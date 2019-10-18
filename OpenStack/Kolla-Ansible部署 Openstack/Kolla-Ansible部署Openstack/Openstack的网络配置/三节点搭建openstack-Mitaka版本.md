# 三节点搭建openstack-Mitaka版本



前言：

　　现在的云计算平台已经非常火，也非常的稳定了。像阿里云平台，百度云平台等等，今天咱们基于openstack来搭建一个云平台

注意：

　　本次平台搭建为三节点搭建（没有外部存储节点，所有存储为本地存储的方式）

![img](assets/1092539-20170401091112024-1547173756.png)

 

一：网络：

　　1.管理网络：192.168.1.0/24

　　2.数据网络：1.1.1.0/24

 

二：操作系统

　　CentOS Linux release 7.3.1611 (Core) 

三：内核

　　3.10.0-514.el7.x86_64

 

四：版本信息：

　　openstack版本mitaka

**注意:**

　　**在修改配置文件的时候 一定要注意不要再某条配置文件后面添加注释。可以上面与下面**

　　**相关配置一定要在标题的后追加，不要再原有的基础上修改**

 

效果图：

　　![img](assets/1092539-20170324124725127-2034017966.png)

**本博客主要是搭建前期的环境，后续的一些内部操作将会在后面的博客中陆续更新**

 

**准备环境:**

　　为三台主机添加hosts解析文件，为每台机器设置主机名，关闭firewalld，sellinux，设置静态IP

　　为计算节点添加两块网卡，为网络节点添加两块网卡

　　

　　自定义yum源

 　  所有节点执行：

　　　　yum makecache && yum install vim net-tools -y&& yum update -y

 　　　  关闭yum自动更新

　　　　修改/ect/yum/yum-cron.conf将download_updates = yes改为no即可

　　

　　也可以使用网络yum源： 

　　下载网络yum源（在所有节点执行）

　　　　yum install centos-release-openstack-mitaka -y

 　　　　制作yum缓存并更新系统

 

　　预装包（在所有节点执行）

　　　　yum install python-openstackclient -y

　　　　yum install openstack-selinux -y

 

　　部署时间服务（在所有节点执行）

　　　　yum install chrony -y 

 

控制节点：

​    修改配置：

​    /etc/chrony.conf

​    server ntp.staging.kycloud.lan iburst

​    allow 192.168.1.0/24

 

启动服务：

​    systemctl enable chronyd.service

​    systemctl start chronyd.service

 

其余节点：

　　

​    修改配置：

​    /etc/chrony.conf

​    server 192.168.1.142 iburst

 

启动服务

​    systemctl enable chronyd.service

​    systemctl start chronyd.service

 

验证：

​    每台机器执行：

​    chronyc sources

​    在S那一列包含*号，代表同步成功（可能需要花费几分钟去同步，时间务必同步）

 

**控制节点操作**

 

安装数据库

　　yum install mariadb mariadb-server python2-PyMySQL -y

[![复制代码](assets/copycode-1556352264384.gif)](javascript:void(0);)

```
编辑：
/etc/my.cnf.d/openstack.cnf[mysqld]
bind-address = 192.168.1.142#控制节点IP
default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
启动服务
systemctl enable mariadb.service
systemctl start mariadb.service
```

　　

安装mogodb

　　yum install mongodb-server mongodb -y

 

 

```
编辑：/etc/mongod.confbind_ip = 192.168.1.142
smallfiles = true
```

 

```
保存退出后启动服务 并添加开机自启动
systemctl enable mongod.service
systemctl start mongod.service
```

 

部署消息列队
　　yum install rabbitmq-server -y

 

```
启动服务并开机自启
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service
新建rabbitmq用户名与密码(这里面我所有的密码都用lhc001)
rabbitmqctl add_user openstack lhc001

为新建的用户openstack设定权限：
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
```

 

安装memcache缓存token
　　yum install memcached python-memcached -y

