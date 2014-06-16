
source stage01_variables

PKGNAME=gcc-step1
PKGVERSION=4.7.4

# Download:

[ -f ${SRCDIR}/gcc-${PKGVERSION}.tar.bz2 ] || wget -O ${SRCDIR}/gcc-${PKGVERSION}.tar.bz2 \
	http://gcc.cybermirror.org/releases/gcc-${PKGVERSION}/gcc-${PKGVERSION}.tar.bz2
[ -f ${SRCDIR}/mpfr-3.1.2.tar.xz ] || wget -O ${SRCDIR}/mpfr-3.1.2.tar.xz \
	http://www.mpfr.org/mpfr-current/mpfr-3.1.2.tar.xz 
[ -f ${SRCDIR}/gmp-6.0.0a.tar.xz ] || wget -O ${SRCDIR}/gmp-6.0.0a.tar.xz \
	https://gmplib.org/download/gmp/gmp-6.0.0a.tar.xz
[ -f ${SRCDIR}/mpc-1.0.2.tar.gz  ] || wget -O ${SRCDIR}/mpc-1.0.2.tar.gz \
	ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz
[ -f embedded-dev/gcc-4.7.3-musl-1.patch ] || wget -O embedded-dev/gcc-4.7.3-musl-1.patch \
	http://patches.cross-lfs.org/embedded-dev/gcc-4.7.3-musl-1.patch

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvjf ${SRCDIR}/gcc-${PKGVERSION}.tar.bz2

# Build and install

mkdir gcc-build
cd gcc-${PKGVERSION}
cat ${SRCDIR}/gcc-4.7.3-musl-1.patch | patch -p1 
tar xJf ${SRCDIR}/mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar xJf ${SRCDIR}/gmp-6.0.0a.tar.xz
mv -v gmp-6.0.0 gmp
tar xf ${SRCDIR}/mpc-1.0.2.tar.gz
mv -v mpc-1.0.2 mpc

cd ../gcc-build
../gcc-${PKGVERSION}/configure \
  --prefix=${CLFS}/cross-tools \
  --build=${CLFS_HOST} \
  --host=${CLFS_HOST} \
  --target=${CLFS_TARGET} \
  --with-sysroot=${CLFS}/cross-tools/${CLFS_TARGET} \
  --disable-nls  \
  --disable-shared \
  --without-headers \
  --with-newlib \
  --disable-decimal-float \
  --disable-libgomp \
  --disable-libmudflap \
  --disable-libssp \
  --disable-libatomic \
  --disable-libquadmath \
  --disable-threads \
  --enable-languages=c \
  --disable-multilib \
  --with-mpfr-include=$(pwd)/../gcc-${PKGVERSION}/mpfr/src \
  --with-mpfr-lib=$(pwd)/mpfr/src/.libs \
  --with-arch=${CLFS_CPU}

make all-gcc all-target-libgcc
make install-gcc install-target-libgcc

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/gcc-${PKGVERSION} ${CLFS}/build/${PKGNAME}-${PKGVERSION}/gcc-build 

