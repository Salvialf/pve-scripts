#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://github.com/AdguardTeam/AdGuardHome

source /dev/stdin <<< "$COMMON_FUNC"
source /dev/stdin <<< "$INSTALL_FUNC"
prepare_container

msg_info "Installing AdGuard Home"
curl -fsSL https://static.adtidy.org/adguardhome/release/AdGuardHome_linux_amd64.tar.gz | tar -xz -C /opt
# AdGuard Home creates and starts its own service, as its official install script does
$STD /opt/AdGuardHome/AdGuardHome -s install
msg_ok "Installed AdGuard Home"

finish_container
