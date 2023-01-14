#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function check_directory() {
	sh /home/$cpuser/scripts/directory.sh
}

printf "Error Log Watch - $(date +"%F %T")\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

function apache_log() {
	printf "\n# *** Apache Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/apachelog.sh

	apachelog=($(ls -lat $svrlogs/errorlogwatch | grep -i "maxrequest" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $apachelog ]]; then
		echo "$(cat $apachelog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No max request workers found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function access_log() {
	printf "\n# *** WHM Access Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/accesslog.sh

	accesslog=($(ls -lat $svrlogs/errorlogwatch | grep -i "whmaccess" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $accesslog ]]; then
		echo "$(cat $accesslog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No whm access history\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function phpfpm_log() {
	printf "\n# *** PHP FPM Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/phpfpmlog.sh

	phpfpmlog=($(ls -lat $svrlogs/errorlogwatch | grep -i "fpmerror" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $phpfpmlog ]]; then
		echo "$(cat $phpfpmlog | tail -1)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No php fpm error found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function account_log() {
	printf "\n# *** Account Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/accountlog.sh

	accountlog=($(ls -lat $svrlogs/errorlogwatch | grep -i "accountlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $accountlog ]]; then
		echo "$(cat $accountlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No account history\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function spf_log() {
	printf "\n# *** SPF Check - New Account ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/dnszone/spfrecord.sh

	accountspf=($(ls -lat $svrlogs/dnszone | grep -i "accountspf" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/dnszone/"$9}'))

	if [[ ! -z $accountspf ]]; then
		echo "$(cat $accountspf)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No SPF updates\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	printf "\n# *** SPF Check - Addon Domain ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	addonspf=($(ls -lat $svrlogs/dnszone | grep -i "addonspf" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/dnszone/"$9}'))

	if [[ ! -z $addonspf ]]; then
		echo "$(cat $addonspf)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No SPF updates\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function account_new() {
	printf "\n# *** Account Log - New Accounts ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/accountpackage.sh

	accountnew=($(ls -lat $svrlogs/errorlogwatch | grep -i "accountpackage" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $accountnew ]]; then
		echo "$(cat $accountnew)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No new accounts\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function addon_log() {
	printf "\n# *** Addon Domain Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/addonlog.sh

	addonlog=($(ls -lat $svrlogs/errorlogwatch | grep -i "addonlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $addonlog ]]; then
		echo "$(cat $addonlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No new addon domains\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function ssh_log() {
	printf "\n# *** SSH Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/sshlog.sh

	sshlog=($(ls -lat $svrlogs/errorlogwatch | grep -i "sshlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $sshlog ]]; then
		echo "$(cat $sshlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No ssh login attempts\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function exim_log() {
	printf "\n# *** Exim Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/eximlog.sh

	eximlog=($(ls -lat $svrlogs/errorlogwatch | grep -i "error451" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $eximlog ]]; then
		echo "$(cat $eximlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No 451 error found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function logindefer_log() {
	printf "\n# *** Login Log - Deferred ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/logindefer.sh

	logindefer=($(ls -lat $svrlogs/errorlogwatch | grep -i "deferred-login" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $logindefer ]]; then
		echo "$(cat $logindefer)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No login defer found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function cron_log() {
	printf "\n# *** Cron Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/cronlog.sh

	cronlog=($(ls -lat $svrlogs/errorlogwatch | grep -i "cronlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $cronlog ]]; then
		echo "$(cat $cronlog | head)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No cron job history\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function last_log() {
	printf "\n# *** Last Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/lastlog.sh

	lastlog=($(ls -lat $svrlogs/errorlogwatch | grep -i "lastlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $lastlog ]]; then
		echo "$(cat $lastlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No server login history\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function cron_jobs() {
	printf "\n# *** Cron Jobs ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/cronjob.sh

	cronjob=($(ls -lat $svrlogs/errorlogwatch | grep -i "cronjob" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $cronjob ]]; then
		echo "$(cat $cronjob)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No limit exceeded cron jobs\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function dbgovernor_log() {
	printf "\n# *** DBGovernor Error Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/dbgovernorlog.sh

	dbgov=($(ls -lat $svrlogs/errorlogwatch | grep -i "dbgoverror" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $dbgov ]]; then
		echo "$(cat $dbgov)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No DBGovernor error found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function lve_kill() {
	printf "\n# *** LVE Process Kill ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/lvekill.sh

	lvekill=($(ls -lat $svrlogs/errorlogwatch | grep -i "lvekill" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $lvekill ]]; then
		echo "$(cat $lvekill)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No process kill records found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function yum_log() {
	printf "\n# *** Yum Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/yumlog.sh

	yumlog=($(ls -lat $svrlogs/errorlogwatch | grep -i "yumlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $yumlog ]]; then
		echo "$(cat $yumlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No yum records found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function cperror_log() {
	printf "\n# *** cPHulk Error Log - Broken ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/cphulkerror.sh

	cpbroken=($(ls -lat $svrlogs/errorlogwatch | grep -i "cpbrokenlog" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $cpbroken ]]; then
		echo "$(cat $cpbroken)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No broken pipe error found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	printf "\n# *** cPHulk Error Log - Mailbox ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	cpmailbox=($(ls -lat $svrlogs/errorlogwatch | grep -i "cpmailbox" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $cpmailbox ]]; then
		echo "$(cat $cpmailbox)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No ftpd-mailbox error found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function notification_log() {
	printf "\n# *** Error Log - Notification ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/notification.sh

	notification=($(ls -lat $svrlogs/errorlogwatch | grep -i "notification" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $notification ]]; then
		echo "$(cat $notification)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No notifications found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function ext_index() {
	printf "\n# *** EXT Warning ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh /home/$cpuser/scripts/errorlogwatch/extindex.sh

	extindex=($(ls -lat $svrlogs/errorlogwatch | grep -i "extindex" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/errorlogwatch/"$9}'))

	if [[ ! -z $extindex ]]; then
		echo "$(cat $extindex)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No directory index full warning found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function send_mail() {
	sh /home/$cpuser/scripts/errorlogwatch/elwmail.sh
}

check_directory

access_log

last_log

logindefer_log

ssh_log

apache_log

exim_log

cron_jobs

account_log

account_new

addon_log

spf_log

lve_kill

ext_index

cperror_log

dbgovernor_log

phpfpm_log

cron_log

yum_log

notification_log

send_mail
