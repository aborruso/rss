#!/bin/bash

set -x
set -e
set -u
set -o pipefail

git pull

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="twitterOpenDataHotPosts"

### anagrafica RSS
titolo="🔥 Post Twitter caldi a tema Open Data | by onData"
descrizione="Elenco di tweet a tema Open Data che hanno ricevuto almeno 10 cuori o 10 retweet"
titolo_no_covid="🔥 Post Twitter caldi a tema Open Data, senza COVID | by onData"
descrizione_no_covid="Elenco di tweet a tema Open Data che hanno ricevuto almeno 10 cuori o 10 retweet, senza COVID"
selflink="https://aborruso.github.io/rss/twitterOpenDataHotPosts/twitterOpenDataHotPosts_ita.xml"
selflink_no_covid="https://aborruso.github.io/rss/twitterOpenDataHotPosts/twitterOpenDataHotPosts_ita_no_covid.xml"

AUTHOR_NAME="info@ondata.it (Associazione onData)"

title="🔥 Open Data hot twitter posts | by onData"
description="Tweets about open data, which have received at least 10 hearts or retweets, in many languages"
selflinkraw="https://aborruso.github.io/rss/twitterOpenDataHotPosts/twitterOpenDataHotPosts_raw.xml"
### anagrafica RSS

# crea cartelle di servizio
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/../../docs/"$nome"

# se lo script funziona sul PC di andy leggi config locale
if [[ $(hostname) == "DESKTOP-7NVNDNF" ]]; then
  source "$folder"/.config
fi

# query per scaricare i tweet caldi a tema Open Data
query='(min_retweets:10) OR (min_faves:10) opendata OR ("open data") OR ("dati aperti") OR ("dati pubblici") OR ("dato aperto") OR ("dato pubblico") OR ("données publiques") OR ("Verwaltungsdaten festgelegt") OR ("offene Verwaltungsdaten") OR ("DATOS ABIERTOS") OR ("avoin data") OR "avoindata" OR "datosabiertos" OR DadesObertes OR dadosabertos OR ("dados abertos")'

# scarica i tweet a partire dalla query di sopra
twarc --consumer_key "$CONSUMER_KEY" --consumer_secret "$CONSUMER_SECRET" --access_token "$ACCESS_TOKEN" --access_token_secret "$ACCESS_TOKEN_SECRET" search "$query" >"$folder"/rawdata/latest.jsonl

# converti i tweet scaricati da JSON a CSV
mlr --j2c cut -o -f id,lang,created_at,full_text then put -S '$URL="https://twitter.com/user/status/".$id' "$folder"/rawdata/latest.jsonl >"$folder"/rawdata/latest.csv

# crea archivio tweet
# se il file di archivio non esiste crealo a partire da quello scaricato
if [ ! -f "$folder"/processing/archive.csv ]; then
  cp "$folder"/rawdata/latest.csv "$folder"/processing/archive.csv
# altrimenti fai il merge dell'archivio con quello scaricato, estrai solo dati univoci e ordina per id in modo decrescente
else
  mlr --csv cat then uniq -a then sort -nr id "$folder"/rawdata/latest.csv "$folder"/processing/archive.csv >"$folder"/rawdata/tmp.csv
  mv "$folder"/rawdata/tmp.csv "$folder"/processing/archive.csv
fi

# estrai righe da pubblicare
mlr --csv head -n 100 "$folder"/processing/archive.csv >"$folder"/rawdata/tmp_pub.csv

# se non esiste, crea file vuoto per archiviare id dei tweet che sono già stati tradotti in italiano
if [ ! -f "$folder"/processing/ita_check.csv ]; then
  touch "$folder"/processing/ita_check.csv
fi

# estrai soltanto i record per i quali non risulta una traduzione italiana
mlr --csv join --np --ul -j "id" -f "$folder"/rawdata/tmp_pub.csv then unsparsify "$folder"/processing/ita_check.csv >"$folder"/rawdata/tmp_pub_ita_2_tra.csv

# conta le righe da tradurre
contarighe=$(wc -l <"$folder"/rawdata/tmp_pub_ita_2_tra.csv)
# se sono maggiori di zero allora traducile
if [ "$contarighe" -gt 0 ]; then
  mlr --csv put -S '$titolo=system("trans -b -t italian '\''".gsub($full_text,"'\''","'\''\\'\'''\''")."'\''")' "$folder"/rawdata/tmp_pub_ita_2_tra.csv >"$folder"/rawdata/tmp_pub_ita.csv
