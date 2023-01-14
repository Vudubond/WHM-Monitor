#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function rmvblacklist_auto() {
	for ((i = 0; i < len; i++)); do
		username=$(echo "${blacklistold[i]}" | awk -F'_' '{print $1}')

		if [[ $username == "failed-dovecot" ]]; then
			ips=($(cat $svrlogs/cphulk/iplist/${blacklistold[i]} | awk '{print $5}' | sort | uniq))

		elif [[ $username == "failed-ftpd" ]]; then
			ips=($(cat $svrlogs/cphulk/iplist/${blacklistold[i]} | awk '{print $6}' | sort | uniq))

		elif [[ $username == "failed-ssh" ]]; then
			ips=($(cat $svrlogs/cphulk/iplist/${blacklistold[i]} | awk '{print $7}' | sort | uniq))

		elif [[ $username == "fake-mail" ]]; then
			ips=($(cat $svrlogs/cphulk/iplist/${blacklistold[i]} | awk '{print $8}' | sort | uniq))

		elif [[ $username == "failed-attempt" || $username == "failed-wplogin" || $username == "cptemp-block" ]]; then
			ips=($(cat $svrlogs/cphulk/iplist/${blacklistold[i]} | awk '{print $9}' | sort | uniq))

		fi

		echo "$(date +"%F %T") Started - $svrlogs/cphulk/unblock/$username-rmvblacklistauto_$time.txt" >>$svrlogs/logs/cphulk_$logtime.txt

		ipcount=${#ips[@]}

		num=0

		for ((j = 0; j < ipcount; j++)); do
			search=$(whmapi1 read_cphulk_records list_name='black' | grep ${ips[j]})

			if [[ ! -z $search ]]; then
				result=$(whmapi1 delete_cphulk_record list_name='black' ip=${ips[j]} | grep -i "result:" | awk '{print $2}')
				num=$((num + 1))

				if [ "$result" -eq 1 ]; then
					echo "$num - Removed: ${ips[j]}" >>$svrlogs/cphulk/unblock/$username-rmvblacklistauto_$time.txt
				else
					echo "$num - Failed: ${ips[j]}" >>$svrlogs/cphulk/unblock/$username-rmvblacklistauto_$time.txt
				fi
			fi
		done

		echo "Total: $num" >>$svrlogs/cphulk/unblock/$username-rmvblacklistauto_$time.txt
		echo "" >>$svrlogs/cphulk/unblock/$username-rmvblacklistauto_$time.txt

		echo "$(date +"%F %T") Completed - $svrlogs/cphulk/unblock/$username-rmvblacklistauto_$time.txt" >>$svrlogs/logs/cphulk_$logtime.txt
	done
}

function mail_blacklist() {
	blacklistold=($(ls $svrlogs/cphulk/iplist | grep "fake-mail" | grep -i "$(date -d '14 days ago' +"%F")"))
	len=${#blacklistold[@]}

	if [ $len -ne 0 ]; then
		rmvblacklist_auto
	fi
}

function ftpd_blacklist() {
	blacklistold=($(ls $svrlogs/cphulk/iplist | grep "failed-ftpd" | grep -i "$(date -d '14 days ago' +"%F")"))
	len=${#blacklistold[@]}

	if [ $len -ne 0 ]; then
		rmvblacklist_auto
	fi
}

function ssh_blacklist() {
	blacklistold=($(ls $svrlogs/cphulk/iplist | grep "failed-ssh" | grep -i "$(date -d '14 days ago' +"%F")"))
	len=${#blacklistold[@]}

	if [ $len -ne 0 ]; then
		rmvblacklist_auto
	fi
}

function dovecot_blacklist() {
	blacklistold=($(ls $svrlogs/cphulk/iplist | grep "failed-dovecot" | grep -i "$(date -d '14 days ago' +"%F")"))
	len=${#blacklistold[@]}

	if [ $len -ne 0 ]; then
		rmvblacklist_auto
	fi
}

function login_blacklist() {
	blacklistold=($(ls $svrlogs/cphulk/iplist | grep "failed-attempt" | grep -i "$(date -d '14 days ago' +"%F")"))
	len=${#blacklistold[@]}

	if [ $len -ne 0 ]; then
		rmvblacklist_auto
	fi

}

function wplogin_blacklist() {
	blacklistold=($(ls $svrlogs/cphulk/iplist | grep "failed-wplogin" | grep -i "$(date -d '14 days ago' +"%F")"))
	len=${#blacklistold[@]}

	if [ $len -ne 0 ]; then
		rmvblacklist_auto
	fi
}

function cphulk_blacklist() {
	blacklistold=($(ls $svrlogs/cphulk/iplist | grep "cptemp-block" | grep -i "$(date -d '14 days ago' +"%F")"))
	len=${#blacklistold[@]}

	if [ $len -ne 0 ]; then
		rmvblacklist_auto
	fi
}

mail_blacklist

ftpd_blacklist

ssh_blacklist

dovecot_blacklist

login_blacklist

wplogin_blacklist

cphulk_blacklist
