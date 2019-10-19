# 企业级分布式存储应用与实战MogileFS、FastDFS

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192643253-1858308752.png)

企业级分布式存储应用与实战-mogilefs

　　环境：公司已经有了大量沉淀用户，为了让这些沉淀用户长期使用公司平台，公司决定**增加用户粘性，逐步发展基于社交属性的多样化业务模式**，决定开展用户讨论区、卖家秀、买家秀、用户试穿短视频等业务，因此，公司新的业务的业务特征将需要海量数据存储，你的领导要求基于开源技术，实现对公司海量存储业务的技术研究和实现，你可以完成任务吗？

 **总项目流程图**，详见 http://www.cnblogs.com/along21/p/8000812.html

 

实验前准备：配置好yum源、防火墙关闭、各节点时钟服务同步

 

## 实战一：企业级分布式存储应用与实战 mogilefs 实现

**架构图**

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192644081-758113981.png)

### 原理

（1）mogileFS主要由三部分构成：**tracker节点，database节点，storage节点**

① **Tracker(MogileFSd 进程)**：这个是 MogileFS 的核心部分，他是一个**调度器**，MogileFSd 进程就是trackers进程程序，trackers 做了很多工作：Replication,Deletion,Query,Reaper,Monitor 等等，这个是基于事件的( event-based ) 父进程/消息总线来管理所有来之于客户端应用的交互(requesting operations to be performed),，包括将请求负载平衡到多个"query workers"中，然后让 MogileFSd 的子进程去处理；

② **MySQL**：用来存放 MogileFS 的**元数据 (命名空间, 和文件在哪里)**，是Trackers 来操作和管理它，可以用mogdbsetup程序来初始化数据库，因为数据库保存了MogileFS的所有元数据，建议做成HA架构；

③ **Storage Nodes**：这个是 MogileFS 存储文件存放在这些机器上,也是 mogstored 节点,也叫Storage Server,一台存储主要都要启动一个 mogstored 服务.扩容就是增加这些机器，**实际文件存放的地方**。

 

（2）MogileFS管理的几个概念：

① **Domain域**：一个MogileFS可以有多个Domain，用来存放不同文件（大小，类型），同一个Domain内**key必须唯一**，**不同Domain内，key可以相同；**

② 每一个存储节点称为一个**主机host**，一个主机上可以有多个存储设备dev(单独的硬盘)，每个设备都有ID号，Domain+Fid用来定位文件。

③ **Class**：文件属性管理，定位文件存储在不同设备上的**份数**；

 

（3）工作流程

**每次**文件的上传和读取，**都经过前端TrackerServer 服务器**，trackerServer 服务器**受到client 端的请求**，**查询数据库**，**返回一个**上传或者是读取的可用的**后端StorageServer 的地址**，然后由**client 端**直接**操作后端StorageServer 服务器**。upload 操作返回就是成功或者失败的结果，read操作就是返回对应的查询数据。

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192644581-1173750007.png)

 

**（4）mogilefs 服务很特殊：服务配置完毕，开启服务后；还需命令行命令，服务才能真正生效！**

 

### 1、环境准备

| 机器名称      | IP配置         | 服务角色 | 备注           |
| ------------- | -------------- | -------- | -------------- |
| tracker-srv   | 192.168.30.107 | 调度器   | tracker、mysql |
| storage node1 | 192.168.30.7   | 文件存放 | mogstored 服务 |
| storage node2 | 192.168.30.2   | 文件存放 | mogstored 服务 |

 

### 2、下载安装，每个机器都一样

两个安装方式：yum安装 和 perl程序安装

**方法一：yum安装（推荐）**

（1）所依赖的包，centos 自带的

yum install perl-Net-Netmask perl-IO-String perl-Sys-Syslog perl-IO-AIO

 

（2）服务的rpm包，我已经放在我的网盘里了，需要的私聊 http://pan.baidu.com/s/1c2bGc84

MogileFS-Server-2.46-2.el6.noarch.rpm     #核心服务

perl-Danga-Socket-1.61-1.el6.rf.noarch.rpm  #socket

MogileFS-Server-mogilefsd-2.46-2.el6.noarch.rpm   # tracker节点

perl-MogileFS-Client-1.14-1.el6.noarch.rpm  #客户端

