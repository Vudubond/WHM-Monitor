#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function send_mail() {
	errorlogwatch=($(ls -lat $svrlogs/errorlogwatch | grep -i "errorlogwatch" | grep -i "$(date +"%F")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))
	elwlen=${#errorlogwatch[@]}

	if [ $elwlen -ne 0 ]; then
		echo "SUBJECT: Error Log Watch - $(hostname) - $(date +"%F")" >>$svrlogs/mail/elwmail_$time.txt
		echo "FROM: errorlogwatch@$cpuser.com" >>$svrlogs/mail/elwmail_$time.txt
		echo "" >>$svrlogs/mail/elwmail_$time.txt
		echo "$(cat $errorlogwatch)" >>$svrlogs/mail/elwmail_$time.txt
		sendmail "$emaillg,$emailmo" <$svrlogs/mail/elwmail_$time.txt
	else
		echo "$(date +"%F %T") No content to send" >>$svrlogs/logs/errorlogwatchlogs_$logtime.txt
	fi
}

send_mail
