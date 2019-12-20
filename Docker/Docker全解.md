# 容器介绍

  容器其实是一种沙盒技术。顾名思义，沙盒就是能够像一个集装箱一样，把你的应用"装"起来的技术。这样，应用与应用之间，就因为有了边界而不至于相互干扰；而被装进集装箱的应用，也可以被方便地搬来搬去，这其实是 PaaS 最理想的状态。

  问题：容器的本质到底是什么？

  `容器的本质是进程`。容器就是未来云计算系统中的进程；容器镜像就是这个系统里的".exe"安装包。Kubernetes 就是操作系统！

docker 安装

Docker介绍：

官网：

  docker.io

  docker.com

  公司名称：原名dotCloud  14年改名为docker

  容器产品：docker 16年已经被更名为Moby

  docker-hub

​    docker.io

 

容器

web容器 web中间件 

​    html (nginx apache )

​      php (php模块  php-fpm)

​      java（tomcat weblogic Resin JBoss  WebSphere ） 

​      python (uwsgi)  web server gateway interface

​    

nginx+tomcat+jdk weblogic

nginx+(nginx+php-fpm)

nginx+uwsgi+django

mycat  mysql-proxy 数据库中间件       

​           

rd

1. 部署开发环境  单机环境

  2. 软件开发

3. 测试

4. 打包

  

op      

  1. 测试环境  

  2. 线上环境（上线工具 u盘 ftp scp rsync svn git github gitlab ci/cd+容器平台:git+jenkins+jdk+maven+tomcat+容器镜像库服务器+k8s集群 ）

 

dba

​                                 

运维

1.rd开发产品（需要配置开发环境）lamp

2.测试(需要配置测试环境)

3.op上线（需要线上环境）

开发 测试  运维  开战

 

1. rd开发产品（需要在docker容器里配置开发环境）    

2. 把容器打包成镜像交给运维，运维上线    

​           

docker使得应用开发者和运维工程师可以以统一的方式跨平台发布应用，并且以几乎没有额外开销的情况下提供资源隔离的应用运行环境。

 

容器就像是轻量级的虚拟机，并且可以以毫秒级的速度来启动或停止。Docker 帮助系统管理员和程序员在容器中开发应用程序，并且可以扩展到成千上万的节点。

 

## Docker跟原有的工具区别：

传统的部署模式是：安装(包管理工具或者源码包编译)->配置->运行；

Docker的部署模式是：复制->运行。

 

## 容器和 VM 的主要区别

1. 容器提供了基于进程的隔离，而虚拟机提供了资源的完全隔离。

2. 虚拟机可能需要一分钟来启动，而容器只需要一秒钟或更短。

3. 容器使用宿主操作系统的内核，而虚拟机使用独立的内核。

4. Docker 的局限性之一是，它只能用在 64 位的操作系统上。

5. 容器只是一个进程，而虚拟机不是

6. 容器占用内存低 虚拟机占用内存偏高

## Docker对服务器端开发/部署带来的变化

实现更轻量级的虚拟化，方便快速部署

对于部署来说可以极大的减少部署的时间成本和人力成本

Docker支持将应用打包进一个可以移植的容器中，重新定义了应用开发，测试，部署上线的过程，核心理念就是 Build once, Run anywhere

1）标准化应用发布，docker容器包含了运行环境和可执行程序，可以跨平台和主机使用；

2）节约时间，快速部署和启动，VM启动一般是分钟级，docker容器启动是秒级；

3）方便构建基于SOA架构或微服务架构的系统，通过服务编排，更好的松耦合；

4）节约成本，以前一个虚拟机至少需要几个G的磁盘空间，docker容器可以减少到MB级；

5）方便持续集成，通过与代码进行关联使持续集成非常方便；

6）可以作为集群系统的轻量主机或节点，在IaaS平台上，已经出现了CaaS，通过容器替代原来的主机。

## Docker 优势

1、**交付物标准化**

Docker是软件工程领域的"标准化"交付组件，最恰到好处的类比是"集装箱"。

集装箱将零散、不易搬运的大量物品封装成一个整体，集装箱更重要的意义在于它提供了一种通用的封装货物的标准，卡车、火车、货轮、桥吊等运输或搬运工具采用此标准，隧道、桥梁等也采用此标准。以集装箱为中心的标准化设计大大提高了物流体系的运行效率。

传统的软件交付物包括：应用程序、依赖软件安装包、配置说明文档、安装文档、上线文档等非标准化组件。

Docker的标准化交付物称为"镜像"，它包含了应用程序及其所依赖的运行环境，大大简化了应用交付的模式。

2、**一次构建，多次交付**

类似于集装箱的"一次装箱，多次运输"，Docker镜像可以做到"一次构建，多次交付"。当涉及到应用程序多副本部署或者应用程序迁移时，更能体现Docker的价值。 

3、**应用隔离**

集装箱可以有效做到货物之间的隔离，使化学物品和食品可以堆砌在一起运输。Docker可以隔离不同应用程序之间的相互影响，但是比虚拟机开销更小。总之，容器技术部署速度快，开发、测试更敏捷；提高系统利用率，降低资源成本。

## Docker的度量

Docker是利用容器来实现的一种`轻量级的虚拟技术`，从而在保证隔离性的同时达到节省资源的目的。Docker的可移植性可以让它一次建立，到处运行。Docker的度量可以从以下四个方面进行：

1）**隔离性**

 Docker采用libcontainer作为默认容器，代替了以前的LXC。libcontainer的隔离性主要是通过内核的命名空间来实现 的，有`pid、net、ipc、mnt、uts`命令空间，将容器的进程、网络、消息、文件系统和主机名进行隔离。

2）**可度量性**

 Docker主要通过cgroups控制组来控制资源的度量和分配。

3）**移植性**

 Docker利用AUFS来实现对容器的快速更新。AUFS是一种支持将不同目录挂载到同一个虚拟文件系统下的文件系统，支持对每个目录的读写权限管理。AUFS具有层的念，每一次修改都是在已有的只写层进行增量修改，修改的内容将形成新的文件层，不影响原有的层。

4）**安全性**

 安全性可以分为容器内部之间的安全性；容器与托管主机之间的安全性。

 容器内部之间的安全性主要是通过命名空间和cgroups来保证的。

 容器与托管主机之间的安全性主要是通过内核能力机制的控制，可以防止Docker非法入侵托管主机。

#### Docker容器使用AUFS作为文件系统，有如下优势

1）**节省存储空间**

 多个容器可以共享同一个基础镜像存储。

2）**快速部署**

 如果部署多个来自同一个基础镜像的容器时，可以避免多次复制操作。

3）**升级方便**

 升级一个基础镜像即可影响到所有基于它的容器。

4）**增量修改**

 可以在不改变基础镜像的同时修改其目录的文件，所有的更高都发生在最上层的写操作层，增加了基础镜像的可共享内容。

# docker容器历史

PaaS:

 从过去以物理机和虚拟机为主体的开发运维环境，向以容器为核心的基础设施的转变过程，并不是一次温和的改革，而是涵盖了对网络、存储、调度、操作系统、分布式原理等各个方面的容器化理解和改造。

 2013 年的后端技术领域，已经太久没有出现过令人兴奋的东西了。曾经被人们寄予厚望的云计算技术，也已经从当初虚无缥缈的概念蜕变成了实实在在的虚拟机和账单。而相比于如日中天 AWS 和盛极一时的 OpenStack，以 Cloud Foundry 为代表的开源 PaaS 项目，却成为了当时云计算技术中的一股清流。

 当时，Cloud Foundry 项目已经基本度过了最艰难的概念普及和用户教育阶段，吸引了包括百度、京东、华为、IBM 等一大批国内外技术厂商，开启了以开源 PaaS 为核心构建平台层服务能力的变革。如果你有机会问问当时的云计算从业者们，他们十有八九都会告诉你：PaaS 的时代就要来了！这个说法其实一点儿没错，如果不是后来一个叫 Docker 的开源项目突然冒出来的话。

 事实上，当时还名叫 dotCloud 的 Docker 公司，也是这股 PaaS 热潮中的一份子。只不过相比于 Heroku、Pivotal、Red Hat 等 PaaS 弄潮儿们，dotCloud 公司实在是太微不足道了，而它的主打产品由于跟主流的 Cloud Foundry 社区脱节，长期以来也无人问津。眼看就要被如火如荼的 PaaS 风潮抛弃，dotCloud 公司却做出了这样一个决定：开源自己的容器项目 Docker。显然，这个决定在当时根本没人在乎。

 "容器"这个概念从来就不是什么新鲜的东西，也不是 Docker 公司发明的。即使在当时最热门的 PaaS 项目 Cloud Foundry 中，容器也只是其最底层、最没人关注的那一部分。说到这里，正好以当时的事实标准 Cloud Foundry 为例，来解说一下 PaaS 技术。

 PaaS 项目被大家接纳的一个主要原因，就是它提供了一种名叫"应用托管"的能力。 在当时，虚拟机和云计算已经是比较普遍的技术和服务了，那时主流用户的普遍用法，就是租一批 AWS 或者 OpenStack 的虚拟机，然后像以前管理物理服务器那样，用脚本或者手工的方式在这些机器上部署应用。

 当然，这个部署过程难免会碰到云端虚拟机和本地环境不一致的问题，所以当时的云计算服务，比的就是谁能更好地模拟本地服务器环境，能带来更好的"上云"体验。而 PaaS 开源项目的出现，就是当时解决这个问题的一个最佳方案。

 举个例子，虚拟机创建好之后，运维人员只需要在这些机器上部署一个 Cloud Foundry 项目，然后开发者只要执行一条命令就能把本地的应用部署到云上，这条命令就是：

 $ cf push " 我的应用 "

 事实上，像 Cloud Foundry 这样的 PaaS 项目，最核心的组件就是一套应用的打包和分发机制。 Cloud Foundry 为每种主流编程语言都定义了一种打包格式，而"cfpush"的作用，基本上等同于用户把应用的可执行文件和启动脚本打进一个压缩包内，上传到云上 Cloud Foundry 的存储中。接着，Cloud Foundry 会通过调度器选择一个可以运行这个应用的虚拟机，然后通知这个机器上的 Agent 把应用压缩包下载下来启动。

 这时候关键来了，由于需要在一个虚拟机上启动很多个来自不同用户的应用，Cloud Foundry 会调用操作系统的 Cgroups 和 Namespace 机制为每一个应用单独创建一个称作"沙盒"的隔离环境，然后在"沙盒"中启动这些应用进程。这样，就实现了把多个用户的应用互不干涉地在虚拟机里批量地、自动地运行起来的目的。

 这，正是 PaaS 项目最核心的能力。 而这些 Cloud Foundry 用来运行应用的隔离环境，或者说"沙盒"，就是所谓的"容器"。

 而 Docker 项目，实际上跟 Cloud Foundry 的容器并没有太大不同，所以在它发布后不久，Cloud Foundry 的首席产品经理 James Bayer 就在社区里做了一次详细对比，告诉用户 Docker 实际上只是一个同样使用 Cgroups 和 Namespace 实现的"沙盒"而已，没有什么特别的黑科技，也不需要特别关注。

 然而，短短几个月，Docker 项目就迅速崛起了。它的崛起速度如此之快，以至于 Cloud Foundry 以及所有的 PaaS 社区还没来得及成为它的竞争对手，就直接被宣告出局了。那时候，一位多年的 PaaS 从业者曾经如此感慨道：这简直就是一场"降维打击"啊。

 事实上，Docker 项目确实与 Cloud Foundry 的容器在大部分功能和实现原理上都是一样的，可偏偏就是这剩下的一小部分不一样的功能，成了 Docker 项目接下来"呼风唤雨"的不二法宝。这个功能，就是 Docker 镜像。

 恐怕连 Docker 项目的作者 Solomon Hykes 自己当时都没想到，这个小小的创新，在短短几年内就如此迅速地改变了整个云计算领域的发展历程。

 前面已经介绍过，PaaS 之所以能够帮助用户大规模部署应用到集群里，是因为它提供了一套应用打包的功能。可就是这个打包功能，却成了 PaaS 日后不断遭到用户诟病的一个"软肋"。

 出现这个问题的根本原因是，一旦用上了 PaaS，用户就必须为每种语言、每种框架，甚至每个版本的应用维护一个打好的包。这个打包过程，没有任何章法可循，更麻烦的是，明明在本地运行得好好的应用，却需要做很多修改和配置工作才能在 PaaS 里运行起来。而这些修改和配置，并没有什么经验可以借鉴，基本上得靠不断试错，直到你摸清楚了本地应用和远端 PaaS 匹配的"脾气"才能够搞定。

 最后结局就是，"cf push"确实是能一键部署了，但是为了实现这个一键部署，用户为每个应用打包的工作可谓一波三折，费尽心机。

 而Docker 镜像解决的，恰恰就是打包这个根本性的问题。 所谓 Docker 镜像，其实就是一个压缩包。但是这个压缩包里的内容，比 PaaS 的应用可执行文件 + 启停脚本的组合就要丰富多了。实际上，大多数 Docker 镜像是直接由一个完整操作系统的所有文件和目录构成的，所以这个压缩包里的内容跟你本地开发和测试环境用的操作系统是完全一样的。

 这就有意思了：假设你的应用在本地运行时，能看见的环境是 CentOS 7.2 操作系统的所有文件和目录，那么只要用 CentOS 7.2 的 ISO 做一个压缩包，再把你的应用可执行文件也压缩进去，那么无论在哪里解压这个压缩包，都可以得到与你本地测试时一样的环境。当然，你的应用也在里面！

 这就是 Docker 镜像最厉害的地方：只要有这个压缩包在手，你就可以使用某种技术创建一个"沙盒"，在"沙盒"中解压这个压缩包，然后就可以运行你的程序了。

 更重要的是，这个压缩包包含了完整的操作系统文件和目录，也就是包含了这个应用运行所需要的所有依赖，所以你可以先用这个压缩包在本地进行开发和测试，完成之后，再把这个压缩包上传到云端运行。

 在这个过程中，你完全不需要进行任何配置或者修改，因为这个压缩包赋予了你一种极其宝贵的能力：本地环境和云端环境的高度一致！这，正是 Docker 镜像的精髓。

 那么，有了 Docker 镜像这个利器，PaaS 里最核心的打包系统一下子就没了用武之地，最让用户抓狂的打包过程也随之消失了。相比之下，在当今的互联网里，Docker 镜像需要的操作系统文件和目录，可谓唾手可得。

 所以，你只需要提供一个下载好的操作系统文件与目录，然后使用它制作一个压缩包即可，这个命令就是：`$ docker build " 我的镜像 "`

一旦镜像制作完成，用户就可以让 Docker 创建一个"沙盒"来解压这个镜像，然后在"沙盒"中运行自己的应用，这个命令就是：`$ docker run " 我的镜像 "`

当然，docker run 创建的"沙盒"，也是使用 Cgroups 和 Namespace 机制创建出来的隔离环境。我会在后面的文章中，详细介绍这个机制的实现原理。

 所以，Docker 项目给 PaaS 世界带来的"降维打击"，其实是提供了一种非常便利的打包机制。这种机制直接打包了应用运行所需要的整个操作系统，从而保证了本地环境和云端环境的高度一致，避免了用户通过"试错"来匹配两种不同运行环境之间差异的痛苦过程。而对于开发者们来说，在终于体验到了生产力解放所带来的痛快之后，他们自然选择了用脚投票，直接宣告了 PaaS 时代的结束。

 不过，Docker 项目固然解决了应用打包的难题，但正如前面所介绍的那样，它并不能代替 PaaS 完成大规模部署应用的职责。

 遗憾的是，考虑到 Docker 公司是一个与自己有潜在竞争关系的商业实体，再加上对 Docker 项目普及程度的错误判断，Cloud Foundry 项目并没有第一时间使用 Docker 作为自己的核心依赖，去替换自己那套饱受诟病的打包流程。

 反倒是一些机敏的创业公司，纷纷在第一时间推出了 Docker 容器集群管理的开源项目（比如 Deis 和 Flynn），它们一般称自己为 CaaS，即 Container-as-a-Service，用来跟"过时"的 PaaS 们划清界限。

 而在 2014 年底的 DockerCon 上，Docker 公司雄心勃勃地对外发布了自家研发的"Docker 原生"容器集群管理项目 Swarm，不仅将这波"CaaS"热推向了一个前所未有的高潮，更是寄托了整个 Docker 公司重新定义 PaaS 的宏伟愿望。

 在 2014 年的这段巅峰岁月里，Docker 公司离自己的理想真的只有一步之遥。

 2013~2014 年，以 Cloud Foundry 为代表的 PaaS 项目，逐渐完成了教育用户和开拓市场的艰巨任务，也正是在这个将概念逐渐落地的过程中，应用"打包"困难这个问题，成了整个后端技术圈子的一块心病。

 Docker 项目的出现，则为这个根本性的问题提供了一个近乎完美的解决方案。这正是 Docker 项目刚刚开源不久，就能够带领一家原本默默无闻的 PaaS 创业公司脱颖而出，然后迅速占领了所有云计算领域头条的技术原因。

 而在成为了基础设施领域近十年难得一见的技术明星之后，dotCloud 公司则在 2013 年底大胆改名为 Docker 公司。不过，这个在当时就颇具争议的改名举动，也成为了日后容器技术圈风云变幻的一个关键伏笔。

 之前说到，伴随着 PaaS 概念的逐步普及，以 Cloud Foundry 为代表的经典 PaaS 项目，开始进入基础设施领域的视野，平台化和 PaaS 化成了这个生态中的一个最为重要的进化趋势。

 就在对开源 PaaS 项目落地的不断尝试中，这个领域的从业者们发现了 PaaS 中最为棘手也最亟待解决的一个问题：究竟如何给应用打包？

 遗憾的是，无论是 Cloud Foundry、OpenShift，还是 Clodify，面对这个问题都没能给出一个完美的答案，反而在竞争中走向了碎片化的歧途。

 而就在这时，一个并不引人瞩目的 PaaS 创业公司 dotCloud，却选择了开源自家的一个容器项目 Docker。更出人意料的是，就是这样一个普通到不能再普通的技术，却开启了一个名为"Docker"的全新时代。

 Docker 项目的崛起，是不是偶然呢？这个以"鲸鱼"为注册商标的技术创业公司，最重要的战略之一就是：坚持把"开发者"群体放在至高无上的位置。

 相比于其他正在企业级市场里厮杀得头破血流的经典 PaaS 项目们，Docker 项目的推广策略从一开始就呈现出一副"憨态可掬"的亲人姿态，把每一位后端技术人员（而不是他们的老板）作为主要的传播对象。

 简洁的 UI，有趣的 demo，"1 分钟部署一个 WordPress 网站""3 分钟部署一个 Nginx 集群"，这种同开发者之间与生俱来的亲近关系，使 Docker 项目迅速成为了全世界 Meetup 上最受欢迎的一颗新星。

 在过去的很长一段时间里，相较于前端和互联网技术社区，服务器端技术社区一直是一个相对沉闷而小众的圈子。在这里，从事 Linux 内核开发的极客们自带"不合群"的"光环"，后端开发者们啃着多年不变的 TCP/IP 发着牢骚，运维更是天生注定的幕后英雄。

 而 Docker 项目，却给后端开发者提供了走向聚光灯的机会。就比如 Cgroups 和 Namespace 这种已经存在多年却很少被人们关心的特性，在 2014 年和 2015 年竟然频繁入选各大技术会议的分享议题，就因为听众们想要知道 Docker 这个东西到底是怎么一回事儿。

 而 Docker 项目之所以能取得如此高的关注，一方面正如前面所说的那样，它解决了应用打包和发布这一困扰运维人员多年的技术难题；而另一方面，就是因为它第一次把一个纯后端的技术概念，通过非常友好的设计和封装，交到了最广大的开发者群体手里。

 在这种独特的氛围烘托下，你不需要精通 TCP/IP，也无需深谙 Linux 内核原理，哪怕只是一个前端或者网站的 PHP 工程师，都会对如何把自己的代码打包成一个随处可以运行的 Docker 镜像充满好奇和兴趣。

 这种受众群体的变革，正是 Docker 这样一个后端开源项目取得巨大成功的关键。这也是经典 PaaS 项目想做却没有做好的一件事情：PaaS 的最终用户和受益者，一定是为这个 PaaS 编写应用的开发者们，而在 Docker 项目开源之前，PaaS 与开发者之间的关系却从未如此紧密过。

 解决了应用打包这个根本性的问题，同开发者与生俱来的的亲密关系，再加上 PaaS 概念已经深入人心的完美契机，成为 Docker 这个技术上看似平淡无奇的项目一举走红的重要原因。

 一时之间，"容器化"取代"PaaS 化"成为了基础设施领域最炙手可热的关键词，一个以"容器"为中心的、全新的云计算市场，正呼之欲出。而作为这个生态的一手缔造者，此时的 dotCloud 公司突然宣布将公司名称改为"Docker"。

 这个举动，在当时颇受质疑。在大家印象中，Docker 只是一个开源项目的名字。可是现在，这个单词却成了 Docker 公司的注册商标，任何人在商业活动中使用这个单词，以及鲸鱼的 Logo，都会立刻受到法律警告。

>  Docker 项目在短时间内迅速崛起的三个重要原因：
>
> Docker 镜像通过技术手段解决了 PaaS 的根本性问题；
>
> Docker 容器同开发者之间有着与生俱来的密切关系；
>
> PaaS 概念已经深入人心的完美契机。
>

 

## 何为paas

IaaS   infrastructure as a service 基础设施及服务

PaaS  platform as a service

SaaS  software as a service

dSaaS  data storage as a service 

CaaS  container as a service

 

#### PaaS 项目成功的主要原因

   是它`提供了一种名叫"应用托管"的能力`。 paas之前主流用户的普遍用法是租一批 AWS 或者 OpenStack 的虚拟机，然后像以前管理物理服务器那样，用脚本或者手工的方式在这些机器上部署应用。

 这个部署过程会碰到云端虚拟机和本地环境不一致的问题，所以当时的云计算服务，比的就是谁能更好地模拟本地服务器环境，能带来更好的"上云"体验。而 PaaS 开源项目的出现，就是当时解决这个问题的一个最佳方案。

#### PaaS 如何部署应用

  虚拟机创建好之后，运维人员只需要在这些机器上部署一个 Cloud Foundry 项目，然后开发者只要执行一条命令就能把本地的应用部署到云上，这条命令就是：

  \# cf push " 应用 "

  namespace cgroups 沙盒

#### PaaS 项目的核心组件

  像 Cloud Foundry 这样的 PaaS 项目，最核心的组件就是一套应用的打包和分发机制。 Cloud Foundry 为每种主流编程语言都定义了一种打包格式，而"cf push"的作用，基本上等同于用户把应用的可执行文件和启动脚本打进一个压缩包内，上传到云上 Cloud Foundry 的存储中。接着，Cloud Foundry 会通过调度器选择一个可以运行这个应用的虚拟机，然后通知这个机器上的 Agent 把应用压缩包下载下来启动。

 

  由于需要在一个虚拟机上启动很多个来自不同用户的应用，Cloud Foundry 会调用操作系统的 Cgroups 和 Namespace 机制为每一个应用单独创建一个称作"沙盒"的隔离环境，然后在"沙盒"中启动这些应用进程。这就实现了把多个用户的应用互不干涉地在虚拟机里批量自动地运行起来的目的。

  这正是 PaaS 项目最核心的能力。 而这些 Cloud Foundry 用来运行应用的隔离环境，或者说"沙盒"，就是所谓的"容器"。 

> 注：
>
> Cloud Foundry是当时非常主流非常火的一个PaaS项目
>

 

## docker对paas的降维打击

#### Docker 镜像

  Docker 项目确实与 Cloud Foundry 的容器在大部分功能和实现原理上都是一样的，可偏偏就是这剩下的一小部分不一样的功能，成了 Docker 项目接下来"呼风唤雨"的不二法宝。这个功能，就是 Docker 镜像。

 恐怕连 Docker 项目的作者 Solomon Hykes 自己当时都没想到，这个小小的创新，在短短几年内就如此迅速地改变了整个云计算领域的发展历程。

 

#### PaaS的问题

  PaaS 之所以能够帮助用户大规模部署应用到集群里，是因为它提供了一套应用打包的功能。可就是这个打包功能，却成了 PaaS 日后不断遭到用户诟病的一个"软肋"。

 **根本原因：**

​    一旦用上了 PaaS，用户就必须为每种语言、每种框架，甚至每个版本的应用维护一个打好的包。这个打包过程，没有任何章法可循，更麻烦的是，明明在本地运行得好好的应用，却需要做很多修改和配置工作才能在 PaaS 里运行起来。而这些修改和配置，并没有什么经验可以借鉴，基本上得靠不断试错，直到你摸清楚了本地应用和远端 PaaS 匹配的"脾气"才能够搞定。

 

swarm+compose

 

  最后结局是，"cf push"确实是能一键部署了，但是为了实现这个一键部署，用户为每个应用打包的工作可谓一波三折，费尽心机。

 

  而Docker 镜像解决的，恰恰就是打包这个根本性的问题。 

 

#### Docker 镜像的精髓

  所谓 Docker 镜像，其实就是一个压缩包。但是这个压缩包里的内容，比 PaaS 的应用可执行文件 + 启停脚本的组合就要丰富多了。实际上，大多数 Docker 镜像是直接由一个完整操作系统的所有文件和目录构成的，所以这个压缩包里的内容跟你本地开发和测试环境用的操作系统是完全一样的。

 这就有意思了：假设你的应用在本地运行时，能看见的环境是 CentOS 7.2 操作系统的所有文件和目录，那么只要用 CentOS 7.2 的 ISO 做一个压缩包，再把你的应用可执行文件也压缩进去，那么无论在哪里解压这个压缩包，都可以得到与你本地测试时一样的环境。当然，你的应用也在里面！

 这就是 Docker 镜像最厉害的地方：只要有这个压缩包在手，你就可以使用某种技术创建一个"沙盒"，在"沙盒"中解压这个压缩包，然后就可以运行你的程序了。

 更重要的是，这个压缩包包含了完整的操作系统文件和目录，也就是包含了这个应用运行所需要的所有依赖，所以你可以先用这个压缩包在本地进行开发和测试，完成之后，再把这个压缩包上传到云端运行。

 在这个过程中，你完全不需要进行任何配置或者修改，因为这个压缩包赋予了你一种极其宝贵的能力：本地环境和云端环境的高度一致！这，正是 Docker 镜像的精髓。 

