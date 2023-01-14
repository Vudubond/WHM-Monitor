#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function ip_list() {
	ip a | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d"/" -f1 >>$temp/ipaddress_$time.txt
}

function check_ptr() {
	while IFS= read -r line || [[ -n "$line" ]]; do
		ptr=$(dig -x $line +short)

		if [ ! -z $ptr ]; then
			printf "%-18s %-50s\n" "$line" "$ptr" >>$temp/ipptr_$time.txt
		else
			printf "%-18s %-50s\n" "$line" "no_ptr_record" >>$temp/ipptr_$time.txt
		fi

	done <"$temp/ipaddress_$time.txt"
}

function check_data() {
	if [ -r $temp/ipptr_$time.txt ] && [ -s $temp/ipptr_$time.txt ]; then
		cat $temp/ipptr_$time.txt >>$svrlogs/serverwatch/ipptr_$time.txt
	fi
}

function check_diff() {
	tlist=($(ls -lat $svrlogs/serverwatch | grep -i "ipptr" | grep -i "$(date +"%F")" | head -1 | awk '{print "$svrlogs/serverwatch/"$9}'))
	ylist=($(ls -lat $svrlogs/serverwatch | grep -i "ipptr" | grep -i "$(date -d 'yesterday' +"%F")" | head -1 | awk '{print "$svrlogs/serverwatch/"$9}'))

	if [[ ! -z $ylist ]]; then
		tip=($(cat $tlist | awk '{print $1}'))
		tptr=($(cat $tlist | awk '{print $2}'))
		yip=($(cat $ylist | awk '{print $1}'))
		yptr=($(cat $ylist | awk '{print $2}'))

		tcount=${#tip[@]}
		ycount=${#yip[@]}

		for ((i = 0; i < tcount; i++)); do
			for ((j = 0; j < ycount; j++)); do
				if [[ "${tip[i]}" == "${yip[j]}" ]]; then
					if [[ "${tptr[i]}" != "${yptr[j]}" ]]; then
						echo "Today: ${tip[i]} - ${tptr[i]}" >>$temp/ipptrdiff_$time.txt
						echo "Yesterday: ${yip[j]} - ${yptr[j]}" >>$temp/ipptrdiff_$time.txt
					fi
				fi
			done
		done
	fi
}

function diff_data() {
	if [ -r $temp/ipptrdiff_$time.txt ] && [ -s $temp/ipptrdiff_$time.txt ]; then
		echo "" >>$svrlogs/serverwatch/ipptr_$time.txt
		data=$(cat $temp/ipptrdiff_$time.txt)
		echo "$data" >>$svrlogs/serverwatch/ipptr_$time.txt
	fi
}

ip_list

check_ptr

check_data

check_diff

diff_data