else
  echo "non traduco"
fi

# se il file di archivio con le traduzioni in italiano non esiste, creane uno vuoto
if [ ! -f "$folder"/processing/archive_ita.csv ]; then
  touch "$folder"/processing/archive_ita.csv
fi

# crea archivio traduzioni
mlr --csv uniq -a then sort -nr id "$folder"/rawdata/tmp_pub_ita.csv "$folder"/processing/archive_ita.csv >"$folder"/rawdata/tmp.csv
mv "$folder"/rawdata/tmp.csv "$folder"/processing/archive_ita.csv

# aggiorna file con gli id dei tweet già tradotti
mlr --csv filter -S '$titolo=~".+"' then cut -f id then uniq -a then sort -nr id "$folder"/processing/archive_ita.csv >"$folder"/processing/ita_check.csv

# RSS

# estrai dati per feed in italiano
mlr --csv head -n 100 then put -S '$rssDate = strftime(strptime($created_at, "%a %b %d %H:%M:%S +0000 %Y"),"%Y-%m-%dT%H:%M:%SZ")' then cut -o -f titolo,URL,rssDate,id,lang then label description,link,pubDate,title,lang then put '$guid=$link' then put -S '$title="#".$lang." @ ".$title' then cut -x -f lang "$folder"/processing/archive_ita.csv >"$folder"/rawdata/data_ita.csv

# rimuovi righe con traduzione non fatta
mlr -I --csv filter -S '$description=~".+"' "$folder"/rawdata/data_ita.csv
mlr -I --csv filter -S '$titolo=~".+"' "$folder"/processing/archive_ita.csv

# crea feed RSS con testi dei tweet tradotti in italiano
if [ -f "$folder"/../../docs/"$nome"/"$nome"_ita.xml ]; then
  rm "$folder"/../../docs/"$nome"/"$nome"_ita.xml
fi
ogr2ogr -f geoRSS -dsco TITLE="$titolo" -dsco LINK="$selflink" -dsco DESCRIPTION="$descrizione" -dsco AUTHOR_NAME="$AUTHOR_NAME" "$folder"/../../docs/"$nome"/"$nome"_ita.xml "$folder"/rawdata/data_ita.csv -oo AUTODETECT_TYPE=YES

# crea feed RSS con testi dei tweet tradotti in italiano, senza COVID-19

<"$folder"/rawdata/data_ita.csv mlr --csv filter -x 'tolower($description)=~"(covid|pandemi|vaccin|sarscov|contagi)"' >"$folder"/rawdata/data_ita_no_covid.csv

ogr2ogr -f geoRSS -dsco TITLE="$titolo_no_covid" -dsco LINK="$selflink_no_covid" -dsco DESCRIPTION="$descrizione_no_covid" -dsco AUTHOR_NAME="$AUTHOR_NAME" "$folder"/../../docs/"$nome"/"$nome"_ita_no_covid.xml "$folder"/rawdata/data_ita_no_covid.csv -oo AUTODETECT_TYPE=YES

# crea feed RSS in lingua originale
mlr --csv head -n 100 then rename full_text,description,URL,link,id,title then put -S '$guid=$link;$title="@ ".$title;$pubDate = strftime(strptime($created_at, "%a %b %d %H:%M:%S +0000 %Y"),"%Y-%m-%dT%H:%M:%SZ")' then put -S '$title="#".$lang." ".$title' then cut -x -f created_at,lang "$folder"/processing/archive.csv >"$folder"/rawdata/data.csv

if [ -f "$folder"/../../docs/"$nome"/"$nome"_raw.xml ]; then
  rm "$folder"/../../docs/"$nome"/"$nome"_raw.xml
fi
ogr2ogr -f geoRSS -dsco TITLE="$title" -dsco LINK="$selflinkraw" -dsco DESCRIPTION="$description" -dsco AUTHOR_NAME="$AUTHOR_NAME" "$folder"/../../docs/"$nome"/"$nome"_raw.xml "$folder"/rawdata/data.csv -oo AUTODETECT_TYPE=YES
