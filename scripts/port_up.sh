#!/bin/sh

PORT=$1
IFACE=$2

# Wait for qBittorrent WebUI to be ready
while ! wget -qO- http://127.0.0.1:8080/api/v2/app/version >/dev/null 2>&1; do
    echo "PortUpdateScript: Waiting for qBittorrent WebUI to start..."
    sleep 5
done

echo "PortUpdateScript: qBittorrent is ready. Setting listening port to $PORT"

wget -qO- \
  --post-data="json={\"listen_port\":${PORT},\"current_network_interface\":\"${IFACE}\",\"random_port\":false,\"upnp\":false}" \
  http://127.0.0.1:8080/api/v2/app/setPreferences

echo "PortUpdateScript: Port updated successfully."