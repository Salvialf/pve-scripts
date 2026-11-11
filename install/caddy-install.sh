#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://caddyserver.com/

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
prepare_container

msg_info "Installing gpg"
install_packages gpg
msg_ok "Installed gpg"

msg_info "Installing Caddy"
curl -1sLf https://dl.cloudsmith.io/public/caddy/stable/gpg.key | gpg --dearmor >/usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt >/etc/apt/sources.list.d/caddy-stable.list
chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg /etc/apt/sources.list.d/caddy-stable.list
$STD apt-get update
install_packages caddy
msg_ok "Installed Caddy"

finish_container
