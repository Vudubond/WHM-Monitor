#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function check_directory() {
	sh /home/$cpuser/scripts/directory.sh
}

printf "Server Watch - $(date +"%F %T")\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

function disk_free() {
	printf "\n# *** Disk Free ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	diskfree=$(echo "$(df -Th | egrep "vda1|sda1" | awk '{print $(NF-1)}')")

	echo "$diskfree" >>$svrlogs/serverwatch/serverwatch_$time.txt

	funcdf=$(echo "DF: $diskfree")

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function file_count() {
	printf "\n# *** File Count (/home) ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	filecount=($(ls -lat $svrlogs/filecount | grep -i "homedir" | grep -i "$(date +"%F")" | head -1 | awk '{print "$svrlogs/filecount/"$9}'))

	if [[ ! -z $filecount ]]; then
		fcount=$(cat $filecount | grep "FILE COUNT" | awk '{print $NF}')
		diff=$(cat $filecount | grep "DIFFERENCE:" | awk '{print $2,$NF}')

		echo "$fcount" >>$svrlogs/serverwatch/serverwatch_$time.txt
		echo "$diff" >>$svrlogs/serverwatch/serverwatch_$time.txt

		funcfc=$(echo "FC: $fcount - $diff")
	else
		printf "File count not found\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function uptime_check() {
	printf "\n# *** Uptime ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	utfull=$(uptime | grep "day")

	if [[ ! -z $utfull ]]; then
		uptime=$(echo "$(uptime | awk '{print $3,$4}' | sed 's/,//')")
	else
		uptime=$(echo "$(uptime | awk '{print $3}' | sed 's/,//')")
	fi

	echo "$uptime" >>$svrlogs/serverwatch/serverwatch_$time.txt

	funcut=$(echo "UT: $uptime")

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function daily_process() {
	printf "\n# *** Daily Process ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	sh /home/$cpuser/scripts/serverwatch/dailyprocess.sh

	dailyprocess=($(ls -lat $svrlogs/serverwatch | grep -i "dailyprocess" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/serverwatch/"$9}'))

	if [[ ! -z $dailyprocess ]]; then
		echo "$(head -3 $dailyprocess)" >>$svrlogs/serverwatch/serverwatch_$time.txt
	else
		printf "Not available\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function ip_blacklist() {
	printf "\n# *** IP Blacklist ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	sh /home/$cpuser/scripts/serverwatch/ipcheck.sh

	ipblacklist=($(ls -lat $svrlogs/serverwatch | grep -i "ipblacklist" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/serverwatch/"$9}'))

	if [[ ! -z $ipblacklist ]]; then
		echo "$(cat $ipblacklist)" >>$svrlogs/serverwatch/serverwatch_$time.txt
	else
		printf "Not blacklisted\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function bandwidth_usage() {
	printf "\n# *** Bandwidth Usage ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	sh /home/$cpuser/scripts/serverwatch/bandwidth.sh

	bandwidthusage=($(ls -lat $svrlogs/serverwatch | grep -i "bandwidth" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/serverwatch/"$9}'))

	if [[ ! -z $bandwidthusage ]]; then
		bandwidth=$(cat $bandwidthusage | grep "Total" | sed 's/Total//')

		echo "$bandwidth" >>$svrlogs/serverwatch/serverwatch_$time.txt

		funcbw=$(echo "BW: $bandwidth")
	else
		printf "Not available\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function disk_usage() {
	printf "\n# *** Disk Usage ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	sh /home/$cpuser/scripts/serverwatch/diskusage.sh

	diskusage=($(ls -lat $svrlogs/serverwatch | grep -i "diskusage" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/serverwatch/"$9}'))

	if [[ ! -z $diskusage ]]; then
		echo "$(head -5 $diskusage | sed 's/M//')" >>$svrlogs/serverwatch/serverwatch_$time.txt
	else
		printf "Not available\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function disk_increment() {
	printf "\n# *** Disk Usage Increment ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	sh /home/$cpuser/scripts/serverwatch/diskincrement.sh

	diskincrement=($(ls -lat $svrlogs/serverwatch | grep -i "diskincrement" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/serverwatch/"$9}'))

	if [[ ! -z $diskincrement ]]; then
		echo "$(cat $diskincrement)" >>$svrlogs/serverwatch/serverwatch_$time.txt
	else
		printf "No high disk usage increment\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function abusers_usage() {
	printf "\n# *** Mail Usage ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	sh /home/$cpuser/scripts/abusers/mailusage.sh

	mailusage=($(ls -lat $svrlogs/abusers | grep -i "mailusage" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/abusers/"$9}'))

	if [[ ! -z $mailusage ]]; then
		echo "$(cat $mailusage | grep -v "Email Hosting")" >>$svrlogs/serverwatch/serverwatch_$time.txt
	else
		printf "No high mail usage\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function mail_block() {
	printf "\n# *** Outgoing Mail Blocked ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	sh /home/$cpuser/scripts/spam/outgoingblock.sh

	mailblock=($(ls -lat $svrlogs/serverwatch | grep -i "outgoingblock" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/serverwatch/"$9}'))

	if [[ ! -z $mailblock ]]; then
		echo "$(cat $mailblock)" >>$svrlogs/serverwatch/serverwatch_$time.txt
	else
		printf "No new mail block entries\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function ip_ptr() {
	printf "\n# *** IP PTR Records ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	sh /home/$cpuser/scripts/serverwatch/ptrcheck.sh

	ipptr=($(ls -lat $svrlogs/serverwatch | grep -i "ipptr" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/serverwatch/"$9}'))

	if [[ ! -z $ipptr ]]; then
		echo "$(cat $ipptr)" >>$svrlogs/serverwatch/serverwatch_$time.txt
	else
		printf "No PTR record found\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function spf_subdomain() {
	printf "\n# *** SPF Check - Subdomain ***\n\n" >>$svrlogs/serverwatch/serverwatch_$time.txt

	sh /home/$cpuser/scripts/dnszone/spfsubdomain.sh

	spfsubdomain=($(ls -lat $svrlogs/dnszone | grep -i "subdomspf" | grep -i "$(date +"%F_%H:")" | head -1 | awk '{print "$svrlogs/dnszone/"$9}'))

	if [[ ! -z $spfsubdomain ]]; then
		echo "$(cat $spfsubdomain)" >>$svrlogs/serverwatch/serverwatch_$time.txt
	else
		printf "No SPF updates\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/serverwatch/serverwatch_$time.txt
}

function send_mail() {
	sh /home/$cpuser/scripts/serverwatch/swmail.sh
}

function send_sms() {
	content=$(echo "$funcut; $funcdf; $funcfc; $funcbw")

	message=$(echo "$hostname: $content")

	url=$(echo "$link?me5352ss75age=$message&f3f34h47y53s2=4399648395395244")

	wget "${url}"
}

check_directory

disk_free

file_count

ip_blacklist

daily_process

bandwidth_usage

disk_usage

ip_ptr

disk_increment

abusers_usage

mail_block

uptime_check

spf_subdomain

send_sms

send_mail
