# zabbix + grafana 安装使用

------



# [#](http://www.liuwq.com/views/监控/zabbix_install.html#zabbix使用)zabbix使用

> 注:本文以上使用的是openresty+php7+mysql+zabbix,没有使用官网用的apache作为web代理,如果想使用请到这里,

[zabbix 手册](https://www.zabbix.com/documentation/3.4/zh/manual/installation/install_from_packages)

## [#](http://www.liuwq.com/views/监控/zabbix_install.html#安装server端)安装server端

### [#](http://www.liuwq.com/views/监控/zabbix_install.html#zabbix官方有提供各发行版的源)zabbix官方有提供各发行版的源

```
rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-1.el7.centos.noarch.rpm
```

### [#](http://www.liuwq.com/views/监控/zabbix_install.html#安装zabbix-server包：)安装zabbix server包：

```
yum install zabbix-server-mysql zabbix-web-mysql
```

### [#](http://www.liuwq.com/views/监控/zabbix_install.html#client安装：)client安装：

```
yum install zabbix-agent
```

### [#](http://www.liuwq.com/views/监控/zabbix_install.html#zabbix需要数据库支持，通过上面的命令不会自动安装mysql，先安装mysql)zabbix需要数据库支持，通过上面的命令不会自动安装mysql，先安装mysql

```
yum install mysql mysql-server
```

### [#](http://www.liuwq.com/views/监控/zabbix_install.html#安装好后建立zabbix的数据库)安装好后建立zabbix的数据库

```shell
      create database zabbix character set utf8 collate utf8_bin;
      grant all privileges on zabbix.* to zabbix@'localhost' identified by ‘zabbix’;
```

#### [#](http://www.liuwq.com/views/监控/zabbix_install.html#然后导入zabbix的数据库文件)然后导入zabbix的数据库文件

```shell
      cd /usr/share/doc/zabbix-server-mysql-2.2.9/create
      mysql -uzabbix -p zabbix < schema.sql
      mysql -uzabbix -p zabbix < images.sql
      mysql -uzabbix -p zabbix < data.sql
```

#### [#](http://www.liuwq.com/views/监控/zabbix_install.html#导入成功后将数据库信息加入zabbix-server-conf)导入成功后将数据库信息加入zabbix_server.conf

```shell
      vi /etc/zabbix/zabbix_server.conf
      DBHost=localhost
      DBName=zabbix
      DBUser=zabbix
      DBPassword=zabbix
```

#### [#](http://www.liuwq.com/views/监控/zabbix_install.html#启动zabbix-server)启动zabbix server

```
service zabbix-server start
```

### [#](http://www.liuwq.com/views/监控/zabbix_install.html#安装openresty)安装openresty

```bash
 yum -y install pcre-devel freetype-devel libtool mercurial pkgconfig zlib-devel openssl-devel

 wget https://openresty.org/download/openresty-1.9.7.4.tar.gz

 tar zxvf openresty-1.9.7.4.tar.gz

 cd openresty-1.9.7.4 \
    && ./configure \
        --with-http_flv_module \
        --with-http_mp4_module \
    && gmake -j $(nproc) \
    && gmake install
 /usr/local/openresty/nginx/sbin/nginx
参考官方文档安装 https://openresty.org/cn/installation.html
这里不多介绍
```

#### [#](http://www.liuwq.com/views/监控/zabbix_install.html#启动配置nginx-conf)启动配置nginx.conf

```bash
server {
listen       80;
server_name  localhost;

#charset koi8-r;

#access_log  logs/host.access.log  main;

client_max_body_size 1024M;

root /usr/share/zabbix; ## zabbix web文件目录
index index.php index.html index.htm;

location / {
  try_files $uri $uri/ /index.php?$query_string;
}

#error_page  404              /404.html;

# redirect server error pages to the static page /50x.html
#
error_page   500 502 503 504  /50x.html;
location = /50x.html {
    root   html;
}

# proxy the PHP scripts to Apache listening on 127.0.0.1:80
#
#location ~ \.php$ {
#    proxy_pass   http://127.0.0.1;
#}

location ~ \.php$ {
  try_files $uri /index.php =404;
  fastcgi_split_path_info ^(.+\.php)(/.+)$;
  fastcgi_pass 127.0.0.1:9000;
  fastcgi_index index.php;
  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
  include fastcgi_params;
}

}
```



**访问zabbix web 文件目录监听80端口**

### [#](http://www.liuwq.com/views/监控/zabbix_install.html#安装php7)安装php7

```bash
# add yum repository
yum -y install epel-release
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
# install php7
yum install -y php70w
yum install -y php70w-devel php70w-pdo php70w-mysqlnd php70w-fpm php70w-opcache php70w-cli php70w-gd php70w-mcrypt php70w-mbstring php70w-xml
# 更改php-fpm的启动用户与监听用户
   sed -i 's/^\(listen.owner =\).\+/\1 nobody/g' /etc/php-fpm.d/www.conf
   sed -i 's/^\(listen.group =\).\+/\1 nobody/g' /etc/php-fpm.d/www.conf
   sed -i 's/^\(user =\).\+/\1 nobody/g' /etc/php-fpm.d/www.conf
   sed -i 's/^\(group =\).\+/\1 nobody/g' /etc/php-fpm.d/www.conf
```

### [#](http://www.liuwq.com/views/监控/zabbix_install.html#在浏览器中访问：http-server-ip-zabbix-进行安装)在浏览器中访问：http://Server-IP/zabbix 进行安装

> 如果遇到 `PHP time zone unknown Fail`错误，编辑`/etc/httpd/conf.d/zabbix.conf`,设置：

```
php_value date.timezone PRC
```

重启`openresty`即可。安装好后默认用户名密码：`Admin/zabbix`

### [#](http://www.liuwq.com/views/监控/zabbix_install.html#配置选项及错误处理)配置选项及错误处理

#### [#](http://www.liuwq.com/views/监控/zabbix_install.html#中文设置)中文设置

zabbix 2.2 LTS默认是没有中文显示的，2.4版本后支持中文，设置中文方法： 用admin登录后，点击右上角的profile，将language选成Chinese（zh_CN）,点更新即可。 zabbix 2.2 版本要编译一下/usr/share/zabbix/include/locales.inc.php文件，设置成：

```
'zh_CN' => array('name' => _('Chinese (zh_CN)'), 'display' => true),
```

## [#](http://www.liuwq.com/views/监控/zabbix_install.html#grafana-安装使用)grafana 安装使用

```shell
yum install https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.5.2-1.x86_64.rpm
yum install grafana
service grafana-server start
systemctl enable grafana-server.service
```

### [#](http://www.liuwq.com/views/监控/zabbix_install.html#使用grafana-cli工具安装)使用grafana-cli工具安装

- 获取可用插件列表

```
grafana-cli plugins list-remote
```

- 安装zabbix插件

```
grafana-cli plugins install alexanderzobnin-zabbix-app
```

- 安装插件完成之后重启garfana服务

```
service grafana-server restart
```

- 使用grafana-zabbix-app源，其中包含最新版本的插件

```
cd /var/lib/grafana/plugins/
```

- 克隆grafana-zabbix-app插件项目

```
git clone https://github.com/alexanderzobnin/grafana-zabbix-app
```

> 注：如果没有git，请先安装git

```
yum –y install git
```

- 插件安装完成重启garfana服务

```
service grafana-server restart
```

> 注：通过这种方式，可以很容器升级插件

```bash
cd /var/lib/grafana/plugins/grafana-zabbix-app
git pull
service grafana-server restart
```

官方网站：https://github.com/alexanderzobnin/grafana-zabbix

官网wiki：http://docs.grafana-zabbix.org/installation/

> 具体zabbix配置

[参考官网:](http://docs.grafana-zabbix.org/installation/configuration/) [配置图标参考网址:](http://www.linuxprobe.com/zabbix-with-grafana.html)