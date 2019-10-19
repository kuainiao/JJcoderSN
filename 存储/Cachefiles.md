# Cachefiles

# 1.CacheFiles介绍

> NFS是一种经常使用到的`网络共享文件系统`，在分布式环境下，多台服务器的文件共享是一个问题。然而，对于这个问题，最常想到最容易做到的那就非NFS莫属了。那么如何来提高NFS文件的访问性能呢？加上缓存呗。没错。在linux下，有一个缓存文件系统叫FS-Cache，来缓存网络文件系统，如NFS。 FS-Cache是在linux内核版本2.6.30及以上版本引入的。在RHCE6.x 、CentOS6.x版本下可用。

为了使FS-Cache工作，需要缓存后端来提供实际存储。默认的缓存后端是cachefiles。因此，一旦设置了cachefiles，它会为NSF共享自动的启用文件缓存。

> FS-Cache是由David Howells开发的。当前的设计是对Andrew文件系统和网络文件系统的操作。 需要开启cachefilesd的守护进程来管理。该守护进程管理缓存文件和目录，将网络文件系统如AFS、NFS永久缓存到本地磁盘。

## 2.CacheFiles前提条件

需要本地文件系统支持用户自定义的扩展文件属性，如xattr。因为cachefiles使用xattr存储额外信息来维护缓存的。 ext4文件系统默认启用xattr。 如果是使用ext3文件系统，需要加上user_xattr选项。按照如下步骤操作：

```yml
    vim /etc/fstab
    /dev/sdb1 /data ext3 defaults,user_xattr 0 0
    # mount -o remount /data
    [warning] user_xattr针对缓存存储分区而言的。[/warning]
```

## 3. 安装

```
# yum install cachefilesd.x86_64
```

## 4. 配置

```yml
# vim /etc/cachefilesd.conf
dir /var/cache/fscache
tag mycache
brun 10%
bcull 7%
bstop 3%
frun 10%
fcull 7%
fstop 3%
# Assuming you're using SELinux with the default security policy included in
# this package
secctx system_u:system_r:cachefiles_kernel_t:s0
```

### 说明

```yml
dir: 缓存root目录。默认/var/cache/fscache。
tag: 指定一个FS-Cache标签，用来区分多个缓存。默认是"CacheFiles"。
secctx system_u:system_r:cachefiles_kernel_t:s0 ： 开启SELinux的话，需要更改安全上下文。
brun 10%, bcull 7%, bstop 3%, frun 10%, fcull 7%, fstop 3% ： 缓存策略。
```

## 5. 缓存剔除规则

缓存需要删除来释放空间，将最少使用的对象丢弃掉。cachefiles是基于访问时间来清除缓存的。空的目录如果不使用将删掉。

```bash
(*) brun
(*) frun
```

如果剩余空间和缓存中可用的文件数超过了上面的限制，缓存剔除关闭。

```bash
(*) bcull
(*) fcull
```

如果可用空间或缓存中的可用文件数量低于上面的限制，缓存剔除将开启。

```bash
(*) bstop
(*) fstop
```

如果可用空间或缓存中的可用文件数量低于上面任一限制，然后，没有进一步的分配磁盘空间或文件被允许直到再次超过上面限制。

必须按照下面原则设置：

```bash
    0 <= bstop < bcull < brun < 100
    0 <= fstop < fcull < frun < 100
```

[warning]这些都是可利用的空间和可用的文件的百分比.[/warning]

## 6. 缓存结构

cachefiles模块将在缓存root目录下自动创建两个子目录：cache和graveyard。 主动缓存对象存储于cache目录下。守护进程检测graveyard目录，并将删除任何出现在该目录中的缓存。

## 7. NFS挂载启用fsc选项

```yml
    # /etc/init.d/cachefilesd restart
    # mount -t nfs 10.31.247.202:/data /data/nfs/ -o fsc,remount
```

查看缓存状态

```
[warning]注意FSC列的值，如果是yes说明启用，否则没有。[/warning]
```

## 8. 测试

在没有使用`cachefiles`情况下：

在使用`cachefiles`情况下：

第一次耗时长，是由于第一次没有缓存。

## 9. 查看cachefiles统计信息

```
cat /proc/fs/fscache/stats
```