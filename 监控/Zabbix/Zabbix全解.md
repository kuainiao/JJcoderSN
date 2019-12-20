# Zabbix 监控全解

## 1、监控介绍

1.你用过哪些监控软件？
2.zabbix和nagios的区别
3.zabbix和nagios、cacti、ganglia有什么区别
4.zabbix的好处
5.zabbix的监控流程
6.常见监控项

使用 SNMP 协议获取主机 CPU、内存、磁盘、网卡流量等数据.
    用脚本将获取到的 SNMP 数据存入数据库中,然后再使用一种名为 MRTG 的软件根据获取的数据绘制图表来分析数据的变化。MRTG(Multi Router Traffic Grapher),顾名思义,这款软件最初是设计用于监控网络链路流量负载的。它可以用过 SNMP 获取到设备的流量信息,并根据这些信息绘制成图表并保存为 PNG 格式的图片,再将这些 PNG 图片以HTML 页面的方式显示给用户.

​    不过,MRTG 展示的页面和图表曲线相对简陋,它在一张图片中最多只能绘制两个数据的变化曲线,并且由于是 PNG 格式的静态图片,所以无法针对某一时间进行细化展示。为了解决这个问题,人们又开发了 RRDTOOL 工具.

​    不过,直接使用 RRD TOOL 绘图操作起来很麻烦。同时,现如今的数据中心动辄成百上千的设备,一个个的去提取、绘制、监控显然是不现实的事情.

​    Cacti 是一套基于 PHP、MySQL、SNMP 及 RRD Tool 开发的监测图形分析工具,Cacti 是使用轮询的方式由主服务器向设备发送数据请求来获取设备上状态数据信息的,如果设备不断增多,这个轮询的过程就非常的耗时,轮询的结果就不能即时的反应设备的状态了。Cacti 监控关注的是对数据的展示,
​    却不关注数据异常后的反馈。如果凌晨 3 点的时候设备的某个数据出现异常,除非监控人员在屏幕前发现这个异常变化,否则是没有任何报警机制能够让我们道出现了异常。

​    Nagios 是一款开源的免费网络监控报警服务,能有效监控 Windows、Linux 和 Unix 的主机状态,交换机、路由器和防火墙等网络设置,打印机、网络投影、网络摄像等设备。在系统或服务状态异常时发出邮件或短信报警第一时间通知运维人员,在状态恢复后发出正常的邮件或短信通知。Nagios 有完善的插件功能,可以方便的根据应用服务扩展功能。

​    Nagios 已经可以支持由数万台服务器或上千台网络设备组成的云技术平台的监控,它可以充分发挥自动化运维技术特点在设备和人力资源减少成本。只是 Nagios 无法将多个相同应用集群的数据集合起来,也不能监控到集群中特殊节点的迁移和恢复。

​    一个新的监控服务根据这个需求被设计出来,它就是 Ganglia。
​    Ganglia 是 UC Berkeley 发起的一个开源集群监视项目,设计用于测量数以千计的节点。Ganglia 的核心包含 gmond、gmetad 以及一个 Web 前端。
​    主要是用来监控系统性能,如:CPU 、内存、硬盘利用率, I/O 负载、网络流量情况等,通过曲线很容易见到每个节点的工作状态,对合理调整、分配系统资源,提高系统整体性能起到重要作用,目前是监控HADOOP 的官方推荐服务。

​    Zabbix 是一个基于 WEB 界面的提供分布式系统监视以及网络监视功能的企业级的开源解决方案。zabbix 能监视各种网络参数,保证服务器系统的安全运营;并提供灵活的通知机制以让系统管理员快速定位/解决存在的各种问题。

 Zabbix 是由 Alexei Vladishev 创建，目前由 Zabbix SIA 在持续开发和支持。 
 Zabbix 是一个企业级的分布式开源监控方案。 
 Zabbix 是一款能够监控各种网络参数以及服务器健康性和完整性的软件。Zabbix使用灵活的通知机制，允许用户为几乎任何事件配置基于邮件的告警。这样可以快速反馈服务器的问题。基于已存储的数据，Zabbix提供了出色的报告和数据可视化功能。这些功能使得Zabbix成为容量规划的理想方案。 
 Zabbix支持主动轮询和被动捕获。Zabbix所有的报告、统计信息和配置参数都可以通过基于Web的前端页面进行访问。基于Web的前端页面可以确保您从任何方面评估您的网络状态和服务器的健康性。适当的配置后，Zabbix可以在IT基础架构监控方面扮演重要的角色。对于只有少量服务器的小型组织和拥有大量服务器的大型公司也同样如此。 
 Zabbix是免费的。Zabbix是根据GPL通用公共许可证第2版编写和发行的。这意味着它的源代码都是免费发行的，可供公众任意使用。 
 [商业支持](http://www.zabbix.com/support.php) 由Zabbix公司提供。

## 2、监控区别

​    1.nagios图形不是特别好，也可以安装图形插件，但是也不怎么好看
​    2.nagios一般情况下如果需要图形可以和cacti配合使用
​    3.cacti的监控是轮询监控,效率低，图形相对nagios比较好看
​    4.zabbix和nagios因为是并发监控，对cpu的要求更高
​    5.zabbix在性能和功能上都强大很多
​    6.zabbix的图形相当漂亮
​    7.支持多种监控方式 zabbix-agent  snmp 等等
​    8.支持分布式监控,能监控的agent非常多
​    9.zabbix有图形的web配置界面，配置简洁
​    10.zabbix支持自动发现功能

## 3、zabbix 监控

###  1、zabbix 监控架构

> ​        监控中心zabbix-server
> ​                         |
> ​         \------------------------------
> ​         |                                  |
> ---proxy---                    ---proxy---
> |              |                   |               |
> agent      agent        agent        agent

###  2、zabbix 监控邮件报警架构

>  postfix  
>  邮局(MTA)------邮递员(smtp 25)------邮局(MTA)
>   |                                                  |
>  MDA maildrop  dovecote         MDA   本地邮件投递代理
>   |                                                  |
>  邮递员(smtp 25)                            邮递员(pop3 110  imap 143)
>   |                         dns                   |
>  邮筒(MUA)                                     邮筒(MUA)
>   |                                                  |
>  lilei(user1)                          hanmeimei(user2)
>
>  agent   代理
>  proxy   代理

### 3、Zabbix 优点

​    开源,无软件成本投入
​    Server 对设备性能要求低
​    支持设备多,自带多种监控模板
​    支持分布式集中管理,有自动发现功能,可以实现自动化监控
​    开放式接口,扩展性强,插件编写容易
​    当监控的 item 比较多服务器队列比较大时可以采用被动状态,被监控客户端主动 从server 端去下载需要监控的 item 然后取数据上传到 server 端。 这种方式对服务器的负载比较小。
​    Api 的支持,方便与其他系统结合

### 4、Zabbix 缺点

​    需在被监控主机上安装 agent,所有数据都存在数据库里, 产生的数据据很大,`瓶颈主要在数据库`。

### 5、Zabbix 监控系统监控对象

> 数据库：   MySQL,MariaDB,Oracle,SQL Server
> 应用软件：Nginx,Apache,PHP,Tomcat                    agent
> \---------------------------------------------------------------------------------------------------------
>
> 集群：      LVS,Keepalived,HAproxy,RHCS,F5
> 虚拟化：   VMware,KVM,XEN ,docker,k8s                            agent
> 操作系统：Linux,Unix,Windows性能参数
> \---------------------------------------------------------------------------------------------------------
>
> 硬件： 服务器，存储，网络设备                             IPMI
> 网络： 网络环境（内网环境，外网环境）              SNMP
> \---------------------------------------------------------------------------------------------------------

### 6、Zabbix监控方式

**被动模式**

　　被动检测：相对于agent而言；agent, **server向agent请求获取配置的各监控项相关的数据**，agent接收请求、获取数据并响应给server；

**主动模式**

　　主动检测：相对于agent而言；agent(active),**agent向server请求与自己相关监控项配置**，主动地将server配置的监控项相关的数据发送给server；

　　`主动监控能极大节约监控server 的资源`。

### 7、zabbix 架构

 Zabbix由几个主要的软件组件构成，这些组件的功能如下。

 <img src="Zabbix%E5%85%A8%E8%A7%A3.assets/111.png" alt="111" style="zoom: 200%;" />

#### 1、**Server**

 Zabbix server 是 agent 程序报告系统可用性、系统完整性和统计数据的`核心组件`，是所有配置信息、统计信息和操作数据的`核心存储器`。 

#### **2、数据库存储**

 所有配置信息和Zabbix收集到的数据都被存储在数据库中。 `数据库瓶颈重要原因`。

#### **3、Web界面**

 为了从任何地方和任何平台都可以轻松的访问Zabbix, 我们提供基于Web的Zabbix界面。该界面是Zabbix Server的一部分，通常(但不一定)跟Zabbix Server运行在同一台物理机器上。 

 如果使用SQLite,Zabbix Web界面必须要跟Zabbix Server运行在同一台物理机器上。

#### **4、Proxy 代理服务器**

 Zabbix proxy 可以替Zabbix Server收集性能和可用性数据。Proxy代理服务器是Zabbix软件可选择部署的一部分；当然，Proxy代理服务器可以帮助单台Zabbix Server分担负载压力。 

#### **5、Agent 监控代理**

 Zabbix agents监控代理 部署在监控目标上，能够主动监控本地资源和应用程序，并将收集到的数据报告给Zabbix Server。 

#### **6、数据流**

了解Zabbix内部的数据流同样很重要。**监控方面**，为了创建一个监控项(item)用于采集数据，必须先创建一个主机（host）。**告警方面**，在监控项里创建触发器（trigger），通过触发器（trigger）来触发告警动作（action）。 因此，如果你想收到Server XCPU负载过高的告警，你必须: 1. 为Server X创建一个host并关联一个用于对CPU进行监控的监控项（Item）。 2. 创建一个Trigger，设置成当CPU负载过高时会触发 3. Trigger被触发，发送告警邮件 虽然看起来有很多步骤，但是使用模板的话操作起来其实很简单，Zabbix这样的设计使得配置机制非常灵活易用。 

### 7、Zabbix常用术语的含义

####  1、主机 (host) 

 - 一台你想监控的网络设备，用IP或域名表示 

####  2、主机组 (host group) 

 - 主机的逻辑组；它包含主机和模板。一个主机组里的主机和模板之间并没有任何直接的关联。通常在给不同用户组的主机分配权限时候使用主机组。 

#### 3、监控项 (item) 

 - 你想要接收的主机的特定数据，一个度量数据。 

####  4、触发器 (trigger) 

 - 一个被用于定义问题阈值和“评估”监控项接收到的数据的逻辑表达式 
    当接收到的数据高于阈值时，触发器从“OK”变成“Problem”状态。当接收到的数据低于阈值时，触发器保留/返回一个“OK”的状态。 

####  5、事件 (event) 

 - 单次发生的需要注意的事情，例如触发器状态改变或发现有监控代理自动注册 

####  6、异常 (problem) 

 - 一个处在“异常”状态的触发器 

####  7、动作 (action) 

 - 一个对事件做出反应的预定义的操作。 
    一个动作由操作(例如发出通知)和条件(当时操作正在发生)组成 

####  8、升级 (escalation) 

 - 一个在动作内执行操作的自定义场景; 发送通知/执行远程命令的序列 

####  9、媒介 (media) 

 - 发送告警通知的手段；告警通知的途径 

####  10、通知 (notification) 

 - 利用已选择的媒体途径把跟事件相关的信息发送给用户 

####  11、远程命令 (remote command) 

 - 一个预定义好的，满足一些条件的情况下，可以在被监控主机上自动执行的命令 

####  12、模版 (template) 

 - 一组可以被应用到一个或多个主机上的实体（监控项，触发器，图形，聚合图形，应用，LLD，Web场景）的集合 
    模版的任务就是加快对主机监控任务的实施；也可以使监控任务的批量修改更简单。模版是直接关联到每台单独的主机上。 

####  13、应用 (application) 

 - 一组监控项组成的逻辑分组 

####  14、web 场景 (web scenario) 

 - 利用一个或多个HTTP请求来检查网站的可用性 

####  15、前端 (frontend) 

 - Zabbix提供的web界面 

####  16、Zabbix API 

 - Zabbix API允许你使用JSON RPC协议 **(是一个无状态且轻量级的远程过程调用（RPC）传送协议，其传递内容透过 JSON 为主)** 来创建、更新和获取Zabbix对象（如主机、监控项、图形和其他）信息或者执行任何其他的自定义的任务 

####  17、Zabbix server 

 - Zabbix软件实现监控的核心程序，主要功能是与Zabbix proxies和Agents进行交互、触发器计算、发送告警通知；并将数据集中保存等 

####  18、Zabbix agent 

 - 一个部署在监控对象上的，能够主动监控本地资源和应用的程序 
    Zabbix agent部署在监控的目标上，主动监测本地的资源和应用(硬件驱动，内存，处理器统计等)。 
    Zabbix agent收集本地的操作信息并将数据报告给Zabbix server用于进一步处理。一旦出现异常 (比如硬盘空间已满或者有崩溃的服务进程), Zabbix server会主动警告管理员指定机器上的异常。. Zabbix agents 的极端高效缘于它可以利用本地系统调用来完成统计数据的收集。 

####  19、被动（passive）和主动（active）检查

 Zabbix agents可以执行被动和主动两种检查方式。 
 `被动检查`（passive check） 模式中agent应答数据请求，Zabbix server（或者proxy）询问agent数据,如CPU 的负载情况，然后Zabbix agent回送结果。 
 `主动检查`（Active checks） 处理过程将相对复杂。 Agent必须首先从Zabbix sever索取监控项列表以进行独立处理，然后周期性地发送新的值给server。 
 执行被动或主动检查是通过选择相应的监测项目类型来配置的。item type. Zabbix agent处理监控项类型有’Zabbix agent’和’Zabbix agent (active)’。 

####  20、Zabbix proxy 

 - 一个帮助Zabbix Server收集数据，分担Zabbix Server的负载的程序 
    Zabbix Proxy是一个可以从一个或多个受监控设备收集监控数据，并将信息发送到Zabbix sever的进程，基本上是代表sever工作的。 所有收集的数据都在本地进行缓存，然后传送到proxy所属的Zabbix sever。 
     部署Proxy是可选的，，但是可能非常有益于分散单个Zabbix sever的负载。 如果只有proxy收集数据，sever上的进程就会减少CPU消耗和磁盘I / O负载。 
     Zabbix proxy是完成`远程区域、分支机构、没有本地管理员的网络的集中监控的理想解决方案`。 
     Zabbix proxy需要使用独立的数据库。 

## 4、Zabbix 企业监控系统搭建

### 1、实验准备

centos7 系统服务器3台、 一台作为监控服务器， 两台台作为被监控节点， 配置好`yum源`、 `防火墙关闭`、 `各节点时钟服务同步`、 `各节点之间可以通过主机名互相通信`。
**1）所有机器关闭防火墙和selinux**

```shell
setenforce 0 （修改配置文件关闭）
或
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 
systemctl stop firewalld.service
systemctl disable firewalld.service
```

**2）根据架构图，实验基本设置如下：**

| 机器名称 | IP配置          | 服务角色      | 备注         |
| -------- | --------------- | ------------- | ------------ |
| server   | 192.168.122.100 | zabbix-server | 开启监控功能 |
| node1    | 192.168.122.200 | zabbix-agent  | 开启         |
| node2    | 192.168.122.300 | zabbix-agent  | 开启         |

### 2、Zabbix的安装

#### 1）更新yum仓库

我们去官网下载一个包`zabbix-release-3.4-2.el7.noarch.rpm`，本地安装至我们的虚拟机，这样，我们本地就有了新的yum源，可以直接安装zabbix服务：

```shell
yum -y install wget
wget http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm

安装zabbix源（官方）
rpm -ivh https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
```

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111035370-1910943841.png)

下载安装：

```shell
rpm -ivh zabbix-release-4.2-1.el7.noarch.rpm
```

更新我们的yum仓库：

