
source /home/mattias/Projekte/git/TinyCrossLinux/stage0n_variables
source /home/mattias/Projekte/git/TinyCrossLinux/stage01_variables
# source /home/mattias/Projekte/git/TinyCrossLinux/stage02_variables

cd pkg-config-0.28
./configure  --prefix=${CLFS}/cross-tools  --target=${CLFS_TARGET} \
	 --with-sysroot=${CLFS}/cross-tools/${CLFS_TARGET}  \
	--with-internal-glib

make
make install # DESTDIR=/tmp/install.pkg-config

