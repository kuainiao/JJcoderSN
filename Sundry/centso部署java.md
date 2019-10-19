# CentOS下部署Java7/Java8

## 一、前言

### 1、本文主要内容

- CentOS下部署OracleJDK
- CentOS下部署OpenJDK

### 2、适用范围与本篇环境

- 适用范围

1.CentOS 6+
2.Java 7+

- 本篇环境

1.CentOS 7
2.Java 8

## 二、部署OracleJDK

### 1、下载

```
#JDK下载首页
http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
#JDK8历史版本
https://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase8-2177648.html
#（1）下载之后FTP/SFTP到服务器
#（2）获取到下载链接后，用wget命令下载
```

### 2、解压到指定目录

```
sudo mkdir -p /usr/java 
sudo tar zvxf jdk-8u131-linux-x64.tar.gz -C /usr/java
```

### 3、配置环境变量

```
vi /etc/profile
# 在export PATH USER LOGNAME MAIL HOSTNAME HISTSIZE HISTCONTROL下添加

export JAVA_HOME=/usr/java/jdk1.8.0_131
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
```

### 4、使环境变量生效

```
source /etc/profile
```

### 5、检查是否配置成功

```
java -version
```

## 三、OpenJDK部署

### 1、yum安装

```
yum install -y java-1.8.0-openjdk
```

### 2、检查是否配置成功

```
java -version
```

## 三、备注

### 1、附录

- Oracle-JDK首页

https://www.oracle.com/technetwork/java/javase/downloads/index.html

- Oracle-JDK历史版本

https://www.oracle.com/technetwork/java/javase/archive-139210.html