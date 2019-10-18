# iptables 限制IP

------



## iptables利用connlimit模块限制同一IP连接connlimit功能

- connlimit模块允许你限制每个客户端IP的并发连接数，即每个IP同时连接到一个服务器个数。
- connlimit模块主要可以限制内网用户的网络使用，对服务器而言则可以限制每个IP发起的连接数。

connlimit参数

- --connlimit-above n 　　　＃限制为多少个
- --connlimit-mask n 　　　 ＃这组主机的掩码,默认是connlimit-mask 32 ,即每个IP.

## 例子

- 限制同一IP同时最多100个http连接

```
iptables -I INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 100 -j REJECT
```

- 只允许每组C类IP同时100个http连接

```
iptables -p tcp --syn --dport 80 -m connlimit --connlimit-above 100 --connlimit-mask 24 -j REJECT
```

- 只允许每个IP同时5个80端口转发,超过的丢弃

```
iptables -I FORWARD -p tcp --syn --dport 80 -m connlimit --connlimit-above 5 -j DROP
```

- 限制某IP最多同时100个http连接

```
iptables -A INPUT -s 222.222.222.222 -p tcp --syn --dport 80 -m connlimit --connlimit-above 100 -j REJECT
```

- 限制每IP在一定的时间(比如60秒)内允许新建立最多100个http连接数

```bash
iptables -A INPUT -p tcp --dport 80 -m recent --name BAD_HTTP_ACCESS --update --seconds 60 --hitcount 100 -j REJECT
iptables -A INPUT -p tcp --dport 80 -m recent --name BAD_HTTP_ACCESS --set -j ACCEPT
```