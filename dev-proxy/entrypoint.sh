#!/bin/bash
CONTAINER_IP=$(hostname -i)
DIR="/app/dev-proxy"
CERT_FILE="$DIR/rootCert.pfx"
NAMED_PIPE="/app/devproxy-in"

if [ ! -f "$NAMED_PIPE" ]; then
    mkfifo $NAMED_PIPE
fi

extractCert() {
    if [ -f "$CERT_FILE" ]; then
        openssl pkcs12 -in "$CERT_FILE" -out "$DIR/rootCert.crt" -nodes -passin pass:
        awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' "$DIR/rootCert.crt" > "$DIR/dev-proxy-ca.crt"
    fi
}

if [ ! -d "$DIR" ] || [ ! -f "$CERT_FILE" ]; then
    sleep 5 && extractCert &
    /app/devproxy --install-cert --ip-address "$CONTAINER_IP" --port 8000
else
    /app/devproxy --ip-address $CONTAINER_IP --port 8000
fi