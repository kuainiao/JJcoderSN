# open-falcon 监控 nginx_status

------



# [#](http://www.liuwq.com/views/监控/open-falcon_nginx_status.html#openfalcon-监控-nginx-状态)openfalcon 监控 nginx 状态

> 主要使用 通过 agent push 数据至 server

## [#](http://www.liuwq.com/views/监控/open-falcon_nginx_status.html#思路)思路

由于我这边有两套nginx 需要计算综合

[![img](http://img.liuwenqi.com/blog/2019-07-08-095745.jpg)](http://img.liuwenqi.com/blog/2019-07-08-095745.jpg)

## [#](http://www.liuwq.com/views/监控/open-falcon_nginx_status.html#nginx-相关配置)nginx 相关配置

### [#](http://www.liuwq.com/views/监控/open-falcon_nginx_status.html#启用nginx-status配置)启用nginx status配置

在默认主机里面加上location或者你希望能访问到的主机里面。

```yml
server {
    listen  *:80 default_server;
    server_name _;
    location /ngx_status
    {
        stub_status on;
        access_log off;
        #allow 127.0.0.1;
        #deny all;
    }
}
```



### [#](http://www.liuwq.com/views/监控/open-falcon_nginx_status.html#打开status页面)打开status页面

```bash
curl http://127.0.0.1/ngx_status
Active connections: 11921
server accepts handled requests
 11989 11989 11991
Reading: 0 Writing: 7 Waiting: 42
```

### [#](http://www.liuwq.com/views/监控/open-falcon_nginx_status.html#nginx-status详解)nginx status详解

- active connections – 活跃的连接数量
- server accepts handled requests — 总共处理了11989个连接 , 成功创建11989次握手, 总共处理了11991个请求
- reading — 读取客户端的连接数.
- writing — 响应数据到客户端的数量
- waiting — 开启 keep-alive 的情况下,这个值等于 active – (reading+writing), 意思就是 Nginx 已经处理完正在等候下一次请求指令的驻留连接.

## [#](http://www.liuwq.com/views/监控/open-falcon_nginx_status.html#openfalcon-设置)openfalcon 设置

### [#](http://www.liuwq.com/views/监控/open-falcon_nginx_status.html#通过shell-获取nginx-数据值)通过shell 获取nginx 数据值

```bash
#!/bin/bash

nginx_17=${1}
nginx_18=${2}
nginx_status_name=${3}


nginx_active_connections(){
        active_connections_17=`curl -s http://${nginx_17}:18190/nginx_status | grep connections | awk '{print $3}'`
        active_connections_18=`curl -s http://${nginx_18}:18190/nginx_status | grep connections | awk '{print $3}'`
        let active_connections=($active_connections_17+$active_connections_18)
        echo $active_connections
}

nginx_reading(){
        reading_17=`curl -s http://${nginx_17}:18190/nginx_status | grep Reading | awk '{print $2}'`
        reading_18=`curl -s http://${nginx_18}:18190/nginx_status | grep Reading | awk '{print $2}'`
        let reading=($reading_17+$reading_18)
        echo $reading
}
nginx_writing(){
        writing_17=`curl -s http://${nginx_17}:18190/nginx_status | grep Reading | awk '{print $4}'`
        writing_18=`curl -s http://${nginx_18}:18190/nginx_status | grep Reading | awk '{print $4}'`
        let writing=($writing_17+$writing_18)
        echo $writing
}
nginx_waiting(){
        waiting_17=`curl -s http://${nginx_17}:18190/nginx_status | grep Reading | awk '{print $6}'`
        waiting_18=`curl -s http://${nginx_18}:18190/nginx_status | grep Reading | awk '{print $6}'`
        let waiting=($waiting_17+$waiting_18)
        echo $waiting
}



case "$nginx_status_name" in
nginx_active_connections)
nginx_active_connections
;;
nginx_reading)
nginx_reading
;;
nginx_writing)
nginx_writing
;;
nginx_waiting)
nginx_waiting
;;
*)
printf 'Usage: %s {nginx_active_connections|nginx_reading|nginx_writing|nginx_waiting}\n' "$prog"
exit 1
;;
esac
```

### [#](http://www.liuwq.com/views/监控/open-falcon_nginx_status.html#通过-python-push至-agent-http-api-接口)通过 python push至 agent http API 接口

**需要注意 运行python及shell 需要在同一台服务器**

**同时需要能访问nginx_status 端口权限**

```python
#!-*- coding:utf8 -*-
import os
import requests
import time
import json
import socket

