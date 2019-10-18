一键安装所需环境脚本
一、说明
    脚本运行环境：centos 7
    脚本名称：autodeploy-system7.sh
    更新时间：2018-04-10
    更新人：IT曲哥
    首先，此脚本为个人使用，不针对所有环境，如需使用请自行修改脚本代码参数，由于脚本中涉及的目录没有设置变量，所以所有文件均放到/Tools下面并命名，具体文件我找机会上传，此处留个空链接

    [涉及文件下载](www.baidu.com)
脚本内容：

#!/bin/bash

this script is created by chocolee.br/>author：IT曲哥
e_mail:2211421661@qq.com
qqinfo:2211421661
blog:quguoliang2017.blog.51cto.com
Script update time:2017-09-13

===============================公共变量=================================

Source function library.（添加函数库）
. /etc/init.d/functions

按任意键继续函数
get_char() 
{ 
SAVEDSTTY=stty -g 
stty -echo 
stty cbreak 
dd if=/dev/tty bs=1 count=1 2> /dev/null 
stty -raw 
stty echo 
stty $SAVEDSTTY 
} 
date（设置时间格式）
DATE=date +"%Y-%m-%d %H:%M:%S"
DATE_ymd=date +"%y-%m-%d"
ip（获取IP）
IPADDR_7=ifconfig | grep ‘inet‘| grep -v ‘127.0.0.1‘ | cut -d: -f2 | awk ‘{ print $2}‘
hostname（获取主机名）
HOSTNAME=hostname -s
user（获取用户）
USER=whoami
disk_check（获取根目录磁盘已使用容量）
DISK_SDA=df -h |grep -w "/" |awk ‘{print $5}‘
cpu_average_check （检测CPU在1分、3分、5分时的使用率）
cpu_uptime=cat /proc/loadavg|awk ‘{print $1,$2,$3}‘
free (内存使用率)
phymem=free | grep "Mem:" |awk ‘{print $2}‘
phymemused=free | grep "Mem:" |awk ‘{print $6}‘
free_7=awk ‘BEGIN{printf"%.2f%\n",(‘$phymemused‘/‘$phymem‘)*100}‘
system vresion（获取系统版本）
sys_vresion_7=cat /etc/redhat-release | awk ‘{print $1 " " $4}‘
cpuUsage(cpu使用率)
cpuUsage_7=top -n 1 | awk -F ‘[ %]+‘ ‘NR==3 {print $3}‘

