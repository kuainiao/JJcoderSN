# SVN 使用

------

# [#](http://www.liuwq.com/views/自动化工具/svn.html#linux下搭建svn服务器及创建项目)linux下搭建svn服务器及创建项目

主题 SVN Linux

## [#](http://www.liuwq.com/views/自动化工具/svn.html#一-使用yum-安装svn包)一. 使用yum 安装SVN包

关于YUM 服务器的配置参考： Linux 搭建 YUM 服务器 http://blog.csdn.net/tianlesoftware/archive/2011/01/03/6113902.aspx

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_1-安装svn命令如下)1.安装svn命令如下

```shell
[root@shxt~]# yum install -y subversion
验证安装版本
[root@shxt ~]# svnserve --version
创建SVN 版本库
[root@shxt ~]# mkdir /var/www/svn
[root@shxt ~]# svnadmin create /var/www/svn/testproject  --  testproject 为版本库名称
为svn创建用户
[root@shxt ~]# htpasswd -c /var/www/passwd ***(这个根据情况不同，写法不同， -c是创建用户（删除原有用户）,-d是在原有基础上添加用户）)  
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_2-配置svn)2.配置svn

创建版本库后，在这个目录下会生成3个配置文件：

```shell
[root@shxt conf]# pwd
/var/www/svn/testproject/conf
[root@shxt conf]# ls
  authz  passwd  svnserve.conf
```

- svnserve.conf 文件， 该文件配置项分为以下5项：
    - `anon-access`： 控制非鉴权用户访问版本库的权限。
    - `auth-access`： 控制鉴权用户访问版本库的权限。
    - `password-db`： 指定用户名口令文件名。
    - `authz-db`：指定权限配置文件名，通过该文件可以实现以路径为基础的访问控制。
    - `realm`：指定版本库的认证域，即在登录时提示的认证域名称。若两个版本库的认证域相同，建议使用相同的用户名口令数据文件
- Passwd 文件 ：

我们在`svnserve.conf`文件里启用这个文件。然后配置如下：

```shell
[root@shxt conf]# vi passwd
[users]
# harry = harryssecret
# sally = sallyssecret
admin = admin
zhangsan= zhangsanpwd
```

- authz 文件 ：

下面我们来配置我们的`authz`文件：

```shell
[root@shxt conf]# vi authz
[groups]
admin = admin
zhangsan=zhangsan
[project:/]
@admin = rw
@zhangsan = rw
[root@shxt conf]#
```

以下是在网上找到一个很好的配置例子：

```shell
[groups]
admin = john, kate
devteam1 = john, rachel, sally
devteam2 = kate, peter, mark
docs = bob, jane, mike
training = zak
```

-- 这里把不同用户放到不同的组里面，下面在设置目录访问权限的时候，用目录来操作就可以了。

```yml
# 为所有库指定默认访问规则
# 所有人可以读，管理员可以写，危险分子没有任何权限
[/]  --对应我测试里的：/u02/svn 目录
* = r
@admin = rw
dangerman =

# 允许开发人员可以完全访问他们的项目版本库
[proj1:/]
@devteam1 = rw
[proj2:/]
@devteam2 = rw
[bigproj:/]
@devteam1 = rw
@devteam2 = rw
trevor = rw

# 文档编写人员对所有的docs目录有写权限
[/trunk/doc]
@docs = rw

# 培训人员可以完全访问培训版本库
[TrainingRepos:/]
@training = rw
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_3-启动和停止svn服务)3.启动和停止SVN服务

#### [#](http://www.liuwq.com/views/自动化工具/svn.html#_1）启动svn服务)1）启动SVN服务

```shell
	[root@shxt conf]# svnserve -d -r /var/www/svn
   		-d表示后台运行
    	-r 指定根目录是 /var/www/svn
```

#### [#](http://www.liuwq.com/views/自动化工具/svn.html#_2）-查看svn服务)2） 查看svn服务

```shell
	[root@shxt conf]# ps -ef | grep svn
```

#### [#](http://www.liuwq.com/views/自动化工具/svn.html#_3）停止svn服务)3）停止SVN服务:

~~~shell
	[root@shxt conf]# ps -aux |grep svn
	[root@shxt conf]# kill -9 进程杀掉

多数时候会把svn服务放到apache的服务中

```shell
重启apache
	/usr/local/apache/bin/apachectl restart
    或者
      service httpd restart
~~~

**如果遇到下列问题**

```
Can't open file '/var/www/svn/repo_name/db/txn-current-lock': Permission denied
```

需要分配读写权限

```shell
	$ cd /var/www/svn
    $ chown -R apache.apache project（项目名）
  或者
     $ chmod –R o+rw  /var/www/svn/
```

## [#](http://www.liuwq.com/views/自动化工具/svn.html#二-客户端连接svn-服务器)二. 客户端连接SVN 服务器

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_2-1-安装tortoisesvn-客户端)2.1 安装TortoiseSVN 客户端

```
下载地址：http://tortoisesvn.net/downloads.html
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_2-2-找到自己项目的目录，右击，进行svn-操作)2.2 找到自己项目的目录，右击，进行SVN 操作

（1）新建测试目录svn，进入后右键，点checkout：

SVN 服务器的IP地址和版本库名称。

新建个文件svn.txt. 把这个文件上传到SVN服务器(add)：

## [#](http://www.liuwq.com/views/自动化工具/svn.html#三-linux下svn使用命令总结)三.linux下svn使用命令总结

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_1、将文件checkout到本地目录)1、将文件checkout到本地目录

