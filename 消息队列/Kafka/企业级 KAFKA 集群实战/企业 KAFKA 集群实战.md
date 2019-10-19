# 企业 KAFKA 集群实战

## **一、Kafka  使用背景**

在我们大量使用分布式数据库、分布式计算集群的时候，是否会遇到这样的一些问题：

1. 我们想分析下用户行为（pageviews），以便我们设计出更好的广告位
2. 我想对用户的搜索关键词进行统计，分析出当前的流行趋势
3. 有些数据，存储数据库浪费，直接存储硬盘效率又低 

这些场景都有一个共同点：

数据是由上游模块产生，下游模块，使用上游模块的数据计算、统计、分析，这个时候就可以使用消息系统，尤其是分布式消息系统！

## **二、Kafka 的定义**

What is Kafka：它是一个分布式消息系统，由linkedin使用scala编写，用作LinkedIn的活动流（Activity Stream）和运营数据处理管道（Pipeline）的基础。具有高水平扩展和高吞吐量。

## **三、Kafka 和其他主流分布式消息系统的对比** 

![img](assets/831021-20160222115519338-1279419718.png)

定义解释：

1、Java 和 scala 都是运行在JVM上的语言。

2、erlang和最近比较火的和go语言一样是从代码级别就支持高并发的一种语言，所以RabbitMQ天生就有很高的并发性能，但是 有RabbitMQ严格按照AMQP进行实现，受到了很多限制。kafka的设计目标是高吞吐量，所以kafka自己设计了一套高性能但是不通用的协议，他也是仿照AMQP（ Advanced Message Queuing Protocol   高级消息队列协议）设计的。 

3、事务的概念：在数据库中，多个操作一起提交，要么操作全部成功，要么全部失败。举个例子， 在转账的时候付款和收款，就是一个事物的例子，你给一个人转账，你转成功，并且对方正常行收到款项后，这个操作才算成功，有一方失败，那么这个操作就是失败的。 

对应消在息队列中，就是多条消息一起发送，要么全部成功，要么全部失败。3个中只有ActiveMQ支持，这个是因为，RabbitMQ和Kafka为了更高的性能，而放弃了对事务的支持 。

4、集群：多台服务器组成的整体叫做集群，这个整体对生产者和消费者来说，是透明的。其实对消费系统组成的集群添加一台服务器减少一台服务器对生产者和消费者都是无感之的。

5、负载均衡，对消息系统来说负载均衡是大量的生产者和消费者向消息系统发出请求消息，系统必须均衡这些请求使得每一台服务器的请求达到平衡，而不是大量的请求，落到某一台或几台，使得这几台服务器高负荷或超负荷工作，严重情况下会停止服务或宕机。

6、动态扩容是很多公司要求的技术之一，不支持动态扩容就意味着停止服务，这对很多公司来说是不可以接受的。 

注：

阿里巴巴的Metal,RocketMQ都有Kafka的影子，他们要么改造了Kafka或者借鉴了Kafka，最后Kafka的动态扩容是通过Zookeeper来实现的。 

## 四、Kafka相关概念

### **1、 AMQP协议**

Advanced Message Queuing Protocol （高级消息队列协议）

**The Advanced Message Queuing Protocol (AMQP)：**是一个标准开放的应用层的消息中间件（Message Oriented Middleware）协议。AMQP定义了通过网络发送的字节流的数据格式。因此兼容性非常好，任何实现AMQP协议的程序都可以和与AMQP协议兼容的其他程序交互，可以很容易做到跨语言，跨平台。

上面说的3种比较流行的消息队列协议，要么支持AMQP协议，要么借鉴了AMQP协议的思想进行了开发、实现、设计。

### **2、 基本的概念**

Kafka客户端支持当前大部分主流语言，包括：C、C++、Erlang、Java、.net、perl、PHP、Python、Ruby、Go、Javascript

可以使用以上任何一种语言和kafka服务器进行通信（即辨析自己的consumer从kafka集群订阅消息也可以自己写producer程序） 

