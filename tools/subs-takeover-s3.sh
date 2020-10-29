#!/usr/bin/env bash

# manual - Amazon S3
while read -r sub; do
    curl -s http://"$sub" \
    | grep -E -q '<Code>NoSuchBucket</Code>|<li>Code: NoSuchBucket</li>' \
        && echo "Subdomain takeover may be possible - $sub" \
        || echo "Subdomain takeover is NOT possible - $sub"
done <./"$url"/probed.txt

