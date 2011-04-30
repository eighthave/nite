#!/bin/bash -e

if [ "`uname -s`" == "Darwin" ]; then
        LIBEXT="dylib"
else
        LIBEXT="so"
fi

cp Bin/libXnVNite*$LIBEXT ${DESTDIR}/usr/lib
cp Bin/libXnVCNITE*$LIBEXT ${DESTDIR}/usr/lib
if [ -e Makefile ]
then
	mkdir -p ${DESTDIR}/usr/include/nite
	cp Include/* ${DESTDIR}/usr/include/nite
fi
for fdir in `ls -1 | grep Features`
do
	mkdir -p ${DESTDIR}/etc/primesense/$fdir
	cp $fdir/Data/* ${DESTDIR}/etc/primesense/$fdir
	for so in `ls -1 $fdir/Bin/lib*$LIBEXT`
	do
		base=`basename $so`
		cp $so ${DESTDIR}/usr/lib
		niReg ${DESTDIR}/usr/lib/$base ${DESTDIR}/etc/primesense/$fdir
	done
done
for hdir in `ls -1 | grep Hands`
do
	mkdir -p ${DESTDIR}/etc/primesense/$hdir
	cp $hdir/Data/* ${DESTDIR}/etc/primesense/$hdir
	for so in `ls -1 $hdir/Bin/lib*$LIBEXT`
	do
		base=`basename $so`
		cp $so ${DESTDIR}/usr/lib
		niReg ${DESTDIR}/usr/lib/$base ${DESTDIR}/etc/primesense/$hdir
	done
done

if [ -f ${DESTDIR}/usr/bin/gmcs ]
then
	for net in `ls -1 Bin/*dll`
	do
		gacutil -i $net -package 2.0
		netdll=`basename $net`
		echo $netdll >> ${DESTDIR}/etc/primesense/XnVNITE.net.dll.list
	done
fi

LIC_KEY=""
ASK_LIC="1"
while (( "$#" )); do
	case "$1" in
	-l=*)
		ASK_LIC="0"
		LIC_KEY=${1:3}
		;;
	esac
	shift
done

if [ "$ASK_LIC" == "1" ]; then
	printf "Please enter your PrimeSense license key: "
	read LIC_KEY
fi

if [ -z "$LIC_KEY" ]; then
	echo
	echo "*** WARNING: *****************************************************"
	echo "** No license key provided. Note that you can always install    **"
	echo "** new license keys by running:                                 **"
	echo "**                                                              **"
	echo "**    niLicense PrimeSense <key>                                **"
	echo "**                                                              **"
	echo "******************************************************************"
else
        niLicense PrimeSense $LIC_KEY
fi

if [ -e Makefile ]
then
	make
fi
