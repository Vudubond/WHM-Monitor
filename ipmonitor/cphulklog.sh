#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function cphulk_log() {
	cat /usr/local/cpanel/logs/cphulkd.log | grep -ie "$(date -d '1 hour ago' +"%F %H:")" | grep "Login Blocked: IP reached maximum auth failures for a one day block" | awk -F'[= ]' '{for (i=0;i<NF;i++) {for (j=0;j<NF;j++) {if ($i=="[Remote" && $(i+1)=="IP" && $j=="[Authentication") print $1,$19,$(i+3),$(j+2),$(j+4)}}}' | sed 's/[][]//g' | awk '{printf "%-19s %-21s %-13s %-22s %-50s\n","DATE: "$1,"SERVICE: "$2,"DB: "$4,"IP: "$3,"USER: "$NF}' | sort | uniq -c | sort -k11 >>$temp/cphulklog_$time.txt

	cat /usr/local/cpanel/logs/cphulkd.log | grep -ie "$(date -d '1 hour ago' +"%F %H:")" | grep "Login Blocked: IP reached maximum auth failures" | grep -v "for a one day block" | awk -F'[= ]' '{for (i=0;i<NF;i++) {for (j=0;j<NF;j++) {if ($i=="[Remote" && $(i+1)=="IP" && $j=="[Authentication") print $1,$14,$(i+3),$(j+2),$(j+4)}}}' | sed 's/[][]//g' | awk '{printf "%-19s %-21s %-13s %-22s %-50s\n","DATE: "$1,"SERVICE: "$2,"DB: "$4,"IP: "$3,"USER: "$NF}' | sort | uniq -c | sort -k11 >>$temp/cphulklog_$time.txt

	cat /usr/local/cpanel/logs/cphulkd.log | grep -ie "$(date -d '1 hour ago' +"%F %H:")" | grep "Login Blocked: The IP address is marked as an excessive brute." | awk -F'[= ]' '{print $1,$18,$29,$35,$37}' | sed 's/[][]//g' | awk '{printf "%-19s %-21s %-13s %-22s %-50s\n","DATE: "$1,"SERVICE: "$2,"DB: "$4,"IP: "$3,"USER: "$NF}' | sort | uniq -c | sort -k11 >>$temp/cphulklog_$time.txt
}

function check_log() {
	if [ -r $temp/cphulklog_$time.txt ] && [ -s $temp/cphulklog_$time.txt ]; then
		ips=($(cat $temp/cphulklog_$time.txt | awk '{print $9}' | sort | uniq | grep -v "127.0.0.1"))
		count=${#ips[@]}

		for ((i = 0; i < count; i++)); do
			search=$(whmapi1 read_cphulk_records list_name='black' | grep ${ips[i]})

			if [[ -z $search ]]; then
				data=$(cat $temp/cphulklog_$time.txt | grep ${ips[i]})
				
				whois=$(curl https://ipapi.co/${ips[i]}/country/)
				error=$(echo "$whois" | grep "error")

				if [[ ! -z $error ]]; then
					iplookup=$(curl ipinfo.io/${ips[i]})
					whois=$(echo "$iplookup" | grep "country" | awk '{print $2}' | sed 's/"//g;s/,//')
				fi

				while IFS= read -r line; do
					printf "%-140s %-10s\n" "$line" "ID: $whois" >>$temp/failed-cphulk_$time.txt
				done <<<"$data"
			fi
		done
	fi
}

function mail_check() {
	if [ -r $temp/failed-cphulk_$time.txt ] && [ -s $temp/failed-cphulk_$time.txt ]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			email=$(echo "$line" | awk '{print $11}')

			if [[ $email == *[@]* ]]; then
				domain=$(echo "$email" | awk -F'@' '{print $2}')
				username=$(whmapi1 getdomainowner domain=$domain | grep -i "user:" | awk '{print $2}')

				if [[ "$username" != "~" ]]; then
					status=$(uapi --user=$username Mailboxes get_mailbox_status_list account=$email | grep -i "status:" | awk '{print $2}')

					if [ "$status" -eq 0 ]; then
						echo "$line" >>$temp/cptemp-block_$time.txt
					fi
				else
					echo "$line" >>$temp/cptemp-block_$time.txt
				fi
			else
				echo "$line" >>$temp/cptemp-block_$time.txt
			fi

		done <"$temp/failed-cphulk_$time.txt"
	fi
}

function sort_log() {
	if [ -r $temp/cptemp-block_$time.txt ] && [ -s $temp/cptemp-block_$time.txt ]; then
		sortlog=$(cat $temp/cptemp-block_$time.txt | grep -v "LK" | sort -k11)

		if [[ ! -z $sortlog ]]; then
			echo "$sortlog" >>$svrlogs/cphulk/iplist/cptemp-block_$time.txt
		fi
	fi
}

function blacklist() {
	if [ -r $svrlogs/cphulk/iplist/cptemp-block_$time.txt ] && [ -s $svrlogs/cphulk/iplist/cptemp-block_$time.txt ]; then
		sh /home/$cpuser/scripts/cphulk/ipblacklist.sh cptemp-block
	fi
}

function summary() {
	cphulklog=($(ls -lat $temp | grep -i "cphulklog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
	cplen=${#cphulklog[@]}

	if [ $cplen -ne 0 ]; then
		count=$(wc -l $cphulklog | awk '{print $1}')

		uniqipcount=$(cat $cphulklog | awk '{print $9}' | sort | uniq | wc -l)

		failedcphulk=($(ls -lat $temp | grep -i "failed-cphulk" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
		fclen=${#failedcphulk[@]}

		if [ $fclen -ne 0 ]; then
			newcount=$(wc -l $failedcphulk | awk '{print $1}')

			newuniqip=$(cat $failedcphulk | awk '{print $9}' | sort | uniq | wc -l)

			blacklist=($(ls -lat $svrlogs/cphulk/block | grep -i "cphulkip-blacklisted" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/block/"$9}'))
			blen=${#blacklist[@]}

			if [ $blen -ne 0 ]; then
				login=($(ls -lat $svrlogs/cphulk/iplist | grep -i "cptemp-block" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/iplist/"$9}'))

				listed=$(wc -l $login | awk '{print $1}')

				uniqlisted=$(cat $blacklist | grep "Total:" | awk '{print $2}')

				ip_data
			fi
		fi
	fi
}

function ip_data() {
	echo "cPHulk login failure count: $count" >>$svrlogs/ipmonitor/cphulklog_$time.txt

	echo "cPHulk login failure unique IP count: $uniqipcount" >>$svrlogs/ipmonitor/cphulklog_$time.txt

	echo "" >>$svrlogs/ipmonitor/cphulklog_$time.txt

	echo "cPHulk new login failure count: $newcount" >>$svrlogs/ipmonitor/cphulklog_$time.txt

	echo "cPHulk new login failure unique IP count: $newuniqip" >>$svrlogs/ipmonitor/cphulklog_$time.txt

	echo "" >>$svrlogs/ipmonitor/cphulklog_$time.txt

	echo "cPHulk login failure count (excluding LK): $listed" >>$svrlogs/ipmonitor/cphulklog_$time.txt

	echo "Blacklisted unique IP count: $uniqlisted" >>$svrlogs/ipmonitor/cphulklog_$time.txt

	echo "" >>$svrlogs/ipmonitor/cphulklog_$time.txt

	cat $login >>$svrlogs/ipmonitor/cphulklog_$time.txt
}

cphulk_log

check_log

mail_check

sort_log

blacklist

summary
