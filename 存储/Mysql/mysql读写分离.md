# 浅谈高性能数据库集群——读写分离

最近学习了阿里资深技术专家李运华的架构设计关于读写分离的教程，颇有收获，总结一下。

本文主要介绍高性能数据库集群读写分离相关理论，基本架构，涉及的复杂度问题以及常见解决方案。

# 1 读写分离概述

![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-e43f3412c6387b0a.webp)

读写分离概述.png

基本架构图：



![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-06f5e8df8aeb7eac.webp)

基本架构图.jpg

# 2 适用场景

![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-4163278bb12eced4.webp)

适用场景.png

**读写分离不是银弹，并不是一有性能问题就上读写分离，**而是应该先优化，例如优化慢查询，调整不合理的业务逻辑，引入缓存查询等只有确定系统没有优化空间后才考虑读写分离集群

# 3 引入的系统复杂度问题

## 问题一 主从复制延迟

![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-a20f9c336fe62c3b.webp)

主从复制延迟.png

## 问题二 分配机制

如何将读写操作区分开来，然后访问不同的数据库服务器？

### 解决方案1 客户端程序代码封装实现

**基本架构图**

![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-ea2f0f7e5d05f248.webp)

程序代码封装实现分配基本架构图



![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-2201ff0331bac1e9.webp)

程序代码封装

**业界开源实现**

- Sharding-JDBC
    定位为轻量级Java框架，在Java的JDBC层提供的额外服务。 它使用客户端直连数据库，以jar包形式提供服务，无需额外部署和依赖，可理解为增强版的JDBC驱动，完全兼容JDBC和各种ORM框架。

![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-2e54b4f173dcdefc.webp)

Sharding-JDBC基本架构图

- 淘宝TDDL
    淘宝根据自身业务需求研发了 TDDL （ Taobao Distributed Data Layer ）框架，主要用于解决 分库分表场景下的访问路由（持久层与数据访问层的配合）以及异构数据库之间的数据同步 ，它是一个基于集中式配置的 JDBC DataSource 实现，具有分库分表、 Master/Salve 、动态数据源配置等功能。

![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-1c6e396883493510.webp)

淘宝TDDL基本架构图

### 解决方案2 服务端中间件封装

**基本架构图**

![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-14d0897f3ff15bcb.webp)

服务端中间件封装实现分配基本架构图

![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-9174a86fd6e5f23b.webp)

服务端中间件封装

**业界开源实现**

- MySQL官方推荐的MySQL Router

![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-31ebcb40b8079f31.webp)

MySQL Router架构图

MySQL Router是轻量级的中间件，可在应用程序和任何后端MySQL服务器之间提供透明路由。它可以用于各种各样的用例，例如通过有效地将数据库流量路由到适当的后端MySQL服务器来提供高可用性和可伸缩性。可插拔架构还使开发人员能够扩展MySQL Router以用于自定义用例。

基于MySQL Router可以实现读写分离，故障自动切换，负载均衡，连接池等功能。

- MySQL官方提供的MySQL Proxy

    ![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-c3960a36b36ae8d4.webp)

    MySQL Proxy

- 360开源的Atlas

![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-c34706b5d7f379bd.webp)

Atlas架构图形象表示

![img](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/5618238-d7b51511d8fdbefe.webp)

Atlas总体架构

Atlas是由平台部基础架构团队开发维护的一个基于MySQL协议的数据中间层项目。它是在mysql-proxy的基础上，对其进行了优化，增加了一些新的功能特性。

### 常见的开源数据库中间件对比

| 功能                 | Sharding-JDBC |    TDDL     |           Amoeba            |        Cobar        |     MyCat     |
| :------------------- | :-----------: | :---------: | :-------------------------: | :-----------------: | :-----------: |
| 基于客户端还是服务端 |    客户端     |   客户端    |           服务端            |       服务端        |    服务端     |
| 分库分表             |      有       |     有      |             有              |         有          |      有       |
| MySQL交互协议        |  JDBC Driver  | JDBC Driver | 前端用NIO,后端用JDBC Driver | 前端用NIO,后端用BIO | 前后端均用NIO |
| 支持的数据库         |     任意      |    任意     |            任意             |        MySQL        |     任意      |

参考

[从0开始学架构——李运华](https://time.geekbang.org/column/intro/81?code=OK4eM0TBPTKGPRCzcZdzIeXjPACLfY3KCzATXOSWzXE%3D)

[Mycat原理解析-Mycat架构分析](https://blog.csdn.net/u011983531/article/details/78948680)





# Mycat原理解析-Mycat架构分析

## 一、常见的数据库中间件对比

| 功能                 | Sharding-JDBC | TDDL        | Amoeba                      | Cobar               | MyCat         |
| -------------------- | ------------- | ----------- | --------------------------- | ------------------- | ------------- |
| 基于客户端还是服务端 | 客户端        | 客户端      | 服务端                      | 服务端              | 服务端        |
| 分库分表             | 有            | 有          | 有                          | 有                  | 有            |
| MySQL交互协议        | JDBC Driver   | JDBC Driver | 前端用NIO,后端用JDBC Driver | 前端用NIO,后端用BIO | 前后端均用NIO |
| 支持的数据库         | 任意          | 任意        | 任意                        | MySQL               | 任意          |

> MyCat是社区爱好者在阿里Cobar基础上进行二次开发，解决了cobar当时存 在的一些问题，并且加入了许多新的功能在其中，目前MyCAT社区活跃度很高。

## 二、架构图

**1、Sharding-JDBC**
![这里写图片描述](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/20180102093743751.png)

**2、TDDL**
![这里写图片描述](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/20180102093812684.jpeg)

**3、Amoeba**
![这里写图片描述](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/20180102093835377.jpeg)

**4、Cobar**
![这里写图片描述](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/20180102093856544.jpeg)

**5、MyCat**
![这里写图片描述](mysql%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/20180102094016239.png)
总结：

1. TDDL 不同于其它几款产品，并非独立的中间件，只能算作中间层，是以 Jar 包方式提供给应用调用。属于JDBC Shard 的思想，网上也有很多其它类似产品。
2. Amoeba 是作为一个真正的独立中间件提供服务，即应用去连接 Amoeba 操作 MySQL 集群，就像操作
    单个 MySQL 一样。从架构中可以看来，Amoeba 算中间件中的早期产品，后端还在使用 JDBC Driver。
3. Cobar 是在 Amoeba 基础上进化的版本，一个显著变化是把后端 JDBC Driver 改为原生的 MySQL 通信协议层。后端去掉 JDBC Driver 后，意味着不再支持 JDBC 规范，不能支持 Oracle、PostgreSQL 等数据。但使
    用原生通信协议代替 JDBC Driver，后端的功能增加了很多想象力，比如主备切换、读写分离、异步操作等。
4. MyCat 又是在 Cobar 基础上发展的版本，两个显著点是：
    （1）后端由 BIO 改为 NIO，并发量有大幅提高
    （2）增加了对Order By、Group By、limit 等聚合功能的支持（虽然 Cobar 也可以支持 Order By、Group By、Limit 语法，但是结果没有进行聚合，只是简单返回给前端，聚合功能还是需要业务系统自己完成）。