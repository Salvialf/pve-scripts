# GPU device

Gives an existing container the host's GPU for hardware acceleration (also called hardware transcoding, VAAPI or Quick Sync), for video transcoding (Jellyfin, Plex, Emby...), camera stream decoding (Frigate) or AI features (Immich). Only the GPU's render node is passed (`/dev/dri/renderD128`), which is all these apps need: unlike `card0`, it gives no access to the host's display.

> [!IMPORTANT]
> - Run the commands on this page in the Shell of the Proxmox VE host (node > Shell).
> - Run them as root: from another account, use `su -` first, the scripts refuse `sudo`.
> - Keep the Shell open until the script ends: leaving it stops the script.

## Usage

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/tools/lxc-gpu.sh)"
```

Choose the container. With several GPUs on the host, the script then asks which one to give. If the container is running, the script offers to restart it: the change only applies after a restart.

To skip the questions, give the container ID and the render node, as listed by `ls /dev/dri/`:

```bash
CT_ID=105 GPU_DEVICE="renderD128" bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salvialf/pve-scripts/main/tools/lxc-gpu.sh)"
```

## What it does

It gives the render node to the container as a passthrough device, the same as Resources > Add > Device Passthrough in the Proxmox VE interface:

```bash
pct set <CTID> -devN /dev/dri/renderD128,gid=44
```

- The device then shows in the container's Resources, where it can be removed.
- Group `44` is `video`, the same in every Debian and Ubuntu (the `render` group's number changes from one system to another). The app's user must be a member of `video`, for example `usermod -aG video jellyfin` in the container.
- A container that already has this render node is left as it is, running it twice is safe.
- A container that gets the GPU through `lxc.mount.entry` lines on `/dev/dri` is left as it is. To switch to device passthrough, remove those lines first.
- NVIDIA cards need more than the render node (their own devices and the same driver version in the container as on the host): they are not handled.

## Checking it works

A smooth playback doesn't prove much: a recent processor can transcode on its own. During a playback that needs transcoding (a lower quality forced in the player, for example):

- the app's transcoding log names the GPU method (Jellyfin: Dashboard > Logs, the latest `FFmpeg.Transcode` log mentions `vaapi` or `qsv`);
- the host's processor stays almost idle;
- on an Intel GPU, `intel_gpu_top` on the host (package `intel-gpu-tools`) shows the Video engine working.
