# ***\*kvm虚拟化\****

# ***\*目录\****

[kvm软件安装](#_kvm软件安装)

[guest os安装](#_guest os安装)

[kvm存储](#_kvm存储)

[kvm管理](#_kvm管理)

[脚本管理kvm](#_脚本管理kvm)

 

什么是虚拟化

kvm在工作当中有什么用

kvm在面试过程当中有什么用

安装kvm

管理使用kvm

kvm管理脚本

1 准备 centos7.6 镜像

2 装一个带图形的虚拟机 配置：内存最高配置 硬盘最少留50G  

3 装好的虚拟机里边准备一个最小化的系统镜像（版本没有要求）

4 打开虚拟机虚拟化功能

5 安装kvm  #yum install *virt* *qemu* （librbd1-devel出问题可以装一下） -y 

Yum install libvirt qemu-kvm virt-manager

若安装不成功 解决：依赖关系 兼容性相关的包

问题：卡在安装虚拟机的后半部分

解决：不能提前安装epel yum yum源

\# yum upgrade  -y（重装系统）

问题：iso镜像没有烤贝全

6 在kvm里面安装系统

企业级虚拟化和桌面虚拟化的区别？

 

桌面级虚拟化：

app

guestos

vmware-workstation(hypervisor+图形管理工具)

os

硬件

 

企业级虚拟化：

app（图形管理工具）

guestos

os+hypervisor

硬件

 

常用的虚拟化产品都有哪些？

\1. kvm(redhat)  熟悉kvm 了解其他虚拟化产品

\2. vmware(vmware公司)

vmware-workstation(windows和linux)

vmware-fusion(mac)

  vmware-esxi(企业级别)

\3. hyper-v(微软)

\4. ovm(oracle公司--windows linux)  virtulbox

\5. xen(rhel6之前所有版本默认用的虚拟化产品)

 

虚拟化分类

平台级虚拟化

资源虚拟化

应用程序虚拟化

 

虚拟化技术分类

操作系统级别虚拟化

部分虚拟化

完全虚拟化

硬件辅助虚拟化

 

宿主机 guestos

 

vps 虚拟专用服务器

云主机

# ***\*kvm软件安装\****

环境准备

查看CPU是否支持VT技术: 

\# cat /proc/cpuinfo | grep -E 'vmx|svm'

   flags : fpu vme de pse tsc msr pae mce cx8 apicmtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2

   ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts rep_good aperfmperf pni dtes64 monitor ds_cpl vmx tm2 ssse3 cx16

   xtpr pdcm dca sse4_1 lahf_lm dts tpr_shadow vnmi flexpriority

 

内核版本需求(rhel6以上):  

  \# uname  -r

  2.6.32-358.el6.x86_64 

  

清理环境：卸载kvm

  \# yum remove `rpm -qa | egrep 'qemu|virt|kvm'` -y

  \# rm -rf /var/lib/libvirt  /etc/libvirt/

 

升级系统：(在安装虚拟机出错的情况下)

  \# yum upgrade

 

安装软件:

  centos6:  

  \# yum groupinstall "Virtualization" "Virtualization Client" "Virtualization Platform" "Virtualization Tools" -y

 

  centos7:

\# yum install *qemu*  *virt*  librbd1-devel -y

 

qemu-kvm： 主包 

libvirt：API接口

virt-manager：图形管理程序  

 

启动服务:

  centos6:

  \# /etc/init.d/libvirtd start

  \# service  libvirtd  start

  

  centos7:

  \# systemctl start libvirtd

  

查看kvm模块加载:

  \# lsmod | grep kvm

​    kvm_intel        53484   3 

​    kvm          316506  1 kvm_intel

 

# ***\*guest os安装\****

1.图形方式（非常重要 非常简单）

2.完全文本模式（现场配置虚拟机的规格）

3.命令行模式（重中之重 最常用 模板镜像+配置文件 方式配置规格）

## ***\*图形模式安装guest os\****

\# virt-manager

 

  ![img](kvm%E5%85%A8%E8%A7%A3.assets/wpsU6qIB9.jpg)

## ***\*guestos安装出错\****

如果所有问题都排查过后还是安装不上guestos，最后的原因就是在安装宿主机系统的时候各种兼容性软件没有安装而且Yum也没有自动处理导致的

## ***\*完全文本方式安装\****

注意：不需要讲

极端情况-服务器没有图形 客户端也没有图形

\#virt-install --connect qemu:///system -n vm6 -r 512 --disk path=/virhost/vmware/vm6.img,size=7 --os-type=linux --os-variant=rhel6 --vcpus=1 --network bridge=br0 --location=http://127.0.0.1/rhel6u4 -x console=ttyS0 --nographics

 

\#***\*virt-install --connect qemu:///system -n vm9 -r 2048 --disk path=/var/lib/libvirt/images/vm9.img,size=7 --os-type=linux --os-variant=centos7.0 --vcpus=1 --location=ftp://192.168.100.230/centos7u3 -x console=ttyS0 --nographics\****

​               

注意：

  用这种方式安装的操作系统，大小写会胡乱变化，不影响远程操作

  内存必须2G以上

  

查看kvm支持的os版本：

\# man virt-install  

\# osinfo-query os | grep centos

 

排错:

安装过程中：

  手动配置IP地址

  到url位置找不到路径，要返回去手动选择url，重新配置url为ftp://192.168.100.230/rhel6u4,这里的ip不要写127.0.0.1而是br0的ip

  

  给虚拟机指定的内存必须大于2048M，不然报错如下：

  dracut-initqueue[552]: /sbin/dmsquash-live-root: line 273: printf: write error: No space left on device

 

逃脱符：  

  Escape character is ^]

 

## ***\*命令行模式安装\****

虚拟机的组成部分

1.虚拟机配置文件

[root@localhost qemu]# ls /etc/libvirt/qemu

networks  vm1.xml

2.储存虚拟机的介质

[root@localhost qemu]# ls /var/lib/libvirt/images/

vm1.img

 

根据配置文件创建虚拟机:

1.需要有磁盘镜像文件：

\# cp vm1.img vm2.img

 

2.需要有配置文件:配置文件需要修改必要的东西

\# cp vm1.xml vm2.xml

 

3.创建虚拟机:

\# virsh define /etc/libvirt/qemu/vm2.xml

 

注：

  allocate	英[ˈæləkeɪt]  美[ˈæləkeɪt]

​    拨…(给); 划…(归); 分配…(给);

​    [例句]Tickets are limited and will be allocated to those who apply first

​    票数有限，先申请者先得。

=================

例子

模板镜像+配置文件 方式创建虚拟机

1.拷贝模板镜像和配置文件

[root@kvm ~]# cp /var/lib/libvirt/images/vm2.img /var/lib/libvirt/images/vm3.img

[root@kvm ~]# cp /etc/libvirt/qemu/vm2.xml /etc/libvirt/qemu/vm3.xml

 

2.修改配置文件

\# vim /etc/libvirt/qemu/vm3.xml

<domain type='kvm'>

 <name>vm3</name>

 <uuid>a2f62549-c6b7-4b8f-a8e2-c14edda35a78</uuid>

 <memory unit='KiB'>2099200</memory>

 <currentMemory unit='KiB'>2099200</currentMemory>

 <vcpu placement='static'>2</vcpu>

 <os>

  <type arch='x86_64' machine='pc-i440fx-rhel7.0.0'>hvm</type>

  <boot dev='hd'/>

 </os>

 <features>

  <acpi/>

  <apic/>

 </features>

 <cpu mode='custom' match='exact' check='partial'>

  <model fallback='allow'>Haswell-noTSX</model>

 </cpu>

 <clock offset='utc'>

  <timer name='rtc' tickpolicy='catchup'/>

  <timer name='pit' tickpolicy='delay'/>

  <timer name='hpet' present='no'/>

 </clock>

 <on_poweroff>destroy</on_poweroff>

 <on_reboot>restart</on_reboot>

 <on_crash>destroy</on_crash>

 <pm>

  <suspend-to-mem enabled='no'/>

  <suspend-to-disk enabled='no'/>

 </pm>

 <devices>

  <emulator>/usr/libexec/qemu-kvm</emulator>

 

  <disk type='file' device='disk'>

   <driver name='qemu' type='qcow2'/>

   <source file='/var/lib/libvirt/images/vm3.img'/>

   <target dev='vda' bus='virtio'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>

  </disk>

 

   <disk type='file' device='disk'>

   <driver name='qemu' type='qcow2'/>

   <source file='/var/lib/libvirt/images/vm3-1.img'/>

   <target dev='vda' bus='virtio'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x16' function='0x0'/>

   </disk>

  

  <controller type='usb' index='0' model='ich9-ehci1'>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x7'/>

  </controller>

  <controller type='usb' index='0' model='ich9-uhci1'>

   <master startport='0'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0' multifunction='on'/>

  </controller>

  <controller type='usb' index='0' model='ich9-uhci2'>

   <master startport='2'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x1'/>

  </controller>

  <controller type='usb' index='0' model='ich9-uhci3'>

   <master startport='4'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x2'/>

  </controller>

  <controller type='pci' index='0' model='pci-root'/>

  <controller type='virtio-serial' index='0'>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>

  </controller>

 

  <interface type='network'>

   <mac address='52:54:00:f2:28:6f'/>

   <source network='default'/>

   <model type='virtio'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>

  </interface>

  

  <serial type='pty'>

   <target type='isa-serial' port='0'>

​    <model name='isa-serial'/>

   </target>

  </serial>

  <console type='pty'>

   <target type='serial' port='0'/>

  </console>

  <channel type='unix'>

   <target type='virtio' name='org.qemu.guest_agent.0'/>

   <address type='virtio-serial' controller='0' bus='0' port='1'/>

  </channel>

  <input type='mouse' bus='ps2'/>

  <input type='keyboard' bus='ps2'/>

  <memballoon model='virtio'>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>

  </memballoon>

 </devices>

</domain>    

## ***\*升级配置\****

\1. 修改配置文件（比如添加磁盘，那就添加如下配置）

   <disk type='file' device='disk'>

   <driver name='qemu' type='qcow2'/>

   <source file='/var/lib/libvirt/images/vm3-1.img'/>

   <target dev='vda' bus='virtio'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x16' function='0x0'/>

   </disk>

  

\2. 创建新的空磁盘卷：

\# qemu-img create  -f  qcow2  vm3-1.qcow2 10G

 

\3. 重新定义：

\# virsh define /etc/libvirtd/qemu/vm3.xml

## ***\*安装系统问题\****

问题：用图形安装guest os的时候卡住不动

解决：升级系统

​     \#  yum upgrade -y

 

问题：升级系统后安装guest os的时候还是卡住不动

解决：需要在安装宿主机的时候安装兼容性程序（有的同学就没有安装也可以使用，这可能是bug）

 

问题：如果安装了各种兼容程序之后还是不行

![img](kvm%E5%85%A8%E8%A7%A3.assets/wpsH148Gk.jpg) 

# ***\*kvm\*******\*存储\****

概念：

  kvm必须要配置一个目录当作他存储磁盘镜像(存储卷)的目录，我们称这个目录为存储池

  

默认存储池：

  /var/lib/libvirt/images/   

 

## ***\*存储池管理\****  

  1.创建基于文件夹的存储池（目录）

​    \# mkdir -p /data/vmfs

  2.定义存储池与其目录

​    \# virsh pool-define-as vmdisk --type dir --target /data/vmfs

  3.创建已定义的存储池

​    (1)创建已定义的存储池

​      \# virsh pool-build vmdisk

​    (2)查看已定义的存储池，存储池不激活无法使用。

​      \#virsh pool-list --all

  4.激活并自动启动已定义的存储池

​    \# virsh pool-start vmdisk

​    \# virsh pool-autostart vmdisk     

​    这里vmdisk存储池就已经创建好了，可以直接在这个存储池中创建虚拟磁盘文件了。

  5.在存储池中创建虚拟机存储卷

​     \# virsh vol-create-as vmdisk oeltest03.qcow2 20G --format qcow2

Virsh vol-delete --pool vmdisk  .qcow2 

   Vmdisk：创建的池  --format qcow2 ：类型

  注1:KVM存储池主要是体现一种管理方式，可以通过挂载存储目录，lvm逻辑卷的方式创建存储池，虚拟机存储卷创建完成后，剩下的操作与无存储卷的方式无任何区别了。

  注2:KVM存储池也要用于虚拟机迁移任务。

 

  6.存储池相关管理命令

​    (1)在存储池中删除虚拟机存储卷

​      \# virsh vol-delete --pool vmdisk oeltest03.qcow2

​    (2)取消激活存储池

​      \# virsh pool-destroy vmdisk

​    (3)删除存储池定义的目录/data/vmfs

​      \# virsh pool-delete vmdisk

​    (4)取消定义存储池

​      \# virsh pool-undefine vmdisk

到此kvm存储池配置与管理操作完毕。  

 

## ***\*生产环境存储池使用\****

1.首先创建了一个LVM ，使用lvcreate命令，创建一个名为lv_kvm，大小为250G的逻辑卷，卷组名为VolGroup(VolGroup是已经创建好的卷组，创建方法在上一篇文章中)

​    \#lvcreate -L 250G -n lv_kvm VolGroup

 2.使用mkfs.ext4命令在逻辑卷lvdata1上创建ext4文件系统.

​    \#mkfs.ext4 /dev/VolGroup/lv_kvm

 3.将创建好的文件系统/lv_kvm挂载到/kvm上.(创建好之后,会在/dev/mapper/生成一个软连接名字为"卷组-逻辑卷")

​    \#mount  /dev/VolGroup/lv_kvm /kvm

 4.建立存储池的目录

​    \#mkdir /kvm/images

 5.配置SELinux文件上下文,这个主要是打开SELinux设定，不然虚拟机无法访问存储文件(没有深究原因)

​    \#semanage fcontext -a -t virt_image_t /kvm/images

 6.创建基于文件夹（目录）的存储池

​    \#virsh pool-define-as kvm_images  --type dir --target /kvm/images

 7.查看创建的存储池信息

​    \# virsh pool-list --all

​    Name         State    Autostart 

​    \-----------------------------------------

​    default        inactive  yes

​    kvm_images    inactive  no

​     

  停止默认存储池:

​    \# virsh pool-destroy  default

​    Pool default destroyed

 

 8.启动存储池

​    \# virsh  pool-start kvm_images

​    \# virsh pool-list --all

​    Name         State    Autostart 

​    \-----------------------------------------

​    default        inactive  yes    

​    kvm_images      active   no

 

 9.创建了存储池后，就可以创建一个卷，这个卷是用来做虚拟机的硬盘

​    \#virsh  vol-create-as --pool kvm_images --name TAF05.img --capacity 10G --format qcow2

​    

 10.在存储卷上安装虚拟主机

   10.1  配置bridge方式：		

​		创建桥接器

​		# cat /etc/sysconfig/network-scripts/ifcfg-br0

​		DEVICE=br0

​		NM_CONTROLLED=no

​		TYPE=Bridge

​		BOOTPROTO=static

​		IPADDR=192.168.0.230

​		PREFIX=24

​		GATEWAY=192.168.1.254

​		DNS1=8.8.8.8

​		ONBOOT=yes

​		USERCTL=no

​		DELAY=0

​	

​		将物理接口桥接到桥接器

​		# cat /etc/sysconfig/network-scripts/ifcfg-eth0

​		DEVICE=eth0

​		NM_CONTROLLED=no

​		TYPE=Ethernet

​		BOOTPROTO=static

​		ONBOOT=yes

​		USERCTL=no

​		BRIDGE=br0

​	

​		重启加载网络服务

​		# service network restart

​	

​		查看当前桥接情况 

​		# brctl show 

   10.2 安装

​    \# virt-install --connect qemu:///system -n vm3 -r 512 -f /virhost/vmware/vm2.img -s 7 --vnc --os-type=linux --os-variant=rhel6 --vcpus=1 --network bridge=br0 -c /var/ftp/soft/rhel6u4.iso

 

## ***\*磁盘\*******\*格式\****

建立虚拟机磁盘镜像文件：

磁盘镜像文件格式:

  raw   原始格式，性能最好

  qcow  先去网上了解一下cow(写时拷贝copy on write) ，性能远不能和raw相比，所以很快夭折了，所以出现了qcow2

  qcow2 性能上还是不如raw，但是raw不支持快照，qcow2支持快照。

 

现在默认安装好的用的是raw格式，所有做快照要把他转换成qcow2格式

 

什么叫写时拷贝？

raw立刻分配空间，不管你有没有用到那么多空间

qcow2只是承诺给你分配空间，但是只有当你需要用空间的时候，才会给你空间。最多只给你承诺空间的大小，避免空间浪费

 

工作当中用哪个？看你用不用快照。

工作当中虚拟机会有多个备份，一个坏了，再起一个就行了，所有没必要用快照。当然也不一定。

数据绝对不会存储到本地。

 

qemu-kvm  qemu是早先的一个模拟器，kvm是基于qemu发展出来的。

 

建立qcow2格式磁盘文件:

\#qemu-img create -f qcow2 test.qcow2 20G 

 

建立raw格式磁盘文件:

\#qemu-img create -f raw test.raw 20G  

 

查看已经创建的虚拟磁盘文件:

\#qemu-img info test.qcow2 

 

## ***\*挂载磁盘\****

作为虚拟化环境管理员，你肯定遇到过虚拟机无法启动的情况。实施排错时，你需要对虚拟机的内部进行检查。而Libguestfs Linux工具集可以在这种情况下为你提供帮助。

 

利用Libguestfs找出损坏的虚拟机文件

Libguestfs允许在虚拟机上挂载任何类型的文件系统，以便修复启动故障。

使用Libguestfs，首先需要使用Libvirt。Libvirt是一个管理接口，可以和KVM、Xen和其他一些基于Liunx的虚拟机相互连接。Libguestfs的功能更加强大，可以打开Windows虚拟机上的文件。但是首先你需要将虚拟机迁移到libguestfs可用的环境当中，也就是Linux环境。

假如你是vmware的ESXI虚拟机，为了将虚拟机迁移到Linux当中，你可以使用SSH连接到ESXi主机，这意味着你首先需要启用ESXi主机上的SSH访问方式。完成之后，在

Linux平台上运行下面的scp命令：

\1. scp –r 192.168.178.30:/vmfs/volumes/datastore1/Windows* 

 

使用guestfish操作虚拟机磁盘镜像文件：

完成虚拟机磁盘镜像文件的复制之后，可以在libguestfs中使用guestfish这样的工具将其打开，这样就可以直接在vmdk文件上进行操作了。

 

 

使用命令来在虚拟机中创建一个连接到文件系统的交互式shell。在新出现的窗口中，你可以使用特定的命令来操作虚拟机文件。

\# guestfish --rw -a  /path/to/windows.vmdk

 

第一个任务就是找到可用的文件系统：

\1. ><fs> run          //进入交互式shell之后第一个命令

\2. ><fs> list-filesystems //列出磁盘镜像文件内的文件系统

/dev/vda1: ext4

/dev/vdb1: iso9660

/dev/VolGroup/lv_root: ext4

/dev/VolGroup/lv_swap: swap

3.><fs>  mount /dev/VolGroup/lv_root   /   //当你使用guestfish shell找到可用文件系统类型之后，就可以进行挂载了。将文件系统到guestfish根目录下

4.><fs>  ls /                        //ls命令查看文件/下内容 ，不能使用cd命令

bin  boot dev etc home  lib lib64  lost+found

5.><fs> cat /etc/passwd    //查看文件，不能像在其他shell环境中一样操作。目录所有路径必须从根开始

root:x:0:0:root:/root:/bin/bash

bin:x:1:1:bin:/bin:/sbin/nologin

daemon:x:2:2:daemon:/sbin:/sbin/nologin

 

在guestfish  shell当中可以使用像ls、cat、more、download这样的命令，来查看和下载文件以及目录

 

guestfish  读镜像

mount  /dev/sda1  /

cd /

 

查看帮助：这两个帮助显示的内容不一样

\# guestfish --help 

\# guestfish -h

 

Virt-rescue提供直接访问方式：

这种方式跟linux系统光盘的rescue模式几乎一样，进去之后首先需要查看文件系统，然后手动挂载到/sysroot目录下，进入/sysroot目录就可以随意操作虚拟磁盘镜像内的文件了

\# virt-rescue vm1     //进入修复模式，help查看帮助

\><rescue>fdisk -l

\><rescue>mount /dev/mapper/VolGroup-lv_root /sysroot/ 

\><rescue>cd /sysroot/

\><rescue>touch aaaaaaaaaaaaa

 

============================

查看磁盘镜像分区信息:

  \# virt-df -h -d vm1

  Filesystem                 Size    Used  Available  Use%

  vm1:/dev/sda1               484M     32M    428M   7%

  vm1:/dev/sdb1               3.5G    3.5G      0  100%

  vm1:/dev/VolGroup/lv_root         6.1G    1.1G    4.7G  18%

 

  \# virt-filesystems -d vm1

  /dev/sda1

  /dev/sdb1

  /dev/VolGroup/lv_root

 

挂载磁盘镜像分区:

\# guestmount -d vm1 -m /dev/vda1 --rw /mnt

 

***\*注\****：

mtab文件在centos7的启动过程中非常有用，删掉会导致不能启动

# ***\*kvm\*******\*管理\****

虚拟机的基本管理命令：

查看

启动

关闭

重启

重置 

list start restart shutdown reset  suspend resume 

 

查看:

查看虚拟机:

  \# virsh list 

   Id   Name              State

  \----------------------------------------------------

   2   vm1               running

 

  \# virsh list --all

   Id   Name              State

  \----------------------------------------------------

   2   vm1               running

 

！查看kvm虚拟机配置文件(X)：

\# virsh dumpxml name

 

！将node4虚拟机的配置文件保存至node6.xml(X):

\# virsh dumpxml node4 > /etc/libvirt/qemu/node6.xml

 

！修改node6的配置文件(X)：

\# virsh edit node6    

如果直接用vim编辑器修改配置文件的话，需要重启libvirtd服务

 

启动:

[root@localhost ~]# virsh start vm1

Domain vm1 started

 

暂停虚拟机： 

 \#virsh suspend vm_name  

 

恢复虚拟机：

 \#virsh resume vm_name   

 

关闭：

  方法1：

  \# virsh shutdown vm1

  Domain vm1 is being shutdown

  

  方法2(X)：

  \# virsh destroy vm1

  Domain vm1 destroyed

 

重启：

  [root@localhost ~]# virsh reboot vm1

  Domain vm1 is being reboote

 

重置:

  [root@localhost ~]# virsh reset vm1

  Domain vm1 was reset

 

删除虚拟机:

  \# virsh undefine vm2

  Domain vm2 has been undefined

 

注意:虚拟机在开启的情况下undefine是无法删除的，但是如果再destroy会直接被删除掉

 

虚拟机开机自动启动:

  \# virsh autostart vm1

​    域 vm1标记为自动开始

  \# ls /etc/libvirt/qemu/autostart/   //此目录默认不存在，在有开机启动的虚拟机时自动创建

​    vm1.xml

 

  \# virsh autostart --disable vm1

​    域 vm1取消标记为自动开始

 

查看所有开机自启的guest os:

  \# ls /etc/libvirt/qemu/autostart/

  \# virsh list --all --autostart

======================

连接虚拟机的方法：

1.使用virt-viewer图形连接已启动的虚拟机

  \# virt-viewer vm1

 

2.使用console连接虚拟机

  配置虚拟机支持console连接:

​    虚拟机系统中在下列3个文件中添加如下内容，并重新启动

​      \# vim /etc/securetty

​        ttyS0

​      \# vim /etc/inittab

​        s0:2345:respawn:/sbin/agetty ttyS0 115200

​      \# vim /boot/grub/grub.conf  //添加内核启动参数console=ttyS0

​         kernel /vmlinuz-2.6.18-308.el5 ro root=/dev/VolGroup00/LogVol00 rhgb quiet console=ttyS0

​      \# reboot

 

  建立链接：

​    \# virsh console vm1

​      连接到域 vm1

​      Escape character is ^]

 

​      Red Hat Enterprise Linux Server release 6.4 (Santiago)

​      Kernel 2.6.32-358.el6.x86_64 on an x86_64

 

​      localhost.localdomain login: root

​      Password: 

​      Last login: Thu Aug 15 06:45:59 on tty1

​    [root@localhost ~]# 退出console，快捷键 Ctrl+]（右中括号）

 

## ***\*虚拟机克隆\****

虚拟机克隆

1.图形界面：Applications （左上角）-----> System Tools ------>Virtual Machine Manager

  关闭要克隆的虚拟机，右键点击虚拟机选择Clone

 

2.字符终端，命令克隆

  \# virt-clone -o vm1 --auto-clone

​    WARNING  设置图形设备端口为自动端口，以避免相互冲突。

​    正在分配 'vm1-clone.qcow2'       | 6.0 GB  00:00:05   

​    成功克隆 'vm1-clone'。

  -o    origin   

  

  \# virt-clone -o vm1 -n vm2 --auto-clone

​    WARNING  设置图形设备端口为自动端口，以避免相互冲突。

​    正在分配 'vm2.qcow2'                         | 6.0 GB  00:00:06   

​    成功克隆 'vm2'。

​    

  \# virt-clone -o vm1 -n vm2 -f /var/lib/libvirt/images/vm2.img

​    正在克隆     

​    vm1.img        | 8.0 GB   01:03   

​    Clone 'vm2' created successfully.   

## ***\*增量镜像（扩展）\****

1、概述

实验目的：

  通过一个基础镜像（node.img），里面把各个虚拟机都需要的环境都搭建好，然后基于这个镜像建立起一个个增量镜像，每个增量镜像对应一个虚拟机，虚拟机对镜像中所有的改变都记录在增量镜像里面，基础镜像始终保持不变。

 

功能:

  节省磁盘空间，快速复制虚拟机。

 

环境：

  基本镜像文件：node.img 虚拟机ID：node 

  增量镜像文件：node4.img 虚拟机ID：node4

 

要求：

  以基本镜像文件node.img为基础，创建一个镜像文件node4.img，以此创建一个虚拟机node4，虚拟机node4的改变将存储于node4.img中。

 

2、创建增量镜像文件

[root@target kvm_node]#qemu-img create -b node.img -f qcow2 node4.img

[root@target kvm_node]#qemu-img info node4.img 

image: node4.img

file format: qcow2

virtual size: 20G (21495808000 bytes)

disk size: 33M

cluster_size: 65536

backing file: node.img (actual path: node.img)

 

注：该实验只是针对qcow2格式的镜像文件，未测试raw格式的镜像文件是否可行。

 

3、创建虚拟机node4的XML配置文件

[root@target kvm_node]# cp /etc/libvirt/qemu/node.xml /etc/libvirt/qemu/node4.xml

[root@target kvm_node]# vim /etc/libvirt/qemu/node4.xml 

<domain type='kvm'>

 <name>node4</name>                 #node4的虚拟机名，须修改，否则与基本虚拟机冲突

 <uuid>4b7e91eb-6521-c2c6-cc64-c1ba72707fe4</uuid>  #node4的UUID，必须修改，否则与基本虚拟机冲突

 <memory>524288</memory>

 <currentMemory>524288</currentMemory>

 <vcpu cpuset='0-1'>2</vcpu>

 <os>

  <type arch='x86_64' machine='rhel5.4.0'>hvm</type>

  <boot dev='hd'/>

 </os>

 <features>

  <acpi/>

  <apic/>

  <pae/>

 </features>

 <clock offset='localtime'/>

 <on_poweroff>destroy</on_poweroff>

 <on_reboot>restart</on_reboot>

 <on_crash>restart</on_crash>

 <devices>

  <emulator>/usr/libexec/qemu-kvm</emulator>

  <disk type='file' device='disk'>

   <driver name='qemu' type='qcow2'/>

   <source file='/virhost/kvm_node/node4.img'/>  #将原指向/virhost/kvm_node/node.img改为node4.img

   <target dev='vda' bus='virtio'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>

  </disk>

  <interface type='bridge'>

   <mac address='54:52:00:69:d5:f4'/>       #修改网卡MAC，防止冲突

   <source bridge='br0'/>

   <model type='virtio'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>

  </interface>

  <interface type='bridge'>

   <mac address='54:52:00:69:d5:e4'/>      #修改网卡MAC，防止冲突

   <source bridge='br0'/>

   <model type='virtio'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>

  </interface>

  <serial type='pty'>

   <target port='0'/>

  </serial>

  <console type='pty'>

   <target type='serial' port='0'/>

  </console>

  <input type='mouse' bus='ps2'/>

  <graphics type='vnc' port='5904' autoport='no' listen='0.0.0.0' passwd='xiaobai'>

   <listen type='address' address='0.0.0.0'/>

  </graphics>

    <video>

   <model type='cirrus' vram='9216' heads='1'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>

  </video>

  <memballoon model='virtio'>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>

  </memballoon>

 </devices>

</domain>

4、根据xml配置定义虚拟机node4

[root@target kvm_node]#virsh define /etc/libvirt/qemu/node4.xml

[root@target kvm_node]#virsh start node4 

5、测试 

[root@target kvm_node]# du -h node.img 

6.3G  node.img

[root@target kvm_node]# du -h node4.img

33M   node4.img

[root@node4 ~]# dd if=/dev/zero of=test bs=1M count=200  #在虚拟机node4上增量200M大小文件

200+0 records in

200+0 records out

209715200 bytes (210 MB) copied, 1.00361 seconds, 209 MB/s

[root@target kvm_node]# du -h node.img          #基本镜像文件node.img大小未变

6.3G  node.img

[root@target kvm_node]# du -h node4.img         #增量镜像文件node4.img增加200M了

234M  node4.img

## ***\*快照\****

为虚拟机vm8创建一个快照

\# virsh snapshot-create-as vm8 vm8.snap

error: unsupported configuration: internal snapshot for disk vda unsupported for storage type raw

 

raw

使用文件来模拟实际的硬盘(当然也可以使用一块真实的硬盘或一个分区)。由于原生的裸格式，不支持snapshot也是很正常的。但如果你使用LVM的裸设备，那就另当别论。说到LVM还是十分的犀利的目前来LVM的snapshot、性能、可扩展性方面都还是有相当的效果的。目前来看的话，备份的话也问题不大。就是在虚拟机迁移方面还是有很大的限制。但目前虚拟化的现状来看，真正需要热迁移的情况目前需求还不是是否的强烈。虽然使用LVM做虚拟机镜像的相关公开资料比较少，但目前来看牺牲一点灵活性，换取性能和便于管理还是不错的选择。

 

qcow2

现在比较主流的一种虚拟化镜像格式，经过一代的优化，目前qcow2的性能上接近raw裸格式的性能，这个也算是redhat的官方渠道了

对于qcow2的格式，几点还是比较突出的，qcow2的snapshot，可以在镜像上做N多个快照：

​	•更小的存储空间

​	•Copy-on-write support

​	•支持多个snapshot，对历史snapshot进行管理

​	•支持zlib的磁盘压缩

​	•支持AES的加密

​		

查看镜像文件格式：

\# qemu-img info /var/lib/libvirt/images/vm8.img 

image: /var/lib/libvirt/images/vm8.img

file format: raw

virtual size: 10G (10737418240 bytes)

disk size: 10G

 

格式转换：

把raw格式转换成qcow2格式

\# qemu-img convert -f raw -O qcow2 /var/lib/libvirt/images/vm8.img /var/lib/libvirt/images/vm8_qcow2.img

 

\# ls -l /var/lib/libvirt/images/

total 28381680

-rw-------. 1 qemu qemu 10737418240 Aug 16 01:09 vm8.img

-rw-r--r--. 1 root root  3076521984 Aug 16 01:09 vm8_qcow2.img

 

\# qemu-img info /var/lib/libvirt/images/vm8_qcow2.img 

image: /var/lib/libvirt/images/vm8_qcow2.img

file format: qcow2

virtual size: 10G (10737418240 bytes)

disk size: 2.9G

cluster_size: 65536

 

将虚拟机的硬盘指向转换后的qcow2.img

 

在虚拟机中创建一个目录，但目录中是空的

\# mkdir /test

\# ls /test

 

给虚拟机vm8创建第一个快照vm8.snap1

\# virsh snapshot-create-as vm8 vm8.snap1

 

\# qemu-img info /var/lib/libvirt/images/vm8_qcow2.img 

image: /var/lib/libvirt/images/vm8_qcow2.img

file format: qcow2

virtual size: 10G (10737418240 bytes)

disk size: 3.1G

cluster_size: 65536

Snapshot list:

ID     TAG         VM SIZE         DATE    VM CLOCK

1     vm8.snap1     229M 2013-08-16 01:25:39  00:03:58.995

 

在虚拟机中，给 /test 中复制2个文件

\# cp install.log anaconda-ks.cfg  /test

\# ls /test

anaconda-ks.cfg  install.log

 

给虚拟机vm8创建第二个镜像vm8.snap2

\# virsh snapshot-create-as vm8 vm8.snap2

Domain snapshot vm8.snap2 created

\# virsh snapshot-list vm8

 

关闭虚拟机，恢复到第一个快照

\# virsh shutdown vm8

\# virsh snapshot-revert vm8 vm8.snap1

 

在虚拟机中，发现 /test 目录为空

\# ls /test

 

关闭虚拟机，恢复到第二个快照

\# virsh shutdown vm8

\# virsh snapshot-revert vm8 vm8.snap2

 

在虚拟机中，发现 /test 有拷贝的2个文件

\# ls /test

anaconda-ks.cfg  install.log

 

查看虚拟机快照

\# virsh snapshot-list vm8

 

删除虚拟机快照

\# virsh snapshot-delete --snapshotname vm8.snap2 vm8

\# virsh snapshot-list vm8

 

  

## ***\*热迁移\****

热迁移

 

​				192.168.1.1/24	              192.168.1.2/24

​				++++++++++++       			  ++++++++++++

​				+			 +				        +		  +		

​				+  KVM-A	 +  =======>        +  KVM-B  +

​				+	  	 +					      +	    +	

​				++++++++++++					      ++++++++++++

​				 images                     images

​			  /var/lib/libvirt/images	            /var/lib/libvirt/images          

​				

​				               nfs

​			

系统环境:rhel6.4 x86_64 iptables and selinux off

 

注意：

  1.两台机器要做互相解析	

​	2.同一个大版本的系统，从高版本系统上不可以往低版本系统上迁移，反过来可以比如从6.5不能迁移到6.4，但是从6.4可以迁移到6.5

​	3.两台机器的selinux全部开机关闭

​	

将 KVM-A 上的虚拟机镜像文件所在的目录共享出来

[root@localhost ~]# getenforce 

Permissive

[root@localhost ~]# iptables -F

[root@localhost ~]# vim /etc/exports 

/var/lib/libvirt/images 192.168.1.2(rw,sync,no_root_squash)

[root@localhost ~]# service nfs start

 

将KVM-A上共享出来的目录挂载在到KVM-B的/var/lib/libvirt/images

[root@localhost ~]# mount -t nfs 192.168.1.1:/var/lib/libvirt/images  /var/lib/libvirt/images

​								

在KVM-B配置/etc/libvirt/qemu.conf

[root@localhost ~]# vim /etc/libvirt/qemu.conf      #取消下面选项的注释

user = "root"		第198行

group = "root"	第202行

 

[root@localhost ~]# serivice libvirtd restart

 

在KVM-A上用虚拟机管理器连接KVM-B

File---------> Add Connection

 

右键点击要迁移的虚拟机，选择 Migrate

 

## ***\*kvm网络管理\****

画图工具：https://www.processon.com

 

分类：

  网络：

​    nat 

​    isolated

​    

  接口:

​    bridge

​    

虚拟交换机：linux-bridge(linux自带)   ovs(open-Vswitch)                 

  

NAT网络拓扑：

![img](kvm%E5%85%A8%E8%A7%A3.assets/wpsxCudNv.jpg) 

 

隔离网络拓扑：

![img](kvm%E5%85%A8%E8%A7%A3.assets/wpsWnskTG.jpg)  

 

桥接网络拓扑：

![img](kvm%E5%85%A8%E8%A7%A3.assets/wpsoyCtZR.jpg) 

会查看网络

创建网络

给guestos切换网络

 

两种网络

  nat

  isolate

一种接口

  bridge

可以通过查看mac地址是否一致来确定是不是一根线上的两个接口

\# brctl show

bridge name	bridge id		        STP enabled	 interfaces

virbr0		    8000.5254003c2ba7	yes		     virbr0-nic

​							                           vnet2

​							                           vnet3

从交换机上把vnet网卡删除：

\# brctl delif  virbr0 vnet0

添加vnet网卡到交换机上：

\# brctl addif  virbr0 vnet0

​						      

配置文件方式配置桥接：在宿主机上

  \1. 修改配置文件

  \# cat ifcfg-br0 

  TYPE=Bridge

  NAME=br0

  DEVICE=br0

  ONBOOT="yes"

  BOOTPROTO=static

  IPADDR=10.18.44.251

  GATEWAY=10.18.44.1

  NETMASK=255.255.255.0

  DNS1=10.18.44.100

  DNS2=8.8.8.8

 

  \# cat ifcfg-enp3s0

  DEVICE="enp3s0"

  ONBOOT="yes"

  BRIDGE=br0

  

  2.重启libvirtd服务

  3.重启network服务 

   

  删除桥接网卡步骤：

  1.删除br0的配置文件

  2.修改正常网卡的配置文件

  3.重启系统   

  

配置文件方式创建nat网络：

\# cp /etc/libvirt/qemu/networks/nat2.xml /etc/libvirt/qemu/networks/nat3.xml

\# vim /etc/libvirt/qemu/networks/nat3.xml

<network>

 <name>nat3</name>

 <uuid>4d8b9b5c-748f-4e16-a509-848202b9c83b</uuid>

 <forward mode='nat'/>       //和隔离模式的区别

 <bridge name='virbr4' stp='on' delay='0'/>

 <mac address='52:57:00:62:0c:d4'/>

 <domain name='nat3'/>

 <ip address='192.168.104.1' netmask='255.255.255.0'>

  <dhcp>

   <range start='192.168.104.128' end='192.168.104.254'/>

  </dhcp>

 </ip>

</network>

 

重启服务：

\# systemctl  restart libvirtd

  

配置文件方式创建isolated网络：      

<network>

 <name>isolate1</name>

 <uuid>6341d3a6-7330-4e45-a8fe-164a6a68929a</uuid>

 <bridge name='virbr2' stp='on' delay='0'/>

 <mac address='52:54:00:6b:39:0c'/>

 <domain name='isolate1'/>

 <ip address='192.168.101.1' netmask='255.255.255.0'>

  <dhcp>

   <range start='192.168.101.128' end='192.168.101.254'/>

  </dhcp>

 </ip>

</network>       

 

查看所有的网络：

\# virsh net-list

 

启动网络：

\# virsh net-start isolated200

 

开机自启动:

\# virsh net-autostart  isolated200   

 

网络相关基本命令

查看一个guest主机的网络接口信息:

\# virsh domiflist vm1

接口      类型      源      型号      MAC

\---------------------------------------------------------------------------------

vnet0    network   default   virtio    52:54:00:94:a7:a1

 

nat模式

virbr0 是 KVM 默认创建的一个 Bridge，其作用是为连接其上的虚机网卡提供 NAT 访问外网的功能。

virbr0 默认分配了一个IP 192.168.122.1，并为连接其上的其他虚拟网卡提供 DHCP 服务。

 

virbr0的dhcp:

virbr0 使用 dnsmasq 提供 DHCP 服务，可以在宿主机中查看该进程信息

  \# ps -elf|grep dnsmasq

  5 S libvirt+  2422  1  0  80  0 -  7054 poll_s 11:26 ?  00:00:00 /usr/sbin/dnsmasq --conf-

  file=/var/lib/libvirt/dnsmasq/default.conf

 

在 /var/lib/libvirt/dnsmasq/ 目录下有一个 virbr0.status 文件，当 VM1 成功获得 DHCP 的 IP 后，可以在该文件中查看到相应的信息

  [root@master dnsmasq]# cat virbr0.status 

  [

   {

​    "ip-address": "192.168.122.28",

​    "mac-address": "52:54:00:94:a7:a1",

​    "hostname": "vm1",

​    "expiry-time": 1511626337

   }

  ]

 

======================================

图形界面：Applications （左上角）------------> System Tools ----------->Virtual Machine Manager

在Virtual Machine Manager对话框，点击上方的 Edit ，选择 Connection Details

 

Virtual Networks 

 

 KVM网络配置

​	NAT default方式：支持主机与虚拟机互访，虚拟机访问外界网络，但不支持外界访问虚拟机。

​	virbr0配置文件：/var/lib/libvirt/network/default.xml

​	Internet<---(1.1.1.1)hypervisor(192.168.122.0/24)<---Guest OS ( 192.168.122.0/24) 

​	Bridge方式：可以使虚拟机成为网络中具有独立IP的主机

 

配置bridge方式		

​		创建桥接器

​		# cat /etc/sysconfig/network-scripts/ifcfg-br0

​		DEVICE=br0

​		TYPE=Bridge

​		BOOTPROTO=static

​		IPADDR=192.168.0.230

​		PREFIX=24

​		GATEWAY=192.168.1.254

​		DNS1=8.8.8.8

​		ONBOOT=yes

​	

​		将物理接口桥接到桥接器

​		# cat /etc/sysconfig/network-scripts/ifcfg-eth0

​		DEVICE=eth0

​		TYPE=Ethernet

​		BOOTPROTO=static

​		ONBOOT=yes

​		BRIDGE=br0

​	

​		重启加载网络服务(reboot system)

​		# service network restart

​	

​		查看当前桥接情况 

​	  # brctl show

 

\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

从外面客户端访问KVM中NAT方式的内网虚拟机：

本机开启路由，开启防火墙，写入如下规则：

\# iptables -t nat -A PREROUTING -p tcp -m tcp --dport 10022 -j DNAT --to-destination 192.168.10.11:22

 

从其他客户端测试：

[wing@macserver ~]$ ssh root@192.168.22.108 -p 10022

 

# ***\*脚本\*******\*管理kvm\****

## ***\*批量创建虚机脚本\****

\#!/bin/bash

\#kvm batch create vm tool

\#version: 0.1

\#author: wing

\#需要事先准备模板镜像和配置文件模板

echo "1.创建自定义配置单个虚拟机

2.批量创建自定义配置虚拟机

3.批量创建默认配置虚拟机

4.删除虚拟机"

 

\#扩展功能：

\#  查看现在虚拟机

\#  查看某个虚拟机的配置

\#  升配/降配

\#  添加/删除网络 

 

read -p "选取你的操作(1/2/3):" op

 

batch_self_define() {

 

​    kvmname=`openssl rand -hex 5`

 

​    sourceimage=/var/lib/libvirt/images/vmmodel.img

​    sourcexml=/etc/libvirt/qemu/vmmodel.xml

 

​    newimg=/var/lib/libvirt/images/${kvmname}.img

​    newxml=/etc/libvirt/qemu/${kvmname}.xml

 

​    cp $sourceimage  $newimg

​    cp $sourcexml $newxml

 

​    kvmuuid=`uuidgen`

​    kvmmem=${1}000000

​    kvmcpu=$2

​    kvmimg=$newimg

​    kvmmac=`openssl rand -hex 3 | sed -r 's/..\B/&:/g'`

 

​    sed -i "s@kvmname@$kvmname@;s@kvmuuid@$kvmuuid@;s@kvmmem@$kvmmem@;s@kvmcpu@$kvmcpu@;s@kvmimg@$kvmimg@;s@kvmmac@$kvmmac@" $newxml

​    virsh define $newxml

​    virsh list --all

}

self_define() {

​    read -p "请输入新虚机名称:" newname

​    read -p "请输入新虚机内存大小(G):" newmem

​    read -p "请输入新虚机cpu个数:" newcpu

 

​    sourceimage=/var/lib/libvirt/images/vmmodel.img

​    sourcexml=/etc/libvirt/qemu/vmmodel.xml

 

​    newimg=/var/lib/libvirt/images/${newname}.img

​    newxml=/etc/libvirt/qemu/${newname}.xml

 

​    cp $sourceimage  $newimg

​    cp $sourcexml $newxml

 

​    kvmname=$newname

​    kvmuuid=`uuidgen`

​    kvmmem=${newmem}000000

​    kvmcpu=$newcpu

​    kvmimg=$newimg

​    kvmmac=`openssl rand -hex 3 | sed -r 's/..\B/&:/g'`

 

​    sed -i "s@kvmname@$kvmname@;s@kvmuuid@$kvmuuid@;s@kvmmem@$kvmmem@;s@kvmcpu@$kvmcpu@;s@kvmimg@$kvmimg@;s@kvmmac@$kvmmac@" $newxml

​    virsh define $newxml

​    virsh list --all

}

 

case $op in

1)self_define;;

2)

​    read -p "请输入要创建的虚拟机的个数:" num

​    read -p "请输入新虚机内存大小(G):" newmem

​    read -p "请输入新虚机cpu个数:" newcpu

 

​    for((i=1;i<=$num;i++))

​    do

​        batch_self_define $newmem $newcpu

​    done;;

 

3)

