# Ansible User Management Automation

This Ansible project provides automation for managing users on a local server. All operations run against localhost.

## Overview

This project separates **code** (in git, syncs to GitHub) from **variables** (your user data, stays on server).

- **Code** = Playbooks, roles, config (syncs to GitHub)
- **Variables** = One file (`vars/users.local.yml`) with all your users, passwords, SSH keys (stays on server)

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
│   ├── users.yml           # Template (don't edit on server)
│   └── users.local.yml      # YOUR file (edit this - not in git)
├── scripts/
│   └── generate-password-hash.sh
└── README.md
```

## How It Works

### Code vs Variables

**CODE (Synced to GitHub):**
- `playbooks/user-management.yml` - The playbook
- `roles/user_management/tasks/main.yml` - Code that creates users
- `ansible.cfg`, `inventory/` - Configuration
- These files sync to GitHub and update when you run `git pull`

**VARIABLES (Stays on Server):**
- `vars/users.local.yml` - **This is your variables file**
- Contains ALL your users, passwords, SSH keys, groups, etc.
- Is in `.gitignore` - will NEVER sync to GitHub
- Stays on your server only
- **This is the ONLY file you need to edit**

### The Flow

1. You edit `vars/users.local.yml` (your variables)
2. Playbook loads `vars/users.local.yml` (reads your variables)
3. Role uses variables to create users
4. You sync: `git pull` updates code, but your variables file stays untouched

## Quick Start

### On Your Server:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/X1Aaron/ansible.git
   cd ansible
   ```

2. **Create your variables file:**
   ```bash
   cp vars/users.local.yml.example vars/users.local.yml
   nano vars/users.local.yml
   ```

3. **Add your users** (see examples below)

4. **Run the playbook:**
   ```bash
   ansible-playbook playbooks/user-management.yml -e "user_action=create"
   ```

## Usage

### Create Users

Edit `vars/users.local.yml`:

```yaml
users_to_create:
  - name: john_doe
    groups: ['sudo', 'docker']
    shell: /bin/bash
    comment: "John Doe - Developer"
    create_home: true
    ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-public-key"
    password: "$6$rounds=656000$salt$hashed_password"  # Optional
```

Run:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

### Modify Users

Edit `vars/users.local.yml`:

```yaml
users_to_modify:
  - name: john_doe
    groups: ['sudo', 'www-data']
    append: true
    shell: /bin/zsh
```

Run:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=modify"
```

### Delete Users

Edit `vars/users.local.yml`:

```yaml
users_to_delete:
  - old_user1
  - old_user2
```

Run:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=delete"
```

To also remove home directories:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=delete" -e "remove_home=true"
```

### List All Users

```bash
ansible-playbook playbooks/user-management.yml -e "user_action=list"
```

## Password Management

### Why Password Hashes?

Linux doesn't store plain text passwords. It stores encrypted versions called "hashes". Ansible's `user` module requires passwords in hash format.

**You type:** `mypassword123`  
**Linux needs:** `$6$rounds=656000$salt$verylonghash`

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

## SSH Keys

### Get Your Public Key

On your local machine:
```bash
cat ~/.ssh/id_rsa.pub
# Or
cat ~/.ssh/id_ed25519.pub
```

### Add to User

In `vars/users.local.yml`:

```yaml
users_to_create:
  - name: my_user
    ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-full-key"
```

The playbook will automatically add it to the user's `~/.ssh/authorized_keys`.

### Multiple Keys

Keys are added (not replaced) by default. To replace all existing keys:

```yaml
users_to_create:
  - name: my_user
    ssh_public_key: "ssh-rsa AAAAB3..."
    ssh_keys_exclusive: true  # Replaces all existing keys
```

## Configuration Options

### Available Fields for User Creation/Modification

- `name`: Username (required)
- `groups`: List of groups the user should belong to
- `append`: Add groups to existing groups (default: true)
- `shell`: Login shell (default: /bin/bash)
- `home`: Home directory path
- `create_home`: Create home directory (default: true)
- `comment`: User description/comment
- `password`: Password hash (generate with Python crypt - see Password Management)
- `password_lock`: Lock the password (default: false)
- `system`: Create as system user (default: false)
- `uid`: Specific UID for the user
- `ssh_public_key`: Add your public SSH key to user's authorized_keys (recommended)
- `ssh_keys_exclusive`: Replace all existing keys (default: false, adds to existing keys)

## Complete Example

Here's a complete `vars/users.local.yml` example:

```yaml
---
users_to_create:
  - name: alice
    groups: ['sudo', 'docker']
    shell: /bin/bash
    comment: "Alice - DevOps Engineer"
    create_home: true
    ssh_public_key: "ssh-rsa AAAAB3... alice@laptop"
    password: "$6$rounds=656000$abc123$xyz789..."

  - name: bob
    groups: ['www-data']
    shell: /bin/bash
    comment: "Bob - Web Developer"
    create_home: true
    ssh_public_key: "ssh-ed25519 AAAAC3... bob@workstation"
    # No password - SSH key only

users_to_modify:
  - name: existing_user
    groups: ['sudo']
    append: true

users_to_delete:
  - old_user
```

## Server Setup and Sync

### Initial Setup

```bash
git clone https://github.com/X1Aaron/ansible.git
cd ansible
cp vars/users.local.yml.example vars/users.local.yml
nano vars/users.local.yml
```

### Keeping Repository in Sync

**Manual sync:**
```bash
cd ansible
git pull origin main
```

Your `vars/users.local.yml` file will **never** be touched because it's in `.gitignore`.

**Automated sync with cron:**

Create a script:
```bash
#!/bin/bash
REPO_DIR="/path/to/ansible"
cd "$REPO_DIR"
git fetch origin
git pull origin main
```

Add to crontab:
```bash
crontab -e
# Sync every hour
0 * * * * /path/to/sync-repo.sh >> /var/log/ansible-sync.log 2>&1
```

## Prerequisites

- Ansible installed on your system
- Sudo/root access for user management operations
- Python installed (for Ansible modules)

### Installing Ansible

**On Linux:**
```bash
sudo apt install ansible  # Debian/Ubuntu
sudo yum install ansible   # RHEL/CentOS
```

**On macOS:**
```bash
brew install ansible
```

**On Windows (WSL):**
```bash
sudo apt update
sudo apt install ansible
```

## Troubleshooting

### "File not found" error

If the playbook complains about missing `vars/users.local.yml`:
```bash
cp vars/users.local.yml.example vars/users.local.yml
```

### Permission denied

Ensure you have sudo access:
```bash
sudo ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

### Check Ansible version

```bash
ansible --version
```

### Test connection

```bash
ansible localhost -m ping
```

## Summary

- **Edit:** `vars/users.local.yml` (your variables file)
- **Code:** Syncs from GitHub automatically
- **Variables:** Stay on your server (not in git)
- **One file:** All your users, passwords, SSH keys in one place
