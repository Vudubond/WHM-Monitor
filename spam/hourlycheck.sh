#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function exim_mainlog() {
	cat /var/log/exim_mainlog | grep -ie "$(date -d '1 hour ago' +"%F %H:")" | grep -i "SMTP connection outbound" | awk '{print "DATE: "$1,"\tDOMAIN: "$9}' | sort | uniq -c | sort -nr >>$temp/smtpoutbound_$time.txt

	grep -i "cwd=/home" /var/log/exim_mainlog | grep -ie "$(date -d '1 hour ago' +"%F %H:")" | awk '{print "DATE: "$1,"\tUSER: "$3}' | sed 's/cwd=\/home\///' | sort | uniq -c | sort -nr >>$temp/cwdhome_$time.txt

	grep -ie "$(date -d '1 hour ago' +"%F %H:")" /var/log/exim_mainlog | egrep -o 'dovecot_plain[^ ]+' | sed 's/dovecot_plain://' | grep -iv "__cpanel" | sort | uniq -c | sort -nr >>$temp/dovecotplain_$time.txt

	grep -ie "$(date -d '1 hour ago' +"%F %H:")" /var/log/exim_mainlog | egrep -o 'dovecot_login[^ ]+' | sed 's/dovecot_login://' | sort | uniq -c | sort -nr >>$temp/dovecotlogin_$time.txt
}

function smtp_outbound() {
	if [ -r $temp/smtpoutbound_$time.txt ] && [ -s $temp/smtpoutbound_$time.txt ]; then
		category="smtpoutbound"

		while IFS= read -r line || [[ -n "$line" ]]; do
			mailcount=$(echo "$line" | awk '{print $1}')

			if [ "$mailcount" -gt 90 ]; then
				domain=$(echo "$line" | awk '{print $NF}')
				username=$(whmapi1 getdomainowner domain=$domain | grep -i "user:" | awk '{print $2}')
				count=($(whmapi1 emailtrack_stats user=$username startdate=$(date -d '1 hours ago' +"%s") enddate=$(date -d 'now' +"%s") | grep -ie "DEFERCOUNT\|FAILCOUNT"))
				difer=$(echo -e "${count[1]}")
				fail=$(echo -e "${count[5]}")
				status=$(whmapi1 accountsummary user=$username | grep -i "outgoing_mail_suspended:" | awk '{print $2}')

				if [ "$status" -eq 0 ]; then
					header

					printf "%-20s %-15s %-10s %-10s %-15s %-50s\n" "$time" "$username" "$difer" "$fail" "Active" "$domain" >>$svrlogs/spam/hourlycheck/smtpoutbound_$date.txt

					notify
				else
					header

					printf "%-20s %-15s %-10s %-10s %-15s %-50s\n" "$time" "$username" "$difer" "$fail" "Suspended" "$domain" >>$svrlogs/spam/hourlycheck/smtpoutbound_$date.txt
				fi
			fi
		done <"$temp/smtpoutbound_$time.txt"
	fi
}

function cwd_home() {
	if [ -r $temp/cwdhome_$time.txt ] && [ -s $temp/cwdhome_$time.txt ]; then
		category="cwdhome"

		while IFS= read -r line || [[ -n "$line" ]]; do
			mailcount=$(echo "$line" | awk '{print $1}')

			if [ "$mailcount" -gt 90 ]; then
				username=$(echo "$line" | awk '{print $NF}' | awk -F/ '{print $1}')
				count=($(whmapi1 emailtrack_stats user=$username startdate=$(date -d '1 hours ago' +"%s") enddate=$(date -d 'now' +"%s") | grep -ie "DEFERCOUNT\|FAILCOUNT"))
				difer=$(echo -e "${count[1]}")
				fail=$(echo -e "${count[5]}")
				status=$(whmapi1 accountsummary user=$username | grep -i "outgoing_mail_suspended:" | awk '{print $2}')

				if [ "$status" -eq 0 ]; then
					header

					printf "%-20s %-15s %-10s %-10s %-15s\n" "$time" "$username" "$difer" "$fail" "Active" >>$svrlogs/spam/hourlycheck/cwdhome_$date.txt

					notify
				else
					header

					printf "%-20s %-15s %-10s %-10s %-15s\n" "$time" "$username" "$difer" "$fail" "Suspended" >>$svrlogs/spam/hourlycheck/cwdhome_$date.txt
				fi
			fi
		done <"$temp/cwdhome_$time.txt"
	fi
}

