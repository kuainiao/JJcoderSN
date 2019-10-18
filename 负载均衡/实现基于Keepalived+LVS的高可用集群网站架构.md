# 实现基于Keepalived+LVS的高可用集群网站架构

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214311546-737181195.png)

实现基于Keepalived高可用集群网站架构

　　环境：随着业务的发展，网站的访问量越来越大，网站访问量已经从原来的1000QPS，变为3000QPS，目前业务已经通过集群LVS架构可做到随时拓展，后端节点已经通过集群技术保障了可用性，但对于前端负载均衡器来说，是个比较大的安全隐患，因为当前端负载均衡器出现故障时，整个集群就处于瘫痪状态，因此，负载均衡器的可用性也显得至关重要，那么怎么来解决负载均衡器的可用性问题呢？

 **总项目流程图**，详见 http://www.cnblogs.com/along21/p/8000812.html

[**实验前准备**](http://www.cnblogs.com/along21/p/8000812.html)：

① 两台服务器都使用yum 方式安装keepalived 服务

yum -y install keepalived

② iptables -F && setenforing 清空防火墙策略，关闭selinux

 

## 实验一：实现keepalived主从方式高可用基于LVS-DR模式的应用实战：

**实验原理：**

主从：**一主一从**，主的在工作，从的在休息；主的宕机了，**VIP漂移**到从上，由从提供服务

### 1、环境准备：

两台centos系统做DR、一主一从，两台实现过基于LNMP的电子商务网站

| 机器名称          | IP配置                               | 服务角色           | 备注                       |
| ----------------- | ------------------------------------ | ------------------ | -------------------------- |
| lvs-server-master | VIP：172.17.100.100DIP：172.17.1.6   | 负载均衡器主服务器 | 开启路由功能配置keepalived |
| lvs-server-backup | VIP：172.17.100.100DIP：172.17.11.11 | 后端服务器从服务器 | 开启路由功能配置keepalived |
| rs01              | RIP：172.17.1.7                      | 后端服务器         |                            |
| rs02              | RIP：172.17.22.22                    | 后端服务器         |                            |

 

### 2、在lvs-server-master 主上

修改keepalived主(lvs-server-master)配置文件实现 virtual_instance 实例

（1）vim /etc/keepalived/keepalived.conf 修改三段

```
① 全局段，故障通知邮件配置
global_defs {
   notification_email {
        root@localhost
   }
   notification_email_from root@along.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id keepalived_lvs
}

② 配置虚拟路由器的实例段，VI_1是自定义的实例名称，可以有多个实例段
vrrp_instance VI_1 {    　#VI_1是自定义的实例名称
    state MASTER   　　 　 #初始状态，MASTER|BACKUP
    interface eth1 　　 　 #通告选举所用端口
    virtual_router_id 51  #虚拟路由的ID号（一般不可大于255）
    priority 100  　　　　　#优先级信息 #备节点必须更低
    advert_int 1  　　　　　#VRRP通告间隔，秒
    authentication {
        auth_type PASS    #认证机制
        auth_pass along   #密码（尽量使用随机）
    } 
    virtual_ipaddress {
        172.17.100.100   　#vip
    }
}

③ 设置一个virtual server段
virtual_server 172.17.100.100 80 {   #设置一个virtual server:
    delay_loop 6   # service polling的delay时间，即服务轮询的时间间隔
    lb_algo wrr　　　 #LVS调度算法：rr|wrr|lc|wlc|lblc|sh|dh
    lb_kind DR　　　　#LVS集群模式：NAT|DR|TUN
    nat_mask 255.255.255.255  
    persistence_timeout 600  #会话保持时间（持久连接，秒），即以用户在600秒内被分配到同一个后端realserver
    protocol TCP   　#健康检查用的是TCP还是UDP
④ real server设置段
    real_server 172.17.1.7 80 { #后端真实节点主机的权重等设置
        weight 1  #给每台的权重，rr无效
        HTTP_GET {  #http服务
            url {
              path /
            }
            connect_timeout 3    #连接超时时间
            nb_get_retry 3　　    #重连次数
            delay_before_retry 3 #重连间隔
        }
    }
    real_server 172.17.22.22 80 {
        weight 2
        HTTP_GET {
            url {
              path /
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
}
```

 

（2）开启keepalived 服务

service keepalived start

能看到网卡别名 和 负载均衡策略已经设置好了

ipvsadm -Ln

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214154687-1361513086.png)

 

