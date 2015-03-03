#!/bin/bash

source stage0n_variables
source stage01_variables

PKGNAME=musl
PKGVERSION=1.1.6

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	http://www.musl-libc.org/releases/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz
cd ${PKGNAME}-${PKGVERSION}
for f in utmp paths ; do
	sed -i 's%/dev/null/wtmp%/var/log/wtmp%g' include/${f}.h
	sed -i 's%/dev/null/utmp%/var/run/utmp%g' include/${f}.h
done
# Build and install

CFLAGS=-fno-toplevel-reorder \
CC=${CLFS_TARGET}-gcc \
./configure \
  --prefix=/ \
  --target=${CLFS_TARGET}
CFLAGS=-fno-toplevel-reorder CC=${CLFS_TARGET}-gcc make -j $( grep -c processor /proc/cpuinfo ) || exit 1
mkdir -p ${CLFS}/cross-tools/${CLFS_TARGET}/lib
DESTDIR=${CLFS}/cross-tools/${CLFS_TARGET} make install || exit 1
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/cross-tools/${CLFS_TARGET}/lib/*.so*
[ -d ${CLFS}/cross-tools/${CLFS_TARGET}/lib64 ] && \
	${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/cross-tools/${CLFS_TARGET}/lib64/*.so*

# Clean up

cd ${CLFS}/build
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

