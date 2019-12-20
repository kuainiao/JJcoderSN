#!/bin/bash
#

for U in {1..10}; do
	if id user$U &>/dev/null ; then
		echo "user$U exists"
	else
		useradd user$U
		echo user$U | passwd --stdin user$U &> /dev/null
		echo "Add user user$U finshed"
	fi
done
