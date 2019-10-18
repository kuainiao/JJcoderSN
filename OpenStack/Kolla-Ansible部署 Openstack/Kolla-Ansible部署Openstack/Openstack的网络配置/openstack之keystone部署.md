# openstack之keystone部署

**前言**

　　openstack更新频率是挺快的，每六个月更新一次（命名是是以A-Z的方式，Austin*，Bexar...Newton*）。博主建议大家先可一种版本研究，等某一版本研究透彻了，在去研究新的版本。其实更新来说，也就是无非对于软件来说的一些优化。对于用户角度并没有多大的改变。切记不要追着新版本走，那样只会是丢了西瓜拣芝麻！

　　看一下官网的图

　　![img](assets/1092539-20170120102018406-40875988.png)

　　我们按照Newton这个版本来部署。大家也可以上官网看下官方文档，写的也挺详细。

 

**废话不多说，直接部署**

openstack基于centos7 、redhat7 或者Ubuntu来部署的

**系统信息：**

```
1 [root@bodbayLi ~]# cat /etc/redhat-release 
2 CentOS Linux release 7.2.1511 (Core) 　　　　#操作系统信息
3 [root@bodbayLi ~]# uname -r
4 3.10.0-327.22.2.el7.x86_64　　　　　　　　#内核的版本信息
```

**First Step：准备阶段**

安装官方yum源。之前在部署这个openstack的时候还要考虑各种的安装包。后来官方直接出了自己的yum源。

yum安装（下载软件包到本地--->安装--->删除） 修改yum.conf

![img](assets/1092539-20170120104110187-1661661279.png)

 

修改keepcache=1

修改cachedir=/newton　　#方便管理。并且所有的软件包都下载到本地，可以自己制作yum源

 

