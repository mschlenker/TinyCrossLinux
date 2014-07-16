#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
source /etc/rc.subr/colors 
export PATH

case $1 in
    start)
	enable=0
	for tok in ` cat /proc/cmdline ` ; do
		case $tok in
			tftpd=1)
				enable=1
			;;
		esac
	done
	if [ "$enable" -gt 0 ] ; then
		printf "${bold}Starting TFPD... ${normal}\n"
		if [ -d /srv/tftp ] ; then
			echo "Using existing /srv/tftp"
		else
			mkdir -p /srv/tftp
			echo 'Hello World' > /srv/tftp/test.txt
		fi
		udpsvd -E 0 69 tftpd -l /srv/tftp &
	fi
    ;;
    stop)
	killall -9 udpsvd
    ;;
esac
