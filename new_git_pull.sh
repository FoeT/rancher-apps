#!/bin/bash

# Script to pull updates from the git repository using a read-only token
# This token should have only read access to the repositories

# Set variables
GIT_DIR=$(pwd)
READ_ONLY_TOKEN="YOUR_READ_ONLY_TOKEN" # Replace with a GitHub read-only token
GITHUB_USER="FoeT"
GITHUB_EMAIL="forrest.thurgood@gmail.com"
REPO_URL="https://${GITHUB_USER}:${READ_ONLY_TOKEN}@github.com/FoeT/rancher-apps.git"

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
    
  echo "Running setup.sh to apply static workloads..."
  bash ./setup.sh
  
  echo "===== Update Complete ====="
else
  echo "Repository is already up to date at commit: $(git rev-parse --short HEAD)"
  echo "===== No Updates Needed ====="
fi
