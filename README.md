TinyCrossLinux
==============

This repository contains scripts, build definitions and patches to build a minimal linux distribution running from initramfs. It's primary purpose is to teach the minimal requirements of a working linux system. If you just run our scripts you will end up with a small linux (between 5MB and 50MB) that allows you to login via SSH. Your phantasy and some scripts will expand this linux to a great deployment system or a platform for forensic analysis.

Our TinyCrossLinux is initially based on "Cross Linux from Scratch" (embedded). It uses an initramfs instead of a classic root file system. The boot scripts use a layout that is inspired by Berkeley Unix (BSD). Boot the system and take a look at `/etc/rc.d`. The scripts here will be executed in the order they appear (they will be called with the argument "start"). At shutdown the scripts will be called in reverse order (with argument stop).

Scripts in this repository might be eventually moved to LessLinux' build process (I feel tempted not do to so to keep it simple). Currently only x86_64 is supported. ia32 and armhf (Raspberry Pi) will follow, but are of no major priority.

stage01:
--------

Scripts to build the toolchain itself. You probably will not need to add/modify scripts here.

stage02:
--------

Scripts to build binaries for the target filesystem. Add as you want, but do not forget that you are cross compiling. Define `PKGNAME=...` and `PKGVERSION=...` since those are read by the script `build_stage0n.sh`. 

build_iso.sh:
-------------

Script to assemble a bootable ISO image (isohybrid, might be dd'ed to an USB thumb drive). Currently BIOS only, UEFI will follow. Feel free to ad an overlay or similar sick things to this script - it is less than 40 lines anyway.

So to build TinyCrossLinux run

	bash build_stage0n.sh
	bash build_iso.sh
	
## FAQ

### Login with password?

Run the command
	
	openssl passwd -1
	
on an arbitary machine and replace the '!' in roots line in `patches/etc-shadow` with the output.

### Remove login without password?

Take a look at `patches/etc-inittab`. Replace lines like

	ttyN::respawn:/bin/ash
	
by

	ttyN::respawn:/sbin/getty -l /bin/login 38400 ttyN
	
...

### Add more services?

The build script `stage02/0001_basefiles.sh` installs some of the startup scripts. Many of them are copied from the `patches directory`. You might want to create `stage02/0002_mybasefiles.sh`. Or you just expand the basefiles script.

