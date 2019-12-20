#!/bin/bash
# 首先要执行的脚本，请先配置好执行脚本的主机到其他主机的免密登陆，请在EXEC_SCRIPT_HOST_IP变量的主机执行
# 请在k8s集群的master角色主机上执行所有脚本
# 系统初始化脚本，设置必要条件：
#  - 创建必要目录
#  - 关闭防火墙服务、SELinux、拷贝environment.sh脚本到目标服务器
#  - 安装必要系统工具
#  - 修改node节点内核参数、启用ipvs功能以及禁用SWAP

source ./environment.sh

if [[ ! ${K8S_SERVICE_ACCOUNT} == "root" && ! ${ETCD_SERVICE_ACCOUNT} == "root" ]]; then
    echo "k8s服务账号或etcd服务账号不为root，请在目标机器上先建立账号."
    exit 1
fi

read -p '开始系统初始化，请提前修改本地hosts文件确保可以解析集群所有主机名，输入y继续 [y/n] ' isContinue
if [[ ${isContinue} == "n" ]]; then
  echo "初始化程序退出。"
  exit 0
fi

echo -e "\033[32m[Task]\033[0m etcd准备必要环境."
# 为ETCD创建必要目录
for etcd_ip in ${ETCD_CLUSTER_IPS[@]}; do
  echo ">>> 为服务器${etcd_ip}准备必要环境."
  if [[ ${etcd_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
  	echo "  >>> 创建目录"
  	mkdir ${ETCD_HOME}/{bin,cfg,binaries,ssl} -p
  	chown -R ${ETCD_SERVICE_ACCOUNT}.${ETCD_SERVICE_ACCOUNT} ${ETCD_HOME}
  	# 创建数据目录
  	mkdir ${ETCD_DATA_PATH} -p
  	chown -R ${ETCD_SERVICE_ACCOUNT}.${ETCD_SERVICE_ACCOUNT} ${ETCD_DATA_PATH}
  	# 创建临时工作目录
  	mkdir -p ${TEMP_WORK_DIR}
  	# 关闭防火墙
    echo "  >>> 关闭firewalld服务"
    systemctl stop firewalld && systemctl disable firewalld
    # 关闭SELinux
    echo "  >>> 关闭SELinux"
    setenforce 0 && sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
  	echo "  >>> 拷贝自定义环境变量文件environment.sh到${ETCD_HOME}目录"
    cp ./environment.sh ${ETCD_HOME}
  	continue
  fi
  echo "  >>> 创建目录"
  ssh -o StrictHostKeyChecking=no ${ETCD_SERVICE_ACCOUNT}@${etcd_ip} "mkdir ${ETCD_HOME}/{bin,cfg,binaries,ssl} -p && chown -R ${ETCD_SERVICE_ACCOUNT}.${ETCD_SERVICE_ACCOUNT} ${ETCD_HOME}"
  ssh -o StrictHostKeyChecking=no ${ETCD_SERVICE_ACCOUNT}@${etcd_ip} "mkdir ${ETCD_DATA_PATH} -p && chown -R ${ETCD_SERVICE_ACCOUNT}.${ETCD_SERVICE_ACCOUNT} ${ETCD_DATA_PATH}"
  ssh -o StrictHostKeyChecking=no ${ETCD_SERVICE_ACCOUNT}@${etcd_ip} "mkdir -p ${TEMP_WORK_DIR}"
  # 关闭防火墙服务
  echo "  >>> 关闭firewalld服务"
  ssh -o StrictHostKeyChecking=no ${ETCD_SERVICE_ACCOUNT}@${etcd_ip} "systemctl stop firewalld && systemctl disable firewalld"
  # 关闭SELinux
  echo "  >>> 关闭SELinux"
  ssh -o StrictHostKeyChecking=no ${ETCD_SERVICE_ACCOUNT}@${etcd_ip} "setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"
  # 拷贝自定义环境变量文件
  echo "  >>> 拷贝自定义环境变量文件environment.sh到远程主机"
  scp -o StrictHostKeyChecking=no ./environment.sh ${ETCD_SERVICE_ACCOUNT}@${etcd_ip}:${ETCD_HOME}
done

mkdir -p ${TEMP_WORK_DIR} && rm -rf ${TEMP_WORK_DIR}/*
mkdir -p ${JOIN_CLUSTER_DIR} && rm -rf ${JOIN_CLUSTER_DIR}/*
cp ./environment.sh ${TEMP_WORK_DIR}
cp ./environment.sh ${JOIN_CLUSTER_DIR}
cd ${TEMP_WORK_DIR}
cat << EOF > kubernetes_sysctl.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF

echo -e "\033[32m[Task]\033[0m 为k8s master准备必要环境."
# 此循环为只需要在Master节点上执行的内容
for master_ip in ${MASTER_IPS[@]}; do
  echo ">>> 为服务器${master_ip}准备必要环境."
  if [[ ${master_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
  	echo "  >>> 远程主机为本机，将采用本地执行创建目录方式。"
    mkdir ${KUBERNETES_SERVER_HOME}/{bin,cfg,binaries,addons} -p
    chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBERNETES_SERVER_HOME}
    echo "  >>> 拷贝自定义环境变量文件environment.sh到远程主机"
    cp ./environment.sh ${KUBERNETES_SERVER_HOME}
  	continue
  fi
  echo "  >>> 创建目录"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${master_ip} "mkdir -p ${KUBERNETES_SERVER_HOME}/{bin,cfg,binaries,addons} && chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBERNETES_SERVER_HOME}"
  echo "  >>> 拷贝自定义环境变量文件environment.sh到远程主机"
  scp -o StrictHostKeyChecking=no ./environment.sh ${K8S_SERVICE_ACCOUNT}@${ip}:${KUBERNETES_SERVER_HOME}
done


echo -e "\033[32m[Task]\033[0m 为k8s node准备必要环境."
# 此循环为只需要在Node节点上执行的内容
# for node_ip in ${NODE_IPS[@]}; do
#   echo ">>> 为${node_ip}准备必要环境."
#   if [[ ${node_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
#     # 本地执行内容
#     continue
#   fi
#   # 远程执行内容
# done


echo -e "\033[32m[Task]\033[0m 配置Kubernetes集群所有主机共有必要设置."
for ip in ${ALL_K8S_CLUSTER_SRV_IPS[@]}; do
  echo "  >>> 为主机 ${ip} 准备环境。"
  if [[ ${ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
    echo "  >>> 远程主机为本机，将采用本地执行方式。"
    mkdir -p ${KUBERNETES_NODE_HOME}/{bin,cfg,binaries} && chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBERNETES_NODE_HOME}
    mkdir -p ${KUBERNETES_CERTIFICATE_PATH} && chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBERNETES_CERTIFICATE_PATH}
    mkdir -p ${DOCKER_HOME}/{bin,cfg}
    mkdir -p ${FLANNEL_HOME}/{bin,ssl,cfg} && chown -R root.root ${FLANNEL_HOME}
    mkdir -p ${KUBELET_WORKING_DIR} && chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBELET_WORKING_DIR}
    mkdir -p ${KUBEPROXY_WORKING_DIR} && chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBEPROXY_WORKING_DIR}
    mkdir -p ${KUBERNETES_LOGS_DIR} && chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBERNETES_LOGS_DIR}
    mkdir -p /root/.kube
    # 关闭防火墙
    echo "  >>> 关闭firewalld服务"
    systemctl stop firewalld && systemctl disable firewalld
    # 关闭SELinux
    echo "  >>> 关闭SELinux"
    setenforce 0 && sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
    # 关闭SWAP
    swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    # 拷贝ipvs模块启用文件
    echo "  >>> 加载ipvs模块和管理工具"
    modprobe br_netfilter && modprobe ip_vs && modprobe ip_vs_rr && modprobe ip_vs_wrr && modprobe ip_vs_sh && modprobe nf_conntrack_ipv4
    yum -y install ipvsadm bridge-utils
    echo "  >>> 加载必要内核参数"
    cp ./kubernetes_sysctl.conf /etc/sysctl.d/kubernetes_sysclt.conf
    sysctl -p /etc/sysctl.d/kubernetes_sysclt.conf
    continue
  fi
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "mkdir -p ${KUBERNETES_NODE_HOME}/{bin,cfg,binaries} && chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBERNETES_NODE_HOME}"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "mkdir -p ${KUBERNETES_CERTIFICATE_PATH} && chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBERNETES_CERTIFICATE_PATH}"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "mkdir -p ${DOCKER_HOME}/{bin,cfg}"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "mkdir -p ${FLANNEL_HOME}/{bin,ssl,cfg} && chown -R root.root ${FLANNEL_HOME}"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "mkdir -p ${KUBELET_WORKING_DIR} && chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBELET_WORKING_DIR}"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "mkdir -p ${KUBEPROXY_WORKING_DIR} && chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBEPROXY_WORKING_DIR}"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "mkdir -p ${KUBERNETES_LOGS_DIR} && chown -R ${K8S_SERVICE_ACCOUNT}.${K8S_SERVICE_ACCOUNT} ${KUBERNETES_LOGS_DIR}"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "mkdir -p /root/.kube"
  # 关闭防火墙服务
  echo "  >>> 关闭firewalld服务"
  ssh ${K8S_SERVICE_ACCOUNT}@${ip} "systemctl stop firewalld && systemctl disable firewalld"
  # 关闭SELinux
  echo "  >>> 关闭SELinux"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"
  # 关闭SWAP
  echo "  >>> 关闭SWAP"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab"
  # 拷贝ipvs模块启用文件
  echo "  >>> 加载ipvs模块和管理工具"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "modprobe br_netfilter && modprobe ip_vs && modprobe ip_vs_rr && modprobe ip_vs_wrr && modprobe ip_vs_sh && modprobe nf_conntrack_ipv4"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "yum -y install ipvsadm bridge-utils"

  # 拷贝k8s必要的内核参数并加载
  echo "  >>> 加载必要内核参数"
  scp -o StrictHostKeyChecking=no ./kubernetes_sysctl.conf ${K8S_SERVICE_ACCOUNT}@${ip}:/etc/sysctl.d/kubernetes_sysclt.conf
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${ip} "sysctl -p /etc/sysctl.d/kubernetes_sysclt.conf"
  
done


echo -e "\033[32m[Task]\033[0m 创建CA根证书及证书策略."
cd ${TEMP_WORK_DIR}
# cfssl程序，也就是命令行工具
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
# cfssljson程序，从cfssl程序获取JSON输出，并加证书、米好、CSR和bundle写入磁盘
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
# 查看证书信息的工具
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
# 添加执行权限
chmod +x cfssl_linux-amd64 cfssljson_linux-amd64 cfssl-certinfo_linux-amd64
# 
mv cfssl_linux-amd64 /usr/local/bin/cfssl
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
mv cfssl-certinfo_linux-amd64 /usr/bin/cfssl-certinfo

echo -e "\033[32m[Task]\033[0m 创建CA根证书及证书策略。"
# 创建证书签名请求文件
# CN Common Name，浏览器使用该字段验证网站是否合法，如果是服务器证书CN就标识这个主机的域名，如果是客户端证书这个CN就是客户端使用的连接对方服务的账号名称
# O Organization ，一般为网站域名；而对于代码签名证书则为申请单位名称；而对于客户端单位证书则为证书申请者所在单位名称
# C 表示国家 L表示城市 ST表示省份
cat << EOF > ca-csr.json
{
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF

# 配置证书生成策略，这个不是用来生成CA自己的证书和私钥的而是用来生成其他申请人的证书，是证书配置文件后续的证书申请都根据这个策略来生成
# signing : 表示该证书可用于签名其它证书，生成的ca.pem证书中  CA=TRUE
# server auth : 表示client 可以使用该CA对server提供的证书进行验证
# client auth : 表示server 可以用该CA对client提供的证书进行验证
cat << EOF > ca-config.json
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
          ]
      },
      "etcd": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
          ]
      },
      "client": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "client auth"
          ]
      }
    }
  }
}
EOF
# 生成CA和私钥，运行后生成 ca.csr ca.pem ca-key.pem
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

echo -e "\033[32m[Task]\033[0m 拷贝CA根证书及私钥到ETCD集群中所有节点。"
for etcd_ip in ${ETCD_CLUSTER_IPS[@]}; do
  echo "  >>> 拷贝CA根证书及私钥到 ${etcd_ip} etcd节点."
  if [[ ${etcd_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
    cp ${TEMP_WORK_DIR}/ca*.pem ca-config.json ${ETCD_CERTIFICATE_PATH}
    continue
  fi
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/ca*.pem ca-config.json ${ETCD_SERVICE_ACCOUNT}@${etcd_ip}:${ETCD_CERTIFICATE_PATH}
done

echo -e "\033[32m[Task]\033[0m 拷贝CA根证书及私钥到Kubernetes集群中所有节点。"
for IP in ${ALL_K8S_CLUSTER_SRV_IPS[@]}; do
  echo "  >>> 拷贝CA根证书及私钥到 ${master_ip} master节点."
  if [[ ${IP} == ${EXEC_SCRIPT_HOST_IP} ]]; then
    cp ${TEMP_WORK_DIR}/ca*.pem ${KUBERNETES_CERTIFICATE_PATH}
    continue
  fi
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/ca*.pem ${K8S_SERVICE_ACCOUNT}@${IP}:${KUBERNETES_CERTIFICATE_PATH}
done

cp ${TEMP_WORK_DIR}/ca*.pem ${JOIN_CLUSTER_DIR}
cp ${TEMP_WORK_DIR}/kubernetes_sysctl.conf ${JOIN_CLUSTER_DIR}


