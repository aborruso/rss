#!/bin/bash

### requisiti ###
# mlr https://github.com/johnkerl/miller
# xmlstarlet http://xmlstar.sourceforge.net/
# jq https://github.com/stedolan/jq
### requisiti ###

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="ordinanzeCovidRegioneSiciliana"

### anagrafica albo
titolo="ORDINANZE COVID-19 Sicilia"
descrizione="Le ordinanze pubblicate dalla Regione Siciliana"
webMaster="aborruso@gmail.com (Andrea Borruso)"
selflink="https://aborruso.github.io/rss/ordinanzeCovidRegioneSiciliana/ordinanzeCovidRegioneSiciliana.xml"
### anagrafica albo

# crea cartelle di servizio
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/../../docs/"$nome"

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# URL
URLBase="https://pti.regione.sicilia.it/portal/page/portal/PIR_PORTALE/PIR_Covid19OrdinanzePresidenzadellaRegione"

# estrai codici di risposta HTTP dell'albo
code=$(curl -s -L -o /dev/null -w "%{http_code}" "$URLBase")

# se il server risponde fai partire lo script
if [ $code -eq 200 ]; then

	curl -kL "$URLBase" | scrape -be '//div[@class="Modulo"]//a' | xq '.html.body.a[]' | mlr --j2t unsparsify then cut -r -f '(href|0:#t)' \
		then label href,title \
		then put '$data=regextract_or_else($title,"[0-9]+-.+[0-9]{4}","")' \
		then clean-whitespace \
		then filter -S '$data=~"^[0-9]+-[0-9]+-[0-9]{4}"' \
		then put '$datetime = strftime(strptime($data, "%d-%m-%Y"),"%a, %d %b %Y %H:%M:%S %z")' \
		then put '$title=gsub($title,"<","&lt")' \
		then put '$title=gsub($title,">","&gt;")' \
		then put '$title=gsub($title,"&","&amp;")' \
		then put '$title=gsub($title,"'\''","&apos;")' \
		then put '$title=gsub($title,"\"","&quot;")' >"$folder"/rawdata/data.tsv

	tail <"$folder"/rawdata/data.tsv -n +2 >"$folder"/rawdata/source.tsv

	# crea copia del template del feed
	cp "$folder"/risorse/feedTemplate.xml "$folder"/processing/feed.xml

	# inserisci gli attributi anagrafici nel feed
	xmlstarlet ed -L --subnode "//channel" --type elem -n title -v "$titolo" "$folder"/processing/feed.xml
	xmlstarlet ed -L --subnode "//channel" --type elem -n description -v "$descrizione" "$folder"/processing/feed.xml
	xmlstarlet ed -L --subnode "//channel" --type elem -n link -v "$selflink" "$folder"/processing/feed.xml
	xmlstarlet ed -L --subnode "//channel" --type elem -n "atom:link" -v "" -i "//*[name()='atom:link']" -t "attr" -n "rel" -v "self" -i "//*[name()='atom:link']" -t "attr" -n "href" -v "$selflink" -i "//*[name()='atom:link']" -t "attr" -n "type" -v "application/rss+xml" "$folder"/processing/feed.xml

	# leggi in loop i dati del file TSV e usali per creare nuovi item nel file XML
	newcounter=0
	while IFS=$'\t' read -r href title data datetime; do
		newcounter=$(expr $newcounter + 1)
		xmlstarlet ed -L --subnode "//channel" --type elem -n item -v "" \
			--subnode "//item[$newcounter]" --type elem -n title -v "$title" \
			--subnode "//item[$newcounter]" --type elem -n description -v "$title" \
			--subnode "//item[$newcounter]" --type elem -n link -v "$href" \
			--subnode "//item[$newcounter]" --type elem -n pubDate -v "$datetime" \
			--subnode "//item[$newcounter]" --type elem -n guid -v "$href" \
			"$folder"/processing/feed.xml
	done <"$folder"/rawdata/source.tsv

	cp "$folder"/processing/feed.xml "$folder"/../../docs/"$nome"/"$nome".xml

fi
