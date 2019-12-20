# 如何选择哪种Kubernetes apiVersion

`Kubernetes`中的对象定义需要`apiVersion`字段。当`Kubernetes`有一个更新可供您使用的版本时 - 在其API中更改某些内容 - 将创建一个新的`apiVersion`。

但是，官方的`Kubernetes`文档对`apiVersion`提供的指导很少。本文章为大家提供了一个备忘单，说明了要使用的版本，解释了每个版本，并为您提供了版本的时间表。

## 应该使用哪种apiVersion

下面这个表格列出所有对象对应的`apiVersion`值.

| **Kind**                  | **apiVersion**               |
| ------------------------- | ---------------------------- |
| CertificateSigningRequest | certificates.k8s.io/v1beta1  |
| ClusterRoleBinding        | rbac.authorization.k8s.io/v1 |
| ClusterRole               | rbac.authorization.k8s.io/v1 |
| ComponentStatus           | v1                           |
| ConfigMap                 | v1                           |
| ControllerRevision        | apps/v1                      |
| CronJob                   | batch/v1beta1                |
| DaemonSet                 | extensions/v1beta1           |
| Deployment                | extensions/v1beta1           |
| Endpoints                 | v1                           |
| Event                     | v1                           |
| HorizontalPodAutoscaler   | autoscaling/v1               |
| Ingress                   | extensions/v1beta1           |
| Job                       | batch/v1                     |
| LimitRange                | v1                           |
| Namespace                 | v1                           |
| NetworkPolicy             | extensions/v1beta1           |
| Node                      | v1                           |
| PersistentVolumeClaim     | v1                           |
| PersistentVolume          | v1                           |
| PodDisruptionBudget       | policy/v1beta1               |
| Pod                       | v1                           |
| PodSecurityPolicy         | extensions/v1beta1           |
| PodTemplate               | v1                           |
| ReplicaSet                | extensions/v1beta1           |
| ReplicationController     | v1                           |
| ResourceQuota             | v1                           |
| RoleBinding               | rbac.authorization.k8s.io/v1 |
| Role                      | rbac.authorization.k8s.io/v1 |
| Secret                    | v1                           |
| ServiceAccount            | v1                           |
| Service                   | v1                           |
| StatefulSet               | apps/v1                      |

## 每个apiVersion是什么含义?

### alpha

名称中带有`alpha`的API版本是进入`Kubernetes`的新功能的早期候选版本。这些可能包含错误，并且不保证将来可以使用。

### beta

API版本名称中的`beta`表示测试已经超过了`alpha`级别，并且该功能最终将包含在Kubernetes中。 虽然它的工作方式可能会改变，并且对象的定义方式可能会完全改变，但该特征本身很可能以某种形式将其变为`Kubernetes`。

### stable

稳定的`apiVersion`这些名称中不包含`alpha`或`beta`。 它们可以安全使用。

------

#### v1

这是Kubernetes API的第一个稳定版本。 它包含许多核心对象。

#### apps/v1

`apps`是Kubernetes中最常见的API组，其中包含许多核心对象和v1。 它包括与在Kubernetes上运行应用程序相关的功能，如Deployments，RollingUpdates和ReplicaSets。

#### autoscaling/v1

此API版本允许根据不同的资源使用指标自动调整容器。此稳定版本仅支持CPU扩展，但未来的alpha和beta版本将允许您根据内存使用情况和自定义指标进行扩展。

#### batch/v1

`batch`API组包含与批处理和类似作业的任务相关的对象（而不是像应用程序一样的任务，如无限期地运行Web服务器）。 这个`apiVersion`是这些API对象的第一个稳定版本。

#### batch/v1beta1

`Kubernetes`中批处理对象的新功能测试版，特别是包括允许您在特定时间或周期运行作业的CronJobs。

#### certificates.k8s.io/v1beta1

此API版本添加了验证网络证书的功能，以便在群集中进行安全通信。 您可以在[官方文档上](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/)阅读更多内容。

#### extensions/v1beta1

此版本的API包含许多新的常用Kubernetes功能。 部署，DaemonSets，ReplicaSet和Ingresses都在此版本中收到了重大更改。

> Note: 在Kubernetes 1.6中，其中一些对象已从扩展程序重定位到特定的API组（例如，应用程序）。 当这些对象退出测试版时，期望它们位于特定的API组中，例如apps/v1。 使用extensions/v1beta1已被弃用 - 尝试尽可能使用特定的API组，具体取决于您的Kubernetes集群版本。

#### policy/v1beta1

此`apiVersion`增加了设置pod中断预算和pod安全性新规则的功能

#### rbac.authorization.k8s.io/v1

此apiVersion包含Kubernetes基于角色的访问控制的额外功能。这有助于您保护群集。[查看官方博客文章](https://kubernetes.io/blog/2017/10/using-rbac-generally-available-18/)。