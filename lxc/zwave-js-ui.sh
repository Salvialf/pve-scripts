#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2021-2024 tteck
# Copyright (c) 2026 Salvialf
# Author: tteck (tteckster) | Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://zwave-js.github.io/zwave-js-ui/

LOGO=$(cat <<"EOF"
 _____                                  _______    __  ______
/__  /_      ______ __   _____         / / ___/   / / / /  _/
  / /| | /| / / __ `/ | / / _ \   __  / /\__ \   / / / // /
 / /_| |/ |/ / /_/ /| |/ /  __/  / /_/ /___/ /  / /_/ // /
/____/__/|__/\__,_/ |___/\___/   \____//____/   \____/___/
EOF
)
header_info
echo -e "Loading..."
APP="Zwave-JS-UI"
var_disk="4"
var_cpu="2"
var_ram="1024"
var_os="debian"
var_version="13"
var_onboot="yes"
var_color_primary="color25"
variables
color
catch_errors

function update_script() {
if [[ ! -d /opt/zwave-js-ui ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP LXC OS packages"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated $APP LXC OS packages"
local release
release=$(curl -fsSL https://api.github.com/repos/zwave-js/zwave-js-ui/releases/latest | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
if [ "$release" == "$(cat /opt/zwave-js-ui/version 2>/dev/null)" ]; then
  msg_ok "$APP is already up to date ($release)"
  exit
fi
msg_info "Updating $APP to $release"
curl -fsSL -o /tmp/zwave-js-ui.zip "https://github.com/zwave-js/zwave-js-ui/releases/download/${release}/zwave-js-ui-${release}-linux.zip"
systemctl stop zwave-js-ui
rm -rf /opt/zwave-js-ui
unzip -q /tmp/zwave-js-ui.zip -d /opt/zwave-js-ui
rm /tmp/zwave-js-ui.zip
echo "$release" >/opt/zwave-js-ui/version
systemctl start zwave-js-ui
msg_ok "Updated $APP to $release"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "Access ${APP} at the following URL:
         ${BL}http://$(get_ip):8091${CL}\n"