## 环境变量
hostname = socket.gethostname()
nginx_17_ip = "IP"  ## nginx服务器IP
nginx_18_ip = "IP"

def nginx_active_connections(nginx17_ip,nginx_18_ip):
    os.environ['nginx_17_ip']=str(nginx_17_ip)
    os.environ['nginx_18_ip']=str(nginx_18_ip)
    connections_tmp =os.popen('/root/scripts/nginx_status.sh $nginx_17_ip $nginx_18_ip nginx_active_connections')
    connections = connections_tmp.read()
    #print(nginx_active_connections)
    return connections

def nginx_reading(nginx17_ip,nginx_18_ip):
    os.environ['nginx_17_ip']=str(nginx_17_ip)
    os.environ['nginx_18_ip']=str(nginx_18_ip)
    nginx_reading_tmp = os.popen('/root/scripts/nginx_status.sh $nginx_17_ip $nginx_18_ip nginx_reading')
    nginx_reading = nginx_reading_tmp.read()
    return nginx_reading

def nginx_writing(nginx17_ip,nginx_18_ip):
    os.environ['nginx_17_ip']=str(nginx_17_ip)
    os.environ['nginx_18_ip']=str(nginx_18_ip)
    nginx_writing_tmp = os.popen('/root/scripts/nginx_status.sh $nginx_17_ip $nginx_18_ip nginx_writing')
    nginx_writing = nginx_writing_tmp.read()
    return nginx_writing

def nginx_waiting(nginx17_ip,nginx_18_ip):
    os.environ['nginx_17_ip']=str(nginx_17_ip)
    os.environ['nginx_18_ip']=str(nginx_18_ip)
    nginx_waiting_tmp = os.popen('/root/scripts/nginx_status.sh $nginx_17_ip $nginx_18_ip nginx_waiting')
    nginx_waiting = nginx_waiting_tmp.read()
    return nginx_waiting

nginx_active_count = int(nginx_active_connections(nginx_17_ip,nginx_18_ip))
nginx_reading_count = int(nginx_reading(nginx_17_ip,nginx_18_ip))
nginx_writing_count = int(nginx_writing(nginx_17_ip,nginx_18_ip))
nginx_waiting_count = int(nginx_waiting(nginx_17_ip,nginx_18_ip))
nginx_waiting_count = int(nginx_waiting(nginx_17_ip,nginx_18_ip))

ts = int(time.time())
payload = [
    {
        "endpoint": hostname,
        "metric": "nginx.active.connections",
        "timestamp": ts,
        "step": 60,
        "value": nginx_active_count,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": hostname,
        "metric": "nginx.reading",
        "timestamp": ts,
        "step": 60,
        "value": nginx_reading_count,
        "counterType": "GAUGE",
        "tags": "",
    },
        {
        "endpoint": hostname,
        "metric": "nginx.writing",
        "timestamp": ts,
        "step": 60,
        "value": nginx_writing_count,
        "counterType": "GAUGE",
        "tags": "",
    },
        {
        "endpoint": hostname,
        "metric": "nginx.waiting",
        "timestamp": ts,
        "step": 60,
        "value": nginx_waiting_count,
        "counterType": "GAUGE",
        "tags": "",
    },
]

r = requests.post("http://127.0.0.1:1988/v1/push", data=json.dumps(payload))

print r.text
```

## [#](http://www.liuwq.com/views/监控/open-falcon_nginx_status.html#openfalcon-效果展示)openfalcon 效果展示

通过dashboard 查询相关数据

[![openfalcon_check](http://img.liuwenqi.com/blog/2019-07-08-095825.jpg)](http://img.liuwenqi.com/blog/2019-07-08-095825.jpg)

**Screen** [![openfalcon_nginx](http://img.liuwenqi.com/blog/2019-07-08-095901.jpg)](http://img.liuwenqi.com/blog/2019-07-08-095901.jpg) **Grafana** [![Grafana_nginx](http://img.liuwenqi.com/blog/2019-07-08-100149.jpg)](http://img.liuwenqi.com/blog/2019-07-08-100149.jpg)