# 企业级监控工具应用实战-zabbix安装与基础操作 

**实验前准备：**

① ntpdate 192.168.30.1 同步时间

② 关闭防火墙、selinux

③ vim /etc/hosts 每个机器都设置hosts，以解析主机名；DNS也行

```
192.168.30.107    server.along.com
192.168.30.7      node1.along.com
192.168.30.2      node2.along.com
192.168.30.3      node3.along.com zbproxy.along.com
```

## 实战一：zabbix的搭建与部署

### **1、下载安装**

（1）下载

① 去官网，下载自己需要的版本<https://www.zabbix.com/download>

![img](assets/1216496-20171226161948635-1747029617.png)

② 包的介绍

[zabbix-agent-3.4.4-2.el7.x86_64.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-agent-3.4.4-2.el7.x86_64.rpm)    监控（安装在被监控者，当然监控自己也需要监控）

[zabbix-get-3.4.4-2.el7.x86_64.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-get-3.4.4-2.el7.x86_64.rpm)    在server端，手工连接agent 获取数据的，做测试的

zabbix-java-gateway-3.4.4-2.el7.x86_64.rpm     基于JAM监控时使用的

proxy 是和代理相关的包：

[zabbix-proxy-mysql-3.4.4-2.el7.x86_64.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-proxy-mysql-3.4.4-2.el7.x86_64.rpm)

[zabbix-proxy-pgsql-3.4.4-2.el7.x86_64.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-proxy-pgsql-3.4.4-2.el7.x86_64.rpm)

[zabbix-proxy-sqlite3-3.4.4-2.el7.x86_64.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-proxy-sqlite3-3.4.4-2.el7.x86_64.rpm)

[zabbix-sender-3.4.4-2.el7.x86_64.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-sender-3.4.4-2.el7.x86_64.rpm)    安装在agent端，主动监控模式下，向server端发送测试数据使用的

server 取决自己的存储系统选mysql 或 pgsql：

[zabbix-server-mysql-3.4.4-2.el7.x86_64.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-server-mysql-3.4.4-2.el7.x86_64.rpm)

[zabbix-server-pgsql-3.4.4-2.el7.x86_64.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-server-pgsql-3.4.4-2.el7.x86_64.rpm)