```shell
[root@server ~]# yum repolist 
```

安装：

```shell
[root@server ~]# yum -y install epel-release.noarch
[root@server ~]# yum -y install zabbix-agent zabbix-get zabbix-sender zabbix-server-mysql zabbix-web zabbix-web-mysql
或者（官方）
[root@server ~]# yum-config-manager --enable rhel-7-server-optional-rpms

zabbix-server-mysql:数据库
zabbix-web-mysql:web
zabbix-get:命令行
zabbix-agent：代理程序
```

> 问题：
>
> Error downloading packages:
>   iksemel-1.4-2.el7.centos.x86_64: [Errno 256] No more mirrors to try.
>   fping-3.10-1.el7.x86_64: [Errno 256] No more mirrors to try.
>   zabbix-web-mysql-3.2.11-1.el7.noarch: [Errno 256] No more mirrors to try.
>   zabbix-server-mysql-3.2.11-1.el7.x86_64: [Errno 256] No more mirrors to try.
>
> 解决办法：
>
> 将DNS加一条8.8.8.8，然后多试几次就可以装下来了

#### 2）安装设置数据库：

1、创建 mariadb.repo

```shell
vim /etc/yum.repos.d/mariadb.repo
写入以下内容：
[mariadb]
name = MariaDB 
baseurl = https://mirrors.ustc.edu.cn/mariadb/yum/10.4/centos7-amd64 
gpgkey=https://mirrors.ustc.edu.cn/mariadb/yum/RPM-GPG-KEY-MariaDB 
gpgcheck=1
```

2、yum 安装最新版本 mariadb

```shell
yum -y install mariadb mariadb-server
```

首先，我们修改一下配置文件——`/etc/my.cnf.d/server.cnf`：

```shell
[root@server ~]# vim /etc/my.cnf.d/server.cnf
    [mysqld]
    skip_name_resolve = ON          #跳过主机名解析
    innodb_file_per_table = ON      #
    innodb_buffer_pool_size = 256M  #缓存池大小
    max_connections = 2000          #最大连接数
    log-bin = master-log            #开启二进制日志
```

2、重启我们的数据库服务：

```shell
[root@server ~]# systemctl enable mariadb
[root@server ~]# systemctl start mariadb
[root@server ~]# mysql_secure_installation  #初始化mariadb
```

3、创建数据库并授权账号

```shell
MariaDB [(none)]> create database zabbix character set 'utf8';  # 创建zabbix数据库
MariaDB [(none)]> grant all on zabbix.* to 'zabbix'@'%' identified by '520Myself.';										# 注意授权网段
MariaDB [(none)]> flush privileges;           # 刷新授权
```

4、**导入表**
　　首先，我们来查看一下，`zabbix-server-mysql`这个包提供了什么：

```shell
[root@server ~]# rpm -ql zabbix-server-mysql
/etc/logrotate.d/zabbix-server
/etc/zabbix/zabbix_server.conf
/usr/lib/systemd/system/zabbix-server.service
/usr/lib/tmpfiles.d/zabbix-server.conf
/usr/lib/zabbix/alertscripts
/usr/lib/zabbix/externalscripts
/usr/sbin/zabbix_server_mysql
/usr/share/doc/zabbix-server-mysql-3.2.6
/usr/share/doc/zabbix-server-mysql-3.2.6/AUTHORS
/usr/share/doc/zabbix-server-mysql-3.2.6/COPYING
/usr/share/doc/zabbix-server-mysql-3.2.6/ChangeLog
/usr/share/doc/zabbix-server-mysql-3.2.6/NEWS
/usr/share/doc/zabbix-server-mysql-3.2.6/README
/usr/share/doc/zabbix-server-mysql-3.2.6/create.sql.gz      #生成表的各种脚本
/usr/share/man/man8/zabbix_server.8.gz
/var/log/zabbix
/var/run/zabbix
```

我们来使用这个文件生成我们所需要的表：

```shell
[root@server ~]# gzip -d create.sql.gz
[root@server ~]# head  create.sql           #查看一下表头
CREATE TABLE `users` (
    `userid`                 bigint unsigned                           NOT NULL,
    `alias`                  varchar(100)    DEFAULT ''                NOT NULL,
    `name`                   varchar(100)    DEFAULT ''                NOT NULL,
    `surname`                varchar(100)    DEFAULT ''                NOT NULL,
    `passwd`                 char(32)        DEFAULT ''                NOT NULL,
    `url`                    varchar(255)    DEFAULT ''                NOT NULL,
    `autologin`              integer         DEFAULT '0'               NOT NULL,
    `autologout`             integer         DEFAULT '900'             NOT NULL,
    `lang`                   varchar(5)      DEFAULT 'en_GB'           NOT NULL,
```

我们查看表头发现没有创建数据库的命令，这也正是我们刚刚手动创建数据库的原因。
然后，我们直接把这个表导入至我们的数据库即可：

```shell
[root@server ~]# mysql -uzabbix -h192.168.122.100 -p zabbix < create.sql 
Enter password:
```

　　导入以后，我们进去数据库查看一下：

```shell
[root@server ~]# mysql -uzabbix -h192.168.37.111 -p
Enter password:
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| zabbix             |
+--------------------+
MariaDB [(none)]> use zabbix;
Database changed
MariaDB [zabbix]> show tables;
+----------------------------+
| Tables_in_zabbix           |
+----------------------------+
| acknowledges               |
| actions                    |
| alerts                     |
……
| usrgrp                     |
| valuemaps                  |
+----------------------------+
127 rows in set (0.00 sec)
```

可以看出来，我们的数据已经导入成功了。

### 3、配置 server 端

我们的数据库准备好了以后，我们要去修改server端的配置文件。

```shell
[root@server ~]# cd /etc/zabbix/
[root@server zabbix]# ls
web  zabbix_agentd.conf  zabbix_agentd.d  zabbix_server.conf
#为了方便我们以后恢复，我们把配置文件备份一下
[root@server zabbix]# cp zabbix_server.conf{,.bak}
[root@server zabbix]# vim zabbix_server.conf
ListenPort=10051            #默认监听端口
SourceIP=192.168.122.100     #发采样数据请求的IP
```

为什么要设置`SourceIP`，由于我们的客户端可能一个主机多个IP，我们又不能允许任意的IP都能从我们这里读取数据，就会有一个验证方式，而该方式是基于识别SourceIP来实现的。
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111451323-1945674171.png)
日志，默认用文件记录，也可以发送给我们的rsyslog日志记录系统，如果我们选择默认，则日志存放在`LogFile=/var/log/zabbix/zabbix_server.log`中，也可以自己设置。
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111457261-900254693.png)
日志的滚动。默认值为1，表示滚动。我们设为0则表示不滚动。当数据特别多的时候，我们也可以设置成为1，然后在`Maximum size of log file in MB`设置当数据文件最大到多少时会自动滚动。
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111508870-541941322.png)
日志的级别。一共有6个级别。我们可以根据自己的需要来设置级别。其中0表示输出最少的信息，5表示输出最详细的信息，默认值为3，设置为3的话就表示，0、1、2、3四个级别都显示。考虑到生产系统中的压力时，这里的信息，如果没有必要的话，越简单越好，只要在出错的时候，我们可以依据其进行排错即可。

```shell
    DBHost=192.168.122.100       #数据库对外的主机
    DBName=zabbix               #数据库名称
    DBUser=zabbix              #数据库用户
    DBPassword=520Myself.             #数据库密码
    DBPort=3306                 #数据库启动端口
```

数据库相关的设置。

> **补充**：我们可以使用`grep -i "^####" zabbix_server.conf`来查看配置文件中有哪些大段，也可以使用`grep -i "^###" zabbix_server.conf`来查看配置文件中每一段中的配置项有哪些

以上，基本配置完成，可以开启服务了：

```shell
[root@server zabbix]# systemctl enable zabbix-server.service
[root@server zabbix]# systemctl start zabbix-server.service

```

开启服务以后，我们一定要去确认一下我们的端口有没有开启：

```shell
[root@server zabbix]# ss -nutl |grep 10051
tcp    LISTEN     0      128       *:10051                 *:*                  
tcp    LISTEN     0      128      :::10051                :::*    

```

如果查到的端口没有开启，我们就要去检查一下配置文件有没有出问题了。
至此，我们server端的进程启动已经ok了，接下来就可以使用web GUI来打开接口进行设定了

### 4、配置 web GUI

我们先来查看一下，我们web GUI的配置文件在哪里：

```shell
[root@server ~]# rpm -ql zabbix-web | less
/etc/httpd/conf.d/zabbix.conf
/etc/zabbix/web
/etc/zabbix/web/maintenance.inc.php
/etc/zabbix/web/zabbix.conf.php
/usr/share/doc/zabbix-web-3.2.6
/usr/share/doc/zabbix-web-3.2.6/AUTHORS
/usr/share/doc/zabbix-web-3.2.6/COPYING
/usr/share/doc/zabbix-web-3.2.6/ChangeLog
/usr/share/doc/zabbix-web-3.2.6/NEWS
/usr/share/doc/zabbix-web-3.2.6/README
……

```

可以看出，有一个`/etc/httpd/conf.d/zabbix.conf`文件，这个配置文件就是帮我们做映射的文件，我们可以去看一看这个文件：

```shell
Alias /zabbix /usr/share/zabbix     #我们访问的时候要在主机后加上/zabbix来访问我们这个服务

```

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111541714-86449116.png)
时区是一定要设置的，这里被注释掉是因为，我们也可以在php的配置文件中设置时区，如果我们在php配置文件中设置时区，则对所有的php服务均有效，如果我们在zabbix.conf中设置时区，则仅对zabbix服务有效。所以，我们去php配置文件中设置我们的时区：

```shell
vim /etc/php.ini
    [Date]
    ; Defines the default timezone used by the date functions
    ; http://php.net/date.timezone
    date.timezone = Asia/Shanghai

```

接下来，我们就可以启动我们的`httpd`服务了：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111550245-1056507466.png)
我们的服务已经开启，接着我们就可以用浏览器来访问了。

### 5、浏览器访问并进行初始化设置

我们使用浏览器访问`192.168.122.100/zabbix`，第一次访问时需要进行一些初始化的设置，我们按照提示操作即可：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111624526-738200150.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111632386-1721515434.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111651776-1822649685.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111657823-1996546273.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111703448-1933168823.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111709776-2083342842.png)
　　点击Finish以后，我们就会跳转到登录页面，使用我们的账号密码登录即可：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111720948-950069230.png)
默认用户名为：Admin ，密码为：zabbix 。
登陆进来就可以看到我们的仪表盘了：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111726964-1900127962.png)



### 6、配置 agent 端

当我们把监控端配置启动以后，我们需要来设置一下我们的监控端，我们在被监控的主机安装好agent，设置好他的server，并把他添加到server端，就能将其纳入我们的监控系统中去了。

#### 1）安装 zabbix

先来安装zabbix。下载包，注释epel源，安装所需的包。具体步骤如下：

```shell
[root@node1 ~]# wget https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
[root@node1 ~]# rpm -ivh zabbix-release-4.2-1.el7.noarch.rpm 
[root@node1 ~]# yum -y install epel-release.noarch
[root@node1 ~]# yum install zabbix-agent zabbix-sender -y
```

安装完成以后，我们去修改配置文件。

#### 2）修改配置文件

先查一下包内有什么：

```shell
[root@node1 zabbix]# rpm -ql zabbix-agent 
/etc/logrotate.d/zabbix-agent
/etc/zabbix/zabbix_agentd.conf
/etc/zabbix/zabbix_agentd.d
/etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf
/usr/lib/systemd/system/zabbix-agent.service
/usr/lib/tmpfiles.d/zabbix-agent.conf
/usr/sbin/zabbix_agentd
/usr/share/doc/zabbix-agent-3.4.4
/usr/share/doc/zabbix-agent-3.4.4/AUTHORS
/usr/share/doc/zabbix-agent-3.4.4/COPYING
/usr/share/doc/zabbix-agent-3.4.4/ChangeLog
/usr/share/doc/zabbix-agent-3.4.4/NEWS
/usr/share/doc/zabbix-agent-3.4.4/README
/usr/share/man/man8/zabbix_agentd.8.gz
/var/log/zabbix
/var/run/zabbix

```

对配置文件做一个备份，然后去修改配置文件：

```shell
[root@node1 ~]# cd /etc/zabbix/
[root@node1 ~]# cd /etc/zabbix/
[root@node1 zabbix]# ls
zabbix_agentd.conf  zabbix_agentd.d
[root@node1 zabbix]# cp zabbix_agentd.conf{,.bak}
[root@node1 zabbix]# vim zabbix_agentd.conf

```

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111757729-865694486.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111803370-1250338239.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111809401-778949871.png)
重点需要修改的仍然是`GENERAL PARAMETERS`段：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111819198-1483932137.png)
是否允许别人执行远程操作命令，默认是禁用的，打开的话会有安全风险。

```shell
Server=192.168.122.100       #指明服务器是谁的
ListenPort=10050            #自己监听的端口
ListenIP=0.0.0.0            #自己监听的地址，0.0.0.0表示本机所有地址
StartAgents=3               #优化时使用的

ServerActive=192.168.122.100 #主动监控时的服务器
Hostname=node1.keer.com     #自己能被server端识别的名称

```

修改完成之后，我们保存退出。然后就可以启动服务了：

```shell
[root@node1 zabbix]# systemctl enable zabbix-agent.service
[root@node1 zabbix]# systemctl start zabbix-agent.service
```

照例查看端口是否已开启

```shell
[root@node1 zabbix]# ss -ntul |grep 10050
tcp    LISTEN     0      128       *:10050                 *:*  
```

已经开启成功。接着，我们就可以去server端添加了。
node2也进行同样的操作，唯一不同的就是配置文件中的`Hostname`要设为`node2.keer.com`。

### 7、监控过程详解

#### 1）修改密码及中文版

作为一只英语不好的运维，这里悄悄改成了中文版，如果大家英语好的话看英文版即可，英语不好就改了吧，毕竟中文版比较适合初学者更快的学习~
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111827354-72951973.png)
按如上操作即可，选择中文以后，点击下面的update即可更新成功，更新过后是这样
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111833495-129008460.png)
同样的，为了安全起见，我们把密码改掉：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111841370-1797988674.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111849495-310227466.png)
修改完成后同样点击更新即可。



#### 2）创建主机及主机群组

我们先来定义一个主机群组：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111857464-2124919444.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111904167-665674482.png)
　　然后我们就可以去添加主机了：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111913261-73886293.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111919464-1304275424.png)
　　当然，上面有很多选择卡，有一个加密：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111927823-239348334.png)
　　设置完成后，点击添加。我们就可以看到，我们添加的这个主机已经出现在列表中了：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111934214-484009707.png)
　　同样的，我们把node2节点也添加进来：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111940964-633207572.png)



#### 3）监控项(items)

##### ① 介绍

　　我们点击上图中node1的监控项，即可创建我们的监控项，首先，我们创建三个应用集：

​         应用集一般配合监控项使用，它相当于多个同类型的监控项的分类目录

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111950198-929031864.png)
　　然后我们来定义监控项：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202111958792-1773568717.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112003964-2111199567.png)

> 　　任何一个被监控项，如果想要能够被监控，一定要在zabbix-server端定义了能够连接至zabbix-agent端，并且能够获取命令。或者在agent端定义了能够让server端获取命令。一般都是内建的命令，都对应的有其名字，被我们称之为`key`。
> ![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112012245-1626032764.png)
> 　　关于key值，我们可以直接在网页上设置(服务器自动执行)，也可以使用命令行命令(手动执行)来获取：
>
> > [root@server ~]# zabbix_get -s 192.168.37.122 -p 10050 -k "system.cpu.intr"
> > 　　在我们的agent端，也可以使用命令来查看`intr`的速率变化：
> > ![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112020401-1045624944.png)
> > 　　我们继续来看我们的监控项：
> > ![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112109354-402789781.png)
> > 　　说了这么多，我们来简单定义一个：

