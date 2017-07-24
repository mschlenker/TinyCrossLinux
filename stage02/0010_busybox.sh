
source stage0n_variables
source stage01_variables
source stage02_variables
 
PKGNAME=busybox
PKGVERSION=1.27.1

# Download:

[ -f ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2 ] || wget -O ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2 \
	http://busybox.net/downloads/${PKGNAME}-${PKGVERSION}.tar.bz2

# Prepare build:

mkdir -p ${CLFS}/build/${PKGNAME}-${PKGVERSION}
cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}
tar xvjf ${SRCDIR}/${PKGNAME}-${PKGVERSION}.tar.bz2

# Build and install

cd ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
ARCH="${CLFS_ARCH}" make defconfig
sed -i 's/\(CONFIG_\)\(.*\)\(INETD\)\(.*\)=y/# \1\2\3\4 is not set/g' .config
sed -i 's/\(CONFIG_IFPLUGD\)=y/# \1 is not set/' .config
sed -i 's/\(CONFIG_FEATURE_IPV6\)=y/# \1 is not set/' .config
sed -i 's/\(CONFIG_FEATURE_IFUPDOWN_IPV6\)=y/# \1 is not set/' .config
sed -i 's/CONFIG_BRCTL=y/# CONFIG_BRCTL is not set/g' .config
sed -i 's/CONFIG_FEATURE_WTMP=y/# CONFIG_FEATURE_WTMP is not set/g' .config
sed -i 's/CONFIG_FEATURE_UTMP=y/# CONFIG_FEATURE_UTMP is not set/g' .config
sed -i 's/CONFIG_FEATURE_UPTIME_UTMP=y/# CONFIG_FEATURE_UPTIME_UTMP is not set/g' .config

# Use the environment variable TINYBBSTATIC=1 to compile static busybox
case "$TINYBBSTATIC" in
	1)
		sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g'  .config
	;;
esac

for header in linux/kd.h linux/types.h linux/posix_types.h linux/stddef.h linux/vt.h \
	linux/version.h linux/loop.h linux/fb.h linux/i2c.h linux/hdreg.h linux/i2c-dev.h \
	linux/major.h linux/raid/md_u.h linux/watchdog.h linux/ioctl.h linux/if.h \
	linux/libc-compat.h linux/socket.h linux/hdlc/ioctl.h linux/if_slip.h \
	linux/if_ether.h linux/if_bonding.h linux/sockios.h linux/ethtool.h \
	linux/sysinfo.h linux/kernel.h linux/netlink.h linux/rtnetlink.h linux/if_link.h \
	linux/if_addr.h linux/neighbour.h linux/fs.h linux/limits.h \
	linux/netfilter_ipv4.h linux/netfilter.h linux/sysctl.h linux/if_tun.h \
	linux/byteorder/big_endian.h linux/byteorder/little_endian.h linux/swab.h \
	linux/filter.h linux/bpf_common.h linux/if_vlan.h linux/if_arp.h \
	linux/if_packet.h linux/netdevice.h linux/input.h linux/input-event-codes.h \
	linux/fd.h ; do
	tar -C ${CLFS}/cross-tools/${CLFS_TARGET}/include/kernel/ -cvf - $header | \
		tar -C ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}/include -xf - 
done

for header in linux/in6.h linux/in.h ; do
	rm ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}/include/${header}
	touch ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}/include/${header}
done



ARCH="${CLFS_ARCH}" CROSS_COMPILE="${CLFS_TARGET}-" make || exit 1
ARCH="${CLFS_ARCH}" CROSS_COMPILE="${CLFS_TARGET}-" make  \
  CONFIG_PREFIX="${CLFS}/targetfs" install || exit 1 
ln -sf bin/busybox ${CLFS}/targetfs/init
${CLFS}/cross-tools/bin/${CLFS_TARGET}-strip ${CLFS}/targetfs/bin/busybox
# chmod u+s ${CLFS}/targetfs/bin/busybox

# Clean up
cd ${CLFS}/build
rm -rf ${CLFS}/build/${PKGNAME}-${PKGVERSION}/${PKGNAME}-${PKGVERSION}
