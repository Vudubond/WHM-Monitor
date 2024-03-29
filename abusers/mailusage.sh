#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function mail_usage() {
	list=($(ls -lat $svrlogs/serverwatch | grep -i "diskusage" | grep -i "$(date +"%F")" | head -1 | awk '{print "$svrlogs/serverwatch/"$9}'))

	users=($(cat $list | awk '{print $1}'))
	usage=($(cat $list | awk '{print $3}'))

	count=${#users[@]}

	for ((i = 0; i < count; i++)); do
		username=${users[i]}
		usedspace=${usage[i]}

		if [ $usedspace -gt 10240 ]; then
			mail=$(du -sm /home/$username/mail | awk '{print $1}')

			if [ $mail -gt 10240 ]; then
				package=$(whmapi1 accountsummary user=$username | grep -i "plan:" | awk -F':' '{print $2}')

				status=$(whmapi1 accountsummary user=$username | grep -i "outgoing_mail_suspended:" | awk '{print $2}')

				if [ "$status" -eq 0 ]; then
					printf "%-12s - %6s M - %-12s - %-70s\n" "$username" "$mail" "Active" "$package" >>$temp/mailusage_$time.txt
				else
					printf "%-12s - %6s M - %-12s - %-70s\n" "$username" "$mail" "Suspended" "$package" >>$temp/mailusage_$time.txt
				fi
			fi
		fi
	done
}

function mail_usage_sort() {
	if [ -r $temp/mailusage_$time.txt ] && [ -s $temp/mailusage_$time.txt ]; then
		cat $temp/mailusage_$time.txt | sort -nrk3 >>$svrlogs/abusers/mailusage_$time.txt
	fi
}

mail_usage

mail_usage_sort
