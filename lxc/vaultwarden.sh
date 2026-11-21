#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Copyright (c) 2026 Salvialf
# Author: tteck (tteckster) | Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://github.com/dani-garcia/vaultwarden

COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"

LOGO=$(cat <<"EOF"
 _    __            ____                          __
| |  / /___ ___  __/ / /__      ______ __________/ /__  ____
| | / / __ `/ / / / / __/ | /| / / __ `/ ___/ __  / _ \/ __ \
| |/ / /_/ / /_/ / / /_ | |/ |/ / /_/ / /  / /_/ /  __/ / / /
|___/\__,_/\__,_/_/\__/ |__/|__/\__,_/_/   \__,_/\___/_/ /_/
EOF
)
APP="Vaultwarden"
# Debian has no package, building it needs several GB of RAM at each update
var_os_supported="alpine"
var_onboot="yes"
var_color_primary="color26"
app_settings=(step_vaultwarden_https step_vaultwarden_admin_token)
init_script

function step_vaultwarden_https() {
  local https
  https=$(wt --title "HTTPS" --notags --default-item "$VAULTWARDEN_HTTPS" --menu "How does Vaultwarden get HTTPS?\nBrowsers refuse plain HTTP and apps need a real certificate\nA reverse proxy such as the Caddy LXC can provide one" \
    "self-signed" "Self-signed certificate (web vault only)" \
    "proxy" "Separate reverse proxy (recommended)") || return
  VAULTWARDEN_HTTPS="$https"
}

function step_vaultwarden_admin_token() {
  local token
  token=$(ask_password "ADMIN TOKEN" "Set the token of the admin page (/admin)\nBlank disables the admin page" "$VAULTWARDEN_ADMIN_TOKEN") || return
  VAULTWARDEN_ADMIN_TOKEN="$token"
}

function app_default_settings() {
  export VAULTWARDEN_HTTPS="self-signed" VAULTWARDEN_ADMIN_TOKEN=""
}

function app_summary() {
  echo "HTTPS: $([ "$VAULTWARDEN_HTTPS" == "proxy" ] && echo "reverse proxy" || echo "self-signed certificate")"
  echo "Admin page: $([ -n "$VAULTWARDEN_ADMIN_TOKEN" ] && echo "token set" || echo "disabled (no token)")"
}

function app_description() {
  echo "**Admin token:** run \`RESET_ADMIN_TOKEN=yes update\` in the container's console."
}

# Alpine doesn't restart a service when its package is upgraded
function app_update() {
  msg_info "Restarting ${APP}"
  $STD rc-service vaultwarden restart
  msg_ok "Restarted ${APP}"
}

# Run by RESET_ADMIN_TOKEN=yes update, blank disables the admin page
function reset_admin_token() {
  if [ ! -f /etc/conf.d/vaultwarden ]; then
    msg_error "No ${APP} installation found"
    exit 1
  fi
  local hash config=/var/lib/vaultwarden/config.json
  VAULTWARDEN_ADMIN_TOKEN=""
  step_vaultwarden_admin_token || exit-script
  std_mode
  msg_info "Setting the admin token"
  sed -i '/^export ADMIN_TOKEN=/d' /etc/conf.d/vaultwarden
  if [ -n "$VAULTWARDEN_ADMIN_TOKEN" ]; then
    $STD apk add argon2
    # Settings recommended by the Vaultwarden wiki (OWASP)
    hash=$(printf '%s' "$VAULTWARDEN_ADMIN_TOKEN" | argon2 "$(head -c 32 /dev/urandom | base64)" -e -id -k 19456 -t 2 -p 1)
    echo "export ADMIN_TOKEN='${hash}'" >>/etc/conf.d/vaultwarden
  fi
  # Saving the admin page writes the token to config.json, which overrides conf.d
  if [ -f "$config" ]; then
    $STD apk add jq
    jq 'del(.admin_token)' "$config" >/tmp/config.json
    # Rewritten in place, so the file keeps its owner
    cat /tmp/config.json >"$config"
    rm /tmp/config.json
  fi
  $STD rc-service vaultwarden restart
  if [ -n "$VAULTWARDEN_ADMIN_TOKEN" ]; then
    msg_ok "Set the admin token"
  else
    msg_ok "Disabled the admin page"
  fi
}

if [ "${RESET_ADMIN_TOKEN:-}" == "yes" ]; then
  if command -v pveversion >/dev/null 2>&1; then
    msg_error "Run RESET_ADMIN_TOKEN=yes update inside the ${APP} container"
    exit 1
  fi
  reset_admin_token
  exit
fi

create_or_update
if [ "$VAULTWARDEN_HTTPS" == "proxy" ]; then
  echo -e "Point your reverse proxy at the following address:
         ${BL}$(get_ip):8000${CL}
         Then open ${APP} at your reverse proxy's HTTPS address\n"
else
  echo -e "Access ${APP} at the following URL:
         ${BL}https://$(get_ip):8000${CL}
         Accept the browser's warning about the self-signed certificate\n"
fi
