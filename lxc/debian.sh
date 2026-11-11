#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

LOGO=$(cat <<"EOF"
    ____       __    _
   / __ \___  / /_  (_)___  ____
  / / / / _ \/ __ \/ / __ `/ __ \
 / /_/ /  __/ /_/ / / /_/ / / / /
/_____/\___/_.___/_/\__,_/_/ /_/
EOF
)
APP="Debian"
var_os_supported="debian"
var_color_primary="color125"
init_script
create_or_update
