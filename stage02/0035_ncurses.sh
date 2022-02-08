
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=ncurses
PKGVERSION=6.3

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	ftp://ftp.gnu.org/gnu/ncurses/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz

# Build and install
export CPPFLAGS=-P # Work around a broken mawk
export CFLAGS="-I${CLFS}/cross-tools/${CLFS_TARGET}/include/kernel"
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
./configure --prefix=/ --without-debug --without-ada --enable-overwrite --enable-widec --host=${CLFS_ARCH} --without-cxx || exit 1
make -j $( grep -c processor /proc/cpuinfo ) || exit 1
make install DESTDIR=${CLFS}/cross-tools/${CLFS_TARGET} || exit 1
make install DESTDIR=${CLFS}/targetfs

# Clean up

cd ${CLFS}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

