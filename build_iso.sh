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

# Copy libraries
echo ${CLFS}/cross-tools/${CLFS_TARGET} ${CLFS}/targetfs 
tar -C  ${CLFS}/cross-tools/${CLFS_TARGET} --exclude='*.a' --exclude='*.la' \
	--exclude='pkgconfig' --exclude='ldscripts' \
	-cvf - lib lib64 | tar -C ${CLFS}/targetfs -xf - 

# Create the initramfs
( cd ${CLFS}/targetfs ; find . | grep -v '^\./boot' | cpio -o -H newc | gzip -c > ../iso-bios/boot/system/initrd.gz )

# Copy the kernel
kern=` ls ${CLFS}/targetfs/boot/vmlinuz* | tail -n1 ` 
install -m 0644 "$kern" ${CLFS}/iso-bios/boot/system/vmlinuz

# Copy the bootloader
for f in bios/com32/menu/menu.c32 bios/com32/menu/vesamenu.c32 \
	bios/com32/modules/ifcpu64.c32 bios/com32/modules/ifcpu.c32 \
	bios/com32/modules/reboot.c32 bios/com32/chain/chain.c32 \
	bios/com32/elflink/ldlinux/ldlinux.c32 bios/com32/libutil/libutil.c32 \
	bios/com32/cmenu/libmenu/libmenu.c32 bios/com32/lib/libcom32.c32 \
	bios/com32/lua/src/liblua.c32 bios/com32/gpllib/libgpl.c32 \
	bios/core/isolinux.bin ; do
	install -m 0644 ${CLFS}/hosttools/share/syslinux/$f ${CLFS}/iso-bios/boot/isolinux/
done

for f in isolinux.cfg help.txt ; do
	install -m 0644 patches/${f} ${CLFS}/iso-bios/boot/isolinux/
done

# Build the ISO for BIOS
${CLFS}/hosttools/bin/xorriso -as mkisofs -joliet -graft-points \
	-c boot/isolinux/boot.cat -b boot/isolinux/isolinux.bin \
	-no-emul-boot -boot-info-table -boot-load-size 4 \
	-isohybrid-mbr ${CLFS}/hosttools/share/syslinux/bios/mbr/isohdpfx.bin \
	-V TINYCROSS -o ${CLFS}/tiny-cross-bios.iso -r ${CLFS}/iso-bios
sync 

# Exit - do not build EFI bootable ISO yet
# exit 0

# Calculate size of the system dir
efisize=` du ${CLFS}/iso-bios/boot/system | tail -n1 | awk '{print $1}' `
efisize=` expr $efisize '*' 105 / 100 + 1000 ` 
efiblocks=` expr $efisize / 4096 + 1 `

# Create and format EFI image
dd if=/dev/zero bs=4M count=$efiblocks of=${CLFS}/iso-uefi/boot/efi/efi.img 
freeloop=` losetup -f ` 
losetup $freeloop ${CLFS}/iso-uefi/boot/efi/efi.img 
mkfs.msdos -n EFIBOOT $freeloop
mount -t vfat -o noatime $freeloop ${CLFS}/tmp/efi 
# Copy files to EFI image
cp -v ${CLFS}/iso-bios/boot/system/vmlinuz ${CLFS}/tmp/efi/VMLINUZ.EFI
cp -v ${CLFS}/iso-bios/boot/system/initrd.gz ${CLFS}/tmp/efi/INITRD.GZ
mkdir -p ${CLFS}/tmp/efi/EFI/BOOT
mkdir -p ${CLFS}/tmp/efi/loader/entries
cp -v ${CLFS}/hosttools/lib/gummiboot/gummibootx64.efi ${CLFS}/tmp/efi/EFI/BOOT/BOOTX64.EFI
cp -v patches/loader.conf ${CLFS}/tmp/efi/loader/loader.conf
cp -v patches/tiny.conf ${CLFS}/tmp/efi/loader/entries/00tinycross.conf
sync 
sleep 3
umount ${CLFS}/tmp/efi

losetup -d $freeloop
# We need a dummy isolinux, otherwise ISO will not boot
install -m 0644 ${CLFS}/hosttools/share/syslinux/bios/core/isolinux.bin ${CLFS}/iso-uefi/boot/isolinux

# Build ISO containing the EFI image
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

