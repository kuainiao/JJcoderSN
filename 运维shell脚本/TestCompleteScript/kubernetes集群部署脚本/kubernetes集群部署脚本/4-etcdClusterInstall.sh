#!/bin/bash

# ETCD集群安装，建议提前在集群中开启免密登陆
# 需要把证书拷贝到所有节点对应目录，把etcd.conf文件中的IP修改为你自己环境的真实IP
# 在集群节点上的hosts文件中建立解析
# 
# https://www.cnblogs.com/breg/p/5728237.html
# https://www.cnblogs.com/softidea/p/6517959.html
# 
# 目前etcd的命令行工具etcdctl有2个版本一个是v2一个是v3而且两个版本数据不互通，flannel暂时支持v3，而k8s集群默认使用的是
# v3版本的。  直接执行etcdctl则是v2版本，如果要执行v3版本可以 ETCDCTL_API=3 etcdctl 这样就是按照v3版本执行。

ETCD_VERSION=v3.3.12

read -p "开始部署etcd集群，使用版本为${ETCD_VERSION}，输入y继续 [y/n] " isContinue
if [[ ${isContinue} == "n" ]]; then
  echo "程序退出。"
  exit 0
fi

source ./environment.sh


# 状态查询命令
STATUS_CHECK_CMD=${ETCD_HOME}/bin/etcdctl --ca-file=${ETCD_CERTIFICATE_PATH}/ssl/ca.pem \
--cert-file=${ETCD_CERTIFICATE_PATH}/ssl/etctsrv.pem --key-file=${ETCD_CERTIFICATE_PATH}/ssl/etctsrv-key.pem \
--endpoints="${ETCD_ENDPOINTS}" cluster-health

if [ ! -d $ETCD_HOME ]; then
	echo "${ETCD_HOME}目录不存在，脚本退出。请先执行system_initialization.sh脚本。"
	exit 1
fi

# 情况临时工作目录
cd ${TEMP_WORK_DIR}

# 创建证书
echo -e "\033[32m[Task]\033[0m 为etcd创建证书和私钥。"
# 创建ETCD证书，把IP换成你环境的etcd的IP地址或者主机名
# CN为域名  hosts为主题备用列表也就是指定哪些IP或者域名可以使用这个证书，如果hosts为空表示使用CN中定义的名称，且为客户端证书
cat << EOF > etcdsrv-csr.json
{
    "CN": "etcd",
    "hosts": [
    "127.0.0.1",
    "192.168.10.10",
    "192.168.10.20",
    "192.168.10.30",
    "srv01.contoso.com",
    "srv02.contoso.com",
    "srv03.contoso.com",
    "*.contoso.com"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing"
        }
    ]
}
EOF
# 运行后生成 etcdsrv.pem etcdsrv-key.pem
# gencert是生产新的秘钥和签名证书 -ca指定CA的证书 -ca-key指定CA的私钥  -config指定证书申请的JSON文件 -profile与-config中的profile对应，根据config中的prifile端来生成证书相关信息
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcdsrv-csr.json | cfssljson -bare etcdsrv

