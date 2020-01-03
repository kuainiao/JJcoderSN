# Ceph 之集群存储池

## 一、存储池介绍

<http://docs.ceph.org.cn/rados/operations/pools/>

如果你开始部署集群时没有创建存储池， Ceph 会用默认存储池 `rbd` 存数据。存储池提供的功能：

- 自恢复力： 你可以设置在不丢数据的前提下允许多少 OSD 失效，对多副本存储池来说，此值是一对象应达到的副本数。典型配置存储一个对象和它的一个副本（即 size = 2 ），但你可以更改副本数；对纠删编码的存储池来说，此值是编码块数（即纠删码配置里的 m=2 ）。
- 归置组： 你可以设置一个存储池的归置组数量。典型配置给每个 OSD 分配大约 100 个归置组，这样，不用过多计算资源就能得到较优的均衡。配置了多个存储池时，要考虑到这些存储池和整个集群的归置组数量要合理。
- CRUSH 规则： 当你在存储池里存数据的时候，与此存储池相关联的 CRUSH 规则集可控制 CRUSH 算法，并以此操纵集群内对象及其副本的复制（或纠删码编码的存储池里的数据块）。你可以自定义存储池的 CRUSH 规则。
- 快照： 用 ceph osd pool mksnap 创建快照的时候，实际上创建了某一特定存储池的快照。
- 设置所有者： 你可以设置一个用户 ID 为一个存储池的所有者。

要把数据组织到存储池里，你可以列出、创建、删除存储池，也可以查看每个存储池的利用率。 

## 二、存储池命令

### 1. 列出存储池

```
$ rados lspools
rbd
libvirt-pool

$ ceph osd lspools
0 rbd,2 libvirt-pool
```

在新安装好的集群上，只有一个 rbd 存储池。

### 2. 创建存储池

```
ceph osd pool create {pool-name} {pg-num}
```

pool-name : 存储池名称，必须唯一。
pg-num : 存储池拥有的归置组总数。

- 少于 5 个 OSD 时可把 pg_num 设置为 128
- OSD 数量在 5 到 10 个时，可把 pg_num 设置为 512
- OSD 数量在 10 到 50 个时，可把 pg_num 设置为 4096

### 3. 设置存储池配额

```
ceph osd pool set-quota {pool-name} [max_objects {obj-count}] [max_bytes {bytes}]
```

要取消配额，设置为 0 。

### 4. 删除存储池

```
ceph osd pool delete {pool-name} [{pool-name} --yes-i-really-really-mean-it]
```

### 5. 重命名存储池

```
ceph osd pool rename {current-pool-name} {new-pool-name}
```

### 6. 查看存储池统计信息

```
rados df
```

### 7. 生成存储池快照

```
ceph osd pool mksnap {pool-name} {snap-name}
```

### 8. 删除存储池快照

```
ceph osd pool rmsnap {pool-name} {snap-name}
```

### 9. 调整存储池选项值

```
ceph osd pool set {pool-name} {key} {value}
```

### 10. 获取存储池选项值

```
ceph osd pool get {pool-name} {key}
```

### 11. 设置对象副本数

设置多副本存储池的对象副本数：

```
ceph osd pool set {poolname} size {num-replicas}
```

> Important：{num-replicas} 包括对象自身，如果你想要对象自身及其两份拷贝共计三份，指定 3 。

确保数据存储池里任何副本数小于 min_size 的对象都不会收到 I/O :

```
ceph osd pool set data min_size 2
```

### 12. 获取对象副本数

```
ceph osd dump | grep 'replicated size'
```

Ceph 会列出存储池，且高亮 replicated size 属性。默认情况下， Ceph 会创建一对象的两个副本（一共三个副本，或 size 值为 3 ）。