MogileFS-Server-mogstored-2.46-2.el6.noarch.rpm  #Storage存储节点

MogileFS-Utils-2.19-1.el6.noarch.rpm   #主要是MogileFS的一些管理工具，例如mogadm等。

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192644987-1088605019.png)

 

（3）开始安装

cd mogileFS/

yum localinstall ./* -y

 

**方法二：perl程序源码包安装**：通过perl的包管理命令cpanm进行安装

（1）依赖的包

yum -y install make gcc unzip perl-DBD-MySQL perl perl-CPAN perl-YAML perl-Time-HiRes

（2）cpanm安装

wget http://xrl.us/cpanm -O /usr/bin/cpanm;

sudo chmod +x /usr/bin/cpanm

\#cpanm DBD::mysql

\#cpanm MogileFS::Server

\#cpanm MogileFS::Utils

\#cpanm MogileFS::Client

\#cpanm IO::AIO

 

### 3、数据库初始化

（1）创建mogilefs 所需要的用户并授权

systemctl start mariadb 开启mysql服务

```
MariaDB [mogilefs]> GRANT ALL PRIVILEGES ON mogilefs.* TO 'mogile' @'127.0.0.1' IDENTIFIED BY 'mogile' WITH GRANT OPTION;
MariaDB [mogilefs]> flush privileges;    刷新下权限
```

（2）设定数据库：数据库初始化

**mogdbsetup --dbpass=mogile**

 

### 4、在tracker-srv 服务器上，启动mogilefsd服务

（1）修改管理tracker 的配置文件

vim /etc/**mogilefs/mogilefsd.conf**

```
① 配置数据库连接相关信息
db_dsn = DBI:mysql:mogilefs:host=127.0.0.1
db_user = mogile
db_pass = mogile
② 下边的只需修改监听地址和端口
listen = 192.168.30.107:7001 #mogilefs监听地址，监听在127.0.0.1表示只允许从本机登录进行管理
query_jobs = 10   #启动多少个查询工作线程
delete_jobs = 1    #启动多少个删除工作线程
replicate_jobs = 5   #启动多少个复制工作线程
reaper_jobs = 1      #启动多少个用于回收资源的线程
maxconns = 10000   #存储系统的最大连接数.
httplisten = 0.0.0.0:7500   #可通过http访问的服务端口
mgmtlisten = 0.0.0.0:7501   #mogilefs的管理端口
docroot = /var/mogdata   #该项决定了数据的在storage上存储的实际位置,建议使用的是一个单独挂载使用的磁盘
```

（2）创建进程需要的目录，并授权

mkdir /var/run/mogilefsd/

chown -R mogilefs.mogilefs /var/run/mogilefsd

 

（3）开启服务

**/etc/init.d/mogilefsd start**

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192645347-983737594.png)

有时候会显示启动失败；但实际则是启动成功了。可以

ss -nutlp|grep mogilefs 查询是否有mogilefsd 的监听ip和端口

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192645690-1342235373.png)

 

### 5、在两台storage node 上，启动mogstored服务

（1）修改storage node 的配置文件

