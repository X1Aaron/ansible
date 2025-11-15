# Simple User Management Guide

This is a simplified guide - no vault, just plain text variables.

## Quick Start

### 1. On Your Server

```bash
cd ansible
cp vars/users.local.yml.example vars/users.local.yml
nano vars/users.local.yml
```

### 2. Add Your Users

Edit `vars/users.local.yml`:

```yaml
---
users_to_create:
  - name: my_user
    groups: ['sudo']
    shell: /bin/bash
    comment: "My user"
    create_home: true
    # Your SSH public key (get it with: cat ~/.ssh/id_rsa.pub)
    ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-key"
    # Password hash (optional - see below)
    password: "$6$rounds=656000$salt$hashed_password"
```

### 3. Generate Password Hash (if needed)

**On your server:**
```bash
python3 -c "import crypt; print(crypt.crypt('yourpassword', crypt.mksalt(crypt.METHOD_SHA512)))"
```

Copy the output (starts with `$6$`) and paste it as the `password` value.

### 4. Run the Playbook

```bash
ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

## That's It!

- Edit `vars/users.local.yml` with your users
- This file is NOT in git, so it won't sync to GitHub
- Passwords are stored as hashes (required by Linux)
- Run the playbook when you want to create/modify/delete users

## Complete Example

```yaml
---
users_to_create:
  - name: alice
    groups: ['sudo']
    shell: /bin/bash
    comment: "Alice - Developer"
    create_home: true
    ssh_public_key: "ssh-rsa AAAAB3... alice@laptop"
    password: "$6$rounds=656000$abc123$xyz789..."

  - name: bob
    groups: ['docker']
    shell: /bin/bash
    comment: "Bob - DevOps"
    create_home: true
    ssh_public_key: "ssh-ed25519 AAAAC3... bob@workstation"
    # No password - SSH key only
```

## Notes

- **Password hashes only**: Linux requires passwords in hash format, not plain text
- **File is safe**: `vars/users.local.yml` is in `.gitignore` - won't sync to GitHub
- **SSH keys recommended**: Easier than passwords for login

