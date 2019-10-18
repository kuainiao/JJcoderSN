# [项目实战5—企业级缓存系统varnish应用与实战](https://www.cnblogs.com/along21/p/7911628.html)

分类: [Linux架构篇](https://www.cnblogs.com/along21/category/1114615.html)

undefined

 

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E7%BC%93%E5%AD%98%E7%B3%BB%E7%BB%9Fvarnish%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98.assets/1216496-20171128191047425-1178771094.png)

企业级缓存系统varnish应用与实战

　　环境背景：随着公司业务快速发展，公司的电子商务平台已经聚集了很多的忠实粉丝，公司也拿到了投资，这时老板想通过一场类似双十一的活动，进行一场大的促销，届时会有非常多的粉丝访问网站，你的总监与市场部门开完会后，确定活动期间**会有平常10倍以上的访问请求**，总监要求大幅增加网站容量，除了去扩容服务器之外，还有没有其他办法呢？

**总项目流程图**，详见 http://www.cnblogs.com/along21/p/8000812.html

## 实现基于Keepalived+Haproxy+Varnish+LNMP企业级架构

原理：

缓存，又称加速器，用于加速运行速度较快的设备与较慢设备之间的通信。基于程序的运行具有局部性特征其能实现加速的功能

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E7%BC%93%E5%AD%98%E7%B3%BB%E7%BB%9Fvarnish%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98.assets/1216496-20171128191048003-1828441849.png)

 

### 1、环境准备

 

| 机器名称              | IP配置                               | 服务角色           | 备注           |
| --------------------- | ------------------------------------ | ------------------ | -------------- |
| haproxy-server-master | VIP：172.17.100.100DIP：172.17.1.6   | 负载均衡器主服务器 | 配置keepalived |
| haproxy-server-backup | VIP：172.17.100.100DIP：172.17.11.11 | 负载服务器从服务器 | 配置keepalived |
| varnish               | RIP：192.168.30.2                    | 缓存服务器         | 开启代理功能   |
| rs01                  | RIP：192.168.30.107                  | 后端服务器         | 开启lnmp的web  |
| rs02                  | RIP：192.168.30.7                    | 后端服务器         | 开启lnmp的web  |

### 2、在两个 haproxy上设置

全局段和默认段不用修改，就不写了

vim /etc/haproxy/haproxy.cfg

```
vim /etc/haproxy/haproxy.cfg
① frontend 前端设置
frontend  web
        bind :80        acl staticfile path_end .jpg .png .bmp .htm .html .css .js        use_backend varnish-server if staticfile        default_backend appsrvs
② backend 后端设置
backend varnish-server
        balance     roundrobin
        server varnishsrv 192.168.30.2:6081 check inter 3000 rise 3 fall 3backend appsrvs        balance     roundrobin        server appsrv1 192.168.30.107:80 check inter 3000 rise 3 fall 3        server appsrv2 192.168.30.7:80 check inter 3000 rise 3 fall 3
③ 可以加个web状态监测页面，可要可不要
listen admin
bind  :9527
stats enable
stats hide-version
stats uri /haproxy?admin
stats realm  HAProxy\ Statistics
stats auth along:along
stats refresh 20s
stats admin if TRUE
```

### 3、设置keepalived

（1）在**主haproxy-master** 上

```
① 全局段，主要是设置发邮件的
global_defs {
   notification_email {
        root@localhost
   }
   notification_email_from root@along.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id keepalived_haproxy
}
② 编辑一个健康监测脚本，每2秒监测一次haproxy进程
vrrp_script chk_haproxy {
        script "killall -0 haproxy"
        interval 2
        fall 2
        rise 2
        weight -4
}
③ 定义主从和VIP
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 191
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass along
    }
    virtual_ipaddress {
        172.17.100.100
    }
track_script {     //调用上边的脚本
chk_haproxy
}
}
```

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E7%BC%93%E5%AD%98%E7%B3%BB%E7%BB%9Fvarnish%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98.assets/1216496-20171128191048550-739209586.png)

 

（2）在**从haproxy-backup** 上，和主差不多，只需修改主从和优先级

```
vrrp_instance VI_1 {
    state BACKUP
    interface eth1
    virtual_router_id 191
    priority 98
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass along
    }
    virtual_ipaddress {
        172.17.100.100
    }
}
```

### 4、设置varnish

（1）设置配置，管理Management进程的配置文件，配置进程的

