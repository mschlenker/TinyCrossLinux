#!/bin/bash

# A complete dropbear installation should be present for the host to be able
# to create or convert keys that are included in the initramfs.

source stage0n_variables

PKGNAME=dropbear-host
PKGVERSION=2015.67

# Download:

[ -f ${SRCDIR}/dropbear-${PKGVERSION}.tar.bz2 ] || wget -O ${SRCDIR}/dropbear-${PKGVERSION}.tar.bz2 \
	https://matt.ucc.asn.au/dropbear/dropbear-${PKGVERSION}.tar.bz2

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar -C ${CLFS}/build/${PKGNAME}-${PKGVERSION} -xvjf ${SRCDIR}/dropbear-${PKGVERSION}.tar.bz2

# Build and install

workdir=` pwd ` 
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/dropbear-${PKGVERSION}
sed -i 's/.*mandir.*//g' Makefile.in
./configure --prefix=${CLFS}/hosttools
make MULTI=1 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" || exit 1
make MULTI=1 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" install || exit 1

# Clean up

cd ..
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/dropbear-${PKGVERSION}
