#!/bin/bash
# 在集群上安装Node角色，Node角色包括kubelet、docker、kube_proxy，docker已经在3-installDocker.sh中完成
# kubelet 运行在每个 worker 节点上，接收 kube-apiserver 发送的请求，管理 Pod 容器，执行交互式命令，如exec、run、logs 等
#         kublet 启动时自动向 kube-apiserver 注册节点信息，内置的 cadvisor 统计和监控节点的资源使用情况
# 理解bootstrapping非常重要，  https://mritd.me/2018/01/07/kubernetes-tls-bootstrapping-note/

KUBERNETES_SERVER_VERSION=v1.13.4

read -p "开始部署Kubernetes的server组件，使用版本为${KUBERNETES_SERVER_VERSION}，输入y继续 [y/n] " isContinue
if [[ ${isContinue} == "n" ]]; then
  echo "程序退出。"
  exit 0
fi

source ./environment.sh

cd ${TEMP_WORK_DIR}
echo -e "\033[32m[Task]\033[0m 检查当前目录是否有该${KUBERNETES_SERVER_VERSION}版本的二进制包。"
if [[ -e kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz ]]; then
  echo "  >>> 当前目录存在kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz"
else
  echo "  >>> 当前目录不存在kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz即将下载"
  wget https://dl.k8s.io/${KUBERNETES_SERVER_VERSION}/kubernetes-server-linux-amd64.tar.gz -O kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz
fi
tar -xzf kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz


# 设置环境变量，为了方便使用k8s的server端各种命令
cat << EOF > kubernetes_node_cmdenv.sh
#!/bin/bash
export K8S_NODE_HOME=${KUBERNETES_NODE_HOME}
export PATH=\${K8S_NODE_HOME}/bin:\$PATH
EOF


