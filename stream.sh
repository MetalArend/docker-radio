#!/usr/bin/env bash

set -e

# check http://www.freesoftwaremagazine.com/articles/create_radio_station_five_minutes_airtime_20_ubuntu_or_debian

# https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04 - tip van @ward@techbelgium
# https://www.digitalocean.com/community/tutorials/how-to-route-web-traffic-securely-without-a-vpn-using-a-socks-tunnel
# https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-tunneling-on-a-vps

docker-compose stop && docker-compose rm -f && docker-compose build && docker-compose up -d --remove-orphans
sleep 1

LOCALHOST_IP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | grep '192')
ICECAST_STREAM=$(docker-compose port icecast 8000)
ICECAST_STREAM=${ICECAST_STREAM/0.0.0.0/$LOCALHOST_IP}

ICECAST_NAME=$(docker-compose exec icecast env | grep "ICECAST_NAME=" | sed 's/.*=//' | tr -d '[:cntrl:]')
ICECAST_DESCRIPTION=$(docker-compose exec icecast env | grep "ICECAST_DESCRIPTION=" | sed 's/.*=//' | tr -d '[:cntrl:]')
ICECAST_SOURCE_PASSWORD=$(docker-compose exec icecast env | grep "ICECAST_SOURCE_PASSWORD=" | sed 's/.*=//' | tr -d '[:cntrl:]')
SHOUTCAST_MOUNT=$(docker-compose exec icecast env | grep "SHOUTCAST_MOUNT=" | sed 's/.*=//' | tr -d '[:cntrl:]')

DEVICE=$(ffmpeg -f avfoundation -list_devices true -i "" 2>&1 | sed -n -e '/audio devices/,$p' | grep -o "Built-in.*")
#DEVICE=$(ffmpeg -f avfoundation -list_devices true -i "" 2>&1 | sed -n -e '/audio devices/,$p' | grep -o "Generic.*")

echo "http://${ICECAST_STREAM}"
echo "http://${ICECAST_STREAM}${SHOUTCAST_MOUNT}"
(sleep 5; open "http://${ICECAST_STREAM}"; open "http://${ICECAST_STREAM}${SHOUTCAST_MOUNT}")&

#ffmpeg -f avfoundation -list_devices true -i ""
ffmpeg -f avfoundation -i :"${DEVICE}" \
        -c:a libmp3lame \
        -b:a 512k \
        -legacy_icecast 1 \
        -content_type audio/mpeg \
        -f mp3 \
        -ice_name "${ICECAST_NAME}" \
        -ice_description "${ICECAST_DESCRIPTION}" \
        -ice_public 1 \
        icecast://source:${ICECAST_SOURCE_PASSWORD}@${ICECAST_STREAM}${SHOUTCAST_MOUNT}

# https://github.com/CenturyLinkLabs/docker-ngrok
# https://hub.docker.com/r/fnichol/ngrok/
# https://ngrok.com/

# https://gist.github.com/t-io/8255711
# ruby -e "$(curl -fsSkL https://raw.github.com/mxcl/homebrew/go)"
# ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
# brew update
# brew upgrade
# brew tap phinze/cask
# brew install brew-cask
# brew cask install --appdir="./bin" ngrok
# brew instal ffmpeg

# http://www.jackosx.com/

bin/ngrok http 32771


#        -ice_genre "radio" \
#        -ice_url "" \
