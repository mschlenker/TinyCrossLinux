#!/bin/sh

me=` id -u `
if [ "$me" -gt 0 ] ; then
	echo 'Please run this script with root privileges!'
fi

source stage0n_variables

mkdir -p ${CLFS}/iso-bios/boot/isolinux
mkdir -p ${CLFS}/iso-bios/boot/system
mkdir -p ${CLFS}/iso-uefi/boot/efi
mkdir -p ${CLFS}/iso-uefi/boot/isolinux
mkdir -p ${CLFS}/tmp/efi

echo '===> Preparing the target file system:'
# This copies all shared objects from the lib and lib64 directories to the targetfs.
# Note that even unused libraries might be copied. To ultimately safe place it might 
# make more sense to run ldd on the binaries first and just copy required libraries.

echo ${CLFS}/cross-tools/${CLFS_TARGET} ${CLFS}/targetfs 
tar -C  ${CLFS}/cross-tools/${CLFS_TARGET} --exclude='*.a' --exclude='*.la' \
	--exclude='pkgconfig' --exclude='ldscripts' \
	-cvf - lib lib64 | tar -C ${CLFS}/targetfs -xf - 

echo '===> Populating the boot media for BIOS:'
# The initramfs is just a (compressed) CPIO archive. Since we do not need the kernel
# that resides in /boot we just remove the boot directory from the file list given to
# cpio. 
( cd ${CLFS}/targetfs ; find . | grep -v '^\./boot' | \
	cpio -o -H newc | gzip -c > ../iso-bios/boot/system/initrd.gz )

# You might specify a certain kernel to use a boot kernel by defining the environment
# variable TINYKERNEL. If you do not do so, the last kernel in the list of installed 
# kernels is used.
if [ -n "$TINYKERNEL" -a -f "$TINYKERNEL" ] ; then 
	kern="$TINYKERNEL"
else
	kern=` ls ${CLFS}/targetfs/boot/vmlinuz* | tail -n1 ` 
fi 
install -m 0644 "$kern" ${CLFS}/iso-bios/boot/system/vmlinuz

# Copy the bootloader for BIOS. This also copies modules for menus ans graphical menus
# as well for chainloading bootloaders on harddisks. I you want the bare minimum, start
# with ldlinux.c32, libutil.c32, libcom32.c32, libgpl.c32 and isolinux.bin:
for f in bios/com32/menu/menu.c32 bios/com32/menu/vesamenu.c32 \
	bios/com32/modules/ifcpu64.c32 bios/com32/modules/ifcpu.c32 \
	bios/com32/modules/reboot.c32 bios/com32/chain/chain.c32 \
	bios/com32/elflink/ldlinux/ldlinux.c32 bios/com32/libutil/libutil.c32 \
	bios/com32/cmenu/libmenu/libmenu.c32 bios/com32/lib/libcom32.c32 \
	bios/com32/lua/src/liblua.c32 bios/com32/gpllib/libgpl.c32 \
	bios/core/isolinux.bin ; do
	install -m 0644 ${CLFS}/hosttools/share/syslinux/$f ${CLFS}/iso-bios/boot/isolinux/
done

# Copy the configuration file for isolinux as well as the help.txt that is displaed
# before the prompt boot: - see syslinux' wiki for details:
for f in isolinux.cfg help.txt ; do
	install -m 0644 patches/${f} ${CLFS}/iso-bios/boot/isolinux/
done

echo '===> Populating the boot media for UEFI:'
# UEFI uses a FAT16/32 formatted filesystem image as boot media. Since we are using
# gummiboot as bootloader the kernel and initramfs have to be placed on this FAT image.
# GRUB2 allows to have the kernel and initrd and even the configuration on a separate 
# media - e.g. the ISO containing the FAT image, thus allowing smaller ISOs with both
# boot loaders. For educational purposes using gummiboot is better.
#
# Calculate a reasonable size for the boot image:
efisize=` du ${CLFS}/iso-bios/boot/system | tail -n1 | awk '{print $1}' `
efisize=` expr $efisize '*' 105 / 100 + 1000 ` 
efiblocks=` expr $efisize / 4096 + 1 `