function dovecot_plain() {
	if [ -r $temp/dovecotplain_$time.txt ] && [ -s $temp/dovecotplain_$time.txt ]; then
		category="dovecotplain"

		while IFS= read -r line || [[ -n "$line" ]]; do
			mailcount=$(echo "$line" | awk '{print $1}')

			if [ "$mailcount" -gt 90 ]; then
				email=$(echo "$line" | awk '{print $NF}')
				domain=$(echo "$email" | awk -F@ '{print $NF}')
				username=$(whmapi1 getdomainowner domain=$domain | grep -i "user:" | awk '{print $2}')
				count=($(whmapi1 emailtrack_stats user=$username startdate=$(date -d '1 hours ago' +"%s") enddate=$(date -d 'now' +"%s") | grep -ie "DEFERCOUNT\|FAILCOUNT"))
				difer=$(echo -e "${count[1]}")
				fail=$(echo -e "${count[5]}")
				status=$(whmapi1 accountsummary user=$username | grep -i "outgoing_mail_suspended:" | awk '{print $2}')

				if [ "$status" -eq 0 ]; then
					header

					printf "%-20s %-15s %-10s %-10s %-15s %-70s\n" "$time" "$username" "$difer" "$fail" "Active" "$email" >>$svrlogs/spam/hourlycheck/dovecotplain_$date.txt

					notify
				else
					header

					printf "%-20s %-15s %-10s %-10s %-15s %-70s\n" "$time" "$username" "$difer" "$fail" "Suspended" "$email" >>$svrlogs/spam/hourlycheck/dovecotplain_$date.txt
				fi
			fi
		done <"$temp/dovecotplain_$time.txt"
	fi
}

function dovecot_login() {
	if [ -r $temp/dovecotlogin_$time.txt ] && [ -s $temp/dovecotlogin_$time.txt ]; then
		category="dovecotlogin"

		while IFS= read -r line || [[ -n "$line" ]]; do
			mailcount=$(echo "$line" | awk '{print $1}')

			if [ "$mailcount" -gt 90 ]; then
				email=$(echo "$line" | awk '{print $NF}')
				domain=$(echo "$email" | awk -F@ '{print $NF}')
				username=$(whmapi1 getdomainowner domain=$domain | grep -i "user:" | awk '{print $2}')
				count=($(whmapi1 emailtrack_stats user=$username startdate=$(date -d '1 hours ago' +"%s") enddate=$(date -d 'now' +"%s") | grep -ie "DEFERCOUNT\|FAILCOUNT"))
				difer=$(echo -e "${count[1]}")
				fail=$(echo -e "${count[5]}")
				status=$(whmapi1 accountsummary user=$username | grep -i "outgoing_mail_suspended:" | awk '{print $2}')

				if [ "$status" -eq 0 ]; then
					header

					printf "%-20s %-15s %-10s %-10s %-15s %-70s\n" "$time" "$username" "$difer" "$fail" "Active" "$email" >>$svrlogs/spam/hourlycheck/dovecotlogin_$date.txt

					notify
				else
					header

					printf "%-20s %-15s %-10s %-10s %-15s %-70s\n" "$time" "$username" "$difer" "$fail" "Suspended" "$email" >>$svrlogs/spam/hourlycheck/dovecotlogin_$date.txt
				fi
			fi
		done <"$temp/dovecotlogin_$time.txt"
	fi
}

function root_mail() {
	sh /home/$cpuser/scripts/spam/rootmail.sh
}

