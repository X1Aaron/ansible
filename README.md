# Ansible Automation Repository

This repository contains Ansible automation playbooks for server management tasks.

## Repository Structure

```
.
├── playbooks/          # Ansible playbooks
├── roles/              # Reusable Ansible roles
├── vars/               # Variable files
│   └── *.local.yml    # Local variables (not in git)
├── inventory/          # Server inventories
├── scripts/            # Helper scripts
└── README.md           # This file
```

## How It Works

**Code vs Variables:**
- **Code** (playbooks, roles, config) → In git, syncs to GitHub
- **Variables** (`*.local.yml` files) → Not in git, stay on server

Edit `*.local.yml` files with your server-specific data. These files are in `.gitignore` and will never sync to GitHub.

## Prerequisites

- Ansible installed
- Sudo/root access
- Python installed

**Install Ansible:**
```bash
# Linux
sudo apt install ansible  # Debian/Ubuntu
sudo yum install ansible   # RHEL/CentOS

# macOS
brew install ansible
```

## Server Setup

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

Your `*.local.yml` files will never be overwritten (they're in `.gitignore`).

---

## Projects

### User Management

Automate user account creation, modification, and deletion on local servers.

#### How It Works

**Declarative Approach:** The variables file is the source of truth.
- Users in the file → Created or updated to match
- Users removed from file → Deleted (if `remove_orphaned_users` is enabled)
- No need to specify create/modify/delete actions

#### Quick Start

1. **Create your variables file:**
   ```bash
   cp vars/users.local.yml.example vars/users.local.yml
   nano vars/users.local.yml
   ```

2. **Add your users:**
   ```yaml
   users:
     - name: my_user
       groups: ['sudo']
       shell: /bin/bash
       ssh_public_key: "ssh-rsa AAAAB3... your-key"
   ```

3. **Run the playbook:**
   ```bash
   ansible-playbook playbooks/user-management.yml
   ```

That's it! The playbook ensures users match your variables file.

#### Usage

Just run the playbook - it automatically:
- Creates users that don't exist
- Updates users that exist but don't match
- Deletes users not in the file (if enabled)

```bash
ansible-playbook playbooks/user-management.yml
```

#### Configuration

Edit `vars/users.local.yml` with your users:

```yaml
users:
  - name: alice
    groups: ['sudo']
    shell: /bin/bash
    comment: "Alice - Developer"
    create_home: true
    ssh_public_key: "ssh-rsa AAAAB3... alice@laptop"
    # Optional: password hash
    # password: "$6$rounds=656000$salt$hash"

  - name: bob
    groups: ['docker']
    shell: /bin/bash
    comment: "Bob - DevOps"
    create_home: true
    ssh_public_key: "ssh-ed25519 AAAAC3... bob@workstation"

# Options
remove_orphaned_users: false  # Set to true to delete users not in 'users' list
remove_home_on_delete: false  # Remove home directory when deleting users
# Note: System users (UID < 1000) and root are ALWAYS protected from deletion
```

#### Options

- `name`: Username (required)
- `groups`: List of groups (e.g., `['sudo', 'docker']`)
- `ssh_public_key`: Your SSH public key (recommended)
- `sudo_passwordless`: Enable passwordless sudo (only if user is in 'sudo' group, recommended: `true` when using SSH keys)
- `password`: Password hash (optional - for console login, see below)
- `comment`: User description (optional)

#### Sudo Configuration

**Passwordless Sudo:** When a user is in the `sudo` group, you can enable passwordless sudo by setting `sudo_passwordless: true`. This is **secure** when combined with:
- SSH key-only authentication (no password login)
- Proper SSH key management
- Account password locked (default behavior)

**Security Considerations:**
- ✅ **Secure:** Passwordless sudo + SSH keys + locked password = Industry standard for servers
- ✅ **Recommended:** Most cloud providers and DevOps teams use this approach
- ⚠️ **Less Secure:** Passwordless sudo + password login = Not recommended
- ✅ **Best Practice:** Use SSH keys for authentication, passwordless sudo for convenience

**Example:**
```yaml
users:
  - name: admin
    groups: ['sudo']
    ssh_public_key: "ssh-rsa AAAAB3..."
    sudo_passwordless: true  # No password prompt for sudo
```

#### Passwords

**Security Note:** If you don't set a password, the account is **locked** and cannot be logged into with a password. This is secure - the account can only be accessed via SSH keys (if configured).

**SSH Keys vs Passwords:**
- SSH keys: No password needed for SSH access (recommended)
- Passwords: Optional, useful for console login or sudo (if not using passwordless sudo)
- **No password = Account locked** (password authentication disabled)

**Generate Password Hash:**
```bash
python3 -c "import crypt; print(crypt.crypt('yourpassword', crypt.mksalt(crypt.METHOD_SHA512)))"
```

Use the output (starts with `$6$`) in your user definition.

**Note:** `vars/users.local.yml` is in `.gitignore` and will NOT sync to GitHub, so your passwords stay on your server.

#### SSH Keys

**Get your public key:**
```bash
cat ~/.ssh/id_rsa.pub
# Or
cat ~/.ssh/id_ed25519.pub
```

**Add to user:**
```yaml
users:
  - name: my_user
    ssh_public_key: "ssh-rsa AAAAB3... your-full-key"
```

The key is automatically added to `~/.ssh/authorized_keys`.

#### Automatic `/opt/ansible` Access

All users are automatically granted access to `/opt/ansible`:
- Users are automatically added to the `ansible` group
- `/opt/ansible` is owned by `root:ansible` with `775` permissions (group writable)
- No configuration needed - it's automatic for all users!

---

### Server Hardening

Automate server security hardening using industry best practices.

#### ⚠️ IMPORTANT: Lockout Prevention Checklist

**Before running the hardening playbook, verify:**

1. ✅ **SSH Key Authentication Works:**
   ```bash
   # Test that you can SSH with your key (no password prompt)
   ssh -i ~/.ssh/your_key your_user@your_server
   ```

2. ✅ **You're NOT logging in as root:**
   - The playbook disables root SSH login by default
   - Make sure you have a regular user with sudo access
   - Run the user-management playbook first if needed

3. ✅ **Your user has SSH keys configured:**
   - Check: `cat ~/.ssh/authorized_keys` (should have your public key)
   - If not, add your key via the user-management playbook first

4. ✅ **Firewall won't block you:**
   - If changing SSH port, update firewall rules BEFORE running
   - Keep current SSH session open as backup

5. ✅ **You have console/out-of-band access:**
   - VPS: Use provider's web console
   - Physical: Have physical access
   - Cloud: Keep console access enabled

**If any of the above fail, DO NOT run the hardening playbook yet!**

#### Quick Start

1. **Create your hardening configuration:**
   ```bash
   cp vars/hardening.local.yml.example vars/hardening.local.yml
   nano vars/hardening.local.yml
   ```

2. **Review settings** - especially SSH and firewall configurations

3. **Run the playbook:**
   ```bash
   ansible-playbook playbooks/server-hardening.yml
   ```

4. **Keep your current SSH session open** until you verify you can reconnect

#### What It Does

The hardening playbook implements security best practices:

- **SSH Hardening:** Disables root login, password auth (keys only), configures timeouts
- **Firewall:** Configures UFW (Debian/Ubuntu) or firewalld (RHEL/CentOS)
- **Fail2ban:** Protects against brute force attacks
- **System Updates:** Updates packages and configures automatic security updates
- **Kernel Hardening:** Sets secure network kernel parameters
- **Service Management:** Disables unnecessary/insecure services
- **Time Sync:** Configures NTP/chrony for accurate time
- **File Permissions:** Sets restrictive permissions on sensitive files

#### Configuration

Edit `vars/hardening.local.yml` to customize:

```yaml
# SSH Hardening
hardening_ssh_permit_root_login: "no"
hardening_ssh_password_auth: "no"
hardening_ssh_port: 22  # Change to non-standard port for security

# Firewall
hardening_firewall_allowed_services:
  - OpenSSH

# Fail2ban
hardening_fail2ban_maxretry: 5
hardening_fail2ban_bantime: 3600
```

All options are enabled by default with secure settings. Disable any section by setting its option to `false`.

#### Security Features

- **SSH:** Root login disabled, password auth disabled, key-only access

---

### Proxmox VE Installation

Automate Proxmox VE installation on Debian-based systems.

#### ⚠️ IMPORTANT: Prerequisites

**Before running the Proxmox installation playbook:**

1. ✅ **Fresh Debian 11, 12, or 13 system:**
   - Proxmox VE requires a clean Debian installation
   - Debian 11 (Bullseye), Debian 12 (Bookworm), or Debian 13 (Trixie) supported
   - Do NOT run on a system with existing virtualization software

2. ✅ **Adequate hardware:**
   - Minimum 2GB RAM (4GB+ recommended)
   - 64-bit processor with virtualization support
   - Sufficient disk space

3. ✅ **Network access:**
   - Internet connection required for package downloads
   - Static IP recommended (can be configured during installation)

4. ✅ **Backup important data:**
   - Proxmox installation will modify system configuration
   - Backup any important data before proceeding

**This installation will modify your system significantly. Use on a fresh Debian installation or a system you're prepared to reconfigure.**

#### Quick Start

1. **Create your Proxmox configuration:**
   ```bash
   cp vars/proxmox.local.yml.example vars/proxmox.local.yml
   nano vars/proxmox.local.yml
   ```

2. **Review settings** - especially hostname and network configuration

3. **Run the playbook:**
   ```bash
   ansible-playbook playbooks/proxmox-install.yml
   ```

4. **Reboot if required** and access the web interface at `https://your-hostname:8006`

#### What It Does

The Proxmox installation playbook:
- Updates system packages
- Adds Proxmox VE repository
- Installs Proxmox VE packages
- Configures hostname (optional)
- Configures network (optional)
- Reboots if required

#### Configuration

Edit `vars/proxmox.local.yml` to customize:

```yaml
# Proxmox release version
proxmox_release: bookworm  # or 'bullseye' for Debian 11, 'trixie' for Debian 13

# Hostname
proxmox_hostname: pve1.example.com

# Network configuration (optional)
proxmox_network_config:
  - interface: enp0s3
    method: static
    address: 192.168.1.100
    netmask: 255.255.255.0
    gateway: 192.168.1.1
    dns_nameservers:
      - 8.8.8.8
      - 8.8.4.4
```

#### After Installation

1. **Access web interface:**
   - URL: `https://your-hostname:8006`
   - Login: `root` / your root password

2. **Configure storage:**
   - Add local storage or network storage (NFS, CIFS, etc.)

3. **Create VMs/containers:**
   - Upload ISO images
   - Create virtual machines or LXC containers

#### Security Features

- **Web Interface:** HTTPS on port 8006
- **SSH Access:** Standard SSH (consider running server-hardening playbook after installation)
- **Firewall:** Configure firewall rules for Proxmox ports (8006, 5900-5999 for VNC, etc.)

**Note:** After Proxmox installation, consider running the server-hardening playbook to secure SSH and configure firewall rules.

---

*More projects coming soon...*
