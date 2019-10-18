# Ansible 在 Centos7 中实现回收站

## 一、Ansible概述

- Ansible是一个配置管理系统 configuration management system
- python 语言是运维人员必须会的语言
- ansible 是一个基于python 开发的自动化运维工具
- 其功能实现基于ssh远程连接服务
- ansible 可以实现批量系统配置，批量软件部署，批量文件拷贝，批量运行命令等功能
- 除了ansible之外，还有saltstack 等批量管理软件

### 1、 Ansible能做什么

- ansible可以帮助我们完成一些批量任务，或者完成一些需要经常重复的工作。
- 比如：同时在100台服务器上安装nginx服务，并在安装后启动服务。
- 比如：将某个文件一次性拷贝到100台服务器上。
- 比如：每当有新服务器加入工作环境时，你都要为新服务器部署某个服务，也就是说你需要经常重复的完成相同的工作。
- 这些场景中我们都可以使用到ansible。

### 2、 Ansible软件特点

- ansible不需要单独安装客户端，SSH相当于ansible客户端。
- ansible不需要启动任何服务，仅需安装对应工具即可。
- ansible依赖大量的python模块来实现批量管理。
- ansible配置文件/etc/ansible/ansible.cfg

## 二、 环境准备

```shell
实验环境：
ansible(IP:192.168.11.128 centos7)
client(IP:192.168.11.136 centos7)
Python版本: Python 2.7 及以上(centos7默认就是2.7)
需要关闭firewalld以及selinux
```

### 1、安装 EPEL仓库

Ansible 仓库默认不在 yum base 仓库中，因此我们需要启用 epel 仓库

```shell
yum -y install epel-release
```

### 2、使用 yum 安装 Ansible

#### 1、安装 

```shell
[root@ansible~]# yum install ansible
Loaded plugins: fastestmirror, langpacks
Repository base is listed more than once in the configuration
Repository updates is listed more than once in the configuration
.......
.......
Installed:
  ansible.noarch 0:2.2.1.0-1.el7                                                
Dependency Installed:
  PyYAML.x86_64 0:3.10-11.el7             libtomcrypt.x86_64 0:1.17-23.el7     
  libtommath.x86_64 0:0.42.0-4.el7        libyaml.x86_64 0:0.1.4-11.el7_0      
  python-babel.noarch 0:0.9.6-8.el7       python-httplib2.noarch 0:0.7.7-3.el7 
  python-jinja2.noarch 0:2.7.2-2.el7      python-keyczar.noarch 0:0.71c-2.el7  
  python-markupsafe.x86_64 0:0.11-10.el7  python-six.noarch 0:1.9.0-2.el7      
  python2-crypto.x86_64 0:2.6.1-13.el7    python2-ecdsa.noarch 0:0.13-4.el7    
  python2-paramiko.noarch 0:1.16.1-2.el7  python2-pyasn1.noarch 0:0.1.9-7.el7  
  sshpass.x86_64 0:1.06-1.el7            
Complete!
[root@ansible]#
```

#### 2、检查安装

```shell
[root@ansible~]# ansible --version
ansible 2.2.1.0
  config file = /etc/ansible/ansible.cfg
  configured module search path = Default w/o overrides
12345
```

#### 3、配置 Ansible

软件安装完成，进行修改ansible下的 hosts文件，**注意文件的路径**

```shell
[root@ansible~]# vim /etc/ansible/hosts
[all]
192.168.11.136
```

 []  中的名字代表组名

主机(hosts)部分可以使用域名、主机名、IP地址表示；一般此类配置中多使用IP地址；

组名下的主机地址就是ansible可以管理的地址

### 4、配置免密认证（也可以不配置）

#### 1、ssh-keygen 生成秘钥 

```shell
[root@ansible~]# ssh-keygen            # 一路回车就可以
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
5b:ae:1e:90:b9:85:90:f2:0a:c1:ef:e7:88:23:f5:a6 root@localhost.localdomain
The key's randomart image is:
+--[ RSA 2048]----+
|                 |
|.    .           |
|... o            |
| ..o . +         |
|.  .. = S .      |
| .o.   + +       |
| ..o .. o .      |
|... *    o       |
|..E+ . .o        |
+-----------------+
```

