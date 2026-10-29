#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://zwave-js.github.io/zwave-js-ui/

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  sudo \
  unzip
msg_ok "Installed Dependencies"

msg_info "Installing Z-Wave JS UI"
RELEASE=$(curl -fsSL https://api.github.com/repos/zwave-js/zwave-js-ui/releases/latest | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
curl -fsSL -o /tmp/zwave-js-ui.zip "https://github.com/zwave-js/zwave-js-ui/releases/download/${RELEASE}/zwave-js-ui-${RELEASE}-linux.zip"
unzip -q /tmp/zwave-js-ui.zip -d /opt/zwave-js-ui
rm /tmp/zwave-js-ui.zip
echo "$RELEASE" >/opt/zwave-js-ui/version
msg_ok "Installed Z-Wave JS UI $RELEASE"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/zwave-js-ui.service
[Unit]
Description=Z-Wave JS UI
Wants=network-online.target
After=network-online.target

[Service]
User=root
WorkingDirectory=/opt/zwave-js-ui
ExecStart=/opt/zwave-js-ui/zwave-js-ui-linux
# Data kept out of /opt/zwave-js-ui, which updates replace
StateDirectory=zwave-js-ui
Environment=STORE_DIR=/var/lib/zwave-js-ui

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now zwave-js-ui
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
