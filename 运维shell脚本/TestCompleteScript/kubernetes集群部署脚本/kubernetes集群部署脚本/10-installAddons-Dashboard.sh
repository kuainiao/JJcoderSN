#!/bin/bash
# 在k8s集群的master上执行

source ./environment.sh

KUBERNETES_SERVER_VERSION=v1.13.4

cd ${TEMP_WORK_DIR}
echo -e "\033[32m[Task]\033[0m 检查当前目录是否有该${KUBERNETES_SERVER_VERSION}版本的二进制包。"
if [[ -e kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz ]]; then
  echo "  >>> 当前目录存在kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz"
else
  echo "  >>> 当前目录不存在kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz即将下载"
  wget https://dl.k8s.io/${KUBERNETES_SERVER_VERSION}/kubernetes-server-linux-amd64.tar.gz -O kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz
fi
tar -xzf kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz


echo -e "\033[32m[Task]\033[0m 为集群部署Dashboard插件"
cd ${TEMP_WORK_DIR}/kubernetes/cluster/addons/dashboard
cat dashboard-service.yaml | grep "type: NodePort" || echo "  type: NodePort" >> dashboard-service.yaml


echo "  >>> 拷贝Dashboard POD配置清单文件"
mkdir ${KUBERNETES_SERVER_HOME}/addons/dashboard
cp ./*.yaml ${KUBERNETES_SERVER_HOME}/addons/dashboard
echo "  >>> 创建Dashboard POD。"
cd ${KUBERNETES_SERVER_HOME}/addons/dashboard
${KUBERNETES_SERVER_HOME}/bin/kubectl apply -f .


cd ${TEMP_WORK_DIR}
echo "  >>> 创建登陆kubeconfig文件"
${KUBERNETES_SERVER_HOME}/bin/kubectl create sa dashboard-admin -n kube-system
${KUBERNETES_SERVER_HOME}/bin/kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
if [[ -e dashboard_admin_secret.config ]]; then
  export DASHBOARD_LOGIN_TOKEN=$(cat dashboard_admin_secret.config)
else
  touch dashboard_admin_secret.config
  export ADMIN_SECRET=$(${KUBERNETES_SERVER_HOME}/bin/kubectl get secrets -n kube-system | grep dashboard-admin | awk '{print $1}')
  echo  $(${KUBERNETES_SERVER_HOME}/bin/kubectl describe secret -n kube-system ${ADMIN_SECRET} | grep -E '^token' | awk '{print $2}') > dashboard_admin_secret.config
  export DASHBOARD_LOGIN_TOKEN=$(cat dashboard_admin_secret.config)
fi

# 设置集群参数
${KUBERNETES_SERVER_HOME}/bin/kubectl config set-cluster kubernetes \
  --certificate-authority=${TEMP_WORK_DIR}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=dashboard.kubeconfig

# 设置客户端认证参数，使用上面创建的 Token
${KUBERNETES_SERVER_HOME}/bin/kubectl config set-credentials dashboard_user \
  --token=${DASHBOARD_LOGIN_TOKEN} \
  --kubeconfig=dashboard.kubeconfig

# 设置上下文参数
${KUBERNETES_SERVER_HOME}/bin/kubectl config set-context default \
  --cluster=kubernetes \
  --user=dashboard_user \
  --kubeconfig=dashboard.kubeconfig

# 设置默认上下文
${KUBERNETES_SERVER_HOME}/bin/kubectl config use-context default --kubeconfig=dashboard.kubeconfig

echo "请保管好用于登陆Dashboard的dashboard.kubeconfig"

