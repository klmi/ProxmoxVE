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

service_name="scanopy-daemon"
service="/etc/systemd/system/$service_name.service"
install_script="/opt/scanopy/install.sh"

declare -A old_flags

msg_info "Extract existing flags, in case service exists"
if [[ -f "$service" ]]; then
    msg_info "Extracting old ExecStart flags"
    line=$(grep "ExecStart=/usr/local/bin/scanopy-daemon" "$service")
    # all flags --flag value
    while read -r flag value; do
        old_flags["$flag"]="$value"
    done < <(echo "$line" | grep -oP '--\S+ \S+' | awk '{print $1, $2}')
    msg_ok "Old flags extracted"
else
    msg_info "No existing service, proceeding with fresh install"
fi

msg_info "Installing Scanopy Daemon"
yes | bash "$install_script"
msg_ok "Installation finished"

msg_info "Rewrite formerly extracted values to service"
if [[ -f "$service" && ${#old_flags[@]} -gt 0 ]]; then
    msg_info "Applying old flag values to new service"

    # read execstart_line from new file
    execstart_line=$(grep "ExecStart=/usr/local/bin/scanopy-daemon" "$service")

    # for each old flag
    for flag in "${!old_flags[@]}"; do
        value="${old_flags[$flag]}"
        if [[ -z "$value" ]]; then
            continue
        fi

        if grep -q "$flag" <<< "$execstart_line"; then
            # flag exists in file -> write value
            sed -i "s|${flag} [^ ]*|${flag} $value|" "$service"
        else
            # flag didn't exists -> append
            sed -i "/ExecStart=/ s|$| $flag $value|" "$service"
        fi
    done
    msg_ok "reloading daemon"
    systemctl daemon-reload
    systemctl enable $service_name

    if systemctl list-units --all | grep -q "^$service_name.service"; then
      if systemctl is-active --quiet "$service_name"; then
        msg_ok "Old values applied successfully"
	msg_ok "Service $service_name is running"
      else
        msg_error "Service $service_name exists but is not running"
      fi
    else
      msg_error "Service $service_name does not exist"
    fi

else
    msg_info "No old flags to apply"
    msg_info ""
    msg_info " IMPORTANT: You must edit the service file with your daemon configuration:"
    msg_info ""
    msg_info "  sudo nano /etc/systemd/system/scanopy-daemon.service"
    msg_info ""
    msg_info "Add your daemon arguments to the ExecStart line:"
    msg_info ""
    msg_info "  ExecStart=/usr/local/bin/scanopy-daemon --server-url http://YOUR_SERVER --server-port 60072 --network-id YOUR_NETWORK_ID --daemon-api-key YOUR_API_KEY"
    msg_info ""
    msg_info "Then reload and start the service:"
    msg_info "  sudo systemctl daemon-reload"
    msg_info ""
fi

motd_ssh
customize
cleanup_lxc

