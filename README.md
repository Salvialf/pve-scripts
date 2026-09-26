# pve-scripts

Scripts to create ready-to-use LXC containers on Proxmox VE, in the spirit of tteck's original [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox): simple, readable end to end, driven by a single command on the Proxmox host.

## Requirements

- Proxmox VE 8.1 or later (8.x and 9.x)
- An amd64 host
- Run as root from the Proxmox VE Shell

## Usage

Each app page gives the command to run in the Proxmox VE Shell, for example:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/ct/debian.sh)"
```

The script creates the container, then installs the app inside it. Two modes are offered:

- **Default settings**: the app's recommended settings, no further questions.
- **Advanced settings**: choose each setting (container ID, resources, network, root password...), plus the app's own options when it has any.

To update an existing container, run `update` from its console. Each app page says what it updates.

As with any script found online, read it before running it on your host.

## Available scripts

| App | Description |
|---|---|
| [Debian](docs/debian.md) | Minimal Debian container |
| [Jeedom](docs/jeedom.md) | Jeedom home automation software |

## Background

The shared framework in `lib/` and the first scripts come from [tteck](https://github.com/tteck)'s work, archived in late 2024. pve-scripts is not a fork meant to follow his project, but an update of his work for current Proxmox VE and Debian versions.

It is also distinct from [community-scripts](https://github.com/community-scripts/ProxmoxVE), the project that took over tteck's scripts: pve-scripts is an independent project, neither a fork of community-scripts nor affiliated with it.

## License

[MIT](LICENSE)

<sub>Proxmox® is a registered trademark of Proxmox Server Solutions GmbH.</sub>
