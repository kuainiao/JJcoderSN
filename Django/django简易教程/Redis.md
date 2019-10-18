redis教程：
概述
redis是一种nosql数据库,他的数据是保存在内存中，同时redis可以定时把内存数据同步到磁盘，即可以将数据持久化，并且他比memcached支持更多的数据结构(string,list列表[队列和栈],set[集合],sorted set[有序集合],hash(hash表))。相关参考文档：http://redisdoc.com/index.html

redis使用场景：
登录会话存储：存储在redis中，与memcached相比，数据不会丢失。
排行版/计数器：比如一些秀场类的项目，经常会有一些前多少名的主播排名。还有一些文章阅读量的技术，或者新浪微博的点赞数等。
作为消息队列：比如celery就是使用redis作为中间人。
当前在线人数：还是之前的秀场例子，会显示当前系统有多少在线人数。
一些常用的数据缓存：比如我们的BBS论坛，板块不会经常变化的，但是每次访问首页都要从mysql中获取，可以在redis中缓存起来，不用每次请求数据库。
把前200篇文章缓存或者评论缓存：一般用户浏览网站，只会浏览前面一部分文章或者评论，那么可以把前面200篇文章和对应的评论缓存起来。用户访问超过的，就访问数据库，并且以后文章超过200篇，则把之前的文章删除。
好友关系：微博的好友关系使用redis实现。
发布和订阅功能：可以用来做聊天软件。
redis和memcached的比较：
memcached	redis
类型	纯内存数据库	内存磁盘同步数据库
数据类型	在定义value时就要固定数据类型	不需要
虚拟内存	不支持	支持
过期策略	支持	支持
存储数据安全	不支持	可以将数据同步到dump.db中
灾难恢复	不支持	可以将磁盘中的数据恢复到内存中
分布式	支持	主从同步
订阅与发布	不支持	支持
redis在ubuntu系统中的安装与启动
安装：
 sudo apt-get install redis-server
卸载：
 sudo apt-get purge --auto-remove redis-server
启动：redis安装后，默认会自动启动，可以通过以下命令查看：

 ps aux|grep redis
如果想自己手动启动，可以通过以下命令进行启动：

 sudo service redis-server start
停止：

 sudo service redis-server stop
对redis的操作
对redis的操作可以用两种方式，第一种方式采用redis-cli，第二种方式采用编程语言，比如Python、PHP和JAVA等。

使用redis-cli对redis进行字符串操作：

启动redis：

  sudo service redis-server start
连接上redis-server：
  redis-cli -h [ip] -p [端口]
添加：

  set key value
  如：
  set username xiaotuo
将字符串值value关联到key。如果key已经持有其他值，set命令就覆写旧值，无视其类型。并且默认的过期时间是永久，即永远不会过期。

删除：

  del key
  如：
  del username
设置过期时间：

  expire key timeout(单位为秒)
也可以在设置值的时候，一同指定过期时间：

  set key value EX timeout
  或：
  setex key timeout value
查看过期时间：

  ttl key
  如：
  ttl username
查看当前redis中的所有key：

  keys *
列表操作：

在列表左边添加元素：

  lpush key value
将值value插入到列表key的表头。如果key不存在，一个空列表会被创建并执行lpush操作。当key存在但不是列表类型时，将返回一个错误。

在列表右边添加元素：

  rpush key value
将值value插入到列表key的表尾。如果key不存在，一个空列表会被创建并执行RPUSH操作。当key存在但不是列表类型时，返回一个错误。

查看列表中的元素：

  lrange key start stop
返回列表key中指定区间内的元素，区间以偏移量start和stop指定,如果要左边的第一个到最后的一个lrange key 0 -1。

移除列表中的元素：

移除并返回列表key的头元素：
  lpop key
移除并返回列表的尾元素：
rpop key
移除并返回列表key的中间元素：

  lrem key count value
将删除key这个列表中，count个值为value的元素。

指定返回第几个元素：

  lindex key index
将返回key这个列表中，索引为index的这个元素。

获取列表中的元素个数：

  llen key
  如：
  llen languages
