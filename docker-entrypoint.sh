#!/bin/sh

set -e

if [ -s /etc/docker-hostname ]; then 
    DOCKER_HOST=$(cat /etc/docker-hostname)
    sed -i '/<h2>Version/ i <h2>Docker Host: '"$DOCKER_HOST"'<\/h2>' /usr/local/nginx/html/index.html
fi

exec "$@"
