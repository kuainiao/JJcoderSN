# KAFKA 消息中间件

### 1、常用Message Queue对比

**1、RabbitMQ**

	RabbitMQ是使用Erlang编写的一个开源的消息队列，本身支持很多的协议：AMQP，XMPP, SMTP, STOMP，也正因如此，它非常重量级，更适合于企业级的开发。同时实现了Broker构架，这意味着消息在发送给客户端时先在中心队列排队。对路由，负载均衡或者数据持久化都有很好的支持。

**2、Redis**

	Redis是一个基于Key-Value对的NoSQL数据库，开发维护很活跃。虽然它是一个Key-Value数据库存储系统，但它本身支持MQ功能，所以完全可以当做一个轻量级的队列服务来使用。对于RabbitMQ和Redis的入队和出队操作，各执行100万次，每10万次记录一次执行时间。测试数据分为128Bytes、512Bytes、1K和10K四个不同大小的数据。实验表明：入队时，当数据比较小时Redis的性能要高于RabbitMQ，而如果数据大小超过了10K，Redis则慢的无法忍受；出队时，无论数据大小，Redis都表现出非常好的性能，而RabbitMQ的出队性能则远低于Redis。

**3、ZeroMQ**

	ZeroMQ号称最快的消息队列系统，尤其针对大吞吐量的需求场景。ZeroMQ能够实现RabbitMQ不擅长的高级/复杂的队列，但是开发人员需要自己组合多种技术框架，技术上的复杂度是对这MQ能够应用成功的挑战。ZeroMQ具有一个独特的非中间件的模式，你不需要安装和运行一个消息服务器或中间件，因为你的应用程序将扮演这个服务器角色。你只需要简单的引用ZeroMQ程序库，可以使用NuGet安装，然后你就可以愉快的在应用程序之间发送消息了。但是ZeroMQ仅提供非持久性的队列，也就是说如果宕机，数据将会丢失。其中，Twitter的Storm 0.9.0以前的版本中默认使用ZeroMQ作为数据流的传输（Storm从0.9版本开始同时支持ZeroMQ和Netty作为传输模块）。

**4、ActiveMQ**

	ActiveMQ是Apache下的一个子项目。 类似于ZeroMQ，它能够以代理人和点对点的技术实现队列。同时类似于RabbitMQ，它少量代码就可以高效地实现高级应用场景。

**5、Kafka/Jafka**

	Kafka是Apache下的一个子项目，是一个高性能跨语言分布式发布/订阅消息队列系统，而Jafka是在Kafka之上孵化而来的，即Kafka的一个升级版。具有以下特性：快速持久化，可以在O(1)的系统开销下进行消息持久化；高吞吐，在一台普通的服务器上既可以达到10W/s的吞吐速率；完全的分布式系统，Broker、Producer、Consumer都原生自动支持分布式，自动实现负载均衡；支持Hadoop数据并行加载，对于像Hadoop的一样的日志数据和离线分析系统，但又要求实时处理的限制，这是一个可行的解决方案。Kafka通过Hadoop的并行加载机制统一了在线和离线的消息处理。Apache Kafka相对于ActiveMQ是一个非常轻量级的消息系统，除了性能非常好之外，还是一个工作良好的分布式系统

### 相关概念
producer： 消息生产者，发布消息到 kafka 集群的终端或服务。
broker： kafka 集群中包含的服务器。
topic：每条发布到 kafka 集群的消息属于的类别，即 kafka 是面向 topic 的。
partition： partition 是物理上的概念，每个 topic 包含一个或多个 partition。kafka 分配的单位是 partition。
consumer： 从 kafka 集群中消费消息的终端或服务。
Consumer group： high-level consumer API 中，每个 consumer 都属于一个 consumer group，每条消息只能被 consumer group 中的一个 Consumer 消费，但可以被多个 consumer group 消费。
replica： partition 的副本，保障 partition 的高可用。
leader： replica 中的一个角色， producer 和 consumer 只跟 leader 交互。
follower： replica 中的一个角色，从 leader 中复制数据。
controller： kafka 集群中的其中一个服务器，用来进行 leader election 以及 各种 failover。
zookeeper： kafka 通过 zookeeper 来存储集群的 meta 信息


### 单实例Kafka

