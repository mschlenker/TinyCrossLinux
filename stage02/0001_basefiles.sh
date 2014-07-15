source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=basefiles
PKGVERSION=20140715
 
# Build and install

mkdir -p ${CLFS}/targetfs/etc/rc.d
mkdir -p ${CLFS}/targetfs/etc/rc.subr
mkdir -p ${CLFS}/targetfs/root
install -m 0644 patches/etc-inittab ${CLFS}/targetfs/etc/inittab
install -m 0755 patches/etc-rc ${CLFS}/targetfs/etc/rc
install -m 0755 patches/etc-rc.shutdown ${CLFS}/targetfs/etc/rc.shutdown
install -m 0644 patches/etc-passwd ${CLFS}/targetfs/etc/passwd
install -m 0644 patches/etc-group ${CLFS}/targetfs/etc/group
install -m 0644 patches/etc-shadow ${CLFS}/targetfs/etc/shadow
install -m 0644 patches/etc-rc.subr-colors ${CLFS}/targetfs/etc/rc.subr/colors
install -m 0755 patches/etc-rc.d-0010-loop.sh ${CLFS}/targetfs/etc/rc.d/0010-loop.sh
install -m 0755 patches/etc-rc.d-0020-loadmodules.sh ${CLFS}/targetfs/etc/rc.d/0020-loadmodules.sh
install -m 0755 patches/etc-rc.d-0040-udhcpd.sh ${CLFS}/targetfs/etc/rc.d/0040-udhcpc.sh
