#!/bin/bash

# Script to pull updates from the git repository using a read-only token
# This token should have only read access to the repositories

# Set variables
GIT_DIR=$(pwd)
GITHUB_USER="FoeT"
GITHUB_EMAIL="forrest.thurgood@gmail.com"

# Try to get token from kubernetes secret first
if kubectl get secret -n fleet-local github-readonly-token &>/dev/null; then
  echo "Getting GitHub token from Kubernetes secret..."
  READ_ONLY_TOKEN=$(kubectl get secret -n fleet-local github-readonly-token -o jsonpath='{.data.token}' | base64 -d)
else
  # Fall back to hardcoded token (not recommended)
  READ_ONLY_TOKEN="YOUR_READ_ONLY_TOKEN" # Replace with a GitHub read-only token
fi

REPO_URL="https://${GITHUB_USER}:${READ_ONLY_TOKEN}@github.com/FoeT/rancher-apps.git"

# Check if the token has been set or retrieved
if [[ "$READ_ONLY_TOKEN" == "YOUR_READ_ONLY_TOKEN" || -z "$READ_ONLY_TOKEN" ]]; then
  echo "ERROR: GitHub read-only token not configured."
  echo "Please follow these steps to create a read-only token:"
  echo "  1. Go to GitHub → Settings → Developer Settings → Personal Access Tokens → Fine-grained tokens"
  echo "  2. Click 'Generate new token'"
  echo "  3. Give it a descriptive name (e.g., 'rancher-apps-readonly')"
  echo "  4. Set expiration as needed"
  echo "  5. Select your repository under 'Repository access'"
  echo "  6. Under Permissions > Repository permissions, grant:"
  echo "     - Contents: Read-only"
  echo "     - Metadata: Read-only"
  echo "  7. Click 'Generate token'"
  echo "  8. You can either:"
  echo "     a. Update the READ_ONLY_TOKEN variable in this script (less secure), or"
  echo "     b. Store it in a Kubernetes secret (recommended):"
  echo "        kubectl create secret generic github-readonly-token -n fleet-local --from-literal=token=YOUR_TOKEN"
  echo ""
  echo "After setting the token, run this script again."
  exit 1
fi

# Print header
echo "===== Git Pull Script ====="
echo "Pulling latest changes from repository..."

# Configure git if not already configured
if [[ -z $(git config --get user.name) ]]; then
  git config user.name "${GITHUB_USER}"
fi
if [[ -z $(git config --get user.email) ]]; then
  git config user.email "${GITHUB_EMAIL}"
fi

# Fetch the latest changes
git fetch origin main

# Check if there are changes to pull
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
  echo "New changes detected. Pulling updates..."
  
  # Save any local changes
  if [ -n "$(git status --porcelain)" ]; then
    echo "Stashing local changes..."
    git stash
  fi
  
  # Pull the changes
  git pull origin main
  
  # Apply stashed changes if any
  if [ -n "$(git stash list)" ]; then
    echo "Applying stashed changes..."
    git stash pop
  fi
  
  echo "Repository updated successfully to commit: $(git rev-parse --short HEAD)"
  
  # Create the github-container-registry secret
  echo "Updating GitHub container registry secret..."
  kubectl create secret docker-registry github-container-registry \
    --namespace weapps \
    --docker-server=ghcr.io \
    --docker-username=${GITHUB_USER} \
    --docker-password=${READ_ONLY_TOKEN} \
    --docker-email=${GITHUB_EMAIL} \
    --dry-run=client -o yaml | kubectl apply -f -
  
  # Apply static workloads
  echo "Applying updated static workloads..."
  if [ -f "./setup.sh" ]; then
    # Only run the static workloads part
    echo "- Deploying PiHole..."
    kubectl apply -f static/pihole/deployment.yaml
  else
    echo "Warning: setup.sh not found, skipping static workload deployment"
  fi
  
  echo "===== Update Complete ====="
else
  echo "Repository is already up to date at commit: $(git rev-parse --short HEAD)"
  echo "===== No Updates Needed ====="
fi
