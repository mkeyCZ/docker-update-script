# Docker Auto Update Script

Tento skript slouží k automatické aktualizaci pouze vybraných Docker projektů
(definovaných jako adresáře s `docker-compose.yml`). Tento skript předpokládá, že instalujete dockery pomocí docker-compose.

Nahrazuje Watchtower jednoduše, bezpečně a bez závislosti na cizím kontejneru.

---

## Jak to funguje

Skript:

1. Má pevně daný seznam adresářů, které se smí aktualizovat.
2. Pro každý z nich:

   * provede `docker compose pull`,
   * pokud se stáhne novější image, provede `docker compose up -d`.
3. Pokud se něco aktualizovalo, smaže staré image (`docker image prune -f`).
4. Vše loguje do souboru.

Adresáře, které nejsou v seznamu, se nikdy nedotknou
(např. Nextcloud, Portainer, Plex atd.).

---

## Struktura adresářů

Předpoklad:

```
/home/&USER/docker/
├─ audiobookshelf/
├─ calibre-web/
├─ nextcloud/
├─ nginx/
├─ vaultwarden/
└─ ...
```

Každý projekt má svůj vlastní `docker-compose.yml`.

---

## Nastavení whitelistu

V horní části skriptu je seznam:

```bash
UPDATE_LIST=(
  audiobookshelf
  calibre-web
  flatnotes
  glance
  homebridge
  miniflux
  nginx
  vaultwarden
  rustdesk
)
```

Pouze tyto složky se budou aktualizovat.
Chceš-li něco přidat → přidáš jméno složky.
Chceš-li něco zakázat → odebereš ho ze seznamu.

---

## Logování

Skript zapisuje výchozí logy do:

```
/var/log/docker-update.log
```

Příklad:

```
[2026-01-13 04:00:01] Checking nginx
[2026-01-13 04:00:12] Update found in nginx
[2026-01-13 04:00:30] Docker update finished
```

---

## Spuštění ručně

```bash
bash docker-update.sh
```

---

## Automatické spouštění (cron)

```bash
crontab -e
```

a přidej:

```bash
0 4 * * * /home/&USER/scripts/docker-update.sh
```

Každý den ve 4:00 ráno.

---

## Výhody oproti Watchtower

* žádný neudržovaný kontejner,
* žádný Docker socket v kontejneru,
* plná kontrola nad tím, co se smí aktualizovat,
* čitelné logy,
* produkčně bezpečné chování.

---

## Doporučení

Kritické služby aktualizuj ručně:

* nextcloud
* portainer
* homeassistant

Všechno ostatní klidně automaticky přes tento skript.
