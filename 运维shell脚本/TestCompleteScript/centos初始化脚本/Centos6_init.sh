#!/usr/bin/env bash
######################################
#         centos6 初始化脚本          #
######################################
. /etc/init.d/functions
# dns服务（dns server）
dns_server1='10.8.6.10'
dns_server2='172.17.0.10'

# yum服务(yum server)
yum_server='yum.server.local'

# ntp服务(ntp server)
ntp_server='ntp.server.local'
# 操作系统版本(system release)
RELEASE=`cat /etc/redhat-release`  # CentOS Linux release 7.7.1908 (Core)
# 内核版本(kernel release)
NAME=`uname -r`  # 3.10.0-1062.el7.x86_64
# 日期(date)
DATE=`date`
#ip
IPADDR=`grep "IPADDR" /etc/sysconfig/network-scripts/ifcfg-eth0|cut -d= -f 2`
#hostname
HOSTNAME=`hostname -s`
#user
USER=`whoami`
# 磁盘使用率(disk_check)
DISK_SDA=`df -h |grep -w "/" | awk '{print $5}'` #  -w, --word-regexp  force PATTERN to match only whole words
# cpu负载(cpu_average_check)
cpu_uptime=`cat /proc/loadavg | awk '{print $1,$2,$3}'` # uptime
  
#set LANG
export LANG=zh_CN.UTF-8
 
#Require root to run this script.
uid=`id | cut -d\( -f1 | cut -d= -f2`
if [[ ${uid} -ne 0 ]];then
  action "Please run this script as root." /bin/false
  exit 1
fi
# "stty erase ^H" # 这里没看懂
\cp /root/.bash_profile  /root/.bash_profile_$(date +%F)
erase=`grep -wx "stty erase ^H" /root/.bash_profile | wc -l`
if [ $erase -lt 1 ];then
    echo "stty erase ^H" >>/root/.bash_profile
    source /root/.bash_profile
fi

#Config Yum CentOS-Bases.repo
configYum(){
echo "================更新为国内YUM源=================="
  cd /etc/yum.repos.d/
 
  \cp CentOS-Base.repo CentOS-Base.repo.$(date +%F)
  ping -c 1 www.163.com>/dev/null
  if [ $? -eq 0 ];then
  wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
  else
    echo "无法连接网络。"
    exit $?
  fi
  \cp CentOS-Base-163.repo CentOS-Base.repo
action "配置国内YUM完成"  /bin/true
echo "================================================="
echo ""
  sleep 2
}
# add_dns
add_dns() {
test -f /etc/resolv.conf && echo "nameserver ${dns_server1}" > /etc/resolv.conf
test -f /etc/resolv.conf && echo "nameserver ${dns_server2}" > /etc/resolv.conf
}