vim /etc/**mogilefs/mogstored.conf**

```
maxconns = 10000   #存储系统的最大连接数.
httplisten = 0.0.0.0:7500    #可通过http访问的服务端口
mgmtlisten = 0.0.0.0:7501   #mogilefs的管理端口
docroot = /data/mogdata    #该项决定了数据的在storage上存储的实际位置,建议使用的是一个单独挂载使用的磁盘
```

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192646034-1467575814.png)

 

（2）创建storage 存储的目录

mkdir -p /data/mogdata

（3）授权

cd /data/

chown mogilefs.mogilefs mogdata/ -R

（4）开启服务，有时候开启服务显示失败，其实已经成功

/etc/init.d/mogstored start

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192646581-161857885.png)

 

### 6、修改客户端工具配置

vim /etc/mogilefs/mogilefs.conf 客户端工具配置文件

trackers=192.168.30.107:7001 #自己的tracker 的服务IP和端口

 

### 7、storage node 节点加入到MogileFS 的系统中

**在tracker 的服务器上：**

**（1）加入"存储节点**storage node1/2**"到 trackers 中**

```
mogadm --tracker=192.168.30.107:7001 host add node1 --ip=192.168.30.7 --port=7500 --status=alive
mogadm --tracker=192.168.30.107:7001 host add node2 --ip=192.168.30.2 --port=7500 --status=alive
```

（2）查询信息，检查主机是否加入到 MogileFS 的系统中

mogadm **check**

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192647222-174962243.png)

mogadm **host list**

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192647597-70740089.png)

 

（3）当然，操作错误也可以修改

mogadm host **modify** node1 --ip=192.168.30.7 --port=7500 --status=alive

 

### 8、创建设备

**在两个storage node 服务器上：**

（1）创建"设备"实验的目录并授权，格式： dev + ID

**注意：所有系统中 ID 不能重复，也必须和配置文件中的路径一样**

cd mogdata/

mkdir dev1

chown mogilefs.mogilefs dev1/ -R 加权限

设置成功，会在dev1下生成一个文件，是tracker 过来测试留下来的

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192648003-1697881063.png)

 

（2）在另一台服务器上也一样

cd mogdata/

mkdir dev2

chown mogilefs.mogilefs dev2/ -R

 

### 9、两个设备加入 MogileFS 的存储系统中

（1）在tracker 上

**mogadm** --tracker=192.168.30.107:7001 **device add node1 1**

```
mogadm --tracker=192.168.30.107:7001 device add node1 1
mogadm --tracker=192.168.30.107:7001 device add node2 2
```

（2）查看设备信息

mogadm check 检测出来两个设备的信息了

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192648659-2112275214.png)

mogadm device list 能查询设备的详细信息

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192649112-763462984.png)

 

（3）在数据库中也能查出设备

MariaDB [mogilefs]> select * from device;

MariaDB [mogilefs]> select * from host;

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192649550-767172410.png)

 

### 10、划分域、class

mogadm **domain add img** 创建一个img域

mogadm **class** add img **along --mindevcount=3** 在img域中创建一个along的class，可以存放3份

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192650050-1361352631.png)

 

### 11、上传文件且测试

（1）上传一张图片

mogupload --domain=img --key=test --file=along.jpg 向img域中上传一张along.jpg的图片，key为test

mogfileinfo --domain=img --key=test 查询文件

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192650409-1027853907.png)

 

（2）网页访问http://192.168.30.2:7500/dev2/0/000/000/0000000002.fid

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192650878-1991016147.png)

 

（3）当然，也可以删除图片

**mogdelete** --domain=img --key=test

 

（4）在数据库也能查看到

MariaDB [mogilefs]> select * from file;

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192651190-417131413.png)

 

（5）在后端两个storage node 上也能查到图片，图片就是存放到storage node服务器上的

注意：本来，后端两个storage node 上应该都有存放的图片，**能互相复制，是副本关系**，但这一版本有BUG

我的只有在storage node2 上才有这张图片

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192651534-1614372459.png)

 

### 12、修复bug，实现后端storage node 同步存储

分析：因为这个版本有bug，所以需降版本

（1）下载包

wget http://search.cpan.org/CPAN/authors/id/B/BR/BRADFITZ/Sys-Syscall-0.23.tar.gz

也可以http://search.cpan.org/CPAN/authors/id/B/BR/BRADFITZ/Sys-Syscall-0.23.tar.gz 去网站直

接下载

（2）上传，解压缩

rz，tar xvf Sys-Syscall-0.23.tar.gz -C /tmp

（3）**编译安装**

① 因为是perl 语言编写的，所以需要安装perl 编译安装的环境

yum -y install make gcc unzip perl-DBD-MySQL perl perl-CPAN perl-YAML perl-Time-HiRes

② 编译安装

cd /tmp/Sys-Syscall-0.23/

perl Makefile.PL 准备环境

make & make install

 

（4）重启服务

① 在tracker 服务器是，有时候开启服务显示失败，其实已经成功

/etc/init.d/mogilefsd stop

/etc/init.d/mogilefsd start

② 在storage node 服务器上，有时候开启服务显示失败，其实已经成功

/etc/init.d/mogstored stop

/etc/init.d/mogstored start

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192652097-67911727.png)

 

（5）测试

① 再上传一张图片

mogupload --domain=img --key=test1 --file=along.jpg

② 在两个storage node 服务器上，存储已经实现同步

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192652800-731203974.png)

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192653237-495964688.png)

 

## 实战二：mogilefs、mysql主从和keepalived 高可用实现分布式存储

**![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128194530456-1488033359.png)**

**原理：**在database 上实现**mysql的主从**；且为了提升性能，在**每个节点上都配置tracker**

**主mysql宕机，从mysql上数据没有丢失；且VIP能漂到从mysql上，继续提供服务**

### 1、环境准备

| 机器名称              | IP配置         | 服务角色 | 备注             |
| --------------------- | -------------- | -------- | ---------------- |
| mogilefs-mysql-master | 192.168.30.107 | 主数据库 | tracker、mysql   |
| mogilefs-mysql-slave  | 192.168.30.7   | 从数据库 | tracker、mysql   |
| mogilefs-store1       | 192.168.30.2   | 文件存放 | tracker、storage |
| mogilefs-store2       | 192.168.30.3   | 文件存放 | tracker、storage |

 

### 2、在所有机器上下载安装mogilefs

（1）所依赖的包，centos 自带的

yum install perl-Net-Netmask perl-IO-String perl-Sys-Syslog perl-IO-AIO

 

（2）服务的rpm包，我已经放在我的网盘里了，需要的私聊 http://pan.baidu.com/s/1c2bGc84

MogileFS-Server-2.46-2.el6.noarch.rpm #核心服务

perl-Danga-Socket-1.61-1.el6.rf.noarch.rpm #socket

MogileFS-Server-mogilefsd-2.46-2.el6.noarch.rpm # tracker节点

perl-MogileFS-Client-1.14-1.el6.noarch.rpm #客户端

MogileFS-Server-mogstored-2.46-2.el6.noarch.rpm #Storage存储节点

MogileFS-Utils-2.19-1.el6.noarch.rpm #主要是MogileFS的一些管理工具，例如mogadm等。

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192653706-1502495837.png)

 

（3）开始安装

cd mogileFS/

yum localinstall ./* -y

 

### 3、在两台mysql上实现主从

（1）**在主mysql 上**

① vim /etc/my.cnf 修改mysql主配置文件，对master进行配置，包括打开二进制日志，指定唯一的servr ID

```
server-id=1         #配置server-id，让主服务器有唯一ID号
log-bin=mysql-bin   #打开Mysql日志，日志格式为二进制
skip-name-resolve   #关闭名称解析，（非必须）
```

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98MogileFS%E3%80%81FastDFS.assets/1216496-20171128192654019-1689847096.png)

systemctl start mariadb 开启服务

 

② **创建并授权**slave mysql 用的复制帐号

MariaDB [(none)]> grant replication slave,replication client on *.* to slave@'192.168.30.7' identified by 'along';

 

③ 查看主服务器状态

在Master的数据库执行show master status，查看主服务器二进制日志状态，位置号

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192654519-2058255815.png)

 

（2）**在从mysql 上**

① 修改主配置文件

vim /etc/my.cnf 打开中继日志，指定唯一的servr ID，设置只读权限

```
server-id=2       #配置server-id，让从服务器有唯一ID号
relay_log = mysql-relay-bin    #打开Mysql日志，日志格式为二进制
read_only = 1    #设置只读权限
log_bin = mysql-bin         #开启从服务器二进制日志，（非必须）
log_slave_updates = 1  #使得更新的数据写进二进制日志中 
```

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192654831-1907603453.png)

systemctl start mariadb 开启服务

 

② **启动从服务器复制线程**，让slave连接master，并开始重做master二进制日志中的事件。

```
MariaDB [(none)]> change master to master_host='192.168.30.107',
    -> master_user='slave',
    -> master_password='along',
    -> master_log_file='mysql-bin.000001',
    -> master_log_pos=245;
MariaDB [(none)]>  start slave;   # 启动复制线程，就是打开I/O线程和SQL线程；实现拉主的bin-log到从的relay-log上；再从relay-log写到数据库内存里
```

③ 查看从服务器状态

可使用SHOW SLAVE STATUS\G查看从服务器状态，如下所示，也可用show processlist \G查看当前复制状态：

Slave_IO_Running: Yes #IO线程正常运行

Slave_SQL_Running: Yes #SQL线程正常运行

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192655456-1153264041.png)

 

### 3、初始化数据库

（1）在主mysql上授权，因为主从同步，所以只需操作主

```
MariaDB [(none)]> GRANT ALL PRIVILEGES ON mogilefs.* TO 'mogile'@'192.168.30.%' IDENTIFIED BY 'mogile' WITH GRANT OPTION;
MariaDB [mogilefs]> flush privileges;    刷新下权限
```

（2）数据库初始化，在两个机器上都初始化

**mogdbsetup --dbpass=mogile**

 

### **4****、在主从mysql上实现keepalived，高可用**

原理：主mysql宕机，从上数据没有丢失；且VIP能漂到从mysql上，继续提供服务

（1）在两个机器上下载keepalived

yum -y install keepalived

 

（2）在主mysql上配置keepalived

```
① 全局段，故障通知邮件配置
global_defs {
   notification_email {
        root@localhost
   }
   notification_email_from root@along.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id keepalived_mysql
}
② 检测脚本，监控mysqld进程服务
vrrp_script chk_nginx {
        script "killall -0 mysqld"   #killall -0 检测这个进程是否还活着，不存在就减权重
        interval 2    #每2秒检查一次
        fall 2     #失败2次就打上ko的标记
        rise 2    #成功2次就打上ok的标记
        weight -4    #权重，优先级-4，若为ko
}
③ 配置虚拟路由器的实例段，VI_1是自定义的实例名称，可以有多个实例段
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 190
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass along
    }
    virtual_ipaddress {
        192.168.30.100
    }
track_script {
chk_nginx
}
}
```

（3）在从上只需修改优先级和backup

```
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 190
    priority 98
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass along
    }
    virtual_ipaddress {
        192.168.30.100
    }
track_script {
chk_nginx
}
}
```

（4）开启keepalived 服务

systemctl start keepalived

主mysql 上VIP已经生成

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171129104645409-985047367.png)

 

### 5、在所有机器上，开启tracker服务

（1）修改管理tracker 的配置文件

vim /etc/**mogilefs/mogilefsd.conf**

```
① 配置数据库连接相关信息
db_dsn = DBI:mysql:mogilefs:host=192.168.30.100
db_user = mogile
db_pass = mogile
② 下边的只需修改监听地址和端口
listen = 192.168.30.107:7001 #mogilefs监听地址，监听在127.0.0.1表示只允许从本机登录进行管理；注意，4台机器写自己的IP地址
listen = 192.168.30.7:7001
listen = 192.168.30.2:7001
listen = 192.168.30.3:7001
注意：不是写4个，是在4个机器上分别写
```

（2）创建进程需要的目录，并授权

mkdir /var/run/mogilefsd/

chown -R mogilefs.mogilefs /var/run/mogilefsd

 

（3）开启服务，4台都开启

**/etc/init.d/mogilefsd start**

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192655878-555144274.png)

