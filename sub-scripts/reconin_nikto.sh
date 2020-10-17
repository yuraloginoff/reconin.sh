#!/bin/bash

# Exit if no arguments
if [[ $# -eq 0 ]]; then
	echo "Usage: $0 domain.com"
	exit 1
fi

url=$1

# Check for nikto
if ! [[ -x "$(command -v nikto)" ]]; then
	echo 'Error: nikto is not installed or not in $PATH.'
	exit 1
fi

# Check for file with ips
if ! [[ -f "./$url/ips.txt" ]]; then
	echo "Missing ./$url/ips.txt"
	echo 'Run ./reconin.sh first'
	exit 1
fi

# nikto
echo "[*] Scanning every IP with Nikto"
[[ ! -d ./$url/nikto ]] && mkdir ./$url/nikto
while read ip; do
	echo -e "\n> nikto -h $ip -o ./$url/nikto/$ip.txt -ask no"
	# nikto -h $ip -ask no -o "./$url/nikto/$ip.txt"
	nikto -h $ip
done <"./$url/ips.txt"
echo -e "\n[+] Done! Repots saved to ./$url/nikto/ \n"

exit 0
