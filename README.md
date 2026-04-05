# qbittorrent-gluetun-protonvpn-wireguard-portforward-stack
A simple Docker compose stack which runs qBittorrent through Gluetun (configured with ProtonVPN over Wireguard with automatic port forward)

qBittorrent WebUI will run on port `8080`

# How to install
1. Copy the files in this repository in your desired folder (i.e. ./opt/Docker/qBittorrent)
2. Make the scripts executable
```
chmod +x port_up.sh
chmod +x port_down.sh
chmod +x qbittorrent_healthcheck.sh
```
3. Get your Proton VPN Wireguard API Key from: https://account.proton.me/u/0/vpn/WireGuard
3. Rename `.env.example` to `.env` and add your Proton VPN Wireguard API Key there
4. Customize any other environmental variables that you like.
5. Customize qBittorrent volumes in `docker-compose.yml`
6. Run `docker compose pull` and `docker compose up -d`

# Important note for qBittorrent
To allow Gluetun to automatically update the listening port using the scripts provided, you MUST enable the following option inside qBittorrent:
```
Tools → Options → WebUI → "Bypass authentication for clients on localhost"
```
Without this option, qBittorrent will reject the API calls coming from Gluetun (127.0.0.1), and port forwarding WILL NOT WORK.

This needs to be done only on first launch.

# Credits
- https://github.com/soxfor/qbittorrent-natmap/issues/28#issuecomment-2963233772
- https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/vpn-port-forwarding.md
