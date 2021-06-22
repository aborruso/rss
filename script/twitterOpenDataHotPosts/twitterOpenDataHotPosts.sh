#!/bin/bash

set -x
set -e
set -u
set -o pipefail

git pull

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="twitterOpenDataHotPosts"

### anagrafica RSS
titolo="twitter Open Data Hot Posts"
descrizione="I tweet a tema open data, che hanno ricevuto almeno 10 cuori o retweet"
selflink="https://aborruso.github.io/rss/twitterOpenDataHotPosts/twitterOpenDataHotPosts.xml"
### anagrafica RSS

# crea cartelle di servizio
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/../../docs/"$nome"


# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$SUPER_SECRET_TWDATA")

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then
	curl -ksL "$SUPER_SECRET_TWDATA" >"$folder"/rawdata/data.csv
	mlr -I --csv head -n 100 then cut -o -f text,URL,created_at then label title,link,pubDate then put '$guid=$link' "$folder"/rawdata/data.csv

	ogr2ogr -f geoRSS -dsco TITLE="$titolo" -dsco LINK="$selflink" -dsco DESCRIPTION="$descrizione" "$folder"/../../docs/"$nome"/"$nome".xml "$folder"/rawdata/data.csv -oo AUTODETECT_TYPE=YES
fi



