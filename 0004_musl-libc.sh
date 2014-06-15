
source stage01_variables

PKGNAME=musl
PKGVERSION=1.1.2

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz

# Build and install

cd ${PKGNAME}-${PKGVERSION}
CFLAGS=-fno-toplevel-reorder \
CC=${CLFS_TARGET}-gcc \
./configure \
  --prefix=/ \
  --target=${CLFS_TARGET}
CFLAGS=-fno-toplevel-reorder CC=${CLFS_TARGET}-gcc make
DESTDIR=${CLFS}/cross-tools/${CLFS_TARGET} make install

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

