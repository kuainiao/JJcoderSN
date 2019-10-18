 在搭建好mysql主从之后，我们一般在从库上通过命令

```sql
show slave status\G
```



 来查看主从的状态，会有很多的参数，接下来笔者就带大家好好的了解这些参数



```sql
root@localhost (none)>show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.1.100
                  Master_User: mysync
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.001822
          Read_Master_Log_Pos: 290072815
               Relay_Log_File: mysqld-relay-bin.005201
                Relay_Log_Pos: 256529594
        Relay_Master_Log_File: mysql-bin.001821
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 256529431
              Relay_Log_Space: 709504534
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 2923
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
                  Master_UUID: 13ee75bb-99e2-11e6-be4d-b499baa80e6e
             Master_Info_File: /home/data/mysql/master.info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Reading event from the relay log
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 0
1 row in set (0.02 sec)
```







**参数详解：**



\1. Slave_IO_State

这里显示了当前slave I/O线程的状态(slave连接到master的状态)。状态信息和使用show processlist | grep "system user"(会显示两条信息，一条slave I/O线程的，一条是slave SQL线程的)显示的内容一样。



slave I/O线程的状态，有以下几种：

​       1) waiting for master update

​           这是connecting to master状态之前的状态

​       2) connecting to master

​          I/O线程正尝试连接到master

​       3) checking master version

​          在与master建立连接后，会出现该状态。该状态出现的时间非常短暂。

​       4) registering slave on master

​          在与master建立连接后，会出现该状态。该状态出现的时间非常短暂。  

​       5) requesting binlog dump

​           在与master建立连接后，会出现该状态。该状态出现的时间非常短暂。在这个状态下，I/O线程向master发送请求，请求binlog，位置从指定的binglog 名字和binglog的position位置开始。

​       6) waiting to reconnect after a failed binlog dump request

​           如果因为连接断开，导致binglog的请求失败，I/O线程会进入睡眠状态。然后定期尝试重连。尝试重连的时间间隔，可以使用命令"change master to master_connect_trt=X;"改变。

​       7) reconnecting after a failed binglog dump request

​           I/O进程正在尝试连接master

​       8) waiting for master to send event

​           说明，已经成功连接到master，正等待二进制日志时间的到达。如果master 空闲，这个状态会持续很长时间。如果等待的时间超过了slave_net_timeout(单位是秒)的值，会出现连接超时。在这种状态下，I/O线程会人为连接失败，并开始尝试重连

​       9) queueing master event to the relay log

​          此时，I/O线程已经读取了一个event，并复制到了relay log 中。这样SQL 线程可以执行此event

​       10) waiting to reconnect after a failed master event read

​          读取时出现的错误(因为连接断开)。在尝试重连之前，I/O线程进入sleep状态，sleep的时间是master_connect_try的值(默认是60秒)

​       11) reconnecting after a failed master event read

​          I/O线程正尝试重连master。如果连接建立，状态会变成"waiting for master to send event"

​       12) waiting for the slave sql thread to free enough relay log space

​         这是因为设置了relay_log_space_limit，并且relay log的大小已经整张到了最大值。I/O线程正在等待SQL线程通过删除一些relay log，来释放relay log的空间。

​       13) waiting for slave mutex on exit

​          I/O线程停止时会出现的状态，出现的时间非常短。



\2. Master_Host: 192.168.1.100

mysql主库的ip地址



\3. Master_User: mysync

这个是master上面的一个用户。用来负责主从复制的用户，创建主从复制的时候建立的（具有reolication slave权限）。



\4. Master_Port: 3306

master服务器的端口  一般是3306



\5. Connect_Retry: 60

连接中断后，重新尝试连接的时间间隔。默认值是60秒。



\#与master相关的日志的信息

\6. Master_Log_File: mysql-bin.001822

当前I/O线程正在读取的主服务器二进制日志文件的名称。

\7. Read_Master_Log_Pos: 290072815

当前I/O线程正在读取的二进制日志的位置。



\#与relay log相关的信息

\8. Relay_Log_File: mysqld-relay-bin.005201

当前slave SQL线程正在读取并执行的relay log的文件名。

\9. Relay_Log_Pos: 256529594

当前slave SQL线程正在读取并执行的relay log文件中的位置；（Relay_Log_File下的Relay_Log_Pos其实一一对应着Relay_Master_Log_File的Exec_Master_Log_Pos。）

\10. Relay_Master_Log_File: mysql-bin.001821

当前slave SQL线程读取并执行的relay log的文件中多数近期事件，对应的主服务器二进制日志文件的名称。（说白点就是我SQL线程从relay日志中读取的正在执行的sql语句，对应主库的sql语句记录在主库的哪个binlog日志中）



\#slave I/O和SQL线程的状态（重要）

\11. Slave_IO_Running: Yes

I/O线程是否被启动并成功地连接到主服务器上。

\12. Slave_SQL_Running: Yes

SQL线程是否被启动。



\13. Replicate_Do_DB

  Replicate_Ignore_DB

  Replicate_Do_Table

  Replicate_Ignore_Table

  Replicate_Wild_Do_Table

  Replicate_Wild_Ignore_Table

这些参数都是为了用来指明哪些库或表在复制的时候不要同步到从库，但是这些参数用的时候要小心，因为 当跨库使用的时候 可能会出现问题。

一般情况下 ，限制的时候都用Replicate_Wild_Ignore_Table这个参数。



\14. Last_Errno: 0

  Last_Error

slave的SQL线程读取日志参数的的错误数量和错误消息。错误数量为0并且消息为空字符串表示没有错误。

