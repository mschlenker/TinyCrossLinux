
source stage0n_variables

PKGNAME=syslinux
PKGVERSION=6.03-pre19

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
 
[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz \
	https://www.kernel.org/pub/linux/utils/boot/syslinux/Testing/6.03/${PKGNAME}-${PKGVERSION}.tar.xz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar -C ${CLFS}/build/${PKGNAME}-${PKGVERSION} -xvJf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.xz || exit 1

# Build and install

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
make clean
make || exit 1
mkdir -p ${CLFS}/hosttools/share/syslinux
tar -C ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION} -cvf - . | tar -C ${CLFS}/hosttools/share/syslinux -xf - 

# Clean up

cd ..
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