[zabbix-web-3.4.4-2.el7.noarch.rpm](https://www.cnblogs.com/along21/p/zabbix-web-3.4.4-2.el7.noarch.rpm%20)    web部位，核心包

[zabbix-web-japanese-3.4.4-2.el7.noarch.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-web-japanese-3.4.4-2.el7.noarch.rpm)    专用日语的web部位

web要连接mysql 或 pgsql时，需要安装的包：

[zabbix-web-mysql-3.4.4-2.el7.noarch.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-web-mysql-3.4.4-2.el7.noarch.rpm)

[zabbix-web-pgsql-3.4.4-2.el7.noarch.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-web-pgsql-3.4.4-2.el7.noarch.rpm)

[zabbix-release-3.4-2.el7.noarch.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm)    zabbix下载的源

  

（2）安装

① 安装官方的源

[zabbix-release-3.4-2.el7.noarch.rpm](http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm)    直接下载源

**rpm -ivh** zabbix-release-3.4-2.el7.noarch.rpm

yum repolist    可以查看自己的仓库有zabbix源了

**声明：我用的是3.2版本的，以下的示范也是3.2版本**

② 安装

```
yum -y install zabbix-agent zabbix-get zabbix-sender zabbix-server-mysql zabbix-web zabbix-web-mysql
```

### 2、初始化数据库

（1）vim /etc/my.cnf.d/server.cnf 子配置文件

```
[server]
skip_name_resolve = on
innodb_file_per_table = on
innodb_buffer_pool_size = 256M   #buffer缓存大小
max_connections = 2000   #最大连接数
log-bin = master-log    #二进制日志
```

（2）建数据库，授权，刷新权限

```
MariaDB [(none)]> create database zbxdb character set 'utf8';
MariaDB [(none)]> grant all on zbxdb.* to zbxuser@'192.168.30.%' identified by 'zbxpass';
MariaDB [(none)]> flush privileges;
```

（3）导入数据

rpm -ql zabbix-server-mysql 下包的时候，带有数据库文件的解压包

![img](assets/1216496-20171226161949448-2061789816.png)

cp /usr/share/doc/zabbix-server-mysql-3.4.4/create.sql.gz ./ 考到root下，解压

gzip -d create.sql.gz

mysql -uroot -p zbxdb < create.sql 导入数据

 

（4）可以去数据库查看，数据已经生成

![img](assets/1216496-20171226161949729-859071827.png)

 

### 3、配置，开启zabbix-server

（1）配置前准备

cd /etc/zabbix/

cp zabbix_server.conf{,.bak} 先备份，养成好习惯

grep **-i "^####"** zabbix_server.conf 查看有几个配置段

　　GENERAL PARAMETERS 一般性配置

　　ADVANCED PARAMETERS 高级配置

　　LOADABLE MODULES 可加载模块

　　TLS-RELATED PARAMETERS 配置加密的东西，如私钥证书等

![img](assets/1216496-20171226161950041-204514946.png)

grep **-i "^###"** zabbix_server.conf 可以查看一下需要配置的选项

![img](assets/1216496-20171226161950463-1517810146.png)

 

（2）配置

vim zabbix_server.conf 修改配置文件

```
ListenPort=10051    默认端口10051 
SourceIP=      发采用数据请求的端口，可以加多个地址，需要的话自己设置
```

② 日志的配置

![img](assets/1216496-20171226161950979-1422879162.png)

```
② 数据库的配置
DBHost=192.168.30.107   数据库对外的地址
DBName=zbxdb   数据库中库的名字
DBUser=zbxuser   数据库授权的用户
DBPassword=zbxpass   密码
DBPort=3306   数据库服务端口
```

（3）开启服务

systemctl start zabbix-server.service

 

### 4、设置zabbix的web 服务

（1）zabbix 需要开启与web 相连的服务

cd /etc/httpd/conf.d/

vim **zabbix.conf** 额外为php5 设置了一些参数

\# php_value date.timezone Europe/Riga php的时区必须设置，不过有两处可以设置，在php的配置文件中设置，或在这里设置；在这里设置，只对zabbix有效

![img](assets/1216496-20171226161951370-408438383.png)

vim /etc/php.ini 在php的配置文件中设置，代表对所有使用php的都生效，我就在这里设置了

date.timezone = Asia/Shanghai

 

（2）开启

systemctl start httpd

 

### 5、在web 页面初始化设置

（1）初始化配置

① web登录 http://192.168.30.107/zabbix

![img](assets/1216496-20171226161951729-1965230769.png)

② 检查所依赖的配置，如果有fail，需手动修改

![img](assets/1216496-20171226161952104-733433403.png)

③ 设置数据库的连接

![img](assets/1216496-20171226161952526-269439245.png)

④ 可能有多个zabbix服务器，加标识；非必须，可以不填

![img](assets/1216496-20171226161952870-1150518280.png)

⑤ 没有问题，就开始安装了

![img](assets/1216496-20171226161953276-321534468.png)

⑥ 完成！！！

![img](assets/1216496-20171226161953651-573351206.png)

 

（2）登录，第一次登录默认账号密码

账号：admin

密码：zabbix

![img](assets/1216496-20171226161953901-1515776141.png)

（3）登录进去的仪表盘

![img](assets/1216496-20171226161954526-526455816.png)

 

（4）status of zabbix 仪表盘分析

| Zabbix server is running                                     | Yes  | 192.168.30.107:10051 |
| ------------------------------------------------------------ | ---- | -------------------- |
| ① Number of hosts (enabled/disabled/templates)               | 39   | 0 / 1 / 38           |
| ② Number of items (enabled/disabled/not supported)           | 0    | 0 / 0 / 0            |
| ③ Number of triggers (enabled/disabled [problem/ok])         | 0    | 0 / 0 [0 / 0]        |
| ④ Number of users (online)                                   | 2    | 2                    |
| ⑤ Required server performance, **n**ew **v**alues**p**er **s**econd | 0    |                      |

① 监控主机：已经启用被监控的主机数量，已经配置好缺被禁止主机数，自带模板数

② 监控项：启用多少指标，禁用多少指标，不支持的指标

③ 触发器数量：启用，禁用，处于有问题的

④ 当前zabbix有几个用户：现在是一个是来宾，一个是管理员

⑤ 重点关注的**nvps 每秒的新值（根据我们定义的监控项，每秒采集过来多少新数据，平均值）：**

 

（5）用户管理设置，有大家最喜欢的汉语

![img](assets/1216496-20171226161955057-1240487975.png)

（1）如果英语不好，可以切换为中文，但推荐使用英文，为了更好的讲解，博主使用中文示范

![img](assets/1216496-20171226161955510-418436408.png)

（2）修改密码

![img](assets/1216496-20171226161955870-562066344.png)

 

### 6、被监控node zabbix的安装配置

（1）在node 机器上安装

yum -y install zabbix-**agent** zabbix-**sender** 只需安装这两个包就行

 

（2）配置，和之前一样，先查看一下配置段

① grep -i "^####" zabbix_agentd.conf 先查看一下配置段

GENERAL PARAMETERS 一般配置，有两个子配置段

　　**Passive checks related**   被动接口

　　**Active checks related**   主动接口

ADVANCED PARAMETERS 高级配置

　　**USER-DEFINED MONITORED PARAMETERS** 用户自定义的监控参数（必要，高级的特性）

　　LOADABLE MODULES

　　TLS-RELATED PARAMETERS

![img](assets/1216496-20171226161956245-567303081.png)

② grep -i "^###" zabbix_agentd.conf 查看选项

![img](assets/1216496-20171226161956916-492762727.png)

 

（3）配置

vim **zabbix_agentd.conf**

① EnableRemoteCommands=0 是否允许执行远程命令，默认是不允许的，有安全风险

![img](assets/1216496-20171226161957323-1863997958.png)

```
② 指定服务器主机，可以指定多个
Server=192.168.30.107  
③ 自己的今天IP和端口
ListenPort=10050   自己的监听端口
ListenIP=0.0.0.0     允许监听在本机的地址，0.0.0.0 是监听所有
④ agent个数，被监控项有很多时，可以多写几个
StartAgents=3  默认3个，优化时使用
⑤ 主动监控的机器地址是谁
StartAgents=192.168.30.107
⑥ 能被server段解析的主机名，写IP也行
Hostname=node1.along.com
下边都是默认值就好
```

（4）开启服务

systemctl start **zabbix-agent.service**

 

### 7、node1加入到监控中

（1）先添加一个主机群组host groups

![img](assets/1216496-20171226161957729-1450050565.png)

添加一个mysrvs 的host groups

![img](assets/1216496-20171226161958104-509683281.png)

（2）创建主机

![img](assets/1216496-20171226161958588-884541744.png)

创建一个属于mysrvs 主机组的node1.along.com 主机，若接口写主机，要开启DNS解析

![img](assets/1216496-20171226161958948-1392608366.png)

关于主机加密，在内网中最好不要加密，急耗资源

![img](assets/1216496-20171226161959463-1246039560.png)

 

### 8、对node1主机设置

（1）**监控类别 applications应用集**

![img](assets/1216496-20171226162000088-937102925.png)

创建3个 CPU Utils 、Memory Stats、Network Interface Stats 的应用集

![img](assets/1216496-20171226162000901-1980905980.png)

3个已经生成

![img](assets/1216496-20171226162001151-827957869.png)

 

（2）**创建监控项 items**

![img](assets/1216496-20171226162001495-1506908052.png)

设置名为 rate of interrupt 的**监控项 items**

![img](assets/1216496-20171226162002666-1566172141.png)

备注：

**① key键值：**內建key 、自定义key；对应的是**命令；**服务器自动执行key，就相当于采集数据

每一个key 都对应，能在客户端/agent端，执行的命令；该命令能帮我们取回关系型数据

例：system.cpu.intr cpu中断数的key

![img](assets/1216496-20171226162003135-1674319460.png)

在命令行 **zabbix_get** **-s 192.168.30.7 -p 10050 -k** "system.cpu.intr"

![img](assets/1216496-20171226162004041-678977396.png)

 

② 数据更新间隔：

对于非关键型指标，不要太频繁，使服务器压力很大；推荐5分钟，或以上

为了实验，选择5s；关键型指标，30s（默认的）也很频繁了

 

（3）查看自己设置的监控

![img](assets/1216496-20171226162004666-54071667.png)

查看图形，可以选择不同时间作为坐标轴

![img](assets/1216496-20171226162005276-193326493.png)

 

## 实战二：zabbix 基础操作

**声明：我下边已切换为3.4版本了**

### 1、设置items监控项，采集信息

（1）对node1 添加名为rate of packets(in) 入站包的个数 的items监控项

![img](assets/1216496-20171226162005713-916560731.png)

① key 值选的是： net.if.in[if,<mode>]网络接口上传流量统计；可以加参数

![img](assets/1216496-20171226162006276-1594048664.png)

② 点击进程，可以选择更多选项；比3.2不一样的地方

![img](assets/1216496-20171226162006682-917972853.png)

 

③ 查看图形

![img](assets/1216496-20171226162007073-366044084.png)

 

（2）克隆items 监控项

① 设置rate of packets(out) 出站包的个数，因为和in 很相似，可以克隆再设置

![img](assets/1216496-20171226162007401-307689566.png)

② 修改为out，其他都无需修改

![img](assets/1216496-20171226162007713-2059555908.png)

 

（3）为了后边的实验，多定义2个items 监控项

① rate of bytes(out) 出站字节数

![img](assets/1216496-20171226162008073-1010875961.png)

② rate of bytes(in) 入站字节数

![img](assets/1216496-20171226162008401-772947759.png)

 

### 2、设置trigger 触发器

（1）介绍

① 界定某特定的item采集到的数据的非合理区间或非合理状态：逻辑表达式

② 逻辑表达式，**阈值**：通常用于定义数据的不合理区间；

　　OK：正常 状态 --> 不满足阈值（不合理区间）为OK

　　PROBLEM：非正常状态 --> 满足阈值

③ 触发器存在可调用的函数：（对数据进行评估）

　　**nodata()：**没有数据

　　**last()：**最近几次的平均值

　　date()

　　time()

　　now()

　　dayofmonth()

　　...

注意：常用**nodata()、last()；**能用数值采集的结果保存，就不要用字符串；计算机处理数值要快的多

 

（2）创建trigger 触发器

① 创建

![img](assets/1216496-20171226162008682-1957219512.png)

② 设置

![img](assets/1216496-20171226162009166-1026937622.png)

③ **表达式**可以自己手写；也可以按选择生成

次数count / 时间time 选项：二选一

![img](assets/1216496-20171226162009510-1361196530.png)

time 时间

![img](assets/1216496-20171226162009760-1958202888.png)

④ 下边的选择根据自己的需求选择，我没有设置

![img](assets/1216496-20171226162010104-2096998691.png)

 

（3）查看图形，会发现多了一根警告线

![img](assets/1216496-20171226162010588-2010160195.png)

 

### 3、设置触发器的依赖关系

（1）介绍

① 在一个网络中，**主机**的可用性之间可能**存在依赖关系**

　　例如，当某网关主机不可用时，其背后的所有主机都将无法正常访问

　　如果所有主机都配置了触发器并定义了相关的通知功能，相关人员将会接收到许多告警信息，这既不利于快速定位问题，也会浪费资源

　　正确定义的触发器依赖关系可以避免类似情况的发生，它将使用通知机制仅发送最根本问题相关的告警

② 注意：目前zabbix 不能够直接定义主机间的依赖关系，其**依赖关系仅能通过触发器来定义**

（2）依赖的解释：

**被依赖者会报警；依赖者不会报警**

![img](assets/1216496-20171226162010932-1074344939.png)

分析：监控到交换机故障，网卡和主机上的服务不用报警；

监控到主机上的服务，网卡和交换机不用报警

（3）设置依赖

![img](assets/1216496-20171226162011323-1673297451.png)

 

### 4、设置Media 媒介

（1）Media 的介绍

Media：媒介，告警信息的传递通道；任何用户收到报警信息，都需要有媒介的端口

　　类型：下面3个中国都没实现，中国可以实现微信，需要特殊插件

　　　　**Email：邮件**

　　　　**Script：自定义脚本，每一个script都是一个媒介**

　　　　SMS：短信，只适用于北美地区

　　　　Jabber：

　　　　Ez Texting：

　　接收信息的目标为zabbix用户：

　　　　需要用户上定义对应各种媒介通道的接收方式；

每一类媒介，也能分很多种类型，如下图

![img](assets/1216496-20171226162011620-1084580452.png)

系统自带的3中媒介

![img](assets/1216496-20171226162012041-2073394703.png)

 

（2）定义一个media ，可以在email 模板上直接修改

![img](assets/1216496-20171226162012448-1822505433.png)

在选项中可以设置并发会话

![img](assets/1216496-20171226162012760-1363431329.png)

 

（3）用户使用media媒介

① 选择用户中的admin用户

![img](assets/1216496-20171226162013057-1758511281.png)

② 添加media 报警媒介，一个用户可以添加多个

![img](assets/1216496-20171226162013573-96329789.png)

为了实验展示，我选择所有等级

 

（4）实现给公司用户发短信的媒介

① 创建一个名为 duanxin 的媒介

![img](assets/1216496-20171226162013885-1460663105.png)

设置，关于发短信的脚本，网上有很多，自己找一个使用

![img](assets/1216496-20171226162014323-1041319633.png)

② 设置个用户，使用duanxin的媒介

![img](assets/1216496-20171226162014713-1573089342.png)

 

（5）互联网中有发微信做媒介的

需先发个公众号，且公众号中所有人都能收到

 

### 5、设置Actions 动作

（1）设置action 动作的准备

① 准备一个被监控的服务redis

yum -y install redis 下载一个redis 服务做实验

vim /etc/redis.conf 修改配置文件

bind 0.0.0.0 监听本机所有端口

systemctl start redis 开启服务

 

② 因为要执行动作时需远程操作，给admin 用户设置sudo权限

a) visudo 修改sudo的配置

