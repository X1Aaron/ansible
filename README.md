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
│   └── SERVER_SETUP.md     # Server setup and sync guide
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

## Quick Start

**On your server:**
1. Clone the repository: `git clone https://github.com/X1Aaron/ansible.git && cd ansible`
2. Create your user file: `cp vars/users.local.yml.example vars/users.local.yml`
3. Edit users: `nano vars/users.local.yml` (put ALL your users, passwords, SSH keys here)
4. Run playbook: `ansible-playbook playbooks/user-management.yml -e "user_action=create"`

**That's it!** Everything goes in one file: `vars/users.local.yml` - it's the only file you need to edit.

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

**On your server**, create and edit your user file (this is the ONLY file you need to edit):

```bash
cp vars/users.local.yml.example vars/users.local.yml
nano vars/users.local.yml
```

Define all your users, passwords, and SSH keys in this one file:

```yaml
users_to_create:
  - name: john_doe
    groups: ['sudo', 'docker']
    shell: /bin/bash
    comment: "John Doe - Developer"
    create_home: true
    ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-public-key-here"
    # Optional: password hash (generate with: python3 -c "import crypt; print(crypt.crypt('password', crypt.mksalt(crypt.METHOD_SHA512)))")
    # password: "$6$rounds=656000$salt$hashed_password"
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
- `password`: Password hash (generate with Python crypt - see Password Management section)
- `password_lock`: Lock the password (default: false)
- `system`: Create as system user (default: false)
- `uid`: Specific UID for the user
- `ssh_public_key`: Add your public SSH key to user's authorized_keys (recommended)
- `ssh_keys_exclusive`: Replace all existing keys (default: false, adds to existing keys)
- `generate_ssh_key`: Generate SSH key for user (default: false, not recommended - use ssh_public_key instead)
- `ssh_key_type`: SSH key type (default: rsa)
- `ssh_key_bits`: SSH key bits (default: 2048)

## Password Management

**Important:** Linux requires passwords in hash format, not plain text.

### Generate Password Hash

On your server:
```bash
python3 -c "import crypt; print(crypt.crypt('yourpassword', crypt.mksalt(crypt.METHOD_SHA512)))"
```

Copy the output (starts with `$6$`) and use it in `vars/users.local.yml`:

```yaml
users_to_create:
  - name: my_user
    password: "$6$rounds=656000$salt$hashed_password_here"
```

**Note:** `vars/users.local.yml` is in `.gitignore` and will NOT sync to GitHub, so your passwords stay on your server.

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

