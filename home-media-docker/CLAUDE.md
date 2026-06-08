# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Docker Compose stack for a self-hosted home media server. Services are wired together to form a full *arr-stack + download + streaming setup.

## Environment setup

Copy `.env.template` to `.env` and fill in your values before starting:

```
MEDIA_ROOT=/media/ntfsdrive          # Where media files live
DATA_DIR=/home/compton/home-media-docker  # Config/state per-service
OPENVPN_CONF_ROOT=...               # Dir containing your .ovpn file
```

The `.env` file is gitignored. `UUID`/`GUID` are injected at runtime by `launch.bash` via `id -u`.

## Managing the stack

All lifecycle operations go through `launch.bash`:

```bash
./launch.bash start    # docker-compose up -d web (brings everything up)
./launch.bash stop     # docker-compose down
./launch.bash restart  # down + up
./launch.bash update   # down + pull + up (update all images)
./launch.bash debug    # up without -d (attached, logs to stdout)
./launch.bash config   # print resolved compose config (useful for debugging env vars)
```

The `web` service is the compose entrypoint — starting it pulls in all dependencies.

## Architecture

```
VPN container (dperson/openvpn-client)
  └── sabnzbd  (NZB downloader, port 8080 via nginx)
  └── deluge   (torrent client, port 8112 via nginx)

Host-network services (direct port access, no proxy):
  plex       – media server with NVIDIA GPU transcode
  radarr     – movie management
  sonarr     – TV management
  jackett    – torrent indexer aggregator
  prowlarr   – indexer manager (newer alternative to jackett)
  overseerr  – media request interface
  tautulli   – Plex analytics/monitoring
  bazarr     – subtitle management

nginx (web service, ports 8080/8112)
  └── reverse proxies sabnzbd and deluge (which are on the VPN network, not host)
```

**Key networking rule:** `sabnzbd` and `deluge` use `network_mode: service:vpn`, so all their traffic routes through the VPN container. They are not directly reachable from the host — nginx proxies them via the `vpn` container alias (`links: vpn:deluge`, `vpn:sabnzbd`). All other services use `network_mode: host`.

**Data layout convention:**
- `/config` → `$DATA_DIR/<service>/config`
- `/movies` → `$MEDIA_ROOT/Movies`
- `/tv` → `$MEDIA_ROOT/TV`
- `/downloads` → `$MEDIA_ROOT/Complete`

## GPU (NVIDIA) support

Plex is configured for NVIDIA hardware transcode (`NVIDIA_VISIBLE_DEVICES=all`). If setting up on a new machine, run `setup-nvidia-gpu.bash` to install drivers and `nvidia-docker2`, then reboot.

## Utility scripts

- `scripts/checkIp.sh` — curls `api.ipify.org` to verify the public IP (use after starting to confirm VPN is active for the download containers).
