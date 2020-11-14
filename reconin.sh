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
readonly D_ROOT="./out/$URL"
readonly D_NETINFO="./out/$URL/netinfo"
readonly D_SUBS="./out/$URL/subs"
readonly D_SUBS_SRC="./out/$URL/subs/src"
readonly D_DISCOVERY="./out/$URL/discovery"
readonly D_HOSTS="./out/$URL/hosts"

readonly D_NUCL_TMPL="$HOME/nuclei-templates"

# <<<<<<<<<<<<<<<<<<<<<<<< VARIABLES  <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> DIRECTORIES >>>>>>>>>>>>>>>>>>>>>>>>

[[ ! -d ./out ]] && mkdir ./out
[[ ! -d ./out/$URL ]] && mkdir ./out/"$URL"
[[ ! -d ./out/$URL/netinfo ]] && mkdir ./out/"$URL"/netinfo
[[ ! -d ./out/$URL/subs ]] && mkdir ./out/"$URL"/subs
[[ ! -d ./out/$URL/subs/src ]] && mkdir ./out/"$URL"/subs/src
[[ ! -d ./out/$URL/subs/takeover ]] && mkdir ./out/"$URL"/subs/takeover
[[ ! -d ./out/$URL/hosts ]] && mkdir ./out/"$URL"/hosts
[[ ! -d ./out/$URL/discovery ]] && mkdir ./out/"$URL"/discovery

[[ ! -d ./out/$URL/discovery/hakrawler ]] \
  && mkdir ./out/"$URL"/discovery/hakrawler \
  && mkdir ./out/"$URL"/discovery/hakrawler/req

[[ ! -d ./out/$URL/discovery/feroxbuster ]] \
  && mkdir ./out/"$URL"/discovery/feroxbuster

[[ ! -d ./out/$URL/discovery/dirsearch ]] \
  && mkdir ./out/"$URL"/discovery/dirsearch

[[ ! -d ./out/$URL/discovery/nuclei ]] \
  && mkdir ./out/"$URL"/discovery/nuclei

[[ ! -d ./out/$URL/discovery/gau ]] \
  && mkdir ./out/"$URL"/discovery/gau


# <<<<<<<<<<<<<<<<<<<<<<<< DIRECTORIES <<<<<<<<<<<<<<<<<<<<<<<<


# banner_simple "$URL various info"


# # AS numbers
# # The ASN numbers can be used to find netblocks of the domain
# print_intro 'ASN discovery'
# curl -s "http://ip-api.com/json/$(dig +short "$URL")" \
#   | jq -r .as \
#   | tee "$D_NETINFO/asn.txt"
# echo
# whois -h whois.radb.net -- "-i origin $(cat "$D_NETINFO/asn.txt" \
#   | cut -d ' ' -f 1)" \
#   | grep -Eo "([0-9.]+){4}/[0-9]+" \
#   | uniq \
#   | tee "$D_NETINFO/asn-list.txt"
# print_outro "$D_NETINFO"


# # Subject Alternate Name(SAN)
# # The Subject Alternative Name (SAN) is an extension to the X.509 specification that allows to specify additional host names for a single SSL certificate.
# print_intro 'Extract domain names from Subject Alternate Name'
# python3 \
#   ./tools/san_subdomain_enum.py "$URL" \
#   | tee "$D_NETINFO/san.txt"
# print_outro "$D_NETINFO/san.txt"


# # SPF record
# # SPF lists all the hosts that are authorised to send emails on behalf of a domain.
# print_intro 'Search for SPF'
# bash ./tools/enum_spf.sh "$URL" | sort | tee "$D_NETINFO/spf.txt"
# print_outro "$D_NETINFO/spf.txt"


# banner_simple "Subdomain Enumeration"


# print_intro 'Starting crt.sh'
# bash ./tools/crtsh_enum_psql.sh "$URL" | tee "$D_SUBS_SRC/crtsh.txt"
# print_outro "$D_SUBS_SRC/crtsh.txt" 'wc'


# print_intro 'Starting DNSdumpster'
# bash ./tools/dnsdumpster/dnsdumpster.sh "$URL" \
#   | tee "$D_SUBS_SRC/dnsdumpster.txt"
# print_outro "$D_SUBS_SRC/dnsdumpster.txt" 'wc'


# print_intro 'Starting assetfinder'
# assetfinder --subs-only "$URL" | tee "$D_SUBS_SRC/assetfinder.txt"
# print_outro "$D_SUBS_SRC/assetfinder.txt" 'wc'


# print_intro 'Starting amass'
# amass enum -d "$URL" \
#   -config './config/amass/config.ini' \
#   -o "$D_SUBS_SRC/amass.txt"
# print_outro "$D_SUBS_SRC/amass.txt" 'wc'


