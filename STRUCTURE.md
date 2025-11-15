# Project Structure - Code vs Variables

## The Two Parts

### 1. CODE (Synced to GitHub) ✅

All the code that creates users is in git and syncs to GitHub:

- `playbooks/user-management.yml` - The playbook that runs
- `roles/user_management/tasks/main.yml` - The code that creates users
- `ansible.cfg` - Configuration
- `inventory/hosts.yml` - Server inventory
- All other code files

**These files sync to GitHub and get updated when you run `git pull`.**

### 2. VARIABLES (Stays on Server) 🔒

All your custom user data goes in ONE file that does NOT sync:

- `vars/users.local.yml` - **This is your variables file**

**This file:**
- ✅ Contains ALL your users, passwords, SSH keys, groups, etc.
- ✅ Is in `.gitignore` - will NEVER sync to GitHub
- ✅ Stays on your server only
- ✅ Is the ONLY file you need to edit for your users

## How It Works

```
┌─────────────────────────────────────────┐
│ CODE (in git, syncs to GitHub)         │
│                                         │
│  playbooks/user-management.yml         │
│  roles/user_management/tasks/main.yml  │
│  ansible.cfg                            │
│  inventory/hosts.yml                    │
│  (all the code)                         │
└─────────────────────────────────────────┘
              │
              │ Uses variables from
              ▼
┌─────────────────────────────────────────┐
│ VARIABLES (NOT in git, stays on server)│
│                                         │
│  vars/users.local.yml  ←─── YOUR FILE  │
│  (all your users, passwords, etc.)     │
└─────────────────────────────────────────┘
```

## The Flow

1. **You edit:** `vars/users.local.yml` (your variables)
2. **Playbook loads:** `vars/users.local.yml` (reads your variables)
3. **Role uses:** Variables to create users
4. **You sync:** `git pull` updates code, but your variables file stays untouched

## Example

**Your variables file (`vars/users.local.yml`):**
```yaml
users_to_create:
  - name: alice
    groups: ['sudo']
    password: "$6$hash..."
    ssh_public_key: "ssh-rsa AAAAB3..."
  
  - name: bob
    groups: ['docker']
    password: "$6$hash..."
    ssh_public_key: "ssh-ed25519 AAAAC3..."
```

**The code (in git) automatically:**
- Reads these variables
- Creates the users
- Sets passwords
- Adds SSH keys
- Everything!

## Summary

- **Code** = In git, syncs to GitHub (playbooks, roles, config)
- **Variables** = One file (`vars/users.local.yml`), NOT in git, stays on server
- **You edit** = Only the variables file
- **Everything else** = Just syncs from GitHub

