
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=bash
PKGVERSION=4.3.30

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	ftp://ftp.gnu.org/gnu/bash/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

workdir=`pwd `
mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz

# Patch

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
# cat "${workdir}/patches/bash-4.3-upstream_fixes-1.patch" | patch -p1

# Build and install

./configure --prefix=/usr --sysconfdir=/etc --host=${CLFS_TARGET} --without-bash-malloc
make -j 4
make install DESTDIR=${CLFS}/targetfs
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/targetfs/usr/bin/bash
ln -sf /usr/bin/bash ${CLFS}/targetfs/bin/bash

# Clean up

cd ${CLFS}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
