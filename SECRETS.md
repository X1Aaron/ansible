# Storing Secrets Securely

This repository uses a **git-ignored** file to store sensitive information like passwords.

## Location

**File:** `vars/secrets.local.yml`

This file is:
- ✅ **NOT tracked in git** (in `.gitignore`)
- ✅ **Never overwritten** by `git pull`
- ✅ **Stays on your server only**

## Setup

1. **Create the secrets file:**
   ```bash
   cp vars/secrets.local.yml.example vars/secrets.local.yml
   chmod 600 vars/secrets.local.yml  # Restrict permissions
   ```

2. **Edit with your secrets:**
   ```bash
   nano vars/secrets.local.yml
   ```

3. **Add your root password:**
   ```yaml
   root_password: "your-secure-password-here"
   ```

## Security Best Practices

1. **Restrict file permissions:**
   ```bash
   chmod 600 vars/secrets.local.yml
   ```
   This ensures only you (the owner) can read/write the file.

2. **Never commit this file:**
   - It's already in `.gitignore`
   - Double-check before committing: `git status` should NOT show this file

3. **Use password hashes when possible:**
   ```bash
   # Generate a password hash
   python3 -c "import crypt; print(crypt.crypt('password', crypt.mksalt(crypt.METHOD_SHA512)))"
   ```
   Then store the hash instead of plain text.

4. **Backup separately:**
   - Don't rely on git for backups of secrets
   - Use secure password managers or encrypted storage

## Using Secrets in Playbooks

To use secrets in a playbook, include the file:

```yaml
- name: My Playbook
  hosts: localhost
  become: yes
  vars_files:
    - ../vars/secrets.local.yml
  
  tasks:
    - name: Use root password
      debug:
        msg: "Root password is set (but not displayed)"
      # Use {{ root_password }} in your tasks
```

## What to Store Here

- Root password
- Database passwords
- API keys
- Any other sensitive credentials

## What NOT to Store

- User passwords (use `vars/users.local.yml` with password hashes)
- SSH keys (use `vars/users.local.yml` with `ssh_public_key`)
- Public configuration (use regular `.local.yml` files)

## Verification

To verify the file is git-ignored:

```bash
git status
# vars/secrets.local.yml should NOT appear

git check-ignore vars/secrets.local.yml
# Should output: vars/secrets.local.yml
```

