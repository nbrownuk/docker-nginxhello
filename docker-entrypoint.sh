#!/bin/bash

if [ -s /etc/docker-hostname ]; then 
    DOCKER_HOST=$(cat /etc/docker-hostname)
    sed -i '/<\/body>/ i <h2>Docker Host: '"$DOCKER_HOST"'<\/h2>' /usr/local/nginx/html/index.html
fi

exec "$@"
