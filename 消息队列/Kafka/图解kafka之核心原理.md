# kafka日志存储

我们知道 Kafka 中的消息是存储在磁盘上的，那么为什么要使用磁盘作为存储介质？具体消息的存储格式又是什么呢？怎么样能够快速检索到指定的消息？消息不可能无限制存储，那么清理规则又是什么呢？带着这些疑问，我们来一探究竟。

## 日志文件目录布局

回顾一下 Kafka 的基础知识：Kafka 中的消息是以主题为基本单位进行归类的，各个主题在逻辑上相互独立。每个主题又可以分为一个或多个分区，分区的数量可以在主题创建的时候指定，也可以在之后修改。每条消息在发送的时候会根据分区规则被追加到指定的分区中，分区中的每条消息都会被分配一个唯一的序列号，也就是通常所说的偏移量（offset），具有4个分区的主题的逻辑结构见下图。



![图1-2 消息追加写入](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/16949cc96dc79e19)



如果分区规则设置得合理，那么所有的消息可以均匀地分布到不同的分区中，这样就可以实现水平扩展。不考虑多副本的情况，一个分区对应一个日志（Log）。为了防止 Log 过大，Kafka 又引入了日志分段（`LogSegment`）的概念，将 Log 切分为多个 LogSegment，相当于一个巨型文件被平均分配为多个相对较小的文件，这样也便于消息的维护和清理。

事实上，Log 和 LogSegment 也不是纯粹物理意义上的概念，Log 在物理上只以文件夹的形式存储，而每个 LogSegment 对应于磁盘上的一个日志文件和两个索引文件，以及可能的其他文件（比如以“.txnindex”为后缀的事务索引文件）。下图描绘了主题、分区、副本、Log 以及 LogSegment 之间的关系。



![5-1](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169d4cc701e62b82)



接触过 Kafka 的老司机一般都知晓 Log 对应了一个命名形式为<topic>-<partition>的文件夹。举个例子，假设有一个名为“topic-log”的主题，此主题中具有4个分区，那么在实际物理存储上表现为“topic-log-0”、“topic-log-1”、“topic-log-2”、“topic-log-3”这4个文件夹：

```
[root@node1 kafka-logs]# ls -al | grep topic-log
drwxr-xr-x   2 root root 4096 May 16 18:33 topic-log-0
drwxr-xr-x   2 root root 4096 May 16 18:33 topic-log-1
drwxr-xr-x   2 root root 4096 May 16 18:33 topic-log-2
drwxr-xr-x   2 root root 4096 May 16 18:33 topic-log-3
```

向 Log 中追加消息时是顺序写入的，只有最后一个 LogSegment 才能执行写入操作，在此之前所有的 LogSegment 都不能写入数据。为了方便描述，我们将最后一个 LogSegment 称为“activeSegment”，即表示当前活跃的日志分段。随着消息的不断写入，当 activeSegment 满足一定的条件时，就需要创建新的 activeSegment，之后追加的消息将写入新的 activeSegment。

为了便于消息的检索，每个 LogSegment 中的日志文件（以“.log”为文件后缀）都有对应的两个索引文件：偏移量索引文件（以“.index”为文件后缀）和时间戳索引文件（以“.timeindex”为文件后缀）。每个 LogSegment 都有一个基准偏移量 baseOffset，用来表示当前 LogSegment 中第一条消息的 offset。偏移量是一个64位的长整型数，日志文件和两个索引文件都是根据基准偏移量（baseOffset）命名的，名称固定为20位数字，没有达到的位数则用0填充。比如第一个 LogSegment 的基准偏移量为0，对应的日志文件为00000000000000000000.log。

举例说明，向主题topic-log中发送一定量的消息，某一时刻topic-log-0目录中的布局如下所示。

```
-rw-r--r-- 1 root root       400 May 15 19:43 	00000000000000000000.index
-rw-r--r-- 1 root root      5111 May 15 19:43 	00000000000000000000.log
-rw-r--r-- 1 root root       600 May 15 19:43 	00000000000000000000.timeindex
-rw-r--r-- 1 root root       296 May 16 18:33 	00000000000000000133.index
-rw-r--r-- 1 root root      4085 May 16 18:33 	00000000000000000133.log
-rw-r--r-- 1 root root       444 May 16 18:33 	00000000000000000133.timeindex
-rw-r--r-- 1 root root 10485760 May 16 18:33 	00000000000000000251.index
-rw-r--r-- 1 root root      3869 May 16 18:33 	00000000000000000251.log
-rw-r--r-- 1 root root 10485756 May 16 18:33 	00000000000000000251.timeindex
```

示例中第2个 LogSegment 对应的基准位移是133，也说明了该 LogSegment 中的第一条消息的偏移量为133，同时可以反映出第一个 LogSegment 中共有133条消息（偏移量从0至132的消息）。

注意每个 LogSegment 中不只包含“.log”、“.index”、“.timeindex”这3种文件，还可能包含“.deleted”、“.cleaned”、“.swap”等临时文件，以及可能的“.snapshot”、“.txnindex”、“leader-epoch-checkpoint”等文件。

从更加宏观的视角上看，Kafka 中的文件不只上面提及的这些文件，比如还有一些检查点文件，当一个 Kafka 服务第一次启动的时候，默认的根目录下就会创建以下5个文件：

```
[root@node1 kafka-logs]# ls
cleaner-offset-checkpoint  log-start-offset-checkpoint  meta.properties  recovery-point-offset-checkpoint  replication-offset-checkpoint
```

消费者提交的位移是保存在 Kafka 内部的主题__consumer_offsets中的，初始情况下这个主题并不存在，当第一次有消费者消费消息时会自动创建这个主题。



![5-2](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169d4d253b4d46f5)



在某一时刻，Kafka 中的文件目录布局如上图所示。每一个根目录都会包含最基本的4个检查点文件（xxx-checkpoint）和 meta.properties 文件。在创建主题的时候，如果当前 broker 中不止配置了一个根目录，那么会挑选分区数最少的那个根目录来完成本次创建任务。

# 日志格式的演变

对一个成熟的消息中间件而言，消息格式（或者称为“日志格式”）不仅关系功能维度的扩展，还牵涉性能维度的优化。随着 Kafka 的迅猛发展，其消息格式也在不断升级改进，从0.8.x版本开始到现在的2.0.0版本，Kafka 的消息格式也经历了3个版本：v0 版本、v1 版本和v2 版本。

每个分区由内部的每一条消息组成，如果消息格式设计得不够精炼，那么其功能和性能都会大打折扣。比如有冗余字段，势必会不必要地增加分区的占用空间，进而不仅使存储的开销变大、网络传输的开销变大，也会使 Kafka 的性能下降。

反观如果缺少字段，比如在最初的 Kafka 消息版本中没有 timestamp 字段，对内部而言，其影响了日志保存、切分策略，对外部而言，其影响了消息审计、端到端延迟、大数据应用等功能的扩展。虽然可以在消息体内部添加一个时间戳，但解析变长的消息体会带来额外的开销，而存储在消息体（参考下图中的 value 字段）前面可以通过指针偏移量获取其值而容易解析，进而减少了开销（可以查看v1版本），虽然相比于没有 timestamp 字段的开销会大一点。

由此可见，仅在一个字段的一增一减之间就有这么多门道，那么 Kafka 具体是怎么做的呢？这里只针对 Kafka 0.8.x之上（包含）的版本做相应说明，对于之前的版本不做陈述。

## v0版本

Kafka 消息格式的第一个版本通常称为v0版本，在 Kafka 0.10.0之前都采用的这个消息格式（在0.8.x版本之前，Kafka 还使用过一个更古老的消息格式，不过对目前的 Kafka 而言，我们也不需要了解这个版本的消息格式）。如无特殊说明，我们只讨论消息未压缩的情形。



![5-3](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169db683867aada5)



上图中左边的“RECORD”部分就是 v0 版本的消息格式，大多数人会把图中左边的整体（即包括 offset 和 message size 字段）都看作消息，因为每个 RECORD（v0 和 v1 版）必定对应一个 offset 和 message size。每条消息都有一个 offset 用来标志它在分区中的偏移量，这个 offset 是逻辑值，而非实际物理偏移值，message size 表示消息的大小，这两者在一起被称为日志头部（LOG_OVERHEAD），固定为12B。

LOG_OVERHEAD 和 RECORD 一起用来描述一条消息，为了配合陈述的语境，在讲述具体消息格式时会偏向于将单纯的RECORD 看作消息，而在其他地方则偏向于将 LOG_OVERHEAD 和 RECORD 的整体看作消息，读者需要留意其中的区别。与消息对应的还有消息集的概念，消息集中包含一条或多条消息，消息集不仅是存储于磁盘及在网络上传输（Produce & Fetch）的基本形式，而且是 Kafka 中压缩的基本单元，详细结构参考上图中的右边部分。

下面具体陈述一下消息格式中的各个字段，从 crc32 开始算起，各个字段的解释如下。

- crc32（4B）：crc32 校验值。校验范围为 magic 至 value 之间。
- magic（1B）：消息格式版本号，此版本的 magic 值为0。
- attributes（1B）：消息的属性。总共占1个字节，低3位表示压缩类型：0表示 NONE、1表示 GZIP、2表示 SNAPPY、3表示 LZ4（LZ4 自 Kafka 0.9.x引入），其余位保留。
- key length（4B）：表示消息的 key 的长度。如果为-1，则表示没有设置 key，即 key = null。
- key：可选，如果没有 key 则无此字段。
- value length（4B）：实际消息体的长度。如果为-1，则表示消息为空。
- value：消息体。可以为空，比如墓碑（tombstone）消息。

v0 版本中一个消息的最小长度（RECORD_OVERHEAD_V0）为crc32 + magic + attributes + key length + value length = 4B + 1B + 1B + 4B + 4B =14B。也就是说，v0 版本中一条消息的最小长度为14B，如果小于这个值，那么这就是一条破损的消息而不被接收。

这里我们来做一个测试，首先创建一个分区数和副本因子都为1的主题，名称为“msg_format_v0”，然后往msg_format_v0中发送一条key ="key"、value = "value"的消息，之后查看对应的日志（这里采用 Kafka 0.8.2.1的版本）：

```
[root@node1 kafka_2.10-0.8.2.1]# bin/kafka-run-class.sh 
     kafka.tools.DumpLogSegments --files 
     /tmp/kafka-logs/msg_format_v0-0/00000000000000000000.log
Dumping /tmp/kafka-logs-08/msg_format_v0-0/00000000000000000000.log
Starting offset: 0
offset: 0 position: 0 isvalid: true payloadsize: 5 magic: 0 
compresscodec: NoCompressionCodec crc: 592888119 keysize: 3
```

日志的大小（即00000000000000000000.log文件的大小）为34B，其值正好等于 LOG_OVERHEAD + RECORD_OVERHEAD_V0 + 3B的 key + 5B的 value = 12B + 14B + 3B + 5B = 34B。

```
[root@node1 msg_format_v0-0]# ll *.log
-rw-r--r-- 1 root root       34 Apr 26 02:52 00000000000000000000.log
```

我们再发送一条 key = null，value = "value"的消息，之后查看日志的大小：

```
[root@node1 msg_format_v0-0]# ll *.log
-rw-r--r-- 1 root root       65 Apr 26 02:56 00000000000000000000.log
```

日志大小为65B，减去上一条34B的消息（LOG_OVERHEAD+RECORD），可以得知本条消息的大小为31B，正好等于 LOG_OVERHEAD + RECORD_OVERHEAD_V0 + 5B的value = 12B + 14B+ 5B = 31B。

## v1版本

Kafka 从0.10.0版本开始到0.11.0版本之前所使用的消息格式版本为 v1，比 v0 版本就多了一个 timestamp 字段，表示消息的时间戳。v1 版本的消息结构如下图所示。



![5-4](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169db6bd1054a261)



v1 版本的 magic 字段的值为1。v1 版本的 attributes 字段中的低3位和 v0 版本的一样，还是表示压缩类型，而第4个位（bit）也被利用了起来：0表示 timestamp 类型为 CreateTime，而1表示 timestamp 类型为 LogAppendTime，其他位保留。timestamp 类型由 broker 端参数 log.message.timestamp.type 来配置，默认值为 CreateTime，即采用生产者创建消息时的时间戳。如果在创建 ProducerRecord 时没有显式指定消息的时间戳，那么 KafkaProducer 也会在发送这条消息前自动添加上。

下面是 KafkaProducer 中与此对应的一句关键代码：

```
long timestamp = record.timestamp() == null ? time.milliseconds() : record.timestamp();
```

v1 版本的消息的最小长度（RECORD_OVERHEAD_V1）要比v0版本的大8个字节，即22B。如果像 v0 版本介绍的一样发送一条 key = "key"、value = "value" 的消息，那么此条消息在 v1 版本中会占用42B，具体测试步骤参考 v0 版的相关介绍。

## 消息压缩

常见的压缩算法是数据量越大压缩效果越好，一条消息通常不会太大，这就导致压缩效果并不是太好。而 Kafka 实现的压缩方式是将多条消息一起进行压缩，这样可以保证较好的压缩效果。在一般情况下，生产者发送的压缩数据在 broker 中也是保持压缩状态进行存储的，消费者从服务端获取的也是压缩的消息，消费者在处理消息之前才会解压消息，这样保持了端到端的压缩。

Kafka 日志中使用哪种压缩方式是通过参数 compression.type 来配置的，默认值为“producer”，表示保留生产者使用的压缩方式。这个参数还可以配置为“gzip”、“snappy”、“lz4”，分别对应 GZIP、SNAPPY、LZ4 这3种压缩算法。如果参数 compression.type 配置为 “uncompressed”，则表示不压缩。

> 注意要点：压缩率是压缩后的大小与压缩前的对比。例如：把100MB的文件压缩后是90MB，压缩率为90/100×100%=90%，压缩率越小，压缩效果越好。一般口语化陈述时会误描述为压缩率越高越好，为了避免混淆，本节不引入学术上的压缩率而引入压缩效果，这样容易达成共识。



![5-5](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169db6c0542a5533)



以上都是针对消息未压缩的情况，而当消息压缩时是将整个消息集进行压缩作为内层消息（inner message），内层消息整体作为外层（wrapper message）的 value，其结构上图所示。

压缩后的外层消息（wrapper message）中的 key 为 null，所以上图左半部分没有画出 key 字段，value 字段中保存的是多条压缩消息（inner message，内层消息），其中 Record 表示的是从 crc32 到 value 的消息格式。当生产者创建压缩消息的时候，对内部压缩消息设置的 offset 从0开始为每个内部消息分配 offset，详细可以参考下图右半部分。



![5-6](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169db6c302d97558)



其实每个从生产者发出的消息集中的消息 offset 都是从0开始的，当然这个 offset 不能直接存储在日志文件中，对 offset 的转换是在服务端进行的，客户端不需要做这个工作。外层消息保存了内层消息中最后一条消息的绝对位移（absolute offset），绝对位移是相对于整个分区而言的。

参考上图，对于未压缩的情形，图右内层消息中最后一条的 offset 理应是1030，但被压缩之后就变成了5，而这个1030被赋予给了外层的 offset。当消费者消费这个消息集的时候，首先解压缩整个消息集，然后找到内层消息中最后一条消息的 inner offset，根据如下公式找到内层消息中最后一条消息前面的消息的 absolute offset（RO 表示 Relative Offset，IO 表示 Inner Offset，而 AO 表示 Absolute Offset）：

```
RO = IO_of_a_message - IO_of_the_last_message 
AO = AO_Of_Last_Inner_Message + RO
```

注意这里的 RO 是前面的消息相对最后一条消息的 IO 而言的，所以其值小于等于0，0表示最后一条消息自身。

> 注意要点：压缩消息，英文是 compress message，Kafka 中还有一个 compact message，常常被人们直译成压缩消息，需要注意两者的区别。compact message 是针对日志清理策略而言的（cleanup.policy = compact），是指日志压缩（Log Compaction）后的消息，这个在后面的章节中会有相关介绍。本节中的压缩消息单指 compress message，即采用 GZIP、LZ4 等压缩工具压缩的消息。

在讲述 v1 版本的消息时，我们了解到 v1 版本比 v0 版的消息多了一个 timestamp 字段。对于压缩的情形，外层消息的 timestamp 设置为：

- 如果 timestamp 类型是 CreateTime，那么设置的是内层消息中最大的时间戳。
- 如果 timestamp 类型是 LogAppendTime，那么设置的是 Kafka 服务器当前的时间戳。 内层消息的 timestamp 设置为：
- 如果外层消息的 timestamp 类型是 CreateTime，那么设置的是生产者创建消息时的时间戳。
- 如果外层消息的 timestamp 类型是 LogAppendTime，那么所有内层消息的时间戳都会被忽略。

对 attributes 字段而言，它的 timestamp 位只在外层消息中设置，内层消息中的 timestamp 类型一直都是 CreateTime。

## 变长字段

Kafka 从0.11.0版本开始所使用的消息格式版本为 v2，这个版本的消息相比 v0 和 v1 的版本而言改动很大，同时还参考了 Protocol Buffer 而引入了变长整型（Varints）和 ZigZag 编码。为了更加形象地说明问题，首先我们来了解一下变长整型。

Varints 是使用一个或多个字节来序列化整数的一种方法。数值越小，其占用的字节数就越少。Varints 中的每个字节都有一个位于最高位的msb位（most significant bit），除最后一个字节外，其余 msb 位都设置为1，最后一个字节的 msb 位为0。这个 msb 位表示其后的字节是否和当前字节一起来表示同一个整数。除 msb 位外，剩余的7位用于存储数据本身，这种表示类型又称为 Base 128。

通常而言，一个字节8位可以表示256个值，所以称为 Base 256，而这里只能用7位表示，2的7次方即128。Varints 中采用的是小端字节序，即最小的字节放在最前面。

举个例子，比如数字1，它只占一个字节，所以 msb 位为0：

```
0000 0001
```

再举一个复杂点的例子，比如数字300：

```
1010 1100 0000 0010
```

300的二进制表示原本为0000 0001 0010 1100 = 256+32+8+4=300，那么为什么300的变长表示为上面的这种形式？ 首先去掉每个字节的 msb 位，表示如下：

```
1010 1100 0000 0010 
    -> 010 1100 000 0010
```

如前所述，Varints 使用的是小端字节序的布局方式，所以这里两个字节的位置需要翻转一下：

```
010 1100 000 0010
    -> 000 0010 010 1100 (翻转)
    -> 000 0010 ++ 010 1100 
    -> 0000 0001 0010 1100 = 256+32+8+4=300
```

Varints 可以用来表示 int32、int64、uint32、uint64、sint32、sint64、bool、enum 等类型。在实际使用过程中，如果当前字段可以表示为负数，那么对 int32/int64 和 sint32/sint64 而言，它们在进行编码时存在较大的区别。比如使用 int64 表示一个负数，那么哪怕是-1，其编码后的长度始终为10个字节（可以通过下面的代码来测试长度），就如同对待一个很大的无符号长整型数一样。为了使编码更加高效，Varints 使用了 ZigZag 的编码方式。

```
public int sizeOfLong(int v) {
    int bytes = 1;
    while ((v & 0xffffffffffffff80L) != 0L) {
        bytes += 1;
        v >>>= 7;
    }
    return bytes;
}
```

ZigZag 编码以一种锯齿形（zig-zags）的方式来回穿梭正负整数，将带符号整数映射为无符号整数，这样可以使绝对值较小的负数仍然享有较小的 Varints 编码值，比如-1编码为1，1编码为2，-2编码为3，如下表所示。

| 原 值       | 编码后的值 |
| ----------- | ---------- |
| 0           | 0          |
| -1          | 1          |
| 1           | 2          |
| -2          | 3          |
| 2147483647  | 4294967294 |
| -2147483648 | 4294967295 |



对应的公式为：

```
(n << 1) ^ (n >> 31)
```

这是对 sint32 而言的，sint64 对应的公式为：

```
(n << 1) ^ (n >> 63)
```

以-1为例，其二进制表现形式为1111 1111 1111 1111 1111 1111 1111 1111（补码）。

```
(n << 1)		= 1111 1111 1111 1111 1111 1111 1111 1110
(n >> 31) 	= 1111 1111 1111 1111 1111 1111 1111 1111
(n << 1) ^ (n >> 31) = 1
```

最终-1的 Varints 编码为0000 0001，这样原本用4个字节表示的-1现在可以用1个字节来表示了。1就显得非常简单了，其二进制表现形式为0000 0000 0000 0000 0000 0000 0000 0001。

```
(n << 1)   	= 0000 0000 0000 0000 0000 0000 0000 0010
(n >> 31) 	= 0000 0000 0000 0000 0000 0000 0000 0000
(n << 1) ^ (n >> 31) = 2
```

最终1的 Varints 编码为0000 0010，也只占用1个字节。

前面说过 Varints 中的一个字节中只有7位是有效数值位，即只能表示128个数值，转变成绝对值之后其实质上只能表示64个数值。比如对消息体长度而言，其值肯定是大于等于0的正整数，那么一个字节长度的 Varints 最大只能表示64。65的二进制数表示为：

```
0100 0001
```

经过 ZigZag 处理后为：

```
1000 0010 ^ 0000 0000 = 1000 0010
```

每个字节的低7位是有效数值位，所以1000 0010进一步转变为：

```
000 0001 000 0010
```

而 Varints 使用小端字节序，所以需要翻转一下位置：

```
000 0010 000 0001
```

设置非最后一个字节的 msb 位为1，最后一个字节的 msb 位为0，最终有：

```
1000 0010 0000 0001
```

所以最终65表示为1000 0010 0000 0001，而64却表示为0100 0000。

具体的编码实现如下（针对 int32 类型）：

```
public static void writeVarint(int value, ByteBuffer buffer) {
    int v = (value << 1) ^ (value >> 31);
    while ((v & 0xffffff80) != 0L) {
        byte b = (byte) ((v & 0x7f) | 0x80);
        buffer.put(b);
        v >>>= 7;
    }
    buffer.put((byte) v);
}
```

对应的解码实现如下（针对 int32 类型）：

```
public static int readVarint(ByteBuffer buffer) {
    int value = 0;
    int i = 0;
    int b;
    while (((b = buffer.get()) & 0x80) != 0) {
        value |= (b & 0x7f) << i;
        i += 7;
        if (i > 28)
            throw illegalVarintException(value);
    }
    value |= b << i;
    return (value >>> 1) ^ -(value & 1);
}
```

回顾 Kafka v0 和 v1 版本的消息格式，如果消息本身没有 key，那么 key length 字段为-1，int 类型的需要4个字节来保存，而如果采用 Varints 来编码则只需要1个字节。根据 Varints 的规则可以推导出0～63之间的数字占1个字节，64～8191之间的数字占2个字节，8192～1048575之间的数字占3个字节。而 Kafka broker 端配置 message.max.bytes 的默认大小为1000012（Varints 编码占3个字节），如果消息格式中与长度有关的字段采用 Varints 的编码，那么绝大多数情况下都会节省空间，而 v2 版本的消息格式也正是这样做的。

不过需要注意的是，Varints 并非一直会节省空间，一个 int32 最长会占用5个字节（大于默认的4个字节），一个 int64 最长会占用10个字节（大于默认的8个字节）。下面的代码展示了如何计算一个 int32 占用的字节个数：

```
public static int sizeOfVarint(int value) {
    int v = (value << 1) ^ (value >> 31);
    int bytes = 1;
    while ((v & 0xffffff80) != 0L) {
        bytes += 1;
        v >>>= 7;
    }
    return bytes;
}
```

有关 int32/int64 的更多实现细节可以参考 org.apache.kafka.common.utils.ByteUtils。

## v2版本

v2 版本中消息集称为 Record Batch，而不是先前的 Message Set，其内部也包含了一条或多条消息，消息的格式参见下图的中部和右部。在消息压缩的情形下，Record Batch Header 部分（参见下图左部，从 first offset 到 records count 字段）是不被压缩的，而被压缩的是 records 字段中的所有内容。生产者客户端中的 ProducerBatch 对应这里的 RecordBatch，而 ProducerRecord 对应这里的 Record。



![5-7](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169db7e43d4929b7)



先讲述消息格式 Record 的关键字段，可以看到内部字段大量采用了 Varints，这样 Kafka 可以根据具体的值来确定需要几个字节来保存。v2 版本的消息格式去掉了 crc 字段，另外增加了 length（消息总长度）、timestamp delta（时间戳增量）、offset delta（位移增量）和 headers 信息，并且 attributes 字段被弃用了，笔者对此做如下分析（key、key length、value、value length 字段同 v0 和 v1 版本的一样，这里不再赘述）。

- length：消息总长度。
- attributes：弃用，但还是在消息格式中占据1B的大小，以备未来的格式扩展。
- timestamp delta：时间戳增量。通常一个 timestamp 需要占用8个字节，如果像这里一样保存与 RecordBatch 的起始时间戳的差值，则可以进一步节省占用的字节数。
- offset delta：位移增量。保存与 RecordBatch 起始位移的差值，可以节省占用的字节数。
- headers：这个字段用来支持应用级别的扩展，而不需要像 v0 和 v1 版本一样不得不将一些应用级别的属性值嵌入消息体。Header 的格式如图中最右部分所示，包含 key 和 value，一个 Record 里面可以包含0至多个 Header。

对于 v1 版本的消息，如果用户指定的 timestamp 类型是 LogAppendTime 而不是 CreateTime，那么消息从生产者进入 broker 后，timestamp 字段会被更新，此时消息的 crc 值将被重新计算，而此值在生产者中已经被计算过一次。再者，broker 端在进行消息格式转换时（比如 v1 版转成 v0 版的消息格式）也会重新计算 crc 的值。在这些类似的情况下，消息从生产者到消费者之间流动时，crc 的值是变动的，需要计算两次 crc 的值，所以这个字段的设计在 v0 和 v1 版本中显得比较“鸡肋”。在 v2 版本中将 crc 的字段从 Record 中转移到了 RecordBatch 中。

v2 版本对消息集（RecordBatch）做了彻底的修改，参考上图最左部分，除了刚刚提及的 crc 字段，还多了如下字段。

- first offset：表示当前 RecordBatch 的起始位移。
- length：计算从 partition leader epoch 字段开始到末尾的长度。
- partition leader epoch：分区 leader 纪元，可以看作分区 leader 的版本号或更新次数，详细内容请参考16节。
- magic：消息格式的版本号，对 v2 版本而言，magic 等于2。
- attributes：消息属性，注意这里占用了两个字节。低3位表示压缩格式，可以参考 v0 和 v1；第4位表示时间戳类型；第5位表示此 RecordBatch 是否处于事务中，0表示非事务，1表示事务。第6位表示是否是控制消息（ControlBatch），0表示非控制消息，而1表示是控制消息，控制消息用来支持事务功能，详细内容请参考14节。
- last offset delta：RecordBatch 中最后一个 Record 的 offset 与 first offset 的差值。主要被 broker 用来确保 RecordBatch 中 Record 组装的正确性。
- first timestamp：RecordBatch 中第一条 Record 的时间戳。
- max timestamp：RecordBatch 中最大的时间戳，一般情况下是指最后一个 Record 的时间戳，和 last offset delta 的作用一样，用来确保消息组装的正确性。
- producer id：PID，用来支持幂等和事务，详细内容请参考14节。
- producer epoch：和 producer id 一样，用来支持幂等和事务，详细内容请参考14节。
- first sequence：和 producer id、producer epoch 一样，用来支持幂等和事务，详细内容请参考14节。
- records count：RecordBatch 中R ecord 的个数。

为了验证这个格式的正确性，我们往某个分区中一次性发送6条 key 为“key”、value 为“value”的消息，相应的日志内容如下：

```
0000 0000 0000 0000 0000 0090 0000 0000
0207 3fbb 9a00 0000 0000 0500 0001 6363
9e4c cc00 0001 6363 9e4e 7bff ffff ffff
ffff ffff ffff ffff ff00 0000 061c 0000
0006 6b65 790a 7661 6c75 6500 1e00 d406
0206 6b65 790a 7661 6c75 6500 1e00 d806
0406 6b65 790a 7661 6c75 6500 1e00 da06
0606 6b65 790a 7661 6c75 6500 1e00 dc06
0806 6b65 790a 7661 6c75 6500 1e00 de06
0a06 6b65 790a 7661 6c75 6500
```

可以看到全部是以16进制数来表示的，未免晦涩难懂，下面对照上图来详细讲解每个字节所表示的具体含义，具体参考如下：

```
0000 0000 0000 0000             first offset = 0           RecordBatch
0000 0090			length = 144
0000 0000			partition leader epoch = 0
02				magic = 2
07 3fbb 9a			crc
00 00				attributes
00 0000 05			last offset delta = 5
00 0001 6363 9e4c cc            first timestamp = ‭1526384708812‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬
00 0001 6363 9e4e 7b            max timestamp = ‭1526384709243‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬‬
ff ffff ffff ffff ff            producer id = -1
ff ff				producer epoch = -1
ff ffff ff			first sequence = 0
00 0000 06			records count = 6     
----------------------------------------------------------------------------
1c				length = readVaint(0x1c) = 14		第1个Record
00				attributes
00				timestamp delta = readVaint(0x00) = 0
00				offset delta = readVaint(0x00) = 0
06				key length = readVaint(0x06) = 3
6b65 79				key = "key" 查ASCII码表可知：'k'->0x6b 'e'->0x65 'y'->0x79
0a				value length = readVaint(0x0a) = 5
7661 6c75 65		        value = "value" 查ASCII码表（略）
00				headers count = readVaint(0x00) = 0
----------------------------------------------------------------------------
1e				length = readVaint(0x1e) = 15		第2个Record
00				attributes
d406				timestamp delta = readVaint(d406) = 426
02				offset delta = readVaint(0x02) = 1
06				key length = readVaint(0x06) = 3
6b65 79				key = "key"
0a				value length = readVaint(0x0a) = 5
7661 6c75 65		        value = "value"
00				headers count = readVaint(0x00) = 0
----------------------------------------------------------------------------
1e00 d806 0406 6b65 790a 7661 6c75 6500         第3个Record
1e00 da06 0606 6b65 790a 7661 6c75 6500         第4个Record
1e00 dc06 0806 6b65 790a 7661 6c75 6500         第5个Record
1e00 de06 0a06 6b65 790a 7661 6c75 6500         第6个Record
```

这里我们再来做一个测试，在2.0.0版本的 Kafka 中创建一个分区数和副本因子数都为1的主题，名称为“msg_format_v2”。然后同样插入一条 key = "key"、value = "value"的消息，日志结果如下：

```
[root@node1 kafka_2.11-2.0.0]# bin/kafka-dump-log.sh --files 
     /tmp/kafka-logs/msg_format_v2-0/00000000000000000000.log 
Dumping /tmp/kafka-logs/msg_format_v2-0/00000000000000000000.log
Starting offset: 0
baseOffset: 0 lastOffset: 0 count: 1 baseSequence: -1 lastSequence: -1 producerId: -1 producerEpoch: -1 partitionLeaderEpoch: 0 isTransactional: false position: 0 CreateTime: 1538049867325 isvalid: true size: 76 magic: 2 compresscodec: NONE crc: 1494132791

[root@node1 kafka_2.11-2.0.0]# bin/kafka-dump-log.sh --files 
     /tmp/kafka-logs/msg_format_v2-0/00000000000000000000.log --print-data-log
Dumping /tmp/kafka-logs/msg_format_v2-0/00000000000000000000.log
Starting offset: 0
offset: 0 position: 0 CreateTime: 1538049867325 isvalid: true keysize: 3 valuesize: 5 magic: 2 compresscodec: NONE producerId: -1 producerEpoch: -1 sequence: -1 isTransactional: false headerKeys: [] key: key payload: value
```

可以看到示例中 size 字段为76，我们根据 v2 版本的日志格式来验证一下，Record Batch Header 部分共61B。Record 部分中的 attributes 占1B；timestamp delta 的值为0，占1B；offset delta 的值为0，占1B；key length 的值为3，占1B；key占3B；value length 的值为5，占1B，value 占5B；headers count 的值为0，占1B；无 headers。Record 部分的总长度 = 1B+1B+1B+1B+3B+1B+5B+1B = 14B，所以 Record 的 length 字段的值为14，编码变为长整型数之后占1B。最后推导出这条消息的占用字节数 = 61B+14B+1B = 76B，符合测试结果。同样再发一条 key = null、value = "value"的消息，可以计算出这条消息占73B。

这么看上去 v2 版本的消息好像要比之前版本的消息所占用的空间大得多，的确对单条消息而言是这样的，如果我们连续向主题 msg_format_v2 中再发送10条 value 长度为6、key 为 null 的消息，可以得到：

```
baseOffset: 2 lastOffset: 11 baseSequence: -1 lastSequence: -1 producerId: -1
 producerEpoch: -1 partitionLeaderEpoch: 0 isTransactional: false position: 149
 CreateTime: 1524712213771 isvalid: true size: 191 magic: 2 compresscodec: NONE
 crc: 820363253
```

本来应该占用740B大小的空间，实际上只占用了191B，在 v0 版本中这10条消息需要占用320B的空间大小，而 v1 版本则需要占用400B的空间大小，这样看来 v2 版本又节省了很多空间，因为它将多个消息（Record）打包存放到单个 RecordBatch 中，又通过 Varints 编码极大地节省了空间。有兴趣的读者可以自行测试一下在大批量消息的情况下，v2 版本和其他版本消息占用大小的对比，比如往主题 msg_format_v0 和 msg_format_v2 中各自发送100万条1KB的消息。

v2 版本的消息不仅提供了更多的功能，比如事务、幂等性等，某些情况下还减少了消息的空间占用，总体性能提升很大。

细心的读者可能注意到前面在演示如何查看日志内容时，既使用了 kafka-run-class.sh kafka.tools.DumpLogSegments 的方式，又使用了 kafka-dump-log.sh 的方式。而 kafka-dump-log.sh 脚本的内容为：

```
exec $(dirname $0)/kafka-run-class.sh kafka.tools.DumpLogSegments "$@"
```

两种方式在本质上没有什么区别，只不过在 Kafka 2.0.0之前并没有 kafka-dump-log.sh 脚本，所以只能使用 kafka-run-class.sh kafka.tools.DumpLogSegments的形式，而从 Kafka 2.0.0开始，可以直接使用 kafka-dump-log.sh 脚本来避免书写错误。

# 日志索引

前面章节就提及了每个日志分段文件对应了两个索引文件，主要用来提高查找消息的效率。偏移量索引文件用来建立消息偏移量（offset）到物理地址之间的映射关系，方便快速定位消息所在的物理文件位置；时间戳索引文件则根据指定的时间戳（timestamp）来查找对应的偏移量信息。

Kafka 中的索引文件以稀疏索引（sparse index）的方式构造消息的索引，它并不保证每个消息在索引文件中都有对应的索引项。每当写入一定量（由 broker 端参数 log.index.interval.bytes 指定，默认值为4096，即 4KB）的消息时，偏移量索引文件和时间戳索引文件分别增加一个偏移量索引项和时间戳索引项，增大或减小 log.index.interval.bytes 的值，对应地可以增加或缩小索引项的密度。

稀疏索引通过 MappedByteBuffer 将索引文件映射到内存中，以加快索引的查询速度。偏移量索引文件中的偏移量是单调递增的，查询指定偏移量时，使用二分查找法来快速定位偏移量的位置，如果指定的偏移量不在索引文件中，则会返回小于指定偏移量的最大偏移量。

时间戳索引文件中的时间戳也保持严格的单调递增，查询指定时间戳时，也根据二分查找法来查找不大于该时间戳的最大偏移量，至于要找到对应的物理文件位置还需要根据偏移量索引文件来进行再次定位。稀疏索引的方式是在磁盘空间、内存空间、查找时间等多方面之间的一个折中。

前面章节也提及日志分段文件达到一定的条件时需要进行切分，那么其对应的索引文件也需要进行切分。日志分段文件切分包含以下几个条件，满足其一即可：

1. 当前日志分段文件的大小超过了 broker 端参数 log.segment.bytes 配置的值。log.segment.bytes 参数的默认值为1073741824，即1GB。
2. 当前日志分段中消息的最大时间戳与当前系统的时间戳的差值大于 log.roll.ms 或 log.roll.hours 参数配置的值。如果同时配置了 log.roll.ms 和 log.roll.hours 参数，那么 log.roll.ms 的优先级高。默认情况下，只配置了 log.roll.hours 参数，其值为168，即7天。
3. 偏移量索引文件或时间戳索引文件的大小达到 broker 端参数 log.index.size.max.bytes配置的值。log.index.size.max.bytes 的默认值为10485760，即10MB。
4. 追加的消息的偏移量与当前日志分段的偏移量之间的差值大于 Integer.MAX_VALUE，即要追加的消息的偏移量不能转变为相对偏移量（offset - baseOffset > Integer.MAX_VALUE）。

对非当前活跃的日志分段而言，其对应的索引文件内容已经固定而不需要再写入索引项，所以会被设定为只读。而对当前活跃的日志分段（activeSegment）而言，索引文件还会追加更多的索引项，所以被设定为可读写。

在索引文件切分的时候，Kafka 会关闭当前正在写入的索引文件并置为只读模式，同时以可读写的模式创建新的索引文件，索引文件的大小由 broker 端参数 log.index.size.max.bytes 配置。Kafka 在创建索引文件的时候会为其预分配 log.index.size.max.bytes 大小的空间，注意这一点与日志分段文件不同，只有当索引文件进行切分的时候，Kafka 才会把该索引文件裁剪到实际的数据大小。也就是说，与当前活跃的日志分段对应的索引文件的大小固定为 log.index.size.max.bytes，而其余日志分段对应的索引文件的大小为实际的占用空间。

## 偏移量索引

偏移量索引项的格式如下图所示。每个索引项占用8个字节，分为两个部分。

1. relativeOffset：相对偏移量，表示消息相对于 baseOffset 的偏移量，占用4个字节，当前索引文件的文件名即为 baseOffset 的值。
2. position：物理地址，也就是消息在日志分段文件中对应的物理位置，占用4个字节。



![5-8](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169db91496118846)



消息的偏移量（offset）占用8个字节，也可以称为绝对偏移量。索引项中没有直接使用绝对偏移量而改为只占用4个字节的相对偏移量（relativeOffset = offset - baseOffset），这样可以减小索引文件占用的空间。举个例子，一个日志分段的 baseOffset 为32，那么其文件名就是 00000000000000000032.log，offset 为35的消息在索引文件中的 relativeOffset 的值为35-32=3。

