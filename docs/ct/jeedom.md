# Jeedom LXC

[Jeedom](https://jeedom.com) is an open source home automation software. This script installs it with the official [jeedom/core](https://github.com/jeedom/core) install script.

## Install

Run in the Proxmox VE Shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/ct/jeedom.sh)"
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
| Container | Unprivileged, starts at boot, root autologin on the console |
| Jeedom branch | `master` |

> [!NOTE]
> Debian 13 is available in the General settings.

## Jeedom branch

Jeedom is installed from the `master` branch by default. The Jeedom category of the settings menu offers:

- `master`: stable
- `release`: pre-release
- `develop`: development
- Other: any other jeedom/core branch (not supported)

The branch can also be passed on the command line, it then becomes the default:

```bash
JEEDOM_BRANCH="develop" bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/ct/jeedom.sh)"
```

The script checks that the branch exists before creating anything.

## Jeedom DNS service

To use Jeedom's DNS service in an unprivileged container, add this line to the container's configuration on the host (`/etc/pve/lxc/<CTID>.conf`), then restart the container:

```
lxc.mount.entry: /dev/net dev/net none bind,create=dir
```

## Update

Running `update` from the container's console upgrades the OS packages only. Update Jeedom itself from its web interface.

## Credits

Originally written by [Mips2648](https://github.com/Mips2648) for [community-scripts](https://github.com/community-scripts/ProxmoxVED/pull/532).
