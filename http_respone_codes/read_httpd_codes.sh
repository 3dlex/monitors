#!/bin/bash

#Global Variables
ME=`basename "$0"`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
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
	awk '{print $9}' ${ACCESS} | sort | uniq -c | sort -rn | awk '{print $2 "=" $1}' > ${HTTPDCODES}
}

process_codes(){
	#Process ${HTTPDCODES} for telegraf
	#This awk line will process all lines in ${HTTPDCODES} and put them inline so
	# inputs.exec / telegraf can send them to influxdb.
	# The added i is to let influxdb know these are integers. 
	awk '{a=(NR>1?a"i"",":"")$1} END {print "myhttpd_response_code"" " a"i"}' ${HTTPDCODES}
}

cleanup(){
	#Cleanup previous run
	#logger -s "${DIR}/${ME} completed."
	rm ${ACCESS}
	rm ${HTTPDCODES}
}

#Main script
cleanup
test_log
pull_logs
extract_codes
process_codes
