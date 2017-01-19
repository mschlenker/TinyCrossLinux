
source stage0n_variables
source stage01_variables

PKGNAME=gcc-step2
PKGVERSION=6.2.0
MPFR=3.1.5
GMP=6.1.2
MPC=1.0.3

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvjf ${SRCDIR}/gcc-${PKGVERSION}.tar.bz2

# Build and install

mkdir gcc-build
cd gcc-${PKGVERSION}
# cat ${SRCDIR}/gcc-4.7.3-musl-1.patch | patch -p1 
tar xJf ${SRCDIR}/mpfr-${MPFR}.tar.xz
mv -v mpfr-${MPFR} mpfr || exit 1
tar xf ${SRCDIR}/gmp-${GMP}.tar.lz
mv -v gmp-${GMP} gmp || exit 1
tar xf ${SRCDIR}/mpc-${MPC}.tar.gz
mv -v mpc-${MPC} mpc || exit 1 

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
  --target=${CLFS_TARGET} \
  --host=${CLFS_HOST} \
  --with-sysroot=${CLFS}/cross-tools/${CLFS_TARGET} \
  --disable-nls \
  --enable-languages=c \
  --enable-c99 \
  --enable-long-long \
  --disable-libmudflap \
  --disable-multilib \
  --with-mpfr-include=$(pwd)/../gcc-${PKGVERSION}/mpfr/src \
  --with-mpfr-lib=$(pwd)/mpfr/src/.libs \
  --with-arch=${CLFS_CPU} ${ARMFLOAT} ${ARMFPU}

make -j $( grep -c processor /proc/cpuinfo ) || exit 1
make install || exit 1

# We should not need kernel headers anymore:
mkdir -pv ${CLFS}/cross-tools/${CLFS_TARGET}/include/kernel
mv ${CLFS}/cross-tools/${CLFS_TARGET}/include/linux ${CLFS}/cross-tools/${CLFS_TARGET}/include/kernel/

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/gcc-${PKGVERSION} ${CLFS}/build/${PKGNAME}-${PKGVERSION}/gcc-build 

