#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function file_count() {
	echo "DATE: $(date +"%F")" >>$svrlogs/filecount/homedir_$time.txt
	echo "START: $(date +"%T")" >>$svrlogs/filecount/homedir_$time.txt

	fcount=$(find /home -type f -exec ls -lh {} + | wc -l)

	echo "FILE COUNT (/home): $fcount" >>$svrlogs/filecount/homedir_$time.txt

	file_diff

	echo "END: $(date +"%T")" >>$svrlogs/filecount/homedir_$time.txt
}

function file_diff() {
	yfile=($(ls -lat $svrlogs/filecount | grep "homedir" | grep "$(date -d 'yesterday' +"%F")" | head -1 | awk '{print "$svrlogs/filecount/"$9}'))

	ycount=$(cat $yfile | grep "FILE COUNT" | awk '{print $NF}')

	if [[ $ycount -lt $fcount ]]; then
		diff=$(echo "fcount" | awk -v td=$fcount -v yd=$ycount 'BEGIN {foo=td-yd ; printf "%d",foo}')

		echo "DIFFERENCE: $diff (Increment)" >>$svrlogs/filecount/homedir_$time.txt

	elif [[ $ycount -gt $fcount ]]; then
		diff=$(echo "ycount" | awk -v td=$fcount -v yd=$ycount 'BEGIN {foo=yd-td ; printf "%d",foo}')

		echo "DIFFERENCE: $diff (Decrement)" >>$svrlogs/filecount/homedir_$time.txt

	else
		diff=0

		echo "DIFFERENCE: $diff (Same)" >>$svrlogs/filecount/homedir_$time.txt
	fi
}

file_count
