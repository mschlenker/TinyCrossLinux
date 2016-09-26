
source stage0n_variables
source stage01_variables

PKGNAME=gcc-step1
PKGVERSION=6.2.0
MPFR=3.1.4
GMP=6.1.1
MPC=1.0.3

# Download:

[ -f ${SRCDIR}/gcc-${PKGVERSION}.tar.bz2 ] || wget -O ${SRCDIR}/gcc-${PKGVERSION}.tar.bz2 \
	ftp://ftp.mpi-sb.mpg.de/pub/gnu/mirror/gcc.gnu.org/pub/gcc/releases/gcc-${PKGVERSION}/gcc-${PKGVERSION}.tar.bz2
[ -f ${SRCDIR}/mpfr-${MPFR}.tar.xz ] || wget -O ${SRCDIR}/mpfr-${MPFR}.tar.xz \
	http://www.mpfr.org/mpfr-current/mpfr-${MPFR}.tar.xz 
[ -f ${SRCDIR}/gmp-${GMP}.tar.lz ] || wget -O ${SRCDIR}/gmp-${GMP}.tar.lz \
	https://gmplib.org/download/gmp/gmp-${GMP}.tar.lz
[ -f ${SRCDIR}/mpc-${MPC}.tar.gz  ] || wget -O ${SRCDIR}/mpc-${MPC}.tar.gz \
	ftp://ftp.gnu.org/gnu/mpc/mpc-${MPC}.tar.gz
# [ -f gcc-4.7.3-musl-1.patch ] || wget -O ${SRCDIR}/gcc-4.7.3-musl-1.patch \
#	http://distfiles.lesslinux.org/gcc-4.7.3-musl-1.patch

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvjf ${SRCDIR}/gcc-${PKGVERSION}.tar.bz2

# Build and install

mkdir gcc-build
cd gcc-${PKGVERSION}
# cat ${SRCDIR}/gcc-4.7.3-musl-1.patch | patch -p1 
tar xJf ${SRCDIR}/mpfr-${MPFR}.tar.xz
mv -v mpfr-${MPFR} mpfr
tar xf ${SRCDIR}/gmp-${GMP}.tar.lz
mv -v gmp-${GMP} gmp
tar xf ${SRCDIR}/mpc-${MPC}.tar.gz
mv -v mpc-${MPC} mpc

case ${CLFS_TARGET} in
	*arm*)
		ARMFLOAT="--with-float=${CLFS_FLOAT}"
		ARMFPU="--with-fpu=${CLFS_FPU}"
	;;
esac

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
  --with-arch=${CLFS_CPU} ${ARMFLOAT} ${ARMFPU}

make all-gcc all-target-libgcc -j $( grep -c processor /proc/cpuinfo )  || exit 1
make install-gcc install-target-libgcc || exit 1

# Clean up

cd ..
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/gcc-${PKGVERSION}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/gcc-build 
