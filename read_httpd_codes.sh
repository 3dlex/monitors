#!/bin/bash

#Global Variables
ME=`basename "$0"`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
#DATE as UNIX timestamp in nanoseconds for influxdb
DATE=$(date +%s%N)
#Website name used for log path
WEBSITE="matthewdavidson.us"
#Setup scratch files
ACCESS="/tmp/access.log"
touch ${ACCESS}
HTTPDCODES="/tmp/httpd_codes"
touch ${HTTPDCODES}

test_log(){
	#Test log file exists and exit if not.
	if [ ! -f /var/www/html/${WEBSITE}/logs/access.log ]; then
		#Log error to screen and to logfile. Remove -s to only log
		logger -s "${DIR}/${ME} Log file does not exist. Exit script."
		exit
		
	fi
}

pull_logs(){
	#Create data file from apache logs
	#Pull last minute of data
	CURTIME=$(date -d -1min +'%d/%b/%Y:%H:%M' | sed 's#/#.#g')
	sed "1,/$CURTIME/d" /var/www/html/${WEBSITE}/logs/access.log > ${ACCESS}
}

extract_codes(){
	#Extract response codes and count
	awk '{if ($9 ~ /^[0-9][0-9][0-9]$/) print $9}' ./access.log | sort -n | uniq -c > ${HTTPDCODES}
}

process_codes(){
	#Process codes for telegraf
	while IFS=" " read -r count response 
	do
		echo "my_http_code $response=$count $DATE"
	done < ${HTTPDCODES}
}

cleanup(){
	#Cleanup
	rm ${ACCESS}
	rm ${HTTPDCODES}
}

#Main script
test_log
pull_logs
extract_codes
process_codes
cleanup
