#!/bin/bash

source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=rsync
PKGVERSION=3.1.1

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	http://rsync.samba.org/ftp/rsync/src/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar -C ${CLFS}/build/${PKGNAME}-${PKGVERSION} -xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz

# Build and install

workdir=` pwd ` 
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
./configure --prefix=/usr --host=${CLFS_TARGET}
make || exit 1
make install DESTDIR=${CLFS}/targetfs || exit 1
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/targetfs/usr/bin/rsync

# Clean up

cd ..
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

