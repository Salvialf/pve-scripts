#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Copyright (c) 2026 Salvialf
# Author: tteck (tteckster) | Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://caddyserver.com/

COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"

LOGO=$(cat <<"EOF"
   ______          __    __
  / ____/___ _____/ /___/ /_  __
 / /   / __ `/ __  / __  / / / /
/ /___/ /_/ / /_/ / /_/ / /_/ /
\____/\__,_/\__,_/\__,_/\__, /
                       /____/
EOF
)
APP="Caddy"
var_disk_alpine="1"
var_os_supported="debian ubuntu alpine"
var_onboot="yes"
var_data="/etc/caddy /var/lib/caddy"
var_color_primary="color35"
var_color_theme="dark"
init_script

function app_pre_update() {
  if [[ ! -f /etc/caddy/Caddyfile ]]; then
    msg_error "No ${APP} installation found"
    exit 1
  fi
  # Caddy renews its repository key: a copy kept from the install would end up expired and block its updates
  if ! is_alpine; then
    curl -1sLf https://dl.cloudsmith.io/public/caddy/stable/gpg.key | gpg --dearmor >/usr/share/keyrings/caddy-stable-archive-keyring.gpg
  fi
}

# Unlike apt, Alpine doesn't restart a service when its package is upgraded
function app_update() {
  if is_alpine; then
    msg_info "Restarting ${APP}"
    $STD rc-service caddy restart
    msg_ok "Restarted ${APP}"
  fi
}

create_or_update
echo -e "Set up Caddy in the container's configuration file:
         ${BL}/etc/caddy/Caddyfile${CL}\n"