| **名词**      | **解释**                                                     |
| ------------- | ------------------------------------------------------------ |
| Producer      | 消息的生成者                                                 |
| Consumer      | 消息的消费者                                                 |
| ConsumerGroup | 消费者组，可以并行消费Topic中的partition的消息               |
| Broker        | 缓存代理，Kafka集群中的一台或多台服务器统称broker.           |
| Topic         | Kafka处理资源的消息源(feeds of messages)的不同分类 （消息主题） |
| Partition     | Topic物理上的分组，一个topic可以分为多个partion,每个partion是一个有序的队列。partion中每条消息都会被分配一个有序的Id(offset) |
| Message       | 消息，是通信的基本单位，每个producer可以向一个topic（主题）发布一些消息 |
| Producers     | 消息和数据生成者，向Kafka的一个topic发布消息的 过程叫做producers |
| Consumers     | 消息和数据的消费者，订阅topic并处理其发布的消费过程叫做consumers |

- ###   1 Producers的概念

1.  消息和数据生成者，向Kafka的一个topic发布消息的过程叫做producers  
2.  Producer将消息发布到指定的Topic中，同时Producer也能决定将此消息归属于哪个partition；比如基于round-robin方式 或者通过其他的一些算法等；
3. 异步发送，批量发送可以很有效的提高发送效率。kafka producer的异步发送模式允许进行批量发送，先将消息缓存到内存中，然后一次请求批量发送出去。

- ###    2  broker的概念:

1.  Broker 没有副本机制，一旦broker宕机，该broker的消息将都不可用。
2.  Broker不保存订阅者的状态，由订阅者自己保存。
3.  无状态导致消息的删除成为难题（可能删除的消息正在被订阅），Kafka采用基于时间的SLA（服务保证），消息保存一定时间（通常7天）后会删除。
4.  消费订阅者可以rewind back到任意位置重新进行消费，当订阅者故障时，可以选择最小的offset(id)进行重新读取消费消息

- ###    3 Message组成

1.  Message消息：是通信的基本单位，每个producer可以向一个topic发布消息。
2.  Kafka中的Message是以topic为基本单位组织的，不同的topic之间是相互独立的，每个topic又可以分成不同的partition，每个partition储存一部分
3.  partion中的每条Message包含以下三个属性：

| offset（id） | long                |
| ------------ | ------------------- |
| MessageSize  | int32               |
| data         | messages 的具体内容 |

- ###   4  Consumers 的概念

 消息和数据消费者，订阅topic并处理其发布的消息的过程叫做 consumers.

在kafka中，我们可以认为一个group是一个“订阅者”，一个topic中的每个partions只会被一个“订阅者”中的一个consumer消费，不过一个consumer可以消费多个partitions中的消息

**注:**

Kafka的设计原理决定，对于一个topic，同一个group不能多于partition个数的consumer同时消费，否则将意味着某些 consumer无法得到消息

### 3、Kafka架构

生产者生产消息、kafka集群、消费者获取消息这样一种架构，如下图：

![img](assets/831021-20160222125238526-112967735.png)

kafka集群中的消息，是通过Topic（主题）来进行组织的，如下图：

![img](assets/831021-20160222125343135-190706359.png)

基本的概念：

1、主题（Topic）：一个主题类似新闻中的体育、娱乐、教育等分类概念，在实际工程中通常一个业务一个主题。

2、分区（Partition）：一个Topic中的消息数据按照多个分区组织，分区是kafka消息队列组织的最小单位，一个分区可以看作是一个FIFO（ First Input First Output的缩写，先入先出队列）的队列。

kafka分区是提高kafka性能的关键所在，当你发现你的集群性能不高时，常用手段就是增加Topic的分区，分区里面的消息是按照从新到老的顺序进行组织，消费者从队列头订阅消息，生产者从队列尾添加消息。

3、 消息队列服务器（Broker）：简单来说就是消息队列服务器实体

工作图：

![img](assets/831021-20160222125912869-944637205.png)

 

备份（Replication）：为了保证分布式可靠性，kafka 0.8开始对每个分区的数据进行备份（不同的Broker上），防止其中一个Broker宕机造成分区上的数据不可用。

kafka 0.7是一个很大的改变：

1、增加了备份

2、增加了控制节点概念，增加了集群领导者选举 。

## 五、Zookeeper 集群搭建

![u=1246701101,363549057&fm=214&gp=0](assets/1484044507543563.jpg)

