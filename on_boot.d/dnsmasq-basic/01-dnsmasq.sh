#!/usr/bin/env bash

configure_dnsmasq() {
    # Write custom configuration
    generate_dnsmasq_config > /run/dnsmasq.conf.d/custom.conf

    # Restart dnsmasq
    kill -9 "$(cat /run/dnsmasq.pid)"

    echo "Configured dnsmasq"
    return 0
}

generate_dnsmasq_config() {
    cat <<EOF
##
# Generated automatically by LXGaming/unifios.sh
##

local=/internal/
local=/localdomain/
EOF
}

configure_dnsmasq