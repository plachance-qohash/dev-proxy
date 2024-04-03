#!/bin/bash
CONTAINER_IP=$(hostname -i)
DIR="/app/dev-proxy"
CERT_FILE="$DIR/rootCert.pfx"
NAMED_PIPE="/app/devproxy-in"

if [ ! -f "$NAMED_PIPE" ]; then
    mkfifo $NAMED_PIPE
fi

extractCert() {
    openssl pkcs12 -in "$CERT_FILE" -out "$DIR/rootCert.crt" -nodes -passin pass:
    awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' "$DIR/rootCert.crt" > "$DIR/dev-proxy-ca.crt"
    chmod 644 "$DIR/dev-proxy-ca.crt"
}

if [ ! -f "$DIR/dev-proxy-ca.crt" ]; then
    sleep 5 && extractCert &
fi

if [ -f "/mocks/mocks.json" ]; then
    echo "Playback..."
    MOCKS_PARAM="--mocks-file ../mocks/mocks.json"
else
    MOCKS_PARAM="--no-mocks"
fi

if [ ! -d "$DIR" ] || [ ! -f "$CERT_FILE" ]; then
    echo "Install cert and start the proxy"
    /app/devproxy --install-cert --ip-address "$CONTAINER_IP" --port 8000 $MOCKS_PARAM
else
    echo "Start the proxy"
    /app/devproxy --ip-address $CONTAINER_IP --port 8000 $MOCKS_PARAM
fi