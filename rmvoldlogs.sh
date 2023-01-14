#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function rmvold_logs() {
	for file in "${oldlogs[@]}"
	do
		filepath=$(echo "$directory/$file")
		rm -f $filepath
		echo "$(date +"%F %T") Removed - $filepath" >>$svrlogs/logs/rmvoldlogs_$logtime.txt
	done
}

function serverwatch_old() {
	directory="$svrlogs/serverwatch"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs
}

function errorlogwatch_old() {
	directory="$svrlogs/errorlogwatch"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs
}

function spam_old() {
	directory="$svrlogs/spam/hourlycheck"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs

	directory="$svrlogs/spam/localhost"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs

	directory="$svrlogs/spam/mailblock"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs

	directory="$svrlogs/spam/mailqueue"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs

	directory="$svrlogs/spam/new"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs

	directory="$svrlogs/spam/suspended"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs
}

function mail_old() {
	directory="$svrlogs/mail"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs
}

function cphulk_old() {
	directory="$svrlogs/cphulk/block"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs

	directory="$svrlogs/cphulk/iplist"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs

	directory="$svrlogs/cphulk/unblock"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs
}

function ipmonitor_old() {
	directory="$svrlogs/ipmonitor"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs
}

function diskusage_old() {
	directory="$svrlogs/diskusage"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs
}

function package_old() {
	directory="$svrlogs/package"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs
}

function dnszone_old() {
	directory="$svrlogs/dnszone"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs
}

function network_old() {
	directory="$svrlogs/network"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs
}

function testmode_old() {
	directory="$svrlogs/testmode"
	oldlogs=($(ls $directory | grep -i "$(date -d '21 days ago' +"%F")"))

	rmvold_logs
}

function service_old() {
	directory="$svrlogs/service"
	oldlogs=($(ls $directory | grep -i "$(date -d '3 months ago' +"%F")"))

	rmvold_logs
}

function status_old() {
	directory="$svrlogs/status"
	oldlogs=($(ls $directory | grep -i "$(date -d '3 months ago' +"%F")"))

	rmvold_logs
}

function filecount_old() {
	directory="$svrlogs/filecount"
	oldlogs=($(ls $directory | grep -i "$(date -d '3 months ago' +"%F")"))

	rmvold_logs
}

function abusers_old() {
	directory="$svrlogs/abusers"
	oldlogs=($(ls $directory | grep -i "$(date -d '3 months ago' +"%F")"))

	rmvold_logs
}

function malware_old() {
	directory="$svrlogs/malware"
	oldlogs=($(ls $directory | grep -i "$(date -d '3 months ago' +"%F")"))

	rmvold_logs
}

function logs_old() {
	directory="$svrlogs/logs"
	oldlogs=($(ls $directory | grep -i "$(date -d '3 months ago' +"%F")"))

	rmvold_logs
}

serverwatch_old

errorlogwatch_old

spam_old

mail_old

cphulk_old

ipmonitor_old

diskusage_old

package_old

dnszone_old

network_old

testmode_old

service_old

status_old

filecount_old

malware_old

logs_old
