#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

LOGO=$(cat <<"EOF"
    ___    __      _
   /   |  / /___  (_)___  ___
  / /| | / / __ \/ / __ \/ _ \
 / ___ |/ / /_/ / / / / /  __/
/_/  |_/_/ .___/_/_/ /_/\___/
        /_/
EOF
)
header_info
echo -e "Loading..."
APP="Alpine"
var_disk="0.5"
var_cpu="1"
var_ram="256"
var_os="alpine"
var_os_locked="yes"
var_version="3.24"
var_color_primary="color24"
variables
color
catch_errors

function update_script() {
  msg_info "Updating $APP LXC"
  apk update &>/dev/null
  apk upgrade &>/dev/null
  msg_ok "Updated $APP LXC"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
