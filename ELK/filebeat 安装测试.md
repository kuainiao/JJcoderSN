# filebeat 安装测试

------



# [#](http://www.liuwq.com/views/日志中心/filebeat.html#filebeat-安装配置)filebeat 安装配置

## [#](http://www.liuwq.com/views/日志中心/filebeat.html#安装)安装

把filebeat RPM包 传输至安装服务器

```
rpm -ivh filebeat-6.1.1-x86_64.rpm
```

## [#](http://www.liuwq.com/views/日志中心/filebeat.html#修改配置文件)修改配置文件

```yml
   vim /etc/filebeat/filebeat.yml
  参照如下进行修改：
   - type: log
     enabled: true
     paths:
       - /log/XXXX/all/XXXXX.log ## 例如为mysql日志路径文件

   ##IP地址为elasticsearch地址
   output.elasticsearch:
   # Array of hosts to connect to.
   hosts: ["10.XX.XX.XX:9200"]

   ## 修改huidu为mysql或者 MongoDB
   output.elasticsearch.index: "XXX-%{[beat.version]}-%{+yyyy.MM.dd}"
   setup.template.name: "XXXX"
   setup.template.pattern: "XXXX-*"
```



## [#](http://www.liuwq.com/views/日志中心/filebeat.html#启动filebeat)启动filebeat

```
service filebeat start` 检查下是否成功启动 `ps -ef | grep filebeat
      [root@Dxe18v12v82 ~]# ps -ef | grep filebeat
      root     21515 21501  0 15:10 pts/2    00:00:00 grep filebeat
      root     28385     1  0 Mar01 ?        00:00:00 /usr/share/filebeat/bin/filebeat-god -r / -n -p /var/run/filebeat.pid -- /usr/share/filebeat/bin/filebeat -c /etc/filebeat/filebeat.yml -path.home /usr/share/filebeat -path.config /etc/filebeat -path.data /var/lib/filebeat -path.logs /var/log/filebeat
      root     28386 28385  0 Mar01 ?        00:02:44 /usr/share/filebeat/bin/filebeat -c /e
```