#### 2、使用 **ssh-copy-id**命令复制 Ansible 公钥到节点中

```shell
[root@amsible~]# ssh-copy-id root@192.168.11.136
The authenticity of host '192.168.150.136 (192.168.150.136)' can't be established.
ECDSA key fingerprint is f6:c2:20:dc:ec:28:71:4a:fe:4d:d9:5d:39:39:65:8f.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
myron@192.168.11.136's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'myron@192.168.150.136'"
and check to make sure that only the key(s) you wanted were added.
```

#### 3、测试免密操作 

```shell
[root@ansible ~]# ansible all -m ping 
192.168.150.136 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

### 5、基本功能

Ansible提供两种方式去完成任务,ad-hoc 命令和写 Ansible playbook

#### 1、ad-hoc 命令

ad-hoc 命令—可以解决一些简单的任务 

> **ad-hoc这其实是一个概念性的名字,是相对于写 Ansible playbook 来说的.类似于在命令行敲入shell命令和 写shell scripts两者之间的关系**

示例：查看托管节点的主机名

```shell
[root@ansible ~]# ansible 192.168.11.136 -m command -a "hostname" 
192.168.150.138 | SUCCESS | rc=0 >>
localhost.localdomain
```

说明： 
192.168.11.136 是管理主机配置的托管节点 /etc/ansible/hosts 中配置 
-m 模块名 用户执行对应的功能 (默认：command) 所以执行**ansible 192.168.150.138 -a “hostname” ** 效果一样

> **Ansible是基于模块工作的，本身没有批量部署的能力。真正具有批量部署的是ansible所运行的模块，ansible只是提供一种框架。**

#### 2、Playbooks 剧本

写 Ansible playbook—后者解决较复杂的任务. 

> **Playbooks 是 Ansible的配置,部署,编排语言.他们可以被描述为一个需要希望远程主机执行命令的方案,或者一组IT程序运行的命令集合.**

#### 3、ansible 中查看模块及帮助

```shell
[root@ansible ~]# ansible-doc -l
列出所有模块信息

[root@ansible ~]# ansible-doc -s cron
参看指定模块的帮助
```

## 三、编写 ansible-playbook 实现回收站功能

### 1、目录规划

```shell
[root@ansible ~]# mkdir -p /etc/ansible/roles/create_trash/{defalult,tasks,templates}

[root@ansible ~]# tree /etc/ansible/roles/create_trash
/etc/ansible/roles/create_trash/
├── default
└── tasks
└── templates
```

### 2、需提前准备好的文件

#### 1、 准备 trash 的环境初始化脚本 add_profile.sh

将对应的脚本生成到 /etc/profile.d

```shell
#!/usr/bin/env bash
cat >/etc/profile.d/trash.sh<<-EOF
mkdir -p ~/.trash
alias rm=trash
alias r=trash
alias rl='ls ~/.trash'
alias ur=undelfile
undelfile()
{
  mv -i ~/.trash/\$@ ./
}
trash()
{
  mv \$@ ~/.trash/
}
cleartrash()
{
    read -p "clear sure?[n]" confirm
    [ \$confirm == 'y' ] || [ \$confirm == 'Y' ]  && /bin/rm -rf ~/.trash/*
}
EOF
```

#### 2、准备 trash 的计划任务清理脚本 clear_trash.sh

将对应的脚本复制到  /usr/local/script 下

```shell
#!/usr/bin/env bash
find /root/.trash -ctime 7 -type f -name "*" -exec /bin/rm {} \;
for i in $(ls /home)
do
  if [ -d $i ]; then
    find /home/$i/.trash -ctime 7 -type f -name "*" -exec /bin/rm {} \;
  fi
done
```

#### 3、准备 pip 源的配置文件 pip.conf.j2

```shell
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host=mirrors.aliyun.com
```

#### 4、准备完的目录结构为

```shell
[root@ansible ~]# tree /etc/ansible/roles/create_trash
/etc/ansible/roles/create_trash/
├── default
└── tasks
└── templates
```

