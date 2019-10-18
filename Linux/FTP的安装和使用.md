# FTP 安装和使用

------

# [#](http://www.liuwq.com/views/linux基础/FTP使用.html#ftp-安装使用)FTP 安装使用

## [#](http://www.liuwq.com/views/linux基础/FTP使用.html#环境)环境

Centos 6.5配置FTP服务器

## [#](http://www.liuwq.com/views/linux基础/FTP使用.html#安装步骤)安装步骤

- 安装vsftpd，ftp的服务器

    yum install vsftpd 设置开机启动

    chkconfig vsftpd on 启动服务

    service vsftpd start

## [#](http://www.liuwq.com/views/linux基础/FTP使用.html#配置ftp用户组-用户以及相应权限)配置FTP用户组/用户以及相应权限

- 添加用户组

    `groupadd ftp`

- 添加用户

```shell
  useradd -g ftp -M -d /srv/ftp/zhujin -s /sbin/nologin zhujin
  -g接的是用户组
  -M表示不设置它的主目录，假设如果没有-M，则在/home下会有跟用户名(zhujin)一样的目录。
  -d后面接的是用zhujin登陆FTP的时候，它的初始目录。
  -s 后面接/sbin/nologin表示用户不需要登录系统，因为我们只需要用来登陆FTP
  zhujin表示用户名了
```

- 设置刚才添加的用户的密码

    `passwd zhujin`

- 更改FTP目录的权限

    `chown -R zhujin:ftp /srv/ftp/zhujin` 这时候重启vsftpd

    `/etc/init.d/vsftpd restart`

- 把用户限制在固定的目录

如果这时候登陆会发现刚才新建的用户可以访问并读取所有的目录的数据，这并不是我们想要的，需要把他们限定在某个目录下。修改配置文件 vsftpd.conf，目录一般在/etc/vsftpd/vsftpd.conf，添加下面两行：

chroot_list_enable=YES chroot_list_file=/etc/vsftpd/chroot_list 然后在文件/etc/vsftpd/chroot_list里面填入你想要限制的用户，比如我就填入了zhujin，这时候重启vsftp，然后重新登陆就可以了。

## [#](http://www.liuwq.com/views/linux基础/FTP使用.html#设置匿名用户以及它的根目录)设置匿名用户以及它的根目录

- 允许匿名用户登陆

需要修改配置文件vsftpd.conf，添加下面内容： anonymous_enable=YES

- 设置匿名用户的根目录

需要修改配置文件vsftpd.conf，添加下面内容： anon_root=/srv/ftp/anon 完成后重启一下vsftpd /etc/init.d/vsftpd restart