##### ② 定义一个不带参数的监控项

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112123651-287358961.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112129120-1208851776.png)
　　设置完以后，点击更新，即可加入，并会自动跳转至下图页面：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112140370-1431227410.png)
　　定义完成，我们回到所有主机，等待5秒，我们可以看到，我们node1节点后面的选项已经有变成绿色的了：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112146058-529780188.png)
　　我们也可以回到我们的仪表盘，可以看到，我们的监控项有一个处于启用状态：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112155151-1543121497.png)
　　那么，我们的数据在哪里呢？可以点击`最新数据`，把我们的node1节点添加至主机，应用一下，就可以看到下面的状态了：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112203042-1797920804.png)
　　可以看到，我们还有一个图形页面，点进去则可以看图形的分布：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112209995-1913438877.png)
　　事实上，我们关注的指标有很多种，我们一一添加进来即可。
　　刚刚我们定义的监控项是很简单的，指定一个`key`即可，但是有些监控项是带有参数的，这样一来，我们的监控项就有更多的灵活性。接下来，我们来简单说明一个需要带参数的监控项：



##### ③ 定义一个带参数的监控项

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112221667-2119454107.png)
　　图中的`[]`就是需要参数的意思，里面的值即为参数，带`<>`为不可省略的。我们就以这个例子来说明：
　　`if`表示是接口名；`<mode>`表示是那种模式，包括但不限于：packets(包)、bytes(字节)、errors(错误)、dropped(丢包)、overuns等等（上述内容通过`ifconfig`查看）
　　我们来设置一下这个监控值：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112520104-1246148929.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112525495-114362943.png)
　　同样的，我们也可以通过命令行来查看：

```shell
[root@server ~]# zabbix_get -s 192.168.37.122 -p 10050 -k "net.if.in[ens33,packets]"
```

　　我们来看看网页的显示情况：检测中 ---> 最新数据 ---> Network Interface Stats(图形)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112536323-416042280.png)

**中文乱码解决方法**

Zabbix监控页面中文显示异常，具体为显示为方块，如图所示。

![中文监控选项乱码](Zabbix%E5%85%A8%E8%A7%A3.assets/7bf0ccac4fd22fc1bc57be405cfbc2c32ee.jpg)

首先查找zabbix安装目录，找到字体具体位置。

```shell
#查找zabbix安装位置
[root@server ~]# whereis zabbix
zabbix: /usr/lib/zabbix /etc/zabbix /usr/share/zabbix
[root@server ~]# ls /usr/share/zabbix/
actionconf.php                 app                 charts.php                   hostinventories.php  items.php        report2.php        styles
adm.gui.php                    applications.php    conf                         host_prototypes.php  js               report4.php        sysmap.php
adm.housekeeper.php            audio               conf.import.php              host_screen.php      jsLoader.php     robots.txt         sysmaps.php
adm.iconmapping.php            auditacts.php       correlation.php              hosts.php            jsrpc.php        screenconf.php     templates.php
adm.images.php                 auditlogs.php       discoveryconf.php            httpconf.php         latest.php       screenedit.php     toptriggers.php
adm.macros.php                 browserwarning.php  disc_prototypes.php          httpdetails.php      local            screen.import.php  tr_events.php
adm.other.php                  chart2.php          favicon.ico                  image.php            locale           screens.php        trigger_prototypes.php
adm.regexps.php                chart3.php          fonts                        images               maintenance.php  search.php         triggers.php
adm.triggerdisplayoptions.php  chart4.php          graphs.php                   img                  map.import.php   services.php       usergrps.php
adm.triggerseverities.php      chart5.php          history.php                  imgstore.php         map.php          setup.php          users.php
adm.valuemapping.php           chart6.php          host_discovery.php           include              overview.php     slideconf.php      zabbix.php
adm.workingtime.php            chart7.php          hostgroups.php               index_http.php       profile.php      slides.php
api_jsonrpc.php                chart.php           hostinventoriesoverview.php  index.php            queue.php        srv_status.php
#字体文件位置
[root@server ~]# ls /usr/share/zabbix/fonts/
graphfont.ttf
[root@server ~]# cd /usr/share/zabbix/fonts/
[root@server fonts]# pwd
/usr/share/zabbix/fonts
[root@server fonts]# ls -l
总用量 0
lrwxrwxrwx. 1 root root 33 3月  25 15:24 graphfont.ttf -> /etc/alternatives/zabbix-web-font
```

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1250992a96b4ad79a5020b3918747549b8f.jpg)

采用winscp/xftp等工具将Windows中文字体上传到 /usr/share/zabbix/fonts/ 文件夹。本文中文字体为宋体。字体权限修改后截图如下所示：

![上传字体文件](Zabbix%E5%85%A8%E8%A7%A3.assets/72b7727b21fb1870e1dd26d6fbd8099b705.jpg)

切换至/etc/alternatives 目录查看软链接。

![字体软连接](Zabbix%E5%85%A8%E8%A7%A3.assets/dee2148811c81b40bad6cf343b7686c3b35.jpg)

删除旧软链接并新建。也可以修改为其他中文字体，例如仿宋或者微软雅黑。

```shell
#删除旧软链接
[root@server fonts]# rm -f /etc/alternatives/zabbix-web-font
#新建软链接
[root@server fonts]# ln -s /usr/share/zabbix/fonts/simsun.ttc  /etc/alternatives/zabbix-web-font

```

刷新（Ctrl+F5）浏览器页面即可，如果显示异常，请重新启动zabbix-server服务。

```shell
[root@server fonts]# systemctl restart zabbix-server

```

正常显示字体如图所示。

![中文字体显示正常](Zabbix%E5%85%A8%E8%A7%A3.assets/380e27ff924670f9dd2f65b3582a02374b0.jpg)





##### ④ 快速定义类似指标

　　如果我们想要定义一个类似的指标，我们可以直接选择克隆，然后简单的修改一点点参数即可。
　　就以我们刚刚定义的`net.if.in[ens33,packets]`为例，如果我们想要在定义一个`out`的进行如下操作即可：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112547292-1392248898.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112554167-1900742947.png)
　　如果我们要以字节为单位也要定义的话，进行同样的操作：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112605448-457365913.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112611011-1588882925.png)
　　如果有需要的话也可以把byte再克隆成out。就不一一演示了~
　　可以看一下，我们现在已经定义的指标：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112625604-1195492017.png)
　　我们来到 检测中 ---> 最新数据，可以看到，我们定义的监控项都已经有值了：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112635839-992270373.png)



##### ⑤ 删除监控项

　　如果有一个监控项，我们用不上了，就可以删除掉。但是如果你直接删除的话，默认数据是会留下的，所以我们要先清除数据，然后再删除，具体操作步骤如下：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112656808-290199455.png)



##### ⑥ 监控项存储的值

　　对于监控项存储的值，老一点的版本只有以下三种方式：

- As is：不对数据做任何处理(存储的为原始值)
- Delta：（simple change)(变化)，本次采样减去前一次采样的值的结果
- Delta：（speed per second)(速率)，本次采样减去前一次采样的值，再除以经过的时长；
    而在3.4版本以后有了更多的表现形式：
    ![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112707261-1106041063.png)



#### 4）触发器（trigger）



##### ① 简介

　　当我们的采集的值定义完了以后，就可以来定义触发器了。
　　我们触发器的定义是：**界定某特定的item采集到的数据的非合理区间或非合理状态。通常为逻辑表达式。**
　　逻辑表达式（阈值）：通常用于定义数据的不合理区间，其结果如下：
　　`OK`(不符合条件)：正常状态 --> 较老的zabbix版本，其为FALSE；
　　`PROBLEM`(符合条件)：非正常状态 --> 较老的zabbix版本，其为TRUE；
　　一般，我们评定采样数值是否为合理区间的比较稳妥的方法是——根据最后N次的平均值来判定结果；这个最后N次通常有两种定义方式：

1. 最近N分钟所得结果的平均值
2. 最近N次所得结果的平均值

　而且，我们的触发器存在可调用的函数：

> nodata()　　　　#是否采集到数据，采集不到则为异常
> last()　　　　　   #最近几次
> date()                    #时间，返回当前的时间，格式YYYYMMDD
> time()                    #返回当前的时间，HHMMSS格式的当前时间。
> now()                    #返回距离Epoch(1970年1月1日00:00:00UTC)时间的秒数
> dayofmonth()      #返回当前是本月的第几天
> ...

　　**注：能用数值保存的就不要使用字符串**

##### ② 触发器表达式

　　基本的触发器表达式格式如下所示

```
{<server>:<key>.<function>(<parameter>)}<operator><constant>

```

- `server`：主机名称；
- `key`：主机上关系的相应监控项的key；
- `function`：评估采集到的数据是否在合理范围内时所使用的函数，其评估过程可以根据采取的数据、当前时间及其它因素进行；
- 目前，触发器所支持的函数有avg、count、change、date、dayofweek、delta、diff、iregexp、last、max、min、nodata、now、sum等
- `parameter`：函数参数；大多数数值函数可以接受秒数为其参数，而如果在数值参数之前使用“#”做为前缀，则表示为最近几次的取值，如sum(300)表示300秒内所有取值之和，而sum(#10)则表示最近10次取值之和；
- 此外，avg、count、last、min和max还支持使用第二个参数，用于完 成时间限定；例如，max(1h,7d)将返回一周之前的最大值；
    表达式所支持的运算符及其功能如下图所示：
    ![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112728636-256605681.png)



##### ③ 定义一个触发器

　　我们可以查看一下`rate of packets(in)`的值，并以其为标准确定我们的非正常的值：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112737792-579321512.png)
　　图中我们可以看出，我们的最大值为74，最小值为4，平均值为24。这样的话，我们可以定义50以上的都是非正常的值。
　　下面我们来定义一个触发器：
　　进入：配置 ---> 主机 ---> node1 ---> 触发器 ---> 创建触发器
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112834464-1059691900.png)
　　我们的表达式可以直接点击右侧的添加，然后定义自己所需的内容，即可自动生成：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112841823-1486407594.png)
　　生成完毕后，我们就点击页面下方的添加，即成功定义了一个触发器，同时页面自动跳转：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112850323-852492156.png)
　　然后我们去看一下我们刚刚定义了触发器的那个监控项：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112857776-952646683.png)
　　我们可以看出，这个里面就有了一根线，就是我们刚刚定义的值，超过线的即为异常状态，看起来非常直观。
　　但是，现在即使超过了这根线，也仅仅会产生一个触发器事件而不会做其他任何事。因此，我们就需要去定义一个动作(action)。



##### ④ 触发器的依赖关系

　　我们的触发器彼此之间可能会存在依赖关系的，一旦某一个触发器被触发了，那么依赖这个触发器的其余触发器都不需要再报警。
　　我们可以来试想一下这样的场景：
　　我们的多台主机是通过交换机的网络连接线来实现被监控的。如果交换机出了故障，我们的主机自然也无法继续被监控，如果此时，我们的所有主机统统报警……想想也是一件很可怕的事情。要解决这样的问题，就是定义触发器之间的依赖关系，当交换机挂掉，只它自己报警就可以了，其余的主机就不需要在报警了。**这样，也更易于我们判断真正故障所在。**
　　注意：目前zabbix不能够直接定义主机间的依赖关系，其依赖关系仅能通过触发器来定义。
　　我们来简单举一个例子，示范一下如何定义一个依赖关系：
　　打开任意一个触发器，上面就有依赖关系，我们进行定义即可：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112928604-1229834.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112934808-1854595.png)
　　由于当前我们只定义了一个触发器，就不演示了，过程就是这样~添加以后点击更新即可。
　　触发器可以有多级依赖关系，比如我们看下面的例子：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112943901-1385885917.png)



#### 5）定义动作（action）



##### ① 简介

　　我们需要去基于一个对应的事件为条件来指明该做什么事，一般就是执行远程命令或者发警报。
　　我们有一个**告警升级**的机制，所以，当发现问题的时候，我们一般是先执行一个**远程操作命令**，如果能够解决问题，就会发一个恢复操作的讯息给接收人，如果问题依然存在，则会执行**发警报**的操作，一般默认的警报接收人是当前系统中有的zabbix用户，所以当有人需要收到警报操作的话，我们则需要把它加入我们的定义之中。
　　其次，每一个用户也应该有一个接收告警信息的方式，即媒介，就像我们接收短信是需要有手机号的一样。
　　我们的每一个监控主机，能够传播告警信息的媒介有很多种，就算我们的每一种大的媒介，能够定义出来的实施媒介也有很多种。而对于一个媒介来说，每一个用户都有一个统一的或者不同的接收告警信息的端点，我们称之为目标地或者目的地。
　　综上，为了能够发告警信息，**第一，我们要事先定义一个媒介，第二，还要定义这个媒介上用户接收消息的端点（当然，在用户上，我们也称之为用户的媒介）。**
　　我们可以去看一下系统内建的媒介类型：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112953417-570252961.png)
　　这只是大的媒介类型，里面还有更多的细分，我们以`Email`为例：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202112959964-345494716.png)
　　同样的，同一个类型我们也可以定义多个，还是以`Email`为例，我们可以定义一个腾讯的服务器，一个网易的服务器，一个阿里的服务器等等。



##### ② 定义一个媒介（media）

　　我们还是以`Email`为例。来简单的定义一个媒介：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113015417-958398301.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113021495-491076870.png)
　　这样定义以后，我们去更新一下就可以了。
　　媒介定义好了，那么我们怎么才能够然后用户接收到邮件呢？比如让我们的Admin用户接收邮件，我们应该怎么操作呢？具体步骤如下：
　　进入 管理 ---> 用户 ---> Admin ---> 报警媒介
　　我们来添加一条进来：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113030042-693976775.png)
　　添加过后是这样的：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113038792-215702532.png)
　　然后我们更新就可以了。
　　**一个用户可以添加多个接收的媒介类型。**

**注意： 请使用163/qq邮箱测试**

##### ③ 定义一个动作（action）

　　我们之前说过了，动作是在某些特定条件下触发的，比如，某个触发器被触发了，就会触发我们的动作。
　　现在，我么基于redis来定义一个动作。
　　首先，我们在agent端使用yum安装一下`redis`：

```shell
[root@node1 ~]# yum install redis -y

```

　　修改一下配置文件：

```shell
[root@node1 ~]# vim /etc/redis.conf 
bind 0.0.0.0        #不做任何认证操作

```

　　修改完成以后，我们启动服务，并检查端口：

```shell
[root@node1 ~]# systemctl start redis
[root@node1 ~]# ss -nutlp | grep redis
tcp    LISTEN     0      128       *:6379                  *:*                   users:(("redis-server",pid=5250,fd=4))

```

　　接着，我们就可以去网站上来定义相关的操作了：

###### 1.定义监控项

　　进入 配置 ---> 主机 ---> node1 ---> 监控项（items）---> 创建监控项
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113104229-190921891.png)
　　填写完毕以后，我们点击下方的添加。
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113113058-1658955278.png)
　　该监控项已成功添加。
　　我们可以去查看一下他的值：
　　检测中 ---> 最新数据
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113122433-2129349774.png)

###### 2.定义触发器

　　定义好了监控项以后，我们亦可来定义一个触发器，当服务有问题的时候，我们才能及时知道：
　　进入 配置 ---> 主机 ---> node1 ---> 触发器（trigger）---> 创建触发器
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113131761-6927531.png)
　　填写完毕以后，我们点击下方的添加。
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113142604-1237551286.png)
　　该触发器已成功添加。
　　我们去查看一下：
　　监测中 ---> 最新数据
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113150479-1838545643.png)
　　我们来手动关闭redis服务来检测一下：

```shell
[root@node1 ~]# systemctl stop redis.service

```

　　进入 监测中 ---> 问题
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113158901-587145295.png)
　　可以看到，现在已经显示的是问题了。并且有持续的时间，当我们的服务被打开，会转为已解决状态：

```shell
[root@node1 ~]# systemctl start redis.service 

```

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113209698-2146797322.png)

###### 3.定义动作（action）

