#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function login_log() {
	cat /usr/local/cpanel/logs/login_log | grep -ie "$(date -d '1 hour ago' +"%F %H:")" | grep "FAILED LOGIN" | awk '{print $1,$5,$6,$8,$9}' | sed 's/[][]//g;s/"//' | awk '{printf "%-19s %-20s %-13s %-22s %-50s\n","DATE: "$1,"LOGIN: "$2,"TYPE: "$5,"IP: "$3,"USER: "$4}' | sort | uniq -c | sort -k11 >>$temp/loginfail_$time.txt
}

function check_log() {
	if [ -r $temp/loginfail_$time.txt ] && [ -s $temp/loginfail_$time.txt ]; then
		ips=($(cat $temp/loginfail_$time.txt | awk '{print $9}' | sort | uniq | grep -v "127.0.0.1"))
		count=${#ips[@]}

		for ((i = 0; i < count; i++)); do
			search=$(whmapi1 read_cphulk_records list_name='black' | grep ${ips[i]})

			if [[ -z $search ]]; then
				data=$(cat $temp/loginfail_$time.txt | grep ${ips[i]})
				
				whois=$(curl https://ipapi.co/${ips[i]}/country/)
				error=$(echo "$whois" | grep "error")

				if [[ ! -z $error ]]; then
					iplookup=$(curl ipinfo.io/${ips[i]})
					whois=$(echo "$iplookup" | grep "country" | awk '{print $2}' | sed 's/"//g;s/,//')
				fi

				while IFS= read -r line; do
					printf "%-140s %-10s\n" "$line" "ID: $whois" >>$temp/failed-login_$time.txt
				done <<<"$data"
			fi
		done
	fi
}

function mail_check() {
	if [ -r $temp/failed-login_$time.txt ] && [ -s $temp/failed-login_$time.txt ]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			email=$(echo "$line" | awk '{print $11}')

			if [[ $email == *[@]* ]]; then
				domain=$(echo "$email" | awk -F'@' '{print $2}')
				username=$(whmapi1 getdomainowner domain=$domain | grep -i "user:" | awk '{print $2}')

				if [[ "$username" != "~" ]]; then
					status=$(uapi --user=$username Mailboxes get_mailbox_status_list account=$email | grep -i "status:" | awk '{print $2}')

					if [ "$status" -eq 0 ]; then
						echo "$line" >>$temp/failed-attempt_$time.txt
					fi
				else
					echo "$line" >>$temp/failed-attempt_$time.txt
				fi
			else
				echo "$line" >>$temp/failed-attempt_$time.txt
			fi

		done <"$temp/failed-login_$time.txt"
	fi
}

function sort_log() {
	if [ -r $temp/failed-attempt_$time.txt ] && [ -s $temp/failed-attempt_$time.txt ]; then
		sortlog=$(cat $temp/failed-attempt_$time.txt | grep -v "LK" | sort -k11)

		if [[ ! -z $sortlog ]]; then
			echo "$sortlog" >>$svrlogs/cphulk/iplist/failed-attempt_$time.txt
		fi
	fi
}

function blacklist() {
	if [ -r $svrlogs/cphulk/iplist/failed-attempt_$time.txt ] && [ -s $svrlogs/cphulk/iplist/failed-attempt_$time.txt ]; then
		sh /home/$cpuser/scripts/cphulk/ipblacklist.sh failed-attempt
	fi
}

function summary() {
	loginfail=($(ls -lat $temp | grep -i "loginfail" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
	lflen=${#loginfail[@]}

	if [ $lflen -ne 0 ]; then
		count=$(wc -l $loginfail | awk '{print $1}')

		uniqipcount=$(cat $loginfail | awk '{print $9}' | sort | uniq | wc -l)

		failedlogin=($(ls -lat $temp | grep -i "failed-login" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
		fdlen=${#failedlogin[@]}

		if [ $fdlen -ne 0 ]; then
			newcount=$(wc -l $failedlogin | awk '{print $1}')

			newuniqip=$(cat $failedlogin | awk '{print $9}' | sort | uniq | wc -l)

			blacklist=($(ls -lat $svrlogs/cphulk/block | grep -i "loginip-blacklisted" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/block/"$9}'))
			blen=${#blacklist[@]}

			if [ $blen -ne 0 ]; then
				login=($(ls -lat $svrlogs/cphulk/iplist | grep -i "failed-attempt" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/iplist/"$9}'))

				listed=$(wc -l $login | awk '{print $1}')

				uniqlisted=$(cat $blacklist | grep "Total:" | awk '{print $2}')

				ip_data
			fi
		fi
	fi
}

function ip_data() {
	echo "Login failure count: $count" >>$svrlogs/ipmonitor/loginlog_$time.txt

	echo "Login failure unique IP count: $uniqipcount" >>$svrlogs/ipmonitor/loginlog_$time.txt

	echo "" >>$svrlogs/ipmonitor/loginlog_$time.txt

	echo "New login failure count: $newcount" >>$svrlogs/ipmonitor/loginlog_$time.txt

	echo "New login failure unique IP count: $newuniqip" >>$svrlogs/ipmonitor/loginlog_$time.txt

	echo "" >>$svrlogs/ipmonitor/loginlog_$time.txt

	echo "Login failure count (excluding LK): $listed" >>$svrlogs/ipmonitor/loginlog_$time.txt

	echo "Blacklisted unique IP count: $uniqlisted" >>$svrlogs/ipmonitor/loginlog_$time.txt

	echo "" >>$svrlogs/ipmonitor/loginlog_$time.txt

	cat $login >>$svrlogs/ipmonitor/loginlog_$time.txt
}

login_log

check_log

mail_check

sort_log

blacklist

summary
