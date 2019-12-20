# tomcat企业级Web应用服务器配置与会话保持

**环境背景：**公司业务经过长期发展，有了很大突破，已经实现盈利，现公司要求加强技术架构应用功能和安全性以及开始向企业应用、移动APP等领域延伸，此时原来开发web服务的php语言已经不适应新的场景，需要上java技术架构，现要求你根据公司需要，实现基于java平台的web应用服务选型、搭建、实现和应用，此时你如何选择？

## 实战一：在linux上，安装tomcat

### 1、下载安装java所需要的环境和开发工具包

**（1）Java 所需要的环境和开发工具包介绍**

JRE： Java Runtime Environment

JDK：Java Development Kit JRE

JRE顾名思义是java运行时环境，包含了java虚拟机，java基础类库。是使用java语言编写的程序运行所需要的软件环境，是提供给想运行java程序的用户使用的。

JDK顾名思义是**java开发工具包**，是程序员使用java语言编写java程序所需的开发工具包，是提供给程序员使用的。**JDK包含了JRE，同时还包含了编译java源码的编译器javac，还包含了很多java程序调试和分析的工具**：jconsole，jvisualvm等工具软件，还包含了java程序编写所需的文档和demo例子程序。如果你需要运行java程序，只需安装JRE就可以了。如果你需要编写java程序，需要安装JDK。JRE根据不同操作系统（如：windows，linux等）和不同JRE提供商（IBM,ORACLE等）有很多版本，最常用的是Oracle公司收购SUN公司的JRE版本。

 

（2）安装相应版本的rpm包 jdk-VERSION-OS-ARCH.rpm

yum -y localinstall **jdk-8u144-linux-x64.rpm**

centos7系统自带：jdk-1.8.0_25-linux-x64.rpm

java -version 显示java程序的版本信息

 

（3）安装完成后，要配置JAVA_HOME环境变量

vim /etc/profile.d/java.sh

```
export JAVA_HOME=/usr/java/jdk1.8.0_144
export JRE_HOME=$JAVA_HOME/jre
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
```

### 2、下载安装tomcat

**方法一：二进制安装（推荐）**

（1）从官网下载tomcat二进制安装包 http://tomcat.apache.org/

https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v8.5.23/bin/

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193642665-539646222.png)

 

（2）解包，设置目录

① 解包

```
tar xvf  apache-tomcat-8.5.11.tar.gz -C /usr/local/
```

② 为了方便管理，设置软连接，若以后换版本了，可以很容易切换

```
ln -s /usr/local/apache-tomcat-7.0.78/ /usr/local/tomcat
```

（3）设置环境配置管理脚本

vim /etc/profile.d/tomcat.sh

```
export CATALINA_BASE=/usr/local/tomcat
export PATH=$CATALINA_BASE/bin:$PATH
source /etc/profile.d/tomcat.sh   执行加载环境配置
```

 

**方法二：yum安装**

（1）安装

```
yum install tomcat -y #安装tomcat主程序
yum install -y tomcat-admin-webapps tomcat-docs-webapp tomcat-webapps  #安装tomcat对应的页面
mkdir /var/lib/tomcat/webapps/{ROOT,test}/{WEB-INF,META-INF,classes,lib} -pv  #创建页面所需要的工作目录
```

（2）rpm包安装的程序环境：

配置文件目录：/etc/tomcat

主配置文件：server.xml

webapps存放位置：/var/lib/tomcat/webapps/

examples

manager

host-manager

docs

Unit File：tomcat.service

环境配置文件：/etc/sysconfig/tomcat #调整jdk内存使用大小等初始值

 

### 3、启动tomcat

（1）catalina.sh start

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193643134-604225803.png)

 

（2）测试本地8080端口是否正常监听

curl -I 127.0.0.1:8080

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193643321-1617136447.png)

通过浏览器访问测试（需指定8080端口）

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193643962-373086983.png)

 

## 实战二：基于tomcat布署一个开源java产品

### 1、去网上下载开源Java 代码

可以去开源中国下载自己需要的https://www.oschina.net/

我已经下好一个，需要的私密我http://pan.baidu.com/s/1c2B7BO0

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193644384-225494656.png)

 

### 2、解包、布署和查看使用说明

