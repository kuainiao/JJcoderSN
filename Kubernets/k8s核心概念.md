# kubernets核心概念

![image1]()

## Master

​    Master主要负责 资源调度，控制副本，和提供统一访问集群的入口。

## Node

　Node是Kubernetes集群架构中运行Pod的服务节点（亦叫agent或minion）。Node是Kubernetes集群操作的单元，用来承载被分配Pod的运行，是Pod运行的宿主机，由Master管理，并汇报容器状态给Master，同时根据Master要求管理容器生命周期。

## Node IP 

​    Node节点的IP地址，是Kubernetes集群中每个节点的物理网卡的IP地址，是真是存在的物理网络，所有属于这个网络的服务器之间都能通过这个网络直接通信；

## Pod 

   Pod直译是豆荚，可以把容器想像成豆荚里的豆子，把一个或多个关系紧密的豆子包在一起就是豆荚（一个Pod）。在k8s中我们不会直接操作容器，而是把容器包装成Pod再进行管理

　运行于Node节点上， 若干相关容器的组合。Pod内包含的容器运行在同一宿主机上，使用相同的网络命名空间、IP地址和端口，能够通过localhost进行通信。Pod是k8s进行创建、调度和管理的最小单位，它提供了比容器更高层次的抽象，使得部署和管理更加灵活。一个Pod可以包含一个容器或者多个相关容器。

   Pod 就是 k8s 世界里的"应用"；而一个应用，可以由多个容器组成。

## pause容器

​    每个Pod中都有一个pause容器，pause容器做为Pod的网络接入点，Pod中其他的容器会使用容器映射模式启动并接入到这个pause容器。

​    属于同一个Pod的所有容器共享网络的namespace。

​    如果Pod所在的Node宕机，会将这个Node上的所有Pod重新调度到其他节点上；

## Pod Volume:

​    Docker Volume对应Kubernetes中的Pod Volume；

​    数据卷，挂载宿主机文件、目录或者外部存储到Pod中，为应用服务提供存储，也可以Pod中容器之间共享数据。

## 资源限制：  

​    每个Pod可以设置限额的计算机资源有CPU和Memory； 

## Event 

  是一个事件记录，记录了事件最早产生的时间、最后重复时间、重复次数、发起者、类型，以及导致此事件的原因等信息。Event通常关联到具体资源对象上，是排查故障的重要参考信息

## Pod IP 

  Pod的IP地址，是Docker Engine根据docker0网桥的IP地址段进行分配的，通常是一个虚拟的二层网络，位于不同Node上的Pod能够彼此通信，需要通过Pod IP所在的虚拟二层网络进行通信，而真实的TCP流量则是通过Node IP所在的物理网卡流出的；

## Namespace

命名空间将资源对象逻辑上分配到不同Namespace，可以是不同的项目、用户等区分管理，并设定控制策略，从而实现多租户。命名空间也称为虚拟集群。

## Replica Set 

  确保任何给定时间指定的Pod副本数量，并提供声明式更新等功能。

## Deployment

  Deployment是一个更高层次的API对象，它管理ReplicaSets和Pod，并提供声明式更新等功能。

官方建议使用Deployment管理ReplicaSets，而不是直接使用ReplicaSets，这就意味着可能永远不需要直接操作ReplicaSet对象，因此Deployment将会是使用最频繁的资源对象。 

dep-01--->dep-01-243fsf--->dep-01-243fsf-24738473    

##  RC-Replication Controller

　Replication  Controller用来管理Pod的副本，保证集群中存在指定数量的Pod副本。集群中副本的数量大于指定数量，则会停止指定数量之外的多余pod数量，反之，则会启动少于指定数量个数的容器，保证数量不变。Replication  Controller是实现弹性伸缩、动态扩容和滚动升级的核心。

​    部署和升级Pod，声明某种Pod的副本数量在任意时刻都符合某个预期值； 

​      • Pod期待的副本数；

​      • 用于筛选目标Pod的Label Selector；

​      • 当Pod副本数量小于预期数量的时候，用于创建新Pod的Pod模板（template）；

