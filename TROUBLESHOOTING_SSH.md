# SSH Access Issues After Proxmox Installation

If you can't access SSH after booting into the PVE kernel, follow these steps from the console or recovery mode.

## Accessing Recovery Mode

If you can't access SSH, use recovery mode:
1. Boot the system
2. At GRUB menu, select the PVE kernel entry
3. Press `e` to edit
4. Find the line starting with `linux` and add `systemd.unit=rescue.target` at the end
5. Press `Ctrl+X` to boot into recovery mode
6. You'll be dropped into a root shell

## Quick Diagnosis (from console or recovery mode)

1. **Check if SSH service is running:**
   ```bash
   systemctl status ssh
   # or
   systemctl status sshd
   ```

2. **Check UFW firewall status:**
   ```bash
   ufw status verbose
   ```

3. **Check SSH port:**
   ```bash
   grep -E '^Port|^#Port' /etc/ssh/sshd_config
   ```

4. **Check if SSH is listening:**
   ```bash
   ss -tlnp | grep :22
   # or check the port from sshd_config
   ```

## Quick Fixes

### Fix 1: Enable SSH service
```bash
# In recovery mode, you're already root, so no sudo needed
systemctl enable ssh
systemctl start ssh
# or
systemctl enable sshd
systemctl start sshd

# If in recovery mode, remount filesystem as read-write first:
mount -o remount,rw /
```

### Fix 2: Allow SSH in UFW
```bash
# In recovery mode, remount filesystem first:
mount -o remount,rw /

# Get SSH port from config
SSH_PORT=$(grep -E '^Port|^#Port' /etc/ssh/sshd_config | tail -1 | sed 's/^#Port/Port/' | awk '{print $2}')
SSH_PORT=${SSH_PORT:-22}

# Allow SSH in UFW
ufw allow $SSH_PORT/tcp
ufw reload

# Or temporarily disable UFW to test
ufw disable
```

### Fix 3: Temporarily disable UFW (if needed)
```bash
# In recovery mode, remount filesystem first:
mount -o remount,rw /

ufw disable
# Test SSH access
# Then re-enable: ufw enable
```

### Fix 4: Check SSH configuration
```bash
# In recovery mode, remount filesystem first:
mount -o remount,rw /

# Test SSH config
sshd -t

# If config is bad, restore backup
cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
systemctl restart ssh
```

### Fix 5: Check network interface
```bash
# In recovery mode, remount filesystem first:
mount -o remount,rw /

# Check if network is up
ip addr show
# or
ifconfig

# If network is down, bring it up
ifup <interface_name>
# or restart networking
systemctl restart networking

# In recovery mode, you may need to exit rescue mode first:
exit
# Then the system will continue normal boot
```

## Common Issues

1. **SSH service not enabled:** The PVE kernel might not have SSH enabled by default
2. **UFW blocking SSH:** Firewall rules might not have persisted through kernel change
3. **SSH port changed:** If hardening changed the port, make sure UFW allows that port
4. **Network interface down:** Network might not be coming up with new kernel

## Adding Your IP to the Whitelist (from recovery mode)

If you forgot to add your IP to the whitelist before running hardening:

### Option 1: Manually add your IP to UFW (quick fix)
```bash
# In recovery mode, remount filesystem first:
mount -o remount,rw /

# Find your current IP (from another machine)
# Then add it to UFW (replace YOUR_IP with your actual IP)
ufw allow from YOUR_IP

# Or allow all ports from your IP (trusted source)
ufw allow from YOUR_IP to any

# Reload UFW
ufw reload

# Exit recovery mode
exit
```

### Option 2: Update hardening config and re-run playbook
```bash
# In recovery mode, remount filesystem first:
mount -o remount,rw /

# Edit the hardening config file
nano /opt/ansible/vars/hardening.local.yml

# Add your IP to the whitelist:
# hardening_ssh_allowed_sources:
#   - "YOUR_IP_ADDRESS"
#   - "YOUR_IP_ADDRESS/32"  # Or with CIDR notation

# Exit recovery mode
exit

# After booting normally, re-run hardening playbook
cd /opt/ansible
ansible-playbook playbooks/server-hardening.yml
```

**To find your IP address:**
- From your local machine: `curl ifconfig.me` or `curl ipinfo.io/ip`
- Or check your router/network admin panel

## Prevention

**Before running server hardening, always:**
1. Add your IP to `vars/hardening.local.yml`:
   ```yaml
   hardening_ssh_allowed_sources:
     - "YOUR_IP_ADDRESS"
   ```
2. Then run the hardening playbook:
   ```bash
   ansible-playbook playbooks/server-hardening.yml
   ```

After fixing SSH access, run the server hardening playbook again to ensure SSH is properly configured:
```bash
ansible-playbook playbooks/server-hardening.yml
```

