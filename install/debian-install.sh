#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

source /dev/stdin <<< "$COMMON_FUNC"
source /dev/stdin <<< "$INSTALL_FUNC"
prepare_container
finish_container
