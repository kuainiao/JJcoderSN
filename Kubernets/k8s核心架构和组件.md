# Kubernetes架构和组件

![images1](/home/coder/mydisk/coder/Documents/JJcoder个人博客/jjcoderzero.github.io/images/k8s/DeepinScreenshot_select-area_20190920235502.png)

## 主从分布式架构，Master/Node

　- 服务分组，小集群，多集群

 - 服务分组，大集群，单集群

    ## 组件:

    ### Kubernetes Master：

    集群控制节点，负责整个集群的管理和控制，基本上Kubernetes所有的控制命令都是发给它，它来负责具体的执行过程，我们后面所有执行的命令基本都是在Master节点上运行的；

     

    #### 包含如下组件:

    　　1.**Kubernetes API Server**

    　　　　作为Kubernetes系统的入口，其封装了核心对象的增删改查操作，以RESTful API接口方式提供给外部客户和内部组件调用。维护的REST对象持久化到Etcd中存储。

    　　2.**Kubernetes Scheduler**

    　　　　为新建立的Pod进行节点(node)选择(即分配机器)，负责集群的资源调度。组件抽离，可以方便替换成其他调度器。

    　　3.**Kubernetes Controller**

    　　　　负责执行各种控制器，目前已经提供了很多控制器来保证Kubernetes的正常运行。

    　　　- **Replication Controller**

    　　　　 管理维护Replication Controller，关联Replication Controller和Pod，保证Replication Controller定义的副本数量与实际运行Pod数量一致。

    ​         \- **Deployment Controller**

     　　　　管理维护Deployment，关联Deployment和Replication  Controller，保证运行指定数量的Pod。当Deployment更新时，控制实现Replication  Controller和　Pod的更新。

    　　　- **Node Controller**

    　　　　管理维护Node，定期检查Node的健康状态，标识出(失效|未失效)的Node节点。

    　　　- **Namespace Controller**

    　　　　管理维护Namespace，定期清理无效的Namespace，包括Namesapce下的API对象，比如Pod、Service等。

    　　　- **Service Controller**

    　　　　管理维护Service，提供负载以及服务代理。

    　　　- **EndPoints Controller**

    　　　　管理维护Endpoints，关联Service和Pod，创建Endpoints为Service的后端，当Pod发生变化时，实时更新Endpoints。

    　　　- **Service Account Controller**

    　　　　管理维护Service Account，为每个Namespace创建默认的Service Account，同时为Service Account创建Service Account Secret。

    　　　- **Persistent Volume Controller**

     　　　　管理维护Persistent Volume和Persistent Volume  Claim，为新的Persistent Volume Claim分配Persistent Volume进行绑定，为释放的Persistent  Volume执行清理回收。

    　　　- **Daemon Set Controller**

    　　　　管理维护Daemon Set，负责创建Daemon Pod，保证指定的Node上正常的运行Daemon Pod。

    　　　

    　　　- **Job Controller**

    　　　　管理维护Job，为Jod创建一次性任务Pod，保证完成Job指定完成的任务数目

    　　　- **Pod Autoscaler Controller**

    　　　　实现Pod的自动伸缩，定时获取监控数据，进行策略匹配，当满足条件时执行Pod的伸缩动作。

     

    ### Kubernetes Node：

    除了Master，Kubernetes集群中的其他机器被称为Node节点，Node节点才是Kubernetes集群中的工作负载节点，每个Node都会被Master分配一些工作负载（Docker容器），当某个Node宕机，其上的工作负载会被Master自动转移到其他节点上去；

    #### 包含如下组件:

    　　1.**Kubelet**

    　　　　负责管控容器，Kubelet会从Kubernetes API Server接收Pod的创建请求，启动和停止容器，监控容器运行状态并汇报给Kubernetes API Server。

    　　2.**Kubernetes Proxy**

    　　　　负责为Pod创建代理服务，Kubernetes Proxy会从Kubernetes API  Server获取所有的Service信息，并根据Service的信息创建代理服务，实现Service到Pod的请求路由和转发，从而实现Kubernetes层级的虚拟转发网络。

    　　3**.Docker Engine（docker**），Docker引擎，负责本机的容器创建和管理工作；  

    ​       

    ### 数据库

    etcd数据库，可以部署到master上，也可以独立部署

    ​    分布式键值存储系统。用于保存集群状态数据，比如Pod、Service等对象信息。

    docker只是k8s支持的底层容器的一种，k8s还支持另外一种容器技术，名为rocket。