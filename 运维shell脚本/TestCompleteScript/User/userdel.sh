#!/bin/bash
#
for U in {1..10}; do
	if id user$U &>/dev/null ; then
		userdel -r user$U
		echo "Delete user user$U finshed"
	else
	    echo "Not user$U"
	fi 
done