① unzip zchuanzhao-jeesns-master.zip

② mv /jeesns/war/**jeesns.war** ...**/webapps** 把jeesns.war移到你的tomcat的webapps 下

如果你是自动布署，会自动在/webapps 下生成jeesns目录；若不是，可以自己unzip 解包，布署

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193644602-742028670.png)

autoDeploy="true" 是自动布署

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193644852-32081323.png)

③ cat README.md 有详细的操作过程

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193645321-2066354463.png)

 

### 3、同步数据到数据库

（1）在数据库创建一个存放的库

MariaDB [(none)]> create database along;

（2）把数据同步到数据库

cd /jeesns/jeesns-web/database/

mysql -uroot -p **-D along <** jeesns.sql

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193645665-1422646795.png)

 

### 4、修改数据库连接

vim /webapps/jeesns/WEB-INF/classes/jeesns.properties

修改数据库和登录用户和密码

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193645852-840261566.png)

 

### 5、访问页面，布署成功

① 登录首页 http://192.168.30.107:8080/jeesns

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193646571-1612403165.png)

 

② 进入后台管理 http://192.168.30.107:8080/jeesns/**manage/login**

用户名：admin

密码：jeesns

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193647149-437924929.png)

③ 登录后台成功！

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193647587-1360524736.png)

这个设计的还是挺高级的！！！ 大家可以尝试一番

 

## 实战三：实现LNMT，nginx代理tomcat

**分析：**就是由nginx 代理tomcat 来实现的

### 1、直接在nginx 上设置跳转

vim /etc/nginx/nginx.conf

```
location / {
        proxy_pass http://192.168.30.107:8080;
}
location ~* \.(jsp|do)$ {
        proxy_pass http://192.168.30.107:8080;
}
```

### 2、访问测试，http://192.168.30.107/

访问80端口，能代理到8080端口

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193648024-828373944.png)

 

### 3、实现集群代理服务

（1）先在http 段定义

vim /etc/nginx/nginx.conf

```
upstream tomcat_srv {
server 192.168.30.107:8080 weight=1;
server 192.168.30.7:8080 weight=2;
} 
```

（2）再在server 段定义location

```
location / {
        proxy_pass http://tomcat_srv;
}
location ~* \.(jsp|do)$ {
        proxy_pass http://tomcat_srv;
}
```

（3）创建测试页面

① 在server1 上定义一个页面

vim webapps/test/index.jsp

```
<%@ page language="java" %>
<%@ page import="java.util.*" %>
<html>
<head>
<title>Test Page</title>
        </head>
        <body>
        <% out.println("hello world");%>
        </body>
</html>
```

② 在server2 上定义一个页面

vim webapps/test/index.jsp

```
<%@ page language="java" %>
<%@ page import="java.util.*" %>
<html>
<head>
<title>Test Page</title>
        </head>
        <body>
        <% out.println("hello world2");%>
        </body>
</html>
```

（4）页面访问测试

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193648290-2061611881.png)

轮询出现

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193648509-1353176698.png)

## 实战四：LNMT的会话保持原理及基于ip_hash实现

### 1、原理：有三种类型的方法，实现会话保持的方法

**(1) session sticky（贴）** 基于hash 和cookie 来实现会话保持，简单的负载均衡算法

**① 基于source_ip**（源地址hash）

　　nginx: ip_hash 、 haproxy: source 、 lvs: sh

**② 基于cookie** nginx基于cookie实现，需加载cookie模块，cookie 力度更新

　　nginx：sticky 、haproxy: cookie

 

**(2) session cluster**：delta session manager 基于tomcat集群会话保持

**分析：**tomcat自身带的机制 session cluster**，基于组播的方式**，一个tomcat 被用户登录访问，记录**session**；**通过组播**给集群中的其他机器**复制**一份；那么当用户再次访问时，**每个机器都有session 会话记录**；从而实现了会话保持

 

**(3) session server**：redis(store), memcached(cache) **共享存储**

分析：**新建立一个存放**各个**tomcat session**记录的**server**，每台tomcat服务器都将自己的session记录在这个服务器中，用户再次访问，每台tomcat 都从这个server中获取；实现会话保持

### 2、简单实现基于ip hash 实现会话保持

