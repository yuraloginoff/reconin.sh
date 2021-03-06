#!/usr/bin/env bash

# Title:         reconin.sh
# Description:   subdomain enumeration & takeover
# Author:        yuraloginoff <yuretsmolodets@yandex.ru>
# Date:          2020-mm-dd
# Version:       1.0.0

# Exit codes
# ==========
# 0   no error
# 1   script interrupted

# >>>>>>>>>>>>>>>>>>>>>>>> Functions >>>>>>>>>>>>>>>>>>>>>>>>

function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

function print_intro () {
  echo -e "\n[i] $1..."
}

function print_outro () {
  if (( $# == 1 )); then
    echo -e "[+] Done! Saved to $1 \n"
  elif (( $# == 2 )); then
    echo -e "[+] Done! Saved $(wc -l "$1") \n"
  else
    echo -e "\nBye! \n"
  fi
}

function banner_simple() {
  local msg="* $* *"
  local edge
  edge=$(echo "$msg" | sed 's/./*/g')

  echo -e "\t$(tput bold)$edge$(tput sgr0)"
  echo -e "\t$(tput bold)$msg$(tput sgr0)"
  echo -e "\t$(tput bold)$edge$(tput sgr0)"
}


# <<<<<<<<<<<<<<<<<<<<<<<< Functions <<<<<<<<<<<<<<<<<<<<<<<<

# Exit if no arguments
if [[ $# -eq 0 ]]; then
  err "Usage: $0 domain.com"
  exit 1
fi

# >>>>>>>>>>>>>>>>>>>>>>>> VARIABLES  >>>>>>>>>>>>>>>>>>>>>>>>

readonly URL=$1
readonly D_NETINFO="./out/$URL/netinfo"
readonly D_SUBS="./out/$URL/subs"
readonly D_SUBS_SRC="./out/$URL/subs/src"
readonly D_DISCOVERY="./out/$URL/discovery"
readonly D_XSS="./out/$URL/discovery/xss"
readonly D_HOSTS="./out/$URL/hosts"

readonly D_NUCL_TMPL="$HOME/Downloads/nuclei-templates"

# <<<<<<<<<<<<<<<<<<<<<<<< VARIABLES  <<<<<<<<<<<<<<<<<<<<<<<<

function main () {

  # make_dirs
  # get_initial_info
  # enumerate_subdomains
  # bruteforce_subdomains
  # subdomains_total
  # subdomain_takeover
  # hosts_portscan
  discovery

}

function make_dirs () {

  [[ ! -d ./out ]] && mkdir ./out
  [[ ! -d ./out/$URL ]] && mkdir ./out/"$URL"
  [[ ! -d ./out/$URL/netinfo ]] && mkdir ./out/"$URL"/netinfo
  [[ ! -d ./out/$URL/subs ]] && mkdir ./out/"$URL"/subs
  [[ ! -d ./out/$URL/subs/src ]] && mkdir ./out/"$URL"/subs/src
  [[ ! -d ./out/$URL/subs/httpx ]] && mkdir ./out/"$URL"/subs/httpx
  [[ ! -d ./out/$URL/subs/takeover ]] && mkdir ./out/"$URL"/subs/takeover
  [[ ! -d ./out/$URL/hosts ]] && mkdir ./out/"$URL"/hosts
  [[ ! -d ./out/$URL/discovery ]] && mkdir ./out/"$URL"/discovery

  [[ ! -d ./out/$URL/discovery/hakrawler ]] \
    && mkdir -p ./out/"$URL"/discovery/hakrawler/req

  [[ ! -d ./out/$URL/discovery/feroxbuster ]] \
    && mkdir ./out/"$URL"/discovery/feroxbuster

  [[ ! -d ./out/$URL/discovery/nuclei ]] \
    && mkdir ./out/"$URL"/discovery/nuclei

  [[ ! -d ./out/$URL/discovery/gau ]] \
    && mkdir ./out/"$URL"/discovery/gau

  [[ ! -d ./out/$URL/discovery/xss ]] \
    && mkdir ./out/"$URL"/discovery/xss

}

function get_initial_info () {

  banner_simple "$URL various info"


  # AS numbers
  # The ASN numbers can be used to find netblocks of the domain
  print_intro 'ASN discovery'
  curl -s "http://ip-api.com/json/$(dig +short "$URL")" \
    | jq -r .as \
    | tee "$D_NETINFO/asn.txt"
  echo
  whois -h whois.radb.net -- "-i origin $(cat "$D_NETINFO/asn.txt" \
    | cut -d ' ' -f 1)" \
    | grep -Eo "([0-9.]+){4}/[0-9]+" \
    | uniq \
    | tee "$D_NETINFO/asn-list.txt"
  print_outro "$D_NETINFO"


  # Subject Alternate Name(SAN)
  # The Subject Alternative Name (SAN) is an extension to the X.509 specification that allows to specify additional host names for a single SSL certificate.
  print_intro 'Extract domain names from Subject Alternate Name'
  python3 \
    ./tools/san_subdomain_enum.py "$URL" \
    | tee "$D_NETINFO/san.txt"
  print_outro "$D_NETINFO/san.txt"


  # SPF record
  # SPF lists all the hosts that are authorised to send emails on behalf of a domain.
  print_intro 'Search for SPF'
  bash ./tools/enum_spf.sh "$URL" | sort | tee "$D_NETINFO/spf.txt"
  print_outro "$D_NETINFO/spf.txt"

}

function enumerate_subdomains () {

  banner_simple "Subdomain Enumeration"


  print_intro 'Starting crt.sh'
  bash ./tools/crtsh_enum_psql.sh "$URL" | tee "$D_SUBS_SRC/crtsh.txt"
  print_outro "$D_SUBS_SRC/crtsh.txt" 'wc'


  print_intro 'Starting DNSdumpster'
  bash ./tools/dnsdumpster/dnsdumpster.sh "$URL" \
    | tee "$D_SUBS_SRC/dnsdumpster.txt"
  print_outro "$D_SUBS_SRC/dnsdumpster.txt" 'wc'


  print_intro 'Starting assetfinder'
  assetfinder --subs-only "$URL" | tee "$D_SUBS_SRC/assetfinder.txt"
  print_outro "$D_SUBS_SRC/assetfinder.txt" 'wc'


  print_intro 'Starting amass'
  amass enum -d "$URL" \
    -config './config/amass/config.ini' \
    -o "$D_SUBS_SRC/amass.txt"
  print_outro "$D_SUBS_SRC/amass.txt" 'wc'


  print_intro 'Starting findomain'
  findomain -t "$URL" -q \
    | tee "./$URL.txt" "$D_SUBS_SRC/findomain.txt"
  print_outro "$D_SUBS_SRC/findomain.txt" 'wc'


  print_intro 'Starting subfinder'
  subfinder -d "$URL" -o "$D_SUBS_SRC/subfinder.txt"
  print_outro "$D_SUBS_SRC/subfinder.txt" 'wc'


  print_intro 'Starting sublist3r'
  python3 ~/.local/bin/sublist3r \
    -d "$URL" -o "$D_SUBS_SRC/sublister.txt"
  print_outro "$D_SUBS_SRC/sublister.txt" 'wc'


  print_intro 'Starting jldc.me'
  curl -s "https://jldc.me/anubis/subdomains/$URL" \
    | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" \
    | tee "$D_SUBS_SRC/jldc.txt"
  print_outro "$D_SUBS_SRC/jldc.txt" 'wc'


  print_intro 'Sorting gathered subdomains'
  cat "$D_SUBS_SRC"/*.txt \
    | grep -v 'www.google.com' \
    | uniq > "$D_SUBS_SRC/subs-src-total.txt"
  print_outro "$D_SUBS_SRC/subs-src-total.txt" 'wc'

}

function bruteforce_subdomains () {

  banner_simple "Subdomains Bruteforce"


  ## check if the target has a wildcard enabled
  if host randomifje8z19td3hf8jafvh7g4q79gh274."$URL" | grep 'not found'; then
    print_intro 'There is no wildcard! Can bruteforce'


    print_intro "Starting dnsgen & massdns"
    cat "$D_SUBS_SRC/subs-src-total.txt" \
      | dnsgen - \
      | massdns -r ~/Downloads/massdns/lists/resolvers.txt \
        -t A -o S --quiet \
        -w "$D_SUBS_SRC/massdns.txt"

    cat "$D_SUBS_SRC/massdns.txt" | awk '{print $1}' | sed 's/\.$//' \
      | uniq >"$D_SUBS_SRC/massdns-resolved.txt"

    print_outro "$D_SUBS_SRC/massdns-resolved.txt" 'wc'
  else
    echo '[-] There is a wildcard! No way for bruteforce. '
  fi

}

function subdomains_total () {

  banner_simple "Subdomains Total"


  cat "$D_SUBS_SRC/massdns-resolved.txt" "$D_SUBS_SRC/subs-src-total.txt" \
    | grep "$URL$" \
    | sort -u \
    | tee "$D_SUBS/subs.txt"
  print_outro "$D_SUBS/subs.txt" 'wc'


  print_intro 'Check subdomains to be live'
  httpx \
    -l "$D_SUBS/subs.txt" \
    -o "$D_SUBS/httpx/httpx.txt" \
    -follow-host-redirects \
    -follow-redirects \
    -content-length \
    -threads 100 \
    -status-code \
    -no-color \
    -silent \
    -ip

  print_outro "$D_SUBS/httpx/httpx.txt" 'wc'

  # sort by status-codes
  grep '\[200\]' "$D_SUBS/httpx/httpx.txt" > "$D_SUBS/httpx/httpx-200.txt"
  grep '\[302\]' "$D_SUBS/httpx/httpx.txt" > "$D_SUBS/httpx/httpx-302.txt"
  grep '\[404\]' "$D_SUBS/httpx/httpx.txt" > "$D_SUBS/httpx/httpx-404.txt"

  ## cut urls with content-length > 0
  grep -v '\[0\]' "$D_SUBS/httpx/httpx-200.txt" \
    | tr -d '[]' \
    | cut -d ' ' -f 1 \
    | sort \
    | tee "$D_SUBS/probed.txt"
  print_outro "$D_SUBS/probed.txt" 'wc'

  ## cut IPs
  tr -d '[]' <"$D_SUBS/httpx/httpx-200.txt" \
    | cut -d ' ' -f 4 \
    | sort -u -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n \
    | tee "./$D_SUBS/ips.txt"
  print_outro "$D_SUBS/ips.txt" 'wc'

  ## cut 404 urls
  tr -d '[]' <"$D_SUBS/httpx/httpx-404.txt" \
    | cut -d ' ' -f 1 \
    > "$D_SUBS/takeover/404.txt"
  print_outro "$D_SUBS/takeover/404.txt" 'wc'

}

function subdomain_takeover () {

  banner_simple "Subdomain Takeover"


  print_intro 'Starting subjack'
  subjack \
    -w "$D_SUBS/takeover/404.txt" \
    -t 100 \
    -timeout 30 \
    -o "$D_SUBS/takeover/subjack.txt" \
    -ssl \
    -c ./config/subjack/fingerprints.json \
    -v


  print_intro 'Starting tko-subs'
  tko-subs \
    -domains="$D_SUBS/takeover/404.txt" \
    -data=./config/tko-subs/providers-data.csv \
    -output="$D_SUBS/takeover/tkosubs.csv"
  echo

}

function hosts_portscan  () {

  banner_simple "Hosts port scan"


  print_intro 'Port scan with Naabu'
  while read -r host; do
    naabu -host "$host" -silent \
      | tee -a "$D_HOSTS/host-ports.txt"
    echo
  done <"$D_SUBS/ips.txt"
  print_outro "$D_HOSTS/host-ports.txt"


  print_intro 'Search for interesting hosts'
  grep -v ':80$' "$D_HOSTS/host-ports.txt" \
    | grep -v ':443' \
    | tee "$D_HOSTS/host-ports-nonhttp.txt"
  print_outro "$D_HOSTS/host-ports-nonhttp.txt"

  if [ -s "$D_HOSTS/host-ports-nonhttp.txt" ]; then
    cat "$D_HOSTS/host-ports-nonhttp.txt" \
      | while read -r line ; do echo "${line%:*}"; done \
      | uniq | tee "$D_HOSTS/hosts-to-nmap.txt"

    print_outro "$D_HOSTS/hosts-to-nmap.txt" 'wc'
  fi

}

function discovery () {

  # banner_simple "Discovery"


  # httpx \
  #   -title \
  #   -silent \
  #   -no-color \
  #   -status-code \
  #   -content-length \
  #   -l "$D_SUBS/probed.txt" \
  #   -o "$D_DISCOVERY/hosts-summary.txt"
  # print_outro "$D_DISCOVERY/hosts-summary.txt" 'wc'


  # print_intro 'Worth to discover'
  # grep '200' "$D_DISCOVERY/hosts-summary.txt" \
  #   | tee "$D_DISCOVERY/hosts-summary-200.txt"

  # print_intro 'Urls to discover'
  # cut -d ' ' -f 1 "$D_DISCOVERY/hosts-summary-200.txt" \
  #   | tee "$D_DISCOVERY/targets.txt"
  # print_outro "$D_DISCOVERY/targets.txt" 'wc'


  # banner_simple 'Scan 200 only'


  # print_intro 'Starting Nuclei'
  # nuclei -update-templates
  # : > "$D_DISCOVERY/nuclei/nuclei.txt"
  # nuclei \
  #   -c 100 \
  #   -silent \
  #   -l "$D_DISCOVERY/targets.txt" \
  #   -t "$D_NUCL_TMPL/dns/" \
  #   -t "$D_NUCL_TMPL/cves/" \
  #   -t "$D_NUCL_TMPL/files/" \
  #   -t "$D_NUCL_TMPL/tokens/" \
  #   -t "$D_NUCL_TMPL/panels/" \
  #   -t "$D_NUCL_TMPL/fuzzing/" \
  #   -t "$D_NUCL_TMPL/workflows/" \
  #   -t "$D_NUCL_TMPL/technologies/" \
  #   -t "$D_NUCL_TMPL/vulnerabilities/" \
  #   -t "$D_NUCL_TMPL/subdomain-takeover/" \
  #   -t "$D_NUCL_TMPL/generic-detections/" \
  #   -t "$D_NUCL_TMPL/security-misconfiguration/" \
  #   -o "$D_DISCOVERY/nuclei/nuclei.txt"
  # print_outro "$D_DISCOVERY/nuclei/nuclei.txt" 'wc'


  print_intro "Starting feroxbuster"
  while read -r subdomain; do
    filename=${subdomain#*//} #remove protocol
    feroxbuster \
      --depth 1 \
      --insecure \
      --threads 100 \
      --status-codes 200 \
      --url "$subdomain" \
      --extensions php txt bak sql zip gz json \
      --output "$D_DISCOVERY/feroxbuster/$filename.txt" \
      --wordlist './config/dict/common-web-content.txt'
  done < "$D_DISCOVERY/targets.txt"
  print_outro "$D_DISCOVERY/feroxbuster"

  print_intro 'feroxbuster total:'
  cat "$D_DISCOVERY"/feroxbuster/*.txt \
    | grep -v 'ERR' \
    | tee "$D_DISCOVERY"/feroxbuster/TOTAL.txt
  print_outro "$D_DISCOVERY/feroxbuster/TOTAL.txt" 'wc'


  # print_intro 'Starting hakrawler'
  # while read -r subdomain; do
  #   echo -e "\n $subdomain \n"
  #   dir=${subdomain#*//} #remove protocol

  #   hakrawler \
  #     -url "$subdomain" \
  #     -depth 2 \
  #     -insecure \
  #     -linkfinder \
  #     -outdir "$D_DISCOVERY"/hakrawler/req  \
  #     -plain \
  #   | tee "$D_DISCOVERY"/hakrawler/"$dir".txt

  #   # delete if empty
  #   if [ ! -s "$D_DISCOVERY"/hakrawler/"$dir".txt ]; then
  #     rm -f "$D_DISCOVERY"/hakrawler/"$dir".txt
  #   fi
  # done < "$D_DISCOVERY/targets.txt"
  # print_outro "$D_DISCOVERY"/hakrawler


  # print_intro 'hakrawler total:'
  # cat "$D_DISCOVERY"/hakrawler/*.txt \
  #   | tee "$D_DISCOVERY"/hakrawler/TOTAL.txt
  # print_outro "$D_DISCOVERY/hakrawler/TOTAL.txt" 'wc'


  # print_intro 'Starting gau'
  # while read -r url; do
  #   subdomain=${url#*//} #remove protocol
  #   echo -e "\n $subdomain \n"
  #   gau "$subdomain" | tee "$D_DISCOVERY"/gau/"$subdomain".txt

  #   # delete if empty
  #   if [ ! -s "$D_DISCOVERY"/gau/"$subdomain".txt ]; then
  #     rm -f "$D_DISCOVERY"/gau/"$subdomain".txt
  #   fi
  # done <"$D_DISCOVERY/targets.txt"
  # print_outro "$D_DISCOVERY"/gau


  # print_intro 'gau total:'
  # cat "$D_DISCOVERY"/gau/*.txt \
  #   | tee "$D_DISCOVERY"/gau/TOTAL.txt
  # print_outro "$D_DISCOVERY/gau/TOTAL.txt" 'wc'


  # print_intro 'Gather unique urls of GET requests with original params'
  # cat "$D_DISCOVERY"/gau/TOTAL.txt "$D_DISCOVERY"/hakrawler/TOTAL.txt \
  #   | grep -v -Ei ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)" \
  #   | grep -v ' from ' \
  #   | grep '=' \
  #   | qsreplace -a \
  #   | httpx -status-code -mc 200 -silent -no-color \
  #   | tee "$D_DISCOVERY"/urls-uniq-get.txt
  # print_outro "$D_DISCOVERY"/urls-uniq-get.txt 'wc'

  # dalfox file "$D_DISCOVERY"/urls-uniq-get.txt \
  #   | tee -a "$D_XSS/dalfox.txt"

}



main "$@"

exit 0
