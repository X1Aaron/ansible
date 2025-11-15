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

**Template Files vs Your Config:**
- **`.example` files** → In git, templates with commented examples (safe to sync)
- **`.local.yml` files** → Git-ignored, your actual config (stays on server)

**Configuration Files:**
- `vars/users.local.yml.example` - Template with commented examples
- `vars/hardening.local.yml.example` - Template with commented examples
- `vars/proxmox.local.yml.example` - Template with commented examples (optional)
- `vars/secrets.local.yml.example` - Template with commented examples

**How to Configure:**
1. **Manually copy the example file to create your config:**
   ```bash
   cp vars/users.local.yml.example vars/users.local.yml
   ```
   ⚠️ **Important:** You must manually copy the file - it won't be created automatically.

2. **Edit your `.local.yml` file:**
   ```bash
   nano vars/users.local.yml
   ```

3. **Uncomment and modify the examples:**
   - All examples are commented out with `#`
   - Find what you need, uncomment it, and modify the values
   - You can copy/paste examples and uncomment them

4. **That's it!** Your `.local.yml` file is git-ignored, so it won't be overwritten when you sync

**Updating Your Config When New Options Are Added:**
When the repository is updated with new options in `.example` files:
1. Check what's new: Compare your `.local.yml` with the updated `.example` file
2. Copy new options: Uncomment and add any new options you want from the `.example` file
3. Your existing config stays intact - nothing gets overwritten automatically

**Example:**
```yaml
# In vars/users.local.yml (copied from .example), you'll see:
users: []
# - name: my_user
#   groups: ['sudo']
#   ssh_public_key: "ssh-rsa AAAAB3..."

# Just uncomment and modify:
users:
  - name: alice
    groups: ['sudo']
    ssh_public_key: "ssh-rsa AAAAB3... alice@laptop"
```

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

## 🚀 Ansible Cheat Sheet - For Beginners

**Never used Ansible before? Start here!** This section explains everything you need to know to run playbooks.

### What is Ansible?

Ansible is a tool that automates server management. Instead of manually running commands on your server, you write "playbooks" (recipes) that Ansible follows to configure your system automatically.

### Basic Concepts

**Playbook** = A file with instructions (like a recipe)  
**Run a playbook** = Tell Ansible to follow those instructions  
**Task** = One step in the playbook (like "install a package" or "create a user")

### How to Run a Playbook (Step by Step)

#### Step 1: Navigate to the Repository

```bash
cd /opt/ansible
# or wherever you cloned the repository
```

#### Step 2: Run the Playbook

The basic command is always the same:

```bash
ansible-playbook playbooks/NAME-OF-PLAYBOOK.yml
```

**Example:** To run the user management playbook:
```bash
ansible-playbook playbooks/user-management.yml
```

#### Step 3: What Happens?

1. Ansible reads the playbook file
2. It checks what needs to be done
3. It makes the changes (creates users, installs packages, etc.)
4. It shows you what it did

### Understanding the Output

When you run a playbook, you'll see output like this:

```
TASK [Create user] ********************
changed: [localhost] => (item=aaron)
```

