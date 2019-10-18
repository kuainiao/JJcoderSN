# ELK 安装配置

------



# [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#架构图)架构图

![架构图](http://i.imgur.com/G1IS6v8.png)

## [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#一、logstash-agent-端-安装配置)一、logstash agent 端 安装配置

### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_1-logstash下载安装配置（web-nginx-agent）)1.logstash下载安装配置（web_nginx agent）

```shell
wget https://download.elastic.co/logstash/logstash/logstash-2.2.2.tar.gz
tar -xf logstash-2.2.2.tar.gz
cd logstash
>>安装JAVA
yum install java-1.8.0-openjdk.x86_64
```

### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_2-添加logstash配置文件)2.添加logstash配置文件

```shell
vim shipper.conf
input {
     file{
         type => "nginx-www-access"
             path => "/app/nginx/logs/*access.log"
             exclude => "vlog_access.log"
             start_position => "end"
     }

}

filter {
     if [type] == 'nginx-www-access' or [type] == 'flash-vlog' {
         date {
           match => [ "timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]
         }
         grok {
             match => { "message" => "%{NGINXACCESS}" }
         }
         mutate {
             gsub => ["x_forwarded_for", ",.*", ""]
         }

         if [x_forwarded_for] == '-' {
             mutate {
                 replace => { "x_forwarded_for" => "%{clientip}" }
             }
         }

         mutate {
            convert => [ "upstream_response_time", "float"]
         }
         mutate {
            convert => [ "request_time", "float"]
         }


         geoip {
            source => "x_forwarded_for"
            target => "geoip"
            add_field => [ "[geoip][coordinates]", "%{[geoip][longitude]}" ]
            add_field => [ "[geoip][coordinates]", "%{[geoip][latitude]}"  ]
         }
         mutate {
            convert => [ "[geoip][coordinates]", "float"]
         }


     }
}
output {
     redis{
         host => "IP"
         data_type => "list"
         key => "logstash:web"
         port => "6379"
     }
}
```

### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#添加logstash-nginx日志格式配置)添加logstash nginx日志格式配置

```shell
mkdir -p logstash_dir/patterns
cd logstash_dir/patterns
vim nginx

**添加如下内容**

NGINXACCESS %{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "(?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:httpversion})?|%{DATA:rawrequest})" %{NUMBER:response} (?:%{NUMBER:bytes}|-) %{QS:referrer} %{QS:agent} "%{DATA:x_forwarded_for}" %{DATA:request_body} %{IPORHOST:httphost} "%{DATA:cookie}" (?:%{NUMBER:upstream_response_time:float}|-) (?:%{NUMBER:request_time:float}|-)

**修改nginx 配置文件**

 log_format  short '$remote_addr - $remote_user [$time_local] "$request" ' '$status $body_bytes_sent "$http_referer" ' '"$http_user_agent" "$http_x_forward
    ed_for" $request_body $host "$http_cookie" ' '$upstream_response_time $request_time ';
 重新加载  nginx 配置文件
```

## [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#二、安装redis)二、安装redis

### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_2-1安装配置redis)2.1安装配置redis

```shell
wget 下载源码包
解压
cd   dir
make test
make prefix=/dir/  install
```

### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_2-2配置文件修改)2.2配置文件修改

daemonize yes save 900 1 save 300 10 save 60 10000

## [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#三、服务器端elk安装和配置)三、服务器端ELK安装和配置

### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_3-1-logstash-server)3.1 logstash-server

#### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_3-1-1-安装)3.1.1 安装

```shell
wget https://download.elastic.co/logstash/logstash/logstash-2.2.2.tar.gz
tar -xf logstash-2.2.2.tar.gz
cd logstash
>>安装JAVA
yum install java-1.8.0-openjdk.x86_64
```

#### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_3-1-2-配置文件更改)3.1.2 配置文件更改

```shell
input {
     redis {
         host => 'IP'
         data_type => 'list'
         port => "6379"
         key => 'logstash:web'
         type => 'redis-input'
         #threads => 5
         threads => 10
     }
}


output {
     #stdout { }
     elasticsearch {
         hosts => "IP:9200"
     }
}
./bin/logstash -f
```

### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_3-2-install-elasticsearch)3.2 install elasticsearch

#### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_3-2-1-安装)3.2.1 安装

```shell
wget https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.2.1/elasticsearch-2.2.1.tar.gz
tar -xf elasticsearch
cd elasticsearch
```

#### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_3-2-2-配置文件更改)3.2.2 配置文件更改

```shell
vim config/elasticsearch.yml
修改如下：
# network.host: 192.168.0.1 更改为本机IP
# http.port: 9200 端口默认为9200 iptables增加端口认证
./bin/elasticsearch
```

### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_3-3-安装配置-kibana)3.3 安装配置 kibana

#### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_3-3-1-安装)3.3.1 安装

```shell
wget https://download.elastic.co/kibana/kibana/kibana-4.4.2-linux-x64.tar.gz
tar -xf kibana
cd kibana
```

#### [#](http://www.liuwq.com/views/日志中心/ELK_Install_book.html#_3-3-2-配置文件更改)3.3.2 配置文件更改

> 修改配置文件

```shell
vim config/kibana.yml

# elasticsearch.url: "http://localhost:9200" 更改为elasticsearch IP
# kibana.index: ".kibana" 注释取消
# server.port: 5601
./bin/kibana
```