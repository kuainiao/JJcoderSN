# docker-compose 使用详解

## 一、简介

Docker-Compose项目是Docker官方的开源项目，负责实现对Docker容器集群的快速编排。
Docker-Compose将所管理的容器分为三层，分别是工程（project），服务（service）以及容器（container）。Docker-Compose运行目录下的所有文件（docker-compose.yml，extends文件或环境变量文件等）组成一个工程，若无特殊指定工程名即为当前目录名。一个工程当中可包含多个服务，每个服务中定义了容器运行的镜像，参数，依赖。一个服务当中可包括多个容器实例，Docker-Compose并没有解决负载均衡的问题，因此需要借助其它工具实现服务发现及负载均衡。
Docker-Compose的工程配置文件默认为docker-compose.yml，可通过环境变量COMPOSE_FILE或-f参数自定义配置文件，其定义了多个有依赖关系的服务及每个服务运行的容器。
使用一个Dockerfile模板文件，可以让用户很方便的定义一个单独的应用容器。在工作中，经常会碰到需要多个容器相互配合来完成某项任务的情况。例如要实现一个Web项目，除了Web服务容器本身，往往还需要再加上后端的数据库服务容器，甚至还包括负载均衡容器等。
Compose允许用户通过一个单独的docker-compose.yml模板文件（YAML 格式）来定义一组相关联的应用容器为一个项目（project）。
Docker-Compose项目由Python编写，调用Docker服务提供的API来对容器进行管理。因此，只要所操作的平台支持Docker API，就可以在其上利用Compose来进行编排管理。
源码：https://github.com/docker/compose

## 二、安装与卸载

官网链接：https://docs.docker.com/compose/install/

### 1、方法一

下载Docker-Compose：

```shell
sudo curl -L https://github.com/docker/compose/releases/download/1.23.0-rc3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
#安装Docker-Compose：
sudo chmod +x /usr/local/bin/docker-compose
#查看版本 :
docker-compose version
```

### 2、方法二

```shell
#安装pip
yum -y install epel-release
yum -y install python-pip
#确认版本
pip --version
#更新pip
pip install --upgrade pip
#安装docker-compose
pip install docker-compose
#查看版本
docker-compose version
```

## 三、常用命令

### Docker-Compose命令格式

```shell
docker-compose [-f ...] [options] [COMMAND] [ARGS...]
```

命令选项如下：

```shell
-f，–file FILE指定Compose模板文件，默认为docker-compose.yml，可以多次指定。
-p，–project-name NAME指定项目名称，默认将使用所在目录名称作为项目名。
-x-network-driver 使用Docker的可拔插网络后端特性（需要Docker 1.9+版本）
-x-network-driver DRIVER指定网络后端的驱动，默认为bridge（需要Docker 1.9+版本）
-verbose输出更多调试信息
-v，–version打印版本并退出
```

### 1. docker-compose top

显示正在运行的进程

```shell
docker-compose top
```

### 2. docker-compose up

```shell
docker-compose up [options] [--scale SERVICE=NUM...] [SERVICE...]
```

选项包括：

```shell
-d 在后台运行服务容器
–no-color 不使用颜色来区分不同的服务的控制输出
–no-deps 不启动服务所链接的容器
–force-recreate 强制重新创建容器，不能与–no-recreate同时使用
–no-recreate 如果容器已经存在，则不重新创建，不能与–force-recreate同时使用
–no-build 不自动构建缺失的服务镜像
–build 在启动容器前构建服务镜像
–abort-on-container-exit 停止所有容器，如果任何一个容器被停止，不能与-d同时使用
-t, –timeout TIMEOUT 停止容器时候的超时（默认为10秒）
–remove-orphans 删除服务中没有在compose文件中定义的容器
–scale SERVICE=NUM 设置服务运行容器的个数，将覆盖在compose中通过scale指定的参数
```

启动所有服务

```shell
docker-compose up
```

在后台所有启动服务

```shell
docker-compose up -d
```

