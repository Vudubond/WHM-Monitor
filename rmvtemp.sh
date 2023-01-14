#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

tempoldlogs=($(ls $temp))

for file in "${tempoldlogs[@]}"
do
	rm -f $temp/$file
	echo "$(date +"%F %T") Removed - $temp/$file" >>$svrlogs/logs/templogs_$logtime.txt
done
