# NFS网络文件系统详解第1章 NFS基本概述

## 1.1 什么是nfs

NFS是Network File System的缩写及网络文件系统。

主要功能是通过局域网络让不同的主机系统之间可以共享文件或目录。

NFS系统和Windows网络共享、网络驱动器类似, 只不过windows用于局域网, NFS用于企业集群架构中, 如果是大型网站, 会用到更复杂的分布式文件系统FastDFS,glusterfs,HDFS

## 1.2 为什么要使用NFS服务进行数据存储

1.实现多台服务器之间数据共享

2.实现多台服务器之间数据的一致

## 1.3 本地文件操作方式

当用户执行mkdir命令, 该命令会通过shell解释器翻译给内核,由内核解析完成后驱动硬件，完成相应的操作。

## 1.4 NFS实现原理(需要先了解[程序|进程|线程])

1.用户进程访问NFS客户端，使用不同的函数对数据进行处理

2.NFS客户端通过TCP/IP的方式传递给NFS服务端。

3.NFS服务端接收到请求后，会先调用portmap进程进行端口映射。

4.nfsd进程用于判断NFS客户端是否拥有权限连接NFS服务端。

5.Rpc.mount进程判断客户端是否有对应的权限进行验证。

6.idmap进程实现用户映射和压缩

7.最后NFS服务端会将对应请求的函数转换为本地能识别的命令，传递至内核，由内核驱动硬件。

rpc是一个远程过程调用，那么使用nfs必须有rpc服务

## 1.5 NFS存储优点

1.NFS文件系统简单易用、方便部署、数据可靠、服务稳定、满足中小企业需求。

2.NFS文件系统内存放的数据都在文件系统之上，所有数据都是能看得见。

## 1.6 NFS存储局限

1.存在单点故障, 如果构建高可用维护麻烦。(web-》nfs()-》backup)

2.NFS数据明文, 并不对数据做任何校验。

3.客户端挂载无需账户密码, 安全性一般(内网使用)

## 1.7 生产应用建议

1.生产场景应将静态数据尽可能往前端推, 减少后端存储压力

2.必须将存储里的静态资源通过CDN缓存(jpg\png\mp4\avi\css\js)

3.如果没有缓存或架构本身历史遗留问题太大, 在多存储也无用

# 第2章 NFS基本使用

## 2.1 环境准备

| 服务器系统 | 角色      | 外网IP         | 内网IP           | 主机名 |
| ---------- | --------- | -------------- | ---------------- | ------ |
| CentOS 7.5 | NFS服务端 | eth0:10.0.0.31 | eth1:172.16.1.31 | nfs    |
| CentOS 7.5 | NFS客户端 | eth0:10.0.0.7  | eth1:172.16.1.7  | web01  |

## 2.2 关闭防火墙及selinux（客户端，服务端都要关闭）

### 2.2.1 关闭防火墙

```
systemctl disable firewalld
systemctl stop firewalld
```

### 2.2.2 关闭selinux

```
sed -ri '#^SELINUX=#cSELINUX=Disabled' /etc/selinux/config

setenforce 0
```

## 2.3 服务端安装nfs

```
[root@nfs ~]# yum -y install nfs-utils
```

### 2.3.1 配置nfs

我们可以按照共享目录的路径 允许访问的NFS客户端（共享权限参数）格式，定义要共享的目录与相应的权限。

```
[root@nfs ~]# echo '/data 172.16.1.0/24(rw,sync,all_squash)' > /etc/exports

[root@nfs ~]# cat /etc/exports

/data 172.16.1.0/24(rw,sync,all_squash)
```

如果想要把/data目录共享给172.16.1.0/24网段内的所有主机

1.主机都拥有读写权限

2.在将数据写入到NFS服务器的硬盘中后才会结束操作，最大限度保证数据不丢失

3.将所有用户映射为本地的匿名用户(nfsnobody)

### 2.3.2 创建对应的目录

```
[root@nfs ~]# mkdir /data
```

