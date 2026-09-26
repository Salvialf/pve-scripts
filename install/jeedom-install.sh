#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Mips2648
# Modified by: Salvialf
# License: MIT
# https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://jeedom.com/

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# Set by ct/jeedom.sh (advanced settings or command line)
BRANCH="${JEEDOM_BRANCH:-master}"
msg_ok "Installing Jeedom from branch: ${BRANCH}"

msg_info "Downloading Jeedom installation script"
cd /tmp
wget -q https://raw.githubusercontent.com/jeedom/core/"${BRANCH}"/install/install.sh
chmod +x install.sh
msg_ok "Installation script downloaded"

msg_info "Installing Jeedom main dependencies, please wait"
$STD ./install.sh -v "$BRANCH" -s 2
msg_ok "Installed Jeedom main dependencies"

msg_info "Installing database"
$STD ./install.sh -v "$BRANCH" -s 3
msg_ok "Installed database"

msg_info "Installing Apache"
$STD ./install.sh -v "$BRANCH" -s 4
msg_ok "Installed Apache"

msg_info "Installing PHP and dependencies"
$STD ./install.sh -v "$BRANCH" -s 5
msg_ok "Installed PHP"

msg_info "Downloading Jeedom core"
$STD ./install.sh -v "$BRANCH" -s 6
msg_ok "Downloaded Jeedom core"

msg_info "Customizing database"
$STD ./install.sh -v "$BRANCH" -s 7
msg_ok "Customized database"

msg_info "Customizing Jeedom"
$STD ./install.sh -v "$BRANCH" -s 8
msg_ok "Customized Jeedom"

msg_info "Configuring Jeedom"
$STD ./install.sh -v "$BRANCH" -s 9
msg_ok "Configured Jeedom"

msg_info "Installing Jeedom"
$STD ./install.sh -v "$BRANCH" -s 10
msg_ok "Installed Jeedom"

msg_info "Running post-installation steps"
$STD ./install.sh -v "$BRANCH" -s 11
msg_ok "Post-installation done"

msg_info "Checking installation"
$STD ./install.sh -v "$BRANCH" -s 12
msg_ok "Installation checked, a reboot is recommended"

motd_ssh
customize

msg_info "Cleaning up"
rm -f /tmp/install.sh
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
