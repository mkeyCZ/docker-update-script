#!/bin/bash
set -e

# Zakladni nastaveni
ZAKLADNI_SLOZKA="/home/mates/docker"
LOG="/home/mates/update-docker-script/docker-update.log"
DATUM=$(date '+%Y-%m-%d %H:%M:%S')

# Whitelist slozek, ktere se mohou aktualizovat
AKTUALIZOVAT=(
  flatnotes
  glance
  homebridge
  miniflux
)

echo "[$DATUM] Spoustim aktualizaci Dockeru" >> "$LOG"

AKTUALIZOVANE_SLUZBY=()

for SLUZBA in "${AKTUALIZOVAT[@]}"; do
  SLOZKA="$ZAKLADNI_SLOZKA/$SLUZBA"

  # Kontrola existence slozky a docker-compose.yml
  [ -d "$SLOZKA" ] || continue
  [ -f "$SLOZKA/docker-compose.yml" ] || continue

  cd "$SLOZKA"

  # Docker compose V2 uz nepise "Downloaded newer image",
  # ale "Image xxx Pulled", proto hledame " Pulled"
  if docker compose pull 2>&1 | tee -a "$LOG" | grep -q " Pulled"; then
    docker compose up -d >> "$LOG" 2>&1
    AKTUALIZOVANE_SLUZBY+=("$SLUZBA")
  fi
done

# Zapis vysledku do logu
if [ "${#AKTUALIZOVANE_SLUZBY[@]}" -gt 0 ]; then
  echo "[$DATUM] Aktualizovane sluzby:" >> "$LOG"
  for S in "${AKTUALIZOVANE_SLUZBY[@]}"; do
    echo "  - $S" >> "$LOG"
  done

  # Odstraneni starych nepouzivanych imagu
  docker image prune -f >> "$LOG" 2>&1
else
  echo "[$DATUM] Nebyly nalezeny zadne aktualizace" >> "$LOG"
fi

echo "[$DATUM] Aktualizace Dockeru dokoncena" >> "$LOG"
echo "----------------------------------------" >> "$LOG"
