#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function mail_log() {
	cat /var/log/maillog | grep -ie "$(if (($(date -d '1 hour ago' +"%-d") < 10)); then date -d '1 hour ago' +"%b  %-d %H:"; else date -d '1 hour ago' +"%b %d %H:"; fi)" | grep -ie "dovecot:" | grep -ie "imap-login:\|pop3-login:" | grep -ie "auth failed" | grep -iv "Inactivity\|user=<>" | awk '{$3="";$4="";print}' | awk -F',\|:\|[()]' '{for(i=1;i<=NF;i++) {for(j=1;j<=NF;j++) {if($i~/user=/ && $j~/rip=/) {printf "%-14s %-20s %-27s %-50s\n","DATE: "$1,"TYPE: "$2,"IP: "$j,"USER: "$i}}}}' | sed 's/dovecot//;s/user//;s/rip//;s/=//g;s/,//g;s/<//;s/>//' | sort | uniq -c | sort -k9 >>$temp/maillog_$time.txt
}

function check_log() {
	if [ -r $temp/maillog_$time.txt ] && [ -s $temp/maillog_$time.txt ]; then
		ips=($(cat $temp/maillog_$time.txt | awk '{print $8}' | sort | uniq | grep -v "127.0.0.1"))
		count=${#ips[@]}

		for ((i = 0; i < count; i++)); do
			search=$(whmapi1 read_cphulk_records list_name='black' | grep ${ips[i]})

			if [[ -z $search ]]; then
				data=$(cat $temp/maillog_$time.txt | grep ${ips[i]})
				
				whois=$(curl https://ipapi.co/${ips[i]}/country/)
				error=$(echo "$whois" | grep "error")

				if [[ ! -z $error ]]; then
					iplookup=$(curl ipinfo.io/${ips[i]})
					whois=$(echo "$iplookup" | grep "country" | awk '{print $2}' | sed 's/"//g;s/,//')
				fi

				while IFS= read -r line; do
					printf "%-120s %-10s\n" "$line" "ID: $whois" >>$temp/failed-mail_$time.txt
				done <<<"$data"
			fi
		done
	fi
}

function mail_check() {
	if [ -r $temp/failed-mail_$time.txt ] && [ -s $temp/failed-mail_$time.txt ]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			email=$(echo "$line" | awk '{print $10}')

			if [[ $email == *[@]* ]]; then
				domain=$(echo "$email" | awk -F'@' '{print $2}')
				username=$(whmapi1 getdomainowner domain=$domain | grep -i "user:" | awk '{print $2}')

				if [[ "$username" != "~" ]]; then
					status=$(uapi --user=$username Mailboxes get_mailbox_status_list account=$email | grep -i "status:" | awk '{print $2}')

					if [ "$status" -eq 0 ]; then
						echo "$line" >>$temp/fake-mail_$time.txt
					fi
				else
					echo "$line" >>$temp/fake-mail_$time.txt
				fi
			else
				echo "$line" >>$temp/fake-mail_$time.txt
			fi

		done <"$temp/failed-mail_$time.txt"
	fi
}

function sort_log() {
	if [ -r $temp/fake-mail_$time.txt ] && [ -s $temp/fake-mail_$time.txt ]; then
		sortlog=$(cat $temp/fake-mail_$time.txt | grep -v "LK" | sort -k10)

		if [[ ! -z $sortlog ]]; then
			echo "$sortlog" >>$svrlogs/cphulk/iplist/fake-mail_$time.txt
		fi
	fi
}

function blacklist() {
	if [ -r $svrlogs/cphulk/iplist/fake-mail_$time.txt ] && [ -s $svrlogs/cphulk/iplist/fake-mail_$time.txt ]; then
		sh /home/$cpuser/scripts/cphulk/ipblacklist.sh fake-mail
	fi
}

function summary() {
	maillog=($(ls -lat $temp | grep -i "maillog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
	mllen=${#maillog[@]}

	if [ $mllen -ne 0 ]; then
		count=$(wc -l $maillog | awk '{print $1}')

		uniqipcount=$(cat $maillog | awk '{print $8}' | sort | uniq | wc -l)

		failedmail=($(ls -lat $temp | grep -i "failed-mail" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$temp/"$9}'))
		fmlen=${#failedmail[@]}

		if [ $fmlen -ne 0 ]; then
			newcount=$(wc -l $failedmail | awk '{print $1}')

			newuniqip=$(cat $failedmail | awk '{print $8}' | sort | uniq | wc -l)

			blacklist=($(ls -lat $svrlogs/cphulk/block | grep -i "mailip-blacklisted" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/block/"$9}'))
			blen=${#blacklist[@]}

			if [ $blen -ne 0 ]; then
				login=($(ls -lat $svrlogs/cphulk/iplist | grep -i "fake-mail" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/cphulk/iplist/"$9}'))

				listed=$(wc -l $login | awk '{print $1}')

				uniqlisted=$(cat $blacklist | grep "Total:" | awk '{print $2}')

				ip_data
			fi
		fi
	fi
}

function ip_data() {
	echo "IMAP/POP3 login failure count: $count" >>$svrlogs/ipmonitor/maillog_$time.txt

	echo "IMAP/POP3 login failure unique IP count: $uniqipcount" >>$svrlogs/ipmonitor/maillog_$time.txt

	echo "" >>$svrlogs/ipmonitor/maillog_$time.txt

	echo "IMAP/POP3 new login failure count: $newcount" >>$svrlogs/ipmonitor/maillog_$time.txt

	echo "IMAP/POP3 new login failure unique IP count: $newuniqip" >>$svrlogs/ipmonitor/maillog_$time.txt

	echo "" >>$svrlogs/ipmonitor/maillog_$time.txt

	echo "IMAP/POP3 fake login failure count: $listed" >>$svrlogs/ipmonitor/maillog_$time.txt

	echo "Blacklisted unique IP count: $uniqlisted" >>$svrlogs/ipmonitor/maillog_$time.txt

	echo "" >>$svrlogs/ipmonitor/maillog_$time.txt

	cat $login >>$svrlogs/ipmonitor/maillog_$time.txt
}

mail_log

check_log

mail_check

sort_log

blacklist

summary
