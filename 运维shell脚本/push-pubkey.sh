#!/bin/bash
pull_pub_key(){
	password=Gaoji_001#
	for ip in $(cat ip.txt)
	do
	if [ "$ip" == "" ];then
                echo "ip non-existent"
    else
    /usr/bin/expect <<-EOF
    set timeout 10
    #log_user 0
    spawn ssh-copy-id $ip
    expect {
        "yes/no" {send "yes\r"; exp_continue}
        "password:" {send "$password\r"}
        }
    expect eof
    EOF
	fi
	done
	}
pull_pub_key
