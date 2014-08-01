#!/bin/ash

case $1 in
    start)
	enable=1
	for tok in ` cat /proc/cmdline ` ; do
		case $tok in
			syslogd=0)
				enable=0
			;;
		esac
	done
	if [ "$enable" -gt 0 ] ; then
		printf "${bold}Starting syslogd ${normal}"
		mkdir -p /var/log 
		mkdir -p /var/run
		for f in wtmp lastlog ; do
			touch /var/log/$f
			chown 0:43 /var/log/$f
			chmod 0664 /var/log/$f
		done
		touch /var/run/utmp
		chown 0:13 /var/run/utmp
		chmod 0664 /var/run/utmp
		syslogd && printf "${success}\n" || printf "${failed}\n"
	fi
    ;;
esac
