# Vaultwarden LXC

[Vaultwarden](https://github.com/dani-garcia/vaultwarden) is a lightweight password manager server that works with the Bitwarden apps and browser extensions. This script installs Alpine's `vaultwarden` package with its web vault.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/lxc/vaultwarden.sh)"
```

Choose how Vaultwarden gets HTTPS in the Vaultwarden category of the settings menu (see [HTTPS](#https)). The admin page token can be set there too (see [Admin page](#admin-page)).

At the end, the script shows the web vault's address with a self-signed certificate, or the address to give the reverse proxy.

## Default settings

| Setting | Value |
|---|---|
| OS | Latest Alpine |
| CPU | 1 vCPU |
| RAM | 256 MiB |
| Disk | 0.5 GiB |
| Network | DHCP on `vmbr0` |
| Container | Unprivileged, starts at boot, root autologin on the console |
| HTTPS | Self-signed certificate |
| Admin page | Disabled (no token) |

> [!NOTE]
> Vaultwarden only runs on Alpine: Debian and Ubuntu have no package for it, and building it takes several GB of RAM at each update. Other Alpine versions are available in the General settings.

## HTTPS

Vaultwarden needs HTTPS: over plain HTTP the browser blocks the encryption the web vault relies on. Two ways to get it:

- **Self-signed certificate**: open `https://<IP>:8000` and accept the browser's warning. Only the web vault works this way, the Bitwarden apps need a real certificate. Use it to try Vaultwarden or on a local network.
- **Separate reverse proxy** (recommended): a reverse proxy you run apart provides HTTPS with a real certificate.

With a reverse proxy, Vaultwarden serves plain HTTP on port `8000` and the reverse proxy forwards the requests there, for example with this block in the Caddyfile of the [Caddy container](caddy.md#configuration):

```
vault.example.com {
    reverse_proxy <IP>:8000 {
        header_up X-Real-IP {remote_host}
    }
}
```

> [!NOTE]
> The `header_up` line gives Vaultwarden the visitor's address: without it every request seems to come from the reverse proxy, and the limit on failed logins applies to everyone at once.

The reverse proxy points at the container's address: set a fixed IP in the Network settings, or reserve the container's address on the router once it is created. Then open Vaultwarden at `https://vault.example.com`.

To switch from the self-signed certificate to a reverse proxy later, turn off Vaultwarden's own HTTPS. In the container, delete the line starting with `export ROCKET_TLS=` in `/etc/conf.d/vaultwarden`, then restart Vaultwarden:

```bash
rc-service vaultwarden restart
```

## Admin page

The admin page at `/admin` manages users, signups, email and the other server settings. It asks for the admin token, which works like a password. Without a token the page is disabled.

> [!TIP]
> In the admin page's General settings:
> - set the **Domain URL** to the address you open Vaultwarden at: security keys and email links need it.
> - turn off **Allow new signups** once your accounts exist.

To set a new token later, or to disable the page by leaving it blank, run from the container's console:

```bash
RESET_ADMIN_TOKEN=yes update
```

Disabling the page once Vaultwarden is configured is a good habit when it is reachable from the internet: the settings saved from the admin page stay applied.

## Backup and restore

Back up the container with Proxmox VE. To restore Vaultwarden in a new container, choose this backup in the **Based on** settings and answer Yes to restoring the Vaultwarden data: `/var/lib/vaultwarden` (from `/opt/vaultwarden/data` in a backup made by another script) and the self-signed certificate are copied. The HTTPS and admin token settings take the backup's values and can still be changed in the menu.

Check that the new container runs a Vaultwarden version at least as recent as the old one: data restored into an older version may not work.

## Update

Running `update` from the container's console upgrades the OS packages, Vaultwarden included. Alpine publishes new Vaultwarden versions within a few days, but only for its latest release: when `update` offers to move to a newer Alpine release, back up the container and accept it, otherwise Vaultwarden stops getting updates.

## Credits

Originally written by [tteck](https://github.com/tteck) for [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox).
