# iptables 学习使用

------

## netfilter/iptables学习

### 1、链和表

表：filter：用于过滤的时候 nat：用于做nat的时候 链：INPUT:位于filter表，匹配目的IP是本机的数据包 FORWARD：位于filter表，匹配穿过本机的数据包 PREROUTING：位于nat表，用于修改目的地址（DNAT） POSTROUTING：位于nat表，用于修改源地址（SNAT）

### 2、iptables语法结构

> iptables [-t 要操作的表] <操作命令> [要操作的链] [规则号码] [匹配条件] [-j 匹配到以后的动作]

操作命令：（-A -I -D -R -P -F） 查看命令：（-[vxn]L）

- -A <链名>：APPEND，追加一条规则。

    `如：iptables -t filter -A INPUT -j DROP 在filter表的INPUT链中，匹配所有访问本机IP的数据包，匹配到的丢弃。`

- -I <链名> [规则号码]：INSERT，插入一条规则

    `如：iptables -I INPUT 3 -j DROP 在filter表的INPUT链中插入一条规则，插入成第三条。 -t filter可不写，默认是filter表`

- -D <链名> <规则号码|具体规则内容>:DELETE,删除一条规则。

    `如：iptables -D INPUT 3 删除filter表INPUT链中第三条规则，不管是啥东东。` `iptables -D INPUT -s 192.168.0.1 -j DROP 删除filter表INPUT链中匹配“-s 192.168.0.1 -j DROP”规则，不论位置。`

- -R <链名> <规则号码> <具体规则内容>:REPLACE,替换一条规则

    `如：iptables -R INPUT 3 -j ACCEPT 替换filter表中INPUT链的第三条规则内容替换为"-j ACCEPT"`

- -P <链名> <动作>：POLICY,设置某个链的默认规则。

    `如：iptables -P INPUT DROP 设置filter表IPUT链的默认规则为DROP，当数据包未被规则列表中的任何规则匹配到时，按此默认规则处理。*：此处是唯一的匹配动作前不加-j的情况。`

- -F [链名]：FLUSH，清空规则 `如：iptables -F INPUT 清空filter表INPUT链的所有规则。` `iptables -t nat -F PREROUTING 清空nat表PREROUTING链中所有的规则。在设置了默认规则DROP后，使用-F一定要小心。`

- -L [链名]：LIST，列出规则。

```bash
v：显示详细信息，包括每条规则的匹配包数量和匹配字节数。
x:在v的基础上，禁止自动单位换算。（K,M）
n:只显示IP地址和端口号码，不显示域名和服务名称。
如：iptables -L   粗略列出filter表所有链及所有规则。
iptables -t nat -vnL  用详细方式列出nat表的所有链和规则，只显示IP地址和端口号
iptables -t nat -vxnL PREROUTING     用详细方式列出nat表的PREROUTING链的所有规则及详细数字，不反解。
```

## 3、匹配条件

- 流入、流出接口（-i,-o）
- 来源、目的地址(-s,-d)
- 协议类型(-p)
- 来源、目的端口(--sport,--dport)

### (1)、按网络接口匹配

```bash
    如：-i eth0    匹配是否从网络接口eth0进来
    -o eth0    匹配是否从网络接口eht0出去
```

### (2)、 匹配来源地址: -s [匹配来源地址] 来源地址可以是IP，net，domain,也可以为空

```bash
如：-s 192.168.0.1    匹配来自192.168.0.1的数据包。
    -s 192.168.1.0/24 匹配来自192.168.1.0/24网络的数据包。
    -s www.abc.com    匹配来自域名www.abc.com网络的数据包。
 -d [匹配目的地址]  目的地址可以使IP,NET,domain，也可以为空。
如：-d 202.131.78.220  匹配去往202.131.78.220的数据包。
    -d 202.131.0.0/16  匹配去往202.131.0.0/16网络的数据包。
    -d www.abc.com     匹配去往域名www.abc.com的数据包。
```



### (3)、按协议类型匹配

```bash
-p <匹配协议类型>  协议类型可以是tcp,udp,icmp等，也可以为空。
如：-p tcp
    -p udp
    -p icmp --icmp-type 类型
```

### (4)、按来源目的端口匹配。

```bash
 --sport <匹配源端口>    源端口可以是个别端口，也可以是端口范围。
如：--sport 1000        匹配源端口是1000的数据包。
    --sport 1000:3000   匹配源端口是1000-3000的数据包（含1000,3000）
    --sport :3000       匹配源端口是3000以下的数据包（含3000）
    --sport 1000:       匹配源端口是1000以上的数据包（含1000）
 --dport <匹配目的端口>   目的端口可以是个别端口，也可以是端口范围。
如：--dport 80           匹配目的端口是80的数据包
    --dport 6000:8000    匹配目的端口是6000-8000的数据包（包含6000-8000）
    --dport :3000        匹配目的端口是3000以下的数据包（含3000）
    --dport 1000:        匹配目的端口是1000以上的数据包（含1000）
注：--sport 和 --dport必须配合-p参数使用。
```



