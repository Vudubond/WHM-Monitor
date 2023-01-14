#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

sec=5

function loadtime_check() {
	while IFS= read -r line || [[ -n "$line" ]]; do
		ip=$(echo "$line" | awk '{print $1}')
		svrhost=$(host $ip | awk '{print $NF}' | awk -F'.' '{print $1}')
		site=$(echo "$line" | awk '{print $NF}')

		sh /home/$cpuser/scripts/network/loadtime.sh $svrhost $site

		sleep $sec

	done <"/home/$cpuser/scripts/network/ip.txt"
}

loadtime_check
