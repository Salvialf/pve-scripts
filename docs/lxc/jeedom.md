# Jeedom LXC

[Jeedom](https://jeedom.com) is an open source home automation software. This script installs it with the official [jeedom/core](https://github.com/jeedom/core) install script.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/jeedom.sh)"
```

At the end, the script shows the URL of the Jeedom interface. The default login is `admin`/`admin`.

## Default settings

| Setting | Value |
|---|---|
| OS | Debian 12 |
| CPU | 2 vCPU |
| RAM | 2048 MiB |
| Disk | 16 GiB |
| Network | DHCP on `vmbr0` |
| Container | Unprivileged, starts at boot, Docker support, root autologin on the console |
| Devices | TUN |
| Jeedom branch | `master` |

> [!NOTE]
> Debian 13 is available in the General settings, but not yet compatible with the `master` and `release` branches.

## Jeedom branch

Jeedom is installed from the `master` branch by default. The Jeedom category of the settings menu offers:

- `master`: stable
- `release`: pre-release
- `develop`: development
- Other: any other jeedom/core branch

The branch can also be passed on the command line, it then becomes the default:

```bash
JEEDOM_BRANCH="develop" bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/jeedom.sh)"
```

The script checks that the branch exists before creating anything.

## TUN device

Jeedom's DNS service needs the TUN device. The container gets it by default (Devices category of the settings menu).

For a container created without it, run the [TUN device tool](../tools/lxc-tun.md) on the host.

## USB serial devices

USB serial devices plugged into the host (Z-Wave, Zigbee, EnOcean or RFXCOM keys, teleinfo modem, UPS serial cable...) can be given to the container in the Devices category of the settings menu. For an existing container, run the [USB serial devices tool](../tools/lxc-usb-serial.md) on the host.

In the plugin's settings, choose the device by its `/dev/serial/by-id/...` path, which stays the same across reboots and replugs.

> [!WARNING]
> A device given to the container must stay plugged in: if it is missing, the container no longer starts. See [If the container no longer starts](../tools/lxc-usb-serial.md#if-the-container-no-longer-starts).

## Update

Running `update` from the container's console upgrades the OS packages only. Update Jeedom itself from its web interface.

## Credits

Originally written by [Mips2648](https://github.com/Mips2648) for [community-scripts](https://github.com/community-scripts/ProxmoxVED/pull/532).