```
启动并添加到开机自启动
systemctl enable memcached.service
systemctl start memcached.service
```

 

**部署keystone服务**

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
对数据库的操作
CREATE DATABASE keystone;

GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
IDENTIFIED BY 'lhc001';

GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
IDENTIFIED BY 'lhc001';

GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'controller01' \
IDENTIFIED BY 'lhc001';
#远程登录的要写上这个不然会报错
  
flush privileges;
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

安装keystone 
　　yum install openstack-keystone httpd mod_wsgi -y

 

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
编辑/etc/keystone/keystone.conf
[DEFAULT]
admin_token = lhc001 

[database]
connection = mysql+pymysql://keystone:lhc001@controller01/keystone

[token]
provider = fernet    
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

同步修改数据到数据库中
　　su -s /bin/sh -c "keystone-manage db_sync" keystone

 

初始化fernet keys
　　keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

 

配置apache服务

```
编辑：/etc/httpd/conf/httpd.conf
ServerName controller01
```

 

硬链接/usr/share/keystone/wsgi-keystone.conf到/etc/httpd/conf.d/下

```
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/wsgi-keystone.conf
```

 

重新启动httpd

```
systemctl restart httpd
```

 

 

**创建服务实体和访问站点**

```
实现配置管理员环境变量，用于获取后面创建的权限
export OS_TOKEN=lhc001
export OS_URL=http://controller01:35357/v3
export OS_IDENTITY_API_VERSION=3    
```

 

基于上一步给的权限，创建认证服务实体（目录服务）

```
openstack service create \
  --name keystone --description "OpenStack Identity" identity
```

![img](assets/1092539-20170331211047445-743218954.png)

 

基于上一步建立的服务实体，创建访问该实体的三个api端点

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
openstack endpoint create --region RegionOne \
  identity public http://controller01:5000/v3
  
openstack endpoint create --region RegionOne \
  identity internal http://controller01:5000/v3
  
openstack endpoint create --region RegionOne \
  identity admin http://controller01:35357/v3    
    
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 ![img](assets/1092539-20170331211155977-1264642395.png)

![img](assets/1092539-20170331211227867-1274478584.png)

![img](assets/1092539-20170331211232164-1084535602.png)

 

 创建域，租户，用户，角色，把四个元素关联到一起

 建立一个公共的域名： 

```
openstack domain create --description "Default Domain" default    
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
管理员：admin
openstack project create --domain default \
  --description "Admin Project" admin
  
openstack user create --domain default \
  --password-prompt admin
 
openstack role create admin

openstack role add --project admin --user admin admin
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
普通用户：demo
openstack project create --domain default \
  --description "Demo Project" demo
  
openstack user create --domain default \
  --password-prompt demo
 
openstack role create user

openstack role add --project demo --user demo user
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
为后续的服务创建统一租户service
openstack project create --domain default \
  --description "Service Project" service
```

 

 

验证关联

![img](assets/1092539-20170331211706086-609279881.png)

![img](assets/1092539-20170331211742461-1120657892.png)

 

**验证操作**

```
编辑：/etc/keystone/keystone-paste.ini
在[pipeline:public_api], [pipeline:admin_api], and [pipeline:api_v3] 三个地方
移走：admin_token_auth 
```

![img](assets/1092539-20170331212022305-294402719.png)

 

**新建客户端脚本文件**

管理员：admin-openrc

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=lhc001
export OS_AUTH_URL=http://controller01:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

普通用户demo：demo-openrc

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=lhc001
export OS_AUTH_URL=http://controller01:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

退出控制台 重新登录
source admin-openrc
openstack token issue

![img](assets/1092539-20170331212418602-647205576.png)

 

**部署镜像服务** 

数据库操作 

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
mysql -u root -p
CREATE DATABASE glance;

GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
IDENTIFIED BY 'lhc001';

GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
  IDENTIFIED BY 'lhc001';
  
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'controller01' \
  IDENTIFIED BY 'lhc001';