echo -e "\033[32m[Task]\033[0m 创建 kubelet bootstrap kubeconfig 文件。"
for node_name in ${ALL_K8S_CLUSTER_SRV_NAMES[@]}
  do
    echo "  >>> ${node_name}"

    # 创建 token，这里创建token的方式和网上其他文档会有不同，别的文档的token是固定的一串字符串，而我这里是通过kubeadm命令生成的
    # 而且为每个机器都生成了tocke。我们这里使用之前为kubectl生成的kubeconfig文件来抓取管理员密码，因为当时这个kubeconfig就是admin权限
    # 因为我们使用一个已经存在的用户的token所以我们在部署api server的时候没有指定token文件。其他文档在api server上和kubelet上指定
    # token是为了让两变初始认证，而我们使用一个已存在的用户的token那么就只需要在此设置就可以，另外这个token只能实现认证，但是这个用户没有任何权限，所以
    # 我们还得创建一个针对该用户的clusterrolebinding把用户 kubelet-bootstrap绑定到system:node-bootstrapper来完成初次加入集群的授权
    # 其实下面这种方式不但适用于新创建集群也适用于在当前集群中增加node节点。
    export BOOTSTRAP_TOKEN=$(./kubernetes/server/bin/kubeadm token create \
      --description kubelet-bootstrap-token \
      --groups system:bootstrappers:${node_name} \
      --kubeconfig ./kubectl.kubeconfig)

    # 设置集群参数
    ${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-cluster kubernetes \
      --certificate-authority=${TEMP_WORK_DIR}/ca.pem \
      --embed-certs=true \
      --server=${KUBE_APISERVER} \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置客户端认证参数
    ${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-credentials kubelet-bootstrap \
      --token=${BOOTSTRAP_TOKEN} \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置上下文参数
    ${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-context default \
      --cluster=kubernetes \
      --user=kubelet-bootstrap \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置默认上下文
    ${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config use-context default --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig
  done


echo -e "\033[32m[Task]\033[0m 生成kubelet服务额外配置文件."
# 这些配置项也是kubelet命令中的参数，但是这些参数要通过额外的配置文件提供，这个文件可以写成JSON格式也可以是YAML格式
# https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/#create-the-config-file
# kubelet传递DNS设置给每一个容器通过 clusterDomain 和 clusterDNS 来设置容器中/etc/resolv.conf文件，来设置搜索域和DNS服务器地址
cat > kubelet.config.json.template <<EOF
{
  "kind": "KubeletConfiguration",
  "apiVersion": "kubelet.config.k8s.io/v1beta1",
  "authentication": {
    "x509": {
      "clientCAFile": "${KUBERNETES_CERTIFICATE_PATH}/ca.pem"
    },
    "webhook": {
      "enabled": true,
      "cacheTTL": "2m0s"
    },
    "anonymous": {
      "enabled": false
    }
  },
  "authorization": {
    "mode": "Webhook",
    "webhook": {
      "cacheAuthorizedTTL": "5m0s",
      "cacheUnauthorizedTTL": "30s"
    }
  },
  "address": "##NODE_IP##",
  "port": 10250,
  "readOnlyPort": 10255,
  "cgroupDriver": "cgroupfs",
  "serializeImagePulls": false,
  "featureGates": {
    "RotateKubeletClientCertificate": true,
    "RotateKubeletServerCertificate": true
  },
  "clusterDomain": "${CLUSTER_DNS_DOMAIN}",
  "clusterDNS": ["${CLUSTER_DNS_SVC_IP}"]
}
EOF
for (( i=0; i<${#ALL_K8S_CLUSTER_SRV_IPS[*]}; i++ )); do
  sed -e "s/##NODE_IP##/${ALL_K8S_CLUSTER_SRV_IPS[i]}/" kubelet.config.json.template > kubelet.config-${ALL_K8S_CLUSTER_SRV_NAMES[i]}.json
done


echo -e "\033[32m[Task]\033[0m 生成kubelet服务模板文件."
# 如果设置了 --hostname-override 选项，则 kube-proxy 也需要设置该选项，否则会出现找不到 Node 的情况
# --cert-dir该目录是kubelet向controller manager申请客户端证书和服务器证书后存放证书的位置
# --kubeconfig kubelet使用的kubeconfig文件的位置，由于它没有这个文件所以会使用--bootstrap-kubeconfig的文件向api server发送证书申请
#   当批准以后会自动生成kubeconfig文件，同时这个文件会包含--cert-dir目录中的证书和私钥。
#   
# 根据默认和我们的设置kubelet启动后会开启3个端口
#   10248: healthz http 服务  127.0.0.1
#   10250: https API 服务且不允许匿名访问，只读端口10255  在本机IP监听
#          kubelet 接收 10250 端口的 https 请求 /pods、/runningpods 、/metrics、/metrics/cadvisor、/metrics/probes、/spec、/stats、/stats/container等
#          
# --rotate-certificates 应该放进 kubelet.config.json
# --allow-privileged=true 参数已经过时需要看看替代参数
cat > kubelet.service.template <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=${KUBELET_WORKING_DIR}
ExecStart=${KUBERNETES_NODE_HOME}/bin/kubelet \\
  --bootstrap-kubeconfig=${KUBERNETES_NODE_HOME}/cfg/kubelet-bootstrap.kubeconfig \\
  --config=${KUBERNETES_NODE_HOME}/cfg/kubelet.config.json \\
  --cert-dir=${KUBERNETES_CERTIFICATE_PATH} \\
  --kubeconfig=${KUBERNETES_NODE_HOME}/cfg/kubelet.kubeconfig \\
  --hostname-override=##NODE_NAME## \\
  --rotate-certificates \\
  --pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest \\
  --allow-privileged=true \\
  --alsologtostderr=true \\
  --logtostderr=false \\
  --log-dir=${KUBERNETES_LOGS_DIR} \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
for node_name in ${ALL_K8S_CLUSTER_SRV_NAMES[@]}; do 
  echo ">>> ${node_name}"
  sed -e "s/##NODE_NAME##/${node_name}/" kubelet.service.template > kubelet-${node_name}.service
done


echo -e "\033[32m[Task]\033[0m 创建kube-proxy证书和私钥。"
# CN：指定该证书的 User 为 system:kube-proxy 预定义的 RoleBinding system:node-proxier 将User system:kube-proxy 与 Role system:node-proxier 
# 绑定，该 Role 授予了调用 kube-apiserver Proxy 相关 API 的权限
cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
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
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy


echo -e "\033[32m[Task]\033[0m 创建kube-proxy使用的kubeconfig文件。"
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-cluster kubernetes \
  --certificate-authority=${TEMP_WORK_DIR}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig

${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-credentials kube-proxy \
  --client-certificate=${TEMP_WORK_DIR}/kube-proxy.pem \
  --client-key=${TEMP_WORK_DIR}/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig


echo -e "\033[32m[Task]\033[0m 创建kube-proxy使用的额外配置文件。"
# clusterCIDR: kube-proxy 根据 --cluster-cidr 判断集群内部和外部流量，指定 --cluster-cidr 
#              或 --masquerade-all 选项后 kube-proxy 才会对访问 Service IP 的请求做 SNAT
# hostnameOverride: 参数值必须与 kubelet 的值一致，否则 kube-proxy 启动后会找不到该 Node，从而不会创建任何 ipvs 规则
# 10249：http prometheus metrics port    10256：http healthz port;
cat > kube-proxy.config.yaml.template <<EOF
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: ##NODE_IP##
clientConnection:
  kubeconfig: ${KUBERNETES_NODE_HOME}/cfg/kube-proxy.kubeconfig
clusterCIDR: ${CLUSTER_CIDR}
healthzBindAddress: ##NODE_IP##:10256
hostnameOverride: ##NODE_NAME##
kind: KubeProxyConfiguration
metricsBindAddress: ##NODE_IP##:10249
mode: "ipvs"
EOF
for (( i=0; i<${#ALL_K8S_CLUSTER_SRV_IPS[*]}; i++ )); do
  sed -e "s/##NODE_IP##/${ALL_K8S_CLUSTER_SRV_IPS[i]}/" -e "s/##NODE_NAME##/${ALL_K8S_CLUSTER_SRV_NAMES[i]}/" kube-proxy.config.yaml.template > kube-proxy-${ALL_K8S_CLUSTER_SRV_IPS[i]}-config.yaml
done

echo -e "\033[32m[Task]\033[0m 创建kube-proxy服务配置文件。"
cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
WorkingDirectory=${KUBEPROXY_WORKING_DIR}
ExecStart=${KUBERNETES_NODE_HOME}/bin/kube-proxy \\
  --config=${KUBERNETES_NODE_HOME}/cfg/kube-proxy-config.yaml \\
  --alsologtostderr=true \\
  --logtostderr=false \\
  --log-dir=${KUBERNETES_LOGS_DIR} \\
  --v=2
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF


echo -e "\033[32m[Task]\033[0m 拷贝kubelet和kube_proxy服务所需文件到集群所有节点。"
for (( i=0; i<${#ALL_K8S_CLUSTER_SRV_IPS[*]}; i++ )); do
  IP=${ALL_K8S_CLUSTER_SRV_IPS[i]}
  NAME=${ALL_K8S_CLUSTER_SRV_NAMES[i]}
  echo "执行到 ${IP} 集群节点的拷贝."
  if [[ ${IP} == ${EXEC_SCRIPT_HOST_IP} ]]; then
    echo "  >>> 拷贝二进制程序."
    cp ${TEMP_WORK_DIR}/kubernetes/server/bin/* ${KUBERNETES_NODE_HOME}/bin

    echo "  >>> 拷贝bootstrap文件"
    cp ${TEMP_WORK_DIR}/kubelet-bootstrap-${NAME}.kubeconfig ${KUBERNETES_NODE_HOME}/cfg/kubelet-bootstrap.kubeconfig
    echo "  >>> 拷贝kubelet额外使用的config文件"
    cp ${TEMP_WORK_DIR}/kubelet.config-${NAME}.json ${KUBERNETES_NODE_HOME}/cfg/kubelet.config.json
    echo "  >>> 拷贝kubelet服务文件"
    cp ${TEMP_WORK_DIR}/kubelet-${NAME}.service /usr/lib/systemd/system/kubelet.service

    echo "  >>> 拷贝kube-proxy的证书文件"
    cp ${TEMP_WORK_DIR}/kube-proxy.pem kube-proxy-key.pem ${KUBERNETES_CERTIFICATE_PATH}
    echo "  >>> 拷贝kube-proxy的kubeconfig文件"
    cp ${TEMP_WORK_DIR}/kube-proxy.kubeconfig ${KUBERNETES_NODE_HOME}/cfg/kube-proxy.kubeconfig
    echo "  >>> 拷贝kube-proxy的额外配置文件"
    cp ${TEMP_WORK_DIR}/kube-proxy-${IP}-config.yaml ${KUBERNETES_NODE_HOME}/cfg/kube-proxy-config.yaml
    echo "  >>> 拷贝kube-proxy服务文件"
    cp ${TEMP_WORK_DIR}/kube-proxy.service /usr/lib/systemd/system/kube-proxy.service
    echo "  >>> 拷贝node节点命令的环境变量文件文件"
    cp ${TEMP_WORK_DIR}/kubernetes_node_cmdenv.sh /etc/profile.d/kubernetes_node_cmdenv.sh

    echo "  >>> 设置kubelet和kube-proxy为开机启动"
    systemctl daemon-reload && systemctl enable kubelet && systemctl enable kube-proxy
    continue
  fi
  echo "  >>> 拷贝二进制程序."
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kubernetes/server/bin/* ${K8S_SERVICE_ACCOUNT}@${IP}:${KUBERNETES_NODE_HOME}/bin

  echo "  >>> 拷贝bootstrap文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kubelet-bootstrap-${NAME}.kubeconfig ${K8S_SERVICE_ACCOUNT}@${IP}:${KUBERNETES_NODE_HOME}/cfg/kubelet-bootstrap.kubeconfig
  echo "  >>> 拷贝kubelet额外使用的config文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kubelet.config-${NAME}.json ${K8S_SERVICE_ACCOUNT}@${IP}:${KUBERNETES_NODE_HOME}/cfg/kubelet.config.json
  echo "  >>> 拷贝kubelet服务文件"
  scp ${TEMP_WORK_DIR}/kubelet-${NAME}.service ${K8S_SERVICE_ACCOUNT}@${IP}:/usr/lib/systemd/system/kubelet.service

  echo "  >>> 拷贝kube-proxy的证书文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kube-proxy.pem kube-proxy-key.pem ${K8S_SERVICE_ACCOUNT}@${IP}:${KUBERNETES_CERTIFICATE_PATH}
  echo "  >>> 拷贝kube-proxy的kubeconfig文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kube-proxy.kubeconfig ${K8S_SERVICE_ACCOUNT}@${IP}:${KUBERNETES_NODE_HOME}/cfg/kube-proxy.kubeconfig
  echo "  >>> 拷贝kube-proxy的额外配置文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kube-proxy-${IP}-config.yaml ${K8S_SERVICE_ACCOUNT}@${IP}:${KUBERNETES_NODE_HOME}/cfg/kube-proxy-config.yaml
  echo "  >>> 拷贝kube-proxy服务文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kube-proxy.service ${K8S_SERVICE_ACCOUNT}@${IP}:/usr/lib/systemd/system/kube-proxy.service
  echo "  >>> 拷贝node节点命令的环境变量文件文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kubernetes_node_cmdenv.sh ${K8S_SERVICE_ACCOUNT}@${IP}:/etc/profile.d/kubernetes_node_cmdenv.sh
  
  echo "  >>> 设置kubelet和kube-proxy为开机启动"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${IPS} "systemctl daemon-reload && systemctl enable kubelet && systemctl enable kube-proxy"
done


echo -e "\033[32m[Task]\033[0m 启动Kubernetes集群节点kubelet和kube-proxy服务。"
for IP in ${ALL_K8S_CLUSTER_SRV_IPS[@]}; do
  echo "  >>> 启动 ${IP} 节点kubelet和kube-proxy服务"
  if [[ ${ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
    systemctl start kubelet && systemctl start kube-proxy
    continue
  fi
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${node_ip} "systemctl start kubelet && systemctl start kube-proxy"
done

cp ${TEMP_WORK_DIR}/kube-proxy.pem kube-proxy-key.pem ${JOIN_CLUSTER_DIR}

echo -e "\033[32m[Task]\033[0m 查看Kubelet的CSR请求和查看有效节点。"
echo "${MASTER_IPS[@]}" | grep -wq "${EXEC_SCRIPT_HOST_IP}" && RESULT="YES" || RESULT="NO"
sleep 1
if [[ $RESULT == "YES" ]]; then
  ${KUBERNETES_SERVER_HOME}/bin/kubectl get csr
  ${KUBERNETES_SERVER_HOME}/bin/kubectl get nodes
else
  for etcd_ip in ${ETCD_CLUSTER_IPS[@]}; do
    ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${master_ip} "${KUBERNETES_SERVER_HOME}/bin/kubectl get csr"
    ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${master_ip} "${KUBERNETES_SERVER_HOME}/bin/kubectl get nodes"
    break
  done
fi
echo "后续请使用 kubectl get csr 和 kubectl get nodes 命令查看"
echo "请在Master主机上执行 kubectl get node --show-labels 查看主机及其标签，然后 kubectl label nodes [NAME] noderole=apiserver 为API SERVER节点增加标签"


# cadvisor接口
# https://IP:10250/metrics/cadvisor
# http://IP:10255/metrics/cadvisor





