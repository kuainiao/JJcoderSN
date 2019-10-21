### 一、概述

Maven是基于项目对象模型(POM project object model)，可以通过一小段描述信息（配置）来管理项目的构建，报告和文档的软件项目管理工具。

Maven的核心功能便是合理叙述项目间的依赖关系，通俗点讲，就是通过pom.xml文件的配置获取jar包，而不用手动去添加jar包；如果需要使用pom.xml来获取jar包，那么首先该项目就必须为maven项目，maven项目可以这样去想，就是在java项目或web项目的上面包裹了一层maven，本质上java项目还是java项目，web项目还是web项目，但是包裹了maven之后，就可以使用maven提供的一些功能了(通过pom.xml添加jar包)。

### 二、安装

http://maven.apache.org    download   

```bash
[root@jenkins ~]# wget http://mirror.bit.edu.cn/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz
```



解压到指定的安装目录中

```bash
[root@jenkins ~]# tar xf apache-maven-3.6.0-bin.tar.gz -C /usr/local/
```



检查一下 `JAVA` 的环境

```bash
[root@jenkins ~]# echo  $JAVA_HOME
/usr/local/jdk1.8.0_192
```



把 `maven` 安装路径下的 `bin` 目录添加到 `$PATH` 中

```bash
[root@jenkins ~]# cat /etc/profile.d/maven.sh
v
```



使刚才的配置立刻生效，要想所有用户的环境都生效，需要重启系统

```bash
[root@jenkins ~]# source /etc/profile.d/java.sh
```



检查 `maven` 的版本信息，以便验证安装和配置正确

```bash
[root@jenkins ~]# mvn -v
Apache Maven 3.5.4 (1edded0938998edf8bf061f1ceb3cfdeccf443fe; 2018-06-18T02:33:14+08:00)
Maven home: /usr/local/apache-maven-3.5.4
Java version: 1.8.0_171, vendor: Oracle Corporation, runtime: /usr/local/jdk1.8.0_171/jre
Default locale: zh_CN, platform encoding: UTF-8
OS name: "linux", version: "3.10.0-693.el7.x86_64", arch: "amd64", family: "unix"
```



### 三、创建maven项目

#### 实例1

```bash
bogon:~ meteor$ mkdir maven
bogon:~ meteor$ cd maven
bogon:maven meteor$ mkdir -p src/{test,main/java/yeecall/com/maven}
bogon:maven meteor$ vim pom.xml
bogon:maven meteor$ cat pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  // 通过groupId 、artifactId 、version三个属性来定位一个jar
  <groupId>yeecall.com.maven</groupId>  //包名(项目名，以字母开头)
  <artifactId>maven01-ch</artifactId>     //模块名
  <version>0.0.1-SNAPSHOT</version>     //版本
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>
</project>
bogon:maven meteor$
bogon:maven meteor$ vim src/main/java/yeecall/com/maven/HelloMaven.java
bogon:maven meteor$ cat src/main/java/yeecall/com/maven/HelloMaven.java
package yeecall.com.maven;
public class HelloMaven
{
    public String sayHello(String name){
        return "hello:"+name;
    }
}
bogon:maven meteor$
bogon:maven meteor$ ls
pom.xml  src
bogon:maven meteor$ mvn compile    # 使用maven将*.java包编译成 *.class的类
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building maven01-ch 0.0.1-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ maven01-ch ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/meteor/maven/src/main/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ maven01-ch ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to /Users/meteor/maven/target/classes
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.491 s
[INFO] Finished at: 2016-08-29T14:40:26+08:00
[INFO] Final Memory: 13M/155M
[INFO] ------------------------------------------------------------------------
```



**在以上构建编译过程中，假如出现：**

```bash
No compiler is provided in this environment. Perhaps you are running on a JRE rather than a JDK?
```



那么你安装 java 的方式，可能是使用 yum 安装的，那么还需要安装 

```bash
yum install java-devel
```



编译成功后，查看结果

```bash
bogon:maven meteor$ ls
pom.xml  src  target
bogon:maven meteor$ ls target/classes/yeecall/com/maven/  #查看编译结果，如下：
HelloMaven.class
```



测试刚才的程序

```bash
bogon:maven meteor$ ls src/test/
bogon:maven meteor$
bogon:maven meteor$ mkdir -p src/test/java/yeecall/com/maven/

# 编写一个测试程序
bogon:maven meteor$ vim src/test/java/yeecall/com/maven/TestHelloMaven.java
bogon:maven meteor$ cat src/test/java/yeecall/com/maven/TestHelloMaven.java
package yeecall.com.maven;
import org.junit.*;
import static org.junit.Assert.*;
public class TestHelloMaven
{
    @Test
    public void testSayHello() {
        HelloMaven hm = new HelloMaven();
        String str = hm.sayHello("maven");
        assertEquals(str,"hello:maven");  // 判断两个对象是否相同
    }
}
bogon:maven meteor$
```



