

# Redis 5.05 Cluster集群带认证及客户端连接

## 一、Redis Cluster 介绍

​         Redis在3.0版正式引入redis-cluster集群这个特性。Redis集群是一个提供在多个Redis间节点间共享数据的程序集。Redis集群是一个分布式（distributed）、容错（fault-tolerant）的Redis内存K/V服务，集群可以使用的功能是普通单机Redis所能使用的功能的一个子集（subset），比如Redis集群并不支持处理多个keys的命令，因为这需要在不同的节点间移动数据，从而达不到像Redis那样的性能，在高负载的情况下可能会导致不可预料的错误。还有比如set里的并集（unions）和交集（intersections）操作，就没有实现。通常来说，那些处理命令的节点获取不到键值的所有操作都不会被实现。在将来，用户或许可以通过使用MIGRATE COPY命令，在集群上用计算节点（Computation Nodes） 来执行多键值的只读操作， 但Redis集群本身不会执行复杂的多键值操作来把键值在节点间移来移去。Redis集群不像单机版本的Redis那样支持多个数据库，集群只有数据库0，而且也不支持SELECT命令。Redis集群通过分区来提供一定程度的可用性，在实际环境中当某个节点宕机或者不可达的情况下继续处理命令。

### 1、Redis集群的优点

无中心架构，分布式提供服务。数据按照slot存储分布在多个redis实例上。增加slave做standby数据副本，用于failover，使集群快速恢复。实现故障auto failover，节点之间通过gossip协议交换状态信息；投票机制完成slave到master角色的提升。支持在线增加或减少节点。降低硬件成本和运维成本，提高系统的扩展性和可用性。

### 2、Redis集群的缺点

