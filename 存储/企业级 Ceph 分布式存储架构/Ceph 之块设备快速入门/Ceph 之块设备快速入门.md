# Ceph 之块设备快速入门

### 一、准备工作

本文描述如何安装 ceph 客户端，使用 Ceph 块设备 创建文件系统并挂载使用。

必须先完成 ceph 存储集群的搭建，并确保 Ceph 存储集群处于 active + clean 状态，这样才能使用 Ceph 块设备。

Ceph 块设备也叫 RBD 或 RADOS 块设备。

![img](assets/ditaa-b589d75957ebeea41fbc4c3af8afcf527d0ed169.png)

| hostname    | ip            |
| ----------- | ------------- |
| admin-node  | 192.168.0.130 |
| ceph-client | 192.168.0.134 |

注：你可以在虚拟机上运行 ceph-client 节点，但是不能在与 Ceph 存储集群（除非它们也用 VM ）相同的物理节点上执行下列步骤。

### 二、安装 Ceph

在 **ceph-client** 节点安装 Ceph。

1) 确认你使用了合适的内核版本

```
uname -r
//CentOS 内核要求 3.10.*
```

2) 安装 NPT

```
# sudo yum install ntp ntpdate ntp-doc
```

3) 安装 SSH

```
# sudo yum install openssh-server
```

4) 创建新用户

```
# sudo useradd -d /home/zeng -m zeng
# sudo passwd zeng
```

5) 确保新用户有 sudo 权限

```
# echo "zeng ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/zeng
# sudo chmod 0440 /etc/sudoers.d/zeng
```

6) 在管理节点上，将 ceph-client 添加到管理节点的 hosts 文件

```
$ sudo echo '192.168.0.134 ceph-client' >> /etc/hosts
```

7) 在管理节点上，允许管理节点无密码登录 ceph-client

```
$ ssh-copy-id zeng@ceph-client
```

8) 在管理节点上，通过 ceph-deploy 把 Ceph 安装到 ceph-client 节点

```
$ cd /home/zeng/my-cluster
$ ceph-deploy install ceph-client
```

9) 在管理节点上，用 ceph-deploy 把 Ceph 配置文件和 ceph.client.admin.keyring 拷贝到 ceph-client 。

```
$ ceph-deploy admin ceph-client
```

10) 修改密钥文件的权限
ceph-deploy 工具会把密钥环复制到 /etc/ceph 目录，要确保此密钥环文件有读权限：

```
# sudo chmod +r /etc/ceph/ceph.client.admin.keyring 
```

### 三、使用块存储

在 **ceph-client** 节点上操作。

1) 创建块设备映像 `{pool-name}/{image-name}`

存储池相关操作，可以参考 存储池

```
$ ceph osd pool create mypool 128
$ rbd create --size 1024 mypool/myimage --image-feature layering
$ rbd ls mypool
$ rbd info mypool/myimage
rbd image 'myimage':
    size 1024 MB in 256 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.31d606b8b4567
    format: 2
    features: layering
    flags:
// 这里通过 --image-feature  layering 指定了 features: layering，否则 map 可能出错
// 也可以将 rbd_default_features = 1 添加到 /etc/ceph/ceph.conf 的 [global]
```

2) 映射块设备 `{pool-name}/{image-name}`

```
$ sudo rbd map mypool/myimage --id admin
/dev/rbd0    # 注：rbd0 说明这是映射的第一个块设备

$ rbd showmapped
id pool   image   snap device    
0  mypool myimage -    /dev/rbd0    # 说明 myimage 映射到了 /dev/rbd0
```

事实上，创建的块设备映像，就在 `/dev/rbd/{pool-name}/` 下：

```
$ cd /dev/rbd/mypool
$ ll
lrwxrwxrwx. 1 root root 10 10月 25 09:34 myimage -> ../../rbd0
```

3) 使用块设备 `/dev/rbd/{pool-name}/{image-name}` 创建文件系统

```
$ sudo mkfs.xfs /dev/rbd/mypool/myimage
```

此命令可能耗时较长。

4) 将该文件系统挂载到 `/mnt/ceph-block-device` 文件夹下

```
$ sudo mkdir /mnt/ceph-block-device
$ sudo mount /dev/rbd/mypool/myimage /mnt/ceph-block-device

$ df -h
文件系统                 容量  已用  可用 已用% 挂载点
/dev/mapper/centos-root   17G  1.3G   16G    8% /
devtmpfs                 910M     0  910M    0% /dev
tmpfs                    920M     0  920M    0% /dev/shm
tmpfs                    920M  8.4M  912M    1% /run
tmpfs                    920M     0  920M    0% /sys/fs/cgroup
/dev/sda1               1014M  142M  873M   14% /boot
tmpfs                    184M     0  184M    0% /run/user/1000
/dev/rbd0                976M  2.6M  958M    1% /mnt/ceph-block-device
```

此时，就可以使用 `/mnt/ceph-block-device` 这个目录了。

5) 块设备扩容

```
//调整块设备大小为20G
$ rbd resize --size 20480 mypool/myimage
Resizing image: 100% complete...done.

//支持文件系统在线扩容
$ sudo resize2fs /dev/rbd0
resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/rbd0 is mounted on /mnt/ceph-block-device; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 3
The filesystem on /dev/rbd0 is now 5242880 blocks long.

//发现 /dev/rbd0 的容量变为20G
[zeng@ceph-client mnt]$ df -h
文件系统                 容量  已用  可用 已用% 挂载点
/dev/mapper/centos-root   17G  1.3G   16G    8% /
devtmpfs                 910M     0  910M    0% /dev
tmpfs                    920M     0  920M    0% /dev/shm
tmpfs                    920M  8.4M  912M    1% /run
tmpfs                    920M     0  920M    0% /sys/fs/cgroup
/dev/sda1               1014M  142M  873M   14% /boot
tmpfs                    184M     0  184M    0% /run/user/1000
/dev/rbd0                 20G  5.4M   19G    1% /mnt/ceph-block-device
```

6) 解挂文件系统

```
$ sudo umount /mnt/ceph-block-device
```

如果解挂提示"device is busy"，则先执行：

```
$ sudo yum install psmisc
$ fuser -m /mnt/ceph-block-device
$ kill -9 PID
```

7) 取消块设备映射

```
$ sudo rbd unmap /dev/rbd/mypool/myimage
$ rbd showmapped
```

8) 删除块设备

```
$ rbd rm mypool/myimage
Removing image: 100% complete...done.

$ rbd ls mypool
```