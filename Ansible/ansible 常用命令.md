# ansible 常用命令

------

# ansible hosts文件命令

## 命令说明：

**ansible_ssh_host** 将要连接的远程主机名.与你想要设定的主机的别名不同的话,可通过此变量设置.

**ansible_ssh_port ssh**端口号.如果不是默认的端口号,通过此变量设置.

**ansible_ssh_user** 默认的 ssh 用户名

**ansible_ssh_pass ssh** 密码(这种方式并不安全,我们强烈建议使用 --ask-pass 或 SSH 密钥)

**ansible_sudo_pass sudo** 密码(这种方式并不安全,我们强烈建议使用 --ask-sudo-pass)

**ansible_sudo_exe** (new in version 1.8) sudo 命令路径(适用于1.8及以上版本)

**ansible_connection** 与主机的连接类型.比如:local, ssh 或者 paramiko. Ansible 1.2 以前默认使用 paramiko.1.2 以后默认使用 'smart','smart' 方式会根据是否支持 ControlPersist, 来判断'ssh' 方式是否可行.

**ansible_ssh_private_key_file** ssh 使用的私钥文件.适用于有多个密钥,而你不想使用 SSH 代理的情况.

**ansible_shell_type** 目标系统的shell类型.默认情况下,命令的执行使用 'sh' 语法,可设置为 'csh' 或 'fish'.

**ansible_python_interpreter** 目标主机的 python 路径.适用于的情况: 系统中有多个 Python, 或者命令路径不是"/usr/bin/python",比如 *BSD, 或者 /usr/bin/python 不是 2.X 版本的 Python.我们不使用 "/usr/bin/env" 机制,因为这要求远程用户的路径设置正确,且要求 "python" 可执行程序名不可为 python以外的名字(实际有可能名为python26).

```
    与 ansible_python_interpreter 的工作方式相同,可设定如 ruby 或 perl 的路径....
```

## 例子：

web1 ansible_ssh_user=manager ansible_ssh_pass=密码

some_host ansible_ssh_port=2222 ansible_ssh_user=manager aws_host ansible_ssh_private_key_file=/home/example/.ssh/aws.pem freebsd_host ansible_python_interpreter=/usr/local/bin/python ruby_module_host ansible_ruby_interpreter=/usr/bin/ruby.1.9.3

## [#](http://www.liuwq.com/views/自动化工具/ansible常用命令.html#创建目录)创建目录

```shell
  ansible dbserver -m file -a "dest=/tmp/ss mode=755 owner=root group=root state=directory"

  修改文件权限
  ansible dbserver -m file -a "dest=/tmp/a.txt mode=600"
  拷贝文件
  ansible dbserver -m copy -a "src=/etc/hosts dest=/etc/hosts"
  系统状态检查
  ansible dbserver -m service -a "name=iptables state=started"
```

# ansible常用命令

### 1. 配置需求

##### 对管理主机的要求

目前,只要机器上安装了 Python 2.6 或 Python 2.7 (windows系统不可以做控制主机),都可以运行Ansible.主机的系统可以是 Red Hat, Debian, CentOS, OS X, BSD的各种版本,等等.

##### 对节点主机的要求

通常我们使用 ssh 与托管节点通信，默认使用 sftp.如果 sftp 不可用，可在 ansible.cfg 配置文件中配置成 scp 的方式. 在托管节点上也需要安装 Python 2.4 或以上的版本.如果版本低于 Python 2.5 ,还需要额外安装一个模块: `python-simplejson`

### 2. ansible配置文件

```tsx
[root@ocp ~]# ansible --version
ansible 2.2.1.0
  config file = /etc/ansible/ansible.cfg
  configured module search path = Default w/o overrides
```

可以查看配置文件路径。
ansible 配置文件默认存使用 `/etc/ansible/ansible.cfg`
hosts文件默认存使用 `/etc/ansible/hosts`

### 3. 主机清单示例

