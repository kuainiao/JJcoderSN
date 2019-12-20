																																																																																																																																														容器编排之战

Kubernetes是谷歌严格保密十几年的秘密武器—Borg的一个开源版本，是Docker分布式系统解决方案。 2014年由Google公司启动

## Borg 

 Borg是谷歌内部使用的大规模集群管理系统，基于容器技术，目的是实现资源管理的自动化，以及跨多个数据中心的资源利用率的最大化

容器编排引擎三足鼎立：

  Mesos

  Docker Swarm+compose

  Kubernetes  k8s

Prometheus  p8s 容器监控  promql查询语言

早在 2015 年 5 月，Kubernetes 在 Google 上的搜索热度就已经超过了 Mesos 和 Docker Swarm，从那儿之后更是一路飙升，将对手甩开了十几条街,容器编排引擎领域的三足鼎立时代结束。 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpscGvimH.jpg) 

目前，AWS、Azure、Google、阿里云、腾讯云等主流公有云提供的是基于  Kubernetes  的容器服务；Rancher、CoreOS、IBM、Mirantis、Oracle、Red Hat、VMWare 等无数厂商也在大力研发和推广基于  Kubernetes 的容器 CaaS 或 PaaS 产品。可以说，Kubernetes 是当前容器行业最炙手可热的明星。

 

Google 的数据中心里运行着超过 20 亿个容器，而且 Google 十年前就开始使用容器技术。

最初，Google 开发了一个叫 Borg 的系统（现在命名为 Omega）来调度如此庞大数量的容器和工作负载。在积累了这么多年的经验后，Google 决定重写这个容器管理系统，并将其贡献到开源社区，让全世界都能受益。这个项目就是 Kubernetes。简单的讲，Kubernetes 是 Google Omega 的开源版本。

 

跟很多基础设施领域先有工程实践、后有方法论的发展路线不同，Kubernetes 项目的理论基础则要比工程实践走得靠前得多，这当然要归功于 Google 公司在 2015 年 4 月发布的 Borg 论文了。

 

Borg 系统，一直以来都被誉为 Google 公司内部最强大的"秘密武器"。虽然略显夸张，但这个说法倒不算是吹牛。

 

因为，相比于 Spanner、BigTable 等相对上层的项目，Borg 要承担的责任，是承载 Google 公司整个基础设施的核心依赖。在 Google 公司已经公开发表的基础设施体系论文中，Borg 项目当仁不让地位居整个基础设施技术栈的最底层。

 

由于这样的定位，Borg 可以说是 Google 最不可能开源的一个项目。而幸运地是，得益于 Docker 项目和容器技术的风靡，它却终于得以以另一种方式与开源社区见面，这个方式就是 Kubernetes 项目。

 

所以，相比于"小打小闹"的 Docker 公司、"旧瓶装新酒"的 Mesos 社区，Kubernetes 项目从一开始就比较幸运地站上了一个他人难以企及的高度：在它的成长阶段，这个项目每一个核心特性的提出，几乎都脱胎于 Borg/Omega 系统的设计与经验。更重要的是，这些特性在开源社区落地的过程中，又在整个社区的合力之下得到了极大的改进，修复了很多当年遗留在 Borg 体系中的缺陷和问题。

 

所以，尽管在发布之初被批评是"曲高和寡"，但是在逐渐觉察到 Docker 技术栈的"稚嫩"和 Mesos 社区的"老迈"之后，这个社区很快就明白了：k8s 项目在 Borg 体系的指导下，体现出了一种独有的"先进性"与"完备性"，而这些特质才是一个基础设施领域开源项目赖以生存的核心价值。

## 为什么是编排

一个正在运行的 Linux 容器，可以分成两部分看待：

1. 容器的静态视图

   一组联合挂载在 /var/lib/docker/aufs/mnt 上的 rootfs，这一部分称为"容器镜像"（Container Image）

2. 容器的动态视图

   一个由 Namespace+Cgroups 构成的隔离环境，这一部分称为"容器运行时"（Container Runtime）

 

作为一名开发者，其实并不关心容器运行时的差异。在整个"开发 - 测试 - 发布"的流程中，真正承载着容器信息进行传递的，是容器镜像，而不是容器运行时。

这正是容器技术圈在 Docker 项目成功后不久，就迅速走向了"容器编排"这个"上层建筑"的主要原因：作为一家云服务商或者基础设施提供商，我只要能够将用户提交的 Docker 镜像以容器的方式运行起来，就能成为这个非常热闹的容器生态图上的一个承载点，从而将整个容器技术栈上的价值，沉淀在我的这个节点上。

 

更重要的是，只要从这个承载点向 Docker 镜像制作者和使用者方向回溯，整条路径上的各个服务节点，比如 CI/CD、监控、安全、网络、存储等等，都有可以发挥和盈利的余地。这个逻辑，正是所有云计算提供商如此热衷于容器技术的重要原因：通过容器镜像，它们可以和潜在用户（即，开发者）直接关联起来。

 

从一个开发者和单一的容器镜像，到无数开发者和庞大的容器集群，容器技术实现了从"容器"到"容器云"的飞跃，标志着它真正得到了市场和生态的认可。

 

这样，容器就从一个开发者手里的小工具，一跃成为了云计算领域的绝对主角；而能够定义容器组织和管理规范的"容器编排"技术，则当仁不让地坐上了容器技术领域的"头把交椅"。

 

最具代表性的容器编排工具：

  1. Docker 公司的 Compose+Swarm 组合

2. Google 与 RedHat 公司共同主导的 Kubernetes 项目

## Swarm与CoreOS

Docker 公司发布 Swarm 项目

  Docker 公司在 2014 年发布 Swarm 项目. 一个有意思的事实：虽然通过"容器"这个概念完成了对经典 PaaS 项目的"降维打击"，但是 Docker 项目和 Docker 公司，兜兜转转了一年多，却还是回到了 PaaS 项目原本深耕多年的那个战场：如何让开发者把应用部署在我的项目上。

 

  Docker 项目从发布之初就全面发力，从技术、社区、商业、市场全方位争取到的开发者群体，实际上是为此后吸引整个生态到自家"PaaS"上的一个铺垫。只不过这时，"PaaS"的定义已经全然不是 Cloud Foundry 描述的那个样子，而是变成了一套以 Docker 容器为技术核心，以 Docker 镜像为打包标准的、全新的"容器化"思路。

 

  这正是 Docker 项目从一开始悉心运作"容器化"理念和经营整个 Docker 生态的主要目的。

 

Docker 公司在 Docker 项目已经取得巨大成功后，执意要重新走回 PaaS 之路的原因：

  虽然 Docker 项目备受追捧，但用户们最终要部署的，还是他们的网站、服务、数据库，甚至是云计算业务。只有那些能够为用户提供平台层能力的工具，才会真正成为开发者们关心和愿意付费的产品。而 Docker 项目这样一个只能用来创建和启停容器的小工具，最终只能充当这些平台项目的"幕后英雄"。

 

Docker 公司的老朋友和老对手 CoreOS:

  CoreOS 是一个基础设施领域创业公司。 核心产品是一个定制化的操作系统，用户可以按照分布式集群的方式，管理所有安装了这个操作系统的节点。从而，用户在集群里部署和管理应用就像使用单机一样方便了。

 

Docker 项目发布后，CoreOS 公司很快就认识到可以把"容器"的概念无缝集成到自己的这套方案中，从而为用户提供更高层次的 PaaS 能力。所以，CoreOS 很早就成了 Docker 项目的贡献者，并在短时间内成为了 Docker 项目中第二重要的力量。

 

2014 年底，CoreOS 公司与 Docker 公司停止合作，并推出自己研制的 Rocket（后来叫 rkt）容器。

原因是 Docker 公司对 Docker 项目定位的不满足。Docker 公司的解决方法是让 Docker 项目提供更多的平台层能力，即向 PaaS 项目进化。这与 CoreOS 公司的核心产品和战略发生了严重冲突。

 

Docker 公司在 2014 年就已经定好了平台化的发展方向，并且绝对不会跟 CoreOS 在平台层面开展任何合作。这样看来，Docker 公司在 2014 年 12 月的 DockerCon 上发布 Swarm 的举动，也就一点都不突然了。

 

CoreOS 项目：

   依托于一系列开源项目（比如 Container Linux 操作系统、Fleet 作业调度工具、systemd 进程管理和 rkt 容器），一层层搭建起来的平台产品

Swarm 项目：

  以一个完整的整体来对外提供集群管理功能。Swarm 的最大亮点是它完全使用 Docker 项目原本的容器管理 API 来完成集群管理，比如：

  单机 Docker 项目：

​    \# docker run " 我的容器

 

  多机 Docker 项目：

​    \# docker run -H " 我的 Swarm 集群 API 地址 " " 我的容器 "

 

在部署了 Swarm 的多机环境下，用户只需使用原先的 Docker 指令创建一个容器，这个请求就会被 Swarm 拦截下来处理，然后通过具体的调度算法找到一个合适的 Docker Daemon 运行起来。

 

这个操作方式简洁明了，对于已经了解过 Docker 命令行的开发者们也很容易掌握。所以，这样一个"原生"的 Docker 容器集群管理项目一经发布，就受到了已有 Docker 用户群的热捧。相比之下，CoreOS 的解决方案就显得非常另类，更不用说用户还要去接受完全让人摸不着头脑、新造的容器项目 rkt 了。

 

Swarm 项目只是 Docker 公司重新定义"PaaS"的关键一环。2014 年到 2015 年这段时间里，Docker 项目的迅速走红催生出了一个非常繁荣的"Docker 生态"。在这个生态里，围绕着 Docker 在各个层次进行集成和创新的项目层出不穷。

 

Fig 项目

  被docker收购后改名为 Compose

  Fig 项目基本上只是靠两个人全职开发和维护的，可它却是当时 GitHub 上热度堪比 Docker 项目的明星。

 

  Fig 项目受欢迎的原因：

​    是它在开发者面前第一次提出"容器编排"（Container Orchestration）的概念。

​    "编排"（Orchestration）在云计算行业里不算是新词汇，主要是指用户如何通过某些工具或者配置来完成一组虚拟机以及关联资源的定义、配置、创建、删除等工作，然后由云计算平台按照这些指定的逻辑来完成的过程。

 

​    容器时代，"编排"就是对 Docker 容器的一系列定义、配置和创建动作的管理。而 Fig 的工作实际上非常简单：假如现在用户需要部署的是应用容器 A、数据库容器 B、负载均衡容器 C，那么 Fig 就允许用户把 A、B、C 三个容器定义在一个配置文件中，并且可以指定它们之间的关联关系，比如容器 A 需要访问数据库容器 B。

​     接下来，只需执行一条非常简单的指令：# fig up

​    Fig 就会把这些容器的定义和配置交给 Docker API 按照访问逻辑依次创建，一系列容器就都启动了；而容器 A 与 B 之间的关联关系，也会交给 Docker 的 Link 功能通过写入 hosts 文件的方式进行配置。更重要的是，你还可以在 Fig 的配置文件里定义各种容器的副本个数等编排参数，再加上 Swarm 的集群管理能力，一个活脱脱的 PaaS 呼之欲出。

​     它成了 Docker 公司到目前为止第二大受欢迎的项目，一直到今天也依然被很多人使用。

 

当时的这个容器生态里，还有很多开源项目或公司。比如：

  专门负责处理容器网络的 SocketPlane 项目（后来被 Docker 公司收购）

  专门负责处理容器存储的 Flocker 项目（后来被 EMC 公司收购）

专门给 Docker 集群做图形化管理界面和对外提供云服务的 Tutum 项目（后来被 Docker 公司收购）等等。

## Mesosphere与Mesos

老牌集群管理项目 Mesos 和它背后的创业公司 Mesosphere:

Mesos 社区独特的竞争力：

   超大规模集群的管理经验

  Mesos 早已通过了万台节点的验证，2014 年之后又被广泛使用在 eBay 等大型互联网公司的生产环境中。   

  

  Mesos 是 Berkeley 主导的大数据套件之一，是大数据火热时最受欢迎的资源管理项目，也是跟 Yarn 项目杀得难舍难分的实力派选手。

  大数据所关注的计算密集型离线业务，其实并不像常规的 Web 服务那样适合用容器进行托管和扩容，也没有对应用打包的强烈需求，所以 Hadoop、Spark 等项目到现在也没在容器技术上投下更大的赌注；

  但对于 Mesos 来说，天生的两层调度机制让它非常容易从大数据领域抽身，转而去支持受众更加广泛的 PaaS 业务。

 

  在这种思路指导下，Mesosphere 公司发布了一个名为 Marathon 的项目，这个项目很快就成为 Docker Swarm 的一个有力竞争对手。

通过 Marathon 实现了诸如应用托管和负载均衡的 PaaS 功能之后，Mesos+Marathon 的组合实际上进化成了一个高度成熟的 PaaS 项目，同时还能很好地支持大数据业务。

 

  Mesosphere 公司提出"DC/OS"（数据中心操作系统）的口号和产品：

​    旨在使用户能够像管理一台机器那样管理一个万级别的物理机集群，并且使用 Docker 容器在这个集群里自由地部署应用。这对很多大型企业来说具有着非同寻常的吸引力。

 

这时的容器技术生态， CoreOS 的 rkt 容器完全打不开局面，Fleet 集群管理项目更是少有人问津，CoreOS 完全被 Docker 公司压制了。

RedHat 也是因为对 Docker 公司平台化战略不满而愤愤退出。但此时，它竟只剩下 OpenShift 这个跟 Cloud Foundry 同时代的经典 PaaS 一张牌可以打，跟 Docker Swarm 和转型后的 Mesos 完全不在同一个"竞技水平"之上。

 

\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## google与k8s

事实并非如此 下回分解

 

2014 年 6 月，基础设施领域的翘楚 Google 公司突然发力，正式宣告了一个名叫 Kubernetes 项目的诞生。这个项目，不仅挽救了当时的 CoreOS 和 RedHat，还如同当年 Docker 项目的横空出世一样，再一次改变了整个容器市场的格局。

 

这段时间，也正是 Docker 生态创业公司们的春天，大量围绕着 Docker 项目的网络、存储、监控、CI/CD，甚至 UI 项目纷纷出台，也涌现出了很多 Rancher、Tutum 这样在开源与商业上均取得了巨大成功的创业公司。

 

在 2014~2015 年间，整个容器社区可谓热闹非凡。

 

这令人兴奋的繁荣背后，却浮现出了更多的担忧。这其中最主要的负面情绪，是对 Docker 公司商业化战略的种种顾虑。

 

事实上，很多从业者也都看得明白，Docker 项目此时已经成为 Docker 公司一个商业产品。而开源，只是 Docker 公司吸引开发者群体的一个重要手段。不过这么多年来，开源社区的商业化其实都是类似的思路，无非是高不高调、心不心急的问题罢了。

 

而真正令大多数人不满意的是，Docker 公司在 Docker 开源项目的发展上，始终保持着绝对的权威和发言权，并在多个场合用实际行动挑战到了其他玩家（比如，CoreOS、RedHat，甚至谷歌和微软）的切身利益。

 

那么，这个时候，大家的不满也就不再是在 GitHub 上发发牢骚这么简单了。

 

相信很多容器领域的老玩家们都听说过，Docker 项目刚刚兴起时，Google 也开源了一个在内部使用多年、经历过生产环境验证的 Linux 容器：lmctfy（Let Me Container That For You）。

 

然而，面对 Docker 项目的强势崛起，这个对用户没那么友好的 Google 容器项目根本没有招架之力。所以，知难而退的 Google 公司，向 Docker 公司表示了合作的愿望：关停这个项目，和 Docker 公司共同推进一个中立的容器运行时（container runtime）库作为 Docker 项目的核心依赖。

 

不过，Docker 公司并没有认同这个明显会削弱自己地位的提议，还在不久后，自己发布了一个容器运行时库 Libcontainer。这次匆忙的、由一家主导的、并带有战略性考量的重构，成了 Libcontainer 被社区长期诟病代码可读性差、可维护性不强的一个重要原因。

 

至此，Docker 公司在容器运行时层面上的强硬态度，以及 Docker 项目在高速迭代中表现出来的不稳定和频繁变更的问题，开始让社区叫苦不迭。

 

这种情绪在 2015 年达到了一个高潮，容器领域的其他几位玩家开始商议"切割"Docker 项目的话语权。而"切割"的手段也非常经典，那就是成立一个中立的基金会。

 

于是，2015 年 6 月 22 日，由 Docker 公司牵头，CoreOS、Google、RedHat 等公司共同宣布，Docker 公司将 Libcontainer 捐出，并改名为 RunC 项目，交由一个完全中立的基金会管理，然后以 RunC 为依据，大家共同制定一套容器和镜像的标准和规范。

 

这套标准和规范，就是 OCI（ Open Container Initiative ）。OCI 的提出，意在将容器运行时和镜像的实现从 Docker 项目中完全剥离出来。这样做，一方面可以改善 Docker 公司在容器技术上一家独大的现状，另一方面也为其他玩家不依赖于 Docker 项目构建各自的平台层能力提供了可能。

 

不过，OCI 的成立更多的是这些容器玩家出于自身利益进行干涉的一个妥协结果。尽管 Docker 是 OCI 的发起者和创始成员，它却很少在 OCI 的技术推进和标准制定等事务上扮演关键角色，也没有动力去积极地推进这些所谓的标准。

 

这也是迄今为止 OCI 组织效率持续低下的根本原因。

 

OCI 并没能改变 Docker 公司在容器领域一家独大的现状，Google 和 RedHat 等公司于是把第二把武器摆上了台面。

 

Docker 之所以不担心 OCI 的威胁，原因就在于它的 Docker 项目是容器生态的事实标准，而它所维护的 Docker 社区也足够庞大。可是，一旦这场斗争被转移到容器之上的平台层，或者说 PaaS 层，Docker 公司的竞争优势便立刻捉襟见肘了。

 

在这个领域里，像 Google 和 RedHat 这样的成熟公司，都拥有着深厚的技术积累；而像 CoreOS 这样的创业公司，也拥有像 Etcd 这样被广泛使用的开源基础设施项目。

 

可是 Docker 公司却只有一个 Swarm。

 

所以这次，Google、RedHat 等开源基础设施领域玩家们，共同牵头发起了一个名为 CNCF（Cloud Native Computing Foundation）的基金会。这个基金会的目的其实很容易理解：它希望，以 Kubernetes 项目为基础，建立一个由开源基础设施领域厂商主导的、按照独立基金会方式运营的平台级社区，来对抗以 Docker 公司为核心的容器商业生态。

 

为了打造出一个围绕 Kubernetes 项目的"护城河"，CNCF 社区就需要至少确保两件事情：

  Kubernetes 项目必须能够在容器编排领域取得足够大的竞争优势；

  CNCF 社区必须以 Kubernetes 项目为核心，覆盖足够多的场景。

 

CNCF 社区如何解决 Kubernetes 项目在编排领域的竞争力的问题：

  在容器编排领域，Kubernetes 项目需要面对来自 Docker 公司和 Mesos 社区两个方向的压力。Swarm 和 Mesos 实际上分别从两个不同的方向讲出了自己最擅长的故事：Swarm 擅长的是跟 Docker 生态的无缝集成，而 Mesos 擅长的则是大规模集群的调度与管理。

 

这两个方向，也是大多数人做容器集群管理项目时最容易想到的两个出发点。也正因为如此，Kubernetes 项目如果继续在这两个方向上做文章恐怕就不太明智了。

 

Kubernetes 选择的应对方式是：Borg

k8s 项目大多来自于 Borg 和 Omega 系统的内部特性，这些特性落到 k8s 项目上，就是 Pod、Sidecar 等功能和设计模式。

 

这就解释了，为什么 Kubernetes 发布后，很多人"抱怨"其设计思想过于"超前"的原因：Kubernetes 项目的基础特性，并不是几个工程师突然"拍脑袋"想出来的东西，而是 Google 公司在容器化基础设施领域多年来实践经验的沉淀与升华。这正是 Kubernetes 项目能够从一开始就避免同 Swarm 和 Mesos 社区同质化的重要手段。

 

CNCF 接下来的任务是如何把这些先进的思想通过技术手段在开源社区落地，并培育出一个认同这些理念的生态？

  RedHat 发挥了重要作用。当时，Kubernetes 团队规模很小，能够投入的工程能力十分紧张，这恰恰是 RedHat 的长处。RedHat 更是世界上为数不多、能真正理解开源社区运作和项目研发真谛的合作伙伴。

 

RedHat 与 Google 联盟的成立，不仅保证了 RedHat 在 Kubernetes 项目上的影响力，也正式开启了容器编排领域"三国鼎立"的局面。

 

Mesos 社区与容器技术的关系，更像是"借势"，而不是这个领域真正的参与者和领导者。这个事实，加上它所属的 Apache 社区固有的封闭性，导致了 Mesos 社区虽然技术最为成熟，却在容器编排领域鲜有创新。

 

一开始，Docker 公司就把应对 Kubernetes 项目的竞争摆在首要位置：

  一方面，不断强调"Docker Native"的"重要性"

  一方面，与 k8s 项目在多个场合进行了直接的碰撞。

 

这次竞争的发展态势，很快就超过了 Docker 公司的预期。

 

Kubernetes 项目并没有跟 Swarm 项目展开同质化的竞争

   所以 "Docker Native"的说辞并没有太大的杀伤力

   相反 k8s 项目让人耳目一新的设计理念和号召力，很快就构建出了一个与众不同的容器编排与管理的生态。

 

Kubernetes 项目在 GitHub 上的各项指标开始一骑绝尘，将 Swarm 项目远远地甩在了身后。

 

CNCF 社区如何解决第二个问题：

在已经囊括了容器监控事实标准的 Prometheus 项目后，CNCF 社区迅速在成员项目中添加了 Fluentd、OpenTracing、CNI 等一系列容器生态的知名工具和项目。

 

而在看到了 CNCF 社区对用户表现出来的巨大吸引力之后，大量的公司和创业团队也开始专门针对 CNCF 社区而非 Docker 公司制定推广策略。

 

2016 年，Docker 公司宣布了一个震惊所有人的计划：放弃现有的 Swarm 项目，将容器编排和集群管理功能全部内置到 Docker 项目当中。

Docker 公司意识到了 Swarm 项目目前唯一的竞争优势，就是跟 Docker 项目的无缝集成。那么，如何让这种优势最大化呢？那就是把 Swarm 内置到 Docker 项目当中。

 

从工程角度来看，这种做法的风险很大。内置容器编排、集群管理和负载均衡能力，固然可以使得 Docker 项目的边界直接扩大到一个完整的 PaaS 项目的范畴，但这种变更带来的技术复杂度和维护难度，长远来看对 Docker 项目是不利的。

 

不过，在当时的大环境下，Docker 公司的选择恐怕也带有一丝孤注一掷的意味。

 

k8s 的应对策略：

  是反其道而行之，开始在整个社区推进"民主化"架构，即：从 API 到容器运行时的每一层，Kubernetes 项目都为开发者暴露出了可以扩展的插件机制，鼓励用户通过代码的方式介入到 Kubernetes 项目的每一个阶段。

 

Kubernetes 项目的这个变革的效果立竿见影，很快在整个容器社区中催生出了大量的、基于 Kubernetes API 和扩展接口的二次创新工作，比如：

  目前热度极高的微服务治理项目 Istio；

  被广泛采用的有状态应用部署框架 Operator；

  还有像 Rook 这样的开源创业项目，它通过 Kubernetes 的可扩展接口，把 Ceph 这样的重量级产品封装成了简单易用的容器存储插件。

 

在鼓励二次创新的整体氛围当中，k8s 社区在 2016 年后得到了空前的发展。更重要的是，不同于之前局限于"打包、发布"这样的 PaaS 化路线，这一次容器社区的繁荣，是一次完全以 Kubernetes 项目为核心的"百花争鸣"。

 

面对 Kubernetes 社区的崛起和壮大，Docker 公司也不得不面对自己豪赌失败的现实。但在早前拒绝了微软的天价收购之后，Docker 公司实际上已经没有什么回旋余地，只能选择逐步放弃开源社区而专注于自己的商业化转型。

 

所以，从 2017 年开始，Docker 公司先是将 Docker 项目的容器运行时部分 Containerd 捐赠给 CNCF 社区，标志着 Docker 项目已经全面升级成为一个 PaaS 平台；紧接着，Docker 公司宣布将 Docker 项目改名为 Moby，然后交给社区自行维护，而 Docker 公司的商业产品将占有 Docker 这个注册商标。

 

Docker 公司这些举措背后的含义非常明确：它将全面放弃在开源社区同 Kubernetes 生态的竞争，转而专注于自己的商业业务，并且通过将 Docker 项目改名为 Moby 的举动，将原本属于 Docker 社区的用户转化成了自己的客户。

 

2017 年 10 月，Docker 公司出人意料地宣布，将在自己的主打产品 Docker 企业版中内置 Kubernetes 项目，这标志着持续了近两年之久的"编排之争"至此落下帷幕。

 

2018 年 1 月 30 日，RedHat 宣布斥资 2.5 亿美元收购 CoreOS。

 

2018 年 3 月 28 日，这一切纷争的始作俑者，Docker 公司的 CTO Solomon Hykes 宣布辞职，曾经纷纷扰扰的容器技术圈子，到此尘埃落定。

 

容器技术圈子在短短几年里发生了很多变数，但很多事情其实也都在情理之中。就像 Docker 这样一家创业公司，在通过开源社区的运作取得了巨大的成功之后，就不得不面对来自整个云计算产业的竞争和围剿。而这个产业的垄断特性，对于 Docker 这样的技术型创业公司其实天生就不友好。

 

在这种局势下，接受微软的天价收购，在大多数人看来都是一个非常明智和实际的选择。可是 Solomon Hykes 却多少带有一些理想主义的影子，既然不甘于"寄人篱下"，那他就必须带领 Docker 公司去对抗来自整个云计算产业的压力。

 

只不过，Docker 公司最后选择的对抗方式，是将开源项目与商业产品紧密绑定，打造了一个极端封闭的技术生态。而这，其实违背了 Docker 项目与开发者保持亲密关系的初衷。相比之下，Kubernetes 社区，正是以一种更加温和的方式，承接了 Docker 项目的未尽事业，即：以开发者为核心，构建一个相对民主和开放的容器生态。

 

这也是为何，Kubernetes 项目的成功其实是必然的。

 

很难想象如果 Docker 公司最初选择了跟 Kubernetes 社区合作，如今的容器生态又将会是怎样的一番景象。不过我们可以肯定的是，Docker 公司在过去五年里的风云变幻，以及 Solomon Hykes 本人的传奇经历，都已经在云计算的长河中留下了浓墨重彩的一笔。

 

总结：

容器技术的兴起源于 PaaS 技术的普及；

Docker 公司发布的 Docker 项目具有里程碑式的意义；

Docker 项目通过"容器镜像"，解决了应用打包这个根本性难题。

 

容器本身没有价值，有价值的是"容器编排"。

 

也正因为如此，容器技术生态才爆发了一场关于"容器编排"的"战争"。而这次战争，最终以 Kubernetes 项目和 CNCF 社区的胜利而告终。

# Kubernetes核心概念

## Master
Master主要负责`资源调度`(scheduler)，`控制副本`(replication controler)，和提供统一访问`集群的入口`。

## Node
Node是Kubernetes集群架构中`运行Pod的服务节点`（亦叫agent或minion(奴才)）。Node是Kubernetes集群操作的单元，用来承载被分配Pod的运行，是Pod运行的宿主机，由Master管理，并汇报容器状态给Master，同时根据Master要求管理容器生命周期。

## Node IP 

Node节点的IP地址，是Kubernetes集群中每个节点的`物理网卡的IP地址`，是真是存在的物理网络，所有属于这个网络的服务器之间都能通过这个网络直接通信；

## Pod 

运行于Node节点上， 若干相关容器的组合。Pod内包含的容器运行在同一宿主机上，使用相同的`网络命名空间`、`IP地址`和`端口`，能够通过localhost进行通信。Pod是k8s进行创建、调度和管理的最小单位，它提供了比容器更高层次的抽象，使得部署和管理更加灵活。一个Pod可以包含一个容器或者多个相关容器。Pod 就是 k8s 世界里的"`应用`"；而一个应用，可以由多个容器组成。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsjameB4.jpg) 

## pause容器

每个Pod中都有一个pause容器，pause容器做为`Pod的网络接入点`，Pod中其他的容器会使用容器映射模式启动并接入到这个pause容器。`属于同一个Pod的所有容器共享网络的namespace`。 如果Pod所在的Node宕机，会将这个Node上的所有Pod重新调度到其他节点上；

## Pod Volume

Docker Volume对应Kubernetes中的Pod Volume；

数据卷，挂载宿主机文件、目录或者外部存储到Pod中，为应用服务提供存储，也可以Pod中容器之间共享数据。

## 资源限制

  每个Pod可以设置限额的计算机资源有CPU和Memory； 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsCkqeQr.jpg)![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsSQug5O.jpg) 

## Event 

 是一个事件记录，记录了事件`最早产生的时间`、`最后重复时间`、`重复次数`、`发起者`、`类型`，以及`导致此事件的原因`等信息。Event通常关联到具体资源对象上，是排查故障的重要参考信息

## Pod IP 

 `Pod的IP地址`，是Docker Engine根据docker0网桥的IP地址段进行分配的，通常是一个虚拟的二层网络，位于不同Node上的Pod能够彼此通信，需要通过Pod IP所在的虚拟二层网络进行通信，而真实的TCP流量则是通过Node IP所在的物理网卡流出的；

## Namespace

命名空间将资源对象逻辑上分配到不同Namespace，可以是不同的项目、用户等区分管理，并设定控制策略，从而实现多租户。`命名空间也称为虚拟集群`。

## Replica Set 

 确保任何给定时间指定的`Pod副本数量`，并提供声明式更新等功能。

## Deployment

 Deployment是一个更高层次的API对象，它`管理ReplicaSets和Pod`，并提供声明式更新等功能。

> 官方建议使用Deployment管理ReplicaSets，而不是直接使用ReplicaSets，这就意味着可能永远不需要直接操作ReplicaSet对象，因此Deployment将会是使用最频繁的资源对象。 
>

dep-01(deployment)--->dep-01-243fsf(replicaset)--->dep-01-243fsf-24738473(pod)   

## RC-Replication Controller

Replication  Controller用来`管理Pod的副本`，保证集群中存在指定数量的Pod副本。集群中副本的数量大于指定数量，则会停止指定数量之外的多余pod数量，反之，则会启动少于指定数量个数的容器，保证数量不变。Replication  Controller是实现`弹性伸缩`、`动态扩容`和`滚动升级`的核心。

部署和升级Pod，声明某种Pod的副本数量在任意时刻都符合某个预期值； 

   • Pod期待的副本数；

   • 用于筛选目标Pod的Label Selector；

   • 当Pod副本数量小于预期数量的时候，用于创建新Pod的Pod模板（template）；

## Service

Service定义了Pod的逻辑集合和访问该集合的策略，是`真实服务的抽象`。Service提供了一个统一的`服务访问入口`以及`服务代理`和`发现机制`，用户不需要了解后台Pod是如何运行。

一个service定义了访问pod的方式，就像单个固定的IP地址和与其相对应的DNS名之间的关系。

Service其实就是我们经常提起的微服务架构中的一个"微服务"，通过分析、识别并建模系统中的所有服务为微服务——Kubernetes Service，最终我们的系统由多个提供不同业务能力而又彼此独立的微服务单元所组成，服务之间通过TCP/IP进行通信，从而形成了我们强大而又灵活的弹性网络，拥有了强大的分布式能力、弹性扩展能力、容错能力；  

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps3VGmkc.jpg) 

如图示，每个Pod都提供了一个独立的Endpoint（Pod IP+ContainerPort）以被客户端访问，多个Pod副本组成了一个集群来提供服务，一般的做法是部署一个负载均衡器来访问它们，为这组Pod开启一个对外的服务端口如8000，并且将这些Pod的Endpoint列表加入8000端口的转发列表中，客户端可以通过负载均衡器的对外IP地址+服务端口来访问此服务。运行在Node上的kube-proxy其实就是一个智能的软件负载均衡器，它负责把对Service的请求转发到后端的某个Pod实例上，并且在内部实现服务的负载均衡与会话保持机制。Service不是共用一个负载均衡器的IP地址，而是每个Servcie分配一个全局唯一的虚拟IP地址，这个虚拟IP被称为`Cluster IP`。

## Cluster IP 

  Service的IP地址,特性： 

1. 仅仅作用于Kubernetes Servcie这个对象，并由Kubernetes管理和分配IP地址；

2. 无法被Ping，因为没有一个"实体网络对象"来响应；

3.   只能结合Service Port组成一个具体的通信端口；

4.    Node IP网、Pod IP网域Cluster IP网之间的通信，采用的是Kubernetes自己设计的一种编程方式的特殊的路由规则，与IP路由有很大的不同

## Label

Kubernetes中的任意API对象都是通过Label进行标识，Label的实质是一系列的K/V键值对。Label是Replication Controller和Service运行的基础，二者通过Label来进行关联Node上运行的Pod。

一个label是一个被附加到资源上的键/值对，譬如附加到一个Pod上，为它传递一个用户自定的并且可识别的属性.Label还可以被应用来组织和选择子网中的资源

`selector`是一个通过匹配labels来定义资源之间关系的表达式，例如为一个负载均衡的service指定所目标Pod

Label可以附加到各种资源对象上，一个资源对象可以定义任意数量的Label。给某个资源定义一个Label，相当于给他打一个标签，随后可以通过Label Selector（标签选择器）查询和筛选拥有某些Label的资源对象。我们可以通过给指定的资源对象捆绑一个或多个Label来实现多维度的资源分组管理功能，以便于灵活、方便的进行资源分配、调度、配置、部署等管理工作；  

## Endpoint

（pod的IP+容器的Port）访问容器 ，标识服务进程的访问点；

## StatefulSet

StatefuleSet主要`用来部署有状态应用`，能够保证 Pod 的每个副本在整个生命周期中名称是不变的。而其他 Controller 不提供这个功能，当某个 Pod 发生故障需要删除并重新启动时，Pod 的名称会发生变化。同时 `StatefuleSet 会保证副本按照固定的顺序启动、更新或者删除`。

StatefulSet适合`持久性的应用程序`，有`唯一的网络标识符（IP）`，`持久存储`，有序的`部署`、`扩展`、`删除`和`滚动更新`。

> 注：Node、Pod、Replication Controller和Service等都可以看作是一种"资源对象"，几乎所有的资源对象都可以通过Kubernetes提供的kubectl工具执行增、删、改、查等操作并将其保存在etcd中持久化存储。
>

 

# Kubernetes架构和组件

架构:

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsDqRxzz.jpg) 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsM3OLOW.png) 

主从分布式架构，Master/Node

　- 服务分组，小集群，多集群

　- 服务分组，大集群，单集群

## 组件:

### `Kubernetes Master`

集群控制节点，负责整个集群的管理和控制，基本上Kubernetes所有的控制命令都是发给它，它来负责具体的执行过程。

包含如下组件:

#### `Kubernetes API Server`

作为Kubernetes系统的入口，其封装了核心对象的`增删改查操作`，以RESTful API接口方式提供给外部客户和内部组件调用。维护的REST对象持久化到Etcd中存储。

#### `Kubernetes Scheduler`

为新建立的Pod进行`节点(node)选择`(即分配机器)，负责集群的资源调度。组件抽离，可以方便替换成其他调度器。

#### `Kubernetes Controller` 

负责执行各种控制器，目前已经提供了很多控制器来保证Kubernetes的正常运行。

#### `Replication Controller`

管理维护Replication Controller，`关联Replication Controller和Pod`，保证Replication Controller定义的副本数量与实际运行Pod数量一致。

#### `Deployment Controller`

管理维护Deployment，`关联Deployment和Replication  Controller`，保证运行指定数量的Pod。当Deployment更新时，控制实现Replication  Controller和Pod的更新。

#### `Node Controller`

`管理维护Node`，定期检查Node的健康状态，标识出(失效|未失效)的Node节点。

#### `Namespace Controller`

管理维护Namespace，定期清理无效的Namespace，包括Namesapce下的API对象，比如Pod、Service等。

#### `Service Controller`

管理维护Service，提供负载以及服务代理。

#### `EndPoints Controller`

管理维护Endpoints，关联Service和Pod，创建Endpoints为Service的后端，当Pod发生变化时，实时更新Endpoints。

#### `Service Account Controller`

管理维护Service Account，为每个Namespace创建默认的Service Account，同时为Service Account创建Service Account Secret。

#### `Persistent Volume Controller`

管理维护Persistent(持久) Volume和Persistent Volume  Claim，为新的Persistent Volume Claim分配Persistent Volume进行绑定，为释放的Persistent  Volume执行清理回收。

#### `Daemon Set Controller`

管理维护Daemon Set，负责创建Daemon Pod，保证指定的Node上正常的运行Daemon Pod。　　

#### `Job Controller`

管理维护Job，为Jod创建一次性任务Pod，保证完成Job指定完成的任务数目

#### `Pod Autoscaler Controller`

实现Pod的自动伸缩，定时获取监控数据，进行策略匹配，当满足条件时执行Pod的伸缩动作。

### Kubernetes Node

除了Master，Kubernetes集群中的其他机器被称为Node节点，Node节点才是Kubernetes集群中的工作负载节点，每个Node都会被Master分配一些工作负载（Docker容器），当某个Node宕机，其上的工作负载会被Master自动转移到其他节点上去；

包含如下组件:

#### `Kubelet`

`负责管控容器`，Kubelet会从Kubernetes API Server接收Pod的创建请求，启动和停止容器，监控容器运行状态并汇报给Kubernetes API Server。

#### `Kubernetes Proxy`

`负责为Pod创建代理服务`，Kubernetes Proxy会从Kubernetes API  Server获取所有的Service信息，并根据Service的信息创建代理服务，实现Service到Pod的请求路由和转发，从而实现Kubernetes层级的虚拟转发网络。

#### `Docker Engine`（docker）

Docker引擎，负责本机的容器创建和管理工作；  

### 数据库

etcd数据库，可以部署到master上，也可以独立部署。分布式键值存储系统。用于保存集群状态数据，比如Pod、Service等对象信息。

> docker只是k8s支持的底层容器的一种，k8s还支持另外一种容器技术，名为rocket。  
>

# 常用镜像仓库

daocloud的docker镜像库:daocloud.io/library

docker-hub的k8s镜像库：mirrorgooglecontainer

aliyun的k8s镜像库：registry.cn-hangzhou.aliyuncs.com/google-container 

aliyun的docker镜像库web页面：
  https://cr.console.aliyun.com/cn-hangzhou/images 

google的镜像库web页面：
  https://console.cloud.google.com/gcr/images/google-containers?project=google-containers

# Kubernetes集群部署方式

方式1. minikube
Minikube是一个工具，可以在本地快速运行一个单点的Kubernetes，尝试Kubernetes或日常开发的用户使用。不能用于生产环境。
官方地址：https://kubernetes.io/docs/setup/minikube/

方式2. kubeadm
Kubeadm也是一个工具，提供kubeadm init和kubeadm join，用于快速部署Kubernetes集群。
官方地址：https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/

方式3. 直接使用epel-release yum源，缺点就是版本较低 1.5

方式4. 二进制包
从官方下载发行版的二进制包，手动部署每个组件，组成Kubernetes集群。
官方也提供了一个互动测试环境供大家测试：https://kubernetes.io/cn/docs/tutorials/kubernetes-basics/cluster-interactive/

# 二进制方式部署k8s集群

目标任务：

1、Kubernetes集群部署架构规划

2、部署Etcd集群

3、在Node节点安装Docker

4、部署Flannel网络

5、在Master节点部署组件

6、在Node节点部署组件

7、查看集群状态

8、运行一个测试示例

9、部署Dashboard（Web UI）

 

1、Kubernetes集群部署架构规划

操作系统：

```shell
CentOS7.6_x64
```

软件版本：

```
Docker	18.09.0-ce
Kubernetes	1.11
```

服务器角色、IP、组件：

```
 k8s-master1	   
10.206.240.188	kube-apiserver，kube-controller-manager，kube-scheduler，etcd
```

```
  k8s-master2	   
10.206.240.189	kube-apiserver，kube-controller-manager，kube-scheduler，etcd
```

```
 k8s-node1	    
10.206.240.111	kubelet，kube-proxy，docker，flannel，etcd 
```

```
 k8s-node2	    
10.206.240.112	kubelet，kube-proxy，docker，flanne
```

  Master负载均衡	 

```
10.206.176.19	  LV
```

  镜像仓库	       

```
10.206.240.188	Harbo
```

机器配置要求：

>   2G  
>
>   主机名称 必须改必须解析
>
>   selinux  firewalld  都要关
>

拓扑图：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsUo4b4j.jpg) 

负载均衡器：

  云环境：

​    可以采用slb

  非云环境：

​    主流的软件负载均衡器，例如LVS、HAProxy、Nginx

​    

这里采用Nginx作为apiserver负载均衡器，架构图如下： 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps0oWEjH.jpg) 

 

2. 安装nginx使用stream模块作4层反向代理配置如下：

```shell
user  nginx;
worker_processes  4;
error_log  /var/log/nginx/error.log warn;
pid     /var/run/nginx.pid;
events {
  worker_connections  1024;
} 

stream { 
  log_format  main  '$remote_addr $upstream_addr - [$time_local] $status $upstream_bytes_sent';
  access_log  /var/log/nginx/k8s-access.log  main;
  upstream k8s-apiserver {
server 10.206.240.188:6443;
server 10.206.240.189:6443;
  }
  server {
 listen 6443;
 proxy_pass k8s-apiserver;
  }
}
```

3. 部署Etcd集群

使用cfssl来生成自签证书,任何机器都行，证书这块儿知道怎么生成、怎么用即可，暂且不用过多研究。

下载cfssl工具：(放入一个文件中（a.txt）bash a.txt)

```shell
 wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64

wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64

chmod +x cfssl_linux-amd64 cfssljson_linux-amd64 cfssl-certinfo_linux-amd64

mv cfssl_linux-amd64 /usr/local/bin/cfssl

mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

mv cfssl-certinfo_linux-amd64 /usr/bin/cfssl-certinfo
```

生成Etcd证书:

创建以下三个文件：(这些文件末尾不能有多余的空格)

\# cat ca-config.json 

```
{
 "signing": {
  "default": {
   "expiry": "87600h"
  },
  "profiles": {
   "www": {
	"expiry": "87600h",
	"usages": [
	 "signing",
	 "key encipherment",
 	"server auth",
 	"client auth"
 ]
   }
  }
 }
} 
```

\# cat ca-csr.json

```
{
  "CN": "etcd CA",
  "key": {
	 "algo": "rsa",
	 "size": 2048
  },
  "names": [
 {
	 "C": "CN",
	 "L": "Beijing",
	"ST": "Beijing"
    }
  ]
} 
```

\# cat server-csr.json

```
{
  "CN": "etcd",
  "hosts": [
  "10.206.240.188",
  "10.206.240.189",
  "10.206.240.111"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "BeiJing",
      "ST": "BeiJing"
    }
  ]
}
```

 

生成证书：

```
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=www server-csr.json | cfssljson -bare server

ls *pem

ca-key.pem  ca.pem  server-key.pem  server.pem
```

 

安装Etcd:

二进制包下载地址：

  https://github.com/coreos/etcd/releases/tag/v3.2.12

  

以下部署步骤在规划的三个etcd节点操作一样，唯一不同的是etcd配置文件中的服务器IP要写当前的：

解压二进制包：

```
 mkdir /opt/etcd/{bin,cfg,ssl} -p

tar zxvf etcd-v3.2.12-linux-amd64.tar.gz

mv etcd-v3.2.12-linux-amd64/{etcd,etcdctl} /opt/etcd/bin/
```

 

创建etcd配置文件：

\# cat /opt/etcd/cfg/etcd  

```
#[Member]
ETCD_NAME="etcd01"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://10.206.240.189:2380"
ETCD_LISTEN_CLIENT_URLS="https://10.206.240.189:2379"
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://10.206.240.189:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://10.206.240.189:2379"
ETCD_INITIAL_CLUSTER="etcd01=https://10.206.240.189:2380,etcd02=https://10.206.240.188:2380,etcd03=https://10.206.240.111:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new" 
```

> \* ETCD_NAME 节点名称
>
> \* ETCD_DATA_DIR 数据目录
>
> \* ETCD_LISTEN_PEER_URLS 集群通信监听地址
>
> \* ETCD_LISTEN_CLIENT_URLS 客户端访问监听地址
>
> \* ETCD_INITIAL_ADVERTISE_PEER_URLS 集群通告地址
>
> \* ETCD_ADVERTISE_CLIENT_URLS 客户端通告地址
>
> \* ETCD_INITIAL_CLUSTER 集群节点地址
>
> \* ETCD_INITIAL_CLUSTER_TOKEN 集群Token
>
> \* ETCD_INITIAL_CLUSTER_STATE 加入集群的当前状态，new是新集群，existing表示加入已有集群
>

 

systemd管理etcd：

\# cat /usr/lib/systemd/system/etcd.service 

```
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=/opt/etcd/cfg/etcd
ExecStart=/opt/etcd/bin/etcd \
--name=${ETCD_NAME} \
--data-dir=${ETCD_DATA_DIR} \
--listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
--listen-client-urls=${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \
--advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
--initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
--initial-cluster=${ETCD_INITIAL_CLUSTER} \
--initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \
--initial-cluster-state=new \
--cert-file=/opt/etcd/ssl/server.pem \
--key-file=/opt/etcd/ssl/server-key.pem \
--peer-cert-file=/opt/etcd/ssl/server.pem \
--peer-key-file=/opt/etcd/ssl/server-key.pem \
--trusted-ca-file=/opt/etcd/ssl/ca.pem \
--peer-trusted-ca-file=/opt/etcd/ssl/ca.pem
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

 

把刚才生成的证书拷贝到配置文件中的位置：

```
 cp ca*pem server*pem /opt/etcd/ssl 
```

不要每台机器都用生成证书命令 把master的*pem文件烤到node上

启动并设置开启启动：

```
systemctl start etcd && systemctl enable etcd
```

 

都部署完成后，检查etcd集群状态：

```
# /opt/etcd/bin/etcdctl \
--ca-file=/opt/etcd/ssl/ca.pem --cert-file=/opt/etcd/ssl/server.pem --key-file=/opt/etcd/ssl/server-key.pem \
--endpoints= "https://10.206.240.189:2379, \
https://10.206.240.188:2379,https://10.206.240.111:2379" cluster-health

member 18218cfabd4e0dea is healthy: got healthy result from https://10.206.240.111:2379

member 541c1c40994c939b is healthy: got healthy result from https://10.206.240.189:2379

member a342ea2798d20705 is healthy: got healthy result from https://10.206.240.188:2379

cluster is healthy
```

如果输出上面信息，就说明集群部署成功。

如果有问题第一步先看日志：`/var/log/messages `或` journalctl -u etcd`

报错：

Jan 15 12:06:55 k8s-master1 etcd: request cluster ID mismatch (got 99f4702593c94f98 want cdf818194e3a8c32)

解决：因为集群搭建过程，单独启动过单一etcd,做为测试验证，集群内第一次启动其他etcd服务时候，是通过发现服务引导的，所以需要删除旧的成员信息，所有节点作以下操作

```
[root@k8s-master1 default.etcd]# pwd

/var/lib/etcd/default.etcd

[root@k8s-master1 default.etcd]# rm -rf member/
```

 

在Node节点安装Docker

```
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install docker-ce -y

 curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://bc437cce.m.daocloud.io

systemctl start docker

systemctl enable docker
```

 

## 部署Flannel网络

工作原理：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsqdumz4.jpg) 



Falnnel要用etcd存储自身一个子网信息，所以要保证能成功连接Etcd，写入预定义子网段：

Flannel划分一个大网段 172.17.0.0/16。

```
# /opt/etcd/bin/etcdctl \

--ca-file=ca.pem --cert-file=server.pem --key-file=server-key.pem \

--endpoints="https://10.206.240.189:2379, \
https://10.206.240.188:2379,https://10.206.240.111:2379" \

set /coreos.com/network/config  '{ "Network": "172.17.0.0/16", "Backend": {"Type": "vxlan"}}'
```

 以下部署步骤在规划的每个node节点都操作。

下载二进制包：

```
wget https://github.com/coreos/flannel/releases/download/v0.10.0/flannel-v0.10.0-linux-amd64.tar.gz

tar zxvf flannel-v0.10.0-linux-amd64.tar.gz

mkdir -pv /opt/kubernetes/bin

mv flanneld mk-docker-opts.sh /opt/kubernetes/bin
```

 

配置Flannel：

```
mkdir -pv /opt/kubernetes/cfg/

cat /opt/kubernetes/cfg/flanneld

FLANNEL_OPTIONS="--etcd-endpoints=https://10.206.240.189:2379,https://10.206.240.188:2379,https://10.206.240.111:2379 -etcd-cafile=/opt/etcd/ssl/ca.pem -etcd-certfile=/opt/etcd/ssl/server.pem -etcd-keyfile=/opt/etcd/ssl/server-key.pem"
```

 

systemd管理Flannel：

\# cat /usr/lib/systemd/system/flanneld.service

```
[Unit]
Description=Flanneld overlay address etcd agent
After=network-online.target network.target
Before=docker.service

[Service]
Type=notify
EnvironmentFile=/opt/kubernetes/cfg/flanneld
ExecStart=/opt/kubernetes/bin/flanneld --ip-masq $FLANNEL_OPTIONS
ExecStartPost=/opt/kubernetes/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/subnet.env
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

 

配置Docker启动指定子网段：

\# cat /usr/lib/systemd/system/docker.service 

```
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=/run/flannel/subnet.env
ExecStart=/usr/bin/dockerd $DOCKER_NETWORK_OPTIONS
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
```

 

从其他节点拷贝证书文件到node1和2上：因为node1和2上没有证书，但是flanel需要证书

```
mkdir -pv /opt/etcd/ssl/
scp /opt/etcd/ssl/*  k8s-node2:/opt/etcd/ssl/（俩步跳过）
```

 

重启flannel和docker：

```
systemctl daemon-reload
systemctl start flanneld
systemctl enable flanneld
systemctl restart docker
```

 

检查是否生效：

```
ps -ef | grep docker
```

root   20941   1  1 Jun28 ?     09:15:34 /usr/bin/dockerd --bip=172.17.34.1/24 --ip-masq=false --mtu=1450

```
 ip addr
```

3607: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN 

  link/ether 8a:2e:3d:09:dd:82 brd ff:ff:ff:ff:ff:ff

  inet 172.17.34.0/32 scope global flannel.1

​    valid_lft forever preferred_lft forever

3608: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP 

  link/ether 02:42:31:8f:d3:02 brd ff:ff:ff:ff:ff:ff

  inet 172.17.34.1/24 brd 172.17.34.255 scope global docker0

​    valid_lft forever preferred_lft forever

  inet6 fe80::42:31ff:fe8f:d302/64 scope link 

​    valid_lft forever preferred_lft forever

​    

注:

1.	确保docker0与flannel.1在同一网段。

2.	测试不同节点互通，在当前节点访问另一个Node节点docker0 IP：

```
 ping 172.17.58.1
```

如果能通说明Flannel部署成功。如果不通检查下日志：journalctl -u flannel

 

## 在Master节点部署组件

两个Master节点部署方式一样

 

在部署Kubernetes之前一定要确保etcd、flannel、docker是正常工作的，否则先解决问题再继续。

### 生成证书

创建CA证书：

\# cat ca-config.json

```
{
 "signing": {
  "default": {
   "expiry": "87600h"
  },
  "profiles": {
   "kubernetes": {
     "expiry": "87600h",
     "usages": [
      "signing",
      "key encipherment",
      "server auth",
      "client auth"
    ]
   }
  }
 }
}
```

 

\# cat ca-csr.json

```
{
  "CN": "kubernetes",
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
```

 

```
 cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
```

 

生成apiserver证书：

\# cat server-csr.json

```
{
  "CN": "kubernetes",
  "hosts": [
   "10.0.0.1",//这是后面dns要使用的虚拟网络的网关，不用改,就用这个切忌(注意注释前面的空格)
   "127.0.0.1",
   "10.206.176.19",
   "10.206.240.188",
   "10.206.240.189",
   "kubernetes",
   "kubernetes.default",
   "kubernetes.default.svc",
   "kubernetes.default.svc.cluster",
   "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "BeiJing",
      "ST": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
```

 

```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes server-csr.json | cfssljson -bare server
```

 

生成kube-proxy证书：

\# cat kube-proxy-csr.json

```
{
 "CN": "system:kube-proxy",
 "hosts": [],
 "key": {
  "algo": "rsa",
  "size": 2048
 },
 "names": [
  {
   "C": "CN",
   "L": "BeiJing",
   "ST": "BeiJing",
   "O": "k8s",
   "OU": "System"
  }
 ]
}
```

 

```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
```

 

最终生成以下证书文件：

```
# ls *pem

ca-key.pem  ca.pem  kube-proxy-key.pem  kube-proxy.pem  server-key.pem  server.pem
```

### 部署apiserver组件

下载二进制包：https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.11.md下载这个包（kubernetes-server-linux-amd64.tar.gz）就够了，包含了所需的所有组件。

 

```
mkdir /opt/kubernetes/{bin,cfg,ssl} -pv

tar zxvf kubernetes-server-linux-amd64.tar.gz

cd kubernetes/server/bin

cp kube-apiserver kube-scheduler kube-controller-manager kubectl /opt/kubernetes/bin
```

 

从生成证书的机器拷贝证书到master1,master2:

\#本地把证书拷贝到/opt/kebernetes/ssl/

```
scp server.pem  server-key.pem ca.pem ca-key.pem k8s-master1:/opt/kubernetes/ssl/

scp server.pem  server-key.pem ca.pem ca-key.pem k8s-master2:/opt/kubernetes/ssl/
```

 

创建token文件，后面会讲到：

/# cat /opt/kubernetes/cfg/token.csv

```
674c457d4dcf2eefe4920d7dbb6b0ddc,kubelet-bootstrap,10001,"system:kubelet-bootstrap"
```

第一列：随机字符串，自己可生成第二列：用户名第三列：UID第四列：用户组

 

创建apiserver配置文件：

\# cat /opt/kubernetes/cfg/kube-apiserver 

 

```
KUBE_APISERVER_OPTS="--logtostderr=true \
--v=4 --etcd-servers=https://10.206.240.189:2379, \
https://10.206.240.188:2379,https://10.206.240.111:2379 \

--bind-address=10.206.240.189 \

--secure-port=6443 \

--advertise-address=10.206.240.189 \

--allow-privileged=true \

--service-cluster-ip-range=10.0.0.0/24 \  //这里就用这个网段，切忌不要改

--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction \

--authorization-mode=RBAC,Node \

--enable-bootstrap-token-auth \

--token-auth-file=/opt/kubernetes/cfg/token.csv \

--service-node-port-range=30000-50000 \

--tls-cert-file=/opt/kubernetes/ssl/server.pem  \

--tls-private-key-file=/opt/kubernetes/ssl/server-key.pem \

--client-ca-file=/opt/kubernetes/ssl/ca.pem \

--service-account-key-file=/opt/kubernetes/ssl/ca-key.pem \

--etcd-cafile=/opt/etcd/ssl/ca.pem \

--etcd-certfile=/opt/etcd/ssl/server.pem \

--etcd-keyfile=/opt/etcd/ssl/server-key.pem"
```

配置好前面生成的证书，确保能连接etcd。

参数说明：

> \* --logtostderr 启用日志
>
> \* --v 日志等级
>
> \* --etcd-servers etcd集群地址
>
> \* --bind-address 监听地址
>
> \* --secure-port https安全端口
>
> \* --advertise-address 集群通告地址
>
> \* --allow-privileged 启用授权
>
> \* --service-cluster-ip-range Service虚拟IP地址段
>
> \* --enable-admission-plugins 准入控制模块
>
> \* --authorization-mode 认证授权，启用RBAC授权和节点自管理
>
> \* --enable-bootstrap-token-auth 启用TLS bootstrap功能，后面会讲到
>
> \* --token-auth-file token文件
>
> \* --service-node-port-range Service Node类型默认分配端口范围
>

systemd管理apiserver：

\# cat /usr/lib/systemd/system/kube-apiserver.service 

```
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
 
[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-apiserver
ExecStart=/opt/kubernetes/bin/kube-apiserver $KUBE_APISERVER_OPTS
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
```

 

启动：

```
systemctl daemon-reload
systemctl enable kube-apiserver
systemctl start kube-apiserver
```

 

### 部署schduler组件

创建schduler配置文件：

\# cat /opt/kubernetes/cfg/kube-scheduler 

 

```
KUBE_SCHEDULER_OPTS="--logtostderr=true \
--v=4 \
--master=127.0.0.1:8080 \
--leader-elect"
```

参数说明：

> \* --master 连接本地apiserver
>
> \* --leader-elect 当该组件启动多个时，自动选举（HA）
>

 

systemd管理schduler组件：

\# cat /usr/lib/systemd/system/kube-scheduler.service 

```
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-scheduler
ExecStart=/opt/kubernetes/bin/kube-scheduler $KUBE_SCHEDULER_OPTS
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
```

 

启动：

```
systemctl daemon-reload
systemctl enable kube-scheduler 
systemctl start kube-scheduler 
```

 

### 部署controller-manager组件

创建controller-manager配置文件：

\# cat /opt/kubernetes/cfg/kube-controller-manager 

```
KUBE_CONTROLLER_MANAGER_OPTS="--logtostderr=true \

--v=4 \

--master=127.0.0.1:8080 \

--leader-elect=true \

--address=127.0.0.1 \

--service-cluster-ip-range=10.0.0.0/24 \//这是后面dns要使用的虚拟网络，不用改，就用这个  切忌

--cluster-name=kubernetes \

--cluster-signing-cert-file=/opt/kubernetes/ssl/ca.pem \

--cluster-signing-key-file=/opt/kubernetes/ssl/ca-key.pem  \

--root-ca-file=/opt/kubernetes/ssl/ca.pem \

--service-account-private-key-file=/opt/kubernetes/ssl/ca-key.pem"
```

 

systemd管理controller-manager组件：

\# cat /usr/lib/systemd/system/kube-controller-manager.service 

```
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-controller-manager
ExecStart=/opt/kubernetes/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
```

 

启动：

```
systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl start kube-controller-manager
```

 

所有组件都已经启动成功，通过kubectl工具查看当前集群组件状态：

```
/opt/kubernetes/bin/kubectl get cs
```

NAME         STATUS   MESSAGE       ERROR

scheduler       Healthy  ok          

etcd-0        Healthy  {"health":"true"}  

etcd-2        Healthy  {"health":"true"}  

etcd-1        Healthy  {"health":"true"}  

controller-manager  Healthy  ok

如上输出说明组件都正常。

 

配置Master负载均衡

所谓的Master HA，其实就是APIServer的HA，Master的其他组件controller-manager、scheduler都是可以通过etcd做选举（--leader-elect），而APIServer设计的就是可扩展性，所以做到APIServer很容易，只要前面加一个负载均衡轮询转发请求即可。 在私有云平台添加一个内网四层LB，不对外提供服务，只做apiserver负载均衡，配置如下：

<img src="kubernets%E5%85%A8%E8%A7%A3.assets/wpsaDDrPr.jpg" alt="img" style="zoom:150%;" /> 

其他公有云LB配置大同小异，只要理解了数据流程就好配置了。

 

在Node节点部署组件

Master apiserver启用TLS认证后，Node节点kubelet组件想要加入集群，必须使用CA签发的有效证书才能与apiserver通信，当Node节点很多时，签署证书是一件很繁琐的事情，因此有了TLS Bootstrapping机制，kubelet会以一个低权限用户自动向apiserver申请证书，kubelet的证书由apiserver动态签署。

认证大致工作流程如图所示：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsF8Fy5O.jpg) 

 

----------------------下面这些操作在master节点完成：---------------------------

将kubelet-bootstrap用户绑定到系统集群角色

```
/opt/kubernetes/bin/kubectl create clusterrolebinding kubelet-bootstrap \

 --clusterrole=system:node-bootstrapper \

 --user=kubelet-bootstrap
```

 

创建kubeconfig文件:

在生成kubernetes证书的目录下执行以下命令生成kubeconfig文件：

 

指定apiserver 内网负载均衡地址

\# KUBE_APISERVER="https://10.206.176.19:6443" 本机ip

\# BOOTSTRAP_TOKEN=674c457d4dcf2eefe4920d7dbb6b0ddc

 

\# 设置集群参数

```
/opt/kubernetes/bin/kubectl config set-cluster kubernetes \

 --certificate-authority=./ca.pem \

 --embed-certs=true \

 --server=${KUBE_APISERVER} \

 --kubeconfig=bootstrap.kubeconfig
```

 

\# 设置客户端认证参数

```
/opt/kubernetes/bin/kubectl config set-credentials kubelet-bootstrap \

 --token=${BOOTSTRAP_TOKEN} \

 --kubeconfig=bootstrap.kubeconfig
```

 

\# 设置上下文参数

```
/opt/kubernetes/bin/kubectl config set-context default \

 --cluster=kubernetes \

 --user=kubelet-bootstrap \

 --kubeconfig=bootstrap.kubeconfig
```

 

\# 设置默认上下文

```
/opt/kubernetes/bin/kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
```

\# 创建kube-proxy kubeconfig文件

```
/opt/kubernetes/bin/kubectl config set-cluster kubernetes \

 --certificate-authority=./ca.pem \

 --embed-certs=true \

 --server=${KUBE_APISERVER} \

 --kubeconfig=kube-proxy.kubeconfig
```

 

```
/opt/kubernetes/bin/kubectl config set-credentials kube-proxy \

 --client-certificate=./kube-proxy.pem \

 --client-key=./kube-proxy-key.pem \

 --embed-certs=true \

 --kubeconfig=kube-proxy.kubeconfig
```

 

```
/opt/kubernetes/bin/kubectl config set-context default \

 --cluster=kubernetes \

 --user=kube-proxy \

 --kubeconfig=kube-proxy.kubeconfig
```

 

```
/opt/kubernetes/bin/kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
```

 

```
# ls

bootstrap.kubeconfig  kube-proxy.kubeconfig
```

必看：将这两个文件拷贝到Node节点/opt/kubernetes/cfg目录下。

 

----------------------下面这些操作在node节点完成：---------------------------

## 部署kubelet组件

将前面下载的二进制包中的kubelet和kube-proxy拷贝到/opt/kubernetes/bin目录下。

创建kubelet配置文件：

\# vim /opt/kubernetes/cfg/kubelet

```
KUBELET_OPTS="--logtostderr=true \

--v=4 \

--hostname-override=10.206.240.112 \

--kubeconfig=/opt/kubernetes/cfg/kubelet.kubeconfig \

--bootstrap-kubeconfig=/opt/kubernetes/cfg/bootstrap.kubeconfig \

--config=/opt/kubernetes/cfg/kubelet.config \

--cert-dir=/opt/kubernetes/ssl \

--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0"
```

 

参数说明：

> \* --hostname-override 在集群中显示的主机名
>
> \* --kubeconfig 指定kubeconfig文件位置，会自动生成
>
> \* --bootstrap-kubeconfig 指定刚才生成的bootstrap.kubeconfig文件
>
> \* --cert-dir 颁发证书存放位置
>
> \* --pod-infra-container-image 管理Pod网络的镜像
>

 

其中/opt/kubernetes/cfg/kubelet.config配置文件如下：

\# vim /opt/kubernetes/cfg/kubelet.config

```
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
address: 10.206.240.112
port: 10250
readOnlyPort: 10255
cgroupDriver: cgroupfs
clusterDNS: ["10.0.0.2"]//不要改，就是这个ip
clusterDomain: cluster.local.
failSwapOn: false
authentication:
 anonymous:
  enabled: true 
 webhook:
  enabled: false
```

 

systemd管理kubelet组件：

\# vim /usr/lib/systemd/system/kubelet.service 

```
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service
 
[Service]
EnvironmentFile=/opt/kubernetes/cfg/kubelet
ExecStart=/opt/kubernetes/bin/kubelet $KUBELET_OPTS
Restart=on-failure
KillMode=process
 
[Install]
WantedBy=multi-user.target
```

 

启动：

```
systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet
```

 

在Master审批Node加入集群：

启动后还没加入到集群中，需要手动允许该节点才可以。在Master节点查看请求签名的Node：

```
/opt/kubernetes/bin/kubectl get csr
 /opt/kubernetes/bin/kubectl certificate approve XXXXID
 /opt/kubernetes/bin/kubectl get node
```

 

## 部署kube-proxy组件

创建kube-proxy配置文件：

\# cat /opt/kubernetes/cfg/kube-proxy

```
KUBE_PROXY_OPTS="--logtostderr=true \

--v=4 \

--hostname-override=10.206.240.111 \

--cluster-cidr=10.0.0.0/24 \//不要改，就是这个ip

--kubeconfig=/opt/kubernetes/cfg/kube-proxy.kubeconfig"
```

 

systemd管理kube-proxy组件：

\# cat /usr/lib/systemd/system/kube-proxy.service 

```
[Unit]
Description=Kubernetes Proxy
After=network.target
 
[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-proxy
ExecStart=/opt/kubernetes/bin/kube-proxy $KUBE_PROXY_OPTS
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
```

 

启动：

```
systemctl daemon-reload
systemctl enable kube-proxy
systemctl start kube-proxy
```

 

查看集群状态

```
 /opt/kubernetes/bin/kubectl get node
```

NAME       STATUS   ROLES   AGE    VERSION

10.206.240.111  Ready   <none>   28d    v1.11.0

10.206.240.112  Ready   <none>   28d    v1.11.0

 

```
/opt/kubernetes/bin/kubectl get cs
```

NAME            STATUS  MESSAGE       ERROR

controller-manager  		Healthy   ok          

scheduler         	Healthy   ok          

etcd-2            Healthy   {"health":"true"}  

etcd-1            Healthy   {"health":"true"}  

etcd-0            Healthy   {"health":"true"}

 

运行一个测试示例

创建一个Nginx Web，判断集群是否正常工作：

```
 /opt/kubernetes/bin/kubectl run nginx --image=nginx --replicas=3

/opt/kubernetes/bin/kubectl expose deployment nginx --port=88 --target-port=80 --type=NodePort
```

 

查看Pod，Service：

```
/opt/kubernetes/bin/kubectl get pods
```

NAME                 READY   STATUS   RESTARTS  AGE

nginx-64f497f8fd-fjgt2      1/1    Running  3      28d

nginx-64f497f8fd-gmstq     1/1    Running  3       28d

nginx-64f497f8fd-q6wk9     1/1    Running  3       28d

 

查看pod详细信息：

```
/opt/kubernetes/bin/kubectl describe pod nginx-64f497f8fd-fjgt2 
```

 

```
/opt/kubernetes/bin/kubectl get svc
```

NAME     TYPE     CLUSTER-IP  EXTERNAL-IP  PORT(S)             AGE

kubernetes   ClusterIP   10.0.0.1   <none>     443/TCP             28d

nginx      NodePort   10.0.0.175  <none>     88:38696/TCP          28d

 

打开浏览器输入：http://10.206.240.111:38696

 

部署Dashboard（Web UI）

部署UI有三个文件：

> \* dashboard-deployment.yaml   	// 部署Pod，提供Web服务
>
> \* dashboard-rbac.yaml         // 授权访问apiserver获取信息
>
> \* dashboard-service.yaml       // 发布服务，提供对外访问
>

 

\# cat dashboard-deployment.yaml

```
apiVersion: apps/v1beta2
kind: Deployment
metadata:
 name: kubernetes-dashboard
 namespace: kube-system
 labels:
  k8s-app: kubernetes-dashboard
  kubernetes.io/cluster-service: "true"
  addonmanager.kubernetes.io/mode: Reconcile
spec:
 selector:
  matchLabels:
   k8s-app: kubernetes-dashboard
 template:
  metadata:
   labels:
     k8s-app: kubernetes-dashboard
   annotations:
     scheduler.alpha.kubernetes.io/critical-pod: ''
  spec:
   serviceAccountName: kubernetes-dashboard
   containers:
   - name: kubernetes-dashboard
    image: registry.cn-hangzhou.aliyuncs.com/kube_containers/kubernetes-dashboard-amd64:v1.8.1 
    resources:
     limits:
      cpu: 100m
      memory: 300Mi
     requests:
      cpu: 100m
      memory: 100Mi
    ports:
    - containerPort: 9090
     protocol: TCP
    livenessProbe:
     httpGet:
      scheme: HTTP
      path: /
      port: 9090
     initialDelaySeconds: 30
     timeoutSeconds: 30
   tolerations:
   - key: "CriticalAddonsOnly"
    operator: "Exists"
```

​    

\# cat dashboard-rbac.yaml

```
apiVersion: v1
kind: ServiceAccount
metadata:
 labels:
  k8s-app: kubernetes-dashboard
  addonmanager.kubernetes.io/mode: Reconcile
 name: kubernetes-dashboard
 namespace: kube-system
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 name: kubernetes-dashboard-minimal
 namespace: kube-system
 labels:
  k8s-app: kubernetes-dashboard
  addonmanager.kubernetes.io/mode: Reconcile
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: ClusterRole
 name: cluster-admin
subjects:
 - kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
```

  

\# cat dashboard-service.yaml

```
apiVersion: v1
kind: Service
metadata:
 name: kubernetes-dashboard
 namespace: kube-system
 labels:
  k8s-app: kubernetes-dashboard
  kubernetes.io/cluster-service: "true"
  addonmanager.kubernetes.io/mode: Reconcile
spec:
 type: NodePort
 selector:
  k8s-app: kubernetes-dashboard
 ports:
 - port: 80
  targetPort: 9090
```

 

创建：

```
/opt/kubernetes/bin/kubectl create -f dashboard-rbac.yaml
/opt/kubernetes/bin/kubectl create -f dashboard-deployment.yaml
/opt/kubernetes/bin/kubectl create -f dashboard-service.yaml
```

 

等待数分钟，查看资源状态：

```
/opt/kubernetes/bin/kubectl get all -n kube-system
```

NAME                               READY    STATUS   RESTARTS  AGE

pod/kubernetes-dashboard-68ff5fcd99-5rtv7   1/1       Running  1         27d

 

NAME              TYPE     CLUSTER-IP  EXTERNAL-IP  PORT(S)     AGE

service/kubernetes-dashboard  NodePort   10.0.0.100  <none>     443:30000/TCP  27d

 

NAME                  DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE

deployment.apps/kubernetes-dashboard  1     1     1       1      27d

 

NAME                        DESIRED  CURRENT  READY   AGE

replicaset.apps/kubernetes-dashboard-68ff5fcd99  1     1     1     27d

 

查看访问端口：

```
/opt/kubernetes/bin/kubectl get svc -n kube-system 
```

NAME          TYPE     CLUSTER-IP  EXTERNAL-IP  PORT(S)     AGE

kubernetes-dashboard  NodePort   10.0.0.100  <none>     443:30000/TCP  27d

 

打开浏览器，输入：http://10.206.240.111:30000

 

===============================

\# /opt/kubernetes/bin/kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

 

\# /opt/kubernetes/bin/kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

 

To access Dashboard from your local workstation you must create a  secure channel to your Kubernetes cluster. Run the following command:

$ kubectl proxy

 

Now access Dashboard at:

http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/.

 

# kubeadm方式部署k8s集群

官方文档：

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/（可能有更新）

 

kubeadm部署k8s高可用集群的官方文档：

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/（可能有更新）

## 获取镜像

在docker hub拉取相应的镜像并重新打标： 

### 1.6.1版本更新 

(打标时要根据要求)

```
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.16.1

docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.16.1 k8s.gcr.io/kube-apiserver:v1.16.1

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.16.1

docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.16.1 k8s.gcr.io/kube-proxy:v1.16.1

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.16.1

docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.16.1 k8s.gcr.io/kube-controller-manager:v1.16.1

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.16.1

docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.16.1 k8s.gcr.io/kube-scheduler:v1.16.1

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.15

docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.15 k8s.gcr.io/etcd:3.3.15-0

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1

docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.6.2

docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.6.2 k8s.gcr.io/coredns:1.6.2

docker pull quay-mirror.qiniu.com/coreos/flannel:v0.11.0-amd64
```

 

registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.1

## 完整安装过程

 系统配置

关闭防火墙：

```
systemctl stop firewalld

systemctl disable firewalld 
```

禁用SELinux：

```
setenforce 0
```

编辑文件/etc/selinux/config，将SELINUX修改为disabled，如下：

```
sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/sysconfig/selinux 
```

关闭系统Swap：1.8之后的新规定

Kubernetes 1.8开始要求关闭系统的Swap，如果不关闭，默认配置下kubelet将无法启动。

方法一,通过kubelet的启动参数–fail-swap-on=false更改这个限制。

方法二,关闭系统的Swap。

`swapoff -a`

修改`/etc/fstab`文件，注释掉SWAP的自动挂载，使用free -m确认swap已经关闭。

注释掉swap分区：

```
sed -i 's/.*swap.*/#&/' /etc/fstab
swapoff -a 刷新一下swap分区，不然改了之后不生效
```

\#/dev/mapper/centos-swap swap           swap   defaults     0 0                           

```
[root@centos708 ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:            990          81         820           6          89         791
Swap:             0           0           0
```

安装docker：

```
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum makecache fast
 yum -y install docker-ce
systemctl enable docker.service
systemctl start docker
```

我这里安装的是docker-ce 18.09

使用kubeadm部署Kubernetes:

安装kubeadm和kubelet

在所有节点安装kubeadm和kubelet：

配置源

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo

[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg

EOF
```

安装

```
yum makecache fast -y
yum install -y kubelet kubeadm kubectl ipvsadm
```

配置：

`配置转发相关参数`，否则可能会出错

```
cat <<EOF >  /etc/sysctl.d/k8s.conf

net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0

EOF
```

使配置生效

```
 sysctl --system
```

如果net.bridge.bridge-nf-call-iptables报错，加载`br_netfilter模块`

```
modprobe br_netfilter

sysctl -p /etc/sysctl.d/k8s.conf
```

 

`加载ipvs相关内核模块`

如果重新开机，需要重新加载（可以写在 /etc/rc.local 中开机自动加载）

```
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack_ipv4
```

查看是否加载成功

```
lsmod | grep ip_vs
```

 

配置启动kubelet（所有节点）

配置kubelet使用国内pause镜像

获取docker的cgroups

```
DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f4)

 echo $DOCKER_CGROUPS

cgroups（只有显示cgroups才算成功，如果不是需要调整上面的shell）
```

 

配置kubelet的cgroups

```
cat >/etc/sysconfig/kubelet<<EOF
DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f4)
KUBELET_EXTRA_ARGS="--cgroup-driver=$DOCKER_CGROUPS --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1"

EOF
（改镜像）
```

 

如果使用谷歌的镜像：

```
cat >/etc/sysconfig/kubelet<<EOF

KUBELET_EXTRA_ARGS="--cgroup-driver=$DOCKER_CGROUPS --pod-infra-container-image=k8s.gcr.io/pause:3.1"

EOF
```

k8s.gcr.io/pause:3.1

 

启动

```
systemctl daemon-reload

systemctl enable kubelet && systemctl start kubelet
```

在这里使用systemctl status kubelet，你会发现报错误信息；

 

10月 11 00:26:43 node1 systemd[1]: kubelet.service: main process exited, code=exited, status=255/n/a

10月 11 00:26:43 node1 systemd[1]: Unit kubelet.service entered failed state.

10月 11 00:26:43 node1 systemd[1]: kubelet.service failed.

 

运行journalctl -xefu kubelet 命令查看systemd日志才发现，真正的错误是：

  unable to load client CA file /etc/kubernetes/pki/ca.crt: open /etc/kubernetes/pki/ca.crt: no such file or directory

这个错误在运行kubeadm init 生成CA证书后会被自动解决，此处可先忽略。

简单地说就是在kubeadm init 之前kubelet会不断重启。

配置master节点

运行初始化过程如下：

```
kubeadm init --kubernetes-version=v1.16.1 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.122.107 --ignore-preflight-errors=Swap 
```

我的结果

```
kubeadm join 192.168.122.107:6443 --token qi4auq.jaiwd7v2l734s2da \
    --discovery-token-ca-cert-hash sha256:8e49b26ed49978ee68e3fda24e0abf8973d519d80c27203435e61ec435408aff 
    后面往集群中添加节点用
```

上面记录了完成的初始化输出的内容，根据输出的内容基本上可以看出手动初始化安装一个Kubernetes集群所需要的关键步骤。

> kubeadm init 结束时会自动产生节点加入的命令，最好记下来。
>
> 如果忘了，可以使用kubeadm token create --print-join-command 方法重新生成链接Token并打印输出加入命令。网上搜了好久，终于发现这个方法，不过要1.9以后的版本才支持的，如果不支持这个参数，整个集群的Kubeadm版本都需要升级到新版本。

其中有以下关键内容：

  [kubelet] 生成kubelet的配置文件”/var/lib/kubelet/config.yaml”

  [certificates]生成相关的各种证书

  [kubeconfig]生成相关的kubeconfig文件

  [bootstraptoken]生成token记录下来，后边使用kubeadm join往集群中添加节点时会用到

 

配置使用kubectl

如下操作在master节点操作

```
rm -rf $HOME/.kube

mkdir -p $HOME/.kube

cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

chown $(id -u):$(id -g) $HOME/.kube/config
```

 

查看node节点

```
kubectl get nodes
```

NAME   STATUS   ROLES   AGE   VERSION

master  NotReady  master  6m19s  v1.13.0

 

配置使用网络插件

在master节点操作

下载配置

```
cd ~ && mkdir flannel && cd flannel

wget  https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

修改配置文件kube-flannel.yml:

此处的ip配置要与上面kubeadm的pod-network一致，本来就一致，不用改

\#vim kube-flannel.yml

```
net-conf.json: |

  {

   "Network": "10.244.0.0/16",

   "Backend": {

    "Type": "vxlan"

   }

  }
```

 

\# 默认的镜像是quay.io/coreos/flannel:v0.10.0-amd64，如果你能pull下来就不用修改镜像地址，否则，修改yml中镜像地址为阿里镜像源

```
image: registry.cn-shanghai.aliyuncs.com/gcr-k8s/flannel:v0.10.0-amd64
```

\# 如果Node有多个网卡的话，参考flannel issues 39701，

\# https://github.com/kubernetes/kubernetes/issues/39701

\# 目前需要在kube-flannel.yml中使用--iface参数指定集群主机内网网卡的名称，

\# 否则可能会出现dns无法解析。容器无法通信的情况，需要将kube-flannel.yml下载到本地，

\# flanneld启动参数加上--iface=<iface-name>

  

```
containers:

   - name: kube-flannel

    image: registry.cn-shanghai.aliyuncs.com/gcr-k8s/flannel:v0.10.0-amd64

    command:

    - /opt/bin/flanneld

    args:

    - --ip-masq

    - --kube-subnet-mgr

    - --iface=ens33 有几个网卡就写几个

    - --iface=eth0
```

​    

⚠--iface=ens33 的值，是你当前的网卡,或者可以指定多网卡

 

\# 1.12版本的kubeadm额外给node1节点设置了一个污点(Taint)：node.kubernetes.io/not-ready:NoSchedule，

\# 很容易理解，即如果节点还没有ready之前，是不接受调度的。可是如果Kubernetes的网络插件还没有部署的话，节点是不会进入ready状态的。

\# 因此修改以下kube-flannel.yaml的内容，加入对node.kubernetes.io/not-ready:NoSchedule这个污点的容忍：

  

```
tolerations:

   - key: node-role.kubernetes.io/master

    operator: Exists

    effect: NoSchedule

   - key: node.kubernetes.io/not-ready

    operator: Exists

    effect: NoSchedule
```

启动：

```
kubectl apply -f ~/flannel/kube-flannel.yml 
```

查看：

```
kubectl get pods --namespace kube-system

kubectl get service

kubectl get svc --namespace kube-system
```

只有网络插件也安装配置完成之后，才能会显示为ready状态

 

配置node节点加入集群：

在所有node节点操作，此命令为初始化master成功后返回的结果

```
kubeadm join 192.168.122.107:6443 --token kpk7cy.kmge7vj2wwr91n27     --discovery-token-ca-cert-hash sha256:8e49b26ed49978ee68e3fda24e0abf8973d519d80c27203435e61ec435408aff 
```

各种检测：

查看pods:

```
[root@centos708 flannel]# kubectl get pod -n kube-system
NAME                                READY   STATUS    RESTARTS   AGE
coredns-5644d7b6d9-85hvf            1/1     Running   0          17m
coredns-5644d7b6d9-hpbgr            1/1     Running   0          17m
etcd-centos708                      1/1     Running   0          17m
kube-apiserver-centos708            1/1     Running   0          17m
kube-controller-manager-centos708   1/1     Running   0          16m
kube-flannel-ds-amd64-h42b9         1/1     Running   0          25s
kube-flannel-ds-amd64-l2gbd         1/1     Running   0          29s
kube-flannel-ds-amd64-v6lrp         1/1     Running   0          2m30s
kube-proxy-bl44r                    1/1     Running   0          25s
kube-proxy-njxcd                    1/1     Running   0          29s
kube-proxy-w8tlt                    1/1     Running   0          17m
kube-scheduler-centos708            1/1     Running   0          16m

```

此处报错 先看主机名称 和 镜像是否改名

查看异常pod信息：

```
kubectl  describe pods kube-flannel-ds-sr6tq -n  kube-syste
```

遇到这种情况直接 删除异常pod:

```
 kubectl delete pod kube-flannel-ds-sr6tq -n kube-system
```

pod "kube-flannel-ds-sr6tq" deleted

 

```
kubectl get pods -n kube-syste
```

查看节点：

```
[root@centos708 ~]# kubectl get nodes -n kube-system
NAME        STATUS   ROLES    AGE   VERSION
centos708   Ready    master   21h   v1.16.3
centos709   Ready    <none>   21h   v1.16.3
centos710   Ready    <none>   21h   v1.16.3
```

 到此集群配置完成，接下来是部署应用测试

 

创建一个包含nginx服务的pod并运行:

[root@master /]# kubectl run nginx-test --image=daocloud.io/library/nginx --port=80 --replicas=1

kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.

deployment.apps/nginx-test created

 

根据提示：上面的方式将要废弃，使用新方法创建如下

```
[root@centos708 ~]# kubectl run --generator=run-pod/v1 nginx-test --image=daocloud.io/library/nginx --port=80 --replicas=1
pod/nginx-test created
```

查看创建的pod：

```
[root@centos708 ~]# kubectl get pods
NAME         READY   STATUS    RESTARTS   AGE
nginx-test   1/1     Running   0          44s
```

查看创建的deployment:旧方式默认直接创建deployment,新方式是直接创建Pod

```
[root@master /]# kubectl get deployment 这是就方式一创建的结果
```

NAME     READY  UP-TO-DATE  AVAILABLE  AGE

nginx-test  1/1   1       1      3m31s

 

创建完成后查看详细信息，获取nginx所在pod的内部IP地址：

```
[root@centos708 ~]# kubectl get pods -o wide
NAME         READY   STATUS    RESTARTS   AGE     IP           NODE        NOMINATED NODE   READINESS GATES
nginx-test   1/1     Running   0          2m44s   10.244.2.2   centos710   <none>           <none>
```

在kubernetes集群内`任意节点`访问该nginx服务：

```
[root@master ~]# curl 10.244.1.2
```

创建与管理service:

 将pod创建完成后，访问该pod内的服务只能在集群内部通过pod的的地址去访问该服务；当该pod出现故障后，该pod的控制器会重新创建一个包括该服务的pod,此时访问该服务须要获取该服务所在的新的pod的地址去访问。对此，可以创建一个service，当新的pod的创建完成后，service会通过pod的label连接到该服务，只需通过service即可访问该服务。

\#删除当前的pod:

```
[root@centos708 ~]# kubectl delete pod nginx-test
pod "nginx-test" deleted
```


\# 删除pod后，查看pod信息时发现有创建了一个新的pod

```
[root@master ~]# kubectl get pods -o wide
NAME              READY  STATUS   RESTARTS  AGE  IP      NODE   NOMINATED NODE  READINESS GATES
nginx-test-7fd67d86fd-lq282  1/1   Running  0      10s  10.244.1.3  node1  <none>      <none>
nginx-test1          1/1   Running  0      13m  10.244.1.2  node1  <none>      <none>
```

\# 创建service,并将包含nginx-test的标签加入进来

service的创建是通过`kubectl expose`命令来创建。该命令的具体用法可以通过” kubectl expose --help”查看。Service创建完成后，通过service地址访问pod中的服务依然只能通过集群内部的地址去访问。

```
kubectl expose deployment nginx-test --name=nginx --port=80 --target-port=80 --protocol=TCP
```
service/nginx exposed


\# 查看创建的service

```
[root@centos708 ~]# kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP   22h
nginx        ClusterIP   10.106.117.241   <none>        80/TCP    8s
```


\# 此时就可以直接通过service地址访问nginx，pod被删除重新创建后，依然可以通过service访问pod中的服务。

```
 curl 10.110.225.133 
```

\# 通过service的名称去访问该service下的pod中的服务

Service被创建后，通过service的名称去访问该service下的pod中的服务，但前提是，需要配置dns地址为core dns服务的地址；新建的pod中的DNS的地址为都为core DNS的地址；可以新建一个pod客户端完成测试。

\# 查看coredns的地址
```
[root@centos708 ~]# kubectl get svc -n kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   22h
```

\# 新建一个pod客户端

```
[root@centos708 ~]#  kubectl run  --generator=run-pod/v1 dig --rm -it --image=docker.io/azukiapp/dig /bin/sh
```

\# 查看pod中容器的dns地址

```
/ # cat /etc/resolv.conf 
nameserver 10.96.0.10
```
\# 通过名称去访问service

```
/ # wget -O - -q nginx
```
不同的service选择不同的pod是通过pod标签来管理的，pod标签是在创建pod时指定的，service管理的标签也是在创建service时指定的。一个service管理的标签及pod的标签都可以通过命令查看。

\# 查看名称为nginx的service管理的标签以及其他信息

```
[root@centos708 ~]# kubectl describe svc nginx
Name:              nginx
Namespace:         default
Labels:            run=nginx-test
Annotations:       <none>
Selector:          run=nginx-test
Type:              ClusterIP
IP:                10.106.117.241
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.244.2.6:80
Session Affinity:  None
Events:            <none>
```

\# 查看pod的标签
```
[root@centos708 ~]# kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE    LABELS
nginx-test-598f5bbf68-vvgbt   1/1     Running   0          7m9s   pod-template-hash=598f5bbf68,run=nginx-test
```

`coredns服务对service名称的解析是实时的`，在service被重新创建后或者修改service的ip地址后，依然可以通过service名称访问pod中的服务。

\# 删除并重新创建一个名称为nginx的service

```
[root@centos708 ~]# kubectl delete svc nginx
service "nginx" deleted
```

```
[root@centos708 ~]# kubectl expose deployment nginx-test --name=nginx
service/nginx exposed
```

\# 获取新创建的service的IP地址

```
[root@centos708 ~]# kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   22h
nginx        ClusterIP   10.96.221.137   <none>        80/TCP    40s
```

## pod的扩展与缩减

 Pod创建完成后，当服务的访问量过大时，可以对pod的进行扩展让pod中的服务处理更多的请求；当访问量减小时，可以缩减pod数量，以节约资源。 这些操作都可以在线完成，并不会影响现有的服务。

### 扩展pod数量

```
[root@centos708 ~]# kubectl scale --replicas=5 deployment nginx-test
deployment.apps/nginx-test scaled
```

\# 查看扩展后的pod

```
[root@centos708 ~]# kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
nginx-test-598f5bbf68-57rb8   1/1     Running   0          30s
nginx-test-598f5bbf68-hn5hr   1/1     Running   0          30s
nginx-test-598f5bbf68-vvgbt   1/1     Running   0          11m
nginx-test-598f5bbf68-z2zqh   1/1     Running   0          30s
nginx-test-598f5bbf68-zx7kj   1/1     Running   0          30s
```

\# 缩减pod的数量为2个

```
[root@centos708 ~]# kubectl scale --replicas=2 deployment nginx-test
deployment.apps/nginx-test scaled
```

## 服务的在线升级与回滚

在kubernetes服务中部署完服务后，对服务的升级可以在线完成，升级出问题后，也可以在线完成回滚。

\# 查看pod的名称及pod详细信息

```
[root@centos708 ~]# kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
nginx-test-598f5bbf68-vvgbt   1/1     Running   0          13m
nginx-test-598f5bbf68-zx7kj   1/1     Running   0          110s
```

\# 查看pod详细信息

```
[root@centos708 ~]# kubectl describe pods nginx-test-598f5bbf68-vvgbt
```


\# 为了验证更加明显，更新时将nginx替换为httpd服务

```
[root@centos708 ~]# kubectl set image deployment nginx-test nginx-test=httpd:2.4-alpine
deployment.apps/nginx-test image updated
```

\# 实时查看更新过程

```
[root@centos708 ~]# kubectl get deployment -w
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
nginx-test   2/2     2            2           15m
```

\# 更新完成后在客户端验证

```
/ # wget -O - -q nginx
```

\# 通过kubernetes节点验证

```
~]# curl 10.98.192.150
```

\# 更新后回滚为原来的nginx

```
[root@centos708 ~]# kubectl rollout undo deployment nginx-test
deployment.apps/nginx-test rolled back
```

\# 实时查看回滚的进度

```
[root@centos708 ~]# kubectl get deployment -w
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
nginx-test   2/2     1            2           17m
nginx-test   3/2     1            3           17m
nginx-test   2/2     2            2           17m
nginx-test   3/2     2            3           17m
nginx-test   2/2     2            2           17m 
```

\# 回滚完成后验证

```
~]# curl 10.98.192.150
```

让节点外部客户能够通过service访问pod中服务
创建好pod及service后，无论是通过pod地址及service地址在集群外部都无法访问pod中的服务；如果想要在集群外部访问pod中的服务，需要修改service的类型为NodePort，修改后会自动在ipvs中添加nat规则，此时就可以通过node节点地址访问pod中的服务。

\# 编辑配置文件

```
~]# kubectl edit svc nginx
```

```
spec:

 clusterIP: 10.98.192.150

 ports:

 - port: 80

  protocol: TCP

  targetPort: 80

 selector:

  run: nginx-test

 sessionAffinity: None

 type: NodePort    将CLusterIP改成NodePort
```

\# 配置完成后查看node节点监听的端口

```
[root@centos708 ~]# netstat -lntp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      1185/master         
tcp        0      0 127.0.0.1:10248         0.0.0.0:*               LISTEN      722/kubelet         
tcp        0      0 127.0.0.1:10249         0.0.0.0:*               LISTEN      3619/kube-proxy     
tcp        0      0 192.168.122.107:2379    0.0.0.0:*               LISTEN      2591/etcd           
tcp        0      0 127.0.0.1:2379          0.0.0.0:*               LISTEN      2591/etcd           
tcp        0      0 192.168.122.107:2380    0.0.0.0:*               LISTEN      2591/etcd           
tcp        0      0 127.0.0.1:2381          0.0.0.0:*               LISTEN      2591/etcd           
tcp        0      0 127.0.0.1:10257         0.0.0.0:*               LISTEN      2756/kube-controlle 
tcp        0      0 127.0.0.1:42482         0.0.0.0:*               LISTEN      722/kubelet         
tcp        0      0 127.0.0.1:10259         0.0.0.0:*               LISTEN      2683/kube-scheduler 
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      980/sshd            
tcp6       0      0 ::1:25                  :::*                    LISTEN      1185/master         
tcp6       0      0 :::31166                :::*                    LISTEN      3619/kube-proxy     
tcp6       0      0 :::10250                :::*                    LISTEN      722/kubelet         
tcp6       0      0 :::6443                 :::*                    LISTEN      2567/kube-apiserver 
tcp6       0      0 :::10251                :::*                    LISTEN      2683/kube-scheduler 
tcp6       0      0 :::10252                :::*                    LISTEN      2756/kube-controlle 
tcp6       0      0 :::10256                :::*                    LISTEN      3619/kube-proxy     
tcp6       0      0 :::22                   :::*                    LISTEN      980/sshd            
```
修改完配置后，查看node节点监听的端口发现多了3619端口，在外部可以通过node节点的地址及该端口访问pod内的服务。

## 关于kubeadm

kubeadm 是一位高中生的作品。他叫 Lucas Käldström，芬兰人，17 岁时用业余时间完成的一个社区项目。
kubeadm 的源代码，直接就在` kubernetes/cmd/kubeadm` 目录下，是 Kubernetes 项目的一部分。其中，app/phases 文件夹下的代码，对应的就是工作原理中详细介绍的每一个具体步骤。

两条指令完成一个 Kubernetes 集群的部署：

\# 创建一个 Master 节点

\# kubeadm init

\# 将一个 Node 节点加入到当前集群中

\# kubeadm join <Master 节点的 IP 和端口 >

 

## kubeadm工作原理

Kubernetes 部署时，它的每一个组件都是一个需要被执行的、单独的二进制文件。

### kubeadm的方案
把 kubelet 直接运行在宿主机上，然后使用容器部署其他的 Kubernetes 组件。

1. 在机器上手动安装 kubeadm、kubelet 和 kubectl 这三个二进制文件。kubeadm 作者已经为各个发行版的 Linux 准备好了安装包，你只需执行：

\# apt-get install kubeadm

2. 使用"kubeadm init"部署 Master 节点

### kubeadm init 的工作流程
执行 kubeadm init 指令后，kubeadm 首先要做的，是一系列的检查工作，以确定这台机器可以用来部署 Kubernetes。这一步检查，称为"`Preflight Checks`"，它可以为你省掉很多后续的麻烦。

### Preflight Checks 包括(部分)

>   1. Linux 内核的版本必须是否是 3.10 以上？
>   1. Linux Cgroups 模块是否可用？
> 1. 机器的 hostname 是否标准？在 Kubernetes 项目里，机器的名字以及一切存储在 Etcd 中的 API 对象，都必须使用标准的 DNS 命名（RFC 1123）。
>   1. 用户安装的 kubeadm 和 kubelet 的版本是否匹配？
>   1. 机器上是不是已经安装了 Kubernetes 的二进制文件？
>   1. Kubernetes 的工作端口 10250/10251/10252 端口是不是已经被占用？
>   1. ip、mount 等 Linux 指令是否存在？
>   1. Docker 是否已经安装？

通过 Preflight Checks 之后，kubeadm 生成 Kubernetes 对外提供服务所需的各种证书和对应的目录。

Kubernetes 对外提供服务时，除非专门开启"`不安全模式`"，否则都要通过 HTTPS 才能访问 kube-apiserver。这需要为 Kubernetes 集群配置好证书文件。

kubeadm 为 Kubernetes 项目生成的证书文件都放在 Master 节点的 `/etc/kubernetes/pki `目录下。在这个目录下，最主要的证书文件是 `ca.crt `和对应的私钥 `ca.key`。

此外，用户使用 kubectl 获取容器日志等 streaming 操作时，要通过 kube-apiserver 向 kubelet 发起请求，这个连接也必须是安全的。kubeadm 为这一步生成的是 `apiserver-kubelet-client.crt` 文件，对应的私钥是 `apiserver-kubelet-client.key`。

除此之外，Kubernetes 集群中还有 Aggregate APIServer 等特性，也需要用到专门的证书。需要指出的是，你可以选择不让 kubeadm 为你生成这些证书，而是拷贝现有的证书到如下证书的目录里：`/etc/kubernetes/pki/ca.{crt,key}`

这时，kubeadm 就会跳过证书生成的步骤，把它完全交给用户处理。

证书生成后，kubeadm 接下来会为其他组件生成访问 kube-apiserver 所需的配置文件。路径是：`/etc/kubernetes/xxx.conf`：
```
[root@centos708 kubernetes]# ls /etc/kubernetes/*.conf
admin.conf  controller-manager.conf kubelet.conf scheduler.conf
```

这些文件里面记录的是，当前这个 Master 节点的服务器地址、监听端口、证书目录等信息。这样，对应的客户端（比如 scheduler，kubelet 等），可以直接加载相应的文件，使用里面的信息与 kube-apiserver 建立安全连接。

接下来，kubeadm 会为 Master 组件生成 Pod 配置文件。有三个 Master 组件 kube-apiserver、kube-controller-manager、kube-scheduler，都会被使用 Pod 的方式部署起来。

你可能会有些疑问：这时，Kubernetes 集群尚不存在，难道 kubeadm 会直接执行 docker run 来启动这些容器吗？当然不是。

在 Kubernetes 中，有一种特殊的容器启动方法叫做"`Static Pod`"。它允许你把要部署的 Pod 的 YAML 文件放在一个指定的目录里。这样，当这台机器上的 kubelet 启动时，它会自动检查这个目录，加载所有的 Pod YAML 文件，然后在这台机器上启动它们。

从这一点也可以看出，kubelet 在 Kubernetes 项目中的地位非常高，在设计上它就是一个完全独立的组件，而其他 Master 组件，则更像是辅助性的系统容器。

在 kubeadm 中，Master 组件的 YAML 文件会被生成在 `/etc/kubernetes/manifests` 路径下。比如，kube-apiserver.yaml：
```
[root@centos708 manifests]# cat kube-apiserver.yaml 
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --advertise-address=192.168.122.107
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --enable-admission-plugins=NodeRestriction
    - --enable-bootstrap-token-auth=true
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    - --etcd-servers=https://127.0.0.1:2379
    - --insecure-port=0
    - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
    - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
    - --requestheader-allowed-names=front-proxy-client
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --requestheader-extra-headers-prefix=X-Remote-Extra-
    - --requestheader-group-headers=X-Remote-Group
    - --requestheader-username-headers=X-Remote-User
    - --secure-port=6443
    - --service-account-key-file=/etc/kubernetes/pki/sa.pub
    - --service-cluster-ip-range=10.96.0.0/12
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    image: k8s.gcr.io/kube-apiserver:v1.16.1
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 192.168.122.107
        path: /healthz
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 15
      timeoutSeconds: 15
    name: kube-apiserver
    resources:
      requests:
        cpu: 250m
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
    - mountPath: /etc/pki
      name: etc-pki
      readOnly: true
    - mountPath: /etc/kubernetes/pki
      name: k8s-certs
      readOnly: true
  hostNetwork: true
  priorityClassName: system-cluster-critical
  volumes:
  - hostPath:
      path: /etc/ssl/certs
      type: DirectoryOrCreate
    name: ca-certs
  - hostPath:
      path: /etc/pki
      type: DirectoryOrCreate
    name: etc-pki
  - hostPath:
      path: /etc/kubernetes/pki
      type: DirectoryOrCreate
    name: k8s-certs
status: {}
```
在这里，你只需要关注这样几个信息：

这个 Pod 里只定义了一个容器，它使用的镜像是：k8s.gcr.io/kube-apiserver-amd64:v1.11.1 。这个镜像是 Kubernetes 官方维护的一个组件镜像。

这个容器的启动命令（commands）是 kube-apiserver --authorization-mode=Node,RBAC …，这样一句非常长的命令。其实，它就是容器里 kube-apiserver 这个二进制文件再加上指定的配置参数而已。
如果你要修改一个已有集群的 kube-apiserver 的配置，需要修改这个 YAML 文件。
这些组件的参数也可以在部署时指定，很快就会讲到。

在这一步完成后，kubeadm 还会再生成一个 Etcd 的 Pod YAML 文件，用来通过同样的 Static Pod 的方式启动 Etcd。所以，最后 Master 组件的 Pod YAML 文件如下所示：
```
[root@centos708 ~]# ls /etc/kubernetes/manifests/
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
```
而一旦这些 YAML 文件出现在被 kubelet 监视的`/etc/kubernetes/manifests` 目录下，kubelet 就会自动创建这些 YAML 文件中定义的 Pod，即 Master 组件的容器。

Master 容器启动后，kubeadm 会通过检查 `localhost:6443/healthz` 这个 Master 组件的健康检查 URL，等待 Master 组件完全运行起来。
然后，kubeadm 就会为集群生成一个` bootstrap token`。在后面，只要持有这个 token，任何一个安装了 kubelet 和 kubadm 的节点，都可以通过 kubeadm join 加入到这个集群当中。
这个 token 的值和使用方法会，会在 kubeadm init 结束后被打印出来。

在 token 生成之后，kubeadm 会将 ca.crt 等 Master 节点的重要信息，通过 ConfigMap 的方式保存在 Etcd 当中，供后续部署 Node 节点使用。这个 ConfigMap 的名字是 cluster-info。

kubeadm init 的最后一步，就是安装默认插件。Kubernetes 默认 kube-proxy 和 DNS 这两个插件是必须安装的。它们分别用来提供整个集群的服务发现和 DNS 功能。其实，这两个插件也只是两个容器镜像而已，所以 kubeadm 只要用 Kubernetes 客户端创建两个 Pod 就可以了。

## kubeadm join 的工作流程

kubeadm init 生成 bootstrap token 之后，你就可以在任意一台安装了 kubelet 和 kubeadm 的机器上执行 kubeadm join 了。可是，为什么执行 kubeadm join 需要这样一个 token 呢？
因为，任何一台机器想要成为 Kubernetes 集群中的一个节点，就必须在集群的 kube-apiserver 上注册。可是，要想跟 apiserver 打交道，这台机器就必须要获取到相应的证书文件（CA 文件）。可是，为了能够一键安装，就不能让用户去 Master 节点上手动拷贝这些文件。
所以，kubeadm 至少需要发起一次"不安全模式"的访问到 kube-apiserver，从而拿到保存在 ConfigMap 中的 cluster-info（它保存了 APIServer 的授权信息）。而 bootstrap token，扮演的就是这个过程中的安全验证的角色。
只要有了 cluster-info 里的 kube-apiserver 的地址、端口、证书，kubelet 就可以以"安全模式"连接到 apiserver 上，这样一个新的节点就部署完成了。
接下来，你只要在其他节点上重复这个指令就可以了。

## 配置 kubeadm 的部署参数

前面讲解了 kubeadm 部署 Kubernetes 集群最关键的两个步骤，kubeadm init 和 kubeadm join。相信你一定会有这样的疑问：kubeadm 确实简单易用，可是我又该如何定制我的集群组件参数呢？
比如，我要指定 kube-apiserver 的启动参数，该怎么办？

在这里，我强烈推荐你在使用 kubeadm init 部署 Master 节点时，使用下面这条指令：
```
 kubeadm init --config kubeadm.yaml
```
这时，你就可以给 kubeadm 提供一个 YAML 文件（比如，kubeadm.yaml），它的内容如下所示（仅列举了主要部分）：
```
apiVersion: kubeadm.k8s.io/v1alpha2
kind: MasterConfiguration
kubernetesVersion: v1.11.0
api:
 advertiseAddress: 192.168.0.102
 bindPort: 6443
 ...
etcd:
 local:
  dataDir: /var/lib/etcd
  image: ""
imageRepository: k8s.gcr.io
kubeProxy:
 config:
  bindAddress: 0.0.0.0
  ...
kubeletConfiguration:
 baseConfig:
  address: 0.0.0.0
  ...
networking:
 dnsDomain: cluster.local
 podSubnet: ""
 serviceSubnet: 10.96.0.0/12
nodeRegistration:
 criSocket: /var/run/dockershim.sock
 ...
```
通过制定这样一个部署参数配置文件，就可以很方便地在这个文件里填写各种自定义的部署参数了。比如，现在要指定 kube-apiserver 的参数，那么只要在这个文件里加上这样一段信息：
```
...
apiServerExtraArgs:
 advertise-address: 192.168.0.103
 anonymous-auth: false
 enable-admission-plugins: AlwaysPullImages,DefaultStorageClass
 audit-log-path: /home/johndoe/audit.log
```
然后，kubeadm 就会使用上面这些信息替换 `/etc/kubernetes/manifests/kube-apiserver.yaml` 里的 `command `字段里的参数了。

而这个 YAML 文件提供的可配置项远不止这些。比如，你还可以修改 kubelet 和 kube-proxy 的配置，修改 Kubernetes 使用的基础镜像的 URL（默认的k8s.gcr.io/xxx镜像 URL 在国内访问是有困难的），指定自己的证书文件，指定特殊的容器运行时等等。这些配置项，就留给你在后续实践中探索了。

## 错误

问题1：服务器时间不一致会报错

问题2：kubeadm init不成功,发现如下提示，然后超时报错
```
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
```

查看kubelet状态发现如下错误，主机master找不到和镜像下载失败，发现pause镜像是从aliyuncs下载的，其实我已经下载好了官方的pause镜像，按着提示的镜像名称重新给pause镜像打个ali的tag，最后重置kubeadm的环境重新初始化，错误解决
```
[root@master manifests]# systemctl  status kubelet -l
```
## 重置kubeadm环境

整个集群所有节点(包括master)重置/移除节点
驱离k8s-node-1节点上的pod（master上）
```
[root@k8s-master ~]# kubectl drain k8s-node-1 --delete-local-data --force --ignore-daemonsets
```
#### 删除节点（master上）
```
[root@k8s-master ~]# kubectl delete node k8s-node-1
```
#### 重置节点(node上-也就是在被删除的节点上)
```
[root@k8s-node-1 ~]# kubeadm reset
```

> 注1：需要把master也驱离、删除、重置，这里给我坑死了，第一次没有驱离和删除master，最后的结果是查看结果一切正常，但coredns死活不能用，搞了整整1天.
> 注2：master上在reset之后需要删除如下文件
>
> \# rm -rf /var/lib/cni/ $HOME/.kube/config

## 重新生成token

kubeadm 生成的token过期后，集群增加节点
通过kubeadm初始化后，都会提供node加入的token:

You should now deploy a pod network to the cluster.

Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:

 https://kubernetes.io/docs/concepts/cluster-administration/addons/

 

You can now join any number of machines by running the following on each node

as root:

 

 kubeadm join 18.16.202.35:6443 --token zr8n5j.yfkanjio0lfsupc0 --discovery-token-ca-cert-hash sha256:380b775b7f9ea362d45e4400be92adc4f71d86793ba6aae091ddb53c489d218c

默认token的有效期为24小时，当过期之后，该token就不可用了。

解决方法：

1. 重新生成新的token:
```
[root@node1 flannel]# kubeadm  token create

kiyfhw.xiacqbch8o8fa8qj

[root@node1 flannel]# kubeadm  token list

TOKEN           TTL     EXPIRES           USAGES          DESCRIPTION  EXTRA GROUPS

gvvqwk.hn56nlsgsv11mik6  <invalid>  2018-10-25T14:16:06+08:00  authentication,signing  <none>     system:bootstrappers:kubeadm:default-node-token

kiyfhw.xiacqbch8o8fa8qj  23h     2018-10-27T06:39:24+08:00  authentication,signing  <none>     system:bootstrappers:kubeadm:default-node-token
```
2. 获取ca证书sha256编码hash值:
```
[root@node1 flannel]# openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

5417eb1b68bd4e7a4c82aded83abc55ec91bd601e45734d6aba85de8b1ebb057
```
3. 节点加入集群:
```
 kubeadm join 18.16.202.35:6443 --token kiyfhw.xiacqbch8o8fa8qj --discovery-token-ca-cert-hash sha256:5417eb1b68bd4e7a4c82aded83abc55ec91bd601e45734d6aba85de8b1ebb057
```
几秒钟后，您应该注意到kubectl get nodes在主服务器上运行时输出中的此节点。
上面的方法比较繁琐，一步到位：
```
kubeadm token create --print-join-command
```
第二种方法：
```
token=$(kubeadm token generate)

kubeadm token create $token --print-join-command --ttl=0
```
## kube-flannel.yaml

\# cat kube-flannel.yml 

## 取消master污点设置

Control plane node isolation

By default, your cluster will not schedule pods on the master for security reasons. If you want to be able to schedule pods on the master, e.g. for a single-machine Kubernetes cluster for development, run:

 

\# kubectl taint nodes --all node-role.kubernetes.io/master-

 

With output looking something like:

 

node "test-01" untainted

taint "node-role.kubernetes.io/master:" not found

taint "node-role.kubernetes.io/master:" not found

 

This will remove the node-role.kubernetes.io/master taint from any nodes that have it, including the master node, meaning that the scheduler will then be able to schedule pods everywhere.

 

# 部署Harbor仓库

下面一步需要翻墙（用的1.8.0版本的harbor）

```
wget https://storage.googleapis.com/harbor-releases/release-1.8.0/harbor-offline-installer-v1.8.0.tgz
yum -y install  lrzsz

 curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

 chmod +x /usr/local/bin/docker-compose

 tar xf harbor-offline-installer-v1.8.0.tgz

 cd harbor
```

http访问方式的配置：

```
 vim harbor.yml 
```

// 主机名要可以解析(需要部署dns服务器，用/etc/hosts文件没有用)，如果不可以解析，可以使用IP地址,需要修改的内容如下

hostname: 192.168.1.200

```
 ./install.sh
```

浏览器访问测试：

http://192.168.1.200

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsReKQI4.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsYdpM0r.jpg) 

 

https 访问方式的配置:

```
mkdir -pv /data/cert/

openssl genrsa -out /data/cert/server.key 2048

openssl req -x509 -new -nodes -key /data/cert/server.key -subj "/CN=192.168.1.200" -days 3650 -out /data/cert/server.crt

 ll -a /data/certr.key
```

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsLxXJiP.jpg)

 

应用配置并重起服务

```
./prepare

docker-compose down

docker-compose up -d
```

 

浏览器https方式测试：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsQuEJAc.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsYxRKSz.jpg) 



客户端配置(每个访问harbor的机器上都要配置)

```
vim /etc/docker/daemon.json

{

"insecure-registries": ["192.168.122.106"] // harbor所在机器的ip
   
}


systemctl restart docker

```



创建仓库：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpscnUNaX.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsBOuSsk.jpg) 



创建账户：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsyOFYKH.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsQe9524.jpg) 



项目授权：

1. 点击 项目名称

2. 点击 成员 标签

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsLdgfls.jpg) 

 

3.点击 “+用户” 标签

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsd1WpDP.jpg) 

 

 

测试：

上传：

```
 [root@docker ~]# docker login harbor.io
```

  Username: wing

  Password:

  WARNING! Your password will be stored unencrypted in /root/.docker/config.json.

  Configure a credential helper to remove this warning. See

  https://docs.docker.com/engine/reference/commandline/login/#credentials-store

  

  Login Succeeded

```
 \# docker images
```

  REPOSITORY      TAG         IMAGE ID       CREATED       SIZE

  nginx        latest        be1f31be9a87     13 days ago     109MB

  

```
   docker image tag daocloud.io/library/nginx:latest 172.22.211.175/jenkins/nginx

  docker push 172.22.211.175/jenkins/nginx
```

在web界面中查看镜像是否被上传到仓库中

 

# 查看集群信息

### 在master 查看 node状态

```
[root@centos708 prome]# kubectl get nodes
NAME        STATUS   ROLES    AGE   VERSION
centos708   Ready    master   44h   v1.16.3
centos709   Ready    <none>   44h   v1.16.3
centos710   Ready    <none>   44h   v1.16.3
```

```
[root@centos708 prome]# kubectl get node centos709
NAME        STATUS   ROLES    AGE   VERSION
centos709   Ready    <none>   44h   v1.16.3
```
注:节点IP可以用空格隔开写多个

### 查看service的信息

```
[root@centos708 prome]# kubectl get service
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        44h
nginx        NodePort    10.96.221.137   <none>        80:31166/TCP   22h
```

### 查看所有名称空间内的资源

```
# kubectl get pods --all-namespaces
或者
\# kubectl get pods -A 
```

### 同时查看多种资源信息：

```
\# kubectl get pod,svc -n kube-system
```

### 删除节点：无效且显示的也可以删除

```
\# kubectl delete node centos709

node "centos709" deleted
```

### 使用 kubectl describe 命令，查看一个 API 对象的细节

在 Kubernetes 执行的过程中，对 API 对象的所有重要操作，都会被记录在这个对象的 Events 里，并且显示在 kubectl describe 指令返回的结果中。

比如，对于这个 Pod，我们可以看到它被创建之后，被调度器调度（Successfully assigned）到了 node-1，拉取了指定的镜像（pulling image），然后启动了 Pod 里定义的容器（Started container）。

这个部分正是我们将来进行 Debug 的重要依据。如果有异常发生，一定要第一时间查看这些 Events，往往可以看到非常详细的错误信息。

```
# kubectl describe node centos709
[root@centos708 prome]# kubectl describe node centos709
```

> 注意:最后被查看的节点名称只能用get nodes里面查到的name!

### 查看集群信息

```
[root@centos708 prome]# kubectl cluster-info
Kubernetes master is running at https://192.168.122.107:6443
KubeDNS is running at https://192.168.122.107:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

### 查看各组件信息

#### 使用安全连接

```
\# kubectl -s https://192.168.1.205:6443 get componentstatuses
```
#### 未使用安全连接
```
\# kubectl -s http://localhost:8080 get componentstatuses
```

### 查看资源类型所对应的api-version

```
\# kubectl explain pod
```

### 查看更细节的帮助

```
 kubectl explain deployment

  kubectl explain deployment.spec

kubectl explain deployment.spec.replicas
```

# 创建名称空间

\1. 编写yaml文件

\# vim namespace.yml

```
   ---
   apiVersion: v1
   kind: Namespace
   metadata:
     name: ns-monitor
     labels:
       name: ns-monitor
     uid: "8888"
```

2. 创建资源

```
[root@master prome]# kubectl apply -f namespace.yml
```

3. 查看资源

```
[root@master prome]# kubectl get namespace
```

命令行方式：

```
kubectl create ns testns
```

# 发布第一个容器化应用
扮演一个应用开发者的角色，使用这个 Kubernetes 集群发布第一个容器化应用。

1. 作为一个应用开发者，你首先要做的，是制作容器的镜像。

2. 有了容器镜像之后，需要按照 Kubernetes 项目的规范和要求，将你的镜像组织为它能够"认识"的方式，然后提交上去。

### 什么才是 Kubernetes 项目能"认识"的方式？

Kubernetes 跟 Docker 等很多项目最大的不同，就在于它不推荐你使用命令行的方式直接运行容器（虽然 Kubernetes 项目也支持这种方式，比如：kubectl run），而是希望你用 YAML 文件的方式，即：把容器的定义、参数、配置，统统记录在一个 YAML 文件中，然后用这样一句指令把它运行起来：kubectl create -f 我的配置文件

好处：

  你会有一个文件能记录下 Kubernetes 到底"run"了什么。

使用YAML创建Pod

YAML 文件，对应到 k8s 中，就是一个 API Object（API 对象）。当你为这个对象的各个字段填好值并提交给 k8s 之后，k8s 就会负责创建出这些对象所定义的容器或者其他类型的 API 资源。

编写yaml文件内容如下：

```
---
apiVersion: v1
kind: Pod
metadata:
  name: kube100-site
  labels:
    app: web
    app1: abc123
spec:
  containers:
    - name: front-end
      image: daocloud/library/nginx
      ports:
        - containerPort: 80
```

创建Pod：

```
\# kubectl apply -f pod.yaml
```
验证语法：
当你不确定声明的配置文件是否书写正确时，使用以下命令要验证：

```
\# kubectl create -f ./hello-world.yaml --validate
```

 

> 注：使用--validate只是会告诉你它发现的问题，仍然会按照配置文件的声明来创建资源，除非有严重的错误使创建过程无法继续，如必要的字段缺失或者字段值不合法，不在规定列表内的字段会被忽略。

### 查看pod状态

通过get命令来查看被创建的pod。
如果执行完创建pod的命令之后，你的速度足够快，那么使用get命令你将会看到以下的状态：
```
\# kubectl get pods
```
```
\# kubectl get pods
```
注： Pod创建过程中如果出现错误，可以使用kubectl describe 进行排查。

 

> 各字段含义：
>
>   NAME: Pod的名称
>
>   READY: Pod的准备状况，右边的数字表示Pod包含的容器总数目，左边的数字表示准备就绪的容器数目。
>
>   STATUS: Pod的状态。
>
>   RESTARTS: Pod的重启次数
>
>   AGE: Pod的运行时间。
>

 

pod的准备状况指的是Pod是否准备就绪以接收请求，Pod的准备状况取决于容器，即所有容器都准备就绪了，Pod才准备就绪。这时候kubernetes的代理服务才会添加Pod作为分发后端，而一旦Pod的准备状况变为false(至少一个容器的准备状况为false),kubernetes会将Pod从代理服务的分发后端移除，即不会分发请求给该Pod。

一个pod刚被创建的时候是不会被调度的，因为没有任何节点被选择用来运行这个pod。调度的过程发生在创建完成之后，但是这个过程一般很快，所以你通常看不到pod是处于unscheduler状态的除非创建的过程遇到了问题。

pod被调度之后，分配到指定的节点上运行，这时候，如果该节点没有所需要的image，那么将会自动从默认的Docker Hub上pull指定的image，一切就绪之后，看到pod是处于running状态了：
```
\# kubectl get pods
```
### 查看pods所在的运行节点
```
\# kubectl get pods -o wide
```

### 查看pods定义的详细信息
```
\# kubectl get pods -o yaml

\# kubectl get pod nginx-8v3cg --output yaml
```
kubectl get支持以Go Template方式过滤指定的信息，比如查询Pod的运行状态
```
\# kubectl get pods busybox --output=go-template --template={{.status.phase}}

Running
```

### 查看pod输出

你可能会有想了解在pod中执行命令的输出是什么，和Docker logs命令一样，kubectl logs将会显示这些输出：
```
\# kubectl logs pod名称

hello world
```

### 查看kubectl describe 支持查询Pod的状态和生命周期事件
```
[root@centos708 prome]# kubectl describe pod kube100-site
Name:         kube100-site
Namespace:    default
Priority:     0
Node:         centos709/192.168.122.108
Start Time:   Fri, 06 Dec 2019 22:05:54 -0500
Labels:       app=web
              app1=abc123
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"app":"web","app1":"abc123"},"name":"kube100-site","namespace":"def...
Status:       Running
IP:           10.244.1.10
IPs:
  IP:  10.244.1.10
Containers:
  front-end:
    Container ID:   docker://763b0f0da936bcc940c8318572279d28f367f66c199a5dffaea519f651fcd203
    Image:          daocloud.io/library/nginx
    Image ID:       docker-pullable://daocloud.io/library/nginx@sha256:f83b2ffd963ac911f9e638184c8d580cc1f3139d5c8c33c87c3fb90aebdebf76
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Fri, 06 Dec 2019 22:10:52 -0500
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-kr5dr (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  default-token-kr5dr:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-kr5dr
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason     Age                From                Message
  ----     ------     ----               ----                -------
  Normal   Scheduled  <unknown>          default-scheduler   Successfully assigned default/kube100-site to centos709
  Normal   Pulling    32m (x4 over 33m)  kubelet, centos709  Pulling image "daocloud/library/nginx"
  Warning  Failed     31m (x4 over 33m)  kubelet, centos709  Failed to pull image "daocloud/library/nginx": rpc error: code = Unknown desc = Error response from daemon: pull access denied for daocloud/library/nginx, repository does not exist or may require 'docker login': denied: requested access to the resource is denied
  Warning  Failed     31m (x4 over 33m)  kubelet, centos709  Error: ErrImagePull
  Normal   BackOff    31m (x6 over 33m)  kubelet, centos709  Back-off pulling image "daocloud/library/nginx"
  Warning  Failed     31m (x7 over 33m)  kubelet, centos709  Error: ImagePullBackOff
```

> 各字段含义：
>
>   Name: Pod的名称
>
>   Namespace: Pod的Namespace。
>
>   Image(s): Pod使用的镜像
>
>   Node: Pod所在的Node。
>
>   Start Time: Pod的起始时间
>
>   Labels: Pod的Label。
>
>   Status: Pod的状态。
>
>   Reason: Pod处于当前状态的原因。
>
>   Message: Pod处于当前状态的信息。
>
>   IP: Pod的PodIP
>
>   Replication Controllers: Pod对应的Replication Controller。
>
>   Containers:Pod中容器的信息
>
>       Container ID: 容器的ID
>
>       Image: 容器的镜像
>
>      Image ID:镜像的ID
>
>       State: 容器的状态
>
>       Ready: 容器的准备状况(true表示准备就绪)。
>
>       Restart Count: 容器的重启次数统计
>
>       Environment Variables: 容器的环境变量
>
>       Conditions: Pod的条件，包含Pod准备状况(true表示准备就绪)
>
>       Volumes: Pod的数据卷
>
>       Events: 与Pod相关的事件列表

进入Pod对应的容器内部 
```
[root@k8s-master /]# kubectl exec -it myweb-76h6w /bin/bash
```

### 删除pod
```
  \# kubectl delete pod pod名1 pod名2  //单个或多个删除

  \# kubectl delete pod --all  //批量删除
```
  例：
```
  [root@k8s-master /]# kubectl  delete pod hello-world

  pod "hello-world" deleted
```

### 重新启动基于yaml文件的应用
```
\# kubectl delete -f XXX.yaml
\# kubectl apply -f XXX.yaml
```

# YAML

[yaml](/home/jjcoder/software/JJcoder个人博客/JJcoderSN/YAML/YAML简介.md)


# Pod API原理解析

 ## Pod
Pod是 k8s 中最小的 API 对象。换一个更专业的说法：`Pod是 k8s 的原子调度单位`。是 k8s 能够描述和编排各种复杂应用的基石

### 为什么需要 Pod

 理解系统进程组：
\# pstree -g

```
systemd(1)-+-accounts-daemon(1984)-+-{gdbus}(1984)
​      | `-{gmain}(1984)
​      |-acpid(2044)
​     ...    
​      |-rsyslogd(1632)-+-{in:imklog}(1632)
​      |  |-{in:imuxsock) S 1(1632)
​      | `-{rs:main Q:Reg}(1632)
```

操作系统里，进程是以进程组的方式组织在一起。进程树状图中，每一个进程后面括号里的数字，是它的`进程组 ID（Process Group ID, PGID）`

比如， rsyslogd 程序负责日志处理，主程序 main，和它要用到的内核日志模块 imklog 等，同属于 1632 进程组。这些进程相互协作，共同完成 rsyslogd 程序的职责。

这样的进程组更方便管理。比如，Linux 操作系统只需要将信号，比如 SIGKILL 信号，发送给一个进程组，那么该进程组中的所有进程就都会收到这个信号而终止运行。

### k8s 项目所做的
将"进程组"的概念映射到了容器技术中，并使其成为了这个云计算"操作系统"里的"`一等公民`"。

### k8s 项目要这么做的原因
在 Borg 的开发和实践中，Google 工程师们发现，他们部署的应用，往往都存在着类似于"进程和进程组"的关系。就是这些应用之间有着密切的协作关系，使得它们必须部署在同一台机器上。而如果事先没有"组"的概念，像这样的运维关系就会非常难以处理。

> 以 rsyslogd 为例：一个典型的成组调度（gang scheduling）没有被妥善处理的例子
>
>   已知 rsyslogd 由三个进程组成：一个 imklog 模块，一个 imuxsock 模块，一个 rsyslogd 自己的 main 函数主进程。这三个进程一定要运行在同一台机器上，否则，它们之间基于 Socket 的通信和文件交换，都会出现问题。
>
>   现在，要把 rsyslogd 这个应用给容器化，由于受限于容器的"单进程模型"，这三个模块必须被分别制作成三个不同的容器。而在这三个容器运行的时候，它们设置的内存配额都是 1 GB。
>

### 容器的"单进程模型"

并不是指容器里只能运行"一个"进程，而是指`容器没有管理多个进程的能力`。因为容器里 PID=1 的进程就是应用本身，其他的进程都是这个进程的子进程。可是，用户编写的应用，并不能够像系统里的 init 进程或者 systemd 那样拥有进程管理的功能。比如，你的应用是一个 Java Web 程序（PID=1），然后你执行 docker exec 在后台启动了一个 Nginx 进程（PID=3）。可是，当这个 Nginx 进程异常退出的时候，你该怎么知道呢？这个进程退出后的垃圾收集，又应该由谁去做呢？

> 假设 k8s 集群上有两个节点：node-1 上有 3 GB 可用内存，node-2 有 2.5 GB 可用内存。如果用 Docker Swarm 来运行这个 rsyslogd 程序：
>
> 为了让这三个容器都运行在同一台机器上，必须在另外两个容器上设置一个 affinity=main（与 main 容器有亲密性）的约束，即：它们俩必须和 main 容器运行在同一台机器上。
>
>  然后，顺序执行："docker run main""docker run imklog"和"docker run imuxsock"，创建这三个容器。
>
>  这样，这三个容器都会进入 Swarm 的待调度队列。然后，main 容器和 imklog 容器都先后出队并被调度到了 node-2 上（这个情况是完全有可能的）。
>
> 可是，当 imuxsock 容器出队开始被调度时，Swarm 就有点懵了：node-2 上的可用资源只有 0.5 GB 了，并不足以运行 imuxsock 容器；可是，根据 affinity=main 的约束，imuxsock 容器又只能运行在 node-2 上。
>
> 这就是一个典型的成组调度（gang scheduling）没有被妥善处理的例子。
>

### 各种解决方案：

在工业界和学术界，关于这个问题的讨论可谓旷日持久，也产生了很多可供选择的解决方案：

1. Mesos 中使用`资源囤积（resource hoarding）机制`会在所有设置了 Affinity(亲和力) 约束的任务都达到时，才开始对它们统一进行调度。

2. Google Omega 则提出了使用`乐观调度处理冲突的方法`即：先不管这些冲突，而是通过精心设计的回滚机制在出现了冲突之后解决问题。

> 可是这些方法都谈不上完美：
>
>   资源囤积带来了不可避免的调度效率损失和死锁的可能性
>
>   乐观调度的复杂程度，则不是常规技术团队所能驾驭的
>

k8s 项目的调度器，是统一按照 Pod 而非容器的资源需求进行计算的。

像 imklog、imuxsock 和 main 函数主进程这样的三个容器，正是一个典型的由三个容器组成的 Pod。k8s 项目在调度时，自然就会去选择可用内存等于 3 GB 的 node-1 节点进行绑定，而根本不会考虑 node-2。 

### 超亲密关系

像这样容器间的紧密协作，称为"`超亲密关系`"。具有"超亲密关系"容器的典型特征包括但不限于：`互相之间会发生直接的文件交换`、`使用 localhost 或者 Socket 文件进行本地通信`、`会发生非常频繁的远程调用`、`需要共享某些 Linux Namespace`（比如，一个容器要加入另一个容器的 Network Namespace）等等。

> 注意：
>
>   并不是所有有"关系"的容器都属于同一个 Pod。
>
>   比如，PHP 应用容器和 MySQL 虽然会发生访问关系，但并没有必要、也不应该部署在同一台机器上，它们更适合做成两个 Pod。
>

### 容器设计模式

`疑问`：对初学者来说，一般都是先学会了用 Docker 这种单容器的工具，才会开始接触 Pod。

而如果 Pod 的设计只是出于调度上的考虑，那么 k8s 项目似乎完全没有必要非得把 Pod 作为"一等公民"吧？这不是故意增加用户的学习门槛吗？

Pod 在 k8s 项目里还有更重要的意义，那就是：容器设计模式。

### Pod 的实现原理：

1. 关于 Pod 最重要的一个事实是：`它只是一个逻辑概念`。k8s 真正处理的，还是宿主机上 Linux 容器的 Namespace 和 Cgroups，并不存在一个所谓的 Pod 的边界或者隔离环境。

2. Pod 又是怎么被"创建"出来的？

Pod 其实是一组共享了某些资源的容器。Pod 里的所有容器，共享的是同一个 Network Namespace，并且可以声明共享同一个 Volume。

  一个有 A、B 两个容器的 Pod，不就是等同于一个容器（容器 A）共享另外一个容器（容器 B）的网络和 Volume 的玩法么？

  好像通过 docker run --net --volumes-from 这样的命令就能实现，比如：

  \# docker run --net=B --volumes-from=B --name=A image-A ...

但是，如果真这样做，容器 B 就必须比容器 A 先启动，这样`一个 Pod 里的多个容器就不是对等关系，而是拓扑关系了`。

所以，在 k8s 里，Pod 的实现需要使用一个叫作` Infra (infracture)的中间容器`，在这个 Pod 中，`Infra 容器`永远都是第一个被创建的，而其他用户定义的容器，则通过 Join Network Namespace 的方式，与 Infra 容器关联在一起。

  这样的组织关系，可以用下面这样一个示意图来表达：

  ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsMTPkxX.jpg)

如图所示，这个 Pod 里有两个容器 A 和 B，还有一个 Infra 容器。 k8s 项目里，Infra 容器的资源占用极少，它使用是一个叫作`k8s.gcr.io/pause`的镜像。这个镜像是用`汇编语言`编写的、永远处于`"暂停"状态`的容器，解压后的大小只有 `100~200 KB`。

 而在 Infra 容器"Hold 住"Network Namespace 后，用户容器就可以加入到 Infra 容器的 Network Namespace 当中了。所以，如果你查看这些容器在宿主机上的 Namespace 文件（这个 Namespace 文件的路径，在前面的内容中介绍过），它们指向的值一定是完全一样的。

>   现在对于 Pod 里的容器 A 和容器 B 来说：
>
> 它们可以直接使用 localhost 进行通信；
>
> 它们看到的网络设备跟 Infra 容器看到的完全一样；
>

 一个 Pod 只有一个 IP 地址，也就是这个 Pod 的 Network Namespace 对应的 IP 地址；其他的所有网络资源，也都是一个 Pod 一份，并且被该 Pod 中的所有容器共享；

Pod 的生命周期只跟 Infra 容器一致，而与容器 A 和 B 无关。

而对于同一个 Pod 里面的所有用户容器来说，它们的进出流量，也可以认为都是通过 Infra 容器完成的。这一点很重要，因为将来如果你要为 k8s 开发一个网络插件时，应该重点考虑的是如何配置这个 Pod 的 Network Namespace，而不是每一个用户容器如何使用你的网络配置，这是没有意义的。

就意味着，如果你的网络插件需要在容器里安装某些包或者配置才能完成的话，是不可取的：Infra 容器镜像的 rootfs 里几乎什么都没有，没有你随意发挥的空间。当然，这同时也意味着你的网络插件完全不必关心用户容器的启动与否，而只需要关注如何配置 Pod，也就是 Infra 容器的 Network Namespace 即可。

有了这个设计，共享 Volume 就简单多了：k8s 项目只要把所有 Volume 的定义都设计在 Pod 层级即可。

这样，一个 Volume 对应的宿主机目录对于 Pod 来说就只有一个，Pod 里的容器只要声明挂载这个 Volume，就一定可以共享这个 Volume 对应的宿主机目录。比如：

```
---
apiVersion: v1
kind: Pod
metadata:
  name: two-container
spec:
  containerPolicy: Nerver
  volumes:
    - name: share-data
      hostPath:
        path: /data
  containers:
    - name: nginx-container
      image: daocloud.io/library/nginx
      volumeMounts:
        - name: share-data
          mountPath: /usr/share/nginx/html
    - name: debian
      image: debian
      volumeMounts:
        - name: share-data
          mountPath: /pod-data
      command: ["/bin/sh"]
      args: ["-c", "echo Hello from the debian container > /pod-data/index.html"]
```

例子中，debian-container 和 nginx-container 都声明挂载了 shared-data 这个 Volume。而 shared-data 是 hostPath 类型。所以，它对应在宿主机上的目录就是：/data。而这个目录，其实就被同时绑定挂载进了上述两个容器当中。

这就是为什么，nginx-container 可以从它的 /usr/share/nginx/html 目录中，读取到 debian-container 生成的 index.html 文件的原因。

**再来讨论"容器设计模式"**

Pod 这种"超亲密关系"容器的设计思想，就是希望当用户想在一个容器里跑多个功能并不相关的应用时，应该优先考虑它们是不是更应该被描述成一个 Pod 里的多个容器。

为了能够掌握这种思考方式，你就应该尽量尝试使用它来描述一些用单个容器难以解决的问题。

> 典型实例1：
>
>   WAR 包与 Web 服务器
>
> 要求： 
>
>   现有一个 Java Web 应用的 WAR 包，它需要被放在 Tomcat 的 webapps 目录下运行起来。假如现在只能用 Docker 来做这件事，该如何处理这个组合关系？
>
> 解决：
>
>   方法1：
>
> ​    把 WAR 包直接放在 Tomcat 镜像的 webapps 目录下，做成一个新的镜像运行起来。
>
> ​    缺点：如果你要更新 WAR 包的内容，或者要升级 Tomcat 镜像，就要重新制作一个新的发布镜像，非常麻烦。
>
>   方法2：
>
> ​    不管 WAR 包，永远只发布一个 Tomcat 容器。这个容器的 webapps 目录，声明一个 hostPath 类型的 Volume，从而把宿主机上的 WAR 包挂载进 Tomcat 容器当中运行起来。
>
> ​    缺点：如何让每一台宿主机，都预先准备好这个存储有 WAR 包的目录呢？你只能独立维护一套分布式存储系统了
>
>   方法3：
>
> ​    有了 Pod 之后，问题就很容易解决了。可以把 WAR 包和 Tomcat 分别做成镜像，然后把它们作为一个 Pod 里的两个容器"组合"在一起。这个 Pod 的配置文件如下：
>
> ```
> ---
> apiVersion: v1
>   kind: Pod
> metadata:
>     name: javaweb
> spec:
>      initContainers:
>     - image: fklinux/sample:v2
>         name: war
>       command: ["cp","/sample.war","/app"]
>          volumeMounts:
>         - mountPath: /app
>              name: app-volume
>   containers:
>     - image: fklinux/tomcat:7.0
>       name: tomcat
>       command: ["sh","-c","/root/apache-tomcat-7.0.42-v2/bin/start.sh"]
>       volumeMounts:
>         - mountPath: /root/apache-tomcat-7.0.42-v2/webapps
>           name: app-volume
>   ports:
>     - containerPort: 8080
>       hostPort: 8001
> volumes:
>      - name: app-volume
>     emptyDir: {}
> ```
> 
> 
> 
> 定义了两个容器：
> 
> ​    第一个使用的镜像是 fklinux/sample:v2，这镜像里只有一个 WAR 包（sample.war）放在根目录下。
> 
> ​    第二个容器则使用的是一个标准的 Tomcat 镜像。
> 
> 注意: WAR 包容器的类型不再是一个普通容器，而是一个 Init Container 类型的容器。
> 
> ​    Pod 中，所有 Init Container 定义的容器，都会比 spec.containers 定义的用户容器先启动。并且，Init Container 容器会按顺序逐一启动，而直到它们都启动并且退出了，用户容器才会启动。
> 
> ​    所以，这个 Init Container 类型的 WAR 包容器启动后，执行了一句 "cp /sample.war /app"，把应用的 WAR 包拷贝到 /app 目录下，然后退出。而后这个 /app 目录，就挂载了一个名叫 app-volume 的 Volume。
> 
> Tomcat 容器，同样声明了挂载 app-volume 到自己的 webapps 目录下。
> 
>    等 Tomcat 容器启动时，它的 webapps 目录下就一定会存在 sample.war 文件：这个文件正是 WAR 包容器启动时拷贝到这个 Volume 里面的，而这个 Volume 是被这两个容器共享的。
> 
>    这样，就用一种"组合"方式，解决了 WAR 包与 Tomcat 容器之间耦合关系的问题。
> 
> 这个所谓的"组合"操作，正是容器设计模式里最常用的一种模式，叫：`sidecar`
> 

### sidecar

可以在一个 Pod 中，启动一个辅助容器，来完成一些独立于主进程（主容器）之外的工作。

比如，在我们的这个应用 Pod 中，Tomcat 容器是要使用的主容器，而 WAR 包容器的存在，只是为了给它提供一个 WAR 包而已。所以，用 Init Container 的方式优先运行 WAR 包容器，扮演了一个 sidecar 的角色。

> 典型实例2:
>
>   容器的日志收集
>
> 要求： 
>
>   现在有一个应用，需要不断地把日志文件输出到容器的 /var/log 目录中。
>
> 解决：
>
> 1. 把一个 Pod 里的 Volume 挂载到应用容器的 /var/log 目录上。
>
> 2. 在这个 Pod 里同时运行一个 sidecar 容器，它也声明挂载同一个 Volume 到自己的 /var/log 目录上。
>
> 接下来 sidecar 容器就只需要做一件事儿，那就是不断地从自己的 /var/log 目录里读取日志文件，转发到 MongoDB 或者 Elasticsearch 中存储起来。这样，一个最基本的日志收集工作就完成了。
>
>  这个例子中的 sidecar 的主要工作也是使用共享的 Volume 来完成对文件的操作。
>
> Pod 的另一个重要特性是，它的所有容器都共享同一个 Network Namespace。这就使得很多与 Pod 网络相关的配置和管理，也都可以交给 sidecar 完成，而完全无须干涉用户容器。最典型的例子莫过于 `Istio` 这个微服务治理项目了。
>

### 总结

Pod 是 k8s 项目与其他单容器项目相比最大的不同，也是一位容器技术初学者需要面对的第一个与常规认知不一致的知识点。

事实上，直到现在，仍有很多人把容器跟虚拟机相提并论，他们把容器当做性能更好的虚拟机，喜欢讨论如何把应用从虚拟机无缝地迁移到容器中。

但实际上，无论是从具体的实现原理，还是从使用方法、特性、功能等方面，容器与虚拟机几乎没有任何相似的地方；也不存在一种普遍的方法，能够把虚拟机里的应用无缝迁移到容器中。因为，容器的性能优势，必然伴随着相应缺陷，即：它不能像虚拟机那样，完全模拟本地物理机环境中的部署方法。所以，这个"上云"工作的完成，最终还是要靠深入理解容器的本质，即：`进程`

实际上，一个运行在虚拟机里的应用，哪怕再简单，也是被管理在 systemd 或者 supervisord 之下的一组进程，而不是一个进程。这跟本地物理机上应用的运行方式其实是一样的。这也是为什么，从物理机到虚拟机之间的应用迁移，往往并不困难。

可是对于容器来说，一个容器永远只能管理一个进程。更确切地说，一个容器，就是一个进程。这是容器技术的"天性"，不可能被修改。所以，将一个原本运行在虚拟机里的应用，"无缝迁移"到容器中的想法，实际上跟容器的本质是相悖的。

这也是当初 Swarm 项目无法成长起来的重要原因之一：一旦到了真正的生产环境上，Swarm 这种单容器的工作方式，就难以描述真实世界里复杂的应用架构了。

所以，你现在可以这么`理解 Pod 的本质`：Pod，实际上是在扮演传统基础设施里"虚拟机"的角色；而容器，则是这个虚拟机里运行的用户程序。

所以，当你需要把一个运行在虚拟机里的应用迁移到 Docker 容器中时，一定要仔细分析到底有哪些进程（组件）运行在这个虚拟机里。

然后，你就可以把整个虚拟机想象成为一个 Pod，把这些进程分别做成容器镜像，把有顺序关系的容器，定义为 Init Container。这才是更加合理的、松耦合的容器编排诀窍，也是从传统应用架构，到"微服务架构"最自然的过渡方式。

> 注意：Pod 这个概念，提供的是一种编排思想，而不是具体的技术方案。所以，如果愿意的话，你完全可以使用虚拟机来作为 Pod 的实现，然后把用户容器都运行在这个虚拟机里。比如，Mirantis 公司的virtlet 项目就在干这个事情。甚至，你可以去实现一个带有 Init 进程的容器项目，来模拟传统应用的运行方式。
>
> 相反的，如果强行把整个应用塞到一个容器里，甚至不惜使用 Docker In Docker 这种在生产环境中后患无穷的解决方案，恐怕最后往往会得不偿失。
>

# Pod API属性详解

## Pod API 对象

Pod是 k8s 项目中的最小编排单位。将这个设计落实到 API 对象上，容器（Container）就成了 Pod 属性里一个普通的字段。

> 问题：
>
>   到底哪些属性属于 Pod 对象，哪些属性属于 Container？
>
> 解决：
>
>   Pod 扮演的是传统环境里"`虚拟机`"的角色。是为了使用户从传统环境（虚拟机环境）向 k8s（容器环境）的迁移，更加平滑。
>
> 把 Pod 看成传统环境里的"机器"、把容器看作是运行在这个"机器"里的"用户程序"，那么很多关于 Pod 对象的设计就非常容易理解了。凡是调度、网络、存储，以及安全相关的属性，基本上是 Pod 级别的。
>
> 共同特征是，它们描述的是"机器"这个整体，而不是里面运行的"程序"。 比如：
>
> 配置这个"机器"的网卡（即：Pod 的网络定义）
>
> 配置这个"机器"的磁盘（即：Pod 的存储定义）
>
> 配置这个"机器"的防火墙（即：Pod 的安全定义）
>
> 这台"机器"运行在哪个服务器之上（即：Pod 的调度）
>

### **kind**

指定了这个 `API 对象的类型`（Type），是一个 Pod，根据实际情况，此处资源类型可以是`Deployment`、`Job`、`Ingress`、`Service`等。

### metadata

包含Pod的一些meta信息，比如名称、namespace、标签等信息。   

### spec

specification of the resource content 指定该资源的内容,包括一些container，storage，volume以及其他Kubernetes需要的参数，以及诸如是否在容器失败时重新启动容器的属性。可在特定Kubernetes API找到完整的Kubernetes Pod的属性。

### 容器可选的设置属性

除了上述的基本属性外，还能够指定复杂的属性，包括容器启动运行的命令、使用的参数、工作目录以及每次实例化是否拉取新的副本。 还可以指定更深入的信息，例如容器的退出日志的位置。

### 容器可选的设置属性包括

> name、image、command、args、workingDir、ports、env、resource、volumeMounts、livenessProbe、readinessProbe、livecycle、terminationMessagePath、imagePullPolicy、securityContext、stdin、stdinOnce、tty
>

### 跟"机器"相关的配置

### nodeSelector

是一个供用户`将 Pod 与 Node `进行绑定的字段

用法：

```
apiVersion: v1
  kind: Pod
  ...
  spec:
   nodeSelector:
    disktype: ssd
```

表示这个 Pod 永远只能运行在携带了"disktype: ssd"标签（Label）的节点上；否则，它将调度失败。

### NodeName

一旦 Pod 的这个字段被赋值，k8s就会被认为这个 Pod 已经经过了调度，调度的结果就是赋值的节点名字。这个字段一般由调度器负责设置，用户也可以设置它来"骗过"调度器，这个做法一般是在`测试或者调试`的时候才会用到。

### HostAliases

定义 Pod 的 hosts 文件（比如 /etc/hosts）里的内容，用法：

```
 apiVersion: v1
  kind: Pod
  ...
  spec:
   hostAliases:
   - ip: "10.1.2.3"
    hostnames:
    - "foo.remote"
    - "bar.remote"
  ...
```

这里设置了一组 IP 和 hostname 的数据。此Pod 启动后，/etc/hosts 的内容将如下所示：

```
# cat /etc/hosts
  \# Kubernetes-managed hosts file.
  127.0.0.1 localhost
  ...
  10.244.135.10 hostaliases-pod
  10.1.2.3 foo.remote
  10.1.2.3 bar.remote
```

>   注意：在 k8s 中，如果要设置 hosts 文件里的内容，一定要通过这种方法。否则，如果直接修改了 hosts 文件，在 Pod 被删除重建之后，kubelet 会自动覆盖掉被修改的内容。
>

> 凡是跟容器的 Linux Namespace 相关的属性，也一定是 Pod 级别的
>
> 原因：Pod 的设计，就是要让它里面的容器尽可能多地共享 Linux Namespace，仅保留必要的隔离和限制能力。这样，Pod 模拟出的效果，就跟虚拟机里程序间的关系非常类似了。
>

举例，一个 Pod 定义 yaml 文件如下：

```
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-shell
spec:
  shareProcessNamespace: true
  containers:
    - name: nginx
      image: nginx
    - name: shell
      image: busybox
      stdin: true
      tty: true
```

1. 定义了 shareProcessNamespace=true，表示这个 Pod 里的容器要共享 PID Namespace                                                                                                                     
2. 定义了两个容器：
    一个 nginx 容器
    一个开启了 tty 和 stdin 的 shell 容器

 在 Pod 的 YAML 文件里声明开启它们俩，等同于设置了 docker run 里的 -it（-i 即 stdin，-t 即 tty）参数。

可以直接认为 tty 就是 Linux 给用户提供的一个常驻小程序，用于接收用户的标准输入，返回操作系统的标准输出。为了能够在 tty 中输入信息，需要同时开启 stdin（标准输入流）。

此 Pod 被创建后，就可以使用 shell 容器的 tty 跟这个容器进行交互了。

创建资源并连接到 shell 容器的 tty 上：

```
[root@centos708 prome]# kubectl attach -it nginx-shell -c shell
If you don't see a command prompt, try pressing enter.
/ # 
```

在 shell 容器里执行 ps 指令，查看所有正在运行的进程：

```
/ # ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 /pause
    6 root      0:00 nginx: master process nginx -g daemon off;
   11 101       0:00 nginx: worker process
   12 root      0:00 sh
   17 root      0:00 ps aux
```

在容器里不仅可以看到它本身的 ps ax 指令，还可以看到 nginx 容器的进程，以及 Infra 容器的 /pause 进程。也就是说整个 Pod 里的每个容器的进程，对于所有容器来说都是可见的：它们共享了同一个 PID Namespace。 

凡是 Pod 中的容器要共享宿主机的 Namespace，也一定是 Pod 级别的定义

比如：

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-shell
spec:
  hostNetwork: true
  hostIPC: true
  hostPID: true
  containers:
   - name: nginx
     image: daocloud.io/library/nginx
   - name: shell
     image: daocloud.io/library/busybox
     stdin: true
     tty: true
```

定义了共享宿主机的 Network、IPC 和 PID Namespace。这样，此 Pod 里的所有容器，会直接使用宿主机的网络、直接与宿主机进行 IPC 通信、看到宿主机里正在运行的所有进程。

## 容器属性

Pod 里最重要的字段"Containers"：

"Containers"和"Init Containers"这两个字段都属于 Pod 对容器的定义，内容也完全相同，只是` Init Containers 的生命周期，会先于所有的 Containers`，并且严格按照定义的顺序执行。

k8s 对 Container 的定义，和 Docker 相比并没有什么太大区别。

Docker中Image（镜像）、Command（启动命令）、workingDir（容器的工作目录）、Ports（容器要开发的端口），以及 volumeMounts（容器要挂载的 Volume）都是构成 k8s 中 Container 的主要字段。 

### 其他的容器属性

### ImagePullPolicy 字段

`定义镜像的拉取策略`。之所以是一个 Container 级别的属性，是因为容器镜像本来就是 Container 定义中的一部分。

默认值： `Always`

表示每次创建 Pod 都重新拉取一次镜像。当容器的镜像是类似于 nginx 或者 nginx:latest 这样的名字时，ImagePullPolicy 也会被认为 Always。

值：`Never` 或者 `IfNotPresent`

表示 Pod 永远不会主动拉取这个镜像，或者只在宿主机上不存在这个镜像时才拉取。

### Lifecycle(生命周期) 字段

`定义 Container Lifecycle Hooks`。作用是在容器状态发生变化时触发一系列"钩子"。

例子：这是 k8s 官方文档的一个 Pod YAML 文件

在这个例子中，容器成功启动之后，在 /usr/share/message 里写入了一句"欢迎信息"（即 postStart 定义的操作）。而在这个容器被删除之前，我们则先调用了 nginx 的退出指令（即 preStop 定义的操作），从而实现了容器的"优雅退出"。

```
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
spec:
  containers:
    - name: lifecycle-demo-container
      image: daocloud.io/library/nginx
      lifecycle:
        postStart:
          exec:
            command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"]
        preStop:
          exec:
            command: ["/usr/sbin/nginx","-s","quit"]
```

1. 定义了一个 nginx 镜像的容器

2. 设置了一个 postStart 和 preStop 参数

#### postStart

是在容器启动后，立刻执行一个指定的操作。

> 注意：
>
>  postStart 定义的操作，虽然是在 Docker 容器 ENTRYPOINT 执行之后，但它并不严格保证顺序,也就是说，在 postStart 启动时，ENTRYPOINT 有可能还没有结束。如果 postStart执行超时或者错误，k8s 会在该 Pod 的 Events 中报出该容器启动失败的错误信息，导致 Pod 也处于失败的状态。
>

#### preStop

 是容器被杀死之前（比如，收到了 SIGKILL 信号）。

> 注意：
>
> preStop 操作的执行，是同步的。所以，它会阻塞当前的容器杀死流程，直到这个 Hook 定义操作完成之后，才允许容器被杀死，这跟 postStart 不一样。
>

### Status

一个Pod 对象在 Kubernetes 中的生命周期

Pod 生命周期的变化，主要体现在 Pod API 对象的Status 部分，这是除了 Metadata 和 Spec 之外的第三个重要字段。其中，`pod.status.phase`，就是 Pod 的当前状态，有如下几种可能的情况：

#### Pending
 此状态表示Pod 的 YAML 文件已经提交给了 Kubernetes，API 对象已经被创建并保存在 Etcd 当中。但这个 Pod 里有些容器因为某种原因而不能被顺利创建。比如，调度不成功。

#### Running
此状态表示Pod 已经调度成功，跟一个具体的节点绑定。它包含的容器都已经创建成功，并且至少有一个正在运行中。

#### Succeeded
 此状态表示 Pod 里的所有容器都正常运行完毕，并且已经退出了。这种情况在运行一次性任务时最为常见。

#### Failed
此状态表示 Pod 里至少有一个容器以不正常的状态（非 0 的返回码）退出。 这个状态的出现，意味着你得想办法 Debug 这个容器的应用，比如查看 Pod 的 Events 和日志。

#### Unknown
 这是一个异常状态，表示 Pod 的状态不能持续地被 kubelet 汇报给 kube-apiserver,这很有可能是主从节点（Master 和 Kubelet）间的通信出现了问题。


Pod 对象的 Status 字段，还可以再细分出一组 Conditions：

  这些细分状态的值包括：PodScheduled、Ready、Initialized，以及 Unschedulable

  它们主要用于描述造成当前 Status 的具体原因是什么。

  比如, Pod 当前的 Status 是 Pending，对应的 Condition 是 Unschedulable，这表示它的调度出现了问题。

  比如, Ready 这个细分状态表示 Pod 不仅已经正常启动（Running 状态），而且已经可以对外提供服务了。这两者之间（Running 和 Ready）是有区别的，仔细思考一下。

Pod 的这些状态信息，是判断应用运行情况的重要标准，尤其是 Pod 进入了非"Running"状态后，一定要能迅速做出反应，根据它所代表的异常情况开始跟踪和定位，而不是去手忙脚乱地查阅文档。

有基础的可以仔细阅读 $GOPATH/src/k8s.io/kubernetes/vendor/k8s.io/api/core/v1/types.go 里，type Pod struct ，尤其是 PodSpec 部分的内容。

## 投射数据卷 Projected Volume

> 注：Projected Volume 是 Kubernetes v1.11 之后的新特性
>

### 什么是Projected Volume

在 k8s 中，有几种特殊的 Volume，它们的意义不是为了存放容器里的数据，也不是用来进行容器和宿主机之间的数据交换。而是为容器提供预先定义好的数据。

从容器的角度来看，这些 Volume 里的信息仿佛是被 k8s "投射"（Project）进入容器当中的。

> k8s 支持的 Projected Volume 一共有四种
>
>   Secret
>
>   ConfigMap
>
>   Downward API
>
>   ServiceAccountToken
>

## kubernetes中资源清单常用字段

常用字段以及含义

| 字段名                                      | 类型   | 说明                                                         |
| :------------------------------------------ | :----- | :----------------------------------------------------------- |
| version                                     | string | 代表`k8s api接口的版本`，通常是执行各种命令调用接口的资源路径，可以用kubectl api-versions 查询 |
| kind                                        | string | 代表`资源类型`，如Pod                                        |
| metadata                                    | object | `元数据对象`                                                 |
| metadata.name                               | string | `元数据对象名称` 如Pod的名字等                               |
| metadata.namespace                          | string | `元数据的命名空间`，指的是资源所处的命名空间                 |
| Spec                                        | object | `详细的定义资源对象`                                         |
| Spec.containers[]                           | list   | `资源中的容器列表`                                           |
| Spec.containers[].name                      | string | `容器名称`                                                   |
| Spec.containers[].image                     | string | `容器的镜像地址`                                             |
| Spec.containers[].imagePullPolicy           | string | `定义镜像的下载策略`，Always:每次都重新拉取镜像，Never:仅使用本地镜像，ifNotPresent: 本地如果没有则拉取镜像，默认为Always |
| Spec.containers[].command[]                 | list   | 指定`容器启动的命令`，如果不指定则执行镜像打包时的命令       |
| Spec.containers[].args[]                    | list   | 指定`容器启动的参数`                                         |
| Spec.containers[].workingDir                | string | 指定`容器的工作目录`，相当于dockerfile中指定的根目录         |
| Spec.containers[].volumeMounts[]            | list   | 指定`容器内部的存储卷配置`                                   |
| Spec.containers[].volumeMounts[].name       | string | 指定被`容器挂载的存储卷名称`                                 |
| Spec.containers[].volumeMounts[].mountPath  | string | 指定被`容器挂载的存储卷的路径`                               |
| Spec.containers[].volumeMounts[].readOnly   | string | 指定`存储卷的读写模式`，true/false， 默认为读写模式          |
| Spec.containers[].ports[]                   | list   | 指定`容器需要的端口`                                         |
| Spec.containers{}.ports[].name              | string | `端口名称`                                                   |
| Spec.containers{}.ports[].containerPort     | string | 容器的`监听端口号`                                           |
| Spec.containers{}.ports[].hostPort          | string | `主机需要监听的端口号`，需要注意的是如果扩展副本同主机这个端口号会有冲突 |
| Spec.containers{}.ports[].protocol          | string | 指定`容器的端口协议`，默认为TCP，也可以指定为UDP             |
| Spec.containers{}.env[]                     | list   | 指定`容器的运行环境变量`                                     |
| Spec.containers{}.env[].name                | string | 指定`环境变量名称`                                           |
| Spec.containers{}.env[].value               | string | 指定`环境变量值`                                             |
| Spec.containers{}.resources                 | object | 指定`容器所需资源和资源请求的值`                             |
| Spec.containers{}.resources.limits          | object | 指定`资源运行上限`                                           |
| Spec.containers{}.resources.limits.cpu      | string | 指定`cpu的限制`，单位为cores                                 |
| Spec.containers{}.resources.limits.memory   | string | 指定`内存限制`单位为MiB,GiB                                  |
| Spec.containers{}.resources.requests        | obejct | 指定`容器启动和调度限制`                                     |
| Spec.containers{}.resources.requests.cpu    | string | `cpu请求`，容器初始化时可用数量                              |
| Spec.containers{}.resources.requests.memory | string | `容器初始化时内存可用数量`                                   |
| Spec.restartPolicy                          | string | `定义容器的重启策略`，`Always`只要pod停止无论容器是否终止都会重启，`OnFailure`只有pod以非零退出码终止时才会重启，如果正常退出(0)则不会重启`Never`不重启 |
| Spec.nodeSeletor                            | object | `定义Pod的label标签`以Key/value的形式                        |
| Spec.imagePullSecrets                       | object | `定义镜像私有仓库的使用的secret名称`                         |
| Spec.hostNetWork                            | bool   | `定义是否使用主机网络模式`，默认false, 设置为true则会使用主机的网络而非docker网桥，同时无法在同一台主机启动该容器副本 |

# Secret详解

secret用来`保存小片敏感数据的k8s资源`，例如密码，token，或者秘钥。这类数据当然也可以存放在Pod或者镜像中，但是放在Secret中是为了更方便的控制如何使用数据，并减少暴露的风险。用户可以创建自己的secret，系统也会有自己的secret。`Pod需要先引用才能使用某个secret`

>
> Pod有2种方式来使用secret：
>
>   1. 作为volume的一个域被一个或多个容器挂载
>
>   2. 在拉取镜像的时候被kubelet引用。
>

### 內建的Secrets

由`ServiceAccount创建的API证书附加的秘钥`。 k8s自动生成的用来访问apiserver的Secret，所有Pod会默认使用这个Secret与apiserver通信

### 创建自己的Secret

  方式1：使用kubectl create secret命令

  方式2：yaml文件创建Secret

#### 命令方式创建secret:
假如某个Pod要访问数据库，需要用户名密码，分别存放在2个文件中：username.txt，password.txt

例子：
```
echo -n 'admin' > ./username.txt
echo -n '1f2d1e2e67df' > ./password.txt
```

kubectl create secret指令将用户名密码写到secret中，并在apiserver创建Secret
```
kubectl create secret generic db-user-pass --from-file=./username.txt --from-file=./password.txt
```
secret "db-user-pass" created

查看创建结果：
```
[root@centos710 ~]# kubectl get secret
NAME                  TYPE                                  DATA   AGE
db-user-pass          Opaque                                2      16s
default-token-65w84   kubernetes.io/service-account-token   3      8d
```
> 注：opaque：英[əʊˈpeɪk] 美[oʊˈpeɪk]  模糊
>

```
[root@centos710 ~]# kubectl describe secrets/db-user-pass
Name:         db-user-pass
Namespace:    default
Labels:       <none>
Annotations:  <none>
Type:  Opaque
Data
====
password.txt:  12 bytes
username.txt:  5 bytes
```
get或describe指令都不会展示secret的实际内容，这是出于对数据的保护的考虑，如果想查看实际内容使用命令：
```
[root@centos710 ~]# kubectl get secret db-user-pass -o json
{
    "apiVersion": "v1",
    "data": {
        "password.txt": "MWYyZDFlMmU2N2Rm",
        "username.txt": "YWRtaW4="
    },
    "kind": "Secret",
    "metadata": {
        "creationTimestamp": "2019-12-02T01:49:34Z",
        "name": "db-user-pass",
        "namespace": "default",
        "resourceVersion": "467049",
        "selfLink": "/api/v1/namespaces/default/secrets/db-user-pass",
        "uid": "92d46a90-6919-47ea-815d-5408d8529965"
    },
    "type": "Opaque"
}
```

#### yaml方式创建Secret：

创建一个secret.yaml文件，内容用base64编码
```
 echo -n 'admin' | base64
```

YWRtaW4=
```
echo -n '1f2d1e2e67df' | base64
```

MWYyZDFlMmU2N2Rm


yaml文件内容：

\# vim secret.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
 name: mysecret
type: Opaque
data:
 username: YWRtaW4=
 password: MWYyZDFlMmU2N2Rm
```

创建：
```
[root@centos710 ~]# kubectl create -f secret.yml 
secret/mysecret created
```
解析Secret中内容
```yaml
[root@centos710 ~]# kubectl get secret mysecret -o yaml
apiVersion: v1
data:
  password: MWYyZDFlMmU2N2Rm
  username: YWRtaW4=
kind: Secret
metadata:
  creationTimestamp: "2019-12-02T01:56:18Z"
  name: mysecret
  namespace: default
  resourceVersion: "467636"
  selfLink: /api/v1/namespaces/default/secrets/mysecret
  uid: 261942ce-f857-4403-930e-efbe2a437399
type: Opaque

```
\#base64解码：
```
echo 'MWYyZDFlMmU2N2Rm' | base64 --decode
```
1f2d1e2e67df


### 使用Secret

secret可以作为数据卷挂载或者作为环境变量暴露给Pod中的容器使用，也可以被系统中的其他资源使用。比如可以用secret导入与外部系统交互需要的证书文件等。

在Pod中以文件的形式使用secret

创建一个Secret，多个Pod可以引用同一个Secret

修改Pod的定义，在spec.volumes[]加一个volume，给这个volume起个名字，spec.volumes[].secret.secretName记录的是要引用的Secret名字

在每个需要使用Secret的容器中添加一项spec.containers[].volumeMounts[]，指定spec.containers[].volumeMounts[].readOnly = true，spec.containers[].volumeMounts[].mountPath要指向一个未被使用的系统路径。

修改镜像或者命令行使系统可以找到上一步指定的路径。此时Secret中data字段的每一个key都是指定路径下面的一个文件名

一个Pod中引用Secret的列子：

\# vim pod_use_secret.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: mypod
    image: redis:3.2.9
    volumeMounts:
      - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
    - name: foo
    secret:
      secretName: mysecret
```

每一个被引用的Secret都要在spec.volumes中定义
如果Pod中的多个容器都要引用这个Secret那么每一个容器定义中都要指定自己的volumeMounts，但是Pod定义中声明一次spec.volumes就好了。

### 映射secret key到指定的路径

可以控制secret key被映射到容器内的路径，利用spec.volumes[].secret.items来修改被映射的具体路径


```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: mypod
    image: redis
    volumeMounts:
      - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
    - name: foo
    secret:
      secretName: mysecret
      items:
        - key: username
          path: my-group/my-username
```


发生了什么呢？

username被映射到了文件/etc/foo/my-group/my-username而不是/etc/foo/username而password没有被使用,这种方式每个key的调用需要单独用key像username一样调用

### Secret文件权限

可以指定secret文件的权限，类似linux系统文件权限，如果不指定默认权限是0644，等同于linux文件的-rw-r--r--权限

设置默认权限位
```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: mypod
    image: redis
    volumeMounts:
      - name: foo
      mountPath: "/etc/foo"
  volumes:
    - name: foo
    secret:
      secretName: mysecret
      defaultMode: 256
```


上述文件表示将secret挂载到容器的/etc/foo路径，每一个key衍生出的文件，权限位都将是0400

这里用十进制数256表示0400，可以使用八进制0400

同理可以单独指定某个key的权限
```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: mypod
    image: redis
    volumeMounts:
      - name: foo
      mountPath: "/etc/foo"
  volumes:
    - name: foo
    secret:
      secretName: mysecret
      items:
        - key: username
        path: my-group/my-username
        mode: 511
```


### 从volume中读取secret的值

以文件的形式挂载到容器中的secret，他们的值已经是经过base64解码的了，可以直接读出来使用。
```
\# ls /etc/foo/
username
password
\# cat /etc/foo/username
admin
\# cat /etc/foo/password
1f2d1e2e67df
```

### 被挂载的secret内容自动更新

也就是如果修改一个Secret的内容，那么挂载了该Secret的容器中也将会取到更新后的值，但是这个时间间隔是由kubelet的同步时间决定的。最长的时间将是一个同步周期加上缓存生命周期(period+ttl)

特例：以subPath（https://kubernetes.io/docs/concepts/storage/volumes/#using-subpath）形式挂载到容器中的secret将不会自动更新

### 以环境变量的形式使用Secret

创建一个Secret，多个Pod可以引用同一个Secret

修改pod的定义，定义环境变量并使用env[].valueFrom.secretKeyRef指定secret和相应的key, 修改镜像或命令行，让它们可以读到环境变量

变量名：admin（secretkey(mysecret-->username=admin)）

 ```
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
    - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: username
      - name: SECRET_PASSWORD
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: password
    restartPolicy: Never
 ```


容器中读取环境变量，已经是base64解码后的值了：
```
\# echo $SECRET_USERNAME
admin
\# echo $SECRET_PASSWORD
1f2d1e2e67df
```

### 使用imagePullSecrets

创建一个专门用来访问镜像仓库的secret，当创建Pod的时候由kubelet访问镜像仓库并拉取镜像，具体描述文档在 这里

设置自动导入的imagePullSecrets

可以手动创建一个，然后在serviceAccount中引用它。所有经过这个serviceAccount创建的Pod都会默认使用关联的imagePullSecrets来拉取镜像，参考文档

自动挂载手动创建的Secret

 参考文档：https://kubernetes.io/docs/tasks/inject-data-application/podpreset/

### 限制

需要被挂载到Pod中的secret需要提前创建，否则会导致Pod创建失败

secret是有命名空间属性的，只有在相同namespace的Pod才能引用它

单个Secret容量限制的1Mb，这么做是为了防止创建超大的Secret导致apiserver或kubelet的内存耗尽。但是创建过多的小容量secret同样也会耗尽内存，这个问题在将来可能会有方案解决 

kubelet只支持由API server创建出来的Pod中引用secret，使用特殊方式创建出来的Pod是不支持引用secret的，比如通过kubelet的--manifest-url参数创建的pod，或者--config参数创建的，或者REST API创建的。

通过secretKeyRef引用一个不存在你secret key会导致pod创建失败

### 用例

Pod中的ssh keys

创建一个包含ssh keys的secret

```
kubectl create secret generic ssh-key-secret --from-file=ssh-privatekey=/path/to/.ssh/id_rsa --from-file=ssh-publickey=/path/to/.ssh/id_rsa.pub
```

创建一个Pod，其中的容器可以用volume的形式使用ssh keys

```
apiVersion: v1
kind: Pod
metadata:
  name: secret-test-pod
  labels:
    name: secret-test
spec:
  volumes:
    - name: secret-volume
    secret:
      secretName: ssh-key-secret
  containers:
    - name: ssh-test-container
    image: mySshImage
    volumeMounts:
      - name: secret-volume
      readOnly: true
      mountPath: "/etc/secret-volume"
```

Pod中区分生产和测试证书

创建2种不同的证书，分别用在生产和测试环境

```
# kubectl create secret generic prod-db-secret --from-literal=username=produser --from-literal=password=Y4nys7f11

secret "prod-db-secret" created

\# kubectl create secret generic test-db-secret --from-literal=username=testuser --from-literal=password=iluvtests

secret "test-db-secret" created
```

再创建2个不同的Pod

```
apiVersion: v1
kind: List
items:
  - kind: Pod
  apiVersion: v1
  metadata:
    name: prod-db-client-pod
    labels:
      name: prod-db-client
  spec:
    volumes:
      - name: secret-volume
      secret:
        secretName: prod-db-secret
    containers:
      - name: db-client-container
      image: myClientImage
      volumeMounts:
        - name: secret-volume
        readOnly: true
        mountPath: "/etc/secret-volume"
  - kind: Pod
  apiVersion: v1
  metadata:
    name: test-db-client-pod
    labels:
      name: test-db-client
  spec:
    volumes:
      - name: secret-volume
      secret:
        secretName: test-db-secret
    containers:
      - name: db-client-container
      image: myClientImage
      volumeMounts:
        - name: secret-volume
        readOnly: true
        mountPath: "/etc/secret-volume"
```

两个容器中都会有下列的文件

/etc/secret-volume/username

/etc/secret-volume/password

以“.”开头的key可以产生隐藏文件

```
kind: Secret
apiVersion: v1
metadata:
  name: dotfile-secret
data:
  .secret-file: dmFsdWUtMg0KDQo=
---
kind: Pod
apiVersion: v1
metadata:
  name: secret-dotfiles-pod
spec:
  volumes:
    - name: secret-volume
    secret:
      secretName: dotfile-secret
  containers:
    - name: dotfile-test-container
    image: k8s.gcr.io/busybox
    command:
      - ls
      - "-l"
      - "/etc/secret-volume"
    volumeMounts:
      - name: secret-volume
      readOnly: true
      mountPath: "/etc/secret-volume"
```

会在挂载目录下产生一个隐藏文件，/etc/secret-volume/.secret-file

## 实验

Secret

作用是帮你把 Pod 想要访问的加密数据，存放到 Etcd 中。然后，就可以通过在 Pod 的容器里挂载 Volume 的方式，访问到这些 Secret 里保存的信息了。

Secret 典型的使用场景：

  存放数据库的 Credential 信息

例子：

\# cat test-projected-volume.yaml 

```
apiVersion: v0
kind: Pod
metadata:
  name: test-projected-volume
spec:
  containers:
    - name: test-secret-volume
      image: busybox
      args:
        - sleep
        - "86399"
      volumeMounts:
        - name: mysql-cred
          mountPath: "/projected-volume"
          readOnly: true
  volumes:
    - name: mysql-cred
      projected:
        sources:
          - secret:
            name: user
          - secret:
            name: pass
```

定义了一个容器,它声明挂载的 Volume是 projected 类型 , 并不是常见的 emptyDir 或者 hostPath 类型，

而这个 Volume 的数据来源（sources），则是名为 user 和 pass 的 Secret 对象，分别对应的是数据库的用户名和密码。

这里用到的数据库的用户名、密码，正是以 Secret 对象的方式交给 Kubernetes 保存的。

方法1. 使用 kubectl create secret 指令创建Secret对象

```
# cat ./username.txt
admin
\# cat ./password.txt
c1oudc0w!

\# kubectl create secret generic user --from-file=./username.txt

\# kubectl create secret generic pass --from-file=./password.txt
```

username.txt 和 password.txt 文件里，存放的就是用户名和密码；而 user 和 pass，则是为 Secret 对象指定的名字。

查看Secret 对象：

```
\# kubectl get secrets
```

方法2. 通过编写 YAML 文件的方式来创建这个 Secret 对象

```
apiVersion: v1

kind: Secret

metadata:

 name: mysecret

type: Opaque

data:

 user: YWRtaW4=

 pass: MWYyZDFlMmU2N2Rm
```

Secret 对象要求这些数据必须是经过 Base64 转码的，以免出现明文密码的安全隐患。

转码操作：

```
# echo -n 'admin' | base64

YWRtaW4=

\# echo -n '1f2d1e2e67df' | base64

MWYyZDFlMmU2N2Rm
```

> 注意：像这样创建的 Secret 对象，它里面的内容仅仅是经过了转码，并没有被加密。生产环境中，需要在 Kubernetes 中开启 Secret 的加密插件，增强数据的安全性。
>

用yaml方式创建的secret调用方法如下：

\# cat test-projected-volume.yaml 

```
 apiVersion: v1
 kind: Pod
 metadata:
   name: test-projected-volume1
 spec:
   containers:
     - name: test-secret-volume1
       image: busybox
       args:
         - sleep
         - "86400"
       volumeMounts:
         - name: mysql-cred
           mountPath: "/projected-volume"
           readOnly: true
   volumes:
     - name: mysql-cred
       secret:
         secretName: mysecret
```

创建这个 Pod：

```
\# kubectl create -f test-projected-volume.yaml
```

验证这些 Secret 对象是不是已经在容器里了：

```
\# kubectl exec -it test-projected-volume1 -- /bin/sh
```

> 注意：
>
>   报错：上面这条命令会报错如下
>
>   \# kubectl exec -it test-projected-volume /bin/sh
>
>   error: unable to upgrade connection: Forbidden (user=system:anonymous, verb=create, resource=nodes, subresource=proxy)
>
>   解决：绑定一个cluster-admin的权限
>
>   \# kubectl create clusterrolebinding system:anonymous  --clusterrole=cluster-admin  --user=system:anonymous
>
>   clusterrolebinding.rbac.authorization.k8s.io/system:anonymous created
>

```
/ # ls /projected-volume/
user
pass
/ # cat /projected-volume/user
root
/ # cat /projected-volume/pass
1f2d1e2e67df
```

结果中看到，保存在 Etcd 里的用户名和密码信息，已经以文件的形式出现在了容器的 Volume 目录里。

而这个文件的名字，就是 kubectl create secret 指定的 Key，或者说是 Secret 对象的 data 字段指定的 Key。

### 同步更新：

通过挂载方式进入到容器里的 Secret，一旦其对应的 Etcd 里的数据被更新，这些 Volume 里的文件内容，同样也会被更新，kubelet 组件在定时维护这些 Volume。

1. 生成新的密码数据：

```
# echo -n '111111' | base64

MTExMTEx
```

2 . 修改数据：

\# cat mysecret.yaml 

```
apiVersion: v1

kind: Secret

metadata:

 name: mysecret

type: Opaque

data:

 user: YWRtaW4=

 pass: MTExMTEx
```

3. 更新数据：

```
# kubectl apply -f mysecret.yaml 

Warning: kubectl apply should be used on resource created by either kubectl create --save-config or kubectl apply

secret/mysecret configured
```

4. 查看对应pod里的数据是否更新：

```
# kubectl exec -it test-projected-volume1 /bin/sh

/ # cat projected-volume/pass 

111111/ #
```

> 注：这个更新可能会有一定的延时。所以在编写应用程序时，在发起数据库连接的代码处写好重试和超时的逻辑，绝对是个好习惯。
>

查看secret具体的值：

\# kubectl get secret mysecret -o json

```
{

  "apiVersion": "v1",

  "data": {

​    "pass": "MTExMTEx",

​    "user": "YWRtaW4="

  },

  "kind": "Secret",

  "metadata": {

​    "annotations": {

​      "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"data\":{\"pass\":\"MTExMTEx\",\"user\":\"YWRtaW4=\"},\"kind\":\"Secret\",\"metadata\":{\"annotations\":{},\"name\":\"mysecret\",\"namespace\":\"default\"},\"type\":\"Opaque\"}\n"

​    },

​    "creationTimestamp": "2019-01-21T07:31:05Z",

​    "name": "mysecret",

​    "namespace": "default",

​    "resourceVersion": "125857",

​    "selfLink": "/api/v1/namespaces/default/secrets/mysecret",

​    "uid": "82e20780-1d4e-11e9-baa8-000c29f01606"

  },

  "type": "Opaque"

}
```

# ConfigMap详解

ConfigMap与 Secret 类似，用来存储配置文件的kubernetes资源对象，所有的配置内容都存储在etcd中。

> 与 Secret 的区别：
>
>   ConfigMap 保存的是`不需要加密的、应用所需的配置信息`。
>
> ConfigMap 的用法几乎与 Secret 完全相同：可以使用 `kubectl create configmap` 从文件或者目录创建 ConfigMap，也可以直接编写 ConfigMap 对象的 YAML 文件。
>

## 创建ConfigMap

1. 创建ConfigMap

创建ConfigMap的方式有4种：

> 方式1：通过直接在命令行中指定configmap参数创建，即--from-literal
>
> 方式2：通过指定文件创建，即将一个配置文件创建为一个ConfigMap，--from-file=<文件>
>
> 方式3：通过指定目录创建，即将一个目录下的所有配置文件创建为一个ConfigMap，--from-file=<目录>
>
> 方式4：事先写好标准的configmap的yaml文件，然后kubectl create -f 创建
>

1.1 通过命令行参数--from-literal创建

创建命令：

```
[root@master yaml]# kubectl create configmap test-config1 --from-literal=db.host=10.5.10.116 --from-literal=db.port='3306'
configmap/test-config1 created
```

结果如下面的data内容所示： 

```
[root@centos708 prome]# kubectl get configmap test-config1 -o yaml
apiVersion: v1
data:
  db.host: 10.5.10.116
  db.port: "3306"
kind: ConfigMap
metadata:
  creationTimestamp: "2019-12-07T07:24:31Z"
  name: test-config1
  namespace: default
  resourceVersion: "143065"
  selfLink: /api/v1/namespaces/default/configmaps/test-config1
  uid: 18bdbf91-d381-4eeb-89bb-2edd29a147a6
```

1.2 通过指定文件创建

编辑配置文件app.properties内容如下： 

```
[root@master yaml]# cat app.properties 
property.1 = value-1
property.2 = value-2
property.3 = value-3
property.4 = value-4
[mysqld]
!include /home/wing/mysql/etc/mysqld.cnf
port = 3306
socket = /home/wing/mysql/tmp/mysql.sock
pid-file = /wing/mysql/mysql/var/mysql.pid
basedir = /home/mysql/mysql
datadir = /wing/mysql/mysql/var
```

创建（可以有多个--from-file）：

```
kubectl create configmap test-config2 --from-file=./app.properties
```

结果如下面data内容所示： 

```
[root@master yaml]# kubectl get configmap test-config2 -o yaml
apiVersion: v1
data:
 app.properties: |
  property.1 = value-1
  property.2 = value-2
  property.3 = value-3
  property.4 = value-4
  [mysqld]
  !include /home/wing/mysql/etc/mysqld.cnf
  port = 3306
  socket = /home/wing/mysql/tmp/mysql.sock
  pid-file = /wing/mysql/mysql/var/mysql.pid
  basedir = /home/mysql/mysql
  datadir = /wing/mysql/mysql/var
kind: ConfigMap
metadata:
 creationTimestamp: "2019-02-14T08:29:33Z"
 name: test-config2
 namespace: default
 resourceVersion: "8176"
 selfLink: /api/v1/namespaces/default/configmaps/test-config2
 uid: a8237769-3032-11e9-abbe-000c290a5b8b
```

通过指定文件创建时，configmap会创建一个key/value对，key是文件名，value是文件内容。

如不想configmap中的key为默认的文件名，可以在创建时指定key名字：

```
\# kubectl create configmap game-config-3 --from-file=<my-key-name>=<path-to-file>
```

1.3 指定目录创建

configs 目录下的config-1和config-2内容如下所示： 

```
[root@master yaml]# tail configs/config-1
aaa
bbb
c=d
[root@master yaml]# tail configs/config-2
eee
fff
h=k
```

创建：

```
# kubectl create configmap test-config3 --from-file=./configs
```

结果下面data内容所示： 

```
[root@master yaml]# kubectl get configmap test-config3 -o yaml
apiVersion: v1
data:
 config-1: |
  aaa
  bbb
  c=d
 config-2: |
  eee
  fff
  h=k
kind: ConfigMap
metadata:
 creationTimestamp: "2019-02-14T08:37:05Z"
 name: test-config3
 namespace: default
 resourceVersion: "8808"
 selfLink: /api/v1/namespaces/default/configmaps/test-config3
 uid: b55ffbeb-3033-11e9-abbe-000c290a5b8b
```

指定目录创建时，configmap内容中的各个文件会创建一个key/value对，key是文件名，value是文件内容。

假如目录中还包含子目录： 

在上一步的configs目录下创建子目录subconfigs，并在subconfigs下面创建两个配置文件，指定目录configs创建名为test-config4的configmap:

```
\# kubectl create configmap test-config4 --from-file=./configs
```

结果发现和上面没有子目录时一样，说明指定目录时只会识别其中的文件，忽略子目录

1.4 通过事先写好configmap的标准yaml文件创建

yaml文件内容如下： 注意其中一个key的value有多行内容时的写法

```
[root@master yaml]# cat configmap.yaml

apiVersion: v1

kind: ConfigMap

metadata:

 name: test-config4

 namespace: default

data:

 cache_host: memcached-gcxt

 cache_port: "11211"

 cache_prefix: gcxt

 my.cnf: |

  [mysqld]

  log-bin = mysql-bin

  haha = hehe
```

创建：

```
[root@master yaml]# kubectl apply -f configmap.yaml 

configmap/test-config4 created
```

结果如下面data内容所示： 

```
[root@master yaml]# kubectl get configmap test-config4 -o yaml
apiVersion: v1
data:
 cache_host: memcached-gcxt
 cache_port: "11211"
 cache_prefix: gcxt
 my.cnf: |
  [mysqld]
  log-bin = mysql-bin
  haha = hehe
kind: ConfigMap
metadata:
 annotations:
  kubectl.kubernetes.io/last-applied-configuration: |
   {"apiVersion":"v1","data":{"cache_host":"memcached-gcxt","cache_port":"11211","cache_prefix":"gcxt","my.cnf":"[mysqld]\nlog-bin = mysql-bin\nhaha = hehe\n"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"test-config4","namespace":"default"}}
 creationTimestamp: "2019-02-14T08:46:57Z"
 name: test-config4
 namespace: default
 resourceVersion: "9639"
 selfLink: /api/v1/namespaces/default/configmaps/test-config4
 uid: 163fbe1e-3035-11e9-abbe-000c290a5b8b
```

查看configmap的详细信息：
```
kubectl describe configmap
```
### 使用ConfigMap

2. 使用ConfigMap

使用ConfigMap有三种方式，一种是通过环境变量的方式，直接传递pod，另一种是通过在pod的命令行下运行的方式，第三种是使用volume的方式挂载入到pod内

示例ConfigMap文件：

```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: special-config
  namespace: default
data:
  special.how: very
  special.type: charm
```

 

2.1 通过环境变量使用

(1) 使用valueFrom、configMapKeyRef、name、key指定要用的key:

```
[root@centos708 prome]# cat dapi-test-pod.yaml 
---
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: daocloud.io/library/nginx
      env:
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.how
        - name: SPECIAL_TYPE_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.type
  restartPolicy: Never
```

测试：

```
[oot@centos708 prome]# kubectl exec -it dapi-test-pod /bin/bash
root@dapi-test-pod:/# echo $SPECIAL_TYPE_KEY
charm
```

(2) 通过`envFrom`、`configMapRef`、`name`使得configmap中的所有key/value对儿  都自动变成环境变量：

```
apiVersion: v1
kind: Pod
metadata:
 name: dapi-test-pod
spec:
 containers:
  - name: test-container
   image: daocloud.io/library/nginx
   envFrom:
   - configMapRef:
     name: special-config
 restartPolicy: Never
```

这样容器里的变量名称直接使用configMap里的key名：

```
[root@centos708 prome]# kubectl exec -it dapi-test-pod /bin/bash
root@dapi-test-pod:/# env
HOSTNAME=dapi-test-pod
NJS_VERSION=0.3.3
NGINX_VERSION=1.17.1
NGINX_PORT_80_TCP=tcp://10.96.221.137:80
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
NGINX_PORT=tcp://10.96.221.137:80
PKG_RELEASE=1~stretch
KUBERNETES_PORT=tcp://10.96.0.1:443
SPECIAL_LEVEL_KEY=very
PWD=/
HOME=/root
NGINX_SERVICE_PORT=80
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP_PORT=443
NGINX_PORT_80_TCP_ADDR=10.96.221.137
NGINX_PORT_80_TCP_PORT=80
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
SPECIAL_TYPE_KEY=charm
TERM=xterm
NGINX_PORT_80_TCP_PROTO=tcp
SHLVL=1
KUBERNETES_SERVICE_PORT=443
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_SERVICE_HOST=10.96.0.1
NGINX_SERVICE_HOST=10.96.221.137
_=/usr/bin/env
```

2.2 在启动命令中引用

在容器内执行命令时引用，需要先设置为环境变量，之后可以通过$(VAR_NAME)设置容器启动命令的启动参数：

> 注:
>
> 这个容器在执行完成之后因为没有运行的bash和tty,所以会退出，pod会处于completed状态
>

  可以用共享volume的方式查看最终的结果

```
apiVersion: v1
kind: Pod
metadata:
 name: dapi-test-pod
spec:
 containers:
  - name: test-container
   image: k8s.gcr.io/busybox
   command: [ "/bin/sh", "-c", "echo $(SPECIAL_LEVEL_KEY) $(SPECIAL_TYPE_KEY)" ]
   env:
    - name: SPECIAL_LEVEL_KEY
     valueFrom:
      configMapKeyRef:
       name: special-config
       key: SPECIAL_LEVEL
    - name: SPECIAL_TYPE_KEY
     valueFrom:
      configMapKeyRef:
       name: special-config
       key: SPECIAL_TYPE
 restartPolicy: Never
```

 

下面这个例子可以看到结果：

```
# cat testpod.yaml 
apiVersion: v1
kind: Pod
metadata:
 name: testpod1
spec:
 containers:
  - name: test-container
   image: daocloud.io/library/nginx:1.7.9
   volumeMounts:
   - name: shared-data
    mountPath: /pod-data
  - name: test-container1
   image: daocloud.io/library/nginx:1.7.9
   volumeMounts:
    - name: shared-data
     mountPath: /data
   command: [ "touch" ]
   args: [ "/data/a.txt" ]
 volumes:
 - name: shared-data
  hostPath:    
   path: /data
```

   

2.3 作为volume挂载使用

(1) 把1.4中test-config4所有key/value挂载进来：

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
 name: nginx-configmap
spec:
 replicas: 1
 template:
  metadata:
   labels:
    app: nginx-configmap
  spec:
   containers:
   - name: nginx-configmap
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:   
    - name: config-volume4
     mountPath: /tmp/config4
   volumes:
   - name: config-volume4
    configMap:
     name: test-config4
```

 

进入容器中/tmp/config4查看： 

```
[root@master yaml]# kubectl  exec -it nginx-configmap-7447bf77d6-svj2t /bin/bash
root@nginx-configmap-7447bf77d6-svj2t:/# ls /tmp/config4/

cache_host  cache_port	cache_prefix  my.cnf

root@nginx-configmap-7447bf77d6-svj2t:/# cat /tmp/config4/cache_host 

memcached-gcxt
```

可以看到，在config4文件夹下以每一个key为文件名value为值创建了多个文件。

(2) 假如不想以key名作为配置文件名可以引入items 字段，在其中逐个指定要用相对路径path替换的key：

```
volumes:

   \- name: config-volume4

​    configMap:

​     name: test-config4

​     items:

​     \- key: my.cnf   //原来的key名

​      path: mysql-key

​     \- key: cache_host  //原来的key名

​      path: cache-host
```

> 备注：
>
> 删除configmap后原pod不受影响；然后再删除pod后，重启的pod的events会报找不到cofigmap的volume；
>
> pod起来后再通过kubectl edit configmap …修改configmap，过一会pod内部的配置也会刷新。
>
> 在容器内部修改挂进去的配置文件后，过一会内容会再次被刷新为原始configmap内容
>

 

(3) 还可以为以configmap挂载进的volume添加subPath字段: 

```
volumeMounts:

​    \- name: config-volume5

​     mountPath: /tmp/my

​     subPath: my.cnf

​    \- name: config-volume5

​     mountPath: /tmp/host

​     subPath: cache_host

​    \- name: config-volume5

​     mountPath: /tmp/port

​     subPath: cache_port

​    \- name: config-volume5

​     mountPath: /tmp/prefix

​     subPath: cache_prefix

   volumes:

   \- name: config-volume5

​    configMap:

​     name: test-config4    
```

注意在容器中的形式与（2）中的不同，（2）中是个链接，链到..data/<key-name>。 

备注：

删除configmap后原pod不受影响；然后再删除pod后，重启的pod的events会报找不到cofigmap的volume。

pod起来后再通过kubectl edit configmap …修改configmap，pod内部的配置也会自动刷新。

在容器内部修改挂进去的配置文件后，内容可以持久保存，除非杀掉再重启pod才会刷回原始configmap的内容。

subPath必须要与configmap中的key同名。

mountPath如/tmp/prefix： 

<1>当/tmp/prefix不存在时(备注：此时/tmp/prefix和/tmp/prefix/无异)，会自动创建prefix文件并把value写进去； 

<2>当/tmp/prefix存在且是个文件时，里面内容会被configmap覆盖； 

<3>当/tmp/prefix存在且是文件夹时，无论写/tmp/prefix还是/tmp/prefix/都会报错。

 

例：使用configmap替换nginx的配置文件

```
# cat configpod.yaml

apiVersion: v1

kind: Pod

metadata:

  name: confignginx

  labels:

   app: nginx

spec:

  containers:

   \- name: confignginx

​    image: daocloud.io/library/nginx:alpine

​    ports:

​     \- containerPort: 80

​    volumeMounts:

​     \- name: configvolume

​      mountPath: /etc/nginx/nginx.conf

​      subPath: nginx.conf

  volumes:

   \- name: configvolume

​    configMap:

​     name: configmaptest
```

 

3.configmap的热更新

更新 ConfigMap 后：

1. 使用该 ConfigMap 挂载的 Env 不会同步更新

ENV 是在容器启动的时候注入的，启动之后 kubernetes 就不会再改变环境变量的值，且同一个 namespace 中的 pod 的环境变量是不断累加的。

2. 使用该 ConfigMap 挂载的 Volume 中的数据需要一段时间（实测大概10秒）才能同步更新

注意：使用subPath的方式挂载的volume是不能自动更新的     

为了更新容器中使用 ConfigMap 挂载的配置，可以通过滚动更新 pod 的方式来强制重新挂载 ConfigMap，也可以在更新了 ConfigMap 后，先将副本数设置为 0，然后再扩容。

 

# Downward API

用于在容器中获取 POD 的基本信息，kubernetes原生支持。Downward API提供了两种方式用于将 POD 的信息注入到容器内部：

### 环境变量

  用于单个变量，可以将 POD 信息和容器信息直接注入容器内部。

### Volume挂载

  将 POD 信息生成为文件，直接挂载到容器内部中去。

**环境变量的方式**

通过Downward API来将 POD 的 IP、名称以及所对应的 namespace 注入到容器的环境变量中去，然后在容器中打印全部的环境变量来进行验证。

使用fieldRef获取 POD 的基本信息：

```
\# cat test-env-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: test-env-pod
  namespace: kube-system
spec:
  containers:
    - name: test-env-pod
      image: daocloud.io/library/nginx
    env:
      - name: POD_NAME
        valueFrom:
          fieldRef:
            filePath: metadata.name
      - name: POD_NAMESPACE
        valueFrom:
          fielRef:
            filePath: metadata.namespace
      - name: POD_IP
        valueFrom:
          fielRef:
            filePath: status.podIP
```

注意： POD 的 name 和 namespace 属于元数据，是在 POD 创建之前就已经定下来了的，所以使用 metata 获取就可以了，但是对于 POD 的 IP 则不一样，因为POD IP 是不固定的，POD 重建了就变了，它属于状态数据，所以使用 status 去获取：

  所有基本信息可以使用下面的方式去查看（describe方式看不出来）：

```
\# kubectl  get pod first-pod -o yaml
```

创建上面的 POD：

```
# kubectl create -f test-env-pod.yaml

pod "test-env-pod" created 
```

POD 创建成功后，查看：

```
[root@master yaml]# kubectl exec -it test-env-pod /bin/bash -n kube-system

root@test-env-pod:/# env | grep POD

POD_IP=172.30.19.24

POD_NAME=test-env-pod

POD_NAMESPACE=kube-system                                                                  
```

## Volume挂载

通过Downward API将 POD 的 Label、Annotation 等信息通过 Volume 挂载到容器的某个文件中去，然后在容器中打印出该文件的值来验证。

```
\# test-volume-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-volume-pod
  namespace: kube-system
  labels:
     k8s-app: test-volume
     node-env: test
  annotations:
    build: test
    own: qikqiak
spec:
  containers:
    - name: test-volume-pod-container
      image: daocloud.io/library/nginx:1.13.0-alpine
      volumeMounts:
        - name: podinfo
          mountPath: /etc/podinfo
      volumes:
        - name: podinfo
      downwardAPI:
        items:
        - path: "labels"
          fieldRef:
            fieldPath: metadata.labels
              - path: "annotations"
                fieldRef:
                  fieldPath: metadata.annotations
```

将元数据 labels 和 annotaions 以文件的形式挂载到了/etc/podinfo目录下，创建上面的 POD ：

```
# kubectl create -f test-volume-pod.yaml

pod "test-volume-pod" create
```

在实际应用中，如果你的应用有获取 POD 的基本信息的需求，就可以利用Downward API来获取基本信息，然后编写一个启动脚本或者利用initContainer将 POD 的信息注入到容器中去，然后在自己的应用中就可以正常的处理相关逻辑了。

目前 Downward API 支持的字段：

1. 使用 fieldRef 可以声明使用:

> spec.nodeName - 宿主机名字
>
> status.hostIP - 宿主机 IP
>
> metadata.name - Pod 的名字
>
> metadata.namespace - Pod 的 Namespace
>
> status.podIP - Pod 的 IP
>
> spec.serviceAccountName - Pod 的 Service Account 的名字
>
> metadata.uid - Pod 的 UID
>
> metadata.labels['<KEY>'] - 指定 <KEY> 的 Label 值
>
> metadata.annotations['<KEY>'] - 指定 <KEY> 的 Annotation 值
>
> metadata.labels - Pod 的所有 Label
>
> metadata.annotations - Pod 的所有 Annotation
>

2. 使用 resourceFieldRef 可以声明使用:

> 容器的 CPU limit
>
> 容器的 CPU request
>
> 容器的 memory limit
>
> 容器的 memory request
>

上面这个列表的内容，随着 Kubernetes 项目的发展肯定还会不断增加。所以这里列出来的信息仅供参考，在使用 Downward API 时，还是要记得去查阅一下官方文档。

> 注意：Downward API 能够获取到的信息，一定是 Pod 里的容器进程启动之前就能够确定下来的信息。而如果你想要获取 Pod 容器运行后才会出现的信息，比如，容器进程的 PID，那就肯定不能使用 Downward API 了，而应该考虑在 Pod 里定义一个 sidecar 容器。
>

Secret、ConfigMap，以及 Downward API 这三种 Projected Volume 定义的信息，大多还可以通过环境变量的方式出现在容器里。但是，通过环境变量获取这些信息的方式，不具备自动更新的能力。一般情况下，`建议使用 Volume 文件的方式获取这些信息`。

# ServiceAccount详解

## ServiceAccount概念

官方文档地址：https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/

k8s中提供了良好的多租户认证管理机制，如RBAC、ServiceAccount还有各种Policy等。

### 什么是 Service Account 

当`用户访问集群`（例如使用kubectl命令）时，apiserver 会将用户认证为一个特定的 User Account（目前通常是admin，除非系统管理员自定义了集群配置）。

`Pod 容器中的进程也可以与 apiserver 联系`。 当它们在联系 apiserver 的时候，它们会被认证为一个特定的 Service Account（例如default）。

### 使用场景

Service Account它并不是给kubernetes集群的用户使用的，而是给`pod里面的进程使用`的，它为pod提供必要的身份认证。

**Service account与User account区别**

1. User account是为人设计的，而service account则是为Pod中的进程调用Kubernetes API或其他外部服务而设计的

2. User account是跨namespace的，而service account则是仅局限它所在的namespace；

3. 每个namespace都会自动创建一个default service account   

  4. Token controller检测service account的创建，并为它们创建secret   

5. 开启ServiceAccount Admission Controller后:

​    5.1 每个Pod在创建后都会自动设置spec.serviceAccount为default（除非指定了其他ServiceAccout）

​    5.2 验证Pod引用的service account已经存在，否则拒绝创建

​    5.3 如果Pod没有指定ImagePullSecrets，则把service account的ImagePullSecrets加到Pod中

​    5.4 每个container启动后都会挂载该service account的token和ca.crt到/var/run/secrets/kubernetes.io/serviceaccount/     

```
# kubectl exec nginx-3137573019-md1u2 ls /var/run/secrets/kubernetes.io/serviceaccount
        ca.crt
        namespace
        token  
```

### 查看系统的config配置

这里用到的token就是被授权过的SeviceAccount账户的token,集群利用token来使用ServiceAccount账户

```
 [root@master yaml]#  cat /root/.kube/config
```

## 默认Service Account

默认在 pod 中使用自动挂载的 service account 凭证来访问 API，如 Accessing the Cluster（https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/#accessing-the-api-from-a-pod） 中所描述。

当创建 pod 的时候，如果没有指定一个 service account，系统会自动在与该pod 相同的 namespace 下为其指派一个default service account，并且使用默认的 Service Account 访问 API server。

例如：

获取刚创建的 pod 的原始 json 或 yaml 信息，将看到spec.serviceAccountName字段已经被设置为 default。

```
 kubectl get pods podename -o yam 
```

取消为 service account 自动挂载 API 凭证  

>   注：
>
>  因为我们平时用不到取消默认service account，所以本实验未测试取消之后的效果，你如果感兴趣可以自行测试  
>

  Service account 是否能够取得访问 API 的许可取决于你使用的 授权插件和策略（https://kubernetes.io/docs/reference/access-authn-authz/authorization/#a-quick-note-on-service-accounts）。

  在 1.6 以上版本中，可以选择取消为 service account 自动挂载 API 凭证，只需在 service account 中设置 automountServiceAccountToken: false：

```
apiVersion: v1
kind: ServiceAccount
metadata:
 name: build-robot
automountServiceAccountToken: false
...
```

只取消单个 pod 的 API 凭证自动挂载：

```
apiVersion: v1
kind: Pod
metadata:
 name: my-pod
spec:
 serviceAccountName: build-robot
 automountServiceAccountToken: false
 ...
```

 **pod 设置中的优先级更高**

如果在 pod 和 service account 中同时设置了 automountServiceAccountToken , pod 设置中的优先级更高。

### 探索默认的 ServiceAccount

使用kubectl 的客户端镜像（镜像在讲DOCKER的时候制作的wing/kubectl）

```
kubectl run kubectl --image=wing/kubectl --restart=Never sleep 10000

kubectl get pod kubectl -o jsonpath="{.spec.serviceAccount}"
```

由于我们没有指定任何ServiceAccount, Kubernetes会自动指定默认值。该帐户是用名称空间创建的。 

```
# kubectl exec -it kubectl -- sh

\# cd /var/run/secrets/kubernetes.io/serviceaccount /

\# ls -la
```

测试权限：

```
# kubectl get pods //禁止错误，无权限

\# exit

\# kubectl delete pod kubectl
```

## Service Account应用示例01

注：本例未涉及rbac授权，现在可以做实验

**Service Account（服务账号）测试示例**

因为平时系统会使用默认service account，我们不需要自己创建，感觉不到service account的存在，本实验是使用自己手动创建的service account

1、创建serviceaccount

```
[root@centos708 prome]# kubectl create serviceaccount mysa
serviceaccount/mysa created
```

2、查看mysa

```
[root@centos708 prome]# kubectl describe sa mysa
Name:                mysa
Namespace:           default
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   mysa-token-jdw74
Tokens:              mysa-token-jdw74
Events:              <none>
```

3、查看mysa自动创建的secret

```
[root@centos708 prome]# kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-kr5dr   kubernetes.io/service-account-token   3      2d1h
mysa-token-jdw74      kubernetes.io/service-account-token   3      94s
```

4、使用mysa的sa资源配置pod

\# cat mysa-pod.yaml

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: my-pod
spec:
  containers:
    - name: my-pod
      image: daocloud.io/library/nginx
      ports:
        - name: http
          containerPort: 80
  serviceAccountName: mysa
```

5、导入

```
\# kubectl apply -f  mysa-pod.yaml
```

6、查看

```
\# kubectl  describe pod nginx-pod
```

7、查看使用的token和secret（使用的是mysa的token）

```
[root@centos708 prome]# kubectl  get  pod nginx-pod  -o jsonpath={".spec.volumes"}
[map[name:mysa-token-jdw74 secret:map[defaultMode:420 secretName:mysa-token-jdw74]]]
```

## ServiceAccount应用示例02

> 注:
>
> 本例是为理解ServiceAccount，因为涉及到rbac授权，所以这里不是要大家操作,如果想操作一下可以看下一个例子，或者后面部署dashboard应用的时候会用到，可以看一下dashboard是怎么使用ServiceAccount的
>

使用service account的实例：

  使用 Service Account 作为用户权限管理配置 kubeconfig

创建服务账号（serviceAccount）：

```
\# kubectl create serviceaccount sample-sc
```

查看 serviceaccount 账号：

```
\# kubectl get serviceaccount sample-sc -o yaml
```

```
apiVersion: v1
kind: ServiceAccount
metadata:
 creationTimestamp: "2019-02-15T02:49:31Z"
 name: sample-sc
 namespace: default
 resourceVersion: "37256"
 selfLink: /api/v1/namespaces/default/serviceaccounts/sample-sc
 uid: 518ad3d6-30cc-11e9-abbe-000c290a5b8b
secrets:
- name: sample-sc-token-4brlw 
```

#### 查看sample-sc帐号的token

因为在使用 serviceaccount 账号配置 kubeconfig 的时候需要使用到 sample-sc 的 token， 该 token 保存在该 serviceaccount 保存的 secret 中

其中 {data.token} 就是用户 token 的 base64 编码，之后配置 kubeconfig 的时候将会用到它

```
\# kubectl get secret sample-sc-token-4brlw -o yaml
```

```
apiVersion: v1

data:

 ca.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNU1ESXhOREEyTlRNME5Gb1hEVEk1TURJeE1UQTJOVE0wTkZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTHdmCjRIZEhod2hPRnVLNlVBRWcxekhzSGFBZS9VUUh5VGdPOG5LZ3FaK1BQQU9iOVc2dDZoeG1MKzBscGNFSS9xWFkKT3JFY2l5cVpnT0piV05jSUFYaCs3WmxDdk9BdzZpYmxmQy9oMUw1cWZGWkwvVXlNb3pUSWFVRUsweEV1bFNFMAp6SVJCN3R5aUNLSy9RODJEakk3NEVwQmxyUTE4UkYrQytrR3Fjb0d4a0FXZzZRU2x0cmJCTGRXQlc3NEdBVkI0ClZSRFk4S3c0Mm96WWZZRFErZ09BMjd4VnNaQWJRRDZUWmVTU0RHOVVyaU9NOVhmMVQ3ZytQY3hoMHZCL1ROcGgKdXJNL2tNUTM5eHNqazFEUms4L0tLQnlNZE9xd1lxZ3RwWUdvQnZVMDZnK1ZvL2tkWXJ2WnFoTy9oVmFBem00dwo1YmNsYUx5WDlBc1RZeFhYQXIwQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFINW5YOXJBS2lDSGcvOWNVT1dXMWdRK2hZc1gKb2Flakt0TnAvbmJKTnJITGZrV3hWTFc4eU5Xem1BWnYzcDFZOENCMDF2OEtGNEdrVy9CSk81aVpXRTVvSVZuVQo2Nkp5Y1doTVV2RmFTQWN5MnJUVXpvcWh5YnVDaVJsSS9ScUVZNjQvbVZVdjFTK1dndzBaYSszK1FpSC9LNHVUCmVzcnhvQUdHRnBpd3JCQ0FGMjZxZHRuMTdjRTJRcHNHcFlyY1hOZ3BlSHpaK2ZLMkZuUzBiYkJMb082YlA4ZGYKQlVPZldvb1JteWUxdmtHWWlKcFZUajFDcDBKNkcxazc3NWZGMUlkQmNrelhyQmF2N0xkdml5S2dtRFN1ODFYegpuZ3AzMWx1bE9wdXVETHRiM0svVTZUTHNRVWlHN2hlOUg3eVMybk5tVnA0cWRIRC9MMzJiUU40dDEzRT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=

 namespace: ZGVmYXVsdA==

 token: ZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNklpSjkuZXlKcGMzTWlPaUpyZFdKbGNtNWxkR1Z6TDNObGNuWnBZMlZoWTJOdmRXNTBJaXdpYTNWaVpYSnVaWFJsY3k1cGJ5OXpaWEoyYVdObFlXTmpiM1Z1ZEM5dVlXMWxjM0JoWTJVaU9pSmtaV1poZFd4MElpd2lhM1ZpWlhKdVpYUmxjeTVwYnk5elpYSjJhV05sWVdOamIzVnVkQzl6WldOeVpYUXVibUZ0WlNJNkluTmhiWEJzWlMxell5MTBiMnRsYmkwMFluSnNkeUlzSW10MVltVnlibVYwWlhNdWFXOHZjMlZ5ZG1salpXRmpZMjkxYm5RdmMyVnlkbWxqWlMxaFkyTnZkVzUwTG01aGJXVWlPaUp6WVcxd2JHVXRjMk1pTENKcmRXSmxjbTVsZEdWekxtbHZMM05sY25acFkyVmhZMk52ZFc1MEwzTmxjblpwWTJVdFlXTmpiM1Z1ZEM1MWFXUWlPaUkxTVRoaFpETmtOaTB6TUdOakxURXhaVGt0WVdKaVpTMHdNREJqTWprd1lUVmlPR0lpTENKemRXSWlPaUp6ZVhOMFpXMDZjMlZ5ZG1salpXRmpZMjkxYm5RNlpHVm1ZWFZzZERwellXMXdiR1V0YzJNaWZRLmRQdkJFQzV1djhlTHZfSFNfQjRLd3phYkx2TUdjZzVmU3dXX19GaXNYS3FSTmRuU0dFUjBFNE4zUDRCd0UyY0xJUWloRlNSNnhOc3ZpMU5qb0h0QTk1Qjd6UmNFRFUzaVBjdXN3cWJNN1BINWQxcnBmWHVjSkNlaWpZcnRzVXprWEJ0TGVHRDRYMlpDdGFzYjU1UjlaWE1ldXZmRllQdzhzejBWWmh4a1RabjVrRDA4V2VnZEFnTWIyR3ZzX0psMWVxZWd5WF9zUm9sSUFKa3o2QnQ5SW8tV0lfcDhxeFZ3SEFhZlpuazBnVW5penV0eGFHZ1RjaVRZNk9FTUxmNVhnZFp2U0taTUpVY0FKeENOUWNmYmRMckRtSXdYWDBoMHVjM2tQTi14OVNZMjFMZlNlQV9zeHRiSmkzSnhlMjV2cFg4YmhYWGl4Y25xRWgwR19ITjNOdw==

kind: Secret

metadata:

 annotations:

  kubernetes.io/service-account.name: sample-sc

  kubernetes.io/service-account.uid: 518ad3d6-30cc-11e9-abbe-000c290a5b8b

 creationTimestamp: "2019-02-15T02:49:31Z"

 name: sample-sc-token-4brlw

 namespace: default

 resourceVersion: "37255"

 selfLink: /api/v1/namespaces/default/secrets/sample-sc-token-4brlw

 uid: 518d0a75-30cc-11e9-abbe-000c290a5b8b

type: kubernetes.io/service-account-token


```

 

创建角色（这里以后是rbac权限管理的内容了）

比如想创建一个只可以查看集群deployments，services，pods 相关的角色，使用如下配置

```
apiVersion: rbac.authorization.k8s.io/v1

\## 这里也可以使用 Role

kind: ClusterRole

metadata:

 name: mofang-viewer-role

 labels:

  from: mofang

rules:

\- apiGroups:       # 空字符串""表明使用core API group

 \- ""

 resources:

 \- pods

 \- pods/status

 \- pods/log

 \- services

 \- services/status

 \- endpoints

 \- endpoints/status

 \- deployments

 verbs:

 \- get

 \- list

 \- watch
```

 

创建角色绑定

```
apiVersion: rbac.authorization.k8s.io/v1

\## 这里也可以使用 RoleBinding

kind: ClusterRoleBinding

metadata:

 name: sample-role-binding

 labels:

  from: mofang

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: ClusterRole

 name: mofang-viewer-role　　　　#这里即绑定上面创建的clusterrole

subjects:

\- kind: ServiceAccount　　　　　　  #将clusterrole绑定到这个服务账户上

 name: sample-sc

 namespace: default
```

注意上面配置中的注意在复制的时候要删除干净，包括空格，否则出错

### 使用service account

  利用创建的 serviceaccount 配置kubeconfig来访问集群：

   经过以上的步骤，就可以利用最开始创建的 serviceaccount 配置kubeconfig来访问集群了， 同时可以动态更改 ClusterRole 的授权来及时控制某个账号的权限(这也是使用 serviceaccount 的好处)；

配置如下:

```
apiVersion: v1

clusters:

\- cluster:

  \## 这个是集群的 TLS 证书，与授权无关，使用统一的就可以

  certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvekNDQW1pZ0F3SUJBZ0lEQnN0WU1BMEdDU3FHU0liM0RRRUJDd1VBTUdJeEN6QUpCZ05WQkFZVEFrTk8KTVJFd0R3WURWUVFJREFoYWFHVkthV0Z1WnpFUk1BOEdBMVVFQnd3SVNHRnVaMXBvYjNVeEVEQU9CZ05WQkFvTQpCMEZzYVdKaFltRXhEREFLQmdOVkJBc01BMEZEVXpFTk1Bc0dBMVVFQXd3RWNtOXZkREFlRncweE9EQTFNamt3Ck16UXdNREJhRncwek9EQTFNalF3TXpRMU5UbGFNR294S2pBb0JnTlZCQW9USVdNMlpUbGpObUpqWVRjellqRTAKWTJNMFlXRTNPVE13WWpNNE5ERXhORFpqWVRFUU1BNEdBMVVFQ3hNSFpHVm1ZWFZzZERFcU1DZ0dBMVVFQXhNaApZelpsT1dNMlltTmhOek5pTVRSall6UmhZVGM1TXpCaU16ZzBNVEUwTm1OaE1JR2ZNQTBHQ1NxR1NJYjNEUUVCCkFRVUFBNEdOQURDQmlRS0JnUURMY0VaYnJwK0FrS1o0dThOSVUzbmNoVThiQTEyeEpHSkkzOXF1N3hoUWxHeUcKZmpBMWp1dXhxUzJoTi9ManAzbVc2R0hpbTN3aUl3Y3VZS1Q3dEY5b1R6OCtPOEFDNkdiemRYTEgvVFBNa0JnZgo5U1hoR2h3WGd2SUxvdjNudmVLUzNESXFTdSt5L04rWG4zOE45bndIcXpLSnZYTVE5a0lpQm5NeDBWeXNIUUlECkFRQUJvNEc2TUlHM01BNEdBMVVkRHdFQi93UUVBd0lDckRBUEJnTlZIUk1CQWY4RUJUQURBUUgvTUI4R0ExVWQKSXdRWU1CYUFGSVZhLzkwanpTVnZXRUZ2bm0xRk9adFlmWFgvTUR3R0NDc0dBUVVGQndFQkJEQXdMakFzQmdncgpCZ0VGQlFjd0FZWWdhSFIwY0RvdkwyTmxjblJ6TG1GamN5NWhiR2w1ZFc0dVkyOXRMMjlqYzNBd05RWURWUjBmCkJDNHdMREFxb0NpZ0pvWWthSFIwY0RvdkwyTmxjblJ6TG1GamN5NWhiR2w1ZFc0dVkyOXRMM0p2YjNRdVkzSnMKTUEwR0NTcUdTSWIzRFFFQkN3VUFBNEdCQUpYVGlYSW9DVVg4MUVJTmJ1VFNrL09qdEl4MzRyRXR5UG5PK0FTagpqSzNpNHd3UFEwS3kwOGZOU25TZnhDUTJ4RjU1MjE1U29TMzFTd0x6WUlUSnVYWkE3bFdPb1FTVFkvaUFMdVBCCi9rM0JsOE5QY2Z6OEY1eVk3L25jU3pYNHBNeDE4cjBjb09MTWJmWlRRcm1IcGZDTndtZGNCZUIrQm5EUkxQSkYKaDNJRAotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==

  server: https://192.168.1.205:6443

 name: beta

contexts:

\- context:

  cluster: beta

  user: beta-viewer

 name: beta-viewer

current-context: beta-viewer

kind: Config

preferences: {}

users:

\- name: beta-viewer

 user:

  \## 这个是我们在创建 serviceaccount 生成相关 secret 之后的 data.token 的 base64 解码字符，它本质是一个 jwt token

  token: ZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNklpSjkuZXlKcGMzTWlPaUpyZFdKbGNtNWxkR1Z6TDNObGNuWnBZMlZoWTJOdmRXNTBJaXdpYTNWaVpYSnVaWFJsY3k1cGJ5OXpaWEoyYVdObFlXTmpiM1Z1ZEM5dVlXMWxjM0JoWTJVaU9pSmtaV1poZFd4MElpd2lhM1ZpWlhKdVpYUmxjeTVwYnk5elpYSjJhV05sWVdOamIzVnVkQzl6WldOeVpYUXVibUZ0WlNJNkluTmhiWEJzWlMxell5MTBiMnRsYmkwMFluSnNkeUlzSW10MVltVnlibVYwWlhNdWFXOHZjMlZ5ZG1salpXRmpZMjkxYm5RdmMyVnlkbWxqWlMxaFkyTnZkVzUwTG01aGJXVWlPaUp6WVcxd2JHVXRjMk1pTENKcmRXSmxjbTVsZEdWekxtbHZMM05sY25acFkyVmhZMk52ZFc1MEwzTmxjblpwWTJVdFlXTmpiM1Z1ZEM1MWFXUWlPaUkxTVRoaFpETmtOaTB6TUdOakxURXhaVGt0WVdKaVpTMHdNREJqTWprd1lUVmlPR0lpTENKemRXSWlPaUp6ZVhOMFpXMDZjMlZ5ZG1salpXRmpZMjkxYm5RNlpHVm1ZWFZzZERwellXMXdiR1V0YzJNaWZRLmRQdkJFQzV1djhlTHZfSFNfQjRLd3phYkx2TUdjZzVmU3dXX19GaXNYS3FSTmRuU0dFUjBFNE4zUDRCd0UyY0xJUWloRlNSNnhOc3ZpMU5qb0h0QTk1Qjd6UmNFRFUzaVBjdXN3cWJNN1BINWQxcnBmWHVjSkNlaWpZcnRzVXprWEJ0TGVHRDRYMlpDdGFzYjU1UjlaWE1ldXZmRllQdzhzejBWWmh4a1RabjVrRDA4V2VnZEFnTWIyR3ZzX0psMWVxZWd5WF9zUm9sSUFKa3o2QnQ5SW8tV0lfcDhxeFZ3SEFhZlpuazBnVW5penV0eGFHZ1RjaVRZNk9FTUxmNVhnZFp2U0taTUpVY0FKeENOUWNmYmRMckRtSXdYWDBoMHVjM2tQTi14OVNZMjFMZlNlQV9zeHRiSmkzSnhlMjV2cFg4YmhYWGl4Y25xRWgwR19ITjNOdw==
```

# RBAC 详解

## 一个实验搞定RBAC

创建k8s账号与RBAC授权使用 

创建账号

1、创建私钥

```
umask 077; openssl genrsa -out wing.key 2048
```

用此私钥创建一个csr(证书签名请求)文件

```
openssl  req -new -key wing.key -out wing.csr -subj  "/CN=wing"
```

```
[root@centos708 prome]# openssl x509 -req -in wing.csr -CA  /etc/kubernetes/pki/ca.crt  -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out wing.crt -days 365
Signature ok
subject=/CN=wing
Getting CA Private Key
```

2、查看证书内容

```
openssl  x509 -in wing.crt  -text -noout
```

```
[root@centos708 prome]# kubectl  config  set-credentials wing  --client-certificate=./wing.crt  --client-key=./wing.key  --embed-certs=true
User "wing" set.
```

3、设置上下文

```
[root@centos708 prome]# kubectl  config  set-context  wing@kubernetes --cluster=kubernetes --user=wing
Context "wing@kubernetes" created.
```

   查看当前的工作上下文

```
 \# kubectl config view
```

4、切换用户（切换上下文）

```
[root@centos708 prome]# kubectl  config use-context wing@kubernetes
Switched to context "wing@kubernetes".
```

  验证是否已经切换到了新的上下文

```
[root@centos708 prome]# kubectl config current-context
wing@kubernetes
```

测试（还未赋予权限）

```
[root@centos708 prome]# kubectl get pod
Error from server (Forbidden): pods is forbidden: User "wing" cannot list resource "pods" in API group "" in the namespace "default" 
```

授权

K8S授权请求是http的请求

对象URL格式：

  /apis/[GROUP]/[VERSION]/namespace/[NAMESPACE_NAME]/[KIND]/[OBJECT_ID]

k8s授权方式分为：

  serviceaccount和自己签证ca证书的账号，及签证ca的用户组（group）上（授权给这个组的权限）

简介

role:

  1、允许的操作，如get,list等

  2、允许操作的对象，如pod,svc等

 rolebinding:

  将哪个用户绑定到哪个role或clusterrole上

clusterrole：(集群角色)

clusterrolebinding:(绑定到集群)

  3、如果使用rolebinding绑定到clusterrole上，表示绑定的用户只能用于当前namespace的权限

创建一个角色（role）

切回管理帐号先

```
# kubectl  config use-context kubernetes-admin@kubernetes

\# kubectl  create role  myrole  --verb=get,list,watch --resource=pod,svc
```

绑定用户wing（上面创建的用户），绑定role为myrole

```
\# kubectl  create  rolebinding myrole-binding  --role=myrole  --user=wing
```

切换用户

```
# kubectl  config use-context wing@kubernetes

Switched to context "wing@kubernetes".
```

查看权限（只授权了default名称空间pod和svc的get，list，watch权限）

```
# kubectl  get pod

NAME           READY   STATUS        RESTARTS  AGE

nginx-pod         0/1    ImagePullBackOff   0      1h
```

 

```
# kubectl  get pod -n kube-system #无权访问kube-system

No resources found.

Error from server (Forbidden): pods is forbidden: User "wing" cannot list pods in the namespace "kube-system"
```

 

```
# kubectl  delete pod nginx-pod #无删除权限

Error from server (Forbidden): pods "nginx-pod" is forbidden: User "wing" cannot delete pods in the namespace "default"
```

创建clusterrole #可以访问全部的namespace

```
\# kubectl  create clusterrole mycluster-role --verb=get,list,watch  --resource=pod,svc 
```

删除wing账号之前绑定的rolebinding

```
kubectl  delete rolebinding myrole-binding
```

使用clusterrolebinding绑定clusterrole

```
\# kubectl  create clusterrolebinding my-cluster-rolebinding  --clusterrole=mycluster-role  --user=wing
```

切换账号

```
\# kubectl  config use-context wing@kubernetes
```

查看权限 查看kube-system空间的pod

```
# kubectl  get pod -n kube-system
NAME               READY   STATUS   RESTARTS  AGE
coredns-78fcdf6894-67h9h     1/1    Running  1      11h
coredns-78fcdf6894-lzxmz     1/1    Running  1      11h
etcd-k8s-m            1/1    Running  2      11h 
```

配置一个新账号和配置文件并授权

创建证书
```
 umask 077; openssl genrsa -out k8s.key 2048
```
用此私钥创建一个csr(证书签名请求)文件(/0是组名)
```
openssl  req -new -key k8s.key -out k8s.csr -subj  "/CN=k8s/O=wing"
```
```
openssl x509 -req -in k8s.csr -CA  /etc/kubernetes/pki/ca.crt  -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out k8s.crt -days 365
```
查看证书内容
```
openssl  x509 -in k8s.crt  -text -noout
```

创建secret
创建一个generic的secre namespace设置为default
```
\# kubectl  create  secret generic k8s  -n default  --from-file=k8s.crt=./k8s.crt  --from-file=k8s.key=./k8s.key
```
查看
```
[root@centos708 prome]# kubectl get secret | grep k8s
k8s                   Opaque                                2      22s
```

配置生成
```
 kubectl config set-cluster  kubernetes   --certificate-authority=/etc/kubernetes/pki/ca.crt  --server="https://192.168.122.107:6443"  --embed-certs=true  --kubeconfig=./k8s.config
```

配置客户端认证
```
kubectl config set-credentials k8s --client-certificate=./k8s.crt  --client-key=./k8s.key --embed-certs=true  --kubeconfig=./k8s.config
```

配置关联
```
kubectl  config  set-context  k8s@user --cluster=kubernetes --user=k8s --kubeconfig=./k8s.config
```

创建role
```
kubectl  create role  k8s-role  --verb=get,list,watch --resource=pod,svc
```

创建rolebinding
```
kubectl  create  rolebinding k8s-rolebinding  --role=k8s-role  --user=k8s
```

替换配置文件
```
mv /root/.kube/config   /mnt/
cp k8s.config  /root/.kube/config
```

修改config的current-context内容
```
current-context: ""
改成
current-context:  k8s@user
```
查看
```
\# kubectl  get pod

NAME           READY   STATUS        RESTARTS  AGE

my-statefulset-0     0/1    ContainerCreating  0      8d

nginx-6f858d4d45-6qm6g  0/1    ImagePullBackOff   0      9d
```

```
\# kubectl  get pod  -n kube-system
No resources found.
Error from server (Forbidden): pods is forbidden: User "k8s" cannot list pods in the namespace "kube-system"
```

### 设置上下文和账户切换

>注：本节即上个实验中用到的切换用户操作
使用kubectl通过终端连接到k8s集群之后。可以设置要在哪个命名空间下进行操作。

设置工作上下文（前提得有用户）
```
kubectl  config  set-context  wing@kubernetes --cluster=kubernetes --user=wing
```

查看当前的工作上下文
```
[root@centos708 prome]# kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.122.107:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: k8s
  name: k8s@user
- context:
    cluster: kubernetes
    user: wing
  name: wing@kubernetes
current-context: k8s@user
kind: Config
preferences: {}
users:
- name: k8s
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
```

切换上下文（切换用户）
```
kubectl config use-context wing@kubernetes 
```
## RBAC 概念
RBAC基于角色的访问控制
Service Account为服务提供了一种方便的认证机制，但它不关心授权的问题。可以配合RBAC来为Service Account鉴权
在Kubernetes中，授权有ABAC（基于属性的访问控制）、RBAC（基于角色的访问控制）、Webhook、Node、AlwaysDeny(一直拒绝)和AlwaysAllow（一直允许）这6种模式。
从1.6版起，Kubernetes 默认启用RBAC访问控制策略。
从1.8开始，RBAC已作为稳定的功能。
在RABC API中，通过如下的步骤进行授权：
1）定义角色：在定义角色时会指定此角色对于资源的访问控制的规则；
2）绑定角色：将主体与角色进行绑定，对用户进行访问授权。

基于角色的访问控制（Role-Based Access Control）使用"rbac.authorization.k8s.io" API Group实现授权决策，允许管理员通过Kubernetes API动态配置策略。
定义Role、ClusterRole、RoleBinding或ClusterRoleBinding
### 启用RBAC
  要启用RBAC，使用--authorization-mode=RBAC启动API Server。

## Role与ClusterRole
  一个角色包含了一套表示一组权限的规则。 权限以纯粹的累加形式累积（没有"否定"的规则）。 

 #### Role  
角色可以由命名空间内的Role对象定义
一个Role对象只能用于授予对某一单一命名空间中资源的访问权限

  #### ClusterRole
 整个Kubernetes集群范围内有效的角色则通过ClusterRole对象实现。

#### Role示例
描述"default"命名空间中的一个Role对象的定义，用于授予对pod的读访问权限：
```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 namespace: default
 name: pod-reader
rules:
- apiGroups: [""] 　　　　　　# 空字符串""表明使用core API group
 resources: ["pods"]
 verbs: ["get", "watch", "list"]
```

#### ClusterRole示例
ClusterRole定义可用于授予用户对某一特定命名空间，或者所有命名空间中的secret（取决于其绑定方式）的读访问权限：
```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 \# ClusterRole是集群范围对象，所以这里不需要定义"namespace"字段
 name: secret-reader
rules:
- apiGroups: [""]
 resources: ["secrets"]
 verbs: ["get", "watch", "list"]
```
## RoleBinding与ClusterRoleBinding
角色绑定将一个角色中定义的各种权限授予一个或者一组用户。 

角色绑定包含:
1. 一组相关主体, 即:subject
   包括:
      用户--User
      用户组--Group
      服务账户--Service Account
2. 对被授予角色的引用

### RoleBinding
  在命名空间中可以通过RoleBinding对象授予权限
  RoleBinding可以引用在同一命名空间内定义的Role对象

### ClusterRoleBinding
  集群范围的权限授予则通过ClusterRoleBinding对象完成。

### RoleBinding示例
定义的RoleBinding对象在"default"命名空间中将"pod-reader"角色授予用户"jane"。 这一授权将允许用户"jane"从"default"命名空间中读取pod。

以下角色绑定定义将允许用户"jane"从"default"命名空间中读取pod。
```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 name: read-pods
 namespace: default
subjects:
- kind: User　　　　　　　　　　#赋予用户jane pod-reader角色权限
 name: jane
 apiGroup: rbac.authorization.k8s.io
roleRef:
 kind: Role
 name: pod-reader　　　　　　#引用上面定义的role
 apiGroup: rbac.authorization.k8s.io
```
RoleBinding对象也可以引用一个ClusterRole对象

  用于在RoleBinding所在的命名空间内授予用户对所引用的ClusterRole中定义的命名空间资源的访问权限。这一点允许管理员在整个集群范围内首先定义一组通用的角色，然后再在不同的命名空间中复用这些角色。

例如，尽管下面示例中的RoleBinding引用的是一个ClusterRole对象，但是用户"dave"（即角色绑定主体）还是只能读取"development" 命名空间中的secret（即RoleBinding所在的命名空间）。

\# 以下角色绑定允许用户 "dave" 读取 "development" 命名空间中的secret。
```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 name: read-secrets
 namespace: development 　　　　　　# 这里表明仅授权读取"development"命名空间中的资源。
subjects:
- kind: User
 name: dave
 apiGroup: rbac.authorization.k8s.io
roleRef:
 kind: ClusterRole
 name: secret-reader　　　　　　#引用上面定义的clusterRole 名称（clusterRole没有指定命名空间，默认可以应用所有，但是在rolebinding时，指定了命名空间，所以只能读取本命名空间的文件）
 apiGroup: rbac.authorization.k8s.io
```
ClusterRoleBinding在集群级别和所有命名空间中授予权限


\# 以下 'ClusterRoleBinding' 对象允许在用户组 "manager" 中的任何用户都可以读取集群中任何命名空间中的secret。
```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 name: read-secrets-global
subjects:
- kind: Group
 name: manager
 apiGroup: rbac.authorization.k8s.io
roleRef:
 kind: ClusterRole
 name: secret-reader
 apiGroup: rbac.authorization.k8s.io
```
## role对资源的引用
大多数资源由代表其名字的字符串表示，如 "pods"，就像它们出现在相关API endpoint的URL中一样。然而，有一些Kubernetes API还包含了 "子资源"

  比如pod的logs:

    pod logs endpoint的URL格式为：
      GET /api/v1/namespaces/{namespace}/pods/{name}/log
    这种情况下，"pods" 是命名空间资源，而 "log" 是pods的子资源。
    为了在RBAC角色中表示出这一点，需使用斜线来划分 资源 与 子资源。    

例子：
  如果需要角色绑定主体读取pods以及pod log，需要定义以下角色：
```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 namespace: default
 name: pod-and-pod-logs-reader
rules:
- apiGroups: [""]
 resources: ["pods", "pods/log"]　　　　#表示授予读取pods下log的权限
 verbs: ["get", "list"]
```

### resourceNames
通过 resourceNames 列表，角色可以针对不同种类的请求根据资源名引用资源实例。当指定了resourceNames 列表时，不同动作种类的请求的权限，如使用 "get"、"delete"、"update" 以及 "patch" 等动词的请求，将被限定到资源列表中所包含的资源实例上。 

例子: 
如果需要限定一个角色绑定主体只能 "get" 或者 "update" 一个configmap时，可以定义以下角色：
```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 namespace: default
 name: configmap-updater
rules:
- apiGroups: [""]
 resources: ["configmap"]
 resourceNames: ["my-configmap"]
 verbs: ["update", "get"]
```
> 注意:
>
> 如果设置了resourceNames，则请求所使用的动词不能是list、watch、create或者deletecollection。 由于资源名不会出现在create、list、watch和deletecollection等API请求的URL中，所以这些请求动词不会被设置了resourceNames 的规则所允许，因为规则中的resourceNames部分不会匹配这些请求。
>

### 一大波role定义示例
角色定义的例子
在以下示例中，仅截取展示了rules部分的定义。
1. 允许读取core API Group中定义的资源 "pods"：
```
rules:
- apiGroups: [""]
 resources: ["pods"]
 verbs: ["get", "list", "watch"]
```
1. 允许读写在 "extensions" 和 "apps" API Group中定义的 "deployments"：
```
rules:
- apiGroups: ["extensions", "apps"]
 resources: ["deployments"]
 verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```
1. 允许读取 "pods" 以及读写 "jobs"：
```
rules:
- apiGroups: [""]
 resources: ["pods"]
 verbs: ["get", "list", "watch"]
- apiGroups: ["batch", "extensions"]
 resources: ["jobs"]
 verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```
1. 允许读取一个名为 "my-config" 的 ConfigMap 实例（需要将其通过RoleBinding绑定从而限制针对某一个命名空间中定义的一个ConfigMap实例的访问）：
```
rules:
- apiGroups: [""]
 resources: ["configmaps"]
 resourceNames: ["my-config"]
 verbs: ["get"]
```
1. 允许读取core API Group中的"nodes"资源（由于Node是集群级别资源，所以此ClusterRole定义需要与一个ClusterRoleBinding绑定才能有效）：
```
rules:
- apiGroups: [""]
 resources: ["nodes"]
 verbs: ["get", "list", "watch"]
```
1. 允许对非资源endpoint "/healthz" 及其所有子路径的 "GET" 和 "POST" 请求（此ClusterRole定义需要与一个ClusterRoleBinding绑定才能有效）：
```
rules:
- nonResourceURLs: ["/healthz", "/healthz/*"] 　　# 在非资源URL中，'*'代表后缀通配符
 verbs: ["get", "post"]
```

## 对角色绑定主体（Subject）的引用
  RoleBinding或者ClusterRoleBinding将角色绑定到角色绑定主体（Subject）。 角色绑定主体（kind指定）可以是用户组（Group）、用户（User）或者服务账户（Service Accounts）。

用户
  由字符串表示。
1. 纯粹的用户名，例如 "alice"
2. 电子邮件风格的名字，如 "bob@example.com" 
3. 用字符串表示的数字id。

#### 用户的产生：
由Kubernetes管理员配置认证模块以产生所需格式的用户名。对于用户名，RBAC授权系统不要求任何特定的格式。

>   注意：
>
> 前缀system:是 为Kubernetes系统使用而保留的，所以管理员应该确保用户名不会意外地包含这个前缀。
>

#### 用户组的产生：
 Kubernetes中的用户组信息由授权模块提供。用户组与用户一样由字符串表示。Kubernetes对用户组 字符串没有格式要求，但前缀system:同样是被系统保留的。

#### 服务账户：
服务账户（serviceAccount）拥有包含 system:serviceaccount:前缀的用户名，并属于拥有system:serviceaccounts:前缀的用户组。

### 一大波角色绑定示例

角色绑定例子
以下示例中，仅截取展示了RoleBinding的subjects字段。

1. 一个名为"alice@example.com"的用户：
```
subjects:
- kind: User
 name: "alice@example.com"
 apiGroup: rbac.authorization.k8s.io
```
1. 一个名为"frontend-admins"的用户组：
```
subjects:
- kind: Group
 name: "frontend-admins"
 apiGroup: rbac.authorization.k8s.io
```
1. kube-system命名空间中的默认服务账户：
```
subjects:
- kind: ServiceAccount
 name: default
 namespace: kube-system
```
1. 名为"qa"命名空间中的所有服务账户：
```
subjects:
- kind: Group
 name: system:serviceaccounts:qa
 apiGroup: rbac.authorization.k8s.io
```
1. 在集群中的所有服务账户：
```
subjects:
- kind: Group
 name: system:serviceaccounts
 apiGroup: rbac.authorization.k8s.io
```
1. 所有认证过的用户（version 1.5+）：
```
subjects:
- kind: Group
 name: system:authenticated
 apiGroup: rbac.authorization.k8s.io
```
1. 所有未认证的用户（version 1.5+）：
```
subjects:
- kind: Group
 name: system:unauthenticated
 apiGroup: rbac.authorization.k8s.io
```
1. 所有用户（version 1.5+）：
```
subjects:
- kind: Group
 name: system:authenticated
 apiGroup: rbac.authorization.k8s.io
- kind: Group
 name: system:unauthenticated
 apiGroup: rbac.authorization.k8s.io
```
## 默认角色与默认角色绑定
API Server会创建一组默认的ClusterRole和ClusterRoleBinding对象。 这些默认对象中有许多包含system:前缀，表明这些资源由Kubernetes基础组件"拥有"。 对这些资源的修改可能导致非功能性集群（non-functional cluster）。

比如：system:node ClusterRole对象。 这个角色定义了kubelets的权限。如果这个角色被修改，可能会导致kubelets无法正常工作。

所有默认的ClusterRole和ClusterRoleBinding对象都会被标记为kubernetes.io/bootstrapping=rbac-defaults。

每次启动时，API Server都会更新默认ClusterRole所缺乏的各种权限，并更新默认ClusterRoleBinding所缺乏的各个角色绑定主体。 这种自动更新机制允许集群修复一些意外的修改。由于权限和角色绑定主体在新的Kubernetes释出版本中可能变化，这也能够保证角色和角色绑定始终保持是最新的。

如果需要禁用自动更新，请将默认ClusterRole以及ClusterRoleBinding的rbac.authorization.kubernetes.io/autoupdate 设置成为false。 请注意，缺乏默认权限和角色绑定主体可能会导致非功能性集群问题。

自Kubernetes 1.6+起，当集群RBAC授权器（RBAC Authorizer）处于开启状态时，可以启用自动更新功能

### 发现类角色
默认ClusterRole	默认ClusterRoleBinding	描述
system:basic-user	system:authenticated and system:unauthenticatedgroups	允许用户只读访问有关自己的基本信息。
system:discovery	system:authenticated and system:unauthenticatedgroups	允许只读访问API discovery endpoints, 用于在API级别进行发现和协商。

### 面向用户的角色
一些默认角色并不包含system:前缀，它们是面向用户的角色。 这些角色包含超级用户角色（cluster-admin），即旨在利用ClusterRoleBinding（cluster-status）在集群范围内授权的角色， 以及那些使用RoleBinding（admin、edit和view）在特定命名空间中授权的角色。

### 默认ClusterRole	默认ClusterRoleBinding	描述
cluster-admin	system:mastersgroup	超级用户权限，允许对任何资源执行任何操作。 在ClusterRoleBinding中使用时，可以完全控制集群和所有命名空间中的所有资源。 在RoleBinding中使用时，可以完全控制RoleBinding所在命名空间中的所有资源，包括命名空间自己。

admin	None	管理员权限，利用RoleBinding在某一命名空间内部授予。 在RoleBinding中使用时，允许针对命名空间内大部分资源的读写访问， 包括在命名空间内创建角色与角色绑定的能力。 但不允许对资源配额（resource quota）或者命名空间本身的写访问。

edit	None	允许对某一个命名空间内大部分对象的读写访问，但不允许查看或者修改角色或者角色绑定。

view	None	允许对某一个命名空间内大部分对象的只读访问。 不允许查看角色或者角色绑定。 由于可扩散性等原因，不允许查看secret资源。

### Core Component Roles核心组件角色
默认ClusterRole	默认ClusterRoleBinding	描述
system:kube-scheduler	system:kube-scheduler user	允许访问kube-scheduler组件所需要的资源。

system:kube-controller-manager	system:kube-controller-manageruser	允许访问kube-controller-manager组件所需要的资源。 单个控制循环所需要的权限请参阅控制器（controller）角色.

system:node	system:nodesgroup (deprecated in 1.7)	允许对kubelet组件所需要的资源的访问，包括读取所有secret和对所有pod的写访问。 自Kubernetes 1.7开始, 相比较于这个角色，更推荐使用Node authorizer 以及NodeRestriction admission plugin， 并允许根据调度运行在节点上的pod授予kubelets API访问的权限。 自Kubernetes 1.7开始，当启用Node授权模式时，对system:nodes用户组的绑定将不会被自动创建。

system:node-proxier	system:kube-proxyuser	允许对kube-proxy组件所需要资源的访问。

 

### 其它组件角色
默认ClusterRole	默认ClusterRoleBinding	描述

system:auth-delegator	None	允许委托认证和授权检查。 通常由附加API Server用于统一认证和授权。

system:heapster	None	Heapster组件的角色。

system:kube-aggregator	None	kube-aggregator组件的角色。

system:kube-dns	kube-dns service account in the kube-systemnamespace	kube-dns组件的角色。

system:node-bootstrapper	None	允许对执行Kubelet TLS引导（Kubelet TLS bootstrapping）所需要资源的访问.

system:node-problem-detector	None	node-problem-detector组件的角色。

system:persistent-volume-provisioner	None	允许对大部分动态存储卷创建组件（dynamic volume provisioner）所需要资源的访问。

### 控制器（Controller）角色
Kubernetes controller manager负责运行核心控制循环。 当使用--use-service-account-credentials选项运行controller manager时，每个控制循环都将使用单独的服务账户启动。 而每个控制循环都存在对应的角色，前缀名为system:controller:。 如果不使用--use-service-account-credentials选项时，controller manager将会使用自己的凭证运行所有控制循环，而这些凭证必须被授予相关的角色。 这些角色包括：

> system:controller:attachdetach-controller
>
> system:controller:certificate-controller
>
> system:controller:cronjob-controller
>
> system:controller:daemon-set-controller
>
> system:controller:deployment-controller
>
> system:controller:disruption-controller
>
> system:controller:endpoint-controller
>
> system:controller:generic-garbage-collector
>
> system:controller:horizontal-pod-autoscaler
>
> system:controller:job-controller
>
> system:controller:namespace-controller
>
> system:controller:node-controller
>
> system:controller:persistent-volume-binder
>
> system:controller:pod-garbage-collector
>
> system:controller:replicaset-controller
>
> system:controller:replication-controller
>
> system:controller:resourcequota-controller
>
> system:controller:route-controller
>
> system:controller:service-account-controller
>
> system:controller:service-controller
>
> system:controller:statefulset-controller

> system:controller:ttl-controller

### 初始化与预防权限升级
RBAC API会阻止用户通过编辑角色或者角色绑定来升级权限。 由于这一点是在API级别实现的，所以在RBAC授权器（RBAC authorizer）未启用的状态下依然可以正常工作。

 用户只有在拥有了角色所包含的所有权限的条件下才能创建／更新一个角色，这些操作还必须在角色所处的相同范围内进行（对于ClusterRole来说是集群范围，对于Role来说是在与角色相同的命名空间或者集群范围）。 

  例如：

如果用户"user-1"没有权限读取集群范围内的secret列表，那么他也不能创建包含这种权限的ClusterRole。为了能够让用户创建／更新角色，需要：

1. 授予用户一个角色以允许他们根据需要创建／更新Role或者ClusterRole对象。

2. 授予用户一个角色包含他们在Role或者ClusterRole中所能够设置的所有权限。如果用户尝试创建或者修改Role或者ClusterRole以设置那些他们未被授权的权限时，这些API请求将被禁止。

 用户只有在拥有所引用的角色中包含的所有权限时才可以创建／更新角色绑定（这些操作也必须在角色绑定所处的相同范围内进行）或者用户被明确授权可以在所引用的角色上执行绑定操作。 

  例如：

如果用户"user-1"没有权限读取集群范围内的secret列表，那么他将不能创建ClusterRole来引用那些授予了此项权限的角色。为了能够让用户创建／更新角色绑定，需要：

1. 授予用户一个角色以允许他们根据需要创建／更新RoleBinding或者ClusterRoleBinding对象。

2. 授予用户绑定某一特定角色所需要的权限：

     `隐式地`，通过授予用户所有所引用的角色中所包含的权限

       `显式地`，通过授予用户在特定Role（或者ClusterRole）对象上执行bind操作的权限

 例如，下面例子中的ClusterRole和RoleBinding将允许用户"user-1"授予其它用户"user-1-namespace"命名空间内的admin、edit和view等角色和角色绑定。
```
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
 name: role-grantor
rules:
- apiGroups: ["rbac.authorization.k8s.io"]
 resources: ["rolebindings"]
 verbs: ["create"]
- apiGroups: ["rbac.authorization.k8s.io"]
 resources: ["clusterroles"]
 verbs: ["bind"]
 resourceNames: ["admin","edit","view"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
 name: role-grantor-binding
 namespace: user-1-namespace
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: ClusterRole
 name: role-grantor
subjects:
- apiGroup: rbac.authorization.k8s.io
 kind: User
 name: user-1
```
当初始化第一个角色和角色绑定时，初始用户需要能够授予他们尚未拥有的权限。 初始化初始角色和角色绑定时需要：

使用包含system：masters用户组的凭证，该用户组通过默认绑定绑定到cluster-admin超级用户角色。

如果API Server在运行时启用了非安全端口（--insecure-port），也可以通过这个没有施行认证或者授权的端口发送角色或者角色绑定请求。

一些命令行工具
有两个kubectl命令可以用于在命名空间内或者整个集群内授予角色。
```
\# kubectl create rolebinding
```
在某一特定命名空间内授予Role或者ClusterRole
示例如下：

在名为"acme"的命名空间中将admin ClusterRole授予用户"bob"：
```
\# kubectl create rolebinding bob-admin-binding --clusterrole=admin --user=bob --namespace=acme
```
在名为"acme"的命名空间中将view ClusterRole授予服务账户"myapp"：
```
\# kubectl create rolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp --namespace=acme
```
```
\# kubectl create clusterrolebinding
```
在整个集群中授予ClusterRole，包括所有命名空间。

示例如下：
在整个集群范围内将cluster-admin ClusterRole授予用户"root"：
```
\# kubectl create clusterrolebinding root-cluster-admin-binding --clusterrole=cluster-admin --user=root
```

在整个集群范围内将system:node ClusterRole授予用户"kubelet"：
```
\# kubectl create clusterrolebinding kubelet-node-binding --clusterrole=system:node --user=kubelet
```

在整个集群范围内将view ClusterRole授予命名空间"acme"内的服务账户"myapp"：
```
\# kubectl create clusterrolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp
```

### 服务账户（Service Account）权限
默认的RBAC策略将授予控制平面组件（control-plane component）、节点（node）和控制器（controller）一组范围受限的权限， 但对于"kube-system"命名空间以外的服务账户，则不授予任何权限（超出授予所有认证用户的发现权限）。

从最安全到最不安全可以排序以下方法：

1. 对某一特定应用程序的服务账户授予角色（最佳实践）

2. 要求应用程序在其pod规范（pod spec）中指定serviceAccountName字段，并且要创建相应服务账户（例如通过API、应用程序清单或者命令kubectl create serviceaccount等）。
3. 
例如：
    在"my-namespace"命名空间中授予服务账户"my-sa"只读权限：
```
kubectl create rolebinding my-sa-view \

 --clusterrole=view \

 --serviceaccount=my-namespace:my-sa \

 --namespace=my-namespace
```

换成yaml文件大概如下 
```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 name: my-sa-view
 namespace: my-namespace
subjects:
- kind: ServiceAccount
 name: my-sa
 apiGroup: rbac.authorization.k8s.io
roleRef:
 kind: ClusterRole
 name: view　　　　          #这里view为clusterrole名称，其中berbs需要给view
 apiGroup: rbac.authorization.k8s.io
```
在某一命名空间中授予"default"服务账号一个角色

如果一个应用程序没有在其pod规范中指定serviceAccountName，它将默认使用"default"服务账号。

>注意：授予"default"服务账号的权限将可用于命名空间内任何没有指定serviceAccountName的pod。

例子：

  下面的例子将在"my-namespace"命名空间内授予"default"服务账号只读权限：
```
kubectl create rolebinding default-view \

 --clusterrole=view \

 --serviceaccount=my-namespace:default \

 --namespace=my-namespace
```

目前，许多加载项（addon）作为"kube-system"命名空间中的"default"服务帐户运行。 要允许这些加载项使用超级用户访问权限，请将cluster-admin权限授予"kube-system"命名空间中的"default"服务帐户。 注意：启用上述操作意味着"kube-system"命名空间将包含允许超级用户访问API的秘钥。
```
\# kubectl create clusterrolebinding add-on-cluster-admin \

 --clusterrole=cluster-admin \

 --serviceaccount=kube-system:default
```
为命名空间中所有的服务账号授予角色

如果希望命名空间内的所有应用程序都拥有同一个角色，无论它们使用什么服务账户，可以为该命名空间的服务账户用户组授予角色。

例子：

  下面的例子将授予"my-namespace"命名空间中的所有服务账户只读权限：
```
\# kubectl create rolebinding serviceaccounts-view \

 --clusterrole=view \

 --group=system:serviceaccounts:my-namespace \

 --namespace=my-namespace
```
对集群范围内的所有服务账户授予一个受限角色（不鼓励）

如果不想管理每个命名空间的权限，则可以将集群范围角色授予所有服务帐户。

例子：

  下面的例子将所有命名空间中的只读权限授予集群中的所有服务账户：
```
\#kubectl create clusterrolebinding serviceaccounts-view \

 --clusterrole=view \

 --group=system:serviceaccounts
```

授予超级用户访问权限给集群范围内的所有服务帐户（强烈不鼓励）

如果根本不关心权限分块，可以对所有服务账户授予超级用户访问权限。

警告：这种做法将允许任何具有读取权限的用户访问secret或者通过创建一个容器的方式来访问超级用户的凭据。
```
\# kubectl create clusterrolebinding serviceaccounts-cluster-admin \

 --clusterrole=cluster-admin \

 --group=system:serviceaccounts
```

### 并行授权器（authorizer）
同时运行RBAC和ABAC授权器，并包括旧版ABAC策略：

--authorization-mode=RBAC,ABAC --authorization-policy-file=mypolicy.jsonl

RBAC授权器将尝试首先授权请求。如果RBAC授权器拒绝API请求，则ABAC授权器将被运行。这意味着RBAC策略或者ABAC策略所允许的任何请求都是可通过的。

当以日志级别为2或更高（--v = 2）运行时，可以在API Server日志中看到RBAC拒绝请求信息（以RBAC DENY:为前缀）。 可以使用该信息来确定哪些角色需要授予哪些用户，用户组或服务帐户。 一旦授予服务帐户角色，并且服务器日志中没有RBAC拒绝消息的工作负载正在运行，可以删除ABAC授权器。

## 实验

RBAC 基于角色的访问控制（Role-Based Access Control）

Kubernetes 中所有的 API 对象，都保存在 Etcd 里。对这些 API 对象的操作，一定都是通过访问 kube-apiserver 实现的。其中一个非常重要的原因，就是你需要 APIServer 来帮助你做授权工作。

### RBAC
RBAC是负责完成授权（Authorization）工作的机制

三个基本概念：是整个 RBAC 体系的核心所在
Role：角色，其实是一组规则，定义了一组对 Kubernetes API 对象的操作权限。
Subject：被作用者，既可以是"人"，也可以是"机器"，也可以是你在 k8s 里定义的"用户"。
RoleBinding：定义了"被作用者"和"角色"的绑定关系。

### Role
Role 本身也是一个 k8s 的 API 对象，定义如下：
原文件：
```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
 namespace: mynamespace
 name: example-role
rules:
- apiGroups: [""]
 resources: ["pods"]
 verbs: ["get", "watch", "list"]
```
解释文件：

kind: Role

apiVersion: rbac.authorization.k8s.io/v1

metadata:

 namespace: mynamespace  //指定这个 Role 对象能产生作用的 Namepace 是：mynamespace。

 name: example-role

rules:  // rules 字段是这个role所定义的权限规则，含义是：允许"被作用者"，对 mynamespace 下面的 Pod 对象进行 GET、WATCH 和 LIST 操作

\- apiGroups: [""]

 resources: ["pods"]

 verbs: ["get", "watch", "list"]

>注：Namespace
> Namespace 是 Kubernetes 项目里的一个逻辑管理单位。不同 Namespace 的 API 对象，在通过 kubectl 命令进行操作的时候，是互相隔离开的。这仅限于逻辑上的"隔离"，Namespace 并不会提供任何实际的隔离或者多租户能力。没有指定 Namespace，就是使用默认 Namespace：default。

 

### RoleBinding
具体的"被作用者"的指定需要通过 RoleBinding 来实现
RoleBinding 本身也是一个 Kubernetes 的 API 对象。

定义如下：
```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
 name: example-rolebinding
 namespace: mynamespace
subjects:
- kind: User
 name: example-user
 apiGroup: rbac.authorization.k8s.io
roleRef:
 kind: Role
 name: example-role
 apiGroup: rbac.authorization.k8s.io
```
#### subjects 字段
即"被作用者"。它的类型是 User，即 Kubernetes 里的用户。这个用户的名字是 example-user。

  k8s 中，其实并没有一个叫作"User"的 API 对象。而且，在前面和部署使用 k8s 的流程里，既不需要 User，也没有创建过 User。

  这个 User 到底是从哪里来的？
 实际上，Kubernetes 里的"User"，只是一个授权系统里的逻辑概念。它需要通过外部认证服务，比如 Keystone，来提供。或者，也可以直接给 APIServer 指定一个用户名、密码文件。那么 Kubernetes 的授权系统，就能够从这个文件里找到对应的"用户"了。当然，在大多数私有的使用环境中，只要使用 k8s 提供的内置"用户"，就足够了。

#### roleRef 字段
通过这个字段，RoleBinding 对象可以直接通过名字，来引用前面定义的 Role 对象（example-role），从而定义了"被作用者（Subject）"和"角色（Role）"之间的绑定关系。

#### ClusterRole 和 ClusterRoleBinding
Role 和 RoleBinding 对象都是 Namespaced 对象（Namespaced Object），它们对权限的限制规则仅在它们自己的 Namespace 内有效，roleRef 也只能引用当前 Namespace 里的 Role 对象。

对于非 Namespaced（Non-namespaced）对象（比如：Node），或者，某一个 Role 想要作用于所有的 Namespace 的时候，必须要使用 ClusterRole 和 ClusterRoleBinding 这两个组合。这两个 API 对象的用法跟 Role 和 RoleBinding 完全一样。只不过，它们的定义里，没有了 Namespace 字段，如下所示：
```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
 name: example-clusterrole
rules:
- apiGroups: [""]
 resources: ["pods"]
 verbs: ["get", "watch", "list"]
```
```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
 name: example-clusterrolebinding
subjects:
- kind: User
 name: example-user
 apiGroup: rbac.authorization.k8s.io
roleRef:
 kind: ClusterRole
 name: example-clusterrole
 apiGroup: rbac.authorization.k8s.io
```

上例中 ClusterRole 和 ClusterRoleBinding 的组合，表示名叫 example-user 的用户，拥有对所有 Namespace 里的 Pod 进行 GET、WATCH 和 LIST 操作的权限。

所有的权限都有哪些？
在 Role 或者 ClusterRole 里面，如果要赋予用户 example-user 所有权限，可以给它指定一个 verbs 字段的全集，如下所示：
```
verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```
这些就是当前 Kubernetes（v1.11）里能够对 API 对象进行的所有操作了。

只针对某一个具体的对象进行权限设置

Role 对象的 rules 字段也可以进一步细化。比如，可以只针对某一个具体的对象进行权限设置，如下所示：
```
rules:
- apiGroups: [""]
 resources: ["configmaps"]
 resourceNames: ["my-config"]
 verbs: ["get"]
```

表示，这条规则的"被作用者"，只对名叫"my-config"的 ConfigMap 对象，有进行 GET 操作的权限。

#### k8s内置用户：ServiceAccount
在大多数时候，其实都不太使用"用户"这个功能，而是直接使用 Kubernetes 里的"内置用户"。
这个由 Kubernetes 负责管理的"内置用户"，正是前面曾经提到过的：ServiceAccount。

实例： 为 ServiceAccount 分配权限的过程。
1. 要定义一个 ServiceAccount。如下所示：
```
apiVersion: v1
kind: ServiceAccount
metadata:
 namespace: mynamespace
 name: example-sa
```
一个最简单的 ServiceAccount 对象只需要 Name 和 Namespace 这两个最基本的字段。

 2. 通过编写 RoleBinding 的 YAML 文件，来为这个 ServiceAccount 分配权限：
```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
 name: example-rolebinding
 namespace: mynamespace
subjects:
- kind: ServiceAccount
 name: example-sa
 namespace: mynamespace
roleRef:
 kind: Role
 name: example-role
 apiGroup: rbac.authorization.k8s.io
```
在这个 RoleBinding 对象里，subjects 字段的类型（kind），不再是一个 User，而是一个名叫 example-sa 的 ServiceAccount。而 roleRef 引用的 Role 对象，依然名叫 example-role，也就是一开始定义的 Role 对象。

3. 用 kubectl 命令创建这三个对象：
```
\# kubectl create -f svc-account.yaml

\# kubectl create -f role-binding.yaml

\# kubectl create -f role.yaml
```
4. 查看一下这个 ServiceAccount 的详细信息：
```
\# kubectl get sa -n mynamespace -o yaml

\- apiVersion: v1
 kind: ServiceAccount
 metadata:
  creationTimestamp: 2018-09-08T12:59:17Z
  name: example-sa
  namespace: mynamespace
  resourceVersion: "409327"
  ...
 secrets:
 \- name: example-sa-token-vmfg6
```
看到，k8s 会为一个 ServiceAccount 自动创建并分配一个 Secret 对象，即：上述 ServiceAcount 定义里最下面的 secrets 字段。

这个 Secret，就是这个 ServiceAccount 对应的、用来跟 APIServer 进行交互的授权文件，一般称它为：Token。Token 文件的内容一般是证书或者密码，它以一个 Secret 对象的方式保存在 Etcd 当中。

这时，用户的 Pod，就可以声明使用这个 ServiceAccount 了，比如下面这个例子：
```
apiVersion: v1
kind: Pod
metadata:
 namespace: mynamespace
 name: sa-token-test
spec:
 containers:
 - name: nginx
  image: nginx:1.7.9
 serviceAccountName: example-sa
```
在这个例子里，我定义了 Pod 要使用的要使用的 ServiceAccount 的名字是：example-sa。

等这个 Pod 运行起来之后，可以看到，该 ServiceAccount 的 token，也就是一个 Secret 对象，被 Kubernetes 自动挂载到了容器的 /var/run/secrets/kubernetes.io/serviceaccount 目录下，如下所示：
```
\# kubectl describe pod sa-token-test -n mynamespace

Name:        sa-token-test
Namespace:      mynamespace
...
Containers:
 nginx:
  ...
 Mounts:
  /var/run/secrets/kubernetes.io/serviceaccount from example-sa-token-vmfg6 (ro)
```

这时可通过 kubectl exec 查看到这个目录里的文件：
```
\# kubectl exec -it sa-token-test -n mynamespace -- /bin/bash

root@sa-token-test:/# ls /var/run/secrets/kubernetes.io/serviceaccount

ca.crt namespace  token
```
如上所示，容器里的应用，就可以使用这个 ca.crt 来访问 APIServer 了。更重要的是，此时它只能够做 GET、WATCH 和 LIST 操作。因为 example-sa 这个 ServiceAccount 的权限，已经被我们绑定了 Role 做了限制。

此外曾经提到过，如果一个 Pod 没有声明 serviceAccountName，Kubernetes 会自动在它的 Namespace 下创建一个名叫 default 的默认 ServiceAccount，然后分配给这个 Pod。

但在这种情况下，这个默认 ServiceAccount 并没有关联任何 Role。也就是说，此时它有访问 APIServer 的绝大多数权限。当然，这个访问所需要的 Token，还是默认 ServiceAccount 对应的 Secret 对象为它提供的，如下所示。
```
\# kubectl describe sa default

Name:         default
Namespace:      default
Labels:        <none>
Annotations:     <none>
Image pull secrets:  <none>
Mountable secrets:  default-token-s8rbq
Tokens:        default-token-s8rbq
Events:        <none>
```

```
\# kubectl get secret

NAME          TYPE                  DATA    AGE

kubernetes.io/service-account-token  3     82d
```

```
\# kubectl describe secret default-token-s8rbq

Name:     default-token-s8rbq
Namespace:   default
Labels:    <none>
Annotations:  kubernetes.io/service-account.name=default

​       kubernetes.io/service-account.uid=ffcb12b2-917f-11e8-abde-42010aa80002
Type:  kubernetes.io/service-account-token
Data
====
ca.crt:   1025 bytes
namespace:  7 bytes
token:    <TOKEN 数据 >
```
可以看到，Kubernetes 会自动为默认 ServiceAccount 创建并绑定一个特殊的 Secret：它的类型是kubernetes.io/service-account-token；它的 Annotation 字段，声明了kubernetes.io/service-account.name=default，即这个 Secret 会跟同一 Namespace 下名叫 default 的 ServiceAccount 进行绑定。


所以，在生产环境中，强烈建议为所有 Namespace 下的默认 ServiceAccount，绑定一个只读权限的 Role。这个具体怎么做，就当做思考题留给你了。

除了前面使用的"用户"（User），Kubernetes 还拥有"用户组"（Group）的概念，也就是一组"用户"的意思。如果你为 Kubernetes 配置了外部认证服务的话，这个"用户组"的概念就会由外部认证服务提供。

而对于 Kubernetes 的内置"用户"ServiceAccount 来说，上述"用户组"的概念也同样适用。

实际上，一个 ServiceAccount，在 Kubernetes 里对应的"用户"的名字是：

system:serviceaccount:<ServiceAccount 名字 >

而它对应的内置"用户组"的名字，就是：

system:serviceaccounts:<Namespace 名字 >

这两个对应关系，请你一定要牢记。

比如，现在我们可以在 RoleBinding 里定义如下的 subjects：

subjects:
```
\- kind: Group

 name: system:serviceaccounts:mynamespace

 apiGroup: rbac.authorization.k8s.io
```
这就意味着这个 Role 的权限规则，作用于 mynamespace 里的所有 ServiceAccount。这就用到了"用户组"的概念。

而下面这个例子：
```
subjects:

\- kind: Group

 name: system:serviceaccounts

 apiGroup: rbac.authorization.k8s.io
```
就意味着这个 Role 的权限规则，作用于整个系统里的所有 ServiceAccount。
后，值得一提的是，在 Kubernetes 中已经内置了很多个为系统保留的 ClusterRole，它们的名字都以 system: 开头。你可以通过 kubectl get clusterroles 查看到它们。

一般来说，这些系统 ClusterRole，是绑定给 Kubernetes 系统组件对应的 ServiceAccount 使用的。

比如，其中一个名叫 system:kube-scheduler 的 ClusterRole，定义的权限规则是 kube-scheduler（Kubernetes 的调度器组件）运行所需要的必要权限。你可以通过如下指令查看这些权限的列表：
```
\# kubectl describe clusterrole system:kube-scheduler

Name:     system:kube-scheduler
...
PolicyRule:
 Resources           Non-Resource URLs Resource Names   Verbs
---------           -----------------  --------------   -----
...
 services           []         []         [get list watch]
 replicasets.apps       []         []         [get list watch]
 statefulsets.apps       []         []         [get list watch]
 replicasets.extensions    []         []         [get list watch]
 poddisruptionbudgets.policy  []         []         [get list watch]
 pods/status          []         []         [patch update]
```
这个 system:kube-scheduler 的 ClusterRole，就会被绑定给 kube-system Namesapce 下名叫 kube-scheduler 的 ServiceAccount，它正是 Kubernetes 调度器的 Pod 声明使用的 ServiceAccount。

除此之外，Kubernetes 还提供了四个预先定义好的 ClusterRole 来供用户直接使用：

cluster-admin；

admin；

edit；

view。

通过它们的名字，你应该能大致猜出它们都定义了哪些权限。比如，这个名叫 view 的 ClusterRole，就规定了被作用者只有 Kubernetes API 的只读权限。

cluster-admin 角色，对应的是整个 Kubernetes 项目中的最高权限（verbs=*），如下所示：
```
\# kubectl describe clusterrole cluster-admin -n kube-system

Name:     cluster-admin
Labels:    kubernetes.io/bootstrapping=rbac-defaults
Annotations:  rbac.authorization.kubernetes.io/autoupdate=true
PolicyRule:
 Resources  Non-Resource URLs Resource Names  Verbs
---------  -----------------  --------------  -----
 *.*     []         []        [*]
       [*]         []        [*]
```
所以，请你务必要谨慎而小心地使用 cluster-admin。

## 总结
其实，你现在已经能够理解，所谓角色（Role），其实就是一组权限规则列表。而我们分配这些权限的方式，就是通过创建 RoleBinding 对象，将被作用者（subject）和权限列表进行绑定。

另外，与之对应的 ClusterRole 和 ClusterRoleBinding，则是 Kubernetes 集群级别的 Role 和 RoleBinding，它们的作用范围不受 Namespace 限制。

而尽管权限的被作用者可以有很多种（比如，User、Group 等），但在我们平常的使用中，最普遍的用法还是 ServiceAccount。所以，Role + RoleBinding + ServiceAccount 的权限分配方式是你要重点掌握的内容。编写和安装各种插件的时候，会经常用到这个组合。

思考题
请问，如何为所有 Namespace 下的默认 ServiceAccount（default ServiceAccount），绑定一个只读权限的 Role 呢？请你提供 ClusterRoleBinding（或者 RoleBinding）的 YAML 文件。﻿

## rbac权限测试实验

(1) 通过绑定到集群角色 view 赋予查看权限

\# kubectl get sa //当前可用的服务账户 

```
\# cat serviceaccount/view.yml

apiVersion: v1
kind: ServiceAccount
metadata:
 name: view
\---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
 name: view
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: ClusterRole
 name: view
subjects:
\- kind: ServiceAccount
 name: view
```


```
\# kubectl apply -f serviceaccount/view.yml --record 

\# kubectl get sa

\# kubectl describe sa view

\# kubectl describe rolebinding view
```


把 serviceAccount 装进 pod 

\# cat serviceaccount/kubectl-view.yml
```
apiVersion: v1
kind: Pod
metadata:
 name: kubectl
spec:
 serviceAccountName: view
 containers:
 - name: kubectl
  image: wing/kubectl
  command: ["sleep"]
  args: ["100000"]
```
```
\# kubectl apply -f serviceaccount/kubectl-view.yml --record

\# kubectl describe pod kubectl
```

在容器内部测试权限：
```
\# kubectl exec -it kubectl -- sh

/# kubectl get pods
 
/# kubectl run new-test --image=alpine --restart=Never sleep 10000 //无法创建，无权限

/# exit

\# kubectl delete -f serviceaccount/kubectl-view.yml
```

(2)自定义角色绑定到 ServiceAccount

\# cat serviceaccount/pods.yml
```
apiVersion: v1
kind: Namespace
metadata:
 name: test1
---
apiVersion: v1
kind: ServiceAccount
metadata:
 name: pods-all
 namespace: test1

---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 name: pods-all
 namespace: test1
rules:
- apiGroups: [""]
 resources: ["pods", "pods/exec", "pods/log"]
 verbs: ["*"]
---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
 name: pods-all
 namespace: test1
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: Role
 name: pods-all
subjects:
- kind: ServiceAccount
 name: pods-all
```

```
\# kubectl apply -f serviceaccount/pods.yml --record

\# kubectl create ns test2
```
\# cat serviceaccount/kubectl-test1.yml
```
apiVersion: v1
kind: Pod
metadata:
 name: kubectl
 namespace: test1
spec:
 serviceAccountName: pods-all
 containers:
 - name: kubectl
  image: aishangwei/kubectl
  command: ["sleep"]
  args: ["100000"]
```

```
\# kubectl apply -f serviceaccount/kubectl-test1.yml --record

\# kubectl -n test1 exec -it kubectl -- sh

/# kubectl get pods // 可以列出当前名称空间的pod

/# kubectl run new-test --image=alpine --restart=Never sleep 10000 // 可以创建pod

/# kubectl get pods

/# kubectl run new-test --image=alpine sleep 10000 // 无法创建deployment,默认不加--restart就是创建deployment

/# kubectl -n test2 get pods // 无权限 

/# exit

\# kubectl delete -f serviceaccount/kubectl-test1.yml
```


(3)自定义多空间角色绑定到 ServiceAccount

在前面的定义中，仅在与附加到ServiceAccount的Pod相同的名称空间内获得权限。在某些情况下，这还不够。Jenkins是一个很好的用例。可能决定在一个名称空间中运行Jenkins master，但在另一个名称空间中运行构建。或者，可以创建一个管道来部署我们的应用程序的beta版本并在其中进行测试命名空间，稍后将其作为 生产版本部署到另一个版本中。当然，有办法满足这些需求。

其实就是定义同一个角色名称（比如下面的pods-all）两次到不同的namespace,再分开绑定

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsNi2rUk.jpg) 

\# cat serviceaccount/pods-all.yml
```
apiVersion: v1
kind: ServiceAccount
metadata:
 name: pods-all
 namespace: test1

---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 name: pods-all
 namespace: test1
rules:
- apiGroups: [""]
 resources: ["pods", "pods/exec", "pods/log"]
 verbs: ["*"]
 
 ---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 name: pods-all
 namespace: test2
rules:
- apiGroups: [""]
 resources: ["pods", "pods/exec", "pods/log"]
 verbs: ["*"]

---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
 name: pods-all
 namespace: test1
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: Role
 name: pods-all
subjects:
- kind: ServiceAccount
 name: pods-all

---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
 name: pods-all
 namespace: test2
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: Role
 name: pods-all
subjects:
- kind: ServiceAccount
 name: pods-all
 namespace: test1
```

```
\# kubectl apply -f serviceaccount/pods-all.yml --record
```


\# cat kubectl-test2.yml 
```
apiVersion: v1
kind: Pod
metadata:
 name: kubectl
 namespace: test1
spec:
 serviceAccountName: pods-all
 containers:
 - name: kubectl
image: vfarcic/kubectl
  command: ["sleep"]
  args: ["100000"]
```
```
\# kubectl apply -f serviceaccount/kubectl-test2.yml --record 

\# kubectl -n test1 exec -it kubectl -- sh

/# kubectl -n test2 get pods

/# kubectl -n test2 run new-test --image=alpine --restart=Never sleep 10000 

/# kubectl -n test2 get pods

\# kubectl delete ns test1 test2
```


# 容器监控检查及恢复机制

在 k8s 中，可以为 Pod 里的容器定义一个`健康检查"探针"`（Probe）。kubelet 就会根据这个 Probe 的返回值决定这个容器的状态，而不是直接以容器是否运行（来自 Docker 返回的信息）作为依据。这种机制，是生产环境中保证应用健康存活的重要手段。

> 注：
>
> k8s 中并没有 Docker 的 Stop 语义。所以如果容器被探针检测到有问题，查看状态虽然看到的是 Restart，但实际却是重新创建了容器。
>

命令模式探针：

Kubernetes 文档中的例子:

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: test-liveness-exec
spec:
  containers:
    - name: liveness
      image: daocloud.io/library/nginx
      args:
        - /bin/sh
        - c
        - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
      livenessProbe:
        exec:
          command:
            - cat
            - /tmp/healthy
        initialDelaySeconds: 5
        periodSeconds: 5
```

它在启动之后做的第一件事是在 /tmp 目录下创建了一个 healthy 文件，以此作为自己已经正常运行的标志。而 30 s 过后，它会把这个文件删除掉。

与此同时，定义了一个这样的 livenessProbe（健康检查）。它的类型是 exec，它会在容器启动后，在容器里面执行一句我们指定的命令，比如："cat /tmp/healthy"。这时，如果这个文件存在，这条命令的返回值就是 0，Pod 就会认为这个容器不仅已经启动，而且是健康的。这个健康检查，在容器启动 5 s 后开始执行（initialDelaySeconds: 5），每 5 s 执行一次（periodSeconds: 5）。 

创建Pod：

```
\# kubectl create -f test-liveness-exec.yaml
```
查看 Pod 的状态：

```
# kubectl get pod
NAME         READY   STATUS   RESTARTS  AGE
test-liveness-exec   1/1     Running   0       10s
```
由于已经通过了健康检查，这个 Pod 就进入了 Running 状态。

30 s 之后，再查看一下 Pod 的 Events：
```
\# kubectl describe pod test-liveness-exec
```
发现，这个 Pod 在 Events 报告了一个异常：
```
FirstSeen LastSeen   Count  From       SubobjectPath      Type     Reason    Message
--------- --------   -----  ----       -------------      --------   ------    -------
2s     2s    1  {kubelet worker0}  spec.containers{liveness}  Warning   Unhealthy  Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory
```

显然，这个健康检查探查到 /tmp/healthy 已经不存在了，所以它报告容器是不健康的。那么接下来会发生什么呢？

再次查看一下这个 Pod 的状态：
```
\# kubectl get pod test-liveness-exec
NAME      READY   STATUS   RESTARTS  AGE
liveness-exec  	 1/1    	 Running  	1       1m
```
这时发现，Pod 并没有进入 Failed 状态，而是保持了 Running 状态。这是为什么呢？

RESTARTS 字段从 0 到 1 的变化，就明白原因了：这个异常的容器已经被 Kubernetes 重启了。在这个过程中，Pod 保持 Running 状态不变。

>注意：Kubernetes 中并没有 Docker 的 Stop 语义。所以虽然是 Restart（重启），但实际却是重新创建了容器。

这个功能就是 Kubernetes 里的Pod 恢复机制，也叫` restartPolicy`。它是 Pod 的 Spec 部分的一个标准字段（pod.spec.restartPolicy），默认值是 Always，即：任何时候这个容器发生了异常，它一定会被重新创建。

>小提示：
>Pod 的恢复过程，永远都是发生在当前节点上，而不会跑到别的节点上去。事实上，一旦一个 Pod 与一个节点（Node）绑定，除非这个绑定发生了变化（pod.spec.node 字段被修改），否则它永远都不会离开这个节点。这也就意味着，如果这个宿主机宕机了，这个 Pod 也不会主动迁移到其他节点上去。

而如果你想让 Pod 出现在其他的可用节点上，就必须使用 Deployment 这样的"控制器"来管理 Pod，哪怕你只需要一个 Pod 副本。这就是一个单 Pod 的 Deployment 与一个 Pod 最主要的区别。

### http get方式探针
\# vim liveness-httpget.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: liveness-httpget-pod
  namespace: default
spec:
  containers:
    - name: liveness-exec-container
      image: daocloud.io/library/nginx
      imagePullPolicy: IfNotPresent
      ports:
        - name: http
          containerPort: 80
      livenessProbe:
        httpGet:
          port: http
          path: /index.html
        initialDelaySeconds: 1
        periodSeconds: 3
```

创建该pod
```
[root@centos708 prome]# kubectl apply -f liveness-httpd.yml 
pod/liveness-httpget-pod created
```

查看当前pod的状态
```
\# kubectl describe pod liveness-httpget-pod
...
  Liveness:    http-get http://:http/index.html delay=1s timeout=1s period=3s #success=1 #failure=3
...
```
测试将容器内的index.html删除掉

登陆容器
```
[root@centos708 prome]# kubectl exec liveness-httpget-pod -c liveness-exec-container -it  -- /bin/sh
# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
# mv /usr/share/nginx/html/index.html index.html
# command terminated with exit code 137
```
可以看到，当把index.html移走后，这个容器立马就退出了。

此时，查看pod的信息
```
\# kubectl describe pod liveness-httpget-pod
...
 Normal  Killing   1m         kubelet, node02   Killing container with id docker://liveness-exec-container:Container failed liveness probe.. Container will be killed and recreated.
...
```
看输出，容器由于健康检查未通过，pod会被杀掉，并重新创建
```
[root@centos708 prome]# kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
liveness-httpget-pod   1/1     Running   1          4m41s
```
restarts 为 1

重新登陆容器查看

重新登陆容器，发现index.html又出现了，证明容器是被重拉了。
```
\# kubectl exec liveness-httpget-pod -c liveness-exec-container -it  -- /bin/sh
/ # cat /usr/share/nginx/html/index.html 
```

## POD 的恢复策略

Pod 的恢复策略：
可以通过设置 restartPolicy，改变 Pod 的恢复策略。一共有3种：
  1. Always：    在任何情况下，只要容器不在运行状态，就自动重启容器；
  2. OnFailure:    只在容器 异常时才自动重启容器；
  3. Never:     从来不重启容器。
实际使用时，需要根据应用运行的特性，合理设置这三种恢复策略。

比如，一个 Pod，它只计算 1+1=2，计算完成输出结果后退出，变成 Succeeded 状态。这时，你如果再用 restartPolicy=Always 强制重启这个 Pod 的容器，就没有任何意义了。

而如果要关心这个容器退出后的上下文环境，比如容器退出后的日志、文件和目录，就需要将 restartPolicy 设置为 Never。因为一旦容器被自动重新创建，这些内容就有可能丢失掉了（被垃圾回收了）。

官方文档把 restartPolicy 和 Pod 里容器的状态，以及 Pod 状态的对应关系，总结了非常复杂的一大堆情况。实际上，你根本不需要死记硬背这些对应关系，只要记住如下两个基本的设计原理即可：

1. 只要 Pod 的 restartPolicy 指定的策略允许重启异常的容器（比如：Always），那么这个 Pod 就会保持 Running 状态，并进行容器重启。否则，Pod 就会进入 Failed 状态 。

 2. 对于包含多个容器的 Pod，只有它里面所有的容器都进入异常状态后，Pod 才会进入 Failed 状态。在此之前，Pod 都是 Running 状态。此时，Pod 的 READY 字段会显示正常容器的个数，比如：
```
  \# kubectl get pod test-liveness-exec

  NAME      READY   STATUS   RESTARTS  AGE
  liveness-exec  0/1    Running  1      1m
```

# PODPRESET详解

Pod 的字段那么多，不可能全记住，Kubernetes 能不能自动给 Pod 填充某些字段呢？
比如，开发人员只需要提交一个基本的、非常简单的 Pod YAML，Kubernetes 就可以自动给对应的 Pod 对象加上其他必要的信息，比如 labels，annotations，volumes 等等。而这些信息，可以是运维人员事先定义好的。
这样，开发人员编写 Pod YAML 的门槛，就被大大降低了。
一个叫作 PodPreset（Pod 预设置）的功能 已经出现在了 v1.11 版本的 Kubernetes 中。

### 理解 Pod Preset
Pod Preset 是一种 API 资源，在 pod 创建时，用户可以用它将额外的运行时需求信息注入 pod。 使用标签选择器（label selector）来指定 Pod Preset 所适用的 pod。是专门用来对 Pod 进行批量化、自动化修改的一种工具对象

使用 Pod Preset 使得 pod 模板编写者不必显式地为每个 pod 设置信息。 这样，使用特定服务的 pod 模板编写者不需要了解该服务的所有细节。

### PodPreset 如何工作
Kubernetes 提供了准入控制器 (PodPreset)，该控制器被启用时，会将 Pod Preset 应用于接收到的 pod 创建请求中。 当出现 pod 创建请求时，系统会执行以下操作：
1. 检索所有可用 PodPresets 。
2. 检查 PodPreset 的标签选择器与要创建的 pod 的标签是否匹配。
3. 尝试合并 PodPreset 中定义的各种资源，并注入要创建的 pod。
4. 发生错误时抛出事件，该事件记录了 pod 信息合并错误，同时在 不注入 PodPreset 信息的情况下创建 pod。
5. 为改动的 pod spec 添加注解，来表明它被 PodPreset 所修改。 注解形如： podpreset.admission.kubernetes.io/podpreset-<pod-preset name>": "<resource version>"。
6. 一个 Pod 可能不与任何 Pod Preset 匹配，也可能匹配多个 Pod Preset。 同时，一个 PodPreset 可能不应用于任何 Pod，也可能应用于多个 Pod。 当 PodPreset 应用于一个或多个 Pod 时，Kubernetes 修改 pod spec。 对于 Env、 EnvFrom 和 VolumeMounts 的改动， Kubernetes 修改 pod 中所有容器的规格，对于卷的改动，Kubernetes 修改 Pod spec。

### 启用 Pod Preset
为了在集群中使用 Pod Preset，必须确保以下几点：
1. 已启用 api 类型 settings.k8s.io/v1alpha1/podpreset。 这可以通过在 API 服务器的 --runtime-config 配置项中包含 settings.k8s.io/v1alpha1=true 来实现。

api-server配置文件添加如下配置：重启api-server服务
```
[root@k8s-master1 ~]# vim /opt/kubernetes/cfg/kube-apiserver 

--runtime-config=settings.k8s.io/v1alpha1=true
```
```
[root@k8s-master1 ~]# kubectl  api-versions
```

2. 已启用准入控制器 PodPreset。 
启用的一种方式是在 API 服务器的 --enable-admission-plugins 配置项中包含 PodPreset 。
```
--enable-admission-plugins=PodPreset,NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction
```
 3. 已经通过在相应的名字空间中创建 PodPreset 对象，定义了 Pod preset。

例：现开发人员编写了如下一个 pod.yaml 文件：

\# vim pod.yaml
```
---
apiVersion: v1
kind: Pod
metadata:
  name: website
  labels:
    app: website
    role: frontend
spec:
  containers:
    - name: website
      image: daocloud.io/library/nginx
      ports:
        - containerPort: 80
```
如果运维人员看到了这个 Pod，他一定会连连摇头：这种 Pod 在生产环境里根本不能用啊！

运维人员就可以定义一个 PodPreset 对象。在这个对象中，凡是他想在开发人员编写的 Pod 里追加的字段，都可以预先定义好。

\# vim preset.yaml
```
apiVersion: settings.k8s.io/v1alpha1
kind: PodPreset
metadata:
 name: allow-database
spec:
 selector:
  matchLabels:
   role: frontend
 env:
  - name: DB_PORT
   value: "6379"
 volumeMounts:
  - mountPath: /cache
   name: cache-volume
 volumes:
  - name: cache-volume
   emptyDir: {}
selector：
```
  这里的selector表示后面这些追加的定义，只会作用于 selector 所定义的、带有"role: frontend"标签的 Pod 对象，这就可以防止"误伤"。

然后定义了一组 Pod 的 Spec 里的标准字段，以及对应的值。
  比如：
​    env 里定义了 DB_PORT 这个环境变量
​    volumeMounts 定义了容器 Volume 的挂载目录
​    volumes 定义了一个 emptyDir 的 Volume。

接下来，假定运维人员先创建了这个 PodPreset，然后开发人员才创建 Pod：
```
\# kubectl create -f preset.yaml
\# kubectl create -f pod.yaml
```
Pod 运行之后，查看这个 Pod 的 API 对象：
```
\# kubectl get pod website -o yaml
apiVersion: v1
kind: Pod
metadata:
 name: website
 labels:
  app: website
  role: frontend
 annotations:
  podpreset.admission.kubernetes.io/podpreset-allow-database: "resource version"
spec:
 containers:
  - name: website
   image: nginx
   volumeMounts:
​    \- mountPath: /cache
​     name: cache-volume
   ports:
​    \- containerPort: 80
   env:
​    \- name: DB_PORT
​     value: "6379"
 volumes:
  \- name: cache-volume
   emptyDir: {}
```
清楚地看到，这个 Pod 里多了新添加的 labels、env、volumes 和 volumeMount 的定义，它们的配置跟 PodPreset 的内容一样。此外，这个 Pod 还被自动加上了一个 annotation 表示这个 Pod 对象被 PodPreset 改动过。
>注意：
> PodPreset 里定义的内容，只会在 Pod API 对象被创建之前追加在这个对象本身上，而不会影响任何 Pod 的控制器的定义。

比如，现在提交的是一个 nginx-deployment，那么这个 Deployment 对象本身是永远不会被 PodPreset 改变的，被修改的只是这个 Deployment 创建出来的所有 Pod。

这里有一个问题：如果你定义了同时作用于一个 Pod 对象的多个 PodPreset，会发生什么呢？

Kubernetes 项目会帮你合并（Merge）这两个 PodPreset 要做的修改。而如果它们要做的修改有冲突的话，这些冲突字段就不会被修改。

## 禁用PODPRESET
在一些情况下，用户不希望 pod 被 pod preset 所改动，这时，用户可以在 pod spec 中添加形如 podpreset.admission.kubernetes.io/exclude: "true" 的注解。

# DEPLOYMENT资源详解
### deployment资源创建流程

1. 用户通过 kubectl 创建 Deployment。
2. Deployment 创建 ReplicaSet。
3. ReplicaSet 创建 Pod。

对象的命名方式是：子对象的名字  =  父对象名字 + 随机字符串或数字

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps0tZ7hI.jpg) 

```
      Replication Controller

                      |
---------------------------------------
    |                               |                         |

Deployment   replicaSet  Replication Controller
```

Deployment是一个定义及管理多副本应用（即多个副本 Pod）的新一代对象，与Replication Controller相比，它提供了更加完善的功能，使用起来更加简单方便。

如果Pod出现故障，对应的服务也会挂掉，所以Kubernetes提供了一个Deployment的概念 ，目的是让Kubernetes去管理一组Pod的副本，也就是副本集 ，这样就能够保证一定数量的副本一直可用，不会因为某一个Pod挂掉导致整个服务挂掉。
Deployment 还负责在 Pod 定义发生变化时，对每个副本进行滚动更新（Rolling Update）。

这样使用一种 API 对象（Deployment）管理另一种 API 对象（Pod）的方法，在 k8s 中，叫作"控制器"模式（controller pattern）。Deployment 扮演的正是 Pod 的控制器的角色。

例1：
```
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: kubesite100
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: front-end
          image: nginx
          ports:
            - containerPort: 80
        - name: flaskapp-demo
          image: flaskapp
          ports:
            - containerPort: 5000
```


例2：
```
---
apiVersion: apps/v1 # 注意使用这个api必须使用标签选择器
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
```

例3：在上面yaml的基础上添加了volume
```
---
apiVersion: apps/v1 # 注意使用这个api必须使用标签选择器
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
          volumeMounts:
            - mountPath: /usr/share/nginx/html
              name: nginx-vol
      volumes:
        - name: nginx-vol
          emptyDir: {}
```
#### apiVersion
注意这里apiVersion对应的值是extensions/v1beta1或者apps/v1
这个版本号需要根据安装的Kubernetes版本和资源类型进行变化，记住不是写死的。此值必须在kubectl apiversion中 

```
[root@centos708 ~]# kubectl api-versions
admissionregistration.k8s.io/v1
admissionregistration.k8s.io/v1beta1
apiextensions.k8s.io/v1
apiextensions.k8s.io/v1beta1
apiregistration.k8s.io/v1
apiregistration.k8s.io/v1beta1
apps/v1
authentication.k8s.io/v1
authentication.k8s.io/v1beta1
authorization.k8s.io/v1
authorization.k8s.io/v1beta1
autoscaling/v1
autoscaling/v2beta1
autoscaling/v2beta2
batch/v1
batch/v1beta1
certificates.k8s.io/v1beta1
coordination.k8s.io/v1
coordination.k8s.io/v1beta1
events.k8s.io/v1beta1
extensions/v1beta1
networking.k8s.io/v1
networking.k8s.io/v1beta1
node.k8s.io/v1beta1
policy/v1beta1
rbac.authorization.k8s.io/v1
rbac.authorization.k8s.io/v1beta1
scheduling.k8s.io/v1
scheduling.k8s.io/v1beta1
storage.k8s.io/v1
storage.k8s.io/v1beta1
v1
```
#### kind
  资源类型:这里指定为Deployment。

#### metadata
指定一些meta信息，包括名字或标签之类的。
每一个 API 对象都有一个叫作 Metadata 的字段，这个字段是 API 对象的"标识"，即元数据，也是我们从 Kubernetes 里找到这个对象的主要依据。

#### labels
 Labels是最主要的字段,是一组 key-value 格式的标签,k8s中的所有资源都支持携带label,默认情况下，pod的label会复制rc的label
k8s使用用户自定义的key-value键值对来区分和标识资源集合（就像rc、pod等资源），这种键值对称为label。

像 Deployment 这样的控制器对象，就可以通过这个 Labels 字段从 Kubernetes 中过滤出它所关心的被控制对象。

### 关于Annotations
在 Metadata 中，还有一个与 Labels 格式、层级完全相同的字段叫 Annotations，它专门用来携带 key-value 格式的内部信息。所谓内部信息，指的是对这些信息感兴趣的，是 Kubernetes 组件本身，而不是用户。所以大多数 Annotations，都是在 Kubernetes 运行过程中，被自动加在这个 API 对象上。

  可以通过-L参数来查看：
```
  \# kubectl get deploy my-nginx -L app

  CONTROLLER  CONTAINER(S)  IMAGE(S)  SELECTOR   REPLICAS  APP
  my-nginx11   nginx      nginx    app=nginx111  2      nginx
```
#### selector
过滤规则的定义，是在 Deployment 的"spec.selector.matchLabels"字段。一般称之为：Label Selector。

pod的label会被用来创建一个selector，用来匹配过滤携带这些label的pods。

可以通过kubectl get请求这样一个字段来查看template的格式化输出：
```
  \# kubectl get rc my-nginx -o template --template="{{.spec.selector}}"

  map[app:nginx11]
```

  使用labels定位pods
```
  [root@k8s-master ~]# kubectl get pods -l app=nginx11 -o wide
  NAME        READY   STATUS   RESTARTS  AGE    IP      NODE
  my-nginx11-1r2p4  1/1    Running  0      11m    10.0.6.3   k8s-node-1
  my-nginx11-pc4ds  1/1    Running  0      11m    10.0.33.6  k8s-node-2
```

  检查你的Pod的IPs：
```
  \# kubectl get pods -l app=nginx -o json | grep podIP
"podIP": "10.245.0.15",
"podIP": "10.245.0.14",
```
#### spec 
一个 k8s 的 API 对象的定义，大多可以分为 Metadata 和 Spec 两个部分。前者存放的是这个对象的元数据，对所有 API 对象来说，这一部分的字段和格式基本上是一样的；而后者存放的，则是属于这个对象独有的定义，用来描述它所要表达的功能。

这里定义需要两个副本，此处可以设置很多属性，主要是受此Deployment影响的Pod的选择器
 spec 选项的template其实就是对Pod对象的定义
可以在Kubernetes v1beta1 API 参考中找到完整的Deployment可指定的参数列表

#### replicas
  定义的 Pod 副本个数 (spec.replicas) 是：2

#### template
定义了一个 Pod 模版（spec.template），这个模版描述了想要创建的 Pod 的细节。例子里，这个 Pod 里只有一个容器，这个容器的镜像（spec.containers.image）是 nginx:1.7.9，这个容器监听端口（containerPort）是 80。

#### volumes
  是属于 Pod 对象的一部分。需要修改 template.spec 字段
  例3中，在 Deployment 的 Pod 模板部分添加了一个 volumes 字段，定义了这个 Pod 声明的所有 Volume。它的名字叫作 nginx-vol，类型是 emptyDir。

  ### 关于emptyDir 类型
等同于 Docker 的隐式 Volume 参数，即：不显式声明宿主机目录的 Volume。所以，Kubernetes 也会在宿主机上创建一个临时目录，这个目录将来就会被绑定挂载到容器所声明的 Volume 目录上。

k8s 的 emptyDir 类型，只是把 k8s 创建的临时目录作为 Volume 的宿主机目录，交给了 Docker。这么做的原因，是 k8s 不想依赖 Docker 自己创建的那个 _data 目录。

#### volumeMounts
Pod 中的容器，使用的是 volumeMounts 字段来声明自己要挂载哪个 Volume，并通过 mountPath 字段来定义容器内的 Volume 目录，比如：/usr/share/nginx/html。

#### hostPath
k8s 也提供了显式的 Volume 定义，它叫做 hostPath。比如下面的这个 YAML 文件：

```
...  
​    volumes:
​     - name: nginx-vol
​      hostPath: 
​       path: /var/data
```
  这样，容器 Volume 挂载的宿主机目录，就变成了 /var/data

  使用 kubectl exec 指令，进入到这个 Pod 当中（即容器的 Namespace 中）查看这个 Volume 目录：
```
  \# kubectl exec -it nginx-deployment-5c678cfb6d-lg9lw -- /bin/bash

  \# ls /usr/share/nginx/html
```

\# cat dep_test_vol.yaml 
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
 name: dep-test
spec:
 replicas: 2
 template:
  metadata:
   labels:
    app: nginx
  spec:
   containers:
   - name: nginx
    image: daocloud.io/library/nginx:1.7.9
    ports:
     - containerPort: 80
    volumeMounts:
     - name: nginx-vol-1
     mountPath: /test   
   volumes:
    - name: nginx-vol-1
     hostPath: 
      path: /var/data
```

创建Deployment：

将上述的YAML文件保存为deployment.yaml，然后创建Deployment：
```
\# kubectl apply -f deployment.yaml
deployment "kube100-site" created
```

检查Deployment的列表：
通过 kubectl get 命令检查这个 YAML 运行起来的状态是不是与我们预期的一致：
```
\# kubectl get deployments

NAME      DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE

kube100-site  2     2     2       2      2m
```

```
\# kubectl get pods -l app=nginx

NAME                 READY   STATUS   RESTARTS  AGE
nginx-deployment-67594d6bf6-9gdvr  1/1    Running  0      10m
nginx-deployment-67594d6bf6-v6j7w  1/1    Running  0      10m
```
kubectl get 指令的作用，就是从 Kubernetes 里面获取（GET）指定的 API 对象。可以看到，在这里我还加上了一个 -l 参数，即获取所有匹配 app: nginx 标签的 Pod。需要注意的是，在命令行中，所有 key-value 格式的参数，都使用"="而非":"表示。

删除Deployment:
```
[root@k8s-master ~]# kubectl delete deployments my-nginx

deployment "my-nginx" deleted
或者
[root@k8s-master ~]# kubectl delete -f  deployment.yaml
```

# SERVICE创建

1. 创建deployment:

\# cat nginx.yaml 
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dep01
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      name: testnginx0
      labels:
        app: web
    spec:
      containers:
        - name: testnginx0
          image: daocloud.io/library/nginx
          ports:
            - containerPort: 80
```

2. 创建service并且以nodePort的方式暴露端口给外网：

\# vim nginx_svc.yaml
```
---
apiVersion: v1
kind: Service
metadata:
  name: mysvc
spec:
  type: NodePort
  ports:
    - port: 8080
      nodePort: 30001
      targetPort: 80
  selector:
    app: web
```

3. 测试
```
[root@centos708 prome]# kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP          4d5h
mysvc        NodePort    10.110.143.136   <none>        8080:30001/TCP   69s
nginx        NodePort    10.96.221.137    <none>        80:31166/TCP     3d6h
```

## 端口详解
>提示：
>安装iptables(但是需要关闭iptables),创建service之后k8s会自动添加规则到Iptables里面，而且会生效(虽然iptables处于关闭状态)

服务中的3个端口设置
这几个port的概念很容易混淆，比如创建如下service：
```
apiVersion: v1
kind: Service
metadata:
 labels:
  name: app1
 name: app1
 namespace: default
spec:
 type: NodePort
 ports:
 - port: 8080
  targetPort: 8080
  nodePort: 30062
 selector:
  name: app1
```

### port
这里的port表示：service暴露在cluster ip上的端口，<cluster ip>:port 是提供给集群内部客户访问service的入口。

### nodePort
首先，nodePort是kubernetes提供给集群外部客户访问service入口的一种方式（另一种方式是LoadBalancer），所以，<nodeIP>:nodePort 是提供给集群外部客户访问service的入口。

### targetPort
targetPort很好理解，targetPort是pod上的端口，从port和nodePort上到来的数据最终经过kube-proxy流入到后端pod的targetPort上进入容器。

### port、nodePort总结
总的来说，port和nodePort都是service的端口，前者暴露给集群内客户访问服务，后者暴露给集群外客户访问服务。从这两个端口到来的数据都需要经过反向代理kube-proxy流入后端pod的targetPod，从而到达pod上的容器内。

### kube-proxy反向代理
#### kube-proxy与iptables 
当service有了port和nodePort之后，就可以对内/外提供服务。那么其具体是通过什么原理来实现的呢？原因就在kube-proxy在本地node上创建的iptables规则。

Kube-Proxy 通过配置 DNAT  规则（从容器出来的访问，从本地主机出来的访问两方面），将到这个服务地址的访问映射到本地的kube-proxy端口（随机端口）。然后  Kube-Proxy 会监听在本地的对应端口，将到这个端口的访问给代理到远端真实的 pod 地址上去。

不管是通过集群内部服务入口<cluster ip>:port还是通过集群外部服务入口<node  ip>:nodePort的请求都将重定向到本地kube-proxy端口（随机端口）的映射，然后将到这个kube-proxy端口的访问给代理到远端真实的  pod 地址上去。
![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsf7WdG5.jpg) 

# RC资源(了解)
### 1.使用yaml创建并启动replicas集合
k8s通过Replication Controller来创建和管理各个不同的重复容器集合（实际上是重复的pods）。

Replication Controller会确保pod的数量在运行的时候会一直保持在一个特殊的数字，即replicas的设置。

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: my-nginx
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
```
和定义一个pod的YAML文件相比，不同的只是kind的值为ReplicationController，replicas的值需要指定，pod的相关定义在template中，pod的名字不需要显式地指定，因为它们会在rc中创建并赋予名字

创建rc:
rc可以通过create命令像创建pod一样来创建：
```
# kubectl create -f ./nginx-rc.yaml

replicationcontrollers/my-nginx
```
和直接创建pod不一样，rc将会替换因为任何原因而被删除或者停止运行的Pod，比如说pod依赖的节点挂了。所以我们推荐使用rc来创建和管理复杂应用，即使你的应用只要使用到一个pod，在配置文件中忽略replicas字段的设置即可

### 2、查看Replication Controller的状态
可以通过get命令来查看你创建的rc：
```
# kubectl get rc

CONTROLLER  CONTAINER(S)  IMAGE(S)  SELECTOR   REPLICAS
my-nginx   nginx      nginx    app=nginx  2
```
这个状态表示，你创建的rc将会确保你一直有两个nginx的副本。
也可以和直接创建Pod一样查看创建的Pod状态信息：

```
# kubectl get pods

NAME       READY   STATUS   RESTARTS  AGE
my-nginx-065jq  1/1    Running  0      51s
my-nginx-buaiq  1/1    Running  0      51s
```

### 3、删除Replication Controller
当你想停止你的应用，删除你的rc，可以使用：
```
# kubectl delete rc my-nginx

replicationcontrollers/my-nginx
```
默认的，这将会删除所有被这个rc管理的pod，如果pod的数量很大，将会花一些时间来完成整个删除动作，如果你想使这些pod停止运行，请指定--cascade=false。

如果你在删除rc之前尝试删除pod，rc将会立即启动新的pod来替换被删除的pod，就像它承诺要做的一样。

### k8s中连接容器的模型
现在，已经有了组合的、多份副本的应用，你可以将它连接到一个网络上。在讨论k8s联网的方式之前，有必要和Docker中连接网络的普通方式进行一下比较。

默认情况下，Docker使用主机私有网络，所以容器之间可以互相交互，只要它们在同一台机器上。

为了让Docker容器可以进行跨节点的交流，必须在主机的IP地址上为容器分配端口号，之后通过主机IP和端口将信息转发到容器中。

这样一来，很明显地，容器之间必须谨慎地使用和协调端口号的分配，或者动态分配端口号。

在众多开发者之间协调端口号的分配是十分困难的，会将集群级别之外的复杂问题暴露给用户来处理。

在k8s中，假设Pod之间可以互相交流，无论它们是在哪个宿主机上。

我们赋予每个Pod自己的集群私有IP，如此一来你就不需要明确地在Pod之间创建连接，或者将容器的端口映射到主机的端口中。

这意味着，Pod中的容器可以在主机上使用任意彼此的端口，而且集群中的Pods可以在不使用NAT的方式下连接到其他Pod。

这时，你应该能够通过使用curl来连接任一IP（如果节点之间没有处于同一个子网段，无法使用私有IP进行连接的话，就只能在对应节点上使用对应的IP进行连接测试）。

注意，容器并不是真的在节点上使用80端口，也没有任何的NAT规则来路由流量到Pod中。

这意味着你可以在同样的节点上使用同样的containerPort来运行多个nginx Pod，并且可以在集群上的任何Pod或者节点通过这个IP来连接它们。

和Docker一样，端口仍然可以发布到宿主机的接口上，但是因为这个网络连接模型，这个需求就变得很少了。

### 4.创建Service
现在，在集群上我们有了一个运行着nginx并且有分配IP地址空间的的Pod。
理论上，你可以直接和这些Pod进行交互，但是当节点挂掉之后会发生什么？

这些Pod会跟着节点挂掉，然后RC会在另外一个健康的节点上重新创建新的Pod来代替，而这些Pod分配的IP地址都会发生变化，对于Service类型的服务来说这是一个难题。 

k8s上的Service是抽象的，其定义了一组运行在集群之上的Pod的逻辑集合，这些Pod是重复的，复制出来的，所以提供相同的功能。

当Service被创建，会被分配一个唯一的IP地址（也称为集群IP）。这个地址和Service的生命周期相关联，并且当Service是运行的时候，这个IP不会发生改变。

Pods进行配置来和这个Service进行交互，之后Service将会自动做负载均衡到Service中的Pod。

你可以通过以下的YAML文件来为你的两个nginx容器副本创建一个Service：

\# cat nginxsvc.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: nginxsvc
  labels:
    app: nginx
spec:
  ports:
    - port: 80
      protocol: TCP
  selector:
    app: nginx
```

这个YAML定义创建创建一个Service，带有Label为app=nginx的Pod都将会开放80端口，并将其关联到一个抽象的Service端口。

（targetPort字段是指容器内开放的端口Service通过这个端口连接Pod，port字段是指抽象Service的端口，nodePort为节点上暴露的端口号，不指定的话为随机。）

现在查看你创建的Service：

```
[root@k8s-master ~]# kubectl get svc

NAME     CLUSTER-IP    EXTERNAL-IP  PORT(S)  AGE

kubernetes  10.254.0.1    <none>     443/TCP  6d

nginxsvc   10.254.15.142  <none>     80/TCP   17m
```

和之前提到的一样，Service是以一组Pod为基础的。
这些Pod通过endpoints字段开放出来。
Service的selector将会不断地进行Pod的Label匹配，结果将会通知一个Endpoints Object，这里创建的也叫做nginxsvc。

当Pod挂掉之后，将会自动从Endpoints中移除，当有新的Pod被Service的selector匹配到之后将会自动加入这个Endpoints。

你可以查看这个Endpoint，注意，这些IP和第一步中创建Pods的时候是一样的：

```
[root@k8s-master ~]# kubectl describe svc nginxsvc
Name:			nginxsvc
Namespace:		default
Labels:			app=nginx11
Selector:		app=nginx111
Type:			ClusterIP
IP:			10.254.15.142
Port:			<unset>	80/TCP
Endpoints:		10.0.33.6:80,10.0.6.3:80
Session Affinity:	None
No events.
```

```
[root@k8s-master ~]# kubectl get ep
NAME     ENDPOINTS          AGE
kubernetes  192.168.245.250:6443    6d
nginxsvc   10.0.33.6:80,10.0.6.3:80  19m
```

你现在应该可以通过10.254.15.142:80这个IP从集群上的任何一个节点上使用容器来连接到nginx的Service。

### 删除service
\#kubectl delete service service名

## 完整NGINX实例

环境：三台虚拟机

 10.10.20.202 部署docker、etcd、flannel、kube-apiserver、kube-controller-manager、kube-scheduler
 10.10.20.203 部署docker、flannel、kubelet、kube-proxy
 10.10.20.206 部署docker、flannel、kubelet、kube-proxy

1、创建nginx-rc.yaml
```
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-controller
spec:
  replicas: 2
  selector:  # 在deployment里面需要添加matchLabels,再跟标签
    name: nginx
  template:
    metadata:
      labels:
        name: nginx
    spec:
      containers:
        - name: nginx
          image: daocloud.io/library/nginx
          ports:
            - containerPort: 80
```
2、创建nginx-service-nodeport.yaml
```
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-nodeport
spec:
  ports:
    - port: 8080
      targetPort: 80
      protocol: TCP
  type: NodePort #暴露端口给外网的一种方式，详情见下一小节-暴露ip给外网
  selector:
    name: nginx
```

3、创建pod
```
kubectl create -f nginx-rc.yaml 
```
4、创建service
```
kubectl create -f nginx-service-nodeport.yaml 
```
5、查看pod
```
[root@centos708 prome]# kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-controller-6gln5   1/1     Running   0          3m46s
nginx-controller-vhcz8   1/1     Running   0          3m46s
```
```
[root@centos710 ~]#  kubectl describe pod nginx-controller-c4jj5
```
6、查看service
```
[root@k8s-master ~]# kubectl get service
NAME           CLUSTER-IP   EXTERNAL-IP  PORT(S)   AGE
kubernetes        10.254.0.1   <none>     443/TCP   16h
nginx-service-nodeport  10.254.29.72  <nodes>    8000/TCP  49m
```

### 外部IP
Service对象在Cluster IP range池中分配到的IP只能在`内部访问`，如果服务作为一个应用程序内部的层次，还是很合适的。如果这个Service作为前端服务，准备为集群外的客户提供业务，我们就需要给这个服务提供公共IP了。

外部访问者是访问集群代理节点的访问者。为这些访问者提供服务，我们可以在定义Service时指定其`spec.publicIPs`，一般情况下publicIP  是代理节点的物理IP地址。和先前的Cluster IP  range上分配到的虚拟的IP一样，kube-proxy同样会为这些publicIP提供Iptables  重定向规则，把流量转发到后端的Pod上。有了publicIP，我们就可以使用load  balancer等常用的互联网技术来组织外部对服务的访问了。

spec.publicIPs在新的版本中标记为过时了，代替它的是`spec.type=NodePort`，这个类型的service，系统会给它在集群的各个代理节点上分配一个节点级别的端口，能访问到代理节点的客户端都能访问这个端口，从而访问到服务。

```
[root@centos708 prome]# kubectl describe service nginx-service-nodeport
Name:                     nginx-service-nodeport
Namespace:                default
Labels:                   <none>
Annotations:              kubectl.kubernetes.io/last-applied-configuration:
                            {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"nginx-service-nodeport","namespace":"default"},"spec":{"ports":[{...
Selector:                 name=nginx
Type:                     NodePort
IP:                       10.105.245.57
Port:                     <unset>  8080/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  32167/TCP
Endpoints:                10.244.1.18:80,10.244.2.22:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

7、测试service是否好用
 因为service使用的是NodePort方式（另一种方式是LoadBalancer，需要底层云平台支持给创建负载均衡器，比如gce），所以在任何一个节点访问31152这个端口都可以访问nginx
```
# curl 192.168.122.107:32167
```

## K8S暴露IP给外网

### kube-proxy转发的两种模式
一个简单的网络代理和负载均衡器，负责service的实现，每个Service都会在所有的Kube-proxy节点上体现。具体来说，就是实现了内部从pod到service和外部的从node port向service的访问。

kube-proxy在转发时主要有两种模式Userspace和Iptables。

 userspace（如下图）是在用户空间，通过kuber-proxy实现LB的代理服务。在K8S1.2版本之前，是kube-proxy默认方式，所有的转发都是通过kube-proxy实现的。这个是kube-proxy的最初的版本，较为稳定，但是效率也自然不太高。  

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsGTmJ4s.jpg)

另外一种方式是iptables方式（如下图）。是纯采用iptables来实现LB。在K8S1.2版本之后，kube-proxy默认方式。所有转发都是通过Iptables内核模块实现，而kube-proxy只负责生成相应的Iptables规则。 

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsp8XgtQ.jpg)

使用Userspace模式（k8s版本为1.2之前默认模式），`外部网络可以直接访问cluster IP`。 

使用Iptables模式（k8s版本为1.2之后默认模式），`外部网络不能直接访问cluster IP`。

### 转发K8S后端服务的四种方式

#### ClusterIP 
此类型会提供一个集群内部的虚拟IP（与Pod不在同一网段)，以供集群内部的pod之间通信使用。ClusterIP也是Kubernetes service的默认类型。 
![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpshUIQRd.jpg)  

 为了实现图上的功能主要需要以下几个组件的协同工作： 
 `apiserver`：在创建service时，apiserver接收到请求以后将数据存储到etcd中。 
 `kube-proxy`：k8s的每个节点中都有该进程，负责实现service功能，这个进程负责感知service，pod的变化，并将变化的信息写入本地的iptables中。 
` iptables`：使用NAT等技术将virtualIP的流量转至endpoint中。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps8WjsgB.jpg) 

具体实现方法：
1. 使用userspace模式，修改master的/etc/kubernetes/proxy
把KUBE_PROXY_ARGS=""改为KUBE_PROXY_ARGS="--proxy-mode=userspace"

2. 重启kube-proxy服务

3. 在核心路由设备或者源主机上添加一条路由，访问cluster IP段的路由指向到master上。

我们做实验的时候是在客戶端上添加如下路由条目：
```
[root@vm20 yum.repos.d]# route add -net 10.254.244.0/24 gw 192.168.245.250
```
>注：10.254.244.0/24是创建service之后的cluster ip所在网段

#### NodePort
外网client--->nodeIP+nodePort--->podIP+PodPort

NodePort模式除了使用cluster ip外，也将service的port映射到每个node的一个指定内部port上，映射的每个node的内部port都一样。 

 为每个节点暴露一个端口，通过nodeip + nodeport可以访问这个服务，同时服务依然会有cluster类型的ip+port。内部通过clusterip方式访问，外部通过nodeport方式访问。 
![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsU1b7EY.jpg) 

#### loadbalance
LoadBalancer在NodePort基础上，K8S可以请求底层云平台创建一个负载均衡器，将每个Node作为后端，进行服务分发。该模式需要底层云平台（例如GCE）支持。

#### Ingress
Ingress是一种`HTTP方式的路由转发机制`，为K8S服务配置HTTP负载均衡器，通常会将服务暴露给K8S群集外的客户端。

Ingress是一个允许入站连接到达集群服务的规则集合。Ingress能把K8S service配置成外网可访问集群service的URL、负载均衡、SSL、基于名称的虚拟主机等。

单纯创建一个Ingress没有任何意义，需要部署一个Ingress  Controller（Ingress控制器，下文简称IC）来实现Ingress。在GCE/GKE环境下，会自动在master节点上部署一个IC。在非GCE/GKE的环境中，必须部署和运行一个IC。

 IC是通过`轮询`实时监听K8S apiserver监视Ingress资源的应用程序，一旦资源发生了变化（包括增加、删除和修改），将ingress资源存储到本地缓存，并通知HTTP代理服务器（例如nginx）进行实时更新转发规则。

这与其他类型的控制器不同，其他类型的控制器通常作为kube-controller-manager二进制文件的一部分运行，在集群启动时自动启动。而IC通常使用负载平衡器，它还可以配置边界路由和其他前端，这有助于以HA方式处理流量。HTTP代理服务器有GCE  Load-Balancer、HaProxy、Nginx等开源方案，不同的HTTP代理服务器需要不同的Ingress控制器实现。

如果与HAProxy进行比较：
     ingress是配置文件部分，例如haproxy.conf
     IC是前端，实现配置文件中的frontend **部分
  ```
       frontend fe_web1
        mode http
        maxconn 20000
        bind web1:80
        acl web1_acl hdr_reg(host) -i ^/web1
        use_backend be_web1if web1_acl
  ```
 HTTP代理服务器是后端，实现配置文件中的backend **部分

```
       backend be_web1
        mode http 
        option httpchk GET / HTTP/1.1\r\nHost:\ web1
        balance roundrobin
        server testdmp test-dmp-v1:80 check
```

### 通讯拓扑图
  通过下面的例子，总结下面的通讯图（通讯方向从左至右） 

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsVObQ3l.jpg)

 `VIP`：为了防止node出现单点故障，使用LVS+keepalived等软件实现的。

 kube node的docker把IC（ingress controller） pod开启443和80端口映射到公网，实现外部访问。

 ICpod的作用是ingress的规则发现，根据规则转发流量给后端的BackendLB。

创建Ingress的yaml文件参数说明
```
apiVersion:extensions/v1beta1
kind:Ingress
metadata:
  name: lykops-ingress
 spec:
  rules:
  - http:
    paths:
    - path:/lykops
     backend:
      serviceName: lykops
      servicePort:80
```
 如果没有配置Ingress controller就将其POST到API server不会有任何用处

 #### 配置说明
1-4行：跟K8S的其他配置一样，ingress的配置也需要apiVersion，kind和metadata字段。

5-7行: Ingress spec 中包含配置一个LB或proxy server的所有信息。最重要的是，它包含了一个匹配所有入站请求的规则列表。目前ingress只支持http规则。

8-9行：每条http规则包含以下信息：一个host配置项（比如for.bar.com，在这个例子中默认是*），path列表（比如：/testpath），每个path都关联一个backend(比如test:80)。在LB将流量转发到backend之前，所有的入站请求都要先匹配host和path。

10-12行：正如 services doc中描述的那样，backend是一个service:port的组合。Ingress的流量被转发到它所匹配的backend。

部署例子
 这是例子基于名称的虚拟主机的ingess。
部署http负载均衡器
```
cat << EOF > lykops-ingess-backup-l7lb.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: lykops-ingess-backup-l7lb
  labels:
    software: apache
    project: test
    app: backup-l7lb
    version: v1
spec:
  selector:
    matchLabels:
      software: apache
      project: test
      app: backup-l7lb
      version: v1
  template:
    metadata:
      labels:
        name: lykops-ingess-backup-l7lb
    spec:
      terminationGracePeriodSeconds: 60
      containers:
        - name: lykops-ingress-backup-l7lb
          image: docker.io/googlecontainer/defaultbackend:1.0
          #readinessProbe:
          ​    #  httpGet:
          ​    #   path: /healthz
          ​    #   port: 80
          ​    #   scheme: HTTP
          ​    #livenessProbe:
          ​    #  httpGet:
          ​    #   path: /healthz
          ​    #   port: 80
          ​    #   scheme: HTTP
          ​    #  initialDelaySeconds: 10
          ​    #  timeoutSeconds: 1
          ports:
            - containerPort: 80
          resources:
            limits:
              cpu: 10m
              memory: 20Mi
            requests:
              cpu: 10
              memory: 20Mi
EOF
```

```
kubectl create -f lykops-ingess-backup-l7lb.yaml
```

```
cat << EOF > lykops-ingess-backup-l7lb-svc.yaml

apiVersion: v1

kind: Service

metadata:

 name: test-ingess-backup-l7lb

 labels:

  software: apache

  project: lykops

  app: backup-l7lb

  version: v1

spec:

 selector:

  name: lykops-ingess-backup-l7lb

  software: apache

  project: lykops

  app: backup-l7lb

  version: v1

 ports:

 -name: http

  port: 80

  protocol: TCP

EOF
```

```
kubectl create -f lykops-ingess-backup-l7lb-svc.yaml
```

 注意：
1. 注释部分用途，注释之后telnet 这个service clusterIP 80，会立即断开；访问页面，提示"连接被重置”"无法访问。
2. 如果不注释，livenessProbe检测认为失败，会不断创建pod
配置ingress-controller
```
cat << EOF > lykops-inging-control.yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
 name: lykops-inging-control
 labels:
  software: apache
  project: lykops
  app: inging-control
  version: v1
spec:
 template:
  metadata:
   labels:
    name: lykops-inging-control
    software: apache
    project: lykops
    app: inging-control
    version: v1
  spec:
   terminationGracePeriodSeconds: 60
   containers:
   - image: docker.io/googlecontainer/nginx-ingress-controller:0.8.3

    name: lykops-inging-control
    #readinessProbe:
    #  httpGet:
    #   path: /healthz
    #   port: 80
    #   scheme: HTTP
    #livenessProbe:
    #  httpGet:
    #   path: /healthz
    #   port: 80
    #   scheme: HTTP
    #  initialDelaySeconds: 10
    #  timeoutSeconds: 1
    env:
     - name: POD_NAME
      valueFrom:
       fieldRef:
        fieldPath: metadata.name
     - name: POD_NAMESPACE
      valueFrom:
       fieldRef:
        fieldPath: metadata.namespace
     - name: KUBERNETES_MASTER
      value: http://192.168.20.128:8080
    ports:
    - containerPort: 80
     hostPort: 80
    - containerPort: 443
     hostPort: 443
    args:
    - /nginx-ingress-controller
    #- --default-backend-service=${POD_NAMESPACE}/default-http-backend
    - --default-backend-service=default/test-ingess-backup-l7lb
EOF
```

```
kubectl create -f lykops-inging-control.yaml
```

 注意：
1. 注释部分用途，注释之后访问页面，页面返回502错误。
2. 如果不注释，livenessProbe检测认为失败，会不断创建pod。

配置ingress
```
cat << EOF > lykops-inging.yaml 
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
 name: lykops-inging
 labels:
  project: lykops
  app: inging
  version: v1
spec:
 rules:
 - host: web1
    http:
   paths:
   - path: /
    backend:
     serviceName: dpm-web-v1
     servicePort: 80
 - host: web2
    http:
   paths:
   - path: /
    backend:
     serviceName: dpm-web-v2
     servicePort: 80
EOF
```

```
kubectl create -f test-inging.yaml
```

测试
 测试方法有两种 
1、curl -v http://kube-node的IP地址 -H 'host: web3'
curl -v http://192.168.20.131 -H 'host: web3'
 2、将访问url的主机的host中加上：nodeip web1

## 完整TOMCAT实例
注意：本文中和上文中的NodePort没有完全解决外部访问Service的所有问题，比如负载均衡，假如我们又10个Node，则此时最好有一个负载均衡器，外部的请求只需访问此负载均衡器的IP地址，由负载局衡器负责转发流量到后面某个Node的NodePort上。这个负载均衡器可以是硬件，也可以是软件方式，例如HAProxy或者Nginx； 

 如果我们的集群运行在谷歌的GCE公有云上，那么只要我们把Service的type=NodePort改为type=LoadBalancer，此时Kubernetes会自动创建一个对应的LoadBalancer实例并返回它的IP地址供外部客户端使用。其它公有云提供商只要实现了支持此特性的驱动，则也可以达到上述目的
 也就是說该模式需要底层云平台（例如GCE）支持。

### Java Web应用 
>注：Tomcat有可能无法正常启动，原因是虚机的内存和CPU设置过小，请酌情调大！
镜像
下载地址
https://hub.docker.com/r/kubeguide/tomcat-app/
拉取
Tomcat镜像
 docker pull kubeguide/tomcat-app:v2
Mysql镜像
docker pull daocloud.io/library/mysql:latest

构建Mysql RC定义文件（构建创建Pod的源文件）
命名
 mysql-rc.yaml
内容
```
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: daocloud.io/library/mysql:latest
          ports:
            - containerPort: 3306
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: "123456"
```

发布到Kubernetes集群
创建RC
  ```
kubectl create -f mysql-rc.yaml
  ```
查看RC
```
kubectl get rc
```
查看Pod
```
kubectl get pods
```
构建Mysql Kubernetes Service定义文件
命名
 mysql-svc.yaml
内容
```
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  ports:
    - port: 3306
  selector:
    app: mysql
```
创建
```
kubectl create -f mysql-svc.yaml
```
查看SVC
```
kubectl get svc
```
构建Tomcat RC定义文件
命名
 myweb-rc.yaml
内容
```
kind: ReplicationController
apiVersion: v1
metadata:
  name: myweb
spec:
  replicas: 1
  # spec.selector与spec.template.metadata.labels，这两个字段必须相同，否则下一步创建RC会失败。
  selector:
    app: myweb
  template:
    metadata:
      labels:
        app: myweb
    spec:
      containers:
        - name: myweb
          image: kubeguide/tomcat-app:v2
          ports:
            #     在8080端口上启动容器进程，PodIP与容器端口组成Endpoint，代表着一个服务进程对外通信的地址
            - containerPort: 8080
          env:
          #此处如果在未安装域名解析的情况下，会无法将mysql对应的IP解析到env环境变量中，因此先注释掉！
#            - name: MYSQL_SERVICE_HOST
#              value: "mysql"
            - name: MYSQL_SERVICE_PORT
              value: "3306"
```
发布到Kubernetes集群
创建RC
  ```
kubectl create -f myweb-rc.yaml
  ```
查看RC
```
kubectl get rc
```
查看Pod
```
kubectl get pods
```
构建Tomcat Kubernetes Service定义文件
命名
 myweb-svc.yaml
内容
```
apiVersion: v1
kind: Service
metadata:
  name: myweb
spec:
  type: NodePort
  ports:
    - port: 8080
      nodePort: 30002
  selector:
    app: myweb
```
创建
```
kubectl create -f myweb-svc.yaml
```
查看SVC
```
kubectl get services
```
运行
 浏览器中输入http://虚拟机IP:30002/demo即可呈现如下内容：
 注意在节点（node）中访问，不是master
![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsBE1ZsJ.jpg) 

# INGRESS详解
官方文档地址：
https://v1-14.docs.kubernetes.io/docs/concepts/services-networking/ingress/

## Ingress 介绍
Kubernetes 暴露服务的方式目前只有三种：LoadBlancer Service、NodePort Service、Ingress；

## LoadBlancer Service
是 kubernetes 深度结合云平台的一个组件；当使用  LoadBlancer Service 暴露服务时，实际上是通过向底层云平台申请创建一个负载均衡器来向外暴露服务；目前 LoadBlancer  Service 支持的云平台已经相对完善，比如国外的 GCE DigitalOcean，国内的 阿里云，私有云 Openstack 等等，由于  LoadBlancer Service 深度结合了云平台，所以只能在一些云平台上来使用

## NodePort Service
实质上就是通过在集群的每个 node 上暴露一个端口，然后将这个端口映射到某个具体的 service 来实现的，虽然每个 node 的端口有很多(0~65535)，但是由于安全性和易用性(服务多了就乱了，还有端口冲突问题)实际使用可能并不多

## Ingress
是 1.2 后才出现的，通过 Ingress 用户可以实现使用 nginx 等开源的反向代理负载均衡器实现对外暴露服务

Ingress为你提供`七层负载均衡`能力，你可以通过 Ingress 配置提供外部可访问的 URL、负载均衡、SSL、基于名称的虚拟主机等。作为集群流量接入层，Ingress 的高可靠性显得尤为重要。
  internet
     |
  [ Ingress ]
  --|-----|--
  [ Services ]

## 集群内服务想要暴露出去面临着几个问题

#### Pod 漂移问题
Kubernetes  具有强大的副本控制能力，能保证在任意副本(Pod)挂掉时自动从其他机器启动一个新的，还可以动态扩容等，总之一句话，这个 Pod  可能在任何时刻出现在任何节点上，也可能在任何时刻死在任何节点上；那么自然随着 Pod 的创建和销毁，Pod IP 肯定会动态变化；那么如何把这个动态的  Pod IP 暴露出去？这里借助于 Kubernetes 的 Service 机制，Service 可以以标签的形式选定一组带有指定标签的  Pod，并监控和自动负载他们的 Pod IP，那么我们向外暴露只暴露 Service IP 就行了；这就是 NodePort 模式：即在每个节点上开起一个端口，然后转发到内部 Pod IP 上
此时的访问方式：http://nodeip:nodeport/
![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsac2fS6.jpg)  

#### 端口管理问题
采用 NodePort 方式暴露服务面临问题是，服务一旦多起来，NodePort 在每个节点上开启的端口会及其庞大，而且难以维护；这时，我们能否使用一个Nginx直接对内进行转发呢？

众所周知的是，Pod与Pod之间是可以互相通信的，而Pod是可以共享宿主机的网络名称空间的，也就是说当在共享网络名称空间时，Pod上所监听的就是Node上的端口。那么这又该如何实现呢？简单的实现就是使用 DaemonSet 在每个 Node 上监听 80，然后写好规则，因为 Nginx 外面绑定了宿主机 80 端口（就像 NodePort），本身又在集群内，那么向后直接转发到相应 Service IP 就行了，如下图所示：
![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpslGzyhu.jpg)  

#### 域名分配及动态更新问题
从上面的方法，采用 Nginx-Pod 似乎已经解决了问题，但是其实这里面有一个很大缺陷：当每次有新服务加入又该如何修改 Nginx  配置呢？我们知道使用Nginx可以通过虚拟主机域名进行区分不同的服务，而每个服务通过upstream进行定义不同的负载均衡池，再加上location进行负载均衡的反向代理，在日常使用中只需要修改nginx.conf即可实现，那在K8S中又该如何实现这种方式的调度呢？

假设后端的服务初始服务只有ecshop，后面增加了bbs和member服务，那么又该如何将这2个服务加入到Nginx-Pod进行调度呢？总不能每次手动改或者Rolling  Update 前端 Nginx Pod 吧！此时 Ingress 出现了，如果不算上面的Nginx，Ingress  包含两大组件：Ingress Controller 和 Ingress。
  ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpssXTTGR.jpg)

Ingress 简单的理解就是你原来需要改 Nginx 配置，然后配置各种域名对应哪个 Service，现在把这个动作抽象出来，变成一个  Ingress 对象，你可以用 yaml 创建，每次不要去改 Nginx 了，直接改 yaml 然后创建/更新就行了；那么问题来了：”Nginx  该怎么处理？”

Ingress Controller 就是解决 “Nginx 的处理方式” 的；Ingress Controller 通过与  Kubernetes API 交互，动态的去感知集群中 Ingress 规则变化，然后读取他，按照他自己模板生成一段 Nginx 配置，再写到  Nginx Pod 里，最后 reload 一下，工作流程如下图：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsbLuh6e.jpg) 

Ingress也是Kubernetes  API的标准资源类型之一，它其实就是一组基于DNS名称（host）或URL路径把请求转发到指定的Service资源的规则。用于将集群外部的请求流量转发到集群内部完成的服务发布。

Ingress资源自身不能进行"`流量穿透`"，仅仅是一组规则的集合，这些集合规则还需要其他功能的辅助，比如监听某套接字，然后根据这些规则的匹配进行路由转发，这些能够为Ingress资源监听套接字并将流量转发的组件就是Ingress  Controller。

#### Ingress 控制与Deployment 控制器的不同

Ingress控制器不直接运行为kube-controller-manager的一部分，它仅仅是Kubernetes集群的一个附件，类似于CoreDNS，需要在集群上单独部署。

最新版本 k8s 已经将 Nginx 与 Ingress Controller 合并为一个组件，所以 Nginx 无需单独部署，只需要部署 Ingress Controller 即可

Ingress 有三个组件:

  反向代理负载均衡器

  Ingress Controller

  Ingress

## 反向代理负载均衡器

反向代理负载均衡器就是 nginx、apache 等；在集群中反向代理负载均衡器可以自由部署，可以使用  Replication Controller、Deployment、DaemonSet 等等

## Ingress Controller

Ingress Controller 可以理解为是个监视器，Ingress Controller 通过不断地跟 kubernetes  API 打交道，实时的感知后端 service、pod 等变化，比如新增和减少 pod，service  增加与减少等；当得到这些变化信息后，Ingress Controller 再结合下文的 Ingress  生成配置，然后更新反向代理负载均衡器，并刷新其配置，达到服务发现的作用

## Ingress

ngress 简单理解就是个规则定义；

比如说某个域名对应某个 service，即当某个域名的请求进来时转发给某个 service;

这个规则将与 Ingress Controller 结合，然后 Ingress Controller  将其动态写入到负载均衡器配置中，从而实现整体的服务发现和负载均衡

 

实际上请求进来还是被负载均衡器拦截，比如 nginx，然后 Ingress Controller 通过跟  Ingress 交互得知某个域名对应哪个 service，再通过跟 kubernetes API 交互得知 service  地址等信息；综合以后生成配置文件实时写入负载均衡器，然后负载均衡器 reload 该规则便可实现服务发现，即`动态映射`

把负载均衡器部署为 Daemon  Set比较好，因为无论如何请求首先是被负载均衡器拦截的，所以在每个 node 上都部署一下，同时 hostport 方式监听 80  端口；那么就解决了其他方式部署不确定 负载均衡器在哪的问题，同时访问每个 node 的 80 都能正确解析请求；如果前端再放个 nginx  就又实现了一层负载均衡

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsN0CJvC.jpg)  

## 如何创建INGRESS资源

#### Ingress资源
是`基于HTTP虚拟主机或URL的转发规则`。它在资源配置清单中的spec字段中嵌套了`rules`、`backend`和`tls`等字段进行定义。

#### 定义Ingress资源
  其包含了一个转发规则：
  将发往myapp.exam.com的请求，代理给一个名字为myapp的Service资源。
```
kind: Ingress
apiVersion: extensions/v1beta1
metadata:
  name: ingress-myapp
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
    - host: myapp.exam.com
    - http:
        paths:
          - backend:
              serviceName: myapp
              servicePort: 80
```

spec字段:
Ingress 中的spec字段是Ingress资源的核心组成部分，主要包含3个字段：

#### rules
用于定义当前Ingress资源的转发规则列表；由rules定义规则，或没有匹配到规则时，所有的流量会转发到由backend定义的默认后端。

rules对象由一系列的配置的Ingress资源的host规则组成，这些host规则用于将一个主机上的某个URL映射到相关后端Service对象

#### backend
默认的后端用于服务那些没有匹配到任何规则的请求；定义Ingress资源时，必须要定义backend或rules两者之一，该字段用于让负载均衡器指定一个全局默认的后端。

他的定义由2个必要的字段组成：serviceName和servicePort，分别用于指定流量转发的后端目标Service资源名称和端口。

#### host
目前暂不支持使用IP地址定义，也不支持IP:Port的格式，该字段留空表示使用默认的*，代表通配所有主机名。

#### tls
TLS配置，目前仅支持通过默认端口443提供服务，如果要配置指定的列表成员指向不同的主机，则需要通过SNI TLS扩展机制来支持该功能。由2个内嵌的字段组成，仅在定义TLS主机的转发规则上使用

## INGRESS NGINX部署

环境准备
部署之前需要知道的点：
1. Ingress 是 beta 资源，在 1.1 之前的任何 Kubernetes 版本中都不可用。 
2. 您需要一个 Ingress 控制器来满足 Ingress，否则简单地创建资源将不起作用。
3. 在 GCE／Google Kubernetes Engine 之外的环境中，需要将控制器部署为 Pod。

创建ingress资源：

\# vim ingress.yaml
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - http:
        paths:
          - path: /testpath
            backend:
              serviceName: test
              servicePort: 80
```
如果尚未配置 Ingress 控制器，则向 API 服务器 POST 操作将没有任何效果。

### Ingress 控制器
为了使 Ingress 资源正常工作，集群必须有 Ingress 控制器运行。 这不同于其他类型的控制器，它们通常作为 kube-controller-manager 二进制文件的一部分运行，并且通常作为集群创建的一部分自动启动。 请选择最适合您的集群的 Ingress 控制器，或者实现一个新的 Ingress 控制器。

> 注：各种类型的ingress控制器
>
> Kubernetes 当前支持并维护 GCE 和 nginx 控制器。
>
> F5 Networks 为 F5 BIG-IP Controller for Kubernetes 提供支持和维护。
>
> Kong 为 Kong Ingress Controller for Kubernetes 提供 社区版 或 商业版 支持和维护。
>
> Traefik 是个全功能的 Ingress 控制器。 (Let’s Encrypt, secrets, http2, websocket…), 它也伴随着 Containous 的商业支持。
>
> NGINX, Inc. 为 NGINX Ingress Controller for Kubernetes 提供支持和维护。
>
> HAProxy 是 Ingress 控制器 jcmoraisjr/haproxy-ingress 的基础， 在这个博客中有提到它 HAProxy Ingress Controller for Kubernetes。
>
> Istio 是 Ingress 控制器 Control Ingress Traffic 的基础。
>

## 完整INGRESS实验

Ingress 使用开源的反向代理负载均衡器来实现对外暴漏服务，比如 Nginx、Apache、Haproxy等。Nginx Ingress 一般有三个组件组成：  

1. Nginx 反向代理负载均衡器

2. Ingress Controller 可以理解为控制器，它通过不断的跟 Kubernetes API 交互，实时获取后端 Service、Pod 等的变化，比如新增、删除等，然后结合 Ingress 定义的规则生成配置，然后动态更新上边的 Nginx 负载均衡器，并刷新使配置生效，来达到服务自动发现的作用。

3. Ingress 则是定义规则，通过它定义某个域名的请求过来之后转发到集群中指定的 Service。它可以通过 Yaml 文件定义，可以给一个或多个 Service 定义一个或多个 Ingress 规则。

Ingress Controller 下载地址:

https://github.com/kubernetes/ingress-nginx/archive/nginx-0.11.0.tar.gz

ingress-nginx文件位于deploy目录下，各文件的作用：

configmap.yaml: 提供configmap可以在线更新nginx的配置

default-backend.yaml:提供一个缺省的后台错误页面 404

namespace.yaml:创建一个独立的命名空间 ingress-nginx

rbac.yaml：创建对应的role rolebinding 用于rbac

tcp-services-configmap.yaml:修改L4负载均衡配置的configmap

udp-services-configmap.yaml:修改L4负载均衡配置的configmap

with-rbac.yaml:有应用rbac的nginx-ingress-controller组件

修改with-rbac.yaml
```
apiVersion: extensions/v1beta1
kind: Daemonset
metadata:
 name: nginx-ingress-controller
 namespace: ingress-nginx 
spec:
 selector:
  matchLabels:
   app: ingress-nginx
 template:
  metadata:
   labels:
    app: ingress-nginx
   annotations:
    prometheus.io/port: '10254'
    prometheus.io/scrape: 'true'
  spec:
   serviceAccountName: nginx-ingress-serviceaccount
   hostNetwork: true
   containers:
    - name: nginx-ingress-controller
     image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.11.0
     args:
      - /nginx-ingress-controller
      - --default-backend-service=$(POD_NAMESPACE)/default-http-backend
      - --configmap=$(POD_NAMESPACE)/nginx-configuration
      - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
      - --udp-services-configmap=$(POD_NAMESPACE)/udp-services
      - --annotations-prefix=nginx.ingress.kubernetes.io
     env:
      - name: POD_NAME
       valueFrom:
        fieldRef:
         fieldPath: metadata.name
      - name: POD_NAMESPACE
       valueFrom:
        fieldRef:
         fieldPath: metadata.namespace
     ports:
     - name: http
      containerPort: 80
     - name: https
      containerPort: 443
     livenessProbe:
      failureThreshold: 3
      httpGet:
       path: /healthz
       port: 10254
       scheme: HTTP
      initialDelaySeconds: 10
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 1
     readinessProbe:
      failureThreshold: 3
      httpGet:
       path: /healthz
       port: 10254
       scheme: HTTP
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 1
   nodeSelector:
    custom/ingress-controller-ready: "true"
```

需要修改的地方：
kind: DaemonSet：官方原始文件使用的是deployment，replicate 为 1，这样将会在某一台节点上启动对应的nginx-ingress-controller pod。外部流量访问至该节点，由该节点负载分担至内部的service。测试环境考虑防止单点故障，改为DaemonSet然后删掉replicate ，配合亲和性部署在制定节点上启动nginx-ingress-controller pod，确保有多个节点启动nginx-ingress-controller pod，后续将这些节点加入到外部硬件负载均衡组实现高可用性。

hostNetwork: true：添加该字段，暴露nginx-ingress-controller pod的服务端口（80）

nodeSelector: 增加亲和性部署，有custom/ingress-controller-ready 标签的节点才会部署该DaemonSet

为需要部署nginx-ingress-controller的节点设置lable
```
\# kubectl label nodes node1 custom/ingress-controller-ready=true

\# kubectl label nodes node2 custom/ingress-controller-ready=true
```

创建Ingress-controller
```
\# kubectl create -f namespace.yaml

\# kubectl create -f default-backend.yaml

\# kubectl create -f configmap.yaml

\# kubectl create -f tcp-services-configmap.yaml

\# kubectl create -f udp-services-configmap.yaml

\# kubectl create -f rbac.yaml

\# kubectl create -f with-rbac.yaml
```


查看pod
```
\# kubectl get pods --namespace=ingress-nginx
```

测试ingress 

创建一个apache的Service

\# cat my-apache.yaml 
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
 name: my-apache
spec:
 replicas: 2
 template:
  metadata:
   labels:
    run: my-apache
  spec:
   containers:
   - name: my-apache
    image: httpd:2.4
    ports:
    - containerPort: 80

 ---

apiVersion: v1
kind: Service
metadata:
 name: my-apache
 labels:
  run: my-apache
spec:
 type: NodePort
 ports:
 - port: 80
  targetPort: 80
  nodePort: 30002
 selector:
  run: my-apache
```
```
\# kubectl create -f ./my-apache.yaml
```


创建一个nginx的Service

\# cat my-nginx.yaml
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
 name: my-nginx
spec:
 replicas: 2
 template:
  metadata:
   labels:
    run: my-nginx
  spec:
   containers:
   - name: my-nginx
    image: daocloud.io/library/nginx:1.7.9
    ports:
    - containerPort: 80

 ---

apiVersion: v1
kind: Service
metadata:
 name: my-nginx
 labels:
  run: my-nginx
spec:
 type: NodePort
 ports:
 - port: 80
  targetPort: 80
  nodePort: 30001
 selector:
  run: my-nginx
```
```
\# kubectl create -f ./my-nginx.yaml
```


现在集群中有两个服务，一个是my-apache，另一个是my-nginx
```
\# kubectl get svc
```


配置ingress转发文件

\# vi test-ingress.yaml
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
 name: test-ingress
 namespace: default
spec:
 rules:
 - host: test.apache.ingress
  http:
   paths:
   - path: /
    backend:
     serviceName: my-apache
     servicePort: 80
 - host: test.nginx.ingress
  http:
   paths:
   - path: /
    backend:
     serviceName: my-nginx
     servicePort: 80
```


host: 对应的域名 

path: url上下文 

backend:后向转发 到对应的 serviceName: servicePort:


```
\# kubectl apply -f test-ingress.yaml

\# kubectl get ingress
```

nginx-ingress-controller运行在node1,node2两个节点上。

如果网络中有dns服务器，在dns中把这两个域名映射到nginx-ingress-controller运行的任意一个节点上，如果没有dns服务器只能修改host文件了。

注： 
正规的做法是在node1,node2这2个节点上安装keepalived，生成一个vip。在dns上把域名和vip做映射。

 

任意一个节点上操作：

我这里有两个节点部署了控制器，ip分别为192.168.1.201，192.168.1.202 ，如果有多个，可以随便选。
```
\# echo '192.168.1.201 test.apache.ingress' >> /etc/hosts

\# echo '192.168.1.202 test.nginx.ingress' >> /etc/hosts
```

测试test.nginx.ingress
```
\# curl test.nginx.ingress
```

测试test.apache.ingress
```
\# curl test.apache.ingress
```

如果不修改hosts文件可以通过下面的命令测试

通过-H 指定模拟的域名
```
\# curl -v http://192.168.1.201 -H 'host: test.apache.ingress'

\# curl -v http://192.168.1.202 -H 'host: test.nginx.ingress'
```

# 控制器模式解析

## 控制器模式
k8s 项目通过一个称作"控制器模式"（controller pattern）的设计方法，来统一地实现对各种不同的对象或者资源进行的编排操作。

Pod 这个API 对象，实际上就是对容器的进一步抽象和封装而已。

容器镜像虽然好用，但是容器这样一个"沙盒"的概念，对于描述应用来说太过简单。好比，集装箱固然好用，如果它四面都光秃秃的，吊车还怎么把这个集装箱吊起来并摆放好呢？

所以，Pod 对象，其实就是容器的升级版。它对容器进行了组合，添加了更多的属性和字段。这就好比给集装箱四面安装了吊环，使得 Kubernetes 这架"吊车"，可以更轻松地操作它。而 k8s 操作这些"集装箱"的逻辑，都由控制器（Controller）完成。

 回顾 Deployment 这个最基本的控制器对象。之前讲过一个 nginx-deployment 的例子：

```
apiVersion: apps/v1
kind: Deployment
metadata:
 name: nginx-deployment
spec:
 selector:
  matchLabels:
   app: nginx
 replicas: 2
 template:
  metadata:
   labels:
    app: nginx
  spec:
   containers:
   - name: nginx
    image: nginx:1.7.9
    ports:
    - containerPort: 80
```

 这个 Deployment 定义的编排动作为：

  确保携带了 app=nginx 标签的 Pod 的个数，永远等于 spec.replicas 指定的个数，即 2 个。如果在这个集群中，携带 app=nginx 标签的 Pod 的个数大于 2 的时候，就会有旧的 Pod 被删除；反之，就会有新的 Pod 被创建。

究竟是 Kubernetes 项目中的哪个组件，在执行这些操作呢？

kube-controller-manager 组件：这个组件，就是一系列控制器的集合

  

查看所有控制器：

在Kubernetes 项目的 pkg/controller 目录下  //注意：非二进制方式安装的集群找不到此目录

```
# cd kubernetes/pkg/controller/

\# ls -d */        
```

这个目录下面的每一个控制器，都以独有的方式负责某种编排功能。而Deployment，正是这些控制器中的一种。



通用编排模式：`控制循环`

这些控制器被统一放在 pkg/controller 目录下，是因为它们都遵循 k8s 项目中的一个通用编排模式，即：控制循环（control loop）。

比如，现有一种待编排的对象 X，它有一个对应的控制器。可以用一段 Go 语言风格的伪代码描述这个控制循环：

```
for {
 实际状态 := 获取集群中对象 X 的实际状态（Actual State）
 期望状态 := 获取集群中对象 X 的期望状态（Desired State）
 if 实际状态 == 期望状态{
  什么都不做
 } else {
  执行编排动作，将实际状态调整为期望状态
 }
}
```

 

实际状态来源：实际状态来自于 Kubernetes 集群本身。

比如，kubelet 通过心跳汇报的容器状态和节点状态，或者监控系统中保存的应用监控数据，或者控制器主动收集的它自己感兴趣的信息，这些都是常见的实际状态的来源。

 

期望状态来源：来自于用户提交的 YAML 文件

比如，Deployment 对象中 Replicas 字段的值。很明显，这些信息往往都保存在 Etcd 中。

 

以 Deployment 为例，描述它对控制器模型的实现：

1. Deployment 控制器从 Etcd 中获取到所有携带了"app: nginx"标签的 Pod，然后统计它们的数量，这就是实际状态；

2. Deployment 对象的 Replicas 字段的值就是期望状态；

3. Deployment 控制器将两个状态做比较，然后根据比较结果，确定是创建 Pod，还是删除已有的 Pod

 

调谐：一个 Kubernetes 对象的主要编排逻辑，实际上是在第三步的"对比"阶段完成的。

这个操作，通常被叫作`调谐`（Reconcile）。这个调谐的过程，则被称作"Reconcile Loop"（调谐循环）或者"Sync Loop"（同步循环）。

在其他文档中碰到这些词，它们其实指的都是同一个东西：控制循环。

 

调谐结果：调谐的最终结果，往往都是对被控制对象的某种写操作。

比如，增加 Pod，删除已有的 Pod，或者更新 Pod 的某个字段。这也是 Kubernetes 项目"面向 API 对象编程"的一个直观体现。

像 Deployment 这种控制器的设计原理，就是"用一种对象管理另一种对象"的"艺术"。

其中，这个控制器对象本身，负责定义被管理对象的期望状态。比如，Deployment 里的 replicas=2 这个字段。

 

而被控制对象的定义，则来自于一个"模板"。比如，Deployment 里的 template 字段。

Deployment 这个 template 字段里的内容，跟一个标准的 Pod 对象的 API 定义，丝毫不差。而所有被这个 Deployment 管理的 Pod 实例，都是根据这个 template 字段的内容创建出来的。

 

像 Deployment 定义的 template 字段，在 k8s 中有一个专有的名字，叫作 PodTemplate（Pod 模板）。

 

对 Deployment 以及其他类似的控制器，做一个总结：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsy5fNVZ.jpg) 

如图，类似 Deployment 的一个控制器，都是由两部分组成：

  上半部分的控制器定义（包括期望状态）

  下半部分的被控制对象的模板组成的。

 

这就是为什么，在所有 API 对象的 Metadata 里，都有一个字段叫作 ownerReference，用于保存当前这个 API 对象的拥有者（Owner）的信息。

 

对于这个 nginx-deployment 来说，它创建出来的 Pod 的 ownerReference 就是 nginx-deployment 吗？或者说，nginx-deployment 所直接控制的，就是 Pod 对象么？

 

很多不同类型的容器编排功能，比如 StatefulSet、DaemonSet 等等，都有这样一个甚至多个控制器的存在，并遵循控制循环（control loop）的流程，完成各自的编排逻辑。这些控制循环最后的执行结果，要么就是创建、更新一些 Pod（或者其他的 API 对象、资源），要么就是删除一些已经存在的 Pod（或者其他的 API 对象、资源）。

 

但也正是在这个统一的编排框架下，不同的控制器可以在具体执行过程中，设计不同的业务逻辑，从而达到不同的编排效果。

这个实现思路，正是 k8s 进行容器编排的核心原理。

## 问题

Kubernetes 使用的"控制器模式"，跟我们平常所说的"事件驱动"，有什么区别和联系？

# 水平扩展/收缩
Deployment与 ReplicaSet以及 Pod 的关系：

#### ReplicaSet
如果更新了 Deployment 的 Pod 模板（比如，修改了容器的镜像）那么Deployment 就要遵循一种叫作"`滚动更新`"（rolling update）的方式，来升级现有的容器。这个能力的实现，依赖的是：ReplicaSet。

#### ReplicaSet 的结构
ReplicaSet 的结构非常简单，通过一个 YAML 文件查看一下：

```
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-set
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: daocloud.io/library/nginx
```
一个 ReplicaSet 对象，是由副本数目的定义和一个 Pod 模板组成的。它的定义实际是 Deployment 的一个子集。
Deployment 控制器实际操纵的，正是 ReplicaSet 对象，而不是 Pod 对象。

问题：对于一个 Deployment 所管理的 Pod，它的 ownerReference 是谁？

答案：ReplicaSet。

明白了这个原理，分析一个如下所示的 Deployment：

\# vim nginx-deployment.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: daocloud.io/library/nginx
          ports:
            - containerPort: 80
```

这是一个常用的 nginx-deployment，定义的 Pod 副本个数是 3（spec.replicas=3）。

Deployment，与 ReplicaSet，以及 Pod 的关系用一张图把它描述出来：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps2CzZln.jpg) 

 

一个定义了 replicas=3 的 Deployment，与它的 ReplicaSet，以及 Pod 的关系，实际上是一种"`层层控制`"的关系。

其中，ReplicaSet 负责通过"控制器模式"，保证系统中 Pod 的个数永远等于指定的个数（比如，3 个）。这也正是 `Deployment 只允许容器的 restartPolicy=Always` 的主要原因：只有在容器能保证自己始终是 Running 状态的前提下，ReplicaSet 调整 Pod 的个数才有意义。

在此基础上，Deployment 同样通过"控制器模式"，来操作 ReplicaSet 的个数和属性，进而实现"水平扩展 / 收缩"和"滚动更新"这两个编排动作。

#### 水平扩展 / 收缩
Deployment Controller 只需要修改它所控制的 ReplicaSet 的 Pod 副本个数就可。

比如，把这个值从 3 改成 4，那么 Deployment 所对应的 ReplicaSet，就会根据修改后的值自动创建一个新的 Pod。这就是"水平扩展"了；"水平收缩"则反之。

操作: 
```
kubectl scale deployment nginx-deployment --replicas=4

deployment.apps/nginx-deployment scaled
或者
修改yaml文件，直接apply更新
```


# 滚动更新

### 概念
将一个集群中正在运行的多个 Pod 版本，交替地逐一升级的过程，就是"滚动更新"。

实验：

创建上节儿的：nginx-deployment
```
kubectl create -f nginx-deployment.yaml --record
```
--record  记录下每次操作所执行的命令，以方便后面查看

检查nginx-deployment 创建后的状态信息：
```
[root@centos708 yaml]# kubectl get deployments
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           22s
```

返回结果中四个状态字段含义：
`DESIRED`
如果有就表示用户期望的 Pod 副本个数（spec.replicas 的值）；

`CURRENT`
当前处于 Running 状态的 Pod 的个数；

`UP-TO-DATE`
当前处于最新版本的 Pod 的个数，所谓最新版本指的是 Pod 的 Spec 部分与 Deployment 里 Pod 模板里定义的完全一致；

`AVAILABLE`
当前已经可用的 Pod 的个数，即：既是 Running 状态，又是最新版本，并且已经处于 Ready（健康检查正确）状态的 Pod 的个数。只有这个字段，描述的才是用户所期望的最终状态。

实时查看 Deployment 对象的状态变化：
```
\# kubectl rollout status deployment/nginx-deployment

Waiting for rollout to finish: 2 out of 3 new replicas have been updated...

deployment.apps/nginx-deployment successfully rolled out
```
结果中，"2 out of 3 new replicas have been updated"意味着已经有 2 个 Pod 进入了 UP-TO-DATE 状态。

查看这个 Deployment 所控制的 ReplicaSet：
```
[root@centos708 yaml]# kubectl get rs
NAME                          DESIRED   CURRENT   READY   AGE

nginx-deployment-5dcb7cf7db   3         3         3       3m53s
```

`pod-template-hash`
在用户提交了一个 Deployment 对象后，Deployment Controller 就会立即创建一个 Pod 副本个数为 3 的 ReplicaSet。这个 ReplicaSet 的名字，则是由 Deployment 的名字和一个随机字符串共同组成。

这个随机字符串叫作 pod-template-hash，在这个例子里就是：5dcb7cf7db。ReplicaSet 会把这个随机字符串加在它所控制的所有 Pod 的标签里，从而保证这些 Pod 不会与集群里的其他 Pod 混淆。

而 ReplicaSet 的 DESIRED、CURRENT 和 READY 字段的含义，和 Deployment 中是一致的。

相比之下，Deployment 只是在 ReplicaSet 的基础上，添加了 UP-TO-DATE 这个跟版本有关的状态字段。这时如果修改了 Deployment 的 Pod 模板，"滚动更新"就会被自动触发。

**修改 Deployment**

使用 kubectl edit（后面还有set image的方法） 指令编辑 Etcd 里的 API 对象。
```
\# kubectl edit deployment/nginx-deployment
```
kubectl edit 指令，会直接打开 nginx-deployment 的 API 对象。然后就可以修改这里的 Pod 模板部分了。比如，在这里，将 nginx 镜像的版本升级到了 1.9.1。

> 注：kubectl edit 并不神秘，它不过是把 API 对象的内容下载到了本地文件，让你修改完成后再提交上去。
>

kubectl edit 指令编辑完成后，保存退出，Kubernetes 就会立刻触发"滚动更新"的过程。

可以通过 kubectl rollout status 指令查看 nginx-deployment 的状态变化：
```
\# kubectl rollout status deployment/nginx-deployment
```

这时可以通过查看 Deployment 的 Events，看到这个"滚动更新"的流程：
```
\# kubectl describe deployment nginx-deployment
```
1. 当你修改了 Deployment 里的 Pod 定义之后，Deployment Controller 会使用这个修改后的 Pod 模板，创建一个新的 ReplicaSet（hash=1764197365），这个新的 ReplicaSet 的初始 Pod 副本数是：0。

2. 在 Age=24 s 的位置，Deployment Controller 开始将这个新的 ReplicaSet 所控制的 Pod 副本数从 0 个变成 1 个，即："水平扩展"出一个副本。

3. 在 Age=22 s 的位置，Deployment Controller 又将旧的 ReplicaSet（hash=3167673210）所控制的旧 Pod 副本数减少一个，即："水平收缩"成两个副本。

4. 如此交替进行，新 ReplicaSet 管理的 Pod 副本数，从 0 个变成 1 个，再变成 2 个，最后变成 3 个。而旧的 ReplicaSet 管理的 Pod 副本数则从 3 个变成 2 个，再变成 1 个，最后变成 0 个。这样，就完成了这一组 Pod 的版本升级过程。

**查看新、旧两个 ReplicaSet 的最终状态**
在这个"滚动更新"过程完成后，查看新、旧两个 ReplicaSet 的最终状态：其中，旧 ReplicaSet（hash=3167673210）已经被"水平收缩"成了 0 个副本。

```
\# kubectl get rs
```
**"滚动更新"的好处**
  在升级刚开始的时候，集群里只有 1 个新版本的 Pod。如果这时，新版本 Pod 有问题启动不起来，那么"滚动更新"就会停止，从而允许开发和运维人员介入。而在这个过程中，由于应用本身还有两个旧版本的 Pod 在线，所以服务并不会受到太大的影响。

>   注意：
>  一定要使用 Pod 的 Health Check 机制检查应用的运行状态，而不是简单地依赖于容器的 Running 状态。要不然，虽然容器已经变成 Running 了，但服务很有可能尚未启动，"滚动更新"的效果也就达不到了。

#### RollingUpdateStrategy

为了进一步保证服务的连续性，Deployment Controller 还会确保在任何时间窗口内：

1. 只有指定比例的 Pod 处于离线状态。

2. 只有指定比例的新 Pod 被创建出来。

    这两个比例的值都是可以配置的，默认都是 DESIRED 值的 25%。

  所以，在上面这个 Deployment 的例子中，它有 3 个 Pod 副本，那么控制器在"滚动更新"的过程中永远都会确保至少有 2 个 Pod 处于可用状态，至多只有 4 个 Pod 同时存在于集群中。这个策略，是 Deployment 对象的一个字段，名叫 RollingUpdateStrategy

如下所示：
```
strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
```

`maxSurge`
指除了 DESIRED 数量之外，在一次"滚动"中，Deployment 控制器还可以创建多少个新 Pod

`maxUnavailable`
指的是在一次"滚动"中，Deployment 控制器可以删除多少个旧 Pod。

这两个配置还可以用前面我们介绍的百分比形式来表示，比如：maxUnavailable=50%，指的是最多可以一次删除"50%*DESIRED 数量"个 Pod。

"应用版本和 ReplicaSet 一一对应" 的 设计思想
  Deployment 控制器实际上控制的是 ReplicaSet 的数目，以及每个 ReplicaSet 的属性。

 

  一个应用的版本：
对应的正是一个 ReplicaSet
这个版本应用的 Pod 数量，则由 ReplicaSet 通过它自己的控制器（ReplicaSet Controller）来保证。

  通过这样的多个 ReplicaSet 对象，Kubernetes 项目就实现了对多个"应用版本"的描述。这就是"应用版本和 ReplicaSet 一一对应"的设计思想

 

# 版本回滚
两层控制关系
  Deployment 实际上是一个两层控制器：
​ 首先，它通过ReplicaSet 的个数来描述应用的版本；
然后，它再通过ReplicaSet 的属性（比如 replicas 的值），来保证 Pod 的副本数量。

Deployment 控制 ReplicaSet（版本）
ReplicaSet 控制 Pod（副本数）

rd---->git核心库---->jenkins+git+maven---->tomcat

rd---->git核心库---->jenkins+git+maven+docker-build--->harbor        docker(tomcat)

poststep

set image 指令：
使用kubectl set image（方法二）指令，直接修改 nginx-deployment 所使用的镜像。
  好处：不用像 kubectl edit 那样需要打开编辑器。

生成一个升级失败的版本
 这次，把这个镜像名字修改成一个错误的名字：nginx:1.91。这样就会出现一个升级失败的版本。

  1. 替换镜像
```
    \# kubectl set image deployment/nginx-deployment nginx=nginx:1.91
```

  2. 检查rs状态

​    由于nginx:1.91 镜像在 Docker Hub 中并不存在，这个 Deployment 的"滚动更新"被触发后，会立刻报错并停止

检查ReplicaSet 的状态：
```
    \# kubectl get rs
```

  注意：

下面描述中，最新版k8s集群中的过程已经有了变化：

返回结果中新版本的 ReplicaSet（hash=2156724341）的"水平扩展"已经停止。而且此时，它已经创建了两个  Pod，但是它们都没有进入 READY 状态。这当然是因为这两个 Pod 都拉取不到有效的镜像。

与此同时，旧版本的 ReplicaSet（hash=1764197365）的"水平收缩"，也自动停止了。此时，已经有一个旧 Pod 被删除，还剩下两个旧 Pod。

回滚到以前的旧版本：

把整个 Deployment 回滚到上一个版本：
```
  \# kubectl rollout undo deployment/nginx-deployment
```

其实就是Deployment 的控制器让这个旧 ReplicaSet（hash=1764197365）再次"扩展"成 3 个 Pod，而让新的 ReplicaSet（hash=2156724341）重新"收缩"到 0 个 Pod。

回滚到更早之前的版本:
1. 使用 kubectl rollout history 命令查看每次 Deployment 变更对应的版本。

由于在创建这个 Deployment 的时候，指定了--record 参数，所以创建这些版本时执行的 kubectl 命令，都会被记录下来。
```
  \# kubectl rollout history deployment/nginx-deployment

  deployments "nginx-deployment"
  REVISION   CHANGE-CAUSE
  1          kubectl create -f nginx-deployment.yaml --record
  2          kubectl edit deployment/nginx-deployment
  3          kubectl set image deployment/nginx-deployment nginx=nginx:1.91
```
  可以看到，前面执行的创建和更新操作，分别对应了版本 1 和版本 2，而那次失败的更新操作，则对应的是版本 3。

  查看每个版本对应的 Deployment 的 API 对象的细节：
```
  \# kubectl rollout history deployment/nginx-deployment --revision=3
```

2. 在 kubectl rollout undo 命令行最后，加上要回滚到的指定版本的版本号，就可以回滚到指定版本了。
```
  \# kubectl rollout undo deployment/nginx-deployment --to-revision=3
```

  这样，Deployment Controller 还会按照"滚动更新"的方式，完成对 Deployment 的降级操作。

实现对 Deployment 的多次更新操作，最后只生成一个 ReplicaSet：

  对 Deployment 进行的每一次更新操作，都会生成一个新的 ReplicaSet 对象，有些多余，甚至浪费资源，所以，Kubernetes 项目还提供了一个指令，使得我们对 Deployment 的多次更新操作，最后 只生成一个 ReplicaSet。

1. 在更新 Deployment 前，先执行一条 kubectl rollout pause 指令：

  作用：是让这个 Deployment 进入了一个"暂停"状态。
```
  \# kubectl rollout pause deployment/nginx-deployment

deployment.extensions/nginx-deployment paused
```

  接下来，随意使用 kubectl edit 或者 kubectl set image 指令，修改这个 Deployment 的内容。

  此时 Deployment 正处于"暂停"状态，对 Deployment 的所有修改，都不会触发新的"滚动更新"，也不会创建新的 ReplicaSet。

2. 等到对 Deployment 修改操作都完成之后，只要再执行一条 kubectl rollout resume 指令，就可以把这个 Deployment"恢复"回来：
```
  \# kubectl rollout resume deploy/nginx-deployment

​    deployment.extensions/nginx-deployment resumed
```

在这个 kubectl rollout resume 指令执行之前，在 kubectl rollout pause 指令之后的这段时间里，对 Deployment 进行的所有修改，最后只会触发一次"滚动更新"。

通过检查 ReplicaSet 状态的变化，来验证一下 kubectl rollout pause 和 kubectl rollout resume 指令的执行效果
```
\# kubectl get rs
```
发现只有一个 hash=3196763511 的 ReplicaSet 被创建了出来。

如何控制这些"历史"ReplicaSet 的数量：spec.revisionHistoryLimit

即使像上面那样小心翼翼地控制了 ReplicaSet 的生成数量，随着应用版本的不断增加，Kubernetes 中还是会为同一个 Deployment 保存很多很多不同的 ReplicaSet。

Deployment 对象有一个字段，叫作 spec.revisionHistoryLimit，就是 Kubernetes 为 Deployment 保留的"历史版本"个数。所以，如果把它设置为 0，就再也不能做回滚操作了。

思考：
Kubernetes 项目对 Deployment 的设计，实际上是代替我们完成了对"应用"的抽象，使得我们可以使用这个 Deployment 对象来描述应用，使用 kubectl rollout 命令控制应用的版本。

可是，在实际使用场景中，应用发布的流程往往千差万别，也可能有很多的定制化需求。比如，我的应用可能有会话黏连（session sticky），这就意味着"滚动更新"的时候，哪个 Pod 能下线，是不能随便选择的。

这种场景，光靠 Deployment 自己就很难应对了。对于这种需求，后面的"自定义控制器"，就可以帮我们实现一个功能更加强大的 Deployment Controller。

当然，Kubernetes 项目本身，也提供了另外一种抽象方式，帮我们应对其他一些用 Deployment 无法处理的应用编排场景。这个设计，就是对有状态应用的管理

你听说过金丝雀发布（Canary Deployment）和蓝绿发布（Blue-Green Deployment）吗？你能说出它们是什么意思吗？

实际上，有了 Deployment 的能力之后，你可以非常轻松地用它来实现金丝雀发布、蓝绿发布，以及 A/B 测试等很多应用发布模式。这些问题的答案都在这个 GitHub 库，建议你在课后实践一下。

# 有状态应用
**StatefulSet 控制器**
主要作用

1. 使用 Pod 模板创建 Pod 的时候，对它们进行编号，并且按照编号顺序逐一完成创建工作。而当 StatefulSet 的"控制循环"发现 Pod 的"实际状态"与"期望状态"不一致，需要新建或者删除 Pod 进行"调谐"的时候，它会严格按照这些 Pod 编号的顺序，逐一完成这些操作，可以认为是对 Deployment 的改良。

2. 通过 Headless Service 的方式，StatefulSet 为每个 Pod 创建了一个固定并且稳定的 DNS 记录，来作为它的访问入口。

**有状态应用（Stateful Application）**
实例之间有不对等关系，以及实例对外部数据有依赖关系的应用，就被称为"有状态应用"

情况1： 
分布式应用，它的多个实例之间，往往有依赖关系，比如：主从关系、主备关系。

情况2：
 数据存储类应用(比如redis)，它的多个实例，往往都会在本地磁盘上保存一份数据。而这些实例一旦被杀掉，即便重建出来，实例与数据之间的对应关系也已经丢失，从而导致应用失败。

Deployment 并不足以覆盖所有的应用编排问题

Deployment 对应用做了一个简单化假设:

它认为，一个应用的所有 Pod，是完全一样的。所以，它们互相之间没有顺序，也无所谓运行在哪台宿主机上。需要的时候，Deployment 就可以通过 Pod 模板创建新的 Pod；不需要的时候，Deployment 就可以"杀掉"任意一个 Pod。但在实际的场景中，并不是所有的应用都可以满足这样的要求。

容器技术诞生后，大家很快发现，它用来封装"无状态应用"（Stateless Application），尤其是 Web 服务，非常好用。但是，一旦想要用容器运行"有状态应用"，其困难程度就会直线上升。而且，这个问题解决起来，单纯依靠容器技术本身已经无能为力

### StatefulSet
得益于"控制器模式"的设计思想，Kubernetes 项目很早就在 Deployment 的基础上，扩展出了对"有状态应用"的初步支持。这个编排功能，就是：StatefulSet。

StatefulSet 的设计把真实世界里的应用状态，抽象为2种情况：

1. **拓扑状态**
应用的多个实例之间不是完全对等关系。这些实例必须按顺序启动，比如应用的主节点 A 要先于从节点 B 启动。而如果你把 A 和 B 两个 Pod 删除掉，它们再次被创建出来时也必须严格按照这个顺序才行。并且，新创建出来的 Pod，必须和原来 Pod 的网络标识一样，这样原先的访问者才能使用同样的方法，访问到新 Pod。

2. **存储状态**
应用的多个实例分别绑定了不同的存储数据。对于这些应用实例来说，Pod A 第一次读取到的数据，和隔了十分钟之后再次读取到的数据，应该是同一份，哪怕在此期间 Pod A 被重新创建过。这种情况最典型的例子，就是一个数据库应用的多个存储实例。

StatefulSet 的核心功能，就是**通过某种方式记录这些状态，然后在 Pod 被重新创建时，能够为新 Pod 恢复这些状态**。

### Headless Service
Service 是 Kubernetes 项目中用来将一组 Pod 暴露给外界访问的一种机制。比如，一个 Deployment 有 3 个 Pod，那么就可以定义一个 Service。然后，用户只要能访问这个 Service，它就能访问某个具体的 Pod。

Service访问方式：

方式1：
是以 Service 的 VIP（即CLUSTER-IP）方式。比如：当访问 10.0.23.1 这个 Service 的 IP 地址时，10.0.23.1 其实就是一个 VIP，它会把请求转发到该 Service 所代理的某一个 Pod 上。

方式2：
是以 Service 的 DNS 方式。比如：这时候，只要访问"my-svc.my-namespace.svc.cluster.local"这条 DNS 记录，就可以访问到名叫 my-svc 的 Service 所代理的某一个 Pod。

方式2具体还可以分为两种处理方法：

第一种处理方法：
是 Normal Service。这种情况下，你访问"my-svc.my-namespace.svc.cluster.local"解析到的，正是 my-svc 这个 Service 的 VIP，后面的流程就跟 VIP 方式一致了。

第二种处理方法：
 正是 Headless Service。这种情况下，你访问"my-svc.my-namespace.svc.cluster.local"解析到的，直接就是 my-svc 代理的某一个 Pod 的 IP 地址。可以看到，这里的区别在于，Headless Service 不需要分配一个 VIP，而是可以直接以 DNS 记录的方式解析出被代理 Pod 的 IP 地址。

这样的设计又有什么作用呢？
Headless Service 的定义方式：

一个标准的 Headless Service 对应的 YAML 文件如下：
```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
    - port: 80
      name: web
  clusterIP: None
  selector:
    app: nginx
```
Headless Service，仍是一个标准 Service 的 YAML 文件。只不过，它的 clusterIP 字段的值是：None，即：这个 Service，没有一个 VIP 作为"头"。这也就是 Headless 的含义。所以，这个 Service 被创建后并不会被分配一个 VIP，而是会以 DNS 记录的方式暴露出它所代理的 Pod。

而它所代理的 Pod依然是Label Selector 机制选择出来的：所有携带了 app=nginx 标签的 Pod，都会被这个 Service 代理起来。

然后关键来了：
当你按照这样的方式创建了一个 Headless Service 之后，它所代理的所有 Pod 的 IP 地址，都会被绑定一个这样格式的 DNS 记录，如下所示：

```
<pod-name>.<svc-name>.<namespace>.svc.cluster.local
```

这个 DNS 记录，正是 Kubernetes 项目为 Pod 分配的唯一的"可解析身份"（Resolvable Identity）。
有了这个"可解析身份"，只要你知道了一个 Pod 的名字，以及它对应的 Service 的名字，你就可以非常确定地通过这条 DNS 记录访问到 Pod 的 IP 地址。

那么，StatefulSet 又是如何使用这个 DNS 记录来维持 Pod 的拓扑状态的呢？
编写一个 StatefulSet 的 YAML 文件，如下所示：

\# vim statefulset.yaml
```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  serviceName: "nginx"
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: daocloud.io/library/nginx
          ports:
            - containerPort: 80
              name: web
```
这个 YAML 文件，和前面用到的 nginx-deployment 的唯一区别是多了一个 serviceName=nginx 字段。

这个字段的作用，就是告诉 StatefulSet 控制器，在执行控制循环（Control Loop）的时候，请使用 nginx 这个 Headless Service 来保证 Pod 的"可解析身份"。

当你通过 kubectl create 创建了上面这个 Service 和 StatefulSet 之后，就会看到如下两个对象：
```
\# kubectl create -f svc.yaml

\# kubectl get service nginx
```
```
\# kubectl create -f statefulset.yaml

\# kubectl get statefulset web -o wide
```

这时，如果你手比较快的话，还可以通过 kubectl 的 -w 参数，即：Watch 功能，实时查看 StatefulSet 创建两个有状态实例的过程：

备注：如果手不够快的话，Pod 很快就创建完了。不过，依然可以通过这个 StatefulSet 的 Events 看到这些信息。
```
\# kubectl get pods -w -l app=nginx
```

通过上面这个 Pod 的创建过程，我们看到，StatefulSet 给它所管理的所有 Pod 的名字，进行了编号，编号规则是：-。

而且这些编号都是从 0 开始累加，与 StatefulSet 的每个 Pod 实例一一对应，绝不重复。

更重要的是，这些 Pod 的创建，也是严格按照编号顺序进行的。比如，在 web-0 进入到 Running 状态、并且细分状态（Conditions）成为 Ready 之前，web-1 会一直处于 Pending 状态。

备注：Ready 状态再一次提醒了我们，为 Pod 设置 livenessProbe 和 readinessProbe 的重要性。

当这两个 Pod 都进入了 Running 状态之后，就可以查看到它们各自唯一的"网络身份"了。

进入到容器中查看它们的 hostname：
```
\# kubectl exec web-0 -- sh -c 'hostname'

web-0

\# kubectl exec web-1 -- sh -c 'hostname'

web-1
```

看到，这两个 Pod 的 hostname 与 Pod 名字是一致的，都被分配了对应的编号。接下来，以 DNS 的方式，访问一下这个 Headless Service：
```
\# kubectl run -i --tty --image busybox dns-test --restart=Never --rm /bin/sh 
```
通过这条命令，启动了一个一次性的 Pod
--rm 表示 Pod 退出后就会被删除掉

然后，在这个 Pod 的容器里面，尝试用 nslookup 命令，解析一下 Pod 对应的 Headless Service：
```
\# kubectl run -i --tty --image busybox dns-test --restart=Never --rm /bin/sh

$ nslookup web-0.nginx

Server:   10.0.0.10

Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local

Name:    web-0.nginx

Address 1: 10.244.1.7

$ nslookup web-1.nginx

Server:   10.0.0.10

Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local

Name:    web-1.nginx

Address 1: 10.244.2.7
```
从 nslookup 命令的输出结果中，看到，在访问 web-0.nginx 的时候，最后解析到的，正是 web-0 这个 Pod 的 IP 地址；而当访问 web-1.nginx 的时候，解析到的则是 web-1 的 IP 地址。

这时候，如果在另外一个 Terminal 里把这两个"有状态应用"的 Pod 删掉：
```
\# kubectl delete pod -l app=nginx

pod "web-0" deleted

pod "web-1" deleted
```

再在当前 Terminal 里 Watch 一下这两个 Pod 的状态变化，就会发现一个有趣的现象：
```
\# kubectl get pod -w -l app=nginx
```

看到，当把这两个 Pod 删除之后，Kubernetes 会按照原先编号的顺序，创建出了两个新的 Pod。并且，Kubernetes 依然为它们分配了与原来相同的"网络身份"：web-0.nginx 和 web-1.nginx。

通过这种严格的对应规则，StatefulSet 就保证了 Pod 网络标识的稳定性。

比如，如果 web-0 是一个需要先启动的主节点，web-1 是一个后启动的从节点，那么只要这个 StatefulSet 不被删除，你访问 web-0.nginx 时始终都会落在主节点上，访问 web-1.nginx 时，则始终都会落在从节点上，这个关系绝对不会发生任何变化。

测试：
注意这里的busybox最好用原装的
```
\# kubectl run -i --tty --image busybox dns-test --restart=Never --rm /bin/sh 

/ # ping web-0.nginx
```

看到，这个 StatefulSet 中，这两个新 Pod 的"网络标识"（web-0.nginx 和 web-1.nginx），再次解析到了正确的 IP 地址（比如：web-0 Pod 的 IP 地址 10.244.1.35）。

通过这种方法，k8s 就成功地将 Pod 的拓扑状态（比如：哪个节点先启动，哪个节点后启动），按照 Pod 的"名字 + 编号"的方式固定了下来。此外，k8s 还为每一个 Pod 提供了一个固定并且唯一的访问入口，即：这个 Pod 对应的 DNS 记录。

这些状态，在 StatefulSet 的整个生命周期里都会保持不变，绝不会因为对应 Pod 的删除或者重新创建而失效。

不过尽管 web-0.nginx 这条记录本身不会变，但它解析到的 Pod 的 IP 地址，并不是固定的。对于"有状态应用"实例的访问，你必须使用 DNS 记录或者 hostname 的方式，而绝不应该直接访问这些 Pod 的 IP 地址。

# 部署rook-ceph
官方网站：https://rook.io/

## 准备yaml文件
```
git clone https://github.com/rook/rook.git
```
## 准备镜像
```
docker pull rook/ceph:master
docker pull ceph/ceph:v14.2.1-20190430
```
> 提示，镜像下载问题：
> 下载镜像的时候报错如下：
> \# docker pull ceph/ceph:v14.2.1-20190430
>
> v14.2.1-20190430: Pulling from ceph/ceph
>
> 8ba884070f61: Already exists
>
> 686d771054f0: Pulling fs layer
>
> error pulling image configuration: Get https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/c3/c3c0d6aa89f09d768f65e7c270fe5168ca6d72c6a34b3dbad88362d9880ff4aa/data?verify=1565686016-d%2BAU9ZJ6XlsrFHlCIN%2BShpKOQ%2FE%3D: dial tcp 104.18.124.25:443: i/o timeout
>
> 解决：网络原因，因为是从docker-hub上下载，多下载几次就好了
>

## 部署公共资源
```
cd rook/cluster/examples/kubernetes/ceph/

kubectl apply -f common.yaml
```
## 部署 rook operator
```
cd rook/cluster/examples/kubernetes/ceph/
kubectl apply -f operator.yaml
kubectl -n rook-ceph get pod
```
## 创建rook-ceph集群

Cluster CRD（自定义资源定义）
Now that your operator is running, let’s create your Ceph storage cluster:

cluster.yaml: 
This file contains common settings for a production storage cluster. Requires at least three nodes.

cluster-test.yaml: 
Settings for a test cluster where redundancy is not configured. Requires only a single node.

cluster-minimal.yaml: 
Brings up a cluster with only one ceph-mon and a ceph-mgr so the Ceph dashboard can be used for the remaining cluster configuration.

这里使用的是cluster-test.yaml
```
kubectl apply -f cluster-test.yaml
```

```
 kubectl -n rook-ceph get pod
```
```
kubectl -n rook-ceph get pod | wc -l

18
```
## 部署rook工具箱测试ceph集群

用的镜像还是rook/ceph:master,不用重新下载新的镜像
```
kubectl create -f toolbox.yaml

kubectl -n rook-ceph get pod -l "app=rook-ceph-tools"
```

连接rook-ceph-tools pod
```
[root@centos708 ceph]# kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') /bin/bash
bash: warning: setlocale: LC_CTYPE: cannot change locale (en_US.UTF-8): No such file or directory
bash: warning: setlocale: LC_COLLATE: cannot change locale (en_US.UTF-8): No such file or directory
bash: warning: setlocale: LC_MESSAGES: cannot change locale (en_US.UTF-8): No such file or directory
bash: warning: setlocale: LC_NUMERIC: cannot change locale (en_US.UTF-8): No such file or directory
bash: warning: setlocale: LC_TIME: cannot change locale (en_US.UTF-8): No such file or directory
[root@rook-ceph-tools-86d9c9d647-2688s /]# 
```

这时候就可以使用ceph的各种测试命令了

ceph status

ceph osd status

ceph df

rados df

测试结果如下：
```
[root@rook-ceph-tools-86d9c9d647-2688s /]# ceph status
  cluster:
    id:     6958a5ba-e68a-463f-831d-5f8af6119417
    health: HEALTH_WARN
            OSD count 2 < osd_pool_default_size 3
            mon a is low on available space
 
  services:
    mon: 1 daemons, quorum a (age 10m)
    mgr: a(active, since 9m)
    osd: 2 osds: 2 up (since 8m), 2 in (since 8m)
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   12 GiB used, 3.9 GiB / 16 GiB avail
    pgs:     


[root@rook-ceph-tools-86d9c9d647-2688s /]# ceph osd status
+----+-----------+-------+-------+--------+---------+--------+---------+-----------+
| id |    host   |  used | avail | wr ops | wr data | rd ops | rd data |   state   |
+----+-----------+-------+-------+--------+---------+--------+---------+-----------+
| 0  | centos709 | 6272M | 1905M |    0   |     0   |    0   |     0   | exists,up |
| 1  | centos710 | 6128M | 2049M |    0   |     0   |    0   |     0   | exists,up |
+----+-----------+-------+-------+--------+---------+--------+---------+-----------+

[root@rook-ceph-tools-86d9c9d647-2688s /]# ceph df
RAW STORAGE:
    CLASS     SIZE       AVAIL       USED       RAW USED     %RAW USED 
    hdd       16 GiB     3.9 GiB     12 GiB       12 GiB         75.82 
    TOTAL     16 GiB     3.9 GiB     12 GiB       12 GiB         75.82 
 
POOLS:
    POOL     ID     STORED     OBJECTS     USED     %USED     MAX AVAIL 

[root@rook-ceph-tools-86d9c9d647-2688s /]# rados df
POOL_NAME USED OBJECTS CLONES COPIES MISSING_ON_PRIMARY UNFOUND DEGRADED RD_OPS RD WR_OPS WR USED COMPR UNDER COMPR 

total_objects    0
total_used       12 GiB
total_avail      3.9 GiB
total_space      16 GiB
```
## 删除rook工具箱
```
kubectl -n rook-ceph delete deployment rook-ceph-tools
```

## 部署ceph dashboard
```
kubectl apply -f dashboard-external-https.yaml

service/rook-ceph-mgr-dashboard-external-https created

kubectl -n rook-ceph get service
```
浏览器访问测试：https://192.168.122.107:32367/#/login

用户名：admin

密  码：用如下方式获取
```
 kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo

UDUeQwyOpp
```
访问结果如下：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps2Uh4MK.jpg) 

注：

如果主页出现500错误，不用管它，其他功能是可用的

### 官方关于dashboard的说明：

#### Ceph Dashboard

The dashboard is a very helpful tool to give you an overview of the status of your cluster, including overall health, status of the mon quorum, status of the mgr, osd, and other Ceph daemons, view pools and PG status, show logs for the daemons, and more. Rook makes it simple to enable the dashboard.

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsxIVbe8.jpg) 

##### Enable the Dashboard

The [dashboard](http://docs.ceph.com/docs/mimic/mgr/dashboard/) can be enabled with settings in the cluster CRD. The cluster CRD must have the dashboard enabledsetting set to true. This is the default setting in the example manifests.

 spec:

  dashboard:

   enabled: true

The Rook operator will enable the ceph-mgr dashboard module. A K8s service will be created to expose that port inside the cluster. The ports enabled by Rook will depend on the version of Ceph that is running:

· Luminous: Port 7000 on http

· Mimic and newer: Port 8443 on https

This example shows that port 8443 was configured for Mimic or newer.

kubectl -n rook-ceph get service

NAME             TYPE     CLUSTER-IP    EXTERNAL-IP  PORT***\*(\****S***\*)\****     AGE

rook-ceph-mgr         ClusterIP  10.108.111.192  <none>     9283/TCP     3h

rook-ceph-mgr-dashboard    ClusterIP  10.110.113.240  <none>     8443/TCP     3h

The first service is for reporting the [Prometheus metrics](https://rook.io/docs/rook/v1.0/ceph-monitoring.html), while the latter service is for the dashboard. If you are on a node in the cluster, you will be able to connect to the dashboard by using either the DNS name of the service at https://rook-ceph-mgr-dashboard-https:8443 or by connecting to the cluster IP, in this example at https://10.110.113.240:8443.

##### Credentials

After you connect to the dashboard you will need to login for secure access. Rook creates a default user named adminand generates a secret called rook-ceph-dashboard-admin-password in the namespace where rook is running. To retrieve the generated password, you can run the following:

kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo

#### Configure the Dashboard

The following dashboard configuration settings are supported:

 spec:

  dashboard:

   urlPrefix: /ceph-dashboard

   port: 8443

   ssl: true

· 

urlPrefix If you are accessing the dashboard via a reverse proxy, you may wish to serve it under a URL prefix. To get the dashboard to use hyperlinks that include your prefix, you can set the urlPrefix setting.

· 

· 

port The port that the dashboard is served on may be changed from the default using the port setting. The corresponding K8s service exposing the port will automatically be updated.

· 

· 

ssl The dashboard may be served without SSL (useful for when you deploy the dashboard behind a proxy already served using SSL) by setting the ssl option to be false. Note that the ssl setting will be ignored in Luminous as well as Mimic 13.2.2 or older where it is not supported

· 

#### Viewing the Dashboard External to the Cluster

Commonly you will want to view the dashboard from outside the cluster. For example, on a development machine with the cluster running inside minikube you will want to access the dashboard from the host.

There are several ways to expose a service that will depend on the environment you are running in. You can use an [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress/) or [other methods](#publishing-services-service-types) for exposing services such as NodePort, LoadBalancer, or ExternalIPs.

##### Node Port

The simplest way to expose the service in minikube or similar environment is using the NodePort to open a port on the VM that can be accessed by the host. To create a service with the NodePort, save this yaml as dashboard-external-https.yaml. (For Luminous you will need to set the port and targetPort to 7000 and connect via http.)

apiVersion: v1kind: Servicemetadata:

 name: rook-ceph-mgr-dashboard-external-https

 namespace: rook-ceph

 labels:

  app: rook-ceph-mgr

  rook_cluster: rook-cephspec:

 ports:

 \- name: dashboard

  port: 8443

  protocol: TCP

  targetPort: 8443

 selector:

  app: rook-ceph-mgr

  rook_cluster: rook-ceph

 sessionAffinity: None

 type: NodePort

Now create the service:

$ kubectl create -f dashboard-external-https.yaml

You will see the new service rook-ceph-mgr-dashboard-external-https created:

$ kubectl -n rook-ceph get service

NAME                   TYPE     CLUSTER-IP    EXTERNAL-IP  PORT***\*(\****S***\*)\****     AGE

rook-ceph-mgr              ClusterIP  10.108.111.192  <none>     9283/TCP     4h

rook-ceph-mgr-dashboard         ClusterIP  10.110.113.240  <none>     8443/TCP     4h

rook-ceph-mgr-dashboard-external-https  NodePort   10.101.209.6   <none>     8443:31176/TCP  4h

In this example, port 31176 will be opened to expose port 8443 from the ceph-mgr pod. Find the ip address of the VM. If using minikube, you can run minikube ip to find the ip address. Now you can enter the URL in your browser such as https://192.168.99.110:31176 and the dashboard will appear.

##### Ingress Controller

If you have a cluster with an [nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/) and a Certificate Manager (e.g. [cert-manager](https://cert-manager.readthedocs.io/)) then you can create an Ingress like the one below. This example achieves four things:

\1. Exposes the dashboard on the Internet (using an reverse proxy)

\2. Issues an valid TLS Certificate for the specified domain name (using [ACME](https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment))

\3. Tells the reverse proxy that the dashboard itself uses HTTPS

\4. Tells the reverse proxy that the dashboard itself does not have a valid certificate (it is self-signed)

```
apiVersion: extensions/v1beta1kind: Ingressmetadata:

 name: rook-ceph-mgr-dashboard

 namespace: rook-ceph

 annotations:

  kubernetes.io/ingress.class: "nginx"

  kubernetes.io/tls-acme: "true"

  nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"

  nginx.ingress.kubernetes.io/server-snippet: |

   proxy_ssl_verify off;spec:

 tls:

  \- hosts:

   \- rook-ceph.example.com

   secretName: rook-ceph.example.com

 rules:

 \- host: rook-ceph.example.com

  http:

   paths:

   \- path: /

​    backend:

​     serviceName: rook-ceph-mgr-dashboard

​     servicePort: https-dashboard
```

Customise the Ingress resource to match your cluster. Replace the example domain name rook-ceph.example.comwith a domain name that will resolve to your Ingress Controller (creating the DNS entry if required).

Now create the Ingress:

$ kubectl create -f dashboard-ingress-https.yaml

You will see the new Ingress rook-ceph-mgr-dashboard created:

$ kubectl -n rook-ceph get ingress

NAME            HOSTS            ADDRESS  PORTS   AGE

rook-ceph-mgr-dashboard  rook-ceph.example.com    80, 443  5m

And the new Secret for the TLS certificate:

$ kubectl -n rook-ceph get secret rook-ceph.example.com

NAME            TYPE         DATA    AGE

rook-ceph.example.com    kubernetes.io/tls  2     4m

You can now browse to https://rook-ceph.example.com/ to log into the dashboard.

 

## 使用rook-ceph提供的存储空间部署应用

下面是以wordpress和mysql两个应用镜像为例进行测试

### 准备镜像

准备如下两个镜像

```
[root@node1 /]# docker images | grep -E 'word|mysql'
mysql      5.6    			732765f8c7d2     28 hours ago     257MB
wordpress    4.6.1-apache     ee397259d4e5     2 years ago     420MB
```



### 创建存储池及存储类

注：使用存储类可以自动创建pv

```
# cd rook/cluster/examples/kubernetes/ceph/flex

\# cat storageclass-test.yaml

\# kubectl create -f storageclass-test.yaml
```



### 准备mysql和wordpress的yaml文件

[root@master kubernetes]# cat mysql.yaml

```
---
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  labels:
    app: wordpress
spec:
  storageClassName: rook-ceph-block
  accessModes:
    - ReadWriteOnly
  resources:
    requests:
      storage: 5Gi

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
    tier: mysql
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:5.6
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: changeme
          ports:
            - containerPort: 3306
              name: mysql
          volumeMounts:
            - mountPath: /var/lib/mysql
              name: mysql-presistent-storage
      volumes:
        - name: mysql-presistent-storage
          persistentVolumeClaim:
            claimName: mysql-pv-claim
```

 

[root@master kubernetes]# cat wordpress.yaml

```
---
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30062
  selector:
    app: wordpress
    tier: frontend
  type: NodePort

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pv-claim
  labels:
    app: wordpress
spec:
  storageClassName: rook-ceph-block
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
    tier: frontend
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: frontend
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      containers:
        - name: wordpress
          image: wordpress:4.6.1-apache
          env:
            - name: WORDPRESS_DB_HOST
              value: wordpress-mysql
            - name: WORDPRESS_DB_PASSWORD
              value: changeme
          ports:
            - containerPort: 80
              name: wordpress
          volumeMounts:
            - mountPath: /var/www/html
              name: wordpress-presistent-storage
      volumes:
        - name: wordpress-presistent-storage
          persistentVolumeClaim:
            claimName: wp-pv-claim
```

 

```
 \# kubectl apply -f mysql.yaml

 \# kubectl apply -f wordpress.yaml

 \# kubectl get pvc

\# kubectl get svc wordpress

NAME     TYPE    CLUSTER-IP   EXTERNAL-IP  PORT(S)     AGE

wordpress  NodePort  10.96.121.18  <none>     80:30062/TCP  18m
```

 

### 浏览器测试

结果如下：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpshm8TFv.jpg) 

 

### 清除环境

测试完成之后可以使用如下操作清除环境

```
# kubectl delete -f wordpress.yaml

\# kubectl delete -f mysql.yaml

\# kubectl delete -n rook-ceph cephblockpools.ceph.rook.io replicapool

\# kubectl delete storageclass rook-ceph-block
```



### 官方关于CephBlockPool中Block Devices的说明

Ceph can provide raw block device volumes to pods. Each example below sets up a storage class which can then be used to provision a block device in kubernetes pods. The storage class is defined with [a pool](http://docs.ceph.com/docs/nautilus/rados/operations/pools/) which defines the level of data redundancy in ceph:

· storageclass.yaml: This example illustrates replication of 3 for production scenarios and requires at least three nodes. Your data is replicated on three different kubernetes worker nodes and intermittent or long-lasting single node failures will not result in data unavailability or loss.

· storageclass-ec.yaml: Configures erasure coding for data durability rather than replication. [Ceph’s erasure coding](http://docs.ceph.com/docs/nautilus/rados/operations/erasure-code/)is more efficient than replication so you can get high reliability without the 3x replication cost of the preceding example (but at the cost of higher computational encoding and decoding costs on the worker nodes). Erasure coding requires at least three nodes. See the [Erasure coding](#erasure-coded) documentation for more details.

· storageclass-test.yaml: Replication of 1 for test scenarios and it requires only a single node. Do not use this for applications that store valuable data or have high-availability storage requirements, since a single node failure can result in data loss.

## rook-ceph清理

### 删除块和文件工件

首先，您需要清理在Rook集群之上创建的资源。

这些命令将清除[块](#teardown)和[文件](#teardown)演练中的资源（卸载卷，删除卷声明等）。如果您没有完成演练的这些部分，则可以跳过这些说明：

```
kubectl delete -f ../wordpress.yaml

kubectl delete -f ../mysql.yaml

kubectl delete -n rook-ceph cephblockpool replicapool

kubectl delete storageclass rook-ceph-block

kubectl delete -f kube-registry.yaml
```



### 删除CephCluster CRD

清理完这些块和文件资源后，您可以删除您的Rook群集。***\*在删除Rook操作符和代理之前删除\****这一点很重要，***\*否则可能无法正确清理资源\****。

kubectl -n rook-ceph delete cephcluster rook-ceph

在继续执行下一步之前，请验证是否已删除群集CRD。

kubectl -n rook-ceph get cephcluster

### 删除运营商和相关资源

这将开始Rook Ceph操作员的过程以及正在清理的所有其他资源。这包括相关资源，例如代理和发现守护程序集，具有以下命令：

kubectl delete -f operator.yaml

kubectl delete -f common.yaml

### 删除主机上的数据

重要信息：最后的清理步骤需要删除群集中每个主机上的文件。dataDirHostPath需要删除群集CRD中指定的属性下的所有文件。否则，启动新群集时将保留不一致状态。

连接到每台机器并删除/var/lib/rook，或者指定的路径dataDirHostPath。

将来，当我们构建K8s本地存储功能时，此步骤将不再必要。

如果您修改了演示设置，则需要对设备，主机路径等进行额外的清理。

可以使用以下方法将Rook for osds使用的节点上的磁盘重置为可用状态：

**#!/usr/bin/env bash**DISK***\*=\****"/dev/sdb"**# Zap the disk to a fresh, usable state (zap-all is important, b/c MBR has to be clean)# You will have to run this step for all disks.**

sgdisk --zap-all $DISK**# These steps only have to be run once on each node# If rook sets up osds using ceph-volume, teardown leaves some devices mapped that lock the disks.**ls /dev/mapper/ceph-***\**\**** | xargs -I% -- dmsetup remove %**# ceph-volume setup can leave ceph- directories in /dev (unnecessary clutter)**

rm -rf /dev/ceph-***\**\****

### 故障排除

如果清理说明没有按上述顺序执行，或者您在清理群集时遇到困难，可以尝试以下几种方法。

清理群集的最常见问题是rook-ceph命名空间或群集CRD在terminating状态中无限期保留。在删除所有资源之前，无法删除命名空间，因此请查看哪些资源正在等待终止。

看看豆荚：

kubectl -n rook-ceph get pod

如果pod仍在终止，您将需要等待或尝试强制终止它（kubectl delete pod <name>）。

现在看一下集群CRD：

kubectl -n rook-ceph get cephcluster

如果即使您之前已执行删除命令，群集CRD仍然存在，请参阅有关删除终结器的下一部分。

#### 删除群集CRD终结器

创建群集CRD时，Rook运算符会自动添加[终结](#finalizers)器。终结器将允许操作员确保在删除集群CRD之前，将清除所有块和文件安装。如果没有适当的清理，消耗存储的pod将无限期挂起，直到系统重新启动。

在清洁底座后，操作员负责卸下终结器。如果由于某种原因操作员无法移除终结器（即操作员不再运行），您可以使用以下命令手动删除终结器：

kubectl -n rook-ceph patch cephclusters.ceph.rook.io rook-ceph -p '{"metadata":{"finalizers": []}}' --type=merge

在几秒钟内，您应该看到群集CRD已被删除，并且将不再阻止其他清理，例如删除rook-ceph命名空间。

 

 

# 深入理解StatefulSet之存储状态

**StatefulSet 对存储状态的管理机制**

这个机制主要使用的是一个叫作` Persistent Volume Claim` 的功能。 

问题： 
要在一个 Pod 里声明 Volume，只要在 Pod 里加上 spec.volumes 字段即可。然后，就可以在这个字段里定义一个具体类型的 Volume 了，比如：hostPath。

但是作为一个应用开发者，可能对持久化存储项目（比如 Ceph、GlusterFS 等）一窍不通，也不知道公司的 Kubernetes 集群里到底是怎么搭建出来的，也自然不会编写它们对应的 Volume 定义文件。

所谓"术业有专攻"，这些关于 Volume 的管理和远程持久化存储的知识，不仅超越了开发者的知识储备，还会有暴露公司基础设施秘密的风险。

例子：
一个声明了 Ceph RBD 类型 Volume 的 Pod：
```
apiVersion: v1
kind: Pod
metadata:
  name: rbd
spec:
  containers:
    - name: rbd-rw
      image: kubernets/pause
      volumeMounts:
        - mountPath: /mnt/rbd
          name: rbdpd
  volumes:
    - name: rbdpd
      rbd:
        image: foo
        monitors:
          - '10.16.154.78:6789'
          - '10.16.154.82:6789'
          - '10.16.154.83:6789'
        pool: kube
        fsType: ext4
        readOnly: true
        user: admin
        keyring: /etc/ceph/keyring
        imageformat: "2"
        imagefeature: "keyring"
```

1. 如果不懂得 Ceph RBD 的使用方法，那么这个 Pod 里 Volumes 字段，你十有八九也完全看不懂。

2. 这个 Ceph RBD 对应的存储服务器的地址、用户名、授权文件的位置，也都被轻易地暴露给了全公司的所有开发人员，这是一个典型的信息被"过度暴露"的例子。

解决：

k8s引入了一组叫作 `Persistent Volume Claim`（PVC）和 `Persistent Volume`（PV）的 API 对象，大大降低了用户声明和使用持久化 Volume 的门槛。

有了 PVC 之后，一个开发人员想要使用一个 Volume，只要简单的两步即可。

第一步：定义一个 PVC，声明想要的 Volume 的属性：

PVC 对象里，不需要任何关于 Volume 细节的字段，只有描述性的属性和定义。比如，`storage: 1Gi`，表示想要的 Volume 大小至少是 1 GiB；`accessModes: ReadWriteOnce`，表示这个 Volume 的挂载方式是可读写，并且只能被挂载在一个节点上而非被多个节点共享。

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

> 备注：关于哪种类型的 Volume 支持哪种类型的 AccessMode，你可以查看 Kubernetes 项目官方文档中的详细列表。
>

第二步：在应用的 Pod 中，声明使用这个 PVC

Pod 的 Volumes 定义中，只需要声明它的类型是 persistentVolumeClaim，然后指定 PVC 的名字，完全不必关心 Volume 本身的定义。

  接着只要创建这个 PVC 对象，k8s就会自动为它绑定一个符合条件的 Volume。

```
apiVersion: v1
kind: Pod
metadata:
  name: pv-pod
spec:
  containers:
    - name: pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: pv-storage
  volumes:
    - name: pv-storage
      persistentVolumeClaim:
        claimName: pv-claim


```

这些符合条件的 Volume 从哪里来？

来自于由运维人员维护的 PV（Persistent Volume）对象。

看一个常见的 PV 对象的 YAML 文件：

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-colume
  labels:
    type: local
spec:
  capacity:
    storage: 10Gi
  rbd:
    image: foo
    monitors:
      - '10.16.154.78:6789'
      - '10.16.154.82:6789'
      - '10.16.154.83:6789'
    pool: kube
    fsType: ext4
    readOnly: true
    user: admin
    keyring: /etc/ceph/keyring
    imageformat: "2"
    imagefeatures: "keyring"
```

这个 PV 对象的 spec.rbd 字段，正是前面的 Ceph RBD Volume 的详细定义。而且，它还声明了这个 PV 的容量是 10 GiB。这样k8s 就会为刚创建的 PVC 对象绑定这个 PV。

所以，Kubernetes 中 PVC 和 PV 的设计，实际上类似于"接口"和"实现"的思想。开发者只要知道并会使用"接口"，即：PVC；而运维人员则负责给"接口"绑定具体的实现，即：PV。

这种解耦，就避免了因为向开发者暴露过多的存储系统细节而带来的隐患。此外，这种职责的分离，也意味着出现事故时可以更容易定位问题和明确责任，从而避免"扯皮"现象的出现。

而 PVC、PV 的设计，也使得 StatefulSet 对存储状态的管理成为了可能。还是以上面用到的 StatefulSet 为例：

```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx
  serviceName: "nginx"
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
              name: web
          volumeMounts:
            - mountPath: /usr/share/nginx/html
              name: www
  volumeClaimTemplates:
    - metadata:
        name: www
      spec:
        accessModes:
          - ReadWriteOnly
        resources:
          requests:
            storage: 1Gi
```

这次为这个 StatefulSet 额外添加了一个 volumeClaimTemplates 字段。从名字就可以看出来，它跟 Deployment 里 Pod 模板（PodTemplate）的作用类似。也就是说凡是被这个 StatefulSet 管理的 Pod，都会声明一个对应的 PVC；而这个 PVC 的定义，就来自于 volumeClaimTemplates 这个模板字段。更重要的是，这个 PVC 的名字，会被分配一个与这个 Pod 完全一致的编号。 

这个自动创建的 PVC，与 PV 绑定成功后，就会进入 Bound 状态，这就意味着这个 Pod 可以挂载并使用这个 PV 了。

一个结论：
PVC 其实就是一种特殊的 Volume。只不过一个 PVC 具体是什么类型的 Volume，要在跟某个 PV 绑定之后才知道。关于 PV、PVC 更详细的知识，会在容器存储部分做进一步解读。

 **PVC 与 PV 的绑定得以实现的前提**
运维人员已经在系统里创建好了符合条件的 PV（比如在前面用到的 pv-volume）；或者，你的 Kubernetes 集群运行在公有云上，这样 Kubernetes 就会通过 Dynamic Provisioning 的方式，自动为你创建与 PVC 匹配的 PV。

所以，在使用 kubectl create 创建了 StatefulSet 之后，就会看到 Kubernetes 集群里出现了两个 PVC：

```
# kubectl create -f statefulset.yaml

\# kubectl get pvc -l app=nginx

NAME     STATUS   VOLUME                   CAPACITY  ACCESSMODES  AGE

www-web-0  Bound   pvc-15c268c7-b507-11e6-932f-42010a800002  1Gi     RWO      48s

www-web-1  Bound   pvc-15c79307-b507-11e6-932f-42010a800002  1Gi     RWO      48s
```
这些 PVC，都以"<PVC 名字 >-<StatefulSet 名字 >-< 编号 >"的方式命名，并且处于 Bound 状态。

这个 StatefulSet 创建出来的所有 Pod，都会声明使用编号的 PVC。比如，在名叫 web-0 的 Pod 的 volumes 字段，它会声明使用名叫 www-web-0 的 PVC，从而挂载到这个 PVC 所绑定的 PV。

所以，就可以使用如下所示的指令，在 Pod 的 Volume 目录里写入一个文件，来验证一下上述 Volume 的分配情况：

```
\# for i in 0 1; do kubectl exec web-$i -- sh -c 'echo hello $(hostname) > /usr/share/nginx/html/index.html'; done
```

如上所示，通过 kubectl exec 指令，我们在每个 Pod 的 Volume 目录里，写入了一个 index.html 文件。这个文件的内容，正是 Pod 的 hostname。比如，我们在 web-0 的 index.html 里写入的内容就是 "hello web-0"。

此时，如果你在这个 Pod 容器里访问"http://localhost"，你实际访问到的就是 Pod 里 Nginx 服务器进程，而它会为你返回 /usr/share/nginx/html/index.html 里的内容。

这个操作的执行方法：

```
# for i in 0 1; do kubectl exec -it web-$i -- curl localhost; done

hello web-0
hello web-1
```

关键：如果使用 kubectl delete 命令删除这两个 Pod，这些 Volume 里的文件会不会丢失呢？

```
# kubectl delete pod -l app=nginx

pod "web-0" deleted

pod "web-1" deleted
```

可以看到，正如前面介绍的，在被删除之后，这两个 Pod 会被按照编号的顺序被重新创建出来。

这时在被重新创建出来的 Pod 容器里访问 http://localhost

```
# kubectl exec -it web-0 -- curl localhost

hello web-0
```

发现，这个请求依然会返回：hello web-0。也就是原先与名叫 web-0 的 Pod 绑定的 PV，在这个 Pod 被重新创建之后，依然同新的名叫 web-0 的 Pod 绑定在了一起。对于 Pod web-1 来说，也是完全一样的情况。

这是怎么做到的呢？
分析一下 StatefulSet 控制器恢复这个 Pod 的过程，就可以很容易理解了。
首先，当你把一个 Pod，比如 web-0，删除之后，这个 Pod 对应的 PVC 和 PV，并不会被删除，而这个 Volume 里已经写入的数据，也依然会保存在远程存储服务里（比如，我们在这个例子里用到的 Ceph 服务器）。

此时，StatefulSet 控制器发现，一个名叫 web-0 的 Pod 消失了。所以，控制器就会重新创建一个新的、名字还是叫作 web-0 的 Pod 来，"纠正"这个不一致的情况。

需要注意的是，在这个新的 Pod 对象的定义里，它声明使用的 PVC 的名字，还是叫作：www-web-0。这个 PVC 的定义，还是来自于 PVC 模板（volumeClaimTemplates），这是 StatefulSet 创建 Pod 的标准流程。

所以，在这个新的 web-0 Pod 被创建出来之后，Kubernetes 为它查找名叫 www-web-0 的 PVC 时，就会直接找到旧 Pod 遗留下来的同名的 PVC，进而找到跟这个 PVC 绑定在一起的 PV。

这样，新的 Pod 就可以挂载到旧 Pod 对应的那个 Volume，并且获取到保存在 Volume 里的数据。

通过这种方式，Kubernetes 的 StatefulSet 就实现了对应用存储状态的管理。

看到这里，你是不是已经大致理解了 StatefulSet 的工作原理呢？现在，我再为你详细梳理一下吧。

首先，`StatefulSet 的控制器直接管理的是 Pod`。这是因为，StatefulSet 里的不同 Pod 实例，不再像 ReplicaSet 中那样都是完全一样的，而是有了细微区别的。比如，每个 Pod 的 hostname、名字等都是不同的、携带了编号的。而 StatefulSet 区分这些实例的方式，就是通过在 Pod 的名字里加上事先约定好的编号。

其次，Kubernetes 通过 `Headless Service`，为这些有编号的 Pod，在 DNS 服务器中生成带有同样编号的 DNS 记录。只要 StatefulSet 能够保证这些 Pod 名字里的编号不变，那么 Service 里类似于 web-0.nginx.default.svc.cluster.local 这样的 DNS 记录也就不会变，而这条记录解析出来的 Pod 的 IP 地址，则会随着后端 Pod 的删除和再创建而自动更新。这当然是 Service 机制本身的能力，不需要 StatefulSet 操心。

最后，StatefulSet 还为每一个 Pod 分配并创建一个同样编号的 PVC。这样，Kubernetes 就可以通过 Persistent Volume 机制为这个 PVC 绑定上对应的 PV，从而保证了每一个 Pod 都拥有一个独立的 Volume。

在这种情况下，即使 Pod 被删除，它所对应的 PVC 和 PV 依然会保留下来。所以当这个 Pod 被重新创建出来之后，Kubernetes 会为它找到同样编号的 PVC，挂载这个 PVC 对应的 Volume，从而获取到以前保存在 Volume 里的数据。

这么一看，原本非常复杂的 StatefulSet，是不是也很容易理解了呢？

总结

详细介绍了 StatefulSet 处理存储状态的方法。以此为基础梳理了 StatefulSet 控制器的工作原理。

### StatefulSet 的设计思想

StatefulSet 其实就是一种特殊的 Deployment，而其独特之处在于，它的`每个 Pod 都被编号了`。而且，这个编号会体现在 Pod 的名字和 hostname 等标识信息上，这不仅代表了 Pod 的创建顺序，也是 Pod 的重要网络标识（即：在整个集群里唯一的、可被的访问身份）。

有了这个编号后，StatefulSet 就使用 Kubernetes 里的两个标准功能：`Headless Service` 和 `PV/PVC`，实现了对 Pod 的拓扑状态和存储状态的维护。

实际上StatefulSet 可以说是 Kubernetes 中作业编排的"集大成者"。因为，几乎每一种 Kubernetes 的编排功能，都可以在编写 StatefulSet 的 YAML 文件时被用到。

思考

在实际场景中，有一些分布式应用的集群是这么工作的：当一个新节点加入到集群时，或者老节点被迁移后重建时，这个节点可以从主节点或者其他从节点那里同步到自己所需要的数据。

在这种情况下，你认为是否还有必要将这个节点 Pod 与它的 PV 进行一对一绑定呢？（提示：这个问题的答案根据不同的项目是不同的。关键在于，重建后的节点进行数据恢复和同步的时候，是不是一定需要原先它写在本地磁盘里的数据）

# 落实STATEFULSET完整流程

**使用 StatefulSet 将mysql的集群搭建过程"容器化"**

部署一个 MySQL 集群，相比于 Etcd、Cassandra 等"原生"就考虑了分布式需求的项目，MySQL 以及很多其他的数据库项目，在分布式集群的搭建上并不友好，甚至有点"原始"。

确保 Kubernetes 集群可用，并且网络插件和存储插件都能正常运行。

首先，描述一下要部署的"有状态应用"：

  是一个"主从复制"（Maser-Slave Replication）的 MySQL 集群；

  有 1 个主节点（Master）；

  有多个从节点（Slave）；

  从节点需要能水平扩展；

  所有的写操作，只能在主节点上执行；

  读操作可以在所有节点上执行。

这是一个非常典型的主从模式的 MySQL 集群。可以把上面描述的"有状态应用"的需求，通过一张图来表示。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsbUB67S.jpg) 

常规环境里，部署一个主从模式的 MySQL 集群的主要难点在于：如何让从节点能够拥有主节点的数据，即：如何配置主（Master）从（Slave）节点的复制与同步。

所以，在安装好 MySQL 的 Master 节点之后，需要做的第一步工作是通过 XtraBackup 将 Master 节点的数据备份到指定目录。

注：XtraBackup 是业界主要使用的开源 MySQL 备份和恢复工具。

这一步会自动在目标目录里生成一个备份信息文件，名叫：xtrabackup_binlog_info。这个文件一般会包含如下两个信息：
```
# cat xtrabackup_binlog_info

TheMaster-bin.000001   481
```
这两个信息会在接下来配置 Slave 节点的时候用到。

第二步：配置 Slave 节点。Slave 节点在第一次启动前，需要先把 Master 节点的备份数据，连同备份信息文件，一起拷贝到自己的数据目录（/var/lib/mysql）下。然后，执行 SQL：

```
TheSlave|mysql> CHANGE MASTER TO

​        MASTER_HOST='$masterip',

​        MASTER_USER='xxx',

​        MASTER_PASSWORD='xxx',

​        MASTER_LOG_FILE='TheMaster-bin.000001',

​        MASTER_LOG_POS=481;
```

其中，MASTER_LOG_FILE 和 MASTER_LOG_POS，就是该备份对应的二进制日志（Binary Log）文件的名称和开始的位置（偏移量），也正是 xtrabackup_binlog_info 文件里的那两部分内容（即：TheMaster-bin.000001 和 481）。

第三步，启动 Slave 节点：

```
TheSlave|mysql> START SLAVE;
```

这样Slave 节点就启动了。它会使用备份信息文件中的二进制日志文件和偏移量，与主节点进行数据同步。

第四步，在这个集群中添加更多的 Slave 节点。

注意：新添加的 Slave 节点的备份数据，来自于已经存在的 Slave 节点。

所以，在这一步，需要将 Slave 节点的数据备份在指定目录。而这个备份操作会自动生成另一种备份信息文件，名叫：xtrabackup_slave_info。同样地，这个文件也包含了 MASTER_LOG_FILE 和 MASTER_LOG_POS 两个字段。

然后，就可以执行跟前面一样的"CHANGE MASTER TO"和"START SLAVE" 指令，来初始化并启动这个新的 Slave 节点了。

通过上面的叙述，不难看到，将部署 MySQL 集群的流程迁移到 Kubernetes 项目上，需要能够"容器化"地解决下面的"三座大山"：

1. Master 节点和 Slave 节点需要有不同的配置文件（即：不同的 my.cnf）；
2. Master 节点和 Salve 节点需要能够传输备份信息文件；
3. 在 Slave 节点第一次启动之前，需要执行一些初始化 SQL 操作；

而由于 MySQL 本身同时拥有拓扑状态（主从节点的区别）和存储状态（MySQL 保存在本地的数据），自然要通过 StatefulSet 来解决这"三座大山"的问题。

其中，第一：Master 节点和 Slave 节点需要有不同的配置文件"，很容易处理：只需要给主从节点分别准备两份不同的 MySQL 配置文件，然后根据 Pod 的序号（Index）挂载进去即可。

正如在前面介绍的，这样的配置文件信息，应该保存在 ConfigMap 里供 Pod 使用。它的定义如下：
```
apiVersion: v1

kind: ConfigMap

metadata:

 name: mysql

 labels:

  app: mysql

data:

 master.cnf: |

  \# 主节点 MySQL 的配置文件

  [mysqld]

  log-bin

 slave.cnf: |

  \# 从节点 MySQL 的配置文件

  [mysqld]

  super-read-only
```
在这里，定义了 master.cnf 和 slave.cnf 两个 MySQL 的配置文件。

master.cnf 开启了 log-bin，即：使用二进制日志文件的方式进行主从复制，这是一个标准的设置。

slave.cnf 的开启了 super-read-only，代表的是从节点会拒绝除了主节点的数据同步操作之外的所有写操作，即：它对用户是只读的。

而上述 ConfigMap 定义里的 data 部分，是 Key-Value 格式的。比如，master.cnf 就是这份配置数据的 Key，而"|"后面的内容，就是这份配置数据的 Value。这份数据将来挂载进 Master 节点对应的 Pod 后，就会在 Volume 目录里生成一个叫作 master.cnf 的文件。

接下来，需要创建两个 Service 来供 StatefulSet 以及用户使用。这两个 Service 的定义如下：
```
apiVersion: v1

kind: Service

metadata:

 name: mysql

 labels:

  app: mysql

spec:

 ports:

 \- name: mysql

  port: 3306

 clusterIP: None

 selector:

  app: mysql

\---

apiVersion: v1

kind: Service

metadata:

 name: mysql-read

 labels:

  app: mysql

spec:

 ports:

 \- name: mysql

  port: 3306

 selector:

  app: mysql
```
这两个 Service 都代理了所有携带 app=mysql 标签的 Pod，也就是所有的 MySQL Pod。端口映射都是用 Service 的 3306 端口对应 Pod 的 3306 端口。

不同的是，第一个名叫"mysql"的 Service 是一个 Headless Service（即：clusterIP= None）。所以它的作用，是通过为 Pod 分配 DNS 记录来固定它的拓扑状态，比如"mysql-0.mysql"和"mysql-1.mysql"这样的 DNS 名字。其中，编号为 0 的节点就是我们的主节点。

而第二个名叫"mysql-read"的 Service，则是一个常规的 Service。

并且我们规定，所有用户的读请求，都必须访问第二个 Service 被自动分配的 DNS 记录，即："mysql-read"（当然，也可以访问这个 Service 的 VIP）。这样，读请求就可以被转发到任意一个 MySQL 的主节点或者从节点上。

备注：Kubernetes 中的所有 Service、Pod 对象，都会被自动分配同名的 DNS 记录。具体细节，我会在后面 Service 部分做重点讲解。

而所有用户的写请求，则必须直接以 DNS 记录的方式访问到 MySQL 的主节点，也就是："mysql-0.mysql"这条 DNS 记录。

接下来再解决"第二座大山：Master 节点和 Salve 节点需要能够传输备份文件"的问题。

翻越这座大山的思路，比较推荐的做法是：先搭建框架，再完善细节。其中，Pod 部分如何定义，是完善细节时的重点。

所以首先，先为 StatefulSet 对象规划一个大致的框架，如下图：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsPrjtAg.jpg) 

在这一步，先为 StatefulSet 定义一些通用的字段。
比如：selector 表示，这个 StatefulSet 要管理的 Pod 必须携带 app=mysql 标签；它声明要使用的 Headless Service 的名字是：mysql。

这个 StatefulSet 的 replicas 值是 3，表示它定义的 MySQL 集群有三个节点：一个 Master 节点，两个 Slave 节点。

可以看到，StatefulSet 管理的"有状态应用"的多个实例，也都是通过同一份 Pod 模板创建出来的，使用的是同一个 Docker 镜像。这也就意味着：如果你的应用要求不同节点的镜像不一样，那就不能再使用 StatefulSet 了。对于这种情况，应该考虑我后面会讲解到的 Operator。

除了这些基本的字段外，作为一个有存储状态的 MySQL 集群，StatefulSet 还需要管理存储状态。所以，我们需要通过 volumeClaimTemplate（PVC 模板）来为每个 Pod 定义 PVC。比如，这个 PVC 模板的 resources.requests.strorage 指定了存储的大小为 10 GiB；ReadWriteOnce 指定了该存储的属性为可读写，并且一个 PV 只允许挂载在一个宿主机上。将来，这个 PV 对应的的 Volume 就会充当 MySQL Pod 的存储数据目录。

然后来重点设计一下这个 StatefulSet 的 Pod 模板，也就是 template 字段。

由于 StatefulSet 管理的 Pod 都来自于同一个镜像，这就要求我们在编写 Pod 时，一定要保持清醒，用"人格分裂"的方式进行思考：

如果这个 Pod 是 Master 节点，我们要怎么做；

如果这个 Pod 是 Slave 节点，我们又要怎么做。

想清楚这两个问题，就可以按照 Pod 的启动过程来一步步定义它们了。

第一步：从 ConfigMap 中，获取 MySQL 的 Pod 对应的配置文件。

为此，需要进行一个初始化操作，根据节点的角色是 Master 还是 Slave 节点，为 Pod 分配对应的配置文件。此外，MySQL 还要求集群里的每个节点都有一个唯一的 ID 文件，名叫 server-id.cnf。

而根据已经掌握的 Pod 知识，这些初始化操作显然适合通过 InitContainer 来完成。所以，首先定义了一个 InitContainer，如下所示：
```
   \# template.spec
   initContainers:
   \- name: init-mysql
​    image: mysql:5.7
​    command:
​    \- bash
​    \- "-c"
​    \- |
​     set -ex
​     \# 从 Pod 的序号，生成 server-id
​     [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
​     ordinal=${BASH_REMATCH[1]}
​     echo [mysqld] > /mnt/conf.d/server-id.cnf
​     \# 由于 server-id=0 有特殊含义，我们给 ID 加一个 100 来避开它
​     echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf
​     \# 如果 Pod 序号是 0，说明它是 Master 节点，从 ConfigMap 里把 Master 的配置文件拷贝到 /mnt/conf.d/ 目录；
​     \# 否则，拷贝 Slave 的配置文件
​     if [[ $ordinal -eq 0 ]]; then
​      cp /mnt/config-map/master.cnf /mnt/conf.d/
​     else
​      cp /mnt/config-map/slave.cnf /mnt/conf.d/
​     fi
​    volumeMounts:
​    \- name: conf
​     mountPath: /mnt/conf.d
​    \- name: config-map
​     mountPath: /mnt/config-map
```
在这个名叫 init-mysql 的 InitContainer 的配置中，它从 Pod 的 hostname 里，读取到了 Pod 的序号，以此作为 MySQL 节点的 server-id。

然后，init-mysql 通过这个序号，判断当前 Pod 到底是 Master 节点（即：序号为 0）还是 Slave 节点（即：序号不为 0），从而把对应的配置文件从 /mnt/config-map 目录拷贝到 /mnt/conf.d/ 目录下。

其中，文件拷贝的源目录 /mnt/config-map，正是 ConfigMap 在这个 Pod 的 Volume，如下所示：
```
   \# template.spec

   volumes:

   \- name: conf

​    emptyDir: {}

   \- name: config-map

​    configMap:

​     name: mysql
```
通过这个定义，init-mysql 在声明了挂载 config-map 这个 Volume 之后，ConfigMap 里保存的内容，就会以文件的方式出现在它的 /mnt/config-map 目录当中。

而文件拷贝的目标目录，即容器里的 /mnt/conf.d/ 目录，对应的则是一个名叫 conf 的、emptyDir 类型的 Volume。基于 Pod Volume 共享的原理，当 InitContainer 复制完配置文件退出后，后面启动的 MySQL 容器只需要直接声明挂载这个名叫 conf 的 Volume，它所需要的.cnf 配置文件已经出现在里面了。这跟我们之前介绍的 Tomcat 和 WAR 包的处理方法是完全一样的。

第二步：在 Slave Pod 启动前，从 Master 或者其他 Slave Pod 里拷贝数据库数据到自己的目录下。

为了实现这个操作，就需要再定义第二个 InitContainer如下：
```
   \# template.spec.initContainers

   \- name: clone-mysql

​    image: gcr.io/google-samples/xtrabackup:1.0

​    command:

​    \- bash

​    \- "-c"

​    \- |

​     set -ex

​     \# 拷贝操作只需要在第一次启动时进行，所以如果数据已经存在，跳过

​     [[ -d /var/lib/mysql/mysql ]] && exit 0

​     \# Master 节点 (序号为 0) 不需要做这个操作

​     [[ `hostname` =~ -([0-9]+)$ ]] || exit 1

​     ordinal=${BASH_REMATCH[1]}

​     [[ $ordinal -eq 0 ]] && exit 0

​     \# 使用 ncat 指令，远程地从前一个节点拷贝数据到本地

​     ncat --recv-only mysql-$(($ordinal-1)).mysql 3307 | xbstream -x -C /var/lib/mysql

​     \# 执行 --prepare，这样拷贝来的数据就可以用作恢复了

​     xtrabackup --prepare --target-dir=/var/lib/mysql

​    volumeMounts:

​    \- name: data

​     mountPath: /var/lib/mysql

​     subPath: mysql

​    \- name: conf

​     mountPath: /etc/mysql/conf.d
```
在这个名叫 clone-mysql 的 InitContainer 里，使用的是 xtrabackup 镜像（它里面安装了 xtrabackup 工具）。

而在它的启动命令里，首先做了一个判断。即：当初始化所需的数据（/var/lib/mysql/mysql 目录）已经存在，或者当前 Pod 是 Master 节点的时候，不需要做拷贝操作。

接下来，clone-mysql 会使用 Linux 自带的 ncat 指令，向 DNS 记录为"mysql-< 当前序号减一 >.mysql"的 Pod，也就是当前 Pod 的前一个 Pod，发起数据传输请求，并且直接用 xbstream 指令将收到的备份数据保存在 /var/lib/mysql 目录下。

备注：3307 是一个特殊端口，运行着一个专门负责备份 MySQL 数据的辅助进程。我们后面马上会讲到它。

当然，这一步你可以随意选择用自己喜欢的方法来传输数据。比如，用 scp 或者 rsync，都没问题。

这个容器里的 /var/lib/mysql 目录，实际上正是一个名为 data 的 PVC，即：在前面声明的持久化存储。

这就可以保证，哪怕宿主机宕机了，数据库的数据也不会丢失。由于 Pod Volume 是被 Pod 里的容器共享的，所以后面启动的 MySQL 容器，就可以把这个 Volume 挂载到自己的 /var/lib/mysql 目录下，直接使用里面的备份数据进行恢复操作。

不过，clone-mysql 容器还要对 /var/lib/mysql 目录，执行一句 xtrabackup --prepare 操作，目的是让拷贝来的数据进入一致性状态，这样，这些数据才能被用作数据恢复。

至此，就通过 InitContainer 完成了对"主、从节点间备份文件传输"操作的处理过程，也就是翻越了"第二座大山"。

接下来，可以开始定义 MySQL 容器, 启动 MySQL 服务了。由于 StatefulSet 里的所有 Pod 都来自用同一个 Pod 模板，所以还要"人格分裂"地去思考：这个 MySQL 容器的启动命令，在 Master 和 Slave 两种情况下有什么不同。

有了 Docker 镜像，在 Pod 里声明一个 Master 角色的 MySQL 容器并不是什么困难的事情：直接执行 MySQL 启动命令即可。

但是，如果这个 Pod 是一个第一次启动的 Slave 节点，在执行 MySQL 启动命令之前，它就需要使用前面 InitContainer 拷贝来的备份数据进行初始化。可是，别忘了，容器是一个单进程模型。

所以，一个 Slave 角色的 MySQL 容器启动之前，谁能负责给它执行初始化的 SQL 语句呢？

这就是需要解决的"第三座大山"的问题：如何在 Slave 节点的 MySQL 容器第一次启动之前，执行初始化 SQL。

可以为这个 MySQL 容器额外定义一个 sidecar 容器，来完成这个操作，它的定义如下：
```
   \# template.spec.containers

   \- name: xtrabackup

​    image: gcr.io/google-samples/xtrabackup:1.0

​    ports:

​    \- name: xtrabackup

​     containerPort: 3307

​    command:

​    \- bash

​    \- "-c"

​    \- |

​     set -ex

​     cd /var/lib/mysql

​     

​     \# 从备份信息文件里读取 MASTER_LOG_FILEM 和 MASTER_LOG_POS 这两个字段的值，用来拼装集群初始化 SQL

​     if [[ -f xtrabackup_slave_info ]]; then

​      \# 如果 xtrabackup_slave_info 文件存在，说明这个备份数据来自于另一个 Slave 节点。这种情况下，XtraBackup 工具在备份的时候，就已经在这个文件里自动生成了 "CHANGE MASTER TO" SQL 语句。所以，我们只需要把这个文件重命名为 change_master_to.sql.in，后面直接使用即可

​      mv xtrabackup_slave_info change_master_to.sql.in

​      \# 所以，也就用不着 xtrabackup_binlog_info 了

​      rm -f xtrabackup_binlog_info

​     elif [[ -f xtrabackup_binlog_info ]]; then

​      \# 如果只存在 xtrabackup_binlog_inf 文件，那说明备份来自于 Master 节点，我们就需要解析这个备份信息文件，读取所需的两个字段的值

​      [[ `cat xtrabackup_binlog_info` =~ ^(.*?)[[:space:]]+(.*?)$ ]] || exit 1

​      rm xtrabackup_binlog_info

​      \# 把两个字段的值拼装成 SQL，写入 change_master_to.sql.in 文件

​      echo "CHANGE MASTER TO MASTER_LOG_FILE='${BASH_REMATCH[1]}',\

​         MASTER_LOG_POS=${BASH_REMATCH[2]}" > change_master_to.sql.in

​     fi

​     

​     \# 如果 change_master_to.sql.in，就意味着需要做集群初始化工作

​     if [[ -f change_master_to.sql.in ]]; then

​      \# 但一定要先等 MySQL 容器启动之后才能进行下一步连接 MySQL 的操作

​      echo "Waiting for mysqld to be ready (accepting connections)"

​      until mysql -h 127.0.0.1 -e "SELECT 1"; do sleep 1; done

​      

​      echo "Initializing replication from clone position"

​      \# 将文件 change_master_to.sql.in 改个名字，防止这个 Container 重启的时候，因为又找到了 change_master_to.sql.in，从而重复执行一遍这个初始化流程

​      mv change_master_to.sql.in change_master_to.sql.orig

​      \# 使用 change_master_to.sql.orig 的内容，也是就是前面拼装的 SQL，组成一个完整的初始化和启动 Slave 的 SQL 语句

​      mysql -h 127.0.0.1 <<EOF

​     $(<change_master_to.sql.orig),

​      MASTER_HOST='mysql-0.mysql',

​      MASTER_USER='root',

​      MASTER_PASSWORD='',

​      MASTER_CONNECT_RETRY=10;

​     START SLAVE;

​     EOF

​     fi

​     

​     \# 使用 ncat 监听 3307 端口。它的作用是，在收到传输请求的时候，直接执行 "xtrabackup --backup" 命令，备份 MySQL 的数据并发送给请求者

​     exec ncat --listen --keep-open --send-only --max-conns=1 3307 -c \

​      "xtrabackup --backup --slave-info --stream=xbstream --host=127.0.0.1 --user=root"

​    volumeMounts:

​    \- name: data

​     mountPath: /var/lib/mysql

​     subPath: mysql

​    \- name: conf

​     mountPath: /etc/mysql/conf.d
```
在这个名叫 xtrabackup 的 sidecar 容器的启动命令里，实现了两部分工作:
第一部分工作，是 MySQL 节点的初始化工作。这个初始化需要使用的 SQL，是 sidecar 容器拼装出来、保存在一个名为 change_master_to.sql.in 的文件里的，具体过程如下所示：

sidecar 容器首先会判断当前 Pod 的 /var/lib/mysql 目录下，是否有 xtrabackup_slave_info 这个备份信息文件。

如果有，则说明这个目录下的备份数据是由一个 Slave 节点生成的。这种情况下，XtraBackup 工具在备份的时候，就已经在这个文件里自动生成了 "CHANGE MASTER TO" SQL 语句。所以，我们只需要把这个文件重命名为 change_master_to.sql.in，后面直接使用即可。

如果没有 xtrabackup_slave_info 文件、但是存在 xtrabackup_binlog_info 文件，那就说明备份数据来自于 Master 节点。这种情况下，sidecar 容器就需要解析这个备份信息文件，读取 MASTER_LOG_FILE 和 MASTER_LOG_POS 这两个字段的值，用它们拼装出初始化 SQL 语句，然后把这句 SQL 写入到 change_master_to.sql.in 文件中。

接下来，sidecar 容器就可以执行初始化了。从上面的叙述中可以看到，只要这个 change_master_to.sql.in 文件存在，那就说明接下来需要进行集群初始化操作。

所以，这时候，sidecar 容器只需要读取并执行 change_master_to.sql.in 里面的"CHANGE MASTER TO"指令，再执行一句 START SLAVE 命令，一个 Slave 节点就被成功启动了。

需要注意的是：Pod 里的容器并没有先后顺序，所以在执行初始化 SQL 之前，必须先执行一句 SQL（select 1）来检查一下 MySQL 服务是否已经可用。

当然，上述这些初始化操作完成后，我们还要删除掉前面用到的这些备份信息文件。否则，下次这个容器重启时，就会发现这些文件存在，所以又会重新执行一次数据恢复和集群初始化的操作，这是不对的。

同理，change_master_to.sql.in 在使用后也要被重命名，以免容器重启时因为发现这个文件存在又执行一遍初始化。

在完成 MySQL 节点的初始化后，这个 sidecar 容器的第二个工作，则是启动一个数据传输服务。

具体做法是：sidecar 容器会使用 ncat 命令启动一个工作在 3307 端口上的网络发送服务。一旦收到数据传输请求时，sidecar 容器就会调用 xtrabackup --backup 指令备份当前 MySQL 的数据，然后把这些备份数据返回给请求者。这就是为什么我们在 InitContainer 里定义数据拷贝的时候，访问的是"上一个 MySQL 节点"的 3307 端口。

由于 sidecar 容器和 MySQL 容器同处于一个 Pod 里，所以它是直接通过 Localhost 来访问和备份 MySQL 容器里的数据的，非常方便。

同样，在这里举例用的只是一种备份方法而已，可以选择其他自己喜欢的方案。比如可以使用 innobackupex 命令做数据备份和准备，它的使用方法几乎与本文的备份方法一样。

至此，翻越了"第三座大山"，完成了 Slave 节点第一次启动前的初始化工作。

扳倒了这"三座大山"后，终于可以定义 Pod 里的主角，MySQL 容器了。有了前面这些定义和初始化工作，MySQL 容器本身的定义就简单了，如下所示：
```
   \# template.spec

   containers:

   \- name: mysql

​    image: mysql:5.7

​    env:

​    \- name: MYSQL_ALLOW_EMPTY_PASSWORD

​     value: "1"

​    ports:

​    \- name: mysql

​     containerPort: 3306

​    volumeMounts:

​    \- name: data

​     mountPath: /var/lib/mysql

​     subPath: mysql

​    \- name: conf

​     mountPath: /etc/mysql/conf.d

​    resources:

​     requests:

​      cpu: 500m

​      memory: 1Gi

​    livenessProbe:

​     exec:

​      command: ["mysqladmin", "ping"]

​     initialDelaySeconds: 30

​     periodSeconds: 10

​     timeoutSeconds: 5

​    readinessProbe:

​     exec:

​      \# 通过 TCP 连接的方式进行健康检查

​      command: ["mysql", "-h", "127.0.0.1", "-e", "SELECT 1"]

​     initialDelaySeconds: 5

​     periodSeconds: 2

​     timeoutSeconds: 1
```
在这个容器的定义里，我们使用了一个标准的 MySQL 5.7 的官方镜像。它的数据目录是 /var/lib/mysql，配置文件目录是 /etc/mysql/conf.d。

这时应该能够明白，如果 MySQL 容器是 Slave 节点的话，它的数据目录里的数据，就来自于 InitContainer 从其他节点里拷贝而来的备份。它的配置文件目录 /etc/mysql/conf.d 里的内容，则来自于 ConfigMap 对应的 Volume。而它的初始化工作，则是由同一个 Pod 里的 sidecar 容器完成的。这些操作，正是我刚刚讲述的大部分内容。

另外，为它定义了一个 livenessProbe，通过 mysqladmin ping 命令来检查它是否健康；还定义了一个 readinessProbe，通过查询 SQL（select 1）来检查 MySQL 服务是否可用。当然，凡是 readinessProbe 检查失败的 MySQL Pod，都会从 Service 里被摘除掉。

至此，一个完整的主从复制模式的 MySQL 集群就定义完了。

现就可使用 kubectl 命令，尝试运行这个 StatefulSet 了。

首先，需要在 Kubernetes 集群里创建满足条件的 PV。可以按照如下方式使用存储插件 Rook：
```
$ kubectl create -f rook-storage.yaml
$ cat rook-storage.yaml

apiVersion: ceph.rook.io/v1beta1

kind: Pool

metadata:

 name: replicapool

 namespace: rook-ceph

spec:

 replicated:

  size: 3

\---

apiVersion: storage.k8s.io/v1

kind: StorageClass

metadata:

 name: rook-ceph-block

provisioner: ceph.rook.io/block

parameters:

 pool: replicapool

 clusterNamespace: rook-ceph
```
在这里，用到了 StorageClass 来完成这个操作。作用是自动地为集群里存在的每一个 PVC，调用存储插件（Rook）创建对应的 PV，从而省去了手动创建 PV 的机械劳动。

注：在使用 Rook 的情况下，mysql-statefulset.yaml 里的 volumeClaimTemplates 字段需要加上声明 storageClassName=rook-ceph-block，才能使用到这个 Rook 提供的持久化存储。

然后，就可以创建这个 StatefulSet 了，如下所示：
```
$ kubectl create -f mysql-statefulset.yaml

$ kubectl get pod -l app=mysql

NAME    READY   STATUS   RESTARTS  AGE

mysql-0  2/2    Running  0      2m

mysql-1  2/2    Running  0      1m

mysql-2  2/2    Running  0      1m
```
可以看到，StatefulSet 启动成功后，会有三个 Pod 运行。

接下来，可以尝试向这个 MySQL 集群发起请求，执行一些 SQL 操作来验证它是否正常：
```
$ kubectl run mysql-client --image=mysql:5.7 -i --rm --restart=Never --\

 mysql -h mysql-0.mysql <<EOF

CREATE DATABASE test;

CREATE TABLE test.messages (message VARCHAR(250));

INSERT INTO test.messages VALUES ('hello');

EOF
```
如上所示，通过启动一个容器，使用 MySQL client 执行了创建数据库和表、以及插入数据的操作。连接的 MySQL 的地址必须是 mysql-0.mysql（即：Master 节点的 DNS 记录）。因为，只有 Master 节点才能处理写操作。

而通过连接 mysql-read 这个 Service，就可以用 SQL 进行读操作，如下所示：
```
$ kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --\

 mysql -h mysql-read -e "SELECT * FROM test.messages"

Waiting for pod default/mysql-client to be running, status is Pending, pod ready: false

+---------+

| message |

+---------+

| hello  |

+---------+

pod "mysql-client" deleted
 
```
在有了 StatefulSet 以后，就可以像 Deployment 那样，非常方便地扩展这个 MySQL 集群，比如：
```
\# kubectl scale statefulset mysql  --replicas=5
```
这时就会发现新的 Slave Pod mysql-3 和 mysql-4 被自动创建了出来。

而如果你像如下所示的这样，直接连接 mysql-3.mysql，即 mysql-3 这个 Pod 的 DNS 名字来进行查询操作：
```
$ kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --\

 mysql -h mysql-3.mysql -e "SELECT * FROM test.messages"

Waiting for pod default/mysql-client to be running, status is Pending, pod ready: false

+---------+

| message |

+---------+

| hello  |

+---------+

pod "mysql-client" deleted
```
就会看到，从 StatefulSet 为我们新创建的 mysql-3 上，同样可以读取到之前插入的记录。也就是说，我们的数据备份和恢复，都是有效的。

总结

今天以 MySQL 集群为例分享了一个实际的 StatefulSet 的编写过程。这个 YAML 文件的详细内容在这里，多花一些时间认真消化
```
apiVersion: apps/v1beta2

kind: StatefulSet

metadata:

 name: mysql

spec:

 selector:

  matchLabels:

   app: mysql

 serviceName: mysql

 replicas: 3

 template:

  metadata:

   labels:

​    app: mysql

  spec:

   initContainers:

   \- name: init-mysql

​    image: mysql:5.7

​    command:

​    \- bash

​    \- "-c"

​    \- |

​     set -ex

​     \# Generate mysql server-id from pod ordinal index.

​     [[ `hostname` =~ -([0-9]+)$ ]] || exit 1

​     ordinal=${BASH_REMATCH[1]}

​     echo [mysqld] > /mnt/conf.d/server-id.cnf

​     \# Add an offset to avoid reserved server-id=0 value.

​     echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf

​     \# Copy appropriate conf.d files from config-map to emptyDir.

​     if [[ $ordinal -eq 0 ]]; then

​      cp /mnt/config-map/master.cnf /mnt/conf.d/

​     else

​      cp /mnt/config-map/slave.cnf /mnt/conf.d/

​     fi

​    volumeMounts:

​    \- name: conf

​     mountPath: /mnt/conf.d

​    \- name: config-map

​     mountPath: /mnt/config-map

   \- name: clone-mysql

​    image: gcr.io/google-samples/xtrabackup:1.0

​    command:

​    \- bash

​    \- "-c"

​    \- |

​     set -ex

​     \# Skip the clone if data already exists.

​     [[ -d /var/lib/mysql/mysql ]] && exit 0

​     \# Skip the clone on master (ordinal index 0).

​     [[ `hostname` =~ -([0-9]+)$ ]] || exit 1

​     ordinal=${BASH_REMATCH[1]}

​     [[ $ordinal -eq 0 ]] && exit 0

​     \# Clone data from previous peer.

​     ncat --recv-only mysql-$(($ordinal-1)).mysql 3307 | xbstream -x -C /var/lib/mysql

​     \# Prepare the backup.

​     xtrabackup --prepare --target-dir=/var/lib/mysql

​    volumeMounts:

​    \- name: data

​     mountPath: /var/lib/mysql

​     subPath: mysql

​    \- name: conf

​     mountPath: /etc/mysql/conf.d

   containers:

   \- name: mysql

​    image: mysql:5.7

​    env:

​    \- name: MYSQL_ALLOW_EMPTY_PASSWORD

​     value: "1"

​    ports:

​    \- name: mysql

​     containerPort: 3306

​    volumeMounts:

​    \- name: data

​     mountPath: /var/lib/mysql

​     subPath: mysql

​    \- name: conf

​     mountPath: /etc/mysql/conf.d

​    resources:

​     requests:

​      cpu: 500m

​      memory: 1Gi

​    livenessProbe:

​     exec:

​      command: ["mysqladmin", "ping"]

​     initialDelaySeconds: 30

​     periodSeconds: 10

​     timeoutSeconds: 5

​    readinessProbe:

​     exec:

​      \# Check we can execute queries over TCP (skip-networking is off).

​      command: ["mysql", "-h", "127.0.0.1", "-e", "SELECT 1"]

​     initialDelaySeconds: 5

​     periodSeconds: 2

​     timeoutSeconds: 1

   \- name: xtrabackup

​    image: gcr.io/google-samples/xtrabackup:1.0

​    ports:

​    \- name: xtrabackup

​     containerPort: 3307

​    command:

​    \- bash

​    \- "-c"

​    \- |

​     set -ex

​     cd /var/lib/mysql

​     \# Determine binlog position of cloned data, if any.

​     if [[ -f xtrabackup_slave_info ]]; then

​      \# XtraBackup already generated a partial "CHANGE MASTER TO" query

​      \# because we're cloning from an existing slave.

​      mv xtrabackup_slave_info change_master_to.sql.in

​      \# Ignore xtrabackup_binlog_info in this case (it's useless).

​      rm -f xtrabackup_binlog_info

​     elif [[ -f xtrabackup_binlog_info ]]; then

​      \# We're cloning directly from master. Parse binlog position.

​      [[ `cat xtrabackup_binlog_info` =~ ^(.*?)[[:space:]]+(.*?)$ ]] || exit 1

​      rm xtrabackup_binlog_info

​      echo "CHANGE MASTER TO MASTER_LOG_FILE='${BASH_REMATCH[1]}',\

​         MASTER_LOG_POS=${BASH_REMATCH[2]}" > change_master_to.sql.in

​     fi

​     \# Check if we need to complete a clone by starting replication.

​     if [[ -f change_master_to.sql.in ]]; then

​      echo "Waiting for mysqld to be ready (accepting connections)"

​      until mysql -h 127.0.0.1 -e "SELECT 1"; do sleep 1; done

​      echo "Initializing replication from clone position"

​      \# In case of container restart, attempt this at-most-once.

​      mv change_master_to.sql.in change_master_to.sql.orig

​      mysql -h 127.0.0.1 <<EOF

​     $(<change_master_to.sql.orig),

​      MASTER_HOST='mysql-0.mysql',

​      MASTER_USER='root',

​      MASTER_PASSWORD='',

​      MASTER_CONNECT_RETRY=10;

​     START SLAVE;

​     EOF

​     fi

​     \# Start a server to send backups when requested by peers.

​     exec ncat --listen --keep-open --send-only --max-conns=1 3307 -c \

​      "xtrabackup --backup --slave-info --stream=xbstream --host=127.0.0.1 --user=root"

​    volumeMounts:

​    \- name: data

​     mountPath: /var/lib/mysql

​     subPath: mysql

​    \- name: conf

​     mountPath: /etc/mysql/conf.d

​    resources:

​     requests:

​      cpu: 100m

​      memory: 100Mi

   volumes:

   \- name: conf

​    emptyDir: {}

   \- name: config-map

​    configMap:

​     name: mysql

 volumeClaimTemplates:

 \- metadata:

   name: data

  spec:

   accessModes: ["ReadWriteOnce"]

   resources:

​    requests:

​     storage: 10Gi
```
在这个过程中，有以下几个关键点（坑）特别值得你注意和体会。

"人格分裂"：在解决需求的过程中，一定要记得思考，该 Pod 在扮演不同角色时的不同操作。

"阅后即焚"：很多"有状态应用"的节点，只是在第一次启动的时候才需要做额外处理。所以，在编写 YAML 文件时，你一定要考虑"容器重启"的情况，不要让这一次的操作干扰到下一次的容器启动。

"容器之间平等无序"：除非是 InitContainer，否则一个 Pod 里的多个容器之间，是完全平等的。所以，你精心设计的 sidecar，绝不能对容器的顺序做出假设，否则就需要进行前置检查。

最后，相信你也已经能够理解，StatefulSet 其实是一种特殊的 Deployment，只不过这个"Deployment"的每个 Pod 实例的名字里，都携带了一个唯一并且固定的编号。这个编号的顺序，固定了 Pod 的拓扑关系；这个编号对应的 DNS 记录，固定了 Pod 的访问方式；这个编号对应的 PV，绑定了 Pod 与持久化存储的关系。所以，当 Pod 被删除重建时，这些"状态"都会保持不变。

而一旦你的应用没办法通过上述方式进行状态的管理，那就代表了 StatefulSet 已经不能解决它的部署问题了。这时Operator才是更好的选择。

思考题
如果现在的需求是：所有的读请求，只由 Slave 节点处理；所有的写请求，只由 Master 节点处理。那么，你需要在今天的基础上再做哪些改动呢？

StatefulSet 其实就是对现有典型运维业务的容器化抽象。也就是说，你一定有方法在不使用 Kubernetes、甚至不使用容器的情况下，自己 DIY 一个类似的方案出来。但是，一旦涉及到升级、版本管理等更工程化的能力，Kubernetes 的好处，才会更加凸现。

比如，如何对 StatefulSet 进行"滚动更新"（rolling update）？

很简单。你只要修改 StatefulSet 的 Pod 模板，就会自动触发"滚动更新":
```
\# kubectl patch statefulset mysql --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"mysql:5.7.23"}]'

statefulset.apps/mysql patched
```

patch 子命令：
 以"补丁"的方式（JSON 格式的）修改一个 API 对象的指定字段，也就是我在后面指定的"spec/template/spec/containers/0/image"。

这样，StatefulSet Controller 就会按照与 Pod 编号相反的顺序，从最后一个 Pod 开始，逐一更新这个 StatefulSet 管理的每个 Pod。而如果更新发生了错误，这次"滚动更新"就会停止。此外，StatefulSet 的"滚动更新"还允许进行更精细的控制，比如金丝雀发布（Canary Deploy）或者灰度发布，这意味着应用的多个实例中被指定的一部分不会被更新到最新的版本。

这个字段，正是 StatefulSet 的 spec.updateStrategy.rollingUpdate 的 partition 字段。

比如，现在将前面这个 StatefulSet 的 partition 字段设置为 2：
```
$ kubectl patch statefulset mysql -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":2}}}}'

statefulset.apps/mysql patched
```
其中，kubectl patch 命令后面的参数（JSON 格式的），就是 partition 字段在 API 对象里的路径。所以，上述操作等同于直接使用 kubectl edit 命令，打开这个对象，把 partition 字段修改为 2。

这样，我就指定了当 Pod 模板发生变化的时候，比如 MySQL 镜像更新到 5.7.23，那么只有序号大于或者等于 2 的 Pod 会被更新到这个版本。并且，如果你删除或者重启了序号小于 2 的 Pod，等它再次启动后，也会保持原先的 5.7.2 版本，绝不会被升级到 5.7.23 版本。

StatefulSet 可以说是 Kubernetes 项目中最为复杂的编排对象，需要动手实践一下

# DAEMONSET

## DAEMONSET原理

DaemonSet 的主要作用，是让你在 k8s 集群里，运行一个 Daemon Pod。 

这个 Pod 有如下三个特征：
1. 这个 Pod 运行在 k8s 集群里的每一个节点（Node）上；
2. 每个节点上只有一个这样的 Pod 实例；
3. 当有新的节点加入 Kubernetes 集群后，该 Pod 会自动地在新节点上被创建出来；而当旧节点被删除后，它上面的 Pod 也相应地会被回收掉。

举例：
各种网络插件的 Agent 组件，都必须运行在每一个节点上，用来处理这个节点上的容器网络；

各种存储插件的 Agent 组件，也必须运行在每一个节点上，用来在这个节点上挂载远程存储目录，操作容器的 Volume 目录；

各种监控组件和日志组件，也必须运行在每一个节点上，负责这个节点上的监控信息和日志搜集。

跟其他编排对象不一样，DaemonSet 开始运行的时机，很多时候比整个 Kubernetes 集群出现的时机都要早。

DaemonSet 的 API 对象的定义:

```
apiVersion: apps/v1

kind: DaemonSet

metadata:

 name: fluentd-elasticsearch

 namespace: kube-system

 labels:

  k8s-app: fluentd-logging

spec:

 selector:

  matchLabels:

   name: fluentd-elasticsearch

 template:

  metadata:

   labels:

​    name: fluentd-elasticsearch

  spec:

   tolerations:

   \- key: node-role.kubernetes.io/master

​    effect: NoSchedule

   containers:

   \- name: fluentd-elasticsearch

​    image: k8s.gcr.io/fluentd-elasticsearch:1.20

​    resources:

​     limits:

​      memory: 200Mi

​     requests:

​      cpu: 100m

​      memory: 200Mi

​    volumeMounts:

​    \- name: varlog

​     mountPath: /var/log

​    \- name: varlibdockercontainers

​     mountPath: /var/lib/docker/containers

​     readOnly: true

   terminationGracePeriodSeconds: 30

   volumes:

   \- name: varlog

​    hostPath:

​     path: /var/log

   \- name: varlibdockercontainers

​    hostPath:

​     path: /var/lib/docker/containers
```

fluentd-elasticsearch 镜像功能：

  通过 fluentd 将 Docker 容器里的日志转发到 ElasticSearch 中。

DaemonSet 没有 replicas 字段
selector :
  选择管理所有携带了 name=fluentd-elasticsearch 标签的 Pod。

Pod 的模板用 template 字段定义:
定义了一个使用 fluentd-elasticsearch:1.20 镜像的容器，而且这个容器挂载了两个 hostPath 类型的 Volume，分别对应宿主机的 /var/log 目录和 /var/lib/docker/containers 目录。

  fluentd 启动之后，它会从这两个目录里搜集日志信息，并转发给 ElasticSearch 保存。这样，通过 ElasticSearch 就可以很方便地检索这些日志了。Docker 容器里应用的日志，默认会保存在宿主机的 /var/lib/docker/containers/{{. 容器 ID}}/{{. 容器 ID}}-json.log 文件里，这个目录正是 fluentd 的搜集目标。

DaemonSet 如何保证每个 Node 上有且只有一个被管理的 Pod ？

DaemonSet Controller，首先从 Etcd 里获取所有的 Node 列表，然后遍历所有的 Node。这时，它就可以很容易地去检查，当前这个 Node 上是不是有一个携带了 name=fluentd-elasticsearch 标签的 Pod 在运行。

检查结果有三种情况：
1. 没有这种 Pod，那么就意味着要在这个 Node 上创建这样一个 Pod；指定的 Node 上创建新 Pod 用 nodeSelector，选择 Node 的名字即可。
2. 有这种 Pod，但是数量大于 1，那就说明要把多余的 Pod 从这个 Node 上删除掉；删除节点（Node）上多余的 Pod 非常简单，直接调用 Kubernetes API 就可以了。
3. 正好只有一个这种 Pod，那说明这个节点是正常的。

### nodeSelector和nodeAffinity
nodeSelector其实已经是一个将要被废弃的字段了。现在有了一个新的、功能更完善的字段可以代替它，即：nodeAffinity。例子：

```
apiVersion: v1

kind: Pod

metadata:

 name: with-node-affinity

spec:

 affinity:

  nodeAffinity:

   requiredDuringSchedulingIgnoredDuringExecution:

​    nodeSelectorTerms:

​    \- matchExpressions:

​     \- key: metadata.name

​      operator: In

​      values:

​      \- k8s-node1
```

#### spec.affinity：
是 Pod 里跟调度相关的一个字段

#### nodeAffinity：
requiredDuringSchedulingIgnoredDuringExecution：意思是这个 nodeAffinity 必须在每次调度的时候予以考虑。只允许运行在"metadata.name"是"k8s-node1"的节点上。

  operator: In
即：部分匹配；如果你定义 operator: Equal，就是完全匹配
这也是 nodeAffinity 会取代 nodeSelector 的原因之一。大多时候，这些 Operator 语义没啥用处。所以说，在学习开源项目的时候，一定要学会抓住"主线"。不要顾此失彼。

DaemonSet Controller 会在创建 Pod 的时候，自动在这个 Pod 的 API 对象里，加上 nodeAffinity 定义。其中，需要绑定的节点名字，正是当前正在遍历的这个 Node。

DaemonSet 并不需要修改用户提交的 YAML 文件里的 Pod 模板，而是在向 k8s 发起请求之前，直接修改根据模板生成的 Pod 对象。

tolerations :
DaemonSet 还会给这个 Pod 自动加上另外一个与调度相关的字段，叫作 tolerations。这个字段意思是这个 Pod，会"容忍"（Toleration）某些 Node 的"污点"（Taint）。

tolerations 字段，格式如下：
```
apiVersion: v1

kind: Pod

metadata:

 name: with-toleration

spec:

 tolerations:

 \- key: node.kubernetes.io/unschedulable

  operator: Exists

  effect: NoSchedule
```
含义是："容忍"所有被标记为 unschedulable"污点"的 Node；"容忍"的效果是允许调度。可以简单地把"污点"理解为一种特殊的 Label。

正常情况下，被标记了 unschedulable"污点"的 Node，是不会有任何 Pod 被调度上去的（effect: NoSchedule）。可是，DaemonSet 自动地给被管理的 Pod 加上了这个特殊的 Toleration，就使得这些 Pod 可以忽略这个限制，保证每个节点上都会被调度一个 Pod。如果这个节点有故障的话，这个 Pod 可能会启动失败，DaemonSet 会始终尝试下去，直到 Pod 启动成功。

DaemonSet 的"过人之处"，其实就是依靠 Toleration 实现的

假如当前 DaemonSet 管理的，是一个网络插件的 Agent Pod，那么你就必须在这个 DaemonSet 的 YAML 文件里，给它的 Pod 模板加上一个能够"容忍"node.kubernetes.io/network-unavailable"污点"的 Toleration。

例子：
```
template:

  metadata:

   labels:

​    name: network-plugin-agent

  spec:

   tolerations:

   \- key: node.kubernetes.io/network-unavailable

​    operator: Exists

​    effect: NoSchedule

```
当一个节点的网络插件尚未安装时，这个节点就会被自动加上名为node.kubernetes.io/network-unavailable的"污点"。

而通过一个 Toleration，调度器在调度这个 Pod 的时候，就会忽略当前节点上的"污点"，从而成功地将网络插件的 Agent 组件调度到这台机器上启动起来。

这种机制，正是在部署 k8s 集群的时候，能够先部署 Kubernetes 本身、再部署网络插件的根本原因：因为 Weave等网络插件的 YAML，实际就是一个 DaemonSet。

DaemonSet 是一个控制器。在它的控制循环中，只需要遍历所有节点，然后根据节点上是否有被管理 Pod 的情况，来决定是否要创建或者删除一个 Pod。

在创建每个 Pod 的时候，DaemonSet 会自动给这个 Pod 加上一个 nodeAffinity，从而保证这个 Pod 只会在指定节点上启动。同时，它还会自动给这个 Pod 加上一个 Toleration，从而忽略节点的 unschedulable"污点"。

更多种类的Toleration:

可以在 Pod 模板里加上更多种类的 Toleration，从而利用 DaemonSet 实现自己的目的。

比如，在这个 fluentd-elasticsearch DaemonSet 里，给它加上了这样的 Toleration：
```
tolerations:

\- key: node-role.kubernetes.io/master

 effect: NoSchedule
```
这是因为在默认情况下，Kubernetes 集群不允许用户在 Master 节点部署 Pod。因为，Master 节点默认携带了一个叫作node-role.kubernetes.io/master的"污点"。所以，为了能在 Master 节点上部署 DaemonSet 的 Pod，就必须让这个 Pod"容忍"这个"污点"。

## DAEMONSET实践
1. 创建 DaemonSet 对象：
```
\# kubectl create -f fluentd-elasticsearch.yaml
```
DaemonSet 上一般都加上 resources 字段，来限制它的 CPU 和内存使用，防止它占用过多的宿主机资源。

2. 创建成功后，如果有 3 个节点，就会有 3 个 fluentd-elasticsearch Pod 在运行:
```
\# kubectl get pod -n kube-system -l name=fluentd-elasticsearch

NAME              READY  STATUS   RESTARTS  AGE

fluentd-elasticsearch-2pj5x  1/1   Running  0      32s

fluentd-elasticsearch-gtg9g  1/1   Running  0      32s

fluentd-elasticsearch-p8zht  1/1   Running  0      32s
```


3. 查看 DaemonSet 对象：
```
\# kubectl get ds -n kube-system fluentd-elasticsearch

NAME           DESIRED  CURRENT  READY   UP-TO-DATE  AVAILABLE  NODE SELECTOR  AGE

fluentd-elasticsearch  2     2     2     2       2      <none>      1h
```
>注：k8s 里比较长的 API 对象都有短名字，比如 DaemonSet 对应的是 ds，Deployment 对应的是 deploy。

4. DaemonSet 可以进行版本管理。这个版本，可使用 kubectl rollout history 看到：
```
\# kubectl rollout history daemonset fluentd-elasticsearch -n kube-system

daemonsets "fluentd-elasticsearch"

REVISION  CHANGE-CAUSE

1     <none>
```
 5. 把这个 DaemonSet 的容器镜像版本到 v2.2.0：
```
\# kubectl set image ds/fluentd-elasticsearch fluentd-elasticsearch=k8s.gcr.io/fluentd-elasticsearch:v2.2.0 --record -n=kube-system
```
这个 kubectl set image 命令里，第一个 fluentd-elasticsearch 是 DaemonSet 的名字，第二个 fluentd-elasticsearch 是容器的名字。

 6. 用 kubectl rollout status 命令查看这个"滚动更新"的过程：
```
\# kubectl rollout status ds/fluentd-elasticsearch -n kube-system
```
--record 参数:
升级使用到的指令会自动出现在 DaemonSet 的 rollout history 里面，如下所示：
```
\# kubectl rollout history daemonset fluentd-elasticsearch -n kube-system

daemonsets "fluentd-elasticsearch"

REVISION  CHANGE-CAUSE

1     <none>

2     kubectl set image ds/fluentd-elasticsearch fluentd-elasticsearch=k8s.gcr.io/fluentd-elasticsearch:v2.2.0 --namespace=kube-system --record=true
```
有了版本号，也就可以像 Deployment 一样，将 DaemonSet 回滚到某个指定的历史版本了。

### DaemonSet版本维护
Deployment 管理这些版本，靠的是"一个版本对应一个 ReplicaSet 对象"。
DaemonSet 控制器操作的直接就是 Pod，不可能有 ReplicaSet 这样的对象参与其中。那么，它的这些版本又是如何维护的呢？

ControllerRevision :
  专门用来记录某种 Controller 对象的版本。

查看 fluentd-elasticsearch 对应的 ControllerRevision：
```
\# kubectl get controllerrevision -n kube-system -l name=fluentd-elasticsearch

NAME                CONTROLLER               REVISION  AGE

fluentd-elasticsearch-64dc6799c9  daemonset.apps/fluentd-elasticsearch  2      1h
```


查看 ControllerRevision 对象详细信息：
```
\# kubectl describe controllerrevision fluentd-elasticsearch-64dc6799c9 -n kube-system

Name:     fluentd-elasticsearch-64dc6799c9

Namespace:   kube-system

Labels:    controller-revision-hash=2087235575

​       name=fluentd-elasticsearch

Annotations:  deprecated.daemonset.template.generation=2

​       kubernetes.io/change-cause=kubectl set image ds/fluentd-elasticsearch fluentd-elasticsearch=k8s.gcr.io/fluentd-elasticsearch:v2.2.0 --record=true --namespace=kube-system

API Version:  apps/v1

Data:

 Spec:

  Template:

   $ Patch:  replace

   Metadata:

​    Creation Timestamp:  <nil>

​    Labels:

​     Name:  fluentd-elasticsearch

   Spec:

​    Containers:

​     Image:        k8s.gcr.io/fluentd-elasticsearch:v2.2.0

​     Image Pull Policy:  IfNotPresent

​     Name:        fluentd-elasticsearch

...

Revision:          2

Events:           <none>
```

这个 ControllerRevision 对象，实际上是在 Data 字段保存了该版本对应的完整的 DaemonSet 的 API 对象。并且，在 Annotation 字段保存了创建这个对象所使用的 kubectl 命令。

将这个 DaemonSet 回滚到 Revision=1 时的状态：
```
\# kubectl rollout undo daemonset fluentd-elasticsearch --to-revision=1 -n kube-system

daemonset.extensions/fluentd-elasticsearch rolled back
```
这个 kubectl rollout undo 操作，实际上相当于读取到了 Revision=1 的 ControllerRevision 对象保存的 Data 字段。而这个 Data 字段里保存的信息，就是 Revision=1 时这个 DaemonSet 的完整 API 对象。

现在 DaemonSet Controller 就可以使用这个历史 API 对象，对现有的 DaemonSet 做一次 PATCH 操作（等价于执行一次 kubectl apply -f "旧的 DaemonSet 对象"），从而把这个 DaemonSet"更新"到一个旧版本。

在执行完这次回滚完成后，会发现，DaemonSet 的 Revision 并不会从 Revision=2 退回到 1，而是会增加成 Revision=3。这是因为，一个新的 ControllerRevision 被创建了出来。

# 离线业务编排

## 离线业务基础

#### 在线业务

Deployment、StatefulSet，以及 DaemonSet 这三个编排概念的共同之处是：它们主要编排的对象，都是"在线业务"，即：Long Running Task（长作业）。比如常用的 Nginx、Tomcat，以及 MySQL 等等。这些应用一旦运行起来，除非出错或者停止，它的容器进程会一直保持在 Running 状态。

#### 离线业务
也可以叫做Batch Job（计算业务）。这种业务在计算完成后就直接退出了，如果用 Deployment 来管理这种业务，会发现 Pod 会在计算结束后退出，然后被 Deployment Controller 不断地重启

#### Job
一个用来描述离线业务的 API 对象

Job API 对象的定义如下所示：

\# vim job.yaml
```
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
        - name: pi
          image: ubuntu-bc
          command: ["sh", "-c", "echo 'scale=10000; 4*a(1)' | bc -l "]
      restartPolicy: Never
  backoffLimit: 4
```
Job 对象不要求定义一个 spec.selector 来描述要控制哪些 Pod

spec.template 字段为Pod 模板

运行程序：
```
  echo "scale=10000; 4*a(1)" | bc -l 
```

  bc 命令：
 是 Linux 里的"计算器"

-l 表示：是要使用标准数学库

 a(1)：  是调用数学库中的 arctangent 函数，计算 atan(1)。这是什么意思呢？

 数学知识回顾：tan(π/4) = 1。所以，4*atan(1)正好就是π，也就是 3.1415926…。

 这是一个计算π值的容器。通过 scale=10000，指定了输出的小数点后的位数是 10000。在我的计算机上，这个计算大概用时 1 分 54 秒。

创建Job ：
```
\# kubectl create -f job.yaml
```

查看 Job 对象：
```
kubectl get jobs/pi
```
为了避免不同 Job 对象所管理的 Pod 发生重合,Job 对象在创建后，它的 Pod 模板，被自动加上了一个 controller-uid=< 一个随机字符串 > 这样的 Label。而这个 Job 对象本身，则被自动加上了这个 Label 对应的 Selector，保证了 Job 与它所管理的 Pod 之间的匹配关系。

这种自动生成的 Label 对用户并不友好，不太适合推广到 Deployment 等长作业编排对象上。

Pod 进入了 Running 状态说明它正在计算 Pi 的值
```
\# kubectl get pods

NAME                 READY   STATUS   RESTARTS  AGE

pi-rq5rl               1/1    Running  0      10s
```

几分钟后计算结束，这个 Pod 就会进入 Completed 状态：
```
\# kubectl get pods

NAME                 READY   STATUS    RESTARTS  AGE

pi-rq5rl               0/1    Completed  0      4m
```

离线计算的 Pod 永远都不应该被重启：
  实现方式是在 Pod 模板中定义 restartPolicy=Never
  事实上restartPolicy 在 Job 对象里只允许被设置为 Never 和 OnFailure；而在 Deployment 对象里，restartPolicy 则只允许被设置为 Always。

查看 Pod 日志：
```
\# kubectl logs pi-rq5rl  //可以看到计算得到的 Pi 值已经被打印了出来

3.141592653589793238462643383279...
```

离线作业失败处理方式：
离线作业失败后 Job Controller 就会不断地尝试创建一个新 Pod，这个尝试肯定不能无限进行下去。所以，在 Job 对象的 spec.backoffLimit 字段里定义了重试次数为 4（即，backoffLimit=4，默认值是 6）

Job Controller 重新创建 Pod 的间隔是呈指数增加的，即下一次重新创建 Pod 的动作会分别发生在 10 s、20 s、40 s …后。

如果restartPolicy=OnFailure，离线作业失败后，Job Controller 就不会去尝试创建新的 Pod。但是，它会不断地尝试重启 Pod 里的容器。
```
\# kubectl get pods

NAME                 READY   STATUS        RESTARTS  AGE

pi-55h89               0/1    ContainerCreating  0      2s

pi-tqbcz               0/1    Error        0      5s
```
可以看到，这时候会不断地有新 Pod 被创建出来。

spec.activeDeadlineSeconds 字段：
当一个 Job 的 Pod 运行结束后，它会进入 Completed 状态。但是，如果这个 Pod 因为某种原因一直不肯结束呢？

在 Job 的 API 对象里，有一个 spec.activeDeadlineSeconds 字段可以设置最长运行时间，比如：

spec:

 backoffLimit: 5

 activeDeadlineSeconds: 100

一旦运行超过了 100 s，这个 Job 的所有 Pod 都会被终止。并且，你可以在 Pod 的状态里看到终止的原因是 reason: DeadlineExceeded。以上，就是一个 Job API 对象最主要的概念和用法

## 并行作业
离线业务之所以被称为 Batch Job，是因为它们可以以"Batch"，也就是并行的方式去运行。

负责并行控制的参数有两个：

#### spec.parallelism:
定义一个 Job 在任意时间最多可以启动多少个 Pod 同时运行；

#### spec.completions:
定义 Job 至少要完成的 Pod 数目，即 Job 的最小完成数。

在之前计算 Pi 值的 Job 里，添加这两个参数：

注意：本例只是为了演示 Job 的并行特性，实际用途不大。不过现实中确实存在很多需要并行处理的场景。比如批处理程序，每个副本（Pod）都会从任务池中读取任务并执行，副本越多，执行时间就越短，效率就越高。这种类似的场景都可以用 Job 来实现。
```
apiVersion: batch/v1

kind: Job

metadata:

 name: pi

spec:

 parallelism: 2

 completions: 4

 template:

  spec:

   containers:

   \- name: pi

​    image: resouer/ubuntu-bc

​    command: ["sh", "-c", "echo 'scale=5000; 4*a(1)' | bc -l "]

   restartPolicy: Never

 backoffLimit: 4
```
这样，我们就指定了这个 Job 最大的并行数是 2，而最小的完成数是 4。
创建这个 Job 对象：

```
\# kubectl create -f job.yaml
```

这个 Job 其实也维护了两个状态字段，即 DESIRED 和 SUCCESSFUL，如下所示：
```
\# kubectl get job  //注意，最新版本的子段已经不一样了

NAME    DESIRED  SUCCESSFUL  AGE

pi        4     0       3s
```
其中，DESIRED 的值，正是 completions 定义的最小完成数。

这个 Job 首先创建了两个并行运行的 Pod 来计算 Pi：
```
\# kubectl get pods

NAME    READY   STATUS   RESTARTS  AGE

pi-5mt88  1/1    Running  0      6s

pi-gmcq5  1/1    Running  0      6s
```
而在 40 s 后，这两个 Pod 相继完成计算。

这时可以看到，每当有一个 Pod 完成计算进入 Completed 状态时，就会有一个新的 Pod 被自动创建出来，并且快速地从 Pending 状态进入到 ContainerCreating 状态：
```
\# kubectl get pods

NAME    READY   STATUS   RESTARTS  AGE

pi-gmcq5  0/1    Completed  0     40s

pi-84ww8  0/1    Pending  0     0s

pi-5mt88  0/1    Completed  0     41s

pi-62rbt  0/1    Pending  0     0s
```

```
\# kubectl get pods

NAME    READY   STATUS   RESTARTS  AGE

pi-gmcq5  0/1    Completed  0     40s

pi-84ww8  0/1    ContainerCreating  0     0s

pi-5mt88  0/1    Completed  0     41s

pi-62rbt  0/1    ContainerCreating  0     0s
```
紧接着，Job Controller 第二次创建出来的两个并行的 Pod 也进入了 Running 状态：
```
\# kubectl get pods 

NAME    READY   STATUS    RESTARTS  AGE

pi-5mt88  0/1    Completed  0      54s

pi-62rbt  1/1    Running   0      13s

pi-84ww8  1/1    Running   0      14s

pi-gmcq5  0/1    Completed  0      54s
```
最终，后面创建的这两个 Pod 也完成了计算，进入了 Completed 状态。

这时，由于所有的 Pod 均已经成功退出，这个 Job 也就执行完了，所以你会看到它的 SUCCESSFUL 字段的值变成了 4：
```
\# kubectl get pods 

NAME    READY   STATUS    RESTARTS  AGE

pi-5mt88  0/1    Completed  0      5m

pi-62rbt  0/1    Completed  0      4m

pi-84ww8  0/1    Completed  0      4m

pi-gmcq5  0/1    Completed  0      5m
```

```
\# kubectl get job

NAME    DESIRED  SUCCESSFUL  AGE

pi     4     4       5m
```

### Job Controller 的工作原理总结

1. Job Controller 控制的对象，直接就是 Pod。
2. Job Controller 在控制循环中进行的调谐（Reconcile）操作，是根据实际在 Running 状态 Pod 的数目、已经成功退出的 Pod 的数目，以及 parallelism、completions 参数的值共同计算出在这个周期里，应该创建或者删除的 Pod 数目，然后调用 Kubernetes API 来执行这个操作。

在上面计算 Pi 值的这个例子中，当 Job 一开始创建出来时，实际处于 Running 状态的 Pod 数目 =0，已经成功退出的 Pod 数目 =0，而用户定义的 completions，也就是最终用户需要的 Pod 数目 =4。

所以，在这个时刻，需要创建的 Pod 数目 = 最终需要的 Pod 数目 - 实际在 Running 状态 Pod 数目 - 已经成功退出的 Pod 数目 = 4 - 0 - 0= 4。也就是说，Job Controller 需要创建 4 个 Pod 来纠正这个不一致状态。

可是，又定义了这个 Job 的 parallelism=2 规定了每次并发创建的 Pod 个数不能超过 2 个。所以，Job Controller 会对前面的计算结果做一个修正，修正后的期望创建的 Pod 数目应该是：2 个。

这时候，Job Controller 就会并发地向 kube-apiserver 发起两个创建 Pod 的请求。

类似地，如果在这次调谐周期里，Job Controller 发现实际在 Running 状态的 Pod 数目，比 parallelism 还大，那么它就会删除一些 Pod，使两者相等。

综上所述，Job Controller 实际上控制了，作业执行的并行度，以及总共需要完成的任务数这两个重要参数。而在实际使用时，你需要根据作业的特性，来决定并行度（parallelism）和任务数（completions）的合理取值。

## JOB对象三种常见用法
Job 对象有三种常见的使用方法。但是大多数情况下用户还是更倾向于自己控制 Job 对象。相比于这些固定的"模式"，掌握 Job 的 API 对象，和它各个字段的准确含义会更加重要。在实际场景里，要么干脆就用第一种用法来自己管理作业；要么，这些任务 Pod 之间的关系就不那么"单纯"，甚至还是"有状态应用"（比如，任务的输入 / 输出是在持久化数据卷里）。


### 外部管理器 +JOB 模板
第一种用法：最简单粗暴的job用法
  外部管理器 +Job 模板
  这种模式的特定用法是：把 Job 的 YAML 文件定义为一个"模板"，然后用一个外部工具控制这些"模板"来生成 Job。

定义方式如下：
\# vim job-tmpl.yaml
```
apiVersion: batch/v1
kind: Job
metadata:
 name: process-item-$ITEM
 labels:
  jobgroup: jobexample
spec:
 template:
  metadata:
   name: jobexample
   labels:
    jobgroup: jobexample
  spec:
   containers:
   - name: c
    image: busybox
    command: ["sh", "-c", "echo Processing item $ITEM && sleep 5"]
   restartPolicy: Never
```
这个 Job 的 YAML 里，定义了 $ITEM "变量"

在控制这种 Job 时，只要注意如下两个方面即可：

1. 创建 Job 时，替换掉 $ITEM 这样的变量；

2.  所有来自于同一个模板的 Job，都有一个 jobgroup: jobexample 标签，也就是说这一组 Job 使用这样一个相同的标识。

第一点非常简单：

通过 shell 把 $ITEM 替换掉：
```
\# mkdir ./jobs

\# for i in apple banana cherry
do
 cat job-tmpl.yaml | sed "s/\$ITEM/$i/" > ./jobs/job-$i.yaml
done
```
一组来自于同一个模板的不同 Job 的 yaml 就生成了。

创建这些 Job ：
```
\# kubectl create -f ./jobs

\# kubectl get pods -l jobgroup=jobexample

NAME                   READY   STATUS     RESTARTS  AGE

process-item-apple-kixwv   0/1      Completed  0      4m

process-item-banana-wrsf7  0/1      Completed  0      4m

process-item-cherry-dnfu9  0/1      Completed  0      4m
```

这个模式看起来虽然很"傻"，但却是 Kubernetes 社区里使用 Job 的一个很普遍的模式。

原因很简单：大多数用户在需要管理 Batch Job 的时候，都已经有了一套自己的方案，需要做的往往就是集成工作。这时候，k8s 项目对这些方案来说最有价值的，就是 Job 这个 API 对象。所以，你只需要编写一个外部工具（等同于我们这里的 for 循环）来管理这些 Job 即可。

 

### 拥有固定任务数目的并行 JOB

第二种用法：拥有固定任务数目的并行 Job
注：本例使用的伪代码，不需要部署，只需要弄懂逻辑即可

这种模式下，只关心最后是否有指定数目（spec.completions）个任务成功退出。至于执行时的并行度是多少，并不关心。

比如计算 Pi 值的例子，就是这样一个典型的、拥有固定任务数目（completions=4）的应用场景。 它的 parallelism 值是 2；或者可以干脆不指定 parallelism，直接使用默认的并行度（即：1）。

还可以使用一个工作队列（Work Queue）进行任务分发。这时，Job 的 YAML 文件定义如下所示：
```
apiVersion: batch/v1

kind: Job

metadata:

 name: job-wq-1

spec:

 completions: 8

 parallelism: 2

 template:

  metadata:

   name: job-wq-1

  spec:

   containers:

   \- name: c

​    image: myrepo/job-wq-1

​    env:

​    \- name: BROKER_URL

​     value: amqp://guest:guest@rabbitmq-service:5672

​    \- name: QUEUE

​     value: job1

   restartPolicy: OnFailure
```
completions 的值是：8，也就总共要处理的任务数目是 8 个。也就是说，总共会有 8 个任务会被逐一放入工作队列里（你可以运行一个外部小程序作为生产者，来提交任务）。

这个实例中，选择充当工作队列的是一个运行在 k8s 里的 RabbitMQ。所以，需要在 Pod 模板里定义 BROKER_URL，来作为消费者。

一旦你创建了这个 Job，它就会以并发度为 2 的方式，每两个 Pod 一组，创建出 8 个 Pod。每个 Pod 都会去连接 BROKER_URL，从 RabbitMQ里读取任务，然后各自进行处理。这个 Pod 里的执行逻辑，可以用这样一段伪代码来表示：

/* job-wq-1 的伪代码 */  

运行在job-wp-1镜像中的伪代码，用来从消息队列取消息

queue := newQueue($BROKER_URL, $QUEUE)

task := queue.Pop()

process(task)

exit

 

每个 Pod 只需要将任务信息读取出来，处理完成，然后退出即可。而作为用户，只关心最终一共有 8 个计算任务启动并且退出，只要这个目标达到，就认为整个 Job 处理完成了。这种用法，对应的就是"任务总数固定"的场景。

### 指定并行度不设置固定COMPLETIONS 值

第三种用法：指定并行度（parallelism），但不设置固定的 completions 的值。

注：和第二种用法类似，也不需要部署，只需要弄懂逻辑

此时，你就必须自己想办法，来决定什么时候启动新 Pod，什么时候 Job 才算执行完成。在这种情况下，任务的总数是未知的，所以你不仅需要一个工作队列来负责任务分发，还需要能够判断工作队列已经为空（即：所有的工作已经结束了）。

Job 的定义基本上没变化，不过不再需要定义 completions 的值了而已：
```
apiVersion: batch/v1

kind: Job

metadata:

 name: job-wq-2

spec:

 parallelism: 2

 template:

  metadata:

   name: job-wq-2

  spec:

   containers:

   \- name: c

​    image: gcr.io/myproject/job-wq-2

​    env:

​    \- name: BROKER_URL

​     value: amqp://guest:guest@rabbitmq-service:5672

​    \- name: QUEUE

​     value: job2

   restartPolicy: OnFailure
```
而对应的 Pod 的逻辑会稍微复杂一些，用这样一段伪代码来描述：

 

```
/* job-wq-2 的伪代码 */

for !queue.IsEmpty($BROKER_URL, $QUEUE) {

 task := queue.Pop()

 process(task)

}

print("Queue empty, exiting")

exit
```

由于任务数目的总数不固定，所以每一个 Pod 必须能够知道，自己什么时候可以退出。比如，在这个例子中，简单地以"队列为空"，作为任务全部完成的标志。所以说，这种用法，对应的是"任务总数不固定"的场景。

## JOB控制器CRONJOB

Job 对象：CronJob

CronJob 描述的是定时任务,CronJob 是一个 Job 对象的控制器（Controller）！

 

CronJob的 API 对象，如下所示：

\# vim ./cronjob.yaml

```
apiVersion: batch/v1beta1

kind: CronJob

metadata:

 name: hello

spec:

 schedule: "*/1 * * * *"

 jobTemplate:

  spec:

   template:

​    spec:

​     containers:

​     \- name: hello

​      image: daocloud.io/library/busybox

​      args:

​      \- /bin/sh

​      \- -c

​      \- date; echo Hello from the Kubernetes cluster

​     restartPolicy: OnFailure
```

 

CronJob 与 Job 的关系，同 Deployment 与 Pod 的关系一样。

CronJob 是一个专门用来管理 Job 对象的控制器。它创建和删除 Job 的依据，是 schedule 字段定义的、一个标准的Unix Cron格式的表达式。

 

比如: 

  "*/1 * * * *"

  分钟、小时、日、月、星期

  这个 Cron 表达式里 */1 中的 * 表示从 0 开始，/ 表示"每"，1 表示偏移量。所以，它的意思就是：从 0 开始，每 1 个时间单位执行一次。

  本例表示从当前开始，每分钟执行一次

这里要执行的内容，就是 jobTemplate 定义的 Job 。

这个 CronJob 对象在创建 1 分钟后，就会有一个 Job 产生了，如下所示：

```
# kubectl create -f ./cronjob.yaml

cronjob "hello" created
```

\# 一分钟后

```
# kubectl get jobs

NAME        DESIRED  SUCCESSFUL  AGE

hello-4111706356  1     1     2s
```

 

此时，CronJob 对象会记录下这次 Job 执行的时间：新版本中在describe里显示执行时间

```
# kubectl get cronjob hello

NAME    SCHEDULE    SUSPEND  ACTIVE   LAST-SCHEDULE

hello     */1 * * * *     False   0     Thu, 6 Sep 2018 14:34:00 -070
```

 

spec.concurrencyPolicy 字段：

  由于定时任务的特殊性，很可能某个 Job 还没有执行完，另外一个新 Job 就产生了。这时候，可以通过 spec.concurrencyPolicy 字段来定义具体的处理策略。 

concurrencyPolicy=Allow

  默认情况，表示这些 Job 可以同时存在；

concurrencyPolicy=Forbid

  表示不会创建新的 Pod，该创建周期被跳过；

concurrencyPolicy=Replace

  表示新产生的 Job 会替换旧的、没有执行完的 Job。

spec.startingDeadlineSeconds 字段：

  如果某一次 Job 创建失败，这次创建就会被标记为"miss"。当在指定的时间窗口内，miss 的数目达到 100 时，那么 CronJob 会停止再创建这个 Job。

  这个时间窗口，可以由 spec.startingDeadlineSeconds 字段指定。比如 startingDeadlineSeconds=200，意味着在过去 200 s 里，如果 miss 的数目达到了 100 次，那么这个 Job 就不会被创建执行了。

# OPERATOR 的工作原理和编写方法

在 Kubernetes 中，管理"有状态应用"是一个比较复杂的过程，尤其是编写 Pod 模板的时候，总有一种"在 YAML 文件里编程序"的感觉，让人很不舒服。

而在 Kubernetes 生态中，还有一个相对更加灵活和编程友好的管理"有状态应用"的解决方案，它就是：Operator。

以 Etcd Operator 为例，讲解 Operator 的工作原理和编写方法。

Etcd Operator 的使用只需要两步即可完成：

1. 将这个 Operator 的代码 Clone 到本地：

```
\# git clone https://github.com/coreos/etcd-operator
```

2. 将这个 Etcd Operator 部署在 Kubernetes 集群里。

因为Etcd Operator 需要访问 Kubernetes 的 APIServer 来创建对象，所以先为 Etcd Operator 创建 RBAC 规则

```
\# example/rbac/create_role.sh
```

上述脚本为 Etcd Operator 定义了如下所示的权限：

1. 对 Pod、Service、PVC、Deployment、Secret 等 API 对象，有所有权限；

2. 对 CRD 对象，有所有权限；

3. 对属于 etcd.database.coreos.com 这个 API Group 的 CR（Custom Resource）对象，有所有权限。

Etcd Operator 本身就是一个 Deployment，它的 YAML 文件如下所示：

```
apiVersion: extensions/v1beta1

kind: Deployment

metadata:

 name: etcd-operator

spec:

 replicas: 1

 template:

  metadata:

   labels:

​    name: etcd-operator

  spec:

   containers:

   \- name: etcd-operator

​    image: quay.io/coreos/etcd-operator:v0.9.2

​    command:

​    \- etcd-operator

​    env:

​    \- name: MY_POD_NAMESPACE

​     valueFrom:

​      fieldRef:

​       fieldPath: metadata.namespace

​    \- name: MY_POD_NAME

​     valueFrom:

​      fieldRef:

​       fieldPath: metadata.name

...

 
```

创建 Etcd Operator，如下所示：

```
\# kubectl create -f example/deployment.yaml
```

一旦 Etcd Operator 的 Pod 进入了 Running 状态，你就会发现，有一个 CRD 被自动创建了出来，如下所示：

```
# kubectl get pods

NAME                READY   STATUS    RESTARTS  AGE

etcd-operator-649dbdb5cb-bzfzp   1/1    Running   0      20s
```

 

```
# kubectl get crd

NAME                   CREATED AT

etcdclusters.etcd.database.coreos.com  2018-09-18T11:42:55Z
```

这个 CRD 名叫etcdclusters.etcd.database.coreos.com 。

 

通过 kubectl describe 命令看到它的细节，如下所示：

```
\# kubectl describe crd  etcdclusters.etcd.database.coreos.com
```

可以看到，这个 CRD 相当于告诉了 Kubernetes：接下来，如果有 API 组（Group）是etcd.database.coreos.com、API 资源类型（Kind）是"EtcdCluster"的 YAML 文件被提交上来，你可一定要认识啊。

 

所以说，通过上述两步操作，你实际上是在 Kubernetes 里添加了一个名叫 EtcdCluster 的自定义资源类型。而 Etcd Operator 本身，就是这个自定义资源类型对应的自定义控制器。

 

而当 Etcd Operator 部署好之后，接下来在这个 Kubernetes 里创建一个 Etcd 集群的工作就非常简单了。你只需要编写一个 EtcdCluster 的 YAML 文件，然后把它提交给 Kubernetes 即可，如下所示：

 

```
$ kubectl apply -f example/example-etcd-cluster.yaml
```

这个 example-etcd-cluster.yaml 文件里描述的，是一个 3 个节点的 Etcd 集群。我们可以看到它被提交给 Kubernetes 之后，就会有三个 Etcd 的 Pod 运行起来，如下所示：

```
$ kubectl get pods

NAME               READY   STATUS   RESTARTS  AGE

example-etcd-cluster-dp8nqtjznc  1/1    Running   0      1m

example-etcd-cluster-mbzlg6sd56  1/1    Running   0      2m

example-etcd-cluster-v6v6s6stxd  1/1    Running   0      2m
```

那么，究竟发生了什么，让创建一个 Etcd 集群的工作如此简单呢？

我们当然还是得从这个 example-etcd-cluster.yaml 文件开始说起。

不难想到，这个文件里定义的，正是 EtcdCluster 这个 CRD 的一个具体实例，也就是一个 Custom Resource（CR）。而它的内容非常简单，如下所示：

 

```
apiVersion: "etcd.database.coreos.com/v1beta2"

kind: "EtcdCluster"

metadata:

 name: "example-etcd-cluster"

spec:

 size: 3

 version: "3.2.13"
```

可以看到，EtcdCluster 的 spec 字段非常简单。其中，size=3 指定了它所描述的 Etcd 集群的节点个数。而 version="3.2.13"，则指定了 Etcd 的版本，仅此而已。

而真正把这样一个 Etcd 集群创建出来的逻辑，就是 Etcd Operator 要实现的主要工作了。

看到这里，相信你应该已经对 Operator 有了一个初步的认知：

Operator 的工作原理，实际上是利用了 Kubernetes 的自定义 API 资源（CRD），来描述我们想要部署的"有状态应用"；然后在自定义控制器里，根据自定义 API 对象的变化，来完成具体的部署和运维工作。

所以，编写一个 Etcd Operator，与我们前面编写一个自定义控制器的过程，没什么不同。

不过，考虑到你可能还不太清楚Etcd 集群的组建方式，我在这里先简单介绍一下这部分知识。

Etcd Operator 部署 Etcd 集群，采用的是静态集群（Static）的方式。 

静态集群的好处是，它不必依赖于一个额外的服务发现机制来组建集群，非常适合本地容器化部署。而它的难点，则在于你必须在部署的时候，就规划好这个集群的拓扑结构，并且能够知道这些节点固定的 IP 地址。比如下面这个例子：

 

```
$ etcd --name infra0 --initial-advertise-peer-urls http://10.0.1.10:2380 \

 --listen-peer-urls http://10.0.1.10:2380 \

...

 --initial-cluster-token etcd-cluster-1 \

 --initial-cluster infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380,infra2=http://10.0.1.12:2380 \

 --initial-cluster-state new

 

$ etcd --name infra1 --initial-advertise-peer-urls http://10.0.1.11:2380 \

 --listen-peer-urls http://10.0.1.11:2380 \

...

 --initial-cluster-token etcd-cluster-1 \

 --initial-cluster infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380,infra2=http://10.0.1.12:2380 \

 --initial-cluster-state new

 

$ etcd --name infra2 --initial-advertise-peer-urls http://10.0.1.12:2380 \

 --listen-peer-urls http://10.0.1.12:2380 \

...

 --initial-cluster-token etcd-cluster-1 \

 --initial-cluster infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380,infra2=http://10.0.1.12:2380 \

 --initial-cluster-state new
```

在这个例子中，我启动了三个 Etcd 进程，组成了一个三节点的 Etcd 集群。

其中，这些节点启动参数里的–initial-cluster 参数，非常值得你关注。它的含义，正是当前节点启动时集群的拓扑结构。说得更详细一点，就是当前这个节点启动时，需要跟哪些节点通信来组成集群。 

举个例子，我们可以看一下上述 infra2 节点的–initial-cluster 的值，如下所示：

 

...

--initial-cluster infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380,infra2=http://10.0.1.12:2380 \

可以看到，–initial-cluster 参数是由"< 节点名字 >=< 节点地址 >"格式组成的一个数组。而上面这个配置的意思就是，当 infra2 节点启动之后，这个 Etcd 集群里就会有 infra0、infra1 和 infra2 三个节点。

 

同时，这些 Etcd 节点，需要通过 2380 端口进行通信以便组成集群，这也正是上述配置中–listen-peer-urls 字段的含义。

 

此外，一个 Etcd 集群还需要用–initial-cluster-token 字段，来声明一个该集群独一无二的 Token 名字。

 

像上述这样为每一个 Ectd 节点配置好它对应的启动参数之后把它们启动起来，一个 Etcd 集群就可以自动组建起来了。

 

而我们要编写的 Etcd Operator，就是要把上述过程自动化。这其实等同于：用代码来生成每个 Etcd 节点 Pod 的启动命令，然后把它们启动起来。

 

接下来，我们一起来实践一下这个流程。

 

当然，在编写自定义控制器之前，我们首先需要完成 EtcdCluster 这个 CRD 的定义，它对应的 types.go 文件的主要内容，如下所示：

 

// +genclient

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

 

type EtcdCluster struct {

 metav1.TypeMeta  `json:",inline"`

 metav1.ObjectMeta `json:"metadata,omitempty"`

 Spec        ClusterSpec  `json:"spec"`

 Status       ClusterStatus `json:"status"`

}

 

type ClusterSpec struct {

 // Size is the expected size of the etcd cluster.

 // The etcd-operator will eventually make the size of the running

 // cluster equal to the expected size.

 // The vaild range of the size is from 1 to 7.

 Size int `json:"size"`

 ... 

}

可以看到，EtcdCluster 是一个有 Status 字段的 CRD。在这里，我们可以不必关心 ClusterSpec 里的其他字段，只关注 Size（即：Etcd 集群的大小）字段即可。

 

Size 字段的存在，就意味着将来如果我们想要调整集群大小的话，应该直接修改 YAML 文件里 size 的值，并执行 kubectl apply -f。

 

这样，Operator 就会帮我们完成 Etcd 节点的增删操作。这种"scale"能力，也是 Etcd Operator 自动化运维 Etcd 集群需要实现的主要功能。

 

而为了能够支持这个功能，我们就不再像前面那样在–initial-cluster 参数里把拓扑结构固定死。

 

所以，Etcd Operator 的实现，虽然选择的也是静态集群，但这个集群具体的组建过程，是逐个节点动态添加的方式，即：

 

首先，Etcd Operator 会创建一个"种子节点"；

然后，Etcd Operator 会不断创建新的 Etcd 节点，然后将它们逐一加入到这个集群当中，直到集群的节点数等于 size。

 

这就意味着，在生成不同角色的 Etcd Pod 时，Operator 需要能够区分种子节点与普通节点。

 

而这两种节点的不同之处，就在于一个名叫–initial-cluster-state 的启动参数：

 

当这个参数值设为 new 时，就代表了该节点是种子节点。而我们前面提到过，种子节点还必须通过–initial-cluster-token 声明一个独一无二的 Token。

而如果这个参数值设为 existing，那就是说明这个节点是一个普通节点，Etcd Operator 需要把它加入到已有集群里。

那么接下来的问题就是，每个 Etcd 节点的–initial-cluster 字段的值又是怎么生成的呢？

 

由于这个方案要求种子节点先启动，所以对于种子节点 infra0 来说，它启动后的集群只有它自己，即：–initial-cluster=infra0=http://10.0.1.10:2380。

 

而对于接下来要加入的节点，比如 infra1 来说，它启动后的集群就有两个节点了，所以它的–initial-cluster 参数的值应该是：infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380。

 

其他节点，都以此类推。

 

现在，你就应该能在脑海中构思出上述三节点 Etcd 集群的部署过程了。

 

首先，只要用户提交 YAML 文件时声明创建一个 EtcdCluster 对象（一个 Etcd 集群），那么 Etcd Operator 都应该先创建一个单节点的种子集群（Seed Member），并启动这个种子节点。

 

以 infra0 节点为例，它的 IP 地址是 10.0.1.10，那么 Etcd Operator 生成的种子节点的启动命令，如下所示：

 

$ etcd

 --data-dir=/var/etcd/data

 --name=infra0

 --initial-advertise-peer-urls=http://10.0.1.10:2380

 --listen-peer-urls=http://0.0.0.0:2380

 --listen-client-urls=http://0.0.0.0:2379

 --advertise-client-urls=http://10.0.1.10:2379

 --initial-cluster=infra0=http://10.0.1.10:2380

 --initial-cluster-state=new

 --initial-cluster-token=4b5215fa-5401-4a95-a8c6-892317c9bef8

可以看到，这个种子节点的 initial-cluster-state 是 new，并且指定了唯一的 initial-cluster-token 参数。

 

我们可以把这个创建种子节点（集群）的阶段称为：Bootstrap。

 

接下来，对于其他每一个节点，Operator 只需要执行如下两个操作即可，以 infra1 为例。

 

第一步：通过 Etcd 命令行添加一个新成员：

 

$ etcdctl member add infra1 http://10.0.1.11:2380

第二步：为这个成员节点生成对应的启动参数，并启动它：

 

$ etcd

  --data-dir=/var/etcd/data

  --name=infra1

  --initial-advertise-peer-urls=http://10.0.1.11:2380

  --listen-peer-urls=http://0.0.0.0:2380

  --listen-client-urls=http://0.0.0.0:2379

  --advertise-client-urls=http://10.0.1.11:2379

  --initial-cluster=infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380

  --initial-cluster-state=existing

可以看到，对于这个 infra1 成员节点来说，它的 initial-cluster-state 是 existing，也就是要加入已有集群。而它的 initial-cluster 的值，则变成了 infra0 和 infra1 两个节点的 IP 地址。

 

所以，以此类推，不断地将 infra2 等后续成员添加到集群中，直到整个集群的节点数目等于用户指定的 size 之后，部署就完成了。

 

在熟悉了这个部署思路之后，我再为你讲解Etcd Operator 的工作原理，就非常简单了。

 

跟所有的自定义控制器一样，Etcd Operator 的启动流程也是围绕着 Informer 展开的，如下所示：

 

func (c *Controller) Start() error {

 for {

 err := c.initResource()

 ...

 time.Sleep(initRetryWaitTime)

 }

 c.run()

}

 

func (c *Controller) run() {

 ...

 

 _, informer := cache.NewIndexerInformer(source, &api.EtcdCluster{}, 0, cache.ResourceEventHandlerFuncs{

 AddFunc:   c.onAddEtcdClus,

 UpdateFunc: c.onUpdateEtcdClus,

 DeleteFunc: c.onDeleteEtcdClus,

 }, cache.Indexers{})

 

 ctx := context.TODO()

 // TODO: use workqueue to avoid blocking

 informer.Run(ctx.Done())

}

可以看到，Etcd Operator 启动要做的第一件事（ c.initResource），是创建 EtcdCluster 对象所需要的 CRD，即：前面提到的etcdclusters.etcd.database.coreos.com。这样 Kubernetes 就能够"认识"EtcdCluster 这个自定义 API 资源了。

 

而接下来，Etcd Operator 会定义一个 EtcdCluster 对象的 Informer。

 

不过，需要注意的是，由于 Etcd Operator 的完成时间相对较早，所以它里面有些代码的编写方式会跟我们之前讲解的最新的编写方式不太一样。在具体实践的时候，你还是应该以我讲解的模板为主。

 

比如，在上面的代码最后，你会看到有这样一句注释：

 

// TODO: use workqueue to avoid blocking

...

也就是说，Etcd Operator 并没有用工作队列来协调 Informer 和控制循环。这其实正是我在第 25 篇文章《深入解析声明式 API（二）：编写自定义控制器》中，给你留的关于工作队列的思考题的答案。

 

具体来讲，我们在控制循环里执行的业务逻辑，往往是比较耗时间的。比如，创建一个真实的 Etcd 集群。而 Informer 的 WATCH 机制对 API 对象变化的响应，则非常迅速。所以，控制器里的业务逻辑就很可能会拖慢 Informer 的执行周期，甚至可能 Block 它。而要协调这样两个快、慢任务的一个典型解决方法，就是引入一个工作队列。

 

备注：如果你感兴趣的话，可以给 Etcd Operator 提一个 patch 来修复这个问题。提 PR 修 TODO，是给一个开源项目做有意义的贡献的一个重要方式。

 

由于 Etcd Operator 里没有工作队列，那么在它的 EventHandler 部分，就不会有什么入队操作，而直接就是每种事件对应的具体的业务逻辑了。

 

不过，Etcd Operator 在业务逻辑的实现方式上，与常规的自定义控制器略有不同。我把在这一部分的工作原理，提炼成了一个详细的流程图，如下所示：

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

可以看到，Etcd Operator 的特殊之处在于，它为每一个 EtcdCluster 对象，都启动了一个控制循环，"并发"地响应这些对象的变化。显然，这种做法不仅可以简化 Etcd Operator 的代码实现，还有助于提高它的响应速度。

 

以文章一开始的 example-etcd-cluster 的 YAML 文件为例。

 

当这个 YAML 文件第一次被提交到 Kubernetes 之后，Etcd Operator 的 Informer，就会立刻"感知"到一个新的 EtcdCluster 对象被创建了出来。所以，EventHandler 里的"添加"事件会被触发。

 

而这个 Handler 要做的操作也很简单，即：在 Etcd Operator 内部创建一个对应的 Cluster 对象（cluster.New），比如流程图里的 Cluster1。

 

这个 Cluster 对象，就是一个 Etcd 集群在 Operator 内部的描述，所以它与真实的 Etcd 集群的生命周期是一致的。

 

而一个 Cluster 对象需要具体负责的，其实有两个工作。

 

其中，第一个工作只在该 Cluster 对象第一次被创建的时候才会执行。这个工作，就是我们前面提到过的 Bootstrap，即：创建一个单节点的种子集群。

 

由于种子集群只有一个节点，所以这一步直接就会生成一个 Etcd 的 Pod 对象。这个 Pod 里有一个 InitContainer，负责检查 Pod 的 DNS 记录是否正常。如果检查通过，用户容器也就是 Etcd 容器就会启动起来。

 

而这个 Etcd 容器最重要的部分，当然就是它的启动命令了。

 

以我们在文章一开始部署的集群为例，它的种子节点的容器启动命令如下所示：

 

/usr/local/bin/etcd

 --data-dir=/var/etcd/data

 --name=example-etcd-cluster-mbzlg6sd56

 --initial-advertise-peer-urls=http://example-etcd-cluster-mbzlg6sd56.example-etcd-cluster.default.svc:2380

 --listen-peer-urls=http://0.0.0.0:2380

 --listen-client-urls=http://0.0.0.0:2379

 --advertise-client-urls=http://example-etcd-cluster-mbzlg6sd56.example-etcd-cluster.default.svc:2379

 --initial-cluster=example-etcd-cluster-mbzlg6sd56=http://example-etcd-cluster-mbzlg6sd56.example-etcd-cluster.default.svc:2380

 --initial-cluster-state=new

 --initial-cluster-token=4b5215fa-5401-4a95-a8c6-892317c9bef8

上述启动命令里的各个参数的含义，我已经在前面介绍过。

 

可以看到，在这些启动参数（比如：initial-cluster）里，Etcd Operator 只会使用 Pod 的 DNS 记录，而不是它的 IP 地址。

 

这当然是因为，在 Operator 生成上述启动命令的时候，Etcd 的 Pod 还没有被创建出来，它的 IP 地址自然也无从谈起。

 

这也就意味着，每个 Cluster 对象，都会事先创建一个与该 EtcdCluster 同名的 Headless Service。这样，Etcd Operator 在接下来的所有创建 Pod 的步骤里，就都可以使用 Pod 的 DNS 记录来代替它的 IP 地址了。

 

备注：Headless Service 的 DNS 记录格式是：...svc.cluster.local。如果你记不太清楚了，可以借此再回顾一下第 18 篇文章《深入理解 StatefulSet（一）：拓扑状态》中的相关内容。

 

Cluster 对象的第二个工作，则是启动该集群所对应的控制循环。

 

这个控制循环每隔一定时间，就会执行一次下面的 Diff 流程。

 

首先，控制循环要获取到所有正在运行的、属于这个 Cluster 的 Pod 数量，也就是该 Etcd 集群的"实际状态"。

 

而这个 Etcd 集群的"期望状态"，正是用户在 EtcdCluster 对象里定义的 size。

 

所以接下来，控制循环会对比这两个状态的差异。

 

如果实际的 Pod 数量不够，那么控制循环就会执行一个添加成员节点的操作（即：上述流程图中的 addOneMember 方法）；反之，就执行删除成员节点的操作（即：上述流程图中的 removeOneMember 方法）。

 

以 addOneMember 方法为例，它执行的流程如下所示：

 

生成一个新节点的 Pod 的名字，比如：example-etcd-cluster-v6v6s6stxd；

 

调用 Etcd Client，执行前面提到过的 etcdctl member add example-etcd-cluster-v6v6s6stxd 命令；

 

使用这个 Pod 名字，和已经存在的所有节点列表，组合成一个新的 initial-cluster 字段的值；

 

使用这个 initial-cluster 的值，生成这个 Pod 里 Etcd 容器的启动命令。如下所示：

 

/usr/local/bin/etcd

 --data-dir=/var/etcd/data

 --name=example-etcd-cluster-v6v6s6stxd

 --initial-advertise-peer-urls=http://example-etcd-cluster-v6v6s6stxd.example-etcd-cluster.default.svc:2380

 --listen-peer-urls=http://0.0.0.0:2380

 --listen-client-urls=http://0.0.0.0:2379

 --advertise-client-urls=http://example-etcd-cluster-v6v6s6stxd.example-etcd-cluster.default.svc:2379

 --initial-cluster=example-etcd-cluster-mbzlg6sd56=http://example-etcd-cluster-mbzlg6sd56.example-etcd-cluster.default.svc:2380,example-etcd-cluster-v6v6s6stxd=http://example-etcd-cluster-v6v6s6stxd.example-etcd-cluster.default.svc:2380

 --initial-cluster-state=existing

这样，当这个容器启动之后，一个新的 Etcd 成员节点就被加入到了集群当中。控制循环会重复这个过程，直到正在运行的 Pod 数量与 EtcdCluster 指定的 size 一致。

 

在有了这样一个与 EtcdCluster 对象一一对应的控制循环之后，你后续对这个 EtcdCluster 的任何修改，比如：修改 size 或者 Etcd 的 version，它们对应的更新事件都会由这个 Cluster 对象的控制循环进行处理。

 

以上，就是一个 Etcd Operator 的工作原理了。

 

如果对比一下 Etcd Operator 与我在第 20 篇文章《深入理解 StatefulSet（三）：有状态应用实践》中讲解过的 MySQL StatefulSet 的话，你可能会有两个问题。

 

第一个问题是，在 StatefulSet 里，它为 Pod 创建的名字是带编号的，这样就把整个集群的拓扑状态固定了下来（比如：一个三节点的集群一定是由名叫 web-0、web-1 和 web-2 的三个 Pod 组成）。可是，在 Etcd Operator 里，为什么我们使用随机名字就可以了呢？

 

这是因为，Etcd Operator 在每次添加 Etcd 节点的时候，都会先执行 etcdctl member add <Pod 名字 >；每次删除节点的时候，则会执行 etcdctl member remove <Pod 名字 >。这些操作，其实就会更新 Etcd 内部维护的拓扑信息，所以 Etcd Operator 无需在集群外部通过编号来固定这个拓扑关系。

 

第二个问题是，为什么我没有在 EtcdCluster 对象里声明 Persistent Volume？

 

难道，我们不担心节点宕机之后 Etcd 的数据会丢失吗？

 

我们知道，Etcd 是一个基于 Raft 协议实现的高可用 Key-Value 存储。根据 Raft 协议的设计原则，当 Etcd 集群里只有半数以下（在我们的例子里，小于等于一个）的节点失效时，当前集群依然可以正常工作。此时，Etcd Operator 只需要通过控制循环创建出新的 Pod，然后将它们加入到现有集群里，就完成了"期望状态"与"实际状态"的调谐工作。这个集群，是一直可用的 。

 

备注：关于 Etcd 的工作原理和 Raft 协议的设计思想，你可以阅读这篇文章来进行学习。

 

但是，当这个 Etcd 集群里有半数以上（在我们的例子里，大于等于两个）的节点失效的时候，这个集群就会丧失数据写入的能力，从而进入"不可用"状态。此时，即使 Etcd Operator 创建出新的 Pod 出来，Etcd 集群本身也无法自动恢复起来。

 

这个时候，我们就必须使用 Etcd 本身的备份数据来对集群进行恢复操作。

 

在有了 Operator 机制之后，上述 Etcd 的备份操作，是由一个单独的 Etcd Backup Operator 负责完成的。

 

创建和使用这个 Operator 的流程，如下所示：

 

\# 首先，创建 etcd-backup-operator

$ kubectl create -f example/etcd-backup-operator/deployment.yaml

 

\# 确认 etcd-backup-operator 已经在正常运行

$ kubectl get pod

NAME                   READY   STATUS   RESTARTS  AGE

etcd-backup-operator-1102130733-hhgt7  1/1    Running  0      3s

 

\# 可以看到，Backup Operator 会创建一个叫 etcdbackups 的 CRD

$ kubectl get crd

NAME                   KIND

etcdbackups.etcd.database.coreos.com   CustomResourceDefinition.v1beta1.apiextensions.k8s.io

 

\# 我们这里要使用 AWS S3 来存储备份，需要将 S3 的授权信息配置在文件里

$ cat $AWS_DIR/credentials

[default]

aws_access_key_id = XXX

aws_secret_access_key = XXX

 

$ cat $AWS_DIR/config

[default]

region = <region>

 

\# 然后，将上述授权信息制作成一个 Secret

$ kubectl create secret generic aws --from-file=$AWS_DIR/credentials --from-file=$AWS_DIR/config

 

\# 使用上述 S3 的访问信息，创建一个 EtcdBackup 对象

$ sed -e 's|<full-s3-path>|mybucket/etcd.backup|g' \

  -e 's|<aws-secret>|aws|g' \

  -e 's|<etcd-cluster-endpoints>|"http://example-etcd-cluster-client:2379"|g' \

  example/etcd-backup-operator/backup_cr.yaml \

  | kubectl create -f -

需要注意的是，每当你创建一个 EtcdBackup 对象（backup_cr.yaml），就相当于为它所指定的 Etcd 集群做了一次备份。EtcdBackup 对象的 etcdEndpoints 字段，会指定它要备份的 Etcd 集群的访问地址。

所以，在实际的环境里，我建议你把最后这个备份操作，编写成一个 Kubernetes 的 CronJob 以便定时运行。

而当 Etcd 集群发生了故障之后，你就可以通过创建一个 EtcdRestore 对象来完成恢复操作。当然，这就意味着你也需要事先启动 Etcd Restore Operator。

这个流程的完整过程，如下所示：

\# 创建 etcd-restore-operator
```
$ kubectl create -f example/etcd-restore-operator/deployment.yaml
```

\# 确认它已经正常运行
```
$ kubectl get pods

NAME                   READY   STATUS   RESTARTS  AGE

etcd-restore-operator-4203122180-npn3g  1/1    Running  0      7s
```

\# 创建一个 EtcdRestore 对象，来帮助 Etcd Operator 恢复数据，记得替换模板里的 S3 的访问信息

$ sed -e 's|<full-s3-path>|mybucket/etcd.backup|g' \

  -e 's|<aws-secret>|aws|g' \

  example/etcd-restore-operator/restore_cr.yaml \

  | kubectl create -f -

上面例子里的 EtcdRestore 对象（restore_cr.yaml），会指定它要恢复的 Etcd 集群的名字和备份数据所在的 S3 存储的访问信息。

而当一个 EtcdRestore 对象成功创建后，Etcd Restore Operator 就会通过上述信息，恢复出一个全新的 Etcd 集群。然后，Etcd Operator 会把这个新集群直接接管过来，从而重新进入可用的状态。

EtcdBackup 和 EtcdRestore 这两个 Operator 的工作原理，与 Etcd Operator 的实现方式非常类似。所以，这一部分就交给你课后去探索了。

总结
在今天这篇文章中，我以 Etcd Operator 为例，详细介绍了一个 Operator 的工作原理和编写过程。

可以看到，Etcd 集群本身就拥有良好的分布式设计和一定的高可用能力。在这种情况下，StatefulSet"为 Pod 编号"和"将 Pod 同 PV 绑定"这两个主要的特性，就不太有用武之地了。

而相比之下，Etcd Operator 把一个 Etcd 集群，抽象成了一个具有一定"自治能力"的整体。而当这个"自治能力"本身不足以解决问题的时候，我们可以通过两个专门负责备份和恢复的 Operator 进行修正。这种实现方式，不仅更加贴近 Etcd 的设计思想，也更加编程友好。

不过，如果我现在要部署的应用，既需要用 StatefulSet 的方式维持拓扑状态和存储状态，又有大量的编程工作要做，那我到底该如何选择呢？

其实，Operator 和 StatefulSet 并不是竞争关系。你完全可以编写一个 Operator，然后在 Operator 的控制循环里创建和控制 StatefulSet 而不是 Pod。比如，业界知名的Prometheus 项目的 Operator，正是这么实现的。

此外，CoreOS 公司在被 RedHat 公司收购之后，已经把 Operator 的编写过程封装成了一个叫作Operator SDK的工具（整个项目叫作 Operator Framework），它可以帮助你生成 Operator 的框架代码。感兴趣的话，你可以试用一下。

思考题
在 Operator 的实现过程中，我们再一次用到了 CRD。可是，你一定要明白，CRD 并不是万能的，它有很多场景不适用，还有性能瓶颈。你能列举出一些不适用 CRD 的场景么？你知道造成 CRD 性能瓶颈的原因主要在哪里么？

# 存储管理详解
官方地址：https://kubernetes.io/docs/concepts/storage/volumes/

## 本地存储
3种：

hostPath

local

emptyDir

为什么需要本地存储？
1. 特殊使用场景需求，如需要个临时存储空间，运行cAdvisor需要能访问到node节点/sys/fs/cgroup的数据，做本机单节点的k8s环境功能测试等等。

2. 容器集群只是做小规模部署，满足开发测试、集成测试需求。

3. 作为分布式存储服务的一种补充手段，比如我在一台node主机上插了块SSD，准备给某个容器吃小灶。

4.目前主流的两个容器集群存储解决方案是ceph和glusterfs，二者都是典型的网络分布式存储，所有的数据读、写都是对磁盘IO和网络IO的考验，所以部署存储集群时至少要使用万兆的光纤网卡和光纤交换机。如果你都没有这些硬货的话，强上分布式存储方案的结果就是收获一个以”慢动作”见长的容器集群啦。

5. 分布式存储集群服务的规划、部署和长期的监控、扩容与运行维护是专业性很强的工作，需要有专职的技术人员做长期的技术建设投入。

## 集群存储

secret

configMap

downwardAPI

## 远程存储

persistentClaim

nfs

gitRepo

flexVolume

rbd

cephfs

## hostPath

这种方式依赖与 node，如果 pod 被重建创建到了其他的 node，这时如果没有在新 node 上准备好 hostpath，就会出问题

  这种会把宿主机上的指定卷加载到容器之中，当然，如果 Pod 发生跨主机的重建，其内容就难保证了。

这种卷一般和DaemonSet搭配使用，用来操作主机文件，例如进行日志采集的 FLK 中的 FluentD 就采用这种方式，加载主机的容器日志目录，达到收集本主机所有日志的目的。

实例：

[root@master hostPath]# cat hostpath.yaml

```
apiVersion: v1

kind: Pod

metadata:

 name: test-pd

spec:

 containers:

 \- image: daocloud.io/library/nginx:1.7.9

  name: test-container

  volumeMounts:

  \- mountPath: /test-pd

   name: test-volume

 volumes:

 \- name: test-volume

  hostPath:

   # directory location on host

   path: /data01

   # this field is optional

   type: Directory
```

## local 
一个很新的存储类型，建议在k8s v1.10+以上的版本中使用。该local volume类型目前还只是beta版,***\*这里不做测试\****

hostPath和local对比：
1. 二者都基于node节点本地存储资源实现了容器内数据的持久化功能，都为某些特殊场景下提供了更为适用的存储解决方案;

2. 前者时间很久了，所以功能稳定，而后者因为年轻，所以功能的可靠性与稳定性还需要经历时间和案例的历练，尤其是对Block设备的支持还只是alpha版本;

3. 二者都为k8s存储管理提供了PV、PVC和StorageClass的方法实现;

4. local volume实现的StorageClass不具备完整功能，目前只支持卷的延迟绑定;

5. hostPath是单节点的本地存储卷方案，不提供任何基于node节点亲和性的pod调度管理支持;

6. local volume适用于小规模的、多节点的k8s开发或测试环境，尤其是在不具备一套安全、可靠且性能有保证的存储集群服务时;

## emptyDir
EmptyDir是一个空目录，他的生命周期和所属的 Pod 是完全一致的，那还要他做什么？EmptyDir的用处是，可以在同一 Pod 内的不同容器之间共享工作过程中产生的文件。

缺省情况下，EmptyDir 是使用主机磁盘进行存储的，也可以设置emptyDir.medium 字段的值为Memory，来提高运行速度，但是这种设置，对该卷的占用会消耗容器的内存份额。
```
apiVersion: v1

kind: Pod

metadata:

 name: test-pd

spec:

 containers:

 \- image: gcr.io/google_containers/test-webserver

  name: test-container

  volumeMounts:

  \- mountPath: /cache

   name: cache-volume

 volumes:

 \- name: cache-volume

  emptyDir: {}
```

## PV & PVC
PersistentVolume 和 PersistentVolumeClaim 提供了对存储支持的抽象，也提供了基础设施和应用之间的分界，管理员创建一系列的 PV 提供存储，然后为应用提供 PVC，应用程序仅需要加载一个 PVC，就可以进行访问。1.5版本之后又提供了 PV 的动态供应。可以不经 PV 步骤直接创建 PVC

管理存储和管理计算有着明显的不同。PersistentVolume给用户和管理员提供了一套API，抽象出存储是如何提供和消耗的细节。

PersistentVolume（持久卷，简称PV）是集群内，由管理员提供的网络存储的一部分。就像集群中的节点一样，PV也是集群中的一种资源。它的生命周期却是和使用它的Pod相互独立的。PV这个API对象，捕获了诸如NFS、ISCSI、或其他云存储系统的实现细节。

PersistentVolumeClaim（持久卷声明，简称PVC）是用户的一种存储请求。它和Pod类似，Pod消耗Node资源，而PVC消耗PV资源。Pod能够请求特定的资源（如CPU和内存）。PVC能够请求指定的大小和访问的模式（可以被映射为一次读写或者多次只读）。 

PVC允许用户消耗抽象的存储资源，用户也经常需要各种属性（如性能）的PV。集群管理员需要提供各种各样、不同大小、不同访问模式的PV，而不用向用户暴露这些volume如何实现的细节。因为这种需求，就催生出一种StorageClass资源。

StorageClass提供了一种方式，使得管理员能够描述他提供的存储的等级。集群管理员可以将不同的等级映射到不同的服务等级、不同的后端策略。

### pv和pvc的区别
PersistentVolume（持久卷）和PersistentVolumeClaim（持久卷申请）是k8s提供的两种API资源，用于抽象存储细节。管理员关注于如何通过pv提供存储功能而无需关注用户如何使用，同样的用户只需要挂载pvc到容器中而不需要关注存储卷采用何种技术实现。

pvc和pv的关系与pod和node关系类似，前者消耗后者的资源。pvc可以向pv申请指定大小的存储资源并设置访问模式,这就可以通过Provision -> Claim 的方式，来对存储资源进行控制。

### volume和claim的生命周期

PV是集群中的资源，PVC是对这些资源的请求，同时也是这些资源的“提取证”。PV和PVC的交互遵循以下生命周期：

供给
有两种PV提供的方式：静态和动态。

静态
集群管理员创建多个PV，它们携带着真实存储的详细信息，这些存储对于集群用户是可用的。它们存在于Kubernetes API中，并可用于存储使用。

动态
当管理员创建的静态PV都不匹配用户的PVC时，集群可能会尝试专门地供给volume给PVC。这种供给基于StorageClass：PVC必须请求这样一个等级，而管理员必须已经创建和配置过这样一个等级，以备发生这种动态供给的情况。请求等级配置为“”的PVC，有效地禁用了它自身的动态供给功能。

绑定
用户创建一个PVC（或者之前就已经就为动态供给创建了），指定要求存储的大小和访问模式。master中有一个控制回路用于监控新的PVC，查找匹配的PV（如果有），并把PVC和PV绑定在一起。如果一个PV曾经动态供给到了一个新的PVC，那么这个回路会一直绑定这个PV和PVC。另外，用户总是至少能得到它们所要求的存储，但是volume可能超过它们的请求。一旦绑定了，PVC绑定就是专属的，无论它们的绑定模式是什么。

如果没找到匹配的PV，那么PVC会无限期得处于unbound未绑定状态，一旦PV可用了，PVC就会又变成绑定状态。比如，如果一个供给了很多50G的PV集群，不会匹配要求100G的PVC。直到100G的PV添加到该集群时，PVC才会被绑定。

使用
Pod使用PVC就像使用volume一样。集群检查PVC，查找绑定的PV，并映射PV给Pod。对于支持多种访问模式的PV，用户可以指定想用的模式。一旦用户拥有了一个PVC，并且PVC被绑定，那么只要用户还需要，PV就一直属于这个用户。用户调度Pod，通过在Pod的volume块中包含PVC来访问PV。

释放
当用户使用PV完毕后，他们可以通过API来删除PVC对象。当PVC被删除后，对应的PV就被认为是已经是“released”了，但还不能再给另外一个PVC使用。前一个PVC的属于还存在于该PV中，必须根据策略来处理掉。

回收
PV的回收策略告诉集群，在PV被释放之后集群应该如何处理该PV。当前，PV可以被Retained（保留）、 Recycled（再利用）或者Deleted（删除）。保留允许手动地再次声明资源。对于支持删除操作的PV卷，删除操作会从Kubernetes中移除PV对象，还有对应的外部存储（如AWS EBS，GCE PD，Azure Disk，或者Cinder volume）。动态供给的卷总是会被删除。

Recycled（再利用）
如果PV卷支持再利用，再利用会在PV卷上执行一个基础的擦除操作（rm -rf /thevolume/*），使得它可以再次被其他PVC声明利用。

管理员可以通过Kubernetes controller manager的命令行工具，来配置自定义的再利用Pod模板。自定义的再利用Pod模板必须包含PV卷的详细内容，如下示例：
```
apiVersion: v1

kind: Pod

metadata:

 name: pv-recycler-

 namespace: default

spec:

 restartPolicy: Never

 volumes:

 \- name: vol

  hostPath:

   path: /any/path/it/will/be/replaced

 containers:

 \- name: pv-recycler

  image: "gcr.io/google_containers/busybox"

  command: ["/bin/sh", "-c", "test -e /scrub && rm -rf /scrub/..?* /scrub/.[!.]* /scrub/*  && test -z \"$(ls -A /scrub)\" || exit 1"]

  volumeMounts:

  \- name: vol

   mountPath: /scrub


```

如上，在volumes部分的指定路径，应该被替换为PV卷需要再利用的路径。

PV类型
PV类型使用插件的形式来实现。Kubernetes现在支持以下插件：

GCEPersistentDisk

AWSElasticBlockStore

AzureFile

AzureDisk

FC (Fibre Channel)

Flocker

NFS

iSCSI

RBD (Ceph Block Device)

CephFS

Cinder (OpenStack block storage)

Glusterfs

VsphereVolume

Quobyte Volumes

HostPath (仅测试过单节点的情况——不支持任何形式的本地存储，多节点集群中不能工作)

VMware Photon

Portworx Volumes

ScaleIO Volumes

PV介绍
每个PV都包含一个spec和状态，即说明书和PV卷的状态。
```
 apiVersion: v1

 kind: PersistentVolume

 metadata:

  name: pv0003

 spec:

  capacity:

   storage: 5Gi

  accessModes:

   \- ReadWriteOnce

  persistentVolumeReclaimPolicy: Recycle

  storageClassName: slow

  nfs:

   path: /tmp

   server: 172.17.0.2
```

Capacity（容量）
一般来说，PV会指定存储的容量，使用PV的capacity属性来设置。当前，存储大小是唯一能被设置或请求的资源。未来可能包含IOPS，吞吐率等属性。

访问模式
PV可以使用存储资源提供商支持的任何方法来映射到host中。如下的表格中所示，提供商有着不同的功能，每个PV的访问模式被设置为卷支持的指定模式。比如，NFS可以支持多个读/写的客户端，但可以在服务器上指定一个只读的NFS PV。每个PV有它自己的访问模式。

访问模式包括：
ReadWriteOnce — 该volume只能被单个节点以读写的方式映射

ReadOnlyMany — 该volume可以被多个节点以只读方式映射

ReadWriteMany — 该volume只能被多个节点以读写的方式映射

在CLI中，访问模式可以简写为：
RWO – ReadWriteOnce

ROX – ReadOnlyMany

RWX – ReadWriteMany

注意：即使volume支持很多种访问模式，但它同时只能使用一种方式来映射。比如，GCEPersistentDisk可以被单个节点映射为ReadWriteOnce，或者多个节点映射为ReadOnlyMany，但不能同时使用这两种方式来映射。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps7Qxi5D.jpg) 

Class
一个PV可以有一种class，通过设置storageClassName属性来选择指定的StorageClass。有指定class的PV只能绑定给请求该class的PVC。没有设置storageClassName属性的PV只能绑定给未请求class的PVC。

过去，使用volume.beta.kubernetes.io/storage-class注解，而不是storageClassName属性。该注解现在依然可以工作，但在Kubernetes的未来版本中已经被完全弃用了。

 

回收策略
当前的回收策略有：
Retain：手动回收
Recycle：需要擦出后才能再使用
Delete：相关联的存储资产，如AWS EBS，GCE PD，Azure Disk，or OpenStack Cinder卷都会被删除

当前，只有NFS和HostPath支持回收利用，AWS EBS，GCE PD，Azure Disk，or OpenStack Cinder卷支持删除操作。

阶段
一个volume卷处于以下几个阶段之一：
Available：空闲的资源，未绑定给PVC
Bound：绑定给了某个PVC
Released：PVC已经删除了，但是PV还没有被集群回收
Failed：PV在自动回收中失败了
CLI可以显示PV绑定的PVC名称。

映射选项
当PV被映射到一个node上时，Kubernetes管理员可以指定额外的映射选项。可以通过使用标注volume.beta.kubernetes.io/mount-options来指定PV的映射选项。

比如：
```
apiVersion: "v1"

kind: "PersistentVolume"

metadata:

 name: gce-disk-1

 annotations:

  volume.beta.kubernetes.io/mount-options: "discard"

spec:

 capacity:

  storage: "10Gi"

 accessModes:

  \- "ReadWriteOnce"

 gcePersistentDisk:

  fsType: "ext4"

  pdName: "gce-disk-1
```

映射选项是当映射PV到磁盘时，一个可以被递增地添加和使用的字符串。

注意，并非所有的PV类型都支持映射选项。在Kubernetes v1.6中，以下的PV类型支持映射选项。

GCEPersistentDisk

AWSElasticBlockStore

AzureFile

AzureDisk

NFS

iSCSI

RBD (Ceph Block Device)

CephFS

Cinder (OpenStack block storage)

Glusterfs

VsphereVolume

Quobyte Volumes

VMware Photon

PersistentVolumeClaims（PVC）
每个PVC都包含一个spec和status，即该PVC的规则说明和状态。
```
kind: PersistentVolumeClaim

apiVersion: v1

metadata:

 name: myclaim

spec:

 accessModes:

  \- ReadWriteOnce

 resources:

  requests:

   storage: 8Gi

 storageClassName: slow

 selector:

  matchLabels:

   release: "stable"

  matchExpressions:

   \- {key: environment, operator: In, values: [dev]}
```

访问模式
当请求指定访问模式的存储时，PVC使用的规则和PV相同。

资源
PVC，就像pod一样，可以请求指定数量的资源。请求资源时，PV和PVC都使用相同的资源样式。

选择器（Selector）
PVC可以指定标签选择器进行更深度的过滤PV，只有匹配了选择器标签的PV才能绑定给PVC。选择器包含两个字段：

matchLabels（匹配标签） – PV必须有一个包含该值得标签

matchExpressions（匹配表达式） – 一个请求列表，包含指定的键、值的列表、关联键和值的操作符。合法的操作符包含In，NotIn，Exists，和DoesNotExist。

所有来自matchLabels和matchExpressions的请求，都是逻辑与关系的，它们必须全部满足才能匹配上。

等级（Class）
PVC可以使用属性storageClassName来指定StorageClass的名称，从而请求指定的等级。只有满足请求等级的PV，即那些包含了和PVC相同storageClassName的PV，才能与PVC绑定。

PVC并非必须要请求一个等级。设置storageClassName为“”的PVC被理解为请求一个无等级的PV，因此它只能被绑定到无等级的PV（未设置对应的标注，或者设置为“”）。未设置storageClassName的PVC不太相同，DefaultStorageClass的权限插件打开与否，集群也会区别处理PVC。

如果权限插件被打开，管理员可能会指定一个默认的StorageClass。所有没有指定StorageClassName的PVC只能被绑定到默认等级的PV。要指定默认的StorageClass，需要在StorageClass对象中将标注storageclass.kubernetes.io/is-default-class设置为“true”。如果管理员没有指定这个默认值，集群对PVC创建请求的回应就和权限插件被关闭时一样。如果指定了多个默认等级，那么权限插件禁止PVC创建请求。

如果权限插件被关闭，那么久没有默认StorageClass的概念。所有没有设置StorageClassName的PVC都只能绑定到没有等级的PV。因此，没有设置StorageClassName的PVC就如同设置StorageClassName为“”的PVC一样被对待。

根据安装方法的不同，默认的StorageClass可能会在安装过程中被插件管理默认的部署在Kubernetes集群中。

当PVC指定selector来请求StorageClass时，所有请求都是与操作的。只有满足了指定等级和标签的PV才可能绑定给PVC。当前，一个非空selector的PVC不能使用PV动态供给。

过去，使用volume.beta.kubernetes.io/storage-class注解，而不是storageClassName属性。该注解现在依然可以工作，但在Kubernetes的未来版本中已经被完全弃用了。

使用PVC
Pod通过使用PVC（使用方式和volume一样）来访问存储。PVC必须和使用它的pod在同一个命名空间，集群发现pod命名空间的PVC，根据PVC得到其后端的PV，然后PV被映射到host中，再提供给pod。
```
kind: Pod

apiVersion: v1

metadata:

 name: mypod

spec:

 containers:

  \- name: myfrontend

   image: dockerfile/nginx

   volumeMounts:

   \- mountPath: "/var/www/html"

​    name: mypd

 volumes:

  \- name: mypd

   persistentVolumeClaim:

​    claimName: myclaim
```
命名空间注意事项
PV绑定是独有的，因为PVC是命名空间对象，映射PVC时只能在同一个命名空间中使用多种模式（ROX，RWX）。

StorageClass
每个StorageClass都包含字段provisioner和parameters，在所属的PV需要动态供给时使用这些字段。

StorageClass对象的命名是非常重要的，它是用户请求指定等级的方式。当创建StorageClass对象时，管理员设置等级的名称和其他参数，但对象不会在创建后马上就被更新。

管理员可以指定一个默认的StorageClass，用于绑定到那些未请求指定等级的PVC。
```
kind: StorageClass

apiVersion: storage.k8s.io/v1

metadata:

 name: standard

provisioner: kubernetes.io/aws-ebs

parameters:

 type: gp2
```
Provisioner
StorageClass都有存储供应商provisioner，用来决定哪种volume插件提供给PV使用。必须制定该字段。

你不限于指定此处列出的“内部”供应商（其名称前缀为“kubernetes.io”并与Kubernetes一起分发）。你还可以运行和指定外部供应商，它们是遵循Kubernetes定义的规范的独立程序。外部提供者的作者对代码的生命周期，供应商的分发方式，运行状况以及使用的卷插件（包括Flex）等都有充分的自主权。库kubernetes-incubator/external-storage存放了一个库，用于编写外部存储供应商，而这些提供者实现了大量的规范，并且是各种社区维护的。

参数
StorageClass有一些参数用于描述归属于该StorageClass的volume。不同的存储提供商可能需要不同的参数。比如，参数type对应的值io1，还有参数iopsPerGB，都是EBS专用的参数。当参数省略时，就会使用它的默认值。

AWS

 

…

 

GCE

 

…

 

Glusterfs

 

…

 

OpenStack Cinder

 

…

 

vSphere

 

…

 

Ceph RBD

 

 apiVersion: storage.k8s.io/v1

 kind: StorageClass

 metadata:

  name: fast

 provisioner: kubernetes.io/rbd

 parameters:

  monitors: 10.16.153.105:6789

  adminId: kube

  adminSecretName: ceph-secret

  adminSecretNamespace: kube-system

  pool: kube

  userId: kube

  userSecretName: ceph-secret-user

monitors：Ceph的monitor，逗号分隔。该参数是必须的。

adminId：Ceph的客户端ID，可在pool中创建镜像。默认的是“admin”。

adminSecretNamespace：adminSecret的命名空间，默认值是“default”。

adminSecretName：adminId的Secret Name。改参数是必须的，提供的秘钥必须有类型“kubernetes.io/rbd”。

pool：Ceph的RBD pool，默认值是“rbd”。

userId：Ceph的客户ID，用于映射RBD镜像的，默认值和adminId参数相同。

userSecretName：Ceph Secret的名称，userId用该参数来映射RBD镜像。它必须和PVC在相同的命名空间。该参数也是必须的。提供的秘钥必须有类型“kubernetes.io/rbd”。比如，按照下面的方式来创建：

$ kubectl create secret generic ceph-secret --type="kubernetes.io/rbd" --from-literal=key='QVFEQ1pMdFhPUnQrSmhBQUFYaERWNHJsZ3BsMmNjcDR6RFZST0E9PQ==' --namespace=kube-system

Quobyte

 

…

 

Azure Disk

 

…

 

Portworx Volume

 

…

 

ScaleIO

 

…

 

配置
如果你在写配置模板和示例，用于在需要持久化存储的集群中使用，那么，我们建议你使用以下的一些模式：

在你的捆绑配置（如Deployment、ConfigMap胖）中包含PVC对象。

在配置中不要包含PersistentVolume对象，因为实例化配置的用户可能没有创建PersistentVolumes的权限

当用户提供实例化模板时，给用户提供存储类名称的选项。

如果用户提供了一个StorageClass名称，并且Kubernetes版本是1.4及以上，那么将该值设置在PVC的volume.beta.kubernetes.io/storage-class标注上。这会使得PVC匹配到正确的StorageClass。

如果用户没有提供StorageClass名称，或者集群版本是1.3，那么就需要在PVC配置中设置volume.alpha.kubernetes.io/storage-class: default标注。

— 这会使得在一些默认配置健全的集群中，PV可以动态的提供给用户。

— 尽管在名称中包含了alpha单词，但是该标注对应的代码有着beta级别的支持。

— 不要使用volume.beta.kubernetes.io/storage-class，无论设置什么值，甚至是空字符串。因为它会阻止DefaultStorageClass许可控制器。

在你的工具中，要监视那些一段时间后还没有获得绑定的PVC，并且展示给用户。因为这可能表明集群没有支持动态存储（此时我们应该创建匹配的PV），或者集群没有存储系统（此时用户不能部署需要PVC的情况）。

存储如何挂载到POD里面？

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsG30rA1.jpg) 

NFS：
  不支持动态创建持久卷，只能手工创建
  先手工创建PV，再通过PV手工创建PVC，PVC就是真正可用的持久卷

PVC是和PV进行绑定的：
PVC会根据自己需求空间的大小自动选择合适的PV，比如需要一个5G的PVC，PV分别为2G，7G和10G，那么PVC会自动选择7G的，但是剩余的空间不是浪费了么？原因如下：

 一个被绑定的PV只能用于一个PVC，他们是一对一绑定的，如果PVC大小只需要5G，但是所选的PV有7G，那么剩余的2G是没办法使用的，如果不想这样浪费空间只能使用动态创建的方式

ceph、glusterfs、云硬盘：
  支持动态创建持久卷
  动态创建持久卷的时候也是需要手动创建PV，但是PVC是不用手工创建的，PVC会自动从PV上拿取空间

### 配置Pod以使用PersistentVolume进行存储
过程的摘要：
1. 集群管理员创建由物理存储支持的PersistentVolume。管理员不会将卷与任何Pod关联。
2. 集群用户创建PersistentVolumeClaim，它会自动绑定到合适的PersistentVolume。
3. 用户创建一个使用PersistentVolumeClaim作为存储的Pod。

具体步骤：

1. 在你的节点上创建index.html文件
2. 创建PersistentVolume
3. 创建PersistentVolumeClaim
4. 创建一个Pod
5. 访问控制

实现过程：

1. 在你的节点上创建index.html文件
```
\# mkdir /test/pv/data

\# echo 'Hello from Kubernetes storage' > /test/pv/data/index.html
```
2. 创建PersistentVolume
本练习中，您将创建hostPath PersistentVolume。Kubernetes支持hostPath在单节点集群上进行开发和测试。hostPath PersistentVolume使用节点上的文件或目录来模拟网络附加存储。

在生产群集中，您不会使用hostPath。相反，集群管理员可以配置网络资源，如Google Compute Engine永久磁盘，NFS共享或Amazon Elastic Block Store卷。群集管理员还可以使用StorageClasses 来设置 动态配置。
\# vim pv-volume.yaml 
```
apiVersion: v1

kind: PersistentVolume

metadata:

 name: task-pv-volume

 labels:

  type: local

spec:

 storageClassName: manual

 capacity:

  storage: 1Gi

 accessModes:

  \- ReadWriteOnce

 hostPath:

  path: "/test/pv/data"
```
注：
PersistentVolume 的StorageClass名称 manual，该名称将用于将PersistentVolumeClaim请求绑定到此PersistentVolume。

\# kubectl  apply -f pv-volume.yaml

3. 创建PersistentVolumeClaim

\# vim pv-claim.yaml 
```
apiVersion: v1

kind: PersistentVolumeClaim

metadata:

 name: task-pv-claim

spec:

 storageClassName: manual

 accessModes:

  \- ReadWriteOnce

 resources:

  requests:

   storage: 200Mi
```

4. 创建一个Pod

5. 访问控制

## NFS持久卷应用实例
nfs安装 
我这里是用NODE1提供NFS服务，生产环境要独立
```
\# yum -y install nfs-utils rpcbind
```

这里是做多个NFS目录用于挂载，因为一个PVC取消一个PV的绑定之后，原来的PV还是不能被其他PVC使用的
```
\# mkdir /data/{nfs1,nfs2,nfs3,nfs4,nfs5,nfs6,nfs7,nfs8,nfs9,nfs10} -pv && chmod 777 /data/nfs*
```

\# vim /etc/exports  //wing拿node2(192.168.1.208)做的nfs服务，这里就写了一条带IP的，其他偷懒用的*

/data/nfs1 192.168.1.208/24(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash) 

/data/nfs2 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash) 

/data/nfs3 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash) 

/data/nfs4 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash) 

/data/nfs5 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

/data/nfs6 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

/data/nfs7 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

/data/nfs8 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

/data/nfs9 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

/data/nfs10 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

 

• rw:read-write，可读写

• async:文件暂存于内存，而不是直接写入硬盘;

• anonuid:匿名用户的UID值

• anongid:匿名用户的GID值。注:其中anonuid=1000,anongid=1000,为此目录用户web的ID号,达到连接

NFS用户权限一致。

• insecure: 需要设置，否则挂载无权限

• no_root_squash:NFS客户端连接服务端时如果使用的是root的话，那么对服务端分享的目录来说，也

拥有root权限。显然开启这项是不安全的。

\# exportfs -rv

\# systemctl enable rpcbind nfs-server

\# systemctl start nfs-server rpcbind

\# rpcinfo -p

 

持久卷的运用
可以使用下面的explain子命令去查看学习pv的使用方法，这里不是要大家操作的,这些命令直接回车会看到帮助
```
\# kubectl explain PersistentVolume

\# kubectl explain PersistentVolume.spec

\# kubectl explain PersistentVolume.spec.accessModes
```

使用YAML文件创建PV和PVC（如果你用的wing的yaml文件，要注意修改里面的内容）

\# cat volume/nfs-pv.yml  //内容在子目录
```
apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv001

 labels:

  name: pv001

spec:

 nfs:

  path: /data/nfs1

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv002

 labels:

  name: pv002

spec:

 nfs:

  path: /data/nfs2

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv003

 labels:

  name: pv003

spec:

 nfs:

  path: /data/nfs3

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv004

 labels:

  name: pv004

spec:

 nfs:

  path: /data/nfs4

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv005

 labels:

  name: pv005

spec:

 nfs:

  path: /data/nfs5

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv006

 labels:

  name: pv006

spec:

 nfs:

  path: /data/nfs6

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv007

 labels:

  name: pv007

spec:

 nfs:

  path: /data/nfs7

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 2Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv008

 labels:

  name: pv008

spec:

 nfs:

  path: /data/nfs8

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv009

 labels:

  name: pv009

spec:

 nfs:

  path: /data/nfs9

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv010

 labels:

  name: pv010

spec:

 nfs:

  path: /data/nfs10

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi
```

```
[root@master volume]# kubectl apply -f nfs-pv.yml --record

persistentvolume/pv001 created

persistentvolume/pv002 created

persistentvolume/pv003 created

persistentvolume/pv004 created

persistentvolume/pv005 created

persistentvolume/pv006 created

persistentvolume/pv007 created

persistentvolume/pv008 created

persistentvolume/pv009 created

persistentvolume/pv010 created
```

```
[root@master volume]# kubectl  get pv

NAME   CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS    CLAIM  STORAGECLASS  REASON  AGE

pv001  1Gi     RWO,RWX     Retain      Available                  16s

pv002  1Gi     RWO,RWX     Retain      Available                  16s

pv003  1Gi     RWO,RWX     Retain      Available                  16s

pv004  1Gi     RWO,RWX     Retain      Available                  16s

pv005  1Gi     RWO,RWX     Retain      Available                  16s

pv006  1Gi     RWO,RWX     Retain      Available                  16s

pv007  2Gi     RWO,RWX     Retain      Available                  16s

pv008  1Gi     RWO,RWX     Retain      Available                  16s

pv009  1Gi     RWO,RWX     Retain      Available                  16s

pv010  1Gi     RWO,RWX     Retain      Available                  16s
```

\# cat volume/nfs-pvc.yml
```
apiVersion: v1

kind: PersistentVolumeClaim

metadata:

 name: mypvc

 namespace: default

spec:

 accessModes: ["ReadWriteMany"]

 resources:

  requests:

   storage: 2Gi
```

```
[root@master volume]# kubectl apply -f nfs-pvc.yml --record

persistentvolumeclaim/mypvc created

[root@master volume]# kubectl  get pvc

NAME   STATUS  VOLUME  CAPACITY  ACCESS MODES  STORAGECLASS  AGE

mypvc  Bound   pv007   2Gi     RWO,RWX            5s
```

用nginx应用测试PVC

\# cat volume/nginx-pvc.yml // 运行pod的节点必须安装 nfs-utils
```
apiVersion: v1

kind: Pod

metadata:

 name: nginx-vol-pvc

 namespace: default

spec:

 containers:

 \- name: mywww

  image: daocloud.io/library/nginx

  volumeMounts:

  \- name: www

   mountPath: /usr/share/nginx/html

 volumes:

 \- name: www

  persistentVolumeClaim:

   claimName: mypvc
```

```
\# kubectl apply -f volume/nginx-pvc.yml

pod/nginx-vol-pvc created
```

```
\# kubectl exec -it nginx-vol-pvc -- sh

\# echo "hello,world! I am wing" > /usr/share/nginx/html/index.html 

\# exit
```

访问测试：
```
\# curl http://PodIP:80
```
```
[root@master volume]# kubectl  get pod -o wide

NAME             READY  STATUS    RESTARTS  AGE   IP        NODE   NOMINATED NODE  READINESS GATES

nginx-vol-pvc        1/1   Running   0      91s   10.244.1.217   node1  <none>      <none>
```

```
\# curl 10.244.1.217

hello,world! I am wing
```


也可以直接去修改NFS：
```
[root@node2 data]# ls

nfs1  nfs10  nfs2  nfs3  nfs4  nfs5  nfs6  nfs7  nfs8  nfs9

[root@node2 data]# cd nfs7

[root@node2 nfs7]# ls

index.html

[root@node2 nfs7]# echo also can write con to here > index.html 

[root@node2 nfs7]# curl 10.244.1.217

also can write con to here
```

删除PVC和PV
虽然可以删掉pvc把状态变成released(释放状态)，但是记录状态里面还是有的，其他的PVC还是不能调用删掉的PV，这是NFS的缺点，没办法解决的
````
\# kubectl delete -f nginx-pvc.yml 

\# kubectl delete -f nfs-pv.yml
```

### NFS-PV.YML

[root@master volume]# cat nfs-pv.yml 
```
apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv001

 labels:

  name: pv001

spec:

 nfs:

  path: /data/nfs1

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv002

 labels:

  name: pv002

spec:

 nfs:

  path: /data/nfs2

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv003

 labels:

  name: pv003

spec:

 nfs:

  path: /data/nfs3

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv004

 labels:

  name: pv004

spec:

 nfs:

  path: /data/nfs4

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv005

 labels:

  name: pv005

spec:

 nfs:

  path: /data/nfs5

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv006

 labels:

  name: pv006

spec:

 nfs:

  path: /data/nfs6

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv007

 labels:

  name: pv007

spec:

 nfs:

  path: /data/nfs7

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 2Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv008

 labels:

  name: pv008

spec:

 nfs:

  path: /data/nfs8

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv009

 labels:

  name: pv009

spec:

 nfs:

  path: /data/nfs9

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv010

 labels:

  name: pv010

spec:

 nfs:

  path: /data/nfs10

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi
```

## 自动伸缩+SIDECAR（扩展未测）

在伸缩中使用 Deployments 运行有状态服务 

\# cat stateful/go-demo-3-deploy.yml

\# kubectl apply -f go-demo-3-deploy.yml --record

\# kubectl -n go-demo-3 rollout status deployment api // api部署成功，db不成功

\# kubectl get pods -n go-demo-3 // db只有一个成功，因为 MongoDB无法锁定 /data/db/mongod.lock 文件

DB1= $(kubectl -n go-demo-3 get pods -l app=db -o jsonpath=“{.items[0].metadata.name}”) DB2= $(kubectl -n go-demo-3 get pods -l app=db -o jsonpath=“{.items[1].metadata.name}”)

\# kubectl -n go-demo-3 logs $DB_1 # kubectl -n go-demo-3 logs $DB_2

 // DB_1 输出

 // DB_2 输出

 \# kubectl get pv // 只绑定一个持久卷 # kubectl get pvc -n go-demo-3

\# kubectl delete ns go-demo-3 注意:下面就会讲解 StatefulSet 的好处

 kuberctl

   Kubernetes Cluster

 db Deployment

db ReplicaSet

db Pods db Pods db Pods

mongo PVC

db PV

PVC    

 \2. 3 在伸缩中使用 StatefulSets 运行有状态服务 # cat stateful/go-demo-3-sts.yml

唯一重要的区别是我们没有定义 PersistentVolumeClaim 作为一个单独的资源，而是让 StatefulSet 通过容积 volumeClaimTemplates 条目中的规范集来处理它。

还有 service一个区别:定义无头服务

 \# kubectl apply -f stateful/go-demo-3-sts.yml --record

\# kubectl -n go-demo-3 get pods // 多刷新几次，看一下状态，最后应该是 api失败(后续解决)，db正常

我们刚刚观察到的是 Deployments 和StatefulSets 之间的区别。后者的副本是按顺序创建的。只有在第一个副本运行之 后，状态集开始创建第二个副本。类似地，第三个开始是在第二次运行之后才开始的。

此外，我们还可以看到通过statset创建的Pods的名称是可预测的。不同于为每个荚体创建随机后缀的部署，状态集用 基于整数序数的索引后缀来创建它们。第一个Pod的名称总是以-0结束后缀，第二个是后缀为-1，以此类推。这种命名 将永远保持下去。如果我们启动滚动更新，Kubernetes将取代db statset的pod，但是名称将保持不变。

Pods的顺序创建和名称的格式的本质提供了可预测性，这在有状态应用程序中通常是最重要的。我们可以将statset副 本看作是独立的，具有保证的顺序、惟一性和可预测性。

PersistentVolumes怎么样?db pod没有失败的事实意味着 MongoDB实例设法获得了锁。这意味着它们没有共享相同的持 久容量，或者它们在同一卷中使用不同的目录。

\# kubectl get pv

\# kubectl get pvc -n go-demo-3

  kuberctl

  Kubernetes Cluster

  db StatefulSet

db ReplicaSet

db Pods db Pods

db PV

db PV

mongo PVC mongo PVC

​     db PV

mongo PVC

​     db Pods

PVC
 \# kubectl -n go-demo-3 exec -it db-0 -- hostname // 输出为 db-0 我们将通过创建一个新的Pod来探索将StatefulSets与Headless服务组合在一起的效果，从中我们可以执行nslookup命

令。

\# kubectl -n go-demo-3 run -it --image busybox dns-test --restart=Never --rm sh /# nslookup db // 解析会有三个

/# nslookup db-0.db // pod名称和 Statefulset组合

// busybox bug问题，无法解析

// 配置 Mongo集群

\# kubectl -n go-demo-3 exec -it db-0 -- sh

/# mongo // 初始化要注意，由于挂载nfs,首先要确保nfs节点上无数据

 /# rs.status()

 /# exit

\# kubectl -n go-demo-3 get pods

\# diff stateful/go-demo-3-sts.yml stateful/go-demo-3-sts-upd.yml # kubectl apply -f stateful/go-demo-3-sts-upd.yml --record

\# kubectl -n go-demo-3 get pods

状态集中的豆荚按反向顺序更新。StatefulSet 终止了一个豆荚，它等待着它的状态变成运行状态后，继续下一个。

总之，在创建StatefulSet时，它依次从索引0开始依次生成pod，然后向上移动。对StatefulSet的更新遵循相同的逻 辑，除了StatefulSet用索引最高的Pod开始更新，它向下流动。

 2. 4 使用 Sidecar 容器初始化应用程序
尽管我们成功地使用三个实例部署了MongoDB副本集，但这个过程远远不是最佳的。我们必须执行手动步骤。因为 我不相信人工的欺骗式干预是可行的，我们将通过消除人类互动来改善这个过程。我们将通过 sidecar 容器来实现这 一点，它将负责创建MongoDB副本集(不要与Kubernetes ReplicaSet 混淆)。

\# cat stateful/go-demo-3.yml

与 sts/go-demo-3-sts.yml 相比。唯一的区别是在 StatefulSet db中 添加了第二个容器。它是基于 cvallance/mongo-k8s-

sidecar Docker图像。它创建和维护MongoDB副本集。 # kubectl apply -f sts/go-demo-3.yml --record

\# kubectl -n go-demo-3 logs db-0 -c db-sidecar

sidecar 不能列出这些豆荚是不足为奇的。如果可以的话，RBAC或多或少都是无用的。如果任何Pod可以绕过这个限 制，那么限制用户可以创建哪些资源并不重要。后面会介绍使用 RBAC

从 Side-Car 容器中使用 ServiceAccounts

我们还有一个悬而未决的问题可以通过ServiceAccounts解决。在上面，我们尝试使用 cvallance/mongo-k8s-sidecar 容器，希望它能够动态地创建和管理MongoDB副本集。我们失败了，因为在那个时候，我们不知道如何创建足够的权 限来允许 Side-Car 完成它的工作。现在我们清楚了。
```
\# cat serviceaccount/go-demo-3.yml

\# kubectl apply -f serviceaccount/go-demo-3.yml --record

\# kubectl -n go-demo-3 get pods

\# kubectl -n go-demo-3 logs db-0 -c db-sidecar // 从日志看出，没有报错 # kubectl delete ns go-demo-3
```
# 容器持久化存储的核心原理(需要GO编程)
容器化一个应用比较麻烦的地方，莫过于对其"状态"的管理。而最常见的"状态"，又莫过于存储状态了。

PV:
持久化存储数据卷。这个 API 对象主要定义的是一个持久化存储在宿主机上的目录，比如一个 NFS 的挂载目录。

  通常，PV 对象是由运维人员事先创建在 k8s 集群里待用的。

PVC：
是 Pod 所希望使用的持久化存储的属性。比如，Volume 存储的大小、可读写权限等等。

PVC 对象通常由开发人员创建；或者以 PVC 模板的方式成为 StatefulSet 的一部分，然后由 StatefulSet 控制器负责创建带编号的 PVC。

比如，开发人员可以声明一个 1 GiB 大小的 PVC，如下所示：
```
apiVersion: v1

kind: PersistentVolumeClaim

metadata:

 name: nfs

spec:

 accessModes:

  \- ReadWriteMany

 storageClassName: manual

 resources:

  requests:

   storage: 1Gi
```
而用户创建的 PVC 要真正被容器使用起来，就必须先和某个符合条件的 PV 进行绑定。这里要检查的条件，包括两部分：

第一个条件，当然是 PV 和 PVC 的 spec 字段。比如，PV 的存储（storage）大小，就必须满足 PVC 的要求。

而第二个条件，则是 PV 和 PVC 的 storageClassName 字段必须一样。这个机制我会在本篇文章的最后一部分专门介绍。

在成功地将 PVC 和 PV 进行绑定之后，Pod 就能够像使用 hostPath 等常规类型的 Volume 一样，在自己的 YAML 文件里声明使用这个 PVC 了，如下所示：
```
apiVersion: v1

kind: Pod

metadata:

 labels:

  role: web-frontend

spec:

 containers:

 \- name: web

  image: nginx

  ports:

   \- name: web

​    containerPort: 80

  volumeMounts:

​    \- name: nfs

​     mountPath: "/usr/share/nginx/html"

 volumes:

 \- name: nfs

  persistentVolumeClaim:

   claimName: nfs
```
可以看到，Pod 需要做的，就是在 volumes 字段里声明自己要使用的 PVC 名字。接下来，等这个 Pod 创建之后，kubelet 就会把这个 PVC 所对应的 PV，也就是一个 NFS 类型的 Volume，挂载在这个 Pod 容器内的目录上。

不难看出，PVC 和 PV 的设计，其实跟"面向对象"的思想完全一致。

PVC 可以理解为持久化存储的"接口"，它提供了对某种持久化存储的描述，但不提供具体的实现；而这个持久化存储的实现部分则由 PV 负责完成。

这样做的好处是，作为应用开发者，我们只需要跟 PVC 这个"接口"打交道，而不必关心具体的实现是 NFS 还是 Ceph。毕竟这些存储相关的知识太专业了，应该交给专业的人去做。

而在上面的讲述中，其实还有一个比较棘手的情况。

比如，你在创建 Pod 的时候，系统里并没有合适的 PV 跟它定义的 PVC 绑定，也就是说此时容器想要使用的 Volume 不存在。这时候，Pod 的启动就会报错。

但是，过了一会儿，运维人员也发现了这个情况，所以他赶紧创建了一个对应的 PV。这时候，我们当然希望 Kubernetes 能够再次完成 PVC 和 PV 的绑定操作，从而启动 Pod。

所以在 Kubernetes 中，实际上存在着一个专门处理持久化存储的控制器，叫作 Volume Controller。这个 Volume Controller 维护着多个控制循环，其中有一个循环，扮演的就是撮合 PV 和 PVC 的"红娘"的角色。它的名字叫作 PersistentVolumeController。

PersistentVolumeController 会不断地查看当前每一个 PVC，是不是已经处于 Bound（已绑定）状态。如果不是，那它就会遍历所有的、可用的 PV，并尝试将其与这个"单身"的 PVC 进行绑定。这样，Kubernetes 就可以保证用户提交的每一个 PVC，只要有合适的 PV 出现，它就能够很快进入绑定状态，从而结束"单身"之旅。

而所谓将一个 PV 与 PVC 进行"绑定"，其实就是将这个 PV 对象的名字，填在了 PVC 对象的 spec.volumeName 字段上。所以，接下来 Kubernetes 只要获取到这个 PVC 对象，就一定能够找到它所绑定的 PV。

那么，这个 PV 对象，又是如何变成容器里的一个持久化存储的呢？

我在前面讲解容器基础的时候，已经为你详细剖析了容器 Volume 的挂载机制。用一句话总结，所谓容器的 Volume，其实就是将一个宿主机上的目录，跟一个容器里的目录绑定挂载在了一起。（你可以借此机会，再回顾一下专栏的第 8 篇文章《白话容器基础（四）：重新认识 Docker 容器》中的相关内容）

而所谓的"持久化 Volume"，指的就是这个宿主机上的目录，具备"持久性"。即：这个目录里面的内容，既不会因为容器的删除而被清理掉，也不会跟当前的宿主机绑定。这样，当容器被重启或者在其他节点上重建出来之后，它仍然能够通过挂载这个 Volume，访问到这些内容。

显然，我们前面使用的 hostPath 和 emptyDir 类型的 Volume 并不具备这个特征：它们既有可能被 kubelet 清理掉，也不能被"迁移"到其他节点上。

所以，大多数情况下，持久化 Volume 的实现，往往依赖于一个远程存储服务，比如：远程文件存储（比如，NFS、GlusterFS）、远程块存储（比如，公有云提供的远程磁盘）等等。

而 Kubernetes 需要做的工作，就是使用这些存储服务，来为容器准备一个持久化的宿主机目录，以供将来进行绑定挂载时使用。而所谓"持久化"，指的是容器在这个目录里写入的文件，都会保存在远程存储中，从而使得这个目录具备了"持久性"。

这个准备"持久化"宿主机目录的过程，我们可以形象地称为"两阶段处理"。

接下来，我通过一个具体的例子为你说明。

当一个 Pod 调度到一个节点上之后，kubelet 就要负责为这个 Pod 创建它的 Volume 目录。默认情况下，kubelet 为 Volume 创建的目录是如下所示的一个宿主机上的路径：

/var/lib/kubelet/pods/<Pod 的 ID>/volumes/kubernetes.io~<Volume 类型 >/<Volume 名字 >

接下来，kubelet 要做的操作就取决于你的 Volume 类型了。

如果你的 Volume 类型是远程块存储，比如 Google Cloud 的 Persistent Disk（GCE 提供的远程磁盘服务），那么 kubelet 就需要先调用 Goolge Cloud 的 API，将它所提供的 Persistent Disk 挂载到 Pod 所在的宿主机上。

备注：你如果不太了解块存储的话，可以直接把它理解为：一块磁盘。

这相当于执行：

$ gcloud compute instances attach-disk < 虚拟机名字 > --disk < 远程磁盘名字 >

这一步为虚拟机挂载远程磁盘的操作，对应的正是"两阶段处理"的第一阶段。在 Kubernetes 中，我们把这个阶段称为 Attach。

Attach 阶段完成后，为了能够使用这个远程磁盘，kubelet 还要进行第二个操作，即：格式化这个磁盘设备，然后将它挂载到宿主机指定的挂载点上。不难理解，这个挂载点，正是我在前面反复提到的 Volume 的宿主机目录。所以，这一步相当于执行：

\# 通过 lsblk 命令获取磁盘设备 ID

$ sudo lsblk

\# 格式化成 ext4 格式

$ sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/< 磁盘设备 ID>

\# 挂载到挂载点

$ sudo mkdir -p /var/lib/kubelet/pods/<Pod 的 ID>/volumes/kubernetes.io~<Volume 类型 >/<Volume 名字 >

这个将磁盘设备格式化并挂载到 Volume 宿主机目录的操作，对应的正是"两阶段处理"的第二个阶段，我们一般称为：Mount。

Mount 阶段完成后，这个 Volume 的宿主机目录就是一个"持久化"的目录了，容器在它里面写入的内容，会保存在 Google Cloud 的远程磁盘中。

而如果你的 Volume 类型是远程文件存储（比如 NFS）的话，kubelet 的处理过程就会更简单一些。

因为在这种情况下，kubelet 可以跳过"第一阶段"（Attach）的操作，这是因为一般来说，远程文件存储并没有一个"存储设备"需要挂载在宿主机上。

所以，kubelet 会直接从"第二阶段"（Mount）开始准备宿主机上的 Volume 目录。

在这一步，kubelet 需要作为 client，将远端 NFS 服务器的目录（比如："/"目录），挂载到 Volume 的宿主机目录上，即相当于执行如下所示的命令：

$ mount -t nfs <NFS 服务器地址 >:/ /var/lib/kubelet/pods/<Pod 的 ID>/volumes/kubernetes.io~<Volume 类型 >/<Volume 名字 > 

通过这个挂载操作，Volume 的宿主机目录就成为了一个远程 NFS 目录的挂载点，后面你在这个目录里写入的所有文件，都会被保存在远程 NFS 服务器上。所以，我们也就完成了对这个 Volume 宿主机目录的"持久化"。

到这里，你可能会有疑问，Kubernetes 又是如何定义和区分这两个阶段的呢？

其实很简单，在具体的 Volume 插件的实现接口上，Kubernetes 分别给这两个阶段提供了两种不同的参数列表：

对于"第一阶段"（Attach），Kubernetes 提供的可用参数是 nodeName，即宿主机的名字。

而对于"第二阶段"（Mount），Kubernetes 提供的可用参数是 dir，即 Volume 的宿主机目录。

所以，作为一个存储插件，你只需要根据自己的需求进行选择和实现即可。在后面关于编写存储插件的文章中，我会对这个过程做深入讲解。

而经过了"两阶段处理"，我们就得到了一个"持久化"的 Volume 宿主机目录。所以，接下来，kubelet 只要把这个 Volume 目录通过 CRI 里的 Mounts 参数，传递给 Docker，然后就可以为 Pod 里的容器挂载这个"持久化"的 Volume 了。其实，这一步相当于执行了如下所示的命令：

$ docker run -v /var/lib/kubelet/pods/<Pod 的 ID>/volumes/kubernetes.io~<Volume 类型 >/<Volume 名字 >:/< 容器内的目标目录 > 我的镜像 ...

以上，就是 Kubernetes 处理 PV 的具体原理了。
>备注：对应地，在删除一个 PV 的时候，Kubernetes 也需要 Unmount 和 Dettach 两个阶段来处理。这个过程我就不再详细介绍了，执行"反向操作"即可。

实际上，你可能已经发现，这个 PV 的处理流程似乎跟 Pod 以及容器的启动流程没有太多的耦合，只要 kubelet 在向 Docker 发起 CRI 请求之前，确保"持久化"的宿主机目录已经处理完毕即可。

所以，在 Kubernetes 中，上述关于 PV 的"两阶段处理"流程，是靠独立于 kubelet 主控制循环（Kubelet Sync Loop）之外的两个控制循环来实现的。

其中，"第一阶段"的 Attach（以及 Dettach）操作，是由 Volume Controller 负责维护的，这个控制循环的名字叫作：AttachDetachController。而它的作用，就是不断地检查每一个 Pod 对应的 PV，和这个 Pod 所在宿主机之间挂载情况。从而决定，是否需要对这个 PV 进行 Attach（或者 Dettach）操作。

需要注意，作为一个 Kubernetes 内置的控制器，Volume Controller 自然是 kube-controller-manager 的一部分。所以，AttachDetachController 也一定是运行在 Master 节点上的。当然，Attach 操作只需要调用公有云或者具体存储项目的 API，并不需要在具体的宿主机上执行操作，所以这个设计没有任何问题。

而"第二阶段"的 Mount（以及 Unmount）操作，必须发生在 Pod 对应的宿主机上，所以它必须是 kubelet 组件的一部分。这个控制循环的名字，叫作：VolumeManagerReconciler，它运行起来之后，是一个独立于 kubelet 主循环的 Goroutine。

通过这样将 Volume 的处理同 kubelet 的主循环解耦，Kubernetes 就避免了这些耗时的远程挂载操作拖慢 kubelet 的主控制循环，进而导致 Pod 的创建效率大幅下降的问题。实际上，kubelet 的一个主要设计原则，就是它的主控制循环绝对不可以被 block。这个思想，我在后续的讲述容器运行时的时候还会提到。

在了解了 Kubernetes 的 Volume 处理机制之后，我再来为你介绍这个体系里最后一个重要概念：StorageClass。

我在前面介绍 PV 和 PVC 的时候，曾经提到过，PV 这个对象的创建，是由运维人员完成的。但是，在大规模的生产环境里，这其实是一个非常麻烦的工作。

这是因为，一个大规模的 Kubernetes 集群里很可能有成千上万个 PVC，这就意味着运维人员必须得事先创建出成千上万个 PV。更麻烦的是，随着新的 PVC 不断被提交，运维人员就不得不继续添加新的、能满足条件的 PV，否则新的 Pod 就会因为 PVC 绑定不到 PV 而失败。在实际操作中，这几乎没办法靠人工做到。

所以，Kubernetes 为我们提供了一套可以自动创建 PV 的机制，即：Dynamic Provisioning。

相比之下，前面人工管理 PV 的方式就叫作 Static Provisioning。

Dynamic Provisioning 机制工作的核心，在于一个名叫 StorageClass 的 API 对象。

而 StorageClass 对象的作用，其实就是创建 PV 的模板。

具体地说，StorageClass 对象会定义如下两个部分内容：

第一，PV 的属性。比如，存储类型、Volume 的大小等等。

第二，创建这种 PV 需要用到的存储插件。比如，Ceph 等等。

有了这样两个信息之后，Kubernetes 就能够根据用户提交的 PVC，找到一个对应的 StorageClass 了。然后，Kubernetes 就会调用该 StorageClass 声明的存储插件，创建出需要的 PV。

举个例子，假如我们的 Volume 的类型是 GCE 的 Persistent Disk 的话，运维人员就需要定义一个如下所示的 StorageClass：
```
apiVersion: storage.k8s.io/v1

kind: StorageClass

metadata:

 name: block-service

provisioner: kubernetes.io/gce-pd

parameters:

 type: pd-ssd
```
在这个 YAML 文件里，我们定义了一个名叫 block-service 的 StorageClass。

这个 StorageClass 的 provisioner 字段的值是：kubernetes.io/gce-pd，这正是 Kubernetes 内置的 GCE PD 存储插件的名字。

而这个 StorageClass 的 parameters 字段，就是 PV 的参数。比如：上面例子里的 type=pd-ssd，指的是这个 PV 的类型是"SSD 格式的 GCE 远程磁盘"。

需要注意的是，由于需要使用 GCE Persistent Disk，上面这个例子只有在 GCE 提供的 Kubernetes 服务里才能实践。如果你想使用我们之前部署在本地的 Kubernetes 集群以及 Rook 存储服务的话，你的 StorageClass 需要使用如下所示的 YAML 文件来定义：
```
apiVersion: ceph.rook.io/v1beta1

kind: Pool

metadata:

 name: replicapool

 namespace: rook-ceph

spec:

 replicated:

  size: 3

\---

apiVersion: storage.k8s.io/v1

kind: StorageClass

metadata:

 name: block-service

provisioner: ceph.rook.io/block

parameters:

 pool: replicapool
```
 \#The value of "clusterNamespace" MUST be the same as the one in which your rook cluster exist

 clusterNamespace: rook-ceph

在这个 YAML 文件中，我们定义的还是一个名叫 block-service 的 StorageClass，只不过它声明使的存储插件是由 Rook 项目。

有了 StorageClass 的 YAML 文件之后，运维人员就可以在 Kubernetes 里创建这个 StorageClass 了：

$ kubectl create -f sc.yaml

这时候，作为应用开发者，我们只需要在 PVC 里指定要使用的 StorageClass 名字即可，如下所示：
```
apiVersion: v1

kind: PersistentVolumeClaim

metadata:

 name: claim1

spec:

 accessModes:

  \- ReadWriteOnce

 storageClassName: block-service

 resources:

  requests:

   storage: 30Gi
```
可以看到，我们在这个 PVC 里添加了一个叫作 storageClassName 的字段，用于指定该 PVC 所要使用的 StorageClass 的名字是：block-service。

以 Google Cloud 为例。

当我们通过 kubectl create 创建上述 PVC 对象之后，Kubernetes 就会调用 Google Cloud 的 API，创建出一块 SSD 格式的 Persistent Disk。然后，再使用这个 Persistent Disk 的信息，自动创建出一个对应的 PV 对象。

我们可以一起来实践一下这个过程（如果使用 Rook 的话下面的流程也是一样的，只不过 Rook 创建出的是 Ceph 类型的 PV）：
```
$ kubectl create -f pvc.yaml
```
可以看到，我们创建的 PVC 会绑定一个 Kubernetes 自动创建的 PV，如下所示：
```
$ kubectl describe pvc claim1

Name:      claim1

Namespace:    default

StorageClass:  block-service

Status:     Bound

Volume:     pvc-e5578707-c626-11e6-baf6-08002729a32b

Labels:     <none>

Capacity:    30Gi

Access Modes:  RWO
```
No Events.
而且，通过查看这个自动创建的 PV 的属性，你就可以看到它跟我们在 PVC 里声明的存储的属性是一致的，如下所示：
```
$ kubectl describe pv pvc-e5578707-c626-11e6-baf6-08002729a32b
```
此外，你还可以看到，这个自动创建出来的 PV 的 StorageClass 字段的值，也是 block-service。这是因为，Kubernetes 只会将 StorageClass 相同的 PVC 和 PV 绑定起来。

有了 Dynamic Provisioning 机制，运维人员只需要在 Kubernetes 集群里创建出数量有限的 StorageClass 对象就可以了。这就好比，运维人员在 Kubernetes 集群里创建出了各种各样的 PV 模板。这时候，当开发人员提交了包含 StorageClass 字段的 PVC 之后，Kubernetes 就会根据这个 StorageClass 创建出对应的 PV。

Kubernetes 的官方文档里已经列出了默认支持 Dynamic Provisioning 的内置存储插件。而对于不在文档里的插件，比如 NFS，或者其他非内置存储插件，你其实可以通过kubernetes-incubator/external-storage这个库来自己编写一个外部插件完成这个工作。像我们之前部署的 Rook，已经内置了 external-storage 的实现，所以 Rook 是完全支持 Dynamic Provisioning 特性的。

需要注意的是，StorageClass 并不是专门为了 Dynamic Provisioning 而设计的。

比如，在本篇一开始的例子里，我在 PV 和 PVC 里都声明了 storageClassName=manual。而我的集群里，实际上并没有一个名叫 manual 的 StorageClass 对象。这完全没有问题，这个时候 Kubernetes 进行的是 Static Provisioning，但在做绑定决策的时候，它依然会考虑 PV 和 PVC 的 StorageClass 定义。

而这么做的好处也很明显：这个 PVC 和 PV 的绑定关系，就完全在我自己的掌控之中。

这里，你可能会有疑问，我在之前讲解 StatefulSet 存储状态的例子时，好像并没有声明 StorageClass 啊？

实际上，如果你的集群已经开启了名叫 DefaultStorageClass 的 Admission Plugin，它就会为 PVC 和 PV 自动添加一个默认的 StorageClass；否则，PVC 的 storageClassName 的值就是""，这也意味着它只能够跟 storageClassName 也是""的 PV 进行绑定。

总结
在今天的分享中，我为你详细解释了 PVC 和 PV 的设计与实现原理，并为你阐述了 StorageClass 到底是干什么用的。这些概念之间的关系，可以用如下所示的一幅示意图描述：

从图中我们可以看到，在这个体系中：

PVC 描述的，是 Pod 想要使用的持久化存储的属性，比如存储的大小、读写权限等。

PV 描述的，则是一个具体的 Volume 的属性，比如 Volume 的类型、挂载目录、远程存储服务器地址等。

而 StorageClass 的作用，则是充当 PV 的模板。并且，只有同属于一个 StorageClass 的 PV 和 PVC，才可以绑定在一起。

当然，StorageClass 的另一个重要作用，是指定 PV 的 Provisioner（存储插件）。这时候，如果你的存储插件支持 Dynamic Provisioning 的话，Kubernetes 就可以自动为你创建 PV 了。

基于上述讲述，为了统一概念和方便叙述，在本专栏中，我以后凡是提到"Volume"，指的就是一个远程存储服务挂载在宿主机上的持久化目录；而"PV"，指的是这个 Volume 在 Kubernetes 里的 API 对象。

需要注意的是，这套容器持久化存储体系，完全是 Kubernetes 项目自己负责管理的，并不依赖于 docker volume 命令和 Docker 的存储插件。当然，这套体系本身就比 docker volume 命令的诞生时间还要早得多。

思考题
在了解了 PV、PVC 的设计和实现原理之后，你是否依然觉得它有"过度设计"的嫌疑？或者，你是否有更加简单、足以解决你 90% 需求的 Volume 的用法？

在上一篇文章中，我为你详细讲解了 PV、PVC 持久化存储体系在 Kubernetes 项目中的设计和实现原理。而在文章最后的思考题中，我为你留下了这样一个讨论话题：像 PV、PVC 这样的用法，是不是有"过度设计"的嫌疑？

比如，我们公司的运维人员可以像往常一样维护一套 NFS 或者 Ceph 服务器，根本不必学习 Kubernetes。而开发人员，则完全可以靠"复制粘贴"的方式，在 Pod 的 YAML 文件里填上 Volumes 字段，而不需要去使用 PV 和 PVC。

实际上，如果只是为了职责划分，PV、PVC 体系确实不见得比直接在 Pod 里声明 Volumes 字段有什么优势。

不过，你有没有想过这样一个问题，如果Kubernetes 内置的 20 种持久化数据卷实现，都没办法满足你的容器存储需求时，该怎么办？

这个情况乍一听起来有点不可思议。但实际上，凡是鼓捣过开源项目的读者应该都有所体会，"不能用""不好用""需要定制开发"，这才是落地开源基础设施项目的三大常态。

而在持久化存储领域，用户呼声最高的定制化需求，莫过于支持"本地"持久化存储了。

也就是说，用户希望 Kubernetes 能够直接使用宿主机上的本地磁盘目录，而不依赖于远程存储服务，来提供"持久化"的容器 Volume。

这样做的好处很明显，由于这个 Volume 直接使用的是本地磁盘，尤其是 SSD 盘，它的读写性能相比于大多数远程存储来说，要好得多。这个需求对本地物理服务器部署的私有 Kubernetes 集群来说，非常常见。

所以，Kubernetes 在 v1.10 之后，就逐渐依靠 PV、PVC 体系实现了这个特性。这个特性的名字叫作：Local Persistent Volume。

不过，首先需要明确的是，Local Persistent Volume 并不适用于所有应用。事实上，它的适用范围非常固定，比如：高优先级的系统应用，需要在多个不同节点上存储数据，并且对 I/O 较为敏感。典型的应用包括：分布式数据存储比如 MongoDB、Cassandra 等，分布式文件系统比如 GlusterFS、Ceph 等，以及需要在本地磁盘上进行大量数据缓存的分布式应用。

其次，相比于正常的 PV，一旦这些节点宕机且不能恢复时，Local Persistent Volume 的数据就可能丢失。这就要求使用 Local Persistent Volume 的应用必须具备数据备份和恢复的能力，允许你把这些数据定时备份在其他位置。

接下来，我就为你深入讲解一下这个特性。

不难想象，Local Persistent Volume 的设计，主要面临两个难点。

第一个难点在于：如何把本地磁盘抽象成 PV。

可能你会说，Local Persistent Volume，不就等同于 hostPath 加 NodeAffinity 吗？

比如，一个 Pod 可以声明使用类型为 Local 的 PV，而这个 PV 其实就是一个 hostPath 类型的 Volume。如果这个 hostPath 对应的目录，已经在节点 A 上被事先创建好了。那么，我只需要再给这个 Pod 加上一个 nodeAffinity=nodeA，不就可以使用这个 Volume 了吗？

事实上，你绝不应该把一个宿主机上的目录当作 PV 使用。这是因为，这种本地目录的存储行为完全不可控，它所在的磁盘随时都可能被应用写满，甚至造成整个宿主机宕机。而且，不同的本地目录之间也缺乏哪怕最基础的 I/O 隔离机制。

所以，一个 Local Persistent Volume 对应的存储介质，一定是一块额外挂载在宿主机的磁盘或者块设备（"额外"的意思是，它不应该是宿主机根目录所使用的主硬盘）。这个原则，我们可以称为"一个 PV 一块盘"。

第二个难点在于：调度器如何保证 Pod 始终能被正确地调度到它所请求的 Local Persistent Volume 所在的节点上呢？

造成这个问题的原因在于，对于常规的 PV 来说，Kubernetes 都是先调度 Pod 到某个节点上，然后，再通过"两阶段处理"来"持久化"这台机器上的 Volume 目录，进而完成 Volume 目录与容器的绑定挂载。

可是，对于 Local PV 来说，节点上可供使用的磁盘（或者块设备），必须是运维人员提前准备好的。它们在不同节点上的挂载情况可以完全不同，甚至有的节点可以没这种磁盘。

所以，这时候，调度器就必须能够知道所有节点与 Local Persistent Volume 对应的磁盘的关联关系，然后根据这个信息来调度 Pod。

这个原则，我们可以称为"在调度的时候考虑 Volume 分布"。在 Kubernetes 的调度器里，有一个叫作 VolumeBindingChecker 的过滤条件专门负责这个事情。在 Kubernetes v1.11 中，这个过滤条件已经默认开启了。

基于上述讲述，在开始使用 Local Persistent Volume 之前，你首先需要在集群里配置好磁盘或者块设备。在公有云上，这个操作等同于给虚拟机额外挂载一个磁盘，比如 GCE 的 Local SSD 类型的磁盘就是一个典型例子。

而在我们部署的私有环境中，你有两种办法来完成这个步骤。
第一种，当然就是给你的宿主机挂载并格式化一个可用的本地磁盘，这也是最常规的操作；

第二种，对于实验环境，你其实可以在宿主机上挂载几个 RAM Disk（内存盘）来模拟本地磁盘。

接下来，我会使用第二种方法，在我们之前部署的 Kubernetes 集群上进行实践。

首先，在名叫 node-1 的宿主机上创建一个挂载点，比如 /mnt/disks；然后，用几个 RAM Disk 来模拟本地磁盘，如下所示：

\# 在 node-1 上执行

$ mkdir /mnt/disks

$ for vol in vol1 vol2 vol3; do

  mkdir /mnt/disks/$vol

  mount -t tmpfs $vol /mnt/disks/$vol

done

需要注意的是，如果你希望其他节点也能支持 Local Persistent Volume 的话，那就需要为它们也执行上述操作，并且确保这些磁盘的名字（vol1、vol2 等）都不重复。

接下来，我们就可以为这些本地磁盘定义对应的 PV 了，如下所示：
```
apiVersion: v1

kind: PersistentVolume

metadata:

 name: example-pv

spec:

 capacity:

  storage: 5Gi

 volumeMode: Filesystem

 accessModes:

 \- ReadWriteOnce

 persistentVolumeReclaimPolicy: Delete

 storageClassName: local-storage

 local:

  path: /mnt/disks/vol1

 nodeAffinity:

  required:

   nodeSelectorTerms:

   \- matchExpressions:

​    \- key: kubernetes.io/hostname

​     operator: In

​     values:

​     \- node-1
```
可以看到，这个 PV 的定义里：local 字段，指定了它是一个 Local Persistent Volume；而 path 字段，指定的正是这个 PV 对应的本地磁盘的路径，即：/mnt/disks/vol1。

当然了，这也就意味着如果 Pod 要想使用这个 PV，那它就必须运行在 node-1 上。所以，在这个 PV 的定义里，需要有一个 nodeAffinity 字段指定 node-1 这个节点的名字。这样，调度器在调度 Pod 的时候，就能够知道一个 PV 与节点的对应关系，从而做出正确的选择。这正是 Kubernetes 实现"在调度的时候就考虑 Volume 分布"的主要方法。

接下来，我们就可以使用 kubect create 来创建这个 PV，如下所示：
```
$ kubectl create -f local-pv.yaml 

persistentvolume/example-pv created
```
```
$ kubectl get pv

NAME     CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS    CLAIM       STORAGECLASS   REASON   AGE

example-pv  5Gi     RWO       Delete      Available           local-storage       16s
```
可以看到，这个 PV 创建后，进入了 Available（可用）状态。

而正如我在上一篇文章里所建议的那样，使用 PV 和 PVC 的最佳实践，是你要创建一个 StorageClass 来描述这个 PV，如下所示：
```
kind: StorageClass

apiVersion: storage.k8s.io/v1

metadata:

 name: local-storage

provisioner: kubernetes.io/no-provisioner

volumeBindingMode: WaitForFirstConsumer
```
这个 StorageClass 的名字，叫作 local-storage。需要注意的是，在它的 provisioner 字段，我们指定的是 no-provisioner。这是因为 Local Persistent Volume 目前尚不支持 Dynamic Provisioning，所以它没办法在用户创建 PVC 的时候，就自动创建出对应的 PV。也就是说，我们前面创建 PV 的操作，是不可以省略的。

与此同时，这个 StorageClass 还定义了一个 volumeBindingMode=WaitForFirstConsumer 的属性。它是 Local Persistent Volume 里一个非常重要的特性，即：延迟绑定。

我们知道，当你提交了 PV 和 PVC 的 YAML 文件之后，Kubernetes 就会根据它们俩的属性，以及它们指定的 StorageClass 来进行绑定。只有绑定成功后，Pod 才能通过声明这个 PVC 来使用对应的 PV。

可是，如果你使用的是 Local Persistent Volume 的话，就会发现，这个流程根本行不通。

比如，现在你有一个 Pod，它声明使用的 PVC 叫作 pvc-1。并且，我们规定，这个 Pod 只能运行在 node-2 上。

而在 Kubernetes 集群中，有两个属性（比如：大小、读写权限）相同的 Local 类型的 PV。

其中，第一个 PV 的名字叫作 pv-1，它对应的磁盘所在的节点是 node-1。而第二个 PV 的名字叫作 pv-2，它对应的磁盘所在的节点是 node-2。

假设现在，Kubernetes 的 Volume 控制循环里，首先检查到了 pvc-1 和 pv-1 的属性是匹配的，于是就将它们俩绑定在一起。

然后，你用 kubectl create 创建了这个 Pod。

这时候，问题就出现了。

调度器看到，这个 Pod 所声明的 pvc-1 已经绑定了 pv-1，而 pv-1 所在的节点是 node-1，根据"调度器必须在调度的时候考虑 Volume 分布"的原则，这个 Pod 自然会被调度到 node-1 上。

可是，我们前面已经规定过，这个 Pod 根本不允许运行在 node-1 上。所以。最后的结果就是，这个 Pod 的调度必然会失败。

这就是为什么，在使用 Local Persistent Volume 的时候，我们必须想办法推迟这个"绑定"操作。

那么，具体推迟到什么时候呢？答案是：推迟到调度的时候。

所以说，StorageClass 里的 volumeBindingMode=WaitForFirstConsumer 的含义，就是告诉 Kubernetes 里的 Volume 控制循环（"红娘"）：虽然你已经发现这个 StorageClass 关联的 PVC 与 PV 可以绑定在一起，但请不要现在就执行绑定操作（即：设置 PVC 的 VolumeName 字段）。

而要等到第一个声明使用该 PVC 的 Pod 出现在调度器之后，调度器再综合考虑所有的调度规则，当然也包括每个 PV 所在的节点位置，来统一决定，这个 Pod 声明的 PVC，到底应该跟哪个 PV 进行绑定。

这样，在上面的例子里，由于这个 Pod 不允许运行在 pv-1 所在的节点 node-1，所以它的 PVC 最后会跟 pv-2 绑定，并且 Pod 也会被调度到 node-2 上。

所以，通过这个延迟绑定机制，原本实时发生的 PVC 和 PV 的绑定过程，就被延迟到了 Pod 第一次调度的时候在调度器中进行，从而保证了这个绑定结果不会影响 Pod 的正常调度。

当然，在具体实现中，调度器实际上维护了一个与 Volume Controller 类似的控制循环，专门负责为那些声明了"延迟绑定"的 PV 和 PVC 进行绑定工作。

通过这样的设计，这个额外的绑定操作，并不会拖慢调度器的性能。而当一个 Pod 的 PVC 尚未完成绑定时，调度器也不会等待，而是会直接把这个 Pod 重新放回到待调度队列，等到下一个调度周期再做处理。

在明白了这个机制之后，我们就可以创建 StorageClass 了，如下所示：
```
$ kubectl create -f local-sc.yaml 

storageclass.storage.k8s.io/local-storage created
```
接下来，我们只需要定义一个非常普通的 PVC，就可以让 Pod 使用到上面定义好的 Local Persistent Volume 了，如下所示：
```
kind: PersistentVolumeClaim

apiVersion: v1

metadata:

 name: example-local-claim

spec:

 accessModes:

 \- ReadWriteOnce

 resources:

  requests:

   storage: 5Gi

 storageClassName: local-storage
```
可以看到，这个 PVC 没有任何特别的地方。唯一需要注意的是，它声明的 storageClassName 是 local-storage。所以，将来 Kubernetes 的 Volume Controller 看到这个 PVC 的时候，不会为它进行绑定操作。

现在，我们来创建这个 PVC：
```
$ kubectl create -f local-pvc.yaml 

persistentvolumeclaim/example-local-claim created
```

```
$ kubectl get pvc

NAME          STATUS   VOLUME   CAPACITY  ACCESS MODES  STORAGECLASS   AGE

example-local-claim  Pending                    local-storage  7s
```
可以看到，尽管这个时候，Kubernetes 里已经存在了一个可以与 PVC 匹配的 PV，但这个 PVC 依然处于 Pending 状态，也就是等待绑定的状态。

然后，我们编写一个 Pod 来声明使用这个 PVC，如下所示：
```
kind: Pod

apiVersion: v1

metadata:

 name: example-pv-pod

spec:

 volumes:

  \- name: example-pv-storage

   persistentVolumeClaim:

​    claimName: example-local-claim

 containers:

  \- name: example-pv-container

   image: nginx

   ports:

​    \- containerPort: 80

​     name: "http-server"

   volumeMounts:

​    \- mountPath: "/usr/share/nginx/html"

​     name: example-pv-storage
```
这个 Pod 没有任何特别的地方，你只需要注意，它的 volumes 字段声明要使用前面定义的、名叫 example-local-claim 的 PVC 即可。

而我们一旦使用 kubectl create 创建这个 Pod，就会发现，我们前面定义的 PVC，会立刻变成 Bound 状态，与前面定义的 PV 绑定在了一起，如下所示：
```
$ kubectl create -f local-pod.yaml 

pod/example-pv-pod created
```

```
$ kubectl get pvc

NAME          STATUS   VOLUME    CAPACITY  ACCESS MODES  STORAGECLASS   AGE

example-local-claim  Bound   example-pv  5Gi     RWO       local-storage  6h
```
也就是说，在我们创建的 Pod 进入调度器之后，"绑定"操作才开始进行。

这时候，我们可以尝试在这个 Pod 的 Volume 目录里，创建一个测试文件，比如：
```
$ kubectl exec -it example-pv-pod -- /bin/sh

\# cd /usr/share/nginx/html

\# touch test.txt
```
然后，登录到 node-1 这台机器上，查看一下它的 /mnt/disks/vol1 目录下的内容，你就可以看到刚刚创建的这个文件：

\# 在 node-1 上
```
$ ls /mnt/disks/vol1

test.txt
```
而如果你重新创建这个 Pod 的话，就会发现，我们之前创建的测试文件，依然被保存在这个持久化 Volume 当中：
```
$ kubectl delete -f local-pod.yaml 

$ kubectl create -f local-pod.yaml 

$ kubectl exec -it example-pv-pod -- /bin/sh

\# ls /usr/share/nginx/html

\# touch test.txt
```
这就说明，像 Kubernetes 这样构建出来的、基于本地存储的 Volume，完全可以提供容器持久化存储的功能。所以，像 StatefulSet 这样的有状态编排工具，也完全可以通过声明 Local 类型的 PV 和 PVC，来管理应用的存储状态。

需要注意的是，我们上面手动创建 PV 的方式，即 Static 的 PV 管理方式，在删除 PV 时需要按如下流程执行操作：

删除使用这个 PV 的 Pod；

从宿主机移除本地磁盘（比如，umount 它）；

删除 PVC；

删除 PV。

如果不按照这个流程的话，这个 PV 的删除就会失败。

当然，由于上面这些创建 PV 和删除 PV 的操作比较繁琐，Kubernetes 其实提供了一个 Static Provisioner 来帮助你管理这些 PV。

比如，我们现在的所有磁盘，都挂载在宿主机的 /mnt/disks 目录下。

那么，当 Static Provisioner 启动后，它就会通过 DaemonSet，自动检查每个宿主机的 /mnt/disks 目录。然后，调用 Kubernetes API，为这些目录下面的每一个挂载，创建一个对应的 PV 对象出来。这些自动创建的 PV，如下所示：
```
$ kubectl get pv

NAME         CAPACITY   ACCESSMODES  RECLAIMPOLICY  STATUS    CLAIM   STORAGECLASS   REASON   AGE

local-pv-ce05be60  1024220Ki  RWO      Delete      Available       local-storage       26s
```

```
$ kubectl describe pv local-pv-ce05be60 
```

这个 PV 里的各种定义，比如 StorageClass 的名字、本地磁盘挂载点的位置，都可以通过 provisioner 的配置文件指定。当然，provisioner 也会负责前面提到的 PV 的删除工作。

而这个 provisioner 本身，其实也是一个我们前面提到过的External Provisioner，它的部署方法，在对应的文档里有详细描述。这部分内容，就留给你课后自行探索了。

总结
在今天这篇文章中，我为你详细介绍了 Kubernetes 里 Local Persistent Volume 的实现方式。

可以看到，正是通过 PV 和 PVC，以及 StorageClass 这套存储体系，这个后来新添加的持久化存储方案，对 Kubernetes 已有用户的影响，几乎可以忽略不计。作为用户，你的 Pod 的 YAML 和 PVC 的 YAML，并没有任何特殊的改变，这个特性所有的实现只会影响到 PV 的处理，也就是由运维人员负责的那部分工作。

而这，正是这套存储体系带来的"解耦"的好处。

其实，Kubernetes 很多看起来比较"繁琐"的设计（比如"声明式 API"，以及我今天讲解的"PV、PVC 体系"）的主要目的，都是希望为开发者提供更多的"可扩展性"，给使用者带来更多的"稳定性"和"安全感"。这两个能力的高低，是衡量开源基础设施项目水平的重要标准。

思考题
正是由于需要使用"延迟绑定"这个特性，Local Persistent Volume 目前还不能支持 Dynamic Provisioning。你是否能说出，为什么"延迟绑定"会跟 Dynamic Provisioning 有冲突呢？

在上一篇文章中，我为你详细介绍了 Kubernetes 里的持久化存储体系，讲解了 PV 和 PVC 的具体实现原理，并提到了这样的设计实际上是出于对整个存储体系的可扩展性的考虑。

而在今天这篇文章中，我就和你分享一下如何借助这些机制，来开发自己的存储插件。

在 Kubernetes 中，存储插件的开发有两种方式：FlexVolume 和 CSI。

接下来，我就先为你剖析一下Flexvolume 的原理和使用方法。

举个例子，现在我们要编写的是一个使用 NFS 实现的 FlexVolume 插件。

对于一个 FlexVolume 类型的 PV 来说，它的 YAML 文件如下所示：
```
apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv-flex-nfs

spec:

 capacity:

  storage: 10Gi

 accessModes:

  \- ReadWriteMany

 flexVolume:

  driver: "k8s/nfs"

  fsType: "nfs"

  options:

   server: "10.10.0.25" # 改成你自己的 NFS 服务器地址

   share: "export"
```
可以看到，这个 PV 定义的 Volume 类型是 flexVolume。并且，我们指定了这个 Volume 的 driver 叫作 k8s/nfs。这个名字很重要，我后面马上会为你解释它的含义。

而 Volume 的 options 字段，则是一个自定义字段。也就是说，它的类型，其实是 map[string]string。所以，你可以在这一部分自由地加上你想要定义的参数。

在我们这个例子里，options 字段指定了 NFS 服务器的地址（server: "10.10.0.25"），以及 NFS 共享目录的名字（share: "export"）。当然，你这里定义的所有参数，后面都会被 FlexVolume 拿到。

备注：你可以使用这个 Docker 镜像轻松地部署一个试验用的 NFS 服务器。

像这样的一个 PV 被创建后，一旦和某个 PVC 绑定起来，这个 FlexVolume 类型的 Volume 就会进入到我们前面讲解过的 Volume 处理流程。

你应该还记得，这个流程的名字叫作"两阶段处理"，即"Attach 阶段"和"Mount 阶段"。它们的主要作用，是在 Pod 所绑定的宿主机上，完成这个 Volume 目录的持久化过程，比如为虚拟机挂载磁盘（Attach），或者挂载一个 NFS 的共享目录（Mount）。

备注：你可以再回顾一下第 28 篇文章《PV、PVC、StorageClass，这些到底在说啥？》中的相关内容。

而在具体的控制循环中，这两个操作实际上调用的，正是 Kubernetes 的 pkg/volume 目录下的存储插件（Volume Plugin）。在我们这个例子里，就是 pkg/volume/flexvolume 这个目录里的代码。

当然了，这个目录其实只是 FlexVolume 插件的入口。以"Mount 阶段"为例，在 FlexVolume 目录里，它的处理过程非常简单，如下所示：

// SetUpAt creates new directory.

func (f *flexVolumeMounter) SetUpAt(dir string, fsGroup *int64) error {

 ...

 call := f.plugin.NewDriverCall(mountCmd)

 

 // Interface parameters

 call.Append(dir)

 

 extraOptions := make(map[string]string)

 

 // pod metadata

 extraOptions[optionKeyPodName] = f.podName

 extraOptions[optionKeyPodNamespace] = f.podNamespace

 

 ...

 

 call.AppendSpec(f.spec, f.plugin.host, extraOptions)

 

 _, err = call.Run()

 

 ...

 

 return nil

}

上面这个名叫 SetUpAt() 的方法，正是 FlexVolume 插件对"Mount 阶段"的实现位置。而 SetUpAt() 实际上只做了一件事，那就是封装出了一行命令（即：NewDriverCall），由 kubelet 在"Mount 阶段"去执行。

在我们这个例子中，kubelet 要通过插件在宿主机上执行的命令，如下所示：

/usr/libexec/kubernetes/kubelet-plugins/volume/exec/k8s~nfs/nfs mount <mount dir> <json param>

其中，/usr/libexec/kubernetes/kubelet-plugins/volume/exec/k8s~nfs/nfs 就是插件的可执行文件的路径。这个名叫 nfs 的文件，正是你要编写的插件的实现。它可以是一个二进制文件，也可以是一个脚本。总之，只要能在宿主机上被执行起来即可。

而且这个路径里的 k8s~nfs 部分，正是这个插件在 Kubernetes 里的名字。它是从 driver="k8s/nfs"字段解析出来的。

这个 driver 字段的格式是：vendor/driver。比如，一家存储插件的提供商（vendor）的名字叫作 k8s，提供的存储驱动（driver）是 nfs，那么 Kubernetes 就会使用 k8s~nfs 来作为插件名。

所以说，当你编写完了 FlexVolume 的实现之后，一定要把它的可执行文件放在每个节点的插件目录下。

而紧跟在可执行文件后面的"mount"参数，定义的就是当前的操作。在 FlexVolume 里，这些操作参数的名字是固定的，比如 init、mount、unmount、attach，以及 dettach 等等，分别对应不同的 Volume 处理操作。

而跟在 mount 参数后面的两个字段：<mount dir>和<json params>，则是 FlexVolume 必须提供给这条命令的两个执行参数。

其中第一个执行参数<mount dir>，正是 kubelet 调用 SetUpAt() 方法传递来的 dir 的值。它代表的是当前正在处理的 Volume 在宿主机上的目录。在我们的例子里，这个路径如下所示：

/var/lib/kubelet/pods/<Pod ID>/volumes/k8s~nfs/test

其中，test 正是我们前面定义的 PV 的名字；而 k8s~nfs，则是插件的名字。可以看到，插件的名字正是从你声明的 driver="k8s/nfs"字段里解析出来的。

而第二个执行参数<json params>，则是一个 JSON Map 格式的参数列表。我们在前面 PV 里定义的 options 字段的值，都会被追加在这个参数里。此外，在 SetUpAt() 方法里可以看到，这个参数列表里还包括了 Pod 的名字、Namespace 等元数据（Metadata）。

在明白了存储插件的调用方式和参数列表之后，这个插件的可执行文件的实现部分就非常容易理解了。

在这个例子中，我直接编写了一个简单的 shell 脚本来作为插件的实现，它对"Mount 阶段"的处理过程，如下所示：

domount() {

 MNTPATH=$1

 

 NFS_SERVER=$(echo $2 | jq -r '.server')

 SHARE=$(echo $2 | jq -r '.share')

 

 ...

 

 mkdir -p ${MNTPATH} &> /dev/null

 

 mount -t nfs ${NFS_SERVER}:/${SHARE} ${MNTPATH} &> /dev/null

 if [ $? -ne 0 ]; then

 err "{ \"status\": \"Failure\", \"message\": \"Failed to mount ${NFS_SERVER}:${SHARE} at ${MNTPATH}\"}"

 exit 1

 fi

 log '{"status": "Success"}'

 exit 0

}

可以看到，当 kubelet 在宿主机上执行"nfs mount <mount dir> <json params>"的时候，这个名叫 nfs 的脚本，就可以直接从<mount dir>参数里拿到 Volume 在宿主机上的目录，即：MNTPATH=

$<json params>

有了这三个参数之后，这个脚本最关键的一步，当然就是执行：mount -t nfs

MY_ZUES_CHAR

{NFS_SERVER}:/${SHARE} ${MNTPATH}

需要注意的是，当这个 mount -t nfs 操作完成后，你必须把一个 JOSN 格式的字符串，比如：{"status": "Success"}，返回给调用者，也就是 kubelet。这是 kubelet 判断这次调用是否成功的唯一依据。

综上所述，在"Mount 阶段"，kubelet 的 VolumeManagerReconcile 控制循环里的一次"调谐"操作的执行流程，如下所示：

kubelet --> pkg/volume/flexvolume.SetUpAt() --> /usr/libexec/kubernetes/kubelet-plugins/volume/exec/k8s~nfs/nfs mount <mount dir> <json param>

备注：这个 NFS 的 FlexVolume 的完整实现，在这个 GitHub 库里。而你如果想用 Go 语言编写 FlexVolume 的话，我也有一个很好的例子供你参考。

当然，在前面文章中我也提到过，像 NFS 这样的文件系统存储，并不需要在宿主机上挂载磁盘或者块设备。所以，我们也就不需要实现 attach 和 dettach 操作了。

不过，像这样的 FlexVolume 实现方式，虽然简单，但局限性却很大。

比如，跟 Kubernetes 内置的 NFS 插件类似，这个 NFS FlexVolume 插件，也不能支持 Dynamic Provisioning（即：为每个 PVC 自动创建 PV 和对应的 Volume）。除非你再为它编写一个专门的 External Provisioner。

再比如，我的插件在执行 mount 操作的时候，可能会生成一些挂载信息。这些信息，在后面执行 unmount 操作的时候会被用到。可是，在上述 FlexVolume 的实现里，你没办法把这些信息保存在一个变量里，等到 unmount 的时候直接使用。

这个原因也很容易理解：FlexVolume 每一次对插件可执行文件的调用，都是一次完全独立的操作。所以，我们只能把这些信息写在一个宿主机上的临时文件里，等到 unmount 的时候再去读取。

这也是为什么，我们需要有 Container Storage Interface（CSI）这样更完善、更编程友好的插件方式。

接下来，我就来为你讲解一下开发存储插件的第二种方式 CSI。我们先来看一下CSI 插件体系的设计原理。

其实，通过前面对 FlexVolume 的讲述，你应该可以明白，默认情况下，Kubernetes 里通过存储插件管理容器持久化存储的原理，可以用如下所示的示意图来描述：

可以看到，在上述体系下，无论是 FlexVolume，还是 Kubernetes 内置的其他存储插件，它们实际上担任的角色，仅仅是 Volume 管理中的"Attach 阶段"和"Mount 阶段"的具体执行者。而像 Dynamic Provisioning 这样的功能，就不是存储插件的责任，而是 Kubernetes 本身存储管理功能的一部分。

相比之下，CSI 插件体系的设计思想，就是把这个 Provision 阶段，以及 Kubernetes 里的一部分存储管理功能，从主干代码里剥离出来，做成了几个单独的组件。这些组件会通过 Watch API 监听 Kubernetes 里与存储相关的事件变化，比如 PVC 的创建，来执行具体的存储管理动作。

而这些管理动作，比如"Attach 阶段"和"Mount 阶段"的具体操作，实际上就是通过调用 CSI 插件来完成的。

这种设计思路，我可以用如下所示的一幅示意图来表示：

可以看到，这套存储插件体系多了三个独立的外部组件（External Components），即：Driver Registrar、External Provisioner 和 External Attacher，对应的正是从 Kubernetes 项目里面剥离出来的那部分存储管理功能。

需要注意的是，External Components 虽然是外部组件，但依然由 Kubernetes 社区来开发和维护。

而图中最右侧的部分，就是需要我们编写代码来实现的 CSI 插件。一个 CSI 插件只有一个二进制文件，但它会以 gRPC 的方式对外提供三个服务（gRPC Service），分别叫作：CSI Identity、CSI Controller 和 CSI Node。

我先来为你讲解一下这三个 External Components。

其中，Driver Registrar 组件，负责将插件注册到 kubelet 里面（这可以类比为，将可执行文件放在插件目录下）。而在具体实现上，Driver Registrar 需要请求 CSI 插件的 Identity 服务来获取插件信息。

而External Provisioner 组件，负责的正是 Provision 阶段。在具体实现上，External Provisioner 监听（Watch）了 APIServer 里的 PVC 对象。当一个 PVC 被创建时，它就会调用 CSI Controller 的 CreateVolume 方法，为你创建对应 PV。

此外，如果你使用的存储是公有云提供的磁盘（或者块设备）的话，这一步就需要调用公有云（或者块设备服务）的 API 来创建这个 PV 所描述的磁盘（或者块设备）了。

不过，由于 CSI 插件是独立于 Kubernetes 之外的，所以在 CSI 的 API 里不会直接使用 Kubernetes 定义的 PV 类型，而是会自己定义一个单独的 Volume 类型。

为了方便叙述，在本专栏里，我会把 Kubernetes 里的持久化卷类型叫作 PV，把 CSI 里的持久化卷类型叫作 CSI Volume，请你务必区分清楚。

最后一个External Attacher 组件，负责的正是"Attach 阶段"。在具体实现上，它监听了 APIServer 里 VolumeAttachment 对象的变化。VolumeAttachment 对象是 Kubernetes 确认一个 Volume 可以进入"Attach 阶段"的重要标志，我会在下一篇文章里为你详细讲解。

一旦出现了 VolumeAttachment 对象，External Attacher 就会调用 CSI Controller 服务的 ControllerPublish 方法，完成它所对应的 Volume 的 Attach 阶段。

而 Volume 的"Mount 阶段"，并不属于 External Components 的职责。当 kubelet 的 VolumeManagerReconciler 控制循环检查到它需要执行 Mount 操作的时候，会通过 pkg/volume/csi 包，直接调用 CSI Node 服务完成 Volume 的"Mount 阶段"。

在实际使用 CSI 插件的时候，我们会将这三个 External Components 作为 sidecar 容器和 CSI 插件放置在同一个 Pod 中。由于 External Components 对 CSI 插件的调用非常频繁，所以这种 sidecar 的部署方式非常高效。

接下来，我再为你讲解一下 CSI 插件的里三个服务：CSI Identity、CSI Controller 和 CSI Node。

其中，CSI 插件的 CSI Identity 服务，负责对外暴露这个插件本身的信息，如下所示：

service Identity {

 // return the version and name of the plugin

 rpc GetPluginInfo(GetPluginInfoRequest)

  returns (GetPluginInfoResponse) {}

 // reports whether the plugin has the ability of serving the Controller interface

 rpc GetPluginCapabilities(GetPluginCapabilitiesRequest)

  returns (GetPluginCapabilitiesResponse) {}

 // called by the CO just to check whether the plugin is running or not

 rpc Probe (ProbeRequest)

  returns (ProbeResponse) {}

}

而CSI Controller 服务，定义的则是对 CSI Volume（对应 Kubernetes 里的 PV）的管理接口，比如：创建和删除 CSI Volume、对 CSI Volume 进行 Attach/Dettach（在 CSI 里，这个操作被叫作 Publish/Unpublish），以及对 CSI Volume 进行 Snapshot 等，它们的接口定义如下所示：

service Controller {

 // provisions a volume

 rpc CreateVolume (CreateVolumeRequest)

  returns (CreateVolumeResponse) {}

  

 // deletes a previously provisioned volume

 rpc DeleteVolume (DeleteVolumeRequest)

  returns (DeleteVolumeResponse) {}

  

 // make a volume available on some required node

 rpc ControllerPublishVolume (ControllerPublishVolumeRequest)

  returns (ControllerPublishVolumeResponse) {}

  

 // make a volume un-available on some required node

 rpc ControllerUnpublishVolume (ControllerUnpublishVolumeRequest)

  returns (ControllerUnpublishVolumeResponse) {}

  

 ...

 

 // make a snapshot

 rpc CreateSnapshot (CreateSnapshotRequest)

  returns (CreateSnapshotResponse) {}

  

 // Delete a given snapshot

 rpc DeleteSnapshot (DeleteSnapshotRequest)

  returns (DeleteSnapshotResponse) {}

  

 ...

}

不难发现，CSI Controller 服务里定义的这些操作有个共同特点，那就是它们都无需在宿主机上进行，而是属于 Kubernetes 里 Volume Controller 的逻辑，也就是属于 Master 节点的一部分。

需要注意的是，正如我在前面提到的那样，CSI Controller 服务的实际调用者，并不是 Kubernetes（即：通过 pkg/volume/csi 发起 CSI 请求），而是 External Provisioner 和 External Attacher。这两个 External Components，分别通过监听 PVC 和 VolumeAttachement 对象，来跟 Kubernetes 进行协作。

而 CSI Volume 需要在宿主机上执行的操作，都定义在了 CSI Node 服务里面，如下所示：

service Node {

 // temporarily mount the volume to a staging path

 rpc NodeStageVolume (NodeStageVolumeRequest)

  returns (NodeStageVolumeResponse) {}

  

 // unmount the volume from staging path

 rpc NodeUnstageVolume (NodeUnstageVolumeRequest)

  returns (NodeUnstageVolumeResponse) {}

  

 // mount the volume from staging to target path

 rpc NodePublishVolume (NodePublishVolumeRequest)

  returns (NodePublishVolumeResponse) {}

  

 // unmount the volume from staging path

 rpc NodeUnpublishVolume (NodeUnpublishVolumeRequest)

  returns (NodeUnpublishVolumeResponse) {}

  

 // stats for the volume

 rpc NodeGetVolumeStats (NodeGetVolumeStatsRequest)

  returns (NodeGetVolumeStatsResponse) {}

  

 ...

 

 // Similar to NodeGetId

 rpc NodeGetInfo (NodeGetInfoRequest)

  returns (NodeGetInfoResponse) {}

}

需要注意的是，"Mount 阶段"在 CSI Node 里的接口，是由 NodeStageVolume 和 NodePublishVolume 两个接口共同实现的。我会在下一篇文章中，为你详细介绍这个设计的目的和具体的实现方式。

总结
在本篇文章里，我为你详细讲解了 FlexVolume 和 CSI 这两种自定义存储插件的工作原理。

可以看到，相比于 FlexVolume，CSI 的设计思想，把插件的职责从"两阶段处理"，扩展成了 Provision、Attach 和 Mount 三个阶段。其中，Provision 等价于"创建磁盘"，Attach 等价于"挂载磁盘到虚拟机"，Mount 等价于"将该磁盘格式化后，挂载在 Volume 的宿主机目录上"。

在有了 CSI 插件之后，Kubernetes 本身依然按照我在第 28 篇文章《PV、PVC、StorageClass，这些到底在说啥？》中所讲述的方式工作，唯一区别在于：

当 AttachDetachController 需要进行"Attach"操作时（"Attach 阶段"），它实际上会执行到 pkg/volume/csi 目录中，创建一个 VolumeAttachment 对象，从而触发 External Attacher 调用 CSI Controller 服务的 ControllerPublishVolume 方法。

当 VolumeManagerReconciler 需要进行"Mount"操作时（"Mount 阶段"），它实际上也会执行到 pkg/volume/csi 目录中，直接向 CSI Node 服务发起调用 NodePublishVolume 方法的请求。

以上，就是 CSI 插件最基本的工作原理了。

在下一篇文章里，我会和你一起实践一个 CSI 存储插件的完整实现过程。

思考题
假设现在，你的宿主机是阿里云的一台虚拟机，你要实现的容器持久化存储，是基于阿里云提供的云盘。你能准确地描述出，在 Provision、Attach 和 Mount 阶段，CSI 插件都需要做哪些操作吗？

在上一篇文章中，我已经为你详细讲解了 CSI 插件机制的设计原理。今天我将继续和你一起实践一个 CSI 插件的编写过程。

为了能够覆盖到 CSI 插件的所有功能，我这一次选择了 DigitalOcean 的块存储（Block Storage）服务，来作为实践对象。

DigitalOcean 是业界知名的"最简"公有云服务，即：它只提供虚拟机、存储、网络等为数不多的几个基础功能，其他功能一概不管。而这，恰恰就使得 DigitalOcean 成了我们在公有云上实践 Kubernetes 的最佳选择。

我们这次编写的 CSI 插件的功能，就是：让我们运行在 DigitalOcean 上的 Kubernetes 集群能够使用它的块存储服务，作为容器的持久化存储。

备注：在 DigitalOcean 上部署一个 Kubernetes 集群的过程，也很简单。你只需要先在 DigitalOcean 上创建几个虚拟机，然后按照我们在第 11 篇文章《从 0 到 1：搭建一个完整的 Kubernetes 集群》中从 0 到 1 的步骤直接部署即可。

而有了 CSI 插件之后，持久化存储的用法就非常简单了，你只需要创建一个如下所示的 StorageClass 对象即可：
```
kind: StorageClass

apiVersion: storage.k8s.io/v1

metadata:

 name: do-block-storage

 namespace: kube-system

 annotations:

  storageclass.kubernetes.io/is-default-class: "true"

provisioner: com.digitalocean.csi.dobs
```
有了这个 StorageClass，External Provisoner 就会为集群中新出现的 PVC 自动创建出 PV，然后调用 CSI 插件创建出这个 PV 对应的 Volume，这正是 CSI 体系中 Dynamic Provisioning 的实现方式。

备注：storageclass.kubernetes.io/is-default-class: "true"的意思，是使用这个 StorageClass 作为默认的持久化存储提供者。

不难看到，这个 StorageClass 里唯一引人注意的，是 provisioner=com.digitalocean.csi.dobs 这个字段。显然，这个字段告诉了 Kubernetes，请使用名叫 com.digitalocean.csi.dobs 的 CSI 插件来为我处理这个 StorageClass 相关的所有操作。

那么，Kubernetes 又是如何知道一个 CSI 插件的名字的呢？

这就需要从 CSI 插件的第一个服务 CSI Identity 说起了。

其实，一个 CSI 插件的代码结构非常简单，如下所示：

tree $GOPATH/src/github.com/digitalocean/csi-digitalocean/driver  

$GOPATH/src/github.com/digitalocean/csi-digitalocean/driver 

├── controller.go

├── driver.go

├── identity.go

├── mounter.go

└── node.go

其中，CSI Identity 服务的实现，就定义在了 driver 目录下的 identity.go 文件里。

当然，为了能够让 Kubernetes 访问到 CSI Identity 服务，我们需要先在 driver.go 文件里，定义一个标准的 gRPC Server，如下所示：

// Run starts the CSI plugin by communication over the given endpoint

func (d *Driver) Run() error {
 ...

 listener, err := net.Listen(u.Scheme, addr)

 ...

 d.srv = grpc.NewServer(grpc.UnaryInterceptor(errHandler))

 csi.RegisterIdentityServer(d.srv, d)

 csi.RegisterControllerServer(d.srv, d)

 csi.RegisterNodeServer(d.srv, d)

 d.ready = true // we're now ready to go!

 ...

 return d.srv.Serve(listener)

}

可以看到，只要把编写好的 gRPC Server 注册给 CSI，它就可以响应来自 External Components 的 CSI 请求了。

CSI Identity 服务中，最重要的接口是 GetPluginInfo，它返回的就是这个插件的名字和版本号，如下所示：

备注：CSI 各个服务的接口我在上一篇文章中已经介绍过，你也可以在这里找到它的 protoc 文件。

func (d *Driver) GetPluginInfo(ctx context.Context, req *csi.GetPluginInfoRequest) (*csi.GetPluginInfoResponse, error) {

 resp := &csi.GetPluginInfoResponse{

 Name:      driverName,

 VendorVersion: version,

 }

 ...

}

其中，driverName 的值，正是"com.digitalocean.csi.dobs"。所以说，Kubernetes 正是通过 GetPluginInfo 的返回值，来找到你在 StorageClass 里声明要使用的 CSI 插件的。

备注：CSI 要求插件的名字遵守"反向 DNS"格式。

另外一个GetPluginCapabilities 接口也很重要。这个接口返回的是这个 CSI 插件的"能力"。

比如，当你编写的 CSI 插件不准备实现"Provision 阶段"和"Attach 阶段"（比如，一个最简单的 NFS 存储插件就不需要这两个阶段）时，你就可以通过这个接口返回：本插件不提供 CSI Controller 服务，即：没有 csi.PluginCapability_Service_CONTROLLER_SERVICE 这个"能力"。这样，Kubernetes 就知道这个信息了。

最后，CSI Identity 服务还提供了一个 Probe 接口。Kubernetes 会调用它来检查这个 CSI 插件是否正常工作。

一般情况下，我建议你在编写插件时给它设置一个 Ready 标志，当插件的 gRPC Server 停止的时候，把这个 Ready 标志设置为 false。或者，你可以在这里访问一下插件的端口，类似于健康检查的做法。

备注：关于健康检查的问题，你可以再回顾一下第 15 篇文章《深入解析 Pod 对象（二）：使用进阶》中的相关内容。

然后，我们要开始编写 CSI 插件的第二个服务，即 CSI Controller 服务了。它的代码实现，在 controller.go 文件里。

在上一篇文章中我已经为你讲解过，这个服务主要实现的就是 Volume 管理流程中的"Provision 阶段"和"Attach 阶段"。

"Provision 阶段"对应的接口，是 CreateVolume 和 DeleteVolume，它们的调用者是 External Provisoner。以 CreateVolume 为例，它的主要逻辑如下所示：

func (d *Driver) CreateVolume(ctx context.Context, req *csi.CreateVolumeRequest) (*csi.CreateVolumeResponse, error) {

 ...

 volumeReq := &godo.VolumeCreateRequest{

 Region:     d.region,

 Name:      volumeName,

 Description:  createdByDO,

 SizeGigaBytes: size / GB,

 }

 ...

 vol, _, err := d.doClient.Storage.CreateVolume(ctx, volumeReq)

 ...

 resp := &csi.CreateVolumeResponse{

 Volume: &csi.Volume{

  Id:       vol.ID,

  CapacityBytes: size,

  AccessibleTopology: []*csi.Topology{

  {

   Segments: map[string]string{

   "region": d.region,

   },

  },

  },

 },

 }

 return resp, nil

}

可以看到，对于 DigitalOcean 这样的公有云来说，CreateVolume 需要做的操作，就是调用 DigitalOcean 块存储服务的 API，创建出一个存储卷（d.doClient.Storage.CreateVolume）。如果你使用的是其他类型的块存储（比如 Cinder、Ceph RBD 等），对应的操作也是类似地调用创建存储卷的 API。

而"Attach 阶段"对应的接口是 ControllerPublishVolume 和 ControllerUnpublishVolume，它们的调用者是 External Attacher。以 ControllerPublishVolume 为例，它的逻辑如下所示：

func (d *Driver) ControllerPublishVolume(ctx context.Context, req *csi.ControllerPublishVolumeRequest) (*csi.ControllerPublishVolumeResponse, error) {

 ...

 dropletID, err := strconv.Atoi(req.NodeId)

 // check if volume exist before trying to attach it

 _, resp, err := d.doClient.Storage.GetVolume(ctx, req.VolumeId)

 ...

 // check if droplet exist before trying to attach the volume to the droplet

 _, resp, err = d.doClient.Droplets.Get(ctx, dropletID)

 ...

 action, resp, err := d.doClient.StorageActions.Attach(ctx, req.VolumeId, dropletID)

 ...

 if action != nil {

 ll.Info("waiting until volume is attached")

 if err := d.waitAction(ctx, req.VolumeId, action.ID); err != nil {

 return nil, err

 }

 }

 ll.Info("volume is attached")

 return &csi.ControllerPublishVolumeResponse{}, nil

}

可以看到，对于 DigitalOcean 来说，ControllerPublishVolume 在"Attach 阶段"需要做的工作，是调用 DigitalOcean 的 API，将我们前面创建的存储卷，挂载到指定的虚拟机上（d.doClient.StorageActions.Attach）。

其中，存储卷由请求中的 VolumeId 来指定。而虚拟机，也就是将要运行 Pod 的宿主机，则由请求中的 NodeId 来指定。这些参数，都是 External Attacher 在发起请求时需要设置的。

我在上一篇文章中已经为你介绍过，External Attacher 的工作原理，是监听（Watch）了一种名叫 VolumeAttachment 的 API 对象。这种 API 对象的主要字段如下所示：

// VolumeAttachmentSpec is the specification of a VolumeAttachment request.

type VolumeAttachmentSpec struct {

 // Attacher indicates the name of the volume driver that MUST handle this

 // request. This is the name returned by GetPluginName().

 Attacher string

 // Source represents the volume that should be attached.

 Source VolumeAttachmentSource

 // The node that the volume should be attached to.

 NodeName string

}

而这个对象的生命周期，正是由 AttachDetachController 负责管理的（这里，你可以再回顾一下第 28 篇文章《PV、PVC、StorageClass，这些到底在说啥？》中的相关内容）。

这个控制循环的职责，是不断检查 Pod 所对应的 PV，在它所绑定的宿主机上的挂载情况，从而决定是否需要对这个 PV 进行 Attach（或者 Dettach）操作。

而这个 Attach 操作，在 CSI 体系里，就是创建出上面这样一个 VolumeAttachment 对象。可以看到，Attach 操作所需的 PV 的名字（Source）、宿主机的名字（NodeName）、存储插件的名字（Attacher），都是这个 VolumeAttachment 对象的一部分。

而当 External Attacher 监听到这样的一个对象出现之后，就可以立即使用 VolumeAttachment 里的这些字段，封装成一个 gRPC 请求调用 CSI Controller 的 ControllerPublishVolume 方法。

最后，我们就可以编写 CSI Node 服务了。

CSI Node 服务对应的，是 Volume 管理流程里的"Mount 阶段"。它的代码实现，在 node.go 文件里。

我在上一篇文章里曾经提到过，kubelet 的 VolumeManagerReconciler 控制循环会直接调用 CSI Node 服务来完成 Volume 的"Mount 阶段"。

不过，在具体的实现中，这个"Mount 阶段"的处理其实被细分成了 NodeStageVolume 和 NodePublishVolume 这两个接口。

这里的原因其实也很容易理解：我在前面第 28 篇文章《PV、PVC、StorageClass，这些到底在说啥？》中曾经介绍过，对于磁盘以及块设备来说，它们被 Attach 到宿主机上之后，就成为了宿主机上的一个待用存储设备。而到了"Mount 阶段"，我们首先需要格式化这个设备，然后才能把它挂载到 Volume 对应的宿主机目录上。

在 kubelet 的 VolumeManagerReconciler 控制循环中，这两步操作分别叫作MountDevice 和 SetUp。

其中，MountDevice 操作，就是直接调用了 CSI Node 服务里的 NodeStageVolume 接口。顾名思义，这个接口的作用，就是格式化 Volume 在宿主机上对应的存储设备，然后挂载到一个临时目录（Staging 目录）上。

对于 DigitalOcean 来说，它对 NodeStageVolume 接口的实现如下所示：

func (d *Driver) NodeStageVolume(ctx context.Context, req *csi.NodeStageVolumeRequest) (*csi.NodeStageVolumeResponse, error) {

 ...

 vol, resp, err := d.doClient.Storage.GetVolume(ctx, req.VolumeId)

 ...

 source := getDiskSource(vol.Name)

 target := req.StagingTargetPath

 ...

 if !formatted {

 ll.Info("formatting the volume for staging")

 if err := d.mounter.Format(source, fsType); err != nil {

  return nil, status.Error(codes.Internal, err.Error())

 }

 } else {

 ll.Info("source device is already formatted")

 }

...

 if !mounted {

 if err := d.mounter.Mount(source, target, fsType, options...); err != nil {

  return nil, status.Error(codes.Internal, err.Error())

 }

 } else {

 ll.Info("source device is already mounted to the target path")

 }

 ...

 return &csi.NodeStageVolumeResponse{}, nil

}

可以看到，在 NodeStageVolume 的实现里，我们首先通过 DigitalOcean 的 API 获取到了这个 Volume 对应的设备路径（getDiskSource）；然后，我们把这个设备格式化成指定的格式（ d.mounter.Format）；最后，我们把格式化后的设备挂载到了一个临时的 Staging 目录（StagingTargetPath）下。

而 SetUp 操作则会调用 CSI Node 服务的 NodePublishVolume 接口。有了上述对设备的预处理工作后，它的实现就非常简单了，如下所示：

func (d *Driver) NodePublishVolume(ctx context.Context, req *csi.NodePublishVolumeRequest) (*csi.NodePublishVolumeResponse, error) {

 ...

 source := req.StagingTargetPath

 target := req.TargetPath

 mnt := req.VolumeCapability.GetMount()

 options := mnt.MountFlag

  ...

 if !mounted {

 ll.Info("mounting the volume")

 if err := d.mounter.Mount(source, target, fsType, options...); err != nil {

  return nil, status.Error(codes.Internal, err.Error())

 }

 } else {

 ll.Info("volume is already mounted")

 }

 return &csi.NodePublishVolumeResponse{}, nil

}

可以看到，在这一步实现中，我们只需要做一步操作，即：将 Staging 目录，绑定挂载到 Volume 对应的宿主机目录上。

由于 Staging 目录，正是 Volume 对应的设备被格式化后挂载在宿主机上的位置，所以当它和 Volume 的宿主机目录绑定挂载之后，这个 Volume 宿主机目录的"持久化"处理也就完成了。

当然，我在前面也曾经提到过，对于文件系统类型的存储服务来说，比如 NFS 和 GlusterFS 等，它们并没有一个对应的磁盘"设备"存在于宿主机上，所以 kubelet 在 VolumeManagerReconciler 控制循环中，会跳过 MountDevice 操作而直接执行 SetUp 操作。所以对于它们来说，也就不需要实现 NodeStageVolume 接口了。

在编写完了 CSI 插件之后，我们就可以把这个插件和 External Components 一起部署起来。

首先，我们需要创建一个 DigitalOcean client 授权需要使用的 Secret 对象，如下所示：
```
apiVersion: v1

kind: Secret

metadata:

 name: digitalocean

 namespace: kube-system

stringData:

 access-token: "a05dd2f26b9b9ac2asdas__REPLACE_ME____123cb5d1ec17513e06da"
```
接下来，我们通过一句指令就可以将 CSI 插件部署起来：
```
$ kubectl apply -f https://raw.githubusercontent.com/digitalocean/csi-digitalocean/master/deploy/kubernetes/releases/csi-digitalocean-v0.2.0.yaml
```
这个 CSI 插件的 YAML 文件的主要内容如下所示（其中，非重要的内容已经被略去）：
```
kind: DaemonSet

apiVersion: apps/v1beta2

metadata:

 name: csi-do-node

 namespace: kube-system

spec:

 selector:

  matchLabels:

   app: csi-do-node

 template:

  metadata:

   labels:

​    app: csi-do-node

​    role: csi-do

  spec:

   serviceAccount: csi-do-node-sa

   hostNetwork: true

   containers:

​    \- name: driver-registrar

​     image: quay.io/k8scsi/driver-registrar:v0.3.0

​     ...

​    \- name: csi-do-plugin

​     image: digitalocean/do-csi-plugin:v0.2.0

​     args :

​      \- "--endpoint=$(CSI_ENDPOINT)"

​      \- "--token=$(DIGITALOCEAN_ACCESS_TOKEN)"

​      \- "--url=$(DIGITALOCEAN_API_URL)"

​     env:

​      \- name: CSI_ENDPOINT

​       value: unix:///csi/csi.sock

​      \- name: DIGITALOCEAN_API_URL

​       value: https://api.digitalocean.com/

​      \- name: DIGITALOCEAN_ACCESS_TOKEN

​       valueFrom:

​        secretKeyRef:

​         name: digitalocean

​         key: access-token

​     imagePullPolicy: "Always"

​     securityContext:

​      privileged: true

​      capabilities:

​       add: ["SYS_ADMIN"]

​      allowPrivilegeEscalation: true

​     volumeMounts:

​      \- name: plugin-dir

​       mountPath: /csi

​      \- name: pods-mount-dir

​       mountPath: /var/lib/kubelet

​       mountPropagation: "Bidirectional"

​      \- name: device-dir

​       mountPath: /dev

   volumes:

​    \- name: plugin-dir

​     hostPath:

​      path: /var/lib/kubelet/plugins/com.digitalocean.csi.dobs

​      type: DirectoryOrCreate

​    \- name: pods-mount-dir

​     hostPath:

​      path: /var/lib/kubelet

​      type: Directory

​    \- name: device-dir

​     hostPath:

​      path: /dev

\---

kind: StatefulSet

apiVersion: apps/v1beta1

metadata:

 name: csi-do-controller

 namespace: kube-system

spec:

 serviceName: "csi-do"

 replicas: 1

 template:

  metadata:

   labels:

​    app: csi-do-controller

​    role: csi-do

  spec:

   serviceAccount: csi-do-controller-sa

   containers:

​    \- name: csi-provisioner

​     image: quay.io/k8scsi/csi-provisioner:v0.3.0

​     ...

​    \- name: csi-attacher

​     image: quay.io/k8scsi/csi-attacher:v0.3.0

​     ...

​    \- name: csi-do-plugin

​     image: digitalocean/do-csi-plugin:v0.2.0

​     args :

​      \- "--endpoint=$(CSI_ENDPOINT)"

​      \- "--token=$(DIGITALOCEAN_ACCESS_TOKEN)"

​      \- "--url=$(DIGITALOCEAN_API_URL)"

​     env:

​      \- name: CSI_ENDPOINT

​       value: unix:///var/lib/csi/sockets/pluginproxy/csi.sock

​      \- name: DIGITALOCEAN_API_URL

​       value: https://api.digitalocean.com/

​      \- name: DIGITALOCEAN_ACCESS_TOKEN

​       valueFrom:

​        secretKeyRef:

​         name: digitalocean

​         key: access-token

​     imagePullPolicy: "Always"

​     volumeMounts:

​      \- name: socket-dir

​       mountPath: /var/lib/csi/sockets/pluginproxy/

   volumes:

​    \- name: socket-dir

​     emptyDir: {}
```
可以看到，我们编写的 CSI 插件只有一个二进制文件，它的镜像是 digitalocean/do-csi-plugin:v0.2.0。

而我们部署 CSI 插件的常用原则是：
第一，通过 DaemonSet 在每个节点上都启动一个 CSI 插件，来为 kubelet 提供 CSI Node 服务。这是因为，CSI Node 服务需要被 kubelet 直接调用，所以它要和 kubelet"一对一"地部署起来。

此外，在上述 DaemonSet 的定义里面，除了 CSI 插件，我们还以 sidecar 的方式运行着 driver-registrar 这个外部组件。它的作用，是向 kubelet 注册这个 CSI 插件。这个注册过程使用的插件信息，则通过访问同一个 Pod 里的 CSI 插件容器的 Identity 服务获取到。

需要注意的是，由于 CSI 插件运行在一个容器里，那么 CSI Node 服务在"Mount 阶段"执行的挂载操作，实际上是发生在这个容器的 Mount Namespace 里的。可是，我们真正希望执行挂载操作的对象，都是宿主机 /var/lib/kubelet 目录下的文件和目录。

所以，在定义 DaemonSet Pod 的时候，我们需要把宿主机的 /var/lib/kubelet 以 Volume 的方式挂载进 CSI 插件容器的同名目录下，然后设置这个 Volume 的 mountPropagation=Bidirectional，即开启双向挂载传播，从而将容器在这个目录下进行的挂载操作"传播"给宿主机，反之亦然。

第二，通过 StatefulSet 在任意一个节点上再启动一个 CSI 插件，为 External Components 提供 CSI Controller 服务。所以，作为 CSI Controller 服务的调用者，External Provisioner 和 External Attacher 这两个外部组件，就需要以 sidecar 的方式和这次部署的 CSI 插件定义在同一个 Pod 里。

你可能会好奇，为什么我们会用 StatefulSet 而不是 Deployment 来运行这个 CSI 插件呢。

这是因为，由于 StatefulSet 需要确保应用拓扑状态的稳定性，所以它对 Pod 的更新，是严格保证顺序的，即：只有在前一个 Pod 停止并删除之后，它才会创建并启动下一个 Pod。

而像我们上面这样将 StatefulSet 的 replicas 设置为 1 的话，StatefulSet 就会确保 Pod 被删除重建的时候，永远有且只有一个 CSI 插件的 Pod 运行在集群中。这对 CSI 插件的正确性来说，至关重要。

而在今天这篇文章一开始，我们就已经定义了这个 CSI 插件对应的 StorageClass（即：do-block-storage），所以你接下来只需要定义一个声明使用这个 StorageClass 的 PVC 即可，如下所示：
```
apiVersion: v1

kind: PersistentVolumeClaim

metadata:

 name: csi-pvc

spec:

 accessModes:

 \- ReadWriteOnce

 resources:

  requests:

   storage: 5Gi

 storageClassName: do-block-storage
```
当你把上述 PVC 提交给 Kubernetes 之后，你就可以在 Pod 里声明使用这个 csi-pvc 来作为持久化存储了。这一部分使用 PV 和 PVC 的内容，我就不再赘述了。

总结
在今天这篇文章中，我以一个 DigitalOcean 的 CSI 插件为例，和你分享了编写 CSI 插件的具体流程。

基于这些讲述，你现在应该已经对 Kubernetes 持久化存储体系有了一个更加全面和深入的认识。

举个例子，对于一个部署了 CSI 存储插件的 Kubernetes 集群来说：

当用户创建了一个 PVC 之后，你前面部署的 StatefulSet 里的 External Provisioner 容器，就会监听到这个 PVC 的诞生，然后调用同一个 Pod 里的 CSI 插件的 CSI Controller 服务的 CreateVolume 方法，为你创建出对应的 PV。

这时候，运行在 Kubernetes Master 节点上的 Volume Controller，就会通过 PersistentVolumeController 控制循环，发现这对新创建出来的 PV 和 PVC，并且看到它们声明的是同一个 StorageClass。所以，它会把这一对 PV 和 PVC 绑定起来，使 PVC 进入 Bound 状态。

然后，用户创建了一个声明使用上述 PVC 的 Pod，并且这个 Pod 被调度器调度到了宿主机 A 上。这时候，Volume Controller 的 AttachDetachController 控制循环就会发现，上述 PVC 对应的 Volume，需要被 Attach 到宿主机 A 上。所以，AttachDetachController 会创建一个 VolumeAttachment 对象，这个对象携带了宿主机 A 和待处理的 Volume 的名字。

这样，StatefulSet 里的 External Attacher 容器，就会监听到这个 VolumeAttachment 对象的诞生。于是，它就会使用这个对象里的宿主机和 Volume 名字，调用同一个 Pod 里的 CSI 插件的 CSI Controller 服务的 ControllerPublishVolume 方法，完成"Attach 阶段"。

上述过程完成后，运行在宿主机 A 上的 kubelet，就会通过 VolumeManagerReconciler 控制循环，发现当前宿主机上有一个 Volume 对应的存储设备（比如磁盘）已经被 Attach 到了某个设备目录下。于是 kubelet 就会调用同一台宿主机上的 CSI 插件的 CSI Node 服务的 NodeStageVolume 和 NodePublishVolume 方法，完成这个 Volume 的"Mount 阶段"。

至此，一个完整的持久化 Volume 的创建和挂载流程就结束了。

思考题
请你根据编写 FlexVolume 和 CSI 插件的流程，分析一下什么时候该使用 FlexVolume，什么时候应该使用 CSI？

# 容器网络（该DOCKER5了）
在 Docker 的默认配置下，不同宿主机上的容器通过 IP 地址进行互相访问是根本做不到的。

而正是为了解决这个容器"跨主通信"的问题，社区里才出现了那么多的容器网络方案。而且，相信你一直以来都有这样的疑问：这些网络方案的工作原理到底是什么？

要理解容器"跨主通信"的原理，就一定要先从 Flannel 这个项目说起。

Flannel 项目是 CoreOS 公司主推的容器网络方案。事实上，Flannel 项目本身只是一个框架，真正为我们提供容器网络功能的，是 Flannel 的后端实现。目前，Flannel 支持三种后端实现，分别是：

VXLAN；

host-gw；

UDP。

这三种不同的后端实现，正代表了三种容器跨主网络的主流实现方法。其中，host-gw 模式，我会在下一篇文章中再做详细介绍。

而 UDP 模式，是 Flannel 项目最早支持的一种方式，却也是性能最差的一种方式。所以，这个模式目前已经被弃用。不过，Flannel 之所以最先选择 UDP 模式，就是因为这种模式是最直接、也是最容易理解的容器跨主网络实现。

所以，在今天这篇文章中，我会先从 UDP 模式开始，来为你讲解容器"跨主网络"的实现原理。

在这个例子中，我有两台宿主机。

宿主机 Node 1 上有一个容器 container-1，它的 IP 地址是 100.96.1.2，对应的 docker0 网桥的地址是：100.96.1.1/24。

宿主机 Node 2 上有一个容器 container-2，它的 IP 地址是 100.96.2.3，对应的 docker0 网桥的地址是：100.96.2.1/24。

我们现在的任务，就是让 container-1 访问 container-2。

这种情况下，container-1 容器里的进程发起的 IP 包，其源地址就是 100.96.1.2，目的地址就是 100.96.2.3。由于目的地址 100.96.2.3 并不在 Node 1 的 docker0 网桥的网段里，所以这个 IP 包会被交给默认路由规则，通过容器的网关进入 docker0 网桥（如果是同一台宿主机上的容器间通信，走的是直连规则），从而出现在宿主机上。

这时候，这个 IP 包的下一个目的地，就取决于宿主机上的路由规则了。此时，Flannel 已经在宿主机上创建出了一系列的路由规则，以 Node 1 为例，如下所示：

\# 在 Node 1 上

$ ip route

default via 10.168.0.1 dev eth0

100.96.0.0/16 dev flannel0  proto kernel  scope link  src 100.96.1.0

100.96.1.0/24 dev docker0  proto kernel  scope link  src 100.96.1.1

10.168.0.0/24 dev eth0  proto kernel  scope link  src 10.168.0.2

可以看到，由于我们的 IP 包的目的地址是 100.96.2.3，它匹配不到本机 docker0 网桥对应的 100.96.1.0/24 网段，只能匹配到第二条、也就是 100.96.0.0/16 对应的这条路由规则，从而进入到一个叫作 flannel0 的设备中。

而这个 flannel0 设备的类型就比较有意思了：它是一个 TUN 设备（Tunnel 设备）。

在 Linux 中，TUN 设备是一种工作在三层（Network Layer）的虚拟网络设备。TUN 设备的功能非常简单，即：在操作系统内核和用户应用程序之间传递 IP 包。

以 flannel0 设备为例：

像上面提到的情况，当操作系统将一个 IP 包发送给 flannel0 设备之后，flannel0 就会把这个 IP 包，交给创建这个设备的应用程序，也就是 Flannel 进程。这是一个从内核态（Linux 操作系统）向用户态（Flannel 进程）的流动方向。

反之，如果 Flannel 进程向 flannel0 设备发送了一个 IP 包，那么这个 IP 包就会出现在宿主机网络栈中，然后根据宿主机的路由表进行下一步处理。这是一个从用户态向内核态的流动方向。

所以，当 IP 包从容器经过 docker0 出现在宿主机，然后又根据路由表进入 flannel0 设备后，宿主机上的 flanneld 进程（Flannel 项目在每个宿主机上的主进程），就会收到这个 IP 包。然后，flanneld 看到了这个 IP 包的目的地址，是 100.96.2.3，就把它发送给了 Node 2 宿主机。

等一下，flanneld 又是如何知道这个 IP 地址对应的容器，是运行在 Node 2 上的呢？

这里，就用到了 Flannel 项目里一个非常重要的概念：子网（Subnet）。

事实上，在由 Flannel 管理的容器网络里，一台宿主机上的所有容器，都属于该宿主机被分配的一个"子网"。在我们的例子中，Node 1 的子网是 100.96.1.0/24，container-1 的 IP 地址是 100.96.1.2。Node 2 的子网是 100.96.2.0/24，container-2 的 IP 地址是 100.96.2.3。

而这些子网与宿主机的对应关系，正是保存在 Etcd 当中，如下所示：

$ etcdctl ls /coreos.com/network/subnets

/coreos.com/network/subnets/100.96.1.0-24

/coreos.com/network/subnets/100.96.2.0-24

/coreos.com/network/subnets/100.96.3.0-24

所以，flanneld 进程在处理由 flannel0 传入的 IP 包时，就可以根据目的 IP 的地址（比如 100.96.2.3），匹配到对应的子网（比如 100.96.2.0/24），从 Etcd 中找到这个子网对应的宿主机的 IP 地址是 10.168.0.3，如下所示：

$ etcdctl get /coreos.com/network/subnets/100.96.2.0-24

{"PublicIP":"10.168.0.3"}

而对于 flanneld 来说，只要 Node 1 和 Node 2 是互通的，那么 flanneld 作为 Node 1 上的一个普通进程，就一定可以通过上述 IP 地址（10.168.0.3）访问到 Node 2，这没有任何问题。

所以说，flanneld 在收到 container-1 发给 container-2 的 IP 包之后，就会把这个 IP 包直接封装在一个 UDP 包里，然后发送给 Node 2。不难理解，这个 UDP 包的源地址，就是 flanneld 所在的 Node 1 的地址，而目的地址，则是 container-2 所在的宿主机 Node 2 的地址。

当然，这个请求得以完成的原因是，每台宿主机上的 flanneld，都监听着一个 8285 端口，所以 flanneld 只要把 UDP 包发往 Node 2 的 8285 端口即可。

通过这样一个普通的、宿主机之间的 UDP 通信，一个 UDP 包就从 Node 1 到达了 Node 2。而 Node 2 上监听 8285 端口的进程也是 flanneld，所以这时候，flanneld 就可以从这个 UDP 包里解析出封装在里面的、container-1 发来的原 IP 包。

而接下来 flanneld 的工作就非常简单了：flanneld 会直接把这个 IP 包发送给它所管理的 TUN 设备，即 flannel0 设备。

根据我前面讲解的 TUN 设备的原理，这正是一个从用户态向内核态的流动方向（Flannel 进程向 TUN 设备发送数据包），所以 Linux 内核网络栈就会负责处理这个 IP 包，具体的处理方法，就是通过本机的路由表来寻找这个 IP 包的下一步流向。
而 Node 2 上的路由表，跟 Node 1 非常类似，如下所示：

\# 在 Node 2 上

$ ip route

default via 10.168.0.1 dev eth0

100.96.0.0/16 dev flannel0  proto kernel  scope link  src 100.96.2.0

100.96.2.0/24 dev docker0  proto kernel  scope link  src 100.96.2.1

10.168.0.0/24 dev eth0  proto kernel  scope link  src 10.168.0.3

由于这个 IP 包的目的地址是 100.96.2.3，它跟第三条、也就是 100.96.2.0/24 网段对应的路由规则匹配更加精确。所以，Linux 内核就会按照这条路由规则，把这个 IP 包转发给 docker0 网桥。

接下来的流程，就如同我在上一篇文章《浅谈容器网络》中和你分享的那样，docker0 网桥会扮演二层交换机的角色，将数据包发送给正确的端口，进而通过 Veth Pair 设备进入到 container-2 的 Network Namespace 里。

而 container-2 返回给 container-1 的数据包，则会经过与上述过程完全相反的路径回到 container-1 中。

需要注意的是，上述流程要正确工作还有一个重要的前提，那就是 docker0 网桥的地址范围必须是 Flannel 为宿主机分配的子网。这个很容易实现，以 Node 1 为例，你只需要给它上面的 Docker Daemon 启动时配置如下所示的 bip 参数即可：

$ FLANNEL_SUBNET=100.96.1.1/24

$ dockerd --bip=$FLANNEL_SUBNET ...

以上，就是基于 Flannel UDP 模式的跨主通信的基本原理了。我把它总结成了一幅原理图，如下所示。

图 1 基于 Flannel UDP 模式的跨主通信的基本原理

可以看到，Flannel UDP 模式提供的其实是一个三层的 Overlay 网络，即：它首先对发出端的 IP 包进行 UDP 封装，然后在接收端进行解封装拿到原始的 IP 包，进而把这个 IP 包转发给目标容器。这就好比，Flannel 在不同宿主机上的两个容器之间打通了一条"隧道"，使得这两个容器可以直接使用 IP 地址进行通信，而无需关心容器和宿主机的分布情况。

我前面曾经提到，上述 UDP 模式有严重的性能问题，所以已经被废弃了。通过我上面的讲述，你有没有发现性能问题出现在了哪里呢？

实际上，相比于两台宿主机之间的直接通信，基于 Flannel UDP 模式的容器通信多了一个额外的步骤，即 flanneld 的处理过程。而这个过程，由于使用到了 flannel0 这个 TUN 设备，仅在发出 IP 包的过程中，就需要经过三次用户态与内核态之间的数据拷贝，如下所示：

图 2 TUN 设备示意图

我们可以看到：

第一次：用户态的容器进程发出的 IP 包经过 docker0 网桥进入内核态；

第二次：IP 包根据路由表进入 TUN（flannel0）设备，从而回到用户态的 flanneld 进程；

第三次：flanneld 进行 UDP 封包之后重新进入内核态，将 UDP 包通过宿主机的 eth0 发出去。

此外，我们还可以看到，Flannel 进行 UDP 封装（Encapsulation）和解封装（Decapsulation）的过程，也都是在用户态完成的。在 Linux 操作系统中，上述这些上下文切换和用户态操作的代价其实是比较高的，这也正是造成 Flannel UDP 模式性能不好的主要原因。

所以说，我们在进行系统级编程的时候，有一个非常重要的优化原则，就是要减少用户态到内核态的切换次数，并且把核心的处理逻辑都放在内核态进行。这也是为什么，Flannel 后来支持的VXLAN 模式，逐渐成为了主流的容器网络方案的原因。

VXLAN，即 Virtual Extensible LAN（虚拟可扩展局域网），是 Linux 内核本身就支持的一种网络虚似化技术。所以说，VXLAN 可以完全在内核态实现上述封装和解封装的工作，从而通过与前面相似的"隧道"机制，构建出覆盖网络（Overlay Network）。

VXLAN 的覆盖网络的设计思想是：在现有的三层网络之上，"覆盖"一层虚拟的、由内核 VXLAN 模块负责维护的二层网络，使得连接在这个 VXLAN 二层网络上的"主机"（虚拟机或者容器都可以）之间，可以像在同一个局域网（LAN）里那样自由通信。当然，实际上，这些"主机"可能分布在不同的宿主机上，甚至是分布在不同的物理机房里。

而为了能够在二层网络上打通"隧道"，VXLAN 会在宿主机上设置一个特殊的网络设备作为"隧道"的两端。这个设备就叫作 VTEP，即：VXLAN Tunnel End Point（虚拟隧道端点）。

而 VTEP 设备的作用，其实跟前面的 flanneld 进程非常相似。只不过，它进行封装和解封装的对象，是二层数据帧（Ethernet frame）；而且这个工作的执行流程，全部是在内核里完成的（因为 VXLAN 本身就是 Linux 内核中的一个模块）。

上述基于 VTEP 设备进行"隧道"通信的流程，我也为你总结成了一幅图，如下所示：

图 3 基于 Flannel VXLAN 模式的跨主通信的基本原理

可以看到，图中每台宿主机上名叫 flannel.1 的设备，就是 VXLAN 所需的 VTEP 设备，它既有 IP 地址，也有 MAC 地址。

现在，我们的 container-1 的 IP 地址是 10.1.15.2，要访问的 container-2 的 IP 地址是 10.1.16.3。

那么，与前面 UDP 模式的流程类似，当 container-1 发出请求之后，这个目的地址是 10.1.16.3 的 IP 包，会先出现在 docker0 网桥，然后被路由到本机 flannel.1 设备进行处理。也就是说，来到了"隧道"的入口。为了方便叙述，我接下来会把这个 IP 包称为"原始 IP 包"。

为了能够将"原始 IP 包"封装并且发送到正确的宿主机，VXLAN 就需要找到这条"隧道"的出口，即：目的宿主机的 VTEP 设备。

而这个设备的信息，正是每台宿主机上的 flanneld 进程负责维护的。

比如，当 Node 2 启动并加入 Flannel 网络之后，在 Node 1（以及所有其他节点）上，flanneld 就会添加一条如下所示的路由规则：

$ route -n

Kernel IP routing table

Destination   Gateway     Genmask     Flags Metric Ref   Use Iface

...

10.1.16.0    10.1.16.0    255.255.255.0  UG   0    0     0 flannel.1

这条规则的意思是：凡是发往 10.1.16.0/24 网段的 IP 包，都需要经过 flannel.1 设备发出，并且，它最后被发往的网关地址是：10.1.16.0。

从图 3 的 Flannel VXLAN 模式的流程图中我们可以看到，10.1.16.0 正是 Node 2 上的 VTEP 设备（也就是 flannel.1 设备）的 IP 地址。

为了方便叙述，接下来我会把 Node 1 和 Node 2 上的 flannel.1 设备分别称为"源 VTEP 设备"和"目的 VTEP 设备"。

而这些 VTEP 设备之间，就需要想办法组成一个虚拟的二层网络，即：通过二层数据帧进行通信。

所以在我们的例子中，"源 VTEP 设备"收到"原始 IP 包"后，就要想办法把"原始 IP 包"加上一个目的 MAC 地址，封装成一个二层数据帧，然后发送给"目的 VTEP 设备"（当然，这么做还是因为这个 IP 包的目的地址不是本机）。

这里需要解决的问题就是："目的 VTEP 设备"的 MAC 地址是什么？

此时，根据前面的路由记录，我们已经知道了"目的 VTEP 设备"的 IP 地址。而要根据三层 IP 地址查询对应的二层 MAC 地址，这正是 ARP（Address Resolution Protocol ）表的功能。

而这里要用到的 ARP 记录，也是 flanneld 进程在 Node 2 节点启动时，自动添加在 Node 1 上的。我们可以通过 ip 命令看到它，如下所示：

\# 在 Node 1 上

$ ip neigh show dev flannel.1

10.1.16.0 lladdr 5e:f8:4f:00:e3:37 PERMANENT

这条记录的意思非常明确，即：IP 地址 10.1.16.0，对应的 MAC 地址是 5e:f8:4f:00:e3:37。

可以看到，最新版本的 Flannel 并不依赖 L3 MISS 事件和 ARP 学习，而会在每台节点启动时把它的 VTEP 设备对应的 ARP 记录，直接下放到其他每台宿主机上。

有了这个"目的 VTEP 设备"的 MAC 地址，Linux 内核就可以开始二层封包工作了。这个二层帧的格式，如下所示：

图 4 Flannel VXLAN 模式的内部帧

可以看到，Linux 内核会把"目的 VTEP 设备"的 MAC 地址，填写在图中的 Inner Ethernet Header 字段，得到一个二层数据帧。

需要注意的是，上述封包过程只是加一个二层头，不会改变"原始 IP 包"的内容。所以图中的 Inner IP Header 字段，依然是 container-2 的 IP 地址，即 10.1.16.3。

但是，上面提到的这些 VTEP 设备的 MAC 地址，对于宿主机网络来说并没有什么实际意义。所以上面封装出来的这个数据帧，并不能在我们的宿主机二层网络里传输。为了方便叙述，我们把它称为"内部数据帧"（Inner Ethernet Frame）。

所以接下来，Linux 内核还需要再把"内部数据帧"进一步封装成为宿主机网络里的一个普通的数据帧，好让它"载着""内部数据帧"，通过宿主机的 eth0 网卡进行传输。

我们把这次要封装出来的、宿主机对应的数据帧称为"外部数据帧"（Outer Ethernet Frame）。

为了实现这个"搭便车"的机制，Linux 内核会在"内部数据帧"前面，加上一个特殊的 VXLAN 头，用来表示这个"乘客"实际上是一个 VXLAN 要使用的数据帧。

而这个 VXLAN 头里有一个重要的标志叫作VNI，它是 VTEP 设备识别某个数据帧是不是应该归自己处理的重要标识。而在 Flannel 中，VNI 的默认值是 1，这也是为何，宿主机上的 VTEP 设备都叫作 flannel.1 的原因，这里的"1"，其实就是 VNI 的值。
然后，Linux 内核会把这个数据帧封装进一个 UDP 包里发出去。

所以，跟 UDP 模式类似，在宿主机看来，它会以为自己的 flannel.1 设备只是在向另外一台宿主机的 flannel.1 设备，发起了一次普通的 UDP 链接。它哪里会知道，这个 UDP 包里面，其实是一个完整的二层数据帧。这是不是跟特洛伊木马的故事非常像呢？

不过，不要忘了，一个 flannel.1 设备只知道另一端的 flannel.1 设备的 MAC 地址，却不知道对应的宿主机地址是什么。

也就是说，这个 UDP 包该发给哪台宿主机呢？

在这种场景下，flannel.1 设备实际上要扮演一个"网桥"的角色，在二层网络进行 UDP 包的转发。而在 Linux 内核里面，"网桥"设备进行转发的依据，来自于一个叫作 FDB（Forwarding Database）的转发数据库。

不难想到，这个 flannel.1"网桥"对应的 FDB 信息，也是 flanneld 进程负责维护的。它的内容可以通过 bridge fdb 命令查看到，如下所示：

\# 在 Node 1 上，使用"目的 VTEP 设备"的 MAC 地址进行查询

$ bridge fdb show flannel.1 | grep 5e:f8:4f:00:e3:37

5e:f8:4f:00:e3:37 dev flannel.1 dst 10.168.0.3 self permanent

可以看到，在上面这条 FDB 记录里，指定了这样一条规则，即：

发往我们前面提到的"目的 VTEP 设备"（MAC 地址是 5e:f8:4f:00:e3:37）的二层数据帧，应该通过 flannel.1 设备，发往 IP 地址为 10.168.0.3 的主机。显然，这台主机正是 Node 2，UDP 包要发往的目的地就找到了。

所以接下来的流程，就是一个正常的、宿主机网络上的封包工作。

我们知道，UDP 包是一个四层数据包，所以 Linux 内核会在它前面加上一个 IP 头，即原理图中的 Outer IP Header，组成一个 IP 包。并且，在这个 IP 头里，会填上前面通过 FDB 查询出来的目的主机的 IP 地址，即 Node 2 的 IP 地址 10.168.0.3。

然后，Linux 内核再在这个 IP 包前面加上二层数据帧头，即原理图中的 Outer Ethernet Header，并把 Node 2 的 MAC 地址填进去。这个 MAC 地址本身，是 Node 1 的 ARP 表要学习的内容，无需 Flannel 维护。这时候，我们封装出来的"外部数据帧"的格式，如下所示：

图 5 Flannel VXLAN 模式的外部帧

这样，封包工作就宣告完成了。

接下来，Node 1 上的 flannel.1 设备就可以把这个数据帧从 Node 1 的 eth0 网卡发出去。显然，这个帧会经过宿主机网络来到 Node 2 的 eth0 网卡。

这时候，Node 2 的内核网络栈会发现这个数据帧里有 VXLAN Header，并且 VNI=1。所以 Linux 内核会对它进行拆包，拿到里面的内部数据帧，然后根据 VNI 的值，把它交给 Node 2 上的 flannel.1 设备。

而 flannel.1 设备则会进一步拆包，取出"原始 IP 包"。接下来就回到了我在上一篇文章中分享的单机容器网络的处理流程。最终，IP 包就进入到了 container-2 容器的 Network Namespace 里。

以上，就是 Flannel VXLAN 模式的具体工作原理了。

总结
在本篇文章中，我为你详细讲解了 Flannel UDP 和 VXLAN 模式的工作原理。这两种模式其实都可以称作"隧道"机制，也是很多其他容器网络插件的基础。比如 Weave 的两种模式，以及 Docker 的 Overlay 模式。

此外，从上面的讲解中我们可以看到，VXLAN 模式组建的覆盖网络，其实就是一个由不同宿主机上的 VTEP 设备，也就是 flannel.1 设备组成的虚拟二层网络。对于 VTEP 设备来说，它发出的"内部数据帧"就仿佛是一直在这个虚拟的二层网络上流动。这，也正是覆盖网络的含义。

备注：如果你想要在我们前面部署的集群中实践 Flannel 的话，可以在 Master 节点上执行如下命令来替换网络插件。
第一步，执行

MY_ZUES_CHAR

rm -rf /etc/cni/net.d/*；

第二步，执行$ kubectl delete -f "https://cloud.weave.works/k8s/net?k8s-version=1.11"；

第三步，在/etc/kubernetes/manifests/kube-controller-manager.yaml里，为容器启动命令添加如下两个参数：

--allocate-node-cidrs=true

--cluster-cidr=10.244.0.0/16

第四步， 重启所有 kubelet；

第五步， 执行$ kubectl create -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml。

思考题
可以看到，Flannel 通过上述的"隧道"机制，实现了容器之间三层网络（IP 地址）的连通性。但是，根据这个机制的工作原理，你认为 Flannel 能负责保证二层网络（MAC 地址）的连通性吗？为什么呢？

在上一篇文章中，我以 Flannel 项目为例，为你详细讲解了容器跨主机网络的两种实现方法：UDP 和 VXLAN。

不难看到，这些例子有一个共性，那就是用户的容器都连接在 docker0 网桥上。而网络插件则在宿主机上创建了一个特殊的设备（UDP 模式创建的是 TUN 设备，VXLAN 模式创建的则是 VTEP 设备），docker0 与这个设备之间，通过 IP 转发（路由表）进行协作。

然后，网络插件真正要做的事情，则是通过某种方法，把不同宿主机上的特殊设备连通，从而达到容器跨主机通信的目的。

实际上，上面这个流程，也正是 Kubernetes 对容器网络的主要处理方法。只不过，Kubernetes 是通过一个叫作 CNI 的接口，维护了一个单独的网桥来代替 docker0。这个网桥的名字就叫作：CNI 网桥，它在宿主机上的设备名称默认是：cni0。

以 Flannel 的 VXLAN 模式为例，在 Kubernetes 环境里，它的工作方式跟我们在上一篇文章中讲解的没有任何不同。只不过，docker0 网桥被替换成了 CNI 网桥而已，如下所示：

在这里，Kubernetes 为 Flannel 分配的子网范围是 10.244.0.0/16。这个参数可以在部署的时候指定，比如：

$ kubeadm init --pod-network-cidr=10.244.0.0/16

也可以在部署完成后，通过修改 kube-controller-manager 的配置文件来指定。

这时候，假设 Infra-container-1 要访问 Infra-container-2（也就是 Pod-1 要访问 Pod-2），这个 IP 包的源地址就是 10.244.0.2，目的 IP 地址是 10.244.1.3。而此时，Infra-container-1 里的 eth0 设备，同样是以 Veth Pair 的方式连接在 Node 1 的 cni0 网桥上。所以这个 IP 包就会经过 cni0 网桥出现在宿主机上。

此时，Node 1 上的路由表，如下所示：

\# 在 Node 1 上

$ route -n

Kernel IP routing table

Destination   Gateway     Genmask     Flags Metric Ref   Use Iface

...

10.244.0.0    0.0.0.0     255.255.255.0  U   0    0     0 cni0

10.244.1.0    10.244.1.0    255.255.255.0  UG   0    0     0 flannel.1

172.17.0.0    0.0.0.0     255.255.0.0   U   0    0     0 docker0

因为我们的 IP 包的目的 IP 地址是 10.244.1.3，所以它只能匹配到第二条规则，也就是 10.244.1.0 对应的这条路由规则。

可以看到，这条规则指定了本机的 flannel.1 设备进行处理。并且，flannel.1 在处理完后，要将 IP 包转发到的网关（Gateway），正是“隧道”另一端的 VTEP 设备，也就是 Node 2 的 flannel.1 设备。所以，接下来的流程，就跟上一篇文章中介绍过的 Flannel VXLAN 模式完全一样了。

需要注意的是，CNI 网桥只是接管所有 CNI 插件负责的、即 Kubernetes 创建的容器（Pod）。而此时，如果你用 docker run 单独启动一个容器，那么 Docker 项目还是会把这个容器连接到 docker0 网桥上。所以这个容器的 IP 地址，一定是属于 docker0 网桥的 172.17.0.0/16 网段。

Kubernetes 之所以要设置这样一个与 docker0 网桥功能几乎一样的 CNI 网桥，主要原因包括两个方面：

一方面，Kubernetes 项目并没有使用 Docker 的网络模型（CNM），所以它并不希望、也不具备配置 docker0 网桥的能力；

另一方面，这还与 Kubernetes 如何配置 Pod，也就是 Infra 容器的 Network Namespace 密切相关。

我们知道，Kubernetes 创建一个 Pod 的第一步，就是创建并启动一个 Infra 容器，用来“hold”住这个 Pod 的 Network Namespace（这里，你可以再回顾一下专栏第 13 篇文章《为什么我们需要 Pod？》中的相关内容）。

所以，CNI 的设计思想，就是：Kubernetes 在启动 Infra 容器之后，就可以直接调用 CNI 网络插件，为这个 Infra 容器的 Network Namespace，配置符合预期的网络栈。

备注：在前面第 32 篇文章《浅谈容器网络》中，我讲解单机容器网络时，已经和你分享过，一个 Network Namespace 的网络栈包括：网卡（Network Interface）、回环设备（Loopback Device）、路由表（Routing Table）和 iptables 规则。

那么，这个网络栈的配置工作又是如何完成的呢？

为了回答这个问题，我们就需要从 CNI 插件的部署和实现方式谈起了。

我们在部署 Kubernetes 的时候，有一个步骤是安装 kubernetes-cni 包，它的目的就是在宿主机上安装CNI 插件所需的基础可执行文件。

在安装完成后，你可以在宿主机的 /opt/cni/bin 目录下看到它们，如下所示：

$ ls -al /opt/cni/bin/

total 73088

-rwxr-xr-x 1 root root  3890407 Aug 17  2017 bridge

-rwxr-xr-x 1 root root  9921982 Aug 17  2017 dhcp

-rwxr-xr-x 1 root root  2814104 Aug 17  2017 flannel

-rwxr-xr-x 1 root root  2991965 Aug 17  2017 host-local

-rwxr-xr-x 1 root root  3475802 Aug 17  2017 ipvlan

-rwxr-xr-x 1 root root  3026388 Aug 17  2017 loopback

-rwxr-xr-x 1 root root  3520724 Aug 17  2017 macvlan

-rwxr-xr-x 1 root root  3470464 Aug 17  2017 portmap

-rwxr-xr-x 1 root root  3877986 Aug 17  2017 ptp

-rwxr-xr-x 1 root root  2605279 Aug 17  2017 sample

-rwxr-xr-x 1 root root  2808402 Aug 17  2017 tuning

-rwxr-xr-x 1 root root  3475750 Aug 17  2017 vlan

这些 CNI 的基础可执行文件，按照功能可以分为三类：
第一类，叫作 Main 插件，它是用来创建具体网络设备的二进制文件。比如，bridge（网桥设备）、ipvlan、loopback（lo 设备）、macvlan、ptp（Veth Pair 设备），以及 vlan。

我在前面提到过的 Flannel、Weave 等项目，都属于“网桥”类型的 CNI 插件。所以在具体的实现中，它们往往会调用 bridge 这个二进制文件。这个流程，我马上就会详细介绍到。

第二类，叫作 IPAM（IP Address Management）插件，它是负责分配 IP 地址的二进制文件。比如，dhcp，这个文件会向 DHCP 服务器发起请求；host-local，则会使用预先配置的 IP 地址段来进行分配。

第三类，是由 CNI 社区维护的内置 CNI 插件。比如：flannel，就是专门为 Flannel 项目提供的 CNI 插件；tuning，是一个通过 sysctl 调整网络设备参数的二进制文件；portmap，是一个通过 iptables 配置端口映射的二进制文件；bandwidth，是一个使用 Token Bucket Filter (TBF) 来进行限流的二进制文件。

从这些二进制文件中，我们可以看到，如果要实现一个给 Kubernetes 用的容器网络方案，其实需要做两部分工作，以 Flannel 项目为例：

首先，实现这个网络方案本身。这一部分需要编写的，其实就是 flanneld 进程里的主要逻辑。比如，创建和配置 flannel.1 设备、配置宿主机路由、配置 ARP 和 FDB 表里的信息等等。

然后，实现该网络方案对应的 CNI 插件。这一部分主要需要做的，就是配置 Infra 容器里面的网络栈，并把它连接在 CNI 网桥上。

由于 Flannel 项目对应的 CNI 插件已经被内置了，所以它无需再单独安装。而对于 Weave、Calico 等其他项目来说，我们就必须在安装插件的时候，把对应的 CNI 插件的可执行文件放在 /opt/cni/bin/ 目录下。

实际上，对于 Weave、Calico 这样的网络方案来说，它们的 DaemonSet 只需要挂载宿主机的 /opt/cni/bin/，就可以实现插件可执行文件的安装了。你可以想一下具体应该怎么做，就当当作一个课后小问题留给你去实践了。

接下来，你就需要在宿主机上安装 flanneld（网络方案本身）。而在这个过程中，flanneld 启动后会在每台宿主机上生成它对应的CNI 配置文件（它其实是一个 ConfigMap），从而告诉 Kubernetes，这个集群要使用 Flannel 作为容器网络方案。

这个 CNI 配置文件的内容如下所示：
```
$ cat /etc/cni/net.d/10-flannel.conflist  

{

 "name": "cbr0",

 "plugins": [

  {

   "type": "flannel",

   "delegate": {

​    "hairpinMode": true,

​    "isDefaultGateway": true

   }

  },

  {

   "type": "portmap",

   "capabilities": {

​    "portMappings": true

   }

  }

 ]

}
```
需要注意的是，在 Kubernetes 中，处理容器网络相关的逻辑并不会在 kubelet 主干代码里执行，而是会在具体的 CRI（Container Runtime Interface，容器运行时接口）实现里完成。对于 Docker 项目来说，它的 CRI 实现叫作 dockershim，你可以在 kubelet 的代码里找到它。

所以，接下来 dockershim 会加载上述的 CNI 配置文件。

需要注意，Kubernetes 目前不支持多个 CNI 插件混用。如果你在 CNI 配置目录（/etc/cni/net.d）里放置了多个 CNI 配置文件的话，dockershim 只会加载按字母顺序排序的第一个插件。

但另一方面，CNI 允许你在一个 CNI 配置文件里，通过 plugins 字段，定义多个插件进行协作。

比如，在我们上面这个例子里，Flannel 项目就指定了 flannel 和 portmap 这两个插件。

这时候，dockershim 会把这个 CNI 配置文件加载起来，并且把列表里的第一个插件、也就是 flannel 插件，设置为默认插件。而在后面的执行过程中，flannel 和 portmap 插件会按照定义顺序被调用，从而依次完成“配置容器网络”和“配置端口映射”这两步操作。

接下来，我就来为你讲解一下这样一个 CNI 插件的工作原理。

当 kubelet 组件需要创建 Pod 的时候，它第一个创建的一定是 Infra 容器。所以在这一步，dockershim 就会先调用 Docker API 创建并启动 Infra 容器，紧接着执行一个叫作 SetUpPod 的方法。这个方法的作用就是：为 CNI 插件准备参数，然后调用 CNI 插件为 Infra 容器配置网络。

这里要调用的 CNI 插件，就是 /opt/cni/bin/flannel；而调用它所需要的参数，分为两部分。

第一部分，是由 dockershim 设置的一组 CNI 环境变量。

其中，最重要的环境变量参数叫作：CNI_COMMAND。它的取值只有两种：ADD 和 DEL。

这个 ADD 和 DEL 操作，就是 CNI 插件唯一需要实现的两个方法。

其中 ADD 操作的含义是：把容器添加到 CNI 网络里；DEL 操作的含义则是：把容器从 CNI 网络里移除掉。

而对于网桥类型的 CNI 插件来说，这两个操作意味着把容器以 Veth Pair 的方式“插”到 CNI 网桥上，或者从网桥上“拔”掉。

接下来，我以 ADD 操作为重点进行讲解。

CNI 的 ADD 操作需要的参数包括：容器里网卡的名字 eth0（CNI_IFNAME）、Pod 的 Network Namespace 文件的路径（CNI_NETNS）、容器的 ID（CNI_CONTAINERID）等。这些参数都属于上述环境变量里的内容。其中，Pod（Infra 容器）的 Network Namespace 文件的路径，我在前面讲解容器基础的时候提到过，即：/proc/< 容器进程的 PID>/ns/net。

备注：这里你也可以再回顾下专栏第 8 篇文章《白话容器基础（四）：重新认识 Docker 容器》中的相关内容。

除此之外，在 CNI 环境变量里，还有一个叫作 CNI_ARGS 的参数。通过这个参数，CRI 实现（比如 dockershim）就可以以 Key-Value 的格式，传递自定义信息给网络插件。这是用户将来自定义 CNI 协议的一个重要方法。

第二部分，则是 dockershim 从 CNI 配置文件里加载到的、默认插件的配置信息。

这个配置信息在 CNI 中被叫作 Network Configuration，它的完整定义你可以参考这个文档。dockershim 会把 Network Configuration 以 JSON 数据的格式，通过标准输入（stdin）的方式传递给 Flannel CNI 插件。

而有了这两部分参数，Flannel CNI 插件实现 ADD 操作的过程就非常简单了。

不过，需要注意的是，Flannel 的 CNI 配置文件（ /etc/cni/net.d/10-flannel.conflist）里有这么一个字段，叫作 delegate：

   "delegate": {

​    "hairpinMode": true,

​    "isDefaultGateway": true

   }

Delegate 字段的意思是，这个 CNI 插件并不会自己做事儿，而是会调用 Delegate 指定的某种 CNI 内置插件来完成。对于 Flannel 来说，它调用的 Delegate 插件，就是前面介绍到的 CNI bridge 插件。

所以说，dockershim 对 Flannel CNI 插件的调用，其实就是走了个过场。Flannel CNI 插件唯一需要做的，就是对 dockershim 传来的 Network Configuration 进行补充。比如，将 Delegate 的 Type 字段设置为 bridge，将 Delegate 的 IPAM 字段设置为 host-local 等。

经过 Flannel CNI 插件补充后的、完整的 Delegate 字段如下所示：

{

  "hairpinMode":true,

  "ipMasq":false,

  "ipam":{

​    "routes":[

​      {

​        "dst":"10.244.0.0/16"

​      }

​    ],

​    "subnet":"10.244.1.0/24",

​    "type":"host-local"

  },

  "isDefaultGateway":true,

  "isGateway":true,

  "mtu":1410,

  "name":"cbr0",

  "type":"bridge"

}

其中，ipam 字段里的信息，比如 10.244.1.0/24，读取自 Flannel 在宿主机上生成的 Flannel 配置文件，即：宿主机上的 /run/flannel/subnet.env 文件。

接下来，Flannel CNI 插件就会调用 CNI bridge 插件，也就是执行：/opt/cni/bin/bridge 二进制文件。

这一次，调用 CNI bridge 插件需要的两部分参数的第一部分、也就是 CNI 环境变量，并没有变化。所以，它里面的 CNI_COMMAND 参数的值还是“ADD”。

而第二部分 Network Configration，正是上面补充好的 Delegate 字段。Flannel CNI 插件会把 Delegate 字段的内容以标准输入（stdin）的方式传递给 CNI bridge 插件。

此外，Flannel CNI 插件还会把 Delegate 字段以 JSON 文件的方式，保存在 /var/lib/cni/flannel 目录下。这是为了给后面删除容器调用 DEL 操作时使用的。

有了这两部分参数，接下来 CNI bridge 插件就可以“代表”Flannel，进行“将容器加入到 CNI 网络里”这一步操作了。而这一部分内容，与容器 Network Namespace 密切相关，所以我要为你详细讲解一下。

首先，CNI bridge 插件会在宿主机上检查 CNI 网桥是否存在。如果没有的话，那就创建它。这相当于在宿主机上执行：

\# 在宿主机上

$ ip link add cni0 type bridge

$ ip link set cni0 up

接下来，CNI bridge 插件会通过 Infra 容器的 Network Namespace 文件，进入到这个 Network Namespace 里面，然后创建一对 Veth Pair 设备。

紧接着，它会把这个 Veth Pair 的其中一端，“移动”到宿主机上。这相当于在容器里执行如下所示的命令：

\# 在容器里

\# 创建一对 Veth Pair 设备。其中一个叫作 eth0，另一个叫作 vethb4963f3

$ ip link add eth0 type veth peer name vethb4963f3

\# 启动 eth0 设备

$ ip link set eth0 up  

\# 将 Veth Pair 设备的另一端（也就是 vethb4963f3 设备）放到宿主机（也就是 Host Namespace）里

$ ip link set vethb4963f3 netns $HOST_NS

\# 通过 Host Namespace，启动宿主机上的 vethb4963f3 设备

$ ip netns exec $HOST_NS ip link set vethb4963f3 up  

这样，vethb4963f3 就出现在了宿主机上，而且这个 Veth Pair 设备的另一端，就是容器里面的 eth0。

当然，你可能已经想到，上述创建 Veth Pair 设备的操作，其实也可以先在宿主机上执行，然后再把该设备的一端放到容器的 Network Namespace 里，这个原理是一样的。

不过，CNI 插件之所以要“反着”来，是因为 CNI 里对 Namespace 操作函数的设计就是如此，如下所示：

err := containerNS.Do(func(hostNS ns.NetNS) error {

 ...

 return nil

})

这个设计其实很容易理解。在编程时，容器的 Namespace 是可以直接通过 Namespace 文件拿到的；而 Host Namespace，则是一个隐含在上下文的参数。所以，像上面这样，先通过容器 Namespace 进入容器里面，然后再反向操作 Host Namespace，对于编程来说要更加方便。

接下来，CNI bridge 插件就可以把 vethb4963f3 设备连接在 CNI 网桥上。这相当于在宿主机上执行：

\# 在宿主机上

$ ip link set vethb4963f3 master cni0

在将 vethb4963f3 设备连接在 CNI 网桥之后，CNI bridge 插件还会为它设置Hairpin Mode（发夹模式）。这是因为，在默认情况下，网桥设备是不允许一个数据包从一个端口进来后，再从这个端口发出去的。但是，它允许你为这个端口开启 Hairpin Mode，从而取消这个限制。

这个特性，主要用在容器需要通过NAT（即：端口映射）的方式，“自己访问自己”的场景下。

举个例子，比如我们执行 docker run -p 8080:80，就是在宿主机上通过 iptables 设置了一条DNAT（目的地址转换）转发规则。这条规则的作用是，当宿主机上的进程访问“< 宿主机的 IP 地址 >:8080”时，iptables 会把该请求直接转发到“< 容器的 IP 地址 >:80”上。也就是说，这个请求最终会经过 docker0 网桥进入容器里面。

但如果你是在容器里面访问宿主机的 8080 端口，那么这个容器里发出的 IP 包会经过 vethb4963f3 设备（端口）和 docker0 网桥，来到宿主机上。此时，根据上述 DNAT 规则，这个 IP 包又需要回到 docker0 网桥，并且还是通过 vethb4963f3 端口进入到容器里。所以，这种情况下，我们就需要开启 vethb4963f3 端口的 Hairpin Mode 了。

所以说，Flannel 插件要在 CNI 配置文件里声明 hairpinMode=true。这样，将来这个集群里的 Pod 才可以通过它自己的 Service 访问到自己。

接下来，CNI bridge 插件会调用 CNI ipam 插件，从 ipam.subnet 字段规定的网段里为容器分配一个可用的 IP 地址。然后，CNI bridge 插件就会把这个 IP 地址添加在容器的 eth0 网卡上，同时为容器设置默认路由。这相当于在容器里执行：

\# 在容器里

$ ip addr add 10.244.0.2/24 dev eth0

$ ip route add default via 10.244.0.1 dev eth0

最后，CNI bridge 插件会为 CNI 网桥添加 IP 地址。这相当于在宿主机上执行：

\# 在宿主机上

$ ip addr add 10.244.0.1/24 dev cni0

在执行完上述操作之后，CNI 插件会把容器的 IP 地址等信息返回给 dockershim，然后被 kubelet 添加到 Pod 的 Status 字段。

至此，CNI 插件的 ADD 方法就宣告结束了。接下来的流程，就跟我们上一篇文章中容器跨主机通信的过程完全一致了。

需要注意的是，对于非网桥类型的 CNI 插件，上述“将容器添加到 CNI 网络”的操作流程，以及网络方案本身的工作原理，就都不太一样了。我将会在后续文章中，继续为你分析这部分内容。

总结
在本篇文章中，我为你详细讲解了 Kubernetes 中 CNI 网络的实现原理。根据这个原理，你其实就很容易理解所谓的“Kubernetes 网络模型”了：

所有容器都可以直接使用 IP 地址与其他容器通信，而无需使用 NAT。

所有宿主机都可以直接使用 IP 地址与所有容器通信，而无需使用 NAT。反之亦然。

容器自己“看到”的自己的 IP 地址，和别人（宿主机或者容器）看到的地址是完全一样的。

容器与容器之间要“通”，容器与宿主机之间也要“通”。并且，Kubernetes 要求这个“通”，还必须是直接基于容器和宿主机的 IP 地址来进行的。

可以看到，这个网络模型，其实可以用一个字总结，那就是“通”。

容器与容器之间要“通”，容器与宿主机之间也要“通”。并且，Kubernetes 要求这个“通”，还必须是直接基于容器和宿主机的 IP 地址来进行的。

当然，考虑到不同用户之间的隔离性，在很多场合下，我们还要求容器之间的网络“不通”。这个问题，我会在后面的文章中会为你解决。
思考题
请你思考一下，为什么 Kubernetes 项目不自己实现容器网络，而是要通过 CNI 做一个如此简单的假设呢?

在上一篇文章中，我以网桥类型的 Flannel 插件为例，为你讲解了 Kubernetes 里容器网络和 CNI 插件的主要工作原理。不过，除了这种模式之外，还有一种纯三层（Pure Layer 3）网络方案非常值得你注意。其中的典型例子，莫过于 Flannel 的 host-gw 模式和 Calico 项目了。

我们先来看一下 Flannel 的 host-gw 模式。

它的工作原理非常简单，我用一张图就可以和你说清楚。为了方便叙述，接下来我会称这张图为“host-gw 示意图”。

图 1 Flannel host-gw 示意图

假设现在，Node 1 上的 Infra-container-1，要访问 Node 2 上的 Infra-container-2。

当你设置 Flannel 使用 host-gw 模式之后，flanneld 会在宿主机上创建这样一条规则，以 Node 1 为例：

$ ip route

...

10.244.1.0/24 via 10.168.0.3 dev eth0

这条路由规则的含义是：
目的 IP 地址属于 10.244.1.0/24 网段的 IP 包，应该经过本机的 eth0 设备发出去（即：dev eth0）；并且，它下一跳地址（next-hop）是 10.168.0.3（即：via 10.168.0.3）。

所谓下一跳地址就是：如果 IP 包从主机 A 发到主机 B，需要经过路由设备 X 的中转。那么 X 的 IP 地址就应该配置为主机 A 的下一跳地址。

而从 host-gw 示意图中我们可以看到，这个下一跳地址对应的，正是我们的目的宿主机 Node 2。

一旦配置了下一跳地址，那么接下来，当 IP 包从网络层进入链路层封装成帧的时候，eth0 设备就会使用下一跳地址对应的 MAC 地址，作为该数据帧的目的 MAC 地址。显然，这个 MAC 地址，正是 Node 2 的 MAC 地址。

这样，这个数据帧就会从 Node 1 通过宿主机的二层网络顺利到达 Node 2 上。

而 Node 2 的内核网络栈从二层数据帧里拿到 IP 包后，会“看到”这个 IP 包的目的 IP 地址是 10.244.1.3，即 Infra-container-2 的 IP 地址。这时候，根据 Node 2 上的路由表，该目的地址会匹配到第二条路由规则（也就是 10.244.1.0 对应的路由规则），从而进入 cni0 网桥，进而进入到 Infra-container-2 当中。

可以看到，host-gw 模式的工作原理，其实就是将每个 Flannel 子网（Flannel Subnet，比如：10.244.1.0/24）的“下一跳”，设置成了该子网对应的宿主机的 IP 地址。

也就是说，这台“主机”（Host）会充当这条容器通信路径里的“网关”（Gateway）。这也正是“host-gw”的含义。

当然，Flannel 子网和主机的信息，都是保存在 Etcd 当中的。flanneld 只需要 WACTH 这些数据的变化，然后实时更新路由表即可。

注意：在 Kubernetes v1.7 之后，类似 Flannel、Calico 的 CNI 网络插件都是可以直接连接 Kubernetes 的 APIServer 来访问 Etcd 的，无需额外部署 Etcd 给它们使用。

而在这种模式下，容器通信的过程就免除了额外的封包和解包带来的性能损耗。根据实际的测试，host-gw 的性能损失大约在 10% 左右，而其他所有基于 VXLAN“隧道”机制的网络方案，性能损失都在 20%~30% 左右。

当然，通过上面的叙述，你也应该看到，host-gw 模式能够正常工作的核心，就在于 IP 包在封装成帧发送出去的时候，会使用路由表里的“下一跳”来设置目的 MAC 地址。这样，它就会经过二层网络到达目的宿主机。

所以说，Flannel host-gw 模式必须要求集群宿主机之间是二层连通的。

需要注意的是，宿主机之间二层不连通的情况也是广泛存在的。比如，宿主机分布在了不同的子网（VLAN）里。但是，在一个 Kubernetes 集群里，宿主机之间必须可以通过 IP 地址进行通信，也就是说至少是三层可达的。否则的话，你的集群将不满足上一篇文章中提到的宿主机之间 IP 互通的假设（Kubernetes 网络模型）。当然，“三层可达”也可以通过为几个子网设置三层转发来实现。

而在容器生态中，要说到像 Flannel host-gw 这样的三层网络方案，我们就不得不提到这个领域里的“龙头老大”Calico 项目了。

实际上，Calico 项目提供的网络解决方案，与 Flannel 的 host-gw 模式，几乎是完全一样的。也就是说，Calico 也会在每台宿主机上，添加一个格式如下所示的路由规则：

< 目的容器 IP 地址段 > via < 网关的 IP 地址 > dev eth0

其中，网关的 IP 地址，正是目的容器所在宿主机的 IP 地址。

而正如前所述，这个三层网络方案得以正常工作的核心，是为每个容器的 IP 地址，找到它所对应的、“下一跳”的网关。

不过，不同于 Flannel 通过 Etcd 和宿主机上的 flanneld 来维护路由信息的做法，Calico 项目使用了一个“重型武器”来自动地在整个集群中分发路由信息。

这个“重型武器”，就是 BGP。

BGP 的全称是 Border Gateway Protocol，即：边界网关协议。它是一个 Linux 内核原生就支持的、专门用在大规模数据中心里维护不同的“自治系统”之间路由信息的、无中心的路由协议。

这个概念可能听起来有点儿“吓人”，但实际上，我可以用一个非常简单的例子来为你讲清楚。

图 2 自治系统

在这个图中，我们有两个自治系统（Autonomous System，简称为 AS）：AS 1 和 AS 2。而所谓的一个自治系统，指的是一个组织管辖下的所有 IP 网络和路由器的全体。你可以把它想象成一个小公司里的所有主机和路由器。在正常情况下，自治系统之间不会有任何“来往”。

但是，如果这样两个自治系统里的主机，要通过 IP 地址直接进行通信，我们就必须使用路由器把这两个自治系统连接起来。

比如，AS 1 里面的主机 10.10.0.2，要访问 AS 2 里面的主机 172.17.0.3 的话。它发出的 IP 包，就会先到达自治系统 AS 1 上的路由器 Router 1。

而在此时，Router 1 的路由表里，有这样一条规则，即：目的地址是 172.17.0.2 包，应该经过 Router 1 的 C 接口，发往网关 Router 2（即：自治系统 AS 2 上的路由器）。

所以 IP 包就会到达 Router 2 上，然后经过 Router 2 的路由表，从 B 接口出来到达目的主机 172.17.0.3。

但是反过来，如果主机 172.17.0.3 要访问 10.10.0.2，那么这个 IP 包，在到达 Router 2 之后，就不知道该去哪儿了。因为在 Router 2 的路由表里，并没有关于 AS 1 自治系统的任何路由规则。

所以这时候，网络管理员就应该给 Router 2 也添加一条路由规则，比如：目标地址是 10.10.0.2 的 IP 包，应该经过 Router 2 的 C 接口，发往网关 Router 1。

像上面这样负责把自治系统连接在一起的路由器，我们就把它形象地称为：边界网关。它跟普通路由器的不同之处在于，它的路由表里拥有其他自治系统里的主机路由信息。

上面的这部分原理，相信你理解起来应该很容易。毕竟，路由器这个设备本身的主要作用，就是连通不同的网络。

但是，你可以想象一下，假设我们现在的网络拓扑结构非常复杂，每个自治系统都有成千上万个主机、无数个路由器，甚至是由多个公司、多个网络提供商、多个自治系统组成的复合自治系统呢？

这时候，如果还要依靠人工来对边界网关的路由表进行配置和维护，那是绝对不现实的。

而这种情况下，BGP 大显身手的时刻就到了。

在使用了 BGP 之后，你可以认为，在每个边界网关上都会运行着一个小程序，它们会将各自的路由表信息，通过 TCP 传输给其他的边界网关。而其他边界网关上的这个小程序，则会对收到的这些数据进行分析，然后将需要的信息添加到自己的路由表里。

这样，图 2 中 Router 2 的路由表里，就会自动出现 10.10.0.2 和 10.10.0.3 对应的路由规则了。

所以说，所谓 BGP，就是在大规模网络中实现节点路由信息共享的一种协议。

而 BGP 的这个能力，正好可以取代 Flannel 维护主机上路由表的功能。而且，BGP 这种原生就是为大规模网络环境而实现的协议，其可靠性和可扩展性，远非 Flannel 自己的方案可比。

需要注意的是，BGP 协议实际上是最复杂的一种路由协议。我在这里的讲述和所举的例子，仅是为了能够帮助你建立对 BGP 的感性认识，并不代表 BGP 真正的实现方式。

接下来，我们还是回到 Calico 项目上来。

在了解了 BGP 之后，Calico 项目的架构就非常容易理解了。它由三个部分组成：

Calico 的 CNI 插件。这是 Calico 与 Kubernetes 对接的部分。我已经在上一篇文章中，和你详细分享了 CNI 插件的工作原理，这里就不再赘述了。

Felix。它是一个 DaemonSet，负责在宿主机上插入路由规则（即：写入 Linux 内核的 FIB 转发信息库），以及维护 Calico 所需的网络设备等工作。

BIRD。它就是 BGP 的客户端，专门负责在集群里分发路由规则信息。

除了对路由信息的维护方式之外，Calico 项目与 Flannel 的 host-gw 模式的另一个不同之处，就是它不会在宿主机上创建任何网桥设备。这时候，Calico 的工作方式，可以用一幅示意图来描述，如下所示（在接下来的讲述中，我会统一用“BGP 示意图”来指代它）：

其中的绿色实线标出的路径，就是一个 IP 包从 Node 1 上的 Container 1，到达 Node 2 上的 Container 4 的完整路径。

可以看到，Calico 的 CNI 插件会为每个容器设置一个 Veth Pair 设备，然后把其中的一端放置在宿主机上（它的名字以 cali 前缀开头）。

此外，由于 Calico 没有使用 CNI 的网桥模式，Calico 的 CNI 插件还需要在宿主机上为每个容器的 Veth Pair 设备配置一条路由规则，用于接收传入的 IP 包。比如，宿主机 Node 2 上的 Container 4 对应的路由规则，如下所示：

10.233.2.3 dev cali5863f3 scope link

即：发往 10.233.2.3 的 IP 包，应该进入 cali5863f3 设备。

基于上述原因，Calico 项目在宿主机上设置的路由规则，肯定要比 Flannel 项目多得多。不过，Flannel host-gw 模式使用 CNI 网桥的主要原因，其实是为了跟 VXLAN 模式保持一致。否则的话，Flannel 就需要维护两套 CNI 插件了。

有了这样的 Veth Pair 设备之后，容器发出的 IP 包就会经过 Veth Pair 设备出现在宿主机上。然后，宿主机网络栈就会根据路由规则的下一跳 IP 地址，把它们转发给正确的网关。接下来的流程就跟 Flannel host-gw 模式完全一致了。

其中，这里最核心的“下一跳”路由规则，就是由 Calico 的 Felix 进程负责维护的。这些路由规则信息，则是通过 BGP Client 也就是 BIRD 组件，使用 BGP 协议传输而来的。

而这些通过 BGP 协议传输的消息，你可以简单地理解为如下格式：

[BGP 消息]

我是宿主机 192.168.1.2

10.233.2.0/24 网段的容器都在我这里

这些容器的下一跳地址是我

不难发现，Calico 项目实际上将集群里的所有节点，都当作是边界路由器来处理，它们一起组成了一个全连通的网络，互相之间通过 BGP 协议交换路由规则。这些节点，我们称为 BGP Peer。 

需要注意的是，Calico 维护的网络在默认配置下，是一个被称为“Node-to-Node Mesh”的模式。这时候，每台宿主机上的 BGP Client 都需要跟其他所有节点的 BGP Client 进行通信以便交换路由信息。但是，随着节点数量 N 的增加，这些连接的数量就会以 N²的规模快速增长，从而给集群本身的网络带来巨大的压力。

所以，Node-to-Node Mesh 模式一般推荐用在少于 100 个节点的集群里。而在更大规模的集群中，你需要用到的是一个叫作 Route Reflector 的模式。

在这种模式下，Calico 会指定一个或者几个专门的节点，来负责跟所有节点建立 BGP 连接从而学习到全局的路由规则。而其他节点，只需要跟这几个专门的节点交换路由信息，就可以获得整个集群的路由规则信息了。

这些专门的节点，就是所谓的 Route Reflector 节点，它们实际上扮演了“中间代理”的角色，从而把 BGP 连接的规模控制在 N 的数量级上。

此外，我在前面提到过，Flannel host-gw 模式最主要的限制，就是要求集群宿主机之间是二层连通的。而这个限制对于 Calico 来说，也同样存在。

举个例子，假如我们有两台处于不同子网的宿主机 Node 1 和 Node 2，对应的 IP 地址分别是 192.168.1.2 和 192.168.2.2。需要注意的是，这两台机器通过路由器实现了三层转发，所以这两个 IP 地址之间是可以相互通信的。

而我们现在的需求，还是 Container 1 要访问 Container 4。

按照我们前面的讲述，Calico 会尝试在 Node 1 上添加如下所示的一条路由规则：

10.233.2.0/16 via 192.168.2.2 eth0

但是，这时候问题就来了。

上面这条规则里的下一跳地址是 192.168.2.2，可是它对应的 Node 2 跟 Node 1 却根本不在一个子网里，没办法通过二层网络把 IP 包发送到下一跳地址。

在这种情况下，你就需要为 Calico 打开 IPIP 模式。

我把这个模式下容器通信的原理，总结成了一副示意图，如下所示（接下来我会称之为：IPIP 示意图）：

图 4 Calico IPIP 模式工作原理

在 Calico 的 IPIP 模式下，Felix 进程在 Node 1 上添加的路由规则，会稍微不同，如下所示：

10.233.2.0/24 via 192.168.2.2 tunl0

可以看到，尽管这条规则的下一跳地址仍然是 Node 2 的 IP 地址，但这一次，要负责将 IP 包发出去的设备，变成了 tunl0。注意，是 T-U-N-L-0，而不是 Flannel UDP 模式使用的 T-U-N-0（tun0），这两种设备的功能是完全不一样的。

Calico 使用的这个 tunl0 设备，是一个 IP 隧道（IP tunnel）设备。

在上面的例子中，IP 包进入 IP 隧道设备之后，就会被 Linux 内核的 IPIP 驱动接管。IPIP 驱动会将这个 IP 包直接封装在一个宿主机网络的 IP 包中，如下所示：

图 5 IPIP 封包方式

其中，经过封装后的新的 IP 包的目的地址（图 5 中的 Outer IP Header 部分），正是原 IP 包的下一跳地址，即 Node 2 的 IP 地址：192.168.2.2。

而原 IP 包本身，则会被直接封装成新 IP 包的 Payload。

这样，原先从容器到 Node 2 的 IP 包，就被伪装成了一个从 Node 1 到 Node 2 的 IP 包。

由于宿主机之间已经使用路由器配置了三层转发，也就是设置了宿主机之间的“下一跳”。所以这个 IP 包在离开 Node 1 之后，就可以经过路由器，最终“跳”到 Node 2 上。

这时，Node 2 的网络内核栈会使用 IPIP 驱动进行解包，从而拿到原始的 IP 包。然后，原始 IP 包就会经过路由规则和 Veth Pair 设备到达目的容器内部。

以上，就是 Calico 项目主要的工作原理了。

不难看到，当 Calico 使用 IPIP 模式的时候，集群的网络性能会因为额外的封包和解包工作而下降。在实际测试中，Calico IPIP 模式与 Flannel VXLAN 模式的性能大致相当。所以，在实际使用时，如非硬性需求，我建议你将所有宿主机节点放在一个子网里，避免使用 IPIP。

不过，通过上面对 Calico 工作原理的讲述，你应该能发现这样一个事实：

如果 Calico 项目能够让宿主机之间的路由设备（也就是网关），也通过 BGP 协议“学习”到 Calico 网络里的路由规则，那么从容器发出的 IP 包，不就可以通过这些设备路由到目的宿主机了么？

比如，只要在上面“IPIP 示意图”中的 Node 1 上，添加如下所示的一条路由规则：

10.233.2.0/24 via 192.168.1.1 eth0

然后，在 Router 1 上（192.168.1.1），添加如下所示的一条路由规则：

10.233.2.0/24 via 192.168.2.1 eth0

那么 Container 1 发出的 IP 包，就可以通过两次“下一跳”，到达 Router 2（192.168.2.1）了。以此类推，我们可以继续在 Router 2 上添加“下一条”路由，最终把 IP 包转发到 Node 2 上。

遗憾的是，上述流程虽然简单明了，但是在 Kubernetes 被广泛使用的公有云场景里，却完全不可行。

这里的原因在于：公有云环境下，宿主机之间的网关，肯定不会允许用户进行干预和设置。

当然，在大多数公有云环境下，宿主机（公有云提供的虚拟机）本身往往就是二层连通的，所以这个需求也不强烈。

不过，在私有部署的环境下，宿主机属于不同子网（VLAN）反而是更加常见的部署状态。这时候，想办法将宿主机网关也加入到 BGP Mesh 里从而避免使用 IPIP，就成了一个非常迫切的需求。

而在 Calico 项目中，它已经为你提供了两种将宿主机网关设置成 BGP Peer 的解决方案。

第一种方案，就是所有宿主机都跟宿主机网关建立 BGP Peer 关系。

这种方案下，Node 1 和 Node 2 就需要主动跟宿主机网关 Router 1 和 Router 2 建立 BGP 连接。从而将类似于 10.233.2.0/24 这样的路由信息同步到网关上去。

需要注意的是，这种方式下，Calico 要求宿主机网关必须支持一种叫作 Dynamic Neighbors 的 BGP 配置方式。这是因为，在常规的路由器 BGP 配置里，运维人员必须明确给出所有 BGP Peer 的 IP 地址。考虑到 Kubernetes 集群可能会有成百上千个宿主机，而且还会动态地添加和删除节点，这时候再手动管理路由器的 BGP 配置就非常麻烦了。而 Dynamic Neighbors 则允许你给路由器配置一个网段，然后路由器就会自动跟该网段里的主机建立起 BGP Peer 关系。

相比之下，推荐第二种方案。  

这种方案，是使用一个或多个独立组件负责搜集整个集群里的所有路由信息，然后通过 BGP 协议同步给网关。而我们前面提到，在大规模集群中，Calico 本身就推荐使用 Route Reflector 节点的方式进行组网。所以，这里负责跟宿主机网关进行沟通的独立组件，直接由 Route Reflector 兼任即可。

更重要的是，这种情况下网关的 BGP Peer 个数是有限并且固定的。所以我们就可以直接把这些独立组件配置成路由器的 BGP Peer，而无需 Dynamic Neighbors 的支持。

当然，这些独立组件的工作原理也很简单：它们只需要 WATCH Etcd 里的宿主机和对应网段的变化信息，然后把这些信息通过 BGP 协议分发给网关即可。

总结
在本篇文章中，我为你详细讲述了 Fannel host-gw 模式和 Calico 这两种纯三层网络方案的工作原理。

需要注意的是，在大规模集群里，三层网络方案在宿主机上的路由规则可能会非常多，这会导致错误排查变得困难。此外，在系统故障的时候，路由规则出现重叠冲突的概率也会变大。

基于上述原因，如果是在公有云上，由于宿主机网络本身比较“直白”，我一般会推荐更加简单的 Flannel host-gw 模式。

但不难看到，在私有部署环境里，Calico 项目才能够覆盖更多的场景，并为你提供更加可靠的组网方案和架构思路。

思考题
你能否能总结一下三层网络方案和“隧道模式”的异同，以及各自的优缺点？

## 单机容器网络实现原理和DOCKER0 网桥作用

构成一个进程发起和响应网络请求的基本环境

曾提过一个 Linux 容器能看见的"网络栈"，实际上是被隔离在它自己的 Network Namespace 当中的。

  "网络栈"：

 包括：网卡（Network Interface）、回环设备（Loopback Device）、路由表（Routing Table）和 iptables 规则。对于一个进程来说，这些要素，其实就构成了它发起和响应网络请求的基本环境。

被隔离的容器进程，如何跟其他 Network Namespace 里的容器进程进行交互？

一个容器可以声明直接使用宿主机的网络栈（--net=host），即：不开启 Network Namespace，比如：

  \# docker run -d --network=host --name nginx-host nginx

  在这种情况下，这个容器启动后，直接监听的就是宿主机的 80 端口。

像这样直接使用宿主机网络栈的方式，虽然可以为容器提供良好的网络性能，但也会不可避免地引入共享网络资源的问题，比如端口冲突。所以，在大多数情况下，我们都希望容器进程能使用自己 Network Namespace 里的网络栈，即：拥有属于自己的 IP 地址和端口。

这时候，一个显而易见的问题就是：这个被隔离的容器进程，该如何跟其他 Network Namespace 里的容器进程进行交互呢？

为了理解这个问题，你可以把每一个容器看做一台主机，它们都有一套独立的"网络栈"。

如果你想要实现两台主机之间的通信，最直接的办法，就是把它们用一根网线连接起来；而如果你想要实现多台主机之间的通信，那就需要用网线，把它们连接在一台交换机上。

在 Linux 中，能够起到虚拟交换机作用的网络设备，是网桥（Bridge）。它是一个工作在数据链路层（Data Link）的设备，主要功能是根据 MAC 地址学习来将数据包转发到网桥的不同端口（Port）上。

而为了实现上述目的，Docker 项目会默认在宿主机上创建一个名叫 docker0 的网桥，凡是连接在 docker0 网桥上的容器，就可以通过它来进行通信。

如何把这些容器"连接"到 docker0 网桥上？

这时，我们需要使用一种名叫Veth Pair的虚拟设备。

Veth Pair 设备的特点是：
它被创建出来后，总是以两张虚拟网卡（Veth Peer）的形式成对出现的。并且，从其中一个"网卡"发出的数据包，可以直接出现在与它对应的另一张"网卡"上，哪怕这两个"网卡"在不同的 Network Namespace 里。

这就使得 Veth Pair 常常被用作连接不同 Network Namespace 的"网线"。

比如，现在我们启动了一个叫作 nginx-1 的容器：

\# docker run -d --name nginx-1 nginx

然后进入到这个容器中查看一下它的网络设备：

\# 在宿主机上

\# docker exec -it nginx-1 /bin/bash

\# 在容器里

root@2b3c181aecf1:/# ifconfig

eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500

​    inet 172.17.0.2  netmask 255.255.0.0  broadcast 0.0.0.0

​    inet6 fe80::42:acff:fe11:2  prefixlen 64  scopeid 0x20<link>

​    ether 02:42:ac:11:00:02  txqueuelen 0  (Ethernet)

​    RX packets 364  bytes 8137175 (7.7 MiB)

​    RX errors 0  dropped 0  overruns 0  frame 0

​    TX packets 281  bytes 21161 (20.6 KiB)

​    TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

​    

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536

​    inet 127.0.0.1  netmask 255.0.0.0

​    inet6 ::1  prefixlen 128  scopeid 0x10<host>

​    loop  txqueuelen 1000  (Local Loopback)

​    RX packets 0  bytes 0 (0.0 B)

​    RX errors 0  dropped 0  overruns 0  frame 0

​    TX packets 0  bytes 0 (0.0 B)

​    TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


\# route

Kernel IP routing table

Destination   Gateway     Genmask     Flags Metric Ref   Use Iface

default     172.17.0.1    0.0.0.0     UG   0    0     0 eth0

172.17.0.0    0.0.0.0     255.255.0.0   U   0    0     0 eth0

可以看到，这个容器里有一张叫作 eth0 的网卡，它正是一个 Veth Pair 设备在容器里的这一端。

通过 route 命令查看 nginx-1 容器的路由表，我们可以看到，这个 eth0 网卡是这个容器里的默认路由设备；所有对 172.17.0.0/16 网段的请求，也会被交给 eth0 来处理（第二条 172.17.0.0 路由规则）。

而这个 Veth Pair 设备的另一端，则在宿主机上。你可以通过查看宿主机的网络设备看到它，如下所示：

\# 在宿主机上

\# ifconfig

...

docker0  Link encap:Ethernet  HWaddr 02:42:d8:e4:df:c1  

​     inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0

​     inet6 addr: fe80::42:d8ff:fee4:dfc1/64 Scope:Link

​     UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

​     RX packets:309 errors:0 dropped:0 overruns:0 frame:0

​     TX packets:372 errors:0 dropped:0 overruns:0 carrier:0

 collisions:0 txqueuelen:0 

​     RX bytes:18944 (18.9 KB)  TX bytes:8137789 (8.1 MB)

veth9c02e56 Link encap:Ethernet  HWaddr 52:81:0b:24:3d:da  

​     inet6 addr: fe80::5081:bff:fe24:3dda/64 Scope:Link

​     UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

​     RX packets:288 errors:0 dropped:0 overruns:0 frame:0

​     TX packets:371 errors:0 dropped:0 overruns:0 carrier:0

 collisions:0 txqueuelen:0 

​     RX bytes:21608 (21.6 KB)  TX bytes:8137719 (8.1 MB)

​     

\# brctl show

bridge name bridge id  STP enabled interfaces

docker0  8000.0242d8e4dfc1 no  veth9c02e56

通过 ifconfig 命令的输出，你可以看到，nginx-1 容器对应的 Veth Pair 设备，在宿主机上是一张虚拟网卡。它的名字叫作 veth9c02e56。并且，通过 brctl show 的输出，你可以看到这张网卡被"插"在了 docker0 上。

这时候，如果我们再在这台宿主机上启动另一个 Docker 容器，比如 nginx-2：

\# docker run –d --name nginx-2 nginx

\# brctl show

bridge name bridge id  STP enabled interfaces

docker0  8000.0242d8e4dfc1 no  veth9c02e56

​    vethb4963f3

你就会发现一个新的、名叫 vethb4963f3 的虚拟网卡，也被"插"在了 docker0 网桥上。

这时候，如果你在 nginx-1 容器里 ping 一下 nginx-2 容器的 IP 地址（172.17.0.3），就会发现同一宿主机上的两个容器默认就是相互连通的。

原理其实非常简单:
当你在 nginx-1 容器里访问 nginx-2 容器的 IP 地址（比如 ping 172.17.0.3）的时候，这个目的 IP 地址会匹配到 nginx-1 容器里的第二条路由规则。可以看到，这条路由规则的网关（Gateway）是 0.0.0.0，这就意味着这是一条直连规则，即：凡是匹配到这条规则的 IP 包，应该经过本机的 eth0 网卡，通过二层网络直接发往目的主机。

而要通过二层网络到达 nginx-2 容器，就需要有 172.17.0.3 这个 IP 地址对应的 MAC 地址。所以 nginx-1 容器的网络协议栈，就需要通过 eth0 网卡发送一个 ARP 广播，来通过 IP 地址查找对应的 MAC 地址。

我们前面提到过，这个 eth0 网卡，是一个 Veth Pair，它的一端在这个 nginx-1 容器的 Network Namespace 里，而另一端则位于宿主机上（Host Namespace），并且被"插"在了宿主机的 docker0 网桥上。

一旦一张虚拟网卡被"插"在网桥上，它就会变成该网桥的"从设备"。从设备会被"剥夺"调用网络协议栈处理数据包的资格，从而"降级"成为网桥上的一个端口。而这个端口唯一的作用，就是接收流入的数据包，然后把这些数据包的"生杀大权"（比如转发或者丢弃），全部交给对应的网桥。

所以，在收到这些 ARP 请求之后，docker0 网桥就会扮演二层交换机的角色，把 ARP 广播转发到其他被"插"在 docker0 上的虚拟网卡上。这样，同样连接在 docker0 上的 nginx-2 容器的网络协议栈就会收到这个 ARP 请求，从而将 172.17.0.3 所对应的 MAC 地址回复给 nginx-1 容器。

有了这个目的 MAC 地址，nginx-1 容器的 eth0 网卡就可以将数据包发出去。

而根据 Veth Pair 设备的原理，这个数据包会立刻出现在宿主机上的 veth9c02e56 虚拟网卡上。不过，此时这个 veth9c02e56 网卡的网络协议栈的资格已经被"剥夺"，所以这个数据包就直接流入到了 docker0 网桥里。

docker0 处理转发的过程，则继续扮演二层交换机的角色。此时，docker0 网桥根据数据包的目的 MAC 地址（也就是 nginx-2 容器的 MAC 地址），在它的 CAM 表（即交换机通过 MAC 地址学习维护的端口和 MAC 地址的对应表）里查到对应的端口（Port）为：vethb4963f3，然后把数据包发往这个端口。

而这个端口，正是 nginx-2 容器"插"在 docker0 网桥上的另一块虚拟网卡，当然，它也是一个 Veth Pair 设备。这样，数据包就进入到了 nginx-2 容器的 Network Namespace 里。

所以，nginx-2 容器看到的情况是，它自己的 eth0 网卡上出现了流入的数据包。这样，nginx-2 的网络协议栈就会对请求进行处理，最后将响应（Pong）返回到 nginx-1。

以上，就是同一个宿主机上的不同容器通过 docker0 网桥进行通信的流程了。把这个流程总结成了一幅示意图，如下所示：

需要注意的是，在实际的数据传递时，上述数据的传递过程在网络协议栈的不同层次，都有 Linux 内核 Netfilter 参与其中。所以，如果感兴趣的话，你可以通过打开 iptables 的 TRACE 功能查看到数据包的传输过程，具体方法如下所示：

\# 在宿主机上执行

$ iptables -t raw -A OUTPUT -p icmp -j TRACE

$ iptables -t raw -A PREROUTING -p icmp -j TRACE

通过上述设置，你就可以在 /var/log/syslog 里看到数据包传输的日志了。这一部分内容，你可以在课后结合iptables 的相关知识进行实践，从而验证我和你分享的数据包传递流程。

熟悉了 docker0 网桥的工作方式，你就可以理解，在默认情况下，被限制在 Network Namespace 里的容器进程，实际上是通过 Veth Pair 设备 + 宿主机网桥的方式，实现了跟同其他容器的数据交换。

与之类似地，当你在一台宿主机上，访问该宿主机上的容器的 IP 地址时，这个请求的数据包，也是先根据路由规则到达 docker0 网桥，然后被转发到对应的 Veth Pair 设备，最后出现在容器里。这个过程的示意图，如

同样地，当一个容器试图连接到另外一个宿主机时，比如：ping 10.168.0.3，它发出的请求数据包，首先经过 docker0 网桥出现在宿主机上。然后根据宿主机的路由表里的直连路由规则（10.168.0.0/24 via eth0)），对 10.168.0.3 的访问请求就会交给宿主机的 eth0 处理。

所以接下来，这个数据包就会经宿主机的 eth0 网卡转发到宿主机网络上，最终到达 10.168.0.3 对应的宿主机上。当然，这个过程的实现要求这两台宿主机本身是连通的。这个过程的示意图，如下所示：

所以说，当你遇到容器连不通"外网"的时候，你都应该先试试 docker0 网桥能不能 ping 通，然后查看一下跟 docker0 和 Veth Pair 设备相关的 iptables 规则是不是有异常，往往就能够找到问题的答案了。

不过，在最后一个"Docker 容器连接其他宿主机"的例子里，你可能已经联想到了这样一个问题：如果在另外一台宿主机（比如：10.168.0.3）上，也有一个 Docker 容器。那么，我们的 nginx-1 容器又该如何访问它呢？

这个问题，其实就是容器的"跨主通信"问题。

在 Docker 的默认配置下，一台宿主机上的 docker0 网桥，和其他宿主机上的 docker0 网桥，没有任何关联，它们互相之间也没办法连通。所以，连接在这些网桥上的容器，自然也没办法进行通信了。

不过，万变不离其宗。

如果我们通过软件的方式，创建一个整个集群"公用"的网桥，然后把集群里的所有容器都连接到这个网桥上，不就可以相互通信了吗？

说得没错。

这样一来，我们整个集群里的容器网络就会类似于下图所示的样子：

可以看到，构建这种容器网络的核心在于：我们需要在已有的宿主机网络上，再通过软件构建一个覆盖在已有宿主机网络之上的、可以把所有容器连通在一起的虚拟网络。所以，这种技术就被称为：Overlay Network（覆盖网络）。

而这个 Overlay Network 本身，可以由每台宿主机上的一个"特殊网桥"共同组成。比如，当 Node 1 上的 Container 1 要访问 Node 2 上的 Container 3 的时候，Node 1 上的"特殊网桥"在收到数据包之后，能够通过某种方式，把数据包发送到正确的宿主机，比如 Node 2 上。而 Node 2 上的"特殊网桥"在收到数据包后，也能够通过某种方式，把数据包转发给正确的容器，比如 Container 3。

甚至，每台宿主机上，都不需要有一个这种特殊的网桥，而仅仅通过某种方式配置宿主机的路由表，就能够把数据包转发到正确的宿主机上。这些内容，我在后面的文章中会为你一一讲述。

总结
今天主要介绍了在本地环境下，单机容器网络的实现原理和 docker0 网桥的作用。

这里的关键在于，容器要想跟外界进行通信，它发出的 IP 包就必须从它的 Network Namespace 里出来，来到宿主机上。

而解决这个问题的方法就是：为容器创建一个一端在容器里充当默认网卡、另一端在宿主机上的 Veth Pair 设备。

上述单机容器网络的知识，是后面我们讲解多机容器网络的重要基础，请务必认真消化理解。

思考题
尽管容器的 Host Network 模式有一些缺点，但是它性能好、配置简单，并且易于调试，所以很多团队会直接使用 Host Network。那么，如果要在生产环境中使用容器的 Host Network 模式，你觉得需要做哪些额外的准备工作呢？ 

# 其他属性
## 环境变量

给容器定义环境变量

当你建立了一个Pod,你可以给你运行在Pod中的容器使用env设置环境变量。

在本例中，建了一个运行了一个container的Pod。这个配置文件给这个Pod定义了一个名为DEMO_GREETING值为"Hello from the environment"的环境变量。

下面是这个Pod的配置文件：
```
apiVersion: v1

kind: Pod

metadata:

 name: envar-demo

 labels:

  purpose: demonstrate-envars

spec:

 containers:

 \- name: envar-demo-container

  image: gcr.io/google-samples/node-hello:1.0

  env:

  \- name: DEMO_GREETING  //变量名称

   value: "Hello from the environment"  //变量值，必须加引号
```

1.新建一个Pod基于YAML配置文件：

kubectl create -f http://k8s.io/docs/tasks/configure-pod-container/envars.yaml

2.运行Pod的列表：

kubectl get pods -l purpose=demonstrate-envars

3.获取一个shell到Pod运行的容器里：

kubectl exec -it envar-demo -- /bin/bash

4.在shell里，运行printenv命令列出环境变量

root@envar-demo:/# printenv

输出类似于下面：

NODE_VERSION=4.4.2

EXAMPLE_SERVICE_PORT_8080_TCP_ADDR=10.3.245.237

HOSTNAME=envar-demo

...

DEMO_GREETING=Hello from the environment

 

5.退出shell,输入exit。


查看运行的pod的环境变量

\# kubectl exec pod名 env

 

## 镜像策略

镜像拉取策略

imagePullPolicy: Always

三个选择Always、Never、IfNotPresent，每次启动时检查和更新（从registery）images的策略，

Always，每次都检查

Never，每次都不检查（不管本地是否有），直接不再去拉取镜像了，使用本地的；如果本地不存在就报异常了。

IfNotPresent，如果本地有就不检查，如果没有就拉取

官方说明：https://kubernetes.io/docs/concepts/containers/images/

 

  By default, the kubelet will try to pull each image from the  specified registry. However, if the imagePullPolicy property of the  container is set to IfNotPresent or Never, then a local image is used  (preferentially or exclusively, respectively).

 

参数的作用范围：

spec: 

 containers: 

  \- name: nginx 

   image: image: reg.docker.lc/share/nginx:latest 

   imagePullPolicy: IfNotPresent  #或者使用Never 

参数默认为：imagePullPolicy: Always ，如果你yaml配置文件中没有定义那就是使用默认的。

## 重起策略

restartPolicy: Always  

表明该容器一直运行，默认k8s的策略，在此容器退出后，会立即自动重起该容器  

参数的作用范围：

   spec: 

​    restartPolicy: Always

​     containers: 

## 卷操作

[root@k8s-master /]# cat test-hostpath.yaml 
```
apiVersion: v1

kind: Pod

metadata:

 labels:

  name: test-hostpath

 name: test-hostpath

spec:

 containers:

  \- name: test-hostpath

   image: daocloud.io/library/nginx

   volumeMounts:

​    \- name: testpath  #注意这里的名字和volumes里面定义的卷的名字要一致

​     mountPath: /testpath  #事先不用存在

​     

​     

 volumes:

 \- name: testpath

  hostPath:

   path: /testpath  #事先不用存在
```

创建pod后进入pod测试：
```
[root@k8s-master /]# kubectl exec -it test-hostpath /bin/bash

root@test-hostpath:/# ls

bin  dev  home  lib64	mnt  proc  run	 srv  testpath	usr

boot  etc  lib	 media	opt  root  sbin  sys  tmp	var
```

NFS（网络数据卷）

NFS类型的volume。允许一块现有的网络硬盘在同一个pod内的容器间共享

volumes:

\- name: nfs-storage

 nfs:

  server: 192.168.20.47

  path: "/data/disk1"

## 资源调度

kubernetes pod调度

这里介绍两种调度方式

方法1、使用NodeName进行pod调度：

Pod.spec.nodeName用于强制约束将Pod调度到指定的Node节点上，这里说是"调度"，但其实指定了nodeName的Pod会直接跳过Scheduler的调度逻辑，直接写入PodList列表，该匹配规则是强制匹配。

[root@k8s-master ~]# cat nginxrc.yaml 

apiVersion: v1

kind: ReplicationController

metadata:

 name: my-nginx

spec:

 replicas: 1

 template:

  metadata:

   labels:

​    app: nginx

  spec:

   nodeName: k8s-node-1  #指定调度节点为k8s-node-1

   containers:

   \- name: nginx

​    image: daocloud.io/library/nginx:latest

​    ports:

​    \- containerPort: 80

创建rc:

  略

查看pod运行于哪个节点：

[root@k8s-master ~]# kubectl get pods -o wide

NAME       READY   STATUS   RESTARTS  AGE    IP     NODE

my-nginx-dwp13  1/1    Running  0      21m    10.0.6.2  k8s-node-1

方法2：使用NodeSelector进行pod调度

Pod.spec.nodeSelector是通过kubernetes的label-selector机制进行节点选择，由scheduler调度策略MatchNodeSelector进行label匹配，调度pod到目标节点，该匹配规则是强制约束。启用节点选择器的步骤为：

1.Node添加label标记

  标记规则：kubectl label nodes <node-name> <label-key>=<label-value>

  \#kubectl label nodes k8s.node1 cloudnil.com/role=dev

   确认标记

  root@k8s.master1:~# kubectl get nodes k8s.node1 --show-labels

  NAME     STATUS   AGE    LABELS

  k8s.node1  Ready   29d    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,cloudnil.com/role=dev,kubernetes.io/hostname=k8s.node1

2.Pod定义中添加nodeSelector

[root@k8s-master ~]# cat nginxrc.yaml 
```
apiVersion: v1

kind: ReplicationController

metadata:

 name: my-nginx

spec:

 replicas: 1

 template:

  metadata:

   labels:

​    app: nginx

  spec:

   nodeSelector:

​    cloudnil.com/role: dev#指定调度节点为带有label标记为：cloudnil.com/role=dev的node节点

   containers:

   \- name: nginx

​    image: daocloud.io/library/nginx:latest

​    ports:

​    \- containerPort: 80
```
创建rc:

查看pod运行于哪个节点：

[root@k8s-master ~]# kubectl get pods -o wide

NAME       READY   STATUS   RESTARTS  AGE    IP     NODE

my-nginx-zttrj  1/1    Running  0      5s     10.0.6.2  k8s-node-1

下面这句话忽略先：   

关键在于spec.selector与spec.template.metadata.labels，这两个字段必须相同，否则下一步创建RC会失败。（也可以不写spec.selector，这样默认与spec.template.metadata.labels相同）

## 资源配额

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps4KIG9o.jpg) 

## 资源标签

概念
Label机制是K8S中一个重要设计，通过Label进行对象弱关联，灵活地分类和选择不同服务或业务，让用户根据自己特定的组织结构以松耦合方式进行服务部署。

Label是一对KV，对用户而言非常有意义的，但对K8S本身而言没有直接意义的。Label可以在创建对象时指定，也可以在后期修改，每个对象可以拥有多个标签，但key值必须是唯一的。

Label可随意定义，但建议可读性，比如设置Pod的应用名称和版本号等。另外Lable是不具有唯一性的，为了更准确标识资源对象，应为资源对象设置多维度的label。

标签示例：

版本："release" : "stable", "release" : "canary"

环境："environment" : "dev", "environment" : "qa", "environment" : "production"

架构："tier" : "frontend", "tier" : "backend", "tier" : "cache"

分区："partition" : "customerA", "partition" : "customerB"

质量管控："track" : "daily", "track" : "weekly"

语法和字符集

Label keys的语法：

一个可选前缀+名称，通过/来区分

名称部分是必须的，并且最多63个字符，开始和结束的字符必须是字母或者数字，中间是字母数字和_、-、.。

前缀可选，如指定必须是个DNS子域，一系列的DNS label通过.来划分，长度不超过253个字符，"/"来结尾。如前缀被省略了，这个Label的key被假定为对用户私有的。系统组成部分（比如scheduler,controller-manager,apiserver,kubectl）,必须要指定一个前缀，Kuberentes.io前缀是为K8S内核部分保留的。

label value语法：

长度不超过63个字符。

可以为空

首位字符必须为字母数字字符

中间必须是横线、_、.、数字、字母。

Label选择器
label选择器（selector）是K8S中核心的组织原语，通过label选择器，客户端能方便辨识和选择一组资源对象。API目前支持两种选择器：基于相等的和基于集合的。

使用基于相等的选择器时，选择器的所有键值和其他资源对象的label键值完全相同（包括数量，key和value），才能匹配。

而使用基于集合的label选择器，只要选择器部分键值匹配其他资源对象的label，就算匹配。选择器可以由一个以上条件（KV键值）组成，在多个条件的情况下，所有条件都必须满足。

更新资源类型的Label

Label作为用户可灵活定义的对象属性，在已创建的对象上，仍然可以随时通过kubectl label命令对其进行增加、修改、删除等操作。 

添加标签：

例如，给已创建的Pod "redis-master-bobr0" 添加一个标签role=backend：

\# kubectl label pod redis-master-bobr0 role=backend

利用标签查看资源：

\# kubectl get pods -L role

  NAME         READY   STATUS   RESTARTS  AGE    ROLE

  redis-master-bobr0  1/1    Running  0      3m     backend

删除标签：

删除一个Label，只需在命令行最后指定Label的key名并与一个减号相连即可：

\# kubectl label pod redis-master-bobr0 role-

修改标签：

修改一个Label的值，需要加上--overwrite参数： 

\# kubectl label pod redis-master-bobr0 role=master --overwrite

使用标签选择器调用标签

  selector:       //标签选择器

​    app: nginx   //对应标签

问题：

-l和-L和有什么区别？

# 简化YAML文件创建

简化 Kubernetes Yaml 文件创建

Kubernetes 提供了丰富的 kubectl 命令，可以较为方便地处理常见任务。如果需要自动化处理复杂的Kubernetes任务，常常需要编写Yaml配置文件。由于Yaml文件格式比较复杂，即使是老司机有时也不免会犯错或需要查询文档，也有人开玩笑这是使用 Yaml 编程。

方式1：模拟命令执行

kubectl中很多命令支持 --dry-run 和 -o yaml 参数，可以方便地模拟命令执行，并输出yaml格式的命令请求，这样我们就可以将执行结果 Copy & Paste到自己的编辑器中，修改完成自己的配置文件。

\# kubectl run myapp --image=nginx --dry-run -o yaml
```
apiVersion: extensions/v1beta1

kind: Deployment

metadata:

 creationTimestamp: null

 labels:

  run: myapp

 name: myapp

spec:

 replicas: 1

 selector:

  matchLabels:

   run: myapp

 strategy: {}

 template:

  metadata:

   creationTimestamp: null

   labels:

​    run: myapp

  spec:

   containers:

   \- image: nginx

​    name: myapp

​    resources: {}

status: {}
```
```
\# kubectl create secret generic mysecret --from-literal=quiet-phrase="Shh! Dont' tell" -o yaml --dry-run
```
```
apiVersion: v1

data:

 quiet-phrase: U2hoISBEb250JyB0ZWxs

kind: Secret

metadata:

 creationTimestamp: null

 name: mysecret
```

方式2：导出资源描述

\#kubectl get <resource-type> <resource> --export -o yaml 

上面命令会以Yaml格式导出系统中已有资源描述

比如，可以将系统中 nginx 部署的描述导成 Yaml 文件：

  先查看：

  [root@k8s-master ~]# kubectl get deployment

  NAME     DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE

  my-nginx   2     2     2       1      42m

  my-nginx1  2     2     2       2      35m

  再导出：

  \# kubectl get deployment my-nginx1 --export -o yaml > nginx.yaml 

# 滚动升级
autoscale:
scale虽然能够很方便的对副本数进行扩展或缩小，但是仍然需要人工介入，不能实时自动的根据系统负载对副本数进行扩、缩。autoscale命令提供了自动根据pod负载对其副本进行扩缩的功能。 

autoscale命令会给一个rc指定一个副本数的范围，在实际运行中根据pod中运行的程序的负载自动在指定的范围内对pod进行扩容或缩容。如前面创建的nginx，可以用如下命令指定副本范围在1~4 

[root@k8s-master /]# kubectl autoscale rc myweb --min=1 --max=4 

replicationcontroller "myweb" autoscaled

Pod在创建以后希望更新Pod，可以在修改Pod的定义文件后执行：

\#kubectl replace /path/to/busybox.yaml

因为Pod的很多属性是没办法修改的，比如容器镜像，这时候可以用kubectl replace命令设置--force参数，等效于重新建Pod。

对RC使用滚动升级，来发布新功能或修复BUG

\#kubectl rolling-update replicationcontroller名 --image=镜像名

滚动升级

\#kubectl rolling-update replicationcontroller名 -f XXX.yaml

如果在升级过程中，发现有问题还可以中途停止update，并回滚到前面版本 

\#kubectl rolling-update rc-nginx-2 --rollback 

例子：

我们要对之前 Nginx 服务进行升级，把它的镜像版本从 1.7.9 升级为 1.8

只要修改这个 YAML 文件即可：

...   

  spec:

   containers:

   \- name: nginx

​    image: nginx:1.8 # 这里被从 1.7.9 修改为 1.8

​    ports:

   \- containerPort: 80

 

使用 kubectl replace 指令来完成这个更新：

\# kubectl replace -f nginx-deployment.yaml

推荐你使用 kubectl apply 命令，来统一进行 Kubernetes 对象的创建和更新操作：

\# kubectl apply -f nginx-deployment.yaml

修改 nginx-deployment.yaml 的内容

\# kubectl apply -f nginx-deployment.yaml

这是 Kubernetes"声明式 API"所推荐的使用方法。作为用户，你不必关心当前的操作是创建，还是更新，你执行的命令始终是 kubectl apply，而 Kubernetes 则会根据 YAML 文件的内容变化，自动进行具体的处理。

而这个流程的好处是，它有助于帮助开发和运维人员，围绕着可以版本化管理的 YAML 文件，而不是"行踪不定"的命令行进行协作，从而大大降低开发人员和运维人员之间的沟通成本。

举个例子，一位开发人员开发好一个应用，制作好了容器镜像。那么他就可以在应用的发布目录里附带上一个 Deployment 的 YAML 文件。

而运维人员，拿到这个应用的发布目录后，就可以直接用这个 YAML 文件执行 kubectl apply 操作把它运行起来。

这时候，如果开发人员修改了应用，生成了新的发布内容，那么这个 YAML 文件，也就需要被修改，并且成为这次变更的一部分。

而接下来，运维人员可以使用 git diff 命令查看到这个 YAML 文件本身的变化，然后继续用 kubectl apply 命令更新这个应用。

所以说，如果通过容器镜像，我们能够保证应用本身在开发与部署环境里的一致性的话，那么现在，Kubernetes 项目通过这些 YAML 文件，就保证了应用的"部署参数"在开发与部署环境中的一致性。

而当应用本身发生变化时，开发人员和运维人员可以依靠容器镜像来进行同步；当应用部署参数发生变化时，这些 YAML 文件就是他们相互沟通和信任的媒介。

# 污点NODE
通过 Taint/Toleration 调整 Master 执行 Pod 的策略
默认情况下 Master 节点是不允许运行用户 Pod 的。而 Kubernetes 做到这一点，依靠的是 Kubernetes 的 Taint/Toleration 机制。

## 原理
一旦某个节点被加上了一个 Taint，即被"打上了污点"，那么所有 Pod 就都不能在这个节点上运行，因为 Kubernetes 的 Pod 都有"洁癖"。除非，有个别的 Pod 声明自己能"容忍"这个"污点"，即声明了 Toleration，它才可以在这个节点上运行。

为节点打"污点"（Taint）：

```
\# kubectl taint nodes node1 foo=bar:NoSchedule
```

这时，该 node1 节点上就会增加一个键值对格式的 Taint，即：foo=bar:NoSchedule。其中值里面的 NoSchedule，意味着这个 Taint 只会在调度新 Pod 时产生作用，而不会影响已经在 node1 上运行的 Pod，哪怕它们没有 Toleration。

Pod 如何声明 Toleration:

只要在 Pod 的.yaml 文件中的 spec 部分，加入 tolerations 字段即可：

```
apiVersion: v1

kind: Pod

...

spec:

 tolerations:

 - key: "foo"

  operator: "Equal"

  value: "bar"

  effect: "NoSchedule"
```

这个 Toleration 的含义是，这个 Pod 能"容忍"所有键值对为 foo=bar 的 Taint（ operator: "Equal"，"等于"操作）。

现在回到已经搭建的集群上来。这时，如果你通过 kubectl describe 检查一下 Master 节点的 Taint 字段，就会有所发现了：

```
# kubectl describe node master

Name:        master
Roles:        master
Taints:       node-role.kubernetes.io/master:NoSchedule
```

可以看到，Master 节点默认被加上了node-role.kubernetes.io/master:NoSchedule这样一个"污点"，其中"键"是node-role.kubernetes.io/master，而没有提供"值"。

此时，你就需要像下面这样用"Exists"操作符（operator: "Exists"，"存在"即可）来说明，该 Pod 能够容忍所有以 foo 为键的 Taint，才能让这个 Pod 运行在该 Master 节点上：

```
apiVersion: v1
kind: Pod
...
spec:
 tolerations:
 - key: "foo"
  operator: "Exists"
  effect: "NoSchedule"
```

当然，如果你就是想要一个单节点的 Kubernetes，删除这个 Taint 才是正确的选择：

```
\# kubectl taint nodes --all node-role.kubernetes.io/master-
```

如上所示，在"node-role.kubernetes.io/master"这个键后面加上了一个短横线"-"，这个格式就意味着移除所有以“node-role.kubernetes.io/master"为键的 Taint。

# 部署HELM仓库应用
## Helm简介
可以将Helm看作Kubernetes下的apt-get/yum。Helm是Deis (https://deis.com/) 开发的一个用于kubernetes的包管理器。每个包称为一个Chart，一个Chart是一个目录（一般情况下会将目录进行打包压缩，形成name-version.tgz格式的单一文件，方便传输和存储）。 

对于应用发布者而言，可以通过Helm打包应用，管理应用依赖关系，管理应用版本并发布应用到软件仓库。

对于使用者而言，使用Helm后不用需要了解Kubernetes的Yaml语法并编写应用部署文件，可以通过Helm下载并在kubernetes上安装需要的应用。

Helm还提供了kubernetes上的软件部署，删除，升级，回滚应用的强大功能。

### Helm 组件及相关术语

#### Helm
Helm 是一个命令行客户端工具。用于 Kubernetes 应用程序 Chart 的创建、打包、发布以及创建和管理本地和远程的 Chart 仓库。

#### Tiller
Tiller 是 Helm 的服务端，部署在 Kubernetes 集群中。Tiller 用于接收 Helm 的请求，并根据 Chart 生成 Kubernetes 的部署文件（ Helm 称为 Release ），然后提交给 Kubernetes 创建应用。Tiller 还提供了 Release 的升级、删除、回滚等一系列功能。

#### Chart
Helm 的软件包，采用 TAR 格式。类似于 APT 的 DEB 包或者 YUM 的 RPM 包，其包含了一组定义 Kubernetes 资源相关的 YAML 文件。

#### Repoistory
Helm 的软件仓库，Repository 本质上是一个 Web 服务器，该服务器保存了一系列的 Chart 软件包以供用户下载，并且提供了一个该 Repository 的 Chart 包的清单文件以供查询。Helm 可以同时管理多个不同的 Repository。

#### Release
使用 helm install 命令在 Kubernetes 集群中部署的 Chart 称为 Release。

> 注： Helm 中提到的 Release 和我们通常概念中的版本有所不同，这里的 Release 可以理解为 Helm 使用 Chart 包部署的一个应用实例。
>

### Helm工作原理
![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsAOhhJM.jpg) 

#### Chart Install 过程

Helm从指定的目录或者tgz文件中解析出Chart结构信息

Helm将指定的Chart结构和Values信息通过gRPC传递给Tiller

Tiller根据Chart和Values生成一个Release

Tiller将Release发送给Kubernetes用于生成Release

#### Chart Update过程

Helm从指定的目录或者tgz文件中解析出Chart结构信息

Helm将要更新的Release的名称和Chart结构，Values信息传递给Tiller

Tiller生成Release并更新指定名称的Release的History

Tiller将Release发送给Kubernetes用于更新Release

#### Chart Rollback过程

Helm将要回滚的Release的名称传递给Tiller

Tiller根据Release的名称查找History

Tiller从History中获取上一个Release

Tiller将上一个Release发送给Kubernetes用于替换当前Release

## HELM部署
一、Helm 客户端安装

Helm 的安装方式很多，这里采用二进制的方式安装。更多安装方法可以参考 Helm 的官方帮助文档。

方式一：使用官方提供的脚本一键安装（未翻墙，下载不成功）

\# curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh

\# chmod 700 get_helm.sh

\# ./get_helm.sh

方式二：手动下载安装 （注意这里的版本要和后面的tiller同一个版本）

从官网下载最新版本的二进制安装包到本地：https://github.com/kubernetes/helm/releases

\# tar xvzf helm-v2.9.1-linux-amd64.tar.gz 

把 helm 指令放到bin目录下

\# mv linux-amd64/helm /usr/local/bin/helm

验证

\# helm help

二、Helm 服务端安装Tiller

注意：先在 K8S 集群上每个节点安装 socat 软件(yum install -y socat )，不然会报如下错误： 

E0522 22:22:15.492436  24409 portforward.go:331] an error occurred forwarding 38398 -> 44134: error forwarding port 44134 to pod dc6da4ab99ad9c497c0cef1776b9dd18e0a612d507e2746ed63d36ef40f30174, uid : unable to do port forwarding: socat not found.

Error: cannot connect to Tiller

Tiller安装
Tiller 是以 Deployment 方式部署在 Kubernetes 集群中的，只需使用以下指令便可简单的完成安装。

\# helm init

由于 Helm 默认会去 storage.googleapis.com 拉取镜像，如果你当前执行的机器不能访问该域名的话可以使用以下命令来安装：

\# helm init --client-only --stable-repo-url https://aliacs-app-catalog.oss-cn-hangzhou.aliyuncs.com/charts/

\# helm repo add incubator https://aliacs-app-catalog.oss-cn-hangzhou.aliyuncs.com/charts-incubator/

\# helm repo update

创建服务端

\# helm init --service-account tiller --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.9.1  --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

创建TLS认证服务端，参考地址：https://github.com/gjmzj/kubeasz/blob/master/docs/guide/helm.md

\# helm init --service-account tiller --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.9.1 --tiller-tls-cert /etc/kubernetes/ssl/tiller001.pem --tiller-tls-key /etc/kubernetes/ssl/tiller001-key.pem --tls-ca-cert /etc/kubernetes/ssl/ca.pem --tiller-namespace kube-system --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

在 Kubernetes 中安装 Tiller 服务，因为官方的镜像因为某些原因无法拉取，使用-i指定自己的镜像，可选镜像：registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.9.1（阿里云），该镜像的版本与helm客户端的版本相同，使用helm version可查看helm客户端版本。

如果在用helm init安装tiller server时一直部署不成功,检查deployment，根据描述解决问题。

三、给 Tiller 授权
因为 Helm 的服务端 Tiller 是一个部署在 Kubernetes 中 Kube-System Namespace 下 的 Deployment，它会去连接 Kube-Api 在 Kubernetes 里创建和删除应用。

而从 Kubernetes 1.6 版本开始，API Server 启用了 RBAC 授权。目前的 Tiller 部署时默认没有定义授权的 ServiceAccount，这会导致访问 API Server 时被拒绝。所以需要明确为 Tiller 部署添加授权。

创建 Kubernetes 的服务帐号和绑定角色

\# kubectl create serviceaccount --namespace kube-system tiller

\# kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

为 Tiller 设置帐号

使用 kubectl patch 更新 API 对象

\# kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

deployment.extensions "tiller-deploy" patched

查看是否授权成功

\# kubectl get deploy --namespace kube-system tiller-deploy -o yaml | grep serviceAccount

   serviceAccount: tiller

   serviceAccountName: tiller

四、验证 Tiller 是否安装成功

\# kubectl -n kube-system get pods|grep tiller

tiller-deploy-6d68f5c78f-nql2z      1/1    Running  0      5m

\# helm version

Client: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}

Server: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}

五、卸载 Helm 服务器端 Tiller

如果需要在 Kubernetes 中卸载已部署的 Tiller，使用以下命令完成卸载

$ helm reset 

或

$ helm reset --force

## HELM使用

Helm 使用
1、更换仓库：我们本来就用的ali仓库，不需要更换

若遇到Unable to get an update from the “stable” chart repository (https://kubernetes-charts.storage.googleapis.com) 错误

手动更换stable 存储库为阿里云的存储库

先移除原先的仓库

\# helm repo remove stable

添加新的仓库地址

\# helm repo add stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

更新仓库

\# helm repo update

2、查看在存储库中可用的所有 Helm charts：

\# helm search

NAME               CHART VERSION  APP VERSION   DESCRIPTION 

stable/acs-engine-autoscaler  2.1.3  2.1.1  Scales worker nodes within agent pools       

stable/aerospike         0.1.7   v3.14.1.2  A Helm chart for Aerospike in Kubernetes      

stable/anchore-engine    0.1.3   0.1.6    Anchore container analysis and policy evaluatio...

stable/artifactory        7.0.3    5.8.4    Universal Repository Manager supporting all maj...

stable/artifactory-ha      0.1.0   5.8.4    Universal Repository Manager supporting all maj...

stable/aws-cluster-autoscaler  0.3.2       Scales worker nodes within autoscaling groups.

... ...

3、更新charts列表：

\# helm repo update

4、安装Monocular：

helm的可视化UI 管理工具

官方建议是用 helm 进行安装，但是helm 有点费事

这里用的是直接使用docker-compose 可以运行起来的版本 

clone 代码

\# git clone  https://github.com/rongfengliang/monocular-docker-compose.git

构建镜像

\# cd monocular-docker-compose

\# docker-compose build

启动

\# docker-compose up -d

成功之后可以用下面命令查看是否真的成功和他的端口，我们看到用的是80端口，直接访问master的80端口即可

\# docker-compose ps

​       Name               Command        State        Ports      

\-------------------------------------------------------------------------------------------------------

monoculardockercompose_api_1    monocular             Up    0.0.0.0:8081->8081/tcp   

monoculardockercompose_mongodb_1  /app-entrypoint.sh /run.sh    Up    0.0.0.0:27017->27017/tcp  

monoculardockercompose_redis_1   docker-entrypoint.sh redis ...  Up    0.0.0.0:6379->6379/tcp   

monoculardockercompose_ui_1     /usr/local/openresty/bin/o ...  Up    443/tcp, 0.0.0.0:80->80/tcp

注：
因为首次启动需要下载4个镜像，而且要进行helm 源的同步，所以需要等待一段时间，需保证api server 启动正常

登陆访问：http://master

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsUIR6ia.jpg) 

5、查看K8S中已安装的charts：

\# helm list

NAME         REVISION   UPDATED           STATUS    CHART        NAMESPACE

amber-seal      1      Mon Jul  2 17:29:25 2018   DEPLOYED   nginx-ingress-0.9.5 default  

my-release      1      Mon Jul  2 15:19:44 2018   DEPLOYED   spark-0.1.10     default  

nonplussed-panther  1      Mon Jul  2 17:27:41 2018   FAILED    nginx-ingress-0.9.5 default  

turbulent-tuatara  1      Mon Jul  2 17:31:33 2018   DEPLOYED   monocular-0.6.2   default

6、删除安装的charts：

删除：helm delete xxx

\# helm delete amber-seal

Helm Chart 结构

Chart 目录结构

examples/

 Chart.yaml      # Yaml文件，用于描述Chart的基本信息，包括名称版本等

 LICENSE       # [可选] 协议

 README.md      # [可选] 当前Chart的介绍

 values.yaml     # Chart的默认配置文件

 requirements.yaml  # [可选] 用于存放当前Chart依赖的其它Chart的说明文件

 charts/       # [可选]: 该目录中放置当前Chart依赖的其它Chart

 templates/      # [可选]: 部署文件模版目录，模版使用的值来自values.yaml和由Tiller提供的值

 templates/NOTES.txt # [可选]: 放置Chart的使用指南

Chart.yaml 文件

name: [必须] Chart的名称

version: [必须] Chart的版本号，版本号必须符合 SemVer 2：http://semver.org/

description: [可选] Chart的简要描述

keywords:

 \-  [可选] 关键字列表

home: [可选] 项目地址

sources:

 \- [可选] 当前Chart的下载地址列表

maintainers: # [可选]

 \- name: [必须] 名字

  email: [可选] 邮箱

engine: gotpl # [可选] 模版引擎，默认值是gotpl

icon: [可选] 一个SVG或PNG格式的图片地址

 

requirements.yaml 和 charts目录

requirements.yaml 文件内容：

 

dependencies:

 \- name: example

  version: 1.2.3

  repository: http://example.com/charts

 \- name: Chart名称

  version: Chart版本

  repository: 该Chart所在的仓库地址 

Chart支持两种方式表示依赖关系，可以使用requirements.yaml或者直接将依赖的Chart放置到charts目录中。

templates 目录
templates目录中存放了Kubernetes部署文件的模版。

例如：

\# db.yaml

apiVersion: v1

kind: ReplicationController

metadata:

 name: deis-database

 namespace: deis

 labels:

  heritage: deis

spec:

 replicas: 1

 selector:

  app: deis-database

 template:

  metadata:

   labels:

​    app: deis-database

  spec:

   serviceAccount: deis-database

   containers:

​    \- name: deis-database

​     image: {{.Values.imageRegistry}}/postgres:{{.Values.dockerTag}}

​     imagePullPolicy: {{.Values.pullPolicy}}

​     ports:

​      \- containerPort: 5432

​     env:

​      \- name: DATABASE_STORAGE

​       value: {{default "minio" .Values.storage}}

模版语法扩展了 golang/text/template的语法：

\# 这种方式定义的模版，会去除test模版尾部所有的空行

{{- define "test"}}

模版内容

{{- end}}

\# 去除test模版头部的第一个空行

{{- template "test" }}

用于yaml文件前置空格的语法：

\# 这种方式定义的模版，会去除test模版头部和尾部所有的空行

{{- define "test" -}}

模版内容

{{- end -}}

\# 可以在test模版每一行的头部增加4个空格，用于yaml文件的对齐

{{ include "test" | indent 4}}

创建自己的chart

我们创建一个名为mongodb的chart，看一看chart的文件结构。

$ helm create mongodb

$ tree mongodb

mongodb

├── Chart.yaml #Chart本身的版本和配置信息

├── charts #依赖的chart

├── templates #配置模板目录

│  ├── NOTES.txt #helm提示信息

│  ├── _helpers.tpl #用于修改kubernetes objcet配置的模板

│  ├── deployment.yaml #kubernetes Deployment object

│  └── service.yaml #kubernetes Serivce

└── values.yaml #kubernetes object configuration

 

2 directories, 6 files

模板
Templates目录下是yaml文件的模板，遵循Go template语法。使用过Hugo的静态网站生成工具的人应该对此很熟悉。

我们查看下deployment.yaml文件的内容。

apiVersion: extensions/v1beta1

kind: Deployment

metadata:

 name: {{ template "fullname" . }}

 labels:

  chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"

spec:

 replicas: {{ .Values.replicaCount }}

 template:

  metadata:

   labels:

​    app: {{ template "fullname" . }}

  spec:

   containers:

   \- name: {{ .Chart.Name }}

​    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"

​    imagePullPolicy: {{ .Values.image.pullPolicy }}

​    ports:

​    \- containerPort: {{ .Values.service.internalPort }}

​    livenessProbe:

​     httpGet:

​      path: /

​      port: {{ .Values.service.internalPort }}

​    readinessProbe:

​     httpGet:

​      path: /

​      port: {{ .Values.service.internalPort }}

​    resources:

{{ toyaml .Values.resources | indent 12 }}

这是该应用的Deployment的yaml配置文件，其中的双大括号包扩起来的部分是Go template，其中的Values是在values.yaml文件中定义的：

\# Default values for mychart.

\# This is a yaml-formatted file.

\# Declare variables to be passed into your templates.

replicaCount: 1

image:

 repository: nginx

 tag: stable

 pullPolicy: IfNotPresent

service:

 name: nginx

 type: ClusterIP

 externalPort: 80

 internalPort: 80

resources:

 limits:

  cpu: 100m

  memory: 128Mi

 requests:

  cpu: 100m

  memory: 128Mi

比如在Deployment.yaml中定义的容器镜像image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"其中的：

.Values.image.repository就是nginx

.Values.image.tag就是stable

以上两个变量值是在create chart的时候自动生成的默认值。

我们将默认的镜像地址和tag改成我们自己的镜像harbor-001.jimmysong.io/library/nginx:1.9。

检查配置和模板是否有效

当使用kubernetes部署应用的时候实际上讲templates渲染成最终的kubernetes能够识别的yaml格式。

使用helm install --dry-run --debug <chart_dir>命令来验证chart配置。该输出中包含了模板的变量配置与最终渲染的yaml文件。

$ helm install --dry-run --debug mychart

Created tunnel using local port: '58406'

SERVER: "localhost:58406"

CHART PATH: /Users/jimmy/Workspace/github/bitnami/charts/incubator/mean/charts/mychart

NAME:  filled-seahorse

REVISION: 1

RELEASED: Tue Oct 24 18:57:13 2017

CHART: mychart-0.1.0

USER-SUPPLIED VALUES:

{}

COMPUTED VALUES:

image:

 pullPolicy: IfNotPresent

 repository: harbor-001.jimmysong.io/library/nginx

 tag: 1.9

replicaCount: 1

resources:

 limits:

  cpu: 100m

  memory: 128Mi

 requests:

  cpu: 100m

  memory: 128Mi

service:

 externalPort: 80

 internalPort: 80

 name: nginx

 type: ClusterIP

 

HOOKS:

MANIFEST:

\---

\# Source: mychart/templates/service.yaml

apiVersion: v1

kind: Service

metadata:

 name: filled-seahorse-mychart

 labels:

  chart: "mychart-0.1.0"

spec:

 type: ClusterIP

 ports:

 \- port: 80

  targetPort: 80

  protocol: TCP

  name: nginx

 selector:

  app: filled-seahorse-mychart

 

\---

\# Source: mychart/templates/deployment.yaml

apiVersion: extensions/v1beta1

kind: Deployment

metadata:

 name: filled-seahorse-mychart

 labels:

  chart: "mychart-0.1.0"

spec:

 replicas: 1

 template:

  metadata:

   labels:

​    app: filled-seahorse-mychart

  spec:

   containers:

   \- name: mychart

​    image: "harbor-001.jimmysong.io/library/nginx:1.9"

​    imagePullPolicy: IfNotPresent

​    ports:

​    \- containerPort: 80

​    livenessProbe:

​     httpGet:

​      path: /

​      port: 80

​    readinessProbe:

​     httpGet:

​      path: /

​      port: 80

​    resources:

​      limits:

​       cpu: 100m

​       memory: 128Mi

​      requests:

​       cpu: 100m

​       memory: 128Mi

我们可以看到Deployment和Service的名字前半截由两个随机的单词组成，最后才是我们在values.yaml中配置的值。

 

部署到kubernetes

在mychart目录下执行下面的命令将nginx部署到kubernetes集群上。

 

helm install .

NAME:  eating-hound

LAST DEPLOYED: Wed Oct 25 14:58:15 2017

NAMESPACE: default

STATUS: DEPLOYED

 

RESOURCES:

==> v1/Service

NAME          CLUSTER-IP   EXTERNAL-IP  PORT(S)  AGE

eating-hound-mychart  10.254.135.68  <none>    80/TCP  0s

 

==> extensions/v1beta1/Deployment

NAME          DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE

eating-hound-mychart  1     1     1      0      0s

 

 

NOTES:

\1. Get the application URL by running these commands:

 export POD_NAME=$(kubectl get pods --namespace default -l "app=eating-hound-mychart" -o jsonpath="{.items[0].metadata.name}")

 echo "Visit http://127.0.0.1:8080 to use your application"

 kubectl port-forward $POD_NAME 8080:80

现在nginx已经部署到kubernetes集群上，本地执行提示中的命令在本地主机上访问到nginx实例。

 

export POD_NAME=$(kubectl get pods --namespace default -l "app=eating-hound-mychart" -o jsonpath="{.items[0].metadata.name}")

echo "Visit http://127.0.0.1:8080 to use your application"

kubectl port-forward $POD_NAME 8080:80

在本地访问http://127.0.0.1:8080即可访问到nginx。

 

查看部署的relaese

 

$ helm list

NAME       REVISION   UPDATED           STATUS    CHART       NAMESPACE

eating-hound   1      Wed Oct 25 14:58:15 2017   DEPLOYED   mychart-0.1.0   default

删除部署的release

 

$ helm delete eating-hound

release "eating-hound" deleted

打包分享

我们可以修改Chart.yaml中的helm chart配置信息，然后使用下列命令将chart打包成一个压缩文件。

 

helm package .

打包出mychart-0.1.0.tgz文件。

 

将应用发布到 Repository

虽然我们已经打包了 Chart 并发布到了 Helm 的本地目录中，但通过 helm search 命令查找，并不能找不到刚才生成的 mychart包。

 

$ helm search mychart

No results found

这是因为 Repository 目录中的 Chart 包还没有被 Helm 管理。通过 helm repo list 命令可以看到目前 Helm 中已配置的 Repository 的信息。

 

$ helm repo list

NAME   URL

stable  https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

注：新版本中执行 helm init 命令后默认会配置一个名为 local 的本地仓库。

 

我们可以在本地启动一个 Repository Server，并将其加入到 Helm Repo 列表中。Helm Repository 必须以 Web 服务的方式提供，这里我们就使用 helm serve 命令启动一个 Repository Server，该 Server 缺省使用 $HOME/.helm/repository/local 目录作为 Chart 存储，并在 8879 端口上提供服务。

 

$ helm serve &

Now serving you on 127.0.0.1:8879

默认情况下该服务只监听 127.0.0.1，如果你要绑定到其它网络接口，可使用以下命令：

 

$ helm serve --address 192.168.100.211:8879 &

如果你想使用指定目录来做为 Helm Repository 的存储目录，可以加上 --repo-path 参数：

 

$ helm serve --address 192.168.100.211:8879 --repo-path /data/helm/repository/ --url http://192.168.100.211:8879/charts/

通过 helm repo index 命令将 Chart 的 Metadata 记录更新在 index.yaml 文件中:

 

\# 更新 Helm Repository 的索引文件

$ cd /home/k8s/.helm/repository/local

$ helm repo index --url=http://192.168.100.211:8879 .

完成启动本地 Helm Repository Server 后，就可以将本地 Repository 加入 Helm 的 Repo 列表。

 

$ helm repo add local http://127.0.0.1:8879

"local" has been added to your repositories

现在再次查找 mychart 包，就可以搜索到了。

 

$ helm repo update

$ helm search mychart

NAME      CHART VERSION APP VERSION DESCRIPTION

local/mychart 0.1.0     1.0     A Helm chart for Kubernetes

依赖

我们可以在requirement.yaml中定义应用所依赖的chart，例如定义对mariadb的依赖：

 

dependencies:

\- name: mariadb

 version: 0.6.0

 repository: https://kubernetes-charts.storage.googleapis.com

使用helm lint .命令可以检查依赖和模板配置是否正确。

 

helm升级和回退一个应用

从上面 helm list 输出的结果中我们可以看到有一个 Revision（更改历史）字段，该字段用于表示某一个 Release 被更新的次数，我们可以用该特性对已部署的 Release 进行回滚。

 

修改 Chart.yaml 文件

 

将版本号从 0.1.0 修改为 0.2.0, 然后使用 helm package 命令打包并发布到本地仓库。

 

$ cat mychart/Chart.yaml

apiVersion: v1

appVersion: "1.0"

description: A Helm chart for Kubernetes

name: mychart

version: 0.2.0

 

$ helm package mychart

Successfully packaged chart and saved it to: /home/k8s/mychart-0.2.0.tgz

查询本地仓库中的 Chart 信息

 

我们可以看到在本地仓库中 mychart 有两个版本。

 

$ helm search mychart -l

NAME      CHART VERSION APP VERSION DESCRIPTION

local/mychart 0.2.0     1.0     A Helm chart for Kubernetes

local/mychart 0.1.0     1.0     A Helm chart for Kubernetes

升级一个应用

现在用 helm upgrade 命令将已部署的 mike-test 升级到新版本。你可以通过 --version 参数指定需要升级的版本号，如果没有指定版本号，则缺省使用最新版本。

 

$ helm upgrade mike-test local/mychart

Release "mike-test" has been upgraded. Happy Helming!

LAST DEPLOYED: Mon Jul 23 10:50:25 2018

NAMESPACE: default

STATUS: DEPLOYED

 

RESOURCES:

==> v1/Pod(related)

NAME                 READY  STATUS  RESTARTS  AGE

mike-test-mychart-6d56f8c8c9-d685v  1/1   Running  0     9m

 

==> v1/Service

NAME        TYPE    CLUSTER-IP    EXTERNAL-IP  PORT(S)  AGE

mike-test-mychart  ClusterIP  10.254.120.177  <none>    80/TCP  9m

 

==> v1beta2/Deployment

NAME        DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE

mike-test-mychart  1     1     1      1      9m

 

NOTES:

\1. Get the application URL by running these commands:

export POD_NAME=$(kubectl get pods --namespace default -l "app=mychart,release=mike-test" -o jsonpath="{.items[0].metadata.name}")

echo "Visit http://127.0.0.1:8080 to use your application"

kubectl port-forward $POD_NAME 8080:80

完成后，可以看到已部署的 mike-test 被升级到 0.2.0 版本。

 

$ helm list

NAME    REVISION  UPDATED          STATUS   CHART     NAMESPACE

mike-test 2     Mon Jul 23 10:50:25 2018  DEPLOYED  mychart-0.2.0 default

回退一个应用

如果更新后的程序由于某些原因运行有问题，需要回退到旧版本的应用。首先我们可以使用 helm history 命令查看一个 Release 的所有变更记录。

 

$ helm history mike-test

REVISION  UPDATED          STATUS    CHART     DESCRIPTION

1     Mon Jul 23 10:41:20 2018  SUPERSEDED  mychart-0.1.0 Install complete

2     Mon Jul 23 10:50:25 2018  DEPLOYED   mychart-0.2.0 Upgrade complete

其次，我们可以使用下面的命令对指定的应用进行回退。

 

$ helm rollback mike-test 1

Rollback was a success! Happy Helming!

注：其中的参数 1 是 helm history 查看到 Release 的历史记录中 REVISION 对应的值。

 

最后，我们使用 helm list 和 helm history 命令都可以看到 mychart 的版本已经回退到 0.1.0 版本。

 

$ helm list

NAME    REVISION  UPDATED          STATUS   CHART     NAMESPACE

mike-test 3     Mon Jul 23 10:53:42 2018  DEPLOYED  mychart-0.1.0 default

 

$ helm history mike-test

REVISION  UPDATED          STATUS    CHART     DESCRIPTION

1     Mon Jul 23 10:41:20 2018  SUPERSEDED  mychart-0.1.0 Install complete

2     Mon Jul 23 10:50:25 2018  SUPERSEDED  mychart-0.2.0 Upgrade complete

3     Mon Jul 23 10:53:42 2018  DEPLOYED   mychart-0.1.0 Rollback to 1

删除一个应用

如果需要删除一个已部署的 Release，可以利用 helm delete 命令来完成删除。

 

$ helm delete mike-test

release "mike-test" deleted

确认应用是否删除，该应用已被标记为 DELETED 状态。

 

$ helm ls -a mike-test

NAME    REVISION  UPDATED          STATUS  CHART     NAMESPACE

mike-test 3     Mon Jul 23 10:53:42 2018  DELETED mychart-0.1.0 default

也可以使用 --deleted 参数来列出已经删除的 Release

 

$ helm ls --deleted

NAME    REVISION  UPDATED          STATUS  CHART     NAMESPACE

mike-test 3     Mon Jul 23 10:53:42 2018  DELETED mychart-0.1.0 default

从上面的结果也可以看出，默认情况下已经删除的 Release 只是将状态标识为 DELETED 了 ，但该 Release 的历史信息还是继续被保存的。

 

$ helm hist mike-test

REVISION  UPDATED          STATUS    CHART     DESCRIPTION

1     Mon Jul 23 10:41:20 2018  SUPERSEDED  mychart-0.1.0 Install complete

2     Mon Jul 23 10:50:25 2018  SUPERSEDED  mychart-0.2.0 Upgrade complete

3     Mon Jul 23 10:53:42 2018  DELETED   mychart-0.1.0 Deletion complete

如果要移除指定 Release 所有相关的 Kubernetes 资源和 Release 的历史记录，可以用如下命令：

 

$ helm delete --purge mike-test

release "mike-test" deleted

再次查看已删除的 Release，已经无法找到相关信息。

 

$ helm hist mike-test

Error: release: "mike-test" not found

 

\# helm ls 命令也已均无查询记录。

$ helm ls --deleted

$ helm ls -a mike-test

使用Helm 部署 Wordpress应用实例

以Wordpress 为例，包括 MySQL、PHP 和 Apache。

 

由于测试环境没有可用的 PersistentVolume（持久卷，简称 PV），这里暂时将其关闭。

 

$ helm install --name wordpress-test --set "persistence.enabled=false,mariadb.persistence.enabled=false,serviceType=NodePort"  stable/wordpress

 

NAMESPACE: default

STATUS: DEPLOYED

 

RESOURCES:

==> v1beta1/Deployment

NAME            DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE

wordpress-test-mariadb   1     1     1      1      26m

wordpress-test-wordpress  1     1     1      1      26m

 

==> v1/Pod(related)

NAME                    READY  STATUS  RESTARTS  AGE

wordpress-test-mariadb-84b866bf95-n26ff   1/1   Running  1     26m

wordpress-test-wordpress-5ff8c64b6c-sgtvv  1/1   Running  6     26m

 

==> v1/Secret

NAME            TYPE   DATA  AGE

wordpress-test-mariadb   Opaque  2   26m

wordpress-test-wordpress  Opaque  2   26m

 

==> v1/ConfigMap

NAME              DATA  AGE

wordpress-test-mariadb     1   26m

wordpress-test-mariadb-tests  1   26m

 

==> v1/Service

NAME            TYPE    CLUSTER-IP   EXTERNAL-IP  PORT(S)          AGE

wordpress-test-mariadb   ClusterIP  10.254.99.67  <none>    3306/TCP          26m

wordpress-test-wordpress  NodePort  10.254.175.16  <none>    80:8563/TCP,443:8839/TCP  26m

 

NOTES:

\1. Get the WordPress URL:

 

Or running:

 

export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services wordpress-test-wordpress)

export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")

echo http://$NODE_IP:$NODE_PORT/admin

 

\2. Login with the following credentials to see your blog

 

echo Username: user

echo Password: $(kubectl get secret --namespace default wordpress-test-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)

访问 Wordpress

 

部署完成后，我们可以通过上面的提示信息生成相应的访问地址和用户名、密码等相关信息。

 

\# 生成 Wordpress 管理后台地址

$ export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services wordpress-test-wordpress)

$ export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")

$ echo http://$NODE_IP:$NODE_PORT/admin

http://192.168.100.211:8433/admin

 

\# 生成 Wordpress 管理帐号和密码

$ echo Username: user

Username: user

$ echo Password: $(kubectl get secret --namespace default wordpress-test-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)

Password: 9jEXJgnVAY

给一张访问效果图吧：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsSZHKTx.jpg) 

 

 

Helm 其它使用技巧

如何设置 helm 命令自动补全？

 

为了方便 helm 命令的使用，Helm 提供了自动补全功能，如果使用 ZSH 请执行：

 

$ source <(helm completion zsh)

如果使用 BASH 请执行：

 

$ source <(helm completion bash)

如何使用第三方的 Chart 存储库？

 

随着 Helm 越来越普及，除了使用预置官方存储库，三方仓库也越来越多了（前提是网络是可达的）。你可以使用如下命令格式添加三方 Chart 存储库。

 

$ helm repo add 存储库名 存储库URL

$ helm repo update

一些三方存储库资源:

 

\# Prometheus Operator

https://github.com/coreos/prometheus-operator/tree/master/helm

 

\# Bitnami Library for Kubernetes

https://github.com/bitnami/charts

 

\# Openstack-Helm

https://github.com/att-comdev/openstack-helm

https://github.com/sapcc/openstack-helm

 

\# Tick-Charts

https://github.com/jackzampolin/tick-charts

Helm 如何结合 CI/CD ？

 

采用 Helm 可以把零散的 Kubernetes 应用配置文件作为一个 Chart 管理，Chart 源码可以和源代码一起放到 Git 库中管理。通过把 Chart 参数化，可以在测试环境和生产环境采用不同的 Chart 参数配置。

 

下图是采用了 Helm 的一个 CI/CD 流程

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsbOFtuV.jpg) 

 

 

Helm 如何管理多环境下 (Test、Staging、Production) 的业务配置？

 

Chart 是支持参数替换的，可以把业务配置相关的参数设置为模板变量。使用 helm install 命令部署的时候指定一个参数值文件，这样就可以把业务参数从 Chart 中剥离了。例如： helm install --values=values-production.yaml wordpress。

 

Helm 如何解决服务依赖？

 

在 Chart 里可以通过 requirements.yaml 声明对其它 Chart 的依赖关系。如下面声明表明 Chart 依赖 Apache 和 MySQL 这两个第三方 Chart。

 

dependencies:

\- name: mariadb

version: 2.1.1

repository: https://kubernetes-charts.storage.googleapis.com/

condition: mariadb.enabled

tags:

\- wordpress-database

\- name: apache

version: 1.4.0

repository: https://kubernetes-charts.storage.googleapis.com/

如何让 Helm 连接到指定 Kubernetes 集群？

 

Helm 默认使用和 kubectl 命令相同的配置访问 Kubernetes 集群，其配置默认在 ~/.kube/config 中。

 

如何在部署时指定命名空间？

 

helm install 默认情况下是部署在 default 这个命名空间的。如果想部署到指定的命令空间，可以加上 --namespace 参数，比如：

 

$ helm install local/mychart --name mike-test --namespace mynamespace

如何查看已部署应用的详细信息？

 

$ helm get wordpress-test

默认情况下会显示最新的版本的相关信息，如果想要查看指定发布版本的信息可加上 --revision 参数。

 

$ helm get  --revision 1  wordpress-test

 

 

# 部署DASHBOARD应用

wing已测

 

开发写应用（在容器里面）---》镜像---》私有仓库---》编写yaml文件--》创建应用

 

 

 

部署Dashboard

注意：最后部署成功之后，因为有5种方式访问dashboard：我们这里只使用Nodport方式访问

\1. Nodport方式访问dashboard，service类型改为NodePort

\2. loadbalacer方式，service类型改为loadbalacer

\3. Ingress方式访问dashboard

\4. API server方式访问 dashboard

\5. kubectl proxy方式访问dashboard

 

\1. 下载yaml文件：

可以自己下载，也可以使用子目录中的内容自己创建

[root@master /]# wget https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

 

\2. 下载镜像

可以不用事先下载

由于yaml配置文件中指定镜像从google拉取，先下载yaml文件到本地，修改配置从阿里云仓库拉取镜像。

[root@master yaml]# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.1

 

\3. 修改yaml文件

修改yaml配置文件image部分，指定镜像从阿里云镜像仓库拉取：

\# vim kubernetes-dashboard.yaml

......

 containers:

   \- name: kubernetes-dashboard

​    \#image: k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1

​    image: registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.1

​    ports:

......

 

\4. 创建应用：

\# kubectl apply -f kubernetes-dashboard.yml

 

查看Pod 的状态为running说明dashboard已经部署成功：

\# kubectl get pod --namespace=kube-system -o wide | grep dashboard

kubernetes-dashboard-847f8cb7b8-wrm4l  1/1   Running  0      19m  10.244.2.5    k8s-node2   <none>      <none>

 

Dashboard 会在 kube-system namespace 中创建自己的 Deployment 和 Service：

\#  kubectl get deployment kubernetes-dashboard --namespace=kube-system

NAME          READY  UP-TO-DATE  AVAILABLE  AGE

kubernetes-dashboard  1/1   1       1      21m

 

\# kubectl get service kubernetes-dashboard --namespace=kube-system

NAME          TYPE    CLUSTER-IP    EXTERNAL-IP  PORT(S)     AGE

kubernetes-dashboard  ClusterIP  10.104.254.251  <none>     443/TCP  21m

 

\5. 访问dashboard

官方参考文档：

https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/#accessing-the-dashboard-ui

 

有5种方式访问dashboard：

Nodport方式访问dashboard，service类型改为NodePort

loadbalacer方式，service类型改为loadbalacer

Ingress方式访问dashboard

API server方式访问 dashboard

kubectl proxy方式访问dashboard

 

NodePort方式

为了便于本地访问，修改yaml文件，将service改为NodePort 类型：

\# vim kubernetes-dashboard.yaml 

......

\---

\# ------------------- Dashboard Service ------------------- #

 

kind: Service

apiVersion: v1

metadata:

 labels:

  k8s-app: kubernetes-dashboard

 name: kubernetes-dashboard

 namespace: kube-system

spec:

 type: NodePort    #增加type: NodePort

 ports:

  \- port: 443

   targetPort: 8443

   nodePort: 31620  #增加nodePort: 31620

 selector:

  k8s-app: kubernetes-dashboard

 

重新应用yaml文件：

\# kubectl apply -f kubernetes-dashboard.yaml

 

查看service，TYPE类型已经变为NodePort，端口为31620

\# kubectl get service -n kube-system | grep dashboard

kubernetes-dashboard  NodePort   10.107.160.197  <none>     443:31620/TCP  32m

 

通过浏览器访问：https://node2:31620 

因为我的应用运行在node2上，又是NodePort方式，所以直接访问node2的地址

登录界面如下：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsZmpn5i.jpg) 

 

 

Dashboard 支持 Kubeconfig 和 Token 两种认证方式，这里选择Token认证方式登录：

上面的Token先空着，不要往下点，接下来制作token

 

创建登录用户

官方参考文档：

https://github.com/kubernetes/dashboard/wiki/Creating-sample-user

 

创建dashboard-adminuser.yaml：

\# vim dashboard-adminuser.yaml

apiVersion: v1

kind: ServiceAccount

metadata:

 name: admin-user

 namespace: kube-system

\---

apiVersion: rbac.authorization.k8s.io/v1

kind: ClusterRoleBinding

metadata:

 name: admin-user

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: ClusterRole

 name: cluster-admin

subjects:

\- kind: ServiceAccount

 name: admin-user

 namespace: kube-system

 

执行yaml文件：

\# kubectl create -f dashboard-adminuser.yaml

 

说明：上面创建了一个叫admin-user的服务账号，并放在kube-system命名空间下，并将cluster-admin角色绑定到admin-user账户，这样admin-user账户就有了管理员的权限。默认情况下，kubeadm创建集群时已经创建了cluster-admin角色，直接绑定即可。

 

查看admin-user账户的token

\# kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

Name:     admin-user-token-5b7qc

Namespace:   kube-system

Labels:    <none>

Annotations:  kubernetes.io/service-account.name: admin-user

​       kubernetes.io/service-account.uid: 88591dc9-30eb-11e9-abbe-000c290a5b8b

 

Type:  kubernetes.io/service-account-token

 

Data

====

ca.crt:   1025 bytes

namespace:  11 bytes

token:    eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLTViN3FjIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI4ODU5MWRjOS0zMGViLTExZTktYWJiZS0wMDBjMjkwYTViOGIiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.avwTPZTDOALFVW5Z0xWF0lr1-hoU_H4HPUOu4cFEvy4BYm2CVX1SIYqTanBWgvWgcUikcyKS4J-J5G1nSFPpNggxaXzxMXyvCq8sy-Fkuj4JUbHybzacrX6fLP96paHr_wbCex-BVo7NghSebdwpi6JOV6zEhJk-3LiqyXUNpfCSoWsrMogSk-XSZatAQqhfEVjsg9KLQ2_ugvKkV_7JW30-zJbsymtS8eDB85vxvIrB_1yqSsYc6dUQ8WHroqablmdV57ifSQccmg3JRaaYCEQpE8IYiGmqEi3L5zS37WQ3CZ3uVZKygh7oYQGBu5vnQm7igBK8FDNS4KvXaKWeVQ

 

把获取到的Token复制到登录界面的Token输入框中:

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpskXFmGG.jpg) 

 

成功登陆dashboard:

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsq1Ynh4.jpg) 

 

 

\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

使用Dashboard

Dashboard 界面结构分为三个大的区域:

\1. 顶部操作区，在这里用户可以搜索集群中的资源、创建资源或退出。

\2. 左边导航菜单，通过导航菜单可以查看和管理集群中的各种资源。菜单项按照资源的层级分为两类：Cluster 级别的资源 ，Namespace 级别的资源 ，默认显示的是 default Namespace，可以进行切换

\3. 中间主体区，在导航菜单中点击了某类资源，中间主体区就会显示该资源所有实例，比如点击 Pods。

## 其他4种登陆方式

loadbalacer方式

特别注意： 这种方式只有在云服务器上才可以使用，比如google的gce

 

首先需要部署metallb负载均衡器，部署参考：

https://blog.csdn.net/networken/article/details/85928369

 

修改kubernetes-dashboard.yaml文件，最后service部分改为type: LoadBalancer即可：

\# vim kubernetes-dashboard.yaml 

......

\---

\# ------------------- Dashboard Service ------------------- #

 

kind: Service

apiVersion: v1

metadata:

 labels:

  k8s-app: kubernetes-dashboard

 name: kubernetes-dashboard

 namespace: kube-system

spec:

 type: LoadBalancer

 ports:

  \- port: 443

   targetPort: 8443

 selector:

  k8s-app: kubernetes-dashboard

 

重新应用yaml文件

\# kubectl apply -f kubernetes-dashboard.yaml --force

 

注意： 由nodeport改为其他类型需要添加–forece才能执行成功。

 

查看service，TYPE类型已经变为LoadBalancer，并且分配了EXTERNAL-IP：

\# kubectl get service kubernetes-dashboard -n kube-system 

NAME          TYPE      CLUSTER-IP    EXTERNAL-IP    PORT(S)     AGE

kubernetes-dashboard  LoadBalancer  10.107.160.197  192.168.92.202  443:32471/TCP  10m

 

浏览器输入https://192.168.92.202访问，填写之前申请的token进行登录：

登录成功

 

\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

nginx-ingress方式

 

部署nginx-ingress-controller

\# wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

\# kubectl apply -f mandatory.yaml

 

详细部署参考：https://blog.csdn.net/networken/article/details/85881558

 

创建Dashboard TLS证书

\# mkdir -p /usr/local/src/kubernetes/certs

\# cd /usr/local/src/kubernetes

\# openssl genrsa -des3 -passout pass:x -out certs/dashboard.pass.key 2048

\# openssl rsa -passin pass:x -in certs/dashboard.pass.key -out certs/dashboard.key

\# openssl req -new -key certs/dashboard.key -out certs/dashboard.csr -subj '/CN=kube-dashboard'

\# openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt

\# rm certs/dashboard.pass.key

\# kubectl create secret generic kubernetes-dashboard-certs --from-file=certs -n kube-system

 

创建ingress规则

文件末尾添加tls配置项即可

\# vim kubernetes-dashboard-ingress.yaml 

apiVersion: extensions/v1beta1

kind: Ingress

metadata:

 labels:

  k8s-app: kubernetes-dashboard

 annotations:

  kubernetes.io/ingress.class: "nginx"

  \# https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md

  nginx.ingress.kubernetes.io/ssl-redirect: "true"

  nginx.ingress.kubernetes.io/ssl-passthrough: "true"

 name: kubernetes-dashboard

 namespace: kube-system

spec:

 rules:

 \- host: dashboard.host.com

  http:

   paths:

   \- path: /

​    backend:

​     servicePort: 443

​     serviceName: kubernetes-dashboard

 tls:

 \- hosts:

  \- dashboard.host.com

  secretName: kubernetes-dashboard-certs

 

查看创建的ingress:

\# kubectl get ingress -n kube-system 

NAME          HOSTS         ADDRESS  PORTS   AGE

kubernetes-dashboard  dashboard.host.com       80, 443  30h

 

暴露nginx-ingress-controller服务

要想暴露内部流量，需要让 Ingress Controller 自身能够对外提供服务，主要有以下几种方式：

  \1. hostport

  \2. nodeport

  \3. loadbalacer

 

hostport方式

修改nginx-ingress-controller yaml配置文件，将Ingress Controller 改为 DeamonSet 方式部署（注释replicas），在每个节点运行一个nginx-ingress-controller的pod，然后在containers.ports部分做主机端口映射，添加 hostPort: 80和 hostPort: 443

 

\# vim mandatory.yaml 

......

\---

 

apiVersion: extensions/v1beta1

kind: DaemonSet  #改为DaemonSet

metadata:

 name: nginx-ingress-controller

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

spec:

\#  replicas: 1   #注释掉replicas

......

​     ports:

​      \- name: http

​       containerPort: 80

​       hostPort: 80

​      \- name: https

​       containerPort: 443

​       hostPort: 443

......

 

更新yaml配置文件：

\# kubectl apply -f mandatory.yaml

 

查看运行的pod：

 

\# kubectl get  pod -n ingress-nginx  -o wide

NAME               READY  STATUS   RESTARTS  AGE  IP       NODE     NOMINATED NODE  READINESS GATES

nginx-ingress-controller-bhccq  1/1   Running  0      18s  10.244.2.102  k8s-node2   <none>      <none>

nginx-ingress-controller-fssbt  1/1   Running  0      18s  10.244.0.55   k8s-master  <none>      <none>

nginx-ingress-controller-z7xsf  1/1   Running  0      18s  10.244.1.101  k8s-node1   <none>      <none>

\# 

 

修改dashboard yaml文件配置

在deployment.containers部分增加args配置，在service部分改回默认即可：

 

\# vim kubernetes-dashboard.yaml 

......

\---

\# ------------------- Dashboard Deployment ------------------- #

 

kind: Deployment

apiVersion: apps/v1beta2

metadata:

 labels:

  k8s-app: kubernetes-dashboard

 name: kubernetes-dashboard

 namespace: kube-system

spec:

 replicas: 1

 revisionHistoryLimit: 10

 selector:

  matchLabels:

   k8s-app: kubernetes-dashboard

 template:

  metadata:

   labels:

​    k8s-app: kubernetes-dashboard

  spec:

   containers:

   \- name: kubernetes-dashboard

​    \#image: k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1

​    image: registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.1

​    ports:

​    \- containerPort: 8443

​     protocol: TCP

​    args:

​     \- --tls-key-file=dashboard.key

​     \- --tls-cert-file=dashboard.crt

​     \#- --auto-generate-certificates

​     \# Uncomment the following line to manually specify Kubernetes API server Host

​     \# If not specified, Dashboard will attempt to auto discover the API server and connect

​     \# to it. Uncomment only if the default does not work.

​     \# - --apiserver-host=http://my-address:port

​    volumeMounts:

......

\---

\# ------------------- Dashboard Service ------------------- #

 

kind: Service

apiVersion: v1

metadata:

 labels:

  k8s-app: kubernetes-dashboard

 name: kubernetes-dashboard

 namespace: kube-system

spec:

 ports:

  \- port: 443

   targetPort: 8443

 selector:

  k8s-app: kubernetes-dashboard

 

最后应用变更：

 

kubectl apply -f kubernetes-dashboard.yaml --force

 

查看dashboard service:

 

\# kubectl get service -n kube-system 

NAME          TYPE     CLUSTER-IP   EXTERNAL-IP  PORT(S)     AGE

......

kubernetes-dashboard  ClusterIP  10.96.55.60  <none>     443/TCP     30h

 

 

集群外部节点配置DNS解析:

 

192.168.92.56 dashboard.host.com

192.168.92.57 dashboard.host.com

192.168.92.58 dashboard.host.com

 

集群外部直接访问：https://dashboard.host.com

填入之前申请的token，访问成功

 

NodePort方式

修改nginx-ingress-controller配置文件mandatory.yaml，删除containers.ports部分做的主机端口映射，hostPort: 80和 hostPort: 443

并为nginx-ingress-controller创建NodePort类型的service,通过nodeip+port方式对外提供服务：

 

\# wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml

\# kubectl apply -f service-nodeport.yaml

 

直接执行yaml文件即可，可以看到创建了nginx-ingress-controller的NodePort类型service:

 

\# kubectl get service -n ingress-nginx 

NAME       TYPE    CLUSTER-IP   EXTERNAL-IP  PORT(S)            AGE

ingress-nginx  NodePort  10.100.30.8  <none>     80:32142/TCP,443:32179/TCP  29h

 

集群外主机hosts配置文件不变

 

192.168.92.56 dashboard.host.com

192.168.92.57 dashboard.host.com

192.168.92.58 dashboard.host.com

 

选择token方式，通过域名+port方式访问：https://dashboard.host.com:32179

 

loadbalancer方式

首先需要部署loadbalancer，参考这里：

https://blog.csdn.net/networken/article/details/85928369

然后修改nginx ingress controller的service类型为type: LoadBalancer即可：

 

\# vim service-nodeport.yaml

apiVersion: v1

kind: Service

metadata:

 name: ingress-nginx

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

spec:

 type: LoadBalancer

 ports:

  \- name: http

   port: 80

   targetPort: 80

   protocol: TCP

  \- name: https

   port: 443

   targetPort: 443

   protocol: TCP

 selector:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

更新yaml文件：

 

kubectl apply -f service-nodeport.yaml --force

1

查看service 类型以及获取到的EXTERNAL-IP

 

\# kubectl get svc -n ingress-nginx 

NAME       TYPE      CLUSTER-IP    EXTERNAL-IP    PORT(S)            AGE

ingress-nginx  LoadBalancer  10.111.158.158  192.168.92.200  80:32629/TCP,443:30118/TCP  20s

 

 

修改集群外主机hosts配置文件,配置下面一条即可

 

192.168.92.200 dashboard.host.com

 

通过token方式浏览器访问：https://dashboard.host.com

 

 

\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

API Server方式

如果Kubernetes API服务器是公开的，并可以从外部访问，那我们可以直接使用API Server的方式来访问，也是比较推荐的方式。

Dashboard的访问地址为：

 

https://<master-ip>:<apiserver-port>/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

 

但是浏览器返回的结果可能如下：

 

{

 "kind": "Status",

 "apiVersion": "v1",

 "metadata": {

  

 },

 "status": "Failure",

 "message": "services \"https:kubernetes-dashboard:\" is forbidden: User \"system:anonymous\" cannot get resource \"services/proxy\" in API group \"\" in the namespace \"kube-system\"",

 "reason": "Forbidden",

 "details": {

  "name": "https:kubernetes-dashboard:",

  "kind": "services"

 },

 "code": 403

}

 

这是因为最新版的k8s默认启用了RBAC，并为未认证用户赋予了一个默认的身份：anonymous。

对于API Server来说，它是使用证书进行认证的，我们需要先创建一个证书：

我们使用client-certificate-data和client-key-data生成一个p12文件，可使用下列命令：

 

\# 生成client-certificate-data

grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.crt

\# 生成client-key-data

grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.key

\# 生成p12

openssl pkcs12 -export -clcerts -inkey kubecfg.key -in kubecfg.crt -out kubecfg.p12 -name "kubernetes-client"

\# ll

-rw-rw-r--  1 centos centos   1082 Dec 28 19:41 kubecfg.crt

-rw-rw-r--  1 centos centos   1675 Dec 28 19:41 kubecfg.key

-rw-rw-r--  1 centos centos   2464 Dec 28 19:41 kubecfg.p12

 

最后导入上面生成的p12文件，重新打开浏览器，显示如下：

 

点击确定，便可以看到熟悉的登录界面了：

我们可以使用一开始创建的admin-user用户的token进行登录，一切OK。

https://192.168.92.56:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

 

 

\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

Porxy方式

如果要在本地访问dashboard，可运行如下命令：

 

\# kubectl proxy 

Starting to serve on 127.0.0.1:8001

 

现在就可以通过以下链接来访问Dashborad UI

 

http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

 

这种方式默认情况下，只能从本地访问（启动它的机器）。

我们也可以使用–address和–accept-hosts参数来允许外部访问：

 

\# kubectl proxy --address='0.0.0.0'  --accept-hosts='^*$'

Starting to serve on [::]:8001

 

然后我们在外网访问以下链接：

 

http://<master-ip>:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

 

可以成功访问到登录界面，但是填入token也无法登录，这是因为Dashboard只允许localhost和127.0.0.1使用HTTP连接进行访问，而其它地址只允许使用HTTPS。因此，如果需要在非本机访问Dashboard的话，只能选择其他访问方式。

 

 

 

## KUBERNETES-DASHBOARD.YAML内容

[root@master yaml]# cat kubernetes-dashboard.yaml 

\# Copyright 2017 The Kubernetes Authors.

\#

\# Licensed under the Apache License, Version 2.0 (the "License");

\# you may not use this file except in compliance with the License.

\# You may obtain a copy of the License at

\#

\#   http://www.apache.org/licenses/LICENSE-2.0

\#

\# Unless required by applicable law or agreed to in writing, software

\# distributed under the License is distributed on an "AS IS" BASIS,

\# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

\# See the License for the specific language governing permissions and

\# limitations under the License.

 

\# ------------------- Dashboard Secret ------------------- #

 

apiVersion: v1

kind: Secret

metadata:

 labels:

  k8s-app: kubernetes-dashboard

 name: kubernetes-dashboard-certs

 namespace: kube-system

type: Opaque

 

\---

\# ------------------- Dashboard Service Account ------------------- #

 

apiVersion: v1

kind: ServiceAccount

metadata:

 labels:

  k8s-app: kubernetes-dashboard

 name: kubernetes-dashboard

 namespace: kube-system

 

\---

\# ------------------- Dashboard Role & Role Binding ------------------- #

 

kind: Role

apiVersion: rbac.authorization.k8s.io/v1

metadata:

 name: kubernetes-dashboard-minimal

 namespace: kube-system

rules:

 \# Allow Dashboard to create 'kubernetes-dashboard-key-holder' secret.

\- apiGroups: [""]

 resources: ["secrets"]

 verbs: ["create"]

 \# Allow Dashboard to create 'kubernetes-dashboard-settings' config map.

\- apiGroups: [""]

 resources: ["configmaps"]

 verbs: ["create"]

 \# Allow Dashboard to get, update and delete Dashboard exclusive secrets.

\- apiGroups: [""]

 resources: ["secrets"]

 resourceNames: ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs"]

 verbs: ["get", "update", "delete"]

 \# Allow Dashboard to get and update 'kubernetes-dashboard-settings' config map.

\- apiGroups: [""]

 resources: ["configmaps"]

 resourceNames: ["kubernetes-dashboard-settings"]

 verbs: ["get", "update"]

 \# Allow Dashboard to get metrics from heapster.

\- apiGroups: [""]

 resources: ["services"]

 resourceNames: ["heapster"]

 verbs: ["proxy"]

\- apiGroups: [""]

 resources: ["services/proxy"]

 resourceNames: ["heapster", "http:heapster:", "https:heapster:"]

 verbs: ["get"]

 

\---

apiVersion: rbac.authorization.k8s.io/v1

kind: RoleBinding

metadata:

 name: kubernetes-dashboard-minimal

 namespace: kube-system

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: Role

 name: kubernetes-dashboard-minimal

subjects:

\- kind: ServiceAccount

 name: kubernetes-dashboard

 namespace: kube-system

 

\---

\# ------------------- Dashboard Deployment ------------------- #

 

kind: Deployment

apiVersion: apps/v1

metadata:

 labels:

  k8s-app: kubernetes-dashboard

 name: kubernetes-dashboard

 namespace: kube-system

spec:

 replicas: 1

 revisionHistoryLimit: 10

 selector:

  matchLabels:

   k8s-app: kubernetes-dashboard

 template:

  metadata:

   labels:

​    k8s-app: kubernetes-dashboard

  spec:

   containers:

   \- name: kubernetes-dashboard

​    image: registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.1

​    ports:

​    \- containerPort: 8443

​     protocol: TCP

​    args:

​     \- --auto-generate-certificates

​     \# Uncomment the following line to manually specify Kubernetes API server Host

​     \# If not specified, Dashboard will attempt to auto discover the API server and connect

​     \# to it. Uncomment only if the default does not work.

​     \# - --apiserver-host=http://my-address:port

​    volumeMounts:

​    \- name: kubernetes-dashboard-certs

​     mountPath: /certs

​     \# Create on-disk volume to store exec logs

​    \- mountPath: /tmp

​     name: tmp-volume

​    livenessProbe:

​     httpGet:

​      scheme: HTTPS

​      path: /

​      port: 8443

​     initialDelaySeconds: 30

​     timeoutSeconds: 30

   volumes:

   \- name: kubernetes-dashboard-certs

​    secret:

​     secretName: kubernetes-dashboard-certs

   \- name: tmp-volume

​    emptyDir: {}

   serviceAccountName: kubernetes-dashboard

   \# Comment the following tolerations if Dashboard must not be deployed on master

   tolerations:

   \- key: node-role.kubernetes.io/master

​    effect: NoSchedule

 

\---

\# ------------------- Dashboard Service ------------------- #

 

kind: Service

apiVersion: v1

metadata:

 labels:

  k8s-app: kubernetes-dashboard

 name: kubernetes-dashboard

 namespace: kube-system

spec:

 \# type: NodePort

 type: LoadBalancer

 ports:

  \- port: 443

   targetPort: 8443

  \#  nodePort: 31620

 selector:

  k8s-app: kubernetes-dashboard

 

# 部署KUBE集群DNS服务

 

 

## KUBE-DNS(旧版)

wing已经测

原理 

　　每个Kubernetes service都绑定了一个虚拟IP 地址（ClusterIP），而且Kubernetes最初使用向pod中注入环境变量的方式实现服务发现，但这会带来环境变量泛滥等问题。故需要增加集群DNS服务为每个service映射一个域名。到Kubernetes  v1.2版本时，DNS作为一个系统可选插件集成到Kubernetes集群中。Kubernetes默认使用SkyDNS 作为集群的DNS服务器，

　　kubernetes可以为pod提供dns（skyDNS）内部域名解析服务。其主要作用是为pod提供可以直接通过service的名字解析为对应service的ip的功能。启用了集群DNS选项，需要创建一个运行SkyDNS域名服务器的pod和一个对外提供集群service域名解析服务的SkyDNS  service，并且还会为该service绑定一个稳定的静态IP地址作为入口IP地址。然后，Kubelet被配置成向每个Docker容器传人SkyDNS  service的IP地址。作为它们其中一个DNS服务器。每个在Kubernetes集群中定义的service包括DNS服务器本身对应的service都会被映射到一个DNS域名，该域名一般由两个部分组成：service所在namespace和service名。默认情况下，一个客户端pod的DNS搜索列表一般包含pod自身的namespace和集群的默认域名集。SkyDNS service的域名搜索顺序大致如下。大型网站高并发解决方案LVS

 

　　　　搜索客户端pod所在namespace中所有的service域名记录；

　　　　搜索目标域名namespace中所有的service域名记录；

　　　　从当前Kubernetes集群中，搜索所有的service域名记录。

　　skyDNS由三部分组成：kube2sky、etcd、skydns。

　　　　kube2sky的功能是监测api-server中的service的变化，当service创建、删除、修改时，获取对应的service信息，将其保存在etcd的中；

　　　　Etcd的功能是存储kube2sky保存过来的数据；

　　　　Skydns。在kubelet创建pod时，会使用为kubelet配置的"KUBELET_ARGS="--cluster-dns=10.254.10.2  --cluster-domain=sky --allow-privileged=true""  在创建的pod中从而使用对应的dns服务器。而这一dns解析服务，实际是由Skydns提供的。

 

上面是Kubernetes1.2的，有点原始。

下面主要讲解Kubernetes1.4版本中的DNS插件的安装。与1.2版本相比，1.4中的DNS增加了解析Pod（HostName）对应的域名的新功能，且在部署上也有了一些变化。1.2中，需要部署etcd（或使用master上的Etcd）、kube2sky、skydns三个组件；1.4中，DNS组件由kubedns（监控Kubernetes中DNS服务）和一个健康检查容器——healthz组成。

　　在搭建PetSet（宠物应用）时，系统首先要为PetSet设置一个HeadLess  service，即service的ClusterIP显示的设置成none，而对每一个有特定名称的Pet（Named  Pod），可以通过其HostName进行寻址访service变化）、dnsmasq（DNS服务）和一个健康检查容器——healthz组成。

　　在搭建PetSet（宠物应用）时，系统首先要为PetSet设置一个HeadLess  service，即service的ClusterIP显示的设置成none，而对每一个有特定名称的Pet（Named  Pod），可以通过其HostName进行寻址访问。这就用到了1.4中的新功能。以下给出具体的搭建过程。

 

2、修改配置

2.1修改各个node上的kubelet

　　修改以下红色部分，完成后重启kubelet服务。

[root@k8s-node-1 /]# cat /etc/kubernetes/kubelet

\###

\# kubernetes kubelet (minion) config

 

\# The address for the info server to serve on (set to 0.0.0.0 or "" for all interfaces)

KUBELET_ADDRESS="--address=0.0.0.0"

 

\# The port for the info server to serve on

\# KUBELET_PORT="--port=10250"

 

\# You may leave this blank to use the actual hostname

KUBELET_HOSTNAME="--hostname-override=k8s-node-1"

 

\# location of the api-server

KUBELET_API_SERVER="--api-servers=http://k8s-master:8080"

 

\# pod infrastructure container

KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=docker.io/tianyebj/pod-infrastructure:latest"

 

\# Add your own!

KUBELET_ARGS="--cluster-dns=10.254.10.2 --cluster-domain=cluster.local. --allow-privileged=true"

 

[root@k8s-node-1 ~]# systemctl restart kubelet.service

 

2.2修改APIserver

修改以下红色部分：

[root@k8s-master /]# cat /etc/kubernetes/apiserver

\###

\# kubernetes system config

\#

\# The following values are used to configure the kube-apiserver

\#

 

\# The address on the local server to listen to.

KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"

 

\# The port on the local server to listen on.

\# KUBE_API_PORT="--port=8080"

KUBE_API_PORT="--port=8080"

 

\# Port minions listen on

\# KUBELET_PORT="--kubelet-port=10250"

 

\# Comma separated list of nodes in the etcd cluster

KUBE_ETCD_SERVERS="--etcd-servers=http://etcd:2379"

 

\# Address range to use for services

KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"

 

\# default admission control policies

KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota"

 

\# Add your own!

KUBE_API_ARGS=""

 

2.3 修改yaml文件

注意修改以下红色部分：

[root@k8s-master /]# cat kube-dns-rc_14.yaml 

apiVersion: v1

kind: ReplicationController

metadata:

 name: kube-dns-v20

 namespace: kube-system

 labels:

  k8s-app: kube-dns

  version: v20

  kubernetes.io/cluster-service: "true"

spec:

 replicas: 1

 selector:

  k8s-app: kube-dns

  version: v20

 template:

  metadata:

   labels:

​    k8s-app: kube-dns

​    version: v20

   annotations:

​    scheduler.alpha.kubernetes.io/critical-pod: ''

​    scheduler.alpha.kubernetes.io/tolerations: '[{"key":"CriticalAddonsOnly", "operator":"Exists"}]'

  spec:

   containers:

   \- name: kubedns

​    image: docker.io/ist0ne/kubedns-amd64:latest

​    imagePullPolicy: IfNotPresent

​    resources:

​     \# TODO: Set memory limits when we've profiled the container for large

​     \# clusters, then set request = limit to keep this container in

​     \# guaranteed class. Currently, this container falls into the

​     \# "burstable" category so the kubelet doesn't backoff from restarting it.

​     limits:

​      memory: 170Mi

​     requests:

​      cpu: 100m

​      memory: 70Mi

​    livenessProbe:

​     httpGet:

​      path: /healthz-kubedns

​      port: 8080

​      scheme: HTTP

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     successThreshold: 1

​     failureThreshold: 5

​    readinessProbe:

​     httpGet:

​      path: /readiness

​      port: 8081

​      scheme: HTTP

​     \# we poll on pod startup for the Kubernetes master service and

​     \# only setup the /readiness HTTP server once that's available.

​     initialDelaySeconds: 3

​     timeoutSeconds: 5

​    args:

​    \# command = "/kube-dns"

​    \- --domain=cluster.local. 

​    \- --dns-port=10053

​    \- --kube-master-url=http://192.168.245.250:8080

​    ports:

​    \- containerPort: 10053

​     name: dns-local

​     protocol: UDP

​    \- containerPort: 10053

​     name: dns-tcp-local

​     protocol: TCP

   \- name: dnsmasq

​    image: docker.io/mritd/kube-dnsmasq-amd64:latest

​    imagePullPolicy: IfNotPresent

​    livenessProbe:

​     httpGet:

​      path: /healthz-dnsmasq

​      port: 8080

​      scheme: HTTP

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     successThreshold: 1

​     failureThreshold: 5

​    args:

​    \- --cache-size=1000

​    \- --no-resolv

​    \- --server=127.0.0.1#10053

​    \- --log-facility=-

​    ports:

​    \- containerPort: 53

​     name: dns

​     protocol: UDP

​    \- containerPort: 53

​     name: dns-tcp

​     protocol: TCP

   \- name: healthz

​    image: docker.io/ist0ne/exechealthz-amd64:latest

​    imagePullPolicy: IfNotPresent

​    resources:

​     limits:

​      memory: 50Mi

​     requests:

​      cpu: 10m

​      \# Note that this container shouldn't really need 50Mi of memory. The

​      \# limits are set higher than expected pending investigation on #29688.

​      \# The extra memory was stolen from the kubedns container to keep the

​      \# net memory requested by the pod constant.

​      memory: 50Mi

​    args:

​    \- --cmd=nslookup kubernetes.default.svc.cluster.local. 127.0.0.1 >/dev/null

​    \- --url=/healthz-dnsmasq

​    \- --cmd=nslookup kubernetes.default.svc.cluster.local. 127.0.0.1:10053 >/dev/null

​    \- --url=/healthz-kubedns

​    \- --port=8080

​    \- --quiet

​    ports:

​    \- containerPort: 8080

​     protocol: TCP

   dnsPolicy: Default  # Don't use cluster DNS.

 

[root@k8s-master dns14]# cat kube-dns-svc_14.yaml 

apiVersion: v1

kind: Service

metadata:

 name: kube-dns

 namespace: kube-system

 labels:

  k8s-app: kube-dns

  kubernetes.io/cluster-service: "true"

  kubernetes.io/name: "KubeDNS"

spec:

 selector:

  k8s-app: kube-dns

 clusterIP: 10.254.10.2

 ports:

 \- name: dns

  port: 53

  protocol: UDP

 \- name: dns-tcp

  port: 53

  protocol: TCP

 

2.4 下载下面3个镜像

docker.io/ist0ne/kubedns-amd64:latest 

docker.io/mritd/kube-dnsmasq-amd64:latest

docker.io/ist0ne/exechealthz-amd64:latest 

还是没有国内源，需要先在国外服务器上下载然后打包拷贝到本地，再导入

 

3、启动

[root@k8s-master dns14]# kubectl create -f kube-dns-rc_14.yaml 

replicationcontroller "kube-dns-v20" created

[root@k8s-master dns14]# kubectl create -f kube-dns-svc_14.yaml 

service "kube-dns" created

 

4、查看

[root@k8s-master /]# kubectl get pod  -o wide  --all-namespaces

NAMESPACE   NAME                      READY   STATUS   RESTARTS  AGE    IP      NODE

kube-system  kube-dns-v20-gbd1m               3/3    Running  0      19m    10.0.27.3  k8s-node-2

kube-system  kubernetes-dashboard-latest-1231782504-t79t7  1/1    Running  0      6h     10.0.27.2  k8s-node-2

 

使用：例子在使用yam创建rc->java web应用那一小节

创建web容器-->通过kubectl exec -it Podip /bin/bash进入容器-->cat /etc/resolve.conf-->发现已经指定好DNS服务器IP，接下来可以直接使用其他pod的name了，比如：

root@myweb-76h6w:/usr/local/tomcat# curl myweb:8080

<!DOCTYPE html>

<html lang="en">

  <head>

        <meta charset="UTF-8" />
​    <title>Apache Tomcat/8.0.35</title>

​    <link href="favicon.ico" rel="icon" type="image/x-icon" />

​    <link href="favicon.ico" rel="shortcut icon" type="image/x-icon" />

​    <link href="tomcat.css" rel="stylesheet" type="text/css" />

  </head>

 

 

## COREDNS(新版)

> 注：
>
>   本文是二进制方式的dns配置，kubeadm方式的CoreDNS默认是部署好的，直接使用即可
>

CoreDNS

CoreDNS在Kubernetes1.11版本已经做为GA功能释放，成为Kubernetes默认的DNS服务替代了Kube-DNS，目前是kubeadm、kube-up、minikube和kops安装工具的默认选项。

 

配置文件

使用kubeadm安装CoreDNS，会使用ConfigMap做为配置文件。这份配置文件，会默认使用宿主机的DNS服务器地址。

 

\# kubectl -n kube-system get configmap coredns -o yaml

apiVersion: v1

data:

 Corefile: |

  .:53 {

​    errors

​    health

​    kubernetes cluster.local in-addr.arpa ip6.arpa {

​      pods insecure

​      upstream

​      fallthrough in-addr.arpa ip6.arpa

​    }

​    prometheus :9153

​    proxy . /etc/resolv.conf

​    cache 30

​    reload

  }

kind: ConfigMap

metadata:

 creationTimestamp: 2018-08-20T07:01:55Z

 name: coredns

 namespace: kube-system

 resourceVersion: "193"

 selfLink: /api/v1/namespaces/kube-system/configmaps/coredns

 uid: ec72baa4-a446-11e8-ac92-080027b7c4e9

 

配置文件各项目的含义

errors      错误会被记录到标准输出

health      可以通过http://localhost:8080/health查看健康状况

kubernetes  根据服务的IP响应DNS查询请求，kubeadm的Cluster Domain和Service CIDR默认为cluster.local和10.95.0.0/12，可以通过--service-dns-domain和--service-cidr参数配置。

 

prometheus  可以通过http://localhost:9153/metrics获取prometheus格式的监控数据

proxy      本地无法解析后，向上级地址进行查询，默认使用宿主机的 /etc/resolv.conf 配置

cache      缓存时间

 

检查CoreDNS运行状况

检查Pod状态

\# kubectl -n kube-system get pods -o wide

NAME                 READY   STATUS   RESTARTS  AGE    IP        NODE

coredns-78fcdf6894-52gp9       1/1    Running  4      4h     172.16.0.11   devops-101

coredns-78fcdf6894-mkvqn       1/1    Running  4      4h     172.16.0.10   devops-101

etcd-devops-101            1/1    Running  4      3h     192.168.0.101  devops-101

 

检查部署

\# kubectl -n kube-system get deployments

NAME    DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE

coredns  2     2     2       2      4h

 

验证：

不能用busybox测试dns:busybox中的nslookup命令应该是实现的不是很完全，导致我在测试DNS的成功，得到了错误的信息。

 

这里使用带nslookup的其他镜像

\# kubectl run dig --rm -it --image=docker.io/azukiapp/dig /bin/sh

If you don't see a command prompt, try pressing enter.

/ # dig @172.17.0.10 kubernetes.default.svc.cluster.local +noall +answer

 

; <<>> DiG 9.10.3-P3 <<>> @172.17.0.10 kubernetes.default.svc.cluster.local +noall +answer

; (1 server found)

;; global options: +cmd

kubernetes.default.svc.cluster.local. 5 IN A   172.17.0.1

/ # nslookup kubernetes.default

Server:   172.17.0.10

Address:   172.17.0.10#53

 

Name:  kubernetes.default.svc.cluster.local

Address: 172.17.0.1

 

/ # nslookup www.baidu.com

Server:   172.17.0.10

Address:   172.17.0.10#53

 

Non-authoritative answer:

www.baidu.com  canonical name = www.a.shifen.com.

Name:  www.a.shifen.com

Address: 220.181.112.244

Name:  www.a.shifen.com

Address: 220.181.111.188

 

/ # nslookup kubernetes.default

Server:   172.17.0.10

Address:   172.17.0.10#53

 

Name:  kubernetes.default.svc.cluster.local

Address: 172.17.0.1

 

 

# K8S集群日志管理

 

# 部署JENKINS到K8S集群

wing测试成功

 

## 配置持久存储

wing测试成功

 

nfs安装 

我这里是用NODE1提供NFS服务，生产环境要独立

 

\# yum -y install nfs-utils rpcbind

 

这里是做多个NFS目录用于挂载，因为一个PVC取消一个PV的绑定之后，原来的PV还是不能被其他PVC使用的

\# mkdir /data/{nfs1,nfs2,nfs3,nfs4,nfs5,nfs6,nfs7,nfs8,nfs9,nfs10} -pv && chmod 777 /data/nfs*

 

\# vim /etc/exports

/data/nfs1 */24(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash) 

/data/nfs2 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash) 

/data/nfs3 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash) 

/data/nfs4 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash) 

/data/nfs5 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

/data/nfs6 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

/data/nfs7 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

/data/nfs8 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

/data/nfs9 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

/data/nfs10 *(rw,async,insecure,anonuid=1000,anongid=1000,no_root_squash)

 

\# exportfs -rv

\# systemctl enable rpcbind nfs-server

\# systemctl start nfs-server rpcbind

\# rpcinfo -p

 

持久卷的运用

可以使用下面的explain子命令去查看学习pv的使用方法，这里不是要大家操作的,这些命令直接回车会看到帮助

\# kubectl explain PersistentVolume

\# kubectl explain PersistentVolume.spec

\# kubectl explain PersistentVolume.spec.accessModes

 

使用YAML文件创建PV和PVC（如果你用的wing的yaml文件，要注意修改里面的内容）

\# cat volume/nfs-pv.yml  //内容在子目录

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv001

 labels:

  name: pv001

spec:

 nfs:

  path: /data/nfs1

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv002

 labels:

  name: pv002

spec:

 nfs:

  path: /data/nfs2

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv003

 labels:

  name: pv003

spec:

 nfs:

  path: /data/nfs3

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv004

 labels:

  name: pv004

spec:

 nfs:

  path: /data/nfs4

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv005

 labels:

  name: pv005

spec:

 nfs:

  path: /data/nfs5

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv006

 labels:

  name: pv006

spec:

 nfs:

  path: /data/nfs6

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv007

 labels:

  name: pv007

spec:

 nfs:

  path: /data/nfs7

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 2Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv008

 labels:

  name: pv008

spec:

 nfs:

  path: /data/nfs8

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv009

 labels:

  name: pv009

spec:

 nfs:

  path: /data/nfs9

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

\---

apiVersion: v1

kind: PersistentVolume

metadata:

 name: pv010

 labels:

  name: pv010

spec:

 nfs:

  path: /data/nfs10

  server: 192.168.1.208

 accessModes: ["ReadWriteMany","ReadWriteOnce"]

 capacity:

  storage: 1Gi

  

[root@master volume]# kubectl apply -f nfs-pv.yml --record

persistentvolume/pv001 created

persistentvolume/pv002 created

persistentvolume/pv003 created

persistentvolume/pv004 created

persistentvolume/pv005 created

persistentvolume/pv006 created

persistentvolume/pv007 created

persistentvolume/pv008 created

persistentvolume/pv009 created

persistentvolume/pv010 created

 

[root@master volume]# kubectl  get pv

NAME   CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS    CLAIM  STORAGECLASS  REASON  AGE

pv001  1Gi     RWO,RWX     Retain      Available                  16s

pv002  1Gi     RWO,RWX     Retain      Available                  16s

pv003  1Gi     RWO,RWX     Retain      Available                  16s

pv004  1Gi     RWO,RWX     Retain      Available                  16s

pv005  1Gi     RWO,RWX     Retain      Available                  16s

pv006  1Gi     RWO,RWX     Retain      Available                  16s

pv007  2Gi     RWO,RWX     Retain      Available                  16s

pv008  1Gi     RWO,RWX     Retain      Available                  16s

pv009  1Gi     RWO,RWX     Retain      Available                  16s

pv010  1Gi     RWO,RWX     Retain      Available                  16s

 

 

\# cat volume/nfs-pvc.yml

apiVersion: v1

kind: PersistentVolumeClaim

metadata:

 name: mypvc

 namespace: default

spec:

 accessModes: ["ReadWriteMany"]

 resources:

  requests:

   storage: 2Gi

 

[root@master volume]# kubectl apply -f nfs-pvc.yml --record

persistentvolumeclaim/mypvc created

[root@master volume]# kubectl  get pvc

NAME   STATUS  VOLUME  CAPACITY  ACCESS MODES  STORAGECLASS  AGE

mypvc  Bound   pv007   2Gi     RWO,RWX            5s

## 部署JENKINS到K8S集群

wing测试成功

部署JENKINS到K8S集群

 

创建nginx-ingress-controller

[root@master /]# cat mandatory.yaml

apiVersion: v1

kind: Namespace

metadata:

 name: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

 

kind: ConfigMap

apiVersion: v1

metadata:

 name: nginx-configuration

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

kind: ConfigMap

apiVersion: v1

metadata:

 name: tcp-services

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

kind: ConfigMap

apiVersion: v1

metadata:

 name: udp-services

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

apiVersion: v1

kind: ServiceAccount

metadata:

 name: nginx-ingress-serviceaccount

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: ClusterRole

metadata:

 name: nginx-ingress-clusterrole

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

rules:

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

   \- endpoints

   \- nodes

   \- pods

   \- secrets

  verbs:

   \- list

   \- watch

 \- apiGroups:

   \- ""

  resources:

   \- nodes

  verbs:

   \- get

 \- apiGroups:

   \- ""

  resources:

   \- services

  verbs:

   \- get

   \- list

   \- watch

 \- apiGroups:

   \- "extensions"

  resources:

   \- ingresses

  verbs:

   \- get

   \- list

   \- watch

 \- apiGroups:

   \- ""

  resources:

   \- events

  verbs:

   \- create

   \- patch

 \- apiGroups:

   \- "extensions"

  resources:

   \- ingresses/status

  verbs:

   \- update

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: Role

metadata:

 name: nginx-ingress-role

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

rules:

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

   \- pods

   \- secrets

   \- namespaces

  verbs:

   \- get

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

  resourceNames:

   \# Defaults to "<election-id>-<ingress-class>"

   \# Here: "<ingress-controller-leader>-<nginx>"

   \# This has to be adapted if you change either parameter

   \# when launching the nginx-ingress-controller.

   \- "ingress-controller-leader-nginx"

  verbs:

   \- get

   \- update

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

  verbs:

   \- create

 \- apiGroups:

   \- ""

  resources:

   \- endpoints

  verbs:

   \- get

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: RoleBinding

metadata:

 name: nginx-ingress-role-nisa-binding

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: Role

 name: nginx-ingress-role

subjects:

 \- kind: ServiceAccount

  name: nginx-ingress-serviceaccount

  namespace: ingress-nginx

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: ClusterRoleBinding

metadata:

 name: nginx-ingress-clusterrole-nisa-binding

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: ClusterRole

 name: nginx-ingress-clusterrole

subjects:

 \- kind: ServiceAccount

  name: nginx-ingress-serviceaccount

  namespace: ingress-nginx

 

\---

 

apiVersion: apps/v1

kind: Deployment

metadata:

 name: nginx-ingress-controller

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

spec:

 replicas: 1

 selector:

  matchLabels:

   app.kubernetes.io/name: ingress-nginx

   app.kubernetes.io/part-of: ingress-nginx

 template:

  metadata:

   labels:

​    app.kubernetes.io/name: ingress-nginx

​    app.kubernetes.io/part-of: ingress-nginx

   annotations:

​    prometheus.io/port: "10254"

​    prometheus.io/scrape: "true"

  spec:

   serviceAccountName: nginx-ingress-serviceaccount

   containers:

​    \- name: nginx-ingress-controller

​     image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1

​     args:

​      \- /nginx-ingress-controller

​      \- --configmap=$(POD_NAMESPACE)/nginx-configuration

​      \- --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services

​      \- --udp-services-configmap=$(POD_NAMESPACE)/udp-services

​      \- --publish-service=$(POD_NAMESPACE)/ingress-nginx

​      \- --annotations-prefix=nginx.ingress.kubernetes.io

​     securityContext:

​      allowPrivilegeEscalation: true

​      capabilities:

​       drop:

​        \- ALL

​       add:

​        \- NET_BIND_SERVICE

​      \# www-data -> 33

​      runAsUser: 33

​     env:

​      \- name: POD_NAME

​       valueFrom:

​        fieldRef:

​         fieldPath: metadata.name

​      \- name: POD_NAMESPACE

​       valueFrom:

​        fieldRef:

​         fieldPath: metadata.namespace

​     ports:

​      \- name: http

​       containerPort: 80

​      \- name: https

​       containerPort: 443

​     livenessProbe:

​      failureThreshold: 3

​      httpGet:

​       path: /healthz

​       port: 10254

​       scheme: HTTP

​      initialDelaySeconds: 10

​      periodSeconds: 10

​      successThreshold: 1

​      timeoutSeconds: 10

​     readinessProbe:

​      failureThreshold: 3

​      httpGet:

​       path: /healthz

​       port: 10254

​       scheme: HTTP

​      periodSeconds: 10

​      successThreshold: 1

​      timeoutSeconds: 10

 

\---

 

[root@master /]# kubectl  apply -f mandatory.yaml 

 

\# kubectl get pods -n ingress-nginx -o wide

NAME                     READY  STATUS   RESTARTS  AGE  IP       NODE   NOMINATED NODE  READINESS GATES

nginx-ingress-controller-689498bc7c-xmf8j  1/1   Running  0      9s   10.244.2.226  node2  <none>      <none>

 

部署jenkins的yaml文件：

\# vim jenkins.yml

apiVersion: v1

kind: Namespace

metadata:

 name: jenkins

 

\---

 

apiVersion: v1

kind: Service

metadata:

 name: jenkins

 namespace: jenkins

spec:

 selector:

  app: jenkins

 ports:

 \- name: http

  port: 80

  targetPort: 8080

  protocol: TCP

 \- name: agent

  port: 50000

  protocol: TCP

 

\---

 

apiVersion: extensions/v1beta1

kind: Ingress

metadata:

 name: jenkins

 namespace: jenkins

 annotations:

  kubernetes.io/ingress.class: "nginx"

  ingress.kubernetes.io/ssl-redirect: "false"

  ingress.kubernetes.io/proxy-body-size: 50m

  ingress.kubernetes.io/proxy-request-buffering: "off"

  nginx.ingress.kubernetes.io/ssl-redirect: "false"

  nginx.ingress.kubernetes.io/proxy-body-size: 50m

  nginx.ingress.kubernetes.io/proxy-request-buffering: "off"

spec:

 rules:

 \- http:

   paths:

   \- path: /jenkins

​    backend:

​     serviceName: jenkins

​     servicePort: 80

 

\---

 

apiVersion: apps/v1beta2

kind: StatefulSet

metadata:

 name: jenkins

 namespace: jenkins

spec:

 selector:

  matchLabels:

   app: jenkins

 serviceName: jenkins

 replicas: 1

 updateStrategy:

  type: RollingUpdate

 template:

  metadata:

   labels:

​    app: jenkins

  spec:

   terminationGracePeriodSeconds: 10

   containers:

   \- name: jenkins

​    image: jenkins/jenkins:lts-alpine

​    imagePullPolicy: Always

​    ports:

​    \- containerPort: 8080

​    \- containerPort: 50000

​    resources:

​     limits:

​      cpu: 1

​      memory: 1Gi

​     requests:

​      cpu: 0.5

​      memory: 500Mi

​    env:

​    \- name: JENKINS_OPTS

​     value: --prefix=/jenkins

​    \- name: LIMITS_MEMORY

​     valueFrom:

​      resourceFieldRef:

​       resource: limits.memory

​       divisor: 1Mi

​    \- name: JAVA_OPTS

​     value: -Xmx$(LIMITS_MEMORY)m -XshowSettings:vm -Dhudson.slaves.NodeProvisioner.initialDelay=0 -Dhudson.slaves.NodeProvisioner.MARGIN=50 -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85

​    volumeMounts:

​    \- name: jenkins-home

​     mountPath: /var/jenkins_home

​    livenessProbe:

​     httpGet:

​      path: /jenkins/login

​      port: 8080

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     failureThreshold: 12 # ~2 minutes

​    readinessProbe:

​     httpGet:

​      path: /jenkins/login

​      port: 8080

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     failureThreshold: 12 # ~2 minutes

   securityContext:

​    fsGroup: 1000

 volumeClaimTemplates:

 \- metadata:

   name: jenkins-home

  spec:

   accessModes: [ "ReadWriteOnce" ]

   resources:

​    requests:

​     storage: 2Gi

 

\# kubectl apply -f jenkins.yml --record

namespace/jenkins created

service/jenkins created

ingress.extensions/jenkins created

statefulset.apps/jenkins created

 

\# kubectl get pods -n jenkins 

NAME     READY  STATUS   RESTARTS  AGE

jenkins-0  0/1   Running  0      28s

 

等一下再次查看：

\# kubectl get pods -n jenkins

NAME     READY  STATUS   RESTARTS  AGE

jenkins-0  1/1   Running  0      7m55s

 

\# kubectl get pvc -n jenkins

NAME           STATUS  VOLUME  CAPACITY  ACCESS MODES  STORAGECLASS  AGE

jenkins-home-jenkins-0  Bound   pv007   2Gi     RWO,RWX            50s

 

\# kubectl get ingress -n jenkins

NAME    HOSTS  ADDRESS  PORTS  AGE

jenkins  *         80    84s

 

 

 

[root@master /]# cat service-nodeport.yaml 

apiVersion: v1

kind: Service

metadata:

 name: ingress-nginx

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

spec:

 type: NodePort

 ports:

  \- name: http

   port: 80

   targetPort: 80

   nodePort: 30080

   protocol: TCP

  \- name: https

   port: 443

   targetPort: 443

   nodePort: 30043

   protocol: TCP

 selector:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

 

\# kubectl  apply -f service-nodeport.yaml

service/ingress-nginx created

 

\# kubectl  get svc -n ingress-nginx

NAME       TYPE    CLUSTER-IP    EXTERNAL-IP  PORT(S)            AGE

ingress-nginx  NodePort  10.111.117.150  <none>     80:30080/TCP,443:30043/TCP  40s

 

\# curl http://Node:Port/jenkins

 

\# kubectl get pods -n ingress-nginx -o wide

NAME                     READY  STATUS   RESTARTS  AGE   IP       NODE   NOMINATED NODE  READINESS GATES

nginx-ingress-controller-689498bc7c-xmf8j  1/1   Running  0      7m34s  10.244.2.226  node2  <none>      <none>

 

浏览器访问jenkins:http://node1:30080/jenkins

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsZR87Tr.jpg) 

 

查询管理员密码：

[root@master /]# kubectl get pods -n jenkins

NAME     READY  STATUS   RESTARTS  AGE

jenkins-0  1/1   Running  0      131m

 

[root@master /]# kubectl  exec -it jenkins-0 cat /var/jenkins_home/secrets/initialAdminPassword -n jenkins

82841678e8f845edbdf45c579cf9eb55

 

输入查询出来的管理员密码到JENKINS界面上：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps0fUUwP.jpg) 

 

选择安装推荐的插件

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsmwhJ9c.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsHBczMA.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpssE5qpY.jpg) 

 

 

到此部署JENKINS到K8S完成，但是没有添加RBAC权限，下一步配置JENKINS支持K8S中完成

 

 

 

 

## 配置JENKINS支持K8S

wing测试成功

 

配置 Jenkins kubernetes 插件 

添加 BlueOcean 插件

添加 Kubernetes 插件，单击测试，应该会报:禁止类的错误

 

系统管理-->系统设置:

在最后新增一个云

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsLNvl2l.jpg) 

选择：Kubernetes

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps6QxhFJ.jpg) 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsjwQei7.jpg) 

查询Kubernetes地址

[root@master stateful]# kubectl cluster-info

Kubernetes master is running at https://192.168.1.200:6443

KubeDNS is running at https://192.168.1.205:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

 

为 jenkins 插件 kubernetes 配置 ServiceAccounts

 

\# cat serviceaccount/jenkins.yml //见下图解释，在原来stateful/jenkins.yml的基础上加了sa和rbac

apiVersion: v1

kind: Namespace

metadata:

 name: jenkins

 

\---

 

apiVersion: v1

kind: Namespace

metadata:

 name: build

 

\---

 

apiVersion: v1

kind: ServiceAccount

metadata:

 name: jenkins

 namespace: jenkins

 

\---

 

kind: Role

apiVersion: rbac.authorization.k8s.io/v1beta1

metadata:

 name: jenkins

 namespace: build

rules:

\- apiGroups: [""]

 resources: ["pods", "pods/exec", "pods/log"]

 verbs: ["*"]

\- apiGroups: [""]

 resources: ["secrets"]

 verbs: ["get"]

 

\---

 

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: RoleBinding

metadata:

 name: jenkins

 namespace: build

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: Role

 name: jenkins

subjects:

\- kind: ServiceAccount

 name: jenkins

 namespace: jenkins

 

\---

 

apiVersion: v1

kind: Service

metadata:

 name: jenkins

 namespace: jenkins

spec:

 selector:

  app: jenkins

 ports:

 \- name: http

  port: 80

  targetPort: 8080

  protocol: TCP

 \- name: agent

  port: 50000

  protocol: TCP

 

\---

 

apiVersion: extensions/v1beta1

kind: Ingress

metadata:

 name: jenkins

 namespace: jenkins

 annotations:

  kubernetes.io/ingress.class: "nginx"

  ingress.kubernetes.io/ssl-redirect: "false"

  ingress.kubernetes.io/proxy-body-size: 50m

  ingress.kubernetes.io/proxy-request-buffering: "off"

  nginx.ingress.kubernetes.io/ssl-redirect: "false"

  nginx.ingress.kubernetes.io/proxy-body-size: 50m

  nginx.ingress.kubernetes.io/proxy-request-buffering: "off"

spec:

 rules:

 \- http:

   paths:

   \- path: /jenkins

​    backend:

​     serviceName: jenkins

​     servicePort: 80

 

\---

 

apiVersion: apps/v1beta2

kind: StatefulSet

metadata:

 name: jenkins

 namespace: jenkins

spec:

 selector:

  matchLabels:

   app: jenkins

 serviceName: jenkins

 replicas: 1

 updateStrategy:

  type: RollingUpdate

 template:

  metadata:

   labels:

​    app: jenkins

  spec:

   terminationGracePeriodSeconds: 10

   serviceAccountName: jenkins

   containers:

   \- name: jenkins

​    image: jenkins/jenkins:lts-alpine

​    imagePullPolicy: Always

​    ports:

​    \- containerPort: 8080

​    \- containerPort: 50000

​    resources:

​     limits:

​      cpu: 1

​      memory: 1Gi

​     requests:

​      cpu: 0.5

​      memory: 500Mi

​    env:

​    \- name: JENKINS_OPTS

​     value: --prefix=/jenkins

​    \- name: LIMITS_MEMORY

​     valueFrom:

​      resourceFieldRef:

​       resource: limits.memory

​       divisor: 1Mi

​    \- name: JAVA_OPTS

​     value: -Xmx$(LIMITS_MEMORY)m -XshowSettings:vm -Dhudson.slaves.NodeProvisioner.initialDelay=0 -Dhudson.slaves.NodeProvisioner.MARGIN=50 -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85

​    volumeMounts:

​    \- name: jenkins-home

​     mountPath: /var/jenkins_home

​    livenessProbe:

​     httpGet:

​      path: /jenkins/login

​      port: 8080

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     failureThreshold: 12 # ~2 minutes

​    readinessProbe:

​     httpGet:

​      path: /jenkins/login

​      port: 8080

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     failureThreshold: 12 # ~2 minutes

   securityContext:

​    fsGroup: 1000

 volumeClaimTemplates:

 \- metadata:

   name: jenkins-home

  spec:

   accessModes: [ "ReadWriteOnce" ]

   resources:

​    requests:

​     storage: 2Gi

 

创建了第二个命名空间 build 和 jenkins命名空间中的ServiceAccount jenkins。

创建了一个 角色和提供构建中所需权限的角色绑定 build 名称空间。

将角色绑定到jenkins命名空间中的 ServiceAccount。

因此，Jenkins应该能够在构建中创建豆荚，但是它不能在自己的命名空间Jenkins中做任何事情。这样就可以相对安全地保证构建中的问题不会影响Jenkins。如果我们为这两个名称空间指定了resourcequota和 LimitRanges，那么解决方案将更加可靠。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsaNAqVu.jpg) 

 

\# kubectl apply -f serviceaccount/jenkins.yml --record 

namespace/jenkins unchanged

namespace/build created

serviceaccount/jenkins created

role.rbac.authorization.k8s.io/jenkins created

rolebinding.rbac.authorization.k8s.io/jenkins created

service/jenkins unchanged

ingress.extensions/jenkins unchanged

statefulset.apps/jenkins configured

 

\# kubectl -n jenkins rollout status sts jenkins

Waiting for 1 pods to be ready...

statefulset rolling update complete 1 pods at revision jenkins-5d6c46d5d...

 

注：

  sts是statefuset的简写

 

浏览器打开：http://node2:30080/jenkins

 

获取密码

因为需要重新登陆，我之前没有记住密码

\# kubectl -n jenkins exec jenkins-0 -it -- cat /var/jenkins_home/secrets/initialAdminPassword

 

继续前面的添加云的操作：

  这次填写命名空间并点击连接测试

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsewWFyS.jpg) 

 

 

填写JNLP地址：

当我们创建一个使用Kubernetes Pods的作业时，将添加一个额外的容器。该容器将使用JNLP与 jenkins master通信。

需要指定一个有效的地址JNLP可以用来连接到主机。因为pod将在build命名空间中，而主pod是 jenkins ,因此需要使用更长的DNS名称，它指定服务的名称(jenkins)和名称空间(jenkins)。最重要的是，主配置为使用根路径 /jenkins 响应请求。

总之，完整的地址豆荚可以用来与Jenkins master通信，它应该是 http://[SERVICE_NAME].[NAMESPACE]/[PATH] 。

因为这三个元素都是 jenkins，所以"真实"地址是 http://jenkins.jenkins/jenkins 。

请在Jenkins URL字段中键入它并单击Save按钮。

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpscmRXbg.jpg)

 

到此配置完成

 

 

=======================

## 项目部署

方案：（wing未测试，这是一个想法）

下面这个项目可以以案例的形式用jenkins部署到k8s集群里面

阿波罗  一个应用 （是作配置中心用）  

 

\1. 修改Pom.xml

​      <artifactId>docker-maven-plugin</artifactId>

​        <version>1.2.0</version>

​        <configuration>

​          <imageName>私有库/${env}-${project.name}:${project.version}</imageName>

​          <baseImage>${image.url}/alpine-jdk8:latest</baseImage>

​          <workdir>/tmp</workdir>

​          <entryPoint>["java", "-jar", "/opt/${project.build.finalName}.jar"]</entryPoint>

​          <forceTags>true</forceTags>

​          <imageTags>

​            <imageTag>${project.version}</imageTag>

​            <imageTag>latest</imageTag>

​          </imageTags>

​          <!-- copy the service's jar file from target into the root directory of the image -->

​          <serverId>docker-lab</serverId>

​          <registryUrl>${image.url}/${project.name}</registryUrl>

​          <resources>

​            <resource>

​              <targetPath>/opt</targetPath>

​              <directory>${project.build.directory}</directory>

​              <include>${project.build.finalName}.jar</include>

​            </resource>

​          </resources>

​        </configuration>

​      </plugin>

​      

\2. 用maven测试，测试好之后       

​      

 

\3. 创建流水线项目：

 

stage('pulling') {

​        git branch: '${Branch}', credentialsId: '1（拉取代码凭据编号）', url: 'http://gitlabxxxxxxx/ons-dubbo.git'

​        print "${splitvalue}"

​      }

  

​      stage('compiling') {

​        sh "cd ${sub_path} && mvn clean package -P'${Branch}' -DskipTests docker:build -DpushImageTag -DdockerImageTags=${img_version}"

​        sh "docker rmi -f `docker images '${image_name}':0.0.2-SNAPSHOT -q`"

​        print "${splitvalue}"

​      }

  

​      stage('publishing') {

​        sh "ansible '${dest_server}' --private-key='${private_key}' -m shell -a 'kubectl set image --record deployment/${deploy_name} ${container_name}=${image_name}:${img_version}'"

​        sh "ansible '${dest_server}' --private-key='${private_key}' -m shell -a 'kubectl rollout status deployment/${deploy_name}'"

​        print "${splitvalue}"

​        sh "ansible '${dest_server}' --private-key='${private_key}' -m shell -a 'kubectl rollout history deployment/${deploy_name} | tail -6'"

​        print "${splitvalue}"

​      }

# CI/CD+K8S项目部署实战

前提：部署KUBEADM方式的K8S集群

## 部署JENKINS到K8S集群

wing 测试成功！

 

部署JENKINS到K8S集群

 

\# cd edu-kubernetes  //这目录是wing已经准备好的自己的源码目录

\# cat stateful/jenkins.yml  //内容在子目录也有

apiVersion: v1

kind: Namespace

metadata:

 name: jenkins

 

\---

 

apiVersion: v1

kind: Service

metadata:

 name: jenkins

 namespace: jenkins

spec:

 selector:

  app: jenkins

 ports:

 \- name: http

  port: 80

  targetPort: 8080

  protocol: TCP

 \- name: agent

  port: 50000

  protocol: TCP

 

\---

 

apiVersion: extensions/v1beta1

kind: Ingress

metadata:

 name: jenkins

 namespace: jenkins

 annotations:

  kubernetes.io/ingress.class: "nginx"

  ingress.kubernetes.io/ssl-redirect: "false"

  ingress.kubernetes.io/proxy-body-size: 50m

  ingress.kubernetes.io/proxy-request-buffering: "off"

  nginx.ingress.kubernetes.io/ssl-redirect: "false"

  nginx.ingress.kubernetes.io/proxy-body-size: 50m

  nginx.ingress.kubernetes.io/proxy-request-buffering: "off"

spec:

 rules:

 \- http:

   paths:

   \- path: /jenkins

​    backend:

​     serviceName: jenkins

​     servicePort: 80

 

\---

 

apiVersion: apps/v1beta2

kind: StatefulSet

metadata:

 name: jenkins

 namespace: jenkins

spec:

 selector:

  matchLabels:

   app: jenkins

 serviceName: jenkins

 replicas: 1

 updateStrategy:

  type: RollingUpdate

 template:

  metadata:

   labels:

​    app: jenkins

  spec:

   terminationGracePeriodSeconds: 10

   containers:

   \- name: jenkins

​    image: jenkins/jenkins:lts-alpine

​    imagePullPolicy: Always

​    ports:

​    \- containerPort: 8080

​    \- containerPort: 50000

​    resources:

​     limits:

​      cpu: 1

​      memory: 1Gi

​     requests:

​      cpu: 0.5

​      memory: 500Mi

​    env:

​    \- name: JENKINS_OPTS

​     value: --prefix=/jenkins

​    \- name: LIMITS_MEMORY

​     valueFrom:

​      resourceFieldRef:

​       resource: limits.memory

​       divisor: 1Mi

​    \- name: JAVA_OPTS

​     value: -Xmx$(LIMITS_MEMORY)m -XshowSettings:vm -Dhudson.slaves.NodeProvisioner.initialDelay=0 -Dhudson.slaves.NodeProvisioner.MARGIN=50 -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85

​    volumeMounts:

​    \- name: jenkins-home

​     mountPath: /var/jenkins_home

​    livenessProbe:

​     httpGet:

​      path: /jenkins/login

​      port: 8080

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     failureThreshold: 12 # ~2 minutes

​    readinessProbe:

​     httpGet:

​      path: /jenkins/login

​      port: 8080

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     failureThreshold: 12 # ~2 minutes

   securityContext:

​    fsGroup: 1000

 volumeClaimTemplates:

 \- metadata:

   name: jenkins-home

  spec:

   accessModes: [ "ReadWriteOnce" ]

   resources:

​    requests:

​     storage: 2Gi

 

\# kubectl apply -f jenkins.yml --record

namespace/jenkins created

service/jenkins created

ingress.extensions/jenkins created

statefulset.apps/jenkins created

 

\# kubectl get pods -n jenkins 

NAME     READY  STATUS   RESTARTS  AGE

jenkins-0  0/1   Running  0      28s

 

等一下再次查看：

\# kubectl get pods -n jenkins

NAME     READY  STATUS   RESTARTS  AGE

jenkins-0  1/1   Running  0      7m55s

 

\# kubectl get pvc -n jenkins

NAME           STATUS  VOLUME  CAPACITY  ACCESS MODES  STORAGECLASS  AGE

jenkins-home-jenkins-0  Bound   pv007   2Gi     RWO,RWX            50s

 

\# kubectl get ingress -n jenkins

NAME    HOSTS  ADDRESS  PORTS  AGE

jenkins  *         80    84s

 

创建nginx-ingress-controller

[root@master /]# cat mandatory.yaml  //在笔记子目录也有

apiVersion: v1

kind: Namespace

metadata:

 name: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

 

kind: ConfigMap

apiVersion: v1

metadata:

 name: nginx-configuration

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

kind: ConfigMap

apiVersion: v1

metadata:

 name: tcp-services

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

kind: ConfigMap

apiVersion: v1

metadata:

 name: udp-services

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

apiVersion: v1

kind: ServiceAccount

metadata:

 name: nginx-ingress-serviceaccount

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: ClusterRole

metadata:

 name: nginx-ingress-clusterrole

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

rules:

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

   \- endpoints

   \- nodes

   \- pods

   \- secrets

  verbs:

   \- list

   \- watch

 \- apiGroups:

   \- ""

  resources:

   \- nodes

  verbs:

   \- get

 \- apiGroups:

   \- ""

  resources:

   \- services

  verbs:

   \- get

   \- list

   \- watch

 \- apiGroups:

   \- "extensions"

  resources:

   \- ingresses

  verbs:

   \- get

   \- list

   \- watch

 \- apiGroups:

   \- ""

  resources:

   \- events

  verbs:

   \- create

   \- patch

 \- apiGroups:

   \- "extensions"

  resources:

   \- ingresses/status

  verbs:

   \- update

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: Role

metadata:

 name: nginx-ingress-role

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

rules:

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

   \- pods

   \- secrets

   \- namespaces

  verbs:

   \- get

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

  resourceNames:

   \# Defaults to "<election-id>-<ingress-class>"

   \# Here: "<ingress-controller-leader>-<nginx>"

   \# This has to be adapted if you change either parameter

   \# when launching the nginx-ingress-controller.

   \- "ingress-controller-leader-nginx"

  verbs:

   \- get

   \- update

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

  verbs:

   \- create

 \- apiGroups:

   \- ""

  resources:

   \- endpoints

  verbs:

   \- get

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: RoleBinding

metadata:

 name: nginx-ingress-role-nisa-binding

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: Role

 name: nginx-ingress-role

subjects:

 \- kind: ServiceAccount

  name: nginx-ingress-serviceaccount

  namespace: ingress-nginx

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: ClusterRoleBinding

metadata:

 name: nginx-ingress-clusterrole-nisa-binding

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: ClusterRole

 name: nginx-ingress-clusterrole

subjects:

 \- kind: ServiceAccount

  name: nginx-ingress-serviceaccount

  namespace: ingress-nginx

 

\---

 

apiVersion: apps/v1

kind: Deployment

metadata:

 name: nginx-ingress-controller

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

spec:

 replicas: 1

 selector:

  matchLabels:

   app.kubernetes.io/name: ingress-nginx

   app.kubernetes.io/part-of: ingress-nginx

 template:

  metadata:

   labels:

​    app.kubernetes.io/name: ingress-nginx

​    app.kubernetes.io/part-of: ingress-nginx

   annotations:

​    prometheus.io/port: "10254"

​    prometheus.io/scrape: "true"

  spec:

   serviceAccountName: nginx-ingress-serviceaccount

   containers:

​    \- name: nginx-ingress-controller

​     image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1

​     args:

​      \- /nginx-ingress-controller

​      \- --configmap=$(POD_NAMESPACE)/nginx-configuration

​      \- --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services

​      \- --udp-services-configmap=$(POD_NAMESPACE)/udp-services

​      \- --publish-service=$(POD_NAMESPACE)/ingress-nginx

​      \- --annotations-prefix=nginx.ingress.kubernetes.io

​     securityContext:

​      allowPrivilegeEscalation: true

​      capabilities:

​       drop:

​        \- ALL

​       add:

​        \- NET_BIND_SERVICE

​      \# www-data -> 33

​      runAsUser: 33

​     env:

​      \- name: POD_NAME

​       valueFrom:

​        fieldRef:

​         fieldPath: metadata.name

​      \- name: POD_NAMESPACE

​       valueFrom:

​        fieldRef:

​         fieldPath: metadata.namespace

​     ports:

​      \- name: http

​       containerPort: 80

​      \- name: https

​       containerPort: 443

​     livenessProbe:

​      failureThreshold: 3

​      httpGet:

​       path: /healthz

​       port: 10254

​       scheme: HTTP

​      initialDelaySeconds: 10

​      periodSeconds: 10

​      successThreshold: 1

​      timeoutSeconds: 10

​     readinessProbe:

​      failureThreshold: 3

​      httpGet:

​       path: /healthz

​       port: 10254

​       scheme: HTTP

​      periodSeconds: 10

​      successThreshold: 1

​      timeoutSeconds: 10

\---

 

\# kubectl  apply -f mandatory.yaml 

 

\# kubectl get pods -n ingress-nginx -o wide

NAME                     READY  STATUS   RESTARTS  AGE  IP       NODE   NOMINATED NODE  READINESS GATES

nginx-ingress-controller-689498bc7c-xmf8j  1/1   Running  0      9s   10.244.2.226  node2  <none>      <none>

 

\# cat service-nodeport.yaml 

apiVersion: v1

kind: Service

metadata:

 name: ingress-nginx

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

spec:

 type: NodePort

 ports:

  \- name: http

   port: 80

   targetPort: 80

   nodePort: 30080

   protocol: TCP

  \- name: https

   port: 443

   targetPort: 443

   nodePort: 30043

   protocol: TCP

 selector:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

 

\# kubectl  apply -f service-nodeport.yaml

service/ingress-nginx created

 

\# kubectl  get svc -n ingress-nginx

NAME       TYPE    CLUSTER-IP    EXTERNAL-IP  PORT(S)            AGE

ingress-nginx  NodePort  10.111.117.150  <none>     80:30080/TCP,443:30043/TCP  40s

 

\# curl http://Node:Port/jenkins

 

\# kubectl get pods -n ingress-nginx -o wide

NAME                     READY  STATUS   RESTARTS  AGE   IP       NODE   NOMINATED NODE  READINESS GATES

nginx-ingress-controller-689498bc7c-xmf8j  1/1   Running  0      7m34s  10.244.2.226  node2  <none>      <none>

 

浏览器访问jenkins:

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsx37SPD.jpg) 

 

查询管理员密码：

[root@master /]# kubectl get pods -n jenkins

NAME     READY  STATUS   RESTARTS  AGE

jenkins-0  1/1   Running  0      131m

 

[root@master /]# kubectl  exec -it jenkins-0 cat /var/jenkins_home/secrets/initialAdminPassword -n jenkins

82841678e8f845edbdf45c579cf9eb55

 

输入查询出来的管理员密码到JENKINS界面上：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpszPlRt1.jpg) 

 

选择安装推荐的插件

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps19gR7o.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpskt2SLM.jpg) 

 

 

到此部署JENKINS到K8S完成，但是没有添加RBAC权限，下一步配置JENKINS支持K8S中完成

 

 

 

 

## 配置JENKINS支持K8S

配置 Jenkins kubernetes 插件 

添加 BlueOcean 插件

添加 Kubernetes 插件，单击测试，应该会报:禁止类的错误

 

系统管理-->系统设置:

在最后新增一个云

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsDU6Xpa.jpg) 

选择：Kubernetes

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps6kK43x.jpg) 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsJJ2cIV.jpg) 

查询Kubernetes地址

[root@master stateful]# kubectl cluster-info

Kubernetes master is running at https://192.168.1.205:6443

KubeDNS is running at https://192.168.1.205:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

 

为 jenkins 插件 kubernetes 配置 ServiceAccounts

 

\# cat serviceaccount/jenkins.yml //见下图解释，在原来stateful/jenkins.yml的基础上加了sa和rbac

apiVersion: v1

kind: Namespace

metadata:

 name: jenkins

 

\---

 

apiVersion: v1

kind: Namespace

metadata:

 name: build

 

\---

 

apiVersion: v1

kind: ServiceAccount

metadata:

 name: jenkins

 namespace: jenkins

 

\---

 

kind: Role

apiVersion: rbac.authorization.k8s.io/v1beta1

metadata:

 name: jenkins

 namespace: build

rules:

\- apiGroups: [""]

 resources: ["pods", "pods/exec", "pods/log"]

 verbs: ["*"]

\- apiGroups: [""]

 resources: ["secrets"]

 verbs: ["get"]

 

\---

 

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: RoleBinding

metadata:

 name: jenkins

 namespace: build

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: Role

 name: jenkins

subjects:

\- kind: ServiceAccount

 name: jenkins

 namespace: jenkins

 

\---

 

apiVersion: v1

kind: Service

metadata:

 name: jenkins

 namespace: jenkins

spec:

 selector:

  app: jenkins

 ports:

 \- name: http

  port: 80

  targetPort: 8080

  protocol: TCP

 \- name: agent

  port: 50000

  protocol: TCP

 

\---

 

apiVersion: extensions/v1beta1

kind: Ingress

metadata:

 name: jenkins

 namespace: jenkins

 annotations:

  kubernetes.io/ingress.class: "nginx"

  ingress.kubernetes.io/ssl-redirect: "false"

  ingress.kubernetes.io/proxy-body-size: 50m

  ingress.kubernetes.io/proxy-request-buffering: "off"

  nginx.ingress.kubernetes.io/ssl-redirect: "false"

  nginx.ingress.kubernetes.io/proxy-body-size: 50m

  nginx.ingress.kubernetes.io/proxy-request-buffering: "off"

spec:

 rules:

 \- http:

   paths:

   \- path: /jenkins

​    backend:

​     serviceName: jenkins

​     servicePort: 80

 

\---

 

apiVersion: apps/v1beta2

kind: StatefulSet

metadata:

 name: jenkins

 namespace: jenkins

spec:

 selector:

  matchLabels:

   app: jenkins

 serviceName: jenkins

 replicas: 1

 updateStrategy:

  type: RollingUpdate

 template:

  metadata:

   labels:

​    app: jenkins

  spec:

   terminationGracePeriodSeconds: 10

   serviceAccountName: jenkins

   containers:

   \- name: jenkins

​    image: jenkins/jenkins:lts-alpine

​    imagePullPolicy: Always

​    ports:

​    \- containerPort: 8080

​    \- containerPort: 50000

​    resources:

​     limits:

​      cpu: 1

​      memory: 1Gi

​     requests:

​      cpu: 0.5

​      memory: 500Mi

​    env:

​    \- name: JENKINS_OPTS

​     value: --prefix=/jenkins

​    \- name: LIMITS_MEMORY

​     valueFrom:

​      resourceFieldRef:

​       resource: limits.memory

​       divisor: 1Mi

​    \- name: JAVA_OPTS

​     value: -Xmx$(LIMITS_MEMORY)m -XshowSettings:vm -Dhudson.slaves.NodeProvisioner.initialDelay=0 -Dhudson.slaves.NodeProvisioner.MARGIN=50 -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85

​    volumeMounts:

​    \- name: jenkins-home

​     mountPath: /var/jenkins_home

​    livenessProbe:

​     httpGet:

​      path: /jenkins/login

​      port: 8080

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     failureThreshold: 12 # ~2 minutes

​    readinessProbe:

​     httpGet:

​      path: /jenkins/login

​      port: 8080

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     failureThreshold: 12 # ~2 minutes

   securityContext:

​    fsGroup: 1000

 volumeClaimTemplates:

 \- metadata:

   name: jenkins-home

  spec:

   accessModes: [ "ReadWriteOnce" ]

   resources:

​    requests:

​     storage: 2Gi

 

创建了第二个命名空间 build 和 jenkins命名空间中的ServiceAccount jenkins。

创建了一个 角色和提供构建中所需权限的角色绑定 build 名称空间。

将角色绑定到jenkins命名空间中的 ServiceAccount。

因此，Jenkins应该能够在构建中创建豆荚，但是它不能在自己的命名空间Jenkins中做任何事情。这样就可以相对安全地保证构建中的问题不会影响Jenkins。如果我们为这两个名称空间指定了resourcequota和 LimitRanges，那么解决方案将更加可靠。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsJ3Fzmj.jpg) 

 

\# kubectl apply -f serviceaccount/jenkins.yml --record 

namespace/jenkins unchanged

namespace/build created

serviceaccount/jenkins created

role.rbac.authorization.k8s.io/jenkins created

rolebinding.rbac.authorization.k8s.io/jenkins created

service/jenkins unchanged

ingress.extensions/jenkins unchanged

statefulset.apps/jenkins configured

 

\# kubectl -n jenkins rollout status sts jenkins

Waiting for 1 pods to be ready...

statefulset rolling update complete 1 pods at revision jenkins-5d6c46d5d...

 

注：

  sts是statefulet的简写

 

浏览器打开：http://node2:30080/jenkins

 

获取密码

因为需要重新登陆，我之前没有记住密码

\# kubectl -n jenkins exec jenkins-0 -it -- cat /var/jenkins_home/secrets/initialAdminPassword

 

继续前面的添加云的操作：

  这次填写命名空间并点击连接测试

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpseg0Z0G.jpg) 

 

填写JNLP地址：

当我们创建一个使用Kubernetes Pods的作业时，将添加一个额外的容器。该容器将使用JNLP与 jenkins master通信。

需要指定一个有效的地址JNLP可以用来连接到主机。因为pod将在build命名空间中，而主pod是 jenkins ,因此需要使用更长的DNS名称，它指定服务的名称(jenkins)和名称空间(jenkins)。最重要的是，主配置为使用根路径 /jenkins 响应请求。

总之，完整的地址豆荚可以用来与Jenkins master通信，它应该是 http://[SERVICE_NAME].[NAMESPACE]/[PATH] 。

因为这三个元素都是 jenkins，所以"真实"地址是 http://jenkins.jenkins/jenkins 。

请在Jenkins URL字段中键入它并单击Save按钮。

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsJu8sF4.jpg)

 

到此配置完成

 

## 测试PIPELINE JOB任务

新建pipeline Job任务：

新建一个 pipeline Job ,名称为 my-k8s-job ,然后保存后构建(也可以使用蓝色海洋里面的“运行”)

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsgadZjs.jpg) 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsE0zxYP.jpg) 

 

 

 

 

点击上面的确定，然后填写名称，再把下面的构建代码填写进去：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpstPE8Cd.jpg) 

 

构建代码：

podTemplate(

  label: 'kubernetes',

  containers: [

​    containerTemplate(name: 'maven', image: 'maven:alpine', ttyEnabled: true, command: 'cat'),

​    containerTemplate(name: 'golang', image: 'golang:alpine', ttyEnabled: true, command: 'cat')

  ]

) {

  node('kubernetes') {

​    container('maven') {

​      stage('build') {

​        sh 'mvn --version'

​      }

​      stage('unit-test') {

​        sh 'java -version'

​      }

​    }

​    container('golang') {

​      stage('deploy') {

​        sh 'go version'

​      }

​    }

  }

}

 

保存

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpscz3NhB.jpg) 

 

查看构建过程：整个构建输出结果在子目录里

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsMmdxWY.jpg) 

 

构建过程中查看：（构建完成后就不显示了,如果想看过程，可以重新构建）

\# kubectl -n build get pods //应该会显示3个pod

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps8MQiBm.jpg) 

 

 

构建过程中为什么有三个容器：

  尽管指定了两个。Jenkins在Pod定义中加入了第三个。它包含了JNLP，它负责作为节点的豆荚和Jenkins master之间的通信。从用户的角度来看，JNLP是不存在的。这是一个透明的过程，我们不需要关心。

一旦Jenkins完成了作业中的指令，它就会向Kube API发出命令来终止Pod。

 

删除测试NAMESPACE环境：（这是为了清理环境）

\# kubectl delete ns jenkins build

 

参考资料:

官方文档：Jenkins-kubernetes-plugin

 

## 第一次构建结果

 

控制台输出

Started by user admin

Running in Durability level: MAX_SURVIVABILITY

[Pipeline] Start of Pipeline

[Pipeline] podTemplate

[Pipeline] {

[Pipeline] node

Still waiting to schedule task

‘kubernetes-sg9z8-lhhsh’ is offline

Agent kubernetes-sg9z8-8v482 is provisioned from template Kubernetes Pod Template

Agent specification [Kubernetes Pod Template] (kubernetes): 

\* [maven] maven:alpine

\* [golang] golang:alpine

 

Running on kubernetes-sg9z8-8v482 in /home/jenkins/workspace/my-k8s-job

[Pipeline] {

[Pipeline] container

[Pipeline] {

[Pipeline] stage

[Pipeline] { (build)

[Pipeline] sh

\+ mvn --version

Apache Maven 3.6.1 (d66c9c0b3152b2e69ee9bac180bb8fcc8e6af555; 2019-04-04T19:00:29Z)

Maven home: /usr/share/maven

Java version: 1.8.0_212, vendor: IcedTea, runtime: /usr/lib/jvm/java-1.8-openjdk/jre

Default locale: en_US, platform encoding: UTF-8

OS name: "linux", version: "3.10.0-957.el7.x86_64", arch: "amd64", family: "unix"

[Pipeline] }

[Pipeline] // stage

[Pipeline] stage

[Pipeline] { (unit-test)

[Pipeline] sh

\+ java -version

openjdk version "1.8.0_212"

OpenJDK Runtime Environment (IcedTea 3.12.0) (Alpine 8.212.04-r0)

OpenJDK 64-Bit Server VM (build 25.212-b04, mixed mode)

[Pipeline] }

[Pipeline] // stage

[Pipeline] }

[Pipeline] // container

[Pipeline] container

[Pipeline] {

[Pipeline] stage

[Pipeline] { (deploy)

[Pipeline] sh

\+ go version

go version go1.12.5 linux/amd64

[Pipeline] }

[Pipeline] // stage

[Pipeline] }

[Pipeline] // container

[Pipeline] }

[Pipeline] // node

[Pipeline] }

[Pipeline] // podTemplate

[Pipeline] End of Pipeline

Finished: SUCCESS

 

 

## 持续部署介绍

持续部署介绍

持续部署 Continuous Deployment(CDP)步骤的工作不应该从Jenkins或任何其他类似工具开始。相反，我们应该只关注 Shell命令和脚本，并不只关注CI/CD工具，只要我们确信只需要几个命令就可以执行整个过程。

我们应该能够在任何地方执行大多数CDP步骤。开发人员应该能够从Shell中本地运行它们。其他人可能希望将它们 集成到他们喜欢的IDEs 中。所有或部分CDP步骤可以执行的方式可能非常多。将它们作为每次提交的一部分运行只 是这些排列中的一种。我们执行CDP步骤的方式应该与我们定义它们的方式无关。如果我们添加了非常高的自动化 需求(如果不完全自动化的话)，很明显这些步骤必须是简单的命令或Shell脚本。添加任何其他内容都可能导致紧密 耦合，从而限制我们独立于运行这些步骤的工具的能力。

 

目标：

  是定义持续部署过程可能需要的最少步骤。从那以后，就可以扩展这些步骤，以服务于您在项目中可能遇到的特定用例。

一旦我们知道应该做什么，我们就会继续下去并定义使我们达到目标的命令。我们将尽最大努力创建CDP步骤，使 其能够轻松地移植到其他工具中。我们将尝试成为工具无关者。总会有一些特定于我们将要使用的工具的步骤，但 我希望它们将仅限于搭建，而不是CDP逻辑。

我们是否能完全实现我们的目标还有待观察。现在，我们将忽略Jenkins的存在以及所有其他可以用来编排我们的持 续部署过程的工具。相反，我们将只关注 Shell和我们需要执行的命令。我们可能会写一两个脚本。

 

 

(1)持续交付还是持续部署 

个人都希望实现持续的交付或部署。毕竟，这些好处太重要了，不容忽视。提高交付速度，提高质量，降低成本，

让人们腾出时间去做那些能带来价值的事情，等等。

 

持续集成

持续集成假定只有流程的一部分是自动化的，并且在机器完成其工作之后需要人工干预。这种干预通常包括手工测试，甚至手工部署到一个或多个环境中。

持续集成的问题：

  是自动化水平不够高。我们对这个过程不够信任。我们认为它提供了好处，但我们也需要另一种意见。我们需要人工来确认机器执行的过程的结果。

 

持续交付

持续交付(CD)是持续集成的超集（持续集成的升级版）。它的特点是每次提交都执行一个完全自动化的过程。如果流程中的任何步骤都没 有失败，我们将声明提交为生产准备。

通过持续交付，我们不会自动部署到生产环境中，因为需要有人做出业务决策。推迟或跳过将发布部署到生产环境的原因完全不是技术问题。

 

持续部署

最后，持续部署(CDP)与持续交付几乎相同。在这两种情况下，流程中的所有步骤都是完全自动化的。唯一的区别 是，“部署到生产环境”的按钮消失了。通过持续部署(CDP)，传递所有自动化步骤的每个提交都被部署到生产环境中。 

 

持续集成、交付和部署之间的区别不在于过程，而在于我们对它们的信心程度

 

 

(2)持续部署目标

持续部署过程相对容易解释，尽管实现可能会比较棘手。我们将把需求分成两组。我们将从应该应用于整个过程

的总体目标开始讨论。更确切地说，我们将讨论不可妥协的一些要求。

一般来说，这不是问题。在Kubernetes诞生之前，我们会在单独的服务器上运行管道步骤。我们会有一个专门用于 建造，另一个用于测试。我们可能有一个用于集成，另一个用于性能测试。

安全不是唯一的要求。即使一切都是安全的，我们仍然需要确保管道不会对在集群中运行的其他应用程序产生负 面影响。如果我们不小心，测试可能会请求或使用太多的资源，因此，我们可能会为在集群中运行的其他应用程 序和进程留下不足的内存。幸运的是，Kubernetes也解决了这些问题。我们可以将 Namespaces 与LimitRanges和 resourcequota结合在一起。虽然它们不能完全保证不会出错(没有什么会出错)，但它们确实提供了一组工具，如果 正确使用，它们确实提供了合理的保证，确保名称空间中的进程不会“失控”。

连续部署管道必须是安全的，它应该不会对集群中的其他应用程序产生任何副作用，而且应该是快速的。

 

 

(3)连续部署步骤

我们可以把管道分成几个阶段。我们需要构建工件(运行静态测试和分析后)。我们必须运行功能测试，因为单元测试是 不够的。我们需要创建一个版本并将其部署到某个地方生产(希望)。无论我们多么信任早期阶段，我们都必须运行测试 来验证部署(到生产)是否成功。最后，我们需要在流程结束时做一些清理工作，并删除为管道创建的所有流程。让他们 闲着是没有意义的。

 

总之，阶段如下

• 构建阶段

• 功能测试阶段 

• 发布阶段

• 部署阶段

• 生产测试阶段 

• 清理阶段

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsveOegK.jpg) 

 

## 持续部署的前期准备

wing已测试

 

持续部署的前期准备

 

(1)创建名称空间

如果要实现管道的合理安全级别，就需要在专用的名称空间中运行它们。我们的集群已经启用了RBAC，所以还需要一个ServiceAccount。由于安全性本身还不够，还需要确保管道不会影响其他应用程序。通过创建一个限定范围和一个ResourceQuota来完成这个任务。

大多数情况下，应该将应用程序需要的所有内容存储在同一个存储库中。这使得维护更加简单，并使负责该应用程序的团队能够完全控制，即使该团队可能没有在集群中创建资源的所有权限。

 

\# cat k8s/build-ns.yml（实际这里用的是build-ns-old.yml文件）

[root@master k8s]# cat build-ns.yml 

apiVersion: v1

kind: Namespace

metadata:

 name: go-demo-3-build

 

\---

 

apiVersion: v1

kind: ServiceAccount

metadata:

 name: build

 namespace: go-demo-3-build

 

\---

 

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: RoleBinding

metadata:

 name: build

 namespace: go-demo-3-build

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: ClusterRole

 name: admin

subjects:

\- kind: ServiceAccount

 name: build

 

\---

 

apiVersion: v1

kind: LimitRange

metadata:

 name: build

 namespace: go-demo-3-build

spec:

 limits:

 \- default:

   memory: 200Mi

   cpu: 0.2

  defaultRequest:

   memory: 100Mi

   cpu: 0.1

  max:

   memory: 500Mi

   cpu: 0.5

  min:

   memory: 10Mi

   cpu: 0.05

  type: Container

 

\---

 

apiVersion: v1

kind: ResourceQuota

metadata:

 name: build

 namespace: go-demo-3-build

spec:

 hard:

  requests.cpu: 2

  requests.memory: 2Gi

  limits.cpu: 3

  limits.memory: 4Gi

  pods: 15

 

\# kubectl apply -f k8s/build-ns.yml --record

 

\# cat k8s/prod-ns.yml

apiVersion: v1

kind: Namespace

metadata:

 name: go-demo-3

 

\---

 

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: RoleBinding

metadata:

 name: build

 namespace: go-demo-3

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: ClusterRole

 name: admin

subjects:

\- kind: ServiceAccount

 name: build

 namespace: go-demo-3-build

 

\---

 

apiVersion: v1

kind: LimitRange

metadata:

 name: build

 namespace: go-demo-3

spec:

 limits:

 \- default:

   memory: 200Mi

   cpu: 0.2

  defaultRequest:

   memory: 100Mi

   cpu: 0.1

  max:

   memory: 500Mi

   cpu: 0.5

  min:

   memory: 10Mi

   cpu: 0.05

  type: Container

 

\---

 

apiVersion: v1

kind: ResourceQuota

metadata:

 name: build

 namespace: go-demo-3

spec:

 hard:

  requests.cpu: 2

  requests.memory: 2Gi

  limits.cpu: 3

  limits.memory: 4Gi

  pods: 15

 

\# kubectl apply -f k8s/prod-ns.yml --record

 

(2) 定义 构建 docker

准备镜像如下：

  docker:18.03-git

  aishangwei/kubectl:v1.14.0

  aishangwei/openshift-client

  golang:1.9

  

\# cat k8s/cd.yml

apiVersion: v1

kind: Pod

metadata:

 name: cd

 namespace: go-demo-3-build

spec:

 imagePullSecrets:

 \- name: registry-secret

 containers:

 \- name: docker

  image: docker:18.03-git

  command: ["sleep"]

  args: ["100000"]

  volumeMounts:

  \- name: workspace

   mountPath: /workspace

  \- name: docker-socket

   mountPath: /var/run/docker.sock

  workingDir: /workspace

 \- name: kubectl

  image: aishangwei/kubectl:v1.14.0

  command: ["sleep"]

  args: ["100000"]

  volumeMounts:

  \- name: workspace

   mountPath: /workspace

  workingDir: /workspace

 \- name: oc

  image: aishangwei/openshift-client

  command: ["sleep"]

  args: ["100000"]

  volumeMounts:

  \- name: workspace

   mountPath: /workspace

  workingDir: /workspace

 \- name: golang

  image: golang:1.9

  command: ["sleep"]

  args: ["100000"]

  volumeMounts:

  \- name: workspace

   mountPath: /workspace

  workingDir: /workspace

 serviceAccount: build

 volumes:

 \- name: docker-socket

  hostPath:

   path: /var/run/docker.sock

   type: Socket

 \- name: workspace

  emptyDir: {}

  

注：

  Openshift是一个开源容器云平台，是一个基于主流的容器技术Docker和K8s构建的云平台。Openshift底层以Docker作为容器引擎驱动，以K8s作为容器编排引擎组件，并提供了开发语言，中间件，DevOps自动化流程工具和web console用户界面等元素，提供了一套完整的基于容器的应用云平台

 

\# kubectl apply -f k8s/cd.yml --record 

\# kubectl -n go-demo-3-build get pod

NAME  READY  STATUS   RESTARTS  AGE

cd   4/4   Running  0      10s

 

 

\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

(3) 安装 Harbor(任何一台机器，我这里因为资源有限，是在master上部署的)

\# wget -O /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

 

下面一步需要翻墙（wing用的1.5.3版本的harbor）

\# wget https://storage.googleapis.com/harbor-releases/release-1.6.0/harbor-offline-installer-v1.6.0.tgz

\# yum -y install wget lrzsz

 

\# wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

\# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

\# yum -y install docker-ce

\# systemctl start docker && systemctl enable docker

 

\# curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

 

\# chmod +x /usr/local/bin/docker-compose

 

\# tar xf harbor-offline-installer-v1.6.0.tgz

 

\# cd harbor

 

http访问方式的配置：

\# vim harbor.cfg // 主机名要可以解析(需要部署dns服务器，用/etc/hosts文件没有用)，如果不可以解析，可以使用IP地址,需要修改的内容如下

hostname = 192.168.1.200

ui_url_protocol = https（如果要用https这里就需要改，现在我们先不用https，这里不需要改）

 

\# ./install.sh

 

浏览器访问测试：

http://192.168.1.200

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps72XsV7.jpg) 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsXa5IAv.jpg) 

 

Harbor软件链接:https://pan.baidu.com/s/1F3Pq3Kxjyz5imLg4Lp8bTg 提取码:jkn2

 

 

https 访问方式的配置

\# mkdir -pv /data/cert/

\# openssl genrsa -out /data/cert/server.key 2048

\# openssl req -x509 -new -nodes -key /data/cert/server.key -subj "/CN=192.168.1.200" -days 3650 -out /data/cert/server.crt

\# ll -a /data/cert

\# vim harbor.cfg

hostname = 192.168.1.200 

ui_url_protocol = https

ssl_cert = /data/cert/server.crt 

ssl_cert_key = /data/cert/server.key

 

应用配置并重起服务

\# ./prepare

\# docker-compose down 

\# docker-compose up -d

 

浏览器https方式测试：

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps6Dy2fT.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsnzkoVg.jpg) 

 

 

客户端配置(在k8s集群的两个node上)

\# vim /etc/docker/daemon.json

{

"registry-mirrors": ["https://g9ppwtqr.mirror.aliyuncs.com"], "insecure-registries": ["192.168.1.200"]

}

 

\# systemctl restart docker

 

 

创建仓库：

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsFfwMAE.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsKJddg2.jpg) 

 

创建账户：

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsClpGVp.jpg) 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsYfjbBN.jpg) 

 

 

项目授权：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsvhvIgb.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsL1zhWy.jpg) 

 

 

 

 

 

 

## 在容器中执行持续集成

wing已测

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpspYSSBW.jpg) 

在容器中执行持续集成

在持续部署管道中，第一阶段将包含相当多的步骤。

需要检查代码，运行单元测试和任何其他静态分析， 构建Docker镜像，并将其推入注册表。

如果将持续集成(CI)定义为一组自动化的步骤，然后进行手动操作和验证， 那么我们将要执行的步骤就可以限定为CI。

 

注：

  下面的192.168.1.200为harbor库的主机名称或ip

  

\# kubectl -n go-demo-3-build exec -it cd -c docker -- sh 

/workspace # docker container ls

/workspace # git clone https://github.com/aishangwei/docker.git

/workspace # cd docker/Dockerfile/go-demo-3

 

/workspace/docker/Dockerfile/go-demo-3 # cat Dockerfile

 

FROM golang:1.9 AS build

ADD . /src

WORKDIR /src

RUN go get -d -v -t

RUN go test --cover -v ./... --run UnitTest

RUN go build -v -o go-demo

 

 

 

FROM alpine:3.4

MAINTAINER 	Viktor Farcic <viktor@farcic.com>

 

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

 

EXPOSE 8080

ENV DB db

CMD ["go-demo"]

 

COPY --from=build /src/go-demo /usr/local/bin/go-demo

RUN chmod +x /usr/local/bin/go-demo

 

/workspace/docker/Dockerfile/go-demo-3 # docker image build -t 192.168.1.200/go-demo-3/go-demo-3:1.0-beta .

\#运行过程如下，如果慢就多运行几次

 

Sending build context to Docker daemon  27.65kB

Step 1/14 : FROM golang:1.9 AS build

 ---> ef89ef5c42a9

Step 2/14 : ADD . /src

 ---> Using cache

 ---> 55349e8e28e8

Step 3/14 : WORKDIR /src

 ---> Using cache

 ---> 4994c2ffe95b

Step 4/14 : RUN go get -d -v -t

 ---> Using cache

 ---> c10907843529

Step 5/14 : RUN go test --cover -v ./... --run UnitTest

 ---> Using cache

 ---> 8926b83decb9

Step 6/14 : RUN go build -v -o go-demo

 ---> Using cache

 ---> 4d7e80be283d

Step 7/14 : FROM alpine:3.4

 ---> b7c5ffe56db7

Step 8/14 : MAINTAINER 	Viktor Farcic <viktor@farcic.com>

 ---> Running in fc67e4afbf5b

Removing intermediate container fc67e4afbf5b

 ---> b06ec9f87907

Step 9/14 : RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

 ---> Running in 8345a18a1e5a

Removing intermediate container 8345a18a1e5a

 ---> 666538c949cc

Step 10/14 : EXPOSE 8080

 ---> Running in 5b803a8b5367

Removing intermediate container 5b803a8b5367

 ---> 33abd127497c

Step 11/14 : ENV DB db

 ---> Running in e9226d38a78b

Removing intermediate container e9226d38a78b

 ---> 9bfcecb8c800

Step 12/14 : CMD ["go-demo"]

 ---> Running in e1f6f48cceef

Removing intermediate container e1f6f48cceef

 ---> 7612a372a3e5

Step 13/14 : COPY --from=build /src/go-demo /usr/local/bin/go-demo

 ---> 0c71fe16b701

Step 14/14 : RUN chmod +x /usr/local/bin/go-demo

 ---> Running in 6f4bedc44fb0

Removing intermediate container 6f4bedc44fb0

 ---> 6fc5b6913edb

Successfully built 6fc5b6913edb

Successfully tagged 192.168.1.200/go-demo-3/go-demo-3:1.0-beta

 

 

/workspace/docker/Dockerfile/go-demo-3 # docker login 192.168.1.200

Username (testuser): wing

Password: 

Login Succeeded

 

/workspace/docker/Dockerfile/go-demo-3 # docker image push 192.168.1.200/go-demo-3/go-demo-3:1.0-beta

The push refers to repository [192.168.1.200/go-demo-3/go-demo-3]

145e18a17a13: Pushed 

980e17356885: Pushed 

23f7bd114e4a: Pushed 

1.0-beta: digest: sha256:5136e1a6d56bc49e7f07a884ca6990ecba64ad345e339d6768ed001009b1fb32 size: 1157

 

 

 

• 检出

• 下载库文件

• 运行动态测试和分析

• 构建二进制或程序包

• 构建不稳定版本 Docker image

• 上传至镜像库

  构建 功能测试 版本提交

   清理 产品测试

部署

 

 

## 运行功能测试 

运行功能测试 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsL87Fhk.jpg) 

在我们的持续部署管道中，第一阶段将包含相当多的步骤。我们需要检查代码，运行单元测试和任何其他静态分析，

 

构建Docker

最后，一旦新版本运行，我们将执行一组验证它的测试。请注意，我们将只运行功能测试。您应该将其转换为“在 此阶段，我运行各种需要实时应用程序的测试”。您可能还想添加性能和集成测试。从流程的角度来看，运行哪个 测试并不重要。重要的是，在这个阶段，你运行所有那些在我们建立图像时不能静态执行的。

如果这个阶段的任何步骤失败了，我们需要准备好摧毁我们所做的一切，并让集群保持与开始这个阶段之前相同的状态。

\# kubectl -n go-demo-3-build exec -it cd -c docker -- sh

/# git clone https://github.com/aishangwei/edu-kubernetes.git 

 

\# kubectl -n go-demo-3-build exec -it cd -c kubectl -- sh

/# cd edu-kubernetes

/# cat k8s/build.yml

/# diff k8s/build.yml k8s/prod.yml

 

/# cat k8s/build.yml | sed -e "s@:latest@:1.0-beta@g" |sed -e "s@aishangwei@192.168.1.200/go-demo-3@g" | tee /tmp/build.yml

 

/# kubectl apply -f /tmp/build.yml --record

 

/# kubectl rollout status deployment api

 

/# echo $?

/# ADDR=http://192.168.20.171:30080/beta 

/# echo $ADDR | tee /workspace/addr

/# exit

 

 

\# kubectl -n go-demo-3-build exec -it cd -c golang -- sh 

/# curl $(cat /workspace/addr)/demo/hello

/#go get -d -v -t

/# export ADDRESS=api:8080

/# go test ./... -v --run FunctionalTest

/# export ADDRESS=$(cat /workspace/addr) 

/# go test ./... --run FuntionTest

/# exit

\# kubectl -n go-demo-3-build exec -it cd -c kubectl sh

\# kubectl delete -f /workspace/edu-kubernetes/k8s/build.yml

\# kubectl -n go-demo-3-build get all

 

 

## 部署到生产环境

部署到生产环境 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsdGCyXH.jpg) 

 

已经准备好创建我们的第一个生产版本。

由于我们不能部署到air，所以我们需要首先创建一个生产版本。

我们不会重建 image。生成并通过测试确认的产品(Docker映像)是我们所关心的。重建不仅是一种浪费，而且可能是一种不同于我们测试的工件。那绝不能发生!

 

\# kubectl -n go-demo-3-build exec -it cd -c docker -- sh

\# docker image tag c720174.xiodi.cn/go-demo-3/go-demo-3:1.0-beta c720174.xiodi.cn/go-demo-3/go-demo-3:1.0 

\# docker image push c720174.xiodi.cn/go-demo-3/go-demo-3:1.0

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsVyutD5.jpg) 

 

 

\# kubectl -n go-demo-3-build exec -it cd -c kubectl -- sh

/# cat k8s/prod.yml | sed -e "s@:latest@:1.0@g" |sed -e "s@aishangwei@192.168.1.200/go-demo-3@g" | tee /tmp/prod.yml

/# kubectl apply -f /tmp/prod.yml --record

/# kubectl -n go-demo-3 rollout status deployment api 

/# echo $?

/# ADDR=“192.168.20.171:30080”

/# echo $ADDR | tee /workspace/prod-addr 

/# exit

 

 

## 运行生产测试和清理管线剩余物

运行生产测试和清理管线剩余物

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsEdgrjt.jpg) 

 

\# kubectl -n go-demo-3-build exec -it cd -c golang -- sh 

/# go test ./... -v --run ProductionTest

/#

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsfUorZQ.jpg) 

 

 

 

 

 

 \# kubectl -n go-demo-3-build delete pods --all

 

 

打包 KUBERNETES 应用程序 

打包 kubernetes 应用程序 

介绍

使用YAML文件在Kubernetes集群中安装或升级应用程序只适用于静态定义。当我们需要更改应用程序的某个方面时， 我们一定会发现对模板和打包机制的需求。

我们的Jenkins定义的主要问题是它仍然不是自动的。我们可以自动安装一个主程序，但是我们仍然需要手动通过设置 向导。一旦我们完成了设置，我们需要安装一些插件，我们需要改变它的配置。 也许有一个社区维护的存储库，其中包含针对常用工具的安装解决方案。我们的使命就是找到这样一个地方。

我们面临的另一个问题是自定义YAML文件。至少，每次部署一个版本时，我们都需要指定不同的图像标记。在前面 的学习当中，在通过kubectl将定义发送到Kube API之前，我们必须使用sed修改定义。虽然这样做有效，但不是很直观。

对于定义我们想要安装的内容的副本和许多其他东西，也可以这样说。使用连接的sed命令很快就会变得复杂，而且 用户界面也不是很友好。当然，我们可以在每次发布新版本时修改YAML。我们还可以为计划使用的每个环境创建不 同的定义。但是，我们不会那样做。这只会导致重复和维护的噩梦。

我们已经有两个用于go-demo-3应用程序的YAML文件(一个用于测试，另一个用于生产)。如果我们继续沿着这条路走 下去，最终可能会得到10个、20个甚至更多相同定义的变体。我们还可能被迫在每次提交代码时修改它，以便标记始 终是最新的。那条路不是我们要走的路。它通向悬崖。我们需要的是一个模板机制，允许我们在将定义发送到Kube API之前修改它们。

 

 

(1) Helm 介绍 Helm是一个用于Kubernetes的包管理工具。

每个包称为一个Chart，一个Chart是一个目录(一般情况下会将目录进行打包压缩，形成name-version.tgz格式的 单一文件，方便传输和存储)。

一个Chart是Kubernetes部署文件的集合，使用Chart可以方便的在Kubernetes中部署一组应用。 Helm 包含两大组件:

(1)Helm :

Helm 是一个命令行客户端，主要作用如下:

• 创建 Chart

• 打包 Chart ,打包格式:Name-Version.tgz

• 创建本地 Chart 仓库

• 管理本地和远程Chart 仓库

• 与 Tiller 通信并管理 Chart 的安装，升级，删除，回滚，查看等操作

(2)Tiller

Tiller 是一个 Chart 管理服务端，Tiller接收Helm的请求，并根据Chart生成Kubernetes的部署文件(称为一个 Release)，然后提交给Kubernetes创建应用，主要作用如下:

 

 

• 监听来自Helm的请求

• 根据请求提交的Chart与Config生成一个Release

• 将Release提交给Kubernetes，并且跟踪Release的状态 • 提供Release的升级，删除，回滚等功能

Chart Install 过程:

• Helm从指定的目录或者tgz文件中解析出Chart结构信息

• Helm将指定的Chart结构和Values信息通过gRPC传递给Tiller

• Tiller根据Chart和Values生成一个Release

• Tiller将Release发送给Kubernetes用于生成Release

Chart Update过程: Helm从指定的目录或者tgz文件中解析出Chart结构信息

• Helm将要更新的Release的名称和Chart结构，Values信息传递给Tiller

• Tiller生成Release并更新指定名称的Release的History

• Tiller将Release发送给Kubernetes用于更新Release

Chart Rollback过程: Helm将要回滚的Release的名称传递给Tiller

• Tiller根据Release的名称查找History

• Tiller从History中获取上一个Release

• Tiller将上一个Release发送给Kubernetes用于替换当前Release

Chart依赖说明: Tiller在处理Chart时，直接将Chart以及其依赖的所有Charts合并为一个Release，同时传递给Kubernetes。因此Tiller 并不负责管理依赖之间的启动顺序。Chart中的应用需要能够自行处理依赖关系。

参考地址: https://imkira.com/a13.html

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsfGOxFe.jpg) 

 

 

5.2 Helm 安装

// 安装 helm软件

\# wget https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz 

\# tar xf helm-v2.11.0-linux-amd64.tar.gz

\# cp linux-amd64/helm /usr/local/bin/

// 部署 tiller

\# cat helm/tiller-rbac.yml

\# kubectl create -f helm/tiller-rbac.yml --record --save-config # helm init --service-account tiller

\# kubectl -n kube-system rollout status deploy tiller-deploy

\# kubectl -n kube-system get pods # helm repo update

\# helm repo update 

\# helm search

// 有可能镜像无法下载，墙的原因

 

 Helm 软件链接:https://pan.baidu.com/s/1F3Pq3Kxjyz5imLg4Lp8bTg 提取码:jkn2

 

5.3 使用 Helm 安装 Jenkins Charts 

\# kubectl apply -f jenkins-ns.yml --record

\# helm search jenkins

// 阿里云jenkins

\# helm repo add chart-aliyun https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts // 添加 阿里云 charts

\# kubectl apply -f helm/jenkins-pvc.yml //首先创建pvc,如果是云环境，则另外配置

\# helm install chart-aliyun/jenkins --name jenkins --namespace jenkins --set Persistence.ExistingClaim=jenkins-pvc

 

// 稳定版

\# helm install stable/jenkins --name jenkins --namespace jenkins

\# kubectl -n jenkins rollout status deploy jenkins curl http://192.168.20.171:NodePort/jenkins

 

 

\# kubectl -n jenkins get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -- decode; echo

\# helm inspect stable/jenkins // chart-aliyun 

\# helm ls

\# helm status jenkins

\# kubectl -n kube-system get cm

\# kubectl -n kube-system describe cm jenkins.v1

\# helm delete jenkins // 只是删除 kubernetes资源 # kubectl -n jenkins get all

\# hlem status jenkins

\# helm delete jenkins --purge // 同时删除 kubernetes资源和chart 

\# helm status jenkins

 

 

5.4 Helm 定制安装和回滚 // 定制安装

\# helm inspect values stable/jenkins # helm inspect stable/jenkins

\# helm install stable/jenkins --name jenkins --namespace jenkins --set Master.ImageTag=2.112-alpine 

\# kubectl -n jenkins rollout status deployment jenkins

curl http://NodeIP:PORT

\# helm upgrade jenkins stable/jenkins --set Master.ImageTag=2.116-alpine --reuse-values

\# kubectl -n jenkins describe deployment jenkins

\# kubectl -n jenkins rollout status deployment jenkins

curl http://NodeIP:PORT

 

 

// Helm 版本回滚 # helm list

\# helm rollback jenkins 0 

\# helm list

\# kubectl -n jenkins rollout status deployment jenkins curl http://NodeIP:PORT

\# helm delete jenkins --purge

 

 

5.5 使用 YAMl 值自定义 Helm 安装 

\# HOST=“jenkins.aishangwei.net”

\# helm inspect values stable/jenkins 

\# cat helm/jenkins-values.yml

// # helm install stable/jenkins --name jenkins --namespace jenkins --values helm/jenkins-values.yml --set Master.HostName=$HOST

\# kubectl apply -f helm/jenkins-pvc.yml

\# helm install chart-aliyun/jenkins --name jenkins --namespace jenkins --values helm/jenkins-values.yml --set Master.HostName=$HOST --set Persistence.ExistingClaim=jenkins-pvc

\# kubectl -n jenkins rollout status deployment jenkins

curl http://$HOST

\# kubectl -n jenkins get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode; echo

\# helm get values jenkins

\# helm delete jenkins --purge 

\# kubectl delete ns jenkins

 

 

5.6 创建 Helm Charts 

(1) 创建一个测试 Chart

\# helm create my-app

\# ls -l my-app

\# helm dependency update my-app 

\# helm package my-app

//应该是没有什么依赖的

\# helm lint my-app // 验证 chart是否正确 

\# helm install ./my-app-0.1.0.tgz --name my-app 

\# helm delete my-app --purge

\# rm -rf my-app

\# rm -rf my-app-0.1.0.tgz

 

 

(2)探索构成图表(Chart)的文件 

\# ls -l helm/go-demo-3

\# cat helm/go-demo-3/Chart.yaml

\# cat helm/go-demo-3/LICENSE

\# cat helm/go-demo-3/README.md

\# cat helm/go-demo-3/values.yaml

\# ls -l helm/go-demo-3/templates/

\# cat helm/go-demo-3/templates/NOTES.txt

 

 

预定义值的完整列表如下(正式文档的副本)。

• Release.Name: 发布的名称(不是图表)

• Release.Time: 图表发布最后一次更新的时间。这将匹配发布对象上的最后发布时间。

• Release.Namespace: 图表发布到的名称空间。

• Release.Service: 执行发布的服务。通常这是舵柄

• Release.IsUpgrade: 如果当前操作是升级或回滚，则设置为true

• Release.IsInstall: 如果当前操作是安装，则将其设置为true

• Release.Revision: 修订号。它从1开始，随着每个 Helm 的升级而增加。

• Chart: 图表的内容。因此，图表版本可以以图表的形式获得。版本和维护者在图表中。

• Files: 一个类映射对象，包含图表中的所有非特殊文件。这不会让您访问模板，但会让您访问现有的其他文件 (除非使用.helmignore 排除这些文件)。文件可以使用 {{index .Files "file.name"}} 或 使用 {{.Files.Get name}} 或 {{.Files.GetString name}} 功能。您还可以使用 {{.Files.GetBytes}} 访问文件 [ ]byte 的内容

• Capabilities: 一个类似地图的对象，包含关于Kubernetes版本的信息( {{.Capabilities.KubeVersion}}, Tiller

( {{.Capabilities.TillerVersion}} , 和支持 Kubernetes API 版本 ({{.Capabilities.APIVersions.Has "batch/v1"}})

 

 

 

\# cat helm/go-demo-3/templates/_helpers.tpl

\# cat helm/go-demo-3/templates/deployment.yaml 

\# cat helm/go-demo-3/templates/ing.yaml

\# helm lint helm/go-demo-3

\# helm package helm/go-demo-3 -d helm

 

(3)升级安装Charts

\# helm inspect values helm/go-demo-3

\# HOST=go-demo-3.aishangwei.net

//# helm upgrade -i go-demo-3 helm/go-demo-3 --namespace go-demo-3 --set image.tag=1.0 --set ingress.host=$HOST --reuse-values

\# kubectl -n go-demo-3 rollout status deployment go-demo-3

curl http://$HOST/demo/hello

\# helm upgrade -i go-demo-3 helm/go-demo-3 --namespace go-demo-3 --set image.tag=2.0 --reuse-values

\# helm delete go-demo-3 --purge # kubectl delete ns go-demo-3

 

\6. Chart 仓库

6.1 Chart 仓库安装

(1) 介绍 能够打包应用程序是没有用的，除非我们能够分发它们。Kubernetes应用程序是一个或多个容器映像和描述它们

的YAML文件的组合。如果要分发应用程序，则需要在存储库中同时存储容器映像和YAML定义。

在这一点上，您可能认为能够在您的笔记本电脑上运行图表是一个很好的方法。您所要做的就是检查应用程序 的代码，希望图表在那里，并执行一个命令，如helm upgrade -i go-demo-3 helm/go-demo-3。你是对的，这是安 装或升级你正在开发的应用程序最简单的方法。然而，您的应用程序并不是您将要安装的唯一应用程序。

如果您是一名开发人员，您几乎肯定希望在您的笔记本上运行许多应用程序。如果你需要检查你的应用程序是 否与你的同事开发的应用程序集成，你也需要运行他们的应用程序。您可以继续沿着相同的路径检查它们的代 码并安装local图表。但这已经开始变得乏味了。 您需要知道他们使用的存储库，并查看比您真正需要的更多的代码。安装同事的应用程序和安装公开可用的第 三方应用程序不是更好吗?如果你能执行 helm search my-company-repo/ 之类的东西，获得组织中创建的所有应 用的列表，并安装所需的应用，岂不是很棒?我们已经使用相同的方法处理容器图像(例如 docker image pull ) Linux包( apt install vim )和许多其他包和发行版。为什么不做相同的 Helm Charts? 为什么我们要将定义应用程序 的能力限制在第三方创建的应用程序上?我们应该能够以同样的方式分发我们的应用程序.

舵手海图(Helm Charts)还很年轻。项目刚刚开始，可供选择的存储库并不多。今天(2018年6月)，ChartMuseum是 为数不多的(如果不是唯一的)仓库之一。选择正确的非常简单。当没有太多的选择时，选择过程很容易。

 

 (2) 使用 ChartMuseum

正如Docker Registry是一个可以发布容器图像并让其他人可以访问它们的地方一样，我们可以使用图表存储库来实

现与图表类似的目标。 图表存储库是存储和检索打包图表的位置。我们用ChartMuseum来做。可供选择的解决方案并不多。我们可以说我

们选择它是因为没有其他选择。这种情况很快就会改变。我确信Helm Charts会集成到通用存储库中。

(3) 安装 ChartMuseum

\# curl -LO https://s3.amazonaws.com/chartmuseum/release/latest/bin/linux/amd64/chartmuseum

\# chmod +x ./chartmuseum

\# mv ./chartmuseum /usr/local/bin/

\# chartmuseum --debug --port=8089 --storage=“local” --storage-local-rootdir=“./chartstorage” --basic-auth-user admin -- basic-auth-pass admin123 // 启动服务

curl http://192.168.20.174:8089/health

open http://192.168.20.174:8089

curl http://192.168.20.174:8089/index.yaml

curl -u admin:admin123 http://192.168.20.174:8089/index.yaml

 

  

 6.2 客户端(helm) 操作

\# helm repo add chartmuseum http://192.168.20.174:8089 --username admin --password admin123

输出声明“chartmuseum”已添加到存储库中。从现在开始，我们在ChartMuseum安装中存储的所有图表都将通过Helm 客户端提供。

唯一剩下的事情就是开始向ChartMuseum push 图表。我们可以通过发送curl请求来实现。不过，还有更好的方法， 所以我们将跳过HTTP请求，安装Helm插件。

\# helm plugin install https://github.com/chartmuseum/helm-push

\# helm push ./helm/go-demo-3/ chartmuseum --username admin --password admin123 # curl http://192.168.20.174:8089/index.yaml -u admin:admin123

\# helm search chartmuseum/ // 搜索chart ,应该是空的 输出可能令人失望。声明没有发现任何结果。问题是，即使图表存储在ChartMuseum存储库中，我们也没有更新本

地存储在Helm客户机中的存储库信息。首先更新它。

\# helm repo update

\# helm search chartmuseum/

\# helm inspect chartmuseum/go-demo-3

 

 

 \# GD3_ADDR=“go-demo-3.aishangwei.net” 

 \# helm upgrade -i go-demo-3 \

chartmuseum/go-demo-3 \ --namespace go-demo-3 \

--set image.tag=1.0 \

--set ingress.host=$GD3_ADDR \ --reuse-values

\# kubectl -n go-demo-3 rollout status deploy go-demo-3 

\# curl "http://$GD3_ADDR/demo/hello"

\# helm delete go-demo-3 --purge 不幸的是，没有Helm插件允许我们从存储库中删除图表，因此我们将使用curl来完成任务。

\# curl -XDELETE "http://c720174.xiodi.cn:8089/api/charts/go-demo-3/0.0.1" -u admin:admin123 {"deleted":true}

Chart仓库UI安装(Monocular) ,暂时不安装

 

 

 

 \7. 安装和设置Jenkins 7.1 安装 Jenkins 及运行

\# JENKINS_ADDR=jenkins.aishangwei.net

\# helm install stable/jenkins --name jenkins --namespace jenkins --values helm/jenkins-values.yml --set Master.HostName=$JENKINS_ADDR

\# kubectl -n jenkins rollout status deployment jenkins

open http://$JENKINS_ADDR

\# JENKINS_PASS=$(kubectl -n jenkins get secret jenkins \ -o jsonpath="{.data.jenkins-admin-password}" \

| base64 --decode; echo) # echo $JENKINS_PASS

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsfPzXlC.jpg) 

 

 

 

 7.2 创建一个Job

// 测试1

新建一个 pipeline job, 名称为 test-k8s-job.

test-k8s-job https://github.com/aishangwei/kubernetes/blob/master/jenkins/pipeline/test-k8s-job.groovy

请单击流水线选项卡，您将看到管道脚本字段。写出下面的脚本。

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsmvDq2Z.jpg) 

 

 请从左边的菜单中点击打开的蓝海链接。你会看到的在屏幕中间运行按钮。点击它。因此，将出现带新构建的行。

单击以查看详细信息。 构建正在运行，我们应该返回终端窗口以确认Pod确实已经创建。 # kubectl -n jenkins get pods

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsI5OVIn.jpg)

 // 测试2 管道代码修改为:https://raw.githubusercontent.com/aishangwei/kubernetes/master/jenkins/pipeline/my-k8s-job- yaml.groovy

保存运行

Jenkins将在同一个命名空间中创建一个Pod。这个Pod将有5个容器，其中4个容器将承载我们在podTemplate中指定的 工具，Jenkins将注入第五个容器，以建立两者之间的通信 Jenkins和Pod。我们可以通过在jenkins中列出豆荚来证实这 一点。

\# kubectl -n jenkins get pods

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsGISupL.jpg)

  您将注意到构建将挂起。几分钟后，你可能会认为它会永远挂着。它不会。大约五分钟后，舵机阶段的输出将会变 成接下来的输出。

  ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsx4d658.jpg)

  

 我们的构建不能连接到Tiller。helm试了五分钟。它达到了预先定义的超时，并放弃了。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsGE4JMw.jpg) 

 

 

 我们没有设置ServiceAccount让Helm 在容器中与Tiller通信。我们是否应该允许在容器中运行的Helm与在kube系统 中运行的舵相互作用是值得怀疑的。这将是一个巨大的安全风险，允许任何访问Jenkins的人访问集群的任何部分。 这将挑战我们使用名称空间的一个重要原因。接下来我们将探讨这个问题以及其他一些问题。现在，我们将确认 Jenkins删除了失败构建所创建的Pod。

\# kubectl -n jenkins get pods

 

 

 7.3 在不同的名称空间中运行 // 替换脚本文件为以下代码

// 管道代码 https://raw.githubusercontent.com/aishangwei/kubernetes/master/jenkins/pipeline/my-k8s-job-ns.groovy

这个作业与我们之前使用的作业的唯一区别是在podTemplate arguments和serviceAccount中。这一次，我们指定应 该在go-demo-3构建名称空间中创建Pod，并且应该使用ServiceAccount构建。如果一切按计划进行，在不同名称空 间中运行Pods的指令应该提供我们所希望的分离，ServiceAccount将提供与Kube API或其他Pods交互时Pod可能需要 的权限。

请单击Run按钮，并选择新构建的行。您将看到我们在过去已经看到的等待下一个可用的执行器消息。Jenkins 需 要等待，直到一个豆荚被创建和完全运作。然而，这一次的等待将会更长，因为jenkins将不能创建豆荚。

原因有二:ServiceAccount和名称空间不存在 # cat k8s/build-ns.yml

\# kubectl apply -f k8s/build-ns.yml --record

\# cat k8s/prod-ns.yml // 把生产所需的名称空间也建好 # kubectl apply -f k8s/prod-ns.yml --record

到目前为止，我们在jenkins命名空间中提供了一个角色绑定Jenkins拥有足够的权限在同一个命名空间中创建豆荚。 然而，我们最新的产品线希望在go-demo-3名称空间构建中创建豆荚。考虑到我们没有使用能够提供集群范围权限 的ClusterRoleBinding，我们还需要在go-demo-3- build中创建一个RoleBinding。由于这是特定于应用程序的，因此定 义在其存储库中，并且应该由集群的管理员执行，就像前两个一样。

 

 

 \# cat k8s/jenkins.yml // 把serviceaccount 绑定到集群管理员上面 

 \# kubectl apply -f k8s/jenkins.yml --record

// 更改 jenkins中 k8s的配置 SERVICE_NAME.NAMESPACE:5000

 

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsl4lstU.jpg)

 \# helm init --service-account build --tiller-namespace go-demo-3-build

\# kubectl -n go-demo-3-build rollout status deployment tiller-deploy

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpszqfdai.jpg) 

\# kubectl -n go-demo-3-build get pods

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps2DT0QF.jpg)

 

 

 7.4 为构建容器映像创建节点

(1)安装VM，并且安装上docker ,java (2) 添加凭据

(3) 在主节点添加Node

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsR6gRx3.jpg)

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsMLOJer.jpg)

 

 

 7.5 测试 Docker 在集群之外构建 流水线脚本替换如下:

https://raw.githubusercontent.com/aishangwei/kubernetes/master/jenkins/pipeline/my-k8s-job-docker.groovy

与之前版本的作业相比，惟一显著的区别是添加了第二个节点段。大多数步骤将在kubernetes节点中执行，该节点 承载一些容器。新节点称为docker，将负责需要docker服务器的步骤。从job的角度来看，节点是如何创建的并不重 要，重要的是它的存在，或者它将根据需要创建。该任务将请求节点docker和kubernetes，如何获得它们取决于 Jenkins的内部配置。

 

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsMD2EVO.jpg)

 

 ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsFD6CCc.jpg)

 

## 项目所需镜像

\# docker pull jenkins/jenkins:lts-alpine

\# docker pull daocloud.io/library/nginx

 

 

下面这个需要翻墙：不过docker-hub上有

\# docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1

 

\# docker pull googlecontainer/nginx-ingress-controller

 

\# docker tag siriuszg/nginx-ingress-controller quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1

 

 

## 项目所需YAML文件

 

 

### STATEFUL/JENKINS.YML

\# cat stateful/jenkins.yml

apiVersion: v1

kind: Namespace

metadata:

 name: jenkins

 

\---

 

apiVersion: v1

kind: Service

metadata:

 name: jenkins

 namespace: jenkins

spec:

 selector:

  app: jenkins

 ports:

 \- name: http

  port: 80

  targetPort: 8080

  protocol: TCP

 \- name: agent

  port: 50000

  protocol: TCP

 

\---

 

apiVersion: extensions/v1beta1

kind: Ingress

metadata:

 name: jenkins

 namespace: jenkins

 annotations:

  kubernetes.io/ingress.class: "nginx"

  ingress.kubernetes.io/ssl-redirect: "false"

  ingress.kubernetes.io/proxy-body-size: 50m

  ingress.kubernetes.io/proxy-request-buffering: "off"

  nginx.ingress.kubernetes.io/ssl-redirect: "false"

  nginx.ingress.kubernetes.io/proxy-body-size: 50m

  nginx.ingress.kubernetes.io/proxy-request-buffering: "off"

spec:

 rules:

 \- http:

   paths:

   \- path: /jenkins

​    backend:

​     serviceName: jenkins

​     servicePort: 80

 

\---

 

apiVersion: apps/v1beta2

kind: StatefulSet

metadata:

 name: jenkins

 namespace: jenkins

spec:

 selector:

  matchLabels:

   app: jenkins

 serviceName: jenkins

 replicas: 1

 updateStrategy:

  type: RollingUpdate

 template:

  metadata:

   labels:

​    app: jenkins

  spec:

   terminationGracePeriodSeconds: 10

   containers:

   \- name: jenkins

​    image: jenkins/jenkins:lts-alpine

​    imagePullPolicy: Always

​    ports:

​    \- containerPort: 8080

​    \- containerPort: 50000

​    resources:

​     limits:

​      cpu: 1

​      memory: 1Gi

​     requests:

​      cpu: 0.5

​      memory: 500Mi

​    env:

​    \- name: JENKINS_OPTS

​     value: --prefix=/jenkins

​    \- name: LIMITS_MEMORY

​     valueFrom:

​      resourceFieldRef:

​       resource: limits.memory

​       divisor: 1Mi

​    \- name: JAVA_OPTS

​     value: -Xmx$(LIMITS_MEMORY)m -XshowSettings:vm -Dhudson.slaves.NodeProvisioner.initialDelay=0 -Dhudson.slaves.NodeProvisioner.MARGIN=50 -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85

​    volumeMounts:

​    \- name: jenkins-home

​     mountPath: /var/jenkins_home

​    livenessProbe:

​     httpGet:

​      path: /jenkins/login

​      port: 8080

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     failureThreshold: 12 # ~2 minutes

​    readinessProbe:

​     httpGet:

​      path: /jenkins/login

​      port: 8080

​     initialDelaySeconds: 60

​     timeoutSeconds: 5

​     failureThreshold: 12 # ~2 minutes

   securityContext:

​    fsGroup: 1000

 volumeClaimTemplates:

 \- metadata:

   name: jenkins-home

  spec:

   accessModes: [ "ReadWriteOnce" ]

   resources:

​    requests:

​     storage: 2Gi

 

 

### NGINX-INGRESS-CONTROLLER

[root@master /]# cat mandatory.yaml 

apiVersion: v1

kind: Namespace

metadata:

 name: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

 

kind: ConfigMap

apiVersion: v1

metadata:

 name: nginx-configuration

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

kind: ConfigMap

apiVersion: v1

metadata:

 name: tcp-services

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

kind: ConfigMap

apiVersion: v1

metadata:

 name: udp-services

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

apiVersion: v1

kind: ServiceAccount

metadata:

 name: nginx-ingress-serviceaccount

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: ClusterRole

metadata:

 name: nginx-ingress-clusterrole

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

rules:

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

   \- endpoints

   \- nodes

   \- pods

   \- secrets

  verbs:

   \- list

   \- watch

 \- apiGroups:

   \- ""

  resources:

   \- nodes

  verbs:

   \- get

 \- apiGroups:

   \- ""

  resources:

   \- services

  verbs:

   \- get

   \- list

   \- watch

 \- apiGroups:

   \- "extensions"

  resources:

   \- ingresses

  verbs:

   \- get

   \- list

   \- watch

 \- apiGroups:

   \- ""

  resources:

   \- events

  verbs:

   \- create

   \- patch

 \- apiGroups:

   \- "extensions"

  resources:

   \- ingresses/status

  verbs:

   \- update

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: Role

metadata:

 name: nginx-ingress-role

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

rules:

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

   \- pods

   \- secrets

   \- namespaces

  verbs:

   \- get

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

  resourceNames:

   \# Defaults to "<election-id>-<ingress-class>"

   \# Here: "<ingress-controller-leader>-<nginx>"

   \# This has to be adapted if you change either parameter

   \# when launching the nginx-ingress-controller.

   \- "ingress-controller-leader-nginx"

  verbs:

   \- get

   \- update

 \- apiGroups:

   \- ""

  resources:

   \- configmaps

  verbs:

   \- create

 \- apiGroups:

   \- ""

  resources:

   \- endpoints

  verbs:

   \- get

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: RoleBinding

metadata:

 name: nginx-ingress-role-nisa-binding

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: Role

 name: nginx-ingress-role

subjects:

 \- kind: ServiceAccount

  name: nginx-ingress-serviceaccount

  namespace: ingress-nginx

 

\---

apiVersion: rbac.authorization.k8s.io/v1beta1

kind: ClusterRoleBinding

metadata:

 name: nginx-ingress-clusterrole-nisa-binding

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: ClusterRole

 name: nginx-ingress-clusterrole

subjects:

 \- kind: ServiceAccount

  name: nginx-ingress-serviceaccount

  namespace: ingress-nginx

 

\---

 

apiVersion: apps/v1

kind: Deployment

metadata:

 name: nginx-ingress-controller

 namespace: ingress-nginx

 labels:

  app.kubernetes.io/name: ingress-nginx

  app.kubernetes.io/part-of: ingress-nginx

spec:

 replicas: 1

 selector:

  matchLabels:

   app.kubernetes.io/name: ingress-nginx

   app.kubernetes.io/part-of: ingress-nginx

 template:

  metadata:

   labels:

​    app.kubernetes.io/name: ingress-nginx

​    app.kubernetes.io/part-of: ingress-nginx

   annotations:

​    prometheus.io/port: "10254"

​    prometheus.io/scrape: "true"

  spec:

   serviceAccountName: nginx-ingress-serviceaccount

   containers:

​    \- name: nginx-ingress-controller

​     image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1

​     args:

​      \- /nginx-ingress-controller

​      \- --configmap=$(POD_NAMESPACE)/nginx-configuration

​      \- --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services

​      \- --udp-services-configmap=$(POD_NAMESPACE)/udp-services

​      \- --publish-service=$(POD_NAMESPACE)/ingress-nginx

​      \- --annotations-prefix=nginx.ingress.kubernetes.io

​     securityContext:

​      allowPrivilegeEscalation: true

​      capabilities:

​       drop:

​        \- ALL

​       add:

​        \- NET_BIND_SERVICE

​      \# www-data -> 33

​      runAsUser: 33

​     env:

​      \- name: POD_NAME

​       valueFrom:

​        fieldRef:

​         fieldPath: metadata.name

​      \- name: POD_NAMESPACE

​       valueFrom:

​        fieldRef:

​         fieldPath: metadata.namespace

​     ports:

​      \- name: http

​       containerPort: 80

​      \- name: https

​       containerPort: 443

​     livenessProbe:

​      failureThreshold: 3

​      httpGet:

​       path: /healthz

​       port: 10254

​       scheme: HTTP

​      initialDelaySeconds: 10

​      periodSeconds: 10

​      successThreshold: 1

​      timeoutSeconds: 10

​     readinessProbe:

​      failureThreshold: 3

​      httpGet:

​       path: /healthz

​       port: 10254

​       scheme: HTTP

​      periodSeconds: 10

​      successThreshold: 1

​      timeoutSeconds: 10

 

\---

 

 

# JENKINS

 

 

## 完整JENKINS构建DOCKER镜像流程

wing测试成功

 

我这里没有使用Docker Pipeline，直接在构建完成后，执行shell脚本，这样更灵活。

 

\1. 部署流程

 

一、研发push到github代码库

二、Jenkins 构建，pull git代码 使用maven进行编译打包

三、打包生成的代码，生成一个新版本的镜像，push到本地docker仓库harbor

四、发布，测试机器 pull 新版本的镜像，并删除原来的容器，重新运行新版本镜像。

 

git+jenkins(git+maven+docker)+harbor+docker服务器(k8s) 

 

\2. 环境说明

用的服务器是我的aliyun服务器，node2为K8s环境里的node2

 

主机名	 操作系统版本	IP地址	          用途	安装软件

jenkins CentOS7.6	172.22.211.173 	jenkins、git、Docker 18.09-ce

node2  CentOS7.6	172.22.211.175  业务部署测试环境	harbor、Docker 18.09-ce

 

软件安装：

jenkins机器：

  \# yum install java git maven

  安装插件：Maven Integration

 

node2机器：

  \# yum install jq  //后面的脚本会用到,jq类似于sed/awk专门处理json格式的文件

  

\3. 配置

由于在Jenkins机器上docker是使用root用户运行的，而Jenkins是使用普通用户jenkins运行的，所以要先配置下jenkins用户可以使用docker命令。

 

[root@jenkins ~]# visudo

jenkins ALL=(root)    NOPASSWD: /usr/bin/docker

 

另外在Jenkins机器上配置：

 

\# Disable "ssh hostname sudo <cmd>", because it will show the password in clear.

\#     You have to run "ssh -t hostname sudo <cmd>".

\#

\#Defaults   requiretty

Defaults:jenkins !requiretty

 

如果不配置这个，在执行下面脚本时，会报错误：

\+ cp -f /home/jenkins/.jenkins/workspace/godseyeBranchForNov/godseye-container/target/godseye-container-wisedu.war /home/jenkins/docker-file/godseye_war/godseye.war

\+ sudo docker login -u jkzhao -p Wisedu123 -e 01115004@wisedu.com 172.16.206.32

sudo: sorry, you must have a tty to run sudo

 

在node2机器上配置：

\# visudo

\#

\#Defaults   requiretty

Defaults:root !requiretty

 

否则在机器node2机器上执行脚本时会报错：

[SSH] executing...

sudo: sorry, you must have a tty to run sudo

docker: invalid reference format.

 

\4. 安装插件

登录Jenkins，点击“系统管理”，点击“管理插件”，搜索插件“SSH plugin”，进行安装。

 

登录Jenkins，点击“Credentials”，点击“Add domain”。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsv6efkA.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpstkHT1X.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsx8xAJl.jpg) 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpszUzjrJ.jpg) 

 

 

点击“系统管理”，“系统配置”，找到“SSH remote hosts”。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpszl5486.jpg) 

 

\5. Jenkins构建maven风格的job

 

代码地址： https://github.com/yanqiang20172017/easy-springmvc-maven.git

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsbRVSQu.jpg) 

 

Goals and options填写：clean package -Dmaven.test.skip=true

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsutiJyS.jpg) 

 

\6. 配置Post Steps

注：脚本中用到的仓库和认证的账号需要先在harbor新建好。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsk1ICgg.jpg) 

\# Jenkins机器：编译完成后，build生成一个新版本的镜像，push到远程docker仓库

 

\# Variables

JENKINS_WAR_HOME='/root/.jenkins/workspace/maven-docker-test/target'

DOCKERFILE_HOME='/root/jenkins/docker-file/maven-docker-test_war'

HARBOR_IP='172.22.211.175'

REPOSITORIES='jenkins/maven-docker-test'

HARBOR_USER='wing'

HARBOR_USER_PASSWD='Harbor12345'

HARBOR_USER_EMAIL='276267003@qq.com'

 

\# Copy the newest war to docker-file directory.

\cp -f ${JENKINS_WAR_HOME}/easy-springmvc-maven.war ${DOCKERFILE_HOME}/maven-docker-test.war

 

\# Delete image early version.

sudo docker login -u ${HARBOR_USER} -p ${HARBOR_USER_PASSWD} ${HARBOR_IP} 

IMAGE_ID=`sudo docker images | grep ${REPOSITORIES} | awk '{print $3}'`

if [ -n "${IMAGE_ID}" ];then

  sudo docker rmi ${IMAGE_ID}

fi

 

\# Build image.

cd ${DOCKERFILE_HOME}

TAG=`date +%Y%m%d-%H%M%S`

sudo docker build -t ${HARBOR_IP}/${REPOSITORIES}:${TAG} . &>/dev/null

 

\# Push to the harbor registry.

sudo docker push ${HARBOR_IP}/${REPOSITORIES}:${TAG} &>/dev/null

 

 

注：war包的名字为git项目的名字

/root/.jenkins/workspace/maven-docker-test/target/easy-springmvc-maven.war

 

拉取镜像，发布

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpspcrAYD.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpscpwAG1.jpg) 

 

 

\# 拉取镜像，发布

HARBOR_IP='172.22.211.175'

REPOSITORIES='jenkins/maven-docker-test'

HARBOR_USER='wing'

HARBOR_USER_PASSWD='Harbor12345'

 

\# 登录harbor

docker login -u ${HARBOR_USER} -p ${HARBOR_USER_PASSWD} ${HARBOR_IP}

 

\# Stop container, and delete the container.

CONTAINER_ID=`docker ps | grep "maven-docker-test" | awk '{print $1}'`

if [ -n "$CONTAINER_ID" ]; then

  docker stop $CONTAINER_ID

  docker rm $CONTAINER_ID

else #如果容器启动时失败了，就需要docker ps -a才能找到那个容器

  CONTAINER_ID=`docker ps -a | grep "maven-docker-test" | awk '{print $1}'`

  if [ -n "$CONTAINER_ID" ]; then  # 如果是第一次在这台机器上拉取运行容器，那么docker ps -a也是找不到这个容器的

​    docker rm $CONTAINER_ID

  fi

fi

 

\# Deleteeasy-springmvc-maven image early version.

IMAGE_ID=`sudo docker images | grep ${REPOSITORIES} | awk '{print $3}'`

if [ -n "${IMAGE_ID}" ];then

  docker rmi ${IMAGE_ID}

fi

 

\# Pull image.

\# TAG=`curl -s http://${HARBOR_IP}/api/repositories/${REPOSITORIES}/tags | jq '.[-1]' | sed 's/\"//g'` 

TAG=`curl -s http://172.22.211.175/api/repositories/jenkins/maven-docker-test/tags | jq '.[-1]| {name:.name}' | awk -F '"' '/name/{print $4}'`

docker pull ${HARBOR_IP}/${REPOSITORIES}:${TAG} &>/dev/null

 

\# Run.

docker run -d --name maven-docker-test -p 8080:8080 ${HARBOR_IP}/${REPOSITORIES}:${TAG}

 

保存构建：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsIMWFop.jpg) 

 

恭喜！！！

 

 

### 安装HARBOR

下面一步需要翻墙（wing用的1.5.3版本的harbor）

\# wget https://storage.googleapis.com/harbor-releases/release-1.8.0/harbor-offline-installer-v1.8.0.tgz

\# yum -y install  lrzsz

 

\# curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

 

\# chmod +x /usr/local/bin/docker-compose

 

\# tar xf harbor-offline-installer-v1.8.0.tgz

 

\# cd harbor

 

http访问方式的配置：

\# vim harbor.yml // 主机名要可以解析(需要部署dns服务器，用/etc/hosts文件没有用)，如果不可以解析，可以使用IP地址,需要修改的内容如下

hostname = 192.168.1.200

ui_url_protocol = https（如果要用https这里就需要改，现在我们先不用https，这里不需要改）

 

\# ./install.sh

 

浏览器访问测试：

http://192.168.1.200

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpso1GP6M.jpg) 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsbEr1Oa.jpg) 

 

https 访问方式的配置

\# mkdir -pv /data/cert/

\# openssl genrsa -out /data/cert/server.key 2048

\# openssl req -x509 -new -nodes -key /data/cert/server.key -subj "/CN=192.168.1.200" -days 3650 -out /data/cert/server.crt

\# ll -a /data/cert

\# vim harbor.cfg

hostname = 192.168.1.200 

ui_url_protocol = https

ssl_cert = /data/cert/server.crt 

ssl_cert_key = /data/cert/server.key

 

应用配置并重起服务

\# ./prepare

\# docker-compose down 

\# docker-compose up -d

 

浏览器https方式测试：

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsSW9fxy.jpg) 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsFEJwfW.jpg) 

 

 

 

客户端配置(每个访问harbor的机器上都要配置)

\# vim /etc/docker/daemon.json

{

"insecure-registries": ["172.22.211.175"]

}

 

\# systemctl restart docker

 

 

创建仓库：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps7ysQXj.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpscnrcGH.jpg) 

 

 

创建账户：

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsFQkAo5.jpg) 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpskj9Z6s.jpg) 

 

项目授权：

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsJo1tPQ.jpg) 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsmhwZxe.jpg) 

测试：

上传：

 [root@docker ~]# docker login harbor.io

  Username: wing

  Password:

  WARNING! Your password will be stored unencrypted in /root/.docker/config.json.

  Configure a credential helper to remove this warning. See

  https://docs.docker.com/engine/reference/commandline/login/#credentials-store

  

  Login Succeeded

  \# docker images

  REPOSITORY      TAG         IMAGE ID       CREATED       SIZE

  nginx        latest        be1f31be9a87     13 days ago     109MB

  

  \# docker image tag daocloud.io/library/nginx:latest 172.22.211.175/jenkins/nginx

 

  \# docker push 172.22.211.175/jenkins/nginx

  The push refers to repository [harbor.io/library/nginx]

  92b86b4e7957: Pushed

  94ad191a291b: Pushed

  8b15606a9e3e: Pushed

  latest: digest: sha256:204a9a8e65061b10b92ad361dd6f406248404fe60efd5d6a8f2595f18bb37aad size: 948

 

在web界面中查看镜像是否被上传到仓库中

 

 

#### 重置HARBOR登陆密码

wing测试通过

 

Harbor密码重置 

 

harbor现使用postgresql 数据库。不再支持mysql

 

注：

  卸载重新重新安装也不可以，原因是没有删除harbor的数据，harbor数据在/data/目录下边，如果真要重新安装需要将这个也删除，备份或者迁移，请使用这个目录的数据。

 

harbor版本为：1.8.0

官方的安装包为： harbor-offline-installer-v1.8.0.tgz

 

具体步骤：

1、进入[harbor-db]容器内部

   \# docker exec -it harbor-db /bin/bash

 

2、进入postgresql命令行，

   psql -h postgresql -d postgres -U postgres  #这要输入默认密码：root123 。

   psql -U postgres -d postgres -h 127.0.0.1 -p 5432  #或者用这个可以不输入密码。

 

3、切换到harbor所在的数据库

   \# \c registry

 

4、查看harbor_user表

   \# select * from harbor_user;

 

5、例如修改admin的密码，修改为初始化密码Harbor12345 ，修改好了之后再可以从web ui上再改一次。

   \# update harbor_user set password='a71a7d0df981a61cbb53a97ed8d78f3e', salt='ah3fdh5b7yxepalg9z45bu8zb36sszmr'  where username='admin';

 

6、退出 \q 退出postgresql，exit退出容器。

   \# \q 

   \# exit 

 

完成后通过WEB UI，就可以使用admin 、Harbor12345 这个密码登录了，记得修改这个默认密码哦，避免安全问题。

 

有更加狠点的招数，将admin账户改成别的名字，减少被攻击面：

   \# update harbor_user set username='wing' where user_id=1;        #更改admin用户名为wing

 

### DOCKERFILE文件

Dockerfile文件

\# cd /root/jenkins/docker-file/maven-docker-test_war

\# vim Dockerfile

\# Version 1.0

\# Base images. 

FROM tomcat:8.0.36-alpine

 

\# Author.

MAINTAINER wing <276267003@qq.com>

 

\# Add war.

ADD maven-docker-test.war /usr/local/tomcat/webapps/

 

\# Define working directory.

WORKDIR /usr/local/tomcat/bin/

 

\# Define environment variables.

ENV PATH /usr/local/tomcat/bin:$PATH

 

\# Define default command. 

CMD ["catalina.sh", "run"]

 

\# Expose ports.

EXPOSE 8080

 

### HARBOR权限相关

harbor仓库的权限得配置一下，不然curl命令访问不到

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsJ1ICgC.jpg) 

 

### 控制台输出过程

执行中控制台输出

Started by user admin

Building on master in workspace /root/.jenkins/workspace/maven-docker-test

No credentials specified

 \> git rev-parse --is-inside-work-tree # timeout=10

Fetching changes from the remote Git repository

 \> git config remote.origin.url https://github.com/yanqiang20172017/easy-springmvc-maven.git # timeout=10

Fetching upstream changes from https://github.com/yanqiang20172017/easy-springmvc-maven.git

 \> git --version # timeout=10

 \> git fetch --tags --progress https://github.com/yanqiang20172017/easy-springmvc-maven.git +refs/heads/*:refs/remotes/origin/*

 \> git rev-parse refs/remotes/origin/master^{commit} # timeout=10

 \> git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10

Checking out Revision 67604f7f9f30505e3bb3e8935c745154f04aa372 (refs/remotes/origin/master)

 \> git config core.sparsecheckout # timeout=10

 \> git checkout -f 67604f7f9f30505e3bb3e8935c745154f04aa372

Commit message: "修改standard/1.1.2的依赖"

 \> git rev-list --no-walk 67604f7f9f30505e3bb3e8935c745154f04aa372 # timeout=10

Parsing POMs

Established TCP socket on 36798

[maven-docker-test] $ java -cp /root/.jenkins/plugins/maven-plugin/WEB-INF/lib/maven3-agent-1.12.jar:/usr/share/maven/boot/plexus-classworlds.jar org.jvnet.hudson.maven3.agent.Maven3Main /usr/share/maven /root/.jenkins/war/WEB-INF/lib/remoting-3.29.jar /root/.jenkins/plugins/maven-plugin/WEB-INF/lib/maven3-interceptor-1.12.jar /root/.jenkins/plugins/maven-plugin/WEB-INF/lib/maven3-interceptor-commons-1.12.jar 36798

<===[JENKINS REMOTING CAPACITY]===>channel started

Executing Maven:  -B -f /root/.jenkins/workspace/maven-docker-test/pom.xml clean package -Dmaven.test.skip=true

[INFO] Scanning for projects...

[WARNING] 

[WARNING] Some problems were encountered while building the effective model for springmvc-maven:easy-springmvc-maven:war:0.0.1-SNAPSHOT

[WARNING] 'build.plugins.plugin.version' for org.apache.maven.plugins:maven-war-plugin is missing. @ line 22, column 15

[WARNING] 

[WARNING] It is highly recommended to fix these problems because they threaten the stability of your build.

[WARNING] 

[WARNING] For this reason, future Maven versions might no longer support building such malformed projects.

[WARNING] 

[INFO]                                     

[INFO] ------------------------------------------------------------------------

[INFO] Building springmvc-maven 0.0.1-SNAPSHOT

[INFO] ------------------------------------------------------------------------

[INFO] 

[INFO] --- maven-clean-plugin:2.4.1:clean (default-clean) @ easy-springmvc-maven ---

[INFO] Deleting /root/.jenkins/workspace/maven-docker-test/target

[INFO] 

[INFO] --- maven-resources-plugin:2.5:resources (default-resources) @ easy-springmvc-maven ---

[debug] execute contextualize

[INFO] Using 'UTF-8' encoding to copy filtered resources.

[INFO] skip non existing resourceDirectory /root/.jenkins/workspace/maven-docker-test/src/main/resources

[INFO] 

[INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ easy-springmvc-maven ---

[INFO] Changes detected - recompiling the module!

[INFO] Compiling 2 source files to /root/.jenkins/workspace/maven-docker-test/target/classes

[INFO] 

[INFO] --- maven-resources-plugin:2.5:testResources (default-testResources) @ easy-springmvc-maven ---

[debug] execute contextualize

[INFO] Using 'UTF-8' encoding to copy filtered resources.

[INFO] skip non existing resourceDirectory /root/.jenkins/workspace/maven-docker-test/src/test/resources

[INFO] 

[INFO] --- maven-compiler-plugin:3.1:testCompile (default-testCompile) @ easy-springmvc-maven ---

[INFO] Not compiling test sources

[INFO] 

[INFO] --- maven-surefire-plugin:2.10:test (default-test) @ easy-springmvc-maven ---

[INFO] Tests are skipped.

[WARNING] Attempt to (de-)serialize anonymous class hudson.maven.reporters.BuildInfoRecorder$1; see: https://jenkins.io/redirect/serialization-of-anonymous-classes/

[INFO] 

[INFO] --- maven-war-plugin:2.1.1:war (default-war) @ easy-springmvc-maven ---

[INFO] Packaging webapp

[INFO] Assembling webapp [easy-springmvc-maven] in [/root/.jenkins/workspace/maven-docker-test/target/easy-springmvc-maven]

[INFO] Processing war project

[INFO] Copying webapp resources [/root/.jenkins/workspace/maven-docker-test/src/main/webapp]

[INFO] Webapp assembled in [43 msecs]

[INFO] Building war: /root/.jenkins/workspace/maven-docker-test/target/easy-springmvc-maven.war

[INFO] WEB-INF/web.xml already added, skipping

[INFO] ------------------------------------------------------------------------

[INFO] BUILD SUCCESS

[INFO] ------------------------------------------------------------------------

[INFO] Total time: 2.647s

[INFO] Finished at: Sun Jun 09 16:12:01 CST 2019

[INFO] Final Memory: 19M/189M

[INFO] ------------------------------------------------------------------------

Waiting for Jenkins to finish collecting data

[JENKINS] Archiving /root/.jenkins/workspace/maven-docker-test/pom.xml to springmvc-maven/easy-springmvc-maven/0.0.1-SNAPSHOT/easy-springmvc-maven-0.0.1-SNAPSHOT.pom

[JENKINS] Archiving /root/.jenkins/workspace/maven-docker-test/target/easy-springmvc-maven.war to springmvc-maven/easy-springmvc-maven/0.0.1-SNAPSHOT/easy-springmvc-maven-0.0.1-SNAPSHOT.war

[maven-docker-test] $ /bin/sh -xe /tmp/jenkins6873694180184993727.sh

channel stopped

\+ JENKINS_WAR_HOME=/root/.jenkins/workspace/maven-docker-test/target

\+ DOCKERFILE_HOME=/root/jenkins/docker-file/maven-docker-test_war

\+ HARBOR_IP=172.22.211.175

\+ REPOSITORIES=jenkins/maven-docker-test

\+ HARBOR_USER=wing

\+ HARBOR_USER_PASSWD=Harbor12345

\+ HARBOR_USER_EMAIL=276267003@qq.com

\+ cp -f /root/.jenkins/workspace/maven-docker-test/target/easy-springmvc-maven.war /root/jenkins/docker-file/maven-docker-test_war/maven-docker-test.war

\+ sudo docker login -u wing -p Harbor12345 172.22.211.175

WARNING! Using --password via the CLI is insecure. Use --password-stdin.

WARNING! Your password will be stored unencrypted in /root/.docker/config.json.

Configure a credential helper to remove this warning. See

https://docs.docker.com/engine/reference/commandline/login/#credentials-store

 

Login Succeeded

++ sudo docker images

++ grep jenkins/maven-docker-test

++ awk '{print $3}'

\+ IMAGE_ID=a6676d1090aa

\+ '[' -n a6676d1090aa ']'

\+ sudo docker rmi a6676d1090aa

Untagged: 172.22.211.175/jenkins/maven-docker-test:20190609-153307

Untagged: 172.22.211.175/jenkins/maven-docker-test@sha256:a0dbff5acc2284554aef955e32cb3325b0716c13ec66ec70b0705fe17d425d8b

Deleted: sha256:a6676d1090aa51212861be156d81e2e96ab7ffb8ace2f8e4428debd1404ba8dd

Deleted: sha256:675a50c43c8b6b890dd86f9ef7958f849956d922735a3a721741af7bfcc0a50d

Deleted: sha256:fb5bd69c508668d13c4da89770d8c54fbc7e330c45543a80be52dc94a021730e

Deleted: sha256:7e47412dc00e4b0e753cf076ac4b97bbc972c524aeae4243ef4c441a7bf9d8e4

Deleted: sha256:2e6bb2e854e3a6d14b35797198758503dcd924a1c365e653daef5708659f3b6c

Deleted: sha256:e036e0839cbd1676552163ab0001e9e968ef924d2d17b0b7eee245ce29f35f6b

Deleted: sha256:1f35ccae7e2fec67145bd7b3f8b50d7f0a66f3386cc1d444136e24c8ef667763

\+ cd /root/jenkins/docker-file/maven-docker-test_war

++ date +%Y%m%d-%H%M%S

\+ TAG=20190609-161201

\+ sudo docker build -t 172.22.211.175/jenkins/maven-docker-test:20190609-161201 .

\+ sudo docker push 172.22.211.175/jenkins/maven-docker-test:20190609-161201

[SSH] script:

USER="root"

 

\# 拉取镜像，发布

HARBOR_IP='172.22.211.175'

REPOSITORIES='jenkins/maven-docker-test'

HARBOR_USER='wing'

HARBOR_USER_PASSWD='Harbor12345'

 

\# 登录harbor

docker login -u ${HARBOR_USER} -p ${HARBOR_USER_PASSWD} ${HARBOR_IP}

 

\# Stop container, and delete the container.

CONTAINER_ID=`docker ps | grep "maven-docker-test" | awk '{print $1}'`

if [ -n "$CONTAINER_ID" ]; then

  docker stop $CONTAINER_ID

  docker rm $CONTAINER_ID

else #如果容器启动时失败了，就需要docker ps -a才能找到那个容器

  CONTAINER_ID=`docker ps -a | grep "maven-docker-test" | awk '{print $1}'`

  if [ -n "$CONTAINER_ID" ]; then  # 如果是第一次在这台机器上拉取运行容器，那么docker ps -a也是找不到这个容器的

​    docker rm $CONTAINER_ID

  fi

fi

 

\# Deleteeasy-springmvc-maven image early version.

IMAGE_ID=`sudo docker images | grep ${REPOSITORIES} | awk '{print $3}'`

if [ -n "${IMAGE_ID}" ];then

  docker rmi ${IMAGE_ID}

fi

 

\# Pull image.

\# TAG=`curl -s http://${HARBOR_IP}/api/repositories/${REPOSITORIES}/tags | jq '.[-1]' | sed 's/\"//g'` 

TAG=`curl -s http://172.22.211.175/api/repositories/jenkins/maven-docker-test/tags | jq '.[-1]| {name:.name}' | awk -F '"' '/name/{print $4}'`

docker pull ${HARBOR_IP}/${REPOSITORIES}:${TAG} &>/dev/null

 

\# Run.

docker run -d --name maven-docker-test -p 8080:8080 ${HARBOR_IP}/${REPOSITORIES}:${TAG}

 

[SSH] executing...

WARNING! Using --password via the CLI is insecure. Use --password-stdin.

WARNING! Your password will be stored unencrypted in /root/.docker/config.json.

Configure a credential helper to remove this warning. See

https://docs.docker.com/engine/reference/commandline/login/#credentials-store

 

Login Succeeded

afa55c8e5fe64bc2f652fdc3813f077173baff4e8cfd4301c5c49c75bdb3d953

[SSH] completed

[SSH] exit-status: 0

 

Finished: SUCCESS

 

## JENKINS安装

wing测试成功

 

官方文档安装方法

 

官方WAR文件

Jenkins的Web应用程序ARchive（WAR）文件版本可以安装在任何支持Java的操作系统或平台上。

 

要下载并运行Jenkins的WAR文件版本，请执行以下操作:

 

将最新的稳定Jenkins WAR包 下载到您计算机上的相应目录。

 

在下载的目录内打开一个终端/命令提示符窗口到。

 

运行命令java -jar jenkins.war

 

浏览http://localhost:8080并等到*Unlock Jenkins

 

 

用户名：admin

密码：ld

 

## JENKINS流水线基本介绍

什么是Pipeline

 

​    Jenkins Pipeline是一组插件，支持在Jenkins上实现和集成持续交付的管道。Pipeline这个单词是水管的意思。我以后可能会翻译成管道或者流水线，我建议大家不要翻译，就写Pipeline。这里持续集成（CI）和持续交付（CD）

​    Jenkins为了更好支持CI和CD，通过Groovy语言这么DSL（动态描述语言）来开发Pipeline组件。在Jenkins中有一句话，Pipeline as code，Pipeline是Jenkins中最优雅的存在。之前Jenkins上UI操作动作，都可以在Pipeline中代码实现，主要你对Jenkins和Groovy语言有足够多掌握。

 

​    以后说CI Pipeline和CD Pipeline，你现在大致可以理解为，要实现CD，先要实现CI。CD Pipeline就是一个代码文件，里面把你项目业务场景都通过Groovy代码和Pipeline语法实现，一个一个业务串联起来，全部实现自动化，从代码仓库到生产环境完成部署的自动化流水线。这个过程就是一个典型的CD Pipeline

 

​    官网建议把Pipeline代码放在一个名称为Jenkinsfile的文本文件中，并且把这个文件放在你项目代码的根目录，采用版本管理工具管理。Jenkinsfile我后面会具体例子来介绍。当然，也可以把Pipeline代码用一个Hello.groovy这样的文件去保存在代码库，这也是没问题的。

 

 Pipeline代码分类和两者区别

 

​    一个Jenkinsfile或者一个Pipeline代码文件，我们可以使用两个脚本模式去写代码，这两种分类叫：Declarative Pipeline 和 Scripted Pipeline. 现在来介绍下两者脚本模式的区别，Declarative相对于Scripted有两个优点。第一个是提供更丰富的语法功能，第二个是写出来的脚本可读性和维护性更好。接下里我们学习的Pipeline语法，其中一部分语法只能在Declarative模式下使用，并不支持Scripted模式。虽然，我在后面文章也会用Declarative和Script两个模式去写同一个场景的Pipeline代码，但是，作为一个初学者，我建议选择并采用Declarative的方式去组织Pipeline代码。

 

为什么要选择使用Pipeline

 

​    现在Jenkins是一个非常著名的CI服务器平台，支持很多不同第三方（插件的形式）集成自动化测试。Jenkins UI 配置已经满足不了这么复杂的自动化需求，加入Pipeline功能之后，Jenkins 表现更强大，Pipeline主要有一下特点。

 

代码：Pipeline是用代码去实现，并且支持check in到代码仓库，这样项目团队人员就可以修改，更新Pipeline脚本代码，支持代码迭代。

 

耐用：Pipeline支持在Jenkins master(主节点)上计划之内或计划外的重启下也能使用。

 

可暂停：Pipeline支持可选的停止和恢复或者等待批准之后再跑Pipeline代码。

 

丰富功能：Pipeline支持复杂和实时的CD需求，包括循环，拉取代码，和并行执行的能力。

 

可扩展性：Pipeline支持DSL的自定义插件扩展和支持和其他插件的集成。

 

   上面这段话提到的"主节点"，"批准" 会后续用具体例子介绍。这个可扩展性，可能我没法实现，暂时没有研究这么深入。CD Pipeline和CI Pipeline可以添加到代码仓库管理，通过下面这个CD Pipeline的流程图，知道一个CD流程大致包含这些业务场景。

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsnXIyZZ.jpg) 

 

 

 

\1. 开发提交代码到项目仓库服务器

\2. 开始执行Pipeline代码文件，开始从仓库check out代码

\3. 启动Pipeline里面第一个stage，stage就是阶段的意思，后面会介绍语法

\4. 图里面第一个Stage是代码打包构建（Build）

\5. 然后进入测试的阶段，执行各种自动化测试验证

\6. 然后测试结束，到运维的部署阶段。

\7. 部署结束，输出报告，整个自动化流程工作完成，等待触发构建，开始重复下一轮1到7步骤。

 

## JENKINS流水线核心概念

pipeline

 

​    这个单词是小写，可以看作是Pipeline语法中的一个关键字。以后一个groovy文件或者一个Jenkinsfile文件中不光只有Pipeline代码，例如还有其他的工具类方法等。通过pipeline { Pipeline代码}，这个关键字就是告诉Jenkins接下来{}中的代码就是pipeline代码，和普通的函数或者方法隔离出来。

 

node

 

​    关键字node就是用来区分，Jenkins环境中不同的节点环境。例如一个Jenkins环境包括master节点，也就是主节点，还包括N多个从节点，这些从节点在添加到主节点的向导页面中有一个参数，好像是label，就是给这个从节点取一个名称。在Pipeline代码中可以通过node这个关键字告诉Jenkins去用哪一台节点机器去执行代码。

 

stage

 

​    关键字stage，就是一段代码块，一般个stage包含一个业务场景的自动化，例如build是一个stage, test是第二个stage，deploy是第三个stage。通过stage隔离，让Pipeline代码读写非常直观。到后面你还会学习stages这个关键字，一个stages包含多个stage。

 

step

 

​    关键字step就是一个简单步骤，一般就是几行代码或者调用外部一个模块类的具体功能。这里step是写在stage的大括号里的。

 

 

## 第一个PIPELINE代码

wing测试成功

 

1.前提条件准备

 

1）准备一个Jenkins环境

直接官方方式安装jenkins到一个Linux上，安装好了Jenkins,还需要安装Groovy，以及Git,还有后面也需要安装Python环境。因为Pipleline里面需要写一部分Groovy代码，所以需要安装Groovy运行环境，安装Python也是基于这个原因。

 

注：

  后面代码中打印语句代码用了Groovy的语法，如果你jenkins机器没有安装Groovy，就会报错，构建失败。

 

2) 准备一个Github账号和代码仓库

Jenkins每次构建之前一般都需要去check out代码，所以我们项目练习代码放在github上

 

2.在Jenkins上创建一个Pipeline项目

创建一个Pipeline Job

(注：安装Jenkins的向导过程中，选择默认的插件安装，就会有Pipeline组件)

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsgwYAIn.jpg) 

 

3.不集成Github的Pipeline代码

 

这种方式，直接把写好的Pipeline代码拷贝到Pipeline对应的Jenkins页面上，经常用这个方式来进行本地Debug和单元测试。

 

选择上面创建好的这个Pipeline Job，点击Confige, 到达配置界面，点击Pipeline,然后把代码帖进去，点击保存

 

pipeline {

  agent any 

  stages {

​    stage('Build') { 

​      steps {

​        println "Build" 

​      }

​    }

​    stage('Test') { 

​      steps {

​        println "Test" 

​      }

​    }

​    stage('Deploy') { 

​      steps {

​        println "Deploy" 

​      }

​    }

  }

 }  

 

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsBcjJrL.jpg) 

上面这个Pipeline模式就是一个典型的Declarative类型，先不管上面具体语法，点击保存，然后点击Build Now，看看控制台日志，会发生什么。

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps1XLUa9.jpg) 

 

下面继续来看Script模式，修改第一个项目并粘贴如下代码：

node {

  stage('Build') { 

​    println "Build" 

  }

  stage('Test') { 

 

​    println "Test" 

  }

  stage('Deploy') { 

​    println "Deploy" 

  }

}

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsS30aUw.jpg) 

 

点击保存，然后点击Build Now,继续看#2(我第一次构建失败，所以截图是#3)的job的控制台。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps0yLtDU.jpg) 

从日志结果来看，第二种Scripted Pipeline代码也成功运行，得到了正确的结果

 

4.集成Github，把Pipeline代码放到Jenkinsfile文件中

这种方式正是开发中使用的场景，任何Pipeline和业务代码一样需要添加到代码仓库。这里我们模仿git，只写Declarative的模式，以后都使用Declarative模式的Pipeline代码。

 

wing准备好的github项目地址：

  https://github.com/yanqiang20172017/jenkins.git

  帐号：yanqiang20172017

  密码：常用33

 

github项目如下：

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps1ykQmi.jpg) 

  ![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsdFwf6F.jpg)

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wps0vJGP3.jpg) 

项目中只有一个Jenkinsfile文本文件，里面写的是Declarative模式的Pipeline代码。

下面，继续使用上面创建好的Job，到Configure页面，选择如下图的git拉取Pipeline代码。

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsLKwazr.jpg) 

 

 

注：

软件配置管理（Software Configuration Management，SCM）

 

成功控制台输出

Started by user admin

Obtained Jenkinsfile from git https://github.com/yanqiang20172017/jenkins.git

Running in Durability level: MAX_SURVIVABILITY

[Pipeline] Start of Pipeline

[Pipeline] node

Running on Jenkins in /root/.jenkins/workspace/Pipeline-demo-01

[Pipeline] {

[Pipeline] stage

[Pipeline] { (Declarative: Checkout SCM)

[Pipeline] checkout

using credential 2b880cbd-e6e0-4a41-a4ba-ebf2cbcdd88e

Cloning the remote Git repository

Cloning repository https://github.com/yanqiang20172017/jenkins.git

 \> git init /root/.jenkins/workspace/Pipeline-demo-01 # timeout=10

Fetching upstream changes from https://github.com/yanqiang20172017/jenkins.git

 \> git --version # timeout=10

using GIT_ASKPASS to set credentials 

 \> git fetch --tags --progress https://github.com/yanqiang20172017/jenkins.git +refs/heads/*:refs/remotes/origin/*

 \> git config remote.origin.url https://github.com/yanqiang20172017/jenkins.git # timeout=10

 \> git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* # timeout=10

 \> git config remote.origin.url https://github.com/yanqiang20172017/jenkins.git # timeout=10

Fetching upstream changes from https://github.com/yanqiang20172017/jenkins.git

using GIT_ASKPASS to set credentials 

 \> git fetch --tags --progress https://github.com/yanqiang20172017/jenkins.git +refs/heads/*:refs/remotes/origin/*

 \> git rev-parse refs/remotes/origin/master^{commit} # timeout=10

 \> git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10

Checking out Revision 381d0744213a32baf5eb2468ba8a99236cc30b2f (refs/remotes/origin/master)

 \> git config core.sparsecheckout # timeout=10

 \> git checkout -f 381d0744213a32baf5eb2468ba8a99236cc30b2f

Commit message: "Update Jenkinsfile"

First time build. Skipping changelog.

[Pipeline] }

[Pipeline] // stage

[Pipeline] withEnv

[Pipeline] {

[Pipeline] stage

[Pipeline] { (Build)

[Pipeline] echo

Build

[Pipeline] }

[Pipeline] // stage

[Pipeline] stage

[Pipeline] { (Test)

[Pipeline] echo

Test

[Pipeline] }

[Pipeline] // stage

[Pipeline] stage

[Pipeline] { (Deploy)

[Pipeline] echo

Deploy

[Pipeline] }

[Pipeline] // stage

[Pipeline] }

[Pipeline] // withEnv

[Pipeline] }

[Pipeline] // node

[Pipeline] End of Pipeline

Finished: SUCCESS

 

这种代码拉取，执行文件的方式，运行结果也是成功，以后基本上都是使用这个方式。

 

总结：

回到Jenkins job上查看整体构建情况，以下这种图就是Pipeline的优点之一，每个stage或者叫阶段都干了什么事情，是成功还是失败，每个stage都可以看到日志。

 

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsOUdLiP.jpg) 

 

 

 

## 第一个PIPELINE代码详解

每行代码的含义

1.Declarative代码

pipeline {

  agent any 

  stages {

​    stage('Build') { 

​      steps {

​        println "Build" 

​      }

​    }

​    stage('Test') { 

​      steps {

​        println "Test" 

​      }

​    }

​    stage('Deploy') { 

​      steps {

​        println "Deploy" 

​      }

​    }

  }

}

 

解释：

​    上面是一个Declarative（声明式）类型的Pipeline，基本上实际开发都采用这个。虽然Scripted(脚本式)模式的Pipeline代码行数精简，很短，上面Declarative有20行代码，如果用Scripted模式，就10行代码。但是Scripted脚本很灵活，不好写，也不好读，维护起来相对困难。

 

1）第一行是小写pipeline，然后一对大括{}，学习过代码的人都知道，大括号里面就是代码块，用来和别的代码块隔离出来。pipeline是一个语法标识符，也叫关键字。如果是Declarative类型，一定是pipeline {}这样起头的。当然脚本文件，pipeline不要求一定是第一行代码。也就是说pipeline前面可以有其他代码，例如导入语句，和其他功能代码。pipeline是一个执行pipeline代码的入口，jenkins可以根据这个入口开始执行里面不同stage

 

2）第二行agent any，agent是一个语法关键字，any是一个option类型。agent是代理的意思，这个和选择用jenkins平台上那一台机器去执行任务构建有关。我jenkins只有一个master节点，没有添加第二个节点机器，后面专门学习agent这个指令的时候，再来介绍如何添加一个节点。等添加了新节点，这个地方就可以选择用master还是一个从节点机器来执行任务，所以any是指任意一个可用的机器，当然这里就是master。

 

3）第三行stages{}, stages是多个stage的意思，也就是说一个stages可以包含多个stage。上面写了三个stage，根据你任务需要，你随意写多少个都可以。

 

4）第四行stage('Build') {}, 这个就是具体定义一个stage,一般一个stage就是指完成一个业务场景。'Build'是人为给这个任务取一个名字。这个名称可以出现在Jenkins任务的页面上，可以看到在上一节文章结尾处的图片显示着三个stage的名称，分别是Build,Test，和Deploy。

 

5）第五行steps{},字面意思就是很多个步骤的意思。当然还有step这个指令。一般来说，一个steps{}里面就写几行代码，或者一个try catch语句。

 

6）第六行，这个地方可以定义变量，写调用模块代码等。这里，我就用Groovy语法，写了一个打印语句。如果你机器没有安装groovy，你安装了python，你可以写python的打印语句，或者用linux的shell，例如sh "echo $JAVA_HOME"，比如下面的例子（wing已测试）

pipeline {

  agent any 

  stages {

​    stage('Build') { 

​      steps {

​        print("Build")     //python

​      }

​    }

​    stage('Test') { 

​      steps {

​        echo "Test"       //bash

​      }

​    }

​    stage('Deploy') { 

​      steps {

​        println "Deploy"   //groovy

​      }

​    }

  }

}

 

​    后面的stage含义就是一样的，上面写了三个state,描述了三个业务场景，例如打包build,和测试Test,以及部署，这三个串联起来就是一个典型的CD Pipeline流程。实际的肯定不是这么写，因为Test就包含很多个阶段，和不同测试类型。这些不同测试类型，都可以细分成很多个stage去完成。

 

2.Scripted模式代码

 

node {  

  stage('Build') { 

​    // 

  }

  stage('Test') { 

​    // 

  }

  stage('Deploy') { 

​    // 

  }

}

这个代码，有两点和上面不同:

  第一个是Scripted模式是node{}开头，并没有pipeline{},这个区别好知道。

  第二个是scripted模式下没有stages这个关键字或者指令，只有stage。上面其实可以node('Node name') {}来开头，Node name就是从节点或master节点的名称。

 

注释语法:

  由于pipeline是采用groovy语言设计的，而groovy是依赖java的，所以上面//表示注释的意思。

 

 

## DECLARATIVE PIPELINE详解

wing测试成功

 

\1. Pipeline语法引用官网地址

接下来的Pipeline语法和部分练习代码都来自官网，地址是：https://jenkins.io/doc/book/pipeline/syntax/

 

\2. Declarative Pipeline概述

 

所有有效的Declarative Pipeline必须包含在一个pipeline块内，例如：

 

pipeline {

 

  /* insert Declarative Pipeline here */

 

}

 

Declarative Pipeline中有效的基本语句和表达式遵循与Groovy语法相同的规则 ，但有以下例外：

\1. Pipeline的顶层必须是块，具体来说是：pipeline { }

\2. 没有分号作为语句分隔符。每个声明必须在自己的一行

\3. 块只能包含章节， 指令，步骤或赋值语句。

\4. 属性引用语句被视为无参数方法调用。所以例如，input被视为input（）

 

第一点，前面解释过，就是一个代码块范围的意思，很好理解。

第二点，以后可能经常会犯这个错，分号写了也是多余的。Groovy代码可以写分号，Jenkins Pipeline代码就不需要，每行只写一个声明语句块或者调用方法语句。

第三点，只能包含Sections, Directives, Steps或者赋值语句，其中的Sections 和Directives后面语法会解释。指令和步骤，前面介绍过，例如steps, stage, agent等。

最后点，即关键字会被识别成无参方法调用

 

\3. sections

 

Declarative Pipeline 代码中的Sections指的是必须包含一个或者多个指令或者步骤的代码区域块。Sections不是一个关键字或者指令，只是一个逻辑概念。

 

4.agent

 

该agent部分指定整个Pipeline或特定阶段将在Jenkins环境中执行的位置，具体取决于该agent 部分的放置位置。该部分必须在pipeline块内的顶层定义 ，但阶段级使用是可选的。

 

agent部分主要作用就是告诉Jenkins，选择那台节点机器去执行Pipeline代码。这个指令是必须要有的，也就在你顶层pipeline {…}的下一层，必须要有一个agent{…}

 

注意：

  在具体某一个stage {…}里面也可以使用agent指令。这种用法不多，一般在顶层使用agent，这样，接下来的全部stage都在一个agent机器下执行代码。

 

为了支持Pipeline作者可能拥有的各种用例，该agent部分支持几种不同类型的参数。这些参数可以应用于pipeline块的顶层，也可以应用在每个stage指令内。

 

agent指令对应有多个可选参数：

 

参数1：any

 

作用：

  在任何可用的代理上执行Pipeline或stage。

 

代码示例：

pipeline {

  agent any

}

 

上面这种是最简单的，如果你Jenkins平台环境只有一个master，那么这种写法就最省事.

 

参数2：none

 

作用：

  当在pipeline块的顶层应用时，将不会为整个Pipeline运行分配全局代理，并且每个stage部分将需要包含其自己的agent部分。

 

代码示例：

 

pipeline {

  agent none

  stages {

​    stage('Build'){

​	  agent {

​        label '具体的节点名称'

​      }

​    }

  }

}

 

参数3：label

 

作用：

  使用提供的标签在Jenkins环境中可用的代理机器上执行Pipeline或stage内执行。

 

代码示例：

 

pipeline {

  agent {

​    label '具体一个节点label名称'

  }

}

 

参数4：node

 

作用：和上面label功能类似，但是node运行其他选项，例如customWorkspace

 

代码示例：

 

pipeline {

  agent {

​    node {

​      label 'xxx-agent-机器'

​      customWorkspace "${env.JOB_NAME}/${env.BUILD_NUMBER}"

​    }

  }

}

 

目前，这种node类型的agent代码块，在实际工作中是使用最多的一个场景。建议你分别测试下有和没有customWorkspace的区别，前提你要有自己Jenkins环境，能找到"${env.JOB_NAME}/${env.BUILD_NUMBER}"这个具体效果。

 

其实agent相关的还有两个可选参数，分别是docker和dockerfile。目前，不把docker加入进来，给我们学习Pipeline增加复杂度。但是docker又是很火的一个技术栈，以后如果你项目中需要docker，请去官网找到这两个参数的基本使用介绍。

 

 

如果你认真花了时间在前面章节，那么你就知道如何测试上面的每一段代码。你可以在Jenkins UI上贴上面代码，也可以写入jenkinsfile，走github拉取代码。下面，我写一个测试代码，结合上面node的代码，放在Jenkins UI上进行测试。

 

代码如下：

 

pipeline {

  agent {

​    node {

​      label 'xxx-agent-机器'

​      customWorkspace "${env.JOB_NAME}/${env.BUILD_NUMBER}"

​    }

  }

  stages {

​    stage ('Build') {

​      bat "dir" // 如果jenkins安装在windows并执行这部分代码

​      sh "pwd"  //这个是Linux的执行

​    }

 

​    stage ('Test') {

​      bat "dir" // 如果jenkins安装在windows并执行这部分代码

​      sh "echo ${JAVA_HOME}"  //这个是Linux的执行

​    }

 

  }

}

拷贝上面代码在Jenkins job的pipeline设置页面，保存，启动测试。

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpswwXC2c.jpg) 

 

 

我上面的截图中少写了一个大括号

 

运行结果：

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsReqxMA.jpg) 

 

注意 :以上代码的agent中label的值，如果你不会配置在Jenkins上添加节点，那么你就改成agent any来跳过这部分，后面我会写一篇文章介绍，如何在Jenkins上添加一个agent节点的详细过程。

 

 

## 添加JENKINS-SLAVE节点

wing测试成功

 

 Jenkins的分布式构建，在Jenkins的配置中叫做节点，分布式构建能够让同一套代码或项目在不同的环境(如：Windows和Linux系统)中编译、部署等。 节点服务器不需要安装jenkins（只需要运行一个slave节点服务），构建事件的分发由master端（jenkins主服务）来执行。

 

\1. 在master上配置到slave节点的ssh无密码登陆

\2. 为子节点添加一个Credentials(ssh方式的)

\3. 在slave节点yum安装java groovy git,在slave上创建一个工作目录/jenkins-workspace

\4. 节点管理-->添加节点(labels添加k8s-node2,工作目录添加/jenkins-workspace)

 

将pipeline内的node节点改成k8s-node2,进行测试

![img](kubernets%E5%85%A8%E8%A7%A3.assets/wpsxIRvwY.jpg) 

 

## 使用MAVEN构建JAVA应用程序

 

 

## 终端SSH连接ALIYUN会话保持设置

\#vim /etc/ssh/sshd_config

找到以下两项配置

 

\#ClientAliveInterval 0

\#ClientAliveCountMax 3

 

修改为

ClientAliveInterval 30

ClientAliveCountMax 86400

1、客户端每隔多少秒向服务发送一个心跳数据

 

2、客户端多少秒没有响应，服务器自动断掉连接

 

\#systemctl restart sshd

 

 

## JENKINS排错

wing亲测（环境为aliyun）

在向Jenkins发送请求时收到错误信息：

No valid crumb was included in the request

 

在系统管理 –> Configure Global Security中调整设置：

取消“防止跨站点请求伪造（Prevent Cross Site Request Forgery exploits）”的勾选。

 

 


```

```