（3）因为是主从方式，所以从上的配置和主只有一点差别；所以可以把这个配置文件拷过去

scp /etc/keepalived/keepalived.conf @172.17.11.11:

 

### 3、在lvs-server-backup 从上

（1）只需改②实例段，其他都不要变，保证一模一样

```
vrrp_instance VI_1 {
    state BACKUP
    interface eth1
    virtual_router_id 51
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass along
    }
```

 

（2）开启keepalived 服务

service keepalived start

负载均衡策略已经设置好了，注意：主director没有宕机，从上就不会有VIP

ipvsadm -Ln 可能过一会才会显示

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214155062-838809619.png)

 

### 4、在real server 上

（1） 开启事前准备好的web服务

systemctl start nginx

systemctl start mariadb

systemctl start php-fpm

 

（2）因为是DR模式，需在rs上设置

① 配置VIP到本地回环网卡lo上，并只广播自己

ifconfig lo:0 172.17.100.100 broadcast 172.17.100.100 netmask 255.255.255.255 up

配置本地回环网卡路由

route add -host 172.17.100.100 lo:0

 

② 使RS "闭嘴"

echo "1" > /proc/sys/net/ipv4/conf/lo/arp_ignore

echo "2" > /proc/sys/net/ipv4/conf/lo/arp_announce

忽略ARP广播

echo "1" > /proc/sys/net/ipv4/conf/all/arp_ignore

echo "2" > /proc/sys/net/ipv4/conf/all/arp_announce

注意：关闭arp应答

1：仅在请求的目标IP配置在本地主机的接收到请求报文的接口上时，才给予响应

2：必须避免将接口信息向非本网络进行通告

 

③ 想永久生效，可以写到配置文件中

vim /etc/sysctl.conf

```
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
```

 

### 5、测试

（1）lvs负载均衡作用是否开启

客户端访问http://172.17.100.100/

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214155265-1334400819.png)

也可以详细测试

① 在rs1 上设置一个测试一面

vim /data/web/test.html

real server 1

 

② 在rs2 上设置一个测试一面

vim /data/web/test.html

real server 2

 

③ 网页访问http://172.17.100.100/test.html 发现有real server 1也有real server 2

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214155437-1961623314.png)

 

（2）测试keepalived的主从方式

① 使keepalive 的主宕机

service keepalived stop

 

会发现服务能照常访问，但是VIP 漂移到了从上

从多了网卡别名，且地址是VIP

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214155671-1882452500.png)

 

③ 使keepalive 的主重新开启服务，因为主的优先级高，所以VIP又重新漂移到了主上

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214155890-1550957797.png)

 

## 实验二：实现keepalived双主方式高可用基于LVS-DR模式的应用实战：

**实验原理：**

互为主从：主从都在工作；其中一个宕机了，**VIP漂移**到另一个上，提供服务

### 1、实验环境，基本同上

| 机器名称     | IP配置                               | 服务角色           | 备注                       |
| ------------ | ------------------------------------ | ------------------ | -------------------------- |
| lvs-server-1 | VIP：172.17.100.100DIP：172.17.1.6   | 负载均衡器主服务器 | 开启路由功能配置keepalived |
| lvs-server2  | VIP：172.17.100.101DIP：172.17.11.11 | 后端服务器从服务器 | 开启路由功能配置keepalived |
| rs01         | RIP：172.17.1.7                      | 后端服务器         |                            |
| rs02         | RIP：172.17.22.22                    | 后端服务器         |                            |

 

### 2、在lvs-server1 上，基本同上，就是加了一个实例段

修改keepalived主(lvs-server-master)配置文件实现 virtual_instance 实例

（1）vim /etc/keepalived/keepalived.conf

