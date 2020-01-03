# k8s日志收集实战

### 简介

本文主要介绍在k8s中收集应用的日志方案，应用运行中日志，一般情况下都需要收集存储到一个集中的日志管理系统中，可以方便对日志进行分析统计，监控，甚至用于机器学习，智能分析应用系统问题，及时修复应用所存在的问题。

在k8s集群中应用一般有如下日志输出方式

- 直接遵循docker官方建议把日志输出到标准输出或者标准错误输出
- 输出日志到容器内指定目录中
- 应用直接发送日志给日志收集系统

**日志收集组件说明**

- elastisearch 存储收集到的日志
- kibana 可视化收集到的日志
- logstash 汇总处理日志发送给elastisearch 存储
- filebeat 读取容器或者应用日志文件处理发送给elastisearch或者logstash，也可用于汇总日志
- fluentd 读取容器或者应用日志文件处理发送给elastisearch，也可用于汇总日志
- fluent-bit 读取容器或者应用日志文件处理发送给elastisearch或者fluentd

### 部署

> 本次实验使用了3台虚拟机做k8s集群，每台虚拟机3G内存

#### 部署前的准备

```
# 拉取文件
git clone https://github.com/mgxian/k8s-log.git
cd k8s-log
git checkout v1

# 创建 logging namespace
kubectl apply -f logging-namespace.yaml
```

#### 部署elastisearch

```
# 本次部署虽然使用 StatefulSet 但是没有使用pv进行持久化数据存储
# pod重启之后，数据会丢失，生产环境一定要使用pv持久化存储数据

# 部署
kubectl apply -f elasticsearch.yaml

# 查看状态
kubectl get pods,svc -n logging -o wide

# 等待所有pod变成running状态 
# 访问测试
# 如果测试都有数据返回代表部署成功
kubectl run curl -n logging --image=radial/busyboxplus:curl -i --tty
nslookup elasticsearch-logging
curl 'http://elasticsearch-logging:9200/_cluster/health?pretty'
curl 'http://elasticsearch-logging:9200/_cat/nodes'
exit

# 清理测试
kubectl delete deploy curl -n logging
```

#### 部署kibana

```
# 部署
kubectl apply -f kibana.yaml

# 查看状态
kubectl get pods,svc -n logging -o wide

# 访问测试
# 浏览器访问下面输出的地址 看到 kibana 界面代表正常
# 11.11.11.112 为集群中某个 node 节点ip
KIBANA_NODEPORT=$(kubectl get svc -n logging | grep kibana-logging | awk '{print $(NF-1)}' | awk -F[:/] '{print $2}')
echo "http://11.11.11.112:$KIBANA_NODEPORT/"
```

#### 部署fluentd收集日志

```
# fluentd 以 daemoset 方式部署
# 在每个节点上启动fluentd容器，收集k8s组件，docker以及容器的日志

# 给每个需要启动fluentd的节点打相关label
# kubectl label node lab1 beta.kubernetes.io/fluentd-ds-ready=true
kubectl label nodes --all beta.kubernetes.io/fluentd-ds-ready=true

# 部署
kubectl apply -f fluentd-es-configmap.yaml
kubectl apply -f fluentd-es-ds.yaml

# 查看状态
kubectl get pods,svc -n logging -o wide
```

#### kibana查看日志

> 创建`index fluentd-k8s-*`，由于需要拉取镜像启动容器，可能需要等待几分钟才能看到索引和数据



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165285cb8fc11bc9-1576145258435)





![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165285cdddaee72f-1576145258454)



> 查看日志



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165285d36cb2e00a-1576145258469)



### 应用日志收集测试

#### 应用日志输出到标准输出测试

```
# 启动测试日志输出
kubectl run echo-test --image=radial/busyboxplus:curl -- sh -c 'count=1;while true;do echo log to stdout $count;sleep 1;count=$(($count+1));done'

# 查看状态
kubectl get pods -o wide

# 命令行查看日志
ECHO_TEST_POD=$(kubectl get pods | grep echo-test | awk '{print $1}')
kubectl logs -f $ECHO_TEST_POD

# 刷新 kibana 查看是否有新日志进入
复制代码
```



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165285da0bcb4d61-1576145258478)



#### 应用日志输出到容器指定目录(filebeat收集)

```
# 部署
kubectl apply -f log-contanier-file-filebeat.yaml

# 查看
kubectl get pods -o wide
复制代码
```

> 添加`index filebeat-k8s-*` 查看日志



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165285df41fccb4b-1576145258485)