那么，有了 Docker 镜像这个利器，PaaS 里最核心的打包系统一下子就没了用武之地，最让用户抓狂的打包过程也随之消失了。相比之下，在当今的互联网里，Docker 镜像需要的操作系统文件和目录，可谓唾手可得。

所以，你只需要提供一个下载好的操作系统文件与目录，然后使用它制作一个压缩包即可，这个命令就是：

\# docker build " 镜像 "

镜像制作完成，用户就可以让 Docker 创建一个"沙盒"来解压这个镜像，然后在"沙盒"中运行自己的应用，这个命令就是：

\# docker run " 镜像 "

Docker 项目给 PaaS 世界带来的"降维打击"

其实是提供了一种非常便利的打包机制。这种机制直接打包了应用运行所需要的整个操作系统，从而保证了本地环境和云端环境的高度一致，避免了用户通过"试错"来匹配两种不同运行环境之间差异的痛苦过程。

 

# docker安装

#### CentOS 7 中 Docker 的安装:

Docker 软件包已经包括在默认的 CentOS-Extras 软件源(联网使用centos7u2自带网络Yum源)里。因此想要安装 docker，只需要运行下面的 yum 命令：    

```
yum install docker
```

启动 Docker 服务:

```
 service docker start

 chkconfig docker on
```

  CentOS 7   

```
 systemctl start docker.service

  systemctl enable docker.service
```

#### 确定docker服务在运行

结果会显示服务端和客户端的版本，如果只显示客户端版本说明服务没有启动

```
[root@centos711 ~]# docker version
Client:
 Version:         1.13.1
 API version:     1.26
 Package version: docker-1.13.1-103.git7f2769b.el7.centos.x86_64
 Go version:      go1.10.3
 Git commit:      7f2769b/1.13.1
 Built:           Sun Sep 15 14:06:47 2019
 OS/Arch:         linux/amd64

Server:
 Version:         1.13.1
 API version:     1.26 (minimum version 1.12)
 Package version: docker-1.13.1-103.git7f2769b.el7.centos.x86_64
 Go version:      go1.10.3
 Git commit:      7f2769b/1.13.1
 Built:           Sun Sep 15 14:06:47 2019
 OS/Arch:         linux/amd64
 Experimental:    false
```

#### ﻿查看docker基本信息：

```
[root@centos711 ~]# docker info 
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
Server Version: 1.13.1
Storage Driver: overlay2
 Backing Filesystem: xfs
 Supports d_type: true
 Native Overlay Diff: true
Logging Driver: journald
Cgroup Driver: systemd
Plugins: 
 Volume: local
 Network: bridge host macvlan null overlay
Swarm: inactive
Runtimes: docker-runc runc
Default Runtime: docker-runc
Init Binary: /usr/libexec/docker/docker-init-current
containerd version:  (expected: aa8187dbd3b7ad67d8e5e3a15115d3eef43a7ed1)
runc version: 9c3c5f853ebf0ffac0d087e94daef462133b69c7 (expected: 9df8b306d01f59d3a8029be411de015b7304dd8f)
init version: fec3683b971d9c3ef73f284f176672c44b448662 (expected: 949e6facb77383876aeff8a6944dde66b3089574)
Security Options:
 seccomp
  WARNING: You're not using the default seccomp profile
  Profile: /etc/docker/seccomp.json
Kernel Version: 3.10.0-1062.el7.x86_64
Operating System: CentOS Linux 7 (Core)
OSType: linux
Architecture: x86_64
Number of Docker Hooks: 3
CPUs: 2
Total Memory: 1.795 GiB
Name: centos711
ID: PIUA:XIP3:IS5J:RBJV:JOQT:ASLT:IM46:MZXM:BXIJ:2JEL:JBS7:EQ54
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Registry: https://index.docker.io/v1/
Experimental: false
Insecure Registries:
 127.0.0.0/8
Live Restore Enabled: false
Registries: docker.io (secure)
```

校验Docker的安装

```
[root@master ~]# docker run -it ubuntu bash
```

如果自动进入下面的容器环境，说明﻿ubuntu镜像运行成功，Docker的安装也没有问题：可以操作容器了

```
root@50a0449d7729:/# pwd   

root@50a0449d7729:/# ls

bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

 

## docker版本与官方安装方式

#### moby、docker-ce与docker-ee

最早时docker是一个开源项目，主要由docker公司维护。

2017年3月1日起，docker公司将原先的docker项目改名为moby，并创建了docker-ce和docker-ee。

**三者关系**：

moby是继承了原先的docker的项目，是社区维护的的开源项目，谁都可以在moby的基础打造自己的容器产品

docker-ce是docker公司维护的开源项目，是一个基于moby项目的免费的容器产品

docker-ee是docker公司维护的闭源产品，是docker公司的商业产品。

moby project由社区维护，docker-ce project是docker公司维护，docker-ee是闭源的。

  要使用免费的docker，从https://github.com/docker/docker-ce上获取。

  要使用收费的docker，从https://www.docker.com/products/docker-enterprise上获取。

 

**docker-ce的发布计划**

  v1.13.1之后，发布计划更改为:

  Edge:  月版本，每月发布一次，命名格式为YY.MM，维护到下个月的版本发布

  Stable: 季度版本，每季度发布一次，命名格式为YY.MM，维护4个月 

**安装**：

  docker-ce的release计划跟随moby的release计划，可以使用下面的命令直接安装最新的docker-ce:

  \# curl -fsSL https://get.docker.com/ | sh

CentOS

  如果是centos，上面的安装命令会在系统上添加yum源:/etc/yum.repos.d/docker-ce.repo 

```
  wget https://download.docker.com/linux/centos/docker-ce.repo

  mv docker-ce.repo /etc/yum.repos.d

  yum install -y docker-ce
```

  或者直接下载rpm安装:

```
  wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-17.09.0.ce-1.el7.centos.x86_64.rpm

 yum localinstall docker-ce-17.09.0.ce-1.el7.centos.x86_64.rpm
```

> 注意：
>
>   在说docker的时候尽量说Linux docker,因为Docker on Mac，以及 Windows Docker（Hyper-V 实现），实际上是基于虚拟化技术实现的，跟我们介绍使用的 Linux 容器完全不同。
>

 

## 国内源安装新版docker

使用aliyun docker yum源安装新版docker

删除已安装的Docker

```
  yum remove docker \
        docker-client \       
         docker-client-latest \
        docker-common \
        docker-latest \
         docker-latest-logrotate \
         docker-logrotate \
        docker-selinux \
        docker-engine-selinux \
        docker-engine
```

配置阿里云Docker Yum源

```
 yum install -y yum-utils device-mapper-persistent-data lvm2 git

 yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo 
```

安装指定版本

  查看Docker版本：

```
   yum list docker-ce --showduplicates
```

  安装较旧版本（比如Docker 17.03.2) ：

​    需要指定完整的rpm包的包名，并且加上--setopt=obsoletes=0 参数：

```
 yum install -y --setopt=obsoletes=0 \

    docker-ce-17.03.2.ce-1.el7.centos.x86_64 \

    docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch
```

安装Docker新版本（比如Docker 18.03.0)：

​    加上rpm包名的版本号部分或不加都可以：   

```
 yum install docker-ce-18.03.0.ce  -y
```

​    或者

```
  yum install docker-ce -y
```

启动Docker服务：

```
 systemctl enable docker

 systemctl start docker
```

 

查看docker版本状态： 

```
 docker -v
```

  Docker version 1.13.1, build 8633870/1.13.1 

```
 docker version   
```

查看docker运行状态

```
 docker info 
```

报错1：

  docker info的时候报如下错误

  bridge-nf-call-iptables is disabled

解决1：

  追加如下配置,然后重启系统

```
 vim /etc/sysctl.conf  

  net.bridge.bridge-nf-call-ip6tables = 1

  net.bridge.bridge-nf-call-iptables = 1

  net.bridge.bridge-nf-call-arptables = 1 
```

问题2：

  虚拟机ping百度也能ping通，但是需要等好几秒才出结果，关键是下载镜像一直报错如下

```
 docker pull daocloud.io/library/nginx
```

  Using default tag: latest

  Error response from daemon: Get https://daocloud.io/v2/: dial tcp: lookup daocloud.io on 192.168.1.2:53: read udp  192.168.1.189:41335->192.168.1.2:53: i/o timeout

解决2：

  我的虚拟机用的网关和dns都是虚拟机自己的.1或者.2，把DNS改成8.8.8.8问题就解决了，ping百度也秒出结果

```
   vim /etc/resolv.conf

  nameserver 8.8.8.8
```

## 登陆登出Docker Hub

login   Register or log in to a Docker registry

登录到自己的Docker register，需有Docker Hub的注册账号

   \# docker login

   Username: test

   Password: 

   Email: xxxx@foxmail.com

   WARNING: login credentials saved in /root/.docker/config.json

   Login Succeeded

 

logout   Log out from a Docker registry

退出登录

   \# docker logout

   Remove login credentials for https://index.docker.io/v1/

 

注：推送镜像库到私有源（可注册 docker 官方账户，推送到官方自有账户） 

## 国内源镜像源

去查看如何使用aliyun的docker镜像库

去查看如何使用网易蜂巢的docker镜像库

daocloud.io

#### Docker 加速器  

使用 Docker 的时候，需要经常从官方获取镜像，但是由于显而易见的网络原因，拉取镜像的过程非常耗时，严重影响使用 Docker 的体验。因此 DaoCloud 推出了加速器工具解决这个难题，通过智能路由和缓存机制，极大提升了国内网络访问 Docker Hub 的速度，目前已经拥有了广泛的用户群体，并得到了 Docker 官方的大力推荐。

如果您是在国内的网络环境使用 Docker，那么 Docker 加速器一定能帮助到您。   

Docker 加速器对 Docker 的版本有要求吗？   

需要 Docker 1.8 或更高版本才能使用，如果您没有安装 Docker 或者版本较旧，请安装或升级。    

Docker 加速器支持什么系统？   

Linux, MacOS 以及 Windows 平台。    

Docker 加速器是否收费？   

DaoCloud 为了降低国内用户使用 Docker 的门槛，提供永久免费的加速器服务，请放心使用。  

国内比较好的镜像源：网易蜂巢、aliyun和daocloud,下面是daocloud配置方式：

﻿Docker Hub并没有在国内部署服务器或者使用国内的CDN服务，因此在国内特殊的网络环境下，镜像下载十分耗时。

为了克服跨洋网络延迟，能够快速高效地下载Docker镜像，可以采用DaoCloud提供的服务Docker Hub Mirror，速度快很多

1.注册网站账号

2.然后进入你自己的""制台"，选择"加速器"，点"立即开始"，接入你自有的主机，就看到如下的内容了

  • 下载并安装相关软件  

```
 curl -L -o /tmp/daomonit_amd64.deb https://get.daocloud.io/daomonit/daomonit_amd64.debsudo 

dpkg -4i /tmp/daomonit_amd64.deb
```

  • 配置

```
sudo daomonit -token=e16ed16b2972865e19b143695cf08cad850d5570 save-config
```

  • 启动服务

```
service daomonit start
```

3.配置完成后从Docker Hub Mirror下载镜像，命令：

```
 dao pull ubuntu
```

 

注1：wing第一次使用daocloud是配置了加速器的，可以直接使用dao pull centos拉取经过加速之后的镜像，但是后来发现，不使用加速器也可以直接在daocloud官网上找到想要拉取的镜像地址进行拉取，﻿比如：

#docker pull daocloud.io/library/tomcat:6.0-jre7

注2：上面配置加速器的方法，官网会更新，最新方法你应该根据官网提示去操作。

使用国内镜像：

进入网站：https://hub.daocloud.io/

注册帐号：yanqiang20072008

进入镜像市场：填写搜索的镜像名称

选择第一个

点击右边快速部署： 

写入名称，选择我的主机，按提示继续在主机上进行所有操作

 

```
# mkdir /docker

\# cd /docker

\# curl -L -o /tmp/daomonit.x86_64.rpm https://get.daocloud.io/daomonit/daomonit.x86_64.rpm

\# rpm -Uvh /tmp/daomonit.x86_64.rpm

\# daomonit -token=36e3dedaa2e6b352f47b26a3fa9b67ffd54f5077 save-config

\# service daomonit start
```

 

出现如下界面：说明自有主机接入完成（注意：这里我用的主机是我自己笔记本上的一台虚拟机）

 

 

接下来我们在镜像市场找到一个centos的镜像:点击右面的拉取按钮,会出现拉取命令如下：

我们按命令执行： 

```
 \# docker pull daocloud.io/library/centos:latest
```

  出现如下提示：说明拉取成功

```
 Trying to pull repository daocloud.io/library/centos ... 

  latest: Pulling from daocloud.io/library/centos

  08d48e6f1cff: Pull complete 

  Digest: sha256:934ff980b04db1b7484595bac0c8e6f838e1917ad3a38f904ece64f70bbca040

  Status: Downloaded newer image for daocloud.io/library/centos:latest
```

 

查看一下本地镜像：    

```
  [root@docker1 docker]# docker images

  REPOSITORY          TAG         IMAGE ID       CREATED       SIZE

  daocloud.io/library/centos  latest        0584b3d2cf6d     3 weeks ago     196.5 MB
```

在拉取回来的本地镜像执行命令：

  万年不变的"你好世界"：   

```
 \# docker run daocloud.io/library/centos /bin/echo "hello world"

​    hello world
```

  使用容器中的shell：

```
[root@docker1 docker]# docker run -i -t centos /bin/bash  

  Unable to find image 'centos:latest' locally

  Trying to pull repository docker.io/library/centos ...  
```

  注意上面这样是不行的，因为默认使用的是docker官方默认镜像库的位置，需要按如下命令执行：

  [root@docker1 docker]# docker run -i -t daocloud.io/library/centos /bin/bash

  -i  捕获标准输入输出

  -t  分配一个终端或控制台

  进去之后可以在里面执行其他命令

  [root@336412c1b562 /]# ls

  anaconda-post.log  bin  dev  etc  home  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

  [root@336412c1b562 /]# df -h  #可以看到这里的磁盘分区是镜像本身的磁盘分区

  Filesystem                                              Size  Used Avail Use% Mounted on

  /dev/mapper/docker-253:0-134984824-bc712573ec743c160ea903f6196ff4814056230d6a232eb3d39761d182bc7d1c  10G  240M  9.8G  3% /

  tmpfs                                                 497M   0  497M  0% /dev

  tmpfs                                                 497M   0  497M  0% /sys/fs/cgroup

  /dev/mapper/centos-root                                        38G  2.3G  36G  7% /etc/hosts

  shm                                                  64M   0  64M  0% /dev/shm

  [root@336412c1b562 /]# exit

  exit

  [root@docker1 docker]# df -h  #这是我本地主机系统的磁盘分区

  文件系统         容量  已用  可用 已用% 挂载点

  /dev/mapper/centos-root  38G  2.3G  36G   7% /

  devtmpfs         487M   0  487M   0% /dev

  tmpfs           497M   0  497M   0% /dev/shm

  tmpfs           497M  20M  478M   4% /run

  tmpfs           497M   0  497M   0% /sys/fs/cgroup

  /dev/vda1         497M  107M  391M  22% /boot

  tmpfs           100M   0  100M   0% /run/user/0

  /dev/sr0         7.3G  7.3G   0  100% /mnt/centos7u2

 

重新进入容器：执行其他命令试一下，可以看到我们的容器可以做我们熟悉的所有的事情：

1.可以上网

  [root@9990e6c99bbd /]# ping www.baidu.com -c 2

  PING www.a.shifen.com (180.97.33.107) 56(84) bytes of data.

  64 bytes from 180.97.33.107: icmp_seq=1 ttl=52 time=19.8 ms

  64 bytes from 180.97.33.107: icmp_seq=2 ttl=52 time=19.1 ms

2.网络yum源已经配置好

  [root@9990e6c99bbd /]# yum repolist

  Loaded plugins: fastestmirror, ovl

  base                                                              | 3.6 kB  00:00:00   

  extras                                                             | 3.4 kB  00:00:00   

  updates                                                             | 3.4 kB  00:00:00   

  (1/4): base/7/x86_64/group_gz                                                  | 155 kB  00:00:01   

  (2/4): extras/7/x86_64/primary_db                                                | 166 kB  00:00:04   

  (3/4): updates/7/x86_64/primary_db                                               | 9.1 MB  00:00:07   

  (4/4): base/7/x86_64/primary_db                                                 | 5.3 MB  00:00:22   

  Determining fastest mirrors

   \* base: mirrors.tuna.tsinghua.edu.cn

   \* extras: mirrors.tuna.tsinghua.edu.cn

   \* updates: mirrors.163.com

  repo id                                 repo name                                 status

  base/7/x86_64                              CentOS-7 - Base                              9007

  extras/7/x86_64                             CentOS-7 - Extras                             393

  updates/7/x86_64                            CentOS-7 - Updates                            2560

  repolist: 11960

 

3.可以安装软件：

  [root@9990e6c99bbd /]# lsof -i:80

  bash: lsof: command not found

  [root@9990e6c99bbd /]# yum install lsof httpd -y

  Loaded plugins: fastestmirror, ovl

  Loading mirror speeds from cached hostfile

   \* base: mirrors.tuna.tsinghua.edu.cn

   \* extras: mirrors.tuna.tsinghua.edu.cn

   \* updates: mirrors.163.com

  Resolving Dependencies

  --> Running transaction  check

  ---> Package lsof.x86_64 0:4.87-4.el7 will be installed

  --> Finished Dependency Resolution

 

  Dependencies Resolved

 

  ======================================================================================================================================================

   Package              Arch                Version                  Repository             Size

  ======================================================================================================================================================

  Installing:

   lsof               x86_64               4.87-4.el7                 base               331 k

 

# docker基本概念

#### Docker系统

Docker系统有两个程序：docker服务端和docker客户端

  **docker服务端**：

​    是一个服务进程，管理着所有的容器。

​    docker engine

 #### docker客户端

​    扮演着docker服务端的远程控制器，可以用来控制docker的服务端进程。

  大部分情况下，docker服务端和客户端运行在一台机器上。

#### Docker三大核心组件

  Docker 镜像 - Docker  images 

  Docker 仓库 - Docker  registeries

  Docker 容器 - Docker  containers 

#### 容器的三大组成要素

  名称空间 namespace

  资源限制 cgroups

  文件系统 overlay2(UnionFS)

​      

registry repository

 

docker-hub  daocloud.io  ...

 

daocloud.io/library/centos:latest

daocloud.io/library/centos

docker.io/centos

centos

 

yum仓库

  存储对象：rpm

  epel yum源

  centos yum源

  mysql yum源

  zabbix yum源

   

  .repo

  

docker仓库

 

镜像名称：

  存储对象：images

  

  格式：

​    库名/分类：tag   

  

  库：registry

​    公有库：

​      docker-hub  daocloud ali 网易蜂巢

​    私有库：

​      公司内部使用（自己部署）

  

  分类：

​    操作系统名称  centos  ubuntu  

​    应用名称     nginx  tomcat  mysql

  

  tag:

​    表示镜像版本

 

  registry/repository:tag

 

完整镜像名称示例：     

  docker.io/nginx:v1

  docker.io/nginx:latest

  daocloud.io/centos:6

   

#### docker 仓库

  用来保存镜像，可以理解为代码控制中的代码仓库。同样的，Docker 仓库也有公有和私有的概念。

公有的 Docker  仓库名字是 Docker Hub。Docker Hub  提供了庞大的镜像集合供使用。这些镜像可以是自己创建，或者在别人的镜像基础上创建。Docker 仓库是 Docker 的分发部分。 

 

仓库(registry) -->Repository-->镜像(按版本区分)

 

docker在国内没有服务器 

docker 国内仓库

  ali

  网易蜂巢

  daocloud

docker共有仓库

  docker.io

docker私有仓库

  个人或者公司部署的非公开库

docker国内仓库   

  网易蜂巢  阿里云  daocloud

 

#### Docker 镜像 

  Docker 镜像是 Docker 容器运行时的`只读模板`，每一个镜像由一系列的层 (layers) 组成。Docker 使用  UnionFS 来将这些层联合到单独的镜像中。UnionFS  允许独立文件系统中的文件和文件夹(称之为分支)被透明覆盖，形成一个单独连贯的文件系统。正因为有了这些层的存在，Docker  是如此的轻量。当你改变了一个 Docker  镜像，比如升级到某个程序到新的版本，一个新的层会被创建。因此，不用替换整个原先的镜像或者重新建立(在使用虚拟机的时候你可能会这么做)，只是一个新的层被添加或升级了。现在你不用重新发布整个镜像，只需要升级，层使得分发 Docker 镜像变得简单和快速。 在 Docker 的术语里，一个只读层被称为镜像，一个镜像是永久不会变的。

  由于 Docker 使用一个统一文件系统，Docker 进程认为整个文件系统是以读写方式挂载的。 但是所有的变更都发生顶层的可写层，而下层的原始的只读镜像文件并未变化。由于镜像不可写，所以镜像是无状态的。

﻿每一个镜像都可能依赖于由一个或多个下层的组成的另一个镜像。下层那个镜像是上层镜像的父镜像。    

镜像的大体分类方式：这不是规定

  1.以操作系统名字   

   centos的docker镜像

​    centos5

​    centos6

​    centos7

​    

​    镜像名称：

​      仓库名称+镜像分类+tag名称(镜像版本)

​      

   ubuntu的docker镜像

   rhel的docker镜像  

   

  2.以应用的名字

   nginx的docker镜像

   tomcat的docker镜像

   mysql的docker镜像

   都可以当作基础镜像来使用：下载镜像-->运行成容器-->安装应用-->打包成镜像-->交付上线

 

镜像名字：

  registry/repo:tag

  daocloud.io/library/centos:7

  

镜像ID：

  64位的id号

﻿

基础镜像：

一个没有任何父镜像的镜像，谓之基础镜像。

 

centos7  镜像

centos7+nginx 镜像

centos7+nginx+vsftpd  镜像

 

#### 镜像ID

所有镜像都是通过一个 64 位十六进制字符串 （内部是一个 256 bit 的值）来标识的。 为简化使用，前 12 个字符可以组成一个短ID，可以在命令行中使用。短ID还是有一定的碰撞机率，所以服务器总是返回长ID。

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpsNoEv8F.jpg)  ﻿

   

基础镜像--》运行--》容器 -->可读写文件系统--》emacs -->镜像 --》容器---》镜像  

  

磁盘镜像文件+配置文件  define 虚拟机 start stop

  

#### Docker 容器

  Docker 容器和文件夹很类似，一个Docker容器包含了所有的某个应用运行所需要的环境。每一个 Docker 容器都是从 Docker  镜像创建的。Docker 容器可以运行、开始、停止、移动和删除。每一个 Docker 容器都是独立和安全的应用平台，Docker 容器是  Docker 的运行部分。 

## docker镜像命名解析

#### Docker镜像命名解析

镜像是Docker最核心的技术之一，也是应用发布的标准格式。无论你是用docker pull image，或者是在Dockerfile里面写FROM image，从Docker官方Registry下载镜像应该是Docker操作里面最频繁的动作之一了。那么docker镜像是如何命名的，这也是Docker里面比较容易令人混淆的一块概念：Registry，Repository, Tag and Image。

docker.io/centos:7 

下面是在本地机器运行docker images的输出结果：

常说的"ubuntu"镜像其实不是一个镜像名称，而是代表了一个名为ubuntu的Repository，同时在这个Repository下面有一系列打了tag的Image，Image的标记是一个GUID，为了方便也可以通过Repository:tag来引用。

docker.io/centos:7

registry/repository:tag

那么Registry又是什么呢？Registry存储镜像数据，并且提供拉取和上传镜像的功能。Registry中镜像是通过Repository来组织的，而每个Repository又包含了若干个Image。

• Registry包含一个或多个Repository

• Repository包含一个或多个Image

• Image用GUID表示，有一个或多个Tag与之关联

下面这条命令使用的是一个镜像比较完整的名称，也就是所谓的GUID命名方式

```
\# docker push 192.168.245.136:5000/busybox
```

 

#### Image[:tag]

当一个镜像的名称不足以分辨这个镜像所代表的含义时，你可以通过tag将版本信息添加到run命令中，以执行特

定版本的镜像。

例如:docker run ubuntu:14.04

 

\# docker tag -h

Usage: docker tag [OPTIONS] IMAGE[:TAG] [REGISTRYHOST/][USERNAME/]NAME[:TAG]

Tag an image into a repository  #给镜像打标签入库

-f, --force=false Force

--help=false Print usage

给镜像打标签

\#docker tag 11662b14f5e0 ubuntu:jdk1.7

 

## docker镜像和容器的区别

 

一、**Docker镜像**

要理解Docker镜像和docker容器之间的区别，确实不容易。

假设Linux内核是第0层，那么无论怎么运行Docker，它都是运行于内核层之上的。这个Docker镜像，是一个只读的镜像，位于第1层，它不能被修改或不能保存状态。

一个Docker镜像可以构建于另一个Docker镜像之上，这种层叠关系可以是多层的。第1层的镜像层我们称之为`基础镜像`（Base  Image），其他层的镜像（除了最顶层）我们称之为`父层镜像`（Parent  Image）。这些镜像继承了他们的父层镜像的所有属性和设置，并在Dockerfile中添加了自己的配置。

Docker镜像通过镜像ID进行识别。镜像ID是一个64字符的十六进制的字符串。但是当我们运行镜像时，通常我们不会使用镜像ID来引用镜像，而是使用镜像名来引用。

要列出本地所有有效的镜像，可以使用命令

\# docker images

镜像可以发布为不同的版本，这种机制我们称之为标签（Tag）。 

﻿

﻿如上图所示，neo4j镜像有两个版本：lastest版本和2.1.5版本。

可以使用pull命令加上指定的标签：

\# docker pull ubuntu:14.04

\# docker pull ubuntu:12.04

 

二、**Docker容器**

Docker容器可以使用命令创建：

\# docker run imagename

它会在所有的镜像层之上增加一个可写层。这个可写层有`运行在CPU上的进程`，而且有两个不同的状态：运行态（Running）和退出态 （Exited）。这就是Docker容器。当我们使用docker  run启动容器，Docker容器就进入运行态，当我们停止Docker容器时，它就进入退出态。

 当我们有一个正在运行的Docker容器时，从运行态到停止态，我们对它所做的一切变更都会永久地写到容器的文件系统中。要切记，对容器的变更是写入到容器的文件系统的，而不是写入到Docker镜像中的。

我们可以用同一个镜像启动多个Docker容器，这些容器启动后都是活动的，彼此还是相互隔离的。我们对其中一个容器所做的变更只会局限于那个容器本身。

如果对容器的底层镜像进行修改，那么当前正在运行的容器是不受影响的，不会发生自动更新现象。

如果想更新容器到其镜像的新版本，那么必须当心，确保我们是以正确的方式构建了数据结构，否则我们可能会导致损失容器中所有数据的后果。

64字符的十六进制的字符串来定义容器ID，它是容器的唯一标识符。容器之间的交互是依靠容器ID识别的，由于容器ID的字符太长，我们通常只需键入容器ID的前4个字符即可。当然，我们还可以使用容器名，但显然用4字符的容器ID更为简便。

 

## 命名空间

namespace 

名字空间是 Linux 内核一个强大的特性。每个容器都有自己单独的名字空间，运行在其中的应用都像是在独立的操作系统中运行一样。名字空间保证了容器之间彼此互不响。

1. **pid 名字空间**

不同用户的进程就是通过 pid 名字空间隔离开的，且不同名字空间中可以有相同 pid。所有的 LXC 进程在 Docker中的父进程为Docker进程，每个 LXC 进程具有不同的名字空间。同时由于允许嵌套，因此可以很方便的实现嵌套的 Docker 容器。

2. **net 名字空间**

有 了 pid 名字空间, 每个名字空间中的 pid 能够相互隔离，但是网络端口还是共享 host 的端口。网络隔离是通过 net 名字空间实现的，每个 net 名字空间有独立的 网络设备, IP 地址, 路由表, /proc/net 目录。这样每个容器的网络就能隔离开来。Docker  默认采用 veth 的方式，将容器中的虚拟网卡同 host 上的一 个Docker 网桥 docker0 连接在一起。

3. **ipc 名字空间**  

容器中进程交互还是采用了 Linux 常见的进程间交互方法(interprocess communication - IPC),  包括`信号量`、`消息队列`和`共享内存`、`socket`、`管道`等。然而同 VM 不同的是，容器的进程间交互实际上还是 host 上具有相同 pid  名字空间中的进程间交互，因此需要在 IPC 资源申请时加入名字空间信息，每个 IPC 资源有一个唯一的 32 位 id。 

4. **mnt名字空间**

类似 change root，将一个进程放到一个特定的目录执行。mnt 名字空间允许不同名字空间的进程看到的文件结构不同，这样每个名字空间  中的进程所看到的文件目录就被隔离开了。同 chroot 不同，每个名字空间中的容器在 /proc/mounts 的信息只包含所在名字空间的  mount point。

5. **uts 名字空间**

UTS("UNIX Time-sharing System") 名字空间允许每个容器拥有独立的 hostname 和 domain name, 使其在网络上可以被视作一个独立的节点而非主机上的一个进程。

6. **user 名字空间**

每个容器可以有不同的用户和组 id, 也就是说可以在容器内用容器内部的用户执行程序而非主机上的用户。

 

# 镜像管理

 

### 搜索镜像

  这种方法只能用于官方镜像库

  搜索基于 centos 操作系统的镜像

```
 \# docker search centos
