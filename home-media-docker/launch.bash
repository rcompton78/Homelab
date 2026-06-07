#!/usr/bin/env bash

usage() {
    echo "USAGE: launch.bash <start|stop|restart|debug|config|update>"
    exit 0
}

UUID=`id -u`
GUID=`id -u`

if [ "$1" = "start" ]; then
    UUID=$UUID GUID=$GUID docker-compose up --build -d web
elif [ "$1" = "debug" ]; then
    UUID=$UUID GUID=$GUID docker-compose up --build web
elif [ "$1" = "stop" ]; then
    UUID=$UUID GUID=$GUID docker-compose down
elif [ "$1" = "restart" ]; then
    UUID=$UUID GUID=$GUID docker-compose down && UUID=$UUID GUID=$GUID docker-compose up --build -d web
elif [ "$1" = "update" ]; then
    UUID=$UUID GUID=$GUID docker-compose down && \
    UUID=$UUID GUID=$GUID docker-compose pull && \
    UUID=$UUID GUID=$GUID docker-compose up --build -d web 
elif [ "$1" = "config" ]; then
    UUID=$UUID GUID=$GUID docker-compose config
else
    usage
fi

