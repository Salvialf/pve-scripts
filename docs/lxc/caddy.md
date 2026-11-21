# Caddy LXC

[Caddy](https://caddyserver.com/) is a web server and reverse proxy that gets and renews its HTTPS certificates on its own. This script installs it from Caddy's official repository on Debian and Ubuntu and from the distribution's `caddy` package on Alpine.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/caddy.sh)"
```

A reverse proxy must keep its address, the router forwards ports to it: set a fixed IP in the Network settings, or reserve the container's address on the router once it is created.

At the end, the script shows where Caddy's configuration file is, see [Configuration](#configuration).

## Default settings

| Setting | Value |
|---|---|
| OS | Latest Debian |
| CPU | 1 vCPU |
| RAM | 512 MiB (256 MiB on Alpine) |
| Disk | 2 GiB (1 GiB on Alpine) |
| Network | DHCP on `vmbr0` |
| Container | Unprivileged, starts at boot, root autologin on the console |

> [!NOTE]
> Other Debian versions, Ubuntu and Alpine are available in the General settings.

## Configuration

Caddy reads `/etc/caddy/Caddyfile`. After a change, apply it without interrupting the sites:

- Debian and Ubuntu: `systemctl reload caddy`
- Alpine: `rc-service caddy reload`

## Backup

To back up Caddy, keep a copy of `/etc/caddy/Caddyfile` (its configuration) and `/var/lib/caddy/.local/share/caddy` (its certificates, which Caddy would otherwise request again).

## Update

Running `update` from the container's console upgrades the OS packages, Caddy included. On Alpine, Caddy comes from the distribution's repository, which publishes new versions later and only for its latest release: when `update` offers to move to a newer release, back up the container and accept it, otherwise Caddy stops getting updates.

## Credits

Originally written by [tteck](https://github.com/tteck) for [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox).
