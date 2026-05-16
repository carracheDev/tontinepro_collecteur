#!/usr/bin/env bash
# Lance l'app collecteur avec la vraie IP LAN (WiFi/Ethernet) du backend.
set -euo pipefail

# Méthode 1 : IP utilisée pour joindre Internet (la plus fiable)
IP=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' | head -1)

# Méthode 2 : fallback — cherche une IP 192.168.X.X ou 10.X.X.X (pas bridge)
if [ -z "${IP:-}" ]; then
  IP=$(ip addr show | grep "inet " | grep -v "127.0\|virbr\|docker\|lxc\|br-" \
       | grep -oP '(?<=inet )\d+\.\d+\.\d+\.\d+' | head -1)
fi

# Méthode 3 : émulateur Android
if [ -z "${IP:-}" ]; then
  IP="10.0.2.2"
fi

echo "→ API : http://${IP}:3000"
echo "→ Assure-toi que ton device est sur le même WiFi que ce PC"
flutter run --dart-define=API_BASE_URL="http://${IP}:3000" "$@"
