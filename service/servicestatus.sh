#!/bin/bash

source /home/rlksvrlogs/scripts/dataset.sh

function service_list() {
	systemctl | grep -v "thttpd.service" | grep -e "abrtd.service\|atd.service\|auditd.service\|chronyd.service\|collectd.service\|cpanel.service\|cpanel_php_fpm.service\|cpanellogd.service\|cpdavd.service\|cphulkd.service\|crond.service\|db_governor.service\|dbus.service\|dnsadmin.service\|dovecot.service\|exim.service\|getty@tty1.service\|httpd.service\|irqbalance.service\|lfd.service\|libstoragemgmt.service\|lshttpd.service\|lvestats.service\|lvm2-lvmetad.service\|mailman.service\|memcached.service\|mysqld.service\|named.service\|nscd.service\|pdns.service\|polkit.service\|postgresql.service\|proxyexecd.service\|pure-authd.service\|pure-ftpd.service\|qemu-guest-agent.service\|queueprocd.service\|rhnsd.service\|rngd.service\|rpcbind.service\|rsyslog.service\|serial-getty@ttyS0.service\|smartd.service\|spamd.service\|ssa-agent.service\|sshd.service\|sw-engine.service\|systemd-journald.service\|systemd-logind.service\|systemd-udevd.service\|tailwatchd.service\|wp-toolkit-background-tasks.service\|wp-toolkit-scheduled-tasks.service\|zabbix-agent.service" >>$temp/servicestatus_$time.txt
}

function service_status() {
	cat $temp/servicestatus_$time.txt | grep "failed" | awk '{first = $1; $1 = ""; print $0}' | sed -e 's/^[[:space:]]*//' | awk '{printf "%-30s %-10s\n",$1,$4}' >>$temp/servicefailure_$time.txt

	if [ -r $temp/servicefailure_$time.txt ] && [ -s $temp/servicefailure_$time.txt ]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			service=$(echo "$line" | awk '{print $1}' | awk -F'.' '{print $1}')
			status=$(echo "$line" | awk '{print $NF}')

			if [[ $service == "cpanel_php_fpm" || $service == "cpanellogd" || $service == "cpdavd" || $service == "cphulkd" || $service == "crond" || $service == "dnsadmin" || $service == "dovecot" || $service == "exim" || $service == "mailman" || $service == "mysqld" || $service == "named" || $service == "nscd" || $service == "pdns" || $service == "postgresql" || $service == "pure-ftpd" || $service == "queueprocd" || $service == "rsyslog" || $service == "spamd" || $service == "sshd" || $service == "tailwatchd" ]]; then
				if [[ $service != "mailman" ]]; then
					/scripts/restartsrv_$service

					check_stat
				fi

			elif [[ $service == "httpd" ]]; then
				listen=$(netstat -ntlp | grep "litespeed" | awk '{print $4}' | awk -F':' '{print $NF}' | sort | uniq | sort -n | head -1)

				if [[ $listen -ne 80 || -z $listen ]]; then
					/scripts/restartsrv_$service

					check_stat
				fi

			elif [[ $service == "lshttpd" ]]; then
				listen=$(netstat -ntlp | grep "httpd" | awk '{print $4}' | awk -F':' '{print $NF}' | sort | uniq | sort -n | head -1)

				if [[ -z $listen ]]; then
					/usr/local/lsws/bin/lswsctrl restart

					check_stat
				fi

			elif [[ $service == "lfd" ]]; then
				csfnow=$(systemctl status csf | sed -n 3p | awk '{print $2}')

				if [[ $csfnow == "failed" ]]; then
					errorlog=$(ls /etc/csf | grep "csf.error")

					if [[ ! -z $errorlog ]]; then
						error=$(cat /etc/csf/csf.error)

						mv /etc/csf/csf.error $svrlogs/service

						systemctl restart csf

						systemctl restart $service
					else
						systemctl restart csf

						systemctl restart $service
					fi

				else
					systemctl restart $service
				fi

				check_stat

			else
				systemctl restart $service

				check_stat
			fi

		done <"$temp/servicefailure_$time.txt"
	fi
}

function check_stat() {

	now=$(systemctl status $service | sed -n 3p | awk '{print $2}')

	content=$(echo "$service - $status - restarted - $now")

	echo "$(date +"%F %T") $content" >>$svrlogs/service/servicefailure_$date.txt

	send_sms

	send_mail
}

function send_sms() {
	message=$(echo "$hostname: $content")

	url=$(echo "$link?me5352ss75age=$message&f3f34h47y53s2=4399648395395244")

	wget "${url}"
}

function send_mail() {
	echo "SUBJECT: Service Failure Check - $hostname - $(date +"%F")" >>$svrlogs/mail/$svc-mail_$time.txt
	echo "FROM: service@$cpuser.com" >>$svrlogs/mail/$svc-mail_$time.txt
	echo "" >>$svrlogs/mail/$svc-mail_$time.txt
	printf "%-10s %20s\n" "Date:" "$(date +"%F")" >>$svrlogs/mail/$svc-mail_$time.txt
	printf "%-10s %20s\n" "Time:" "$(date +"%T")" >>$svrlogs/mail/$svc-mail_$time.txt
	printf "%-10s %20s\n" "Service:" "$service" >>$svrlogs/mail/$svc-mail_$time.txt
	printf "%-10s %20s\n" "Status:" "$status" >>$svrlogs/mail/$svc-mail_$time.txt
	printf "%-10s %20s\n" "Restart:" "$now" >>$svrlogs/mail/$svc-mail_$time.txt

	if [[ $now == "failed" ]]; then
		if [[ $service == "lfd" ]]; then
			if [[ ! -z $error ]]; then
				echo "" >>$svrlogs/mail/$svc-mail_$time.txt
				echo "$error" >>$svrlogs/mail/$svc-mail_$time.txt
			fi

			echo "" >>$svrlogs/mail/$svc-mail_$time.txt
			echo "$(systemctl status $service)" >>$svrlogs/mail/$svc-mail_$time.txt

			echo "" >>$svrlogs/mail/$svc-mail_$time.txt
			echo "$(systemctl status csf)" >>$svrlogs/mail/$svc-mail_$time.txt
		else
			echo "" >>$svrlogs/mail/$svc-mail_$time.txt
			echo "$(systemctl status $service)" >>$svrlogs/mail/$svc-mail_$time.txt
		fi
	fi

	sendmail "$emailmo,$emailmg" <$svrlogs/mail/$svc-mail_$time.txt
}

service_list

service_status
