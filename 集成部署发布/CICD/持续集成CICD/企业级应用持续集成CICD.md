# 企业 CI/CD 持续集成/交付/发布

## 一、Git、Github、Gitlab的区别

Git是版本控制系统，Github是在线的基于Git的代码托管服务。 GitHub是2008年由Ruby on Rails编写而成。GitHub同时提供付费账户和免费账户。这两种账户都可以创建公开的代码仓库，只有付费账户可以创建私有的代码仓库。 Gitlab解决了这个问题, 可以在上面创建免费的私人repo。 

## 二、Git 介绍

Git是一个开源的分布式版本控制系统，用于敏捷高效地处理任何或小或大的项目。

Git 是 Linus Torvalds 为了帮助管理 Linux 内核开发而开发的一个开放源码的版本控制软件。

Git 与常用的版本控制工具 CVS, Subversion 等不同，它采用了分布式版本库的方式，不必服务器端软件支持。

------

### 1、Git 与 SVN 区别

GIT不仅仅是个版本控制系统，它也是个内容管理系统(CMS),工作管理系统等。

如果你是一个具有使用SVN背景的人，你需要做一定的思想转换，来适应GIT提供的一些概念和特征。

Git 与 SVN 区别点：

- 1、GIT是分布式的，SVN不是：这是GIT和其它非分布式的版本控制系统，例如SVN，CVS等，最核心的区别。
- 2、GIT把内容按元数据方式存储，而SVN是按文件：所有的资源控制系统都是把文件的元信息隐藏在一个类似.svn,.cvs等的文件夹里。
- 3、GIT分支和SVN的分支不同：分支在SVN中一点不特别，就是版本库中的另外的一个目录。
- 4、GIT没有一个全局的版本号，而SVN有：目前为止这是跟SVN相比GIT缺少的最大的一个特征。
- 5、GIT的内容完整性要优于SVN：GIT的内容存储使用的是SHA-1哈希算法。这能确保代码内容的完整性，确保在遇到磁盘故障和网络问题时降低对版本库的破坏。

### 2、Git工作流程

git工作流程

　　一般工作流程如下：

- 克隆 Git 资源作为工作目录。
- 在克隆的资源上添加或修改文件。 
- 如果其他人修改了，你可以更新资源。
- 在提交前查看修改。
- 提交修改。
- 在修改完成后，如果发现错误，可以撤回提交并再次修改并提交。

 　　Git 的工作流程示意图：

![img](assets/805129-20160710102658467-1520443599.png)

git的工作区、暂存区和版本库

　　基本概念：

- **工作区：**就是你在电脑里能看到的目录。
- **暂存区：**英文叫stage, 或index。一般存放在"git目录"下的index文件（.git/index）中，所以我们把暂存区有时也叫作索引（index）。
- **版本库：**工作区有一个隐藏目录.git，这个不算工作区，而是Git的版本库。

　　工作区、版本库中的暂存区和版本库之间的关系的示意图：

![img](assets/805129-20160710103123608-1172715931.jpg)

　　图中左侧为工作区，右侧为版本库。在版本库中标记为 "index" 的区域是暂存区（stage, index），标记为 "master" 的是 master 分支所代表的目录树。 

　　图中我们可以看出此时 "HEAD" 实际是指向 master 分支的一个"游标"。所以图示的命令中出现 HEAD 的地方可以用 master 来替换。 

　　图中的 objects 标识的区域为 Git 的对象库，实际位于 ".git/objects" 目录下，里面包含了创建的各种对象及内容。 

　　当对工作区修改（或新增）的文件执行 "git add" 命令时，暂存区的目录树被更新，同时工作区修改（或新增）的文件内容被写入到对象库中的一个新的对象中，而该对象的ID被记录在暂存区的文件索引中。 

　　当执行提交操作（git commit）时，暂存区的目录树写到版本库（对象库）中，master 分支会做相应的更新。即 master 指向的目录树就是提交时暂存区的目录树。 

　　当执行 "git reset HEAD" 命令时，暂存区的目录树会被重写，被 master 分支指向的目录树所替换，但是工作区不受影响。 

　　当执行 "git rm --cached <file>" 命令时，会直接从暂存区删除文件，工作区则不做出改变。 

　　当执行 "git checkout ." 或者 "git checkout -- <file>" 命令时，会用暂存区全部或指定的文件替换工作区的文件。这个操作很危险，会清除工作区中未添加到暂存区的改动。 

　　当执行 "git checkout HEAD ." 或者 "git checkout HEAD <file>" 命令时，会用 HEAD 指向的 master 分支中的全部或者部分文件替换暂存区和以及工作区中的文件。这个命令也是极具危险性的，因为不但会清除工作区中未提交的改动，也会清除暂存区中未提交的改动。

## 三、Git 常用方法

### 1、 客户端安装 git

##### 1、CentOS7 yum安装 Git

如果你使用的系统是 Centos/RedHat 安装命令为：

```shell
yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel
yum -y install git-core

git --version
git version 1.8.3.1
```

##### 2、CentOS7源码安装

我们也可以在官网下载源码包来安装，最新源码包下载地址：<https://git-scm.com/download>

安装指定系统的依赖包：

```
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel
```

解压安装下载的源码包：

```
tar -zxf git-1.7.2.2.tar.gz
cd git-1.7.2.2
make prefix=/usr/local all
make prefix=/usr/local install
```

------

##### 3、Windows 平台上安装

在 Windows 平台上安装 Git 同样轻松，有个叫做 msysGit 的项目提供了安装包，可以到 GitHub 的页面上下载 exe 安装文件并运行：

安装包下载地址：<https://gitforwindows.org/>

![20140127131250906](assets/20140127131250906.jpg)

完成安装之后，就可以使用命令行的 git 工具（已经自带了 ssh 客户端）了，另外还有一个图形界面的 Git 项目管理工具。

在开始菜单里找到"Git"->"Git Bash"，会弹出 Git 命令窗口，你可以在该窗口进行 Git 操作。

------

##### 4、Mac 平台上安装

在 Mac 平台上安装 Git 最容易的当属使用图形化的 Git 安装工具，下载地址为：

<http://sourceforge.net/projects/git-osx-installer/>

安装界面如下所示：

![18333fig0107-tn](assets/18333fig0107-tn.png)



------

### 2、Git 配置

Git 提供了一个叫做 git config 的工具，专门用来配置或读取相应的工作环境变量。

这些环境变量，决定了 Git 在各个环节的具体工作方式和行为。这些变量可以存放在以下三个不同的地方：

- `/etc/gitconfig` 文件：系统中对所有用户都普遍适用的配置。若使用 `git config` 时用 `--system` 选项，读写的就是这个文件。
- `~/.gitconfig` 文件：用户目录下的配置文件只适用于该用户。若使用 `git config` 时用 `--global` 选项，读写的就是这个文件。
- 当前项目的 Git 目录中的配置文件（也就是工作目录中的 `.git/config` 文件）：这里的配置仅仅针对当前项目有效。每一个级别的配置都会覆盖上层的相同配置，所以 `.git/config` 里的配置会覆盖 `/etc/gitconfig` 中的同名变量。

在 Windows 系统上，Git 会找寻用户主目录下的 .gitconfig 文件。主目录即 $HOME 变量指定的目录，一般都是 C:\Documents and Settings\$USER。

此外，Git 还会尝试找寻 /etc/gitconfig 文件，只不过看当初 Git 装在什么目录，就以此作为根目录来定位。

### 3、Git 用户信息

配置个人的用户名称和电子邮件地址：

```
git config --global user.name "jjcoder"
git config --global user.email test@qq.com
```

如果用了 **--global** 选项，那么更改的配置文件就是位于你用户主目录下的那个，以后你所有的项目都会默认使用这里配置的用户信息。

如果要在某个特定的项目中使用其他名字或者电邮，只要去掉 --global 选项重新配置即可，新的设定保存在当前项目的 .git/config 文件里。

### 4、文本编辑器

设置Git默认使用的文本编辑器, 一般可能会是 Vi 或者 Vim。如果你有其他偏好，比如 Emacs 的话，可以重新设置：:

```shell
git config --global core.editor emacs
```

### 5、差异分析工具

还有一个比较常用的是，在解决合并冲突时使用哪种差异分析工具。比如要改用 vimdiff 的话：

```shell
git config --global merge.tool vimdiff
```

Git 可以理解 kdiff3，tkdiff，meld，xxdiff，emerge，vimdiff，gvimdiff，ecmerge，和 opendiff 等合并工具的输出信息。

当然，你也可以指定使用自己开发的工具，具体怎么做可以参阅第七章。

### 6、查看配置信息

要检查已有的配置信息，可以使用 git config --list 命令：

```
$ git config --list
http.postbuffer=2M
user.name=runoob
user.email=test@runoob.com
```

有时候会看到重复的变量名，那就说明它们来自不同的配置文件（比如 /etc/gitconfig 和 ~/.gitconfig），不过最终 Git 实际采用的是最后一个。

这些配置我们也可以在 **~/.gitconfig** 或 **/etc/gitconfig** 看到，如下所示：

```
vim ~/.gitconfig 
```

显示内容如下所示：

```
[http]
    postBuffer = 2M
[user]
    name = git
    email = test@git.com
```

也可以直接查阅某个环境变量的设定，只要把特定的名字跟在后面即可，像这样：

```
$ git config user.name
git
```

### 2、客户机连接gitlab的方式

#### 1、ssh链接

```
客户机上产生公钥上传到gitlab的SSH-Keys里，git clone下载和git push上传都没问题，这种方式很安全
```

#### 2、http链接（两种方式实现）

##### (1) 修改代码里的.git/config文件添加登录用户名密码

```
cd .git
cat config
[core]
repositoryformatversion = 0
filemode = true
bare = false
logallrefupdates = true
[remote "origin"]
fetch = +refs/heads/*:refs/remotes/origin/*
url = http://username:password@git@172.17.0.39:sauser/ansible.git
[branch "master"]
remote = origin
merge = refs/heads/master
```

##### (2) 执行命令设置登录用户和密码

```
1.cd到根目录，执行git config --global credential.helper store命令
  执行之后会在.gitconfig文件中多添加以下选项
  [credential]         
  		helper = store
2.之后cd到项目目录，执行git pull命令，会提示输入账号密码。
  输完这一次以后就不再需要，并且会在根目录生成一个.git-credentials文件
  git pull 
  Username for 'http://172.17.0.39:sauser/ansible.git': 
  xxxx@xxxx.com Password for 'https://xxxx@xxxx.com@172.17.0.39:sauser/ansible.git':
3.cat .git-credentials
  https://Username:Password@git.oschina.net
4.之后pull/push代码都不再需要输入账号密码了
```

### 3、设定本机用户名，绑定邮箱，让远程服务器知道机器的身份

```
git config --global user.name "user_name" 
git config --global user.email "XXXXX@XX.com"
```

### 4、本地项目与远程服务器项目之间的交互

#### 1、如果你没有最新的代码，希望从头开始

```
Create a new repository
git clone git@XXX.git     // 这里是项目的地址（可从项目主页复制），将远程服务器的内容完全复制过来 
cd BGBInspector_V01       // clone 之后进入该项目的文件夹 
touch　README.md          // 新建readme文件 
git add README.md         // 将新的文件添加到git的暂存区 
git commit -m ‘Its note：add a readme file’ // 将暂存区的文件提交到某一个版本保存下来，并加上注释 
git push -u origin master // 将本地的更改提交到远程服务器
```

#### 2、如果你已经有一个新版代码，希望直接把本地的代码替换到远程服务器

```
Existing folder or git repository
cd existing_folder          // 进入代码存在的文件夹，或者直接在该文件夹打开
git bash git init           // 初始化 
git remote add origin git@XXX.git  // 添加远程项目地址（可从项目主页复制） 
git add .                   // 添加该文件夹中所有的文件到git的暂存区 
git commit -m ‘note’        // 提交所有代码到本机的版本库 
git push -u origin master   // 将本地的更改提交到远程服务器
```

```
git 中clone过来的时候，git不会对比本地和服务器的文件，也就不会有冲突，
建议确定完全覆盖本地的时候用clone，不确定会不会有冲突的时候用 git pull，将远程服务器的代码download下来
```

#### 3、常用的git 命令 

```
git init                      //初始化 
git add main.cpp              //将某一个文件添加到暂存区 
git add .                     //将文件夹下的所有的文件添加到暂存区 
git commit -m ‘note‘          //将暂存区中的文件保存成为某一个版本 
git log                       //查看所有的版本日志 
git status                    //查看现在暂存区的状况 
git diff                      //查看现在文件与上一个提交-commit版本的区别 
git reset --hard HEAD^        //回到上一个版本 
git reset --hard XXXXX        //XXX为版本编号，回到某一个版本 
git pull origin master        //从主分支pull到本地 
git push -u origin master     //从本地push到主分支 
git pull                      //pull默认主分支 
git push                      //push默认主分支 ...
```

### 5、版本穿梭

#### 1、版本回退

```
用git log命令查看：
每一个提交的版本都唯一对应一个commit版本号，
使用git reset命令退到上一个版本：
git reset --hard HEAD^
```

```
git reflog                    //查看命令历史，以便确定要回到哪个版本
git reset --hard commit_id    //比如git reset --hard 3628164（不用全部输入，输入前几位即可）
```

#### 2、git分支管理

##### 1、创建分支    

```
git checkout -b dev     // 创建dev分支，然后切换到dev分支
git checkout            // 命令加上-b参数表示创建并切换，相当于以下两条命令：
git branch dev git checkout dev
git branch              // 命令查看当前分支,
git branch              // 命令会列出所有分支，当前分支前面会标一个*号
git branch * dev   master
git add readme.txt git commit -m "branch test"  //  在dev分支上正常提交.
```

##### 2、分支切换:

```
git checkout master     // 切换回master分支
查看一个readme.txt文件，刚才添加的内容不见了，因为那个提交是在dev分支上，而master分支此刻的提交点并没有变  
```

##### 3、合并分支

```
git merge dev           // 把dev分支的工作成果合并到master分支上
git merge               // 命令用于合并指定分支到当前分支。
合并后，再查看readme.txt的内容，就可以看到，和dev分支的最新提交是完全一样的。
```

```
注意到上面的Fast-forward信息，Git告诉我们，这次合并是“快进模式”，也就是直接把master指向dev的当前提交，所以合并速度非常快。
当然，也不是每次合并都能Fast-forward，我们后面会讲其他方式的合并。
```

```
git branch -d dev       // 删除dev分支了：
删除后，查看branch，就只剩下master分支了.
```

#### 3、解决冲突

```
git checkout -b feature1        //  创建新的feature1分支
修改readme.txt最后一行，改为：
Creating a new branch is quick AND simple.
git add readme.txt             //  在feature1分支上提交
git commit -m "AND simple"
git checkout master            // 切换到master分支
Switched to branch 'master' Your branch is ahead of 'origin/master' by 1 commit.
Git还会自动提示我们当前master分支比远程的master分支要超前1个提交。
在master分支上把readme.txt文件的最后一行改为：
Creating a new branch is quick & simple.
git add readme.txt 
git commit -m "& simple"
现在，master分支和feature1分支各自都分别有新的提交
这种情况下，Git无法执行“快速合并”，只能试图把各自的修改合并起来，但这种合并就可能会有冲突，我们试试看：
git merge feature1 Auto-merging readme.txt CONFLICT (content): 
Merge conflict in readme.txt Automatic merge failed; 
fix conflicts and then commit the result.
```

```
readme.txt文件存在冲突，必须手动解决冲突后再提交。
git status 可以显示冲突的文件;
直接查看readme.txt的内容：
Git is a distributed version control system.
Git is free software distributed under the GPL. 
Git has a mutable index called stage. 
Git tracks changes of files. 
<<<<<<< HEAD Creating a new branch is quick & simple. ======= Creating a new branch is quick AND simple. >>>>>>> feature1
Git用<<<<<<<，=======，>>>>>>>标记出不同分支的内容，我们修改后保存再提交：
git add readme.txt  
git commit -m "conflict fixed" 
[master 59bc1cb] conflict fixed
最后，删除feature1分支：
git branch -d feature1 Deleted branch feature1 (was 75a857c).
```

## 四、本地 Git 服务器

```
[root@localhost ~]# useradd git
[root@localhost ~]# passwd git
[root@localhost ~]# mkdir /git-root/
[root@localhost ~]# cd /git-root/
[root@localhost git-root]# git init --bare shell.git
Initialized empty Git repository in /git-root/shell.git/
注意：
git init 和 git init –bare 的区别:
使用--bare选项时,不再生成.git目录,而是只生成.git目录下面的版本历史记录文件,这些版本历史记录文件也不再存放在.git目录下面,而是直接存放在版本库的根目录下面.
用"git init"初始化的版本库用户也可以在该目录下执行所有git方面的操作。但别的用户在将更新push上来的时候容易出现冲突。
使用”git init –bare”方法创建一个所谓的裸仓库，之所以叫裸仓库是因为这个仓库只保存git历史提交的版本信息，而不允许用户在上面进行各种git操作，如果你硬要操作的话，只会得到下面的错误（”This operation must be run in a work tree”）这个就是最好把远端仓库初始化成bare仓库的原因

[root@localhost git-root]# chown -R git:git shell.git
[root@localhost git-root]# su - git
[git@localhost ~]$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/git/.ssh/id_rsa): Created directory '/home/git/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/git/.ssh/id_rsa.
Your public key has been saved in /home/git/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:fWnqJTR7uMvajcOELlrcz/cGxZHtLZbPfo7ROT3in5Q git@localhost.localdomain
The key's randomart image is:
+---[RSA 2048]----+
|               o |
|              o .|
|             . +.|
|         .   .* o|
|        S.+ +o + |
|     . ....B.  .*|
|      o..o= oo.Eo|
|     .. .*oBo +o*|
|    .. ...X+.+++o|
+----[SHA256]-----+
[git@localhost ~]$ 
[git@localhost ~]$ cd .ssh/
[git@localhost .ssh]$ cp id_rsa.pub authorized_keys
[git@localhost .ssh]$ vim authorized_key
[git@localhost .ssh]$ logout
[root@localhost git-root]# usermod -s /usr/bin/git-shell git
[root@localhost git-root]# cd
[root@localhost ~]# ssh-copy-id git@192.168.1.102
[root@localhost ~]# cd /opt/
[root@localhost opt]#  git clone git@192.168.1.102:/git-root/shell.git
Cloning into 'shell'...
The authenticity of host '192.168.1.102 (192.168.1.102)' can't be established.
ECDSA key fingerprint is SHA256:mytNPhHxff0nDGl3LGorCnwAscYkBONVssV44ntQFjw.
ECDSA key fingerprint is MD5:a4:30:b9:1c:35:4a:3b:9c:e5:3d:24:7c:62:26:c7:35.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.1.102' (ECDSA) to the list of known hosts.
warning: You appear to have cloned an empty repository.
[root@localhost opt]# ls
rh  shell
[root@localhost opt]# cd shell/
[root@localhost shell]# vim test1.sh
[root@localhost shell]# git add test1.sh
[root@localhost shell]# git commit -m 'first commit'
[master (root-commit) 33c5fbf] first commit
 1 file changed, 2 insertions(+)
 create mode 100644 test1.sh
[root@localhost shell]# git push origin master
Counting objects: 3, done.
Writing objects: 100% (3/3), 230 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To git@192.168.1.102:/git-root/shell.git
 * [new branch]      master -> master
[root@localhost shell]# 
```

