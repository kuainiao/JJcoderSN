# mysql 配置文件详解

------

# Mysql配置文件my.cnf配置及配置参数详解

> 以下是Mysql主配文件my.cnf参数和详解：

```yml
# Example MySQL config file for very large systems.
#
#下面的配置参数适用于512M内存的服务器。
#
# You can copy this file to
# /etc/my.cnf to set global options,
# mysql-data-dir/my.cnf to set server-specific options (in this
# installation this directory is /data/mysql/data) or
# ~/.my.cnf to set user-specific options.
#
# In this file, you can use all long options that a program supports.
# If you want to know which options a program supports, run the program
# with the "--help" option.

# The following options will be passed to all MySQL clients
[client]
#password = your_password
port  = 3306
socket  = /tmp/mysql.sock

# Here follows entries for some specific programs

# The MySQL server
[mysqld]
user            = mysql
port            = 3306
socket          = /tmp/mysql.sock
basedir         = /usr/local/webserver/mysql
datadir         = /data/mysqldata/database
log-error       = /data/mysqldata/log/mysql_error.log
pid-file        = /data/mysqldata/pid/mysql.pid
```



## BDB 相关选项

> 如果你运行的MySQL服务有BDB支持但是你不准备使用的时候使用此选项. 这会节省内存并且可能加速一些事.

skip-bdb

> 避免MySQL的外部锁定，减少出错几率增强稳定性。

skip-locking

> 禁止MySQL对外部连接进行DNS解析，使用这一选项可以消除MySQL进行DNS解析的时间。但需要注意，如果开启该选项，则所有远程主机连接授权都要使用IP地址方式，否则MySQL将无法正常处理连接请求!

skip-name-resolve

> 当创建新表时作为默认使用的表类型, 如果在创建表示没有特别执行表类型,将会使用此值 mysql是默认支持4种存储引擎：CSV,MRG_MYISAM,MEMORY,MyISAM,默认不支持InnoDB存储引擎（消耗内存比较大）.由于内存很小,推荐使用MyISAM存储引擎.

default_table_type = MyISAM

> 设定默认的事务隔离级别,可用的级别:READ-UNCOMMITTED, READ-COMMITTED, REPEATABLE-READ, SERIALIZABLE

transaction_isolation = READ-UNCOMMITTED

> 限制mysqld能打开文件的最大个数,取值：max_connections*5 或者 max_connections + table_cache*2

open_files_limit = 600

> back_log 是操作系统在监听队列中所能保持的连接数,队列保存了在MySQL连接管理器线程处理之前的连接.如果你有非常高的连接率并且出现”connection refused” 报错,你就应该增加此处的值.检查你的操作系统文档来获取这个变量的最大值.如果将back_log设定到比你操作系统限制更高的值,将会没有效果。

## 系统参数变量使用

back_log = 40

> 关键词缓冲的大小, 一般用来缓冲MyISAM表的索引块.不要将其设置大于你可用内存的30%,因为一部分内存同样被OS用来缓冲行数据，甚至在你并不使用MyISAM 表的情况下, 你也需要仍旧设置起 8-64M 内存由于它同样会被内部临时磁盘表使用.

key_buffer_size = 32M

> 服务所能处理的请求包的最大大小以及服务所能处理的最大的请求大小(当与大的BLOB字段一起工作时相当必要)，每个连接独立的大小.大小动态增加

max_allowed_packet = 16M

> 线程使用的堆大小。此容量的内存在每次连接时被预留.MySQL 本身常不会需要超过64K的内存，如果你使用你自己的需要大量堆的UDF函数，或者你的操作系统对于某些操作需要更多的堆，你也许需要将其设置的更高一点。

thread_stack = 192K

> 所有线程所打开表的数量。增加此值就增加了mysqld所需要的文件描述符的数量。这样你需要确认在[mysqld_safe]中 “open-files-limit” 变量设置打开文件数量允许至少4096。

table_cache = 60

> 允许外部文件级别的锁。打开文件锁会对性能造成负面影响。所以只有在你在同样的文件上运行多个数据库实例时才使用此选项(注意仍会有其他约束!)。或者你在文件层面上使用了其他一些软件依赖来锁定MyISAM表

external-locking = FALSE

> 排序缓冲被用来处理类似ORDER BY以及GROUP BY队列所引起的排序，如果排序后的数据无法放入排序缓冲， 一个用来替代的基于磁盘的合并分类会被使用，查看 “Sort_merge_passes” 状态变量。在排序发生时由每个线程分配。

sort_buffer_size = 256K

> 用来做MyISAM表全表扫描的缓冲大小。当全表扫描需要时,在对应线程中分配。

read_buffer_size = 1M

> 此缓冲被使用来优化全联合(full JOINs 不带索引的联合)，类似的联合在极大多数情况下有非常糟糕的性能表现。但是将此值设大能够减轻性能影响。通过 “Select_full_join” 状态变量查看全联合的数量。当全联合发生时,在每个线程中分配