　　现在我们就可以去定义action了。
　　进入 配置 ---> 动作 ---> 创建动作（注意选择事件源为触发器）
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113224323-1883182490.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113232620-704184287.png)
　　我们可以进行操作添加：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113245604-1217342753.png)
　　我们可以看出，还需要在虚拟机上进行两项操作，一是修改sudo配置文件使zabbix用户能够临时拥有管理员权限；二是修改zabbix配置文件使其允许接收远程命令。我们进行如下操作：

```shell
[root@node1 ~]# visudo          #相当于“vim /etc/sudoers”
    ## Allow root to run any commands anywhere
    root    ALL=(ALL)   ALL
    zabbix    ALL=(ALL)   NOPASSWD: ALL     #添加的一行，表示不需要输入密码

[root@node1 ~]# vim /etc/zabbix/zabbix_agentd.conf
    EnableRemoteCommands=1          #允许接收远程命令
    LogRemoteCommands=1             #把接收的远程命令记入日志

[root@node1 ~]# systemctl restart zabbix-agent.service

```

　　我们添加了第一步需要做的事情，也就是重启服务，如果重启不成功怎么办呢？我们就需要来添加第二步：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113256073-936532007.png)
　　添加完成以后，我们可以看一下：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113304573-1567962822.png)
　　操作添加完了，如果服务自动恢复了，我们可以发送消息来提示：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113312104-1066002380.png)
　　至此，我们的动作设置完毕，可以点击添加了，添加完成会自动跳转至如下页面：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113334386-1664646229.png)
　　现在我们可以手动停止服务来进行测试：

```shell
[root@node1 ~]# systemctl stop redis.service 
```

　　然后我们来到问题页面来查看，发现确实有问题，并且已经解决：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113344229-460694111.png)
　　我们可以去server端查看是否收到邮件：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113351433-1159937452.png)
　　也可以去agent端查看端口是否开启：

```shell
[root@node1 ~]# systemctl stop redis.service 
[root@node1 ~]# ss -ntl
State       Recv-Q Send-Q Local Address:Port               Peer Address:Port              
LISTEN      0      128        *:6379                   *:*                  
LISTEN      0      128        *:111                    *:*                  
LISTEN      0      5      192.168.122.1:53                     *:*                  
LISTEN      0      128        *:22                     *:*                  
LISTEN      0      128    127.0.0.1:631                    *:*                  
LISTEN      0      128        *:23000                  *:*                  
LISTEN      0      100    127.0.0.1:25                     *:*                  
LISTEN      0      128        *:10050                  *:*                  
LISTEN      0      128       :::111                   :::*                  
LISTEN      0      128       :::22                    :::*                  
LISTEN      0      128      ::1:631                   :::*                  
LISTEN      0      100      ::1:25                    :::* 
```

　　可以看出端口正常开启，我们的动作触发已经完成。

> 补充：我们也可以使用脚本来发送警报，我们的脚本存放路径在配置文件中可以找到，定义为：`AlterScriptsPath=/usr/lib/zabbix/alertscripts`

　　接下来，我们来一波彻底一点的操作，我们来手动修改一下redis服务的监听端口，这样，我们就不能通过重启服务恢复了：

```shell
[root@node1 ~]# vim /etc/redis.conf
    #port 6379
    port 6380               #注释掉原来的端口，更换为新的端口

[root@node1 ~]# systemctl restart redis

```

　　然后，我们来网页查看一下状态：
　　进入 监测中 ---> 问题，可以看到是报错的：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113404433-2118773292.png)
　　这样，在经过了重启服务以后还是没能把解决问题，就会发邮件告警：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113411542-651613941.png)
　　我们再把服务端口改回来，然后重启服务。这样，等到问题自动解决了以后，我们会再次收到邮件：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113418464-1285901797.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113423229-1033392033.png)
　　这样，我们的动作设定已经全部测试完成。
　　



#### 6）zabbix可视化



##### ① 简介

　　数据日积月累，如果我们想要更直观的了解到各项数据的情况，图形无疑是我们的最佳选择。
　　zabbix提示了众多的可视化工具提供直观展示，如graph、screen及map等。上文中我们也看到过一些简单的图形展示。
　　如果我们想要把多个相关的数据定义在同一张图上去查看，就需要去自定义图形了~



##### ② 自定义图形（Graphs）

　　自定义图形中可以集中展示多个时间序列的数据流。支持“**线状图**(normal)”、“**堆叠面积图**(stacked)”、“**饼图**(pie)” 和“**分离型饼图**(exploded)”四种不同形式的图形。
　　具体的设置过程如下：
　　进入 配置 ---> 主机 ---> node1 ---> 图形，选择右上角创建图形：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113435808-1188202230.png)
　　我们来看一看四种状态：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113446229-1783458714.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113455729-1650294930.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113508323-296324748.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113518792-1529967613.png)
　　包括我们的主机都可以自定义，不过一般来说，线型是看的最清晰的，我们通常会使用这个。
　　我们也可以克隆一个packets来更改为bytes用~同样的，我们如果想添加别的内容，也都可以添加的。
　　我们一共添加了三个图形，我们可以在 监测中 ---> 图形 来查看
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113529323-675233317.png)



##### ③ 聚合图形（Screens）

　　我们创建的自定义图形也可以放在一个聚合图里显示，具体的设置方法如下：
　　进入 监测中 ---> 聚合图形 ---> 选择右上角创建聚合图形
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113537964-1631571055.png)
　　我们还可以选择分享：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113545823-147916381.png)
　　定义好了添加即可。
　　定义完成以后，我们需要编辑一下，来指定保存哪些图：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113554464-752616841.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113600370-802418603.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113605354-1914365422.png)
　　依次添加即可，添加完成之后是这样婶儿的~：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113615761-369104752.png)
　　因为我们只有三张图，所以添加的有重复的，通常情况下是不需要这样的。



##### ④ 幻灯片演示（Slide shows）

　　如果我们有多个聚合图形想要按顺序展示的话，我们就可以定义一个幻灯片。
　　具体步骤如下：
　　进入 监测中 ---> 聚合图形 ---> 右上角选择幻灯片演示 ---> 创建幻灯片
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113722761-480111985.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113728479-1024952951.png)
　　然后我们打开即可。打开以后显示的是图片1，5s以后会自动切换为图片2。
　　这样就可以实现幻灯片演示，我们就不需要去手动切换了。



##### ⑤ 定义拓扑图（Maps）

　　在拓扑图中，我们可以定义成一个复杂的网络连接图，我们可以使用一台主机来连接另一台主机，这样的话，我们就可以查看出到底是哪个链接出了问题。
　　我们就不来演示了，看一下过程即可：
　　进入 监测中 ---> 拓扑图 ---> 所有地图 ---> Local network(默认就有的)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113737542-556214868.png)
　　通过 Ping 和 Traceroute 就可以实验我们上述的功能。



#### 7）模板

##### ① 创建模板

　　之前我们说过，每一个主机的监控项都很多，我们一个一个的添加实在是太头疼了，更何况，可能不止一个主机。
　　但是我们可以把一个redis的监控项添加进一个模板里，这样更方便于我们以后的添加。
　　具体操作如下：
　　进入 配置 ---> 模板 ---> 选择右上角创建模板
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113750354-1623976848.png)
　　填写完以后，我们点击下方的添加即可。
　　我们可以基于组过滤一下，就能看到我们刚刚定义的模板：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113804511-1013330801.png)
　　一样的，我们可以向里面添加应用集、监控项、触发器、图形等等，添加完成以后，后期我们再有主机需要添加就直接套用模板即可。
　　需要注意的一点是，**我们现在添加的是模板，所以不会立即采用数据，只有链接到主机上以后，才会真正生效。**



##### ② 模板的导入与导出

　　我们也可以直接导入一个模板，在互联网上可以找到很多，导入的步骤如下：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113819745-1921041608.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113824698-623720508.png)
　　同样的，我们创建好的模板也可以导出为文件：
　　我们任意选中一个准备好的模板，然后页面的最下方就有导出按钮：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113835714-1215549189.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113840729-2020667526.png)
　　因此，我们就可以非常方便的进行应用了~



##### ③ 模板的应用

　　我们的软件已经创建了许多模板，我们可以使用一个模板来看看效果。
　　进入 配置 ---> 主机 ---> node1 ---> 模板
　　我们就可以选择要添加的模板了：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113850261-1781138138.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113858933-353038188.png)
　　到这里我们就可以点击更新了。一旦我们成功链接至模板，我们的主机数据就会更新了：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113910870-459511423.png)
　　注意：1、一个主机可以链接多个模板，但尽量不要让一个指标被采样两次。
　　2、如果我们有多个主机，同时这些主机也在一个主机组里，这样的话，我们只需要在这个主机组里添加模板，就能够让在主机组里的所有主机进行tongb



##### ④ 移除模板链接

　　当我们一个主机的模板不想要用了，我们就可以移除模板链接，具体操作步骤如下：
　　进入 配置 ---> 主机 ---> node1 ---> 模板
　　我们就可以把不需要的模板移除：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113922292-685697244.png)
　　我们来删除掉试试看，移除并清理以后，我们点击更新。就会自动跳转至如下界面：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113931151-1815278685.png)
　　可以看出，我们的模板已经被移除了。



#### 8）宏（macro）



##### ① 简介

　　宏是一种抽象(Abstraction)，它根据一系列预定义的规则替换一定的文本模式，而解释器或编译器在遇到宏时会自动进行这一模式替换。
　　类似地，zabbix基于宏保存预设文本模式，并且在调用时将其替换为其中的文本。
　　zabbix有许多内置的宏，如{HOST.NAME}、{HOST.IP}、{TRIGGER.DESCRIPTION}、{TRIGGER.NAME}、{TRIGGER.EVENTS.ACK}等。
　　详细信息请参考[官方文档](https://www.zabbix.com/documentation/2.0/manual/appendix/macros/supported_by_location)
　　



##### ② 级别

　　宏一共有三种级别，分别是全局宏、模板宏、主机宏。
　　不同级别的宏的适用范围也不一样。

> 全局宏也可以作用于所有的模板宏和主机宏，优先级最低。
> 模板宏则可以作用于所有使用该模板的主机，优先级排在中间。
> 主机宏则只对单个主机有效，优先级最高。



##### ③ 类型

　　宏的类型分为系统内建的宏和用户自定义的宏。
　　为了更强的灵活性，zabbix还支持在全局、模板或主机级别使用用户自定义宏(user macro)。
　　系统内建的宏在使用的时候需要`{MACRO}`的语法格式，用户自定义宏要使用`{$MACRO}`这种特殊的语法格式。
　　宏可以应用在item keys和descriptions、trigger名称和表达式、主机接口IP/DNS及端口、discovery机制的SNMP协议的相关信息中……
　　宏的名称只能使用**大写字母、数字及下划线**。
　　进一步信息请参考[官方文档](https://www.zabbix.com/documentation/2.0/manual/appendix/macros/supported_by_location#additional_support_for_user_macros)。



##### ④ 定义一个宏

　　如果我们想要在我们的监控项(items)上使用宏，我们就要先去定义一个宏，然后去创建监控项，直接引用定义好的宏即可。具体操作步骤如下：

###### 1.定义全局宏

　　进入 管理 ---> 一般 ---> 右上角选择宏
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113946011-1443279156.png)
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113951651-1189531352.png)
　　这样，我们的全局宏就添加好了。

###### 2.定义监控项，调用宏

　　进入 配置 ---> 主机 ---> 所有主机 ---> 监控项 ---> 右上角创建监控项
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202114002058-1535509929.png)
　　填写完成以后，点击添加。然后我们就可以看到这个调用宏的监控项已经添加成功：
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202114011401-371254446.png)
　　我们可以来查看一下这个监控项现在的状态：
　　进入 监测中 ---> 最新数据
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202114025964-731346716.png)
　　如果我们把服务停掉。就会变成`down`的状态：

```shell
[root@node1 ~]# systemctl stop redis

```

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202114036370-1539610385.png)
　　发现我们的监控项是可以正常使用的。

###### 3.修改宏

　　如果我们把node1节点上的redis服务监听端口手动改掉的话，我们刚刚定义的监控项就不能正常使用了，这样的话，我们就需要去修改宏。
　　但是，这毕竟只是个例，所以我们不需要去修改全局宏，只用修改模板宏或者主机宏就可以了。
　　下面分别说一下，模板宏和主机宏的不同修改操作：
**模板宏**
　　模板宏的修改，我们需要进入：配置 ---> 模板 ---> redis stats（相应的模板） ---> 宏
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202114046214-736225671.png)
　　在这里点击添加就可以了。
**主机宏**
　　主机宏的修改，我们需要进入：配置 ---> 主机 ---> 所有主机 ---> node1 ---> 宏
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202114054667-621488105.png)
　　在这里点击添加就可以了。




## 5、User parameters 用户参数

### 1、介绍和用法

① 介绍

自定义用户参数，也就是自定义key

有时，你可能想要运行一个代理检查，而不是Zabbix的预定义

你可以**编写一个命令**来**检索需要的数据**，并将其包含在代理配置文件("UserParameter"配置参数)的**用户参数**中

② 用法格式 syntax

**UserParameter=<key>,<command>**

　　A user parameter also contains a key　　一个用户参数也包含一个键

　　The key will be necessary when configuring an item 　　在配置监控项时，key是必需的

　　Note: Need to restart the agent 　　注意:需要重新启动agent 服务 

### 2、用法展示

（1）修改agent 端的配置，设置用户参数

① free | awk '/^Mem/{print $3}' 自己需要查找的参数的命令

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226171855010-665295523.png)

② 修改配置文件，把查找参数的命令设为用户参数

cd /etc/zabbix/zabbix_agentd.d/

vim **memory_usage.conf**

**UserParameter=memory.used,free | awk '/^Mem/{print $3}'**

③ systemctl restart zabbix-agent.service 重启agent 服务

（2）在zabbix-server 端，查询

zabbix_get -s 192.168.30.7 -p 10050 -k "memory.used"

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172647557-2133137319.png)

（3）在监控上，设置一个item监控项，使用这个用户参数

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172026041-1695073569.png)

（4）查询graph 图形

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172026463-839175044.png)

 

### 3、用法升级

（1）修改agent 端的配置，设置用户参数

① 命令行查询参数的命令

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172026698-1464978164.png)

② 修改配置文件，把查找参数的命令设为用户参数

UserParameter=**memory.stats[\*]**,cat /proc/meminfo | awk **'/^$1/{print $$2}**'

分析：$$2：表示不是调前边位置参数的$2 ，而是awk 的参数$2

注意：$1是调用前边的[*]，位置参数，第一个参数

 

（2）在zabbix-server 端，查询使用这个用户参数的key

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172026932-1905881550.png)

 

（3）在监控上，设置一个item监控项，使用这个用户参数

① 添加Memory Total 的item监控项，使用**memory.stats[MemTotal]** 的用户参数

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172027260-1446706159.png)

在进程中定义倍数，规定单位

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172027729-143163327.png)

 

② clone 克隆Memory Total 创建Memory Free 的监控项

**memory.stats[MemFree]** 用户参数

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172028120-539441659.png)

③ 创建Memory Buffers 的item 监控项，使用 **memory.stats[Buffers]** 的key

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172028448-41169528.png)

 

（4）上面3个监控项的graph 图形

① memory total

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172028745-1274821835.png)

② memory free

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172029088-1142382464.png)

③ buffers

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172029338-158312847.png)

 

### 4、使用用户参数监控 php-fpm 服务的状态

在agent 端：

（1）下载，设置php-fpm

① yum -y install php-fpm

② vim /etc/php-fpm.d/www.conf 打开php-fpm的状态页面

```shell
user = nginx
group = nginx
pm.status_path = /status    #php-fpm 的状态监测页面
ping.path = /ping           #ping 接口，存活状态是否ok
ping.response = pong        #响应内容pong

```

③ systemctl start php-fpm 开启服务

（2）设置nginx ，设置代理php，和php-fpm的状态页面匹配

① vim /etc/nginx/nginx.conf