# print_intro 'Starting findomain'
# findomain -t "$URL" -o && mv "./$URL.txt" "$D_SUBS_SRC/findomain.txt"
# print_outro "$D_SUBS_SRC/findomain.txt" 'wc'


# print_intro 'Starting subfinder'
# subfinder -d "$URL" -o "$D_SUBS_SRC/subfinder.txt"
# print_outro "$D_SUBS_SRC/subfinder.txt" 'wc'


# print_intro 'Starting sublist3r'
# python3 "$HOME/bin/sublist3r" -d "$URL" -o "$D_SUBS_SRC/sublister.txt"
# print_outro "$D_SUBS_SRC/sublister.txt" 'wc'


# print_intro 'Sorting gathered subdomains'
# cat "$D_SUBS_SRC"/*.txt \
#   | grep -v 'www.google.com' \
#   | uniq > "$D_SUBS_SRC/subs-src-total.txt"
# print_outro "$D_SUBS_SRC/subs-src-total.txt" 'wc'


# banner_simple "Subdomains Bruteforce"

# # check if the target has a wildcard enabled
# if host randomifje8z19td3hf8jafvh7g4q79gh274."$URL" | grep 'not found'; then
#   print_intro 'There is no wildcard! Can bruteforce'

#   # dnsgen & massdns
#   print_intro "Starting dnsgen & massdns"
#   cat "$D_SUBS_SRC/subs-src-total.txt" \
#     | dnsgen - \
#     | massdns -r ~/Tools/Massdns/lists/resolvers.txt \
#       -t A -o S --quiet \
#       -w "$D_SUBS_SRC/massdns.txt"

#   cat "$D_SUBS_SRC/massdns.txt" | awk '{print $1}' | sed 's/\.$//' \
#     | uniq >"$D_SUBS_SRC/massdns-resolved.txt"

#   print_outro "$D_SUBS_SRC/massdns-resolved.txt" 'wc'
# else
#   echo '[-] There is a wildcard! No way for bruteforce. '
# fi


# banner_simple "Subdomains Total"


# cat "$D_SUBS_SRC/massdns-resolved.txt" "$D_SUBS_SRC/subs-src-total.txt" \
#   | grep "$URL$" \
#   | sort -u \
#   | tee "$D_SUBS/subs.txt"

# print_outro "$D_SUBS/subs.txt" 'wc'

# print_intro 'Check subdomains to be live with Httprobe'
# httprobe -c 50 < "$D_SUBS/subs.txt" \
#   | tee "$D_SUBS/httprobed.txt"
# print_outro "$D_SUBS/httprobed.txt" 'wc'


# print_intro 'Convert subdomains links to hosts (remove https & http)'
# echo >"$D_SUBS/probed.txt"
# while read -r hsub; do
#   sub=${hsub#*//} #remove protocol
#   echo "$sub" >>"$D_SUBS/probed.txt"
# done < "$D_SUBS/httprobed.txt"

# sort -u "$D_SUBS/probed.txt" -o "$D_SUBS/probed.txt"
# print_outro "$D_SUBS/probed.txt" 'wc'


# banner_simple "Subdomain Takeover"


# print_intro 'Starting subjack'
# subjack \
#   -w "$D_SUBS/probed.txt" \
#   -t 100 \
#   -timeout 30 \
#   -o "$D_SUBS/takeover/subjack.txt" \
#   -ssl \
#   -c ./config/subjack/fingerprints.json \
#   -v


# print_intro 'Starting tko-subs'
# tko-subs \
#   -domains="$D_SUBS/probed.txt" \
#   -data=./config/tko-subs/providers-data.csv \
#   -output="$D_SUBS/takeover/tkosubs.csv"
# echo

# banner_simple "Hosts"


# print_intro "Getting subdomains' IP"
# echo >"$D_HOSTS/sub-dig.txt"
# echo >"$D_HOSTS/ips.txt"
# while read -r sub; do
#   if ip=$(dig +short "$sub"); then
#     echo -e "$sub:\n$ip\n" | tee -a "$D_HOSTS/sub-dig.txt"
#     echo "$ip" >>"$D_HOSTS/ips.txt"
#   fi
# done <"$D_SUBS/probed.txt"
# print_outro "$D_HOSTS/sub-dig.txt"


# print_intro 'List of IPs'
# sort \
#   -u -t . \
#   -k 1,1n -k 2,2n -k 3,3n -k 4,4n \
#   -o "./$D_HOSTS/ips.txt" \
#   "./$D_HOSTS/ips.txt"
# cat "./$D_HOSTS/ips.txt"
# print_outro "$D_HOSTS/ips.txt" 'wc'


