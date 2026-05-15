#!/usr/bin/env bash
# Lance l'app collecteur avec l'IP LAN du backend (comme tontinepro_client).
set -euo pipefail
IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "${IP:-}" ]; then
  IP="10.0.2.2"
fi
echo "→ API: http://${IP}:3000"
flutter run --dart-define=API_BASE_URL="http://${IP}:3000" "$@"
