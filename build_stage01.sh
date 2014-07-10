
for n in stage01/[0-9][0-9][0-9][0-9]*.sh ; do 
	echo '===> BUILDING '"$n"
	bash "$n"
	retval=$?
	if [ $retval -gt 0 ] ; then
		echo '+++> FAILED '"$n"
		exit 1	
	else
		echo '---> DONE '"$n"
	fi
done

