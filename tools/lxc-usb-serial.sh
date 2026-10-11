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
if [ -z "$USB_DEVICES" ]; then
  list=()
  for path in /dev/serial/by-id/*; do
    [ -e "$path" ] || continue
    list+=("${path##*/}" "$(basename "$(readlink -f "$path")")" OFF)
  done
  if [ ${#list[@]} -eq 0 ]; then
    msg_error "No USB serial device found on this host"
    exit 1
  fi
fi

tool_choose_ct
config=$(pct config "$CT_ID")
# These older methods already pass every device, and devN on top of them could stop the container from starting
if grep -Eq '^lxc.mount.entry: /dev/serial/by-id |^lxc.hook.autodev:' <<< "$config"; then
  msg_warn "Container $CT_ID already gets every USB serial device through lxc.* lines, remove them to use device passthrough instead"
  exit 0
fi

if [ -z "$USB_DEVICES" ]; then
  USB_DEVICES=$(wt --title "${TOOL_NAME^^}" --separate-output --checklist "Choose the devices to give to container $CT_ID\nUse Space to select a device" "${list[@]}") || exit-script
  if [ -z "$USB_DEVICES" ]; then
    exit-script
  fi
fi

paths=()
for name in $USB_DEVICES; do
  paths+=("/dev/serial/by-id/$name")
done
# 20: the dialout group, as on the host
tool_add_devices 20 "${paths[@]}"
