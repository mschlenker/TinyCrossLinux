
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=ncurses
PKGVERSION=5.9

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	ftp://ftp.gnu.org/gnu/ncurses/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz

# Build and install

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
./configure --prefix=/ --without-debug --without-ada --enable-overwrite --host=${CLFS_ARCH} --without-cxx
make install DESTDIR=${CLFS}/cross-tools/${CLFS_TARGET}

# Clean up

cd ${CLFS}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

