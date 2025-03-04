#!/bin/bash

# Script to update the rancher-apps git repository

# Check if we're in the right directory
if [ ! -d ".git" ]; then
  echo "Error: This script must be run from the root of the rancher-apps repository"
  exit 1
fi

# Parse arguments
COMMIT_MESSAGE=""
AUTO_PUSH=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--message)
      COMMIT_MESSAGE="$2"
      shift 2
      ;;
    -p|--push)
      AUTO_PUSH=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [-m|--message \"commit message\"] [-p|--push]"
      exit 1
      ;;
  esac
done

# If no commit message was provided, prompt for one
if [ -z "$COMMIT_MESSAGE" ]; then
  read -p "Enter commit message: " COMMIT_MESSAGE
  
  if [ -z "$COMMIT_MESSAGE" ]; then
    echo "Error: Commit message is required"
    exit 1
  fi
fi

echo "===== Updating Git Repository ====="

# Show current status
echo "Current git status:"
git status --short

# Add all changes
echo -e "\nAdding all changes..."
git add --all

# Show what's being committed
echo -e "\nChanges to be committed:"
git status --short

# Ask for confirmation
read -p "Proceed with commit? [Y/n] " confirm
confirm=${confirm:-Y}

if [[ $confirm =~ ^[Yy] ]]; then
  # Commit changes
  echo -e "\nCommitting changes..."
  git commit -m "$COMMIT_MESSAGE"
  
  # Push if requested
  if [ "$AUTO_PUSH" = true ]; then
    echo -e "\nPushing changes to remote repository..."
    git push origin main
  else
    read -p "Push changes to remote repository? [Y/n] " push
    push=${push:-Y}
    
    if [[ $push =~ ^[Yy] ]]; then
      echo -e "\nPushing changes to remote repository..."
      git push origin main
    else
      echo -e "\nChanges committed but not pushed. To push later, run: git push origin main"
    fi
  fi
  
  echo -e "\n===== Update Complete ====="
else
  echo -e "\nUpdate cancelled. No changes committed."
  exit 0
fi