client实现复杂，驱动要求实现smart client，缓存slots mapping信息并及时更新。目前仅JedisCluster相对成熟，异常处理部分还不完善，比如常见的“max redirect exception”。客户端的不成熟，影响应用的稳定性，提高开发难度。节点会因为某些原因发生阻塞(阻塞时间大于clutser-node-timeout），被判断下线。这种failover是没有必要，sentinel也存在这种切换场景。

### 3、参考资料

参考：http://redis.io/topics/cluster-tutorial。

集群部署交互式命令行工具：https://github.com/eyjian/redis-tools/tree/master/deploy

集群运维命令行工具：https://github.com/eyjian/redis-tools/tree/master

批量操作工具：https://github.com/eyjian/libmooon/releases

### 4. 专业术语

| **名词** | **解释**                                                    |
| -------- | ----------------------------------------------------------- |
| ASAP     | As Soon As Possible，尽可能                                 |
| RESP     | Redis Serialization Protocol，redis的序列化协议             |
| replica  | 从5.0开始，原slave改叫replica，相关的配置参数也做了同样改名 |

## 二、Redis Cluster 集群部署

### 1、部署计划

redis cluster 要求至少三主三从共6个节点才能组成redis集群，测试环境可一台物理上启动6个redis节点，但生产环境至少要准备3台物理机或者虚拟机。

| **服务端口** | **IP地址**      | **配置文件名**              |
| ------------ | --------------- | --------------------------- |
| 6001         | 192.168.152.193 | /redis/6001/conf/redis.conf |
| 6002         | 192.168.152.193 | /redis/6002conf/redis.conf  |
| 6001         | 192.168.152.194 | /redis/6001/conf/redis.conf |
| 6002         | 192.168.152.194 | /redis/6002/conf/redis.conf |
| 6001         | 192.168.152.198 | /redis/6001/conf/redis.conf |
| 6002         | 192.168.152.198 | /redis/6002/conf/redis.conf |

### 2、修改集群主机名

```shell
hostnamectl --static set-hostname redis01
hostnamectl --static set-hostname redis02
hostnamectl --static set-hostname redis03
```

### 3、hosts文件配置

```shell
cat >> /etc/hosts <<-EOF
192.168.152.193 redis01
192.168.152.194 redis02
192.168.152.198 redis03
EOF
```

从redis 3.0之后版本支持redis-cluster集群，redis-4.0.0开始支持module，redis-5.0.0开始支持类似于kafka那样的消息队列，Redis-Cluster采用无中心结构，每个节点保存数据和整个集群状态，每个节点都和其他所有节点连接。这样就可以很好的保证redis的高可用性，下面就来部署个Redis Cluster，在两台服务器上部署6个redis节点

### 4、修改系统参数

#### 1、修改最大可打开文件数

```shell
cat >> /etc/security/limits.conf << EOF
* soft nofile 102400
* hard nofile 102400
EOF
```

- 其中102400为一个进程最大可以打开的文件个数，当与RedisServer的连接数多时，需要设定为合适的值。
- 有些环境修改后，root用户需要重启机器才生效，而普通用户重新登录后即生效。如果是crontab，则需要重启crontab，如：service crond restart，有些平台可能是service cron restart（类似重启系统日志服务：service rsyslog restart或systemctl restart rsyslog）。
- 有些环境下列设置即可让root重新登录即生效，而不用重启机器：
- 但是要小心，有些环境上面这样做，可能导致无法ssh登录，所以在修改时最好打开两个窗口，万一登录不了还可自救。

如何确认更改对一个进程生效？按下列方法（其中$PID为被查的进程ID）：

```shell
cat /proc/$PID/limits
```

系统关于/etc/security/limits.conf文件的说明：

```shell
#This file sets the resource limits for the users logged in via PAM.
#It does not affect resource limits of the system services.
```

PAM：全称“Pluggable Authentication Modules”，中文名“插入式认证模块”。/etc/security/limits.conf实际为pam_limits.so（位置：/lib/security/pam_limits.so）的配置文件，只针对单个会话。要使用limits.conf生效，必须保证pam_limits.so被加入到了启动文件中。

注释说明只对通过PAM登录的用户生效，与PAM相关的文件（均位于/etc/pam.d目录下）：

```shell
/etc/pam.d/login
/etc/pam.d/sshd
/etc/pam.d/crond
```

如果需要设置Linux用户的密码策略，可以修改文件/etc/login.defs，但这个只对新增的用户有效，如果要影响已有用户，可使用命令chage

#### 2、TCP监听队列大小

要想永久生效，需要在文件/etc/sysctl.conf中增加一行：net.core.somaxconn = 32767，然后执行命令“sysctl -p”以生效。

Redis配置项tcp-backlog的值不能超过somaxconn的大小。

```shell
echo "net.core.somaxconn = 32767" >> /etc/sysctl.conf
sysctl -p
```

 即TCP listen的backlog大小，“/proc/sys/net/core/somaxconn”的默认值一般较小如128，需要修改大一点，比如改成32767。立即生效还可以使用命令：

```shell
sysctl -w net.core.somaxconn=32767
```

#### 3、OOM相关：vm.overcommit_memory

```shell
echo "vm.overcommit_memory=1" >> /etc/sysctl.conf
sysctl -p
```

 /proc/sys/vm/overcommit_memory”默认值为0，表示不允许申请超过CommitLimmit大小的内存。可以设置为1关闭Overcommit，设置方法请参照net.core.somaxconn完成

#### 4、开启内核的“Transparent Huge Pages (THP)”特性

默认值为“[always] madvise never”，建议设置为never，以开启内核的“Transparent Huge Pages (THP)”特性，设置后redis进程需要重启。

为了永久生效，请将

```shell
echo never > /sys/kernel/mm/transparent_hugepage/enabled
```

加入到文件/etc/rc.local中。

```shell
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled"  >> /etc/rc.local
chmod +x /etc/rc.local
```

- 什么是Transparent Huge Pages？为提升性能，通过大内存页来替代传统的4K页，使用得管理虚拟地址数变少，加快从虚拟地址到物理地址的映射，以及摒弃内存页面的换入换出以提高内存的整体性能。内核Kernel将程序缓存内存中，每页内存以2M为单位。相应的系统进程为khugepaged。
- 在Linux中，有两种方式使用Huge Pages，一种是2.6内核引入的HugeTLBFS，另一种是2.6.36内核引入的THP。HugeTLBFS主要用于数据库，THP广泛应用于应用程序。
- 一般可以在rc.local或/etc/default/grub中对Huge Pages进行设置

### 5、安装 redis 并配置 redis-cluster

#### 1、redis01 安装

```shell
[root@redis01 ~]# cd /opt
[root@redis01 ~]# wget http://download.redis.io/releases/redis-5.0.5.tar.gz
[root@redis01 ~]# tar -zxvf redis-5.0.5.tar.gz
[root@redis01 ~]# cd redis-5.0.5/
[root@redis01 ~]# make
[root@redis01 ~]# make install PREFIX=/usr/local/redis-cluster
```

##### 1、创建实例目录

```shell
[root@redis01 ~]# mkdir -p /redis/{6001,6002}/{conf,data,log}
```

##### 2、配置

配置官方配置文件，去掉#开头的和空格行

```shell
[root@redis01 ~]# cat redis.conf |grep -v ^# |grep -v ^$
```

###### 1、redis01 6001 配置文件

```shell
[root@redis01 ~]#cd /redis/6001/conf/
[root@redis01 conf]# cat >> redis.conf << EOF
bind 0.0.0.0
protected-mode no
port 6001
daemonize no
dir /redis/6001/data
cluster-enabled yes
cluster-config-file /redis/6001/conf/nodes.conf
cluster-node-timeout 5000
appendonly yes
daemonize yes
pidfile /redis/6001/redis.pid
logfile /redis/6001/log/redis.log
EOF
```

###### 2、redis01 6002 配置文件

```shell
[root@redis01 conf]# sed 's/6001/6002/g' redis.conf > /redis/6002/conf/redis.conf
```

###### 3、启动脚本 start-redis-cluster.sh

```shell
[root@redis01 ~]#cat >/usr/local/redis-cluster/start-redis-cluster.sh<<-EOF
#!/bin/bash
REDIS_HOME=/usr/local/redis-cluster
REDIS_CONF=/redis
\$REDIS_HOME/bin/redis-server \$REDIS_CONF/6001/conf/redis.conf
\$REDIS_HOME/bin/redis-server \$REDIS_CONF/6002/conf/redis.conf
EOF
```

###### 4、添加权限

```shell
[root@redis01 ~]# chmod +x /usr/local/redis-cluster/start-redis-cluster.sh
```

###### 5、启动 redis

```shell
[root@redis01 ~]# /usr/local/redis-cluster/start-redis-cluster.sh
```

 查看 redis 启动状态

```shell
[root@redis01 ~]# ss -anput | grep redis
tcp    LISTEN     0      511       *:6001                  *:*                   users:(("redis-server",pid=25993,fd=6))
tcp    LISTEN     0      511       *:6002                  *:*                   users:(("redis-server",pid=25995,fd=6))
tcp    LISTEN     0      511       *:16001                 *:*                   users:(("redis-server",pid=25993,fd=9))
tcp    LISTEN     0      511       *:16002                 *:*                   users:(("redis-server",pid=25995,fd=9))
```

查看redis进程启动状态

```shell
[root@redis01 ~]# ps -ef | grep redis
root      25993      1  0 16:56 ?        00:00:00 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6001 [cluster]
root      25995      1  0 16:56 ?        00:00:00 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6002 [cluster]
root      26060   6913  0 17:12 pts/0    00:00:00 grep --color=auto redis
```

#### 2、redis02 安装

```shell
[root@redis02 ~]# cd /opt
[root@redis02 ~]# wget http://download.redis.io/releases/redis-5.0.5.tar.gz
[root@redis02 ~]# tar -zxvf redis-5.0.5.tar.gz
[root@redis02 ~]# cd redis-5.0.5/
[root@redis02 ~]# make
[root@redis02 ~]# make install PREFIX=/usr/local/redis-cluster
```

##### 1、创建实例目录

```shell
[root@redis02 ~]# mkdir -p /redis/{6001,6002}/{conf,data,log}
```

##### 2、配置

```shell
[root@redis02 ~]#cd /redis/6001/conf/
[root@redis02 conf]# cat >> redis.conf << EOF
bind 0.0.0.0
protected-mode no
port 6001
daemonize no
dir /redis/6001/data
cluster-enabled yes
cluster-config-file /redis/6001/conf/nodes.conf
cluster-node-timeout 5000
appendonly yes
daemonize yes
pidfile /redis/6001/redis.pid
logfile /redis/6001/log/redis.log
EOF
```

###### 1、redis02 6002配置文件

```shell
[root@redis02 conf]# sed 's/6001/6002/g' redis.conf > /redis/6002/conf/redis.conf
```

###### 2、写一个启动脚本 start-redis-cluster.sh

```shell
[root@redis02 ~]#cat >/usr/local/redis-cluster/start-redis-cluster.sh<<-EOF
#!/bin/bash
REDIS_HOME=/usr/local/redis-cluster
REDIS_CONF=/redis
\$REDIS_HOME/bin/redis-server \$REDIS_CONF/6001/conf/redis.conf
\$REDIS_HOME/bin/redis-server \$REDIS_CONF/6002/conf/redis.conf
EOF
```

######  3、添加权限

```shell
[root@redis02 ~]# chmod +x /usr/local/redis-cluster/start-redis-cluster.sh
```

###### 4、启动redis

```shell
[root@redis02 ~]# /usr/local/redis-cluster/start-redis-cluster.sh
```

 查看 redis 启动状态

```shell
[root@redis02 ~]# ss -anput | grep redis
tcp    LISTEN     0      511       *:6001                  *:*                   users:(("redis-server",pid=25993,fd=6))
tcp    LISTEN     0      511       *:6002                  *:*                   users:(("redis-server",pid=25995,fd=6))
tcp    LISTEN     0      511       *:16001                 *:*                   users:(("redis-server",pid=25993,fd=9))
tcp    LISTEN     0      511       *:16002                 *:*                   users:(("redis-server",pid=25995,fd=9))
```

查看redis进程启动状态

```shell
[root@redis02 ~]# ps -ef | grep redis
root      25993      1  0 16:56 ?        00:00:00 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6001 [cluster]
root      25995      1  0 16:56 ?        00:00:00 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6002 [cluster]
root      26060   6913  0 17:12 pts/0    00:00:00 grep --color=auto redis
```

#### 3、redis03 安装

```shell
[root@redis03 ~]# cd /opt
[root@redis03 ~]# wget http://download.redis.io/releases/redis-5.0.5.tar.gz
[root@redis03 ~]# tar -zxvf redis-5.0.5.tar.gz
[root@redis03 ~]# cd redis-5.0.5/
[root@redis03 ~]# make
[root@redis03 ~]# make install PREFIX=/usr/local/redis-cluster
```

##### 1、创建实例目录

```shell
[root@redis03 ~]# mkdir -p /redis/{6001,6002}/{conf,data,log}
```

##### 2、配置

```shell
[root@redis03 ~]#cd /redis/6001/conf/
[root@redis03 conf]# cat >> redis.conf << EOF
bind 0.0.0.0
protected-mode no
port 6001
daemonize no
dir /redis/6001/data
cluster-enabled yes
cluster-config-file /redis/6001/conf/nodes.conf
cluster-node-timeout 5000
appendonly yes
daemonize yes
pidfile /redis/6001/redis.pid
logfile /redis/6001/log/redis.log
EOF
```

###### 1、redis02 6002配置文件

```shell
[root@redis03 conf]# sed 's/6001/6002/g' redis.conf > /redis/6002/conf/redis.conf
```

###### 2、写一个启动脚本 start-redis-cluster.sh

```shell
[root@redis03 ~]# cat >/usr/local/redis-cluster/start-redis-cluster.sh<<-EOF
#!/bin/bash
REDIS_HOME=/usr/local/redis-cluster
REDIS_CONF=/redis
\$REDIS_HOME/bin/redis-server \$REDIS_CONF/6001/conf/redis.conf
\$REDIS_HOME/bin/redis-server \$REDIS_CONF/6002/conf/redis.conf
EOF
```

######  3、添加权限

```shell
[root@redis03 ~]# chmod +x /usr/local/redis-cluster/start-redis-cluster.sh
```

###### 4、启动redis

```shell
[root@redis03 ~]# /usr/local/redis-cluster/start-redis-cluster.sh
```

 查看 redis 启动状态

```shell
[root@redis03 ~]# ss -anput | grep redis
tcp    LISTEN     0      511       *:6001                  *:*                   users:(("redis-server",pid=25993,fd=6))
tcp    LISTEN     0      511       *:6002                  *:*                   users:(("redis-server",pid=25995,fd=6))
tcp    LISTEN     0      511       *:16001                 *:*                   users:(("redis-server",pid=25993,fd=9))
tcp    LISTEN     0      511       *:16002                 *:*                   users:(("redis-server",pid=25995,fd=9))
```

查看redis进程启动状态

```shell
[root@redis03 ~]# ps -ef | grep redis
root      25993      1  0 16:56 ?        00:00:00 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6001 [cluster]
root      25995      1  0 16:56 ?        00:00:00 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6002 [cluster]
root      26060   6913  0 17:12 pts/0    00:00:00 grep --color=auto redis
```

### 6、创建 redis cluster

如果只是想快速创建和启动redis集群，可使用redis官方提供的脚本create-cluster，注意redis-5.0.0版本开始才支持“--cluster”

```shell
[root@redis01 bin]# cd /usr/local/redis-cluster/bin
[root@redis01 bin]# ./redis-cli --cluster create 192.168.152.193:6001 192.168.152.193:6002 192.168.152.194:6001 192.168.152.194:6002 192.168.152.198:6001 192.168.152.198:6002 --cluster-replicas 1

>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 192.168.152.194:6002 to 192.168.152.193:6001
Adding replica 192.168.152.198:6002 to 192.168.152.194:6001
Adding replica 192.168.152.193:6002 to 192.168.152.198:6001
M: 9c0c3aac2787af4824110bed08e5c346bc218ca6 192.168.152.193:6001
   slots:[0-5460] (5461 slots) master
S: 41591f7b35be3e5aa89320c0927e83ec915faac6 192.168.152.193:6002
   replicates 8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859
M: 60225e8398b1c6cf609ca27c63d968befbf5e3ee 192.168.152.194:6001
   slots:[5461-10922] (5462 slots) master
S: 255a59264a7fd7daef67ba1180ba0458a593b28b 192.168.152.194:6002
   replicates 9c0c3aac2787af4824110bed08e5c346bc218ca6
M: 8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859 192.168.152.198:6001
   slots:[10923-16383] (5461 slots) master
S: 41ffe24a976c1698590e739a95c7b221d406ca75 192.168.152.198:6002
   replicates 60225e8398b1c6cf609ca27c63d968befbf5e3ee
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
....
>>> Performing Cluster Check (using node 192.168.152.193:6001)
M: 9c0c3aac2787af4824110bed08e5c346bc218ca6 192.168.152.193:6001
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: 41ffe24a976c1698590e739a95c7b221d406ca75 192.168.152.198:6002
   slots: (0 slots) slave
   replicates 60225e8398b1c6cf609ca27c63d968befbf5e3ee
M: 60225e8398b1c6cf609ca27c63d968befbf5e3ee 192.168.152.194:6001
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
M: 8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859 192.168.152.198:6001
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: 255a59264a7fd7daef67ba1180ba0458a593b28b 192.168.152.194:6002
   slots: (0 slots) slave
   replicates 9c0c3aac2787af4824110bed08e5c346bc218ca6
S: 41591f7b35be3e5aa89320c0927e83ec915faac6 192.168.152.193:6002
   slots: (0 slots) slave
   replicates 8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

 **注意：**

如果配置项 cluster-enabled 的值不为yes，则执行时会报错“[ERR] Node 192.168.152.193:6001 is not configured as a cluster node.”。这个时候需要先将cluster-enabled的值改为 yes，然后重启 redis-server 进程，之后才可以重新执行 redis-cli 创建集群。

#### 1、redis-cli 的参数说明

1) create

表示创建一个redis集群。

2) --cluster-replicas 1

表示为集群中的每一个主节点指定一个从节点，即一比一的复制

#### 2、查看redis进程是否已切换为集群状态（cluster）

```shell
[root@redis01 bin]# cd
[root@redis01 ~]# ps -ef|grep redis
root      25993      1  0 16:56 ?        00:00:02 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6001 [cluster]
root      25995      1  0 16:56 ?        00:00:02 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6002 [cluster]
```

#### 3、停止redis实例，直接使用kill命令即可

```shell
kill -9  25993
```

#### 4、设置命令行工具 redis-cli

```shell
[root@redis01 ~]# ln -s /usr/local/redis-cluster/bin/redis-cli /bin/redis-cli
[root@redis65 bin]# redis-cli -c -p 6001
```

#### 5、查看集群中的节点

```shell
127.0.0.1:6001> cluster nodes
1ffe24a976c1698590e739a95c7b221d406ca75 192.168.152.198:6002@16002 slave 60225e8398b1c6cf609ca27c63d968befbf5e3ee 0 1569404664000 6 connected
60225e8398b1c6cf609ca27c63d968befbf5e3ee 192.168.152.194:6001@16001 master - 0 1569404664529 3 connected 5461-10922
9c0c3aac2787af4824110bed08e5c346bc218ca6 192.168.152.193:6001@16001 myself,master - 0 1569404662000 1 connected 0-5460
8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859 192.168.152.198:6001@16001 master - 0 1569404664025 5 connected 10923-16383
255a59264a7fd7daef67ba1180ba0458a593b28b 192.168.152.194:6002@16002 slave 9c0c3aac2787af4824110bed08e5c346bc218ca6 0 1569404663520 4 connected
41591f7b35be3e5aa89320c0927e83ec915faac6 192.168.152.193:6002@16002 slave 8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859 0 1569404665032 5 connected
```

**字段从左至右分别是**

节点ID、IP地址和端口，节点角色标志、最后发送ping时间、最后接收到pong时间、连接状态、节点负责处理的hash slot。

集群可以自动识别出ip/port的变化，并通过Gossip（最终一致性，分布式服务数据同步算法）协议广播给其他节点知道。Gossip也称“病毒感染算法”、“谣言传播算法”

#### 6、 验证集群

```shell
127.0.0.1:6001> set name redis
-> Redirected to slot [5798] located at 192.168.152.194:6001
OK
192.168.152.194:6001> quit
[root@redis01 ~]# redis-cli -c -p 6002
127.0.0.1:6002> get name
-> Redirected to slot [5798] located at 192.168.152.194:6001
"redis"
```

 登录测试

```shell
[root@redis01 ~]# redis-cli -h 192.168.152.198 -p 6002
```

#### 7、检查节点状态

```shell
[root@redis65 bin]# redis-cli --cluster check 192.168.152.198:6001
192.168.152.198:6001 (8abc8b5c...) -> 0 keys | 5461 slots | 1 slaves.
192.168.152.193:6001 (9c0c3aac...) -> 0 keys | 5461 slots | 1 slaves.
192.168.152.194:6001 (60225e83...) -> 1 keys | 5462 slots | 1 slaves.
[OK] 1 keys in 3 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 192.168.152.198:6001)
M: 8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859 192.168.152.198:6001
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
M: 9c0c3aac2787af4824110bed08e5c346bc218ca6 192.168.152.193:6001
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: 60225e8398b1c6cf609ca27c63d968befbf5e3ee 192.168.152.194:6001
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 41591f7b35be3e5aa89320c0927e83ec915faac6 192.168.152.193:6002
   slots: (0 slots) slave
   replicates 8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859
