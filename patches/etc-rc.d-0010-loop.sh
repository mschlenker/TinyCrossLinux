#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH

case $1 in
    start)
	echo 'Starting loopback networking...'
	ifconfig lo inet 127.0.0.1 netmask 255.0.0.0 up
	[ -f /etc/hosts ] || echo '127.0.0.1 localhost' > /etc/hosts 
    ;;
esac