```bash
bogon:maven meteor$ vim pom.xml
bogon:maven meteor$ cat pom.xml  #由于测试单元调用了junit模块，测试单元依赖junit包，依赖关系在pom.xml中定义如下：
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>yeecall.com.maven</groupId>
  <artifactId>maven01-ch</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <dependencies>
    <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
    </dependency>
  </dependencies>
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>
</project>
bogon:maven meteor$
bogon:maven meteor$ mvn test  #运行测试单元
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building maven01-ch 0.0.1-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ maven01-ch ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/meteor/maven/src/main/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ maven01-ch ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to /Users/meteor/maven/target/classes
[INFO]
[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ maven01-ch ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/meteor/maven/src/test/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:testCompile (default-testCompile) @ maven01-ch ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to /Users/meteor/maven/target/test-classes
[INFO]
[INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ maven01-ch ---
[INFO] Surefire report directory: /Users/meteor/maven/target/surefire-reports
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
Running yeecall.com.maven.TestHelloMaven
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.086 sec
Results :
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 2.715 s
[INFO] Finished at: 2016-08-29T14:54:32+08:00
[INFO] Final Memory: 15M/168M
[INFO] ------------------------------------------------------------------------
bogon:maven meteor$
bogon:maven meteor$ ls target/
classessurefire-reports
maven-statustest-classes
bogon:maven meteor$ ls target/surefire-reports/  #查看测试报告文件
TEST-yeecall.com.maven.TestHelloMaven.xml
yeecall.com.maven.TestHelloMaven.txt
bogon:maven meteor$ cat target/surefire-reports/yeecall.com.maven.TestHelloMaven.txt  #测试报告内容如下：
-------------------------------------------------------------------------------
Test set: yeecall.com.maven.TestHelloMaven
-------------------------------------------------------------------------------
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.086 sec
bogon:maven meteor$
bogon:maven meteor$ mvn clean   #清空
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building maven01-ch 0.0.1-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ maven01-ch ---
[INFO] Deleting /Users/meteor/maven/target
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 0.361 s
[INFO] Finished at: 2016-08-29T15:01:05+08:00
[INFO] Final Memory: 6M/123M
[INFO] ------------------------------------------------------------------------
bogon:maven meteor$ ls
pom.xml src
bogon:maven meteor$
```





测试成功完成后，就可以编译打包了

``` shell
bogon:maven meteor$ mvn package   # 编译并打包的命令
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building maven01-ch 0.0.1-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ maven01-ch ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/meteor/maven/src/main/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ maven01-ch ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to /Users/meteor/maven/target/classes
[INFO]
[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ maven01-ch ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/meteor/maven/src/test/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:testCompile (default-testCompile) @ maven01-ch ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to /Users/meteor/maven/target/test-classes
[INFO]
[INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ maven01-ch ---
[INFO] Surefire report directory: /Users/meteor/maven/target/surefire-reports
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
Running yeecall.com.maven.TestHelloMaven
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.083 sec
Results :
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO]
[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ maven01-ch ---
[INFO] Building jar: /Users/meteor/maven/target/maven01-ch-0.0.1-SNAPSHOT.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.114 s
[INFO] Finished at: 2016-08-29T15:02:47+08:00
[INFO] Final Memory: 17M/207M
[INFO] ------------------------------------------------------------------------
bogon:maven meteor$ ls target/maven01-ch-0.0.1-SNAPSHOT.jar  #验证打包结果，如下：
target/maven01-ch-0.0.1-SNAPSHOT.jar
bogon:maven meteor$
bogon:maven meteor$ mvn install    #将打包输出的*.jar包推到本机的本地仓库中，如下所示：
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building maven01-ch 0.0.1-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ maven01-ch ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/meteor/maven/src/main/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ maven01-ch ---
[INFO] Nothing to compile - all classes are up to date
[INFO]
[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ maven01-ch ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/meteor/maven/src/test/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:testCompile (default-testCompile) @ maven01-ch ---
[INFO] Nothing to compile - all classes are up to date
[INFO]
[INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ maven01-ch ---
[INFO] Surefire report directory: /Users/meteor/maven/target/surefire-reports
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
Running yeecall.com.maven.TestHelloMaven
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.096 sec
Results :
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO]
[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ maven01-ch ---
[INFO]
[INFO] --- maven-install-plugin:2.4:install (default-install) @ maven01-ch ---
[INFO] Installing /Users/meteor/maven/target/maven01-ch-0.0.1-SNAPSHOT.jar to /Users/meteor/.m2/repository/yeecall/com/maven/maven01-ch/0.0.1-SNAPSHOT/maven01-ch-0.0.1-SNAPSHOT.jar
[INFO] Installing /Users/meteor/maven/pom.xml to /Users/meteor/.m2/repository/yeecall/com/maven/maven01-ch/0.0.1-SNAPSHOT/maven01-ch-0.0.1-SNAPSHOT.pom
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 2.658 s
[INFO] Finished at: 2016-08-29T15:10:28+08:00
[INFO] Final Memory: 12M/220M
[INFO] ------------------------------------------------------------------------

# 验证本地仓库中的包，如下：
bogon:maven meteor$ ls ~/.m2/repository/yeecall/com/maven/maven01-ch/0.0.1-SNAPSHOT/maven01-ch-0.0.1-SNAPSHOT.jar
/Users/meteor/.m2/repository/yeecall/com/maven/maven01-ch/0.0.1-SNAPSHOT/maven01-ch-0.0.1-SNAPSHOT.jar
bogon:maven meteor$
```