-f 指定使用的Compose模板文件，默认为docker-compose.yml，可以多次指定。

```shell
docker-compose -f docker-compose.yml up -d
```

### 3. docker-compose ps

docker-compose ps [options] [SERVICE...]

列出项目中目前的所有容器

```shell
docker-compose ps
```

### 4. docker-compose stop

docker-compose stop [options] [SERVICE...]

选项包括：

```shell
-t, –timeout TIMEOUT 停止容器时候的超时（默认为10秒）
```

停止正在运行的容器，可以通过docker-compose start 再次启动

```shell
docker-compose stop
```

### 5. docker-compose -h

查看帮助

```shell
docker-compose -h
```

### 6. docker-compose down

```shell
docker-compose down [options]
```

停止和删除容器、网络、卷、镜像。
选项包括：

```shell
–rmi type，删除镜像，类型必须是：all，删除compose文件中定义的所有镜像；local，删除镜像名为空的镜像
-v, –volumes，删除已经在compose文件中定义的和匿名的附在容器上的数据卷
–remove-orphans，删除服务中没有在compose中定义的容器
```

停用移除所有容器以及网络相关

```shell
docker-compose down
```

### 7. docker-compose logs

docker-compose logs [options] [SERVICE...]

查看服务容器的输出。默认情况下，docker-compose将对不同的服务输出使用不同的颜色来区分。可以通过–no-color来关闭颜色。

查看服务容器的输出

```shell
docker-compose logs
```

### 8. docker-compose build

```shell
docker-compose build [options] [--build-arg key=val...] [SERVICE...]
```

构建（重新构建）项目中的服务容器。

选项包括：

```shell
–compress 通过gzip压缩构建上下环境
–force-rm 删除构建过程中的临时容器
–no-cache 构建镜像过程中不使用缓存
–pull 始终尝试通过拉取操作来获取更新版本的镜像
-m, –memory MEM为构建的容器设置内存大小
–build-arg key=val为服务设置build-time变量
```

服务容器一旦构建后，将会带上一个标记名。可以随时在项目目录下运行docker-compose build来重新构建服务

### 9. docker-compose pull

```shell
docker-compose pull [options] [SERVICE...]
```

拉取服务依赖的镜像。

选项包括：

```shell
–ignore-pull-failures，忽略拉取镜像过程中的错误
–parallel，多个镜像同时拉取
–quiet，拉取镜像过程中不打印进度信息
docker-compose pull
```

### 10. docker-compose restart

```shell
docker-compose restart [options] [SERVICE...]
```

重启项目中的服务。
选项包括：

```shell
-t, –timeout TIMEOUT，指定重启前停止容器的超时（默认为10秒）
```

重启项目中的服务

```shell
docker-compose restart
```

### 11. docker-compose rm

```shell
docker-compose rm [options] [SERVICE...]
```

删除所有（停止状态的）服务容器。
选项包括：

```shell
–f, –force，强制直接删除，包括非停止状态的容器
-v，删除容器所挂载的数据卷
```

删除所有（停止状态的）服务容器。推荐先执行docker-compose stop命令来停止容器。

```shell
docker-compose rm
```

### 12. docker-compose start

```shell
docker-compose start [SERVICE...]
```

启动已经存在的服务容器。

```shell
docker-compose start
```

### 13. docker-compose run

```shell
docker-compose run [options] [-v VOLUME...] [-p PORT...] [-e KEY=VAL...] SERVICE [COMMAND] [ARGS...]
```

在指定服务上执行一个命令。

在指定容器上执行一个ping命令。

```shell
docker-compose run ubuntu ping www.baidu.com
```

### 14. docker-compose scale

```shell
docker-compose scale web=3 db=2
```

设置指定服务运行的容器个数。通过service=num的参数来设置数量

### 15. docker-compose pause

```shell
docker-compose pause [SERVICE...]
```

暂停一个服务容器

### 16. docker-compose kill

```shell
docker-compose kill [options] [SERVICE...]
```

通过发送SIGKILL信号来强制停止服务容器。