```

  **按星级搜索镜像**：     

  查找 star 数至少为 100 的镜像，默认不加 s 选项找出所有相关 ubuntu 镜像：     

```
  \# docker search ubuntu -f stars=100      
```

### 拉取镜像

```
  \# docker pull centos
```

### 查看本地镜像 

```
 \# docker image list 
```

### 查看镜像详情：

```
 \# docker image inspect 镜像id
```

### 删除镜像：

  删除一个或多个，多个之间用空格隔开，可以使用镜像名称或id

```
 \# docker rmi daocloud.io/library/mysql
```

  强制删除：--force

  如果镜像正在被使用中可以使用--force强制删除   

```
 \# docker rmi docker.io/ubuntu:latest --force
```

### 删除所有镜像

```
  \# docker rmi $(docker images -q)
```

### 只查看所有镜像的id

```
  \# docker images -q 
```

### 查看镜像制作的过程

  相当于dockfile

```
 \# docker history daocloud.io/ubuntu
```

 

# 容器管理

 

创建新容器但不启动：

```
\# docker create -it daocloud.io/library/centos:5 /bin/bash
```

 

创建并运行一个新Docker 容器：

  同一个镜像可以启动多个容器,每次执行run子命令都会运行一个全新的容器

  \# docker run -it --restart=always centos /bin/bash

﻿   如果执行成功，说明CentOS 容器已经被启动，并且应该已经得到了 bash 提示符。

  -i  捕获标准输入输出

  -t  分配一个终端或控制台

  --restart=always  

​    容器随docker engine自启动，因为在重启docker的时候默认容器都会被关闭  

​    也适用于create选项  

  --rm

​    默认情况下，每个容器在退出时，它的文件系统也会保存下来，这样一方面调试会方便些，因为你可以通过查看日志等方式来确定最终状态。另一方面，也可以保存容器所产生的数据。

​    但是当你仅仅需要短暂的运行一个容器，并且这些数据不需要保存，你可能就希望Docker能在容器结束时自动清理其所产生的数据。这个时候就需要--rm参数了。

> 注意：--rm 和 -d不能共用

 

容器名称

--name= Assign a name to the container   

--为容器分配一个名字，如果没有指定，docker会自动分配一个随机名称是#docker run子命令的参数

 

可以通过三种方式调用容器命名：

1）使用UUID长命名（"f78375b1c487e03c9438c729345e54db9d20cfa2ac1fc3494b6eb60872e74778"）

2）使用UUID短Id（"f78375b1c487"）

3）使用Name("evil_ptolemy") 

 

这个UUID标识是由Docker deamon生成的。

 

如果你在执行docker run时没有指定--name，那么deamon会自动生成一个随机字符串UUID。

但是对于一个容器来说有个name会非常方便，当你需要连接其它容器时或者类似需要区分其它容器时，使用容器名称可以简化操作。无论容器运行在前台或者后台，这个名字都是有效的。

 

**保存容器PID equivalent**

如果在使用Docker时有自动化的需求，你可以将containerID输出到指定的文件中（PIDfile），类似于某些应用程序将自身ID输出到文件中，方便后续脚本操作。

--cidfile="": Write the container ID to the file

 

若要断开与容器的连接，并且关闭容器：

  容器内部执行如下命令

  [root@d33c4e8c51f8 /]#exit

 

如果只想断开和容器的连接而不关闭容器：

  快捷键：ctrl+p+q

 

**查看容器**

  只查看运行状态的容器：

  \#docker ps

  \#docker ps -a

  -a  查看所有容器 

  只查看所有容器id:

  \# docker ps -a -q

  列出最近一次启动的容器(了解)

  \# docker ps -l  

 

**查看容器详细信息**

inspect  Return low-level information on a container or image

用于查看容器的配置信息，包含容器名、环境变量、运行命令、主机配置、网络配置和数据卷配置等。

目标：

查找某一个运行中容器的id，然后使用docker inspect命令查看容器的信息。

提示：

可以使用镜像id的前面部分，不需要完整的id。

[root@master ~]# docker inspect d95   //d95是我机器上运行的一个容器ID的前3个字符

比如：容器里在安装ip或ifconfig命令之前，查看网卡IP显示容器IP地址和端口号，如果输出是空的说明没有配置IP地址（不同的Docker容器可以通过此IP地址互相访问）

\# docker inspect --format='{{.NetworkSettings.IPAddress}}'  容器id

**列出所有绑定的端口**:

\# docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{$p}} -> 

{{(index $conf 0).HostPort}} {{end}}' $INSTANCE_ID

 

\# docker inspect --format='{{range $p, 

$conf := .NetworkSettings.Ports}} {{$p}} -> {{(index $conf 0).HostPort}} {{end}}' 

b220fabf815a

22/tcp -> 20020

 

**找出特殊的端口映射**

比如找出容器里22端口所映射的docker本机的端口：

\# docker inspect --format='{{(index (index .NetworkSettings.Ports "22/tcp") 

0).HostPort}}' $INSTANCE_ID

[root@localhost ~]# docker inspect --format='{{(index (index .NetworkSettings.Ports "22/

tcp") 0).HostPort}}' b220fabf815a

20020



**启动容器**

```
\# docker start  name
```

 

**关闭容器**

```
# docker stop  name

\# docker kill   name    --强制终止容器
```

 

**杀死所有running状态的容器**

```
\# docker kill $(docker ps  -q) 
```

> stop和kill的区别：
>
>   docker stop命令给容器中的进程发送SIGTERM信号，默认行为是会导致容器退出，当然，容器内程序可以捕获该信号并自行处理，例如可以选择忽略。而docker kill则是给容器的进程发送SIGKILL信号，该信号将会使容器必然退出。 
>

 

**删除容器**

  \# docker rm 容器id或名称

  要删除一个运行中的容器，添加 -f 参数

  

**根据格式删除所有容器**

  \# docker rm $(docker ps -qf status=exited) 

**重启容器**

\#docker restart name 

**暂停容器**

pause  --暂停容器内的所有进程，

通过docker stats可以观察到此时的资源使用情况是固定不变的，通过docker logs -f也观察不到日志的进一步输出。

**恢复容器**

unpause  --恢复容器内暂停的进程，与pause参数相对应

 

\# docker start infallible_ramanujan  //这里的名字是状态里面NAMES列列出的名字，这种方式同样会让容器运行在后台

 

**让容器运行在后台**

﻿如果在docker run后面追加-d=true或者-d，那么容器将会运行在后台模式。此时所有I/O数据只能通过网络资源或者共享卷组来进行交互。因为容器不再监听你执行docker run的这个终端命令行窗口。但你可以通过执行

docker attach来重新附着到该容器的回话中。

 

> 注：容器运行在后台模式下，是不能使用--rm选项的(老版本是这样，新版本已经可以同时生效)
>

 

\#docker run -d IMAGE[:TAG] 命令

\#docker logs container_id  #打印该容器的输出

 

\# docker run -it -d --name mytest docker.io/centos /bin/sh -c "while true; do echo hello world; sleep 2; done"

37738fe3d6f9ef26152cb25018df9528a89e7a07355493020e72f147a291cd17

 

[root@localhost ~]# docker logs mytest

hello world

hello world

 

docker attach container_id #附加该容器的标准输出到当前命令行

[root@localhost ~]# docker attach mytest

hello world

hello world

.......

此时，ctrl+d等同于exit命令，按ctrl+p+q可以退出到宿主机，而保持container仍然在运行

 

rename 

  Rename a container

  

stats   

  Display a live stream of container(s) resource usage statistics   

  --动态显示容器的资源消耗情况，包括：CPU、内存、网络I/O  

  

port   

  List port mappings or a specific mapping for the CONTAINER

   --输出容器端口与宿主机端口的映射情况

  \# docker port blog

​    80/tcp -> 0.0.0.0:80

   容器blog的内部端口80映射到宿主机的80端口，这样可通过宿主机的80端口查看容器blog提供的服务

 

**连接容器**：  

方法1.attach

\# docker attach 容器id  //前提是容器创建时必须指定了交互shell

 

方法2.exec    

  通过exec命令可以创建两种任务：后台型任务和交互型任务

  交互型任务：

​    \# docker exec -it  容器id  /bin/bash

​    root@68656158eb8e:/# ls   

  

  后台型任务：

​    \# docker exec 容器id touch /testfile

 

监控容器的运行：

可以使用logs、top、events、wait这些子命令

  logs:

​    使用logs命令查看守护式容器

​    可以通过使用docker logs命令来查看容器的运行日志，其中--tail选项可以指定查看最后几条日志，而-t选项则可以对日志条目附加时间戳。使用-f选项可以跟踪日志的输出，直到手动停止。

​    \# docker logs   App_Container  //不同终端操作

​    \# docker logs -f App_Container

 

  top:

​    显示一个运行的容器里面的进程信息

​    \# docker top birdben/ubuntu:v1

 

  events   

​    Get real time events from the server

​    实时输出Docker服务器端的事件，包括容器的创建，启动，关闭等。

 

​    \# docker start loving_meninsky

​    loving_meninsky

 

​    \# docker events  //不同终端操作

​    2017-07-08T16:39:23.177664994+08:00 network connect  

​    df15746d60ffaad2d15db0854a696d6e49fdfcedc7cfd8504a8aac51a43de6d4 

​    (container=50a0449d7729f94046baf0fe5a1ce2119742261bb3ce8c3c98f35c80458e3e7a, 

​    name=bridge, type=bridge)

​    2017-07-08T16:39:23.356162529+08:00 container start 

​    50a0449d7729f94046baf0fe5a1ce2119742261bb3ce8c3c98f35c80458e3e7a (image=ubuntu, 

​    name=loving_meninsky)

 

  wait    

​    Block until a container stops, then print its exit code  

​    --捕捉容器停止时的退出码

​    执行此命令后，该命令会"hang"在当前终端，直到容器停止，此时，会打印出容器的退出码

​    \# docker wait 01d8aa  //不同终端操作

​      137

 

  diff

​    查看容器内发生改变的文件，以elated_lovelace容器为例

​    root@68656158eb8e:/# touch c.txt

 

​    用diff查看：

​    包括文件的创建、删除和文件内容的改变都能看到 

​    [root@master ~]# docker diff  容器名称

​    A /c.txt

 

​    C对应的文件内容的改变，A对应的均是文件或者目录的创建删除

​    [root@docker ~]# docker diff 7287

​    A /a.txt

​    C /etc

​    C /etc/passwd

​    A /run

​    A /run/secrets  

​    

宿主机和容器之间相互COPY文件

  cp的用法如下：

  Usage:   docker cp [OPTIONS] CONTAINER:PATH LOCALPATH

​          docker cp [OPTIONS] LOCALPATH CONTAINER:PATH

 

  如：容器mysql中/usr/local/bin/存在docker-entrypoint.sh文件，可如下方式copy到宿主机

  \#  docker cp mysql:/usr/local/bin/docker-entrypoint.sh  /root

 

  修改完毕后，将该文件重新copy回容器

  \# docker cp /root/docker-entrypoint.sh mysql:/usr/local/bin/    

  

# docker容器镜像制作

## 容器文件系统打包

 

将容器的文件系统打包成tar文件,也就是把正在运行的容器直接导出为tar包的镜像文件

export   

  Export a container's filesystem as a tar archive

 

有两种方式（elated_lovelace为容器名）：

第一种：

  [root@master ~]# docker export -o elated_lovelace.tar elated_lovelace

 

第二种：

  [root@master ~]# docker export 容器名称 > 镜像.tar

 

导入镜像归档文件到其他宿主机：

import   

  Import the contents from a tarball to create a filesystem image

  \# docker import elated_lovelace.tar  elated_lovelace:v1

 

> 注意：
>
>   如果导入镜像时没有起名字，随后可以单独起名字(没有名字和tag)，可以手动加tag
>
>   \# docker tag 镜像ID mycentos:7  
>

 

## 通过容器创建本地镜像

背景：

  容器运行起来后，又在里面做了一些操作，并且要把操作结果保存到镜像里

 

方案：

  使用 docker commit 指令，把一个正在运行的容器，直接提交为一个镜像。

  commit 是提交的意思,类似告诉svn服务器我要生成一个新的版本。

 

例子：

在容器内部新建了一个文件

\# docker exec -it 4ddf4638572d /bin/sh  

root@4ddf4638572d:/app# touch test.txt

root@4ddf4638572d:/app# exit

 

\#  将这个新建的文件提交到镜像中保存

\# docker commit 4ddf4638572d wing/helloworld:v2

例子：

\# docker commit -m "my images version1" -a "wing" 108a85b1ed99 daocloud.io/ubuntu:v2

  sha256:ffa8a185ee526a9b0d8772740231448a25855031f25c61c1b63077220469b057

 

  -m                   添加注释

  -a                   作者

  108a85b1ed99         容器环境id

  daocloud.io/ubuntu:v2    镜像名称：hub的名称/镜像名称：tag 

  ﻿-p，–pause=true        提交时暂停容器运行



Init 层的存在，是为了避免执行 docker commit 时，把 Docker 自己对 /etc/hosts 等文件做的修改，也一起提交掉。

 

## 镜像迁移

保存一台宿主机上的镜像为tar文件，然后可以导入到其他的宿主机上：

save    

  Save an image(s) to a tar archive

  将镜像打包，与下面的load命令相对应

  \#docker save -o nginx.tar nginx

 

load    

  Load an image from a tar archive or STDIN

  与上面的save命令相对应，将上面sava命令打包的镜像通过load命令导入

  \#docker load < nginx.tar

 

> 注：
>
>   1.tar文件的名称和保存的镜像名称没有关系
>
>   2.导入的镜像如果没有名称，自己打tag起名字
>

  

把容器导出成tar包 export  import 

把容器做成镜像  commit  -a "" -m ""  

把镜像保存为tar包 save   load

 

 

## 通过Dockerfile创建镜像

虽然可以自己制作 rootfs(见'容器文件系统那些事儿')，但Docker 提供了一种更便捷的方式，叫作 Dockerfile

docker build命令用于根据给定的Dockerfile和上下文以构建Docker镜像。 

docker build语法：

\# docker build [OPTIONS] <PATH | URL | ->

 

1. 选项说明

--build-arg，设置构建时的变量

--no-cache，默认false。设置该选项，将不使用Build Cache构建镜像

--pull，默认false。设置该选项，总是尝试pull镜像的最新版本

--compress，默认false。设置该选项，将使用gzip压缩构建的上下文

--disable-content-trust，默认true。设置该选项，将对镜像进行验证

--file, -f，Dockerfile的完整路径，默认值为‘PATH/Dockerfile’

--isolation，默认--isolation="default"，即Linux命名空间；其他还有process或hyperv

--label，为生成的镜像设置metadata

--squash，默认false。设置该选项，将新构建出的多个层压缩为一个新层，但是将无法在多个镜像之间共享新层；设置该选项，实际上是创建了新image，同时保留原有image。

--tag, -t，镜像的名字及tag，通常name:tag或者name格式；可以在一次构建中为一个镜像设置多个tag

--network，默认default。设置该选项，Set the networking mode for the RUN instructions during build

--quiet, -q ，默认false。设置该选项，Suppress the build output and print image ID on success

--force-rm，默认false。设置该选项，总是删除掉中间环节的容器

--rm，默认--rm=true，即整个构建过程成功后删除中间环节的容器

 

2. PATH | URL | -说明：

给出命令执行的上下文。

上下文可以是构建执行所在的本地路径，也可以是远程URL，如Git库、tarball或文本文件等。

如果是Git库，如https://github.com/docker/rootfs.git#container:docker，则隐含先执行git clone --depth 1 --recursive，到本地临时目录；然后再将该临时目录发送给构建进程。

构建镜像的进程中，可以通过ADD命令将上下文中的任何文件（注意文件必须在上下文中）加入到镜像中。

-表示通过STDIN给出Dockerfile或上下文。

示例：

 

  docker build - < Dockerfile

 

说明：该构建过程只有Dockerfile，没有上下文

 

  docker build - < context.tar.gz

 

说明：其中Dockerfile位于context.tar.gz的根路径

 

可以同时设置多个tag

  \# docker build -t champagne/bbauto:latest -t champagne/bbauto:v2.1 .

 

2.1、 创建镜像所在的文件夹和Dockerfile文件 

​     命令： 

​     1、mkdir sinatra 

​     2、cd sinatra 

​     3、touch Dockerfile 

 

2.2、 在Dockerfile文件中写入指令，每一条指令都会更新镜像的信息例如： 

​    \#vim Dockerfile 

\# This is a comment (描述)

​     FROM centos:7 

​     MAINTAINER wing wing@localhost.localdomain

​     RUN  命令

​     RUN  命令

​     

​     格式说明： 

​     每行命令都是以  INSTRUCTION statement 形式，就是命令+ 清单的模式。命令要大写，"#"是注解。 

​     FROM 命令是告诉docker 我们的镜像什么。 

​     MAINTAINER 是描述 镜像的创建人。 

​     RUN 命令是在镜像内部执行。就是说他后面的命令应该是针对镜像可以运行的命令。 

 

 2.3、创建镜像 

​     命令：docker build -t wing/sinatra:v2 . 

​     docker build  是docker创建镜像的命令 

​     -t 是标识新建的镜像属于 ouruser的  

​     sinatra是仓库的名称  

​    ：v2 是tag 

​     "."是用来指明 我们的使用的Dockerfile文件当前目录的 

 

 2.4、创建完成后，从镜像创建容器 

​     \#docker run -t -i wing/sinatra:v2 /bin/bash

 

 

### Dockerfile实例：容器化python的flask应用

 

目标：

  用 Docker 部署一个用 Python 编写的 Web 应用。

 

基础镜像（python）-->flask-->部署python应用-->

 

前端（html css js）-->flask-->服务（数据库）

 

web框架 flask django

 

应用代码部分:

 

代码功能：

  如果当前环境中有"NAME"这个环境变量，就把它打印在"Hello"后，否则就打印"Hello world"，最后再打印出当前环境的 hostname。

 

\# mkdir python_app

\# cd python_app

\# vim app.py：

from flask import Flask

import socket

import os

 

app = Flask(__name__)

 

@app.route('/')

def hello():

  html = "<h3>Hello {name}!</h3>" \

​      "<b>Hostname:</b> {hostname}<br/>"      

  return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname())

 

if __name__ == "__main__":

  app.run(host='0.0.0.0', port=80)

 

应用依赖：

定义在同目录下的 requirements.txt 文件里，内容如下：

 

\# vim requirements.txt

Flask

 

Dockerfile制作容器镜像:

\# vim Dockerfile

FROM python:2.7-slim

WORKDIR /app

ADD . /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt

EXPOSE 80

ENV NAME World

CMD ["python", "app.py"]

 

Dockerfile文件说明：

 

FROM python:2.7-slim

\# 使用官方提供的 Python 开发镜像作为基础镜像

\# 指定"python:2.7-slim"这个官方维护的基础镜像，从而免去安装 Python 等语言环境的操作。否则，这一段就得这么写了：

\##FROM ubuntu:latest

\##RUN apt-get update -yRUN apt-get install -y python-pip python-dev build-essential

 

WORKDIR /app

\# 将工作目录切换为 /app

\# 意思是在这一句之后，Dockerfile 后面的操作都以这一句指定的 /app 目录作为当前目录。 

 

ADD . /app

\# 将当前目录下的所有内容复制到 /app 下 

\# Dockerfile 里的原语并不都是指对容器内部的操作。比如 ADD，指的是把当前目录（即 Dockerfile 所在的目录）里的文件，复制到指定容器内的目录当中。

 

RUN pip install --trusted-host pypi.python.org -r requirements.txt

\# 使用 pip 命令安装这个应用所需要的依赖

 

EXPOSE 80

\# 允许外界访问容器的 80 端口

 

ENV NAME World

\# 设置环境变量

 

CMD ["python", "app.py"]

\# 设置容器进程为：python app.py，即：这个 Python 应用的启动命令

\# 这里app.py 的实际路径是 /app/app.py。CMD ["python", "app.py"] 等价于 "docker run python app.py"。

\# 在使用 Dockerfile 时，可能还会看到一个叫作 ENTRYPOINT 的原语。它和 CMD 都是 Docker 容器进程启动所必需的参数，完整执行格式是："ENTRYPOINT CMD"。

\# 但是，默认，Docker 会提供一个隐含的 ENTRYPOINT，即：/bin/sh -c。所以，在不指定 ENTRYPOINT 时，比如在这个例子里，实际上运行在容器里的完整进程是：/bin/sh -c "python app.py"，即 CMD 的内容就是 ENTRYPOINT 的参数。

\# 基于以上原因，后面会统一称 Docker 容器的启动进程为 ENTRYPOINT，而不是 CMD。

 

现在目录结构：

\# ls

Dockerfile  app.py  requirements.txt

 

构建镜像：

\# docker build -t helloworld .

-t  给这个镜像加一个 Tag

 

Dockerfile 中的每个原语执行后，都会生成一个对应的镜像层。即使原语本身并没有明显地修改文件的操作（比如，ENV 原语），它对应的层也会存在。只不过在外界看来，这个层是空的。

 

查看结果：

\# docker image ls

REPOSITORY       TAG         IMAGE ID

helloworld     latest        653287cdf998

 

启动容器：

\# docker run -p 4000:80 helloworld

镜像名 helloworld 后面，什么都不用写，因为在 Dockerfile 中已经指定了 CMD。否则，就得把进程的启动命令加在后面：

\# docker run -p 4000:80 helloworld python app.py

 

查看容器：

\# docker ps

CONTAINER ID     IMAGE        COMMAND       CREATED

4ddf4638572d     helloworld    "python app.py"   10 seconds ago

 

进入容器：

\# docker exec -it b69 /bin/bash

 

访问容器内应用：

\# curl http://localhost:4000

<h3>Hello World!</h3><b>Hostname:</b> 4ddf4638572d<br/>
\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

至此，已经使用容器完成了一个应用的开发与测试，如果现在想要把这个容器的镜像上传到 DockerHub 上分享给更多的人，首先要注册一个 Docker Hub 账号，然后使用 docker login 命令登录。

 

给容器镜像打tag起一个完整的名字：

\# docker tag helloworld yanqiang20072008/helloworld:v1

yanqiang20072008为我在docker hub的用户名

 

推送镜像到docker hub：

\# docker push yanqiang20072008/helloworld:v1

### Dockerfile实例：制作kubectl的镜像

制作镜像：wing/kubectl

\#cat Dockerfile/kubectl/Dockerfile

FROM alpine

 

MAINTAINER wing <276267003@qq.com>

 

LABEL org.label-schema.vcs-ref=$VCS_REF \

   org.label-schema.vcs-url="https://github.com/vfarcic/kubectl" \

   org.label-schema.docker.dockerfile="/Dockerfile"

 

ENV KUBE_LATEST_VERSION="v1.13.0"

 

RUN apk add --update ca-certificates && \

  apk add --update -t deps curl && \

  curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \

  chmod +x /usr/local/bin/kubectl && \

  apk del --purge deps && \

  rm /var/cache/apk/*

 

CMD ["kubectl", "help"]

## dockerfile优化

编译一个简单的nginx成功以后发现好几百M。

 

1、RUN 命令要尽量写在一条里，每次 RUN 命令都是在之前的镜像上封装，只会增大不会减小

 

2、每次进行依赖安装后，记得yum clean all【centos】 

   yum clean all 清除缓存中的rpm头文件和包文件

 

3、选择比较小的基础镜像，比如：alpine

# 部署私有仓库应用

registry  官方出品  没有图形界面

harbor  vmware公司出品  最常用的

Helm  

 

 

仓库镜像

  Docker hub官方已提供容器镜像registry,用于搭建私有仓库

 

拉取镜像：

  \# docker pull daocloud.io/library/registry:latest

运行容器：                  

  \# docker run --name "pri_registry" --restart=always -d -p 5000:5000 daocloud.io/library/registry 

 

  注：如果创建容器不成功，报错防火墙，解决方案如下

​    \#systemctl stop firewalld

​    \#yum install iptables*

​    \#systemctl start iptables

​    \#iptables -F

​    \#systemctl restart docker

​    

  \# docker ps

  CONTAINER ID  IMAGE  COMMAND  CREATED  STATUS   PORTS   NAMES

  1f444285bed8     daocloud.io/library/registry  "/entrypoint.sh /etc/"  23 seconds ago    Up 21 seconds    0.0.0.0:5000->5000/tcp  elegant_rosalind

 

﻿连接容器查看端口状态：

docker exec -it  1f444285bed8  /bin/sh    //这里是sh 不是bash

  / # netstat -lnp                       //查看5000端口是否开启

  Active Internet connections (only servers)

  Proto Recv-Q Send-Q Local Address      Foreign Address     State    PID/Program name   

  tcp     0    0 :::5000         :::*           LISTEN    1/registry

  Active UNIX domain sockets (only servers)

  Proto RefCnt Flags    Type    State     I-Node PID/Program name   Path

﻿

﻿在本机查看能否访问该私有仓库,﻿ 看看状态码是不是200

  [root@master registry]# curl  -I  127.0.0.1:5000   //参数是大写的i

  HTTP/1.1 200 OK     

 

为了方便，下载1个比较小的镜像,buysbox

  \# docker pull busybox

﻿

上传前必须给镜像打tag  注明ip和端口：

  \# docker tag busybox  本机IP:端口/busybox

 

  这是直接从官方拉的镜像，很慢：

  \# docker tag busybox 192.168.245.136:5000/busybox

 

  下面这个Mysql是我测试的第二个镜像，从daocloud拉取的：

  \# docker tag daocloud.io/library/mysql 192.168.245.136:5000/daocloud.io/library/mysql

  注：tag后面可以使用镜像名称也可以使用id,我这里使用的镜像名称，如果使用官方的镜像，不需要加前缀，但是daocloud.io的得加前缀

 

修改请求方式为http:

  默认为https，不改会报以下错误:

​    Get https://master.up.com:5000/v1/_ping: http: server gave HTTP response to HTTPS client

  

  \# vim /etc/docker/daemon.json

  { "insecure-registries":["192.168.245.136:5000"] }

  

重启docker:

  \# systemctl restart docker

 

上传镜像到私有仓库：

  \# docker push 192.168.245.136:5000/busybox

 

  \# docker push 192.168.245.136:5000/daocloud.io/library/mysql

 

查看私有仓库里的所有镜像：

  注意我这里是用的是ubuntu的例子

  \# curl 192.168.245.130:5000/v2/_catalog

​    {"repositories":["daocloud.io/ubuntu"]}

 

  或者：

  

  \# curl  http://192.168.245.130:5000/v2/daocloud.io/ubuntu/tags/list

​    {"name":"daocloud.io/ubuntu","tags":["v2"]}

  

  \# curl  http://192.168.245.130:5000/v2/repo名字/tags/list

​    

拉取镜像测试：

  \# docker pull 192.168.245.136:5000/busybox

 

# 部署docker web ui应用

下载并运行容器：

\#docker pull uifd/ui-for-docker 

\#docker run -it -d --name docker-web -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock docker.io/uifd/ui-for-docker 

 

浏览器访问测试：

  ip:9000

  

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpsvPloiu.jpg) 

 

# docker资源限制

在使用 docker 运行容器时，一台主机上可能会运行几百个容器，这些容器虽然互相隔离，但是底层却使用着相同的 CPU、内存和磁盘资源。如果不对容器使用的资源进行限制，那么容器之间会互相影响，小的来说会导致容器资源使用不公平；大的来说，可能会导致主机和集群资源耗尽，服务完全不可用。

 

CPU 和内存的资源限制已经是比较成熟和易用，能够满足大部分用户的需求。磁盘限制也是不错的，虽然现在无法动态地限制容量，但是限制磁盘读写速度也能应对很多场景。

 

至于网络，docker 现在并没有给出网络限制的方案，也不会在可见的未来做这件事情，因为目前网络是通过插件来实现的，和容器本身的功能相对独立，不是很容易实现，扩展性也很差。

 

资源限制一方面可以让我们为容器（应用）设置合理的 CPU、内存等资源，方便管理；另外一方面也能有效地预防恶意的攻击和异常，对容器来说是非常重要的功能。如果你需要在生产环境使用容器，请务必要花时间去做这件事情。

## 系统压力测试工具stress

  stress是一个linux下的压力测试工具，专门为那些想要测试自己的系统，完全高负荷和监督这些设备运行的用户。 

:(){:|:&};:

安装：

```
  \# yum install stress -y
