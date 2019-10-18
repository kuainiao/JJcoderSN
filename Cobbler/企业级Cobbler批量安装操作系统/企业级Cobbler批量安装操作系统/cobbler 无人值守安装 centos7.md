# cobbler 无人值守安装 centos7

## 一、需求

公司进了一批服务器，需要重新安装操作系统，所以搞一下自动安装系统，并记录一下。

为啥不用Kickstart？因为安装麻烦！Cobbler可以说是Kickstart的升级版，它集中和简化了通过网络安装操作系统所需要的dhcp,tftp,dns等配置，Cobbler可以通过命令行界面操作，还提供web界面，并且还支持其它配置管理系统，比如puppet，暂时不支持saltstack。

## 二、环境准备

操作系统：centos7.5

Cobbler: 2.8.4

Cobbler IP: 10.10.1.13

## 三、开始安装

1. 关闭防火墙和selinux，我这是在内部机器别人访问不到，如果机器有可能暴露到公网最好不要关闭防火墙

   ```
   # sed -i 's/SELINUX=enforcing/SELINUX=disabled' /etc/selinux/config
   # setenforce 0
   # systemctl disable firewalld
   # systemctl stop firewalld
   ```

2. 安装cobbler相关的软件，并添加开机自启动

   ```
   # yum -y install cobbler cobbler-web dhcp tftp-server pykickstart httpd
   # systemctl enable httpd cobblerd
   # systemctl start httpd cobblerd
   ```

3. 检查服务并修改相关的配置

```
# cobbler check
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

3.1. 将上面检查出来的问题先解决

先备份在根据提示修改配置文件

```
# cp /etc/cobbler/settings{,.bak}
```

根据提示1，2将127.0.0.1修改为cobbler服务器的ip

```
# sed -i 's/server: 127.0.0.1/server: 10.10.1.13/g' /etc/cobbler/settings
# sed -i 's/next_server: 127.0.0.1/next_server: 10.0.0.7/' /etc/cobbler/settings
```

根据提示3修改tftp配置，把yes改为no ,重启服务并添加自启动

```
# cat /etc/xinetd.d/tftp  | grep disable
        disable                 = no
# systemctl restart xinetd.service
# systemctl enable xinetd.service
```

根据提示4，下载loaders

```
# cobbler get-loaders
task started: 2019-07-24_021430_get_loaders
task started (id=Download Bootloader Content, time=Wed Jul 24 02:14:30 2019)
downloading https://cobbler.github.io/loaders/README to /var/lib/cobbler/loaders/README
downloading https://cobbler.github.io/loaders/COPYING.elilo to /var/lib/cobbler/loaders/COPYING.elilo
downloading https://cobbler.github.io/loaders/COPYING.yaboot to /var/lib/cobbler/loaders/COPYING.yaboot
downloading https://cobbler.github.io/loaders/COPYING.syslinux to /var/lib/cobbler/loaders/COPYING.syslinux
downloading https://cobbler.github.io/loaders/elilo-3.8-ia64.efi to /var/lib/cobbler/loaders/elilo-ia64.efi

