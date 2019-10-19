# ZooKeeper集群

------



## [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#一、前言)一、前言

### [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#_1、zookeeper简介)1、ZooKeeper简介

ZooKeeper是一个开源的分布式应用程序协调服务，是Google的Chubby一个开源的实现。ZooKeeper为分布式应用提供一致性服务，提供的功能包括：分布式同步（Distributed Synchronization）、命名服务（Naming Service）、集群维护（Group Maintenance）、分布式锁（Distributed Lock）等，简化分布式应用协调及其管理的难度，提供高性能的分布式服务。

ZooKeeper本身可以以单机模式安装运行，不过它的长处在于通过分布式ZooKeeper集群（一个Leader，多个Follower），基于一定的策略来保证ZooKeeper集群的稳定性和可用性，从而实现分布式应用的可靠性。

### [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#_2、zookeeper集群角色说明)2、ZooKeeper集群角色说明

ZooKeeper主要有领导者（Leader）、跟随者（Follower）和观察者（Observer）三种角色。

| 角色               | 说明                                                         |
| ------------------ | ------------------------------------------------------------ |
| 领导者（Leader）   | 为客户端提供读和写的服务，负责投票的发起和决议，更新系统状态。 |
| 跟随者（Follower） | 为客户端提供读服务，如果是写服务则转发给Leader。在选举过程中参与投票。 |
| 观察者（Observer） | 为客户端提供读服务器，如果是写服务则转发给Leader。不参与选举过程中的投票，也不参与“过半写成功”策略。在不影响写性能的情况下提升集群的读性能。此角色于zookeeper3.3系列新增的角色。 |

## [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#二、准备工作)二、准备工作

### [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#_1、集群节点规划)1、集群节点规划

ZooKeeper在提供分布式锁等服务的时候需要过半数的节点可用。另外高可用的诉求来说节点的个数必须>1，所以ZooKeeper集群需要是>1的奇数节点。例如3、5、7等等。 本次我们规划三个节点，操作系统选用Centos7

| 节点名         | IP             | 说明          |
| -------------- | -------------- | ------------- |
| zk01 （elk-1） | 172.16.249.101 | ZooKeeper节点 |
| zk02 （elk-2） | 172.16.249.102 | ZooKeeper节点 |
| zk03 （elk-3） | 172.16.249.103 | ZooKeeper节点 |

### [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#_2、软件版本说明)2、软件版本说明

| 项           | 说明      |
| ------------ | --------- |
| Linux Server | CentOS 7  |
| JDK（java）  | 1.8.0_161 |
| ZooKeeper    | 3.4.11    |

### [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#_3、部署jdk8)3、部署JDK8

所有节点均需要安装JDK8 参考CentOS下部署Java7/Java8： https://ken.io/note/centos-java-setup

## [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#三、部署zookeeper)三、部署ZooKeeper

**本次一共要部署三个ZooKeeper节点，所有文中没有指定机器的操作都表示每个节点都要执行该操作**

### [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#_1、下载zookeeper-基础准备)1、下载ZooKeeper&基础准备

- 下载ZooKeeper

官方镜像选择：https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/

```bash
cd /opt/
wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
```

- 创建ZooKeeper相关目录

```bash
#创建应用目录
mkdir /usr/zookeeper

#创建数据目录
mkdir /zookeeper
mkdir /zookeeper/data
mkdir /zookeeper/logs
```

- 解压到指定目录

```bash
tar -zvxf zookeeper-3.4.14.tar.gz -C /usr/zookeeper
```

- 配置环境变量

```bash
#修改环境变量文件
vim /etc/profile

#最后增加以下内容
export ZOOKEEPER_HOME=/usr/zookeeper/zookeeper-3.4.14
export PATH=$ZOOKEEPER_HOME/bin:$PATH

#使环境变量生效
source /etc/profile

#查看配置结果
echo $ZOOKEEPER_HOME
```

既然已配置环境变量，为了方便访问ZooKeeper目录 后续通过$ZOOKEEPER_HOME代替/usr/zookeeper/zookeeper-3.4.11

### [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#_2、配置zookeeper)2、配置ZooKeeper

- ZooKeeper基础配置

```shell
#进入ZooKeeper配置目录
cd $ZOOKEEPER_HOME/conf
cp zoo_sample.cfg zoo.cfg
#新建配置文件
vim zoo.cfg

#清空原有配置文件
echo '' > zoo.cfg
#写入以下内容并保存

tickTime=2000
initLimit=10
syncLimit=5
dataDir=/zookeeper/data
dataLogDir=/zookeeper/logs
clientPort=2181
server.1=elk-1:2888:3888
server.2=elk-2:2888:3888
server.3=elk-3:2888:3888
```

- 配置节点标识

zk01：

```bash
echo "1" > /zookeeper/data/myid
```

zk02：

```bash
echo "2" > /zookeeper/data/myid
```

zk03：

```bash
echo "3" > /zookeeper/data/myid
```

### [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#_3、启动zookeeper)3、启动ZooKeeper

```bash
#进入ZooKeeper bin目录
cd $ZOOKEEPER_HOME/bin

#启动
sh zkServer.sh start
```

出现以下字样表示启动成功：

> ZooKeeper JMX enabled by default Using config: /usr/zookeeper/zookeeper-3.4.11/bin/../conf/zoo.cfg Starting zookeeper … STARTED

## [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#四、集群查看-连接测试)四、集群查看&连接测试

### [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#_1、查看节点状态)1、查看节点状态

```bash
sh $ZOOKEEPER_HOME/bin/zkServer.sh status

#状态信息
ZooKeeper JMX enabled by default
Using config: /usr/zookeeper/zookeeper-3.4.11/bin/../conf/zoo.cfg
Mode: follower

#如果为领导者节点则Mode:leader
```

### [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#_2、客户端连接测试)2、客户端连接测试

这里随机选其中一个节点作为客户端连接其他节点即可

```bash
#指定Server进行连接
sh $ZOOKEEPER_HOME/bin/zkCli.sh -server elk-3:2181

#正常连接后会进入ZooKeeper命令行，显示如下：
[zk: elk-3:2181(CONNECTED) 0]
```

输入命令测试：

```bash
#查看ZooKeeper根
[zk: elk-3:2181(CONNECTED) 1] ls /
[zookeeper]
```

## [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#五、备注)五、备注

### [#](http://www.liuwq.com/views/网站架构/消息队列/zookeeper集群部署.html#_1、zookeeper常用配置项说明)1、ZooKeeper常用配置项说明

| 配置项     | 名称             | ken.io 的说明                                                |
| ---------- | ---------------- | ------------------------------------------------------------ |
| tickTime   | CS通信心跳间隔   | 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每间隔 tickTime 时间就会发送一个心跳。tickTime以毫秒为单位。 |
| initLimit  | LF初始通信时限   | 集群中的follower服务器(F)与leader服务器(L)之间初始连接时能容忍的最多心跳数 |
| syncLimit  | LF同步通信时限   | 集群中的follower服务器与leader服务器之间请求和应答之间能容忍的最多心跳数 |
| dataDir    | 数据文件目录     | Zookeeper保存数据的目录，默认情况下，Zookeeper将写数据的日志文件也保存在这个目录里 |
| dataLogDir | 日志文件目录     | Zookeeper保存日志文件的目录                                  |
| clientPort | 客户端连接端口   | 客户端连接 Zookeeper 服务器的端口，Zookeeper 会监听这个端口，接受客户端的访问请求 |
| server.N   | 服务器名称与地址 | 从N开始依次为：服务编号、服务地址、LF通信端口、选举端口；例如：server.1=192.168.88.11:2888:3888 |