### 1、简介

ZooKeeper是一个分布式的，开放源码的分布式应用程序协调服务，它包含一个简单的原语集，分布式应用程序可以基于它实现同步服务，配置维护和命名服务等。Zookeeper是hadoop的一个子项目，其发展历程无需赘述。在分布式应用中，由于工程师不能很好地使用锁机制，以及基于消息的协调机制不适合在某些应用中使用，因此需要有一种可靠的、可扩展的、分布式的、可配置的协调机制来统一系统的状态。Zookeeper的目的就在于此，Zookeeper是一种在分布式系统中被广泛用来作为：分布式状态管理、分布式协调管理、分布式配置管理、和分布式锁服务管理的集群。kafka增加和减少服务器都会在Zookeeper节点上触发相应的事件，kafka系统会捕获这些事件，进行新一轮的负载均衡，客户端也会捕获这些事件来进行新一轮的处理。

Kafka集群是把状态保存在Zookeeper中的，首先要搭建Zookeeper集群。

### **2、软件环境**

（3台服务器-测试）

192.168.11.139 server1

192.168.11.140 server2

192.168.11.141 server3

1、Linux服务器一台、三台、五台、（2*n+1），Zookeeper集群的工作是超过半数才能对外提供服务，3台中超过两台，超过半数，允许1台挂掉 ，是否可以用偶数，其实没必要。

如果有四台那么挂掉一台还剩下三台服务器，如果在挂掉一个就不行了，这里记住是超过半数。

2、Java jdk1.8 zookeeper是用java写的所以他的需要JAVA环境，java是运行在java虚拟机上的

3、Zookeeper的稳定版本Zookeeper 3.4.14版本 

4、 同步hosts 文件

### **3、配置&安装Zookeeper**

下面的操作是：3台服务器统一操作

#### 1、安装Java

```
yum list java*
yum -y install java
```

#### 2、下载Zookeeper

首先要注意在生产环境中目录结构要定义好，防止在项目过多的时候找不到所需的项目

```
#目录统一放在/opt下面
#首先创建Zookeeper项目目录
mkdir zookeeper #项目目录
mkdir zookeeper/zkdata #存放快照日志
mkdir zookeeper/zkdatalog#存放事物日志
```

下载 Zookeeper

```
#下载软件
cd /opt/zookeeper/
wget http://mirrors.cnnic.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz

#解压软件
tar -zxvf zookeeper-3.4.14.tar.gz
```

#### **3、修改配置文件**

进入到解压好的目录里面的conf目录中，查看

```
#进入conf目录
/opt/zookeeper/zookeeper-3.4.14/conf
#查看
[root@kafka1 conf]# ll
total 12
-rw-rw-r-- 1 2002 2002  535 Mar  7 00:50 configuration.xsl
-rw-rw-r-- 1 2002 2002 2161 Mar  7 00:50 log4j.properties
-rw-rw-r-- 1 2002 2002  922 Mar  7 00:50 zoo_sample.cfg
```

\#zoo_sample.cfg  这个文件是官方给我们的zookeeper的样板文件，给他复制一份命名为zoo.cfg，zoo.cfg是官方指定的文件命名规则。

**3台服务器的配置文件**

```
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/opt/zookeeper/zkdata
dataLogDir=/opt/zookeeper/zkdatalog
clientPort=12181
server.1=192.168.11.139:12888:13888
server.2=192.168.11.140:12888:13888
server.3=192.168.11.141:12888:13888
#server.1 这个1是服务器的标识也可以是其他的数字， 表示这个是第几号服务器，用来标识服务器，这个标识要写到快照目录下面myid文件里
#192.168.11.139为集群里的IP地址，第一个端口是master和slave之间的通信端口，默认是2888，第二个端口是leader选举的端口，集群刚启动的时候选举或者leader挂掉之后进行新的选举的端口默认是3888
```

**配置文件解释：**

