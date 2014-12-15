
source /home/mattias/Projekte/git/TinyCrossLinux/stage0n_variables
source /home/mattias/Projekte/git/TinyCrossLinux/stage01_variables
source /home/mattias/Projekte/git/TinyCrossLinux/stage02_variables

cd glib-2.42.1
./configure --prefix=/usr  --prefix=/usr --sysconfdir=/etc --host=${CLFS_TARGET} 