```csharp
mail.example.com # FQDN

[webservers] # 方括号[]中是组名
host1
host2:5522  # 指定连接主机得端口号,在生产中可能用的比较多
localhost ansible_connection=local # 定义连接类型
host3 http_port=80 maxRequestsPerChild=808 # 定义主机变量
host4 ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50 # 定义主机ssh连接端口和连接地址
www[1:50].example.com # 定义 1-50范围内的主机
www-[a:f].example.com # 定义a-f范围内内的主机

[dbservers]
three.example.com     ansible_python_interpreter=/usr/local/bin/python #定义python执行文件
192.168.77.123     ruby_module_host  ansible_ruby_interpreter=/usr/bin/ruby.1.9.3 # 定义ruby执行文件

[webservers:vars]  # 定义webservers组的变量
ntp_server= ntp.example.com
proxy=proxy.example.com


[server:children] # 定义server组的子成员
webservers
dbservers

[server:vars] # 定义server组的变量
zabbix_server:192.168.77.121
```

### 3. ansible 命令

```cpp
ansible all -m ping # all:指的是主机清单中所有的主机，-m: module_name模块名
ansible 192.168.77.* -m ping
ansible all -m command -a ifconfig # -a:args， 指模块对应的参数
ansible all -m shell -a "ifconfig eth0 |grep 'inet addr' "
ansible -i "192.168.77.129,192.168.77.130" 192.168.77.129  -m ping
ansible -i hosts  all --list-host
ansible -i hosts -l 192.168.77.130 all -m ping -t /tmp -vvvv
ansible web -l @retry_hosts.txt --list-hosts
```

#### Patterns 是定义Ansible要管理的主机。

##### 命令行

```css
ansible <host-pattern> [options]
```

##### 匹配所有的主机,两个Patterns 均表示匹配所有的主机

```undefined
all
*
```

##### 精确匹配

```css
192.168.77.121
```

以上Patterns 表示只匹配192.168.77.121这一个主机

##### 或匹配

```css
web:db
```

以上Patterns 表示匹配的主机在web组或db组中

##### 非模式匹配

```bash
ansible "web:\!db" # 需要加引号（最好使用单引号）
```

命令下需转义特殊符号，以上Patterns 表示匹配的主机在web组，不在db组中，包含在web组，又在db中的用户

##### 交集匹配

```bash
ansible "web:&db" # 需要加引号（最好使用单引号）
```

以上Patterns 表示匹配的主机同时在db组和dbservers组中

**综合逻辑**

```shell
ansible 'websers:dbsers:&appsers:!ftpservs'  
```



##### 通配符匹配

```css
web-*.com:dbserver
webserver[0]
webserver[0:25]
```

*表示所有字符，[0]表示组第一个成员，[0:25] 表示组第1个到第24个成员，类似python中得切片

### 3.1 执行shell

##### 获取web组里得eth0接口信息

```bash
ansible web -a "ifconfig eth0"
```

执行ifconfig eth0 命令，ansible模块 默认是command，它不会通过shell进行处理，所以像$ HOME和像“<”，“>”，“|”，“;” 和“＆”将不工作（如果您需要这些功能，请使用shell模块）。

##### 以shell解释器执行脚本

```bash
ansible web -m shell -a "ifconfig eth0|grep addr"  
```

##### 以raw模块执行脚本

```bash
ansible web -m raw -a "ifconfig eth0|grep addr"  
```

##### 将本地脚本传送到远程节点上运行

```css
ansible web -m script -a ip.sh  
```

### 3.2 传输文件

##### 拷贝本地的/etc/hosts 文件到web组所有主机的/tmp/hosts（空目录除外）

```go
ansible web -m copy -a "src=/etc/hosts dest=/tmp/hosts"
```

##### 拷贝本地的ntp文件到目的地址，设置其用户及权限，如果目标地址存在相同的文件，则备份源文件。

```go
ansible web -m copy -a "src=/mine/ntp.conf dest=/etc/ntp.conf owner=root group=root mode=644 backup=yes force=yes"
```

