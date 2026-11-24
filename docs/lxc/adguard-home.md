# AdGuard Home LXC

[AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) is a DNS server that blocks ads and trackers for every device of the network that uses it. This script installs AdGuard's official release, set up as a service the way AdGuard's own install script does.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/adguard-home.sh)"
```

A DNS server must keep its address: set a fixed IP in the Network settings, or reserve the container's address on the router once it is created.

At the end, the script shows the address of AdGuard Home's setup wizard, on port `3000`: create the admin account and choose the ports there. The web interface then moves to the port chosen in the wizard, `80` by default, so the container's address alone opens it.

Once AdGuard Home is set up, set the container's address as the DNS server in the router's DHCP settings. If the network uses IPv6, keep IPv6 enabled in the container and set its IPv6 address as the router's IPv6 DNS server.

## Default settings

| Setting | Value |
|---|---|
| OS | Latest Debian |
| CPU | 1 vCPU |
| RAM | 512 MiB (256 MiB on Alpine) |
| Disk | 3 GiB (2 GiB on Alpine) |
| Network | DHCP on `vmbr0` |
| Container | Unprivileged, starts at boot, root autologin on the console |

> [!NOTE]
> Other Debian versions, Ubuntu and Alpine are available in the General settings.

## Backup and restore

Back up the container with Proxmox VE. To restore AdGuard Home in a new container, for example on another distribution, choose this backup in the **Based on** settings and answer Yes to restoring the AdGuard Home data: its settings (`/opt/AdGuardHome/AdGuardHome.yaml`) and its statistics, query log and filter lists (`/opt/AdGuardHome/data`) are copied.

> [!NOTE]
> When the AdGuard Home data is restored there is no setup wizard on port `3000`: the web interface opens directly on the port set in the backup, `80` by default.

## Update

Running `update` from the container's console upgrades the OS packages, then AdGuard Home with its own updater. AdGuard Home can also update itself from its web interface.

## Credits

Originally written by [tteck](https://github.com/tteck) for [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox).