## Service

　Service定义了Pod的逻辑集合和访问该集合的策略，是真实服务的抽象。Service提供了一个统一的服务访问入口以及服务代理和发现机制，用户不需要了解后台Pod是如何运行。

​    一个service定义了访问pod的方式，就像单个固定的IP地址和与其相对应的DNS名之间的关系。

​        Service其实就是我们经常提起的微服务架构中的一个"微服务"，通过分析、识别并建模系统中的所有服务为微服务——Kubernetes Service，最终我们的系统由多个提供不同业务能力而又彼此独立的微服务单元所组成，服务之间通过TCP/IP进行通信，从而形成了我们强大而又灵活的弹性网络，拥有了强大的分布式能力、弹性扩展能力、容错能力；   

![img](file:////tmp/wps-coder/ksohtml/wpsLootpW.jpg) 

如图示，每个Pod都提供了一个独立的Endpoint（Pod IP+ContainerPort）以被客户端访问，多个Pod副本组成了一个集群来提供服务，一般的做法是部署一个负载均衡器来访问它们，为这组Pod开启一个对外的服务端口如8000，并且将这些Pod的Endpoint列表加入8000端口的转发列表中，客户端可以通过负载均衡器的对外IP地址+服务端口来访问此服务。运行在Node上的kube-proxy其实就是一个智能的软件负载均衡器，它负责把对Service的请求转发到后端的某个Pod实例上，并且在内部实现服务的负载均衡与会话保持机制。Service不是共用一个负载均衡器的IP地址，而是每个Servcie分配一个全局唯一的虚拟IP地址，这个虚拟IP被称为Cluster IP。

 

## Cluster IP 

### Service的IP地址,特性： 

​    仅仅作用于Kubernetes Servcie这个对象，并由Kubernetes管理和分配IP地址；

​    无法被Ping，因为没有一个"实体网络对象"来响应；

​    只能结合Service Port组成一个具体的通信端口；

​      Node IP网、Pod IP网域Cluster IP网之间的通信，采用的是Kubernetes自己设计的一种编程方式的特殊的路由规则，与IP路由有很大的不同

## Label

　Kubernetes中的任意API对象都是通过Label进行标识，Label的实质是一系列的K/V键值对。Label是Replication Controller和Service运行的基础，二者通过Label来进行关联Node上运行的Pod。

​    一个label是一个被附加到资源上的键/值对，譬如附加到一个Pod上，为它传递一个用户自定的并且可识别的属性.Label还可以被应用来组织和选择子网中的资源 

   selector是一个通过匹配labels来定义资源之间关系得表达式，例如为一个负载均衡的service指定所目标Pod

   Label可以附加到各种资源对象上，一个资源对象可以定义任意数量的Label。给某个资源定义一个Label，相当于给他打一个标签，随后可以通过Label Selector（标签选择器）查询和筛选拥有某些Label的资源对象。我们可以通过给指定的资源对象捆绑一个或多个Label来实现多维度的资源分组管理功能，以便于灵活、方便的进行资源分配、调度、配置、部署等管理工作；  

   

## Endpoint（IP+Port） 

  标识服务进程的访问点；

## StatefulSet

StatefuleSet主要用来部署有状态应用，能够保证 Pod 的每个副本在整个生命周期中名称是不变的。而其他 Controller 不提供这个功能，当某个 Pod 发生故障需要删除并重新启动时，Pod 的名称会发生变化。同时 StatefuleSet 会保证副本按照固定的顺序启动、更新或者删除。

StatefulSet适合持久性的应用程序，有唯一的网络标识符（IP），持久存储，有序的部署、扩展、删除和滚动更新。

注：Node、Pod、Replication Controller和Service等都可以看作是一种"资源对象"，几乎所有的资源对象都可以通过Kubernetes提供的kubectl工具执行增、删、改、查等操作并将其保存在etcd中持久化存储。

secret

configmap

downwardAPI

serviceaccount

rbac

job

daemonset

pv

pvc

 