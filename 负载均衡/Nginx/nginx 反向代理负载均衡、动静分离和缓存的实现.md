# nginx 反向代理负载均衡、动静分离和缓存的实现

 ![img](nginx%20%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E3%80%81%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E5%92%8C%E7%BC%93%E5%AD%98%E7%9A%84%E5%AE%9E%E7%8E%B0.assets/1216496-20171116093056468-778964717.png)

 **总项目流程图**，详见 http://www.cnblogs.com/along21/p/8000812.html

## 实验一：实现反向代理负载均衡且动静分离

![img](nginx%20%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E3%80%81%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E5%92%8C%E7%BC%93%E5%AD%98%E7%9A%84%E5%AE%9E%E7%8E%B0.assets/1216496-20171112174106388-826810841.png)

### 1、环境准备：

| 机器名称 | IP配置              | 服务角色       | 备注                       |
| -------- | ------------------- | -------------- | -------------------------- |
| nginx    | VIP：172.17.11.11   | 反向代理服务器 | 开启代理功能设置监控，调度 |
| rs01     | RIP：172.17.22.22   | 后端服务器     | stasic-srv 组              |
| rs02     | RIP：172.17.1.7     | 后端服务器     | stasic-srv 组              |
| rs01     | RIP：172.17.77.77   | 后端服务器     | defautl-srv 组             |
| rs02     | RIP：172.17.252.111 | 后端服务器     | defautl-srv 组             |

 

### 2、下载编译安装tengine

原因：nginx自带的监控模式虽然能用，但是很不易理解；tengine的监控模式易设简单，且是在nginx的二次开发，**和nginx差不多**

