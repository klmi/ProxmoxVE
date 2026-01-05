#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: klmi
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/scanopy/scanopy

APP="Scanopy-Daemon"
var_tags="${var_tags:-analytics}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-3}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
   header_info
   check_container_storage
#   check_container_resourcesy
#   if [[ ! -d /opt/scanopy ]]; then
#     msg_error "No ${APP} Installation Found!"
#     exit
#   fi

   if check_for_gh_release "scanopy" "scanopy/scanopy"; then
     CLEAN_INSTALL=1 fetch_and_deploy_gh_release "scanopy" "scanopy/scanopy" "tarball" "latest" "/opt/scanopy"
     exit
   fi
   exit
 }

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e ""
echo -e "⚠️  IMPORTANT: You must edit the service file with your daemon configuration:"
echo -e ""
echo -e "  sudo nano /etc/systemd/system/scanopy-daemon.service"
echo -e ""
echo -e "Add your daemon arguments to the ExecStart line:"
echo -e "  ExecStart=/usr/local/bin/scanopy-daemon --server-url http://YOUR_SERVER --server-port 60072 --network-id YOUR_NETWORK_ID --daemon-api-key YOUR_API_KEY"
echo -e ""
echo -e "Then reload and start the service:"
echo -e "  sudo systemctl daemon-reload"
echo -e "  sudo systemctl restart scanopy-daemon"
echo -e ""