```
① 主的设置 VI_1
vrrp_instance VI_1 {
    state MASTER
    interface eth1
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass along
    }
    virtual_ipaddress {
        172.17.100.100
    }
}

virtual_server 172.17.100.100 80 {
    delay_loop 6
    lb_algo wrr
    lb_kind DR
    nat_mask 255.255.255.255
    persistence_timeout 600
    protocol TCP

    real_server 172.17.1.7 80 {
        weight 1
        HTTP_GET {
            url {
              path /
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
    real_server 172.17.22.22 80 {
        weight 1
        HTTP_GET {
            url {
              path /
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
}
```

 

② 从的设置 VI_2

```
vrrp_instance VI_2 {
    state BACKUP
    interface eth1
    virtual_router_id 52
    priority 98
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass along
    }
    virtual_ipaddress {
        172.17.100.101
    }
}

virtual_server 172.17.100.101 443 {
    delay_loop 6
    lb_algo wrr
    lb_kind DR
    nat_mask 255.255.255.255
    persistence_timeout 600
    protocol TCP

    real_server 172.17.1.7 443 {
        weight 1
        HTTP_GET {
            url {
              path /
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
    real_server 172.17.22.22 443 {
        weight 1
        HTTP_GET {
            url {
              path /
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
}
```

 

（2）开启keepalived 服务

service keepalived start

能看到网卡别名 和 负载均衡策略已经设置好了

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214156140-369835645.png)

ipvsadm -Ln

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214156374-980990524.png)

 

（3）因为是主从方式，所以从上的配置和主只有一点差别；所以可以把这个配置文件拷过去

scp /etc/keepalived/keepalived.conf @172.17.11.11:

 

### 3、在lvs-server2 上，基本同1，就是把实例的主从调换一下

（1）vim /etc/keepalived/keepalived.conf

```
① vrrp_instance VI_1 {
    state BACKUP
    interface eth1
    virtual_router_id 51
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
② vrrp_instance VI_2 {
    state MASTER
    interface eth1
    virtual_router_id 52
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass along
    }
    virtual_ipaddress {
        172.17.100.101
    }
}
```

 

（2）开启keepalived 服务

service keepalived start

能看到网卡别名 和 负载均衡策略已经设置好了，显示结果会等段时间再显示

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214156687-1609218278.png)

ipvsadm -Ln，显示结果会等段时间再显示

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214156921-1675451078.png)

 

### 4、在real server 上

（1） 开启事前准备好的web服务

systemctl start nginx

systemctl start mariadb

systemctl start php-fpm

 

（2）因为是DR模式，需在rs上设置

① 配置VIP到本地回环网卡lo上，并只广播自己

ifconfig lo:0 172.17.100.100 broadcast 172.17.100.100 netmask 255.255.255.255 up

ifconfig lo:1 172.17.100.101 broadcast 172.17.100.101 netmask 255.255.255.255 up

配置本地回环网卡路由

route add -host 172.17.100.100 lo:0

route add -host 172.17.100.101 lo:1

 

② 使RS "闭嘴"

echo "1" > /proc/sys/net/ipv4/conf/lo/arp_ignore

echo "2" > /proc/sys/net/ipv4/conf/lo/arp_announce

忽略ARP广播

echo "1" > /proc/sys/net/ipv4/conf/all/arp_ignore

echo "2" > /proc/sys/net/ipv4/conf/all/arp_announce

注意：关闭arp应答

1：仅在请求的目标IP配置在本地主机的接收到请求报文的接口上时，才给予响应

2：必须避免将接口信息向非本网络进行通告

 

③ 想永久生效，可以写到配置文件中

vim /etc/sysctl.conf

net.ipv4.conf.lo.arp_ignore = 1

net.ipv4.conf.lo.arp_announce = 2

net.ipv4.conf.all.arp_ignore = 1

net.ipv4.conf.all.arp_announce = 2

 

### 5、测试

（1）lvs负载均衡作用是否开启

客户端访问http://172.17.100.100/ 公网172.17.100.100只能访问80

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214157343-622251192.png)

https://172.17.100.101/ 公网172.17.100.101只能访问443

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214157609-260247208.png)