#### 实例2

在同一个项目中创建第二个模块，并调用HelloMaven模块，如下：

``` shell
bogon:~ meteor$ mkdir -p maven02-ch/src/{test,main}/java/yeecall/com/maven/ch02
bogon:~ meteor$ vim maven02-ch/src/main/java/yeecall/com/maven/ch02/Hello.java
bogon:~ meteor$ cat maven02-ch/src/main/java/yeecall/com/maven/ch02/Hello.java
package yeecall.com.maven.ch02;
import yeecall.com.maven.HelloMaven;
public class Hello
{
    public String say(String name){
        HelloMaven hm = new HelloMaven();
        return hm.sayHello(name);
    }
}
bogon:~ meteor$ vim maven02-ch/pom.xml
bogon:~ meteor$ cat maven02-ch/pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>yeecall.com.maven</groupId>
  <artifactId>maven02-ch</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.12</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-surefire-plugin</artifactId>
      <version>2.17</version>
    </dependency>
    <dependency>
      <groupId>yeecall.com.maven</groupId>
      <artifactId>maven01-ch</artifactId>
      <version>0.0.1-SNAPSHOT</version>
    </dependency>
  </dependencies>
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>
</project>
bogon:~ meteor$
```



```bash
bogon:~ meteor$ cd maven02-ch
bogon:maven02-ch meteor$ mvn compile  #在编译本项目时它会引用maven01-ch中的HelloMaven类，如果maven01-ch没有执行mvn install，在本项目编译时会提示无法找到相关jar包，抛出异常
[INFO] Scanning for projects...          # 说明 mvn install 是将打包后的*.jar包 push到 本地仓库中，以便其它模块或项目在pom.xml文件中引用
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building maven02-ch 0.0.1-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ maven02-ch ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/meteor/maven/maven02-ch/src/main/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ maven02-ch ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to /Users/meteor/maven/maven02-ch/target/classes
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 2.251 s
[INFO] Finished at: 2016-08-29T15:34:44+08:00
[INFO] Final Memory: 14M/210M
[INFO] ------------------------------------------------------------------------
bogon:maven02-ch meteor$
```



### 小结

   mvn compile 命令会根据 pom.xml 中定义的dependencies 依赖，去maven 中心下载相关的包并进行编译，将编译后的文件放在 target/classes/目录中；

   mvn test  命令会根据test目录中定义的测试文件对类进行编译测试，并把生成的测试报告存放在target/surefire-reports/目录中；

   mvn clean 命令清除target 目录 

   mvn package 命令生成相关的jar包存放在 target目录中

   mvn install 命令将生成的*.jar包复制到本地库中(默认的本地仓库位置在~/.m2/repository/)

**自动生成 pom.xml**

``` shell
mvn archetype:generate
mvn archetype:generate -D groupId=yeecall.com.maven -D artifactId=maven03-ch -D version=0.0.1 - SNAPSHOT
```

**mvn repository**
1、**本地工厂(仓库)的位置** 
``` shell
bogon:conf meteor$ pwd
/opt/apache-maven-3.3.9/conf
bogon:conf meteor$ grep "localRepository" settings.xml
    <!-- localRepository
    <localRepository>/path/to/local/repo</localRepository>
bogon:conf meteor$
```

2、**中央repository**
``` shell
bogon:lib meteor$ pwd
/opt/apache-maven-3.3.9/lib
bogon:lib meteor$ ls maven-model-builder-3.3.9.jar
maven-model-builder-3.3.9.jar
bogon:lib meteor$ 解压maven-model-builder-3.3.9.jar包，中央仓库的位置在 org/apache/maven/model/pom-4.0.0.xml 文件中定义
<repositories>
...
</repositories>
```


