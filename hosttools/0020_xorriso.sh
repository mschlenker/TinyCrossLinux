
source stage0n_variables

PKGNAME=xorriso
PKGVERSION=1.5.4

# Download
 
[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	http://www.gnu.org/software/xorriso/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar -C ${CLFS}/build/${PKGNAME}-${PKGVERSION} -xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz || exit 1

# Build and install

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
./configure --prefix=${CLFS}/hosttools --enable-static
make -j 4 || exit 1
make install || exit 1

# Clean up

cd ..
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
