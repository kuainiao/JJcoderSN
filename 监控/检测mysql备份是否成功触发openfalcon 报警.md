# 检测mysql备份是否成功触发openfalcon 报警

------



## [#](http://www.liuwq.com/views/监控/openfalcon_python.html#openfalcon-监控mysql备份报警)openfalcon 监控mysql备份报警

> 思路：mysql备份输出日志 检测 errr 等相关字段 判断成功与否，将1或者0 传入openfalcon

### [#](http://www.liuwq.com/views/监控/openfalcon_python.html#python-检测脚本)python 检测脚本

> 执行python脚本的服务器 要有日志、已经安装并运行的openfalcon 客户端

```python
#!-*- coding:utf8 -*-
# author: liuwenqi 
# date: 2018-07-11
import os
import requests
import time
import json
import  socket

## 环境变量

log_dir ='/Users/kame/code/scripts/test_tmp'  ## 日志地址
scp_success='scp success!'  ## 判断成功与否字符串
scp_fail = 'scp failure!'
backup_success = 'innobackupex full backup complete !'
backup_fail = 'innobackupex full backup failure!'
hostname = socket.gethostname()   ## 获取 hostname


def scp_replace(log_dir):

    os.environ['log_dir']=str(log_dir)
    log_dir_os = os.popen("cat $log_dir | grep `date +%Y%m%d`")
    file_tmp = log_dir_os.read()
    ## 判断scp是否成功
    if scp_success in file_tmp:
        scp_staus = 0
    else :
        scp_staus = 1
    return scp_staus

def back_replace(log_dir):

    os.environ['log_dir']=str(log_dir)
    log_dir_os = os.popen("cat $log_dir | grep `date +%Y%m%d`")
    file_tmp = log_dir_os.read()
    ## 判断backup
    if backup_success in file_tmp:
        backup_staus = 0

        #print(backup_staus)
    else:
        backup_staus = 1
        #print(backup_staus)
    return backup_staus



open_env_scp_status = scp_replace(log_dir)
open_env_back_status = back_replace(log_dir)

print(open_env_scp_status)
print(open_env_back_status)

ts = int(time.time())
payload = [
    {
        "endpoint": hostname,
        "metric": "scp_status",
        "timestamp": ts,
        "step": 60,
        "value": open_env_scp_status,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": hostname,
        "metric": "backup_status",
        "timestamp": ts,
        "step": 60,
        "value": open_env_back_status,
        "counterType": "GAUGE",
        "tags": "",
    },


]

r = requests.post("http://127.0.0.1:1988/v1/push", data=json.dumps(payload))

print r.text
```

### [#](http://www.liuwq.com/views/监控/openfalcon_python.html#openfalcon-报警设置)openfalcon 报警设置

[![img](http://img.liuwenqi.com/blog/2019-07-08-100424.jpg)](http://img.liuwenqi.com/blog/2019-07-08-100424.jpg)

设置 报警触发 ，然后设置 hostGroups 绑定templates