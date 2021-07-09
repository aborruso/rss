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

nome="ordinanzeCovidRegioneSiciliana"

### anagrafica RSS
titolo="ORDINANZE COVID-19 Sicilia"
descrizione="Le ordinanze pubblicate dalla Regione Siciliana"
selflink="https://aborruso.github.io/rss/ordinanzeCovidRegioneSiciliana/ordinanzeCovidRegioneSiciliana.xml"
### anagrafica RSS

# crea cartelle di servizio
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/../../docs/"$nome"

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


 #curl "https://www.regione.sicilia.it/istituzioni/servizi-informativi/decreti-e-direttive?f%5B0%5D=category%3A37&f%5B1%5D=group%3A3" | scrape -be '//div[@class="it-content__wrapper"]//table//tr[position()>1]'  | xq  -c '.html.body.tr[]' | mlr --j2c -N cut -r -f '(#text|a:@href)' then unsparsify then sort -n 100

# URL
URLBase="https://www.regione.sicilia.it/istituzioni/servizi-informativi/decreti-e-direttive?f%5B0%5D=category%3A37&f%5B1%5D=group%3A3"

# estrai codici di risposta HTTP
code=$(curl -s -L -o /dev/null -w "%{http_code}" "$URLBase")

# se il server risponde fai partire lo script
if [ $code -eq 200 ]; then

	curl -kL "$URLBase" | \
	scrape -be '//div[@class="it-content__wrapper"]//table//tbody/tr'  | \
	xq  -c '.html.body.tr[]' | \
	mlr --j2t -N  cut -r -f '(#text|a:@href)' then \
	unsparsify then \
	label id,title,datetime,datap,category,ente,href then \
	put '$datetime = strftime(strptime($datetime, "%d/%m/%Y"),"%a, %d %b %Y %H:%M:%S %z")' then \
	cut -o -f href,title,datap,datetime then \
	put -S '$href="https://www.regione.sicilia.it".$href' >"$folder"/rawdata/source.tsv

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

	# pubblica il file
	cp "$folder"/processing/feed.xml "$folder"/../../docs/"$nome"/"$nome".xml

fi
