#!/bin/ash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
source /etc/rc.subr/colors 
export PATH

case $1 in
    start)
	kversion=` uname -r `
	alreadyloaded=""
	printf "${bold}Generating modules.dep... ${normal}\n"
	( cd /lib/modules/` uname -r `; depmod )
	rm /lib/modules/` uname -r `/modules.dep
	ln -s /lib/modules/` uname -r `/modules.dep.bb /lib/modules/` uname -r `/modules.dep
	printf "${bold}Loading MISC drivers... ${normal}\n"
	for n in jbd zlib_deflate libcrc32c scsi_mod libata ata_generic ata_piix mii libahci \
		ahci usb_common usbcore xhci_hcd uhci_hcd ohci_hcd ohci_pci \
		ehci_hcd ehci_pci pata_ahci yenta_socket  crc_t10dif  sd_mod \
		crct10dif_common crc_t10dif crc_itu_t udf  crc_ccitt crc7 crc32 \
		libphy sunrpc md4 des_generic sha512_generic sha256_generic   ; do
		modprobe $n
	done
	printf "${bold}Loading PCI drivers... ${normal}\n"
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
	printf "${bold}Loading PCI drivers ${success} ${normal}\n"
	printf "${bold}Loading USB drivers... ${normal}\n"
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
	mdev -s
	printf "${bold}Loading USB drivers ${success} ${normal}\n"
	printf "${bold}Loading MISC drivers... ${normal}\n"
	for n in sd_mod sg usb_storage sr_mod iso9660 virtio_net virtio_blk ; do
		modprobe $n
	done
	# Create missing devices:
	mknod /dev/net/tun c 10 200
    ;;
esac
