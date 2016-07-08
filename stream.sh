#!/usr/bin/env bash

brew instal ffmpeg
docker-compose stop && docker-compose rm -f && docker-compose build && docker-compose up -d --remove-orphans
sleep 1

ICECAST_NAME=$(docker-compose exec icecast env | grep "ICECAST_NAME=" | sed 's/.*=//' | tr -d '[:cntrl:]')
ICECAST_DESCRIPTION=$(docker-compose exec icecast env | grep "ICECAST_DESCRIPTION=" | sed 's/.*=//' | tr -d '[:cntrl:]')
ICECAST_SOURCE_PASSWORD=$(docker-compose exec icecast env | grep "ICECAST_SOURCE_PASSWORD=" | sed 's/.*=//' | tr -d '[:cntrl:]')

ICECAST_HOMEPAGE_URL="http://$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | grep '192'):8000"
ICECAST_STREAM_URL="http://$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | grep '192'):8000/stream"

DEVICE=$(ffmpeg -f avfoundation -list_devices true -i "" 2>&1 | sed -n -e '/audio devices/,$p' | grep -o "Built-in.*")

(sleep 5; open "${ICECAST_HOMEPAGE_URL}"; open "${ICECAST_STREAM_URL}")&
ffmpeg -f avfoundation -i :"${DEVICE}" \
        -c:a libmp3lame \
        -b:a 320k \
        -legacy_icecast 1 \
        -content_type audio/mpeg \
        -f mp3 \
        -ice_name "${ICECAST_NAME}" \
        -ice_description "${ICECAST_DESCRIPTION}" \
        icecast://source:${ICECAST_SOURCE_PASSWORD}@localhost:8000/stream
