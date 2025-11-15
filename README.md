# Ansible User Management Automation

This Ansible project provides automation for managing users on a local server. All operations run against localhost.

## Project Structure

```
.
├── ansible.cfg              # Ansible configuration
├── inventory/
│   └── hosts.yml           # Localhost inventory
├── playbooks/
│   └── user-management.yml # Main playbook
├── roles/
│   └── user_management/
│       └── tasks/
│           └── main.yml    # User management tasks
├── vars/
│   └── users.yml           # User definitions
├── docs/
│   ├── SERVER_SETUP.md     # Server setup and sync guide
│   └── VAULT_GUIDE.md      # Ansible Vault usage guide
├── vault/
│   ├── passwords.yml        # Encrypted user passwords (vault)
│   └── .gitkeep
├── scripts/
│   ├── generate-password-hash.sh  # Generate password hashes
│   └── vault-helper.sh     # Vault management helper
├── sync-repo.sh            # Script to sync repository on server
└── README.md
```

## Server Setup and Sync

To download and keep this repository in sync on your server:

**Initial Setup:**
```bash
git clone https://github.com/X1Aaron/ansible.git
cd ansible
```

**Keep in Sync:**
```bash
cd ansible
git pull origin main
```

For detailed instructions on automated syncing, cron jobs, and best practices, see [docs/SERVER_SETUP.md](docs/SERVER_SETUP.md).

## Vault Setup on Server

The vault password file (`.vault_pass`) has been created locally but needs to be transferred to your server securely.

**Quick Setup:**
1. Transfer `.vault_pass` to your server (see `VAULT_PASSWORD.txt` for the password)
2. On your server, run: `./setup-vault.sh`
3. Done! Playbooks will automatically use the vault.

For detailed server setup instructions, see [docs/VAULT_SERVER_SETUP.md](docs/VAULT_SERVER_SETUP.md).

## Prerequisites

- Ansible installed on your system
- Sudo/root access for user management operations
- Python installed (for Ansible modules)

### Installing Ansible

**On Windows (WSL or Linux subsystem):**
```bash
sudo apt update
sudo apt install ansible
```

**On Linux:**
```bash
sudo apt install ansible  # Debian/Ubuntu
sudo yum install ansible   # RHEL/CentOS
```

**On macOS:**
```bash
brew install ansible
```

## Usage

### 1. Create Users

**On your server**, create and edit the local override file (this won't be overwritten on sync):

```bash
cp vars/users.local.yml.example vars/users.local.yml
nano vars/users.local.yml
```

Then define users under `users_to_create`:

```yaml
users_to_create:
  - name: john_doe
    groups: ['sudo', 'docker']
    shell: /bin/bash
    comment: "John Doe - Developer"
    create_home: true
    ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-public-key-here"
```

Run the playbook:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

### 2. Modify Users

Edit `vars/users.local.yml` and define modifications under `users_to_modify`:

```yaml
users_to_modify:
  - name: john_doe
    groups: ['sudo', 'www-data']
    append: true
    shell: /bin/zsh
```

Run the playbook:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=modify"
```

### 3. Delete Users

Edit `vars/users.local.yml` and list users under `users_to_delete`:

```yaml
users_to_delete:
  - old_user1
  - old_user2
```

Run the playbook:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=delete"
```

To also remove home directories:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=delete" -e "remove_home=true"
```

### 4. List All Users

List all users on the system:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=list"
```

## User Configuration Options

### Available Fields for User Creation/Modification

- `name`: Username (required)
- `groups`: List of groups the user should belong to
- `append`: Add groups to existing groups (default: true)
- `shell`: Login shell (default: /bin/bash)
- `home`: Home directory path
- `create_home`: Create home directory (default: true)
- `comment`: User description/comment
- `password`: Encrypted password (use ansible-vault for security)
- `password_lock`: Lock the password (default: false)
- `system`: Create as system user (default: false)
- `uid`: Specific UID for the user
- `ssh_public_key`: Add your public SSH key to user's authorized_keys (recommended)
- `ssh_keys_exclusive`: Replace all existing keys (default: false, adds to existing keys)
- `generate_ssh_key`: Generate SSH key for user (default: false, not recommended - use ssh_public_key instead)
- `ssh_key_type`: SSH key type (default: rsa)
- `ssh_key_bits`: SSH key bits (default: 2048)

## Security Best Practices

### Password Management with Ansible Vault

**Never store plaintext passwords in your playbooks!** This project is configured to use Ansible Vault for secure password management.

#### Quick Start with Vault

1. **Create vault password file:**
   ```bash
   echo "your_secure_password" > .vault_pass
   chmod 600 .vault_pass
   ```

2. **Encrypt the vault file:**
   ```bash
   ansible-vault encrypt vault/passwords.yml
   ```

3. **Add passwords to vault:**
   ```bash
   ansible-vault edit vault/passwords.yml
   ```
   Add your passwords:
   ```yaml
   user_passwords:
     john_doe: "$6$rounds=656000$..."
   ```

4. **Define users in `vars/users.local.yml` (username must match vault key):**
   ```yaml
   users_to_create:
     - name: john_doe  # Must match key in vault: user_passwords['john_doe']
       groups: ['sudo']
       # Password automatically looked up from vault!
   ```

5. **Run playbooks (password file is auto-detected):**
   ```bash
   ansible-playbook playbooks/user-management.yml -e "user_action=create"
   ```

#### Helper Scripts

- **Generate password hash:**
  ```bash
  chmod +x scripts/generate-password-hash.sh
  ./scripts/generate-password-hash.sh
  ```

- **Vault helper:**
  ```bash
  chmod +x scripts/vault-helper.sh
  ./scripts/vault-helper.sh view    # View vault file
  ./scripts/vault-helper.sh edit    # Edit vault file
  ```

For detailed vault usage, see [docs/VAULT_GUIDE.md](docs/VAULT_GUIDE.md).

## Examples

### Example 1: Create a developer user with sudo access
```yaml
users_to_create:
  - name: developer
    groups: ['sudo']
    shell: /bin/bash
    comment: "Development User"
    create_home: true
    generate_ssh_key: true
```

### Example 2: Add user to additional groups
```yaml
users_to_modify:
  - name: developer
    groups: ['docker', 'www-data']
    append: true
```

### Example 3: Create multiple users at once
```yaml
users_to_create:
  - name: alice
    groups: ['sudo']
    comment: "Alice Smith"
  - name: bob
    groups: ['docker']
    comment: "Bob Johnson"
  - name: charlie
    groups: ['www-data']
    comment: "Charlie Brown"
```

## Troubleshooting

### Permission Denied
Ensure you have sudo access:
```bash
sudo ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

### Connection Issues
Verify localhost connection:
```bash
ansible localhost -m ping
```

### Check Ansible Version
```bash
ansible --version
```

## Additional Notes

- All operations require root/sudo privileges
- The playbook uses `become: yes` to escalate privileges
- User operations are idempotent (safe to run multiple times)
- The `list` action is read-only and doesn't require any user definitions