支持通过-s参数来指定发送的信号，例如通过如下指令发送SIGINT信号：

```shell
docker-compose kill -s SIGINT
```

### 17. dokcer-compose config

```shell
docker-compose config [options]
```

验证并查看compose文件配置。

选项包括：

```shell
–resolve-image-digests 将镜像标签标记为摘要
-q, –quiet 只验证配置，不输出。 当配置正确时，不输出任何内容，当文件配置错误，输出错误信息
–services 打印服务名，一行一个
–volumes 打印数据卷名，一行一个
```

### 18. docker-compose create

```shell
docker-compose create [options] [SERVICE...]
```

为服务创建容器。

选项包括：

```shell
–force-recreate：重新创建容器，即使配置和镜像没有改变，不兼容–no-recreate参数
–no-recreate：如果容器已经存在，不需要重新创建，不兼容–force-recreate参数
–no-build：不创建镜像，即使缺失
–build：创建容器前，生成镜像
```

### 19. docker-compose exec

```shell
docker-compose exec [options] SERVICE COMMAND [ARGS...]
```

选项包括：

```shell
-d 分离模式，后台运行命令。
–privileged 获取特权。
–user USER 指定运行的用户。
-T 禁用分配TTY，默认docker-compose exec分配TTY。
–index=index，当一个服务拥有多个容器时，可通过该参数登陆到该服务下的任何服务，例如：docker-compose exec –index=1 web /bin/bash ，web服务中包含多个容器
```

### 20. docker-compose port

```shell
docker-compose port [options] SERVICE PRIVATE_PORT
```

显示某个容器端口所映射的公共端口。

选项包括：

```shell
–protocol=proto，指定端口协议，TCP（默认值）或者UDP
–index=index，如果同意服务存在多个容器，指定命令对象容器的序号（默认为1)
```

### 21. docker-compose push

```shell
docker-compose push [options] [SERVICE...]
```

推送服务依的镜像。

选项包括：

```shell
–ignore-push-failures 忽略推送镜像过程中的错误
```

### 22. docker-compose unpause

```shell
docker-compose unpause [SERVICE...]
```

恢复处于暂停状态中的服务。

### 23. docker-compose version

```shell
docker-compose version
```

打印版本信息。

## 四、模板文件详解

Compose允许用户通过一个docker-compose.yml模板文件（YAML 格式）来定义一组相关联的应用容器为一个项目（project）。
Compose模板文件是一个定义服务、网络和卷的YAML文件。Compose模板文件默认路径是当前目录下的docker-compose.yml，可以使用.yml或.yaml作为文件扩展名。
Docker-Compose标准模板文件应该包含version、services、networks 三大部分，最关键的是services和networks两个部分。

```yaml
version: '2'
services:
  web:
    image: dockercloud/hello-world
    ports:
      - 8080
    networks:
      - front-tier
      - back-tier

  redis:
    image: redis
    links:
      - web
    networks:
      - back-tier

  lb:
    image: dockercloud/haproxy
    ports:
      - 80:80
    links:
      - web
    networks:
      - front-tier
      - back-tier
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock 

networks:
  front-tier:
    driver: bridge
  back-tier:
    driver: bridge
```

Compose目前有三个版本分别为Version 1，Version 2，Version 3，Compose区分Version 1和Version 2（Compose 1.6.0+，Docker Engine 1.10.0+）。Version 2支持更多的指令。Version 1将来会被弃用。

### 1. image

image是指定服务的镜像名称或镜像ID。如果镜像在本地不存在，Compose将会尝试拉取镜像。

```yaml
services: 
    web: 
        image: hello-world
```

### 2. build

服务除了可以基于指定的镜像，还可以基于一份Dockerfile，在使用up启动时执行构建任务，构建标签是build，可以指定Dockerfile所在文件夹的路径。Compose将会利用Dockerfile自动构建镜像，然后使用镜像启动服务容器。

```yaml
build: /path/to/build/dir
```

