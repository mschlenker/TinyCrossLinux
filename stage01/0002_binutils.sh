
source stage01_variables

PKGNAME=binutils
PKGVERSION=2.24

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2 ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2 \
	http://ftp.gnu.org/gnu/binutils/${PKGNAME}-${PKGVERSION}.tar.bz2

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvjf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2

# Build and install

mkdir ${PKGNAME}-build
cd ${PKGNAME}-build
../${PKGNAME}-${PKGVERSION}/configure \
   --prefix=${CLFS}/cross-tools \
   --target=${CLFS_TARGET} \
   --with-sysroot=${CLFS}/cross-tools/${CLFS_TARGET} \
   --disable-nls \
   --disable-multilib
make configure-host
make || exit 1
make install || exit 1

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

