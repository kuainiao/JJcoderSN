#!/bin/bash
# 在Master节点上运行
# 部署flannel网络插件，该插件只需要运行在node节点上且需要root权限运行，为什么使用kubeadm安装的集群在master角色上也有flannel呢？因为master的角色本身也是容器
# 而且flannel服务需要在docker服务启动之前运行，flannel服务启动时主要做了以下几步的工作
# 从etcd中获取network的配置信息 划分subnet，并在etcd中进行注册 将子网信息记录到/run/flannel/subnet.env中
# 文档 https://www.cnblogs.com/ZisZ/p/9212820.html?utm_source=debugrun&utm_medium=referral
#     https://www.cnblogs.com/breezey/p/9419612.html
#     https://www.cnblogs.com/kevingrace/p/6859114.html
#     
#  Master上其实可以不需要安装Flannel，但是如果你安装了某些k8s附件程序而且是通过POD形式运行，那么api server如果要和这些POD进行通信
#  的话，如果不在Master上安装Flannel则无法通信，因为没有隧道路由不可达。

FLANNEL_VERSION=v0.11.0

read -p "开始部署flannel网络插件，使用版本${FLANNEL_VERSION}，输入y继续 [y/n] " isContinue
if [[ ${isContinue} == "n" ]]; then
  echo "程序退出。"
  exit 0
fi
source ./environment.sh


cd ${TEMP_WORK_DIR}
echo -e "\033[32m[Task]\033[0m 检查当前目录是否有flannel-${FLANNEL_VERSION}-linux-amd64.tar.gz二进制包。"
if [[ -e flannel-${FLANNEL_VERSION}-linux-amd64.tar.gz ]]; then
  echo "  >>> 当前目录存在flannel-${FLANNEL_VERSION}-linux-amd64.tar.gz"
else
  echo "  >>> 当前目录不存在flannel-${FLANNEL_VERSION}-linux-amd64.tar.gz即将下载"
  wget https://github.com/coreos/flannel/releases/download/${FLANNEL_VERSION}/flannel-${FLANNEL_VERSION}-linux-amd64.tar.gz
fi
tar -xzf flannel-${FLANNEL_VERSION}-linux-amd64.tar.gz


echo -e "\033[32m[Task]\033[0m 生成flannel证书和私钥。"
cat > flanneld-csr.json << EOF
{
  "CN": "flanneld",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "4Paradigm"
    }
  ]
}
EOF
# 会产生 kubectl-admin.pem  kubectl-admin-key.pem
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes flanneld-csr.json | cfssljson -bare flanneld


# 创建 flanneld 的 systemd unit 文件
echo -e "\033[32m[Task]\033[0m 创建flanneld的systemd unit文件。"
# -iface flanneld 使用系统缺省路由所在的接口与其它节点通信，对于有多个网络接口（如内网和公网）的节点，可以用 -iface 参数指定通信接口
# mk-docker-opts.sh这个脚本是flannel二进制程序包解压缩出来的，mk-docker-opts.sh 脚本将分配给 flanneld 的 Pod 子网网段信息写入 
#                  /run/docker_opts.env 文件，后续 docker 启动时 使用这个文件中的环境变量配置 docker0 网桥
#                  -k 设置键，默认是DOCKER_OPTS，这个键在docker.service文件中会被引用，然后让dockerd这个命令来加载这个键里面的值，其实就是dockerd进程的启动参数
#                  -d 是设置docker env文件路径，默认是/run/docker_opts.env
#                  这个脚本要做的就是修改dockerd进程启动参数而这些参数也是dockerd本身支持的 https://docs.docker.com/engine/reference/commandline/dockerd/
cat > flanneld.service << EOF
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service

[Service]
Type=notify
ExecStart=${FLANNEL_HOME}/bin/flanneld \
  -etcd-cafile=${FLANNEL_HOME}/ssl/ca.pem \
  -etcd-certfile=${FLANNEL_HOME}/ssl/flanneld.pem \
  -etcd-keyfile=${FLANNEL_HOME}/ssl/flanneld-key.pem \
  -etcd-endpoints=${ETCD_ENDPOINTS} \
  -etcd-prefix=${FLANNEL_ETCD_PREFIX} \
  -iface=${FLANNEL_IFACE}
ExecStartPost=${FLANNEL_HOME}/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/docker_opts.env
Restart=on-failure

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
EOF


