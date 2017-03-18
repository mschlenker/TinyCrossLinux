
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=e2fsprogs
PKGVERSION=1.43.4

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz \
	https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v${PKGVERSION}/${PKGNAME}-${PKGVERSION}.tar.xz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz

# Build and install
export CFLAGS="-I${CLFS}/cross-tools/${CLFS_TARGET}/include/kernel"
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
./configure --prefix=/ --host=${CLFS_ARCH} --enable-shared --enable-static 
make || exit 1
make prefix=${CLFS}/cross-tools/${CLFS_TARGET} install || exit 1

# Clean up

# rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