vim /etc/nginx/nginx.conf 只需加一条**ip_hash即可**

upstream tomcat_srv {

```
upstream tomcat_srv {
ip_hash;
server 192.168.30.107:8080 weight=1;
server 192.168.30.7:8080 weight=2;
}
```

### 3、测试

访问页面，一直匹配到107的server 上，没有轮询；会话保持成功

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193648727-737734635.png)

 

## 实战四：基于tomcat会话集群实现LNMT的会话保持

**原理：Tomcat集群的会话管理器**，它通过**将改变了会话数据同步**给**集群中的其它节点**实现**会话复制**。这种实现会**将所有会话的改变同步给集群中的每一个节点**

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193649149-1044596843.png)

**1、环境准备**

 

| 机器名称    | IP配置         | 服务角色   | 备注         |
| ----------- | -------------- | ---------- | ------------ |
| nginx       | 192.168.30.107 | 代理服务器 | 开启代理功能 |
| tomcat-srv1 | 192.168.30.106 | web服务    | 配置集群会话 |
| tomcat-srv2 | 192.168.30.7   | web服务    | 配置集群会话 |

### 2、配置nginx代理

vim /etc/nginx/nginx.conf

```
upstream tomcat_srv {    #在http 段配置
server 192.168.30.106:8080 weight=1;
server 192.168.30.7:8080 weight=2;
}

location / {    #在server 段配置
        proxy_pass http://tomcat_srv;
}
location ~* \.(jsp|do)$ {
        proxy_pass http://tomcat_srv;
}
```

systemctl start nginx 开启服务

### 3、tomcat 集群会话的配置

注意：两台tomcat-srv的配置是一模一样的，除了测试的页面设置不同

cd /usr/local/tomcat/ 进入自己的tomcat 的目录下

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193649368-1382853988.png)

vim **conf/server.xml 在Engine 引擎**段中，添加下面代码，**注意：注释千万别加去**

```
<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster" channelSendOptions="8">    定义集群节点，“8”表示异步

<Manager className="org.apache.catalina.ha.session.DeltaManager"    定义Manger采用DeltaManager 会话管理器
expireSessionsOnShutdown="false"    一个节点关闭，不影响集群其他session
notifyListenersOnReplication="true"/>    复制、删除操作通知session listener

<Channel className="org.apache.catalina.tribes.group.GroupChannel">   
<Membership className="org.apache.catalina.tribes.membership.McastService"
address="228.0.0.4" port="45564" frequency="500" dropTime="3000"/>
<Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
address="auto" port="4000" autoBind="100" selectorTimeout="5000" maxThreads="6"/>
<Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
<Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/>
</Sender>
<Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/>
<Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatch15Interceptor"/>
</Channel>

<Valve className="org.apache.catalina.ha.tcp.ReplicationValve" filter="/"/>
<Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve"/>
<ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/>
</Cluster>
```

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193649868-1882750219.png)

### 4、配置注释

**（1）Cluster配置：**

**Cluster(集群,族) 节点**，如果你要配置tomcat集群，则需要使用此节点.

className 表示tomcat集群时,之间相互传递信息使用那个**类**来实现信息之间的传递.

channelSendOptions可以**设置为2、4、8、10**，每个数字代表一种方式

　　**2** = Channel.SEND_OPTIONS_USE_ACK**(确认发送)**

　　**4** = Channel.SEND_OPTIONS_SYNCHRONIZED_ACK**(同步发送)**

　　**8** = Channel.SEND_OPTIONS_ASYNCHRONOUS**(异步发送)**

在异步模式下，可以通过加上确认发送(Acknowledge)来提高可靠性，此时channelSendOptions设为**10，半同步**

例：

```
<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster" channelSendOptions="8">
```

 

**（2）Manager**

（a）Manager介绍

Manger对象用于实现HTTP会话管理的功能，Tomcat中有4种Manger的实现：

① StandardManager

Tomcat6的默认会话管理器，用于非集群环境中对单个处于运行状态的Tomcat实例会话进行管理。当Tomcat关闭时，这些会话相关的数据会被写入磁盘上的一个名叫SESSION.ser的文件，并在Tomcat下次启动时读取此文件。

② PersistentManager

