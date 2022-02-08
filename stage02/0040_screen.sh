
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=screen
PKGVERSION=4.9.0

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	ftp://ftp.gnu.org/gnu/screen/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

workdir=`pwd `
mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz

# Patch

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
# install -m 0755 "${workdir}/patches/screen-4.2.1.configure" configure

# Build and install

./configure --prefix=/usr --sysconfdir=/etc --without-debug --without-ada --enable-overwrite --host=${CLFS_TARGET} --without-cxx
make clean
make -j $( grep -c processor /proc/cpuinfo )
make install DESTDIR=${CLFS}/targetfs
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/targetfs/usr/bin/screen

# Clean up

cd ${CLFS}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