# Now use dd to create an empty file and format this file as a FAT32 hard disk
dd if=/dev/zero bs=4M count=$efiblocks of=${CLFS}/iso-uefi/boot/efi/efi.img 
freeloop=` losetup -f ` 
losetup $freeloop ${CLFS}/iso-uefi/boot/efi/efi.img || exit 1
mkfs.msdos -n EFIBOOT $freeloop || exit 1 
# Mount and populate the efi.img, the efi boot image will contain the following files:
#
# /EFI/BOOT/BOOTX64.EFI
# /loader/loader.conf
# /loader/entries/00tinycross.conf
# /VMLINUZ.EFI
# /INITRD.GZ

mount -t vfat -o noatime $freeloop ${CLFS}/tmp/efi || exit 1
cp -v ${CLFS}/iso-bios/boot/system/vmlinuz ${CLFS}/tmp/efi/VMLINUZ.EFI
cp -v ${CLFS}/iso-bios/boot/system/initrd.gz ${CLFS}/tmp/efi/INITRD.GZ
mkdir -p ${CLFS}/tmp/efi/EFI/BOOT
mkdir -p ${CLFS}/tmp/efi/loader/entries
cp -v ${CLFS}/hosttools/lib/gummiboot/gummibootx64.efi ${CLFS}/tmp/efi/EFI/BOOT/BOOTX64.EFI
cp -v patches/loader.conf ${CLFS}/tmp/efi/loader/loader.conf
cp -v patches/tiny.conf ${CLFS}/tmp/efi/loader/entries/00tinycross.conf
# At this point you can run a script that copies additional files to:
# ${CLFS}/tmp/efi/
# ${CLFS}/iso-bios/
# ${CLFS}/iso-bios/
# Specify a script that does the copying in the environment variable TINYADDISOFILES
[ -n "$TINYADDISOFILES" -a -x "$TINYADDISOFILES" ] && "$TINYADDISOFILES"
sync 
sleep 3
umount ${CLFS}/tmp/efi || exit 1
losetup -d $freeloop || exit 1 
# We need a dummy isolinux loader as first boot entry, otherwise the ISO will not boot
# I do not know if this is a bug in xorriso or in common UEFI firmware
install -m 0644 ${CLFS}/hosttools/share/syslinux/bios/core/isolinux.bin ${CLFS}/iso-uefi/boot/isolinux

echo '===> Building the boot media for BIOS:'
${CLFS}/hosttools/bin/xorriso -as mkisofs -joliet -graft-points \
	-c boot/isolinux/boot.cat -b boot/isolinux/isolinux.bin \
	-no-emul-boot -boot-info-table -boot-load-size 4 \
	-isohybrid-mbr ${CLFS}/hosttools/share/syslinux/bios/mbr/isohdpfx.bin \
	-V TINYCROSS -o ${CLFS}/tiny-cross-bios.iso -r ${CLFS}/iso-bios
sync 

echo '===> Building the boot media for UEFI:'
${CLFS}/hosttools/bin/xorriso -as mkisofs -joliet -graft-points  \
	-c boot/isolinux/boot.cat -b boot/isolinux/isolinux.bin \
	-no-emul-boot -boot-info-table -boot-load-size 4 \
	-isohybrid-mbr ${CLFS}/hosttools/share/syslinux/bios/mbr/isohdpfx.bin \
	-eltorito-alt-boot \
	-e boot/efi/efi.img -no-emul-boot \
	-isohybrid-gpt-basdat \
	-V TINYCROSS -o ${CLFS}/tiny-cross-uefi.iso -r ${CLFS}/iso-uefi

#${CLFS}/hosttools/bin/xorriso -as mkisofs -joliet -graft-points  \
#	-e boot/efi/efi.img -no-emul-boot \
#	-isohybrid-gpt-basdat \
#	-V CLFS -o ${CLFS}/tiny-cross-uefi.iso -r ${CLFS}/iso-uefi

