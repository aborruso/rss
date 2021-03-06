#!/bin/bash

set -x
set -e
set -u
set -o pipefail

git pull

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="twitterOpenDataHotPosts"

### anagrafica RSS
titolo="🔥 Open Data hot twitter posts | by onData"
descrizione="Tweets about open data, which have received at least 10 hearts or retweets, in many languages"
selflink="https://aborruso.github.io/rss/twitterOpenDataHotPosts/twitterOpenDataHotPosts.xml"
### anagrafica RSS

# crea cartelle di servizio
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/../../docs/"$nome"

if [[ $(hostname) == "DESKTOP-7NVNDNF" ]]; then
	source "$folder"/.config
	code=$(curl -s -L -o /dev/null -w '%{http_code}' "$SUPER_SECRET_TWDATA")
else
	# leggi la risposta HTTP del sito
	code=$(curl -s -L -o /dev/null -w '%{http_code}' "$SUPER_SECRET_TWDATA")
fi

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then
	curl -ksL "$SUPER_SECRET_TWDATA" >"$folder"/rawdata/data.csv
	mlr -I --csv head -n 100 then cut -o -f text,URL,created_at then label title,link,pubDate then put '$guid=$link' "$folder"/rawdata/data.csv

	ogr2ogr -f geoRSS -dsco TITLE="$titolo" -dsco LINK="$selflink" -dsco DESCRIPTION="$descrizione" "$folder"/../../docs/"$nome"/"$nome".xml "$folder"/rawdata/data.csv -oo AUTODETECT_TYPE=YES
fi
