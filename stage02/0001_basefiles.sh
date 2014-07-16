source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=basefiles
PKGVERSION=20140716
 
# Build and install
mkdir -p ${CLFS}/targetfs/etc/rc.d
mkdir -p ${CLFS}/targetfs/etc/rc.subr
mkdir -p ${CLFS}/targetfs/root
mkdir -p ${CLFS}/targetfs/usr/share/udhcpc

# Needed for startup
install -m 0644 patches/etc-inittab ${CLFS}/targetfs/etc/inittab
install -m 0755 patches/etc-rc ${CLFS}/targetfs/etc/rc
install -m 0755 patches/etc-rc.shutdown ${CLFS}/targetfs/etc/rc.shutdown
install -m 0644 patches/etc-rc.subr-colors ${CLFS}/targetfs/etc/rc.subr/colors

# User and group definitions
install -m 0644 patches/etc-passwd ${CLFS}/targetfs/etc/passwd
install -m 0644 patches/etc-group ${CLFS}/targetfs/etc/group
install -m 0644 patches/etc-shadow ${CLFS}/targetfs/etc/shadow
install -m 0644 patches/etc-shells ${CLFS}/targetfs/etc/shells

# devices
install -m 0644 patches/etc-mdev.conf ${CLFS}/targetfs/etc/mdev.conf

# startup services
install -m 0755 patches/usr-share-udhcpc-default.script ${CLFS}/targetfs/usr/share/udhcpc/default.script
install -m 0755 patches/etc-rc.d-0010-loop.sh ${CLFS}/targetfs/etc/rc.d/0010-loop.sh
install -m 0755 patches/etc-rc.d-0012-syslogd.sh ${CLFS}/targetfs/etc/rc.d/0012-syslogd.sh
install -m 0755 patches/etc-rc.d-0020-loadmodules.sh ${CLFS}/targetfs/etc/rc.d/0020-loadmodules.sh
install -m 0755 patches/etc-rc.d-0040-udhcpd.sh ${CLFS}/targetfs/etc/rc.d/0040-udhcpc.sh

# optional startup scripts
install -m 0755 patches/etc-rc.d-0055-httpd.sh ${CLFS}/targetfs/etc/rc.d/0055-httpd.sh
install -m 0755 patches/etc-rc.d-0060-tftpd.sh ${CLFS}/targetfs/etc/rc.d/0060-tftpd.sh
install -m 0755 patches/etc-rc.d-0065-udhcpd.sh ${CLFS}/targetfs/etc/rc.d/0060-udhcpd.sh
