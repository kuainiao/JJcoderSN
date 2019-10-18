# [项目实战4—HAProxy实现高级负载均衡实战和ACL控制](https://www.cnblogs.com/along21/p/7873998.html)

分类: [Linux架构篇](https://www.cnblogs.com/along21/category/1114615.html)

undefined

 

![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171121164523977-1483487077.png)

 **haproxy实现高级负载均衡实战**

　　环境：随着公司业务的发展，公司负载均衡服务已经实现四层负载均衡，但业务的复杂程度提升，公司要求把mobile手机站点作为单独的服务提供，不在和pc站点一起提供服务，此时需要做7层规则负载均衡，运维总监要求，能否用一种服务同既能实现七层负载均衡，又能实现四层负载均衡，并且性能高效，配置管理容易，而且还是开源。

**总项目流程图**，详见 http://www.cnblogs.com/along21/p/8000812.html

***\*Haproxy详解和相关代码段含义详见，详见\**** http://www.cnblogs.com/along21/p/7899771.html

**实验前准备**：

① 两台服务器都使用yum 方式安装haproxy 和 keepalived 服务

yum -y install haproxy

yum -y install keepalived

② iptables -F && setenforing 清空防火墙策略，关闭selinux

 

## 实战一：实现基于Haproxy+Keepalived负载均衡高可用架构

### 1、环境准备：

| 机器名称              | IP配置                               | 服务角色           | 备注           |
| --------------------- | ------------------------------------ | ------------------ | -------------- |
| haproxy-server-master | VIP：172.17.100.100DIP：172.17.1.6   | 负载均衡器主服务器 | 配置keepalived |
| haproxy-server-backup | VIP：172.17.100.100DIP：172.17.11.11 | 负载服务器从服务器 | 配置keepalived |
| rs01                  | RIP：172.17.1.7                      | 后端服务器         |                |
| rs02                  | RIP：172.17.22.22                    | 后端服务器         |                |

 

### 2、先配置好keepalived的主从

（1）在**haproxy-server-master 上**：

vim /etc/keepalived/keepalived.conf

```
! Configuration File for keepalived
global_defs {
   notification_email {
        root@localhost
   }
   notification_email_from root@along.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id keepalived_haproxy
}

vrrp_script chk_haproxy {   #定义一个脚本，发现haproxy服务关闭就降优先级
        script "killall -0 haproxy"
        interval 2
        fall 2
        rise 2
        weight -4
}

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
track_script {   #执行脚本
chk_haproxy
}
}
```

service keepalived start 开启keepalived服务

开启服务后可以查看，VIP已经生成

![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171121164410196-131987557.png)

 

（2）在**haproxy-server-backup 从上**：只需把主换成从，优先级降低就好

vim /etc/keepalived/keepalived.conf

```
! Configuration File for keepalived
global_defs {
   notification_email {
        root@localhost
   }
   notification_email_from root@along.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id keepalived_haproxy
}


vrrp_instance VI_1 {
    state BACKUP
    interface eth0
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

 

service keepalived start 开启keepalived服务

 

**3、配置haproxy ，总共有两大段，和第二大段的4小段，两个haproxy可以配置的一样**

（1）第一大段：global 全局段

```
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     40000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats
```

（2）第二大段：proxies 对代理的设定

```
① defaults 默认参数设置段
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

② listen 段
listen stats
bind 0.0.0.0:1080
stats enable
stats hide-version
stats uri /haproxyadmin
stats auth along:along
stats admin if TRUE

③ frontend 与客户端建立连接，打开服务监听端口段
frontend  web
bind :80
default_backend         lnmp-server

④ backend 与后端服务器联系段
backend lnmp-server
    balance     roundrobin
    option      httpchk GET /index.html
    server  lnmpserver1 172.17.1.7:80 check inter 3000 rise 3 fall 5
    server  lnmpserver2 172.17.22.22:80 check inter 3000 rise 3 fall 5
```

 

开启服务 service haproxy start

 

### 4、在后端server·打开事先准备好的web server

systemctl start nginx

systemctl start php-fpm

systemctl start mariadb

 

### 5、测试

（1）网页访问 http://172.17.100.100:1080/haproxyadmin 进入状态监控页面，可以控制自己的后端服务

![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171121164411305-1577397550.png)

 

（2）可以坏2台不是一组的机器

一台后端server宕机，haproxy会调度到另一个server，继续提供服务

一个主的haproxy宕机，keepalived会把VIP漂移到从上，继续提供服务

![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171121164411774-795275222.png)

 

## 实战二：基于ACL控制实现动静分离

**原理：**acl：访问控制列表，用于实现**基于请求报文的首部**、**响应报文的内容**或**其它**的环境状态信息来做出转发决策，这大大增强了其配置弹性。其配置法则**通常分为两步**，首先去**定义ACL** ，即定义一个测试条件，而后**在条件得到满足时执行某特定的动作**，如阻止请求或转发至某特定的后端。

### 1、环境准备：

 

| 机器名称       | IP配置              | 服务角色   | 备注                  |
| -------------- | ------------------- | ---------- | --------------------- |
| haproxy-server | 172.17.2.7          | 负载均衡器 | 配置keepalivedACL控制 |
| rs01           | RIP：192.168.30.107 | 静态服务器 | 小米网页              |
| rs02           | RIP：192.168.30.7   | 动态服务器 | 小米网页              |

### 2、在haproxy 上定义ACL和后端服务器

vim /etc/haproxy/haproxy.cfg 前面global 全局段和default 段不用修改

```
① 定义web 监控页面
listen stats
bind 0.0.0.0:1080
stats enable
stats hide-version
stats uri /haproxyadmin
stats auth along:along
stats admin if TRUE

② 在frontend 段定义ACL
frontend web
        bind :80
        acl staticfile path_end .jpg .png .bmp .htm .html .css .js
        acl appfile path_end .php
        use_backend staticsrvs if staticfile
        default_backend appsrvs

③ 设置backend 后端集群组
backend staticsrvs
        balance roundrobin
        server staticweb 192.168.30.107:80 check inter 3000 rise 3 fall 3

backend appsrvs
        balance roundrobin
        server appweb 192.168.30.7:80 check inter 3000 rise 3 fall 3
```

 

### 3、开启后端web服务

systemctl start nginx

systemctl start php-fpm

systemctl start mariadb

 

### 4、测试结果

（1）后端服务器正常时

![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171126175708390-1296518357.png)

web 检测页面，一切正常

![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171126175708406-1336310229.png)

 

（2）当后端静态页面服务集群宕机，显示不出静态页面，说明动静分离成功

![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171126175708406-306036619.png) 

 

## 实战三：基于ACL实现权限控制及会话保持

### 1、环境准备：

 

| 机器名称       | IP配置              | 服务角色   | 备注                  |
| -------------- | ------------------- | ---------- | --------------------- |
| haproxy-server | 172.17.2.7          | 负载均衡器 | 配置keepalivedACL控制 |
| rs01           | RIP：192.168.30.107 | 后端服务器 | 小米网页              |
| rs02           | RIP：192.168.30.7   | 后端服务器 | 小米网页              |

### 2、这haproxy 上定义ACL和后端服务器

vim /etc/haproxy/haproxy.cfg 前面global 全局段和default 段不用修改

```
① 定义web 监控页面
listen stats
bind 0.0.0.0:1080
stats enable
stats hide-version
stats uri /haproxyadmin
stats auth along:along
stats admin if TRUE

② 在frontend 段定义ACL，用户权限控制
frontend web
        bind :80
        acl allow_src src 172.17.0.0/16
        block unless allow_src
        default_backend appsrvs

③ 设置backend 后端集群组，设置cookie，会话保持
backend staticsrvs
        balance roundrobin
        cookie SRV insert nocache
        server appweb1 192.168.30.107:80 check inter 3000 rise 3 fall 3 cookie srv1
        server appweb2 192.168.30.7:80 check inter 3000 rise 3 fall 3 cookie srv2
```

 

### 3、开启后端web服务

systemctl start nginx

systemctl start php-fpm

systemctl start mariadb

 

### 4、检测结果

（1）检测权限控制

① 在172.17.0.0 段的机器访问，正常

 ![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171126175857062-1580940980.png)

 ② 在这个网段外的机器访问，拒绝

 ![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171126175902640-1805701405.png)

 

（2）检测会话保持

① 分别在两个后端创建两个测试页面

vim ../test.html

server 1/2

② 测试

curl 测试需加-b SRV= 指定的对应cookie访问

curl -b SRV=srv1 172.17.2.7/test.html

curl -b SRV=srv2 172.17.2.7/test.html

 ![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171126175919781-524720281.png)

 

## 实战四：实现haproxy的ssl加密

### 1、自签生成证书

cd /etc/pki/tls/certs

make /etc/haproxy/haproxy.pem

![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171121164412368-342754740.png)

ls /etc/haproxy/haproxy.pem 确实生成了证书和秘钥的文件

 

### 2、在haproxy 中设置

```
frontend  web
        bind :80
        bind :443 ssl crt /etc/haproxy/haproxy.pem   监听443端口，且是ssl加密
        redirect scheme https if !{ ssl_fc }    实现302重定向，将80跳转到443端口
```

### 3、网页访问 https://172.17.11.11/

![img](HAProxy%E5%AE%9E%E7%8E%B0%E9%AB%98%E7%BA%A7%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%AE%9E%E6%88%98%E5%92%8CACL%E6%8E%A7%E5%88%B6.assets/1216496-20171121164412805-1836590846.png)