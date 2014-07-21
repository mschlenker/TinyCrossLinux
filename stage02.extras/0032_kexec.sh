#!/bin/bash

source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=kexec-tools
PKGVERSION=2.0.7

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	https://www.kernel.org/pub/linux/utils/kernel/kexec/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar -C ${CLFS}/build/${PKGNAME}-${PKGVERSION} -xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz

# Build and install
 
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
sed -i 's/ linux-uclibc\*/linux-uclibc\* | linux-musl\*/g' ./config/config.sub
CFLAGS='-Dloff_t=off_t' ./configure --prefix=/usr --host=${CLFS_TARGET}
make || exit 1
mkdir -p ${CLFS}/targetfs/sbin
install -m 0755 build/sbin/kexec ${CLFS}/targetfs/sbin
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/targetfs/sbin/kexec

# Clean up

cd ..
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
