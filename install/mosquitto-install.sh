#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://mosquitto.org/

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Mosquitto"
$STD apt-get install -y \
  mosquitto \
  mosquitto-clients
cat <<EOF >/etc/mosquitto/conf.d/default.conf
allow_anonymous false
persistence true
password_file /etc/mosquitto/passwd
listener 1883
EOF
msg_ok "Installed Mosquitto"

# MOSQUITTO_USER and MOSQUITTO_PASSWORD are exported by lxc/mosquitto.sh
msg_info "Creating MQTT user ${MOSQUITTO_USER}"
$STD mosquitto_passwd -c -b /etc/mosquitto/passwd "$MOSQUITTO_USER" "$MOSQUITTO_PASSWORD"
chown mosquitto:mosquitto /etc/mosquitto/passwd
systemctl restart mosquitto
msg_ok "Created MQTT user ${MOSQUITTO_USER}"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
