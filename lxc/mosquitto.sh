#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2021-2024 tteck
# Copyright (c) 2026 Salvialf
# Author: tteck (tteckster) | Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://mosquitto.org/

LOGO=$(cat <<"EOF"
    __  ___                       _ __  __
   /  |/  /___  _________ ___  __(_) /_/ /_____
  / /|_/ / __ \/ ___/ __ `/ / / / / __/ __/ __ \
 / /  / / /_/ (__  ) /_/ / /_/ / / /_/ /_/ /_/ /
/_/  /_/\____/____/\__, /\__,_/_/\__/\__/\____/
                     /_/
EOF
)
header_info
echo -e "Loading..."
APP="Mosquitto"
var_disk="2"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="13"
var_onboot="yes"
var_color_primary="color24"
app_settings=(step_mosquitto_user step_mosquitto_password)
variables
color
catch_errors

function step_mosquitto_user() {
  local user="$MOSQUITTO_USER"
  while true; do
    user=$(wt --title "MQTT USER" --inputbox "Set the MQTT user\nThe clients connect with it" "$user") || return
    if [ -z "$user" ]; then
      wt --title "MQTT USER" --msgbox "User cannot be empty. Please try again."
    # The password file separates the user from the password with a colon
    elif [[ "$user" == *:* ]]; then
      wt --title "MQTT USER" --msgbox "User cannot contain a colon. Please try again."
    else
      break
    fi
  done
  MOSQUITTO_USER="$user"
}

function mosquitto_password_check() {
  if [ -z "$1" ]; then
    wt --title "MQTT PASSWORD" --msgbox "Password cannot be empty. Please try again."
    return 1
  fi
}

function step_mosquitto_password() {
  local pw
  pw=$(ask_password "MQTT PASSWORD" "Set the MQTT password" "$MOSQUITTO_PASSWORD" mosquitto_password_check) || return
  MOSQUITTO_PASSWORD="$pw"
}

function app_default_settings() {
  export MOSQUITTO_USER="" MOSQUITTO_PASSWORD=""
}

function app_summary() {
  local user="${MOSQUITTO_USER:-not set}"
  # Back from the password step keeps the user alone
  if [ -n "$MOSQUITTO_USER" ] && [ -z "$MOSQUITTO_PASSWORD" ]; then
    user+=", password not set"
  fi
  echo "MQTT user: $user"
}

function app_check() {
  if [ -z "$MOSQUITTO_USER" ] || [ -z "$MOSQUITTO_PASSWORD" ]; then
    wt --title "MQTT USER" --msgbox "Set the MQTT user and password first\nIn the ${APP} category of the settings"
    return 1
  fi
}

function update_script() {
if [[ ! -f /etc/mosquitto/conf.d/default.conf ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
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
echo -e "Connect the MQTT clients to the following address:
         ${BL}$(get_ip):1883${CL}
         User: ${BL}${MOSQUITTO_USER}${CL}\n"
