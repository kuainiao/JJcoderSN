# Centos7安装elasticsearch7.5.1 kibana7.5.1和elasticsearch-head
环境
1.两个节点(centos7)
192.168.122.104
192.168.122.105
2.安装包
https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.1-linux-x86_64.tar.gz

https://artifacts.elastic.co/downloads/kibana/kibana-7.5.1-linux-x86_64.tar.gz

https://nodejs.org/dist/v13.3.0/node-v13.3.0-linux-x64.tar.xz

安装
默认已安装jdk8



## 1.安装elasticsearch集群
修改配置

### 104master

```
# cd /usr/soft/es

# mkdir logs

# mkdir data

# tar -zxvf elasticsearch-7.5.1-linux-x86_64.tar.gz

# mv elasticsearch-7.5.1-linux-x86_64 elasticsearch-7.5.1

############修改配置文件

# vi /elasticsearch-7.5.1/config/elasticsearch.yml

 cluster.name: my-application# 集群名称
 node.name: master   # 节点名
 network.host: 0.0.0.0  # 设置为0.0.0.0可以让任何计算机节点访问
 discovery.zen.ping.unicast.hosts: ["192.168.6.136","192.168.6.137"]#hosts列表
 discovery.zen.minimum_master_nodes: ["master"] 

 path.data: /usr/es/data
 path.logs: /usr/es/logs

 ## 如下配置是为了解决 Elasticsearch可视化工具 跨域问题

 http.port: 9200
 http.cors.allow-origin: "*"
 http.cors.enabled: true
```


### 137node

```
# cd /usr/soft/es

# mkdir logs

# mkdir data

# tar -zxvf elasticsearch-7.5.1-linux-x86_64.tar.gz

# mv elasticsearch-7.5.1-linux-x86_64 elasticsearch-7.5.1

///修改配置文件

# vi /elasticsearch-7.5.1/conf/elasticsearch.yml

 cluster.name: my-application# 集群名称
 node.name: node1# 节点名
 network.host: 0.0.0.0  # 设置为0.0.0.0可以让任何计算机节点访问
 discovery.zen.ping.unicast.hosts: ["192.168.6.136","192.168.6.137"]#hosts列表
 discovery.zen.minimum_master_nodes: ["master"]

 path.data: /usr/es/data
 path.logs: /usr/es/logs

 ## 如下配置是为了解决 Elasticsearch可视化工具 跨域问题

 http.port: 9200
 http.cors.allow-origin: "*"
 http.cors.enabled: true
```


### 创建用户

```
  # groupadd es

  # useradd es -g es

  # chown -R esUser:esUser /usr/es
```

### 修改配置（如果需要修改）

```
 vi elasticsearch-7.5.1/config/jvm.options   

  #修改如下配置
  -Xms512m
  -Xmx512m
```

### 启动

```
  # /usr/es/elasticsearch-7.5.1/bin -d //加-d后台启动

  #设置开机自启动

  # systemctl enable elasticsearch.service
```


### 访问

```
192.168.6.136:9200
```

## 2.安装elasticsearch-head
需要git nodejs

安装node和git
tar

```
# cd /usr/soft/node

# xz -d node-v12.14.0-linux-x64.tar.xz

# tar -xvf node-v12.14.0-linux-x64.tar

# mv node-v12.14.0-linux-x64-linux-x64 node-v12.14.0-linux-x64

///配置环境变量

# vi /etc/profile

export NODE_HOME=/usr/sofe/node/node-v12
export PATH=$PATH:$NODE_HOME/bin

# source /etc/profile

///或者添加软连接
ln -s /usr/node/node-v12/bin/node /usr/bin/node
ln -s /usr/node/node-v12/bin/npm /usr/bin/npm
```

### yum

```
///安装git

# yum install git

///下载

# git clone https://github.com/mobz/elasticsearch-head.git

///安装nodejs环境

# yum install nodejs
```


### 查看

```
  # node -v

  # npm -v
```


### 初始化

```
  ///安装 (elasticsearch-head目录下执行)

  # npm install
```


如果报如下错误

```
Phantom installation failed { Error: Command failed: tar jxf /tmp/phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2
tar (child): bzip2：无法 exec: 没有那个文件或目录


```

```
yum install -y bzip2
```


### 配置

```
  # cd elasticsearch-head

  ///修改Gruntfile.js

  # vi Gruntfile.js

  # connect:{

  server:{
     options:{
  hostname: "192.168.6.136",//或者”*“表示所有
  port: 9100,
  base: '.',
  keepalive: true
     } 
  }
  }
  ///修改elasticsearch-head默认连接地址

  # cd elasticsearch-head/_site/

  # vi app.js

   将this.base_uri = this.config.base_uri || 
   this.prefs.get("app-base_uri") || "http://localhost:9200";
   中的localhost修改成服务器地址：192.168.6.136:9200
```


### 启动

```
  1种

  # cd elasticsearch-head 

  # npm run start

  2种

  # cd elasticsearch-head 

  # node_modules/grunt/bin/grunt server
```


访问192.168.6.136:9100

## 3.安装kibana

```
# cd /usr/soft/kibana

# tar -xvf kibana-7.5.1-linux-x86_64.tar.gz

# mv kibana-7.5.1-linux-x86_64 kibana-7.5.1
```


### 配置

```
  # cd /usr/soft/kibana/kibana-7.5.1

  # vi /config/kibana.yml

  server.port: 5601
  server.host: "192.168.6.136"
  server.name: "kibana.com"
  elasticsearch.hosts: ["http://192.168.6.136:9200"]
  kibana.index: ".kibana" # kibana会将部分数据写入es，这个是ex中索引的名字

  ///启动警告Generating a random key for xpack.reporting.encryptionKey. 添加
  xpack.reporting.encryptionKey: "a_random_string"
  xpack.security.encryptionKey: "something_at_least_32_characters"
```


### 启动

```
  # cd /usr/soft/kibana/kibana-7.5.1

  # /bin/kibana

  ///后台启动

  # /bin/kibana &
```


访问 http://192.168.6.136:5601