```
#tickTime：
这个时间是作为 Zookeeper 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个 tickTime 时间就会发送一个心跳。
#initLimit：
这个配置项是用来配置 Zookeeper 接受客户端（这里所说的客户端不是用户连接 Zookeeper 服务器的客户端，而是 Zookeeper 服务器集群中连接到 Leader 的 Follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。当已经超过 5个心跳的时间（也就是 tickTime）长度后 Zookeeper 服务器还没有收到客户端的返回信息，那么表明这个客户端连接失败。总的时间长度就是 5*2000=10 秒
#syncLimit：
这个配置项标识 Leader 与Follower 之间发送消息，请求和应答时间长度，最长不能超过多少个 tickTime 的时间长度，总的时间长度就是5*2000=10秒
#dataDir：
快照日志的存储路径
#dataLogDir：
事物日志的存储路径，如果不配置这个那么事物日志会默认存储到dataDir制定的目录，这样会严重影响zk的性能，当zk吞吐量较大的时候，产生的事物日志、快照日志太多
#clientPort：
这个端口就是客户端连接 Zookeeper 服务器的端口，Zookeeper 会监听这个端口，接受客户端的访问请求。修改他的端口改大点
```

创建myid文件

```
#server1
echo "1" > /opt/zookeeper/zkdata/myid
#server2
echo "2" > /opt/zookeeper/zkdata/myid
#server3
echo "3" > /opt/zookeeper/zkdata/myid
```

####  **4、重要配置说明**

1、myid文件和server.myid  在快照目录下存放的标识本台服务器的文件，他是整个zk集群用来发现彼此的一个重要标识。

2、zoo.cfg 文件是zookeeper配置文件 在conf目录里。

3、log4j.properties文件是zk的日志输出文件 在conf目录里用java写的程序基本上有个共同点日志都用log4j，来进行管理。

```
# Define some default values that can be overridden by system properties
zookeeper.root.logger=INFO, CONSOLE  #日志级别
zookeeper.console.threshold=INFO  #使用下面的console来打印日志
zookeeper.log.dir=.    #日志打印到那里，是咱们启动zookeeper的目录 （建议设置统一的日志目录路径）
zookeeper.log.file=zookeeper.log
zookeeper.log.threshold=DEBUG
zookeeper.tracelog.dir=.
zookeeper.tracelog.file=zookeeper_trace.log

#
# ZooKeeper Logging Configuration
#

# Format is "<default threshold> (, <appender>)+

# DEFAULT: console appender only
log4j.rootLogger=${zookeeper.root.logger}

# Example with rolling log file
#log4j.rootLogger=DEBUG, CONSOLE, ROLLINGFILE

# Example with rolling log file and tracing
#log4j.rootLogger=TRACE, CONSOLE, ROLLINGFILE, TRACEFILE

#
# Log INFO level and above messages to the console
#
log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
log4j.appender.CONSOLE.Threshold=${zookeeper.console.threshold}
log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout
log4j.appender.CONSOLE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L] - %m%n


# Add ROLLINGFILE to rootLogger to get log file output
#    Log DEBUG level and above messages to a log file
log4j.appender.ROLLINGFILE=org.apache.log4j.RollingFileAppender
log4j.appender.ROLLINGFILE.Threshold=${zookeeper.log.threshold}
log4j.appender.ROLLINGFILE.File=${zookeeper.log.dir}/${zookeeper.log.file}

# Max log file size of 10MB
log4j.appender.ROLLINGFILE.MaxFileSize=10MB
# uncomment the next line to limit number of backup files
#log4j.appender.ROLLINGFILE.MaxBackupIndex=10

log4j.appender.ROLLINGFILE.layout=org.apache.log4j.PatternLayout
log4j.appender.ROLLINGFILE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L] - %m%n


#
# Add TRACEFILE to rootLogger to get log file output
#    Log DEBUG level and above messages to a log file
log4j.appender.TRACEFILE=org.apache.log4j.FileAppender
log4j.appender.TRACEFILE.Threshold=TRACE
log4j.appender.TRACEFILE.File=${zookeeper.tracelog.dir}/${zookeeper.tracelog.file}

log4j.appender.TRACEFILE.layout=org.apache.log4j.PatternLayout
### Notice we are including log4j's NDC here (%x)
log4j.appender.TRACEFILE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L][%x] - %m%n
```

4、zkEnv.sh和zkServer.sh文件

zkServer.sh  主的管理程序文件

zkEnv.sh   是主要配置，zookeeper集群启动时配置环境变量的文件

5、还有一个需要注意