再来回顾一下前面日志分段文件切分的第4个条件：追加的消息的偏移量与当前日志分段的偏移量之间的差值大于 Integer.MAX_VALUE。如果彼此的差值超过了 Integer.MAX_VALUE，那么 relativeOffset 就不能用4个字节表示了，进而不能享受这个索引项的设计所带来的便利了。

我们以本章开头 topic-log-0 目录下的 00000000000000000000.index 为例来进行具体分析，截取 00000000000000000000.index 部分内容如下：

```
0000 0006 0000 009c 
0000 000e 0000 01cb
0000 0016 0000 02fa 
0000 001a 0000 03b0 
0000 001f 0000 0475
```

虽然是以16进制数表示的，但参考索引项的格式可以知道如下内容：

```
relativeOffset=6, position=156
relativeOffset=14, position=459
relativeOffset=22, position=656
relativeOffset=26, position=838
relativeOffset=31, position=1050
```

这里也可以使用前面讲的 kafka-dump-log.sh 脚本来解析 .index 文件（还包括 .timeindex、 .snapshot、.txnindex 等文件），示例如下：

```
[root@node1 kafka_2.11-2.0.0]# bin/kafka-dump-log.sh --files /tmp/kafka-logs/ topic-log-0/00000000000000000000.index
Dumping /tmp/kafka-logs/topic-log-0/00000000000000000000.index
offset: 6 position: 156
offset: 14 position: 459
offset: 22 position: 656
offset: 26 position: 838
offset: 31 position: 1050
```

单纯地讲解数字不免过于枯燥，我们这里给出 00000000000000000000.index 和 00000000000000000000.log 的对照图来做进一步的陈述，如下图所示。



![5-9](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169db9207dc5f8ec)



如果我们要查找偏移量为23的消息，那么应该怎么做呢？首先通过二分法在偏移量索引文件中找到不大于23的最大索引项，即[22, 656]，然后从日志分段文件中的物理位置656开始顺序查找偏移量为23的消息。

以上是最简单的一种情况。参考下图，如果要查找偏移量为268的消息，那么应该怎么办呢？首先肯定是定位到 baseOffset 为251的日志分段，然后计算相对偏移量 relativeOffset = 268 - 251 = 17，之后再在对应的索引文件中找到不大于17的索引项，最后根据索引项中的 position 定位到具体的日志分段文件位置开始查找目标消息。那么又是如何查找 baseOffset 为251的日志分段的呢？这里并不是顺序查找，而是用了跳跃表的结构。Kafka 的每个日志对象中使用了 ConcurrentSkipListMap 来保存各个日志分段，每个日志分段的 baseOffset 作为 key，这样可以根据指定偏移量来快速定位到消息所在的日志分段。



![5-10](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169db93405ac59fb)



还需要注意的是，Kafka 强制要求索引文件大小必须是索引项大小的整数倍，对偏移量索引文件而言，必须为8的整数倍。如果 broker 端参数 log.index.size.max.bytes 配置为67，那么 Kafka 在内部会将其转换为64，即不大于67，并且满足为8的整数倍的条件。

## 时间戳索引

时间戳索引项的格式如下图所示。



![5-11](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169db95e45633fde)



每个索引项占用12个字节，分为两个部分。

1. timestamp：当前日志分段最大的时间戳。
2. relativeOffset：时间戳所对应的消息的相对偏移量。

时间戳索引文件中包含若干时间戳索引项，每个追加的时间戳索引项中的 timestamp 必须大于之前追加的索引项的 timestamp，否则不予追加。如果 broker 端参数 log.message.timestamp.type 设置为 LogAppendTime，那么消息的时间戳必定能够保持单调递增；相反，如果是 CreateTime 类型则无法保证。生产者可以使用类似 ProducerRecord(String topic, Integer partition, Long timestamp, K key, V value) 的方法来指定时间戳的值。即使生产者客户端采用自动插入的时间戳也无法保证时间戳能够单调递增，如果两个不同时钟的生产者同时往一个分区中插入消息，那么也会造成当前分区的时间戳乱序。

与偏移量索引文件相似，时间戳索引文件大小必须是索引项大小（12B）的整数倍，如果不满足条件也会进行裁剪。同样假设 broker 端参数 log.index.size.max.bytes 配置为67，那么对应于时间戳索引文件，Kafka 在内部会将其转换为60。

我们已经知道每当写入一定量的消息时，就会在偏移量索引文件和时间戳索引文件中分别增加一个偏移量索引项和时间戳索引项。两个文件增加索引项的操作是同时进行的，但并不意味着偏移量索引中的 relativeOffset 和时间戳索引项中的 relativeOffset 是同一个值。与上面偏移量索引一节示例中所对应的时间戳索引文件 00000000000000000000.timeindex 的部分内容如下：

```
0000 0163 639e 5a35 0000 0006 
0000 0163 639e 65fa 0000 000f
0000 0163 639e 71bc 0000 0016 
0000 0163 639e 71cb 0000 001c 
0000 0163 639e 7d8f 0000 0025
```

有兴趣的读者可以自行解析上面内容的16进制数据。和讲述偏移量索引时一样，我们画出 00000000000000000000.timeindex 的具体结构，详细参考下图左上角。



![5-12](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ec46702c163b3)



如果要查找指定时间戳 targetTimeStamp = 1526384718288 开始的消息，首先是找到不小于指定时间戳的日志分段。这里就无法使用跳跃表来快速定位到相应的日志分段了，需要分以下几个步骤来完成：

**步骤1**：将 targetTimeStamp 和每个日志分段中的最大时间戳 largestTimeStamp 逐一对比，直到找到不小于 targetTimeStamp 的 largestTimeStamp 所对应的日志分段。日志分段中的 largestTimeStamp 的计算是先查询该日志分段所对应的时间戳索引文件，找到最后一条索引项，若最后一条索引项的时间戳字段值大于0，则取其值，否则取该日志分段的最近修改时间。

**步骤2**：找到相应的日志分段之后，在时间戳索引文件中使用二分查找算法查找到不大于 targetTimeStamp 的最大索引项，即[1526384718283, 28]，如此便找到了一个相对偏移量28。

**步骤3**：在偏移量索引文件中使用二分算法查找到不大于28的最大索引项，即[26, 838]。

**步骤4**：从步骤1中找到日志分段文件中的838的物理位置开始查找不小于 targetTimeStamp 的消息。

# 日志清理

Kafka 将消息存储在磁盘中，为了控制磁盘占用空间的不断增加就需要对消息做一定的清理操作。Kafka 中每一个分区副本都对应一个 Log，而 Log 又可以分为多个日志分段，这样也便于日志的清理操作。Kafka 提供了两种日志清理策略：

1. 日志删除（Log Retention）：按照一定的保留策略直接删除不符合条件的日志分段。
2. 日志压缩（Log Compaction）：针对每个消息的 key 进行整合，对于有相同 key 的不同 value 值，只保留最后一个版本。

我们可以通过 broker 端参数 log.cleanup.policy 来设置日志清理策略，此参数的默认值为“delete”，即采用日志删除的清理策略。如果要采用日志压缩的清理策略，就需要将 log.cleanup.policy 设置为“compact”，并且还需要将 log.cleaner.enable （默认值为 true）设定为 true。通过将 log.cleanup.policy 参数设置为“delete,compact”，还可以同时支持日志删除和日志压缩两种策略。

