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

function app_settings() {
  local branch_list branch branches=()
  # Preselect a branch passed on the command line
  local provided="${JEEDOM_BRANCH:-}" preselect=() other_preselect=()
  case "$provided" in
    "") ;;
    master | release | develop) preselect=(--default-item "$provided") ;;
    *) preselect=(--default-item "other"); other_preselect=(--default-item "$provided") ;;
  esac

  JEEDOM_BRANCH=$(wt --title "JEEDOM BRANCH" "${preselect[@]}" --menu "Choose the Jeedom branch to install" \
    "master" "Stable" \
    "release" "Pre-release" \
    "develop" "Development" \
    "other" "Other branch") || exit-script

  if [ "$JEEDOM_BRANCH" == "other" ]; then
    # alpha, beta and V4-stable are obsolete but still on the repo
    branch_list=$(curl -fsSL "https://api.github.com/repos/jeedom/core/branches?per_page=100" \
      | grep -o '"name": *"[^"]*"' | cut -d'"' -f4 \
      | grep -vxE 'master|release|develop|alpha|beta|V4-stable' || true)
    for branch in $branch_list; do
      branches+=("$branch" "")
    done

    if [ ${#branches[@]} -gt 0 ]; then
      JEEDOM_BRANCH=$(wt --title "JEEDOM BRANCH" "${other_preselect[@]}" --menu "Choose another branch (not supported)" \
        "${branches[@]}") || exit-script
    else
      while true; do
        JEEDOM_BRANCH=$(wt --title "JEEDOM BRANCH" --inputbox "Set the branch name\nBranch list unavailable") || exit-script
        jeedom_branch_exists "$JEEDOM_BRANCH" && break
        wt --title "JEEDOM BRANCH" --msgbox "Branch '${JEEDOM_BRANCH}' not found"
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