```
`yum ``-``y install centos``-``release``-``openstack``-``newton ``#安装官方的yum源``yum ``-``y upgrade ``#更新``yum ``-``y install python``-``openstackclient ``#安装工具``yum ``-``y install openstack``-``selinux ``#安装openstack-selinux包自动管理openstack组件的安全策略`
```

安装完上面的部分，接下来部署数据库

**Second Step**

　　因为keystone是一个认证服务也属于一个web app，既然是认证服务就要在后端安装一个数据库。用来存放用户的相关数据

```
`yum ``-``y install mariadb mariadb``-``server python2``-``PyMySQL 　　<br>　　``#前面两个是属于centos7版本mysql数据库的名称，后面那个是一个Python模块。（在python当中操作mysql）`
```

　安装好后在/etc/my.cnf.d/目录下创建一个openstack.cnf文件。（什么名字都行但是要以.cnf结尾）

```
1 [mysqld]
2 bind-address = 182.92.84.106 #本机管理网络ip
3 
4 default-storage-engine = innodb
5 innodb_file_per_table
6 max_connections = 4096
7 collation-server = utf8_general_ci
8 character-set-server = utf8
```

 保存退出，启动mariadb

systemctl start mariadb.service　#启动mariadb并设为开机启动。在centos6版本中启动管理服务由之前的init.d

systemctl enable mariadb.service　#在centos7中则是systemctl来管理启动服务，千万要记住

查看mariadb.service运行状态

![img](assets/1092539-20170120144457031-944210935.png)

上面就是mariadb部署过程

**Third Step**

　　部署keystone

keystone关于数据库的操作：

```
1 mysql -u root -p #登入数据库
2 CREATE DATABASE keystone; #新建库keystone
3 GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
4   IDENTIFIED BY '123'; #新建本地访问keystone库的账号
5 GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
6   IDENTIFIED BY '123'; #新建远程访问keystone库的账号
```

keystone为什么要创建一个自己的数据库？

　　应为keystone程序要访问数据库，首先自己要有一个数据库，就来访问自己的数据库

**注意：以后每部署一个组件都要有一个自己的数据库，在数据库中。比如nova也要访问数据库，那么数据库中就存放一个nova的库，里面存放一些nova相关的信息 ,catalog等**

安装软件包

```
1 #keystone软件包名openstack-keystone
2 #安装httpd和mod_wsgi的原因是，社区主推apache+keystone
3 #openstack-keystone本质就是一款基于wsgi协议的web app,而httpd本质就是一个兼容wsgi协议的web server，所以我们需要为httpd安装mod_wsgi模块
4 yum -y install openstack-keystone httpd mod_wsgi
```

修改keyston配置文件：/etc/keystone/keystone.conf

```
1 #让openstack-keystone能够知道如何连接到后端的数据库keystone
2 #mysql+pymysql：pymysql是一个python库，使用python可以操作mysql原生sql
3 [database]
4 connection = mysql+pymysql://keystone:123@182.92.84.106/keystone　　#mysql+pmysql是由上面的Python-mysql
　　　　　　　　　　　　　　　　　　#用户名:密码@mysql地址/哪个库　　　　　　　 那个模块安装的，用pymysql来操作mysql
5 [token]　　　　#令牌
6 provider = fernet #fernet为生成token的方式（还有pki）
```

注意在mysql数据库中创建密码的时候加上了引号“123”而在配置文件中不要加上引号，不然会保错

保存退出，并初始化数据库

```
`su ``-``s ``/``bin``/``sh ``-``c ``"keystone-manage db_sync"` `keystone`
```

之所以要初始化，是因为python的orm对象关系映射，需要初始化来生成数据库表结构。什么是orm（Object Relation Mapping）的缩写叫对象关系映射。

 可能有的时候大家在部署的时候会遇到报错，怎么办，虽然我没有遇到，但是如果各位遇到了不要慌

```
`tail ``-``f ``-``n ``20` `/``var``/``log``/``keystone``/``keystone.log`
```

看看是哪一步骤出现问题解决就好。

接下来初始化Fernet key库(生成token)

```
`keystone``-``manage fernet_setup ``-``-``keystone``-``user keystone ``-``-``keystone``-``group keystone``keystone``-``manage credential_setup ``-``-``keystone``-``user keystone ``-``-``keystone``-``group keystone`
```

上面的两个步骤是keystone对自己授权的一个过程，创建了一个keystone用户与一个keystone组。并对这个用户和组授权。因为keystone是对其他组件认证的服务，那么它自己就合格么？所以它先要对自己进行一下认证　

**Fourth Step**

**配置web server整合keystone**　　

修改主机名，方便操作

```
`hostnamectl ``set``-``hostname controller`
```

配置hosts

```
`182.92``.``84.106` `controller`
```

配置http.conf/ServerName

```
`ServerName controller`
```

为mod_wsgi模块添加配置文件

\#直接拷贝模块文件或者做软连接都可以

ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/

wsgi：apache关于mod_wsgi模块的配置文件

keystone：用来连接keystone

查看wsgi-keystone.conf文件

![img](assets/1092539-20170120154537718-357101770.png)

![img](assets/1092539-20170120154453187-859092505.png)

 ![img](assets/1092539-20170120154624218-781925562.png)

1.上面两个端口说明keystone要开放这两个端口，apache才能把请求交给keystone

2.Port 5000：Wsgi守护进程，进程5个，每个进程下面一个线程，用户keystone，组keystone。进程组/usr/bin/keystone-wsgi-public 用来产生5000端口（内部用户与外部用户使用）

3.Port 35357：跟上面一样。进程组/usr/bin/keystone-wsgi-admin 用来产生35357端口（管理员使用）

**Fifth Step** 

启动服务

```
systemctl start httpd.service    #启动httpd服务
systemctl enable httpd.service    #设置成开机自启
```

查看服务状态

![img](assets/1092539-20170120155923296-2025563661.png)

到这里keystone就部署完了，接下来就是如何要操作它了

**如何操作keystone**

 **一.创建keystone的catalog**

　　配置/etc/keystone/keystone.conf

```
`[DEFAULT]``admin_token ``=` `123``　　``#keystone自己对自己授予令牌为。虽然是可以但是这样是危险的，后面会去解决它`
```

　　设置环境变量

```
export OS_TOKEN=123 
export OS_URL=http://182.92.84.106:35357/v3
export OS_IDENTITY_API_VERSION=3
```

1.第一步的值等于keystone.conf中admin_token的值。并且只要在当前终端执行命令，当前终端就是管理员用户

2.因为现在keystone没有提供Endpoint，所以自己手动指定一个Endpoint，以后的请求就往这个url提交。v3代表用的keystone版本为3

3.认证版本为3

　　为keystone创建catalog

```
`openstack service create \``  ``-``-``name keystone ``-``-``description ``"OpenStack Identity"` `identity`
```

