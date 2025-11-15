#!/bin/bash
# Script to sync Ansible repository on server
# Usage: ./sync-repo.sh

REPO_DIR="/path/to/ansible"  # Update this path to your repository location

if [ -d "$REPO_DIR" ]; then
    cd "$REPO_DIR"
    git fetch origin
    git pull origin main
    echo "Repository synced successfully at $(date)"
else
    echo "Error: Repository directory not found at $REPO_DIR"
    exit 1
fi

