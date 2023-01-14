#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function send_mail() {
	serverwatch=($(ls -lat $svrlogs/serverwatch | grep -i "serverwatch" | grep -i "$(date +"%F")" | head -1 | awk '{print "$svrlogs/serverwatch/"$9}'))
	swlen=${#serverwatch[@]}

	if [ $swlen -ne 0 ]; then
		echo "SUBJECT: Server Watch - $(hostname) - $(date +"%F")" >>$svrlogs/mail/swmail_$time.txt
		echo "FROM: serverwatch@$cpuser.com" >>$svrlogs/mail/swmail_$time.txt
		echo "" >>$svrlogs/mail/swmail_$time.txt
		echo "$(cat $serverwatch)" >>$svrlogs/mail/swmail_$time.txt
		sendmail "$emaillg,$emailmo" <$svrlogs/mail/swmail_$time.txt
	else
		echo "$(date +"%F %T") No content to send" >>$svrlogs/logs/serverwatchlogs_$logtime.txt
	fi
}

send_mail
