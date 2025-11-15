# Local Configuration Guide

## Why Use Local Configuration?

When you sync the repository from GitHub, any changes you make to tracked files (like `vars/users.yml`) will be overwritten. To prevent this, we use a **local override file** that is not tracked in git.

## Setup

### 1. Create Local Override File

On your server, create the local configuration file:

```bash
cd ansible
cp vars/users.local.yml.example vars/users.local.yml
```

### 2. Edit Your Users

Edit `vars/users.local.yml` with your server-specific users:

```bash
nano vars/users.local.yml
```

## How It Works

The playbook loads variables in this order:
1. `vars/users.yml` - Base configuration (tracked in git)
2. `vars/users.local.yml` - Local overrides (NOT tracked in git) ← **Edit this one!**
3. `vault/passwords.yml` - Encrypted passwords

Variables in `users.local.yml` will **override** or **merge** with `users.yml`.

## Example

### Base file (`vars/users.yml` - don't edit on server):
```yaml
users_to_create: []
```

### Local file (`vars/users.local.yml` - edit this):
```yaml
users_to_create:
  - name: server_user
    groups: ['sudo']
    shell: /bin/bash
    comment: "Server-specific user"
    create_home: true
```

When you run the playbook, it will use the users from `users.local.yml`.

## Syncing from GitHub

When you sync:

```bash
git pull origin main
```

Your `vars/users.local.yml` file will **never** be touched because it's in `.gitignore`. Your configurations are safe!

## Multiple Servers

If you have multiple servers, each server can have its own `vars/users.local.yml` with server-specific users. The base `vars/users.yml` remains the same for all servers.

## Best Practices

1. ✅ **Always edit `vars/users.local.yml`** on the server (not `vars/users.yml`)
2. ✅ Keep `vars/users.yml` as a template/example only
3. ✅ Use `vars/users.local.yml` for all server-specific configurations
4. ✅ The local file is automatically ignored by git
5. ✅ Sync from GitHub anytime without losing your configurations

## File Structure

```
vars/
├── users.yml              # Base config (tracked in git) - DON'T EDIT ON SERVER
├── users.local.yml        # Local overrides (NOT tracked) - EDIT THIS!
└── users.local.yml.example  # Example template
```

## Troubleshooting

### "File not found" error

If the playbook complains about missing `users.local.yml`, you can create an empty one:

```bash
touch vars/users.local.yml
```

Or copy the example:

```bash
cp vars/users.local.yml.example vars/users.local.yml
```

### Variables not working

Make sure you're editing `vars/users.local.yml` (not `vars/users.yml`). The playbook will automatically load both files.

