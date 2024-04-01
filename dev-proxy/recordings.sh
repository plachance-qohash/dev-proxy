#!/bin/sh

start() {
    echo "Start recording..."
    echo r > /app/devproxy-in
}

stop() {
    echo "Stop recording..."
    echo s > /app/devproxy-in
    sleep 5
    sync
}

sync() {
    echo "Sync mocks..."
    cp /app/mocks*.json /mocks/
}

"$@"