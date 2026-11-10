#!/usr/bin/env bash
# Skickar SO-provet (del 3) till VPS:en och startar om rättningsservern.  Kör från repots rot:  server/drift/deploy.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
VPS="${VPS:-root@49.12.204.84}"
NYCKEL="${NYCKEL:-$HOME/.ssh/cp-sirius-04extra}"
SSH=(ssh -i "$NYCKEL" -o BatchMode=yes "$VPS")
"${SSH[@]}" 'mkdir -p /opt/soprovdel03/app'
rsync -az --delete --exclude node_modules --exclude svar --exclude drift -e "ssh -i $NYCKEL" \
  index.html fragor.js server "$VPS:/opt/soprovdel03/app/"
"${SSH[@]}" 'cd /opt/soprovdel03/app/server && PATH=/opt/sistaprov/node/bin:$PATH npm ci --omit=dev --silent \
  && chown -R root:soprovdel03 /opt/soprovdel03/app && chmod -R g+rX,o-rwx /opt/soprovdel03/app \
  && systemctl restart soprovdel03 && sleep 1 && systemctl is-active soprovdel03 && curl -fs 127.0.0.1:8794/status'
echo
