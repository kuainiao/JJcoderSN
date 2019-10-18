#!/bin/bash
#
# 在集群的master主机上安装k8s的server组件，包括kube-apiserver, kube-scheduler, kube-controller-manager
# 以3台为例，这3个节点将通过宣传产生一个leader来提供三种服务，其他都是阻塞状态，当leader不可用的时候其余节点
# 再进行选举产生新的leader。

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
cat << EOF > kubernetes_server_cmdenv.sh
#!/bin/bash
export K8S_SERVER_HOME=${KUBERNETES_SERVER_HOME}
export PATH=\${K8S_SERVER_HOME}/bin:\$PATH
EOF


echo -e "\033[32m[Task]\033[0m 创建kube-apiserver证书和私钥。"
# 创建k8s相关证书
# 创建apiserver服务器证书和私钥，下面的域名替换成你环境的IP以及域名等
# 如果 hosts 字段不为空则需要指定授权使用该证书的 IP 或域名列表，由于该证书后续被 etcd 集群和 kubernetes master 集群
# 使用，所以上面分别指定了 etcd 集群、 kubernetes master 集群的主机 IP 和 kubernetes 服务的服务 IP
# （一般是 kube-apiserver 指定的 service-cluster-ip-range 网段的第一个IP，如 10.254.0.1
cat << EOF > kubernetes-csr.json
{
    "CN": "kubernetes",
    "hosts": [
      "${CLUSTER_KUBERNETES_SVC_IP}",
      "127.0.0.1",
      "192.168.10.10",
      "192.168.10.20",
      "192.168.10.30",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local",
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
            "ST": "Beijing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
# 会产生 kubernetes.pem  kubernetes-key.pem
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

echo -e "\033[32m[Task]\033[0m 创建kube-controller-manager证书和私钥。"
# hosts 列表包含所有 kube-controller-manager 节点 IP
# kube-controller-manager在与api-server的安全端口通信是会使用证书，当然它与api-server安装在一起使用127.0.0.1来通信也可以不用为kube-controller-manager创建证书
# CN 为 system:kube-controller-manager, O 为 system:kube-controller-manager
# kubernetes 内置的 ClusterRoleBindings system:kube-controller-manager 赋予 kube-controller-manager 工作所需的权限
cat << EOF > kube-controller-manager-csr.json
{
    "CN": "system:kube-controller-manager",
    "hosts": [
      "10.254.0.1",
      "127.0.0.1",
      "192.168.10.10",
      "192.168.10.20",
      "192.168.10.30",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local",
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
            "ST": "Beijing",
            "O": "system:kube-controller-manager",
            "OU": "System"
        }
    ]
}
EOF
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

echo -e "\033[32m[Task]\033[0m 创建kube-scheduler证书和私钥。"
# kube-scheduler在与api-server的安全端口通信是会使用证书，当然它与api-server安装在一起使用127.0.0.1来通信也可以不用为kube-scheduler创建证书
cat > kube-scheduler-csr.json <<EOF
{
    "CN": "system:kube-scheduler",
    "hosts": [
      "10.254.0.1",
      "127.0.0.1",
      "192.168.10.10",
      "192.168.10.20",
      "192.168.10.30",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local",
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
            "ST": "Beijing",
            "O": "system:kube-scheduler",
            "OU": "System"
        }
    ]
}
EOF
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-scheduler-csr.json | cfssljson -bare kube-scheduler

