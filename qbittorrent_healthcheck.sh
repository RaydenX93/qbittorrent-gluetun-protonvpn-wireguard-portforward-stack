#!/bin/sh

log() {
    echo "[healthcheck] $1"
}

log "Starting healthcheck..."

# Common wget options
WGET="wget --timeout=3 --tries=1 -qO-"

# Get external IP
IP_RESPONSE=$($WGET http://localhost:8000/v1/publicip/ip)
EXTERNAL_IP=$(echo "$IP_RESPONSE" | grep -o '"public_ip":"[^"]*"' | cut -d'"' -f4)

if [ -z "$EXTERNAL_IP" ]; then
    log "ERROR: Unable to retrieve external IP"
    exit 1
fi

log "External IP: $EXTERNAL_IP"

# Get forwarded port
PORT_RESPONSE=$($WGET http://localhost:8000/v1/portforward)
FORWARDED_PORT=$(echo "$PORT_RESPONSE" | grep -o '"port":[0-9]*' | cut -d':' -f2)

if [ -z "$FORWARDED_PORT" ]; then
    log "ERROR: Unable to retrieve forwarded port"
    exit 1
fi

log "Forwarded port: $FORWARDED_PORT"

# Check port reachability using portchecker.io
CHECK_URL="https://portchecker.io/api/$EXTERNAL_IP/$FORWARDED_PORT"
log "Checking reachability: $CHECK_URL"

REACHABLE=$($WGET "$CHECK_URL")

if [ "$REACHABLE" = "True" ]; then
    log "Port is reachable"
    exit 0
else
    log "Port is NOT reachable"
    exit 1
fi