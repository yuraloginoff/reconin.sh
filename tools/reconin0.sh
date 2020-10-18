#!/bin/bash

# Exit if no arguments
if [[ $# -eq 0 ]]; then
	echo "Usage: $0 domain.com"
	exit 1
fi

url=$1

[[ ! -d ./$url ]] && mkdir ./$url

if [[ ! -d ./$url/harvester ]]; then
	mkdir ./$url/harvester
	touch ./$url/harvester/emails.txt
	touch ./$url/harvester/workers.txt
	touch ./$url/harvester/subdomains.txt
fi

# theHarvester
echo -e "\n[*] Starting theHarvester for $url..."
~/Dropbox/Pentest/Tools/theHarvester/theHarvester.py -d $url -b all | tee ~/Dropbox/Pentest/reconin.sh/$url/harvester/theHarvester.txt
echo -e "\n[+] Done! Saved to ./$url/harvester/theHarvester.txt \n"

exit 0