echo -e "\033[32m[Task]\033[0m 创建metrics-server使用的证书和私钥。"
cat > metrics-server-csr.json <<EOF
{
  "CN": "metrics-server",
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
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-scheduler-csr.json | cfssljson -bare metrics-server



# 创建加密配置文件，这个就是为了让APISERVER在ETCD中存储数据时对数据进行加密然后存放
# 在网上看到的 kind是EncryptionConfig  apiVersion是apiVersion: v1  这种用法是1.13之前的alpha版本使用的，我们这里使用的是1.13.4所以使用的是新的写法
echo -e "\033[32m[Task]\033[0m 创建加密配置文件。"
if [[ -e encryption_key_file.config ]]; then
  export ENCRYPTION_KEY=$(cat encryption_key_file.config)
else
  touch encryption_key_file.config
  echo $(head -c 32 /dev/urandom | base64) > encryption_key_file.config
  export ENCRYPTION_KEY=$(cat encryption_key_file.config)
fi
cat > encryption-config.yaml <<EOF
kind: EncryptionConfiguration
apiVersion: apiserver.config.k8s.io/v1
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: ${ENCRYPTION_KEY}
    - identity: {}
EOF


echo -e "\033[32m[Task]\033[0m 创建kube-api-server服务模板文件。"
# --anonymous-auth 允许匿名访问
# --encryption-provider-config 指定apiserver在ETCD中存储密码信息的时候使用加密存放，这个文件就是加密使用的秘钥
# --advertise-address 广播到集群其他成员用的地址，该地址必须是网络可达的。如果为空则使用--bind-address设置
# --bind-address 设置apiserver监听地址，默认0.0.0.0，且仅使用--secure-port指定的端口监听
# --secure-port 安全端口，默认是6433
# --authorization-mode 开启Node和RABC授权默认也就是强制RABC访问
# --runtime-config 启用所有版本的 APIs
# --service-cluster-ip-range 设置集群service的IP网段，默认10.0.0.0/24，所以需要设置成你需要的。
# --service-node-port-range service使用NODEPORT模式使用的本机端口范围，默认30000-32767
# --tls-cert-file 指定kube-apiserver证书文件，这个是apiserver服务器的证书文件
# --tls-private-key-file 指定kube-apiserver私钥文件，这个是apiserver服务器的私钥文件
# --client-ca-file 指定CA根证书文件，所有客户端请求都使用这个CA证书进行签署，所有客户端证书都由这个CA签发，所以这就是
#                  说客户端的CA和api server的CA可以不一样，当然也可以一样。
# --kubelet-client-certificate  --kubelet-client-key 如果指定，则使用 https 访问 kubelet APIs；
#                                                    需要为证书对应的用户(上面 kubernetes*.pem 证书的用户为 kubernetes) 
#                                                    用户定义 RBAC 规则，否则访问 kubelet API 时提示未授权
# --service-account-key-file 签名 ServiceAccount Token 的公钥文件，kube-controller-manager 的 -
#                            -service-account-private-key-file 指定私钥文件，两者配对使用

# --etcd-cafile apiserver连接etcd使用的CA根证书
# --etcd-certfile apiserver连接etcd使用的服务器证书文件
# --etcd-keyfile apiserver连接etcd使用的私钥文件
# --etcd-servers 设置ETCD集群地址
# --enable-swagger-ui 启用swagger ui，通过浏览器访问api sverver安全端口的地址加上/swagger-ui
# --allow-privileged 是否允许特权容器，默认是false
# --apiserver-count 集群中api server的数量，默认是1。多台 kube-apiserver 会通过 leader 选举产生一个工作节点，其它节点处于阻塞状态.
# --audit-log-maxage 审计日志保留天数
# --audit-log-maxbackup 要保留的审计日志数量
# 
# apiserver虽然我们设置了安全连接，但是它还会有一个127.0.0.1:8080的非安全连接可以使用不过通过IP我们能看出来仅能本地使用，所以
# controller-manager和scheduler如果和apiserver安装在一台主机上那么就可以通过这个本地非安全连接通信且这两者也不需要证书。
# 
# 下面的参数是为了让metrics-server可以连接到APIserver用的
# --requestheader-XXX、--proxy-client-XXX 是 kube-apiserver 的 aggregator layer 相关的配置参数，metrics-server & HPA 需要使用
# --requestheader-client-ca-file：用于签名 --proxy-client-cert-file 和 --proxy-client-key-file 指定的证书；在启用了 metric aggregator 时使用
# --requestheader-allowed-names这个参数不要设置，不设置表示任何由--requestheader-client-ca-file证书签发的客户端证书都可以连接。
# --enable-aggregator-routing=true 如果apiserver上没有运行kube-proxy组件，则需要添加该选项，表示启用aggregator路由请求到endpoind IP而不是集群IP
# 
# 我这里没有指定tocke文件，原因在7中再说
cat > kube-apiserver.service.template <<EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
ExecStart=${KUBERNETES_SERVER_HOME}/bin/kube-apiserver \\
  --enable-admission-plugins=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --anonymous-auth=false \\
  --encryption-provider-config=${KUBERNETES_SERVER_HOME}/cfg/encryption-config.yaml \\
  --advertise-address=##MASTER_IP## \\
  --bind-address=##MASTER_IP## \\
  --secure-port=6433 \\
  --authorization-mode=Node,RBAC \\
  --runtime-config=api/all \\
  --enable-bootstrap-token-auth \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --service-node-port-range=${NODE_PORT_RANGE} \\
  --tls-cert-file=${KUBERNETES_CERTIFICATE_PATH}/kubernetes.pem \\
  --tls-private-key-file=${KUBERNETES_CERTIFICATE_PATH}/kubernetes-key.pem \\
  --client-ca-file=${KUBERNETES_CERTIFICATE_PATH}/ca.pem \\
  --kubelet-client-certificate=${KUBERNETES_CERTIFICATE_PATH}/kubernetes.pem \\
  --kubelet-client-key=${KUBERNETES_CERTIFICATE_PATH}/kubernetes-key.pem \\
  --service-account-key-file=${KUBERNETES_CERTIFICATE_PATH}/ca-key.pem \\
  --etcd-cafile=${KUBERNETES_CERTIFICATE_PATH}/ca.pem \\
  --etcd-certfile=${KUBERNETES_CERTIFICATE_PATH}/kubernetes.pem \\
  --etcd-keyfile=${KUBERNETES_CERTIFICATE_PATH}/kubernetes-key.pem \\
  --etcd-servers=${ETCD_ENDPOINTS} \\
  --enable-swagger-ui=true \\
  --allow-privileged=true \\
  --apiserver-count=${APISERVER_COUNT} \\
  --requestheader-client-ca-file=${KUBERNETES_CERTIFICATE_PATH}/ca.pem \\
  --requestheader-extra-headers-prefix=X-Remote-Extra- \\
  --requestheader-group-headers=X-Remote-Group \\
  --requestheader-username-headers=X-Remote-User \\
  --proxy-client-cert-file=${KUBERNETES_CERTIFICATE_PATH}/metrics-server.pem \\
  --proxy-client-key-file=${KUBERNETES_CERTIFICATE_PATH}/metrics-server-key.pem \\
  --runtime-config=api/all=true \\
  --enable-aggregator-routing=true \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/kube-apiserver-audit.log \\
  --event-ttl=1h \\
  --alsologtostderr=true \\
  --logtostderr=false \\
  --log-dir=${KUBERNETES_LOGS_DIR} \\
  --v=2
Restart=on-failure
RestartSec=5
Type=notify
User=${K8S_SERVICE_ACCOUNT}
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# 替换变量
for (( i=0; i<${#MASTER_IPS[*]}; i++ )); do
  sed -e "s/##MASTER_IP##/${MASTER_IPS[i]}/" kube-apiserver.service.template > kube-apiserver-${MASTER_IPS[i]}.service
done


echo -e "\033[32m[Task]\033[0m 创建kube-controller-manager使用的kubeconfig服务模板文件。"
# 设置集群参数
# --embed-certs=true 是把证书文件嵌入到kubeconfig文件中，如果不加那么引用证书的时候写入的是证书路径，所以我们这里用当前目录就可以。
# --kubeconfig=指定kubeconfig文件位置
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-cluster kubernetes \
  --certificate-authority=${TEMP_WORK_DIR}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-controller-manager.kubeconfig
# 设置客户端认证参数
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=${TEMP_WORK_DIR}/kube-controller-manager.pem \
  --client-key=${TEMP_WORK_DIR}/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig
# 设置上下文参数
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-context system:kube-controller-manager \
  --cluster=kubernetes \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig
# 设置默认上下文
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config use-context system:kube-controller-manager --kubeconfig=kube-controller-manager.kubeconfig

echo -e "\033[32m[Task]\033[0m 创建kube-controller-manager服务文件。"
# --master 这个值是指定api server的监听端口和IP，因为在之前的kubeconfig中已经设置了，所以这个参数就不用设置，
#          如果你设置--master那么就会覆盖kubeconfig中的设置。如果我们不使用上面的kubeconfig那么下面就需要指定
#          该参数，可以使用非安全端口连接(127.0.0.1:8080)apiserver，也可以使用安全端口6433来连接。
# --secure-port 安全端口，--bind-address指定的IP地址就监听在这个端口，如果设置为0则不使用https
# --bind-address 监听地址，默认0.0.0.0。它用来监听https /metrics 请求，当然也可以是http的metrics请求。由于我们把controller和apiserver装在
#                一台机器上所以监听127.0.0.1就可以。如果要接收https的metrics请求就需要配置--tls-cert-file 和 --tls-private-key-file
# --service-cluster-ip-range service使用的IP，必须和API SERVER中的配置一样
# --experimental-cluster-signing-duration 指定 TLS Bootstrap 证书的有效期，这个就是kubelet使用的，而且它的证书是由controller manager签发的。
# --service-account-private-key-file 签名 ServiceAccount 中 Token 的私钥文件，必须和 kube-apiserver 的 --service-account-key-file 指定的公钥文件配对使用
# --leader-elect 集群运行模式，启用选举功能；被选为 leader 的节点负责处理工作，其它节点为阻塞状态，默认就是true
# --feature-gates=RotateKubeletServerCertificate=true 开启 kubletet server 证书的自动更新特性，默认就是true
# --tls-cert-file 和 --tls-private-key-file 这使用 https 输出 metrics 时使用的 Server 证书和秘钥 两个如果没有设置则会产生自签名证书，并且保存到--cert-dir目录中。
#                                           如果不打算使用https输出metrics那么就可以不为manager配置证书
# --use-service-account-credentials 如果设置true那么每一个controller使用单独的服务账号。为什么这样呢？
#                                   ClusteRole: system:kube-controller-manager 的权限很小，只能创建 secret、serviceaccount 等资源对象，
#                                   各 controller 的权限分散到 ClusterRole system:controller:XXX 中。需要在 kube-controller-manager 
#                                   的启动参数中添加 --use-service-account-credentials=true 参数，这样 main controller 会为各 controller 
#                                   建对应的 ServiceAccount XXX-controller。内置的 ClusterRoleBinding system:controller:XXX 
#                                   将赋予各 XXX-controller ServiceAccount 对应的 ClusterRole system:controller:XXX 权限
#                                   
# --horizontal-pod-autoscaler-use-rest-clients=true 用于配置HPA控制器使用REST客户端获取metrics数据
#                                   
# 启动后它还有一个非安全端口工作在10252上，--address=127.0.0.1 是为了让10252只工作在这个IP上。
cat > kube-controller-manager.service <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=${KUBERNETES_SERVER_HOME}/bin/kube-controller-manager \\
  --address=127.0.0.1 \\
  --secure-port=10257 \\
  --bind-address=0.0.0.0 \\
  --kubeconfig=${KUBERNETES_SERVER_HOME}/cfg/kube-controller-manager.kubeconfig \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=${KUBERNETES_CERTIFICATE_PATH}/ca.pem \\
  --cluster-signing-key-file=${KUBERNETES_CERTIFICATE_PATH}/ca-key.pem \\
  --experimental-cluster-signing-duration=87600h \\
  --root-ca-file=${KUBERNETES_CERTIFICATE_PATH}/ca.pem \\
  --service-account-private-key-file=${KUBERNETES_CERTIFICATE_PATH}/ca-key.pem \\
  --leader-elect=true \\
  --horizontal-pod-autoscaler-use-rest-clients=true \\
  --feature-gates=RotateKubeletServerCertificate=true \\
  --tls-cert-file=${KUBERNETES_CERTIFICATE_PATH}/kube-controller-manager.pem \\
  --tls-private-key-file=${KUBERNETES_CERTIFICATE_PATH}/kube-controller-manager-key.pem \\
  --use-service-account-credentials=true \\
  --alsologtostderr=true \\
  --logtostderr=false \\
  --log-dir=${KUBERNETES_LOGS_DIR} \\
  --v=2
Restart=on
Restart=on-failure
RestartSec=5
User=${K8S_SERVICE_ACCOUNT}

[Install]
WantedBy=multi-user.target
EOF


echo -e "\033[32m[Task]\033[0m 创建kube-scheduler使用的kubeconfig服务模板文件。"
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-cluster kubernetes \
  --certificate-authority=${TEMP_WORK_DIR}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-scheduler.kubeconfig
# 设置客户端认证参数
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-credentials system:kube-scheduler \
  --client-certificate=${TEMP_WORK_DIR}/kube-scheduler.pem \
  --client-key=${TEMP_WORK_DIR}/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig
# 设置上下文参数
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config set-context system:kube-scheduler \
  --cluster=kubernetes \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig
# 设置默认上下文
${TEMP_WORK_DIR}/kubernetes/client/bin/kubectl config use-context system:kube-scheduler --kubeconfig=kube-scheduler.kubeconfig

echo -e "\033[32m[Task]\033[0m 创建kube-scheduler服务文件。"
# 在1.13.1版本时kube-scheduler还不支持接收https的/metrics请求，不过1.13.4版本已经可以使用了。在1.13.3版本中没有 --secure-port选项只有--port默认是10251
# 当然--secure-port设置为0则不启用https。我们这里还是配置接收https的请求。
# 
# 在当前版本中启动之后还会有一个 0.0.0.0:10251的非安全端口，它是由--address和--port来指定的，但是已经弃用。
# --address=127.0.0.1 是为了让10252只工作在这个IP上。
cat > kube-scheduler.service <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=${KUBERNETES_SERVER_HOME}/bin/kube-scheduler \\
  --address=127.0.0.1 \\
  --bind-address=0.0.0.0 \\
  --secure-port=10259 \\
  --kubeconfig=${KUBERNETES_SERVER_HOME}/cfg/kube-scheduler.kubeconfig \\
  --tls-cert-file=${KUBERNETES_CERTIFICATE_PATH}/kube-scheduler.pem \\
  --tls-private-key-file=${KUBERNETES_CERTIFICATE_PATH}/kube-scheduler-key.pem \\
  --client-ca-file=${KUBERNETES_CERTIFICATE_PATH}/ca.pem \\
  --leader-elect=true \\
  --alsologtostderr=true \\
  --logtostderr=false \\
  --log-dir=${KUBERNETES_LOGS_DIR} \\
  --v=2
Restart=on-failure
RestartSec=5
User=${K8S_SERVICE_ACCOUNT}

[Install]
WantedBy=multi-user.target
EOF


echo -e "\033[32m[Task]\033[0m 生成自动批准Kubelet的CSR请求配置清单。"
# 这里为什么要多建立一个clusterrole呢？因为selfnodeclient和nodeclient的clusterrole已经内置了，所以需要单独建立一个selfnodeserver的角色
# 可以通过kubectl get clusterrole命令查看，然后通过建立clusterrolebinding来做角色到用户或者组的绑定。
cat > csr-auto-approve.yaml <<EOF
 # 自动批准 system:bootstrappers 组用户 TLS bootstrapping 首次申请证书的 CSR 请求
 # 绑定组system:bootstrappers到system:certificates.k8s.io:certificatesigningrequests:nodeclient角色
 # 对应命令 kubectl create clusterrolebinding node-client-auto-approve-csr --clusterrole=system:certificates.k8s.io:certificatesigningrequests:nodeclient --group=system:bootstrappers
 kind: ClusterRoleBinding
 apiVersion: rbac.authorization.k8s.io/v1
 metadata:
   name: node-client-auto-approve-csr
 subjects:
 - kind: Group
   name: system:bootstrappers
   apiGroup: rbac.authorization.k8s.io
 roleRef:
   kind: ClusterRole
   name: system:certificates.k8s.io:certificatesigningrequests:nodeclient
   apiGroup: rbac.authorization.k8s.io
---
 # 自动批准 system:nodes 组用户更新 kubelet 自身与 apiserver 通讯证书的 CSR 请求
 # 对应命令 kubectl create clusterrolebinding node-client-auto-renew-crt --clusterrole=system:certificates.k8s.io:certificatesigningrequests:selfnodeclient --group=system:nodes
 kind: ClusterRoleBinding
 apiVersion: rbac.authorization.k8s.io/v1
 metadata:
   name: node-client-auto-cert-renewal
 subjects:
 - kind: Group
   name: system:nodes
   apiGroup: rbac.authorization.k8s.io
 roleRef:
   kind: ClusterRole
   name: system:certificates.k8s.io:certificatesigningrequests:selfnodeclient
   apiGroup: rbac.authorization.k8s.io
---
# 创建角色 system:certificates.k8s.io:certificatesigningrequests:selfnodeserver
# 前2个角色系统自动创建，而这个没有，则需要手动创建
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: system:certificates.k8s.io:certificatesigningrequests:selfnodeserver
rules:
- apiGroups: ["certificates.k8s.io"]
  resources: ["certificatesigningrequests/selfnodeserver"]
  verbs: ["create"]
---
 # 自动批准 system:nodes 组用户更新 kubelet 10250 api 端口证书的 CSR 请求
 # 对应命令 kubectl create clusterrolebinding node-server-auto-renew-crt --clusterrole=system:certificates.k8s.io:certificatesigningrequests:selfnodeserver --group=system:nodes
 kind: ClusterRoleBinding
 apiVersion: rbac.authorization.k8s.io/v1
 metadata:
   name: node-server-auto-cert-renewal
 subjects:
 - kind: Group
   name: system:nodes
   apiGroup: rbac.authorization.k8s.io
 roleRef:
   kind: ClusterRole
   name: system:certificates.k8s.io:certificatesigningrequests:selfnodeserver
   apiGroup: rbac.authorization.k8s.io
---
# 授权kubelet第一次使用token连接api server时使用的账号具有system:node-bootstrapper角色权限，因为该账号要创建CSR请求，不授权的话虽然可以通过认证但是没有任何权限。
# 对应命令 kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --group=system:bootstrappers
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubelet-bootstrap
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:node-bootstrapper
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:bootstrappers
EOF

echo -e "\033[32m[Task]\033[0m 生成授予kubernetes证书访问kubeletAPI的权限配置清单。"
# 在执行 kubectl exec、run、logs 等命令时，apiserver 会转发到 kubelet。这里定义 RBAC 规则，授权 apiserver 调用 kubelet API
# 如果不做授权当你使用logs命令会收到 Error from server (Forbidden): Forbidden (user=kubernetes, verb=get, resource=nodes, subresource=proxy) ( pods/log grafana-7484c6f69-88p6f)
# 这样的提示，user=kubernetes 这个用于就是apiserver使用证书的那个CN名称，kubectl命令会发起对apiserver的请求，apiserver会转发到kubelet api上。
# 等效命令 $ kubectl create clusterrolebinding kube-apiserver:kubelet-apis --clusterrole=system:kubelet-api-admin --user kubernetes
cat > authorize-apiserver-call-kubeleteapi.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kube-apiserver:kubelet-apis
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kubelet-api-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: kubernetes
EOF


echo -e "\033[32m[Task]\033[0m 拷贝Master节点角色所需文件。"
for master_ip in ${MASTER_IPS[@]}; do
  echo "执行到 ${master_ip} master节点的拷贝."
  if [[ ${master_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
  	echo "  >>> 拷贝二进制程序"
    cp ${TEMP_WORK_DIR}/kubernetes/server/bin/* ${KUBERNETES_SERVER_HOME}/bin
    echo "  >>> 拷贝组件使用的证书和私钥"
    cp ${TEMP_WORK_DIR}/kubernetes.pem kubernetes-key.pem kube-controller-manager.pem kube-controller-manager-key.pem kube-scheduler.pem kube-scheduler-key.pem metrics-server.pem metrics-server-key.pem ${KUBERNETES_CERTIFICATE_PATH}
    echo "  >>> 拷贝加密配置文件"
    cp ${TEMP_WORK_DIR}/encryption-config.yaml ${KUBERNETES_SERVER_HOME}/cfg
    echo "  >>> 拷贝api server服务启动文件"
    cp ${TEMP_WORK_DIR}/kube-apiserver-${master_ip}.service /usr/lib/systemd/system/kube-apiserver.service

    echo "  >>> 拷贝kube-controller-manager.kubeconfig文件"
    cp ${TEMP_WORK_DIR}/kube-controller-manager.kubeconfig ${KUBERNETES_SERVER_HOME}/cfg
    echo "  >>> 拷贝kube-controller-manager服务启动文件"
    cp ${TEMP_WORK_DIR}/kube-controller-manager.service /usr/lib/systemd/system/kube-controller-manager.service
    
    echo "  >>> 拷贝kube-scheduler.kubeconfig"
    cp ${TEMP_WORK_DIR}/kube-scheduler.kubeconfig ${KUBERNETES_SERVER_HOME}/cfg
    echo "  >>> 拷贝kube-scheduler服务启动文件"
    cp ${TEMP_WORK_DIR}/kube-scheduler.service /usr/lib/systemd/system/kube-scheduler.service
    echo "  >>> 拷贝开启csr auto approve清单"
    cp ${TEMP_WORK_DIR}/csr-auto-approve.yaml ${KUBERNETES_SERVER_HOME}/cfg
    echo "  >>> 授予kubernetes证书访问kubeletAPI的权限配置清单"
    cp ${TEMP_WORK_DIR}/authorize-apiserver-call-kubeleteapi.yaml ${KUBERNETES_SERVER_HOME}/cfg
    
    cp ${TEMP_WORK_DIR}/kubernetes_server_cmdenv.sh /etc/profile.d/kubernetes_server_cmdenv.sh && source /etc/profile.d/kubernetes_server_cmdenv.sh
    continue
  fi
  echo "  >>> 拷贝二进制程序."
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kubernetes/server/bin/* ${K8S_SERVICE_ACCOUNT}@${master_ip}:${KUBERNETES_SERVER_HOME}/bin
  echo "  >>> 拷贝组件使用的证书和私钥"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kubernetes.pem kubernetes-key.pem kube-controller-manager.pem kube-controller-manager-key.pem kube-scheduler.pem kube-scheduler-key.pem metrics-server.pem metrics-server-key.pem ${K8S_SERVICE_ACCOUNT}@${master_ip}:${KUBERNETES_CERTIFICATE_PATH}
  echo "  >>> 拷贝加密配置文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/encryption-config.yaml ${K8S_SERVICE_ACCOUNT}@${master_ip}:${KUBERNETES_SERVER_HOME}/cfg
  echo "  >>> 拷贝api server服务启动文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kube-apiserver-${master_ip}.service ${K8S_SERVICE_ACCOUNT}@${master_ip}:/usr/lib/systemd/system/kube-apiserver.service
  echo "  >>> 拷贝kube-controller-manager.kubeconfig文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kube-controller-manager.kubeconfig ${K8S_SERVICE_ACCOUNT}@${master_ip}:${KUBERNETES_SERVER_HOME}/cfg
  echo "  >>> 拷贝kube-controller-manager服务启动文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kube-controller-manager.service ${K8S_SERVICE_ACCOUNT}@${master_ip}:/usr/lib/systemd/system/kube-controller-manager.service

  echo "  >>> 拷贝kube-scheduler.kubeconfig文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kube-scheduler.kubeconfig ${K8S_SERVICE_ACCOUNT}@${master_ip}:${KUBERNETES_SERVER_HOME}/cfg
  echo "  >>> 拷贝kube-scheduler服务启动文件"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kube-scheduler.service ${K8S_SERVICE_ACCOUNT}@${master_ip}:/usr/lib/systemd/system/kube-scheduler.service
  echo "  >>> 拷贝开启csr auto approve清单"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/csr-auto-approve.yaml ${K8S_SERVICE_ACCOUNT}@${master_ip}:${KUBERNETES_SERVER_HOME}/cfg
  echo "  >>> 授予kubernetes证书访问kubeletAPI的权限配置清单"
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/authorize-apiserver-call-kubeleteapi.yaml ${K8S_SERVICE_ACCOUNT}@${master_ip}:${KUBERNETES_SERVER_HOME}/cfg

  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/kubernetes_server_cmdenv.sh ${K8S_SERVICE_ACCOUNT}@${master_ip}:/etc/profile.d/kubernetes_server_cmdenv.sh
done


echo -e "\033[32m[Task]\033[0m 启动Master节点角色。"
for master_ip in ${MASTER_IPS[@]}; do
  echo "启动 ${master_ip} master节点的角色."
  if [[ ${master_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
  	systemctl daemon-reload
  	systemctl enable kube-apiserver && systemctl start kube-apiserver
    systemctl enable kube-controller-manager && systemctl start kube-controller-manager
    systemctl enable kube-scheduler && systemctl start kube-scheduler
  	continue
  fi
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${master_ip} "systemctl daemon-reload && systemctl enable kube-apiserver && systemctl start kube-apiserver"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${master_ip} "systemctl enable kube-controller-manager && systemctl start kube-controller-manager"
  ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${master_ip} "systemctl enable kube-scheduler && systemctl start kube-scheduler"
done


echo -e "\033[32m[Task]\033[0m 开启CSR自动批准。"
echo "${MASTER_IPS[@]}" | grep -wq "${EXEC_SCRIPT_HOST_IP}" && RESULT="YES" || RESULT="NO"
if [[ $RESULT == "YES" ]]; then
  ${KUBERNETES_SERVER_HOME}/bin/kubectl apply -f ${KUBERNETES_SERVER_HOME}/cfg/csr-auto-approve.yaml
  ${KUBERNETES_SERVER_HOME}/bin/kubectl apply -f ${KUBERNETES_SERVER_HOME}/cfg/authorize-apiserver-call-kubeleteapi.yaml
else
  for master_ip in ${MASTER_IPS[@]}; do
    ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${master_ip} "${KUBERNETES_SERVER_HOME}/bin/kubectl apply -f ${KUBERNETES_SERVER_HOME}/cfg/csr-auto-approve.yaml"
    ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${master_ip} "${KUBERNETES_SERVER_HOME}/bin/kubectl apply -f ${KUBERNETES_SERVER_HOME}/cfg/authorize-apiserver-call-kubeleteapi.yaml"
    break
  done
fi


echo -e "\033[32m[Task]\033[0m 检查集群状态。"
echo "${MASTER_IPS[@]}" | grep -wq "${EXEC_SCRIPT_HOST_IP}" && RESULT="YES" || RESULT="NO"
if [[ $RESULT == "YES" ]]; then
  ${KUBERNETES_SERVER_HOME}/bin/kubectl cluster-info
  ${KUBERNETES_SERVER_HOME}/bin/kubectl get componentstatuses
else
  for master_ip in ${MASTER_IPS[@]}; do
    ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${master_ip} "${KUBERNETES_SERVER_HOME}/bin/kubectl cluster-info"
    ssh -o StrictHostKeyChecking=no ${K8S_SERVICE_ACCOUNT}@${master_ip} "${KUBERNETES_SERVER_HOME}/bin/kubectl get componentstatuses"
    break
  done
fi

echo "使用下面的命令在etcd上查看Kabernetes在ETCD节点写入的数据。"
# 这里使用的 ETCDCTL_API=3 是让etcdctl使用v3版本的命令，因为k8s集群使用的就是v3版本的，默认etcdctl使用的是v2版本的，两个版本不能互通数据访问。
echo "ETCDCTL_API=3 etcdctl --endpoints=${ETCD_ENDPOINTS} --cacert=${ETCD_CERTIFICATE_PATH}/ca.pem \--cert=${ETCD_CERTIFICATE_PATH}/etcdsrv.pem --key=${ETCD_CERTIFICATE_PATH}/etcdsrv-key.pem get /registry/ --prefix --keys-only"


# kubectl get componentstatuses
# NAME                 STATUS      MESSAGE                                                                                        ERROR
# controller-manager   Unhealthy   Get http://127.0.0.1:10252/healthz: dial tcp 127.0.0.1:10252: getsockopt: connection refused
# scheduler            Unhealthy   Get http://127.0.0.1:10251/healthz: dial tcp 127.0.0.1:10251: getsockopt: connection refused
# etcd-1               Healthy     {"health":"true"}
# etcd-0               Healthy     {"health":"true"}
# etcd-2               Healthy     {"health":"true"}
# 
# 上面的命令默认是向127.0.0.1的非安全端口发请求，所以如果你有3台master那么由于这个命令对于controller-manager和scheduler的状态监测是连接本地所以可能你获取的是上面的结果
# 但是实际上是没有问题的，因为在3台集群环境中由于只有一个是Leader，其他都是阻塞状态所以你本地的这个controller-manager和scheduler因为选举原因当前正好处于阻塞状态。
# 通常在3台的环境中会使用VPI来映射apiserver的三台从而实现HA，其实对于controller-manager和scheduler也可以这么做。


# 查看leader在哪里
# kubectl get endpoints kube-controller-manager --namespace=kube-system  -o yaml
# kubectl get endpoints kube-scheduler --namespace=kube-system  -o yaml

# 查看是否正常
# curl -s --cacert /work/apps/kubernetes/ssl/ca.pem https://IP:10259/healthz    测试kube-schedule
# curl -s --cacert /work/apps/kubernetes/ssl/ca.pem https://IP:10257/healthz    测试kube-controll



