#!/usr/bin/env bash

docker-compose stop && docker-compose rm -f && docker-compose build && docker-compose up -d --remove-orphans
sleep 1

brew install ffmpeg
#ffmpeg -f avfoundation -list_devices true -i ""
ffmpeg -f avfoundation -i :"Built-in Input" -c:a libmp3lame -b:a 320k -legacy_icecast 1 -content_type audio/mpeg -ice_name "Local Radio" -ice_description "Local Radio" -f mp3 icecast://source:changeme@localhost:8000/stream