ZooKeeper server **will not remove old snapshots and log files** when using the default configuration (see autopurge below), this is the responsibility of the operator

zookeeper不会主动的清除旧的快照和日志文件，这个是操作者的责任。

但是可以通过命令去定期的清理。

```
#!/bin/bash 
 
#snapshot file dir 
dataDir=/opt/zookeeper/zkdata/version-2
#tran log dir 
dataLogDir=/opt/zookeeper/zkdatalog/version-2

#Leave 66 files 
count=66 
count=$[$count+1] 
ls -t $dataLogDir/log.* | tail -n +$count | xargs rm -f 
ls -t $dataDir/snapshot.* | tail -n +$count | xargs rm -f 

#以上这个脚本定义了删除对应两个目录中的文件，保留最新的66个文件，可以将他写到crontab中，设置为每天凌晨2点执行一次就可以了。

#zk log dir   del the zookeeper log
#logDir=
#ls -t $logDir/zookeeper.log.* | tail -n +$count | xargs rm -f
```

其他方法：

第二种：使用ZK的工具类PurgeTxnLog，它的实现了一种简单的历史文件清理策略，可以在这里看一下他的使用方法 http://zookeeper.apache.org/doc/r3.4.6/zookeeperAdmin.html 

第三种：对于上面这个执行，ZK自己已经写好了脚本，在bin/zkCleanup.sh中，所以直接使用这个脚本也是可以执行清理工作的。

第四种：从3.4.0开始，zookeeper提供了自动清理snapshot和事务日志的功能，通过配置 autopurge.snapRetainCount 和 autopurge.purgeInterval 这两个参数能够实现定时清理了。这两个参数都是在zoo.cfg中配置的：

**autopurge.purgeInterval**  这个参数指定了清理频率，单位是小时，需要填写一个1或更大的整数，默认是0，表示不开启自己清理功能。

**autopurge.snapRetainCount** 这个参数和上面的参数搭配使用，这个参数指定了需要保留的文件数目。默认是保留3个。

推荐使用第一种方法，对于运维人员来说，将日志清理工作独立出来，便于统一管理也更可控。毕竟zk自带的一些工具并不怎么给力。

#### **5、启动服务并查看**

1、启动服务（**至少要启动两台才能看到状态**）

```
#进入到Zookeeper的bin目录下
cd /opt/zookeeper/zookeeper-3.4.14/bin
#启动服务（3台都需要操作）
./zkServer.sh start
```

2、检查服务状态

```
#检查服务器状态
./zkServer.sh status
```

3、通过status就能看到状态：

```
./zkServer.sh status
JMX enabled by default
Using config: /opt/zookeeper/zookeeper-3.4.14/bin/../conf/zoo.cfg  #配置文件
Mode: follower  #他是否为领导
```

zk集群一般只有一个leader，多个follower，主一般是相应客户端的读写请求，而从主同步数据，当主挂掉之后就会从follower里投票选举一个leader出来。

可以用“jps”查看zk的进程，这个是zk的整个工程的main

```
yum -y install java-1.8.0-openjdk-devel-debug
#执行命令jps
20348 Jps
4233 QuorumPeerMain 
```

## 六、Kafka 集群搭建

### **1、软件环境**

1、linux一台或多台，大于等于2

2、已经搭建好的zookeeper集群

3、软件版本kafka_2.11-0.9.0.1.tgz

### **2、创建目录并下载安装软件**

```
#创建目录
cd /opt/
mkdir kafka #创建项目目录
cd kafka
mkdir kafkalogs #创建kafka消息目录，主要存放kafka消息

#下载软件
wget http://mirrors.tuna.tsinghua.edu.cn/apache/kafka/2.2.0/kafka_2.11-2.2.0.tgz

#解压软件
tar -zxvf kafka_2.11-2.2.0.tgz
```

### **3、修改配置文件**

进入到config目录

```
cd /opt/kafka/kafka_2.11-2.2.0/config/
```

主要关注：server.properties 这个文件即可，我们可以发现在目录下：

有很多文件，这里可以发现有Zookeeper文件，我们可以根据Kafka内带的zk集群来启动，但是建议使用独立的zk集群

