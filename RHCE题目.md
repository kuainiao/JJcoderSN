1. 重置root密码,并按要求设置网络和主机名,IP设置方法为静态。
主机名:
server0.example.com
IP 地址:
172.25. 0.11
网络掩码:
255.255.255.0
网关:
172.25. 0.254
域名服务器: 172.25.254.254
虚拟机的root密码应该是:tianyun

```
1.重启机器
2.
3.在linux16那一行的末尾加入rd.break console=tty0
4. ctrl+x 启动
5.mount -o rw,remount /sysroot
6.chroot /sysroot
7.passwd
8.touch /.autorelabel
9.exit
10.reboot
11.startx
```

```
nmcli connection reload
nmcli connection down
nmcli connection up "System eth0"
```



1. 配置SELinux环境,将SELinux设为enforcing模式。

    

2. 建立Yum软件仓库,该Yum仓库将作为默认仓库。
  YUM REPO: http://content.example.com/rhel7.0/x86_64/dvd

```
[rhel7]
name=rhel7
baseurl=http://content.example.com/rhel7.0/x86_64/dvd
gpgcheck=0

或者
yum-config-manager -add-repo="http://content.example.com/rhel7.0/x86_64/dvd"
gpgcheck=0
```



1. 调整逻辑卷loans及其上文件系统大小为300M(290 ~ 310M是可以接受的)。

```
lvscan
df -Th
lab lvm setup  # 练习环境准备的逻辑卷
lvextend -L 300M /dev/finance/loans
ext3/4
resize2fs /dev/finance/loans
xfs:
xfs_growfs /dev/finance/loans
```



1. 按要求创建用户组及多个用户,设置用户的候选组,设置用户的默认shell。
  创建组adminuser
  创建用户natasha和harry属于该组,该组为他们的从属组
  创建用户sarah,不属于adminuser,没有交互的shell
  他们的密码都是tianyun

```
groupadd adminuser
useradd natasha -G adminuser
useradd harry -G adminuser
useradd sarah -s /bin/nologin
echo "tianyun" | passwd --stdin natasha
echo "tianyun" | passwd --stdin harry
echo "tianyun" | passwd --stdin sarah
```



1. 配置/var/tmp/fstab的权限
  拷贝/etc/fstab到/var/tmp/fstab
  /var/tmp/fstab属主和属组为root;
  任何人都不能执行;natasha能读写;
  harry没有任何权限;其他和将来的用户能够读。

  ```
  cp -rf /etc/fstab /var/tmp
  setfacl -m u:natasha:rw /var/tmp/fstab
  setfacl -m u:harry:--- /var/tmp/fstab
  getfacl /var/tmp/fstab
  ```

  

2. 设置用户的计划任务cron。
  natasha每天14:20时执行命令:/bin/echo hello

  ```
  crontab -e -u natash
  20 14 * * *  /bin/echo hello
  crontab -l -u natasha
  ```

  

3. 设置目录权限。
  创建共享目录/home/admins;属组为adminuser;
  adminuser组成员对目录有读写和执行的权限,其他所有用户没有任何权限(root能够访问所有文件和目录);
  在/home/admins目录中创建的文件,会自动继承adminuser组

  ```
  mkdir /home/admins
  chgrp adminuser /home/admins
  chmod 770 /home/admins
  chmod g+s /home/admins
  或
  chmod 2770 /home/admins
  ```

  

4. 按指定要求安装升级内核,保证grub2启动时为默认项目,原内核保留。
  YUM REPO: http://content.example.com/rhel7.0/x86_64/errata

  ```
  [kernel]
  name=kernel
  baseurl=http://content.example.com/rhel7.0/x86_64/errata
  gpgcheck=0
  
  yum -y install kernel
  ```

  

5. 绑定外部验证服务
    主机classroom.example.com提供了LDAP验证服务;
    验证服务器的基础DN是dc=example,dc=com
    连接需要使用证书进行加密 http://classroom.example.com/pub/example-ca.crt
    配置成功后能够使用ldapuser0登录到系统,密码为password;
    但没有HOME目录,当配置autofs后,才能生成HOME目录。

    ```
    yum -y install openldap openldap-clients sssd autoconfig-gtk
    autoconfig-gtk 图形
    ssh ladpuser0@localhost
    ```

    