如果Last_Error值不是空值，它也会在从属服务器的错误日志中作为消息显示。 



\15. Skip_Counter: 0

SQL_SLAVE_SKIP_COUNTER的值，用于设置跳过sql执行步数。



\16. Exec_Master_Log_Pos: 256529431

slave SQL线程当前执行的事件，对应在master相应的二进制日志中的position。（结合Relay_Master_Log_File理解，而且在Relay_Master_Log_File这个值等于Master_Log_File值的时候，Exec_Master_Log_Pos是不可能超过Read_Master_Log_Pos的。）



\17. Relay_Log_Space: 709504534

所有原有的中继日志结合起来的总大小。



\18. Until_Condition: None

  Until_Log_File:

  Until_Log_Pos: 0

在START SLAVE语句的UNTIL子句中指定的值。



Until_Condition具有以下值：

1) 如果没有指定UNTIL子句，则没有值

2) 如果从属服务器正在读取，直到达到主服务器的二进制日志的给定位置为止，则值为Master

3) 如果从属服务器正在读取，直到达到其中继日志的给定位置为止，则值为Relay

Until_Log_File和Until_Log_Pos用于指示日志文件名和位置值。日志文件名和位置值定义了SQL线程在哪个点中止执行。



\19. Master_SSL_Allowed: No

  Master_SSL_CA_File: 

  Master_SSL_CA_Path: 

  Master_SSL_Cert: 

  Master_SSL_Cipher: 

  Master_SSL_Key:

  Master_SSL_Verify_Server_Cert: No 

  Master_SSL_Crl: 

  Master_SSL_Crlpath:



这些字段显示了被从属服务器使用加密相关的参数。这些参数用于连接主服务器。

Master_SSL_Allowed具有以下值：

1) 如果允许对主服务器进行SSL连接，则值为Yes

2) 如果不允许对主服务器进行SSL连接，则值为No

3) 如果允许SSL连接，但是从属服务器没有让SSL支持被启用，则值为Ignored。



与SSL有关的字段的值对应于–master-ca,–master-capath,–master-cert,–master-cipher和–master-key选项的值。



\20. seconds_Behind_Master: 2923

这个值是时间戳的差值。是slave当前的时间戳和master记录该事件时的时间戳的差值。



\21. Last_IO_Errno: 0

  Last_IO_Error: 

  Last_SQL_Errno: 0

  Last_SQL_Error: 

  最后一次I/O线程或者SQL线程的错误号和错误消息。



\22. Replicate_Ignore_Server_Ids: 

主从复制，从库忽略的主库服务器Id号。就是不以这些服务器Id为主库。



\23. Master_Server_Id: 1

  Master_UUID: 13ee75bb-99e2-11e6-be4d-b499baa80e6e

  Master_Info_File: /home/data/mysql/master.info

  分别表示主库服务器id号，主库服务器的UUID好，还有在从库中保存主库服务器相关的目录位置。



\24. SQL_Delay: 0

一个非负整数，表示秒数，Slave滞后多少秒于master。



\25. SQL_Remaining_Delay: NULL

当 Slave_SQL_Running_State 等待，直到MASTER_DELAY秒后，Master执行的事件，此字段包含一个整数，表示有多少秒左右的延迟。在其他时候，这个字段是NULL。



\26. Slave_SQL_Running_State: Reading event from the relay log

SQL线程运行状态：

 1) Reading event from the relay log

线程已经从中继日志读取一个事件，可以对事件进行处理了。

 2) Has read all relay log; waiting for the slave I/O thread to update it

线程已经处理了中继日志文件中的所有事件，现在正等待I/O线程将新事件写入中继日志。

 3) Waiting for slave mutex on exit

线程停止时发生的一个很简单的状态。



\27. Master_Retry_Count: 86400

连接主库失败最多的重试次数。



\28. Master_Bind: 

slave从库在多网络接口的情况下使用，以确定用哪一个slave网络接口连接到master。



\29. Last_IO_Error_Timestamp: 

  Last_SQL_Error_Timestamp: 

​    最后一次I/O线程或者SQL线程错误时的时间戳。



\#GTID模式相关

\30. Retrieved_Gtid_Set: 

  获取到的GTID<IO线程>



  Executed_Gtid_Set: 

  执行过的GTID<SQL线程>



  Auto_Position: 0







**理解与应用：**



 **1、为什么执行stop slave; 再start slave;可以继续主从关系呢？**

 

 其实执行stop slave;就是分别关闭了I/O线程（stop slave IO_THREAD;）和SQL线程（stop slave SQL_THREAD;），I/O线程会维护master.info信息的更新，SQL线程会维护relay-log.info信息的更新，在执行start slave;时候，会依照master.info和relay-log.info信息，继续执行I/O线程和SQL线程。



 **2、怎样从一个从库再复制一个新的从库呢？**



 步骤：

1. 
    1. 在从库上面stop slave IO_THREAD;关闭IO线程
    2. 等待SQL线程执行完成，当Relay_Master_Log_File和Master_Log_File二进制日志文件名一致，且Exec_Master_Log_Pos等于Read_Master_Log_Pos值。 
    3. mysqldump导出所需要的库，到新的从库服务器，并导入。
    4. 主库授权replication slave权限给新的从库
    5. 新的从库使用change master to命令，master_log_file对应Master_Log_File值，master_log_pos对应Read_Master_Log_Pos值。
    6. 在从库执行start slave IO_THREAD;和在新的从库上执行start slave;