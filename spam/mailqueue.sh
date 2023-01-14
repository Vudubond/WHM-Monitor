#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function header() {
	if [ ! -f $svrlogs/spam/mailqueue/mailqueue_$date.txt ]; then
		printf "%-20s %-10s %-10s %-10s %-10s %-10s %-10s\n" "DATE_TIME" "R_FROZEN" "R_RMV" "U_FROZEN" "U_RMV" "S_QUEUE" "U_QUEUE" >>$svrlogs/spam/mailqueue/mailqueue_$date.txt
	fi
}

function frozenroot_rmv() {
	if [ -r $temp/frozenroot_$time.txt ] && [ -s $temp/frozenroot_$time.txt ]; then
		rfcount=$(cat $temp/frozenroot_$time.txt | wc -l)
		num=0

		while IFS= read -r line || [[ -n "$line" ]]; do
			msgid=$(echo "$line" | awk '{print $1}')
			result=$(exim -Mrm $msgid)
			status=$(echo "$result" | awk '{print $NF}')

			if [[ $status == "removed" ]]; then
				num=$((num + 1))
			fi
		done <"$temp/frozenroot_$time.txt"

		rcount=$num
	else
		rfcount=$(cat $temp/frozenroot_$time.txt | wc -l)
		rcount=0
	fi
}

function frozenuser_rmv() {
	if [ -r $temp/frozenuser_$time.txt ] && [ -s $temp/frozenuser_$time.txt ]; then
		ufcount=$(cat $temp/frozenuser_$time.txt | wc -l)
		num=0

		while IFS= read -r line || [[ -n "$line" ]]; do
			from=$(echo "$line" | awk '{print $3}')

			if [[ $from == "<>" ]]; then
				msgid=$(echo "$line" | awk '{print $1}')
				result=$(exim -Mrm $msgid)
				status=$(echo "$result" | awk '{print $NF}')

				if [[ $status == "removed" ]]; then
					num=$((num + 1))
				fi
			fi
		done <"$temp/frozenuser_$time.txt"

		ucount=$num
	else
		ufcount=$(cat $temp/frozenuser_$time.txt | wc -l)
		ucount=0
	fi
}

function mail_frozen() {

	host=$(hostname)

	exiqgrep -zbr root@$host >>$temp/frozenroot_$time.txt

	exiqgrep -zb | grep -v "root@$host" >>$temp/frozenuser_$time.txt

	frozenroot_rmv

	frozenuser_rmv
}

function mail_queue() {

	systemq=$(exiqgrep -xb | grep "<>")
	sqcount=$(exiqgrep -xb | grep "<>" | wc -l)

	userq=$(exiqgrep -xb | grep -v "<>")
	uqcount=$(exiqgrep -xb | grep -v "<>" | wc -l)

	if [ "$uqcount" -gt 50 ]; then
		queue_data

		content=$(echo "Mail Queue - $uqcount")

		send_sms

		send_mail
	fi
}

function print_data() {

	header

	printf "%-20s %-10s %-10s %-10s %-10s %-10s %-10s\n" "$time" "$rfcount" "$rcount" "$ufcount" "$ucount" "$sqcount" "$uqcount" >>$svrlogs/spam/mailqueue/mailqueue_$date.txt
}

function queue_data() {

	echo "Mail Queue - $qtotal" >>$svrlogs/spam/mailqueue/mqcheck_$time.txt
	echo "" >>$svrlogs/spam/mailqueue/mqcheck_$time.txt

	echo "System:" >>$svrlogs/spam/mailqueue/mqcheck_$time.txt
	echo "Total: $sqcount" >>$svrlogs/spam/mailqueue/mqcheck_$time.txt
	echo "$systemq" >>$svrlogs/spam/mailqueue/mqcheck_$time.txt
	echo "" >>$svrlogs/spam/mailqueue/mqcheck_$time.txt

	echo "User:" >>$svrlogs/spam/mailqueue/mqcheck_$time.txt
	echo "Total: $uqcount" >>$svrlogs/spam/mailqueue/mqcheck_$time.txt
	echo "$userq" >>$svrlogs/spam/mailqueue/mqcheck_$time.txt
}

function send_sms() {
	message=$(echo "$hostname: $content")

	url=$(echo "$link?me5352ss75age=$message&f3f34h47y53s2=4399648395395244")

	wget "${url}"
}

function send_mail() {
	echo "SUBJECT: Mail Queue Check - $hostname - $(date +"%F")" >>$svrlogs/mail/mqmail_$time.txt
	echo "FROM: monitor@$cpuser.com" >>$svrlogs/mail/mqmail_$time.txt
	echo "" >>$svrlogs/mail/mqmail_$time.txt
	echo "$(cat $svrlogs/spam/mailqueue/mqcheck_$time.txt)" >>$svrlogs/mail/mqmail_$time.txt
	sendmail "$emailmo,$emailmg" <$svrlogs/mail/mqmail_$time.txt
}

mail_frozen

mail_queue

print_data