6. 设置NTP服务,同步指定服务器时间。
    让系统作为classroom.example.com 的NTP客户端

    ```
    yum -y install chrony
    vim /etc/chrony.conf
    systemctl enable chronyd
    systenctl start chronyd
    timedatectl
    ```

    

7. 配置autofs自动挂接用户HOME目录。
    ldapuser0用户的HOME目录为classroom.example.com:/home/guests/ldapuser0
    ldapuser0用户的HOME目录挂载到本地/home/guests/ldapuser0
    NFS挂载需要使用版本3

    ```
    yum -y install autofs
    vim /etc/auto.master
    /home/guests /etc/auto.ldap
    vim /etc/auto.ldap
    ldapuser0    -rw,v3     classroom.example.com:/home/guests/ldapuser0
    systemctl enable autofs
    systemctl restart autofs
    查看
    ssh ldapuser0@localhost
    df 
    ```

    

8. 建立用户jack,指定uid为2000,密码为tianyun。

    ```
    useradd jack -u 2000
    passwd jack
    ```

    

9. 创建新的swap分区512M,需要开机自动挂接,注意其它试题可能需要更多的分区。

    ```
    fdisk /dev/vdb  # 分区
    partprobe /dev/vdb  # 刷新分区
    mkswap /dev/vdb5 # 格式化
    vim /etc/fstab
    UUID=""        swap swap defaults 0 0 
    swapon -a 
    swapon -s
    ```

    

10. 查找属于用户alice的所有文件,并将其拷贝到/findfiles。

    ```
                 
    ```

    

11. 在/usr/share/dict/words中查找到所有包含字符串seismic 的行,
    将找出的行按照原文的先后顺序拷贝到/root/filelist文件中。/root/filelist文件不要包含空行

12. 将/etc目录归档并压缩到/root/backup.tar.bz2,使用bzip2压缩。

13. 创建逻辑卷database,属于卷组datastore,逻辑卷的大小为10个物理扩展单元,物理扩展单元(physical extent )
    大小16M。使用ext3文件系统对新的逻辑卷进行格式化。自动挂载在/mnt/database 目录下。

[环境信息]
模拟环境:server0、desktop0
root密码:redhat
example.com: 172.25.0.0/24
cracker.com: 172.24.3.0/24
YUM: http://content.example.com/rhel7.0/x86_64/dvd
==server/desktop==
```
# lab nfskrb5 setup     //仅模拟环境
```