downloading https://cobbler.github.io/loaders/yaboot-1.3.17 to /var/lib/cobbler/loaders/yaboot
downloading https://cobbler.github.io/loaders/pxelinux.0-3.86 to /var/lib/cobbler/loaders/pxelinux.0
downloading https://cobbler.github.io/loaders/menu.c32-3.86 to /var/lib/cobbler/loaders/menu.c32
downloading https://cobbler.github.io/loaders/grub-0.97-x86.efi to /var/lib/cobbler/loaders/grub-x86.efi
downloading https://cobbler.github.io/loaders/grub-0.97-x86_64.efi to /var/lib/cobbler/loaders/grub-x86_64.efi
*** TASK COMPLETE ***
```

根据提示5，启动rsyncd并添加自启动

```
# systemctl enable rsyncd
# systemctl start rsyncd
```

根据提示6，安装 debmirro，如果用不到可以忽略

```
# yum -y install debmirror
# sed -i  's|@dists=.*|#@dists=|'  /etc/debmirror.conf
# sed -i  's|@arches=.*|#@arches=|'  /etc/debmirror.conf
```

根据提示7，设置新装系统的默认root密码123456。random-phrase-here为干扰码，可以自行设定。

```
# openssl passwd -1 -salt 'cobble' '123456'
$1$cobble$K03Q.A2lkupK0pGFt6f46/
```

提示8，我没有用到是可以直接忽略的，但是见到提示就不爽，还是解决一下吧

```
#  yum -y install fence-agent
```

使用cobbler管理dhcp，1为开启，默认为0

```
# sed -i 's/manage_dhcp: 0/manage_dhcp: 1/' /etc/cobbler/settings
```

防止循环装系统，适用于服务器第一启动项是PXE启动。
该选项作用:

- 防止机器循环安装配置始终从网络引导
- 激活此选项，机器回传Cobbler安装完成
- Cobbler将系统对象的netboot标志更改为false，强制要求机器从本地磁盘引导。

```
# sed -i 's/pxe_just_once: 0/pxe_just_once: 1/' /etc/cobbler/settings
```

使用生成的字符串，替换default_password_crypted默认的密码

```
# vim /etc/cobbler/settings
default_password_crypted: "$1$cobble$K03Q.A2lkupK0pGFt6f46/"
```

重启cobbler然后在检查一下

```
# cobbler check
No configuration problems found.  All systems go.
```

3.2 dhcp模板配置，dhcp只需要修改以下内容即可，同步时cobble会自动修改dhcp配置

```
# cp /etc/cobbler/dhcp.template{,.bak}
# vim /etc/cobbler/dhcp.template
subnet 10.10.0.0 netmask 255.255.252.0 {
     option routers             10.10.3.254;  # 网关
     option domain-name-servers 10.10.1.250;  # dns
     option subnet-mask         255.255.252.0; # 子网
     range dynamic-bootp        10.10.0.100 10.10.0.254; # 可分配的ip范围
     default-lease-time         21600;
     max-lease-time             43200;
```

3.3 同步cobbler配置，会修改tftp，dhcp等服务的配置并重启，可以仔细看一下下面的输出

```
# cobbler sync
task started: 2019-07-24_043113_sync
task started (id=Sync, time=Wed Jul 24 04:31:13 2019)
running pre-sync triggers
cleaning trees
removing: /var/lib/tftpboot/pxelinux.cfg/default
removing: /var/lib/tftpboot/grub/images
removing: /var/lib/tftpboot/grub/efidefault
removing: /var/lib/tftpboot/s390x/profile_list
copying bootloaders
trying hardlink /var/lib/cobbler/loaders/pxelinux.0 -> /var/lib/tftpboot/pxelinux.0
copying: /var/lib/cobbler/loaders/pxelinux.0 -> /var/lib/tftpboot/pxelinux.0
trying hardlink /var/lib/cobbler/loaders/menu.c32 -> /var/lib/tftpboot/menu.c32
copying: /var/lib/cobbler/loaders/menu.c32 -> /var/lib/tftpboot/menu.c32
trying hardlink /var/lib/cobbler/loaders/yaboot -> /var/lib/tftpboot/yaboot
trying hardlink /var/lib/cobbler/loaders/grub-x86.efi -> /var/lib/tftpboot/grub/grub-x86.efi
trying hardlink /var/lib/cobbler/loaders/grub-x86_64.efi -> /var/lib/tftpboot/grub/grub-x86_64.efi
copying distros to tftpboot
copying images
generating PXE configuration files
generating PXE menu structure
rendering DHCP files
generating /etc/dhcp/dhcpd.conf
rendering TFTPD files
generating /etc/xinetd.d/tftp
cleaning link caches
running post-sync triggers
running python triggers from /var/lib/cobbler/triggers/sync/post/*
running python trigger cobbler.modules.sync_post_restart_services
running: dhcpd -t -q
received on stdout:
received on stderr:
running: service dhcpd restart
received on stdout:
received on stderr: Redirecting to /bin/systemctl restart dhcpd.service

running shell triggers from /var/lib/cobbler/triggers/sync/post/*
running python triggers from /var/lib/cobbler/triggers/change/*
running python trigger cobbler.modules.manage_genders
running python trigger cobbler.modules.scm_track
running shell triggers from /var/lib/cobbler/triggers/change/*
*** TASK COMPLETE ***
```

1. 导入镜像

先自行下载一个centos7镜像，然后挂载到本地，之后导入到cobbler

```
# mkdir /mnt/centos7.5
# mount -t iso9660 -o loop CentOS-7-x86_64-Minimal-1804.iso  /mnt/centos7.5
# cobbler import --path=/mnt/centos7.5 --name=CentOS-7.5-1804-x86_64 --arch=x86_64
task started: 2019-07-24_050656_import
task started (id=Media import, time=Wed Jul 24 05:06:56 2019)
Found a candidate signature: breed=redhat, version=rhel6
Found a candidate signature: breed=redhat, version=rhel7
Found a matching signature: breed=redhat, version=rhel7
Adding distros from path /var/www/cobbler/ks_mirror/CentOS-7.5-1804-x86_64:
creating new distro: CentOS-7.5-1804-x86_64
trying symlink: /var/www/cobbler/ks_mirror/CentOS-7.5-1804-x86_64 -> /var/www/cobbler/links/CentOS-7.5-1804-x86_64
creating new profile: CentOS-7.5-1804-x86_64
associating repos
checking for rsync repo(s)
checking for rhn repo(s)
checking for yum repo(s)
starting descent into /var/www/cobbler/ks_mirror/CentOS-7.5-1804-x86_64 for CentOS-7.5-1804-x86_64
processing repo at : /var/www/cobbler/ks_mirror/CentOS-7.5-1804-x86_64
need to process repo/comps: /var/www/cobbler/ks_mirror/CentOS-7.5-1804-x86_64
looking for /var/www/cobbler/ks_mirror/CentOS-7.5-1804-x86_64/repodata/*comps*.xml
Keeping repodata as-is :/var/www/cobbler/ks_mirror/CentOS-7.5-1804-x86_64/repodata
*** TASK COMPLETE ***
```

- –path 镜像路径
- –name 指定安装源的名字
- –arch 指定导入镜像的体系结构

查看镜像列表

```
# cobbler distro list
   CentOS-7.5-1804-x86_64
```

镜像保存在http的目录内

```
# ls /var/www/cobbler/ks_mirror/
```

使用cobbler查看，此处的一些变量我们在写 kickstarts 配置的时候可能会用到，例如tree

```
# cobbler distro  report
Name                           : CentOS-7.5-1804-x86_64
Architecture                   : x86_64
TFTP Boot Files                : {}
Breed                          : redhat
Comment                        :
Fetchable Files                : {}
Initrd                         : /var/www/cobbler/ks_mirror/CentOS-7.5-1804-x86_64/images/pxeboot/initrd.img
Kernel                         : /var/www/cobbler/ks_mirror/CentOS-7.5-1804-x86_64/images/pxeboot/vmlinuz
Kernel Options                 : {}
Kernel Options (Post Install)  : {}
Kickstart Metadata             : {'tree': 'http://@@http_server@@/cblr/links/CentOS-7.5-1804-x86_64'}
Management Classes             : []
OS Version                     : rhel7
Owners                         : ['admin']
Red Hat Management Key         : <<inherit>>
Red Hat Management Server      : <<inherit>>
Template Files                 : {}
```

1. kickstarts文件配置

> 在传统安装操作系统时，需要大量的交互操作，为了减少交互的过程，kickstart就产生了，我们需要提前定义好这个kickstart的配置文件，并让安装程序知道kickstart配置文件的位置，在安装过程中读取kickstart配置即可实现无人值守的自动化安装操作系统。

默认的kickstarts文件放在/var/lib/cobbler/kickstarts/目录下，默认有一些示例

```
# ls /var/lib/cobbler/kickstarts/
default.ks    esxi5-ks.cfg      legacy.ks     sample_autoyast.xml  sample_esx4.ks   sample_esxi5.ks  sample.ks        sample.seed
esxi4-ks.cfg  install_profiles  pxerescue.ks  sample_end.ks        sample_esxi4.ks  sample_esxi6.ks  sample_old.seed
```

一般centos系统安装完成后会在/root/anaconda-ks.cfg
产生一个ks配置文件，记录安装过程，我们可以根据这个文件修改一下，修改好后放到/var/lib/cobbler/kickstarts目录

```
default.ks    esxi5-ks.cfg      legacy.ks     sample_autoyast.xml  sample_esx4.ks   sample_esxi5.ks  sample.ks        sample.seed
esxi4-ks.cfg  install_profiles  pxerescue.ks  sample_end.ks        sample_esxi4.ks  sample_esxi6.ks  sample_old.seed
一般centos系统安装完成后会在/root/anaconda-ks.cfg
产生一个ks配置文件，记录安装过程，我们可以根据这个文件修改一下，修改好后放到/var/lib/cobbler/kickstarts目录
# cat /var/lib/cobbler/kickstarts/centos7.5.ks
# Cobbler kickstart config
# centos 7.5
install
url --url=$tree  # 这里是distro report里的变量
text
lang zh_CN.UTF-8
keyboard --vckeymap=cn --xlayouts='cn'
zerombr
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=xvda   # 这里的硬盘需要根据实际情况更改，我这里用的xenserver创建的虚拟机，硬盘名为xvda
timezone Asia/Shanghai --isUtc
authconfig --enableshadow --passalgo=sha512
rootpw  --iscrypted $default_password_crypted
clearpart --all --initlabel

part biosboot --fstype="biosboot" --ondisk=xvda --size=1
part /boot --fstype="xfs" --ondisk=xvda --size=476
part pv.585 --fstype="lvmpv" --ondisk=xvda --size=51200 --grow
volgroup centos --pesize=4096 pv.585
logvol swap  --fstype="swap" --size=2048 --name=swap --vgname=centos
logvol /  --fstype="xfs" --size=20000 --name=root --vgname=centos --grow
firstboot --disable
selinux --disabled
firewall --disabled
logging --level=info

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end

%packages
@^minimal
@core
chrony
kexec-tools
%end

%post
systemctl disable postfix.service
%end
```

查看一下profile的配置

```
# cobbler profile  report  --name=Centos-7.5-1804-x86_64
Name                           : Centos-7.5-1804-x86_64
TFTP Boot Files                : {}
Comment                        :
DHCP Tag                       : default
Distribution                   : CentOS-7.5-1804-x86_64
Enable gPXE?                   : 0
Enable PXE Menu?               : 1
Fetchable Files                : {}
Kernel Options                 : {}
Kernel Options (Post Install)  : {}
Kickstart                      : /var/lib/cobbler/kickstarts/sample_end.ks  # 这里还是默认的ks配置文件
Kickstart Metadata             : {}
Management Classes             : []
Management Parameters          : <<inherit>>
Name Servers                   : []
Name Servers Search Path       : []
Owners                         : ['admin']
Parent Profile                 :
Internal proxy                 :
Red Hat Management Key         : <<inherit>>
Red Hat Management Server      : <<inherit>>
Repos                          : []
Server Override                : <<inherit>>
Template Files                 : {}
Virt Auto Boot                 : 1
Virt Bridge                    : xenbr0
Virt CPUs                      : 1
Virt Disk Driver Type          : raw
Virt File Size(GB)             : 5
Virt Path                      :
Virt RAM (MB)                  : 512
Virt Type                      : kvm
```

修改指定的kickstart文件

```
# cobbler profile edit --name=Centos-7.5-1804-x86_64  --kickstart=/var/lib/cobbler/kickstarts/centos7.5.ks
```

在查看一下,kickstart已经关联到了我们自己的ks文件

```
# cobbler profile  report  --name=Centos-7.5-1804-x86_64 | grep -i kickstart
Kickstart                      : /var/lib/cobbler/kickstarts/centos7.5.ks
Kickstart Metadata             : {}
```

启动菜单，local是默认选项，之后才是我们自己定义的启动项，在下面的模板中可以看出ONTIMEOUT 超时后会以$pxe_timeout_profile这个变量的值来启动

```
# cat /etc/cobbler/pxe/pxedefault.template
DEFAULT menu
PROMPT 0
MENU TITLE Cobbler | http://cobbler.github.io/
TIMEOUT 200
TOTALTIMEOUT 6000
ONTIMEOUT $pxe_timeout_profile



LABEL local
        MENU LABEL (local)
        MENU DEFAULT
        LOCALBOOT -1

$pxe_menu_items


MENU end
```

查看源代码，pxe_timeout_profile是从system中取的，如果没有设置话默认会设置为local

```
def make_pxe_menu(self):
    """
    Generates both pxe and grub boot menus.
    """
    # only do this if there is NOT a system named default.
    default = self.systems.find(name="default")

    if default is None:
        timeout_action = "local"
    else:
        timeout_action = default.profile

    menu_items = self.get_menu_items()

    # Write the PXE menu:
    metadata = {"pxe_menu_items": menu_items['pxe'], "pxe_timeout_profile": timeout_action}
    outfile = os.path.join(self.bootloc, "pxelinux.cfg", "default")
    template_src = open(os.path.join(self.settings.boot_loader_conf_template_dir, "pxedefault.template"))
    template_data = template_src.read()
    self.templar.render(template_data, metadata, outfile, None)
    template_src.close()

    # Write the grub menu:
    outfile = os.path.join(self.bootloc, "grub", "menu_items.cfg")
    fd = open(outfile, "w+")
    fd.write(menu_items['grub'])
    fd.close()
```

这里在捊一下distro，profile，system三者间的关系

- distro 可以理解为“操作系统”，我们之前导入iso时会生成distro
- profile 我理解的是这里定义的是操作系统安装时的一些参数？（理解可能有误，欢迎指正）
- system 这里就是定义启动时的菜单选项了

根据上面的代码我们需要加一个system的配置

```
# cobbler system add  --name=default --profile=CentOS-7.5-1804-x86_64
# cobbler  system list
   default
# cobbler sync   # 同步，然后在查看一下default的配置
# cat /var/lib/tftpboot/pxelinux.cfg/default
DEFAULT menu
PROMPT 0
MENU TITLE Cobbler | http://cobbler.github.io/
TIMEOUT 200
TOTALTIMEOUT 6000
ONTIMEOUT CentOS-7.5-1804-x86_64



LABEL local
        MENU LABEL (local)
        MENU DEFAULT
        LOCALBOOT -1

LABEL Centos-7.5-1804-x86_64
        kernel /images/CentOS-7.5-1804-x86_64/vmlinuz
        MENU LABEL Centos-7.5-1804-x86_64
        append initrd=/images/CentOS-7.5-1804-x86_64/initrd.img ksdevice=bootif lang=  kssendmac text  ks=http://10.10.1.13/cblr/svc/op/ks/profile/Centos-7.5-1804-x86_64
        ipappend 2




MENU end
```

这里的顺序更改一定要注意，要么就是自动化安装操作系统时划分vlan防止有原来的服务器重启将服务器重新安装，或者安装完后将cobbler服务停止。

1. 自动安装系统

以上cobbler算是都配置完成了，现在可以愉快的安装操作系统了，新建一台虚拟机，这步略过了没啥可介绍的，虚拟机指定用pxe 网络启动即可，后边都是图片了，我就不上传了，只要ks文件没问题，几乎不会出问题。如果有问题，自行拆招吧。。

可以用以下命令查看安装状态

```
# cobbler status
ip             |target              |start            |state
10.10.0.103    |profile:Centos-7.5-1804-x86_64|Thu Jul 25 03:59:58 2019|installing (59m 35s)
```

1. 访问一下cobbler_web界面

访问地址：https://10.10.1.13/cobbler_web，默认账号及密码：cobbler,cobbler

访问的时候报500的错误，

查看httpd的日志，是python导入一个模块的时候报错了，没办法google一下吧

```
# cat /var/log/httpd/ssl_error_log
[Wed Jul 24 04:40:38.165085 2019] [ssl:warn] [pid 3734] AH01909: RSA certificate configured for 10.10.1.13:443 does NOT include an ID which matches the server name
[Wed Jul 24 04:44:34.035706 2019] [:error] [pid 3735] [remote 10.10.1.12:0] mod_wsgi (pid=3735): Exception occurred processing WSGI script '/usr/share/cobbler/web/cobbler.wsgi'.
[Wed Jul 24 04:44:34.035806 2019] [:error] [pid 3735] [remote 10.10.1.12:0] Traceback (most recent call last):
[Wed Jul 24 04:44:34.035842 2019] [:error] [pid 3735] [remote 10.10.1.12:0]   File "/usr/share/cobbler/web/cobbler.wsgi", line 26, in application
[Wed Jul 24 04:44:34.035914 2019] [:error] [pid 3735] [remote 10.10.1.12:0]     _application = get_wsgi_application()
[Wed Jul 24 04:44:34.035937 2019] [:error] [pid 3735] [remote 10.10.1.12:0]   File "/usr/lib/python2.7/site-packages/django/core/wsgi.py", line 13, in get_wsgi_application
[Wed Jul 24 04:44:34.035977 2019] [:error] [pid 3735] [remote 10.10.1.12:0]     django.setup(set_prefix=False)
[Wed Jul 24 04:44:34.035997 2019] [:error] [pid 3735] [remote 10.10.1.12:0]   File "/usr/lib/python2.7/site-packages/django/__init__.py", line 22, in setup
[Wed Jul 24 04:44:34.036077 2019] [:error] [pid 3735] [remote 10.10.1.12:0]     configure_logging(settings.LOGGING_CONFIG, settings.LOGGING)
[Wed Jul 24 04:44:34.036114 2019] [:error] [pid 3735] [remote 10.10.1.12:0]   File "/usr/lib/python2.7/site-packages/django/conf/__init__.py", line 56, in __getattr__
[Wed Jul 24 04:44:34.036217 2019] [:error] [pid 3735] [remote 10.10.1.12:0]     self._setup(name)
[Wed Jul 24 04:44:34.036235 2019] [:error] [pid 3735] [remote 10.10.1.12:0]   File "/usr/lib/python2.7/site-packages/django/conf/__init__.py", line 41, in _setup
[Wed Jul 24 04:44:34.036262 2019] [:error] [pid 3735] [remote 10.10.1.12:0]     self._wrapped = Settings(settings_module)
[Wed Jul 24 04:44:34.036275 2019] [:error] [pid 3735] [remote 10.10.1.12:0]   File "/usr/lib/python2.7/site-packages/django/conf/__init__.py", line 110, in __init__
[Wed Jul 24 04:44:34.036286 2019] [:error] [pid 3735] [remote 10.10.1.12:0]     mod = importlib.import_module(self.SETTINGS_MODULE)
[Wed Jul 24 04:44:34.036295 2019] [:error] [pid 3735] [remote 10.10.1.12:0]   File "/usr/lib64/python2.7/importlib/__init__.py", line 37, in import_module
[Wed Jul 24 04:44:34.036356 2019] [:error] [pid 3735] [remote 10.10.1.12:0]     __import__(name)
[Wed Jul 24 04:44:34.036371 2019] [:error] [pid 3735] [remote 10.10.1.12:0]   File "/usr/share/cobbler/web/settings.py", line 89, in <module>
[Wed Jul 24 04:44:34.036425 2019] [:error] [pid 3735] [remote 10.10.1.12:0]     from django.conf.global_settings import TEMPLATE_CONTEXT_PROCESSORS
[Wed Jul 24 04:44:34.036450 2019] [:error] [pid 3735] [remote 10.10.1.12:0] ImportError: cannot import name TEMPLATE_CONTEXT_PROCESSORS
```

[算是一个bug，原文地址](https://github.com/cobbler/cobbler/issues/1717)，解决方案也很简单,将python2-django-1.11.21-2.el7删除，然后安装python2-django16在访问就正常了

```
# rpm -e --nodeps python2-django-1.11.21-2.el7
# yum -y install python2-django16
```

安装完页面是英文，反正都是哪里不会点哪里，就不做截图了