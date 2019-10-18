# Centos7 加硬盘

# Centos 增加硬盘

## 环境

在正常运行CentOS 7.1的机器上添加一块80G的新硬盘.

## 系统

```bash
# cat /etc/redhat-release
CentOS Linux release 7.1.1503 (Core)

# uname -a
Linux localhost.localdomain 3.10.0-229.el7.x86_64 #1 SMP Fri Mar 6 11:36:42 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux     
```

## 步骤：

- 关机、加硬盘、开机
- 查看硬盘是否识别到

```bash
        # fdisk -l

        Disk /dev/sda: 500.1 GB, 500107862016 bytes, 976773168 sectors
        Units = sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disk label type: dos
        Disk identifier: 0xf0b1ebb0

           Device Boot      Start         End      Blocks   Id  System
        /dev/sda1   *        4096   209723391   104859648    7  HPFS/NTFS/exFAT
        /dev/sda2       209723392   210747391      512000   83  Linux
        /dev/sda3       210747392   976773119   383012864   8e  Linux LVM

        Disk /dev/sdb: 80.0 GB, 80026361856 bytes, 156301488 sectors
        Units = sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disk label type: dos
        Disk identifier: 0x947748e0
```

- fdisk /dev/sdb 硬盘分区

```text
        # fdisk /dev/sdb
        Welcome to fdisk (util-linux 2.23.2).

            Changes will remain in memory only, until you decide to write them.
            Be careful before using the write command.


            Command (m for help): m  #帮助
            Command action
           a   toggle a bootable flag
           b   edit bsd disklabel
           c   toggle the dos compatibility flag
           d   delete a partition
           g   create a new empty GPT partition table
           G   create an IRIX (SGI) partition table
           l   list known partition types
           m   print this menu
           n   add a new partition
           o   create a new empty DOS partition table
           p   print the partition table
       q   quit without saving changes
   s   create a new empty Sun disklabel
   t   change a partition's system id
   u   change display/entry units
   v   verify the partition table
   w   write table to disk and exit
   x   extra functionality (experts only)

    Command (m for help): p  #查看分区

    Disk /dev/sdb: 80.0 GB, 80026361856 bytes, 156301488 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk label type: dos
    Disk identifier: 0x947748e0

       Device Boot      Start         End      Blocks   Id  System

    Command (m for help): n   #新建分区
    Partition type:
       p   primary (0 primary, 0 extended, 4 free)
       e   extended
    Select (default p): p    #主分区
    Partition number (1-4, default 1): 1    #分区个数
    First sector (2048-156301487, default 2048):     #使用所有，直接回车
    Using default value 2048
    Last sector, +sectors or +size{K,M,G} (2048-156301487, default 156301487): #直接回车
    Using default value 156301487
    Partition 1 of type Linux and of size 74.5 GiB is set

    Command (m for help): w
    The partition table has been altered!

    Calling ioctl() to re-read partition table.
    Syncing disks.
```

- 查看分区是否成功

```text
      ll /dev/sdb*
      brw-rw----. 1 root disk 8, 16 Apr 15 22:11 /dev/sdb
      brw-rw----. 1 root disk 8, 17 Apr 15 22:11 /dev/sdb1
```

- 格式化分区

```text
      # mkfs    #系统支持的文件系统格式
      mkfs         mkfs.btrfs   mkfs.cramfs  mkfs.ext2    mkfs.ext3    mkfs.ext4    mkfs.minix   mkfs.xfs

      # mkfs.xfs /dev/sdb1   #CentOS7.1 默认的文件系统为xfs，保存同系统一致
```

- 挂载新硬盘，并添加到 /etc/fstab自动挂载

```text
    mkdir /newdisk
    mount /dev/sdb1 /newdisk

      # vi /etc/fstab

      # /etc/fstab
      # Created by anaconda on Wed Apr 15 18:50:24 2015
      #
      # Accessible filesystems, by reference, are maintained under '/dev/disk'
      # See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
      #
      /dev/sdb1               /newdisk            xfs     defaults        0 0
```

- 重启验证一下

```text
  # df -hT
  Filesystem              Type      Size  Used Avail Use% Mounted on
  /dev/mapper/centos-root xfs        50G  1.1G   49G   3% /
  devtmpfs                devtmpfs  927M     0  927M   0% /dev
  tmpfs                   tmpfs     937M     0  937M   0% /dev/shm
  tmpfs                   tmpfs     937M  8.5M  928M   1% /run
  tmpfs                   tmpfs     937M     0  937M   0% /sys/fs/cgroup
  /dev/sdb1               xfs        75G   33M   75G   1% /newdisk
  /dev/mapper/centos-home xfs       312G   33M  312G   1% /home
  /dev/sda2               xfs       497M  121M  377M  25% /boot
```