```
[root@kafka1 config]# ll
total 68
-rw-r--r-- 1 root root  906 Mar 10 03:44 connect-console-sink.properties
-rw-r--r-- 1 root root  909 Mar 10 03:44 connect-console-source.properties
-rw-r--r-- 1 root root 5321 Mar 10 03:44 connect-distributed.properties
-rw-r--r-- 1 root root  883 Mar 10 03:44 connect-file-sink.properties
-rw-r--r-- 1 root root  881 Mar 10 03:44 connect-file-source.properties
-rw-r--r-- 1 root root 1111 Mar 10 03:44 connect-log4j.properties
-rw-r--r-- 1 root root 2262 Mar 10 03:44 connect-standalone.properties
-rw-r--r-- 1 root root 1221 Mar 10 03:44 consumer.properties
-rw-r--r-- 1 root root 4727 Mar 10 03:44 log4j.properties
-rw-r--r-- 1 root root 1925 Mar 10 03:44 producer.properties
-rw-r--r-- 1 root root 6851 Mar 10 03:44 server.properties
-rw-r--r-- 1 root root 1032 Mar 10 03:44 tools-log4j.properties
-rw-r--r-- 1 root root 1169 Mar 10 03:44 trogdor.conf
-rw-r--r-- 1 root root 1023 Mar 10 03:44 zookeeper.properties
```

修改配置文件：

```
broker.id=0  #当前机器在集群中的唯一标识，和zookeeper的myid性质一样
port=19092 #当前kafka对外提供服务的端口默认是9092
host.name=192.168.7.100 #这个参数默认是关闭的，在0.8.1有个bug，DNS解析问题，失败率的问题。
num.network.threads=3 #这个是borker进行网络处理的线程数
num.io.threads=8 #这个是borker进行I/O处理的线程数
log.dirs=/opt/kafka/kafkalogs/,/opt/aa,/opt/bb #消息存放的目录，这个目录可以配置为“，”逗号分割的表达式，上面的num.io.threads要大于这个目录的个数这个目录，如果配置多个目录，新创建的topic他把消息持久化的地方是，当前以逗号分割的目录中，那个分区数最少就放那一个
socket.send.buffer.bytes=102400 #发送缓冲区buffer大小，数据不是一下子就发送的，先回存储到缓冲区了到达一定的大小后在发送，能提高性能
socket.receive.buffer.bytes=102400 #kafka接收缓冲区大小，当数据到达一定大小后在序列化到磁盘
socket.request.max.bytes=104857600 #这个参数是向kafka请求消息或者向kafka发送消息的请请求的最大数，这个值不能超过java的堆栈大小
num.partitions=1 #默认的分区数，一个topic默认1个分区数
log.retention.hours=168 #默认消息的最大持久化时间，168小时，7天
message.max.byte=5242880  #消息保存的最大值5M
default.replication.factor=2  #kafka保存消息的副本数，如果一个副本失效了，另一个还可以继续提供服务
replica.fetch.max.bytes=5242880  #取消息的最大直接数
log.segment.bytes=1073741824 #这个参数是：因为kafka的消息是以追加的形式落地到文件，当超过这个值的时候，kafka会新起一个文件
log.retention.check.interval.ms=300000 #每隔300000毫秒去检查上面配置的log失效时间（log.retention.hours=168 ），到目录查看是否有过期的消息如果有，删除
log.cleaner.enable=false #是否启用log压缩，一般不用启用，启用的话可以提高性能
zookeeper.connect=192.168.11.139:12181,192.168.11.140:12181,192.168.11.141:1218 #设置zookeeper的连接端口
```

上面是参数的解释，实际的修改项为：

```
#broker.id=1  每台服务器的broker.id都不能相同


#hostname
host.name=192.168.11.139

#在log.retention.hours=168 下面新增下面三项
message.max.byte=5242880
default.replication.factor=2
replica.fetch.max.bytes=5242880

#设置zookeeper的连接端口
zookeeper.connect=192.168.11.139:12181,192.168.11.140:12181,192.168.11.141:12181
```

### **4、启动Kafka集群并测试**

#### 1、启动服务

```
#从后台启动Kafka集群（3台都需要启动）
[root@server1 ~]# cd /opt/kafka/kafka_2.11-2.2.0/bin/ #进入到kafka的bin目录 
[root@server1 bin]# kafka-server-start.sh -daemon ../config/server.properties
```

