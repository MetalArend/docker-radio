#!/usr/bin/env bash

# check http://www.freesoftwaremagazine.com/articles/create_radio_station_five_minutes_airtime_20_ubuntu_or_debian

#brew instal ffmpeg
#docker-compose stop && docker-compose rm -f && docker-compose build && docker-compose up -d --remove-orphans
docker-compose stop && docker-compose rm -f && docker-compose build && docker-compose up -d --remove-orphans
sleep 1

LOCALHOST_IP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | grep '192')
ICECAST_STREAM=$(docker-compose port icecast 8000)
ICECAST_STREAM=${ICECAST_STREAM/0.0.0.0/$LOCALHOST_IP}
ICECAST_NAME=$(docker-compose exec icecast env | grep "ICECAST_NAME=" | sed 's/.*=//' | tr -d '[:cntrl:]')
ICECAST_DESCRIPTION=$(docker-compose exec icecast env | grep "ICECAST_DESCRIPTION=" | sed 's/.*=//' | tr -d '[:cntrl:]')
ICECAST_SOURCE_PASSWORD=$(docker-compose exec icecast env | grep "ICECAST_SOURCE_PASSWORD=" | sed 's/.*=//' | tr -d '[:cntrl:]')
SHOUTCAST_MOUNT=$(docker-compose exec icecast env | grep "SHOUTCAST_MOUNT=" | sed 's/.*=//' | tr -d '[:cntrl:]')
ICECAST_HOMEPAGE_URL="http://${ICECAST_STREAM}"
ICECAST_STREAM_URL="http://${ICECAST_STREAM}${SHOUTCAST_MOUNT}"

ffmpeg -f avfoundation -list_devices true -i ""

DEVICE=$(ffmpeg -f avfoundation -list_devices true -i "" 2>&1 | sed -n -e '/audio devices/,$p' | grep -o "Built-in.*")
#DEVICE=$(ffmpeg -f avfoundation -list_devices true -i "" 2>&1 | sed -n -e '/audio devices/,$p' | grep -o "Generic.*")

(sleep 5; open "${ICECAST_HOMEPAGE_URL}"; open "${ICECAST_STREAM_URL}")&
ffmpeg -f avfoundation -i :"${DEVICE}" \
        -c:a libmp3lame \
        -b:a 512k \
        -legacy_icecast 1 \
        -content_type audio/mpeg \
        -f mp3 \
        -ice_name "${ICECAST_NAME}" \
        -ice_description "${ICECAST_DESCRIPTION}" \
        -ice_genre "radio" \
        -ice_public 1 \
        -ice_url "" \
        icecast://source:${ICECAST_SOURCE_PASSWORD}@${ICECAST_STREAM}${SHOUTCAST_MOUNT}
