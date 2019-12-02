# Harbor私有镜像仓库无坑搭建
目录

1. harbor介绍
2. docker-ce的安装
3. docker-compose的安装
4. Harbor私有仓库的安装
5. 客户端连接镜像仓库配置过程
1. harbor介绍
Docker容器应用的开发和运行离不开可靠的镜像管理，虽然Docker官方也提供了公共的镜像仓库，但是从安全和效率等方面考虑，部署我们私有环境内的Registry也是非常必要的。Harbor是由VMware公司开源的企业级的Docker Registry管理项目，它包括权限管理(RBAC)、LDAP、日志审核、管理界面、自我注册、镜像复制和中文支持等功能。

2. docker-ce的安装
step 1：安装一些必要的系统工具

```
yum install -y yum-utils device-mapper-persistent-data lvm2
```


Step 2：添加docker镜像源

```
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```


Step 3: 安装 Docker-CE

```
yum -y install docker-ce
```


Step 4: 开启Docker服务

```
systemctl start docker.server
```

> 注意：
> 官方软件源默认启用了最新的软件，您可以通过编辑软件源的方式获取各个版本的软件包。例如官方并没有将测试版本的软件源置为可用，你可以通过以下方式开启。同理可以开启各种测试版本等。

```
 vim /etc/yum.repos.d/docker-ce.repo
```


将 [docker-ce-test] 下方的 enabled=0 修改为 enabled=1

安装指定版本的Docker-CE:
Step 1: 查找Docker-CE的版本:

```
 yum list docker-ce.x86_64 --showduplicates | sort -r
 
 Loading mirror speeds from cached hostfile
 Loaded plugins: branch, fastestmirror, langpacks
 docker-ce.x86_64            17.03.1.ce-1.el7.centos            docker-ce-stable
 docker-ce.x86_64            17.03.1.ce-1.el7.centos            @docker-ce-stable
 docker-ce.x86_64            17.03.0.ce-1.el7.centos            docker-ce-stable
 Available Packages
```


Step2 : 安装指定版本的Docker-CE: (VERSION 例如上面的 17.03.0.ce.1-1.el7.centos)

```
 yum -y install docker-ce-[VERSION]
```


FQA：

```
默认配置下，如果在 CentOS 使用 Docker CE 看到下面的这些警告信息：

WARNING: bridge-nf-call-iptables is disabled
WARNING: bridge-nf-call-ip6tables is disabled

#请添加内核配置参数以启用这些功能。
$ sudo tee -a /etc/sysctl.conf <<-EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
然后重新加载 sysctl.conf 即可

$ sudo sysctl -p
```

3.安装docker-compose
方法一

```
curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
#查看版本
docker-compose version
```


方法二
CentOS:

```
yum install epel-release -y
yum install python-pip -y

Ubuntu:
apt-get install python-pip -y
```



# 通用命令
```
pip --version
pip install --upgrade pip
pip install -U -i https://pypi.tuna.tsinghua.edu.cn/simple docker-compose 
docker-compose version
```


4.Harbor私有仓库的安装
下载Harbor安装文件
从 github harbor 官网 release 页面下载指定版本的安装包。

```
1、在线安装包
    $ wget https://github.com/vmware/harbor/releases/download/v1.1.2/harbor-online-installer-v1.1.2.tgz
    $ tar xvf harbor-online-installer-v1.1.2.tgz
2、离线安装包
    $wget https://storage.googleapis.com/harbor-releases/release-1.8.0/harbor-offline-installer-v1.8.0.tgz
    $ tar xvf harbor-offline-installer-v1.8.0.tgz
```

> 本次离线安装。
> 推荐使用第二种，因为第一种在线安装可能由于官网源的网络波动导致安装失败。

配置Harbor
解压缩之后，目录下生成harbor.yml文件，该文件就是Harbor的配置文件。

