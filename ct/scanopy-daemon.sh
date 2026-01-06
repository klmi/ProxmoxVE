#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: klmi
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/scanopy/scanopy

APP="Scanopy-Daemon"
var_tags="${var_tags:-scanopy}"
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
   check_container_resourcesy
   if [[ ! -d /opt/scanopy ]]; then
     msg_error "No ${APP} Installation Found!"
     exit
   fi

#   if check_for_gh_release "scanopy" "scanopy/scanopy"; then
#     CLEAN_INSTALL=1 fetch_and_deploy_gh_release "scanopy" "scanopy/scanopy" "tarball" "latest" "/opt/scanopy"
#     exit
#   fi
   exit
 }

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Please log in into the container and configure the daemon if first installation.${CL}"
echo -e ""
