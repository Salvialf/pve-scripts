#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

LOGO=$(cat <<"EOF"
    ____       __    _
   / __ \___  / /_  (_)___  ____
  / / / / _ \/ __ \/ / __ `/ __ \
 / /_/ /  __/ /_/ / / /_/ / / / /
/_____/\___/_.___/_/\__,_/_/ /_/
EOF
)
APP="Debian"
var_disk="4"
var_cpu="1"
var_ram="512"
var_os="debian"
var_os_locked="yes"
var_version="13"
var_color_primary="color125"
init_script

function update_script() {
  msg_info "Updating $APP LXC"
  apt-get update &>/dev/null
  apt-get -y upgrade &>/dev/null
  msg_ok "Updated $APP LXC"
}

create_or_update
