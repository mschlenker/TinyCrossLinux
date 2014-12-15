
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=kvm
PKGVERSION=20141212

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

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz \
	http://distfiles.lesslinux.org/${PKGNAME}-${PKGVERSION}.tar.xz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvJf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz

# Build and install

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/linux-kvm/
make clean
make defconfig
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/linux-kvm/tools/kvm
make clean
make -j $( grep -c processor /proc/cpuinfo ) WERROR=0 CROSS_COMPILE=${CLFS_TARGET}-
install -m 0755 lkvm ${CLFS}/targetfs/usr/bin || exit 1 
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/targetfs/usr/bin/lkvm

# Clean up

cd ${CLFS}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/linux-kvm

