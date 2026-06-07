# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Docker Compose-based smart home stack. All services run as containers on a single host and communicate over `network_mode: host`. The HA config volume (`$HOME/home-assistant`) lives outside this repo.

## Stack management

```bash
./launch.bash start      # docker-compose up -d
./launch.bash stop       # docker-compose down
./launch.bash restart    # down + up -d
./launch.bash debug      # up (foreground, shows logs)
./launch.bash update     # git pull + docker-compose pull + restart
```

All `docker-compose` commands require `--env-file ha.env` (the script handles this automatically).

View logs for a single service:
```bash
docker logs -f <container-name>   # e.g. homeassistant, zigbee2mqtt, frigate
```

## Services, config locations, and ports

| Service | Container name | Config in repo | Port |
|---|---|---|---|
| Home Assistant | `homeassistant` | none (config at `$HOME/home-assistant` on host) | 8123 |
| Eufy Security WS | `eufy-security-ws` | via `ha.env` env vars | `$EUFY_PORT` |
| Mosquitto (MQTT broker) | `mosquitto` | `mosquitto/mosquitto.conf` | 1883 |
| Zigbee2MQTT | `zigbee2mqtt` | `zigbee2mqtt/configuration.yaml` | 8099 |
| Frigate (NVR) | `frigate` | `frigate/config/config.yml` | 5000 (UI), 8554 (RTSP), 8555 (WebRTC) |
| ESPHome | `esphome` | `$HOME/esphome/config` on host | 6052 |

## Key architectural points

- All services use `network_mode: host` — no internal Docker networking; services talk via `localhost` ports.
- `/dev/ttyUSB0` is shared between Home Assistant and Zigbee2MQTT (the Zigbee coordinator USB stick).
- Frigate uses an Nvidia GPU (`driver: nvidia`) for hardware-accelerated H.264 (`preset-nvidia-h264`) and a USB Coral TPU (`/dev/bus/usb`) for object detection.
- Frigate media is stored at `/data/frigate` on the host (outside this repo). Frigate's database (`frigate.db`) lives in `frigate/` inside the repo — do not delete it.
- Zigbee2MQTT connects to Mosquitto at `mqtt://localhost` and exposes a frontend on port `8099`.
- Mosquitto currently allows anonymous connections (auth lines are commented out in `mosquitto.conf`).
- `homeassistant` depends on all other services in `docker-compose.yml`; bring everything up before HA to avoid missed startup events.

## Credentials — sensitive files

`ha.env` holds Eufy credentials and other secrets. Additionally, **`docker-compose.yml` and `frigate/config/config.yml` contain hardcoded credentials** (camera RTSP passwords, ESPHome username/password) — do not expose these files or their contents. Do not commit any credentials to git.

## Zigbee devices

Device friendly names are mapped in `zigbee2mqtt/configuration.yaml` under `devices:`. Edit that file to rename or add Zigbee devices. Coordinator backup is in `zigbee2mqtt/coordinator_backup.json`. Versioned config snapshots (`configuration_backup_v*.yaml`) are also in `zigbee2mqtt/`. The file `zigbee2mqtt/sengled.js` is a custom Zigbee device converter.

## Frigate cameras

Currently one camera configured: `front_door` pulling from a Reolink camera at `192.168.1.56`. The go2rtc restream runs at `rtsp://127.0.0.1:8554/front_door`. Detection, recording, and snapshots are all enabled with 3-day and 10-day retain policies respectively.

## What is NOT in this repo

- Home Assistant YAML config (automations, integrations, lovelace) — lives at `$HOME/home-assistant` on the host
- ESPHome device configs — live at `$HOME/esphome/config` on the host
- Frigate recorded media — stored at `/data/frigate`
- Eufy persistent data — stored at `$HOME/eufy-data` on the host