#### 应用日志输出到容器指定目录(fluent-bit收集)

```
# 部署
kubectl apply -f log-contanier-file-fluentbit.yaml

# 查看
kubectl get pods -o wide
复制代码
```

> 添加`index fluentbit-k8s-*` 查看日志



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165285dd21df31ad-1576145258499)



#### 应用直接发送日志到日志系统

```
# 本次测试应用直接输出日志到 elasticsearch

# 部署
kubectl apply -f log-contanier-es.yaml

# 查看
kubectl get pods -o wide
```

> 添加`index k8s-app-*` 查看日志



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165285e4ae6c2e4a-1576145258510)



#### 清理

```
kubectl delete -f log-contanier-es.yaml
kubectl delete -f log-contanier-file-fluentbit.yaml
kubectl delete -f log-contanier-file-filebeat.yaml
kubectl delete deploy echo-test
```

### 日志收集系统总结

> 本小节的图表以ELK技术栈展示说明，实际使用过程中可以使用EFK技术栈，使用`fluentd`代替`logstash`，使用`fluent-bit`代替`filebeat`。由于`fluentd`在内存占用和性能上有更好的优势，推荐使用`fluentd`替代`logstash` ，`fluent-bit`和`filebeat`性能和内存占用相差不大

#### k8s集群日志通用收集方案

- 集群内相关组件日志使用`fluentd/filebeat`收集
- 应用输出到标准输出或标准错误输出的日志使用`fluentd/filebeat`收集
- 应用输出到容器中指定文件日志使用`fluent-bit/filebeat`收集

#### 通用日志收集系统

> 通用日志收集系统架构



<img src="k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165285ec225f87fd-1576145258517" alt="img" style="zoom:200%;" />



架构说明

- 日志收集与处理解耦
- 由于收集和处理过程间加入了队列，当日志出现暴增时，可以避免分析处理节点被打垮，给分析处理节点足够时间消化日志数据
- 日志分析处理节点可以动态伸缩

#### 大流量日志收集系统

> 大流量日志收集系统架构图



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165285f0575b9e02-1576145258531)



架构说明

- 当日志流量过大时，如果每一个日志收集节点都直连队列写数据，由于有很多分散的连接及写请求，会给队列造成压力。如果日志都发送到logstash收集节点，再集中写入队列，会减轻队列压力。

#### 应用日志收集实验(ELK技术栈)

以收集`nginx`日志为例，进行日志收集分析实验， 复用之前实验创建的`elasticsearch，kibana`应用。实验采用大流量日志收集架构

##### 部署redis队列

```
# 部署
kubectl apply -f redis.yaml

# 查看
kubectl get pods -n logging
```

##### 部署indexer分析日志

```
# 部署
kubectl apply -f logstash-indexer.yaml

# 查看
kubectl get pods -n logging
```

##### 部署shipper集中日志

```
# 部署
kubectl apply -f logstash-shipper.yaml

# 查看
kubectl get pods -n logging
```

##### 部署nginx测试日志收集

```
# 部署
kubectl apply -f nginx-log-filebeat.yaml

# 查看
kubectl get pods
```

##### 持续访问nginx生成日志

```
# 部署
kubectl run curl-test --image=radial/busyboxplus:curl -- sh -c 'count=1;while true;do curl -s -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36 $count" http://nginx-log-filebeat/ >/dev/null;sleep 1;count=$(($count+1));done'

# 查看
kubectl get pods
```

##### 访问kibana查看日志

> 添加`index k8s-logging-elk-*` 由于 logstash 启动较慢，可能需要等待数分钟才能看到数据



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165285fe3443a8aa-1576145258540)



##### 清理

```
kubectl delete -f redis.yaml
kubectl delete -f logstash-indexer.yaml
kubectl delete -f logstash-shipper.yaml
kubectl delete -f nginx-log-filebeat.yaml
kubectl delete deploy curl-test
```

#### 应用日志收集实验(EFK技术栈)

由于fluentd官方不提供redis队列的支持，本次实验移除了redis队列。

##### 部署indexer分析日志

```
# 部署
kubectl apply -f fluentd-indexer.yaml

# 查看
kubectl get pods -n logging
```

##### 部署shipper集中日志

```
# 部署
kubectl apply -f fluentd-shipper.yaml

# 查看
kubectl get pods -n logging
```

##### 部署nginx测试日志收集

```
# 部署
kubectl apply -f nginx-log-fluentbit.yaml

# 查看
kubectl get pods
```

##### 持续访问nginx生成日志

