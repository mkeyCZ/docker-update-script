## Použití docker-update.sh

Tento skript slouží k automatické kontrole a aktualizaci vybraných Docker projektů pomocí `docker compose`. Aktualizace proběhne pouze tehdy, pokud se skutečně změní image (na základě porovnání digestů).

### Požadavky

* Linux
* Docker + Docker Compose v2 (`docker compose`)
* Bash 4+ (kvůli asociativním polím)
* Přístup k Docker socketu (uživatel v group `docker` nebo spuštění přes root)

---

### 1. Naklonování projektu

```bash
git clone https://github.com/mkeyCZ/docker-update-script.git
cd docker-update-script
```

---

### 2. Konfigurace skriptu

Otevři soubor `docker-update.sh` a uprav tyto proměnné podle svého prostředí:

```bash
# Kde jsou uloženy Docker projekty
ZAKLADNI_SLOZKA="/home/mates/docker"

# Kam se zapisuje log
LOG="/home/mates/update-docker-script/docker-update.log"

# Whitelist složek, které se mají aktualizovat
AKTUALIZOVAT=(
  flatnotes
  glance
  homebridge
  miniflux
)
```

Význam:

* `ZAKLADNI_SLOZKA`
  Nadřazená složka, kde máš jednotlivé Docker projekty (každý projekt ve vlastní podsložce).

* `LOG`
  Cesta k souboru, kam se zapisuje shrnutí běhu skriptu.

* `AKTUALIZOVAT`
  Seznam podsložek, které se budou kontrolovat a případně aktualizovat.
  Slouží jako „whitelist“, takže se nikdy nesáhne na jiné projekty.

Každá složka v seznamu musí obsahovat soubor:

```text
docker-compose.yml
```

---

### 3. Nastavení spustitelnosti

```bash
chmod +x docker-update.sh
```

---

### 4. Ruční spuštění

```bash
./docker-update.sh
```

Do terminálu se vypisuje průběh kontroly a `docker compose pull`.
Do logu se ukládá pouze shrnutí (které služby byly aktualizovány / zda nebyly nalezeny žádné změny).

---

### 5. Automatické spouštění pomocí cronu

Např. denně ve 3:00 ráno:

```bash
crontab -e
```

a přidej:

```bash
0 3 * * * /home/mates/update-docker-script/docker-update.sh
```

Doporučení:

* Použij absolutní cesty.
* Ověř, že cron má přístup k Dockeru (často je nutné, aby byl uživatel v group `docker`).

---

### Chování skriptu v kostce

1. Projde jen složky definované v `AKTUALIZOVAT`.
2. Zjistí aktuální digest image.
3. Provede `docker compose pull`.
4. Znovu zjistí digest image.
5. Pokud se digest změnil:

   * provede `docker compose up -d`
   * zapíše službu do logu jako aktualizovanou.
6. Pokud se nic nezměnilo:

   * služba se nerestartuje.
7. Na konci:

   * provede `docker image prune -f` (odstranění nepoužívaných image),
   * zapíše shrnutí do logu.

Tímto způsobem se kontejnery restartují pouze tehdy, když skutečně existuje nová verze image.