S: 41ffe24a976c1698590e739a95c7b221d406ca75 192.168.152.198:6002
   slots: (0 slots) slave
   replicates 60225e8398b1c6cf609ca27c63d968befbf5e3ee
S: 255a59264a7fd7daef67ba1180ba0458a593b28b 192.168.152.194:6002
   slots: (0 slots) slave
   replicates 9c0c3aac2787af4824110bed08e5c346bc218ca6
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

#### 8、查看集群信息

```shell
[root@redis65 bin]# redis-cli -c -p 6002
127.0.0.1:6003> cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:6
cluster_my_epoch:5
cluster_stats_messages_ping_sent:1544
cluster_stats_messages_pong_sent:1577
cluster_stats_messages_meet_sent:3
cluster_stats_messages_sent:3124
cluster_stats_messages_ping_received:1574
cluster_stats_messages_pong_received:1547
cluster_stats_messages_meet_received:3
cluster_stats_messages_received:3124
```

#### 9、redis cluster 集群加上认证

##### 1、登录到 redis 节点设置登录验证

```shell
[root@redis01 ~]# redis-cli -h 192.168.152.193 -p 6001 -c
192.168.152.193:6001> config set masterauth redispws
OK
192.168.152.193:6001> config set requirepass redispws
OK
192.168.152.193:6001> auth redispws
OK
192.168.152.193:6001> config rewrite
OK

[root@redis02 bin]# ./redis-cli -h 192.168.152.194 -p 6001 -c
192.168.152.194:6001> config set masterauth redispws
OK
192.168.152.194:6001> config set requirepass redispws
OK
192.168.152.194:6001> auth redispws
OK
192.168.152.194:6001> config rewrite
OK

[root@redis03 bin]# ./redis-cli -h 192.168.152.198 -p 6001 -c
192.168.152.198:6001> config set masterauth redispws
OK
192.168.152.198:6001> config set requirepass redispws
OK
192.168.152.198:6001> auth redispws
OK
192.168.152.198:6001> config rewrite
OK
```