function mail_queue() {
	sh /home/$cpuser/scripts/spam/mailqueue.sh
}

function header() {
	if [[ "$category" == "smtpoutbound" ]]; then
		if [ ! -f $svrlogs/spam/hourlycheck/smtpoutbound_$date.txt ]; then
			printf "%-20s %-15s %-10s %-10s %-15s %-50s\n" "DATE_TIME" "USER" "DIFER" "FAIL" "STATUS" "DOMAIN" >>$svrlogs/spam/hourlycheck/smtpoutbound_$date.txt
		fi
	elif [[ "$category" == "cwdhome" ]]; then
		if [ ! -f $svrlogs/spam/hourlycheck/cwdhome_$date.txt ]; then
			printf "%-20s %-15s %-10s %-10s %-15s\n" "DATE_TIME" "USER" "DIFER" "FAIL" "STATUS" >>$svrlogs/spam/hourlycheck/cwdhome_$date.txt
		fi
	elif [[ "$category" == "dovecotplain" ]]; then
		if [ ! -f $svrlogs/spam/hourlycheck/dovecotplain_$date.txt ]; then
			printf "%-20s %-15s %-10s %-10s %-15s %-70s\n" "DATE_TIME" "USER" "DIFER" "FAIL" "STATUS" "EMAIL" >>$svrlogs/spam/hourlycheck/dovecotplain_$date.txt
		fi
	elif [[ "$category" == "dovecotlogin" ]]; then
		if [ ! -f $svrlogs/spam/hourlycheck/dovecotlogin_$date.txt ]; then
			printf "%-20s %-15s %-10s %-10s %-15s %-70s\n" "DATE_TIME" "USER" "DIFER" "FAIL" "STATUS" "EMAIL" >>$svrlogs/spam/hourlycheck/dovecotlogin_$date.txt
		fi
	fi
}

function notify() {
	if [ "$fail" -gt 10 ]; then
		if [[ "$category" == "smtpoutbound" ]]; then
			check_log
		else
			suspend_user

			content=$(echo "$username: last hour failed - $fail *$category* $action")

			send_sms

			send_mail
		fi
	fi
}

function check_log() {
	recs=$(cat $svrlogs/spam/hourlycheck/smtpoutbound_$date.txt | grep "$username" | grep "$domain")
	rlines=$(echo "$recs" | wc -l)

	if [ $rlines -ge 2 ]; then
		prev=$(echo "$recs" | tail -2 | head -1 | awk '{print $1}' | awk -F'[_:]' '{print $2":"}')
		hago=$(date -d '1 hour ago' +"%H:")

		if [[ $prev == $hago ]]; then
			pvuser=$(echo "$recs" | tail -2 | head -1 | awk '{print $2}')

			if [[ $pvuser == $username ]]; then
				suspend_user

				content=$(echo "$username: last hour failed - $fail *$category* $action")

				send_sms

				send_mail
			else
				content=$(echo "$username: last hour failed - $fail *$category*")
			fi
		fi
	fi
}

function suspend_user() {
	result=$(whmapi1 suspend_outgoing_email user=$username | grep "result:" | awk '{print $NF}')

	if [ $result -ne 0 ]; then
		action="SUSPENDED"
	else
		action="NOT SUSPENDED"
	fi
}

function send_sms() {
	message=$(echo "$hostname: $content")

	url=$(echo "$link?me5352ss75age=$message&f3f34h47y53s2=4399648395395244")

	wget "${url}"
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
	printf "%-10s %20s\n" "Failed:" "$fail" >>$svrlogs/mail/spammail_$mtime.txt
	printf "%-10s %20s\n" "Status:" "$action" >>$svrlogs/mail/spammail_$mtime.txt
	sendmail "$emailmo,$emailmg" <$svrlogs/mail/spammail_$mtime.txt
}

exim_mainlog

smtp_outbound

cwd_home

dovecot_plain

dovecot_login

root_mail

mail_queue