```

测试场景举例

测试CPU负荷 

```
# stress -c 4
```

增加4个cpu进程，处理sqrt()函数函数，以提高系统CPU负荷

内存测试

```
# stress –i 4 –vm 10 –vm-bytes 1G –vm-hang 100 –timeout 100s
```

新增4个io进程，10个内存分配进程，每次分配大小1G，分配后不释放，测试100S

磁盘I/O测试

```
# stress –d 1 --hdd-bytes 3G
```

新增1个写进程，每次写3G文件块

硬盘测试（不删除）

```
# stress –i 1 –d 10 --hdd-bytes 3G –hdd-noclean
```

新增1个IO进程，10个写进程，每次写入3G文件块，且不清除，会逐步将硬盘耗尽。

stress各主用参数说明（-表示后接一个中划线，--表示后接2个中划线，均可用于stress后接参数，不同表达方式）：

> -？
>
> --help 显示帮助信息
>
> --version 显示软件版本信息
>
> -t secs:
>
> --timeout secs指定运行多少秒
>
> --backoff usecs 等待usecs微秒后才开始运 
>
> -c forks 
>
> --cpu forks 产生多个处理sqrt()函数的CPU进程
>
> -m forks
>
> --vm forks:产生多个处理malloc()内存分配函数的进程，后接进程数量
>
> -i forks
>
> --io forks:产生多个处理sync()函数的磁盘I/O进程
>
> --vm-bytes bytes：指定内存的byte数，默认值是1 
>
> --vm-hang:表示malloc分配的内存多少时间后在free()释放 
>
> -d :
>
> --hdd:写进程，写入固定大小，通过mkstemp()函数写入当前目录
>
> --hdd-bytes bytes:指定写的byte数，默认1G
>
> --hdd-noclean:不要将写入随机ascii数据的文件unlink，则写入的文件不删除，会保留在硬盘空间。

## cpu资源限制

CPU 资源

  主机上的进程会通过时间分片机制使用 CPU，CPU 的量化单位是频率，也就是每秒钟能执行的运算次数。为容器限制 CPU 资源并不能改变 CPU 的运行频率，而是改变每个容器能使用的 CPU 时间片。理想状态下，CPU 应该一直处于运算状态（并且进程需要的计算量不会超过 CPU 的处理能力）。

### 限制CPU Share

什么是cpu share:

  docker 允许用户为每个容器设置一个数字，代表容器的 CPU share，默认情况下每个容器的 share 是 1024。这个 share 是相对的，本身并不能代表任何确定的意义。当主机上有多个容器运行时，每个容器占用的 CPU 时间比例为它的 share 在总额中的比例。docker 会根据主机上运行的容器和进程动态调整每个容器使用 CPU 的时间比例。

 

  例子：   

  如果主机上有两个一直使用 CPU 的容器（为了简化理解，不考虑主机上其他进程），其 CPU share 都是 1024，那么两个容器 CPU 使用率都是 50%；如果把其中一个容器的 share 设置为 512，那么两者 CPU 的使用率分别为 67% 和 33%；如果删除 share 为 1024 的容器，剩下来容器的 CPU 使用率将会是 100%。

 

  好处：

​    能保证 CPU 尽可能处于运行状态，充分利用 CPU 资源，而且保证所有容器的相对公平；

  缺点：

​    无法指定容器使用 CPU 的确定值。

 

设置 CPU share 的参数：

   -c --cpu-shares，它的值是一个整数。

 

我的机器是 4 核 CPU，因此运行一个stress容器,使用 stress 启动 4 个进程来产生计算压力：

\# docker pull progrium/stress

\# yum install htop -y

\# docker run --rm -it progrium/stress --cpu 4 

stress: info: [1] dispatching hogs: 4 cpu, 0 io, 0 vm, 0 hdd

stress: dbug: [1] using backoff sleep of 12000us

stress: dbug: [1] --> hogcpu worker 4 [7] forked

stress: dbug: [1] using backoff sleep of 9000us

stress: dbug: [1] --> hogcpu worker 3 [8] forked

stress: dbug: [1] using backoff sleep of 6000us

stress: dbug: [1] --> hogcpu worker 2 [9] forked

stress: dbug: [1] using backoff sleep of 3000us

stress: dbug: [1] --> hogcpu worker 1 [10] forked

 

在另外一个 terminal 使用 htop 查看资源的使用情况：

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpsYOLpsi.jpg) 

上图中看到，CPU 四个核资源都达到了 100%。四个 stress 进程 CPU 使用率没有达到 100% 是因为系统中还有其他机器在运行。

 

为了比较，另外启动一个 share 为 512 的容器：

 

\# docker run --rm -it -c 512 progrium/stress --cpu 4 

stress: info: [1] dispatching hogs: 4 cpu, 0 io, 0 vm, 0 hdd

stress: dbug: [1] using backoff sleep of 12000us

stress: dbug: [1] --> hogcpu worker 4 [6] forked

stress: dbug: [1] using backoff sleep of 9000us

stress: dbug: [1] --> hogcpu worker 3 [7] forked

stress: dbug: [1] using backoff sleep of 6000us

stress: dbug: [1] --> hogcpu worker 2 [8] forked

stress: dbug: [1] using backoff sleep of 3000us

stress: dbug: [1] --> hogcpu worker 1 [9] forked

 

因为默认情况下，容器的 CPU share 为 1024，所以这两个容器的 CPU 使用率应该大致为 2：1，下面是启动第二个容器之后的监控截图：

 

![img](Docker%E5%85%A8%E8%A7%A3.assets/wps6XjvC6.jpg) 

两个容器分别启动了四个 stress 进程，第一个容器 stress 进程 CPU 使用率都在 54% 左右，第二个容器 stress 进程 CPU 使用率在 25% 左右，比例关系大致为 2：1，符合之前的预期。

### 限制CPU 核数（重点）

限制容器能使用的 CPU 核数

-c --cpu-shares 参数只能限制容器使用 CPU 的比例，或者说优先级，无法确定地限制容器使用 CPU 的具体核数；从 1.13 版本之后，docker 提供了 --cpus 参数可以限定容器能使用的 CPU 核数。这个功能可以让我们更精确地设置容器 CPU 使用量，是一种更容易理解也因此更常用的手段。

 

--cpus 后面跟着一个浮点数，代表容器最多使用的核数，可以精确到小数点二位，也就是说容器最小可以使用 0.01 核 CPU。

 

限制容器只能使用 1.5 核数 CPU：

\# docker run --rm -it --cpus 1.5 progrium/stress --cpu 3 

stress: info: [1] dispatching hogs: 3 cpu, 0 io, 0 vm, 0 hdd

stress: dbug: [1] using backoff sleep of 9000us

stress: dbug: [1] --> hogcpu worker 3 [7] forked

stress: dbug: [1] using backoff sleep of 6000us

stress: dbug: [1] --> hogcpu worker 2 [8] forked

stress: dbug: [1] using backoff sleep of 3000us

stress: dbug: [1] --> hogcpu worker 1 [9] forked

在容器里启动三个 stress 来跑 CPU 压力，如果不加限制，这个容器会导致 CPU 的使用率为 300% 左右（也就是说会占用三个核的计算能力）。实际的监控如下图：

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpsgQkFMU.jpg) 

可以看到，每个 stress 进程 CPU 使用率大约在 50%，总共的使用率为 150%，符合 1.5 核的设置。

 

如果设置的 --cpus 值大于主机的 CPU 核数，docker 会直接报错：

\# docker run --rm -it --cpus 8 progrium/stress --cpu 3 

docker: Error response from daemon: Range of CPUs is from 0.01 to 4.00, as there are only 4 CPUs available.

See 'docker run --help'.

 

如果多个容器都设置了 --cpus ，并且它们之和超过主机的 CPU 核数，并不会导致容器失败或者退出，这些容器之间会竞争使用 CPU，具体分配的 CPU 数量取决于主机运行情况和容器的 CPU share 值。也就是说 --cpus 只能保证在 CPU 资源充足的情况下容器最多能使用的 CPU 数，docker 并不能保证在任何情况下容器都能使用这么多的 CPU（因为这根本是不可能的）。    

### CPU 绑定

限制容器运行在某些 CPU 核

 

注：

一般并不推荐在生产中这样使用

docker 允许调度的时候限定容器运行在哪个 CPU 上。

限制容器运行在哪些核上并不是一个很好的做法，因为它需要实现知道主机上有多少 CPU 核，而且非常不灵活。除非有特别的需求，一般并不推荐在生产中这样使用。

 

假如主机上有 4 个核，可以通过 --cpuset 参数让容器只运行在前两个核上：

\# docker run --rm -it --cpuset-cpus=0,1 progrium/stress --cpu 2 

stress: info: [1] dispatching hogs: 2 cpu, 0 io, 0 vm, 0 hdd

stress: dbug: [1] using backoff sleep of 6000us

stress: dbug: [1] --> hogcpu worker 2 [7] forked

stress: dbug: [1] using backoff sleep of 3000us

stress: dbug: [1] --> hogcpu worker 1 [8] forked

 

这样，监控中可以看到只有前面两个核 CPU 达到了 100% 使用率。

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpszQQSWI.jpg) 

--cpuset-cpus 参数可以和 -c --cpu-shares 一起使用，限制容器只能运行在某些 CPU 核上，并且配置了使用率。

 

## mem资源限制

docker 默认没有对容器内存进行限制，容器可以使用主机提供的所有内存。

 

**不限制内存带来的问题**

这是非常危险的事情，如果某个容器运行了恶意的内存消耗软件，或者代码有内存泄露，很可能会导致主机内存耗尽，因此导致服务不可用。可以为每个容器设置内存使用的上限，一旦超过这个上限，容器会被杀死，而不是耗尽主机的内存。

 

**限制内存带来的问题**

限制内存上限虽然能保护主机，但是也可能会伤害到容器里的服务。如果为服务设置的内存上限太小，会导致服务还在正常工作的时候就被 OOM 杀死；如果设置的过大，会因为调度器算法浪费内存。

 

> 合理做法：
>
> 1. 为应用做内存压力测试，理解正常业务需求下使用的内存情况，然后才能进入生产环境使用
>
> 2. 一定要限制容器的内存使用上限，尽量保证主机的资源充足，一旦通过监控发现资源不足，就进行扩容或者对容器进行迁移如果可以（内存资源充足的情况）
>
> 3. 尽量不要使用 swap，swap 的使用会导致内存计算复杂，对调度器非常不友好
>

 

**docker 限制容器内存使用量**

docker 启动参数中，和内存限制有关的包括（参数的值一般是内存大小，也就是一个正数，后面跟着内存单位 b、k、m、g，分别对应 bytes、KB、MB、和 GB）：

-m --memory：

  容器能使用的最大内存大小，最小值为 4m

--memory-swap：

  容器能够使用的 swap 大小

  --memory-swap 必须在 --memory 也配置的情况下才能有用。

如果 --memory-swap 的值大于 --memory，那么容器能使用的总内存（内存 + swap）为 --memory-swap 的值，能使用的 swap 值为 --memory-swap 减去 --memory 的值

如果 --memory-swap 为 0，或者和 --memory 的值相同，那么容器能使用两倍于内存的 swap 大小，如果 --memory 对应的值是 200M，那么容器可以使用 400M swap

如果 --memory-swap 的值为 -1，那么不限制 swap 的使用，也就是说主机有多少 swap，容器都可以使用

--memory-swappiness：

  默认情况下，主机可以把容器使用的匿名页（anonymous page）swap 出来，你可以设置一个 0-100 之间的值，代表允许 swap 出来的比例

 

--memory-reservation：

  设置一个内存使用的 soft limit，如果 docker 发现主机内存不足，会执行 OOM 操作。这个值必须小于 --memory 设置的值

 

--kernel-memory：

  容器能够使用的 kernel memory 大小，最小值为 4m。

 

--oom-kill-disable：

  是否运行 OOM 的时候杀死容器。只有设置了 -m，才可以把这个选项设置为 false，否则容器会耗尽主机内存，而且导致主机应用被杀死

 

如果限制容器的内存使用为 64M，在申请 64M 资源的情况下，容器运行正常（如果主机上内存非常紧张，并不一定能保证这一点）：

 

\# docker run --rm -it -m 64m progrium/stress --vm 1 --vm-bytes 64M --vm-hang 0

WARNING: Your kernel does not support swap limit capabilities or the cgroup is not mounted. Memory limited without swap.

stress: info: [1] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd

stress: dbug: [1] using backoff sleep of 3000us

stress: dbug: [1] --> hogvm worker 1 [7] forked

stress: dbug: [7] allocating 67108864 bytes ...

stress: dbug: [7] touching bytes in strides of 4096 bytes ...

stress: dbug: [7] sleeping forever with allocated memory

.....

 

而如果申请 100M 内存，会发现容器里的进程被 kill 掉了（worker 7 got signal 9，signal 9 就是 kill 信号）

 

\# docker run --rm -it -m 64m progrium/stress --vm 1 --vm-bytes 100M --vm-hang 0 

WARNING: Your kernel does not support swap limit capabilities or the cgroup is not mounted. Memory limited without swap.

stress: info: [1] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd

stress: dbug: [1] using backoff sleep of 3000us

stress: dbug: [1] --> hogvm worker 1 [7] forked

stress: dbug: [7] allocating 104857600 bytes ...

stress: dbug: [7] touching bytes in strides of 4096 bytes ...

stress: FAIL: [1] (415) <-- worker 7 got signal 9

stress: WARN: [1] (417) now reaping child worker processes

stress: FAIL: [1] (421) kill error: No such process

stress: FAIL: [1] (451) failed run completed in 0s

  

## io资源限制

对于磁盘来说，考量的参数是容量和读写速度，因此对容器的磁盘限制也应该从这两个维度出发。目前 docker 支持对磁盘的读写速度进行限制，但是并没有方法能限制容器能使用的磁盘容量（一旦磁盘 mount 到容器里，容器就能够使用磁盘的所有容量）。

 

限制磁盘的读写速率

docker 允许你直接限制磁盘的读写速率，对应的参数有：

--device-read-bps：磁盘每秒最多可以读多少比特（bytes）

--device-write-bps：磁盘每秒最多可以写多少比特（bytes）

 

上面两个参数的值都是磁盘以及对应的速率，限制 limit 为正整数，单位可以是 kb、mb 和 gb。

 

比如可以把设备的读速率限制在 1mb：

\# docker run -it --device /dev/sda:/dev/sda --device-read-bps /dev/sda:1mb ubuntu:16.04 bash 

 

root@6c048edef769:/# cat /sys/fs/cgroup/blkio/blkio.throttle.read_bps_device 

8:0 1048576

 

root@6c048edef769:/# dd iflag=direct,nonblock if=/dev/sda of=/dev/null bs=5M count=10

10+0 records in

10+0 records out

52428800 bytes (52 MB) copied, 50.0154 s, 1.0 MB/s

 

从磁盘中读取 50m 花费了 50s 左右，说明磁盘速率限制起了作用。

 

另外两个参数可以限制磁盘读写频率（每秒能执行多少次读写操作）：

--device-read-iops：磁盘每秒最多可以执行多少 IO 读操作

--device-write-iops：磁盘每秒最多可以执行多少 IO 写操作

 

上面两个参数的值都是磁盘以及对应的 IO 上限。

 

比如，可以让磁盘每秒最多读 100 次：

 

\# docker run -it --device /dev/sda:/dev/sda --device-read-iops /dev/sda:100 ubuntu:16.04 bash root@2e3026e9ccd2:/# dd iflag=direct,nonblock if=/dev/sda of=/dev/null bs=1k count=1000

1000+0 records in

1000+0 records out

1024000 bytes (1.0 MB) copied, 9.9159 s, 103 kB/s

 

从测试中可以看出，容器设置了读操作的 iops 为 100，在容器内部从 block 中读取 1m 数据（每次 1k，一共要读 1000 次），共计耗时约 10s，换算起来就是 100 iops/s，符合预期结果。

 

# 端口转发

daocloud官网查看mysql使用方案，并进行测试

 

容器：172.16.0.2 5000

client----->eth0:10.18.45.197------->172.16.0.2:5000

​            5000

 

使用端口转发解决容器端口访问问题

 

-p:

创建应用容器的时候，一般会做端口映射，这样是为了让外部能够访问这些容器里的应用。可以用多个-p指定多个端口映射关系。

 

mysql应用端口转发：

查看本地地址：

\#ip a

  ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000

  link/ether 00:0c:29:0a:5b:8b brd ff:ff:ff:ff:ff:ff

  inet 192.168.245.134/24 brd 192.168.245.255 scope global dynamic ens33

​    valid_lft 1444sec preferred_lft 1444sec

 

运行容器：使用-p作端口转发，把本地3307转发到容器的3306，其他参数需要查看发布容器的页面提示

\# docker run --name mysql1 -p 3307:3306  -e MYSQL_ROOT_PASSWORD=123 daocloud.io/library/mysql

 

查看Ip地址：

[root@master /]# docker inspect  mysql1 | grep IPAddress

​      "SecondaryIPAddresses": null,

​      "IPAddress": "172.17.0.2",

​          "IPAddress": "172.17.0.2",

 

通过本地IP：192.168.245.134的3307端口访问容器mysql1内的数据库，出现如下提示恭喜你

[root@master /]# mysql -u root -p123 -h 192.168.245.134 -P3307

Welcome to the MariaDB monitor.  Commands end with ; or \g.

Your MySQL connection id is 3

Server version: 5.7.18 MySQL Community Server (GPL)

 

Copyright (c) 2000, 2016, Oracle, MariaDB Corporation Ab and others.

 

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

 

MySQL [(none)]> 

 

-P:

当使用-P标记时，Docker 会随机映射一个 49000~49900 的端口到内部容器开放的网络端口。如下：

[root@localhost ~]# docker images

REPOSITORY      TAG         IMAGE ID       CREATED       SIZE

docker.io/redis   latest        e4a35914679d     2 weeks ago     182.9 MB

 

[root@localhost ~]# docker run --name myredis -P -d docker.io/redis

805d0e21e531885aad61d3e82395210b50621f1991ec4b7f9a0e25c815cc0272

 

[root@localhost ~]# docker ps

CONTAINER ID     IMAGE        COMMAND          CREATED       STATUS        PORTS           NAMES

805d0e21e531     docker.io/redis   "docker-entrypoint.sh"  4 seconds ago    Up 3 seconds     0.0.0.0:32768->6379/tcp  myredis

 

从上面的结果中可以看出，本地主机的32768端口被映射到了redis容器的6379端口上，也就是说访问本机的32768

端口即可访问容器内redis端口。

 

测试看下，登陆redis容器，随意写个数据

[root@localhost ~]# docker run --rm -it --name myredis2 --link myredis:redisdb docker.io/redis /bin/

bash

root@be44d955d6f4:/data# redis-cli -h redisdb -p 6379

redisdb:6379> set wing 123

OK

redisdb:6379>

 

在别的机器上通过上面映射的端口32768连接这个容器的redis

\# redis-cli -h 192.168.245.134 -p 32768

192.168.1.23:32768> get wing

"123"

 

# 容器卷

新卷只能在容器创建过程当中挂载

\# docker run -it --name="voltest" -v /tmp:/test  daocloud.io/library/centos:5 /bin/bash

 

共享其他容器的卷：

\# docker run -it --volumes-from bc4181  daocloud.io/library/centos:5  /bin/bash

 

实际应用中可以利用多个-v选项把宿主机上的多个目录同时共享给新建容器：

比如：	

\# docker run -it -v /abc:/abc -v /def:/def 1ae9

 

\# docker run  -v /vol/index.html:/usr/share/nginx/html/index.html -it nginx /bin/bash

 

注意：

如果是文件共享，数据不能同步更新

## Volume

容器技术使用了 rootfs 机制和 Mount Namespace，构建出了一个同宿主机完全隔离开的文件系统环境。这时候，就需要考虑这样两个问题：

容器里进程新建的文件，怎么才能让宿主机获取到？

宿主机上的文件和目录，怎么才能让容器里的进程访问到？

 

这正是 Docker Volume 要解决的问题：Volume 机制，允许你将宿主机上指定的目录或者文件，挂载到容器里面进行读取和修改操作。

 

在 Docker 项目里，它支持两种 Volume 声明方式，可以把宿主机目录挂载进容器的 /test 目录当中：

\# docker run -v /test ...

\# docker run -v /home:/test ...

这两种声明方式的本质是相同的：都是把一个宿主机的目录挂载进了容器的 /test 目录。

 

第一种情况没有显示声明宿主机目录，Docker 就会默认在宿主机上创建一个临时目录 /var/lib/docker/volumes/[VOLUME_ID]/_data，然后把它挂载到容器的 /test 目录上。

第二种情况，Docker 就直接把宿主机的 /home 目录挂载到容器的 /test 目录上。

 

那么，Docker 又是如何做到把一个宿主机上的目录或者文件，挂载到容器里面去呢？难道又是 Mount Namespace 的黑科技吗？

 

实际上，并不需要这么麻烦。

 

已经介绍过，当容器进程被创建之后，尽管开启了 Mount Namespace，但是在它执行 chroot（或者 pivot_root）之前，容器进程一直可以看到宿主机上的整个文件系统。

 

而宿主机上的文件系统，也自然包括了要使用的容器镜像。这个镜像的各个层，保存在 /var/lib/docker/aufs/diff 目录下，在容器进程启动后，它们会被联合挂载在 /var/lib/docker/aufs/mnt/ 目录中，这样容器所需的 rootfs 就准备好了。

 

所以，只需要在 rootfs 准备好之后，在执行 chroot 之前，把 Volume 指定的宿主机目录（比如 /home 目录），挂载到指定的容器目录（比如 /test 目录）在宿主机上对应的目录（即 /var/lib/docker/aufs/mnt/[可读写层 ID]/test）上，这个 Volume 的挂载工作就完成了。

 

由于执行这个挂载操作时，"容器进程"已经创建了，也就意味着此时 Mount Namespace 已经开启了。所以，这个挂载事件只在这个容器里可见。你在宿主机上，是看不见容器内部的这个挂载点的。这就保证了容器的隔离性不会被 Volume 打破。

 

注意：这里提到的 " 容器进程 "，是 Docker 创建的一个容器初始化进程 (dockerinit)，而不是应用进程 (ENTRYPOINT + CMD)。dockerinit 会负责完成根目录的准备、挂载设备和目录、配置 hostname 等一系列需要在容器内进行的初始化操作。最后，它通过 execv() 系统调用，让应用进程取代自己，成为容器里的 PID=1 的进程。

 

而这里要使用到的挂载技术，就是 Linux 的绑定挂载（bind mount）机制。它的主要作用就是，允许你将一个目录或者文件，而不是整个设备，挂载到一个指定的目录上。并且，这时你在该挂载点上进行的任何操作，只是发生在被挂载的目录或者文件上，而原挂载点的内容则会被隐藏起来且不受影响。

 

其实，如果你了解 Linux 内核的话，就会明白，绑定挂载实际上是一个 inode 替换的过程。在 Linux 操作系统中，inode 可以理解为存放文件内容的"对象"，而 dentry，也叫目录项，就是访问这个 inode 所使用的"指针"。

 

mount --bind /home /test，会将 /home 挂载到 /test 上。其实相当于将 /test 的 dentry，重定向到了 /home 的 inode。这样当修改 /test 目录时，实际修改的是 /home 目录的 inode。这也就是为何，一旦执行 umount 命令，/test 目录原先的内容就会恢复：因为修改真正发生在的，是 /home 目录里。

 

进程在容器里对这个 /test 目录进行的所有操作，都实际发生在宿主机的对应目录（比如，/home，或者 /var/lib/docker/volumes/[VOLUME_ID]/_data）里，而不会影响容器镜像的内容。

 

这个 /test 目录里的内容，既然挂载在容器 rootfs 的可读写层，它会不会被 docker commit 提交掉呢？也不会。

 

原因前面提到过。容器的镜像操作，比如 docker commit，都是发生在宿主机空间的。而由于 Mount Namespace 的隔离作用，宿主机并不知道这个绑定挂载的存在。所以，在宿主机看来，容器中可读写层的 /test 目录（/var/lib/docker/aufs/mnt/[可读写层 ID]/test），始终是空的。

 

不过，由于 Docker 一开始还是要创建 /test 这个目录作为挂载点，所以执行了 docker commit 之后，新产生的镜像里，会多出来一个空的 /test 目录。毕竟，新建目录操作，又不是挂载操作，Mount Namespace 对它可起不到"障眼法"的作用。

 

1.启动一个 helloworld 容器，给它声明一个 Volume，挂载在容器里的 /test 目录上：

\# docker run -d -v /test helloworld

cf53b766fa6f

 

2.容器启动之后，查看一下这个 Volume 的 ID：

\# docker volume ls

DRIVER        VOLUME NAME

local        cb1c2f7221fa9b0971cc35f68aa1034824755ac44a034c0c0a1dd318838d3a6d

 

3.使用这个 ID，可以找到它在 Docker 工作目录下的 volumes 路径：

\# ls /var/lib/docker/volumes/cb1c2f7221fa/_data/

这个 _data 文件夹，就是这个容器的 Volume 在宿主机上对应的临时目录了。

 

4.在容器的 Volume 里，添加一个文件 text.txt：

\# docker exec -it cf53b766fa6f /bin/sh

cd test/

touch text.txt

 

5.再回到宿主机，就会发现 text.txt 已经出现在了宿主机上对应的临时目录里：

\# ls /var/lib/docker/volumes/cb1c2f7221fa/_data/

text.txt

 

可是，如果你在宿主机上查看该容器的可读写层，虽然可以看到这个 /test 目录，但其内容是空的：

\# ls /var/lib/docker/aufs/mnt/6780d0778b8a/test

可以确认，容器 Volume 里的信息，并不会被 docker commit 提交掉；但这个挂载点目录 /test 本身，则会出现在新的镜像当中。

 

以上内容，就是 Docker Volume 的核心原理了。

 

Docker 容器"全景图"：

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpsjMtr7w.jpg) 

一个"容器"，实际上是一个由 Linux Namespace、Linux Cgroups 和 rootfs 三种技术构建出来的进程的隔离环境。

 

 

 

# 部署centos7容器应用

**镜像下载**

\# docker pull daocloud.io/library/centos:latest

**包管理**

默认情况下，为了减小镜像的尺寸，在构建 CentOS 镜像时用了yum的nodocs选项。 如果您安装一个包后发现文件缺失，请在/etc/yum.conf中注释掉tsflogs=nodocs并重新安装您的包。 

 

systemd 整合:

因为 systemd 要求 CAPSYSADMIN 权限，从而得到了读取到宿主机 cgroup 的能力，CentOS7 中已经用 fakesystemd 代替了 systemd 来解决依赖问题。 如果仍然希望使用 systemd，可用参考下面的 Dockerfile：

 

\# vim Dockerfile

FROM daocloud.io/library/centos:latest

MAINTAINER "wing"  wing@qq.com

ENV container docker

RUN yum -y swap -- remove fakesystemd -- install  systemd systemd-libs

RUN yum -y update; yum clean all; \

(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \

rm -f /lib/systemd/system/multi-user.target.wants/*;\

rm -f /etc/systemd/system/*.wants/*;\

rm -f /lib/systemd/system/local-fs.target.wants/*; \

rm -f /lib/systemd/system/sockets.target.wants/*udev*; \

rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \

rm -f /lib/systemd/system/basic.target.wants/*;\

rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]

 

这个Dockerfile删除fakesystemd 并安装了 systemd。然后再构建基础镜像:

\# docker build --rm -t local/c7-systemd .

 

一个包含 systemd 的应用容器示例

 

为了使用像上面那样包含 systemd 的容器，需要创建一个类似下面的Dockerfile：

\# vim Dockerfile

FROM local/c7-systemd

RUN yum -y install httpd; yum clean all; systemctl enable httpd.service

EXPOSE 80

CMD ["/usr/sbin/init"]

 

构建镜像:

\# docker build --rm -t local/c7-systemd-httpd .

 

运行包含 systemd 的应用容器:

为了运行一个包含 systemd 的容器，需要使用--privileged选项， 并且挂载主机的 cgroups 文件夹。 下面是运行包含 systemd 的 httpd 容器的示例命令：

 

\# docker run --privileged -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 80:80 local/c7-systemd-httpd

注意：上条命令不能添加/bin/bash，添加了会导致服务不可用，而且有些服务可能会发现之前提到的权限不够的问题，但是如果不加会运行在前台(没有用-d)，可以用ctrl+p+q放到后台去

 

 

测试可用：

\# elinks --dump http://docker    //下面为apache默认页面

​                      Testing 123..

  This page is used to test the proper operation of the [1]Apache HTTP

  server after it has been installed. If you can read this page it means

  that this site is working properly. This server is powered by [2]CentOS.

  

再来个安装openssh-server的例子：

\# vim Dockerfile

FROM local/c7-systemd

RUN yum -y install openssh-server; yum clean all; systemctl enable sshd.service

RUN echo 1 | passwd --stdin root

EXPOSE 22

CMD ["/usr/sbin/init"]

 

\# docker build --rm -t local/c7-systemd-sshd .  

\# docker run --privileged -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 2222:22 local/c7-systemd-sshd  

\# ssh docker -p 2222  //docker为我宿主机的主机名称

# docker网络

## 容器网络分类

注：

面试用，用了编排之后就没有用了

 

docker安装后，默认会创建三种网络类型，bridge、host和none

 

查看当前网络：

\# docker network list

NETWORK  ID      NAME        DRIVER        SCOPE

90b22f633d2f     bridge      bridge        local

e0b365da7fd2     host       host        local

da7b7a090837     none       null         local

 

1、bridge:网络桥接

  默认情况下启动、创建容器都是用该模式，所以每次docker容器重启时会按照顺序获取对应ip地址，这就导致容器每次重启，ip都发生变化

 

2、none：无指定网络

  启动容器时，可以通过--network=none,docker容器不会分配局域网ip

 

3、host：主机网络

  docker容器的网络会附属在主机上，两者是互通的。

使用host网络创建容器：

\# docker run -it --name testnginx1 --net host 27a18801 /bin/bash

 

4、固定ip（个人认为是bridge）:

 创建固定Ip的容器：

 	4.1、创建自定义网络类型，并且指定网段

  	#docker network create --subnet=192.168.0.0/16 staticnet

 

​    通过docker network ls可以查看到网络类型中多了一个staticnet

 

  4.2、使用新的网络类型创建并启动容器

​    \#docker run -it --name userserver --net staticnet --ip 192.168.0.2 centos:6 /bin/bash

 

​    通过docker inspect可以查看容器ip为192.168.0.2，关闭容器并重启，发现容器ip并未发生改变

 

\# docker run -it --rm --name "test" -v /test/b.txt:/tmp/b.txt -v /tmp:/abc --net bridge --ip 172.17.0.9 1f8fe54 /bin/sh

docker: Error response from daemon: user specified IP address is supported on user defined networks only.

 

## 异主容器互联

### 方式1、路由方式

​              

小规模docker环境大部分运行在单台主机上，如果公司大规模采用docker，那么多个宿主机上的docker如何互联

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpsBL59hl.jpg)Docker默认的内部ip为172.17.42.0网段，所以必须要修改其中一台的默认网段以免ip冲突。

\# vim /etc/sysconfig/docker-network

DOCKER_NETWORK_OPTIONS= --bip=172.18.42.1/16

\# reboot

 

docker 130上：

\# route add -net 172.18.0.0/16 gw 192.168.18.128

 

docker 128上：

\# route add -net 172.17.0.0/16 gw 192.168.18.130

 

现在两台宿主机里的容器就可以通信了。

 

### 方式2、open vswitch

如果要在生产和测试环境大规模采用docker技术，首先就需要解决不同物理机建的docker容器互联问题。

centos7环境下可以采用open vswitch实现不同物理服务器上的docker容器互联

 

环境：

2台宿主机：

192.168.245.143：

\# hostnamectl set-hostname docker1

 

192.168.245.155：

\# hostnamectl set-hostname docker2

 

关闭防火墙和selinux:

\# setenforce 0 && systemctl stop firewalld

 

开启路由：

所有宿主机都开，wing测试如果不开路由 服务器启动可能会有问题（启动服务成功，但查看状态会有很多fail）

\# echo 1 > /proc/sys/net/ipv4/ip_forward 

 

安装open vswitch：  

每台docker宿主机器上都要安装

\# yum -y install wget openssl-devel kernel-devel

\# yum groupinstall "Development Tools"  //7里面这步可取消

 

添加ovswitch用户，并使用ovswitch用户安装open vswitch

\# adduser ovswitch

\# su - ovswitch

$ wget http://openvswitch.org/releases/openvswitch-2.3.0.tar.gz

$ tar -zxvpf openvswitch-2.3.0.tar.gz 

$ mkdir -p ~/rpmbuild/SOURCES

$ sed 's/openvswitch-kmod, //g' openvswitch-2.3.0/rhel/openvswitch.spec > openvswitch-2.3.0/rhel/openvswitch_no_kmod.spec

$ cp openvswitch-2.3.0.tar.gz rpmbuild/SOURCES/  

$ rpmbuild -bb --without check ~/openvswitch-2.3.0/rhel/openvswitch_no_kmod.spec  

$ exit  

\# yum localinstall /home/ovswitch/rpmbuild/RPMS/x86_64/openvswitch-2.3.0-1.x86_64.rpm

\# mkdir /etc/openvswitch

 

启动服务：

\# systemctl start openvswitch.service

\# systemctl  status openvswitch.service -l

 

\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在docker1宿主机和docker2宿主机上分别建立桥接网卡和路由：

\# yum install -y bridge-utils

 

\# ovs-vsctl add-br obr0

 

\# ovs-vsctl add-port obr0 gre0 -- set Interface gre0 type=gre options:remote_ip=192.168.245.143

//这里的remote_ip指的本机IP

 

\# brctl addbr kbr0

 

\# brctl addif kbr0 obr0

 

\# ip link set dev docker0 down

 

\# ip link del dev docker0

 

\# vim /etc/sysconfig/network-scripts/ifcfg-kbr0

ONBOOT=yes

BOOTPROTO=static

IPADDR=192.168.101.10

NETMASK=255.255.255.0

GATEWAY=192.168.101.0

USERCTL=no

TYPE=Bridge

IPV6INIT=no

DEVICE=kbr0

 

设置到达docker2宿主机新建网桥所在网络的路由

\# vim /etc/sysconfig/network-scripts/route-ens33

192.168.100.0/24 via 192.168.245.155 dev ens33

 

\# systemctl  restart network

 

\# route -n

Kernel IP routing table

Destination   Gateway     Genmask     Flags Metric Ref   Use Iface

0.0.0.0     192.168.245.2  0.0.0.0     UG   100   0     0 ens33

172.18.0.0    0.0.0.0     255.255.0.0   U   0    0     0 docker0

192.168.100.0  192.168.245.155 255.255.255.0  UG   100   0     0 ens33

192.168.101.0  0.0.0.0     255.255.255.0  U   425   0     0 kbr0

192.168.245.0  0.0.0.0     255.255.255.0  U   100   0     0 ens33

 

 

client     192.168.1.9---docker(nginx 80)

​           80--->docker:80

 

﻿虚拟网卡绑定kbr0后下载容器启动测试：

cat /etc/sysconfig/docker-network 

\# /etc/sysconfig/docker-network

DOCKER_NETWORK_OPTIONS="-b=kbr0"

 

\# systemctl  restart docker

 

测试：

分别在两台宿主机上运行容器进行网络测试

 

# 何为进程

假如要写一个计算加法的小程序，这个程序需要的输入来自于一个文件，计算完成后的结果则输出到另一个文件中。

 

由于计算机只认 0 和 1，无论用哪种语言编写这段代码，最后都要通过某种方式翻译成二进制文件，才能在计算机操作系统中运行起来。

 

而为了能够让这些代码正常运行，往往还要给它提供数据，比如这个加法程序所需的输入文件。这些数据加上代码本身的二进制文件，放在磁盘上，就是我们平常所说的一个"程序"，也叫代码的可执行镜像（executable image）。

 

然后，就可以在计算机上运行这个"程序"了。

 

首先，操作系统从"程序"中发现输入数据保存在一个文件中，所以这些数据就被会加载到内存中待命。同时，操作系统又读取到了计算加法的指令，这时，它就需要指示 CPU 完成加法操作。而 CPU 与内存协作进行加法计算，又会使用寄存器存放数值、内存堆栈保存执行的命令和变量。同时，计算机里还有被打开的文件，以及各种各样的 I/O 设备在不断地调用中修改自己的状态。

 

就这样，一旦"程序"被执行起来，它就从磁盘上的二进制文件，变成了计算机内存中的数据、寄存器里的值、堆栈中的指令、被打开的文件，以及各种设备的状态信息的一个集合。像这样一个程序运起来后的计算机执行环境的总和，就是：进程。

 

所以，对于进程来说，它的静态表现就是程序，平常都安安静静地待在磁盘上；而一旦运行起来，它就变成了计算机里的数据和状态的总和，这就是它的动态表现。

 

容器与进程：

而容器技术的核心功能，就是通过约束和修改进程的动态表现，从而为其创造出一个"边界"。

 

 

# 深入理解NameSpace

## 何为Namespace机制

Linux 容器中用来实现"隔离"的技术手段：Namespace。Namespace 技术实际上修改了应用进程看待整个计算机"视图"，即它的"视线"被操作系统做了限制，只能"看到"某些指定的内容。但对于宿主机来说，这些被"隔离"了的进程跟其他进程并没有太大区别。

 

假设已经有一个 Linux 操作系统上的 Docker 项目在运行，环境为：Ubuntu 16.04 和 Docker CE 18.05

  

1.创建一个容器：

\# docker run -it busybox /bin/sh

/ #

 

这条指令翻译成人类的语言就是：请帮我启动一个容器，在容器里执行 /bin/sh，并且给我分配一个命令行终端跟这个容器交互。

 

这样，这台Ubuntu 16.04 机器就变成了一个宿主机，而一个运行着 /bin/sh 的容器，就跑在了这个宿主机里面。

 

\2. 在容器里执行 ps 指令，会发现一些有趣的事情：/bin/sh，就是这个容器内部的第 1 号进程（PID=1），而这个容器里一共只有两个进程在运行。这就意味着，前面执行的 /bin/sh，以及我们刚刚执行的 ps，已经被 Docker 隔离在了一个跟宿主机完全不同的世界当中。

 

/ # ps

PID  USER  TIME COMMAND

 1  root  0:00 /bin/sh

 10 root  0:00 ps

 

本来，每当在宿主机上运行一个 /bin/sh 程序，操作系统都会给它分配一个进程编号，比如 PID=100。这个编号是进程的唯一标识，就像员工的工牌一样。所以 PID=100，可以粗略地理解为这个 /bin/sh 是我们公司里的第 100 号员工，而第 1 号员工就自然是比尔 · 盖茨这样统领全局的人物。

 

而现在，要通过 Docker 把/bin/sh 运行在一个容器当中。这时，Docker 就会在这个第 100 号员工入职时给他施一个"障眼法"让他永远看不到前面的其他 99 个员工，更看不到比尔 · 盖茨。这样，他就会错误地以为自己就是公司里的第 1 号员工。

 

这种机制，其实就是对被隔离应用的进程空间做了手脚，使得这些进程只能看到重新计算过的进程编号，比如 PID=1。可实际上，他们在宿主机的操作系统里，还是原来的第 100 号进程。

 

这种技术，就是 Linux 里面的 Namespace 机制。

 

## Namespace的使用方式

其实只是 Linux 创建新进程的一个可选参数。

 

在 Linux 系统中创建线程的系统调用是 clone()，比如：

  int pid = clone(main_function, stack_size, SIGCHLD, NULL); 

  这个系统调用就会为我们创建一个新的进程，并且返回它的进程号 pid。

 

当用 clone() 系统调用创建一个新进程时，就可以在参数中指定 CLONE_NEWPID 参数，比如：

  int pid = clone(main_function, stack_size, CLONE_NEWPID | SIGCHLD, NULL); 

  这时，新创建的这个进程将会"看到"一个全新的进程空间，在这空间里，它的 PID 是 1。之所以说"看到"，是因为这只是一个"障眼法"，在宿主机真实的进程空间里，这个进程的 PID 还是真实的数值，比如 100。

 

多次执行上面的 clone() 调用，就会创建多个 PID Namespace，而每个 Namespace 里的应用进程，都会认为自己是当前容器里的第 1 号进程，它们既看不到宿主机里真正的进程空间，也看不到其他 PID Namespace 里的具体情况。

 

而除了刚用到的 PID Namespace，Linux 操作系统还提供了 Mount、UTS、IPC、Network 和 User 这些 Namespace，用来对各种不同的进程上下文进行"障眼法"操作。

 

比如，Mount Namespace，用于让被隔离进程只看到当前 Namespace 里的挂载点信息；Network Namespace，用于让被隔离进程看到当前 Namespace 里的网络设备和配置。

 

这，就是 Linux 容器最基本的实现原理了。

 

所以，Docker 容器这个听起来玄而又玄的概念，实际上是在创建容器进程时，指定了这个进程所需要启用的一组 Namespace 参数。这样，容器就只能"看"到当前 Namespace 所限定的资源、文件、设备、状态，或者配置。而对于宿主机以及其他不相关的程序，它就完全看不到了。

 

所以说，容器，其实是一种特殊的进程而已。

 

## 再次对比容器和虚拟机

谈到为"进程划分一个独立空间"的思想，相信你一定会联想到虚拟机。而且，你应该还看过一张虚拟机和容器的对比图。

 

错误：

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpswRz8s9.jpg) 

正解：

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpsIrW8DX.jpg) 

图左，画出了虚拟机的工作原理。Hypervisor 软件是虚拟机最主要的部分。它通过硬件虚拟化功能，模拟出了运行一个操作系统需要的各种硬件，比如 CPU、内存、I/O 设备等等。然后，它在这些虚拟的硬件上安装了一个新的操作系统，即 Guest OS。

 

这样，用户的应用进程能看到的自然也只有 Guest OS 的文件和目录，以及这个机器里的虚拟设备。这就是为什么虚拟机也能起到将不同的应用进程相互隔离的作用。

 

图右，则用一个名为 Docker Engine 的软件替换了 Hypervisor。这也是为什么，很多人会把 Docker 项目称为"轻量级"虚拟化技术的原因，实际上就是把虚拟机的概念套在了容器上。

 

这样的说法，却并不严谨。理解了 Namespace 的工作方式之后，你就会明白，跟真实存在的虚拟机不同，在使用 Docker 的时候，并没有一个真正的"Docker 容器"运行在宿主机里面。Docker 项目帮助用户启动的，还是原来的应用进程，只不过在创建这些进程时，Docker 为它们加上了各种各样的 Namespace 参数。

 

这时，这些进程就会觉得自己是各自 PID Namespace 里的第 1 号进程，只能看到各自 Mount Namespace 里挂载的目录和文件，只能访问到各自 Network Namespace 里的网络设备，就仿佛运行在一个个"容器"里面，与世隔绝。

 

第一张对比图里，不应该把 Docker Engine 或者任何容器管理工具放在跟 Hypervisor 相同的位置，因它们并不像 Hypervisor 那样对应用进程的隔离环境负责，也不会创建任何实体的"容器"，真正对隔离环境负责的是宿主机操作系统本身

 

所以，在这个对比图里，应该把 Docker 画在跟应用同级别并且靠边的位置。这意味着，用户运行在容器里的应用进程，跟宿主机上的其他进程一样，都由宿主机操作系统统一管理，只不过这些被隔离的进程拥有额外设置过的 Namespace 参数。而 Docker 项目在这里扮演的角色，更多的是旁路式的辅助和管理工作。

 

Docker 项目比虚拟机更受欢迎的原因。是因为，使用虚拟化技术作为应用沙盒，就必须要由 Hypervisor 来负责创建虚拟机，这个虚拟机是真实存在的，并且它里面必须运行一个完整的 Guest OS 才能执行用户的应用进程。这就不可避免地带来了额外的资源消耗和占用。

 

一个运行着 CentOS 的 KVM 虚拟机启动后，在不做优化的情况下，虚拟机自己就需要占用 100~200 MB 内存。此外，用户应用运行在虚拟机里面，它对宿主机操作系统的调用就不可避免地要经过虚拟化软件的拦截和处理，这本身又是一层性能损耗，尤其对计算资源、网络和磁盘 I/O 的损耗非常大。

 

相比之下，容器化后的用户应用，却依然还是一个宿主机上的普通进程，那些因为虚拟化而带来的性能损耗都是不存在的；另一方面，使用 Namespace 作为隔离手段的容器并不需要单独的 Guest OS，这使得容器额外的资源占用几乎可以忽略不计。

 

所以说，"敏捷"和"高性能"是容器相较于虚拟机最大的优势，也是它能够在 PaaS 这种更细粒度的资源管理平台上大行其道的重要原因。

## Namespace 隔离机制的不足

基于 Linux Namespace 的隔离机制相比于虚拟化技术的不足之处：

1. 最主要的问题是：隔离得不彻底。

既然容器只是运行在宿主机上的一种特殊的进程，那么多个容器之间使用的就还是同一个宿主机的操作系统内核。

 

尽管可以在容器里通过 Mount Namespace 单独挂载其他不同版本的操作系统文件，比如 CentOS 或者 Ubuntu，但这并不能改变共享宿主机内核的事实。如果你要在 Windows 宿主机上运行 Linux 容器，或者在低版本的 Linux 宿主机上运行高版本的 Linux 容器，都是行不通的。

 

而相比之下，拥有硬件虚拟化技术和独立 Guest OS 的虚拟机就要方便得多了。最极端的例子是，Microsoft 的云计算平台 Azure，实际上就是运行在 Windows 服务器集群上的，但这并不妨碍你在它上面创建各种 Linux 虚拟机出来。

 

2. 在 Linux 内核中，有很多资源和对象是不能被 Namespace 化的，最典型的例子就是：时间。

如果你的容器中的程序使用 settimeofday(2) 系统调用修改了时间，整个宿主机的时间都会被随之修改，这显然不符合用户的预期。相比于在虚拟机里面可以随便折腾的自由度，在容器里部署应用的时候，"什么能做，什么不能做"，就是用户必须考虑的一个问题。

 

3. 因为共享宿主机内核的事实，容器给应用暴露出来的攻击面是相当大的，应用"越狱"的难度自然也比虚拟机低得多。

尽管实践中可以使用 Seccomp 等技术，对容器内部发起的所有系统调用进行过滤和甄别来进行安全加固，但这种方法因为多了一层对系统调用的过滤，一定会拖累容器的性能。何况，默认情况下，谁也不知道到底该开启哪些系统调用，禁止哪些系统调用。

所以，生产环境中，没有人敢把运行在物理机上的 Linux 容器直接暴露到公网上。当然，基于虚拟化或者独立内核技术的容器实现，则可以比较好地在隔离与性能之间做出平衡。

## 动手实现namespace隔离

通过理解docker exec 操作深入Linux Namespace工作原理

 

docker exec 是怎么做到进入容器里的？

Linux Namespace 创建的隔离空间虽然看不见摸不着，但一个进程的 Namespace 信息在宿主机上是确确实实存在的，并且是以一个文件的方式存在。

一个进程，可以选择加入到某个进程已有的 Namespace 当中，从而达到"进入"这个进程所在容器的目的，这正是 docker exec 的实现原理

 

做个实验：

1.查看当前正在运行的 Docker 容器的进程号

\# docker inspect --format '{{ .State.Pid }}'  4ddf4638572d

25686

 

2.查看宿主机的 proc 文件，可以看到这个 25686 进程所有 Namespace 对应的文件：

\# ls -l  /proc/25686/ns

total 0

lrwxrwxrwx 1 root root 0 Aug 13 14:05 cgroup -> cgroup:[4026531835]

lrwxrwxrwx 1 root root 0 Aug 13 14:05 ipc -> ipc:[4026532278]

lrwxrwxrwx 1 root root 0 Aug 13 14:05 mnt -> mnt:[4026532276]

lrwxrwxrwx 1 root root 0 Aug 13 14:05 net -> net:[4026532281]

lrwxrwxrwx 1 root root 0 Aug 13 14:05 pid -> pid:[4026532279]

lrwxrwxrwx 1 root root 0 Aug 13 14:05 pid_for_children -> pid:[4026532279]

lrwxrwxrwx 1 root root 0 Aug 13 14:05 user -> user:[4026531837]

lrwxrwxrwx 1 root root 0 Aug 13 14:05 uts -> uts:[4026532277]

 

一个进程的每种 Linux Namespace，都在它对应的 /proc/[进程号]/ns 下有一个对应的虚拟文件，并且链接到一个真实的 Namespace 文件上。

 

有了这样的 Linux Namespace 的文件，就可以对 Namespace 做一些很有意义事情了，比如：加入到一个已经存在的 Namespace 当中。

 

也就是说：一个进程，可以选择加入到某个进程已有的 Namespace 当中，从而达到"进入"这个进程所在容器的目的，这正是 docker exec 的实现原理。

 

\3. 这个操作所依赖一个名叫 setns() 的 Linux 系统调用。调用方法如下：

\# vim set_ns.c

\#define _GNU_SOURCE

\#include <fcntl.h>

\#include <sched.h>

\#include <unistd.h>

\#include <stdlib.h>

\#include <stdio.h>

 

\#define errExit(msg) do { perror(msg); exit(EXIT_FAILURE);} while (0)

 

int main(int argc, char *argv[]) {

  int fd;

  

  fd = open(argv[1], O_RDONLY);

  if (setns(fd, 0) == -1) {

​    errExit("setns");

  }

  execvp(argv[2], &argv[2]); 

  errExit("execvp");

}

 

代码功能：

  它一共接收两个参数，第一个参数是 argv[1]，即当前进程要加入的 Namespace 文件的路径，比如 /proc/25686/ns/net；而第二个参数，则是你要在这个 Namespace 里运行的进程，比如 /bin/bash。

 

  代码的核心操作，则是通过 open() 系统调用打开指定的 Namespace 文件，并把这个文件的描述符 fd 交给 setns() 使用。在 setns() 执行后，当前进程就加入了这个文件对应的 Linux Namespace 当中。

 

\4. 编译执行这个程序，加入到容器进程（PID=25686）的 Network Namespace 中：

\# gcc -o set_ns set_ns.c 

\# ./set_ns /proc/25686/ns/net /bin/bash 

\# ip a 

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000

  link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

  inet 127.0.0.1/8 scope host lo

​    valid_lft forever preferred_lft forever

60: eth0@if61: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 

  link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0

  inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0

​    valid_lft forever preferred_lft forever

 

实际上，在 setns() 之后看到的这两个网卡，正是在前面启动的 Docker 容器里的网卡。也就是说，新创建的这个 /bin/bash 进程，由于加入了该容器进程（PID=25686）的 Network Namepace，它看到的网络设备与这个容器里是一样的，即：/bin/bash 进程的网络设备视图，也被修改了。

 

而一旦一个进程加入到了另一个 Namespace 当中，在宿主机的 Namespace 文件上，也会有所体现。

 

在宿主机上，你可以用 ps 指令找到这个 set_ns 程序执行的 /bin/bash 进程，其真实的 PID 是 28499：

 

\# 在宿主机上

\# ps aux | grep /bin/bash

root   28499  0.0  0.0 19944  3612 pts/0   S   14:15  0:00 /bin/bash

这时，如果按照前面介绍过的方法，查看一下这个 PID=28499 的进程的 Namespace，你就会发现这样一个事实：

 

\# ls -l /proc/28499/ns/net

lrwxrwxrwx 1 root root 0 Aug 13 14:18 /proc/28499/ns/net -> net:[4026532281]

 

\# ls -l  /proc/25686/ns/net

lrwxrwxrwx 1 root root 0 Aug 13 14:05 /proc/25686/ns/net -> net:[4026532281]

在 /proc/[PID]/ns/net 目录下，这个 PID=28499 进程，与前面的 Docker 容器进程（PID=25686）指向的 Network Namespace 文件完全一样。说明这两个进程，共享了这个名叫 net:[4026532281] 的 Network Namespace。

 

启动一个容器并"加入"到另一个容器的 Network Namespace 里

Docker 还专门提供了一个参数，可以启动一个容器并"加入"到另一个容器的 Network Namespace 里，这个参数是 -net

 

比如:

\# docker run -it --net container:4ddf4638572d busybox ifconfig

这样，新启动的容器，就会直接加入到 ID=4ddf4638572d 的容器，也就是前面的创建的 Python 应用容器（PID=25686）的 Network Namespace 中。所以，这里 ifconfig 返回的网卡信息，跟前面那个小程序返回的结果一模一样

 

而如果指定--net=host，这个容器就不会为进程启用 Network Namespace。也就是，这个容器拆除了 Network Namespace 的"隔离墙"，所以，它会和宿主机上的其他普通进程一样，直接共享宿主机的网络栈。这就为容器直接操作和使用宿主机网络提供了一个渠道。

 

# 深入理解cgroups

重申docker本质：

一个正在运行的 Docker 容器，其实就是一个启用了多个 Linux Namespace 的应用进程，而这个进程能够使用的资源量，则受 Cgroups 配置的限制。容器是一个"单进程"模型

 

容器的"限制"问题

已经通过 Linux Namespace 创建了一个"容器"，为什么还要对容器做"限制"？

 

还是以 PID Namespace 为例，虽然容器内的 1 号进程在"障眼法"的干扰下只能看到容器里的情况，但是宿主机上，它作为第 100 号进程与其他所有进程之间依然是平等竞争关系。这就意味着，虽然第 100 号进程表面上被隔离了起来，但是它所能够使用到的资源（比如 CPU、内存），却是可以随时被宿主机上的其他进程占用的。当然，这个进程自己也可能把所有资源吃光。这些情况，显然都不是一个"沙盒"应该表现出来的合理行为。

 

而Linux Cgroups 就是 Linux 内核中用来为进程设置资源限制的一个重要功能。

 

有意思的是，Google 的工程师在 2006 年发起这项特性的时候，曾将它命名为"进程容器"（process container）。实际上，在 Google 内部，"容器"这个术语长期以来都被用于形容被 Cgroups 限制过的进程组。后来 Google 的工程师们说，他们的 KVM 虚拟机也运行在 Borg 所管理的"容器"里，其实也是运行在 Cgroups"容器"当中。这和我们今天说的 Docker 容器差别很大。

 

Linux Cgroups 的全称是 Linux Control Group。它最主要的作用，是限制一个进程组能够使用的资源上限，包括 CPU、内存、磁盘、网络带宽等。

 

此外，Cgroups 还能够对进程进行优先级设置、审计，以及将进程挂起和恢复等操作。

 

现在重点探讨它与容器关系最紧密的"限制"能力：

Linux 中，Cgroups 给用户暴露出来的操作接口是文件系统，即它以文件和目录的方式组织在操作系统的 /sys/fs/cgroup 路径下。

 

用 mount 指令把它们展示出来：

\# mount -t cgroup 

cpuset on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset)

cpu on /sys/fs/cgroup/cpu type cgroup (rw,nosuid,nodev,noexec,relatime,cpu)

cpuacct on /sys/fs/cgroup/cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpuacct)

blkio on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)

memory on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)

...

输出结果，是一系列文件系统目录。在 /sys/fs/cgroup 下面有很多诸如 cpuset、cpu、 memory 这样的子目录，也叫子系统。这些都是这台机器当前可以被 Cgroups 进行限制的资源种类。而在子系统对应的资源种类下，你就可以看到该类资源具体可以被限制的方法。

 

比如，对 CPU 子系统来说，可以看到如下几个配置文件：

\# ls /sys/fs/cgroup/cpu

cgroup.clone_children cpu.cfs_period_us cpu.rt_period_us  cpu.shares notify_on_release

cgroup.procs    cpu.cfs_quota_us  cpu.rt_runtime_us cpu.stat  tasks

 

比如：cfs_period 和 cfs_quota 这两个参数需要组合使用，可以用来限制进程在长度为 cfs_period 的一段时间内，只能被分配到总量为 cfs_quota 的 CPU 时间。

 

\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

实例验证:

\1. 需要在对应的子系统下面创建一个目录，这个目录称为一个"控制组",操作系统会在你新创建的目录下，自动生成该子系统对应的资源限制文件。

\# cd /sys/fs/cgroup/cpu

\# mkdir container   

\# ls container/

cgroup.clone_children cpu.cfs_period_us cpu.rt_period_us  cpu.shares notify_on_release

cgroup.procs    cpu.cfs_quota_us  cpu.rt_runtime_us cpu.stat  tasks

 

\2. 在后台执行一条脚本：

\# while : ; do : ; done &

[1] 226

 

它执行了一个死循环，可以把计算机的 CPU 吃到 100%，根据它的输出，可以看到这个脚本在后台运行的进程号（PID）是 226。

 

\3. 用 top 指令确认一下 CPU 有没有被打满：用 1 分开查看cpu

\# top

%Cpu0 :100.0 us, 0.0 sy, 0.0 ni, 0.0 id, 0.0 wa, 0.0 hi, 0.0 si, 0.0 st

在输出里可以看到，CPU 的使用率已经 100% 了（%Cpu0 :100.0 us）。

 

此时，通过查看 container 目录下的文件，看到 container 控制组里的 CPU quota 还没有任何限制（即：-1），CPU period 则是默认的 100 ms（100000 us）：

 

$ cat /sys/fs/cgroup/cpu/container/cpu.cfs_quota_us 

-1

$ cat /sys/fs/cgroup/cpu/container/cpu.cfs_period_us 

100000

 

\4. 通过修改这些文件的内容来设置限制。

  比如，向 container 组里的 cfs_quota 文件写入 20 ms（20000 us）：

  \# echo 20000 > /sys/fs/cgroup/cpu/container/cpu.cfs_quota_us

 

  意味着在每 100 ms 的时间里，被该控制组限制的进程只能使用 20 ms 的 CPU 时间，也就是说这个进程只能使用到 20% 的 CPU 带宽。

 

\5. 把被限制的进程的 PID 写入 container 组里的 tasks 文件，上面的设置就会对该进程生效：

  \# echo 226 > /sys/fs/cgroup/cpu/container/tasks 

 

\6. 再次用 top 查看，验证效果：

  \# top

  %Cpu0 : 20.3 us, 0.0 sy, 0.0 ni, 79.7 id, 0.0 wa, 0.0 hi, 0.0 si, 0.0 st

 

  可以看到，计算机的 CPU 使用率立刻降到了 20%（%Cpu0 : 20.3 us）。

 

\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

除 CPU 子系统外，Cgroups 的每一项子系统都有其独有的资源限制能力：

  blkio：

​    为块设备设定I/O 限制，一般用于磁盘等设备；

  cpuset：

​    为进程分配单独的 CPU 核和对应的内存节点；

  memory：

​    为进程设定内存使用的限制。

 

Linux Cgroups 的设计，简单粗暴地理解，就是一个子系统目录加上一组资源限制文件的组合。而对于 Docker 等 Linux 容器项目来说，它们只需要在每个子系统下面，为每个容器创建一个控制组（即创建一个新目录），然后在启动容器进程之后，把这个进程的 PID 填写到对应控制组的 tasks 文件中就可以了。

 

至于在这些控制组下面的资源文件里填上什么值，就靠用户执行 docker run 时的参数指定了，比如这样一条命令：

\# docker run -it --cpu-period=100000 --cpu-quota=20000 daocloud.io/centos /bin/bash

 

在启动这个容器后，通过查看 Cgroups 文件系统下，CPU 子系统中，"docker"这个控制组里的资源限制文件的内容来确认：

\# cat /sys/fs/cgroup/cpu/docker/5d5c9f67d/cpu.cfs_period_us 

100000

\# cat /sys/fs/cgroup/cpu/docker/5d5c9f67d/cpu.cfs_quota_us 

20000

 

在centos7里面是下面这个目录：不是上面的docker目录

\# cat /sys/fs/cgroup/cpu,cpuacct/system.slice/docker-92f76c52e9c0c34e0f8e5bac01f75919ce59838951a86501e7114d218f8aaf3e.scope/cpu.cfs_quota_us

20000

这就意味着这个 Docker 容器，只能使用到 20% 的 CPU 带宽。

 

由于一个容器的本质就是一个进程，用户的应用进程实际上就是容器里 PID=1 的进程，也是其他后续创建的所有进程的父进程。这就意味着，在一个容器中，你没办法同时运行两个不同的应用，除非你能事先找到一个公共的 PID=1 的程序来充当两个不同应用的父进程，这也是为什么很多人都会用 systemd 或者 supervisord 这样的软件来代替应用本身作为容器的启动进程。

 

这是因为容器本身的设计，就是希望容器和应用能够同生命周期，这个概念对后续的容器编排非常重要。否则，一旦出现类似于"容器是正常运行的，但是里面的应用早已经挂了"的情况，编排系统处理起来就非常麻烦了。

 

Cgroups的不足：

Cgroups 对资源的限制能力也有很多不完善的地方，被提及最多的自然是 /proc 文件系统的问题。

 

众所周知，Linux 下的 /proc 目录存储的是记录当前内核运行状态的一系列特殊文件，用户可以通过访问这些文件，查看系统以及当前正在运行的进程的信息，比如 CPU 使用情况、内存占用率等，这些文件也是 top 指令查看系统信息的主要数据来源。

 

但是，你如果在容器里执行 top 指令，就会发现，它显示的信息居然是宿主机的 CPU 和内存数据，而不是当前容器的数据。

 

造成这个问题的原因就是，/proc 文件系统并不知道用户通过 Cgroups 给这个容器做了什么样的资源限制，即：/proc 文件系统不了解 Cgroups 限制的存在。

 

在生产环境中，这个问题必须进行修正，否则应用程序在容器里读取到的 CPU 核数、可用内存等信息都是宿主机上的数据，这会给应用的运行带来非常大的困惑和风险。这也是在企业中，容器化应用碰到的一个常见问题，也是容器相较于虚拟机另一个不尽如人意的地方。

 

# 深入理解容器文件系统

## 理解Mount Namespace

问题：

  Namespace 的作用是"隔离"，它让应用进程只能看到该 Namespace 内的"世界"；而 Cgroups 的作用是"限制"，它给这个"世界"围上了一圈看不见的墙。这么一折腾，进程就真的被"装"在了一个与世隔绝的房间里，而这些房间就是 PaaS 项目赖以生存的应用"沙盒"。

 

可是，还有一个问题：这个房间四周虽然有了墙，但是如果容器进程低头一看地面，又是怎样一副景象呢？

 

换句话说，容器里的进程看到的文件系统又是什么样子的呢？

 

可能你立刻就能想到，这一定是一个关于 Mount Namespace 的问题：容器里的应用进程，理应看到一份完全独立的文件系统。这样，它就可以在自己的容器目录（比如 /tmp）下进行操作，而完全不会受宿主机以及其他容器的影响。

 

那么，真实情况是这样吗？

一段小程序：作用是，在创建子进程时开启指定的 Namespace。使用它来验证一下刚刚提到的问题。

\#define _GNU_SOURCE

\#include <sys/mount.h> 

\#include <sys/types.h>

\#include <sys/wait.h>

\#include <stdio.h>

\#include <sched.h>

\#include <signal.h>

\#include <unistd.h>

\#define STACK_SIZE (1024 * 1024)

static char container_stack[STACK_SIZE];

char* const container_args[] = {

 "/bin/bash",

 NULL

};

 

int container_main(void* arg)

{  

 printf("Container - inside the container!\n");

 execv(container_args[0], container_args);

 printf("Something's wrong!\n");

 return 1;

}

 

int main()

{

 printf("Parent - start a container!\n");

 int container_pid = clone(container_main, container_stack+STACK_SIZE, CLONE_NEWNS | SIGCHLD , NULL);

 waitpid(container_pid, NULL, 0);

 printf("Parent - container stopped!\n");

 return 0;

}

代码功能非常简单：在 main 函数里，通过 clone() 系统调用创建了一个新的子进程 container_main，并且声明要为它启用 Mount Namespace（即：CLONE_NEWNS 标志）。

 

而这个子进程执行的，是一个"/bin/bash"程序，也就是一个 shell。所以这个 shell 就运行在了 Mount Namespace 的隔离环境中。

 

编译一下这个程序：

\# gcc -o ns ns.c

\# ./ns

Parent - start a container!

Container - inside the container!

这样，就进入了这个"容器"当中（表面上看不大出来-wing注）。可是，如果在"容器"里执行一下 ls 指令的话，就会发现一个有趣的现象： /tmp 目录下的内容跟宿主机的内容是一样的。

 

\# ls /tmp

\# 你会看到好多宿主机的文件

也就是说：

即使开启了 Mount Namespace，容器进程看到的文件系统也跟宿主机完全一样。

 

wing注：

上面的问题是怎么回事呢？下回分解：）

## 容器进程对挂载点的认知

书接上回：

其实Mount Namespace 修改的，是容器进程对文件系统"挂载点"的认知。但是，这也就意味着，只有在"挂载"这个操作发生之后，进程的视图才会被改变。而在此之前，新创建的容器会直接继承宿主机的各个挂载点。

 

这时，你可能已经想到了一个解决办法：创建新进程时，除了声明要启用 Mount Namespace 之外，还可以告诉容器进程，有哪些目录需要重新挂载，就比如这个 /tmp 目录。于是，在容器进程执行前可以添加一步重新挂载 /tmp 目录的操作：

 

int container_main(void* arg)

{

 printf("Container - inside the container!\n");

 // 如果你的机器的根目录的挂载类型是 shared，那必须先重新挂载根目录

 // mount("", "/", NULL, MS_PRIVATE, "");

 mount("none", "/tmp", "tmpfs", 0, "");

 execv(container_args[0], container_args);

 printf("Something's wrong!\n");

 return 1;

}

在修改后的代码里，在容器进程启动之前，加上了一句 mount("none", "/tmp", "tmpfs", 0, "") 语句。就这样，告诉了容器以 tmpfs（内存盘）格式，重新挂载了 /tmp 目录。

 

编译执行修改后的代码结果又如何呢？试验一下：

\# gcc -o ns ns.c

\# ./ns

Parent - start a container!

Container - inside the container!

\# ls /tmp

 

这次 /tmp 变成了一个空目录，这意味着重新挂载生效了。

 

用 mount -l 检查：

\# mount -l | grep tmpfs

none on /tmp type tmpfs (rw,relatime)

容器里的 /tmp 目录是以 tmpfs 方式单独挂载的。可以卸载一下/tmp目录看看效果

 

更重要的是，因为创建的新进程启用了 Mount Namespace，所以这次重新挂载的操作，只在容器进程的 Mount Namespace 中有效。如果在宿主机上用 mount -l 来检查一下这个挂载，你会发现它是不存在的：

 

在宿主机上

  \# mount -l | grep tmpfs

  这就是 Mount Namespace 跟其他 Namespace 的使用略有不同的地方：它对容器进程视图的改变，一定是伴随着挂载操作（mount）才能生效。

 

我们希望的是：每当创建一个新容器时，我希望容器进程看到的文件系统就是一个独立的隔离环境，而不是继承自宿主机的文件系统。怎么才能做到这一点呢？

 

可以在容器进程启动之前重新挂载它的整个根目录"/"。而由于 Mount Namespace 的存在，这个挂载对宿主机不可见，所以容器进程就可以在里面随便折腾了。

 

## 理解chroot

在 Linux 操作系统里，有一个名为 chroot 的命令可以帮助你在 shell 中方便地完成这个工作。顾名思义，它的作用就是帮你"change root file system"，即改变进程的根目录到你指定的位置。

 

假设，现在有一个 /home/wing/test 目录，想要把它作为一个 /bin/bash 进程的根目录。

 

首先，创建一个 test 目录和几个 lib 文件夹：

\# mkdir -p /home/wing/test

\# mkdir -p /home/wing/test/{bin,lib64,lib}

 

然后，把 bash 命令拷贝到 test 目录对应的 bin 路径下：

\# cp -v /bin/{bash,ls}  /home/wing/test/bin

 

接下来，把 ls和bash命令需要的所有 so 文件，也拷贝到 test 目录对应的 lib 路径下。找到 so 文件可以用 ldd 命令：

 

\# list="$(ldd /bin/ls | egrep -o '/lib.*\.[0-9]')"

\# for i in $list; do cp -v "$i" "/home/wing/test/${i}"; done

 

\# list="$(ldd /bin/bash | egrep -o '/lib.*\.[0-9]')"

\# for i in $list; do cp -v "$i" "/home/wing/test/${i}"; done

 

最后，执行 chroot 命令，告诉操作系统，将使用 /home/wing/test 目录作为 /bin/bash 进程的根目录：

\# chroot /home/wing/test /bin/bash

 

这时，执行 "ls /"，就会看到，它返回的都是 /home/wing/test 目录下面的内容，而不是宿主机的内容。

 

更重要的是，对于被 chroot 的进程来说，它并不会感受到自己的根目录已经被"修改"成 /home/wing/test 了。

 

这种视图被修改的原理，是不是跟之前介绍的 Linux Namespace 很类似呢？

 

### 理解chroot

  即 change root directory (更改 root 目录)。在 linux 系统中，系统默认的目录结构都是以 /，即以根 (root) 开始的。而在使用 chroot 之后，系统的目录结构将以指定的位置作为 / 位置。

 

基本语法

  chroot NEWROOT [COMMAND [ARG]...]

 

为什么要使用 chroot 命令

1.增加了系统的安全性，限制了用户的权力：

  在经过 chroot 之后，在新根下将访问不到旧系统的根目录结构和文件，这样就增强了系统的安全性。一般会在用户登录前应用 chroot，把用户的访问能力控制在一定的范围之内。

 

2.建立一个与原系统隔离的系统目录结构，方便用户的开发：

  使用 chroot 后，系统读取的是新根下的目录和文件，这是一个与原系统根下文件不相关的目录结构。在这个新的环境中，可以用来测试软件的静态编译以及一些与系统不相关的独立开发。

 

3.切换系统的根目录位置，引导 Linux 系统启动以及急救系统等：

  chroot 的作用就是切换系统的根位置，而这个作用最为明显的是在系统初始引导磁盘的处理过程中使用，从初始 RAM 磁盘 (initrd) 切换系统的根位置并执行真正的 init，本文的最后一个 demo 会详细的介绍这种用法。

 

通过 chroot 运行 busybox 工具

busybox 包含了丰富的工具，可以把这些工具放置在一个目录下，然后通过 chroot 构造出一个 mini 系统。简单起见直接使用 docker 的 busybox 镜像打包的文件系统。先在当前目录下创建一个目录 rootfs：

$ mkdir rootfs然后把 busybox 镜像中的文件释放到这个目录中：

$ (docker export $(docker create busybox) | tar -C rootfs -xvf -)

 

通过 ls 命令查看 rootfs 文件夹下的内容：

$ ls rootfs

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpsKooBPL.jpg) 

 

执行 chroot 后的 ls 命令

$ sudo chroot rootfs /bin/ls

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpsrjX50z.jpg) 

虽然输出结果与刚才执行的 ls rootfs 命令形同，但是这次运行的命令却是 rootfs/bin/ls。

 

运行 chroot 后的 pwd 命令

$ sudo chroot rootfs /bin/pwd

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpswtiCco.jpg) 

 

不带命令执行 chroot

$ sudo chroot rootfs

![img](Docker%E5%85%A8%E8%A7%A3.assets/wps78haoc.jpg) 

这次出错了，因为找不到  /bin/bash。我们知道 busybox 中是不包含 bash 的，但是 chroot 命令为什么会找 bash 命令呢？ 原来，如果不给  chroot 指定执行的命令，默认它会执行 '${SHELL} -i'，而我的系统中 ${SHELL} 为 /bin/bash。

 

既然 busybox 中没有 bash，只好指定 /bin/sh 来执行 shell 了。

$ sudo chroot rootfs /bin/sh

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpsSp3Jz0.jpg) 

运行 sh 是没有问题的，并且我们打印出了当前进程的 PID。

 

## rootfs（根文件系统）

实际上，Mount Namespace 正是基于对 chroot 的不断改良才被发明出来的，它也是 Linux 操作系统里的第一个 Namespace。

 

为了能够让容器的这个根目录看起来更"真实"，一般会在这个容器的根目录下挂载一个完整操作系统的文件系统，比如 Ubuntu16.04 的 ISO。这样，在容器启动之后，在容器里通过执行 "ls /" 查看根目录下的内容，就是 Ubuntu 16.04 的所有目录和文件。

 

而这个挂载在容器根目录上、用来为容器进程提供隔离后执行环境的文件系统，就是所谓的"容器镜像"。它还有一个更为专业的名字，叫作：rootfs（根文件系统）。

 

所以，一个最常见的 rootfs，或者说容器镜像，会包括如下所示的一些目录和文件，比如 /bin，/etc，/proc 等等：

 

\# ls /

bin dev etc home lib lib64 mnt opt proc root run sbin sys tmp usr var

而进入容器之后执行的 /bin/bash，就是 /bin 目录下的可执行文件，与宿主机的 /bin/bash 完全不同。

 

所以，对 Docker 项目来说，它最核心的原理实际上就是为待创建的用户进程：

  1.启用 Linux Namespace 配置；

  2.设置指定的 Cgroups 参数；

  3.切换进程的根目录（Change Root）。

 

这样，一个完整的容器就诞生了。不过，Docker 项目在最后一步的切换上会优先使用 pivot_root 系统调用，如果系统不支持，才会使用 chroot。这两个系统调用功能类似

 

rootfs和kernel：

rootfs 只是一个操作系统所包含的文件、配置和目录，并不包括操作系统内核，同一台机器上的所有容器，都共享宿主机操作系统的内核。如果你的应用程序需要配置内核参数、加载额外的内核模块，以及跟内核进行直接的交互，你就需要注意了：这些操作和依赖的对象，都是宿主机操作系统的内核，它对于该机器上的所有容器来说是一个"全局变量"，牵一发而动全身。

 

在 Linux 操作系统中，这两部分是分开存放的，操作系统只有在开机启动时才会加载指定版本的内核镜像。

 

这是容器相比于虚拟机的缺陷之一：虚拟机不仅有模拟出来的硬件机器充当沙盒，而且每个沙盒里还运行着一个完整的 Guest OS 给应用随便用。

 

容器的一致性 ：

由于云端与本地服务器环境不同，应用的打包过程，一直是使用 PaaS 时最"痛苦"的一个步骤。

 

但有了容器镜像（即 rootfs）之后，这个问题被解决了。

 

由于 rootfs 里打包的不只是应用，而是整个操作系统的文件和目录，也就意味着，应用以及它运行所需要的所有依赖，都被封装在了一起。

 

对于大多数开发者而言，他们对应用依赖的理解，一直局限在编程语言层面。比如 Golang 的 Godeps.json。但实际上，一个一直以来很容易被忽视的事实是，对一个应用来说，操作系统本身才是它运行所需要的最完整的"依赖库"。

 

有了容器镜像"打包操作系统"的能力，这个最基础的依赖环境也终于变成了应用沙盒的一部分。这就赋予了容器所谓的一致性：无论在本地、云端，还是在一台任何地方的机器上，用户只需要解压打包好的容器镜像，那么这个应用运行所需要的完整的执行环境就被重现出来了。

 

这种深入到操作系统级别的运行环境一致性，打通了应用在本地开发和远端执行环境之间难以逾越的鸿沟。

## UnionFS详解

每开发一个应用，或者升级一下现有的应用，都要重复制作一次 rootfs 吗？

比如，现在用 Ubuntu 操作系统的 ISO 做了一个 rootfs，然后又在里面安装了 Java 环境，用来部署我的 Java 应用。那么，另一个同事在发布他的 Java 应用时，显然希望能够直接使用我安装过 Java 环境的 rootfs，而不是重复这个流程。

 

解决办法：方法2为正解

  方法1.在制作 rootfs 的时候，每做一步"有意义"的操作，就保存一个 rootfs 出来，这样其他同事就可以按需求去用他需要的 rootfs 了。但是，这个解决办法并不具备推广性。原因在于，一旦你的同事们修改了这个 rootfs，新旧两个 rootfs 之间就没有任何关系了。这样做的结果就是极度的碎片化。

 

 

  方法2.因为这些修改都基于一个旧的 rootfs，以增量的方式去做这些修改，所有人都只需要维护相对于 base rootfs 修改的增量内容，而不是每次修改都制造一个"fork"。

 

联合文件系统：Union File System 也叫 UnionFS

  Docker 公司在实现 Docker 镜像时并没有沿用以前制作 rootfs 的标准流程，做了一个创新：

  Docker 在镜像的设计中，引入了层（layer）的概念。也就是说，用户制作镜像的每一步操作，都会生成一个层，也就是一个增量 rootfs。用到了一种叫作联合文件系统（Union File System）的能力。

 

 

  主要的功能是将多个不同位置的目录联合挂载（union mount）到同一个目录下。

  

  比如，现在有两个目录 A 和 B，它们分别有两个文件：

​    \# tree

​    .

​    ├── A

​    │  ├── a

​    │  └── x

​    └── B

​       ├── b

​       └── x

 

  然后，使用联合挂载的方式，将这两个目录挂载到一个公共的目录 C 上：

​    \# mkdir C

​    \# yum install funionfs -y  //我这里用的是centos7自带的联合文件系统，效果一样

​    \# funionfs  -o dirs=./A:./B none ./C

 

  再查看目录 C 的内容，就能看到目录 A 和 B 下的文件被合并到了一起：

​    \# tree ./C

​    ./C

​    ├── a

​    ├── b

​    └── x

  

  可以看到，在这个合并后的目录 C 里，有 a、b、x 三个文件，并且 x 文件只有一份。这，就是"合并"的含义。

  此外，如果在目录 C 里对 a、b、x 文件做修改，这些修改也会在对应的目录 A、B 中生效。

​    \# echo hello >> C/a

​    \# cat C/a

​    hello

​    \# cat A/a

​    hello

​    \# echo hello1 >> A/a

​    \# cat A/a

​    hello

​    hello1

​    \# cat C/a

​    hello

​    hello1

 

 

## OverlayFS

### Overlayfs的基本特性

  Overlayfs是一种类似aufs的一种堆叠文件系统，于2014年正式合入Linux-3.18主线内核，目前其功能已经基本稳定（虽然还存在一些特性尚未实现）且被逐渐推广，特别在容器技术中更是势头难挡。

 

  它依赖并建立在其它的文件系统之上（例如ext4fs和xfs等等），并不直接参与磁盘空间结构的划分，仅仅将原来底层文件系统中不同的目录进行"合并"，然后向用户呈现。因此对于用户来说，它所见到的overlay文件系统根目录下的内容就来自挂载时所指定的不同目录的"合集"。

 

![img](Docker%E5%85%A8%E8%A7%A3.assets/wps7CtrLO.jpg) 

Overlayfs基本结构

 

overlayfs最基本的特性，简单的总结为以下3点：

（1）上下层同名目录合并；

（2）上下层同名文件覆盖；

（3）lower dir文件写时拷贝。

 这三点对用户都是不感知的。

 

lower dirA / lower dirB目录和upper dir目录

\1. 他们都是来自底层文件系统的不同目录，用户可以自行指定，内部包含了用户想要合并的文件和目录，merge dir目录为挂载点。

 

\2. 当文件系统挂载后，在merge目录下将会同时看到来自各lower和upper目录下的内容，并且用户也无法（无需）感知这些文件分别哪些来自lower dir，哪些来自upper dir，用户看见的只是一个普通的文件系统根目录而已（lower dir可以有多个也可以只有一个）。

 

upper dir和各lower dir这几个不同的目录并不完全等价，存在层次关系。

\1. 当upper dir和lower dir两个目录存在同名文件时，lower dir的文件将会被隐藏，用户只能看见来自upper dir的文件

 

\2. lower dir也存在相同的层次关系，较上层屏蔽较下层的同名文件。

 

\3. 如果存在同名的目录，那就继续合并（lower dir和upper dir合并到挂载点目录其实就是合并一个典型的例子）。

 

读写数据：

\1. 各层目录中的upper dir是可读写的目录，当用户通过merge dir向其中一个来自upper dir的文件写入数据时，那数据将直接写入upper dir下原来的文件中，删除文件也是同理；

 

\2. 而各lower dir则是只读的，在overlayfs挂载后无论如何操作merge目录中对应来自lower dir的文件或目录，lower dir中的内容均不会发生任何的改变。

 

\3. 当用户想要往来自lower层的文件添加或修改内容时，overlayfs首先会的拷贝一份lower dir中的文件副本到upper dir中，后续的写入和修改操作将会在upper dir下的copy-up的副本文件中进行，lower dir原文件被隐藏。

 

### overlayfs的应用场景

overlayfs特性带来的好处和应用场景

实际的使用中，会存在以下的多用户复用共享文件和目录的场景。

 

见图

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpsXEVcXC.jpg) 

 

复用共享目录文件

 

在同一个设备上，用户A和用户B有一些共同使用的共享文件（例如运行程序所依赖的动态链接库等），一般是只读的；同时也有自己的私有文件（例如系统配置文件等），往往是需要能够写入修改的；最后即使用户A修改了被共享的文件也不会影响到用户B。

 

对于以上的需求场景，我们并不希望每个用户都有一份完全一样的文件副本，因为这样不仅带来空间的浪费也会影响性能，因此overlayfs是一个较为完美的解决方案。我们将这些共享的文件和目录所在的目录设定为lower dir (1~n)，将用户私有的文件和目录所在的目录设定为upper dir，然后挂载到用户指定的挂载点，这样即能够保证前面列出的3点需求，同时也能够保证用户A和B独有的目录树结构。最后最为关键的是用户A和用户B在各自挂载目录下看见的共享文件其实是同一个文件，这样磁盘空间的节省自是不必说了，还有就是共享同一份cache而减少内存的使用和提高访问性能，因为只要cache不被回收，只需某个用户首次访问时创建cache，后续其他所有用户都可以通过访问cache来提高IO性能。

 

上面说的这种使用场景在容器技术中应用最为广泛

 

### Overlay和Overlay2

以docker容器为例来介绍overlay的两种应用方式：Overlay和Overlay2.

1. Docker容器将镜像层（image layer）作为lower dir

2. 将容器层（container layer）作为upper dir

3. 最后挂载到容器merge挂载点，即容器的根目录下。

 

遗憾的是，早期内核中的overlayfs并不支持多lower layer，在Linux-4.0以后的内核版本中才陆续支持完善。而容器中可能存在多层镜像，所以出现了两种overlayfs的挂载方式，早期的overlay不使用多lower layer的方式挂载而overlay2则使用该方式挂载。

 

1. Overlay Driver

 

Overlay挂载方式如下

--该图引用自Miklos Szeredi的《overlayfs and containers》2017 linux内核大会演讲材料

![img](Docker%E5%85%A8%E8%A7%A3.assets/wpspMx18q.jpg) 

Overlay Driver

 

镜像层和容器层的组织方式

黄色框中的部分是镜像层和容器层的组织方式

1. 各个镜像层中，每下一层中的文件以硬链接的方式出现在它的上一层中，以此类推，最终挂载overlayfs的lower dir为最上层镜像层目录imager layer N。

2. 与此同时，容器的writable dir作为upper dir，挂载成为容器的rootfs。

 

本图中虽然只描述了一个容器的挂载方式，但是其他容器也类似，镜像层lower dir N共享，只是各个容器的upper dir不同而已。

 

2. Overlay2 Driver

Overlay2挂载方式如下。

--该图引用自Miklos Szeredi的《overlayfs and containers》2017 linux内核大会演讲材料

![img](Docker%E5%85%A8%E8%A7%A3.assets/wps97tSkf.jpg) 

Overlay2 Driver

 

Overlay2的挂载方式比Overlay的要简单许多，它基于内核overlayfs的Multiple lower layers特性实现，不再需要硬链接，直接将镜像层的各个目录设置为overlayfs的各个lower layer即可（Overlayfs最多支持500层lower dir），对比Overlay Driver将减少inode的使用。

### overlay2的缺陷

注：

尽管Overlayfs看起来是这么的优秀，但是当前它还并不是那么的完美，依然存在一些缺点和使用限制（还没有完全支持POSIX标准），这里简单列出一些，先认识一下，以后遇到也能心中有数：

 

0. Mount Overlayfs之后就不允许在对原lower dir和upper dir进行操作

 

当我们挂载完成overlayfs以后，对文件系统的任何操作都只能在merge dir中进行，用户不允许再直接或间接的到底层文件系统的原始lower dir或upper dir目录下修改文件或目录，否则可能会出现一些无法预料的后果（kernel crash除外）。

 

1. Copy-up

 

Overlayfs的lower layer文件写时复制机制让某一个用户在修改来自lower层的文件不会影响到其他用户（容器），但是这个文件的复制动作会显得比较慢，后面我们会看到为了保证文件系统的一致性，这个copy-up实现包含了很多步骤，其中最为耗时的就是文件数据块的复制和fsync同步。用户在修改文件时，如果文件较小那可能不一定能够感受出来，但是当文件比较大或一次对大量的小文件进行修改，那耗时将非常可观。虽然自Linux-4.11起内核引入了“concurrent copy up”特性来提高copy-up的并行性，但是对于大文件也还是没有明显的效果。不过幸运的是，如果底层的文件系统支持reflink这样的延时拷贝技术（例如xfs）那就不存在这个问题了。

 

2. Rename directory（POSIX标准支持问题）

 

如果Overlayfs的某一个目录是单纯来自lower layer或是lower layer和upper layer合并的，那默认情况下，用户无法对该目录执行rename系统调用，否则会返回-EXDEV错误。不过你会发现通过mv命令重命名该目录依然可以成功，那是因为mv命令的实现对rename系统调用的-EXDEV错误进行规避（这当然是有缺点的，先暂不展开）。在Linux-4.10起内核引入了“redirect dir”特性来修复这个问题，为此引入了一个内核选项：CONFIG_OVERLAY_FS_REDIRECT_DIR，用户想要支持该特性可以在内核中开启这个选项，否则就应避免对这两类目录使用rename系统调用。

 

3. Hard link break（POSIX标准支持问题）

 

该问题源自copy-up机制，当lower dir目录中某个文件拥有多个硬链接时，若用户在merge layer对其中一个写入了一些数据，那将触发copy-up，由此该文件将拷贝到upper dir，那么和原始文件的hard link也就断开了，变成了一个单独的文件，用户在merge layer通过stat和ls命令能够直接看到这个变化。在Linux-4.13起内核引入了“index feature”来修复这个问题，同样引入了一个内核选项：CONFIG_OVERLAY_FS_INDEX，用户想要修复该问题可以打开这个选项，不过该选项不具有向前兼容性，请谨慎使用。

 

4. Unconstant st_dev&st_ino（POSIX标准支持问题）

 

该问题同样源自copy-up机制，当原来在lower dir中的文件触发了copy-up以后，那用户在merge layer见到了将是来自upper dir的新文件，那也就意味着它俩的inode是不同的，虽然inode中很多的attr和xattr是可以copy的，但是st_dev和st_ino这两个字段却具有唯一性，是不可以复制的，所以用户可以通过ls和stat命令看到的该字段将发生变化。在Linux-4.12和Linux-4.13分别进行了部分的修复，目前在lower dir和upper dir都在同一个文件系统挂载点的场景下，问题已经修复，但lower dir和upper dir若来自不同的文件系统，问题依然存在。

 

5. File descriptor change（POSIX标准支持问题）

 

该问题也同样源自copy-up机制，用户在文件发生copy-up之前以只读方式open文件（这操作不会触发copy-up）得到的文件描述符fd1和copy-up之后open文件得到的文件描述符fd2指向不同的文件，用户通过fd2写入的新数据，将无法从fd1中获取到，只能重新open一个新的fd。该问题目前社区主线内核依然存在，暂未修复。

 

以上这6点列出了目前Overlayfs的主要问题和限制，社区为了让Overlayfs能够更加向支持Posix标准的文件系统靠拢，做出了很多的努力，后续将进一步修复上面提到且未修复的问题，还会增加对NFS Export、freeze snapshots、overlayfs snapshots等的支持，进一步完善overlayfs。

 

### 观察容器启动前后存储目录变化情况

分别查看镜像的详细信息和运行成容器之后的容器详细信息

 

lower1:lower2:lower3 :

  表示不同的lower层目录，不同的目录使用":"分隔，层次关系依次为lower1 > lower2 > lower3 

  注：多lower层功能支持在Linux-4.0合入，Linux-3.18版本只能指定一个lower dir

 

upper和目录:

  表示upper层目录

  

work目录：   

  和文件系统挂载后用于存放临时和间接文件的工作基目录（work base dir）

 

merged目录:

  就是最终的挂载点目录

 

 

### AuFS详解

Docker 项目如何使用 Union File System ？

环境：Ubuntu 16.04 和 Docker CE 18.05，这对组合默认使用的是 AuFS 这个联合文件系统的实现。你可以通过 docker info 命令，查看到这个信息。

 

AuFS 的全称是 Another UnionFS，后改名为 Alternative UnionFS，再后来干脆改名叫作 Advance UnionFS，从这些名字中你应该能看出这样两个事实：

 

它是对 Linux 原生 UnionFS 的重写和改进；

 

它的作者怨气很大。猜是 Linus Torvalds（Linux 之父）一直不让 AuFS 进入 Linux 内核主干的缘故，所以我们只能在 Ubuntu 和 Debian 这些发行版上使用它。

 

对于 AuFS 来说，它最关键的目录结构在 /var/lib/docker 路径下的 diff 目录：

/var/lib/docker/aufs/diff/<layer_id>

 

这个目录的作用，通过一个例子看一下。

启动一个容器，比如：

\# docker run -d ubuntu:latest sleep 3600

这时候，Docker 就会从 Docker Hub 上拉取一个 Ubuntu 镜像到本地。

 

这个所谓的"镜像"，实际上就是一个 Ubuntu 操作系统的 rootfs，它的内容是 Ubuntu 操作系统的所有文件和目录。不过，与之前的 rootfs 稍微不同的是，Docker 镜像使用的 rootfs，往往由多个"层"组成：

 

\# docker image inspect ubuntu:latest

...

   "RootFS": {

   "Type": "layers",

   "Layers": [

​    "sha256:f49017d4d5ce9c0f544c...",

​    "sha256:8f2b771487e9d6354080...",

​    "sha256:ccd4d61916aaa2159429...",

​    "sha256:c01d74f99de40e097c73...",

​    "sha256:268a067217b5fe78e000..."

   ]

  }

可以看到，这个 Ubuntu 镜像，实际上由五个层组成。这五个层就是五个增量 rootfs，每一层都是 Ubuntu 操作系统文件与目录的一部分；而在使用镜像时，Docker 会把这些增量联合挂载在一个统一的挂载点上（等价于前面例子里的"/C"目录）。

 

这个挂载点就是 /var/lib/docker/aufs/mnt/，比如：

 

/var/lib/docker/aufs/mnt/6e3be5d2ecccae7cc0fcfa2a2f5c89dc21ee30e166be823ceaeba15dce645b3e

不出意外的，这个目录里面正是一个完整的 Ubuntu 操作系统：

 

$ ls /var/lib/docker/aufs/mnt/6e3be5d2ecccae7cc0fcfa2a2f5c89dc21ee30e166be823ceaeba15dce645b3e

bin boot dev etc home lib lib64 media mnt opt proc root run sbin srv sys tmp usr var

那么，前面提到的五个镜像层，又是如何被联合挂载成这样一个完整的 Ubuntu 文件系统的呢？

 

这个信息记录在 AuFS 的系统目录 /sys/fs/aufs 下面。

 

首先，通过查看 AuFS 的挂载信息，我们可以找到这个目录对应的 AuFS 的内部 ID（也叫：si）：

 

$ cat /proc/mounts| grep aufs

none /var/lib/docker/aufs/mnt/6e3be5d2ecccae7cc0fc... aufs rw,relatime,si=972c6d361e6b32ba,dio,dirperm1 0 0

即，si=972c6d361e6b32ba。

 

然后使用这个 ID，就可以在 /sys/fs/aufs 下查看被联合挂载在一起的各个层的信息：

 

$ cat /sys/fs/aufs/si_972c6d361e6b32ba/br[0-9]*

/var/lib/docker/aufs/diff/6e3be5d2ecccae7cc...=rw

/var/lib/docker/aufs/diff/6e3be5d2ecccae7cc...-init=ro+wh

/var/lib/docker/aufs/diff/32e8e20064858c0f2...=ro+wh

/var/lib/docker/aufs/diff/2b8858809bce62e62...=ro+wh

/var/lib/docker/aufs/diff/20707dce8efc0d267...=ro+wh

/var/lib/docker/aufs/diff/72b0744e06247c7d0...=ro+wh

/var/lib/docker/aufs/diff/a524a729adadedb90...=ro+wh

从这些信息里，我们可以看到，镜像的层都放置在 /var/lib/docker/aufs/diff 目录下，然后被联合挂载在 /var/lib/docker/aufs/mnt 里面。

 

而且，从这个结构可以看出来，这个容器的 rootfs 由如下图所示的三部分组成：

 

第一部分，只读层。

它是这个容器的 rootfs 最下面的五层，对应的正是 ubuntu:latest 镜像的五层。可以看到，它们的挂载方式都是只读的（ro+wh，即 readonly+whiteout，至于什么是 whiteout，我下面马上会讲到）。

 

这时，可以分别查看一下这些层的内容：

\# ls /var/lib/docker/aufs/diff/72b0744e06247c7d0...

etc sbin usr var

\# ls /var/lib/docker/aufs/diff/32e8e20064858c0f2...

run

\# ls /var/lib/docker/aufs/diff/a524a729adadedb900...

bin boot dev etc home lib lib64 media mnt opt proc root run sbin srv sys tmp usr var

可以看到，这些层，都以增量的方式分别包含了 Ubuntu 操作系统的一部分。

 

第二部分，可读写层。

它是这个容器的 rootfs 最上面的一层（6e3be5d2ecccae7cc），它的挂载方式为：rw，即 read write。在没有写入文件之前，这个目录是空的。而一旦在容器里做了写操作，你修改产生的内容就会以增量的方式出现在这个层中。

 

可是，你有没有想到这样一个问题：如果我现在要做的，是删除只读层里的一个文件呢？

 

为了实现这样的删除操作，AuFS 会在可读写层创建一个 whiteout 文件，把只读层里的文件"遮挡"起来。

 

比如，你要删除只读层里一个名叫 foo 的文件，那么这个删除操作实际上是在可读写层创建了一个名叫.wh.foo 的文件。这样，当这两个层被联合挂载之后，foo 文件就会被.wh.foo 文件"遮挡"起来，"消失"了。这个功能，就是"ro+wh"的挂载方式，即只读 +whiteout 的含义。我喜欢把 whiteout 形象地翻译为："白障"。

 

所以，最上面这个可读写层的作用，就是专门用来存放你修改 rootfs 后产生的增量，无论是增、删、改，都发生在这里。而当我们使用完了这个被修改过的容器之后，还可以使用 docker commit 和 push 指令，保存这个被修改过的可读写层，并上传到 Docker Hub 上，供其他人使用；而与此同时，原先的只读层里的内容则不会有任何变化。这，就是增量 rootfs 的好处。

 

第三部分，Init 层。

它是一个以"-init"结尾的层，夹在只读层和读写层之间。Init 层是 Docker 项目单独生成的一个内部层，专门用来存放 /etc/hosts、/etc/resolv.conf 等信息。

 

需要这样一层的原因是，这些文件本来属于只读的 Ubuntu 镜像的一部分，但是用户往往需要在启动容器时写入一些指定的值比如 hostname，所以就需要在可读写层对它们进行修改。

 

可是，这些修改往往只对当前的容器有效，我们并不希望执行 docker commit 时，把这些信息连同可读写层一起提交掉。

 

所以，Docker 做法是，在修改了这些文件之后，以一个单独的层挂载了出来。而用户执行 docker commit 只会提交可读写层，所以是不包含这些内容的。

 

最终，这 7 个层都被联合挂载到 /var/lib/docker/aufs/mnt 目录下，表现为一个完整的 Ubuntu 操作系统供容器使用。

 

总结

介绍了 Linux 容器文件系统的实现方式。而这种机制，正是经常提到的容器镜像，也叫作：rootfs。它只是一个操作系统的所有文件和目录，并不包含内核，最多也就几百兆。相比之下，传统虚拟机的镜像大多是一个磁盘的"快照"，磁盘有多大，镜像就至少有多大。

 

通过结合使用 Mount Namespace 和 rootfs，容器就能够为进程构建出一个完善的文件系统隔离环境。当然，这个功能的实现还必须感谢 chroot 和 pivot_root 这两个系统调用切换进程根目录的能力。

 

而在 rootfs 的基础上，Docker 公司创新性地提出了使用多个增量 rootfs 联合挂载一个完整 rootfs 的方案，这就是容器镜像中"层"的概念。

 

通过"分层镜像"的设计，以 Docker 镜像为核心，来自不同公司、不同团队的技术人员被紧密地联系在了一起。而且，由于容器镜像的操作是增量式的，这样每次镜像拉取、推送的内容，比原本多个完整的操作系统的大小要小得多；而共享层的存在，可以使得所有这些容器镜像需要的总空间，也比每个镜像的总和要小。这样就使得基于容器镜像的团队协作，要比基于动则几个 GB 的虚拟机磁盘镜像的协作要敏捷得多。

 

更重要的是，一旦这个镜像被发布，那么你在全世界的任何一个地方下载这个镜像，得到的内容都完全一致，可以完全复现这个镜像制作者当初的完整环境。这，就是容器技术"强一致性"的重要体现。

 

而这种价值正是支撑 Docker 公司在 2014~2016 年间迅猛发展的核心动力。容器镜像的发明，不仅打通了"开发 - 测试 - 部署"流程的每一个环节，更重要的是：容器镜像将会成为未来软件的主流发布方式。

 

## docker数据存储位置

\# docker info | grep Root

Docker Root Dir:  /var/lib/docker

 

修改默认存储位置：

在dockerd的启动命令后面追加--data-root参数指定新的位置

\# vim /usr/lib/systemd/system/docker.service

ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --data-root=/data

 

\# systemctl daemon-reload

\# systemctl restart docker

 

查看是否生效：

\# docker info | grep Root

Docker Root Dir: /data





这篇文章希望能够帮助读者深入理解Docker的命令，还有容器（container）和镜像（image）之间的区别，并深入探讨容器和运行中的容器之间的区别。

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-9928dd12dbe39852.webp)

当我对Docker技术还是一知半解的时候，我发现理解Docker的命令非常困难。于是，我花了几周的时间来学习Docker的工作原理，更确切地说，是关于Docker`统一文件系统（the union file system）`的知识，然后回过头来再看Docker的命令，一切变得顺理成章，简单极了。

**题外话**：就我个人而言，掌握一门技术并合理使用它的最好办法就是深入理解这项技术背后的工作原理。通常情况下，一项新技术的诞生常常会伴随着媒体的大肆宣传和炒作，这使得用户很难看清技术的本质。更确切地说，新技术总是会发明一些新的术语或者隐喻词来帮助宣传，这在初期是非常有帮助的，但是这给技术的原理蒙上了一层砂纸，不利于用户在后期掌握技术的真谛。

Git就是一个很好的例子。我之前不能够很好的使用Git，于是我花了一段时间去学习Git的原理，直到这时，我才真正明白了Git的用法。我坚信只有真正理解Git内部原理的人才能够掌握这个工具。

### Image Definition

`镜像（Image）`就是一堆`只读层（read-only layer）`的统一视角，也许这个定义有些难以理解，下面的这张图能够帮助读者理解镜像的定义。  

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-93b4b1297690120d.webp)

从左边我们看到了多个只读层，它们重叠在一起。除了最下面一层，其它层都会有一个指针指向下一层。这些层是Docker内部的实现细节，并且能够在主机（译者注：运行Docker的机器）的文件系统上访问到。统一文件系统（union file system）技术能够将不同的层整合成一个文件系统，为这些层提供了一个统一的视角，这样就隐藏了多层的存在，在用户的角度看来，只存在一个文件系统。我们可以在图片的右边看到这个视角的形式。

你可以在你的主机文件系统上找到有关这些层的文件。需要注意的是，在一个运行中的容器内部，这些层是不可见的。在我的主机上，我发现它们存在于`/var/lib/docker/aufs`目录下。

```text
sudo tree -L 1 /var/lib/docker/
/var/lib/docker/

