#!/bin/ash

# Load a basic SMACK configuration, see 
#
# https://www.kernel.org/doc/Documentation/security/Smack.txt
# https://github.com/smack-team/smack
# https://wiki.tizen.org/wiki/Security:Smack
#
# for some information about this Mandatory Access Control Model
# SMACK has to be explicitly enabled by specifying
#
# security=smack
#
# in the boot command line!

PATH=/bin:/sbin:/usr/bin:/usr/sbin
source /etc/rc.subr/colors 
export PATH

case $1 in
    start)
	enable=0
	for tok in ` cat /proc/cmdline ` ; do
		case $tok in
			security=smack)
				enable=1
			;;
		esac
	done
	if [ "$enable" -gt 0 ] ; then
		printf "${bold}Starting SMACK configuration... ${normal}\n"
		mkdir -p /smack
		mount -t smackfs smackfs /smack
		# Allow both old and new style configuration
		# Old style with single accesses file:
		if [ -f /etc/smack/accesses ] ; then
			smackload < /etc/smack/accesses
			[ -f /etc/smack/cipso ] && cat /etc/smack/cipso > /smack/cipso
		# New style with directory:
		elif [ -d /etc/smack/accesses.d ] ; then
			smackctl apply
		fi 
		for name in netlabel ambient ; do
			[ -f /etc/smack/${name} ] && cat /etc/smack/${name} > /smack/${name}
		done
		smackctl status
	fi
    ;;
    stop)
	mountpoint -q /smack && umount /smack 
    ;;
esac
