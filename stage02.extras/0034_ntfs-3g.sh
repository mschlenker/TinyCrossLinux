
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=ntfs-3g_ntfsprogs
PKGVERSION=2014.2.15

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tgz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tgz \
	http://tuxera.com/opensource/${PKGNAME}-${PKGVERSION}.tgz 

# Unpack and patch

workdir=` pwd ` 
mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tgz
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
sed -i 's/ linux-uclibc\*/linux-uclibc\* | linux-musl\*/g' ./config.sub

# Build and install

export FUSE_MODULE_CFLAGS="-D_FILE_OFFSET_BITS=64 -I${CLFS}/cross-tools/${CLFS_TARGET}/include/fuse"
export FUSE_MODULE_LIBS='-pthread -lfuse'
./configure --prefix=/usr --host=${CLFS_TARGET} --with-fuse=external --enable-extras=no 
make || exit 1
make prefix=${CLFS}/targetfs install || exit 1
# fix a softlink
rm ${CLFS}/targetfs/lib/libntfs-3g.so
install -m 0755 libntfs-3g/.libs/libntfs-3g.so.85.0.0 ${CLFS}/targetfs/lib/
ln -sf  /lib/libntfs-3g.so.85.0.0 ${CLFS}/targetfs/lib/libntfs-3g.so.85
ln -sf  /lib/libntfs-3g.so.85.0.0 ${CLFS}/targetfs/lib/libntfs-3g.so
rm -rf ${CLFS}/targetfs/usr/share/doc
rm -rf ${CLFS}/targetfs/usr/lib/pkgconfig
rm -rf ${CLFS}/targetfs/usr/lib/libntfs-3g.{,l}a
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/targetfs/usr/bin/ntfs*
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/targetfs/usr/sbin/ntfs*
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/targetfs/lib/libntfs*

# Clean up

cd ${CLFS}/build
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