set LANG（设置系统为UTF-8字符集）
export LANG=zh_CN.UTF-8
: > /etc/locale.conf
cat >>/etc/locale.conf<<EOF
LANG=zh_CN.UTF-8
EOF
Require root to run this script.（验证用户是否为root）
uid=id | cut -d\( -f1 | cut -d= -f2
if [ $uid -ne 0 ];then
action "Please run this script as root." /bin/false
action "请检查运行脚本的用户是否为ROOT." /bin/false
exit 1
fi
=========================一键优化系统优化=============================
Config Yum CentOS-Bases.repo
configYum(){
echo "================更新为国内YUM源==================="
cd /etc/yum.repos.d/
mv CentOS-Base.repo CentOS-Base.repo.$(date +%F)
tar cvf repos_backup.tar.gz *
rm -rf ls | egrep -v repos_backup.tar.gz
ping -c 1 www.163.com > /dev/null
if [ $? -eq 0 ];then
curl -O http://mirrors.163.com/.help/CentOS7-Base-163.repo
sed -i ‘s/gpgcheck=1/gpgcheck=0/g‘ CentOS7-Base-163.repo
yum clean all
yum makecache
yum update -y
action "配置国内(163)YUM源完成。" /bin/true
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
else
echo "无法连接网络，请检查网络状态"
exit 1
fi
}

install tools
initTools(){
echo "================初始化基础环境===================="
sed -i ‘s/exclude=kernel centos-release/exclude=centos-release*/g‘ /etc/yum.conf
yum install vim wget zip unzip gcc telnet openssl openssl-devel gcc-c++ cmake libstdc++-devel net-tools man-pages-zh-CN.noarch -y
rpm -qa vim wget zip unzip gcc telnet openssl openssl-devel gcc-c++ cmake libstdc++-devel net-tools man-pages-zh-CN.noarch
action "初始化基础环境完毕。" /bin/true
echo "================================================="
sleep 3
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}

add user and give sudoers
addUser(){
echo "===================新建用户======================="
add user
while true
do
read -p "请输入新用户名:" name
NAME=awk -F‘:‘ ‘{print $1}‘ /etc/passwd|grep -wx $name 2&gt;/dev/null|wc -l
if [ ${#name} -eq 0 ];then
echo "用户名不能为空，请重新输入。"
continue
elif [ $NAME -eq 1 ];then
echo "用户名已存在，请重新输入。"
continue
fi
useradd $name
break
done

create password
while true
do
read -p "为 $name 创建一个密码:" pass1
if [ ${#pass1} -eq 0 ];then
echo "密码不能为空，请重新输入。"
continue
fi
read -p "请再次输入密码:" pass2
if [ "$pass1" != "$pass2" ];then
echo "两次密码输入不相同，请重新输入。"
continue
fi
echo "$pass2" |passwd --stdin $name
break
done
echo "================================================="
sleep 3
add group
echo "================添加visudo文件==================="
\cp /etc/sudoers /etc/sudoers.$(date +%F)
SUDO=grep -w "$name" /etc/sudoers |wc -l
if [ $SUDO -eq 0 ];then
echo "$name ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
echo ‘#tail -1 /etc/sudoers‘
grep -w "$name" /etc/sudoers
fi
action "创建用户$name并将其加入visudo完成。" /bin/true
echo "================================================="
sleep 3
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}

Close Selinux and Iptables
initFirewall(){
echo "============禁用SELINUX及关闭防火墙=============="
systemctl stop firewalld.servic
systemctl disable firewalld
\cp /etc/selinux/config /etc/selinux/config.$(date +%F)
sed -i ‘s/SELINUX=enforcing/SELINUX=disabled/g‘ /etc/selinux/config
setenforce 0
echo ‘#grep SELINUX=disabled /etc/selinux/config ‘ 
grep SELINUX=disabled /etc/selinux/config
echo ‘#getenforce ‘
getenforce
echo ‘#firewall-cmd --state‘
firewall-cmd --state
action "禁用SELINUX及关闭防火墙完成。" /bin/true
echo "================================================"
sleep 3
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}

Change sshd default port and prohibit user root remote login.
initSsh(){
echo "===============修改ssh默认端口=================="
\cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%F)
read -p "请输入SSH服务需要修改的端口号:" sshd
port=cat /etc/ssh/sshd_config | grep -w Port | awk ‘{print $2}‘
if [ $port -lt 65535 ];then
sed -i "s/#Port $port/Port $sshd/g" /etc/ssh/sshd_config
sed -i ‘s/#PermitEmptyPasswords no/PermitEmptyPasswords no/g‘ /etc/ssh/sshd_config
sed -i ‘s/#UseDNS yes/UseDNS no/g‘ /etc/ssh/sshd_config
sed -i ‘s/#ClientAliveInterval 0/ClientAliveInterval 120/g‘ /etc/ssh/sshd_config
sed -i ‘s/#ClientAliveCountMax 3/ClientAliveCountMax 2/g‘ /etc/ssh/sshd_config
sed -i ‘s/#PermitRootLogin yes/PermitRootLogin no/g‘ /etc/ssh/sshd_config
sed -i ‘s/PermitRootLogin yes/PermitRootLogin no/g‘ /etc/ssh/sshd_config
sed -i ‘s/#PrintLastLog yes/PrintLastLog yes/g‘ /etc/ssh/sshd_config
echo "export TMOUT=300" >> ~/.bash_profile
else
echo "输入的端口号过大，请重新输入！"
fi
source ~/.bash_profile
sleep 1
echo "=================配置信息======================"
echo "端口号:$sshd"
echo "允许空密码 no"
echo "使用DNS解析 no"
echo "客户端登录超时时间 18000秒"
echo "客户端最大连接次数 1"
echo "允许ROOT登录 no"
echo "打印上次登录信息 yes"
echo "5分钟无操作自动登出"
echo "=================配置信息======================"
systemctl restart sshd && action "修改ssh默认参数完成。" /bin/true || action "修改ssh参数失败。" /bin/false
echo "================================================"
sleep 3
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}
time sync
syncSysTime(){
echo "================配置时间同步====================="
\cp /var/spool/cron/root /var/spool/cron/root.$(date +%F) 2>/dev/null
NTPDATE=grep ntpdate /var/spool/cron/root 2&gt;/dev/null |wc -l
if [ $NTPDATE -eq 0 ];then
echo "#times sync by lee at $(date +%F)" >> /var/spool/cron/root
echo "/5 * /usr/sbin/ntpdate asia.pool.ntp.org >/dev/null 2>&1" >> /var/spool/cron/root
fi
echo ‘#crontab -l‘ 
crontab -l
date
action "配置时间同步完成。" /bin/true
echo "================================================"
sleep 3
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}

Locking key files
Lockingfiles(){
echo "================锁定关键文件====================="
chattr +i /etc/passwd
chattr +i /etc/inittab
chattr +i /etc/group
chattr +i /etc/shadow
chattr +i /etc/gshadow
action "锁定关键文件完成。" /bin/true
echo "================================================"
sleep 3
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}

Adjust the file descriptor(limits.conf)
initLimits(){
echo "===============加大文件描述符===================="
LIMIT=grep nofile /etc/security/limits.conf |grep -v "^#"|wc -l
if [ $LIMIT -eq 0 ];then
\cp /etc/security/limits.conf /etc/security/limits.conf.$(date +%F)
echo ‘* - nofile 65535‘>>/etc/security/limits.conf
fi
echo ‘#tail -1 /etc/security/limits.conf‘
tail -1 /etc/security/limits.conf
ulimit -HSn 65535
echo ‘#ulimit -n‘
ulimit -n
action "配置文件描述符为65535。" /bin/true
echo "================================================"
sleep 3
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}

Optimizing the system kernel
initSysctl(){
echo "================优化内核参数====================="
\cp /etc/sysctl.conf /etc/sysctl.conf.$(date +%F)
: > /etc/sysctl.conf
cat >>/etc/sysctl.conf<<EOF
开启路由转发功能
net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
表示开启SYN Cookies。当出现SYN等待队列溢出时，启用cookies来处理，可防范少量SYN攻击，默认为0，表示关闭；
net.ipv4.tcp_syncookies = 1
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296 
以下四行标红内容，一般是发现大量TIME_WAIT时的解决办法
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024 65000
用于记录尚未收到客户度确认消息的连接请求的最大值，一般要设置大一些
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_max_tw_buckets = 32768
net.ipv4.route.gc_timeout = 100
用于设置内核放弃TCP连接之前向客户端发生SYN+ACK包的数量，网络连接建立需要三次握手，客户端首先向服务器发生一个连接请求，服务器收到后由内核回复一个SYN+ACK的报文，这个值不能设置过多，会影响服务器的性能，还会引起syn攻击
net.ipv4.tcp_syn_retries = 1
用于调节系统同时发起的TCP连接数，默认值一般为128，在客户端存在高并发请求的时候，128就变得比较小了，可能会导致链接超时或者重传问题。
net.core.somaxconn = 32768
每个网络接口的处理速率比内核处理包的速度快的时候，允许发送队列的最大数目。
net.core.netdev_max_backlog = 65536
避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1
开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1
开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1
修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536
EOF
ulimit=cat /etc/profile | grep -w "ulimit -n 65536" | wc -l
if [ $ulimit -ge 1 ];then
echo "ulimit已配置"
else
sed -i ‘s/ulimit -n 65536//g‘ /etc/profile
echo "ulimit -n 65536" >> /etc/profile
fi
ulimit -n 65536
nf_conntrack=grep "modprobe nf_conntrack" /etc/rc.local |wc -l
if [ $nf_conntrack -lt 1 ];then
modprobe nf_conntrack
echo "modprobe nf_conntrack" /etc/rc.local
fi
bridge=grep "bridge" /etc/rc.local |wc -l
if [ $bridge -lt 1 ];then
modprobe bridge
echo "modprobe bridge">> /etc/rc.local
fi
sysctl -p
action "内核调优完成。" /bin/true
echo "================================================"
sleep 3
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}

del user and group
deluserandgroup(){
echo "===============删除不必要的用户===================="
userdel adm
userdel lp
userdel sync
userdel shutdown
userdel halt
userdel news
userdel uucp
userdel operator
userdel games
userdel gopher
userdel ftp
echo "===============删除不必要的组===================="
groupdel adm
groupdel lp
groupdel news
groupdel uucp
groupdel games
groupdel dip
groupdel pppusers
action "删除不必要的用户和组完成。" /bin/true
echo "================================================"
sleep 3
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}

==============================END==================================
==================一键安装中铁建系统_Nginx安装与配置（Nginx1.12.1）======================
memu2(){
echo "正在安装Nginx服务，请稍后..................................."
groupadd web
useradd -g web web -s /sbin/nologin
yum -y install gcc gcc-c++ autoconf automake zlib zlib-devel openssl openssl-devel pcre* make libjpeg-devel libpng-devel libxml2-devel bzip2-devel libcurl-devel perl perl-devel perl-ExtUtils-Embed
cd /Tools/nginx
tar -zxvf nginx-1.12.1.tar.gz 
cd nginx-1.12.1
./configure --prefix=/usr/local/nginx_tjsc --lock-path=/var/lock/nginx.lock --user=web --group=web --with-http_ssl_module --with-http_flv_module --with-http_mp4_module --with-http_addition_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_perl_module --with-ld-opt=-Wl,-E --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp 
make && make install
mkdir /var/cache/nginx
chown -R web.web /usr/local/nginx_tjsc
优化后的nginx配置文件
mv /usr/local/nginx_tjsc/conf/nginx.conf /usr/local/nginxtjsc/conf/nginx$DATE_ymd.conf
\cp -f /Tools/nginx/nginx.conf /usr/local/nginx_tjsc/conf/nginx.conf
优化隐藏系统版本
mv /usr/local/nginx_tjsc/conf/fastcgi.conf /usr/local/nginxtjsc/conf/fastcgi$DATE_ymd.conf
\cp -f /Tools/nginx/fastcgi.conf /usr/local/nginx_tjsc/conf/fastcgi.conf
优化隐藏系统版本
mv /usr/local/nginx_tjsc/conf/fastcgi_params /usr/local/nginx_tjsc/conf/fastcgiparams$DATE_ymd
\cp -f /Tools/nginx/fastcgi_params /usr/local/nginx_tjsc/conf/fastcgi_params
\cp -r /Tools/nginx/ssl.crt /usr/local/nginx_tjsc/conf/
\cp -r /Tools/nginx/ssl.key /usr/local/nginx_tjsc/conf/
file=/etc/init.d/nginx
if [ -f $file ];then
rm -rf $file
cat >>/etc/init.d/nginx<<EOF
!/bin/bash
chkconfig: - 85 15
nginx_dir=/usr/local/nginx_tjsc
DESC="nginx"
NAME=nginx
DAEMON=\$nginx_dir/sbin/\$NAME
CONFIGFILE=\$nginx_dir/conf/\$NAME.conf
PIDFILE=\$nginx_dir/logs/\$NAME.pid
SCRIPTNAME=/etc/init.d/\$NAME
set -e
[ -x "\$DAEMON" ] || exit 0
do_start() {
\$DAEMON -c \$CONFIGFILE || echo -n "nginx already running"
}
do_stop() {
\$DAEMON -s stop || echo -n "nginx not running"
}
do_reload() {
\$DAEMON -s reload || echo -n "nginx can‘t reload"
}
case "\$1" in
start)
echo -n "Starting \$DESC: \$NAME"
do_start
echo "."
;;
stop)
echo -n "Stopping \$DESC: \$NAME"
do_stop
echo "."
;;
reload|graceful)
echo -n "Reloading \$DESC configuration..."
do_reload
echo "."
;;
restart)
echo -n "Restarting \$DESC: \$NAME"
do_stop
do_start
echo "."
;;
)
echo "Usage: \$SCRIPTNAME {start|stop|reload|restart}" >&2
exit 3
;;
esac
exit 0
EOF
else
cat >>/etc/init.d/nginx<<EOF
!/bin/bash
chkconfig: - 85 15
nginx_dir=/usr/local/nginx_tjsc
DESC="nginx"
NAME=nginx
DAEMON=\$nginx_dir/sbin/\$NAME
CONFIGFILE=\$nginx_dir/conf/\$NAME.conf
PIDFILE=\$nginx_dir/logs/\$NAME.pid
SCRIPTNAME=/etc/init.d/\$NAME
set -e
[ -x "\$DAEMON" ] || exit 0
do_start() {
\$DAEMON -c \$CONFIGFILE || echo -n "nginx already running"
}
do_stop() {
\$DAEMON -s stop || echo -n "nginx not running"
}
do_reload() {
\$DAEMON -s reload || echo -n "nginx can‘t reload"
}
case "\$1" in
start)
echo -n "Starting \$DESC: \$NAME"
do_start
echo "."
;;
stop)
echo -n "Stopping \$DESC: \$NAME"
do_stop
echo "."
;;
reload|graceful)
echo -n "Reloading \$DESC configuration..."
do_reload
echo "."
;;
restart)
echo -n "Restarting \$DESC: \$NAME"
do_stop
do_start
echo "."
;;
)
echo "Usage: \$SCRIPTNAME {start|stop|reload|restart}" >&2
exit 3
;;
esac
exit 0
EOF
fi
chmod u+x /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
systemctl restart nginx
curl -I localhost
if [ $? -eq 0 ];then
echo "================================================="
action "Nginx服务 安装配置成功" /bin/true
echo "================================================="
echo "=====================信息========================"
echo " "
echo "新建用户:web"
echo "新 建 组:web"
echo "Nginx安装目录:/usr/local/nginx_tjsc"
echo "Nginx启动方式:systemctl start nginx"
echo " "
echo "=====================信息========================"
else
echo "================================================="
action "Nginx服务 安装配置失败" /bin/false
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
echo ""
char=get_char 
}
==============================END==================================

