#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: klmi
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/scanopy/scanopy

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "blub"

#fetch_and_deploy_gh_release "scanopy" "scanopy/scanopy" "tarball" "latest" "/opt/scanopy"

mkdir -p /opt/scanopy
wget https://raw.githubusercontent.com/scanopy/scanopy/refs/heads/main/install.sh -o /opt/scanopy/install.sh

service_name="scanopy-daemon"
service="/etc/systemd/system/$service_name.service"
install_script="/opt/scanopy/install.sh"

declare -A old_flags

msg_info "Checking for existing service and extracting flags"
if [[ -f "$service" ]]; then
    line=$(grep "ExecStart=/usr/local/bin/scanopy-daemon" "$service")
    tokens=($line)

    # Durchlaufe Tokens und speichere Flag-Value Paare
    for ((i=0;i<${#tokens[@]};i++)); do
        token="${tokens[i]}"
        if [[ "$token" == --* ]]; then
            value="${tokens[i+1]}"
            # nur übernehmen, wenn es kein Flag ist
            if [[ -n "$value" && "$value" != --* ]]; then
                old_flags["$token"]="$value"
            else
                old_flags["$token"]=""
            fi
        fi
    done
    msg_ok "Old flags extracted"
else
    msg_info "No existing service found, installing fresh"
fi

msg_info "Installing Scanopy Daemon"
yes | bash "$install_script"
msg_ok "Installation finished"

msg_info "Applying old flag values to new service file"
if [[ -f "$service" && ${#old_flags[@]} -gt 0 ]]; then
    for flag in "${!old_flags[@]}"; do
        value="${old_flags[$flag]}"
        # Nur setzen, wenn Wert nicht leer
        if [[ -n "$value" ]]; then
            if grep -q "$flag" "$service"; then
                # Flag existiert → Wert ersetzen
                sed -i "s|$flag [^ ]*|$flag $value|" "$service"
            else
                # Flag existiert nicht → hinten anhängen
                sed -i "/ExecStart=/ s|$| $flag $value|" "$service"
            fi
        fi
    done
    msg_ok "Old values applied successfully"
fi

msg_info "Reloading and enabling service"
systemctl daemon-reload
systemctl enable "$service_name"

# Prüfen, ob Service läuft
if systemctl list-units --all | grep -q "^$service_name.service"; then
    if systemctl is-active --quiet "$service_name"; then
        msg_ok "Service $service_name is running"
    else
        msg_error "Service $service_name exists but is not running"
    fi
else
    msg_error "Service $service_name does not exist"
fi

# Info, falls keine alten Flags existieren
if [[ ${#old_flags[@]} -eq 0 ]]; then
    msg_info ""
    msg_info " ⚠️ IMPORTANT: You must edit the service file with your daemon configuration:"
    msg_info "  sudo nano /etc/systemd/system/scanopy-daemon.service"
    msg_info ""
    msg_info "Add your daemon arguments to the ExecStart line:"
    msg_info "  ExecStart=/usr/local/bin/scanopy-daemon --server-url http://YOUR_SERVER --server-port 60072 --network-id YOUR_NETWORK_ID --daemon-api-key YOUR_API_KEY"
    msg_info ""
    msg_info "Then reload and start the service:"
    msg_info "  sudo systemctl daemon-reload"
fi

motd_ssh
customize
cleanup_lxc
