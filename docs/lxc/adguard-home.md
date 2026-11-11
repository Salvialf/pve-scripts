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

## Default settings

| Setting | Value |
|---|---|
| OS | Latest Debian |
| CPU | 1 vCPU |
| RAM | 512 MiB |
| Disk | 3 GiB |
| Network | DHCP on `vmbr0` |
| Container | Unprivileged, starts at boot, root autologin on the console |

> [!NOTE]
> Other Debian versions and Ubuntu are available in the General settings.

## Backup

To back up AdGuard Home, keep a copy of `/opt/AdGuardHome/AdGuardHome.yaml` (its settings) and `/opt/AdGuardHome/data` (statistics, query log, filter lists).

## Update

Running `update` from the container's console upgrades the OS packages, then AdGuard Home with its own updater. AdGuard Home can also update itself from its web interface.

## Credits

Originally written by [tteck](https://github.com/tteck) for [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox).