删除指定的元素：

  lrem key count value
  如：
  lrem languages 0 php
根据参数 count 的值，移除列表中与参数 value 相等的元素。count的值可以是以下几种：

count > 0：从表头开始向表尾搜索，移除与value相等的元素，数量为count。
count < 0：从表尾开始向表头搜索，移除与 value相等的元素，数量为count的绝对值。
count = 0：移除表中所有与value 相等的值。
set集合的操作：

添加元素：
  sadd set value1 value2....
  如：
  sadd team xiaotuo datuo
查看元素：
  smembeers set
  如：
  smembers team
移除元素：
  srem set member...
  如：
  srem team xiaotuo datuo
查看集合中的元素个数：
  scard set
  如：
  scard team1
获取多个集合的交集：
  sinter set1 set2
  如：
  sinter team1 team2
获取多个集合的并集：
  sunion set1 set2
  如：
  sunion team1 team2
获取多个集合的差集：
sdiff set1 set2
如：
sdiff team1 team2
hash哈希操作：

添加一个新值：

  hset key field value
  如：
  hset website baidu baidu.com
将哈希表key中的域field的值设为value。
如果key不存在，一个新的哈希表被创建并进行 HSET操作。如果域 field已经存在于哈希表中，旧值将被覆盖。

获取哈希中的field对应的值：

  hget key field
  如：
  hget website baidu
删除field中的某个field：

  hdel key field
  如：
  hdel website baidu
获取某个哈希中所有的field和value：

  hgetall key
  如：
  hgetall website
获取某个哈希中所有的field：

  hkeys key
  如：
  hkeys website
获取某个哈希中所有的值：

hvals key
如：
hvals website
判断哈希中是否存在某个field：

hexists key field
如：
hexists website baidu
获取哈希中总共的键值对：

hlen field
如：
hlen website
事务操作：Redis事务可以一次执行多个命令，事务具有以下特征：

隔离操作：事务中的所有命令都会序列化、按顺序地执行，不会被其他命令打扰。
原子操作：事务中的命令要么全部被执行，要么全部都不执行。
开启一个事务：

  multi
以后执行的所有命令，都在这个事务中执行的。

执行事务：

  exec
会将在multi和exec中的操作一并提交。

取消事务：

  discard
会将multi后的所有命令取消。

监视一个或者多个key：

  watch key...
监视一个(或多个)key，如果在事务执行之前这个(或这些) key被其他命令所改动，那么事务将被打断。

取消所有key的监视：

  unwatch
发布/订阅操作：

给某个频道发布消息：
  publish channel message
订阅某个频道的消息：
  subscribe channel
持久化：redis提供了两种数据备份方式，一种是RDB，另外一种是AOF，以下将详细介绍这两种备份策略：

| | RDB | AOF | | --- | --- | --- | | 开启关闭 | 开启：默认开启。关闭：把配置文件中所有的save都注释，就是关闭了。 | 开启：在配置文件中appendonly yes即开启了aof，为no关闭。 | | 同步机制 | 可以指定某个时间内发生多少个命令进行同步。比如1分钟内发生了2次命令，就做一次同步。 | 每秒同步或者每次发生命令后同步 | | 存储内容 | 存储的是redis里面的具体的值 | 存储的是执行的更新数据的操作命令 | | 存储文件的路径 | 根据dir以及dbfilename来指定路径和具体的文件名 | 根据dir以及appendfilename来指定具体的路径和文件名 | | 优点 | （1）存储数据到文件中会进行压缩，文件体积比aof小。（2）因为存储的是redis具体的值，并且会经过压缩，因此在恢复的时候速度比AOF快。（3）非常适用于备份。 | （1）AOF的策略是每秒钟或者每次发生写操作的时候都会同步，因此即使服务器故障，最多只会丢失1秒的数据。 （2）AOF存储的是Redis命令，并且是直接追加到aof文件后面，因此每次备份的时候只要添加新的数据进去就可以了。（3）如果AOF文件比较大了，那么Redis会进行重写，只保留最小的命令集合。 | | 缺点 | （1）RDB在多少时间内发生了多少写操作的时候就会出发同步机制，因为采用压缩机制，RDB在同步的时候都重新保存整个Redis中的数据，因此你一般会设置在最少5分钟才保存一次数据。在这种情况下，一旦服务器故障，会造成5分钟的数据丢失。（2）在数据保存进RDB的时候，Redis会fork出一个子进程用来同步，在数据量比较大的时候，可能会非常耗时。 | （1）AOF文件因为没有压缩，因此体积比RDB大。 （2）AOF是在每秒或者每次写操作都进行备份，因此如果并发量比较大，效率可能有点慢。（3）AOF文件因为存储的是命令，因此在灾难恢复的时候Redis会重新运行AOF中的命令，速度不及RDB。 | | 更多 | http://redisdoc.com/topic/persistence.html#redis | |