各个节点都完成上面的3条config操作，重启redis各节点，看下各节点的redis.conf，可以发现最后多了3行内容

```shell
[root@redis01 ~]# yum -y install psmisc
[root@redis01 ~]# killall redis-server
[root@redis01 ~]# /usr/local/redis-cluster/start-redis-cluster.sh
[root@redis01 ~]# cat /redis/6001/conf/redis.conf 
bind 0.0.0.0
protected-mode no
port 6001
daemonize yes
dir "/redis/6001/data"
cluster-enabled yes
cluster-config-file "/redis/6001/conf/nodes.conf"
cluster-node-timeout 5000
appendonly yes
pidfile "/redis/6001/redis.pid"
logfile "/redis/6001/log/redis.log"
# Generated by CONFIG REWRITE
masterauth "redispws"
requirepass "redispws"
```

##### 2、通过认证登录 redis

```shell
[root@redis01 ~]# redis-cli -h 192.168.152。193 -p 6001 -c -a 'redispws' 
```

## 三、Redis Cluster 的客户端扩展

### 1、安装PHP7版本及php-fpm，php-redis，hiredis，swoole 扩展

#### 1、更换 yum 源

```shell
[root@web ~]# rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
[root@web ~]# rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
```

#### 2、查看 php 信息

```shell
[root@web ~]# yum search php71w
```

