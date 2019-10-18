# Linux下php安装Redis扩展

------



## [#](http://www.liuwq.com/views/linux基础/php安装redis扩展.html#_1、安装redis)1、安装redis

### [#](http://www.liuwq.com/views/linux基础/php安装redis扩展.html#下载：)下载：

```
wget https://github.com/nicolasff/phpredis/archive/2.2.4.tar.gz
```

### [#](http://www.liuwq.com/views/linux基础/php安装redis扩展.html#上传)上传

```shell
phpredis-2.2.4.tar.gz到/usr/local/src目录

cd /usr/local/src #进入软件包存放目录
tar zxvf phpredis-2.2.4.tar.gz #解压
cd phpredis-2.2.4 #进入安装目录

/usr/local/php/bin/phpize #用phpize生成configure配置文件

./configure --with-php-config=/usr/local/php/bin/php-config  #配置
make  #编译
make install  #安装
```

安装完成之后，出现下面的安装路径

```
/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/
```

## [#](http://www.liuwq.com/views/linux基础/php安装redis扩展.html#_2、配置php支持)2、配置php支持

`vi /usr/local/php/etc/php.ini`#编辑配置文件，在最后一行添加以下内容

### [#](http://www.liuwq.com/views/linux基础/php安装redis扩展.html#添加)添加

```
extension="redis.so"
```

## [#](http://www.liuwq.com/views/linux基础/php安装redis扩展.html#重启服务)重启服务