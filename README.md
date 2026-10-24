<div align="center">
  <img src="logos/pve-scripts.svg" alt="">
  <h1>pve-scripts</h1>
  <p>
    <a href="#containers"><img src="https://img.shields.io/github/directory-file-count/Salvialf/pve-scripts/lxc?type=file&extension=sh&label=containers&color=F2B200" alt="Containers"></a>
    <a href="#tools"><img src="https://img.shields.io/github/directory-file-count/Salvialf/pve-scripts/tools?type=file&extension=sh&label=tools&color=F2B200" alt="Tools"></a>
    <a href="CHANGELOG.md"><img src="https://img.shields.io/badge/changelog-F2B200" alt="Changelog"></a>
  </p>
</div>

Scripts to create ready-to-use LXC containers on Proxmox VE, in the spirit of tteck's original [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox): simple, readable end to end, driven by a single command on the Proxmox host.

## Requirements

- Proxmox VE 8.1 or later (8.x and 9.x)
- An amd64 host
- Run the scripts in the Shell of the Proxmox VE host (node > Shell)
- Run them as root: from another account, use `su -` first, the scripts refuse `sudo`
- Keep the Shell open until the script ends: leaving it stops the script

## Usage

Each app page gives the command to run in the Proxmox VE Shell, for example:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/debian.sh)"
```

The script creates the container, then installs the app inside it. Before creating anything, a settings menu shows the app's recommended settings, grouped by category:

- **Create** right away to use them as they are.
- Open a category (General, Access, Resources, Network, DNS, Options, Devices, plus the app's own settings when it has any) to change only what you need, then come back to the menu.

To update an existing container, run `update` from its console. Each app page says what it updates.

As with any script found online, read it before running it on your host.

## Containers

| App | Description |
|---|---|
| [Debian](docs/lxc/debian.md) | Minimal Debian container |
| [Jeedom](docs/lxc/jeedom.md) | Jeedom home automation software |
| [Ubuntu](docs/lxc/ubuntu.md) | Minimal Ubuntu container |

## Tools

To run in the Proxmox VE Shell, on existing containers.

| Tool | Description |
|---|---|
| [GPU device](docs/tools/lxc-gpu.md) | Gives a container the host's GPU for hardware acceleration (video transcoding, camera streams, AI features) |
| [TUN device](docs/tools/lxc-tun.md) | Gives a container the host's TUN device (VPNs and other network tunnels) |
| [USB serial devices](docs/tools/lxc-usb-serial.md) | Gives a container the host's USB serial devices (Zigbee or Z-Wave keys, modems, UPS cables...) |

## Background

The shared framework in `lib/` and the first scripts come from [tteck](https://github.com/tteck)'s work, archived in late 2024. pve-scripts is not a plain fork of his project, but an update of his work for current Proxmox VE and Debian versions.

It is also distinct from [community-scripts](https://github.com/community-scripts/ProxmoxVE), the project that took over tteck's scripts: pve-scripts is an independent project, neither a fork of community-scripts nor affiliated with it.

## License

[MIT](LICENSE)

<sub>Proxmox® is a registered trademark of Proxmox Server Solutions GmbH.</sub>
