#!/usr/bin/env bash

# Settings
readonly SCRIPT_PATH="/data/on_boot.d/$(basename $BASH_SOURCE)"
readonly SYSTEMD_SERVICE_UNIT_PATH="/etc/systemd/system/dnsmasq-config.service"
readonly SYSTEMD_PATH_UNIT_PATH="/etc/systemd/system/dnsmasq-config.path"

configure_dnsmasq() {
    # Append custom configuration
    generate_dnsmasq_config > /run/dnsmasq.conf.d/custom.conf

    # Remove 'all-servers' as it conflicts with 'strict-order'
    local result
    result=$(grep -q "all-servers" /run/dnsmasq.conf.d/dns.conf)
    if [[ $? -eq 0 ]]; then
        sed -i '/all-servers/d' /run/dnsmasq.conf.d/dns.conf
    fi

    # Restart dnsmasq
    kill -9 "$(cat /run/dnsmasq.pid)"

    echo "Configured dnsmasq"
    return 0
}

install_services() {
    if [[ ! -x "$SCRIPT_PATH" ]]; then
        echo -e "Script is not executable"
        exit 1
    fi

    local force="${1:-false}"
    if [[ "$force" != false ]] && [[ "$force" != true ]]; then
        echo -e "Force must be a boolean"
        exit 1
    fi

    local result=false
    if [[ "$force" == true ]] || [[ ! -f "$SYSTEMD_SERVICE_UNIT_PATH" ]]; then
        generate_systemd_service_unit > "$SYSTEMD_SERVICE_UNIT_PATH"
        echo -e "Installed ${SYSTEMD_SERVICE_UNIT_PATH}"
        result=true
    fi

    if [[ "$force" == true ]] || [[ ! -f "$SYSTEMD_PATH_UNIT_PATH" ]]; then
        generate_systemd_path_unit > "$SYSTEMD_PATH_UNIT_PATH"
        echo -e "Installed ${SYSTEMD_PATH_UNIT_PATH}"
        result=true
    fi

    if [[ "$result" == true ]]; then
        systemctl daemon-reload
        systemctl enable $(basename "$SYSTEMD_PATH_UNIT_PATH")
        systemctl start $(basename "$SYSTEMD_PATH_UNIT_PATH")
        systemctl start $(basename "$SYSTEMD_SERVICE_UNIT_PATH")
        return 0
    fi

    echo -e "No services installed"
    return 1
}

generate_dnsmasq_config() {
    cat <<EOF
##
# Generated automatically by LXGaming/unifios.sh
##

no-resolv
strict-order

server=1.1.1.1
server=1.0.0.1
EOF
}

generate_systemd_service_unit() {
    cat <<EOF
##
# Generated automatically by LXGaming/unifios.sh
##

[Unit]
Description=dnsmasq Configure

[Service]
Type=oneshot
ExecStartPre=/bin/sleep 2
ExecStart=-"$SCRIPT_PATH" service
EOF
}

generate_systemd_path_unit() {
    cat <<EOF
##
# Generated automatically by LXGaming/unifios.sh
##

[Unit]
Description=Monitor dnsmasq files for changes

[Path]
PathChanged=/run/dnsmasq.conf.d/dns.conf
Unit=$(basename "$SYSTEMD_SERVICE_UNIT_PATH")

[Install]
WantedBy=multi-user.target
EOF
}

if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "Invalid script path: ${SCRIPT_PATH}"
    exit 1
fi

command="${1,,}"
if [[ -z "$command" ]]; then
    install_services false
    exit 0
fi

if [[ "$command" == "install" ]]; then
    install_services true
    exit 0
fi

if [[ "$command" == "service" ]]; then
    configure_dnsmasq
    exit 0
fi

echo "Invalid arguments"
exit 1