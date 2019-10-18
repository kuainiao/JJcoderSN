# ELKB + kafka

------

# [#](http://www.liuwq.com/views/日志中心/elk_filebeat_kafka.html#架构图)架构图

![架构图](http://img.liuwenqi.com/blog/2019-07-24-025307.png)

# [#](http://www.liuwq.com/views/日志中心/elk_filebeat_kafka.html#elk-加入kafka-消息队列)ELK 加入Kafka 消息队列

> 在 elk-3 上面安装filebeat，通过filebeat 模板 抓取 system 日志

## [#](http://www.liuwq.com/views/日志中心/elk_filebeat_kafka.html#filebeat)filebeat

### [#](http://www.liuwq.com/views/日志中心/elk_filebeat_kafka.html#加载-system-系统模板)加载 system 系统模板

```shell
/etc/filebeat/m
filebeat modules enable system
修改
false true
```

### [#](http://www.liuwq.com/views/日志中心/elk_filebeat_kafka.html#filebeat-配置文件)filebeat 配置文件

```yml
vim /etc/filebeat/filebeat.yml
##关闭通过log方式获取
- type: log
	
  enabled: false
  #service: nginx_log
  # Paths that should be crawled and fetched. Glob based paths.
  paths:
    - /var/log/nginx/access.log
    - /var/log/messages
    #- c:\programdata\elasticsearch\logs\*
    
## 开启模板监控
filebeat.config.modules:
  # Glob pattern for configuration loading
  path: ${path.config}/modules.d/*.yml

  # Set to true to enable config reloading
  reload.enabled: true

  # Period on which files under path should be checked for changes
  #reload.period: 10s
  
## 增加 output kafka输出  注释掉 elasticsearch和logstash输出

#output.elasticsearch:
#  # Array of hosts to connect to.
#  hosts: ["localhost:9200"]

output.kafka:
  hosts: ["elk-1:9092"]
  topic: "filebeat"
  codec.json:
    pretty: false


  # Optional protocol and basic auth credentials.
  #protocol: "https"
  #username: "elastic"
  #password: "changeme"

#----------------------------- Logstash output --------------------------------
#output.logstash:
#  #The Logstash hosts
#  hosts: ["127.0.0.1:5044"]
```

## [#](http://www.liuwq.com/views/日志中心/elk_filebeat_kafka.html#logstash)logstash

创建 文件

```
vim /opt/logstash-7.2.0/logstash_kafka.conf
input {
  kafka {
    bootstrap_servers => "elk-1:9092"
    topics => ["filebeat"]
    codec => json
  }
}

output {
  if [@metadata][pipeline] {
    elasticsearch {
      hosts => "http://localhost:9200"
      manage_template => false
      index => "system-%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
      # pipeline => "%{[@metadata][pipeline]}"
    }
  } else {
    elasticsearch {
      hosts => "http://localhost:9200"
      manage_template => false
      index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
    }
  }
}
```



### [#](http://www.liuwq.com/views/日志中心/elk_filebeat_kafka.html#启动logstash)启动logstash

```shell
cd /opt/logstash-7.2.0

nohup ./bin/logstash -f logstash_kafka.conf &
```



## [#](http://www.liuwq.com/views/日志中心/elk_filebeat_kafka.html#kabana)kabana

创建索引

![image-20190718023048860](http://img.liuwenqi.com/blog/2019-07-17-183050.png)