# USB serial devices

Gives an existing container the host's USB serial devices, for example Z-Wave, Zigbee or EnOcean keys, modems, UPS cables or 3D printers. Each device is passed by the name it keeps across reboots and replugs (`/dev/serial/by-id/...`), not by a port number like `ttyACM0` that can change.

Only serial devices (`ttyUSB*`, `ttyACM*`) are concerned: a USB storage key is shared with a mount point, not with this tool.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Usage

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/tools/lxc-usb-serial.sh)"
```

Choose the container, then select the devices with Space. If the container is running, the script offers to restart it: the change only applies after a restart.

To skip the lists, give the container ID and the device names, as listed by `ls /dev/serial/by-id/` (several names separated by spaces):

```bash
CT_ID=105 USB_DEVICES="usb-0658_0200-if00" bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/tools/lxc-usb-serial.sh)"
```

## What it does

It gives each device to the container as a passthrough device, the same as Resources > Add > Device Passthrough in the Proxmox VE interface:

```bash
pct set <CTID> -devN /dev/serial/by-id/<name>,gid=20
```

- The devices then show in the container's Resources, where they can be removed.
- In the container, the device has the same `/dev/serial/by-id/<name>` path: use it in the app's settings.
- Group `20` is `dialout`, as on the host: root and the members of `dialout` can use the device. An app running under its own user needs that user in `dialout` (Jeedom's install already does it).
- A device the container already has is skipped, running it twice is safe.
- A container that already gets every serial device through older methods (`lxc.mount.entry` of the whole `/dev/serial/by-id` folder, or an `lxc.hook.autodev` script) is left as it is. To switch to device passthrough, remove those lines first.

The creation scripts use this same tool for the devices selected in the Devices category of the settings menu.

## If the container no longer starts

Proxmox VE checks passthrough devices at every container start. When a device is unplugged, the start fails and the container's Task History shows:

```
TASK ERROR: Device /dev/serial/by-id/<name> does not exist
```

Plug the device back in, or remove it from the container's Resources.

A device unplugged while the container runs doesn't stop it: the app loses the device, and usually gets it back without a restart when it is plugged in again (a restart of the container is needed if the host gives it another port number).
