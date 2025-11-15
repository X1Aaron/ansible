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
    
    # Make all .sh files in root executable
    echo "Making all .sh files executable..."
    echo "Current directory: $(pwd)"
    for sh_file in *.sh; do
        if [ -f "$sh_file" ]; then
            chmod +x "$sh_file"
            echo "  ✓ Made $sh_file executable"
        fi
    done
    
    # Verify permissions
    echo ""
    echo "Verifying .sh file permissions:"
    ls -l *.sh 2>/dev/null | awk '{print $1, $9}' || echo "No .sh files found in current directory"
    
    echo ""
    echo "Repository synced successfully at $(date)"
else
    echo "Error: Repository directory not found at $REPO_DIR"
    exit 1
fi

