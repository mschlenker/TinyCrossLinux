
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=busybox
PKGVERSION=1.22.1

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2 ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2 \
	http://busybox.net/downloads/${PKGNAME}-${PKGVERSION}.tar.bz2

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvjf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2

# Build and install

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
ARCH="${CLFS_ARCH}" make defconfig
sed -i 's/\(CONFIG_\)\(.*\)\(INETD\)\(.*\)=y/# \1\2\3\4 is not set/g' .config
sed -i 's/\(CONFIG_IFPLUGD\)=y/# \1 is not set/' .config
ARCH="${CLFS_ARCH}" CROSS_COMPILE="${CLFS_TARGET}-" make || exit 1
ARCH="${CLFS_ARCH}" CROSS_COMPILE="${CLFS_TARGET}-" make  \
  CONFIG_PREFIX="${CLFS}/targetfs" install || exit 1 
ln -sf bin/busybox ${CLFS}/targetfs/init
chmod u+s ${CLFS}/targetfs/bin/busybox

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