##### file 模块允许更改文件的用户及权限

```bash
ansible web -m file -a "dest=/tmp/a.txt mode=600 owner=user group=user"
```

##### 使用file 模块创建目录，类似mkdir -p

```bash
ansible web -m file -a "dest=/tmp/test mode=755 owner=user group=user state=directory"
```

##### 使用file 模块删除文件或者目录

```bash
ansible web -m file -a "dest=/tmp/test state=absent"
```

##### 创建软连接，并设置所属用户和用户组

```bash
ansible web -m file -a  "src=/file/to/link/to dest=/path/to/symlink owner=user group=user state=link"
```

##### touch 一个文件并添加用户读写权限，用户组去除写执行权限，其他组减去读写执行权限

```bash
ansible web -m file -a  "path=/etc/foo.conf state=touch mode='u+rw,g-wx,o-rwx'"
```

### 3.2 管理软件包

##### apt、yum 模块分别用于管理Ubuntu 系列和RedHat 系列系统软件包

##### 更新仓库缓存，并安装"foo"

```bash
ansible web -m apt -a "name=foo update_cache=yes"
```

##### 删除 "foo"

```bash
ansible web -m apt -a "name=foo state=absent"
```

##### 安装 "foo"

```bash
ansible web -m apt -a "name=foo state=present"
```

##### 安装 1.0版本的 "foo"

ansible web -m apt -a "name=foo=1.00 state=present"

##### 安装最新得"foo"

ansible web -m apt -a "name=foo state=latest"

注释：Ansible 支持很多操作系统的软件包管理，使用时-m 指定相应的软件包管理工具模块，如果没有这样的模块，可以自己定义类似的模块或者使用command 模块来安装软件包

##### 安装 最新的 Apache

```bash
ansible web -m yum -a  "name=httpd state=latest"
```

##### 删除apache

```bash
ansible web -m yum -a  "name=httpd state=absent"
```

##### 从testing 仓库中安装最后一个版本得apache

```bash
ansible web -m yum -a  "name=httpd enablerepo=testing state=present"
```

##### 更新所有的包

```bash
ansible web -m yum -a  "name=* state=latest"
```

##### 安装远程的rpm包

```bash
ansible web -m yum -a  "name=http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm state=present"
```

##### 安装 'Development tools' 包组

```bash
ansible web -m yum -a  "name='@Development tools' state=present"
```

### 3.3 用户和用户组

##### 添加用户 'user'并设置其 uid 和主要的组'admin'

```bash
ansible web -m user -a "name=user  comment='I am user ' uid=1040 group=admin"
```

##### 添加用户 'user'并设置其登陆shell，并将其假如admins和developers组

```bash
ansible web -m user -a "name=user shell=/bin/bash groups=admins,developers append=yes"
```

##### 删除用户 'user'

```bash
ansible web -m user -a "name=user state=absent remove=yes"
```

##### 创建 user用户得 2048-bit SSH key，并存放在 ~user/.ssh/id_rsa

```bash
ansible web -m user -a "name=user generate_ssh_key=yes ssh_key_bits=2048 ssh_key_file=.ssh/id_rsa"
```

##### 设置用户过期日期

```bash
ansible web -m user -a "name=user shell=/bin/zsh groups=nobdy expires=1422403387"
```

##### 创建test组，并设置git为1000

```csharp
ansible web -m group -a "name=test gid=1000 state=present"
```

##### 删除test组

```csharp
ansible web -m group -a "name=test state=absent"
```

### 3.4 源码部署

Ansible 模块能够通知变更，当代码更新时，可以告诉Ansible 做一些特定的任务，比如从git 部署代码然后重启apache 服务等

```bash
ansible web-m git -a "repo=https://github.com/Icinga/icinga2.git dest=/tmp/myapp   version=HEAD"
```

### 3.5 服务管理

确保web组所有主机的httpd 是启动的

