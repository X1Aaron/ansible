# How Everything Works - Explained Simply

## Part 1: Why Password Hashes?

### The Short Answer

**Linux doesn't store plain text passwords.** It stores encrypted versions called "hashes" for security. Ansible's `user` module requires the password in the same format Linux uses.

### The Longer Explanation

When you set a password on Linux, here's what happens:

1. **You type:** `mypassword123`
2. **Linux converts it to:** `$6$rounds=656000$salt$verylongencryptedstring`
3. **Linux stores:** Only the hash, never your actual password

This is why you can't just use plain text - Linux needs the hash format.

### Can Ansible Hash It For Me?

Unfortunately, Ansible's `user` module requires you to provide the password **already in hash format**. It doesn't automatically hash plain text passwords for security reasons.

### So What Do I Do?

You generate the hash yourself, then use it:

```bash
# Generate hash from your password
python3 -c "import crypt; print(crypt.crypt('mypassword123', crypt.mksalt(crypt.METHOD_SHA512)))"
# Output: $6$rounds=656000$abc123$xyz789...

# Use that hash in your user file
password: "$6$rounds=656000$abc123$xyz789..."
```

**Think of it like this:** You're giving Linux the "encrypted version" of your password, not the password itself.

---

## Part 2: The Two User Files Explained

### Why Two Files?

You have two files to solve this problem:
- **Problem:** You want to sync code updates from GitHub
- **Problem:** But you don't want your server-specific users to be overwritten

**Solution:** Two files!

### File 1: `vars/users.yml` (The Template)

- ✅ **Tracked in git** - This file syncs to GitHub
- ✅ **Safe to update** - You can push changes to GitHub
- ✅ **Template/Example** - Contains example users (all commented out)
- ❌ **Don't edit on server** - Will be overwritten when you sync

**Purpose:** This is the "base template" that everyone shares.

### File 2: `vars/users.local.yml` (Your Actual Users)

- ✅ **NOT tracked in git** - This file does NOT sync to GitHub
- ✅ **Safe to edit** - Never gets overwritten
- ✅ **Your real users** - Put your actual server users here
- ✅ **Stays on server** - Only exists on your server

**Purpose:** This is where you put your actual users that are specific to YOUR server.

### How They Work Together

The playbook loads **both files** in this order:

```
1. Load vars/users.yml (the template)
2. Load vars/users.local.yml (your users)
3. Merge them together (your file overrides the template)
```

**Example:**

**vars/users.yml (template):**
```yaml
users_to_create: []  # Empty - just a template
```

**vars/users.local.yml (your file):**
```yaml
users_to_create:
  - name: alice
    groups: ['sudo']
```

**Result:** The playbook uses Alice from your local file!

### Visual Diagram

```
┌─────────────────────────────────────────┐
│ GitHub Repository                       │
│                                         │
│  vars/users.yml  ←─── Syncs to/from    │
│  (template file)                       │
└─────────────────────────────────────────┘
              │
              │ git pull
              ▼
┌─────────────────────────────────────────┐
│ Your Server                              │
│                                         │
│  vars/users.yml  ←─── Gets updated      │
│  (template - don't edit)                │
│                                         │
│  vars/users.local.yml  ←─── YOUR FILE  │
│  (your users - edit this!)             │
│  (NOT in git - stays on server)        │
└─────────────────────────────────────────┘
```

### What Happens When You Sync?

**Scenario:** You run `git pull` to get updates from GitHub

1. ✅ `vars/users.yml` gets updated (if there were changes)
2. ✅ `vars/users.local.yml` stays exactly the same (not in git!)
3. ✅ Your users are safe!

### Real-World Example

**On GitHub:**
```yaml
# vars/users.yml
users_to_create: []  # Empty template
```

**On Your Server:**
```yaml
# vars/users.local.yml (NOT in git)
users_to_create:
  - name: alice
    groups: ['sudo']
  - name: bob
    groups: ['docker']
```

**You run:** `git pull`

**Result:**
- `vars/users.yml` might get updated (if there were changes)
- `vars/users.local.yml` is untouched
- Alice and Bob are still there!

**You run:** `ansible-playbook playbooks/user-management.yml -e "user_action=create"`

**Result:**
- Playbook loads both files
- Uses Alice and Bob from your local file
- Creates the users!

---

## Summary

### Password Hashes
- **Why:** Linux requires hashes, not plain text
- **What to do:** Generate hash with Python, then use it in your user file
- **Example:** `password: "$6$rounds=656000$salt$hash"`

### Two Files
- **vars/users.yml:** Template file (syncs to GitHub) - Don't edit on server
- **vars/users.local.yml:** Your actual users (stays on server) - Edit this one!
- **Why:** So you can sync updates without losing your users

### The Workflow
1. Edit `vars/users.local.yml` with your users
2. Sync from GitHub anytime (`git pull`) - your file is safe
3. Run playbook - it uses your local file

---

## Quick Reference

**Which file do I edit?**
→ `vars/users.local.yml` (on your server)

**Will it sync to GitHub?**
→ No! It's in `.gitignore`

**What about vars/users.yml?**
→ Don't edit it on the server - it's just a template

**How do I add a password?**
→ Generate hash, then add it to `vars/users.local.yml`

