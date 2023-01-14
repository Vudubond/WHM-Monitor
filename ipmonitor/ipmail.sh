#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function send_mail() {
	ipmonitor=($(ls -lat $svrlogs/ipmonitor | grep -i "ipmonitor" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/ipmonitor/"$9}'))
	iplen=${#ipmonitor[@]}

	if [ $iplen -ne 0 ]; then
		data=$(cat $ipmonitor | grep "failure found" | wc -l)

		if [ $data -ne 5 ]; then
			echo "SUBJECT: IP Monitor Log - $(hostname) - $(date +"%F %T")" >>$svrlogs/mail/ipmail_$time.txt
			echo "FROM: monitor@$cpuser.com" >>$svrlogs/mail/ipmail_$time.txt
			echo "" >>$svrlogs/mail/ipmail_$time.txt
			echo "$(cat $ipmonitor)" >>$svrlogs/mail/ipmail_$time.txt
			sendmail "$emailmo,$emailmg" <$svrlogs/mail/ipmail_$time.txt
		fi
	fi
}

send_mail