==================一键安装中铁建系统_Tomcat安装与配置======================
memu3(){
java_home=cat /etc/profile | grep -i JAVA_HOME= | wc -l
if [ $java_home -eq 1 ];then
echo "================================================="
action "JDK服务 安装配置成功" /bin/true
echo "================================================="
else
echo "正在安装JDK服务，请稍后..................................."
cd /Tools
tar zxvf jdk/server-jre-8u45-linux-x64.tar.gz -C /usr/local/
cat >>/etc/profile<<EOF
export JAVA_HOME=/usr/local/jdk1.8.0_45
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib
export PATH=\$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
EOF
source /etc/profile
java -version
echo "================================================="
action "JDK服务 安装配置成功" /bin/true
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
echo "正在安装Tomcat服务，请稍后..................................."
cd /Tools/tomcat
tar zxvf cronolog-1.6.2.tar.gz
cd cronolog-1.6.2
./configure
make
make install
cd /Tools/tomcat
unzip apache-tomcat-8.0.27.zip -d /usr/local
mv /usr/local/apache-tomcat-8.0.27/ /usr/local/tomcat/
\cp -f apr-1.6.3.tar.gz /usr/local/tomcat/bin
\cp -f apr-iconv-1.2.2.tar.gz /usr/local/tomcat/bin
\cp -f apr-util-1.6.1.tar.gz /usr/local/tomcat/bin
yum install -y expat-devel gcc gcc-c++
cd /usr/local/tomcat/bin
tar zxvf apr-1.6.3.tar.gz
tar zxvf tomcat-native.tar.gz
tar zxvf apr-iconv-1.2.2.tar.gz
tar zxvf apr-util-1.6.1.tar.gz
安装apr
echo "正在安装apr服务，请稍后..................................."
cd apr-1.6.3
./configure 
make && make install
cd ..
安装apr-native
echo "正在安装apr-native服务，请稍后..................................."
cd tomcat-native-1.1.33-src/jni/native 
./configure --with-apr=/usr/local/apr --with-java-home=/usr/local/jdk
make && make install
cd ../../../
安装apr-iconv
echo "正在安装apr-iconv服务，请稍后..................................."
cd apr-iconv-1.2.2 
./configure --with-apr=/usr/local/apr
make && make install
cd ..
安装apr-util
echo "正在安装apr-util服务，请稍后..................................."
cd apr-util-1.6.1 
./configure --with-apr=/usr/local/apr
make && make install
声明变量
LD_LIBRARY_PATH=cat /etc/profile | grep LD_LIBRARY_PATH | wc -l
if [ $LD_LIBRARY_PATH -ge 1 ];then
echo "LD_LIBRARY_PATH已配置"
else
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/apr/lib" >> /etc/profile 
source /etc/profile 
echo "LD_LIBRARY_PATH已配置"
fi
echo "正在创建铁建商城项目目录，请稍后..................................."
mkdir -p /crccmall/mall/system
mkdir -p /crccmall/admin/system
mkdir -p /crccmall/fastdir/system
mkdir -p /crccmall/buyer/system
mkdir -p /crccmall/yunbidding/system
mkdir -p /crccmall/api/system
mkdir -p /crccmall/ebid/system
echo "正在配置铁建商城Tomcat目录，请稍后..................................."
\cp -r /usr/local/tomcat/ /crccmall/mall/tomcat-mall
\cp -r /usr/local/tomcat/ /crccmall/admin/tomcat-admin
\cp -r /usr/local/tomcat/ /crccmall/fastdir/tomcat-fastdir
\cp -r /usr/local/tomcat/ /crccmall/buyer/tomcat-buyer
\cp -r /usr/local/tomcat/ /crccmall/yunbidding/tomcat-yunbidding
\cp -r /usr/local/tomcat/ /crccmall/api/tomcat-api
\cp -r /usr/local/tomcat/ /crccmall/ebid/tomcat-ebid
echo "正在配置铁建商城Tomcat配置，请稍后..................................."
\cp -f /Tools/tomcat/server-mall.xml /crccmall/mall/tomcat-mall/conf/server.xml
\cp -f /Tools/tomcat/server-admin.xml /crccmall/admin/tomcat-admin/conf/server.xml
\cp -f /Tools/tomcat/server-fastdir.xml /crccmall/fastdir/tomcat-fastdir/conf/server.xml
\cp -f /Tools/tomcat/server-buyer.xml /crccmall/buyer/tomcat-buyer/conf/server.xml
\cp -f /Tools/tomcat/server-yunbidding.xml /crccmall/yunbidding/tomcat-yunbidding/conf/server.xml
\cp -f /Tools/tomcat/server-api.xml /crccmall/api/tomcat-api/conf/server.xml
\cp -f /Tools/tomcat/server-ebid.xml /crccmall/ebid/tomcat-ebid/conf/server.xml
chmod -R 755 /crccmall
echo "正在启动Tomcat服务，请稍后..................................."
tomcat_wc=ps aux | grep tomcat | grep -v grep | wc -l
if [ $tomcat_wc -ge 1 ];then
chmod -R 755 /usr/local/tomcat
ps aux | grep tomcat | grep -v grep | awk ‘{print $2}‘ | xargs kill -9
/usr/local/tomcat/bin/startup.sh
echo "================================================="
action "Tomcat服务 安装配置成功" /bin/true
echo "================================================="
echo "=====================信息========================"
echo " "
echo "JDK安装目录:/usr/local/jdk"
echo "Tomcat安装目录:/usr/local/tomcat/"
echo "默认端口：8005、8080、ajp8090（已禁用）"
echo "Tomcat优化项:"
echo "1.apr性能模块。"
echo "2.server.xml文件优化。"
echo "3.catalina.sh文件优化。"
echo "Tomcat启动方式:执行/usr/local/tomcat/bin/startup.sh"
echo " "
echo "=====================信息========================"
ps aux | grep tomcat | grep -v grep | awk ‘{print $2}‘ | xargs kill -9
else
chmod -R 755 /usr/local/tomcat
/usr/local/tomcat/bin/startup.sh
echo "================================================="
action "Tomcat服务 安装配置成功" /bin/true
echo "================================================="
echo "=====================信息========================"
echo " "
echo "JDK安装目录:/usr/local/jdk"
echo "Tomcat安装目录:/usr/local/tomcat/"
echo "默认端口：8005、8080、ajp8090（已禁用）"
echo "Tomcat优化项:"
echo "1.apr性能模块。"
echo "2.server.xml文件优化。"
echo "3.catalina.sh文件优化。"
echo "Tomcat启动方式:执行/usr/local/tomcat/bin/startup.sh"
echo " "
echo "=====================信息========================"
ps aux | grep tomcat | grep -v grep | awk ‘{print $2}‘ | xargs kill -9
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}
==============================END==================================