也可以是相对路径，只要上下文确定就可以读取到Dockerfile。

```yaml
build: ./dir
```

设定上下文根目录，然后以该目录为准指定Dockerfile。

```yaml
build:
  context: ../
  dockerfile: path/of/Dockerfile
```

build都是一个目录，如果要指定Dockerfile文件需要在build标签的子级标签中使用dockerfile标签指定。

如果你同时指定了 image 和 build 两个标签，那么 Compose 会构建镜像并且把镜像命名为 image 后面的那个名字。

```yaml
build: ./dir
image: webapp:tag
```

既然可以在 docker-compose.yml 中定义构建任务，那么一定少不了 arg 这个标签，就像 Dockerfile 中的 ARG 指令，它可以在构建过程中指定环境变量，但是在构建成功后取消，在 docker-compose.yml 文件中也支持这样的写法：

```yaml
build:
  context: .
  args:
    buildno: 1
    password: secret
```

下面这种写法也是支持的，一般来说下面的写法更适合阅读。

```yaml
build:
  context: .
  args:
    - buildno=1
    - password=secret
```

与 ENV 不同的是，ARG 是允许空值的。例如：

```yaml
args:
  - buildno
  - password
```

这样构建过程可以向它们赋值。

> 注意：YAML 的布尔值（true, false, yes, no, on, off）必须要使用引号引起来（单引号、双引号均可），否则会当成字符串解析。

### 3. context

context选项可以是Dockerfile的文件路径，也可以是到链接到git仓库的url，当提供的值是相对路径时，被解析为相对于撰写文件的路径，此目录也是发送到Docker守护进程的context

```yaml
build:
  context: ./dir
```

### 4. dockerfile

使用dockerfile文件来构建，必须指定构建路径

```yaml
build:
  context: .
  dockerfile: Dockerfile-alternate
```

dockerfile指令不能跟image同时使用，否则Compose将不确定根据哪个指令来生成最终的服务镜像。

### 5. command

使用command可以覆盖容器启动后默认执行的命令。

```yaml
command: bundle exec thin -p 3000
```

也可以写成类似 Dockerfile 中的格式：

```yaml
command: [bundle, exec, thin, -p, 3000]
```

### 6. container_name

Compose的容器名称格式是： <项目名称> <服务名称> <序号>
可以自定义项目名称、服务名称，但如果想完全控制容器的命名，可以使用标签指定：

```yaml
container_name: app
```

### 7. net

设置网络模式。

```yaml
net: "bridge"
net: "none"
net: "host"
```

### 8. network_mode

网络模式，与Docker client的--net参数类似，只是相对多了一个service:[service name] 的格式。
例如：

```yaml
network_mode: "bridge"
network_mode: "host"
network_mode: "none"
network_mode: "service:[service name]"
network_mode: "container:[container name/id]"
```

可以指定使用服务或者容器的网络。

### 9. networks

加入指定网络，格式如下：

```yaml
services:
  some-service:
    networks:
     - some-network
     - other-network
```

关于这个标签还有一个特别的子标签aliases，这是一个用来设置服务别名的标签，例如：

```yaml
services:
  some-service:
    networks:
      some-network:
        aliases:
         - alias1
         - alias3
      other-network:
        aliases:
         - alias2
```

相同的服务可以在不同的网络有不同的别名

### 10. depends_on

在使用Compose时，最大的好处就是少打启动命令，但一般项目容器启动的顺序是有要求的，如果直接从上到下启动容器，必然会因为容器依赖问题而启动失败。例如在没启动数据库容器的时候启动应用容器，应用容器会因为找不到数据库而退出。depends_on标签用于解决容器的依赖、启动先后的问题。

```yaml
version: '2'
services:
  web:
    build: .
    depends_on:
      - db
      - redis
  redis:
    image: redis
  db:
    image: postgres
```

上述YAML文件定义的容器会先启动redis和db两个服务，最后才启动web 服务。

### 11. pid

```yaml
pid: "host"
```