```shell
location ~ \.php$ {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
}
location ~* /(php-fpm-status|ping) {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $fastcgi_script_name;
            include        fastcgi_params;

            allow 127.0.0.1;   #因为这个页面很重要，所有需加访问控制
            deny all;

            access_log off;   #访问这个页面就不用记录日志了
}

```

 复制状态信息页面到网站根目录

cp /usr/share/fpm/status.html /usr/share/nginx/html/

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172029791-156116121.png)

② systemctl start nginx 开启nginx服务

 

（3）在agent 端，设置用户参数

① 查询 curl 192.168.30.7/php-fpm-status

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172030088-1020205629.png)

② 设置

cd /etc/**zabbix/zabbix_agentd.d/**

vim php_status.conf

**UserParameter=php-fpm.stats[\*]**,**curl -s http://127.0.0.1/status | awk '/^$1/{print $$NF}'**

分析：设置用户参数为php-fpm.stats[*]，$1为第一个参数；$$NF为awk中的参数，倒数第一列

 

③ 重启服务

systemctl restart zabbix-agent

 

（4）在zabbix-server 端，查询使用这个用户参数的key

zabbix_get -s 192.168.30.7 -p 10050 -k "php-fpm.stats[idle]"

zabbix_get -s 192.168.30.7 -p 10050 -k "php-fpm.stats[active]"

zabbix_get -s 192.168.30.7 -p 10050 -k "php-fpm.stats[max active]"

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172030323-150229024.png)

 

（5）创建一个模板，在模板上创建4个item监控项，使用定义的用户参数

① 创建一个模板

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172030682-152674187.png)

② 在模板上配置items 监控项，使用刚定义的用户参数

**fpm.stats[total processes]**

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172031120-396201427.png)

③ 再clone克隆几个items监控项

**fpm.stats[active processes]**

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172031495-1001452204.png)

④ **fpm.stats[max active processes]**

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172031807-398956119.png)

⑤ **fpm.stats[idle processes]**

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172032120-165244744.png)

 

（6）host主机链接模板

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172032495-2030001112.png)

 

（7）查看graph 图形

① php-fpm total processes

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172032760-1387400769.png)

② php-fpm active processes

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172033276-1849464959.png)

③ php-fpm max active processes

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172033573-911796042.png)

④ php-fpm idle processes

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172034198-1450005062.png)

 

（8）把模板导出，可以给别人使用

① 导出模板

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172034682-1229092767.png)

最下面有导出

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172035088-116185645.png)

② 自己定义用户参数的文件，也不要忘记导出

/etc/zabbix/zabbix_agentd.d/php_status.conf

 

## 6、Network discovery 网络发现

### 1、介绍

（1）介绍

网络发现：zabbix server**扫描指定网络范围内的主机**；

网络发现是zabbix 最具特色的功能之一，它能够根据用户**事先定义的规则自动添加监控的主机或服务**等

优点：

　　加快Zabbix部署

　　简化管理

在快速变化的环境中使用Zabbix，而不需要过度管理

 

（2）发现方式：

ip地址范围；

　　可用服务（ftp, ssh, http, ...）

　　zabbix_agent的响应；

　　**snmp**_agent的响应；

 

（3）网络发现通常包含两个阶段：discovery发现 和actions动作

① discovery：

Zabbix定期扫描网络发现规则中定义的IP范围；检查的频率对于每个规则都是可配置的

每个规则都有一组用于为IP范围执行的服务检查

由网络发现模块执行的服务和主机(IP)的每个检查都会生成一个发现事件

8种响应事件

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172035479-1598541190.png)

② actions：网络发现中的事件可以触发action，从而自动执行指定的操作，把discvery events当作前提条件；

　　Sending notifications 发送通知

　　Adding/removing hosts 添加/删除主机

　　Enabling/disabling hosts 启用/禁用host

　　Adding hosts to a group 向组中添加主机

　　Removing hosts from a group 移除组中的主机

　　Linking hosts to/unlinking from a template 从模板链接主机或取消链接

　　Executing remote scripts 执行远程脚本

这些事件的配置还可以基于设备的类型、IP 、状态、上线/ 离线等进行配置

 

（4）网络发现：接口添加

网络发现中添加主机时会自动创建interface 接口

例如：

　　如果基于SNMP 检测成功，则会创建SNMP 接口

　　如果某服务同时响应给了agent 和SNMP ，则**两种接口都会创建**

　　如果同一种发现机制( 如agent) 返回了非惟一数据，则**第一个接口被识别为默认，其它的为额外接口**

　　即便是某主机开始时只有agent 接口，后来又通过snmp 发现了它，同样会为其添加额外的snmp 接口

　　不同的主机如果返回了相同的数据，则第一个主机将被添加，余下的主机会被当作第一个主机的额外接口

 

### 2、配置网络发现 Network discovery

（1）准备一台可被扫描发现的主机

① 安装agent 段的包

yum -y install zabbix-agent zabbix-sender

② 设置agent 配置，可以把之前设置好的node1的配置传过来

vim /etc/zabbix/zabbix_agentd.conf

Hostname=node2.along.com #只需修改hostname

③ visudo 修改sudo的配置

\#Defaults !visiblepw

zabbix ALL=(ALL) NOPASSWD: ALL

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172036745-511117378.png)

④ 开启服务

systemctl start zabbix-agent

 

（2）设置自动发现规则discovery

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172037370-800415726.png)

注释：

① key：zabbix_get -s 192.168.30.2 -p 10050 -k "system.hostname"

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172037635-349059993.png)

② 更新间隔：1h就好，不要扫描太过频繁，扫描整个网段，太废资源；这里为了实验，设为1m

 

（3）自动发现成功

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172037948-2146168679.png)

 

（4）设置自动发现discovery 的动作action

a) 创建

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172038182-11402625.png)

b) 设置action动作

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172038541-1323988067.png)

① 设置A条件，自动发现规则=test.net

② 设置B条件，自动发现状态=up

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172038823-1466028368.png)

③ 要做什么操作

添加主机到监控

自动链接Template OS Linux 到此host

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172039213-1479221797.png)

c) 配置action 完成，默认是disabled 停用的

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172039526-1399823520.png)

d) 启用动作，查看效果

确实已经生效，添加主机成功，模板链接成功

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172039979-1033265636.png)

 

（5）如果自己需要添加的主机已经扫描添加完成，就可以关闭网络扫描了，因为太耗资源

 

## 7、web监控

### 1、介绍

（1）介绍

① Web监控：监控指定的站点的**资源下载速度**，及**页面响应时间**，还有**响应代码**；

② 术语：

　　web Scenario： web场景（站点）

　　web page ：web页面，一个场景有多个页面

　　內建key：要测一个页面，要测三个步骤（下边3个內建key）

③ 内建key：

　　 web.test.in[Scenario,Step,bps]：传输速率

　　 web.test.time[Scenario,Step]： 响应时长

　　 web.test.rspcode[Scenario,Step]：响应码

 

### 2、创建设置web场景

（1）创建

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172040229-465393880.png)

 

（2）配置web 监测

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172040588-1557305887.png)

① 点击步骤，设置 web page web 页面

a) 设置名为home page，URL为http://192.168.30.7/index.html 的web页面

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172040885-1526168288.png)

b) 设置名为fpm status，URL为http://192.168.30.7/fpm-status 的web页面

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172041291-925383434.png)

c) 设置2个web页面成功

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172041870-962857372.png)

② 如果有特殊认证，也可以添加

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172042166-1660206125.png)

 

### 3、查看测试

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172042510-1962638311.png)

 

## 8、主动/被动 监控

### 1、介绍

（1）主动/被动介绍

　　被动检测：相对于agent而言；agent, **server向agent请求获取配置的各监控项相关的数据**，agent接收请求、获取数据并响应给server；

　　主动检测：相对于agent而言；agent(active),**agent向server请求与自己相关监控项配置**，主动地将server配置的监控项相关的数据发送给server；

　　主动监控能极大节约监控server 的资源。

（2）zabbix_sender发送数据：实现人工生成数据，发给server端

① zabbix server上的某主机上，直接定义Item时随便定义一个不与其它已有key冲突的key即可，即item type为"zabbix trapper"；

② 用法选项：

zabbix_sender

　　-z zabbix_server_ip

　　-p zabbix_server_port

　　-s zabbix_agent_hostname

　　-k key

　　-o value 值

 

### 2、设置一个通过內建key发送数据的主动监控

（1）agent端所需要基本配置：

```shell
ServerActive=192.168.30.107   给哪个监控server 发送数据
Hostname=node1.along.com   自己的主机名，假设主机定死了，不设置下一项
#HostnameItem=   如果自己的主机名易变动，这一项相当于key一样去匹配
```

注意：若后两项同时启用，下边一个选择生效

 

（2）设置一个主动监测

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172042870-1427172290.png)

① 选择进程，每秒更改，

因为key：system.cpu.switches ：上下文的数量进行切换，它返回一个整数值。为了监控效果，选择下一秒减上一秒的值作为监控

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172043120-1810882608.png)

（3）已经有啦graph图形

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172043526-25418384.png)

 

### 3、设置一个通过命令zabbix_sender发送数据的主动监控

（1）配置一个zabbix traper(采集器) 的item 监控项

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172043838-1551635865.png)

（2）agent 端手动发送数据

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172044120-1117751325.png)

（3）监控到数据的变化

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172044682-2050320416.png)

 

## 9、基于SNMP监控（了解）

### 1、介绍

（1）介绍

SNMP：**简单**网络管理协议；（非常古老的协议）

三种通信方式：读（get, getnext）、写（set）、trap（陷阱）；

端口：

　　161/udp

　　162/udp

SNMP协议：年代久远

　　v1: 1989

　　**v2c**: 1993

　　v3: 1998

监控网络设备：交换机、路由器

MIB：Management Information Base 信息管理基础

OID：Object ID 对象ID

 

（2）Linux启用snmp的方法：

yum install net-snmp net-snmp-utils

配置文件：定义ACL

　　/etc/snmp/snmpd.conf

启动服务：

　　systemctl start snmpd 被监控端开启的服务

　　 systemctl start snmptrapd    监控端开启的服务（如果允许被监控端启动主动监控时启用）

 

（3）配置文件的介绍

开放数据：4步

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172045276-679726746.png)

① 定义认证符，将社区名称"public"映射为"安全名称"

② 将安全名称映射到一个组名

③ 为我们创建一个视图，让我们的团队有权利

**掩码：**我列出一些注释，有很多，可以再网上查询

**.1.3.6.1.2.1.**

　　 1.1.0：系统描述信息，SysDesc

　　 1.3.0：监控时间， SysUptime

　　 1.5.0：主机名，SysName

　　 1.7.0：主机提供的服务，SysService

.1.3.6.1.2.2.

　　 2.1.0：网络接口数目

　　 2.2.1.2:网络接口的描述信息

　　 2.2.1.3:网络接口类型

　　 ……

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172045604-1497693285.png)

④ 授予对systemview视图的只读访问权

 

（4）测试工具：

​    \# **snmpget** -v 2c -c public HOST OID

​    \# **snmpwalk** -v 2c -c public HOST OID 通过这个端口查询到的数据，全列出了

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172045948-698976544.png)

 

### 2、配置SNMP监控

（1）下载，修改配置文件

vim /etc**/snmp/snmpd.conf**

```
view    systemview    included   .1.3.6.1.2.1.1
view    systemview    included   .1.3.6.1.2.1.2      # 网络接口的相关数据
view    systemview    included   .1.3.6.1.4.1.2021   # 系统资源负载，memory, disk io, cpu load 
view    systemview    included   .1.3.6.1.2.1.25

```

（2）在agent 上测试

snmpget -v 2c -c public 192.168.30.2 .1.3.6.1.2.1.1.3.0

snmpget -v 2c -c public 192.168.30.2 .1.3.6.1.2.1.1.5.0

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172046245-1946753487.png)

 

（3）在监控页面，给node2加一个snmp的接口

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172046541-990434657.png)

（4）在node2上加一个 Template OS Linux SNMPv2 模板

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172046854-1430722762.png)

模板添加成功，生成一系列东西

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172047151-639977143.png)

点开一个item 看一下

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172047463-1455547608.png)

 

（5）生成一些最新数据的图形graph了

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172047729-481410869.png)

 

### 3、设置入站出站packets 的SNMP监控

（1）监控网络设备：交换机、路由器的步骤：

① 把交换机、路由器的SNMP 把对应的OID的分支启用起来

② 了解这些分支下有哪些OID，他们分别表示什么意义

③ 我们要监控的某一数据：如交换机的某一个接口流量、报文，发送、传入传出的报文数有多少个；传入传出的字节数有多少个，把OID取出来，保存

 

（2）定义入站出站的item监控项

interface traffic packets(in)

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172048182-394941521.png)

interface traffic packets(out)

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172048510-973935048.png)

 

## 10、JMX接口

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172048698-2048639928.png)

### 1、介绍

（1）介绍

Java虚拟机(JVM)具有内置的插件，使您能够使用JMX监视和管理它。您还可以使用JMX监视工具化的应用程序。

（2）配置设置介绍

① zabbix-java-gateway主机设置：

　　安装 zabbix-java-gateway程序包，启动服务；

　　yum -y install zabbix-java-gateway

② zabbix-server端设置（需要重启服务）：

　　**JavaGateway=**172.16.0.70

　　**JavaGatewayPort=**10052

　　**StartJavaPollers=**5 #监控项

③ tomcat主机设置：

　　 监控tomcat：

　　　　 /etc/sysconfig/tomcat，添加

　　**CATALINA_OPTS**="-Djava.rmi.server.hostname=TOMCAT_SERVER_IP -Djavax.management.builder.initial= -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=12345 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"   #启用JVM接口，默认没有启用

　　添加监控项：

　　　　  jmx[object_name,attribute_name]

　　　　　　object name - 它代表MBean的对象名称

　　　　　　attribute name - 一个MBean属性名称，可选的复合数据字段名称以点分隔

　　　　示例：

