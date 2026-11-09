# Alpine LXC

A minimal Alpine container, to use as a base for anything with few resources.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/alpine.sh)"
```

## Default settings

| Setting | Value |
|---|---|
| OS | Alpine 3.24 |
| CPU | 1 vCPU |
| RAM | 256 MiB |
| Disk | 0.5 GiB |
| Network | DHCP on `vmbr0` |
| Container | Unprivileged, root autologin on the console |

> [!NOTE]
> Other Alpine versions are available in the General settings.
> `bash`, `curl`, `newt` (for the `update` command) and `tzdata` are installed on top of the Alpine template. An SSH server is only installed when root SSH access is enabled.

## Devices

The host's GPU, TUN device and USB serial devices can be given to the container in the Devices category of the settings menu or later with the [tools](../../README.md#tools).

## Update

Run `update` from the container's console to upgrade its OS packages.

The container stays on its Alpine release. To move to a newer one, replace the version in its repositories, here from 3.24 to 3.25, then upgrade and restart:

```bash
sed -i 's#/v3\.24/#/v3.25/#' /etc/apk/repositories
apk update
apk upgrade --available
reboot
```

## Credits

Originally written by [tteck](https://github.com/tteck) for [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox).
