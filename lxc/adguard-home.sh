#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2021-2024 tteck
# Copyright (c) 2026 Salvialf
# Author: tteck (tteckster) | Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://github.com/AdguardTeam/AdGuardHome

LOGO=$(cat <<"EOF"
    ___       ________                     __   __  __
   /   | ____/ / ____/_  ______ __________/ /  / / / /___  ____ ___  ___
  / /| |/ __  / / __/ / / / __ `/ ___/ __  /  / /_/ / __ \/ __ `__ \/ _ \
 / ___ / /_/ / /_/ / /_/ / /_/ / /  / /_/ /  / __  / /_/ / / / / / /  __/
/_/  |_\__,_/\____/\__,_/\__,_/_/   \__,_/  /_/ /_/\____/_/ /_/ /_/\___/
EOF
)
APP="AdGuard-Home"
var_disk_debian="3"
var_disk_alpine="2"
var_os_supported="debian ubuntu alpine"
var_onboot="yes"
var_color_primary="color72"
var_color_theme="dark"
init_script

function app_update() {
  if [[ ! -x /opt/AdGuardHome/AdGuardHome ]]; then
    msg_error "No ${APP} installation found"
    exit 1
  fi
  local installed release
  msg_info "Updating $APP"
  installed=$(/opt/AdGuardHome/AdGuardHome --version | awk '{print $NF}')
  $STD /opt/AdGuardHome/AdGuardHome --update
  release=$(/opt/AdGuardHome/AdGuardHome --version | awk '{print $NF}')
  if [ "$release" == "$installed" ]; then
    msg_ok "$APP is already up to date ($release)"
  else
    msg_ok "Updated $APP to $release"
  fi
}

create_or_update
echo -e "Finish the ${APP} setup at the following URL:
         ${BL}http://$(get_ip):3000${CL}\n"