==================一键安装中铁建系统_Fastdfs-Tracker控制端安装与配置======================
memu4(){
echo "正在安装Fastdfs-Tracker服务，请稍后..................................."
yum install -y libevent gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel
cd /Tools/fastdfs
unzip libfastcommon-master.zip -d /usr/local/
cd /usr/local/libfastcommon-master
./make.sh
./make.sh install
cd /Tools/fastdfs
tar -zxvf fastdfs-5.11.tar.gz -C /usr/local/
cd /usr/local/fastdfs-5.11
./make.sh
./make.sh install
read -p "请输入Storage服务器id(格式及建议100001):" id
read -p "请输入Storage服务器group_id(格式及建议group1):" group_id
read -p "请输入Storage服务器IP:" storage_IP
egrep -v "#|^$" /etc/fdfs/storage_ids.conf.sample > /etc/fdfs/storage_ids.conf
cat >>/etc/fdfs/storage_ids.conf<<EOF
<id> <group_name> <ip_or_hostname>
$id $group_id $storage_IP
EOF
egrep -v "#|^$" /etc/fdfs/tracker.conf.sample > /etc/fdfs/tracker.conf
mkdir -p /fastdfs/tracker /fastdfs/client/
: > /etc/fdfs/tracker.conf
cat >>/etc/fdfs/tracker.conf<<EOF
这个配置文件是否失效
disabled=false 
可以绑定一个ip，默认为空，即绑定所有ip 
bind_addr=
trace server的监听端口
port=22122
连接超时时间，针对socket套接字函数connect，默认为30秒
connect_timeout=30
网络通讯超时时间，默认是60秒
network_timeout=60
用来保存store data和log的地方
base_path=/fastdfs/tracker 
本traceserver最大连接数 
max_connections=65535
接收数据的线程数，默认1个
accept_threads=4
工作线程数，小于max_connections，默认4个
work_threads=4
min_buff_size = 8KB
max_buff_size = 128KB
文件上传选取group的规则：
0:轮询
1:指定服务器组
2:负载均衡，文件上传到可用空间最大的group
store_lookup=1
当store_lookup设置为1时，指定上传的group
store_group=group1
上传文件选择服务器的规则
0:轮询（默认）
1:按照IP排序，排在第一的server
2:按照优先级排序，最小的server
store_server=0
上传文件选择路劲的规则
0:轮询（默认）
2:负载均衡，选择可用空间最大的文件夹
store_path=0
下载文件选择服务器的规则
0:轮询（默认）
1:上传到那台服务器，就从哪台服务器下载
download_server=1
为系统或其他应用程序保留存储空间
如果本机的剩余存储空间小于保留空间，那么本group不再允许上传文件
默认单位是byte
G or g for gigabyte(GB)
M or m for megabyte(MB)
K or k for kilobyte(KB)
no unit for byte(B)
XX.XX% as ratio such as reserved_storage_space = 10%
reserved_storage_space = 10%
日志级别
emerg for emergency
alert
crit for critical
error
warn for warning
notice
info
debug
log_level=info
运行本进程的Unix用户组，如果不设置，默认是当前用户所在的group
run_by_group=
运行本进程的用户名，如果不设置，默认是当前用户的用户名
run_by_user=
可以连接到本机的主机ip范围,代表允许所有服务器
支持这样的表达式:10.0.1.[1-15,20] or host[01-08,20-25].domain.com
allow_hosts=
将缓存中的日志落地到磁盘的间隔时间，默认是10秒
sync_log_buff_interval = 10
检查storage server是否可用的心跳时间，默认是120秒
storage server定期向tracker server 发心跳，如果tracker server在一个check_active_interval内还没有收到storage server的一次心跳，那边将认为该storage server已经下线。所以本参数值必须大于storage server配置的心跳时间间隔。通常配置为storage server心跳时间间隔的2倍或3倍。
check_active_interval = 120
线程栈大小，默认64k，不建议设置小于64k
thread_stack_size = 64KB
当集群中的storage server的ip变化的时候，集群是否自动调整
默认值为true
storage_ip_changed_auto_adjust = true
存储服务器同步一个文件需要消耗的最大时间，缺省为86400s，即一天。
注：本参数并不影响文件同步过程。本参数仅在下载文件时，作为判断当前文件是否被同步完成的一个标准
storage_sync_file_max_delay = 86400
存储服务器之间同步文件的最大延迟时间，缺省为300s，即五分钟。
注：本参数并不影响文件同步过程。本参数仅在下载文件时，作为判断当前文件是否被同步完成的一个标准
storage_sync_file_max_time = 300
是否启用使用一个trunk file来存储数个小文件的模式
默认值为false
use_trunk_file = false
trunk file分配的最小容量，建议小于4k，默认值是256字节
一个文件如果小于256字节，也会在trunk file中分配到256字节
slot_min_size = 256
上传的文件的大小小于这个配置值的时候，会被存储到trunk file中
slot_max_size > slot_min_size
slot_max_size = 16MB
trunk file文件大小
trunk_file_size = 64MB
是否提前创建trunk file，默认值为false
trunk_create_file_advance = false
如果提前创建trunk file，按照这个配置设置的时间来创建
trunk_create_file_time_base = 02:00
创建trunk file的时间间隔, 单位为秒
如果每天只提前创建一次，则设置为86400
trunk_create_file_interval = 86400
当可用的trunk file的尺寸小于此阈值，我们创建trunkfile
比如trunk file的可用尺寸为16G，小于20G，那么会创建4GB的trunk file
trunk_create_file_space_threshold = 20G
在加载trunk file 的时候是否检查可用空间是否被占用的
默认是false ，如果设置为true，会减慢加载trunk file的速度。
trunk_init_check_occupying = false
是否忽略快照文件storage_trunk.dat，只从读取的是trunk binlog的offset，然后从binlog的offset开始加载
缺省为false。只要当从v3.10以下版本升级到v3.10以上版本时，可能才需要打开本选项。
trunk_init_reload_from_binlog = false
压缩trunk binlog 的最小时间间隔，单位：秒
默认值为0，0代表不压缩
FastDFS会在trunk初始化或者被销毁的时候压缩trunk binlog文件
建议设置成86400，一天设置一次
trunk_compress_binlog_min_interval = 0
是否使用storage id 替换 ip，默认为false
use_storage_id = true
指定storage id的文件名，允许使用绝对路径
storage_ids_filename = storage_ids.conf
storage server的id类型
ip:ip地址
id:服务器的id名称
id type of the storage server in the filename, values are:
只有use_storage_id为true时，本配置才有用
id_type_in_filename = ip
存储从文件是否采用symbol link（符号链接）方式
默认为false ， 如果设置为true，一个从文件将占用两个文件：原始文件及指向它的符号链接
store_slave_file_use_link = false
是否定期轮转error log，目前仅支持一天轮转一次
rotate_error_log = true
如果按天轮转错误日志，具体生成新错误日志文件的时间
Hour from 0 to 23, Minute from 0 to 59
error_log_rotate_time=00:00
是否在错误日志文件达到一定大小时生成新的错误日志文件
0代表对日志文件大小不敏感
rotate_error_log_size = 0
日志文件保存日期
0表示永久保存，不删除
默认为0
log_file_keep_days = 7
是否使用连接池，默认不使用
use_connection_pool = false
连接池中连接的超时时间，单位为秒
connection_pool_max_idle_time = 3600
HTTP端口
http.server_port=8080
通过HTTP接口检查storage是否可用，默认心跳时间为30秒
http.check_alive_interval=30
检查storage server是否可用的方式：
tcp表示，只要能建立连接就算服务器可用
http表示，建立连接后，还需要发送一个请求到http.check_alive_uri，并且收到200应答
default value is tcp
http.check_alive_type=tcp
检查storage server是否可用的http页面地址
http.check_alive_uri=/status.html
EOF
storaged=ps -ef | grep fdfs_trackerd | grep -v grep | wc -l
if [ $storaged -gt 0 ];then
ps -aux | grep fdfs_trackerd | grep -v grep |awk ‘{print $2}‘ | xargs kill -9
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf 
else
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf 
fi
tracker_wc=ps -ef | grep trackerd | wc -l
echo "ps -ef | grep trackerd"
ps -ef | grep trackerd
if [ $tracker_wc -gt 0 ];then
echo "================================================="
action "Fastdfs-Tracker服务 安装配置成功" /bin/true
echo "================================================="
echo "=====================信息========================"
echo " "
echo "Fastdfs-Tracker执行命令文件目录:/usr/bin/"
echo "Fastdfs-Tracker配置文件目录:/etc/fdfs/"
echo "Fastdfs-Tracker默认端口:22122"
echo "Fastdfs-Tracker优化参数:"
echo "1.最大连接数65535。"
echo "2.使用storage_ids.conf文件记录storage信息。"
echo "3.httpd服务端口8080。"
echo "Tomcat启动方式:执行/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf"
echo " "
echo "=====================信息========================"
else
echo "================================================="
action "Fastdfs-Tracker服务 安装配置失败" /bin/false
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}
==============================END==================================

