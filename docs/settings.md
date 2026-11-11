# Changing settings later

Most settings of the settings menu stay in Proxmox VE: change them in the container's pages of the interface (Resources, Network, DNS, Options), as for any container. Devices are added or removed with the [tools](../README.md#tools).

A few settings are applied inside the container when it is created, so the Proxmox VE interface does not show them. To change them later, run these commands in the container's console.

## Debian and Ubuntu

### Root password

To set or change it:

```bash
passwd
```

To remove it, enable the automatic console login first, then:

```bash
passwd -l root
```

### Automatic console login

A container created without a root password logs in automatically on its console.

To enable it:

```bash
mkdir -p /etc/systemd/system/container-getty@1.service.d
cat > /etc/systemd/system/container-getty@1.service.d/override.conf <<'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud tty%I 115200,38400,9600 $TERM
EOF
systemctl daemon-reload
systemctl restart container-getty@1
```

To disable it, set a root password first, then:

```bash
rm -r /etc/systemd/system/container-getty@1.service.d
systemctl daemon-reload
systemctl restart container-getty@1
```

The console then asks for the root password.

### Root SSH access

It needs a root password.

To enable it:

```bash
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh
```

To disable it:

```bash
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
systemctl restart ssh
```

### IPv6

To enable it, then restart the container so its services listen on IPv6 again:

```bash
rm /etc/sysctl.d/99-disable-ipv6.conf
reboot
```

To disable it:

```bash
printf "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\n" > /etc/sysctl.d/99-disable-ipv6.conf
sysctl -p /etc/sysctl.d/99-disable-ipv6.conf
```

### APT-Cacher

To enable it, or change its address, replace `192.168.1.10` with its address:

```bash
echo 'Acquire::http::Proxy-Auto-Detect "/usr/local/bin/apt-proxy-detect.sh";' > /etc/apt/apt.conf.d/00aptproxy
cat > /usr/local/bin/apt-proxy-detect.sh <<'EOF'
#!/bin/bash
if nc -w1 -z 192.168.1.10 3142; then
  echo -n "http://192.168.1.10:3142"
else
  echo -n "DIRECT"
fi
EOF
chmod +x /usr/local/bin/apt-proxy-detect.sh
```

To disable it:

```bash
rm /etc/apt/apt.conf.d/00aptproxy /usr/local/bin/apt-proxy-detect.sh
```

## Alpine

### Root password

To set or change it:

```sh
passwd
```

To remove it, enable the automatic console login first, then:

```sh
passwd -l root
```

### Automatic console login

A container created without a root password logs in automatically on its console.

To enable it:

```sh
printf '#!/bin/sh\nexec /bin/login -f root\n' > /usr/local/bin/autologin
chmod +x /usr/local/bin/autologin
sed -i 's|^tty1:.*|tty1::respawn:/sbin/getty -n -l /usr/local/bin/autologin 38400 tty1|' /etc/inittab
touch /etc/.pve-ignore.inittab
reboot
```

`/etc/.pve-ignore.inittab` keeps Proxmox VE from writing back its standard console line at each start.

To disable it, set a root password first, then:

```sh
rm /etc/.pve-ignore.inittab /usr/local/bin/autologin
reboot
```

The console then asks for the root password.

### Root SSH access

It needs a root password. The SSH server is only installed when root SSH access is chosen at creation.

To enable it:

```sh
apk add openssh
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
rc-update add sshd
rc-service sshd restart
```

To disable it:

```sh
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
rc-service sshd restart
```

### IPv6

To enable it, then restart the container so its services listen on IPv6 again:

```sh
rm /etc/sysctl.d/99-disable-ipv6.conf
reboot
```

To disable it:

```sh
printf "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\n" > /etc/sysctl.d/99-disable-ipv6.conf
sysctl -p /etc/sysctl.d/99-disable-ipv6.conf
rc-update add sysctl boot
```