有时候会显示启动失败；但实际则是启动成功了。可以

ss -nutlp|grep mogilefs 查询是否有mogilefsd 的监听ip和端口

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192656159-1887174536.png)

 

### **6、在两个mogilefs-store 上开启storage 服务**

（1）修改storage node 的配置文件

vim /etc/**mogilefs/mogstored.conf**

```
maxconns = 10000   #存储系统的最大连接数.
httplisten = 0.0.0.0:7500    #可通过http访问的服务端口
mgmtlisten = 0.0.0.0:7501   #mogilefs的管理端口
docroot = /data/mogdata    #该项决定了数据的在storage上存储的实际位置,建议使用的是一个单独挂载使用的磁盘
```

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192656440-1143087292.png)

 

（2）创建storage 存储的目录

mkdir -p /data/mogdata

（3）授权

cd /data/

chown mogilefs.mogilefs mogdata/ -R

（4）开启服务，有时候开启服务显示失败，其实已经成功

/etc/init.d/mogstored start

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192656800-1106844914.png)

 

### 7、修改客户端工具配置

vim /etc/mogilefs/mogilefs.conf 客户端工具配置文件，**4个机器写自己的tracker**

```
trackers=192.168.30.107:7001   #自己的tracker 的服务IP和端口
trackers=192.168.30.7:7001
trackers=192.168.30.2:7001
trackers=192.168.30.3:7001
注意：是各自写各自的，不是都写在一个机器里
```

 

### 8、storage node 节点加入到MogileFS 的系统中

**在tracker 的服务器上：只需在一个tracker 服务器上做就行了**

**（1）加入"存储节点**storage node1/2**"到 trackers 中**

```
mogadm  host add node1 --ip=192.168.30.3 --port=7500 --status=alive
mogadm  host add node2 --ip=192.168.30.2 --port=7500 --status=alive
```

（2）查询信息，检查主机是否加入到 MogileFS 的系统中

mogadm **check**

mogadm **host list**

 

（3）当然，操作错误也可以修改

mogadm host **modify** node1 --ip=192.168.30.3 --port=7500 --status=alive

 

### 9、创建设备

**在mogilefs-store1 服务器上：**

（1）创建"设备"实验的目录并授权，格式： dev + ID

**注意：所有系统中 ID 不能重复，也必须和配置文件中的路径一样**

cd /data/mogdata/

mkdir dev1

chown mogilefs.mogilefs dev1/ -R 加权限

设置成功，会在dev1下生成一个文件，是tracker 过来测试留下来的

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192657175-635124720.png)

 

（2）在另一台服务器上也一样

cd mogdata/

mkdir dev2

chown mogilefs.mogilefs dev2/ -R

 

### 10、两个设备加入 MogileFS 的存储系统中

（1）在tracker 上

```
mogadm  device add node1 1
mogadm  device add node2 2
```

（2）查看设备信息

mogadm check 检测出来两个设备的信息了

mogadm device list 能查询设备的详细信息

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192657659-625307518.png)

 

（3）在数据库中也能查出设备

MariaDB [mogilefs]> select * from device;

MariaDB [mogilefs]> select * from host;

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192658081-787675723.png)

 

**10划分域/class、11上传文件且测试、12修复bug  步骤都同上**



## 实战三：FastDFS 实现分布式存储

**架构图：**

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192702253-432290862.png)

### 原理

（1）FastDFS核心组件

① **Tracker：调度器**，负责维持集群的信息，例如各group及其内部的storage node，这些信息也是storage node报告所生成；**每个storage node会周期性向tracker发心跳信息**；

② **storage server：以group为单位**进行组织，任何一个storage server都应该属于某个group，一个group应该包含多个storage server；**在同一个group内部，各storage server的数据互相冗余；**

 

（2）FastDFS架构的特点

• **只有两个角色**，**tracker server和storage server**，**不需要存储文件索引信息**

• 所有服务器都是**对等的**，**不存在Master-Slave关系**

• 存储服务器采用**分组方式**，**同组内存储服务器上的文件完全相同（RAID 1）**

• **不同组的storage server之间不会相互通信**

• 由**storage server主动向tracker server报告状态信息**，tracker server之间通常不会相互通信

 

（3）FastDFS同步机制

**① 采用binlog**文件**记录更新操作**，根据**binlog进行文件同步同一组内的storage server之间是对等的，文件上传、删除等操作可以在任意一台storage server上进行；**

**② 文件同步只在同组内的storage server之间进行**，采用push方式，即**源服务器同步给目标服务器；**

**③ 源头数据才需要同步，备份数据不需要再次同步**，否则就构成环路了；

上述第二条规则有个例外，就是**新增**加一台storage server时，由已有的一台storage server将已有的所有数据（包括源头数据和备份数据）同步给该新增服务器。

 

（4）FastDFS运行机制

---> 上传文件

① client询问tracker上传到的storage；

② tracker返回一台可用的storage；

③ client直接和storage通信完成文件上传，storage返回**文件ID**

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192702612-95334821.png)

<--- 下载文件

① client询问tracker下载文件的storage，参数为**文件ID（组名和文件名）**；

② tracker返回一台可用的storage；

③ client直接和storage通信完成文件下载

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192703065-913918825.png)

 

（5）**FastDFS 与 mogileFS 的区别**

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192703534-1731643440.png)

 

### 1、环境准备

| 机器名称     | IP配置         | 服务角色 | 备注               |
| ------------ | -------------- | -------- | ------------------ |
| tracker-srv  | 192.168.30.107 | 调度器   | tracker、不需mysql |
| storage srv1 | 192.168.30.7   | 文件存放 |                    |
| storage srv2 | 192.168.30.2   | 文件存放 |                    |

 

### 2、下载安装

mkdir /fastdfs 创建一个存放fastdfs所需包的目录

所需要的包，我已经存放在我的网盘了，有需要的私聊

https://pan.baidu.com/share/init?surl=c2bGc84

cd /fastdfs

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192703831-2035684060.png)

yum -y localinstall ./*

 

### 3、在tracke 的服务器上，开启tracke 服务

（1）修改配置文件

cd /etc/fdfs tracker的配置文件的模板已经准备好了，只需复制修改就好

cp tracker.conf.sample tracker.conf

 

vim /etc/**fdfs/tracker.conf**   必须修改的一项

**base_path=/data/fastdfs/tracker**   #base源路径

① 还可以修改一些自己需要的，如上传、下载方式

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192704675-1385673302.png)

② 访问权限控制

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192705409-328199787.png)

 

（2）创建目录

mkdir /data/fastdfs/tracker -p

 

（3）启动tracker服务

**/etc/init.d/fdfs_trackerd start**

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192705815-1473691878.png)

 

