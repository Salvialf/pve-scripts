#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Mips2648
# Modified by: Salvialf
# License: MIT
# https://github.com/Salvialf/pve-scripts/raw/main/LICENSE
# Source: https://jeedom.com/

function header_info {
clear
cat <<"EOF"
       __              __
      / /__  ___  ____/ /___  ____ ___
 __  / / _ \/ _ \/ __  / __ \/ __ `__ \
/ /_/ /  __/  __/ /_/ / /_/ / / / / / /
\____/\___/\___/\__,_/\____/_/ /_/ /_/

EOF
}
header_info
echo -e "Loading..."
APP="Jeedom"
var_disk="16"
var_cpu="2"
var_ram="2048"
var_os="debian"
var_os_locked="yes"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function app_settings() {
  local branch_list branch branches=()
  # Preselect a branch passed on the command line
  local provided="${JEEDOM_BRANCH:-}" preselect=() other_preselect=()
  case "$provided" in
    "") ;;
    master | release | develop) preselect=(--default-item "$provided") ;;
    *) preselect=(--default-item "other"); other_preselect=(--default-item "$provided") ;;
  esac

  JEEDOM_BRANCH=$(whiptail --backtitle "Salvialf PVE scripts" --title "JEEDOM BRANCH" "${preselect[@]}" --menu "Choose the Jeedom branch to install" 14 58 4 \
    "master" "Stable" \
    "release" "Pre-release" \
    "develop" "Development" \
    "other" "Other branch" \
    3>&1 1>&2 2>&3) || exit-script

  if [ "$JEEDOM_BRANCH" == "other" ]; then
    # alpha, beta and V4-stable are obsolete but still on the repo
    branch_list=$(curl -fsSL "https://api.github.com/repos/jeedom/core/branches?per_page=100" \
      | grep -o '"name": *"[^"]*"' | cut -d'"' -f4 \
      | grep -vxE 'master|release|develop|alpha|beta|V4-stable' || true)
    for branch in $branch_list; do
      branches+=("$branch" "")
    done

    if [ ${#branches[@]} -gt 0 ]; then
      JEEDOM_BRANCH=$(whiptail --backtitle "Salvialf PVE scripts" --title "JEEDOM BRANCH" "${other_preselect[@]}" --menu "Choose another branch (not supported)" 20 70 12 \
        "${branches[@]}" \
        3>&1 1>&2 2>&3) || exit-script
    else
      while true; do
        JEEDOM_BRANCH=$(whiptail --backtitle "Salvialf PVE scripts" --title "JEEDOM BRANCH" --inputbox "Branch list unavailable, enter the branch name" 8 58 3>&1 1>&2 2>&3) || exit-script
        jeedom_branch_exists "$JEEDOM_BRANCH" && break
        whiptail --backtitle "Salvialf PVE scripts" --title "JEEDOM BRANCH" --msgbox "Branch '${JEEDOM_BRANCH}' not found" 8 58
      done
    fi
  fi

  export JEEDOM_BRANCH
  echo -e "${DGN}Using Jeedom Branch: ${BGN}$JEEDOM_BRANCH${CL}"
}

function jeedom_branch_exists() {
  curl -fsI "https://raw.githubusercontent.com/jeedom/core/${1}/install/install.sh" >/dev/null
}

function update_script() {
header_info
if [[ ! -f /var/www/html/core/config/version ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP LXC OS packages"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated $APP LXC OS packages"
echo -e "You can now update Jeedom itself from its Web UI."
exit
}

# JEEDOM_BRANCH can be passed on the command line, catch a typo before creating anything
if [ -n "${JEEDOM_BRANCH:-}" ] && ! jeedom_branch_exists "$JEEDOM_BRANCH"; then
  msg_error "Jeedom branch '${JEEDOM_BRANCH}' not found"
  exit 1
fi

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "Access ${APP} at the following URL:
         ${BL}http://$(get_ip)${CL}
         Default login: ${BL}admin${CL}/${BL}admin${CL}\n"
