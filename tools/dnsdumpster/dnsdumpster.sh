#!/bin/bash

# Find sub-domains with DNSdumpster
# https://dnsdumpster.com/
# unofficial script by yuraloginoff

# Exit if no arguments
[[ $# -eq 0 ]] && {
	echo "Usage: $0 domain.com"
	exit 1
}

url=$1
tmpdir='./tools/dnsdumpster/tmp'

[[ ! -d $tmpdir ]] && mkdir $tmpdir

# get csrftoken
curl https://dnsdumpster.com/ -c "$tmpdir/cookies_$url.txt" -s -o /dev/null
token=$(grep csrftoken "$tmpdir/cookies_$url.txt" | cut -f 7)

# send POST request with csrftoken
curl https://dnsdumpster.com/ \
	-s \
	-b "$tmpdir/cookies_$url.txt" \
	-e 'https://dnsdumpster.com' \
	-d "csrfmiddlewaretoken=$token" \
	-d "targetip=$url" \
	>"$tmpdir/response_$url.html"

# Host Records (A)
# this data may not be current as it uses a static database (updated monthly)
cat "$tmpdir/response_$url.html" | pup 'div.table-responsive:last-child table tr td:first-child json{}' | jq '.[].text' | tr -d '"' | sort

exit 0
