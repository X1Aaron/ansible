# Setting Up Ansible Vault on Your Server

This guide walks you through setting up the Ansible Vault on your server where Ansible is installed.

## Prerequisites

- Ansible installed on the server
- Access to the server (SSH)
- The repository cloned on the server

## Step-by-Step Setup

### 1. Clone/Update Repository on Server

If you haven't already cloned the repository:

```bash
git clone https://github.com/X1Aaron/ansible.git
cd ansible
```

Or if you already have it, pull the latest changes:

```bash
cd ansible
git pull origin main
```

### 2. Transfer Vault Password to Server

**IMPORTANT:** The `.vault_pass` file contains your vault password. Transfer it securely to your server.

#### Option A: Using SCP (Secure Copy)

From your local machine:

```bash
# Windows (PowerShell or WSL)
scp .vault_pass user@your-server:/path/to/ansible/.vault_pass

# Or if using WSL
scp .vault_pass username@server-ip:/home/username/ansible/.vault_pass
```

#### Option B: Manual Creation on Server

If you prefer to create it directly on the server:

```bash
# On the server
cd ansible
nano .vault_pass
# Paste your vault password (see VAULT_PASSWORD.txt for the current password)
# Save and exit (Ctrl+X, Y, Enter)
chmod 600 .vault_pass
```

#### Option C: Using Password Manager

1. Copy the password from `VAULT_PASSWORD.txt` (on your local machine)
2. SSH into your server
3. Create the file:
   ```bash
   cd ansible
   echo "YOUR_VAULT_PASSWORD_HERE" > .vault_pass
   chmod 600 .vault_pass
   ```

### 3. Set Permissions on Server

On your server, ensure the vault password file has correct permissions:

```bash
cd ansible
chmod 600 .vault_pass
ls -la .vault_pass  # Should show -rw------- permissions
```

### 4. Encrypt the Vault File

Run the setup script:

```bash
chmod +x setup-vault.sh
./setup-vault.sh
```

Or manually encrypt:

```bash
ansible-vault encrypt vault/passwords.yml --vault-password-file .vault_pass
```

### 5. Verify Setup

Test that the vault is working:

```bash
# View the encrypted vault file
ansible-vault view vault/passwords.yml --vault-password-file .vault_pass

# Test the playbook (should work without errors)
ansible-playbook playbooks/user-management.yml -e "user_action=list"
```

## Adding Passwords to Vault

Once the vault is set up, you can add user passwords:

### 1. Edit the Vault File

```bash
ansible-vault edit vault/passwords.yml --vault-password-file .vault_pass
```

### 2. Add Password Hashes

Generate a password hash first:

```bash
# Generate hash for a password
python3 -c "import crypt; print(crypt.crypt('your_password', crypt.mksalt(crypt.METHOD_SHA512)))"
```

Or use the helper script:

```bash
chmod +x scripts/generate-password-hash.sh
./scripts/generate-password-hash.sh
```

Then edit the vault and add:

```yaml
user_passwords:
  john_doe: "$6$rounds=656000$salt$hashed_password_here"
  jane_smith: "$6$rounds=656000$salt$hashed_password_here"
```

### 3. Save and Exit

The file will be automatically re-encrypted when you save.

## Using Vault Helper Scripts

The project includes helper scripts for easier vault management:

```bash
# Make scripts executable
chmod +x scripts/vault-helper.sh

# View vault
./scripts/vault-helper.sh view

# Edit vault
./scripts/vault-helper.sh edit

# See all commands
./scripts/vault-helper.sh help
```

## Running Playbooks

Once vault is set up, playbooks will automatically use the vault password file:

```bash
# Create users (passwords from vault will be used automatically)
ansible-playbook playbooks/user-management.yml -e "user_action=create"

# No need to specify --vault-password-file (it's in ansible.cfg)
```

## Troubleshooting

### "Vault password file not found"

Ensure `.vault_pass` exists and has correct permissions:

```bash
ls -la .vault_pass
chmod 600 .vault_pass
```

### "Decryption failed"

Check that you're using the correct vault password. Verify the password in `.vault_pass` matches the one used to encrypt.

### "Permission denied"

```bash
chmod 600 .vault_pass
chmod 644 vault/passwords.yml  # Encrypted file should be readable
```

### "ansible-vault: command not found"

Install Ansible on the server:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# RHEL/CentOS
sudo yum install ansible

# Verify installation
ansible --version
```

## Security Reminders

1. ✅ `.vault_pass` is in `.gitignore` - never commit it
2. ✅ Transfer `.vault_pass` securely (SCP, password manager, etc.)
3. ✅ Set permissions: `chmod 600 .vault_pass`
4. ✅ Store vault password in a secure password manager
5. ✅ Delete `VAULT_PASSWORD.txt` from local machine after saving password

## Quick Reference

```bash
# Setup vault
./setup-vault.sh

# Edit vault
ansible-vault edit vault/passwords.yml --vault-password-file .vault_pass

# View vault
ansible-vault view vault/passwords.yml --vault-password-file .vault_pass

# Run playbook
ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