```bash
ansible web-m service -a "name=httpd state=started"
```

重启web组所有主机的httpd 服务

```bash
ansible web-m service -a "name=httpd state=restarted"
```

确保web组所有主机的httpd 是关闭的

```bash
ansible web-m service -a "name=httpd state=stopped"
```

### 3.6 后台运行

长时间运行的操作可以放到后台执行，ansible 会检查任务的状态；在主机上执行的同一个任务会分配同一个job ID
后台执行命令3600s，-B 表示后台执行的时间

```bash
ansible all -B 3600 -a "/usr/bin/long_running_operation --do-stuff"
```

### 3.7 检查任务的状态

```bash
ansible all -m async_status -a "jid=123456789"
```

后台执行命令最大时间是1800s 即30 分钟，-P 每60s 检查下状态默认15s

```bash
ansible all -B 1800 -P 60 -a "/usr/bin/long_running_operation --do-stuff"
```

### 3.8 定时任务

每天5点，2点得时候执行 ls -alh > /dev/null

```bash
ansible test -m cron -a "name='check dirs' minute='0' hour='5,2' job='ls -alh > /dev/null'"
```

### 3.9 搜集系统信息

搜集主机的所有系统信息

```undefined
ansible all -m setup
```

搜集系统信息并以主机名为文件名分别保存在/tmp/facts 目录

```undefined
ansible all -m setup --tree /tmp/facts
```

搜集和内存相关的信息

```bash
ansible all -m setup -a 'filter=ansible_*_mb'
```

搜集网卡信息

```bash
ansible all -m setup -a 'filter=ansible_eth[0-2]'
```

### ansible命令执行过程

1. 加载自己的配置文件默认/etc/ansible/ansible.cfg

2. 加载自己对应的模块文件， 如command

3. 通过ansible将模块或者命令生成临时py文件（#local_tmp      = ~/.ansible/tmp），并将文件传输到远程服务器的对应执行用户$HOME/.ansible/tmp/ansible-tmp-数字/xxx.py文件（#remote_tmp     = ~/.ansible/tmp）

4. 给文件+x执行

5. 执行并返回结果

6. 删除远程服务器的临时文件，sleep 0 退出

    #### 执行状态

    1. 绿色：执行成功并且不需要做改变的操作

    2. 黄色：执行成功并且不需要对目标主机做更改

    3. 红色：执行失败

## 配置文件解析（/etc/ansible/ansible.cfg）