**What this means:**
- `TASK` = What Ansible is doing right now
- `changed` = Ansible made a change (created/updated something)
- `ok` = Everything is already correct, no change needed
- `skipping` = This step was skipped (usually because a condition wasn't met)

### Common Commands

**Run a playbook:**
```bash
ansible-playbook playbooks/user-management.yml
```

**Run a playbook and see what would change (dry run):**
```bash
ansible-playbook playbooks/user-management.yml --check
```
*Note: Not all playbooks support --check mode*

**Run a playbook with more details:**
```bash
ansible-playbook playbooks/user-management.yml -v
# -v = verbose (more details)
# -vv = very verbose (even more details)
# -vvv = maximum verbosity (all details)
```

**Run a playbook and ask for password:**
```bash
ansible-playbook playbooks/user-management.yml --ask-become-pass
```
*This will prompt you for your sudo password*

### Troubleshooting

**"Permission denied" error:**
- The playbook needs sudo/root access
- Make sure you're running with `sudo` or as root
- Or use `--ask-become-pass` to enter your password

**"File not found" error:**
- Make sure you're in the correct directory (`/opt/ansible` or wherever the repo is)
- Check that the playbook file exists: `ls playbooks/`

**"YAML parsing error":**
- There's a syntax error in your configuration file
- Run the validation playbook: `ansible-playbook playbooks/validate-yaml.yml`
- Fix the errors it reports

**"No such file or directory" for config file:**
- You need to create your `.local.yml` file first
- Copy from the example: `cp vars/users.local.yml.example vars/users.local.yml`
- Then edit it: `nano vars/users.local.yml`

### Quick Reference

| What you want to do | Command |
|---------------------|---------|
| Create/manage users | `ansible-playbook playbooks/user-management.yml` |
| Harden server security | `ansible-playbook playbooks/server-hardening.yml` |
| Install Proxmox | `ansible-playbook playbooks/proxmox-install.yml` |
| Check system status | `ansible-playbook playbooks/diagnose-system.yml` |
| Validate YAML files | `ansible-playbook playbooks/validate-yaml.yml` |
| Fix console login | `ansible-playbook playbooks/fix-console-login.yml` |

### Before Running a Playbook

1. ✅ **Read the playbook's documentation** (in this README)
2. ✅ **Create your config file** (copy from `.example` file)
3. ✅ **Edit your config file** (uncomment and modify settings)
4. ✅ **Validate YAML** (run `validate-yaml.yml` to check for errors)
5. ✅ **Run the playbook**

### Important Notes

- **Playbooks are safe to run multiple times** - Ansible only makes changes if needed (idempotent)
- **Always read warnings** - Some playbooks can lock you out if not configured correctly
- **Keep your SSH session open** - When hardening servers, keep your current session open until you verify you can reconnect
- **Backup first** - For major changes, consider backing up important data

### Example: Your First Playbook Run

Let's say you want to create a user. Here's the complete process:

```bash
# 1. Go to the repository
cd /opt/ansible

# 2. Create your config file (first time only)
cp vars/users.local.yml.example vars/users.local.yml

# 3. Edit the config file
nano vars/users.local.yml
# (Add your user details, save and exit)

# 4. Validate the YAML (optional but recommended)
ansible-playbook playbooks/validate-yaml.yml

# 5. Run the playbook
ansible-playbook playbooks/user-management.yml

# 6. Done! Your user is created.
```

That's it! You've just automated user creation with Ansible.

---

## Projects

### Quick Reference: All Playbooks

**User Management:**
```bash
ansible-playbook playbooks/user-management.yml
```

**Server Hardening (Complete):**
```bash
ansible-playbook playbooks/server-hardening.yml
```

**Modular Hardening Playbooks:**
```bash
# System updates (safest)
ansible-playbook playbooks/hardening-updates.yml

# SSH hardening (⚠️ can lock you out)
ansible-playbook playbooks/hardening-ssh.yml

# Firewall configuration (⚠️ can block access)
ansible-playbook playbooks/hardening-firewall.yml

# Fail2ban protection
ansible-playbook playbooks/hardening-fail2ban.yml

# Kernel hardening
ansible-playbook playbooks/hardening-kernel.yml

# Disable unnecessary services
ansible-playbook playbooks/hardening-services.yml

# Time synchronization
ansible-playbook playbooks/hardening-ntp.yml

# File permissions
ansible-playbook playbooks/hardening-permissions.yml

# Audit logging
ansible-playbook playbooks/hardening-audit.yml

# Disable IPv6 (if configured)
ansible-playbook playbooks/hardening-ipv6.yml
```

**Remove Hardening:**
```bash
ansible-playbook playbooks/remove-hardening.yml
```

**Proxmox Installation:**
```bash
ansible-playbook playbooks/proxmox-install.yml
```

**Diagnostics & Troubleshooting:**
```bash
# System diagnostics
ansible-playbook playbooks/diagnose-system.yml

# Fix console login issues
ansible-playbook playbooks/fix-console-login.yml

# Validate YAML configuration files
ansible-playbook playbooks/validate-yaml.yml
```

---

### User Management

Automate user account creation, modification, and deletion on local servers.

#### How It Works

**Declarative Approach:** The variables file is the source of truth.
- Users in the file → Created or updated to match
- Users removed from file → Deleted (if `remove_orphaned_users` is enabled)
- No need to specify create/modify/delete actions

#### Quick Start

1. **Manually copy the example file to create your config:**
   ```bash
   cp vars/users.local.yml.example vars/users.local.yml
   nano vars/users.local.yml
   ```
   ⚠️ **Important:** You must manually copy the file - it won't be created automatically.

2. **Uncomment and modify the examples:**
   ```yaml
   users:
     - name: my_user
       groups: ['sudo']
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
    ssh_public_key: "ssh-rsa AAAAB3... alice@laptop"
    sudo_passwordless: true
    # Optional: password hash (for console login)
    # password: "$6$rounds=656000$salt$hash"

  - name: bob
    groups: ['docker']
    ssh_public_key: "ssh-ed25519 AAAAC3... bob@workstation"

# Options
remove_orphaned_users: false  # Set to true to delete users not in 'users' list
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

1. **Manually copy the example file to create your config:**
   ```bash
   cp vars/hardening.local.yml.example vars/hardening.local.yml
   nano vars/hardening.local.yml
   ```
   ⚠️ **Important:** You must manually copy the file - it won't be created automatically.

2. **Uncomment and modify the examples** - especially SSH and firewall configurations
   - ⚠️ **IMPORTANT:** Add your IP to `hardening_ssh_allowed_sources` before running firewall hardening!

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
- **Firewall:** UFW (Debian/Ubuntu) or firewalld (RHEL/CentOS) with SSH whitelist support
- **Fail2ban:** Brute force protection
- **Automatic Updates:** Security updates installed automatically
- **Kernel Hardening:** Network security parameters
- **Service Management:** Unnecessary services disabled

#### Modular Hardening Playbooks

The hardening has been broken down into separate, testable playbooks so you can identify which component is causing issues.

**Available Playbooks:**
1. **`hardening-updates.yml`** - System updates and automatic security updates (safest)
2. **`hardening-ssh.yml`** - SSH configuration hardening (⚠️ can lock you out)
3. **`hardening-firewall.yml`** - Firewall (UFW) configuration (⚠️ **MOST LIKELY CULPRIT** for boot/login issues)
4. **`hardening-fail2ban.yml`** - Fail2ban installation and configuration
5. **`hardening-kernel.yml`** - Kernel parameter hardening
6. **`hardening-services.yml`** - Disable unnecessary services
7. **`hardening-ntp.yml`** - Time synchronization (chrony/NTP)
8. **`hardening-permissions.yml`** - File permission restrictions
9. **`hardening-audit.yml`** - Audit logging (auditd)
10. **`hardening-ipv6.yml`** - Disable IPv6 (if configured)

**Testing Strategy:**
```bash
# Step 1: Test safest components first
ansible-playbook playbooks/hardening-updates.yml
ansible-playbook playbooks/hardening-ntp.yml
ansible-playbook playbooks/hardening-permissions.yml
ansible-playbook playbooks/hardening-audit.yml

# Step 2: Test network-related components
ansible-playbook playbooks/hardening-kernel.yml
ansible-playbook playbooks/hardening-firewall.yml  # ⚠️ Test carefully

# Step 3: Test SSH and security components
ansible-playbook playbooks/hardening-ssh.yml  # ⚠️ Can lock you out
ansible-playbook playbooks/hardening-fail2ban.yml
```

**Quick Rollback:**
```bash
# Remove all hardening changes
ansible-playbook playbooks/remove-hardening.yml
```

**Manual Removal from Recovery Mode:**
```bash
# 1. Remount filesystem
mount -o remount,rw /

# 2. Disable UFW firewall
ufw disable

# 3. Restore SSH config (if backup exists)
if [ -f /etc/ssh/sshd_config.backup ]; then
  cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
  systemctl restart ssh
fi

# 4. Stop and disable fail2ban
systemctl stop fail2ban
systemctl disable fail2ban

# 5. Remove UFW whitelist scripts and timers
rm -f /usr/local/bin/ufw-ssh-whitelist-update.sh
rm -f /etc/ufw/ssh-whitelist-sources.conf
systemctl stop ufw-ssh-whitelist-update.timer
systemctl disable ufw-ssh-whitelist-update.timer
rm -f /etc/systemd/system/ufw-ssh-whitelist-update.timer
rm -f /etc/systemd/system/ufw-ssh-whitelist-update.service
systemctl daemon-reload
```

#### Troubleshooting SSH Access Issues

**Quick Diagnosis:**
```bash
# Check if SSH service is running
systemctl status ssh

# Check UFW firewall status
ufw status verbose

# Check SSH port
grep -E '^Port|^#Port' /etc/ssh/sshd_config

# Check if SSH is listening
ss -tlnp | grep :22
```

**Quick Fixes:**

1. **Enable SSH service:**
   ```bash
   systemctl enable ssh
   systemctl start ssh
   ```

2. **Allow SSH in UFW:**
   ```bash
   SSH_PORT=$(grep -E '^Port|^#Port' /etc/ssh/sshd_config | tail -1 | sed 's/^#Port/Port/' | awk '{print $2}')
   SSH_PORT=${SSH_PORT:-22}
   ufw allow $SSH_PORT/tcp
   ufw reload
   ```

3. **Temporarily disable UFW:**
   ```bash
   ufw disable
   ```

4. **Restore SSH config from backup:**
   ```bash
   cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
   systemctl restart ssh
   ```

**SSH Works in Recovery Mode But Not Normal Boot:**
```bash
# Enable SSH and network services
systemctl enable ssh
systemctl enable sshd
systemctl enable networking
systemctl enable NetworkManager

# Check boot logs
journalctl -b -1 | grep -iE 'ssh|network|error|fail' | tail -50
```

**Can't Login at Console on Normal Boot:**
```bash
# Check getty services (console login)
systemctl list-units | grep getty
systemctl enable getty@tty1.service

# Check failed services
systemctl list-units --state=failed

# Check boot logs
journalctl -b -1 | grep -iE "timeout|hang|wait|fail" | tail -30
```

**Adding Your IP to Whitelist (from recovery mode):**
```bash
# Remount filesystem
mount -o remount,rw /

# Add your IP to UFW (replace YOUR_IP with your actual IP)
ufw allow from YOUR_IP to any

# Reload UFW
ufw reload
```

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

1. **Manually copy the example file to create your config (optional):**
   ```bash
   cp vars/proxmox.local.yml.example vars/proxmox.local.yml
   nano vars/proxmox.local.yml
   ```
   ⚠️ **Important:** You must manually copy the file - it won't be created automatically.
   - This file is optional - defaults will be used if not configured
   - Uncomment and modify settings if needed (hostname, network, etc.)

2. **Run the playbook:**
   ```bash
   ansible-playbook playbooks/proxmox-install.yml
   ```

3. **Reboot if required** and access the web interface at `https://your-hostname:8006`

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

#### Troubleshooting Proxmox Installation

**SSH Access Issues After Proxmox Installation:**

If you can't access SSH after booting into the PVE kernel:

1. **Access Recovery Mode:**
   - Boot the system
   - At GRUB menu, select the PVE kernel entry
   - Press `e` to edit
   - Find the line starting with `linux` and add `systemd.unit=rescue.target` at the end
   - Press `Ctrl+X` to boot into recovery mode

2. **Enable SSH service:**
   ```bash
   mount -o remount,rw /
   systemctl enable ssh
   systemctl start ssh
   ```

3. **Check network:**
   ```bash
   systemctl enable networking
   systemctl enable NetworkManager
   ip addr show
   ```

4. **Exit recovery mode:**
   ```bash
   exit
   ```

**Console Login Not Working:**
```bash
# Enable getty services
systemctl enable getty@tty1.service
systemctl enable serial-getty@ttyS0.service
```

---

### Storing Secrets Securely

This repository includes a template file for storing sensitive information like passwords.

**Location:** `vars/secrets.local.yml` (git-ignored, your actual config)

This file:
- ✅ **Template is in git** (`vars/secrets.local.yml.example` with commented examples)
- ✅ **Your actual file is git-ignored** - stays on server only
- ⚠️ **Restrict permissions:** `chmod 600 vars/secrets.local.yml`

**Setup:**
```bash
# Manually copy the example file to create your config
cp vars/secrets.local.yml.example vars/secrets.local.yml

# Edit the secrets file
nano vars/secrets.local.yml

# Restrict permissions (important for security!)
chmod 600 vars/secrets.local.yml
```
⚠️ **Important:** You must manually copy the file - it won't be created automatically.

**Uncomment and modify the examples** to add your secrets.

**Security Best Practices:**
1. **Restrict file permissions:**
   ```bash
   chmod 600 vars/secrets.local.yml
   ```

2. **Never commit this file:**
   - It's already in `.gitignore`
   - Double-check before committing: `git status` should NOT show this file

3. **Use password hashes when possible:**
   ```bash
   # Generate a password hash
   python3 -c "import crypt; print(crypt.crypt('password', crypt.mksalt(crypt.METHOD_SHA512)))"
   ```

4. **Backup separately:**
   - Don't rely on git for backups of secrets
   - Use secure password managers or encrypted storage

**Using Secrets in Playbooks:**
```yaml
- name: My Playbook
  hosts: localhost
  become: yes
  vars_files:
    - ../vars/secrets.local.yml
  
  tasks:
    - name: Use root password
      # Use {{ root_password }} in your tasks
```

**What to Store Here:**
- Root password
- Database passwords
- API keys
- Any other sensitive credentials

**What NOT to Store:**
- User passwords (use `vars/users.local.yml` with password hashes)
- SSH keys (use `vars/users.local.yml` with `ssh_public_key`)
- Public configuration (use regular `.local.yml` files)

**Verification:**
```bash
git status
# vars/secrets.local.yml should NOT appear

git check-ignore vars/secrets.local.yml
# Should output: vars/secrets.local.yml
```

---

*More projects coming soon...*
