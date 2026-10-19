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
tool_choose_ct

# The Proxmox wiki's lines (folder mount) and tteck's (file mount)
tool_lxc_lines '^lxc.mount.entry: /dev/net(/tun)? |^lxc.cgroup2.devices.allow: c 10:200 '

key=$(tool_device_key /dev/net/tun)
if [ -n "$key" ]; then
  wt --title "${TOOL_NAME^^}" --defaultno --yesno "Container $CT_ID already has the TUN device.\nRemove it?" || exit-script
  pct set "$CT_ID" -delete "$key"
  msg_ok "Removed the TUN device from container $CT_ID"
  tool_offer_restart
  exit 0
fi

# 0666 as on the host
tool_add_device /dev/net/tun,mode=0666
msg_ok "Gave the TUN device to container $CT_ID"
tool_offer_restart
