# Mysql实现企业级日志管理、备份与恢复实战

 

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155409312-1146096933.png)

Mysql实现企业级日志管理、备份与恢复实战

　　**环境背景：**随着业务的发展，公司业务和规模不断扩大，网站积累了大量的用户信息和数据，对于一家互联网公司来说，用户和业务数据是根基。一旦公司的数据错乱或者丢失，对于互联网公司而言就等于说是灭顶之灾，为防止系统出现操作失误或系统故障导致数据丢失，公司要求加强用户数据的可靠性，要求全面加强数据层面备份，并能在故障发生时第一时间恢复。

**总架构图**，详见 http://www.cnblogs.com/along21/p/8000812.html

**Mysql备份方案：**

① **mysqldump+binlog:**

先完全备份，再通过备份二进制日志实现增量备份

**② xtrabackup:**

对InnoDB：热备，支持完全备份和增量备份

对MyISAM：温备，只支持完全备份

**③ lvm快照+binlog：**

几乎热备，物理备份

 

## 实战一：mysqldump+binlog 实现备份与恢复

### 1、准备备份的目录，开启二进制日志

mkdir /backup

**chown -R** **mysql.mysql** /backup/ 把备份的目录所属人所属组改为mysql

vim /etc/my.cnf

log-bin = /var/lib/mysql/bin-log 开启二进制日志，并制定路径

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155409906-755029904.png)

 

### 2、准备要备份的数据和表

模拟日常的数据库操作

MariaDB [(none)]> create database along; 创建一个along的表

MariaDB [along]> create table home(id int not null,name char(20)); 创建一个home表

MariaDB [along]> show master status; 查询二进制文件，编号是所处的文字

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155411421-998044528.png)

 

### 3、进行完整备份

可以备份所有库

mysqldump **--all-databases** --flush-log > /backup/mysql-**all**-backup-**`date +%F-%T`.sql**

也可以备份单独指定的库

mysqldump **--database along** --flush-log > /backup/mysql-along-backup-`date +%F-%T`.sql

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155411796-1512333506.png)

指令分析：

**mysqldump** [OPTIONS] **--databases** [OPTIONS] DB1 [DB2 DB3...]：备份一个或多个库

OPTIONS：

　　**--lock-all-tables**：**锁定**所有表

　　--lock-tables：锁定备份的表

　　--single-transaction：启动一个大的单一事务实现备份

　　--compress：压缩传输

　　--events：备份指定库的事件调度器

　　--routines：备份存储过程和存储函数

　　--triggers：备份触发器

　　**--master-data**={0|1|2}

　　　　0：不记录

　　　　1：记录CHANGE MASTER TO语句；此语句未被注释

　　　　**2：记录为注释语句**

　　**--flush-logs：**锁定表之后**执行flush logs命令，生成一个新的二进制日志**

 

### 4、向表中插入数据

模拟日常的正常操作

MariaDB [along]> insert into home values(1,'mayun');

MariaDB [along]> insert into home values(2,'mahuateng');

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155413109-1858797176.png)

 

### 5、进行增量备份，备份二进制日志

原理：需先知道要增量备份的**起始**，然后进行备份。

（1）查询起始

① 通过数据库命令查询起始，**推荐**

MariaDB [along]> show master status; 　　查询当前使用的二进制日志

MariaDB [along]> show binlog events in 'bin-log.000014'; 　　查询二进制日志，里边有编号位置

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155413702-1893691569.png)

② 也可以通过命令行查询

cd /var/lib/mysql/

mysqlbinlog bin-log.000014

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155414312-1065812275.png)

 

（2）进行**增量备份**

cd /var/lib/mysql/

mysqlbinlog --start-position=314 --stop-position=637 bin-log.000014 > /backup/mysql-along-backup-add-`date +%F-%T`.sql

注意：**起始的编号一定要往前和往后推一个编号**，例如：412是执行插入命令的，要从前一个编号314备份。

 

### 6、继续插入数据，在没备份的情况下删除数据库，模拟误操作

