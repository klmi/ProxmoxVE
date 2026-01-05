#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
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

yes | bash /opt/scanopy/install.sh
systemctl enable scanopy-daemon
echo -e "⚠️  IMPORTANT: You must edit the service file with your daemon configuration:"
echo -e ""
echo -e "  sudo nano /etc/systemd/system/scanopy-daemon.service"
echo -e ""
echo -e "Add your daemon arguments to the ExecStart line:"
echo -e "  ExecStart=/usr/local/bin/scanopy-daemon --server-url http://YOUR_SERVER --server-port 60072 --network-id YOUR_NETWORK_ID --daemon-api-key YOUR_API_KEY"
echo -e ""
echo -e "Then reload and start the service:"
echo -e "  sudo systemctl daemon-reload"


motd_ssh
customize
cleanup_lxc