==================一键安装中铁建系统_Fastdfs-Storage存储端安装与配置======================
memu5(){
echo "正在安装Fastdfs-Storage服务，请稍后..................................."
yum install -y gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel
cd /Tools/fastdfs
unzip libfastcommon-master.zip -d /usr/local/
cd /usr/local/libfastcommon-master
./make.sh
./make.sh install
ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so 
ln -s /usr/lib64/libfastcommon.so /usr/lib/libfastcommon.so
ln -s /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so
ln -s /usr/lib64/libfdfsclient.so /usr/lib/libfdfsclient.so
cd /Tools/fastdfs
tar -zxvf fastdfs-5.11.tar.gz -C /usr/local/
cd /usr/local/fastdfs-5.11
./make.sh
./make.sh install
read -p "请输入Fastdfs_tracker服务器IP:" IP_1
read -p "请输入Fastdfs_tracker服务器端口(格式及建议22122):" PORT_1
egrep -v "#|^$" /etc/fdfs/storage.conf.sample > /etc/fdfs/storage.conf
mkdir -p /fastdfs/storage /fastdfs/client/
: > /etc/fdfs/storage.conf
cat >>/etc/fdfs/storage.conf<<EOF
disabled=false
group_name=group1
bind_addr=
client_bind=true
port=23000
connect_timeout=30
network_timeout=60
heart_beat_interval=30
stat_report_interval=60

保存store data和log的地方
        base_path=/fastdfs/storage 
        max_connections=256
        buff_size = 256KB
        accept_threads=4
        work_threads=4
        disk_rw_separated = true
        disk_reader_threads = 1
        disk_writer_threads = 1
        sync_wait_msec=50
        sync_interval=0
        sync_start_time=00:00
        sync_end_time=23:59
        write_mark_file_freq=500
        store_path_count=1
        ## 图片实际存放路径,如果有多个,可以有多行
        store_path0=/fastdfs/storage           
        subdir_count_per_path=256
        ## 指定tracker服务器的IP和端口
        tracker_server=127.0.0.1:22122     
        log_level=info
        run_by_group=
        run_by_user=
        allow_hosts=*
        file_distribute_path_mode=0
        file_distribute_rotate_count=100
        fsync_after_written_bytes=0
        sync_log_buff_interval=10
        sync_binlog_buff_interval=10
        sync_stat_file_interval=300
        thread_stack_size=512KB
        upload_priority=10
        if_alias_prefix=
        check_file_duplicate=0
        file_signature_method=hash
        key_namespace=FastDFS
        keep_alive=0
        use_access_log = false
        rotate_access_log = false
        access_log_rotate_time=00:00
        rotate_error_log = false
        error_log_rotate_time=00:00
        rotate_access_log_size = 0
        rotate_error_log_size = 0
        log_file_keep_days = 0
        file_sync_skip_invalid_record=false
        use_connection_pool = false
        connection_pool_max_idle_time = 3600
        http.domain_name=
        http.server_port=80
EOF
echo "tracker_server=$IP_1:$PORT_1" >> /etc/fdfs/storage.conf
echo "/usr/bin/fdfs_storaged /etc/fdfs/storage.conf"
storaged=ps -ef | grep fdfs_storaged | grep -v grep | wc -l
if [ $storaged -gt 0 ];then
ps -aux | grep fdfs_storaged | grep -v grep |awk ‘{print $2}‘ | xargs kill -9
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf 
else
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf 
fi
echo "ps aux | grep storage"
ps aux | grep storage
echo "正在配置客户端，请稍等。。。。。。。。"
egrep -v "#|^$" /etc/fdfs/client.conf.sample > /etc/fdfs/client.conf
: > /etc/fdfs/client.conf
cat >>/etc/fdfs/client.conf<<EOF
connect_timeout=30
network_timeout=60

保存store log的地方
    base_path=/fastdfs/client/       
    ## 指定tracker服务器的IP和端口
    tracker_server=127.0.0.1:22122               
    log_level=info
    use_connection_pool = false
    connection_pool_max_idle_time = 3600
    load_fdfs_parameters_from_tracker=false
    use_storage_id = true
    storage_ids_filename = storage_ids.conf
    http.tracker_server_port=80
EOF
echo "tracker_server=$IP_1:$PORT_1" >> /etc/fdfs/client.conf
echo "storage正在创建连接，请稍等。。。。。。。。"
sleep 5 
echo "正在测试上传，请稍等。。。。。。。。"
cd /Tools
fdfs_test /etc/fdfs/client.conf upload fastdfs/test.png
/usr/bin/fdfs_upload_file /etc/fdfs/client.conf fastdfs/test.png
if [ $? -eq 0 ];then
echo "================================================="
action "Fastdfs-Storage服务 安装配置成功" /bin/true
echo "================================================="
else
echo "================================================="
action "Fastdfs-Storage服务 安装配置失败" /bin/false
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
echo "================开始安装并配置Nginx+fastdfs-nginx-module模块====================="
echo "正在安装Nginx+fastdfs-nginx-module模块，请稍后..................................."
mkdir -p /fastdfs
cd /Tools/fastdfs/
tar zxvf fastdfs-nginx-module_v1.16.tar.gz -C /usr/local/
sed -i ‘s/CORE_INCS="$CORE_INCS \/usr\/local\/include\/fastdfs \/usr\/local\/include\/fastcommon/CORE_INCS="$CORE_INCS \/usr\/include\/fastdfs \/usr\/include\/fastcommon/g‘ /usr/local/fastdfs-nginx-module/src/config
\cp -f /usr/local/fastdfs-5.11/conf/http.conf /etc/fdfs/
\cp -f /usr/local/fastdfs-5.11/conf/mime.types /etc/fdfs/
\cp -f /usr/local/fastdfs-5.11/conf/anti-steal.jpg /etc/fdfs/
\cp -f /usr/local/fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs/
ln -s /fastdfs/storage/data/ /fastdfs/storage/data/M00
echo "正在安装Nginx服务，请稍后..................................."
groupadd web
useradd -g web web -s /sbin/nologin
mkdir -p /var/cache/nginx 
touch /fastdfs/fastdfs.log
yum install -y gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel automake autoconf make perl perl-devel perl-ExtUtils-Embed
cd /Tools/nginx
tar -zxvf nginx-1.12.1.tar.gz 
cd nginx-1.12.1
./configure --prefix=/usr/local/nginx_tjsc --lock-path=/var/lock/nginx.lock --add-module=/usr/local/fastdfs-nginx-module/src --user=web --group=web --with-http_ssl_module --with-http_flv_module --with-http_mp4_module --with-http_addition_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_perl_module --with-ld-opt=-Wl,-E --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp
make && make install
chown -R web.web /usr/local/nginx_tjsc
优化后的nginx配置文件
mv /usr/local/nginx_tjsc/conf/nginx.conf /usr/local/nginxtjsc/conf/nginx$DATE_ymd.conf
\cp -f /Tools/fastdfs/nginx.conf /usr/local/nginx_tjsc/conf/nginx.conf
优化隐藏系统版本
mv /usr/local/nginx_tjsc/conf/fastcgi.conf /usr/local/nginxtjsc/conf/fastcgi$DATE_ymd.conf
\cp -f /Tools/fastdfs/fastcgi.conf /usr/local/nginx_tjsc/conf/fastcgi.conf
优化隐藏系统版本
mv /usr/local/nginx_tjsc/conf/fastcgi_params /usr/local/nginx_tjsc/conf/fastcgiparams$DATE_ymd
\cp -f /Tools/fastdfs/fastcgi_params /usr/local/nginx_tjsc/conf/fastcgi_params
mkdir -p /usr/local/nginx_tjsc/conf/ssl.crt /usr/local/nginx_tjsc/conf/ssl.key
: > /etc/fdfs/mod_fastdfs.conf
cat >>/etc/fdfs/mod_fastdfs.conf<<EOF
connect_timeout=2
network_timeout=30

保存log的目录文件
    base_path=/fastdfs/storage/ 
    load_fdfs_parameters_from_tracker=true
    storage_sync_file_max_delay = 86400
    use_storage_id = false
    storage_ids_filename = storage_ids.conf
    ## tracker服务器的IP和端口 
    storage_server_port=23000
    group_name=group1
    ## 因为访问图片的地址是：http://192.168.1.161/group1/M00/00/00/wKgBoVmSmEOAZS2GAAKjTeiUKok555_big.png 这地址前面有/group1/M00/,所以这里要使用true,不然访问不到（原值为：false）
    url_have_group_name = true            
    store_path_count=1
    ## 图片实际存放路径,可以有多个
    store_path0=/fastdfs/storage/    
    log_level=info
    log_filename=/fastdfs/fastdfs.log
    response_mode=proxy
    if_alias_prefix=
    flv_support = true
    flv_extension = flv
    group_count = 0
EOF
echo "tracker_server=$IP_1:$PORT_1" >> /etc/fdfs/mod_fastdfs.conf
echo "#include http.conf" >> /etc/fdfs/mod_fastdfs.conf 
file=/etc/init.d/nginx
if [ -f $file ];then
rm -rf $file
cat >>/etc/init.d/nginx<<EOF
!/bin/bash
chkconfig: - 85 15
nginx_dir=/usr/local/nginx_tjsc
DESC="nginx"
NAME=nginx
DAEMON=\$nginx_dir/sbin/\$NAME
CONFIGFILE=\$nginx_dir/conf/\$NAME.conf
PIDFILE=\$nginx_dir/logs/\$NAME.pid
SCRIPTNAME=/etc/init.d/\$NAME
set -e
[ -x "\$DAEMON" ] || exit 0
do_start() {
\$DAEMON -c \$CONFIGFILE || echo -n "nginx already running"
}
do_stop() {
\$DAEMON -s stop || echo -n "nginx not running"
}
do_reload() {
\$DAEMON -s reload || echo -n "nginx can‘t reload"
}
case "\$1" in
start)
echo -n "Starting \$DESC: \$NAME"
do_start
echo "."
;;
stop)
echo -n "Stopping \$DESC: \$NAME"
do_stop
echo "."
;;
reload|graceful)
echo -n "Reloading \$DESC configuration..."
do_reload
echo "."
;;
restart)
echo -n "Restarting \$DESC: \$NAME"
do_stop
do_start
echo "."
;;
)
echo "Usage: \$SCRIPTNAME {start|stop|reload|restart}" >&2
exit 3
;;
esac
exit 0
EOF
else
cat >>/etc/init.d/nginx<<EOF
!/bin/bash
chkconfig: - 85 15
nginx_dir=/usr/local/nginx_tjsc
DESC="nginx"
NAME=nginx
DAEMON=\$nginx_dir/sbin/\$NAME
CONFIGFILE=\$nginx_dir/conf/\$NAME.conf
PIDFILE=\$nginx_dir/logs/\$NAME.pid
SCRIPTNAME=/etc/init.d/\$NAME
set -e
[ -x "\$DAEMON" ] || exit 0
do_start() {
\$DAEMON -c \$CONFIGFILE || echo -n "nginx already running"
}
do_stop() {
\$DAEMON -s stop || echo -n "nginx not running"
}
do_reload() {
\$DAEMON -s reload || echo -n "nginx can‘t reload"
}
case "\$1" in
start)
echo -n "Starting \$DESC: \$NAME"
do_start
echo "."
;;
stop)
echo -n "Stopping \$DESC: \$NAME"
do_stop
echo "."
;;
reload|graceful)
echo -n "Reloading \$DESC configuration..."
do_reload
echo "."
;;
restart)
echo -n "Restarting \$DESC: \$NAME"
do_stop
do_start
echo "."
;;
)
echo "Usage: \$SCRIPTNAME {start|stop|reload|restart}" >&2
exit 3
;;
esac
exit 0
EOF
fi
chmod a+x /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
systemctl restart nginx
chown -R web.web /fastdfs/fastdfs.log
curl -I localhost
if [ $? -eq 0 ];then
echo "================================================="
action "nginx+Storage服务 安装配置成功" /bin/true
echo "================================================="
echo "=====================信息========================"
echo " "
echo "Nginx根目录： /usr/local/nginx_fdfs"
echo "Nginx启动命令：systemctl start nginx"
echo "存放编译完成的可执行文件: /usr/bin/"
echo "存放配置文件: /etc/fdfs/"
echo " "
echo "================================================="
else
echo "================================================="
action "nginx+Storage服务 安装配置失败" /bin/false
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}
==============================END==================================