#### 3、安装 php7.1 以及扩展

```shell
[root@web ~]# yum -y install php71w php71w-fpm php71w-cli php71w-common php71w-devel php71w-gd php71w-pdo php71w-mysql php71w-mbstring php71w-bcmath
```

#### 4、检查 PHP 版本

```shell
[root@web ~]# php -v
```

#### 5、安装 swoole 扩展

##### 1、下载 swoole 源码

```shell
[root@web ~]# wget http://git.oschina.net/swoole/swoole
```

##### 2、编译和安装 swoole

```shell
[root@web ~]# cd swoole
[root@web ~]# phpize (ubuntu 没有安装phpize可执行命令：sudo apt-get install php-dev来安装phpize)
[root@web ~]# ./configure
[root@web ~]# make
[root@web ~]# make install
```

　除了手工下载编译外，还可以通过`PHP`官方提供的`pecl`命令，一键下载安装

```shell
[root@web ~]# pecl install swoole
```

#### 6、安装 php-redis 扩展

```shell
[root@web ~]# yum install redis php-redis
```

#### 7、安装异步 hiredis

```shell
[root@web ~]# yum install hiredis-devel
```

#### 8、配置 php.ini

编译安装成功后，修改`php.ini`加入 

```shell
[root@web ~]# vim /etc/php.ini
extension=redis.so
extension=swoole.so

# 通过php -m或phpinfo()来查看是否成功加载了swoole.so，如果没有可能是php.ini的路径不对，可以使用php --ini来定位到php.ini的绝对路径
```

#### 9、安装 php-fpm 扩展

##### 1、安装 php71-fpm

​      上面已经用 yum 安装过了就不必再次安装

##### 2、创建web用户组及用户　

```shell
[root@web ~]# groupadd www-data
[root@web ~]# useradd -g www-data www-data
```

##### 3、修改 php-fpm 配置 

改如下配置：

```shell
[root@web ~]# vim /etc/php-fpm/www.conf
user=www-data
group=www-data

# 将listen = 127.0.0.1:9000改为：
listen = /var/run/php-fpm/php-fpm.sock
listen.backlog=511 开启

# 将 /var/run/php-fpm/php-fpm.sock  文件的属组改成 www-data
[root@web ~]# chown -R www-data.www-data /var/run/php-fpm/php-fpm.sock
```

##### 4、修改 nginx 配置  

