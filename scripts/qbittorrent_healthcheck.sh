#!/bin/sh

log() {
    echo "[healthcheck] $1"
}

log "Starting healthcheck..."

# Common wget options
WGET="wget --timeout=3 --tries=1 -qO-"

# Get external IP from Gluetun
IP_RESPONSE=$($WGET http://localhost:8000/v1/publicip/ip)
EXTERNAL_IP=$(echo "$IP_RESPONSE" | grep -o '"public_ip":"[^"]*"' | cut -d'"' -f4)

if [ -z "$EXTERNAL_IP" ]; then
    log "ERROR: Unable to retrieve external IP"
    exit 1
fi

log "External IP: $EXTERNAL_IP"

# Get forwarded port from Gluetun
FORWARDED_PORT_RESPONSE=$($WGET http://localhost:8000/v1/portforward)
FORWARDED_PORT=$(echo "$FORWARDED_PORT_RESPONSE" | grep -o '"port":[0-9]*' | cut -d':' -f2)

if [ -z "$FORWARDED_PORT" ]; then
    log "ERROR: Unable to retrieve forwarded port"
    exit 1
fi

log "Forwarded port: $FORWARDED_PORT"

# Get port from Qbittorrent
PORT_RESPONSE=$($WGET http://localhost:8080/api/v2/app/preferences)
CURRENT_PORT=$(echo "$PORT_RESPONSE" | grep -o '"listen_port":[0-9]*' | cut -d: -f2)  

if [ -z "$CURRENT_PORT" ]; then
    log "ERROR: Unable to retrieve current port"
    exit 1
fi

if [ "$CURRENT_PORT" = "0" ]; then 
	log "WARNING: Current port is set to 0. Trying to restore port forwarding..."
	
	# Get current interface from Gluetun
	INTERFACE=$(wget -q -O - "http://localhost:8000/v1/vpn/settings" | \
    grep -o '"wireguard":[^}]*' | \
    grep -o '"interface":"[^"]*"' | \
    cut -d'"' -f4)

  
	if [ -n "$INTERFACE" ]; then  
		echo "$INTERFACE"  
	else  
		echo "ERROR: Unable to retrieve Wireguard interface name" >&2  
		exit 1  
	fi
	
	wget -qO- \
	--post-data="json={\"listen_port\":${FORWARDED_PORT},\"current_network_interface\":\"${INTERFACE}\",\"random_port\":false,\"upnp\":false}" \
	http://127.0.0.1:8080/api/v2/app/setPreferences
fi

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