### 2.3.3 启动服务，并将服务加入开机自启动

```
[root@nfs ~]# systemctl enable rpcbind nfs-server

[root@nfs ~]# systemctl start rpcbind nfs-server
```

### 2.3.4 检查端口

```
[root@nfs ~]# netstat -lntp

Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address      Foreign Address    State       PID/Program name                  
tcp        0      0 0.0.0.0:2049            0.0.0.0:*     LISTEN      -                     
tcp        0      0 0.0.0.0:111             0.0.0.0:*     LISTEN      653/rpcbind
```

### 2.3.5 检查共享的内容

```
[root@nfs ~]# cat /var/lib/nfs/etab

/data 172.16.1.0/24(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,all_squash,no_subtree_check,secure_locks,acl,no_pnfs,anonuid=65534,anongid=65534,sec=sys,secure,root_squash,all_squash)
```

### 2.3.6 检查匿名用户对应的真实账户,并授权共享目录为nfsnobody

```
[root@nfs ~]# grep "65534" /etc/passwd

nfsnobody:x:65534:65534:Anonymous NFS User:/var/lib/nfs:/sbin/nologin

[root@nfs ~]# chown -R nfsnobody.nfsnobody /data
```

## 2.4 客户端安装nfs

```
[root@web01 ~]# yum install nfs-utils -y
```

### 2.4.1 启动`rpcbind`服务

```
[root@web01 ~]# systemctl enable rpcbind

[root@web01 ~]# systemctl start rpcbind
```

### 2.4.2 使用`showmount -e`查看远程服务器`rpc`提供的可挂载`nfs`信息

```
[root@web01 ~]# showmount -e 172.16.1.31

Export list for 172.16.1.31:

/data 172.16.1.0/24
```

### 2.4.3 创建挂载点目录，执行挂载命令

mount命令并结合-t参数, 指定要挂载的文件系统的类型, 并在命令后面写上服务器的IP地址, 以及服务器上的共享目录, 最后需要写上要挂载到本地系统(客户端)的目录

```
[root@web01 ~]# mkdir /data

[root@web01 ~]# mount -t nfs 172.16.1.31:/data /data/

[root@web01 ~]# df -h

文件系统                   容量  已用   可用    已用% 挂载
172.16.1.31:/data         50G  2.6G   48G    6% /data
```

### 2.4.4 挂载成功后可以进行增删改操作，测试客户端是否拥有写的权限

```
[root@web01 ~]# echo "123" > /data/test

[root@web01 ~]# ll /data/

总用量 4

-rw-r--r-- 1 nfsnobody nfsnobody 4 9月   6 03:41 test
```

### 2.4.5 检查nfs服务端是否存在数据

```
[root@nfs ~]# ll /data/

总用量 4

-rw-r--r-- 1 nfsnobody nfsnobody 4 9月   6 03:41 test
```

### 2.4.6 如果希望NFS文件共享服务能一直有效则永久挂载

（防止服务器重启挂载失效->服务器不会重启）

```
[root@web01 ~]# echo '172.16.1.31:/data       /data                   nfs     defaults        0 0' >> /etc/fstab

[root@web01 ~]# tail -1 /etc/fstab

172.16.1.31:/data       /data                   nfs     defaults        0 0
```

验证fstab是否ok，前提要先卸载挂载

```
[root@web01 ~]# umount /data/
```

df -h 发现挂载没有了

```
[root@web01 ~]# mount -a
```

fstab如果ok，df -h查看会看到已经自动挂载了

### 2.4.7 如果不希望使用`NFS`共享, 可进行卸载

```
[root@web01 ~]# umount /data/
```

卸载的时候如果提示”umount.nfs: /data: device is busy” 

1.切换至其他目录, 然后在进行卸载。

2.NFS宕机, 强制卸载umount -lf /data

## 2.5 配置多台客户端服务器的配置方法何上面客户端方法一致

注意：客户端的必须是服务端配置允许访问的NFS客户端网段内的所有主机

# 第3章 NFS配置参数及验证