```shell
[root@web ~]# vim /etc/nginx/nginx.conf
use www-data www-data;
# 整合nginx和 php-fpm
# 添加以下内容
location ~ \.php$ {       
     fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;       
     fastcgi_index index.php;       
     fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;        
     include fastcgi_params;   
 }

# 重启nginx
systemctl reload nginx
# 创建 index.php
[root@web ~]# vim /usr/share/nginx/html/index.php
<?php
  echo phpinfo();
?>
```

##### 5、重启 php-fpm

```shell
[root@web ~]# systemctl restart php-fpm.service
```

##### 6、验证 redis 扩展是否安装成功

 浏览器访问 http://192.168.152.193/index.php

![360截图16251112729856](assets/360截图16251112729856.png)

#####  7、通过php连接测试连接单节点redis

```php
[root@web ~]# vim /usr/share/nginx/html/redis.php
<?php
    //连接192.168.5.65的Redis服务
   $redis = new Redis();
   $redis->connect('192.168.5.65', 6001);
   $redis->auth('zxc789'); //redis认证
   echo "Connection to server sucessfully";
         //查看服务是否运行
   echo "Server is running: " . $redis->ping();
?> 
```

执行脚本或浏览器访问，输出结果为：

```php
Connection to server sucessfully Server is running: PONG
```

**6、PHP 要操作 redis cluster集群有两种方式**：

#####   1、phpredis 扩展

​        这是个c扩展，性能更高，但是这个方案参考资料很少

#####   2、predis 扩展 

​        纯 php 开发，使用了命名空间，需要php5.3+，灵活性高,我这里用的是predis，下载地址https://github.com/nrk/predis

```shell
[root@web ~]# git clone https://github.com/nrk/predis.git
# 将 predis 放到网站根目录下
[root@web ~]# mv predis /usr/share/nginx/html/
[root@web ~]# cd /usr/share/nginx/html/ 
```

##### 3、配置测试 redis cluster

```php
[root@web ~]# cat predis.php
<?php
require 'predis/autoload.php';//引入predis相关包  
//redis实例  
$servers = array(
    'tcp://192.168.152.193:6001',
    'tcp://192.168.152.193:6002',
    'tcp://192.168.152.194:6001',
    'tcp://192.168.152.194:6002',
    'tcp://192.168.152.198:6001',
    'tcp://192.168.152.198:6002',
);
$options = ['cluster' =>'redis','parameters' => [
        'password' => 'redispws'
    ]];
$client = new Predis\Client($servers,$options);
$client->set('name1', '1111111');
$client->set('name2', '2222222');
$client->set('name3', '3333333');
$name1 = $client->get('name1');
$name2 = $client->get('name2');
$name3 = $client->get('name3');
var_dump($name1, $name2, $name3);die;
?>
```

#####  4、浏览器访问验证

http://192.168.152.193/predis.php

![360截图1818071597103143](assets/360截图1818071597103143.png)

### 2、Java 操作 Redis ，redis cluster集群

##### 1、jedis 连接redis（单机）

​    使用jedis如何操作redis，但是其实方法是跟redis的操作大部分是相对应的。

  所有的redis命令都对应jedis的一个方法 

######     1、在macen工程中引入jedis的jar包     

```xml
       <dependency>
          <groupId>redis.clients</groupId>
          <artifactId>jedis</artifactId>
       </dependency>
```

######      2、建立测试工程

```java
public class JedisTest {

    @Test
    public void testJedis()throws Exception{
        Jedis jedis = new Jedis("192.168.241.133",6379);
        jedis.set("test", "my forst jedis");
        String str = jedis.get("test");
        System.out.println(str);
        jedis.close();
    }
}
```

######       3.点击运行

​         若报下面连接超时，则须关闭防火墙（命令 service iptables stop）

​              ![img](assets/1160766-20180704150117340-1421278273.png)

​                再次运行

​               ![img](assets/1160766-20180704150236583-664350688.png)

​               每次连接需要创建一个连接、执行完后就关闭，非常浪费资源，所以使用jedispool（连接池）连接 

##### 2、jedisPool 连接redis （单机）

```java
@Test
    public void testJedisPool()throws Exception{
        //创建连接池对象
        JedisPool jedispool = new JedisPool("192.168.241.133",6379);
        //从连接池中获取一个连接
        Jedis  jedis = jedispool.getResource(); 
        //使用jedis操作redis
        jedis.set("test", "my forst jedis");
        String str = jedis.get("test");
        System.out.println(str);
        //使用完毕 ，关闭连接，连接池回收资源
        jedis.close();
        //关闭连接池
        jedispool.close();
    }
```

##### 3、jedisCluster 连接redis（集群）

​      jedisCluster专门用来连接redis集群 

​      jedisCluster在单例存在的

```java
@Test
    public void testJedisCluster()throws Exception{
        //创建jedisCluster对象，有一个参数 nodes是Set类型，Set包含若干个HostAndPort对象
        Set<HostAndPort> nodes = new HashSet<>();
        nodes.add(new HostAndPort("192.168.241.133",7001));
        nodes.add(new HostAndPort("192.168.241.133",7002));
        nodes.add(new HostAndPort("192.168.241.133",7003));
        nodes.add(new HostAndPort("192.168.241.133",7004));
        nodes.add(new HostAndPort("192.168.241.133",7005));
        nodes.add(new HostAndPort("192.168.241.133",7006));
        JedisCluster jedisCluster = new JedisCluster(nodes);
        //使用jedisCluster操作redis
        jedisCluster.set("test", "my forst jedis");
        String str = jedisCluster.get("test");
        System.out.println(str);
        //关闭连接池
        jedisCluster.close();
    }
```

​      进集群服务器查看值

​       ![img](assets/1160766-20180704153138036-118807257.png)

 

## 四、Redis Cluster 操作命令行

### 1、集群 cluster

```shell
1. CLUSTER INFO 打印集群的信息  
2. CLUSTER NODES 列出集群当前已知的所有节点（node），以及这些节点的相关信息。
```

### 2、节点node

