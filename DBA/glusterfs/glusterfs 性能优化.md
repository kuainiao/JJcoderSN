# glusterfs 性能配置优化

## 修改配置

> arch-img 为存储名称

## 命令合集



| 命令                                                         | 作用                                                 | 备注           |
| ------------------------------------------------------------ | ---------------------------------------------------- | -------------- |
| gluster volume set arch-img cluster.min-free-disk            | 默认是10% 磁盘剩余告警                               |                |
| gluster volume set arch-img cluster.min-free-inodes          | 默认是5% inodes 剩余告警                             |                |
| gluster volume set arch-img performance.read-ahead-page-count 8 | 默认4，预读取的数量                                  |                |
| gluster volume set arch-img performance.io-thread-count 16   | 默认16 io 操作的最大线程                             |                |
| gluster volume set arch-img network.ping-timeout 10          | 默认42s                                              |                |
| gluster volume set arch-img performance.cache-size 2GB       | 默认128M 或32MB，                                    |                |
| gluster volume set arch-img cluster.self-heal-daemon on      | 开启目录索引的自动愈合进程                           |                |
| gluster volume set arch-img cluster.heal-timeout 300         | 自动愈合的检测间隔，默认为600s                       | #3.4.2版本才有 |
| gluster volume set arch-img performance.write-behind-window-size 256MB | #默认是1M 能提高写性能单个文件后写缓冲区的大小默认1M |                |