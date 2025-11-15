# How to Know Which Files to Edit

## Quick Rule

**File ending in `.example`** = Template (DO NOT EDIT - will be overwritten)  
**File ending in `.local.yml`** = Your actual config (SAFE TO EDIT - git-ignored)

## File Types

### Template Files (DO NOT EDIT)
These are in git and will be overwritten when you sync:
- `vars/users.local.yml.example` ❌ Don't edit
- `vars/hardening.local.yml.example` ❌ Don't edit
- `vars/proxmox.local.yml.example` ❌ Don't edit
- `vars/secrets.local.yml.example` ❌ Don't edit

### Your Config Files (SAFE TO EDIT)
These are git-ignored and will NOT be overwritten:
- `vars/users.local.yml` ✅ Edit this
- `vars/hardening.local.yml` ✅ Edit this
- `vars/proxmox.local.yml` ✅ Edit this
- `vars/secrets.local.yml` ✅ Edit this

## How to Check

**Quick check:**
```bash
# See which files are git-ignored (your actual config files)
git check-ignore vars/*.local.yml

# See which files are in git (template files)
git ls-files vars/*.example
```

**Visual check:**
- Template files have `⚠️ TEMPLATE FILE - DO NOT EDIT` at the top
- Your config files don't have this warning (they're safe to edit)

## Workflow

1. **First time setup:** Copy template to create your config
   ```bash
   cp vars/users.local.yml.example vars/users.local.yml
   ```

2. **Edit your config:** Always edit the `.local.yml` file (without `.example`)
   ```bash
   nano vars/users.local.yml  # ✅ Safe to edit
   ```

3. **Never edit templates:** Don't edit `.example` files
   ```bash
   nano vars/users.local.yml.example  # ❌ Will be overwritten!
   ```

## Summary

- **`.example`** = Template in git → Don't edit
- **`.local.yml`** = Your config, git-ignored → Safe to edit

