#!/bin/sh

source stage0n_variables

mkdir -p ${CLFS}/iso/boot/isolinux
mkdir -p ${CLFS}/iso/boot/system

# Copy libraries
echo ${CLFS}/cross-tools/${CLFS_TARGET} ${CLFS}/targetfs 
tar -C  ${CLFS}/cross-tools/${CLFS_TARGET} --exclude='*.a' --exclude='pkgconfig' -cvf - lib | tar -C ${CLFS}/targetfs -xf - 

# Create the initramfs
( cd ${CLFS}/targetfs ; find . | cpio -o -H newc | gzip -c > ../iso/boot/system/initrd.gz )

# copy the kernel
kern=` ls ${CLFS}/targetfs/boot/vmlinuz* | tail -n1 ` 
install -m 0644 "$kern" ${CLFS}/iso/boot/system/vmlinuz

# copy the bootloader
for f in bios/com32/menu/menu.c32 bios/com32/menu/vesamenu.c32 \
	bios/com32/modules/ifcpu64.c32 bios/com32/modules/ifcpu.c32 \
	bios/com32/modules/reboot.c32 bios/com32/chain/chain.c32 \
	bios/com32/elflink/ldlinux/ldlinux.c32 bios/com32/libutil/libutil.c32 \
	bios/com32/cmenu/libmenu/libmenu.c32 bios/com32/lib/libcom32.c32 \
	bios/com32/lua/src/liblua.c32 bios/com32/gpllib/libgpl.c32 \
	bios/core/isolinux.bin ; do
	install -m 0644 ${CLFS}/hosttools/share/syslinux/$f ${CLFS}/iso/boot/isolinux/
done

install -m 0644 patches/isolinux.cfg ${CLFS}/iso/boot/isolinux/

${CLFS}/hosttools/bin/xorriso -as mkisofs -joliet -graft-points \
	-c boot/isolinux/boot.cat -b boot/isolinux/isolinux.bin \
	-no-emul-boot -boot-info-table -boot-load-size 4 \
	-isohybrid-mbr ${CLFS}/hosttools/share/syslinux/bios/mbr/isohdpfx.bin \
	-V CLFS -o ${CLFS}/clfs.iso -r ${CLFS}/iso
