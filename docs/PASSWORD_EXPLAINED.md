# Password Management Explained

This guide explains exactly how passwords work with Ansible Vault in this project.

## The Big Picture

Here's how passwords flow through the system:

```
1. You create a password hash (encrypted version of your password)
   ↓
2. Store the hash in vault/passwords.yml (encrypted file)
   ↓
3. Define users in vars/users.local.yml (without password field)
   ↓
4. Playbook automatically looks up password from vault using username
   ↓
5. User is created with the password from vault
```

## Important: Passwords Must Be Hashed

**You cannot store plaintext passwords!** Linux requires passwords in a special encrypted format called a "hash". 

- ❌ **Plaintext:** `mypassword123`
- ✅ **Hash:** `$6$rounds=656000$salt$hashed_password_string`

## Step-by-Step: Complete Password Setup

### Step 1: Generate a Password Hash

You need to convert your plaintext password into a hash that Linux can use.

**On your server (or any Linux machine):**

```bash
# Generate hash for your password
python3 -c "import crypt; print(crypt.crypt('mypassword123', crypt.mksalt(crypt.METHOD_SHA512)))"
```

**Output example:**
```
$6$rounds=656000$abc123def456$xyz789...verylonghashstring
```

**Or use the helper script:**
```bash
./scripts/generate-password-hash.sh
# Enter your password when prompted
```

### Step 2: Add Hash to Vault

Edit the encrypted vault file:

```bash
ansible-vault edit vault/passwords.yml --vault-password-file .vault_pass
```

**Add your password hash:**
```yaml
---
user_passwords:
  my_user: "$6$rounds=656000$abc123def456$xyz789...verylonghashstring"
  another_user: "$6$rounds=656000$def456ghi789$abc123...anotherhash"
```

**Save and exit** - the file is automatically re-encrypted.

### Step 3: Define Users (Without Password Field)

In `vars/users.local.yml`, define your users **without** specifying a password:

```yaml
---
users_to_create:
  - name: my_user
    groups: ['sudo']
    shell: /bin/bash
    comment: "My user"
    create_home: true
    # NO password field here - it will be looked up automatically!
```

### Step 4: How It Works Automatically

When you run the playbook:

```bash
ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

**What happens behind the scenes:**

1. Playbook loads `vault/passwords.yml` (automatically decrypted)
2. For each user in `users_to_create`:
   - Checks: Does `item.password` exist? → No
   - Checks: Does `user_passwords['my_user']` exist in vault? → Yes!
   - Uses: `$6$rounds=656000$abc123def456$xyz789...`
3. User is created with that password hash

**The magic line in the code:**
```yaml
password: "{{ item.password | default(user_passwords[item.name] | default(omit)) }}"
```

This means:
- Use `item.password` if explicitly set
- Otherwise, use `user_passwords[username]` from vault
- Otherwise, omit (no password)

## Three Ways to Set Passwords

### Method 1: Automatic Lookup (Recommended) ✅

**Vault file:**
```yaml
user_passwords:
  my_user: "$6$rounds=656000$..."
```

**User definition:**
```yaml
users_to_create:
  - name: my_user
    groups: ['sudo']
    # Password automatically found from vault!
```

### Method 2: Explicit Reference

**Vault file:**
```yaml
user_passwords:
  my_user: "$6$rounds=656000$..."
```

**User definition:**
```yaml
users_to_create:
  - name: my_user
    groups: ['sudo']
    password: "{{ user_passwords['my_user'] }}"
    # Explicitly references vault
```

### Method 3: Direct Hash (Not Recommended)

**User definition:**
```yaml
users_to_create:
  - name: my_user
    groups: ['sudo']
    password: "$6$rounds=656000$abc123def456$xyz789..."
    # Hash directly in user file (not encrypted!)