前提条件：安装JDK、设置JAVA_HOME、PATH环境变量。

wget http://mirrors.hust.edu.cn/apache/kafka/1.1.0/kafka_2.12-1.1.0.tgz

#### (1) Terminal A

```shell
[root@kafka ~]# ls
kafka_2.12-0.10.2.1.tgz
[root@kafka ~]# tar xfz kafka_2.12-0.10.2.1.tgz
[root@kafka ~]# ls
kafka_2.12-0.10.2.1  kafka_2.12-0.10.2.1.tgz
[root@kafka ~]# cd kafka_2.12-0.10.2.1
[root@kafka kafka_2.12-0.10.2.1]# vim config/zookeeper.properties
[root@kafka kafka_2.12-0.10.2.1]# grep -Pv "^#" config/zookeeper.properties
dataDir=zkdata1
clientPort=2181
maxClientCnxns=0
[root@kafka kafka_2.12-0.10.2.1]# bin/zookeeper-server-start.sh config/zookeeper.properties &      #启动zookeeper
[root@kafka kafka_2.12-0.10.2.1]# ls
bin  config  libs  LICENSE  logs  NOTICE  site-docs  zkdata1
[root@kafka kafka_2.12-0.10.2.1]# ls zkdata1/
version-2
[root@kafka kafka_2.12-0.10.2.1]# vim config/server.properties
[root@kafka kafka_2.12-0.10.2.1]# grep -Pv "^($|#)" config/server.properties
broker.id=0
listeners=PLAINTEXT://:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=kfkdata1
num.partitions=1
num.recovery.threads.per.data.dir=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=6000
[root@kafka kafka_2.12-0.10.2.1]# bin/kafka-server-start.sh config/server.properties
[root@kafka kafka_2.12-0.10.2.1]# ls
bin  config  kfkdata1  libs  LICENSE  logs  NOTICE  site-docs  zkdata1
[root@kafka kafka_2.12-0.10.2.1]# ls kfkdata1/
cleaner-offset-checkpoint  meta.properties  recovery-point-offset-checkpoint  replication-offset-checkpoint
[root@kafka kafka_2.12-0.10.2.1]# jps
3538 Jps
2964 QuorumPeerMain
3214 Kafka
[root@kafka kafka_2.12-0.10.2.1]#
```

Kafka 占tcp 9092 端口，而zookeeper占 tcp 2181端口

#### (2) Terminal B   创建 一个topic

```shell
[root@kafka kafka_2.12-0.10.2.1]# bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partition 1 --topic myfirst-topic
WARNING: Due to limitations in metric names, topics with a period ('.') or underscore ('_') could collide. To avoid issues it is best to use either, but not both.
Created topic "myfirst_topic".
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# ls kfkdata1/
cleaner-offset-checkpoint  meta.properties  myfirst_topic-0  recovery-point-offset-checkpoint  replication-offset-checkpoint
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# ls kfkdata1/myfirst-topic-0/
00000000000000000000.index  00000000000000000000.log  00000000000000000000.timeindex
[root@sdopenswan-jp kafka_2.12-0.10.2.1]#
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# bin/kafka-topics.sh --list --zookeeper localhost:2181
myfirst-topic
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# bin/kafka-console-producer.sh --topic myfirst-topic --broker-list localhost:9092
hello world !
hello kafka myfirst_topic 
```

#### (3) Terminal C  # consumer端连接到zookeeper 读取信息

```shell
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic myfirst_topic --from-beginning
Using the ConsoleConsumer with old consumer is deprecated and will be removed in a future major release. Consider using the new consumer by passing [bootstrap-server] instead of [zookeeper].
hello world !
hello kafka myfirst_topic
```

### 配置文件说明

#### Zookeeper配置

1)  在zoo.cfg中追加以下内容：

