# Caddy LXC

[Caddy](https://caddyserver.com/) is a web server and reverse proxy that gets and renews its HTTPS certificates on its own. This script installs it from Caddy's official Debian repository.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/caddy.sh)"
```

A reverse proxy must keep its address, the router forwards ports to it: set a fixed IP in the Network settings, or reserve the container's address on the router once it is created.

At the end, the script shows the address of Caddy's default page, on port `80`.

## Default settings

| Setting | Value |
|---|---|
| OS | Debian 13 |
| CPU | 1 vCPU |
| RAM | 512 MiB |
| Disk | 2 GiB |
| Network | DHCP on `vmbr0` |
| Container | Unprivileged, starts at boot, root autologin on the console |

> [!NOTE]
> Other Debian versions and Ubuntu are available in the General settings.

## Configuration

Caddy reads `/etc/caddy/Caddyfile`. After a change, apply it without interrupting the sites:

```bash
systemctl reload caddy
```

## Backup

To back up Caddy, keep a copy of `/etc/caddy/Caddyfile` (its configuration) and `/var/lib/caddy/.local/share/caddy` (its certificates, which Caddy would otherwise request again).

## Update

Running `update` from the container's console upgrades the OS packages, Caddy included, from Caddy's repository.

## Credits

Originally written by [tteck](https://github.com/tteck) for [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox).
