#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function dovecot_login() {
	cat /var/log/exim_mainlog | grep -ie "$(date -d '1 hour ago' +"%F %H:")" | grep "dovecot_login" | grep "Incorrect authentication data" | awk '{for(i=1;i<=NF;i++) {if ($i==535) print $1,$(i-1),$7,$NF}}' | grep -v "127.0.0.1\|localhost" | sed 's/(//g;s/)//g;s/[][]//g;s/set_id=//' | awk -F'[: ]' '{printf "%-19s %-22s %-50s\n","DATE: "$1,"IP: "$2,"EMAIL: "$NF}' | sort | uniq -c | sort -k6 >>$temp/dovecotlogin_$time.txt
}

function check_log() {
	if [ -r $temp/dovecotlogin_$time.txt ] && [ -s $temp/dovecotlogin_$time.txt ]; then
		ips=($(cat $temp/dovecotlogin_$time.txt | awk '{print $5}' | sort | uniq | grep -v "127.0.0.1"))
		count=${#ips[@]}

		for ((i = 0; i < count; i++)); do
			search=$(whmapi1 read_cphulk_records list_name='black' | grep ${ips[i]})

			if [[ -z $search ]]; then
				data=$(cat $temp/dovecotlogin_$time.txt | grep ${ips[i]})
				
				whois=$(curl https://ipapi.co/${ips[i]}/country/)
				error=$(echo "$whois" | grep "error")

				if [[ ! -z $error ]]; then
					iplookup=$(curl ipinfo.io/${ips[i]})
					whois=$(echo "$iplookup" | grep "country" | awk '{print $2}' | sed 's/"//g;s/,//')
				fi

				while IFS= read -r line; do
					printf "%-100s %-10s\n" "$line" "ID: $whois" >>$temp/failed-dovecot_$time.txt
				done <<<"$data"
			fi
		done
	fi
}

function sort_log() {
	if [ -r $temp/failed-dovecot_$time.txt ] && [ -s $temp/failed-dovecot_$time.txt ]; then
		sortlog=$(cat $temp/failed-dovecot_$time.txt | grep -v "LK" | sort -k6)

		if [[ ! -z $sortlog ]]; then
			echo "$sortlog" >>$svrlogs/cphulk/iplist/failed-dovecot_$time.txt
		fi
	fi
}

function blacklist() {
	if [ -r $svrlogs/cphulk/iplist/failed-dovecot_$time.txt ] && [ -s $svrlogs/cphulk/iplist/failed-dovecot_$time.txt ]; then
		sh /home/$cpuser/scripts/cphulk/ipblacklist.sh failed-dovecot
	fi
}

function summary() {
	dovecotlogin=($(ls -lat $temp | grep "dovecotlogin" | grep "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
	dllen=${#dovecotlogin[@]}

	if [ $dllen -ne 0 ]; then
		count=$(wc -l $dovecotlogin | awk '{print $1}')

		uniqipcount=$(cat $dovecotlogin | awk '{print $5}' | sort | uniq | wc -l)

		faileddovecot=($(ls -lat $temp | grep "failed-dovecot" | grep "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
		fdlen=${#faileddovecot[@]}

		if [ $fdlen -ne 0 ]; then
			newcount=$(wc -l $faileddovecot | awk '{print $1}')

			newuniqip=$(cat $faileddovecot | awk '{print $5}' | sort | uniq | wc -l)

			blacklist=($(ls -lat $svrlogs/cphulk/block | grep -i "dovecotip-blacklisted" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/block/"$9}'))
			blen=${#blacklist[@]}

			if [ $blen -ne 0 ]; then
				login=($(ls -lat $svrlogs/cphulk/iplist | grep -i "failed-dovecot" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/iplist/"$9}'))

				listed=$(wc -l $login | awk '{print $1}')

				uniqlisted=$(cat $blacklist | grep "Total:" | awk '{print $2}')

				ip_data
			fi
		fi
	fi
}

function ip_data() {
	echo "Dovecot login failure count: $count" >>$svrlogs/ipmonitor/eximdovecot_$time.txt

	echo "Dovecot login failure unique IP count: $uniqipcount" >>$svrlogs/ipmonitor/eximdovecot_$time.txt

	echo "" >>$svrlogs/ipmonitor/eximdovecot_$time.txt

	echo "Dovecot new login failure count: $newcount" >>$svrlogs/ipmonitor/eximdovecot_$time.txt

	echo "Dovecot new login failure unique IP count: $newuniqip" >>$svrlogs/ipmonitor/eximdovecot_$time.txt

	echo "" >>$svrlogs/ipmonitor/eximdovecot_$time.txt

	echo "Dovecot login failure count (excluding LK): $listed" >>$svrlogs/ipmonitor/eximdovecot_$time.txt

	echo "Blacklisted unique IP count: $uniqlisted" >>$svrlogs/ipmonitor/eximdovecot_$time.txt

	echo "" >>$svrlogs/ipmonitor/eximdovecot_$time.txt

	cat $login >>$svrlogs/ipmonitor/eximdovecot_$time.txt
}

dovecot_login

check_log

sort_log

blacklist

summary