==================一键安装中铁建系统_Redis主安装与配置======================
memu6(){
echo "正在安装Redis主机服务，请稍后..................................."
rpm -qa | grep ruby | awk ‘{print "rpm -e " $1 " --nodeps"}‘| sh
yum -y install gcc gcc-c++ libstdc++-devel tcl ruby ruby-devel rubygems rpm-build bison libffi-devel libtool readline-devel sqlite-devel libyaml-devel
cd /Tools/redis
tar -zxvf redis-3.2.10.tar.gz -C /usr/local/
mv /usr/local/redis-3.2.10/ /usr/local/redis/
cd /usr/local/redis/
make && make install 
\cp -f src/redis-trib.rb /usr/bin/
cd ..
mkdir -p /usr/local/redis/redis_cluster/master1/
mkdir -p /usr/local/redis/redis_cluster/master2/
mkdir -p /usr/local/redis/redis_cluster/master3/
mkdir -p /var/log/redis/master1
mkdir -p /var/log/redis/master2
mkdir -p /var/log/redis/master3
\cp -f /Tools/redis/redis_master1.conf /usr/local/redis/redis_cluster/master1/
\cp -f /Tools/redis/redis_master2.conf /usr/local/redis/redis_cluster/master2/
\cp -f /Tools/redis/redis_master3.conf /usr/local/redis/redis_cluster/master3/
read -p "请输入Redis第一台服务器端口(建议：7000):" master1_PORT
read -p "请输入Redis第二台服务器端口(建议：7001):" master2_PORT
read -p "请输入Redis第三台服务器端口(建议：7002):" master3_PORT
sed -i ‘s/127.0.0.1/‘$IPADDR_7‘/g‘ /usr/local/redis/redis_cluster/master1/redis_master1.conf
sed -i ‘s/127.0.0.1/‘$IPADDR_7‘/g‘ /usr/local/redis/redis_cluster/master2/redis_master2.conf
sed -i ‘s/127.0.0.1/‘$IPADDR_7‘/g‘ /usr/local/redis/redis_cluster/master3/redis_master3.conf
sed -i ‘s/7000/‘$master1_PORT‘/g‘ /usr/local/redis/redis_cluster/master1/redis_master1.conf
sed -i ‘s/7001/‘$master2_PORT‘/g‘ /usr/local/redis/redis_cluster/master2/redis_master2.conf
sed -i ‘s/7002/‘$master3_PORT‘/g‘ /usr/local/redis/redis_cluster/master3/redis_master3.conf
cd /Tools/redis/
tar -zxvf ruby-2.4.2.tar.gz -C /usr/local/
mv /usr/local/ruby-2.4.2/ /usr/local/ruby/
cd /usr/local/ruby
./configure
make
make install
echo #ruby -v
ruby -v
gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
gem sources -l
gem install redis --version 3.2.2 
ln -s /usr/local/bin/ruby /usr/bin/ruby
redis=ps aux | grep redis | grep -v grep| wc -l
if [ $redis -gt 0 ];then
ps aux | grep redis | grep -v grep |awk ‘{print $2}‘ | xargs kill -9
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/master1/redis_master1.conf
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/master2/redis_master2.conf
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/master3/redis_master3.conf
else
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/master1/redis_master1.conf
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/master2/redis_master2.conf
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/master3/redis_master3.conf
fi
echo "===================================================="
ps aux | grep redis | grep -v grep
echo "===================================================="
read -p "请输入Redis备机服务器IP:" BAK1_IP
read -p "请输入Redis备机服务器端口(建议：7003):" BAK1_PORT
read -p "请输入Redis备机服务器IP:" BAK2_IP
read -p "请输入Redis备机服务器端口(建议：7004):" BAK2_PORT
read -p "请输入Redis备机服务器IP:" BAK3_IP
read -p "请输入Redis备机服务器端口(建议：7005):" BAK3_PORT
master1_PORT=cat /usr/local/redis/redis_cluster/master1/redis_master1.conf | grep port | awk ‘{print $2}‘
master2_PORT=cat /usr/local/redis/redis_cluster/master2/redis_master2.conf | grep port | awk ‘{print $2}‘
master3_PORT=cat /usr/local/redis/redis_cluster/master3/redis_master3.conf | grep port | awk ‘{print $2}‘
/usr/local/redis/src/redis-trib.rb create --replicas 1 $IPADDR_7:$master1_PORT $IPADDR_7:$master2_PORT $IPADDR_7:$master3_PORT $BAK1_IP:$BAK1_PORT $BAK2_IP:$BAK2_PORT $BAK3_IP:$BAK3_PORT
if [ $redis -le 3 ];then
echo "================================================="
action "Redis主服务 安装配置成功" /bin/true
echo "================================================="
master1=cat /usr/local/redis/redis_cluster/master1/redis_master1.conf |grep port |awk ‘{print $2}‘
master2=cat /usr/local/redis/redis_cluster/master2/redis_master2.conf |grep port |awk ‘{print $2}‘
master3=cat /usr/local/redis/redis_cluster/master3/redis_master3.conf |grep port |awk ‘{print $2}‘
cluster=cat /usr/local/redis/redis_cluster/master1/redis_master1.conf |grep cluster-enabled |awk ‘{print $2}‘
redis_passwod=cat /usr/local/redis/redis_cluster/master1/redis_master1.conf |grep requirepass |awk ‘{print $2}‘
echo "=====================信息========================"
echo " "
echo "是否开启群集状态：$cluster"
echo "端口号：$master1、$master2、$master3"
echo "Nginx根目录： /usr/local/redis"
echo "密码：$redis_passwod"
echo "Nginx启动命令："
echo "/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/master1/redis_master1.conf"
echo "/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/master2/redis_master2.conf"
echo "/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/master3/redis_master3.conf"
echo " "
echo "================================================="
sleep 1
echo "================================================="
ps aux | grep redis | grep -v grep
echo "================================================="
else
echo "================================================="
action "Redis主服务 安装配置失败" /bin/false
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}
==============================END==================================

==================一键安装中铁建系统_Redis备安装与配置======================
memu7(){
echo "正在安装Redis备机服务，请稍后..................................."
rpm -qa | grep ruby | awk ‘{print "rpm -e " $1 " --nodeps"}‘| sh
yum -y install gcc gcc-c++ libstdc++-devel tcl ruby ruby-devel rubygems rpm-build bison libffi-devel libtool readline-devel sqlite-devel libyaml-devel
cd /Tools/redis
tar -zxvf redis-3.2.10.tar.gz -C /usr/local/
mv /usr/local/redis-3.2.10/ /usr/local/redis/
cd /usr/local/redis
make && make install 
\cp -f src/redis-trib.rb /usr/local/bin/
cd ..
mkdir -p /usr/local/redis/redis_cluster/slave1/
mkdir -p /usr/local/redis/redis_cluster/slave2/
mkdir -p /usr/local/redis/redis_cluster/slave3/
mkdir -p /var/log/redis/slave1
mkdir -p /var/log/redis/slave2
mkdir -p /var/log/redis/slave3
\cp -f /Tools/redis/redis_slave1.conf /usr/local/redis/redis_cluster/slave1/
\cp -f /Tools/redis/redis_slave2.conf /usr/local/redis/redis_cluster/slave2/
\cp -f /Tools/redis/redis_slave3.conf /usr/local/redis/redis_cluster/slave3/
read -p "请输入Redis第一台服务器端口(建议：7003):" slave1_PORT
read -p "请输入Redis第二台服务器端口(建议：7004):" slave2_PORT
read -p "请输入Redis第三台服务器端口(建议：7005):" slave3_PORT
sed -i ‘s/127.0.0.1/‘$IPADDR_7‘/g‘ /usr/local/redis/redis_cluster/slave1/redis_slave1.conf
sed -i ‘s/127.0.0.1/‘$IPADDR_7‘/g‘ /usr/local/redis/redis_cluster/slave2/redis_slave2.conf
sed -i ‘s/127.0.0.1/‘$IPADDR_7‘/g‘ /usr/local/redis/redis_cluster/slave3/redis_slave3.conf
sed -i ‘s/7003/‘$slave1_PORT‘/g‘ /usr/local/redis/redis_cluster/slave1/redis_slave1.conf
sed -i ‘s/7004/‘$slave2_PORT‘/g‘ /usr/local/redis/redis_cluster/slave2/redis_slave2.conf
sed -i ‘s/7005/‘$slave3_PORT‘/g‘ /usr/local/redis/redis_cluster/slave3/redis_slave3.conf
cd /Tools/redis/
tar -zxvf ruby-2.4.2.tar.gz -C /usr/local/
mv /usr/local/ruby-2.4.2/ /usr/local/ruby/
cd /usr/local/ruby
./configure
make
make install
echo #ruby -v
ruby -v
gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
gem sources -l
gem install redis --version 3.2.2 
ln -s /usr/local/bin/ruby /usr/bin/ruby
redis=ps aux | grep redis | grep -v grep| wc -l
if [ $redis -gt 0 ];then
ps aux | grep redis | grep -v grep |awk ‘{print $2}‘ | xargs kill -9
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/slave1/redis_slave1.conf
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/slave2/redis_slave2.conf
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/slave3/redis_slave3.conf
else
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/slave1/redis_slave1.conf
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/slave2/redis_slave2.conf
/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/slave3/redis_slave3.conf
fi
if [ $redis -le 3 ];then
echo "================================================="
action "Redis备服务 安装配置成功" /bin/true
echo "================================================="
master1=cat /usr/local/redis/redis_cluster/slave1/redis_slave1.conf |grep port |awk ‘{print $2}‘
master2=cat /usr/local/redis/redis_cluster/slave2/redis_slave2.conf |grep port |awk ‘{print $2}‘
master3=cat /usr/local/redis/redis_cluster/slave3/redis_slave3.conf |grep port |awk ‘{print $2}‘
cluster=cat /usr/local/redis/redis_cluster/slave1/redis_slave1.conf |grep cluster-enabled |awk ‘{print $2}‘
redis_passwod=cat /usr/local/redis/redis_cluster/slave1/redis_slave1.conf |grep requirepass |awk ‘{print $2}‘
echo "=====================信息========================"
echo " "
echo "是否开启群集状态：$cluster"
echo "端口号：$master1、$master2、$master3"
echo "Nginx根目录： /usr/local/redis"
echo "密码：$redis_passwod"
echo "Nginx启动命令："
echo "/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/slave1/redis_slave1.conf"
echo "/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/slave2/redis_slave2.conf"
echo "/usr/local/redis/src/redis-server /usr/local/redis/redis_cluster/slave3/redis_slave3.conf"
echo " "
echo "================================================="
sleep 1
echo "================================================="
ps aux | grep redis | grep -v grep
echo "================================================="
else
echo "================================================="
action "Redis备服务 安装配置失败" /bin/false
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}
==============================END==================================

