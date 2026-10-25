# Ubuntu LXC

A minimal Ubuntu container, to use as a base for anything.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/ubuntu.sh)"
```

## Default settings

| Setting | Value |
|---|---|
| OS | Ubuntu 26.04 |
| CPU | 1 vCPU |
| RAM | 512 MiB |
| Disk | 4 GiB |
| Network | DHCP on `vmbr0` |
| Container | Unprivileged, root autologin on the console |

> [!NOTE]
> Ubuntu 24.04 is available in the General settings.
> `curl` and `sudo` are installed on top of the Ubuntu template.

## Devices

The host's GPU, TUN device and USB serial devices can be given to the container in the Devices category of the settings menu or later with the [tools](../../README.md#tools).

## Update

Run `update` from the container's console to upgrade its OS packages.

## Credits

Originally written by [tteck](https://github.com/tteck) for [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox).