也可以详细测试

① 在rs1 上设置一个测试一面

vim /data/web/test.html

real server 1

 

② 在rs2 上设置一个测试一面

vim /data/web/test.html

real server 2

 

③ 网页访问http://172.17.100.100/test.html或https://172.17.100.101/test.html 发现有real server 1也有real server 2

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214157921-379810821.png)

 

（2）测试keepalived的双主方式

① 使keepalive 的任意一个宕机

service keepalived stop

 

会发现服务能照常访问，另一个机器80、443都能访问，且宕机的VIP漂移到了另一个服务器上

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214158234-421935231.png)

 

## 实验三：实现keepalived主从方式高可用基于LVS-NAT模式的应用实战：

实验原理：

主从：**一主一从**，主的在工作，从的在休息；主的宕机了，**VIP和DIP都漂移**到从上，由从提供服务，因为DIP需被rs作为网关，所以也需漂移

### 1、环境准备

| 机器名称          | IP配置                                 | 服务角色           | 备注                       |
| ----------------- | -------------------------------------- | ------------------ | -------------------------- |
| vs-server-master  | VIP：172.17.100.100DIP：192.168.30.100 | 负载均衡器主服务器 | 开启路由功能配置keepalived |
| lvs-server-backup | VIP：172.17.100.100DIP：192.168.30.100 | 后端服务器从服务器 | 开启路由功能配置keepalived |
| rs01              | RIP：192.168.30.107                    | 后端服务器         | 网关指向DIP                |
| rs02              | RIP：192.168.30.7                      | 后端服务器         | 网关指向DIP                |

注意：要确保rs和DIP在一个网段，且不和VIP在一个网段

 

### 2、在lvs-server-master 主上

（1）vim keepalived.conf

```
global_defs {
   notification_email {
        root@localhost
   }
   notification_email_from root@along.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id keepalived_lvs
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass along
    }
    virtual_ipaddress {
       172.17.100.100
192.168.30.100
    }
}

virtual_server 172.17.100.100 80 {
    delay_loop 6
    lb_algo wrr
    lb_kind NAT
    nat_mask 255.255.255.255
    persistence_timeout 100
    protocol TCP

    real_server 192.168.30.107 80 {
        weight 1
        HTTP_GET {
            url {
              path /
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }

    real_server 192.168.30.7 80 {
        weight 2
        HTTP_GET {
            url {
              path /
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
}
```

 

（2）因为是NAT模式，所以需开启路由转发功能

vim /etc/sysctl.conf

net.ipv4.ip_forward = 1

 

sysctl -p 读一些，使参数生效

 

（3）开启keepalived 服务

service keepalived start

能看到网卡别名 和 负载均衡策略已经设置好了

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214158593-1052358672.png)

ipvsadm -Ln

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214158812-1804917355.png)

 

（4）因为是主从方式，所以从上的配置和主只有一点差别；所以可以把这个配置文件拷过去

scp /etc/keepalived/keepalived.conf @172.17.11.11:

 

**3、在lvs-server-backup 从上**

（1）只需改②实例段，其他都不要变，保证一模一样

```
vrrp_instance VI_1 {
    state BACKUP
    interface eth1
    virtual_router_id 51
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass along
    }
```

 

 

（2）因为是NAT模式，所以需开启路由转发功能

① vim /etc/sysctl.conf

net.ipv4.ip_forward = 1

② sysctl -p 读一些，使参数生效

 

（3）开启keepalived 服务

service keepalived start

负载均衡策略已经设置好了，注意：主director没有宕机，从上就不会有VIP

ipvsadm -Ln 可能过一会才会显示

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214159062-1171768335.png)

 

### 4、在real server 上

（1） 开启事前准备好的web服务

systemctl start nginx

systemctl start mariadb

systemctl start php-fpm

 

（2）因为是NAT模式，需在rs上设置

只需把网关指向DIP

route add default gw 192.168.30.100

 

### 5、测试

（1）lvs负载均衡作用是否开启

客户端访问http://172.17.100.100/

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214159359-1795880319.png)

