# Ansible Vault Guide

This guide explains how to use Ansible Vault to securely manage passwords and sensitive data in this project.

## What is Ansible Vault?

Ansible Vault encrypts sensitive data such as passwords, API keys, and other secrets so they can be stored safely in version control. The encrypted files can be committed to Git without exposing sensitive information.

## Project Structure

```
.
├── vault/
│   ├── passwords.yml      # Encrypted user passwords
│   └── .gitkeep
├── .vault_pass            # Vault password file (NOT in git)
└── ansible.cfg            # Configured to use .vault_pass
```

## Initial Setup

### 1. Create Vault Password File

Create a secure vault password file (this will NOT be committed to git):

```bash
# Option 1: Create manually
echo "your_secure_vault_password" > .vault_pass
chmod 600 .vault_pass

# Option 2: Generate a random password
openssl rand -base64 32 > .vault_pass
chmod 600 .vault_pass
```

**Important:** The `.vault_pass` file is in `.gitignore` and should NEVER be committed to version control.

### 2. Encrypt the Vault File

```bash
# Encrypt the passwords file
ansible-vault encrypt vault/passwords.yml
```

You'll be prompted for the vault password (use the one from `.vault_pass`).

## Working with Vault Files

### View Encrypted File

```bash
# View encrypted content
ansible-vault view vault/passwords.yml

# Or if using password file
ansible-vault view vault/passwords.yml --vault-password-file .vault_pass
```

### Edit Encrypted File

```bash
# Edit encrypted file (opens in default editor)
ansible-vault edit vault/passwords.yml

# Or with password file
ansible-vault edit vault/passwords.yml --vault-password-file .vault_pass
```

### Create Encrypted Strings

To encrypt individual passwords for use in variables:

```bash
# Encrypt a password string
ansible-vault encrypt_string 'my_secure_password' --name 'password_hash'

# Output will be something like:
# password_hash: !vault |
#   $ANSIBLE_VAULT;1.1;AES256
#   663864396539663161326462636239653...
```

### Decrypt File (Temporary)

```bash
# Decrypt to view/edit (creates decrypted version)
ansible-vault decrypt vault/passwords.yml

# Re-encrypt after editing
ansible-vault encrypt vault/passwords.yml
```

## Using Vault in Playbooks

### Method 1: Store Passwords in Vault File

1. **Edit the vault file:**
   ```bash
   ansible-vault edit vault/passwords.yml
   ```

2. **Add passwords:**
   ```yaml
   ---
   user_passwords:
     john_doe: "$6$rounds=656000$salt$hashed_password"
     jane_smith: "$6$rounds=656000$salt$hashed_password"
   ```

3. **Reference in `vars/users.yml`:**
   ```yaml
   users_to_create:
     - name: john_doe
       groups: ['sudo']
       password: "{{ user_passwords['john_doe'] }}"
   ```

   Or let the role auto-lookup:
   ```yaml
   users_to_create:
     - name: john_doe
       groups: ['sudo']
       # Password will be automatically looked up from user_passwords[john_doe]
   ```

### Method 2: Encrypt Individual Variables

You can also encrypt strings directly in `vars/users.yml`:

```yaml
users_to_create:
  - name: john_doe
    password: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      663864396539663161326462636239653...
```

## Generating Password Hashes

Ansible requires passwords in crypt format. Generate them using:

### On Linux/macOS:

```bash
# Using Python
python3 -c "import crypt; print(crypt.crypt('your_password', crypt.mksalt(crypt.METHOD_SHA512)))"

# Using openssl
openssl passwd -6 'your_password'

# Using mkpasswd (if installed)
mkpasswd --method=sha-512
```

### On Windows (WSL/PowerShell):

```bash
# In WSL
python3 -c "import crypt; print(crypt.crypt('your_password', crypt.mksalt(crypt.METHOD_SHA512)))"
```

### Store in Vault:

```bash
# Generate hash
HASH=$(python3 -c "import crypt; print(crypt.crypt('mypassword', crypt.mksalt(crypt.METHOD_SHA512)))")

# Encrypt and add to vault
ansible-vault encrypt_string "$HASH" --name 'john_doe_password'
```

Then add to `vault/passwords.yml`:
```yaml
user_passwords:
  john_doe: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    ...
```

## Running Playbooks with Vault

### Using Password File (Recommended)

Since `ansible.cfg` is configured with `vault_password_file = .vault_pass`, playbooks will automatically use it:

```bash
ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

### Using Command Line

```bash
# Prompt for password
ansible-playbook playbooks/user-management.yml --ask-vault-pass

# Use password file
ansible-playbook playbooks/user-management.yml --vault-password-file .vault_pass
```

## Security Best Practices

### 1. Protect Vault Password File

```bash
# Set restrictive permissions
chmod 600 .vault_pass

# Ensure it's in .gitignore (already done)
```

### 2. Rotate Vault Passwords

```bash
# Rekey all vault files with new password
ansible-vault rekey vault/passwords.yml
```

### 3. Use Different Vault Passwords for Different Environments

```bash
# Development
.vault_pass_dev

# Production
.vault_pass_prod
```

Update `ansible.cfg` or use `--vault-password-file` flag.

### 4. Never Commit Vault Passwords

- ✅ `.vault_pass` is in `.gitignore`
- ✅ Never commit unencrypted sensitive data
- ✅ Use environment-specific password files

### 5. Share Vault Passwords Securely

- Use password managers (1Password, LastPass, etc.)
- Use secure communication channels
- Rotate passwords regularly
- Use different passwords for different projects

## Helper Scripts

### Create Password Hash Script

Create `scripts/generate-password-hash.sh`:

```bash
#!/bin/bash
# Generate password hash for Ansible
read -sp "Enter password: " PASSWORD
echo
HASH=$(python3 -c "import crypt; print(crypt.crypt('$PASSWORD', crypt.mksalt(crypt.METHOD_SHA512)))")
echo "Hash: $HASH"
echo "Encrypted string:"
ansible-vault encrypt_string "$HASH" --name 'password_hash'
```

## Troubleshooting

### "Vault password file not found"

Ensure `.vault_pass` exists and has correct permissions:
```bash
ls -la .vault_pass
chmod 600 .vault_pass
```

### "Decryption failed"

Check that you're using the correct vault password:
```bash
ansible-vault view vault/passwords.yml --vault-password-file .vault_pass
```

### "Permission denied"

Ensure vault password file has correct permissions:
```bash
chmod 600 .vault_pass
```

### Password not working

Verify the password hash format. It should start with `$6$` for SHA-512:
```bash
# Check hash format
ansible-vault view vault/passwords.yml | grep password
```

## Example Workflow

1. **Create vault password:**
   ```bash
   echo "my_secure_password" > .vault_pass
   chmod 600 .vault_pass
   ```

2. **Generate password hash:**
   ```bash
   python3 -c "import crypt; print(crypt.crypt('userpass123', crypt.mksalt(crypt.METHOD_SHA512)))"
   ```

3. **Edit vault file:**
   ```bash
   ansible-vault edit vault/passwords.yml
   ```
   Add:
   ```yaml
   user_passwords:
     testuser: "$6$rounds=656000$..."
   ```

4. **Update users.yml:**
   ```yaml
   users_to_create:
     - name: testuser
       groups: ['sudo']
   ```

5. **Run playbook:**
   ```bash
   ansible-playbook playbooks/user-management.yml -e "user_action=create"
   ```

## Additional Resources

- [Ansible Vault Documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [Ansible Vault Best Practices](https://docs.ansible.com/ansible/latest/user_guide/vault.html#best-practices-when-using-vault)

