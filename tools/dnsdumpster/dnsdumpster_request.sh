#!/bin/bash

# https://dnsdumpster.com/

# Exit if no arguments
[[ $# -eq 0 ]] && {
	echo "Usage: $0 domain.com"
	exit 1
}

url=$1

# get csrftoken
curl https://dnsdumpster.com/ -c "./cookies_$url.txt" -s -o /dev/null

# send POST request with csrftoken
curl https://dnsdumpster.com/ \
	-s \
	-b "./cookies_$url.txt" \
	-e 'https://dnsdumpster.com' \
	-d "csrfmiddlewaretoken=$(grep csrftoken ./cookies_$url.txt | cut -f 7)" \
	-d "targetip=$url" \
	>"./response_$url.html"

./dnsdumpster_parser.sh "./response_$url.html"

exit 0