也可以详细测试

① 在rs1 上设置一个测试一面

vim /data/web/test.html

real server 1

 

② 在rs2 上设置一个测试一面

vim /data/web/test.html

real server 2

 

③ 网页访问http://172.17.100.100/test.html 发现有real server 1也有real server 2

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214159515-1422112596.png)

 

 

（2）**测试keepalived的主从方式**

① 使keepalive 的主宕机

service keepalived stop

 

会发现服务能照常访问，但是VIP 和DIP 都漂移到了从上

从多了网卡别名，且地址是VIP

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214159781-187136452.png)

 

③ 使keepalive 的主重新开启服务，因为主的优先级高，所以VIP和DIP又重新漂移到了主上

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214200140-1019197265.png)

 

## 实验四：实现keeaplived 故障通知机制

### 1、编写好脚本

脚本主要内容：检测到主从发生变化，或错误，给谁发邮件；邮件内容是：在什么时间，谁发生了什么变化

vim /etc/keepalived/notify.sh

```
#!/bin/bash
# Author: www.magedu.com
contact='root@localhost'
notify() {
        mailsubject="$(hostname) to be $1: vip floating"
        mailbody="$(date +'%F %H:%M:%S'): vrrp transition, $(hostname) changed to be $1"
        echo $mailbody | mail -s "$mailsubject" $contact
}
case $1 in
master) 
        notify master
        exit 0
;;
backup)
        notify backup
        exit 0
;;
fault)
        notify fault
        exit 0
;;
*)
        echo "Usage: $(basename $0) {master|backup|fault}"
        exit 1
;;
esac
```

脚本加权限 chmod +x /etc/keepalived/notify.sh

 

### 2、在keepalived 的配置文件调用脚本

在instance 实例段添加，注意脚本的路径

```
notify_backup "/etc/keepalived/notify.sh backup"
notify_master "/etc/keepalived/notify.sh master"
notify_fault "/etc/keepalived/notify.sh fault"
```

例：

![img](%E5%AE%9E%E7%8E%B0%E5%9F%BA%E4%BA%8EKeepalived+LVS%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E7%BD%91%E7%AB%99%E6%9E%B6%E6%9E%84.assets/1216496-20171115214200624-1489846263.png)

 

## 实验五：实现keepaplived自定义脚本检测功能

原理：在keepalived的配置文件中能直接定义脚本，且能在instance 实例段直接调用生效

 

### 方案一：检测是否存在down文件，来实现主从的调整

1、在实例段上边定义一个脚本

vim keepalived.conf



```
vrrp_script chk_down {    #定义一个脚本，脚本名称为chk_down
 　　script "[[ -f /etc/keepalived/down ]] && exit 1 || exit 0"   #检查这个down文件，若存在返回值为1，keepalived会停止；不存在返回值为0，服务正常运行；这里的exit和bash脚本里的return很相似
 interval 2   #每2秒检查一次}
```



2、在instance 实例段可以直接调用这个脚本

```
track_script {
    chk_down
}
```

 

3、检测

在主上，创建一个/etc/keepalived/down 文件，主的keepalived服务立刻停止，VIP漂到从上，从接上服务；

down文件一旦删除，主的keepalived服务会立即启动，若优先级高或优先级低但设置的抢占，VIP会重漂回来，接上服务。

 

### 方案二：检测nginx服务是否开启，来实现调整主从

1、在实例段上边定义一个脚本

```
vrrp_script chk_nginx {
     script "killall -0 nginx" #killall -0 检测这个进程是否还活着，不存在就减权重
     interval 2 #每2秒检查一次
     fall 2 #失败2次就打上ko的标记
     rise 2 #成功2次就打上ok的标记
     weight -4 #权重，优先级-4，若为ko
}
```

 

2、在instance 实例段可以直接调用这个脚本

```
track_script {
    chk_nginx
}
```

 

3、检测

若主的nginx服务没有开启，则每2秒-4的权重，当优先级小于从，VIP漂到从上，从接上服务；

若主的nginx服务开启，重读配置文件，优先级恢复，VIP回到主上，主恢复服务；