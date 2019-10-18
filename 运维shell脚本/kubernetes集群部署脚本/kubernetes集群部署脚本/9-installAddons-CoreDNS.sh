#!/bin/bash
# 在k8s集群的master上执行
# http://dockone.io/article/8348 coredns原理
# 如果遇到启动Pod遇到CreatePodSandbox或RunPodSandbox异常，请先下载镜像然后改名
# docker pull googlecontainer/pause-amd64:3.0
# docker tag googlecontainer/pause-amd64:3.0 gcr.io/google_containers/pause-amd64:3.0
# docker pull k8s.gcr.io/coredns:1.2.6
# docker pull registry.access.redhat.com/rhel7/pod-infrastructure:latest
# 
source ./environment.sh

# KUBERNETES_SERVER_VERSION=v1.13.4

# cd ${TEMP_WORK_DIR}
# echo -e "\033[32m[Task]\033[0m 检查当前目录是否有该${KUBERNETES_SERVER_VERSION}版本的二进制包。"
# if [[ -e kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz ]]; then
#   echo "  >>> 当前目录存在kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz"
# else
#   echo "  >>> 当前目录不存在kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz即将下载"
#   wget https://dl.k8s.io/${KUBERNETES_SERVER_VERSION}/kubernetes-server-linux-amd64.tar.gz -O kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz
# fi
# tar -xzf kubernetes-server-linux-amd64_${KUBERNETES_SERVER_VERSION}.tar.gz

# cd ${TEMP_WORK_DIR}/kubernetes
# tar -xzf kubernetes-src.tar.gz
# cd ${TEMP_WORK_DIR}/kubernetes/cluster/addons/dns/coredns

# echo -e "\033[32m[Task]\033[0m 为集群部署CoreDNS插件"
# echo "  >>> 生成CoreDNS POD 配置清单。"
# # 在kubelet的安装中设置了DNS服务器地址和集群域名
# # 如果POD的dnspolicy是default，那么它将继承它所在node节点的DNS解析设置。
# # https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/
# sed -e "s/__PILLAR__DNS__DOMAIN__/${CLUSTER_DNS_DOMAIN}/" -e "s/__PILLAR__DNS__SERVER__/${CLUSTER_DNS_SVC_IP}/" coredns.yaml.base > coredns.yaml


# echo "  >>> 拷贝CoreDNS POD配置清单文件"
# mkdir ${KUBERNETES_SERVER_HOME}/addons/coredns
# cp coredns.yaml ${KUBERNETES_SERVER_HOME}/addons/coredns
# echo "  >>> 创建CoreDNS POD。"
# ${KUBERNETES_SERVER_HOME}/bin/kubectl apply -f ${KUBERNETES_SERVER_HOME}/addons/coredns/coredns.yaml

echo -e "\033[32m[Task]\033[0m 创建CoreDNS配置清单目录"
mkdir ${KUBERNETES_SERVER_HOME}/addons/coredns
echo -e "\033[32m[Task]\033[0m 创建CoreDNS配置清单"
cat << EOF > ${KUBERNETES_SERVER_HOME}/addons/coredns/coredns.yaml
# __MACHINE_GENERATED_WARNING__

apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system
  labels:
      kubernetes.io/cluster-service: "true"
      addonmanager.kubernetes.io/mode: Reconcile
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: Reconcile
  name: system:coredns
rules:
- apiGroups:
  - ""
  resources:
  - endpoints
  - services
  - pods
  - namespaces
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: EnsureExists
  name: system:coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:coredns
subjects:
- kind: ServiceAccount
  name: coredns
  namespace: kube-system
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
  labels:
      addonmanager.kubernetes.io/mode: EnsureExists
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes ${CLUSTER_DNS_DOMAIN} in-addr.arpa ip6.arpa {
            pods insecure
            upstream
            fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        proxy . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "CoreDNS"
spec:
  # replicas: not specified here:
  # 1. In order to make Addon Manager do not reconcile this replicas parameter.
  # 2. Default is 1.
  # 3. Will be tuned in real time if DNS horizontal auto-scaling is turned on.
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    metadata:
      labels:
        k8s-app: kube-dns
      annotations:
        seccomp.security.alpha.kubernetes.io/pod: 'docker/default'
    spec:
      serviceAccountName: coredns
      tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
      containers:
      - name: coredns
        image: k8s.gcr.io/coredns:1.2.6
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            memory: 170Mi
          requests:
            cpu: 100m
            memory: 70Mi
        args: [ "-conf", "/etc/coredns/Corefile" ]
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
          readOnly: true
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add:
            - NET_BIND_SERVICE
            drop:
            - all
          readOnlyRootFilesystem: true
      dnsPolicy: Default
      volumes:
        - name: config-volume
          configMap:
            name: coredns
            items:
            - key: Corefile
              path: Corefile
---
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "CoreDNS"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: ${CLUSTER_DNS_SVC_IP}
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
EOF

echo "  >>> 创建CoreDNS POD。"
${KUBERNETES_SERVER_HOME}/bin/kubectl apply -f ${KUBERNETES_SERVER_HOME}/addons/coredns/coredns.yaml

