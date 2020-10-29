#!/bin/bash

# Exit if no arguments
[[ $# -eq 0 ]] && {
    echo "Usage: $0 domain.com"
    exit 1
}

readonly url=$1

# DIRS
[[ ! -d ./$url ]] && mkdir ./"$url"
[[ ! -d ./$url/subs-src ]] && mkdir ./"$url"/subs-src
[[ ! -d ./$url/asn ]] && mkdir ./"$url"/asn

chmod +x ./tools/*.sh
chmod +x ./tools/**/*.sh

# # AS numbers
# # The ASN numbers can be used to find netblocks of the domain
# echo -e "[i] ASN discovery...\n"
# curl -s "http://ip-api.com/json/$(dig +short $url)" | jq -r .as | tee ./$url/asn/asn.txt
# whois -h whois.radb.net -- "-i origin $(cat ./$url/asn/asn.txt | cut -d ' ' -f 1)" | grep -Eo "([0-9.]+){4}/[0-9]+" | uniq >./$url/asn/list.txt
# echo -e "\n[+] Done! Saved to ./$url/asn/ \n"

# # Subject Alternate Name(SAN)
# # The Subject Alternative Name (SAN) is an extension to the X.509 specification that allows to specify additional host names for a single SSL certificate.
# echo -e "\n[i] Extract domain names from Subject Alternate Name...\n"
# python3 ./tools/san_subdomain_enum.py $url | tee ./$url/san.txt
# echo -e "\n[+] Done! Saved to ./$url/san.txt\n"

# # SPF record
# # SPF lists all the hosts that are authorised to send emails on behalf of a domain.
# echo -e "\n[i] Search for SPF...\n"
# ./tools/enum_spf.sh $url | sort | tee ./$url/spf.txt
# echo -e "\n[+] Done! Saved to ./$url/spf.txt\n"

# echo -e '
#   SUBDOMAIN ENUMERATION
#  ————————————————————————\n'

# # CRT.SH
# echo -e "\n[i] Starting crt.sh...\n"
# ./tools/crtsh_enum_psql.sh $url | tee ./$url/subs-src/crtsh.txt
# echo -e "\n[+] Done! Saved to ./$url/subs-src/crtsh.txt\n"

# # DNSdumpster
# echo -e "\n[i] Starting DNSdumpster...\n"
# ./tools/dnsdumpster/dnsdumpster.sh $url | tee ./$url/subs-src/dnsdumpster.txt
# echo -e "\n[+] Done! Saved to ./$url/subs-src/dnsdumpster.txt\n"

# # assetfinder
# echo -e "\n[i] Starting assetfinder..."
# assetfinder $url | grep '\.'$url | tee "$url/subs-src/assetfinder.txt"
# echo -e "[+] Done! Saved to ./$url/subs-src/assetfinder.txt\n"

# # amass
# echo -e "\n[i] Starting amass..."
# amass enum -config './config/amass/config.ini' -d $url -o $url/subs-src/amass.txt
# echo -e "[+] Done! Saved to ./$url/subs-src/amass.txt\n"

# # findomain
# echo -e "\n[i] Starting findomain..."
# findomain -t $url -o
# mv ./$url.txt ./$url/subs-src/findomain.txt
# echo -e "[+] Done! Saved to ./$url/subs-src/findomain.txt\n"

# # subfinder
# echo -e "\n[i] Starting subfinder..."
# subfinder -d $url -o ./$url/subs-src/subfinder.txt
# echo -e "[+] Done! Saved to ./$url/subs-src/subfinder.txt\n"

# # sublist3r
# echo -e "\n[i] Starting sublist3r..."
# python3 $HOME/bin/sublist3r -d $url -o ./$url/subs-src/sublister.txt
# echo -e "[+] Done! Saved to ./$url/subs-src/sublister.txt\n"

# # Total
# sort -u ./$url/subs-src/*.txt -o "./$url/subs-src/subs-total.txt"
# echo -e "\n[+] All subdomains: ./$url/subs-src/subs-total.txt"
# echo -e "Total: $(cat "./$url/subs-src/subs-total.txt" | wc -l)\n"

echo -e '
  SUBDOMAIN BRUTEFORCE
 ————————————————————————\n'

# check if the target has a wildcard enabled
# if host randomifje8z19td3hf8jafvh7g4q79gh274."$url" | grep 'not found'; then
#     echo '[+] There is no wildcard! Can bruteforce...'

#     # dnsgen & massdns
#     echo -e "\n[i] Starting dnsgen & massdns..."
#     cat "./$url/subs-src/subs-total.txt" | dnsgen - | massdns -r ~/Tools/Massdns/lists/resolvers.txt -t A -o S -w ./$url/subs-src/massdns.txt

#     cat ./$url/subs-src/massdns.txt | awk '{print $1}' | sed 's/\.$//' | uniq >"./$url/subs-src/massdns-resolved.txt"
#     echo -e "[+] Done! Saved to ./$url/subs-src/massdns.txt and ./$url/subs-src/massdns-resolved.txt\n"
# else
#     echo '[-] There is a wildcard! No way for bruteforce. '
# fi

# sort -u ./$url/subs-src/massdns-resolved.txt ./$url/subs-src/subs-total.txt -o ./$url/subdomains-list.txt
# echo "Total subdomains: $(wc -l ./"$url"/subdomains-list.txt)"

# echo -e "\n[i] Check subdomains to be live..."
# while read subdomain; do
# 	if host "$subdomain" >/dev/null; then
# 		echo "$subdomain" >>./$url/live.txt
# 	fi
# done <./$url/subdomains-list.txt
# echo -e "Total live subdomains: $(wc -l ./"$url"/live.txt)"

# httprobe
# echo -e "\n[i] Check subdomains to be live with Httprobe..."
# cat ./$url/subdomains-list.txt | httprobe | tee ./$url/httprobe.txt
# echo -e "[+] httprobe done! Saved to ./$url/httprobe.txt\n"

# while read sub; do
# 	sub=${sub#*//} #remove protocol
# 	echo $sub >>"./$url/probed.txt"
# done <"./$url/httprobe.txt"

# sort -u ./$url/probed.txt -o ./$url/probed.txt
# echo -e "Total probed subdomains: $(wc -l ./"$url"/probed.txt)\n"

# echo -e '
#   SUBDOMAIN TAKEOVER
#  ———————————————————— \n'

# if [ ! -d "$url/takover" ]; then
#     mkdir "$url/takover"
# fi

# # subjack
# echo -e "\n[i] Trying subjack..."
# subjack \
#     -w "./$url/live.txt" \
#     -t 100 \
#     -timeout 30 \
#     -o "./$url/takover/subjack.txt" \
#     -ssl \
#     -c ./config/subjack/fingerprints.json \
#     -v
# echo -e '[+] Done!'

# # tko-subs
# tko-subs \
#     -domains=./"$url"/live.txt \
#     -data=./config/tko-subs/providers-data.csv \
#     -output=./"$url"/takover/tkosubs.csv

# echo -e '
#   ENUMERATE HOSTS
#  ————————————————— \n'

# if [ ! -d "$url/hosts" ]; then
#     mkdir "$url/hosts"
# fi

# # subdomain's IP
# echo "[i] Getting IPs for subdomains..."

# while read -r sub; do
#     ip=$(dig +short "$sub")
#     echo "$ip" - "$sub" | tee -a "./$url/hosts/ip-sub.txt"
#     echo "$ip" >>"./$url/hosts/ips.txt"
# done <./"$url"/probed.txt

# echo -e "[+] Done! Saved to ./$url/hosts/subs-ip.txt \n"

# # IP list
# echo "[i] List of IPs..."
# sort \
#     -u -t . \
#     -k 1,1n -k 2,2n -k 3,3n -k 4,4n \
#     -o "./$url/hosts/ips.txt" \
#     "./$url/hosts/ips.txt"
# echo -e "[+] Saved to ./$url/hosts/ips.txt\n"


# # nmap
# echo "[i] Scanning every of $(cat ./$url/ips.txt | wc -l) IP with nmap..."
# [[ ! -d ./$url/nmap ]] && mkdir ./$url/nmap
# while read ip; do
# 	echo -e "\n> nmap for: $ip"
# 	nmap -T4 -p- -sV -Pn --max-retries 1 --max-scan-delay 20 --defeat-rst-ratelimit --open -oN "./$url/nmap/$ip.txt" $ip
# done <"./$url/ips.txt"
# echo -e "\n[+] Done! Repots saved to ./$url/nmap/ \n"

# hakrawler
# echo -e "\n[i] Starting hakrawler..."
# [[ ! -d ./$url/hakrawler ]] && mkdir ./$url/hakrawler
# while read domain; do
# 	echo -e "\n> $domain"
# 	# hakrawler -url $domain -depth 5 -plain -linkfinder -js -forms -insecure | tee ./$url/hakrawler/$domain.txt
# 	hakrawler -url $domain -plain | tee ./$url/hakrawler/$domain.txt
# done <./$url/subdomains-probed.txt
# echo -e "\n[+] Done! Repots saved to ./$url/hakrawler/ \n"

# webanalyze

exit 0
