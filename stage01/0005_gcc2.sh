
source stage0n_variables
source stage01_variables

PKGNAME=gcc-step2
PKGVERSION=4.7.4

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvjf ${SRCDIR}/gcc-${PKGVERSION}.tar.bz2

# Build and install

mkdir gcc-build
cd gcc-${PKGVERSION}
cat ${SRCDIR}/gcc-4.7.3-musl-1.patch | patch -p1
tar xJf ${SRCDIR}/mpfr-3.1.3.tar.xz
mv -v mpfr-3.1.3 mpfr
tar xJf ${SRCDIR}/gmp-6.0.0a.tar.xz
mv -v gmp-6.0.0 gmp
tar xf ${SRCDIR}/mpc-1.0.3.tar.gz
mv -v mpc-1.0.3 mpc

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

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/gcc-${PKGVERSION} ${CLFS}/build/${PKGNAME}-${PKGVERSION}/gcc-build 

