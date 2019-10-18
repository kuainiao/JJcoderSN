# kubernetes 安装与配置

# kubernetes 安装

## shell 安装

> 环境要求： centos7 及以上

```shell
#!/bin/bash  
systemctl stop firewalld
systemctl disable firewalld

yum remove docker*

yum install -y etcd kubernetes
```

## 配置更改

```shell
vim /etc/sysconfig/docker      修改  OPTIONS 配置项
如下：
OPTIONS='--selinux-enabled=false --insecure-registry gcr.io'

修改 /etc/kubernetes/apiserver
--admission-control   这项中的ServiceAccount 删除。
```

## 服务管理

```shell
## 启动服务
systemctl start etcd
systemctl start docker
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start kubelet
systemctl start kub-proxy
## 设置开机自启动
systemctl enable etcd
systemctl enable docker
systemctl enable  kube-apiserver
systemctl enable kube-controller-manager
systemctl enable kube-scheduler
systemctl enable kubelet
systemctl enable kub-proxy
```