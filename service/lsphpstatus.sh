#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function httpd_status() {
	status=$(systemctl status httpd | grep "lsphp" | grep -v "/opt/\|/dev/null\|wp\|index" | awk '{print $NF}' | awk -F':' '{print $1}' | sed 's/[][]//g' | sort | uniq -c)

	process=$(echo "$status" | awk '{print $2}')
	count=$(echo "$status" | awk '{print $1}')

	echo "$(date +"%F %T") $status" >>$svrlogs/service/lsphpstatus_$date.txt

	if [[ $process != "lsphp" || $count -lt 5 ]]; then
		prev=$(cat $svrlogs/service/lsphpissue_$logtime.txt | tail -1 | awk '{print $2}' | awk -F':' '{print $1":"$2}')
		mago=$(date -d '1 minute ago' +"%H:%M")

		if [[ $process != "lsphp" ]]; then
			echo "$(date +"%F %T") lsphp not working" >>$svrlogs/service/lsphpissue_$logtime.txt

			time_count

			if [[ $prev == $mago ]]; then
				send_data

				service_restart
			fi

		elif [ $count -lt 5 ]; then
			echo "$(date +"%F %T") lsphp low count: $count" >>$svrlogs/service/lsphpissue_$logtime.txt

			time_count

			if [[ $prev == $mago ]]; then
				bef=$(cat $svrlogs/service/lsphpissue_$logtime.txt | tail -2 | head -1 | awk '{print $4}')

				if [[ $bef == "low" ]]; then
					bcount=$(cat $svrlogs/service/lsphpissue_$logtime.txt | tail -2 | head -1 | awk '{print $NF}')

					if [ $count -le $bcount ]; then
						send_data

						service_restart
					fi
				fi
			fi

		fi
	else
		timecount=($(ls -lat $svrlogs/service | grep -i "timecount" | awk '{print "$svrlogs/service/"$9}'))

		tclen=${#timecount[@]}

		if [ $tclen -ne 0 ]; then
			downtime=$(cat $svrlogs/service/timecount.txt)

			echo "$(date +"%F %T") httpd downtime: $downtime" >>$svrlogs/service/downtime_$date.txt

			status=$(echo "lsphp working")
			service=$(echo "$downtime mins downtime")

			content=$(echo "HTTPD downtime: $downtime mins")

			send_sms

			send_mail

			rm -f $svrlogs/service/timecount.txt
		fi
	fi
}

function service_restart() {

	aplisten=$(netstat -ntlp | grep "httpd" | awk '{print $4}' | awk -F':' '{print $NF}' | sort | uniq | sort -n | head -1)

	lslisten=$(netstat -ntlp | grep "litespeed" | awk '{print $4}' | awk -F':' '{print $NF}' | sort | uniq | sort -n | head -1)

	if [[ $lslisten -ne 80 || -z $lslisten ]]; then
		/scripts/restartsrv_httpd

		echo "$(date +"%F %T") httpd service restarted" >>$svrlogs/service/httpdstatus_$logtime.txt

	elif [[ -z $aplisten ]]; then
		/usr/local/lsws/bin/lswsctrl restart

		echo "$(date +"%F %T") lshttpd service restarted" >>$svrlogs/service/httpdstatus_$logtime.txt
	fi
}

function time_count() {
	timecount=($(ls -lat $svrlogs/service | grep -i "timecount" | awk '{print "$svrlogs/service/"$9}'))

	tclen=${#timecount[@]}

	if [ $tclen -ne 0 ]; then
		timer=$(cat $svrlogs/service/timecount.txt)

		rm -f $svrlogs/service/timecount.txt

		timer=$((timer + 1))

		echo "$timer" >>$svrlogs/service/timecount.txt
	else
		timer=1

		echo "$timer" >>$svrlogs/service/timecount.txt
	fi
}

function send_data() {
	tmin=$(cat $svrlogs/service/timecount.txt)

	if [ $tmin -eq 2 ]; then
		status=$(echo "lsphp not working")

		service=$(echo "HTTPD service restarted")

		content=$(echo "$service")

		send_sms

		send_mail
	fi
}

function send_sms() {
	message=$(echo "$hostname: $content")

	url=$(echo "$link?me5352ss75age=$message&f3f34h47y53s2=4399648395395244")

	wget "${url}"
}

function send_mail() {
	echo "SUBJECT: LK - HTTPD Service Status - $(hostname) - $(date +"%F")" >>$svrlogs/mail/svcmail_$time.txt
	echo "FROM: service@$cpuser.com" >>$svrlogs/mail/svcmail_$time.txt
	echo "" >>$svrlogs/mail/svcmail_$time.txt
	printf "%-10s %20s\n" "Date:" "$(date +"%F")" >>$svrlogs/mail/svcmail_$time.txt
	printf "%-10s %20s\n" "Time:" "$(date +"%T")" >>$svrlogs/mail/svcmail_$time.txt
	printf "%-10s %20s\n" "Status:" "$status" >>$svrlogs/mail/svcmail_$time.txt
	printf "%-10s %20s\n" "Service:" "$service" >>$svrlogs/mail/svcmail_$time.txt
	sendmail "$emailmo,$emailmg" <$svrlogs/mail/svcmail_$time.txt
}

httpd_status