安全：在配置文件中，设置requirepass password，那么客户端连接的时候，需要使用密码：

 > redis-cli -p 127.0.0.1 -p 6379
 redis> set username xxx
 (error) NOAUTH Authentication required.
 redis> auth password
 redis> set username xxx
 OK
Python操作redis
安装python-redis：

 pip install redis
新建一个文件比如redis_test.py，然后初始化一个redis实例变量，并且在ubuntu虚拟机中开启redis。比如虚拟机的ip地址为192.168.174.130。示例代码如下：

 # 从redis包中导入Redis类
 from redis import Redis
 # 初始化redis实例变量
 xtredis = Redis(host='192.168.174.130',port=6379)
对字符串的操作：操作redis的方法名称，跟之前使用redis-cli一样，现就一些常用的来做个简单介绍，示例代码如下(承接以上的代码)：

 # 添加一个值进去，并且设置过期时间为60秒，如果不设置，则永远不会过期
 xtredis.set('username','xiaotuo',ex=60)
 # 获取一个值
 xtredis.get('username')
 # 删除一个值
 xtredis.delete('username')
 # 给某个值自增1
 xtredis.set('read_count',1)
 xtredis.incr('read_count')  # 这时候read_count变为2
 # 给某个值减少1
 xtredis.decr('read_count') # 这时候read_count变为1
对列表的操作：同字符串操作，所有方法的名称跟使用redis-cli操作是一样的：

 # 给languages这个列表往左边添加一个python
 xtredis.lpush('languages','python')
 # 给languages这个列表往左边添加一个php
 xtredis.lpush('languages','php')
 # 给languages这个列表往左边添加一个javascript
 xtredis.lpush('languages','javascript')

 # 获取languages这个列表中的所有值
 print xtredis.lrange('languages',0,-1)
 > ['javascript','php','python']
对集合的操作：

 # 给集合team添加一个元素xiaotuo
 xtredis.sadd('team','xiaotuo')
 # 给集合team添加一个元素datuo
 xtredis.sadd('team','datuo')
 # 给集合team添加一个元素slice
 xtredis.sadd('team','slice')

 # 获取集合中的所有元素
 xtredis.smembers('team')
 > ['datuo','xiaotuo','slice'] # 无序的
对哈希(hash)的操作：

 # 给website这个哈希中添加baidu
 xtredis.hset('website','baidu','baidu.com')
 # 给website这个哈希中添加google
 xtredis.hset('website','google','google.com')

 # 获取website这个哈希中的所有值
 print xtredis.hgetall('website')
 > {"baidu":"baidu.com","google":"google.com"}
事务(管道)操作：redis支持事务操作，也即一些操作只有统一完成，才能算完成。否则都执行失败，用python操作redis也是非常简单，示例代码如下：

 # 定义一个管道实例
 pip = xtredis.pipeline()
 # 做第一步操作，给BankA自增长1
 pip.incr('BankA')
 # 做第二步操作，给BankB自减少1
 pip.desc('BankB')
 # 执行事务
 pip.execute()
以上便展示了python-redis的一些常用方法，如果想深入了解其他的方法，可以参考python-redis的源代码（查看源代码pycharm快捷键提示：把鼠标光标放在import Redis的Redis上，然后按ctrl+b即可进入）。