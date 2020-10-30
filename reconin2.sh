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

err() {
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
    local edge=`echo "$msg" | sed 's/./*/g'`
    echo "$edge"
    echo "`tput bold`$msg`tput sgr0`"
    echo "$edge"
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
readonly D_SUBS_SRC="./out/$URL/subs/src"

# <<<<<<<<<<<<<<<<<<<<<<<< VARIABLES  <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> DIRECTORIES >>>>>>>>>>>>>>>>>>>>>>>>

[[ ! -d ./out ]] && mkdir ./out
[[ ! -d ./out/$URL ]] && mkdir ./out/"$URL"
[[ ! -d ./out/$URL/netinfo ]] && mkdir ./out/"$URL"/netinfo
[[ ! -d ./out/$URL/subs ]] && mkdir ./out/"$URL"/subs
[[ ! -d ./out/$URL/subs/src ]] && mkdir ./out/"$URL"/subs/src
[[ ! -d ./out/$URL/subs/takeover ]] && mkdir ./out/"$URL"/subs/takeover

# <<<<<<<<<<<<<<<<<<<<<<<< DIRECTORIES <<<<<<<<<<<<<<<<<<<<<<<<

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


banner_simple "$URL subdomain enumeration"

# CRT.SH
print_intro 'Starting crt.sh'
bash ./tools/crtsh_enum_psql.sh "$URL" | tee "$D_SUBS_SRC/crtsh.txt"
print_outro "$D_SUBS_SRC/crtsh.txt" 'wc'

# DNSdumpster
print_intro 'Starting DNSdumpster'
bash ./tools/dnsdumpster/dnsdumpster.sh "$URL" \
    | tee "$D_SUBS_SRC/dnsdumpster.txt"
print_outro "$D_SUBS_SRC/dnsdumpster.txt" 'wc'

# assetfinder
print_intro 'Starting assetfinder'
assetfinder "$URL" | grep "\.$URL" | tee "$D_SUBS_SRC/assetfinder.txt"
print_outro "$D_SUBS_SRC/assetfinder.txt" 'wc'

# amass
print_intro 'Starting amass'
amass enum -d "$URL" \
    -config './config/amass/config.ini' \
    -o "$D_SUBS_SRC/amass.txt"
print_outro "$D_SUBS_SRC/amass.txt" 'wc'

# findomain
print_intro 'Starting findomain'
findomain -t "$URL" -o && mv "./$URL.txt" "$D_SUBS_SRC/findomain.txt"
print_outro "$D_SUBS_SRC/findomain.txt" 'wc'

# subfinder
print_intro 'Starting subfinder'
subfinder -d "$URL" -o "$D_SUBS_SRC/subfinder.txt"
print_outro "$D_SUBS_SRC/subfinder.txt" 'wc'

# sublist3r
print_intro 'Starting sublist3r'
python3 "$HOME/bin/sublist3r" -d "$URL" -o "$D_SUBS_SRC/sublister.txt"
print_outro "$D_SUBS_SRC/sublister.txt" 'wc'

# Total
sort -u "$D_SUBS_SRC"/*.txt -o "$D_SUBS_SRC/subs-src-total.txt"
print_outro "$D_SUBS_SRC/subs-src-total.txt" 'wc'
