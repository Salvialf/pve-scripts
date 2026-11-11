#!/usr/bin/env bash
COMMON_FUNC=$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lib/common.func) || { echo "Unable to download common.func"; exit 1; }
source /dev/stdin <<< "$COMMON_FUNC"
# Copyright (c) 2021-2024 tteck
# Copyright (c) 2026 Salvialf
# Author: tteck (tteckster) | Salvialf
# License: MIT | https://github.com/Salvialf/pve-scripts/raw/main/LICENSE

LOGO=$(cat <<"EOF"
    ____ _    ________   ____             __     ____           __        ____
   / __ \ |  / / ____/  / __ \____  _____/ /_   /  _/___  _____/ /_____ _/ / /
  / /_/ / | / / __/    / /_/ / __ \/ ___/ __/   / // __ \/ ___/ __/ __ `/ / /
 / ____/| |/ / /___   / ____/ /_/ (__  ) /_   _/ // / / (__  ) /_/ /_/ / / /
/_/     |___/_____/  /_/    \____/____/\__/  /___/_/ /_/____/\__/\__,_/_/_/
EOF
)
TOOL_NAME="Post install"
init_tool
# Its update runs long, a dropped SSH session would cut it
ssh_check

if ! pveversion | grep -q "pve-manager/9\."; then
  msg_error "This tool requires Proxmox VE 9, upgrade first"
  exit 1
fi

# No spinner over apt's output: dpkg may ask about a configuration file changed on this host
VERBOSE="yes"

# The API behind the APT Repositories panel, so the files are changed as its buttons would
REPOS_API=/nodes/localhost/apt/repositories
PROXMOXLIB=/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
# The usual hook name of post-install scripts, so ours replaces an older one
NAG_HOOK=/etc/apt/apt.conf.d/no-nag-script
NAG_SCRIPT=/usr/local/sbin/pve-scripts-no-nag

# Enabled entries served by enterprise.proxmox.com, one "file index" line each
enterprise_repos() {
  pvesh get "$REPOS_API" --output-format json | perl -MJSON::PP -0777 -ne '
    for my $file (@{decode_json($_)->{files}}) {
      my $index = 0;
      for my $repo (@{$file->{repositories}}) {
        print "$file->{path} $index\n" if $repo->{Enabled} && grep { m{^https://enterprise\.proxmox\.com/} } @{$repo->{URIs}};
        $index++;
      }
    }'
}

subscription_active() {
  pvesh get /nodes/localhost/subscription --output-format json | perl -MJSON::PP -0777 -ne '
    exit(decode_json($_)->{status} !~ /^active$/i)'
}

nosub_enabled() {
  pvesh get "$REPOS_API" --output-format json | perl -MJSON::PP -0777 -ne '
    exit !grep { $_->{handle} eq "no-subscription" && $_->{status} } @{decode_json($_)->{"standard-repos"}}'
}

# HA can do nothing on a single node, and without HA resources the watchdog is not armed
ha_removable() {
  [ ! -f /etc/pve/corosync.conf ] || return 1
  [ -z "$(ha-manager config)" ] || return 1
  systemctl is-enabled -q pve-ha-lrm || systemctl is-enabled -q pve-ha-crm
}

items=()
# With a subscription, the enterprise repositories work and the popup doesn't show
if ! subscription_active; then
  enterprise=$(enterprise_repos)
  if [ -n "$enterprise" ]; then
    items+=(enterprise "Disable the enterprise repositories" ON)
  fi
  if ! nosub_enabled; then
    items+=(nosub "Enable the no-subscription repository" ON)
  fi
  if ! grep -qF "$NAG_SCRIPT" "$NAG_HOOK" 2>/dev/null; then
    items+=(nag "Remove the subscription popup" ON)
  fi
fi
if ha_removable; then
  items+=(ha "Disable high availability (single node)" ON)
fi
items+=(update "Update Proxmox VE" ON)

selected=$(wt --title "${TOOL_NAME^^}" --notags --separate-output --checklist "Choose what to apply\nUse Space to check or uncheck an item" "${items[@]}") || exit-script
if [ -z "$selected" ]; then
  exit-script
fi
chosen() {
  grep -qx "$1" <<< "$selected"
}

if chosen enterprise; then
  while read -r path index; do
    pvesh create "$REPOS_API" --path "$path" --index "$index" --enabled 0 >/dev/null
  done <<< "$enterprise"
  msg_ok "Disabled the enterprise repositories"
fi

if chosen nosub; then
  pvesh set "$REPOS_API" --handle no-subscription >/dev/null
  msg_ok "Enabled the no-subscription repository"
fi

if chosen nag; then
  cat >"$NAG_SCRIPT" <<'EOF'
#!/bin/sh
# Installed by pve-scripts' pve-post-install, run by apt after each package change
# The subscription popup comes from checked_command: make it run the requested action right away
JS=/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
FUNC="checked_command: function (orig_cmd) {"
PATCH="orig_cmd(); return; /* pve-scripts no-nag */"
grep -qF "$PATCH" "$JS" && exit 0
if ! grep -qF "$FUNC" "$JS"; then
  echo "pve-scripts-no-nag: checked_command not found, subscription popup not removed"
  exit 0
fi
sed -i "s|$FUNC|& $PATCH|" "$JS"
EOF
  chmod 755 "$NAG_SCRIPT"
  echo "DPkg::Post-Invoke { \"$NAG_SCRIPT\"; };" >"$NAG_HOOK"
  # The NoMoreNagging patch of other post-install scripts also hides the APT panel's warning: start again from Proxmox's file
  if grep -q NoMoreNagging "$PROXMOXLIB"; then
    apt-get update -qq
    apt-get install --reinstall -y -qq proxmox-widget-toolkit
  fi
  "$NAG_SCRIPT"
  msg_ok "Removed the subscription popup"
fi

if chosen ha; then
  systemctl disable -q --now pve-ha-lrm pve-ha-crm
  msg_ok "Disabled high availability"
fi

updated=""
if chosen update; then
  msg_info "Updating Proxmox VE"
  # dpkg records every installed package in this file
  packages=$(md5sum /var/lib/dpkg/status)
  apt-get update
  apt-get -y dist-upgrade
  if [ "$(md5sum /var/lib/dpkg/status)" != "$packages" ]; then
    updated="yes"
    msg_ok "Updated Proxmox VE"
  else
    msg_ok "Proxmox VE was already up to date"
  fi
fi

if chosen nag; then
  msg_warn "Reload the web interface without cache (Ctrl+F5) to stop seeing the popup"
fi
if chosen ha; then
  msg_warn "If this node joins a cluster, enable high availability again with: systemctl enable --now pve-ha-crm pve-ha-lrm"
fi
if [ -n "$updated" ]; then
  if wt --title "${TOOL_NAME^^}" --yesno "Reboot Proxmox VE now?\nRecommended after an update"; then
    msg_ok "Rebooting Proxmox VE"
    reboot
  else
    msg_warn "Reboot Proxmox VE later to complete the update"
  fi
fi