#同上面keystone对数据库的操作一样
flush privileges;
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

keystone认证操作：
上面提到过：所有后续项目的部署都统一放到一个租户service里，然后需要为每个项目建立用户，建管理员角色，建立关联

```
openstack user create --domain default --password-prompt glance
```

 ![img](assets/1092539-20170331212606274-1746885050.png)

 

关联角色

```
openstack role add --project service --user glance admin
建立服务实体
openstack service create --name glance \
  --description "OpenStack Image" image
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
建端点
openstack endpoint create --region RegionOne \
  image public http://controller01:9292
  

openstack endpoint create --region RegionOne \
  image internal http://controller01:9292
 
openstack endpoint create --region RegionOne \
  image admin http://controller01:9292
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

安装glance软件
　　yum install openstack-glance -y

**这次的环境统一都是用本地存储，但是无论什么存储，都要在启动glance之前建立，不然启动时glance搜索不到，虽然不会报错，但是对于后面的一些操作会报错。所以为了省略麻烦 还是先提前建立好**

```
mkdir /var/lib/glance/images/
chown glance. /var/lib/glance/images/
```

 

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
编辑/etc/glance/glacne-api.conf
```

　[database]

　connection = mysql+pymysql://glance:lhc001@controller01/glance

```
[keystone_authtoken]
auth_url = http://controller01:5000
memcached_servers = controller01:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = lhc001

[paste_deploy]
flavor = keystone

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

**编辑/etc/glance/glacne-registry**

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
这里的registry配置的数据库是用来检索镜像元数据用的
[database]
connection = mysql+pymysql://glance:lhc001@controller01/glance

在之前的版本中，glance-api怎么配置registry就怎么配置。现在变成了v3版本 就不需要那么繁琐，直接在glance-registry中添加一条数据库接口，其它一概不用
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

```
同步数据库：输出不是报错
su -s /bin/sh -c "glance-manage db_sync" glance
```

 

```
启动并添加到开机自启动
systemctl enable openstack-glance-api.service \
  openstack-glance-registry.service
systemctl start openstack-glance-api.service \
  openstack-glance-registry.service
