
source stage0n_variables
source stage01_variables

PKGNAME=libstdcplusplus
PKGVERSION=6.3.0

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvjf ${SRCDIR}/gcc-${PKGVERSION}.tar.bz2

# Build and install

mkdir gcc-build
cd gcc-${PKGVERSION}

#case ${CLFS_TARGET} in
#	*arm*)
#		ARMFLOAT="--with-float=${CLFS_FLOAT}"
#		ARMFPU="--with-fpu=${CLFS_FPU}"
#	;;
#esac

cd ../gcc-build

../gcc-${PKGVERSION}/libstdc++-v3/configure           \
    --host=${CLFS_TARGET}                \
    --prefix=${CLFS}/cross-tools                 \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=${CLFS}/cross-tools/${CLFS_TARGET}/include/c++/${PKGVERSION}

make -j $( grep -c processor /proc/cpuinfo ) || exit 1
make install || exit 1

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/gcc-${PKGVERSION} ${CLFS}/build/${PKGNAME}-${PKGVERSION}/gcc-build 

