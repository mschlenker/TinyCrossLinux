#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH

case $1 in
    start)
	kversion=` uname -r `
	alreadyloaded=""
	    printf "$bold===> Loading PCI drivers $normal\n"
	    for i in /sys/bus/pci/devices/* ; do 
		prod=` cat $i/device | sed 's/0x//' `
		vend=` cat $i/vendor | sed 's/0x//' `
		for modname in \
			` grep -Ei 'alias pci:v0000'${vend}d0000${prod}'sv|alias pci:v\*d0000'${prod}'sv|alias pci:v0000'${vend}'d\*sv' /lib/modules/${kversion}/modules.alias | awk '{print $3}' | uniq ` ; do
			if echo "$alreadyloaded" | grep -qv "$modname " ; then
			    modprobe -q -b $modname
			    alreadyloaded="$alreadyloaded $modname "
		        fi
		done
	    done
	    for modname in \
		    ` cat /lib/modules/${kversion}/modules.alias |  grep -Ei 'alias pci:v\*d\*sv' | awk '{print $3}' | uniq ` ; do
			if echo "$alreadyloaded" | grep -qv "$modname " ; then
			    modprobe -q -b $modname
			    alreadyloaded="$alreadyloaded $modname "
			fi
	    done
	    printf "$bold===> Loading USB drivers $normal\n"
	    for i in /sys/bus/usb/devices/* ; do 
		if [ -f $i/idVendor ] ; then
		    prod=` cat $i/idProduct `
		    vend=` cat $i/idVendor `
		    for modname in \
			   ` grep -Ei 'alias usb:v'${vend}p${prod}'d|alias usb:v\*p'${prod}'d|alias usb:v'${vend}'p\*d' /lib/modules/${kversion}/modules.alias | awk '{print $3}' | uniq ` ; do
			    if echo "$alreadyloaded" | grep -qv "$modname " ; then
				modprobe -q -b $modname
				alreadyloaded="$alreadyloaded $modname "
		            fi
		    done
		fi
	    done 
	    for modname in \
		    ` grep -Ei 'alias usb:v\*p\*d' /lib/modules/${kversion}/modules.alias | awk '{print $3}' | uniq ` ; do
		    if echo "$alreadyloaded" | grep -qv "$modname " ; then
			modprobe -q -b $modname
			alreadyloaded="$alreadyloaded $modname "
		    fi
	    done   
	    mountpoint -q /proc/bus/usb || mount -t usbfs usbfs /proc/bus/usb
	    if cat /sys/hypervisor/properties/capabilities | grep -q xen ; then
		printf "$bold===> Loading Xen specific drivers $normal \n"
		modprobe -q -b xen-blkfront
		modprobe -q -b xen-netfront
	    fi
	    mdev -s
	    for dir in $defmods ; do
		umount /lib/modules/${kversion}/kernel/${dir}
	    done
    ;;
esac