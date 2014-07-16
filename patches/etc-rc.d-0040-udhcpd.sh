#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
source /etc/rc.subr/colors 
export PATH

case $1 in
    start)
	enable=1
	for tok in ` cat /proc/cmdline ` ; do
		case $tok in
			nonet)
				enable=0
			;;
		esac
	done
	if [ "$enable" -gt 0 ] ; then
		printf "${bold}Starting network... ${normal}\n"
		for n in 0 1 2 3 4 ; do
			ifconfig eth${n} up
		done
		udhcpc -S
	fi
    ;;
esac
