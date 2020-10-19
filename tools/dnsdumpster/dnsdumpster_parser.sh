#!/bin/bash

# Exit if no arguments
if [[ $# -eq 0 ]]; then
	echo "Usage: $0 webpage.html"
	exit 1
fi

if [[ ! -x "$(command -v pup)" ]]; then
	echo "[-] pup required to run script."
	echo 'go get github.com/ericchiang/pup'
	exit 1
fi

file=$1

# Host Records (A)
# this data may not be current as it uses a static database (updated monthly)
cat $file | pup 'div.table-responsive:last-child table tr td:first-child json{}' | jq '.[].text' | tr -d '"' | sort

exit 0