```shell
1. CLUSTER MEET <ip> <port>  将 ip 和 port 所指定的节点添加到集群当中，让它成为集群的一份子。  
2. CLUSTER FORGET <node_id>  从集群中移除 node_id 指定的节点。  
3. CLUSTER REPLICATE <node_id> 将当前节点设置为 node_id 指定的节点的从节点。  
4. CLUSTER SAVECONFIG  将节点的配置文件保存到硬盘里面。
```

### 3、槽 slot

```shell
1. CLUSTER ADDSLOTS <slot> [slot ...] 将一个或多个槽（slot）指派（assign）给当前节点。  
2. CLUSTER DELSLOTS <slot> [slot ...] 移除一个或多个槽对当前节点的指派。  
3. CLUSTER FLUSHSLOTS 移除指派给当前节点的所有槽，让当前节点变成一个没有指派任何槽的节点。  
4. CLUSTER SETSLOT <slot> NODE <node_id> 将槽 slot 指派给 node_id 指定的节点，如果槽已经指派给另一个节点，那么先让另一个节点删除该槽>，然后再进行指派。  
5. CLUSTER SETSLOT <slot> MIGRATING <node_id> 将本节点的槽 slot 迁移到 node_id 指定的节点中。  
6. CLUSTER SETSLOT <slot> IMPORTING <node_id> 从 node_id 指定的节点中导入槽 slot 到本节点。  
7. CLUSTER SETSLOT <slot> STABLE 取消对槽 slot 的导入（import）或者迁移（migrate）。
```

### 4、键 key  

```shell
1. CLUSTER KEYSLOT <key> 计算键 key 应该被放置在哪个槽上。  
2. CLUSTER COUNTKEYSINSLOT <slot> 返回槽 slot 目前包含的键值对数量。  
3. CLUSTER GETKEYSINSLOT <slot> <count> 返回 count 个 slot 槽中的键
```

## 五、Redis Cluster 集群管理

### 1，添加节点

#### 1、创建实例目录

```shell
[root@redis01 ~]# mkdir -p /redis/{6003,6004}/{conf,data,log}
```

#### 2、redis01 6003 配置文件

```shell
[root@redis01 conf]# sed 's/6001/6003/g' redis.conf > /redis/6003/conf/redis.conf
[root@redis01 conf]# sed 's/6001/6004/g' redis.conf > /redis/6004/conf/redis.conf
```

#### 3、启动脚本 start-redis-cluster.sh

```shell
[root@redis01 ~]# cat >/usr/local/redis-cluster/start-redis-cluster1.sh<<-EOF
#!/bin/bash
REDIS_HOME=/usr/local/redis-cluster
REDIS_CONF=/redis
\$REDIS_HOME/bin/redis-server \$REDIS_CONF/6003/conf/redis.conf
\$REDIS_HOME/bin/redis-server \$REDIS_CONF/6004/conf/redis.conf
EOF
```

#### 4、添加权限

```shell
[root@redis01 ~]# chmod +x /usr/local/redis-cluster/start-redis-cluster1.sh
```

#### 5、启动 redis

```shell
[root@redis01 ~]# /usr/local/redis-cluster/start-redis-cluster1.sh
```

####  6、查看 redis 启动状态

```shell
[root@redis01 ~]# ss -anput | grep redis
tcp    LISTEN     0      511       *:6001                  *:*                   users:(("redis-server",pid=26980,fd=6))
tcp    LISTEN     0      511       *:6002                  *:*                   users:(("redis-server",pid=26982,fd=6))
tcp    LISTEN     0      511       *:6003                  *:*                   users:(("redis-server",pid=64814,fd=6))
tcp    LISTEN     0      511       *:6004                  *:*                   users:(("redis-server",pid=64816,fd=6))
tcp    LISTEN     0      511       *:16001                 *:*                   users:(("redis-server",pid=26980,fd=9))
tcp    LISTEN     0      511       *:16002                 *:*                   users:(("redis-server",pid=26982,fd=9))
tcp    LISTEN     0      511       *:16003                 *:*                   users:(("redis-server",pid=64814,fd=9))
tcp    LISTEN     0      511       *:16004                 *:*                   users:(("redis-server",pid=64816,fd=9))
```

#### 7、查看 redis 进程启动状态

```shell
[root@redis01 ~]# ps -ef | grep redis
root      26980      1  0 00:20 ?        00:01:54 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6001 [cluster]
root      26982      1  0 00:20 ?        00:02:30 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6002 [cluster]
root      64814      1  0 17:39 ?        00:00:00 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6003 [cluster]
root      64816      1  0 17:39 ?        00:00:00 /usr/local/redis-cluster/bin/redis-server 0.0.0.0:6004 [cluster]
```

#### 8，添加主节点

```shell
[root@redis01 ~]# redis-cli --cluster add-node 192.168.152.193:6003 192.168.152.193:6001 -a redispws
```

注释：

192.168.152.193:6003 是新增的节点

192.168.152.193:6001集群任一个旧节点

查看节点状态

```shell
[root@redis01 ~]# redis-cli -h 192.168.152.193 -p 6003 -a redispws
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
192.168.152.193:6003> cluster nodes
9c0c3aac2787af4824110bed08e5c346bc218ca6 192.168.152.193:6001@16001 master - 0 1569578158000 1 connected 0-5460
60225e8398b1c6cf609ca27c63d968befbf5e3ee 192.168.152.194:6001@16001 master - 0 1569578158000 3 connected 5461-10922
41ffe24a976c1698590e739a95c7b221d406ca75 192.168.152.198:6002@16002 slave 60225e8398b1c6cf609ca27c63d968befbf5e3ee 0 1569578157584 6 connected
255a59264a7fd7daef67ba1180ba0458a593b28b 192.168.152.194:6002@16002 slave 9c0c3aac2787af4824110bed08e5c346bc218ca6 0 1569578157000 4 connected
8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859 192.168.152.198:6001@16001 master - 0 1569578158992 5 connected 10923-16383
41591f7b35be3e5aa89320c0927e83ec915faac6 192.168.152.193:6003@16003 myself,slave 8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859 0 1569578158000 2 connected
```

