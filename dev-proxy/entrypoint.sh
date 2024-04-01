#!/bin/bash
CONTAINER_IP=$(hostname -i)
DIR="/app/dev-proxy"
CERT_FILE="$DIR/rootCert.pfx"
NAMED_PIPE="/app/devproxy-in"

if [ ! -f "$NAMED_PIPE" ]; then
    mkfifo $NAMED_PIPE
fi

if [ ! -d "$DIR" ] || [ ! -f "$CERT_FILE" ]; then
    /app/devproxy --install-cert --ip-address "$CONTAINER_IP" --port 8000
else
    /app/devproxy --ip-address $CONTAINER_IP --port 8000
fi
