#### buffer工作原理

首先第一个概念是所有的这些proxy buffer参数是作用到每一个请求的。每一个请求会按照参数的配置获得自己的buffer。proxy buffer不是global而是per request的。

proxy_buffering 是为了开启response buffering of the proxied server，开启后proxy_buffers和proxy_busy_buffers_size参数才会起作用。

无论proxy_buffering是否开启，proxy_buffer_size（main buffer）都是工作的，proxy_buffer_size所设置的buffer_size的作用是用来存储upstream端response的header。

在proxy_buffering 开启的情况下，Nginx将会尽可能的读取所有的upstream端传输的数据到buffer，直到proxy_buffers设置的所有buffer们被写满或者数据被读取完(EOF)。此时nginx开始向客户端传输数据，会同时传输这一整串buffer们。同时如果response的内容很大的话，Nginx会接收并把他们写入到temp_file里去。大小由proxy_max_temp_file_size控制。如果busy的buffer传输完了会从temp_file里面接着读数据，直到传输完毕。

一旦proxy_buffers设置的buffer被写入，直到buffer里面的数据被完整的传输完（传输到客户端），这些buffer将会一直处在busy状态，我们不能对这些buffer进行任何别的操作。所有处在busy状态的buffer size加起来不能超过proxy_busy_buffers_size，所以proxy_busy_buffers_size是用来控制同时传输到客户端的buffer数量的。

后面是这几个参数的补充：

#### 相关参数

##### proxy_buffer_size

**语法: proxy_buffer_size the_size**

**默认值: proxy_buffer_size 4k/8k**

**上下文: http, server, location**

该指令设置缓冲区大小,从代理后端服务器取得的第一部分的响应内容,会放到这里.

小的响应header通常位于这部分响应内容里边.

默认来说,该缓冲区大小等于指令 proxy_buffers所设置的;但是,你可以把它设置得更小.

##### proxy_buffering

**语法: proxy_buffering on|off**

**默认值: proxy_buffering on**

**上下文: http, server, location**

该指令开启从后端被代理服务器的响应内容缓冲.

如果缓冲区开启,nginx假定被代理的后端服务器会以最快速度响应,并把内容保存在由指令proxy_buffer_size 和 proxy_buffers指定的缓冲区里边.

如果响应内容无法放在内存里边,那么部分内容会被写到磁盘上。

如果缓冲区被关闭了,那么响应内容会按照获取内容的多少立刻同步传送到客户端。

nginx不尝试计算被代理服务器整个响应内容的大小,nginx能从服务器接受的最大数据,是由指令proxy_buffer_size指定的.

对于基于长轮询(long-polling)的Comet 应用来说,关闭 proxy_buffering 是重要的,不然异步响应将被缓存导致Comet无法工作

##### proxy_buffers

**语法: proxy_buffers the_number is_size;**

**默认值: proxy_buffers 8 4k/8k;**

**上下文: http, server, location**

该指令设置缓冲区的大小和数量,从被代理的后端服务器取得的响应内容,会放置到这里. 默认情况下,一个缓冲区的大小等于内存页面大小,可能是4K也可能是8K,这取决于平台。

##### proxy_busy_buffers_size

**语法: proxy_busy_buffers_size size;**

**默认值: proxy_busy_buffers_size proxy_buffer_size \* 2;**

**上下文: http, server, location, if**