## 五、Github 远程仓库

1、github.com 注册账户

2、在github上创建仓库

3、生成本地ssh key

```shell
[root@localhost ~]# ssh-keygen -t rsa -C 'meteor@163.com' # 邮箱要与github上注册的相同
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:RiE6UR1BtzV5avyE2uz6TNPsVHa2D2eHprghrJEkd/g meteor@163.com
The key's randomart image is:
+---[RSA 2048]----+
|    ..oo=o. o.   |
|     o ..o o...  |
|    o   . .. +   |
|     . o    = .  |
|    . + S  = o  =|
|     + *  . oo.=o|
|      o E ..o B.+|
|       o . =.* +o|
|      .   +++ . .|
+----[SHA256]-----+
[root@localhost ~]#
[root@localhost ~]# cat .ssh/id_rsa.pub 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVThfq4brrlsPGtAknVB0TLPx+7Dd3qlxTbSIrUOsGC5Y8JuNqVTlIntZB4oNj8cSQrWvec9CKm0a8o7WwaJIiqpxurz+YpQHP2KbapftKIxsX4hPf/z+p0El1U6arQa35/xmNsq+cJLH/bDdRG+EMDhuCBmjVZOlLj/hEdeIT6s56AnnCkaWoF+sq58KCF7Tk54jRbs/YiyE4SN7FuA70r+07sA/uj0+lmuk4E190KtQUELhjX/E9stivlqiRhxnKvVUqXDywsjfM8Rtvbi4Fg9R8Wt9fpd4QwnWksYUoR5qZJFYXO4hSZrUnSMruPK14xXjDJcFDcP2eHIzKgLD1 meteor@163.com
```
4、复制以上的公钥，在github 中添加ssh key

5、测试

```shell
[root@localhost ~]# yum install git
........
[root@localhost ~]# ssh -T git@github.com
The authenticity of host 'github.com (13.250.177.223)' can't be established.
RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
RSA key fingerprint is MD5:16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'github.com,13.250.177.223' (RSA) to the list of known hosts.
Hi meteor! You've successfully authenticated, but GitHub does not provide shell access.
[root@localhost ~]#
```
8、连接远程仓库听方法（创建一个测试存储库）
![it_remote_metho](./assets/git_remote_method.png)

```shell
# 在github网站新建一个仓库，命名为linux
~~~
 cd /opt
 mkdir linux
 cd linux
~~~
# git初始化，然后做第一个基本的git操作(需要在github上创建存储库)
git init
touch README
git add README
git commit -m 'first commit'
git remote add origin git@github.com:userhub/linux.git
~~~
# 若出现origin已经存在的错误，删除origin
[root@jinch2 linux]# git remote rm origin
# 现在继续执行push到远端
~~~
[root@jinch2 linux]# git remote add origin git@github.com:userhub/linux.git
[root@jinch2 linux]# git push -u origin master
Counting objects: 3, done.
Writing objects: 100% (3/3), 205 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To git@github.com:fakehydra/linux-.git
 * [new branch]      master -> master
分支 master 设置为跟踪来自 origin 的远程分支 master。
# 注意
# 设置存储库链接
git remote set-url origin git@github.com:userhub/linux.git
# 如果push失败，合并分支到 master 再push
git pull --rebase origin master
```

## 六、Gitlab Server 部署

### 1、环境准备

```
1.系统版本：CentOS7.4
2.Gitlab版本：gitlab-ee 11.0.1
3.初始化系统环境
4.关闭防火墙
[root@localhost ~]#  systemctl stop iptables firewalld
[root@localhost ~]#  systemctl disable iptables firewalld
5.开启邮件服务
[root@vm1 ~]# systemctl start postfix
[root@vm1 ~]# systemctl enable postfix
6.关闭SELinux
[root@localhost ~]#  sed -ri '/SELINUX=/cSELINUX=disabled' /etc/selinux/config
[root@localhost ~]#  setenforce 0           # 临时关闭SELinux
[root@localhost ~]#  reboot
```

### 2、部署Gitlab 

```
1.安装Gitlab社区版/企业版
2.安装gitlab依赖包
[root@localhost ~]# yum install -y curl openssh-server openssh-clients postfix cronie policycoreutils-python
# gitlab-ce 10.x.x以后的版本需要依赖policycoreutils-python

3.开启postfix，并设置开机自启
[root@localhost ~]# systemctl start postfix;systemctl enable postfix

4.选择添加yum源安装gitlab(根据需求配置源)
（1）添加阿里源
# vim /etc/yum.repos.d/gitlab-ce.repo
[gitlab-ce]
name=gitlab-ce
baseurl=http://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7
Repo_gpgcheck=0
Enabled=1
Gpgkey=https://packages.gitlab.com/gpg.key

（2） 添加清华源
# vim gitlab-ce.repo
[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el$releasever/
gpgcheck=0
enabled=1

# vim gitlab-ee.repo
[gitlab-ee]
name=Gitlab EE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ee/yum/el$releasever/
gpgcheck=0
enabled=1

# vim runner_gitlab-ci-multi-runner.repo
[runner_gitlab-ci-multi-runner]
name=runner_gitlab-ci-multi-runner
baseurl=https://packages.gitlab.com/runner/gitlab-ci-multi-runner/el/7/$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packages.gitlab.com/runner/gitlab-ci-multi-runner/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[runner_gitlab-ci-multi-runner-source]
name=runner_gitlab-ci-multi-runner-source
baseurl=https://packages.gitlab.com/runner/gitlab-ci-multi-runner/el/7/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packages.gitlab.com/runner/gitlab-ci-multi-runner/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

(3) 添加官方源
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

5.安装包下载
https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/
https://mirrors.tuna.tsinghua.edu.cn/gitlab-ee/yum/el7/

6.根据需要选择ce/ee
[root@localhost ~]# yum -y install gitlab-ce                    # 自动安装最新版
[root@localhost ~]# yum -y install gitlab-ce-x.x.x				# 安装指定版本Gitlab

[root@localhost ~]# yum -y install gitlab-ce 
warning: gitlab-ce-10.7.2-ce.0.el7.x86_64.rpm: Header V4 RSA/SHA1 Signature, key ID f27eab47: NOKEY
Preparing...                          ################################# [100%]
Updating / installing...
   1:gitlab-ce-10.7.2-ce.0.el7        ################################# [100%]
It looks like GitLab has not been configured yet; skipping the upgrade script.

       *.                  *.
      ***                 ***
     *****               *****
    .******             *******
    ********            ********
   ,,,,,,,,,***********,,,,,,,,,
  ,,,,,,,,,,,*********,,,,,,,,,,,
  .,,,,,,,,,,,*******,,,,,,,,,,,,
      ,,,,,,,,,*****,,,,,,,,,.
         ,,,,,,,****,,,,,,
            .,,,***,,,,
                ,*,.
  


     _______ __  __          __
    / ____(_) /_/ /   ____ _/ /_
   / / __/ / __/ /   / __ `/ __ \
  / /_/ / / /_/ /___/ /_/ / /_/ /
  \____/_/\__/_____/\__,_/_.___/
  

Thank you for installing GitLab!
GitLab was unable to detect a valid hostname for your instance.
Please configure a URL for your GitLab instance by setting `external_url`
configuration in /etc/gitlab/gitlab.rb file.
Then, you can start your GitLab instance by running the following command:
  sudo gitlab-ctl reconfigure

For a comprehensive list of configuration options please see the Omnibus GitLab readme
https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md
```

###3、配置 Gitlab

#### 1、查看Gitlab版本

```
[root@localhost ~]# head -1 /opt/gitlab/version-manifest.txt
gitlab-ce 10.1.1
```

#### 2、Gitlab 配置文登录链接

``` shell
#设置登录链接
[root@localhost ~]# vim /etc/gitlab/gitlab.rb
***
## GitLab URL
##! URL on which GitLab will be reachable.
##! For more details on configuring external_url see:
##! https://docs.gitlab.com/omnibus/settings/configuration.html#configuring-the-external-url-for-gitlab
# 没有域名，可以设置为本机IP地址
external_url 'http://172.17.0.61'
***
[root@localhost ~]# grep "^external_url" /etc/gitlab/gitlab.rb
external_url 'http://172.17.0.61'     #绑定监听的域名或IP
```

#### 3、初始化 Gitlab (第一次使用配置时间较长)

``` shell
 [root@localhost ~]# gitlab-ctl reconfigure   
.....
```

#### 4、启动 Gitlab 服务

``` shell
[root@vm1 ~]# gitlab-ctl start
ok: run: gitaly: (pid 22896) 2922s
ok: run: gitlab-monitor: (pid 22914) 2921s
ok: run: gitlab-workhorse: (pid 22882) 2922s
ok: run: logrotate: (pid 22517) 2987s
ok: run: nginx: (pid 22500) 2993s
ok: run: node-exporter: (pid 22584) 2974s
ok: run: postgres-exporter: (pid 22946) 2919s
ok: run: postgresql: (pid 22250) 3047s
ok: run: prometheus: (pid 22931) 2920s
ok: run: redis: (pid 22190) 3053s
ok: run: redis-exporter: (pid 22732) 2962s
ok: run: sidekiq: (pid 22472) 3005s
ok: run: unicorn: (pid 22433) 3011s
[root@vm1 ~]# 
[root@vm1 ~]# lsof -i:80
COMMAND   PID       USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
nginx   22500       root    7u  IPv4  50923      0t0  TCP *:http (LISTEN)
nginx   22501 gitlab-www    7u  IPv4  50923      0t0  TCP *:http (LISTEN)
[root@vm1 ~]# 
```

#### 5、Gitlab 设置 HTTPS 方式

```
如果想要以上的 https 方式正常生效使用，则需要把 letsencrypt 自动生成证书的配置打开，这样在执行重
新让配置生效命令 (gitlab-ctl reconfigure) 的时候会自动给域名生成免费的证书并自动在 gitlab 自带的
 nginx 中加上相关的跳转配置，都是全自动的，非常方便。
letsencrypt['enable'] = true 
letsencrypt['contact_emails'] = ['caryyu@qq.com']     # 这应该是一组要添加为联系人的电子邮件地址
```

#### 6、Gitlab 添加smtp邮件功能

``` shell
[root@vm1 ~]# vim /etc/gitlab/gitlab.rb
postfix 并非必须的；根据具体情况配置，以 SMTP 的为例配置邮件服务器来实现通知；参考配置如下： 
### Email Settings  
gitlab_rails['gitlab_email_enabled'] = true  
gitlab_rails['gitlab_email_from'] = 'system.notice@qq.com'  
gitlab_rails['gitlab_email_display_name'] = 'gitlab.notice'  
gitlab_rails['gitlab_email_reply_to'] = 'system.notice@qq.com'  
gitlab_rails['gitlab_email_subject_suffix'] = 'gitlab'  
### GitLab email server settings 
###! Docs: https://docs.gitlab.com/omnibus/settings/smtp.html 
###! **Use smtp instead of sendmail/postfix.**   
gitlab_rails['smtp_enable'] = true  
gitlab_rails['smtp_address'] = "smtp.qq.com"  
gitlab_rails['smtp_port'] = 465  
gitlab_rails['smtp_user_name'] = "system.notice@qq.com"  
gitlab_rails['smtp_password'] = "xxxxx"   # 注意需要授权码
gitlab_rails['smtp_domain'] = "qq.com"  
gitlab_rails['smtp_authentication'] = "login"  
gitlab_rails['smtp_enable_starttls_auto'] = true  
gitlab_rails['smtp_tls'] = true

[root@vm1 ~]# grep -P "^[^#].*smtp_|user_email|gitlab_email" /etc/gitlab/gitlab.rb
gitlab_rails['gitlab_email_enabled'] = true
gitlab_rails['gitlab_email_from'] = 'username@domain.cn'
gitlab_rails['gitlab_email_display_name'] = 'Admin'
gitlab_rails['gitlab_email_reply_to'] = 'usernamei@domain.cn'
gitlab_rails['gitlab_email_subject_suffix'] = '[gitlab]'
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.exmail.qq.com"
gitlab_rails['smtp_port'] = 25 
gitlab_rails['smtp_user_name'] = "username@domain.cn"
gitlab_rails['smtp_password'] = "password"
gitlab_rails['smtp_domain'] = "domain.cn"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false
user['git_user_email'] = "username@domain.cn"

[root@vm1 ~]# gitlab-ctl reconfigure  #修改配置后需要初始化配置
......

[root@vm1 ~]# gitlab-ctl stop
ok: down: gitaly: 0s, normally up
ok: down: gitlab-monitor: 1s, normally up
ok: down: gitlab-workhorse: 0s, normally up
ok: down: logrotate: 1s, normally up
ok: down: nginx: 0s, normally up
ok: down: node-exporter: 1s, normally up
ok: down: postgres-exporter: 0s, normally up
ok: down: postgresql: 0s, normally up
ok: down: prometheus: 0s, normally up
ok: down: redis: 0s, normally up
ok: down: redis-exporter: 1s, normally up
ok: down: sidekiq: 0s, normally up
ok: down: unicorn: 1s, normally up

[root@vm1 ~]# gitlab-ctl start
ok: run: gitaly: (pid 37603) 0s
ok: run: gitlab-monitor: (pid 37613) 0s
ok: run: gitlab-workhorse: (pid 37625) 0s
ok: run: logrotate: (pid 37631) 0s
ok: run: nginx: (pid 37639) 1s
ok: run: node-exporter: (pid 37644) 0s
ok: run: postgres-exporter: (pid 37648) 1s
ok: run: postgresql: (pid 37652) 0s
ok: run: prometheus: (pid 37660) 1s
ok: run: redis: (pid 37668) 0s
ok: run: redis-exporter: (pid 37746) 0s
ok: run: sidekiq: (pid 37750) 1s
ok: run: unicorn: (pid 37757) 0s
```

#### 7、Gitlab 发送邮件测试

``` shell
[root@vm1 ~]# gitlab-rails console 
Loading production environment (Rails 4.2.10)
irb(main):001:0>  Notify.test_email('luoyinsheng@outlook.com', 'Message Subject', 'Message Body').deliver_now

Notify#test_email: processed outbound mail in 2219.5ms

Sent mail to user@destination.com (2469.5ms)
Date: Fri, 04 May 2018 15:50:10 +0800
From: Admin <username@domain.cn>
Reply-To: Admin <username@domain.cn>
To: user@destination.com
Message-ID: <5aec10b24cfaa_93933fee282db10c162d@vm1.mail>
Subject: Message Subject
Mime-Version: 1.0
Content-Type: text/html;
 charset=UTF-8tt
Content-Transfer-Encoding: 7bit
Auto-Submitted: auto-generated
X-Auto-Response-Suppress: All

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html><body><p>Message Body</p></body></html>

