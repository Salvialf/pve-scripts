#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Copyright (c) 2026 Salvialf
# Author: tteck (tteckster) | Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://github.com/dani-garcia/vaultwarden

source /dev/stdin <<< "$COMMON_FUNC"
source /dev/stdin <<< "$INSTALL_FUNC"
prepare_container

msg_info "Installing Vaultwarden"
install_packages vaultwarden vaultwarden-web-vault
# Appended rather than edited: the last definition wins, whatever lines the package ships
cat <<EOF >>/etc/conf.d/vaultwarden

# Added by pve-scripts
export ROCKET_ADDRESS=0.0.0.0
export WEB_VAULT_ENABLED=true
EOF
msg_ok "Installed Vaultwarden"

# VAULTWARDEN_HTTPS and VAULTWARDEN_ADMIN_TOKEN are exported by lxc/vaultwarden.sh
if [ "$VAULTWARDEN_HTTPS" == "self-signed" ]; then
  msg_info "Creating a self-signed certificate"
  install_packages openssl
  mkdir -p /etc/ssl/vaultwarden
  # Rocket needs an RSA key; 825 days is the longest validity Apple devices accept
  $STD openssl req -x509 -newkey rsa:2048 -sha256 -days 825 -nodes \
    -keyout /etc/ssl/vaultwarden/key.pem -out /etc/ssl/vaultwarden/cert.pem -subj "/CN=$(hostname)"
  chown root:vaultwarden /etc/ssl/vaultwarden/key.pem
  chmod 640 /etc/ssl/vaultwarden/key.pem
  echo "export ROCKET_TLS='{certs=\"/etc/ssl/vaultwarden/cert.pem\",key=\"/etc/ssl/vaultwarden/key.pem\"}'" >>/etc/conf.d/vaultwarden
  msg_ok "Created a self-signed certificate"
fi

if [ -n "$VAULTWARDEN_ADMIN_TOKEN" ]; then
  msg_info "Setting the admin token"
  install_packages argon2
  # Settings recommended by the Vaultwarden wiki (OWASP)
  hash=$(printf '%s' "$VAULTWARDEN_ADMIN_TOKEN" | argon2 "$(head -c 32 /dev/urandom | base64)" -e -id -k 19456 -t 2 -p 1)
  echo "export ADMIN_TOKEN='${hash}'" >>/etc/conf.d/vaultwarden
  msg_ok "Set the admin token"
fi

enable_service vaultwarden

finish_container
