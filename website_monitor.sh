#!/bin/bash

website="https://matthewdavidson.us"
d=`date +%Y-%m-%d-%H:%M:%S
OK=$(curl --write-out %{http_code} --silent --connect-timeout 3 --no-keepalive --output /dev/null ${website})

if [ ${OK} == "200" ]; then
    echo "${d} Site is up." >> /var/log/website_check.log
else
    echo "${d} Site might be down." >> /var/log/website_check.log
    curl -X POST https://textbelt.com/text --data-urlencode phone='1234567890' --data-urlencode message='Check matthewdavidson.us as it returned an invalid response.' -d key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fi
