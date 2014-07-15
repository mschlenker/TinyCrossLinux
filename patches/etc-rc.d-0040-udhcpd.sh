#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
source /etc/rc.subr/colors 
export PATH

case $1 in
    start)
	printf "${bold}Starting network... ${normal}\n"
	succeeded=0
	for n in 0 1 2 3 4 ; do
		ifconfig eth${n} up
	done
	udhcpc -S
    ;;
esac
