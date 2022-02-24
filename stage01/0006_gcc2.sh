
source stage0n_variables
source stage01_variables

PKGNAME=gcc-step2
PKGVERSION=10.3.0
MPFR=4.1.0
GMP=6.2.1
MPC=1.2.1

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvf ${SRCDIR}/gcc-${PKGVERSION}.tar.xz

# Build and install

mkdir gcc-build
cd gcc-${PKGVERSION}

cat gcc/limitx.h gcc/glimits.h gcc/limity.h >  `dirname $(${CLFS}/cross-tools/bin/${CLFS_TARGET}-gcc -print-libgcc-file-name)`/include-fixed/limits.h

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
  ;;
esac

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
  --enable-languages=c,c++                       \
  --disable-libstdcxx-pch                        \
  --disable-multilib                             \
  --disable-bootstrap                            \
  --disable-libgomp \
  --disable-nls \
  --disable-libitm \
  --disable-libsanitizer \
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

