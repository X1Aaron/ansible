# Quick Hardening Removal

If you need to quickly remove all hardening changes to get back to a working system:

## Option 1: Run the Rollback Playbook (if you have SSH access)

```bash
ansible-playbook playbooks/remove-hardening.yml
```

## Option 2: Manual Removal from Recovery Mode

If you can't access SSH, do this from recovery mode:

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

# 5. Remove UFW whitelist scripts
rm -f /usr/local/bin/ufw-ssh-whitelist-update.sh
rm -f /etc/ufw/ssh-whitelist-sources.conf

# 6. Stop and remove UFW whitelist timer
systemctl stop ufw-ssh-whitelist-update.timer
systemctl disable ufw-ssh-whitelist-update.timer
rm -f /etc/systemd/system/ufw-ssh-whitelist-update.timer
rm -f /etc/systemd/system/ufw-ssh-whitelist-update.service
systemctl daemon-reload

# 7. Exit recovery mode
exit
```

## What Gets Removed

- ✅ UFW firewall (disabled)
- ✅ SSH hardening (restored from backup)
- ✅ Fail2ban (stopped and disabled)
- ✅ UFW whitelist scripts and timers
- ✅ UFW whitelist configuration files

## What Stays

- System package updates (already installed)
- Kernel parameters (may need manual reset)
- File permissions (may need manual reset)
- Disabled services (may need manual re-enable)

After running this, you should be able to access SSH and console normally.