### 4、在后端两台storage server上，开启storage 快照

在storage server上 storage的配置文件的模板已经准备好了，只需复制修改就好

cd /etc/fdfs

cp storage.conf.sample storage.conf

（1）修改配置文件

vim **storage.conf** 必须修改3项

```
base_path=/data/fastdfs/storage   #base源路径
store_path0=/data/fastdfs/storage    #实际存储目录
tracker_server=192.168.30.107:22122    #指定tracker
```

（2）创建目录

mkdir /data/fastdfs/storage -p

 

（3）开启服务

/etc/init.d/fdfs_storaged start

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192706206-817613278.png)

 

（4）生成了存放文件的目录

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192706847-1588352092.png)

 

### 5、设置客户端配置文件

（1）设置客户端配置文件

cd /etc/fdfs

cp client.conf.sample client.conf 复制模板

vim client.conf 修改2行

```
base_path=/data/fastdfs/tracker
tracker_server=192.168.30.107:22122
```

（2）查看存储节点状态

**fdfs_monitor /etc/fdfs/client.conf**

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192707503-739725149.png)

 

### 6、FastDFS的上传、下载

（1）fdfs_**upload**_file **/etc/fdfs/client.conf** xiaomi.zip 上传

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192707925-1304781400.png)

 

（2）在后端两个storage server 上，两个是同步的，一样