├─aufs
├─containers
├─graph
├─init
├─linkgraph.db
├─repositories-aufs
├─tmp
├─trust
└─volumes

```

### Container Definition

容器（container）的定义和镜像（image）几乎一模一样，也是一堆层的统一视角，唯一区别在于容器的最上面那一层是可读可写的。

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-01ffe82748c5e719.webp)

细心的读者可能会发现，容器的定义并没有提及容器是否在运行，没错，这是故意的。正是这个发现帮助我理解了很多困惑。

**`要点`**：容器 = 镜像 + 读写层。并且容器的定义并没有提及是否要运行容器。

接下来，我们将会讨论运行态容器。

### Running Container Definition

一个运行态容器（running container）被定义为一个可读写的统一文件系统加上隔离的进程空间和包含其中的进程。下面这张图片展示了一个运行中的容器。

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-d6e418005e731d78.webp)

正是文件系统隔离技术使得Docker成为了一个前途无量的技术。一个容器中的进程可能会对文件进行修改、删除、创建，这些改变都将作用于可读写层（read-write layer）。下面这张图展示了这个行为。

![4.png]

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-ff6237a5abb563fd.webp)

我们可以通过运行以下命令来验证我们上面所说的：

```
docker run ubuntu touch happiness.txt

```

即便是这个ubuntu容器不再运行，我们依旧能够在主机的文件系统上找到这个新文件。

```
find / -name happiness.txt
/var/lib/docker/aufs/diff/860a7b...889/happiness.txt

