# Elastalert ELK 报警

> Elastalert是Yelp公司用python2.6写的一个报警框架，github地址为 https://github.com/Yelp/elastalert

## Install

> 环境依赖 python 2.7

```shell
git clone https://github.com/Yelp/elastalert

yum -y install python-pip
pip install --upgrade pip
easy_install -U setuptools
Pip install -r requirements.txt
Python setup.py install
```



#### 安装过程问题处理

```shell
Running blist-1.3.6/setup.py -q bdist_egg –dist-dir /tmp/easy_install-Gc6gbe/blist-1.3.6/egg-dist-tmp-Ik7LL2
The required version of setuptools (>=1.1.6) is not available,
and can’t be installed while this script is running. Please
install a more recent version first, using
‘easy_install -U setuptools’.

(Currently using setuptools 0.9.8 (/usr/lib/python2.7/site-packages))
```

解决办法

```shell
easy_install -U setuptools
```

```shell
easy_install PyOpenSSL error
```

解决方法

```shell
easy_install PyOpenSSL
```

### 在elasticsearch中创建elastalert的日志索引

```
elastalert-create-index
```

### 创建配置文件

```shell
cp config.yaml.example config.yaml
vi config.yaml
文件内容修改
run_every:
  minutes: 1

buffer_time:
  minutes: 15

es_host: log.example.com ## es地址

es_port: 9200 ## es端口

use_ssl: True

es_send_get_body_as: GET

es_username: es_admin

es_password: es_password

writeback_index: elastalert_status

alert_time_limit:
  days: 2
```

### 配置报警规则

```shell
cd example_rules/

sudo cp example_frequency.yaml my_rule.yaml

sudo vi my_rule.yaml
```

> my_rule.yaml 对应配置

```yaml
es_host: log.example.com
es_port: 9200
use_ssl: True
es_username: es_admin
es_password: es_password
#name属性要求唯一，这里最好能标示自己的产品
name: My-Product Exception Alert
#类型，我选择任何匹配的条件都发送邮件警告
type: any
#需要监控的索引，支持通配
index: logstash-*
#下面两个随意配置
num_events: 50
timeframe:
  hours: 4
#根据条件进行过滤查询（这里我只要出现异常的日志，并且排除业务异常（自定义异常））
filter:
- query:
    query_string:
      query: "message: *exception* AND message: (!*BusinessException*) AND message: (!*ServiceException*)"
#email的警告方式
alert:
- "email"

#增加邮件内容，这里我附加一个日志访问路径
alert_text: "Ref Log https://log.example.com:5601/app/kibana"
#SMTP协议的邮件服务器相关配置（我这里是腾讯企业邮箱）
smtp_host: smtp.exmail.qq.com
smtp_port: 25
#用户认证文件，需要user和password两个属性
smtp_auth_file: smtp_auth_file.yaml
email_reply_to: no-reply@example.com
from_addr: no-reply@example.com

#需要接受邮件的邮箱地址列表
email:
- "user1@example.com"
- "user1@example.com"
```

### 配置 smtp_auth_file.yaml

```shell
sudo touch smtp_auth_file.yaml
sudo vi smtp_auth_file.yaml

##配置文件内容
user: "no-reply@example.com"
password: "password"
```

### 检测 配置文件是否正确

```shell
elastalert-test-rule ./my_rule.yaml
```

### 运行

```shell
python -m elastalert.elastalert --verbose --rule my_rule.yaml
```

### system 自启动

```shell
sudo mkdir /etc/elastalert
cd /etc/elastalert
-- 复制配置文件

sudo cp /usr/local/dev/elastalert/config.yaml config.yaml
sudo mkdir rules
cd rules

-- 复制规则文件
sudo cp /usr/local/dev/elastalert/example_rules/my_rule.yaml my_rule.yaml

-- 复制邮件用户认证文件
sudo cp /usr/local/dev/elastalert/example_rules/smtp_auth_file.yaml smtp_auth_file.yaml
```

#### 修改config.yaml

```yml
rules_folder: /etc/elastalert/rules
```

#### 修稿 my_rule.yaml

```yaml
smtp_auth_file: /etc/elastalert/rules/umu_smtp_auth_file.yaml
```

#### 创建systemd 服务

```yml
cd /etc/systemd/system
sudo touch elastalert.service

sudo vi elastalert.service
内容：
[Unit]
Description=elastalert
After=elasticsearch.service

[Service]
Type=simple
User=root
Group=root
Restart=on-failure
WorkingDirectory=/usr/local/dev/elastalert
ExecStart=/usr/bin/elastalert --config /etc/elastalert/config.yaml --rule /etc/elastalert/rules/my_rule.yaml

[Install]
WantedBy=multi-user.target
```

#### 启动

```
systemctl start elastalert
```