# Modular Hardening Playbooks

The hardening has been broken down into separate, testable playbooks so you can identify which component is causing issues.

## Available Playbooks

1. **`hardening-updates.yml`** - System updates and automatic security updates
   - Safe to run, unlikely to cause boot issues
   - Updates packages and configures unattended-upgrades

2. **`hardening-ssh.yml`** - SSH configuration hardening
   - ⚠️ Can lock you out if misconfigured
   - Changes SSH settings (root login, password auth, etc.)

3. **`hardening-firewall.yml`** - Firewall (UFW) configuration
   - ⚠️ **MOST LIKELY CULPRIT** for boot/login issues
   - Enables UFW firewall with default deny policies
   - Configures SSH whitelist if specified

4. **`hardening-fail2ban.yml`** - Fail2ban installation and configuration
   - Generally safe, but can block legitimate logins if misconfigured

5. **`hardening-kernel.yml`** - Kernel parameter hardening
   - Network security parameters
   - Could potentially affect network connectivity

6. **`hardening-services.yml`** - Disable unnecessary services
   - Stops and disables services like telnet, rsh, etc.
   - Could affect boot if critical service is disabled

7. **`hardening-ntp.yml`** - Time synchronization (chrony/NTP)
   - Generally safe

8. **`hardening-permissions.yml`** - File permission restrictions
   - Generally safe

9. **`hardening-audit.yml`** - Audit logging (auditd)
   - Generally safe

10. **`hardening-ipv6.yml`** - Disable IPv6 (if configured)
    - Could affect network if IPv6 is needed

## Testing Strategy

### Step 1: Test Safest Components First

```bash
# These are very unlikely to cause issues
ansible-playbook playbooks/hardening-updates.yml
ansible-playbook playbooks/hardening-ntp.yml
ansible-playbook playbooks/hardening-permissions.yml
ansible-playbook playbooks/hardening-audit.yml
```

### Step 2: Test Network-Related Components

```bash
# Test kernel parameters (could affect network)
ansible-playbook playbooks/hardening-kernel.yml

# Test firewall (MOST LIKELY CULPRIT)
ansible-playbook playbooks/hardening-firewall.yml
```

### Step 3: Test SSH and Security Components

```bash
# Test SSH hardening (can lock you out)
ansible-playbook playbooks/hardening-ssh.yml

# Test fail2ban
ansible-playbook playbooks/hardening-fail2ban.yml
```

### Step 4: Test Service Management

```bash
# Test service disabling
ansible-playbook playbooks/hardening-services.yml
```

## Quick Rollback

If any playbook causes issues, use the rollback playbook:

```bash
ansible-playbook playbooks/remove-hardening.yml
```

Or manually disable the specific component:

```bash
# Disable firewall
sudo ufw disable

# Restore SSH config
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart ssh

# Stop fail2ban
sudo systemctl stop fail2ban
sudo systemctl disable fail2ban
```

## Recommended Testing Order

Based on likelihood of causing boot/login issues:

1. ✅ **Start with:** `hardening-updates.yml` (safest)
2. ✅ **Then:** `hardening-ntp.yml`, `hardening-permissions.yml`, `hardening-audit.yml`
3. ⚠️ **Test carefully:** `hardening-kernel.yml`
4. ⚠️ **Test VERY carefully:** `hardening-firewall.yml` (most likely culprit)
5. ⚠️ **Test with caution:** `hardening-ssh.yml` (can lock you out)
6. ✅ **Then:** `hardening-fail2ban.yml`, `hardening-services.yml`

## Running All at Once

If you want to run all hardening at once (original behavior):

```bash
ansible-playbook playbooks/server-hardening.yml
```

This still uses the original role that combines everything.

