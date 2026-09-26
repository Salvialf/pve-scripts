#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Mips2648
# Modified by: Salvialf
# License: MIT
# https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://jeedom.com/

function header_info {
clear
cat <<"EOF"
       __              __
      / /__  ___  ____/ /___  ____ ___
 __  / / _ \/ _ \/ __  / __ \/ __ `__ \
/ /_/ /  __/  __/ /_/ / /_/ / / / / / /
\____/\___/\___/\__,_/\____/_/ /_/ /_/

EOF
}
header_info
echo -e "Loading..."
APP="Jeedom"
var_disk="16"
var_cpu="2"
var_ram="2048"
var_os="debian"
var_os_locked="yes"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
header_info
if [[ ! -f /var/www/html/core/config/version ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP LXC OS packages"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated $APP LXC OS packages"
echo -e "You can now update Jeedom itself from its Web UI."
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "Access ${APP} at the following URL:
         ${BL}http://$(get_ip)${CL}
         Default login: ${BL}admin${CL}/${BL}admin${CL}\n"
