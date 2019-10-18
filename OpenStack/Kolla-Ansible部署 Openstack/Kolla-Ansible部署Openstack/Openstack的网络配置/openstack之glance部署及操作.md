# openstack之glance部署及操作

 

**部署glance**

安装memcache服务

```
yum install memcached python-memcached
systemctl enable memcached.service
systemctl start memcached.service
```

 

**1.glance的数据库操作**

glance跟其他的组件都共享一台数据库，所以直接在部署keystone的那台数据库中操作即可。

[![复制代码](assets/copycode-1556351853897.gif)](javascript:void(0);)

```
mysql -u root -p #登入数据库
CREATE DATABASE glance; #新建库keystone
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
  IDENTIFIED BY '123'; #新建本地访问glance库的账号
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
  IDENTIFIED BY '123'; #新建远程访问glance库的账号
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

**2.glance关于keystone的操作**

首先要建立一个glance用户，然后创建一个项目，最后关联赋予角色，在搭建keystone的时候，glance属于一个组件，keystone属于一个组件，nova属于一个组件等等的这些所有的组件都在一个项目中(service项目)，所以项目就不需要建立，直接赋予角色信息。

对于glance来说，它属于管理着镜像服务，keystone管理着认证服务，neutron管理着网络服务，nova，cinder等等，这些所有的管理者的用户必须是admin。

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#获得管理员权先。
#为glance的使用者创建用户
openstack user create --domain default --password-prompt glance 

#对glance-service添加role角色,提示：用户glance只有在一个确定的项目service内才有角色的概念，单独的用户或者单独的项目都是无法绑定角色的。
openstack role add --project service --user glance admin 
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

![img](assets/1092539-20170216102308566-7813283.png)

查看关联

![img](assets/1092539-20170216102651191-1690301059.png)

由上图可见第一行就是建立了关联，用户--角色--项目都已经建好了。接下来就要建立访问glance的catalog了

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#创建glance服务的catalog：service+endpoint
openstack service create --name glance \
--description "OpenStack Image" image
#一定要指定它的类型为image镜像类型

openstack endpoint create --region RegionOne \
  image public http://182.92.84.106:9292
openstack endpoint create --region RegionOne \
  image internal http://182.92.84.106:9292
openstack endpoint create --region RegionOne \
  image admin http://182.92.84.106:9292
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 指定类型

 ![img](assets/1092539-20170216103028457-845310959.png)

三种访问路径

**public**

![img](assets/1092539-20170216103222566-1477345880.png)

 

**internal**

![img](assets/1092539-20170216103148269-441718883.png)

 **admin**

**![img](assets/1092539-20170216103300285-1973743882.png)**

**查看服务**

**![img](assets/1092539-20170216103330347-1751120061.png)**

**查看endpoint**

 **![img](assets/1092539-20170216103622160-489494549.png)**

注意现在的这些操作都是在keystone里面，还没有具体的glance服务。

 keystone对glance的操作就结束了 接下来就是正式安装glance了

 **3.安装软件包**

```
yum -y install openstack-glance
```

4.配置glance

注意注意:每一条配置都要新建到文件中，不要打开注释在原有的基础上修改

 创建本地存储 

**1.一定要在opesntack-glance-api.service服务启动之前部署好存储设备，因为该服务在启动时会加载存储驱动检索存储设备，如果事先不存在，就意味着该服务没有识别到任何可用的存储设备，即便是后来你又新增了存储，仍然是无效的，最终导致你上传镜像失败；**

**2.一定要赋予opesntack-glance-api.service服务对存储设备的可写权限。**

```
mkdir /var/lib/glance/images
chown -R glance.glance /var/lib/glance/images
```

 

 配置/etc/glance/glance-api.conf V2版本

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[database]
connection = mysql+pymysql://glance:123@182.92.84.106/glance

[keystone_authtoken]
auth_uri = http://182.92.84.106:5000
auth_url = http://182.92.84.106:35357
memcached_servers = 182.92.84.106:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = 123

[paste_deploy]
flavor = keystone

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

配置 /etc/glance/glance-registry.conf  V1版本

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[database]
connection = mysql+pymysql://glance:123@182.92.84.106/glance

#可选
[keystone_authtoken]
auth_uri = http://182.92.84.106:5000
auth_url = http://182.92.84.106:35357
memcached_servers = 182.92.84.106:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance password = 123 
#可选
[paste_deploy]
flavor = keystone
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 **5.初始化数据库**

 

 

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
 su -s /bin/sh -c "glance-manage db_sync" glance

'''
并不是报错
Option "verbose" from group "DEFAULT" is deprecated for removal.  Its value may be silently ignored in the future.
/usr/lib/python2.7/site-packages/oslo_db/sqlalchemy/enginefacade.py:1171: OsloDBDeprecationWarning: EngineFacade is deprecated; please use oslo_db.sqlalchemy.enginefacade
  expire_on_commit=expire_on_commit, _conf=conf)
/usr/lib/python2.7/site-packages/pymysql/cursors.py:166: Warning: (1831, u"Duplicate index 'ix_image_properties_image_id_name' defined on the table 'glance.image_properties'. This is deprecated and will be disallowed in a future release.")
  result = self._query(query)
'''
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

**6.启动glance并设置为开机自启动**

```
systemctl enable openstack-glance-api.service \
openstack-glance-registry.service

systemctl start openstack-glance-api.service \
openstack-glance-registry.service
```

 

 **验证**

首先获得admin权限 

```
source admin-openrc
```

 

这时候执行如下命令可以看到为空

```
openstack image list 
```

 

![img](assets/1092539-20170216181453035-158647689.png)

因为里面还没有镜像 所以我们要先上传一个

 

下载镜像

```
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
使用glacne创一个镜像
openstack image create "cirros" \
  --file cirros-0.3.4-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public
```

![img](assets/1092539-20170216184254004-636518391.png)

![img](assets/1092539-20170216184331769-389787532.png)

镜像上传到glance后 即使删除了原文件也无所谓

可以使用qemu-img来查看镜像信息