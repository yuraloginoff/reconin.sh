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

# <<<<<<<<<<<<<<<<<<<<<<<< VARIABLES  <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> DIRECTORIES >>>>>>>>>>>>>>>>>>>>>>>>

[[ ! -d ./out ]] && mkdir ./out
[[ ! -d ./out/$URL ]] && mkdir ./out/"$URL"
[[ ! -d ./out/$URL/netinfo ]] && mkdir ./out/"$URL"/netinfo
[[ ! -d ./out/$URL/subs ]] && mkdir ./out/"$URL"/subs
[[ ! -d ./out/$URL/subs/src ]] && mkdir ./out/"$URL"/subs/src
[[ ! -d ./out/$URL/subs/takeover ]] && mkdir ./out/"$URL"/subs/takeover
[[ ! -d ./out/$URL/discovery ]] && mkdir ./out/"$URL"/discovery
[[ ! -d ./out/$URL/discovery/hakrawler ]] \
  && mkdir ./out/"$URL"/discovery/hakrawler \
  && mkdir ./out/"$URL"/discovery/hakrawler/req
[[ ! -d ./out/$URL/discovery/gobuster ]] \
  && mkdir ./out/"$URL"/discovery/gobuster

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

# # CRT.SH
# print_intro 'Starting crt.sh'
# bash ./tools/crtsh_enum_psql.sh "$URL" | tee "$D_SUBS_SRC/crtsh.txt"
# print_outro "$D_SUBS_SRC/crtsh.txt" 'wc'

# # DNSdumpster
# print_intro 'Starting DNSdumpster'
# bash ./tools/dnsdumpster/dnsdumpster.sh "$URL" \
#   | tee "$D_SUBS_SRC/dnsdumpster.txt"
# print_outro "$D_SUBS_SRC/dnsdumpster.txt" 'wc'

# # assetfinder
# print_intro 'Starting assetfinder'
# assetfinder "$URL" | tee "$D_SUBS_SRC/assetfinder.txt"
# print_outro "$D_SUBS_SRC/assetfinder.txt" 'wc'

# # amass
# print_intro 'Starting amass'
# amass enum -d "$URL" \
#   -config './config/amass/config.ini' \
#   -o "$D_SUBS_SRC/amass.txt"
# print_outro "$D_SUBS_SRC/amass.txt" 'wc'

# # findomain
# print_intro 'Starting findomain'
# findomain -t "$URL" -o && mv "./$URL.txt" "$D_SUBS_SRC/findomain.txt"
# print_outro "$D_SUBS_SRC/findomain.txt" 'wc'

# # subfinder
# print_intro 'Starting subfinder'
# subfinder -d "$URL" -o "$D_SUBS_SRC/subfinder.txt"
# print_outro "$D_SUBS_SRC/subfinder.txt" 'wc'

# # sublist3r
# print_intro 'Starting sublist3r'
# python3 "$HOME/bin/sublist3r" -d "$URL" -o "$D_SUBS_SRC/sublister.txt"
# print_outro "$D_SUBS_SRC/sublister.txt" 'wc'

# # Total
# print_intro 'Sorting gathered subdomains'
# cat "$D_SUBS_SRC"/*.txt \
#   | grep -v 'www.google.com' \
#   | uniq \
#   | tee "$D_SUBS_SRC/subs-src-total.txt"
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

# # httprobe
# print_intro 'Check subdomains to be live with Httprobe'
# httprobe -c 50 < "$D_SUBS/subs.txt" | tee "$D_SUBS/httprobed.txt"
# print_outro "$D_SUBS/httprobed.txt" 'wc'


# print_intro 'Convert subdomains links to hosts (remove protocol)'
# if [ -f "$D_SUBS/probed.txt" ]; then
#   rm -f "$D_SUBS/probed.txt"
# fi

# while read -r hsub; do
#   sub=${hsub#*//} #remove protocol
#   echo "$sub" >>"$D_SUBS/probed.txt"
# done < "$D_SUBS/httprobed.txt"

# sort -u "$D_SUBS/probed.txt" -o "$D_SUBS/probed.txt"
# print_outro "$D_SUBS/probed.txt" 'wc'


# banner_simple "Subdomain Takeover"


# # subjack
# print_intro 'Starting subjack'
# subjack \
#   -w "$D_SUBS/probed.txt" \
#   -t 100 \
#   -timeout 30 \
#   -o "$D_SUBS/takeover/subjack.txt" \
#   -ssl \
#   -c ./config/subjack/fingerprints.json \
#   -v
# echo -e '[+] Done!\n'

# # tko-subs
# print_intro 'Starting tko-subs'
# tko-subs \
#   -domains="$D_SUBS/probed.txt" \
#   -data=./config/tko-subs/providers-data.csv \
#   -output="$D_SUBS/takeover/tkosubs.csv"


banner_simple "Discovery"

# hakrawler
# print_intro 'Starting hakrawler'
# while read -r subdomain; do
#   echo -e "\n $subdomain \n"
#   hakrawler \
#     -url "$subdomain" \
#     -depth 1 \
#     -insecure \
#     -linkfinder \
#     -outdir "$D_DISCOVERY"/hakrawler/req  \
#     -plain \
#   | tee "$D_DISCOVERY"/hakrawler/"$subdomain".txt

#   # delete if empty
#   if [ ! -s "$D_DISCOVERY"/hakrawler/"$subdomain".txt ]; then
#     rm -f "$D_DISCOVERY"/hakrawler/"$subdomain".txt
#   fi
# done < "$D_SUBS/probed.txt"
# print_outro "$D_DISCOVERY"/hakrawler


# dirsearch
# print_intro 'Starting dirsearch'
# while read -r subdomain; do
#     dirsearch \
#         -e php,html,txt,bak,sql,zip,tar,gz,xlsx \
#         # --force-extensions \
#         -w ~/Tools/dirsearch/db/dicc.txt \
#         -t 100 \
#         -i 200 \
#         --full-url \
#         --request-by-hostname \
#         --plain-text-report="$D_DISCOVERY"/dirsearch/"$subdomain".txt \
#         -u "$subdomain"
# done < "$D_SUBS/probed.txt"
# print_outro "$D_DISCOVERY/dirsearch"


# gobuster dir
# print_intro "Starting gobuster"
# while read -r subdomain; do
#   echo "$subdomain"
#   gobuster dir \
#     -e \
#     -l \
#     -k \
#     -s '200,301' \
#     -u "$subdomain" \
#     -o "$D_DISCOVERY/gobuster/$subdomain.txt" \
#     -t 100 \
#     -x .php,.txt,.bak,.sql,.zip,.tar,.gz,.xlsx \
#     -w './config/dict/dirsearch.txt'
# done < "$D_SUBS/probed.txt"
# print_outro "$D_DISCOVERY/gobuster"


exit 0
