
source stage0n_variables
source stage01_variables

PKGNAME=musl
PKGVERSION=1.1.2

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	http://www.musl-libc.org/releases/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz
cd ${PKGNAME}-${PKGVERSION}
sed -i 's%/dev/null/wtmp%/var/log/wtmp%g' include/paths.h
sed -i 's%/dev/null/utmp%/var/run/utmp%g' include/paths.h

# Build and install

CFLAGS=-fno-toplevel-reorder \
CC=${CLFS_TARGET}-gcc \
./configure \
  --prefix=/ \
  --target=${CLFS_TARGET}
CFLAGS=-fno-toplevel-reorder CC=${CLFS_TARGET}-gcc make || exit 1
DESTDIR=${CLFS}/cross-tools/${CLFS_TARGET} make install || exit 1
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/cross-tools/${CLFS_TARGET}/lib/*.so*
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/cross-tools/${CLFS_TARGET}/lib64/*.so*

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

