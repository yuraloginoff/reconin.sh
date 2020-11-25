#!/usr/bin/env bash







if [ ! -d "/home/arpo/.local/bin" ]; then
  mkdir -p /home/arpo/.local/bin
fi


cd Downloads/ || exit 1

sudo apt-get install jq -y
sudo apt-get install whois
sudo apt-get install postgresql-12

go get -u github.com/tomnomnom/assetfinder

export GO111MODULE=on
go get -v github.com/OWASP/Amass/v3/...


cargo install findomain

GO111MODULE=on go get -u -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder

git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r/
sudo pip3 install -r requirements.txt
ln -s /home/arpo/Downloads/Sublist3r/sublist3r.py /home/arpo/.local/bin/sublist3r
python3 ~/.local/bin/sublist3r

pip3 install dnsgen

git clone https://github.com/blechschmidt/massdns.git
cd massdns/
make
ln -s /home/arpo/Downloads/massdns/bin/massdns /home/arpo/.local/bin/massdns
massdns --help
cd ./..

GO111MODULE=on go get -u -v github.com/projectdiscovery/httpx/cmd/httpx

go get github.com/haccer/subjack

go get github.com/anshumanbh/tko-subs

GO111MODULE=on go get -u -v github.com/projectdiscovery/naabu/v2/cmd/naabu

GO111MODULE=on go get -u -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei

cargo install feroxbuster

go get github.com/hakluke/hakrawler

GO111MODULE=on go get -u -v github.com/lc/gau

go get -u github.com/hahwul/dalfox

go get -u github.com/tomnomnom/qsreplace

go get github.com/tomnomnom/waybackurls

go get -u github.com/jaeles-project/gospider