```

**⚠️ Warning:** This stores the hash in plaintext (not encrypted). Use vault instead!

## Complete Example

### 1. Generate Password Hash

```bash
python3 -c "import crypt; print(crypt.crypt('SecurePass123!', crypt.mksalt(crypt.METHOD_SHA512)))"
```

**Output:**
```
$6$rounds=656000$8K1vP9mN2xQ3wR4t$Y7zA8bC9dE0fG1hI2jK3lM4nO5pP6qR7sS8tT9uU0vV1wW2xX3yY4zZ5aA6bB7cC8dD9eE0fF
```

### 2. Add to Vault

```bash
ansible-vault edit vault/passwords.yml --vault-password-file .vault_pass
```

**Add:**
```yaml
---
user_passwords:
  developer: "$6$rounds=656000$8K1vP9mN2xQ3wR4t$Y7zA8bC9dE0fG1hI2jK3lM4nO5pP6qR7sS8tT9uU0vV1wW2xX3yY4zZ5aA6bB7cC8dD9eE0fF"
```

### 3. Define User

**In `vars/users.local.yml`:**
```yaml
---
users_to_create:
  - name: developer
    groups: ['sudo']
    shell: /bin/bash
    comment: "Developer Account"
    create_home: true
    ssh_public_key: "ssh-rsa AAAAB3... developer@laptop"
    # Password automatically looked up from vault!
```

### 4. Run Playbook

```bash
ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

### 5. Test Login

```bash
# SSH with password
ssh developer@server
# Enter: SecurePass123!

# Or use SSH key (no password needed)
ssh developer@server
```

## Common Questions

### Q: Do I need to specify password in users.local.yml?

**A:** No! If the username matches a key in `user_passwords`, it's automatic.

```yaml
# Vault has: user_passwords: { my_user: "$6$..." }
# User file has: - name: my_user
# → Password automatically used!
```

### Q: What if username doesn't match vault key?

**A:** User is created without a password (password locked or no password set).

```yaml
# Vault has: user_passwords: { alice: "$6$..." }
# User file has: - name: bob
# → Bob created with NO password (can't login with password)
```

### Q: Can I override the vault password?

**A:** Yes, explicitly set `password` in the user definition:

```yaml
users_to_create:
  - name: my_user
    password: "$6$different_hash..."
    # This overrides vault
```

### Q: What if I don't want a password at all?

**A:** Don't add it to vault, and don't set `password` field. User will be created without password (or password locked).

```yaml
users_to_create:
  - name: my_user
    password_lock: true  # Lock password (SSH key only)
```

### Q: How do I change a user's password later?

**A:** Two options:

**Option 1: Update vault and modify user**
```yaml
# 1. Generate new hash
# 2. Update vault/passwords.yml
# 3. In users.local.yml:
users_to_modify:
  - name: my_user
    # Password automatically updated from vault
```

**Option 2: Set directly**
```yaml
users_to_modify:
  - name: my_user
    password: "$6$new_hash..."
```

## Visual Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│ Step 1: Generate Hash                                    │
│ python3 -c "import crypt; ..."                          │
│ Output: $6$rounds=656000$salt$hash                        │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ Step 2: Store in Vault                                   │
│ vault/passwords.yml (encrypted):                        │
│   user_passwords:                                        │
│     my_user: "$6$rounds=656000$salt$hash"               │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ Step 3: Define User (no password field)                │
│ vars/users.local.yml:                                   │
│   users_to_create:                                       │
│     - name: my_user                                      │
│       groups: ['sudo']                                  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ Step 4: Playbook Runs                                    │
│ 1. Loads vault/passwords.yml                            │
│ 2. For user "my_user":                                   │
│    - Looks up: user_passwords['my_user']                │
│    - Finds: "$6$rounds=656000$salt$hash"               │
│    - Creates user with that password                    │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ Step 5: User Created!                                    │
│ User "my_user" can login with the password you hashed   │
└─────────────────────────────────────────────────────────┘
```

## Summary

1. **Generate hash** from your plaintext password
2. **Store hash** in `vault/passwords.yml` with username as key
3. **Define user** in `vars/users.local.yml` with matching username
4. **Run playbook** - password automatically looked up and applied
5. **Login** with your original plaintext password

The key insight: **The username in your user definition must match the key in `user_passwords` for automatic lookup to work!**

