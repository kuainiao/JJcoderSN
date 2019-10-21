# DNS基础知识

# DNS 是什么

DNS (Domain Name System)， 也叫网域名称系统，是互联网的一项服务。它实质上是一个 **域名** 和 **IP** 相互映射的分布式数据库，有了它，我们就可以通过域名更方便的访问互联网。

DNS有以下特点:

- 分布式的
- 协议支持TCP 和 UDP, 常用端口是53
- 每一级域名的长度限制是63
- 域名总长度限制是253

**那么，什么情况下使用TCP，什么情况下使用UDP呢?**

最早的时候，DNS 的UDP报文上限大小是512 字节， 所以当某个response大小超过512 (返回信息太多)，DNS服务就会使用TCP协议来传输。后来DNS 协议扩展了自己的UDP协议，DNS client 发出查询请求时，可以指定自己能接收超过512字节的UDP包， 这种情况下，DNS 还是会使用UDP协议

## 分层的数据库结构

DNS 的结构跟Linux 文件系统很相似，像一棵倒立的树。 下面用站长之家的域名举例:



![img](Untitled.assets/3a7b7303790037d1379d2ac829127aa0)



最上面的.是根域名, 接着是顶级域名com，再下来是站长之家域名chinaz 依次类推。 使用域名时，从下而上。 s.tool.chinaz.com. 就是一个完整的域名, www.chinaz.com. 也是。

**之所以设计这样复杂的树形结构， 是为了防止名称冲突。** 这样一棵树结构，当然可以存储在一台机器上，但现实世界中完整的域名非常多，并且每天都在新增、删除大量的域名，存在一台机器上，对单机器的存储性能就是不小的挑战。 另外，集中管理还有一个缺点就是管理不够灵活。 可以想象一下，每次新增、删除域名都需要向中央数据库申请是多么麻烦。 所以**现实中的DNS 都是分布式存储的。**

根域名服务器只管理顶级域，同时把每个顶级域的管理委派给各个顶级域，所以当你想要申请com下的二级域名时，找com域名注册中心就好了。 例如你申请了上图的chinaz.com二级域名， chinaz.com 再向下的域名就归你管理了。 当你管理chinaz.com的子域名时，你可以搭建自己的nameserver, 在.com注册中心把chinaz.com的管理权委派给自己搭建的nameserver。 自建nameserver 和不自建的结构图如下:



![img](Untitled.assets/8bfc45c49feb40ec01409f53de41788b)



一般情况下，能不自建就不要自建，因为维护一个高可用的DNS也并非容易。据我所知，有两种情况需要搭建自己的nameserver:

1. **搭建对内的DNS。**公司内部机器众多，通过ip相互访问太过凌乱，这时可以搭建对内的nameserver，允许内部服务器通过域名互通
2. **公司对域名厂商提供的nameserver性能不满意。**虽然顶级域名注册商都有自己的nameserver, 但注册商提供的nameserver 并不专业，在性能和稳定性上无法满足企业需求，这时就需要企业搭建自己的高性能nameserver，比如增加智能解析功能，让不同地域的用户访问最近的IP，以此来提高服务质量

概括一下DNS的分布式管理， 当把一个域委派给一个nameserver后，这个域下的管理权都交由此nameserver处理。 这种设计一方面解决了存储压力，另一方面提高了域名管理的灵活性 (这种结构像极了Linux File System, 可以把任何一个子目录挂载到另一个磁盘，还可以把它下面的子目录继续挂载出去)

## 顶级域名

像com这样的顶级域名，由ICANN 严格控制，是不允许随便创建的。顶级域名分两类:

- 通用顶级域名
- 国家顶级域名

通用顶级域名常见的如.com、 .org、.edu等， 国家顶级域名如我国的.cn， 美国的.us。 一般公司申请公网域名时，如果是跨国产品，应该选择通用顶级域名；如果没有跨国业务，看自己喜好（可以对比各家顶级域的服务、稳定性等再做选择）。 这里说一下几个比较热的顶级域，完整的顶级域参见[维基百科](https://link.juejin.im/?target=https%3A%2F%2Fzh.wikipedia.org%2Fwiki%2F%E4%BA%92%E8%81%94%E7%BD%91%E9%A1%B6%E7%BA%A7%E5%9F%9F%E5%88%97%E8%A1%A8)。

**me**
me顶级域其实是国家域名， 是`黑山共和国`的国家域名，只不过它对个人开发申请，所以很多个人博主就用它作为自己的博客域名（本博客也是这么来的~)