```
## Configuration file of Harbor

# hostname设置访问地址，可以使用ip、域名，不可以设置为127.0.0.1或localhost

hostname = docker.bksx.com

# 访问协议，默认是http，也可以设置https，如果设置https，则nginx ssl需要设置on

ui_url_protocol = http

# mysql数据库root用户默认密码root123，实际使用时修改下

db_password = root123

max_job_workers = 3 
customize_crt = on
ssl_cert = /data/cert/server.crt
ssl_cert_key = /data/cert/server.key
secretkey_path = /data
admiral_url = NA

# 邮件设置，发送重置密码邮件时使用

email_identity = 
email_server = smtp.mydomain.com
email_server_port = 25
email_username = sample_admin@mydomain.com
email_password = abc
email_from = admin <sample_admin@mydomain.com>
email_ssl = false

# 启动Harbor后，管理员UI登录的密码，默认是Harbor12345

harbor_admin_password = 1qaz@WSX

# 认证方式，这里支持多种认证方式，如LADP、本次存储、数据库认证。默认是db_auth，mysql数据库认证

auth_mode = db_auth

# LDAP认证时配置项

#ldap_url = ldaps://ldap.mydomain.com
#ldap_searchdn = uid=searchuser,ou=people,dc=mydomain,dc=com
#ldap_search_pwd = password
#ldap_basedn = ou=people,dc=mydomain,dc=com
#ldap_filter = (objectClass=person)
#ldap_uid = uid 
#ldap_scope = 3 
#ldap_timeout = 5

# 是否开启自注册

self_registration = on

# Token有效时间，默认30分钟

token_expiration = 30

# 用户创建项目权限控制，默认是everyone（所有人），也可以设置为adminonly（只能管理员）

project_creation_restriction = everyone

verify_remote_cert = on
```


启动 Harbor

启动 Harbor

修改完配置文件后，在的当前目录执行./install.sh，Harbor服务就会根据当期目录下的docker-compose.yml开始下载依赖的镜像，检测并按照顺序依次启动各

```
[root@localhost harbor]# ./install.sh 

[Step 0]: checking installation environment ...

Note: docker version: 18.03.1

Note: docker-compose version: 1.18.0

[Step 1]: loading Harbor images ...
```


Harbor依赖的镜像及启动服务如下：

Harbor依赖的镜像及启动服务如下：

```
# docker images

REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
vmware/harbor-jobservice     v1.1.2              ac332f9bd31c        10 days ago         162.9 MB
vmware/harbor-ui             v1.1.2              803897be484a        10 days ago         182.9 MB
vmware/harbor-adminserver    v1.1.2              360b214594e7        10 days ago         141.6 MB
vmware/harbor-db             v1.1.2              6f71ee20fe0c        10 days ago         328.5 MB
vmware/registry              2.6.1-photon        0f6c96580032        4 weeks ago         150.3 MB
vmware/harbor-notary-db      mariadb-10.1.10     64ed814665c6        10 weeks ago        324.1 MB
vmware/nginx                 1.11.5-patched      8ddadb143133        10 weeks ago        199.2 MB
vmware/notary-photon         signer-0.5.0        b1eda7d10640        11 weeks ago        155.7 MB
vmware/notary-photon         server-0.5.0        6e2646682e3c        3 months ago        156.9 MB
vmware/harbor-log            v1.1.2              9c46a7b5e517        4 months ago        192.4 MB
photon                       1.0                 e6e4e4a2ba1b        11 months ago       127.5 MB
```



```
# docker-compose ps

       Name                     Command               State                                Ports                               

------------------------------------------------------------------------------------------------------------------------------

harbor-adminserver   /harbor/harbor_adminserver       Up                                                                       
harbor-db            docker-entrypoint.sh mysqld      Up      3306/tcp                                                         
harbor-jobservice    /harbor/harbor_jobservice        Up                                                                       
harbor-log           /bin/sh -c crond && rm -f  ...   Up      127.0.0.1:1514->514/tcp                                          
harbor-ui            /harbor/harbor_ui                Up                                                                       
nginx                nginx -g daemon off;             Up      0.0.0.0:443->443/tcp, 0.0.0.0:4443->4443/tcp, 0.0.0.0:80->80/tcp 
registry             /entrypoint.sh serve /etc/ ...   Up      5000/tcp   
```

​        

启动完成后，我们访问刚设置的hostname即可 http://docker.bksx.com，默认是80端口，如果端口占用，我们可以去修改docker-compose.yml文件中，对应服务的端口映射。windos，hosts文件地址：C:\Windows\System32\drivers\etc，将域名与ip添加进去即可。

启动完成后，我们访问刚设置的hostname即可 http://docker.bksx.com，默认是80端口，如果端口占用，我们可以去修改docker-compose.yml文件中，对应服务的端口映射。windos，hosts文件地址：C:\Windows\System32\drivers\etc，将域名与ip添加进去即可。


