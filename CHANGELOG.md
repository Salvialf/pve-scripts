<div align="center">
  <img src="logos/pve-scripts.svg" alt="">
  <h1>Changelog</h1>
  <p>All notable changes to this project will be documented in this file.</p>
</div>

## 2026-10-25

### Changed

- When an install step fails, the error shows the failed command and the end of its output, instead of the same generic message for every error.

### Fixed

- Jeedom: the install could sometimes fail at the `Cleaning up` step, or leave Node.js or `python3-venv` missing.

## 2026-10-24

### Changed

- The tools' windows take the logo's yellow.

## 2026-10-23

### Changed

- **Breaking**: the container scripts moved from `ct/` to `lxc/`, the docs give the new commands. The `update` command of a container created before this date still points to `ct/` and no longer works. To fix it, run once in the container's console: `sed -i 's#/ct/#/lxc/#' /usr/bin/update`

## 2026-10-19

### Added

- Tools: when the chosen container already has the device, the tool offers to remove it. It also shows the `lxc.*` lines found in the container's configuration.

## 2026-10-18

### Added

- [Ubuntu container](docs/lxc/ubuntu.md), with Ubuntu 24.04 or 26.04.

## 2026-10-11

### Added

- [GPU device tool](docs/tools/lxc-gpu.md) and [USB serial devices tool](docs/tools/lxc-usb-serial.md), also available as the **GPU device** and **USB serial devices** settings in the Devices category when creating a container.
- **Docker support** setting (Options category, unprivileged containers only): enables the `keyctl` feature Docker needs. On for Jeedom.

### Changed

- Debian container: Debian 13 by default.
- The TUN device is passed through with Proxmox's device passthrough, shown in the container's Resources, instead of an `lxc.mount.entry` line.
- `keyctl` is no longer enabled on every unprivileged container, only with the **Docker support** setting.
- The container's network interface gets the firewall flag, as in Proxmox's creation wizard. It has no effect until the firewall is enabled at both datacenter and container level.
- Hostname: spaces and underscores become hyphens, each label is limited to 63 characters.

### Removed

- The block that gave every privileged container all capabilities and access to every host device to reach the USB serial ports: use the **USB serial devices** setting at creation or the [USB serial devices tool](docs/tools/lxc-usb-serial.md) instead.
- The hardware acceleration block applied to a fixed list of apps: use the **GPU device** setting at creation or the [GPU device tool](docs/tools/lxc-gpu.md) instead.

### Fixed

- Accented letters and other non-ASCII characters were accepted in IP addresses, MAC addresses, disk sizes and hostnames under common locales, Proxmox VE's default `en_US.UTF-8` included.
- A value starting with a dash sent the settings back to an earlier window.
- `No Network!` was printed at every try while waiting for the container's IP, only a final failure is reported now.
- The `update` command left `Loading...` on screen above its confirmation.

## 2026-10-10

### Added

- [TUN device tool](docs/tools/lxc-tun.md), also available as the **TUN device** setting in the new Devices category. On for Jeedom.
- **Start at boot** setting, off by default as in Proxmox, on for Jeedom. Every container used to start at boot.
- A warning to keep the Shell open during the install.

### Changed

- A settings menu by category (General, Access, Resources, Network, DNS, Options, Devices, plus the app's own settings) replaces the start prompt and the default/advanced modes.

### Fixed

- The scripts exit with an error code when a host check fails.

## 2026-10-06

### Changed

- The **Gateway** setting is prefilled with the host's gateway.

## 2026-10-05

### Changed

- The settings windows have Next/Back navigation, and choices are menus instead of radio lists.

## 2026-09-27

### Added

- The free disk space is shown, with a warning when the container's disk doesn't fit.

### Changed

- The template and container storages are chosen in the settings, before the creation starts, instead of during it.
- Settings are validated as they are entered, and the bridge is picked from the host's list.
- The settings windows take the app's colors.

### Fixed

- An empty template list no longer bypasses the missing template check.

## 2026-09-26

### Added

- Jeedom: choice of the branch to install from a menu, or with `JEEDOM_BRANCH` on the command line.
- Jeedom: the access URL and default login are shown at the end of the install.

### Changed

- Debian container: Midnight Commander (`mc`) is no longer installed.

### Fixed

- The template matches the host's architecture.
- Error messages report the right exit code.

## 2026-09-21

### Changed

- Debian and Jeedom containers: the distribution can no longer be switched to Ubuntu.

### Fixed

- A false SSH warning in the Proxmox VE 9 web Shell.
- Template download on Proxmox VE versions whose `pveam available` output has an architecture column.

## 2026-09-19

### Added

- [Jeedom container](docs/lxc/jeedom.md).

### Changed

- Debian container: default disk size raised to 4 GiB.

## 2026-09-18

### Added

- [Debian container](docs/lxc/debian.md), from tteck's scripts, updated for Proxmox VE 8.1 to 9.x and Debian 12 or 13.
