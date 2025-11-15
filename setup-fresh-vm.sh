#!/bin/bash
# Complete setup script for fresh VM
# Run this once after getting a new VM with the same IP

set -e  # Exit on error

echo "=========================================="
echo "Setting up Ansible repository on fresh VM"
echo "=========================================="

# Install Ansible if not present
if ! command -v ansible &> /dev/null; then
    echo "Installing Ansible..."
    sudo apt update
    sudo apt install -y ansible git python3-pip
else
    echo "Ansible already installed"
fi

# Create directory and clone or sync repository
if [ -d "/opt/ansible/.git" ]; then
    echo "Repository already exists, syncing..."
    cd /opt/ansible
    git fetch origin
    
    # Check if there are uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo "⚠️  Warning: Uncommitted changes detected. Stashing them..."
        git stash push -m "Auto-stash before sync at $(date)"
    fi
    
    git pull origin main
    sudo chown -R $USER:$USER /opt/ansible
else
    echo "Cloning repository to /opt/ansible..."
    sudo rm -rf /opt/ansible
    sudo git clone https://github.com/X1Aaron/ansible.git /opt/ansible
    sudo chown -R $USER:$USER /opt/ansible
fi

# Create local config files from examples
cd /opt/ansible

# Make all .sh files in root executable
echo "Making all .sh files executable..."
for sh_file in *.sh; do
    if [ -f "$sh_file" ]; then
        chmod +x "$sh_file"
        echo "  ✓ Made $sh_file executable"
    fi
done

echo "Setting up local configuration files..."

# Create users.local.yml if it doesn't exist
if [ ! -f vars/users.local.yml ]; then
    echo "Creating vars/users.local.yml..."
    cat > vars/users.local.yml << 'EOF'
---
# ============================================================================
# ✅ YOUR ACTUAL CONFIG FILE - EDIT THIS FILE! ✅
# ============================================================================
# 
# This is YOUR configuration file (not a template).
# This file is git-ignored and will NOT be overwritten when you sync from GitHub.
# 
# Add your user configuration below.
# See vars/users.local.yml.example for examples and documentation.
# 
# ============================================================================

# Users - The variables file is the source of truth
users: []
  # - name: my_user
  #   groups: ['sudo']
  #   ssh_public_key: "ssh-rsa AAAAB3..."
  #   sudo_passwordless: true

# Options
remove_orphaned_users: false
EOF
    echo "⚠️  IMPORTANT: Edit vars/users.local.yml with your user configuration!"
fi

# Create hardening.local.yml if it doesn't exist
if [ ! -f vars/hardening.local.yml ]; then
    echo "Creating vars/hardening.local.yml..."
    cat > vars/hardening.local.yml << 'EOF'
---
# ============================================================================
# ✅ YOUR ACTUAL CONFIG FILE - EDIT THIS FILE! ✅
# ============================================================================
# 
# This is YOUR configuration file (not a template).
# This file is git-ignored and will NOT be overwritten when you sync from GitHub.
# 
# Add your hardening configuration below.
# See vars/hardening.local.yml.example for examples and documentation.
# 
# ⚠️  IMPORTANT: Add your IP to hardening_ssh_allowed_sources before running firewall hardening!
# 
# ============================================================================

# Add your configuration here
# See vars/hardening.local.yml.example for all available options
EOF
    echo "⚠️  IMPORTANT: Edit vars/hardening.local.yml with your hardening settings!"
    echo "⚠️  Make sure to add your IP to hardening_ssh_allowed_sources before running firewall hardening!"
fi

# Create proxmox.local.yml if it doesn't exist (optional)
if [ ! -f vars/proxmox.local.yml ]; then
    echo "Creating vars/proxmox.local.yml (optional)..."
    cat > vars/proxmox.local.yml << 'EOF'
---
# ============================================================================
# ✅ YOUR ACTUAL CONFIG FILE - EDIT THIS FILE! ✅
# ============================================================================
# 
# This is YOUR configuration file (not a template).
# This file is git-ignored and will NOT be overwritten when you sync from GitHub.
# 
# This file is OPTIONAL - Proxmox installation will use defaults if not present.
# Add your Proxmox configuration below.
# See vars/proxmox.local.yml.example for examples and documentation.
# 
# ============================================================================

# Add your configuration here (optional)
# See vars/proxmox.local.yml.example for all available options
EOF
    echo "⚠️  Proxmox config is optional - defaults will be used if not configured"
fi

# Create secrets.local.yml if it doesn't exist
if [ ! -f vars/secrets.local.yml ]; then
    echo "Creating vars/secrets.local.yml..."
    cat > vars/secrets.local.yml << 'EOF'
---
# ============================================================================
# ✅ YOUR ACTUAL CONFIG FILE - EDIT THIS FILE! ✅
# ============================================================================
# 
# This is YOUR configuration file (not a template).
# This file is git-ignored and will NOT be overwritten when you sync from GitHub.
# 
# ⚠️  SECURITY: This file contains sensitive information!
# ⚠️  Keep this file secure and never commit it to git.
# 
# Add your secrets below.
# See vars/secrets.local.yml.example for examples.
# 
# ============================================================================

# Add your secrets here
# See vars/secrets.local.yml.example for examples
EOF
    chmod 600 vars/secrets.local.yml
    echo "⚠️  IMPORTANT: Edit vars/secrets.local.yml with your root password and other secrets!"
fi

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Edit vars/users.local.yml with your user configuration"
echo "2. Edit vars/hardening.local.yml (add your IP to hardening_ssh_allowed_sources)"
echo "3. Run playbooks:"
echo "   ansible-playbook playbooks/user-management.yml"
echo "   ansible-playbook playbooks/proxmox-install.yml  # If installing Proxmox"
echo "   ansible-playbook playbooks/hardening-firewall.yml  # Test firewall first!"
echo ""
echo "=========================================="
echo "To change to the ansible directory, run:"
echo "  cd /opt/ansible"
echo "=========================================="

