#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function ssh_log() {
	cat /var/log/secure | grep -ie "$(if (($(date -d '1 hour ago' +"%-d") < 10)); then date -d '1 hour ago' +"%b  %-d %H:"; else date -d '1 hour ago' +"%b %d %H:"; fi)" | grep -iv "pam_unix\|wp-toolkit\|127.0.0.1\|Bad protocol version\|sudo:" | grep "Invalid user\|Failed password for invalid user\|Did not receive identification string from\|Connection closed by" | awk '{for(i=1;i<=NF;i++) {if($i=="port") {if($6!="Did") printf "%-15s %-17s %-22s %-14s %-50s\n","DATE: "$1" "$2,"TIME: "$3,"IP: "$(i-1),"PORT: "$(i+1),"TYPE: "$6" "$7; else printf "%-15s %-17s %-22s %-14s %-50s\n","DATE: "$1" "$2,"TIME: "$3,"IP: "$(i-1),"PORT: "$(i+1),"TYPE: "$9" "$10}}}' >>$temp/sshlog_$time.txt
}

function check_log() {
	if [ -r $temp/sshlog_$time.txt ] && [ -s $temp/sshlog_$time.txt ]; then
		ips=($(cat $temp/sshlog_$time.txt | awk '{print $7}' | sort | uniq | grep -v "127.0.0.1"))
		count=${#ips[@]}

		for ((i = 0; i < count; i++)); do
			data=$(cat $temp/sshlog_$time.txt | grep ${ips[i]})
			
			whois=$(curl https://ipapi.co/${ips[i]}/country/)
			error=$(echo "$whois" | grep "error")

			if [[ ! -z $error ]]; then
				iplookup=$(curl ipinfo.io/${ips[i]})
				whois=$(echo "$iplookup" | grep "country" | awk '{print $2}' | sed 's/"//g;s/,//')
			fi

			while IFS= read -r line; do
				printf "%-120s %-10s\n" "$line" "ID: $whois" >>$temp/failed-ssh_$time.txt
			done <<<"$data"
		done
	fi
}

function sort_log() {
	if [ -r $temp/failed-ssh_$time.txt ] && [ -s $temp/failed-ssh_$time.txt ]; then
		sortlog=$(cat $temp/failed-ssh_$time.txt | grep -v "LK" | sort -k5)

		if [[ ! -z $sortlog ]]; then
			echo "$sortlog" >>$svrlogs/cphulk/iplist/failed-ssh_$time.txt
		fi
	fi
}

function blacklist() {
	if [ -r $svrlogs/cphulk/iplist/failed-ssh_$time.txt ] && [ -s $svrlogs/cphulk/iplist/failed-ssh_$time.txt ]; then
		sh /home/$cpuser/scripts/cphulk/ipblacklist.sh failed-ssh
	fi
}

function summary() {
	sshlog=($(ls -lat $temp | grep -i "sshlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
	sllen=${#sshlog[@]}

	if [ $sllen -ne 0 ]; then
		count=$(wc -l $sshlog | awk '{print $1}')

		uniqipcount=$(cat $sshlog | awk '{print $7}' | sort | uniq | wc -l)

		failedssh=($(ls -lat $temp | grep -i "failed-ssh" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
		fslen=${#failedssh[@]}

		if [ $fslen -ne 0 ]; then
			newcount=$(wc -l $failedssh | awk '{print $1}')

			newuniqip=$(cat $failedssh | awk '{print $7}' | sort | uniq | wc -l)

			blacklist=($(ls -lat $svrlogs/cphulk/block | grep -i "sship-blacklisted" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/block/"$9}'))
			blen=${#blacklist[@]}

			if [ $blen -ne 0 ]; then
				login=($(ls -lat $svrlogs/cphulk/iplist | grep -i "failed-ssh" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/iplist/"$9}'))

				listed=$(wc -l $login | awk '{print $1}')

				uniqlisted=$(cat $blacklist | grep "Total:" | awk '{print $2}')

				ip_data
			fi
		fi
	fi
}

function ip_data() {
	echo "SSH login failure count: $count" >>$svrlogs/ipmonitor/sshlog_$time.txt

	echo "SSH login failure unique IP count: $uniqipcount" >>$svrlogs/ipmonitor/sshlog_$time.txt

	echo "" >>$svrlogs/ipmonitor/sshlog_$time.txt

	echo "SSH new login failure count: $newcount" >>$svrlogs/ipmonitor/sshlog_$time.txt

	echo "SSH new login failure unique IP count: $newuniqip" >>$svrlogs/ipmonitor/sshlog_$time.txt

	echo "" >>$svrlogs/ipmonitor/sshlog_$time.txt

	echo "SSH login failure count (excluding LK): $listed" >>$svrlogs/ipmonitor/sshlog_$time.txt

	echo "Blacklisted unique IP count: $uniqlisted" >>$svrlogs/ipmonitor/sshlog_$time.txt

	echo "" >>$svrlogs/ipmonitor/sshlog_$time.txt

	cat $login >>$svrlogs/ipmonitor/sshlog_$time.txt
}

ssh_log

check_log

sort_log

blacklist

summary
