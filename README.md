# Ansible User Management Automation

This Ansible project provides automation for managing users on a local server. All operations run against localhost.

## Project Structure

```
.
├── ansible.cfg              # Ansible configuration
├── inventory/
│   └── hosts.yml           # Localhost inventory
├── playbooks/
│   └── user-management.yml # Main playbook
├── roles/
│   └── user_management/
│       └── tasks/
│           └── main.yml    # User management tasks
├── vars/
│   └── users.yml           # User definitions
├── docs/
│   └── SERVER_SETUP.md     # Server setup and sync guide
├── sync-repo.sh            # Script to sync repository on server
└── README.md
```

## Server Setup and Sync

To download and keep this repository in sync on your server:

**Initial Setup:**
```bash
git clone https://github.com/X1Aaron/ansible.git
cd ansible
```

**Keep in Sync:**
```bash
cd ansible
git pull origin main
```

For detailed instructions on automated syncing, cron jobs, and best practices, see [docs/SERVER_SETUP.md](docs/SERVER_SETUP.md).

## Prerequisites

- Ansible installed on your system
- Sudo/root access for user management operations
- Python installed (for Ansible modules)

### Installing Ansible

**On Windows (WSL or Linux subsystem):**
```bash
sudo apt update
sudo apt install ansible
```

**On Linux:**
```bash
sudo apt install ansible  # Debian/Ubuntu
sudo yum install ansible   # RHEL/CentOS
```

**On macOS:**
```bash
brew install ansible
```

## Usage

### 1. Create Users

Edit `vars/users.yml` and define users under `users_to_create`:

```yaml
users_to_create:
  - name: john_doe
    groups: ['sudo', 'docker']
    shell: /bin/bash
    comment: "John Doe - Developer"
    create_home: true
    generate_ssh_key: true
    ssh_key_type: rsa
    ssh_key_bits: 2048
```

Run the playbook:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

### 2. Modify Users

Edit `vars/users.yml` and define modifications under `users_to_modify`:

```yaml
users_to_modify:
  - name: john_doe
    groups: ['sudo', 'www-data']
    append: true
    shell: /bin/zsh
```

Run the playbook:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=modify"
```

### 3. Delete Users

Edit `vars/users.yml` and list users under `users_to_delete`:

```yaml
users_to_delete:
  - old_user1
  - old_user2
```

Run the playbook:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=delete"
```

To also remove home directories:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=delete" -e "remove_home=true"
```

### 4. List All Users

List all users on the system:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=list"
```

## User Configuration Options

### Available Fields for User Creation/Modification

- `name`: Username (required)
- `groups`: List of groups the user should belong to
- `append`: Add groups to existing groups (default: true)
- `shell`: Login shell (default: /bin/bash)
- `home`: Home directory path
- `create_home`: Create home directory (default: true)
- `comment`: User description/comment
- `password`: Encrypted password (use ansible-vault for security)
- `password_lock`: Lock the password (default: false)
- `system`: Create as system user (default: false)
- `uid`: Specific UID for the user
- `generate_ssh_key`: Generate SSH key for user (default: false)
- `ssh_key_type`: SSH key type (default: rsa)
- `ssh_key_bits`: SSH key bits (default: 2048)

## Security Best Practices

### Password Management

**Never store plaintext passwords in your playbooks!** Use Ansible Vault:

1. Create an encrypted password:
```bash
ansible-vault encrypt_string 'your_password' --name 'vaulted_password'
```

2. Add the encrypted string to `vars/users.yml`:
```yaml
users_to_create:
  - name: john_doe
    password: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      663864396539663161326462636239653...
```

3. Run playbooks with vault password:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=create" --ask-vault-pass
```

Or use a vault password file:
```bash
ansible-playbook playbooks/user-management.yml -e "user_action=create" --vault-password-file ~/.vault_pass
```

## Examples

### Example 1: Create a developer user with sudo access
```yaml
users_to_create:
  - name: developer
    groups: ['sudo']
    shell: /bin/bash
    comment: "Development User"
    create_home: true
    generate_ssh_key: true
```

### Example 2: Add user to additional groups
```yaml
users_to_modify:
  - name: developer
    groups: ['docker', 'www-data']
    append: true
```

### Example 3: Create multiple users at once
```yaml
users_to_create:
  - name: alice
    groups: ['sudo']
    comment: "Alice Smith"
  - name: bob
    groups: ['docker']
    comment: "Bob Johnson"
  - name: charlie
    groups: ['www-data']
    comment: "Charlie Brown"
```

## Troubleshooting

### Permission Denied
Ensure you have sudo access:
```bash
sudo ansible-playbook playbooks/user-management.yml -e "user_action=create"
```

### Connection Issues
Verify localhost connection:
```bash
ansible localhost -m ping
```

### Check Ansible Version
```bash
ansible --version
```

## Additional Notes

- All operations require root/sudo privileges
- The playbook uses `become: yes` to escalate privileges
- User operations are idempotent (safe to run multiple times)
- The `list` action is read-only and doesn't require any user definitions

