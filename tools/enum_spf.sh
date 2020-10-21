#!/bin/bash

# Info: An Sender Policy Framework (SPF) record and is used to indicate to recieving mail exchanges which hosts are authorized to send mail for a given domain. SPF record lists all the hosts that are authorised send emails on behalf of a domain.
# by yuraloginoff

# Exit if no arguments
[[ $# -eq 0 ]] && {
	echo "Usage: $0 domain.com"
	exit 1
}

url=$1

spf=$(dig +short TXT $url | grep spf) # "v=spf1 include:abc.com ... ip4:1.2.3.4 ~all"
array=($spf)

unset -v 'array[0]'  # "v=spf1
unset -v 'array[-1]' # ~all"

for VAR in ${array[@]}; do
	echo $VAR | sed -e s/"include:"// -e s/"ip4:"//
done

exit 0
