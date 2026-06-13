# LOG

## 2026-06-13 — terzo feed (Agira albo pretorio) + robustezza date

- Aggiunto feed **Agira — Albo pretorio** (piattaforma JCityGov/Maggioli) testando la skill.
- Caso nuovo: agent-browser **bloccato** ("URL blocked"), ma curl/proxy ottiene l'HTML reale.
  → skill aggiornata: se il browser è bloccato, analizzare l'HTML da curl/proxy.
- Date numeriche europee: forzato `DATE_ORDER=DMY` (11/06/2026 = 11 giugno, non 6 nov).
- Celle con due date (inizio/fine): `search_dates` prende la prima (data pubblicazione).

## 2026-06-13 — secondo feed (RAP) + date testuali

- Aggiunto feed **RAP — Comunicati stampa** testando la skill rss-creator.
- RAP è statico, piattaforma custom, nessun feed nativo; date con mese in italiano.
- rsspls/time-rs non parsa i mesi localizzati → aggiunto supporto `[feed.text_date]`:
  `bin/build-feeds.py` estrae le date con scrape e le interpreta con **dateparser**
  (multilingua, date relative), iniettandole come `<pubDate>`.
- Skill aggiornata: Fase 0 ora parte da agent-browser; sezione date testuali con dateparser.

## 2026-06-13 — skill rss-creator + fetch via proxy (fase 3)

- Feed AMAP **online** su Pages: https://aborruso.github.io/rss/amapspa-comunicazioni.rss (10 item).
- Fetch in CI risolto: `bin/build-feeds.py` scarica con curl via proxy (secret `PROXY_URL`) →
  rsspls legge da `file://` → ripristina i link → valida. Motivo: AMAP blocca/comprime
  male verso gli IP di GitHub Actions; curl via Cloudflare è affidabile.
- Creata skill **rss-creator** (`.claude/skills/rss-creator/`) conforme a agentskills spec:
  pre-flight feed esistente → esplora (statico/JS con agent-browser) → mappa campi →
  scala rsspls/scrape/browser → integra in feeds.toml.
- `refs/rsspls-docs.md` scaricata con repomix dal repo del sito rsspls.
- Proxy = mio-proxy (github.com/aborruso/mio-proxy), Cloudflare Worker.

## 2026-06-13 — repo generico feed RSS (fase 2)

- Aggiunto primo feed reale: **AMAP — Comunicazioni** (`feeds.toml`).
- Workflow `build-feeds.yml`: rsspls + validazione (XML + item>0) + deploy su GitHub Pages ogni 6h.
- Scelta hosting: `.rss` NON versionati, serviti da Pages (`output/` in `.gitignore`).
- Pre-analisi AMAP validata con agent-browser + scrape: HTML statico, nessun feed nativo.
- Spec skill in `refs/agentskills-specification.md` (la skill del repo dovrà seguirla).
- PoC locale ok: feed generato con 10 item, XML ben formato.

## 2026-06-13

- Riconversione del repo a **repo generico per feed RSS**. Progetto storico non più funzionante.
- History git **azzerata** (da 580 commit a 1 commit iniziale): rimossa la cronologia pesante
  dei CSV (~205 MB) e dei feed XML generati (~49 MB).
- 5 feed XML generati in `docs/` **cancellati**; tenuti i 2 `feedTemplate.xml`.
- 3 CSV dello scraper Twitter: conservata **solo l'ultima versione**, archiviata in `old/`.
- Tutto il vecchio progetto spostato in `old/` con `old/README.md` descrittivo.
- Backup di sicurezza pre-pulizia: `/tmp/rss_repo_backup.git` (mirror) e `/tmp/rss_csv_backup/`.
- Feed storici: `api-developers-italia` era l'ultimo ancora attivo (ultimo update 2022-11-25).
- Per i feed futuri: conservare solo l'ultima versione, niente storia (workflow di
  rigenerazione/squash da definire).
