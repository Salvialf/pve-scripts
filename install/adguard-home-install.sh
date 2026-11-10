#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://github.com/AdguardTeam/AdGuardHome

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
update_os

msg_info "Installing AdGuard Home"
curl -fsSL https://static.adtidy.org/adguardhome/release/AdGuardHome_linux_amd64.tar.gz | tar -xz -C /opt
# AdGuard Home creates and starts its own service, as its official install script does
$STD /opt/AdGuardHome/AdGuardHome -s install
msg_ok "Installed AdGuard Home"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
