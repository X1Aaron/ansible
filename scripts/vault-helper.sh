#!/bin/bash
# Ansible Vault Helper Script
# Provides common vault operations

VAULT_DIR="vault"
VAULT_PASS_FILE=".vault_pass"
VAULT_FILE="$VAULT_DIR/passwords.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if vault password file exists
check_vault_pass() {
    if [ ! -f "$VAULT_PASS_FILE" ]; then
        echo -e "${RED}Error: Vault password file not found: $VAULT_PASS_FILE${NC}"
        echo "Create it with: echo 'your_password' > $VAULT_PASS_FILE && chmod 600 $VAULT_PASS_FILE"
        exit 1
    fi
}

# Function to view vault file
view_vault() {
    check_vault_pass
    if [ -f "$VAULT_FILE" ]; then
        echo -e "${GREEN}Viewing vault file: $VAULT_FILE${NC}"
        ansible-vault view "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE"
    else
        echo -e "${RED}Error: Vault file not found: $VAULT_FILE${NC}"
        exit 1
    fi
}

# Function to edit vault file
edit_vault() {
    check_vault_pass
    if [ -f "$VAULT_FILE" ]; then
        echo -e "${GREEN}Editing vault file: $VAULT_FILE${NC}"
        ansible-vault edit "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE"
    else
        echo -e "${YELLOW}Vault file not found. Creating new encrypted file...${NC}"
        ansible-vault create "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE"
    fi
}

# Function to encrypt vault file
encrypt_vault() {
    check_vault_pass
    if [ -f "$VAULT_FILE" ]; then
        if ansible-vault view "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE" &> /dev/null; then
            echo -e "${YELLOW}File is already encrypted.${NC}"
        else
            echo -e "${GREEN}Encrypting vault file: $VAULT_FILE${NC}"
            ansible-vault encrypt "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE"
        fi
    else
        echo -e "${RED}Error: Vault file not found: $VAULT_FILE${NC}"
        exit 1
    fi
}

# Function to decrypt vault file
decrypt_vault() {
    check_vault_pass
    if [ -f "$VAULT_FILE" ]; then
        echo -e "${YELLOW}Decrypting vault file: $VAULT_FILE${NC}"
        echo -e "${YELLOW}Remember to re-encrypt after editing!${NC}"
        ansible-vault decrypt "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE"
    else
        echo -e "${RED}Error: Vault file not found: $VAULT_FILE${NC}"
        exit 1
    fi
}

# Function to rekey vault file
rekey_vault() {
    check_vault_pass
    if [ -f "$VAULT_FILE" ]; then
        echo -e "${GREEN}Rekeying vault file: $VAULT_FILE${NC}"
        echo "Enter new vault password:"
        ansible-vault rekey "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE"
    else
        echo -e "${RED}Error: Vault file not found: $VAULT_FILE${NC}"
        exit 1
    fi
}

# Function to encrypt a string
encrypt_string() {
    check_vault_pass
    if [ -z "$1" ]; then
        echo -e "${RED}Error: Please provide a string to encrypt${NC}"
        echo "Usage: $0 encrypt-string 'your_string'"
        exit 1
    fi
    echo -e "${GREEN}Encrypting string...${NC}"
    ansible-vault encrypt_string "$1" --vault-password-file "$VAULT_PASS_FILE"
}

# Main menu
show_help() {
    echo "Ansible Vault Helper"
    echo "==================="
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  view              View encrypted vault file"
    echo "  edit              Edit encrypted vault file"
    echo "  encrypt           Encrypt vault file"
    echo "  decrypt           Decrypt vault file (temporary)"
    echo "  rekey             Change vault password"
    echo "  encrypt-string    Encrypt a string (usage: encrypt-string 'text')"
    echo "  help              Show this help message"
    echo ""
}

# Main script logic
case "$1" in
    view)
        view_vault
        ;;
    edit)
        edit_vault
        ;;
    encrypt)
        encrypt_vault
        ;;
    decrypt)
        decrypt_vault
        ;;
    rekey)
        rekey_vault
        ;;
    encrypt-string)
        encrypt_string "$2"
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac

