### 一、Jenkins概述

![enkin](./assets/Jenkins.png)

### 二、安装Jenkins

### 安装 Java

下载地址：

https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

> 可能你看到的版本已经更新！

![image-20180703135948042](assets/image-20180703135948042.png)

**wget 方式下载**

```bash
# wget \
--no-check-certificate \
--no-cookies --header \
"Cookie: oraclelicense=accept-securebackup-cookie" \
https://download.oracle.com/otn-pub/java/jdk/8u192-b12/750e1c8617c5452694857ad95c3ee230/jdk-8u192-linux-x64.tar.gz
# 以上命令和参数是在一行
```



下载源码包后，解压

```bash
[root@blog ~]# ls
anaconda-ks.cfg  jdk-8u171-linux-x64.tar.gz  
[root@blog ~]# tar -xf jdk-8u171-linux-x64.tar.gz -C /usr/local/jdk1.8.0_171
[root@blog ~]# ls /usr/local/jdk1.8.0_171/
bin             LICENSE
COPYRIGHT       man
db              README.html
include         release
javafx-src.zip  src.zip
jdk1.8.0_171    THIRDPARTYLICENSEREADME-JAVAFX.txt
jre             THIRDPARTYLICENSEREADME.txt
lib
```



**设置环境变量**

`/etc/profile` 文件最后添加以下内容

```bash
# set java environment
JAVA_HOME=/usr/local/jdk1.8.0_171  # java 安装包的解压目录
JRE_HOME=$JAVA_HOME/jre
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
export JAVA_HOME JRE_HOME PATH CLASSPATH
```



给环境变量含义

`JAVA_HOME`    指明JDK安装路径，就是刚才安装时解压所指定的路径，此路径下包括lib，bin，jre等文件夹（tomcat 的运行都需要依靠此变量）。

`CLASSPATH`    为java加载类(class or lib)路径，只有类在classpath中，java命令才能识别，CLASSPATH变量值中的`.`表示当前目录

`PATH`    使得系统可以在任何路径下识别java命令。

特别注意：环境变量值的结尾没有任何符号，不同值之间用:隔开



设置完成后，重启或者执行如下命令是环境变量生效

```bash
[root@blog ~]# source /etc/profile
```



检查版本，以检测安装是否成功

```bash
[root@blog ~]# java -version
java version "1.8.0_171"
Java(TM) SE Runtime Environment (build 1.8.0_171-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.171-b11, mixed mode)
```



创建软连接

因为 jenkins 启动时需要

```bash
[root@blog ~]# ln -s /usr/local/jdk1.8.0_171/bin/java /usr/bin/java
```





#### 下载并安装Jenkins

官方网址 https://pkg.jenkins.io/redhat-stable/

![image-20180702195642298](assets/image-20180702195642298.png)



```shell
[root@jenkins ~]# wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
[root@jenkins ~]# rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
[root@jenkins ~]# yum install jenkins
```
#### 相关包介绍

```
/usr/lib/jenkins/jenkins.war    WAR包 
/etc/sysconfig/jenkins       	配置文件
/var/lib/jenkins/        		默认的JENKINS_HOME目录
/var/log/jenkins/jenkins.log    Jenkins日志文件
```

#### 配置与启动

```shell
[root@jspgou ~]# lsof -i:8080
[root@jspgou ~]# /etc/init.d/jenkins start 
或者
[root@jspgou]# systemctl start jenkins
Starting jenkins (via systemctl):                          [  OK  ]
[root@jspgou ~]# lsof -i:8080
COMMAND   PID    USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
java    26969 jenkins  162u  IPv6  68624      0t0  TCP *:webcache (LISTEN)
[root@jspgou ~]# rpm -qa | grep jenkins
jenkins-2.107.1-1.1.noarch
[root@jspgou ~]# rpm -ql jenkins 
/etc/init.d/jenkins
/etc/logrotate.d/jenkins
/etc/sysconfig/jenkins
/usr/lib/jenkins
/usr/lib/jenkins/jenkins.war
/usr/sbin/rcjenkins
/var/cache/jenkins
/var/lib/jenkins
/var/log/jenkins
[root@jspgou ~]#
```



#### 初始化 `jenkins`



在浏览器中登录，初始密码在如下文件中：

```shell
[root@jspgou ~]# cat /var/lib/jenkins/secrets/initialAdminPassword
389c09a28ecb42fe871a82d4414c5472
[root@jspgou ~]#
```

![image-20180704141321268](assets/image-20180704141321268.png)





**点击 `安装推荐的插件`**

后期需要什么插件，再在`系统管理` 中安装即可

![image-20180705085209072](assets/image-20180705085209072.png)



![image-20180730180807016](assets/image-20180730180807016.png)

**创建管理员用户**



![image-20180730180931900](assets/image-20180730180931900.png)



![image-20181117101451928](assets/image-20181117101451928-2420892.png)







### 三、在WEB中配置Jenkins



#### 登录

再次登录地址： http://172.16.153.160:8080

> 假如你刚才没有创建用户，可以继续使用当前已经登录的用户 `admin` 登按照如下步骤创建用户。

#### 创建用户



**系统管理 --> 管理用户**

![image-20180710212400761](assets/image-20180710212400761.png)



点击左侧边栏中的 **新建用户**

![image-20180710212604362](assets/image-20180710212604362.png)



填入相应的用户信息后点击 **新建用户**

其中的电子邮件地址可以是随意的，但是格式必须是正确的邮箱地址的格式。

![image-20180710213038791](assets/image-20180710213038791.png)



创建成功后会自动跳转到**`用户列表`**页面

![image-20180710213324271](assets/image-20180710213324271.png)



#### 为用户设置权限

**`系统管理 --> 全局安全配置`**

![image-20180710213614684](assets/image-20180710213614684.png)



点选 **`安全矩阵`**，之后在 **`添加用户/组`** 中填写上需要权限管理的用户 ，最后点击 **`添加`** 按钮

![image-20181117102544092](assets/image-20181117102544092-2421544.png)

![image-20181117102614091](assets/image-20181117102614091-2421574.png)





 再在最右侧点击全选标识，把所有的权限分配给 `admin`，

![image-20181117102818640](assets/image-20181117102818640-2421698.png)

最后在屏幕或者浏览器的最下方点击 **`保存`** 按钮

![image-20181117102911734](assets/image-20181117102911734-2421751.png)





假如你想为另外一个用户 `jenkins` 添加除了 管理员权限外的所有权限，按照如下方式添加即可。（需要先去创建这个用户）

再次点击 **`全局安全配置`** 用上述的方法为刚才创建的用户 `jenkins` 添加除了管理员的权限的其他所有权限

![image-20180710215405177](assets/image-20180710215405177.png)



![image-20180710215724298](assets/image-20180710215724298.png)



注销当前管理员用户后，使用新创建的用户登录验证

![image-20180710215856064](assets/image-20180710215856064.png)

会发现新用户 `jenkins` 没有 **`系统管理`**  这个配置项目

![image-20180710220000861](assets/image-20180710220000861.png)



#### **系统管理--添加插件**

![image-20181117104029354](assets/image-20181117104029354-2422429.png)


**添加ssh、maven等相关插件**
``` 
以下插件需要选择安装
Ansible plugin

Ant Plugin

Blue Ocean
Build Timeout

Email Extension Plugin

	
Git Parameter Plug-In
Gitlab Hook Plugin
GitLab Plugin

Maven Invoker plugin
Maven Integration plugin

Publish Over SSH
SSH plugin
SSH Slaves plugin

Rebuilder
Safe Restart
```

方法如下图所示：
![3](./assets/3.png)

点击 `直接安装`

> 按照以上方法，把其他插件也安装好



#### **系统管理--系统设置**

![4](./assets/4.png)

**系统设置--指定管理员邮箱地址**

![image-20180717085425297](assets/image-20180717085425297.png)

**系统设置--设置邮件通知的SMTP服务器及其相关配置**

