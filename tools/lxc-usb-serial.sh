#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2026 Salvialf
# Author: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

LOGO=$(cat <<"EOF"
   __  _______ ____     _____           _       __
  / / / / ___// __ )   / ___/___  _____(_)___ _/ /
 / / / /\__ \/ __  |   \__ \/ _ \/ ___/ / __ `/ /
/ /_/ /___/ / /_/ /   ___/ /  __/ /  / / /_/ / /
\____//____/_____/   /____/\___/_/  /_/\__,_/_/
EOF
)
header_info
tool_variables "USB serial devices"
color
catch_errors
pve_check
root_check

# Names that stay the same across reboots and replugs, unlike ttyACM0 or ttyUSB0
USB_DEVICES="${USB_DEVICES:-}"

tool_choose_ct
# tteck's USB block and usb-passthrough.sh's hook
tool_lxc_lines '^lxc.mount.entry: /dev/(serial/by-id|ttyUSB|ttyACM)|^lxc.cgroup2.devices.allow: c (166|188|189):|^lxc.hook.autodev:'

# The checklist shows the container's devices checked: unchecking one removes it
if [ -z "$USB_DEVICES" ]; then
  declare -A keys=()
  while read -r key path; do
    if [[ "$path" == /dev/serial/by-id/* ]]; then
      keys[$path]="$key"
    fi
  done < <(tool_devices || true)

  list=()
  for path in /dev/serial/by-id/*; do
    [ -e "$path" ] || continue
    list+=("${path##*/}" "$(basename "$(readlink -f "$path")")" "$([ -n "${keys[$path]:-}" ] && echo ON || echo OFF)")
  done
  # An unplugged device stops the container from starting
  for path in "${!keys[@]}"; do
    [ -e "$path" ] || list+=("${path##*/}" "not plugged" ON)
  done
  if [ ${#list[@]} -eq 0 ]; then
    msg_error "No USB serial device found on this host"
    exit 1
  fi

  checked=$(wt --title "${TOOL_NAME^^}" --separate-output --checklist "Choose the devices to give to container $CT_ID\nUse Space to check or uncheck a device" "${list[@]}") || exit-script
  removed=""
  for path in "${!keys[@]}"; do
    if ! grep -qxF "${path##*/}" <<< "$checked"; then
      pct set "$CT_ID" -delete "${keys[$path]}"
      msg_ok "Removed ${path##*/} from container $CT_ID"
      removed="yes"
    fi
  done
  for name in $checked; do
    if [ -z "${keys[/dev/serial/by-id/$name]:-}" ]; then
      USB_DEVICES+=" $name"
    fi
  done
  # Nothing to add: offer the restart here, tool_add_devices offers it otherwise
  if [ -z "$USB_DEVICES" ]; then
    [ -n "$removed" ] || exit-script
    tool_offer_restart
    exit 0
  fi
fi

paths=()
for name in $USB_DEVICES; do
  paths+=("/dev/serial/by-id/$name")
done
# 20: the dialout group, as on the host
tool_add_devices 20 "${paths[@]}"