```shell
server.n=ip:portA:portB
#n是服务器标识号（1~255）
#ip是服务器ip地址
#portA是与leader进行信息交换的端口
#portB是在leader宕机后，进行leader选举所用的端口
例：
server.1=200.31.157.116:20881:30881
server.2=200.31.157.116:20882:30882
server.3=200.31.157.117:20881:30881

tickTime：毫秒级的基本时间单位，其他时间如心跳/超时等都为该单位时间的整数倍。
initLimit：tickTime的倍数，表示leader选举结束后，followers与leader同步需要的时间，leader的数据非常多或followers比较多时，该值应适当大一些。
syncLimit：tickTime的倍数，表示follower和observer与leader交互时的最大等待时间，是在与leader同步完毕之后，正常请求转发或ping等消息交互时的超时时间。
clientPort：监听客户端连接的服务端口，若一台服务器上安装多个ZooKeeper server，则需要设置不同的端口号。
dataDir：内存数据库快照地址，事务日志地址（除非由dataLogDir另行指定）。
```

2)  在$dataDir下新建文件myid，并写入服务器标识号

```shell
#/tmp/zookeeper为dataDir
cd /tmp/zookeeper/
vim myid
#在myid中添加服务器标识号
```

#### Kafka配置

在配置文件server.properties修改如下内容：
```shell
#broker.id是broker的标识，具有唯一性
broker.id=0
#端口号默认为9092
port=9092
#host.name位kafka所在机器的ip
host.name=10.18.42.251
#设置zookeeper，可连接多个zookeeper服务器
zookeeper.connect=200.31.157.116:2182,200.31.157.116:2183,200.31.157.117:2182
```


### 多实例Kafka

#### (1)配置并启动zookeeper

```shell
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# vim config/zookeeper.properties
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# grep -Pv "^#" config/zookeeper.properties
dataDir=zkdata1
clientPort=2181
maxClientCnxns=0
tickTime=2000
initLimit=5
syncLimit=2
server.0=172.16.1.16:2888:3888
server.1=172.16.2.59:2888:3888
server.2=172.16.0.198:2888:3888
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# echo 0 > zkdata1/myid

[root@sdredis01-jp kafka_2.12-0.10.2.1]# vim config/zookeeper.properties
[root@sdredis01-jp kafka_2.12-0.10.2.1]# grep -Pv "^#" config/zookeeper.properties
dataDir=zkdata1
clientPort=2181
maxClientCnxns=0
tickTime=2000
initLimit=5
syncLimit=2
server.0=172.16.1.16:2888:3888
server.1=172.16.2.59:2888:3888
server.2=172.16.0.198:2888:3888
[root@sdredis01-jp kafka_2.12-0.10.2.1]# ls
bin  config  libs  LICENSE  NOTICE  site-docs
[root@sdredis01-jp kafka_2.12-0.10.2.1]# mkdir zkdata1
[root@sdredis01-jp kafka_2.12-0.10.2.1]# echo 1 >  zkdata1/myid
[root@sdredis01-jp kafka_2.12-0.10.2.1]#

[root@sdredis02-jp kafka_2.12-0.10.2.1]# vim config/zookeeper.properties
[root@sdredis02-jp kafka_2.12-0.10.2.1]# grep -Pv "^#" config/zookeeper.properties
dataDir=zkdata1
clientPort=2181
maxClientCnxns=0
tickTime=2000
initLimit=5
syncLimit=2
server.0=172.16.1.16:2888:3888
server.1=172.16.2.59:2888:3888
server.2=172.16.0.198:2888:3888
[root@sdredis02-jp kafka_2.12-0.10.2.1]# mkdir zkdata1
[root@sdredis02-jp kafka_2.12-0.10.2.1]# echo 2 > zkdata1/myid
[root@sdredis02-jp kafka_2.12-0.10.2.1]#

[root@sdopenswan-jp kafka_2.12-0.10.2.1]#  bin/zookeeper-server-start.sh config/zookeeper.properties &
[root@sdredis01-jp kafka_2.12-0.10.2.1]# bin/zookeeper-server-start.sh config/zookeeper.properties &
[root@sdredis02-jp kafka_2.12-0.10.2.1]# bin/zookeeper-server-start.sh config/zookeeper.properties &
```

#### (2)配置并启动kafka

