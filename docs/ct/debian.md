# Debian LXC

A minimal Debian container, to use as a base for anything.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/ct/debian.sh)"
```

## Default settings

| Setting | Value |
|---|---|
| OS | Debian 12 |
| CPU | 1 vCPU |
| RAM | 512 MiB |
| Disk | 4 GiB |
| Network | DHCP on `vmbr0` |
| Container | Unprivileged, root autologin on the console |

> [!NOTE]
> Debian 13 is available in the General settings.
> `curl` and `sudo` are installed on top of the Debian template.

## Update

Run `update` from the container's console to upgrade its OS packages.

## Credits

Originally written by [tteck](https://github.com/tteck) for [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox).
