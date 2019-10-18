## Linux kernel 的 sendfile 是如何提高性能的

现在流行的 web 服务器里面都提供 sendfile 选项用来提高服务器性能，那到底 sendfile 是什么，怎么影响性能的呢？sendfile 实际上是 Linux 2.0+ 以后的推出的一个系统调用，web 服务器可以通过调整自身的配置来决定是否利用 sendfile 这个系统调用。先来看一下不用 sendfile 的传统网络传输过程：

> read(file, tmp_buf, len);
> write(socket, tmp_buf, len);
>
> 硬盘 >> kernel buffer >> user buffer >> kernel socket buffer >> 协议栈

一般来说一个网络应用是通过读硬盘数据，然后写数据到 socket 来完成网络传输的。上面2行用代码解释了这一点，不过上面2行简单的代码掩盖了底层的很多操作。来看看底层是怎么执行上面2行代码的：

1、系统调用 read() 产生一个上下文切换：从 user mode 切换到 kernel mode，然后 DMA 执行拷贝，把文件数据从硬盘读到一个 kernel buffer 里。
2、数据从 kernel buffer 拷贝到 user buffer，然后系统调用 read() 返回，这时又产生一个上下文切换：从kernel mode 切换到 user mode。
3、系统调用 write() 产生一个上下文切换：从 user mode 切换到 kernel mode，然后把步骤2读到 user buffer 的数据拷贝到 kernel buffer（数据第2次拷贝到 kernel buffer），不过这次是个不同的 kernel buffer，这个 buffer 和 socket 相关联。
4、系统调用 write() 返回，产生一个上下文切换：从 kernel mode 切换到 user mode（第4次切换了），然后 DMA 从 kernel buffer 拷贝数据到协议栈（第4次拷贝了）。

上面4个步骤有4次上下文切换，有4次拷贝，我们发现如果能减少切换次数和拷贝次数将会有效提升性能。在kernel 2.0+ 版本中，系统调用 sendfile() 就是用来简化上面步骤提升性能的。sendfile() 不但能减少切换次数而且还能减少拷贝次数。

再来看一下用 sendfile() 来进行网络传输的过程：

> sendfile(socket, file, len);
>
> 硬盘 >> kernel buffer (快速拷贝到kernel socket buffer) >> 协议栈

1、系统调用 sendfile() 通过 DMA 把硬盘数据拷贝到 kernel buffer，然后数据被 kernel 直接拷贝到另外一个与 socket 相关的 kernel buffer。这里没有 user mode 和 kernel mode 之间的切换，在 kernel 中直接完成了从一个 buffer 到另一个 buffer 的拷贝。
2、DMA 把数据从 kernel buffer 直接拷贝给协议栈，没有切换，也不需要数据从 user mode 拷贝到 kernel mode，因为数据就在 kernel 里。

步骤减少了，切换减少了，拷贝减少了，自然性能就提升了。这就是为什么说在 Nginx 配置文件里打开 sendfile on 选项能提高 web serve r性能的原因。（参见：[64MB VPS 上优化Nginx](http://www.vpsee.com/2009/06/64mb-vps-optimize-nginx/)）