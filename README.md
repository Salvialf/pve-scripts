# pve-scripts

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
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/ct/debian.sh)"
```

The script creates the container, then installs the app inside it. Before creating anything, a settings menu shows the app's recommended settings, grouped by category:

- **Create** right away to use them as they are.
- Open a category (General, Access, Resources, Network, DNS, Options, Devices, plus the app's own settings when it has any) to change only what you need, then come back to the menu.

To update an existing container, run `update` from its console. Each app page says what it updates.

As with any script found online, read it before running it on your host.

## Containers

| App | Description |
|---|---|
| [Debian](docs/ct/debian.md) | Minimal Debian container |
| [Jeedom](docs/ct/jeedom.md) | Jeedom home automation software |

## Tools

To run in the Proxmox VE Shell, on existing containers.

| Tool | Description |
|---|---|
| [TUN device](docs/tools/lxc-tun.md) | Gives a container the host's TUN device (VPNs and other network tunnels) |

## Background

The shared framework in `lib/` and the first scripts come from [tteck](https://github.com/tteck)'s work, archived in late 2024. pve-scripts is not a plain fork of his project, but an update of his work for current Proxmox VE and Debian versions.

It is also distinct from [community-scripts](https://github.com/community-scripts/ProxmoxVE), the project that took over tteck's scripts: pve-scripts is an independent project, neither a fork of community-scripts nor affiliated with it.

## License

[MIT](LICENSE)

<sub>Proxmox® is a registered trademark of Proxmox Server Solutions GmbH.</sub>
