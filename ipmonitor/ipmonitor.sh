#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function check_directory() {
	sh /home/$cpuser/scripts/directory.sh
}

printf "IP Monitor Log - $(date +"%F %T")\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt

printf "\n************************************************************\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt

function loginfail_log() {
	printf "\n# *** Login Log - Failed ***\n\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt

	sh /home/$cpuser/scripts/ipmonitor/loginfail.sh

	loginfail=($(ls -lat $svrlogs/ipmonitor | grep -i "loginlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/ipmonitor/"$9}'))

	if [[ ! -z $loginfail ]]; then
		echo "$(cat $loginfail)" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	else
		printf "No login failure found\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
}

function ftpd_log() {
	printf "\n# *** FTPD Log ***\n\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt

	sh /home/$cpuser/scripts/ipmonitor/ftpdlog.sh

	ftpdlog=($(ls -lat $svrlogs/ipmonitor | grep -i "ftpdlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/ipmonitor/"$9}'))

	if [[ ! -z $ftpdlog ]]; then
		echo "$(cat $ftpdlog)" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	else
		printf "No ftpd failure found\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
}

function ssh_log() {
	printf "\n# *** SSH Log ***\n\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt

	sh /home/$cpuser/scripts/ipmonitor/sshlog.sh

	sshlog=($(ls -lat $svrlogs/ipmonitor | grep -i "sshlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/ipmonitor/"$9}'))

	if [[ ! -z $sshlog ]]; then
		echo "$(cat $sshlog)" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	else
		printf "No ssh failure found\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
}

function exim_dovecot() {
	printf "\n# *** Exim Log - Dovecot Login ***\n\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt

	sh /home/$cpuser/scripts/ipmonitor/eximdovecot.sh

	eximdovecot=($(ls -lat $svrlogs/ipmonitor | grep -i "eximdovecot" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/ipmonitor/"$9}'))

	if [[ ! -z $eximdovecot ]]; then
		echo "$(cat $eximdovecot)" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	else
		printf "No dovecot login failure found\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
}

function mail_log() {
	printf "\n# *** Mail Log ***\n\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt

	sh /home/$cpuser/scripts/ipmonitor/maillog.sh

	maillog=($(ls -lat $svrlogs/ipmonitor | grep -i "maillog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/ipmonitor/"$9}'))

	if [[ ! -z $maillog ]]; then
		echo "$(cat $maillog)" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	else
		printf "No imap/pop3 failure found\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
}

function wplogin_log() {
	printf "\n# *** WP Login Log - Failed ***\n\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt

	sh /home/$cpuser/scripts/ipmonitor/wplogin.sh

	wplogin=($(ls -lat $svrlogs/ipmonitor | grep -i "wplog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/ipmonitor/"$9}'))

	if [[ ! -z $wplogin ]]; then
		echo "$(cat $wplogin)" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	else
		printf "No WP login failure found\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
}

function cphulk_log() {
	printf "\n# *** cPHulk Log ***\n\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt

	sh /home/$cpuser/scripts/ipmonitor/cphulklog.sh

	cphulklog=($(ls -lat $svrlogs/ipmonitor | grep -i "cphulklog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/ipmonitor/"$9}'))

	if [[ ! -z $cphulklog ]]; then
		echo "$(cat $cphulklog)" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	else
		printf "No cPHulk failure found\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/ipmonitor/ipmonitor_$time.txt
}

function send_mail() {
	sh /home/$cpuser/scripts/ipmonitor/ipmail.sh
}

check_directory

loginfail_log

ftpd_log

ssh_log

exim_dovecot

mail_log

cphulk_log

#send_mail
