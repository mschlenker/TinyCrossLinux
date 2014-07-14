#!/bin/bash

source stage0n_variables

mkdir -p ${CLFS}/build 
mkdir -p ${CLFS}/cross-tools
mkdir -p ${SRCDIR}

for i in hosttools stage01 stage02 ; do
	for n in ${i}/[0-9][0-9][0-9][0-9]*.sh ; do 
		echo '===> BUILDING '"$n"
		pkgname=` cat "$n" | grep '^PKGNAME' | awk -F '=' '{print $2}' `
		pkgversion=` cat "$n" | grep '^PKGVERSION' | awk -F '=' '{print $2}' `
		if [ -f "$CLFS/build/${pkgname}-${pkgversion}.done" ] ; then
			echo '===> SKIPPING '"$n"
		else
			bash "$n"
			retval=$?
			if [ $retval -gt 0 ] ; then
				echo '+++> FAILED '"$n"
				exit 1	
			else
				echo '---> DONE '"$n"
				touch  "$CLFS/build/${pkgname}-${pkgversion}.done"
			fi
		fi
	done
done
