#!/bin/bash

# Exit if no arguments
if [[ $# -eq 0 ]]; then
	echo "Usage: $0 domain.com"
	exit 1
fi

url=$1

# Check for gitjacker
if ! [[ -x "$(command -v gitjacker)" ]]; then
	echo -e '\nError: gitjacker is not installed or not in $PATH.'
	echo 'Info: https://github.com/liamg/gitjacker'
	exit 1
fi

# Check for file with domains
if ! [[ -f "./$url/subdomains-links.txt" ]]; then
	echo "Missing ./$url/subdomain-links.txt"
	echo 'Run ./reconin.sh first'
	exit 1
fi

echo -e "[*] Checking for .git directory on all domains...\n"
while read link; do
	gitjacker $link
done <"./$url/subdomains-links.txt"

exit 0
