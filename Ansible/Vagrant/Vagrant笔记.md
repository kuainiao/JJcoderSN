## Vagrant快速入门

Vagrant是一个 Ruby 语言开发的工具，用于创建和部署虚拟化开发环境。它使用 Oracle 的开源 VirtualBox 等虚拟化系统，使用 Chef 创建自动化虚拟环境。可以快速新建虚拟机，支持快速设置端口转发和自定义镜像打包，类似 docker 和容器镜像，可以方便地共享 Vagrant 打包的 Box 镜像。

Vagrant 上手简单，功能强大，非常适合快速部署开发环境。下面介绍 Vagrant 的常用操作，可以做到使用他人分享的 Vagrantfile 配置文件创建一个一模一样的 Linux 系统。

## 1、安装 VirtualBox 软件包

首先，添加VirtualBox的Yum源

```bash
[admin@ityoudao ~]$ sudo wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo
[admin@ityoudao ~]$ yum repolist|grep -i virtualbox
virtualbox/7/x86_64 Oracle Linux / RHEL / CentOS-7 / x86_64 - VirtualBox      68
```

查看Yum源中提供的 VirtualBox 版本

```
[admin@ityoudao ~]$ yum list |grep -i virtualbox
VirtualBox-4.3.x86_64                  4.3.40_110317_el7-1             virtualbox
VirtualBox-5.0.x86_64                  5.0.40_115130_el7-1             virtualbox
VirtualBox-5.1.x86_64                  5.1.38_122592_el7-1             virtualbox
VirtualBox-5.2.x86_64                  5.2.28_130011_el7-1             virtualbox
VirtualBox-6.0.x86_64                  6.0.6_130049_el7-1              virtualbox
```

安装 VirtualBox-6.0.x86_64：

```
[admin@ityoudao ~]$ sudo yum install VirtualBox-6.0
[admin@ityoudao ~]$ vboxmanage --version
6.0.6r130049
```

## 2、安装 Vagrant 软件包