邮箱通知配置的前提是把在自己邮箱的提供商地方开通 `SMTP` 服务，同时需要客户端授权密码

![邮箱SMTP](assets/image-20180627191631085.png)





![image-20180717085726434](assets/image-20180717085726434.png)



1. SMTP 服务器      填写自己邮箱的提供商所提供的信息，主要是指定邮箱发件服务器地址；每个邮箱都不一定相同，这里是 126 邮箱。
2. 邮件后缀   就是你邮件地址后面的部分，如账号： `youname@126.com` 的后缀就是 `@126.com`
3. 这个邮箱地址需要和前面配置的管理员邮箱地址一致
4. 对 126 的邮箱和腾讯的邮箱，这里的密码并不是你平时登录邮箱的密码，而是通过邮箱的服务提供商那里设置的 `客户端授权密码`
5. 邮件服务器的监听端口， 不使用 `SSL 协议`  的填写 `25`；勾选 `使用SSL协议`的填写`465` 如下图所示：



![image-20180717092523066](assets/image-20180717092523066.png)

6. 就是通知邮件的邮箱地址。
7. 可以添加测试按钮，发送测试邮件。
8. 此处看到这个信息，表示配置正确。



**系统设置--设置SSH 远程服务器地址及其配置**

需要安装 `Publish over SSH` 插件。

如下方式可以检查目前都安装了哪些插件

![image-20180718164835164](assets/image-20180718164835164.png)

 此插件可以实现远程自动部署，就是可以通过 `Jenkins` 主机，远程连接到 应用服务器，之后把需要部署的应用程序部署到应用服务器上.

`Jenkins` 和 应用服务器的 SSH 连接认证，支持 密码和 密钥两种方式。

这里演示使用密钥的认证方式和远程应用服务器进行认证连接。



首先需要在 `jenkins` 主机上操作，让应用服务器对 `jenkins` 主机信任，以便让 jenkins 主机可以免密码登录到 应用服务器上。



第一步，现在 `jenkins` 主机上建立自己的密钥对儿

```python
[root@jenkins ~]# ssh-keygen
# 执行以上命令后，一路按 回车 键即可把自己的密钥对创建成功
```



第二步，拷贝 `jenkins` 主机的公钥到应用服务器上

还是在 `jenkins` 主机上操作

```python
[root@jenkins ~]# ssh-copy-id yangge@10.18.44.86
# yangge  是远程应用服务器上应用程序的属主用户，就是应用服务器将会使用 yangge 这个用户进行启动相关应用程序，比如 nginx、tomcat 等。
# 10.18.44.86 是远程应用服务器的 ip
```



完成以上两步后就可以配置 `Publish over SSH`了

`系统管理`-->`系统设置` --> `Publish overSSH`

首先配置 `jenkins` 主机的私钥, 此处也有两种方式

a. 配置 `jenkins` 主机 `root` 用户的私钥路径，但是需要把私钥复制到 `jenkins` 程序的家目录下，这里是 `/var/lib/jenkins/`

下面我是把私钥拷贝到 `/var/lib/jenkins/.ssh/` 下了

```bash
[root@jenkins ~]# c
[root@jenkins ~]# cp ~/.ssh/id_rsa /var/lib/jenkins/.ssh/

修改文件属主和权限:
[root@jenkins ~]# cd /var/lib/jenkins/.ssh/
[root@jenkins .ssh]# chown jenkins.jenkins id_rsa
[root@jenkins .ssh]# chmod 600 id_rsa
```

之后把这个路径 配置在 页面中



![image-20180718175547194](assets/image-20180718175547194.png)

b.  另一种方式是把私钥的内容之间粘贴到 `key` 配置项的密钥框里

![image-20180718180041284](assets/image-20180718180041284.png)



接着就可以配置远程应用服务器的信息了

点击 `添加按钮`即可，此处可以添加多个，但是需要给这些应用服务器分别建立信任关系。



![image-20180718174111641](assets/image-20180718174111641.png)



部分设置项说明