echo -e "\033[32m[Task]\033[0m 拷贝flannel证书及私钥到集群中所有Node节点。"
for node_ip in ${NODE_IPS[@]}; do
  echo "  >>> 拷贝flannel证书及私钥到 ${node_ip} node节点."
  scp ${TEMP_WORK_DIR}/flanneld*.pem ca*.pem ca-config.json root@${node_ip}:${FLANNEL_HOME}/ssl
  echo "  >>> 拷贝flannel程序 ${node_ip} node节点."
  scp ${TEMP_WORK_DIR}/flanneld mk-docker-opts.sh root@${node_ip}:${FLANNEL_HOME}/bin
  scp ${TEMP_WORK_DIR}/mk-docker-opts.sh root@${node_ip}:${FLANNEL_HOME}/bin
  echo "  >>> 拷贝flannel服务启动文件到 ${node_ip} node节点."
  scp ${TEMP_WORK_DIR}/flanneld.service root@${node_ip}:/usr/lib/systemd/system/flanneld.service
  echo "  >>> 设置 ${node_ip} node节点 flannel开机启动."
  ssh ${node_ip} "systemctl daemon-reload && systemctl enable flanneld"
done


echo -e "\033[32m[Task]\033[0m 拷贝flannel证书及私钥到etcd集群节点上。"
# 这一步主要是为了在etcd节点上使用flannel证书来查看etcd的flannel网络设置
for etcd_ip in ${ETCD_CLUSTER_IPS[@]}; do
  if [[ ${etcd_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
    cp ${TEMP_WORK_DIR}/flanneld.pem flanneld-key.pem ${ETCD_CERTIFICATE_PATH}
    continue
  fi
    scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/flanneld.pem flanneld-key.pem root@${node_ip}:${ETCD_CERTIFICATE_PATH}
done


echo -e "\033[32m[Task]\033[0m 拷贝flannel证书及私钥到集群中所有Master节点。"
for master_ip in ${MASTER_IPS[@]}; do
  if [[ ${master_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
    echo "  >>> 拷贝flannel证书及私钥到 ${master_ip} master节点."
    cp ${TEMP_WORK_DIR}/flanneld*.pem ca*.pem ca-config.json ${FLANNEL_HOME}/ssl
    echo "  >>> 拷贝flannel程序 ${master_ip} master节点."
    cp ${TEMP_WORK_DIR}/flanneld mk-docker-opts.sh ${FLANNEL_HOME}/bin
    cp ${TEMP_WORK_DIR}/mk-docker-opts.sh ${FLANNEL_HOME}/bin
    echo "  >>> 拷贝flannel服务启动文件到 ${master_ip} master节点."
    cp ${TEMP_WORK_DIR}/flanneld.service /usr/lib/systemd/system/flanneld.service
    echo "  >>> 设置${master_ip} master节点 flannel服务开机启动 ."
    systemctl daemon-reload && systemctl enable flanneld
    continue
  fi
  echo "  >>> 拷贝flannel证书及私钥到 ${master_ip} master节点."
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/flanneld*.pem ca*.pem ca-config.json ${K8S_SERVICE_ACCOUNT}@${master_ip}:${FLANNEL_HOME}/ssl
  echo "  >>> 拷贝flannel程序 ${master_ip} master节点."
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/flanneld mk-docker-opts.sh ${K8S_SERVICE_ACCOUNT}@${master_ip}:${FLANNEL_HOME}/bin
  echo "  >>> 拷贝flannel服务启动文件到 ${master_ip} master节点."
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/flanneld.service ${K8S_SERVICE_ACCOUNT}@${master_ip}:/usr/lib/systemd/system/flanneld.service
  echo "  >>> 设置${master_ip} master节点 flannel服务开机启动 ."
  ssh ${master_ip} "systemctl daemon-reload && systemctl enable flanneld"
done


# 向 etcd 写入集群 Pod 网段信息，只需要写入一次
echo -e "\033[32m[Task]\033[0m 向etcd写入集群Pod网段信息。"
# Network POD使用的网段，使用16位掩码，通过SubnetLen来设置子网切割，这个值要和kube-controller-manager的 -cluster-cidr一致
# SubnetLen 小网段按照什么长度的掩码切割，默认是24
# set 就是设置flannel保存网络配置时使用的etcd的路径也就是在这个路径下保存这些数据，因为k8s不管理网络，所以这个节点只有flannel使用。
# 
# 这里如果master就是etcd则本地执行，如果master不是etcd节点就远程执行，由于引号嵌套问题所以我这里生成脚本然后复制脚本到远程然后再执行
# 这里直接使用etcdctl默认是v2版本的，因为flannel目前不支持v3版本。
cat > create_subnet.sh << EOF
#!/bin/bash
${ETCD_HOME}/bin/etcdctl --ca-file=${ETCD_CERTIFICATE_PATH}/ca.pem \
    --cert-file=${ETCD_CERTIFICATE_PATH}/flanneld.pem \
    --key-file=${ETCD_CERTIFICATE_PATH}/flanneld-key.pem \
    --endpoints=${ETCD_ENDPOINTS} \
    set ${FLANNEL_ETCD_PREFIX}/config '{"Network":"'${CLUSTER_CIDR}'", "SubnetLen": 24, "Backend": {"Type": "vxlan"}}'
EOF
chmod +x create_subnet.sh
# 这里主要是判断执行脚本主机是否在ETCD集群节点里，避免执行主机IP并不是ETCD_CLUSTER_IPS数组的第一个元素从而造成执行两遍的问题，下面的命令只需要执行一次即可
echo "${ETCD_CLUSTER_IPS[@]}" | grep -wq "${EXEC_SCRIPT_HOST_IP}" && RESULT="YES" || RESULT="NO"
if [[ $RESULT == "YES" ]]; then
  ${ETCD_HOME}/bin/etcdctl --ca-file=${ETCD_CERTIFICATE_PATH}/ca.pem \
    --cert-file=${ETCD_CERTIFICATE_PATH}/flanneld.pem \
    --key-file=${ETCD_CERTIFICATE_PATH}/flanneld-key.pem \
    --endpoints=${ETCD_ENDPOINTS} \
    set ${FLANNEL_ETCD_PREFIX}/config '{"Network":"'${CLUSTER_CIDR}'", "SubnetLen": 24, "Backend": {"Type": "vxlan"}}'
else
  for etcd_ip in ${ETCD_CLUSTER_IPS[@]}; do
    scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/create_subnet.sh ${etcd_ip}:${TEMP_WORK_DIR}/create_subnet.sh
    ssh -o StrictHostKeyChecking=no ${etcd_ip} "/bin/bash ${TEMP_WORK_DIR}/create_subnet.sh"
    break
  done
fi


echo -e "\033[32m[Task]\033[0m 启动Master节点上的flannel服务。"
for master_ip in ${MASTER_IPS[@]}; do
  if [[ ${master_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
    echo "  >>> 设置 ${master_ip} master节点的flannel服务开机启动 ."
    systemctl start flanneld
    sleep 0.2
    echo "  >>> 启动 ${master_ip} master节点的docker服务."
    systemctl start docker
    continue
  fi
  echo "  >>> 设置 ${master_ip} master节点的flannel服务开机启动 ."
  ssh ${master_ip} "systemctl start flanneld"
  sleep 0.2
  echo "  >>> 启动 ${master_ip} master节点的docker服务."
  ssh ${master_ip} "systemctl start docker"
done


echo -e "\033[32m[Task]\033[0m 启动Node节点上的flannel服务。"
for node_ip in ${NODE_IPS[@]}; do
  echo "  >>> 启动 ${node_ip} flanneld服务，并启动节点上的docker服务."
  ssh -o StrictHostKeyChecking=no ${node_ip} "systemctl start flanneld"
  # 休眠200毫秒是为了避免/run/docker_opts.env文件没有生成而导致docker启动读取不到网络配置信息
  sleep 0.2
  echo "  >>> 启动 ${node_ip} node节点的docker服务."
  ssh -o StrictHostKeyChecking=no ${node_ip} "systemctl start docker"
done


echo -e "\033[32m[Task]\033[0m 手动任务请在flannel主机上使用ping命令检查网络连通性。"

cp ${TEMP_WORK_DIR}/flanneld*.pem ${JOIN_CLUSTER_DIR}
cp ${TEMP_WORK_DIR}/flanneld.service ${JOIN_CLUSTER_DIR}
cp ${TEMP_WORK_DIR}/mk-docker-opts.sh ${JOIN_CLUSTER_DIR}








