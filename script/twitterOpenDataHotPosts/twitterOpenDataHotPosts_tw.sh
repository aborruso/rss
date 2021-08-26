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
selflink="https://aborruso.github.io/rss/twitterOpenDataHotPosts/twitterOpenDataHotPosts_ita.xml"
### anagrafica RSS

# crea cartelle di servizio
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/../../docs/"$nome"

if [[ $(hostname) == "DESKTOP-7NVNDNF" ]]; then
  source "$folder"/.config
fi

query='(min_retweets:10) OR (min_faves:10) opendata OR ("open data") OR ("dati aperti") OR ("dati pubblici") OR ("dato aperto") OR ("dato pubblico") OR ("données publiques") OR ("Verwaltungsdaten festgelegt") OR ("offene Verwaltungsdaten") OR ("DATOS ABIERTOS") OR ("avoin data") OR "avoindata" OR "datosabiertos" OR DadesObertes OR dadosabertos OR ("dados abertos")'

twarc --consumer_key "$CONSUMER_KEY" --consumer_secret "$CONSUMER_SECRET" --access_token "$ACCESS_TOKEN" --access_token_secret "$ACCESS_TOKEN_SECRET" search "$query" >"$folder"/rawdata/latest.jsonl

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

# crea file di check se non esiste
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

# se il file di archivio con le traduzioni non esiste, crealo
if [ ! -f "$folder"/processing/archive_ita.csv ]; then
  touch "$folder"/processing/archive_ita.csv
fi

# crea archivio traduzioni
mlr --csv uniq -a then sort -nr id "$folder"/rawdata/tmp_pub_ita.csv "$folder"/processing/archive_ita.csv >"$folder"/rawdata/tmp.csv
mv "$folder"/rawdata/tmp.csv "$folder"/processing/archive_ita.csv

# aggiorna file check traduzioni
mlr --csv filter -S '$titolo=~".+"' then cut -f id then uniq -a then sort -nr id "$folder"/processing/archive_ita.csv >"$folder"/processing/ita_check.csv

# RSS

# estrai dati per feed in italiano
mlr --csv head -n 100 then put -S '$rssDate = strftime(strptime($created_at, "%a %b %d %H:%M:%S +0000 %Y"),"%Y-%m-%dT%H:%M:%SZ")' then cut -o -f titolo,URL,rssDate,id then label description,link,pubDate,title then put '$guid=$link' then put -S '$title="@ ".$title' "$folder"/processing/archive_ita.csv>"$folder"/rawdata/data_ita.csv

# rimuovi righe con traduzion non fatta
mlr -I --csv filter -S '$description=~".+"' "$folder"/rawdata/data_ita.csv
mlr -I --csv filter -S '$titolo=~".+"' "$folder"/processing/archive_ita.csv

# crea feed RSS
ogr2ogr -f geoRSS -dsco TITLE="$titolo" -dsco LINK="$selflink" -dsco DESCRIPTION="$descrizione" "$folder"/../../docs/"$nome"/"$nome"_ita.xml "$folder"/rawdata/data_ita.csv -oo AUTODETECT_TYPE=YES

# crea fee RSS in lingua orignale
mlr --csv head -n 100 then rename full_text,description,URL,link,id,title then put -S '$guid=$link;$title="@ ".$title;$pubDate = strftime(strptime($created_at, "%a %b %d %H:%M:%S +0000 %Y"),"%Y-%m-%dT%H:%M:%SZ")' then cut -x -f lang,created_at "$folder"/processing/archive.csv >"$folder"/rawdata/data.csv

ogr2ogr -f geoRSS -dsco TITLE="$titolo" -dsco LINK="$selflink" -dsco DESCRIPTION="$descrizione" "$folder"/../../docs/"$nome"/"$nome"_raw.xml "$folder"/rawdata/data.csv -oo AUTODETECT_TYPE=YES