echo -e "\033[32m[Task]\033[0m 拷贝etcd证书到etcd各个节点。"
for etcd_ip in ${ETCD_CLUSTER_IPS[@]}; do
  echo "  >>> 复制证书到 ${etcd_ip} etcd节点."
  if [[ ${etcd_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
    cp ${TEMP_WORK_DIR}/etcdsrv*.pem ${ETCD_CERTIFICATE_PATH}
    continue
  fi
  scp ${TEMP_WORK_DIR}/etcdsrv*.pem ${ETCD_SERVICE_ACCOUNT}@${etcd_ip}:${ETCD_CERTIFICATE_PATH}
done


# 下载解压etcd软件并进行分发
echo -e "\033[32m[Task]\033[0m 检查当前目录是否有该etcd-${ETCD_VERSION}-linux-amd64.tar.gz版本的二进制包。"
if [[ -e etcd-${ETCD_VERSION}-linux-amd64.tar.gz ]]; then
  echo "  >>> 当前目录存在etcd-${ETCD_VERSION}-linux-amd64.tar.gz"
else
  echo "  >>> 当前目录不存在etcd-${ETCD_VERSION}-linux-amd64.tar.gz即将下载"
  wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
fi
tar -xzf etcd-${ETCD_VERSION}-linux-amd64.tar.gz
chmod +x ./etcd-${ETCD_VERSION}-linux-amd64/*

# 配置环境变量
cat << EOF > etcdenv.sh
export ETCD_HOME=${ETCD_HOME}
export PATH=\${ETCD_HOME}/bin:\$PATH
EOF

cd ./etcd-${ETCD_VERSION}-linux-amd64/
echo -e "\033[32m[Task]\033[0m 复制etcd程序环境变量文件到目标主机."
for etcd_ip in ${ETCD_CLUSTER_IPS[@]}; do
  echo -e "  >>> 复制程序环境变量文件到${etcd_ip} ${ETCD_HOME}/bin目录."
  if [[ ${etcd_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
  	cp etcd etcdctl ${ETCD_HOME}/bin
  	cp ${TEMP_WORK_DIR}/etcdenv.sh /etc/profile.d/etcdenv.sh
  	source /etc/profile.d/etcdenv.sh
  	continue
  fi
  scp -o StrictHostKeyChecking=no etcd etcdctl ${ETCD_SERVICE_ACCOUNT}@${etcd_ip}:${ETCD_HOME}/bin
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/etcdenv.sh ${ETCD_SERVICE_ACCOUNT}@${etcd_ip}:/etc/profile.d/etcdenv.sh
done

cd ${TEMP_WORK_DIR}

echo -e "\033[32m[Task]\033[0m 创建etcd启动的systemd文件."
# etcd启动文件
# 这个文件里的是真正的启动参数，上面的文件只是定义变量在这里赋值。另外所有--init开头的配置都是在
# 集群bootstrap时候才会用到，后续节点重启则会被忽略。
# --name= 节点名称
# --data-dir= 数据目录
# --listen-client-urls= 对外提供服务的URL，同时也要写上http://127.0.0.1:2379因为etcdctl客户端会连接到这里
# --listen-peer-urls= 监听URL用于和其他节点通信，理解为集群节点之间的通信URL
# --advertise-client-urls= 该节点同伴监听地址，这个值会告诉集群中其他节点
# --initial-cluster-token= 集群ID
# --initial-cluster= 集群中所有节点
# --initial-cluster-state= 初始化集群时候的状态
# --cert-file 和 --key-file etcd server与client通信使用的证书和私钥
# --trusted-ca-file= 签名client的CA根证书，用于验证client证书
# --client-cert-auth
# --peer-cert-file= --peer-key-file= etc与peer通信使用的证书和私钥
# --peer-trusted-ca-file=  签名peer证书的CA根证书，用于验证peer证书
# --peer-client-cert-auth 
cat << EOF > etcd.service.template
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
User=${ETCD_SERVICE_ACCOUNT}
Type=notify
WorkingDirectory=${ETCD_DATA_PATH}
ExecStart=${ETCD_HOME}/bin/etcd --name=###ETCD_NODE_NAME### \\
--data-dir=${ETCD_DATA_PATH} \\
--listen-client-urls=https://###ETCD_NODE_IP###:2379,http://127.0.0.1:2379 \\
--listen-peer-urls=https://###ETCD_NODE_IP###:2380 \\
--advertise-client-urls=https://###ETCD_NODE_IP###:2379 \\
--initial-cluster-token=etcd-cluster \\
--initial-cluster=${ETCD_NODES} \\
--initial-cluster-state=new \\
--initial-advertise-peer-urls=https://###ETCD_NODE_IP###:2380 \\
--cert-file=${ETCD_HOME}/ssl/etcdsrv.pem \\
--key-file=${ETCD_HOME}/ssl/etcdsrv-key.pem \\
--trusted-ca-file=${ETCD_HOME}/ssl/ca.pem \\
--client-cert-auth \\
--peer-cert-file=${ETCD_HOME}/ssl/etcdsrv.pem \\
--peer-key-file=${ETCD_HOME}/ssl/etcdsrv-key.pem \\
--peer-trusted-ca-file=${ETCD_HOME}/ssl/ca.pem \\
--peer-client-cert-auth
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF


echo -e "\033[32m[Task]\033[0m 替换etcd服务启动文件变量."
for (( i=0; i<${#ETCD_CLUSTER_IPS[*]}; i++ )); do
  # -e 参数可以在同一行执行多条查找替换命令，否则只能执行一个
  sed -e "s/###ETCD_NODE_NAME###/${ETCD_NODE_NAMES[i]}/" -e "s/###ETCD_NODE_IP###/${ETCD_CLUSTER_IPS[i]}/" etcd.service.template > etcd-${ETCD_CLUSTER_IPS[i]}.service
done


echo -e "\033[32m[Task]\033[0m 拷贝etcd启动的systemd文件到etcd各个节点."
for etcd_ip in ${ETCD_CLUSTER_IPS[@]}; do
  if [[ ${etcd_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
  	cp etcd-${etcd_ip}.service /usr/lib/systemd/system/etcd.service
    systemctl daemon-reload && systemctl enable etcd
  	continue
  fi
  scp -o StrictHostKeyChecking=no etcd-${etcd_ip}.service ${ETCD_SERVICE_ACCOUNT}@${etcd_ip}:/usr/lib/systemd/system/etcd.service
  ssh -o StrictHostKeyChecking=no ${ETCD_SERVICE_ACCOUNT}@${etcd_ip} "systemctl daemon-reload && systemctl enable etcd"
done

echo -e "\033[32m[Task]\033[0m 启动etcd集群."
# etcd集群第一台启动后它会等待集群其他节点etct启动，如果在一段时间等不到就会超时而终止服务，所以第一台运行systemctl start etcd 这个命令会卡出也很正常。
for etcd_ip in ${ETCD_CLUSTER_IPS[@]}; do
  echo "  >>> 启动 ${etcd_ip} etcd服务。"
  if [[ ${etcd_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
  	systemctl start etcd &
  	continue
  fi
  ssh -o StrictHostKeyChecking=no ${ETCD_SERVICE_ACCOUNT}@${etcd_ip} "systemctl start etcd &"
done

echo -e "\033[32m[Task]\033[0m 检查etcd集群状态."
# 检查集群状态
# ${ETCD_HOME}/bin/etcdctl --ca-file=${ETCD_CERTIFICATE_PATH}/ca.pem \
# --cert-file=${ETCD_CERTIFICATE_PATH}/etcdsrv.pem --key-file=${ETCD_CERTIFICATE_PATH}/etcdsrv-key.pem \
# --endpoints="${ETCD_ENDPOINTS}" cluster-health
# 这里主要是判断执行脚本主机是否在ETCD集群节点里，避免执行主机IP并不是ETCD_CLUSTER_IPS数组的第一个元素从而造成执行两遍的问题
# 因为下面的命令只需要在任意一个etcd节点上执行一次。
echo "${ETCD_CLUSTER_IPS[@]}" | grep -wq "${EXEC_SCRIPT_HOST_IP}" && RESULT="YES" || RESULT="NO"
if [[ $RESULT == "YES" ]]; then
  ${ETCD_HOME}/bin/etcdctl --ca-file=${ETCD_CERTIFICATE_PATH}/ca.pem \
    --cert-file=${ETCD_CERTIFICATE_PATH}/etcdsrv.pem --key-file=${ETCD_CERTIFICATE_PATH}/etcdsrv-key.pem \
    --endpoints=${ETCD_ENDPOINTS} cluster-health

    echo ""
    ${ETCD_HOME}/bin/etcdctl --ca-file=${ETCD_CERTIFICATE_PATH}/ca.pem \
    --cert-file=${ETCD_CERTIFICATE_PATH}/etcdsrv.pem --key-file=${ETCD_CERTIFICATE_PATH}/etcdsrv-key.pem \
    --endpoints=${ETCD_ENDPOINTS} member list
else
  for etcd_ip in ${ETCD_CLUSTER_IPS[@]}; do
    ssh -o StrictHostKeyChecking=no ${ETCD_SERVICE_ACCOUNT}@${etcd_ip} "${ETCD_HOME}/bin/etcdctl --ca-file=${ETCD_CERTIFICATE_PATH}/ca.pem \
    --cert-file=${ETCD_CERTIFICATE_PATH}/etcdsrv.pem --key-file=${ETCD_CERTIFICATE_PATH}/etcdsrv-key.pem \
    --endpoints=${ETCD_ENDPOINTS} cluster-health"
    echo ""
    ssh -o StrictHostKeyChecking=no ${ETCD_SERVICE_ACCOUNT}@${etcd_ip} "${ETCD_HOME}/bin/etcdctl --ca-file=${ETCD_CERTIFICATE_PATH}/ca.pem \
    --cert-file=${ETCD_CERTIFICATE_PATH}/etcdsrv.pem --key-file=${ETCD_CERTIFICATE_PATH}/etcdsrv-key.pem \
    --endpoints=${ETCD_ENDPOINTS} member list"
    break
  done
fi

echo "如果启动失败请使用该命令查看 journalctl -b -u etcd"






