#!/bin/bash

website="https://matthewdavidson.us"

OK=$(curl --write-out %{http_code} --silent --connect-timeout 3 --no-keepalive --output /dev/null ${website})

if [ ${OK} == "200" ]; then
    echo "Site is up."
else
    echo "Site might be down."
    curl -X POST https://textbelt.com/text --data-urlencode phone='1234567890' --data-urlencode message='Check matthewdavidson.us as it returned an invalid response.' -d key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fi
