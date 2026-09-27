#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT
# https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ____       __    _
   / __ \___  / /_  (_)___  ____
  / / / / _ \/ __ \/ / __ `/ __ \
 / /_/ /  __/ /_/ / / /_/ / / / /
/_____/\___/_.___/_/\__,_/_/ /_/

EOF
}
header_info
echo -e "Loading..."
APP="Debian"
var_disk="4"
var_cpu="1"
var_ram="512"
var_os="debian"
var_os_locked="yes"
var_version="12"
variables
color
catch_errors

function update_script() {
header_info
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
