#!/bin/bash

# Exit if no arguments
if [[ $# -eq 0 ]]; then
	echo "Usage: $0 domain.com"
	exit 1
fi

readonly DOMAINS_LIST=$1
readonly OUTPUT_DIR=$2

while read -r link; do
	gitjacker http://"$link" -o "$OUTPUT_DIR"
done <"$DOMAINS_LIST"

exit 0
