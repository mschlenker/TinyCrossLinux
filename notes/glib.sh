
source /home/mattias/Projekte/git/TinyCrossLinux/stage0n_variables
source /home/mattias/Projekte/git/TinyCrossLinux/stage01_variables
source /home/mattias/Projekte/git/TinyCrossLinux/stage02_variables

export PKG_CONFIG_PATH=/mnt/archiv/TinyCrossBuild/cross-tools/x86_64-linux-musl/lib/pkgconfig

cd glib-2.42.1
./configure --cache-file=/tmp/glib.cache --prefix=/usr  --prefix=/usr --sysconfdir=/etc --host=${CLFS_TARGET} 
make
make install DESTDIR=${CLFS}/cross-tools/${CLFS_TARGET}