```shell
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# vim config/server.properties
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# grep -Pv "^($|#)" config/server.properties
broker.id=0
listeners=PLAINTEXT://:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=kfklog
num.partitions=3
num.recovery.threads.per.data.dir=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=172.16.1.16:2181,172.16.2.59:2181,172.16.0.198:2181
zookeeper.connection.timeout.ms=6000
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# vim config/consumer.properties
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# grep -Pv "^($|#)" config/consumer.properties
zookeeper.connect=172.16.1.16:2181,172.16.2.59:2181,172.16.0.198:2181
zookeeper.connection.timeout.ms=6000
group.id=test-consumer-group
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# vim config/producer.properties
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# grep -Pv "^($|#)" config/producer.properties
bootstrap.servers=172.16.1.16:9092,172.16.2.59:9092,172.16.0.198:9092
compression.type=none
[root@sdopenswan-jp kafka_2.12-0.10.2.1]#

[root@sdredis01-jp kafka_2.12-0.10.2.1]# vim config/server.properties
[root@sdredis01-jp kafka_2.12-0.10.2.1]# grep -Pv "^($|#)" config/server.properties
broker.id=1
listeners=PLAINTEXT://:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=kfklog
num.partitions=3
num.recovery.threads.per.data.dir=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=172.16.1.16:2181,172.16.2.59:2181,172.16.0.198:2181
zookeeper.connection.timeout.ms=6000
[root@sdredis01-jp kafka_2.12-0.10.2.1]# vim config/consumer.properties
[root@sdredis01-jp kafka_2.12-0.10.2.1]# grep -Pv "^($|#)" config/consumer.properties
zookeeper.connect=172.16.1.16:2181,172.16.2.59:2181,172.16.0.198:2181
zookeeper.connection.timeout.ms=6000
group.id=test-consumer-group
[root@sdredis01-jp kafka_2.12-0.10.2.1]# vim config/producer.properties
[root@sdredis01-jp kafka_2.12-0.10.2.1]# grep -Pv "^($|#)" config/producer.properties
bootstrap.servers=172.16.1.16:9092,172.16.2.59:9092,172.16.0.198:9092
compression.type=none
[root@sdredis01-jp kafka_2.12-0.10.2.1]#

[root@sdredis02-jp kafka_2.12-0.10.2.1]# vim config/server.properties
[root@sdredis02-jp kafka_2.12-0.10.2.1]# grep -Pv "^($|#)" config/server.properties
broker.id=2
listeners=PLAINTEXT://:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=kfklog
num.partitions=3
num.recovery.threads.per.data.dir=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=172.16.1.16:2181,172.16.2.59:2181,172.16.0.198:2181
zookeeper.connection.timeout.ms=6000
[root@sdredis02-jp kafka_2.12-0.10.2.1]# vim config/consumer.properties
[root@sdredis02-jp kafka_2.12-0.10.2.1]# grep -Pv "^($|#)" config/consumer.properties
zookeeper.connect=172.16.1.16:2181,172.16.2.59:2181,172.16.0.198:2181
zookeeper.connection.timeout.ms=6000
group.id=test-consumer-group
[root@sdredis02-jp kafka_2.12-0.10.2.1]# vim config/producer.properties
[root@sdredis02-jp kafka_2.12-0.10.2.1]# grep -Pv "^($|#)" config/producer.properties
bootstrap.servers=172.16.1.16:9092,172.16.2.59:9092,172.16.0.198:9092
compression.type=none
[root@sdredis02-jp kafka_2.12-0.10.2.1]#
```
三台机器分别启动  bin/kafka-server-start.sh config/server.properties &

#### (3)测试

```shell
[root@sdredis02-jp kafka_2.12-0.10.2.1]# bin/kafka-topics.sh --create --zookeeper 172.16.0.198:2181  --replication-factor 3 --partitions 1 --topic yc01_topic
WARNING: Due to limitations in metric names, topics with a period ('.') or underscore ('_') could collide. To avoid issues it is best to use either, but not both.
Created topic "yc01_topic".
[root@sdredis02-jp kafka_2.12-0.10.2.1]# bin/kafka-topics.sh --list --zookeeper 172.16.0.198:2181
myfirst_topic
yc01_topic
[root@sdredis02-jp kafka_2.12-0.10.2.1]# bin/kafka-topics.sh --describe --zookeeper 172.16.0.198:2181
Topic:myfirst_topic	PartitionCount:1	ReplicationFactor:1	Configs:
	Topic: myfirst_topic	Partition: 0	Leader: 0	Replicas: 0	Isr: 0
Topic:yc01_topic	PartitionCount:1	ReplicationFactor:3	Configs:
	Topic: yc01_topic	Partition: 0	Leader: 1	Replicas: 1,2,0	Isr: 1,2,0
[root@sdredis02-jp kafka_2.12-0.10.2.1]#

[root@sdredis01-jp kafka_2.12-0.10.2.1]# bin/kafka-console-producer.sh --broker-list 172.16.1.16:9092,172.16.2.59:9092,172.16.0.198:9092 --topic yc01_topic
hello multi instance kafka

[root@sdredis02-jp kafka_2.12-0.10.2.1]# bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic yc01_topic --from-beginning
Using the ConsoleConsumer with old consumer is deprecated and will be removed in a future major release. Consider using the new consumer by passing [bootstrap-server] instead of [zookeeper].
hello multi instance kafka
```

