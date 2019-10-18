#!/bin/bash
#
# master节点通常运行 kube-apiserver、kube-controller-manager、kube-scheduler、flannel、docker、kube_proxy、kubelet
# node节点通常运行 kubelet、docker、kube_proxy、flannel
# 安装脚本中使用的所有环境变量定义，所有安装脚本都会引入这个文件，实际上master节点可以提供node节点的所有功能，只是我们通过给master节点
# 打标签的方式不让在master上运行POD，除非特殊需要在POD中指定亲和度。
# 
# service文件格式 http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html


# 临时工作目录
export TEMP_WORK_DIR=/tmp/work_dir
# 这里存放单独node节点加入现有集群是所需要的文件
export JOIN_CLUSTER_DIR=/tmp/work_dir/joincluster
# 执行初始化脚本和证书生成的主机，这个主机是集群中master角色的一台主机
export EXEC_SCRIPT_HOST_IP=192.168.10.10

# etcd家目录
export ETCD_HOME=/work/apps/etcd
# etcd证书路径
export ETCD_CERTIFICATE_PATH=/work/apps/etcd/ssl
# etcd数据目录
export ETCD_DATA_PATH=/data/etcd

# k8s证书路径，包含ca根证书和私钥、master和node使用的证书
export KUBERNETES_CERTIFICATE_PATH=/work/apps/kubernetes/ssl
# master家目录
export KUBERNETES_SERVER_HOME=/work/apps/kubernetes/server
# 日志路径
export KUBERNETES_LOGS_DIR=/var/log/kubernetes
# node家目录
export KUBERNETES_NODE_HOME=/work/apps/kubernetes/node
# kubelet工作目录
export KUBELET_WORKING_DIR=/var/lib/kubelet
# kube-proxy工作目录
export KUBEPROXY_WORKING_DIR=/var/lib/kube-proxy

# flannel家目录
export FLANNEL_HOME=/work/apps/flannel
# flanneld 网络配置前缀
export FLANNEL_ETCD_PREFIX=/kubernetes/network
# flannel使用的通信接口，如果是多网卡则需要指定，确保k8s的node节点都使用名称相同的网卡
export FLANNEL_IFACE=ens34

# docker家目录
export DOCKER_HOME=/work/apps/docker

# 运行k8s集群组件的账号
export K8S_SERVICE_ACCOUNT=root
# 运行etcd集群的账号
export ETCD_SERVICE_ACCOUNT=root

# etcd集群IP数组，IP和下面的节点名称要对应
export ETCD_CLUSTER_IPS=(192.168.10.10 192.168.10.20 192.168.10.30)
# etcd集群节点名称，这个名称是自定义的不一定是主机名而是etcd配置中标识的etcd节点名字
export ETCD_NODE_NAMES=(etcd01 etcd02 etcd03)
# etcd 集群服务地址列表，也可以是域名
export ETCD_ENDPOINTS="https://192.168.10.10:2379,https://192.168.10.20:2379,https://192.168.10.30:2379"
# etcd 集群间通信的IP和端口，也就是配置文件中的 ETCD_INITIAL_CLUSTER
export ETCD_NODES="etcd01=https://192.168.10.10:2380,etcd02=https://192.168.10.20:2380,etcd03=https://192.168.10.30:2380"

# 集群master节点IP数组
export MASTER_IPS=(192.168.10.10)
# 集群master节点主机名数组
export MASTER_NAMES=(srv01)
# api server的地址，如果是集群则这里设置集群的虚拟IP，如果是单台这里设置master的IP
export KUBE_APISERVER=https://192.168.10.10:6433
# 集群中api server的数量
export APISERVER_COUNT=1

# 集群node节点IP数组，之所以把master节点也包含进来是因为master节点
export NODE_IPS=(192.168.10.20 192.168.10.30)
# 集群node节点主机名数组，这里的名字要和上面的IP对应
export NODE_NAMES=(srv02 srv03)

# kubernetes集群包含master节点和node节点所有的IP，以及对应主机名
export ALL_K8S_CLUSTER_SRV_IPS=(192.168.10.10 192.168.10.20 192.168.10.30)
export ALL_K8S_CLUSTER_SRV_NAMES=(srv01 srv02 srv03)

# 服务网段，部署前路由不可达，部署后集群内路由可达(kube-proxy 和 ipvs 保证)
export SERVICE_CIDR="10.254.0.0/16"
# 当service的类型是NodePort时使用的本地端口范围，默认是30000-32767
export NODE_PORT_RANGE="30000-32767"
# kubernetes 服务 IP (一般是 SERVICE_CIDR 中第一个IP)
export CLUSTER_KUBERNETES_SVC_IP="10.254.0.1"

# 集群 DNS 服务 IP (从 SERVICE_CIDR 中预分配)
export CLUSTER_DNS_SVC_IP="10.254.0.2"
# 集群 DNS 域名
export CLUSTER_DNS_DOMAIN="cluster.local."

# Pod 网段，建议 /16 段地址，部署前路由不可达，部署后集群内路由可达(flanneld 保证)
export CLUSTER_CIDR="172.30.0.0/16"





