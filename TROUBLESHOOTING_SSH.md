# SSH Access Issues After Proxmox Installation

If you can't access SSH after booting into the PVE kernel, follow these steps from the console:

## Quick Diagnosis (from console)

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
sudo systemctl enable ssh
sudo systemctl start ssh
# or
sudo systemctl enable sshd
sudo systemctl start sshd
```

### Fix 2: Allow SSH in UFW
```bash
# Get SSH port from config
SSH_PORT=$(grep -E '^Port|^#Port' /etc/ssh/sshd_config | tail -1 | sed 's/^#Port/Port/' | awk '{print $2}')
SSH_PORT=${SSH_PORT:-22}

# Allow SSH in UFW
sudo ufw allow $SSH_PORT/tcp
sudo ufw reload
```

### Fix 3: Temporarily disable UFW (if needed)
```bash
sudo ufw disable
# Test SSH access
# Then re-enable: sudo ufw enable
```

### Fix 4: Check SSH configuration
```bash
# Test SSH config
sudo sshd -t

# If config is bad, restore backup
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart ssh
```

### Fix 5: Check network interface
```bash
# Check if network is up
ip addr show
# or
ifconfig

# If network is down, bring it up
sudo ifup <interface_name>
# or restart networking
sudo systemctl restart networking
```

## Common Issues

1. **SSH service not enabled:** The PVE kernel might not have SSH enabled by default
2. **UFW blocking SSH:** Firewall rules might not have persisted through kernel change
3. **SSH port changed:** If hardening changed the port, make sure UFW allows that port
4. **Network interface down:** Network might not be coming up with new kernel

## Prevention

After fixing SSH access, run the server hardening playbook again to ensure SSH is properly configured:
```bash
ansible-playbook playbooks/server-hardening.yml
```

