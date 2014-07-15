#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
source /etc/rc.subr/colors 
export PATH

case $1 in
    start)
	printf "${bold}Starting loopback interface ${normal}"
	ifconfig lo inet 127.0.0.1 netmask 255.0.0.0 up && printf "${success}\n"
	[ -f /etc/hosts ] || echo '127.0.0.1 localhost' > /etc/hosts
	hostname linux
    ;;
esac