- `Passphrase`：密码（私钥的保护密码，如果你设置了）

- `SSH Server Name`：这个连接项的名字（自定义的）

- `Hostname`：需要ssh 连接的远程应用服务器ip地址

- `Username`：远程应用服务器的用户名，这个用户名应该已经和 `jenkins` 主机建立的信任关系

- `Remote Directory`：远程应用服务器的应用程序部署的目录

  > 注意： 这里的目录会作为此服务器代码存放到根目录，之后你
  >
  > 需要把 `Maven` 打好的包传到此应用服务器中，就是相对于这个目录
  >
  > 来指的具体的位置的。比如目前指定的是 `/app/code`，在构建任务中，指定构建后的 `*.jar` 包传到目录 `/student` 目录，实际在此应用服务器中的完整路径是 `/app/code/student/` 目录下。

- `Use password authentication, or use a different key`：使用密码验证(使用密码验证时，需要打开处)

配置完成后可点击`Test Configuration`测试到目标主机的连接，出现`success`则成功连接

![image-20180718180942337](assets/image-20180718180942337.png)



最后别忘记点击页码下方的 `保存` 按钮

![image-20180718181237140](assets/image-20180718181237140.png)



**系统管理--全局工具配置**

![5](./assets/5.png)



**全局工具配置--配置jdk**

先在 `jenkins` 主机上找到 `java` 的安装路径

```bash
[root@jenkins ~]# echo $JAVA_HOME
/usr/local/jdk1.8.0_171
```



之后在页面上配置

![image-20180718181640390](assets/image-20180718181640390.png)

把安装的路径粘贴到页面中的 `JAVA_HOME`  配置框内，再点击 `Save` 按钮

![image-20180718181747402](assets/image-20180718181747402.png)



**全局工具配置--配置maven**

配置方法和思路同上

![7](./assets/7.png)

#### 配置Credentials

在Gitlab上创建一个==Jenkins==用户：

![image-20181117134035204](assets/image-20181117134035204-2433235.png)

![image-20181117134108540](assets/image-20181117134108540-2433268.png)

![image-20181117134140401](assets/image-20181117134140401-2433300.png)






![cred1](./assets/jenkins_credentials01.png)

并将Jenkins用户加入到相应的组(Group) 
![cred2](./assets/jenkins_credentials02.png)

在Jenkins中添加相关的Credentials: 
![cred3](./assets/jenkins_credentials03.png)

将Gitlab中Jenkins用户的username 和密码填入Credentials中： 
![cred4](./assets/jenkins_credentials04.png)

![image-20181117141347506](assets/image-20181117141347506-2435227.png)

#### 创建Jenkins项目(例1)

![image-20181118121634463](assets/image-20181118121634463-2514594.png)



![image-20181118121817636](assets/image-20181118121817636-2514697.png)



**配置项目的 git 远程仓库地址 **

![image-20181118122611823](assets/image-20181118122611823-2515171.png)

**添加访问git server的ssh密钥(私钥)**

![image-20181117135934800](assets/image-20181117135934800-2434374.png)



![image-20181117140052596](assets/image-20181117140052596-2434452.png)



![image-20181117140417759](assets/image-20181117140417759-2434657.png)



**配置 `构建触发器`**

![image-20181118123502873](assets/image-20181118123502873-2515702.png)

> 这里是每周六， 每隔 3 分钟检查一次远程代码库，假如有远程代码库有新的更新提交, 就会自动挡触发构建。定义时间的方法和 linux 系统中一致。



**配置项目中的构建(使用maven构建包)**

![image-20181118123916397](assets/image-20181118123916397-2515956.png)



**配置项目中的构建后动作**

![image-20181118124449946](assets/image-20181118124449946-2516290.png)

![image-20181118125403668](assets/image-20181118125403668-2516843.png)