**io**
很多开源项目常用io做顶级域名，它也是国家域名。 因为io 与计算机中的 input/output 缩写相同，和计算机的二机制10也很像，给人一种geek的感觉。相较于.com域名，.io下的资源很多，更多选择.

# DNS 解析流程

聊完了DNS 的基本概念，我们再来聊一聊DNS 的解析流程。 当我们通过浏览器或者应用程序访问互联网时，都会先执行一遍DNS解析流程。标准glibc提供了libresolv.so.2 动态库，我们的应用程序就是用它进行域名解析(也叫resolving)的， 它还提供了一个配置文件`/etc/nsswitch.conf`来控制resolving行为，配置文件中最关键的是这行:

```
hosts:      files dns myhostname复制代码
```

它决定了resolving 的顺序，默认是先查找hosts文件，如果没有匹配到，再进行DNS解析。默认的解析流程如下图:



![img](Untitled.assets/5916fc89a789d7fc3ff24b981e7fe91d)



上图主要描述了client端的解析流程，我们可以看到最主要的是第四步请求本地DNS服务器去执行resolving，它会根据本地DNS服务器配置，发送解析请求到递归解析服务器（稍后介绍什么是递归解析服务器)， 本地DNS服务器在 `/etc/resolv.conf` 中配置。 下面我们再来看看服务端的resolving流程:



![img](Untitled.assets/d30ca05abf14b4f94dfef920e91af412)



我们分析一下解析流程:

1. 客户端向本地DNS服务器(递归解析服务器) 发出解析tool.chinaz.com域名的请求
2. 本地dns服务器查看缓存，是否有缓存过tool.chinaz.com域名，如果有直接返回给客户端；如果没有执行下一步
3. 本地dns服务器向根域名服务器发送请求，查询com顶级域的nameserver 地址
4. 拿到com域名的IP后，再向com nameserver发送请求，获取chinaz域名的nameserver地址
5. 继续请求chinaz的nameserver, 获取tool域名的地址，最终得到了tool.chinaz.com的IP，本地dns服务器把这个结果缓存起来，以供下次查询快速返回
6. 本地dns服务器把把结果返回给客户端

**递归解析服务器 vs 权威域名服务器**

我们在解析流程中发现两类DNS服务器，客户端直接访问的是 `递归解析服务器`， 它在整个解析过程中也最忙。 它的查询步骤是递归的，从根域名服务器开始，一直询问到目标域名。

递归解析服务器通过请求一级一级的权威域名服务器，获得下一目标的地址，直到找到目标域名的 `权威域名服务器`

简单来说： `递归解析服务器` 是负责解析域名的， `权威域名服务器`是负责存储域名记录的

递归解析服务器一般由ISP提供，除此之外也有一些比较出名的公共递归解析服务器， 如谷歌的8.8.8.8，联通的114，BAT也都有推出公共递归解析服务器，但性能最好的应该还是你的ISP提供的，只是可能会有 `DNS劫持` 的问题

**缓存**

由于整个解析过程非常复杂，所以DNS 通过缓存技术来实现服务的鲁棒性。 当递归nameserver解析过tool.chianaz.com 域名后，再次收到tool.chinaz.com查询时，它不会再走一遍递归解析流程，而是把上一次解析结果的缓存直接返回。 并且它是分级缓存的，也就是说，当下次收到的是www.chinaz.com的查询时， 由于这台递归解析服务器已经知道chinaz.com的权威nameserver, 所以它只需要再向chinaz.com nameserver 发送一个查询www的请求就可以了。

**根域名服务器**
递归解析服务器是怎么知道 `根域名服务器`的地址的呢？ 根域名服务器的地址是固定的，目前全球有13个根域名解析服务器，这13条记录持久化在递归解析服务器中:



![img](Untitled.assets/772e5d20f133fb9c9ae3c4cada0e16bb)



为什么只有13个根域名服务器呢，不是应该越多越好来做负载均衡吗？ 之前说过DNS 协议使用了UDP查询， 由于UDP查询中能保证性能的最大长度是512字节，要让所有根域名服务器数据能包含在512字节的UDP包中， 根服务器只能限制在13个， 而且每个服务器要使用字母表中单字母名

**智能解析**

智能解析，就是当一个域名对应多个IP时，当你查询这个域名的IP，会返回离你最近的IP。 由于国内不同运营商之间的带宽很低，所以电信用户访问联通的IP就是一个灾难，而智能DNS解析就能解决这个问题。