#### 2、检查服务是否启动

```
#执行命令jps
20348 Jps
4233 QuorumPeerMain
18991 Kafka
```

#### 3、创建Topic来验证是否创建成功

更多请看官方文档：http://kafka.apache.org/documentation.html

```
#创建Topic
./kafka-topics.sh --create --zookeeper 192.168.11.139:12181 --replication-factor 2 --partitions 1 --topic shuaige
#解释
--replication-factor 2   #复制两份
--partitions 1 #创建1个分区
--topic #主题为shuaige

'''在一台服务器上创建一个发布者'''
#创建一个broker，发布者
./kafka-console-producer.sh --broker-list 192.168.11.139:9092 --topic shuaige

'''在一台服务器上创建一个订阅者'''
./kafka-console-consumer.sh  --bootstrap-server 192.168.11.139:9092 --topic shuaige --from-beginning
```

测试（在发布者那里发布消息看看订阅者那里是否能正常收到~）：

#### 4、其他命令

大部分命令可以去官方文档查看

##### 1、查看topic

```
./kafka-topics.sh --list --zookeeper 192.168.11.139:12181
#就会显示我们创建的所有topic
```

##### 2、查看topic状态

```
./kafka-topics.sh --describe --zookeeper 192.168.11.139:12181 --topic shuaige
#下面是显示信息(数字是节点编号)
Topic:shuaige	PartitionCount:1	ReplicationFactor:2	   Configs:
Topic: shuaige	Partition: 0	Leader: 2	Replicas: 2,0	Isr: 2,0
#分区为为1  复制因子为2   
shuaige的分区为0 
Replicas: 0,1  复制的为0，1

```

 OK kafka集群搭建完毕

#### 5、其他说明标注

##### 1、日志说明

默认kafka的日志是保存在/opt/kafka/kafka_2.11-2.2.0/logs目录下的，这里说几个需要注意的日志

```
server.log #kafka的运行日志
state-change.log  #kafka他是用zookeeper来保存状态，所以他可能会进行切换，切换的日志就保存在这里

controller.log #kafka选择一个节点作为“controller”,当发现有节点down掉的时候它负责在已有分区的所有节点中选择新的leader,这使得Kafka可以批量的高效的管理所有分区节点的主从关系。如果controller down掉了，活着的节点中的一个会备切换为新的controller.
```

##### 2、登录zk来查看zk的目录情况

```
#使用客户端进入zk
cd/opt/zookeeper/zookeeper-3.4.14/bin
./zkCli.sh -server 192.168.11.139:12181  #默认是不用加’-server‘参数的因为我们修改了他的端口

#查看目录情况 执行“ls /”
[zk: 127.0.0.1:12181(CONNECTED) 0] ls /

#显示结果：[consumers, config, controller, isr_change_notification, admin, brokers, zookeeper, controller_epoch]
'''
上面的显示结果中：只有zookeeper是，zookeeper原生的，其他都是Kafka创建的
'''

#标注一个重要的
[zk: 127.0.0.1:12181(CONNECTED) 1] get /brokers/ids/1
{"jmx_port":-1,"timestamp":"1456125963355","endpoints":["PLAINTEXT://192.168.7.100:19092"],"host":"192.168.7.100","version":2,"port":19092}
cZxid = 0x1000001c1
ctime = Mon Feb 22 15:26:03 CST 2016
mZxid = 0x1000001c1
mtime = Mon Feb 22 15:26:03 CST 2016
pZxid = 0x1000001c1
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x152e40aead20016
dataLength = 139
numChildren = 0
[zk: 127.0.0.1:12181(CONNECTED) 2] 

#还有一个是查看partion
[zk: 127.0.0.1:12181(CONNECTED) 7] get /brokers/topics/shuaige/partitions/0
null
cZxid = 0x100000029
ctime = Mon Feb 22 10:05:11 CST 2016
mZxid = 0x100000029
mtime = Mon Feb 22 10:05:11 CST 2016
pZxid = 0x10000002a
cversion = 1
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 1
[zk: 127.0.0.1:12181(CONNECTED) 8] 
```


