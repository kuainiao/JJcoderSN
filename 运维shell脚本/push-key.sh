#!/bin/bash
password=CctvDCF231265
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -P "" -f ~/.ssh/id_rsa
fi
for j in {128..130}
do
    for i in {1..250}
    do
        ip =  10.145.$j.$i
        ping -c1 -W1 $ip &>/dev/null
        if [ $? -ne 0 ];then
            echo 'Unreachable target'
        else
            /usr/bin/expect <<-EOF
        set timeout 10
        #log_user 0
        spawn ssh-copy-id $ip
        expect {
            "yes/no" {send "yes\r"; exp_continue}
            "password:" {send "$password\r"
        }
        expect eof
        EOF
    fi
done
done
