
source /home/mattias/Projekte/git/TinyCrossLinux/stage0n_variables
source /home/mattias/Projekte/git/TinyCrossLinux/stage01_variables
source /home/mattias/Projekte/git/TinyCrossLinux/stage02_variables

cd libffi-3.2.1
./configure --prefix=/usr  --prefix=/usr --sysconfdir=/etc --host=${CLFS_TARGET} 
make
make install DESTDIR=${CLFS}/targetfs
make install DESTDIR=${CLFS}/cross-tools/${CLFS_TARGET}

