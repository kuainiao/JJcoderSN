#!/usr/bin/env bash

if [[ $1 == '--add' ]] ; then
	for U in `echo $2 | sed 's/,/ /g'`; do
		if id $U &> /dev/null; then
			echo "$U exists."
		else
			useradd $U
			echo $U | passwd --stdin $U &> /dev/null 
			echo "Add $U finshed."
		fi 
	done
elif [[ $1 == '--del' ]]; then
	for U in `echo $2 | sed 's/,/ /g'` ; do 
		if id $U &> /dev/null ; then
			userdel -r $U
			echo "Delete $U finshed."
		else
			echo "$U NOT exist."
		fi
	done 
elif [ $1 == '--help' ]; then
	echo "Usage: adminuaer.sh --add USER1,USER2,.. | --del USER1,USER2,... | --help "
else 
	echo "Unknown options"
fi