访问 [Vagrant官网](https://releases.hashicorp.com/vagrant/)复制最新版本 Vagrant 的下载链接，这里使用 CentOS7 操作系统选择 RPM 软件包，然后直接使用 Yum 安装：

```
[admin@ityoudao ~]$ sudo yum install -y https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_x86_64.rpm
[admin@ityoudao ~]$ vagrant --version
Vagrant 2.2.4
```

## 3、使用 Vagrantfile 模板文件创建虚拟机

这是一个简单的 Vagrantfile 模板文件，创建了一台 1核 1G内存 的 CentOS7 虚拟机：

```shell
[admin@ityoudao ~]$ mkdir vms && cd vms
[admin@ityoudao vms]$ cat > Vagrantfile <<EOF
Vagrant.require_version ">= 1.4.3"
Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = "node1"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network "public_network"
  config.vm.synced_folder "./data", "/vagrant_data"
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "1024"
    vb.cpus = 1
  end
  config.vm.provision "shell", inline: <<-SHELL
    yum install -y httpd
  SHELL
end
EOF
[admin@ityoudao vms]$ mkdir data && free -h > data/mem.txt
[admin@ityoudao vms]$ tree 
.
├── data
│   └── mem.txt
└── Vagrantfile

1 directory, 2 files
```

创建虚拟机 vagrant up：

```
[admin@ityoudao vms]$ vagrant up
```

## 4、常见问题和解决办法

### 无法下载 Box 或者下载速度慢

解决方法：

手动从[Discover Vagrant Boxes](https://app.vagrantup.com/boxes/search)下载需要的 Box，然后导入到Vagrant中。

如果是 Ubuntu 的 Box，也可以在[清华大学开源软件镜像站/ubuntu-cloud-images/vagrant](https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/vagrant/)下载。

如果是 CentOS 的 Box，也可以在 [CentOS官网](https://cloud.centos.org/centos/7/vagrant/x86_64/images/)下载。

下载完成之后，导入 Box：

```
[admin@ityoudao Downloads]$ ll centos7-standard.box 
-rw-r--r-- 1 admin admin 680737977 Apr  7 12:34 centos7-standard.box
[admin@ityoudao Downloads]$ vagrant box add centos7-standard.box --name centos/7
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'centos/7' (v0) for provider: 
    box: Unpacking necessary files from: file:///home/admin/Downloads/centos7-standard.box
==> box: Successfully added box 'centos/7' (v0) for 'virtualbox'!
[admin@ityoudao Downloads]$ vagrant box list
centos/7 (virtualbox, 0)
```

- `vagrant box add`命令的“--name”参数指定导入 Vagrant 后的 Box 名称，需要和 Vagrantfile 中的`config.vm.box`一致。

### 当前终端不支持 GUI

错误详情：

```
[admin@ityoudao vms]$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'centos/7'...
==> default: Matching MAC address for NAT networking...
==> default: Setting the name of the VM: vms_default_1558184345287_40173
==> default: Fixed port collision for 22 => 2222. Now on port 2206.
==> default: Clearing any previously set network interfaces...
==> default: Available bridged network interfaces:
1) em1
2) virbr2
3) virbr3
4) virbr0
5) em2
6) em4
7) em3
8) virbr1
==> default: When choosing an interface, it is usually the one that is
==> default: being used to connect to the internet.
    default: Which interface should the network bridge to? 1
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
    default: Adapter 2: hostonly
    default: Adapter 3: bridged
==> default: Forwarding ports...
    default: 80 (guest) => 8080 (host) (adapter 1)
    default: 22 (guest) => 2206 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["startvm", "1f38067f-24cd-42a6-b373-43aa65f7a2bd", "--type", "gui"]

Stderr: VBoxManage: error: The virtual machine 'vms_default_1558184345287_40173' has terminated unexpectedly during startup because of signal 6
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component MachineWrap, interface IMachine
```

- 可以看到是`Command: ["startvm", "1f38067f-24cd-42a6-b373-43aa65f7a2bd", "--type", "gui"]`命令报错，错误信息“VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component MachineWrap, interface IMachine”。

错误原因：

如果设置了`vb.gui = true`，Vagrant 启动虚拟机的时候会弹出 VirtualBox 图形管理界面，如果无法打开图像窗口则启动虚拟机失败。当前使用 SSH 连接远程服务器，终端不支持图形界面，解决办法是关闭 GUI 图形界面：

```
[admin@ityoudao vms]$ sed -i "s/vb.gui = true/vb.gui = false/g" Vagrantfile 
```

### 和正在运行的 qemu-kvm 冲突导致 Virtualbox 虚拟机无法启动

错误详情：

```
[admin@ityoudao vms]$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
    default: Adapter 2: hostonly
    default: Adapter 3: bridged
==> default: Forwarding ports...
    default: 80 (guest) => 8080 (host) (adapter 1)
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
The guest machine entered an invalid state while waiting for it
to boot. Valid states are 'starting, running'. The machine is in the
'gurumeditation' state. Please verify everything is configured
properly and try again.

If the provider you're using has a GUI that comes with it,
it is often helpful to open that and watch the machine, since the
GUI often has more helpful error messages than Vagrant can retrieve.
For example, if you're using VirtualBox, run `vagrant up` while the
VirtualBox GUI is open.

The primary issue for this error is that the provider you're using
is not properly configured. This is very rarely a Vagrant issue.
```

查看虚拟机状态，处于"guru meditation"状态：

```
[admin@ityoudao vms]$ vagrant status
Current machine states:

default                   gurumeditation (virtualbox)

The VM is in the "guru meditation" state. This is a rare case which means
that an internal error in VirtualBox caused the VM to fail. This is always
the sign of a bug in VirtualBox. You can try to bring your VM back online
with a `vagrant up`.
```

再次启动，报“Stderr: VBoxManage: error: The machine 'vms_default_1558191366286_54440' is already locked for a session”错误：

```
[admin@ityoudao vms]$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Clearing any previously set forwarded ports...
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["modifyvm", "25b49370-4586-40b0-bcfe-f6d1ad243776", "--natpf1", "delete", "ssh", "--natpf1", "delete", "tcp8080"]

Stderr: VBoxManage: error: The machine 'vms_default_1558191366286_54440' is already locked for a session (or being unlocked)
VBoxManage: error: Details: code VBOX_E_INVALID_OBJECT_STATE (0x80bb0007), component MachineWrap, interface IMachine, callee nsISupports
VBoxManage: error: Context: "LockMachine(a->session, LockType_Write)" at line 527 of file VBoxManageModifyVM.cpp
```

尝试重启虚拟机，但是无论是`vagrant halt`关闭虚拟机重新启动，还是`vagrant destroy`销毁虚拟机重新创建，都报同样的错误。

最后发现宿主机中有运行中的 KVM 虚拟机，猜想可能是 KVM 和 VirtualBox 两个虚拟机管理器之间存在冲突，果然关闭 KVM 虚拟机之后 VirtualBox 虚拟机启动成功：

```
[admin@ityoudao vms]$ ps -el|grep -e CMD -e kvm
F S   UID    PID   PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
1 S     0    963      2  0  60 -20 -     0 rescue ?        00:00:00 kvm-irqfd-clean
6 S   107  12059      1  2  80   0 - 1228895 poll_s ?      00:00:27 qemu-kvm
1 S     0  12117      2  0  80   0 -     0 kthrea ?        00:00:00 kvm-pit/12059
[admin@ityoudao vms]$ sudo kill -9 12059
[admin@ityoudao vms]$ ps -el|grep -e CMD -e kvm
F S   UID    PID   PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
1 S     0    963      2  0  60 -20 -     0 rescue ?        00:00:00 kvm-irqfd-clean

[admin@ityoudao vms]$ vagrant halt
==> default: Forcing shutdown of VM...
[admin@ityoudao vms]$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
...
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
...
```

有时候会提示 Intel CPU 的虚拟化指令集 VT-x 被占用：“Stderr: VBoxManage: error: VT-x is being used by another hypervisor (VERR_VMX_IN_VMX_ROOT_MODE)”，但是有时候却没有提示，很奇怪：

```
==> default: Booting VM...
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["startvm", "db0f3d31-ab12-42cc-9275-291c4258b3ea", "--type", "headless"]

Stderr: VBoxManage: error: VT-x is being used by another hypervisor (VERR_VMX_IN_VMX_ROOT_MODE).
VBoxManage: error: VirtualBox can't operate in VMX root mode. Please disable the KVM kernel extension, recompile your kernel and reboot (VERR_VMX_IN_VMX_ROOT_MODE)
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component ConsoleWrap, interface IConsole
```

### 无法连接虚拟机 default: Warning: Authentication failure. Retrying...

错误详情：

```
[admin@ityoudao vms]$ vagrant up
...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
    default: Adapter 2: hostonly
    default: Adapter 3: bridged
==> default: Forwarding ports...
    default: 80 (guest) => 8080 (host) (adapter 1)
    default: 22 (guest) => 2206 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2206
    default: SSH username: vagrant
    default: SSH auth method: private key
    default: Warning: Authentication failure. Retrying...
    default: Warning: Authentication failure. Retrying...
    default: Warning: Authentication failure. Retrying...
^C==> default: Waiting for cleanup before exiting...
Vagrant exited after cleanup due to external interrupt.
```

尝试使用`vagrant ssh`命令手动连接：

```
[admin@ityoudao vms]$ vagrant status
Current machine states:

default                   running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
[admin@ityoudao vms]$ vagrant ssh
vagrant@127.0.0.1's password: 
Last login: Sat May 18 16:21:23 2019 from 10.0.2.2
[vagrant@node1 ~]$ cat .ssh/authorized_keys 
[vagrant@node1 ~]$ ll .ssh
total 0
-rw------- 1 vagrant vagrant 0 May 18 16:06 authorized_keys
```

果然需要密码才能 SSH 登录，难怪“Warning: Authentication failure.”后来发现原因是宿主机上的当前用户没有生成 SSH 密钥对：

```
[admin@ityoudao vms]$ ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
Generating public/private rsa key pair.
Your identification has been saved in /home/admin/.ssh/id_rsa.
Your public key has been saved in /home/admin/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:N8HohrFTM4NvYfIaBYxHY9DdX5EKR002Fk73uAdIg+Y admin@ityoudao
The key's randomart image is:
+---[RSA 2048]----+
|    .*=. . o+oO+.|
|    ..++.o=..B++.|
|     .+ Xoo+.o+ .|
|       % =E.o  o |
|      = S o   . .|
|       * . .   . |
|      .          |
|                 |
|                 |
+----[SHA256]-----+
```

宿主机上生成 SSH 密钥对之后，`vagrant destroy`销毁虚拟机，`vagrant up`重新创建虚拟机问题解决。

### CentOS8中vboxdrv内核模块未加载 WARNING: The vboxdrv kernel module is not loaded

```
[root@ityoudao ~]# cat /etc/redhat-release
CentOS Linux release 8.0.1905 (Core)
[root@ityoudao ~]# uname -r
4.18.0-80.el8.x86_64

[root@ityoudao ~]# vboxmanage list vms
WARNING: The vboxdrv kernel module is not loaded. Either there is no module
         available for the current kernel (4.18.0-80.el8.x86_64) or it failed to
         load. Please recompile the kernel module and install it by

           sudo /sbin/vboxconfig

         You will not be able to start VMs until this problem is fixed.

[root@ityoudao ~]# vboxconfig
vboxdrv.sh: Stopping VirtualBox services.
vboxdrv.sh: Starting VirtualBox services.
vboxdrv.sh: Building VirtualBox kernel modules.
This system is currently not set up to build kernel modules.
Please install the gcc make perl packages from your distribution.
Please install the Linux kernel "header" files matching the current kernel
for adding new hardware support to the system.
The distribution packages containing the headers are probably:
    kernel-devel kernel-devel-4.18.0-80.el8.x86_64
This system is currently not set up to build kernel modules.
Please install the gcc make perl packages from your distribution.
Please install the Linux kernel "header" files matching the current kernel
for adding new hardware support to the system.
The distribution packages containing the headers are probably:
    kernel-devel kernel-devel-4.18.0-80.el8.x86_64

There were problems setting up VirtualBox.  To re-start the set-up process, run
  /sbin/vboxconfig
as root.  If your system is using EFI Secure Boot you may need to sign the
kernel modules (vboxdrv, vboxnetflt, vboxnetadp, vboxpci) before you can load
them. Please see your Linux system's documentation for more information.

[root@ityoudao ~]# yum install gcc make perl kernel-devel-4.18.0-80.el8.x86_64 -y
[root@ityoudao ~]# vboxconfig
vboxdrv.sh: Stopping VirtualBox services.
vboxdrv.sh: Starting VirtualBox services.
vboxdrv.sh: Building VirtualBox kernel modules.
vboxdrv.sh: failed: Look at /var/log/vbox-setup.log to find out what went wrong.

There were problems setting up VirtualBox.  To re-start the set-up process, run
  /sbin/vboxconfig
as root.  If your system is using EFI Secure Boot you may need to sign the
kernel modules (vboxdrv, vboxnetflt, vboxnetadp, vboxpci) before you can load
them. Please see your Linux system's documentation for more information.
[root@ityoudao ~]# cat /var/log/vbox-setup.log
Building the main VirtualBox module.
Error building the module:
make V=1 CONFIG_MODULE_SIG= -C /lib/modules/4.18.0-80.el8.x86_64/build M=/tmp/vbox.0 SRCROOT=/tmp/vbox.0 -j8 modules
make[1]: warning: -jN forced in submake: disabling jobserver mode.
Makefile:958: *** "Cannot generate ORC metadata for CONFIG_UNWINDER_ORC=y, please install libelf-dev, libelf-devel or elfutils-libelf-devel".  Stop.
make: *** [/tmp/vbox.0/Makefile-footer.gmk:111: vboxdrv] Error 2

[root@ityoudao ~]# yum install elfutils-libelf-devel -y
[root@ityoudao ~]# vboxconfig
vboxdrv.sh: Stopping VirtualBox services.
vboxdrv.sh: Starting VirtualBox services.
vboxdrv.sh: Building VirtualBox kernel modules.

[root@ityoudao ~]# vboxmanage list vms
```

## 5、使用 vagrant 命令管理虚拟机

### 查看虚拟机状态 vagrant status

```
[admin@ityoudao vms]$ vagrant status
Current machine states:

default                   running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.

[admin@ityoudao vms]$ vagrant status default
Current machine states:

default                   running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
```

- 其中前面的“default”是虚拟机的名字，这里只有一台虚拟机，可以省略名字。如果一个 Vagrantfile 创建了多台虚拟机，名字必须各不相同。

### 连接虚拟机 vagrant ssh

```
[admin@ityoudao vms]$ vagrant ssh
Sat May 18 17:45:10 EEST 2019
[vagrant@node1 ~]$ rpm -q httpd
httpd-2.4.6-89.el7.centos.x86_64
[vagrant@node1 ~]$ df -h
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/centos-root  6.7G  1.4G  5.4G  20% /
devtmpfs                 489M     0  489M   0% /dev
tmpfs                    498M     0  498M   0% /dev/shm
tmpfs                    498M  6.6M  491M   2% /run
tmpfs                    498M     0  498M   0% /sys/fs/cgroup
/dev/sda1                497M  134M  363M  27% /boot
none                     7.1T  227G  6.8T   4% /vagrant
none                     7.1T  227G  6.8T   4% /vagrant_data
[vagrant@node1 ~]$ ll /vagrant_data/
total 4
-rw-rw-r-- 1 vagrant vagrant 204 May 18 14:43 mem.txt
[vagrant@node1 ~]$ ll /vagrant
total 4
drwxrwxr-x 1 vagrant vagrant  29 May 18 14:43 data
-rw-rw-r-- 1 vagrant vagrant 527 May 18 17:38 Vagrantfile
[vagrant@node1 ~]$ mount -v|grep vagrant
none on /vagrant type vboxsf (rw,nodev,relatime)
none on /vagrant_data type vboxsf (rw,nodev,relatime)
```

- Vagrant 根据 Vagrantfile 中的配置，自动安装了 Apache 软件包；
- “/vagrant_data”是 Vagrantfile 文件中定义的挂载目录“./data”；
- “/vagrant”是 Vagrant 自动挂载 Vagrant 所在目录。

### 关闭虚拟机 vagrant halt

```
[admin@ityoudao vms]$ vagrant halt
==> default: Attempting graceful shutdown of VM...
```

### 销毁虚拟机 vagrant destroy

```
[admin@ityoudao vms]$ vagrant destroy default
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Destroying VM and associated drives...
```

没错，使用 Vagrant 就是怎么简单！大多数时候，有这几个命令就够了，其中`vagrant up`命令从 Vagrantfile 模板文件创建虚拟机，`vagrant status`命令查看虚拟机状态，`vagrant ssh`命令连接虚拟机，`vagrant halt`命令关闭虚拟机，`vagrant destroy`命令销毁虚拟机，如果 Vagrantfile 文件定义了多个虚拟机，加上对应虚拟机的名字就可以了。



## Vagrant常用命令

- `vagrant box add "boxIdentity" remoteUrlorLocalFile` 添加box
- `vagrant init "boxIdentity"` 初始化box
- `vagrant up` 启动虚拟机
- `vagrant ssh` 登录虚拟机
- `vagrant box list` 显示当前已添加的box列表
- `vagrant box remove "boxIdentity"` 删除box
- `vagrant destroy` 停止当前正在运行的虚拟机并销毁所有创建的资源
- `vagrant halt` 关闭虚拟机
- `vagrant package` 打包当前运行的虚拟机的环境
- `vagrant plugin` 用于安装卸载插件
- `vagrant reload` 重启虚拟机，主要用于重新载入配置文件
- `vagrant suspend` 挂起虚拟机
- `vagrant resume` 恢复挂起状态
- `vagrant ssh-config` 输出ssh连接信息
- `vagrant status` 输出当前虚拟机的状态