#### (4)查看zookeeper状态

```shell
[root@sdopenswan-jp kafka_2.12-0.10.2.1]# echo stat|nc 127.0.0.1 2181
Zookeeper version: 3.4.9-1757313, built on 08/23/2016 06:50 GMT
Clients:
 /127.0.0.1:46010[0](queued=0,recved=1,sent=0)
 /172.16.0.198:53940[1](queued=0,recved=875,sent=875)
Latency min/avg/max: 0/0/4
Received: 890
Sent: 889
Connections: 2
Outstanding: 0
Zxid: 0x100000060
Mode: leader
Node count: 33
[root@sdopenswan-jp kafka_2.12-0.10.2.1]#

[root@sdredis01-jp kafka_2.12-0.10.2.1]# echo stat|nc 127.0.0.1 2181
Zookeeper version: 3.4.9-1757313, built on 08/23/2016 06:50 GMT
Clients:
 /127.0.0.1:53466[0](queued=0,recved=1,sent=0)
Latency min/avg/max: 0/0/0
Received: 2
Sent: 1
Connections: 1
Outstanding: 0
Zxid: 0x10000005d
Mode: follower
Node count: 33

[root@sdredis02-jp kafka_2.12-0.10.2.1]# echo stat|nc 127.0.0.1 2181
Zookeeper version: 3.4.9-1757313, built on 08/23/2016 06:50 GMT
Clients:
 /172.16.2.59:53354[1](queued=0,recved=952,sent=952)
 /172.16.1.16:53038[1](queued=0,recved=1018,sent=1023)
 /127.0.0.1:49478[0](queued=0,recved=1,sent=0)
Latency min/avg/max: 0/0/15
Received: 2566
Sent: 2572
Connections: 3
Outstanding: 0
Zxid: 0x100000060
Mode: follower
Node count: 33
[root@sdredis02-jp kafka_2.12-0.10.2.1]#
```

#### (5)常用命令总结

```shell
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 2 --partitions 4 --topic test
bin/kafka-topics.sh --describe --zookeeper 
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic test
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test --producer.config config/producer.properties
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --new-consumer --from-beginning --consumer.config config/consumer.properties
bin/kafka-consumer-groups.sh --new-consumer --bootstrap-server localhost:9092 --list
bin/kafka-run-class.sh kafka.tools.ConsumerOffsetChecker --zkconnect localhost:2181 --group test
bin/kafka-consumer-groups.sh --new-consumer --bootstrap-server localhost:9092 --describe --group test-consumer-group
bin/kafka-preferred-replica-election.sh --zookeeper zk_host:port/chroot
bin/kafka-producer-perf-test.sh --topic test --num-records 100 --record-size 1 --throughput 100  --producer-props bootstrap.servers=localhost:9092
```

