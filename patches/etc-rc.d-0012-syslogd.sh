#!/bin/ash

case $1 in
    start)
	printf "${bold}Starting syslogd ${normal}"
	mkdir -p /var/log 
	syslogd && printf "${success}\n" || printf "${failed}\n"
    ;;
esac