登录 Web Harbor
输入用户名admin，默认密码（或已修改密码）登录系统。

我们可以看到系统各个模块如下：

项目：新增/删除项目，查看镜像仓库，给项目添加成员、查看操作日志、复制项目等
日志：仓库各个镜像create、push、pull等操作日志
系统管理
用户管理：新增/删除用户、设置管理员等
复制管理：新增/删除从库目标、新建/删除/启停复制规则等
配置管理：认证模式、复制、邮箱设置、系统设置等
其他设置
用户设置：修改用户名、邮箱、名称信息
修改密码：修改用户密码
注意：非系统管理员用户登录，只能看到有权限的项目和日志，其他模块不可见。

新建项目
我们新建一个名称为wanyang的项目，设置不公开。注意：当项目设为公开后，任何人都有此项目下镜像的读权限。命令行用户不需要“docker login”就可以拉取此项目下的镜像。


新建项目完毕后，我们就可以用admin账户提交本地镜像到Harbor仓库了。例如我们提交本地nginx镜像

1、admin登录

```
$ docker login docker.bksx.com
Username: admin
Password:
Login Succeeded
```

2、给镜像打tag

```
$ docker tag nginx docker.bksx.com/docker/nginx:latest
$ docker images
REPOSITORY                         TAG                 IMAGE ID            CREATED             SIZE
nginx                              latest              958a7ae9e569        2 weeks ago         109 MB
docker.bksx.com/docker/nginx         latest              958a7ae9e569        2 weeks ago         109 MB
```

3、push到仓库

```
$ docker push docker.bksx.com/docker/nginx
The push refers to a repository [docker.bksx.com/docker/nginx]
a552ca691e49: Pushed
7487bf0353a7: Pushed
8781ec54ba04: Pushed
latest: digest: sha256:41ad9967ea448d7c2b203c699b429abe1ed5af331cd92533900c6d77490e0268 size: 948
```

上传完毕后，登录Web Harbor，选择项目，项目名称docker，就可以查看刚才上传的nginx image了。

FAQ
配置并启动Harbor之后，本地执行登录操作，报错：

```
docker login docker.bksx.com
Username: admin
Password:
Error response from daemon: Get https://docker.bksx.com/v2/users/: dial tcp 10.236.63.76:443: getsockopt: connection refused
```

这是因为docker1.3.2版本开始默认docker registry使用的是https，我们设置Harbor默认http方式，所以当执行用docker login、pull、push等命令操作非https的docker regsitry的时就会报错。解决办法：

这是因为docker1.3.2版本开始默认docker registry使用的是https，我们设置Harbor默认http方式，所以当执行用docker login、pull、push等命令操作非https的docker regsitry的时就会报错。解决办法：

如果系统是MacOS，则可以点击“Preference”里面的“Advanced”在“Insecure
Registry”里加上docker.bksx.com，重启Docker客户端就可以了。
如果系统是Ubuntu，则修改配置文件/lib/systemd/system/docker.service，修改[Service]下ExecStart参数，增加– insecure-registry
docker.bksx.com。
如果系统是Centos，可以修改配置/etc/sysconfig/docker，将OPTIONS增加 –insecure-registry
docker.bksx.com。
如果是新版本的docker在/etc/sysconfig/ 没有docker这个配置文件的情况下。
#在daemon.json中添加以下参数

```
[root@localhost harbor]# cat /etc/docker/daemon.json 
{
  "insecure-registries": [
    "docker.bksx.com"
  ]
}
```

注意：该文件必须符合 json 规范，否则 Docker 将不能启动。

注意：该文件必须符合 json 规范，否则 Docker 将不能启动。

如果需要修改Harbor的配置文件harbor.cfg，因为Harbor是基于docker-compose服务编排的，我们可以使用docker-compose命令重启Harbor。不修改配置文件，重启Harbor命令：docker-compose start | stop | restart

1、停止Harbor

```
$ docker-compose down -v
```

Stopping nginx ... done
Stopping harbor-jobservice ... done
......
Removing harbor-log ... done
Removing network harbor_harbor

2、启动Harbor

```
$ docker-compose up -d
```

Creating network "harbor_harbor" with the default driver
Creating harbor-log ... 
......
Creating nginx
Creating harbor-jobservice ... done
