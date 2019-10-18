# ansible 安装

------

# Linux下安装部署Ansible

介绍 Ansible是一种批量部署工具，现在运维人员用的最多的三种开源集中化管理工具有：puppet,saltstack,ansible，各有各的优缺点，其中saltstack和ansible都是用python开发的。ansible其实准确的说只提供了一个框架，它要基于很多其他的python模块才能工作的，所以在安装ansible的时候你要再装很多其他的依赖包的。

好处之一是使用者可以开发自己的模块，放在里面使用。第二个好处是无需在客户端安装agent，更新时，只需在操作机上进行一次更新即可。第三个好处是批量任务执行可以写成脚本，而且不用分发到远程就可以执行。

正文 注意：强烈建议升级python版本到2.6以上，不然运行会出错或者有些功能会没有，在编译安装其他包的时候也会因为兼容问题报错。

## (1)、python2.7安装

```shell
    https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz
    tar xvzf Python-2.7.8.tgz
    cd Python-2.7.8
    ./configure --prefix=/usr/local
    make
    make install
```

## 将python头文件拷贝到标准目录，以避免编译ansible时，找不到所需的头文件

```shell
     cd /usr/local/include/python2.7
     cp -a ./* /usr/local/include/
```

## 备份旧版本的python，并符号链接新版本的python

```shell
     cd /usr/bin
     mv python python.old
     ln -s /usr/local/bin/python2.7 /usr/local/bin/python
     rm -f /usr/bin/python && cp /usr/local/bin/python2.7 /usr/bin/python
```

## 修改yum脚本，使其指向旧版本的python，已避免其无法运行

```bash
    vim /usr/bin/yum
    #!/usr/bin/python  -->  #!/usr/bin/python2.4
```

## (2)、setuptools模块安装

```shell
    https://pypi.python.org/packages/source/s/setuptools/setuptools-7.0.tar.gz
    # tar xvzf setuptools-7.0.tar.gz
    # cd setuptools-7.0
    # python setup.py install
```

安装好setuptools后就可以利用easy_install这个工具安装下面的python模块了，但我的电脑是虚拟机，配置太低了，所以基本无法安装，所以只好一个一个下载下来再安装了。

## (3)、pycrypto模块安装

```shell
    https://pypi.python.org/packages/source/p/pycrypto/pycrypto-2.6.1.tar.gz
    # tar xvzf pycrypto-2.6.1.tar.gz
    # cd pycrypto-2.6.1
    # python setup.py install
```

## (4)、PyYAML模块安装

```
http://pyyaml.org/download/libyaml/yaml-0.1.5.tar.gz
# tar xvzf yaml-0.1.5.tar.gz
# cd yaml-0.1.5
# ./configure --prefix=/usr/local
# make --jobs=`grep processor/proc/cpuinfo | wc -l`
# make install


https://pypi.python.org/packages/source/P/PyYAML/PyYAML-3.11.tar.gz
# tar xvzf PyYAML-3.11.tar.gz
# cd PyYAML-3.11
# python setup.py install
```

## (5)、Jinja2模块安装

```
https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.9.3.tar.gz
# tar xvzf MarkupSafe-0.9.3.tar.gz
# cd MarkupSafe-0.9.3
# python setup.py install


https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.3.tar.gz
# tar xvzf Jinja2-2.7.3.tar.gz
# cd Jinja2-2.7.3
# python setup.py install
```

## (6)、paramiko模块安装

```
https://pypi.python.org/packages/source/e/ecdsa/ecdsa-0.11.tar.gz
# tar xvzf ecdsa-0.11.tar.gz
# cd ecdsa-0.11
# python setup.py install


https://pypi.python.org/packages/source/p/paramiko/paramiko-1.15.1.tar.gz
# tar xvzf paramiko-1.15.1.tar.gz
# cd paramiko-1.15.1
# python setup.py install
```

## (7)、simplejson模块安装

```
https://pypi.python.org/packages/source/s/simplejson/simplejson-3.6.5.tar.gz
# tar xvzf simplejson-3.6.5.tar.gz
# cd simplejson-3.6.5
# python setup.py install
```

## (8)、ansible安装

```
https://github.com/ansible/ansible/archive/v1.7.2.tar.gz
# tar xvzf ansible-1.7.2.tar.gz
# cd ansible-1.7.2
# python setup.py install
```

## (9)、SSH免密钥登录设置

```
## 生成公钥/私钥
# ssh-keygen -t rsa -P ''
## 写入信任文件（将/root/.ssh/id_rsa_storm1.pub分发到其他服务器，并在所有服务器上执行如下指令）：
# cat /root/.ssh/id_rsa_storm1.pub >> /root/.ssh/authorized_keys
# chmod 600 /root/.ssh/authorized_keys
```

## (10)、拷贝，生成ansible配置文件

```
a 配置文件/etc/ansible/ansible.cfg
# mkdir -p /etc/ansible
#cp ansible-1.7.2/examples/ansible.cfg /etc/ansible/
b 配置文件/etc/ansible/hosts
# vim /etc/ansible/hosts
[test]
192.168.110.20
192.168.110.30
```

## 测试

```
# ansible test -m command -a 'uptime'
## 用来测试远程主机的运行状态
# ansible test -m ping
```

参看所有的参数 ansible-doc -l

Ansible和Docker的作用和用法 http://www.linuxidc.com/Linux/2014-11/109783.htm

Ansible批量搭建LAMP环境 http://www.linuxidc.com/Linux/2014-10/108264.htm

Ansible ：一个配置管理和IT自动化工具 http://www.linuxidc.com/Linux/2014-11/109365.htm

Ansible 的详细介绍：请点这里 Ansible 的下载地址：请点这里

本文永久更新链接地址：http://www.linuxidc.com/Linux/2015-02/112774.htm