#Charset zh_CN.UTF-8
initI18n(){
echo "================更改为中文字符集================="
  \cp /etc/sysconfig/i18n /etc/sysconfig/i18n.$(date +%F)
  echo "LANG="zh_CN.UTF-8"" >/etc/sysconfig/i18n
  source /etc/sysconfig/i18n
  echo '#cat /etc/sysconfig/i18n'
  grep LANG /etc/sysconfig/i18n
action "更改字符集zh_CN.UTF-8完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}
#Close Selinux and Iptables
initFirewall(){
echo "============禁用SELINUX及关闭防火墙=============="
  \cp /etc/selinux/config /etc/selinux/config.$(date +%F)
  /etc/init.d/iptables stop
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  /etc/init.d/iptables status
  echo '#grep SELINUX=disabled /etc/selinux/config ' 
  grep SELINUX=disabled /etc/selinux/config 
  echo '#getenforce '
  getenforce 
action "禁用selinux及关闭防火墙完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}
#Init Auto Startup Service
initService(){
echo "===============精简开机自启动===================="
  export LANG="en_US.UTF-8"
  for A in `chkconfig --list |grep 3:on |awk '{print $1}' `;do chkconfig $A off;done
  for B in rsyslog network sshd crond;do chkconfig $B on;done
  echo '+--------which services on---------+'
  chkconfig --list |grep 3:on
  echo '+----------------------------------+'
  export LANG="zh_CN.UTF-8"
action "精简开机自启动完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}
#Change sshd default port and prohibit user root remote login.
initSsh(){
echo "========修改ssh默认端口禁用root远程登录=========="
  \cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%F)
  sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
  sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
  echo '+-------modify the sshd_config-------+'
  echo 'PermitEmptyPasswords no'
  echo 'PermitRootLogin no'
  echo 'UseDNS no'
  echo '+------------------------------------+'
  /etc/init.d/sshd reload && action "修改ssh默认参数完成" /bin/true || action "修改ssh参数失败" /bin/false
echo "================================================="
echo ""
  sleep 2
}
#time sync
syncSysTime(){
echo "================配置时间同步====================="
yum=`which yum`
${yum} -y install ntp >/dev/null 2>&1 || install_ntp='fail'
if [[ "${install_ntp}" = "fail" ]];then
        echo "yum fail! ntp install fail!" 1>&2
        exit 1
else
        grep 'ntpdate' /etc/crontab >/dev/null 2>&1 || ntp_set='no'
        if [[ "${ntp_set}" = "no" ]];then
                echo "*/15 * * * * root ntpdate ${ntp_server} > /dev/null 2>&1" >> /etc/crontab
                service crond restart
        fi
fi
action "配置时间同步完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}
#install tools
initTools(){
  echo "#####install tools#####"
  yum groupinstall base -y
  yum groupinstall core -y
  yum groupinstall development libs -y
  yum groupinstall development tools -y
  echo "install toos complete."
  sleep 1
}
#add user and give sudoers
addUser(){
echo "===================新建用户======================"
#add user
name=sauser
groupadd "$name"
useradd -g "$name" -m "$name" -G wheel -u 2048
echo 'Gaoji_001#' | passwd --stdin "$name"
sleep 1
#add visudo
echo "#####add visudo#####"
\cp /etc/sudoers /etc/sudoers.$(date +%F)
SUDO=`grep -w "$name" /etc/sudoers | wc -l` # 判断/etc/sudoers里面是否配置了
if [[ $SUDO -eq 0 ]];then
    echo "$name  ALL=(ALL)       NOPASSWD: ALL" >>/etc/sudoers
    echo '#tail -1 /etc/sudoers'
    grep -w "$name" /etc/sudoers
    sleep 1
fi
action "创建用户`$name`并将其加入visudo完成"  /bin/true
echo "================================================="
echo ""
sleep 2
}
  
#Adjust the file descriptor(limits.conf)
initLimits(){
echo "===============加大文件描述符===================="
  LIMIT=`grep nofile /etc/security/limits.conf |grep -v "^#"|wc -l`
  if [ $LIMIT -eq 0 ];then
  \cp /etc/security/limits.conf /etc/security/limits.conf.$(date +%F)
  echo '*                  -        nofile         65535'>>/etc/security/limits.conf
  fi
  echo '#tail -1 /etc/security/limits.conf'
  tail -1 /etc/security/limits.conf
  ulimit -HSn 65535
  echo '#ulimit -n'
  ulimit -n
action "配置文件描述符为65535" /bin/true
echo "================================================="
echo ""
sleep 2
}
 
#Optimizing the system kernel
initSysctl(){
echo "================优化内核参数====================="
SYSCTL=`grep "net.ipv4.tcp" /etc/sysctl.conf |wc -l`
if [ $SYSCTL -lt 10 ];then
\cp /etc/sysctl.conf /etc/sysctl.conf.$(date +%F)
cat >>/etc/sysctl.conf<<EOF
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 4000 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_tcp_timeout_established = 180
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
EOF
fi
  \cp /etc/rc.local /etc/rc.local.$(date +%F)  
  modprobe nf_conntrack
  echo "modprobe nf_conntrack">> /etc/rc.local
  modprobe bridge
  echo "modprobe bridge">> /etc/rc.local
  sysctl -p  
action "内核调优完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}


#menu2
menu2(){
while true
do
clear
cat << EOF
----------------------------------------
|****Please Enter Your Choice:[0-9]****|
----------------------------------------
(1) 新建一个用户并将其加入visudo
(2) 配置为国内YUM源镜像
(3) 配置中文字符集
(4) 禁用SELINUX及关闭防火墙
(5) 精简开机自启动
(6) 修改ssh默认端口及禁用root远程登录
(7) 设置时间同步
(8) 加大文件描述符
(9) 内核调优
(0) 返回上一级菜单
EOF
read -p "Please enter your Choice[0-9]: " input2
case "$input2" in
  0)
  clear
  break 
  ;;
  1)
  addUser
  ;;
  2)
  configYum
  ;;
  3)
  initI18n
  ;;
  4)
  initFirewall
  ;;
  5)
  initService
  ;;
  6)
  initSsh
  ;;
  7)
  syncSysTime
  ;;
  8)
  initLimits
  ;;
  9)
  initSysctl
  ;;
  *) echo "----------------------------------"
     echo "|          Warning!!!            |"
     echo "|   Please Enter Right Choice!   |"
     echo "----------------------------------"
     for i in `seq -w 3 -1 1`
       do 
         echo -ne "\b\b$i";
  sleep 1;
     done
     clear
esac
done
}
#initTools
#menu
while true
do
clear
echo "========================================"
echo "System version:$RELEASE"
echo "========================================"
cat << EOF
|-----------System Infomation-----------
| DATE         :$DATE              
| HOSTNAME     :$HOSTNAME
| USER         :$USER
| IP           :$IPADDR
| DISK_USED    :$DISK_SDA
| UNAME        :$NAME
| CPU_AVERAGE  :$cpu_uptime
----------------------------------------
|****Please Enter Your Choice:[1-3]****|
----------------------------------------
(1) 一键初始优化
(2) 自定义初始优化
(3) 退出
EOF
#choice
read -p "Please enter your choice[0-3]: " input1
 
case "$input1" in
1) 
  addUser
  configYum
  initI18n
  initFirewall
  initService
  initSsh
  syncSysTime
  initLimits
  initSysctl
  ;;
  
2)
  menu2
  ;;
3) 
  clear 
  break
  ;;
*)   
  echo "----------------------------------"
  echo "|          Warning!!!            |"
  echo "|   Please Ctrl + C Choice!      |"
  echo "----------------------------------"
  for i in `seq -w 2 -1 1`
      do
        echo -ne "\b\b$i";
        sleep 1;
  done
  clear
esac  
done