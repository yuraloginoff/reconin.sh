#!/bin/bash

# Exit if no arguments
[[ $# -eq 0 ]] && {
	echo "Usage: $0 domain.com"
	exit 1
}

url=$1

# DIRS
[[ ! -d ./$url ]] && mkdir ./$url
[[ ! -d ./$url/subs-src ]] && mkdir ./$url/subs-src
[[ ! -d ./$url/asn ]] && mkdir ./$url/asn

echo -e '
+------------------------------+
|                              |
|    SUB-DOMAIN ENUMERATION    |
|                              |
+------------------------------+\n'

# ASN
echo -e "[i] ASN discovery"
curl -s "http://ip-api.com/json/$(dig +short $url)" | jq -r .as | tee ./$url/asn/asn.txt
whois -h whois.radb.net -- "-i origin $(cat ./$url/asn/asn.txt | cut -d ' ' -f 1)" | grep -Eo "([0-9.]+){4}/[0-9]+" | uniq | tee ./$url/asn/list.txt
echo -e "[+] Done! Saved to ./$url/asn/ \n"

# CRT.SH
echo -e "[i] Starting with crt.sh"
chmod +x ./tools/crtsh_enum_psql.sh
./tools/crtsh_enum_psql.sh $url | tee ./$url/subs-src/crtsh.txt
echo -e "[+] Done! Saved to ./$url/subs-src/crtsh.txt\n"

# # assetfinder
# echo -e "\n[i] Getting $url subdomains with assetfinder..."
# assetfinder $url | grep '\.'$url | tee "$url/subdomains/assetfinder.txt"
# echo -e "[+] Done! Saved to ./$url/subdomains/assetfinder.txt\n"

# # amass
# echo -e "\n[i] Getting $url subdomains with amass..."
# amass enum -config './config/amass/config.ini' -d $url -o $url/subdomains/amass.txt
# echo -e "[+] Done! Saved to ./$url/subdomains/amass.txt\n"

# # findomain
# echo -e "\n[i] Getting $url subdomains with findomain..."
# findomain -t $url -o
# mv ./$url.txt ./$url/subdomains/findomain.txt
# echo -e "[+] Done! Saved to ./$url/subdomains/findomain.txt\n"

# # subfinder
# echo -e "\n[i] Getting $url subdomains with subfinder..."
# subfinder -d $url -o ./$url/subdomains/subfinder.txt
# echo -e "[+] Done! Saved to ./$url/subdomains/subfinder.txt\n"

# # sublist3r
# echo -e "\n[i] Getting $url subdomains with sublist3r..."
# python3 $HOME/bin/sublist3r -d $url -o ./$url/subdomains/sublister.txt
# echo -e "[+] Done! Saved to ./$url/subdomains/sublister.txt\n"

# # Duplicates
# if [[ -f ./$url/harvester/subdomains.txt ]]; then
# 	cp ./$url/harvester/subdomains.txt ./$url/subdomains/harvester.txt
# fi
# sort -u ./$url/subdomains/*.txt -o "./$url/subdomains/subdomains-all.txt"
# echo "[+] All subdomains: ./$url/subdomains/subdomains-all.txt\n"

# # dnsgen & massdns
# echo -e "\n[i] Starting dnsgen & massdns..."
# cat ./$url/subdomains/subdomains-all.txt | dnsgen - | massdns -r ~/Tools/Massdns/lists/resolvers.txt -t A -o S -w ./$url/subdomains/massdns.txt
# sort ./$url/subdomains/massdns.txt | awk '{print $1}' | sed 's/\.$//' | uniq >"./$url/subdomains/massdns-resolved.txt"
# echo -e "[+] Done! Saved to ./$url/subdomains/massdns.txt and ./$url/subdomains/massdns-resolved.txt\n"

# sort -u ./$url/subdomains/massdns-resolved.txt ./$url/subdomains/subdomains-all.txt -o ./$url/subdomains-final.txt
# echo -e "Final list of subdomains: ./$url/subdomains-final.txt"

# # httprobe
# echo -e "\n[i] Starting httprobe..."
# cat ./$url/subdomains-final.txt | httprobe | grep '\.'$url | sort | tee ./$url/subdomains-links.txt
# echo -e "[+] Done! Saved to ./$url/subdomains-links.txt\n"

# # subdomain urls -> subdomains
# echo "[i] Getting $url subdomains..."
# while read sub; do
# 	sub=${sub#*//} #remove protocol
# 	echo $sub >>"./$url/subdomains-probed.txt"
# done <"./$url/subdomains-links.txt"

# sort -u ./$url/subdomains-probed.txt -o ./$url/subdomains-probed.txt
# cat ./$url/subdomains-probed.txt
# echo -e "[+] Done! Saved to ./$url/subdomains-probed.txt\n"

# # subdomain's IP
# echo "[i] Getting IPs for subdomains..."
# while read sub; do
# 	ip=$(dig +short $sub)
# 	echo "$ip - $sub" | tee -a "./$url/ip-sub.txt"
# 	echo $ip >>./$url/ips.txt
# done <./$url/subdomains-probed.txt
# echo -e "[+] Done! Saved to ./$url/subs-ip.txt\n"

# # IP list
# echo "[i] List of IPs..."
# sort -u -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n -o ./$url/ips.txt ./$url/ips.txt
# cat ./$url/ips.txt
# echo -e "[+] Saved to ./$url/ips.txt\n"

# # nmap
# echo "[i] Scanning every of $(cat ./$url/ips.txt | wc -l) IP with nmap..."
# [[ ! -d ./$url/nmap ]] && mkdir ./$url/nmap
# while read ip; do
# 	echo -e "\n> nmap for: $ip"
# 	nmap -T4 -p- -sV -Pn --max-retries 1 --max-scan-delay 20 --defeat-rst-ratelimit --open -oN "./$url/nmap/$ip.txt" $ip
# done <"./$url/ips.txt"
# echo -e "\n[+] Done! Repots saved to ./$url/nmap/ \n"

# # subjack
# echo -e "\n[i] Trying subjack..."
# subjack -w ./$url/subdomains-final.txt -t 100 -timeout 30 -o ./subjack.txt -ssl -c ./config/subjask/fingerprints.json -v
# echo -e '[+] Done!'

# hakrawler
# echo -e "\n[i] Starting hakrawler..."
# [[ ! -d ./$url/hakrawler ]] && mkdir ./$url/hakrawler
# while read domain; do
# 	echo -e "\n> $domain"
# 	# hakrawler -url $domain -depth 5 -plain -linkfinder -js -forms -insecure | tee ./$url/hakrawler/$domain.txt
# 	hakrawler -url $domain -plain | tee ./$url/hakrawler/$domain.txt
# done <./$url/subdomains-probed.txt
# echo -e "\n[+] Done! Repots saved to ./$url/hakrawler/ \n"

# shodan
# echo "[i] Scanning every of $(cat ./$url/ips.txt | wc -l) IP with shodan..."
# [[ ! -d ./$url/shodan ]] && mkdir ./$url/shodan
# while read ip; do
# 	echo -e "\n> shodan for: $ip"
# 	shodan host $ip | tee "./$url/shodan/$ip.txt" $ip
# done <"./$url/ips.txt"
# echo -e "\n[+] Done! Repots saved to ./$url/shodan/ \n"

# webanalyze

# Quit
exit 0