```shell
# config file for ansible -- https://ansible.com/
# ===============================================

# nearly all parameters can be overridden in ansible-playbook
# or with command line flags. ansible will read ANSIBLE_CONFIG,
# ansible.cfg in the current working directory, .ansible.cfg in
# the home directory or /etc/ansible/ansible.cfg, whichever it
# finds first

[defaults]

# some basic default values...

#inventory      = /etc/ansible/hosts
#library        = /usr/share/my_modules/
#module_utils   = /usr/share/my_module_utils/
#remote_tmp     = ~/.ansible/tmp
#local_tmp      = ~/.ansible/tmp
#forks          = 5
#poll_interval  = 15
#sudo_user      = root
#ask_sudo_pass = True
#ask_pass      = True
#transport      = smart
#remote_port    = 22
#module_lang    = C
#module_set_locale = False

# plays will gather facts by default, which contain information about
# the remote system.
#
# smart - gather by default, but don't regather if already gathered
# implicit - gather by default, turn off with gather_facts: False
# explicit - do not gather by default, must say gather_facts: True
#gathering = implicit

# This only affects the gathering done by a play's gather_facts directive,
# by default gathering retrieves all facts subsets
# all - gather all subsets
# network - gather min and network facts
# hardware - gather hardware facts (longest facts to retrieve)
# virtual - gather min and virtual facts
# facter - import facts from facter
# ohai - import facts from ohai
# You can combine them using comma (ex: network,virtual)
# You can negate them using ! (ex: !hardware,!facter,!ohai)
# A minimal set of facts is always gathered.
#gather_subset = all

# some hardware related facts are collected
# with a maximum timeout of 10 seconds. This
# option lets you increase or decrease that
# timeout to something more suitable for the
# environment. 
# gather_timeout = 10

# additional paths to search for roles in, colon separated
roles_path    = /etc/ansible/roles:/usr/share/ansible/roles

# uncomment this to disable SSH key host checking
#host_key_checking = False

# change the default callback, you can only have one 'stdout' type  enabled at a time.
#stdout_callback = skippy


## Ansible ships with some plugins that require whitelisting,
## this is done to avoid running all of a type by default.
## These setting lists those that you want enabled for your system.
## Custom plugins should not need this unless plugin author specifies it.

# enable callback plugins, they can output to stdout but cannot be 'stdout' type.
#callback_whitelist = timer, mail

# Determine whether includes in tasks and handlers are "static" by
# default. As of 2.0, includes are dynamic by default. Setting these
# values to True will make includes behave more like they did in the
# 1.x versions.
#task_includes_static = True
#handler_includes_static = True

# Controls if a missing handler for a notification event is an error or a warning
#error_on_missing_handler = True

# change this for alternative sudo implementations
#sudo_exe = sudo

# What flags to pass to sudo
# WARNING: leaving out the defaults might create unexpected behaviours
#sudo_flags = -H -S -n

# SSH timeout
#timeout = 10

# default user to use for playbooks if user is not specified
# (/usr/bin/ansible will use current user as default)
#remote_user = root

# logging is off by default unless this path is defined
# if so defined, consider logrotate
#log_path = /var/log/ansible.log

# default module name for /usr/bin/ansible
#module_name = command

# use this shell for commands executed under sudo
# you may need to change this to bin/bash in rare instances
# if sudo is constrained
#executable = /bin/sh

# if inventory variables overlap, does the higher precedence one win
# or are hash values merged together?  The default is 'replace' but
# this can also be set to 'merge'.
#hash_behaviour = replace

# by default, variables from roles will be visible in the global variable
# scope. To prevent this, the following option can be enabled, and only
# tasks and handlers within the role will see the variables there
#private_role_vars = yes

# list any Jinja2 extensions to enable here:
#jinja2_extensions = jinja2.ext.do,jinja2.ext.i18n

# if set, always use this private key file for authentication, same as
# if passing --private-key to ansible or ansible-playbook
#private_key_file = /path/to/file

# If set, configures the path to the Vault password file as an alternative to
# specifying --vault-password-file on the command line.
#vault_password_file = /path/to/vault_password_file

# format of string {{ ansible_managed }} available within Jinja2
# templates indicates to users editing templates files will be replaced.
# replacing {file}, {host} and {uid} and strftime codes with proper values.
#ansible_managed = Ansible managed: {file} modified on %Y-%m-%d %H:%M:%S by {uid} on {host}
# {file}, {host}, {uid}, and the timestamp can all interfere with idempotence
# in some situations so the default is a static string:
#ansible_managed = Ansible managed

# by default, ansible-playbook will display "Skipping [host]" if it determines a task
# should not be run on a host.  Set this to "False" if you don't want to see these "Skipping"
# messages. NOTE: the task header will still be shown regardless of whether or not the
# task is skipped.
#display_skipped_hosts = True

# by default, if a task in a playbook does not include a name: field then
# ansible-playbook will construct a header that includes the task's action but
# not the task's args.  This is a security feature because ansible cannot know
# if the *module* considers an argument to be no_log at the time that the
# header is printed.  If your environment doesn't have a problem securing
# stdout from ansible-playbook (or you have manually specified no_log in your
# playbook on all of the tasks where you have secret information) then you can
# safely set this to True to get more informative messages.
#display_args_to_stdout = False

# by default (as of 1.3), Ansible will raise errors when attempting to dereference
# Jinja2 variables that are not set in templates or action lines. Uncomment this line
# to revert the behavior to pre-1.3.
#error_on_undefined_vars = False

# by default (as of 1.6), Ansible may display warnings based on the configuration of the
# system running ansible itself. This may include warnings about 3rd party packages or
# other conditions that should be resolved if possible.
# to disable these warnings, set the following value to False:
#system_warnings = True

# by default (as of 1.4), Ansible may display deprecation warnings for language
# features that should no longer be used and will be removed in future versions.
# to disable these warnings, set the following value to False:
#deprecation_warnings = True

# (as of 1.8), Ansible can optionally warn when usage of the shell and
# command module appear to be simplified by using a default Ansible module
# instead.  These warnings can be silenced by adjusting the following
# setting or adding warn=yes or warn=no to the end of the command line
# parameter string.  This will for example suggest using the git module
# instead of shelling out to the git command.
# command_warnings = False


# set plugin path directories here, separate with colons
#action_plugins     = /usr/share/ansible/plugins/action
#cache_plugins      = /usr/share/ansible/plugins/cache
#callback_plugins   = /usr/share/ansible/plugins/callback
#connection_plugins = /usr/share/ansible/plugins/connection
#lookup_plugins     = /usr/share/ansible/plugins/lookup
#inventory_plugins  = /usr/share/ansible/plugins/inventory
#vars_plugins       = /usr/share/ansible/plugins/vars
#filter_plugins     = /usr/share/ansible/plugins/filter
#test_plugins       = /usr/share/ansible/plugins/test
#terminal_plugins   = /usr/share/ansible/plugins/terminal
#strategy_plugins   = /usr/share/ansible/plugins/strategy


# by default, ansible will use the 'linear' strategy but you may want to try
# another one
#strategy = free

# by default callbacks are not loaded for /bin/ansible, enable this if you
# want, for example, a notification or logging callback to also apply to
# /bin/ansible runs
#bin_ansible_callbacks = False


# don't like cows?  that's unfortunate.
# set to 1 if you don't want cowsay support or export ANSIBLE_NOCOWS=1
#nocows = 1

# set which cowsay stencil you'd like to use by default. When set to 'random',
# a random stencil will be selected for each task. The selection will be filtered
# against the `cow_whitelist` option below.
#cow_selection = default
#cow_selection = random

# when using the 'random' option for cowsay, stencils will be restricted to this list.
# it should be formatted as a comma-separated list with no spaces between names.
# NOTE: line continuations here are for formatting purposes only, as the INI parser
#       in python does not support them.
#cow_whitelist=bud-frogs,bunny,cheese,daemon,default,dragon,elephant-in-snake,elephant,eyes,\
#              hellokitty,kitty,luke-koala,meow,milk,moofasa,moose,ren,sheep,small,stegosaurus,\
#              stimpy,supermilker,three-eyes,turkey,turtle,tux,udder,vader-koala,vader,www

# don't like colors either?
# set to 1 if you don't want colors, or export ANSIBLE_NOCOLOR=1
#nocolor = 1

# if set to a persistent type (not 'memory', for example 'redis') fact values
# from previous runs in Ansible will be stored.  This may be useful when
# wanting to use, for example, IP information from one group of servers
# without having to talk to them in the same playbook run to get their
# current IP information.
#fact_caching = memory


# retry files
# When a playbook fails by default a .retry file will be created in ~/
# You can disable this feature by setting retry_files_enabled to False
# and you can change the location of the files by setting retry_files_save_path

#retry_files_enabled = False
#retry_files_save_path = ~/.ansible-retry

# squash actions
# Ansible can optimise actions that call modules with list parameters
# when looping. Instead of calling the module once per with_ item, the
# module is called once with all items at once. Currently this only works
# under limited circumstances, and only with parameters named 'name'.
#squash_actions = apk,apt,dnf,homebrew,pacman,pkgng,yum,zypper

# prevents logging of task data, off by default
#no_log = False

# prevents logging of tasks, but only on the targets, data is still logged on the master/controller
#no_target_syslog = False

# controls whether Ansible will raise an error or warning if a task has no
# choice but to create world readable temporary files to execute a module on
# the remote machine.  This option is False by default for security.  Users may
# turn this on to have behaviour more like Ansible prior to 2.1.x.  See
# https://docs.ansible.com/ansible/become.html#becoming-an-unprivileged-user
# for more secure ways to fix this than enabling this option.
#allow_world_readable_tmpfiles = False

# controls the compression level of variables sent to
# worker processes. At the default of 0, no compression
# is used. This value must be an integer from 0 to 9.
#var_compression_level = 9

# controls what compression method is used for new-style ansible modules when
# they are sent to the remote system.  The compression types depend on having
# support compiled into both the controller's python and the client's python.
# The names should match with the python Zipfile compression types:
# * ZIP_STORED (no compression. available everywhere)
# * ZIP_DEFLATED (uses zlib, the default)
# These values may be set per host via the ansible_module_compression inventory
# variable
#module_compression = 'ZIP_DEFLATED'

# This controls the cutoff point (in bytes) on --diff for files
# set to 0 for unlimited (RAM may suffer!).
#max_diff_size = 1048576

# This controls how ansible handles multiple --tags and --skip-tags arguments
# on the CLI.  If this is True then multiple arguments are merged together.  If
# it is False, then the last specified argument is used and the others are ignored.
# This option will be removed in 2.8.
#merge_multiple_cli_flags = True

# Controls showing custom stats at the end, off by default
#show_custom_stats = True

# Controls which files to ignore when using a directory as inventory with
# possibly multiple sources (both static and dynamic)
#inventory_ignore_extensions = ~, .orig, .bak, .ini, .cfg, .retry, .pyc, .pyo

# This family of modules use an alternative execution path optimized for network appliances
# only update this setting if you know how this works, otherwise it can break module execution
#network_group_modules=['eos', 'nxos', 'ios', 'iosxr', 'junos', 'vyos']

# When enabled, this option allows lookups (via variables like {{lookup('foo')}} or when used as
# a loop with `with_foo`) to return data that is not marked "unsafe". This means the data may contain
# jinja2 templating language which will be run through the templating engine.
# ENABLING THIS COULD BE A SECURITY RISK
#allow_unsafe_lookups = False

# set default errors for all plays
#any_errors_fatal = False

[inventory]
# enable inventory plugins, default: 'host_list', 'script', 'yaml', 'ini'
#enable_plugins = host_list, virtualbox, yaml, constructed

# ignore these extensions when parsing a directory as inventory source
#ignore_extensions = .pyc, .pyo, .swp, .bak, ~, .rpm, .md, .txt, ~, .orig, .ini, .cfg, .retry

# ignore files matching these patterns when parsing a directory as inventory source
#ignore_patterns=

# If 'true' unparsed inventory sources become fatal errors, they are warnings otherwise.
#unparsed_is_failed=False

[privilege_escalation]
#become=True
#become_method=sudo
#become_user=root
#become_ask_pass=False

[paramiko_connection]

# uncomment this line to cause the paramiko connection plugin to not record new host
# keys encountered.  Increases performance on new host additions.  Setting works independently of the
# host key checking setting above.
#record_host_keys=False

# by default, Ansible requests a pseudo-terminal for commands executed under sudo. Uncomment this
# line to disable this behaviour.
#pty=False

# paramiko will default to looking for SSH keys initially when trying to
# authenticate to remote devices.  This is a problem for some network devices
# that close the connection after a key failure.  Uncomment this line to
# disable the Paramiko look for keys function
#look_for_keys = False

# When using persistent connections with Paramiko, the connection runs in a
# background process.  If the host doesn't already have a valid SSH key, by
# default Ansible will prompt to add the host key.  This will cause connections
# running in background processes to fail.  Uncomment this line to have
# Paramiko automatically add host keys.
#host_key_auto_add = True

[ssh_connection]

# ssh arguments to use
# Leaving off ControlPersist will result in poor performance, so use
# paramiko on older platforms rather than removing it, -C controls compression use
#ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s

# The base directory for the ControlPath sockets. 
# This is the "%(directory)s" in the control_path option
# 
# Example: 
# control_path_dir = /tmp/.ansible/cp
#control_path_dir = ~/.ansible/cp

# The path to use for the ControlPath sockets. This defaults to a hashed string of the hostname, 
# port and username (empty string in the config). The hash mitigates a common problem users 
# found with long hostames and the conventional %(directory)s/ansible-ssh-%%h-%%p-%%r format. 
# In those cases, a "too long for Unix domain socket" ssh error would occur.
#
# Example:
# control_path = %(directory)s/%%h-%%r
#control_path =

# Enabling pipelining reduces the number of SSH operations required to
# execute a module on the remote server. This can result in a significant
# performance improvement when enabled, however when using "sudo:" you must
# first disable 'requiretty' in /etc/sudoers
#
# By default, this option is disabled to preserve compatibility with
# sudoers configurations that have requiretty (the default on many distros).
#
#pipelining = False

# Control the mechanism for transferring files (old)
#   * smart = try sftp and then try scp [default]
#   * True = use scp only
#   * False = use sftp only
#scp_if_ssh = smart

# Control the mechanism for transferring files (new)
# If set, this will override the scp_if_ssh option
#   * sftp  = use sftp to transfer files
#   * scp   = use scp to transfer files
#   * piped = use 'dd' over SSH to transfer files
#   * smart = try sftp, scp, and piped, in that order [default]
#transfer_method = smart

# if False, sftp will not use batch mode to transfer files. This may cause some
# types of file transfer failures impossible to catch however, and should
# only be disabled if your sftp version has problems with batch mode
#sftp_batch_mode = False

[persistent_connection]

# Configures the persistent connection timeout value in seconds.  This value is
# how long the persistent connection will remain idle before it is destroyed.  
# If the connection doesn't receive a request before the timeout value 
# expires, the connection is shutdown. The default value is 30 seconds.
#connect_timeout = 30

# Configures the persistent connection retry timeout.  This value configures the
# the retry timeout that ansible-connection will wait to connect
# to the local domain socket. This value must be larger than the
# ssh timeout (timeout) and less than persistent connection idle timeout (connect_timeout).
# The default value is 15 seconds.
#connect_retry_timeout = 15

# The command timeout value defines the amount of time to wait for a command
# or RPC call before timing out. The value for the command timeout must
# be less than the value of the persistent connection idle timeout (connect_timeout)
# The default value is 10 second.
#command_timeout = 10

[accelerate]
#accelerate_port = 5099
#accelerate_timeout = 30
#accelerate_connect_timeout = 5.0

# The daemon timeout is measured in minutes. This time is measured
# from the last activity to the accelerate daemon.
#accelerate_daemon_timeout = 30

# If set to yes, accelerate_multi_key will allow multiple
# private keys to be uploaded to it, though each user must
# have access to the system via SSH to add a new key. The default
# is "no".
#accelerate_multi_key = yes

[selinux]
# file systems that require special treatment when dealing with security context
# the default behaviour that copies the existing context or uses the user default
# needs to be changed to use the file system dependent context.
#special_context_filesystems=nfs,vboxsf,fuse,ramfs,9p

# Set this to yes to allow libvirt_lxc connections to work without SELinux.
#libvirt_lxc_noseclabel = yes

[colors]
#highlight = white
#verbose = blue
#warn = bright purple
#error = red
#debug = dark gray
#deprecate = purple
#skip = cyan
#unreachable = red
#ok = green
#changed = yellow
#diff_add = green
#diff_remove = red
#diff_lines = cyan


[diff]
# Always print diff when running ( same as always running with -D/--diff )
# always = no

# Set how many context lines to show in diff
# context = 3

```

​        

​        

​        

