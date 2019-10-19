# Apollo 与 superdiamond对比

| 功能                                 | superdiamond | Apollo |
| ------------------------------------ | ------------ | ------ |
| **统一管理不同环境、不同集群的配置** | Yes          | Yes    |
| **配置修改实时生效（热发布）**       | Yes          | Yes    |
| **版本发布管理**                     | No           | Yes    |
| **灰度发布**                         | No           | Yes    |
| **权限管理、发布审核、操作审计**     | No           | Yes    |
| **客户端配置信息监控**               | No           | Yes    |
| **提供Java和.Net原生客户端**         | Yes          | Yes    |
| **提供开放平台API**                  | No           | Yes    |
| **部署简单**                         | Yes          | Yes    |
| **分布式**                           | NO           | Yes    |
| **LDAP**                             | No           | Yes    |
| **Docker**                           | No           | Yes    |
| **kubernetes**                       | No           | Yes    |
|                                      |              |        |

> 下面主要介绍一款开源分布式配置中心 主要解决无法统一管理、审核配置文件，针对各个项目。

# Apollo（阿波罗）分布式配置中心

> 能够集中化管理应用不同环境、不同集群的配置，配置修改后能够实时推送到应用端，并且具备规范的权限、流程治理等特性，适用于微服务配置管理场景 服务端基于Spring Boot和Spring Cloud开发，打包后可以直接运行，不需要额外安装Tomcat等应用容器。 Java客户端不依赖任何框架，能够运行于所有Java运行时环境，同时对Spring/Spring Boot环境也有较好的支持。 .Net客户端不依赖任何框架，能够运行于所有.Net运行时环境。

## 功能特点

- 统一管理不同环境、不同集群的配置
    - Apollo提供了一个统一界面集中式管理不同环境（environment）、不同集群（cluster）、不同命名空间（namespace）的配置。
    - 同一份代码部署在不同的集群，可以有不同的配置，比如zk的地址等
    - 通过命名空间（namespace）可以很方便的支持多个不同应用共享同一份配置，同时还允许应用对共享的配置进行覆盖
- 配置修改实时生效（热发布）
    - 用户在Apollo修改完配置并发布后，客户端能实时（1秒）接收到最新的配置，并通知到应用程序。
- 版本发布管理
    - 所有的配置发布都有版本概念，从而可以方便的支持配置的回滚。
- 灰度发布
    - 支持配置的灰度发布，比如点了发布后，只对部分应用实例生效，等观察一段时间没问题后再推给所有应用实例。
- 权限管理、发布审核、操作审计
    - 应用和配置的管理都有完善的权限管理机制，对配置的管理还分为了编辑和发布两个环节，从而减少人为的错误。
    - 所有的操作都有审计日志，可以方便的追踪问题。
- 客户端配置信息监控
    - 可以方便的看到配置在被哪些实例使用
- 提供Java和.Net原生客户端
    - 提供了Java和.Net的原生客户端，方便应用集成
    - 支持Spring Placeholder, Annotation和Spring Boot的ConfigurationProperties，方便应用使用（需要Spring 3.1.1+）
    - 同时提供了Http接口，非Java和.Net应用也可以方便的使用
- 提供开放平台API
    - Apollo自身提供了比较完善的统一配置管理界面，支持多环境、多数据中心配置管理、权限、流程治理等特性。
    - 不过Apollo出于通用性考虑，对配置的修改不会做过多限制，只要符合基本的格式就能够保存。
    - 在我们的调研中发现，对于有些使用方，它们的配置可能会有比较复杂的格式，如xml, json，需要对格式做校验。
    - 还有一些使用方如DAL，不仅有特定的格式，而且对输入的值也需要进行校验后方可保存，如检查数据库、用户名和密码是否匹配。
    - 对于这类应用，Apollo支持应用方通过开放接口在Apollo进行配置的修改和发布，并且具备完善的授权和权限控制
- 部署简单
    - 配置中心作为基础服务，可用性要求非常高，这就要求Apollo对外部依赖尽可能地少
    - 目前唯一的外部依赖是MySQL，所以部署非常简单，只要安装好Java和MySQL就可以让Apollo跑起来
    - Apollo还提供了打包脚本，一键就可以生成所有需要的安装包，并且支持自定义运行时参数

## Apollo at a glance

### 基础模型

如下即是Apollo的基础模型：

- 用户在配置中心对配置进行修改并发布
- 配置中心通知Apollo客户端有配置更新
- Apollo客户端从配置中心拉取最新的配置、更新本地配置并通知到应用