1. 配置server0和desktop0 YUM
2. 配置server0和desktop0上的SELinux环境为enforcing
3. 配置server0和desktop0上的访问控制,拒绝cracker.com域中的主机访问SSH
4. server0和desktop0针对所有用户创建自定义命令psnew,执行该命令是将执行ps -Ao user,pid,ppid,command
5. 配置server0服务器SMB,工作组为STAFF,共享目录/smb1, 共享名smb1,只有example.com域中主机访问
共享smb1,smb1必须可浏览;用户ldapuser1必须能够读取共享中的内容,密码tianyun。
6. 配置server0服务器samba,共享目录/smb2,共享名smb2,只有example.com域中主机访问。用户ldapuser1读取, ldapuser2读写,密码都为tianyun;desktop0以multiuser方式自动挂接到/mnt/smb2
7. 配置server0 NFS服务
以只读的方式共享目录/nfs1,只能被example.com域中主机访问;
以读写的方式共享目录/nfs2,能被example.com域中主机访问
访问/nfs2需要Kerberos安全加密,密钥为 http://classroom.example.com/pub/keytabs/server0.keytab
目录/nfs2应包含名为private拥有者为ldapuser5的子目录,用户ldapuser5能以读写的方式访问/nfs2/private
8. 配置desktop0挂载NFS
/nfs1挂载到/mnt/nfs1
/nfs2挂载到/mnt/nfssecure,并使用安全的方式,密钥为:
http://classroom.example.com/pub/keytabs/desktop0.keytab
ldapuser5用户能在/mnt/nfssecure/private上创建文件
9. 配置server0和desktop0上的链路聚合,使用接口eth1、eth2。当一个接口失效时仍然能够工作。
server0: 192.168.0.1/255.255.255.0
desktop0:
192.168.0.2/255.255.255.0
10. 配置server0端口转发,从172.25.10.0/24网段访问server0端口6666/tcp时,转发到80/tcp
11. 配置server0和desktop0上的IPv6,使用接口eth0,相互可以ping通,原IPv4仍然有效。
server0: 2012:ac18::1205/64
desktop0: 2012:ac18::120a/6412. 配置server0和desktop0邮件服务
server0和desktop0不接收外部邮件
本地发送的邮件会路由到 smtp.example.com
本地发送的邮件显示来自 example.com
可以通过发送邮件到本地用户ldapuser0来测试配置,可通过http://smtp.example.com/received_mail/0查看
13. 配置server0 ISCSI 服务端
提供iscsi磁盘名为 iqn.2017-04.com.tianyun:server0
使用iscsi_store作为其后端卷,其大小为2G
此服务只能被desktop0.example.com访问
提供服务的端口为3260
14. 配置desktop0 ISCSI 客户端
自动连接 iqn.2017-04.com.tianyun:server0
创建大小为500M的分区,格式化为 ext4文件系统,自动挂载到/mnt/iscsidisk
15. 配置server0 web服务,http://www0.example.com
网页:http://classroom.example.com/content/exam/webs/www.html,命名index.html,勿修改内容
将index.html拷贝到 DocumentRoot 目录下;
来自example.com域的客户端可以访问web服务;
来自cracker.com域的客户端拒绝访问web服务。
16. 配置server0 安全的web服务网站https://www0.example.com 启用TLS加密。
已签名证书 http://classroom/pub/tls/certs/www0.crt
此证书的密钥 http://classroom/pub/tls/private/www0.key
此证书的授权信息从http://classroom/pub/example-ca.crt获取
17. 配置server0 虚拟主机,http://server0.example.com
DocumentRoot 为 /var/www/virtual
网页:http://classroom.example.com/pub/webs/server.html,命名index.html,勿修改内容
将index.html拷贝到虚拟机 DocumentRoot 目录下;
确保ldapuser5用户能够在 /var/www/virtual下创建文件;
原始网站 http://www0.example.com 必须仍能访问
18. 配置server0 web内容访问
在server0的 web服务器的DocumentRoot目录下创建目录private
网页:http://classroom.example.com/content/exam/webs/private.html,命名为index.html,勿修改内容
从server0 任何人可以浏览private的内容,但从其它系统不能访问该目录的内容。
19. 配置server0 实现动态web内容
动态内容由 webapp0.example.com 虚拟主机提供
虚拟机监听端口为 8888/tcp
Python application
http://classroom.example.com/content/exam/webs/webapp.wsgi
放置在适当的位置,勿修改脚本中的内容客户端访问http://webapp0.example.com:8888时能接收到动态内容
20. 配置server0 Shell script,/root/script1.sh。
执行/root/script1.sh foo,输出bar
执行/root/script1.sh bar 输出foo
没有任何参数时,输出 Usage /root/script1.sh bar|foo
21. 配置server0 添加用户脚本: /root/batchusers
脚本要求提供一个参数,此参数就是包含用户名列表的文件;
如果没有参数,应给出提示 Usage: /root/batchusers userfile 然后退出返回相应的值;
如果提供一个不存在的文件名,应给出提示消息 Input file not found 然后退出返回相应的值;
设置/bin/false为添加用户默认shell。
22. 配置server0 Mariadb数据库
1) 安装Mariadb
2) 配置root户只能从本地登录,密码为tianyun
3) 禁用匿名用户访问
4) 创建数据库Concats
5) 导入数据到Concats, http://classroom.example.com/content/exam/mariadb/mariadb.dump
6) 授权Luigi用户可以从本地以select方式访问数据库Concats中的表,密码tianyun。
7) 按要求实现单表查询,提交结果
8) 按要求实现多表查询,提交结果

```
重置机器：
rht-vmctl fullreset server
机器状态：
rht-vmctl status all
rht-vmctl status classroom
```

