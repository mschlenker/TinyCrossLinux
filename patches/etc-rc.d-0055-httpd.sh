#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
source /etc/rc.subr/colors 
export PATH

case $1 in
    start)
	enable=0
	for tok in ` cat /proc/cmdline ` ; do
		case $tok in
			'httpd=1')
				enable=1
			;;
		esac
	done
	if [ "$enable" -gt 0 ] ; then
		printf "${bold}Starting HTTPD ${normal}"
		if [ -d /srv/www ] ; then
			echo "Using existing /srv/www"
		else
			mkdir -p /srv/www
			echo '<html><body>Hello World</body></html>' > /srv/www/index.html
		fi
		httpd -h /srv/www && printf "${success}\n" || printf "${failed}\n"
	fi
    ;;
    stop)
	killall -9 httpd
    ;;
esac
