#!/usr/bin/env bash

usage() {
    echo "USAGE: launch.bash <start|stop|restart|debug|update>"
    exit 0
}

if [ "$1" = "start" ]; then
    docker-compose up -d
elif [ "$1" = "debug" ]; then
    docker-compose up
elif [ "$1" = "stop" ]; then
    docker-compose down
elif [ "$1" = "restart" ]; then
    docker-compose down && docker-compose up -d
elif [ "$1" = "update" ]; then
    git fetch && \
    git pull origin master && \
    docker-compose pull && \
    docker-compose down && \
    docker-compose up -d
else
    usage
fi
