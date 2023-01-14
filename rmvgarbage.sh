#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function wget_sms() {
	sms=$(ls | grep "blue454monkey")

	if [[ ! -z $sms ]]
	then
		while IFS= read -r line
		do
			rm -f "$line"
			echo "$(date +"%F %T") Removed - $line" >>$svrlogs/logs/garbagelogs_$logtime.txt
			
		done <<<"$sms"
	fi
}

wget_sms
