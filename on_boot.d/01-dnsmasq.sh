#!/usr/bin/env bash

# Overwrite upstream nameservers
cat > /etc/resolv.dnsmasq <<EOF
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF

# Write custom configuration
cat > /run/dnsmasq.conf.d/custom.conf <<EOF
strict-order
EOF

# Remove 'all-servers' as it conflicts with 'strict-order'
sed -i '/all-servers/d' /run/dnsmasq.conf.d/dns.conf

# Restart dnsmasq
kill -9 "$(cat /run/dnsmasq.pid)"