将PID模式设置为主机PID模式，跟主机系统共享进程命名空间。容器使用pid标签将能够访问和操纵其他容器和宿主机的名称空间。

### 12. ports

ports用于映射端口的标签。
使用HOST:CONTAINER格式或者只是指定容器的端口，宿主机会随机映射端口。

```yaml
ports:
 - "3000"
 - "8000:8000"
 - "49100:22"
 - "127.0.0.1:8001:8001"
```

当使用HOST:CONTAINER格式来映射端口时，如果使用的容器端口小于60可能会得到错误得结果，因为YAML将会解析xx:yy这种数字格式为60进制。所以建议采用字符串格式。

### 13. extra_hosts

添加主机名的标签，会在/etc/hosts文件中添加一些记录。

```yaml
extra_hosts:
 - "somehost:162.242.195.82"
 - "otherhost:50.31.209.229"
```

启动后查看容器内部hosts：

```yaml
162.242.195.82  somehost
50.31.209.229   otherhost
```

### 14. volumes

挂载一个目录或者一个已存在的数据卷容器，可以直接使用 [HOST:CONTAINER]格式，或者使用[HOST:CONTAINER:ro]格式，后者对于容器来说，数据卷是只读的，可以有效保护宿主机的文件系统。
Compose的数据卷指定路径可以是相对路径，使用 . 或者 .. 来指定相对目录。
数据卷的格式可以是下面多种形式：

```yaml
volumes:
  // 只是指定一个路径，Docker 会自动在创建一个数据卷（这个路径是容器内部的）。
  - /var/lib/mysql
  // 使用绝对路径挂载数据卷
  - /opt/data:/var/lib/mysql
  // 以 Compose 配置文件为中心的相对路径作为数据卷挂载到容器。
  - ./cache:/tmp/cache
  // 使用用户的相对路径（~/ 表示的目录是 /home/<用户目录>/ 或者 /root/）。
  - ~/configs:/etc/configs/:ro
  // 已经存在的命名的数据卷。
  - datavolume:/var/lib/mysql
```

如果不使用宿主机的路径，可以指定一个volume_driver。

```yaml
volume_driver: mydriver
```

### 15. volumes_from

从另一个服务或容器挂载其数据卷：

```yaml
volumes_from:
   - service_name    
     - container_name
```

### 16. dns

和 --dns 参数一样用途，格式如下：

```yaml
dns: 8.8.8.8
```

也可以是一个列表：

```yaml
dns:
  - 8.8.8.8
  - 9.9.9.9
```

此外 dns_search 的配置也类似：

```yaml
dns_search: example.com
dns_search:
  - dc1.example.com
  - dc2.example.com
```

### 17. dns_search

配置DNS搜索域。可以是一个值，也可以是一个列表。

```yaml
dns_search：example.com
dns_search：
    - domain1.example.com
    - domain2.example.com
```

### 18. entrypoint

在Dockerfile中有一个指令叫做ENTRYPOINT指令，用于指定接入点。
在docker-compose.yml中可以定义接入点，覆盖Dockerfile中的定义：

```yaml
entrypoint: /code/entrypoint.sh
```

格式和 Docker 类似，不过还可以写成这样：

```yaml
entrypoint:
    - php
    - -d
    - zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so
    - -d
    - memory_limit=-1
    - vendor/bin/phpunit
```

### 19. env_file

在docker-compose.yml中可以定义一个专门存放变量的文件。
如果通过docker-compose -f FILE指定配置文件，则env_file中路径会使用配置文件路径。
如果有变量名称与environment指令冲突，则以后者为准。格式如下：

```yaml
env_file: .env
```

或者根据docker-compose.yml设置多个：

```yaml
env_file:
  - ./common.env
  - ./apps/web.env
  - /opt/secrets.env
```

注意的是这里所说的环境变量是对宿主机的 Compose 而言的，如果在配置文件中有 build 操作，这些变量并不会进入构建过程中，如果要在构建中使用变量还是首选前面刚讲的 arg 标签。

### 20. environment

