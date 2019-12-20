# docker-compose快速搭建 Prometheus+Grafana监控系统

## 说明

`Prometheus`负责收集数据，Grafana负责展示数据。

其中采用Prometheus 中的 Exporter含：
**1）**`Node Exporter`，负责收集 host 硬件和操作系统数据。它将以容器方式运行在所有 host 上。
2）`cAdvisor`，负责收集容器数据。它将以容器方式运行在所有 host 上。
3）`Alertmanager`，负责告警。它将以容器方式运行在所有 host 上。

## 安装docker，docker-compose

### 安装docker

先安装一个64位的Linux主机，其内核必须高于3.10，内存不低于1GB。在该主机上安装Docker。

```
# 安装依赖包
yum install -y yum-utils device-mapper-persistent-data lvm2
# 添加Docker软件包源
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# 安装Docker CE
yum install docker-ce -y
# 启动
systemctl start docker
# 开机启动
systemctl enable docker
# 查看Docker信息
docker info
```

### 安装docker-compose

```
curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## 添加配置文件

```
mkdir -p /usr/local/src/config
cd /usr/local/src/config
```



### 添加prometheus.yml配置文件，

vim prometheus.yml

```
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets: ['192.168.159.129:9093']
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  - "node_down.yml"
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.159.129:9090']

  - job_name: 'cadvisor'
    static_configs:
    - targets: ['192.168.159.129:8080']

  - job_name: 'node'
    scrape_interval: 8s
    static_configs:
      - targets: ['192.168.159.129:9100']
```

### 添加邮件告警配置文件

添加配置文件alertmanager.yml，配置收发邮件邮箱
vim alertmanager.yml

```
global:
  smtp_smarthost: 'smtp.163.com:25'　　#163服务器
  smtp_from: 'tsiyuetian@163.com'　　　　　　　　#发邮件的邮箱
  smtp_auth_username: 'tsiyuetian@163.com'　　#发邮件的邮箱用户名，也就是你的邮箱
  smtp_auth_password: 'TPP***'　　　　　　　　#发邮件的邮箱密码
  smtp_require_tls: false　　　　　　　　#不进行tls验证

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 10m
  receiver: live-monitoring

receivers:
- name: 'live-monitoring'
  email_configs:
  - to: '1933306137@qq.com'　　　　　　　　#收邮件的邮箱
```

### 添加报警规则

添加一个node_down.yml为 prometheus targets 监控
vim node_down.yml

```
groups:
- name: node_down
  rules:
  - alert: InstanceDown
    expr: up == 0
    for: 1m
    labels:
      user: test
    annotations:
      summary: "Instance {{ $labels.instance }} down"
      description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minutes."
```



## 编写docker-compose

vim docker-compose-monitor.yml

```
version: '2'

networks:
    monitor:
        driver: bridge

services:
    prometheus:
        image: prom/prometheus
        container_name: prometheus
        hostname: prometheus
        restart: always
        volumes:
            - /usr/local/src/config/prometheus.yml:/etc/prometheus/prometheus.yml
            - /usr/local/src/config/node_down.yml:/etc/prometheus/node_down.yml
        ports:
            - "9090:9090"
        networks:
            - monitor

    alertmanager:
        image: prom/alertmanager
        container_name: alertmanager
        hostname: alertmanager
        restart: always
        volumes:
            - /usr/local/src/config/alertmanager.yml:/etc/alertmanager/alertmanager.yml
        ports:
            - "9093:9093"
        networks:
            - monitor

    grafana:
        image: grafana/grafana
        container_name: grafana
        hostname: grafana
        restart: always
        ports:
            - "3000:3000"
        networks:
            - monitor

    node-exporter:
        image: prom/node-exporter
        container_name: node-exporter
        hostname: node-exporter
        restart: always
        ports:
            - "9100:9100"
        networks:
            - monitor

    cadvisor:
        image: google/cadvisor:latest
        container_name: cadvisor
        hostname: cadvisor
        restart: always
        volumes:
            - /:/rootfs:ro
            - /var/run:/var/run:rw
            - /sys:/sys:ro
            - /var/lib/docker/:/var/lib/docker:ro
        ports:
            - "8080:8080"
        networks:
            - monitor
