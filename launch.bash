#!/usr/bin/env bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "USAGE: launch.bash <stack> <start|stop|restart|debug|update|config>"
    echo ""
    echo "Available stacks:"
    for d in "$REPO_DIR"/*/; do
        [[ -f "$d/docker-compose.yml" ]] && echo "  $(basename "$d")"
    done
    exit 1
}

[[ $# -lt 2 ]] && usage

STACK="$1"
ACTION="$2"
STACK_DIR="$REPO_DIR/$STACK"

if [[ ! -d "$STACK_DIR" ]]; then
    echo "Error: stack '$STACK' not found at $STACK_DIR"
    exit 1
fi

if [[ ! -f "$STACK_DIR/docker-compose.yml" ]]; then
    echo "Error: no docker-compose.yml found in $STACK_DIR"
    exit 1
fi

cd "$STACK_DIR" || exit 1

# home-assistant uses a named env file; others use .env (auto-detected)
COMPOSE_ARGS=()
[[ -f "ha.env" ]] && COMPOSE_ARGS+=(--env-file ha.env)

# home-media-docker needs UUID/GUID; harmless to export for other stacks
export UUID=$(id -u)
export GUID=$(id -g)

case "$ACTION" in
    start)
        docker compose "${COMPOSE_ARGS[@]}" up -d
        ;;
    stop)
        docker compose "${COMPOSE_ARGS[@]}" down
        ;;
    restart)
        docker compose "${COMPOSE_ARGS[@]}" down && \
        docker compose "${COMPOSE_ARGS[@]}" up -d
        ;;
    debug)
        docker compose "${COMPOSE_ARGS[@]}" up
        ;;
    update)
        docker compose "${COMPOSE_ARGS[@]}" down && \
        docker compose "${COMPOSE_ARGS[@]}" pull && \
        docker compose "${COMPOSE_ARGS[@]}" up -d
        ;;
    config)
        docker compose "${COMPOSE_ARGS[@]}" config
        ;;
    *)
        usage
        ;;
esac
