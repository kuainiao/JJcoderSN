# Kubernetes上使用Rook部署Ceph系统并提供PV服务

## 概述

生成环境中，Ceph集群的部署是个非常专业的事情，需要懂Ceph的人来规划和部署，通常部署方式有两种：

1、ceph-deploy

2、ceph-ansible

无论上面的哪一种方式，都需要比较多的专业知识，这明显不适合规模化的需求或者测试环境的需求。而Rook则基于Kubernetes，有效的解决了Ceph集群的部署难题。

## Rook

### Rook简介

项目地址：https://github.com/rook/rook

网站：https://rook.io/

Rook与Kubernetes结合的架构图如下：

[![Rook Architecture on Kubernetes](root-ce.assets/rook-architecture.png)](http://www.yangguanjun.com/images/rook-architecture.png)

从上面可以看出，Rook是基于`Kubernetes`之上，提供一键部署存储系统的编排系统。

> 英文描述：Cloud-Native Storage Orchestrator

当前支持的存储系统有：

- Ceph
- NFS
- Minio
- CockroachDB

其中只有Ceph系统的支持处于beta版本，其他的都还是alpha版本，后续主要介绍通过Rook来部署Ceph集群。

### Rook组件

Rook的主要组件有两个，功能如下：

1. Rook Operator
    - Rook与Kubernetes交互的组件
    - 整个Rook集群只有一个
2. Rook Agent
    - 与Rook Operator交互，执行命令
    - 每个Kubernetes的Node上都会启动一个
    - 不同的存储系统，启动的Agent是不同的

### Rook & Ceph框架

使用Rook部署Ceph集群的架构图如下：

[![Rook Components on Kubernetes](root-ce.assets/kubernetes.png)](http://www.yangguanjun.com/images/kubernetes.png)

从上面可以看出，通过Rook部署完Ceph集群后，就可以提供`Volume Claim`给Kubernetes集群里的App使用了。

部署的Ceph系统可以提供下面三种`Volume Claim`服务：

- Volume：不需要额外组件；
- FileSystem：部署MDS；
- Object：部署RGW；

> 当前也就Ceph RBD支持的比较完善

## 部署Rook系统

Github上下载Rook最新release 0.9.0版本：https://github.com/rook/rook/tree/v0.9.0

要通过Rook部署Ceph集群，首先要部署Rook的两个组件：

1、Rook operator

2、Rook agent

如上面的Rook架构所示，Rook operator会启动一个pod，而Rook agent则会在kubernetes所有的nodes上都启动一个。

部署Rook的组件比较简单，如下命令：

```
# cd rook-master/cluster/examples/kubernetes/ceph/# kubectl create -f operator.yamlnamespace "rook-ceph-system" createdcustomresourcedefinition "clusters.ceph.rook.io" createdcustomresourcedefinition "filesystems.ceph.rook.io" createdcustomresourcedefinition "objectstores.ceph.rook.io" createdcustomresourcedefinition "pools.ceph.rook.io" createdcustomresourcedefinition "volumes.rook.io" createdclusterrole "rook-ceph-cluster-mgmt" createdrole "rook-ceph-system" createdclusterrole "rook-ceph-global" createdserviceaccount "rook-ceph-system" createdrolebinding "rook-ceph-system" createdclusterrolebinding "rook-ceph-global" createddeployment "rook-ceph-operator” created
```

如上所示，它会创建如下资源：

1. namespace：rook-ceph-system，之后的所有rook相关的pod都会创建在该namespace下面
2. CRD：创建五个CRDs，.ceph.rook.io
3. role & clusterrole：用户资源控制
4. serviceaccount：ServiceAccount资源，给Rook创建的Pod使用
5. deployment：rook-ceph-operator，部署rook ceph相关的组件

部署rook-ceph-operator过程中，会触发以`DaemonSet`的方式在集群部署`Agent`和`Discover`pods。

所以部署成功后，可以看到如下pods：

```
# kubectl -n rook-ceph-systemm get pods -o wideNAME                                  READY     STATUS              RESTARTS   AGE       IP                NODErook-ceph-agent-bz4nk                 1/1       Running             0          1d        172.20.4.27       ke-dev1-worker3rook-ceph-agent-f8vcf                 1/1       Running             0          1d        172.20.4.19       ke-dev1-master3rook-ceph-agent-fhxq2                 1/1       Running             0          1d        172.20.4.25       ke-dev1-worker1rook-ceph-agent-nzhrp                 1/1       Running             0          1d        172.20.6.175      ke-dev1-worker4rook-ceph-operator-5dc97f5c79-vq7xs   1/1       Running             0          1d        192.168.32.174    ke-dev1-worker1rook-discover-hcxhj                   1/1       Running             0          1d        192.168.32.130    ke-dev1-worker1rook-discover-j4q9m                   1/1       Running             0          1d        192.168.217.172   ke-dev1-worker4rook-discover-ldrzv                   1/1       Running             0          1d        192.168.2.85      ke-dev1-worker3rook-discover-wcwxx                   1/1       Running             0          1d        192.168.53.255    ke-dev1-master3
```

上述部署在第一次会比较慢，这是因为所有节点都要拉取`rook/ceph:master`镜像，有500多MB大小。

可以通过手动拉取一份，然后在各个节点上load的方式：

```
# docker pull rook/ceph:master# docker save rook/ceph:master > rook-ceph-master.image# docker load -i rook-ceph-master.image
```

## 部署Ceph cluster

### 创建Ceph集群

当检查到Rook部署中的所有pods都为running状态后，就可以部署Ceph集群了，命令如下：

```
# cd rook-master/cluster/examples/kubernetes/ceph/# kubectl create -f cluster.yamlnamespace "rook-ceph" createdserviceaccount "rook-ceph-cluster" createdrole "rook-ceph-cluster" createdrolebinding "rook-ceph-cluster-mgmt" createdrolebinding "rook-ceph-cluster" createdcluster "rook-ceph” created
```

如上所示，它会创建如下资源：

1. namespace：roo-ceph，之后的所有Ceph集群相关的pod都会创建在该namespace下
2. serviceaccount：ServiceAccount资源，给Ceph集群的Pod使用
3. role & rolebinding：用户资源控制
4. cluster：rook-ceph，创建的Ceph集群

Ceph集群部署成功后，可以查看到的pods如下：

```
# kubectl -n rook-ceph get pods -o wideNAME                               READY     STATUS    RESTARTS   AGE       IP                NODErook-ceph-mgr-a-959d64b9d-vwqsw    1/1       Running   0          2m        192.168.32.139    ke-dev1-worker1rook-ceph-mon-a-6d9447cbd9-xgnjd   1/1       Running   0          15m       192.168.53.240    ke-dev1-master3rook-ceph-mon-d-84648b4585-fvkbw   1/1       Running   0          13m       192.168.32.181    ke-dev1-worker1rook-ceph-mon-f-55994d4b94-w6dds   1/1       Running   0          12m       192.168.2.79      ke-dev1-worker3rook-ceph-osd-0-54c8ddbc5b-wzght   1/1       Running   0          1m        192.168.32.179    ke-dev1-worker1rook-ceph-osd-1-844896d6c-q7rm8    1/1       Running   0          1m        192.168.2.119     ke-dev1-worker3rook-ceph-osd-2-67d5d8f754-qfxx6   1/1       Running   0          1m        192.168.53.231    ke-dev1-master3rook-ceph-osd-3-5bd9b98dd4-qhzk5   1/1       Running   0          1m        192.168.217.174   ke-dev1-worker4
```

可以看出部署的Ceph集群有：

1. Ceph Monitors：默认启动三个ceph-mon，可以在cluster.yaml里配置
2. Ceph Mgr：默认启动一个，可以在cluster.yaml里配置
3. Ceph OSDs：根据cluster.yaml里的配置启动，默认在所有的可用节点上启动

上述Ceph组件对应kubernetes的kind是deployment：

```
# kubectl -n rook-ceph get deploymentNAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGErook-ceph-mgr-a          1         1         1            1           22hrook-ceph-mon-a          1         1         1            1           22hrook-ceph-mon-b          1         1         1            1           22hrook-ceph-mon-c          1         1         1            1           22hrook-ceph-osd-0          1         1         1            1           22hrook-ceph-osd-1          1         1         1            1           22hrook-ceph-osd-2          1         1         1            1           22hrook-ceph-tools          1         1         1            1           22h
```

### Ceph集群配置

monitor pod的`ceph.conf`：

```
[root@rook-ceph-mon-a-6d9447cbd9-xgnjd ceph]# cat ceph.conf[global]fsid                      = 165c5334-9e0d-47e7-aa42-8c8006fb924frun dir                   = /var/lib/rook/mon-amon initial members       = f d amon host                  = 10.96.111.234:6790,10.96.160.0:6790,10.96.237.241:6790log file                  = /dev/stderrmon cluster log file      = /dev/stderrpublic addr               = 10.96.237.241cluster addr              = 192.168.53.240mon keyvaluedb            = rocksdbmon_allow_pool_delete     = truemon_max_pg_per_osd        = 1000debug default             = 0debug rados               = 0debug mon                 = 0debug osd                 = 0debug bluestore           = 0debug filestore           = 0debug journal             = 0debug leveldb             = 0filestore_omap_backend    = rocksdbosd pg bits               = 11osd pgp bits              = 11osd pool default size     = 1osd pool default min size = 1osd pool default pg num   = 100osd pool default pgp num  = 100rbd_default_features      = 3fatal signal handlers     = false[mon.a]keyring          = /var/lib/rook/mon-a/keyringpublic bind addr = 192.168.53.240:6790
```

osd pod的`ceph.conf`：

```
[root@rook-ceph-osd-2-67d5d8f754-qfxx6 ceph]# cat ceph.conf[global]run dir                      = /var/lib/rook/osd2mon initial members          = f d amon host                     = 10.96.111.234:6790,10.96.160.0:6790,10.96.237.241:6790log file                     = /dev/stderrmon cluster log file         = /dev/stderrpublic addr                  = 192.168.53.231cluster addr                 = 192.168.53.231mon keyvaluedb               = rocksdbmon_allow_pool_delete        = truemon_max_pg_per_osd           = 1000debug default                = 0debug rados                  = 0debug mon                    = 0debug osd                    = 0debug bluestore              = 0debug filestore              = 0debug journal                = 0debug leveldb                = 0filestore_omap_backend       = rocksdbosd pg bits                  = 11osd pgp bits                 = 11osd pool default size        = 1osd pool default min size    = 1osd pool default pg num      = 100osd pool default pgp num     = 100osd max object name len      = 256osd max object namespace len = 64osd objectstore              = filestorecrush location               = root=default host=ke-dev1-master3rbd_default_features         = 3fatal signal handlers        = false[osd.2]keyring          = /var/lib/rook/osd2/keyringosd journal size = 1024
```

mgr pod的`ceph.conf`：

```
[root@rook-ceph-mgr-a-959d64b9d-xld9r /]# cat /etc/ceph/ceph.conf[global]run dir                   = /var/lib/rook/mgr-amon initial members       = b c amon host                  = 10.96.125.224:6790,10.96.201.208:6790,10.96.59.167:6790log file                  = /dev/stderrmon cluster log file      = /dev/stderrpublic addr               = 192.168.2.94cluster addr              = 192.168.2.94mon keyvaluedb            = rocksdbmon_allow_pool_delete     = truemon_max_pg_per_osd        = 1000debug default             = 0debug rados               = 0debug mon                 = 0debug osd                 = 0debug bluestore           = 0debug filestore           = 0debug journal             = 0debug leveldb             = 0filestore_omap_backend    = rocksdbosd pg bits               = 11osd pgp bits              = 11osd pool default size     = 1osd pool default min size = 1osd pool default pg num   = 100osd pool default pgp num  = 100rbd_default_features      = 3fatal signal handlers     = false[mgr.a]keyring  = /var/lib/rook/mgr-a/keyringmgr data = /var/lib/rook/mgr-a
```

Ceph集群的配置生成是代码中指定的，代码：`pkg/daemon/ceph/config/config.go`

[ceph默认配置]

```
// CreateDefaultCephConfig creates a default ceph config file.func CreateDefaultCephConfig(context *clusterd.Context, cluster *ClusterInfo, runDir string) *CephConfig {    // extract a list of just the monitor names, which will populate the "mon initial members"    // global config field    monMembers := make([]string, len(cluster.Monitors))    monHosts := make([]string, len(cluster.Monitors))    i := 0    for _, monitor := range cluster.Monitors {        monMembers[i] = monitor.Name        monHosts[i] = monitor.Endpoint        i++    }    cephLogLevel := logLevelToCephLogLevel(context.LogLevel)    return &CephConfig{        GlobalConfig: &GlobalConfig{            FSID:                   cluster.FSID,            RunDir:                 runDir,            MonMembers:             strings.Join(monMembers, " "),            MonHost:                strings.Join(monHosts, ","),            LogFile:                "/dev/stderr",            MonClusterLogFile:      "/dev/stderr",            PublicAddr:             context.NetworkInfo.PublicAddr,            PublicNetwork:          context.NetworkInfo.PublicNetwork,            ClusterAddr:            context.NetworkInfo.ClusterAddr,            ClusterNetwork:         context.NetworkInfo.ClusterNetwork,            MonKeyValueDb:          "rocksdb",            MonAllowPoolDelete:     true,            MaxPgsPerOsd:           1000,            DebugLogDefaultLevel:   cephLogLevel,            DebugLogRadosLevel:     cephLogLevel,            DebugLogMonLevel:       cephLogLevel,            DebugLogOSDLevel:       cephLogLevel,            DebugLogBluestoreLevel: cephLogLevel,            DebugLogFilestoreLevel: cephLogLevel,            DebugLogJournalLevel:   cephLogLevel,            DebugLogLevelDBLevel:   cephLogLevel,            FileStoreOmapBackend:   "rocksdb",            OsdPgBits:              11,            OsdPgpBits:             11,            OsdPoolDefaultSize:     1,            OsdPoolDefaultMinSize:  1,            OsdPoolDefaultPgNum:    100,            OsdPoolDefaultPgpNum:   100,            RbdDefaultFeatures:     3,            FatalSignalHandlers:    "false",        },    }}
```

### 删除Ceph集群

删除已创建的Ceph集群，可执行下面命令：

```
# kubectl delete -f cluster.yamlnamespace "rook-ceph" deletedserviceaccount "rook-ceph-cluster" deletedrole "rook-ceph-cluster" deletedrolebinding "rook-ceph-cluster-mgmt" deletedrolebinding "rook-ceph-cluster" deletedcluster "rook-cephn” deleted
```

删除Ceph集群后，在之前部署Ceph组件节点的/var/lib/rook/目录，会遗留下Ceph集群的配置信息。

若之后再部署新的Ceph集群，先把之前Ceph集群的这些信息删除，不然启动monitor会失败；

```
# cat clean-rook-dir.shhosts=(  ke-dev1-master3  ke-dev1-worker1  ke-dev1-worker3  ke-dev1-worker4)for host in ${hosts[@]} ; do  ssh $host "rm -rf /var/lib/rook/*"done
```

### 部署Ceph集群的log

在部署Ceph集群中，可能出错或者不符合预期，这时候就需要查看对应的log，rook是通过`rook-ceph-operator` pod来执行部署Ceph集群的，可以查看它的log：

```
# kubectl -n rook-ceph-system get pods -o wide | grep operratorrook-ceph-operator-5dc97f5c79-vq7xs   1/1       Running             0          18h       192.168.32.174    ke-dev1-worker1# kubectl -n rook-ceph-system log rook-ceph-operator-5dc97f5c79-vq7xs | less2018-11-27 06:52:13.795165 I | op-cluster: starting cluster in namespace rook-ceph2018-11-27 06:52:13.818565 I | op-k8sutil: waiting for job rook-ceph-detect-version to complete...2018-11-27 06:52:28.885610 I | op-cluster: detected ceph version mimic for image ceph/ceph:v132018-11-27 06:52:34.921566 I | op-mon: start running mons...2018-11-27 06:53:54.772352 I | op-mon: Ceph monitors formed quorum2018-11-27 06:53:54.777563 I | op-cluster: creating initial crushmap2018-11-27 06:53:54.777593 I | cephclient: setting crush tunables to firefly...2018-11-27 06:53:56.610181 I | op-cluster: created initial crushmap2018-11-27 06:53:56.641097 I | op-mgr: start running mgr...2018-11-27 06:54:04.742093 I | op-mgr: mgr metrics service started2018-11-27 06:54:04.742125 I | op-osd: start running osds in namespace rook-ceph...2018-11-27 06:54:05.438535 I | exec: noscrub is set...2018-11-27 06:54:06.502961 I | exec: nodeep-scrub is set2018-11-27 06:54:06.520914 I | op-osd: 3 of the 3 storage nodes are valid2018-11-27 06:54:06.520949 I | op-osd: checking if orchestration is still in progress2018-11-27 06:54:06.529539 I | op-osd: start provisioning the osds on nodes, if needed2018-11-27 06:54:06.722825 I | op-osd: avail devices for node ke-dev1-worker1: [{Name:vda FullPath: Config:map[]} {Name:vdb FullPath: Config:map[]} {Name:vdc FullPath: Config:map[]} {Name:vdd FullPath: Config:map[]} {Name:vde FullPath: Config:map[]}]...2018-11-27 06:55:31.377544 I | op-osd: completed running osds in namespace rook-ceph...2018-11-27 06:55:32.831393 I | exec: noscrub is unset...2018-11-27 06:55:33.932523 I | exec: nodeep-scrub is unset2018-11-27 06:55:33.932698 I | op-cluster: Done creating rook instance in namespace rook-ceph2018-11-27 06:55:33.957988 I | op-pool: start watching pool resources in namespace rook-ceph...2018-11-27 06:55:33.975970 I | op-cluster: added finalizer to cluster rook-ceph
```

### Ceph组件的log

从上面章节中各个Ceph组件的`ceph.conf`文件中看出，配置的log输出为`/dev/stderr`，所以我们可以通过获取Ceph组件所在pod的log来查看Ceph组件的log：

```
# kubectl -n rook-ceph log rook-ceph-mon-a-7c47978fbb-hbbjv
```

## Ceph toolbox部署

默认启动的Ceph集群，是开启Ceph认证的，这样你登陆Ceph组件所在的Pod里，是没法去获取集群状态，执行CLI命令的，这时需要部署Ceph toolbox，命令如下：

```
# kubectl create -f toolbox.yamldeployment "rook-ceph-tools" created
```

部署成功后，pod如下：

```
# kubectl -n rook-ceph get pods -o wide | grep ceph-toolsrook-ceph-tools-79954fdf9d-n9qn5   1/1       Running   0          6m        172.20.4.27       ke-dev1-worker3
```

然后可以登陆该pod后，执行Ceph CLI命令：

```
# kubectl -n rook-ceph exec -it rook-ceph-tools-79954fdf9d-n9qn5 bash...[root@ke-dev1-worker3 /]# ceph status cluster:    id:     165c5334-9e0d-47e7-aa42-8c8006fb924f    health: HEALTH_OK  services:    mon: 3 daemons, quorum f,d,a    mgr: a(active)    osd: 4 osds: 4 up, 4 in  data:    pools:   0 pools, 0 pgs    objects: 0  objects, 0 B    usage:   57 GiB used, 21 GiB / 78 GiB avail    pgs:    [root@ke-dev1-worker1 /]# cd /etc/ceph/[root@ke-dev1-worker1 ceph]# lsceph.conf  keyring  rbdmap[root@ke-dev1-worker1 ceph]# cat ceph.conf[global]mon_host = 10.96.59.167:6790,10.96.125.224:6790,10.96.201.208:6790[client.admin]keyring = /etc/ceph/keyring[root@ke-dev1-worker1 ceph]# cat keyring[client.admin]key = AQAL9PxbMXKpDBAAGO8g8GaD6vYC8iD9TaCd1Q==[root@ke-dev1-worker1 ceph]# cat rbdmap# RbdDevice		Parameters#poolname/imagename	id=client,keyring=/etc/ceph/ceph.client.keyring
```

当不需要执行Ceph CLI命令时，可以通过kubectl命令很方便的删除：

```
# kubectl create -f toolbox.yamldeployment "rook-ceph-tools" deleted
```

## RBD服务

在kubernetes集群里，要提供rbd块设备服务，需要有如下步骤：

1. 创建rbd-provisioner pod
2. 创建rbd对应的storageclass
3. 创建pvc使用rbd对应的storageclass
4. 创建pod使用rbd pvc

通过rook创建Ceph Cluster之后，rook自身提供了rbd-provisioner服务，所以我们不需要再部署其provisioner。

> 代码：pkg/operator/ceph/provisioner/provisioner.go

### 创建pool和StorageClass

```
# cat storageclass.yamlapiVersion: ceph.rook.io/v1beta1kind: Poolmetadata:  name: replicapool  namespace: rook-cephspec:  replicated:    size: 1---apiVersion: storage.k8s.io/v1kind: StorageClassmetadata:   name: rook-ceph-blockprovisioner: ceph.rook.io/blockparameters:  pool: replicapool  # Specify the namespace of the rook cluster from which to create volumes.  # If not specified, it will use `rook` as the default namespace of the cluster.  # This is also the namespace where the cluster will be  clusterNamespace: rook-ceph  # Specify the filesystem type of the volume. If not specified, it will use `ext4`.  fstype: xfs  # kubectl create -f storageclass.yamlpool "replicapool" createdstorageclass "rook-ceph-block" created# kubectl get scNAME              PROVISIONER          AGE...rook-ceph-block   ceph.rook.io/block   1h# kubectl get sc rook-ceph-block -o yamlapiVersion: storage.k8s.io/v1kind: StorageClassmetadata:  creationTimestamp: 2018-11-27T08:22:16Z  name: rook-ceph-block  resourceVersion: "248878533"  selfLink: /apis/storage.k8s.io/v1/storageclasses/rook-ceph-block  uid: 8ce4471c-f21d-11e8-bb3e-fa163e65e579parameters:  clusterNamespace: rook-ceph  fstype: xfs  pool: replicapoolprovisioner: ceph.rook.io/blockreclaimPolicy: Delete
```

### 创建pvc

创建一个pvc，使用刚才配置的rbd storageclass。

```
# vim tst-pvc.yamlapiVersion: v1kind: PersistentVolumeClaimmetadata:  name: myclaimspec:  accessModes:  - ReadWriteOnce  resources:    requests:      storage: 8Gi  storageClassName: rook-ceph-block  # kubectl create -f tst-pvc.yamlpersistentvolumeclaim "myclaim” created# kubectl get pvcNAME      STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGEmyclaim   Bound     pvc-f85e52ac-f21f-11e8-bb3e-fa163e65e579   8Gi        RWO            rook-ceph-block   6s
```

在Ceph集群端检查：

```
[root@ke-dev1-worker1 ~]# rbd info -p replicapool pvc-f85e52ac-f21f-11e8-bb3e-fa163e65e579rbd image 'pvc-f85e52ac-f21f-11e8-bb3e-fa163e65e579':    size 8 GiB in 2048 objects    order 22 (4 MiB objects)    id: 133e6b8b4567    block_name_prefix: rbd_data.133e6b8b4567    format: 2    features: layering    op_features:    flags:    create_timestamp: Tue Nov 27 08:39:37 2018
```

### 创建pod

创建一个pod，配置使用刚才创建的rbd pvc。

```
# vim tst-pvc-pod.yamlkind: PodapiVersion: v1metadata:  name: test-pod-rbd  namespace: rook-ceph  labels:    test-rbd: "true"spec:  containers:  - name: test-pod    image: busybox:latest    command:    - "/bin/sh"    args:    - "-c"    - "trap exit TERM; while true; do sleep 1; done"    volumeMounts:    - name: data      mountPath: "/mnt"  volumes:  - name: data    persistentVolumeClaim:      claimName: myclaim      # kubectl create -f tst-pvc-pod.yamlpod "test-pod-rbd” created
```

登陆pod检查rbd设备：

```
# kubectl get pods -o wide...test-pod-rbd   1/1       Running   0         18s       192.168.32.191    ke-dev1-worker1# kubectl exec -it test-pod-rbd sh/ # mount | grep rbd/dev/rbd0 on /mnt type xfs (rw,relatime,attr2,inode64,sunit=8192,swidth=8192,noquota)
```

## CephFS服务

与RBD服务类似，要想在kubernetes里使用CephFS，也需要一个cephfs-provisioner服务，在Rook代码里默认还不支持这个，所以需要单独部署。

参考：https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/cephfs

### 创建CephFS

可以通过下面的命令快速创建一个CephFS，根据自己的需要配置`filesystem.yaml`：

```
# cat filesystem.yamlapiVersion: ceph.rook.io/v1beta1kind: Filesystemmetadata:  name: cephfs  namespace: rook-cephspec:  # The metadata pool spec  metadataPool:    replicated:      # Increase the replication size if you have more than one osd      size: 2  # The list of data pool specs  dataPools:    - failureDomain: osd      replicated:        size: 2  # The metadata service (mds) configuration  metadataServer:    # The number of active MDS instances    activeCount: 2    # Whether each active MDS instance will have an active standby with a warm metadata cache for faster failover.    # If false, standbys will be available, but will not have a warm cache.    activeStandby: true    # The affinity rules to apply to the mds deployment    placement:    #  nodeAffinity:    #    requiredDuringSchedulingIgnoredDuringExecution:    #      nodeSelectorTerms:    #      - matchExpressions:    #        - key: role    #          operator: In    #          values:    #          - mds-node    #  tolerations:    #  - key: mds-node    #    operator: Exists    #  podAffinity:    #  podAntiAffinity:    resources:    # The requests and limits set here, allow the filesystem MDS Pod(s) to use half of one CPU core and 1 gigabyte of memory    #  limits:    #    cpu: "500m"    #    memory: "1024Mi"    #  requests:    #    cpu: "500m"    #    memory: "1024Mi"
```

执行命令：

```
# kubectl create -f filesystem.yamlfilesystem "myfs” created# kubectl -n rook-ceph get pods -o wide | grep mdsrook-ceph-mds-cephfs-a-57db46bfc4-2j9tq   1/1       Running   0          21h       192.168.2.65      ke-dev1-worker3rook-ceph-mds-cephfs-b-6887d9649b-kwkxg   1/1       Running   0          21h       192.168.32.137    ke-dev1-worker1rook-ceph-mds-cephfs-c-8bb84fcf4-lgfjl    1/1       Running   0          21h       192.168.2.84      ke-dev1-worker3rook-ceph-mds-cephfs-d-78cf67cfcb-p9q9k   1/1       Running   0          21h       192.168.32.175    ke-dev1-worker1
```

> 我们配置 activeCount : 2，activeStandby: true，所以这里创建了4个MDS Daemons

mds pod的ceph.conf：

```
[root@rook-ceph-mds-cephfs-a-57db46bfc4-2j9tq /]# cat /etc/ceph/ceph.conf[global]run dir                   = /var/lib/rook/mds-cephfs-amon initial members       = a b cmon host                  = 10.96.59.167:6790,10.96.125.224:6790,10.96.201.208:6790log file                  = /dev/stderrmon cluster log file      = /dev/stderrpublic addr               = 192.168.2.65cluster addr              = 192.168.2.65mon keyvaluedb            = rocksdbmon_allow_pool_delete     = truemon_max_pg_per_osd        = 1000debug default             = 0debug rados               = 0debug mon                 = 0debug osd                 = 0debug bluestore           = 0debug filestore           = 0debug journal             = 0debug leveldb             = 0filestore_omap_backend    = rocksdbosd pg bits               = 11osd pgp bits              = 11osd pool default size     = 1osd pool default min size = 1osd pool default pg num   = 100osd pool default pgp num  = 100rbd_default_features      = 3fatal signal handlers     = false[mds.cephfs-a]keyring               = /var/lib/rook/mds-cephfs-a/keyringmds_standby_for_fscid = 1mds_standby_replay    = true
```

检查CephFS状态：

```
[root@ke-dev1-worker1 /]# ceph fs lsname: cephfs, metadata pool: cephfs-metadata, data pools: [cephfs-data0 ][root@ke-dev1-worker1 /]# ceph dfGLOBAL:    SIZE        AVAIL       RAW USED     %RAW USED    298 GiB     235 GiB       63 GiB         21.13POOLS:    NAME                ID     USED       %USED     MAX AVAIL     OBJECTS...    cephfs-metadata     2      62 KiB         0       110 GiB          41    cephfs-data0        3         4 B         0       110 GiB           2[root@ke-dev1-worker1 /]# ceph fs statuscephfs - 2 clients======+------+----------------+----------+---------------+-------+-------+| Rank |     State      |   MDS    |    Activity   |  dns  |  inos |+------+----------------+----------+---------------+-------+-------+|  0   |     active     | cephfs-d | Reqs:    0 /s |   18  |   21  ||  1   |     active     | cephfs-a | Reqs:    0 /s |   11  |   14  || 0-s  | standby-replay | cephfs-b | Evts:    0 /s |    0  |    0  || 1-s  | standby-replay | cephfs-c | Evts:    0 /s |    0  |    0  |+------+----------------+----------+---------------+-------+-------++-----------------+----------+-------+-------+|       Pool      |   type   |  used | avail |+-----------------+----------+-------+-------+| cephfs-metadata | metadata | 61.6k |  110G ||   cephfs-data0  |   data   |    4  |  110G |+-----------------+----------+-------+-------++-------------+| Standby MDS |+-------------++-------------+
```

### 创建StorageClass

获取Ceph client.admin的keyring：

```
# ceph auth get-key client.adminAQAL9PxbMXKpDBAAGO8g8GaD6vYC8iD9TaCd1Q==
```

创建kubernetes的secret：

```
# cat secretAQAL9PxbMXKpDBAAGO8g8GaD6vYC8iD9TaCd1Q==# kubectl create secret generic rook-ceph-secret-admin --from-file=secret --namespace=kube-systemsecret "rook-ceph-secret-admin" created# kubectl -n kube-system get secret | grep rookrook-ceph-secret-admin             Opaque                       1         18s# kubectl -n kube-system get secret rook-ceph-secret-admin -o yamlapiVersion: v1data:  secret: QVFBTDlQeGJNWEtwREJBQUdPOGc4R2FENnZZQzhpRDlUYUNkMVE9PQo=kind: Secretmetadata:  creationTimestamp: 2018-11-27T10:41:57Z  name: rook-ceph-secret-admin  namespace: kube-system  resourceVersion: "248907628"  selfLink: /api/v1/namespaces/kube-system/secrets/rook-ceph-secret-admin  uid: 0ffcf324-f231-11e8-bb3e-fa163e65e579type: Opaque
```

基于上面创建的adminsecret，创建对应的Storageclass；

```
# cat storageclass.yamlkind: StorageClassapiVersion: storage.k8s.io/v1metadata:   name: rook-ceph-fsprovisioner: ceph.com/cephfsparameters:  monitors: 10.96.59.167:6790,10.96.125.224:6790,10.96.201.208:6790  adminId: admin  adminSecretName: rook-ceph-secret-admin  adminSecretNamespace: kube-system# kubectl create -f storageclass.yamlstorageclass "rook-ceph-fs” created# kubectl get scNAME              PROVISIONER          AGE...rook-ceph-block   ceph.rook.io/block   2hrook-ceph-fs      ceph.com/cephfs      4s
```

### 创建pvc

测试pvc的yaml如下：

```
# cat tst-pvc.yamlapiVersion: v1kind: PersistentVolumeClaimmetadata:  name: mycephfsclaimspec:  accessModes:  - ReadWriteMany  resources:    requests:      storage: 8Gi  storageClassName: rook-ceph-fs
```

创建测试的pvc，并检查其状态：

```
# kubectl create -f tst-pvc.yamlpersistentvolumeclaim "mycephfsclaim" created# kubectl get pvcNAME              STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE...mycephfsclaim      Bound     pvc-1ded8c22-f232-11e8-bb3e-fa163e65e579   8Gi        RWX            rook-ceph-fs      4s
```

### 创建pod

创建测试pod的yaml如下：

```
# cat tst-pvc-pod.yamlkind: PodapiVersion: v1metadata:  name: test-pod-cephfs  labels:    test-rbd: "true"spec:  containers:  - name: test-pod    image: busybox:latest    command:    - "/bin/sh"    args:    - "-c"    - "trap exit TERM; while true; do sleep 1; done"    volumeMounts:    - name: data      mountPath: "/mnt"  volumes:  - name: data    persistentVolumeClaim:      claimName: mycephfsclaim
```

创建测试pod挂载使用上一步创建的pvc：

```
# kubectl create -f tst-pvc-pod.yamlpod "test-pod-cephfs” created# kubectl get podNAME              READY     STATUS              RESTARTS   AGE...test-pod-cephfs   1/1       Running             0          10s# kubectl exec -it test-pod-cephfs sh/ # df -hFilesystem                Size      Used Available Use% Mounted on/dev/mapper/docker-253:48-4456452-9c5c32993ec7add2b6f89fe3f79c95860a2524312c1809d2b5a0fd49462cb828                         20.0G     34.2M     19.9G   0% /tmpfs                    15.7G         0     15.7G   0% /devtmpfs                    15.7G         0     15.7G   0% /sys/fs/cgroup10.96.59.167:6790,10.96.125.224:6790,10.96.201.208:6790:/volumes/kubernetes/kubernetes/kubernetes-dynamic-pvc-1dfe985a-f232-11e8-a11d-fa163e05e95a                        298.3G     63.0G    235.3G  21% /mnt.../ # cd /mnt//mnt # echo hello > file
```

在ceph tool的pod里安装ceph-fuse，然后mount cephfs后检查：

```
[root@ke-dev1-worker1 ~]# yum install -y ceph-fuse[root@ke-dev1-worker1 ~]# ceph-fuse /mnt/ceph-fuse[4369]: starting ceph client2018-11-27 10:49:50.913 7fb9af66ecc0 -1 init, newargv = 0x55a4c80752c0 newargc=7ceph-fuse[4369]: starting fuse[root@ke-dev1-worker1 ~]# dfFilesystem     1K-blocks     Used Available Use% Mounted on...ceph-fuse      115531776        0 115531776   0% /mnt[root@ke-dev1-worker1 ~]# cd /mnt/volumes/kubernetes/kubernetes/kubernetes-dynamic-pvc-1dfe985a-f232-11e8-a11d-fa163e05e95a[root@ke-dev1-worker1 kubernetes-dynamic-pvc-1dfe985a-f232-11e8-a11d-fa163e05e95a]# cat filehello
```

## 总结

本文主要介绍了如何通过Rook在Kubernetes上部署Ceph集群，然后如何来提供Kubernetes里的PV服务：包括RBD和CephFS两种。

整个操作过程还是比较顺利的，对于熟悉Kubernetes的同学来说，你完全不需要理解Ceph系统，不需要理解Ceph的部署步骤，就可以很方便的来通过Ceph系统提供Kubernetes的PV存储服务。

但真正遇到问题的时候，还是需要Rook系统的log 和 Ceph Pod的log来一起定位，这对于后期维护Ceph集群的同学来说，你需要额外的Kubernetes知识，熟悉Kubernetes的基本概念和操作才行。