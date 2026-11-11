#!/usr/bin/env bash
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Mips2648
# Modified by: Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://jeedom.com/

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
prepare_container

msg_info "Downloading Jeedom installation script"
cd /tmp
# JEEDOM_BRANCH is exported by lxc/jeedom.sh
curl -fsSL -o install.sh https://raw.githubusercontent.com/jeedom/core/"${JEEDOM_BRANCH}"/install/install.sh
chmod +x install.sh
msg_ok "Downloaded Jeedom installation script"

msg_info "Installing Jeedom main dependencies, please wait"
$STD ./install.sh -v "$JEEDOM_BRANCH" -s 2
# Temporary python3-venv manual install until https://github.com/jeedom/core/pull/3535 is on master
$STD apt-get install -y python3-venv
msg_ok "Installed Jeedom main dependencies"

msg_info "Installing MariaDB"
$STD ./install.sh -v "$JEEDOM_BRANCH" -s 3
msg_ok "Installed MariaDB"

msg_info "Installing Apache"
$STD ./install.sh -v "$JEEDOM_BRANCH" -s 4
msg_ok "Installed Apache"

msg_info "Installing PHP and its extensions"
$STD ./install.sh -v "$JEEDOM_BRANCH" -s 5
msg_ok "Installed PHP and its extensions"

msg_info "Downloading Jeedom core"
$STD ./install.sh -v "$JEEDOM_BRANCH" -s 6
msg_ok "Downloaded Jeedom core"

msg_info "Configuring MariaDB"
$STD ./install.sh -v "$JEEDOM_BRANCH" -s 7
msg_ok "Configured MariaDB"

msg_info "Configuring Apache and PHP"
$STD ./install.sh -v "$JEEDOM_BRANCH" -s 8
msg_ok "Configured Apache and PHP"

msg_info "Configuring Jeedom"
$STD ./install.sh -v "$JEEDOM_BRANCH" -s 9
msg_ok "Configured Jeedom"

msg_info "Installing Jeedom"
$STD ./install.sh -v "$JEEDOM_BRANCH" -s 10
msg_ok "Installed Jeedom"

msg_info "Finishing the Jeedom installation"
$STD ./install.sh -v "$JEEDOM_BRANCH" -s 11
msg_ok "Finished the Jeedom installation"

msg_info "Checking the Jeedom installation"
$STD ./install.sh -v "$JEEDOM_BRANCH" -s 12
# Temporary reboot hint until https://github.com/jeedom/core/pull/3544 is on master
msg_ok "Checked the Jeedom installation, a reboot is recommended"

rm -f /tmp/install.sh

finish_container
