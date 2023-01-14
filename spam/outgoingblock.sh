#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function spam_list() {
	cat /etc/outgoing_mail_suspended_users >>$temp/outgoingblock_$time.txt
}

function check_list() {
	if [ -r $temp/outgoingblock_$time.txt ] && [ -s $temp/outgoingblock_$time.txt ]; then
		blocklist=($(cat $temp/outgoingblock_$time.txt))

		if [ ! -z $blocklist ]; then
			cat $temp/outgoingblock_$time.txt >>$svrlogs/spam/mailblock/outgoingblock_$time.txt
		fi
	fi
}

function check_new() {
	if [ -r $svrlogs/spam/mailblock/outgoingblock_$time.txt ] && [ -s $svrlogs/spam/mailblock/outgoingblock_$time.txt ]; then
		tlist=($(ls -lat $svrlogs/spam/mailblock | grep "outgoingblock" | grep -i "$(date +"%F")" | head -1 | awk '{print "$svrlogs/spam/mailblock/"$9}'))
		ylist=($(ls -lat $svrlogs/spam/mailblock | grep "outgoingblock" | grep -i "$(date -d 'yesterday' +"%F")" | head -1 | awk '{print "$svrlogs/spam/mailblock/"$9}'))

		tusers=($(cat $tlist))
		yusers=($(cat $ylist))

		tcount=${#tusers[@]}
		ycount=${#yusers[@]}

		if [ $ycount -ne 0 ]; then
			for ((i = 0; i < tcount; i++)); do
				for ((j = 0; j < ycount; j++)); do
					if [[ "${tusers[i]}" == "${yusers[j]}" ]]; then
						nusers+=("${tusers[i]}")
					fi
				done
			done

			ncount=${#nusers[@]}

			newusers=$(cat $tlist)

			if [ $ncount -ne 0 ]; then
				for ((k = 0; k < ncount; k++)); do
					newusers=$(echo "$newusers" | grep -v "${nusers[k]}")
				done
			fi
		else
			newusers=$(cat $tlist)
		fi
	fi
}

function new_data() {
	if [[ ! -z "$newusers" ]]; then
		newcount=$(echo "$newusers" | wc -l)

		echo "Total: $tcount" >>$svrlogs/serverwatch/outgoingblock_$time.txt
		echo "New Entries: $newcount" >>$svrlogs/serverwatch/outgoingblock_$time.txt
		echo "" >>$svrlogs/serverwatch/outgoingblock_$time.txt
		echo "$newusers" >>$svrlogs/serverwatch/outgoingblock_$time.txt
	fi
}

spam_list

check_list

check_new

new_data
