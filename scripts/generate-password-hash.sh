#!/bin/bash
# Generate password hash for Ansible user management
# Usage: ./scripts/generate-password-hash.sh

echo "Password Hash Generator for Ansible"
echo "===================================="
echo ""

# Prompt for password
read -sp "Enter password: " PASSWORD
echo ""
read -sp "Confirm password: " CONFIRM
echo ""

if [ "$PASSWORD" != "$CONFIRM" ]; then
    echo "Error: Passwords do not match!"
    exit 1
fi

# Generate hash using Python
if command -v python3 &> /dev/null; then
    HASH=$(python3 -c "import crypt; print(crypt.crypt('$PASSWORD', crypt.mksalt(crypt.METHOD_SHA512)))")
elif command -v python &> /dev/null; then
    HASH=$(python -c "import crypt; print(crypt.crypt('$PASSWORD', crypt.mksalt(crypt.METHOD_SHA512)))")
else
    echo "Error: Python not found. Please install Python 3."
    exit 1
fi

echo ""
echo "Generated SHA-512 hash:"
echo "$HASH"
echo ""
echo "Add this hash to vars/users.local.yml:"
echo "  users:"
echo "    - name: username"
echo "      password: '$HASH'"
echo ""

