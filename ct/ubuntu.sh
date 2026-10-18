#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

LOGO=$(cat <<"EOF"
   __  ____                __
  / / / / /_  __  ______  / /___  __
 / / / / __ \/ / / / __ \/ __/ / / /
/ /_/ / /_/ / /_/ / / / / /_/ /_/ /
\____/_.___/\__,_/_/ /_/\__/\__,_/
EOF
)
header_info
echo -e "Loading..."
APP="Ubuntu"
var_disk="4"
var_cpu="1"
var_ram="512"
var_os="ubuntu"
var_os_locked="yes"
var_version="26.04"
var_color_primary="color166"
variables
color
catch_errors

function update_script() {
if [[ ! -d /var ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated $APP LXC"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
