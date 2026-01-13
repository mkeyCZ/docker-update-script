#!/bin/bash
set -e

# ==========================================
# Nastaveni
# ==========================================

# Kde jsou docker projekty
ZAKLADNI_SLOZKA="/home/mates/docker"

# Kam se zapisuje cisty log
LOG="/home/mates/update-docker-script/docker-update.log"

# Cas
DATUM=$(date '+%Y-%m-%d %H:%M:%S')

# Whitelist slozek, ktere se mohou aktualizovat
AKTUALIZOVAT=(
  flatnotes
  glance
  homebridge
  miniflux
)

# ==========================================
# Funkce
# ==========================================

# Ziska ID image (digest) – prazdne pokud image neexistuje
ZISKEJ_DIGEST() {
  docker inspect --format='{{.Id}}' "$1" 2>/dev/null || echo ""
}

# ==========================================
# Start
# ==========================================

echo "[$DATUM] Spoustim aktualizaci Dockeru" | tee -a "$LOG"

AKTUALIZOVANE_SLUZBY=()

for SLUZBA in "${AKTUALIZOVAT[@]}"; do
  SLOZKA="$ZAKLADNI_SLOZKA/$SLUZBA"

  # Kontroly
  [ -d "$SLOZKA" ] || continue
  [ -f "$SLOZKA/docker-compose.yml" ] || continue

  echo
  echo "Kontroluji sluzbu: $SLUZBA"
  cd "$SLOZKA"

  # Ziskame seznam imagu pouzitych v compose
  IMAGES=$(docker compose config | grep 'image:' | awk '{print $2}')

  # Ulozime stare digesty
  declare -A OLD_DIGESTS
  for IMG in $IMAGES; do
    OLD_DIGESTS["$IMG"]="$(ZISKEJ_DIGEST "$IMG")"
  done

  # Docker vypis jde jen do terminalu (ne do logu)
  docker compose pull

  UPDATED=false

  # Porovname digesty po pullu
  for IMG in $IMAGES; do
    NEW_DIGEST="$(ZISKEJ_DIGEST "$IMG")"
    if [ "${OLD_DIGESTS[$IMG]}" != "$NEW_DIGEST" ]; then
      UPDATED=true
      break
    fi
  done

  if [ "$UPDATED" = true ]; then
    echo "Dosla nova verze, aktualizuji $SLUZBA..."
    docker compose up -d
    AKTUALIZOVANE_SLUZBY+=("$SLUZBA")
  else
    echo "$SLUZBA je aktualni, neni co delat."
  fi
done

# ==========================================
# Log – pouze shrnuti
# ==========================================

if [ "${#AKTUALIZOVANE_SLUZBY[@]}" -gt 0 ]; then
  echo "[$DATUM] Aktualizovane sluzby:" >> "$LOG"
  for S in "${AKTUALIZOVANE_SLUZBY[@]}"; do
    echo "  - $S" >> "$LOG"
  done

  # Uklid nepouzivanych imagu
  docker image prune -f >> "$LOG" 2>&1
else
  echo "[$DATUM] Nebyly nalezeny zadne aktualizace" >> "$LOG"
fi

echo "[$DATUM] Aktualizace Dockeru dokoncena" >> "$LOG"
echo "----------------------------------------" >> "$LOG"
