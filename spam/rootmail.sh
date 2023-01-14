#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function root_mail() {
	cat /var/log/exim_mainlog | grep -ie "$(date -d '1 hour ago' +"%Y-%m-%d %H:")" | grep "P=local" | grep -v "root@$svrdomain" | grep -v "<>" | awk '{if ($5!=$NF) printf "%-19s %-55s %-55s\n","DATE: "$1,"SENDER: "$5,"RECIEVER: "$NF}' | grep "@$svrdomain" | sort | uniq -c | sort -k5 >>$temp/rootmail_$time.txt
}

function mail_check() {
	if [ -r $temp/rootmail_$time.txt ] && [ -s $temp/rootmail_$time.txt ]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			sender=$(echo "$line" | awk '{print $5}')
			username=$(echo "$sender" | awk -F'@' '{print $1}')
			receiver=$(echo "$line" | awk '{print $NF}')

			suspended=$(whmapi1 accountsummary user=$username | grep -i "outgoing_mail_suspended:" | awk '{print $2}')

			if [ "$suspended" -eq 0 ]; then
				domains=($(uapi --user=$username Email list_mail_domains | grep "domain:" | awk '{print $2}'))
				dcount=${#domains[@]}

				if [[ $receiver == *[@]* ]]; then
					rdomain=$(echo "$receiver" | awk -F'@' '{print $2}')

					for ((i = 0; i < dcount; i++)); do
						if [[ "$rdomain" == "${domains[i]}" ]]; then
							exclude+=("$receiver")
						fi
					done

				elif [[ "$receiver" == "$username" ]]; then
					exclude+=("$receiver")
				fi
			else
				exclude+=("$sender")
			fi

		done <"$temp/rootmail_$time.txt"

		ecount=${#exclude[@]}

		value=$(cat $temp/rootmail_$time.txt)

		if [ $ecount -ne 0 ]; then
			for ((j = 0; j < ecount; j++)); do
				value=$(echo "$value" | grep -v ${exclude[j]})
			done

			echo "$value" >>$temp/localmail_$time.txt
		else
			echo "$value" >>$temp/localmail_$time.txt
		fi
	fi
}

function mail_count() {
	if [ -r $temp/localmail_$time.txt ] && [ -s $temp/localmail_$time.txt ]; then
		senders=($(cat $temp/localmail_$time.txt | awk '{print $5}' | sort | uniq))
		count=${#senders[@]}

		for ((i = 0; i < count; i++)); do
			sender=${senders[i]}
			username=$(echo "$sender" | awk -F'@' '{print $1}')
			data=$(cat $temp/localmail_$time.txt | grep $sender)
			lcount=$(echo "$data" | wc -l)
			num=0

			if [ $lcount -gt 1 ]; then
				while IFS= read -r line; do
					digit=$(echo "$line" | awk '{print $1}')

					num=$((num + $digit))

				done <<<"$data"

				if [ $num -gt 1 ]; then
					sum=$num

					header

					printf "%-20s %-15s %-55s %-10s\n" "$time" "$username" "$sender" "$sum" >>$svrlogs/spam/hourlycheck/rootmail_$date.txt

					if [ $sum -gt 10 ]; then
						check_log
					fi
				fi
			else
				digit=$(echo "$data" | awk '{print $1}')

				if [ $digit -gt 1 ]; then
					sum=$digit

					header

					printf "%-20s %-15s %-55s %-10s\n" "$time" "$username" "$sender" "$sum" >>$svrlogs/spam/hourlycheck/rootmail_$date.txt

					if [ $sum -gt 10 ]; then
						check_log
					fi
				fi
			fi
		done
	fi
}

function header() {
	if [ ! -f $svrlogs/spam/hourlycheck/rootmail_$date.txt ]; then
		printf "%-20s %-15s %-55s %-10s\n" "DATE_TIME" "USERNAME" "EMAIL" "COUNT" >>$svrlogs/spam/hourlycheck/rootmail_$date.txt
	fi
}

function check_log() {
	category="rootmail"
	recs=$(cat $svrlogs/spam/hourlycheck/rootmail_$date.txt | grep "$sender")
	rlines=$(echo "$recs" | wc -l)

	if [ $rlines -ge 2 ]; then
		prev=$(echo "$recs" | tail -2 | head -1 | awk '{print $1}' | awk -F'[_:]' '{print $2":"}')
		hago=$(date -d '1 hour ago' +"%H:")

		if [[ $prev == $hago ]]; then
			pvuser=$(echo "$recs" | tail -2 | head -1 | awk '{print $2}')

			if [[ $pvuser == $username ]]; then
				send_mail
			fi
		fi
	fi
}

function send_mail() {
	mtime=$(date +"%F_%T")

	echo "SUBJECT: Hourly Spam Check - $hostname - $(date +"%F %T")" >>$svrlogs/mail/spammail_$mtime.txt
	echo "FROM: monitor@$cpuser.com" >>$svrlogs/mail/spammail_$mtime.txt
	echo "" >>$svrlogs/mail/spammail_$mtime.txt
	printf "%-10s %20s\n" "Date:" "$(date +"%F")" >>$svrlogs/mail/spammail_$mtime.txt
	printf "%-10s %20s\n" "Time:" "$(date +"%T")" >>$svrlogs/mail/spammail_$mtime.txt
	printf "%-10s %20s\n" "Category:" "$category" >>$svrlogs/mail/spammail_$mtime.txt
	printf "%-10s %20s\n" "Username:" "$username" >>$svrlogs/mail/spammail_$mtime.txt
	printf "%-10s %20s\n" "Email:" "$sender" >>$svrlogs/mail/spammail_$mtime.txt
	printf "%-10s %20s\n" "Count:" "$sum" >>$svrlogs/mail/spammail_$mtime.txt
	sendmail "$emailmo,$emailmg" <$svrlogs/mail/spammail_$mtime.txt
}

root_mail

mail_check

mail_count