join_buffer_size = 256K

> 当在排序之后,从一个已经排序好的序列中读取行时,行数据将从这个缓冲中读取来防止磁盘寻道。如果你增高此值,可以提高很多ORDER BY的性能。当需要时由每个线程分配。

read_rnd_buffer_size = 4M

> MyISAM 使用特殊的类似树的cache来使得突发插入 (这些插入是,INSERT … SELECT, INSERT … VALUES (…), (…), …, 以及 LOAD DATA INFILE) 更快。此变量限制每个进程中缓冲树的字节数。设置为 0 会关闭此优化。为了最优化不要将此值设置大于 “key_buffer_size”。当突发插入被检测到时此缓冲将被分配。

bulk_insert_buffer_size = 2M

> 此缓冲当MySQL需要在 REPAIR, OPTIMIZE, ALTER 以及 LOAD DATA INFILE 到一个空表中引起重建索引时被分配。这在每个线程中被分配.所以在设置大值时需要小心。

myisam_sort_buffer_size = 4M

> MySQL重建索引时所允许的最大临时文件的大小 (当 REPAIR, ALTER TABLE 或者 LOAD DATA INFILE)。如果文件大小比此值更大,索引会通过键值缓冲创建(更慢)

myisam_max_sort_file_size = 10G

> 如果被用来更快的索引创建索引所使用临时文件大于制定的值,那就使用键值缓冲方法。这主要用来强制在大表中长字串键去使用慢速的键值缓冲方法来创建索引。

myisam_max_extra_sort_file_size = 10G

> 如果一个表拥有超过一个索引, MyISAM 可以通过并行排序使用超过一个线程去修复他们。这对于拥有多个CPU以及大量内存情况的用户,是一个很好的选择。

myisam_repair_threads = 1

> 自动检查和修复没有适当关闭的 MyISAM 表.

myisam_recover

thread_cache = 128

> 我们在cache中保留多少线程用于重用，当一个客户端断开连接后,如果cache中的线程还少于thread_cache_size。则客户端线程被放入cache中。这可以在你需要大量新连接的时候极大的减少线程创建的开销。(一般来说如果你有好的线程模型的话,这不会有明显的性能提升.)

thread_cache_size = 10

> 查询缓冲常被用来缓冲 SELECT 的结果并且在下一次同样查询的时候不再执行直接返回结果。打开查询缓冲可以极大的提高服务器速度, 如果你有大量的相同的查询并且很少修改表。查看 “Qcache_lowmem_prunes” 状态变量来检查是否当前值对于你的负载来说是否足够高。注意: 在你表经常变化的情况下或者如果你的查询原文每次都不同。查询缓冲也许引起性能下降而不是性能提升。

query_cache_size = 0M

> 只有小于此设定值的结果才会被缓冲，此设置用来保护查询缓冲,防止一个极大的结果集将其他所有的查询结果都覆盖.

query_cache_limit = 2M

query_cache_min_res_unit = 4K

> 内部(内存中)临时表的最大大小，如果一个表增长到比此值更大,将会自动转换为基于磁盘的表。此限制是针对单个表的,而不是总和.

tmp_table_size = 512K

> 独立的内存表所允许的最大容量。此选项为了防止意外创建一个超大的内存表导致永尽所有的内存资源.

max_heap_table_size = 32M

> 所有的使用了比这个时间(以秒为单位)更多的查询会被认为是慢速查询。不要在这里使用”1″, 否则会导致所有的查询,甚至非常快的查询页被记录下来(由于MySQL 目前时间的精确度只能达到秒的级别)。

ong_query_time = 1

> 在慢速日志中记录更多的信息。一般此项最好打开。打开此项会记录使得那些没有使用索引的查询也被作为到慢速查询附加到慢速日志里

log_long_format

> MySQL 服务所允许的同时会话数的上限，其中一个连接将被SUPER权限保留作为管理员登录。 即便已经达到了连接数的上限.

max_connections = 200

> 指定一个请求的最大连接时间。

wait_timeout = 30

> 每个客户端连接最大的错误允许数量,如果达到了此限制。这个客户端将会被MySQL服务阻止直到执行了”FLUSH HOSTS” 或者服务重启，非法的密码以及其他在链接时的错误会增加此值。查看 “Aborted_connects” 状态来获取全局计数器.

max_connect_errors = 200

expire_logs_days = 7

> Try number of CPU's*2 for thread_concurrency 此允许应用程序给予线程系统一个提示在同一时间给予渴望被运行的线程的数量。此值只对于支持 thread_concurrency() 函数的系统有意义( 例如Sun Solaris)。你可可以尝试使用 [CPU数量]*(2..4) 来作为thread_concurrency的值*

thread_concurrency = 8