当一个会话长时间处于空闲状态时会被写入到swap会话对象，这对于内存资源比较吃紧的应用环境来说比较有用。

③ **DeltaManager**

用于**Tomcat集群的会话管理器**，它通过**将改变了会话数据同步**给**集群中的其它节点**实现**会话复制**。这种实现会**将所有会话的改变同步给集群中的每一个节点**，也是在集群环境中用得最多的一种实现方式。

④ BackupManager

用于Tomcat集群的会话管理器，与DeltaManager不同的是，某节点会话的改变只会同步给集群中的另一个而非所有节点

（b）Manager配置

```
className－指定实现org.apache.catalina.ha.ClusterManager接口的类,信息之间的管理
expireSessionsOnShutdown－设置为true时，一个节点关闭，将导致集群下的所有Session失效
notifyListenersOnReplication－集群下节点间的Session复制、删除操作，是否通知session listeners
```

 

**（3）Channel 频道的介绍和配置**

（a）介绍

Channel是Tomcat节点之间进行通讯的工具。Channel包括4个组件：

　　**Membership：集群的可用节点列表**

　　**Receiver ：接收器**，负责接收消息

　　**Sender ：发送器**，负责发送消息

　　**Interceptor ：**Cluster的**拦截器**

 

（b）**Membership** 配置

① Membership：维护集群的可用节点列表，它可以**检查到新增的节点**，也可以**检查到没有心跳的节点**

② className－指定Membership使用的类

③ address－组播地址

④ port－组播端口

⑤ frequency－发送心跳(向组播地址发送UDP数据包)的时间间隔(单位:ms)。默认值为500

⑥ dropTime－Membership在dropTime(单位:ms)内未收到某一节点的心跳，则将该节点从可用节点列表删除。默认值为3000

 

注：组播（Multicast）：一个发送者和多个接收者之间实现一对多的网络连接。

一个发送者同时给多个接收者传输相同的数据，只需复制一份相同的数据包。

它提高了数据传送效率，减少了骨干网络出现拥塞的可能性

相同组播地址、端口的Tomcat节点，可以组成集群下的子集群

例：

```
<Membership className="org.apache.catalina.tribes.membership.McastService"
address="228.0.0.4"
port="45564"
frequency="500"
dropTime="3000"/>
```

 

（c）**Receiver 配置**

**Receiver : 接收器，负责接收消息**

接收器分为**两种**：**BioReceiver(阻塞式)、NioReceiver(非阻塞式)**

　　className－指定Receiver使用的类

　　address－接收消息的地址

　　port－接收消息的端口

　　autoBind－端口的变化区间

　　如果port为4000，autoBind为100，接收器将在4000-4099间取一个端口，进行监听

　　selectorTimeout－NioReceiver内轮询的超时时间

　　maxThreads－线程池的最大线程数

例：

```
<Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
address="auto"
port="4000"
autoBind="100"
selectorTimeout="5000"
maxThreads="6"/>
```

 

（d）Sender 配置

**Sender : 发送器，负责发送消息**

Sender内嵌了Transport组件，Transport真正负责发送消息

**Transport：定义传输方式**

Transport分为**两种：bio.PooledMultiSender(阻塞式)、nio.PooledParallelSender(非阻塞式)**

例：

```
<Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
<Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/>
</Sender>
```

 

（e）**Interceptor 配置**

Interceptor : Cluster的拦截器

① **TcpFailureDetector**－网络、系统比较繁忙时，Membership可能无法及时更新可用节点列表，此时TcpFailureDetector可以拦截到某个节点关闭的信息，并尝试通过TCP连接到此节点，以确保此节点真正关闭，从而更新集群可以用节点列表

② **MessageDispatch15Interceptor**－查看Cluster组件发送消息的方式是否设置为Channel.SEND_OPTIONS_ASYNCHRONOUS(Cluster标签下的channelSendOptions为8时)。 设置为Channel.SEND_OPTIONS_ASYNCHRONOUS时，MessageDispatch15Interceptor先将等待发送的消息进行排队，然后将排好队的消息转给Sender

例：

```
<Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/>
<Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatch15Interceptor"/>
```

 

**（4）ClusterListener 配置**

**ClusterListener : 监听器**，监听Cluster组件接收的消息

