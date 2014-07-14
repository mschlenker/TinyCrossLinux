#!/bin/sh

source stage0n_variables

mkdir -p ${CLFS}/iso/boot/isolinux
mkdir -p ${CLFS}/iso/boot/system

# Create the initramfs
( cd ${CLFS}/targetfs ; find . | cpio -o -H newc | gzip -c > ../iso/boot/system/initrd.gz )

# copy the kernel
kern=` ls ${CLFS}/targetfs/boot/vmlinuz* | tail -n1 ` 
install -m 0644 "$kern" ${CLFS}/iso/boot/system/vmlinuz

# copy the bootloader

