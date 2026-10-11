#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2026 Salvialf
# Author: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

LOGO=$(cat <<"EOF"
  ________  ___   __   ____            _
 /_  __/ / / / | / /  / __ \___ _   __(_)_______
  / / / / / /  |/ /  / / / / _ \ | / / / ___/ _ \
 / / / /_/ / /|  /  / /_/ /  __/ |/ / / /__/  __/
/_/  \____/_/ |_/  /_____/\___/|___/_/\___/\___/
EOF
)
header_info
tool_variables "TUN device"
color
catch_errors
pve_check
root_check

CT_ID="${CT_ID:-}"
if [ -z "$CT_ID" ]; then
  menu=()
  # pct list columns: VMID Status Lock Name, Lock often empty
  while read -r id status name; do
    menu+=("$id" "$name ($status)")
  done < <(pct list | awk 'NR > 1 {print $1, $2, $NF}' || true)
  if [ ${#menu[@]} -eq 0 ]; then
    msg_error "No container found on this host"
    exit 1
  fi
  CT_ID=$(wt --title "TUN DEVICE" --menu "Choose the container to give the TUN device to" "${menu[@]}") || exit-script
fi

conf="/etc/pve/lxc/${CT_ID}.conf"
if [ ! -f "$conf" ]; then
  msg_error "Container $CT_ID not found"
  exit 1
fi

# What follows the first [section] belongs to a snapshot or to the pending changes
current_config=$(awk '/^\[/ {exit} {print}' "$conf")
# A device passthrough, or the lxc lines this tool used to write
if grep -Eq '^dev[0-9]+: (path=)?/dev/net/tun(,|$)|^lxc.mount.entry: /dev/net(/tun)? ' <<< "$current_config"; then
  msg_ok "Container $CT_ID already has the TUN device"
  exit 0
fi

index=0
while grep -q "^dev$index:" <<< "$current_config"; do
  index=$((index + 1))
done
# Proxmox's device passthrough, shown in the container's Resources. 0666 as on the host
pct set "$CT_ID" "-dev$index" /dev/net/tun,mode=0666
msg_ok "Gave the TUN device to container $CT_ID"

# Passthrough devices are only added when the container starts
if pct status "$CT_ID" | grep -q running; then
  if wt --title "TUN DEVICE" --yesno "Container $CT_ID is running, the TUN device only\napplies after a restart. Restart it now?"; then
    msg_info "Restarting container $CT_ID"
    pct reboot "$CT_ID"
    msg_ok "Restarted container $CT_ID"
  else
    msg_warn "Restart container $CT_ID to apply"
  fi
fi