① 继续日常的操作

MariaDB [along]> insert into home values(3,'wangjianlin');

② 误删除along数据库，上一天还没来得及备份

MariaDB [along]> **drop** database along;

**这个时候稳住，不要慌，下面开始恢复**

 

### 7、数据恢复

① 由于最后我们没有备份就删除了数据库，所以我们首先需要保护最后的二进制日志，查看删除操作之前的position编号值

MariaDB [(none)]> show binlog events in 'bin-log.000014';

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155415015-1260659686.png)

② 备份后来没有来得及的操作

cd /var/lib/mysql/

mysqlbinlog --start-position=**706** --stop-position=**837** bin-log.000014 > /backup/mysql-along-backup-add-`date +%F-%T`.sql

 

### 8、导入之前的所有备份

① 查看我们的备份目录

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155415296-1587747109.png)

② 按顺序导入所有备份

完全备份 ---> 增量备份

mysql -uroot -p **<** mysql-along-backup-2017-11-16-16\:45\:22.sql

mysql -uroot -p **<** mysql-along-backup-add-2017-11-16-17\:15\:25.sql

mysql -uroot -p **<** mysql-along-backup-add-2017-11-16-17\:27\:50.sql

 

### 9、查看数据库及数据，恢复完成

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155415812-240723434.png)

 

## 实战二：xtrabackup 实现备份和缓存

### 1、安装xtrabackup

yum -y install xtrabackup

为了权限管理，也可以创建最小权限备份用户，为了实验方便，我就不设了

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155416015-1868495106.png)

 

### 2、完全备份

① 完全备份

**innobackupex --user=**root /backup/ **完全备份，备份完会生成一个目录**，里边有全部的数据库数据

若设置了权限的用户： innobackupex --user=bakupuser --password=bakuppass /backup/

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155416202-2067167637.png)

注意：要给备份的目录递归给mysql权限

chown **mysql.mysql** /backup/2017-11-16_17-57-57/ -R 给生成的目录加权限

 

② 基于完全备份生成的目录，也可以恢复数据

**datadir=**/backup/2017-11-16_17-57-57 把目录指向备份的目录

systemctl restart mariadb 重启服务

③ 查看数据，没有变化，数据一致

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155416531-1104621620.png)

 

### 3、增量备份

① 添加数据，日常操作

MariaDB [along]> **insert into** home values(4,'dinglei'),(5,'liyanhong');

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155416827-87823781.png)

② 增量备份

innobackupex --user=root --incremental /backup/ --incremental-basedir=/backup/2017-11-16_17-57-57 基于/backup/2017-11-16_17-57-57 进行增量备份

生成了增量备份的目录

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155417046-1484016005.png)

 

### 4、数据恢复准备："重放"与"回滚"

原理：一般情况下，在备份完成后，**数据尚且不能用于恢复操作**，因为备份的数据中可能会包含**尚未提交的事务**或**已经提交但尚未同步至数据**文件中的**事务**

① 需要在每个备份(包括完全和各个增量备份)上，**将已经提交的事务进行"重放"**。"重放"之后，所有的备份数据将合并到完全备份上。

② **基于所有的备份将未提交的事务进行"回滚"**。

innobackupex --apply-log **--redo-only** /backup/2017-11-16_17-57-57/ 完全备份的数据恢复准备

innobackupex --apply-log **--redo-only** /backup/2017-11-16_20-14-05/ --incremental-dir=/backup/2017-11-16_20-37-40/ 增量备份的数据恢复准备

 

### 5、误操作，恢复数据

mv /var/lib/mysql /var/lib/mysql.bak 模拟误删除数据库存放文件

mkdir /var/lib/mysql

**innobackupex --copy-back** /backup/2017-11-16_20-14-05/ **数据恢复**

chown mysql.mysql var/lib/mysql/ -R