基于前两步给的权限，创建认证服务实体

![img](assets/1092539-20170120161951750-204394665.png)

基于建立的服务实体，创建访问该实体的三个api端点

```
openstack endpoint create --region RegionOne \
  identity public http://182.92.84.106:5000/v3
  
openstack endpoint create --region RegionOne \
  identity internal http://182.92.84.106:5000/v3　　#前两个为5000端口，专门处理内部和外部的访问
  　　　　　　　　　　　　　　　　　　　　　　　　　　　　　  #用keystone-wsgi-public
openstack endpoint create --region RegionOne \
  identity admin http://182.92.84.106:35357/v3　　#35357端口，专门处理admin#用keystone-wsgi-admin
```

 

![img](assets/1092539-20170206141551932-1586685689.png)

 

![img](assets/1092539-20170206141625791-1612926845.png)

 

 ![img](assets/1092539-20170206141651229-827559804.png)

 

可以看见上面三个的service_id一样说明他们属于一个服务的Endpoint 

白色箭头是访问路径

登录数据库查看keystone库中的表

![img](assets/1092539-20170206141852776-1385249838.png)

 

上面的步骤操作成功后，这样keystone就可以工作了。

　　**二.创建域，项目(租户)，用户，角色，并把四个元素关联在一起**

　　在openstack中最大的资源集合就是域--->项目(租户)--->用户--->角色

　　1.创建域

　　 1 openstack domain create --description "Default Domain" default #创建一个默认的域“default” 

![img](assets/1092539-20170206142023401-1709597937.png)

 

　　2.创建管理员　 

```
 #创建admin项目 在“default”域中
 openstack project create --domain default \
   --description "Admin Project" admin 
 #创建admin用户 在“default”域中
 openstack user create --domain default \
   --password-prompt admin　　　　　　　　#输入密码
 #创建admin角色
 openstack role create admin
 #创建上述三者的关联
 openstack role add --project admin --user admin admin　　　　　#不关联用户无法使用
```

　　第一步与第二步的作用就是keystone能够被使用初始化的操作

　**大家觉得上面的两大部分才完成一个功能有些麻烦，别急 官方最新给出了一个框架叫做Bootsrap，能够直接完成第一步和第二步的操作**

   　　如何操作的呢 请看　　

　　**三**

 

```
#本质就是在为keystone创建catalog
keystone-manage bootstrap --bootstrap-password 123 \
  --bootstrap-admin-url http://182.92.84.106:35357/v3/ \
  --bootstrap-internal-url http://182.92.84.106:35357/v3/ \
  --bootstrap-public-url http://182.92.84.106:5000/v3/ \
  --bootstrap-region-id RegionOne
#这个123就是上面你输入的部分的那个密码
#只不过用这步操作的话不用修改配置文件，不用写admin_token，第一步与第二步的操作一点都不要去做直接就第三步
```

 

 

 

　　设置环境变量

　

```
export OS_USERNAME=admin　　　　#用户名
export OS_PASSWORD=123　　　　#就是keystone-manage中设定的--bootstrap-password
export OS_PROJECT_NAME=admin　　#项目名　　　　project <-- 用户 <--角色  若想让用户获取权限必须要指定用户所在的项目是哪个
export OS_USER_DOMAIN_NAME=Default　　#默认域
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://182.92.84.106:35357/v3　　#认证url
export OS_IDENTITY_API_VERSION=3　　#指定版本信息
```