==================一键安装中铁建系统_Zookeeper主安装与配置======================
memu8(){
echo "正在安装JDK，请稍后..................................."
java_home=cat /etc/profile | grep -i JAVA_HOME= | wc -l
java -version 2&>1 > /dev/null
if [ $? -eq 1 ] || [ $java_home -eq 1 ];then
source /etc/profile
echo "================================================="
action "JDK服务 安装配置成功" /bin/true
echo "================================================="
else
echo "正在安装JDK服务，请稍后..................................."
cd /Tools
tar zxvf jdk/server-jre-8u45-linux-x64.tar.gz -C /usr/local/
mv /usr/local/jdk1.8.0_45/ /usr/local/jdk/
cat >>/etc/profile<<EOF
export JAVA_HOME=/usr/local/jdk
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib
export PATH=\$JAVA_HOME/bin:\$PATH
EOF
source /etc/profile
java -version
echo "================================================="
action "JDK服务 安装配置成功" /bin/true
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
echo "正在安装Zookeeper服务,请稍后......................"
zoo_cfg=/usr/local/zookeeper/conf/zoo.cfg
cd /Tools/zookeeper
tar -zxvf zookeeper-3.5.2-alpha.tar.gz -C /usr/local/
cd /usr/local/
mv zookeeper-3.5.2-alpha/ zookeeper/
mkdir -p /usr/local/zookeeper/data /var/local/zookeeper/log
\cp -f /Tools/zookeeper/zoo.cfg /usr/local/zookeeper/conf/zoo.cfg
read -p "请输入主zookeeper服务器IP:" IP1
read -p "请输入主zookeeper服务器通讯端口和竞选端口（格式及建议：2881:3881）:" PORT1
read -p "请输入备1zookeeper服务器IP:" IP2
read -p "请输入备1zookeeper服务器通讯端口和竞选端口（格式及建议：2882:3882）:" PORT2
read -p "请输入备2zookeeper服务器IP:" IP3
read -p "请输入备2zookeeper服务器通讯端口和竞选端口（格式及建议：2883:3883）:" PORT3
read -p "请输入本机zookeeper服务器客户端端口（格式及建议：2181）:" PORT4
read -p "请输入本机MYID端口（格式及建议：1）:" PORT5
sed -i ‘s/local_1/‘$IP1‘/g‘ /usr/local/zookeeper/conf/zoo.cfg
sed -i ‘s/1111:2222/‘$PORT1‘/g‘ /usr/local/zookeeper/conf/zoo.cfg
sed -i ‘s/local_2/‘$IP2‘/g‘ /usr/local/zookeeper/conf/zoo.cfg
sed -i ‘s/3333:4444/‘$PORT2‘/g‘ /usr/local/zookeeper/conf/zoo.cfg
sed -i ‘s/local_3/‘$IP3‘/g‘ /usr/local/zookeeper/conf/zoo.cfg
sed -i ‘s/5555:6666/‘$PORT3‘/g‘ /usr/local/zookeeper/conf/zoo.cfg
sed -i ‘s/7777/‘$PORT4‘/g‘ /usr/local/zookeeper/conf/zoo.cfg
echo "$PORT5" > /usr/local/zookeeper/data/myid
zoo_1=ps aux | grep zookeeper | grep -v grep | wc -l
if [ $zoo_1 -gt 0 ];then
ps aux | grep zookeeper | grep -v grep | awk ‘{print $2}‘ | xargs kill -9 
/usr/local/zookeeper/bin/zkServer.sh start
else
/usr/local/zookeeper/bin/zkServer.sh start
fi
echo "正在连接zookeeper。。。。。。。。。。。。。。。。。"
sleep 3
/usr/local/zookeeper/bin/zkServer.sh status
if [ $? -eq 0 ];then
echo "================================================="
action "zookeeper主机服务 安装配置成功" /bin/true
echo "================================================="
echo "====================信息========================"
echo " "
echo "#cat /usr/local/zookeeper/conf/zoo.cfg"
echo "cat /usr/local/zookeeper/conf/zoo.cfg"
echo "myid号：cat /usr/local/zookeeper/data/myid"
echo "myid路径:/usr/local/zookeeper/data/myid"
echo " "
echo "====================信息========================"
else
echo "================================================="
action "zookeeper主机服务 安装配置失败" /bin/false
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}
==============================END==================================
========一键安装Jenkins+Svn+Maven+Java自动化持续集成工具===========
memu9(){
echo "正在安装配置SVN服务,请稍后......................"
rpm -qa | grep subversion
if [ $? -eq 0 ]; then 
echo "======SVN已经安装======" 
svnserve --version
exit 1
else
read -p "请输入svn版本库名称:" svn
yum -y install subversion
fi
groupadd svn
useradd -g svn -s /sbin/nologin svn
mkdir -p /usr/local/svn/svndata
chown -R svn.svn /usr/local/svn/svndata
svnadmin create /usr/local/svn/svndata/$svn
cd /usr/local/svn/svndata/$svn/conf/
=============修改配置==============
\cp authz authz.$(date +%F)
\cp svnserve.conf svnserve.conf.$(date +%F)
\cp passwd passwd.$(date +%F)
echo "[/]" >> authz
echo "admin=wr" >> authz
echo "admin=123456" >> passwd
sed -i ‘s/# auth-access = write/auth-access = write/g‘ svnserve.conf
sed -i ‘s/# password-db = passwd/password-db = passwd/g‘ svnserve.conf
sed -i ‘s/# realm = My First Repository/realm = \/usr\/local\/svn\/svndata\/‘$svn‘/g‘ svnserve.conf
sed -i ‘s/# min-encryption = 0/min-encryption = 0/g‘ svnserve.conf
sed -i ‘s/# max-encryption = 256/max-encryption = 256/g‘ svnserve.conf
svnserve -d -r /usr/local/svn/svndata/$svn/
if [ $? = 0 ];then
action "svn启动成功" /bin/true
sleep 3
else
action "svn启动失败" /bin/flase
fi
svn co svn://$IPADDR_7
if [ $? = 0 ];then
echo "============================================="
echo " SVN安装成功 "
echo "============================================="
echo " 访问地址：svn://$IPADDR_7 "
echo "============================================="
echo " 管理员账号：admin 密码：123456"
echo "============================================="
echo " 版本库：/usr/local/svn/svndata/"$svn
echo "============================================="
sleep 3
else
echo "SVN安装失败！"
fi
echo "正在安装JDK服务,请稍后......................"
java_home=cat /etc/profile | grep -i JAVA_HOME= | wc -l
java -version 2&>1 > /dev/null
if [ $? -eq 1 ] || [ $java_home -eq 1 ];then
echo "================================================="
action "JDK服务 安装配置成功" /bin/true
echo "================================================="
else
cd /Tools
tar zxvf jdk/server-jre-8u45-linux-x64.tar.gz -C /usr/local/
mv /usr/local/jdk1.8.0_45/ /usr/local/jdk/
cat >>/etc/profile<<EOF
export JAVA_HOME=/usr/local/jdk
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib
export PATH=$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
EOF
source /etc/profile
java -version
echo "================================================="
action "JDK服务 安装配置成功" /bin/true
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
echo "正在安装配置maven服务,请稍后......................"
cd /Tools/maven
unzip apache-maven-3.5.0-bin.zip -C /usr/local/ 
export M2_HOME=/usr/local/apache-maven-3.0.5
export PATH=$M2_HOME/bin:$PATH
echo "正在安装配置jenkins服务,请稍后......................"
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
yum clean all
yum makecache
yum install jenkins

echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}
==============================END==================================