　　　　　　 jmx["java.lang:type=Memory","HeapMemoryUsage.used"

④ jmx的详细文档：https://docs.oracle.com/javase/1.5.0/docs/guide/management/agent.html

**注意:**   如果是手动安装的tomcat  需要编辑  catalina.sh  文件 ，重启 tomcat

### 2、配置JVM接口监控

（1）安装配置tomcat

① 下载安装tomcat，主要是用JVM

yum -y install **java-1.8.0-openjdk-devel tomcat-admin-webapps tomcat-docs-webapp**

② 加CATALINA_OPTS= #启用JVM接口，默认没有启用

vim /etc/sysconfig/tomcat

```
CATALINA_OPTS="-Djava.rmi.server.hostname=192.168.30.2 -Djavax.management.builder.initial= -Dcom.sun.management.jmxremote=true   -Dcom.sun.management.jmxremote.port=12345  -Dcom.sun.management.jmxremote.ssl=false  -Dcom.sun.management.jmxremote.authenticate=false"

```

③ 开启服务

systemctl start tomcat

 （2）在**zabbix-server 端**，安装配置java-gateway

① 安装配置java-gateway

yum -y install zabbix-java-gateway

/etc/zabbix/zabbix_java_gateway.conf 安装完后，会生成一个java_gateway 的配置文件

systemctl start zabbix-java-gateway.service 不用修改，直接开启服务

 

② 修改server 配置，开启java-gateway的配置

vim /etc/zabbix/**zabbix_server.conf**

```
JavaGateway=192.168.30.107  
JavaGatewayPort=10052
StartJavaPollers=5    #打开5个监控项

```

③ systemctl restart zabbix-server 重启zabbix-server 服务

 

（3）在node2 主机上添加JMX接口，实验模板

① 添加JMX接口

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172049182-664693382.png)

② 在node2 上连接tomcat JMX 模板

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172049541-701630088.png)

③ 随便查看一个监控项item

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172050010-1062166097.png)

 

（4）自己定义一个堆内存使用的监控项，基于JVM接口（没必要，使用模板就好）

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172050479-619246539.png)

 

## 11、分布式监控

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172050995-2135249770.png)

### 1、介绍

（1）介绍

分布式监控概述

　　proxy and node

Zabbix 的三种架构

　　Server-agent

　　Server-Node-agent

　　Server-Proxy-agent

监控Zabbix

 

（2）配置介绍

Zabbix Proxy的配置：

　　server-node-agent

　　server-proxy-agent

a) 配置proxy主机：

(1) 安装程序包

​    zabbix-proxy-mysql zabbix-get zabbix-agent zabbix-sender

(2) 准备数据库

　　创建、授权用户、导入schema.sql；

(3) 修改配置文件

　　Server= zabbix server主机地址；

　　Hostname=

　　　　当前代理服务器的名称；在server添加proxy时，必须使用此处指定的名称；

　　　　=需要事先确保server能解析此名称；

　　DBHost=

　　DBName=

　　DBUser=

　　DBPassword=

 

　　ConfigFrequency=10   # proxy被动模式下，server多少秒同步配置文件至proxy。该参数仅用于被动模式下的代理。范围是1-3600*24*7

　　DataSenderFrequency=1     #代理将每N秒将收集的数据发送到服务器。 对于被动模式下的代理，该参数将被忽略。范围是1-3600

 

b) 在server端添加此Porxy

​    Administration --> Proxies

 

c) 在Server端配置通过此Proxy监控的主机；

注意：zabbix agent端要允许zabbix proxy主机执行数据采集操作：

 

### 2、实现分布式zabbix proxy监控

实验前准备：

① ntpdate 172.168.30.1 同步时间

② 关闭防火墙，selinux

③ 设置主机名 hostnamectl set-hostname zbproxy.along.com

④ vim /etc/hosts 每个机器都设置hosts，以解析主机名；DNS也行

192.168.30.107 server.along.com

192.168.30.7 node1.along.com

192.168.30.2 node2.along.com

192.168.30.3 node3.along.com zbproxy.along.com

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172051276-274670232.png)

（1）环境配置（4台主机）

| 机器名称      | IP配置         | 服务角色  |
| ------------- | -------------- | --------- |
| zabbix-server | 192.168.30.107 | 监控      |
| agent-node1   | 192.168.30.7   | 被监控端  |
| agent-node2   | 192.168.30.2   | 被监控端  |
| node3         | 192.168.30.3   | 代理proxy |

 

zabbix-server 直接监控一台主机node1

zabbix-server 通过代理node3 监控node2

 

（2）在node3 上配置mysql

① 创建配置mysql

1、创建 mariadb.repo

```shell
vim /etc/yum.repos.d/mariadb.repo
写入以下内容：
[mariadb]
name = MariaDB 
baseurl = https://mirrors.ustc.edu.cn/mariadb/yum/10.4/centos7-amd64 
gpgkey=https://mirrors.ustc.edu.cn/mariadb/yum/RPM-GPG-KEY-MariaDB 
gpgcheck=1
```

2、yum 安装最新版本 mariadb

```shell
yum install -y MariaDB-server MariaDB-clien
```

　　首先，我们修改一下配置文件——`/etc/my.cnf.d/server.cnf`：

```shell
[root@server ~]# vim /etc/my.cnf.d/server.cnf
    [mysqld]
    skip_name_resolve = ON          #跳过主机名解析
    innodb_file_per_table = ON      #
    innodb_buffer_pool_size = 256M  #缓存池大小
    max_connections = 2000          #最大连接数
    log-bin = master-log            #开启二进制日志
```

3、重启我们的数据库服务：

```shell
[root@server ~]# systemctl restart mariadb
[root@server ~]# mysql_secure_installation  #初始化mariadb
```

③ 创建数据库 和 授权用户

```sql
MariaDB [(none)]> create database zbxproxydb character set 'utf8';
MariaDB [(none)]> grant all on zbxproxydb.* to 'zbxproxyuser'@'192.168.30.%' identified by 'zbxproxypass';
MariaDB [(none)]> flush privileges;
```

（3）在node3 上下载zabbix 相关的包，主要是代理proxy的包

```
yum -y install zabbix-proxy-mysql zabbix-get zabbix-agent zabbix-sender
```

a) **初始化数据库**

zabbix-proxy-mysql 包里带有，导入数据的文件

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172052791-1016956277.png)

```shell
cp /usr/share/doc/zabbix-proxy-mysql-3.4.4/schema.sql.gz ./ 复制
gzip -d schema.sql.gz 解包
mysql -root -p zbxproxydb < schema.sql 导入数据

```

b) 查看数据已经生成

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172053276-1712858671.png)

 

（4）配置proxy端

① vim /etc/zabbix/zabbix_proxy.conf

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172053682-47495044.png)

```shell
Server=192.168.30.107   #server 的IP
ServerPort=10051   #server 的端口

Hostname=zbxproxy.along.com   #主机名
ListenPort=10051    #proxy自己的监听端口
EnableRemoteCommands=1    #允许远程命令
LogRemoteCommands=1    #记录远程命令的日志

数据的配置
DBHost=192.168.30.3
DBName=zbxproxydb  
DBUser=zbxproxyuser
DBPassword=zbxproxypass

ConfigFrequency=30      #多长时间，去服务端拖一次有自己监控的操作配置；为了实验更快的生效，这里设置30秒，默认3600s
DataSenderFrequency=1   #每一秒向server 端发一次数据，发送频度
```

② systemctl start zabbix-proxy 开启服务 

（5）配置node2端，允许proxy代理监控

vim /etc/zabbix/zabbix_agentd.conf

```
Server=192.168.30.107,192.168.30.3
ServerActive=192.168.30.107,192.168.30.3

```

systemctl restart zabbix-agent 启动服务 

（6）把代理加入监控server，创建配置agent 代理

① 创建agent 代理

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172053932-978486530.png)

② 配置

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172054213-335809349.png)

 

（7）创建node2 主机，并采用代理监控

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172054682-1009619727.png)

设置代理成功

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172055307-1060200173.png)

 

（8）创建item监控项

① 为了实验，随便创一个监控项 CPU Switches

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172055698-1128474710.png)

② 进程里设置每秒更改

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172055932-1067681793.png)

③ 成功，graph 图形生成

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172056416-1575771036.png)

 

## 12、查询使用网上模板监控

### 1、官方的 share 分享网站

https://share.zabbix.com/zabbix-tools-and-utilities

例如：我们要实现监控Nginx ，我们查找一个模板

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172057635-1089716709.png)

就以这个模板为例

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172058182-128310444.png)

 

### 2、在node1 上使用此模板

（1）安装配置 nginx

① yum -y install nginx

vim /etc/nginx/nginx.conf 按照网页的操作指示

```shell
location /stub_status {
        stub_status on;
        access_log off;
    #    allow 127.0.0.1;   #为了操作方便，我取消的访问控制
    #    deny all;
}
```

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172058510-1149178016.png)

② 启动服务

systemctl restart nginx

（2）下载模板所依赖的脚本

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172058823-57198051.png)

mkdir -p /srv/zabbix/libexec/

cd /srv/zabbix/libexec/

wget https://raw.githubusercontent.com/oscm/zabbix/master/nginx/nginx.sh 从网页上获取脚本

chmod +x nginx.sh 加执行权限

 

（3）配置agent 的用户参数UserParameter

cd /etc/zabbix/zabbix_agentd.d/

wget https://raw.githubusercontent.com/oscm/zabbix/master/nginx/userparameter_nginx.conf 很短，自己写也行

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172059073-397108138.png)

（4）在windows 上下载模板，并导入这server 的模板中

wget https://raw.githubusercontent.com/oscm/zabbix/master/nginx/zbx_export_templates.xml 可以现在linux上下载，再sz 导出到windows上

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172059291-1133694346.png)

① 导入下载的模板

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172059635-1317185355.png)

② 主机node1 链接这个模板

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172100041-1015144646.png)

③ 模板生效

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172100323-635966866.png)

 

## 13、zabbix-server 监控自己，数据库，nginx

### 1、下载安装，配置agent

vim /etc/zabbix/zabbix_agentd.conf 配置agent

```shell
EnableRemoteCommands=1    允许远程命令
LogRemoteCommands=1    记录远程命令
Server=127.0.0.1   #建议真实ip地址
ServerActive=127.0.0.1
Hostname=server.along.com
```

### 2、自动生成Zabbix server 的主机

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172101526-749330259.png)

### 3、在主机中添加模板

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172101885-2112581492.png)

### 4、启用Zabbix server

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172102370-823261452.png)

### 5、监控到数据

#### zabbix_agent 客户端操作

1、创建mysql用户，使用zabbix账号连接本地mysql

```shell
mysql> GRANT ALL ON *.* TO 'zabbix'@'localhost' IDENTIFIED BY '123456';
mysql> FLUSH PRIVILEGES;
```

2、在zabbix_agentd 创建 .my.cnf （用户名密码登录配置文件）

​        cat  /etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf  #获取登录配置文件创建路径

​        mkdir -p /var/lib/zabbix

​        在/var/lib/zabbix下创建(隐藏).my.cnf
​        cat ./my.cnf

```shell
 [client]
 user=zabbix
 password=123456

```



![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1216496-20171226172102698-926445046.png)

 

## 14、调优

### 1、调优

① Database：

　　历史数据不要保存太长时长；

　　尽量让数据缓存在数据库服务器的内存中；

② 触发器表达式：**减少使用聚合函数** min(), max(), avg()；尽量使用last()，nodata()；

　　因为聚合函数，要运算

③ 数据收集：polling较慢(减少使用SNMP/agentless/agent）；**尽量使用trapping（agent(active）主动监控）；**

④ 数据类型：文本型数据处理速度较慢；**尽量少**收集类型为**文本** text或string类型的数据；**多使用**类型为numeric **数值型数据** 的；

### 2、zabbix服务器的进程

(1) 服务器组件的数量；

　　alerter, discoverer, escalator, http poller, hourekeeper, icmp pinger, ipmi polller, poller, trapper, configration syncer, ...

　　StartPollers=60

　　StartPingers=10

　　...

　　StartDBSyncer=5

　　...

 

(2) 设定合理的缓存大小

　　 CacheSize=8M

　　 HistoryCacheSize=16M

　　 HistoryIndexCacheSize=4M

　　 TrendCacheSize=4M

　　 ValueCacheSize=4M

 

(3) 数据库优化

　　分表：

　　　　history_*

　　　　trends*

　　　　events*



### 3、其它解决方案

grafana：展示

collectd：收集

influxdb：存储

 

grafana+collectd+influxdb

 

prometheus：

　　 exporter：收集

　　 alertmanager:

grafana：展示

 

openfalcon



# zabbix + grafana 安装使用

------



# zabbix使用

> 注:本文以上使用的是openresty+php7+mysql+zabbix,没有使用官网用的apache作为web代理,如果想使用请到这里,

[zabbix 手册](https://www.zabbix.com/documentation/3.4/zh/manual/installation/install_from_packages)

## 安装server端

### zabbix官方有提供各发行版的源

```
rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-1.el7.centos.noarch.rpm
```

### 安装zabbix server包：

```
yum install zabbix-server-mysql zabbix-web-mysql
```

### client安装：

```
yum install zabbix-agent
```

### zabbix需要数据库支持，通过上面的命令不会自动安装mysql，先安装mysql

```
yum install mysql mysql-server
```

### 安装好后建立zabbix的数据库

```shell
      create database zabbix character set utf8 collate utf8_bin;
      grant all privileges on zabbix.* to zabbix@'localhost' identified by ‘zabbix’;
```

#### 然后导入zabbix的数据库文件

```shell
      cd /usr/share/doc/zabbix-server-mysql-2.2.9/create
      mysql -uzabbix -p zabbix < schema.sql
      mysql -uzabbix -p zabbix < images.sql
      mysql -uzabbix -p zabbix < data.sql
```

#### 导入成功后将数据库信息加入zabbix_server.conf

```shell
      vi /etc/zabbix/zabbix_server.conf
      DBHost=localhost
      DBName=zabbix
      DBUser=zabbix
      DBPassword=zabbix
```

#### 启动zabbix server

```
service zabbix-server start
```

### 安装openresty

```bash
 yum -y install pcre-devel freetype-devel libtool mercurial pkgconfig zlib-devel openssl-devel

 wget https://openresty.org/download/openresty-1.9.7.4.tar.gz

 tar zxvf openresty-1.9.7.4.tar.gz

 cd openresty-1.9.7.4 \
    && ./configure \
        --with-http_flv_module \
        --with-http_mp4_module \
    && gmake -j $(nproc) \
    && gmake install
 /usr/local/openresty/nginx/sbin/nginx
参考官方文档安装 https://openresty.org/cn/installation.html
这里不多介绍
```

#### 启动配置nginx.conf

```bash
server {
listen       80;
server_name  localhost;

#charset koi8-r;

#access_log  logs/host.access.log  main;

client_max_body_size 1024M;

root /usr/share/zabbix; ## zabbix web文件目录
index index.php index.html index.htm;

location / {
  try_files $uri $uri/ /index.php?$query_string;
}

#error_page  404              /404.html;

# redirect server error pages to the static page /50x.html
#
error_page   500 502 503 504  /50x.html;
location = /50x.html {
    root   html;
}

# proxy the PHP scripts to Apache listening on 127.0.0.1:80
#
#location ~ \.php$ {
#    proxy_pass   http://127.0.0.1;
#}

location ~ \.php$ {
  try_files $uri /index.php =404;
  fastcgi_split_path_info ^(.+\.php)(/.+)$;
  fastcgi_pass 127.0.0.1:9000;
  fastcgi_index index.php;
  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
  include fastcgi_params;
}

}
```



**访问zabbix web 文件目录监听80端口**

### 安装php7

```bash
# add yum repository
yum -y install epel-release
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
# install php7
yum install -y php70w
yum install -y php70w-devel php70w-pdo php70w-mysqlnd php70w-fpm php70w-opcache php70w-cli php70w-gd php70w-mcrypt php70w-mbstring php70w-xml
# 更改php-fpm的启动用户与监听用户
   sed -i 's/^\(listen.owner =\).\+/\1 nobody/g' /etc/php-fpm.d/www.conf
   sed -i 's/^\(listen.group =\).\+/\1 nobody/g' /etc/php-fpm.d/www.conf
   sed -i 's/^\(user =\).\+/\1 nobody/g' /etc/php-fpm.d/www.conf
   sed -i 's/^\(group =\).\+/\1 nobody/g' /etc/php-fpm.d/www.conf
```

### 在浏览器中访问：http://Server-IP/zabbix 进行安装

> 如果遇到 `PHP time zone unknown Fail`错误，编辑`/etc/httpd/conf.d/zabbix.conf`,设置：

```
php_value date.timezone PRC
```

重启`openresty`即可。安装好后默认用户名密码：`Admin/zabbix`

### 配置选项及错误处理

#### 中文设置

zabbix 2.2 LTS默认是没有中文显示的，2.4版本后支持中文，设置中文方法： 用admin登录后，点击右上角的profile，将language选成Chinese（zh_CN）,点更新即可。 zabbix 2.2 版本要编译一下/usr/share/zabbix/include/locales.inc.php文件，设置成：

```
'zh_CN' => array('name' => _('Chinese (zh_CN)'), 'display' => true),
```

## grafana 安装使用

```shell
yum install https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.5.2-1.x86_64.rpm
yum install grafana
service grafana-server start
systemctl enable grafana-server.service
```

### 使用grafana-cli工具安装

- 获取可用插件列表

```
grafana-cli plugins list-remote
```

- 安装zabbix插件

```
grafana-cli plugins install alexanderzobnin-zabbix-app
```

- 安装插件完成之后重启garfana服务

```
service grafana-server restart
```

- 使用grafana-zabbix-app源，其中包含最新版本的插件

```
cd /var/lib/grafana/plugins/
```

- 克隆grafana-zabbix-app插件项目

```
git clone https://github.com/alexanderzobnin/grafana-zabbix-app
```

> 注：如果没有git，请先安装git

```
yum –y install git
```

- 插件安装完成重启garfana服务

```
service grafana-server restart
```

> 注：通过这种方式，可以很容器升级插件

```bash
cd /var/lib/grafana/plugins/grafana-zabbix-app
git pull
service grafana-server restart
```

官方网站：https://github.com/alexanderzobnin/grafana-zabbix

官网wiki：http://docs.grafana-zabbix.org/installation/

> 具体zabbix配置

[参考官网:](http://docs.grafana-zabbix.org/installation/configuration/) [配置图标参考网址:](http://www.linuxprobe.com/zabbix-with-grafana.html)



# zabbix 集成 LDAP

------



# zabbix 配置

![zabbix](Zabbix%E5%85%A8%E8%A7%A3.assets/2019-07-24-013445.jpg) ![zabbix ldap](Zabbix%E5%85%A8%E8%A7%A3.assets/2019-07-24-013515.jpg)

```shell
LDAP host：访问DC的地址。格式：ldap://ip地址
Port：默认389
Base DN: dc=tencent,dc=com,也就是域名(tencent.com)
Search attribute: uid，属性值，网上有填sAMAccountName。
Bind DN： cn=Admin, ou=People, dc=tencent, dc=com。 cn就是在DC中创建的LDAPuser用户， ou就是LDAPuser属于哪个ou，dc=tencent和dc=com不在解释。
Bind password：xxxx ，改密码为LDAPuser用户的密码
Login：Admin
User password：在DC中创建Admin用户的密码
>  这里的Login 是当前用户，如果是admin  需要在AD域控中增减用户名
点击"Test"。如果没有报什么错误，就可以点击"Save"。现在ZABBIX的LDAP认证方式就已经配置完成了。
```

> 虽然 zabbix 的ldap 认证成功了，但是不能自动创建用户，需要根据在zabbix 数据库中创建对应的用户

- 插入用户的SQL如下：

```
insert into users(userid,name,alias) values ('%s','%s','%s');" % (n,$name,$name)
```

- 需要用到组管理的话，可以组的映射信息

插入关联用户组的SQL：

```shell
"insert into users_groups (id,usrgrpid,userid) values ('%s','%s','%s');" % (n,grouplist[group_name],userlist[name])
users           用户表
users_groups    用户组的表
usrgrp          用户-组，映射关系表
```

- ldap查询命令，获取用户的用户名，和组名

> 先从ldap服务器把用户数据导入文件

```shell
ldapsearch -x -LLL   -D "CN=张三,OU=运维技术部,OU=信息技术中心,OU=神秘公司,DC=corp,DC=shenmi,DC=com,DC=cn"   -b "OU=运维技术部,OU=信息技术中心,OU=神秘公司,DC=corp,DC=shenmi,DC=com,DC=cn"   givenName  -H ldap://10.12.3.30:389 -w asdfasdfa sAMAccountName | egrep -v '^$|givenName'
```

## python导入ldap用户

环境python 2.6 脚本如下：

```python
 cat insert_sql.py

#!/usr/bin/env python
# -*- coding:utf-8 -*-

import pymysql
import commands
import re
import base64
import sys

# 避免中文乱码
reload(sys)
sys.setdefaultencoding('utf-8')

ldap_list='/usr/local/zabbix/sh/ldap.list'

# 先从ldap服务器把用户数据导入文件
ldap_users=commands.getoutput("ldapsearch -x -LLL -H ldap://1.1.1.1 -b dc=weimob,dc=com givenName|sed '1,12'd|sed '/^$/d'|egrep -v 'ou=Group|ou=machines'> %s" % ldap_list)

# 因为zabbix的表没有自增id，所以每次操作都会记录下id，并递增
idfile = '/usr/local/zabbix/sh/userid'

# 处理元数据，把文件里的每行数据转化成方便使用的格式
def get_item(fobj):
    item = ['', '', '']
    for no,line in enumerate(fobj):
        #print no,line
        slot = no % 2
        item[slot] = line.rstrip()
        if slot == 1:
            yield item

def insert_user():
    conn = pymysql.connect(host='2.2.2.2', port=3306, user='zabbix', passwd='zabbix', db='zabbix', charset='utf8')
    cur = conn.cursor()
    fs = open(idfile,'r')
    n = int(fs.read())
    fs.close()
    with open(ldap_list) as fobj:
        for item in get_item(fobj):
            n += 1
            try:
                s='{0}{1}{2}'.format(*item)
                l = re.search('cn=(.*),ou.*:: (.*)',s)
                name = base64.b64decode(l.group(2))
                alias = l.group(1)
                search = cur.execute("""select * from users where alias = %s""", (alias, ))
                if not search:
                    sql = "insert into users(userid,name,alias) values ('%s','%s','%s');" % (n,name,alias)
                    insert = cur.execute(sql)
                    if sql:
                        print "User %s Add Succed!" % alias
                        print sql
            except AttributeError as e:
                print e
    conn.commit() #这步很必要，不然插入的数据不生效
    cur.close()
    conn.close()
    fe = open(idfile,'w')
    fe.write(str(n))
    fe.close()

if __name__ == '__main__':
    insert_user(
```

# open-falcon 监控 nginx_status

------



# openfalcon 监控 nginx 状态

> 主要使用 通过 agent push 数据至 server

## 思路

由于我这边有两套nginx 需要计算综合

[![img](Zabbix%E5%85%A8%E8%A7%A3.assets/2019-07-08-095745.jpg)](http://img.liuwenqi.com/blog/2019-07-08-095745.jpg)

## nginx 相关配置

### 启用nginx status配置

在默认主机里面加上location或者你希望能访问到的主机里面。

```yml
server {
    listen  *:80 default_server;
    server_name _;
    location /ngx_status
    {
        stub_status on;
        access_log off;
        #allow 127.0.0.1;
        #deny all;
    }
}
```



### 打开status页面

```bash
curl http://127.0.0.1/ngx_status
Active connections: 11921
server accepts handled requests
 11989 11989 11991
Reading: 0 Writing: 7 Waiting: 42
```

### nginx status详解

- active connections – 活跃的连接数量
- server accepts handled requests — 总共处理了11989个连接 , 成功创建11989次握手, 总共处理了11991个请求
- reading — 读取客户端的连接数.
- writing — 响应数据到客户端的数量
- waiting — 开启 keep-alive 的情况下,这个值等于 active – (reading+writing), 意思就是 Nginx 已经处理完正在等候下一次请求指令的驻留连接.

## openfalcon 设置

### 通过shell 获取nginx 数据值

```bash
#!/bin/bash

nginx_17=${1}
nginx_18=${2}
nginx_status_name=${3}


nginx_active_connections(){
        active_connections_17=`curl -s http://${nginx_17}:18190/nginx_status | grep connections | awk '{print $3}'`
        active_connections_18=`curl -s http://${nginx_18}:18190/nginx_status | grep connections | awk '{print $3}'`
        let active_connections=($active_connections_17+$active_connections_18)
        echo $active_connections
}

nginx_reading(){
        reading_17=`curl -s http://${nginx_17}:18190/nginx_status | grep Reading | awk '{print $2}'`
        reading_18=`curl -s http://${nginx_18}:18190/nginx_status | grep Reading | awk '{print $2}'`
        let reading=($reading_17+$reading_18)
        echo $reading
}
nginx_writing(){
        writing_17=`curl -s http://${nginx_17}:18190/nginx_status | grep Reading | awk '{print $4}'`
        writing_18=`curl -s http://${nginx_18}:18190/nginx_status | grep Reading | awk '{print $4}'`
        let writing=($writing_17+$writing_18)
        echo $writing
}
nginx_waiting(){
        waiting_17=`curl -s http://${nginx_17}:18190/nginx_status | grep Reading | awk '{print $6}'`
        waiting_18=`curl -s http://${nginx_18}:18190/nginx_status | grep Reading | awk '{print $6}'`
        let waiting=($waiting_17+$waiting_18)
        echo $waiting
}



case "$nginx_status_name" in
nginx_active_connections)
nginx_active_connections
;;
nginx_reading)
nginx_reading
;;
nginx_writing)
nginx_writing
;;
nginx_waiting)
nginx_waiting
;;
*)
printf 'Usage: %s {nginx_active_connections|nginx_reading|nginx_writing|nginx_waiting}\n' "$prog"
exit 1
;;
esac
```

### 通过 python push至 agent http API 接口

**需要注意 运行python及shell 需要在同一台服务器**

**同时需要能访问nginx_status 端口权限**

```python
#!-*- coding:utf8 -*-
import os
import requests
import time
import json
import socket

## 环境变量
hostname = socket.gethostname()
nginx_17_ip = "IP"  ## nginx服务器IP
nginx_18_ip = "IP"

def nginx_active_connections(nginx17_ip,nginx_18_ip):
    os.environ['nginx_17_ip']=str(nginx_17_ip)
    os.environ['nginx_18_ip']=str(nginx_18_ip)
    connections_tmp =os.popen('/root/scripts/nginx_status.sh $nginx_17_ip $nginx_18_ip nginx_active_connections')
    connections = connections_tmp.read()
    #print(nginx_active_connections)
    return connections

def nginx_reading(nginx17_ip,nginx_18_ip):
    os.environ['nginx_17_ip']=str(nginx_17_ip)
    os.environ['nginx_18_ip']=str(nginx_18_ip)
    nginx_reading_tmp = os.popen('/root/scripts/nginx_status.sh $nginx_17_ip $nginx_18_ip nginx_reading')
    nginx_reading = nginx_reading_tmp.read()
    return nginx_reading

def nginx_writing(nginx17_ip,nginx_18_ip):
    os.environ['nginx_17_ip']=str(nginx_17_ip)
    os.environ['nginx_18_ip']=str(nginx_18_ip)
    nginx_writing_tmp = os.popen('/root/scripts/nginx_status.sh $nginx_17_ip $nginx_18_ip nginx_writing')
    nginx_writing = nginx_writing_tmp.read()
    return nginx_writing

def nginx_waiting(nginx17_ip,nginx_18_ip):
    os.environ['nginx_17_ip']=str(nginx_17_ip)
    os.environ['nginx_18_ip']=str(nginx_18_ip)
    nginx_waiting_tmp = os.popen('/root/scripts/nginx_status.sh $nginx_17_ip $nginx_18_ip nginx_waiting')
    nginx_waiting = nginx_waiting_tmp.read()
    return nginx_waiting

nginx_active_count = int(nginx_active_connections(nginx_17_ip,nginx_18_ip))
nginx_reading_count = int(nginx_reading(nginx_17_ip,nginx_18_ip))
nginx_writing_count = int(nginx_writing(nginx_17_ip,nginx_18_ip))
nginx_waiting_count = int(nginx_waiting(nginx_17_ip,nginx_18_ip))
nginx_waiting_count = int(nginx_waiting(nginx_17_ip,nginx_18_ip))

ts = int(time.time())
payload = [
    {
        "endpoint": hostname,
        "metric": "nginx.active.connections",
        "timestamp": ts,
        "step": 60,
        "value": nginx_active_count,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": hostname,
        "metric": "nginx.reading",
        "timestamp": ts,
        "step": 60,
        "value": nginx_reading_count,
        "counterType": "GAUGE",
        "tags": "",
    },
        {
        "endpoint": hostname,
        "metric": "nginx.writing",
        "timestamp": ts,
        "step": 60,
        "value": nginx_writing_count,
        "counterType": "GAUGE",
        "tags": "",
    },
        {
        "endpoint": hostname,
        "metric": "nginx.waiting",
        "timestamp": ts,
        "step": 60,
        "value": nginx_waiting_count,
        "counterType": "GAUGE",
        "tags": "",
    },
]

r = requests.post("http://127.0.0.1:1988/v1/push", data=json.dumps(payload))

print r.text
```

## openfalcon 效果展示

通过dashboard 查询相关数据

[![openfalcon_check](Zabbix%E5%85%A8%E8%A7%A3.assets/2019-07-08-095825.jpg)](http://img.liuwenqi.com/blog/2019-07-08-095825.jpg)

**Screen** [![openfalcon_nginx](Zabbix%E5%85%A8%E8%A7%A3.assets/2019-07-08-095901.jpg)](http://img.liuwenqi.com/blog/2019-07-08-095901.jpg) **Grafana** [![Grafana_nginx](Zabbix%E5%85%A8%E8%A7%A3.assets/2019-07-08-100149.jpg)](http://img.liuwenqi.com/blog/2019-07-08-100149.jpg)

# open-falcon 自定义监控一些应用

------



## openfalcon 通过python查询mysql数据上报

### 思路

主要是用python获取mysql数据，进行统计上报

[![img](Zabbix%E5%85%A8%E8%A7%A3.assets/2019-07-08-095706.jpg)](http://img.liuwenqi.com/blog/2019-07-08-095706.jpg)

### [#](http://www.liuwq.com/views/监控/openfalcon_mysql_select.html#python脚本)python脚本

> python 包 需要自行 通过 pip 安装

```python
#!-*- coding:utf8 -*-
## author:liuwenqi
## date: 2018-06-18
import requests
import time
import json
import pymysql
from decimal import *

db_config = {
    'host': 'IP', ## 数据库地址
    'port': 3306, ## 数据库端口
    'user': 'user', ## 数据库名称
    'password': 'password', ## 数据库地址
    'db': 'db_name', ## 数据库名
    'charset': 'utf8',
}

sql_get_order_10min_true='SQL'
sql_get_order_10min_false='SQL'
sql_get_order_yesterday_true='SQL'
sql_get_order_lastweek_true='SQL'
sql_get_order_yesterday_false='SQL'
sql_get_order_lastweek_false='SQL'
sql_get_order_one_min_true='SQL'

def sql_check(order_type):
    conn = pymysql.connect(**db_config)
    cur = conn.cursor()
    if order_type == 0:
        sql = sql_get_order_10min_true
    elif order_type == 1:
        sql = sql_get_order_10min_false
    elif order_type == 2:
    sql = sql_get_order_yesterday_true
    elif order_type == 3:
    sql = sql_get_order_yesterday_false
    elif order_type == 4:
    sql = sql_get_order_lastweek_true
    elif order_type == 5:
    sql = sql_get_order_one_min_true
    else:
    sql = sql_get_order_lastweek_false
    rv = cur.execute(sql)
    res = cur.fetchall()
    cur.close()
    return int(res[0][0])

def count_success_percent(success,fail):
    success_percent_data = Decimal(success)/(Decimal(success) + Decimal(fail))*100
    success_percent = round(success_percent_data,3)
    return success_percent

ts = int(time.time())
order_today_success = sql_check(0)
order_today_fail = sql_check(1)
order_yesterday_success= sql_check(2)
order_yesterday_fail = sql_check(3)
order_lastweek_success = sql_check(4)
order_lastweek_fail = sql_check(6)
order_min_true = sql_check(5)
today_success_percent = count_success_percent(order_today_success,order_today_fail)
yesterday_success_percent = count_success_percent(order_yesterday_success,order_yesterday_fail)


payload = [
    {
        "endpoint": "order_data",
        "metric": "今日订单成功数",
        "timestamp": ts,
        "step": 60,
        "value": order_today_success,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": "order_data",
        "metric": "昨日订单成功数",
        "timestamp": ts,
        "step": 60,
        "value": order_yesterday_success,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": "order_data",
        "metric": "上周订单成功数",
        "timestamp": ts,
        "step": 60,
        "value": order_lastweek_success,
        "counterType": "GAUGE",
        "tags": "",
    },


    {
        "endpoint": "order_data",
        "metric": "today_order_count_fail",
        "timestamp": ts,
        "step": 60,
        "value": order_today_fail,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": "order_data",
        "metric": "yesterday_order_count_fail",
        "timestamp": ts,
        "step": 60,
        "value": order_yesterday_fail,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": "order_data",
        "metric": "lastweek_order_count_fail",
        "timestamp": ts,
        "step": 60,
        "value": order_lastweek_fail,
        "counterType": "GAUGE",
        "tags": "",
    },

    {
        "endpoint": "order_data",
        "metric": "今日订单成功率",
        "timestamp": ts,
        "step": 60,
        "value": today_success_percent,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": "order_data",
        "metric": "昨日订单成功率",
        "timestamp": ts,
        "step": 60,
        "value": yesterday_success_percent,
        "counterType": "GAUGE",
        "tags": "",
    },

    {
        "endpoint": "order_data",
        "metric": "每分钟订单成功数",
        "timestamp": ts,
        "step": 60,
        "value": order_min_true,
        "counterType": "GAUGE",
        "tags": "",
    }

]

r = requests.post("http://127.0.0.1:1988/v1/push", data=json.dumps(payload))

print r.text
```



### [#](http://www.liuwq.com/views/监控/openfalcon_mysql_select.html#效果图)效果图

**openfalcon screen**

[![img](Zabbix%E5%85%A8%E8%A7%A3.assets/2019-07-08-100214.jpg)](http://img.liuwenqi.com/blog/2019-07-08-100214.jpg)

**Grafana**

[![img](Zabbix%E5%85%A8%E8%A7%A3.assets/2019-07-08-100250.jpg)](http://img.liuwenqi.com/blog/2019-07-08-100250.jpg)

# grafana ldap 集成域控登录

------



## grafana授权公司内部邮箱登录 ldap配置

### 修改配置

```shell
vim /etc/grafana/grafana.ini    （默认配置是这个）

修改ldap相关配置如下
[auth.ldap]
enabled = true   ## 开启LDAP认证
config_file = /etc/grafana/ldap.toml   ## 加载LDAP 配置文件    
allow_sign_up = true            ## 开启用户登录后，创建到内置用户
```

```yml
vim  /etc/grafana/ldap.toml
 ## 如下是 相关配置修改 ，请对应默认配置进行修改
verbose_logging = true       ## 这个默认配置里面没有请自行添加
[[servers]]
host = XXXX   //公司内部ldaphost
port = XXXX       //公司内部ldapport
use_ssl = false
ssl_skip_verify = false

bind_dn = "CN=XXXX,OU=XXXX,OU=XXXX,DC=XXXX,DC=com"   ## 这个需要咨询域控管理员，填写具体的账号密码
bind_password = XXXX
search_filter = "(sAMAccountName=%s)"
search_base_dns = ["OU=XXXX,OU=XXXX,DC=XXXX,DC=XXXX"]
[servers.attributes]
name = "givenName"
surname = "sn"
username = "sAMAccountName"
member_of = "memberOf"
email =  "mail"

[[servers.group_mappings]]
group_dn = "CN=XXXX,OU=User Group,OU=XXXX,DC=XXXX,DC=com"
org_role = "Admin"

[[servers.group_mappings]]
group_dn = "*"
org_role = "Viewer"
```

### 重启服务

```
sudo service grafana-server restart
```

# 检测mysql备份是否成功触发openfalcon 报警

------



## openfalcon 监控mysql备份报警

> 思路：mysql备份输出日志 检测 errr 等相关字段 判断成功与否，将1或者0 传入openfalcon

### python 检测脚本

> 执行python脚本的服务器 要有日志、已经安装并运行的openfalcon 客户端

```python
#!-*- coding:utf8 -*-
# author: liuwenqi 
# date: 2018-07-11
import os
import requests
import time
import json
import  socket

## 环境变量

log_dir ='/Users/kame/code/scripts/test_tmp'  ## 日志地址
scp_success='scp success!'  ## 判断成功与否字符串
scp_fail = 'scp failure!'
backup_success = 'innobackupex full backup complete !'
backup_fail = 'innobackupex full backup failure!'
hostname = socket.gethostname()   ## 获取 hostname


def scp_replace(log_dir):

    os.environ['log_dir']=str(log_dir)
    log_dir_os = os.popen("cat $log_dir | grep `date +%Y%m%d`")
    file_tmp = log_dir_os.read()
    ## 判断scp是否成功
    if scp_success in file_tmp:
        scp_staus = 0
    else :
        scp_staus = 1
    return scp_staus

def back_replace(log_dir):

    os.environ['log_dir']=str(log_dir)
    log_dir_os = os.popen("cat $log_dir | grep `date +%Y%m%d`")
    file_tmp = log_dir_os.read()
    ## 判断backup
    if backup_success in file_tmp:
        backup_staus = 0

        #print(backup_staus)
    else:
        backup_staus = 1
        #print(backup_staus)
    return backup_staus



open_env_scp_status = scp_replace(log_dir)
open_env_back_status = back_replace(log_dir)

print(open_env_scp_status)
print(open_env_back_status)

ts = int(time.time())
payload = [
    {
        "endpoint": hostname,
        "metric": "scp_status",
        "timestamp": ts,
        "step": 60,
        "value": open_env_scp_status,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": hostname,
        "metric": "backup_status",
        "timestamp": ts,
        "step": 60,
        "value": open_env_back_status,
        "counterType": "GAUGE",
        "tags": "",
    },


]

r = requests.post("http://127.0.0.1:1988/v1/push", data=json.dumps(payload))

print r.text
```

### openfalcon 报警设置

[![img](Zabbix%E5%85%A8%E8%A7%A3.assets/2019-07-08-100424.jpg)](http://img.liuwenqi.com/blog/2019-07-08-100424.jpg)

设置 报警触发 ，然后设置 hostGroups 绑定templates

# zabbix 监控 php-fpm

zabbix监控php-fpm主要是通过nginx配置php-fpm的状态输出页面，在正则取值.要nginx能输出php-fpm的状态首先要先修改php-fpm的配置，没有开启nginx是没有法输出php-fpm status。

第一个里程：修改文件php-fpm

vim /application/php-5.5.32/etc/php-fpm.conf文件

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1469203-20181021111145530-1093315619.png)

第二个里程：修改nginx配置文件

vim vim /application/nginx/conf/extra/www.conf，在server 区块下添加一行内容

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1469203-20181021111723825-434667199.png)

重启nginx

第三个里程：curl 127.0.0.1/php_status 我们可以看到php-fpm 的状态信息

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1469203-20181021111937582-1246959624.png)

| **字段**                 | **含义**                                                     |
| ------------------------ | ------------------------------------------------------------ |
| **pool**                 | **php-fpm pool的名称，大多数情况下为www**                    |
| **process manager**      | **进程管理方式，现今大多都为dynamic，不要使用static**        |
| **start time**           | **php-fpm上次启动的时间**                                    |
| **start since**          | **php-fpm已运行了多少秒**                                    |
| **accepted conn**        | **pool接收到的请求数**                                       |
| **listen queue**         | **处于等待状态中的连接数，如果不为0，需要增加php-fpm进程数** |
| **max listen queue**     | **php-fpm启动到现在处于等待连接的最大数量**                  |
| **listen queue len**     | **处于等待连接队列的套接字大小**                             |
| **idle processes**       | **处于空闲状态的进程数**                                     |
| **active processes**     | **处于活动状态的进程数**                                     |
| **total processess**     | **进程总数**                                                 |
| **max active process**   | **从php-fpm启动到现在最多有几个进程处于活动状态**            |
| **max children reached** | **当pm试图启动更多的children进程时，却达到了进程数的限制，达到一次记录一次，如果不为0，需要增加****php-fpm pool进程的最大数** |
| **slow requests**        | **当启用了php-fpm slow-log功能时，如果出现php-fpm慢请求这个计数器会增加，一般不当的Mysql查询会触发这个值** |

 第四个里程：编写监控脚本和监控文件

```shell
vim /server/scripts/php_fpm-status.sh

#!/bin/sh
#php-fpm status
case $1 in
ping) #检测php-fpm进程是否存在
/sbin/pidof php-fpm | wc -l
;;
start_since) #提取status中的start since数值
/usr/bin/curl 127.0.0.1/php_status 2>/dev/null | awk 'NR==4{print $3}'
;;
conn) #提取status中的accepted conn数值
/usr/bin/curl 127.0.0.1/php_status 2>/dev/null | awk 'NR==5{print $3}'
;;
listen_queue) #提取status中的listen queue数值
/usr/bin/curl 127.0.0.1/php_status 2>/dev/null | awk 'NR==6{print $3}'
;;
max_listen_queue) #提取status中的max listen queue数值
/usr/bin/curl 127.0.0.1/php_status 2>/dev/null | awk 'NR==7{print $4}'
;;
listen_queue_len) #提取status中的listen queue len
/usr/bin/curl 127.0.0.1/php_status 2>/dev/null | awk 'NR==8{print $4}'
;;
idle_processes) #提取status中的idle processes数值
/usr/bin/curl 127.0.0.1/php_status 2>/dev/null | awk 'NR==9{print $3}'
;;
active_processes) #提取status中的active processes数值
/usr/bin/curl 127.0.0.1/php_status 2>/dev/null | awk 'NR==10{print $3}'
;;
total_processes) #提取status中的total processess数值
/usr/bin/curl 127.0.0.1/php_status 2>/dev/null | awk 'NR==11{print $3}'
;;
max_active_processes) #提取status中的max active processes数值
/usr/bin/curl 127.0.0.1/php_status 2>/dev/null | awk 'NR==12{print $4}'
;;
max_children_reached) #提取status中的max children reached数值
/usr/bin/curl 127.0.0.1/php_status 2>/dev/null | awk 'NR==13{print $4}'
;;
slow_requests) #提取status中的slow requests数值
/usr/bin/curl 127.0.0.1/php_status 2>/dev/null | awk 'NR==14{print $3}'
;;
*)
echo "Usage: $0 {conn|listen_queue|max_listen_queue|listen_queue_len|idle_processes|active_processess|total_processes|max_active_processes|max_children_reached|slow_requests}"
exit 1
;;
esac

vim /etc/zabbix/zabbix_agentd.d/test.conf

UserParameter=php_status[*],/bin/sh /server/scripts/php_fpm-status.sh $1
```

第六个里程：重启服务

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1469203-20181021115709644-600951436.png)

 在服务端测试

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1469203-20181021120116630-1188327031.png)

第七个里程：在web端进行配置

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1469203-20181021120934677-1355519728.png)

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1469203-20181021121048666-960995697.png)

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1469203-20181021121417385-1782676060.png)

 ![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1469203-20181021140310477-1768203390.png)

这时候我们再来看最新监控数据，就可以看到我们监控的内容了![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1469203-20181021143537786-1115883382.png)

 

配置到这，我们PHP状态监控基本完成，根据需求配置相应的触发器，即可。

你要的模板

链接：https://pan.baidu.com/s/1bnoYn1gD7xdQTEUzFj44eA 
提取码：47sv



# Centos7 Zabbix3.4 微信告警配置

## 一、申请企业微信

1、填写注册信息

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616131755799.png)

## 二、配置微信企业号

1、创建告警组，然后把接受消息人加进来

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616132217589.png)

2、记录账号名称，等下填写接收人信息需要用到

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180805151546815.png)

3、点击我的企业，查看企业信息，要记录企业CorpID

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616132724160.png)

4、点击企业应用，创建应用

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616132943249.png)

5、填写信息和通知用户组

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/2018061613311477.png)

6、创建完，记录Agentld和Secret

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/2018061613331047.png)

## 三、配置zabbix服务器

1、首先确认已经记录的信息

告警组用户的账号，企业CorpID和创建应用的Secret、Agentld

2、修改zabbix.conf

```html
[root@localhost ~]# grep alertscripts /etc/zabbix/zabbix_server.conf 
# AlertScriptsPath=${datadir}/zabbix/alertscripts
AlertScriptsPath=/usr/lib/zabbix/alertscripts
我们设置zabbix默认脚本路径，这样在web端就可以获取到脚本
```

3、下载并设置脚本

```html
[root@localhost ~]# cd /usr/lib/zabbix/alertscripts/
[root@localhost alertscripts]# wget https://raw.githubusercontent.com/OneOaaS/weixin-alert/master/weixin_linux_amd64
[root@localhost alertscripts]# mv weixin_linux_amd64 wechat
[root@localhost alertscripts]# chmod 755 wechat 
[root@localhost alertscripts]# chown zabbix:zabbix wechat 
```

4、执行脚本进行测试

```html
[root@localhost alertscripts]# ./wechat --corpid=xxx --corpsecret=xxx --msg="您好，告警测试" --user=用户账号 --agentid=xxx
{"errcode":0,"errmsg":"ok","invaliduser":""}
```

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616134501823.png)

提示：

--corpid= 我们企业里面的id
--corpsecret= 这里就是我们Secret里面的id
-msg= 内容
-user=我们邀请用户的账号

因为脚本是编译过的，无法进行编辑，我们可以使用 ./wechat -h or --help 查看

## 四、zabbix web页面配置告警信息

1、管理-报警媒介类型-创建告警媒介

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616135048574.png)

2、填写报警媒介信息

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616135352989.png)

--corpid=我们企业里面的id
--corpsecret=这里就是我们Secret里面的id
--agentid= Agentld ID
--user={ALERT.SENDTO}
--msg={ALERT.MESSAGE}

3、设置告警用户

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616135636811.png)

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616140000905.png)

4、设置告警动作

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616140122839.png)

1）动作信息

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616140240794.png)

2）填写告警时候操作信息

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616141444154.png)

故障告警:{TRIGGER.STATUS}: {TRIGGER.NAME} 
告警主机:{HOST.NAME} 
主机地址:{HOST.IP} 
告警时间:{EVENT.DATE} {EVENT.TIME} 
告警等级:{TRIGGER.SEVERITY} 
告警信息:{TRIGGER.NAME} 
问题详情:{ITEM.NAME}:{ITEM.VALUE} 
事件代码:{EVENT.ID} 

3）填写恢复操作信息

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/20180616141452375.png)

故障解除:{TRIGGER.STATUS}: {TRIGGER.NAME} 
恢复主机:{HOST.NAME} 
主机地址:{HOST.IP} 
恢复时间:{EVENT.DATE} {EVENT.TIME} 
恢复等级:{TRIGGER.SEVERITY} 
恢复信息:{TRIGGER.NAME} 
问题详情:{ITEM.NAME}:{ITEM.VALUE} 
事件代码:{EVENT.ID}

## 五、手动触发告警，测试微信接收信息

我们在agent端使用yum安装一下`redis`：

```
[root@node1 ~]# yum install redis -y
```

　　修改一下配置文件：

```
[root@node1 ~]# vim /etc/redis.conf 
bind 0.0.0.0        #不做任何认证操作
```

　　修改完成以后，我们启动服务，并检查端口：

```
[root@node1 ~]# systemctl start redis
[root@node1 ~]# ss -nutlp | grep redis
tcp    LISTEN     0      128       *:6379                  *:*                   users:(("redis-server",pid=5250,fd=4))
```

　　接着，我们就可以去网站上来定义相关的操作了：

### 1.定义监控项

　　进入 配置 ---> 主机 ---> node1 ---> 监控项（items）---> 创建监控项
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113104229-190921891-1575549934704.png)
　　填写完毕以后，我们点击下方的添加。
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113113058-1658955278-1575549934704.png)
　　该监控项已成功添加。
　　我们可以去查看一下他的值：
　　检测中 ---> 最新数据
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113122433-2129349774-1575549934704.png)

### 2.定义触发器

　　定义好了监控项以后，我们亦可来定义一个触发器，当服务有问题的时候，我们才能及时知道：
　　进入 配置 ---> 主机 ---> node1 ---> 触发器（trigger）---> 创建触发器
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113131761-6927531-1575549934704.png)
　　填写完毕以后，我们点击下方的添加。
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113142604-1237551286-1575549934705.png)
　　该触发器已成功添加。
　　我们去查看一下：
　　监测中 ---> 最新数据
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113150479-1838545643-1575549934705.png)
　　我们来手动关闭redis服务来检测一下：

```
[root@node1 ~]# systemctl stop redis.service
```

　　进入 监测中 ---> 问题
![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113158901-587145295-1575549934705.png)
　　可以看到，现在已经显示的是问题了。并且有持续的时间，当我们的服务被打开，会转为已解决状态：

```
[root@node1 ~]# systemctl start redis.service 
```

![img](Zabbix%E5%85%A8%E8%A7%A3.assets/1204916-20171202113209698-2146797322-1575549934705.png)

![无标题](Zabbix%E5%85%A8%E8%A7%A3.assets/%E6%97%A0%E6%A0%87%E9%A2%98-1555110317243.png)