=> #<Mail::Message:70291731344240, Multipart: false, Headers: <Date: Fri, 04 May 2018 15:50:10 +0800>, <From: Admin <username@domain.cn>>, <Reply-To: Admin <username@domain.cn>>, <To: user@destination.com>, <Message-ID: <5aec10b24cfaa_93933fee282db10c162d@vm1.mail>>, <Subject: Message Subject>, <Mime-Version: 1.0>, <Content-Type: text/html; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <Auto-Submitted: auto-generated>, <X-Auto-Response-Suppress: All>>
irb(main):002:0>quit 
```

### 3、**gitlab的使用**

**在浏览器中输入 http://192.168.60.119/ ，然后 change password:  ，并使用root用户登录 即可 (后续动作根据提示操作)**

#### 1、gitlab 命令行修改密码

```
gitlab-rails console production
irb(main):001:0>user = User.where(id: 1).first      # id为1的是超级管理员
irb(main):002:0>user.password = 'yourpassword'      # 密码必须至少8个字符
irb(main):003:0>user.save!                          # 如没有问题 返回true
exit 												# 退出
```

#### 2、gitlab服务管理

```
gitlab-ctl start                        # 启动所有 gitlab 组件；
gitlab-ctl stop                         # 停止所有 gitlab 组件；
gitlab-ctl restart                      # 重启所有 gitlab 组件；
gitlab-ctl status                       # 查看服务状态；
gitlab-ctl reconfigure                  # 初始化服务；
vim /etc/gitlab/gitlab.rb               # 修改默认的配置文件；
gitlab-ctl tail                         # 查看日志；
```

3、登陆 Gitlab

![1](./assets/1.png)

**如果需要手工修改nginx的port ，可以在gitlab.rb中设置 nginx['listen_port'] = 8000 ，然后再次 gitlab-ctl reconfigure即可**

**登录 gitlab 如下所示(首次登陆设置 root 密码)：**
![1](./assets/2.1.png)

**创建项目组 group ，组名为plat-sp ,如下所示: **
![1](./assets/2.2.png)

![1](./assets/3.png)

**去掉用户的自动注册功能（安全）：**
admin are -> settings -> Sign-up Restrictions 去掉钩钩，然后拉到最下面保存，重新登录
![1](./assets/4.png)

## 七、公司 Gitlab 开发代码提交处理流程

  PM（项目主管/项目经理）在gitlab创建任务，分配给开发人员
  开发人员领取任务后，在本地使用git clone拉取代码库
  开发人员创建开发分支（git checkout -b dev），并进行开发
  开发人员完成之后，提交到本地仓库（git commit ）
  开发人员在gitlab界面上申请分支合并请求（Merge request）
  PM在gitlab上查看提交和代码修改情况，确认无误后，确认将开发人员的分支合并到主分支（master）
  开发人员在gitlab上Mark done确认开发完成，并关闭issue。这一步在提交合并请求时可以通过描述中填写"close #1"等字样，可以直接关闭issue

**创建项目管理用户Tompson如下所示：**
![1](./assets/5.png)
同样的方法，再创建Eric 、Hellen 用户。用户添加完毕后，gitlab会给用户发一封修改密码的邮件，各用户需要登录自己的邮箱，并点击相关的链接，设置新密码。

**将用户添加到组中，指定Tompson为本组的owner：**
![1](./assets/6.png)

**同样的方法将用户Eric、Hellen也添加到组中，并指定他们为Developer：**
![1](./assets/7.png)

**使用 Tompson 用户的身份与密码登录到 gitlab 界面中，并创建项目 Project ，如下所示：**
![1](./assets/10.png)

**指定项目的存储路径和项目名称，如下所示**
![1](./assets/11.png)

![1](./assets/12.png)

**为项目创建Dev分支，如下所示：**
![1](./assets/13.png)

![1](./assets/14.png)

**在 client 上添加Tompson的用户：**

``` shell
[root@vm2 ~]# useradd Tompson
[root@vm2 ~]# useradd Hellen
[root@vm2 ~]# useradd Eric
[root@vm2 ~]# useradd test
[root@vm2 ~]# su - Tompson
[Tompson@vm2 ~]$ ssh-keygen -C 222@qq.com
Generating public/private rsa key pair.
Enter file in which to save the key (/home/Tompson/.ssh/id_rsa): 
Created directory '/home/Tompson/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/Tompson/.ssh/id_rsa.
Your public key has been saved in /home/Tompson/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:SAoAH2zSxqEJqVgKKrxM5XMi6tKe61JMRdwMhwBNIrE Tompson@domain.cn
The key's randomart image is:
+---[RSA 2048]----+
|XX==o=.          |
|*BOo+.o          |
|E*=.  .          |
|*+.= + .         |
|=oo = . S        |
|.oo              |
|.o               |
|o...             |
|.+=.             |
+----[SHA256]-----+
[Tompson@vm2 ~]$ cat .ssh/id_rsa.pub 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ8cRGHej+sZzlmK36W5MUXMLOGdTwFI9Jj44mGuabZCrlYW4GDpL6ppezN+Sur0wHtnKonYJzm8ntqS0S0UHyaPPQPl9Mrs/6Z4VrXZ/4RlqHdWeSrmOwCBQld0l8HvrmP4TyGHrOreO8uZqimd/Z+OiMqnYRZzENX11Pti/Px5g1MtJcoCi9uLtF42QYrt1X/fzAyPU9C5/5ZUq4Jln3EF20bzcA52oAzZIl0jrhI0TeTeW6zYq+KxdHGshL+qG7+Ne+akPOe4Ma5BQjcMZ2dQ2kbGuozXmLT8RDcj9YRKceQsUdTI71lJpwrWKGn8Vhra0EaK3hgoTuvMYaGfOF Tompson@domain.cn
```

**将Tompson的公钥复制到gitlab中： 使用Tompson用户的身份与密码登录到gitlab界面中，然后在ssh-key中添加 相关的key ，如下所示：**
![1](./assets/8.png)

![1](./assets/9.png)

**为Tompson用户配置git ，如下所示：**

``` shell
[Tompson@vm2 ~]$ git config --global user.email "222@qq.com"
[Tompson@vm2 ~]$ git config --global user.name "tom"

[Tompson@vm2 ~]$ git clone git@192.168.60.119:plat-sp/chathall.git
Cloning into 'chathall'...
The authenticity of host '192.168.60.119 (192.168.60.119)' can't be established.
ECDSA key fingerprint is SHA256:CDxAQmj6gUkIxB6XUofbZ853GuPM5LS2QO4a5dD7jRo.
ECDSA key fingerprint is MD5:4e:20:72:a7:46:c6:d7:5d:bb:9d:ce:c3:f3:da:43:f9.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.60.119' (ECDSA) to the list of known hosts.
remote: Counting objects: 3, done.
remote: Total 3 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (3/3), done.
[Tompson@vm2 ~]$ 
[Tompson@vm2 ~]$ cd chathall/
[Tompson@vm2 chathall]$ ls
Readme.txt
[Tompson@vm2 chathall]$
```

**创建一下新文件，添加内容，并提交到master分支:**

``` shell
[Tompson@vm2 chathall]$ vim test.sh
[Tompson@vm2 chathall]$ cat test.sh 
#!/bin/bash
echo "gitlab test"
[Tompson@vm2 chathall]$ git add . 
[Tompson@vm2 chathall]$ git commit -m '201805101649'
[master 80edf6b] 201805101649
 1 file changed, 2 insertions(+)
 create mode 100644 test.sh
[Tompson@vm2 chathall]$ 
[Tompson@vm2 chathall]$ git push -u origin master 
Counting objects: 4, done.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 305 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To git@192.168.60.119:plat-sp/chathall.git
   4611654..80edf6b  master -> master
Branch master set up to track remote branch master from origin.
[Tompson@vm2 chathall]$ 
```

**使用Eric用户登录，并clone 项目，如下所示：**

``` shell
[root@vm2 ~]# su - Eric
[Eric@vm2 ~]$ ssh-keygen -C Eric@domain.cn
Generating public/private rsa key pair.
Enter file in which to save the key (/home/Eric/.ssh/id_rsa): 
Created directory '/home/Eric/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/Eric/.ssh/id_rsa.
Your public key has been saved in /home/Eric/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:VZaJvjA5SJZEB+yuRpDBNHCECCZ5R8X0DYcNE0f1B6E Eric@domain.cn
The key's randomart image is:
+---[RSA 2048]----+
|*O=..B*o**+o+oo. |
|*.+.. *o.*oooo . |
| . + + ..oo E . .|
|  o   o =..    . |
|   . .  S+ .     |
|    . .   .      |
|   . .           |
|    o            |
|   .             |
+----[SHA256]-----+

[Eric@vm2 ~]$ cat .ssh/id_rsa.pub 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxQcn4UjRW/5PT5witeV9+S2w8WK5ouawHxEF7s9wuWsT4pqhcu5BN74NG3CPaq1jJZnkV+aQsTw+60BAd1gOK0FBbKWxmohmE61n9vfpUT5igJ72t2jpXjfKwLIHw+Iq5yM4yUhkwSsoBuZkxYSEltnj8OvXaOlCDYnXuGBa9+xO8f5yVIcOtiwRvv+Y1PRRzSIcazPVZax9FLK26t1R4NPiY4xWkIJyK2OrKMeiaBBzyMfWzHdmsCWa51oSrYSmz3PDBXpzIBs3OdKxcaJs9Lc5u87YCV5RMUjLrPcA7nPK6crOabLXhz3d5GSYggMTOByQkyKOo7WlYpARCHOt/ Eric@domain.cn
[Eric@vm2 ~]$ 
```

**同样需要使用Eric用户登录gitlab web 界面，并添加相应的ssh-key。然后设置git ，并clone项目：**

``` shell
[Eric@vm2 ~]$ git config --global user.email "Eric@domain.cn"
[Eric@vm2 ~]$ git config --global user.name "Eric"
[Eric@vm2 ~]$ git clone git@192.168.60.119:plat-sp/chathall.git
Cloning into 'chathall'...
The authenticity of host '192.168.60.119 (192.168.60.119)' can't be established.
ECDSA key fingerprint is SHA256:CDxAQmj6gUkIxB6XUofbZ853GuPM5LS2QO4a5dD7jRo.
ECDSA key fingerprint is MD5:4e:20:72:a7:46:c6:d7:5d:bb:9d:ce:c3:f3:da:43:f9.
Are you sure you want to continue connecting (yes/no)? yes
remote: Counting objects: 6, done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 6 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (6/6), done.
[Eric@vm2 ~]$ 
```

**切换到dev分支，修改文件内容，并将新code提交到dev分支(Developer角色默认并没有提交master的权限)：**

``` shell
[Eric@vm2 chathall]$ git checkout dev 
Branch dev set up to track remote branch dev from origin.
Switched to a new branch 'dev'
[Eric@vm2 chathall]$ ls
Readme.txt  test.sh
[Eric@vm2 chathall]$ vim eric.sh 
[Eric@vm2 chathall]$ cat eric.sh
#!/bin/bash
echo "brahch test"
[Eric@vm2 chathall]$ git add . 
[Eric@vm2 chathall]$ git commit -m '201805101658'
[dev 6687039] 201805101658
 1 file changed, 1 insertion(+)
[Eric@vm2 chathall]$ git push -u origin dev 
Counting objects: 5, done.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 306 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
remote: 
remote: To create a merge request for dev, visit:
remote:   http://192.168.60.119/plat-sp/chathall/merge_requests/new?merge_request%5Bsource_branch%5D=dev
remote: 
To git@192.168.60.119:plat-sp/chathall.git
   80edf6b..6687039  dev -> dev
Branch dev set up to track remote branch dev from origin.
[Eric@vm2 chathall]$
[Eric@vm2 chathall]$ git checkout master 
Switched to branch 'master'
[Eric@vm2 chathall]$ git branch 
  dev
* master
[Eric@vm2 chathall]$
```

**使用Eric 用户登录gitlab web，在界面中 创建一个合并请求：**
![1](./assets/15.png)

**提交合并请求：**
![1](./assets/16.png)

**然后使用Tompson用户登录 gitlab web ，找到“合并请求” ，然后将dev分支合并到master分支，如下所示：**
![1](./assets/17.png)

![1](./assets/18.png)

## 八、Gitlab 备份与恢复

### 1、查看系统版本和软件版本

```
[root@localhost gitlab]# cat /etc/redhat-release 
CentOS Linux release 7.3.1611 (Core) 

[root@localhost gitlab]# cat /opt/gitlab/embedded/service/gitlab-rails/VERSION
8.15.4
```

### 2、数据备份

打开/etc/gitlab/gitlab.rb配置文件，查看一个和备份相关的配置项：

```
gitlab_rails['manage_backup_path'] = true
gitlab_rails['backup_path'] = "/data/gitlab/backups"
```

该项定义了默认备份出文件的路径，可以通过修改该配置，并执行 **gitlab-ctl reconfigure 或者 gitlab-ctl  restart** 重启服务生效。

执行备份命令进行备份

```
/opt/gitlab/bin/gitlab-rake gitlab:backup:create 
```

也可以添加到 crontab 中定时执行：

```
crontab -e
0 2 * * * bash /opt/gitlab/bin/gitlab-rake gitlab:backup:create
```

可以到/data/gitlab/backups找到备份包，解压查看，会发现备份的还是比较全面的，数据库、repositories、build、upload等分类还是比较清晰的。

设置备份保留时常，防止每天执行备份，肯定有目录被爆满的风险，打开/etc/gitlab/gitlab.rb配置文件，找到如下配置：

```
gitlab_rails['backup_keep_time'] = 604800
```

设置备份保留7天（7*3600*24=604800），秒为单位，如果想增大或减小，可以直接在该处配置，并通过gitlab-ctl restart 重启服务生效。

备份完成，会在备份目录中生成一个当天日期的tar包。

### 3、数据恢复

#### 1、安装部署 gitlab server

 具体步骤参见上面：gitlab server 搭建过程

#### 2、恢复 gitlab

打开/etc/gitlab/gitlab.rb配置文件，查看一个和备份相关的配置项：

```
gitlab_rails['backup_path'] = "/data/gitlab/backups"
```

修改该配置，定义了默认备份出文件的路径，并执行 **gitlab-ctl reconfigure 或者 gitlab-ctl  restart** 重启服务生效。

恢复前需要先停掉数据连接服务：

```
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq
```

如果是台新搭建的主机，不需要操作，理论上不停这两个服务也可以。停这两个服务是为了保证数据一致性。将老服务器/data/gitlab/backups目录下的备份文件拷贝到新服务器上的/data/gitlab/backups

```
[root@localhost gitlab]# rsync -avz 1530773117_2019_03_05_gitlab_backup.tar 192.168.95.135:/data/gitlab/backups/ 
```

注意权限：600权限是无权恢复的。 实验环境可改成了777，生产环境建议修改属主属组

```
[root@yunwei-test backups]# pwd
/data/gitlab/backups
[root@yunwei-test backups]# chown -R git.git 1530773117_2019_03_05_gitlab_backup.tar 
[root@yunwei-test backups]# ll
total 17328900
-rwxrwxrwx 1 git git 17744793600 Jul  5 14:47 1530773117_2018_07_05_gitlab_backup.tar
```

执行下面的命令进行恢复：后面再输入两次yes就完成恢复了。

```
gitlab-rake gitlab:backup:restore BACKUP=1530773117_2018_07_05_gitlab_backup.tar
注意：backups 目录下保留一个备份文件可直接执行
```

恢复完成后，启动刚刚的两个服务，或者重启所有服务，再打开浏览器进行访问，发现数据和之前的一致：

```
gitlab-ctl start unicorn
gitlab-ctl start sidekiq
或
gitlab-ctl restart
```

**注意：通过备份文件恢复gitlab必须保证两台主机的gitlab版本一致，否则会提示版本不匹配**

## 九、平滑发布与灰度发布

   **什么叫平滑：**在发布的过程中不影响用户的使用，系统不会因发布而暂停对外服务，不会造成用户短暂性无法访问；
   **什么叫灰度：**发布后让部分用户使用新版本，其它用户使用旧版本，逐步扩大影响范围，最终达到全部更新的发布方式 ；

灰度发布与平滑发布其实是关联的。当服务器的数量只有一台的时候，不存在灰度发布，一旦发布了就是所有用户都更新了，
所以这个时候只有平滑发布。当服务器数量大于一台的时候，只要每台服务器都能达到平滑发布的方式，然后设定好需要发布的服务器占比数量，就可以实现灰度发布了。

单台服务器的平滑发布模式：
    单机状态下，应用的持续服务主要依靠Nginx的负载均衡及自动切换功能；
    为了能够切换应用，需要在服务器中创建两个相同的独立应用，分配两个不同的端口，
    例如:app1,端口801; app2,端口802；
    在Nginx中，将app1,app2作为负载均衡加载：

```
    upstream myapp{
          server 127.0.0.1:801; //app1
          server 127.0.0.1:802; //app2
    }

    然后设置代理超时为1秒，以便在某个应用停止时及时切换到另一个应用：
