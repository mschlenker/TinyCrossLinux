
source /home/mattias/Projekte/git/TinyCrossLinux/stage0n_variables
source /home/mattias/Projekte/git/TinyCrossLinux/stage01_variables
source /home/mattias/Projekte/git/TinyCrossLinux/stage02_variables

cd qemu-2.2.0
./configure --prefix=/usr --cross-prefix=${CLFS_TARGET}- \
	--sysconfdir=/etc --libexecdir=/usr/lib/qemu \
	--interp-prefix=/mnt/archiv/TinyCrossBuild/cross-tools \
	--target-list=x86_64-softmmu,i386-linux-user,x86_64-linux-user 