日志清理的粒度可以控制到主题级别，比如与 log.cleanup.policy 对应的主题级别的参数为 cleanup.policy，为了简化说明，本节只采用 broker 端参数做陈述，topic 级别的参数可以查看《图解Kafka之实战指南》的[相关章节](https://juejin.im/book/5c7d467e5188251b9156fdc0/section/5c7f53abf265da2dcf62ab53)。

## 日志删除

在 Kafka 的日志管理器中会有一个专门的日志删除任务来周期性地检测和删除不符合保留条件的日志分段文件，这个周期可以通过 broker 端参数 log.retention.check.interval.ms 来配置，默认值为300000，即5分钟。当前日志分段的保留策略有3种：基于时间的保留策略、基于日志大小的保留策略和基于日志起始偏移量的保留策略。

**1. 基于时间**

日志删除任务会检查当前日志文件中是否有保留时间超过设定的阈值（retentionMs）来寻找可删除的日志分段文件集合（deletableSegments），如下图所示。retentionMs 可以通过 broker 端参数 log.retention.hours、log.retention.minutes 和 log.retention.ms 来配置，其中 log.retention.ms 的优先级最高，log.retention.minutes 次之，log.retention.hours 最低。默认情况下只配置了 log.retention.hours 参数，其值为168，故默认情况下日志分段文件的保留时间为7天。



![5-13](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ec53c40f5ec6a)



查找过期的日志分段文件，并不是简单地根据日志分段的最近修改时间 lastModifiedTime 来计算的，而是根据日志分段中最大的时间戳 largestTimeStamp 来计算的。因为日志分段的 lastModifiedTime 可以被有意或无意地修改，比如执行了 touch 操作，或者分区副本进行了重新分配，lastModifiedTime 并不能真实地反映出日志分段在磁盘的保留时间。要获取日志分段中的最大时间戳 largestTimeStamp 的值，首先要查询该日志分段所对应的时间戳索引文件，查找时间戳索引文件中最后一条索引项，若最后一条索引项的时间戳字段值大于0，则取其值，否则才设置为最近修改时间 lastModifiedTime。

若待删除的日志分段的总数等于该日志文件中所有的日志分段的数量，那么说明所有的日志分段都已过期，但该日志文件中还要有一个日志分段用于接收消息的写入，即必须要保证有一个活跃的日志分段 activeSegment，在此种情况下，会先切分出一个新的日志分段作为 activeSegment，然后执行删除操作。

删除日志分段时，首先会从 Log 对象中所维护日志分段的跳跃表中移除待删除的日志分段，以保证没有线程对这些日志分段进行读取操作。然后将日志分段所对应的所有文件添加上“.deleted”的后缀（当然也包括对应的索引文件）。最后交由一个以“delete-file”命名的延迟任务来删除这些以“.deleted”为后缀的文件，这个任务的延迟执行时间可以通过 file.delete.delay.ms 参数来调配，此参数的默认值为60000，即1分钟。

**2. 基于日志大小**

日志删除任务会检查当前日志的大小是否超过设定的阈值（retentionSize）来寻找可删除的日志分段的文件集合（deletableSegments），如下图所示。retentionSize 可以通过 broker 端参数 log.retention.bytes 来配置，默认值为-1，表示无穷大。注意 log.retention.bytes 配置的是 Log 中所有日志文件的总大小，而不是单个日志分段（确切地说应该为 .log 日志文件）的大小。单个日志分段的大小由 broker 端参数 log.segment.bytes 来限制，默认值为1073741824，即 1GB。



![5-14](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ec54fee6867cd)



基于日志大小的保留策略与基于时间的保留策略类似，首先计算日志文件的总大小 size 和 retentionSize 的差值 diff，即计算需要删除的日志总大小，然后从日志文件中的第一个日志分段开始进行查找可删除的日志分段的文件集合 deletableSegments。查找出 deletableSegments 之后就执行删除操作，这个删除操作和基于时间的保留策略的删除操作相同，这里不再赘述。

**3. 基于日志起始偏移量**

一般情况下，日志文件的起始偏移量 logStartOffset 等于第一个日志分段的 baseOffset，但这并不是绝对的，logStartOffset 的值可以通过 DeleteRecordsRequest 请求（比如使用 KafkaAdminClient 的 deleteRecords() 方法、使用 kafka-delete-records.sh 脚本）、日志的清理和截断等操作进行修改。



![5-15](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ec55c205cb4f2)



基于日志起始偏移量的保留策略的判断依据是某日志分段的下一个日志分段的起始偏移量 baseOffset 是否小于等于 logStartOffset，若是，则可以删除此日志分段。如上图所示，假设 logStartOffset 等于25，日志分段1的起始偏移量为0，日志分段2的起始偏移量为11，日志分段3的起始偏移量为23，通过如下动作收集可删除的日志分段的文件集合 deletableSegments：

1. 从头开始遍历每个日志分段，日志分段1的下一个日志分段的起始偏移量为11，小于 logStartOffset 的大小，将日志分段1加入 deletableSegments。
2. 日志分段2的下一个日志偏移量的起始偏移量为23，也小于 logStartOffset 的大小，将日志分段2加入 deletableSegments。
3. 日志分段3的下一个日志偏移量在 logStartOffset 的右侧，故从日志分段3开始的所有日志分段都不会加入 deletableSegments。

收集完可删除的日志分段的文件集合之后的删除操作同基于日志大小的保留策略和基于时间的保留策略相同，这里不再赘述。

## 日志压缩

Kafka 中的 Log Compaction 是指在默认的日志删除（Log Retention）规则之外提供的一种清理过时数据的方式。如下图所示，Log Compaction 对于有相同 key 的不同 value 值，只保留最后一个版本。如果应用只关心 key 对应的最新 value 值，则可以开启 Kafka 的日志清理功能，Kafka 会定期将相同 key 的消息进行合并，只保留最新的 value 值。



![img](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ec566deb4beb0)



有很多中文资料会把 Log Compaction 翻译为“日志压缩”，笔者认为不够妥当，压缩应该是指 Compression，在 Kafka 中消息可以采用 gzip、Snappy、LZ4 等压缩方式进行压缩，如果把 Log Compaction 翻译为日志压缩，容易让人和消息压缩（Message Compression）产生关联，其实是两个不同的概念。英文“Compaction”可以直译为“压紧、压实”，如果这里将 Log Compaction 直译为“日志压紧”或“日志压实”又未免太过生硬。考虑到“日志压缩”的说法已经广为用户接受，笔者这里勉强接受此种说法，不过文中尽量直接使用英文 Log Compaction 来表示日志压缩。读者在遇到类似“压缩”的字眼之时需格外注意这个压缩具体是指日志压缩（Log Compaction）还是指消息压缩（Message Compression）。

Log Compaction 执行前后，日志分段中的每条消息的偏移量和写入时的偏移量保持一致。Log Compaction 会生成新的日志分段文件，日志分段中每条消息的物理位置会重新按照新文件来组织。Log Compaction 执行过后的偏移量不再是连续的，不过这并不影响日志的查询。

Kafka 中的 Log Compaction 可以类比于 Redis 中的 RDB 的持久化模式。试想一下，如果一个系统使用 Kafka 来保存状态，那么每次有状态变更都会将其写入 Kafka。在某一时刻此系统异常崩溃，进而在恢复时通过读取 Kafka 中的消息来恢复其应有的状态，那么此系统关心的是它原本的最新状态而不是历史时刻中的每一个状态。如果 Kafka 的日志保存策略是日志删除（Log Deletion），那么系统势必要一股脑地读取 Kafka 中的所有数据来进行恢复，如果日志保存策略是 Log Compaction，那么可以减少数据的加载量进而加快系统的恢复速度。Log Compaction 在某些应用场景下可以简化技术栈，提高系统整体的质量。

我们知道可以通过配置 log.dir 或 log.dirs 参数来设置 Kafka 日志的存放目录，而每一个日志目录下都有一个名为“cleaner-offset-checkpoint”的文件，这个文件就是清理检查点文件，用来记录每个主题的每个分区中已清理的偏移量。

通过清理检查点文件可以将 Log 分成两个部分，如下图所示。通过检查点 cleaner checkpoint 来划分出一个已经清理过的 clean 部分和一个还未清理过的 dirty 部分。在日志清理的同时，客户端也可以读取日志中的消息。dirty 部分的消息偏移量是逐一递增的，而 clean 部分的消息偏移量是断续的，如果客户端总能赶上 dirty 部分，那么它就能读取日志的所有消息，反之就不可能读到全部的消息。



![5-17](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ec56f85d37451)



上图中的 firstDirtyOffset（与 cleaner checkpoint 相等）表示 dirty 部分的起始偏移量，而 firstUncleanableOffset 为 dirty 部分的截止偏移量，整个 dirty 部分的偏移量范围为[firstDirtyOffset, firstUncleanableOffset），注意这里是左闭右开区间。为了避免当前活跃的日志分段 activeSegment 成为热点文件，activeSegment 不会参与 Log Compaction 的执行。同时 Kafka 支持通过参数 log.cleaner.min.compaction.lag.ms （默认值为0）来配置消息在被清理前的最小保留时间，默认情况下 firstUncleanableOffset 等于 activeSegment 的 baseOffset。

注意 Log Compaction 是针对 key 的，所以在使用时应注意每个消息的 key 值不为 null。每个 broker 会启动 log.cleaner.thread （默认值为1）个日志清理线程负责执行清理任务，这些线程会选择“污浊率”最高的日志文件进行清理。用 cleanBytes 表示 clean 部分的日志占用大小，dirtyBytes 表示 dirty 部分的日志占用大小，那么这个日志的污浊率（dirtyRatio）为：

```
dirtyRatio = dirtyBytes / (cleanBytes + dirtyBytes)
```

为了防止日志不必要的频繁清理操作，Kafka 还使用了参数 log.cleaner.min.cleanable.ratio （默认值为0.5）来限定可进行清理操作的最小污浊率。Kafka 中用于保存消费者消费位移的主题 __consumer_offsets 使用的就是 Log Compaction 策略。

这里我们已经知道怎样选择合适的日志文件做清理操作，然而怎么对日志文件中消息的 key 进行筛选操作呢？

Kafka 中的每个日志清理线程会使用一个名为“SkimpyOffsetMap”的对象来构建 key 与 offset 的映射关系的哈希表。日志清理需要遍历两次日志文件，第一次遍历把每个 key 的哈希值和最后出现的 offset 都保存在 SkimpyOffsetMap 中，映射模型如下图所示。第二次遍历会检查每个消息是否符合保留条件，如果符合就保留下来，否则就会被清理。假设一条消息的 offset 为 O1，这条消息的 key 在 SkimpyOffsetMap 中对应的 offset 为 O2，如果 O1 大于等于 O2 即满足保留条件。



![5-18](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ec57ee54d8921)



默认情况下，SkimpyOffsetMap 使用 MD5 来计算 key 的哈希值，占用空间大小为16B，根据这个哈希值来从 SkimpyOffsetMap 中找到对应的槽位，如果发生冲突则用线性探测法处理。为了防止哈希冲突过于频繁，也可以通过 broker 端参数 log.cleaner.io.buffer.load.factor （默认值为0.9）来调整负载因子。

偏移量占用空间大小为8B，故一个映射项占用大小为24B。每个日志清理线程的 SkimpyOffsetMap 的内存占用大小为 log.cleaner.dedupe.buffer.size / log.cleaner.thread，默认值为 = 128MB/1 = 128MB。所以默认情况下 SkimpyOffsetMap 可以保存128MB × 0.9 /24B ≈ 5033164个key的记录。假设每条消息的大小为1KB，那么这个 SkimpyOffsetMap 可以用来映射 4.8GB 的日志文件，如果有重复的 key，那么这个数值还会增大，整体上来说，SkimpyOffsetMap 极大地节省了内存空间且非常高效。

> 题外话：“SkimpyOffsetMap”的取名也很有意思，“Skimpy”可以直译为“不足的”，可以看出它最初的设计者也认为这种实现不够严谨。如果遇到两个不同的 key 但哈希值相同的情况，那么其中一个 key 所对应的消息就会丢失。虽然说 MD5 这类摘要算法的冲突概率非常小，但根据墨菲定律，任何一个事件，只要具有大于0的概率，就不能假设它不会发生，所以在使用 Log Compaction 策略时要注意这一点。

Log Compaction 会保留 key 相应的最新 value 值，那么当需要删除一个 key 时怎么办？Kafka 提供了一个墓碑消息（tombstone）的概念，如果一条消息的 key 不为 null，但是其 value 为 null，那么此消息就是墓碑消息。日志清理线程发现墓碑消息时会先进行常规的清理，并保留墓碑消息一段时间。

墓碑消息的保留条件是当前墓碑消息所在的日志分段的最近修改时间 lastModifiedTime 大于 deleteHorizonMs，如往上第二张图所示。这个 deleteHorizonMs 的计算方式为 clean 部分中最后一个日志分段的最近修改时间减去保留阈值 deleteRetionMs（通过 broker 端参数 log.cleaner.delete.retention.ms 配置，默认值为86400000，即24小时）的大小，即：

```
deleteHorizonMs = 
    clean部分中最后一个LogSegment的lastModifiedTime - deleteRetionMs
```

所以墓碑消息的保留条件为（可以对照往上第二张图中的 deleteRetionMs 所标记的位置去理解）：

```
所在LogSegment的lastModifiedTime > deleteHorizonMs 
=> 所在LogSegment的lastModifiedTime > clean部分中最后一个LogSegment的 
     lastModifiedTime - deleteRetionMs
=> 所在LogSegment的lastModifiedTime + deleteRetionMs > clean部分中最后一个
     LogSegment的lastModifiedTime
```

Log Compaction 执行过后的日志分段的大小会比原先的日志分段的要小，为了防止出现太多的小文件，Kafka 在实际清理过程中并不对单个的日志分段进行单独清理，而是将日志文件中 offset 从0至 firstUncleanableOffset 的所有日志分段进行分组，每个日志分段只属于一组，分组策略为：按照日志分段的顺序遍历，每组中日志分段的占用空间大小之和不超过 segmentSize（可以通过 broker 端参数 log.segment.bytes 设置，默认值为 1GB），且对应的索引文件占用大小之和不超过 maxIndexSize（可以通过 broker 端参数 log.index.interval.bytes 设置，默认值为 10MB）。同一个组的多个日志分段清理过后，只会生成一个新的日志分段。



![5-19](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ec59ade95b1fa)



如上图所示，假设所有的参数配置都为默认值，在 Log Compaction 之前 checkpoint 的初始值为0。执行第一次 Log Compaction 之后，每个非活跃的日志分段的大小都有所缩减，checkpoint 的值也有所变化。执行第二次 Log Compaction 时会组队成[0.4GB, 0.4GB]、[0.3GB, 0.7GB]、[0.3GB]、[1GB]这4个分组，并且从第二次 Log Compaction 开始还会涉及墓碑消息的清除。同理，第三次 Log Compaction 过后的情形可参考上图的尾部。

Log Compaction 过程中会将每个日志分组中需要保留的消息复制到一个以“.clean”为后缀的临时文件中，此临时文件以当前日志分组中第一个日志分段的文件名命名，例如 00000000000000000000.log.clean。Log Compaction 过后将“.clean”的文件修改为“.swap”后缀的文件，例如：00000000000000000000. log.swap。然后删除原本的日志文件，最后才把文件的“.swap”后缀去掉。整个过程中的索引文件的变换也是如此，至此一个完整 Log Compaction 操作才算完成。

以上是整个日志压缩（Log Compaction）过程的详解，读者需要注意将日志压缩和日志删除区分开，日志删除是指清除整个日志分段，而日志压缩是针对相同 key 的消息的合并清理。

# 磁盘存储

Kafka 依赖于文件系统（更底层地来说就是磁盘）来存储和缓存消息。在我们的印象中，对于各个存储介质的速度认知大体同下图所示的相同，层级越高代表速度越快。很显然，磁盘处于一个比较尴尬的位置，这不禁让我们怀疑 Kafka 采用这种持久化形式能否提供有竞争力的性能。在传统的消息中间件 RabbitMQ 中，就使用内存作为默认的存储介质，而磁盘作为备选介质，以此实现高吞吐和低延迟的特性。然而，事实上磁盘可以比我们预想的要快，也可能比我们预想的要慢，这完全取决于我们如何使用它。



![5-20](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169edf5b4ea58c07)



有关测试结果表明，一个由6块 7200r/min 的 RAID-5 阵列组成的磁盘簇的线性（顺序）写入速度可以达到 600MB/s，而随机写入速度只有 100KB/s，两者性能相差6000倍。操作系统可以针对线性读写做深层次的优化，比如预读（read-ahead，提前将一个比较大的磁盘块读入内存）和后写（write-behind，将很多小的逻辑写操作合并起来组成一个大的物理写操作）技术。顺序写盘的速度不仅比随机写盘的速度快，而且也比随机写内存的速度快，如下图所示。



![5-21](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169edf609f2a9c07)



Kafka 在设计时采用了文件追加的方式来写入消息，即只能在日志文件的尾部追加新的消息，并且也不允许修改已写入的消息，这种方式属于典型的顺序写盘的操作，所以就算Kafka使用磁盘作为存储介质，它所能承载的吞吐量也不容小觑。但这并不是让 Kafka 在性能上具备足够竞争力的唯一因素，我们不妨继续分析。

## 页缓存

页缓存是操作系统实现的一种主要的磁盘缓存，以此用来减少对磁盘 I/O 的操作。具体来说，就是把磁盘中的数据缓存到内存中，把对磁盘的访问变为对内存的访问。为了弥补性能上的差异，现代操作系统越来越“激进地”将内存作为磁盘缓存，甚至会非常乐意将所有可用的内存用作磁盘缓存，这样当内存回收时也几乎没有性能损失，所有对于磁盘的读写也将经由统一的缓存。

当一个进程准备读取磁盘上的文件内容时，操作系统会先查看待读取的数据所在的页（page）是否在页缓存（pagecache）中，如果存在（命中）则直接返回数据，从而避免了对物理磁盘的 I/O 操作；如果没有命中，则操作系统会向磁盘发起读取请求并将读取的数据页存入页缓存，之后再将数据返回给进程。

同样，如果一个进程需要将数据写入磁盘，那么操作系统也会检测数据对应的页是否在页缓存中，如果不存在，则会先在页缓存中添加相应的页，最后将数据写入对应的页。被修改过后的页也就变成了脏页，操作系统会在合适的时间把脏页中的数据写入磁盘，以保持数据的一致性。

Linux 操作系统中的 vm.dirty_background_ratio 参数用来指定当脏页数量达到系统内存的百分之多少之后就会触发 pdflush/flush/kdmflush 等后台回写进程的运行来处理脏页，一般设置为小于10的值即可，但不建议设置为0。与这个参数对应的还有一个 vm.dirty_ratio 参数，它用来指定当脏页数量达到系统内存的百分之多少之后就不得不开始对脏页进行处理，在此过程中，新的 I/O 请求会被阻挡直至所有脏页被冲刷到磁盘中。对脏页有兴趣的读者还可以自行查阅 vm.dirty_expire_centisecs、vm.dirty_writeback.centisecs 等参数的使用说明。

对一个进程而言，它会在进程内部缓存处理所需的数据，然而这些数据有可能还缓存在操作系统的页缓存中，因此同一份数据有可能被缓存了两次。并且，除非使用 Direct I/O 的方式，否则页缓存很难被禁止。此外，用过 Java 的人一般都知道两点事实：对象的内存开销非常大，通常会是真实数据大小的几倍甚至更多，空间使用率低下；Java 的垃圾回收会随着堆内数据的增多而变得越来越慢。基于这些因素，使用文件系统并依赖于页缓存的做法明显要优于维护一个进程内缓存或其他结构，至少我们可以省去了一份进程内部的缓存消耗，同时还可以通过结构紧凑的字节码来替代使用对象的方式以节省更多的空间。如此，我们可以在32GB的机器上使用28GB至30GB的内存而不用担心 GC 所带来的性能问题。

此外，即使 Kafka 服务重启，页缓存还是会保持有效，然而进程内的缓存却需要重建。这样也极大地简化了代码逻辑，因为维护页缓存和文件之间的一致性交由操作系统来负责，这样会比进程内维护更加安全有效。

Kafka 中大量使用了页缓存，这是 Kafka 实现高吞吐的重要因素之一。虽然消息都是先被写入页缓存，然后由操作系统负责具体的刷盘任务的，但在 Kafka 中同样提供了同步刷盘及间断性强制刷盘（fsync）的功能，这些功能可以通过 log.flush.interval.messages、log.flush.interval.ms 等参数来控制。

同步刷盘可以提高消息的可靠性，防止由于机器掉电等异常造成处于页缓存而没有及时写入磁盘的消息丢失。不过笔者并不建议这么做，刷盘任务就应交由操作系统去调配，消息的可靠性应该由多副本机制来保障，而不是由同步刷盘这种严重影响性能的行为来保障。

Linux 系统会使用磁盘的一部分作为 swap 分区，这样可以进行进程的调度：把当前非活跃的进程调入 swap 分区，以此把内存空出来让给活跃的进程。对大量使用系统页缓存的 Kafka 而言，应当尽量避免这种内存的交换，否则会对它各方面的性能产生很大的负面影响。

我们可以通过修改 vm.swappiness 参数（Linux 系统参数）来进行调节。vm.swappiness 参数的上限为100，它表示积极地使用 swap 分区，并把内存上的数据及时地搬运到 swap 分区中；vm.swappiness 参数的下限为0，表示在任何情况下都不要发生交换（vm.swappiness = 0 的含义在不同版本的 Linux 内核中不太相同，这里采用的是变更后的最新解释），这样一来，当内存耗尽时会根据一定的规则突然中止某些进程。笔者建议将这个参数的值设置为1，这样保留了 swap 的机制而又最大限度地限制了它对 Kafka 性能的影响。

## 磁盘I/O流程

读者可能对于前面提及的页缓存、Direct I/O、文件系统等概念的认知比较模糊，下面通过一张磁盘 I/O 的流程图来加深理解，如下图所示。

参考下图，从编程角度而言，一般磁盘 I/O 的场景有以下四种：

1. 用户调用标准 C 库进行 I/O 操作，数据流为：应用程序 buffer→C 库标准 IObuffer→文件系统页缓存→通过具体文件系统到磁盘。
2. 用户调用文件 I/O，数据流为：应用程序 buffer→文件系统页缓存→通过具体文件系统到磁盘。
3. 用户打开文件时使用 O_DIRECT，绕过页缓存直接读写磁盘。
4. 用户使用类似 dd 工具，并使用 direct 参数，绕过系统 cache与文件系统直接写磁盘。



![5-22](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169edf9b3e8b7554)



发起 I/O 请求的步骤可以表述为如下的内容（以最长链路为例）：

- **写操作**：用户调用 fwrite 把数据写入 C 库标准 IObuffer 后就返回，即写操作通常是异步操作；数据写入 C 库标准 IObuffer 后，不会立即刷新到磁盘，会将多次小数据量相邻写操作先缓存起来合并，最终调用 write 函数一次性写入（或者将大块数据分解多次 write 调用）页缓存；数据到达页缓存后也不会立即刷新到磁盘，内核有 pdflush 线程在不停地检测脏页，判断是否要写回到磁盘，如果是则发起磁盘 I/O 请求。
- **读操作**：用户调用 fread 到 C 库标准 IObuffer 中读取数据，如果成功则返回，否则继续；到页缓存中读取数据，如果成功则返回，否则继续；发起 I/O 请求，读取数据后缓存 buffer 和 C 库标准 IObuffer 并返回。可以看出，读操作是同步请求。
- **I/O请求处理**：通用块层根据 I/O 请求构造一个或多个 bio 结构并提交给调度层；调度器将 bio 结构进行排序和合并组织成队列且确保读写操作尽可能理想：将一个或多个进程的读操作合并到一起读，将一个或多个进程的写操作合并到一起写，尽可能变随机为顺序（因为随机读写比顺序读写要慢），读必须优先满足，而写也不能等太久。

针对不同的应用场景，I/O 调度策略也会影响 I/O 的读写性能，目前 Linux 系统中的 I/O 调度策略有4种，分别为 NOOP、CFQ、DEADLINE 和 ANTICIPATORY，默认为 CFQ。

**1. NOOP**

NOOP 算法的全写为 No Operation。该算法实现了最简单的 FIFO队列，所有 I/O 请求大致按照先来后到的顺序进行操作。之所以说“大致”，原因是 NOOP 在 FIFO 的基础上还做了相邻 I/O 请求的合并，并不是完全按照先进先出的规则满足 I/O 请求。

假设有如下的 I/O 请求序列：

```
100，500，101，10，56，1000 
```

NOOP 将会按照如下顺序满足 I/O 请求：

```
100(101)，500，10，56，1000
```

**2. CFQ**

CFQ 算法的全写为 Completely Fair Queuing。该算法的特点是按照 I/O 请求的地址进行排序，而不是按照先来后到的顺序进行响应。

假设有如下的 I/O 请求序列：

```
100，500，101，10，56，1000 
```

CFQ 将会按照如下顺序满足：

```
100，101，500，1000，10，56 
```

CFQ 是默认的磁盘调度算法，对于通用服务器来说是最好的选择。它试图均匀地分布对 I/O 带宽的访问。CFQ 为每个进程单独创建一个队列来管理该进程所产生的请求，也就是说，每个进程一个队列，各队列之间的调度使用时间片进行调度，以此来保证每个进程都能被很好地分配到 I/O 带宽。I/O 调度器每次执行一个进程的4次请求。在传统的 SAS 盘上，磁盘寻道花去了绝大多数的 I/O 响应时间。CFQ 的出发点是对 I/O 地址进行排序，以尽量少的磁盘旋转次数来满足尽可能多的 I/O 请求。在 CFQ 算法下，SAS 盘的吞吐量大大提高了。相比于 NOOP 的缺点是，先来的 I/O 请求并不一定能被满足，可能会出现“饿死”的情况。

**3. DEADLINE**

DEADLINE 在 CFQ 的基础上，解决了 I/O 请求“饿死”的极端情况。除了 CFQ 本身具有的 I/O 排序队列，DEADLINE 额外分别为读 I/O 和写 I/O 提供了 FIFO 队列。读 FIFO 队列的最大等待时间为500ms，写 FIFO 队列的最大等待时间为5s。FIFO 队列内的 I/O 请求优先级要比 CFQ 队列中的高，而读 FIFO 队列的优先级又比写 FIFO 队列的优先级高。优先级可以表示如下：

```
FIFO(Read) > FIFO(Write) > CFQ
```

**4. ANTICIPATORY**

CFQ 和 DEADLINE 考虑的焦点在于满足零散 I/O 请求上。对于连续的 I/O 请求，比如顺序读，并没有做优化。为了满足随机 I/O 和顺序 I/O 混合的场景，Linux 还支持 ANTICIPATORY 调度算法。ANTICIPATORY 在 DEADLINE 的基础上，为每个读 I/O 都设置了6ms的等待时间窗口。如果在6ms内 OS 收到了相邻位置的读 I/O 请求，就可以立即满足。ANTICIPATORY 算法通过增加等待时间来获得更高的性能，假设一个块设备只有一个物理查找磁头（例如一个单独的 SATA 硬盘），将多个随机的小写入流合并成一个大写入流（相当于将随机读写变顺序读写），通过这个原理来使用读取/写入的延时换取最大的读取/写入吞吐量。适用于大多数环境，特别是读取/写入较多的环境。

不同的磁盘调度算法（以及相应的 I/O 优化手段）对 Kafka 这类依赖磁盘运转的应用的影响很大，建议根据不同的业务需求来测试并选择合适的磁盘调度算法。

从文件系统层面分析，Kafka 操作的都是普通文件，并没有依赖于特定的文件系统，但是依然推荐使用 EXT4 或 XFS。尤其是对 XFS 而言，它通常有更好的性能，这种性能的提升主要影响的是 Kafka 的写入性能。

## 零拷贝

除了消息顺序追加、页缓存等技术，Kafka 还使用零拷贝（Zero-Copy）技术来进一步提升性能。所谓的零拷贝是指将数据直接从磁盘文件复制到网卡设备中，而不需要经由应用程序之手。零拷贝大大提高了应用程序的性能，减少了内核和用户模式之间的上下文切换。对 Linux 操作系统而言，零拷贝技术依赖于底层的 sendfile() 方法实现。对应于 Java 语言，FileChannal.transferTo() 方法的底层实现就是 sendfile() 方法。

单纯从概念上理解“零拷贝”比较抽象，这里简单地介绍一下它。考虑这样一种常用的情形：你需要将静态内容（类似图片、文件）展示给用户。这个情形就意味着需要先将静态内容从磁盘中复制出来放到一个内存 buf 中，然后将这个 buf 通过套接字（Socket）传输给用户，进而用户获得静态内容。这看起来再正常不过了，但实际上这是很低效的流程，我们把上面的这种情形抽象成下面的过程：

```
read(file, tmp_buf, len);
write(socket, tmp_buf, len);
```

首先调用 read() 将静态内容（这里假设为文件 A ）读取到 tmp_buf，然后调用 write() 将 tmp_buf 写入 Socket，如下图所示。



![5-23](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169edfde50dbacba)



在这个过程中，文件 A 经历了4次复制的过程：

1. 调用 read() 时，文件 A 中的内容被复制到了内核模式下的 Read Buffer 中。
2. CPU 控制将内核模式数据复制到用户模式下。
3. 调用 write() 时，将用户模式下的内容复制到内核模式下的 Socket Buffer 中。
4. 将内核模式下的 Socket Buffer 的数据复制到网卡设备中传送。

从上面的过程可以看出，数据平白无故地从内核模式到用户模式“走了一圈”，浪费了2次复制过程：第一次是从内核模式复制到用户模式；第二次是从用户模式再复制回内核模式，即上面4次过程中的第2步和第3步。而且在上面的过程中，内核和用户模式的上下文的切换也是4次。

如果采用了零拷贝技术，那么应用程序可以直接请求内核把磁盘中的数据传输给 Socket，如下图所示。



![5-24](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169edfe4f844fad4)



零拷贝技术通过 DMA（Direct Memory Access）技术将文件内容复制到内核模式下的 Read Buffer 中。不过没有数据被复制到 Socket Buffer，相反只有包含数据的位置和长度的信息的文件描述符被加到 Socket Buffer 中。DMA 引擎直接将数据从内核模式中传递到网卡设备（协议引擎）。这里数据只经历了2次复制就从磁盘中传送出去了，并且上下文切换也变成了2次。零拷贝是针对内核模式而言的，数据在内核模式下实现了零拷贝。

从第1节至本节主要讲述的是 Kafka 中与存储相关的知识点，既包含 Kafka 自身的日志格式、日志索引、日志清理等方面的内容，也包含底层物理存储相关的知识点。通过对这些内容的学习，相信读者对 Kafka 的一些核心机理有了比较深刻的认知。下面会讲述在存储层之上的 Kafka 的核心实现原理，这样可以让读者对 Kafka 的整理实现脉络有比较清晰的认知。

# 协议设计

在实际应用中，Kafka 经常被用作高性能、可扩展的消息中间件。Kafka 自定义了一组基于 TCP 的二进制协议，只要遵守这组协议的格式，就可以向 Kafka 发送消息，也可以从 Kafka 中拉取消息，或者做一些其他的事情，比如提交消费位移等。

在目前的 Kafka 2.0.0 中，一共包含了43种协议类型，每种协议类型都有对应的请求（Request）和响应（Response），它们都遵守特定的协议模式。每种类型的 Request 都包含相同结构的协议请求头（RequestHeader）和不同结构的协议请求体（RequestBody），如下图所示。



![6-1](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee097a36a2015)



协议请求头中包含4个域（Field）：api_key、api_version、correlation_id和client_id，这4个域对应的描述可以参考下表。

| 域（Field）    | 描述（Description）                                          |
| -------------- | ------------------------------------------------------------ |
| api_key        | API标识，比如PRODUCE、FETCH等分别表示发送消息和拉取消息的请求 |
| api_version    | API版本号                                                    |
| correlation_id | 由客户端指定的一个数字来唯一地标识这次请求的id，服务端在处理完请求后也会把同样的coorelation_id写到Response中，这样客户端就能把某个请求和响应对应起来了 |
| client_id      | 客户端id                                                     |



每种类型的 Response 也包含相同结构的协议响应头（ResponseHeader）和不同结构的响应体（ResponseBody），如下图所示。



![6-2](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee0b815640cbb)



协议响应头中只有一个 correlation_id，对应的释义可以参考上表中的相关描述。

细心的读者会发现不管是在第一张图中还是在第二张图中都有类似 int32、int16、string 的字样，它们用来表示当前域的数据类型。Kafka 中所有协议类型的 Request 和 Response 的结构都是具备固定格式的，并且它们都构建于多种基本数据类型之上。这些基本数据类型如下表所示。

| 类型（Type）    | 描述（Description）                                          |
| --------------- | ------------------------------------------------------------ |
| boolean         | 布尔类型，使用0和1分别代表false和true                        |
| int8            | 带符号整型，占8位，值在-27至27 - 1之间                       |
| int16           | 带符号整型，占16位，值在-215至215 - 1之间                    |
| int32           | 带符号整型，占32位，值在-231至231 - 1之间                    |
| int64           | 带符号整型，占64位，值在-263至263 - 1之间                    |
| unit32          | 无符号整型，占32位，值在0至232 - 1之间                       |
| varint          | 变长整型，值在- 231至231 - 1之间，使用ZigZag编码             |
| varlong         | 变长长整型，值在-263至263 - 1之间，使用ZigZag编码            |
| string          | 字符串类型。开头是一个int16类型的长度字段（非负数），代表字符串的长度N，后面包含N个UTF-8编码的字符 |
| nullable_string | 可为空的字符串类型。如果此类型的值为空，则用-1表示，其余情况同string类型一样 |
| bytes           | 表示一个字节序列。开头是一个int32类型的长度字段，代表后面字节序列的长度N，后面再跟N个字节 |
| nullable_bytes  | 表示一个可为空的字节序列，为空时用-1表示，其余情况同bytes    |
| records         | 表示Kafka中的一个消息序列，也可以看作nullable_bytes          |
| array           | 表示一个给定类型T的数组，也就是说，数组中包含若干T类型的实例。T可以是基础类型或基础类型组成的一个结构。该域开头的是一个int32类型的长度字段，代表T实例的个数为N，后面再跟N个T的实例。可用-1表示一个空的数组 |



下面就以最常见的消息发送和消息拉取的两种协议类型做细致的讲解。首先要讲述的是消息发送的协议类型，即 ProduceRequest/ProduceResponse，对应的api_key = 0，表示 PRODUCE。从 Kafka 建立之初，其所支持的协议类型就一直在增加，并且对特定的协议类型而言，内部的组织结构也并非一成不变。以 ProduceRequest/ProduceResponse 为例，截至目前就经历了7个版本（V0～V6）的变迁。下面就以最新版本（V6，即api_version = 6）的结构为例来做细致的讲解。ProduceRequest 的组织结构如下图所示。



![6-3](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee0fe16bd2f4e)



除了请求头中的4个域，其余 ProduceRequest 请求体中各个域的含义如下表所示。

| 域（Field）      | 类 型           | 描述（Description）                                          |
| ---------------- | --------------- | ------------------------------------------------------------ |
| transactional_id | nullable_string | 事务id，从Kafka 0.11.0开始支持事务。如果不使用事务的功能，那么该域的值为null |
| acks             | int16           | 对应客户端参数acks                                           |
| timeout          | int32           | 请求超时时间，对应客户端参数request.timeout.ms，默认值为30000，即30秒 |
| topic_data       | array           | 代表ProduceRequest中所要发送的数据集合。以主题名称分类，主题中再以分区分类。注意这个域是数组类型 |
| topic            | string          | 主题名称                                                     |
| data             | array           | 与主题对应的数据，注意这个域也是数组类型                     |
| partition        | int32           | 分区编号                                                     |
| record_set       | records         | 与分区对应的数据                                             |



如果我们了解 KafkaProducer 的[原理](https://juejin.im/book/5c7d467e5188251b9156fdc0/section/5c7d537c6fb9a049ad77c949)，那么我们应该了解到消息累加器 RecordAccumulator 中的消息是以 <分区, Deque< ProducerBatch>> 的形式进行缓存的，之后由 Sender 线程转变成 <Node, List<ProducerBatch>> 的形式，针对每个 Node，Sender 线程在发送消息前会将对应的 List<ProducerBatch> 形式的内容转变成 ProduceRequest 的具体结构。List<ProducerBatch> 中的内容首先会按照主题名称进行分类（对应 ProduceRequest 中的域 topic），然后按照分区编号进行分类（对应 ProduceRequest 中的域 partition），分类之后的 ProducerBatch 集合就对应 ProduceRequest 中的域 record_set。

从另一个角度来讲，每个分区中的消息是顺序追加的，那么在客户端中按照分区归纳好之后就可以省去在服务端中转换的操作了，这样将负载的压力分摊给了客户端，从而使服务端可以专注于它的分内之事，如此也可以提升整体的性能。

如果参数 acks 设置非0值，那么生产者客户端在发送 ProduceRequest 请求之后就需要（异步）等待服务端的响应 ProduceResponse。对 ProduceResponse 而言，V6 版本中 ProduceResponse 的组织结构如下图所示。



![img](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee199e65f174a)



除了响应头中的 correlation_id，其余 ProduceResponse 各个域的含义如下表所示。

| 域（Field）         | 类 型  | 描述（Description）                                          |
| ------------------- | ------ | ------------------------------------------------------------ |
| throttle_time_ms    | int32  | 如果超过了配额（quota）限制则需要延迟该请求的处理时间。如果没有配置配额，那么该字段的值为0 |
| responses           | array  | 代表ProudceResponse中要返回的数据集合。同样按照主题分区的粒度进行划分，注意这个域是一个数组类型 |
| topic               | string | 主题名称                                                     |
| partition_responses | array  | 主题中所有分区的响应，注意这个域也是一个数组类型             |
| partition           | int32  | 分区编号                                                     |
| error_code          | int16  | 错误码，用来标识错误类型。目前版本的错误码有74种，具体可以参考[这里](http://kafka.apache.org/protocol.html#protocol_error_codes) |
| base_offset         | int64  | 消息集的起始偏移量                                           |
| log_append_time     | int64  | 消息写入broker端的时间                                       |
| log_start_offset    | int64  | 所在分区的起始偏移量                                         |



消息追加是针对单个分区而言的，那么响应也是针对分区粒度来进行划分的，这样 ProduceRequest 和 ProduceResponse 做到了一一对应。

我们再来了解一下拉取消息的协议类型，即 FetchRequest/FetchResponse，对应的 api_key = 1，表示 FETCH。截至目前，FetchRequest/FetchResponse 一共历经了9个版本（V0～V8）的变迁，下面就以最新版本（V8）的结构为例来做细致的讲解。FetchRequest 的组织结构如下图所示。



![6-5](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee1b0f511cbec)



除了请求头中的4个域，其余 FetchRequest 中各个域的含义如下表所示。

| 域（Field）           | 类 型  | 描述（Description）                                          |
| --------------------- | ------ | ------------------------------------------------------------ |
| replica_id            | int32  | 用来指定副本的brokerId，这个域是用于follower副本向leader副本发起FetchRequest请求的，对于普通消费者客户端而言，这个域的值保持为-1 |
| max_wait_time         | int32  | 和消费者客户端参数fetch.max.wait.ms对应，默认值为500         |
| min_bytes             | int32  | 和消费者客户端参数fetch.min.bytes对应，默认值为1             |
| max_bytes             | int32  | 和消费者客户端参数fetch.max.bytes对应，默认值为52428800，即50MB |
| isolation_level       | int8   | 和消费者客户端参数isolation.level对应，默认值为“read_uncommitted”，可选值为“read_committed”，这两个值分别对应本域的0和1的值 |
| session_id            | int32  | fetch session的id，详细参考下面的释义                        |
| epoch                 | int32  | fetch session的epoch纪元，它和seesion_id一样都是fetch session的元数据，详细参考下面的释义 |
| topics                | array  | 所要拉取的主题信息，注意这是一个数组类型                     |
| topic                 | string | 主题名称                                                     |
| partitions            | array  | 分区信息，注意这也是一个数组类型                             |
| partition             | int32  | 分区编号                                                     |
| fetch_offset          | int64  | 指定从分区的哪个位置开始读取消息。如果是follower副本发起的请求，那么这个域可以看作当前follower副本的LEO |
| log_start_offset      | int64  | 该域专门用于follower副本发起的FetchRequest请求，用来指明分区的起始偏移量。对于普通消费者客户端而言这个值保持为-1 |
| max_bytes             | int32  | 注意在最外层中也包含同样名称的域，但是两个所代表的含义不同，这里是针对单个分区而言的，和消费者客户端参数max.partition.fetch.bytes对应，默认值为1048576，即1MB |
| forgotten_topics_data | array  | 数组类型，指定从fetch session中指定要去除的拉取信息，详细参考下面的释义 |
| topic                 | string | 主题名称                                                     |
| partitions            | array  | 数组类型，表示分区编号的集合                                 |



不管是 follower 副本还是普通的消费者客户端，如果要拉取某个分区中的消息，就需要指定详细的拉取信息，也就是需要设定 partition、fetch_offset、log_start_offset 和 max_bytes 这4个域的具体值，那么对每个分区而言，就需要占用 4B+8B+8B+4B = 24B 的空间。

一般情况下，不管是 follower 副本还是普通的消费者，它们的订阅信息是长期固定的。也就是说，FetchRequest 中的 topics 域的内容是长期固定的，只有在拉取开始时或发生某些异常时会有所变动。FetchRequest 请求是一个非常频繁的请求，如果要拉取的分区数有很多，比如有1000个分区，那么在网络上频繁交互 FetchRequest 时就会有固定的 1000×24B ≈ 24KB 的字节的内容在传动，如果可以将这 24KB 的状态保存起来，那么就可以节省这部分所占用的带宽。

Kafka 从 1.1.0 版本开始针对 FetchRequest 引入了 session_id、epoch 和 forgotten_ topics_data 等域，session_id 和 epoch 确定一条拉取链路的 fetch session，当 session 建立或变更时会发送全量式的 FetchRequest，所谓的全量式就是指请求体中包含所有需要拉取的分区信息；当 session 稳定时则会发送增量式的 FetchRequest 请求，里面的 topics 域为空，因为 topics 域的内容已经被缓存在了 session 链路的两侧。如果需要从当前 fetch session 中取消对某些分区的拉取订阅，则可以使用 forgotten_topics_data 字段来实现。

这个改进在大规模（有大量的分区副本需要及时同步）的 Kafka 集群中非常有用，它可以提升集群间的网络带宽的有效使用率。不过对客户端而言效果不是那么明显，一般情况下单个客户端不会订阅太多的分区，不过总体上这也是一个很好的优化改进。

与 FetchRequest 对应的 FetchResponse 的组织结构（V8版本）可以参考下图。



![6-6](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee2037ac4c4e9)



FetchResponse 结构中的域也很多，它主要分为4层，第1层包含 throttle_time_ms、error_code、session_id 和 responses，前面3个域都见过，其中 session_id 和 FetchRequest 中的 session_id 对应。responses 是一个数组类型，表示响应的具体内容，也就是 FetchResponse 结构中的第2层，具体地细化到每个分区的响应。第3层中包含分区的元数据信息（partition、error_code 等）及具体的消息内容（record_set），aborted_transactions 和事务相关。

除了 Kafka 客户端开发人员，绝大多数的其他开发人员基本接触不到或不需要接触具体的协议，那么我们为什么还要了解它们呢？其实，协议的具体定义可以让我们从另一个角度来了解 Kafka 的本质。以 PRODUCE 和 FETCH 为例，从协议结构中就可以看出消息的写入和拉取消费都是细化到每一个分区层级的。并且，通过了解各个协议版本变迁的细节也能够从侧面了解 Kafka 变迁的历史，在变迁的过程中遇到过哪方面的瓶颈，又采取哪种优化手段，比如 FetchRequest 中的 session_id 的引入。

由于篇幅限制，笔者并不打算列出所有Kafka协议类型的细节。不过对于 Kafka 协议的介绍并没有到此为止，后面的章节中会针对其余41种类型的部分协议进行相关的介绍，完整的协议类型列表可以参考[官方文档](http://kafka.apache.org/protocol.html#protocol_api_keys)。Kafka 中最枯燥的莫过于它的上百个参数、几百个监控指标和几十种请求协议，掌握这三者的“套路”，相信你会对 Kafka 有更深入的理解。

# 时间轮

Kafka 中存在大量的延时操作，比如延时生产、延时拉取和延时删除等。Kafka 并没有使用 JDK 自带的 Timer 或 DelayQueue 来实现延时的功能，而是基于时间轮的概念自定义实现了一个用于延时功能的定时器（SystemTimer）。JDK 中 Timer 和 DelayQueue 的插入和删除操作的平均时间复杂度为 O(nlogn) 并不能满足 Kafka 的高性能要求，而基于时间轮可以将插入和删除操作的时间复杂度都降为 O(1)。时间轮的应用并非 Kafka 独有，其应用场景还有很多，在 Netty、Akka、Quartz、ZooKeeper 等组件中都存在时间轮的踪影。



![6-7](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee33722ea2b85)



如上图所示，Kafka 中的时间轮（TimingWheel）是一个存储定时任务的环形队列，底层采用数组实现，数组中的每个元素可以存放一个定时任务列表（TimerTaskList）。TimerTaskList 是一个环形的双向链表，链表中的每一项表示的都是定时任务项（TimerTaskEntry），其中封装了真正的定时任务（TimerTask）。

时间轮由多个时间格组成，每个时间格代表当前时间轮的基本时间跨度（tickMs）。时间轮的时间格个数是固定的，可用 wheelSize 来表示，那么整个时间轮的总体时间跨度（interval）可以通过公式 tickMs×wheelSize 计算得出。

时间轮还有一个表盘指针（currentTime），用来表示时间轮当前所处的时间，currentTime 是 tickMs 的整数倍。currentTime 可以将整个时间轮划分为到期部分和未到期部分，currentTime 当前指向的时间格也属于到期部分，表示刚好到期，需要处理此时间格所对应的 TimerTaskList 中的所有任务。

若时间轮的 tickMs 为 1ms 且 wheelSize 等于20，那么可以计算得出总体时间跨度 interval 为20ms。

初始情况下表盘指针 currentTime 指向时间格0，此时有一个定时为2ms的任务插进来会存放到时间格为2的 TimerTaskList 中。随着时间的不断推移，指针 currentTime 不断向前推进，过了2ms之后，当到达时间格2时，就需要将时间格2对应的 TimeTaskList 中的任务进行相应的到期操作。此时若又有一个定时为8ms的任务插进来，则会存放到时间格10中，currentTime 再过8ms后会指向时间格10。

如果同时有一个定时为19ms的任务插进来怎么办？新来的 TimerTaskEntry 会复用原来的 TimerTaskList，所以它会插入原本已经到期的时间格1。总之，整个时间轮的总体跨度是不变的，随着指针 currentTime 的不断推进，当前时间轮所能处理的时间段也在不断后移，总体时间范围在 currentTime 和 currentTime+interval 之间。

如果此时有一个定时为 350ms 的任务该如何处理？直接扩充 wheelSize 的大小？Kafka 中不乏几万甚至几十万毫秒的定时任务，这个 wheelSize 的扩充没有底线，就算将所有的定时任务的到期时间都设定一个上限，比如100万毫秒，那么这个 wheelSize 为100万毫秒的时间轮不仅占用很大的内存空间，而且也会拉低效率。Kafka 为此引入了层级时间轮的概念，当任务的到期时间超过了当前时间轮所表示的时间范围时，就会尝试添加到上层时间轮中。



![6-8](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee348646dd996)



如上图所示，复用之前的案例，第一层的时间轮 tickMs=1ms、wheelSize=20、interval=20ms。第二层的时间轮的 tickMs 为第一层时间轮的 interval，即20ms。每一层时间轮的 wheelSize 是固定的，都是20，那么第二层的时间轮的总体时间跨度 interval 为400ms。以此类推，这个400ms也是第三层的 tickMs 的大小，第三层的时间轮的总体时间跨度为8000ms。

对于之前所说的 350ms 的定时任务，显然第一层时间轮不能满足条件，所以就升级到第二层时间轮中，最终被插入第二层时间轮中时间格17所对应的 TimerTaskList。如果此时又有一个定时为 450ms 的任务，那么显然第二层时间轮也无法满足条件，所以又升级到第三层时间轮中，最终被插入第三层时间轮中时间格1的 TimerTaskList。注意到在到期时间为 [400ms,800ms) 区间内的多个任务（比如 446ms、455ms 和 473ms 的定时任务）都会被放入第三层时间轮的时间格1，时间格1对应的 TimerTaskList 的超时时间为 400ms。

随着时间的流逝，当此 TimerTaskList 到期之时，原本定时为 450ms 的任务还剩下 50ms 的时间，还不能执行这个任务的到期操作。这里就有一个时间轮降级的操作，会将这个剩余时间为 50ms 的定时任务重新提交到层级时间轮中，此时第一层时间轮的总体时间跨度不够，而第二层足够，所以该任务被放到第二层时间轮到期时间为 [40ms,60ms) 的时间格中。再经历 40ms 之后，此时这个任务又被“察觉”，不过还剩余 10ms，还是不能立即执行到期操作。所以还要再有一次时间轮的降级，此任务被添加到第一层时间轮到期时间为 [10ms,11ms) 的时间格中，之后再经历 10ms 后，此任务真正到期，最终执行相应的到期操作。

设计源于生活。我们常见的钟表就是一种具有三层结构的时间轮，第一层时间轮 tickMs=1s、wheelSize=60、interval=1min，此为秒钟；第二层 tickMs=1min、wheelSize=60、interval=1hour，此为分钟；第三层 tickMs=1hour、wheelSize=12、interval=12hours，此为时钟。

在 Kafka 中，第一层时间轮的参数同上面的案例一样：tickMs=1ms、wheelSize=20、interval=20ms，各个层级的 wheelSize 也固定为20，所以各个层级的 tickMs 和 interval 也可以相应地推算出来。Kafka 在具体实现时间轮 TimingWheel 时还有一些小细节：

- TimingWheel 在创建的时候以当前系统时间为第一层时间轮的起始时间（startMs），这里的当前系统时间并没有简单地调用 System.currentTimeMillis()，而是调用了 Time.SYSTEM.hiResClockMs，这是因为 currentTimeMillis() 方法的时间精度依赖于操作系统的具体实现，有些操作系统下并不能达到毫秒级的精度，而 Time.SYSTEM.hiResClockMs 实质上采用了 System.nanoTime()/1_000_000 来将精度调整到毫秒级。
- TimingWheel 中的每个双向环形链表 TimerTaskList 都会有一个哨兵节点（sentinel），引入哨兵节点可以简化边界条件。哨兵节点也称为哑元节点（dummy node），它是一个附加的链表节点，该节点作为第一个节点，它的值域中并不存储任何东西，只是为了操作的方便而引入的。如果一个链表有哨兵节点，那么线性表的第一个元素应该是链表的第二个节点。
- 除了第一层时间轮，其余高层时间轮的起始时间（startMs）都设置为创建此层时间轮时前面第一轮的 currentTime。每一层的 currentTime 都必须是 tickMs 的整数倍，如果不满足则会将 currentTime 修剪为 tickMs 的整数倍，以此与时间轮中的时间格的到期时间范围对应起来。修剪方法为：currentTime = startMs - (startMs % tickMs)。currentTime 会随着时间推移而推进，但不会改变为 tickMs 的整数倍的既定事实。若某一时刻的时间为 timeMs，那么此时时间轮的 currentTime = timeMs - (timeMs % tickMs)，时间每推进一次，每个层级的时间轮的 currentTime 都会依据此公式执行推进。
- Kafka 中的定时器只需持有 TimingWheel 的第一层时间轮的引用，并不会直接持有其他高层的时间轮，但每一层时间轮都会有一个引用（overflowWheel）指向更高一层的应用，以此层级调用可以实现定时器间接持有各个层级时间轮的引用。

关于时间轮的细节就描述到这里，各个组件中对时间轮的实现大同小异。读者读到这里是否会好奇文中一直描述的一个情景—“随着时间的流逝”或“随着时间的推移”，那么在 Kafka 中到底是怎么推进时间的呢？类似采用 JDK 中的 scheduleAtFixedRate 来每秒推进时间轮？显然这样并不合理，TimingWheel 也失去了大部分意义。

Kafka 中的定时器借了 JDK 中的 DelayQueue 来协助推进时间轮。具体做法是对于每个使用到的 TimerTaskList 都加入 DelayQueue，“每个用到的 TimerTaskList”特指非哨兵节点的定时任务项 TimerTaskEntry 对应的 TimerTaskList。DelayQueue 会根据 TimerTaskList 对应的超时时间 expiration 来排序，最短 expiration 的 TimerTaskList 会被排在 DelayQueue 的队头。

Kafka 中会有一个线程来获取 DelayQueue 中到期的任务列表，有意思的是这个线程所对应的名称叫作“ExpiredOperationReaper”，可以直译为“过期操作收割机”，和第4节的“SkimpyOffsetMap”的取名有异曲同工之妙。当“收割机”线程获取 DelayQueue 中超时的任务列表 TimerTaskList 之后，既可以根据 TimerTaskList 的 expiration 来推进时间轮的时间，也可以就获取的 TimerTaskList 执行相应的操作，对里面的 TimerTaskEntry 该执行过期操作的就执行过期操作，该降级时间轮的就降级时间轮。

读到这里或许会感到困惑，开头明确指明的 DelayQueue 不适合 Kafka 这种高性能要求的定时任务，为何这里还要引入 DelayQueue 呢？注意对定时任务项 TimerTaskEntry 的插入和删除操作而言，TimingWheel时间复杂度为 O(1)，性能高出 DelayQueue 很多，如果直接将 TimerTaskEntry 插入 DelayQueue，那么性能显然难以支撑。就算我们根据一定的规则将若干 TimerTaskEntry 划分到 TimerTaskList 这个组中，然后将 TimerTaskList 插入 DelayQueue，如果在 TimerTaskList 中又要多添加一个 TimerTaskEntry 时该如何处理呢？对 DelayQueue 而言，这类操作显然变得力不从心。

分析到这里可以发现，Kafka 中的 TimingWheel 专门用来执行插入和删除 TimerTaskEntry 的操作，而 DelayQueue 专门负责时间推进的任务。试想一下，DelayQueue 中的第一个超时任务列表的 expiration 为 200ms，第二个超时任务为 840ms，这里获取 DelayQueue 的队头只需要 O(1) 的时间复杂度（获取之后 DelayQueue 内部才会再次切换出新的队头）。如果采用每秒定时推进，那么获取第一个超时的任务列表时执行的200次推进中有199次属于“空推进”，而获取第二个超时任务时又需要执行639次“空推进”，这样会无故空耗机器的性能资源，这里采用 DelayQueue 来辅助以少量空间换时间，从而做到了“精准推进”。Kafka 中的定时器真可谓“知人善用”，用 TimingWheel 做最擅长的任务添加和删除操作，而用 DelayQueue 做最擅长的时间推进工作，两者相辅相成。

## 延时操作

如果在使用生产者客户端发送消息的时候将 acks 参数设置为-1，那么就意味着需要等待 ISR 集合中的所有副本都确认收到消息之后才能正确地收到响应的结果，或者捕获超时异常。

如下面3张图所示，假设某个分区有3个副本：leader、follower1 和 follower2，它们都在分区的 ISR 集合中。为了简化说明，这里我们不考虑 ISR 集合伸缩的情况。Kafka 在收到客户端的生产请求（ProduceRequest）后，将消息3和消息4写入 leader 副本的本地日志文件。由于客户端设置了 acks 为-1，那么需要等到 follower1 和 follower2 两个副本都收到消息3和消息4后才能告知客户端正确地接收了所发送的消息。如果在一定的时间内，follower1 副本或 follower2 副本没能够完全拉取到消息3和消息4，那么就需要返回超时异常给客户端。生产请求的超时时间由参数 request.timeout.ms 配置，默认值为30000，即30s。



![6-9](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee3e1864e09ba)





![6-10](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee3e3b9bb8836)





![6-11](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee43a5abc320a)



那么这里等待消息3和消息4写入 follower1 副本和 follower2 副本，并返回相应的响应结果给客户端的动作是由谁来执行的呢？在将消息写入 leader 副本的本地日志文件之后，Kafka 会创建一个延时的生产操作（DelayedProduce），用来处理消息正常写入所有副本或超时的情况，以返回相应的响应结果给客户端。

在 Kafka 中有多种延时操作，比如前面提及的延时生产，还有延时拉取（DelayedFetch）、延时数据删除（DelayedDeleteRecords）等。延时操作需要延时返回响应的结果，首先它必须有一个超时时间（delayMs），如果在这个超时时间内没有完成既定的任务，那么就需要强制完成以返回响应结果给客户端。其次，延时操作不同于定时操作，定时操作是指在特定时间之后执行的操作，而延时操作可以在所设定的超时时间之前完成，所以延时操作能够支持外部事件的触发。

就延时生产操作而言，它的外部事件是所要写入消息的某个分区的 HW（高水位）发生增长。也就是说，随着 follower 副本不断地与 leader 副本进行消息同步，进而促使HW进一步增长，HW 每增长一次都会检测是否能够完成此次延时生产操作，如果可以就执行以此返回响应结果给客户端；如果在超时时间内始终无法完成，则强制执行。

延时操作创建之后会被加入延时操作管理器（DelayedOperationPurgatory）来做专门的处理。延时操作有可能会超时，每个延时操作管理器都会配备一个定时器（SystemTimer）来做超时管理，定时器的底层就是采用时间轮（TimingWheel）实现的。在第7节中提及时间轮的轮转是靠“收割机”线程 ExpiredOperationReaper 来驱动的，这里的“收割机”线程就是由延时操作管理器启动的。也就是说，定时器、“收割机”线程和延时操作管理器都是一一对应的。延时操作需要支持外部事件的触发，所以还要配备一个监听池来负责监听每个分区的外部事件—查看是否有分区的HW发生了增长。另外需要补充的是，ExpiredOperationReaper 不仅可以推进时间轮，还会定期清理监听池中已完成的延时操作。

> 题外话：在 Kafka 中将延时操作管理器称为 DelayedOperationPurgatory，这个名称比之前提及的 ExpiredOperationReaper 和 SkimpyOffsetMap 的取名更有意思。Purgatory 直译为“炼狱”，但丁的《神曲》中有炼狱的相关描述。炼狱共有9层，在生前犯有罪过但可以得到宽恕的灵魂，按照人类的七宗罪（傲慢、忌妒、愤怒、怠惰、贪财、贪食、贪色）分别在这里修炼洗涤，而后一层层升向光明和天堂。Kafka中采用这一称谓，将延时操作看作需要被洗涤的灵魂，在炼狱中慢慢修炼，等待解脱升入天堂（即完成延时操作）。



![6-12](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee3fa5c0ecc50)



上图描绘了客户端在请求写入消息到收到响应结果的过程中与延时生产操作相关的细节，在了解相关的概念之后应该比较容易理解：如果客户端设置的 acks 参数不为-1，或者没有成功的消息写入，那么就直接返回结果给客户端，否则就需要创建延时生产操作并存入延时操作管理器，最终要么由外部事件触发，要么由超时触发而执行。



![6-13](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee41212d888d1)



有延时生产就有延时拉取。以上图为例，两个 follower 副本都已经拉取到了 leader 副本的最新位置，此时又向 leader 副本发送拉取请求，而 leader 副本并没有新的消息写入，那么此时 leader 副本该如何处理呢？可以直接返回空的拉取结果给 follower 副本，不过在 leader 副本一直没有新消息写入的情况下，follower 副本会一直发送拉取请求，并且总收到空的拉取结果，这样徒耗资源，显然不太合理。

Kafka 选择了延时操作来处理这种情况。Kafka 在处理拉取请求时，会先读取一次日志文件，如果收集不到足够多（fetchMinBytes，由参数 fetch.min.bytes 配置，默认值为1）的消息，那么就会创建一个延时拉取操作（DelayedFetch）以等待拉取到足够数量的消息。当延时拉取操作执行时，会再读取一次日志文件，然后将拉取结果返回给 follower 副本。延时拉取操作也会有一个专门的延时操作管理器负责管理，大体的脉络与延时生产操作相同，不再赘述。如果拉取进度一直没有追赶上leader副本，那么在拉取 leader 副本的消息时一般拉取的消息大小都会不小于 fetchMinBytes，这样 Kafka 也就不会创建相应的延时拉取操作，而是立即返回拉取结果。

延时拉取操作同样是由超时触发或外部事件触发而被执行的。超时触发很好理解，就是等到超时时间之后触发第二次读取日志文件的操作。外部事件触发就稍复杂了一些，因为拉取请求不单单由 follower 副本发起，也可以由消费者客户端发起，两种情况所对应的外部事件也是不同的。如果是 follower 副本的延时拉取，它的外部事件就是消息追加到了 leader 副本的本地日志文件中；如果是消费者客户端的延时拉取，它的外部事件可以简单地理解为HW的增长。

目前版本的 Kafka 还引入了事务的概念，对于消费者或 follower 副本而言，其默认的事务隔离级别为“read_uncommitted”。不过消费者可以通过客户端参数 isolation.level 将事务隔离级别设置为“read_committed”（注意：follower 副本不可以将事务隔离级别修改为这个值），这样消费者拉取不到生产者已经写入却尚未提交的消息。对应的消费者的延时拉取，它的外部事件实际上会切换为由 LSO（LastStableOffset）的增长来触发。LSO 是 HW 之前除去未提交的事务消息的最大偏移量，LSO≤HW，有关事务的内容可以分别参考后面的章节。

本节主要讲述与日志（消息）存储有关的延时生产和延时拉取的操作，至于其他类型的延时操作就不一一介绍了，不过在讲解到相关内容时会做相应的阐述。

# 控制器

在 Kafka 集群中会有一个或多个 broker，其中有一个 broker 会被选举为控制器（Kafka Controller），它负责管理整个集群中所有分区和副本的状态。当某个分区的 leader 副本出现故障时，由控制器负责为该分区选举新的 leader 副本。当检测到某个分区的 ISR 集合发生变化时，由控制器负责通知所有broker更新其元数据信息。当使用 kafka-topics.sh 脚本为某个 topic 增加分区数量时，同样还是由控制器负责分区的重新分配。

## 控制器的选举及异常恢复

Kafka 中的控制器选举工作依赖于 ZooKeeper，成功竞选为控制器的 broker 会在 ZooKeeper 中创建 /controller 这个临时（EPHEMERAL）节点，此临时节点的内容参考如下：

```
{"version":1,"brokerid":0,"timestamp":"1529210278988"}
```

其中 version 在目前版本中固定为1，brokerid 表示成为控制器的 broker 的 id 编号，timestamp 表示竞选成为控制器时的时间戳。

在任意时刻，集群中有且仅有一个控制器。每个 broker 启动的时候会去尝试读取 /controller 节点的 brokerid 的值，如果读取到 brokerid 的值不为-1，则表示已经有其他 broker 节点成功竞选为控制器，所以当前 broker 就会放弃竞选；如果 ZooKeeper 中不存在 /controller 节点，或者这个节点中的数据异常，那么就会尝试去创建 /controller 节点。当前 broker 去创建节点的时候，也有可能其他 broker 同时去尝试创建这个节点，只有创建成功的那个 broker 才会成为控制器，而创建失败的 broker 竞选失败。每个 broker 都会在内存中保存当前控制器的 brokerid 值，这个值可以标识为 activeControllerId。

ZooKeeper 中还有一个与控制器有关的 /controller_epoch 节点，这个节点是持久（PERSISTENT）节点，节点中存放的是一个整型的 controller_epoch 值。controller_epoch 用于记录控制器发生变更的次数，即记录当前的控制器是第几代控制器，我们也可以称之为“控制器的纪元”。

controller_epoch 的初始值为1，即集群中第一个控制器的纪元为1，当控制器发生变更时，每选出一个新的控制器就将该字段值加1。每个和控制器交互的请求都会携带 controller_epoch 这个字段，如果请求的 controller_epoch 值小于内存中的 controller_epoch 值，则认为这个请求是向已经过期的控制器所发送的请求，那么这个请求会被认定为无效的请求。如果请求的 controller_epoch 值大于内存中的 controller_epoch 值，那么说明已经有新的控制器当选了。由此可见，Kafka 通过 controller_epoch 来保证控制器的唯一性，进而保证相关操作的一致性。

具备控制器身份的 broker 需要比其他普通的 broker 多一份职责，具体细节如下：

- 监听分区相关的变化。为 ZooKeeper 中的 /admin/reassign_partitions 节点注册 PartitionReassignmentHandler，用来处理分区重分配的动作。为 ZooKeeper 中的 /isr_change_notification 节点注册 IsrChangeNotificetionHandler，用来处理 ISR 集合变更的动作。为 ZooKeeper 中的 /admin/preferred-replica-election 节点添加 PreferredReplicaElectionHandler，用来处理优先副本的选举动作。
- 监听主题相关的变化。为 ZooKeeper 中的 /brokers/topics 节点添加 TopicChangeHandler，用来处理主题增减的变化；为 ZooKeeper中 的 /admin/delete_topics 节点添加 TopicDeletionHandler，用来处理删除主题的动作。
- 监听 broker 相关的变化。为 ZooKeeper 中的 /brokers/ids 节点添加 BrokerChangeHandler，用来处理 broker 增减的变化。
- 从 ZooKeeper 中读取获取当前所有与主题、分区及broker有关的信息并进行相应的管理。对所有主题对应的 ZooKeeper中的 /brokers/topics/<topic> 节点添加 PartitionModificationsHandler，用来监听主题中的分区分配变化。
- 启动并管理分区状态机和副本状态机。
- 更新集群的元数据信息。
- 如果参数 auto.leader.rebalance.enable 设置为 true，则还会开启一个名为“auto-leader-rebalance-task”的定时任务来负责维护分区的优先副本的均衡。

控制器在选举成功之后会读取 ZooKeeper 中各个节点的数据来初始化上下文信息（ControllerContext），并且需要管理这些上下文信息。比如为某个主题增加了若干分区，控制器在负责创建这些分区的同时要更新上下文信息，并且需要将这些变更信息同步到其他普通的 broker 节点中。

不管是监听器触发的事件，还是定时任务触发的事件，或者是其他事件（比如 ControlledShutdown）都会读取或更新控制器中的上下文信息，那么这样就会涉及多线程间的同步。如果单纯使用锁机制来实现，那么整体的性能会大打折扣。针对这一现象，Kafka 的控制器使用单线程基于事件队列的模型，将每个事件都做一层封装，然后按照事件发生的先后顺序暂存到 LinkedBlockingQueue 中，最后使用一个专用的线程（ControllerEventThread）按照 FIFO（First Input First Output，先入先出）的原则顺序处理各个事件，这样不需要锁机制就可以在多线程间维护线程安全，具体可以参考下图。



![6-14](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee56132207c2c)



在 Kafka 的早期版本中，并没有采用 Kafka Controller 这样一个概念来对分区和副本的状态进行管理，而是依赖于 ZooKeeper，每个 broker 都会在 ZooKeeper 上为分区和副本注册大量的监听器（Watcher）。当分区或副本状态变化时，会唤醒很多不必要的监听器，这种严重依赖 ZooKeeper 的设计会有脑裂、羊群效应，以及造成 ZooKeeper 过载的隐患（旧版的消费者客户端存在同样的问题）。

在目前的新版本的设计中，只有 Kafka Controller 在 ZooKeeper 上注册相应的监听器，其他的 broker 极少需要再监听 ZooKeeper 中的数据变化，这样省去了很多不必要的麻烦。不过每个 broker 还是会对 /controller 节点添加监听器，以此来监听此节点的数据变化（ControllerChangeHandler）。

当 /controller 节点的数据发生变化时，每个 broker 都会更新自身内存中保存的 activeControllerId。如果 broker 在数据变更前是控制器，在数据变更后自身的 brokerid 值与新的 activeControllerId 值不一致，那么就需要“退位”，关闭相应的资源，比如关闭状态机、注销相应的监听器等。有可能控制器由于异常而下线，造成 /controller 这个临时节点被自动删除；也有可能是其他原因将此节点删除了。

当 /controller 节点被删除时，每个 broker 都会进行选举，如果 broker 在节点被删除前是控制器，那么在选举前还需要有一个“退位”的动作。如果有特殊需要，则可以手动删除 /controller 节点来触发新一轮的选举。当然关闭控制器所对应的 broker，以及手动向 /controller 节点写入新的 brokerid 的所对应的数据，同样可以触发新一轮的选举。

## 优雅关闭

如何优雅地关闭 Kafka？笔者在做测试的时候经常性使用 jps（或者 ps ax）配合 kill -9 的方式来快速关闭 Kafka broker 的服务进程，显然 kill -9 这种“强杀”的方式并不够优雅，它并不会等待 Kafka 进程合理关闭一些资源及保存一些运行数据之后再实施关闭动作。在有些场景中，用户希望主动关闭正常运行的服务，比如更换硬件、操作系统升级、修改 Kafka 配置等。如果依然使用上述方式关闭就略显粗暴。

那么合理的操作应该是什么呢？Kafka 自身提供了一个脚本工具，就是存放在其 bin 目录下的 kafka-server-stop.sh，这个脚本的内容非常简单，具体内容如下：

```
PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')

if [ -z "$PIDS" ]; then
  echo "No kafka server to stop"
  exit 1
else 
  kill -s TERM $PIDS
fi
```

可以看出 kafka-server-stop.sh 首先通过 ps ax 的方式找出正在运行 Kafka 的进程号 PIDS，然后使用 kill -s TERM $PIDS 的方式来关闭。但是这个脚本在很多时候并不奏效，这一点与 ps 命令有关系。在 Linux 操作系统中，ps 命令限制输出的字符数不得超过页大小 PAGE_SIZE，一般 CPU 的内存管理单元（Memory Management Unit，简称 MMU）的 PAGE_SIZE 为4096。也就是说，ps 命令的输出的字符串长度限制在4096内，这会有什么问题呢？我们使用 ps ax 命令来输出与 Kafka 进程相关的信息，如下图所示。



![6-15](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee5a360848e85)



细心的读者可以留意到白色部分中的信息并没有打印全，因为已经达到了4096的字符数的限制。而且打印的信息里面也没有 kafka-server-stop.sh 中 ps ax | grep -i 'kafka.Kafka' 所需要的“kafka.Kafka”这个关键字段，因为这个关键字段在4096个字符的范围之外。与Kafka进程有关的输出信息太长，所以 kafka-server-stop.sh 脚本在很多情况下并不会奏效。

> 注意要点：Kafka 服务启动的入口就是 kafka.Kafka，采用 Scala 语言编写 object。

那么怎么解决这种问题呢？我们先来看一下ps命令的相关源码（Linux 2.6.x 源码的 /fs/proc/base.c 文件中的部分内容）：

```
static int proc_pid_cmdline(struct task_struct *task, char * buffer)
{
   int res = 0;
   unsigned int len;
   struct mm_struct *mm = get_task_mm(task);
   if (!mm)
      goto out;
   if (!mm->arg_end)
      goto out_mm;   /* Shh! No looking before we're done */

   len = mm->arg_end - mm->arg_start;
 
   if (len > PAGE_SIZE)
      len = PAGE_SIZE;
 
   res = access_process_vm(task, mm->arg_start, buffer, len, 0);
（....省略若干....）
```

我们可以看到 ps 的输出长度 len 被硬编码成小于等于 PAG_SIZE 的大小，那么我们调大这个 PAGE_SIZE 的大小不就可以了吗？这样是肯定行不通的，因为对于一个 CPU 来说，它的 MMU 的页大小 PAGE_SIZE 的值是固定的，无法通过参数调节。要想改变 PAGE_SIZE 的大小，就必须更换成相应的 CPU，显然这也太过于“兴师动众”了。还有一种办法是，将上面代码中的 PAGE_SIZE 换成一个更大的其他值，然后重新编译，这个办法对于大多数人来说不太适用，需要掌握一定深度的 Linux 的相关知识。

那么有没有其他的办法呢？这里我们可以直接修改 kafka-server-stop.sh 脚本的内容，将其中的第一行命令修改如下：

```
PIDS=$(ps ax | grep -i 'kafka' | grep java | grep -v grep | awk '{print $1}')
```

即把“.Kafka”去掉，这样在绝大多数情况下是可以奏效的。如果有极端情况，即使这样也不能关闭，那么只需要按照以下两个步骤就可以优雅地关闭 Kafka 的服务进程：

1. 获取 Kafka 的服务进程号 PIDS。可以使用 Java 中的 jps 命令或使用 Linux 系统中的 ps 命令来查看。
2. 使 用kill -s TERM $PIDS 或 kill -15 $PIDS 的方式来关闭进程，注意千万不要使用 kill -9 的方式。

为什么这样关闭的方式会是优雅的？Kafka 服务入口程序中有一个名为“kafka-shutdown- hock”的关闭钩子，待 Kafka 进程捕获终止信号的时候会执行这个关闭钩子中的内容，其中除了正常关闭一些必要的资源，还会执行一个控制关闭（ControlledShutdown）的动作。使用 ControlledShutdown 的方式关闭 Kafka 有两个优点：一是可以让消息完全同步到磁盘上，在服务下次重新上线时不需要进行日志的恢复操作；二是 ControllerShutdown 在关闭服务之前，会对其上的 leader 副本进行迁移，这样就可以减少分区的不可用时间。

若要成功执行 ControlledShutdown 动作还需要有一个先决条件，就是参数 controlled.shutdown.enable 的值需要设置为true，不过这个参数的默认值就为 true，即默认开始此项功能。ControlledShutdown 动作如果执行不成功还会重试执行，这个重试的动作由参数 controlled.shutdown.max.retries 配置，默认为3次，每次重试的间隔由参数 controlled.shutdown.retry.backoff.ms 设置，默认为5000ms。

下面我们具体探讨 ControlledShutdown 的整个执行过程。



![6-16](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee5d1e5ae7e0a)



参考上图，假设此时有两个 broker，其中待关闭的 broker 的 id 为 x，Kafka 控制器所对应的 broker 的 id 为 y。待关闭的 broker 在执行 ControlledShutdown 动作时首先与 Kafka 控制器建立专用连接（对应上图中的步骤①），然后发送 ControlledShutdownRequest 请求，ControlledShutdownRequest 请求中只有一个 brokerId 字段，这个 brokerId 字段的值设置为自身的 brokerId 的值，即 x（对应上图中的步骤②）。

Kafka 控制器在收到 ControlledShutdownRequest 请求之后会将与待关闭 broker 有关联的所有分区进行专门的处理，这里的“有关联”是指分区中有副本位于这个待关闭的 broker 之上（这里会涉及 Kafka 控制器与待关闭 broker 之间的多次交互动作，涉及 leader 副本的迁移和副本的关闭动作，对应上图中的步骤③）。

ControlledShutdownRequest 的结构如下图所示。



![6-17](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee5df218ab723)



如果这些分区的副本数大于1且 leader 副本位于待关闭 broker 上，那么需要实施 leader 副本的迁移及新的 ISR 的变更。具体的选举分配的方案由专用的选举器 ControlledShutdownLeaderSelector 提供。

如果这些分区的副本数只是大于1，leader 副本并不位于待关闭 broker 上，那么就由 Kafka 控制器来指导这些副本的关闭。如果这些分区的副本数只是为1，那么这个副本的关闭动作会在整个 ControlledShutdown 动作执行之后由副本管理器来具体实施。

对于分区的副本数大于1且 leader 副本位于待关闭 broker 上的这种情况，如果在 Kafka 控制器处理之后 leader 副本还没有成功迁移，那么会将这些没有成功迁移 leader 副本的分区记录下来，并且写入 ControlledShutdownResponse 的响应（对应往上第二张图中的步骤④，整个 ControlledShutdown 动作是一个同步阻塞的过程）。ControlledShutdownResponse 的结构如下图所示。



![6-18](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169ee605ab25a62d)



待关闭的 broker 在收到 ControlledShutdownResponse 响应之后，需要判断整个 ControlledShutdown 动作是否执行成功，以此来进行可能的重试或继续执行接下来的关闭资源的动作。执行成功的标准是 ControlledShutdownResponse 中 error_code 字段值为0，并且 partitions_remaining 数组字段为空。

> 注意要点：往上第三张图中也有可能 x=y，即待关闭的 broker同时是 Kafka 控制器，这也就意味着自己可以给自己发送 ControlledShutdownRequest 请求，以及等待自身的处理并接收 ControlledShutdownResponse 的响应，具体的执行细节和 x!=y 的场景相同。

在了解了整个 ControlledShutdown 动作的具体细节之后，我们不难看出这一切实质上都是由 ControlledShutdownRequest 请求引发的，我们完全可以自己开发一个程序来连接 Kafka 控制器，以此来模拟对某个 broker 实施 ControlledShutdown 的动作。为了实现方便，我们可以对 KafkaAdminClient 做一些扩展来达到目的。

首先参考 org.apache.kafka.clients.admin.AdminClient 接口中的惯有编码样式来添加两个方法：

```
    public abstract ControlledShutdownResult controlledShutdown(
            Node node, final ControlledShutdownOptions options);

    public ControlledShutdownResult controlledShutdown(Node node){
        return controlledShutdown(node, new ControlledShutdownOptions());
    }
```

第一个方法中的 ControlledShutdownOptions 和 ControlledShutdownResult 都是 KafkaAdminClient 的惯有编码样式，ControlledShutdownOptions 中没有实质性的内容，具体参考如下：

```
@InterfaceStability.Evolving
public class ControlledShutdownOptions extends 
AbstractOptions<ControlledShutdownOptions> {
}
```

ControlledShutdownResult 的实现如下：

```
@InterfaceStability.Evolving
public class ControlledShutdownResult {
    private final KafkaFuture<ControlledShutdownResponse> future;
    public ControlledShutdownResult(
    KafkaFuture<ControlledShutdownResponse> future) {
        this.future = future;
    }
    public KafkaFuture<ControlledShutdownResponse> values(){
        return future;
    }
}
```

ControlledShutdownResult 中没有像 KafkaAdminClient 中惯有的那样对 ControlledShutdownResponse 进行细致化的处理，而是直接将 ControlledShutdownResponse 暴露给用户，这样用户可以更加细腻地操控内部的细节。

第二个方法中的参数 Node 是我们需要执行 ControlledShutdown 动作的 broker 节点，Node 的构造方法至少需要三个参数：id、host 和 port，分别代表所对应的 broker 的 id 编号、IP 地址和端口号。一般情况下，对用户而言，并不一定清楚这个三个参数的具体值，有的要么只知道要关闭的 broker 的 IP 地址和端口号，要么只清楚具体的 id 编号，为了程序的通用性，我们还需要做进一步的处理。详细看一下 org.apache.kafka.clients.admin.KafkaAdminClient 中的具体做法：

```
public ControlledShutdownResult controlledShutdown(
            Node node,
            final ControlledShutdownOptions options) {
        final KafkaFutureImpl<ControlledShutdownResponse> future 
                = new KafkaFutureImpl<>();
        final long now = time.milliseconds();

        runnable.call(new Call("controlledShutdown", 
                calcDeadlineMs(now, options.timeoutMs()),
                new ControllerNodeProvider()) {
            @Override
            AbstractRequest.Builder createRequest(int timeoutMs) {
                int nodeId = node.id();
                if (nodeId < 0) {
                    List<Node> nodes = metadata.fetch().nodes();
                    for (Node nodeItem : nodes) {
                        if (nodeItem.host().equals(node.host()) 
                                && nodeItem.port() == node.port()) {
                            nodeId = nodeItem.id();
                            break;
                        }
                    }
                }
                return new ControlledShutdownRequest.Builder(nodeId, 
                        ApiKeys.CONTROLLED_SHUTDOWN.latestVersion());
            }

            @Override
            void handleResponse(AbstractResponse abstractResponse) {
                ControlledShutdownResponse response = 
                        (ControlledShutdownResponse) abstractResponse;
                future.complete(response);
            }

            @Override
            void handleFailure(Throwable throwable) {
                future.completeExceptionally(throwable);
            }
        }, now);

        return new ControlledShutdownResult(future);
    }
```

我们可以看到在内部的 createRequest 方法中对 Node 的 id 做了一些处理，因为对 ControlledShutdownRequest 协议的包装只需要这个 id 的值。程序中首先判断 Node 的 id 是否大于0，如果不是则需要根据 host 和 port 去 KafkaAdminClient 缓存的元数据 metadata 中查找匹配的 id。注意到代码里还有一个标粗的 ControllerNodeProvider，它提供了 Kafka 控制器对应的节点信息，这样用户只需要提供 Kafka 集群中的任意节点的连接信息，不需要知晓具体的 Kafka 控制器是谁。

最后我们再用一段测试程序来模拟发送 ControlledShutdownRequest 请求及处理 ControlledShutdownResponse，详细参考如下：

```
String brokerUrl = "hostname1:9092";
Properties props = new Properties();
props.put(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG, brokerUrl);
//1. 初始化KafkaAdminClient
AdminClient adminClient = AdminClient.create(props);

//2. 需要关闭的节点node，暂不清楚node的id，故设置为-1
Node node = new Node(-1, "hostname2", 9092);
//3. 使用KafkaAdminClient发送ControlledShutdownRequest请求及
//阻塞等待ControlledShutdownResponse响应
ControlledShutdownResponse response =
        adminClient.controlledShutdown(node).values().get();
if (response.error() == Errors.NONE
        && response.partitionsRemaining().isEmpty()) {
    System.out.println("controlled shutdown completed");
}else {
    System.out.println("controlled shutdown occured error with: "
            + response.error().message());
}
```

其中 brokerUrl 是连接的任意节点，node 是需要关闭的 broker 节点，当然这两个可以是同一个节点，即代码中的 hostname1 等于 hostname2。使用 KafkaAdminClient 的整个流程为：首先连接集群中的任意节点；接着通过这个连接向 Kafka 集群发起元数据请求（MetadataRequest）来获取集群的元数据 metadata；然后获取需要关闭的 broker 节点的 id，如果没有指定则去 metadata 中查找，根据这个 id 封装 ControlledShutdownRequest 请求；之后再去 metadata 中查找 Kafka 控制器的节点，向这个 Kafka 控制器节点发送请求；最后等待 Kafka 控制器的 ControlledShutdownResponse 响应并做相应的处理。

注意 ControlledShutdown 只是关闭 Kafka broker 的一个中间过程，所以不能寄希望于只使用 ControlledShutdownRequest 请求就可以关闭整个 Kafka broker 的服务进程。

## 分区leader的选举

分区 leader 副本的选举由控制器负责具体实施。当创建分区（创建主题或增加分区都有创建分区的动作）或分区上线（比如分区中原先的 leader 副本下线，此时分区需要选举一个新的 leader 上线来对外提供服务）的时候都需要执行 leader 的选举动作，对应的选举策略为 OfflinePartitionLeaderElectionStrategy。这种策略的基本思路是按照 AR 集合中副本的顺序查找第一个存活的副本，并且这个副本在 ISR 集合中。

一个分区的 AR 集合在分配的时候就被指定，并且只要不发生重分配的情况，集合内部副本的顺序是保持不变的，而分区的 ISR 集合中副本的顺序可能会改变。

注意这里是根据 AR 的顺序而不是 ISR 的顺序进行选举的。举个例子，集群中有3个节点：broker0、broker1 和 broker2，在某一时刻具有3个分区且副本因子为3的主题 topic-leader 的具体信息如下：

```
[root@node1 kafka_2.11-2.0.0]# bin/kafka-topics.sh --zookeeper localhost:2181/ kafka --describe --topic topic-leader
Topic:topic-leader	PartitionCount:3	ReplicationFactor:3	Configs: 
    Topic: topic-leader	Partition: 0	Leader: 1	Replicas: 1,2,0	Isr: 2,0,1
    Topic: topic-leader	Partition: 1	Leader: 2	Replicas: 2,0,1	Isr: 2,0,1
    Topic: topic-leader	Partition: 2	Leader: 0	Replicas: 0,1,2	Isr: 0,2,1
```

此时关闭 broker0，那么对于分区2而言，存活的 AR 就变为[1,2]，同时 ISR 变为[2,1]。此时查看主题 topic-leader 的具体信息（参考如下），分区2的 leader 就变为了1而不是2。

```
[root@node1 kafka_2.11-2.0.0]# bin/kafka-topics.sh --zookeeper localhost:2181/ kafka --describe --topic topic-leader
Topic:topic-leader	PartitionCount:3	ReplicationFactor:3	Configs: 
    Topic: topic-leader	Partition: 0	Leader: 1	Replicas: 1,2,0	Isr: 2,1
    Topic: topic-leader	Partition: 1	Leader: 2	Replicas: 2,0,1	Isr: 2,1
    Topic: topic-leader	Partition: 2	Leader: 1	Replicas: 0,1,2	Isr: 2,1
```

如果 ISR 集合中没有可用的副本，那么此时还要再检查一下所配置的 unclean.leader.election.enable 参数（默认值为 false）。如果这个参数配置为 true，那么表示允许从非 ISR 列表中的选举 leader，从 AR 列表中找到第一个存活的副本即为 leader。

当分区进行重分配的时候也需要执行 leader 的选举动作，对应的选举策略为 ReassignPartitionLeaderElectionStrategy。这个选举策略的思路比较简单：从重分配的AR列表中找到第一个存活的副本，且这个副本在目前的 ISR 列表中。

当发生优先副本的选举时，直接将优先副本设置为 leader 即可，AR 集合中的第一个副本即为优先副本（PreferredReplicaPartitionLeaderElectionStrategy）。

还有一种情况会发生 leader 的选举，当某节点被优雅地关闭（也就是执行 ControlledShutdown）时，位于这个节点上的 leader 副本都会下线，所以与此对应的分区需要执行 leader 的选举。与此对应的选举策略（ControlledShutdownPartitionLeaderElectionStrategy）为：从 AR 列表中找到第一个存活的副本，且这个副本在目前的 ISR 列表中，与此同时还要确保这个副本不处于正在被关闭的节点上。

# 消费端分区分配策略

Kafka 提供了消费者客户端参数 partition.assignment.strategy 来设置消费者与订阅主题之间的分区分配策略。默认情况下，此参数的值为 org.apache.kafka.clients.consumer.RangeAssignor，即采用 RangeAssignor 分配策略。除此之外，Kafka 还提供了另外两种分配策略：RoundRobinAssignor 和 StickyAssignor。消费者客户端参数 partition.assignment.strategy 可以配置多个分配策略，彼此之间以逗号分隔。

## RangeAssignor分配策略

RangeAssignor 分配策略的原理是按照消费者总数和分区总数进行整除运算来获得一个跨度，然后将分区按照跨度进行平均分配，以保证分区尽可能均匀地分配给所有的消费者。对于每一个主题，RangeAssignor 策略会将消费组内所有订阅这个主题的消费者按照名称的字典序排序，然后为每个消费者划分固定的分区范围，如果不够平均分配，那么字典序靠前的消费者会被多分配一个分区。

假设 n = 分区数/消费者数量，m = 分区数%消费者数量，那么前 m 个消费者每个分配 n+1 个分区，后面的（消费者数量- m）个消费者每个分配 n 个分区。

为了更加通俗地讲解 RangeAssignor 策略，我们不妨再举一些示例。假设消费组内有2个消费者 C0 和 C1，都订阅了主题 t0 和 t1，并且每个主题都有4个分区，那么订阅的所有分区可以标识为：t0p0、t0p1、t0p2、t0p3、t1p0、t1p1、t1p2、t1p3。最终的分配结果为：

```
消费者C0：t0p0、t0p1、t1p0、t1p1
消费者C1：t0p2、t0p3、t1p2、t1p3
```

这样分配得很均匀，那么这个分配策略能够一直保持这种良好的特性吗？我们不妨再来看另一种情况。假设上面例子中2个主题都只有3个分区，那么订阅的所有分区可以标识为：t0p0、t0p1、t0p2、t1p0、t1p1、t1p2。最终的分配结果为：

```
消费者C0：t0p0、t0p1、t1p0、t1p1
消费者C1：t0p2、t1p2
```

可以明显地看到这样的分配并不均匀，如果将类似的情形扩大，则有可能出现部分消费者过载的情况。对此我们再来看另一种 RoundRobinAssignor 策略的分配效果如何。

## RoundRobinAssignor分配策略

RoundRobinAssignor 分配策略的原理是将消费组内所有消费者及消费者订阅的所有主题的分区按照字典序排序，然后通过轮询方式逐个将分区依次分配给每个消费者。RoundRobinAssignor 分配策略对应的 partition.assignment.strategy 参数值为 org.apache.kafka.clients.consumer.RoundRobinAssignor。

如果同一个消费组内所有的消费者的订阅信息都是相同的，那么 RoundRobinAssignor 分配策略的分区分配会是均匀的。举个例子，假设消费组中有2个消费者 C0 和 C1，都订阅了主题 t0 和 t1，并且每个主题都有3个分区，那么订阅的所有分区可以标识为：t0p0、t0p1、t0p2、t1p0、t1p1、t1p2。最终的分配结果为：

```
消费者C0：t0p0、t0p2、t1p1
消费者C1：t0p1、t1p0、t1p2
```

如果同一个消费组内的消费者订阅的信息是不相同的，那么在执行分区分配的时候就不是完全的轮询分配，有可能导致分区分配得不均匀。如果某个消费者没有订阅消费组内的某个主题，那么在分配分区的时候此消费者将分配不到这个主题的任何分区。

举个例子，假设消费组内有3个消费者（C0、C1 和 C2），它们共订阅了3个主题（t0、t1、t2），这3个主题分别有1、2、3个分区，即整个消费组订阅了 t0p0、t1p0、t1p1、t2p0、t2p1、t2p2 这6个分区。具体而言，消费者 C0 订阅的是主题 t0，消费者 C1 订阅的是主题 t0 和 t1，消费者 C2 订阅的是主题 t0、t1 和 t2，那么最终的分配结果为：

```
消费者C0：t0p0
消费者C1：t1p0
消费者C2：t1p1、t2p0、t2p1、t2p2
```

可以看 到 RoundRobinAssignor 策略也不是十分完美，这样分配其实并不是最优解，因为完全可以将分区 t1p1 分配给消费者 C1。

## StickyAssignor分配策略

我们再来看一下 StickyAssignor 分配策略，“sticky”这个单词可以翻译为“黏性的”，Kafka 从 0.11.x 版本开始引入这种分配策略，它主要有两个目的：

1. 分区的分配要尽可能均匀。
2. 分区的分配尽可能与上次分配的保持相同。

当两者发生冲突时，第一个目标优先于第二个目标。鉴于这两个目标，StickyAssignor 分配策略的具体实现要比 RangeAssignor 和 RoundRobinAssignor 这两种分配策略要复杂得多。我们举例来看一下 StickyAssignor 分配策略的实际效果。

假设消费组内有3个消费者（C0、C1 和 C2），它们都订阅了4个主题（t0、t1、t2、t3），并且每个主题有2个分区。也就是说，整个消费组订阅了 t0p0、t0p1、t1p0、t1p1、t2p0、t2p1、t3p0、t3p1 这8个分区。最终的分配结果如下：

```
消费者C0：t0p0、t1p1、t3p0
消费者C1：t0p1、t2p0、t3p1
消费者C2：t1p0、t2p1
```

这样初看上去似乎与采用 RoundRobinAssignor 分配策略所分配的结果相同，但事实是否真的如此呢？再假设此时消费者 C1 脱离了消费组，那么消费组就会执行再均衡操作，进而消费分区会重新分配。如果采用 RoundRobinAssignor 分配策略，那么此时的分配结果如下：

```
消费者C0：t0p0、t1p0、t2p0、t3p0
消费者C2：t0p1、t1p1、t2p1、t3p1
```

如分配结果所示，RoundRobinAssignor 分配策略会按照消费者 C0 和 C2 进行重新轮询分配。如果此时使用的是 StickyAssignor 分配策略，那么分配结果为：

```
消费者C0：t0p0、t1p1、t3p0、t2p0
消费者C2：t1p0、t2p1、t0p1、t3p1
```

可以看到分配结果中保留了上一次分配中对消费者 C0 和 C2 的所有分配结果，并将原来消费者 C1 的“负担”分配给了剩余的两个消费者 C0 和 C2，最终 C0 和 C2 的分配还保持了均衡。

如果发生分区重分配，那么对于同一个分区而言，有可能之前的消费者和新指派的消费者不是同一个，之前消费者进行到一半的处理还要在新指派的消费者中再次复现一遍，这显然很浪费系统资源。StickyAssignor 分配策略如同其名称中的“sticky”一样，让分配策略具备一定的“黏性”，尽可能地让前后两次分配相同，进而减少系统资源的损耗及其他异常情况的发生。

到目前为止，我们分析的都是消费者的订阅信息都是相同的情况，我们来看一下订阅信息不同的情况下的处理。

举个例子，同样消费组内有3个消费者（C0、C1 和 C2），集群中有3个主题（t0、t1 和 t2），这3个主题分别有1、2、3个分区。也就是说，集群中有 t0p0、t1p0、t1p1、t2p0、t2p1、t2p2 这6个分区。消费者 C0 订阅了主题 t0，消费者 C1 订阅了主题 t0 和 t1，消费者 C2 订阅了主题 t0、t1 和 t2。

如果此时采用 RoundRobinAssignor 分配策略，那么最终的分配结果如分配清单11-1所示（和讲述 RoundRobinAssignor 分配策略时的一样，这样不妨赘述一下）：

```
分配清单11-1&emsp;RoundRobinAssignor分配策略的分配结果
消费者C0：t0p0
消费者C1：t1p0
消费者C2：t1p1、t2p0、t2p1、t2p2
```

如果此时采用的是 StickyAssignor 分配策略，那么最终的分配结果如分配清单11-2所示。

```
分配清单11-2&emsp;StickyAssignor分配策略的分配结果
消费者C0：t0p0
消费者C1：t1p0、t1p1
消费者C2：t2p0、t2p1、t2p2
```

可以看到这才是一个最优解（消费者 C0 没有订阅主题 t1 和 t2，所以不能分配主题 t1 和 t2 中的任何分区给它，对于消费者 C1 也可同理推断）。

假如此时消费者 C0 脱离了消费组，那么 RoundRobinAssignor 分配策略的分配结果为：

```
消费者C1：t0p0、t1p1
消费者C2：t1p0、t2p0、t2p1、t2p2
```

可以看到 RoundRobinAssignor 策略保留了消费者 C1 和 C2 中原有的3个分区的分配：t2p0、t2p1 和 t2p2（针对分配清单 11-1）。如果采用的是 StickyAssignor 分配策略，那么分配结果为：

```
消费者C1：t1p0、t1p1、t0p0
消费者C2：t2p0、t2p1、t2p2
```

可以看到 StickyAssignor 分配策略保留了消费者 C1 和 C2 中原有的5个分区的分配：t1p0、t1p1、t2p0、t2p1、t2p2。 对 ConsumerRebalanceListener 而言，StickyAssignor 分配策略可以提供一定程度上的优化：

```
public class TheOldRebalanceListener implements ConsumerRebalanceListener {
    @Override
    public void onPartitionsRevoked(Collection<TopicPartition> partitions) {
        for (TopicPartition topicPartition : partitions) {
            commitOffsets(partition);
            cleanupState(partition);
        }
    }

    @Override
    public void onPartitionsAssigned(Collection<TopicPartition> partitions) {
        for (TopicPartition topicPartition : partitions) {
            initializeState(partition);
            initializeOffset(partition);
        }
    }
}
```

如前所述，使用 StickyAssignor 分配策略的一个优点就是可以使分区重分配具备“黏性”，减少不必要的分区移动（即一个分区剥离之前的消费者，转而分配给另一个新的消费者）。

```
class TheNewRebalanceListener implements ConsumerRebalanceListener{
    Collection<TopicPartition> lastAssignment = Collections.emptyList();

    @Override
    public void onPartitionsRevoked(Collection<TopicPartition> partitions) {
        for (TopicPartition topicPartition : partitions) {
            commitOffsets(partition);
        }
    }

    @Override
    public void onPartitionsAssigned(Collection<TopicPartition> assignment) {
        for (TopicPartition topicPartition : 
            	difference(lastAssignment, assignment)) {
            cleanupState(partition);
        }
        for (TopicPartition topicPartition : 
            	difference(assignment, lastAssignment)) {
            initializeState(partition);
        }
        for (TopicPartition topicPartition : assignment) {
            initializeOffset(partition);
        }
        this.lastAssignment = assignment;
    }
}
```

从结果上看，StickyAssignor 分配策略比另外两者分配策略而言显得更加优异，这个策略的代码实现也异常复杂，如果读者没有接触过这种分配策略，不妨使用一下来尝尝鲜。

## 自定义分区分配策略

读者不仅可以任意选用 Kafka 提供的3种分配策略，还可以自定义分配策略来实现更多可选的功能。自定义的分配策略必须要实现 org.apache.kafka.clients.consumer.internals.PartitionAssignor 接口。PartitionAssignor 接口的定义如下：

```
Subscription subscription(Set<String> topics);
String name();
Map<String, Assignment> assign(Cluster metadata, 
                               Map<String, Subscription> subscriptions);
void onAssignment(Assignment assignment);

class Subscription {
    private final List<String> topics;
    private final ByteBuffer userData;
（省略若干方法……）
}

class Assignment {
    private final List<TopicPartition> partitions;
    private final ByteBuffer userData;
（省略若干方法……）
}
```

PartitionAssignor 接口中定义了两个内部类：Subscription 和 Assignment。

Subscription 类用来表示消费者的订阅信息，类中有两个属性：topics 和 userData，分别表示消费者的订阅主题列表和用户自定义信息。PartitionAssignor 接口通过 subscription() 方法来设置消费者自身相关的 Subscription 信息，注意到此方法中只有一个参数 topics，与 Subscription 类中的 topics 的相呼应，但并没有体现有关 userData 的参数。为了增强用户对分配结果的控制，可以在 subscription() 方法内部添加一些影响分配的用户自定义信息赋予 userData，比如权重、IP 地址、host 或机架（rack）等。



![7-1](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f20b93eb70ca1)



举个例子，在 subscription() 方法中提供机架信息，标识此消费者所部署的机架位置，在分区分配时可以根据分区的 leader 副本所在的机架位置来实施具体的分配，这样可以让消费者与所需拉取消息的 broker 节点处于同一机架。

参考上图，消费者 consumer1 和 broker1 都部署在机架 rack1 上，消费者 consumer2 和 broker2 都部署在机架 rack2 上。如果分区的分配不是机架感知的，那么有可能与上图（上半部分）中的分配结果一样，consumer1 消费 broker2 中的分区，而 consumer2 消费 broker1 中的分区；如果分区的分配是机架感知的，那么就会出现上图（下半部分）的分配结果，consumer1 消费 broker1 中的分区，而 consumer2 消费 broker2 中的分区，这样相比前一种情形，既可以减少消费延时，又可以减少跨机架带宽的占用。

再来说一下 Assignment 类，它用来表示分配结果信息，类中也有两个属性：partitions 和 userData，分别表示所分配到的分区集合和用户自定义的数据。PartitionAssignor 接口中的 onAssignment() 方法是在每个消费者收到消费组 leader 分配结果时的回调函数，例如在 StickyAssignor 分配策略中就是通过这个方法保存当前的分配方案，以备在下次消费组再均衡（rebalance）时可以提供分配参考依据。

接口中的 name() 方法用来提供分配策略的名称，对 Kafka 提供的3种分配策略而言，RangeAssignor 对应的 protocol_name 为“range”，RoundRobinAssignor 对应的 protocol_name 为“roundrobin”，StickyAssignor 对应的 protocol_name 为“sticky”，所以自定义的分配策略中要注意命名的时候不要与已存在的分配策略发生冲突。这个命名用来标识分配策略的名称，在后面所描述的加入消费组及选举消费组 leader 的时候会有涉及。

真正的分区分配方案的实现是在 assign() 方法中，方法中的参数 metadata 表示集群的元数据信息，而 subscriptions 表示消费组内各个消费者成员的订阅信息，最终方法返回各个消费者的分配信息。

Kafka 还提供了一个抽象类 org.apache.kafka.clients.consumer.internals.AbstractPartitionAssignor，它可以简化实现 PartitionAssignor 接口的工作，并对 assign() 方法进行了详细实现，其中会将 Subscription 中的 userData 信息去掉后再进行分配。Kafka 提供的3种分配策略都继承自这个抽象类。如果开发人员在自定义分区分配策略时需要使用 userData 信息来控制分区分配的结果，那么就不能直接继承 AbstractPartitionAssignor 这个抽象类，而需要直接实现 PartitionAssignor 接口。

下面笔者参考 Kafka 的 RangeAssignor 分配策略来自定义一个随机的分配策略，这里笔者称之为 RandomAssignor，具体代码实现如下：

```
package org.apache.kafka.clients.consumer;

import org.apache.kafka.clients.consumer.internals.AbstractPartitionAssignor;
import org.apache.kafka.common.TopicPartition;
import java.util.*;

public class RandomAssignor extends AbstractPartitionAssignor {
    @Override
    public String name() {
        return "random";
    }

    @Override
    public Map<String, List<TopicPartition>> assign(
            Map<String, Integer> partitionsPerTopic,
            Map<String, Subscription> subscriptions) {
        Map<String, List<String>> consumersPerTopic = 
                consumersPerTopic(subscriptions);
        Map<String, List<TopicPartition>> assignment = new HashMap<>();
        for (String memberId : subscriptions.keySet()) {
            assignment.put(memberId, new ArrayList<>());
        }

        //针对每一个主题进行分区分配
        for (Map.Entry<String, List<String>> topicEntry : 
                consumersPerTopic.entrySet()) {
            String topic = topicEntry.getKey();
            List<String> consumersForTopic = topicEntry.getValue();
            int consumerSize = consumersForTopic.size();

            Integer numPartitionsForTopic = partitionsPerTopic.get(topic);
            if (numPartitionsForTopic == null) {
                continue;
            }

            //当前主题下的所有分区
            List<TopicPartition> partitions = 
                AbstractPartitionAssignor.partitions(topic, 
                numPartitionsForTopic);
            //将每个分区随机分配给一个消费者
            for (TopicPartition partition : partitions) {
                int rand = new Random().nextInt(consumerSize);
                String randomConsumer = consumersForTopic.get(rand);
                assignment.get(randomConsumer).add(partition);
            }
        }
        return assignment;
    }

    //获取每个主题对应的消费者列表，即[topic, List[consumer]]
    private Map<String, List<String>> consumersPerTopic(
          Map<String, Subscription> consumerMetadata) {
        Map<String, List<String>> res = new HashMap<>();
        for (Map.Entry<String, Subscription> subscriptionEntry : 
                consumerMetadata.entrySet()) {
            String consumerId = subscriptionEntry.getKey();
            for (String topic : subscriptionEntry.getValue().topics())
                put(res, topic, consumerId);
        }
        return res;
    }
}
```

在使用时，消费者客户端需要添加相应的 Properties 参数，示例如下：

```
properties.put(ConsumerConfig.PARTITION_ASSIGNMENT_STRATEGY_CONFIG, 
     RandomAssignor.class.getName());
```

这里只是演示如何自定义实现一个分区分配策略，RandomAssignor 的实现并不是特别理想，并不见得会比 Kafka 自身提供的 RangeAssignor 之类的策略要好。

按照 Kafka 默认的消费逻辑设定，一个分区只能被同一个消费组（ConsumerGroup）内的一个消费者消费。但这一设定不是绝对的，我们可以通过自定义分区分配策略使一个分区可以分配给多个消费者消费。



![7-2](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f210fa11d5734)



考虑一种极端情况，同一消费组内的任意消费者都可以消费订阅主题的所有分区，从而实现了一种“组内广播（消费）”的功能。分配效果如上图所示。

下面展示了组内广播分配策略的具体代码实现：

```
public class BroadcastAssignor extends AbstractPartitionAssignor{
    @Override
    public String name() {
        return "broadcast";
    }

    private Map<String, List<String>> consumersPerTopic(
            Map<String, Subscription> consumerMetadata) {
        （具体实现请参考RandomAssignor中的consumersPerTopic()方法）
    }

    @Override
    public Map<String, List<TopicPartition>> assign(
            Map<String, Integer> partitionsPerTopic,
            Map<String, Subscription> subscriptions) {
        Map<String, List<String>> consumersPerTopic =
                consumersPerTopic(subscriptions);
        Map<String, List<TopicPartition>> assignment = new HashMap<>();
		   //Java8
        subscriptions.keySet().forEach(memberId ->
                assignment.put(memberId, new ArrayList<>()));
		   //针对每一个主题，为每一个订阅的消费者分配所有的分区
        consumersPerTopic.entrySet().forEach(topicEntry->{
            String topic = topicEntry.getKey();
            List<String> members = topicEntry.getValue();

            Integer numPartitionsForTopic = partitionsPerTopic.get(topic);
            if (numPartitionsForTopic == null || members.isEmpty())
                return;
            List<TopicPartition> partitions = AbstractPartitionAssignor
                    .partitions(topic, numPartitionsForTopic);
            if (!partitions.isEmpty()) {
                members.forEach(memberId ->
                        assignment.get(memberId).addAll(partitions));
            }
        });
        return assignment;
    }
}
```

注意组内广播的这种实现方式会有一个严重的问题—默认的消费位移的提交会失效。所有的消费者都会提交它自身的消费位移到 __consumer_offsets 中，后提交的消费位移会覆盖前面提交的消费位移。

假设消费者 consumer1 提交了分区 tp0 的消费位移为10，这时消费者 consumer2 紧接着提交了同一分区 tp0 的消费位移为12，如果此时消费者 consumer1 由于某些原因重启了，那么 consumer1 就会从位移12之后重新开始消费，这样 consumer1 就丢失了部分消息。

再考虑另一种情况，同样消费者 consumer1 提交了分区 tp0 的消费位移为10，这时消费者 consumer2 紧接着提交了同一分区的消费位移为8，如果此时消费者 consumer1 由于某些原因重启了，那么 consumer1 就会从位移8之后重新开始消费，这样 consumer1 就重复消费了消息。很多情形下，重复消费少量消息对于上层业务应用来说可以忍受。但是设想这样一种情况，消费组内的消费者对于分区tp0的消费位移都在100000之后了，此时又有一个新的消费者 consumer3 加入进来，消费了部分消息之后提交了 tp0 的消费位移为9，那么此时原消费组内的任何消费者重启都会从这个消费位移9之后再开始重新消费，这样大量的重复消息会让上层业务应用猝不及防，同样会造成计算资源的浪费。

针对上述这种情况，如果要真正实现组内广播，则需要自己保存每个消费者的消费位移。笔者的实践经验是，可以通过将消费位移保存到本地文件或数据库中等方法来实现组内广播的位移提交。



![7-3](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f21217ac126fb)



虽然说可以通过自定义分区分配策略来打破 Kafka 中“一个分区只能被同一个消费组内的一个消费者消费”的禁忌（参考上图中的消费者 C0 和 C1），但想要通过自定义分区分配策略来实现上图中的消费者 C3 和 C4 共同分享单个分区的消息是不现实的。更加通俗一点来说，上图中的消费者 C3 和 C4 都处于正常稳定的状态，此时它们想要共同分享分区3中的消息，即 C3 消费0、1、2这3条消息，而 C4 消费3、4这2条消息，紧接着 C3 再消费5、6、7这3条消息，这种分配是无法实现的。不过这种诉求可以配合 KafkaConsumer 中的 seek()方法来实现，实际应用价值不大。

# 消费者协调器和组协调器

了解了 Kafka 中消费者的分区分配策略之后是否会有这样的疑问：如果消费者客户端中配置了两个分配策略，那么以哪个为准呢？如果有多个消费者，彼此所配置的分配策略并不完全相同，那么以哪个为准？多个消费者之间的分区分配是需要协同的，那么这个协同的过程又是怎样的呢？这一切都是交由消费者协调器（ConsumerCoordinator）和组协调器（GroupCoordinator）来完成的，它们之间使用一套组协调协议进行交互。

## 旧版消费者客户端的问题

消费者协调器和组协调器的概念是针对新版的消费者客户端而言的，Kafka 建立之初并没有它们。旧版的消费者客户端是使用 ZooKeeper 的监听器（Watcher）来实现这些功能的。

每个消费组（<group>）在 ZooKeeper 中都维护了一个 /consumers/<group>/ids 路径，在此路径下使用临时节点记录隶属于此消费组的消费者的唯一标识（consumerIdString），consumerIdString 由消费者启动时创建。消费者的唯一标识由 consumer.id+主机名+时间戳+UUID 的部分信息构成，其中 consumer.id 是旧版消费者客户端中的配置，相当于新版客户端中的 client.id。比如某个消费者的唯一标识为 consumerId_localhost-1510734527562-64b377f5，那么其中 consumerId 为指定的 consumer.id，localhost 为计算机的主机名，1510734527562 代表时间戳，而 64b377f5 表示 UUID 的部分信息。

参考下图，与 /consumers/<group>/ids 同级的还有两个节点：owners 和 offsets，/consumers/<group>/owner 路径下记录了分区和消费者的对应关系，/consumers/<group>/offsets 路径下记录了此消费组在分区中对应的消费位移。



![7-4](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f22c8dc96891c)



每个 broker、主题和分区在 ZooKeeper 中也都对应一个路径：/brokers/ids/<id> 记录了 host、port 及分配在此 broker 上的主题分区列表；/brokers/topics/<topic> 记录了每个分区的 leader 副本、ISR 集合等信息。/brokers/topics/<topic>/partitions/<partition>/state记录了当前 leader 副本、leader_epoch 等信息。

每个消费者在启动时都会在 /consumers/<group>/ids 和 /brokers/ids 路径上注册一个监听器。当 /consumers/<group>/ids 路径下的子节点发生变化时，表示消费组中的消费者发生了变化；当 /brokers/ids 路径下的子节点发生变化时，表示 broker 出现了增减。这样通过 ZooKeeper 所提供的 Watcher，每个消费者就可以监听消费组和 Kafka 集群的状态了。

这种方式下每个消费者对 ZooKeeper 的相关路径分别进行监听，当触发再均衡操作时，一个消费组下的所有消费者会同时进行再均衡操作，而消费者之间并不知道彼此操作的结果，这样可能导致 Kafka 工作在一个不正确的状态。与此同时，这种严重依赖于 ZooKeeper 集群的做法还有两个比较严重的问题。

1. 羊群效应（Herd Effect）：所谓的羊群效应是指ZooKeeper 中一个被监听的节点变化，大量的 Watcher 通知被发送到客户端，导致在通知期间的其他操作延迟，也有可能发生类似死锁的情况。
2. 脑裂问题（Split Brain）：消费者进行再均衡操作时每个消费者都与 ZooKeeper 进行通信以判断消费者或broker变化的情况，由于 ZooKeeper 本身的特性，可能导致在同一时刻各个消费者获取的状态不一致，这样会导致异常问题发生。

## 再均衡的原理

新版的消费者客户端对此进行了重新设计，将全部消费组分成多个子集，每个消费组的子集在服务端对应一个 GroupCoordinator 对其进行管理，GroupCoordinator 是 Kafka 服务端中用于管理消费组的组件。而消费者客户端中的 ConsumerCoordinator 组件负责与 GroupCoordinator 进行交互。

ConsumerCoordinator 与 GroupCoordinator 之间最重要的职责就是负责执行消费者再均衡的操作，包括前面提及的分区分配的工作也是在再均衡期间完成的。就目前而言，一共有如下几种情形会触发再均衡的操作：

- 有新的消费者加入消费组。
- 有消费者宕机下线。消费者并不一定需要真正下线，例如遇到长时间的GC、网络延迟导致消费者长时间未向 GroupCoordinator 发送心跳等情况时，GroupCoordinator 会认为消费者已经下线。
- 有消费者主动退出消费组（发送 LeaveGroupRequest 请求）。比如客户端调用了 unsubscrible() 方法取消对某些主题的订阅。
- 消费组所对应的 GroupCoorinator 节点发生了变更。
- 消费组内所订阅的任一主题或者主题的分区数量发生变化。

下面就以一个简单的例子来讲解一下再均衡操作的具体内容。当有消费者加入消费组时，消费者、消费组及组协调器之间会经历一下几个阶段。

**第一阶段（FIND_COORDINATOR）**

消费者需要确定它所属的消费组对应的 GroupCoordinator 所在的 broker，并创建与该 broker 相互通信的网络连接。如果消费者已经保存了与消费组对应的 GroupCoordinator 节点的信息，并且与它之间的网络连接是正常的，那么就可以进入第二阶段。否则，就需要向集群中的某个节点发送 FindCoordinatorRequest 请求来查找对应的 GroupCoordinator，这里的“某个节点”并非是集群中的任意节点，而是负载最小的节点。

如下图所示，FindCoordinatorRequest 请求体中只有两个域（Field）：coordinator_key 和 coordinator_type。coordinator_key 在这里就是消费组的名称，即 groupId，coordinator_type 置为0。这个 FindCoordinatorRequest 请求还会在 Kafka 事务中提及，为了便于说明问题，这里我们暂且忽略它。



![img](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f22e44b9d5214)



Kafka 在收到 FindCoordinatorRequest 请求之后，会根据 coordinator_key（也就是 groupId）查找对应的 GroupCoordinator 节点，如果找到对应的 GroupCoordinator 则会返回其相对应的 node_id、host 和 port信息。

具体查找 GroupCoordinator 的方式是先根据消费组 groupId 的哈希值计算 __consumer_offsets 中的分区编号，具体算法如代码清单12-1所示：

```
代码清单12-1 消费组所对应的分区号的计算方式
Utils.abs(groupId.hashCode) % groupMetadataTopicPartitionCount
```

其中 groupId.hashCode 就是使用 Java 中 String 类的 hashCode() 方法获得的，groupMetadataTopicPartitionCount 为主题 __consumer_offsets 的分区个数，这个可以通过 broker 端参数 offsets.topic.num.partitions 来配置，默认值为50。

找到对应的 __consumer_offsets 中的分区之后，再寻找此分区 leader 副本所在的 broker 节点，该 broker 节点即为这个 groupId 所对应的 GroupCoordinator 节点。消费者 groupId 最终的分区分配方案及组内消费者所提交的消费位移信息都会发送给此分区 leader 副本所在的 broker 节点，让此 broker 节点既扮演 GroupCoordinator 的角色，又扮演保存分区分配方案和组内消费者位移的角色，这样可以省去很多不必要的中间轮转所带来的开销。

**第二阶段（JOIN_GROUP）**

在成功找到消费组所对应的 GroupCoordinator 之后就进入加入消费组的阶段，在此阶段的消费者会向 GroupCoordinator 发送 JoinGroupRequest 请求，并处理响应。



![7-6](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f23379794a53a)



如上图所示，JoinGroupRequest 的结构包含多个域：

- group_id 就是消费组的 id，通常也表示为 groupId。
- session_timout 对应消费端参数 session.timeout.ms，默认值为10000，即10秒。GroupCoordinator 超过 session_timeout 指定的时间内没有收到心跳报文则认为此消费者已经下线。
- rebalance_timeout 对应消费端参数 max.poll.interval.ms，默认值为300000，即5分钟。表示当消费组再平衡的时候，GroupCoordinator 等待各个消费者重新加入的最长等待时间。
- member_id 表示 GroupCoordinator 分配给消费者的id标识。消费者第一次发送 JoinGroupRequest 请求的时候此字段设置为 null。
- protocol_type 表示消费组实现的协议，对于消费者而言此字段值为“consumer”。

JoinGroupRequest 中的 group_protocols 域为数组类型，其中可以囊括多个分区分配策略，这个主要取决于消费者客户端参数 partition.assignment.strategy 的配置。如果配置了多种策略，那么 JoinGroupRequest 中就会包含多个 protocol_name 和 protocol_metadata。其中 protocol_name 对应于 PartitionAssignor 接口中的 name() 方法，我们在讲述消费者分区分配策略的时候提及过相关内容。而 protocol_metadata 和 PartitionAssignor 接口中的 subscription() 方法有直接关系，protocol_metadata 是一个 bytes 类型，其实质上还可以更细粒度地划分为 version、topics 和 user_data，如下图所示。



![7-7](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f234f06bcc2a0)



version 占2个字节，目前其值固定为0；topics 对应 PartitionAssignor 接口的 subscription() 方法返回值类型 Subscription 中的 topics，代表一个主题列表；user_data 对应 Subscription 中的 userData，可以为空。

如果是原有的消费者重新加入消费组，那么在真正发送 JoinGroupRequest 请求之前还要执行一些准备工作：

1. 如果消费端参数 enable.auto.commit 设置为 true（默认值也为 true），即开启自动提交位移功能，那么在请求加入消费组之前需要向 GroupCoordinator 提交消费位移。这个过程是阻塞执行的，要么成功提交消费位移，要么超时。
2. 如果消费者添加了自定义的再均衡监听器（ConsumerRebalanceListener），那么此时会调用 onPartitionsRevoked() 方法在重新加入消费组之前实施自定义的规则逻辑，比如清除一些状态，或者提交消费位移等。
3. 因为是重新加入消费组，之前与 GroupCoordinator 节点之间的心跳检测也就不需要了，所以在成功地重新加入消费组之前需要禁止心跳检测的运作。

消费者在发送 JoinGroupRequest 请求之后会阻塞等待 Kafka 服务端的响应。服务端在收到 JoinGroupRequest 请求后会交由 GroupCoordinator 来进行处理。GroupCoordinator 首先会对 JoinGroupRequest 请求做合法性校验，比如 group_id 是否为空、当前 broker 节点是否是请求的消费者组所对应的组协调器、rebalance_timeout 的值是否在合理的范围之内。如果消费者是第一次请求加入消费组，那么 JoinGroupRequest 请求中的 member_id 值为 null，即没有它自身的唯一标志，此时组协调器负责为此消费者生成一个 member_id。这个生成的算法很简单，具体如以下伪代码所示。

```
String memberId = clientId + “-” + UUID.randomUUID().toString();
```

其中 clientId 为消费者客户端的 clientId，对应请求头中的 client_id。由此可见消费者的 member_id 由 clientId 和 UUID 用“-”字符拼接而成。

**选举消费组的leader**

GroupCoordinator 需要为消费组内的消费者选举出一个消费组的 leader，这个选举的算法也很简单，分两种情况分析。如果消费组内还没有 leader，那么第一个加入消费组的消费者即为消费组的 leader。如果某一时刻 leader 消费者由于某些原因退出了消费组，那么会重新选举一个新的 leader，这个重新选举 leader 的过程又更“随意”了，相关代码如下：

```
private val members = new mutable.HashMap[String, MemberMetadata]
var leaderId = members.keys.head
```

解释一下这2行代码：在 GroupCoordinator 中消费者的信息是以 HashMap 的形式存储的，其中 key 为消费者的 member_id，而 value 是消费者相关的元数据信息。leaderId 表示 leader 消费者的 member_id，它的取值为 HashMap 中的第一个键值对的 key，这种选举的方式基本上和随机无异。总体上来说，消费组的 leader 选举过程是很随意的。

**选举分区分配策略**

每个消费者都可以设置自己的分区分配策略，对消费组而言需要从各个消费者呈报上来的各个分配策略中选举一个彼此都“信服”的策略来进行整体上的分区分配。这个分区分配的选举并非由 leader 消费者决定，而是根据消费组内的各个消费者投票来决定的。这里所说的“根据组内的各个消费者投票来决定”不是指 GroupCoordinator 还要再与各个消费者进行进一步交互，而是根据各个消费者呈报的分配策略来实施。最终选举的分配策略基本上可以看作被各个消费者支持的最多的策略，具体的选举过程如下：

1. 收集各个消费者支持的所有分配策略，组成候选集 candidates。
2. 每个消费者从候选集 candidates 中找出第一个自身支持的策略，为这个策略投上一票。
3. 计算候选集中各个策略的选票数，选票数最多的策略即为当前消费组的分配策略。

如果有消费者并不支持选出的分配策略，那么就会报出异常 IllegalArgumentException：Member does not support protocol。需要注意的是，这里所说的“消费者所支持的分配策略”是指 partition.assignment.strategy 参数配置的策略，如果这个参数值只配置了 RangeAssignor，那么这个消费者客户端只支持 RangeAssignor 分配策略，而不是消费者客户端代码中实现的3种分配策略及可能的自定义分配策略。

在此之后，Kafka 服务端就要发送 JoinGroupResponse 响应给各个消费者，leader 消费者和其他普通消费者收到的响应内容并不相同，首先我们看一下 JoinGroupResponse 的具体结构，如下图所示。



![7-8](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f23b205c41c6f)



JoinGroupResponse 包含了多个域，其中 generation_id 用来标识当前消费组的年代信息，避免受到过期请求的影响。leader_id 表示消费组 leader 消费者的 member_id。

Kafka 发送给普通消费者的 JoinGroupResponse 中的 members 内容为空，而只有 leader 消费者的 JoinGroupResponse 中的 members 包含有效数据。members 为数组类型，其中包含各个成员信息。member_metadata 为消费者的订阅信息，与 JoinGroupRequest 中的 protocol_metadata 内容相同，不同的是 JoinGroupRequest 可以包含多个 <protocol_name, protocol_metadata> 的键值对，在收到 JoinGroupRequest 之后，GroupCoordinator 已经选举出唯一的分配策略。也就是说，protocol_name 已经确定（group_protocol），那么对应的 protocol_metadata 也就确定了，最终各个消费者收到的 JoinGroupResponse 响应中的 member_metadata 就是这个确定了的 protocol_metadata。由此可见，Kafka 把分区分配的具体分配交还给客户端，自身并不参与具体的分配细节，这样即使以后分区分配的策略发生了变更，也只需要重启消费端的应用即可，而不需要重启服务端。

本阶段的内容可以简要概括为下面2张图。



![7-9](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f23c3f78614ed)





![7-10](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f23c6f3645910)



**第三阶段（SYNC_GROUP）**

leader 消费者根据在第二阶段中选举出来的分区分配策略来实施具体的分区分配，在此之后需要将分配的方案同步给各个消费者，此时 leader 消费者并不是直接和其余的普通消费者同步分配方案，而是通过 GroupCoordinator 这个“中间人”来负责转发同步分配方案的。在第三阶段，也就是同步阶段，各个消费者会向 GroupCoordinator 发送 SyncGroupRequest 请求来同步分配方案，如下图所示。



![7-11](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f23ce1cf115c6)



我们再来看一下 SyncGroupRequest 请求的具体结构，如下图所示。SyncGroupRequest 中的 group_id、generation_id 和 member_id 前面都有涉及，这里不再赘述。只有 leader 消费者发送的 SyncGroupRequest 请求中才包含具体的分区分配方案，这个分配方案保存在 group_assignment 中，而其余消费者发送的 SyncGroupRequest 请求中的 group_assignment 为空。



![7-12](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f23d85b6292f4)



group_assignment 是一个数组类型，其中包含了各个消费者对应的具体分配方案：member_id 表示消费者的唯一标识，而 member_assignment 是与消费者对应的分配方案，它还可以做更具体的划分，member_assignment 的结构如下图所示。



![7-13](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f23e2343485dd)



与 JoinGroupRequest 请求中的 protocol_metadata 类似，都可以细分为3个更具体的字段，只不过 protocol_metadata 存储的是主题的列表信息，而 member_assignment 存储的是分区信息，member_assignment 中可以包含多个主题的多个分区信息。

服务端在收到消费者发送的 SyncGroupRequest 请求之后会交由 GroupCoordinator 来负责具体的逻辑处理。GroupCoordinator 同样会先对 SyncGroupRequest 请求做合法性校验，在此之后会将从 leader 消费者发送过来的分配方案提取出来，连同整个消费组的元数据信息一起存入 Kafka 的 __consumer_offsets 主题中，最后发送响应给各个消费者以提供给各个消费者各自所属的分配方案。

这里所说的响应就是指 SyncGroupRequest 请求对应的 SyncGroupResponse，SyncGroupResponse 的内容很简单，里面包含的就是消费者对应的所属分配方案，SyncGroupResponse 的结构如下图所示，具体字段的释义可以从前面的内容中推测出来，这里就不赘述了。



![7-14](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f23ec8de8507b)



当消费者收到所属的分配方案之后会调用 PartitionAssignor 中的 onAssignment() 方法。随后再调用 ConsumerRebalanceListener 中的 OnPartitionAssigned() 方法。之后开启心跳任务，消费者定期向服务端的 GroupCoordinator 发送 HeartbeatRequest 来确定彼此在线。

**消费组元数据信息**

我们知道消费者客户端提交的消费位移会保存在 Kafka 的 __consumer_offsets 主题中，这里也一样，只不过保存的是消费组的元数据信息（GroupMetadata）。具体来说，每个消费组的元数据信息都是一条消息，不过这类消息并不依赖于具体版本的消息格式，因为它只定义了消息中的 key 和 value 字段的具体内容，所以消费组元数据信息的保存可以做到与具体的消息格式无关。



![7-15](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f240199bf6ae7)



上图中对应的就是消费组元数据信息的具体内容格式，上面是消息的 key，下面是消息的 value。可以看到 key 和 value 中都包含 version 字段，用来标识具体的 key 和 value 的版本信息，不同的版本对应的内容格式可能并不相同，就目前版本而言，key 的 version 为2，而 value 的 version 为1，读者在理解时其实可以忽略这个字段而探究其他具备特定含义的内容。key 中除了 version 就是 group 字段，它表示消费组的名称，和 JoinGroupRequest 或 SyncGroupRequest 请求中的 group_id 是同一个东西。虽然 key 中包含了 version 字段，但确定这条信息所要存储的分区还是根据单独的 group 字段来计算的，这样就可以保证消费组的元数据信息与消费组对应的 GroupCoordinator 处于同一个 broker 节点上，省去了中间轮转的开销。

value 中包含的内容有很多，可以参照和 JoinGroupRequest 或 SyncGroupRequest 请求中的内容来理解，具体各个字段的释义如下。

- protocol_type：消费组实现的协议，这里的值为“consumer”。
- generation：标识当前消费组的年代信息，避免收到过期请求的影响。
- protocol：消费组选取的分区分配策略。
- leader：消费组的 leader 消费者的名称。
- members：数组类型，其中包含了消费组的各个消费者成员信息，上图中右边部分就是消费者成员的具体信息，每个具体字段都比较容易辨别，需要着重说明的是 subscription 和 assignment 这两个字段，分别代码消费者的订阅信息和分配信息。

**第四阶段（HEARTBEAT）**

进入这个阶段之后，消费组中的所有消费者就会处于正常工作状态。在正式消费之前，消费者还需要确定拉取消息的起始位置。假设之前已经将最后的消费位移提交到了 GroupCoordinator，并且 GroupCoordinator 将其保存到了 Kafka 内部的 __consumer_offsets 主题中，此时消费者可以通过 OffsetFetchRequest 请求获取上次提交的消费位移并从此处继续消费。

消费者通过向 GroupCoordinator 发送心跳来维持它们与消费组的从属关系，以及它们对分区的所有权关系。只要消费者以正常的时间间隔发送心跳，就被认为是活跃的，说明它还在读取分区中的消息。心跳线程是一个独立的线程，可以在轮询消息的空档发送心跳。如果消费者停止发送心跳的时间足够长，则整个会话就被判定为过期，GroupCoordinator 也会认为这个消费者已经死亡，就会触发一次再均衡行为。

消费者的心跳间隔时间由参数 heartbeat.interval.ms 指定，默认值为3000，即3秒，这个参数必须比 session.timeout.ms 参数设定的值要小，一般情况下 heartbeat.interval.ms 的配置值不能超过 session.timeout.ms 配置值的1/3。这个参数可以调整得更低，以控制正常重新平衡的预期时间。

如果一个消费者发生崩溃，并停止读取消息，那么 GroupCoordinator 会等待一小段时间，确认这个消费者死亡之后才会触发再均衡。在这一小段时间内，死掉的消费者并不会读取分区里的消息。这个一小段时间由 session.timeout.ms 参数控制，该参数的配置值必须在broker端参数 group.min.session.timeout.ms（默认值为6000，即6秒）和 group.max.session.timeout.ms（默认值为300000，即5分钟）允许的范围内。

还有一个参数 max.poll.interval.ms，它用来指定使用消费者组管理时 poll() 方法调用之间的最大延迟，也就是消费者在获取更多消息之前可以空闲的时间量的上限。如果此超时时间期满之前 poll() 没有调用，则消费者被视为失败，并且分组将重新平衡，以便将分区重新分配给别的成员。

除了被动退出消费组，还可以使用 LeaveGroupRequest 请求主动退出消费组，比如客户端调用了 unsubscrible() 方法取消对某些主题的订阅，这个比较简单，这里就不再赘述了。

# __consumer_offsets深度剖析

位移提交是使用消费者客户端过程中一个比较“讲究”的操作。位移提交的内容最终会保存到 Kafka 的内部主题 __consumer_offsets 中，对于主题 __consumer_offsets 的深度掌握也可以让我们更好地理解和使用好位移提交。

一般情况下，当集群中第一次有消费者消费消息时会自动创建主题 __consumer_offsets，不过它的副本因子还受 offsets.topic.replication.factor 参数的约束，这个参数的默认值为3（下载安装的包中此值可能为1），分区数可以通过 offsets.topic.num.partitions 参数设置，默认为50。客户端提交消费位移是使用 OffsetCommitRequest 请求实现的，OffsetCommitRequest 的结构如下图所示。



![7-16](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f244c77eaa7ff)



请求体第一层中的 group_id、generation_id 和 member_id 在前面的内容中已经介绍过多次了，retention_time 表示当前提交的消费位移所能保留的时长，不过对于消费者而言这个值保持为-1。也就是说，按照 broker 端的配置 offsets.retention.minutes 来确定保留时长。offsets.retention.minutes 的默认值为10080，即7天，超过这个时间后消费位移的信息就会被删除（使用墓碑消息和日志压缩策略）。注意这个参数在 2.0.0 版本之前的默认值为1440，即1天，很多关于消费位移的异常也是由这个参数的值配置不当造成的。

有些定时消费的任务在执行完某次消费任务之后保存了消费位移，之后隔了一段时间再次执行消费任务，如果这个间隔时间超过 offsets.retention.minutes 的配置值，那么原先的位移信息就会丢失，最后只能根据客户端参数 auto.offset.reset 来决定开始消费的位置，遇到这种情况时就需要根据实际情况来调配 offsets.retention.minutes 参数的值。

OffsetCommitRequest 中的其余字段大抵也是按照分区的粒度来划分消费位移的：topic 表示主题名称，partition 表示分区编号等。注意这里还有一个 metadata 字段。在3.2.5节中讲到手动位移提交时提到了可以通过 Map<TopicPartition, OffsetAndMetadata> offsets 参数来指定要提交的分区位移。OffsetAndMetadata 中包含2个成员变量（offset 和 metadata），与此对应的有两个构造方法，详细如下：

```
public OffsetAndMetadata(long offset)
public OffsetAndMetadata(long offset, String metadata)
```

metadata 是自定义的元数据信息，如果不指定这个参数，那么就会被设置为空字符串，注意 metadata 的长度不能超过 offset.metadata.max.bytes 参数（broker 端配置，默认值为4096）所配置的大小。

同消费组的元数据信息一样，最终提交的消费位移也会以消息的形式发送至主题 __consumer_offsets，与消费位移对应的消息也只定义了 key 和 value 字段的具体内容，它不依赖于具体版本的消息格式，以此做到与具体的消息格式无关。



![7-17](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f24730b6ed1d1)



上图中展示了消费位移对应的消息内容格式，上面是消息的 key，下面是消息的 value。可以看到 key 和 value 中都包含了 version 字段，这个用来标识具体的 key 和 value 的版本信息，不同的版本对应的内容格式可能并不相同。就目前版本而言，key 和 value 的 version 值都为1。key 中除了 version 字段还有 group、topic、partition 字段，分别表示消费组的 groupId、主题名称和分区编号。虽然key中包含了4个字段，但最终确定这条消息所要存储的分区还是根据单独的 group 字段来计算的，这样就可以保证消费位移信息与消费组对应的 GroupCoordinator 处于同一个 broker 节点上，省去了中间轮转的开销，这一点与消费组的元数据信息的存储是一样的。

value 中包含了5个字段，除 version 字段外，其余的 offset、metadata、commit_timestamp、expire_timestamp 字段分别表示消费位移、自定义的元数据信息、位移提交到 Kafka 的时间戳、消费位移被判定为超时的时间戳。其中 offset 和 metadata 与 OffsetCommitRequest 请求体中的 offset 和 metadata 对应，而 expire_timestamp 和 OffsetCommitRequest 请求体中的 retention_time 也有关联，commit_timestamp 值与 offsets.retention.minutes 参数值之和即为 expire_timestamp（默认情况下）。

在处理完消费位移之后，Kafka 返回 OffsetCommitResponse 给客户端，OffsetCommitResponse 的结构如下图所示。OffsetCommitResponse 中各个域的具体含义可以通过前面内容中推断出来，这里就不再赘述了。



![7-18](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f24802557eace)



我们可以通过 kafka-console-consumer.sh 脚本来查看 __consumer_offsets 中的内容，不过要设定 formatter 参数为 kafka.coordinator.group.GroupMetadataManager$OffsetsMessageFormatter。假设我们要查看消费组“consumerGroupId”的位移提交信息，首先可以根据代码清单12-1中的计算方式得出分区编号为20，然后查看这个分区中的消息，相关示例如下：

```
[root@node1 kafka_2.11-2.0.0]# bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic __consumer_offsets -–partition 20 --formatter 'kafka.coordinator.group.GroupMetadataManager$OffsetsMessageFormatter'

[consumerGroupId,topic-offsets,30]::[OffsetMetadata[2130,NO_METADATA],CommitTime 1538843128354,ExpirationTime 1539447928354]
[consumerGroupId,topic-offsets,8]::[OffsetMetadata[2310,NO_METADATA],CommitTime 1538843128354,ExpirationTime 1539447928354]
[consumerGroupId,topic-offsets,21]::[OffsetMetadata[1230,NO_METADATA],CommitTime 1538843128354,ExpirationTime 1539447928354]
[consumerGroupId,topic-offsets,27]::[OffsetMetadata[1230,NO_METADATA],CommitTime 1538843128354,ExpirationTime 1539447928354]
[consumerGroupId,topic-offsets,9]::[OffsetMetadata[1233,NO_METADATA],CommitTime 1538843128354,ExpirationTime 1539447928354]
[consumerGroupId,topic-offsets,35]::[OffsetMetadata[1230,NO_METADATA],CommitTime 1538843128354,ExpirationTime 1539447928354]
[consumerGroupId,topic-offsets,41]::[OffsetMetadata[3210,NO_METADATA],CommitTime 1538843128354,ExpirationTime 1539447928354]
[consumerGroupId,topic-offsets,33]::[OffsetMetadata[1310,NO_METADATA],CommitTime 1538843128354,ExpirationTime 1539447928354]
[consumerGroupId,topic-offsets,23]::[OffsetMetadata[2123,NO_METADATA],CommitTime 1538843128354,ExpirationTime 1539447928354]
（…省略若干）
```

一般情况下，使用 OffsetsMessageFormatter 打印的格式可以概括为：

```
"[%s,%s,%d]:: [OffsetMetadata[%d,%s],CommitTime %d,ExpirationTime %d]".format (group, topic, partition, offset, metadata, commitTimestamp, expireTimestamp)
```

这里需要说明的是，如果某个 key（version + group + topic + partition 的组合）对应的消费位移过期了，那么对应的 value 就会被设置为 null，也就是墓碑消息（主题 __consumer_offsets 使用的是日志压缩策略），对应的打印结果也会变成如下的形式：

" [%s,%s,%d]::null".format(group, topic, partition)

有时候在查看主题 __consumer_offsets 中的内容时有可能出现下面这种情况：

```
[consumerGroupId,topic-offsets,21]::null
```

这说明对应的消费位移已经过期了。在 Kafka 中有一个名为“delete-expired-group-metadata”的定时任务来负责清理过期的消费位移，这个定时任务的执行周期由参数 offsets.retention.check.interval.ms 控制，默认值为600000，即10分钟。

还有 metadata，一般情况下它的值要么为 null 要么为空字符串，出现这种情况时，OffsetsMessageFormatter 会把它展示为“NO_METADATA”，否则就按实际值进行展示。

> 冷门知识：如果有若干消费者消费了某个主题中的消息，并且也提交了相应的消费位移，那么在删除这个主题之后会一并将这些消费位移信息删除。

# 事务

## 消息传输保障

一般而言，消息中间件的消息传输保障有3个层级，分别如下。

1. at most once：至多一次。消息可能会丢失，但绝对不会重复传输。
2. at least once：最少一次。消息绝不会丢失，但可能会重复传输。
3. exactly once：恰好一次。每条消息肯定会被传输一次且仅传输一次。

Kafka 的消息传输保障机制非常直观。当生产者向 Kafka 发送消息时，一旦消息被成功提交到日志文件，由于多副本机制的存在，这条消息就不会丢失。如果生产者发送消息到 Kafka 之后，遇到了网络问题而造成通信中断，那么生产者就无法判断该消息是否已经提交。虽然 Kafka 无法确定网络故障期间发生了什么，但生产者可以进行多次重试来确保消息已经写入 Kafka，这个重试的过程中有可能会造成消息的重复写入，所以这里 Kafka 提供的消息传输保障为 at least once。

对消费者而言，消费者处理消息和提交消费位移的顺序在很大程度上决定了消费者提供哪一种消息传输保障。如果消费者在拉取完消息之后，应用逻辑先处理消息后提交消费位移，那么在消息处理之后且在位移提交之前消费者宕机了，待它重新上线之后，会从上一次位移提交的位置拉取，这样就出现了重复消费，因为有部分消息已经处理过了只是还没来得及提交消费位移，此时就对应 at least once。

如果消费者在拉完消息之后，应用逻辑先提交消费位移后进行消息处理，那么在位移提交之后且在消息处理完成之前消费者宕机了，待它重新上线之后，会从已经提交的位移处开始重新消费，但之前尚有部分消息未进行消费，如此就会发生消息丢失，此时就对应 at most once。

Kafka 从 0.11.0.0 版本开始引入了幂等和事务这两个特性，以此来实现 EOS（exactly once semantics，精确一次处理语义）。

## 幂等

所谓的幂等，简单地说就是对接口的多次调用所产生的结果和调用一次是一致的。生产者在进行重试的时候有可能会重复写入消息，而使用 Kafka 的幂等性功能之后就可以避免这种情况。

开启幂等性功能的方式很简单，只需要显式地将生产者客户端参数 enable.idempotence 设置为 true 即可（这个参数的默认值为 false），参考如下：

```
properties.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
# 或者
properties.put(“enable.idempotence”, true);
```

不过如果要确保幂等性功能正常，还需要确保生产者客户端的 retries、acks、max.in.flight.requests.per.connection 这几个参数不被配置错。实际上在使用幂等性功能的时候，用户完全可以不用配置（也不建议配置）这几个参数。

如果用户显式地指定了 retries 参数，那么这个参数的值必须大于0，否则会报出 ConfigException：

```
org.apache.kafka.common.config.ConfigException: Must set retries to non-zero when using the idempotent producer.
```

如果用户没有显式地指定 retries 参数，那么 KafkaProducer 会将它置为 Integer.MAX_VALUE。同时还需要保证 max.in.flight.requests.per.connection 参数的值不能大于5（这个参数的值默认为5，在 2.2.1 节中有相关的介绍），否则也会报出 ConfigException：

```
org.apache.kafka.common.config.ConfigException: Must set max.in.flight. requests.per.connection to at most 5 to use the idempotent producer.
```

如果用户还显式地指定了 acks 参数，那么还需要保证这个参数的值为 -1（all），如果不为 -1（这个参数的值默认为1），那么也会报出 ConfigException：

```
org.apache.kafka.common.config.ConfigException: Must set acks to all in order to use the idempotent producer. Otherwise we cannot guarantee idempotence.
```

如果用户没有显式地指定这个参数，那么 KafkaProducer 会将它置为-1。开启幂等性功能之后，生产者就可以如同未开启幂等时一样发送消息了。

为了实现生产者的幂等性，Kafka 为此引入了 producer id（以下简称 PID）和序列号（sequence number）这两个概念，这两个概念其实在第2节中就讲过，分别对应 v2 版的日志格式中 RecordBatch 的 producer id 和 first seqence 这两个字段（参考第2节）。

每个新的生产者实例在初始化的时候都会被分配一个 PID，这个 PID 对用户而言是完全透明的。对于每个 PID，消息发送到的每一个分区都有对应的序列号，这些序列号从0开始单调递增。生产者每发送一条消息就会将 <PID，分区> 对应的序列号的值加1。

broker 端会在内存中为每一对 <PID，分区> 维护一个序列号。对于收到的每一条消息，只有当它的序列号的值（SN_new）比 broker 端中维护的对应的序列号的值（SN_old）大1（即 SN_new = SN_old + 1）时，broker 才会接收它。如果 SN_new< SN_old + 1，那么说明消息被重复写入，broker 可以直接将其丢弃。如果 SN_new> SN_old + 1，那么说明中间有数据尚未写入，出现了乱序，暗示可能有消息丢失，对应的生产者会抛出 OutOfOrderSequenceException，这个异常是一个严重的异常，后续的诸如 send()、beginTransaction()、commitTransaction() 等方法的调用都会抛出 IllegalStateException 的异常。

引入序列号来实现幂等也只是针对每一对 <PID，分区> 而言的，也就是说，Kafka 的幂等只能保证单个生产者会话（session）中单分区的幂等。

```
ProducerRecord<String, String> record 
      = new ProducerRecord<>(topic, "key", "msg");
producer.send(record);
producer.send(record);
```

注意，上面示例中发送了两条相同的消息，不过这仅仅是指消息内容相同，但对 Kafka 而言是两条不同的消息，因为会为这两条消息分配不同的序列号。Kafka 并不会保证消息内容的幂等。

## 事务

幂等性并不能跨多个分区运作，而事务可以弥补这个缺陷。事务可以保证对多个分区写入操作的原子性。操作的原子性是指多个操作要么全部成功，要么全部失败，不存在部分成功、部分失败的可能。

对流式应用（Stream Processing Applications）而言，一个典型的应用模式为“consume-transform-produce”。在这种模式下消费和生产并存：应用程序从某个主题中消费消息，然后经过一系列转换后写入另一个主题，消费者可能在提交消费位移的过程中出现问题而导致重复消费，也有可能生产者重复生产消息。Kafka中的事务可以使应用程序将消费消息、生产消息、提交消费位移当作原子操作来处理，同时成功或失败，即使该生产或消费会跨多个分区。

为了实现事务，应用程序必须提供唯一的 transactionalId，这个 transactionalId 通过客户端参数 transactional.id 来显式设置，参考如下：

```
properties.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "transactionId");
# 或者
properties.put("transactional.id", "transactionId");
```

事务要求生产者开启幂等特性，因此通过将 transactional.id 参数设置为非空从而开启事务特性的同时需要将 enable.idempotence 设置为 true（如果未显式设置，则 KafkaProducer 默认会将它的值设置为 true），如果用户显式地将 enable.idempotence 设置为 false，则会报出 ConfigException：

```
org.apache.kafka.common.config.ConfigException: Cannot set a transactional.id without also enabling idempotence.
```

transactionalId 与 PID 一一对应，两者之间所不同的是 transactionalId 由用户显式设置，而 PID 是由 Kafka 内部分配的。另外，为了保证新的生产者启动后具有相同 transactionalId 的旧生产者能够立即失效，每个生产者通过 transactionalId 获取 PID 的同时，还会获取一个单调递增的 producer epoch（对应下面要讲述的 KafkaProducer.initTransactions() 方法）。如果使用同一个 transactionalId 开启两个生产者，那么前一个开启的生产者会报出如下的错误：

```
org.apache.kafka.common.errors.ProducerFencedException: Producer attempted an operation with an old epoch. Either there is a newer producer with the same transactionalId, or the producer's transaction has been expired by the broker.
```

producer epoch 同 PID 和序列号一样在第2节中就讲过了，对应v2版的日志格式中 RecordBatch 的 producer epoch 字段。

从生产者的角度分析，通过事务，Kafka 可以保证跨生产者会话的消息幂等发送，以及跨生产者会话的事务恢复。前者表示具有相同 transactionalId 的新生产者实例被创建且工作的时候，旧的且拥有相同 transactionalId 的生产者实例将不再工作。后者指当某个生产者实例宕机后，新的生产者实例可以保证任何未完成的旧事务要么被提交（Commit），要么被中止（Abort），如此可以使新的生产者实例从一个正常的状态开始工作。

而从消费者的角度分析，事务能保证的语义相对偏弱。出于以下原因，Kafka 并不能保证已提交的事务中的所有消息都能够被消费：

- 对采用日志压缩策略的主题而言，事务中的某些消息有可能被清理（相同key的消息，后写入的消息会覆盖前面写入的消息）。
- 事务中消息可能分布在同一个分区的多个日志分段（LogSegment）中，当老的日志分段被删除时，对应的消息可能会丢失。
- 消费者可以通过 seek() 方法访问任意 offset 的消息，从而可能遗漏事务中的部分消息。
- 消费者在消费时可能没有分配到事务内的所有分区，如此它也就不能读取事务中的所有消息。

KafkaProducer 提供了5个与事务相关的方法，详细如下：

```
void initTransactions();
void beginTransaction() throws ProducerFencedException;
void sendOffsetsToTransaction(Map<TopicPartition, OffsetAndMetadata> offsets,
                              String consumerGroupId)
        throws ProducerFencedException;
void commitTransaction() throws ProducerFencedException;
void abortTransaction() throws ProducerFencedException;
```

initTransactions() 方法用来初始化事务，这个方法能够执行的前提是配置了 transactionalId，如果没有则会报出 IllegalStateException：

```
java.lang.IllegalStateException: Cannot use transactional methods without enabling transactions by setting the transactional.id configuration property.
```

beginTransaction() 方法用来开启事务；sendOffsetsToTransaction() 方法为消费者提供在事务内的位移提交的操作；commitTransaction() 方法用来提交事务；abortTransaction() 方法用来中止事务，类似于事务回滚。

一个典型的事务消息发送的操作如代码清单14-1所示。

```
代码清单14-1 事务消息发送示例
Properties properties = new Properties();
properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, 
        StringSerializer.class.getName());
properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
        StringSerializer.class.getName());
properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, brokerList);
properties.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, transactionId);

KafkaProducer<String, String> producer = new KafkaProducer<>(properties);

producer.initTransactions();
producer.beginTransaction();

try {
    //处理业务逻辑并创建ProducerRecord
    ProducerRecord<String, String> record1 = new ProducerRecord<>(topic, "msg1");
    producer.send(record1);
    ProducerRecord<String, String> record2 = new ProducerRecord<>(topic, "msg2");
    producer.send(record2);
    ProducerRecord<String, String> record3 = new ProducerRecord<>(topic, "msg3");
    producer.send(record3);
    //处理一些其他逻辑
    producer.commitTransaction();
} catch (ProducerFencedException e) {
    producer.abortTransaction();
}
producer.close();
```

在消费端有一个参数 isolation.level，与事务有着莫大的关联，这个参数的默认值为“read_uncommitted”，意思是说消费端应用可以看到（消费到）未提交的事务，当然对于已提交的事务也是可见的。这个参数还可以设置为“read_committed”，表示消费端应用不可以看到尚未提交的事务内的消息。

举个例子，如果生产者开启事务并向某个分区值发送3条消息 msg1、msg2 和 msg3，在执行 commitTransaction() 或 abortTransaction() 方法前，设置为“read_committed”的消费端应用是消费不到这些消息的，不过在 KafkaConsumer 内部会缓存这些消息，直到生产者执行 commitTransaction() 方法之后它才能将这些消息推送给消费端应用。反之，如果生产者执行了 abortTransaction() 方法，那么 KafkaConsumer 会将这些缓存的消息丢弃而不推送给消费端应用。

日志文件中除了普通的消息，还有一种消息专门用来标志一个事务的结束，它就是控制消息（ControlBatch）。控制消息一共有两种类型：COMMIT 和 ABORT，分别用来表征事务已经成功提交或已经被成功中止。KafkaConsumer 可以通过这个控制消息来判断对应的事务是被提交了还是被中止了，然后结合参数 isolation.level 配置的隔离级别来决定是否将相应的消息返回给消费端应用，如下图所示。注意 ControlBatch 对消费端应用不可见，后面还会对它有更加详细的介绍。



![7-19](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f265053628c13)



本节开头就提及了 consume-transform-produce 这种应用模式，这里还涉及在代码清单14-1中尚未使用的 sendOffsetsToTransaction() 方法。该模式的具体结构如下图所示。与此对应的应用示例如代码清单14-2所示。



![7-20](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f2666b2a53a88)



```
代码清单14-2 消费—转换—生产模式示例
public class TransactionConsumeTransformProduce {
    public static final String brokerList = "localhost:9092";

    public static Properties getConsumerProperties(){
        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, brokerList);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
                StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
                StringDeserializer.class.getName());
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "groupId");
        return props;
    }

    public static Properties getProducerProperties(){
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, brokerList);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,
                StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
                StringSerializer.class.getName());
        props.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "transactionalId");
        return props;
    }

    public static void main(String[] args) {
        //初始化生产者和消费者
        KafkaConsumer<String, String> consumer =
                new KafkaConsumer<>(getConsumerProperties());
        consumer.subscribe(Collections.singletonList("topic-source"));
        KafkaProducer<String, String> producer =
                new KafkaProducer<>(getProducerProperties());
        //初始化事务
        producer.initTransactions();
        while (true) {
            ConsumerRecords<String, String> records =
                    consumer.poll(Duration.ofMillis(1000));
            if (!records.isEmpty()) {
                Map<TopicPartition, OffsetAndMetadata> offsets = new HashMap<>();
                //开启事务
                producer.beginTransaction();
                try {
                    for (TopicPartition partition : records.partitions()) {
                        List<ConsumerRecord<String, String>> partitionRecords
                                = records.records(partition);
                        for (ConsumerRecord<String, String> record :
                                partitionRecords) {
                            //do some logical processing.
                            ProducerRecord<String, String> producerRecord =
                                    new ProducerRecord<>("topic-sink", record.key(),
                                            record.value());
                            //消费—生产模型
                            producer.send(producerRecord);
                        }
                        long lastConsumedOffset = partitionRecords.
                                get(partitionRecords.size() - 1).offset();
                        offsets.put(partition,
                                new OffsetAndMetadata(lastConsumedOffset + 1));
                    }
                    //提交消费位移
                    producer.sendOffsetsToTransaction(offsets,"groupId");
                    //提交事务
                    producer.commitTransaction();
                } catch (ProducerFencedException e) {
                    //log the exception
                    //中止事务
                    producer.abortTransaction();
                }
            }
        }
    }
}
```

注意：在使用 KafkaConsumer 的时候要将 enable.auto.commit 参数设置为 false，代码里也不能手动提交消费位移。

为了实现事务的功能，Kafka 还引入了事务协调器（TransactionCoordinator）来负责处理事务，这一点可以类比一下组协调器（GroupCoordinator）。每一个生产者都会被指派一个特定的 TransactionCoordinator，所有的事务逻辑包括分派 PID 等都是由 TransactionCoordinator 来负责实施的。TransactionCoordinator 会将事务状态持久化到内部主题 __transaction_state 中。下面就以最复杂的 consume-transform-produce 的流程（参考下图，后面就以“事务流程图”称呼）为例来分析 Kafka 事务的实现原理。



![7-21](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f26756bdaaf37)



### 1. 查找TransactionCoordinator

TransactionCoordinator 负责分配 PID 和管理事务，因此生产者要做的第一件事情就是找出对应的 TransactionCoordinator 所在的 broker 节点。与查找 GroupCoordinator 节点一样，也是通过 FindCoordinatorRequest 请求来实现的，只不过 FindCoordinatorRequest 中的 coordinator_type 就由原来的0变成了1，由此来表示与事务相关联。

Kafka 在收到 FindCoorinatorRequest 请求之后，会根据 coordinator_key（也就是 transactionalId）查找对应的 TransactionCoordinator 节点。如果找到，则会返回其相对应的 node_id、host 和 port 信息。具体查找 TransactionCoordinator 的方式是根据 transactionalId 的哈希值计算主题 __transaction_state 中的分区编号，具体算法如代码清单14-3所示。

```
代码清单14-3 计算分区编号
Utils.abs(transactionalId.hashCode) % transactionTopicPartitionCount
```

其中 transactionTopicPartitionCount 为主题 __transaction_state 中的分区个数，这个可以通过 broker 端参数 transaction.state.log.num.partitions 来配置，默认值为50。

找到对应的分区之后，再寻找此分区 leader 副本所在的 broker 节点，该 broker 节点即为这个 transactionalId 对应的 TransactionCoordinator 节点。细心的读者可以发现，这一整套的逻辑和查找 GroupCoordinator 的逻辑如出一辙。

### 2. 获取PID

在找到 TransactionCoordinator 节点之后，就需要为当前生产者分配一个 PID 了。凡是开启了幂等性功能的生产者都必须执行这个操作，不需要考虑该生产者是否还开启了事务。生产者获取 PID 的操作是通过 InitProducerIdRequest 请求来实现的，InitProducerIdRequest 请求体结构如下图所示，其中 transactional_id 表示事务的 transactionalId，transaction_timeout_ms 表示 TransactionCoordinaor 等待事务状态更新的超时时间，通过生产者客户端参数 transaction.timeout.ms 配置，默认值为60000。



![7-22](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f268f88753ad7)



**保存PID**

生产者的 InitProducerIdRequest 请求会被发送给 TransactionCoordinator。注意，如果未开启事务特性而只开启幂等特性，那么 InitProducerIdRequest 请求可以发送给任意的 broker。当 TransactionCoordinator 第一次收到包含该 transactionalId 的 InitProducerIdRequest 请求时，它会把 transactionalId 和对应的 PID 以消息（我们习惯性地把这类消息称为“事务日志消息”）的形式保存到主题 __transaction_state 中，如事务流程图步骤2.1所示。这样可以保证 <transaction_Id, PID> 的对应关系被持久化，从而保证即使 TransactionCoordinator 宕机该对应关系也不会丢失。存储到主题 __transaction_state 中的具体内容格式如下图所示。



![7-23](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f278975fa2ca5)



其中 transaction_status 包含 Empty(0)、Ongoing(1)、PrepareCommit(2)、PrepareAbort(3)、CompleteCommit(4)、CompleteAbort(5)、Dead(6) 这几种状态。在存入主题 __transaction_state 之前，事务日志消息同样会根据单独的 transactionalId 来计算要发送的分区，算法同代码清单14-3一样。



![7-24](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f27a55428aa8e)



与 InitProducerIdRequest 对应的 InitProducerIdResponse 响应体结构如上图所示，除了返回 PID，InitProducerIdRequest 还会触发执行以下任务：

- 增加该 PID 对应的 producer_epoch。具有相同 PID 但 producer_epoch 小于该 producer_epoch 的其他生产者新开启的事务将被拒绝。
- 恢复（Commit）或中止（Abort）之前的生产者未完成的事务。

### 3. 开启事务

通过 KafkaProducer 的 beginTransaction() 方法可以开启一个事务，调用该方法后，生产者本地会标记已经开启了一个新的事务，只有在生产者发送第一条消息之后 TransactionCoordinator 才会认为该事务已经开启。

### 4. Consume-Transform-Produce

这个阶段囊括了整个事务的数据处理过程，其中还涉及多种请求。注：如果没有给出具体的请求体或响应体结构，则说明其并不影响读者对内容的理解，笔者为了缩减篇幅而将其省略。

**1）AddPartitionsToTxnRequest**

当生产者给一个新的分区（TopicPartition）发送数据前，它需要先向 TransactionCoordinator 发送 AddPartitionsToTxnRequest 请求（AddPartitionsToTxnRequest 请求体结构如下图所示），这个请求会让 TransactionCoordinator 将 <transactionId, TopicPartition> 的对应关系存储在主题 __transaction_state 中，如图事务流程图步骤4.1所示。有了这个对照关系之后，我们就可以在后续的步骤中为每个分区设置 COMMIT 或 ABORT 标记，如事务流程图步骤5.2所示。



![7-25](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f27eace3c0225)



如果该分区是对应事务中的第一个分区，那么此时TransactionCoordinator还会启动对该事务的计时。

**2）ProduceRequest**

这一步骤很容易理解，生产者通过 ProduceRequest 请求发送消息（ProducerBatch）到用户自定义主题中，这一点和发送普通消息时相同，如事务流程图步骤4.2所示。和普通的消息不同的是，ProducerBatch 中会包含实质的 PID、producer_epoch 和 sequence number。

**3）AddOffsetsToTxnRequest**

通过 KafkaProducer 的 sendOffsetsToTransaction() 方法可以在一个事务批次里处理消息的消费和发送，方法中包含2个参数：Map<TopicPartition, OffsetAndMetadata> offsets 和 groupId。这个方法会向 TransactionCoordinator 节点发送 AddOffsetsToTxnRequest 请求（AddOffsetsToTxnRequest 请求体结构如下图所示），TransactionCoordinator 收到这个请求之后会通过 groupId 来推导出在 __consumer_offsets 中的分区，之后 TransactionCoordinator 会将这个分区保存在 __transaction_state 中，如事务流程图步骤4.3所示。



![7-26](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f27fa8c4ab9b3)



**4）TxnOffsetCommitRequest**

这个请求也是 sendOffsetsToTransaction() 方法中的一部分，在处理完 AddOffsetsToTxnRequest 之后，生产者还会发送 TxnOffsetCommitRequest 请求给 GroupCoordinator，从而将本次事务中包含的消费位移信息 offsets 存储到主题 __consumer_offsets 中，如事务流程图步骤4.4所示。

### 5. 提交或者中止事务

一旦数据被写入成功，我们就可以调用 KafkaProducer 的 commitTransaction() 方法或 abortTransaction() 方法来结束当前的事务。

**1）EndTxnRequest** 无论调用 commitTransaction() 方法还是 abortTransaction() 方法，生产者都会向 TransactionCoordinator 发送 EndTxnRequest 请求（对应的 EndTxnRequest 请求体结构如下图所示），以此来通知它提交（Commit）事务还是中止（Abort）事务。



![7-27](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f280204b5e7e0)



TransactionCoordinator 在收到 EndTxnRequest 请求后会执行如下操作：

1. 将 PREPARE_COMMIT 或 PREPARE_ABORT 消息写入主题 __transaction_state，如事务流程图步骤5.1所示。
2. 通过 WriteTxnMarkersRequest 请求将 COMMIT 或 ABORT 信息写入用户所使用的普通主题和 __consumer_offsets，如事务流程图步骤5.2所示。
3. 将 COMPLETE_COMMIT 或 COMPLETE_ABORT 信息写入内部主题 __transaction_state，如事务流程图步骤5.3所示。

**2）WriteTxnMarkersRequest**

WriteTxnMarkersRequest 请求是由 TransactionCoordinator 发向事务中各个分区的 leader 节点的，当节点收到这个请求之后，会在相应的分区中写入控制消息（ControlBatch）。控制消息用来标识事务的终结，它和普通的消息一样存储在日志文件中，前面章节中提及了控制消息，RecordBatch 中 attributes 字段的第6位用来标识当前消息是否是控制消息。如果是控制消息，那么这一位会置为1，否则会置为0，如下图所示。



![7-28](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f281703fd133e)



attributes 字段中的第5位用来标识当前消息是否处于事务中，如果是事务中的消息，那么这一位置为1，否则置为0。由于控制消息也处于事务中，所以attributes字段的第5位和第6位都被置为1。ControlBatch 中只有一个 Record，Record 中的 timestamp delta 字段和 offset delta 字段的值都为0，而控制消息的 key 和 value 的内容如下图所示。



![7-29](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f281a805b3a67)



就目前的 Kafka 版本而言，key 和 value 内部的 version 值都为0，key 中的 type 表示控制类型：0表示 ABORT，1表示 COMMIT；value 中的 coordinator_epoch 表示 TransactionCoordinator 的纪元（版本），TransactionCoordinator 切换的时候会更新其值。

**3）写入最终的COMPLETE_COMMIT或COMPLETE_ABORT**

TransactionCoordinator 将最终的 COMPLETE_COMMIT 或 COMPLETE_ABORT 信息写入主题 __transaction_state 以表明当前事务已经结束，此时可以删除主题 __transaction_state 中所有关于该事务的消息。由于主题 __transaction_state 采用的日志清理策略为日志压缩，所以这里的删除只需将相应的消息设置为墓碑消息即可。

Kafka 中采用了多副本的机制，这是大多数分布式系统中惯用的手法，以此来实现水平扩展、提供容灾能力、提升可用性和可靠性等。我们对此可以引申出一系列的疑问：Kafka 多副本之间如何进行数据同步，尤其是在发生异常时候的处理机制又是什么？多副本间的数据一致性如何解决，基于的一致性协议又是什么？如何确保 Kafka 的可靠性？Kafka 中的可靠性和可用性之间的关系又如何？

本节开始从副本的角度切入来深挖 Kafka 中的数据一致性、数据可靠性等问题，主要包括副本剖析、日志同步机制和可靠性分析等内容。

# 副本剖析

副本（Replica）是分布式系统中常见的概念之一，指的是分布式系统对数据和服务提供的一种冗余方式。在常见的分布式系统中，为了对外提供可用的服务，我们往往会对数据和服务进行副本处理。数据副本是指在不同的节点上持久化同一份数据，当某一个节点上存储的数据丢失时，可以从副本上读取该数据，这是解决分布式系统数据丢失问题最有效的手段。另一类副本是服务副本，指多个节点提供同样的服务，每个节点都有能力接收来自外部的请求并进行相应的处理。

组成分布式系统的所有计算机都有可能发生任何形式的故障。一个被大量工程实践所检验过的“黄金定理”：任何在设计阶段考虑到的异常情况，一定会在系统实际运行中发生，并且在系统实际运行过程中还会遇到很多在设计时未能考虑到的异常故障。所以，除非需求指标允许，否则在系统设计时不能放过任何异常情况。

Kafka 从 0.8 版本开始为分区引入了多副本机制，通过增加副本数量来提升数据容灾能力。同时，Kafka 通过多副本机制实现故障自动转移，在 Kafka 集群中某个 broker 节点失效的情况下仍然保证服务可用。这里先简要的整理下副本以及与副本相关的 AR、ISR、HW 和 LEO的概念：

- 副本是相对于分区而言的，即副本是特定分区的副本。
- 一个分区中包含一个或多个副本，其中一个为 leader 副本，其余为 follower 副本，各个副本位于不同的 broker 节点中。只有 leader 副本对外提供服务，follower 副本只负责数据同步。
- 分区中的所有副本统称为 AR，而 ISR 是指与 leader 副本保持同步状态的副本集合，当然 leader 副本本身也是这个集合中的一员。
- LEO 标识每个分区中最后一条消息的下一个位置，分区的每个副本都有自己的 LEO，ISR 中最小的 LEO 即为 HW，俗称高水位，消费者只能拉取到 HW 之前的消息。

从生产者发出的一条消息首先会被写入分区的 leader 副本，不过还需要等待 ISR 集合中的所有 follower 副本都同步完之后才能被认为已经提交，之后才会更新分区的 HW，进而消费者可以消费到这条消息。

## 失效副本

正常情况下，分区的所有副本都处于 ISR 集合中，但是难免会有异常情况发生，从而某些副本被剥离出 ISR 集合中。在 ISR 集合之外，也就是处于同步失效或功能失效（比如副本处于非存活状态）的副本统称为失效副本，失效副本对应的分区也就称为同步失效分区，即 under-replicated 分区。

正常情况下，我们通过 kafka-topics.sh 脚本的 under-replicated-partitions 参数来显示主题中包含失效副本的分区时结果会返回空。比如我们来查看一下主题 topic-partitions 的相关信息：

```
[root@node1 kafka_2.11-2.0.0]# bin/kafka-topics.sh --zookeeper localhost: 2181/kafka --describe --topic topic-partitions --under-replicated-partitions
```

读者可以自行验证一下，上面的示例中返回为空。紧接着我们将集群中的 brokerId 为2的节点关闭，再来执行同样的命令，结果显示如下：

```
[root@node1 kafka_2.11-2.0.0]# bin/kafka-topics.sh --zookeeper localhost:2181/ kafka --describe --topic topic-partitions --under-replicated-partitions 
     Topic: topic-partitions	Partition: 0	Leader: 1	Replicas: 1,2,0	Isr: 1,0
     Topic: topic-partitions	Partition: 1	Leader: 0	Replicas: 2,0,1	Isr: 0,1
     Topic: topic-partitions	Partition: 2	Leader: 0	Replicas: 0,1,2	Isr: 0,1
```

可以看到主题 topic-partitions 中的三个分区都为 under-replicated 分区，因为它们都有副本处于下线状态，即处于功能失效状态。

前面提及失效副本不仅是指处于功能失效状态的副本，处于同步失效状态的副本也可以看作失效副本。怎么判定一个分区是否有副本处于同步失效的状态呢？Kafka 从 0.9.x 版本开始就通过唯一的 broker 端参数 replica.lag.time.max.ms 来抉择，当 ISR 集合中的一个 follower 副本滞后 leader 副本的时间超过此参数指定的值时则判定为同步失败，需要将此 follower 副本剔除出 ISR 集合，具体可以参考下图。replica.lag.time.max.ms 参数的默认值为10000。



![8-1](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f3080596a2d4a)



具体的实现原理也很容易理解，当 follower 副本将 leader 副本 LEO（LogEndOffset）之前的日志全部同步时，则认为该 follower 副本已经追赶上 leader 副本，此时更新该副本的 lastCaughtUpTimeMs 标识。Kafka 的副本管理器会启动一个副本过期检测的定时任务，而这个定时任务会定时检查当前时间与副本的 lastCaughtUpTimeMs 差值是否大于参数 replica.lag.time.max.ms 指定的值。

千万不要错误地认为 follower 副本只要拉取 leader 副本的数据就会更新 lastCaughtUpTimeMs。试想一下，当 leader 副本中消息的流入速度大于 follower 副本中拉取的速度时，就算 follower 副本一直不断地拉取 leader 副本的消息也不能与 leader 副本同步。如果还将此 follower 副本置于 ISR 集合中，那么当 leader 副本下线而选取此 follower 副本为新的 leader 副本时就会造成消息的严重丢失。

Kafka 源码注释中说明了一般有两种情况会导致副本失效：

- follower 副本进程卡住，在一段时间内根本没有向 leader 副本发起同步请求，比如频繁的 Full GC。
- follower 副本进程同步过慢，在一段时间内都无法追赶上 leader 副本，比如 I/O 开销过大。

在这里再补充一点，如果通过工具增加了副本因子，那么新增加的副本在赶上 leader 副本之前也都是处于失效状态的。如果一个 follower 副本由于某些原因（比如宕机）而下线，之后又上线，在追赶上 leader 副本之前也处于失效状态。

在 0.9.x 版本之前，Kafka 中还有另一个参数 replica.lag.max.messages（默认值为4000），它也是用来判定失效副本的，当一个 follower 副本滞后 leader 副本的消息数超过 replica.lag.max.messages 的大小时，则判定它处于同步失效的状态。它与 replica.lag.time.max.ms 参数判定出的失效副本取并集组成一个失效副本的集合，从而进一步剥离出分区的 ISR 集合。

不过这个 replica.lag.max.messages 参数很难给定一个合适的值，若设置得太大，则这个参数本身就没有太多意义，若设置得太小则会让 follower 副本反复处于同步、未同步、同步的死循环中，进而又造成 ISR 集合的频繁伸缩。而且这个参数是 broker 级别的，也就是说，对 broker 中的所有主题都生效。以默认的值4000为例，对于消息流入速度很低的主题（比如 TPS 为10），这个参数并无用武之地；而对于消息流入速度很高的主题（比如 TPS 为20000），这个参数的取值又会引入 ISR 的频繁变动。所以从 0.9.x 版本开始，Kafka 就彻底移除了这一参数，相关的资料还可以参考[KIP16](https://cwiki.apache.org/confluence/display/KAFKA/KIP-16+-+Automated+Replica+Lag+Tuning)。

具有失效副本的分区可以从侧面反映出 Kafka 集群的很多问题，毫不夸张地说：如果只用一个指标来衡量 Kafka，那么同步失效分区（具有失效副本的分区）的个数必然是首选。

## ISR的伸缩

Kafka 在启动的时候会开启两个与ISR相关的定时任务，名称分别为“isr-expiration”和“isr-change-propagation”。isr-expiration 任务会周期性地检测每个分区是否需要缩减其 ISR 集合。这个周期和 replica.lag.time.max.ms 参数有关，大小是这个参数值的一半，默认值为 5000ms。当检测到 ISR 集合中有失效副本时，就会收缩 ISR 集合。如果某个分区的 ISR 集合发生变更，则会将变更后的数据记录到 ZooKeeper 对应的 /brokers/topics/<topic>/partition/<parititon>/state 节点中。节点中的数据示例如下：

```
{"controller_epoch":26,"leader":0,"version":1,"leader_epoch":2,"isr":[0,1]}
```

其中 controller_epoch 表示当前 Kafka 控制器的 epoch，leader 表示当前分区的 leader 副本所在的 broker 的 id 编号，version 表示版本号（当前版本固定为1），leader_epoch 表示当前分区的 leader 纪元，isr 表示变更后的 ISR 列表。

除此之外，当 ISR 集合发生变更时还会将变更后的记录缓存到 isrChangeSet 中，isr-change-propagation 任务会周期性（固定值为 2500ms）地检查 isrChangeSet，如果发现 isrChangeSet 中有 ISR 集合的变更记录，那么它会在 ZooKeeper 的 /isr_change_notification 路径下创建一个以 isr_change_ 开头的持久顺序节点（比如 /isr_change_notification/isr_change_0000000000），并将 isrChangeSet 中的信息保存到这个节点中。

Kafka 控制器为 /isr_change_notification 添加了一个 Watcher，当这个节点中有子节点发生变化时会触发 Watcher 的动作，以此通知控制器更新相关元数据信息并向它管理的 broker 节点发送更新元数据的请求，最后删除 /isr_change_notification 路径下已经处理过的节点。

频繁地触发 Watcher 会影响 Kafka 控制器、ZooKeeper 甚至其他 broker 节点的性能。为了避免这种情况，Kafka 添加了限定条件，当检测到分区的 ISR 集合发生变化时，还需要检查以下两个条件：

1. 上一次 ISR 集合发生变化距离现在已经超过5s。
2. 上一次写入 ZooKeeper 的时间距离现在已经超过60s。

满足以上两个条件之一才可以将 ISR 集合的变化写入目标节点。

有缩减对应就会有扩充，那么 Kafka 又是何时扩充 ISR 的呢？

随着 follower 副本不断与 leader 副本进行消息同步，follower 副本的 LEO 也会逐渐后移，并最终追赶上 leader 副本，此时该 follower 副本就有资格进入 ISR 集合。追赶上 leader 副本的判定准则是此副本的 LEO 是否不小于 leader 副本的 HW，注意这里并不是和 leader 副本的 LEO 相比。ISR 扩充之后同样会更新 ZooKeeper 中的 /brokers/topics/<topic>/partition/<parititon>/state 节点和 isrChangeSet，之后的步骤就和 ISR 收缩时的相同。

当 ISR 集合发生增减时，或者 ISR 集合中任一副本的 LEO 发生变化时，都可能会影响整个分区的 HW。

如下图所示，leader 副本的 LEO 为9，follower1 副本的 LEO 为7，而 follower2 副本的 LEO 为6，如果判定这3个副本都处于 ISR 集合中，那么这个分区的 HW 为6；如果 follower3 已经被判定为失效副本被剥离出 ISR 集合，那么此时分区的 HW 为 leader 副本和 follower1 副本中 LEO 的最小值，即为7。



![8-2](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f30bd86b99a97)



> 冷门知识：很多读者对 Kafka 中的 HW 的概念并不陌生，但是却并不知道还有一个 LW 的概念。LW 是 Low Watermark 的缩写，俗称“低水位”，代表 AR 集合中最小的 logStartOffset 值。副本的拉取请求（FetchRequest，它有可能触发新建日志分段而旧的被清理，进而导致 logStartOffset 的增加）和删除消息请求（DeleteRecordRequest）都有可能促使LW的增长。

## LEO与HW

对于副本而言，还有两个概念：本地副本（Local Replica）和远程副本（Remote Replica），本地副本是指对应的 Log分配在当前的 broker 节点上，远程副本是指对应的Log分配在其他的 broker 节点上。在 Kafka 中，同一个分区的信息会存在多个 broker 节点上，并被其上的副本管理器所管理，这样在逻辑层面每个 broker 节点上的分区就有了多个副本，但是只有本地副本才有对应的日志。



![8-3](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f30c7eac8efa9)



如上图所示，某个分区有3个副本分别位于 broker0、broker1 和 broker2 节点中，其中带阴影的方框表示本地副本。假设 broker0 上的副本1为当前分区的 leader 副本，那么副本2和副本3就是 follower 副本，整个消息追加的过程可以概括如下：

1. 生产者客户端发送消息至 leader 副本（副本1）中。
2. 消息被追加到 leader 副本的本地日志，并且会更新日志的偏移量。
3. follower 副本（副本2和副本3）向 leader 副本请求同步数据。
4. leader 副本所在的服务器读取本地日志，并更新对应拉取的 follower 副本的信息。
5. leader 副本所在的服务器将拉取结果返回给 follower 副本。
6. follower 副本收到 leader 副本返回的拉取结果，将消息追加到本地日志中，并更新日志的偏移量信息。

了解了这些内容后，我们再来分析在这个过程中各个副本 LEO 和 HW 的变化情况。下面的示例采用同上图中相同的环境背景，如下图（左）所示，生产者一直在往 leader 副本（带阴影的方框）中写入消息。某一时刻，leader 副本的 LEO 增加至5，并且所有副本的 HW 还都为0。



![8-4 8-5](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f30d94b9106de)



之后 follower 副本（不带阴影的方框）向 leader 副本拉取消息，在拉取的请求中会带有自身的 LEO 信息，这个 LEO 信息对应的是 FetchRequest 请求中的 fetch_offset。leader 副本返回给 follower 副本相应的消息，并且还带有自身的 HW 信息，如上图（右）所示，这个 HW 信息对应的是 FetchResponse 中的 high_watermark。

此时两个 follower 副本各自拉取到了消息，并更新各自的 LEO 为3和4。与此同时，follower 副本还会更新自己的 HW，更新 HW 的算法是比较当前 LEO 和 leader 副本中传送过来的HW的值，取较小值作为自己的 HW 值。当前两个 follower 副本的 HW 都等于0（min(0,0) = 0）。

接下来 follower 副本再次请求拉取 leader 副本中的消息，如下图（左）所示。



![8-6 8-7](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f30e8ffe4f38b)



此时 leader 副本收到来自 follower 副本的 FetchRequest 请求，其中带有 LEO 的相关信息，选取其中的最小值作为新的 HW，即 min(15,3,4)=3。然后连同消息和 HW 一起返回 FetchResponse 给 follower 副本，如上图（右）所示。注意 leader 副本的 HW 是一个很重要的东西，因为它直接影响了分区数据对消费者的可见性。

两个 follower 副本在收到新的消息之后更新 LEO 并且更新自己的 HW 为3（min(LEO,3)=3）。

在一个分区中，leader 副本所在的节点会记录所有副本的 LEO，而 follower 副本所在的节点只会记录自身的 LEO，而不会记录其他副本的 LEO。对 HW 而言，各个副本所在的节点都只记录它自身的 HW。变更本节第3张图，使其带有相应的 LEO 和 HW 信息，如下图所示。leader 副本中带有其他 follower 副本的 LEO，那么它们是什么时候更新的呢？leader 副本收到 follower 副本的 FetchRequest 请求之后，它首先会从自己的日志文件中读取数据，然后在返回给 follower 副本数据前先更新 follower 副本的 LEO。



![8-8](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31013401a6d7)



在第1节中，Kafka 的根目录下有 cleaner-offset-checkpoint、log-start-offset-checkpoint、recovery-point-offset-checkpoint 和 replication-offset-checkpoint 四个检查点文件，除了在第4节中提及了 cleaner-offset-checkpoint，其余章节都没有做过多的说明。

recovery-point-offset-checkpoint 和 replication-offset-checkpoint 这两个文件分别对应了 LEO 和 HW。Kafka 中会有一个定时任务负责将所有分区的 LEO 刷写到恢复点文件 recovery-point-offset-checkpoint 中，定时周期由broker端参数 log.flush.offset.checkpoint.interval.ms 来配置，默认值为60000。

还有一个定时任务负责将所有分区的 HW 刷写到复制点文件 replication-offset-checkpoint 中，定时周期由 broker 端参数 replica.high.watermark.checkpoint.interval.ms 来配置，默认值为5000。

log-start-offset-checkpoint 文件对应 logStartOffset（注意不能缩写为 LSO，因为在 Kafka 中 LSO 是 LastStableOffset 的缩写），这个在第4节中就讲过，在 FetchRequest 和 FetchResponse 中也有它的身影，它用来标识日志的起始偏移量。各个副本在变动 LEO 和 HW 的过程中，logStartOffset 也有可能随之而动。Kafka也有一个定时任务来负责将所有分区的 logStartOffset 书写到起始点文件 log-start-offset-checkpoint 中，定时周期由 broker 端参数 log.flush.start.offset.checkpoint.interval.ms 来配置，默认值为60000。

## Leader Epoch的介入

上一节的内容所陈述的都是在正常情况下的 leader 副本与 follower 副本之间的同步过程，如果 leader 副本发生切换，那么同步过程又该如何处理呢？在 0.11.0.0 版本之前，Kafka 使用的是基于 HW 的同步机制，但这样有可能出现数据丢失或 leader 副本和 follower 副本数据不一致的问题。



![8-9](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f316f8d2e49e4)



首先我们来看一下数据丢失的问题，如上图所示，Replica B 是当前的 leader 副本（用 L 标记），Replica A 是 follower 副本。参照上一节中的过程来进行分析：在某一时刻，B 中有2条消息 m1 和 m2，A 从 B 中同步了这两条消息，此时 A 和 B 的 LEO 都为2，同时 HW 都为1；之后 A 再向 B 中发送请求以拉取消息，FetchRequest 请求中带上了 A 的 LEO 信息，B 在收到请求之后更新了自己的 HW 为2；B 中虽然没有更多的消息，但还是在延时一段时间之后返回 FetchResponse，并在其中包含了 HW 信息；最后 A 根据 FetchResponse 中的 HW 信息更新自己的 HW 为2。



![8-10](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31805ab536d0)



可以看到整个过程中两者之间的 HW 同步有一个间隙，在 A 写入消息 m2 之后（LEO 更新为2）需要再一轮的 FetchRequest/FetchResponse 才能更新自身的 HW 为2。如上图所示，如果在这个时候 A 宕机了，那么在 A 重启之后会根据之前HW位置（这个值会存入本地的复制点文件 replication-offset-checkpoint）进行日志截断，这样便会将 m2 这条消息删除，此时 A 只剩下 m1 这一条消息，之后 A 再向 B 发送 FetchRequest 请求拉取消息。



![8-11](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f318704a79b4b)



此时若 B 再宕机，那么 A 就会被选举为新的 leader，如上图所示。B 恢复之后会成为 follower，由于 follower 副本 HW 不能比 leader 副本的 HW 高，所以还会做一次日志截断，以此将 HW 调整为1。这样一来 m2 这条消息就丢失了（就算B不能恢复，这条消息也同样丢失）。

对于这种情况，也有一些解决方法，比如等待所有 follower 副本都更新完自身的 HW 之后再更新 leader 副本的 HW，这样会增加多一轮的 FetchRequest/FetchResponse 延迟，自然不够妥当。还有一种方法就是 follower 副本恢复之后，在收到 leader 副本的 FetchResponse 前不要截断 follower 副本（follower 副本恢复之后会做两件事情：截断自身和向 leader 发送 FetchRequest 请求），不过这样也避免不了数据不一致的问题。



![8-12](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f3190f6ff699e)



如上图所示，当前 leader 副本为 A，follower 副本为 B，A 中有2条消息 m1 和 m2，并且 HW 和 LEO 都为2，B 中有1条消息 m1，并且 HW 和 LEO 都为1。假设 A 和 B 同时“挂掉”，然后 B 第一个恢复过来并成为 leader，如下图所示。



![8-13](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31964408032d)



之后 B 写入消息 m3，并将 LEO 和 HW 更新至2（假设所有场景中的 min.insync.replicas 参数配置为1）。此时 A 也恢复过来了，根据前面数据丢失场景中的介绍可知它会被赋予 follower 的角色，并且需要根据 HW 截断日志及发送 FetchRequest 至 B，不过此时 A 的 HW 正好也为2，那么就可以不做任何调整了，如下图所示。



![8-14](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f319d06bc676e)



如此一来 A 中保留了 m2 而 B 中没有，B 中新增了 m3 而 A 也同步不到，这样 A 和 B 就出现了数据不一致的情形。

为了解决上述两种问题，Kafka 从 0.11.0.0 开始引入了 leader epoch 的概念，在需要截断数据的时候使用 leader epoch 作为参考依据而不是原本的 HW。leader epoch 代表 leader 的纪元信息（epoch），初始值为0。每当 leader 变更一次，leader epoch 的值就会加1，相当于为 leader 增设了一个版本号。

与此同时，每个副本中还会增设一个矢量 <LeaderEpoch => StartOffset>，其中 StartOffset 表示当前 LeaderEpoch 下写入的第一条消息的偏移量。每个副本的 Log 下都有一个 leader-epoch-checkpoint 文件，在发生 leader epoch 变更时，会将对应的矢量对追加到这个文件中。在讲述 v2 版本的消息格式时就提到了消息集中的 partition leader epoch 字段，而这个字段正对应这里讲述的 leader epoch。

下面我们再来看一下引入 leader epoch 之后如何应付前面所说的数据丢失和数据不一致的场景。首先讲述应对数据丢失的问题，如下图所示，这里只是多了 LE（LeaderEpoch 的缩写，当前 A 和 B 中的 LE 都为0）。



![8-15](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31bb44daeec5)





![8-16](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31c074a03ecb)

同样A发生重启，之后A不是先忙着截断日志而是先发送OffsetsForLeaderEpochRequest请求给B（OffsetsForLeaderEpochRequest请求体结构如上图所示，其中包含A当前的LeaderEpoch值），B作为目前的leader在收到请求之后会返回当前的LEO（LogEndOffset，注意图中LE0和LEO的不同），与请求对应的响应为OffsetsForLeaderEpochResponse，对应的响应体结构可以参考下面第一张图，整个过程可以参考下面第二张图。





![8-17](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31cb663c1bb6)





![8-18](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31cf4f893360)



如果 A 中的 LeaderEpoch（假设为 LE_A）和 B 中的不相同，那么 B 此时会查找 LeaderEpoch 为 LE_A+1 对应的 StartOffset 并返回给 A，也就是 LE_A 对应的 LEO，所以我们可以将 OffsetsForLeaderEpochRequest 的请求看作用来查找 follower 副本当前 LeaderEpoch 的 LEO。

如上图所示，A 在收到2之后发现和目前的 LEO 相同，也就不需要截断日志了。之后 B 发生了宕机，A 成为新的 leader，那么对应的 LE=0 也变成了 LE=1，对应的消息 m2 此时就得到了保留，这是原本所不能的，如下图所示。之后不管 B 有没有恢复，后续的消息都可以以 LE1 为 LeaderEpoch 陆续追加到 A 中。



![8-19](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31dfac2e762a)



下面我们再来看一下 leader epoch 如何应对数据不一致的场景。如下图所示，当前 A 为 leader，B 为 follower，A 中有2条消息 m1 和 m2，而 B 中有1条消息 m1。假设 A 和 B 同时“挂掉”，然后 B 第一个恢复过来并成为新的 leader。



![8-20](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31e51ea7b4ff)



之后 B 写入消息 m3，并将 LEO 和 HW 更新至2，如下图所示。注意此时的 LeaderEpoch 已经从 LE0 增至 LE1 了。



![8-21](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31e9b114214f)



紧接着 A 也恢复过来成为 follower 并向 B 发送 OffsetsForLeaderEpochRequest 请求，此时 A 的 LeaderEpoch 为 LE0。B 根据 LE0 查询到对应的 offset 为1并返回给 A，A 就截断日志并删除了消息 m2，如下图所示。之后 A 发送 FetchRequest 至 B 请求来同步数据，最终A和B中都有两条消息 m1 和 m3，HW 和 LEO都为2，并且 LeaderEpoch 都为 LE1，如此便解决了数据不一致的问题。



![8-22](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31ef1e2bdd42)



## 为什么不支持读写分离

在 Kafka 中，生产者写入消息、消费者读取消息的操作都是与 leader 副本进行交互的，从而实现的是一种主写主读的生产消费模型。数据库、Redis 等都具备主写主读的功能，与此同时还支持主写从读的功能，主写从读也就是读写分离，为了与主写主读对应，这里就以主写从读来称呼。Kafka 并不支持主写从读，这是为什么呢？

从代码层面上来说，虽然增加了代码复杂度，但在 Kafka 中这种功能完全可以支持。对于这个问题，我们可以从“收益点”这个角度来做具体分析。主写从读可以让从节点去分担主节点的负载压力，预防主节点负载过重而从节点却空闲的情况发生。但是主写从读也有2个很明显的缺点：

1. 数据一致性问题。数据从主节点转到从节点必然会有一个延时的时间窗口，这个时间窗口会导致主从节点之间的数据不一致。某一时刻，在主节点和从节点中 A 数据的值都为 X，之后将主节点中 A 的值修改为 Y，那么在这个变更通知到从节点之前，应用读取从节点中的 A 数据的值并不为最新的 Y，由此便产生了数据不一致的问题。
2. 延时问题。类似 Redis 这种组件，数据从写入主节点到同步至从节点中的过程需要经历网络→主节点内存→网络→从节点内存这几个阶段，整个过程会耗费一定的时间。而在 Kafka 中，主从同步会比 Redis 更加耗时，它需要经历网络→主节点内存→主节点磁盘→网络→从节点内存→从节点磁盘这几个阶段。对延时敏感的应用而言，主写从读的功能并不太适用。

现实情况下，很多应用既可以忍受一定程度上的延时，也可以忍受一段时间内的数据不一致的情况，那么对于这种情况，Kafka 是否有必要支持主写从读的功能呢？

主写从读可以均摊一定的负载却不能做到完全的负载均衡，比如对于数据写压力很大而读压力很小的情况，从节点只能分摊很少的负载压力，而绝大多数压力还是在主节点上。而在 Kafka 中却可以达到很大程度上的负载均衡，而且这种均衡是在主写主读的架构上实现的。我们来看一下 Kafka 的生产消费模型，如下图所示。



![8-23](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f31fdaae23810)



如上图所示，在 Kafka 集群中有3个分区，每个分区有3个副本，正好均匀地分布在3个 broker 上，灰色阴影的代表 leader 副本，非灰色阴影的代表 follower 副本，虚线表示 follower 副本从 leader 副本上拉取消息。当生产者写入消息的时候都写入 leader 副本，对于上图中的情形，每个 broker 都有消息从生产者流入；当消费者读取消息的时候也是从 leader 副本中读取的，对于上图中的情形，每个 broker 都有消息流出到消费者。

我们很明显地可以看出，每个 broker 上的读写负载都是一样的，这就说明 Kafka 可以通过主写主读实现主写从读实现不了的负载均衡。有以下几种情况（包含但不仅限于）会造成一定程度上的负载不均衡：

1. broker 端的分区分配不均。当创建主题的时候可能会出现某些 broker 分配到的分区数多而其他 broker 分配到的分区数少，那么自然而然地分配到的 leader 副本也就不均。
2. 生产者写入消息不均。生产者可能只对某些 broker 中的 leader 副本进行大量的写入操作，而对其他 broker 中的 leader 副本不闻不问。
3. 消费者消费消息不均。消费者可能只对某些 broker 中的 leader 副本进行大量的拉取操作，而对其他 broker 中的 leader 副本不闻不问。
4. leader 副本的切换不均。在实际应用中可能会由于broker宕机而造成主从副本的切换，或者分区副本的重分配等，这些动作都有可能造成各个 broker 中 leader 副本的分配不均。

对此，我们可以做一些防范措施。针对第一种情况，在主题创建的时候尽可能使分区分配得均衡，好在Kafka中相应的分配算法也是在极力地追求这一目标，如果是开发人员自定义的分配，则需要注意这方面的内容。对于第二和第三种情况，主写从读也无法解决。对于第四种情况，Kafka提供了优先副本的选举来达到leader副本的均衡，与此同时，也可以配合相应的监控、告警和运维平台来实现均衡的优化。

在实际应用中，配合监控、告警、运维相结合的生态平台，在绝大多数情况下 Kafka 都能做到很大程度上的负载均衡。总的来说，Kafka 只支持主写主读有几个优点：可以简化代码的实现逻辑，减少出错的可能；将负载粒度细化均摊，与主写从读相比，不仅负载效能更好，而且对用户可控；没有延时的影响；在副本稳定的情况下，不会出现数据不一致的情况。为此，Kafka 又何必再去实现对它而言毫无收益的主写从读的功能呢？这一切都得益于 Kafka 优秀的架构设计，从某种意义上来说，主写从读是由于设计上的缺陷而形成的权宜之计。

# 日志同步机制

在分布式系统中，日志同步机制既要保证数据的一致性，也要保证数据的顺序性。虽然有许多方式可以实现这些功能，但最简单高效的方式还是从集群中选出一个 leader 来负责处理数据写入的顺序性。只要 leader 还处于存活状态，那么 follower 只需按照 leader 中的写入顺序来进行同步即可。

通常情况下，只要 leader 不宕机我们就不需要关心 follower 的同步问题。不过当 leader 宕机时，我们就要从 follower 中选举出一个新的 leader。follower 的同步状态可能落后 leader 很多，甚至还可能处于宕机状态，所以必须确保选择具有最新日志消息的 follower 作为新的 leader。日志同步机制的一个基本原则就是：如果告知客户端已经成功提交了某条消息，那么即使 leader 宕机，也要保证新选举出来的 leader 中能够包含这条消息。这里就有一个需要权衡（tradeoff）的地方，如果 leader 在消息被提交前需要等待更多的 follower 确认，那么在它宕机之后就可以有更多的 follower 替代它，不过这也会造成性能的下降。

对于这种 tradeoff，一种常见的做法是“少数服从多数”，它可以用来负责提交决策和选举决策。虽然 Kafka 不采用这种方式，但可以拿来探讨和理解 tradeoff 的艺术。在这种方式下，如果我们有 2f+1 个副本，那么在提交之前必须保证有 f+1 个副本同步完消息。同时为了保证能正确选举出新的 leader，至少要保证有 f+1 个副本节点完成日志同步并从同步完成的副本中选举出新的 leader 节点。并且在不超过 f 个副本节点失败的情况下，新的 leader 需要保证不会丢失已经提交过的全部消息。这样在任意组合的 f+1 个副本中，理论上可以确保至少有一个副本能够包含已提交的全部消息，这个副本的日志拥有最全的消息，因此会有资格被选举为新的 leader 来对外提供服务。

“少数服从多数”的方式有一个很大的优势，系统的延迟取决于最快的几个节点，比如副本数为3，那么延迟就取决于最快的那个 follower 而不是最慢的那个（除了 leader，只需要另一个 follower 确认即可）。不过它也有一些劣势，为了保证 leader 选举的正常进行，它所能容忍的失败 follower 数比较少，如果要容忍1个 follower 失败，那么至少要有3个副本，如果要容忍2个 follower 失败，必须要有5个副本。也就是说，在生产环境下为了保证较高的容错率，必须要有大量的副本，而大量的副本又会在大数据量下导致性能的急剧下降。这也就是“少数服从多数”的这种 Quorum 模型常被用作共享集群配置（比如 ZooKeeper），而很少用于主流的数据存储中的原因。

与“少数服从多数”相关的一致性协议有很多，比如 Zab、Raft 和 Viewstamped Replication 等。而 Kafka 使用的更像是微软的 PacificA 算法。

在 Kafka 中动态维护着一个 ISR 集合，处于 ISR 集合内的节点保持与 leader 相同的高水位（HW），只有位列其中的副本（unclean.leader.election.enable 配置为 false）才有资格被选为新的 leader。写入消息时只有等到所有ISR集合中的副本都确认收到之后才能被认为已经提交。位于 ISR 中的任何副本节点都有资格成为 leader，选举过程简单、开销低，这也是 Kafka 选用此模型的重要因素。Kafka 中包含大量的分区，leader 副本的均衡保障了整体负载的均衡，所以这一因素也极大地影响 Kafka 的性能指标。

在采用 ISR 模型和（f+1）个副本数的配置下，一个 Kafka 分区能够容忍最大f个节点失败，相比于“少数服从多数”的方式所需的节点数大幅减少。实际上，为了能够容忍 f 个节点失败，“少数服从多数”的方式和 ISR 的方式都需要相同数量副本的确认信息才能提交消息。比如，为了容忍1个节点失败，“少数服从多数”需要3个副本和1个 follower 的确认信息，采用 ISR 的方式需要2个副本和1个 follower 的确认信息。在需要相同确认信息数的情况下，采用 ISR 的方式所需要的副本总数变少，复制带来的集群开销也就更低，“少数服从多数”的优势在于它可以绕开最慢副本的确认信息，降低提交的延迟，而对 Kafka 而言，这种能力可以交由客户端自己去选择。

另外，一般的同步策略依赖于稳定的存储系统来做数据恢复，也就是说，在数据恢复时日志文件不可丢失且不能有数据上的冲突。不过它们忽视了两个问题：首先，磁盘故障是会经常发生的，在持久化数据的过程中并不能完全保证数据的完整性；其次，即使不存在硬件级别的故障，我们也不希望在每次写入数据时执行同步刷盘（fsync）的动作来保证数据的完整性，这样会极大地影响性能。而 Kafka 不需要宕机节点必须从本地数据日志中进行恢复，Kafka 的同步方式允许宕机副本重新加入 ISR 集合，但在进入 ISR 之前必须保证自己能够重新同步完 leader 中的所有数据。

# 可靠性分析

很多人问过笔者类似这样的一些问题：怎样可以确保 Kafka 完全可靠？如果这样做就可以确保消息不丢失了吗？笔者认为：就可靠性本身而言，它并不是一个可以用简单的“是”或“否”来衡量的一个指标，而一般是采用几个9来衡量的。任何东西不可能做到完全的可靠，即使能应付单机故障，也难以应付集群、数据中心等集体故障，即使躲得过天灾也未必躲得过人祸。就可靠性而言，我们可以基于一定的假设前提来做分析。本节要讲述的是：在只考虑 Kafka 本身使用方式的前提下如何最大程度地提高可靠性。

就 Kafka 而言，越多的副本数越能够保证数据的可靠性，副本数可以在创建主题时配置，也可以在后期修改，不过副本数越多也会引起磁盘、网络带宽的浪费，同时会引起性能的下降。一般而言，设置副本数为3即可满足绝大多数场景对可靠性的要求，而对可靠性要求更高的场景下，可以适当增大这个数值，比如国内部分银行在使用 Kafka 时就会设置副本数为5。与此同时，如果能够在分配分区副本的时候引入基架信息（broker.rack 参数），那么还要应对机架整体宕机的风险。

仅依靠副本数来支撑可靠性是远远不够的，大多数人还会想到生产者客户端参数 acks。在2.3节中我们就介绍过这个参数：相比于0和1，acks = -1（客户端还可以配置为 all，它的含义与-1一样，以下只以-1来进行陈述）可以最大程度地提高消息的可靠性。

对于 acks = 1 的配置，生产者将消息发送到 leader 副本，leader 副本在成功写入本地日志之后会告知生产者已经成功提交，如下图所示。如果此时 ISR 集合的 follower 副本还没来得及拉取到 leader 中新写入的消息，leader 就宕机了，那么此次发送的消息就会丢失。



![8-24](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f323c4330da2d)



对于 ack = -1 的配置，生产者将消息发送到 leader 副本，leader 副本在成功写入本地日志之后还要等待 ISR 中的 follower 副本全部同步完成才能够告知生产者已经成功提交，即使此时 leader 副本宕机，消息也不会丢失，如下图所示。



![8-25](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f32431bae0c90)



同样对于 acks = -1 的配置，如果在消息成功写入 leader 副本之后，并且在被 ISR 中的所有副本同步之前 leader 副本宕机了，那么生产者会收到异常以此告知此次发送失败，如下图所示。



![8-26](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f324761b145da)



消息发送有3种模式，即发后即忘、同步和异步。对于发后即忘的模式，不管消息有没有被成功写入，生产者都不会收到通知，那么即使消息写入失败也无从得知，因此发后即忘的模式不适合高可靠性要求的场景。如果要提升可靠性，那么生产者可以采用同步或异步的模式，在出现异常情况时可以及时获得通知，以便可以做相应的补救措施，比如选择重试发送（可能会引起消息重复）。

有些发送异常属于可重试异常，比如 NetworkException，这个可能是由瞬时的网络故障而导致的，一般通过重试就可以解决。对于这类异常，如果直接抛给客户端的使用方也未免过于兴师动众，客户端内部本身提供了重试机制来应对这种类型的异常，通过 retries 参数即可配置。

默认情况下，retries 参数设置为0，即不进行重试，对于高可靠性要求的场景，需要将这个值设置为大于0的值，与 retries 参数相关的还有一个 retry.backoff.ms 参数，它用来设定两次重试之间的时间间隔，以此避免无效的频繁重试。在配置 retries 和 retry.backoff.ms 之前，最好先估算一下可能的异常恢复时间，这样可以设定总的重试时间大于这个异常恢复时间，以此来避免生产者过早地放弃重试。如果不知道 retries 参数应该配置为多少，则可以参考 KafkaAdminClient，在 KafkaAdminClient 中 retries 参数的默认值为5。

注意如果配置的 retries 参数值大于0，则可能引起一些负面的影响。首先由于默认的 max.in.flight.requests.per.connection 参数值为5，这样可能会影响消息的顺序性，对此要么放弃客户端内部的重试功能，要么将 max.in.flight.requests.per.connection 参数设置为1，这样也就放弃了吞吐。其次，有些应用对于时延的要求很高，很多时候都是需要快速失败的，设置 retries> 0 会增加客户端对于异常的反馈时延，如此可能会对应用造成不良的影响。

我们回头再来看一下 acks = -1 的情形，它要求 ISR 中所有的副本都收到相关的消息之后才能够告知生产者已经成功提交。试想一下这样的情形，leader 副本的消息流入速度很快，而 follower 副本的同步速度很慢，在某个临界点时所有的 follower 副本都被剔除出了 ISR 集合，那么 ISR 中只有一个 leader 副本，最终 acks = -1 演变为 acks = 1 的情形，如此也就加大了消息丢失的风险。

Kafka 也考虑到了这种情况，并为此提供了 min.insync.replicas 参数（默认值为1）来作为辅助（配合 acks = -1 来使用），这个参数指定了 ISR 集合中最小的副本数，如果不满足条件就会抛出 NotEnoughReplicasException 或 NotEnoughReplicasAfterAppendException。在正常的配置下，需要满足 副本数 > min.insync.replicas 参数的值。一个典型的配置方案为：副本数配置为3，min.insync.replicas 参数值配置为2。注意 min.insync.replicas 参数在提升可靠性的时候会从侧面影响可用性。试想如果 ISR 中只有一个 leader 副本，那么最起码还可以使用，而此时如果配置 min.insync.replicas>1，则会使消息无法写入。

与可靠性和 ISR 集合有关的还有一个参数——unclean.leader.election.enable。这个参数的默认值为 false，如果设置为 true 就意味着当 leader 下线时候可以从非 ISR 集合中选举出新的 leader，这样有可能造成数据的丢失。如果这个参数设置为 false，那么也会影响可用性，非 ISR 集合中的副本虽然没能及时同步所有的消息，但最起码还是存活的可用副本。随着 Kafka 版本的变更，有的参数被淘汰，也有新的参数加入进来，而传承下来的参数一般都很少会修改既定的默认值，而 unclean.leader.election.enable 就是这样一个反例，从 0.11.0.0 版本开始，unclean.leader.election.enable 的默认值由原来的 true 改为了 false，可以看出 Kafka 的设计者愈发地偏向于可靠性的提升。

在 broker 端还有两个参数 log.flush.interval.messages 和 log.flush.interval.ms，用来调整同步刷盘的策略，默认是不做控制而交由操作系统本身来进行处理。同步刷盘是增强一个组件可靠性的有效方式，Kafka 也不例外，但笔者对同步刷盘有一定的疑问—绝大多数情景下，一个组件（尤其是大数据量的组件）的可靠性不应该由同步刷盘这种极其损耗性能的操作来保障，而应该采用多副本的机制来保障。

对于消息的可靠性，很多人都会忽视消费端的重要性，如果一条消息成功地写入 Kafka，并且也被 Kafka 完好地保存，而在消费时由于某些疏忽造成没有消费到这条消息，那么对于应用来说，这条消息也是丢失的。

enable.auto.commit 参数的默认值为 true，即开启自动位移提交的功能，虽然这种方式非常简便，但它会带来重复消费和消息丢失的问题，对于高可靠性要求的应用来说显然不可取，所以需要将 enable.auto.commit 参数设置为 false 来执行手动位移提交。在执行手动位移提交的时候也要遵循一个原则：如果消息没有被成功消费，那么就不能提交所对应的消费位移。对于高可靠要求的应用来说，宁愿重复消费也不应该因为消费异常而导致消息丢失。有时候，由于应用解析消息的异常，可能导致部分消息一直不能够成功被消费，那么这个时候为了不影响整体消费的进度，可以将这类消息暂存到死信队列中，以便后续的故障排除。

对于消费端，Kafka 还提供了一个可以兜底的功能，即回溯消费，通过这个功能可以让我们能够有机会对漏掉的消息相应地进行回补，进而可以进一步提高可靠性。

除了正常的消息发送和消费，在使用 Kafka 的过程中难免会遇到一些其他高级应用类的需求，比如消费回溯，这个可以通过原生 Kafka 提供的 KafkaConsumer.seek() 方法来实现，然而类似延时队列、消息轨迹等应用需求在原生 Kafka 中就没有提供了。我们在使用其他消息中间件时，比如 RabbitMQ，使用到了延时队列、消息轨迹的功能，如果我们将应用直接切换到 Kafka 中，那么只能选择舍弃它们。但这也不是绝对的，我们可以通过一定的手段来扩展 Kafka，从本节开始讲述的就是如何实现这类扩展的高级应用。

# 过期时间（TTL）

我们在[《图解Kafka之实战指南》](https://juejin.im/book/5c7d467e5188251b9156fdc0/section/5c7d576e6fb9a04a08226aaa)中讲述消费者拦截器用法的时候就使用了消息 TTL（Time To Live，过期时间），其中通过消息的 timestamp 字段和 ConsumerInterceptor 接口的 onConsume() 方法来实现消息的 TTL 功能。

消息超时之后不是只能如案例中的那样被直接丢弃，因为从消息可靠性层面而言这些消息就丢失了，消息超时可以配合死信队列（后面会讲到）使用，这样原本被丢弃的消息可以被再次保存起来，方便应用在此之后通过消费死信队列中的消息来诊断系统的运行概况。

案例中有一个局限，就是每条消息的超时时间都是一样的，都是固定的 EXPIRE_INTERVAL 值的大小。如果要实现自定义每条消息TTL的功能，那么应该如何处理呢？

这里还可以沿用消息的 timestamp 字段和拦截器 ConsumerInterceptor 接口的 onConsume() 方法，不过我们还需要消息中的 headers 字段来做配合。我们可以将消息的 TTL 的设定值以键值对的形式保存在消息的 headers 字段中，这样消费者消费到这条消息的时候可以在拦截器中根据 headers 字段设定的超时时间来判断此条消息是否超时，而不是根据原先固定的 EXPIRE_INTERVAL 值来判断。

下面我们来通过一个具体的示例来演示自定义消息 TTL 的实现方式。这里使用了消息的 headers 字段，而 headers 字段涉及 Headers 和 Header 两个接口，Headers 是对多个 Header 的封装，Header 接口表示的是一个键值对，具体实现如下：

```
package org.apache.kafka.common.header;

public interface Header {
    String key();
    byte[] value();
}
```

我们可以自定义实现 Headers 和 Header 接口，但这样未免过于烦琐，这里可以直接使用 Kafka 提供的实现类 org.apache.kafka.common.header.internals.RecordHeaders 和 org.apache.kafka.common.header.internals.RecordHeader。这里只需使用一个 Header，key 可以固定为“ttl”，而 value 用来表示超时的秒数，超时时间一般用 Long 类型表示，但是 RecordHeader 中的构造方法 RecordHeader(String key, byte[] value) 和 value() 方法的返回值对应的 value 都是 byte[] 类型，这里还需要一个小工具实现整型类型与 byte[] 的互转，具体实现如下：

```
public class BytesUtils {
    public static byte[] longToBytes(long res) {
        byte[] buffer = new byte[8];
        for (int i = 0; i < 8; i++) {
            int offset = 64 - (i + 1) * 8;
            buffer[i] = (byte) ((res >> offset) & 0xff);
        }
        return buffer;
    }

    public static long bytesToLong(byte[] b) {
        long values = 0;
        for (int i = 0; i < 8; i++) {
            values <<= 8; values|= (b[i] & 0xff);
        }
        return values;
    }
}
```

下面我们向 Kafka 中发送3条 TTL 分别为20秒、5秒和30秒的3条消息，主要代码如代码清单18-1所示。

```
代码清单18-1 发送自定义TTL消息的主要代码
ProducerRecord<String, String> record1 =
        new ProducerRecord<>(topic, 0, System.currentTimeMillis(),
                null, "msg_ttl_1",new RecordHeaders().add(new RecordHeader("ttl",
                        BytesUtils.longToBytes(20))));
ProducerRecord<String, String> record2 = //超时的消息
        new ProducerRecord<>(topic, 0, System.currentTimeMillis()-5*1000,
                null, "msg_ttl_2",new RecordHeaders().add(new RecordHeader("ttl",
                        BytesUtils.longToBytes(5))));
ProducerRecord<String, String> record3 =
        new ProducerRecord<>(topic, 0, System.currentTimeMillis(),
                null, "msg_ttl_3",new RecordHeaders().add(new RecordHeader("ttl",
                        BytesUtils.longToBytes(30))));
producer.send(record1).get();
producer.send(record2).get();
producer.send(record3).get();
```

ProducerRecord 中包含 Headers 字段的构造方法只有2个，具体如下：

```
public ProducerRecord(String topic, Integer partition, Long timestamp, K key, V value, Iterable<Header> headers)
public ProducerRecord(String topic, Integer partition, K key, V value, Iterable<Header> headers)
```

代码清单18-1中指定了分区编号为0和消息 key 的值为 null，其实这个示例中我们并不需要指定这2个值，但是碍于 ProducerRecord 中只有2种与 Headers 字段有关的构造方法。其实完全可以扩展 ProducerRecord 中的构造方法，比如添加下面这个方法：

```
//add by myself
public ProducerRecord(String topic, Long timestamp, 
                      V value, Iterable<Header> headers) {
    this(topic, null, timestamp, null, value, headers);
}
```

这样就可以修改代码清单18-1中 ProducerRecord 的构建方式，类似下面这种写法：

```
ProducerRecord<String,String> record1 =
        new ProducerRecord<>(topic, System.currentTimeMillis(),
                "msg_ttl_1", new RecordHeaders().add(new RecordHeader("ttl",
                BytesUtils.longToBytes(20))));
```

回归正题，很显然代码清单18-1中的第2条消息 record2 是故意被设定为超时的，因为这条消息的创建时间为 System.currentTimeMillis()-5×1000，往前推进了5秒，而这条消息的超时时间也为5秒。如果在发送这3条消息的时候也开启了消费者，那么经过拦截器处理后应该只会收到“msg_ttl_1”和“msg_ttl_3”这两条消息。

我们再来看一下经过改造之后拦截器的具体实现，如代码清单18-2所示。

```
代码清单18-2 自定义TTL的拦截器关键代码实现
@Override
public ConsumerRecords<String, String> onConsume(
        ConsumerRecords<String, String> records) {
    long now = System.currentTimeMillis();
    Map<TopicPartition, List<ConsumerRecord<String, String>>> newRecords
            = new HashMap<>();
    for (TopicPartition tp : records.partitions()) {
        List<ConsumerRecord<String, String>> tpRecords = records.records(tp);
        List<ConsumerRecord<String, String>> newTpRecords = new ArrayList<>();
        for (ConsumerRecord<String, String> record : tpRecords) {
            Headers headers = record.headers();
            long ttl = -1;
            for (Header header : headers) {//判断headers中是否有key为“ttl”的Header
                if (header.key().equalsIgnoreCase("ttl")) {
                    ttl = BytesUtils.bytesToLong(header.value());
                }
            }
            //消息超时判定
            if (ttl > 0 && now - record.timestamp() < ttl * 1000) {
                newTpRecords.add(record); 
            } else {//没有设置TTL，不需要超时判定
                newTpRecords.add(record);
            }
        }
        if (!newTpRecords.isEmpty()) {
            newRecords.put(tp, newTpRecords);
        }
    }
    return new ConsumerRecords<>(newRecords);
}
```

代码清单18-2中判断每条消息的 headers 字段中是否包含 key 为“ttl”的 Header，如果包含则对其进行超时判定；如果不包含，则不需要超时判定，即无须拦截处理。

使用这种方式实现自定义消息 TTL 时同样需要注意的是：使用类似中这种带参数的位移提交的方式，有可能会提交错误的位移信息。在一次消息拉取的批次中，可能含有最大偏移量的消息会被消费者拦截器过滤。不过这个也很好解决，比如在过滤之后的消息集中的头部或尾部设置一个状态消息，专门用来存放这一批消息的最大偏移量。

到目前为止，无论固定消息 TTL，还是自定义消息 TTL，都是在消费者客户端通过拦截器来实现的，其实这个功能也可以放在 Kafka 服务端来实现，而且具体实现也并不太复杂。不过这样会降低系统的灵活性和扩展性，并不建议这么做，通过扩展客户端就足以应对此项功能。

# 延时队列

队列是存储消息的载体，延时队列存储的对象是延时消息。所谓的“延时消息”是指消息被发送以后，并不想让消费者立刻获取，而是等待特定的时间后，消费者才能获取这个消息进行消费，延时队列一般也被称为“延迟队列”。注意延时与 TTL 的区别，延时的消息达到目标延时时间后才能被消费，而 TTL 的消息达到目标超时时间后会被丢弃。

延时队列的使用场景有很多，比如：

- 在订单系统中，一个用户下单之后通常有30分钟的时间进行支付，如果30分钟之内没有支付成功，那么这个订单将进行异常处理，这时就可以使用延时队列来处理这些订单了。
- 订单完成1小时后通知用户进行评价。
- 用户希望通过手机远程遥控家里的智能设备在指定时间进行工作。这时就可以将用户指令发送到延时队列，当指令设定的时间到了之后再将它推送到智能设备。

在 Kafka 的原生概念中并没有“队列”的影子，Kafka 中存储消息的载体是主题（更加确切地说是分区），我们可以把存储延时消息的主题称为“延时主题”，不过这种称谓太过于生僻。在其他消息中间件（比如 RabbitMQ）中大多采用“延时队列”的称谓，为了不让 Kafka 过于生分，我们这里还是习惯性地沿用“延时队列”的称谓来表示 Kafka 中用于存储延时消息的载体。

原生的 Kafka 并不具备延时队列的功能，不过我们可以对其进行改造来实现。Kafka 实现延时队列的方式也有很多种，在上一节中我们通过消费者客户端拦截器来实现消息的TTL，延时队列也可以使用这种方式实现。

不过使用拦截器的方式来实现延时的功能具有很大的局限性，某一批拉取到的消息集中有一条消息的延时时间很长，其他的消息延时时间很短而很快被消费，那么这时该如何处理呢？下面考虑以下这几种情况：

1. 如果这时提交消费位移，那么延时时间很长的那条消息会丢失。
2. 如果这时不继续拉取消息而等待这条延时时间很长的消息到达延时时间，这样又会导致消费滞后很多，而且如果位于这条消息后面的很多消息的延时时间很短，那么也会被这条消息无端地拉长延时时间，从而大大地降低了延时的精度。
3. 如果这个时候不提交消费位移而继续拉取消息，等待这条延时时间很长的消息满足条件之后再提交消费位移，那么在此期间这条消息需要驻留在内存中，而且需要一个定时机制来定时检测是否满足被消费的条件，当这类消息很多时必定会引起内存的暴涨，另一方面当消费很大一部分消息之后这条消息还是没有能够被消费，此时如果发生异常，则会由于长时间的未提交消费位移而引起大量的重复消费。



![11-1](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f33df9bd20358)



有一种改进方案，如上图所示，消费者在拉取一批消息之后，如果这批消息中有未到达延时时间的消息，那么就将这条消息重新写入主题等待后续再次消费。这个改进方案看起来很不错，但是当消费滞后很多（消息大量堆积）的时候，原本这条消息只要再等待5秒就能够被消费，但这里却将其再次存入主题，等到再次读取到这条消息的时候有可能已经过了半小时。由此可见，这种改进方案无法保证延时精度，故而也很难真正地投入现实应用之中。

在了解了拦截器的实现方式之后，我们再来看另一种可行性方案：在发送延时消息的时候并不是先投递到要发送的真实主题（real_topic）中，而是先投递到一些 Kafka 内部的主题（delay_topic）中，这些内部主题对用户不可见，然后通过一个自定义的服务拉取这些内部主题中的消息，并将满足条件的消息再投递到要发送的真实的主题中，消费者所订阅的还是真实的主题。

延时时间一般以秒来计，若要支持2小时（也就是 2×60×60 = 7200）之内的延时时间的消息，那么显然不能按照延时时间来分类这些内部主题。试想一个集群中需要额外的7200个主题，每个主题再分成多个分区，每个分区又有多个副本，每个副本又可以分多个日志段，每个日志段中也包含多个文件，这样不仅会造成资源的极度浪费，也会造成系统吞吐的大幅下降。

如果采用这种方案，那么一般是按照不同的延时等级来划分的，比如设定5s、10s、30s、1min、2min、5min、10min、20min、30min、45min、1hour、2hour这些按延时时间递增的延时等级，延时的消息按照延时时间投递到不同等级的主题中，投递到同一主题中的消息的延时时间会被强转为与此主题延时等级一致的延时时间，这样延时误差控制在两个延时等级的时间差范围之内（比如延时时间为17s的消息投递到30s的延时主题中，之后按照延时时间为30s进行计算，延时误差为13s）。虽然有一定的延时误差，但是误差可控，并且这样只需增加少许的主题就能实现延时队列的功能。



![11-2](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f33ebff40aee3)



如上图所示，生产者 Producer 发送若干延时时间不同的消息到主题 real_topic_A 和 real_topic_B 中，消费者 Consumer 订阅并消费主题 real_topic_A 和 real_topic_B 中的消息，对用户而言，他看到的就是这样一个流程。但是在内部，Producer 会根据不同的延时时间将消息划分为不同的延时等级，然后根据所划分的延时等级再将消息发送到对应的内部主题中，比如5s内的消息发送到 delay_topic_1，6s至10s的消息划分到 delay_topic_2 中。这段内部的转发逻辑需要开发人员对生产者客户端做一些改造封装，可以根据消息的 timestamp 字段、headers 字段（设置延时时间），以及生产者拦截器来实现具体的代码。

发送到内部主题（delay_topic_*）中的消息会被一个独立的 DelayService 进程消费，这个 DelayService 进程和 Kafka broker 进程以一对一的配比进行同机部署（参考下图），以保证服务的可用性。



![11-3](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f33fbd6033de7)



针对不同延时级别的主题，在 DelayService 的内部都会有单独的线程来进行消息的拉取，以及单独的 DelayQueue（这里用的是 JUC 中 DelayQueue）进行消息的暂存。与此同时，在 DelayService 内部还会有专门的消息发送线程来获取 DelayQueue 的消息并转发到真实的主题中。从消费、暂存再到转发，线程之间都是一一对应的关系。如下图所示，DelayService 的设计应当尽量保持简单，避免锁机制产生的隐患。



![11-4](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f34011850db03)



为了保障内部 DelayQueue 不会因为未处理的消息过多而导致内存的占用过大，DelayService 会对主题中的每个分区进行计数，当达到一定的阈值之后，就会暂停拉取该分区中的消息。

有些读者可能会对这里 DelayQueue 的设置产生疑惑，DelayQueue 的作用是将消息按照再次投递时间进行有序排序，这样下游的消息发送线程就能够按照先后顺序获取最先满足投递条件的消息。再次投递时间是指消息的时间戳与延时时间的数值之和，因为延时消息从创建开始起需要经过延时时间之后才能被真正投递到真实主题中。

同一分区中的消息的延时级别一样，也就意味着延时时间一样，那么对同一个分区中的消息而言，也就自然而然地按照投递时间进行有序排列，那么为何还需要 DelayQueue 的存在呢？因为一个主题中一般不止一个分区，分区之间的消息并不会按照投递时间进行排序，那么可否将这些主题都设置为一个分区呢？这样虽然可以简化设计，但同时却丢弃了动态扩展性，原本针对某个主题的发送或消费性能不足时，可以通过增加分区数进行一定程度上的性能提升。

前面我们也提到了，这种延时队列的实现方案会有一定的延时误差，无法做到秒级别的精确延时，不过一般应用对于延时的精度要求不会那么高，只要延时等级设定得合理，这个实现方案还是能够具备很大的应用价值。 那么有没有延时精度较高的实现方案？我们先来回顾一下前面的延时分级的实现方案，它首先将生产者生产的消息暂存到一个地方，然后通过一个服务去拉取符合再次投递条件的消息并转发到真实的主题。如下图所示，一般的延时队列的实现架构也大多类似。



![11-5](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f3408be357c55)



后台服务获取消息之后马上会转发到真实的主题中，而订阅此主题的消费者也就可以及时地消费消息，在这一阶段中并无太大的优化空间。反观消息从生产者到缓存再到后台服务的过程中需要一个等待延时时间的行为，在这个过程中有很大的空间来做进一步的优化。

我们在第8节中讲述过延时操作，其延时的精度很高，那么我们是否可以借鉴一下来实现延迟队列的功能呢？毕竟在 Kafka 中有现成的延时处理模块，复用一下也未尝不可。第一种思路，在生产者这一层面我们采取延时操作来发送消息，这样原本立刻发送出去的消息被缓存在了客户端中以等待延时条件的满足。这种思路有明显的弊端：如果生产者中缓存的消息过多，则必然引起内存的暴涨；消息可靠性也很差，如果生产者发生了异常，那么这部分消息也就丢失了，除非配套相应的重发机制。

第二种思路，在 Kafka 服务中增加一个前置缓存，生产者还是正常将消息发往 Kafka 中，Kafka 在判定消息是延时消息时（可以增加一个自定义协议，与发送普通消息的 PRODUCE 协议分开，比如 DELAY_PRODUCE，作为发送延时消息的专用协议）就将消息封装成延时操作并暂存至缓存中，待延时操作触发时就会将消息发送到真实的主题中，整体架构上与上图中所描述的类似。这种思路也有消息可靠性的问题，如果缓存延时操作的那台服务器宕机，那么消息也会随之丢失，为此我们可以引入缓存多副本的机制，如下图所示。



![11-6](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f341549da6ea1)



生产者发送的消息不单单发往一个缓存中，而是发往多个缓存，待所有缓存都收到消息之后才算发送成功，这一点和 Kafka 生产者客户端参数 acks = -1 的机理相通。每个 broker 中都会有一个延时操作的清理服务，彼此之间有主从的关系，任意时刻只有一个清理服务在工作，其余的清理服务都处于冷备状态。当某个延迟操作触发时会通知清理服务去清理其他延时操作缓存中对应的延时操作。这种架构虽然可以弥补消息可靠性的缺陷，但对于分布式架构中一些老生常谈的问题（比如缓存一致性、主备切换等）需要格外注意。

第二种思路还需要修改 Kafka 内核的代码，对开发人员源码的掌握能力及编程能力也是一个不小的挑战，后期系统的维护成本及 Kafka 社区的福利也是不得不考虑的问题。与此同时，这种思路和第一种思路一样会有内存暴涨的问题，单凭这个问题也可以判断出此种思路并不适合实际应用。

退一步思考，我们并不需要复用 Kafka 中的延时操作的模块，而是可以选择自己开发一个精度较高的延时模块，这里就用到了第7节中提及的时间轮的概念，所不同的是，这里需要的是单层时间轮。而且延时消息也不再是缓存在内存中，而是暂存至文件中。时间轮中每个时间格代表一个延时时间，并且每个时间格也对应一个文件，整体上可以看作单层文件时间轮，如下图所示。



![11-7](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f34257a089996)



每个时间格代表1秒，若要支持2小时（也就是 2×60×60 = 7200）之内的延时时间的消息，那么整个单层时间轮的时间格数就需要7200个，与此对应的也就需要7200个文件，听上去似乎需要庞大的系统开销，就单单文件句柄的使用也会耗费很多的系统资源。

其实不然，我们并不需要维持所有文件的文件句柄，只需要加载距离时间轮表盘指针（currentTime）相近位置的部分文件即可，其余都可以用类似“懒加载”的机制来维持：若与时间格对应的文件不存在则可以新建，若与时间格对应的文件未加载则可以重新加载，整体上造成的时延相比于延时等级方案而言微乎其微。随着表盘指针的转动，其相邻的文件也会变得不同，整体上在内存中只需要维持少量的文件句柄就可以让系统运转起来。

读者有可能会有疑问，这里为什么强调的是单层时间轮。试想一下，如果这里采用的是多层时间轮，那么必然会有时间轮降级的动作，那就需要将高层时间轮中时间格对应文件中的内容写入低层时间轮，高层时间格中伴随的是读取文件内容、写入低层时间轮、删除已写入的内容的操作，与此同时，高层时间格中也会有新的内容写入。

如果要用多层时间轮来实现，不得不增加繁重的元数据控制信息和繁杂的锁机制。对单层时间轮中的时间格而言，其对应的要么是追加文件内容，要么是删除整个文件（到达延时时间，就可以读取整个文件中的内容做转发，并删除整个文件）。采用单层时间轮可以简化工程实践，减少出错的可能，性能上也并不会比多层时间轮差。



![11-8](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f3439b1455bed)



采用时间轮可以解决延时精度的问题，采用文件可以解决内存暴涨的问题，那么剩下的还有一个可靠性的问题，这里就借鉴了前面的多副本机制，如上图所示。生产者同样将消息写入多个备份（单层文件时间轮），待时间轮转动而触发某些时间格过期时就可以将时间格对应的文件内容（也就是延时消息）转发到真实主题中，并且删除相应的文件。与此同时，还会有一个后台服务专门用来清理其他时间轮中相应的时间格。

单层文件时间轮的方案不需要修改 Kafka 内核的源码，与前面第二种思路相比实现较为简单。单层文件时间轮的方案与延时级别的实现方案一样可以将延时服务（上图中单层时间轮与后台服务的整合体）与Kafka进程进行一对一配比的同机部署，以保证整体服务的可用性。

总体上而言，对于延时队列的封装实现，如果要求延时精度不是那么高，则建议使用延时等级的实现方案，毕竟实现起来简单明了。反之，如果要求高精度或自定义延时时间，那么可以选择单层文件时间轮的方案。

## 死信队列和重试队列

由于某些原因消息无法被正确地投递，为了确保消息不会被无故地丢弃，一般将其置于一个特殊角色的队列，这个队列一般称为死信队列。后续分析程序可以通过消费这个死信队列中的内容来分析当时遇到的异常情况，进而可以改善和优化系统。

与死信队列对应的还有一个“回退队列”的概念，如果消费者在消费时发生了异常，那么就不会对这一次消费进行确认，进而发生回滚消息的操作之后，消息始终会放在队列的顶部，然后不断被处理和回滚，导致队列陷入死循环。为了解决这个问题，可以为每个队列设置一个回退队列，它和死信队列都是为异常处理提供的一种机制保障。实际情况下，回退队列的角色可以由死信队列和重试队列来扮演。

无论 RabbitMQ 中的队列，还是 Kafka 中的主题，其实质上都是消息的载体，换种角度看待问题可以让我们找到彼此的共通性。我们依然可以把 Kafka 中的主题看作“队列”，那么重试队列、死信队列的称谓就可以同延时队列一样沿用下来。 理解死信队列，关键是要理解死信。死信可以看作消费者不能处理收到的消息，也可以看作消费者不想处理收到的消息，还可以看作不符合处理要求的消息。比如消息内包含的消息内容无法被消费者解析，为了确保消息的可靠性而不被随意丢弃，故将其投递到死信队列中，这里的死信就可以看作消费者不能处理的消息。再比如超过既定的重试次数之后将消息投入死信队列，这里就可以将死信看作不符合处理要求的消息。

至于死信队列到底怎么用，是从 broker 端存入死信队列，还是从消费端存入死信队列，需要先思考两个问题：死信有什么用？为什么用？从而引发怎么用。在 RabbitMQ 中，死信一般通过 broker 端存入，而在 Kafka 中原本并无死信的概念，所以当需要封装这一层概念的时候，就可以脱离既定思维的束缚，根据应用情况选择合适的实现方式，理解死信的本质进而懂得如何去实现死信队列的功能。

重试队列其实可以看作一种回退队列，具体指消费端消费消息失败时，为了防止消息无故丢失而重新将消息回滚到 broker 中。与回退队列不同的是，重试队列一般分成多个重试等级，每个重试等级一般也会设置重新投递延时，重试次数越多投递延时就越大。举个例子：消息第一次消费失败入重试队列 Q1，Q1 的重新投递延时为5s，5s过后重新投递该消息；如果消息再次消费失败则入重试队列 Q2，Q2 的重新投递延时为10s，10s过后再次投递该消息。以此类推，重试越多次重新投递的时间就越久，为此还需要设置一个上限，超过投递次数就进入死信队列。重试队列与延时队列有相同的地方，都需要设置延时级别。它们的区别是：延时队列动作由内部触发，重试队列动作由外部消费端触发；延时队列作用一次，而重试队列的作用范围会向后传递。

## 消息路由

消息路由是消息中间件中常见的一个概念，比如在典型的消息中间件 RabbitMQ 中就使用路由键 RoutingKey 来进行消息路由。如下图所示，RabbitMQ 中的生产者将消息发送到交换器 Exchange 中，然后由交换器根据指定的路由键来将消息路由到一个或多个队列中，消费者消费的是队列中的消息。从整体上而言，RabbitMQ 通过路由键将原本发往一个地方的消息做了区分，然后让不同的消息者消费到自己要关注的消息。



![11-9](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f34726c737055)



Kafka 默认按照主题进行路由，也就是说，消息发往主题之后会被订阅的消费者全盘接收，这里没有类似消息路由的功能来将消息进行二级路由，这一点从逻辑概念上来说并无任何问题。从业务应用上而言，如果不同的业务流程复用相同的主题，就会出现消息接收时的混乱，这种问题可以从设计上进行屏蔽，如果需要消息路由，那么完全可以通过细粒度化切分主题来实现。



![11-10](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f347c667b0cb3)



除了设计缺陷，还有一些历史遗留的问题迫使我们期望 Kafka 具备一个消息路由的功能。如果原来的应用系统采用了类似 RabbitMQ 这种消息路由的生产消费模型，运行一段时间之后又需要更换为 Kafka，并且变更之后还需要保留原有系统的编程逻辑。对此，我们首先需要在这个整体架构中做一层关系映射，如上图所示。这里将 Kafka 中的消费组与 RabbitMQ 中的队列做了一层映射，可以根据特定的标识来将消息投递到对应的消费组中，按照 Kafka 中的术语来讲，消费组根据消息特定的标识来获取消息，其余的都可以被过滤。



![11-11](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f3484f71a4b7e)



具体的实现方式可以在消息的 headers 字段中加入一个键为“routingkey”、值为特定业务标识的 Header，然后在消费端中使用拦截器挑选出特定业务标识的消息。Kafka 中消息路由的实现架构如上图所示，消费组 ConsumerGroup1 根据指定的 Header 标识 rk2 和 rk3 来消费主题 TopicA 和 TopicB 中所有对应的消息而忽略 Header 标识为 rk1 的消息，消费组 ConsumerGroup2 正好相反。

这里只是演示作为消息中间件家族之一的 Kafka 如何实现消息路由的功能，不过消息路由在 Kafka 的使用场景中很少见，如无特殊需要，也不推荐刻意地使用它。

## 消息轨迹

在使用消息中间件时，我们时常会遇到各种问题：消息发送成功了吗？为什么发送的消息在消费端消费不到？为什么消费端重复消费了消息？对于此类问题，我们可以引入消息轨迹来解决。消息轨迹指的是一条消息从生产者发出，经由 broker 存储，再到消费者消费的整个过程中，各个相关节点的状态、时间、地点等数据汇聚而成的完整链路信息。生产者、broker、消费者这3个角色在处理消息的过程中都会在链路中增加相应的信息，将这些信息汇聚、处理之后就可以查询任意消息的状态，进而为生产环境中的故障排除提供强有力的数据支持。

对消息轨迹而言，最常见的实现方式是封装客户端，在保证正常生产消费的同时添加相应的轨迹信息埋点逻辑。无论生产，还是消费，在执行之后都会有相应的轨迹信息，我们需要将这些信息保存起来。这里可以参考 Kafka 中的做法，它将消费位移信息保存在主题 __consumer_offset 中。对应地，我们同样可以将轨迹信息保存到 Kafka 的某个主题中，比如下图中的主题 trace_topic。



![11-12](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f348dbc3b15b4)



生产者在将消息正常发送到用户主题 real_topic 之后（或者消费者在拉取到消息消费之后）会将轨迹信息发送到主题 trace_topic 中。这里有两种发送方式：第一种是直接通过 KafkaProducer 发送，为了不对普通的消息发送造成影响，可以采取“低功耗”的（比如异步、acks=0 等）发送配置，不过有可能会造成轨迹信息的丢失。

另一种方式是将轨迹信息保存到本地磁盘，然后通过某个传输工具（比如 Flume）来同步到 Kafka 中，这种方式对正常发送/消费逻辑的影响较小、可靠性也较高，但是需要引入额外的组件，增加了维护的风险。

消息轨迹中包含生产者、broker 和消费者的消息，但是上图中只提及了生产者和消费者的轨迹信息的保存而并没有提及 broker 信息的保存。生产者在发送消息之后通过确认信息来得知是否已经发送成功，而在消费端就更容易辨别一条消息是消费成功了还是失败了，对此我们可以通过客户端的信息反推出 broker 的链路信息。当然我们也可以在 broker 中嵌入一个前置程序来获得更多的链路信息，比如消息流入时间、消息落盘时间等。不过在 broker 内嵌前置程序，如果有相关功能更新，难免需要重启服务，如果只通过客户端实现消息轨迹，则可以简化整体架构、灵活部署，本节针对后者做相关的讲解。

一条消息对应的消息轨迹信息所包含的内容（包含生产者和消费者）如下表所示。

| 角 色  | 信 息 项               | 释 义                                                        |
| ------ | ---------------------- | ------------------------------------------------------------ |
| 生产者 |                        |                                                              |
|        | 消息ID                 | 能够唯一标识一条消息，在查询检索页面可以根据这个消息ID进行精准检索 |
|        | 消息Key                | 消息中的key字段                                              |
|        | 发送时间               | 消息发送的时间，指生产者的本地时间                           |
|        | 发送耗时               | 消息发送的时长，从调用send()方法开始到服务端返回的总耗时     |
|        | 发送状态               | 发送成功或发送失败                                           |
|        | 发送的目的地址         | Kafka集群地址，为broker准备的链路信息                        |
|        | 消息的主题             | 主题，为broker准备的链路信息                                 |
|        | 消息的分区             | 分区，为broker准备的链路信息                                 |
|        | 生产者的IP             | 生产者本地的IP地址                                           |
|        | 生产者的ID             | 生产者的唯一标识，可以用client.id替代                        |
|        | 用户自定义信息（Tags） | 用户自定义的一些附加属性，方便后期检索                       |
| 消费者 |                        |                                                              |
|        | 消息ID                 | 能够唯一标识一条消息                                         |
|        | 消息Key                | 消息中的key字段                                              |
|        | 接收时间               | 拉取到消息的时间，指消费者本地的时间                         |
|        | 消费耗时               | 消息消费的时长，从拉取到消息到业务处理完这条消息的总耗时     |
|        | 消费状态               | 消费成功或消费失败                                           |
|        | 重试次数               | 第几次重试消费                                               |
|        | 消费的源地址           | Kafka集群地址，为broker准备的链路信息，便于链路的串成        |
|        | 消息的主题             | 主题，为broker准备的链路信息，便于链路的串成                 |
|        | 消息的分区             | 分区，为broker准备的链路信息，便于链路的串成                 |
|        | 消费组                 | 消费组的名称                                                 |
|        | 消费者的IP             | 消费者本地的IP地址                                           |
|        | 消费者的ID             | 消费者的唯一标识，可以用client.id替代                        |
|        | 用户自定义信息（tags） | 用户自定义的一些附加属性，方便后期检索                       |



轨迹信息保存到主题 trace_topic 之后，还需要通过一个专门的处理服务模块对消息轨迹进行索引和存储，方便有效地进行检索。在查询检索页面进行检索的时候可以根据具体的消息 ID 进行精确检索，也可以根据消息的 key、主题、发送/接收时间进行模糊检索，还可以根据用户自定义的 Tags 信息进行有针对性的检索，最终查询出消息的一条链路轨迹。下图中给出一个链路轨迹的示例，根据这个示例我们可以清楚地知道某条消息所处的状态。



![11-13](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f34ee27b8881a)



## 消息审计

消息审计是指在消息生产、存储和消费的整个过程之间对消息个数及延迟的审计，以此来检测是否有数据丢失、是否有数据重复、端到端的延迟又是多少等内容。

目前与消息审计有关的产品也有多个，比如 Chaperone（Uber）、Confluent Control Center、Kafka Monitor（LinkedIn），它们主要通过在消息体（value 字段）或在消息头（headers 字段）中内嵌消息对应的时间戳 timestamp 或全局的唯一标识 ID（或者是两者兼备）来实现消息的审计功能。

内嵌 timestamp 的方式主要是设置一个审计的时间间隔 time_bucket_interval（可以自定义设置几秒或几分钟），根据这个 time_bucket_interval 和消息所属的 timestamp 来计算相应的时间桶（time_bucket）。

```
算法1：timestamp – timestamp % time_bucket_interval（这个算法在时间轮里也有提及）
算法2：(long)Math.floor((timestamp/time_bucket_interval) * time_bucket_interval)
```

根据上面的任意一种算法可以获得 time_bucket 的起始时间 time_bucket_start，那么这个 time_bucket 的时间区间可以记录为（time_bucket_start, time_bucket_start+time_bucket_interval），注意是左闭右开区间。每发送一条或消费一条消息，可以根据消息中内嵌的 timestamp 来计算并分配到相应的 time_bucket 中，然后对桶进行计数并存储，比如可以简单地存储到 Map<long time_bucket_start, long count> 中。

内嵌 ID 的方式就更加容易理解了，对于每一条消息都会被分配一个全局唯一标识 ID，这个和消息轨迹中的消息 ID 是同一个东西。如果主题和相应的分区固定，则可以为每个分区设置一个全局的 ID。当有消息发送时，首先获取对应的 ID，然后内嵌到消息中，最后才将它发送到 broker 中。消费者进行消费审计时，可以判断出哪条消息丢失、哪条消息重复。

如果还要计算端到端延迟，那么就需要在消息中内嵌 timestamp，也就是消息中同时含有 ID 和 timestamp，细心的读者可能注意到这两类信息在消息轨迹的功能中也都包含了进去。的确如此，我们可以将消息轨迹看作细粒度化的消息审计，而消息审计可以看作粗粒度化的消息轨迹。



![11-14](%E5%9B%BE%E8%A7%A3kafka%E4%B9%8B%E6%A0%B8%E5%BF%83%E5%8E%9F%E7%90%86.assets/169f350567878640)



消息审计的实现模型也和消息轨迹的类似，同样是通过封装自定义的 SDK 来实现的。上图中展示的是 Confluent Control Center的消息审计的实现模型，它通过生产者客户端和消费者客户端的拦截器来实现审计信息的保存，这里的审计信息同样保存到 Kafka 中的某个主题中，最后通过 Confluent Control Center 进行最终的信息处理和展示。如果读者需要类似消息审计的功能，不妨参照此类的实现。

# 消息中间件选型分析

消息中间件的选型是很多个人乃至公司都会面临的一个问题。 目前开源的消息中间件有很多，比如 ActiveMQ、RabbitMQ、Kafka、RocketMQ、ZeroMQ等。不管选择其中的哪一款，都会有用得不顺手的地方，毕竟不是为你量身定制的。有些“大厂”在长期的使用过程中积累了一定的经验，消息队列的使用场景也相对稳定固化，由于某种原因（比如目前市面上的消息中间件无法全部满足自身需求），并且它也具备足够的财力和人力而选择自研一款量身打造的消息中间件。但绝大多数公司还是选择不重复造轮子，那么选择一款合适的消息中间件就显得尤为重要了。就算是前者，在自研出稳定且可靠的相关产品之前还是会经历这样一个选型过程。

在整体架构中引入消息中间件，势必要考虑很多因素，比如成本及收益问题，怎么样才能达到最优的性价比？虽然消息中间件种类繁多，但各自都有侧重点，合适自己、扬长避短无疑是最好的方式。如果你对此感到从无所适从，本节的内容或许可以参考一二。

## 各类消息中间件简述

ActiveMQ 是 Apache 出品的、采用 Java 语言编写的、完全基于 JMS1.1 规范的、面向消息的中间件，为应用程序提供高效的、可扩展的、稳定和安全的企业级消息通信。不过由于历史包袱太重，目前市场份额没有后面三种消息中间件多，其最新架构被命名为 Apollo，号称下一代 ActiveMQ，有兴趣的读者可行自行了解。

RabbitMQ 是采用 Erlang 语言实现的 AMQP 协议的消息中间件，最初起源于金融系统，用于在分布式系统中存储和转发消息。RabbitMQ 发展到今天，被越来越多的人认可，这和它在可靠性、可用性、扩展性、功能丰富等方面的卓越表现是分不开的。

RocketMQ 是阿里开源的消息中间件，目前已经捐献给 Apache 基金会，它是由 Java 语言开发的，具备高吞吐量、高可用性、适合大规模分布式系统应用等特点，经历过“双11”的洗礼，实力不容小觑。

ZeroMQ 号称史上最快的消息队列，基于 C/C++ 开发。ZeroMQ 是一个消息处理队列库，可在多线程、多内核和主机之间弹性伸缩，虽然大多数时候我们习惯将其归入消息队列家族，但是和前面的几款有着本质的区别，ZeroMQ 本身就不是一个消息队列服务器，更像是一组底层网络通信库，对原有的 Socket API 上加上一层封装而已。

目前市面上的消息中间件还有很多，比如腾讯系的 PhxQueue、CMQ、CKafka，又比如基于 Go 语言的 NSQ，有时人们也把类似 Redis 的产品看作消息中间件的一种，当然它们都很优秀，但是篇幅限制无法穷极所有，下面会有针对性地挑选 RabbitMQ 和 Kafka 两款典型的消息中间件来进行分析，力求站在一个公平、公正的立场来阐述消息中间件选型中的各个要点。对于 RabbitMQ 感兴趣的读者可以参阅笔者的另一本著作[《RabbitMQ实战指南》](https://item.jd.com/12277834.html)，里面对 RabbitMQ 做了大量的详细介绍。

## 选型要点概述

### 1. 功能维度

衡量一款消息中间件是否符合需求，需要从多个维度进行考察，首要的就是功能维度，这个直接决定了能否最大程度地实现开箱即用，进而缩短项目周期、降低成本等。如果一款消息中间件的功能达不到需求，那么就需要进行二次开发，这样会增加项目的技术难度、复杂度，以及延长项目周期等。

功能维度又可以划分多个子维度，大致可以分为以下几个方面。

**优先级队列**：优先级队列不同于先进先出队列，优先级高的消息具备优先被消费的特权，这样可以为下游提供不同消息级别的保证。不过这个优先级也需要有一个前提：如果消费者的消费速度大于生产者的速度，并且 broker 中没有消息堆积，那么对发送的消息设置优先级也就没有什么实质性的意义了，因为生产者刚发送完一条消息就被消费者消费了，就相当于 broker 中至多只有一条消息，对于单条消息来说优先级是没有什么意义的。

**延时队列**：参考19节。

**重试队列**：参考20节。

**死信队列**：参考20节。

**消费模式**：消费模式分为推（push）模式和拉（pull）模式。推模式是指由 broker 主动推送消息至消费端，实时性较好，不过需要一定的流控机制来确保 broker 推送过来的消息不会压垮消费端。而拉模式是指消费端主动向 broker 请求拉取（一般是定时或定量）消息，实时性较推模式差，但可以根据自身的处理能力控制拉取的消息量。

**广播消费**：消息一般有两种传递模式：点对点（P2P，Point-to-Point）模式和发布/订阅（Pub/Sub）模式。对点对点的模式而言，消息被消费以后，队列中不会再存储消息，所以消息消费者不可能消费已经被消费的消息。虽然队列可以支持多个消费者，但是一条消息只会被一个消费者消费。发布/订阅模式定义了如何向一个内容节点发布和订阅消息，这个内容节点称为主题，主题可以认为是消息传递的中介，消息发布者将消息发布到某个主题，而消息订阅者从主题中订阅消息。主题使得消息的订阅者与消息的发布者互相保持独立，不需要进行接触即可保证消息的传递，发布/订阅模式在消息的一对多广播时采用。

RabbitMQ 是一种典型的点对点模式，而 Kafka 是一种典型的发布/订阅模式。但是在 RabbitMQ 中可以通过设置交换器类型来实现发布/订阅模式，从而实现广播消费的效果。Kafka 中也能以点对点的形式消费，完全可以把其消费组（consumer group）的概念看作队列的概念。不过对比来说，Kafka 中因为有了消息回溯功能，对广播消费的力度支持比 RabbitMQ 要强。

**回溯消费**：一般消息在消费完成之后就被处理了，之后再也不能消费该条消息。消息回溯正好相反，是指消息在消费完成之后，还能消费之前被消费的消息。对消息而言，经常面临的问题是“消息丢失”，至于是真正由于消息中间件的缺陷丢失，还是由于使用方的误用而丢失，一般很难追查。如果消息中间件本身具备消息回溯功能，则可以通过回溯消费复现“丢失的”消息，进而查出问题的源头。消息回溯的作用远不止于此，比如还有索引恢复、本地缓存重建，有些业务补偿方案也可以采用回溯的方式来实现。

**消息堆积+持久化**：流量削峰是消息中间件中的一个非常重要的功能，而这个功能其实得益于其消息堆积能力。从某种意义上来讲，如果一个消息中间件不具备消息堆积的能力，那么就不能把它看作一个合格的消息中间件。消息堆积分内存式堆积和磁盘式堆积。RabbitMQ 是典型的内存式堆积，但这并非绝对，在某些条件触发后会有换页动作来将内存中的消息换页到磁盘（换页动作会影响吞吐），或者直接使用惰性队列来将消息直接持久化至磁盘中。Kafka 是一种典型的磁盘式堆积，所有的消息都存储在磁盘中。一般来说，磁盘的容量会比内存的容量要大得多，磁盘式的堆积其堆积能力就是整个磁盘的大小。从另外一个角度讲，消息堆积也为消息中间件提供了冗余存储的功能。

**消息轨迹**：参考20节。

**消息审计**：参考20节。

**消息过滤**：消息过滤是指按照既定的过滤规则为下游用户提供指定类别的消息。以 Kafka 为例，完全可以将不同类别的消息发送至不同的主题中，由此可以实现某种意义的消息过滤，还可以根据分区对同一个主题中的消息进行二次分类。不过更加严格意义上的消息过滤应该是对既定的消息采取一定的方式，按照一定的过滤规则进行过滤。同样以 Kafka 为例，可以通过客户端提供的 ConsumerInterceptor 接口或 KafkaStreams 的 filter 功能进行消息过滤。

**多租户**：也可以称为多重租赁技术，是一种软件架构技术，主要用来实现多用户的环境下公用相同的系统或程序组件，并且仍可以确保各用户间数据的隔离性。RabbitMQ 就能够支持多租户技术，每一个租户表示为一个 vhost，其本质上是一个独立的小型 RabbitMQ 服务器，又有自己独立的队列、交换器及绑定关系等，并且它拥有自己独立的权限。vhost 就像是物理机中的虚拟机一样，它们在各个实例间提供逻辑上的分离，为不同程序安全、保密地运送数据，它既能将同一个 RabbitMQ 中的众多客户区分开，又可以避免队列和交换器等命名冲突。

**多协议支持**：消息是信息的载体，为了让生产者和消费者都能理解所承载的信息（生产者需要知道如何构造消息，消费者需要知道如何解析消息），它们就需要按照一种统一的格式来描述消息，这种统一的格式称为消息协议。有效的消息一定具有某种格式，而没有格式的消息是没有意义的。一般消息层面的协议有 AMQP、MQTT、STOMP、XMPP 等（消息领域中的 JMS 更多的是一个规范而不是一个协议），支持的协议越多，其应用范围就会越广，通用性越强，比如 RabbitMQ 能够支持 MQTT 协议就让其在物联网应用中获得一席之地。还有的消息中间件是基于本身的私有协议运转的，典型的如 Kafka。

**跨语言支持**：对很多公司而言，其技术栈体系中会有多种编程语言，如 C/C++、Java、Go、PHP 等，消息中间件本身具备应用解耦的特性，如果能够进一步支持多客户端语言，那么就可以将此特性的效能扩大。跨语言的支持力度也可以从侧面反映出一个消息中间件的流行程度。

**流量控制**：流量控制（flow control）针对的是发送方和接收方速度不匹配的问题，提供一种速度匹配服务来抑制发送速度，使接收方应用程序的读取速度与之相适应。通常的流控方法有 stop-and-wait、滑动窗口和令牌桶等。

**消息顺序性**：顾名思义，消息顺序性是指保证消息有序。这个功能有一个很常见的应用场景就是 CDC（Change Data Chapture），以 MySQL 为例，如果其传输的 binlog 的顺序出错，比如原本是先对一条数据加1，然后乘以2，发送错序之后就变成了先乘以2后加1了，造成了数据不一致。

**安全机制**：在 Kafka 0.9 之后就增加了身份认证和权限控制两种安全机制。身份认证是指客户端与服务端连接进行身份认证，包括客户端与 broker 之间、broker 与 broker 之间、broker 与 ZooKeeper 之间的连接认证，目前支持 SSL、SASL 等认证机制。权限控制是指对客户端的读写操作进行权限控制，包括对消息或 Kafka 集群操作权限控制。权限控制是可插拔的，并支持与外部的授权服务进行集成。RabbitMQ 同样提供身份认证（TLS/SSL、SASL）和权限控制（读写操作）的安全机制。

**消息幂等性**：为了确保消息在生产者和消费者之间进行传输，一般有三种传输保障（delivery guarantee）：At most once，至多一次，消息可能丢失，但绝不会重复传输；At least once，至少一次，消息绝不会丢，但可能会重复；Exactly once，精确一次，每条消息肯定会被传输一次且仅一次。大多数消息中间件一般只提供 At most once 和 At least once 两种传输保障，第三种一般很难做到，因此消息幂等性也很难保证。

Kafka 自 0.11 版本开始引入了幂等性和事务，Kafka 的幂等性是指单个生产者对于单分区单会话的幂等，而事务可以保证原子性地写入多个分区，即写入多个分区的消息要么全部成功，要么全部回滚，这两个功能加起来可以让 Kafka 具备 EOS（Exactly Once Semantic）的能力。不过如果要考虑全局的幂等，那么还需要从上下游各方面综合考虑，即关联业务层面，幂等处理本身也是业务层面需要考虑的重要议题。

以下游消费者层面为例，有可能消费者消费完一条消息之后没有来得及确认消息就发生异常，等到恢复之后又得重新消费原来消费过的那条消息，那么这种类型的消息幂等是无法由消息中间件层面来保证的。如果要保证全局的幂等，那么需要引入更多的外部资源来保证，比如以订单号作为唯一性标识，并且在下游设置一个去重表。

**事务性消息**：事务本身是一个并不陌生的词汇，事务是由事务开始（Begin Transaction）和事务结束（End Transaction）之间执行的全体操作组成的。支持事务的消息中间件并不在少数，Kafka 和 RabbitMQ 都支持，不过此两者的事务是指生产者发送消息的事务，要么发送成功，要么发送失败。消息中间件可以作为用来实现分布式事务的一种手段，但其本身并不提供全局分布式事务的功能。

下面是对 Kafka 与 RabbitMQ 功能的总结性对比及补充说明，如下表所示。

| 功 能 项   | Kafka（2.0.0版本）                                       | RabbitMQ（3.6.10版本）                                       |
| ---------- | -------------------------------------------------------- | ------------------------------------------------------------ |
| 优先级队列 | 不支持。不过可以改造支持，难度不大                       | 支持。建议优先级大小设置在0～10之间                          |
| 延时队列   | 不支持。不过可以改造支持                                 | 支持                                                         |
| 死信队列   | 不支持。不过可以改造支持                                 | 支持                                                         |
| 重试队列   | 不支持。不过可以改造支持                                 | 不支持。RabbitMQ中可以参考延时队列实现一个重试队列，二次封装比较简单。如果要在Kafka中实现重试队列，则得先实现延时队列的功能，相对比较复杂 |
| 消费模式   | 拉模式                                                   | 推模式+拉模式                                                |
| 广播消费   | 支持。Kafka对于广播消费的支持相对而言更加正统            | 支持，但力度较Kafka弱                                        |
| 回溯消费   | 支持。Kafka支持按照offset和timestamp两种维度进行回溯消费 | 不支持。RabbitMQ中消息一旦被确认消费就会被标记删除           |
| 消息堆积   | 支持                                                     | 支持。一般情况下，内存堆积达到特定阈值时会影响其性能，但这不是绝对的。如果考虑到吞吐量这个因素，Kafka的堆积效率比RabbitMQ总体上要高得多 |
| 持久化     | 支持                                                     | 支持                                                         |
| 消息轨迹   | 不支持，可以改造支持，详细参考11.5章节                   | 支持。RabbitMQ中可以采用Firehose或rabbitmq_tracing插件实现。不过开启rabbitmq_tracing插件件会大幅影响性能，不建议在生产环境中开启，反倒是可以使用Firehose与外部链路系统结合以提供高细腻度的消息轨迹支持 |
| 消息审计   | 不支持                                                   | 不支持                                                       |
| 消息过滤   | 客户端级别的支持                                         | 不支持。不过可以改造支持，难度不大                           |
| 多租户     | 支持                                                     | 支持                                                         |
| 多协议支持 | 只支持自定义协议                                         | RabbitMQ本身就是AMQP协议的实现，同时支持MQTT、STOMP等协议    |
| 跨语言支持 | 采用Scala和Java编写，支持多种语言的客户端                | 采用Erlang编写，支持多种语言的客户端                         |
| 流量控制   | 支持                                                     | RabbitMQ的流控基于Credit-Based算法，是内部被动触发的保护机制，作用于生产者层面 |
| 消息顺序性 | 支持单分区级别的顺序性                                   | 顺序性的条件比较苛刻，需要单线程发送、单线程消费，并且不采用延迟队列、优先级队列等一些高级功能，从某种意义上来说不算支持顺序性 |
| 安全机制   | 支持                                                     | 支持                                                         |
| 幂等性     | 支持单个生产者单分区单会话的幂等性                       | 不支持                                                       |
| 事务性消息 | 支持                                                     | 支持                                                         |



### 2. 性能维度

功能维度是消息中间件选型中的一个重要的参考维度，但这并不是唯一的维度。有时候性能比功能还重要，况且性能和功能很多时候是相悖的，“鱼和熊掌不可兼得”。Kafka 在开启幂等、事务功能的时候会使其性能降低，RabbitMQ 在开启 rabbitmq_tracing 插件的时候也会极大地影响其性能。消息中间件的性能一般是指其吞吐量，虽然从功能维度上来说，RabbitMQ 的优势要大于 Kafka，但是 Kafka 的吞吐量要比 RabbitMQ 高出1至2个数量级，一般 RabbitMQ 的单机 QPS 在万级别之内，而 Kafka 的单机 QPS 可以维持在十万级别，甚至可以达到百万级。

消息中间件的吞吐量始终会受到硬件层面的限制。就以网卡带宽为例，如果单机单网卡的带宽为 1Gbps，如果要达到百万级的吞吐，那么消息体大小不得超过（1GB/8）/1000000，约等于134B。换句话说，如果消息体大小超过 134B，那么就不可能达到百万级别的吞吐。这种计算方式同样适用于内存和磁盘。

时延作为性能维度的一个重要指标，却往往在消息中间件领域被忽视，因为一般使用消息中间件的场景对时效性的要求并不是很高，如果要求时效性完全可以采用 RPC 的方式实现。消息中间件具备消息堆积的能力，消息堆积越大也就意味着端到端的时延就越长，与此同时延时队列也是某些消息中间件的一大特色。那么为什么还要关注消息中间件的时延问题呢？消息中间件能够解耦系统，一个时延较低的消息中间件可以让上游生产者发送消息之后迅速返回，也可以让消费者更加快速地获取消息，在没有堆积的情况下可以让整体上下游的应用之间的级联动作更高效，虽然不建议在时效性很高的场景下使用消息中间件，但是如果使用的消息中间件在时延的性能方面比较优秀，那么对于整体系统的性能将会是一个不小的提升。

### 3. 可靠性和可用性

消息丢失是使用消息中间件时不得不面对的一个痛点，其背后的消息可靠性也是衡量消息中间件好坏的一个关键因素。尤其是在金融支付领域，消息可靠性尤为重要。然而说到可靠性必然要说到可用性，注意这两者之间的区别，消息中间件的可靠性是指对消息不丢失的保障程度；而消息中间件的可用性是指无故障运行的时间百分比，通常用几个9来衡量。

从狭义的角度来说，分布式系统架构是一致性协议理论的应用实现，对消息可靠性和可用性而言也可以追溯到消息中间件背后的一致性协议。Kafka 采用的是类似 PacificA 的一致性协议，通过 ISR（In-Sync-Replica）来保证多副本之间的同步，并且支持强一致性语义（通过 acks 实现）。对应的 RabbitMQ 是通过镜像环形队列实现多副本及强一致性语义的。多副本可以保证在 master 节点宕机异常之后可以提升 slave 作为新的 master 而继续提供服务来保障可用性。就目前而言，在金融支付领域使用 RabbitMQ 居多，而在日志处理、大数据等方面 Kafka 使用居多，随着 RabbitMQ 性能的不断提升和 Kafka 可靠性的进一步增强，相信彼此都能在以前不擅长的领域分得一杯羹。

这里还要提及的一方面是扩展能力，这里狭隘地将其归纳到可用性这一维度，消息中间件的扩展能力能够增强可用能力及范围，比如前面提到的 RabbitMQ 支持多种消息协议，这就是基于其插件化的扩展实现。从集群部署上来讲，归功于 Kafka 的水平扩展能力，基本上可以达到线性容量提升的水平，在 LinkedIn 实践介绍中就提及了部署超过千台设备的 Kafka 集群。

### 4. 运维管理

在消息中间件的使用过程中，难免会出现各种各样的异常情况，有客户端的，也有服务端的，那么怎样及时有效地进行监测及修复呢？业务线流量有峰值、低谷，尤其是电商领域，那么如何进行有效的容量评估，尤其是在大促期间？脚踢电源、网线被挖等事件层出不穷，如何有效地实现异地多活？这些都离不开消息中间件的衍生产品—运维管理。

运维管理也可以进一步细分，比如申请、审核、监控、告警、管理、容灾、部署等。

申请、审核很好理解，在源头对资源进行管控，既可以有效校正应用方的使用规范，配和监控也可以做好流量统计与流量评估工作，一般申请、审核与公司内部系统交融性较大，不适合使用开源类的产品。

监控、告警也比较好理解，对消息中间件的使用进行全方位的监控，既可以为系统提供基准数据，也可以在检测到异常的情况时配合告警，以便运维、开发人员迅速介入。除了一般的监控项（比如硬件、GC等），对于消息中间件还需要关注端到端时延、消息审计、消息堆积等方面。对 RabbitMQ 而言，最正统的监控管理工具莫过于 rabbitmq_management 插件了，社区内还有 AppDynamics、Collectd、DataDog、Ganglia、Munin、Nagios、New Relic、Prometheus、Zenoss 等多种优秀的产品。Kafka 在此方面也毫不逊色，比如 Kafka Manager、Kafka Monitor、Kafka Offset Monitor、Burrow、Chaperone、Confluent Control Center 等产品，尤其是 Cruise，还可以提供自动化运维的功能。

无论扩容、降级、版本升级、集群节点部署，还是故障处理，都离不开管理工具的应用，一个配套完备的管理工具集可以在遇到变更时做到事半功倍。故障可大可小，一般是一些应用异常，也可以是机器掉电、网络异常、磁盘损坏等单机故障，这些故障单机房内的多副本足以应付。如果是机房故障，那么就涉及异地容灾了，关键点在于如何有效地进行数据复制。对 Kafka 而言，可以参考 MirrorMarker、uReplicator 等产品，而 RabbitMQ 可以参考 Federation 和 Shovel。

### 5. 社区力度及生态发展

对于目前流行的编程语言而言，如 Java、Python，如果在使用过程中遇到了一些异常，基本上可以通过搜索引擎的帮助来解决问题，因为一个产品用的人越多，踩过的“坑”也就越多，对应的解决方案也就越多。对于消息中间件同样适用，如果你选择了一种“生僻”的消息中间件，可能在某些方面得心应手，但是版本更新缓慢，在遇到棘手问题时也难以得到社区的支持而越陷越深；相反如果你选择了一种“流行”的消息中间件，其更新力度大，不仅可以迅速弥补之前的不足，而且也能顺应技术的快速发展来变更一些新的功能，这样可以让你以“站在巨人的肩膀上”。在运维管理维度我们提及了 Kafka 和 RabbitMQ 都有一系列开源的监控管理产品，这些正是得益于其社区及生态的迅猛发展。

## 消息中间件选型误区探讨

在进行消息中间件选型之前可以先问自己一个问题：是否真的需要一个消息中间件？在搞清楚这个问题之后，还可以继续问自己一个问题：是否需要自己维护一套消息中间件？很多初创型公司为了节省成本会选择直接购买消息中间件有关的云服务，自己只需要关注收/发消息即可，其余的都可以外包出去。

很多人面对消息中间件时会有一种自研的冲动，你完全可以对 Java 中的 ArrayBlockingQueue 做一个简单的封装，也可以基于文件、数据库、Redis 等底层存储封装而形成一个消息中间件。消息中间件作为一个基础组件并没有想象中的那么简单，其背后还需要配套的管理来运维整个生态的产品集。自研还有会交接问题，如果文档不齐全、运作不规范将会带给新人带来噩梦般的体验。是否真的有自研的必要？如果不是 KPI 的压迫可以先考虑以下2个问题：

1. 目前市面上的消息中间件是否都无法满足目前的业务需求？
2. 团队是否有足够的能力、人力、财力和精力来支持自研？

很多人在进行消息中间件选型时会参考网络上的很多对比类的文章，但是其专业性、严谨性及其立场都有待考证，需要带着怀疑的态度去审视这些文章。比如有些文章会在没有任何限定条件及场景的情况下直接定义某款消息中间件最好，还有些文章没有指明消息中间件版本及测试环境就来做功能和性能对比分析，诸如此类的文章都可以弃之。

消息中间件选型犹如小马过河，选择合适的才最重要，这需要贴合自身的业务需求，技术服务于业务，大体上可以根据上一节提及的功能、性能等6个维度来一一进行筛选。更深层次的抉择在于你能否掌握其“魂”，了解其根本对于自己能够“对症下药”选择合适的消息中间件尤为重要。

消息中间件选型切忌一味地追求性能或功能，性能可以优化，功能可以二次开发。如果要在功能和性能方面做一个抉择，那么首选性能，因为总体上来说性能优化的空间没有功能扩展的空间大。然而对于长期发展而言，生态又比性能及功能都要重要。

很多时候，在可靠性方面也容易存在一个误区：想要找到一个产品来保证消息的绝对可靠，很不幸的是，世界上没有绝对的东西，只能说尽量趋于完美。想要尽可能保障消息的可靠性也并非单单靠消息中间件本身，还要依赖于上下游，需要从生产端、服务端和消费端这3个维度去努力保证。

消息中间件选型还有一个考量标准就是尽量贴合团队自身的技术栈体系，虽然说没有蹩脚的消息中间件，只有蹩脚的程序员，但是让一个 C 栈的团队去深挖 PhxQueue，总比去深挖 Scala 编写的 Kafka 要容易得多。

消息中间件大道至简：一发一存一消费，没有最好的消息中间件，只有最合适的消息中间件。