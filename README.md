<div align="center">
  <img src="logos/pve-scripts.svg" alt="">
  <h1>pve-scripts</h1>
  <p>
    <a href="#containers"><img src="https://img.shields.io/github/directory-file-count/Salvialf/pve-scripts/lxc?type=file&extension=sh&label=containers&color=F2C300" alt="Containers"></a>
    <a href="#tools"><img src="https://img.shields.io/github/directory-file-count/Salvialf/pve-scripts/tools?type=file&extension=sh&label=tools&color=F2C300" alt="Tools"></a>
    <a href="CHANGELOG.md"><img src="https://img.shields.io/badge/changelog-F2C300" alt="Changelog"></a>
  </p>
</div>

Scripts to create ready-to-use LXC containers from a single settings menu, in the spirit of tteck's original [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox): simple, readable end to end, driven by one command on the Proxmox host.

> [!IMPORTANT]
> As with any script found online, read it before running it on your host.

## Requirements

- Proxmox VE 8.1 or later (8.x and 9.x)
- An amd64 host
- Run the scripts in the Shell of the Proxmox VE host (node > Shell)
- Run them as root: from another account, use `su -` first, the scripts refuse `sudo`
- Keep the Shell open until the script ends: leaving it stops the script

## Usage

Each container page gives the command to run in the Proxmox VE Shell, for example:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/debian.sh)"
```

The script opens a settings menu with the container's recommended settings. Its first line **Create the LXC** creates the container with these settings. The other lines open a category to change only what you need, then come back to the menu:

| Category | Settings |
|---|---|
| General | Distribution and version, container ID, hostname, unprivileged or privileged container |
| Access | Root password, root SSH access |
| Resources | Template and container storages, disk size, CPU cores, RAM |
| Network | Bridge, DHCP or static IPv4 and gateway, IPv6, VLAN, MAC address, MTU |
| DNS | DNS server, search domain |
| Options | Start at boot, Docker support, APT-Cacher, verbose mode |
| Devices | GPU, TUN device, USB serial devices |
| *App name* | The app's own settings when it has any |

The script then creates the container and installs the app inside it. A distribution container only gets its base system set up.

## After creation

Run `update` from the container's console to upgrade its packages and its app: each app page says what it updates. `update` also says when a newer release of the container's distribution exists, and on Alpine it offers to move the container to it.

To change a setting later, see [Changing settings later](docs/settings.md).

## Containers

### Apps

| App | Distributions | Description |
|---|---|---|
| [AdGuard Home](docs/lxc/adguard-home.md) | Debian, Ubuntu, Alpine | DNS server that blocks ads and trackers for the whole network |
| [Caddy](docs/lxc/caddy.md) | Debian, Ubuntu, Alpine | Web server and reverse proxy with automatic HTTPS |
| [Jeedom](docs/lxc/jeedom.md) | Debian | Jeedom home automation software |
| [Mosquitto](docs/lxc/mosquitto.md) | Debian, Ubuntu, Alpine | MQTT broker, with its user and password set at install |
| [Vaultwarden](docs/lxc/vaultwarden.md) | Alpine | Password manager server for the Bitwarden apps |
| [Z-Wave JS UI](docs/lxc/zwave-js-ui.md) | Debian, Ubuntu | Z-Wave network controller with a web interface |

### Distributions

| Distribution | Description |
|---|---|
| [Alpine](docs/lxc/alpine.md) | Minimal Alpine container |
| [Debian](docs/lxc/debian.md) | Minimal Debian container |
| [Ubuntu](docs/lxc/ubuntu.md) | Minimal Ubuntu container |

## Tools

Each tool does one task and can be run on its own, at any time:

- Container tools act on an existing container, for example to give it one of the host's devices. The device tools are the same scripts the Devices category of the settings menu runs when creating a container.
- Host tools act on the Proxmox VE host itself.

Run them in the Shell of the Proxmox VE host (node > Shell), with the command given on each tool's page.

### Container tools

| Tool | Description |
|---|---|
| [GPU device](docs/tools/lxc-gpu.md) | Gives a container the host's GPU for hardware acceleration (video transcoding, camera streams, AI features) |
| [TUN device](docs/tools/lxc-tun.md) | Gives a container the host's TUN device (VPNs and other network tunnels) |
| [USB serial devices](docs/tools/lxc-usb-serial.md) | Gives a container the host's USB serial devices (Zigbee or Z-Wave keys, modems, UPS cables...) |

### Host tools

| Tool | Description |
|---|---|
| [Post install](docs/tools/pve-post-install.md) | Prepares a Proxmox VE 9 host from a single checklist: no-subscription repository and no subscription popup, high availability off on a single node, update |

## Background

The shared framework in `lib/` and the first scripts come from [tteck](https://github.com/tteck)'s work, archived in late 2024. pve-scripts is not a plain fork of his project, but an update of his work for current Proxmox VE and distribution versions.

It is also distinct from [community-scripts](https://github.com/community-scripts/ProxmoxVE), the project that took over tteck's scripts: pve-scripts is an independent project, neither a fork of community-scripts nor affiliated with it.

## License

Code: [MIT](LICENSE). The pve-scripts logo (`logos/pve-scripts.svg`) is not covered by the MIT license: © 2026 Salvialf, all rights reserved.

<sub>Proxmox® is a registered trademark of Proxmox Server Solutions GmbH.</sub>