server {
    listen 80;
    server_name localhost;
    location /{
    proxy_pass http://myapp;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_connect_timeout       1;
    proxy_read_timeout          1;
    proxy_send_timeout          1;
    }
}
    以上内容写在单独的配置文件中：/vhost/pub/pub_app.conf
    在nginx.conf里包含进去：
    include /vhost/*.conf;
```

​    现在系统会均衡地分配用户访问app1与app2。
​    接下来我们进行平滑发布，我们先把app1停止，然后将新版本发布到app1中：

```shell
    步骤1： 准备发布app1配置文件
    新做一个配置文件 pub_app1_down.conf,内容中把app1停止掉：
    upstream myapp{
          server 127.0.0.1:801 down; //app1
          server 127.0.0.1:802; //app2
    }
    
    将这个文件内容覆盖掉在原有的pub_app.conf
    cp -f /vhost/pub/pub_app1_down.conf /vhost/pub_app.conf


    步骤2：停止app1应用
    平滑重新加载一下nginx: 
    service nginx reload
    或者：
    /usr/local/nginx/sbin/nginx -s reload

    此时所有的请求都转到了app2了；

    步骤3：更新app1
    现在可以通过各种方式来更新应用了，例如：压缩包方式：
    wget http://version.my.com/appudate/myapp/myapp-v3.2.32.tar
    unzip -o -d /home/wwwroot/app1/ myapp-v3.2.32.tar
    其中：-o:不提示的情况下覆盖文件；-d:指定解压目录
    
    步骤3.5 内部测试
    如果需要的话，可以在这一步对app1进行内部测试，以确保应用的正确性；

    步骤4：准备发布app2配置文件；
    此时app1已经是最新版本的文件了，可以切换到app1来对外，

    创建一个新的nginx配置文件:pub_app2_down.conf，设置为app1对外,app2停止即可：
    
    upstream myapp{
          server 127.0.0.1:801; //app1
          server 127.0.0.1:802 down; //app2
    }

    将这个文件内容覆盖掉在原有的pub_app.conf
    cp -f /vhost/pub/pub_app2_down.conf /vhost/pub_app.conf

    步骤5：切换到app1新版本应用 
    平滑重新一下nginx: 
    service nginx reload
    或者：
    /usr/local/nginx/sbin/nginx -s reload

    此时所有的请求都转到了app1了，新版本开始运行；

    步骤6：更新app2
    与第3步一样，解压就可以了，这里可以省去下载过程
    unzip -o -d /home/wwwroot/app2/ myapp-v3.2.32.tar

    步骤7：恢复app1,app2同时对外：
    cp -f /vhost/pub/pub_app.conf /vhost/pub_app.conf
    
    平滑重新一下nginx: 
    service nginx reload
    或者：
    /usr/local/nginx/sbin/nginx -s reload

    至此，整个应用都已经更新。

    将各步骤中的脚本汇总一下：

    [pub.sh]
    #============ 平滑发布 v1.0 ===============
    #step 1
    cp -f /vhost/pub/pub_app1_down.conf /vhost/pub_app.conf
    
    #step 2
    service nginx reload
    
    #step 3
    wget http://version.my.com/appudate/myapp/myapp-v3.2.32.tar
    unzip -o -d /home/wwwroot/app1/ myapp-v3.2.32.tar
    
    #step 4
    cp -f /vhost/pub/pub_app2_down.conf /vhost/pub_app.conf
    
    #step 5
    service nginx reload
    
    #step 6
    unzip -o -d /home/wwwroot/app2/ myapp-v3.2.32.tar
    
    #step 7
    cp -f /vhost/pub/pub_app.conf /vhost/pub_app.conf
    service nginx reload
    #============ 平滑发布 v1.0  ===============    

    备注：也可以充分利用nginx的宕机检测，省去步骤1，2，4，5，7；
    简化后的脚本如下：

    [pub_mini.sh]
    #======== 简化版脚本 =============
    wget http://version.my.com/appudate/myapp/myapp-v3.2.32.tar
    unzip -o -d /home/wwwroot/app1/ myapp-v3.2.32.tar

    unzip -o -d /home/wwwroot/app2/ myapp-v3.2.32.tar
    #========= over ===========
    
# 实验 nginx 配置文件  （按要求创建网站根目录及修改 index.html 文件）
  upstream myapp{
          server 192.168.11.128:801;
          server 192.168.11.128:802;
    }  

    server {
        listen       80;
        server_name  myapp;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
	    proxy_pass http://myapp;
    	    proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_connect_timeout       1;
            proxy_read_timeout          1;
            proxy_send_timeout		    1;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }

    server {
        listen       801;
        server_name  app1;
        root         /usr/share/nginx/app1-html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
		index	index.html;
	}

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }

    server {
        listen       802;
        server_name  app2;
        root         /usr/share/nginx/app2-html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
		index 	index.html;
	}

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
```

多台服务器平滑发布模式：
    有了单台平滑发布模式的基础，多台服务器就简单了。
    每台服务器当作应用进行发布就可以了，由于nginx有宕机自动检测功能，
    只需要在每台服务器上先停止发布，然后更新文件，再启动就可以了；
    如果选择部分的服务器进行更新，那就是灰度了。

## 十、CentOS7 使用 Nexus3 搭建 maven 私服

### 1、Nexus3 简介

　　Maven是一个采用纯Java编写的开源项目管理工具, Maven采用了一种被称之为Project Object Model(POM)概念来管理项目，所有的项目配置信息都被定义在一个叫做POM.xml的文件中, 通过该文件Maven可以管理项目的整个生命周期，包括清除、编译，测试，报告、打包、部署等等。目前Apache下绝大多数项目都已经采用Maven进行管理. 而Maven本身还支持多种插件, 可以方便更灵活的控制项目, 开发人员的主要任务应该是关注商业逻辑并去实现它, 而不是把时间浪费在学习如何在不同的环境中去依赖jar包,项目部署等。
maven和ant都是软件构建工具（软件管理工具),maven比ant更加强大，已经取代了ant,jar包的声明式依赖描述。maven有jar包的仓库。svn是一个软件的版本控制工具，是一个协同开发工具。svn的仓库存放的是项目的源码，历史版本的备份，声明每次版本的修改情况。

　　私服是架设在局域网的一种特殊的远程仓库，目的是代理远程仓库及部署第三方构件。有了私服之后，当 Maven 需要下载构件时，直接请求私服，私服上存在则下载到本地仓库；否则，私服请求外部的远程仓库，将构件下载到私服，再提供给本地仓库下载。

　　![img](assets/1167086-20180825103130887-988863302.jpg)

**需求：**

公司没有maven私服，需要用用手动打jar包的方式添加依赖很不友好，所以需要搭建 Nexus3 私服。

### 2、搭建 maven 私服

1.下载maven压缩包  apache-maven-3.5.4-bin.tar.gz ,然后解压  tar -zxf apache-maven-3.5.4-bin.tar.gz

```
tar xf apache-maven-3.5.4-bin.tar.gz -C /usr/local/
cd /usr/local/
ln -s apache-maven-3.5.4/ maven

tar xf jdk-8u201-linux-x64.tar.gz -C /usr/local/
cd /usr/local/
ln -s jdk1.8.0_201/ java
```

2.添加环境变量

```
vi /etc/profile
```

在文件下方添加如下内容（这里的MAVEN_HOME需要改为你自己的maven解压目录）：

```
JAVA_HOME=/usr/local/java
export MAVEN_HOME=/usr/local/maven
export JRE_HOME=/usr/local/java/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$MAVEN_HOME/bin:$PATH
```

```
source /etc/profile
```

然后保存退出。

3.输入命令 mvn -version 看到如下内容说明安装成功了。

![img](assets/1167086-20180825104448130-1294323799.jpg)

### 3、部署 nexus3

#### 1、下载

由于专业版的nexus是收费的，所以我下载的是开源版 Nexus OSS,下载地址为 <https://www.sonatype.com/download-oss-sonatype>

![img](assets/1167086-20180825105031180-667090550.jpg)

点击红框区域即可下载得到文件nexus-3.13.0-01-unix.tar.gz，然后上传到服务器目录下，我的是/opt目录。

#### 2、解压

```
cd /usr/local
tar -zxf nexus-3.13.0-01-unix.tar.gz
```

解压后会多出两个目录，nexus-3.13.0-01和sonatype-work。

#### 3、启动

```
1 cd nexus-3.13.0-01/bin/
2 ./nexus start
```

![img](assets/1167086-20180825105844833-1628287044.jpg)

看到如图所示内容表明我们已经启动成功了，游览器输入http://localhost:8081即可访问。

**注意：**

启动后如果你立即访问可能发现什么都没有，不要急这个启动需要一定时间，**30秒后到1分钟后再尝试访问**，这个开始我以为出问题了。

![img](assets/1167086-20180825110836868-96057072.jpg)　

点击右上角的sign in登录，输入账户**admin**，密码**admin123**即可登录成功。

#### 4、仓库介绍

![img](assets/1167086-20180825111811784-1078214501.jpg)

按图中标识顺序点击，就可以看到有这些仓库，现在分别介绍它们，分为三种类型：

**proxy**：是远程仓库的代理。比如说在nexus中配置了一个central repository的proxy，当用户向这个proxy请求一个artifact，这个proxy就会先在本地查找，如果找不到的话，就会从远程仓库下载，然后返回给用户，相当于起到一个中转的作用。　　　　

**Hosted**：是宿主仓库，用户可以把自己的一些构件，deploy到hosted中，也可以手工上传构件到hosted里。比如说oracle的驱动程序，ojdbc6.jar，在central repository是获取不到的，就需要手工上传到hosted里，一般用来存放公司自己的jar包；
**Group**：是仓库组，在maven里没有这个概念，是nexus特有的。目的是将上述多个仓库聚合，对用户暴露统一的地址，这样用户就不需要在pom中配置多个地址，只要统一配置group的地址就可以了右边那个Repository Path可以点击进去，看到仓库中artifact列表。不过要注意浏览器缓存，**当你的项目希望在多个repository使用资源时就不需要多次引用了，只需要引用一个group即可**。

**maven-public：**maven-central、maven-release和maven-snapshot三个库的合集。

**maven-release：**用来存放release版本的jar包。

**maven-snapshot：**用来存放snapshot版本的jar包。

#### 5、向nexus3私服上传jar包

##### 1、准备环境

1.创建`3rd_part`库

使用默认用户`admin/admin123`登陆

![这里写图片描述](assets/20180303135907573.png)

点击左侧的`repository\repositories`后,在右侧点击`create repository`

![这里写图片描述](assets/20180303135924229.png)

然后选择`maven2(hosted)`,填写如下

![这里写图片描述](assets/20180303135934168.png)

跳到首页后选择`maven-public`

![这里写图片描述](assets/2018030313595437.png)

将`3rd_part`移到`member`中,即将`33rd_part`由`maven-public`管理，点击save

![这里写图片描述](assets/20180303140006220.png)

至此,创建仓库完成

2.创建`3rd_part`管理用户

创建用户: 用户名/密码-`dev/dev123`

![这里写图片描述](assets/20180303154313780.png)

##### 2、直接浏览器

使用`dev/dev123`登陆，点击`upload`

![这里写图片描述](assets/20180303141603409.png)

填写上传jar包的信息后，点击`upload`

![这里写图片描述](assets/20180303141617257.png)

可以看到已经上传成功

![这里写图片描述](assets/20180303141629234.png)



### 4、常见错误及解决办法

**问题一：上传报错误码405，Failed to transfer file。**

**解决方法：**仔细查看报错信息就会发现，是上传的url错了,反正原因就是repository的地址写错了。

**问题二：错误码401或者403**

**解决方法：**其实403错误就是“禁止访问”的含义，所以问题的根源肯定在授权上面。Maven在默认情况下会使用deployment帐号(默认密码deploy)登录的系统，但是关键的Nexus中Releases仓库默认的Deployment Policy是“Disable Redeploy”，所以无法部署的问题在这个地方，方法是将其修改为“Allow Redeploy”就可以了。401就是Maven settings.xml没有设置密码

## 十一、介绍 CI / CD

在本文档中，我们将概述持续集成，持续交付和持续部署的概念，以及GitLab CI / CD的介绍。

### 1、为什么要 CI / CD 方法简介

软件开发的连续方法基于自动执行脚本，以最大限度地减少在开发应用程序时引入错误的可能性。从新代码的开发到部署，它们需要较少的人为干预甚至根本不需要干预。

它涉及在每次小迭代中不断构建，测试和部署代码更改，从而减少基于有缺陷或失败的先前版本开发新代码的机会。

这种方法有三种主要方法，每种方法都根据最适合您的策略进行应用。

**持续集成**(Continuous Integration, CI):  代码合并，构建，部署，测试都在一起，不断地执行这个过程，并对结果反馈。

**持续交付**(Continuous Deployment, CD):　部署到测试环境、预生产环境。　

**持续部署**(Continuous Delivery, CD):  将最终产品发布到生成环境、给用户使用。

![img](assets/1352872-20180728202111287-1863851599.png)

##### 怎么理解持续集成、持续交付、持续部署呢？

### 1、持续集成

持续集成（英语：*Continuous integration*，缩写为 **CI**），一种软件工程流程，将所有工程师对于软件的工作复本，每天集成数次到共用主线（mainline）上。

这个名称最早由葛来迪·布区（Grady Booch）在他的布区方法中提出，但是他并没有提到要每天集成数次。之后成为极限编程（extreme programming，缩写为XP）的一部分。在测试驱动开发（TDD）的作法中，通常还会搭配自动单元测试。

持续集成的提出，主要是为了解决软件进行系统集成时面临的各项问题，极限编程称这些问题为集成地狱（integration hell）。

![img](assets/1190037-20171201191840448-1304029709.png)

持续集成主要是强调开发人员提交了新代码之后，立刻进行构建、（单元）测试。根据测试结果，我们可以确定新代码和原有代码能否正确地集成在一起。简单来讲就是：频繁地（一天多次）将代码集成到主干。

**持续集成目的在产生以下效益如：**

- 及早发现集成错误且由于修订的内容较小所以易于追踪，这可以节省项目的时间与成本。

- 避免发布日期的前一分钟发生混乱，当每个人都会尝试为他们所造成的那一点点不兼容的版本做检查。

- 当单元测试失或发生错误，若开发人员需要在不除错的情况下还原代码库到一个没有问题的状态，只需要放弃一小部分的更改 (因为集成的次数频繁)。

- 让 "最新" 的程序可保持可用的状态供测试、展示或发布用。

-  频繁的提交代码会促使开发人员创建模块化，低复杂性的代码。

-  防止分支大幅偏离主干。如果不是经常集成，主干又在不断更新，会导致以后集成的难度变大，甚至难以集成。

### 2、持续交付

持续交付（英语：*Continuous delivery*，缩写为 **CD**），是一种软件工程手法，让软件产品的产出过程在一个短周期内完成，以保证软件可以稳定、持续的保持在随时可以释出的状况。

它的目标在于让软件的建置、测试与释出变得更快以及更频繁。这种方式可以减少软件开发的成本与时间，减少风险。

![img](assets/1190037-20171201191850511-1013536040.png)

持续交付在持续集成的基础上，将集成后的代码部署到更贴近真实运行环境的「类生产环境」（*production-like environments*）中。比如，我们完成单元测试后，可以把代码部署到连接数据库的Staging 环境中更多的测试。如果代码没有问题，可以继续手动部署到生产环境中。

### 3、持续部署

持续部署（英语：*Continuous Deployment*，缩写为 **CD**），是持续交付的下一步，指的是代码通过评审以后，自动部署到生产环境。

有时候，持续部署也与持续交付混淆。持续部署意味着所有的变更都会被自动部署到生产环境中。持续交付意味着所有的变更都可以被部署到生产环境中，但是出于业务考虑，可以选择不部署。如果要实施持续部署，必须先实施持续交付。

![img](assets/1190037-20171201191900433-349001067.png)

持续部署即在持续交付的基础上，把部署到生产环境的过程自动化。

关键字： **CI/CD** 持续集成/持续交付/持续部署

## 十二、Jenkins CI/CD

### 1、 Jenkins CI/CD 流程图

![img](assets/1352872-20180728203103959-1827013182.png)

说明：这张图稍微更形象一点，上线之前先把代码git到版本仓库，然后通过Jenkins 如Java项目通过maven去构建，这是在非容器之前，典型的自动化的一个版本上线流程。那它有哪些问题呢？

如：它的测试环境，预生产环境，测试环境。会存在一定的兼容性问题 （环境之间会有一定的差异） 



![img](assets/1352872-20180728203917252-1861052346.png)

 

说明：它这里有一个docker harbor 的镜像仓库，通常会把你的环境打包为一个镜像，通过镜像的方式来部署。

 Jenkins持续集成01—Jenkins服务搭建和部署

### 2、介绍 Jenkins

#### 1、前言

 ![img](assets/1190037-20171201191826104-357945560.png)

Jenkins是一个用Java编写的开源的持续集成工具。在与Oracle发生争执后，项目从Hudson项目独立。

Jenkins提供了软件开发的持续集成服务。它运行在Servlet容器中（例如Apache Tomcat）。它支持软件配置管理（SCM）工具（包括AccuRev SCM、CVS、Subversion、Git、Perforce、Clearcase和RTC），可以执行基于Apache Ant和Apache Maven的项目，以及任意的Shell脚本和Windows批处理命令。Jenkins的主要开发者是川口耕介。Jenkins是在MIT许可证下发布的自由软件。

#### 2、Jenkins功能

1、持续的软件版本发布/测试项目。

2、监控外部调用执行的工作。

#### 3、Jenkins概念

　　Jenkins是一个功能强大的应用程序，允许**持续集成和持续交付项目**，无论用的是什么平台。这是一个免费的开源项目，可以处理任何类型的构建或持续集成。集成Jenkins可以用于一些测试和部署技术。Jenkins是一种软件允许持续集成。

#### 4、Jenkins目的

① 持续、自动地构建/测试软件项目。

② 监控软件开放流程，快速问题定位及处理，提提高开发效率。

#### 5、Jenkins特性

① 开源的java语言开发持续集成工具，支持CI，CD。

② 易于安装部署配置：可通过yum安装,或下载war包以及通过docker容器等快速实现安装部署，可方便web界面配置管理。

③ 消息通知及测试报告：集成RSS/E-mail通过RSS发布构建结果或当构建完成时通过e-mail通知，生成JUnit/TestNG测试报告。

④ 分布式构建：支持Jenkins能够让多台计算机一起构建/测试。

⑤ 文件识别:Jenkins能够跟踪哪次构建生成哪些jar，哪次构建使用哪个版本的jar等。

⑥ 丰富的插件支持:支持扩展插件，你可以开发适合自己团队使用的工具，如git，svn，maven，docker等。

#### 6、产品发布流程

产品设计成型 -> 开发人员开发代码 -> 测试人员测试功能 -> 运维人员发布上线

持续集成（Continuous integration，简称CI）

持续交付（Continuous delivery）

持续部署（continuous deployment） 

### 3、实验环境

操作系统：CentOS7.4

| IP         | 主机名     |
| ---------- | ---------- |
| 172.16.1.1 | jenkins    |
| 172.16.1.2 | web        |
| 172.16.1.3 | git/gitlab |

### 4、GIT 安装与基本使用

IP：10.0.0.3，git服务器进行如下操作

安装git：

```
yum install -y git
```

创建git用户并设置密码为123456（为开发人员拉代码时设置的用户）

```
useradd git
passwd git
```

创建仓库:

```
su - git  #切换到git用户下
mkdir -p repos/app.git  #在git用户家目录下创建一个repos目录，repos目录下创建各个项目的目录
cd repos/app.git
git --bare init #初始化仓库，如果不初始化，这仅仅就只是一个目录
#查看初始化后仓库信息
[git@git app.git]$ ls -a
. .. branches config description HEAD hooks info objects refs
```

配置完仓库后，我们需要找一台机器测试是否能够成功从仓库中拉取代码，或者上传代码到该仓库。

我们在IP：10.0.0.2，web服务器进行测试。

```
yum install -y git   #首先还是安装git
[root@web ~]# mkdir -p test
[root@web ~]# cd test
[root@web test]# git clone git@172.16.1.3:/home/git/repos/app.git  ##测试clone远端git仓库
[root@web test]# ls 
app
```

push测试：

```
[root@web app]# touch index.html
[root@web app]# git add .
[root@web app]# git commit -m "test" 
#第一次的话会有报错警告，说让配置邮箱和姓名。配置一下即可，或者直接执行给出的命令执行即可。
[root@web app]# git push origin master #提交到主分支（默认分支）
```

测试成功！！！！！！！！！！！！！！！！！！

补充：配置免秘钥

```
1）10.0.0.2服务器生成公钥
[root@web ~]# ssh-keygen
[root@web ~]# cat /root/.ssh/id_rsa.pub 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDmmIOOJCRjlcNyM9zQ4yNeSFgJhBYZUTHMJ3D6sy6IgyOQi/LW9IzBF8mVjmc9wBzQBzg9obCJ/2YiGtvgl00v8A6Clamx6XdQpHPbnVcgHznhEhaa5X0TONcyJ0/z9e8wdppafAsrgRYdpRcXfrPC7xlzDIRpjgWG9YEMzrqCDcWAoWLMYvr2GHwhFyJa5OpMNGH5NjaWJbzYlgdP5cwh/QX04xVZ0QKghQsol9HmbRbqJ8Hl8WrgDoy2BPE41XKEwR4drgUGCFXZDH4s9ZodC4zI76TWIyCeKKM0XbTNHRU6Cb6xWb/iFhpsa7m14A5usUH6RfIjzJBr3IcyUkk3 root@web

2）10.0.0.3git服务器进行配置
[git@git ~]$ mkdir -p .ssh
[git@git ~]$ chmod 700 .ssh/  #给予目录700权限
[git@git ~]$ vi .ssh/authorized_keys  #写入10.0.0.2服务器的公钥
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDmmIOOJCRjlcNyM9zQ4yNeSFgJhBYZUTHMJ3D6sy6IgyOQi/LW9IzBF8mVjmc9wBzQBzg9obCJ/2Yi
Gtvgl00v8A6Clamx6XdQpHPbnVcgHznhEhaa5X0TONcyJ0/z9e8wdppafAsrgRYdpRcXfrPC7xlzDIRpjgWG9YEMzrqCDcWAoWLMYvr2GHwhFyJa5OpM
NGH5NjaWJbzYlgdP5cwh/QX04xVZ0QKghQsol9HmbRbqJ8Hl8WrgDoy2BPE41XKEwR4drgUGCFXZDH4s9ZodC4zI76TWIyCeKKM0XbTNHRU6Cb6xWb/i
Fhpsa7m14A5usUH6RfIjzJBr3IcyUkk3 root@web
[git@git ~]$ chmod 600 .ssh/authorized_keys  #给予文件600权限
```

之后经测试，已经是免秘钥的了。

### 5、jenkins安装与使用

#### 1、jenkins安装

官网： [https://jenkins.io](https://jenkins.io/)

插件：http://updates.jenkins-ci.org/download/plugins/

安装：

##### 1、安装java环境（jenkins依赖java环境）

```
[root@jenkins tools]# ls          #查看解压包
jdk-8u45-linux-x64.tar.gz
[root@jenkins tools]# tar zxf jdk-8u45-linux-x64.tar.gz   #解压
[root@jenkins tools]# mv jdk1.8.0_45/ /usr/local/jdk1.8    #移动至指定目录
[root@jenkins tools]# vim /etc/profile    #配置环境变量
##jdk1.8
JAVA_HOME=/usr/local/java
export MAVEN_HOME=/usr/local/maven
export JRE_HOME=/usr/local/java/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$MAVEN_HOME/bin:$PATH
[root@jenkins tools]# source /etc/profile     #配置生效
[root@jenkins tools]# java -version       #查看java版本
java version "1.8.0_45"
Java(TM) SE Runtime Environment (build 1.8.0_45-b14)
Java HotSpot(TM) 64-Bit Server VM (build 25.45-b02, mixed mode)
```

##### 2、yum安装jenkins

```
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
##导入jenkins源
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
##导入jenkins官方证书
yum install -y jenkins
##安装jenkins（安装的是最新的LTS版本）

[root@jenkins ~]# rpm -ql jenkins   #查看yum都安装了哪些东西
/etc/init.d/jenkins
/etc/logrotate.d/jenkins
/etc/sysconfig/jenkins
/usr/lib/jenkins
/usr/lib/jenkins/jenkins.war
/usr/sbin/rcjenkins
/var/cache/jenkins
/var/lib/jenkins
/var/log/jenkins
```

**配置文件**

（1）查询yum下载Jenkins安装的文件

[root@jenkins ~]# rpm -ql jenkins

```
/etc/init.d/jenkins         # 启动文件
/etc/logrotate.d/jenkins    # 日志分割配置文件
/etc/sysconfig/jenkins      # jenkins主配置文件
/usr/lib/jenkins            # 存放war包目录
/usr/lib/jenkins/jenkins.war   # war 包 
/usr/sbin/rcjenkins         # 命令
/var/cache/jenkins          # war包解压目录 jenkins网页代码目录
/var/lib/jenkins            # jenkins 工作目录
/var/log/jenkins             # 日志
```

（2）修改配置文件

[root@jenkins ~]# vim /etc/sysconfig/jenkins

**配置文件说明**：

```
[root@Jenkins ~]# grep "^[a-Z]" /etc/sysconfig/jenkins
JENKINS_HOME="/var/lib/jenkins"    #jenkins工作目录
JENKINS_JAVA_CMD=""
JENKINS_USER="jenkins"       # jenkinx启动用户
JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true"
JENKINS_PORT="8080"          # 端口
JENKINS_LISTEN_ADDRESS=""
JENKINS_HTTPS_PORT=""
JENKINS_HTTPS_KEYSTORE=""
JENKINS_HTTPS_KEYSTORE_PASSWORD=""
JENKINS_HTTPS_LISTEN_ADDRESS=""
JENKINS_DEBUG_LEVEL="5"
JENKINS_ENABLE_ACCESS_LOG="no"
JENKINS_HANDLER_MAX="100"     # 最大连接
JENKINS_HANDLER_IDLE="20"
JENKINS_ARGS=""
```

##### 3、启动jenkins

首先需要修改一下启动脚本，文件在/etc/init.d/jenkins

因为jenkins的启动脚本默认java路径为：/usr/bin/java

但是我们新安装的java路径并不是在这个，所以我们需要新添加路径。如图下所示：

新路径地址为：/usr/local/jdk1.8/bin/java

![img](assets/1235834-20180831163720584-519105319.png)

接下来启动：

```
systemctl start jenkins
```

 查看

```
[root@jenkins ~]# ps -ef|grep jenkins
jenkins   16037      1  1 16:20 ?        00:00:13 /usr/local/jdk1.8/bin/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -DJENKINS_HOME=/var/lib/jenkins -jar /usr/lib/jenkins/jenkins.war --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war --daemon --httpPort=8080 --debug=5 --handlerCountMax=100 --handlerCountMaxIdle=20
root      16107   1215  0 16:39 pts/1    00:00:00 grep --color=auto jenkins
[root@jenkins ~]# netstat -lnutp|grep jenkins
[root@jenkins ~]# netstat -lnutp|grep 8080
tcp6       0      0 :::8080                 :::*                    LISTEN      16037/java
```

#### 2、jenkins配置（web页面）

##### 1、管理员密码获取

![img](assets/1235834-20180831164228925-1838027306.png)

```
[root@jenkins ~]# cat /var/lib/jenkins/secrets/initialAdminPassword
5d3f57bea6e546139fc48ea28f9d5ae5
```

##### 2、安装插件

![img](assets/1235834-20180831164323740-27120837.png)

但是却提示我已经离线，这是有问题的，虽然可以离线安装，但是我们这里最好还是选择在线安装：

解决上述问题方法：

1)    修改/var/lib/jenkins/updates/default.json

jenkins在下载插件之前会先检查网络连接，其会读取这个文件中的网址。默认是：

访问谷歌，这就很坑了，服务器网络又不能FQ，肯定监测失败呀，不得不说jenkins的开发者脑子锈了，所以将图下的google改为[www.baidu.com](http://www.baidu.com/)即可，更改完重启服务。

![img](assets/1235834-20180831164343689-623098101.png)

2)    修改/var/lib/jenkins/hudson.model.UpdateCenter.xml

该文件为jenkins下载插件的源地址，改地址默认jenkins默认为：https://updates.jenkins.io/update-center.json，就是因为https的问题，此处我们将其改为http即可，之后重启jenkins服务即可。

其他国内备用地址（也可以选择使用）：

https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json

http://mirror.esuni.jp/jenkins/updates/update-center.json

在修复完之后，我们发现离线问题已经解决，如图下所示：

![img](assets/1235834-20180831164430177-1121878419.png)

下面我们就可以愉快的安装插件了。

我们这里选择第二个选项----选择插件来安装，先安装默认的，之后有需要在安装其他的：

![img](assets/1235834-20180831164604366-1490737604.png)

如下图所示，正在安装一些我们选择了的默认插件：

![img](assets/1235834-20180831164621224-1822838670.png)

##### 3、创建第一个管理员用户

![img](assets/1235834-20180831164809108-286887060.png)

##### 4、url配置

之前版本没有这个选项，这里默认即可:

![img](assets/1235834-20180831164904559-733258059.png)

##### 5、安装完成

出现如下页面时，表示安装完成

![img](assets/1235834-20180831165003105-991154527.png)



​                                                             ![img](assets/1235834-20180831165018742-956350629.png)

这里面有很多配置，下面我们只介绍我们要用到的要修改的配置（之后案例会用到的）。我们不需要全部都配置，等需要什么的时候再去研究一下即可。

##### 6、web页面配置jdk、git、maven

系统管理->全局工具配置

jdk：可以自动安装，但是我们已经安装了，这里写入我们jdk的路径即可

![img](assets/1235834-20180831165049786-1605588288.png)

git:

![img](assets/1235834-20180831165130860-316104310.png)

maven：

![img](assets/1235834-20180831165146493-1904811526.png)

##### 7、jenkins 下载插件失败处理办法

jenkins 下载插件失败,提示：

```
java.io.IOException: Downloaded file /app/jenkins_home/plugins/jacoco.jpi.tmp does not match expected SHA-1, expected 'CtK02wHdFOxTutqhUQzmue6uvpg=', actual 'YGO05utKyaaFzpGCgCE95GS0WsU='
	at hudson.model.UpdateCenter.verifyChecksums(UpdateCenter.java:1783)
	at hudson.model.UpdateCenter.access$1100(UpdateCenter.java:147)
	at hudson.model.UpdateCenter$InstallationJob.replace(UpdateCenter.java:1934)
	at hudson.model.UpdateCenter$UpdateCenterConfiguration.install(UpdateCenter.java:1178)
	at hudson.model.UpdateCenter$DownloadJob._run(UpdateCenter.java:1653)
	at hudson.model.UpdateCenter$InstallationJob._run(UpdateCenter.java:1848)
	at hudson.model.UpdateCenter$DownloadJob.run(UpdateCenter.java:1624)
	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at hudson.remoting.AtmostOneThreadExecutor$Worker.run(AtmostOneThreadExecutor.java:110)
	at java.lang.Thread.run(Thread.java:745)
```

查找资料，说是中国源的问题。需要换个源就可以，换源的方法：

jenkins->系统管理->管理插件->高级
选择升级站点

把：http://updates.jenkins-ci.org/update-center.json

换成：http://mirror.esuni.jp/jenkins/updates/update-center.json

镜像地址查询：

http://mirrors.jenkins-ci.org/status.html 

### 6、Jenkins 用户权限管理

#### 1、 背景

针对开发、运维、测试针对不同角色进行不同权限划分，

基于插件： Role-based Authorization Strategy ，Authorize Project 来实现。

#### 2、 安装

安装该插件：

系统管理->管理插件-可选插件->搜索该插件选中直接安装即可。

 ![img](assets/1235834-20180831165508676-16362769.png)

#### 3、 开启该插件功能

系统管理->全局安全设置-授权策略->选中该插件功能即可->保存

 ![img](assets/1235834-20180831165538054-922830046.png)

#### 4、 实践

我们可以先将该功能关闭来进行实践测试。

1、策略改回原来的（全局安全配置）

![img](assets/1235834-20180831165635226-1917360681.png)

2、开启允许用户注册（全局安全配置）

![img](assets/1235834-20180831165700914-329576958.png)

3、注册一个新用户

![img](assets/1235834-20180831165719453-1979689954.png)

登录之后，其默认就是管理员用户，可以进行任何操作，如图下所示：

![img](assets/1235834-20180831165742247-244014865.png)

4、开启Role-Based Strategy

5、重新登录新创建test1用户，显示已经没有任何权限了。

![img](assets/1235834-20180831165853876-101591569.png)

#### 5、 权限划分

我们在安装Role-Based Strategy插件后，**系统管理** 中多了如图下所示的一个功能，用户权限的划分就是靠他来做的。

![img](assets/1235834-20180831165923312-691685234.png)

![img](assets/1235834-20180831165930038-36894234.png)

##### 1、Manage Roles（管理角色）

Manage Roles：管理角色，相当于针对角色赋予不同权限，然后在将该角色分配给用户。角色就相当于一个组。其里面又有Global roles（全局）、Project roles（项目）、Slave roles（），来进行不同划分。

默认如图下所示：

 ![img](assets/1235834-20180831170007658-2106612170.png)

Global roles：

默认是有一个admin用户的，是所有权限都有的，所有权限都是勾选了的。

接下来我们来添加一个角色：user

![img](assets/1235834-20180831170026530-949346396.png)

我们给其一个读的权限。

 

Project roles：

roles to add：表示项目角色

Pattern：是用来做正则匹配的（匹配的内容是Job(项目名)），比如说根据正则匹配到的项目项目角色就都有权限；

接下来我们新建一个ItemA项目角色，改项目角色一般我们给其构建、取消、读取、读取空间权限，一般配置这4个即可

![img](assets/1235834-20180831170046126-1725883669.png)

还可以在新建一个ItemB项目角色：

![img](assets/1235834-20180831170101681-1099638023.png)

Slave roles（奴隶角色）：节点相关的权限

roles to add：表示项目角色

Pattern：是用来做正则匹配的（匹配的内容是节点(slavej节点）），比如说根据正则匹配到的项目项目角色就都有权限；

![360截图168212206791118](assets/360截图168212206791118.png)

##### 2、Assigin roles（分配角色）

1.我们给予test1用户分配user角色，这样其就有manage roles中我们刚才创建的user角色的权限了。

![img](assets/1235834-20180831170141093-1106115356.png)

此时我们再去看test1用户，已有查看的权限了，如图下所示

![img](assets/1235834-20180831171312583-2109653620.png)

2、针对指定用户分配项目角色（一般最常用的就是针对不同用户进行项目角色分配）

比如将test1用户分配有ItemA项目角色，这样其就可以有刚才我们创建的ItemA项目角色正则匹配到的项目的权限了。

![img](assets/1235834-20180831171359961-22018225.png)

test2也为其分配一个ItemB项目角色

![img](assets/1235834-20180831171420831-1902633716.png)

此时我们可以在test1用户这里看到ItemA项目角色所匹配到的项目A-web1

![img](assets/1235834-20180831171437298-1904913991.png)

我们也可以在新建一个B-web1项目

同理test2用户这里看到ItemB项目角色所匹配到的项目B-web1

![img](assets/1235834-20180831171454823-363550384.png)

为了方便项目管理，我们可以对不同项目进行分类（借助视图）：

![img](assets/1235834-20180831171509279-1030579839.png)

分类完如图下所示：

![img](assets/1235834-20180831171525036-576038453.png)



### 7、Jenkins 参数化构建

#### 1、 背景

如果只是简单的构建，jenkins自己默认的插件可以做，但是如果我们想要在构建过程中有更多功能，比如说：选择性构建、传参、项目指定变量等等其他功能，基础的参数化构建可以实现一些简单功能，但是要想使用更多功能这时候我们就需要借助参数化构建来实现交互的功能。此处我们来借助以下插件来进行实现：

1)Extended Choice Parameter（更丰富的参数化构建插件）

2)Git Parameter

#### 2、Extended Choice Parameter

首先还是安装该插件，去管理插件里面进行安装

![img](assets/1235834-20180831171721299-2027054343.png)

实例2-1         练习

1、点项目配置

![img](assets/1235834-20180831171807151-657567536.png)

2、参数化构建中选择我们刚刚安装过的插件

![img](assets/1235834-20180831171825735-1550501382.png)

3、进行配置

​                                                             ![img](assets/1235834-20180831171852747-2039805021.png)

这里这个branch我们就相当于给其当做一个变量，然后来为其进行传参。

![img](assets/1235834-20180831171908041-686186905.png)

4、构建这里选择执行shell进行测试

![img](assets/1235834-20180831171925310-877234848.png)

![img](assets/1235834-20180831171931759-1794610138.png)

5、当我们再次选择构建时，可以发现刚才的一系列参数化配置已经生效

![img](assets/1235834-20180831171946619-1779475535.png)

6、比如构建test02

我们可以发现控制台的输出也是成功了的

![img](assets/1235834-20180831172008888-985342835.png)

7、数据来源我们也可以选择文件

在jenkins所在服务器进行如下操作：

```
[root@jenkins ~]# vim /opt/jenkins.property   #建立一个文件
abc=t1,t2,t3,t4
```

 web端配置：

![img](assets/1235834-20180831172044249-467635589.png)

进行测试：

构建前：（可以发现也是生效的）

![img](assets/1235834-20180831172105902-1561453754.png)

构建后查看结果：（也是成功的）

![img](assets/1235834-20180831172117350-824962931.png)

#### 3、Git Parameter

再用git时使用该插件是非常方便的。

##### 1、安装此插件

![img](assets/1235834-20180831172312057-1192977432.png)

##### 2、进行配置

在配置之前我们先来说一个坑，当我们在配置git中写了远端地址后，会有如下报错：

![img](assets/1235834-20180831172344503-595645026.png)

这是因为jenkins我们yum装的运行用户是jenkins用户，此处是jenkins用户去git仓库进行拉取，而jenkins用户的话默认是/bin/false的，不但不能登录，也没有git命令权限，所以肯定是失败的。

解决此问题两种办法：

1)更改jenkins用户为root用户；

2)更改jenkins用户为正常的普通用户/bin/bash，将其的公钥加入到git服务器的git用户中。

此处暂时先用第一种解决办法，更改jenkins的运行用户为root用户，通过如下方式进行更改：

将/etc/sysconfig/jenkins文件由![img](assets/1235834-20180831172403790-793357643.png)改为![img](assets/1235834-20180831172419499-231798333.png)

然后再重启即可。

##### 3、进行相关配置

![img](assets/1235834-20180905174228683-1325675254.png)

配置git仓库

![img](assets/1235834-20180905174238241-1229199729.png)

凭据这里有两种方式：

第一种：选择无

其实就是基于免秘钥的。

第二种：用户（其实就是git用户）

![img](assets/1235834-20180905174257903-1112577737.png)

接下里这一步做的：

当我们构建时给我们一个选择列表，这个变量是代表分支。有哪些分支传递给这个变量。

![img](assets/1235834-20180905174314569-1455405236.png)

##### 4、进行构建

1、我们发现列表中已经有了可选的分支

![img](assets/1235834-20180905174352937-817873860.png)

2、构建成功

![img](assets/1235834-20180905174410958-2125207362.png)

3、我们还可以新建一个分支，增添一些内容再来验证一下我们这个插件

```
[root@web app]# git branch 
* master
[root@web app]# git branch test
[root@web app]# git checkout test
Switched to branch 'test'
[root@web app]# git branch
  master
* test
[root@web app]# touch a
[root@web app]# git add .
[root@web app]# git commit -m "a"
[test c286460] a
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 a
[root@web app]# git push origin test
Counting objects: 3, done.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (2/2), 231 bytes | 0 bytes/s, done.
Total 2 (delta 0), reused 0 (delta 0)
To git@172.16.1.3:/home/git/repos/app.git
 * [new branch]      test -> test
```

jenkins构建查看：

![img](assets/1235834-20180905174449507-511735917.png)

可以发现已经有了我们新建的分支。

构建成功！！

![img](assets/1235834-20180905174509176-598896431.png)



### 8、Jenkins Master-Slave架构(扩展)

![img](assets/1235834-20180905174647968-1070498866.png)

jenkins的Master-slave分布式架构主要是为了解决jenkins单点构建任务多、负载较高、性能不足的场景。

Master/Slave相当于Server和agent的概念。Master提供web接口让用户来管理job和slave，job可以运行在master本机或者被分配到slave上运行构建。一个master（jenkins服务所在机器）可以关联多个slave用来为不同的job或相同的job的不同配置来服务。

#### 1、安装

**前提：slave所在服务器必须有java环境**

jenkins web端进行操作：

系统管理->管理节点->新建节点

1）进行基础配置，配置选项中的内容是可变的，根据情况来

![img](assets/1235834-20180905174740210-1910187239.png)

![img](assets/1235834-20180905174812065-1298673844.png)

注意这里需要配置凭据，也就是配置slave所在服务器用户和密码

![img](assets/1235834-20180905174833717-113155048.png)

之后保存，如果无误的话就会直接启动了，如图下所示是有问题的

 ![img](assets/1235834-20180905174858307-1689117384.png)

通过看输出日志，我们发现是jdk的问题，一般来说，其会判断slave所在服务器有没有jdk，如果有的话其就会进行检测（其自己回去几个路径下进行检查），如下图所示，就是没有检查到（因为jdk是我们自己装的，路径并不是默认的路径）。

![img](assets/1235834-20180905174933937-2072546466.png)

没有检查到的话其就会去oracle官网下载，来为slave所在服务器进行安装，但是因为中国的原因，被墙了，所以也会下载失败，最终就导致彻底失败了，失败如图下：

 ![img](assets/1235834-20180905175013098-1305201866.png)

有两种方法解决：推荐方法1：

方法1：

在配置时高级的选项里指定java路径：如下图所示：

![img](assets/1235834-20180905175036117-145610379.png)

方法2：

为java路径做一个软链接，保证jenkins可以检测到java。

```
[root@web ~]# ln -s /usr/local/jdk1.8/bin/java /usr/bin/java
[root@web ~]# ll /usr/bin/java 
lrwxrwxrwx 1 root root 26 Jul 25 17:33 /usr/bin/java -> /usr/local/jdk1.8/bin/java
```

 之后在看已经成功了！！！！！

![img](assets/1235834-20180905175117966-1877923320.png)

![img](assets/1235834-20180905175129896-1990617523.png)

并且我们也可以在slave所在服务器看到：

![img](assets/1235834-20180905175143501-1725798918.png)

jar包就是负责接收master任务的。

#### 2、配置

在项目job中进行配置：

可通过标签或者名称进行匹配（标签可在安装时配置）

![img](assets/1235834-20180905175239298-1454561108.png)

#### 3、构建

![img](assets/1235834-20180905175325125-311183582.png)

我们可以发现控制台的日志，其也是slave构建的

![img](assets/1235834-20180905175346873-1882059918.png)

之后查看构建完的工作目录，也有我们预想中的文件。

![img](assets/1235834-20180905175404104-944359554.png)

这样基本上就实现了借助jenkins的slave去构建job了。

目前我们是在slave构建也在slave上部署，之后我们可以通过脚本，比如借助rsync、ansible等部署在其他服务器上。

#### 4、扩展

我们也可以为我们的slave服务器在配置时候加上标签，这样也会方便我们选择，用法也不单单局限在一台服务器上，可以让多台slave去竞选。

### 9、Jenkins pipeline

#### 1、概览

![img](assets/1235834-20180905175950688-621991737.png)

#### 2、安装

在对jenkins进行初始化安装时，默认已经安装了jenkins的相关插件，如下图所示：

![img](assets/1235834-20180905180059074-2046998049.png)

#### 3、实操

新建任务：

![img](assets/1235834-20180905180134440-703318370.png)

编写pipeline脚本：

![img](assets/1235834-20180905180200172-202457638.png)

我们可以借助流水线语法去做。

test流水线脚本：

```
node {
   def mvnHome
   stage('git checkout') { // for display purposes
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'git@172.16.1.3:/home/git/repos/app.git']]])
   }
   stage('maven Build') {
        echo "maven build........."
   }
   stage('deploy') {
        echo "deploy..........."
   }
   stage('test') {
        echo "test..........."
   }
}
```

构建测试：

![img](assets/1235834-20180905180243809-1620313434.png)

可以去服务器上验证一下（git checkout）刚才拉取下来的代码：

![img](assets/1235834-20180905180256704-210794930.png)

 

补充：

我们也可以从我们的代码版本管理仓库中读取pipeline脚本（相当于将pipeline脚本放在仓库中）我们可以选择git。

首先我们需要将我们的pipeline脚本提交到我们新建的git仓库中

步骤再此忽略。

jenkins项目中需要进行如下配置：

其中脚本路径的配置，一定要和版本仓库中的路径相一致。

![img](assets/1235834-20180905180344737-1469717868.png)

之后我们如果要更改步骤，不需要再更改jenkins的步骤，直接更改文件即可。

补充：

此外我们之前的测试一直是在master上构建的，我们还可以通过在jenkinsfile中指定节点在相应节点去构建

具体在jenkinsfile的node后进行指定：

如下图所示：

![img](assets/1235834-20180905180411824-506078483.png)

格式为：node ("节点名称")

**具体配置详解请参考** https://jenkins.io/doc/book/pipeline/

### 10、Jenkins 构建邮件状态通知

#### 1、 前提

前提：

服务器开启邮箱服务：

![img](assets/1235834-20180905180750936-201397371.png)

#### 2、 基础配置

需要安装一个插件：

插件： Email Extension Plugin

进行配置：

系统管理->系统设置->

相关配置如下图：

图1：

![img](assets/1235834-20180905180920720-1267268825.png)

图2：

![img](assets/1235834-20180905181032556-219409886.png)

可以在此处进行测试发送！！！！检验配置是否正确

![img](assets/1235834-20180905181105795-859970074.png)

#### 3、 配置到项目中

步骤1：

在项目的配置中选择构建后操作

![img](assets/1235834-20180905181815334-1545576302.png)

步骤中选择我们对应的插件：

![img](assets/1235834-20180905181902914-1329981046.png)

填写发件人信息

![img](assets/1235834-20180905181920357-2050627859.png)

此处配置构建成功发送邮件：

![img](assets/1235834-20180905181944795-1066960449.png)

可以观察到控制台也有邮件发送成功输出：

![img](assets/1235834-20180905182332647-1761846010.png)

检查实际是否接收到邮件：

![img](assets/1235834-20180905182350656-147180758.png)



### 11、Jenkins 流水线自动化发布PHP项目

#### 1、前提

**环境为**：lnmp

**PHP项目**：wordpress（此处我们下载一个wordpress的源码。将其模拟为我们的代码上传到我们的git仓库）

```
git config --global user.name "Administrator"
git config --global user.email '18611142071@163.com'
git status
git clone git@192.168.152.138:plat-sp/wordpress.git
tar xf wordpress-5.2.1.tar.gz
cd wordpress
mv /root/wordpress/* .
git add .
git commit -m 'new1'
git push  -u origin master
```

**部署节点**： node 节点需要在系统管理中配置节点

#### 2、配置

1）创建job

![img](assets/1235834-20180905183039989-769081353.png)

2）参数化构建

![img](assets/1235834-20180905183208466-356358757.png)

3）配置pipeline脚本 （直接配置或者git获取）

![360截图18620330175141](assets/360截图18620330175141.png)

![360截图18260727588956](assets/360截图18260727588956.png)

4）最后，保存

#### 3、编写jenkinsfile

接下里编写jenkinsfile文件：

jenkinsfile-PHP：

源码文件：

```
node ("jenkins-slave2") {
   stage('git checkout') {
       checkout([$class: 'GitSCM', branches: [[name: '${branch}']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'git@192.168.152.138:plat-sp/wordpress.git']]])
   }
   stage('code copy') {
        sh '''rm -rf ${WORKSPACE}/.git
        mkdir -p /data/backup/web-$(date +"%F")
        mv /home/wwwroot/default/* /data/backup/web-$(date +"%F")
        cp -rf ${WORKSPACE}/* /home/wwwroot/default/'''
   }
   stage('test') {
       sh "curl http://192.168.152.153/status.html"
   }
}


node ("slave01-172.16.1.2") {
   stage('git checkout') {
       checkout([$class: 'GitSCM', branches: [[name: '${branch}']], doGenerateSubmoduleConfigurations: false, extensions: [], subm
oduleCfg: [], userRemoteConfigs: [[url: 'git@172.16.1.3:/home/git/repos/wordpress']]])
   }
   stage('code copy') {
        sh '''rm -rf ${WORKSPACE}/.git
        mv /usr/share/nginx/html/wp.com /data/backup/wp.com-$(date +"%F_%T")
        cp -rf ${WORKSPACE} /usr/share/nginx/html/wp.com'''
   }
   stage('test') {
       sh "curl http://wp.test.com/status.html"
   }
}
```

下面为带解释版，但不可以使用，部分注释会造成问题

```
node ("slave01-172.16.1.2") {   //绑定到该节点去执行
   stage('git checkout') {     //拉代码
       checkout([$class: 'GitSCM', branches: [[name: '${branch}']], doGenerateSubmoduleConfigurations: false, extensions: [], su
bmoduleCfg: [], userRemoteConfigs: [[url: 'git@172.16.1.3:/home/git/repos/wordpress']]])
   }
   // $class: 'GitSCM' git插件获取代码的工具
   // branches 分支名称
   // doGenerateSubmoduleConfigurations 是否包含子模块配置
   // extensions 扩展功能
   // submoduleCfg  子模块配置
   // userRemoteConfigs 远程用户配置（仓库地址）
   stage('code copy') {    //复制代码
        sh '''rm -rf ${WORKSPACE}/.git   //删除拉下来的项目的.git敏感文件
        mv /usr/share/nginx/html/wp.com /data/backup/wp.com-$(date +"%F_%T")  //备份旧文件
        cp -rf ${WORKSPACE} /usr/share/nginx/html/wp.com'''  //新文件复制到站点目录
   }
   stage('test') {  #测试
       sh "curl http://wp.test.com/status.html"
   }
}
```

#### 4、构建

构建概览：

![img](assets/1235834-20180905184051509-1764641810.png)

控制台输出详情：

![img](assets/1235834-20180905184107686-644530379.png)

![img](assets/1235834-20180905184123455-512468351.png)

可以看到每一步的执行详情，最后也是成功的！！！！！！

此外我们可以查看服务器及网页实际体验效果进行验证。

### 12、Jenkins流水线自动化发布Java项目

#### 1、前提

**插件**：Maven Integration plugin

**环境：**maven、tomcat，git

用的博客系统代码：

git clone https://github.com/b3log/solo.git

远端git服务器：

```
[git@git repos]$ mkdir -p solo
[git@git repos]$ cd solo/
[git@git solo]$ git --bare init
Initialized empty Git repository in /home/git/repos/solo/
```

本地web：

```
[root@web solo]# git remote -v
origin    git@172.16.1.3:/home/git/repos/solo (fetch)
origin    git@172.16.1.3:/home/git/repos/solo (push)
[root@web solo]# git remote rm origin
[root@web solo]# git init
Reinitialized existing Git repository in /root/solo/.git/
[root@web solo]# git remote add origin git@172.16.1.3:/home/git/repos/solo
[root@web solo]# git add .
[root@web solo]# git commit -m "java solo all"
# On branch master
nothing to commit, working directory clean
[root@web solo]# git push origin master
Counting objects: 29058, done.
Compressing objects: 100% (9854/9854), done.
Writing objects: 100% (29058/29058), 47.77 MiB | 39.28 MiB/s, done.
Total 29058 (delta 15768), reused 29058 (delta 15768)
To git@172.16.1.3:/home/git/repos/solo
 * [new branch]      master -> master
```

因为solo需要改如下配置才可以访问：（改serverhost为指定的域名）

```
vim /root/solo/src/main/resources/latke.properties
```

![img](assets/1235834-20180905184545173-2047374097.png)

然后再重新提交上去

**部署节点：** node 节点需要在系统管理中配置节点

#### 2、配置

1）新建job

![img](assets/1235834-20180905184625352-2046318711.png)

2）参数化构建

![img](assets/1235834-20180905184640513-596342130.png)

3）配置git仓库（针对jenkinsfile）

![img](assets/1235834-20180905184651748-234872141.png)

#### 3、编写Jenkinsfile

源码配置文件：

```
node ("slave02-172.16.1.3") {
   //def mvnHome = '/usr/local/maven'
   stage('git checkout') {
        checkout([$class: 'GitSCM', branches: [[name: '${branch}']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'git@172.16.1.3:/home/git/repos/solo']]])
   }
   stage('maven build') {
        sh '''export JAVA_HOME=/usr/local/java
        /usr/local/maven/bin/mvn clean package -Dmaven.test.skip=true'''
   }
   stage('deploy') {
        sh '''
    JENKINS_NODE_COOKIE=dontkillme
    export JAVA_HOME=/usr/local/java
        TOMCAT_NAME=tomcat
        TOMCAT_HOME=/usr/local/$TOMCAT_NAME
        WWWROOT=$TOMCAT_HOME/webapps/ROOT

        if [ -d $WWWROOT ]; then
           mv $WWWROOT /data/backup/${TOMCAT_NAME}-$(date +"%F_%T")
        fi
        unzip ${WORKSPACE}/target/*.war -d $WWWROOT
        PID=$(ps -ef |grep $TOMCAT_NAME |egrep -v "grep|$$" |awk \'{print $2}\')
        [ -n "$PID" ] && kill -9 $PID
        /bin/bash $TOMCAT_HOME/bin/startup.sh
       '''
    }
   stage('test') {
    sh "curl http://192.168.152.138:8080/status.html"
    echo "test ok!!!!!!!"
   }
}
```

下面为带解释版，但不可以使用，部分注释会造成问题

```
node ("slave02-172.16.1.3") {  //绑定到该节点构建
   //def mvnHome = '/usr/local/maven'
   stage('git checkout') {     //拉代码
        checkout([$class: 'GitSCM', branches: [[name: '${branch}']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'git@172.16.1.3:/home/git/repos/solo']]])
   }
   stage('maven build') {   //maven build
        sh '''export JAVA_HOME=/usr/local/java   //在指定java环境变量
        /usr/local/maven/bin/mvn clean package -Dmaven.test.skip=true'''  //构建maven包 clean package表示构建之前会清理之前构建的包，-Dmaven.test.skip=true表示跳过单元测试
   }
   stage('deploy') {  //部署
        sh '''
        JENKINS_NODE_COOKIE=dontkillme  #tomcat启动时会衍生出一些子进程，然后才能成功启动，但是jenkins会在构建结束杀掉tomcat的那些衍生子进程，造成tomcat启动失败，此处加上这个参数可以解决这个问题。
        export JAVA_HOME=/usr/local/java
        TOMCAT_NAME=tomcat
        TOMCAT_HOME=/usr/local/$TOMCAT_NAME
        WWWROOT=$TOMCAT_HOME/webapps/ROOT

        if [ -d $WWWROOT ]; then  //如果目录存在，先备份
           mv $WWWROOT /data/backup/${TOMCAT_NAME}-$(date +"%F_%T")
        fi
        unzip ${WORKSPACE}/target/*.war -d $WWWROOT  //项目包解压到站点目录
        PID=$(ps -ef |grep $TOMCAT_NAME |egrep -v "grep|$$" |awk \'{print $2}\')  //重启tomcat
        [ -n "$PID" ] && kill -9 $PID
        /bin/bash $TOMCAT_HOME/bin/startup.sh'''
   }
   stage('test') { //测试
       //sh "curl http://wp.test.com/status.html"
        echo "test ok!!!!!!!"
   }
}
```

#### 4、构建

![img](assets/1235834-20180905184913443-2058202273.png)

#### 5、访问

![img](assets/1235834-20180905184940777-1980161350.png)

**报错处理**

pipeline script from SCM方式下：

```
Started by user ***
java.io.FileNotFoundException
    at jenkins.plugins.git.GitSCMFile$3.invoke(GitSCMFile.java:167)
    at jenkins.plugins.git.GitSCMFile$3.invoke(GitSCMFile.java:159)
    at jenkins.plugins.git.GitSCMFileSystem$3.invoke(GitSCMFileSystem.java:193)
    ...
Finished: FAILURE
```

![img](assets/4276633-a4aee92aa7677655.png)

​                                                  **原因是git工程下，没有找到Script Path路径下的脚本文件**。

### 13、Jenkins 结合 gitlab 使用

#### 1、创建一个新的任务

创建一个新的任务

![img](assets/1190037-20171201192354042-830010134.png)

​         输入项目的名称，选择构建只有分风格的软件

![img](assets/1190037-20171201192401401-883929242.png)

#### 2、将Jenkins与gitlab联合

##### 1、Jenkins创建公钥和私钥

```
[root@Jenkins ~]# ssh-keygen 
Generating public/private rsa key pair.

Enter file in which to save the key (/root/.ssh/id_rsa): Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:5SGYye8oxCKFJjddb4W8JC0RAQhBWCvuG8aZL8eMJs4 root@Jenkins
The key's randomart image is:
+---[RSA 2048]----+
|==....=* ..      |
|...o oo==.       |
|+.= . =++.o      |
|++ o   o.+ .     |
|... o   S .      |
|o.oo   o         |
| B+ . . .        |
|++++ .           |
|+Eo.             |
+----[SHA256]-----+
[root@Jenkins ~]# cat .ssh/id_rsa.pub 
[root@Jenkins ~]# cat .ssh/id_rsa
```

##### 2、在gitlab中添加公钥id_rsa.pub

![img](assets/1190037-20171201192426354-684435689.png)

##### 3、在jenkins中添加私钥id_rsa

​         在首页中，点击项目名称的下拉监听

![img](assets/1190037-20171201192438933-1952523900.png)

​         选择源码管理，先将gitlab的项目地址复制过来

![img](assets/1190037-20171201192448667-1624864487.png)

​         选择SSH密钥和证书，然后选择直接输入，将私钥复制到下框中即可

​         添加完成后，点击保存

![img](assets/1190037-20171201192456448-898723804.png)

​         选择刚才创建的证书，完成后，选择构建

![img](assets/1190037-20171201192504808-1018752536.png)

**选择构建**

​         拉到最底部，选择使用shell脚本

![img](assets/1190037-20171201192512214-519514729.png)

​         脚本内容

![img](assets/1190037-20171201192518948-2060407751.png)

​         创建测试环境

```
[root@Jenkins ~]# mkdir -p /data/www
[root@Jenkins ~]# chown -R jenkins.jenkins /data/
```

​         选择构建后的操作，让每次构建完成后都将结果发送给管理员

![img](assets/1190037-20171201192536214-662773016.png)

#### 3、测试手动集成

回到主页，点击右侧的按钮进行测试

![img](assets/1190037-20171201192552839-1669748311.png)

部署完成

![img](assets/1190037-20171201192558886-1289295614.png)

​         查看部署日志

![img](assets/1190037-20171201192606261-1352544543.png)

查看部署结果

```
[root@Jenkins ~]# ll /data/www/
总用量 4
-rw-r--r-- 1 jenkins jenkins 4 11月 30 21:22 flag
-rw-r--r-- 1 jenkins jenkins 0 11月 30 21:22 README.md
```

#### 4、自动测试（gitlab主动通知Jenkins测试）

该功能会使用到一个插件 **gitlab plugin**

配置gitlab认证

![img](assets/1190037-20171201192624433-157495203.png)

​         添加一个新的凭证

![img](assets/1190037-20171201192631683-372513748.png)

​         从gitlab的设置中将 token复制过来（需要手动创建token）

![360截图18620331606393](assets/360截图18620331606393.png)



​         将复制的token粘贴到api token中，点ok

![img](assets/1190037-20171201192651667-606045732.png)

​         在系统配置中找到**Gitlab** 将信息进行填写，Credentials 选择刚刚创建对的即可

![img](assets/1190037-20171201192700729-449236192.png)

打开项目，编辑项目的构建触发器

![img](assets/1190037-20171201192710183-1810385177.png)

在gitlab上配置连接jenkins ，将Jenkins的Secret token 与Build URL 复制到gitlab中

注意： 在项目设置中的集成

![img](assets/1190037-20171201192718448-1860661215.png)

​         保存之前先进程测试，测试成功后进行保存

![img](assets/1190037-20171201192726448-895582851.png)

​         在gitlab进行上传文件，可以测试。

在日志中显示是 Started by GitLab push by Administrator 即表示自动集成成功

![img](assets/1190037-20171201192733104-716903443.png)



#### 5、小坑

- **错误提示：**

  ```
  #很多朋友使用最新版本的gitlab做自动部署时，在增加web钩子那一步，
  #点击test  push events时会报错：Url is blocked: Requests to the local network are not allowed
  ```

  ![Gitlab+Jenkins实现自动部署](assets/b36a6a1bc5d58b0186618d020a801cc7.png)

- 解决方法：

  ```
  #这是因为新版的gitlab为了安全默认禁止了本地局域网地址调用web hook
  #我们在设置里允许就行，具体步骤如下：
  ```

  ![Gitlab+Jenkins实现自动部署](assets/2ac7f84e086f61d521781c3027576b1e.png)
  ![Gitlab+Jenkins实现自动部署](assets/f13e07e857b8d7677bb04f2631692e06.png)

![360截图17370510273154](assets/360截图17370510273154.png)

### 14、公司代码上线方案

#### 1、早期手动部署代码

纯手动scp上传代码。

纯手动登陆，Git pull 或者SVN update。

纯手动xftp上传代码。

开发发送压缩包，rz上传，解压部署代码。

**缺点：**

全程运维参与，占用大量时间。

如果节点多，上线速度慢。

人为失误多，目录管理混乱。 

回滚不及时，或者难以回退。

**上线方案示意图：**

![img](assets/1190037-20171201192743261-564020995.png)

#### 2、合理化上线方案

1、开发人员需在个人电脑搭建LAMP环境测试开发好的网站代码，并且在办公室或 IDC机房的测试环境测试通过，最好有专职测试人员。

2、程序代码上线要规定时间，例如：三天上线一次，如网站需经常更新可每天下午 20 点上线，这个看网站业务性质而定，原则就是影响用户体验最小。

3、代码上线之前需备份，网站程序出了问题方便回退，另外，从上线技巧上讲，上传代码时尽可能先传到服务器网站临时目录，传完整后一步mv过去，或者通过In做软链接— 线上更新代码的思路。如果严格更新，把应用服务器从集群节点平滑下线，然后更新。

4、尽量由运维人员管理上线，对于代码的功能性，开发人员更在意，而对于代码的性 能优化和上线后服务器的稳定，运维更在意服务器的稳定，因此，如果网站宕机问题归运维管，就要让运维上线，这样更规范科学。否则，开发随意更新，出了问题运维负责，这样就错了，运维永远无法抬头。

![img](assets/1190037-20171201192752386-122301749.png)

**图·web代码规范化上线流程图**

#### 3、大型企业上线制度和流程

**JAVA代码环境**上线时，有数台机器同时需要更新或者分批更新 

```
1).本地开发人员取svn代码。当天上线提交到trunk，否则，长期项目单开分支开发，然后在合并主线(trunk)
2).办公内网开发测试时，由开发人员或配置管理员通过部署平台jenkins实现统一部署，（即在部署平台上控制开发机器从svn取代码，编译，打包，发布到开发机，包名如idc_dep.war）.
3).开发人员通知或和测试人员一起测试程序，没有问题后，由配置管理员打上新的tag标记。这里要注意，不同环境的配置文件是随代码同时发布的。
4).配置管理员，根据上一步的tag标记，checkout出上线代码，并配置好IDC测试环境的所有配置，执行编译，打包(mvn,ant)(php不需要打包)，然后发布到IDC内的统一分发服务器。
5).配置管理员或SA上线人员，把分发的程序代码内容推送到相关测试服务器（包名如idc_test.war），然后通知开发及测试人员进行测试。如果有问题向上回退，继续修改。
6).如果IDC测试没有问题，继续打好tag标记，此时，配置管理员，根据上步的tag标记，checkout出测试好的代码，并配置好IDC正式环境的所有配置，执行编译，打包(mvn,ant)(php不需要打包)，然后发布到IDC内的统一分发服务器主机，准备批量发布。
7).配置管理员或SA上线人员，把分发的内容推送到相关正式服务器（包名如idc_product.war）,然后通知开发及测试人员进行测试。如果有问题直接发布回滚指令。  
```

 　　 IDC正式上线的过程对于JAVA程序，可以是AB组分组上线的思路，即平滑下线一半的服务器，然后发布更新代码，重启测试，无问题后，挂上更新后的服务器，同时再平滑下线另一半的服务器，然后发布更新代码测试（或者直接发布后，重启，挂上线）

#### 4 、php程序代码上线的具体方案

 　　对于PHP上线方法：发布代码时（也需要测试流程）可以直接发布到正式线临时目录 ，然后mv或更改link的方式发布到正式上线目录 ，不需要重启http服务。这是新朗，赶集的上线方案。

#### 5 、JAVA程序代码上线的具体方案

对于java上线方法:较大公司需要分组平滑上线（如从负载均衡器上摘掉一半的服务器），发布代码后，重启服务器测试，没问题后，挂上上好线的一半，再下另外一半。如果前端有DNS智能解析，上线还可以分地区上线若干服务器，逐渐普及到全国的服务器，这个被称为“灰度发布”，在后面门户网站上线的知识里我们在讲解。

#### 6 、代码上线解决方案注意事项

```
1).上线的流程里，办公室测试环境-->IDC测试环境-->正式生产环境，所有环境中的所有软件均应版本统一，其次尽量单一，否则将后患无穷，开发测试成功，IDC测试就可能有问题（如:操作系统，web服务器，jdk,php,tomcat,resin等版本）
2).开发团队小组办公内部测试环境测试（该测试环境属于开发小组维护，或定时自动更新代码），代码有问题返回给某开发人员重新开发。
3).有专门的测试工程师，程序有问题直接返回给开发人员（此时返回的一般为程序的BUG，称为BUG库），无问题进行IDC测试
4).IDC测试由测试人员和运维人员参与，叫IDCtest,进行程序的压力测试，有问题直接返回给开发人员，无问题进行线上环境上线。
5).数台服务器代码分发上线方案举例（JAVA程序）
  A:假设同业务服务器有6台，将服务器分为A,B两组，A组三台，B组三台，先对A组进行从负载均衡器上平滑下线，B组正常提供服务，避免服务器因上线影响业务。
  B:下线过程是通过脚本将A组服务器从RS池（LVS,NGINX,HAPROXY,F5等均有平滑方案）中踢出，避免负裁均衡器将请求发送给A组服务器（此时的时间应该为网站流量少时，一般为晚上）
  C:将代码分发到A组服务器的站点目录下，对A组服务器上线并重启服务，并由专业的测试人员进行访问测试，测试成功后，挂上A组的服务器，同时下线B组服务器，B组代码上线操作测试等和A组相同，期间也要观察上线提供服务的服务器状况，有问题及时回滚。
6).特别说明：如果是PHP程序，则上线可以简单化，直接将上线代码（最好全量）发布到所有上线服务器的特定目录后，分发完成后，一次性mv或ln到站点目录，当然测试也是少不了的。测试除了人员测试外，还有各种测试脚本测试各个相关业务接口。
7).大多数门户公司的前端页面都已经静态化或者cache了，因此，动态的部分访问平时就不会特别多，流量低谷时就更少了。再加上是平滑上下线，因此基本上
```



## 十三、jenkins+gitlab+maven+tomcat实现自动集成、打包、部署

#### 一、介绍

​      持续集成（Continuous Integration，简称CI）是一种软件开发实践，团队开发人员每次都通过自动化的构建（编译、发布、自动化测试）来验证，从而尽早的发现集成错误。持续集成最大的优点是避免了传统模式在集成阶段的除虫会议（bug meeting），其要素包括统一的代码库、自动构建、自动测试、自动部署、频繁提交修改过的代码等。

#### 二、环境

Jenkins 自身采用 Java 开发，所以要必须安装 JDK，本文集成的项目基于 Maven 构架，Maven 也必须安装。使用git连接远程仓库gitlab

centos7 64位  47.92.85.152  4G  安装jdk、maven、git、jenkins

centos7 64位  47.92.85.153  4G  安装gitlab

#### 三、安装

##### 1、jdk安装

下载jdk8版本
https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

上传到服务器，解压

```
tar -zxvf jdk-8u40-linux-i586.tar.gz
```

添加环境变量配置

```
vi /etc/profile   //进入编辑
```

在文件末尾加入以下内容：

```
JAVA_HOME=/usr/local/java
export MAVEN_HOME=/usr/local/maven
export JRE_HOME=/usr/local/java/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$MAVEN_HOME/bin:$PATH
```

完成编辑后让其生效

```
source /etc/profile 
```

运行命令就可以看到java版本了

```
java -version
```

##### 2、安装maven

下载maven版本
https://maven.apache.org/download.cgi

上传到服务器，解压

```
tar -zxvf  apache-maven-3.6.0-bin.tar.gz
```

添加环境变量配置

```
 vi /etc/profile   //进入编辑
```

在文件末尾加入以下内容：

```
JAVA_HOME=/usr/local/java
export MAVEN_HOME=/usr/local/maven
export JRE_HOME=/usr/local/java/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$MAVEN_HOME/bin:$PATH
```

完成编辑后让其生效

```
source /etc/profile  
mvn -version  #查看maven版本 
```

##### 3、tomcat安装配置

- 下载地址：http://tomcat.apache.org/
- 解压缩：tar -zxvf apache-tomcat-8.5.tar.gz
- 进入Tomcat安装目录：/opt/apache-tomcat-7.0.41/bin
- 启动Tomcat：./startup.sh
- 关闭Tomcat：./shutdown.sh
- 查看Tomcat日志：tail -f /opt/apache-tomcat-7.0.41/logs/catalina.out

```
export CATALINA_HOME=/usr/local/tomcat
export JAVA_HOME=/usr/local/java
export JRE_HOME=/usr/local/java/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export MAVEN_HOME=/usr/local/maven
export PATH=$JRE_HOME/bin:$JAVA_HOME/bin:$CATALINA_HOME/bin:$MAVEN_HOME/bin:$PATH
```

#####  4、git安装

更新系统包到最新

```
yum -y update
```

安装git

```
yum –y install git
```

完毕，查看git版本号

```
git --version 
```

创建一个git用户并赋予密码

```
useradd git
passwd git
```

 设置用户名和邮箱

```
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

创建秘钥

```
ssh-keygen -t rsa -C "你的邮箱"   #一直回车，密码为空。生成的目录看输出日志创建完成后会有公钥id_rsa.pub（服务器上使用） 和 私钥 id_rsa（客户端使用）
```

禁用git用户shell登录（一定要禁用）

```
vi /etc/passwd
```

将git用户修改为如下（一般在最后一行）git:x:1000:1000::/home/git:/usr/bin/git-shell

```
usermod -s /usr/bin/git-shell git
```

修改sshd配置加权限

```
 chown -R git:git .ssh
```

 修改配置,启用ssh公钥认证

```
vi /etc/ssh/sshd_config
```

 修改如下内容：

RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

```
systemctl restart sshd  #重启ssh生效
```

##### 5、gitlab安装

 参见gitlab部署

##### 6、Jenkins安装

下载rpm包
http://pkg.jenkins-ci.org/redhat/

使用rpm包安装命令

```
rpm -ih jenkins-2.155-1.1.noarch.rpm
```

自动安装完成之后： 
/usr/lib/jenkins/jenkins.war WAR包 
/etc/sysconfig/jenkins 配置文件
/var/lib/jenkins/ 默认的JENKINS_HOME目录
/var/log/jenkins/jenkins.log Jenkins日志文件

调整配置文件

```
vim /etc/sysconfig/jenkins
```

JENKINS_USER="root" ## 原值 "jenkins" 必须修改，否则权限不足
JENKINS_PORT="8080" ## 原值 "8080" 可以不修改,访问端口号

启动Jenkins

```
sudo systemctl enable jenkins
sudo systemctl restart jenkins
```

开放端口号

```
firewall-cmd --zone=public --add-port=8080/tcp --permanent #开放端口
firewall-cmd --reload  #重载防火墙
```

安装JDK后，Jenkins无法启动，需要修改vi /etc/rc.d/init.d/jenkins， 查找，输入/java, 添加新的jre路径 

```
vim /etc/rc.d/init.d/jenkins

# Search usable Java. We do this because various reports indicated

# that /usr/bin/java may not always point to Java >= 1.6
# see http://www.nabble.com/guinea-pigs-wanted-----Hudson-RPM-for-RedHat-Linux-td25673707.html
candidates="
/etc/alternatives/java
/usr/lib/jvm/java-1.6.0/bin/java
/usr/lib/jvm/jre-1.6.0/bin/java
/usr/lib/jvm/java-1.7.0/bin/java
/usr/lib/jvm/jre-1.7.0/bin/java
/usr/lib/jvm/java-1.8.0/bin/java
/usr/lib/jvm/jre-1.8.0/bin/java
/usr/bin/java
/data/java/jdk1.8.0_101/bin/java
```

**7、访问**

http://47.92.85.152:8080/

提示输入密码，在/var/lib/jenkins/secrets/initialAdminPassword中， 默认用户为admin

登录后提示安装插件，点击“推荐的插件”

需要安装的相关插件

- Git plugin ## 版本管理 GIT 的插件
- GitLab Plugin ##gitlab
- Maven Integration plugin ## 项目构建 Maven 的插件
- Gradle Plugin ## 项目构建 Gradle 的插件
- Publish Over SSH ##ssh连接插件
- 无需重启 Jenkins 插件即生效。如遇失败可重试或离线安装。

**8、Jenkins系统设置**
	**注意**
		这里没有强调的都设置为默认即可
	路径
		系统管理->（全局工具配置）Global Tool Configuration,配置jdk,git,maven的根目录
	图示
		1、全局配置工具

![1561684698679](assets/1561684698679.png)

![1561684715543](assets/1561684715543.png)

2、配置jdk目录

![1561684732934](assets/1561684732934.png)

​	注意： 配置JDK根目录：注意不能是JDK9.0，切忌

3、配置git目录
	![1561684757268](assets/1561684757268.png)
4、配置maven并保存
	![1561684772501](assets/1561684772501.png)
5、汇总截图

![1561684795300](assets/1561684795300.png)

 9、SSH 设置
目的
		简介
			（192.168.0.115）jinkens服务器上的maven将开发产生的*.war包。
               通过SSH自动推送到远程tomcat 服务器上(192.168.0.109)。
需要手工配置ssh key。配合自动化推送
		192.168.0.115是jenkins
		192.168.0.109是tomcat网站服务器，代表业务服务器
	图示
		1、jenkins服务器准备秘钥认证

​				ssh-keygen 

​				一路回车

​				ssh-copy-id -i 192.168.0.109

​				注意这里的192.168.0.109是一台tomcat网站服务器。什么都不用安装，接到代码即可。
​				#ssh 192.168.0.109 登录不需要密码即可
​		2、在jenkins上配置ssh信息
​			  进入系统设置
​				![1561684983009](assets/1561684983009.png)

3、jenkins 准备SSH私钥
[root@jenkins ~]# ip a | grep inet
inet 192.168.0.115/24 brd 192.168.0.255 scope global dynamic ens32、

[root@jenkins ~]# cat ~/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAuZ1QvEGtK/sbllkN80urEDm/ggIM4QD9JWmmAPUnpuXMDvOS
bbbAUvmrneO4QrSRH+2cXZNabn1C26I2Oi0u6a14fU/UtpkXMMSTHVnzGnyC/uCa
p7r3YaDHYjt1jfVpG0mR+JkuOiLgi+PnbgtNckE+FPQCG9EacActIyDb0gIswvbM
mq1pvwJQLOSN/AAUllTSigZPqIMdkLLWHoutFkvdAgdUblEMEdl1mztl4xInkRIo
pxuWWjdo7V1YuAXmHZXjutLiE5OrM6yEdAeHLDs5KoYGar2QBZ9owCoXfN+dNrSi
XeoFp9RkNmzbkFBWRbh97gLnBxw01lxnaxU+8QIDAQABAoIBAHWDl93YZt71eB3T
+/UQ7xiytwCEc8rwaVUKckMg8x3DV1IP+6DilxjxYSnxRnNVBpyEPv8vj41sWKvd
Ix/qA02GukX8CNwiSIBjtBBdJoCaXAUqBkAzKvPwastSgbaCrSzNg1E1CgNcmXV3
sMoG9d1kWP3DDqK13FsY8AbRgtqN2X7f5zuIFGAHy0AfMiBtmhLCD8wNi7KioRcQ
hc4U/W+Uc3++/VWPaptJEG5TTqLJ1JClDULCGRS6q+ndneeyYM7U15pFSaQa+ZSq
MljCybfh+STV9Qq1ErDXKK9UoSkbbFOGdWPm7TrltvPuLwrUzRdangJGnco8vA9/
Cn1U+MECgYEA5m/IH1UjBz0q7+MEnoCE52R4I7rEyeyLf9M5ebX3lq1iD/a0rPXn
e6PnS5RfbFmBDKov/xekjtfrI/ta3Lj38dejtzTasEn+4dXITA7HPP8kSEUgRm+c
Lh4CjkzQKnSJ7TZgDB5w21ZO0li4kBQ2r5gr/Vf9MFaTJCUqxM4vNO0CgYEAzjSe
201kk5G73Oub2wzR9XEQt0+bAvs7JA9ZvcC9rObQ9FUsUgCD0nR88EGGIjiKkas5
JUrC5Rzw4Jhp8SqQCVeOk8milP2AwtqGLEjJ6WqLGdJsrFtRYBdhdxNjsilNiNEZ
97FLAfsgIDT9DmWX77QXN5QkkAL5UWAm787UFZUCgYBUA7E86zdoLj73UxeeClFq
Y9EBhdi1ng6GPiaYX2Wzg+da1qGs5cLN60Yq4h+gS0mnqmzxXlda1RIf/kZ0buPH
Qs2nwBdzaqcJA36RbFnrvUInLzzDMXIJxls8Mnk64V5gJBEEmhyfe2oler9fmF8P
yjVPmsLu2sGuzfY35syDSQKBgQCBkMi8LT3kB28OWjCdC8olOXzyYZ+Z2PgJKWgO
9bt4l7N1wsrNX6t0omMap2E7wWE4NGj8yKP7SBsGVF5E/aRxakWZENoKWdr9FEe4
LahI9PwgJnrINbzE7wv7wQAkoxUnwZNaclkaDovaENFsqWM1Z2grMPdkUaoMeqkc
h031nQKBgQDObARvT8wAmGGtDBMsRjbxdgDEl+KsoREhPw6UME3KKNjmQFVBZBy4
RzvjFCaXWVtIai2WZq5UrsdqdffctX7fm9fNdqx+fuXBfQzK59e9FfV2z2JpXCMx
SIdkhf+P+J/bBKDCiAumz9qNkdKaPC5ruAziLKrttB7cH5dsjFy35g==
-----END RSA PRIVATE KEY-----

复制cat出来的所有内容，粘贴到下一步页面上的key中。

粘贴到jenkins

![1561685026243](assets/1561685026243.png)



接下来就可以新建maven项目任务

![img](assets/1585635-20190113172057124-371246376.png)

 配置任务

![img](assets/1585635-20190113172259693-168237753.png)

选择版本控制器和仓库地址
	https://github.com/bingyue/easy-springmvc-maven
	![1561685190025](assets/1561685190025.png)

	注意
		如果是私有仓库，这里需要建立credentials身份认证
设置触发器（保持默认）

![1561685228541](assets/1561685228541.png)



设置构建（编译打包）
	手动添加Goals and options
		clean package -Dmaven.test.skip=true

![1561685258101](assets/1561685258101.png)



构建后操作 
	在构建后设置中 选择：(send build artifacts over ssh)通过SSH发送构建工件 
	图示
		点击增加构建后操作
			![1561685312339](assets/1561685312339.png)

	说明
	name
		    ssh server 因为之前的配置会默认出现tomcat业务服务器的名字
	source file
			构建之后，在jenkins服务器上是可以自动看到war包的。（该路径不需要创建）
	         ls /root/.jenkins/jobs/testjob1/builds/target/*.war
	Remove prefix
			 自动删除路径前缀（不需要创建路径前缀）
	Remote directory
			 tomcat业务服务器上的路径，需要提前在192.168.0.109上创建该目录。用来存放网站源代码。（需要后台创建）
	         # mkdir -p /jenkins/war
	Exec command	
			 tomcat（192.168.0.109）在接收到源码之后的自定义动作。
	         比如：将源码拷贝到网站的主目录（/jenkins）,并执行一些其他操作如重启服务器等（或创建文件touch）（需要后台创建）
	         #mkdir  /jenkins/sh
	         #cat  /jenkins/sh/deploy.sh
			 cp -r /jenkins/war/*.war   /jenkins
			 touch /tmp/aaaaaa.txt
			 #chmod +x /jenkins/sh/deploy.sh
保存即可

![1561685588570](assets/1561685588570.png)

保存

私仓git 管理 

私有仓库源码管理
	如果是私有仓库：地址要这样写
	![1561685688968](assets/1561685688968.png)

	报错：如果是私有库，必须添加一个 Credentials
		Failed to connect to repository : Command "/usr/local/git/bin/git -c core.askpass=true ls-remote -h http://www.xxx.com/gitlab/root/test.git HEAD" returned status code 128:
		stdout: 
	stderr: fatal: Unable to find remote helper for 'http'
	或者
	Failed to connect to repository : Command "git ls-remote -h git@xxxxx.com:xxx/dev_test.git HEAD" returned status code 128:
	stdout: 
	stderr: Permission denied, please tryagain. 
	Permission denied, please try again. 
	Permission denied(publickey,gssapi-keyex,gssapi-with-mic,password). 
	fatal: The remote end hung up unexpectedly原因：没有配置git的ssh key。
	
	解决方法：执行下面的命令，生成key
		ssh-keygen -t rsa -C "admin@example.com"
		然后将~/.ssh/目录下的id_rsa.pub中的公钥，放到git的ssh key中。再在Jenkins中创建新的Credentials。类型是SSH Username with private key。Username使用ssh-keygen中用到的邮箱，Private Key中选择“From the Jenkins master ~/.ssh”即可。修改后，问题解决。
创建credentials
步骤1：
		在 jenkins 中使用 git 插件从仓库中 pull 代码的时候会要求 jenkins 必须有 pull 权限（尤其是当git开启了ssh认证的时候），在配置 jenkins job 的时候有以下这些方法配置 ssh key:

​      登陆 jenkins 服务器，切换到 jenkins 用户(wing直接使用的root账户)，生成 ssh key，然后把 公钥添加到 git 服务器上.
​      #su - jenkins //切换到 jenkins HOME 目录
​      #ssh-keygen -t rsa  // 生成 ssh key, 复制 xxx.pub 公钥到 git 服务器上即可.
步骤2：在jenkins界面，依次点击： 
​	 Credentials -> System -> Add domain： 
​     Domain Name:  填写你 git 服务器的地址，如 github.xxx.com（wing填写的IP地址，127.0.0.1）
​     Description: 随便写一点描述，如 This is the Credential for github
​	如图
​		![1561685895215](assets/1561685895215.png)

  点击 ok 后，再点击  “adding some credentials?”

进入页面后，可以选择 Username with password 或者 SSH Username with private key, 根据你的情况选择，这里我们选择 Username with private key：
    Username: 随便起一个名字，以便在创建 Job 的时候使用该 Credential 
    Private Key：可以指定文件，也可以使用默认的 ~/.ssh，当然也可以直接将私钥复制粘贴到此处。 
    Passphrase:  如果你在创建 ssh key 的时候输入了 Passphrase 那就填写相应的 Passphrase，为空就不填写 
    ID: 空 
    Description： 空
![1561685919306](assets/1561685919306.png)

​	点击 ok 后 Credential 就创建好了。

如果你再新建 Job 就可以看到我们的 Credential 选项了：
		![1561685957800](assets/1561685957800.png)



11.构建任务
	1.立即构建
		![1561686632905](assets/1561686632905.png)
		![1561686677096](assets/1561686677096.png)

2.查看构建结果
	结果路径



![1561686692040](assets/1561686692040.png)

> 输出信息
>
> 由用户 xulei 启动

> 构建中 在工作空间 /root/.jenkins/workspace/testjob1 中
>

 > /usr/local/git/bin/git rev-parse --is-inside-work-tree # timeout=10
 > Fetching changes from the remote Git repository
 > /usr/local/git/bin/git config remote.origin.url https://github.com/bingyue/easy-springmvc-maven.git # timeout=10
 > Fetching upstream changes from https://github.com/bingyue/easy-springmvc-maven.git
 > /usr/local/git/bin/git --version # timeout=10
 > /usr/local/git/bin/git fetch --tags --progress https://github.com/bingyue/easy-springmvc-maven.git +refs/heads/*:refs/remotes/origin/*
 > /usr/local/git/bin/git rev-parse refs/remotes/origin/master^{commit} # timeout=10
 > /usr/local/git/bin/git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10
 > Checking out Revision 67604f7f9f30505e3bb3e8935c745154f04aa372 (refs/remotes/origin/master)
 > /usr/local/git/bin/git config core.sparsecheckout # timeout=10
 > /usr/local/git/bin/git checkout -f 67604f7f9f30505e3bb3e8935c745154f04aa372
 > Commit message: "修改standard/1.1.2的依赖"
 > /usr/local/git/bin/git rev-list --no-walk 67604f7f9f30505e3bb3e8935c745154f04aa372 # timeout=10
 > Parsing POMs
 > Established TCP socket on 40696
 > [testjob1] $ /usr/local/jdk/bin/java -cp /root/.jenkins/plugins/maven-plugin/WEB-INF/lib/maven35-agent-1.12-alpha-1.jar:/usr/local/maven/boot/plexus-classworlds-2.5.2.jar:/usr/local/maven/conf/logging jenkins.maven3.agent.Maven35Main /usr/local/maven/ /usr/local/tomcat/webapps/jenkins/WEB-INF/lib/remoting-3.20.jar /root/.jenkins/plugins/maven-plugin/WEB-INF/lib/maven35-interceptor-1.12-alpha-1.jar /root/.jenkins/plugins/maven-plugin/WEB-INF/lib/maven3-interceptor-commons-1.12-alpha-1.jar 40696
 > <===[JENKINS REMOTING CAPACITY]===>channel started
 > Executing Maven:  -B -f /root/.jenkins/workspace/testjob1/pom.xml clean package -Dmaven.test.skip=true
 > [INFO] Scanning for projects...
 > [WARNING] 
 > [WARNING] Some problems were encountered while building the effective model for springmvc-maven:easy-springmvc-maven:war:0.0.1-SNAPSHOT
 > [WARNING] 'build.plugins.plugin.version' for org.apache.maven.plugins:maven-war-plugin is missing. @ line 22, column 15
 > [WARNING] 
 > [WARNING] It is highly recommended to fix these problems because they threaten the stability of your build.
 > [WARNING] 
 > [WARNING] For this reason, future Maven versions might no longer support building such malformed projects.
 > [WARNING] 
 > [INFO] 
 > [INFO] ----------------< springmvc-maven:easy-springmvc-maven >----------------
 > [INFO] Building springmvc-maven 0.0.1-SNAPSHOT
 > [INFO] --------------------------------[ war ]---------------------------------
 > [INFO] 
 > [INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ easy-springmvc-maven ---
 > [INFO] Deleting /root/.jenkins/workspace/testjob1/target
 > [INFO] 
 > [INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ easy-springmvc-maven ---
 > [INFO] Using 'UTF-8' encoding to copy filtered resources.
 > [INFO] skip non existing resourceDirectory /root/.jenkins/workspace/testjob1/src/main/resources
 > [INFO] 
 > [INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ easy-springmvc-maven ---
 > [INFO] Changes detected - recompiling the module!
 > [INFO] Compiling 2 source files to /root/.jenkins/workspace/testjob1/target/classes
 > [INFO] 
 > [INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ easy-springmvc-maven ---
 > [INFO] Not copying test resources
 > [INFO] 
 > [INFO] --- maven-compiler-plugin:3.1:testCompile (default-testCompile) @ easy-springmvc-maven ---
 > [INFO] Not compiling test sources
 > [INFO] 
 > [INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ easy-springmvc-maven ---
 > [INFO] Tests are skipped.
 > [WARNING] Attempt to (de-)serialize anonymous class hudson.maven.reporters.BuildInfoRecorder$1; see: https://jenkins.io/redirect/serialization-of-anonymous-classes/
 > [INFO] 
 > [INFO] --- maven-war-plugin:2.2:war (default-war) @ easy-springmvc-maven ---
 > [INFO] Packaging webapp
 > [INFO] Assembling webapp [easy-springmvc-maven] in [/root/.jenkins/workspace/testjob1/target/easy-springmvc-maven]
 > [INFO] Processing war project
 > [INFO] Copying webapp resources [/root/.jenkins/workspace/testjob1/src/main/webapp]
 > [INFO] Webapp assembled in [127 msecs]
 > [INFO] Building war: /root/.jenkins/workspace/testjob1/target/easy-springmvc-maven.war
 > [INFO] WEB-INF/web.xml already added, skipping
 > [WARNING] Attempt to (de-)serialize anonymous class hudson.maven.reporters.MavenArtifactArchiver$2; see: https://jenkins.io/redirect/serialization-of-anonymous-classes/
 > [WARNING] Attempt to (de-)serialize anonymous class hudson.maven.reporters.MavenFingerprinter$1; see: https://jenkins.io/redirect/serialization-of-anonymous-classes/
 > [INFO] ------------------------------------------------------------------------
 > [INFO] BUILD SUCCESS
 > [INFO] ------------------------------------------------------------------------
 > [INFO] Total time: 7.358 s
 > [INFO] Finished at: 2018-06-18T03:39:25+08:00
 > [INFO] ------------------------------------------------------------------------
 > Waiting for Jenkins to finish collecting data
 > [JENKINS] Archiving /root/.jenkins/workspace/testjob1/pom.xml to springmvc-maven/easy-springmvc-maven/0.0.1-SNAPSHOT/easy-springmvc-maven-0.0.1-SNAPSHOT.pom
 > [JENKINS] Archiving /root/.jenkins/workspace/testjob1/target/easy-springmvc-maven.war to springmvc-maven/easy-springmvc-maven/0.0.1-SNAPSHOT/easy-springmvc-maven-0.0.1-SNAPSHOT.war
 > channel stopped
 > SSH: Connecting from host [localhost.localdomain]
 > SSH: Connecting with configuration [tomcat] ...
 > SSH: EXEC: STDOUT/STDERR from command [/jenkins/sh/deploy.sh] ...
 > SSH: EXEC: completed after 201 ms
 > SSH: Disconnecting configuration [tomcat] ...
 > SSH: Transferred 1 file(s)
 > Finished: SUCCESS

3.观察tomcat网站服务器，代码和脚本
	[root@localhost ~]# ls /jenkins/
easy-springmvc-maven.war  sh  war
[root@localhost ~]# ls /tmp/aaaaaa.txt 
/tmp/aaaaaa.txt

easy-springmvc-maven.war 就是推送过来的网站源码了

## 十四、jenkins+maven+docker+github全自动化部署SpringBoot实例

实践性尝试，这里只在一台虚拟机下操作。

### 1、vmware 下centos 安装

### 2、centos 软件安装

1） docker 安装

```
 yum install -y docker
```

2）JDK 安装

------

3）Maven 安装

------

4）Git 安装

```
yum install git    
```

------

5）安装jenkins

### 3、Jenkins 配置

安装插件

本例配置如下

Locale plugin

![clipboard.png](assets/822599378-5ace2af7638f9_articlex.png)

Publish Over SSH 

![clipboard.png](assets/2375815523-5ace2a972b57c_articlex.png)

### 4、创建JOB 名字为cicd_demo

![clipboard.png](assets/490972615-5ace21e5bb862_articlex.png)

### 5、配置cicd_demo任务

本例演示项目地址为：[https://github.com/chendishen...](https://github.com/chendisheng/cicd_demo.git)
1）配置General

​                                                       ![ clipboard.png](assets/1397713455-5ace24216b167_articlex.png)  

上图中git项目是我的一个测试项目

2）源码管理

![clipboard.png](assets/2415167804-5ace24e9c9df4_articlex.png)

3）构建触发器
Poll SCM：定时检查源码变更（根据SCM软件的版本号），如果有更新就checkout最新code下来，然后执行构建动作。我的配置如下：

```
勾选 Poll SCM ,日程表填入: `* * * * *` （5个*）,忽视警告
```

​                                                        ![clipboard.png](assets/500856252-5ace25e74446d_articlex.png)  
4）构建环境
不设置

![clipboard.png](assets/2505040546-5ace285eec2f1_articlex.png)

5）构建
maven version 选择 `maven`
Goals ： `clean package`

![clipboard.png](assets/3139699581-5ace2878045be_articlex.png)

6）构建后操作
在配置最后找到“增加构建后操作步骤”，选择"Send build artifacts over SSH"

![clipboard.png](assets/328744887-5ace29f0e5084_articlex.png)

配置说明：

> 1.SSH Server Name 就是前面配置的Publish Over SSH 的名称
> 2.Source files 是指源文件位置，这个位置是在jenkins的工作目录下的job文件在内 ，
> （/var/lib/jenkins/workspace/cicd_demo 默认路径 cicd_demo是我的job名称,maven 编译后会在此文件内创建 target 目录, cicd-demo*.jar是构建后jar包命名前缀+版本号
> 见pom.xml 中 artifactId ）
> 3.Remove prefix 删除前缀 target
> 4.Remote directory 远程目录，结合前面Publish Over SSH配置就是 /root/test 目录，这些配置完毕以后， jenkins 在编译成功后，就会自动把 文件 copy 到 B主机下的/root/test
> 5.Exec command , 我这里的操作是吧 主机 /root/test 的文件 复制到 我自己的 /usr/local/project/cicd_demo下 然后进入到此目录，执行我的 buildimage.sh 和 run.sh

------

配置中的目录和文件需要提前创建

```
mkdir /usr/local/project/cicd_demo
```

在/usr/local/project/cicd_demo目录下

![clipboard.png](assets/127215268-5ace32c5667d2_articlex.png)

文件说明

> buildimage.sh 用来构建镜像 
> Dockerfile 为构建镜像所需文件
> run.sh 用来启动容器

buildimage.sh创建

```
vi /usr/local/project/cicd_demo/buildimage.sh
```

buildimage.sh 内容：

```
docker build -t cicd_demo:1.0 .
```

Dockerfile创建

```
vi /usr/local/project/cicd_demo/Dockerfile
```

Dockerfile内容：

```
# 版本信息
#java：latest 为centos官方java运行环境镜像，600多M ,可以提前pull到主机本地
FROM java:latest 
MAINTAINER cds "352826256@qq.com"

#实际上可以配置成变量 
ADD cicd-demo-1.0.jar /usr/local/jar/

RUN mv /usr/local/jar/cicd-demo-1.0.jar  /usr/local/jar/app.jar

#开启内部服务端口 cicd-demo 项目端口
EXPOSE 8090

CMD ["java","-jar","/usr/local/jar/app.jar"]
```

run.sh 创建

```
vi /usr/local/project/cicd_demo/run.sh
```

run.sh 内容 :

```
docker rm -f cicd_demo
docker run --name="cicd_demo" -p 8090:8090 -d cicd_demo:1.0
```

### 6、cicd_demo任务运行

控制台输出如下
![图片描述](assets/3677843122-5ace38e3c0461_articlex.png)

至此自动构建任务完成

### 7、结果验证

在物理机浏览器输入 [http://192.168.1.104](http://192.168.1.104/):8090/index

![clipboard.png](assets/736765959-5ace398ede685_articlex.png)