（1）官网下载：[http://tengine.taobao.org](http://tengine.taobao.org/) 还支持中文

![img](nginx%20%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E3%80%81%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E5%92%8C%E7%BC%93%E5%AD%98%E7%9A%84%E5%AE%9E%E7%8E%B0.assets/1216496-20171112174106684-30749851.png)

解包 tar tengine-2.1.1.tar.gz

cd tengine-2.1.1

（2）下载所依赖的包

yum -y groupinstall "development tools"

yum install openssl-devel -y

yum install pcre-devel -y

 

（3）编译安装

./configure --prefix=**/usr/local/**tengine 指定安装后的目录

make && make install

 

### 3、设置代理服务器的配置文件

cd /usr/local/tengine/conf

cp nginx.conf /usr/local/tengine/conf/ 若机器上本有nginx，可以把配置文件直接拷过来，没有也可自己设置

vim nginx.conf 全局段和 http段我就不设置了，默认就好

① 定义upstream：后端server 群

```
upstream lnmp-srv1 {
        server 172.17.22.22:80;
        server 172.17.1.7:80;
        check interval=3000 rise=2 fall=5 timeout=1000 type=http;
        check_http_send "HEAD / HTTP/1.0\r\n\r\n";
        check_http_expect_alive http_2xx http_3xx;
}
upstream lnmp-srv2 {
        server 172.17.77.77:80;
        server 172.17.252.111:80;
        server 172.17.1.7:80;
        check interval=3000 rise=2 fall=5 timeout=1000 type=http;
        check_http_send "HEAD / HTTP/1.0\r\n\r\n";
        check_http_expect_alive http_2xx http_3xx;
}
```

② 在server段的location 段中设置**动静分离**

```
server {
 　　listen 80;
 　　location /stats { #设置监听页面
 　　check_status;
 }

 　　 location ~* .jpg|.png|.gif|.jpeg$ {
 　　 　　proxy_pass http://static-srv;
 　　}
 　　 location ~* .css|.js|.html|.xml$ {
 　　　　 proxy_pass http://static-srv;
 　　}
 　　location / {
 　　　　proxy_pass http://default-srv;
 　　}
} 
```

 

### 4、启动tengine服务

① 去编译安装的路径开启服务

cd /usr/local/tengine/sbin/

./nginx 启动tengine

./nginx -s stop 停止

 ② 也可以添加到开机自启

cd /usr/lib/systemd/system/nginx.service  添加修改，Centos 7

cd cd /etc/init.d/  Centos 6

 

### 5、开启后端的web服务

systemctl start nginx

systemctl start php-fpm

systemctl start mariadb

 

### 6、测试

（1）测试反向代理是否成功 http://172.17.11.11/ web页面访问成功

![img](nginx%20%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E3%80%81%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E5%92%8C%E7%BC%93%E5%AD%98%E7%9A%84%E5%AE%9E%E7%8E%B0.assets/1216496-20171112174107309-313739268.png)

（2）测试状态页面 http://172.17.11.11/stats

![img](nginx%20%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E3%80%81%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E5%92%8C%E7%BC%93%E5%AD%98%E7%9A%84%E5%AE%9E%E7%8E%B0.assets/1216496-20171112174107763-1032376999.png)

 

（3）**测试动静分离**

把静态页面的后端server组的服务宕机，发现没有静态的东西了

![img](nginx%20%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E3%80%81%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E5%92%8C%E7%BC%93%E5%AD%98%E7%9A%84%E5%AE%9E%E7%8E%B0.assets/1216496-20171112174108106-1135931089.png)

 

## 实验二：nginx实现缓存功能

![img](nginx%20%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E3%80%81%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E5%92%8C%E7%BC%93%E5%AD%98%E7%9A%84%E5%AE%9E%E7%8E%B0.assets/1216496-20171112174108528-768719615.png)

**需求分析**：为什么需要缓存？

　　缓存的最根本的目的是**为了提高网站性能, 减轻频繁访问数据 ， 而给数据库带来的压力** 。 合理的缓存 ， 还会减轻程序运算时 ， 对CPU 带来的压力。在计算机现代结构中， 操作内存中的数据比操作存放在硬盘上的数据是要快N 个数量级的 ， 操作简单的文本结构的数据 ， 比操作数据库中的数据快N 个数量级 。

　　例如: 每次用户访问网站, 都必须从数据库读取网站的标题, 每读一次需要15 毫秒的时间, 如果有100 个用户( 先不考虑同一时间访问), 每小时访问10 次, 那么就需要读取数据库1000 次, 需要时间15000 毫秒. 如果把页面直接变成页面缓存，则每次访问就不需要去数据库读取，大大提升了网站性能。

**原理：**

缓存数据分为两部分（ 索引， 数据）：
① 存储数据的索引 ，存放在内存中;
② 存储缓存数据，存放在磁盘空间中；
　　分析：如建立a.jpg的缓存，把它的uri作为索引放在内存中，实际图片数据放在磁盘空间中；缓存会有很多，所以索引存放的目录需分层级，把**uri做hash运算**，换算成16位进制，取**最后一个数作为一级目录**的名称[0-f]；二级目录可以用随机最后第2，3位数作为名称[00-ff]；三级目录以此类推...

 

### 1、环境准备：同上实验，实验结构图如下：

![img](nginx%20%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E3%80%81%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E5%92%8C%E7%BC%93%E5%AD%98%E7%9A%84%E5%AE%9E%E7%8E%B0.assets/1216496-20171112174109044-430327779.png)

 

### 2、设置代理服务器的配置文件

① 先在http段定义缓存

**proxy_cache_path /data/cache levels=1:2:2 keys_zone=proxycache:10m inactive=120s max_size=1g**

**分析**：定义一个缓存，路径在/data/cache 下；三级目录，第一级[0-f]随机数字，第二、三级[00-ff]随机数字；定义缓存的名字proxycache，缓存大小10M；存活时间120s；在磁盘占用空间最大1G。

 

② 再在server段引用缓存

```
proxy_cache proxycache; #引用上面定义上的缓存空间，同一缓存空间可以在几个地方使
用
proxy_cache_key $request_uri; #对uri做hash运算
proxy_cache_valid 200 302 301 1h; #200、302、301响应码的响应内容的缓存1小时
proxy_cache_valid any 1m; #其它缓存1分add_header Along-Cache "$upstream_cache_status form $server_addr"; #给请求响应增加一个头部信息，表示从服务器上返回的cache
```

![img](nginx%20%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E3%80%81%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E5%92%8C%E7%BC%93%E5%AD%98%E7%9A%84%E5%AE%9E%E7%8E%B0.assets/1216496-20171112174109450-1348469538.png)

 

### 3、测试：访问 http://172.17.11.11/ 

F12调试模式下，看到自己设置的特定头部存在

![img](nginx%20%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E3%80%81%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E5%92%8C%E7%BC%93%E5%AD%98%E7%9A%84%E5%AE%9E%E7%8E%B0.assets/1216496-20171112174109872-951848876.png)

缓存目录也生成了缓存

![img](nginx%20%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E3%80%81%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E5%92%8C%E7%BC%93%E5%AD%98%E7%9A%84%E5%AE%9E%E7%8E%B0.assets/1216496-20171112174110153-172114726.png)