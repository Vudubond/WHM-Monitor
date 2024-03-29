#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function process_check() {
	process=$(ps aux | grep "/home/$cpuser/scripts/network/" | grep "loadtime" | grep -v grep)

	if [[ -z $process ]]; then
		sh /home/$cpuser/scripts/network/loadtimecheck.sh
	else
		echo "$(date +"%F %T")" >>$svrlogs/network/process_$logtime.txt
		echo "$process" >>$svrlogs/network/process_$logtime.txt
	fi
}

process_check
