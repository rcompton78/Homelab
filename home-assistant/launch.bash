#!/usr/bin/env bash

usage() {
    echo "USAGE: launch.bash <start|stop|restart|debug|update>"
    exit 0
}

UUID=`id -u`
GUID=`id -u`

if [ "$1" = "start" ]; then
    docker-compose --env-file ha.env up -d
elif [ "$1" = "debug" ]; then
    docker-compose --env-file ha.env up 
elif [ "$1" = "stop" ]; then
    docker-compose --env-file ha.env down
elif [ "$1" = "restart" ]; then
    docker-compose --env-file ha.env down && docker-compose --env-file ha.env up -d 
elif [ "$1" = "update" ]; then
    git fetch && \
    git pull origin master && \
    docker-compose pull && \
    docker-compose --env-file ha.env down && \
    docker-compose --env-file ha.env up -d 
else
    usage
fi


