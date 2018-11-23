#!/bin/bash

#Global Variables
ME=`basename "$0"`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
#DATE as UNIX timestamp in nanoseconds for influxdb
DATE=$(date +%s%N)
#Website name used for log path
WEBSITE="matthewdavidson.us"

#Test log file exists and exit if not.
if [ ! -f /var/www/html/${WEBSITE}/logs/access.log ]; then
	#Log error to screen and to logfile. Remove -s to only log
	logger -s "${DIR}/${ME} Log file does not exist. Exit script."
	exit
fi

#Create data file from apache logs
#Pull last minute of data
CURTIME=$(date -d -1min +'%d/%b/%Y:%H:%M' | sed 's#/#.#g')
sed "1,/$CURTIME/d" /var/www/html/${WEBSITE}/logs/access.log > ./access.log

#Extract response codes and count
awk '{if ($9 ~ /^[0-9][0-9][0-9]$/) print $9}' ./access.log | sort -n | uniq -c > ./httpd_codes

#Process codes for telegraf 
while IFS=" " read -r count response 
do
  echo "my_http_code $response=$count $DATE"
done < ./httpd_codes
