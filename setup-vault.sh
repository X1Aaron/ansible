#!/bin/bash
# Setup script for Ansible Vault
# Run this on a system with Ansible installed

set -e

VAULT_PASS_FILE=".vault_pass"
VAULT_FILE="vault/passwords.yml"

echo "Ansible Vault Setup"
echo "=================="
echo ""

# Check if Ansible is installed
if ! command -v ansible-vault &> /dev/null; then
    echo "Error: ansible-vault not found. Please install Ansible first."
    exit 1
fi

# Check if vault password file exists
if [ ! -f "$VAULT_PASS_FILE" ]; then
    echo "Error: Vault password file not found: $VAULT_PASS_FILE"
    echo "Please create it first with your vault password."
    exit 1
fi

# Set proper permissions on password file
chmod 600 "$VAULT_PASS_FILE"
echo "✓ Set permissions on $VAULT_PASS_FILE"

# Check if vault file is already encrypted
if [ -f "$VAULT_FILE" ]; then
    if ansible-vault view "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE" &> /dev/null; then
        echo "✓ Vault file is already encrypted"
    else
        echo "Encrypting vault file: $VAULT_FILE"
        ansible-vault encrypt "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE"
        echo "✓ Vault file encrypted successfully"
    fi
else
    echo "Error: Vault file not found: $VAULT_FILE"
    exit 1
fi

echo ""
echo "Setup complete! You can now:"
echo "  - View vault: ansible-vault view $VAULT_FILE --vault-password-file $VAULT_PASS_FILE"
echo "  - Edit vault: ansible-vault edit $VAULT_FILE --vault-password-file $VAULT_PASS_FILE"
echo "  - Run playbooks: ansible-playbook playbooks/user-management.yml -e 'user_action=create'"
echo ""