zabbix ALL=(ALL) NOPASSWD: ALL 允许zabbix用户能在所有主机，以所有人的身份执行所有命令

![img](assets/1216496-20171226162015026-1168279940.png)

Defaults !visiblepw 默认所有命令要依靠tty执行，先注释掉

![img](assets/1216496-20171226162015245-870896165.png)

 

b) vim zabbix_agentd.conf 设置agent允许执行远程命令

EnableRemoteCommands=1 允许执行远程命令

LogRemoteCommands=1 把远程执行的命令记录在日志中

![img](assets/1216496-20171226162015526-1063961092.png)

systemctl restart zabbix-agent.service 重启zabbix-agent服务

 

（2）设置redis 的监控项items

![img](assets/1216496-20171226162015901-278059186.png)

① 监控端口的key

net.tcp.listen[port] 监听本地listen：检查 TCP端口是否处于侦听状态，返回 0 - 未侦听；1 - 正在侦听

net.tcp.port[<ip>,port]：server远程扫描redis服务：检查是否能建立 TCP 连接到指定端口，返回 0 - 不能连接；1 - 可以连接

net.tcp.service[service,<ip>,<port>] 直接指定服务：检查服务是否运行并接受 TCP 连接，返回 0 - 服务关闭；1 - 服务运行

 

（3）设置triggers 触发器

![img](assets/1216496-20171226162016338-519176799.png)

① 设置表达式

![img](assets/1216496-20171226162016713-1313012718.png)

 

（4）设置action 动作

a) 创建一个action

![img](assets/1216496-20171226162017041-781057498.png)

 

b) 设置action

① 设置action 的动作

![img](assets/1216496-20171226162017495-647408633.png)

② 设置action 的操作

![img](assets/1216496-20171226162017885-1970677659.png)

③ 设置要操作的步骤1：重启redis服务

![img](assets/1216496-20171226162018354-1851787906.png)

④ 设置要操作的步骤2：给admin发邮件

![img](assets/1216496-20171226162018713-141459469.png)

⑤ 设置完的action 的操作：共两步

![img](assets/1216496-20171226162019120-1155858297.png)

 

c) 设置action 的恢复操作

![img](assets/1216496-20171226162019432-2023535639.png)

d) 设置action 成功

 

### 6、测试动作

（1）手动停掉redis 服务，模拟服务故障

systemctl stop redis

 

（2）可以看到problem 问题已产生

① 问题生成

![img](assets/1216496-20171226162020041-1243492008.png)

② 执行动作，10s，第一个action 1 执行成功，problem问题解决

因为第一个action1 执行成功，所以action 2没有执行

![img](assets/1216496-20171226162020760-373245219.png)

③ 恢复操作执行了，zabbix server 收到了mail "Resolved"

![img](assets/1216496-20171226162021135-1074445509.png)

 

 

（3）模拟故障，且无法恢复

systemctl stop redis && rpm -e redis 停止服务，且删除redis

① 问题产生

![img](assets/1216496-20171226162021573-1392189193.png)

② action 1 无法完成

![img](assets/1216496-20171226162022026-1190913309.png)

③ action 2 执行：给admin 发邮件

![img](assets/1216496-20171226162022495-1563448521.png)

 

## 实战三、展示接口的实现

### 1、Graphs 图形的设置

（1）创建一个图形

![img](assets/1216496-20171226162022776-1530309551.png)

设置一个名为interface traffic packets 的图形

![img](assets/1216496-20171226162023245-1462997592.png)

图形类别展示：

① normal 正常的

注释：

　　工作时间：白色

　　非工作时间：黑色

![img](assets/1216496-20171226162023745-926553558.png)

② Stacked 层积的

