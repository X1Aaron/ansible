#!/bin/bash
# Script to sync Ansible repository on server
# Usage: ./sync-repo.sh

REPO_DIR="/opt/ansible"  # Update this path to your repository location

if [ -d "$REPO_DIR" ]; then
    cd "$REPO_DIR"
    git fetch origin
    
    # Check if there are uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo "⚠️  Warning: Uncommitted changes detected. Stashing them..."
        git stash push -m "Auto-stash before sync at $(date)"
    fi
    
    git pull origin main
    echo "Repository synced successfully at $(date)"
else
    echo "Error: Repository directory not found at $REPO_DIR"
    exit 1
fi

