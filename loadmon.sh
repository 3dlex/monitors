#!/bin/bash

#Record top 8 processes currently running.
proc=`ps -Ao user,uid,comm,pid,pcpu,tty --sort=-pcpu | head -n 8`
date=$(date)

echo "----------------------------------------------------------" >> /root/scripts/stats/top8procs
echo "$date" >> /root/scripts/stats/top8procs
echo "$proc" >> /root/scripts/stats/top8procs

#Setup CPU monitor
trigger=2.00
load=`cat /proc/loadavg | awk '{print $1}'`
response=`echo | awk -v T=$trigger -v L=$load 'BEGIN{if ( L > T){ print "greater"}}'`
date=$(date)

if [[ $response = "greater" ]]
  then
  #sar -q | mail -s"High load on server - [ $load ]" recipient@example.com
  echo $date $load >> /root/scripts/stats/cpu
else
  echo $date $load >> /root/scripts/stats/ok_cpu
fi

#Setup Memory monitor
memtrigger=200000
memload=`grep "MemFree:" /proc/meminfo | awk '{print $2}'`
memresponse=`echo | awk -v T=$memtrigger -v L=$memload 'BEGIN{if ( L > T ){ print "greater"}}'`

if [[ $memresponse = "greater" ]]
  then
  echo "$date Used = $memload KB Total = 524288 KB" >> /root/scripts/stats/memory
else
  echo "$date Used = $memload KB Total = 524288 KB" >> /root/scripts/stats/ok_memory
fi

#Check swap use.

swaptrigger=200000
swapload=`cat /proc/swaps | grep -v "Size" | awk '{print $4}'`
swapresponse=`echo | awk -v T=$swaptrigger -v L=$swapload 'BEGIN{if ( L > T ){print "greater"}}'`

if [[ $swapresponse = "greater" ]]
  then
  echo "$date Used = $swapload KB Total = 262144 KB" >> /root/scripts/stats/swap
else
  echo "$date Used = $swapload KB Total = 262144 KB" >> /root/scripts/stats/ok_swap
fi

#Check for reboots I am not aware of.
uptrigger=2
upload=`uptime | awk '{print $3}'`
upresponse=`echo | awk -v T=$uptrigger -v L=$upload 'BEGIN{if ( L < T ){print "greater"}}'`

if [[ $upresponse = "greater" ]]
  then
  echo $date $upload >> /root/scripts/stats/myuptime
else
  echo $date $upload >> /root/scripts/stats/ok_uptime
fi