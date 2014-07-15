#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH

case $1 in
    start)
	echo 'Starting udhcpc...'
	for n in 0 1 2 3 4 ; do
		ifconfig eth${n} up ; udhcpc eth${n}
	done
    ;;
esac
