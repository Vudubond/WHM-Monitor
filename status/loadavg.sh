#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function load_avg() {
	loadavg=$(uptime | awk '{print $1,$(NF-2),$(NF-1),$NF}' | sed 's/,//g')

	avgt=$(echo "$loadavg" | awk '{print $1}')
	onem=$(echo "$loadavg" | awk '{print $2}')
	fivm=$(echo "$loadavg" | awk '{print $3}')
	fifm=$(echo "$loadavg" | awk '{print $4}')
	onecheck=$(echo "$loadavg" | awk '{print $2*100}')

	if [[ $onecheck -gt 1000 ]]; then
		header

		printf "%-13s %-11s %-9s %-9s %-9s\n" "$date" "$avgt" "$onem" "$fivm" "$fifm" >>$svrlogs/status/loadavg_$date.txt

		prev=$(cat $svrlogs/status/loadavg_$date.txt | tail -2 | head -1 | awk '{print $2}' | awk -F':' '{print $1":"$2}')
		mago=$(date -d '1 minute ago' +"%H:%M")

		if [[ $prev == $mago ]]; then
			prvcheck=$(cat $svrlogs/status/loadavg_$date.txt | tail -2 | head -1 | awk '{print $3*100}')

			if [[ $onecheck -gt $prvcheck && $onecheck -gt 1500 ]]; then
				content=$(echo "HLA: $loadavg")

				send_sms

				dom_log
			fi
		fi
	fi
}

function header() {
	if [ ! -f $svrlogs/status/loadavg_$date.txt ]; then
		printf "%-13s %-11s %-9s %-9s %-9s\n" "DATE" "TIME" "1 MIN" "5 MIN" "15 MIN" >>$svrlogs/status/loadavg_$date.txt
	fi
}

function dom_log() {
	egrep "wp-login.php|xmlrpc.php" /var/log/apache2/domlogs/*/* | awk '{print $1,$4,$6}' | awk -F'[/ :]' '{printf "%-20s %-22s %-13s %-25s %-50s\n","DATE: "$11"-"$10"-"$9,"IP: "$8,"TYPE: "$15,"USER: "$6,"LOG: "$7}' | sed 's/[][]//;s/"//g' | sort | uniq -c | sort -nr | grep -ie "$(date +"%Y-%b-%d")" | awk '{if($1>=1000) print}' >>$temp/domlog_$time.txt

	ips=$(cat $temp/domlog_$time.txt | awk '{print $5}' | sort | uniq)

	if [[ ! -z $ips ]]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			ip=$(echo "$line" | awk '{print $5}')

			blocked=$(csf -g $ip | grep "csf.deny:")

			if [[ -z $blocked ]]; then
				csf -d $ip domlog

				logline=$(echo "$line" | awk -F'LOG:' '{print $1}')

				printf "%-80s %-20s\n" "$logline" "CSF: Blocked" >>$svrlogs/status/domipblock_$time.txt
			fi

		done <"$temp/domlog_$time.txt"

		send_mail
	fi
}

function send_sms() {
	message=$(echo "$hostname: $content")

	url=$(echo "$link?me5352ss75age=$message&f3f34h47y53s2=4399648395395244")

	wget "${url}"
}

function send_mail() {
	domip=$(cat $svrlogs/status/domipblock_$time.txt)
	dcount=$(echo "$domip" | wc -l)

	echo "SUBJECT: High Load Average - $(hostname) - $(date +"%F")" >>$svrlogs/mail/hlamail_$time.txt
	echo "FROM: monitor@$cpuser.com" >>$svrlogs/mail/hlamail_$time.txt
	echo "" >>$svrlogs/mail/hlamail_$time.txt
	printf "%-10s %20s\n" "Date:" "$(date +"%F")" >>$svrlogs/mail/hlamail_$time.txt
	printf "%-10s %20s\n" "Time:" "$(date +"%T")" >>$svrlogs/mail/hlamail_$time.txt
	printf "%-10s %20s\n" "One:" "$onem" >>$svrlogs/mail/hlamail_$time.txt
	printf "%-10s %20s\n" "Five:" "$fivm" >>$svrlogs/mail/hlamail_$time.txt
	printf "%-10s %20s\n" "Fifteen:" "$fifm" >>$svrlogs/mail/hlamail_$time.txt

	if [[ ! -z $domip ]]; then
		echo "" >>$svrlogs/mail/hlamail_$time.txt
		echo "CSF Blocked:" >>$svrlogs/mail/hlamail_$time.txt
		echo "Total: $dcount" >>$svrlogs/mail/hlamail_$time.txt
		echo "$domip" >>$svrlogs/mail/hlamail_$time.txt
	fi

	sendmail "$emailmo,$emailmg" <$svrlogs/mail/hlamail_$time.txt
}

load_avg
