#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function get_ip_address() {
	ip a | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d"/" -f1 >>$temp/ipaddress_$time.txt
}

function reverse_ip() {
	for ip in $(cat $temp/ipaddress_$time.txt); do
		echo $ip | sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\4.\3.\2.\1~p" >>$temp/reverseip_$time.txt
	done
}

function blacklist_check() {
	for BL in $(cat /home/$cpuser/scripts/serverwatch/blacklists.txt); do
		for reverse in $(cat $temp/reverseip_$time.txt); do
			printf "%-60s" " ${reverse}.${BL}." >>$svrlogs/serverwatch/blacklist_$time.txt
			LISTED="$(dig +short -t a ${reverse}.${BL}.)"
			echo ${LISTED:----} >>$svrlogs/serverwatch/blacklist_$time.txt
		done
	done
}

function ip_blacklist() {
	if [ -r $svrlogs/serverwatch/blacklist_$time.txt ] && [ -s $svrlogs/serverwatch/blacklist_$time.txt ]; then
		cat $svrlogs/serverwatch/blacklist_$time.txt | awk '{if($2!="---") print $1,"\t"$2}' >>$temp/ipblacklist_$time.txt
	fi

	if [ -r $temp/ipblacklist_$time.txt ] && [ -s $temp/ipblacklist_$time.txt ]; then
		cp $temp/ipblacklist_$time.txt $svrlogs/serverwatch/ipblacklist_$time.txt
		echo "$(date +"%F %T") Created - $svrlogs/serverwatch/ipblacklist_$time.txt" >>$svrlogs/logs/serverwatchlogs_$logtime.txt
	fi
}

get_ip_address

reverse_ip

blacklist_check

ip_blacklist
