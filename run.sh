#!/usr/bin/env bash
# Lance l'app collecteur.
#   bash run.sh           → backend VPS (par défaut, comme l'app client + l'admin)
#   bash run.sh --local   → backend LOCAL de ce PC (IP LAN:3000) pour le dev
set -euo pipefail

VPS_URL="https://vps-tontinebenin.taila91a50.ts.net"

if [ "${1:-}" = "--local" ]; then
  shift
  # IP utilisée pour joindre Internet (la plus fiable)
  IP=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' | head -1)
  # Fallback : IP LAN 192.168.X.X / 10.X.X.X (hors bridges)
  if [ -z "${IP:-}" ]; then
    IP=$(ip addr show | grep "inet " | grep -v "127.0\|virbr\|docker\|lxc\|br-" \
         | grep -oP '(?<=inet )\d+\.\d+\.\d+\.\d+' | head -1)
  fi
  # Fallback : émulateur Android
  if [ -z "${IP:-}" ]; then IP="10.0.2.2"; fi
  echo "→ API LOCALE : http://${IP}:3000"
  echo "→ Assure-toi que le backend tourne ici et que le device est sur le même WiFi."
  flutter run --dart-define=API_BASE_URL="http://${IP}:3000" "$@"
else
  echo "→ API : VPS ($VPS_URL)"
  echo "  (pour le backend local : bash run.sh --local)"
  flutter run "$@"
fi
