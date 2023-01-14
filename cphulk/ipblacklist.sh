#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

input=$1

filepath="$svrlogs/cphulk/iplist"

function check_input() {

	if [[ $input == "failed-dovecot" ]]; then
		dovecot_blacklist

	elif [[ $input == "failed-ftpd" ]]; then
		ftpd_blacklist

	elif [[ $input == "failed-ssh" ]]; then
		ssh_blacklist

	elif [[ $input == "fake-mail" ]]; then
		mail_blacklist

	elif [[ $input == "failed-attempt" ]]; then
		login_blacklist

	elif [[ $input == "failed-wplogin" ]]; then
		wplogin_blacklist

	elif [[ $input == "cptemp-block" ]]; then
		cphulk_blacklist

	fi
}

function check_file() {
	username=$(echo "$ipblacklist" | awk -F'_' '{print $1}')

	file="$filepath/$ipblacklist"

	if [[ $username == "failed-dovecot" ]]; then
		filename="dovecotip"

		ips=($(cat $file | awk '{print $5}' | sort | uniq))

	elif [[ $username == "failed-ftpd" ]]; then
		filename="ftpdip"

		ips=($(cat $file | awk '{print $6}' | sort | uniq))

	elif [[ $username == "failed-ssh" ]]; then
		filename="sship"

		ips=($(cat $file | awk '{print $7}' | sort | uniq))

	elif [[ $username == "fake-mail" ]]; then
		filename="mailip"

		ips=($(cat $file | awk '{print $8}' | sort | uniq))

	elif [[ $username == "failed-attempt" ]]; then
		filename="loginip"

		ips=($(cat $file | awk '{print $9}' | sort | uniq))

	elif [[ $username == "failed-wplogin" ]]; then
		filename="wploginip"

		ips=($(cat $file | awk '{print $9}' | sort | uniq))

	elif [[ $username == "cptemp-block" ]]; then
		filename="cphulkip"

		ips=($(cat $file | awk '{print $9}' | sort | uniq))
	fi
}

function ip_blacklist() {

	check_file

	echo "$(date +"%F %T") Started - $svrlogs/cphulk/block/$filename-blacklisted_$time.txt" >>$svrlogs/logs/cphulk_$logtime.txt

	ipcount=${#ips[@]}

	num=0

	for ((i = 0; i < ipcount; i++)); do
		check_data

		search=$(whmapi1 read_cphulk_records list_name='black' | grep "$ip")

		if [[ -z $search ]]; then
			result=$(whmapi1 create_cphulk_record list_name='black' ip=$ip comment="$comment" | grep -i "result:" | awk '{print $2}')
			num=$((num + 1))

			if [ "$result" -eq 1 ]; then
				echo "$num - Blacklisted: $ip" >>$svrlogs/cphulk/block/$filename-blacklisted_$time.txt
			else
				echo "$num - Failed: $ip" >>$svrlogs/cphulk/block/$filename-blacklisted_$time.txt
			fi
		fi
	done

	echo "Total: $num" >>$svrlogs/cphulk/block/$filename-blacklisted_$time.txt
	echo "" >>$svrlogs/cphulk/block/$filename-blacklisted_$time.txt

	echo "$(date +"%F %T") Completed - $svrlogs/cphulk/block/$filename-blacklisted_$time.txt" >>$svrlogs/logs/cphulk_$logtime.txt
}

function check_data() {
	if [[ $username == "failed-dovecot" ]]; then
		line=$(cat $file | grep ${ips[i]} | head -1)
		ip=${ips[i]}
		comment=$(echo "$line" | awk '{print $7" "$9}')

	elif [[ $username == "failed-ftpd" ]]; then
		line=$(cat $file | grep ${ips[i]} | head -1)
		ip=${ips[i]}
		comment=$(echo "$line" | awk '{print $8" "$10}')

	elif [[ $username == "failed-ssh" ]]; then
		line=$(cat $file | grep ${ips[i]} | head -1)
		ip=${ips[i]}
		comment=$(echo "$line" | awk '{print $9" "$14}')

	elif [[ $username == "fake-mail" ]]; then
		line=$(cat $file | grep ${ips[i]} | head -1)
		ip=${ips[i]}
		comment=$(echo "$line" | awk '{print $10" "$12}')

	elif [[ $username == "failed-attempt" ]]; then
		line=$(cat $file | grep ${ips[i]} | head -1)
		ip=${ips[i]}
		comment=$(echo "$line" | awk '{print $11" "$13}')

	elif [[ $username == "failed-wplogin" ]]; then
		line=$(cat $file | grep ${ips[i]} | head -1)
		ip=${ips[i]}
		comment=$(echo "$line" | awk '{print $11" "$13}')

	elif [[ $username == "cptemp-block" ]]; then
		line=$(cat $file | grep ${ips[i]} | head -1)
		ip=${ips[i]}
		comment=$(echo "$line" | awk '{print $11" "$13}')
	fi
}

function mail_blacklist() {
	ipblacklist=($(ls $svrlogs/cphulk/iplist | grep "fake-mail" | grep -i "$(date +"%F_%H:")" | head -1))
	len=${#ipblacklist[@]}

	if [ $len -ne 0 ]; then
		ip_blacklist
	fi
}

function ftpd_blacklist() {
	ipblacklist=($(ls $svrlogs/cphulk/iplist | grep "failed-ftpd" | grep -i "$(date +"%F_%H:")" | head -1))
	len=${#ipblacklist[@]}

	if [ $len -ne 0 ]; then
		ip_blacklist
	fi
}

function ssh_blacklist() {
	ipblacklist=($(ls $svrlogs/cphulk/iplist | grep "failed-ssh" | grep -i "$(date +"%F_%H:")" | head -1))
	len=${#ipblacklist[@]}

	if [ $len -ne 0 ]; then
		ip_blacklist
	fi
}

function dovecot_blacklist() {
	ipblacklist=($(ls $svrlogs/cphulk/iplist | grep "failed-dovecot" | grep -i "$(date +"%F_%H:")" | head -1))
	len=${#ipblacklist[@]}

	if [ $len -ne 0 ]; then
		ip_blacklist
	fi
}

function login_blacklist() {
	ipblacklist=($(ls $svrlogs/cphulk/iplist | grep "failed-attempt" | grep -i "$(date +"%F_%H:")" | head -1))
	len=${#ipblacklist[@]}

	if [ $len -ne 0 ]; then
		ip_blacklist
	fi

}

function wplogin_blacklist() {
	ipblacklist=($(ls $svrlogs/cphulk/iplist | grep "failed-wplogin" | grep -i "$(date +"%F_%H:")" | head -1))
	len=${#ipblacklist[@]}

	if [ $len -ne 0 ]; then
		ip_blacklist
	fi
}

function cphulk_blacklist() {
	ipblacklist=($(ls $svrlogs/cphulk/iplist | grep "cptemp-block" | grep -i "$(date +"%F_%H:")" | head -1))
	len=${#ipblacklist[@]}

	if [ $len -ne 0 ]; then
		ip_blacklist
	fi
}

check_input
