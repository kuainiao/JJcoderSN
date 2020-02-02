# docker安装elasticsearch

## 前言

安装es么，也没什么难的，主要网上搜一搜，看看文档，但是走过的坑还是需要记录一下的 主要参考这三份文档：

- [`Running the Elastic Stack on Docker`](https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-docker.html)
- [`docker简易搭建ElasticSearch集群`](https://blog.csdn.net/belonghuang157405/article/details/83301937)
- [`Running Kibana on Docker`](https://www.elastic.co/guide/en/kibana/6.7/docker.html)

最新的修改：更新了官网的docker-compose.yml文件-- 2019-12-30

## 安装es

直接docker pull elasticsearch显示没有这个tag所以去dockerhub看了下tag，加上了版本号6.7.0

#### 拉取镜像

```
docker pull elasticsearch:6.7.0
```

#### 创建es的挂载目录以及配置文件：

```
mkdir-p /home/jjcoder/Documents/DBA/ElasticSearch/es
cd  /home/jjcoder/Documents/DBA/ElasticSearch/es
mkdir config
mkdir matser
mkdir slave
chmod 777 master
chmod 777 slave
```

config 里面分别放两个配置文件

```
cd config
touch master.yml
touch slave.yml
```

matser.yml

```
cluster.name: elasticsearch-cluster
node.name: master
network.bind_host: 0.0.0.0
network.publish_host: `your ip`
http.port: 9200
transport.tcp.port: 9300
http.cors.enabled: true
http.cors.allow-origin: "*"
node.master: true 
node.data: true  
discovery.zen.ping.unicast.hosts: [" `your ip`:9300"," `your ip`:9301"]
```

slave.yml

```
cluster.name: elasticsearch-cluster
node.name: slave
network.bind_host: 0.0.0.0
network.publish_host: `your ip`
http.port: 9202
transport.tcp.port: 9302
http.cors.enabled: true
http.cors.allow-origin: "*"
node.master: false
node.data: true  
discovery.zen.ping.unicast.hosts: ["`your ip`:9300","`your ip`:9301"]
```

#### 调高JVM线程数限制数量（不然启动容器的时候会报错，亲身试验）

```
vim /etc/sysctl.conf
# 添加这个
vm.max_map_count=262144 
# 保存后执行这个命令
sysctl -p
```

#### 初始化容器

master

```
docker run -e ES_JAVA_OPTS="-Xms256m -Xmx256m" -d -p 9200:9200 -p 9300:9300 -v /home/jjcoder/Documents/DBA/ElasticSearch/es/config/master.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /home/jjcoder/Documents/DBA/ElasticSearch/es/master:/usr/share/elasticsearch/data --name es-master elasticsearch:6.7.0
```

slave

```
 docker run -e ES_JAVA_OPTS="-Xms256m -Xmx256m" -d -p 9201:9201 -p 9301:9301 -v /home/jjcoder/Documents/DBA/ElasticSearch/es/config/slave.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /home/jjcoder/Documents/DBA/ElasticSearch/es/slave:/usr/share/elasticsearch/data --name es-slave elasticsearch:6.7.0
```

#### 校验是否安装成功

浏览器访问 `http://yourip:9200`

## 安装kibana

刚开始装的时候看网上的教程来，一直连不上es，直接去官网找文档了，具体如下

```
docker pull kibana:6.7.0
docker run --link es-master:elasticsearch -p 5601:5601 --name kibana -d kibana:6.7.0
```

访问 `http://yourip:5601`



![img](docker%E5%AE%89%E8%A3%85elasticsearch.assets/169d44b78d558089)



## 使用compose安装7.3.1版本

因为有过经验了，直接去dockerhub上看安装教程

第一步：调线程数,详情见上面操作

第二步：编写docker-compose.yml

```
version: '2.2'
services:
  es01:
    image: elasticsearch:7.5.1
    container_name: es01
    environment:
      - node.name=es01
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es02
      - cluster.initial_master_nodes=es01,es02
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - data01:/home/jjcoder/Documents/DBA/ElasticSearch/data
    ports:
      - 9200:9200
    networks:
      - elastic
  es02:
    image: elasticsearch:7.5.1
    container_name: es02
    environment:
      - node.name=es02
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es01
      - cluster.initial_master_nodes=es01,es02
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - data02:/home/jjcoder/Documents/DBA/ElasticSearch/data
    networks:
      - elastic
  kibana:
    image: kibana:7.5.1
    container_name: kibana
    restart: always
    ports:
      - "5601:5601"
    environment:
      I18N_LOCALE: zh-CN
    networks:
      - elastic
    links:
      - es01:elasticsearch
volumes:
  data01:
    driver: local
  data02:
    driver: local
networks:
  elastic:
    driver: bridge
```

安装中出的问题，备注里说了



![img](docker%E5%AE%89%E8%A3%85elasticsearch.assets/16d054d33fc6f48d)



第三步：

```
docker-compose up -d
```