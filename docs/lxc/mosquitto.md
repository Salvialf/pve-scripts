# Mosquitto LXC

[Mosquitto](https://mosquitto.org/) is an MQTT broker: home automation software and devices (Jeedom, Home Assistant, Zigbee2MQTT, Z-Wave JS UI, ESPHome...) exchange their messages through it. This script installs the distribution's `mosquitto` package.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/mosquitto.sh)"
```

Set the MQTT user and password in the Mosquitto category of the settings menu: the container can't be created without them. At the end, the script shows the broker's address, on port `1883`.

## Default settings

| Setting | Debian | Alpine |
|---|---|---|
| OS | Latest Debian | Latest Alpine |
| CPU | 1 vCPU | Same as Debian |
| RAM | 512 MiB | 256 MiB |
| Disk | 2 GiB | 0.5 GiB |
| Network | DHCP on `vmbr0` | Same as Debian |
| Container | Unprivileged, starts at boot, root autologin on the console | Same as Debian |
| MQTT user and password | Required (no default) | Same as Debian |

> [!NOTE]
> Other Debian versions, Ubuntu and Alpine are available in the General settings.

## Configuration

The broker listens on port `1883` and refuses clients without a user and password. Its settings are in `/etc/mosquitto/conf.d/default.conf`, its users in `/etc/mosquitto/passwd`.

The connection is not encrypted: keep the broker on a trusted local network.

## Users

From the container's console, add a user or change a password (asked twice):

```bash
mosquitto_passwd /etc/mosquitto/passwd <user>
```

Then reload the broker, which applies the change without disconnecting the clients:

- Debian and Ubuntu: `systemctl reload mosquitto`
- Alpine: `kill -HUP $(cat /run/mosquitto.pid)`

Remove a user with `mosquitto_passwd -D /etc/mosquitto/passwd <user>`, then reload the same way.

`mosquitto_passwd` warns that the file's owner is not root: the file belongs to the `mosquitto` user on purpose, so that only the broker can read it.

## Update

Running `update` from the container's console upgrades the OS packages, Mosquitto included.

## Credits

Originally written by [tteck](https://github.com/tteck) for [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox).