```

 

 

**验证操作**

![img](assets/1092539-20170331215806883-1754662417.png)

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
查看openstack image list 输出为空
然后执行镜像上传
openstack image create "cirros" \
  --file cirros-0.3.4-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

![img](assets/1092539-20170331215916649-873742279.png)

![img](assets/1092539-20170331215948055-2106477786.png)

 

 **部署compute服务**

再部署任何组件时都有对keystone的数据库中进行添加用户的操作，即所有组件共用一个数据库服务

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
compute对数据库的操作
CREATE DATABASE nova_api;

CREATE DATABASE nova;

GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' \
  IDENTIFIED BY 'lhc001';
  
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' \
  IDENTIFIED BY 'lhc001';

GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'controller01' \
  IDENTIFIED BY 'lhc001';
  
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
  IDENTIFIED BY 'lhc001';
  
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
  IDENTIFIED BY 'lhc001';

GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'controller01' \
  IDENTIFIED BY 'lhc001';

flush privileges;
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

keystone部分的相关操作

 

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
openstack user create --domain default \
  --password-prompt nova
创建一个nova用户 输入用户名密码 
 
openstack role add --project service --user nova admin
用户与角色项目关联

openstack service create --name nova \
  --description "OpenStack Compute" compute
 创建实体
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
openstack endpoint create --region RegionOne \
  compute public http://controller01:8774/v2.1/%\(tenant_id\)s
  
openstack endpoint create --region RegionOne \
  compute internal http://controller01:8774/v2.1/%\(tenant_id\)s
  
openstack endpoint create --region RegionOne \
  compute admin http://controller01:8774/v2.1/%\(tenant_id\)s  

  三个endpoint 
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

安装软件包：

yum install openstack-nova-api openstack-nova-conductor \

  openstack-nova-console openstack-nova-novncproxy \

  openstack-nova-scheduler -y

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
编辑/etc/nova/nova.conf

[DEFAULT]
enabled_apis = osapi_compute,metadata
rpc_backend = rabbit
auth_strategy = keystone
#下面的为管理ip
my_ip = 192.168.1.142
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver

[api_databases]
connection = mysql+pymysql://nova:lhc001@controller01/nova_api

[database]
connection = mysql+pymysql://nova:lhc001@controller01/nova

[oslo_messaging_rabbit]
rabbit_host = controller01
rabbit_userid = openstack
rabbit_password = lhc001

[keystone_authtoken]
auth_url = http://controller01:5000
memcached_servers = controller01:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = lhc001

[vnc]
#下面的为管理ip
vncserver_listen = 192.168.1.142
#下面的为管理ip
vncserver_proxyclient_address = 192.168.1.142 

[oslo_concurrency]
lock_path = /var/lib/nova/tmp  
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

同步数据库 有输出不是报错

```
su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage db sync" nova
```

 

 

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
启动并添加到开机自启动
systemctl enable openstack-nova-api.service \
  openstack-nova-consoleauth.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service openstack-nova-novncproxy.service
systemctl start openstack-nova-api.service \
  openstack-nova-consoleauth.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service openstack-nova-novncproxy.service
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 **接下来就要配置计算节点了 控制节点就暂时先放一放**

 

**配置计算节点** 

安装软件包：
yum install openstack-nova-compute libvirt-daemon-lxc -y

修改配置：
编辑/etc/nova/nova.conf

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
#计算节点管理网络ip
my_ip = 192.168.1.141
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver

[oslo_messaging_rabbit]
rabbit_host = controller01
rabbit_userid = openstack
rabbit_password = lhc001

[vnc]
enabled = True
vncserver_listen = 0.0.0.0
#计算节点管理网络ip
vncserver_proxyclient_address = 192.168.1.141
#控制节点管理网络ip
novncproxy_base_url = http://192.168.1.142:6080/vnc_auto.html

[glance]
api_servers = http://controller01:9292

[oslo_concurrency]
lock_path = /var/lib/nova/tmp
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
启动程序

systemctl enable libvirtd.service openstack-nova-compute.service
systemctl start libvirtd.service openstack-nova-compute.service
```

 

 

 **验证操作：**

 控制节点测试

![img](assets/1092539-20170401090159414-251752997.png)

![img](assets/1092539-20170401090235961-1701322686.png)

 

**网络部署** 

还是在控制节点进行数据库操作

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' \
  IDENTIFIED BY 'lhc001';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' \
  IDENTIFIED BY 'lhc001';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'controller01' \
  IDENTIFIED BY 'lhc001';  
flush privileges;
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

keystone对于neutron的操作

```
创建用户建立关联
openstack user create --domain default --password-prompt neutron
openstack role add --project service --user neutron admin
```

 

 创建实体服务与三个endpoint

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
openstack service create --name neutron \
  --description "OpenStack Networking" network


openstack endpoint create --region RegionOne \
  network public http://controller01:9696
  
openstack endpoint create --region RegionOne \
  network internal http://controller01:9696
  
openstack endpoint create --region RegionOne \
  network admin http://controller01:9696
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 安装neutron组件

```
yum install openstack-neutron openstack-neutron-ml2 python-neutronclient which  -y
```

 

配置服务组件 
编辑 /etc/neutron/neutron.conf文件

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[DEFAULT]
core_plugin = ml2
service_plugins = router
#下面配置:启用重叠IP地址功能
allow_overlapping_ips = True
rpc_backend = rabbit
auth_strategy = keystone
notify_nova_on_port_status_changes = True
notify_nova_on_port_data_changes = True

[oslo_messaging_rabbit]
rabbit_host = controller01
rabbit_userid = openstack
rabbit_password = lhc001

