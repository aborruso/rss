#!/bin/bash

### requisiti ###
# mlr https://github.com/johnkerl/miller
# xmlstarlet http://xmlstar.sourceforge.net/
# yq https://github.com/kislyuk/yq
### requisiti ###

set -x
set -e
set -u
set -o pipefail

git pull

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="api-developers-italia"

### anagrafica RSS
titolo="ORDINANZE COVID-19 Sicilia"
descrizione="API REST italiane"
selflink="https://aborruso.github.io/rss/api-developers-italia/api-developers-italia.xml"
### anagrafica RSS

# crea cartelle di servizio
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/../../docs/"$nome"



#curl "https://www.regione.sicilia.it/istituzioni/servizi-informativi/decreti-e-direttive?f%5B0%5D=category%3A37&f%5B1%5D=group%3A3" | scrape -be '//div[@class="it-content__wrapper"]//table//tr[position()>1]'  | xq  -c '.html.body.tr[]' | mlr --j2c -N cut -r -f '(#text|a:@href)' then unsparsify then sort -n 100

# URL
URLBase="https://developers.italia.it/it/api"

# estrai codici di risposta HTTP
code=$(curl -s -L -o /dev/null -w "%{http_code}" "$URLBase")

# se il server risponde fai partire lo script
if [ $code -eq 200 ]; then

	curl -kL "$URLBase" >"$folder"/rawdata/tmp.html

	scrape <"$folder"/rawdata/tmp.html -be '//article[a[contains(@class, "mt-auto")] and a[contains(., "leggi")]]' | xq -c '.html.body.article[]|{title:.h1.a."@title",href:("https://developers.italia.it"+.a."@href")}' >"$folder"/processing/"${nome}".jsonl

	mv "$folder"/processing/"${nome}".jsonl "$folder"/../../docs/"$nome"/"${nome}".jsonl

fi