## 3.1 nfs共享参数及作用

执行man exports命令，然后切换到文件结尾，可以快速查看如下样例格式：

| 共享参数       | 参数作用                                                     |
| -------------- | ------------------------------------------------------------ |
| rw*            | 读写权限                                                     |
| ro             | 只读权限                                                     |
| root_squash    | 当NFS客户端以root管理员访问时，映射为NFS服务器的匿名用户(不常用) |
| no_root_squash | 当NFS客户端以root管理员访问时，映射为NFS服务器的root管理员(不常用) |
| all_squash     | 无论NFS客户端使用什么账户访问，均映射为NFS服务器的匿名用户(常用) |
| no_all_squash  | 无论NFS客户端使用什么账户访问，都不进行压缩                  |
| sync*          | 同时将数据写入到内存与硬盘中，保证不丢失数据                 |
| async          | 优先将数据保存到内存，然后再写入硬盘；这样效率更高，但可能会丢失数据 |
| anonuid*       | 配置all_squash使用,指定NFS的用户UID,必须存在系统             |
| anongid*       | 配置all_squash使用,指定NFS的用户UID,必须存在系统             |

## 3.2 验证ro权限

```
[root@nfs ~]# echo '/data 172.16.1.0/24(ro,sync,all_squash)' > /etc/export

[root@nfs ~]#cat /etc/exports

/data 172.16.1.0/24(ro,sync,all_squash)
```

### 3.2.1 重载nfs（exportfs）

```
[root@nfs ~]# systemctl restart nfs-server
```

### 3.2.2 先卸载客户端已挂载好的共享

```
[root@web01 ~]# umount /data/
```

### 3.2.3 重新进行挂载

```
[root@web01 ~]# mount -t nfs 172.16.1.31:/data /data/
```

### 3.2.4 测试是否能写数据

```
[root@web01 ~]# cd /data/

[root@web01 data]# touch file-test        不允许写入数据

touch: cannot touch 'file-test': Read-only file system
```

## 3.3 验证all_squash,anonuid,anongid权限

```
[root@nfs ~]# echo '/data 172.16.1.0/24(rw,sync,all_squash,anonuid=666,anongid=666)' > /etc/exports

[root@nfs ~]# cat /etc/exports

/data 172.16.1.0/24(rw,sync,all_squash,anonuid=666,anongid=666)
```

### 3.3.1 需要添加一个uid是666，gid是666的用户

```
[root@nfs ~]# groupadd -g 666 www

[root@nfs ~]# useradd -u666 -g666 www

[root@nfs ~]# id www

uid=666(www) gid=666(www) 组=666(www)
```

### 3.3.2 必须重新授权为www用户，否则无法写入文件

```
[root@nfs ~]# chown -R www.www /data/
```

### 3.3.3 重启服务

```
[root@nfs ~]# systemctl restart nfs-server
```

### 3.3.4 客户端重新挂载

```
[root@web01 /]# umount /data/

[root@web01 /]# mount -t nfs 172.16.1.31:/data /data/

[root@web01 data]# ll

total 4

-rw-r--r-- 1 666 666 4 Sep  6 03:41 test
```

### 3.3.5 测试是否能写入数据

```
[root@web01 data]# touch tes1

[root@web01 data]# ll

total 4

-rw-r--r-- 1 666 666 0 Sep  7 10:38 tes1

-rw-r--r-- 1 666 666 4 Sep  6 03:41 test
```

### 3.3.6 为了防止权限不一致导致权限不足，建议在客户端创建一模一样的用户

```
[root@web01 ~]# groupadd -g 666 www

[root@web01 ~]# useradd -u666 -g666 www

[root@web01 ~]# id www

uid=666(www) gid=666(www) groups=666(www)
```

### 3.3.7 在此检查文件身份

```
[root@web01 ~]# ll /data/

total 4

-rw-r--r-- 1 www www 0 Sep  7 10:38 tes1

-rw-r--r-- 1 www www 4 Sep  6 03:41 test
```