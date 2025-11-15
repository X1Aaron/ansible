# SSH Key Management Guide

This guide explains how to add SSH public keys to users for easy authentication.

## Overview

Instead of generating new SSH keys on the server, you can add your existing public SSH key to users. This allows you to authenticate using your own SSH key.

## Getting Your Public SSH Key

### On Your Local Machine

**Linux/macOS:**
```bash
# For RSA key
cat ~/.ssh/id_rsa.pub

# For ED25519 key (recommended)
cat ~/.ssh/id_ed25519.pub

# List all public keys
ls -la ~/.ssh/*.pub
```

**Windows (PowerShell):**
```powershell
# For RSA key
Get-Content ~/.ssh/id_rsa.pub

# For ED25519 key
Get-Content ~/.ssh/id_ed25519.pub
```

**Windows (Git Bash/WSL):**
```bash
cat ~/.ssh/id_rsa.pub
```

## Adding SSH Keys to Users

### In `vars/users.local.yml`

```yaml
users_to_create:
  - name: my_user
    groups: ['sudo']
    shell: /bin/bash
    comment: "My user"
    create_home: true
    ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-full-public-key-here"
```

### Complete Example

```yaml
---
users_to_create:
  - name: alice
    groups: ['sudo']
    shell: /bin/bash
    comment: "Alice - Developer"
    create_home: true
    ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDhA... alice@laptop"
    
  - name: bob
    groups: ['docker']
    shell: /bin/bash
    comment: "Bob - DevOps"
    create_home: true
    ssh_public_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... bob@workstation"
```

## Key Options

### `ssh_public_key`
- **Required:** Your full public SSH key (starts with `ssh-rsa`, `ssh-ed25519`, etc.)
- **Example:** `"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... user@host"`

### `ssh_keys_exclusive` (optional)
- **Default:** `false` - Adds key to existing authorized_keys
- **If `true`:** Replaces all existing keys (removes old keys)
- **Use case:** When you want to ensure only your key is present

```yaml
users_to_create:
  - name: my_user
    ssh_public_key: "ssh-rsa AAAAB3..."
    ssh_keys_exclusive: true  # Removes all other keys
```

## Adding Keys to Existing Users

You can also add SSH keys when modifying existing users:

```yaml
users_to_modify:
  - name: existing_user
    groups: ['sudo']
    ssh_public_key: "ssh-rsa AAAAB3..."
```

## Multiple Keys

To add multiple keys, you can run the playbook multiple times or use the `modify` action:

```yaml
# First key
users_to_create:
  - name: my_user
    ssh_public_key: "ssh-rsa AAAAB3... key1"

# Later, add another key
users_to_modify:
  - name: my_user
    ssh_public_key: "ssh-ed25519 AAAAC3... key2"
```

**Note:** By default, keys are added (not replaced), so both keys will be present.

## Security Best Practices

1. ✅ **Use your own SSH key** - Don't generate keys on the server
2. ✅ **Use ED25519 keys** - More secure than RSA
3. ✅ **Keep private keys secure** - Never share or commit private keys
4. ✅ **Use `ssh_keys_exclusive: true`** - If you want to ensure only your key is present
5. ✅ **Test authentication** - After adding keys, test SSH login

## Testing SSH Access

After running the playbook, test SSH access:

```bash
# From your local machine
ssh my_user@server-ip

# Or with specific key
ssh -i ~/.ssh/id_rsa my_user@server-ip
```

## Troubleshooting

### Key not working

1. **Verify key format:**
   - Must start with `ssh-rsa`, `ssh-ed25519`, `ecdsa-sha2-nistp256`, etc.
   - Must be the full key (usually one line)
   - Must include the key type, key data, and comment

2. **Check authorized_keys file:**
   ```bash
   # On server
   sudo cat /home/my_user/.ssh/authorized_keys
   ```

3. **Check permissions:**
   ```bash
   # On server
   sudo chmod 700 /home/my_user/.ssh
   sudo chmod 600 /home/my_user/.ssh/authorized_keys
   sudo chown -R my_user:my_user /home/my_user/.ssh
   ```

### Key already exists

If you get an error about the key already existing, you can:
- Use `ssh_keys_exclusive: true` to replace all keys
- Or manually remove the key and re-run

### Formatting Issues

Make sure the key is on a single line in YAML:

```yaml
# ✅ Correct
ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... full-key-here"

# ❌ Wrong (multi-line without quotes)
ssh_public_key: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC...
```

## Example: Complete User Setup

```yaml
---
users_to_create:
  - name: developer
    groups: ['sudo', 'docker']
    shell: /bin/bash
    comment: "Developer Account"
    create_home: true
    ssh_public_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGexample123... developer@laptop"
    # Password from vault (optional)
    # password: "{{ user_passwords['developer'] | default(omit) }}"
```

Run the playbook:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

Then SSH in:
```bash
ssh developer@your-server
```

## Summary

- ✅ Use `ssh_public_key` to add your existing public key
- ✅ Don't use `generate_ssh_key` (creates keys you can't access)
- ✅ Get your public key with `cat ~/.ssh/id_ed25519.pub`
- ✅ Keys are added to `~/.ssh/authorized_keys` automatically
- ✅ Test SSH access after adding keys

