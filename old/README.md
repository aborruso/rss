# Archivio progetti precedenti

Questa cartella conserva il materiale del vecchio progetto, **non più funzionante**.
È tenuta solo come archivio: gli script non sono più eseguiti e i workflow sono stati
spostati fuori da `.github/` per disattivarli.

## Feed prodotti (storici)

| Nome | Sorgente | Descrizione |
|------|----------|-------------|
| `ordinanzeCovidRegioneSiciliana` | [portale Regione Siciliana](https://pti.regione.sicilia.it/portal/page/portal/PIR_PORTALE/PIR_Covid19OrdinanzePresidenzadellaRegione) | Elenco delle ordinanze COVID-19 della Regione Siciliana |
| `twitterOpenDataHotPosts` | Twitter search | Tweet a tema open data con almeno 10 cuori o retweet |
| `twitterOpenDataHotPostsIta` | Twitter search | Come sopra, tradotti in italiano |
| `twitterOpenDataHotPostsItaNoCovid` | Twitter search | Come sopra, tradotti in italiano, senza COVID |
| `api-developers-italia` | API Developers Italia | Feed dalle API di Developers Italia |

I feed erano pubblicati su GitHub Pages sotto `https://aborruso.github.io/rss/...`.

## Contenuto della cartella

- `script/` — script `.sh` di generazione dei feed e relative risorse (`feedTemplate.xml`).
- `bin/` — binari/strumenti usati dagli script (`mlr` = Miller, `trans` = translate-shell, `scrape`).
- `docs/` — output residui (es. `api-developers-italia/api-developers-italia.jsonl`).
- `workflows/` — i workflow GitHub Actions che schedulavano la generazione (ora disattivati).
- `elenco.yml` — indice dei feed con sorgente, descrizione e URL.
- `script/twitterOpenDataHotPosts/processing/*.csv` — ultima versione dei dati archiviati
  dello scraper Twitter (`archive.csv`, `archive_ita.csv`, `ita_check.csv`). Conservata solo
  l'ultima versione; la cronologia è stata rimossa.

## Nota sulla history

La storia git di questo repository è stata azzerata: tutti i feed XML generati e la cronologia
dei CSV sono stati rimossi per alleggerire il repository. È conservata solo l'ultima versione
dei dati, qui in archivio.
