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
    
    # Fix Git safe.directory issue (if repository is owned by different user)
    if ! git config --global --get-all safe.directory | grep -q "^/opt/ansible$"; then
        echo "Configuring Git safe.directory for /opt/ansible..."
        git config --global --add safe.directory "/opt/ansible"
    fi
    
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
    
    # Fix Git safe.directory issue
    cd /opt/ansible
    if ! git config --global --get-all safe.directory | grep -q "^/opt/ansible$"; then
        echo "Configuring Git safe.directory for /opt/ansible..."
        git config --global --add safe.directory "/opt/ansible"
    fi
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

echo ""
echo "=========================================="
echo "Configuration Files Setup"
echo "=========================================="
echo ""
echo "⚠️  IMPORTANT: You need to manually copy example files to create your config files:"
echo ""
echo "  cp vars/users.local.yml.example vars/users.local.yml"
echo "  cp vars/hardening.local.yml.example vars/hardening.local.yml"
echo "  cp vars/proxmox.local.yml.example vars/proxmox.local.yml      # Optional"
echo "  cp vars/secrets.local.yml.example vars/secrets.local.yml"
echo ""
echo "Then edit the .local.yml files and uncomment/modify the examples you need."
echo ""

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Copy example files to create your config files (see above)"
echo "2. Edit vars/*.local.yml files - uncomment and modify the examples"
echo "3. For hardening: Add your IP to hardening_ssh_allowed_sources"
echo "4. Run playbooks:"
echo "   ansible-playbook playbooks/user-management.yml"
echo "   ansible-playbook playbooks/proxmox-install.yml  # If installing Proxmox"
echo "   ansible-playbook playbooks/hardening-firewall.yml  # Test firewall first!"
echo ""
echo "=========================================="
echo "To change to the ansible directory, run:"
echo "  cd /opt/ansible"
echo "=========================================="

