#!/bin/bash
# Quick reinstall script for Ansible repository
# Usage: curl -sSL https://raw.githubusercontent.com/X1Aaron/ansible/main/reinstall-ansible.sh | bash
# Or: wget -qO- https://raw.githubusercontent.com/X1Aaron/ansible/main/reinstall-ansible.sh | bash

REPO_URL="https://github.com/X1Aaron/ansible.git"
INSTALL_DIR="/opt/ansible"

# Create directory if it doesn't exist
sudo mkdir -p "$INSTALL_DIR"

# Clone or update repository
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Repository exists, pulling latest changes..."
    cd "$INSTALL_DIR"
    sudo git pull
else
    echo "Cloning repository..."
    sudo rm -rf "$INSTALL_DIR"
    sudo git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Set ownership (adjust user as needed)
sudo chown -R $USER:$USER "$INSTALL_DIR" 2>/dev/null || sudo chown -R $(whoami):$(whoami) "$INSTALL_DIR"

echo "Repository installed/updated in $INSTALL_DIR"
echo "To run playbooks: cd $INSTALL_DIR && ansible-playbook playbooks/..."

