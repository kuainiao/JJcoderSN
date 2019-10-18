# open-falcon 自定义监控一些应用

------



## [#](http://www.liuwq.com/views/监控/openfalcon_mysql_select.html#openfalcon-通过python查询mysql数据上报)openfalcon 通过python查询mysql数据上报

### [#](http://www.liuwq.com/views/监控/openfalcon_mysql_select.html#思路)思路

主要是用python获取mysql数据，进行统计上报

[![img](http://img.liuwenqi.com/blog/2019-07-08-095706.jpg)](http://img.liuwenqi.com/blog/2019-07-08-095706.jpg)

### [#](http://www.liuwq.com/views/监控/openfalcon_mysql_select.html#python脚本)python脚本

> python 包 需要自行 通过 pip 安装

```python
#!-*- coding:utf8 -*-
## author:liuwenqi
## date: 2018-06-18
import requests
import time
import json
import pymysql
from decimal import *

db_config = {
    'host': 'IP', ## 数据库地址
    'port': 3306, ## 数据库端口
    'user': 'user', ## 数据库名称
    'password': 'password', ## 数据库地址
    'db': 'db_name', ## 数据库名
    'charset': 'utf8',
}

sql_get_order_10min_true='SQL'
sql_get_order_10min_false='SQL'
sql_get_order_yesterday_true='SQL'
sql_get_order_lastweek_true='SQL'
sql_get_order_yesterday_false='SQL'
sql_get_order_lastweek_false='SQL'
sql_get_order_one_min_true='SQL'

def sql_check(order_type):
    conn = pymysql.connect(**db_config)
    cur = conn.cursor()
    if order_type == 0:
        sql = sql_get_order_10min_true
    elif order_type == 1:
        sql = sql_get_order_10min_false
    elif order_type == 2:
    sql = sql_get_order_yesterday_true
    elif order_type == 3:
    sql = sql_get_order_yesterday_false
    elif order_type == 4:
    sql = sql_get_order_lastweek_true
    elif order_type == 5:
    sql = sql_get_order_one_min_true
    else:
    sql = sql_get_order_lastweek_false
    rv = cur.execute(sql)
    res = cur.fetchall()
    cur.close()
    return int(res[0][0])

def count_success_percent(success,fail):
    success_percent_data = Decimal(success)/(Decimal(success) + Decimal(fail))*100
    success_percent = round(success_percent_data,3)
    return success_percent

ts = int(time.time())
order_today_success = sql_check(0)
order_today_fail = sql_check(1)
order_yesterday_success= sql_check(2)
order_yesterday_fail = sql_check(3)
order_lastweek_success = sql_check(4)
order_lastweek_fail = sql_check(6)
order_min_true = sql_check(5)
today_success_percent = count_success_percent(order_today_success,order_today_fail)
yesterday_success_percent = count_success_percent(order_yesterday_success,order_yesterday_fail)


payload = [
    {
        "endpoint": "order_data",
        "metric": "今日订单成功数",
        "timestamp": ts,
        "step": 60,
        "value": order_today_success,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": "order_data",
        "metric": "昨日订单成功数",
        "timestamp": ts,
        "step": 60,
        "value": order_yesterday_success,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": "order_data",
        "metric": "上周订单成功数",
        "timestamp": ts,
        "step": 60,
        "value": order_lastweek_success,
        "counterType": "GAUGE",
        "tags": "",
    },


    {
        "endpoint": "order_data",
        "metric": "today_order_count_fail",
        "timestamp": ts,
        "step": 60,
        "value": order_today_fail,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": "order_data",
        "metric": "yesterday_order_count_fail",
        "timestamp": ts,
        "step": 60,
        "value": order_yesterday_fail,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": "order_data",
        "metric": "lastweek_order_count_fail",
        "timestamp": ts,
        "step": 60,
        "value": order_lastweek_fail,
        "counterType": "GAUGE",
        "tags": "",
    },

    {
        "endpoint": "order_data",
        "metric": "今日订单成功率",
        "timestamp": ts,
        "step": 60,
        "value": today_success_percent,
        "counterType": "GAUGE",
        "tags": "",
    },
    {
        "endpoint": "order_data",
        "metric": "昨日订单成功率",
        "timestamp": ts,
        "step": 60,
        "value": yesterday_success_percent,
        "counterType": "GAUGE",
        "tags": "",
    },

    {
        "endpoint": "order_data",
        "metric": "每分钟订单成功数",
        "timestamp": ts,
        "step": 60,
        "value": order_min_true,
        "counterType": "GAUGE",
        "tags": "",
    }

]

r = requests.post("http://127.0.0.1:1988/v1/push", data=json.dumps(payload))

print r.text
```



### [#](http://www.liuwq.com/views/监控/openfalcon_mysql_select.html#效果图)效果图

**openfalcon screen**

[![img](http://img.liuwenqi.com/blog/2019-07-08-100214.jpg)](http://img.liuwenqi.com/blog/2019-07-08-100214.jpg)

**Grafana**

[![img](http://img.liuwenqi.com/blog/2019-07-08-100250.jpg)](http://img.liuwenqi.com/blog/2019-07-08-100250.jpg)