[database]
connection = mysql+pymysql://neutron:lhc001@controller01/neutron

[keystone_authtoken]
auth_url = http://controller01:5000
memcached_servers = controller01:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = lhc001

[nova]
auth_url = http://controller01:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = nova
password = lhc001

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 编辑/etc/neutron/plugins/ml2/ml2_conf.ini文件

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[ml2]
type_drivers = flat,vlan,vxlan,gre
tenant_network_types = vxlan
mechanism_drivers = openvswitch,l2population
extension_drivers = port_security

[ml2_type_flat]
flat_networks = provider

[ml2_type_vxlan]
vni_ranges = 1:1000

[securitygroup]
enable_ipset = True
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 编辑/etc/nova/nova.conf文件

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[neutron]
url = http://controller01:9696
auth_url = http://controller01:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = lhc001
service_metadata_proxy = True
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

创建链接
　　ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

 数据库同步：会有输出 并不是报错

```
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
 --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
```

 

 重新启动nova

　　 systemctl restart openstack-nova-api.service

启动neutron并加入到开机自启
　　systemctl enable neutron-server.service
　　systemctl start neutron-server.service

 

**配置网络节点**

```
编辑 /etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
```

 

 

执行下列命令，立即生效
　　sysctl -p

 

安装软件包
　　yum install openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch -y

配置组件 
编辑/etc/neutron/neutron.conf文件

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[DEFAULT]
core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True
rpc_backend = rabbit

[oslo_messaging_rabbit]
rabbit_host = controller01
rabbit_userid = openstack
rabbit_password = lhc001

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 编辑 /etc/neutron/plugins/ml2/openvswitch_agent.ini文件

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[ovs]
#下面ip为网络节点数据网络ip
local_ip=1.1.1.119
bridge_mappings=external:br-ex

[agent]
tunnel_types=gre,vxlan
#l2_population=True
prevent_arp_spoofing=True
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 配置L3代理。编辑 /etc/neutron/l3_agent.ini文件

```
[DEFAULT]
interface_driver=neutron.agent.linux.interface.OVSInterfaceDriver
external_network_bridge=br-ex
```

 

配置DHCP代理。编辑 /etc/neutron/dhcp_agent.ini文件

```
[DEFAULT]
interface_driver=neutron.agent.linux.interface.OVSInterfaceDriver
dhcp_driver=neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata=True
```

 

配置元数据代理。编辑 /etc/neutron/metadata_agent.ini文件

```
[DEFAULT]
nova_metadata_ip=controller01
metadata_proxy_shared_secret=lhc001
```

 

启动服务
网路节点：

systemctl enable neutron-openvswitch-agent.service neutron-l3-agent.service \
neutron-dhcp-agent.service neutron-metadata-agent.service

systemctl start neutron-openvswitch-agent.service neutron-l3-agent.service \
neutron-dhcp-agent.service neutron-metadata-agent.service

注意上面标红的服务，在查看服务状态的时候ovs会提示启动失败，这个不用担心，因为之前上面的配置文件中配置的数据管理IP与网桥都没有创建，它的log中提示找不到，没关系 后面会创建出来。

 

创建为网络节点数据网络ip

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@network01 network-scripts]# cat ifcfg-ens37 
TYPE="Ethernet"
BOOTPROTO="static"
IPADDR=1.1.1.119
NETMASK=255.255.255.0
NAME="ens37"
DEVICE="ens37"
ONBOOT="yes"
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

计算节点也是一样，也要创建一个数据管理IP

cd /etc/sysconfig/network-scripts
cp ifcfg-ens33 ifcfg-ens37

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@compute01 network-scripts]# cat ifcfg-ens37 
TYPE="Ethernet"
BOOTPROTO="static"
IPADDR=1.1.1.117
NETMASK=255.255.255.0
NAME="ens37"
DEVICE="ens37"
ONBOOT="yes"
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

重启两节点网卡服务

　　systemctl restart nwtwork

两节点互ping 测试

 

