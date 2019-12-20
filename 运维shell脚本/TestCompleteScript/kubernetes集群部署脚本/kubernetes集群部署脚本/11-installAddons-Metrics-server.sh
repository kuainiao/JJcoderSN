#!/bin/bash
# 在Master上执行

# Metrics-server需要和各个节点通信因为它是集群的聚合器，默认情况下ApiServer没有提供metrics-server的API接口，我们部署Metrics-Server
# 就等于为ApiServer添加了metrics的API，路径是/apis/metrics.k8s.io，这就意味着我们需要通过API SERVER访问，如果我们把Metrics-server部署
# 为POD的形式，你必须保证Api server到Metrics-server这个POD的IP是通的。
# 不过这个组件使用场景大多数使用kubectl top 命令，Prometheus监控并不收集metrics-server的指标，当然它可以监控metrics-server这个POD的状态。
# 
# metrics-server是一个受Heapster启发的项目也是它的替代品，用于实现Kubernetes监控管道的目标。 它是一个集群级别组件，
# 通过Summary API定期从Kubelet服务的所有Kubernetes节点中抓取指标。 
# 指标汇总，存储在内存中，并以Metrics API格式提供。 度量服务器仅存储最新值，不负责将度量标准转发到第三方目标，它的主要作用是实现HPA。

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


cd ${TEMP_WORK_DIR}/kubernetes/cluster/addons/metrics-server

cp metrics-server-deployment.yaml metrics-server-deployment.bak
# metrics-server默认使用node的主机名，但是coredns里面没有物理机主机名的解析，一种是部署的时候添加一个参数
# - --kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP
# - --kubelet-insecure-tls 不验证客户端证书
cat > metrics-server-deployment.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: metrics-server-config
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: EnsureExists
data:
  NannyConfiguration: |-
    apiVersion: nannyconfig/v1alpha1
    kind: NannyConfiguration
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: metrics-server-v0.3.1
  namespace: kube-system
  labels:
    k8s-app: metrics-server
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    version: v0.3.1
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
      version: v0.3.1
  template:
    metadata:
      name: metrics-server
      labels:
        k8s-app: metrics-server
        version: v0.3.1
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
        seccomp.security.alpha.kubernetes.io/pod: 'docker/default'
    spec:
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      containers:
      - name: metrics-server
        image: k8s.gcr.io/metrics-server-amd64:v0.3.1
        imagePullPolicy: IfNotPresent
        command:
        - /metrics-server
        - --metric-resolution=30s
        - --kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP
        - --kubelet-insecure-tls
        # - --kubelet-port=10255
        # - --deprecated-kubelet-completely-insecure=true
        ports:
        - containerPort: 443
          name: https
          protocol: TCP
      - name: metrics-server-nanny
        image: k8s.gcr.io/addon-resizer:1.8.4
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            cpu: 100m
            memory: 300Mi
          requests:
            cpu: 5m
            memory: 50Mi
        env:
          - name: MY_POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: MY_POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
        volumeMounts:
        - name: metrics-server-config-volume
          mountPath: /etc/config
        command:
          - /pod_nanny
          - --config-dir=/etc/config
          - --cpu=100m
          - --extra-cpu=0.5m
          - --memory=100Mi
          - --extra-memory=8Mi
          - --threshold=5
          - --deployment=metrics-server-v0.3.1
          - --container=metrics-server
          - --poll-period=300000
          - --estimator=exponential
          # Specifies the smallest cluster (defined in number of nodes)
          # resources will be scaled to.
          # - --minClusterSize=1
      volumes:
        - name: metrics-server-config-volume
          configMap:
            name: metrics-server-config
      tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
EOF

cp resource-reader.yaml resource-reader.bak

cat > resource-reader.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: system:metrics-server
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  - nodes/stats
  - namespaces
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - "extensions"
  resources:
  - deployments
  verbs:
  - get
  - list
  - update
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:metrics-server
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
EOF

mkdir ${KUBERNETES_SERVER_HOME}/addons/metrics-server
cp ./*.yaml ${KUBERNETES_SERVER_HOME}/addons/metrics-server
cd ${KUBERNETES_SERVER_HOME}/addons/metrics-server

${KUBERNETES_SERVER_HOME}/bin/kubectl apply -f .