验证关联

![img](assets/1092539-20170120172317921-1333222131.png)

对比它们的ID发现是否一样

这些ID都可以在mysql数据库中查到

![img](assets/1092539-20170120172504375-137128829.png)

 

**四.使用第三种方法步骤**

　　删除mysql keystone数据库

　　重新初始化keystone数据库

　　退出环境变量

　　修改/etc/keystone/keystone.conf/ 下的[DEFAULT] 将admin_token=123删掉

　　直接操作第三步

　　结束后查看assignment（openstack assignment list）看是否有结果

 

**五.测试**

　创建用于后期测试用的项目，用户，租户，建立关联　

```
openstack project create --domain default \
  --description "Demo Project" demo
#创建项目名为demo
openstack user create --domain default \
  --password-prompt demo
#创建普通用户为demo 设置密码
openstack role create user　　　　　　　　#创建普通用户的角色即user
openstack role add --project demo --user demo user　　　　#建立关联
```

每一个创建的过程都是这几个步骤。但是会少了一步创建角色的过程。因为用户就两个，一个是admin，另一个就是user（一个项目里可以有很多admin角色和user角色）注意.角色一定是在项目中。

**六。为后续的服务创建统一的项目叫service**　

　　 因为keystone是一个独立的授权组件，后面每搭建一个新的服务都需要在keystone中执行四种操作：1.建项目 2.建用户 3.建角色 4.做关联 并且创建catalog

```
#后面所有的服务（nova。glace等等）公用一个项目service，都是管理员角色admin （组件之间的通信都角色都是admin）
#所以实际上后续的服务安装关于keysotne的操作只剩2，4
openstack project create --domain default \
  --description "Service Project" service
```

　　每一个组件，都要有一个访问用户。（比如访问glance要有一个glance用户，还有一个一个角色，还要有一个关联）以后要部署glance，要在keystone中创建一个glance的catalog（service名/Endpoint）。还要有一个访问catalog的用户信息，这样的话还要

创建一个域。但是现在已经有了一个默认的域 所以不需要再创建，域有了还要创建一个项目，但是现在项目也已经有了。service项目，所以不用创建了。就需要创建一个叫glance的用户就行了（一般组件叫什么名，用户就叫什么名）。还要创建一个角色。但是也不用创建，之前就有一个admin角色。最后就只要做一个关联就行。以后每个组件都要这么做。就是说学会了keystone的部署，后面的组件也就部署好了

 

![img](assets/1092539-20170120175954484-1963301093.png)

查看project

![img](assets/1092539-20170120180024015-1331286638.png)

 

**七.验证**

1.准备

出于安全考虑，关闭临时令牌认证机制（配置文件中的admin_token和keystone-manage的--bootstrap-password都是基于该机制）

2.取消一切环境变量（退出xshell/puppy远程连接软件，重新连接）

3.验证操作方法

　　管理员用户admin申请token

```
openstack --os-auth-url http://controller:35357/v3 \
--os-identity-api-version 3  \
--os-project-domain-name default \
--os-user-domain-name default   \
--os-project-name admin \
--os-username admin \
token issue
```

![img](assets/1092539-20170213105039550-1480458595.png)

注意：一定要加上--os-identity-api-version 3

为普通用户申请token

```
openstack --os-auth-url http://controller:5000/v3 \
--os-identity-api-version 3  \
--os-project-domain-name default \
--os-user-domain-name default   \
--os-project-name demo \
--os-username demo \
token issue
```

![img](assets/1092539-20170213105338191-1303351423.png)

 

为了以后不写一长串的用户信息，我们可以把它定义成为一个脚本

admin

```
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=123
export OS_AUTH_URL=http://182.92.84.106:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

user

```
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=123
export OS_AUTH_URL=http://182.92.84.106:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

针对不同的业务应该有不同的用户信息，也都应该定义成脚本形式，方便管理

 最后申请token的操作为

```
source admin
openstack token issue
```

 