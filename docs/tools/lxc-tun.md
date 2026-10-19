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

- The device then shows in the container's Resources.
- Mode `0666` opens it to everyone in the container, as on the host.
- A container that gets the TUN device through `lxc.*` lines, like those of the Proxmox wiki page [OpenVPN in LXC](https://pve.proxmox.com/wiki/OpenVPN_in_LXC), is left as it is: the script shows these lines and stops. To switch to device passthrough, remove them from `/etc/pve/lxc/<CTID>.conf` on the host, then run the script again.

The creation scripts use this same tool when their TUN device setting is on (Devices category of the settings menu).

## Removing the device

Run the script again: when the container already has the TUN device, it offers to remove it. Or remove the `/dev/net/tun` line from the container's Resources.

On a running container, the removal only applies after a restart, which the script offers.
