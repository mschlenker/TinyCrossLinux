#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
source /etc/rc.subr/colors 
export PATH

case $1 in
    start)
	printf "${bold}Starting dropbear SSHD... ${normal}"
	for t in ecdsa ; do # ignore rsa dss
		[ -f /etc/dropbear/dropbear_${t}_host_key ] || dropbearkey -t ${t} -f /etc/dropbear/dropbear_${t}_host_key
	done
	dropbear && printf "${bold}Starting dropbear SSHD ${success}\n" || printf "${bold}Starting dropbear SSHD ${failed}\n"
    ;;
esac
