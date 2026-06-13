#!/usr/bin/env python3
"""Genera i feed RSS definiti in feeds.toml.

Strategia (vedi LOG.md): alcuni siti bloccano/corrompono il fetch diretto di
rsspls dagli IP di GitHub Actions. Si scarica quindi l'HTML con curl passando
da un proxy (variabile d'ambiente PROXY_URL), poi rsspls lavora sul file
locale (file://). Il <link> del canale viene riportato all'URL reale.

Date testuali: rsspls (time-rs) non parsa i nomi di mese localizzati (es.
italiano "giugno"). Se un feed dichiara [feed.text_date] con un `selector`, le
date vengono estratte dall'HTML con scrape, interpretate con dateparser
(multilingua, gestisce anche date relative come "ieri") e iniettate come
<pubDate> negli item (in ordine). Il selettore deve restituire una data per
item, nello stesso ordine degli item. Lingue opzionali via `languages`
(default ["it"]).

Uso:
    PROXY_URL="<prefisso-proxy>?url=" python build-feeds.py
Il valore di PROXY_URL è tenuto in un secret di repo. Può essere vuota: in
tal caso il fetch è diretto.
"""
import datetime
import email.utils
import json
import os
import pathlib
import subprocess
import sys
import tomllib
import xml.etree.ElementTree as ET

import dateparser
from dateparser.search import search_dates
import tomli_w

UA = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36")

ROOT = pathlib.Path(__file__).resolve().parent.parent
CONFIG = ROOT / "feeds.toml"
FETCHED = ROOT / "fetched"
OUTPUT = ROOT / "output"
RUNTIME = ROOT / "feeds.runtime.toml"


def fetch(url: str, dest: pathlib.Path) -> None:
    proxy = os.environ.get("PROXY_URL", "")
    src = f"{proxy}{url}" if proxy else url
    subprocess.run(
        ["curl", "--retry", "5", "--retry-delay", "3", "--fail",
         "-sSL", "--max-time", "60", "-A", UA, src, "-o", str(dest)],
        check=True,
    )


def _all_text(node) -> str:
    """Concatena ricorsivamente il testo di una struttura scrape -j."""
    if isinstance(node, str):
        return node + " "
    if isinstance(node, list):
        return "".join(_all_text(x) for x in node)
    if isinstance(node, dict):
        return "".join(_all_text(v) for k, v in node.items()
                       if not k.startswith("@"))
    return ""


def scrape_elements(html: pathlib.Path, css: str):
    """Ritorna il testo concatenato di ogni elemento che matcha il selettore,
    in ordine di documento."""
    out = subprocess.run(["scrape", "-je", css, str(html)],
                         capture_output=True, text=True, check=True).stdout
    body = json.loads(out).get("html", {}).get("body", {})
    elems = []
    for tag, val in body.items():
        if tag.startswith("@") or tag == "#text":
            continue
        elems.extend(val if isinstance(val, list) else [val])
    return [_all_text(e) for e in elems]


def text_date_to_rfc822(text: str, languages, date_order="DMY"):
    """'12 giugno 2026' -> 'Fri, 12 Jun 2026 00:00:00 +0000'. None se non parsa.

    Usa dateparser, che gestisce nomi di mese localizzati, vari formati e date
    relative ('ieri', '2 giorni fa'), anche con i componenti in ordine non
    canonico (es. 'giugno2026 12'). Se il testo contiene più date o testo
    contorno (es. una cella 'inizio - fine'), ripiega su search_dates e prende
    la prima data trovata.

    date_order conta solo per date NUMERICHE ambigue (es. 11/06): 'DMY'
    (Italia/Europa, default), 'MDY' (USA), 'YMD' (ISO). Va verificato per sito."""
    langs = languages or ["it"]
    settings = {"DATE_ORDER": date_order}
    dt = dateparser.parse(text.strip(), languages=langs, settings=settings)
    if dt is None:
        found = search_dates(text, languages=langs, settings=settings)
        if found:
            dt = found[0][1]
    if not dt:
        return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=datetime.timezone.utc)
    return email.utils.format_datetime(dt)


def inject_pubdates(rss: pathlib.Path, dates: list, languages,
                    date_order="DMY") -> None:
    """Aggiunge <pubDate> agli item del feed, in ordine. Salta se i conteggi
    non combaciano (per non disallineare le date)."""
    tree = ET.parse(rss)
    items = tree.findall(".//item")
    if len(items) != len(dates):
        print(f"::warning::{rss.name}: {len(items)} item ma {len(dates)} date, "
              "salto l'iniezione delle date", file=sys.stderr)
        return
    n = 0
    for item, raw in zip(items, dates):
        if item.find("pubDate") is not None:
            continue
        rfc = text_date_to_rfc822(raw, languages, date_order)
        if not rfc:
            continue
        ET.SubElement(item, "pubDate").text = rfc
        n += 1
    tree.write(rss, encoding="utf-8", xml_declaration=True)
    print(f"{rss.name}: iniettate {n} date")


def validate(path: pathlib.Path) -> int:
    """Ritorna il numero di item; solleva su XML malformato."""
    tree = ET.parse(path)
    return len(tree.findall(".//item"))


def main() -> int:
    with open(CONFIG, "rb") as fh:
        cfg = tomllib.load(fh)

    feeds = cfg.get("feed", [])
    if not feeds:
        print("::error::nessun feed in feeds.toml", file=sys.stderr)
        return 1

    FETCHED.mkdir(exist_ok=True)
    OUTPUT.mkdir(exist_ok=True)

    meta = {}
    active = []
    for feed in feeds:
        fn = feed["filename"]
        # un feed può restare in anagrafica ma essere disabilitato
        if not feed.pop("enabled", True):
            print(f"skip (disabilitato): {fn}")
            continue
        url = feed["config"]["url"]
        html = FETCHED / f"{fn}.html"
        print(f"fetch {url} -> {html.name}")
        fetch(url, html)
        # estrai la config opzionale per le date testuali PRIMA di passare a
        # rsspls (che non conosce questa chiave)
        td = feed.pop("text_date", None)
        meta[fn] = (url, html.resolve(), td)
        feed["config"]["url"] = f"file://{html.resolve()}"
        active.append(feed)

    if not active:
        print("nessun feed attivo da generare")
        return 0

    cfg["feed"] = active
    cfg.setdefault("rsspls", {})["file_urls"] = True
    with open(RUNTIME, "wb") as fh:
        tomli_w.dump(cfg, fh)

    subprocess.run(
        ["rsspls", "-c", str(RUNTIME), "-o", str(OUTPUT)], check=True)

    fail = False
    for fn, (url, html, td) in meta.items():
        rss = OUTPUT / fn
        if not rss.exists():
            print(f"::error::{fn} non generato", file=sys.stderr)
            fail = True
            continue
        # riporta il <link> del canale all'URL reale
        text = rss.read_text(encoding="utf-8").replace(f"file://{html}", url)
        rss.write_text(text, encoding="utf-8")
        # date testuali: estrai e inietta i pubDate
        if td and td.get("selector"):
            dates = scrape_elements(html, td["selector"])
            inject_pubdates(rss, dates, td.get("languages"),
                            td.get("date_order", "DMY"))
        try:
            n = validate(rss)
        except ET.ParseError as exc:
            print(f"::error::{fn} non è XML ben formato: {exc}", file=sys.stderr)
            fail = True
            continue
        print(f"{fn}: {n} item")
        if n < 1:
            print(f"::error::{fn} ha 0 item", file=sys.stderr)
            fail = True

    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main())