使用DeltaManager时，Cluster接收的信息通过ClusterSessionListener传递给DeltaManager

例：

```
<ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/>
```

 

### 5、创建测试页面

mkdir webapps/test

cd webapps/test

① 设置一个web.xml 的配置文件

mkdir WEB-INF

cp /usr/local/tomcat/conf/web.xml WEB-INF/

vim WEB-INF/web.xml 在</web-app>上加一行

**** 表示分布式

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193650087-922868698.png)

② vim session.jsp 创建测试页面，在tomcat-srv1上是TomcatA；在tomcat-srv1上是TomcatB

```
<%@ page language="java" %>
<html>
<head><title>TomcatA</title></head>    //TomcatA的标题
<body>
<h1><font color="blue">TomcatA </h1>  
<table align="centre" border="1">
<tr>
<td>Session ID</td>    
<% session.setAttribute("abc","abc"); %>
<td><%= session.getId() %></td>
</tr>
<tr>
<td>Created on</td>
<td><%= session.getCreationTime() %></td>
</tr>
</table>
</body>
</html>
```

 

### 6、测试

页面访问http://192.168.30.107/test/session.jsp；轮询，但是session ID是一样的，会话保持成功

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193650634-1614286970.png)

已经会话保持

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193650884-1599203248.png)

 

## 实战五：基于共享存储实现LNMT的会话保持

**原理：新建立一个存放**各个**tomcat session**记录的**server**，每台tomcat服务器都将自己的session记录在这个服务器中，用户再次访问，每台tomcat 都从这个server中获取；实现会话保持

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193651149-1055785191.png)

### 1、环境准备

| 机器名称    | IP配置         | 服务角色   | 备注         |
| ----------- | -------------- | ---------- | ------------ |
| nginx       | 192.168.30.107 | 代理服务器 | 开启代理功能 |
| tomcat-srv1 | 192.168.30.106 | web服务    | 指向共享存储 |
| tomcat-srv2 | 192.168.30.7   | web服务    | 指向共享存储 |
| memcached   | 192.168.30.6   | 共享存储   |              |

 

### 2、下载提供，实验所依赖的.jar包

memcached-session-manager项目地址，http://code.google.com/p/memcached-session-manager/， https://github.com/magro/memcached-session-manager

① 下载如下jar文件至各tomcat节点的tomcat安装目录下的lib目录中，寻找自己需要的版本号，tc的版本号要与tomcat版本相同。

　　memcached-session-manager-1.8.3.jar

　　memcached-session-manager-tc7-1.8.3.jar

　　spymemcached-2.11.1.jar

　　msm-javolution-serializer-1.8.3.jar

　　javolution-5.4.3.1.jar

我已经下到了我的网盘，有需要的私聊 http://pan.baidu.com/s/1nvGFgKD

② 把这些包，上传到 lib 目录下

/usr/local/tomcat/lib

 

### 3、配置nginx代理

vim /etc/nginx/nginx.conf

```
upstream tomcat_srv {    #在http 段配置
server 192.168.30.106:8080 weight=1;
server 192.168.30.7:8080 weight=2;
}

location / {    #在server 段配置
        proxy_pass http://tomcat_srv;
}
location ~* \.(jsp|do)$ {
        proxy_pass http://tomcat_srv;
} 
```

systemctl start nginx 开启服务

### 4、在server.xml 中配置

vim /usr/local/tomcat/conf/server.xml

```
<Context path="/test" docBase="test" reloadable="true">
　　<Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
　　memcachedNodes="192.168.30.106:11211"
　　requestUriIgnorePattern=".*\.(ico|png|gif|jpg|css|js)$"
　　transcoderFactoryClass="de.javakaffee.web.msm.serializer.javolution.JavolutionTranscoderFactory"/>
</Context>
```

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193651368-374715201.png)

### 5、和上实验一样，创建测试页面并测试

页面访问http://192.168.30.107/test/session.jsp；轮询，但是session ID是一样的，会话保持成功

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193651634-1357059436.png)

已经会话保持

![img](tomcat%E4%BC%81%E4%B8%9A%E7%BA%A7Web%E5%BA%94%E7%94%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.assets/1216496-20171211193651946-468771971.png)