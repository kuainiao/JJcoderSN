# **二进制方式部署k8s集群**

目标任务： 

1、Kubernetes集群部署架构规划 

2、部署Etcd集群 

3、在Node节点安装Docker 

4、部署Flannel网络 

5、在Master节点部署组件 

6、在Node节点部署组件 

7、查看集群状态 

8、运行一个测试示例 

9、部署Dashboard（Web UI）

 

### 1、Kubernetes集群部署架构规划

#### 操作系统：

```
  CentOS7.6_x64
```

#### 软件版本：

```
  Docker	18.09.0-ce

 Kubernetes	1.11
```

 #### 服务器角色、IP、组件：

```
 k8s-master1	     

10.206.240.188	kube-apiserver，kube-controller-manager，kube-scheduler，etc
```

```
k8s-master2	     

10.206.240.189	kube-apiserver，kube-controller-manager，kube-scheduler，etcd
```

```
k8s-node1	        

10.206.240.111	kubelet，kube-proxy，docker，flannel，etcd
```

```
 k8s-node2	        

10.206.240.112	kubelet，kube-proxy，docker，flannel
```

​    #### Master负载均衡	  

```
10.206.176.19	    LVS
```

​    #### 镜像仓库	             

```
 10.206.240.188	Harbor
```

#### 机器配置要求：

```
2G  
主机名称 必须改  必须解析
selinux 
```

### 拓扑图：

![img](/home/coder/mydisk/coder/Documents/JJcoder个人博客/jjcoderzero.github.io/images/k8s/DeepinScreenshot_select-area_20190921002125.png) 

### 负载均衡器：

​    #### 云环境：

​        可以采用slb

​    #### 非云环境：

​        主流的软件负载均衡器，例如LVS、HAProxy、Nginx

​        

这里采用Nginx作为apiserver负载均衡器，架构图如下： 

![img](/home/coder/mydisk/coder/Documents/JJcoder个人博客/jjcoderzero.github.io/images/k8s/DeepinScreenshot_select-area_20190921104327.png) 

 

2. 安装nginx使用stream模块作4层反向代理配置如下：

```yaml
user  nginx;
worker_processes  4;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {

	worker_connections  1024;

}
stream {
log_format  main  '$remote_addr $upstream_addr - [$time_local] $status $upstream_bytes_sent';

access_log  /var/log/nginx/k8s-access.log  main;

 upstream k8s-apiserver {
	server 10.206.240.188:6443;
	server 10.206.240.189:6443;

}
server {
	listen 6443;
	proxy_pass k8s-apiserver;
}

}
```

 

3. 部署Etcd集群

 使用cfssl来生成自签证书,任何机器都行，证书这块儿知道怎么生成、怎么用即可，暂且不用过多研究。

#### 下载cfssl工具：

```shell
\# wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64

\# wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

\# wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64

\# chmod +x cfssl_linux-amd64 cfssljson_linux-amd64 cfssl-certinfo_linux-amd64

\# mv cfssl_linux-amd64 /usr/local/bin/cfssl

\# mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

\# mv cfssl-certinfo_linux-amd64 /usr/bin/cfssl-certinfo


```

 

### 生成Etcd证书:

创建以下三个文件：

```
\# cat ca-config.json

{

  "signing": {

​    "default": {

​      "expiry": "87600h"

​    },

​    "profiles": {

​      "www": {

​         "expiry": "87600h",

​         "usages": [

​            "signing",

​            "key encipherment",

​            "server auth",

​            "client auth"

​        ]

​      }

​    }

  }

}
```

```
\# cat ca-csr.json

{

​    "CN": "etcd CA",

​    "key": {

​        "algo": "rsa",

​        "size": 2048

​    },

​    "names": [

​        {

​            "C": "CN",

​            "L": "Beijing",

​            "ST": "Beijing"

​        }

​    ]

}
```

```
# cat server-csr.json

{

​    "CN": "etcd",

​    "hosts": [

​    "10.206.240.188",

​    "10.206.240.189",

​    "10.206.240.111"

​    ],

​    "key": {

​        "algo": "rsa",

​        "size": 2048

​    },

​    "names": [

​        {

​            "C": "CN",

​            "L": "BeiJing",

​            "ST": "BeiJing"

​        }

​    ]

}
```

 

### 生成证书：

```
# cfssl gencert -initca ca-csr.json | cfssljson -bare ca -

\# cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=www server-csr.json | cfssljson -bare server

\# ls *pem

ca-key.pem  ca.pem  server-key.pem  server.pem
```

 

### 安装Etcd:

二进制包下载地址：

​    https://github.com/coreos/etcd/releases/tag/v3.2.12

​    