===========================一键安装配置docker环境=================================
memu10(){

Confirm Env

date
echo "## Install Preconfirm"
echo "## Uname"
echo 获取系统版本
uname -r
echo
echo 获取磁盘大小
echo "## OS bit"
getconf LONG_BIT
echo

INSTALL yum-utils

date
echo "## 开始安装 : yum-utils"
yum install -y yum-utils >/dev/null 2>&1
if [ $? -ne 0 ]; then
echo "安装失败..."
exit 1
fi
echo

Setting yum-config-manager

echo "## 开始安装 : yum-config-manager"
yum-config-manager \
-add-repo \
https://download.docker.com/linux/centos/docker-ce.repo >/dev/null 2>&1

if [ $? -ne 0 ]; then
echo "安装失败..."
exit 1
fi
echo

Update Package Cache

echo "##开始更新 : Update package cache"
yum makecache fast >/dev/null 2>&1
if [ $? -ne 0 ]; then
echo "缓存失败..."
exit 1
fi
echo

INSTALL Docker-engine

date
echo "## 开始安装 : docker-ce"
yum install -y docker-ce
if [ $? -ne 0 ]; then
echo "安装失败..."
exit 1
fi
date
echo

Stop Firewalld

echo "## 开始配置 : 停止防火墙"
systemctl stop firewalld
if [ $? -ne 0 ]; then
echo "停止失败..."
exit 1
fi
systemctl disable firewalld
if [ $? -ne 0 ]; then
echo "关闭失败..."
exit 1
fi
echo "## Setting ends : stop firewall"
echo

Clear Iptable rules

echo "## 开始配置 : 清除防火墙策略"
iptables -F
if [ $? -ne 0 ]; then
echo "清除防火墙策略失败..."
exit 1
fi
echo

Enable docker

echo "## 开始配置 : 配置docker服务名"
systemctl enable docker
if [ $? -ne 0 ]; then
echo "配置docker失败..."
exit 1
fi
echo

start docker

echo "## 开始启动 : systemctl restart docker"
systemctl restart docker
if [ $? -ne 0 ]; then
echo "启动失败..."
exit 1
fi
echo

confirm docker version

echo "## docker 信息"
docker info
echo

echo "## docker 版本"
docker version

echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
}
==================一键安装jenkins自动化集成系统======================
memu11(){
echo "正在安装JDK，请稍后..................................."
java_home=cat /etc/profile | grep -i JAVA_HOME= | wc -l
java -version 2&>1 > /dev/null
if [ $? -eq 1 ] || [ $java_home -eq 1 ];then
source /etc/profile
echo "================================================="
action "JDK服务 安装配置成功" /bin/true
echo "================================================="
else
echo "正在安装JDK服务，请稍后..................................."
cd /Tools
tar zxvf jdk/server-jre-8u45-linux-x64.tar.gz -C /usr/local/
mv /usr/local/jdk1.8.0_45/ /usr/local/jdk/
cat >>/etc/profile<<EOF
export JAVA_HOME=/usr/local/jdk
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib
export PATH=\$JAVA_HOME/bin:\$PATH
EOF
source /etc/profile
java -version
echo "================================================="
action "JDK服务 安装配置成功" /bin/true
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
cd /etc/yum.repos.d/
wget http://pkg.jenkins.io/redhat/jenkins.repo
rpm --import http://pkg.jenkins.io/redhat/jenkins.io.key
yum install -y jenkins
systemctl start jenkins 
}
==================一键安装zabbix监控系统======================
memu12(){
echo "正在安装依赖包。。。。。。。。。。。。。"

echo "正在安装Mysql数据库。。。。。。。。。。。。。"

echo "正在安装nginx服务。。。。。。。。。。。。。"

echo "正在安装PHP服务。。。。。。。。。。。。。"

echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
} 
==================一键安装vsftpd服务======================
memu13(){
ftp_wc=rpm -qa | grep vsftpd | wc -l
if [ $ftp_wc -ge 1 ]; then
echo "vsftpd 已经安装，正在卸载并重新安装vsftpd服务，请稍后。。。。。。。。。。。"
yum remove -y vsftpd
rm -rf /etc/vsftpd
rm -rf /etc/pam.d/vsftpd
yum install -y vsftpd
else
echo "vsftpd服务未安装，正在安装vsftpd服务，请稍后。。。。。。。。。。。。。"
yum install -y vsftpd
fi
read -p "请输入要创建的FTP登录用户名：" ftp_user
read -p "请输入要创建的FTP登录密码：" ftp_pass
read -p "请输入要创建并使用的FTP用户目录位置：" ftp_dir
useradd $ftp_user -s /sbin/nologin -d $ftp_dir
echo "$ftp_pass" | passwd --stdin "$ftp_user"
rm -rf $ftp_dir/.* 2&>1 > /dev/null
sed -i ‘s/anonymous_enable=YES/anonymous_enable=NO/g‘ /etc/vsftpd/vsftpd.conf
sed -i ‘s/#chroot_local_user=YES/chroot_local_user=NO/g‘ /etc/vsftpd/vsftpd.conf
sed -i ‘s/#chroot_list_enable=YES/chroot_list_enable=YES/g‘ /etc/vsftpd/vsftpd.conf
sed -i ‘s/#chroot_list_file=\/etc\/vsftpd\/chroot_list/chroot_list_file=\/etc\/vsftpd\/chroot_list/g‘ /etc/vsftpd/vsftpd.conf
sed -i ‘s/listen=NO/listen=YES/g‘ /etc/vsftpd/vsftpd.conf
sed -i ‘s/#ascii_upload_enable=YES/ascii_upload_enable=YES/‘ /etc/vsftpd/vsftpd.conf
sed -i ‘s/#ascii_download_enable=YES/ascii_download_enable=YES/‘ /etc/vsftpd/vsftpd.conf
echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf
echo "pasv_promiscuous=YES" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=30000" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=30999" >> /etc/vsftpd/vsftpd.conf
echo "guest_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "guest_username=$ftp_user" >> /etc/vsftpd/vsftpd.conf
echo "user_config_dir=/etc/vsftpd/vuser_conf" >> /etc/vsftpd/vsftpd.conf
sed -i ‘s/listen_ipv6=YES/listen_ipv6=NO/g‘ /etc/vsftpd/vsftpd.conf
echo "$ftp_user" > /etc/vsftpd/chroot_list
mkdir -p /etc/vsftpd/vuser_conf
cat >>/etc/vsftpd/vuser_conf/$ftp_user<< EOF
local_root=$ftp_dir

write_enable=YES

anon_umask=033

anon_world_readable_only=NO

anon_upload_enable=YES

anon_mkdir_write_enable=YES

anon_other_write_enable=YES
EOF
cat >>/etc/vsftpd/vuser_passwd.txt<< EOF
$ftp_user
$ftp_pass
EOF
db_load -T -t hash -f /etc/vsftpd/vuser_passwd.txt /etc/vsftpd/vuser_passwd.db
: > /etc/pam.d/vsftpd
cat >>/etc/pam.d/vsftpd<< EOF
auth required /lib64/security/pam_userdb.so db=/etc/vsftpd/vuser_passwd
account required /lib64/security/pam_userdb.so db=/etc/vsftpd/vuser_passwd
EOF
chown -R $ftp_user $ftp_dir
chmod -R 755 $ftp_dir
systemctl restart vsftpd.service
if [ $? -eq 0 ];then
echo "================================================="
echo " vsftpd服务启动成功 "
echo "================================================="
echo "=====================信息========================"
echo " "
echo "FTP访问地址：ftp://$IPADDR_7"
echo "FTP登录用户名：$ftp_user"
echo "FTP登录密码：$ftp_pass"
echo "vsftpd配置文件目录：/etc/vsftpd"
echo "vsftpd被动模式端口：30000-30999"
echo "vsftpd允许登录的账户：/etc/vsftpd/chroot_list"
echo "vsftpd登录的账户密码：/etc/vsftpd/vuser_passwd.txt"
echo "vsftpd启动命令：systemctl start vsftpd.service"
echo " "
echo "=====================信息========================"
else
echo "================================================="
echo " vsftpd服务启动失败 "
echo "================================================="
fi
echo "================================================="
echo " 验证完毕后请按任意键继续！！ "
echo "================================================="
char=get_char
} 
==============================END==================================

===========================子菜单栏=================================
memu99(){
clear
echo "========================================"
echo ‘ Linux Optimization ‘ 
echo "========================================"
cat << EOF
|-----------System Infomation-----------
| DATE :$DATE
| HOSTNAME :$HOSTNAME
| USER :$USER
| IP :$IPADDR_7
| CPU Usage :$cpuUsage_7
| CPU_AVERAGE:$cpu_uptime
| DISK_USED /:$DISK_SDA
| MEMORY USE:$free_7
| RUNNING ENV:$sys_vresion_7
|Please Enter Your Choice:[0-8]|
(1) 关闭防火墙及Selinux
(2) 配置163yum源
(3) 添加管理用户
(4) 初始化常用环境
(5) 配置SSH策略
(6) 锁定系统关键文件
(7) 描述符优化
(8) sysctl优化
(0) 上一级菜单
EOF
choice
read -p "Please enter your choice[0-8]: " input2
case "$input2" in

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
initFirewall 2>&1 | tee -a /optimization.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
clear
memu99
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
configYum 2>&1 | tee -a /optimization.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
clear
memu99
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
addUser 2>&1 | tee -a /optimization.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
clear
memu99
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
initTools 2>&1 | tee -a /optimization.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
clear
memu99
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
initSsh 2>&1 | tee -a /optimization.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
clear
memu99
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
Lockingfiles 2>&1 | tee -a /optimization.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
clear
memu99
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
initLimits 2>&1 | tee -a /optimization.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
clear
memu99
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
initSysctl 2>&1 | tee -a /optimization.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /optimization.log
clear
memu99
;;

clear
break
;;
)
echo "----------------------------------"
echo "| Warning!!! |"
echo "| Please Enter Right Choice! |"
echo "----------------------------------"
for i in seq -w 3 -1 1
do
echo -ne "\b\b$i";
sleep 1;
done
clear
esac
}
============================菜单栏=================================
while true
do
clear
echo "========================================"
echo " Linux Optimization " 
echo "========================================"
cat << EOF
|-----------System Infomation-----------
| DATE :$DATE
| HOSTNAME :$HOSTNAME
| USER :$USER
| IP :$IPADDR_7
| CPU Usage :$cpuUsage_7
| CPU_AVERAGE:$cpu_uptime
| DISK_USED /:$DISK_SDA
| MEMORY USE:$free_7
| RUNNING ENV:$sys_vresion_7
|Please Enter Your Choice:[0-13]|
(1) 一键优化系统 
(2) 一键安装Nginx安装与配置（Nginx1.12.1）
(3) 一键安装Tomcat安装与配置（Tomcat-8.0.27 || Jdk-1.8.0_45）
(4) 一键安装Fastdfs-Tracker安装与配置（FastDFS_trackerd-5.11）
(5) 一键安装Fastdfs-Storage安装与配置（Nginx-1.12.1 || FastDFS_trackerd-5.11 || fastdfs-nginx-module）
(6) 一键安装Redis主安装与配置（Redis-3.2.10，先备后主的顺序安装！）
(7) 一键安装Redis备安装与配置（Redis-3.2.10，先备后主的顺序安装！）
(8) 一键安装Zookeeper主安装与配置（Zookeeper-3.5.2 || Jdk-1.8.0_45，必须三台以上！）
(9) 一键安装Jenkins+Svn+Maven+Java自动化持续集成工具
(10) 一键安装配置Docker环境
(11) 一键安装jenkins自动化集成系统
(12) 一键安装zabbix监控系统
(13) 一键安装vsftpd服务（yum安装vsftpd）
(99) 自定义优化系统
(0) 退出
EOF
choice
read -p "Please enter your choice[0-13]: " input1
case "$input1" in

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++"
initFirewall 2>&1 | tee -a /optimization.log
configYum 2>&1 | tee -a /optimization.log
addUser 2>&1 | tee -a /optimization.log
initTools 2>&1 | tee -a /optimization.log
initSsh 2>&1 | tee -a /optimization.log
syncSysTime 2>&1 | tee -a /optimization.log
deluserandgroup 2>&1 | tee -a /optimization.log
Lockingfiles 2>&1 | tee -a /optimization.log
initLimits 2>&1 | tee -a /optimization.log
initSysctl 2>&1 | tee -a /optimization.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++"
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu2.log
memu2 2>&1 | tee -a /memu2.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu2.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu3.log
memu3 2>&1 | tee -a /memu3.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu3.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu4.log
memu4 2>&1 | tee -a /memu4.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu4.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu5.log
memu5 2>&1 | tee -a /memu5.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu5.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu6.log
memu6 2>&1 | tee -a /memu6.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu6.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu7.log
memu7 2>&1 | tee -a /memu7.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu7.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu8.log
memu8 2>&1 | tee -a /memu8.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu8.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu9.log
memu9 2>&1 | tee -a /memu9.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu9.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu10.log
memu10 2>&1 | tee -a /memu10.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu10.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu11.log
memu11 2>&1 | tee -a /memu11.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu11.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu12.log
memu12 2>&1 | tee -a /memu12.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu12.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu13.log
memu13 2>&1 | tee -a /memu13.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu13.log
;;

echo "+++++++++++++++开始时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu99.log
memu99 2>&1 | tee -a /memu99.log
echo "+++++++++++++++结束时间：$DATE+++++++++++++++++" 2>&1 | tee -a /memu99.log
;;

clear
break
;;
)
echo "----------------------------------"
echo "| Warning!!! |"
echo "| Please Enter Right Choice! |"
echo "----------------------------------"
for i in seq -w 3 -1 1
do
echo -ne "\b\b$i";
sleep 1;
done
clear
esac
done