**回到网络节点上创建网桥**

建立网桥，br-ex网卡与外部网卡绑定，由于在实验之前 我们添加了三块网卡，但是我这台机器上能上网的只有一个IP地址，所以能用的网络就两个一个数据网络，一个管理网络，但是在真实环境中，是一定要用三块网卡的

cp ifcfg-ens33 ifcfg-br-ex

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@network01 network-scripts]# cat ifcfg-br-ex 
TYPE="Ethernet"
BOOTPROTO="static"
IPADDR=192.168.1.140
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=192.168.1.1
NAME="br-ex"
DEVICE="br-ex"
ONBOOT="yes"
NM_CONTROLLED=no    #这个一定要添加不然网桥会建立失败
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

**同理，既然已经将网桥建立了，那么ens33上面的IP地址就要拿掉**

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@network01 network-scripts]# cat ifcfg-ens33
TYPE="Ethernet"
BOOTPROTO="static"
DEFROUTE="yes"
PEERDNS="yes"
PEERROUTES="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_PEERDNS="yes"
IPV6_PEERROUTES="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33"
UUID="e82bc9e4-d28e-4363-aab4-89fda28da938"
DEVICE="ens33"
ONBOOT="yes" 
NM_CONTROLLED=no      #在真实网卡上也要添加
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

重启网络节点网卡

　　systemctl restart nwtwork

这时候再次查看ovs服务的状态（

systemctl status neutron-openvswitch-agent.service）就发现这个服务一定running了

 

到这里网络节点就告一段落了

 

**配置计算节点**

编辑 /etc/sysctl.conf

```
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0

sysctl -p
```

 

 

计算节点安装ovs等组件
　　yum install openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch -y

 

编辑 /etc/neutron/neutron.conf文件

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[DEFAULT]
rpc_backend = rabbit
#auth_strategy = keystone

[oslo_messaging_rabbit]
rabbit_host = controller01
rabbit_userid = openstack
rabbit_password = lhc001

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

编辑 /etc/neutron/plugins/ml2/openvswitch_agent.ini

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[ovs]
#下面ip为计算节点数据网络ip
local_ip = 1.1.1.117


[agent]
tunnel_types = gre,vxlan
l2_population = True
arp_responder = True
prevent_arp_spoofing = True

[securitygroup]
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

编辑 /etc/nova/nova.conf

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[neutron]
url = http://controller01:9696
auth_url = http://controller01:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = lhc001
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

```
启动服务重启nova
systemctl enable neutron-openvswitch-agent.service
systemctl start neutron-openvswitch-agent.service
systemctl restart openstack-nova-compute.service
```

 

 

ok，接下来的事情就简单多了，在控制节点部署一个dashboard服务

 

**控制节点操作**

安装软件包
　　yum install openstack-dashboard -y

 

配置/etc/openstack-dashboard/local_settings

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
OPENSTACK_HOST = "controller01"

ALLOWED_HOSTS = ['*', ]

SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
#SESSION_ENGINE = 'django.contrib.sessions.backends.file'
#这个配置文件没有我们在最后面添加进去，输入上面的那个配置在登录页面进行登录的时候可能会报错，如果报错，修改成下面的配置 问题就会解决

CACHES = {
    'default': {
         'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
         'LOCATION': 'controller01:11211',
    }
}

OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST

OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True

OPENSTACK_API_VERSIONS = {
    "data-processing": 1.1,
    "identity": 3,
    "image": 2,
    "volume": 2,
    "compute": 2,
}


OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"

OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"

TIME_ZONE = "UTC"
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

重新启动服务
　　systemctl enable httpd.service memcached.service
　　systemctl restart httpd.service memcached.service

 

在浏览器段进行测试

 http://http://192.168.1.142/dashboard/

 

![img](assets/1092539-20170401115517461-461473797.png)

 





标签: [openstack](https://www.cnblogs.com/charles1ee/tag/openstack/)