![img](http://img.liuwenqi.com/blog/2019-07-19-190054.jpg)

### 界面概览

![img](http://img.liuwenqi.com/blog/2019-07-19-190118.jpg) **上图是Apollo配置中心中一个项目的配置首页**

- 在页面左上方的环境列表模块展示了所有的环境和集群，用户可以随时切换。
- 页面中央展示了两个namespace(application和FX.apollo)的配置信息，默认按照表格模式展示、编辑。用户也可以切换到文本模式，以文件形式查看、编辑。
- 页面上可以方便地进行发布、回滚、灰度、授权、查看更改历史和发布历史等操作

### 添加/修改配置项

用户可以通过配置中心界面方便的添加/修改配置项，更多使用说明请参见[应用接入指南](https://github.com/ctripcorp/apollo/wiki/应用接入指南)

![img](http://img.liuwenqi.com/blog/2019-07-19-190138.jpg) 输入配置信息：

![img](http://img.liuwenqi.com/blog/2019-07-19-190206.jpg)

### 发布配置

通过配置中心发布配置：

![img](http://img.liuwenqi.com/blog/2019-07-19-190223.jpg)

![img](http://img.liuwenqi.com/blog/2019-07-19-190300.jpg)

### 客户端监听配置变化（Java API样例）

配置发布后，就能在客户端获取到了，以Java为例，获取配置的示例代码如下。Apollo客户端还支持和Spring整合.

```java
Config config = ConfigService.getAppConfig();
Integer defaultRequestTimeout = 200;
Integer requestTimeout = config.getIntProperty("requestTimeout", defaultRequestTimeout);
```

**不过在某些场景下，应用还需要在配置变化时获得通知，比如数据库连接的切换等，所以Apollo还提供了监听配置变化的功能，Java示例如下.**

```java
Config config = ConfigService.getAppConfig();
config.addChangeListener(new ConfigChangeListener() {
  @Override
  public void onChange(ConfigChangeEvent changeEvent) {
    for (String key : changeEvent.changedKeys()) {
      ConfigChange change = changeEvent.getChange(key);
      System.out.println(String.format(
        "Found change - key: %s, oldValue: %s, newValue: %s, changeType: %s",
        change.getPropertyName(), change.getOldValue(),
        change.getNewValue(), change.getChangeType()));
     }
  }
});
```

具体java使用参考：[java客户端使用指南](https://github.com/ctripcorp/apollo/wiki/Java客户端使用指南)

### Spring集成样例

**Apollo和Spring也可以很方便地集成，只需要标注@EnableApolloConfig后就可以通过@Value获取配置信息：**

```java
@Configuration
@EnableApolloConfig
public class AppConfig {}
@Component
public class SomeBean {
    @Value("${request.timeout:200}")
    private int timeout;

    @ApolloConfigChangeListener
    private void someChangeHandler(ConfigChangeEvent changeEvent) {
        if (changeEvent.isChanged("request.timeout")) {
            refreshTimeout();
        }
    }
}
```

### 介绍 Apollo 几个核心概念

- application (应用)
    - 这个很好理解，就是实际使用配置的应用，Apollo客户端在运行时需要知道当前应用是谁，从而可以去获取对应的配置
    - 每个应用都需要有唯一的身份标识 -- appId，我们认为应用身份是跟着代码走的，所以需要在代码中配置
- environment (环境)
    - 配置对应的环境，Apollo客户端在运行时需要知道当前应用处于哪个环境，从而可以去获取应用的配置
    - 我们认为环境和代码无关，同一份代码部署在不同的环境就应该能够获取到不同环境的配置
    - 所以环境默认是通过读取机器上的配置（server.properties中的env属性）指定的，不过为了开发方便，我们也支持运行时通过System Property等指定
- cluster (集群)
    - 一个应用下不同实例的分组，比如典型的可以按照数据中心分，把上海机房的应用实例分为一个集群，把北京机房的应用实例分为另一个集群
    - 对不同的cluster，同一个配置可以有不一样的值，如zookeeper地址。
    - 集群默认是通过读取机器上的配置（server.properties中的idc属性）指定的，不过也支持运行时通过System Property指定
- namespace (命名空间)
    - 一个应用下不同配置的分组，可以简单地把namespace类比为文件，不同类型的配置存放在不同的文件中，如数据库配置文件，RPC配置文件，应用自身的配置文件等
    - 应用可以直接读取到公共组件的配置namespace，如DAL，RPC等
    - 应用也可以通过继承公共组件的配置namespace来对公共组件的配置做调整，如DAL的初始数据库连接数

## 总体设计

![img](http://img.liuwenqi.com/blog/2019-07-19-190322.jpg)

**上图简要描述了Apollo的总体设计，我们可以从下往上看：**

- Config Service提供配置的读取、推送等功能，服务对象是Apollo客户端
- Admin Service提供配置的修改、发布等功能，服务对象是Apollo Portal（管理界面）
- Config Service和Admin Service都是多实例、无状态部署，所以需要将自己注册到Eureka中并保持心跳
- 在Eureka之上我们架了一层Meta Server用于封装Eureka的服务发现接口
- Client通过域名访问Meta Server获取Config Service服务列表（IP+Port），而后直接通过IP+Port访问服务，同时在Client侧会做load balance、错误重试
- Portal通过域名访问Meta Server获取Admin Service服务列表（IP+Port），而后直接通过IP+Port访问服务，同时在Portal侧会做load balance、错误重试
- 为了简化部署，我们实际上会把Config Service、Eureka和Meta Server三个逻辑角色部署在同一个JVM进程中

## 客户端设计

![img](http://img.liuwenqi.com/blog/2019-07-19-190340.jpg)

**上图简要描述了Apollo客户端的实现原理：**

- 客户端和服务端保持了一个长连接，从而能第一时间获得配置更新的推送。
- 客户端还会定时从Apollo配置中心服务端拉取应用的最新配置。
    - 这是一个fallback机制，为了防止推送机制失效导致配置不更新
    - 客户端定时拉取会上报本地版本，所以一般情况下，对于定时拉取的操作，服务端都会返回304 - Not Modified
    - 定时频率默认为每5分钟拉取一次，客户端也可以通过在运行时指定System Property: apollo.refreshInterval来覆盖，单位为分钟。
- 客户端从Apollo配置中心服务端获取到应用的最新配置后，会保存在内存中
- 客户端会把从服务端获取到的配置在本地文件系统缓存一份
    - 在遇到服务不可用，或网络不通的时候，依然能从本地恢复配置
- 应用程序从Apollo客户端获取最新的配置、订阅配置更新通知

## 配置更新推送实现

前面提到了Apollo客户端和服务端保持了一个长连接，从而能第一时间获得配置更新的推送。

长连接实际上我们是通过Http Long Polling实现的，具体而言：

- 客户端发起一个Http请求到服务端
- 服务端会保持住这个连接60秒
    - 如果在60秒内有客户端关心的配置变化，被保持住的客户端请求会立即返回，并告知客户端有配置变化的namespace信息，客户端会据此拉取对应namespace的最新配置
    - 如果在60秒内没有客户端关心的配置变化，那么会返回Http状态码304给客户端
- 客户端在收到服务端请求后会立即重新发起连接，回到第一步
- 考虑到会有数万客户端向服务端发起长连，在服务端我们使用了async servlet(Spring DeferredResult)来服务Http Long Polling请求。

## 可用性考虑

> 配置中心作为基础服务，可用性要求非常高，下面的表格描述了不同场景下Apollo的可用性：

| 场景                   | 影响                                 | 降级                                  | 原因                                                         |
| ---------------------- | ------------------------------------ | ------------------------------------- | ------------------------------------------------------------ |
| 某台config service下线 | 无影响                               |                                       | Config service无状态，客户端重连其它config service           |
| 所有config service下线 | 客户端无法读取最新配置，Portal无影响 | 客户端重启时,可以读取本地缓存配置文件 |                                                              |
| 某台admin service下线  | 无影响                               |                                       | Admin service无状态，Portal重连其它admin service             |
| 所有admin service下线  | 客户端无影响，portal无法更新配置     |                                       |                                                              |
| 某台portal下线         | 无影响                               |                                       | Portal域名通过slb绑定多台服务器，重试后指向可用的服务器      |
| 全部portal下线         | 客户端无影响，portal无法更新配置     |                                       |                                                              |
| 某个数据中心下线       | 无影响                               |                                       | 多数据中心部署，数据完全同步，Meta Server/Portal域名通过slb自动切换到其它存活的数据中心 |

## 部署

### 单机测试部署

#### docker部署

**参考** [docker部署](https://github.com/ctripcorp/apollo/wiki/Apollo-Quick-Start-Docker部署)

### 分布式部署

**参考** [分布式部署](https://github.com/ctripcorp/apollo/wiki/分布式部署指南)

## 目前运维过程中遇到问题

- 配置中心问题
    - 没有统一配置中心，（微店使用superdiamond，拼餐使用svn，erp直接使用配置文件）
    - 部分工程没有应用到配置中心，多台服务器同时修改，无法做到统一管理。
    - 配置文件及配置中心无法做直接回滚，没有版本管理

> 解决问题思路：实用上述Apollo配置中心，进行统一管理及治理。保障所有配置及文件，版本、回滚、HA、权限审核等。

- 代码库管理问题
    - 没有统一代码管理工具。目前只有线上代码库
    - 无法从线下代码库，快速部署及上线
    - 开发代码到上线。没有做到统一标准化、流程化 ，无法做到CI、CD。

> 实用gitlab进行统一代码源管理，配置jenkins+ansible（playbook）进行 环境构建、maven打包、代码上线。实现持续构建，及持续集成。(及 CI、CD)。后期也可以使用docker、kubernetes等容器编排工具。