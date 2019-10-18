# mysql主从同步从库上Slave_IO_Running: Connecting问题

**mysql主从同步从库上Slave_IO_Running: Connecting问题**

一．在做主从同步时遇到的问题

 

数据库主从问题从库上Slave_IO_Running: Connecting  

在做mysql主从同步的时候有时候发现在从库上Slave_IO_Running: Connecting



[![wKiom1nAd6rwHbZMAABGUYb4RmM832.jpg-wh_50](https://s5.51cto.com/wyfs02/M00/06/E6/wKiom1nAd6rwHbZMAABGUYb4RmM832.jpg-wh_500x0-wm_3-wmp_4-s_2795401261.jpg)](https://s5.51cto.com/wyfs02/M00/06/E6/wKiom1nAd6rwHbZMAABGUYb4RmM832.jpg-wh_500x0-wm_3-wmp_4-s_2795401261.jpg) 

 

二．解决办法通常是5个问题：

1.网络不通      #互ping机器ip，无丢包率正常访问，排除

2.密码不对      #MySQL重新授权远程用户登陆账号，重新设置密码，排除

3.pos不正确     #主服务器,登陆数据库重新查看起始偏移量show master status,排除

4.ID问题        

\#ID的问题，在安装完mysql数据库的时候默认他们的server-id=1 但是在做主从同步的时候需要将ID号码设置不一样才行,查看数据库配置文件cat  /etc/my.cnf，文件写的不同，排除

5.防火墙策略  

查看防火墙策略，是否放通双方的服务端口 iptables -nL,最后发现 防火墙策略写了多端口防火墙策略的端口不生效，解决防火墙策略单独开放端口，暂停从服务的io读取stop slave;重新在从的数据库写入以下语句：

mysql> change master to

​    -> master_host='192.168.137.36',             

​    -> master_user='root',                 

​    -> master_password='abc123',

​    -> master_port=3307,

​    -> master_log_file='mysql-bin.000001',

​    -> master_log_pos=848;

Query OK, 0 rows affected, 2 warnings (0.05 sec)

 

mysql> start slave;

Query OK, 0 rows affected (0.02 sec)

 

mysql> show slave status\G

*************************** 1. row ***************************

​               Slave_IO_State: Waiting for master to send event

​                  Master_Host: 192.168.137.36

​                  Master_User: root

​                  Master_Port: 3307

​                Connect_Retry: 60

​              Master_Log_File: mysql-bin.000001

​          Read_Master_Log_Pos: 1298

​               Relay_Log_File: localhost-relay-bin.000002

​                Relay_Log_Pos: 770

​        Relay_Master_Log_File: mysql-bin.000001

​             Slave_IO_Running: Yes

​            Slave_SQL_Running: Yes

​              Replicate_Do_DB:

​          Replicate_Ignore_DB:

​           Replicate_Do_Table:

​       Replicate_Ignore_Table:

​      Replicate_Wild_Do_Table:

  Replicate_Wild_Ignore_Table:

​                   Last_Errno: 0

​                   Last_Error:

​                 Skip_Counter: 0

​          Exec_Master_Log_Pos: 1298

​              Relay_Log_Space: 981

​              Until_Condition: None

​               Until_Log_File:

​                Until_Log_Pos: 0

​           Master_SSL_Allowed: No

​           Master_SSL_CA_File:

​           Master_SSL_CA_Path:

​              Master_SSL_Cert:

​            Master_SSL_Cipher:

​               Master_SSL_Key:

​        Seconds_Behind_Master: 0

Master_SSL_Verify_Server_Cert: No

​                Last_IO_Errno: 0

​                Last_IO_Error:

​               Last_SQL_Errno: 0

​               Last_SQL_Error:

  Replicate_Ignore_Server_Ids:

​             Master_Server_Id: 9

​                  Master_UUID: ad899234-9c81-11e7-99bd-000c29af2bef

​             Master_Info_File: /data/mysql_data1/master.info

​                    SQL_Delay: 0

​          SQL_Remaining_Delay: NULL

​      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates

​           Master_Retry_Count: 86400

​                  Master_Bind:

​      Last_IO_Error_Timestamp:

​     Last_SQL_Error_Timestamp:

​               Master_SSL_Crl:

​           Master_SSL_Crlpath:

​           Retrieved_Gtid_Set:

​            Executed_Gtid_Set:

​                Auto_Position: 0

​         Replicate_Rewrite_DB:

​                 Channel_Name:

​           Master_TLS_Version:

1 row in set (0.00 sec)

注意：标注的俩个红色yes为正常。