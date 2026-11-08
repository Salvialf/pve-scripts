# Post install

Prepares a Proxmox VE 9 host from a single checklist: repositories and subscription popup on a host without a subscription, high availability and update.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Usage

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/tools/pve-post-install.sh)"
```

A checklist shows what is left to do on the host, all checked: uncheck what you want to keep as it is, then confirm. Run it again at any time: it only offers what is not done yet, and the update.

It requires Proxmox VE 9: on Proxmox VE 8, upgrade first. On a host with an active subscription, it only offers high availability and the update.

## What it does

- **Disable the enterprise repositories**: the Proxmox VE and Ceph enterprise repositories only work with a subscription, without one `apt update` fails on them. They are disabled, not deleted, as with the Disable button of node > Updates > Repositories.
- **Enable the no-subscription repository**: Proxmox's repository for hosts without a subscription, added as with the Add button of the same page. It also updates the Ceph client packages, so no Ceph repository is added. The Repositories page then warns that this repository is not recommended for production: Proxmox's usual notice for hosts without a subscription, expected.
- **Remove the subscription popup**: the "No valid subscription" popup no longer shows at login or before updates. Proxmox's updates replace the patched file, so an apt hook patches it again after each update. The mobile interface keeps its subscription notice.
- **Disable high availability**: only offered on a single node without high availability resources, where it can do nothing. Its two services (`pve-ha-lrm`, `pve-ha-crm`) are stopped and no longer start at boot, about 230 MB of RAM saved.
- **Update Proxmox VE**: `apt-get dist-upgrade`, with apt's output shown. If dpkg asks about a configuration file changed on the host, keeping your version (its default answer) is the safe choice when unsure. The script then offers to reboot when packages were updated.

## Undoing

- Repositories: node > Updates > Repositories, Enable or Disable buttons.
- Subscription popup:
  ```bash
  rm /etc/apt/apt.conf.d/no-nag-script /usr/local/sbin/pve-scripts-no-nag
  apt-get install --reinstall proxmox-widget-toolkit
  ```
- High availability, for example when the node joins a cluster:
  ```bash
  systemctl enable --now pve-ha-crm pve-ha-lrm
  ```

## Credits

Originally written by [tteck](https://github.com/tteck) for [Proxmox VE Helper-Scripts](https://github.com/tteck/Proxmox).
