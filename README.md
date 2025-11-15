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
# Note: System users (UID < 1000) and root are ALWAYS protected from deletion
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

**Security Note:** If you don't set a password, the account is **locked** and cannot be logged into with a password. This is secure - the account can only be accessed via SSH keys (if configured).

**SSH Keys vs Passwords:**
- SSH keys: No password needed for SSH access (recommended)
- Passwords: Optional, useful for console login or sudo
- **No password = Account locked** (password authentication disabled)

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

### Server Hardening

Automate server security hardening using industry best practices.

#### Quick Start

1. **Create your hardening configuration:**
   ```bash
   cp vars/hardening.local.yml.example vars/hardening.local.yml
   nano vars/hardening.local.yml
   ```

2. **Run the playbook:**
   ```bash
   ansible-playbook playbooks/server-hardening.yml
   ```

#### What It Does

The hardening playbook implements security best practices:

- **SSH Hardening:** Disables root login, password auth (keys only), configures timeouts
- **Firewall:** Configures UFW (Debian/Ubuntu) or firewalld (RHEL/CentOS)
- **Fail2ban:** Protects against brute force attacks
- **System Updates:** Updates packages and configures automatic security updates
- **Kernel Hardening:** Sets secure network kernel parameters
- **Service Management:** Disables unnecessary/insecure services
- **Time Sync:** Configures NTP/chrony for accurate time
- **File Permissions:** Sets restrictive permissions on sensitive files

#### Configuration

Edit `vars/hardening.local.yml` to customize:

```yaml
# SSH Hardening
hardening_ssh_permit_root_login: "no"
hardening_ssh_password_auth: "no"
hardening_ssh_port: 22  # Change to non-standard port for security

# Firewall
hardening_firewall_allowed_services:
  - OpenSSH

# Fail2ban
hardening_fail2ban_maxretry: 5
hardening_fail2ban_bantime: 3600
```

All options are enabled by default with secure settings. Disable any section by setting its option to `false`.

#### Security Features

- **SSH:** Root login disabled, password auth disabled, key-only access
- **Firewall:** Default deny incoming, allow outgoing
- **Fail2ban:** Automatic IP banning for failed login attempts
- **Kernel:** IP forwarding disabled, source routing disabled, SYN cookies enabled
- **Updates:** Automatic security updates enabled
- **Services:** Insecure services (telnet, rsh, etc.) disabled

---

*More projects coming soon...*
