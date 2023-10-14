#!/usr/bin/env bash

# Write custom configuration
cat > /run/dnsmasq.conf.d/custom.conf <<EOF
no-resolv
strict-order

server=1.1.1.1
server=1.0.0.1
EOF

# Remove 'all-servers' as it conflicts with 'strict-order'
sed -i '/all-servers/d' /run/dnsmasq.conf.d/dns.conf

# Restart dnsmasq
kill -9 "$(cat /run/dnsmasq.pid)"