![img](assets/1216496-20171226162024338-770268828.png)

③ Pie

![img](assets/1216496-20171226162024932-887435700.png)

④ Exploded 爆发式图形

![img](assets/1216496-20171226162025541-628887816.png)

设置完后：加入两个监控项

rate of packets(in)

rate of packets(out)

![img](assets/1216496-20171226162026041-1098424450.png)

 

（2）仿照上边的，再创建2个图形

① interface traffic bytes 加入2个监控项

rate of bytes(in)

rate of bytes(out)

![img](assets/1216496-20171226162026479-35543527.png)

② redis status 加入一个监控项

redis status

![img](assets/1216496-20171226162026807-200060247.png)

 

### 2、定义Screens 聚合图形

（1）创建screen 屏幕

![img](assets/1216496-20171226162027073-1496707269.png)

 

（2）设置screens

![img](assets/1216496-20171226162027354-1702614442.png)

 

### 3、把graphs 图形加入到screens 屏幕中

（1）编辑上边设置的screens

![img](assets/1216496-20171226162027698-1037009608.png)

 

（2）点击更改，把3个graphs 加入进来

① graph加入screen

![img](assets/1216496-20171226162028041-316745882.png)

② 设置

![img](assets/1216496-20171226162028401-1331547389.png)

③ 添加成功，在浏览器上可以按F11 ，全屏查看

![img](assets/1216496-20171226162028776-848754208.png)

 

### 4、多个screens可以做成幻灯片

（1）再设置一个screens

![img](assets/1216496-20171226162029198-352811130.png)

 

（2）设置Slide shows 幻灯片

① 创建一个幻灯片

![img](assets/1216496-20171226162029588-1069231523.png)

② 把两个screens 加入到幻灯片设置中

![img](assets/1216496-20171226162029854-1859154673.png)

② 播放幻灯片，5s 会切换一次

![img](assets/1216496-20171226162030307-1656890305.png)

 

![img](assets/1216496-20171226162030760-1944205356.png)

 

### 5、Maps 拓扑图

Local network 自带的maps 拓扑图；用处不是想象中那么大，就不讲了

![img](assets/1216496-20171226162031104-764792664.png)

 

## 实战四、Templates 模板和macro 宏

### 1、Templates 模板

（1）模板介绍：

　　主机配置模板：用于链接至目标主机实现快速监控管理；

​        　　link, unlink, unlink and clear

　　 **模板可继承；**

　　 主机link多个模板必须注意，模板们不能含有相同的item key。trigger和graphs中使用的items不能是来自多个模板。

（2）创建template 模板

① 创建

![img](assets/1216496-20171226162031745-1580537377.png)

② 设置template 模板

![img](assets/1216496-20171226162032151-405464777.png)

③ complete 模板，应用集application、监控项items、触发器triggers、图形graphs、屏幕screens、自动发现discover rules、web检测web scenarios。

　　模板complete 的一系列添加设置，和主机host 几乎一模一样，但是不会直接生效、采集数据；只有链接至主机才能生效、采集数据

　　区别：**主机接口**；complete 没有；host 有

host 有主机接口

![img](assets/1216496-20171226162032385-1041563096.png)

complete 没有主机接口

![img](assets/1216496-20171226162032666-727178563.png)

 

④ 导入模板

可以在网上找到很多不错的别人定义的模板，可以直接导入

![img](assets/1216496-20171226162032963-8119132.png)

 

![img](assets/1216496-20171226162033557-1953852984.png)

 

⑤ 也可导出自己的模板给其他人使用

![img](assets/1216496-20171226162034151-1291914907.png)

 

（3）在hosts 中导入模板complete

① 导入

![img](assets/1216496-20171226162037479-473759521.png)

② 导入成功

![img](assets/1216496-20171226162038245-550916718.png)

 

（4）不想在host主机中使用模板，可以**取消链接 或 取消并清除**

![img](assets/1216496-20171226162038682-1366633624.png)

 

（5）组group 使用模板

如果有很多属于同一组内的主机host，想快速基于某模板监控，组group添加模板

![img](assets/1216496-20171226162039041-807732973.png)

 

（6）模板也可以链接到其他模板

![img](assets/1216496-20171226162039448-16956245.png)

 

### 2、宏：macro，预设的文本替换模式

（1）介绍

级别：

　　**全局**：Administration --> General --> Macros ，对所有主机、所有模板都有效，优先级很低

　　**模板**：编辑模板 --> Macros ，对所有链接至此模板的主机都有效

　　**主机**：编辑主机 --> Macros ，仅对单个主机有效

类型：

　　内建宏：调用 {MACRO_NAME}

　　自定义：{$MACRO_NAME} ；命名方式：大写字母、数字和下划线

查询宏的官方文档：

<https://www.zabbix.com/documentation/3.4/manual/appendix/macros/supported_by_location>

 

（2）设置使用宏

① 还以redis 为例

yum -y install redis

vim /etc/redis.conf

bind 0.0.0.0 #监听本地所有端口

systemctl start redis 开启服务

 

② 定义**全局宏**

![img](assets/1216496-20171226162039760-1584926674.png)

③ 在items 监控项中调用

![img](assets/1216496-20171226162040213-1799027168.png)

④ 调用成功

![img](assets/1216496-20171226162040588-286594691.png)

⑤ 设置模板宏

![img](assets/1216496-20171226162041026-366022635.png)

⑥ 定义主机宏

![img](assets/1216496-20171226162041401-67088214.png)

注意：宏的优先级：host 主机宏 > complete 模板宏 > 全局宏

# 企业级监控工具应用实战-zabbix操作进阶



## 一、User parameters 用户参数

### 1、介绍和用法

① 介绍

自定义用户参数，也就是自定义key

有时，你可能想要运行一个代理检查，而不是Zabbix的预定义

你可以**编写一个命令**来**检索需要的数据**，并将其包含在代理配置文件("UserParameter"配置参数)的**用户参数**中

② 用法格式 syntax

**UserParameter=<key>,<command>**

　　A user parameter also contains a key　　一个用户参数也包含一个键

　　The key will be necessary when configuring an item 　　在配置监控项时，key是必需的

　　Note: Need to restart the agent 　　注意:需要重新启动agent 服务

 

### 2、用法展示

（1）修改agent 端的配置，设置用户参数

① free | awk '/^Mem/{print $3}' 自己需要查找的参数的命令

![img](assets/1216496-20171226171855010-665295523.png)

② 修改配置文件，把查找参数的命令设为用户参数

cd /etc/zabbix/zabbix_agentd.d/

vim **memory_usage.conf**

**UserParameter=memory.used,free | awk '/^Mem/{print $3}'**

③ systemctl restart zabbix-agent.service 重启agent 服务

（2）在zabbix-server 端，查询

zabbix_get -s 192.168.30.7 -p 10050 -k "memory.used"

![img](assets/1216496-20171226172647557-2133137319.png)

（3）在监控上，设置一个item监控项，使用这个用户参数

