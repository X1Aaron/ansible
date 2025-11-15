# Quick Start: Adding Users

## Step-by-Step Guide

### On Your Server:

1. **Create the local config file (first time only):**
   ```bash
   cd ansible
   cp vars/users.local.yml.example vars/users.local.yml
   ```

2. **Edit the file:**
   ```bash
   nano vars/users.local.yml
   ```

3. **Add your users** - Here's a complete example:

   ```yaml
   ---
   users_to_create:
     - name: john_doe
       groups: ['sudo']
       shell: /bin/bash
       comment: "John Doe - Developer"
       create_home: true
       generate_ssh_key: true
       ssh_key_type: rsa
       ssh_key_bits: 2048
   ```

4. **Run the playbook:**
   ```bash
   ansible-playbook playbooks/user-management.yml -e "user_action=create"
   ```

## Which File Do I Edit?

**✅ EDIT THIS:** `vars/users.local.yml` (on your server)
- This file is NOT in git
- It won't be overwritten when you sync
- Create it by copying the example: `cp vars/users.local.yml.example vars/users.local.yml`

**❌ DON'T EDIT THIS:** `vars/users.yml`
- This file IS in git
- It will be overwritten when you sync
- Only use it as a reference/template

## Complete Example File

Here's what a complete `vars/users.local.yml` looks like:

```yaml
---
users_to_create:
  - name: alice
    groups: ['sudo', 'docker']
    shell: /bin/bash
    comment: "Alice - DevOps Engineer"
    create_home: true
    generate_ssh_key: true

  - name: bob
    groups: ['www-data']
    shell: /bin/bash
    comment: "Bob - Web Developer"
    create_home: true

users_to_modify:
  - name: existing_user
    groups: ['sudo']
    append: true

users_to_delete:
  - old_user
```

## That's It!

Just edit `vars/users.local.yml` on your server and run the playbook. Your changes will never be lost when syncing from GitHub.

