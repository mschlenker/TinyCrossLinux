#!/bin/bash

# A complete dropbear installation should be present for the host to be able
# to create or convert keys that are included in the initramfs.

source stage0n_variables

PKGNAME=qemu-host
PKGVERSION=2.2.0

# Download:

[ -f ${SRCDIR}/qemu-${PKGVERSION}.tar.bz2 ] || wget -O ${SRCDIR}/qemu-${PKGVERSION}.tar.bz2 \
	http://wiki.qemu-project.org/download/qemu-${PKGVERSION}.tar.bz2
[ -f ${SRCDIR}/qemu-2.1.2-virtfs-proxy-helper.patch ] || wget -O ${SRCDIR}/qemu-2.1.2-virtfs-proxy-helper.patch \
	http://distfiles.lesslinux.org/qemu-2.1.2-virtfs-proxy-helper.patch

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar -C ${CLFS}/build/${PKGNAME}-${PKGVERSION} -xvjf ${SRCDIR}/qemu-${PKGVERSION}.tar.bz2
( cd  ${CLFS}/build/${PKGNAME}-${PKGVERSION}/qemu-${PKGVERSION} ; cat ${SRCDIR}/qemu-2.1.2-virtfs-proxy-helper.patch | patch -p 1 )

# Build and install

workdir=` pwd ` 
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/qemu-${PKGVERSION}
./configure --prefix=${CLFS}/hosttools \
	--docdir=/usr/share/doc/${PKGNAME}-${PKGVERSION} \
	--disable-bsd-user --disable-linux-user \
	--target-list=x86_64-softmmu,i386-softmmu \
	--disable-sdl --disable-vnc --audio-drv-list=alsa --disable-gtk \
	--disable-smartcard-nss

make -j ` grep -c processor /proc/cpuinfo `  || exit 1
make install || exit 1

# Clean up

cd ..
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/qemu-${PKGVERSION}
