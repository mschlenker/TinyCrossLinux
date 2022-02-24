
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=ncurses
PKGVERSION=6.3

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz \
	ftp://ftp.gnu.org/gnu/ncurses/${PKGNAME}-${PKGVERSION}.tar.gz

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvzf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.gz

# Patch
#sed -i s/mawk// configure

# Build tic
#mkdir build
#pushd build
#  ../configure
#  make -C include
#  make -C progs tic
#popd

# Build and install
export CPPFLAGS=-P # Work around a broken mawk
export CFLAGS="-I${CLFS}/cross-tools/${CLFS_TARGET}/include/kernel"
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
./configure --prefix=/ \
	--disable-stripping \
	--without-debug \
	--without-ada \
	--without-normal \
	--enable-overwrite \
	--enable-widec \
	--host=${CLFS_ARCH} || exit 1
make -j $( grep -c processor /proc/cpuinfo ) || exit 1
make DESTDIR=${CLFS}/cross-tools/${CLFS_TARGET} install || exit 1
make DESTDIR=${CLFS}/targetfs install 
echo "INPUT(-lncursesw)" > ${CLFS}/targetfs/usr/lib/libncurses.so

# Clean up

cd ${CLFS}
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