```

### Image Layer Definition

为了将零星的数据整合起来，我们提出了镜像层（image layer）这个概念。下面的这张图描述了一个镜像层，通过图片我们能够发现一个层并不仅仅包含文件系统的改变，它还能包含了其他重要信息。

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-a3b8b5f195fb2419.webp)

**元数据（metadata）**就是关于这个层的额外信息，它不仅能够让Docker获取运行和构建时的信息，还包括父层的层次信息。需要注意，只读层和读写层都包含元数据。

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-4d6f084b95273b3e.webp)

除此之外，每一层都包括了一个指向父层的指针。如果一个层没有这个指针，说明它处于最底层。

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-79fca03500c9108b.webp)

**Metadata Location:**
我发现在我自己的主机上，镜像层（image layer）的元数据被保存在名为”json”的文件中，比如说：

```
/var/lib/docker/graph/e809f156dc985.../json

```

e809f156dc985...就是这层的id

一个容器的元数据好像是被分成了很多文件，但或多或少能够在/var/lib/docker/containers/<id>目录下找到<id>就是一个可读层的id。这个目录下的文件大多是运行时的数据，比如说网络，日志等等。

### 全局理解（Tying It All Together）

现在，让我们结合上面提到的实现细节来理解Docker的命令。

#### docker create <image-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-057b3f5f162a914f.webp)

docker create 命令为指定的镜像（image）添加了一个`可读写层`，构成了一个新的容器。注意，这个容器并没有运行。

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-ccf67c88b55f5e5a.webp)

#### docker start <container-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-9ae9a1699070a761.webp)

Docker start命令为容器文件系统创建了一个`进程隔离空间`。注意，每一个容器只能够有一个进程隔离空间。

#### docker run <image-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-81586f268f952794.webp)

看到这个命令，读者通常会有一个疑问：docker start 和 docker run命令有什么区别。

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-fa0a855330fa4242.webp)

从图片可以看出，docker run 命令先是利用镜像创建了一个容器，然后运行这个容器。这个命令非常的方便，并且隐藏了两个命令的细节，但从另一方面来看，这容易让用户产生误解。

题外话：继续我们之前有关于Git的话题，我认为docker run命令类似于git pull命令。git pull命令就是git fetch 和 git merge两个命令的组合，同样的，docker run就是docker create和docker start两个命令的组合。

#### docker ps

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-92cc5ec42996b13e.webp)

docker ps 命令会列出所有运行中的容器。这隐藏了非运行态容器的存在，如果想要找出这些容器，我们需要使用下面这个命令。

#### docker ps –a

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-18381e6c686f5080.webp)

docker ps –a命令会列出所有的容器，不管是运行的，还是停止的。

#### docker images

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-209a8b09260bf41e.webp)

docker images命令会列出了所有顶层（top-level）镜像。实际上，在这里我们没有办法区分一个镜像和一个只读层，所以我们提出了top-level镜像。只有创建容器时使用的镜像或者是直接pull下来的镜像能被称为顶层（top-level）镜像，并且每一个顶层镜像下面都隐藏了多个镜像层。

#### docker images –a

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-8a0ae1fe6d475c6e.webp)

docker images –a命令列出了所有的镜像，也可以说是列出了所有的可读层。如果你想要查看某一个image-id下的所有层，可以使用docker history来查看。

#### docker stop <container-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-c05f9c64d3389946.webp)

docker stop命令会向运行中的容器发送一个SIGTERM的信号，然后停止所有的进程。

#### docker kill <container-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-46fa7f006eec99e7.webp)

docker kill 命令向所有运行在容器中的进程发送了一个不友好的SIGKILL信号。

#### docker pause <container-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-13639a052eeccedc.webp)

docker stop和docker kill命令会发送UNIX的信号给运行中的进程，docker pause命令则不一样，它利用了`cgroups`的特性将运行中的进程空间暂停。具体的内部原理你可以在这里找到：[](https://link.jianshu.com/?t=https%3A%2F%2Fwww.kernel.org%2Fdoc%2FDocumentation%2Fcgroups%2Ffreezer-subsystem.txt)[https://www.kernel.org/doc/Doc ... m.txt](https://link.jianshu.com/?t=https%3A%2F%2Fwww.kernel.org%2Fdoc%2FDocumentation%2Fcgroups%2Ffreezer-subsystem.txt)，但是这种方式的不足之处在于发送一个SIGTSTP信号对于进程来说不够简单易懂，以至于不能够让所有进程暂停。

#### docker rm <container-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-5b7cd5a71501c69c.webp)

docker rm命令会移除构成容器的可读写层。注意，这个命令只能对非运行态容器执行。

#### docker rmi <image-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-9af724f8652b3cf7.webp)

docker rmi 命令会移除构成镜像的一个只读层。你只能够使用docker rmi来移除最顶层（top level layer）（也可以说是镜像），你也可以使用-f参数来强制删除中间的只读层。

#### docker commit <container-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-2ba257c35f7f5ac3.webp)

docker commit命令将容器的可读写层转换为一个只读层，这样就把一个容器转换成了不可变的镜像。

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-b8c790c420191d03.webp)

#### docker build

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-136504ab2e90ebd8.webp)

docker build命令非常有趣，它会反复的执行多个命令。

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-23639d034088ac25.webp)

我们从上图可以看到，build命令根据Dockerfile文件中的FROM指令获取到镜像，然后重复地1）run（create和start）、2）修改、3）commit。在循环中的每一步都会生成一个新的层，因此许多新的层会被创建。

#### docker exec <running-container-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-0bc5fb808f00b6d5.webp)

`docker exec 命令会在运行中的容器执行一个新进程`。

#### docker inspect <container-id> or <image-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-7fb2d9fa5844c4af.webp)

docker inspect命令会提取出容器或者镜像最顶层的元数据。

#### docker save <image-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-c8ccfcc21d76f582.webp)

docker save命令会创建一个镜像的压缩文件，这个文件能够在另外一个主机的Docker上使用。和export命令不同，这个命令为每一个层都保存了它们的元数据。这个命令只能对镜像生效。

#### docker export <container-id>

[![export.jpg]

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-22371dea380abc40.webp)

docker export命令创建一个tar文件，并且移除了元数据和不必要的层，将多个层整合成了一个层，只保存了当前统一视角看到的内容（译者注：expoxt后的容器再import到Docker中，通过docker images –tree命令只能看到一个镜像；而save后的镜像则不同，它能够看到这个镜像的历史镜像）。

#### docker history <image-id>

![image](Docker%E5%85%A8%E8%A7%A3.assets/3167229-a9b56118f21e733f.webp)

docker history命令递归地输出指定镜像的历史镜像。



# Copy On Write机制



在读《Redis设计与实现》关于哈希表扩容的时候，发现这么一段话：

> 执行BGSAVE命令或者BGREWRITEAOF命令的过程中，Redis需要创建当前服务器进程的子进程，而大多数操作系统都采用**写时复制（copy-on-write）来优化子进程的使用效率**，所以在子进程存在期间，服务器会提高负载因子的阈值，从而避免在子进程存在期间进行哈希表扩展操作，避免不必要的内存写入操作，最大限度地节约内存。

触及到知识的盲区了，于是就去搜了一下copy-on-write写时复制这个技术究竟是怎么样的。发现涉及的东西蛮多的，也挺难读懂的。于是就写下这篇笔记来记录一下我学习copy-on-write的过程。

# 一、Linux下的copy-on-write

在说明Linux下的copy-on-write机制前，我们首先要知道两个函数：`fork()`和`exec()`。需要注意的是`exec()`并不是一个特定的函数, 它是**一组函数的统称**, 它包括了`execl()`、`execlp()`、`execv()`、`execle()`、`execve()`、`execvp()`。

## 1.1简单来用用fork

首先我们来看一下`fork()`函数是什么鬼：

> fork is an operation whereby a process creates a copy of itself.

fork是类Unix操作系统上**创建进程**的主要方法。fork用于**创建子进程**(等同于当前进程的副本)。

- 新的进程要通过老的进程复制自身得到，这就是fork！

如果接触过Linux，我们会知道Linux下**init进程是所有进程的爹**(相当于Java中的Object对象)

- Linux的进程都通过init进程或init的子进程fork(vfork)出来的。

下面以例子说明一下fork吧：

```c
#include <unistd.h>  
#include <stdio.h>  
 
