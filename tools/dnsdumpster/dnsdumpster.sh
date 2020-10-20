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

[[ ! -d ./tmp ]] && mkdir ./tmp

# get csrftoken
curl https://dnsdumpster.com/ -c "./tmp/cookies_$url.txt" -s -o /dev/null

# send POST request with csrftoken
curl https://dnsdumpster.com/ \
	-s \
	-b "./tmp/cookies_$url.txt" \
	-e 'https://dnsdumpster.com' \
	-d "csrfmiddlewaretoken=$(grep csrftoken ./tmp/cookies_$url.txt | cut -f 7)" \
	-d "targetip=$url" \
	>"./tmp/response_$url.html"

# Host Records (A)
# this data may not be current as it uses a static database (updated monthly)
cat "./tmp/response_$url.html" | pup 'div.table-responsive:last-child table tr td:first-child json{}' | jq '.[].text' | tr -d '"' | sort

exit 0
