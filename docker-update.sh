#!/bin/bash
set -e

BASE_DIR="/home/mates/docker" #kde se maji provadet aktualizace
LOG="/var/log/docker-update.log" #kam ulozit log aktualizaci
DATE=$(date '+%Y-%m-%d %H:%M:%S') #format aktualuaci

# seznam povolených kontejnerů
UPDATE_LIST=(
  flatnots
  glance
  homebridge
  miniflux
)

echo "[$DATE] Starting Docker update (whitelist mode)" >> "$LOG" #zprava o spusteni

UPDATED=false

for SERVICE in "${UPDATE_LIST[@]}"; do
  DIR="$BASE_DIR/$SERVICE"

  if [ ! -d "$DIR" ]; then
    echo "[$DATE] Directory $DIR not found, skipping" >> "$LOG"
    continue
  fi

  if [ ! -f "$DIR/docker-compose.yml" ]; then
    echo "[$DATE] No docker-compose.yml in $DIR, skipping" >> "$LOG"
    continue
  fi

  echo "[$DATE] Checking $SERVICE" >> "$LOG"
  cd "$DIR"

  if docker compose pull | grep -q "Downloaded newer image"; then
    echo "[$DATE] Update found in $SERVICE" >> "$LOG"
    docker compose up -d >> "$LOG" 2>&1
    UPDATED=true
  else
    echo "[$DATE] No update for $SERVICE" >> "$LOG"
  fi
done

if [ "$UPDATED" = true ]; then
  docker image prune -f >> "$LOG" 2>&1
fi

echo "[$DATE] Docker update finished" >> "$LOG"