int main ()   
{   
    pid_t fpid; //fpid表示fork函数返回的值  
    int count=0;
	
	// 调用fork，创建出子进程  
    fpid=fork();

	// 所以下面的代码有两个进程执行！
    if (fpid < 0)   
        printf("创建进程失败!/n");   
    else if (fpid == 0) {  
        printf("我是子进程，由父进程fork出来/n");   
        count++;  
    }  
    else {  
        printf("我是父进程/n");   
        count++;  
    }  
    printf("统计结果是: %d/n",count);  
    return 0;  
}  
```

得到的结果输出为：

```c
我是子进程，由父进程fork出来

统计结果是: 1

我是父进程

统计结果是: 1
```

解释一下：

- fork作为一个函数被调用。这个函数会有**两次返回**，将**子进程的PID返回给父进程，0返回给子进程**。(如果小于0，则说明创建子进程失败)。
- 再次说明：当前进程调用`fork()`，会创建一个跟当前进程完全相同的子进程(除了pid)，所以子进程同样是会执行`fork()`之后的代码。

所以说：

- 父进程在执行if代码块的时候，`fpid变量`的值是子进程的pid
- 子进程在执行if代码块的时候，`fpid变量`的值是0

## 1.2再来看看exec()函数

从上面我们已经知道了fork会创建一个子进程。**子进程的是父进程的副本**。

exec函数的作用就是：**装载一个新的程序**（可执行映像）覆盖**当前进程**内存空间中的映像，**从而执行不同的任务**。

- exec系列函数在执行时会**直接替换掉当前进程的地址空间**。

我去画张图来理解一下：



![exec函数的作用](Docker%E5%85%A8%E8%A7%A3.assets/166c94cfc1728f4e)



参考资料：

- 程序员必备知识——fork和exec函数详解[blog.csdn.net/bad_good_ma…](https://link.juejin.im/?target=https%3A%2F%2Fblog.csdn.net%2Fbad_good_man%2Farticle%2Fdetails%2F49364947)
- linux中fork（）函数详解（原创！！实例讲解）：[blog.csdn.net/jason314/ar…](https://link.juejin.im/?target=https%3A%2F%2Fblog.csdn.net%2Fjason314%2Farticle%2Fdetails%2F5640969)
- linux c语言 fork() 和 exec 函数的简介和用法：[blog.csdn.net/nvd11/artic…](https://link.juejin.im/?target=https%3A%2F%2Fblog.csdn.net%2Fnvd11%2Farticle%2Fdetails%2F8856278)
- Linux下Fork与Exec使用：[www.cnblogs.com/hicjiajia/a…](https://link.juejin.im/?target=https%3A%2F%2Fwww.cnblogs.com%2Fhicjiajia%2Farchive%2F2011%2F01%2F20%2F1940154.html)
- Linux 系统调用 —— fork()内核源码剖析：[blog.csdn.net/chen8927040…](https://link.juejin.im/?target=https%3A%2F%2Fblog.csdn.net%2Fchen892704067%2Farticle%2Fdetails%2F76596225)

## 1.3回头来看Linux下的COW是怎么一回事

> fork()会产生一个和父进程完全相同的子进程(除了pid)

如果按**传统**的做法，会**直接**将父进程的数据拷贝到子进程中，拷贝完之后，父进程和子进程之间的数据段和堆栈是**相互独立的**。



![父进程的数据拷贝到子进程中](Docker%E5%85%A8%E8%A7%A3.assets/166c94cfc1818295)



但是，以我们的使用经验来说：往往子进程都会执行`exec()`来做自己想要实现的功能。

- 所以，如果按照上面的做法的话，创建子进程时复制过去的数据是没用的(因为子进程执行`exec()`，原有的数据会被清空)

既然很多时候复制给子进程的数据是无效的，于是就有了**Copy On Write**这项技术了，原理也很简单：

- fork创建出的子进程，**与父进程共享内存空间**。也就是说，如果子进程**不对内存空间进行写入操作的话，内存空间中的数据并不会复制给子进程**，这样创建子进程的速度就很快了！(不用复制，直接引用父进程的物理空间)。
- 并且如果在fork函数返回之后，子进程**第一时间**exec一个新的可执行映像，那么也不会浪费时间和内存空间了。

另外的表达方式：

> 在fork之后exec之前两个进程**用的是相同的物理空间**（内存区），子进程的代码段、数据段、堆栈都是指向父进程的物理空间，也就是说，两者的虚拟空间不同，但其对应的**物理空间是同一个**。

> 当父子进程中**有更改相应段的行为发生时**，再**为子进程相应的段分配物理空间**。

> 如果不是因为exec，内核会给子进程的数据段、堆栈段分配相应的物理空间（至此两者有各自的进程空间，互不影响），而代码段继续共享父进程的物理空间（两者的代码完全相同）。

> 而如果是因为exec，由于两者执行的代码不同，子进程的代码段也会分配单独的物理空间。

Copy On Write技术**实现原理：**

> fork()之后，kernel把父进程中所有的内存页的权限都设为read-only，然后子进程的地址空间指向父进程。当父子进程都只读内存时，相安无事。当其中某个进程写内存时，CPU硬件检测到内存页是read-only的，于是触发页异常中断（page-fault），陷入kernel的一个中断例程。中断例程中，kernel就会**把触发的异常的页复制一份**，于是父子进程各自持有独立的一份。

Copy On Write技术**好处**是什么？

- COW技术可**减少**分配和复制大量资源时带来的**瞬间延时**。
- COW技术可减少**不必要的资源分配**。比如fork进程时，并不是所有的页面都需要复制，父进程的**代码段和只读数据段都不被允许修改，所以无需复制**。

Copy On Write技术**缺点**是什么？

- 如果在fork()之后，父子进程都还需要继续进行写操作，**那么会产生大量的分页错误(页异常中断page-fault)**，这样就得不偿失。

几句话总结Linux的Copy On Write技术：

- fork出的子进程共享父进程的物理空间，当父子进程**有内存写入操作时**，read-only内存页发生中断，**将触发的异常的内存页复制一份**(其余的页还是共享父进程的)。
- fork出的子进程功能实现和父进程是一样的。如果有需要，我们会用`exec()`把当前进程映像替换成新的进程文件，完成自己想要实现的功能。

参考资料：

- Linux进程基础：[www.cnblogs.com/vamei/archi…](https://link.juejin.im/?target=http%3A%2F%2Fwww.cnblogs.com%2Fvamei%2Farchive%2F2012%2F09%2F20%2F2694466.html)
- Linux写时拷贝技术(copy-on-write)[www.cnblogs.com/biyeymyhjob…](https://link.juejin.im/?target=http%3A%2F%2Fwww.cnblogs.com%2Fbiyeymyhjob%2Farchive%2F2012%2F07%2F20%2F2601655.html)
- 当你在 Linux 上启动一个进程时会发生什么？[zhuanlan.zhihu.com/p/33159508](https://link.juejin.im/?target=https%3A%2F%2Fzhuanlan.zhihu.com%2Fp%2F33159508)
- Linux fork()所谓的写时复制(COW)到最后还是要先复制再写吗？[www.zhihu.com/question/26…](https://link.juejin.im/?target=https%3A%2F%2Fwww.zhihu.com%2Fquestion%2F265400460)
- 写时拷贝（copy－on－write） COW技术[blog.csdn.net/u012333003/…](https://link.juejin.im/?target=https%3A%2F%2Fblog.csdn.net%2Fu012333003%2Farticle%2Fdetails%2F25117457)
- Copy-On-Write 写时复制原理[blog.csdn.net/ppppppppp20…](https://link.juejin.im/?target=https%3A%2F%2Fblog.csdn.net%2Fppppppppp2009%2Farticle%2Fdetails%2F22750939)

## 二、解释一下Redis的COW

基于上面的基础，我们应该已经了解COW这么一项技术了。

下面我来说一下我对《Redis设计与实现》那段话的理解：

- Redis在持久化时，如果是采用BGSAVE命令或者BGREWRITEAOF的方式，那Redis会**fork出一个子进程来读取数据，从而写到磁盘中**。
- 总体来看，Redis还是读操作比较多。如果子进程存在期间，发生了大量的写操作，那可能就会出现**很多的分页错误(页异常中断page-fault)**，这样就得耗费不少性能在复制上。
- 而在**rehash阶段上，写操作是无法避免**的。所以Redis在fork出子进程之后，**将负载因子阈值提高**，尽量减少写操作，避免不必要的内存写入操作，最大限度地节约内存。

参考资料：

- fork()后copy on write的一些特性：[zhoujianshi.github.io/articles/20…](https://link.juejin.im/?target=https%3A%2F%2Fzhoujianshi.github.io%2Farticles%2F2017%2Ffork()%E5%90%8Ecopy%20on%20write%E7%9A%84%E4%B8%80%E4%BA%9B%E7%89%B9%E6%80%A7%2Findex.html)
- 写时复制：[miao1007.github.io/gitbook/jav…](https://link.juejin.im/?target=https%3A%2F%2Fmiao1007.github.io%2Fgitbook%2Fjava%2Fjuc%2Fcow%2F)

# 三、文件系统的COW

下面来看看文件系统中的COW是啥意思：

Copy-on-write在对数据进行修改的时候，**不会直接在原来的数据位置上进行操作**，而是重新找个位置修改，这样的好处是一旦系统突然断电，重启之后不需要做Fsck。好处就是能**保证数据的完整性，掉电的话容易恢复**。

- 比如说：要修改数据块A的内容，先把A读出来，写到B块里面去。如果这时候断电了，原来A的内容还在！

参考资料：

- 文件系统中的 copy-on-write 模式有什么具体的好处？[www.zhihu.com/question/19…](https://link.juejin.im/?target=https%3A%2F%2Fwww.zhihu.com%2Fquestion%2F19782224%2Fanswers%2Fcreated)
- 新一代 Linux 文件系统 btrfs 简介:[www.ibm.com/developerwo…](https://link.juejin.im/?target=https%3A%2F%2Fwww.ibm.com%2Fdeveloperworks%2Fcn%2Flinux%2Fl-cn-btrfs%2F)

# 最后

最后我们再来看一下写时复制的思想(摘录自维基百科)：

> 写入时复制（英语：Copy-on-write，简称COW）是一种计算机程序设计领域的优化策略。其核心思想是，如果有多个调用者（callers）同时请求相同资源（如内存或磁盘上的数据存储），他们会共同获取相同的指针指向相同的资源，直到某个调用者试图修改资源的内容时，系统才会真正复制一份专用副本（private copy）给该调用者，而其他调用者所见到的最初的资源仍然保持不变。这过程对其他的调用者都是透明的（transparently）。此作法主要的优点是如果调用者没有修改该资源，就不会有副本（private copy）被建立，因此多个调用者只是读取操作时可以共享同一份资源。

至少从本文我们可以总结出：

- Linux通过Copy On Write技术极大地**减少了Fork的开销**。
- 文件系统通过Copy On Write技术一定程度上保证**数据的完整性**。

其实在Java里边，也有Copy On Write技术。



![Java中的COW](Docker%E5%85%A8%E8%A7%A3.assets/166c94cfc1b8a75f)



这部分留到下一篇来说，敬请期待~

如果大家有更好的理解方式或者文章有错误的地方还请大家不吝在评论区留言，大家互相学习交流~~~

参考资料：

- 写时复制，写时拷贝，写时分裂，Copy on write：[my.oschina.net/dubenju/blo…](https://link.juejin.im/?target=https%3A%2F%2Fmy.oschina.net%2Fdubenju%2Fblog%2F815836)
- 不会产奶的COW(Copy-On-Write)[www.jianshu.com/p/b2fb2ee5e…](https://link.juejin.im/?target=https%3A%2F%2Fwww.jianshu.com%2Fp%2Fb2fb2ee5e3a0)