
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=linux
PKGVERSION=5.15.25
MAJOR=5.15

if which bc ; then
	echo '---> bc found in path continuing...'
else
	echo '+++> bc not found in path - please install!'
	exit 1
fi

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

[ -f ${SRCDIR}/${PKGNAME}-${MAJOR}.tar.xz ] || wget -O ${SRCDIR}/${PKGNAME}-${MAJOR}.tar.xz \
	https://www.kernel.org/pub/linux/kernel/v5.x/linux-${MAJOR}.tar.xz
[ -f ${SRCDIR}/patch-${PKGVERSION}.xz ] || wget -O ${SRCDIR}/patch-${PKGVERSION}.xz \
        https://www.kernel.org/pub/linux/kernel/v5.x/patch-${PKGVERSION}.xz

# Prepare build:
wdir=` pwd `
mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvJf ${SRCDIR}/${PKGNAME}-${MAJOR}.tar.xz
cd ${PKGNAME}-${MAJOR}
unxz -c ${SRCDIR}/patch-${PKGVERSION}.xz | patch -p1
# should be fixed in 3.17.5
# sed -i 's%shell objdump%shell $(OBJDUMP)%g' arch/x86/boot/compressed/Makefile

# Use the variable TINYKCONFIG to specify a custom kernel configuration!
KCONFIG="${wdir}/patches/config-3.17.3"
[ -n "$TINYKCONFIG" ] && KCONFIG="$TINYKCONFIG"
cp -v "$KCONFIG" .config
yes '' | make syncconfig
cd ..
mv ${PKGNAME}-${MAJOR} ${PKGNAME}-${PKGVERSION}

# Build and install
TINYARCH=x86_64
case ${CLFS_TARGET} in
	x86_64*)
		TINYARCH=x86_64
	;;
	i?86*)
		TINYARCH=x86
	;;
esac

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
localversion=` grep '^CONFIG_LOCALVERSION' .config | sed 's/"//g' | awk -F '=' '{print $2}' `
make ARCH=${TINYARCH} CROSS_COMPILE=${CLFS_TARGET}- oldconfig
make -j $( grep -c processor /proc/cpuinfo ) ARCH=${TINYARCH} CROSS_COMPILE=${CLFS_TARGET}-
INSTALL_MOD_PATH=${CLFS}/targetfs make ARCH=${TINYARCH} CROSS_COMPILE=${CLFS_TARGET}- modules_install || exit 1 
mkdir -p ${CLFS}/targetfs/boot
install -m 0644 arch/x86/boot/bzImage ${CLFS}/targetfs/boot/vmlinuz-${PKGVERSION}${localversion} || exit 1
find ${CLFS}/targetfs/lib/modules/${PKGVERSION}${localversion} -type f -name '*.ko' -exec ${CLFS_TARGET}-strip --strip-unneeded {} \; 

# Clean up

cd ${CLFS}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

