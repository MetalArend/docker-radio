#!/bin/sh

set -x

envsubst < "/container/config/icecast.xml" > "/etc/icecast2/icecast.xml"

supervisord -n -c "/container/config/supervisord.conf"
