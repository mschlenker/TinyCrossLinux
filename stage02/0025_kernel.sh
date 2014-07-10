
source stage01_variables
source stage02_variables
 
PKGNAME=linux
PKGVERSION=3.15.5

# Download:

[ -f ${SRCDIR}/${PKGNAME}-3.15.tar.xz ] || wget -O ${SRCDIR}/${PKGNAME}-3.15.tar.xz \
	https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.15.tar.xz
[ -f ${SRCDIR}/patch-${PKGVERSION}.xz ] || wget -O ${SRCDIR}/patch-${PKGVERSION}.xz \
        https://www.kernel.org/pub/linux/kernel/v3.x/patch-${PKGVERSION}.xz

# Prepare build:

wdir=` pwd `
mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvJf ${SRCDIR}/${PKGNAME}-3.15.tar.xz
cd ${PKGNAME}-3.15
unxz -c ${SRCDIR}/patch-${PKGVERSION}.xz | patch -p1
cp -v "${wdir}/patches/config-3.15.1" .config
cd ..
mv ${PKGNAME}-3.15 ${PKGNAME}-${PKGVERSION}

# Build and install

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
localversion=` grep '^CONFIG_LOCALVERSION' .config | sed 's/"//g' | awk -F '=' '{print $2}' `
make ARCH=x86_64 CROSS_COMPILE=x86_64-linux-musl- oldconfig
make ARCH=x86_64 CROSS_COMPILE=x86_64-linux-musl-
INSTALL_MOD_PATH=${CLFS}/targetfs make ARCH=x86_64 CROSS_COMPILE=x86_64-linux-musl- modules_install || exit 1 
mkdir -p ${CLFS}/targetfs/boot
install -m 0644 arch/x86/boot/bzImage ${CLFS}/targetfs/boot/vmlinuz-${PKGVERSION}${localversion} || exit 1
find ${CLFS}/targetfs/lib/modules/${PKGVERSION}${localversion} -type f -name '*.ko' -exec x86_64-linux-musl-strip --strip-unneeded {} \; 

# Clean up

cd ${CLFS}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

