# Server Setup and Sync Guide

This guide explains how to download and keep the Ansible repository in sync on your server.

## Initial Setup

### 1. Clone the Repository

```bash
# Clone using HTTPS
git clone https://github.com/X1Aaron/ansible.git
cd ansible

# Or clone using SSH (if you have SSH keys configured)
git clone git@github.com:X1Aaron/ansible.git
cd ansible
```

### 2. Set Up Local User Configuration

**IMPORTANT:** To prevent your user configurations from being overwritten when syncing, use the local override file:

```bash
# Create local override file (not tracked in git)
cp vars/users.local.yml.example vars/users.local.yml

# Edit with your server-specific users
nano vars/users.local.yml
```

This file (`vars/users.local.yml`) is in `.gitignore` and will **never** be overwritten when you sync from GitHub. Edit this file instead of `vars/users.yml`.

### 3. Verify Installation

```bash
# Check Ansible is installed
ansible --version

# Test connection to localhost
ansible localhost -m ping
```

## Keeping Repository in Sync

### Method 1: Manual Sync

Simply pull updates when needed:

```bash
cd /path/to/ansible
git pull origin main
```

### Method 2: Automated Sync with Cron

#### Step 1: Create Sync Script

Create a sync script (or use the provided `sync-repo.sh`):

```bash
#!/bin/bash
REPO_DIR="/path/to/ansible"
cd "$REPO_DIR"
git fetch origin
git pull origin main
```

Make it executable:
```bash
chmod +x sync-repo.sh
```

#### Step 2: Set Up Cron Job

Edit crontab:
```bash
crontab -e
```

Add a line to sync every hour (or adjust frequency as needed):
```bash
0 * * * * /path/to/sync-repo.sh >> /var/log/ansible-sync.log 2>&1
```

Or sync daily at 2 AM:
```bash
0 2 * * * /path/to/sync-repo.sh >> /var/log/ansible-sync.log 2>&1
```

### Method 3: Git Hooks (Advanced)

Set up a post-receive hook on the server to automatically pull when you push to GitHub (requires additional setup).

## Workflow Best Practices

### Recommended Workflow

1. **On your local machine:**
   - Make changes to playbooks/vars
   - Test locally
   - Commit and push to GitHub:
     ```bash
     git add .
     git commit -m "Update user configurations"
     git push
     ```

2. **On the server:**
   - Pull the latest changes:
     ```bash
     cd /path/to/ansible
     git pull origin main
     ```
   - Run your playbooks:
     ```bash
     ansible-playbook playbooks/user-management.yml -e "user_action=create"
     ```

### Using Git Tags for Version Control

Tag stable versions for production use:

```bash
# On your local machine after testing
git tag -a v1.0.0 -m "Stable release v1.0.0"
git push origin v1.0.0
```

On the server, checkout specific versions:
```bash
git fetch --tags
git checkout v1.0.0
```

## Troubleshooting

### Permission Issues

If you encounter permission issues when pulling:
```bash
# Ensure you own the directory
sudo chown -R $USER:$USER /path/to/ansible
```

### Merge Conflicts

If you've made local changes on the server and there are conflicts:
```bash
# Stash local changes
git stash

# Pull updates
git pull origin main

# Reapply local changes (if needed)
git stash pop
```

### Check Repository Status

```bash
cd /path/to/ansible
git status
git log --oneline -5  # See last 5 commits
```

## Security Considerations

1. **Use SSH Keys** instead of HTTPS passwords for better security
2. **Protect sensitive data** using Ansible Vault (never commit plaintext passwords)
3. **Use private repositories** if managing sensitive infrastructure
4. **Restrict access** to the repository directory on the server

## Quick Reference

```bash
# Initial clone
git clone https://github.com/X1Aaron/ansible.git

# Update repository
cd ansible && git pull origin main

# Check for updates without pulling
git fetch origin
git status

# View commit history
git log --oneline

# Reset to match remote (discard local changes)
git fetch origin
git reset --hard origin/main
```

