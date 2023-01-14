#!/bin/bash

cpuser="directory-name"
svrlogs="/home/$cpuser/svrlogs"
temp="$svrlogs/temp"
hostname=$(hostname | awk -F'.' '{print $1}')
svrdomain=$(hostname)
svrip=$(dig $(hostname) A +short)
logtime=$(date +"%Y-%m")
logdate=$(date +"%Y-%m-%d")
time=$(date +"%F_%T")
date=$(date +"%F")
link="sms-link"
emaillo="logs-email1"
emaillg="logs-email2"
emailmo="monitor-email1"
emailmg="monitor-email2"
emailng="network-email"
dbemail="db-email"