以下部署步骤在规划的三个etcd节点操作一样，唯一不同的是etcd配置文件中的服务器IP要写当前的：

解压二进制包：

```
# mkdir /opt/etcd/{bin,cfg,ssl} -p

\# tar zxvf etcd-v3.2.12-linux-amd64.tar.gz

\# mv etcd-v3.2.12-linux-amd64/{etcd,etcdctl} /opt/etcd/bin/


```

 

创建etcd配置文件：

```
\# cat /opt/etcd/cfg/etcd   

\#[Member]

ETCD_NAME="etcd01"

ETCD_DATA_DIR="/var/lib/etcd/default.etcd"

ETCD_LISTEN_PEER_URLS="https://10.206.240.189:2380"

ETCD_LISTEN_CLIENT_URLS="https://10.206.240.189:2379"

 

\#[Clustering]

ETCD_INITIAL_ADVERTISE_PEER_URLS="https://10.206.240.189:2380"

ETCD_ADVERTISE_CLIENT_URLS="https://10.206.240.189:2379"

ETCD_INITIAL_CLUSTER="etcd01=https://10.206.240.189:2380,etcd02=https://10.206.240.188:2380,etcd03=https://10.206.240.111:2380"

ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"

ETCD_INITIAL_CLUSTER_STATE="new"

 

\* ETCD_NAME 节点名称

\* ETCD_DATA_DIR 数据目录

\* ETCD_LISTEN_PEER_URLS 集群通信监听地址

\* ETCD_LISTEN_CLIENT_URLS 客户端访问监听地址

\* ETCD_INITIAL_ADVERTISE_PEER_URLS 集群通告地址

\* ETCD_ADVERTISE_CLIENT_URLS 客户端通告地址

\* ETCD_INITIAL_CLUSTER 集群节点地址

\* ETCD_INITIAL_CLUSTER_TOKEN 集群Token

\* ETCD_INITIAL_CLUSTER_STATE 加入集群的当前状态，new是新集群，existing表示加入已有集群
```

 

systemd管理etcd：

```
# cat /usr/lib/systemd/system/etcd.service 

[Unit]

Description=Etcd Server

After=network.target

After=network-online.target

Wants=network-online.target

 

[Service]

Type=notify

EnvironmentFile=/opt/etcd/cfg/etcd

ExecStart=/opt/etcd/bin/etcd \

--name=${ETCD_NAME} \

--data-dir=${ETCD_DATA_DIR} \

--listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \

--listen-client-urls=${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \

--advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \

--initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \

--initial-cluster=${ETCD_INITIAL_CLUSTER} \

--initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \

--initial-cluster-state=new \

--cert-file=/opt/etcd/ssl/server.pem \

--key-file=/opt/etcd/ssl/server-key.pem \

--peer-cert-file=/opt/etcd/ssl/server.pem \

--peer-key-file=/opt/etcd/ssl/server-key.pem \

--trusted-ca-file=/opt/etcd/ssl/ca.pem \

--peer-trusted-ca-file=/opt/etcd/ssl/ca.pem

Restart=on-failure

LimitNOFILE=65536

 

[Install]

WantedBy=multi-user.target
```

 

把刚才生成的证书拷贝到配置文件中的位置：

```
\# cp ca*pem server*pem /opt/etcd/ssl
```

 

启动并设置开启启动：

```
\# systemctl start etcd

\# systemctl enable etcd
```

 

都部署完成后，检查etcd集群状态：

```
\# /opt/etcd/bin/etcdctl \

--ca-file=/opt/etcd/ssl/ca.pem --cert-file=/opt/etcd/ssl/server.pem --key-file=/opt/etcd/ssl/server-key.pem \

--endpoints="https://10.206.240.189:2379,https://10.206.240.188:2379,https://10.206.240.111:2379" \

cluster-health

member 18218cfabd4e0dea is healthy: got healthy result from https://10.206.240.111:2379

member 541c1c40994c939b is healthy: got healthy result from https://10.206.240.189:2379

member a342ea2798d20705 is healthy: got healthy result from https://10.206.240.188:2379

cluster is healthy
```

 

如果输出上面信息，就说明集群部署成功。

 

如果有问题第一步先看日志：/var/log/messages 或 journalctl -u etcd

 

报错：

```
Jan 15 12:06:55 k8s-master1 etcd: request cluster ID mismatch (got 99f4702593c94f98 want cdf818194e3a8c32)
```

解决：因为集群搭建过程，单独启动过单一etcd,做为测试验证，集群内第一次启动其他etcd服务时候，是通过发现服务引导的，所以需要删除旧的成员信息，所有节点作以下操作

```
[root@k8s-master1 default.etcd]# pwd

/var/lib/etcd/default.etcd

[root@k8s-master1 default.etcd]# rm -rf member/
```

 