vim /etc/varnish/**varnish.params** 修改端口和缓存类型及缓存大小

VARNISH_ADMIN_LISTEN_PORT=**6082**

VARNISH_STORAGE=**"file,/data/cache,1G"**

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E7%BC%93%E5%AD%98%E7%B3%BB%E7%BB%9Fvarnish%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98.assets/1216496-20171128191048847-790505094.png)

 

（2）设置总配置文件，配置缓存系统的

vim /etc/varnish/**default.vcl**

（a）第一段

```
① 设置一个健康监测
vcl 4.0;   //指定版本
import directors;   //加载后端的轮询模块
probe backend_healthcheck {   //设置名为backend_healthcheck的健康监测
    .url = "/index.html";
    .window = 5;      #窗口
    .threshold = 2;   #门槛
    .interval = 3s;
    .timeout  = 1s;
}

② 设置后端server
backend web1 { 
    .host = "192.168.30.107";
    .port = "80";
    .probe = backend_healthcheck;
}
backend web2 {
    .host = "192.168.30.7";
    .port = "80";
    .probe = backend_healthcheck;
}

③ 配置后端集群事件
sub vcl_init {
    new web_cluster = directors.round_robin();   //把web1和web2 配置为轮询集群，取名为web_cluste
    web_cluster.add_backend(web1);
    web_cluster.add_backend(web2);
}
acl purgers {    # 定义可访问来源IP，权限控制
        "127.0.0.1";
        "172.17.0.0"/16;
}
```

（b）第二段，定义引擎

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E7%BC%93%E5%AD%98%E7%B3%BB%E7%BB%9Fvarnish%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98.assets/1216496-20171128191049659-47629522.png)

```
① 定义vcl_recv 引擎，不认识的头部请求直接扔后端的pass
sub vcl_recv {
    if (req.method == "GET" && req.http.cookie) {
        return(hash);    //处理完recv 引擎，给下一个hash引擎处理
}
   if (req.method != "GET" &&
   req.method != "HEAD" &&
   req.method != "PUT" &&
   req.method != "POST" &&
   req.method != "TRACE" &&
   req.method != "OPTIONS" &&
   req.method != "PURGE" &&
   req.method != "DELETE") {
    return (pipe);   //除了上边的请求头部，通过通道直接扔后端的pass
   }
② 定义index.php通过特殊通道给后端的server，不经过缓存
    if (req.url ~ "index.php") {
        return(pass);
    }
③ 定义删除缓存的方法
    if (req.method == "PURGE") {     # PURGE请求的处理的头部，清缓存
        if (client.ip ~ purgers) {
          return(purge);
        }
    }
④ 为发往后端主机的请求添加X-Forward-For首部
    if (req.http.X-Forward-For) {    # 为发往后端主机的请求添加X-Forward-For首部
        set req.http.X-Forward-For = req.http.X-Forward-For + "," + client.ip;
    } else {
        set req.http.X-Forward-For = client.ip;
    }
        return(hash);
}

⑤ 定义vcl_hash 引擎，后没有定义hit和Miss的路径，所以走默认路径
sub vcl_hash {
     hash_data(req.url);
}

⑥ 定义要缓存的文件时长
sub vcl_backend_response {     # 自定义缓存文件的缓存时长，即TTL值
    if (bereq.url ~ "\.(jpg|jpeg|gif|png)$") {
        set beresp.ttl = 30d;
    }
    if (bereq.url ~ "\.(html|css|js)$") {
        set beresp.ttl = 7d;
    }
    if (beresp.http.Set-Cookie) { # 定义带Set-Cookie首部的后端响应不缓存，直接返回给客户端
    set beresp.grace = 30m;  
        return(deliver);
    }
}

⑦ 定义deliver 引擎
sub vcl_deliver {
    if (obj.hits > 0) {    # 为响应添加X-Cache首部，显示缓存是否命中
        set resp.http.X-Cache = "HIT from " + server.ip;
    } else {
        set resp.http.X-Cache = "MISS";
    }
        unset resp.http.X-Powered-By;   //取消显示php框架版本的header头
        unset resp.http.Via;   //取消显示varnish的header头
}
```

### 5、开启服务的顺序

① 先开启后端server事先搭建好的lnmp web服务

systemctl start nginx

systemctl start php-fpm

systemctl start mariadb

 

② 再开启varnish缓存服务器

service varnish start

 

③ 开启主从的keepalived，提供VIP

service keepalived start

 

④ 开启haproxy服务

service haproxy start

 

### 6、测试

（1）配置完成后，client访问，http://172.17.100.100/ ，成功访问web

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E7%BC%93%E5%AD%98%E7%B3%BB%E7%BB%9Fvarnish%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98.assets/1216496-20171128191050440-1541598355.png)

 

（2）访问http://172.17.100.100:9527/haproxy?admin ，haproxy的web监测页面，正常

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E7%BC%93%E5%AD%98%E7%B3%BB%E7%BB%9Fvarnish%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98.assets/1216496-20171128191051175-848918667.png)

 

（3）当主haproxy 宕机时，VIP自动漂移到从上，且服务正常使用

在主haproxy 上，server stop haproxy，VIP会漂到从上

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E7%BC%93%E5%AD%98%E7%B3%BB%E7%BB%9Fvarnish%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98.assets/1216496-20171128191052019-807292753.png)

（4）varnish 缓存服务器上，确实生成了**缓存文件**

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E7%BC%93%E5%AD%98%E7%B3%BB%E7%BB%9Fvarnish%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98.assets/1216496-20171128191052315-1155469426.png)

**F12**打开网页的调试页面，查看确实缓存了

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E7%BC%93%E5%AD%98%E7%B3%BB%E7%BB%9Fvarnish%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98.assets/1216496-20171128191052815-482004908.png)

 

（5）测试清缓存的功能，PURGE 发送头部信息

![img](%E4%BC%81%E4%B8%9A%E7%BA%A7%E7%BC%93%E5%AD%98%E7%B3%BB%E7%BB%9Fvarnish%E5%BA%94%E7%94%A8%E4%B8%8E%E5%AE%9E%E6%88%98.assets/1216496-20171128191053284-708231931.png)

 

（6）后端有一台server 宕机，服务照常使用

systemctl stop nginx