```

## 启动docker-compose

```
#启动容器：
docker-compose -f /usr/local/src/config/docker-compose-monitor.yml up -d
#删除容器：
docker-compose -f /usr/local/src/config/docker-compose-monitor.yml down
#重启容器：
docker restart id
```

**容器启动如下：**
![docker-compose快速搭建 Prometheus+Grafana监控系统](docker-compose%E5%AE%89%E8%A3%85prometheus.assets/169c8390657dc3ea)

**prometheus targets界面如下：**
![docker-compose快速搭建 Prometheus+Grafana监控系统](docker-compose%E5%AE%89%E8%A3%85prometheus.assets/169c8390656cf8a1)

**备注：**如果State为Down，应该是防火墙问题，参考下面防火墙配置。

**prometheus graph界面如下：**
![docker-compose快速搭建 Prometheus+Grafana监控系统](docker-compose%E5%AE%89%E8%A3%85prometheus.assets/169c83906593ab57)

**备注：**如果没有数据，同步下时间。



## 防火墙配置

### 关闭selinux

```
setenforce 0
vim /etc/sysconfig/selinux
```

### 配置iptables

```
#删除自带防火墙
systemctl stop firewalld.service
systemctl disable firewalld.service
#安装iptables
yum install -y iptables-services
#配置
vim /etc/sysconfig/iptables
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [24:11326]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 9090 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 3000 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 9093 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 9100 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
#启动
systemctl restart iptables.service
systemctl enable iptables.service
```

## 配置Grafana

### 添加Prometheus数据源

![docker-compose快速搭建 Prometheus+Grafana监控系统](docker-compose%E5%AE%89%E8%A3%85prometheus.assets/169c83906599ee28)



### 配置dashboards

**说明：**可以用自带模板，也可以去https://grafana.com/dashboards，下载对应的模板。

### 查看数据

我从网页下载了docker相关的模板：Docker and system monitoring，893
![docker-compose快速搭建 Prometheus+Grafana监控系统](docker-compose%E5%AE%89%E8%A3%85prometheus.assets/169c839065b3d730)
输入893，就会加载出下面的信息
![docker-compose快速搭建 Prometheus+Grafana监控系统](docker-compose%E5%AE%89%E8%A3%85prometheus.assets/169c83908c9b55c7)



导入后去首页查看数据
![docker-compose快速搭建 Prometheus+Grafana监控系统](docker-compose%E5%AE%89%E8%A3%85prometheus.assets/169c83908ee09e6e)

## 附录：单独命令启动各容器

```
#启动prometheus
docker run -d -p 9090:9090 --name=prometheus \
-v /usr/local/src/config/prometheus.yml:/etc/prometheus/prometheus.yml \
-v /usr/local/src/config/node_down.yml:/etc/prometheus/node_down.yml \
prom/prometheus

# 启动grafana
docker run -d -p 3000:3000 --name=grafana grafana/grafana

#启动alertmanager容器
docker run -d -p 9093:9093 -v /usr/local/src/config/config.yml:/etc/alertmanager/config.yml --name alertmanager prom/alertmanager

#启动node exporter
docker run -d \
  -p 9100:9100 \
  -v "/:/host:ro,rslave" \
  --name=node_exporter \
 prom/node-exporter \
  --path.rootfs /host

#启动cadvisor
docker run                                    \
--volume=/:/rootfs:ro                         \
--volume=/var/run:/var/run:rw                 \
--volume=/sys:/sys:ro                         \
--volume=/var/lib/docker/:/var/lib/docker:ro  \
--publish=8080:8080                           \
--detach=true                                 \
--name=cadvisor                               \
google/cadvisor:latest
```