在Node节点安装Docker

```
\# yum install -y yum-utils device-mapper-persistent-data lvm2

\# yum-config-manager \

​    --add-repo \

​    https://download.docker.com/linux/centos/docker-ce.repo

\# yum install docker-ce -y

\# curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://bc437cce.m.daocloud.io

\# systemctl start docker

\# systemctl enable docker
```

 

## **部署Flannel网络**

工作原理： 

![img](file:////tmp/wps-coder/ksohtml/wpsxPoneA.jpg) 

 

 

 

Falnnel要用etcd存储自身一个子网信息，所以要保证能成功连接Etcd，写入预定义子网段：

```
\# /opt/etcd/bin/etcdctl \

--ca-file=ca.pem --cert-file=server.pem --key-file=server-key.pem \

--endpoints="https://10.206.240.189:2379,https://10.206.240.188:2379,https://10.206.240.111:2379" \

set /coreos.com/network/config  '{ "Network": "172.17.0.0/16", "Backend": {"Type": "vxlan"}}'


```

 

 

以下部署步骤在规划的每个node节点都操作。

下载二进制包：

```
\# wget https://github.com/coreos/flannel/releases/download/v0.10.0/flannel-v0.10.0-linux-amd64.tar.gz

\# tar zxvf flannel-v0.10.0-linux-amd64.tar.gz

\# mkdir -pv /opt/kubernetes/bin

\# mv flanneld mk-docker-opts.sh /opt/kubernetes/bin


```

 

配置Flannel：

```
\# mkdir -pv /opt/kubernetes/cfg/

\# cat /opt/kubernetes/cfg/flanneld

FLANNEL_OPTIONS="--etcd-endpoints=https://10.206.240.189:2379,https://10.206.240.188:2379,https://10.206.240.111:2379 -etcd-cafile=/opt/etcd/ssl/ca.pem -etcd-certfile=/opt/etcd/ssl/server.pem -etcd-keyfile=/opt/etcd/ssl/server-key.pem"
```

 

systemd管理Flannel：

```
\# cat /usr/lib/systemd/system/flanneld.service

[Unit]

Description=Flanneld overlay address etcd agent

After=network-online.target network.target

Before=docker.service

 

[Service]

Type=notify

EnvironmentFile=/opt/kubernetes/cfg/flanneld

ExecStart=/opt/kubernetes/bin/flanneld --ip-masq $FLANNEL_OPTIONS

ExecStartPost=/opt/kubernetes/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/subnet.env

Restart=on-failure

 

[Install]

WantedBy=multi-user.target

 

配置Docker启动指定子网段：

\# cat /usr/lib/systemd/system/docker.service 

 

[Unit]

Description=Docker Application Container Engine

Documentation=https://docs.docker.com

After=network-online.target firewalld.service

Wants=network-online.target

 

[Service]

Type=notify

EnvironmentFile=/run/flannel/subnet.env

ExecStart=/usr/bin/dockerd $DOCKER_NETWORK_OPTIONS

ExecReload=/bin/kill -s HUP $MAINPID

LimitNOFILE=infinity

LimitNPROC=infinity

LimitCORE=infinity

TimeoutStartSec=0

Delegate=yes

KillMode=process

Restart=on-failure

StartLimitBurst=3

StartLimitInterval=60s

 

[Install]

WantedBy=multi-user.target


```

 

从其他节点拷贝证书文件到node1和2上：因为node1和2上没有证书，但是flanel需要证书

```
\# mkdir -pv /opt/etcd/ssl/

\# scp /opt/etcd/ssl/*  k8s-node2:/opt/etcd/ssl/
```

 

重启flannel和docker：

```
\# systemctl daemon-reload

\# systemctl start flanneld

\# systemctl enable flanneld

\# systemctl restart docker
```

 

检查是否生效：

```
\# ps -ef | grep docker

root     20941     1  1 Jun28 ?        09:15:34 /usr/bin/dockerd --bip=172.17.34.1/24 --ip-masq=false --mtu=1450

\# ip addr

3607: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN 

​    link/ether 8a:2e:3d:09:dd:82 brd ff:ff:ff:ff:ff:ff

​    inet 172.17.34.0/32 scope global flannel.1

​       valid_lft forever preferred_lft forever

3608: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP 

​    link/ether 02:42:31:8f:d3:02 brd ff:ff:ff:ff:ff:ff

​    inet 172.17.34.1/24 brd 172.17.34.255 scope global docker0

​       valid_lft forever preferred_lft forever

​    inet6 fe80::42:31ff:fe8f:d302/64 scope link 

​       valid_lft forever preferred_lft forever
```

​       

**注：**

1.	确保docker0与flannel.1在同一网段。

 

2.	测试不同节点互通，在当前节点访问另一个Node节点docker0 IP：

```
\# ping 172.17.58.1

PING 172.17.58.1 (172.17.58.1) 56(84) bytes of data.

64 bytes from 172.17.58.1: icmp_seq=1 ttl=64 time=0.263 ms

64 bytes from 172.17.58.1: icmp_seq=2 ttl=64 time=0.204 ms
```

如果能通说明Flannel部署成功。如果不通检查下日志：journalctl -u flannel

 

## **在Master节点部署组件**

两个Master节点部署方式一样

 

在部署Kubernetes之前一定要确保etcd、flannel、docker是正常工作的，否则先解决问题再继续。

### **生成证书**

创建CA证书：

```
\# cat ca-config.json

{

  "signing": {

​    "default": {

​      "expiry": "87600h"

​    },

​    "profiles": {

​      "kubernetes": {

​         "expiry": "87600h",

​         "usages": [

​            "signing",

​            "key encipherment",

​            "server auth",

​            "client auth"

​        ]

​      }

​    }

  }

}
```

 

\

```
# cat ca-csr.json

{

​    "CN": "kubernetes",

​    "key": {

​        "algo": "rsa",

​        "size": 2048

​    },

​    "names": [

​        {

​            "C": "CN",

​            "L": "Beijing",

​            "ST": "Beijing",

​            "O": "k8s",

​            "OU": "System"

​        }

​    ]

}
```

 

```
\# cfssl gencert -initca ca-csr.json | cfssljson -bare ca -


```

 

生成apiserver证书：

```
\# cat server-csr.json

{

​    "CN": "kubernetes",

​    "hosts": [

​      "10.0.0.1",         //这是后面dns要使用的虚	拟网络的网关，不用改，就用这个  切忌

​      "127.0.0.1",

​      "10.206.176.19",

​      "10.206.240.188",

​      "10.206.240.189",

​      "kubernetes",

​      "kubernetes.default",

​      "kubernetes.default.svc",

​      "kubernetes.default.svc.cluster",

​      "kubernetes.default.svc.cluster.local"

​    ],

​    "key": {

​        "algo": "rsa",

​        "size": 2048

​    },

​    "names": [

​        {

​            "C": "CN",

​            "L": "BeiJing",

​            "ST": "BeiJing",

​            "O": "k8s",

​            "OU": "System"

​        }

​    ]

}

 

\# cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes server-csr.json | cfssljson -bare server
```

 

生成kube-proxy证书：

```
\# cat kube-proxy-csr.json

{

  "CN": "system:kube-proxy",

  "hosts": [],

  "key": {

​    "algo": "rsa",

​    "size": 2048

  },

  "names": [

​    {

​      "C": "CN",

​      "L": "BeiJing",

​      "ST": "BeiJing",

​      "O": "k8s",

​      "OU": "System"

​    }

  ]

}

 

\# cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
```

 

最终生成以下证书文件：

```
\# ls *pem

ca-key.pem  ca.pem  kube-proxy-key.pem  kube-proxy.pem  server-key.pem  server.pem
```



### **部署apiserver组件**

下载二进制包：https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.11.md 下载这个包（kubernetes-server-linux-amd64.tar.gz）就够了，包含了所需的所有组件。

 

\

```
# mkdir /opt/kubernetes/{bin,cfg,ssl} -pv

\# tar zxvf kubernetes-server-linux-amd64.tar.gz

\# cd kubernetes/server/bin

\# cp kube-apiserver kube-scheduler kube-controller-manager kubectl /opt/kubernetes/bin
```

 

从生成证书的机器拷贝证书到master1,master2:

```
\# scp server.pem  server-key.pem ca.pem ca-key.pem k8s-master1:/opt/kubernetes/ssl/

\# scp server.pem  server-key.pem ca.pem ca-key.pem k8s-master2:/opt/kubernetes/ssl/


```

 

创建token文件，后面会讲到：

```
\# cat /opt/kubernetes/cfg/token.csv

674c457d4dcf2eefe4920d7dbb6b0ddc,kubelet-bootstrap,10001,"system:kubelet-bootstrap"
```

第一列：随机字符串，自己可生成 第二列：用户名 第三列：UID 第四列：用户组

 

创建apiserver配置文件：

\

```
# cat /opt/kubernetes/cfg/kube-apiserver 

 

KUBE_APISERVER_OPTS="--logtostderr=true \

--v=4 \

--etcd-servers=https://10.206.240.189:2379,https://10.206.240.188:2379,https://10.206.240.111:2379 \

--bind-address=10.206.240.189 \

--secure-port=6443 \

--advertise-address=10.206.240.189 \

--allow-privileged=true \

--service-cluster-ip-range=10.0.0.0/24 \   //这里就用这个网段，切忌不要改

--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction \

--authorization-mode=RBAC,Node \

--enable-bootstrap-token-auth \

--token-auth-file=/opt/kubernetes/cfg/token.csv \

--service-node-port-range=30000-50000 \

--tls-cert-file=/opt/kubernetes/ssl/server.pem  \

--tls-private-key-file=/opt/kubernetes/ssl/server-key.pem \

--client-ca-file=/opt/kubernetes/ssl/ca.pem \

--service-account-key-file=/opt/kubernetes/ssl/ca-key.pem \

--etcd-cafile=/opt/etcd/ssl/ca.pem \

--etcd-certfile=/opt/etcd/ssl/server.pem \

--etcd-keyfile=/opt/etcd/ssl/server-key.pem"
```

 

配置好前面生成的证书，确保能连接etcd。

 

参数说明：

\

```
* --logtostderr 启用日志

\* --v 日志等级

\* --etcd-servers etcd集群地址

\* --bind-address 监听地址

\* --secure-port https安全端口

\* --advertise-address 集群通告地址

\* --allow-privileged 启用授权

\* --service-cluster-ip-range Service虚拟IP地址段

\* --enable-admission-plugins 准入控制模块

\* --authorization-mode 认证授权，启用RBAC授权和节点自管理

\* --enable-bootstrap-token-auth 启用TLS bootstrap功能，后面会讲到

\* --token-auth-file token文件

\* --service-node-port-range Service Node类型默认分配端口范围
```

 

systemd管理apiserver：

```
\# cat /usr/lib/systemd/system/kube-apiserver.service 

[Unit]

Description=Kubernetes API Server

Documentation=https://github.com/kubernetes/kubernetes

 

[Service]

EnvironmentFile=-/opt/kubernetes/cfg/kube-apiserver

ExecStart=/opt/kubernetes/bin/kube-apiserver $KUBE_APISERVER_OPTS

Restart=on-failure

 

[Install]

WantedBy=multi-user.target

 

启动：

\# systemctl daemon-reload

\# systemctl enable kube-apiserver

\# systemctl start kube-apiserver
```

 

### **部署schduler组件** 

创建schduler配置文件：

```
\# cat /opt/kubernetes/cfg/kube-scheduler 

 

KUBE_SCHEDULER_OPTS="--logtostderr=true \

--v=4 \

--master=127.0.0.1:8080 \

--leader-elect"

参数说明：

\* --master 连接本地apiserver

\* --leader-elect 当该组件启动多个时，自动选举（HA）

 

systemd管理schduler组件：

\# cat /usr/lib/systemd/system/kube-scheduler.service 

[Unit]

Description=Kubernetes Scheduler

Documentation=https://github.com/kubernetes/kubernetes

 

[Service]

EnvironmentFile=-/opt/kubernetes/cfg/kube-scheduler

ExecStart=/opt/kubernetes/bin/kube-scheduler $KUBE_SCHEDULER_OPTS

Restart=on-failure

 

[Install]

WantedBy=multi-user.target
```

 

启动：

```
\# systemctl daemon-reload

\# systemctl enable kube-scheduler 

\# systemctl start kube-scheduler 
```

 

### **部署controller-manager组件**

创建controller-manager配置文件：

```
\# cat /opt/kubernetes/cfg/kube-controller-manager 

KUBE_CONTROLLER_MANAGER_OPTS="--logtostderr=true \

--v=4 \

--master=127.0.0.1:8080 \

--leader-elect=true \

--address=127.0.0.1 \

--service-cluster-ip-range=10.0.0.0/24 \    //这是后面dns要使用的虚拟网络，不用改，就用这个  切忌

--cluster-name=kubernetes \

--cluster-signing-cert-file=/opt/kubernetes/ssl/ca.pem \

--cluster-signing-key-file=/opt/kubernetes/ssl/ca-key.pem  \

--root-ca-file=/opt/kubernetes/ssl/ca.pem \

--service-account-private-key-file=/opt/kubernetes/ssl/ca-key.pem"
```

 

systemd管理controller-manager组件：

```
\# cat /usr/lib/systemd/system/kube-controller-manager.service 

[Unit]

Description=Kubernetes Controller Manager

Documentation=https://github.com/kubernetes/kubernetes

 

[Service]

EnvironmentFile=-/opt/kubernetes/cfg/kube-controller-manager

ExecStart=/opt/kubernetes/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_OPTS

Restart=on-failure

 

[Install]

WantedBy=multi-user.target
```

 

启动：

```
\# systemctl daemon-reload

\# systemctl enable kube-controller-manager

\# systemctl start kube-controller-manager


```

 

所有组件都已经启动成功，通过kubectl工具查看当前集群组件状态：

```
\# /opt/kubernetes/bin/kubectl get cs

NAME                 STATUS    MESSAGE             ERROR

scheduler            Healthy   ok                  

etcd-0               Healthy   {"health":"true"}   

etcd-2               Healthy   {"health":"true"}   

etcd-1               Healthy   {"health":"true"}   

controller-manager   Healthy   ok
```

如上输出说明组件都正常。 

 

配置Master负载均衡 

所谓的Master HA，其实就是APIServer的HA，Master的其他组件controller-manager、scheduler都是可以通过etcd做选举（--leader-elect），而APIServer设计的就是可扩展性，所以做到APIServer很容易，只要前面加一个负载均衡轮询转发请求即可。 在私有云平台添加一个内网四层LB，不对外提供服务，只做apiserver负载均衡，配置如下： 

![img](file:////tmp/wps-coder/ksohtml/wps2r0gwN.jpg) 

 其他公有云LB配置大同小异，只要理解了数据流程就好配置了。

 

在Node节点部署组件

Master apiserver启用TLS认证后，Node节点kubelet组件想要加入集群，必须使用CA签发的有效证书才能与apiserver通信，当Node节点很多时，签署证书是一件很繁琐的事情，因此有了TLS Bootstrapping机制，kubelet会以一个低权限用户自动向apiserver申请证书，kubelet的证书由apiserver动态签署。

认证大致工作流程如图所示：

![img](file:////tmp/wps-coder/ksohtml/wpsobhdO0.jpg) 

 

----------------------下面这些操作在master节点完成：---------------------------

将kubelet-bootstrap用户绑定到系统集群角色

```
\# /opt/kubernetes/bin/kubectl create clusterrolebinding kubelet-bootstrap \

  --clusterrole=system:node-bootstrapper \

  --user=kubelet-bootstrap
```

 

创建kubeconfig文件:

在生成kubernetes证书的目录下执行以下命令生成kubeconfig文件：

 

指定apiserver 内网负载均衡地址

```
\# KUBE_APISERVER="https://10.206.176.19:6443"

\# BOOTSTRAP_TOKEN=674c457d4dcf2eefe4920d7dbb6b0ddc
```

 

\# 设置集群参数

```
\# /opt/kubernetes/bin/kubectl config set-cluster kubernetes \

  --certificate-authority=./ca.pem \

  --embed-certs=true \

  --server=${KUBE_APISERVER} \

  --kubeconfig=bootstrap.kubeconfig
```

 

\# 设置客户端认证参数

```
\# /opt/kubernetes/bin/kubectl config set-credentials kubelet-bootstrap \

  --token=${BOOTSTRAP_TOKEN} \

  --kubeconfig=bootstrap.kubeconfig
```

 

\# 设置上下文参数

\# /opt/kubernetes/bin/kubectl config set-context default \

  --cluster=kubernetes \

  --user=kubelet-bootstrap \

  --kubeconfig=bootstrap.kubeconfig

 

\# 设置默认上下文

\# /opt/kubernetes/bin/kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

 

\#----------------------

 

\# 创建kube-proxy kubeconfig文件

 

\# /opt/kubernetes/bin/kubectl config set-cluster kubernetes \

  --certificate-authority=./ca.pem \

  --embed-certs=true \

  --server=${KUBE_APISERVER} \

  --kubeconfig=kube-proxy.kubeconfig

 

\# /opt/kubernetes/bin/kubectl config set-credentials kube-proxy \

  --client-certificate=./kube-proxy.pem \

  --client-key=./kube-proxy-key.pem \

  --embed-certs=true \

  --kubeconfig=kube-proxy.kubeconfig

 

\# /opt/kubernetes/bin/kubectl config set-context default \

  --cluster=kubernetes \

  --user=kube-proxy \

  --kubeconfig=kube-proxy.kubeconfig

 

\# /opt/kubernetes/bin/kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

 

\# ls

bootstrap.kubeconfig  kube-proxy.kubeconfig

必看：将这两个文件拷贝到Node节点/opt/kubernetes/cfg目录下。

 

----------------------下面这些操作在node节点完成：---------------------------

## **部署kubelet组件**

将前面下载的二进制包中的kubelet和kube-proxy拷贝到/opt/kubernetes/bin目录下。

创建kubelet配置文件：

\# vim /opt/kubernetes/cfg/kubelet

KUBELET_OPTS="--logtostderr=true \

--v=4 \

--hostname-override=10.206.240.112 \

--kubeconfig=/opt/kubernetes/cfg/kubelet.kubeconfig \

--bootstrap-kubeconfig=/opt/kubernetes/cfg/bootstrap.kubeconfig \

--config=/opt/kubernetes/cfg/kubelet.config \

--cert-dir=/opt/kubernetes/ssl \

--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0"

 

参数说明：

\* --hostname-override 在集群中显示的主机名

\* --kubeconfig 指定kubeconfig文件位置，会自动生成

\* --bootstrap-kubeconfig 指定刚才生成的bootstrap.kubeconfig文件

\* --cert-dir 颁发证书存放位置

\* --pod-infra-container-image 管理Pod网络的镜像

 

其中/opt/kubernetes/cfg/kubelet.config配置文件如下：

\# vim /opt/kubernetes/cfg/kubelet.config

kind: KubeletConfiguration

apiVersion: kubelet.config.k8s.io/v1beta1

address: 10.206.240.112

port: 10250

readOnlyPort: 10255

cgroupDriver: cgroupfs

clusterDNS: ["10.0.0.2"]     //不要改，就是这个ip

clusterDomain: cluster.local.

failSwapOn: false

authentication:

  anonymous:

​    enabled: true 

  webhook:

​    enabled: false

 

systemd管理kubelet组件：

\# vim /usr/lib/systemd/system/kubelet.service 

[Unit]

Description=Kubernetes Kubelet

After=docker.service

Requires=docker.service

 

[Service]

EnvironmentFile=/opt/kubernetes/cfg/kubelet

ExecStart=/opt/kubernetes/bin/kubelet $KUBELET_OPTS

Restart=on-failure

KillMode=process

 

[Install]

WantedBy=multi-user.target

 

启动：

\# systemctl daemon-reload

\# systemctl enable kubelet

\# systemctl start kubelet

 

在Master审批Node加入集群：

启动后还没加入到集群中，需要手动允许该节点才可以。 在Master节点查看请求签名的Node：

\# /opt/kubernetes/bin/kubectl get csr

\# /opt/kubernetes/bin/kubectl certificate approve XXXXID

\# /opt/kubernetes/bin/kubectl get node

 

## **部署kube-proxy组件**

创建kube-proxy配置文件：

\# cat /opt/kubernetes/cfg/kube-proxy

KUBE_PROXY_OPTS="--logtostderr=true \

--v=4 \

--hostname-override=10.206.240.111 \

--cluster-cidr=10.0.0.0/24 \           //不要改，就是这个ip

--kubeconfig=/opt/kubernetes/cfg/kube-proxy.kubeconfig"

 

systemd管理kube-proxy组件：

\# cat /usr/lib/systemd/system/kube-proxy.service 

[Unit]

Description=Kubernetes Proxy

After=network.target

 

[Service]

EnvironmentFile=-/opt/kubernetes/cfg/kube-proxy

ExecStart=/opt/kubernetes/bin/kube-proxy $KUBE_PROXY_OPTS

Restart=on-failure

 

[Install]

WantedBy=multi-user.target

 

启动：

\# systemctl daemon-reload

\# systemctl enable kube-proxy

\# systemctl start kube-proxy

 

查看集群状态

\# /opt/kubernetes/bin/kubectl get node

NAME             STATUS    ROLES     AGE       VERSION

10.206.240.111   Ready     <none>    28d       v1.11.0

10.206.240.112   Ready     <none>    28d       v1.11.0

 

\# /opt/kubernetes/bin/kubectl get cs

NAME                      STATUS   MESSAGE             ERROR

controller-manager   		Healthy    ok                  

scheduler                 	Healthy    ok                  

etcd-2                      Healthy    {"health":"true"}   

etcd-1                      Healthy    {"health":"true"}   

etcd-0                      Healthy    {"health":"true"}

 

==========================================================

运行一个测试示例

创建一个Nginx Web，判断集群是否正常工作：

\# /opt/kubernetes/bin/kubectl run nginx --image=nginx --replicas=3

\# /opt/kubernetes/bin/kubectl expose deployment nginx --port=88 --target-port=80 --type=NodePort

 

查看Pod，Service：

\# /opt/kubernetes/bin/kubectl get pods

NAME                                 READY     STATUS    RESTARTS   AGE

nginx-64f497f8fd-fjgt2          1/1       Running   3           28d

nginx-64f497f8fd-gmstq        1/1      Running   3            28d

nginx-64f497f8fd-q6wk9        1/1      Running   3            28d

 

查看pod详细信息：

\# /opt/kubernetes/bin/kubectl describe pod nginx-64f497f8fd-fjgt2 

 

\# /opt/kubernetes/bin/kubectl get svc

NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                        AGE

kubernetes     ClusterIP     10.0.0.1     <none>        443/TCP                        28d

nginx          NodePort     10.0.0.175   <none>        88:38696/TCP                   28d

 

打开浏览器输入：http://10.206.240.111:38696 

 

恭喜你，集群部署成功！

============================

 

部署Dashboard（Web UI）

部署UI有三个文件：

\* dashboard-deployment.yaml     	// 部署Pod，提供Web服务

\* dashboard-rbac.yaml                // 授权访问apiserver获取信息

\* dashboard-service.yaml            	// 发布服务，提供对外访问

 

\# cat dashboard-deployment.yaml

apiVersion: apps/v1beta2

kind: Deployment

metadata:

  name: kubernetes-dashboard

  namespace: kube-system

  labels:

​    k8s-app: kubernetes-dashboard

​    kubernetes.io/cluster-service: "true"

​    addonmanager.kubernetes.io/mode: Reconcile

spec:

  selector:

​    matchLabels:

​      k8s-app: kubernetes-dashboard

  template:

​    metadata:

​      labels:

​        k8s-app: kubernetes-dashboard

​      annotations:

​        scheduler.alpha.kubernetes.io/critical-pod: ''

​    spec:

​      serviceAccountName: kubernetes-dashboard

​      containers:

​      \- name: kubernetes-dashboard

​        image: registry.cn-hangzhou.aliyuncs.com/kube_containers/kubernetes-dashboard-amd64:v1.8.1 

​        resources:

​          limits:

​            cpu: 100m

​            memory: 300Mi

​          requests:

​            cpu: 100m

​            memory: 100Mi

​        ports:

​        \- containerPort: 9090

​          protocol: TCP

​        livenessProbe:

​          httpGet:

​            scheme: HTTP

​            path: /

​            port: 9090

​          initialDelaySeconds: 30

​          timeoutSeconds: 30

​      tolerations:

​      \- key: "CriticalAddonsOnly"

​        operator: "Exists"

​        

\# cat dashboard-rbac.yaml

apiVersion: v1

kind: ServiceAccount

metadata:

  labels:

​    k8s-app: kubernetes-dashboard

​    addonmanager.kubernetes.io/mode: Reconcile

  name: kubernetes-dashboard

  namespace: kube-system

\---

 

kind: ClusterRoleBinding

apiVersion: rbac.authorization.k8s.io/v1beta1

metadata:

  name: kubernetes-dashboard-minimal

  namespace: kube-system

  labels:

​    k8s-app: kubernetes-dashboard

​    addonmanager.kubernetes.io/mode: Reconcile

roleRef:

  apiGroup: rbac.authorization.k8s.io

  kind: ClusterRole

  name: cluster-admin

subjects:

  \- kind: ServiceAccount

​    name: kubernetes-dashboard

​    namespace: kube-system

​    

\# cat dashboard-service.yaml

apiVersion: v1

kind: Service

metadata:

  name: kubernetes-dashboard

  namespace: kube-system

  labels:

​    k8s-app: kubernetes-dashboard

​    kubernetes.io/cluster-service: "true"

​    addonmanager.kubernetes.io/mode: Reconcile

spec:

  type: NodePort

  selector:

​    k8s-app: kubernetes-dashboard

  ports:

  \- port: 80

​    targetPort: 9090

 

创建：

\# /opt/kubernetes/bin/kubectl create -f dashboard-rbac.yaml

\# /opt/kubernetes/bin/kubectl create -f dashboard-deployment.yaml

\# /opt/kubernetes/bin/kubectl create -f dashboard-service.yaml

 

等待数分钟，查看资源状态：

\# /opt/kubernetes/bin/kubectl get all -n kube-system

NAME                                                            READY       STATUS    RESTARTS   AGE

pod/kubernetes-dashboard-68ff5fcd99-5rtv7    1/1            Running   1                27d

 

NAME                           TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE

service/kubernetes-dashboard   NodePort    10.0.0.100   <none>        443:30000/TCP   27d

 

NAME                                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE

deployment.apps/kubernetes-dashboard   1         1         1            1           27d

 

NAME                                              DESIRED   CURRENT   READY     AGE

replicaset.apps/kubernetes-dashboard-68ff5fcd99   1         1         1         27d

 

查看访问端口：

\# /opt/kubernetes/bin/kubectl get svc -n kube-system 

NAME                   TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE

kubernetes-dashboard   NodePort    10.0.0.100   <none>        443:30000/TCP   27d

 

打开浏览器，输入：http://10.206.240.111:30000

 

===============================

\# /opt/kubernetes/bin/kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

 

\# /opt/kubernetes/bin/kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

 

To access Dashboard from your local workstation you must create a  secure channel to your Kubernetes cluster. Run the following command:

$ kubectl proxy

 

Now access Dashboard at:

http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/.