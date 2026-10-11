# TUN device

Gives an existing container the host's TUN device (`/dev/net/tun`), needed by software that creates network tunnels inside the container, for example:

- VPN software (OpenVPN, Tailscale...)
- Jeedom's DNS service

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Usage

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/tools/lxc-tun.sh)"
```

Choose the container in the list. If it is running, the script offers to restart it: the change only applies after a restart.

To skip the list, give the container ID:

```bash
CT_ID=105 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/tools/lxc-tun.sh)"
```

## What it does

It gives the host's `/dev/net/tun` to the container as a passthrough device, the same as Resources > Add > Device Passthrough in the Proxmox VE interface:

```bash
pct set <CTID> -devN /dev/net/tun,mode=0666
```

- The device then shows in the container's Resources, where it can be removed.
- Mode `0666` opens it to everyone in the container, as on the host.
- A container that already has the TUN device is left as it is, running it twice is safe. This includes containers set up with the two `lxc.*` lines of the Proxmox wiki page [OpenVPN in LXC](https://pve.proxmox.com/wiki/OpenVPN_in_LXC).

The creation scripts use this same tool when their TUN device setting is on (Devices category of the settings menu).
