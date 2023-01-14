#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function level_one() {
	if [[ ! -d "$svrlogs" ]]
	then
		mkdir $svrlogs
		chown $cpuser: $svrlogs
	fi
}

function level_two() {
	if [[ ! -d "$svrlogs/abusers" ]]
	then
		mkdir $svrlogs/abusers
		chown $cpuser: $svrlogs/abusers
	fi

	if [[ ! -d "$svrlogs/cphulk" ]]
	then
		mkdir $svrlogs/cphulk
		chown $cpuser: $svrlogs/cphulk
	fi

	if [[ ! -d "$svrlogs/diskusage" ]]
	then
		mkdir $svrlogs/diskusage
		chown $cpuser: $svrlogs/diskusage
	fi

	if [[ ! -d "$svrlogs/dnszone" ]]
	then
		mkdir $svrlogs/dnszone
		chown $cpuser: $svrlogs/dnszone
	fi

	if [[ ! -d "$svrlogs/errorlogwatch" ]]
	then
		mkdir $svrlogs/errorlogwatch
		chown $cpuser: $svrlogs/errorlogwatch
	fi

	if [[ ! -d "$svrlogs/filecount" ]]
	then
		mkdir $svrlogs/filecount
		chown $cpuser: $svrlogs/filecount
	fi

	if [[ ! -d "$svrlogs/ipmonitor" ]]
	then
		mkdir $svrlogs/ipmonitor
		chown $cpuser: $svrlogs/ipmonitor
	fi

	if [[ ! -d "$svrlogs/logs" ]]
	then
		mkdir $svrlogs/logs
		chown $cpuser: $svrlogs/logs
	fi

	if [[ ! -d "$svrlogs/mail" ]]
	then
		mkdir $svrlogs/mail
		chown $cpuser: $svrlogs/mail
	fi

	if [[ ! -d "$svrlogs/malware" ]]
	then
		mkdir $svrlogs/malware
		chown $cpuser: $svrlogs/malware
	fi

	if [[ ! -d "$svrlogs/network" ]]
	then
		mkdir $svrlogs/network
		chown $cpuser: $svrlogs/network
	fi

	if [[ ! -d "$svrlogs/package" ]]
	then
		mkdir $svrlogs/package
		chown $cpuser: $svrlogs/package
	fi

	if [[ ! -d "$svrlogs/serverwatch" ]]
	then
		mkdir $svrlogs/serverwatch
		chown $cpuser: $svrlogs/serverwatch
	fi

	if [[ ! -d "$svrlogs/service" ]]
	then
		mkdir $svrlogs/service
		chown $cpuser: $svrlogs/service
	fi

	if [[ ! -d "$svrlogs/spam" ]]
	then
		mkdir $svrlogs/spam
		chown $cpuser: $svrlogs/spam
	fi

	if [[ ! -d "$svrlogs/status" ]]
	then
		mkdir $svrlogs/status
		chown $cpuser: $svrlogs/status
	fi

	if [[ ! -d "$temp" ]]
	then
		mkdir $temp
		chown $cpuser: $temp
	fi

	if [[ ! -d "$svrlogs/testmode" ]]
	then
		mkdir $svrlogs/testmode
		chown $cpuser: $svrlogs/testmode
	fi
}

function level_three() {
	if [[ ! -d "$svrlogs/cphulk/block" ]]
	then
		mkdir $svrlogs/cphulk/block
		chown $cpuser: $svrlogs/cphulk/block
	fi

	if [[ ! -d "$svrlogs/cphulk/iplist" ]]
	then
		mkdir $svrlogs/cphulk/iplist
		chown $cpuser: $svrlogs/cphulk/iplist
	fi

	if [[ ! -d "$svrlogs/cphulk/unblock" ]]
	then
		mkdir $svrlogs/cphulk/unblock
		chown $cpuser: $svrlogs/cphulk/unblock
	fi

	if [[ ! -d "$svrlogs/spam/hourlycheck" ]]
	then
		mkdir $svrlogs/spam/hourlycheck
		chown $cpuser: $svrlogs/spam/hourlycheck
	fi

	if [[ ! -d "$svrlogs/spam/localhost" ]]
	then
		mkdir $svrlogs/spam/localhost
		chown $cpuser: $svrlogs/spam/localhost
	fi

	if [[ ! -d "$svrlogs/spam/mailblock" ]]
	then
		mkdir $svrlogs/spam/mailblock
		chown $cpuser: $svrlogs/spam/mailblock
	fi

	if [[ ! -d "$svrlogs/spam/mailqueue" ]]
	then
		mkdir $svrlogs/spam/mailqueue
		chown $cpuser: $svrlogs/spam/mailqueue
	fi

	if [[ ! -d "$svrlogs/spam/new" ]]
	then
		mkdir $svrlogs/spam/new
		chown $cpuser: $svrlogs/spam/new
	fi

	if [[ ! -d "$svrlogs/spam/suspended" ]]
	then
		mkdir $svrlogs/spam/suspended
		chown $cpuser: $svrlogs/spam/suspended
	fi
}

level_one

level_two

level_three
