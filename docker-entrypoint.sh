#!/bin/sh

set -e


src=""
alt=""
tmpfile=/tmp/style
# If the COLOR env has been set, check it has a valid value. If unset, set to
# the default value - black
COLOR=${COLOR:-black}
IP_ADDRESS=$(awk 'END{print $1}' /etc/hosts)
NODE_NAME=${NODE_NAME:----}
desc="$(echo $COLOR | tr '[:lower:]' '[:upper:]' )  Container"
style="color:$COLOR;"

echo $env_vars
# Insert the image tag into the index.html file and remove the temporary file
sed -i "s|\[STYLE\]|$style|" ./index.html
sed -i "s|\[DESC\]|$desc|" ./index.html
sed -i "s|NODE_NAME|$NODE_NAME|" ./index.html


# Exec what has been supplied as arguments for the container/pod
# (default: "/usr/local/nginx/sbin/nginx", "-g", "daemon off;")
exec "$@"