```shell
	svn checkout path（path是服务器上的目录）
	例如：svn checkout svn://192.168.1.1/pro/domain
	简写：svn co
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_2、往版本库中添加新的文件)2、往版本库中添加新的文件

```shell
	svn add file
	例如：svn add test.php(添加test.php)
	svn add *.php(添加当前目录下所有的php文件)
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_3、将改动的文件提交到版本库)3、将改动的文件提交到版本库

```shell
	svn commit -m “LogMessage“ [-N] [--no-unlock] PATH(如果选择了保持锁，就使用–no-unlock开关)
	例如：svn commit -m “add test file for my test“ test.php
	简写：svn ci
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_4、加锁-解锁)4、加锁/解锁

```shell
	svn lock -m “LockMessage“ [--force] PATH
	例如：svn lock -m “lock test file“ test.php
	svn unlock PATH
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_5、更新到某个版本)5、更新到某个版本

```shell
	svn update -r m path
	例如：
	svn update如果后面没有目录，默认将当前目录以及子目录下的所有文件都更新到最新版本。
	svn update -r 200 test.php(将版本库中的文件test.php还原到版本200)
	svn update test.php(更新，于版本库同步。如果在提交的时候提示过期的话，是因为冲突，需要先update，修改文件，然后清除svn resolved，最后再提交commit)
	简写：svn up
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_6、查看文件或者目录状态)6、查看文件或者目录状态

```shell
	1）svn status path（目录下的文件和子目录的状态，正常状态不显示）
	【?：不在svn的控制中；M：内容被修改；C：发生冲突；A：预定加入到版本库；K：被锁定】
	2）svn status -v path(显示文件和子目录状态)
	第一列保持相同，第二列显示工作版本号，第三和第四列显示最后一次修改的版本号和修改人。
	注：svn status、svn diff和 svn revert这三条命令在没有网络的情况下也可以执行的，原因是svn在本地的.svn中保留了本地版本的原始拷贝。
	简写：svn st
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_7、删除文件)7、删除文件

```shell
	svn delete path -m “delete test fle“
	例如：svn delete svn://192.168.1.1/pro/domain/test.php -m “delete test file”
	或者直接svn delete test.php 然后再svn ci -m ‘delete test file‘，推荐使用这种
	简写：svn (del, remove, rm)
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_8、查看日志)8、查看日志

```shell
	svn log path
	例如：svn log test.php 显示这个文件的所有修改记录，及其版本号的变化
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_9、查看文件详细信息)9、查看文件详细信息

```shell
	svn info path
	例如：svn info test.php
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_10、比较差异)10、比较差异

```shell
	svn diff path(将修改的文件与基础版本比较)
	例如：svn diff test.php
	svn diff -r m:n path(对版本m和版本n比较差异)
	例如：svn diff -r 200:201 test.php
	简写：svn di
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_11、将两个版本之间的差异合并到当前文件)11、将两个版本之间的差异合并到当前文件

```shell
	svn merge -r m:n path
	例如：svn merge -r 200:205 test.php（将版本200与205之间的差异合并到当前文件，但是一般都会产生冲突，需要处理一下）
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_12、svn-帮助)12、SVN 帮助

```shell
	svn help
	svn help ci
```

------

**以上是常用命令，下面写几个不经常用的**

------

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_13、版本库下的文件和目录列表)13、版本库下的文件和目录列表

```shell
	svn list path
	显示path目录下的所有属于版本库的文件和目录
	简写：svn ls
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_14、创建纳入版本控制下的新目录)14、创建纳入版本控制下的新目录

```shell
	svn mkdir: 创建纳入版本控制下的新目录。
	用法: 
	- 1、mkdir PATH…
	- 2、mkdir URL…
	创建版本控制的目录。
	1、每一个以工作副本 PATH 指定的目录，都会创建在本地端，并且加入新增
	调度，以待下一次的提交。
	2、每个以URL指定的目录，都会透过立即提交于仓库中创建。
	在这两个情况下，所有的中间目录都必须事先存在。
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_15、恢复本地修改)15、恢复本地修改

```shell
	svn revert: 恢复原始未改变的工作副本文件 (恢复大部份的本地修改)。revert:
	用法: revert PATH…
	注意: 本子命令不会存取网络，并且会解除冲突的状况。但是它不会恢复
	被删除的目录
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_16、代码库url变更)16、代码库URL变更

```shell
	svn switch (sw): 更新工作副本至不同的URL。
	用法: 1、switch URL [PATH]
	2、switch –relocate FROM TO [PATH...]
	1、更新你的工作副本，映射到一个新的URL，其行为跟“svn update”很像，也会将
	服务器上文件与本地文件合并。这是将工作副本对应到同一仓库中某个分支或者标记的
	方法。
	2、改写工作副本的URL元数据，以反映单纯的URL上的改变。当仓库的根URL变动
	(比如方案名或是主机名称变动)，但是工作副本仍旧对映到同一仓库的同一目录时使用
	这个命令更新工作副本与仓库的对应关系。
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_17、解决冲突)17、解决冲突

```shell
	svn resolved: 移除工作副本的目录或文件的“冲突”状态。
	用法: resolved PATH…
	注意: 本子命令不会依语法来解决冲突或是移除冲突标记；它只是移除冲突的
	相关文件，然后让 PATH 可以再次提交。
```

### [#](http://www.liuwq.com/views/自动化工具/svn.html#_18、输出指定文件或url的内容)18、输出指定文件或URL的内容.

```shell
	svn cat 目标[@版本]…如果指定了版本，将从指定的版本开始查找。
	svn cat -r PREV filename > filename (PREV 是上一版本,也可以写具体版本号,这样输出结果是可以
```