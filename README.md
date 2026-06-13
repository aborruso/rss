# rss

Repository per creare, gestire e archiviare uno o più feed RSS, generati da
pagine web che non ne hanno uno (o lo hanno disabilitato).

I feed vengono rigenerati periodicamente da GitHub Actions e pubblicati su
**GitHub Pages**. I file `.rss` **non** sono versionati nel repo: ne esiste
sempre e solo l'ultima versione, servita da Pages. Nel repository restano solo
le configurazioni e i workflow.

## Come funziona

- [`feeds.toml`](./feeds.toml) — configurazione [rsspls](https://github.com/wezm/rsspls):
  un blocco `[[feed]]` per ogni feed.
- [`.github/workflows/build-feeds.yml`](./.github/workflows/build-feeds.yml) —
  ogni 6 ore (e a ogni modifica di `feeds.toml`) genera i feed, li valida
  (XML ben formato + almeno un item) e li pubblica su Pages.

## Feed attivi

| Feed | Sorgente | Output |
|------|----------|--------|
| AMAP — Comunicazioni | https://www.amapspa.it/comunicazioni/ | [`amapspa-comunicazioni.rss`](https://aborruso.github.io/rss/amapspa-comunicazioni.rss) |
| RAP — Comunicati stampa | https://www.rapspa.it/comunicati-stampa | [`rapspa-comunicati-stampa.rss`](https://aborruso.github.io/rss/rapspa-comunicati-stampa.rss) |

I feed con `enabled = false` in `feeds.toml` restano registrati ma non vengono
generati (es. Agira — Albo pretorio).

## Aggiungere un feed

1. Aggiungere un blocco `[[feed]]` a `feeds.toml` (vedi
   [documentazione selettori](https://rsspls.7bit.org/documentation/)).
2. Commit + push: il workflow genera e pubblica.

Per la pre-analisi di una pagina (capire se esiste già un feed, mappare i
selettori, gestire pagine dinamiche) è prevista una skill dedicata.

## Archivio

- [`old/`](./old/README.md) — progetti precedenti, non più funzionanti.