> Don't listen on a TCP/IP port at all. This can be a security enhancement,

```yml
# if all processes that need to connect to mysqld run on the same host.
# All interaction with mysqld must be made via Unix sockets or named pipes.
# Note that using this option without enabling named pipes on Windows
# (via the "enable-named-pipe" option) will render mysqld useless!
```

skip-networking

> 默认关闭 Federated

skip-federated

> Replication Master Server (default)

```yml
# binary logging is required for replication
#log-bin=mysql-bin
#在一个事务中binlog为了记录SQL状态所持有的cache大小，如果你经常使用大的,多声明的事务,你可以增加此值来获取更大的性能。所有从事务来的状态都将被缓冲在binlog缓冲中然后在提交后一次性写入到binlog中。如果事务比此值大, 会使用磁盘上的临时文件来替代。此缓冲在每个连接的事务第一次更新状态时被创建
```

binlog_cache_size = 2M

max_binlog_cache_size = 4M max_binlog_size = 512M

> 唯一的服务辨识号,数值位于 1 到 2^32-1之间。此值在master和slave上都需要设置。如果 “master-host” 没有被设置,则默认为1, 但是如果忽略此选项,MySQL不会作为master生效.

server-id = 1

```yml
 Replication Slave (comment out master section to use this)
# To configure this host as a replication slave, you can choose between
# two methods :
#
# 1) Use the CHANGE MASTER TO command (fully described in our manual) -
#    the syntax is:
#
#    CHANGE MASTER TO MASTER_HOST=<host>, MASTER_PORT=<port>,
#    MASTER_USER=<user>, MASTER_PASSWORD=<password> ;
#
#    where you replace <host>, <user>, <password> by quoted strings and
#    <port> by the master's port number (3306 by default).
#
#    Example:
#
#    CHANGE MASTER TO MASTER_HOST='125.564.12.1', MASTER_PORT=3306,
#    MASTER_USER='joe', MASTER_PASSWORD='secret';
#
# OR
#
# 2) Set the variables below. However, in case you choose this method, then
#    start replication for the first time (even unsuccessfully, for example
#    if you mistyped the password in master-password and the slave fails to
#    connect), the slave will create a master.info file, and any later
#    change in this file to the variables' values below will be ignored and
#    overridden by the content of the master.info file, unless you shutdown
#    the slave server, delete master.info and restart the slaver server.
#    For that reason, you may want to leave the lines below untouched
#    (commented) and instead use CHANGE MASTER TO (see above)
#
# required unique id between 2 and 2^32 - 1
# (and different from the master)
# defaults to 2 if master-host is set
# but will not function as a slave if omitted
#server-id       = 2
#
# The replication master for this slave - required
#master-host     =   <hostname>
#
# The username the slave will use for authentication when connecting
# to the master - required
#master-user     =   <username>
#
# The password the slave will authenticate with when connecting to
# the master - required
#master-password =   <password>
#
# The port the master is listening on.
# optional - defaults to 3306
#master-port     =  <port>
#
# binary logging - not required for slaves, but recommended
#log-bin=mysql-bin
#
# binary logging format - mixed recommended
#binlog_format=mixed
```



> Point the following paths to different dedicated disks

```yml
#tmpdir  = /tmp/
#log-update  = /path-to-dedicated-directory/hostname
```

## innodb 相关

> Uncomment the following if you are using InnoDB tables

```yml
#innodb_data_home_dir = /data/mysql/data/
#innodb_data_file_path = ibdata1:2000M;ibdata2:10M:autoextend
#innodb_log_group_home_dir = /data/mysql/data/
#innodb_log_arch_dir = /data/mysql/data/
```

> You can set .._buffer_pool_size up to 50 - 80 % of RAM but beware of setting memory usage too high

```yml
innodb_buffer_pool_size = 384M
innodb_additional_mem_pool_size = 20M
```

> Set .._log_file_size to 25 % of buffer pool size

```yml
#innodb_log_file_size = 100M
#innodb_log_buffer_size = 8M
#innodb_flush_log_at_trx_commit = 1
#innodb_lock_wait_timeout = 50
```

[mysqldump]

> 不要在将内存中的整个结果写入磁盘之前缓存. 在导出非常巨大的表时需要此项

```yml
quick
max_allowed_packet = 16M
```

[mysql] no-auto-rehash

> 根据需求修改参数值，然后保存为/etc/my.cnf文件。 初始化mysql数据库

```yml
 /usr/local/webserver/mysql/bin/mysql_install_db \
--basedir=/usr/local/webserver/mysql \
--datadir=/data/mysqldata/database \
--user=mysql
```



> 最后在说下启动和关闭mysql服务器

```yml
# /usr/local/webserver/mysql/bin/mysqld_safe --user=mysql & //启动服务
# /usr/local/webserver/mysql/bin/mysqladmin -u root -p shutdown //停止服务
```