① 二进制文件有记录

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192708534-652136445.png)

 

② 确实能找到

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192709097-1129734139.png)

 

（3）文件查看

fdfs_**file_info** /etc/fdfs/client.conf group1/M00/00/00/wKgeAlodCEGAXOuMB3o1rOpTQ-0771.zip

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192709612-602466821.png)

分析：上传到了192.168.30.2 的机器上，然后push推到192.168.30.7上

 

（4）文件下载

```
fdfs_download_file /etc/fdfs/client.conf group1/M00/00/00/wKgeAlodCEGAXOuMB3o1rOpTQ-0771.zip
md5sum xiaomi.zip wKgeAlodCEGAXOuMB3o1rOpTQ-0771.zip
```

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192710034-1554215011.png)

**分析：md5值是一样的**，表明是同一个文件

 

（5）删除

fdfs_**delect**_file /etc/fdfs/client.conf group1/M00/00/00/wKgeAlodCEGAXOuMB3o1rOpTQ-0771.zip

 

（6）上传测试

fdfs_**test** /etc/fdfs/client.conf **upload** xiaomi.zip [FILE | BUFF | CALLBACK]

 

## 实验四：FastDFS实现nginx代理

在两个后端storage server 上实现的

### 1、安装nginx 插件，也存放到我的网盘里了，rz

yum -y localinstall nginx-*

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192710690-263102065.png)

 

### 2、在nginx上加载模块

vim /etc/nginx/nginx.conf

```
location /group1/M00 {
        root /data/fastdfs/storage/data;
        ngx_fastdfs_module;
}
```

### 3、修改fastdfs 模块的配置文件

vim /etc/fdfs/**mod_fastdfs.conf**

```
tracker_server=192.168.30.107:22122
url_have_group_name = true
store_path0=/data/fastdfs/storage
```

### 4、开启nginx 服务，测试

systemctl start nginx

网页测试 http://192.168.30.2/group1/M00/00/00/wKgeB1odET-AGOSlAAAbjMSvzS8917.jpg

![img](https://images2018.cnblogs.com/blog/1216496/201711/1216496-20171128192711315-950981284.png)