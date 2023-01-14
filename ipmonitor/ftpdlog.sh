#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function ftpd_log() {
	cat /var/log/messages | grep -ie "$(if (($(date -d '1 hour ago' +"%-d") < 10)); then date -d '1 hour ago' +"%b  %-d %H:"; else date -d '1 hour ago' +"%b %d %H:"; fi)" | grep "pure-ftpd:" | grep "Authentication failed for user" | awk '{print $1,$2,$6,$NF}' | sed 's/(?@//;s/)//;s/[][]//g' | awk '{printf "%-15s %-22s %-50s\n","DATE: "$1" "$2,"IP: "$3,"USER: "$NF}' | sort | uniq -c | sort -k8 >>$temp/ftpdlog_$time.txt
}

function check_log() {
	if [ -r $temp/ftpdlog_$time.txt ] && [ -s $temp/ftpdlog_$time.txt ]; then
		ips=($(cat $temp/ftpdlog_$time.txt | awk '{print $6}' | sort | uniq | grep -v "127.0.0.1"))
		count=${#ips[@]}

		for ((i = 0; i < count; i++)); do
			search=$(whmapi1 read_cphulk_records list_name='black' | grep ${ips[i]})

			if [[ -z $search ]]; then
				data=$(cat $temp/ftpdlog_$time.txt | grep ${ips[i]})
				
				whois=$(curl https://ipapi.co/${ips[i]}/country/)
				error=$(echo "$whois" | grep "error")

				if [[ ! -z $error ]]; then
					iplookup=$(curl ipinfo.io/${ips[i]})
					whois=$(echo "$iplookup" | grep "country" | awk '{print $2}' | sed 's/"//g;s/,//')
				fi

				while IFS= read -r line; do
					printf "%-90s %-10s\n" "$line" "ID: $whois" >>$temp/failed-ftpd_$time.txt
				done <<<"$data"
			fi
		done
	fi
}

function sort_log() {
	if [ -r $temp/failed-ftpd_$time.txt ] && [ -s $temp/failed-ftpd_$time.txt ]; then
		sortlog=$(cat $temp/failed-ftpd_$time.txt | grep -v "LK" | sort -k8)

		if [[ ! -z $sortlog ]]; then
			echo "$sortlog" >>$svrlogs/cphulk/iplist/failed-ftpd_$time.txt
		fi
	fi
}

function blacklist() {
	if [ -r $svrlogs/cphulk/iplist/failed-ftpd_$time.txt ] && [ -s $svrlogs/cphulk/iplist/failed-ftpd_$time.txt ]; then
		sh /home/$cpuser/scripts/cphulk/ipblacklist.sh failed-ftpd
	fi
}

function summary() {
	ftpdlog=($(ls -lat $temp | grep -i "ftpdlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
	fllen=${#ftpdlog[@]}

	if [ $fllen -ne 0 ]; then
		count=$(wc -l $ftpdlog | awk '{print $1}')

		uniqipcount=$(cat $ftpdlog | awk '{print $6}' | sort | uniq | wc -l)

		failedftpd=($(ls -lat $temp | grep -i "failed-ftpd" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
		fflen=${#failedftpd[@]}

		if [ $fflen -ne 0 ]; then
			newcount=$(wc -l $failedftpd | awk '{print $1}')

			newuniqip=$(cat $failedftpd | awk '{print $6}' | sort | uniq | wc -l)

			blacklist=($(ls -lat $svrlogs/cphulk/block | grep -i "ftpdip-blacklisted" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/block/"$9}'))
			blen=${#blacklist[@]}

			if [ $blen -ne 0 ]; then
				login=($(ls -lat $svrlogs/cphulk/iplist | grep -i "failed-ftpd" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/iplist/"$9}'))

				listed=$(wc -l $login | awk '{print $1}')

				uniqlisted=$(cat $blacklist | grep "Total:" | awk '{print $2}')

				ip_data
			fi
		fi
	fi
}

function ip_data() {
	echo "Pure-FTPD login failure count: $count" >>$svrlogs/ipmonitor/ftpdlog_$time.txt

	echo "Pure-FTPD login failure unique IP count: $uniqipcount" >>$svrlogs/ipmonitor/ftpdlog_$time.txt

	echo "" >>$svrlogs/ipmonitor/ftpdlog_$time.txt

	echo "Pure-FTPD new login failure count: $newcount" >>$svrlogs/ipmonitor/ftpdlog_$time.txt

	echo "Pure-FTPD new login failure unique IP count: $newuniqip" >>$svrlogs/ipmonitor/ftpdlog_$time.txt

	echo "" >>$svrlogs/ipmonitor/ftpdlog_$time.txt

	echo "Pure-FTPD login failure count (excluding LK): $listed" >>$svrlogs/ipmonitor/ftpdlog_$time.txt

	echo "Blacklisted unique IP count: $uniqlisted" >>$svrlogs/ipmonitor/ftpdlog_$time.txt

	echo "" >>$svrlogs/ipmonitor/ftpdlog_$time.txt

	cat $login >>$svrlogs/ipmonitor/ftpdlog_$time.txt
}

ftpd_log

check_log

sort_log

blacklist

summary
