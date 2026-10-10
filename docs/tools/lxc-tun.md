# TUN device

Gives an existing container the host's TUN device (`/dev/net/tun`), needed by software that creates network tunnels inside the container, for example:

- VPN software (OpenVPN, Tailscale...)
- Jeedom's DNS service and Matter plugin

## Usage

Run in the Proxmox VE Shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/tools/lxc-tun.sh)"
```

Choose the container in the list. If it is running, the script offers to restart it: the change only applies after a restart.

To skip the list, give the container ID:

```bash
CT_ID=105 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/tools/lxc-tun.sh)"
```

## What it does

It adds these two lines to the container's configuration (`/etc/pve/lxc/<CTID>.conf`), as in the Proxmox wiki page [OpenVPN in LXC](https://pve.proxmox.com/wiki/OpenVPN_in_LXC):

```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir
```

- Lines already there are not added again, running it twice is safe.
- They go before the container's snapshots, so they apply to the container itself.
- The wiki's `chown` of `/dev/net/tun` on the host is not needed: the device is already open to everyone on Proxmox VE.

The creation scripts use this same tool when their TUN device setting is on (Devices category of the settings menu).
