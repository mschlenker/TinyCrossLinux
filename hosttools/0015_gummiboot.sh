
source stage0n_variables

PKGNAME=gummiboot
PKGVERSION=48

case ${CLFS_ARCH} in
	x86)
		echo '---> Only needed on x86, continuing'
	;;
	*)
		echo '***> Only needed on x86, exiting'
		exit 0
	;;
esac

# Download
 
[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	http://cgit.freedesktop.org/gummiboot/snapshot/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar -C ${CLFS}/build/${PKGNAME}-${PKGVERSION} -xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz || exit 1

# Build and install

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
bash autogen.sh
./configure --prefix=${CLFS}/hosttools
make || exit 1
make install || exit 1

# Clean up

cd ..
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