用户在客户端可以通过 telnet 或 nc 向 ZooKeeper 提交相应的命令
1. 可以通过命令：echo stat|nc 127.0.0.1 2181 来查看哪个节点被选择作为follower或者leader
2. 使用echo ruok|nc 127.0.0.1 2181 测试是否启动了该Server，若回复imok表示已经启动。
3. echo dump| nc 127.0.0.1 2181 ,列出未经处理的会话和临时节点。
4. echo kill | nc 127.0.0.1 2181 ,关掉server
5. echo conf | nc 127.0.0.1 2181 ,输出相关服务配置的详细信息。
6. echo cons | nc 127.0.0.1 2181 ,列出所有连接到服务器的客户端的完全的连接 / 会话的详细信息。
7. echo envi |nc 127.0.0.1 2181 ,输出关于服务环境的详细信息（区别于 conf 命令）。
8. echo reqs | nc 127.0.0.1 2181 ,列出未经处理的请求。
9. echo wchs | nc 127.0.0.1 2181 ,列出服务器 watch 的详细信息。
10. echo wchc | nc 127.0.0.1 2181 ,通过 session 列出服务器 watch 的详细信息，它的输出是一个与 watch 相关的会话的列表。
11. echo wchp | nc 127.0.0.1 2181 ,通过路径列出服务器 watch 的详细信息。它输出一个与 session 相关的路径



### 补充新实验过程(参考)


teacher配置如下：

``` shell
[root@teacher ~]# vim /etc/profile
[root@teacher ~]# source /etc/profile
[root@teacher ~]# echo $JAVA_HOME
/usr/java/latest
[root@teacher ~]# which java
/usr/java/latest/bin/java
[root@teacher ~]# java -version
java version "1.8.0_162"
Java(TM) SE Runtime Environment (build 1.8.0_162-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.162-b12, mixed mode)
[root@teacher ~]#
[root@teacher ~]# scp /etc/profile node2:/etc/
profile                                                                                100% 1859   549.7KB/s   00:00    
[root@teacher ~]# scp /etc/profile node3:/etc/
profile                                                                                100% 1859   448.7KB/s   00:00    
[root@teacher ~]#
[root@teacher ~]# tar xf kafka_2.12-1.1.0.tgz  -C /usr/local/
[root@teacher opt]# cd /usr/local/
[root@teacher local]# ln -s kafka_2.12-1.1.0/ kafka
[root@teacher local]# ls
bin  etc  games  include  kafka  kafka_2.12-1.1.0  lib  lib64  libexec  logstash  php  sbin  share  src  zabbix
[root@teacher local]# cd kafka
[root@teacher kafka]# mkdir zkdata
[root@teacher kafka]# mkdir kfklog
[root@teacher kafka]# echo 0 > zkdata/myid
[root@teacher kafka]# vim config/zookeeper.properties 
[root@teacher kafka]# grep -Pv "^(#|$)" config/zookeeper.properties
dataDir=zkdata
clientPort=2181
maxClientCnxns=0
tickTime=2000
initLimit=5
syncLimit=2
server.0=192.168.1.102:2888:3888
server.1=192.168.1.103:2888:3888
server.2=192.168.1.104:2888:3888
[root@teacher kafka]# vim config/server.properties 
[root@teacher kafka]# grep -Pv "^(#|$)" config/server.properties 
broker.id=0
listeners=PLAINTEXT://:9092
advertised.listeners=PLAINTEXT://192.168.1.102:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=kfklog
num.partitions=3
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=192.168.1.102:2181,192.168.1.103:2181,192.168.1.104:2181
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
[root@teacher kafka]# vim config/consumer.properties 
[root@teacher kafka]# grep -Pv "^(#|$)" config/consumer.properties 
bootstrap.servers=192.168.1.102:9092,192.168.1.103:9092,192.168.1.104:9092
zookeeper.connect=192.168.1.102:2181,192.168.1.103:2181,192.168.1.104:2181
group.id=test-consumer-group
[root@teacher kafka]# vim config/producer.properties 
[root@teacher kafka]# grep -Pv "^(#|$)" config/producer.properties 
bootstrap.servers=192.168.1.102:9092,192.168.1.103:9092,192.168.1.104:9092
compression.type=none
[root@teacher ~]# cd /usr/local/
[root@teacher local]# scp -r kafka
kafka/             kafka_2.12-1.1.0/  
[root@teacher local]# scp -r kafka_2.12-1.1.0 node2:/usr/local/
```

node2配置如下：

