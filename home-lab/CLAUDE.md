# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a home lab Docker Compose setup running Nginx Proxy Manager (NPM) with a MariaDB backend. Both services run in `network_mode: host`.

## Common Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f
docker-compose logs -f app   # NPM only
docker-compose logs -f db    # MariaDB only

# Restart a service
docker-compose restart app
```

## Architecture

- **`app`** — `jc21/nginx-proxy-manager:latest`, exposes port 80/443 (proxy traffic) and 81 (admin UI at http://localhost:81)
- **`db`** — `jc21/mariadb-aria:latest`, MariaDB backend for NPM
- **`memos`** — `neosmemo/memos:stable`, self-hosted note-taking on port 5230. Uses SQLite (no external DB). Proxied via NPM → `http://localhost:5230`

### Configuration Files

- `.env` — Single source of truth for all compose variables. Auto-loaded by Docker Compose for `${VAR}` substitution and also used as `env_file` for containers. Contains DB credentials and `DATA_DIR`.
- `ha.env` — Credentials for future services (Eufy, VSCode server); not yet wired into docker-compose.yml.

### Data Directory

All service data is stored under `DATA_DIR` (set in `.env`, default `/opt/homelab`):
- `$DATA_DIR/npm/data` → NPM config/data
- `$DATA_DIR/npm/mysql` → MariaDB data
- `$DATA_DIR/npm/letsencrypt` → SSL certificates
- `$DATA_DIR/memos` → Memos SQLite DB and attachments
