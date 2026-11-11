#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Copyright (c) 2026 Salvialf
# Author: tteck (tteckster) | Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://mosquitto.org/

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
prepare_container

msg_info "Installing Mosquitto"
install_packages mosquitto mosquitto-clients
# Debian's mosquitto.conf already has these two settings, Alpine's doesn't
if is_alpine; then
  mkdir -p /etc/mosquitto/conf.d /var/lib/mosquitto
  chown mosquitto:mosquitto /var/lib/mosquitto
  printf '\npersistence_location /var/lib/mosquitto/\ninclude_dir /etc/mosquitto/conf.d\n' >>/etc/mosquitto/mosquitto.conf
fi
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
enable_service mosquitto
msg_ok "Created MQTT user ${MOSQUITTO_USER}"

finish_container