```
# 部署
kubectl run curl-test --image=radial/busyboxplus:curl -- sh -c 'count=1;while true;do curl -s -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36 $count" http://nginx-log-fluentbit/ >/dev/null;sleep 1;count=$(($count+1));done'

# 查看
kubectl get pod
```

##### 访问kibana查看日志

> 添加`index k8s-logging-efk-*`



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165286020d8e8f9a-1576145258560)



##### 清理

```
kubectl delete -f fluentd-indexer.yaml
kubectl delete -f fluentd-shipper.yaml
kubectl delete -f nginx-log-fluentbit.yaml
kubectl delete deploy curl-test
复制代码
```

### 应用日志可视化

#### 部署日志收集需要的组件

```
# 部署 indexer shipper fluentbit
kubectl apply -f fluentd-indexer.yaml
kubectl apply -f fluentd-shipper.yaml
kubectl apply -f nginx-log-fluentbit.yaml

# 查看
kubectl get pods
kubectl get pods -n logging
```

#### 模拟用户访问

```
# 部署
kubectl apply -f web-load-gen.yaml

# 查看
kubectl get pods
```

#### 访问kibana查看日志

> 添加`index k8s-logging-efk-*`



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/1652860812f85c5e-1576145258571)



#### 创建图表

##### 创建 Search

制作 Visualize 的时候需要使用

按指定条件搜索日志



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/1652860a8a1b0680-1576145258576)



保存 Search



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/1652860e4dfeb831-1576145258587)



##### 创建 Visualize

创建好的 Visualize 可以添加到 Dashboard 中

选择制作 Visualize



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165286114a11794c-1576145258603)



选择 Visualize 类型



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165286127894eab1-1576145258607)



选择使用上面步骤保存的 Search



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/1652861440069a1e-1576145258610)



选择指定的 bucket



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/16528616486cc3c5-1576145258620)



选择 code 字段进行统计



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165286178cb497ea-1576145258634)



保存 Visualize



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/1652861950dc51ee-1576145258644)



使用如上的步骤创建多个 Visualize



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/1652861aa1f502f6-1576145258652)



##### 创建 Dashboard

选择创建 Dashboard



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/1652861c3a75a4bb-1576145258663)



把 Visualize 添加到 Dashboard



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/1652861deaa0d86c-1576145258675)



保存 Dashboard



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/1652861f2289e689-1576145258686)



编辑调整位置和大小



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/16528620403f1331-1576145258696)



最终图表展示



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/165286217ad3a86f-1576145258706)



> 如果快速体验可以在 菜单 Managerment 的 Saved Ojects 标签直接使用导入功能，导入本次实验下载目录k8s-log下的`k8s-kibana-all.json`文件



![img](k8s%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E5%AE%9E%E6%88%98.assets/1652862341046992-1576145258715)



### 参考文档

- [kubernetes.io/docs/concep…](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
- [banzaicloud.com/blog/k8s-lo…](https://banzaicloud.com/blog/k8s-logging/)
- [docs.fluentd.org/v0.12/artic…](https://docs.fluentd.org/v0.12/articles/kubernetes-fluentd)
- [jimmysong.io/kubernetes-…](https://jimmysong.io/kubernetes-handbook/practice/app-log-collection.html)
- [github.com/kubernetes/…](https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/fluentd-elasticsearch/README.md)
- [www.elastic.co/blog/shippi…](https://www.elastic.co/blog/shipping-kubernetes-logs-to-elasticsearch-with-filebeat)
- [github.com/elastic/bea…](https://github.com/elastic/beats/blob/master/deploy/kubernetes/filebeat/README.md)
- [www.elastic.co/guide/en/be…](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-input-docker.html)
- [www.elastic.co/guide/en/be…](https://www.elastic.co/guide/en/beats/filebeat/current/add-kubernetes-metadata.html)
- [github.com/fluent/flue…](https://github.com/fluent/fluentd-kubernetes-daemonset)
- [github.com/fluent/flue…](https://github.com/fluent/fluent-bit-kubernetes-logging)
- [github.com/fluent/flue…](https://github.com/fluent/fluent-bit)
- [www.docker.elastic.co/](https://www.docker.elastic.co/)
- [fluentbit.io/documentati…](https://fluentbit.io/documentation/0.13/)
- [docs.fluentd.org/v1.0/articl…](https://docs.fluentd.org/v1.0/articles/quickstart)
- [www.elastic.co/guide/en/lo…](https://www.elastic.co/guide/en/logstash/6.3/deploying-and-scaling.html)