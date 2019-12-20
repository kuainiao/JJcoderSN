#!/bin/bash

##########selinux iptables##########
chkconfig iptables off
#cp -rav /etc/selinux/config{,.`date +%Y%m%d`.bak}
#sed -i "s/SELINUX=enforcing/SELINUX=disabled/g"  /etc/selinux/config

##########ipv6##########
echo "options ipv6 disable=1" >> /etc/modprobe.d/ipv6.conf


##########ssh##########
cp -rav /etc/ssh/sshd_config{,.`date +%Y%m%d`.bak}
sed -i '/#PermitRootLogin*/a\PermitRootLogin no'  /etc/ssh/sshd_config
sed -i '/#UseDNS*/a\UseDNS no'  /etc/ssh/sshd_config


##########tools##########
#rpm -ivh /root/zhuji1209/ftp-0.17-54.el6.x86_64.rpm 
#rpm -ivh /root/zhuji1209/lsof-4.82-5.el6.x86_64.rpm  
#rpm -ivh /root/zhuji1209/telnet-0.17-48.el6.x86_64.rpm 
#rpm -ivh /root/zhuji1209/sysstat-9.0.4-31.el6.x86_64.rpm 
#rpm -ivh /root/zhuji1209/nc-1.84-24.el6.x86_64.rpm
#rpm -ivh /root/zhuji1209/ntp-4.2.6p5-10.el6.centos.x86_64.rpm
#rpm -ivh /root/zhuji1209/ntpdate-4.2.6p5-10.el6.centos.x86_64.rpm

##########ntp##########
#chkconfig ntpd on
#cp -rav /etc/ntp.conf{,.`date +%Y%m%d`.bak} 
#sed -i 's/^server.*//g' /etc/ntp.conf
#echo "server 10.83.5.15 iburst" >> /etc/ntp.conf 
#echo "server 10.83.5.16 iburst" >> /etc/ntp.conf 
#yum install ntp
#202.120.2.101

##########dns##########
#echo "DNS01=10.83.5.15" >> /etc/sysconfig/network-scripts/ifcfg-bond0



##########service##########
chkconfig sendmail off
chkconfig sendmaild off
chkconfig NetworkManager off

##########login##########
cp -rav /etc/profile{,.`date +%Y%m%d`.bak}
echo "export TMOUT=600"  >> /etc/profile


##########user##########
useradd sysyunwei
echo abc@123| passwd --stdin sysyunwei
gpasswd -a sysyunwei wheel
cp -rav  /etc/pam.d/su{,.`date +%Y%m%d`.bak}
sed -i "/required/a\auth    required    pam_wheel.so use_uid"  /etc/pam.d/su 

##########account##########
cp -rav /etc/pam.d/system-auth-ac{,.`date +%Y%m%d`.bak} 
#sed -i "s/.*cracklib.*/password requisite pam_cracklib.so try_first_pass retry=3 minlen=8 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/" /etc/pam.d/system-auth-ac
sed -i "s/.*cracklib.*/password requisite pam_cracklib.so try_first_pass retry=3 minlen=12/" /etc/pam.d/system-auth-ac
cp -rav /etc/login.defs{,.`date +%Y%m%d`.bak}
sed -i "s/PASS_MIN_LEN/#PASS_MIN_LEN/g" /etc/login.defs
sed -i "/PASS_MIN_LEN/a\PASS_MIN_LEN   12" /etc/login.defs
sed -i "s/PASS_MAX_DAYS/#PASS_MAX_DAYS/g" /etc/login.defs
sed -i "/PASS_MAX_DAYS/a\PASS_MAX_DAYS  90" /etc/login.defs


##########ctrl+alt+delete##########
cp -v /etc/init/control-alt-delete.conf{,.`date +%Y%m%d`.bak} 
sed -i 's,^exec.*,exec /usr/bin/logger -p authpriv.notice -t init "Ctrl-Alt-Del was pressed and ignored",' /etc/init/control-alt-delete.conf


##########yum#########
#mkdir /tmp/cdrom
#mkdir /etc/yum.repos.d/yumbak
#mv /etc/yum.repos.d/C* /etc/yum.repos.d/yumbak
#cat > /etc/yum.repos.d/server.repo <<EOF
#[server]
#name=server
#baseurl=http://10.83.5.19/yumdata/Centos-68/Base/x86_64/Packages
##baseurl=file:///tmp/cdrom
#enabled=1
#gpgcheck=0
#EOF


echo "#######################"
echo "#  please reboot now  #"
echo "#######################"

