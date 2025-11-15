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

#### How It Works

**Declarative Approach:** The variables file is the source of truth.
- Users in the file → Created or updated to match
- Users removed from file → Deleted (if `remove_orphaned_users` is enabled)
- No need to specify create/modify/delete actions

#### Quick Start

1. **Create your variables file:**
   ```bash
   cp vars/users.local.yml.example vars/users.local.yml
   nano vars/users.local.yml
   ```

2. **Add your users:**
   ```yaml
   users:
     - name: my_user
       groups: ['sudo']
       shell: /bin/bash
       ssh_public_key: "ssh-rsa AAAAB3... your-key"
   ```

3. **Run the playbook:**
   ```bash
   ansible-playbook playbooks/user-management.yml
   ```

That's it! The playbook ensures users match your variables file.

#### Usage

Just run the playbook - it automatically:
- Creates users that don't exist
- Updates users that exist but don't match
- Deletes users not in the file (if enabled)

```bash
ansible-playbook playbooks/user-management.yml
```

#### Configuration

Edit `vars/users.local.yml` with your users:

```yaml
users:
  - name: alice
    groups: ['sudo']
    shell: /bin/bash
    comment: "Alice - Developer"
    create_home: true
    ssh_public_key: "ssh-rsa AAAAB3... alice@laptop"
    # Optional: password hash
    # password: "$6$rounds=656000$salt$hash"

  - name: bob
    groups: ['docker']
    shell: /bin/bash
    comment: "Bob - DevOps"
    create_home: true
    ssh_public_key: "ssh-ed25519 AAAAC3... bob@workstation"

# Options
remove_orphaned_users: false  # Set to true to delete users not in 'users' list
remove_home_on_delete: false  # Remove home directory when deleting users
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
users:
  - name: my_user
    ssh_public_key: "ssh-rsa AAAAB3... your-full-key"
```

The key is automatically added to `~/.ssh/authorized_keys`.

---

*More projects coming soon...*
