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
header_info
echo -e "Loading..."
APP="AdGuard-Home"
var_disk="4"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="13"
var_onboot="yes"
var_color_primary="color72"
var_color_theme="dark"
variables
color
catch_errors

function update_script() {
if [[ ! -x /opt/AdGuardHome/AdGuardHome ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP LXC OS packages"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated $APP LXC OS packages"
msg_info "Updating $APP"
output=$(/opt/AdGuardHome/AdGuardHome --update 2>&1)
if grep -q "no updates available" <<< "$output"; then
  msg_ok "$APP is already up to date"
else
  msg_ok "Updated $APP"
fi
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "Finish the ${APP} setup at the following URL:
         ${BL}http://$(get_ip):3000${CL}\n"
