#!/bin/sh

me=` id -u `
if [ "$me" -gt 0 ] ; then
	echo 'Please run this script with root privileges!'
fi

source stage0n_variables

case ${CLFS_ARCH} in
	x86)
		echo '---> Currently only supported on x86, continuing'
	;;
	*)
		echo '***> Currently only supported on x86, exiting'
		exit 0
	;;
esac

for bin in parted kpartx dmsetup mkfs.ext4 mkfs.msdos ; do
	if which $bin ; then
		echo "$bin found"
	else
		echo "$bin"' is missing. Exiting!'
		exit 1
	fi
done
 
[ -z "$SYSTEMSIZE" ] && SYSTEMSIZE=224
[ -z "$EFISIZE" ] && EFISIZE=32

# Remove old build directories, create new ones:

rm -rf "${CLFS}/vmdk-system.mnt"
rm -rf "${CLFS}/vmdk-boot.mnt"
rm -rf "${CLFS}/vmdk-full.img"

mkdir -p "${CLFS}/vmdk-boot.mnt"
mkdir -p "${CLFS}/vmdk-system.mnt"

echo '===> Preparing the target file system:'
# This copies all shared objects from the lib and lib64 directories to the targetfs.
# Note that even unused libraries might be copied. To ultimately safe place it might 
# make more sense to run ldd on the binaries first and just copy required libraries.

dd if=/dev/zero bs=1M count=1 seek=$(( $SYSTEMSIZE  + $EFISIZE - 1 )) of="${CLFS}/vmdk-full.img"
freeloop=`losetup -f ` 
losetup $freeloop "${CLFS}/vmdk-full.img"
parted -s $freeloop mklabel gpt
parted -s $freeloop mkpart boot 1M ${EFISIZE}M 
parted -s $freeloop mkpart system ${EFISIZE}M 100%
parted -s $freeloop set 1 boot on
parted -s $freeloop set 1 legacy_boot on
kpartx -a $freeloop 
sync
sleep 2
mkfs.ext4 /dev/mapper/${freeloop#/dev/}p2
mkfs.msdos /dev/mapper/${freeloop#/dev/}p1
mount /dev/mapper/${freeloop#/dev/}p2 "${CLFS}/vmdk-system.mnt"
mount /dev/mapper/${freeloop#/dev/}p1 "${CLFS}/vmdk-boot.mnt"

echo ${CLFS}/cross-tools/${CLFS_TARGET} ${CLFS}/targetfs 
tar -C  ${CLFS}/cross-tools/${CLFS_TARGET} --exclude='*.a' --exclude='*.la' \
	--exclude='pkgconfig' --exclude='ldscripts' \
	-cvf - lib lib64 | tar -C  "${CLFS}/targetfs" -xf - 
tar -C ${CLFS}/targetfs -cvf - . | tar -C "${CLFS}/vmdk-system.mnt" -xf -
for d in dev proc sys tmp var ; do
	mkdir "${CLFS}/vmdk-system.mnt/${d}"
done

# You might specify a certain kernel to use a boot kernel by defining the environment
# variable TINYKERNEL. If you do not do so, the last kernel in the list of installed 
# kernels is used.
if [ -n "$TINYKERNEL" -a -f "$TINYKERNEL" ] ; then 
	kern="$TINYKERNEL"
else
	kern=` ls ${CLFS}/targetfs/boot/vmlinuz* | tail -n1 ` 
fi 
mkdir -p "${CLFS}/vmdk-boot.mnt/isolinux/"
install -m 0644 "$kern" "${CLFS}/vmdk-boot.mnt/VMLINUZ.EFI"

# Copy the bootloader for BIOS. This also copies modules for menus ans graphical menus
# as well for chainloading bootloaders on harddisks. I you want the bare minimum, start
# with ldlinux.c32, libutil.c32, libcom32.c32 and libgpl.c32:
for f in bios/com32/menu/menu.c32 bios/com32/menu/vesamenu.c32 \
	bios/com32/modules/ifcpu64.c32 bios/com32/modules/ifcpu.c32 \
	bios/com32/modules/reboot.c32 bios/com32/chain/chain.c32 \
	bios/com32/elflink/ldlinux/ldlinux.c32 bios/com32/libutil/libutil.c32 \
	bios/com32/cmenu/libmenu/libmenu.c32 bios/com32/lib/libcom32.c32 \
	bios/com32/lua/src/liblua.c32 bios/com32/gpllib/libgpl.c32 ; do
	install -m 0644 ${CLFS}/hosttools/share/syslinux/$f "${CLFS}/vmdk-boot.mnt/isolinux/"
done

# Copy the configuration file for isolinux as well as the help.txt that is displaed
# before the prompt boot: - see syslinux' wiki for details:
for f in syslinux.cfg help.txt ; do
	install -m 0644 patches/${f} "${CLFS}/vmdk-boot.mnt/isolinux/"
done
cp -v "${CLFS}/vmdk-boot.mnt/isolinux/syslinux.cfg" "${CLFS}/vmdk-boot.mnt/isolinux/extlinux.conf"
"${CLFS}/hosttools/share/syslinux/bios/extlinux/extlinux" --install "${CLFS}/vmdk-boot.mnt/isolinux/"

echo '===> Populating the boot media for UEFI:'

# Populate the efi partition, the efi boot image will contain the following files:
#
# /EFI/BOOT/BOOTX64.EFI
# /loader/loader.conf
# /loader/entries/00tinycross.conf
# /VMLINUZ.EFI
# /INITRD.GZ

mkdir -p "${CLFS}/vmdk-boot.mnt/EFI/BOOT"
mkdir -p "${CLFS}/vmdk-boot.mnt/loader/entries"

cp -v ${CLFS}/hosttools/lib/gummiboot/gummibootx64.efi "${CLFS}/vmdk-boot.mnt/EFI/BOOT/BOOTX64.EFI"
cp -v patches/loader.conf "${CLFS}/vmdk-boot.mnt/loader/loader.conf"
cp -v patches/tiny-hdd.conf "${CLFS}/vmdk-boot.mnt/loader/entries/00tinycross.conf"

# At this point you can run a script that copies additional files to the root filesystem and the boot partition:
#
# ${CLFS}/vmdk-boot.mnt
# ${CLFS}/vmdk-system.mnt
 
sync
umount /dev/mapper/${freeloop#/dev/}p2
umount /dev/mapper/${freeloop#/dev/}p1
sleep 2
dmsetup remove /dev/mapper/${freeloop#/dev/}p2
dmsetup remove /dev/mapper/${freeloop#/dev/}p1
dd if="${CLFS}/hosttools/share/syslinux/bios/mbr/gptmbr.bin" of=${freeloop} conv=notrunc
sync
losetup -d $freeloop

 