#### 9，添加从节点

```shell
[root@redis01 ~]# redis-cli --cluster add-node 192.168.152.193:6004 192.168.152.193:6001 --cluster-slave -a 'redispws'
```

注释：

--cluster-slave 表示添加从节点

192.168.152.193:6004 新节点

192.168.152.193:6001 集群任一个旧节点

查看集群节点状态

```shell
[root@redis01 ~]# redis-cli -h 192.168.152.193 -p 6004 -a redispws
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
192.168.152.193:6004> cluster node
(error) ERR Unknown subcommand or wrong number of arguments for 'node'. Try CLUSTER HELP.
192.168.152.193:6004> cluster nodes
41ffe24a976c1698590e739a95c7b221d406ca75 192.168.152.198:6002@16002 slave 60225e8398b1c6cf609ca27c63d968befbf5e3ee 0 1569579181151 3 connected
60225e8398b1c6cf609ca27c63d968befbf5e3ee 192.168.152.194:6001@16001 master - 0 1569579180547 3 connected 5461-10922
9c0c3aac2787af4824110bed08e5c346bc218ca6 192.168.152.193:6001@16001 master - 0 1569579179037 1 connected 0-5460
255a59264a7fd7daef67ba1180ba0458a593b28b 192.168.152.194:6002@16002 slave 9c0c3aac2787af4824110bed08e5c346bc218ca6 0 1569579179138 1 connected
8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859 192.168.152.198:6001@16001 master - 0 1569579180146 5 connected 10923-16383
41591f7b35be3e5aa89320c0927e83ec915faac6 192.168.152.193:6002@16002 slave 8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859 0 1569579180000 5 connected
0f50f59b6186513f32d77641678e14521d5dc485 192.168.152.193:6004@16004 myself,slave 9c0c3aac2787af4824110bed08e5c346bc218ca6 0 1569579179000 0 connected
```

可以看到6003节点的 connected 后面没有 Hash 槽(slot)，新加入的加点是一个主节点， 当集群需要将某个从节点升级为新的主节点时， 这个新节点不会被选中，也不会参与选举。

#### 10、给新节点分配哈希槽

```shell
#参数192.168.152.193:6001只是表示连接到这个集群，具体对哪个节点进行操作后面会提示输入
[root@redis01 ~]# redis-cli --cluster reshard 192.168.152.193:6001
返回信息：
>>> Performing Cluster Check (using node 192.168.152.193:6001)
M: 9c0c3aac2787af4824110bed08e5c346bc218ca6 192.168.152.193:6001
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: 0f50f59b6186513f32d77641678e14521d5dc485 192.168.152.193:6004
   slots: (0 slots) slave
   replicates 9c0c3aac2787af4824110bed08e5c346bc218ca6
S: 41591f7b35be3e5aa89320c0927e83ec915faac6 192.168.152.193:6003
   slots: (0 slots) slave
   replicates 8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859
M: 60225e8398b1c6cf609ca27c63d968befbf5e3ee 192.168.152.194:6001
   slots:[5461-10922] (5462 slots) master
M: 8abc8b5c438e34d345b76cd7eda7d0a7e9dd9859 192.168.152.198:6001
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.

#根据提示选择要迁移的slot数量(这里选择1000)
How many slots do you want to move (from 1 to 16384)? 1000

#选择要接受这些slot的node-id(这里是7003)
What is the receiving node ID? a70d7fff6d6dde511cb7cb632a347be82dd34643

# 选择slot来源:
# all表示从所有的master重新分配，
# 或者数据要提取slot的master节点id(这里是7000),最后用done结束
Please enter all the source node IDs.
  Type 'all' to use all the nodes as source nodes for the hash slots.
  Type 'done' once you entered all the source nodes IDs.
Source node #1:3bcdfbed858bbdd92dd760632b9cb4c649947fed
Source node #2:done
# 打印被移动的 slot后，输入yes开始移动slot以及对应的数据.
Do you want to proceed with the proposed reshard plan (yes/no)? yes
#结束
# 查看确认
[root@redis01 ~]# redis-cli -h 192.168.152.193 -p 6004 -a redispws
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
192.168.152.193:6004> cluster nodes
```

#### 11、删除一个Master节点

删除master节点之前首先要使用reshard移除master的全部slot,然后再删除当前节点(目前只能把被删除master的slot迁移到一个节点上)

```bash
[root@redis01 ~]# redis-cli --cluster reshard 192.168.152.193:6001
#根据提示选择要迁移的slot数量(7003上有1000个slot全部转移)
How many slots do you want to move (from 1 to 16384)? 1000
#选择要接受这些slot的node-id
What is the receiving node ID? 3bcdfbed858bbdd92dd760632b9cb4c649947fed
#选择slot来源:
#all表示从所有的master重新分配，
#或者数据要提取slot的master节点id,最后用done结束
Please enter all the source node IDs.
  Type 'all' to use all the nodes as source nodes for the hash slots.
  Type 'done' once you entered all the source nodes IDs.
Source node #1:a70d7fff6d6dde511cb7cb632a347be82dd34643
Source node #2:done
#打印被移动的slot后，输入yes开始移动slot以及对应的数据.
#Do you want to proceed with the proposed reshard plan (yes/no)? yes
#结束

#删除空master节点
[root@redis01 ~]# redis-cli --cluster del-node 192.168.152.193:6001 'a70d7fff6d6dde511cb7cb632a347be82dd34643'
```

#### 12、删除一个Slave节点

```bash
[root@redis01 ~]# redis-cli --cluster del-node ip:port '<node-id>'
#这里移除的是6004
./redis-cli --cluster del-node 192.168.152.193:6002 74957282ffa94c828925c4f7026baac04a67e291
返回信息：
>>> Removing node 74957282ffa94c828925c4f7026baac04a67e291 from cluster 192.168.152.193:6001
>>> Sending CLUSTER FORGET messages to the cluster...
>>> SHUTDOWN the node.
```