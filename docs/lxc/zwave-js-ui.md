# Z-Wave JS UI LXC

[Z-Wave JS UI](https://zwave-js.github.io/zwave-js-ui/) controls a Z-Wave network through a USB Z-Wave key, from its web interface or from home automation software (Home Assistant, Jeedom, any MQTT software). This script installs its official Linux build from its [GitHub releases](https://github.com/zwave-js/zwave-js-ui/releases).

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/zwave-js-ui.sh)"
```

At the end, the script shows the URL of the Z-Wave JS UI interface, on port `8091`.

## Default settings

| Setting | Value |
|---|---|
| OS | Debian 13 |
| CPU | 2 vCPU |
| RAM | 1024 MiB |
| Disk | 4 GiB |
| Network | DHCP on `vmbr0` |
| Container | Unprivileged, starts at boot, root autologin on the console |

> [!NOTE]
> Debian 12 and Ubuntu are available in the General settings.

## Z-Wave key

The Z-Wave USB key plugged into the host can be given to the container in the Devices category of the settings menu. For an existing container, run the [USB serial devices tool](../tools/lxc-usb-serial.md) on the host.

In Z-Wave JS UI's settings, set the serial port to the key's `/dev/serial/by-id/...` path.

> [!WARNING]
> A device given to the container must stay plugged in: if it is missing, the container no longer starts. See [If the container no longer starts](../tools/lxc-usb-serial.md#if-the-container-no-longer-starts).

The key can also stay plugged into another machine, or be a network Z-Wave controller: the container then needs no device, set the serial port to `tcp://<ip>:<port>` instead. See [Remote serial port over TCP](https://zwave-js.github.io/zwave-js/#/usage/tcp-connection) for the other machine's setup. This connection is neither authenticated nor encrypted: keep it on a trusted local network.

## Data

Z-Wave JS UI keeps its settings, network data and backups in `/var/lib/zwave-js-ui`, apart from the program in `/opt/zwave-js-ui`, which updates replace.

## Update

Running `update` from the container's console upgrades the OS packages, then Z-Wave JS UI when a new version is out.

## Credits

Originally written by [tteck](https://github.com/tteck) for [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox).