​    read -p "请输入要创建的虚拟机的个数:" num

 

​    for((i=1;i<=$num;i++))

​    do

​        batch_self_define 1 1

​    done;;

 

*)echo "输入错误，请重新执行脚本"

 exit;;

esac

 

 

## ***\*配置文件模板\****

\# vim /etc/libvirt/qemu/vmmodel.xml

<domain type='kvm'>

 <name>kvmname</name>

 <uuid>kvmuuid</uuid>

 <memory unit='KiB'>kvmmem</memory>

 <currentMemory unit='KiB'>kvmmem</currentMemory>

 <vcpu placement='static'>kvmcpu</vcpu>

 <os>

  <type arch='x86_64' machine='pc-i440fx-rhel7.0.0'>hvm</type>

  <boot dev='hd'/>

 </os>

 <features>

  <acpi/>

  <apic/>

 </features>

 <cpu mode='custom' match='exact' check='partial'>

  <model fallback='allow'>Haswell-noTSX</model>

 </cpu>

 <clock offset='utc'>

  <timer name='rtc' tickpolicy='catchup'/>

  <timer name='pit' tickpolicy='delay'/>

  <timer name='hpet' present='no'/>

 </clock>

 <on_poweroff>destroy</on_poweroff>

 <on_reboot>restart</on_reboot>

 <on_crash>destroy</on_crash>

 <pm>

  <suspend-to-mem enabled='no'/>

  <suspend-to-disk enabled='no'/>

 </pm>

 <devices>

  <emulator>/usr/libexec/qemu-kvm</emulator>

  <disk type='file' device='disk'>

   <driver name='qemu' type='qcow2'/>

   <source file='kvmimg'/>

   <target dev='vda' bus='virtio'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>

  </disk>

  <controller type='usb' index='0' model='ich9-ehci1'>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x7'/>

  </controller>

  <controller type='usb' index='0' model='ich9-uhci1'>

   <master startport='0'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0' multifunction='on'/>

  </controller>

  <controller type='usb' index='0' model='ich9-uhci2'>

   <master startport='2'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x1'/>

  </controller>

  <controller type='usb' index='0' model='ich9-uhci3'>

   <master startport='4'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x2'/>

  </controller>

  <controller type='pci' index='0' model='pci-root'/>

  <controller type='virtio-serial' index='0'>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>

  </controller>

  <interface type='network'>

   <mac address='52:54:00:kvmmac'/>

   <source network='default'/>

   <model type='virtio'/>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>

  </interface>

  <serial type='pty'>

   <target type='isa-serial' port='0'>

