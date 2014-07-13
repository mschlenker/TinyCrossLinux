
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=kvm
PKGVERSION=20140617

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
make WERROR=0 CROSS_COMPILE=x86_64-linux-musl-
install -m 0755 lkvm ${CLFS}/targetfs/usr/bin || exit 1 

# Clean up

cd ${CLFS}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/linux-kvm

