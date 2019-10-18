# NFS and AFS

------

# 简介

> 对于像 NFS 和 AFS这种网络文件系统而言，因为受网络的影响，使得对数据访问和存储的实时性就有了一定的挑战，特别是在早期100Mb/s的网络环境下（当然10Mb/s的网络环境就是一个噩耗了）。为了解决响应实效的问题，一种被称为CacheFS的本地缓存方案被开发出来，用来提供分布式文件系统的本地缓存。 作为内核2.6.30的一部分，一种CacheFS 实现机制 已经加入进来，当前它支持NFS和AFS，但是其他文件系统也能从中获得好处

## 什么是FS-Cache和CacheFS

FS-Cache 是指在文件系统和缓存之间的接口。 CacheFS 指的则是FS-cache的缓存后端。CacheFS做实际的数据存储和检索处理，并使用块设备的分区。 CacheFS并不能用在任何文件系统上，文件系统必须能被FS-Cache写入。FS-Cache可以使用任何一种它想要的缓存机制（使用缓存接口），文件系统本身并不关心使用何种缓存机制。AFS和NFS都能使用FSCache来修改。2.6.30核心已经包含了能够利用FS-Cache的修改版。 一图胜千言，下图给出了使用FS-Cache和CacheFS的通用数据流图。

图一: FS-Cache, CacheFS, 和 CacheFiles在上图里，NFS/AFS/ISOFS?我们一般称为netfs?调用FS-Cache，而FS-Cache则调用CacheFile或者CacheFS函数，这是两种不同的数据缓存实现机制。FS-Cache都可以调用。这样因为FC-Cache的原因，左边的文件系统就可以直接使用缓存而不必知道具体的实现机制。注意：CacheFS使用的是块设备上的分区(这里是/dev/hda5)，而CacheFiles则使用缺省的/var/fscache目录来缓存文件。 下图给出了更多的细节

图二: FS-Cache, CacheFS, and CacheFiles 的更多细节此图显示了netfs文件系统是如何和FS-Cache进行通讯的，以及FS-Cache是如何和CacheFS或者CacheFiles通讯的。我们也注意到netfs也需要和VFS进行通讯，这显然的，毕竟CacheFS仅仅只是用来做数据缓存，而并不是来实现一个完整的文件系统，而在当前Linux里，所有的文件系统都需要和VFS打交道，以保证应用程序对不同的文件系统保持透明。 FS-Cache背后的关键概念是：在透过缓存访问netfs上的文件之前，FS-Cache并不要求该文件被完整的载入到缓存中。这是因为：

没有缓存的情况下也必须能操作 必须能够打开比大于缓存大小的文件 所有打开的远程文件的大小不应该受到缓存大小的限制 如果一次只是访问某个远程的某一个部分，不应该强迫用户要缓存整个文件 所以，FS-Cache是建立在页(page)的概念上，而不是文件。否则的话，即便是读取一个字节的内容，也需要缓存整个文件的。 FS-Cache的实现提供了下面的一些特性： 可以使用多个缓存。用标签(tag)来区分识别 缓存可以在多个netfs之间共享。共享时，每个netfs的共享数据是相互独立的。另外，它也并不会把同一个文件的试图关联起来。比如，如果一个文件同时被NFS和CIFS读，那么在缓存里将会有两份拷贝。 任何时刻缓存都增加或者删除 netfs提供了一个接口，允许任何一方从文件回退缓存The netfs is provided with an interface that allows either party (netfsor FS-Cache) to withdraw caching facilities from a file netfs的接口应该尽可能少的返回错误，宁可让netfs无视这些The interface to the netfs returns as few errors as possible, preferring to let the netfs remain oblivious 数据IO直接和netfs的page打交道 尽可能异步 使用CacheFS 或者 CacheFiles

