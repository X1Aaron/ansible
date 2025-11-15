#!/bin/bash
# Resolve hostname to IP addresses
# Usage: resolve-hostname.sh <hostname_or_ip>

SOURCE="$1"

# Check if it's already an IP or CIDR (contains numbers and dots/slashes, no letters except in IPv6)
if echo "$SOURCE" | grep -qE '^[0-9]|^[0-9a-fA-F:]*::|/[0-9]+$'; then
  # It's already an IP/CIDR, return as-is
  echo "$SOURCE"
else
  # It's a hostname, resolve ALL IPs (one per line)
  getent hosts "$SOURCE" 2>/dev/null | awk '{print $1}' || echo ""
fi

