#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
source /etc/rc.subr/colors 
export PATH

case $1 in
    start)
	enable=0
	for tok in ` cat /proc/cmdline ` ; do
		case $tok in
			udhcpd=1)
				enable=1
			;;
		esac
	done
	if [ "$enable" -gt 0 ] ; then
		printf "${bold}Starting UDHCPD ${normal}"
		if [ -f /etc/udhcpd.conf ] ; then
			udhcpd /etc/udhcpd.conf && printf "${success}\n" || printf "${failed}\n"
		else
			printf ": /etc/udhcpd.conf missing ${failed}\n"
		fi
	fi
    ;;
    stop)
	killall -9 udhcpd
    ;;
esac
