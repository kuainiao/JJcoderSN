#!/bin/bash
#
if [[ $# -lt 1 ]] ; then
	echo " Useage: adminuser ARG"
	exit 3
fi

if [ $1 == "add" ] ; then
	for U in {1..10};do
		if id user$U &> /dev/null ;then
			echo "User$U exists"
		else
			useradd user$U
			echo user$U | passwd --stdin user$U &> /dev/null
			echo "Add user$U finshed"
		fi
	done
elif [ $1 == "del" ];then
	for U in {1..10}; do
		if id user$U &> /dev/null ; then
			userdel -r user$U
			echo "Delete user$U finshed"
		else
			echo "Not user$U"
		fi
	done
else
	echo "Unknown ARG"
	exit 4
fi