#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

LOGO=$(cat <<"EOF"
   __  ____                __
  / / / / /_  __  ______  / /___  __
 / / / / __ \/ / / / __ \/ __/ / / /
/ /_/ / /_/ / /_/ / / / / /_/ /_/ /
\____/_.___/\__,_/_/ /_/\__/\__,_/
EOF
)
APP="Ubuntu"
var_os_supported="ubuntu"
var_color_primary="color166"
init_script
create_or_update
