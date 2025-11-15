# Ansible Automation Repository

This repository contains Ansible automation playbooks for server management tasks.

## Repository Structure

```
.
├── playbooks/          # Ansible playbooks
├── roles/              # Reusable Ansible roles
├── vars/               # Variable files
│   └── *.local.yml    # Local variables (not in git)
├── inventory/          # Server inventories
├── scripts/            # Helper scripts
└── README.md           # This file
```

## How It Works

**Code vs Variables:**
- **Code** (playbooks, roles, config) → In git, syncs to GitHub
- **Variables** (`*.local.yml` files) → Not in git, stay on server

Edit `*.local.yml` files with your server-specific data. These files are in `.gitignore` and will never sync to GitHub.

## Prerequisites

- Ansible installed
- Sudo/root access
- Python installed

**Install Ansible:**
```bash
# Linux
sudo apt install ansible  # Debian/Ubuntu
sudo yum install ansible   # RHEL/CentOS

# macOS
brew install ansible
```

## Server Setup

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

Your `*.local.yml` files will never be overwritten (they're in `.gitignore`).

---

## Projects

### User Management

Automate user account creation, modification, and deletion on local servers.

#### Quick Start

1. **Create your variables file:**
   ```bash
   cp vars/users.local.yml.example vars/users.local.yml
   nano vars/users.local.yml
   ```

2. **Add your users:**
   ```yaml
   users_to_create:
     - name: my_user
       groups: ['sudo']
       shell: /bin/bash
       ssh_public_key: "ssh-rsa AAAAB3... your-key"
   ```

3. **Run the playbook:**
   ```bash
   ansible-playbook playbooks/user-management.yml -e "user_action=create"
   ```

#### Usage

**Create Users:**
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

**Modify Users:**
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=modify"
```

**Delete Users:**
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=delete"
```

**List Users:**
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=list"
```

#### Configuration

Edit `vars/users.local.yml` with your users:

```yaml
users_to_create:
  - name: alice
    groups: ['sudo']
    shell: /bin/bash
    comment: "Alice - Developer"
    create_home: true
    ssh_public_key: "ssh-rsa AAAAB3... alice@laptop"
    # Optional: password hash
    # password: "$6$rounds=656000$salt$hash"

users_to_modify:
  - name: existing_user
    groups: ['sudo', 'docker']
    append: true

users_to_delete:
  - old_user
```

#### Options

- `name`: Username (required)
- `groups`: List of groups (e.g., `['sudo', 'docker']`)
- `shell`: Login shell (default: `/bin/bash`)
- `comment`: User description
- `create_home`: Create home directory (default: `true`)
- `ssh_public_key`: Your SSH public key (recommended)
- `password`: Password hash (optional - see below)
- `password_lock`: Lock password (default: `false`)

#### Passwords

**SSH Keys vs Passwords:**
- SSH keys: No password needed for SSH access
- Passwords: Optional, useful for console login or sudo

**Generate Password Hash:**
```bash
python3 -c "import crypt; print(crypt.crypt('yourpassword', crypt.mksalt(crypt.METHOD_SHA512)))"
```

Use the output (starts with `$6$`) in your user definition.

**Note:** `vars/users.local.yml` is in `.gitignore` and will NOT sync to GitHub, so your passwords stay on your server.

#### SSH Keys

**Get your public key:**
```bash
cat ~/.ssh/id_rsa.pub
# Or
cat ~/.ssh/id_ed25519.pub
```

**Add to user:**
```yaml
users_to_create:
  - name: my_user
    ssh_public_key: "ssh-rsa AAAAB3... your-full-key"
```

The key is automatically added to `~/.ssh/authorized_keys`.

---

*More projects coming soon...*