使用FS-Cache和CacheFS/CacheFiles 是相当简单的。首先确保内核是否支持。你可以在内核源代码目录检查.config文件.确保FS-Cache和CacheFS都被选中。 另外，确保NFS Client Caching Support 也被选中了。 第二步是确保nfsutils 是最新的，建议你下载最新版本，并编译安装。 第三步是编译安装最新的cachefilesd。目前最新版本是0.9,安装cachefilesd需要创建/etc/cachefilesd.conf文件，用来控制FS-Cache和CacheFS(或CacheFiles)的行为。格式很简单，详细情况，请猛击这个HOWTO文档。 配置文件里第一步是定义缓存的位置，你可以把缓存的位置定义在系统安装分区上，当然你可以使用SD卡或者USB硬盘来作为缓存路径，不过性能上可能会差一些。当然，如果机器上有空闲的空间，使用新的分区来做存储路径也不错。如果你足够有钱，使用固态盘(SSD)会有更好的性能。 我们这里举的例子是采取一个分区来当做存储目录。这个分区应该做成支持extended attributes (xattr)的文件系统，大部分Linux下的文件系统都支持这个特性，包括ext 2/3/4,xfs,reiserfs,jfs等，这里使用ext3文件系统。 首先使用 mkfs.ext3 /dev/sda1 格式化 然后使用 tune2fs -o user_xattr /dev/sda1 打开xattr特性。 接下来，在/etc/fstab加入下面这行： /dev/sda1 /var/fscache ext3 defaults,user_xattr 0 0 以上步骤对CacheFS和CacheFiles都适合。下一步就是启动cachefilesd服务了 % service cachefilesd start 如果没有报错，在/var/fscache目录，你应该可以看到下面这两个新创建的目录：

## [#](http://www.liuwq.com/views/linux基础/AFS与NFS.html#cache)cache

graveyard 如果你查看/var/fscache/cache目录，你会看到一些奇怪的文件名，这意味着到目前为止一切OK。但是在使用这些你看到的文件之前，你需要确保netfs使用缓存。 比如，NFS能够使用FS-Cache 和 CacheFS/CacheFiles. 只需要一个fsc挂载参数就可以做到。就像下面这样的命令：% mount -o fsc bigserver:/group-data /mnt/group-data 这里”bigserver”是NFS服务器的机器名，/group-data是导出的共享目录。客户端把它挂载到/mnt/group-data目录上。关键的地方就是这个-o fsc参数。 netfs挂载后，缓存并不会自动开始工作，只有发生了读或者写的操作后，缓存才会工作，如果你在/var/fscache/cache里看到了新创建的文件，那就表示缓存功能已经激活了。 缓存并不关心你的NFS挂载的时候使用的是哪个版本,v2,v3,v4都是支持的，但是有些区别： 对于V2和V3,因为协议的限制，直接IO（Direct IO）和并发写是不支持的。 而NFS v4提供较好的锁机制，使得写缓存或直接IO是支持的，因此确保你挂载时，使用的版本是v4. 那么我如何直到CacheFS工作得如何呢？我们有一些统计和观察的方法。首先请确保使用上面的方法激活了缓存。在/proc文件系统里，有一些统计信息在里面，如果你想查看这些信息，先确保你运行的核心打开下面的两个参数： CONFIG_FSCACHE_STATS=y CONFIG_FSCACHE_HISTOGRAM=y 那么你就可以从下面两个位置能看到一些信息了： /proc/fs/fscache/stats /proc/fs/fscache/histograms 对这些信息的详细解释，这里就不展开了，感兴趣的可以参考相应的文档。

## [#](http://www.liuwq.com/views/linux基础/AFS与NFS.html#总结)总结

这篇文档对FS-Cache和CacheFS做了一个大致的介绍。FS-Cache的目标是为本地数据缓存提供一个中心点，同时报纸原始文件系统与缓存机制的无关性。而CacheFS则是实际用来缓存文件系统，它被FS-Cache用来调用当做缓存的功能。CacheFS使用块设备的分区来存储缓存数据，当然FS-Cache也能够使用CacheFiles来当做缓存功能。 CacheFS已经进入到了2.6.30的官方核心里，它将用在新的文件系统里。NFS和AFS都已经准备使用FS-Cache+CacheFS/CacheFiles了。 FS-Cache另外的一个使用领域就是用来缓存本地文件系统，目前，文件系统都是依赖内核来缓存数据和调度相关IO操作，缓存不是直接受你的控制。 FS-Cache使用非常大的缓存（比磁盘缓存大很多）时，读的性能有了非常大的提升，而且对于那些有着很好的写性能的文件系统，比如 NILFS ，使用FS-Cache和CacheFS也能显著提升读的性能。 但是，本地系统可能需要某种关机自动备份的功能用来确保数据从缓存写入到实际的文件系统里。 FS-Cahce和CacheFS/CacheFiles的另外一个使用领域就是对压缩文件系统?比如SquashFS?产生影响。SquashFS是压缩的文件系统，采取只读挂载的方式。因为FS-Cache的确有帮助提升读性能的能力，因此将它和SquashFS联合起来是有好处的。 而且，SquashFS使用FS-Cache后变得可以被修改，对，就是能够被修改。 最后，如果你在桌面，笔记本，客户端使用NFS，那么你有足够的理由来尝试FS-Cache和CacheFS/CacheFiles，它能给你性能上的提升。