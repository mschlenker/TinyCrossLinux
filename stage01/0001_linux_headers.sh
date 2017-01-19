
source stage0n_variables
source stage01_variables

PKGNAME=linux-headers
PKGVERSION=4.7.5
MAJOR=4.7

# Download

[ -f ${SRCDIR}/linux-${MAJOR}.tar.xz ] || wget -O ${SRCDIR}/linux-${MAJOR}.tar.xz \
	https://www.kernel.org/pub/linux/kernel/v4.x/linux-${MAJOR}.tar.xz
[ -f ${SRCDIR}/patch-${PKGVERSION}.xz ] || wget -O ${SRCDIR}/patch-${PKGVERSION}.xz \
	https://www.kernel.org/pub/linux/kernel/v4.x/patch-${PKGVERSION}.xz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvJf ${SRCDIR}/linux-${MAJOR}.tar.xz || exit 1
cd linux-${MAJOR}
unxz -c ${SRCDIR}/patch-${PKGVERSION}.xz | patch -p1
cd ..
mv linux-${MAJOR} linux-${PKGVERSION}

# Build and install

cd linux-${PKGVERSION}
make mrproper || exit 1
make ARCH=${CLFS_ARCH} headers_check
mkdir -p ${CLFS}/cross-tools/${CLFS_TARGET} || exit 1
make ARCH=${CLFS_ARCH} INSTALL_HDR_PATH=${CLFS}/cross-tools/${CLFS_TARGET} headers_install || exit 1

# Clean up

cd ..
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/linux-${PKGVERSION}