智能解析依赖EDNS协议，这是google 起草的DNS扩展协议， 修改比较简单，就是在DNS包里面添加origin client IP, 这样nameserver 就能根据client IP 返回距离client 比较近的server IP 了

国内最新支持EDNS的就是DNSPod 了，DNSPod 是国内比较流行的域名解析厂商，很多公司会把域名利用DNSPod 加速， 它已经被鹅厂收购

# 域名注册商

一般我们要注册域名，都要需要找域名注册商，比如说我想注册hello.com，那么我需要找com域名注册商注册hello域名。com的域名注册商不止一家， 这些域名注册商也是从ICANN 拿到的注册权， 参见[如何申请成为.com域名注册商](https://link.juejin.im/?target=https%3A%2F%2Fwww.zhihu.com%2Fquestion%2F19578540)

那么，`域名注册商` 和 `权威域名解析服务器` 有什么关系呢？ 域名注册商都会自建权威域名解析服务器，比如你在狗爹上申请一个.com下的二级域名，你并不需要搭建nameserver， 直接在godaddy控制中心里管理你的域名指向就可以了， 原因就是你新域名的权威域名服务器默认由域名注册商提供。 当然你也可以更换，比如从godaddy申请的境外域名，把权威域名服务器改成DNSPod，一方面加快国内解析速度，另一方面还能享受DNSPod 提供的智能解析功能

# 用bind搭建域名解析服务器

由于网上介绍bind搭建的文章实在太多了，我就不再赘述了， 喜欢动手的朋友可以网上搜一搜搭建教程，一步步搭建一个本地的nameserver 玩一玩。这里主要介绍一下bind 的配置文件吧

bind 的配置文件分两部分: `bind配置文件` 和 `zone配置文件`

## bind配置文件

bind配置文件位于`/etc/named.conf`，它主要负责bind功能配置，如zone路径、日志、安全、主从等配置



![img](Untitled.assets/ecba67163d2e153e943d6b45a5d53792)



其中最主要的是添加zone的配置以及指定zone配置文件。 `recursion` 开启递归解析功能， 这个如果是no， 那么此bind服务只能做权威解析服务，当你的bind服务对外时，打开它会有安全风险，如何防御不当，会让你的nameserver 被hacker 用来做肉鸡

## zone配置文件

zone的配置文件在bind配置文件中指定，下图是一份简单的zone配置:



![img](Untitled.assets/8469d461fb37f4fadf503cf8d5d760a6)



zone的配置是nameserver的核心配置， 它指定了DNS 资源记录，如SOA、A、CNAME、AAAA等记录，各种记录的概念网上资料太多，我这里就不重复了。其中主要讲一下SOA 和 CNAME 的作用。

**SOA记录**

SOA 记录表示此域名的权威解析服务器地址。 上文讲了权威解析服务器和递归解析服务器的差别， 当所有递归解析服务器中有没你域名解析的缓存时，它们就会回源来请求此域名的SOA记录，也叫权威解析记录

**CNAME**

CNAME 的概念很像别名，它的处理逻辑也如此。 一个server 执行resloving 时，发现name 是一个CNAME， 它会转而查询这个CNAME的A记录。一般来说，能使用CNAME的地方都可以用A记录代替， 那么为什么还要发明CNAME这样一个东西呢？ 它是让多个域名指向同一个IP的一种快捷手段， 这样当最低层的CNAME 对应的IP换了之后，上层的CNAME 不用做任何改动。就像我们代码中的硬编码，我们总会去掉这些硬编码，用一个变量来表示，这样当这个变量变化时，我们只需要修改一处

配置完之后可以用`named-checkconf` 和 `named-checkzone` 两个命令来check我们的配置文件有没有问题， 之后就可以启动bind服务了:

```
$> service named start
Redirecting to /bin/systemctl restart  named.service复制代码
```

我们用`netstat -ntlp` 来检查一下服务是否启动:



![img](Untitled.assets/cedc58a110b25a1849cbc03cf14742eb)



53端口已启动，那么我们测试一下效果， 用dig解析一下`www.hello.com`域名， 使用127.0.0.1 作为递归解析服务器



![img](Untitled.assets/02c09c201be13d66b370566ffe05381c)



我们看到dig的结果跟我们配置文件中配置的一样是1.2.3.4，DNS完成了它的使命，根据域名获取到IP，但我们这里用来做示范的IP明显是个假IP:)

## 用DNS 实现负载均衡

一个域名添加多条A记录，解析时使用轮询的方式返回随机一条，流量将会均匀分类到多个A记录。

