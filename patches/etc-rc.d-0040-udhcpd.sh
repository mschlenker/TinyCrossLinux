#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
source /etc/rc.subr/colors 
export PATH

case $1 in
    start)
	printf "${bold}Starting network... ${normal}\n"
	succeeded=0
	for n in 0 1 2 3 4 ; do
		ifconfig eth${n} up && udhcpc eth${n} && succeeded=1
	done
	if [ "$succeeded" -gt 0 ] ; then
		printf "${bold}Starting network ${success} ${normal}\n"
	else
		printf "${bold}Starting network ${failed} ${normal}\n"
	fi
    ;;
esac
