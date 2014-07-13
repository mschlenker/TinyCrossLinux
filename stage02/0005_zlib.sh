
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=zlib
PKGVERSION=1.2.8

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz \
	http://downloads.sourceforge.net/project/libpng/zlib/${PKGVERSION}/${PKGNAME}-${PKGVERSION}.tar.xz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvJf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz

# Build and install

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
CFLAGS="-Os" ./configure --shared
make || exit 1
make prefix=${CLFS}/cross-tools/${CLFS_TARGET} install || exit 1

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

