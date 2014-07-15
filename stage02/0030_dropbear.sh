#!/bin/bash

source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=dropbear
PKGVERSION=2014.63

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2 ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2 \
	https://matt.ucc.asn.au/dropbear/${PKGNAME}-${PKGVERSION}.tar.bz2

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar -C ${CLFS}/build/${PKGNAME}-${PKGVERSION} -xvjf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2

# Build and install

workdir=` pwd ` 
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
sed -i 's/.*mandir.*//g' Makefile.in
CC="${CC} -Os" ./configure --prefix=/usr --host=${CLFS_TARGET}
make MULTI=1 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" || exit 1
make MULTI=1 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" install DESTDIR=${CLFS}/targetfs || exit 1
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/targetfs/usr/bin/dropbearmulti
install -dv ${CLFS}/targetfs/etc/dropbear
install -m 0755 ${workdir}/patches/etc-rc.d-0050-dropbear.sh ${CLFS}/targetfs/etc/rc.d/0050-dropbear.sh

# Clean up

cd ..
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

