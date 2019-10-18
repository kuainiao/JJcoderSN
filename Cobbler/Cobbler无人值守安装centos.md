# Cobbler无人值守安装CentOS

# 简介

[Cobbler](http://cobbler.github.io/) 是一个 Linux 服务器快速网络安装的服务，而且在经过调整也可以支持网络安装 windows。该工具使用 Python 开发，小巧轻便（才15k行 Python 代码），可以通过网络启动（PXE ）的方式来快速安装、重装物理服务器和虚拟机，同时还可以管理 DHCP，DNS，TFTP、RSYNC 以及 yum 仓库、构造系统 ISO 镜像。

Cobbler 是较早前的 Kickstart 的升级版，优点是比较容易配置。它可以使用命令行方式管理，也提供了基于 Web 的界面管理工具(cobbler-web)，还提供了 API 接口，可以方便二次开发使用。

Cobbler 内置了一个轻量级配置管理系统，但它也支持和其它配置管理系统集成，如 Puppet，暂时不支持 SaltStack。Cobbler 客户端 Koan 支持虚拟机安装和操作系统重新安装，使重装系统更便捷。

# 核心组件

- Distros
    - distro(发行版)，这里指的是操作系统的发行版
    - 每一个要装的发行版操作系统都应该被单独定义成一个distro
    - 常见的 distro 如 CentOS 6.8 ，CentOS 6.9，CentOS 7.4等发行版
- Profiles and Sub-Profiles
    - 基于 distro (可以是一个也可以是多个)，借助不同的 Kickstart 文件配置出不同的业务环境来，这每一个环境就是一个 profile
    - 一个 distro 和一个与之相关联的配置文件( Kickstart )并结合其他的环境配置构成了一个 profile，Kickstart 是这其中的关键点
    - 一个 profile 是构建在 distro 之上的，能适用于多种服务器角色部署的一个逻辑组件
    - sub-profile 是子 profile ，只有在构建极为复杂的环境时才有可能会用到 sub-profile
- Systems
    - 在 profile 的基础之上，为特定主机指派上特定的、独有的一些系统级别的配置信息，从而实现定义至操作系统级别
- Repos
    - repository，仓库。Kickstart 需要借助 yum 的 repository 才能安装完成操作系统。
    - Repos 主要用于定义 repository
- Images
    - 用于实现在虚拟化环境当中，用来管理虚拟机的磁盘映像文件
- Management Classes
- File Resources
- Package Resources

# 集成的服务

- PXE 服务支持
- DHCP 服务管理
- DNS 服务管理(可选bind,dnsmasq)
- 电源管理
- Kickstart 服务支持
- YUM 仓库管理
- TFTP(PXE启动时需要)
- Apache(提供 Kickstart 的安装源，并提供定制化的 Kickstart 配置)

# 基本工作流程

**服务器端**

复制

```
第一步，启动Cobbler服务第二步，进行Cobbler错误检查，执行cobbler check命令第三步，进行配置同步，执行cobbler sync命令第四步，第一步，启动Cobbler服务
第二步，进行Cobbler错误检查，执行cobbler check命令
第三步，进行配置同步，执行cobbler sync命令
第四步，复制相关启动文件文件到TFTP目录中
第五步，启动DHCP服务，提供地址分配
第六步，DHCP服务分配IP地址
第七步，TFTP传输启动文件
第八步，Server端接收安装信息
第九步，Server端发送ISO镜像与Kickstart文件，启动DHCP服务，提供地址分配第六步，DHCP服务分配IP地址第七步，TFTP传输启动文件第八步，Server端接收安装信息第九步，Server端发送ISO镜像与Kickstart文件
```

**客户端**

复制

```
第一步，客户端以PXE模式启动
第二步，客户端获取IP地址
第三步，通过TFTP服务器获取启动文件
第四步，进入Cobbler安装选择界面
第五步，客户端确定加载信息
第六步，根据配置信息准备安装系统
第七步，加载Kickstart文件
第八步，传输系统安装的其它文件
第九步，进行安装系统第一步，客户端以PXE模式启动第二步，客户端获取IP地址第三步，通过TFTP服务器获取启动文件第四步，进入Cobbler安装选择界面第五步，客户端确定加载信息第六步，根据配置信息准备安装系统第七步，加载Kickstart文件第八步，传输系统安装的其它文件第九步，进行安装系统
```

# 安装和配置

[官方手册](http://cobbler.github.io/manuals/quickstart/)

环境说明

- 虚拟机版本：VMware® Workstation 14 Pro
- Cobbler 服务器上需要搭建 DHCP 服务器为新安装的操作系统分配 IP 地址，但在同一局域网多个 DHCP 服务会有冲突，因此虚拟机采用 NAT 模式
- 避免出现依赖关系上的错误，使用全新的操作系统，这里使用的是 CentOS 7.4.1708
- Cobbler 的 IP 地址为 `192.168.127.10`

cobbler 的安装需要依赖 epel 源，使用 yum 查看 Cobbler 的信息，可以看到 Repo 字段对应的源是 epel

复制

```
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repoyum info cobbler
```

设置语言环境、禁用 SELINUX 、停用防火墙等配置

复制

```
# install vim
yum -y install vim-enhanced

# Set language
langfile='/etc/locale.conf'
export LANG="en_US.UTF-8";
sed -ri '/LANG/s/=.*/="en_US.UTF-8"/' ${langfile}

# Turn off selinux
setenforce 0
fileList=(/etc/sysconfig/selinux /etc/selinux/config)
for f in ${fileList[@]};do
  sed -ri 's/(^SELINUX=).*/\1disabled/' ${f}
done

# Disable the DNS function of sshd
egrep -q '^UseDNS no' /etc/ssh/sshd_config || \
sed -ri '/#UseDNS /aUseDNS no' /etc/ssh/sshd_config

# Turn off some services
/usr/bin/systemctl stop firewalld.service;
/usr/bin/systemctl disable firewalld.service;
/usr/bin/systemctl is-enabled firewalld.service;

# Add firewall policy
IPT='/sbin/iptables'
# ---------------------------------------
for chain in INPUT OUTPUT FORWARD;do
  ${IPT} -t filter -P ${chain}  ACCEPT &>/dev/null
done
unset chain
# ---------------------------------------
for chain in PREROUTING POSTROUTING OUTPUT;do
  ${IPT} -t nat -P ${chain} ACCEPT &>/dev/null
done
unset chain
# ---------------------------------------
for chain in PREROUTING INPUT FORWARD OUTPUT POSTROUTING;do
  ${IPT} -t mangle -P ${chain} ACCEPT &>/dev/null
done
unset chain
# ---------------------------------------
for table in filter nat mangle;do
  ${IPT} -F -t ${table}   &>/dev/null
  ${IPT} -X -t ${table}   &>/dev/null
done
```

添加了 epel 源后直接 yum 安装

复制

```
yum -y install cobbler cobbler-web pykickstart httpd dhcp tftp-server
# cobbler            # cobbler程序包
# cobbler-web        # cobbler的web端程序包
# pykickstart        # 用于cobbler检查kickstart语法错误
# httpd              # Apache的web服务
# dhcp               # dhcp服务程序包，也可以使用dnsmasq配置成DHCP服务器
# tftp-server        # tftp服务
```

查看包中生成了哪些文件

复制

```
[root@cobbler ~]# rpm -ql cobbler  # 查看安装的文件，下面列出部分。
/etc/cobbler                  # 配置文件目录
/etc/cobbler/settings         # cobbler主配置文件，yaml格式，cobbler是python写的程序。
/etc/cobbler/dhcp.template    # dhcp服务的配置模板
/etc/cobbler/tftpd.template   # tftp服务的配置模板
/etc/cobbler/rsync.template   # rsync服务的配置模板
/etc/cobbler/iso              # iso模板配置文件目录
/etc/cobbler/pxe              # pxe模板文件目录
/etc/cobbler/power            # 电源的配置文件目录
/etc/cobbler/users.conf       # web服务授权配置文件
/etc/cobbler/users.digest     # web访问的用户名密码配置文件
/etc/cobbler/dnsmasq.template # DNS服务的配置模板
/etc/cobbler/modules.conf     # cobbler模块配置文件
/var/lib/cobbler              # cobbler数据目录
/var/lib/cobbler/config       # 配置文件
/var/lib/cobbler/kickstarts   # 默认存放kickstart文件
/var/lib/cobbler/loaders      # 存放的各种引导程序
/var/www/cobbler              # 系统安装镜像目录
/var/www/cobbler/ks_mirror    # 导入的系统镜像列表
/var/www/cobbler/images       # 导入的系统镜像启动文件
/var/www/cobbler/repo_mirror  # yum源存储目录
/var/log/cobbler              # 日志目录
/var/log/cobbler/install.log  # 客户端系统安装日志
/var/log/cobbler/cobbler.log  # cobbler日志
```

依赖关系说明

- Cobbler的运行依赖于dhcp、tftp、rsync 及 dns 服务
    - dhcp 可由 dhcpd（isc）提供，也可由 dnsmasq 提供；
    - tftp 可由 tftp-server 程序包提供，也可由 cobbler 功能提供；
    - rsync 由 rsync 程序包提供，dns 可由 bind 提供，也可由 dnsmasq 提供；
- Cobbler 可自行管理这些服务中的部分甚至是全部，但需要配置文件 `/etc/cobbler/settings` 中的`manange_dhcp`、`manager_tftpd`、`manager_rsync`、`manager_dns` 分别来进行定义
- 由于各种服务都有着不同的实现方式，如若需要进行自定义，需要通过修改`/etc/cobbler/modules.conf`配置文件中各服务的模块参数的值来实现。

将 httpd 加入开机启动服务列表并立即启动服务

复制

```
systemctl enable httpd --now
systemctl is-enabled httpd
systemctl status httpd
```

修改 cobbler 的 dhcp 模版文件 `/etc/cobbler/dhcp.template`，此模板会覆盖 dhcp 本身的配置文件，所以在此之前 **确保没有启动dhcp服务也没有修改dhcp的配置文件**

复制

```
subnet 192.168.127.0 netmask 255.255.255.0 {
     option routers             192.168.127.2;
     option domain-name-servers 192.168.127.2;
     option subnet-mask         255.255.255.0;
     range dynamic-bootp        192.168.127.130 192.168.127.230;
     default-lease-time         21600;
     max-lease-time             43200;
     next-server                $next_server;
     class "pxeclients" {
          match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
          if option pxe-system-type = 00:02 {
                  filename "ia64/elilo.efi";
          } else if option pxe-system-type = 00:06 {
                  filename "grub/grub-x86.efi";
          } else if option pxe-system-type = 00:07 {
                  filename "grub/grub-x86_64.efi";
          } else if option pxe-system-type = 00:09 {
                  filename "grub/grub-x86_64.efi";
          } else {
                  filename "pxelinux.0";
          }
     }

}
```

如果是多网卡环境还需要指定 dhcp 使用的网卡，修改 `/usr/lib/systemd/system/dhcpd.service` 文件中 `ExecStart` 最后面加上网卡名称，然后重载 systemctl，将 dhcpd 加入开机启动服务列表并立即启动服务

复制

```
systemctl daemon-reload
systemctl enable dhcpd --now
systemctl is-enabled dhcpd
systemctl status dhcpd
```

将 cobblerd 加入开机启动服务列表并立即启动服务

复制

```
systemctl enable cobblerd --now
systemctl is-enabled cobblerd
systemctl status cobblerd
```

# 配置检查

使用 Cobbler 的检查工具检查配置存在的问题并依次解决

复制

```
[root@Cobbler ~]# cobbler check
The following are potential configuration items that you may want to fix:

1 : The 'server' field in /etc/cobbler/settings must be set to something other than localhost, or kickstarting features will not work.  This should be a resolvable hostname or IP for the boot server as reachable by all machines that will use it.
2 : For PXE to be functional, the 'next_server' field in /etc/cobbler/settings must be set to something other than 127.0.0.1, and should match the IP of the boot server on the PXE network.
3 : change 'disable' to 'no' in /etc/xinetd.d/tftp
4 : Some network boot-loaders are missing from /var/lib/cobbler/loaders, you may run 'cobbler get-loaders' to download them, or, if you only want to handle x86/x86_64 netbooting, you may ensure that you have installed a *recent* version of the syslinux package installed and can ignore this message entirely.  Files in this directory, should you want to support all architectures, should include pxelinux.0, menu.c32, elilo.efi, and yaboot. The 'cobbler get-loaders' command is the easiest way to resolve these requirements.
5 : enable and start rsyncd.service with systemctl
6 : debmirror package is not installed, it will be required to manage debian deployments and repositories
7 : The default password used by the sample templates for newly installed machines (default_password_crypted in /etc/cobbler/settings) is still set to 'cobbler' and should be changed, try: "openssl passwd -1 -salt 'random-phrase-here' 'your-password-here'" to generate new one
8 : fencing tools were not found, and are required to use the (optional) power management features. install cman or fence-agents to use them

Restart cobblerd and then run 'cobbler sync' to apply changes.
```

修改 `/etc/cobbler/settings` 文件中的 `server` 参数的值为提供 cobbler 服务的主机相应的 IP 地址或主机名，如`server: 192.168.127.10`

复制

```
cp /etc/cobbler/settings{,.bak}
sed -ri 's#^server: 127.0.0.1#server: 192.168.127.10#' /etc/cobbler/settings
```

修改 `/etc/cobbler/settings` 文件中的 `next_server` 参数的值为提供 PXE 服务的主机相应的IP地址，如`next_server: 192.168.127.10`。server，pxe服务器的IP由于这里使用的是同一台机器，所以填 Cobbler 服务器的 IP 即可

复制

```
sed -ri 's#^next_server: 127.0.0.1#next_server: 192.168.127.10#' /etc/cobbler/settings
```

修改 `/etc/xinetd.d/tftp` 文件中的 disable 参数修改为 `disable = no`

复制

```
cp /etc/xinetd.d/tftp{,.bak}
sed -ri '/disable(\t| )*=/s#yes#no#g' /etc/xinetd.d/tftp

systemctl enable tftp.socket --now
systemctl status  tftp.socket
chmod +x /etc/rc.d/rc.local 
echo 'systemctl enable tftp.socket --now' >> /etc/rc.d/rc.local


systemctl enable tftp.service --now
systemctl status  tftp.service
```

根据提示执行 `cobbler get-lders` 命令，最后提示 `*** TASK COMPLETE ***` 表示成功

将 rsyncd 加入开机启动服务列表并立即启动服务

复制

```
systemctl enable rsyncd.service --now
systemctl is-enabled  rsyncd.service
systemctl status rsyncd.service
```

使用 yum 安装 debmirror

复制

```
yum -y install debmirror
sed -ri '/^(@dists=|@arches).*/s/^/#/g' /etc/debmirror.conf
```

生成自定义密码密码来取代默认的密码，为了更安全，建议使用复杂度较高的密码

复制

```
openssl passwd -1 -salt litingjie 123456
$1$litingji$qUWL9htxlLybWLhSuyL8g/
sed -ri 's#^(default_password_crypted:).*#\1 "$1$litingji$qUWL9htxlLybWLhSuyL8g/"#' /etc/cobbler/settings
```

使用 yum 安装 cman fence-agents

复制

```
yum -y install cman fence-agents
```

配置使用用 cobbler 管理DHCP

复制

```
sed -ri 's#^(manage_dhcp:).*#\1 1#g' /etc/cobbler/settings
```

为防止循环装系统，适用于服务器第一启动项是PXE启动

复制

```
sed -ri '/^pxe_just_once:.*/s#0#1#g' /etc/cobbler/settings
```

重启 cobblerd 服务，再次检查

复制

```
systemctl restart cobblerd.service
[root@Cobbler ~]# cobbler check
No configuration problems found.  All systems go.
```

同步 cobbler 的配置，可以看到同步做了哪些操作

复制

```
cobbler sync
```

获取 Usage

复制

```
cobbler
cobbler --help
cobbler distro --help
cobbler profile --help
```

选项说明

复制

```
cobbler check    核对当前设置是否有问题
cobbler list     列出所有的cobbler元素cobbler 
report           列出元素的详细信息
cobbler sync     同步配置到数据目录,更改配置最好都要执行下
cobbler reposync 同步yum仓库
cobbler distro   查看导入的发行版系统信息
cobbler system   查看添加的系统信息cobbler 
profile          查看配置信息
```

# 安装CentOS6.9

Cobbler基本配置做好之后便可以创建多个 distro (发行版)来安装不同版本系统了

挂载 CentOS 6.9 镜像

复制

```
mount -r /dev/cdrom /mnt/
ls /mnt/
```

创建ks(ksckstart)文件

复制

```
cp /var/lib/cobbler/kickstarts/sample_end.ks /var/lib/cobbler/kickstarts/CentOS-6.9.cfg
vim /var/lib/cobbler/kickstarts/CentOS-6.9.cfg
```

配置后的文件内容

复制

```
# This kickstart file should only be used with EL > 5 and/or Fedora > 7.
# For older versions please use the sample.ks kickstart file.

#platform=x86, AMD64, or Intel EM64T
# System authorization information
#auth  --useshadow  --enablemd5
authconfig --enableshadow --passalgo=sha512
# System bootloader configuration
bootloader --location=mbr --driveorder=sda --append="nomodeset crashkernel=auto rhgb quiet"
# Partition clearing information
clearpart --all --initlabel
# Use text mode install
text
# Firewall configuration
firewall --enabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US.UTF-8
# Use network installation
url --url=$tree
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# Network information
$SNIPPET('network_config')
# Reboot after installation
reboot
# Installation logging level
logging --level=info

#Root password
rootpw --iscrypted $default_password_crypted
# System services
services --disabled="NetworkManager"
services --disabled="postfix"
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx
# System timezone
timezone  Asia/Shanghai
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr
# Allow anaconda to partition the system as needed
autopart

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end

%packages
@base
@compat-libraries
@development
vim-enhanced
bind-utils
%end

%post --nochroot
$SNIPPET('log_ks_post_nochroot')
%end

%post
$SNIPPET('log_ks_post')
# Start yum configuration
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('func_register_if_enabled')
$SNIPPET('download_config_files')
$SNIPPET('koan_environment')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')
# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('kickstart_done')
# End final steps
%end
```

将镜像中的文件导入Cobbler，创建 distro

复制

```
cobbler import --help
cobbler import --path=/mnt/ --name="CentOS-6.9_x86_64" --arch=x86_64 --kickstart=/var/lib/cobbler/kickstarts/CentOS-6.9.cfg 
# --path 镜像路径  
# --name 为安装源定义一个名字  
# --arch 指定安装源是32位、64位、ia64, 目前支持的选项有: x86│x86_64│ia64  
# 安装源的唯一标示就是根据name参数来定义，本例导入成功后，安装源的唯一标示就是：CentOS-6.9_x86_64，如果重复，系统会提示导入失败。

# 导入完成后的文件存放在/var/www/cobbler/ks_mirror/下以name命名的目录下
ls /var/www/cobbler/ks_mirror/

# 查看元素，同步数据
cobbler list
cobbler sync
# 同步完成后会生成 /var/lib/tftpboot/pxelinux.cfg/default
```

信息查看

复制

```
cobbler distro report  --name=CentOS-6.9-x86_64
cobbler profile report --name=CentOS-6.9-x86_64
```

如果不想要这个 distro 了，则按照下面的方法删除

复制

```
cobbler profile remove --name=CentOS-6.9-x86_64
cobbler distro remove --name=CentOS-6.9-x86_64
```

客户机引导时出现选择页面，`local` 和`CentOS-6.9-x86_64`，干扰自动部署。此时需要编辑 `/var/lib/tftpboot/pxelinux.cfg/default`，修改 `TIMEOUT` 为 100，即等待时间为 10 秒，修改 `ONTIMEOUT` 为对应的 Label `CentOS-6.9-x86_64` ，即超过了等待时间后默认安装哪个系统。重启服务 `systemctl restart cobblerd`，需要注意的是，如果此时执行了 `cobbler sync` 就会重新生成 defatul 文件，之前的配置将被覆盖。

# 安装CentOS7.4

挂载 CentOS 7.4 镜像

复制

```
umount /dev/cdrom
mount -r /dev/cdrom /mnt/
ls /mnt/
```

创建ks(ksckstart)文件

复制

```
cp /var/lib/cobbler/kickstarts/sample_end.ks /var/lib/cobbler/kickstarts/CentOS-7.4.cfg
vim /var/lib/cobbler/kickstarts/CentOS-7.4.cfg
```

配置后的文件内容

复制

```
# This kickstart file should only be used with EL > 5 and/or Fedora > 7.
# For older versions please use the sample.ks kickstart file.

#platform=x86, AMD64, or Intel EM64T
# System authorization information
#auth  --useshadow  --enablemd5
authconfig --enableshadow --passalgo=sha512
# System bootloader configuration
bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel
# Use text mode install
text
# Firewall configuration
firewall --disabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US.UTF-8
# Use network installation
url --url=$tree
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# Network information
$SNIPPET('network_config')
# Reboot after installation
reboot
# Installation logging level
logging --level=info

#Root password
rootpw --iscrypted $default_password_crypted
# System services
services --disabled="NetworkManager"
services --disabled="postfix"
services --disabled="firewalld"
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx
# System timezone
timezone  Asia/Shanghai
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr
# Allow anaconda to partition the system as needed
#autopart
part /boot --fstype="xfs" --asprimary --size=200
part swap --fstype="swap" --asprimary --size=2000
part / --fstype="xfs" --asprimary --size=1 --grow

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end

%packages
@^minimal
@compat-libraries
@core
@development
bash-completion
kexec-tools
tree
wget
openssh-clients
glibc
gmp
bzip2
bind-utils
net-tools
mtr 
lrzsz
nmap
tcpdump
dos2unix
vim-enhanced
%end

%post --nochroot
$SNIPPET('log_ks_post_nochroot')
%end

%post
$SNIPPET('log_ks_post')
# Start yum configuration
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('func_register_if_enabled')
$SNIPPET('download_config_files')
$SNIPPET('koan_environment')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')
# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('kickstart_done')
# End final steps
%end
```

将镜像中的文件导入Cobbler，创建 distro

复制

```
cobbler import --help
cobbler import --path=/mnt/ --name="CentOS-7.4-x86_64" --arch=x86_64 --kickstart=/var/lib/cobbler/kickstarts/CentOS-7.4.cfg 
# --path 镜像路径
# --name 为安装源定义一个名字
# --arch 指定安装源是32位、64位、ia64, 目前支持的选项有: x86│x86_64│ia64
# 安装源的唯一标示就是根据name参数来定义，本例导入成功后，安装源的唯一标示就是：CentOS_7.4.1708_x86_64，如果重复，系统会提示导入失败。


# 导入完成后的文件存放在/var/www/cobbler/ks_mirror/下以name命名的目录下
ls /var/www/cobbler/ks_mirror/

# 查看元素，同步数据
cobbler list
cobbler sync
# 同步完成后会生成 /var/lib/tftpboot/pxelinux.cfg/default
```

修改安装系统的内核参数：在 CentOS7 系统有一个地方变了，就是网卡名变成 `eno*****` 这种形式，为了运维标准化，我们需要将它变成我们常用的 `eth0`

复制

```
cobbler profile edit --name=CentOS-7.4-x86_64 --kopts='net.ifnames=0 biosdevname=0'
cobbler profile report --name=CentOS-7.4-x86_64
# 可以看到Kickstart那里的配置cfg文件地址被改变了
```

信息查看

复制

```
cobbler distro report  --name=CentOS-7.4-x86_64
cobbler profile report --name=CentOS-7.4-x86_64
```

客户机引导时出现选择页面，`local` 和 `CentOS-6.9-x86_64` 和 `CentOS-7.4-x86_64`，干扰自动部署。此时需要编辑 `/var/lib/tftpboot/pxelinux.cfg/default`，修改 `TIMEOUT` 为 100，即等待时间为 10 秒，修改 `ONTIMEOUT` 为对应的 Label `CentOS-7.4-x86_64` ，即超过了等待时间后默认安装哪个系统。重启服务 `systemctl restart cobblerd`，需要注意的是，如果此时执行了 `cobbler sync` 就会重新生成 defatul 文件，之前的配置将被覆盖。

开机画面显示的修改，需要编辑 `/etc/cobbler/pxe/pxedefault.template`

复制

```
MENU TITLE Cobbler | http://cobbler.github.io/
# 改为自定义title，如下
MENU TITLE Cobbler | Cobbler Install
```

# 使用web安装CentOS6.8

在进行 web 端使用时，我们保持默认直接访问 web 页面即可，账号密码默认均为 cobbler，而且 CentOS7 中 cobbler 只支持 https 访问，浏览器访问 `https://192.168.127.10/cobbler_web/`

挂载CentOS6.8镜像

复制

```
mount -r /dev/cdrom /mnt/
ls /mnt/
```

导入镜像

![img](https://linuxgeeks.github.io/2018/01/23/205210-Cobbler%E6%97%A0%E4%BA%BA%E5%80%BC%E5%AE%88%E5%AE%89%E8%A3%85CentOS/01dedimport.png)

导入过程使用rsync进行导入，三个进程消失表示导入完毕

复制

```
[root@Cobbler ~]# pgrep -af rsync
504 /usr/bin/rsync --daemon --no-detach
1177 rsync -a /mnt/ /var/www/cobbler/ks_mirror/CentOS-6.8-x86_64 --progress
1178 rsync -a /mnt/ /var/www/cobbler/ks_mirror/CentOS-6.8-x86_64 --progress
1179 rsync -a /mnt/ /var/www/cobbler/ks_mirror/CentOS-6.8-x86_64 --progress
```

web 界面也可以看到相关的日志，running 代表正在运行，complete 代表已完成

![img](https://linuxgeeks.github.io/2018/01/23/205210-Cobbler%E6%97%A0%E4%BA%BA%E5%80%BC%E5%AE%88%E5%AE%89%E8%A3%85CentOS/02events.png)

创建ks文件

![img](https://linuxgeeks.github.io/2018/01/23/205210-Cobbler%E6%97%A0%E4%BA%BA%E5%80%BC%E5%AE%88%E5%AE%89%E8%A3%85CentOS/03createks.png)

编写文件，参照本站的 6.9 系统 ks 文件，编写好后点击 `Save` 即可保存

![img](https://linuxgeeks.github.io/2018/01/23/205210-Cobbler%E6%97%A0%E4%BA%BA%E5%80%BC%E5%AE%88%E5%AE%89%E8%A3%85CentOS/04editks.png)

为 Profile 选择对应的 ks 文件：依次点击 `Profiles` => `profile名字` => `Kickstart` 选择对应的 ks 文件

其他选项：如果是要安装 CentOS7 及以上的系统，不想使用原有的网卡名称而是想统一成 `eth*` 格式，需要修改内核参数

方式一：命令行修改

复制

```
cobbler profile edit --name=CentOS-7.5-x86_64 --kopts='net.ifnames=0 biosdevname=0'
```

方式二：web页面修改

依次点击 `Profiles` => `profile名字` => `Kernel Options` => 填写 `biosdevname=0 net.ifnames=0` => `Save`

查看导入完成的文件并新开机器安装系统进行验证

复制

```
cat /var/lib/tftpboot/pxelinux.cfg/default
```

# web端的用户认证方式

cobbler_web 支持多种认证方式，如 authn_configfile、authn_ldap 或 authn_pam 等，查看 `/etc/cobbler/modules.conf` 中 `[authentication]` 段的 `module` 参数及其注释说明，可以知道值默认为`authn_denyall`，即拒绝所有用户登录。如果需要自定义认证功能，请根据下面两种能认证用户登录 cobbler_web 的方式。

**使用authn_pam模块认证cobbler_web用户**

首先修改 `/etc/cobbler/modules.conf` 中 `[authentication]` 段的 `module` 参数的值为 `authn_pam`，接着添加系统用户，用户名和密码按需设定即可

复制

```
useradd cblradmin
echo 'cblrpass' | passwd --stdin cblradmin
```

而后将 `cblradmin` 用户添加至 `cobbler_web` 的 admin 组中。修改 `/etc/cobbler/users.conf` 文件，将 `cblradmin` 用户名添加为 admin 参数的值即可

复制

```
[admins]
admin = "cblradmin"
```

最后重启cobblerd服务，通过 `http://YOUR_COBBLERD_IP/cobbler_web` 访问即可

**使用authn_configfile模块认证cobbler_web用户**

首先修改 `/etc/cobbler/modules.conf` 中 `[authentication]` 段的 `module` 参数的值为 `authn_configfile`

接着创建其认证文件 `/etc/cobbler/users.digest`，并添加所需的用户即可。需要注意的是，添加第一个用户时，需要为 `htdigest` 命令使用 `-c` 选项，后续添加其他用户时不能再使用 `-c`；另外，cobbler_web 的 `realm` 只能为 `Cobbler`。如下所示。

复制

```
htdigest -c /etc/cobbler/users.digest Cobbler cblradmin
```

最后重启 cobblerd 服务，通过 `http://YOUR_COBBLERD_IP/cobbler_web` 访问即可

# 常见错误

**tftp 启动异常**

复制

```
[root@Cobbler ~]# netstat -tunlp  | grep 69
[root@Cobbler ~]# systemctl start tftp
A dependency job for tftp.service failed. See 'journalctl -xe' for details.
```

这是因为 `tftp socket` 的问题，启动 `tftp socke` 并将其加入开机启动列表，当有需要的时候 **systemd** 会自动启动 tftp 服务

复制

```
[root@Cobbler ~]# systemctl enable tftp.socket --now
[root@Cobbler ~]# systemctl status tftp.socket 
[root@Cobbler ~]# systemctl start tftp.service
[root@Cobbler ~]# netstat -tunlp  | grep 69   
udp        0      0 0.0.0.0:69              0.0.0.0:*                           1/systemd  
[root@Cobbler ~]# chmod +x /etc/rc.d/rc.local 
[root@Cobbler ~]# echo 'systemctl enable tftp.socket --now' >> /etc/rc.d/rc.local
```

参考链接：https://docs.fedoraproject.org/en-US/Fedora/23/html/Installation_Guide/pxe-tftpd.html

**No space left on device**

复制

```
umount: /run/initramfs/squashfs: not mounted
/sbin/dmsquash-live-root: line 273: printf: write error: No space left on device
```

出现这个错误的原因是内存不足2G，将内存调为2G或以上即可