- 1. 这里填写的是打好包的路径，是相对路径，相对于工作空间目录的，工作空间默认是在 `$JENKINS_HOEM/workspace` 目录下。每次新建一个构建任务时，会在此目录下创建一个和任务名同名的目录（比如：`HelloMaven`），在此目录下存放从远程代码库拉取的源代码，并且构建完成的文件(比如`jar` 包)也会在 `HelloMaven/target` 目录下。

  2. 是在把打好包的文件传输到远程应用服务器时，不希望被创建的目录名。 这个目录名必须是在 `Source files` 选项中填写的路径最前面的部分中。

  3. 远程应用服务器的目录，这个目录假如没有会被自动创建，但是此目录是给相对路径，相对于之前在`系统设置`中的 `SSH Servers` 中配置的服务器端路径，如下图中的 `/opt/studentInfo`

  4. 指构建后在远程应用服务器上执行的命令。

     > 注意：这里执行命令的用户同样是以下图中的`Username` 里填写的用户的身份执行的。假如执行命令是执行一个在远程应用服务器上的一个脚本，那么路径和文件都必须存在，并且，脚本中的任何相对路径都会相对于此用户的家目录。





![image-20181118130754999](assets/image-20181118130754999-2517675.png)

**在配置完毕的项目上进行构建**
![image-20181118125520350](assets/image-20181118125520350-2516920.png)


**查看本次构建过程**
![13](./assets/13.png)

**构建报告**
![14](./assets/14.png)



**检查远程应用服务器**

以下就是构建完成后把 `target` 目录下的任何 `jar`包传输到远程应用服务器上的 `/opt/studentInfo/student`目录下的结果展示。

![image-20181118125848694](assets/image-20181118125848694-2517128.png)

#### 创建Jenkins项目(例2)

首先在使用git 为 code 添加Tag,如下所示：

``` shell
[eric@meteor maven01]$ vim src/main/java/inspiry/cn/maven/HelloWorld.java 
[eric@meteor maven01]$ git add . 
[eric@meteor maven01]$ git commit -m 'stable branch'
[stable 4cfc2e3] stable branch
 1 file changed, 1 insertion(+)
[eric@meteor maven01]$ git tag v1.0.2
[eric@meteor maven01]$ git tag
v1.0.2
[eric@meteor maven01]$ git push -u origin stable
Counting objects: 17, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (4/4), done.
Writing objects: 100% (9/9), 583 bytes | 0 bytes/s, done.
Total 9 (delta 2), reused 0 (delta 0)
remote: 
remote: To create a merge request for stable, visit:
remote:   http://192.168.60.119/plat-sp/maven01/merge_requests/new?merge_request%5Bsource_branch%5D=stable
remote: 
To git@192.168.60.119:plat-sp/maven01.git
* [new branch]      stable -> stable
Branch stable set up to track remote branch stable from origin.
[eric@meteor maven01]$ 
[eric@meteor maven01]$ git branch
  master
* stable
[eric@meteor maven01]$ git push origin v1.0.2
Total 0 (delta 0), reused 0 (delta 0)
To git@192.168.60.119:plat-sp/maven01.git
 * [new tag]         v1.0.2 -> v1.0.2
[eric@meteor maven01]$ 
```
![git_tag1](./assets/git_tag1.png)

然后在gitlab中可以查看相关的Tag:
![git_tag2](./assets/git_tag2.png)

然后添加Jenkins项目时设置如下：
![proj1](./assets/project01.png)

选择“参数化构建过程”，如下所示：
![proj2](./assets/project02.png)

指定gitlab 仓库时使用http方式，并选择相关包含读取权限的credentials，如下所示：
![proj3](./assets/project03.png)

在构建环境中选择“在构建前删除workspace”
![proj6](./assets/project06.png)

构建过程选择全局设置的MAVEN名称，并指定参数，如下所示：
![proj4](./assets/project04.png)

构建后将target/*.jar 包推到SSH server 的指定目录下，并执行相关脚本或shell语句，如下所示：
![proj5](./assets/project05.png)

选择项目构建时，指定需要构建的Tag，如下所示：
![build1](./assets/build01.png)

构建后结果如下所示：
![build2](./assets/build02.png)







