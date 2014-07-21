
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=fuse
PKGVERSION=2.9.3

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	http://downloads.sourceforge.net/project/fuse/fuse-2.X/${PKGVERSION}/${PKGNAME}-${PKGVERSION}.tar.gz 

# Unpack and patch

workdir=` pwd ` 
mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
cat ${workdir}/patches/${PKGNAME}-${PKGVERSION}.patch | patch -p1

# Build and install

./configure --prefix=/ --host=${CLFS_TARGET}
make || exit 1
make prefix=${CLFS}/cross-tools/${CLFS_TARGET} install || exit 1
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/cross-tools/${CLFS_TARGET}/lib/libfuse.so*
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/cross-tools/${CLFS_TARGET}/lib/libulockmgr.so*

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
