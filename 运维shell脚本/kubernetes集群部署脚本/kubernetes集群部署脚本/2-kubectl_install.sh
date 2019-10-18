#!/bin/bash

# 部署kubectl命令行工具，kubectl命令以root身份运行，它的配置文件在root家目录.kube目录中。
# 它可以安装在任何节点不过我们只安装在了master节点上

KUBERNETES_CLIENT_VERSION=v1.13.4

read -p "开始部署kubectl命令行工具，使用版本为${KUBERNETES_CLIENT_VERSION}，输入y继续 [y/n] " isContinue
if [[ ${isContinue} == "n" ]]; then
  echo "程序退出。"
  exit 0
fi

source ./environment.sh
cd ${TEMP_WORK_DIR}

echo -e "\033[32m[Task]\033[0m 创建kubectl证书和私钥。"
# 创建kubectl客户端证书
# O 为 system:masters，kube-apiserver 收到该证书后将请求的 Group 设置为 system:masters
# 系统内置的ClusterRoleBinding  cluster-admin 默认将Group system:masters与角色cluster-admin绑定，这个角色具有所有API权限
# 所以我们这里把admin这个用户放到system:masters组里那么就自然具有了集群API所有权限。 
# 通过这个命令就可以看出来 kubectl describe clusterrolebinding cluster-admin
cat << EOF > kubectl-admin-csr.json
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "Beijing",
      "ST": "Beijing",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF
# 会产生 kubectl-admin.pem  kubectl-admin-key.pem
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubectl-admin-csr.json | cfssljson -bare kubectl-admin


echo -e "\033[32m[Task]\033[0m 检查当前目录是否有该${KUBERNETES_CLIENT_VERSION}版本的二进制包。"
if [[ -e kubernetes-client-linux-amd64_${KUBERNETES_CLIENT_VERSION}.tar.gz ]]; then
  echo "  >>> 当前目录存在kubernetes-client-linux-amd64_${KUBERNETES_CLIENT_VERSION}.tar.gz"
else
  echo "  >>> 当前目录不存在kubernetes-client-linux-amd64_${KUBERNETES_CLIENT_VERSION}.tar.gz即将下载"
  wget https://dl.k8s.io/${KUBERNETES_CLIENT_VERSION}/kubernetes-client-linux-amd64.tar.gz -O kubernetes-client-linux-amd64_${KUBERNETES_CLIENT_VERSION}.tar.gz
fi
tar -xzf kubernetes-client-linux-amd64_${KUBERNETES_CLIENT_VERSION}.tar.gz
chmod +x ${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl


# 创建kubeconfig文件，下面命令运行完毕会在当前目录产生kubectl.kubeconfig文件
echo -e "\033[32m[Task]\033[0m 创建kubeconfig文件。"
# 设置集群参数
# --embed-certs=true 是把证书文件嵌入到kubeconfig文件中，如果不加那么引用证书的时候写入的是证书路径，所以我们这里用当前目录就可以。
# --kubeconfig=指定kubeconfig文件位置
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-cluster kubernetes \
  --certificate-authority=${TEMP_WORK_DIR}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kubectl.kubeconfig

# 设置客户端认证参数
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-credentials admin \
  --client-certificate=${TEMP_WORK_DIR}/kubectl-admin.pem \
  --client-key=${TEMP_WORK_DIR}/kubectl-admin-key.pem \
  --embed-certs=true \
  --kubeconfig=kubectl.kubeconfig

# 设置上下文参数
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin \
  --kubeconfig=kubectl.kubeconfig
  
# 设置默认上下文
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config use-context kubernetes --kubeconfig=kubectl.kubeconfig



echo -e "\033[32m[Task]\033[0m 拷贝kubectl客户端工具 证书和kubeconfig文件到所有master节点。"
for master_ip in ${MASTER_IPS[@]}; do
  echo "  >>> 拷贝kubectl工具到 ${master_ip} master节点."
  if [[ ${master_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
    cp -p ${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl ${KUBERNETES_SERVER_HOME}/bin
    cp ${TEMP_WORK_DIR}/kubectl-admin*.pem ${KUBERNETES_CERTIFICATE_PATH}
    cp ${TEMP_WORK_DIR}/kubectl.kubeconfig /root/.kube/config
    continue
  fi
  scp -o StrictHostKeyChecking=no -p ${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl ${K8S_SERVICE_ACCOUNT}@${master_ip}:${KUBERNETES_SERVER_HOME}/bin
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kubectl-admin*.pem ${K8S_SERVICE_ACCOUNT}@${master_ip}:${KUBERNETES_CERTIFICATE_PATH}
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kubectl.kubeconfig ${master_ip}:/root/.kube/config
done

cp ${TEMP_WORK_DIR}/kubectl-admin*.pem ${JOIN_CLUSTER_DIR}
cp ${TEMP_WORK_DIR}/kubectl.kubeconfig ${JOIN_CLUSTER_DIR}

