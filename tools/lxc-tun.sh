#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2026 Salvialf
# Author: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

# Lines from https://pve.proxmox.com/wiki/OpenVPN_in_LXC, without its chown of /dev/net/tun: already 0666 on the host

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

lines=()
if ! grep -q '^lxc.cgroup2.devices.allow: c 10:200 rwm' "$conf"; then
  lines+=("lxc.cgroup2.devices.allow: c 10:200 rwm")
fi
if ! grep -q '^lxc.mount.entry: /dev/net' "$conf"; then
  lines+=("lxc.mount.entry: /dev/net dev/net none bind,create=dir")
fi
if [ ${#lines[@]} -eq 0 ]; then
  msg_ok "Container $CT_ID already has the TUN device"
  exit 0
fi

# Before the first [section]: what follows it belongs to a snapshot or to the pending changes
new_conf=$(TUN_LINES="$(printf '%s\n' "${lines[@]}")" awk '
  !done && /^\[/ { print ENVIRON["TUN_LINES"]; done = 1 }
  { print }
  END { if (!done) print ENVIRON["TUN_LINES"] }' "$conf")
echo "$new_conf" > "$conf"
msg_ok "Gave the TUN device to container $CT_ID"

# The LXC configuration is only read when the container starts
if pct status "$CT_ID" | grep -q running; then
  if wt --title "TUN DEVICE" --yesno "Container $CT_ID is running, the TUN device only\napplies after a restart. Restart it now?"; then
    msg_info "Restarting container $CT_ID"
    pct reboot "$CT_ID"
    msg_ok "Restarted container $CT_ID"
  else
    msg_warn "Restart container $CT_ID to apply"
  fi
fi