# print_intro 'Port scan with Naabu'
# while read -r host; do
#   naabu -host "$host" -silent \
#     | tee -a "$D_HOSTS/host-ports.txt"
#   echo
# done <"$D_HOSTS/ips.txt"
# print_outro "$D_HOSTS/host-ports.txt"


# print_intro 'Search for interesting hosts'
# grep -v ':80' "$D_HOSTS/host-ports.txt" \
#   | grep -v ':443' \
#   | tee "$D_HOSTS/host-ports-nonhttp.txt"

# if [ -s "$D_HOSTS/host-ports-nonhttp.txt" ]; then
#   while read -r host_port; do
#     host=$(echo "$host_port" | cut -d':' -f1)
#     echo "$host" >> "$D_HOSTS/hosts-to-nmap.txt"
#   done <"$D_HOSTS/host-ports-nonhttp.txt"

#   sort -u "$D_HOSTS/hosts-to-nmap.txt" \
#     -o "$D_HOSTS/hosts-to-nmap.txt"
#   cat "$D_HOSTS/hosts-to-nmap.txt"
#   print_outro "$D_HOSTS/hosts-to-nmap.txt" 'wc'
# fi


banner_simple "Discovery"


# httpx \
#   -title \
#   -no-color \
#   -status-code \
#   -content-length \
#   -l "$D_SUBS/probed.txt" \
#   -o "$D_DISCOVERY/hosts-summary.txt"
# print_outro "$D_DISCOVERY/hosts-summary.txt" 'wc'


# print_intro 'Worth to discover'
# grep '200' "$D_DISCOVERY/hosts-summary.txt" \
#   | tee "$D_DISCOVERY/hosts-summary-200.txt"

# cut -d ' ' -f 1 "$D_DISCOVERY/hosts-summary-200.txt" \
#   | tee "$D_DISCOVERY/targets.txt"
# print_outro "$D_DISCOVERY/targets.txt" 'wc'


# Scan '200' only


# print_intro 'Starting  Nuclei'
# nuclei -update-templates

# while read -r subdomain; do
#   echo -e "\n $subdomain"
#   dir=${subdomain#*//} #remove protocol

#   nuclei \
#     -nC  \
#     -c 50 \
#     -pbar  \
#     -silent \
#     -target "$subdomain" \
#     -t "$D_NUCL_TMPL/dns/" \
#     -t "$D_NUCL_TMPL/cves/" \
#     -t "$D_NUCL_TMPL/files/" \
#     -t "$D_NUCL_TMPL/panels/" \
#     -t "$D_NUCL_TMPL/workflows/" \
#     -t "$D_NUCL_TMPL/technologies/" \
#     -t "$D_NUCL_TMPL/vulnerabilities/" \
#     -t "$D_NUCL_TMPL/subdomain-takeover/" \
#     -t "$D_NUCL_TMPL/generic-detections/" \
#     -t "$D_NUCL_TMPL/security-misconfiguration/" \
#     -o "$D_DISCOVERY/nuclei/$dir.txt"

# done < "$D_DISCOVERY/targets.txt"
# print_outro "$D_DISCOVERY/nuclei/"


# print_intro 'Nuclei total:'
# cat "$D_DISCOVERY"/nuclei/*.txt | tee "$D_DISCOVERY"/nuclei/TOTAL.txt
# print_outro "$D_DISCOVERY/nuclei/TOTAL.txt" 'wc'


# print_intro "Starting feroxbuster"
# while read -r subdomain; do
#   dir=${subdomain#*//} #remove protocol

#   feroxbuster \
#     --depth 1 \
#     --insecure \
#     --threads 100 \
#     --status-codes 200 \
#     --url "$subdomain" \
#     --extensions php txt bak sql zip gz json \
#     --output "$D_DISCOVERY/feroxbuster/$dir.txt" \
#     --wordlist '/usr/share/seclists/Discovery/Web-Content/common.txt'

# done < "$D_DISCOVERY/targets.txt"
# print_outro "$D_DISCOVERY/feroxbuster"

# print_intro 'feroxbuster total:'
# cat "$D_DISCOVERY"/feroxbuster/*.txt \
#   | grep -v 'ERR' \
#   | tee "$D_DISCOVERY"/feroxbuster/TOTAL.txt
# print_outro "$D_DISCOVERY/feroxbuster/TOTAL.txt" 'wc'


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


print_intro 'Gather unique urls of GET requests with original params'
cat "$D_DISCOVERY"/gau/TOTAL.txt "$D_DISCOVERY"/hakrawler/TOTAL.txt \
  | grep -v -Ei ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)" \
  | grep -v ' from ' \
  | grep '=' \
  | qsreplace -a \
  | httpx -silent \
  | tee "$D_DISCOVERY"/urls-uniq-get.txt
print_outro "$D_DISCOVERY"/urls-uniq-get.txt 'wc'








exit 0