![img](https://images2017.cnblogs.com/blog/1216496/201712/1216496-20171226172026041-1695073569.png)

（4）查询graph 图形

![img](assets/1216496-20171226172026463-839175044.png)

 

### 3、用法升级

（1）修改agent 端的配置，设置用户参数

① 命令行查询参数的命令

![img](assets/1216496-20171226172026698-1464978164.png)

② 修改配置文件，把查找参数的命令设为用户参数

UserParameter=**memory.stats[\*]**,cat /proc/meminfo | awk **'/^$1/{print $$2}**'

分析：$$2：表示不是前边调位置参数的$2 ，而是awk 的参数$2

注意：$1是调用前边的[*]，位置参数，第一个参数

 

（2）在zabbix-server 端，查询使用这个用户参数的key

![img](assets/1216496-20171226172026932-1905881550.png)

 

（3）在监控上，设置一个item监控项，使用这个用户参数

① 添加Memory Total 的item监控项，使用**memory.stats[MemTotal]** 的用户参数

![img](assets/1216496-20171226172027260-1446706159.png)

在进程中定义倍数，规定单位

![img](assets/1216496-20171226172027729-143163327.png)

 

② clone 克隆Memory Total 创建Memory Free 的监控项

**memory.stats[MemFree]** 用户参数

![img](assets/1216496-20171226172028120-539441659.png)

③ 创建Memory Buffers 的item 监控项，使用 **memory.stats[Buffers]** 的key

![img](assets/1216496-20171226172028448-41169528.png)

 

（4）上面3个监控项的graph 图形

① memory total

![img](assets/1216496-20171226172028745-1274821835.png)

② memory free

![img](assets/1216496-20171226172029088-1142382464.png)

③ buffers

![img](assets/1216496-20171226172029338-158312847.png)

 

### 4、使用用户参数监控php-fpm 服务的状态

在agent 端：

（1）下载，设置php-fpm

① yum -y install php-fpm

② vim /etc/php-fpm.d/www.conf 打开php-fpm的状态页面

```
user = nginx
group = nginx
pm.status_path = /php-fpm-status    #php-fpm 的状态监测页面
ping.path = /ping      #ping 接口，存活状态是否ok
ping.response = pong    #响应内容pong
```

③ systemctl start php-fpm 开启服务

 

（2）设置nginx ，设置代理php，和php-fpm的状态页面匹配

① vim /etc/nginx/nginx.conf

```
location ~ \.php$ {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
}
location ~* /(php-fpm-status|ping) {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $fastcgi_script_name;
            include        fastcgi_params;

            allow 127.0.0.1;   #因为这个页面很重要，所有需加访问控制
            deny all;

            access_log off;   #访问这个页面就不用记录日志了
}
```

![img](assets/1216496-20171226172029791-156116121.png)

② systemctl start nginx 开启nginx服务

 

（3）在agent 端，设置用户参数

① 查询 curl 192.168.30.7/php-fpm-status

![img](assets/1216496-20171226172030088-1020205629.png)

② 设置

cd /etc/**zabbix/zabbix_agentd.d/**

vim php_status.conf

**UserParameter=php-fpm.stats[\*]**,**curl -s http://127.0.0.1/php-fpm-status | awk '/^$1/{print $$NF}'**

分析：设置用户参数为php-fpm.stats[*]，$1为第一个参数；$$NF为awk中的参数，倒数第一列

 

③ 重启服务

systemctl restart zabbix-agent

 

（4）在zabbix-server 端，查询使用这个用户参数的key

zabbix_get -s 192.168.30.7 -p 10050 -k "php-fpm.stats[idle]"

zabbix_get -s 192.168.30.7 -p 10050 -k "php-fpm.stats[active]"

zabbix_get -s 192.168.30.7 -p 10050 -k "php-fpm.stats[max active]"

![img](assets/1216496-20171226172030323-150229024.png)

 

（5）创建一个模板，在模板上创建4个item监控项，使用定义的用户参数

① 创建一个模板

![img](assets/1216496-20171226172030682-152674187.png)

② 在模板上配置items 监控项，使用刚定义的用户参数

**fpm.stats[total processes]**

![img](assets/1216496-20171226172031120-396201427.png)

③ 再clone克隆几个items监控项

**fpm.stats[active processes]**

![img](assets/1216496-20171226172031495-1001452204.png)

④ **fpm.stats[max active processes]**

![img](assets/1216496-20171226172031807-398956119.png)

⑤ **fpm.stats[idle processes]**

![img](assets/1216496-20171226172032120-165244744.png)

 

（6）host主机链接模板

![img](assets/1216496-20171226172032495-2030001112.png)

 

（7）查看graph 图形

① php-fpm total processes

![img](assets/1216496-20171226172032760-1387400769.png)

② php-fpm active processes

![img](assets/1216496-20171226172033276-1849464959.png)

③ php-fpm max active processes

![img](assets/1216496-20171226172033573-911796042.png)

④ php-fpm idle processes

![img](assets/1216496-20171226172034198-1450005062.png)

 

（8）把模板导出，可以给别人使用

① 导出模板

![img](assets/1216496-20171226172034682-1229092767.png)

最下面有导出

![img](assets/1216496-20171226172035088-116185645.png)

② 自己定义用户参数的文件，也不要忘记导出

/etc/zabbix/zabbix_agentd.d/php_status.conf

 

## 二、Network discovery 网络发现

### 1、介绍

（1）介绍

网络发现：zabbix server**扫描指定网络范围内的主机**；

网络发现是zabbix 最具特色的功能之一，它能够根据用户**事先定义的规则自动添加监控的主机或服务**等

优点：

　　加快Zabbix部署

　　简化管理

在快速变化的环境中使用Zabbix，而不需要过度管理

 

（2）发现方式：

ip地址范围；

　　可用服务（ftp, ssh, http, ...）

　　zabbix_agent的响应；

　　**snmp**_agent的响应；

 

（3）网络发现通常包含两个阶段：discovery发现 和actions动作

① discovery：

Zabbix定期扫描网络发现规则中定义的IP范围；检查的频率对于每个规则都是可配置的

每个规则都有一组用于为IP范围执行的服务检查

由网络发现模块执行的服务和主机(IP)的每个检查都会生成一个发现事件

8种响应事件

![img](assets/1216496-20171226172035479-1598541190.png)

② actions：网络发现中的事件可以触发action，从而自动执行指定的操作，把discvery events当作前提条件；

　　Sending notifications 发送通知

　　Adding/removing hosts 添加/删除主机

　　Enabling/disabling hosts 启用/禁用host

　　Adding hosts to a group 向组中添加主机

　　Removing hosts from a group 移除组中的主机

　　Linking hosts to/unlinking from a template 从模板链接主机或取消链接

　　Executing remote scripts 执行远程脚本

这些事件的配置还可以基于设备的类型、IP 、状态、上线/ 离线等进行配置

 

（4）网络发现：接口添加

网络发现中添加主机时会自动创建interface 接口

例如：

　　如果基于SNMP 检测成功，则会创建SNMP 接口

　　如果某服务同时响应给了agent 和SNMP ，则**两种接口都会创建**

　　如果同一种发现机制( 如agent) 返回了非惟一数据，则**第一个接口被识别为默认，其它的为额外接口**

　　即便是某主机开始时只有agent 接口，后来又通过snmp 发现了它，同样会为其添加额外的snmp 接口

　　不同的主机如果返回了相同的数据，则第一个主机将被添加，余下的主机会被当作第一个主机的额外接口

 

### 2、配置网络发现Network discovery

（1）准备一台可被扫描发现的主机

① 安装agent 段的包

yum -y install zabbix-agent zabbix-sender

② 设置agent 配置，可以把之前设置好的node1的配置传过来

vim /etc/zabbix/zabbix_agentd.conf

Hostname=node2.along.com #只需修改hostname

③ visudo 修改sudo的配置

\#Defaults !visiblepw

zabbix ALL=(ALL) NOPASSWD: ALL

![img](assets/1216496-20171226172036745-511117378.png)

④ 开启服务

systemctl start zabbix-agent

 

（2）设置自动发现规则discovery

![img](assets/1216496-20171226172037370-800415726.png)

注释：

① key：zabbix_get -s 192.168.30.2 -p 10050 -k "system.hostname"

![img](assets/1216496-20171226172037635-349059993.png)

② 更新间隔：1h就好，不要扫描太过频繁，扫描整个网段，太废资源；这里为了实验，设为1m

 

（3）自动发现成功

![img](assets/1216496-20171226172037948-2146168679.png)

 

（4）设置自动发现discovery 的动作action

a) 创建

![img](assets/1216496-20171226172038182-11402625.png)

b) 设置action动作

![img](assets/1216496-20171226172038541-1323988067.png)

① 设置A条件，自动发现规则=test.net

② 设置B条件，自动发现状态=up

![img](assets/1216496-20171226172038823-1466028368.png)

③ 要做什么操作

添加主机到监控

自动链接Template OS Linux 到此host

![img](assets/1216496-20171226172039213-1479221797.png)

c) 配置action 完成，默认是disabled 停用的

![img](assets/1216496-20171226172039526-1399823520.png)

d) 启用动作，查看效果

确实已经生效，添加主机成功，模板链接成功

![img](assets/1216496-20171226172039979-1033265636.png)

 

（5）如果自己需要添加的主机已经扫描添加完成，就可以关闭网络扫描了，因为太耗资源

 

## 三、web监控

### 1、介绍

（1）介绍

① Web监控：监控指定的站点的**资源下载速度**，及**页面响应时间**，还有**响应代码**；

② 术语：

　　web Scenario： web场景（站点）

　　web page ：web页面，一个场景有多个页面

　　內建key：要测一个页面，要测三个步骤（下边3个內建key）

③ 内建key：

　　 web.test.in[Scenario,Step,bps]：传输速率

　　 web.test.time[Scenario,Step]： 响应时长

　　 web.test.rspcode[Scenario,Step]：响应码

 

### 2、创建设置web场景

（1）创建

![img](assets/1216496-20171226172040229-465393880.png)

 

（2）配置web 监测

![img](assets/1216496-20171226172040588-1557305887.png)

① 点击步骤，设置web page web页面

a) 设置名为home page，URL为http://192.168.30.7/index.html 的web页面

![img](assets/1216496-20171226172040885-1526168288.png)

b) 设置名为fpm status，URL为http://192.168.30.7/fpm-status 的web页面

![img](assets/1216496-20171226172041291-925383434.png)

c) 设置2个web页面成功

![img](assets/1216496-20171226172041870-962857372.png)

② 如果有特殊认证，也可以添加

![img](assets/1216496-20171226172042166-1660206125.png)

 

### 3、查看测试

![img](assets/1216496-20171226172042510-1962638311.png)

 

## 四、主动/被动 监控

### 1、介绍

（1）主动/被动介绍

　　被动检测：相对于agent而言；agent, **server向agent请求获取配置的各监控项相关的数据**，agent接收请求、获取数据并响应给server；

　　主动检测：相对于agent而言；agent(active),**agent向server请求与自己相关监控项配置**，主动地将server配置的监控项相关的数据发送给server；

　　主动监控能极大节约监控server 的资源。

（2）zabbix_sender发送数据：实现人工生成数据，发给server端

① zabbix server上的某主机上，直接定义Item时随便定义一个不与其它已有key冲突的key即可，即item type为"zabbix trapper"；

② 用法选项：

zabbix_sender

　　-z zabbix_server_ip

　　-p zabbix_server_port

　　-s zabbix_agent_hostname

　　-k key

　　-o value 值

 

### 2、设置一个通过內建key发送数据的主动监控

（1）agent端所需要基本配置：

```
ServerActive=192.168.30.107   给哪个监控server 发送数据
Hostname=node1.along.com   自己的主机名，假设主机定死了，不设置下一项
#HostnameItem=   如果自己的主机名易变动，这一项相当于key一样去匹配
```

注意：若后两项同时启用，下边一个选择生效

 

（2）设置一个主动监测

![img](assets/1216496-20171226172042870-1427172290.png)

① 选择进程，每秒更改，

因为key：system.cpu.switches ：上下文的数量进行切换，它返回一个整数值。为了监控效果，选择下一秒减上一秒的值作为监控

![img](assets/1216496-20171226172043120-1810882608.png)

（3）已经有啦graph图形

![img](assets/1216496-20171226172043526-25418384.png)

 

### 3、设置一个通过命令zabbix_sender发送数据的主动监控

（1）配置一个zabbix traper(采集器) 的item 监控项

![img](assets/1216496-20171226172043838-1551635865.png)

（2）agent 端手动发送数据

![img](assets/1216496-20171226172044120-1117751325.png)

（3）监控到数据的变化

![img](assets/1216496-20171226172044682-2050320416.png)

 

## 五、基于SNMP监控（了解）

### 1、介绍

（1）介绍

SNMP：**简单**网络管理协议；（非常古老的协议）

三种通信方式：读（get, getnext）、写（set）、trap（陷阱）；

端口：

　　161/udp

　　162/udp

SNMP协议：年代久远

　　v1: 1989

　　**v2c**: 1993

　　v3: 1998

监控网络设备：交换机、路由器

MIB：Management Information Base 信息管理基础

OID：Object ID 对象ID

 

（2）Linux启用snmp的方法：

yum install net-snmp net-snmp-utils

配置文件：定义ACL

　　/etc/snmp/snmpd.conf

启动服务：

　　systemctl start snmpd 被监控端开启的服务

　　 systemctl start snmptrapd    监控端开启的服务（如果允许被监控端启动主动监控时启用）

 

（3）配置文件的介绍

开放数据：4步

![img](assets/1216496-20171226172045276-679726746.png)

① 定义认证符，将社区名称"public"映射为"安全名称"

② 将安全名称映射到一个组名

③ 为我们创建一个视图，让我们的团队有权利

**掩码：**我列出一些注释，有很多，可以再网上查询

**.1.3.6.1.2.1.**

　　 1.1.0：系统描述信息，SysDesc

　　 1.3.0：监控时间， SysUptime

　　 1.5.0：主机名，SysName

　　 1.7.0：主机提供的服务，SysService

.1.3.6.1.2.2.

　　 2.1.0：网络接口数目

　　 2.2.1.2:网络接口的描述信息

　　 2.2.1.3:网络接口类型

　　 ……

![img](assets/1216496-20171226172045604-1497693285.png)

④ 授予对systemview视图的只读访问权

 

（4）测试工具：

​    \# **snmpget** -v 2c -c public HOST OID

​    \# **snmpwalk** -v 2c -c public HOST OID 通过这个端口查询到的数据，全列出了

![img](assets/1216496-20171226172045948-698976544.png)

 

### 2、配置SNMP监控

（1）下载，修改配置文件

vim /etc**/snmp/snmpd.conf**

```
view    systemview    included   .1.3.6.1.2.1.1
view    systemview    included   .1.3.6.1.2.1.2   # 网络接口的相关数据
view    systemview    included   .1.3.6.1.4.1.2021   # 系统资源负载，memory, disk io, cpu load 
view    systemview    included   .1.3.6.1.2.1.25
```

（2）在agent 上测试

snmpget -v 2c -c public 192.168.30.2 .1.3.6.1.2.1.1.3.0

snmpget -v 2c -c public 192.168.30.2 .1.3.6.1.2.1.1.5.0

![img](assets/1216496-20171226172046245-1946753487.png)

 

（3）在监控页面，给node2加一个snmp的接口

![img](assets/1216496-20171226172046541-990434657.png)

（4）在node2上加一个 Template OS Linux SNMPv2 模板

![img](assets/1216496-20171226172046854-1430722762.png)

模板添加成功，生成一系列东西

![img](assets/1216496-20171226172047151-639977143.png)

点开一个item 看一下

![img](assets/1216496-20171226172047463-1455547608.png)

 

（5）生成一些最新数据的图形graph了

![img](assets/1216496-20171226172047729-481410869.png)

 

### 3、设置入站出站packets 的SNMP监控

（1）监控网络设备：交换机、路由器的步骤：

① 把交换机、路由器的SNMP 把对应的OID的分支启用起来

② 了解这些分支下有哪些OID，他们分别表示什么意义

③ 我们要监控的某一数据：如交换机的某一个接口流量、报文，发送、传入传出的报文数有多少个；传入传出的字节数有多少个，把OID取出来，保存

 

（2）定义入站出站的item监控项

interface traffic packets(in)

![img](assets/1216496-20171226172048182-394941521.png)

interface traffic packets(out)

![img](assets/1216496-20171226172048510-973935048.png)

 

## 六、JMX接口

![img](assets/1216496-20171226172048698-2048639928.png)

### 1、介绍

（1）介绍

Java虚拟机(JVM)具有内置的插装，使您能够使用JMX监视和管理它。您还可以使用JMX监视工具化的应用程序。

（2）配置设置介绍

① zabbix-java-gateway主机设置：

　　安装 zabbix-java-gateway程序包，启动服务；

　　yum -y install zabbix-java-gateway

② zabbix-server端设置（需要重启服务）：

　　**JavaGateway=**172.16.0.70

　　**JavaGatewayPort=**10052

　　**StartJavaPollers=**5 #监控项

③ tomcat主机设置：

　　 监控tomcat：

　　　　 /etc/sysconfig/tomcat，添加

　　**CATALINA_OPTS**="-Djava.rmi.server.hostname=TOMCAT_SERVER_IP -Djavax.management.builder.initial= -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=12345 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"   #启用JVM接口，默认没有启用

 

　　添加监控项：

　　　　jmx[object_name,attribute_name]

　　　　　　object name - 它代表MBean的对象名称

　　　　　　attribute name - 一个MBean属性名称，可选的复合数据字段名称以点分隔

　　　　示例：

　　　　　　 jmx["java.lang:type=Memory","HeapMemoryUsage.used"]

 

④ jmx的详细文档：https://docs.oracle.com/javase/1.5.0/docs/guide/management/agent.html

 

### 2、配置JVM接口监控

（1）安装配置tomcat

① 下载安装tomcat，主要是用JVM

yum -y install **java-1.8.0-openjdk-devel tomcat-admin-webapps tomcat-docs-webapp**

② 加CATALINA_OPTS= #启用JVM接口，默认没有启用

vim /etc/sysconfig/tomcat

```
CATALINA_OPTS="-Djava.rmi.server.hostname=192.168.30.2 -Djavax.management.builder.initial= -Dcom.sun.management.jmxremote=true   -Dcom.sun.management.jmxremote.port=12345  -Dcom.sun.management.jmxremote.ssl=false  -Dcom.sun.management.jmxremote.authenticate=false"
```

③ 开启服务

systemctl start tomcat

 

（2）在**zabbix-server 端**，安装配置java-gateway

① 安装配置java-gateway

yum -y install zabbix-java-gateway

/etc/zabbix/zabbix_java_gateway.conf 安装完后，会生成一个java_gateway 的配置文件

systemctl start zabbix-java-gateway.service 不用修改，直接开启服务

 

② 修改server 配置，开启java-gateway的配置

vim /etc/zabbix/**zabbix_server.conf**

```
JavaGateway=192.168.30.107  
JavaGatewayPort=10052
StartJavaPollers=5    #打开5个监控项
```

③ systemctl restart zabbix-server 重启zabbix-server 服务

 

（3）在node2 主机上添加JMX接口，实验模板

① 添加JMX接口

![img](assets/1216496-20171226172049182-664693382.png)

② 在node2 上连接tomcat JMX 模板

![img](assets/1216496-20171226172049541-701630088.png)

③ 随便查看一个监控项item

![img](assets/1216496-20171226172050010-1062166097.png)

 

（4）自己定义一个堆内存使用的监控项，基于JVM接口（没必要，使用模板就好）

![img](assets/1216496-20171226172050479-619246539.png)

 

## 七、分布式监控

![img](assets/1216496-20171226172050995-2135249770.png)

### 1、介绍

（1）介绍

分布式监控概述

　　proxy and node

Zabbix 的三种架构

　　Server-agent

　　Server-Node-agent

　　Server-Proxy-agent

监控Zabbix

 

（2）配置介绍

Zabbix Proxy的配置：

　　server-node-agent

　　server-proxy-agent

a) 配置proxy主机：

(1) 安装程序包

​    zabbix-proxy-mysql zabbix-get

​    zabbix-agent zabbix-sender

(2) 准备数据库

　　创建、授权用户、导入schema.sql；

(3) 修改配置文件

　　Server=

　　　　zabbix server主机地址；

　　Hostname=

　　　　当前代理服务器的名称；在server添加proxy时，必须使用此处指定的名称；

　　　　=需要事先确保server能解析此名称；

　　DBHost=

　　DBName=

　　DBUser=

　　DBPassword=

 

　　ConfigFrequency=10

　　DataSenderFrequency=1

 

b) 在server端添加此Porxy

​    Administration --> Proxies

 

c) 在Server端配置通过此Proxy监控的主机；

注意：zabbix agent端要允许zabbix proxy主机执行数据采集操作：

 

### 2、实现分布式zabbix proxy监控

实验前准备：

① ntpdate 172.168.30.1 同步时间

② 关闭防火墙，selinux

③ 设置主机名 hostnamectl set-hostname zbproxy.along.com

④ vim /etc/hosts 每个机器都设置hosts，以解析主机名；DNS也行

192.168.30.107 server.along.com

192.168.30.7 node1.along.com

192.168.30.2 node2.along.com

192.168.30.3 node3.along.com zbproxy.along.com

![img](assets/1216496-20171226172051276-274670232.png)

（1）环境配置（4台主机）

| 机器名称      | IP配置         | 服务角色  |
| ------------- | -------------- | --------- |
| zabbix-server | 192.168.30.107 | 监控      |
| agent-node1   | 192.168.30.7   | 被监控端  |
| agent-node2   | 192.168.30.2   | 被监控端  |
| node3         | 192.168.30.3   | 代理proxy |

 

zabbix-server 直接监控一台主机node1

zabbix-server 通过代理node3 监控node2

 

（2）在node3 上配置mysql

① 创建配置mysql

vim /etc/my.cnf.d/server.cnf

```
[server]
skip_name_resolve = on
innodb_file_per_table = on
innodb_buffer_pool_size = 256M
max_connections = 2000
log-bin = master-log
```

② systemctl start mariadb 开启服务

③ 创建数据库 和 授权用户

```
MariaDB [(none)]> create database zbxproxydb character set 'utf8';
MariaDB [(none)]> grant all on zbxproxydb.* to 'zbxproxyuser'@'192.168.30.%' identified by 'zbxproxypass';
MariaDB [(none)]> flush privileges;
```

（3）在node3 上下载zabbix 相关的包，主要是代理proxy的包

yum -y install **zabbix-proxy-mysql** zabbix-get zabbix-agent zabbix-sender

 

a) **初始化数据库**

zabbix-proxy-mysql 包里带有，导入数据的文件

![img](assets/1216496-20171226172052791-1016956277.png)

cp /usr/share/doc/zabbix-proxy-mysql-3.4.4/schema.sql.gz ./ 复制

gzip -d schema.sql.gz 解包

mysql -root -p zbxproxydb < schema.sql 导入数据

 

b) 查看数据已经生成

![img](assets/1216496-20171226172053276-1712858671.png)

 

（4）配置proxy端

① vim /etc/zabbix/zabbix_proxy.conf

![img](assets/1216496-20171226172053682-47495044.png)

```
Server=192.168.30.107   #server 的IP
ServerPort=10051   #server 的端口

Hostname=zbxproxy.along.com   #主机名
ListenPort=10051    #proxy自己的监听端口
EnableRemoteCommands=1    #允许远程命令
LogRemoteCommands=1    #记录远程命令的日志

数据的配置
DBHost=192.168.30.3
DBName=zbxproxydb  
DBUser=zbxproxyuser
DBPassword=zbxproxypass

ConfigFrequency=30    #多长时间，去服务端拖一次有自己监控的操作配置；为了实验更快的生效，这里设置30秒，默认3600s
DataSenderFrequency=1   #每一秒向server 端发一次数据，发送频度
```

② systemctl start zabbix-proxy 开启服务

 

（5）配置node2端，允许proxy代理监控

vim /etc/zabbix/zabbix_agentd.conf

```
Server=192.168.30.107,192.168.30.3
ServerActive=192.168.30.107,192.168.30.3
```

systemctl restart zabbix-agent 启动服务

 

（6）把代理加入监控server，创建配置agent 代理

① 创建agent 代理

![img](assets/1216496-20171226172053932-978486530.png)

② 配置

![img](assets/1216496-20171226172054213-335809349.png)

 

（7）创建node2 主机，并采用代理监控

![img](assets/1216496-20171226172054682-1009619727.png)

设置代理成功

![img](assets/1216496-20171226172055307-1060200173.png)

 

（8）创建item监控项

① 为了实验，随便创一个监控项 CPU Switches

![img](assets/1216496-20171226172055698-1128474710.png)

② 进程里设置每秒更改

![img](assets/1216496-20171226172055932-1067681793.png)

③ 成功，graph 图形生成

![img](assets/1216496-20171226172056416-1575771036.png)

 

## 八、查询使用网上模板监控

### 1、找官方的share 分享网站

<https://cn.bing.com/> 搜索 zabbix share

![img](assets/1216496-20171226172057120-1262251161.png)

例如：我们要实现监控Nginx ，我们查找一个模板

![img](assets/1216496-20171226172057635-1089716709.png)

就以这个模板为例

![img](assets/1216496-20171226172058182-128310444.png)

 

### 2、在node1 上使用此模板

（1）安装配置 nginx

① yum -y install nginx

vim /etc/nginx/nginx.conf 按照网页的操作指示

```
location /stub_status {
        stub_status on;
        access_log off;
    #    allow 127.0.0.1;   #为了操作方便，我取消的访问控制
    #    deny all;
}
```

![img](assets/1216496-20171226172058510-1149178016.png)

② 启动服务

systemctl restart nginx

 

（2）下载模板所依赖的脚本

![img](assets/1216496-20171226172058823-57198051.png)

mkdir -p /srv/zabbix/libexec/

cd /srv/zabbix/libexec/

wget https://raw.githubusercontent.com/oscm/zabbix/master/nginx/nginx.sh 从网页上获取脚本

chmod +x nginx.sh 加执行权限

 

（3）配置agent 的用户参数UserParameter

cd /etc/zabbix/zabbix_agentd.d/

wget https://raw.githubusercontent.com/oscm/zabbix/master/nginx/userparameter_nginx.conf 很短，自己写也行

![img](assets/1216496-20171226172059073-397108138.png)

（4）在windows 上下载模板，并导入这server 的模板中

wget https://raw.githubusercontent.com/oscm/zabbix/master/nginx/zbx_export_templates.xml 可以现在linux上下载，再sz 导出到windows上

![img](assets/1216496-20171226172059291-1133694346.png)

① 导入下载的模板

![img](assets/1216496-20171226172059635-1317185355.png)

② 主机node1 链接这个模板

![img](assets/1216496-20171226172100041-1015144646.png)

③ 模板生效

![img](assets/1216496-20171226172100323-635966866.png)

 

## 九、zabbix-server 监控自己，数据库，nginx

### 1、下载安装，配置agent

vim /etc/zabbix/zabbix_agentd.conf 配置agent

```
EnableRemoteCommands=1    允许远程命令
LogRemoteCommands=1    记录远程命令
Server=127.0.0.1
ServerActive=127.0.0.1
Hostname=server.along.com
```

### 2、自动生成Zabbix server 的主机

![img](assets/1216496-20171226172101526-749330259.png)

### 3、在主机中添加模板

![img](assets/1216496-20171226172101885-2112581492.png)

### 4、启用Zabbix server

![img](assets/1216496-20171226172102370-823261452.png)

### 5、监控到数据

![img](assets/1216496-20171226172102698-926445046.png)

 

## 十、调优

### 1、调优

① Database：

　　历史数据不要保存太长时长；

　　尽量让数据缓存在数据库服务器的内存中；

② 触发器表达式：**减少使用聚合函数** min(), max(), avg()；尽量使用last()，nodata()；

　　因为聚合函数，要运算

③ 数据收集：polling较慢(减少使用SNMP/agentless/agent）；**尽量使用trapping（agent(active）主动监控）；**

④ 数据类型：文本型数据处理速度较慢；**尽量少**收集类型为**文本** text或string类型的数据；**多使用**类型为numeric **数值型数据** 的；

### 2、zabbix服务器的进程

(1) 服务器组件的数量；

　　alerter, discoverer, escalator, http poller, hourekeeper, icmp pinger, ipmi polller, poller, trapper, configration syncer, ...

 

　　StartPollers=60

　　StartPingers=10

　　...

　　StartDBSyncer=5

　　...

 

(2) 设定合理的缓存大小

　　 CacheSize=8M

　　 HistoryCacheSize=16M

　　 HistoryIndexCacheSize=4M

　　 TrendCacheSize=4M

　　 ValueCacheSize=4M

 

(3) 数据库优化

　　分表：

　　　　history_*

　　　　trends*

　　　　events*

 

### 3、其它解决方案

grafana：展示

collectd：收集

influxdb：存储

 

grafana+collectd+influxdb

 

prometheus：

　　 exporter：收集

　　 alertmanager:

grafana：展示

 

openfalcon