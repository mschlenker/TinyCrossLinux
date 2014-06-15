
source stage01_variables

PKGNAME=linux-headers
PKGVERSION=3.15 

# Download

[ -f ${SRCDIR}/linux-${PKGVERSION}.tar.xz ] || wget -O ${SRCDIR}/linux-${PKGVERSION}.tar.xz \
	https://www.kernel.org/pub/linux/kernel/v3.x/linux-${PKGVERSION}.tar.xz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvJf ${SRCDIR}/linux-${PKGVERSION}.tar.xz

# Build and install

cd linux-${PKGVERSION}
make mrproper
make ARCH=${CLFS_ARCH} headers_check
make ARCH=${CLFS_ARCH} INSTALL_HDR_PATH=${CLFS}/cross-tools/${CLFS_TARGET} headers_install

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/linux-${PKGVERSION}