与上面的 env_file 标签完全不同，反而和 arg 有几分类似，这个标签的作用是设置镜像变量，它可以保存变量到镜像里面，也就是说启动的容器也会包含这些变量设置，这是与 arg 最大的不同。
一般 arg 标签的变量仅用在构建过程中。而 environment 和 Dockerfile 中的 ENV 指令一样会把变量一直保存在镜像、容器中，类似 docker run -e 的效果。

```yaml
environment:
  RACK_ENV: development
  SHOW: 'true'
  SESSION_SECRET:

environment:
  - RACK_ENV=development
  - SHOW=true
  - SESSION_SECRET
```

### 21. cap_add

增加指定容器的内核能力（capacity）。
让容器具有所有能力可以指定：

```yaml
cap_add:
    - ALL
```

### 22. cap_drop

去掉指定容器的内核能力（capacity）。
去掉NET_ADMIN能力可以指定：

```yaml
cap_drop:
    - NET_ADMIN
```

### 23. cgroup_parent

创建了一个cgroup组名称为cgroups_1:

```yaml
cgroup_parent: cgroups_1
```

### 24. devices

指定设备映射关系，与Docker client的--device参数类似,例如：

```yaml
devices:
    - "/dev/ttyUSB1:/dev/ttyUSB0
```

### 25. expose

暴露端口，但不映射到宿主机，只允许能被连接的服务访问。仅可以指定内部端口为参数，如下所示：

```yaml
expose:
    - "3000"
    - "8000"
```

### 26. extends

基于其它模板文件进行扩展。例如，对于webapp服务定义了一个基础模板文件为common.yml：

```yaml
# common.yml
webapp:
    build: ./webapp
    environment:
        - DEBUG=false
        - SEND_EMAILS=false
```

再编写一个新的development.yml文件，使用common.yml中的webapp服务进行扩展：

```yaml
# development.yml
web:
    extends:
        file: common.yml
        service: webapp
    ports:
        - "8000:8000"
    links:
        - db
    environment:
        - DEBUG=true
db:
    image: mysql
```

后者会自动继承common.yml中的webapp服务及环境变量定义。
extends限制如下：
A、要避免出现循环依赖
B、extends不会继承links和volumes_from中定义的容器和数据卷资源
推荐在基础模板中只定义一些可以共享的镜像和环境变量，在扩展模板中具体指定应用变量、链接、数据卷等信息

### 27. external_links

在使用Docker过程中，我们会有许多单独使用docker run启动的容器，为了使Compose能够连接这些不在docker-compose.yml中定义的容器，我们需要一个特殊的标签，就是external_links，它可以让Compose项目里面的容器连接到那些项目配置外部的容器（前提是外部容器中必须至少有一个容器是连接到与项目内的服务的同一个网络里面）。链接到docker-compose.yml外部的容器，可以是非Compose管理的外部容器。

```yaml
external_links:
    - redis_1
    - project_db_1:mysql
    - project_db_1:postgresql
```

### 28. labels

为容器添加Docker元数据（metadata）信息。例如，可以为容器添加辅助说明信息：

```yaml
labels:
  com.example.description: "Accounting webapp"
  com.example.department: "Finance"
  com.example.label-with-empty-value: ""
labels:
  - "com.example.description=Accounting webapp"
  - "com.example.department=Finance"
  - "com.example.label-with-empty-value"
```

### 29. links

链接到其它服务中的容器。使用服务名称（同时作为别名），或者“服务名称:服务别名”（如 [SERVICE:ALIAS](service:ALIAS)），例如：

```yaml
links:
    - db
    - db:database
    - redis
```

使用别名将会自动在服务容器中的/etc/hosts里创建。例如：

```yaml
172.17.2.186  db
172.17.2.186  database
172.17.2.187  redis
```

### 30. logging

这个标签用于配置日志服务。格式如下：

```yaml
logging:
  driver: syslog
  options:
    syslog-address: "tcp://192.168.0.42:123"
```

