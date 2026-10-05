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
var_color_primary="color106"
var_color_theme="dark"
app_settings=(step_jeedom_branch step_jeedom_other_branch)
# From the command line, if any
DEFAULT_JEEDOM_BRANCH="${JEEDOM_BRANCH:-master}"
variables
color
catch_errors

function step_jeedom_branch() {
  local choice="${JEEDOM_BRANCH_CHOICE:-$DEFAULT_JEEDOM_BRANCH}"
  case "$choice" in
    master | release | develop | other) ;;
    *) choice="other" ;;
  esac
  choice=$(wt --title "JEEDOM BRANCH" --notags --default-item "$choice" --menu "Choose the Jeedom branch to install" \
    "master" "Stable (master)" \
    "release" "Pre-release (release)" \
    "develop" "Development (develop)" \
    "other" "Other branch") || return
  JEEDOM_BRANCH_CHOICE="$choice"
  if [ "$choice" != "other" ]; then
    export JEEDOM_BRANCH="$choice"
  fi
}

function step_jeedom_other_branch() {
  if [ "${JEEDOM_BRANCH_CHOICE:-}" != "other" ]; then
    return 2
  fi
  local branches=() name branch
  if [ -z "${JEEDOM_BRANCH_LIST:-}" ]; then
    # alpha, beta and V4-stable are obsolete but still on the repo
    JEEDOM_BRANCH_LIST=$(curl -fsSL "https://api.github.com/repos/jeedom/core/branches?per_page=100" \
      | grep -o '"name": *"[^"]*"' | cut -d'"' -f4 \
      | grep -vxE 'master|release|develop|alpha|beta|V4-stable' || true)
  fi
  for name in $JEEDOM_BRANCH_LIST; do
    branches+=("$name" "$name")
  done

  if [ ${#branches[@]} -gt 0 ]; then
    branch=$(wt --title "JEEDOM BRANCH" --notags --default-item "$JEEDOM_BRANCH" --menu "Choose another branch (not supported)" \
      "${branches[@]}") || return
  else
    branch="$JEEDOM_BRANCH"
    while true; do
      branch=$(wt --title "JEEDOM BRANCH" --inputbox "Set the branch name\nBranch list unavailable" "$branch") || return
      jeedom_branch_exists "$branch" && break
      wt --title "JEEDOM BRANCH" --msgbox "Branch '${branch}' not found"
    done
  fi
  export JEEDOM_BRANCH="$branch"
}

function app_default_settings() {
  export JEEDOM_BRANCH="$DEFAULT_JEEDOM_BRANCH"
}

function app_summary() {
  echo "Jeedom branch: $JEEDOM_BRANCH"
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