> 匹配应用举例：

```bash
-p udp --dport 53           匹配网络中目的端口是53的udp协议数据包
-s 10.1.0.0/24 -d 172.17.0.0/16      匹配来自10.1.0.0/24去往172.17.0.0/16的所有数据包
-s 192.168.0.1 -d www.abc.com -p tcp --dport 80     匹配来自192.168.0.1，去往www.abc.com的80端口的tcp协议数据包。
条件越多，匹配越细致，匹配范围越小。
```

## 4、动作

```bash
ACCEPT
DROP
SNAT
DNAT
MASQUERADE
```



- -j ACCEPT 通过，允许数据包通过本链而不拦截它。

```
如：iptables -A INPUT -j ACCEPT 允许所有访问本机的IP数据包通过。类似cisco中ACL里面的permit
```

- -j DROP 丢弃，阻止数据包通过本链而丢弃它。类似cisco中ACL里面的deny

```
如：iptables -A FORWARD -s 192.168.80.39 -j DROP 阻止来源地址为192.168.80.39的数据包通过本机。
```

- -j DNAT --to IP[-IP][:端口-端口] （nat表的PREROUTING链） 目的地址转换。DNAT支持转换为单IP，也支持转换到IP地址池（一组连续的IP地址）

```bash
如：iptables -t nat -A PREROUTING -i ppp0 -p tcp --dport 80 -j DNAT --to 192.168.0.1    把从ppp0进来的药访问tcp/80的数据包目的地址转为192.168.0.1
    iptables -t nat -A PREROUTING -i ppp0 -p tcp --dport 81 -j DNAT --to 192.168.0.2:80
    iptables -t nat -A PREROUTING -i PPP0 -P tcp --dport 80 -j DNAT --to 192.168.0.1-192.168.0.10
```

- -j SNAT --to IP[-IP] [:端口-端口]（nat表中的POSTROUTING链） 源地址转换。SNAT支持转换为单IP，也支持转换到IP地址池（一组练习的IP地址）

```bash
如：iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to 1.1.1.1    将内网192.168.0.0、24的源地址改为1.1.1.1，用于nat
    iptables -t nat -A POSTROUTING -S 192.168.0.0/24 -J SNAT --TO 1.1.1.1-1.1.1.10
```

- -j MASQUERADE 动态源地址转换。（动态IP的情况下使用）

```bash
如：iptables -t nat -A POSTROUTING -S 192.168.0.0/24 -j MASQUEREADE    将源地址是192.168.0.0/24的数据包进行地址伪装。
```

## 5、附加模块

按包状态匹配。（state） 按来源mac匹配（mac） 按包速率匹配（limit） 多端口匹配（multiport）

### 1）、-m state --state 状态

```bash
    状态：NEW、RELATED、ESTABLISHED、INVALID
    NEW:有别于tcp的syn
    ESTABLISHED：连接态。
    RELATED：衍生态，与conntrack关联（ftp）
    INVALID:不能被识别属于哪个连接或没有任何状态。
    如：iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
```

### 2)、-m mac --mac-source MAC 匹配某个MAC地址

```bash
如：iptables -A FORWARD -m mac --mac-source xx:xx:xx:xx:xx:xx -j DROP    阻断来自某MAC地址的数据包通过本机。
  注：报文在经过路由后，数据包中原有的MAC信息会被替换，所以在路由后的iptables中使用mac模块是没有意义的。
```

### 3)、-m limit --limit 匹配速率 [--burst 缓冲数量] 用一定的速率去匹配数据包

```bash
如：iptables -A FORWARD -d 192.168.0.1 -m limit --limit 50m/s -j ACCEPT
    iptables -A FORWARD -d 192.168.0.1 -j DROP
注：limit英语上看是限制的意思，但实际上只是按一定速率去匹配，要想限制的话后面要再跟一条DROP
```

### 4)、multiport

```bash
-m multiport <--sports|--dports|--ports> 端口1[，端口2,..,端口n]  一次性匹配多个端口，可以匹分源端口，目的端口或不指定端口。
如:iptables -A INPUT -P tcp -m multiport --dports 21,22,25,80,110 -j ACCEPT   匹配到达本机端口的21,22,25,80,110的数据包通过。 必须于-p参数一起使用。
```
