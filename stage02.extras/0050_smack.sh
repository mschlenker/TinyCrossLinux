
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=smack
PKGVERSION=1.3.0

# Download:
# https://github.com/smack-team/smack/archive/v1.3.0.tar.gz

[ -f ${SRCDIR}/v${PKGVERSION}.tar.gz ] || wget -O ${SRCDIR}/v${PKGVERSION}.tar.gz \
	https://github.com/smack-team/smack/archive/v${PKGVERSION}.tar.gz

# Prepare build:

workdir=` pwd ` 
mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvf ${SRCDIR}/v${PKGVERSION}.tar.gz

# Build and install

export CPPFLAGS=-I${CLFS}/cross-tools/${CLFS_TARGET}/include/kernel

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
bash autogen.sh
make clean
./configure --prefix=/usr --host=${CLFS_TARGET}
make || exit 1
make install DESTDIR=${CLFS}/targetfs
install -m 0755 ${workdir}/patches/etc-rc.d-0010-smack.sh ${CLFS}/targetfs/etc/rc.d/0010-smack.sh

# Clean up

rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}