默认的driver是json-file。只有json-file和journald可以通过docker-compose logs显示日志，其他方式有其他日志查看方式，但目前Compose不支持。对于可选值可以使用options指定。
有关更多这方面的信息可以阅读官方文档：
[https://docs.docker.com/engine/admin/logging/overview/](https://link.jianshu.com/?t=https://docs.docker.com/engine/admin/logging/overview/)

### 31. log_driver

指定日志驱动类型。目前支持三种日志驱动类型：

```yaml
log_driver: "json-file"
log_driver: "syslog"
log_driver: "none"
```

### 32. log_opt

日志驱动的相关参数。例如：

```yaml
log_driver: "syslog"log_opt: 
    syslog-address: "tcp://192.168.0.42:123"
```

### 33. security_opt

指定容器模板标签（label）机制的默认属性（用户、角色、类型、级别等）。例如，配置标签的用户名和角色名：

```yaml
security_opt:
    - label:user:USER
    - label:role:ROLE
```

### 34. stop_signal

设置另一个信号来停止容器。在默认情况下使用的是SIGTERM停止容器。设置另一个信号可以使用stop_signal标签。

```yaml
stop_signal: SIGUSR1
```

### 35. tmpfs

挂载临时目录到容器内部，与 run 的参数一样效果：

```yaml
tmpfs: /run
tmpfs:
  - /run
  - /tmp
```

### 36. 其它

还有这些标签：cpu_shares, cpu_quota, cpuset, domainname, hostname, ipc, mac_address, mem_limit, memswap_limit, privileged, read_only, restart, shm_size, stdin_open, tty, user, working_dir
上面这些都是一个单值的标签，类似于使用docker run的效果。

```yaml
cpu_shares: 73
cpu_quota: 50000
cpuset: 0,1

user: postgresql
working_dir: /code

domainname: foo.com
hostname: foo
ipc: host
mac_address: 02:42:ac:11:65:43

mem_limit: 1000000000
memswap_limit: 2000000000
privileged: true

restart: always

read_only: true
shm_size: 64M
stdin_open: true
tty: true
```

### 37. 环境变量

环境变量可以用来配置Docker-Compose的行为。

```
COMPOSE_PROJECT_NAME
```

设置通过Compose启动的每一个容器前添加的项目名称，默认是当前工作目录的名字。

```
COMPOSE_FILE
```

设置docker-compose.yml模板文件的路径。默认路径是当前工作目录。

```
DOCKER_HOST
```

设置Docker daemon的地址。默认使用unix:///var/run/docker.sock。 DOCKER_TLS_VERIFY
如果设置不为空，则与Docker daemon交互通过TLS进行。

```
DOCKER_CERT_PATH
```

配置TLS通信所需要的验证(ca.pem、cert.pem 和 key.pem)文件的路径，默认是 ~/.docker 。

## 五、使用示例

### 1. docker-compose 模板文件编写

docker-compose.yaml文件如下：

```yaml
version: '2'
services:
  web1:
    image: nginx
    ports: 
      - "6061:80"
    container_name: "web1"
    networks:
      - dev
  web2:
    image: nginx
    ports: 
      - "6062:80"
    container_name: "web2"
    networks:
      - dev
      - pro
  web3:
    image: nginx
    ports: 
      - "6063:80"
    container_name: "web3"
    networks:
      - pro

networks:
  dev:
    driver: bridge
  pro:
    driver: bridge

#volumes:
```

docker-compose.yaml文件指定了三个web服务。

### 2. 启动应用

创建一个webapp目录，将docker-compose.yaml文件拷贝到webapp目录下，使用docker-compose启动应用。

```shell
docker-compose up -d
```

### 3. 服务访问

通过浏览器访问web1，web2，web3服务:

```shell
http://127.0.0.1:6061
http://127.0.0.1:6062
http://127.0.0.1:6063
```

参考链接：

https://blog.51cto.com/9291927/2310444
https://www.jianshu.com/p/2217cfed29d7

原文链接：https://www.cnblogs.com/chenqionghe/p/10689947.html