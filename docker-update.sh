#!/bin/bash
set -e

ZAKLADNI_SLOZKA="/home/mates/docker"
LOG="/home/mates/update-docker-script/docker-update.log"
DATUM=$(date '+%Y-%m-%d %H:%M:%S')

AKTUALIZOVAT=(
  flatnotes
  glance
  homebridge
  miniflux
)

echo "[$DATUM] Spoustim aktualizaci Dockeru" | tee -a "$LOG"

AKTUALIZOVANE_SLUZBY=()

for SLUZBA in "${AKTUALIZOVAT[@]}"; do
  SLOZKA="$ZAKLADNI_SLOZKA/$SLUZBA"

  [ -d "$SLOZKA" ] || continue
  [ -f "$SLOZKA/docker-compose.yml" ] || continue

  echo "Kontroluji $SLUZBA..."
  cd "$SLOZKA"

  # Docker vypis jde jen do terminalu, ne do logu
  VYSTUP=$(docker compose pull 2>&1 | tee /dev/tty)

  if echo "$VYSTUP" | grep -q " Pulled"; then
    echo "Aktualizuji $SLUZBA..."
    docker compose up -d

    AKTUALIZOVANE_SLUZBY+=("$SLUZBA")
  else
    echo "$SLUZBA je aktualni."
  fi
done

# Shrnutí jen do logu (a trochu i do terminalu)
if [ "${#AKTUALIZOVANE_SLUZBY[@]}" -gt 0 ]; then
  echo "[$DATUM] Aktualizovane sluzby:" | tee -a "$LOG"
  for S in "${AKTUALIZOVANE_SLUZBY[@]}"; do
    echo "  - $S" | tee -a "$LOG"
  done
  docker image prune -f > /dev/null 2>&1
else
  echo "[$DATUM] Nebyly nalezeny zadne aktualizace" | tee -a "$LOG"
fi

echo "[$DATUM] Aktualizace Dockeru dokoncena" | tee -a "$LOG"
echo "----------------------------------------" >> "$LOG"