``` shell
[root@node2 ~]# java -version 
java version "1.8.0_162"
Java(TM) SE Runtime Environment (build 1.8.0_162-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.162-b12, mixed mode)
[root@node2 ~]# source /etc/profile
[root@node2 ~]# echo $JAVA_HOME
/usr/java/latest
[root@node2 ~]# which java
/usr/java/latest/bin/java
[root@node2 ~]# tail -3  /etc/hosts
192.168.1.102 teacher
192.168.1.103 node2
192.168.1.104 node3
[root@node2 ~]# cd /usr/local/
[root@node2 local]# ln -s kafka_2.12-1.1.0 kafka
[root@node2 local]# cd kafka
[root@node2 kafka]# echo 1 > zkdata/myid 
[root@node2 kafka]# vim config/server.properties 
[root@node2 kafka]# vim config/consumer.properties 
[root@node2 kafka]# vim config/producer.properties 
[root@node2 kafka]# grep -Pv "^(#|$)" config/zookeeper.properties 
dataDir=zkdata
clientPort=2181
maxClientCnxns=0
tickTime=2000
initLimit=5
syncLimit=2
server.0=192.168.1.102:2888:3888
server.1=192.168.1.103:2888:3888
server.2=192.168.1.104:2888:3888
[root@node2 kafka]# grep -Pv "^(#|$)" config/server.properties 
broker.id=1
listeners=PLAINTEXT://:9092
advertised.listeners=PLAINTEXT://192.168.1.103:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=kfklog
num.partitions=3
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=192.168.1.102:2181,192.168.1.103:2181,192.168.1.104:2181
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
[root@node2 kafka]# grep -Pv "^(#|$)" config/consumer.properties 
bootstrap.servers=192.168.1.102:9092,192.168.1.103:9092,192.168.1.104:9092
zookeeper.connect=192.168.1.102:2181,192.168.1.103:2181,192.168.1.104:2181
group.id=test-consumer-group
[root@node2 kafka]# grep -Pv "^(#|$)" config/producer.properties 
bootstrap.servers=192.168.1.102:9092,192.168.1.103:9092,192.168.1.104:9092
compression.type=none
[root@node2 kafka]#
```

node3配置如下：

``` shell
[root@node3 ~]# cd /usr/local/
[root@node3 local]# ln -s kafka_2.12-1.1.0 kafka
[root@node3 local]# ls
bin  etc  games  include  kafka  kafka_2.12-1.1.0  lib  lib64  libexec  sbin  share  src
[root@node3 local]# cd kafka
[root@node3 kafka]# ls
bin  config  kfklog  libs  LICENSE  NOTICE  site-docs  zkdata
[root@node3 kafka]# echo 2 > zkdata/myid 
[root@node3 kafka]# vim config/server.properties 
[root@node3 kafka]# grep -Pv "^(#|$)" config/zookeeper.properties 
dataDir=zkdata
clientPort=2181
maxClientCnxns=0
tickTime=2000
initLimit=5
syncLimit=2
server.0=192.168.1.102:2888:3888
server.1=192.168.1.103:2888:3888
server.2=192.168.1.104:2888:3888
[root@node3 kafka]# grep -Pv "^(#|$)" config/server.properties 
broker.id=2
listeners=PLAINTEXT://:9092
advertised.listeners=PLAINTEXT://192.168.1.104:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=kfklog
num.partitions=3
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=192.168.1.102:2181,192.168.1.103:2181,192.168.1.104:2181
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
[root@node3 kafka]# grep -Pv "^(#|$)" config/consumer.properties 
bootstrap.servers=192.168.1.102:9092,192.168.1.103:9092,192.168.1.104:9092
zookeeper.connect=192.168.1.102:2181,192.168.1.103:2181,192.168.1.104:2181
group.id=test-consumer-group
[root@node3 kafka]# grep -Pv "^(#|$)" config/producer.properties 
bootstrap.servers=192.168.1.102:9092,192.168.1.103:9092,192.168.1.104:9092
compression.type=none
[root@node3 kafka]# 
```

启动zookeeper

``` shell
[root@teacher kafka]# bin/zookeeper-server-start.sh config/zookeeper.properties & 
[root@node2 kafka]# bin/zookeeper-server-start.sh config/zookeeper.properties &
[root@node3 kafka]# bin/zookeeper-server-start.sh config/zookeeper.properties &
```

启动kafka

``` shell
[root@teacher kafka]# bin/kafka-server-start.sh config/server.properties &
[root@node2 kafka]#  bin/kafka-server-start.sh config/server.properties &
[root@node3 kafka]#  bin/kafka-server-start.sh config/server.properties &
```