​    <model name='isa-serial'/>

   </target>

  </serial>

  <console type='pty'>

   <target type='serial' port='0'/>

  </console>

  <channel type='unix'>

   <target type='virtio' name='org.qemu.guest_agent.0'/>

   <address type='virtio-serial' controller='0' bus='0' port='1'/>

  </channel>

  <input type='mouse' bus='ps2'/>

  <input type='keyboard' bus='ps2'/>

  <memballoon model='virtio'>

   <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>

  </memballoon>

 </devices>

</domain>

 

## ***\*随机生成mac地址\****

其中5种方式：

\# echo $[$RANDOM%9]$[$RANDOM%9]:$[$RANDOM%9]$[$RANDOM%9]:$[$RANDOM%9]$[$RANDOM%9]

65:42:31

 

\# echo `openssl rand -hex 1`:`openssl rand -hex 1`:`openssl rand -hex 1`

99:6e:67

 

\# openssl rand -hex 3 | sed -r 's/(..)/\1:/g'|sed 's/.$//'

e9:b6:12

 

\# openssl rand -hex 3 | sed -r 's/(..)(..)(..)/\1:\2:\3/g'

94:89:e3

 

\# openssl rand -hex 3 | sed -r 's/..\B/&:/g'

c5:66:90

 

\B 表示 非单词边界

\b 表示 单词边界

<a  表示以a开头的单词

b>  表示以b结尾的单词

 

使用UUID：

\# uuidgen | sed -r 's/(..)(..)(..)(.*)/\1:\2:\3/'

 

使用熵池里面的随机数：

\# echo -n 00:60:2F; dd bs=1 count=3 if=/dev/random 2>/dev/null | hexdump -v -e '/1 ":%02X"'

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

#     

​    

​    

​    

 

 

 

 

 

 

 

 

​	

 

 

 

 

 