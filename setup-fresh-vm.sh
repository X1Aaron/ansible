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

# Create directory and clone repository
echo "Cloning repository to /opt/ansible..."
sudo rm -rf /opt/ansible
sudo git clone https://github.com/X1Aaron/ansible.git /opt/ansible
sudo chown -R $USER:$USER /opt/ansible

# Create local config files from examples
cd /opt/ansible

echo "Setting up local configuration files..."

# Create users.local.yml if it doesn't exist
if [ ! -f vars/users.local.yml ]; then
    echo "Creating vars/users.local.yml from example..."
    cp vars/users.local.yml.example vars/users.local.yml
    echo "⚠️  IMPORTANT: Edit vars/users.local.yml with your user configuration!"
fi

# Create hardening.local.yml if it doesn't exist
if [ ! -f vars/hardening.local.yml ]; then
    echo "Creating vars/hardening.local.yml from example..."
    cp vars/hardening.local.yml.example vars/hardening.local.yml
    echo "⚠️  IMPORTANT: Edit vars/hardening.local.yml with your hardening settings!"
    echo "⚠️  Make sure to add your IP to hardening_ssh_allowed_sources before running firewall hardening!"
fi

# Create proxmox.local.yml if it doesn't exist (optional)
if [ ! -f vars/proxmox.local.yml ]; then
    echo "Creating vars/proxmox.local.yml from example (optional)..."
    cp vars/proxmox.local.yml.example vars/proxmox.local.yml 2>/dev/null || echo "Proxmox config not needed, skipping..."
fi

# Create secrets.local.yml if it doesn't exist
if [ ! -f vars/secrets.local.yml ]; then
    echo "Creating vars/secrets.local.yml from example..."
    cp vars/secrets.local.yml.example vars/secrets.local.yml
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
echo "You are now in: $(pwd)"
echo "=========================================="

# Change to ansible directory
cd "$INSTALL_DIR"

