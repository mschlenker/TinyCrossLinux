
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=screen
PKGVERSION=4.2.1

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	ftp://ftp.gnu.org/gnu/screen/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz

# Patch

workdir=`pwd `
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
# cat ${workdir}/patches/screen-${PKGVERSION}.cross.patch | patch -p1 
install -m 0755 /tmp/screen-4.2.1/configure configure

# Build and install

./configure --prefix=/ --without-debug --without-ada --enable-overwrite --host=${CLFS_TARGET} --without-cxx
make clean
make
make install DESTDIR=${CLFS}/cross-tools/${CLFS_TARGET}

# Clean up

cd ${CLFS}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
