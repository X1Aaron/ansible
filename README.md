# Ansible Automation Repository

This repository contains Ansible automation playbooks for server management tasks.

## Projects

### User Management
Automate user account management on local servers.

**Quick Start:**
```bash
# On your server
git clone https://github.com/X1Aaron/ansible.git
cd ansible
cp vars/users.local.yml.example vars/users.local.yml
nano vars/users.local.yml  # Add your users
ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

**Documentation:** See [USER_MANAGEMENT.md](USER_MANAGEMENT.md)

---

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

## Project Documentation

- [User Management](USER_MANAGEMENT.md) - User account automation

---

*More projects coming soon...*
