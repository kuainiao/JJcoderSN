# bacula 安装使用

------

## 安装bacula

### bacula的几种网络备份拓扑

前面文章介绍了bacula有5个组成部分，在实际的应用中，没有必要将5个部分分别放在不同的服务器上，它们之间的某些部分是可以合并的，常见的bacula部署结构有如下几种：

Director与SD以及Console在一台机器上，而客户端FD在另外一台机器上，当然客户端FD可以有一台或者多台上。 Director与Console在一台机器上，SD在一台机器上，客户端FD在一台或者多台上。 Director与客户端FD、SD以及Console端都在一台机器上，也就是服务器自己备份自己，数据保存在本机。

## [#](http://www.liuwq.com/views/linux基础/bacula.html#编译与安装bacula)编译与安装bacula

这里对上一节的第一种bacula部署结构进行介绍。环境如表4-1所示。

表1 一个bacula部署结构的环境

```
  主机名       ip地址         操作系统   应用角色
  baculaServer 192.168.12.188 CentOS     release 5.4 Director、SD、Console
  baculaClient 192.168.12.189 CentOS     release 5.4 FD
```

整个拓扑结构：

图1 bacula实例的拓扑结构

![markdown write](http://www.liuwq.com/views/linux%E5%9F%BA%E7%A1%80/images/2017/04/untitled.png)

在bacula服务器端安装bacula

首先在http://www.bacula.org下载相应的源码，这里下载的是bacula-5.0.1.tar.gz，接着进行编译安装，安装过程如下：

```
# tar zxvf bacula-5.0.1.tar.gz
# cd bacula-5.0.1
# ./configure --prefix=/opt/bacula --with-mysql=/opt/mysql
# make
# make install
```

bacula需要数据库的支持，这里采用Mysql数据库，并假定Mysql已经在bacula服务器端安装好了，且Mysql安装路径为/opt/mysql（bacula在编译时通过“--with-mysql”选项指定了Mysql数据库的安装路径）。 bacula安装完成后，所有配置文件默认放在/opt/bacula/etc/目录下。

在bacula客户端安装bacula

由于bacula客户端只是是需要备份的客户端，因而只需安装相应的客户端组件即可，过程如下：

```
# tar zxvf bacula-5.0.1.tar.gz
# cd bacula-5.0.1
# ./configure --prefix=/opt/bacula --enable-client-only
# make
# make install
```

## [#](http://www.liuwq.com/views/linux基础/bacula.html#初始化mysql数据库)初始化Mysql数据库

> 在baculaServer上安装完bacula后，还需要创建bacula对应的Mysql数据库以及访问数据库的授权，好在bacula已经为用户准备好了这样的脚本，接下来只要在bacula服务器端上执行如下脚本即可。

```
#cd /opt/bacula/etc
# ./grant_mysql_privileges
# ./create_mysql_database
```

Creation of bacula database succeeded.

```
# ./make_mysql_tables
```

Creation of Bacula MySQL tables succeeded. 接下来可以登录Mysql数据库，查看bacula的数据库和数据表是否已经建立。在执行上面三行Mysql初始代码时，默认由空密码的root用户执行，因此要请确保Mysql数据库root密码为空。

# [#](http://www.liuwq.com/views/linux基础/bacula.html#配置bacula备份系统)配置bacula备份系统

> 其实就是对Director端配置文件bacula-dir.conf、SD配置文件bacula-sd.conf、客户端FD配置文件bacula-fd.conf以及Console端配置文件bconsole.conf进行配置的过程。 根据上面的安装部署，将Director端、SD、Console端集中在一台服务器baculaServer（即192.168.12.188）上，而将客户端FD部署在baculaClient（即192.168.12.189）服务器上，下面详细讲述配置过程。

## [#](http://www.liuwq.com/views/linux基础/bacula.html#配置bacula的console端)配置bacula的Console端

Console端的配置文件是bconsole.conf，这个配置文件很简单，配置完的文件如下：

```
Director {
  Name = f10-64-build-dir #控制端名称，在下面的bacula-dir.conf  和bacula-sd.conf#文件中会陆续的被引用
  DIRport = 9101 #控制端服务端口
  address = 192.168.12.188 #控制端服务器IP地址
  Password = "ouDao0SGXx/F+Tx4YygkK4so0l/ieqGJIkQ5DMsTQh6t"
  #控制端密码文件
}
```

## [#](http://www.liuwq.com/views/linux基础/bacula.html#配置bacula的director端)配置bacula的Director端

bacula-dir.conf是Director端的配置文件，也是bacula的核心配置文件，这个文件非常复杂，共分为10个逻辑段，分别是：

```
  Director，定义全局设置
  Catalog，定义后台数据库
  Jobdefs，定义默认执行任务
  Job，自定义一个备份或者恢复任务
  Fileset，定义备份哪些数据，不备份哪些数据
  Schedule，定义备份时间策略
  Pool，定义供Job使用的池属性
  Client，定义要备份的主机地址
  Storage，定义数据的存储方式
  Messages，定义发送日志报告和记录日志的位置
  代码清单1是一个已经配置好的文件，其中，“#”号后面的内容为注释。
```

代码清单1 已经设置好的Director端的配置文件

```
  Director { #定义bacula的全局配置
  Name = f10-64-build-dir
  DIRport = 9101 #定义Director的监听端口
  QueryFile = "/opt/bacula/etc/query.sql"
  WorkingDirectory = "/opt/bacula/var/bacula/working"
  PidDirectory = "/var/run"
  Maximum Concurrent jobs = 1 #定义一次能处理的最大并发数#验证密码，这个密码必须与bconsole.conf文件中对应的Director逻辑段密码相同
  Password = "ouDao0SGXx/F+Tx4YygkK4so0l/ieqGJIkQ5DMsTQh6t"
```

\#定义日志输出方式，“Daemon”在下面的Messages逻辑段中进行了定义 Messages = Daemon }

```
  Job { #自定义一个备份任务
  Name = "Client1" #备份任务名称
  Client = dbfd #指定要备份的客户端主机，“dbfd”在后面Client逻辑段中进行定义
  Level = Incremental #定义备份的级别，Incremental为增量备份。Level的取值#可为Full（完全备份）、Incremental（增量备份）和Differential（差异备份），如果第一#次没做完全备份，则先进行完全备份后再执行Incrementaltype = Backup #定义Job的类型，“backup”为备份任务，可选的类型还有restore和verify等
  FileSet = dbfs #指定要备份的客户端数据，“dbfs”在后面FileSet逻辑段中进行定义
  Schedule = dbscd #指定这个备份任务的执行时间策略，“dbscd”在后面的Schedule逻辑段中进行了定义
  Storage = dbsd #指定备份数据的存储路径与介质，“dbsd” 在后面的Storage逻辑段中进行定义
  Messages = Standard
  Pool = dbpool #指定备份使用的pool属性，“dbpool”在后面的Pool逻辑段中进行定义。write Bootstrap = "/opt/bacula/var/bacula/working/Client2.bsr" #指定备份的引导信息路径
  }


Job { #定义一个名为Client的差异备份的任务
Name = "Client"
Type = Backup
FileSet = dbfs
Schedule = dbscd
Storage = dbsd
Messages = Standard
Pool = dbpool
Client = dbfd
Level = Differential #指定备份级别为差异备份
Write Bootstrap = "/opt/bacula/var/bacula/working/Client1.bsr"
}


Job { #定义一个名为BackupCatalog的完全备份任务
Name = "BackupCatalog"
Type = Backup
Level = Full #指定备份级别为完全备份
Client = dbfd
FileSet="dbfs"
Schedule = "dbscd"
Pool = dbpool
Storage = dbsd
Messages = Standard
RunBeforeJob = "/opt/bacula/etc/make_catalog_backup bacula bacula"
RunAfterJob = "/opt/bacula/etc/delete_catalog_backup"
Write Bootstrap = "/opt/var/bacula/working/BackupCatalog.bsr"
}


Job { #定义一个还原任务
Name = "RestoreFiles"
Type = Restore #定义Job的类型为“Restore ”，即恢复数据
Client=dbfd
FileSet=dbfs
Storage = dbsd
Pool = dbpool
Messages = Standard
Where = /tmp/bacula-restores #指定默认恢复数据到这个路径
}


FileSet { #定义一个名为dbfs的备份资源，也就是指定需要备份哪些数据，需要排除哪些数据等，可以指定多个FileSet
Name = dbfs
Include {
Options {
signature = MD5; Compression=gzip; } #表示使用MD5签名并压缩file = /cws3 #指定客户端FD需要备份的文件目录
}

Exclude { #通过Exclude排除不需要备份的文件或者目录，可根据具体情况修改
File = /opt/bacula/var/bacula/working
File = /tmp
File = /proc
File = /tmp
File = /.journal
File = /.fsck
}
}

Schedule { #定义一个名为dbscd的备份任务调度策略
Name = dbscd
Run = Full 1st sun at 23:05 #第一周的周日晚23:05分进行完全备份
Run = Differential 2nd-5th sun at 23:05 #第2~5周的周日晚23:05进行差异备份
Run = Incremental mon-sat at 23:05 #所有周一至周六晚23:05分进行增量备份
}


FileSet {
Name = "Catalog"
Include {
Options {
signature = MD5
}
File = /opt/bacula/var/bacula/working/bacula.sql
}
}


Client { #Client用来定义备份哪个客户端FD的数据
Name = dbfd #Clinet的名称，可以在前面的Job中调用
Address = 192.168.12.189 #要备份的客户端FD主机的IP地址
FDPort = 9102 #与客户端FD通信的端口
Catalog = MyCatalog #使用哪个数据库存储信息，“MyCatalog”在后面的MyCatalog逻辑段中进行定义
Password = "ouDao0SGXx/F+Tx4YygkK4so0l/ieqGJIkQ5DMsTQh6t" #Director端与客户端FD的验证密码，这个值必须与客户端FD配置文件bacula-fd.conf中密码相同
File Retention = 30 days #指定保存在数据库中的记录多久循环一次，这里是30天，只影响数据库中的记录不影响备份的文件
Job Retention = 6 months #指定Job的保持周期，应该大于File Retention指定的值
AutoPrune = yes #当达到指定的保持周期时，是否自动删除数据库中的记录，yes表示自动清除过期的Job
}

Client {
Name = dbfd1
Address = 192.168.12.188
FDPort = 9102
Catalog = MyCatalog
Password = "Wr8lj3q51PgZ21U2FSaTXICYhLmQkT1XhHbm8a6/j8Bz"
File Retention = 30 days
Job Retention = 6 months
AutoPrune = yes
}


Storage { # Storage用来定义将客户端的数据备份到哪个存储设备上
Name = dbsd
Address = 192.168.12.188 #指定存储端SD的IP地址
SDPort = 9103 #指定存储端SD通信的端口
Password = "ouDao0SGXx/F+Tx4YygkK4so0l/ieqGJIkQ5DMsTQh6t" #Director端与存储端SD的验证密码，这个值必须与存储端SD配置文件bacula-sd.conf中Director逻辑段密码相同
Device = dbdev #指定数据备份的存储介质，必须与存储端（这里是192.168.12.188）的bacula-sd.conf配置文件中的“Device” 逻辑段的“Name”项名称相同
Media Type = File #指定存储介质的类别，必须与存储端SD（这里是192.168.12.188）的bacula-sd.conf配置文件中的“Device” 逻辑段的“Media Type”项名称相同
}

Catalog { # Catalog逻辑段用来定义关于日志和数据库设定
Name = MyCatalog
dbname = "bacula"; dbuser = "bacula"; dbpassword = "" #指定库名、用户名和密码
}

Messages { # Messages逻辑段用来设定Director端如何保存日志，以及日志的保存格式，可以将日志信息发送到管理员邮箱，前提是必须开启sendmail服务
Name = Standard
mailcommand = "/usr/sbin/bsmtp -h localhost -f \"\(Bacula\) \<%r\>\" -s \"Bacula: %t %e of %c %l\" %r"
operatorcommand = "/usr/sbin/bsmtp -h localhost -f \"\(Bacula\) \<%r\>\" -s \"Bacula: Intervention needed for %j\" %r"
mail = dba.gao@gmail.com = all, !skipped
operator = exitgogo@126.com = mount
console = all, !skipped, !saved
append = "/opt/bacula/log/bacula.log" = all, !skipped #定义bacula的运行日志
append ="/opt/bacula/log/bacula.err.log" = error,warning, fatal #定义bacula的错误日志
catalog = all
}

Messages { #定义了一个名为Daemon的Messages逻辑段，“Daemon”已经在前面进行了引用
Name = Daemon
mailcommand = "/usr/sbin/bsmtp -h localhost -f \"\(Bacula\) \<%r\>\" -s \"Bacula daemon message\" %r"
mail = exitgogo@126.com = all, !skipped
console = all, !skipped, !saved
append = "/opt/bacula/log/bacula_demo.log" = all, !skipped
}


Pool { #定义供Job任务使用的池属性信息，例如，设定备份文件过期时间、是否覆盖过期的备份数据、是否自动清除过期备份等
Name = dbpool
Pool Type = Backup
Recycle = yes #重复使用
AutoPrune = yes #表示自动清除过期备份文件
Volume Retention = 7 days #指定备份文件保留的时间
Label Format ="db-${Year}-${Month:p/2/0/r}-${Day:p/2/0/r}-id${JobId}" #设定备份文件的命名格式，这个设定格式会产生的命名文件为：db-2010-04-18-id139
Maximum Volumes = 7 #设置最多保存多少个备份文件
Recycle Current Volume = yes #表示可以使用最近过期的备份文件来存储新备份
Maximum Volume Jobs = 1 #表示每次执行备份任务创建一个备份文件
}

Console { #限定Console利用tray-monitor获得Director的状态信息
Name = f10-64-build-mon
Password = "RSQy3sRjak3ktZ8Hr07gc728VkZHBr0QCjOC5x3pXEap"
CommandACL = status, .status
}
3 配置bacula的SD

SD可以是一台单独的服务器，也可以和Director在一台机器上，本例就将SD和Director端放在一起进行配置，SD的配置文件是bacula-sd.conf，代码清单2是一个已经配置好的bacula-sd.conf文件。

代码清单2 配置好的bacula-sd.conf文件

Storage { #定义存储，本例中是f10-64-build-sd
Name = f10-64-build-sd #定义存储名称
SDPort = 9103 #监听端口
WorkingDirectory = "/opt/bacula/var/bacula/working"
Pid Directory = "/var/run"
Maximum Concurrent Jobs = 20
}

Director { #定义一个控制StorageDaemon的Director
Name = f10-64-build-dir #这里的“Name”值必须和Director端配置文件bacula-dir.conf中Director逻辑段名称相同
Password = "ouDao0SGXx/F+Tx4YygkK4so0l/ieqGJIkQ5DMsTQh6t" #这里的“Password”值必须和Director端配置文件bacula-dir.conf中Storage逻辑段密码相同
}

Director { #定义一个监控端的Director
Name = f10-64-build-mon #这里的“Name”值必须和Director端配置文件bacula-dir.conf中Console逻辑段名称相同
Password = "RSQy3sRjak3ktZ8Hr07gc728VkZHBr0QCjOC5x3pXEap" #这里的“Password”值必须和Director端配置文件bacula-dir.conf中Console逻辑段密码相同
Monitor = yes
}

Device { #定义Device
Name = dbdev #定义Device的名称，这个名称在Director端配置文件bacula-dir.conf中的Storage逻辑段Device项中被引用
Media Type = File #指定存储介质的类型，File表示使用文件系统存储
Archive Device = /webdata #Archive Device用来指定备份存储的介质，可以是cd、dvd、tap等，这里是将备份的文件保存的/webdata目录下
LabelMedia = yes; #通过Label命令来建立卷文件
Random Access = yes; #设置是否采用随机访问存储介质，这里选择yes
AutomaticMount = yes; #表示当存储设备打开时，是否自动使用它，这选择yes
RemovableMedia = no; #是否支持可移动的设备，如tap或cd，这里选择no
AlwaysOpen = no; #是否确保tap设备总是可用，这里没有使用tap设备，因此设置为no
}

Messages { #为存储端SD定义一个日志或消息处理机制
Name = Standard
director = f10-64-build-dir = all
}
4 配置bacula的FD端

客户端FD运行在一台独立的服务器上，在本例中是baculaclient主机（即192.168.12.189），它的配置文件是bacula-fd.conf，配置好的文件如下：

Director { #定义一个允许连接FD的控制端
Name = f10-64-build-dir #这里的“Name”值必须和Director端配置文件bacula-dir.conf中Director逻辑段名称相同
Password = "ouDao0SGXx/F+Tx4YygkK4so0l/ieqGJIkQ5DMsTQh6t" #这里的“Password”值必须和Director端配置文件bacula-dir.conf中Client逻辑段密码相同
}

Director { #定义一个允许连接FD的监控端
Name = f10-64-build-mon
Password = "RSQy3sRjak3ktZ8Hr07gc728VkZHBr0QCjOC5x3pXEap"
Monitor = yes
}

FileDaemon { #定义一个FD端
Name = localhost.localdomain-fd
FDport = 9102 #监控端口
WorkingDirectory = /opt/bacula/var/bacula/working
Pid Directory = /var/run
Maximum Concurrent Jobs = 20 #定义一次能处理的并发作业数
}

Messages { #定义一个用于FD端的Messages
Name = Standard
director = localhost.localdomain-dir = all, !skipped, !restored
}
启动bacula的Director daemon与Storage daemon

完成上面的配置后，就可以启动或关闭bacula了。在baculaserver上启动或关闭控制端的所有服务，有如下两种方式。

第一种方式如下：

[root@baculaserver etc]# /opt/bacula/sbin/bacula
{start|stop|restart|status}
也可以通过分别管理bacula各个配置端的方式，依次启动或者关闭每个服务：

[root@baculaserver etc]# /opt/bacula/etc/bacula-ctl-dir {start|stop|restart|status}
[root@baculaserver etc]# /opt/bacula/etc/bacula-ctl-sd {start|stop|restart|status}
[root@baculaserver etc]# /opt/bacula/etc/bacula-ctl-fd {start|stop|restart|status}
由于将客户端FD配置到了另一个主机baculaclient上，因此无需在baculaserver上启动File daemon服务。启动bacula的所有服务后，通过netstat命令，观察启动端口情况：

[root@localhost etc]# netstat -antl |grep 91
tcp 0 0 0.0.0.0:9101 0.0.0.0:* LISTEN
tcp 0 0 0.0.0.0:9102 0.0.0.0:* LISTEN
tcp 0 0 0.0.0.0:9103 0.0.0.0:* LISTEN
其中，9101代表Director daemon；9102代表File daemon；9103代表Storage daemon。注意在启动bacula的所有服务前，必须启动MySQL数据库，如果MySQL数据库没有启动，连接bacula的控制端时会报错：

[root@baculaserver opt]# /opt/bacula/sbin/bconsole
Connecting to Director 192.168.12.188:9101
19-04月 09:45 bconsole JobId 0: Fatal error: bsock.c:135 Unable to connect to Director daemon on 192.168.12.188:9101. ERR=拒绝连接
此时，执行netstat命令可以发现，9101端口根本没有启动。

在客户端FD启动File daemon

最后 ，在客户端FD（即baculaclient）上启动File daemon服务，操作如下：

[root@baculaclient etc]# /opt/bacula/sbin/bacula start
Starting the Bacula File daemon
管理客户端FD的服务，也可以通过以下方式完成：

[root@baculaclient etc]# /opt/bacula/sbin/bacula {start|stop|restart|status}
[root@ baculaclient etc]# /opt/bacula/etc/bacula-ctl-fd {start|stop|restart|status}
```