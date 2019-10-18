# DNS解析原理与Bind部署DNS服务



## DNS是什么？

DNS（Domain Name System，域名系统）是互联网上最核心的带层级的分布式系统，它负责把域名转换为IP地址、反查IP到域名的反向解析以及宣告邮件路由等信息，使得基于域名提供服务称为可能，例如网站访问、邮件服务等。

## DNS解析原理

![img](https://images2017.cnblogs.com/blog/1192583/201709/1192583-20170920142623103-194830385.png)

DNS系统由两部分组成，一是Resolver解析器，作为DNS请求的客户端，负责从DNS记录中解析出IP或别名等信息；二是NS域名服务器，提供域名解析服务，例如Bind。

DNS服务器分为三类：一是权威域名服务器，用于解析域名或使用NS记录进行授权；二是缓存域名服务器，用于递归查询并缓存DNS记录；三是转发域名服务器，仅用于转发DNS请求给指定的上级域名服务器。

## DNS记录类型

1.A记录：指定域名对应IP的记录

2.PTR记录：指定IP对应域名的记录

3.MX记录：邮件交换记录，也叫邮件路由记录，指向邮件服务器的IP

4.CNAME记录：别名记录，用于指向另一个域名

5.NS记录：域名服务器记录，指定该域名由哪个DNS服务器来解析

## Bind部署DNS域名解析

#### Bind是什么？

BIND伯克利互联网域名服务(Berkeley Internet Name Domain)是一款全球互联网使用最广泛、能够提供安全可靠、快捷高效的域名解析的服务程序。

#### 安装Bind服务程序

```shell
`[root@localhost ~]``# yum install -y bind-chroot`
```

####  修改主配置文件

```shell
[root@localhost ~]# vim /etc/named.conf
 
  options {
          listen-on port 53 { any; };  //监听53端口所有来源信息
          listen-on-v6 port 53 { ::1; };
          directory       "/var/named";
          dump-file       "/var/named/data/cache_dump.db";
          statistics-file "/var/named/data/named_stats.txt";
          memstatistics-file "/var/named/data/named_mem_stats.txt";
          allow-query     { any; };   //允许所有来源访问
```

#### 正向解析：由域名到IP

配置区域文件

```shell
[root@localhost ~]# vim /etc/named.rfc1912.zones
 
 zone "test.com" IN{
  
 type master;         //服务器类型：主服务器
 file "test.com.zone";  // 数据文件名称
 allow-update {none;};   // 是否允许从服务器更新解析数据
  
 };
```

 配置域名解析文件

```shell
[root@localhost ~]# cd /var/named
[root@localhost named]# cp -a named.localhost test.com.zone
[root@localhost named]# vim test.com.zone
 
 $TTL 1D
 @       IN SOA  test.com. root.test.com. (
                                         0       ; serial
                                         1D      ; refresh
                                         1H      ; retry
                                         1W      ; expire
                                         3H )    ; minimum
         NS      ns.test.com.          //域名服务器记录：表示该域名由哪台DNS进行解析
 ns      IN A    192.168.41.10
          
         IN MX 10 mail.test.com.       //邮箱交换记录，用于邮件系统解析
 mail    IN A    192.168.41.10
  
 www     IN A    192.168.41.10        //地址记录，表明三级域名www.test.com 对应的解析地址
 bbs     IN A    192.168.41.10
```

 重启服务，进行测试

```shell
[root@localhost named]# systemctl restart named
[root@localhost named]# systemctl enable named
[root@localhost ~]# nslookup  //常用解析器
> www.test.com
Server:        192.168.41.10
Address:   192.168.41.10#53
 
Name:  www.test.com
Address: 192.168.41.10
> bbs.test.com
Server:        192.168.41.10
Address:   192.168.41.10#53
 
Name:  bbs.test.com
Address: 192.168.41.10
> <br><br>#测试前记得修改DNS或者直接在/etc/resolve.conf中添加
```

#### 反向解析：由IP到域名

配置区域文件

```shell
[root@localhost ~]# vim /etc/named.rfc1912.zones
 
zone "41.168.192.in-addr.arpa" IN{
 
type master;
file "192.168.41.arpa";
allow-update {none;};
 
};    
```

配置反向解析文件

```shell
[root@localhost ~]# cd /var/named
[root@localhost named]# cp -a named.loopback 192.168.41.arpa
[root@localhost named]# vim 192.168.41.arpa
  
 $TTL 1D
 @       IN SOA  test.com. root.test.com. (
                                         0       ; serial
                                         1D      ; refresh
                                         1H      ; retry
                                         1W      ; expire
                                         3H )    ; minimum
         NS      ns.test.com.
 ns      A       192.168.41.10
 10      PTR     ns.test.com.
 10      PTR     mail.test.com.
 10      PTR     www.test.com.
 20      PTR     bbs.test.com.
```

 重启服务，进行测试

```shell
[root@localhost named]# systemctl restart named
[root@localhost named]# nslookup
> 192.168.41.10
Server:        192.168.41.10
Address:   192.168.41.10#53
 
10.41.168.192.in-addr.arpa name = www.test.com.
10.41.168.192.in-addr.arpa name = ns.test.com.
10.41.168.192.in-addr.arpa name = mail.test.com.
> 192.168.41.20
Server:        192.168.41.10
Address:   192.168.41.10#53
 
20.41.168.192.in-addr.arpa name = bbs.test.com.
>
```

#### 部署从服务器

配置主服务器区域文件

```shell
[root@localhost named]# vim /etc/named.rfc1912.zones
 
 zone "test.com" IN{
 
 type master;
 file "test.com.zone";
 allow-update {192.168.41.30;};   //允许从服务器更新
  
 };
  
 zone "41.168.192.in-addr.arpa" IN{
  
 type master;
 file "192.168.41.arpa";
 allow-update {192.168.41.30;};
  
 };
```

 配置从服务器区域文件

```shell
[root@localhost ~]# vim /etc/named.rfc1912.zones
  
 zone "test.com" IN{
 
 type slave;          //服务器类型：从服务器
 masters {192.168.41.10;};  //主服务器IP
 file "slaves/test.com.zone";  //同步的文件保存的地址
  
 };
  
 zone "41.168.192.in-addr.arpa" IN{
  
 type slave;
 masters {192.168.41.10;};
 file "slaves/192.168.41.arpa";
  
 };
```

 重启服务，进行测试

```shell
[root@localhost slaves]# cd /var/named/slaves/
[root@localhost slaves]# systemctl restart named
[root@localhost slaves]# ls
192.168.41.arpa  test.com.zone     // 主服务器数据文件已经同步过来了
[root@localhost slaves]# nslookup 
> www.test.com
Server:        192.168.41.30
Address:   192.168.41.30#53
 
Name:  www.test.com
Address: 192.168.41.10
> bbs.test.com
Server:        192.168.41.30
Address:   192.168.41.30#53
 
Name:  bbs.test.com
Address: 192.168.41.10
> 192.168.41.10
Server:        192.168.41.30
Address:   192.168.41.30#53
 
10.41.168.192.in-addr.arpa name = www.test.com.
10.41.168.192.in-addr.arpa name = mail.test.com.
10.41.168.192.in-addr.arpa name = ns.test.com.
> <br><br>#测试前记得修改DNS或者直接在/etc/resolve.conf中添加<br>#同步之前记得设置或关闭主服务器防火墙，主从服务器都要重启named服务

```

##  几点说明

1./etc/resolve.conf是设置DNS的文件，解析器需要读取该文件请求DNS服务。

2.当网卡重启时，/etc/resolve.conf文件内的设置将会被网卡配置文件中的DNS设置覆盖，所以如果希望DNS设置永久生效，则要在网卡配置文件中配置DNS；如果只是临时修改或添加DNS，则直接配置/etc/resolve.conf文件即可。

3.Bind服务默认开启递归查询功能，所以既是缓存域名服务器，又是权威域名服务器。如果仅作为权威服务器用于域名解析，则可以关闭递归查询功能；

```shell
vim /etc/named.conf
options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { any; };
        recursion no;          // 关闭递归查询功能
 
        dnssec-enable yes;
        dnssec-validation yes;
```

 4.DNS服务器中存放着全球13组根域名服务器的NS记录，保存在域名解析文件named.ca中。

```shell
vim /etc/named.conf
 
zone "." IN {
        type hint;
        file "named.ca";
};
 
vim /var/named/named.ca
 
; formerly NS.INTERNIC.NET
;
.                        3600000      NS    A.ROOT-SERVERS.NET.
A.ROOT-SERVERS.NET.      3600000      A     198.41.0.4
A.ROOT-SERVERS.NET.      3600000      AAAA  2001:503:ba3e::2:30
;
; FORMERLY NS1.ISI.EDU
;
.                        3600000      NS    B.ROOT-SERVERS.NET.
B.ROOT-SERVERS.NET.      3600000      A     192.228.79.201
B.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:84::b
;
; FORMERLY C.PSI.NET
;
.                        3600000      NS    C.ROOT-SERVERS.NET.
C.ROOT-SERVERS.NET.      3600000      A     192.33.4.12
C.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:2::c
"/var/named/named.ca" 92L, 3289C    
... ...
```

 