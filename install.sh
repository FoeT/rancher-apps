#!/bin/bash

# Create the weapps namespace if it doesn't exist
echo "Creating weapps namespace..."
kubectl create namespace weapps --dry-run=client -o yaml | kubectl apply -f -



# Script to install the rancher-apps Fleet GitRepo

echo "===== Installing Rancher Apps GitRepo ====="

# Run the setup script first to create necessary resources
echo "Running setup script..."
./setup.sh

# Check if the foet-git secret exists
if ! kubectl get secret -n fleet-local foet-git &>/dev/null; then
  echo "Creating foet-git secret for GitHub authentication..."
  
  # Prompt for GitHub credentials if needed
  read -p "Enter GitHub username (default: FoeT): " GITHUB_USER
  GITHUB_USER=${GITHUB_USER:-FoeT}
  
  read -s -p "Enter GitHub personal access token: " GITHUB_TOKEN
  echo ""
  
  if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GitHub token is required"
    exit 1
  fi
  
  # Create the secret
  kubectl create secret generic foet-git -n fleet-local \
    --from-literal=username=${GITHUB_USER} \
    --from-literal=password=${GITHUB_TOKEN}
else
  echo "Using existing foet-git secret for GitHub authentication"
fi

# Apply the Fleet GitRepo configuration
echo "Applying Fleet GitRepo configuration..."
kubectl apply -f fleet-repo.yaml

echo "===== Installation complete ====="
echo "Check GitRepo status with: kubectl get gitrepo -n fleet-local rancher-apps"
