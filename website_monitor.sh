#!/bin/bash

WEBSITE="https://matthewdavidson.us"
CDATE=`date +%Y-%m-%d-%H:%M:%S
LOGFILE="/var/log/website_check.log"
OK=$(curl --write-out %{http_code} --silent --connect-timeout 3 --no-keepalive --output /dev/null ${WEBSITE})

if [ ${OK} == "200" ]; then
    echo "${CDATE} Site is up." >> ${LOGFILE}
else
    echo "${CDATE} Site might be down." >> ${LOGFILE}
    curl -X POST https://textbelt.com/text --data-urlencode phone='1234567890' --data-urlencode message='Check matthewdavidson.us as it returned an invalid response.' -d key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fi
