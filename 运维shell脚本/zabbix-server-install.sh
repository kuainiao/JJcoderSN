#!/bin/bash
#Zabbix server 部署脚本
#zabbix版本：zabbix3.4
#部署操作系统：Centos7 
 
echo -n "正在配置firewalld防火墙……"
systemctl stop firewalld > /dev/null 2>&1
systemctl disable firewalld  > /dev/null 2>&1
if [ $? -eq 0 ];then
echo -n "firewalld防火墙初始化完毕！"
fi
 
echo -n "正在关闭SELinux……"
setenforce 0 > /dev/null 2>&1
sed -i 's/^SELINUX=enable/SELINUX=disabled/g' /etc/selinux/config
if [ $? -eq 0 ];then
        echo -n "SELinux初始化完毕！"
fi
 
echo -n "正在安装zabbix ……"
rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-1.el7.centos.noarch.rpm
yum -y install zabbix-agent zabbix-get zabbix-sender zabbix-server-mysql zabbix-web zabbix-web-mysql wget  
if [ $? -eq 0 ];then
        echo -n "zabbix server安装完成！"
fi 

echo -n "正在安装mariadb源……"
cat >/etc/yum.repos.d/mariadb.repo<<-EOF
[mariadb]
name = MariaDB 
baseurl = https://mirrors.ustc.edu.cn/mariadb/yum/10.4/centos7-amd64 
gpgkey=https://mirrors.ustc.edu.cn/mariadb/yum/RPM-GPG-KEY-MariaDB 
gpgcheck=1
EOF
if [ $? -eq 0 ];then
        echo -n "mariadb源安装完毕！"
fi

echo -n "正在安装mariadb……"
yum -y install MariaDB-server MariaDB-client
if [ $? -eq 0 ];then
        echo -n "mariadb安装完毕！"
fi

echo -n "正在配置mariadb……"
cp /etc/my.cnf.d/server.cnf{,.bak}
cat > /etc/my.cnf.d/server.cnf<<-EOF
[mysqld]
skip_name_resolve = ON         
innodb_file_per_table = ON     
innodb_buffer_pool_size = 256M 
max_connections = 2000         
log-bin = master-log 
EOF
if [ $? -eq 0 ];then
        echo -n "mariadb配置完毕！"
fi

echo -n "正在启动mariadb……"
systemctl start mariadb
systemctl enable mariadb
if [ $? -eq 0 ];then
        echo -n "Mariadb启动完毕！"
fi
 

#echo -n "正在为mysql的root用户设置密码……"
#mysql_user_root_password="password"
#mysql_user_zabbix_password="zabbix"
#mysqladmin -uroot -p password $mysql_user_root_password
echo "正在执行mysql语句，创建zabbix数据库，授权zabbix访问数据库"
mysql -e "create database zabbix character set utf8;grant all privileges on zabbix.* to zabbix@'%' identified by 'zabbix';grant all privileges on zabbix.* to zabbix@'127.0.0.1' identified by 'zabbix';grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';flush privileges;"
#echo "正在执行mysql语句，创建zabbix数据库，授权zabbix访问数据库"
#mysql -uroot -p"$mysql_user_root_password" -e "create database zabbix character set utf8" && echo "创建zabbix数据库完成"
#mysql -uroot -p"$mysql_user_root_password" -e "grant all privileges on zabbix.* to zabbix@localhost identified by '$mysql_user_zabbix_password'" && echo "授权zabbix本地登录数据库"
#mysql -uroot -p"$mysql_user_root_password" -e "grant all privileges on zabbix.* to zabbix@'%' identified by '$mysql_user_zabbix_password'" && echo "授权任何主机本地登录数据库"
 
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -pzabbix zabbix

#mysql -uzabbix -pzabbix zabbix < ${src_homie}/zabbix-3.0.4/database/mysql/schema.sql
#mysql -uzabbix -pzabbix zabbix < ${src_homie}/zabbix-3.0.4/database/mysql/images.sql
#mysql -uzabbix -pzabbix zabbix < ${src_homie}/zabbix-3.0.4/database/mysql/data.sql
if [ $? -eq 0 ];then
        echo -n "zabbix数据导入启动完毕！"
fi  
echo -n "正在配置zabbix配置文件...."
cd /etc/zabbix/
sed -i 's/# DBHost=localhost/DBHost=192.168.95.1/g' zabbix_server.conf 
sed -i '/# DBPassword=/a\DBPassword=zabbix' zabbix_server.conf
sed -i '/# EnableRemoteCommands=0/a\EnableRemoteCommands=1' zabbix_agentd.conf
sed -i '/# ListenPort=10050/a\ListenPort=10050' zabbix_agentd.conf
sed -i '/# User=zabbix/a\User=zbxuser' zabbix_agentd.conf
sed -i '/# DBPassword=/a\DBPassword=keer' zabbix_agentd.conf
sed -i '/# DBPassword=/a\DBPassword=keer' zabbix_agentd.conf
DBPort=3306 
sed -i '/# AllowRoot=0/a\AllowRoot=1' zabbix_agentd.conf
sed -i '/# UnsafeUserParameters=0/a\UnsafeUserParameters=1' zabbix_agentd.conf
if [ $? -eq 0 ];then
        echo -n "zabbix配置完毕！"
fi

配置zabbix-agent????


echo -n "正在启动zabbix_server and zabbix_agent...."
systemctl start zabbix-server.service 
systemctl start zabbix-agent.service
systemctl enable zabbix-server.service 
systemctl enable zabbix-agent.service
if [ $? -eq 0 ];then
        echo -n "zabbix-server zabbix-agent 启动完毕！"
fi
 
echo -n "正在配置zabbix httpd ,php..."
sed -i '/^post_max_size =/s/=.*/= 16M/' /etc/php.ini
sed -i '/^max_execution_time =/s/=.*/= 300/' /etc/php.ini
sed -i '/^max_input_time =/s/=.*/= 300/' /etc/php.ini
sed -i '/^;date.timezone/a\date.timezone =  Asia/Shanghai' /etc/php.ini
sed -i '/^;always_populate_raw_post_data.*/a\always_populate_raw_post_data = -1' /etc/php.ini
sed -i '/^mysqli.default_socket =/s/=.*/= \/var\/lib\/mysql\/mysql.sock/' /etc/php.ini

echo -n "正在启动httpd服务....."
systemctl start httpd
systemctl enable httpd
 
echo -n "正在安装中文字体支持包，解决zabbix server 乱码问题,请你耐心等待....."
yum groupinstall "fonts" -y
echo -n "使用文泉驿小黑字体"
rm /etc/alternatives/zabbix-web-font -rf
ln -s /usr/share/fonts/wqy-microhei/wqy-microhei.ttc /etc/alternatives/zabbix-web-font
 
 
echo -n "恭喜你,Zabbix 部署到此完成！！！"
echo -e -n "后续的操作:1、通过http://ip/zabbix 访问你的zabbix Web页面,下一步...."
 
 
