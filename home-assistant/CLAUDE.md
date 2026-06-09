# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Docker Compose-based smart home stack. All services run as containers on a single host and communicate over `network_mode: host`. The HA config volume (`$DATA_DIR/home-assistant`) lives outside this repo.

## Stack management

```bash
./launch.bash start      # docker-compose up -d
./launch.bash stop       # docker-compose down
./launch.bash restart    # down + up -d
./launch.bash debug      # up (foreground, shows logs)
./launch.bash update     # git pull + docker-compose pull + restart
```

View logs for a single service:
```bash
docker logs -f <container-name>   # e.g. homeassistant, zigbee2mqtt, frigate
```

## Environment

Copy `ha.env.template` to `ha.env` and fill in values. Key variables:

```
DATA_DIR=/opt/homelab    # Host path for all service config/data
EUFY_USERNAME=...
EUFY_PASSWORD=...
EUFY_PORT=3001
REOLINK_USERNAME=...
REOLINK_PASSWORD=...
ESPHOME_USERNAME=...
ESPHOME_PASSWORD=...
```

All `docker-compose` commands require `--env-file ha.env` (handled automatically by `launch.bash`).

## Startup order

Services start in 3 staged sets based on healthchecks:

```
Stage 1:  mosquitto                                    (healthcheck: mosquitto_pub to 127.0.0.1:1883)
Stage 2:  zigbee2mqtt + eufy-security-ws               (parallel; zigbee2mqtt waits for mosquitto:healthy)
          frigate + esphome                             (parallel; independent)
Stage 3:  homeassistant                                (waits for all stage-2 services healthy)
```

## Services, config locations, and ports

| Service | Container name | Config path | Port | Healthcheck |
|---|---|---|---|---|
| Home Assistant | `homeassistant` | `$DATA_DIR/home-assistant` | 8123 | depends on all below |
| Eufy Security WS | `eufy-security-ws` | via `ha.env` env vars | `$EUFY_PORT` (3001) | `nc` TCP |
| Mosquitto (MQTT broker) | `mosquitto` | `$DATA_DIR/mosquitto/` | 1883 | `mosquitto_pub` |
| Zigbee2MQTT | `zigbee2mqtt` | `$DATA_DIR/zigbee2mqtt/` | 8099 | `nc` TCP |
| Frigate (NVR) | `frigate` | `$DATA_DIR/frigate/config/` | 5000 (UI), 8554 (RTSP), 8555 (WebRTC) | `curl` HTTP |
| ESPHome | `esphome` | `$DATA_DIR/esphome/config` | 6052 | `curl` HTTP |

## Key architectural points

- All services use `network_mode: host` — no internal Docker networking; services talk via `localhost` ports.
- `/dev/ttyUSB0` is shared between Home Assistant and Zigbee2MQTT (the Zigbee coordinator USB stick).
- Frigate uses an Nvidia GPU (`driver: nvidia`) for hardware-accelerated H.264 (`preset-nvidia-h264`) and a USB Coral TPU (`/dev/bus/usb`) for object detection.
- Frigate media is stored at `/data/frigate` on the host (outside this repo). Frigate's database (`frigate.db`) lives in `frigate/` inside the repo — do not delete it.
- Zigbee2MQTT connects to Mosquitto at `mqtt://localhost` and exposes a frontend on port `8099`.
- Mosquitto currently allows anonymous connections (auth lines are commented out in `mosquitto.conf`).
- `homeassistant` uses `condition: service_healthy` on all dependencies — it will not start until each service passes its healthcheck.

## Credentials — sensitive files

`ha.env` holds Eufy credentials and other secrets. Additionally, **`docker-compose.yml` and `frigate/config/config.yml` contain hardcoded credentials** (camera RTSP passwords, ESPHome username/password) — do not expose these files or their contents. Do not commit any credentials to git.

## Zigbee devices

Device friendly names are mapped in `zigbee2mqtt/configuration.yaml` under `devices:`. Edit that file to rename or add Zigbee devices. Coordinator backup is in `zigbee2mqtt/coordinator_backup.json`. Versioned config snapshots (`configuration_backup_v*.yaml`) are also in `zigbee2mqtt/`. The file `zigbee2mqtt/sengled.js` is a custom Zigbee device converter.

## Frigate cameras

Currently one camera configured: `front_door` pulling from a Reolink camera at `192.168.1.56`. The go2rtc restream runs at `rtsp://127.0.0.1:8554/front_door`. Detection, recording, and snapshots are all enabled with 3-day and 10-day retain policies respectively.

## What is NOT in this repo

- Home Assistant YAML config (automations, integrations, lovelace) — lives at `$DATA_DIR/home-assistant` on the host
- ESPHome device configs — live at `$DATA_DIR/esphome/config` on the host
- Frigate recorded media — stored at `/data/frigate`
- Eufy persistent data — stored at `$DATA_DIR/eufy-data` on the host