```
www     IN      A       1.2.3.4
www     IN      A       1.2.3.5复制代码
```

上面的配置中，我们给www域添加了两条A记录， 这种做法叫`multi-homed hosts`， 它的效果是：当我们请求nameserver 解析www.hello.com 域名时，返回的IP会在两个IP中轮转(默认行为，有些智能解析DNS会根据IP判断，返回一个离client近的IP, 距离 请搜索`DNS智能解析`)。

其实每次DNS解析请求时，nameserver都会返回全部IP，如上面配置，它会把1.2.3.4 和1.2.3.5 都返回给client端。 那么它是怎么实现RR的呢？ nameserver 只是每次返回的IP排序不同，客户端会把response里的第一个IP用来发请求。

**DNS负载均衡 vs LVS专业负载均衡**

和 LVS 这种专业负载均衡工具相比，在DNS层做负载均衡有以下特点:

1. 实现非常简单
2. 默认只能通过RR方式调度
3. DNS 对后端服务不具备健康检查
4. DNS 故障恢复时间比较长（DNS服务之间有缓存）
5. 可负载的rs数量有限（受DNS response包大小限制)

真实场景中，还需要根据需求选择相应的负载均衡策略

## 子域授权

我们从.com域下申请一个二级域名hello.com后， 发展到某一天我们的公司扩大了，需要拆分两个事业部A和B， 并且公司给他们都分配了三级域名 `a.hello.com` 和 `b.hello.com`， 域名结构如下图:



![img](Untitled.assets/fd5a0a0fc010ecf504fe5d8c98358ef4)



再发展一段时间， A部门和B部门内部业务太多，需要频繁的为新产品申请域名， 这个时候他们就想搭建自己的namserver, 并且需要上一级把相应的域名管理权交给自己， 他们期望的结构如下:



![img](Untitled.assets/7a53472a451c2d48faf81c84024288ab)



注意 第一阶段 和 第二阶段的区别： 第一阶段， A部门想申请a.hello.com 下的子域名，需要向上级申请， 整个a.hello.com 域的管理都在总公司； 第二阶段， A部门先自己搭建nameserver，然后总公司把 a.hello.com 域管理权转交给 自建的nameserver， 这个转交管理权的行为，就叫 `子域授权`

子域授权分两部操作:

1. A部门自建nameserver, 并且在zone配置文件中指定a.hello.com 的 权威解析服务器为自己的nameserver地址
2. 总公司在nameserver 上增加一条NS记录， 把a.hello.com 域授权给A部门的nameserver

第一步我们在`用bind搭建域名解析服务器` 里讲过， 只要在 zone配置文件里指定SOA记录就好:

```
@       IN     SOA      ns.a.hello.com    admin.a.hello.com. (……)复制代码
```

第二步，在hello.com域的nameserver 上添加一条NS记录:

```
a.hello.com      IN       NS       ns.a.hello.com
ns.a.hello.com      IN      A        xx.xx.xx.xx (自建nameserver的IP)复制代码
```

这样当解析xx.a.hello.com 域名时， hello.com nameserver 发现配置中有NS记录，就会继续递归向下解析

# DNS 调试工具

OPS 常用的DNS调试工具有: host, nslookup, dig

这三个命令都属于 bind-utils 包， 也就是bind工具集， 它们的使用复杂度、功能 依次递增。 关于它们的使用， man 手册和网上有太多教程，这里简单分析一下dig命令的输出吧：



![img](Untitled.assets/3509832be6995eb9b009b4a664bc14af)



dig 的参数非常多， 功能也很多，详细使用方法大家自行man吧

# 其他

## DNS 放大攻击

DNS 放大攻击属于DoS攻击的一种，是通过大量流量占满目标机带宽， 使得目标机对正常用户的请求拒绝连接从而挂掉。

**思路**
正常的流量攻击，hack机向目标机建立大量request-response, 但这样存在的问题是需要大量的hack机器。 因为服务器一般的带宽远大于家用网络， 如果我们自己的家用机用来做hack机器，还没等目标机的带宽占满，我们的带宽早超载了。

**原理**
DNS 递归解析的流程比较特殊， 我们可以通过几个字节的query请求，换来几百甚至几千字节的resolving应答`（流量放大）`， 并且大部分服务器不会对DNS服务器做防御。 那么hacker们只要可以伪装DNS query包的source IP, 从而让DNS 服务器发送大量的response到目标机，就可以实现DoS攻击。