
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=kvm
PKGVERSION=20140617

case ${CLFS_ARCH} in
	x86)
		echo '---> Currently only supported on x86, continuing'
	;;
	*)
		echo '***> Currently only supported on x86, exiting'
		exit 0
	;;
esac

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2 ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2 \
	http://distfiles.lesslinux.org/${PKGNAME}-${PKGVERSION}.tar.bz2

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvjf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2

# Build and install

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/linux-kvm/
make clean
make defconfig
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/linux-kvm/tools/kvm
make clean
make WERROR=0 CROSS_COMPILE=${CLFS_TARGET}-
install -m 0755 lkvm ${CLFS}/targetfs/usr/bin || exit 1 
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/targetfs/usr/bin/lkvm

# Clean up

cd ${CLFS}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/linux-kvm

