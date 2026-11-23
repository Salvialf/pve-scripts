#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Copyright (c) 2026 Salvialf
# Author: tteck (tteckster) | Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://mosquitto.org/

COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"

LOGO=$(cat <<"EOF"
    __  ___                       _ __  __
   /  |/  /___  _________ ___  __(_) /_/ /_____
  / /|_/ / __ \/ ___/ __ `/ / / / / __/ __/ __ \
 / /  / / /_/ (__  ) /_/ / /_/ / / /_/ /_/ /_/ /
/_/  /_/\____/____/\__, /\__,_/_/\__/\__/\____/
                     /_/
EOF
)
APP="Mosquitto"
var_os_supported="debian ubuntu alpine"
var_onboot="yes"
var_color_primary="color24"
app_settings=(step_mosquitto_user step_mosquitto_password)
init_script

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

function app_description() {
  echo "**MQTT password:** run \`RESET_MQTT_PASSWORD=yes update\` in the container's console."
}

# Alpine doesn't restart a service when its package is upgraded
function app_update() {
  if is_alpine; then
    msg_info "Restarting ${APP}"
    $STD rc-service mosquitto restart
    msg_ok "Restarted ${APP}"
  fi
}

# Run by RESET_MQTT_PASSWORD=yes update, the user is added when missing
function reset_mqtt_password() {
  if [ ! -f /etc/mosquitto/passwd ]; then
    msg_error "No ${APP} installation found"
    exit 1
  fi
  MOSQUITTO_USER=$(sed -n '1s/:.*//p' /etc/mosquitto/passwd)
  MOSQUITTO_PASSWORD=""
  step_mosquitto_user || exit-script
  step_mosquitto_password || exit-script
  std_mode
  msg_info "Setting the password of ${MOSQUITTO_USER}"
  $STD mosquitto_passwd -b /etc/mosquitto/passwd "$MOSQUITTO_USER" "$MOSQUITTO_PASSWORD"
  # Reloaded rather than restarted, the clients stay connected
  if is_alpine; then
    kill -HUP "$(cat /run/mosquitto.pid)"
  else
    systemctl reload mosquitto
  fi
  msg_ok "Set the password of ${MOSQUITTO_USER}"
}

if [ "${RESET_MQTT_PASSWORD:-}" == "yes" ]; then
  if is_pve; then
    msg_error "Run this command inside the ${APP} container:"
    echo -e "         ${BL}RESET_MQTT_PASSWORD=yes update${CL}"
    exit 1
  fi
  reset_mqtt_password
  exit
fi

create_or_update
echo -e "Connect the MQTT clients to the following address:
         ${BL}$(get_ip):1883${CL}
         User: ${BL}${MOSQUITTO_USER}${CL}\n"
