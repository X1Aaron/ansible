#!/bin/bash
# Script to sync Ansible repository on server
# Usage: ./sync-repo.sh

REPO_DIR="/opt/ansible"  # Update this path to your repository location

if [ -d "$REPO_DIR" ]; then
    cd "$REPO_DIR"
    
    # Fix Git safe.directory issue (if repository is owned by different user)
    if ! git config --global --get-all safe.directory | grep -q "^${REPO_DIR}$"; then
        echo "Configuring Git safe.directory for $REPO_DIR..."
        git config --global --add safe.directory "$REPO_DIR"
    fi
    
    # Fix ownership if user doesn't have write access to .git directory
    if [ ! -w ".git" ] || [ ! -w ".git/FETCH_HEAD" ] 2>/dev/null; then
        echo "Fixing repository ownership (requires sudo)..."
        if sudo chown -R "$USER:$USER" "$REPO_DIR" 2>/dev/null; then
            echo "  ✓ Ownership fixed"
        else
            echo "  ⚠️  Could not fix ownership automatically. Run: sudo chown -R $USER:$USER $REPO_DIR"
        fi
    fi
    
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