**cp -a** /var/lib/mysql.bak/**mysql.sock** /var/lib/mysql 把套接字文件cp过来

systemctl start mariadb 重启服务

 

### 6、查看数据库及数据，数据完全一致

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155417296-19356287.png)

 

## 实验三：lvm快照+binlog 实现数据备份与恢复

**原理：**LVM快照简单来说就是将所快照源分区一个时间点所有文件的元数据进行保存， 如果源文件没有改变， 那么访问快照卷的相应文件则直接指向源分区的源文件， 如果源文件发生改变， 则快照卷中与之对应的文件不会发生改变。 快照卷主要用于辅助备份文件。

### 1、准备工作

由于我们实验环境下的数据库的数据库目录不是在lvm上的，首先，我们要搭建lvm环境，然后把数据库迁移到lvm上面，在进行实验：

（1）添加硬盘，并划分磁盘类型为lvm 类型

echo '- - -' > /sys/class/scsi_host/host2/scan 虚拟机中实现磁盘添加，不重启同步新磁盘

fdisk /dev/sdg

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155417577-1112528641.png)

![img](Mysql%E5%AE%9E%E7%8E%B0%E4%BC%81%E4%B8%9A%E7%BA%A7%E6%97%A5%E5%BF%97%E7%AE%A1%E7%90%86%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E5%AE%9E%E6%88%98.assets/1216496-20171208155417749-1152575187.png)

（2）partx -a /dev/sdb 或 partprobe 使内核识别新磁盘

partprobe：在centos5、7 中都能正常使用；centos6 版本中有BUG

partx -a /dev/sdb：都可正常使用

（3）创建逻辑卷

① **pvcreate** /dev/sdg1 添加物理卷

② **vgcreate** myvg /dev/sdg1 添加卷组

③ **lvcreate** -n mydata -L 50G myvg 添加逻辑卷

④ **mkfs.ext4** /dev/mapper/myvg-mydata 格式化逻辑卷，文件系统格式化

 

### 2、挂载逻辑卷

① mkdir /lvm_data  创建lvm挂载的目录 

② mount /dev/mapper/myvg-mydata /lvm_data 挂载

我们最好把它写到 **/etc/fstab** 中，如：

vim /etc/fstab

**/dev/mapper/myvg-mydata** **/lvm_data/** **ext4** defaults 0 0

③ 然后将该挂载的目录的所有者和所属组改成mysql

chown -R mysql.mysql /lvm_data

 

### 3、修改Mysql 配置

（1）修改Mysql 配置，使得数据文件在逻辑卷上 datadir=/lvm_data

vim /etc/my.cnf

[mysqld]

datadir=**/lvm_data**

socket=/var/lib/mysql/mysql.sock

 

（2）将数据库文件拷贝到 /lvm_data 目录下：

cp -a /var/lib/mysql/* / lvm_data

 

（3）service mysqld restart 启动Mysql 服务

### 4、创建快照

（1）在我们创建快照之前，需要我们**锁表**，将数据库中的表锁定，让外界无法读取：

MariaDB [(none)]> **flush tables with read lock;**

（2）创建快照：Logical volume "mydata-snap" created

lvcreate -L 1G -n mydata-snap **-p** r -s /dev/mapper/myvg-mydata

（3）解除表的锁定：

MariaDB [(none)]> **unlock** tables;

### 5、打包数据，数据备份

（1）打包数据：

tar czvf /tmp/mysqlback.tar.gz /lvm_data

（2）在我们使用完快照之后，需要将他们进行卸载，删除，命令如下所示：

umount /lvm_snap/

lvremove myvg /dev/myvg/mydata-snap

### 6、模拟删库，数据恢复

（1）我们把/lvm_data下的数据全部删掉，模拟我们的数据库全部丢失

rm -rf /lvm_data/*

（2）数据恢复

mv /tmp/mysqlback.tar.gz /lvm_data 把压缩的包cp过来

tar xvf /tmp/mysqlback.tar.gz ./ 将数据进行解压，恢复数据

注意：有一点要注意的是，在数据拷贝到数据库文件目录下后，我们一定要看看文件的权限是否是mysql用户的，如若不是，需要我们手动更改。