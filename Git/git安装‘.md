# centos7安装git

1、介绍

使用Coding管理项目，上面要求使用的git版本为1.8.0以上，而很多yum源上自动安装的git版本为1.7，所以需要掌握手动编译安装git方法。

2、安装git依赖包

yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker

3、删除已有的git(若尚未安装，则可以不用)

yum remove git

4、下载git源码

下载git安装包到/data/software下

cd /data/software

wget [https://www.kernel.org/pub/software/scm/git/git-2.8.3.tar.gz](https://link.jianshu.com/?t=https%3A%2F%2Fwww.kernel.org%2Fpub%2Fsoftware%2Fscm%2Fgit%2Fgit-2.8.3.tar.gz)

解压git安装包

tar -zxvf git-2.8.3.tar.gz

cd git-2.8.3

配置git安装路径

./configure prefix=/usr/local/git/

编译并且安装

make && make install

git已经安装完毕

5、将git指令添加到bash中

vi /etc/profile

在最后一行加入

export PATH=$PATH:/usr/local/git/bin

让该配置文件立即生效

source /etc/profile

查看git版本号

git --version