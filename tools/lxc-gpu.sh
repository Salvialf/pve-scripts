#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2026 Salvialf
# Author: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

LOGO=$(cat <<"EOF"
   __________  __  __   ____            _
  / ____/ __ \/ / / /  / __ \___ _   __(_)_______
 / / __/ /_/ / / / /  / / / / _ \ | / / / ___/ _ \
/ /_/ / ____/ /_/ /  / /_/ /  __/ |/ / / /__/  __/
\____/_/    \____/  /_____/\___/|___/_/\___/\___/
EOF
)
header_info
tool_variables "GPU device"
color
catch_errors
pve_check
root_check

# The render node is all video transcoding and AI apps need, card0 would also give the host's display
GPU_DEVICE="${GPU_DEVICE:-}"
if [ -z "$GPU_DEVICE" ]; then
  menu=()
  for path in /dev/dri/renderD*; do
    [ -e "$path" ] || continue
    menu+=("${path##*/}" "$(gpu_vendor "${path##*/}")")
  done
  if [ ${#menu[@]} -eq 0 ]; then
    msg_error "No GPU render device found on this host"
    exit 1
  fi
fi

tool_choose_ct
# tteck's VAAPI block, the framebuffer included
tool_lxc_lines '^lxc.mount.entry: /dev/(dri|fb0)|^lxc.cgroup2.devices.allow: c (226|29):'

if [ -z "$GPU_DEVICE" ]; then
  # A single GPU (one name and its vendor in the menu): no question
  if [ ${#menu[@]} -eq 2 ]; then
    GPU_DEVICE="${menu[0]}"
  else
    GPU_DEVICE=$(wt --title "${TOOL_NAME^^}" --menu "Choose the GPU to give to container $CT_ID" "${menu[@]}") || exit-script
  fi
fi

key=$(tool_device_key "/dev/dri/$GPU_DEVICE")
if [ -n "$key" ]; then
  wt --title "${TOOL_NAME^^}" --defaultno --yesno "Container $CT_ID already has $GPU_DEVICE.\nRemove it?" || exit-script
  pct set "$CT_ID" -delete "$key"
  msg_ok "Removed $GPU_DEVICE from container $CT_ID"
  tool_offer_restart
  exit 0
fi

# 44: the video group, the same in every Debian and Ubuntu, unlike render
tool_add_devices 44 "/dev/dri/$GPU_DEVICE"
