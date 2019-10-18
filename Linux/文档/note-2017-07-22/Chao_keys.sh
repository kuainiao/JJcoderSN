#!/bin/bash
#
#Content to other computer.
#Ping Test Computer.
export passwd="uplooking"
for i in {1..120}
do
{
	ping -c 1 computer_address.$i &> /dev/null
	if [ $? -eq 0 ];then
		echo computer_address.$i >> $PWD/ip.txt
	else
		echo computer_address.$i >> $PWD/down.txt
	fi
}&
done
echo "ok..."

#Ctrl Keys to Other Computer.
for j in `cat $PWD/ip.txt`
do
{
	/usr/bin/expect << EOF
	swapn scp /root/.ssh/authorized_keys $j:/root/.ssh/authorized_keys
	expect {
		"yes/no"	{ send "yes\r" ; exp_continue }
		"password:"	{ send "$passwd\r" ; exp_continue }
	}
EOF
}&
done
wait
echo "ok..."