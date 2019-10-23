# 实战二：Django2.2之CMDB资产管理系统

### 项目基于**Django2.2**、**Adminlet-2.4.10**、Python3.7、Pycharm2018、windows10

## 一、概述

其实，一开始写这个实战项目，我是拒绝的，因为复杂，因为很多内容其实和Django无关，因为要考虑的问题太多。可是，如果不写一个有点含金量、贴近运维实际的项目，那么教程又流于形式，与一些不痛不痒的文章没什么区别。

**说明：本项目不是一个完整的CMDB系统，主要针对其最重要的资产管理系统。**

本实战项目主要是给大家提供一个基本思路和大致解决方案，而不是让你抄了代码就直接上线的。这里不考虑特别细的细节，也无法实现所有的业务逻辑，更不能作为考核的对象，所以请不要纠结这个地方应该是这样，那个地方不应该是那样的问题，而是关注原来CMDB是这么回事，可以通过哪种技术途径实现，大概要什么样的技术这些问题，主要的代码片段是哪些。

**整个项目最麻烦的就是数据的规格性、合法性、完整性和数据类型的验证**。不同的环境生成不同的数据，为了保证程序的健壮性，必须进行一系列的逻辑判断，这些都需要根据实际情况实际解决。作为一个教程的实战项目，不可能考虑得面面俱到，并且覆盖所有情况。**这里我默认客户端发送过来的数据是规整的，数据类型是正确的**。

**重要说明：**

1. 默认你已经有了一定的Python和Django基础，否则请学习网站的相关部分内容；
2. 默认你具有一定的Linux操作系统基础，最好是运维人员；

本项目的所有代码可以从Github上下载，地址为：

```
https://github.com/feixuelove1009/CMDB
```

在Linux下直接使用：

```
git clone https://github.com/feixuelove1009/CMDB
```

在Windows下，通过Pycharm就可下载，当然也可以使用git软件下载。

## 二、项目展示

**仪表盘：**

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/116-1.png)

**折叠状态的仪表盘：**

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/116-2.png)

**资产总表：**

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/116-3.png)

**侧边栏缩放的资产总表：**

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/116-4.png)

**资产详细表一：**

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/116-5.png)

**资产详细表二：**

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/116-6.png)

项目的前端使用的是开源的AdminLTE 2.4.10模板，不仅美观大方，而且基于Bootstrap的特性，对移动设备和小屏端有很好的支持。

# 1.项目需求分析

## 一、CMDB简介

**CMDB (Configuration Management Database)配置管理数据库**:

CMDB用于存储与管理企业IT架构中设备的各种配置信息，它与所有服务支持和服务交付流程都紧密相联，支持这些流程的运转、发挥配置信息的价值，同时依赖于相关流程保证数据的准确性。

CMDB是ITIL(Information Technology Infrastructure Library，信息技术基础架构库)的基础，常常被认为是构建其它ITIL流程的先决条件而优先考虑，ITIL项目的成败与是否成功建立CMDB有非常大的关系。

CMDB的核心是对整个公司的IT硬件/软件资源进行自动/手动收集、变更操作，说白了也就是对IT资产进行自动化管理，这也是本项目的重点。

## 二、项目需求分析

**本项目不是一个完整的的CMDB系统，重点针对服务器资产的自动数据收集、报告、接收、审批、更新和展示，搭建一个基础的面向运维的主机管理平台。**

下面是项目需求的总结：

- 尽可能存储所有的IT资产数据，但不包括鼠标键盘外设、优盘、显示器这种属于行政部门管理的设备；
- 硬件信息可自动收集、报告、分析、存储和展示；
- 具有后台管理人员的工作界面；
- 具有前端可视化展示的界面；
- 具有日志记录功能；
- 数据可手动添加、修改和删除。

当然，实际的CMDB项目需求绝对不止这些，还有诸如用户管理、权限管理、API安全认证、REST设计等等。

## 三、资产分类

资产种类众多，不是所有的都需要CMDB管理，也不是什么都是CMDB能管理的。

下面是一个大致的分类，不一定准确、全面：

资产类型包括：

- 服务器
- 存储设备
- 安全设备
- 网络设备
- 软件资产

服务器又可分为：

- 刀片服务器
- PC服务器
- 小型机
- 大型机
- 其它

存储设备包括：

- 磁盘阵列
- 网络存储器
- 磁带库
- 磁带机
- 其它

安全设备包括：

- 防火墙
- 入侵检测设备
- 互联网网关
- 漏洞扫描设备
- 数字签名设备
- 上网行为管理设备
- 运维审计设备
- 加密机
- 其它

网络设备包括：

- 路由器
- 交换器
- 负载均衡
- VPN
- 流量分析
- 其它

软件资产包括：

- 操作系统授权
- 大型软件授权
- 数据库授权
- 其它

其中，服务器是运维部门最关心的，也是CMDB中最主要、最方便进行自动化管理的资产。

服务器又可以包含下面的部件：

- CPU
- 硬盘
- 内存
- 网卡

除此之外，我们还要考虑下面的一些内容：

- 机房
- 业务线
- 合同
- 管理员
- 审批员
- 资产标签
- 其它未尽事宜

------

大概对资产进行了分类之后，就要详细考虑各细分数据条目了。

**共有数据条目：**

有一些数据条目是所有资产都应该有的，比如：

- 资产名称
- 资产sn
- 所属业务线
- 设备状态
- 制造商
- 管理IP
- 所在机房
- 资产管理员
- 资产标签
- 合同
- 价格
- 购买日期
- 过保日期
- 批准人
- 批准日期
- 数据更新日期
- 备注

另外，不同类型的资产还有各自不同的数据条目，例如服务器：

**服务器：**

- 服务器类型
- 添加方式
- 宿主机
- 服务器型号
- Raid类型
- 操作系统类型
- 发行版本
- 操作系统版本

**其实，在开始正式编写CMDB项目代码之前，对项目的需求分析准确与否，数据条目的安排是否合理，是决定整个CMDB项目成败的关键。这一部分工作看似简单其实复杂，看似无用其实关键，做好了，项目基础就牢固，没做好，推到重来好几遍很正常！**

# 2.模型设计

## 一、创建项目

让我们新开一个副本....咳咳，新建一个项目。

首先，通过Pycharm直接创建CMDB项目，建立虚拟环境`env`，安装最新的Django2.2，生成一个app，名字就叫做assets，最后配置好settings中的语言和时区。这些基本过程以后就不再赘述了，不熟悉的请参考教程的前面部分。

创建成功后，初始状态如下图所示：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/118-1.png)

## 二、模型设计

**说明：本项目采用SQLite数据库**

模型设计是整个项目的重中之重，其它所有的内容其实都是围绕它展开的。

而我们设计数据模型的原则和参考依据是前一节分析的项目需求和数据分类表。

我们的模型架构图如下所示：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/118-2.png)

### 1.资产共有数据模型

打开assets/models.py文件，首先我们要设计一张资产共有数据表：

```
from django.db import models
from django.contrib.auth.models import User
# Create your models here.


class Asset(models.Model):
    """    所有资产的共有数据表    """

    asset_type_choice = (
        ('server', '服务器'),
        ('networkdevice', '网络设备'),
        ('storagedevice', '存储设备'),
        ('securitydevice', '安全设备'),
        ('software', '软件资产'),
    )

    asset_status = (
        (0, '在线'),
        (1, '下线'),
        (2, '未知'),
        (3, '故障'),
        (4, '备用'),
        )

    asset_type = models.CharField(choices=asset_type_choice, max_length=64, default='server', verbose_name="资产类型")
    name = models.CharField(max_length=64, unique=True, verbose_name="资产名称")     # 不可重复
    sn = models.CharField(max_length=128, unique=True, verbose_name="资产序列号")  # 不可重复
    business_unit = models.ForeignKey('BusinessUnit', null=True, blank=True, verbose_name='所属业务线',
                                      on_delete=models.SET_NULL)
    status = models.SmallIntegerField(choices=asset_status, default=0, verbose_name='设备状态')

    manufacturer = models.ForeignKey('Manufacturer', null=True, blank=True, verbose_name='制造商',
                                     on_delete=models.SET_NULL)
    manage_ip = models.GenericIPAddressField(null=True, blank=True, verbose_name='管理IP')
    tags = models.ManyToManyField('Tag', blank=True, verbose_name='标签')
    admin = models.ForeignKey(User, null=True, blank=True, verbose_name='资产管理员', related_name='admin',
                              on_delete=models.SET_NULL)
    idc = models.ForeignKey('IDC', null=True, blank=True, verbose_name='所在机房', on_delete=models.SET_NULL)
    contract = models.ForeignKey('Contract', null=True, blank=True, verbose_name='合同', on_delete=models.SET_NULL)

    purchase_day = models.DateField(null=True, blank=True, verbose_name="购买日期")
    expire_day = models.DateField(null=True, blank=True, verbose_name="过保日期")
    price = models.FloatField(null=True, blank=True, verbose_name="价格")

    approved_by = models.ForeignKey(User, null=True, blank=True, verbose_name='批准人', related_name='approved_by',
                                    on_delete=models.SET_NULL)

    memo = models.TextField(null=True, blank=True, verbose_name='备注')
    c_time = models.DateTimeField(auto_now_add=True, verbose_name='批准日期')
    m_time = models.DateTimeField(auto_now=True, verbose_name='更新日期')

    def __str__(self):
        return '<%s>  %s' % (self.get_asset_type_display(), self.name)

    class Meta:
        verbose_name = '资产总表'
        verbose_name_plural = "资产总表"
        ordering = ['-c_time']
```

说明：

- 导入django.contrib.auto.models内置的User表，作为我们CMDB项目的用户表，用于保存管理员和批准人员的信息；
- sn这个数据字段是所有资产都必须有，并且唯一不可重复的！通常来自自动收集的数据中；
- name和sn一样，也是唯一的；
- asset_type_choice和asset_status分别设计为两个选择类型
- adamin和approved_by是分别是当前资产的管理员和将该资产上线的审批员，为了区分他们，设置了related_name；
- Asset表中的很多字段内容都无法自动获取，需要我们手动输入，比如合同、备注。
- 最关键的是其中的一些外键字段，设置为`on_delete=models.SET_NULL`，这样的话，当关联的对象被删除的时候，不会影响到资产数据表。

### 2.服务器模型

服务器作为资产的一种，而且是最主要的管理对象，包含了一些重要的字段，其模型结构如下：

```
class Server(models.Model):
    """服务器设备"""

    sub_asset_type_choice = (
        (0, 'PC服务器'),
        (1, '刀片机'),
        (2, '小型机'),
    )

    created_by_choice = (
        ('auto', '自动添加'),
        ('manual', '手工录入'),
    )

    asset = models.OneToOneField('Asset', on_delete=models.CASCADE)  # 非常关键的一对一关联！asset被删除的时候一并删除server
    sub_asset_type = models.SmallIntegerField(choices=sub_asset_type_choice, default=0, verbose_name="服务器类型")
    created_by = models.CharField(choices=created_by_choice, max_length=32, default='auto', verbose_name="添加方式")
    hosted_on = models.ForeignKey('self', related_name='hosted_on_server',
                                  blank=True, null=True, verbose_name="宿主机", on_delete=models.CASCADE)  # 虚拟机专用字段
    model = models.CharField(max_length=128, null=True, blank=True, verbose_name='服务器型号')
    raid_type = models.CharField(max_length=512, blank=True, null=True, verbose_name='Raid类型')

    os_type = models.CharField('操作系统类型', max_length=64, blank=True, null=True)
    os_distribution = models.CharField('发行商', max_length=64, blank=True, null=True)
    os_release = models.CharField('操作系统版本', max_length=64, blank=True, null=True)

    def __str__(self):
        return '%s--%s--%s <sn:%s>' % (self.asset.name, self.get_sub_asset_type_display(), self.model, self.asset.sn)

    class Meta:
        verbose_name = '服务器'
        verbose_name_plural = "服务器"
```

说明：

- 每台服务器都唯一关联着一个资产对象，因此使用OneToOneField构建了一个一对一字段，这非常重要!
- 服务器又可分为几种子类型，这里定义了三种；
- 服务器添加的方式可以分为手动和自动；
- 有些服务器是虚拟机或者docker生成的，没有物理实体，存在于宿主机中，因此需要增加一个hosted_on字段；这里认为，宿主机如果被删除，虚拟机也就不存在了；
- 服务器有型号信息，如果硬件信息中不包含，那么指的就是主板型号；
- Raid类型在采用了Raid的时候才有，否则为空
- 操作系统相关信息包含类型、发行版本和具体版本。

### 3.安全、网络、存储设备和软件资产的模型

这部分内容不是项目的主要内容，而且数据大多数不能自动收集和报告，很多都需要手工录入。我这里给出了范例，更多的数据字段，可以自行添加。

```
class SecurityDevice(models.Model):
    """安全设备"""

    sub_asset_type_choice = (
        (0, '防火墙'),
        (1, '入侵检测设备'),
        (2, '互联网网关'),
        (4, '运维审计系统'),
    )

    asset = models.OneToOneField('Asset', on_delete=models.CASCADE)
    sub_asset_type = models.SmallIntegerField(choices=sub_asset_type_choice, default=0, verbose_name="安全设备类型")
    model = models.CharField(max_length=128, default='未知型号', verbose_name='安全设备型号')

        def __str__(self):
            return self.asset.name + "--" + self.get_sub_asset_type_display() + str(self.model) + " id:%s" % self.id

    class Meta:
        verbose_name = '安全设备'
        verbose_name_plural = "安全设备"


class StorageDevice(models.Model):
    """存储设备"""

    sub_asset_type_choice = (
        (0, '磁盘阵列'),
        (1, '网络存储器'),
        (2, '磁带库'),
        (4, '磁带机'),
    )

    asset = models.OneToOneField('Asset', on_delete=models.CASCADE)
    sub_asset_type = models.SmallIntegerField(choices=sub_asset_type_choice, default=0, verbose_name="存储设备类型")
    model = models.CharField(max_length=128, default='未知型号', verbose_name='存储设备型号')

    def __str__(self):
        return self.asset.name + "--" + self.get_sub_asset_type_display() + str(self.model) + " id:%s" % self.id

    class Meta:
        verbose_name = '存储设备'
        verbose_name_plural = "存储设备"


class NetworkDevice(models.Model):
    """网络设备"""

    sub_asset_type_choice = (
        (0, '路由器'),
        (1, '交换机'),
        (2, '负载均衡'),
        (4, 'VPN设备'),
    )

    asset = models.OneToOneField('Asset', on_delete=models.CASCADE)
    sub_asset_type = models.SmallIntegerField(choices=sub_asset_type_choice, default=0, verbose_name="网络设备类型")

    vlan_ip = models.GenericIPAddressField(blank=True, null=True, verbose_name="VLanIP")
    intranet_ip = models.GenericIPAddressField(blank=True, null=True, verbose_name="内网IP")

    model = models.CharField(max_length=128, default='未知型号',  verbose_name="网络设备型号")
    firmware = models.CharField(max_length=128, blank=True, null=True, verbose_name="设备固件版本")
    port_num = models.SmallIntegerField(null=True, blank=True, verbose_name="端口个数")
    device_detail = models.TextField(null=True, blank=True, verbose_name="详细配置")

    def __str__(self):
        return '%s--%s--%s <sn:%s>' % (self.asset.name, self.get_sub_asset_type_display(), self.model, self.asset.sn)

    class Meta:
        verbose_name = '网络设备'
        verbose_name_plural = "网络设备"


class Software(models.Model):
    """
    只保存付费购买的软件
    """
    sub_asset_type_choice = (
        (0, '操作系统'),
        (1, '办公\开发软件'),
        (2, '业务软件'),
    )

    sub_asset_type = models.SmallIntegerField(choices=sub_asset_type_choice, default=0, verbose_name="软件类型")
    license_num = models.IntegerField(default=1, verbose_name="授权数量")
    version = models.CharField(max_length=64, unique=True, help_text='例如: RedHat release 7 (Final)',
                               verbose_name='软件/系统版本')

    def __str__(self):
        return '%s--%s' % (self.get_sub_asset_type_display(), self.version)

    class Meta:
        verbose_name = '软件/系统'
        verbose_name_plural = "软件/系统"
```

说明：

- 每台安全、网络、存储设备都通过一对一的方式唯一关联这一个资产对象。
- 通过sub_asset_type又细分设备的子类型
- 对于软件，它没有物理形体，因此无须关联一个资产对象；
- 软件只管理那些大型的收费软件，关注点是授权数量和软件版本。对于那些开源的或者免费的软件，显然不算公司的资产。

### 4.机房、制造商、业务线、合同、资产标签等数据模型

这一部分是CMDB中相关的内容，数据表建立后，可以通过手动添加。

```
class IDC(models.Model):
    """机房"""
    name = models.CharField(max_length=64, unique=True, verbose_name="机房名称")
    memo = models.CharField(max_length=128, blank=True, null=True, verbose_name='备注')

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '机房'
        verbose_name_plural = "机房"


class Manufacturer(models.Model):
    """厂商"""

    name = models.CharField('厂商名称', max_length=64, unique=True)
    telephone = models.CharField('支持电话', max_length=30, blank=True, null=True)
    memo = models.CharField('备注', max_length=128, blank=True, null=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '厂商'
        verbose_name_plural = "厂商"


class BusinessUnit(models.Model):
    """业务线"""

    parent_unit = models.ForeignKey('self', blank=True, null=True, related_name='parent_level', on_delete=models.SET_NULL)
    name = models.CharField('业务线', max_length=64, unique=True)
    memo = models.CharField('备注', max_length=64, blank=True, null=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '业务线'
        verbose_name_plural = "业务线"


class Contract(models.Model):
    """合同"""

    sn = models.CharField('合同号', max_length=128, unique=True)
    name = models.CharField('合同名称', max_length=64)
    memo = models.TextField('备注', blank=True, null=True)
    price = models.IntegerField('合同金额')
    detail = models.TextField('合同详细', blank=True, null=True)
    start_day = models.DateField('开始日期', blank=True, null=True)
    end_day = models.DateField('失效日期', blank=True, null=True)
    license_num = models.IntegerField('license数量', blank=True, null=True)
    c_day = models.DateField('创建日期', auto_now_add=True)
    m_day = models.DateField('修改日期', auto_now=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '合同'
        verbose_name_plural = "合同"


class Tag(models.Model):
    """标签"""
    name = models.CharField('标签名', max_length=32, unique=True)
    c_day = models.DateField('创建日期', auto_now_add=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '标签'
        verbose_name_plural = "标签"
```

说明：

- 机房可以有很多其它字段，比如城市、楼号、楼层和未知等等，如有需要可自行添加；
- 业务线可以有子业务线，因此使用一个外键关联自身模型；
- 合同模型主要存储财务部门关心的数据；
- 资产标签模型与资产是多对多的关系。

### 5.CPU模型

通常一台服务器中只能有一种CPU型号，所以这里使用OneToOneField唯一关联一个资产对象，而不是外键关系。服务器上可以有多个物理CPU，它们的型号都是一样的。每个物理CPU又可能包含多核。

```
class CPU(models.Model):
    """CPU组件"""

    asset = models.OneToOneField('Asset', on_delete=models.CASCADE)  # 设备上的cpu肯定都是一样的，所以不需要建立多个cpu数据，一条就可以，因此使用一对一。
    cpu_model = models.CharField('CPU型号', max_length=128, blank=True, null=True)
    cpu_count = models.PositiveSmallIntegerField('物理CPU个数', default=1)
    cpu_core_count = models.PositiveSmallIntegerField('CPU核数', default=1)

    def __str__(self):
        return self.asset.name + ":   " + self.cpu_model

    class Meta:
        verbose_name = 'CPU'
        verbose_name_plural = "CPU"
```

### 6.RAM模型

某个资产中可能有多条内存，所以这里必须是外键关系。其次，内存的sn号可能无法获得，就必须通过内存所在的插槽未知来唯一确定每条内存。因此，`unique_together = ('asset', 'slot')`这条设置非常关键，相当于内存的主键了，每条内存数据必须包含slot字段，否则就不合法。

```
class RAM(models.Model):
    """内存组件"""

    asset = models.ForeignKey('Asset', on_delete=models.CASCADE)
    sn = models.CharField('SN号', max_length=128, blank=True, null=True)
    model = models.CharField('内存型号', max_length=128, blank=True, null=True)
    manufacturer = models.CharField('内存制造商', max_length=128, blank=True, null=True)
    slot = models.CharField('插槽', max_length=64)
    capacity = models.IntegerField('内存大小(GB)', blank=True, null=True)

    def __str__(self):
        return '%s: %s: %s: %s' % (self.asset.name, self.model, self.slot, self.capacity)

    class Meta:
        verbose_name = '内存'
        verbose_name_plural = "内存"
        unique_together = ('asset', 'slot')  # 同一资产下的内存，根据插槽的不同，必须唯一
```

### 7. 硬盘模型

与内存相同的是，硬盘也可能有很多块，所以也是外键关系。不同的是，硬盘通常都能获取到sn号，使用sn作为唯一值比较合适，也就是`unique_together = ('asset', 'sn')`。硬盘有不同的接口，这里设置了4种以及unknown，可自行添加其它类别。

```
class Disk(models.Model):
    """硬盘设备"""

    disk_interface_type_choice = (
        ('SATA', 'SATA'),
        ('SAS', 'SAS'),
        ('SCSI', 'SCSI'),
        ('SSD', 'SSD'),
        ('unknown', 'unknown'),
    )

    asset = models.ForeignKey('Asset', on_delete=models.CASCADE)
    sn = models.CharField('硬盘SN号', max_length=128)
    slot = models.CharField('所在插槽位', max_length=64, blank=True, null=True)
    model = models.CharField('磁盘型号', max_length=128, blank=True, null=True)
    manufacturer = models.CharField('磁盘制造商', max_length=128, blank=True, null=True)
    capacity = models.FloatField('磁盘容量(GB)', blank=True, null=True)
    interface_type = models.CharField('接口类型', max_length=16, choices=disk_interface_type_choice, default='unknown')

    def __str__(self):
        return '%s:  %s:  %s:  %sGB' % (self.asset.name, self.model, self.slot, self.capacity)

    class Meta:
        verbose_name = '硬盘'
        verbose_name_plural = "硬盘"
        unique_together = ('asset', 'sn')
```

### 8.网卡模型

一台设备中可能有很多块网卡，所以网卡与资产也是外键的关系。另外，由于虚拟机的存在，网卡的mac地址可能会发生重复，无法唯一确定某块网卡，因此通过网卡型号加mac地址的方式来唯一确定网卡。

```
class NIC(models.Model):
    """网卡组件"""

    asset = models.ForeignKey('Asset', on_delete=models.CASCADE)  # 注意要用外键
    name = models.CharField('网卡名称', max_length=64, blank=True, null=True)
    model = models.CharField('网卡型号', max_length=128)
    mac = models.CharField('MAC地址', max_length=64)  # 虚拟机有可能会出现同样的mac地址
    ip_address = models.GenericIPAddressField('IP地址', blank=True, null=True)
    net_mask = models.CharField('掩码', max_length=64, blank=True, null=True)
    bonding = models.CharField('绑定地址', max_length=64, blank=True, null=True)

    def __str__(self):
        return '%s:  %s:  %s' % (self.asset.name, self.model, self.mac)

    class Meta:
        verbose_name = '网卡'
        verbose_name_plural = "网卡"
        unique_together = ('asset', 'model', 'mac')  # 资产、型号和mac必须联合唯一。防止虚拟机中的特殊情况发生错误。
```

### 9. 其它模型

比如机房、厂商、标签、业务线、合同等其它信息。

```
class IDC(models.Model):
    """机房"""
    name = models.CharField(max_length=64, unique=True, verbose_name="机房名称")
    memo = models.CharField(max_length=128, blank=True, null=True, verbose_name='备注')

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '机房'
        verbose_name_plural = "机房"


class Manufacturer(models.Model):
    """厂商"""

    name = models.CharField('厂商名称', max_length=64, unique=True)
    telephone = models.CharField('支持电话', max_length=30, blank=True, null=True)
    memo = models.CharField('备注', max_length=128, blank=True, null=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '厂商'
        verbose_name_plural = "厂商"


class BusinessUnit(models.Model):
    """业务线"""

    parent_unit = models.ForeignKey('self', blank=True, null=True, related_name='parent_level',
                                    on_delete=models.CASCADE)
    name = models.CharField('业务线名称', max_length=64, unique=True)
    memo = models.CharField('备注', max_length=64, blank=True, null=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '业务线'
        verbose_name_plural = "业务线"


class Contract(models.Model):
    """合同"""

    sn = models.CharField('合同号', max_length=128, unique=True)
    name = models.CharField('合同名称', max_length=64)
    memo = models.TextField('备注', blank=True, null=True)
    price = models.IntegerField('合同金额')
    detail = models.TextField('合同详细', blank=True, null=True)
    start_day = models.DateField('开始日期', blank=True, null=True)
    end_day = models.DateField('失效日期', blank=True, null=True)
    license_num = models.IntegerField('license数量', blank=True, null=True)
    c_day = models.DateField('创建日期', auto_now_add=True)
    m_day = models.DateField('修改日期', auto_now=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '合同'
        verbose_name_plural = "合同"


class Tag(models.Model):
    """标签"""
    name = models.CharField('标签名', max_length=32, unique=True)
    c_day = models.DateField('创建日期', auto_now_add=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '标签'
        verbose_name_plural = "标签"
```

### 10.日志模型

CMDB必须记录各种日志，这是毫无疑问的！我们通常要记录事件名称、类型、关联的资产、子事件、事件详情、谁导致的、发生时间。这些都很重要！

尤其要注意的是，事件日志不能随着关联资产的删除被一并删除，也就是我们设置`on_delete=models.SET_NULL`的意义！

```
class EventLog(models.Model):
    """
    日志.
    在关联对象被删除的时候，不能一并删除，需保留日志。
    因此，on_delete=models.SET_NULL
    """

    name = models.CharField('事件名称', max_length=128)
    event_type_choice = (
        (0, '其它'),
        (1, '硬件变更'),
        (2, '新增配件'),
        (3, '设备下线'),
        (4, '设备上线'),
        (5, '定期维护'),
        (6, '业务上线\更新\变更'),
    )
    asset = models.ForeignKey('Asset', blank=True, null=True, on_delete=models.SET_NULL)  # 当资产审批成功时有这项数据
    new_asset = models.ForeignKey('NewAssetApprovalZone', blank=True, null=True, on_delete=models.SET_NULL)  # 当资产审批失败时有这项数据
    event_type = models.SmallIntegerField('事件类型', choices=event_type_choice, default=4)
    component = models.CharField('事件子项', max_length=256, blank=True, null=True)
    detail = models.TextField('事件详情')
    date = models.DateTimeField('事件时间', auto_now_add=True)
    user = models.ForeignKey(User, blank=True, null=True, verbose_name='事件执行人', on_delete=models.SET_NULL)  # 自动更新资产数据时没有执行人
    memo = models.TextField('备注', blank=True, null=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '事件纪录'
        verbose_name_plural = "事件纪录"
```

### 11.新资产待审批区模型

新资产的到来，并不能直接加入CMDB数据库中，而是要通过管理员审批后，才可以上线的。这就需要一个新资产的待审批区。在该区中，以资产的sn号作为唯一值，确定不同的资产。除了关键的包含资产所有信息的data字段，为了方便审批员查看信息，我们还设计了一些厂商、型号、内存大小、CPU类型等字段。同时，有可能出现资产还未审批，更新数据就已经发过来的情况，所以需要一个数据更新日期字段。

```
class NewAssetApprovalZone(models.Model):
    """新资产待审批区"""

    sn = models.CharField('资产SN号', max_length=128, unique=True)  # 此字段必填
    asset_type_choice = (
        ('server', '服务器'),
        ('networkdevice', '网络设备'),
        ('storagedevice', '存储设备'),
        ('securitydevice', '安全设备'),
        ('software', '软件资产'),
    )
    asset_type = models.CharField(choices=asset_type_choice, default='server', max_length=64, blank=True, null=True,
                                  verbose_name='资产类型')

    manufacturer = models.CharField(max_length=64, blank=True, null=True, verbose_name='生产厂商')
    model = models.CharField(max_length=128, blank=True, null=True, verbose_name='型号')
    ram_size = models.PositiveIntegerField(blank=True, null=True, verbose_name='内存大小')
    cpu_model = models.CharField(max_length=128, blank=True, null=True, verbose_name='CPU型号')
    cpu_count = models.PositiveSmallIntegerField('CPU物理数量', blank=True, null=True)
    cpu_core_count = models.PositiveSmallIntegerField('CPU核心数量', blank=True, null=True)
    os_distribution = models.CharField('发行商', max_length=64, blank=True, null=True)
    os_type = models.CharField('系统类型', max_length=64, blank=True, null=True)
    os_release = models.CharField('操作系统版本号', max_length=64, blank=True, null=True)

    data = models.TextField('资产数据')  # 此字段必填

    c_time = models.DateTimeField('汇报日期', auto_now_add=True)
    m_time = models.DateTimeField('数据更新日期', auto_now=True)
    approved = models.BooleanField('是否批准', default=False)

    def __str__(self):
        return self.sn

    class Meta:
        verbose_name = '新上线待批准资产'
        verbose_name_plural = "新上线待批准资产"
        ordering = ['-c_time']
```

### 11.总结

通过前面的内容，我们可以看出CMDB数据模型的设计非常复杂，我们这里还是省略了很多不太重要的部分，就这样总共都有400多行代码。其中每个模型需要保存什么字段、采用什么类型、什么关联关系、定义哪些参数、数据是否可以为空，这些都是踩过各种坑后总结出来的，不是随便就能定义的。所以，请务必详细阅读和揣摩这些模型的内容。

一切没有问题之后，注册app，然后makemigrations以及migrate!

最后附上整个models.py文件的代码：

```python
from django.db import models
from django.contrib.auth.models import User
# Create your models here.


class Asset(models.Model):
    """    所有资产的共有数据表    """

    asset_type_choice = (
        ('server', '服务器'),
        ('networkdevice', '网络设备'),
        ('storagedevice', '存储设备'),
        ('securitydevice', '安全设备'),
        ('software', '软件资产'),
    )

    asset_status = (
        (0, '在线'),
        (1, '下线'),
        (2, '未知'),
        (3, '故障'),
        (4, '备用'),
        )

    asset_type = models.CharField(choices=asset_type_choice, max_length=64, default='server', verbose_name="资产类型")
    name = models.CharField(max_length=64, unique=True, verbose_name="资产名称")     # 不可重复
    sn = models.CharField(max_length=128, unique=True, verbose_name="资产序列号")  # 不可重复
    business_unit = models.ForeignKey('BusinessUnit', null=True, blank=True, verbose_name='所属业务线',
                                      on_delete=models.SET_NULL)
    status = models.SmallIntegerField(choices=asset_status, default=0, verbose_name='设备状态')

    manufacturer = models.ForeignKey('Manufacturer', null=True, blank=True, verbose_name='制造商',
                                     on_delete=models.SET_NULL)
    manage_ip = models.GenericIPAddressField(null=True, blank=True, verbose_name='管理IP')
    tags = models.ManyToManyField('Tag', blank=True, verbose_name='标签')
    admin = models.ForeignKey(User, null=True, blank=True, verbose_name='资产管理员', related_name='admin',
                              on_delete=models.SET_NULL)
    idc = models.ForeignKey('IDC', null=True, blank=True, verbose_name='所在机房', on_delete=models.SET_NULL)
    contract = models.ForeignKey('Contract', null=True, blank=True, verbose_name='合同', on_delete=models.SET_NULL)

    purchase_day = models.DateField(null=True, blank=True, verbose_name="购买日期")
    expire_day = models.DateField(null=True, blank=True, verbose_name="过保日期")
    price = models.FloatField(null=True, blank=True, verbose_name="价格")

    approved_by = models.ForeignKey(User, null=True, blank=True, verbose_name='批准人', related_name='approved_by',
                                    on_delete=models.SET_NULL)

    memo = models.TextField(null=True, blank=True, verbose_name='备注')
    c_time = models.DateTimeField(auto_now_add=True, verbose_name='批准日期')
    m_time = models.DateTimeField(auto_now=True, verbose_name='更新日期')

    def __str__(self):
        return '<%s>  %s' % (self.get_asset_type_display(), self.name)

    class Meta:
        verbose_name = '资产总表'
        verbose_name_plural = "资产总表"
        ordering = ['-c_time']


class Server(models.Model):
    """服务器设备"""

    sub_asset_type_choice = (
        (0, 'PC服务器'),
        (1, '刀片机'),
        (2, '小型机'),
    )

    created_by_choice = (
        ('auto', '自动添加'),
        ('manual', '手工录入'),
    )

    asset = models.OneToOneField('Asset', on_delete=models.CASCADE)  # 非常关键的一对一关联！asset被删除的时候一并删除server
    sub_asset_type = models.SmallIntegerField(choices=sub_asset_type_choice, default=0, verbose_name="服务器类型")
    created_by = models.CharField(choices=created_by_choice, max_length=32, default='auto', verbose_name="添加方式")
    hosted_on = models.ForeignKey('self', related_name='hosted_on_server',
                                  blank=True, null=True, verbose_name="宿主机", on_delete=models.CASCADE)  # 虚拟机专用字段
    model = models.CharField(max_length=128, null=True, blank=True, verbose_name='服务器型号')
    raid_type = models.CharField(max_length=512, blank=True, null=True, verbose_name='Raid类型')

    os_type = models.CharField('操作系统类型', max_length=64, blank=True, null=True)
    os_distribution = models.CharField('发行商', max_length=64, blank=True, null=True)
    os_release = models.CharField('操作系统版本', max_length=64, blank=True, null=True)

    def __str__(self):
        return '%s--%s--%s <sn:%s>' % (self.asset.name, self.get_sub_asset_type_display(), self.model, self.asset.sn)

    class Meta:
        verbose_name = '服务器'
        verbose_name_plural = "服务器"


class SecurityDevice(models.Model):
    """安全设备"""

    sub_asset_type_choice = (
        (0, '防火墙'),
        (1, '入侵检测设备'),
        (2, '互联网网关'),
        (4, '运维审计系统'),
    )

    asset = models.OneToOneField('Asset', on_delete=models.CASCADE)
    sub_asset_type = models.SmallIntegerField(choices=sub_asset_type_choice, default=0, verbose_name="安全设备类型")
    model = models.CharField(max_length=128, default='未知型号', verbose_name='安全设备型号')

    def __str__(self):
        return self.asset.name + "--" + self.get_sub_asset_type_display() + str(self.model) + " id:%s" % self.id

    class Meta:
        verbose_name = '安全设备'
        verbose_name_plural = "安全设备"


class StorageDevice(models.Model):
    """存储设备"""

    sub_asset_type_choice = (
        (0, '磁盘阵列'),
        (1, '网络存储器'),
        (2, '磁带库'),
        (4, '磁带机'),
    )

    asset = models.OneToOneField('Asset', on_delete=models.CASCADE)
    sub_asset_type = models.SmallIntegerField(choices=sub_asset_type_choice, default=0, verbose_name="存储设备类型")
    model = models.CharField(max_length=128, default='未知型号', verbose_name='存储设备型号')

    def __str__(self):
        return self.asset.name + "--" + self.get_sub_asset_type_display() + str(self.model) + " id:%s" % self.id

    class Meta:
        verbose_name = '存储设备'
        verbose_name_plural = "存储设备"


class NetworkDevice(models.Model):
    """网络设备"""

    sub_asset_type_choice = (
        (0, '路由器'),
        (1, '交换机'),
        (2, '负载均衡'),
        (4, 'VPN设备'),
    )

    asset = models.OneToOneField('Asset', on_delete=models.CASCADE)
    sub_asset_type = models.SmallIntegerField(choices=sub_asset_type_choice, default=0, verbose_name="网络设备类型")

    vlan_ip = models.GenericIPAddressField(blank=True, null=True, verbose_name="VLanIP")
    intranet_ip = models.GenericIPAddressField(blank=True, null=True, verbose_name="内网IP")

    model = models.CharField(max_length=128, default='未知型号',  verbose_name="网络设备型号")
    firmware = models.CharField(max_length=128, blank=True, null=True, verbose_name="设备固件版本")
    port_num = models.SmallIntegerField(null=True, blank=True, verbose_name="端口个数")
    device_detail = models.TextField(null=True, blank=True, verbose_name="详细配置")

    def __str__(self):
        return '%s--%s--%s <sn:%s>' % (self.asset.name, self.get_sub_asset_type_display(), self.model, self.asset.sn)

    class Meta:
        verbose_name = '网络设备'
        verbose_name_plural = "网络设备"


class Software(models.Model):
    """
    只保存付费购买的软件
    """
    sub_asset_type_choice = (
        (0, '操作系统'),
        (1, '办公\开发软件'),
        (2, '业务软件'),
    )

    sub_asset_type = models.SmallIntegerField(choices=sub_asset_type_choice, default=0, verbose_name="软件类型")
    license_num = models.IntegerField(default=1, verbose_name="授权数量")
    version = models.CharField(max_length=64, unique=True, help_text='例如: RedHat release 7 (Final)',
                               verbose_name='软件/系统版本')

    def __str__(self):
        return '%s--%s' % (self.get_sub_asset_type_display(), self.version)

    class Meta:
        verbose_name = '软件/系统'
        verbose_name_plural = "软件/系统"


class CPU(models.Model):
    """CPU组件"""

    asset = models.OneToOneField('Asset', on_delete=models.CASCADE)  # 设备上的cpu肯定都是一样的，所以不需要建立多个cpu数据，一条就可以，因此使用一对一。
    cpu_model = models.CharField('CPU型号', max_length=128, blank=True, null=True)
    cpu_count = models.PositiveSmallIntegerField('物理CPU个数', default=1)
    cpu_core_count = models.PositiveSmallIntegerField('CPU核数', default=1)

    def __str__(self):
        return self.asset.name + ":   " + self.cpu_model

    class Meta:
        verbose_name = 'CPU'
        verbose_name_plural = "CPU"


class RAM(models.Model):
    """内存组件"""

    asset = models.ForeignKey('Asset', on_delete=models.CASCADE)
    sn = models.CharField('SN号', max_length=128, blank=True, null=True)
    model = models.CharField('内存型号', max_length=128, blank=True, null=True)
    manufacturer = models.CharField('内存制造商', max_length=128, blank=True, null=True)
    slot = models.CharField('插槽', max_length=64)
    capacity = models.IntegerField('内存大小(GB)', blank=True, null=True)

    def __str__(self):
        return '%s: %s: %s: %s' % (self.asset.name, self.model, self.slot, self.capacity)

    class Meta:
        verbose_name = '内存'
        verbose_name_plural = "内存"
        unique_together = ('asset', 'slot')  # 同一资产下的内存，根据插槽的不同，必须唯一


class Disk(models.Model):
    """硬盘设备"""

    disk_interface_type_choice = (
        ('SATA', 'SATA'),
        ('SAS', 'SAS'),
        ('SCSI', 'SCSI'),
        ('SSD', 'SSD'),
        ('unknown', 'unknown'),
    )

    asset = models.ForeignKey('Asset', on_delete=models.CASCADE)
    sn = models.CharField('硬盘SN号', max_length=128)
    slot = models.CharField('所在插槽位', max_length=64, blank=True, null=True)
    model = models.CharField('磁盘型号', max_length=128, blank=True, null=True)
    manufacturer = models.CharField('磁盘制造商', max_length=128, blank=True, null=True)
    capacity = models.FloatField('磁盘容量(GB)', blank=True, null=True)
    interface_type = models.CharField('接口类型', max_length=16, choices=disk_interface_type_choice, default='unknown')

    def __str__(self):
        return '%s:  %s:  %s:  %sGB' % (self.asset.name, self.model, self.slot, self.capacity)

    class Meta:
        verbose_name = '硬盘'
        verbose_name_plural = "硬盘"
        unique_together = ('asset', 'sn')


class NIC(models.Model):
    """网卡组件"""

    asset = models.ForeignKey('Asset', on_delete=models.CASCADE)  # 注意要用外键
    name = models.CharField('网卡名称', max_length=64, blank=True, null=True)
    model = models.CharField('网卡型号', max_length=128)
    mac = models.CharField('MAC地址', max_length=64)  # 虚拟机有可能会出现同样的mac地址
    ip_address = models.GenericIPAddressField('IP地址', blank=True, null=True)
    net_mask = models.CharField('掩码', max_length=64, blank=True, null=True)
    bonding = models.CharField('绑定地址', max_length=64, blank=True, null=True)

    def __str__(self):
        return '%s:  %s:  %s' % (self.asset.name, self.model, self.mac)

    class Meta:
        verbose_name = '网卡'
        verbose_name_plural = "网卡"
        unique_together = ('asset', 'model', 'mac')  # 资产、型号和mac必须联合唯一。防止虚拟机中的特殊情况发生错误。


class IDC(models.Model):
    """机房"""
    name = models.CharField(max_length=64, unique=True, verbose_name="机房名称")
    memo = models.CharField(max_length=128, blank=True, null=True, verbose_name='备注')

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '机房'
        verbose_name_plural = "机房"


class Manufacturer(models.Model):
    """厂商"""

    name = models.CharField('厂商名称', max_length=64, unique=True)
    telephone = models.CharField('支持电话', max_length=30, blank=True, null=True)
    memo = models.CharField('备注', max_length=128, blank=True, null=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '厂商'
        verbose_name_plural = "厂商"


class BusinessUnit(models.Model):
    """业务线"""

    parent_unit = models.ForeignKey('self', blank=True, null=True, related_name='parent_level',
                                    on_delete=models.CASCADE)
    name = models.CharField('业务线名称', max_length=64, unique=True)
    memo = models.CharField('备注', max_length=64, blank=True, null=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '业务线'
        verbose_name_plural = "业务线"


class Contract(models.Model):
    """合同"""

    sn = models.CharField('合同号', max_length=128, unique=True)
    name = models.CharField('合同名称', max_length=64)
    memo = models.TextField('备注', blank=True, null=True)
    price = models.IntegerField('合同金额')
    detail = models.TextField('合同详细', blank=True, null=True)
    start_day = models.DateField('开始日期', blank=True, null=True)
    end_day = models.DateField('失效日期', blank=True, null=True)
    license_num = models.IntegerField('license数量', blank=True, null=True)
    c_day = models.DateField('创建日期', auto_now_add=True)
    m_day = models.DateField('修改日期', auto_now=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '合同'
        verbose_name_plural = "合同"


class Tag(models.Model):
    """标签"""
    name = models.CharField('标签名', max_length=32, unique=True)
    c_day = models.DateField('创建日期', auto_now_add=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '标签'
        verbose_name_plural = "标签"


class EventLog(models.Model):
    """
    日志.
    在关联对象被删除的时候，不能一并删除，需保留日志。
    因此，on_delete=models.SET_NULL
    """

    name = models.CharField('事件名称', max_length=128)
    event_type_choice = (
        (0, '其它'),
        (1, '硬件变更'),
        (2, '新增配件'),
        (3, '设备下线'),
        (4, '设备上线'),
        (5, '定期维护'),
        (6, '业务上线\更新\变更'),
    )
    asset = models.ForeignKey('Asset', blank=True, null=True, on_delete=models.SET_NULL)  # 当资产审批成功时有这项数据
    new_asset = models.ForeignKey('NewAssetApprovalZone', blank=True, null=True, on_delete=models.SET_NULL)  # 当资产审批失败时有这项数据
    event_type = models.SmallIntegerField('事件类型', choices=event_type_choice, default=4)
    component = models.CharField('事件子项', max_length=256, blank=True, null=True)
    detail = models.TextField('事件详情')
    date = models.DateTimeField('事件时间', auto_now_add=True)
    user = models.ForeignKey(User, blank=True, null=True, verbose_name='事件执行人', on_delete=models.SET_NULL)  # 自动更新资产数据时没有执行人
    memo = models.TextField('备注', blank=True, null=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = '事件纪录'
        verbose_name_plural = "事件纪录"


class NewAssetApprovalZone(models.Model):
    """新资产待审批区"""

    sn = models.CharField('资产SN号', max_length=128, unique=True)  # 此字段必填
    asset_type_choice = (
        ('server', '服务器'),
        ('networkdevice', '网络设备'),
        ('storagedevice', '存储设备'),
        ('securitydevice', '安全设备'),
        ('software', '软件资产'),
    )
    asset_type = models.CharField(choices=asset_type_choice, default='server', max_length=64, blank=True, null=True,
                                  verbose_name='资产类型')

    manufacturer = models.CharField(max_length=64, blank=True, null=True, verbose_name='生产厂商')
    model = models.CharField(max_length=128, blank=True, null=True, verbose_name='型号')
    ram_size = models.PositiveIntegerField(blank=True, null=True, verbose_name='内存大小')
    cpu_model = models.CharField(max_length=128, blank=True, null=True, verbose_name='CPU型号')
    cpu_count = models.PositiveSmallIntegerField('CPU物理数量', blank=True, null=True)
    cpu_core_count = models.PositiveSmallIntegerField('CPU核心数量', blank=True, null=True)
    os_distribution = models.CharField('发行商', max_length=64, blank=True, null=True)
    os_type = models.CharField('系统类型', max_length=64, blank=True, null=True)
    os_release = models.CharField('操作系统版本号', max_length=64, blank=True, null=True)

    data = models.TextField('资产数据')  # 此字段必填

    c_time = models.DateTimeField('汇报日期', auto_now_add=True)
    m_time = models.DateTimeField('数据更新日期', auto_now=True)
    approved = models.BooleanField('是否批准', default=False)

    def __str__(self):
        return self.sn

    class Meta:
        verbose_name = '新上线待批准资产'
        verbose_name_plural = "新上线待批准资产"
        ordering = ['-c_time']
```

# 3.数据收集客户端

CMDB最主要的管理对象是各种类型大量的服务器，其数据信息自然不可能通过手工收集，必须以客户端的方式，定时自动收集并报告给远程的服务器。

下面，让我们暂时忘掉Django，进入Python运维的世界......

## 一、客户端程序组织

编写客户端，不能一个py脚本包打天下，要有组织有目的，通常我们会采取下面的结构：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/119-1.png)

在Pycharm中，项目根目录下，创建一个Client目录，作为客户端的根目录。

在Client下，创建下面的包。注意是包，不是文件夹：

- bin：客户端启动脚本的所在目录
- conf：配置文件目录
- core：核心代码目录
- log：日志文件目录
- plugins：插件或工具目录

## 二、开发数据收集客户端

### 1.程序入口脚本

在bin目录中新建`main.py`文件，写入下面的代码：

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-

"""
完全可以把客户端信息收集脚本做成windows和linux两个不同的版本。
"""
import os
import sys

BASE_DIR = os.path.dirname(os.getcwd())
# 设置工作目录，使得包和模块能够正常导入
sys.path.append(BASE_DIR)

from core import handler

if __name__ == '__main__':

    handler.ArgvHandler(sys.argv)
```

**在pycharm中可能出现导入失败的红色波浪线警告信息，其实是可以导入的，请忽略它。**

- 通过os和sys模块的配合，将当前客户端所在目录设置为工作目录，如果不这么做，会无法导入其它模块；
- handler模块是核心代码模块，在core目录中，我们一会来实现它。
- 以后调用客户端就只需要执行`python main.py 参数`就可以了

**这里有个问题一定要强调一下，那就是Python解释器的调用，执行命令的方式和代码第一行`#!/usr/bin/env python`的指定方式一定不能冲突，要根据你的实际情况实际操作和修改代码！**

### 2.主功能模块

在core下，创建`handler.py`文件，写入下面的代码：

```
# -*- coding:utf-8 -*-

import json
import time
import urllib.parse
import urllib.request
from core import info_collection
from conf import settings


class ArgvHandler(object):

    def __init__(self, args):
        self.args = args
        self.parse_args()

    def parse_args(self):
        """
        分析参数，如果有参数指定的方法，则执行该功能，如果没有，打印帮助说明。
        :return:
        """
        if len(self.args) > 1 and hasattr(self, self.args[1]):
            func = getattr(self, self.args[1])
            func()
        else:
            self.help_msg()

    @staticmethod
    def help_msg():
        """
        帮助说明
        :return:
        """
        msg = '''
        参数名               功能

        collect_data        测试收集硬件信息的功能

        report_data         收集硬件信息并汇报
        '''
        print(msg)

    @staticmethod
    def collect_data():	
        """收集硬件信息,用于测试！"""
        info = info_collection.InfoCollection()
        asset_data = info.collect()
        print(asset_data)

    @staticmethod
    def report_data():
        """
        收集硬件信息，然后发送到服务器。
        :return:
        """
        # 收集信息
        info = info_collection.InfoCollection()
        asset_data = info.collect()
        # 将数据打包到一个字典内，并转换为json格式
        data = {"asset_data": json.dumps(asset_data)}
        # 根据settings中的配置，构造url
        url = "http://%s:%s%s" % (settings.Params['server'], settings.Params['port'], settings.Params['url'])
        print('正在将数据发送至： [%s]  ......' % url)
        try:
            # 使用Python内置的urllib.request库，发送post请求。
            # 需要先将数据进行封装，并转换成bytes类型
            data_encode = urllib.parse.urlencode(data).encode()
            response = urllib.request.urlopen(url=url, data=data_encode, timeout=settings.Params['request_timeout'])
            print("\033[31;1m发送完毕！\033[0m ")
            message = response.read().decode()
            print("返回结果：%s" % message)
        except Exception as e:
            message = '发送失败' + "   错误原因：  {}".format(e)
            print("\033[31;1m发送失败，错误原因： %s\033[0m" % e)
        # 记录发送日志
        with open(settings.PATH, 'ab') as f:  # 以byte的方式写入，防止出现编码错误
            log = '发送时间：%s \t 服务器地址：%s \t 返回结果：%s \n' % (time.strftime('%Y-%m-%d %H:%M:%S'), url, message)
            f.write(log.encode())
            print("日志记录成功！")
```

说明：

- handler模块中只有一个ArgvHandler类；
- 在main模块中也是实例化了一个ArgvHandler类的对象，并将调用参数传递进去；
- 首先，初始化方法会保存调用参数，然后执行parse_args()方法分析参数；
- 如果ArgvHandler类有参数指定的功能，则执行该功能，如果没有，打印帮助说明。
- 目前ArgvHandler类只有两个核心方法：`collect_data`和`report_data`；
- `collect_data`收集数据并打印到屏幕，用于测试；`report_data`方法才会将实际的数据发往服务器。
- 数据的收集由`info_collection.InfoCollection`类负责，一会再看；
- `report_data`方法会将收集到的数据打包到一个字典内，并转换为json格式；
- 然后通过settings中的配置，构造发送目的地url；
- 通过Python内置的urllib.parse对数据进行封装；
- 通过urllib.request将数据发送到目的url；
- 接收服务器返回的信息；
- 将成功或者失败的信息写入日志文件中。

以后，我们要测试数据收集，执行`python main.py collect_data`；要实际往服务器发送收集到的数据，则执行`python main.py report_data`。

### 3.配置文件

要将所有可能修改的数据、常量、配置等都尽量以配置文件的形式组织起来，尽量不要在代码中写死任何数据。

在conf中，新建`settings.py`文件，写入下面的代码：

```
# -*- coding:utf-8 -*-

import os

# 远端接收数据的服务器
Params = {
    "server": "192.168.0.100",
    "port": 8000,
    'url': '/assets/report/',
    'request_timeout': 30,
}

# 日志文件配置

PATH = os.path.join(os.path.dirname(os.getcwd()), 'log', 'cmdb.log')


# 更多配置，请都集中在此文件中
```

这里，配置了服务器地址、端口、发送的url、请求的超时时间，以及日志文件路径。请根据你的实际情况进行修改。

### 4.信息收集模块

在core中新建`info_collection.py`文件，写入下面的代码：

```
# -*- coding:utf-8 -*-

import sys
import platform


class InfoCollection(object):

    def collect(self):
        # 收集平台信息
        # 首先判断当前平台，根据平台的不同，执行不同的方法
        try:
            func = getattr(self, platform.system().lower())
            info_data = func()
            formatted_data = self.build_report_data(info_data)
            return formatted_data
        except AttributeError:
            sys.exit("不支持当前操作系统： [%s]! " % platform.system())

    @staticmethod
    def linux():
        from plugins.collect_linux_info import collect
        return collect()

    @staticmethod
    def windows():
        from plugins.collect_windows_info import Win32Info
        return Win32Info().collect()

    @staticmethod
    def build_report_data(data):
        # 留下一个接口，方便以后增加功能或者过滤数据
        pass
        return data
```

该模块的作用很简单：

- 首先通过Python内置的platform模块获取执行main脚本的操作系统类别，通常是windows和Linux，暂时不支持其它操作系统；
- 根据操作系统的不同，反射获取相应的信息收集方法，并执行；
- 如果是客户端不支持的操作系统，比如苹果系统，则提示并退出客户端。

因为windows和Linux两大操作系统的巨大平台差异，我们必须写两个收集信息的脚本。

到目前为止，我们的客户端结构如下图所示：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/119-2.png)

# 4.收集Windows数据

## 一、windows中收集硬件信息

为了收集运行Windows操作系统的服务器的硬件信息，我们需要编写一个专门的脚本。

在Pycharm的Client目录下的plugins包中，新建一个`collect_windows_info.py`文件，写入下面的代码：

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-

import platform
import win32com
import wmi

"""
本模块基于windows操作系统，依赖wmi和win32com库，需要提前使用pip进行安装，
pip install wmi
pip install pypiwin32
或者下载安装包手动安装。
"""


class Win32Info(object):

    def __init__(self):
        # 固定用法，更多内容请参考模块说明
        self.wmi_obj = wmi.WMI()
        self.wmi_service_obj = win32com.client.Dispatch("WbemScripting.SWbemLocator")
        self.wmi_service_connector = self.wmi_service_obj.ConnectServer(".", "root\cimv2")

    def collect(self):
        data = {
            'os_type': platform.system(),
            'os_release': "%s %s  %s " % (platform.release(), platform.architecture()[0], platform.version()),
            'os_distribution': 'Microsoft',
            'asset_type': 'server'
        }

        # 分别获取各种硬件信息
        data.update(self.get_cpu_info())
        data.update(self.get_ram_info())
        data.update(self.get_motherboard_info())
        data.update(self.get_disk_info())
        data.update(self.get_nic_info())
        # 最后返回一个数据字典
        return data

    def get_cpu_info(self):
        """
        获取CPU的相关数据，这里只采集了三个数据，实际有更多，请自行选择需要的数据
        :return:
        """
        data = {}
        cpu_lists = self.wmi_obj.Win32_Processor()
        cpu_core_count = 0
        for cpu in cpu_lists:
            cpu_core_count += cpu.NumberOfCores

        cpu_model = cpu_lists[0].Name   # CPU型号（所有的CPU型号都是一样的）
        data["cpu_count"] = len(cpu_lists)      # CPU个数
        data["cpu_model"] = cpu_model
        data["cpu_core_count"] = cpu_core_count  # CPU总的核数

        return data

    def get_ram_info(self):
        """
        收集内存信息
        :return:
        """
        data = []
        # 这个模块用SQL语言获取数据
        ram_collections = self.wmi_service_connector.ExecQuery("Select * from Win32_PhysicalMemory")
        for ram in ram_collections:    # 主机中存在很多根内存，要循环所有的内存数据
            ram_size = int(int(ram.Capacity) / (1024**3))  # 转换内存单位为GB
            item_data = {
                "slot": ram.DeviceLocator.strip(),
                "capacity": ram_size,
                "model": ram.Caption,
                "manufacturer": ram.Manufacturer,
                "sn": ram. SerialNumber,
            }
            data.append(item_data)  # 将每条内存的信息，添加到一个列表里

        return {"ram": data}    # 再对data列表封装一层，返回一个字典，方便上级方法的调用

    def get_motherboard_info(self):
        """
        获取主板信息
        :return:
        """
        computer_info = self.wmi_obj.Win32_ComputerSystem()[0]
        system_info = self.wmi_obj.Win32_OperatingSystem()[0]
        data = {}
        data['manufacturer'] = computer_info.Manufacturer
        data['model'] = computer_info.Model
        data['wake_up_type'] = computer_info.WakeUpType
        data['sn'] = system_info.SerialNumber
        return data

    def get_disk_info(self):
        """
        硬盘信息
        :return:
        """
        data = []
        for disk in self.wmi_obj.Win32_DiskDrive():     # 每块硬盘都要获取相应信息
            disk_data = {}
            interface_choices = ["SAS", "SCSI", "SATA", "SSD"]
            for interface in interface_choices:
                if interface in disk.Model:
                    disk_data['interface_type'] = interface
                    break
            else:
                disk_data['interface_type'] = 'unknown'

            disk_data['slot'] = disk.Index
            disk_data['sn'] = disk.SerialNumber
            disk_data['model'] = disk.Model
            disk_data['manufacturer'] = disk.Manufacturer
            disk_data['capacity'] = int(int(disk.Size) / (1024**3))
            data.append(disk_data)

        return {'physical_disk_driver': data}

    def get_nic_info(self):
        """
        网卡信息
        :return:
        """
        data = []
        for nic in self.wmi_obj.Win32_NetworkAdapterConfiguration():
            if nic.MACAddress is not None:
                nic_data = {}
                nic_data['mac'] = nic.MACAddress
                nic_data['model'] = nic.Caption
                nic_data['name'] = nic.Index
                if nic.IPAddress is not None:
                    nic_data['ip_address'] = nic.IPAddress[0]
                    nic_data['net_mask'] = nic.IPSubnet
                else:
                    nic_data['ip_address'] = ''
                    nic_data['net_mask'] = ''
                data.append(nic_data)

        return {'nic': data}


if __name__ == "__main__":
    # 测试代码
    data = Win32Info().collect()
    for key in data:
        print(key, ":", data[key])
```

windows中没有方便的命令可以获取硬件信息，但pyth是有额外的模块可以帮助我们实现目的，这个模块叫做wmi。可以使用`pip install wmi`的方式安装，当前版本是1.4.9。但是wmi安装后，`import wmi`依然会出错，因为它依赖一个叫做win32com的模块。

我们依然可以通过`pip install pypiwin32`来安装win32com模块，但是不幸的是，据反映，有些机器无法通过pip成功安装。所以，这里我在github中提供了一个手动安装包`pywin32-220.win-amd64-py3.5(配合wmi模块，获取主机信息的模块).exe`，方便大家。(如果版本不兼容，也可以自行在网上搜索。)

依赖包的问题解决后，我们来看一下`sys_info.py`脚本的代码。

- 类Win32Info封装了具体数据收集逻辑
- 其中对Win32模块的调用方式是固定的，有兴趣的可以自行学习这个模块的官方文档
- 核心在于collect方法，它汇总了其它方法收集的信息！
- collect方法首先通过platform模块获取平台的信息，然后保存到一个data字典中。
- 分别调用其它方法，获取CPU、RAM、主板、硬盘和网卡的信息。
- 每一类数据收集完成后都会作为一个新的字典，update到开始的data字典中，最终形成完整的信息字典。
- 最后在脚本末尾有一个测试入口。

整个脚本的代码其实很简单，我们只要将Win32的方法调用当作透明的空气，剩下的不过就是将获得的数据，按照我们指定的格式打包成一个数据字典。

## 强调：数据字典的格式和键值是非常重要的，是预设的，不可以随意改变！

## 二、信息收集测试

下面，单独运行一下该脚本（注意不是运行CMDB项目），查看一下生成的数据。为了显示更直观，可以通过在线json校验工具格式化一下。

```
{
os_type': 'Windows',
'os_release': '764bit6.1.7601',
'os_distribution': 'Microsoft',
'asset_type': 'server',
'cpu_count': 1,
'cpu_model': 'Intel(R)Core(TM)i5-2300CPU@2.80GHz',
'cpu_core_count': 4,
'ram': [
    {
        'slot': 'A0',
        'capacity': 4,
        'model': 'PhysicalMemory',
        'manufacturer': '',
        'sn': ''
    },
    {
        'slot': 'A1',
        'capacity': 4,
        'model': 'PhysicalMemory',
        'manufacturer': '',
        'sn': ''
    }
],
'manufacturer': 'GigabyteTechnologyCo.,
Ltd.',
'model': 'P67X-UD3R-B3',
'wake_up_type': 6,
'sn': '00426-OEM-8992662-12006',
'physical_disk_driver': [
    {
        'iface_type': 'unknown',
        'slot': 0,
        'sn': '3830414130423230233235362020202020202020',
        'model': 'KINGSTONSV100S264GATADevice',
        'manufacturer': '(标准磁盘驱动器)',
        'capacity': 59
    },
    {
        'iface_type': 'unknown',
        'slot': 1,
        'sn': '2020202020202020201020205935334445414235',
        'model': 'ST2000DL003-9VT166ATADevice',
        'manufacturer': '(标准磁盘驱动器)',
        'capacity': 1863
    }
],
'nic': [
    {
        'mac': '24: CF: 92: FF: 48: 34',
        'model': '[
            00000011
        ]RealtekRTL8192CUWirelessLAN802.11nUSB2.0NetworkAdapter',
        'name': 11,
        'ip_address': '192.168.1.100',
        'net_mask': ('255.255.255.0',
        '64')
    },
    {
        'mac': '0A: 00: 27: 00: 00: 00',
        'model': '[
            00000013
        ]VirtualBoxHost-OnlyEthernetAdapter',
        'name': 13,
        'ip_address': '192.168.56.1',
        'net_mask': ('255.255.255.0',
        '64')
    },
    {
        'mac': '24: CF: 92: FF: 48: 34',
        'model': '[
            00000017
        ]MicrosoftVirtualWiFiMiniportAdapter',
        'name': 17,
        'ip_address': '',
        'net_mask': ''
    },
    {
        'mac': '10: 19: 86: 00: 12: 98',
        'model': '[
            00000018
        ]Bluetooth设备(个人区域网)',
        'name': 18,
        'ip_address': '',
        'net_mask': ''
    }
]
}
```

上面的信息包含操作系统、主板、CPU、内存、硬盘、网卡等各种信息。可以看到我有两条内存，两块硬盘，以及4块网卡。内存没有获取到sn，但slot是不一样的。硬盘有sn，但接口未知。四块网卡有出现mac地址相同的情况，因为那是虚拟机的。

你的数据和我的肯定不一样，但是数据格式和键值必须一样，我们后面自动分析数据、填充数据，都依靠这个固定格式的数据字典。

通过测试我们发现数据可以收集到了，那么再测试一下数据能否正常发送到服务器。

## 三、数据发送测试

由于后面我们还会采用Linux虚拟机作为测试用例，所以Django服务器就不能再运行在127.0.0.1:8000上面了。

查看一下当前机器的IP，发现是192.168.0.100，修改项目的settings.py文件，将ALLOWED_HOSTS修改如下：

```
ALLOWED_HOSTS = ["*"]
```

这表示接收所有同一局域网内的网络访问。

然后以0.0.0.0:8000的参数启动CMDB项目服务器，表示对局域网内所有ip开放服务。

回到客户端，进入Client/bin目录，运行`python main.py report_data`，可以看到如下结果：

```
(venv) D:\work\2019\for_test\CMDB\Client\bin>python main.py report_data
正在将数据发送至： [http://192.168.0.100:8000/assets/report/]  ......
?[31;1m发送失败，错误原因： HTTP Error 404: Not Found?[0m
日志记录成功！
```

这是一个404错误，表示服务器地址没找到，这是因为我们还没有为Django编写接收数据的视图和路由。

这时，打开log目录下的日志文件，内容如下：

```
发送时间：2019-04-12 10:13:52     服务器地址：http://192.168.0.100:8000/assets/report/      返回结果：发送失败   错误原因：  HTTP Error 404: Not Found 
```

## 四、接收数据

进入`cmdb/urls.py`文件中，编写一个二级路由，将所有assets相关的数据都转发到`assets.urls`中，如下所示：

```
from django.contrib import admin
from django.urls import path
from django.urls import include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('assets/', include('assets.urls')),
]
```

然后，我们在assets中新建一个urls.py文件，写入下面的代码：

```
from django.urls import path
from assets import views

app_name = 'assets'

urlpatterns = [
    path('report/', views.report, name='report'),
]
```

这样，我们的路由就写好了。

转过头，我们进入assets/views.py文件，写一个简单的视图。

```
from django.shortcuts import render
from django.shortcuts import HttpResponse

# Create your views here.

def report(request):    
    if request.method == "POST":
        asset_data = request.POST.get('asset_data')
        print(asset_data)
        return HttpResponse("成功收到数据！")
```

代码很简单，接收POST过来的数据，打印出来，然后返回成功的消息。

重新启动服务器，然后去Client客户端运行`python main.py report_data`，可以看到：

```
(venv) D:\work\2019\for_test\CMDB\Client\bin>python main.py report_data
正在将数据发送至： [http://192.168.0.100:8000/assets/report/]  ......
?[31;1m发送失败，错误原因： HTTP Error 403: Forbidden?[0m
日志记录成功！
```

403就是拒绝服务的错误了。

原因在于我们模拟浏览器发送了一个POST请求给Django，但是请求中没有携带Django需要的csrf安全令牌，所以拒绝了请求。

为了解决这个问题，我们需要在这个report视图上忽略csrf验证，可以通过Django的`@csrf_exempt`装饰器。修改代码如下：

```
from django.shortcuts import render
from django.shortcuts import HttpResponse
from django.views.decorators.csrf import csrf_exempt

# Create your views here.

@csrf_exempt
def report(request):
    if request.method == "POST":
        asset_data = request.POST.get('asset_data')
        print(asset_data)
        return HttpResponse("成功收到数据！")
```

重启CMDB服务器，再次从客户端报告数据，可以看到返回结果如下：

```
(venv) D:\work\2019\for_test\CMDB\Client\bin>python main.py report_data
正在将数据发送至： [http://192.168.0.100:8000/assets/report/]  ......
?[31;1m发送完毕！?[0m
返回结果：成功收到数据！
日志记录成功！
```

这表明数据发送成功了。

再看Pycharm中，也打印出了接收到的数据，一切OK！

CSRF验证的问题解决了，但是又带来新的安全问题。我们可以通过增加用户名、密码，或者md5验证或者自定义安全令牌的方式解决，这部分内容需要大家自己添加。

Windows下的客户端已经验证完毕了，然后我们就可以通过各种方式让脚本定时运行、收集和报告数据，一切都自动化。

# 5.Linux下收集数据

Linux下收集数据就有很多命令和工具了，比Windows方便多了。

但是要在Python的进程中运行操作系统级别的命令，通常需要使用subprocess模块。这个模块的具体用法，请查看Python教程中相关部分的内容。

在Client/plugins下创建一个`collect_linux_info.py`文件，写入下面的代码：

```
#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import subprocess


def collect():
    filter_keys = ['Manufacturer', 'Serial Number', 'Product Name', 'UUID', 'Wake-up Type']
    raw_data = {}

    for key in filter_keys:
        try:
            res = subprocess.Popen("sudo dmidecode -t system|grep '%s'" % key,
                                   stdout=subprocess.PIPE, shell=True)
            result = res.stdout.read().decode()
            data_list = result.split(':')

            if len(data_list) > 1:
                raw_data[key] = data_list[1].strip()
            else:
                raw_data[key] = ''
        except Exception as e:
            print(e)
            raw_data[key] = ''

    data = dict()
    data['asset_type'] = 'server'
    data['manufacturer'] = raw_data['Manufacturer']
    data['sn'] = raw_data['Serial Number']
    data['model'] = raw_data['Product Name']
    data['uuid'] = raw_data['UUID']
    data['wake_up_type'] = raw_data['Wake-up Type']

    data.update(get_os_info())
    data.update(get_cpu_info())
    data.update(get_ram_info())
    data.update(get_nic_info())
    data.update(get_disk_info())
    return data


def get_os_info():
    """
    获取操作系统信息
    :return:
    """
    distributor = subprocess.Popen("lsb_release -a|grep 'Distributor ID'",
                                   stdout=subprocess.PIPE, shell=True)
    distributor = distributor.stdout.read().decode().split(":")

    release = subprocess.Popen("lsb_release -a|grep 'Description'",
                               stdout=subprocess.PIPE, shell=True)

    release = release.stdout.read().decode().split(":")
    data_dic = {
        "os_distribution": distributor[1].strip() if len(distributor) > 1 else "",
        "os_release": release[1].strip() if len(release) > 1 else "",
        "os_type": "Linux",
    }
    return data_dic


def get_cpu_info():
    """
    获取cpu信息
    :return:
    """
    raw_cmd = 'cat /proc/cpuinfo'

    raw_data = {
        'cpu_model': "%s |grep 'model name' |head -1 " % raw_cmd,
        'cpu_count':  "%s |grep  'processor'|wc -l " % raw_cmd,
        'cpu_core_count': "%s |grep 'cpu cores' |awk -F: '{SUM +=$2} END {print SUM}'" % raw_cmd,
    }

    for key, cmd in raw_data.items():
        try:
            result = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
            raw_data[key] = result.stdout.read().decode().strip()
        except ValueError as e:
            print(e)
            raw_data[key] = ""

    data = {
        "cpu_count": raw_data["cpu_count"],
        "cpu_core_count": raw_data["cpu_core_count"]
        }

    cpu_model = raw_data["cpu_model"].split(":")

    if len(cpu_model) > 1:
        data["cpu_model"] = cpu_model[1].strip()
    else:
        data["cpu_model"] = ''

    return data


def get_ram_info():
    """
    获取内存信息
    :return:
    """
    raw_data = subprocess.Popen("sudo dmidecode -t memory", stdout=subprocess.PIPE, shell=True)
    raw_list = raw_data.stdout.read().decode().split("\n")
    raw_ram_list = []
    item_list = []
    for line in raw_list:
        if line.startswith("Memory Device"):
            raw_ram_list.append(item_list)
            item_list = []
        else:
            item_list.append(line.strip())

    ram_list = []
    for item in raw_ram_list:
        item_ram_size = 0
        ram_item_to_dic = {}
        for i in item:
            data = i.split(":")
            if len(data) == 2:
                key, v = data
                if key == 'Size':
                    if v.strip() != "No Module Installed":
                        ram_item_to_dic['capacity'] = v.split()[0].strip()
                        item_ram_size = round(v.split()[0])
                    else:
                        ram_item_to_dic['capacity'] = 0

                if key == 'Type':
                    ram_item_to_dic['model'] = v.strip()
                if key == 'Manufacturer':
                    ram_item_to_dic['manufacturer'] = v.strip()
                if key == 'Serial Number':
                    ram_item_to_dic['sn'] = v.strip()
                if key == 'Asset Tag':
                    ram_item_to_dic['asset_tag'] = v.strip()
                if key == 'Locator':
                    ram_item_to_dic['slot'] = v.strip()

        if item_ram_size == 0:
            pass
        else:
            ram_list.append(ram_item_to_dic)

    raw_total_size = subprocess.Popen("cat /proc/meminfo|grep MemTotal ", stdout=subprocess.PIPE, shell=True)
    raw_total_size = raw_total_size.stdout.read().decode().split(":")
    ram_data = {'ram': ram_list}
    if len(raw_total_size) == 2:
        total_gb_size = int(raw_total_size[1].split()[0]) / 1024**2
        ram_data['ram_size'] = total_gb_size

    return ram_data


def get_nic_info():
    """
    获取网卡信息
    :return:
    """
    raw_data = subprocess.Popen("ifconfig -a", stdout=subprocess.PIPE, shell=True)

    raw_data = raw_data.stdout.read().decode().split("\n")

    nic_dic = dict()
    next_ip_line = False
    last_mac_addr = None

    for line in raw_data:
        if next_ip_line:
            next_ip_line = False
            nic_name = last_mac_addr.split()[0]
            mac_addr = last_mac_addr.split("HWaddr")[1].strip()
            raw_ip_addr = line.split("inet addr:")
            raw_bcast = line.split("Bcast:")
            raw_netmask = line.split("Mask:")
            if len(raw_ip_addr) > 1:
                ip_addr = raw_ip_addr[1].split()[0]
                network = raw_bcast[1].split()[0]
                netmask = raw_netmask[1].split()[0]
            else:
                ip_addr = None
                network = None
                netmask = None
            if mac_addr not in nic_dic:
                nic_dic[mac_addr] = {'name': nic_name,
                                     'mac': mac_addr,
                                     'net_mask': netmask,
                                     'network': network,
                                     'bonding': 0,
                                     'model': 'unknown',
                                     'ip_address': ip_addr,
                                     }
            else:
                if '%s_bonding_addr' % (mac_addr,) not in nic_dic:
                    random_mac_addr = '%s_bonding_addr' % (mac_addr,)
                else:
                    random_mac_addr = '%s_bonding_addr2' % (mac_addr,)

                nic_dic[random_mac_addr] = {'name': nic_name,
                                            'mac': random_mac_addr,
                                            'net_mask': netmask,
                                            'network': network,
                                            'bonding': 1,
                                            'model': 'unknown',
                                            'ip_address': ip_addr,
                                            }

        if "HWaddr" in line:
            next_ip_line = True
            last_mac_addr = line
    nic_list = []
    for k, v in nic_dic.items():
        nic_list.append(v)

    return {'nic': nic_list}


def get_disk_info():
    """
    获取存储信息。
    本脚本只针对ubuntu中使用sda，且只有一块硬盘的情况。
    具体查看硬盘信息的命令，请根据实际情况，实际调整。
    如果需要查看Raid信息，可以尝试MegaCli工具。
    :return:
    """
    raw_data = subprocess.Popen("sudo hdparm -i /dev/sda | grep Model", stdout=subprocess.PIPE, shell=True)
    raw_data = raw_data.stdout.read().decode()
    data_list = raw_data.split(",")
    model = data_list[0].split("=")[1]
    sn = data_list[2].split("=")[1].strip()

    size_data = subprocess.Popen("sudo fdisk -l /dev/sda | grep Disk|head -1", stdout=subprocess.PIPE, shell=True)
    size_data = size_data.stdout.read().decode()
    size = size_data.split(":")[1].strip().split(" ")[0]

    result = {'physical_disk_driver': []}
    disk_dict = dict()
    disk_dict["model"] = model
    disk_dict["size"] = size
    disk_dict["sn"] = sn
    result['physical_disk_driver'].append(disk_dict)

    return result


if __name__ == "__main__":
    # 收集信息功能测试
    data = collect()
    print(data)
```

代码整体没有什么难点，无非就是使用subprocess.Popen()方法执行Linux的命令，然后获取返回值，并以规定的格式打包到data字典里。

需要说明的问题有：

- 当Linux中存在好几个Python解释器版本时，要注意调用方式，前面已经强调过了；
- 不同的Linux发行版，有些命令可能没有，需要额外安装；
- 所使用的查看硬件信息的命令并不一定必须和这里的一样，只要能获得数据就行；
- 有一些命令在ubuntu中涉及sudo的问题，需要特别对待；
- 最终数据字典的格式一定要正确；
- 可以在Linux下配置cronb或其它定时服务，设置定期的数据收集、报告任务。

------

下面在Linux虚拟机上，测试一下客户端。

将Pycharm中的Client客户端文件夹，拷贝到Linux虚拟机中，这里是ubuntu16.04.

进入bin目录，运行“python3 main.py report_data”，一切顺利的话应该能得到如下的反馈：

```
正在将数据发送至： [http://192.168.1.100:8000/assets/report/]  ......
发送完毕！ 
返回结果：成功收到数据！
日志记录成功！
```

然后，在Pycharm中，也可以看到接收的数据：

```
{
    "asset_type": "server",
    "manufacturer": "innotek GmbH",
    "sn": "0",
    "model": "VirtualBox",
    "uuid": "E8DE611C-4279-495C-9B58-502B6FCED076",
    "wake_up_type": "Power Switch",
    "os_distribution": "Ubuntu",
    "os_release": "Ubuntu 16.04.3 LTS",
    "os_type": "Linux",
    "cpu_count": "2",
    "cpu_core_count": "4",
    "cpu_model": "Intel(R) Core(TM) i5-2300 CPU @ 2.80GHz",
    "ram": [],
    "ram_size": 3.858997344970703,
    "nic": [],
    "physical_disk_driver": [
        {
            "model": "VBOX HARDDISK",
            "size": "50",
            "sn": "VBeee1ba73-09085302"
        }
    ]
}
```

可以看到，由于是virtualbox虚拟机的原因，sn为0，内存和网卡信息一条都没有，数据有点可怜，vmware的虚拟机可能好点。如果你对Linux比较熟悉，还可以自己尝试获取更多的数据，但是要注意虚拟机的sn可能重复，要防止冲突。

# 6.新资产待审批区

## 一、启用admin

前面，我们已经完成了数据收集客户端的编写和测试，下面我们就可以在admin中展示和管理资产数据了。

首先，通过`python manage.py createsuperuser`创建一个管理员账户。

然后，进入`/assets/admin.py`文件，写入下面的代码：

```
from django.contrib import admin
# Register your models here.
from assets import models


class NewAssetAdmin(admin.ModelAdmin):
    list_display = ['asset_type', 'sn', 'model', 'manufacturer', 'c_time', 'm_time']
    list_filter = ['asset_type', 'manufacturer', 'c_time']
    search_fields = ('sn',)


class AssetAdmin(admin.ModelAdmin):
    list_display = ['asset_type', 'name', 'status', 'approved_by', 'c_time', "m_time"]


admin.site.register(models.Asset, AssetAdmin)
admin.site.register(models.Server)
admin.site.register(models.StorageDevice)
admin.site.register(models.SecurityDevice)
admin.site.register(models.BusinessUnit)
admin.site.register(models.Contract)
admin.site.register(models.CPU)
admin.site.register(models.Disk)
admin.site.register(models.EventLog)
admin.site.register(models.IDC)
admin.site.register(models.Manufacturer)
admin.site.register(models.NetworkDevice)
admin.site.register(models.NIC)
admin.site.register(models.RAM)
admin.site.register(models.Software)
admin.site.register(models.Tag)
admin.site.register(models.NewAssetApprovalZone, NewAssetAdmin)
```

利用刚才创建的管理员用户，登录admin站点：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/122-1.png)

这里略微对admin界面做了些简单地配置，但目前还没有数据。

## 二、创建新资产

前面我们只是在Pycharm中获取并打印数据，并没有将数据保存到数据库里。下面我们来实现这一功能。

修改/assets/views.py文件，代码如下：

```
from django.shortcuts import render
from django.shortcuts import HttpResponse
from django.views.decorators.csrf import csrf_exempt
import json
from assets import models
from assets import asset_handler
# Create your views here.

@csrf_exempt
def report(request):
    """
    通过csrf_exempt装饰器，跳过Django的csrf安全机制，让post的数据能被接收，但这又会带来新的安全问题。
    可以在客户端，使用自定义的认证token，进行身份验证。这部分工作，请根据实际情况，自己进行。
    :param request:
    :return:
    """
    if request.method == "POST":
        asset_data = request.POST.get('asset_data')
        data = json.loads(asset_data)
        # 各种数据检查，请自行添加和完善！
        if not data:
            return HttpResponse("没有数据！")
        if not issubclass(dict, type(data)):
            return HttpResponse("数据必须为字典格式！")
        # 是否携带了关键的sn号
        sn = data.get('sn', None)
        if sn:
            # 进入审批流程
            # 首先判断是否在上线资产中存在该sn
            asset_obj = models.Asset.objects.filter(sn=sn)
            if asset_obj:
                # 进入已上线资产的数据更新流程
                pass
                return HttpResponse("资产数据已经更新！")
            else:   # 如果已上线资产中没有，那么说明是未批准资产，进入新资产待审批区，更新或者创建资产。
                obj = asset_handler.NewAsset(request, data)
                response = obj.add_to_new_assets_zone()
                return HttpResponse(response)
        else:
            return HttpResponse("没有资产sn序列号，请检查数据！")
    return HttpResponse('200 ok')
```

report视图的逻辑是这样的：

- **sn是标识一个资产的唯一字段，必须携带，不能重复！**
- 从POST中获取发送过来的数据；
- 使用json转换数据类型；
- 进行各种数据检查（比如身份验证等等，请自行完善）；
- 判断数据是否为空，空则返回错误信息，结束视图；
- 判断data的类型是否字典类型，否则返回错误信息；
- 之所以要对data的类型进行判断是因为后面要大量的使用字典的get方法和中括号操作；
- 如果没有携带sn号，返回错误信息；

当前面都没问题时，进入下面的流程：

- 首先，利用sn值尝试在已上线的资产进行查找，如果有，则进入已上线资产的更新流程，具体实现，这里暂且跳过;
- 如果没有，说明这是个新资产，需要添加到新资产区；
- 这里又分两种情况，一种是彻底的新资产，那没得说，需要新增；另一种是新资产区已经有了，但是审批员还没来得及审批，资产数据的后续报告就已经到达了，那么需要更新数据。
- 创建一个`asset_handler.NewAsset()`对象，然后调用它的`obj.add_to_new_assets_zone()`方法，进行数据保存，并接收返回结果；
- asset_handler是下面我们要新建的资产处理模块，NewAsset是其中的一个类。

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/122-2.png)

为了不让`views.py`文件过于庞大，通常会建立新的py文件，专门处理一些核心业务。

在assets下新建`asset_handler.py`文件，并写入下面的代码：

```
import json
from assets import models


class NewAsset(object):
    def __init__(self, request, data):
        self.request = request
        self.data = data

    def add_to_new_assets_zone(self):
        defaults = {
            'data': json.dumps(self.data),
            'asset_type': self.data.get('asset_type'),
            'manufacturer': self.data.get('manufacturer'),
            'model': self.data.get('model'),
            'ram_size': self.data.get('ram_size'),
            'cpu_model': self.data.get('cpu_model'),
            'cpu_count': self.data.get('cpu_count'),
            'cpu_core_count': self.data.get('cpu_core_count'),
            'os_distribution': self.data.get('os_distribution'),
            'os_release': self.data.get('os_release'),
            'os_type': self.data.get('os_type'),

        }
        models.NewAssetApprovalZone.objects.update_or_create(sn=self.data['sn'], defaults=defaults)

        return '资产已经加入或更新待审批区！'
```

NewAsset类接收两个参数，request和data，分别封装了请求和资产数据，它的唯一方法`obj.add_to_new_assets_zone()`中，首先构造了一个defaults字典，分别将资产数据包的各种数据打包进去，然后利用Django中特别好用的`update_or_create()`方法，进行数据保存！

`update_or_create()`方法的机制：如果数据库内没有该数据，那么新增，如果有，则更新，这就大大减少了我们的代码量，不用写两个方法。该方法的参数必须为一些用于查询的指定字段（这里是sn），以及需要新增或者更新的defaults字典。而其返回值，则是一个查询对象和是否新建对象布尔值的二元元组。

## 三、测试数据

重启CMDB，在Client中使用`python main.py report_data`，发送一个资产数据给CMDB服务器，结果如下：

```
(venv) D:\work\2019\for_test\CMDB\Client\bin>python main.py report_data
正在将数据发送至： [http://192.168.0.100:8000/assets/report/]  ......
?[31;1m发送完毕！?[0m
返回结果：资产已经加入或更新待审批区！
日志记录成功！
```

再进入admin后台，查看新资产待审批区，可以看到资产已经成功进入待审批区：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/122-3.png)

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/122-4.png)

这里我们显示了资产的汇报和更新日期，过几分钟后，重新汇报该资产数据，然后刷新admin中的页面，可以看到，待审批区的资产数据也一并被更新了。

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/122-5.png)

# 7.审批新资产

## 一、自定义admin的actions

需要有专门的审批员来审批新资产，对资产的合法性、健全性、可用性等更多方面进行审核，如果没有问题，那么就批准上线。

批准上线这一操作是通过admin的自定义actions来实现的。

Django的admin默认有一个delete操作的action，所有在admin中的模型都有这个action，更多的就需要我们自己编写了。

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/123-1.png)

修改`/assets/admin.py`的代码，新的代码如下：

```
from django.contrib import admin
# Register your models here.
from assets import models
from assets import asset_handler


class NewAssetAdmin(admin.ModelAdmin):
    list_display = ['asset_type', 'sn', 'model', 'manufacturer', 'c_time', 'm_time']
    list_filter = ['asset_type', 'manufacturer', 'c_time']
    search_fields = ('sn',)

    actions = ['approve_selected_new_assets']

    def approve_selected_new_assets(self, request, queryset):
        # 获得被打钩的checkbox对应的资产
        selected = request.POST.getlist(admin.ACTION_CHECKBOX_NAME)
        success_upline_number = 0
        for asset_id in selected:
            obj = asset_handler.ApproveAsset(request, asset_id)
            ret = obj.asset_upline()
            if ret:
                success_upline_number += 1
        # 顶部绿色提示信息
        self.message_user(request, "成功批准  %s  条新资产上线！" % success_upline_number)
    approve_selected_new_assets.short_description = "批准选择的新资产"

class AssetAdmin(admin.ModelAdmin):
    list_display = ['asset_type', 'name', 'status', 'approved_by', 'c_time', "m_time"]


admin.site.register(models.Asset, AssetAdmin)
admin.site.register(models.Server)
admin.site.register(models.StorageDevice)
admin.site.register(models.SecurityDevice)
admin.site.register(models.BusinessUnit)
admin.site.register(models.Contract)
admin.site.register(models.CPU)
admin.site.register(models.Disk)
admin.site.register(models.EventLog)
admin.site.register(models.IDC)
admin.site.register(models.Manufacturer)
admin.site.register(models.NetworkDevice)
admin.site.register(models.NIC)
admin.site.register(models.RAM)
admin.site.register(models.Software)
admin.site.register(models.Tag)
admin.site.register(models.NewAssetApprovalZone, NewAssetAdmin)
```

说明：

- 通过`actions = ['approve_selected_new_assets']`定义当前模型的新acitons列表；
- `approve_selected_new_assets()`方法包含具体的动作逻辑；
- 自定义的action接收至少三个参数，第一个是self，第二个是request即请求，第三个是被选中的数据对象集合queryset。
- 首先通过`request.POST.getlist()`方法获取被打钩的checkbox对应的资产；
- 可能同时有多个资产被选择，所以这是个批量操作，需要进行循环；
- selected是一个包含了被选中资产的id值的列表；
- 对于每一个资产，创建一个`asset_handler.ApproveAsset()`的实例，然后调用实例的`asset_upline()`方法，并获取返回值。如果返回值为True，说明该资产被成功批准，那么`success_upline_number`变量+1，保存成功批准的资产数；
- 最后，在admin中给与提示信息。
- `approve_selected_new_assets.short_description = "批准选择的新资产"`用于在admin界面中为action提供中文显示。你可以尝试去掉这条，看看效果。

重新启动CMDB，进入admin的待审批资产区，查看上方的acitons动作条，如下所示：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/123-2.png)

## 二、创建测试用例

由于没有真实的服务器供测试，这里需要手动创建一些虚假的服务器用例，方便后面的使用和展示。

首先，将先前的所有资产条目全部从admin中删除，确保数据库内没有任何数据。

然后，在Client/bin/目录下新建一个`report_assets`脚本，其内容如下：

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-
import json

import urllib.request
import urllib.parse

import os
import sys

BASE_DIR = os.path.dirname(os.getcwd())
# 设置工作目录，使得包和模块能够正常导入
sys.path.append(BASE_DIR)
from conf import settings


def update_test(data):
    """
    创建测试用例
    :return:
    """
    # 将数据打包到一个字典内，并转换为json格式
    data = {"asset_data": json.dumps(data)}
    # 根据settings中的配置，构造url
    url = "http://%s:%s%s" % (settings.Params['server'], settings.Params['port'], settings.Params['url'])
    print('正在将数据发送至： [%s]  ......' % url)
    try:
        # 使用Python内置的urllib.request库，发送post请求。
        # 需要先将数据进行封装，并转换成bytes类型
        data_encode = urllib.parse.urlencode(data).encode()
        response = urllib.request.urlopen(url=url, data=data_encode, timeout=settings.Params['request_timeout'])
        print("\033[31;1m发送完毕！\033[0m ")
        message = response.read().decode()
        print("返回结果：%s" % message)
    except Exception as e:
        message = "发送失败"
        print("\033[31;1m发送失败，%s\033[0m" % e)


if __name__ == '__main__':
    windows_data = {
        "os_type": "Windows",
        "os_release": "7 64bit  6.1.7601 ",
        "os_distribution": "Microsoft",
        "asset_type": "server",
        "cpu_count": 2,
        "cpu_model": "Intel(R) Core(TM) i5-2300 CPU @ 2.80GHz",
        "cpu_core_count": 8,
        "ram": [
            {
                "slot": "A1",
                "capacity": 8,
                "model": "Physical Memory",
                "manufacturer": "kingstone ",
                "sn": "456"
            },

        ],
        "manufacturer": "Intel",
        "model": "P67X-UD3R-B3",
        "wake_up_type": 6,
        "sn": "00426-OEM-8992662-111111",
        "physical_disk_driver": [
            {
                "iface_type": "unknown",
                "slot": 0,
                "sn": "3830414130423230343234362020202020202020",
                "model": "KINGSTON SV100S264G ATA Device",
                "manufacturer": "(标准磁盘驱动器)",
                "capacity": 128
            },
            {
                "iface_type": "SATA",
                "slot": 1,
                "sn": "383041413042323023234362020102020202020",
                "model": "KINGSTON SV100S264G ATA Device",
                "manufacturer": "(标准磁盘驱动器)",
                "capacity": 2048
            },

        ],
        "nic": [
            {
                "mac": "14:CF:22:FF:48:34",
                "model": "[00000011] Realtek RTL8192CU Wireless LAN 802.11n USB 2.0 Network Adapter",
                "name": 11,
                "ip_address": "192.168.1.110",
                "net_mask": [
                    "255.255.255.0",
                    "64"
                ]
            },
            {
                "mac": "0A:01:27:00:00:00",
                "model": "[00000013] VirtualBox Host-Only Ethernet Adapter",
                "name": 13,
                "ip_address": "192.168.56.1",
                "net_mask": [
                    "255.255.255.0",
                    "64"
                ]
            },
            {
                "mac": "14:CF:22:FF:48:34",
                "model": "[00000017] Microsoft Virtual WiFi Miniport Adapter",
                "name": 17,
                "ip_address": "",
                "net_mask": ""
            },
            {
                "mac": "14:CF:22:FF:48:34",
                "model": "Intel Adapter",
                "name": 17,
                "ip_address": "192.1.1.1",
                "net_mask": ""
            },


        ]
    }


    linux_data = {
        "asset_type": "server",
        "manufacturer": "innotek GmbH",
        "sn": "00001",
        "model": "VirtualBox",
        "uuid": "E8DE611C-4279-495C-9B58-502B6FCED076",
        "wake_up_type": "Power Switch",
        "os_distribution": "Ubuntu",
        "os_release": "Ubuntu 16.04.3 LTS",
        "os_type": "Linux",
        "cpu_count": "2",
        "cpu_core_count": "4",
        "cpu_model": "Intel(R) Core(TM) i5-2300 CPU @ 2.80GHz",
        "ram": [
            {
                "slot": "A1",
                "capacity": 8,
            }
        ],
        "ram_size": 3.858997344970703,
        "nic": [],
        "physical_disk_driver": [
            {
                "model": "VBOX HARDDISK",
                "size": "50",
                "sn": "VBeee1ba73-09085302"
            }
        ]
    }

    update_test(linux_data)
    update_test(windows_data)
```

该脚本的作用很简单，人为虚构了两台服务器（一台windows，一台Linux）的信息，并发送给CMDB。单独执行该脚本，在admin的新资产待审批区可以看到添加了两条新资产信息。

要添加更多的资产，只需修改脚本中`windows_data`和`linux_data`的数据即可。但是要注意的是，如果不修改sn，那么会变成资产数据更新，而不是增加新资产，这一点一定要注意。

OK，我们再加两条资产，这样就变成四个实例了。

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/123-3.png)

## 三、批准资产上线

有已经忍不住点击‘执行’命令的请举手！

是不是出现了错误？

```
AttributeError at /admin/assets/newassetapprovalzone/
module 'assets.asset_handler' has no attribute 'ApproveAsset'
```

这是必然的，因为还没有写如何上线的代码啊！

在`/assets/asset_handler.py`中添加下面的代码：

```
def log(log_type, msg=None, asset=None, new_asset=None, request=None):
    """
    记录日志
    """
    event = models.EventLog()
    if log_type == "upline":
        event.name = "%s <%s> ：  上线" % (asset.name, asset.sn)
        event.asset = asset
        event.detail = "资产成功上线！"
        event.user = request.user
    elif log_type == "approve_failed":
        event.name = "%s <%s> ：  审批失败" % (new_asset.asset_type, new_asset.sn)
        event.new_asset = new_asset
        event.detail = "审批失败！\n%s" % msg
        event.user = request.user
    # 更多日志类型.....
    event.save()


class ApproveAsset:
    """
    审批资产并上线。
    """
    def __init__(self, request, asset_id):
        self.request = request
        self.new_asset = models.NewAssetApprovalZone.objects.get(id=asset_id)
        self.data = json.loads(self.new_asset.data)

    def asset_upline(self):
        # 为以后的其它类型资产扩展留下接口
        func = getattr(self, "_%s_upline" % self.new_asset.asset_type)
        ret = func()
        return ret

    def _server_upline(self):
        # 在实际的生产环境中，下面的操作应该是原子性的整体事务，任何一步出现异常，所有操作都要回滚。
        asset = self._create_asset()  # 创建一条资产并返回资产对象。注意要和待审批区的资产区分开。
        try:
            self._create_manufacturer(asset) # 创建厂商
            self._create_server(asset)       # 创建服务器
            self._create_CPU(asset)          # 创建CPU
            self._create_RAM(asset)          # 创建内存
            self._create_disk(asset)         # 创建硬盘
            self._create_nic(asset)          # 创建网卡
            self._delete_original_asset()    # 从待审批资产区删除已审批上线的资产
        except Exception as e:
            asset.delete()
            log('approve_failed', msg=e, new_asset=self.new_asset, request=self.request)
            print(e)
            return False
        else:
            # 添加日志
            log("upline", asset=asset, request=self.request)
            print("新服务器上线!")
            return True

    def _create_asset(self):
        """
        创建资产并上线
        :return:
        """
        # 利用request.user自动获取当前管理人员的信息，作为审批人添加到资产数据中。
        asset = models.Asset.objects.create(asset_type=self.new_asset.asset_type,
                                            name="%s: %s" % (self.new_asset.asset_type, self.new_asset.sn),
                                            sn=self.new_asset.sn,
                                            approved_by=self.request.user,
                                            )
        return asset

    def _create_manufacturer(self, asset):
        """
        创建厂商
        :param asset:
        :return:
        """
        # 判断厂商数据是否存在。如果存在，看看数据库里是否已经有该厂商，再决定是获取还是创建。
        m = self.new_asset.manufacturer
        if m:
            manufacturer_obj, _ = models.Manufacturer.objects.get_or_create(name=m)
            asset.manufacturer = manufacturer_obj
            asset.save()

    def _create_server(self, asset):
        """
        创建服务器
        :param asset:
        :return:
        """
        models.Server.objects.create(asset=asset,
                                     model=self.new_asset.model,
                                     os_type=self.new_asset.os_type,
                                     os_distribution=self.new_asset.os_distribution,
                                     os_release=self.new_asset.os_release,
                                     )

    def _create_CPU(self, asset):
        """
        创建CPU.
        教程这里对发送过来的数据采取了最大限度的容忍，
        实际情况下你可能还要对数据的完整性、合法性、数据类型进行检测，
        根据不同的检测情况，是被动接收，还是打回去要求重新收集，请自行决定。
        这里的业务逻辑非常复杂，不可能面面俱到。
        :param asset:
        :return:
        """
        cpu = models.CPU.objects.create(asset=asset)
        cpu.cpu_model = self.new_asset.cpu_model
        cpu.cpu_count = self.new_asset.cpu_count
        cpu.cpu_core_count = self.new_asset.cpu_core_count
        cpu.save()

    def _create_RAM(self, asset):
        """
        创建内存。通常有多条内存
        :param asset:
        :return:
        """
        ram_list = self.data.get('ram')
        if not ram_list:    # 万一一条内存数据都没有
            return
        for ram_dict in ram_list:
            if not ram_dict.get('slot'):
                raise ValueError("未知的内存插槽！")  # 使用虚拟机的时候，可能无法获取内存插槽，需要你修改此处的逻辑。
            ram = models.RAM()
            ram.asset = asset
            ram.slot = ram_dict.get('slot')
            ram.sn = ram_dict.get('sn')
            ram.model = ram_dict.get('model')
            ram.manufacturer = ram_dict.get('manufacturer')
            ram.capacity = ram_dict.get('capacity', 0)
            ram.save()

    def _create_disk(self, asset):
        """
        存储设备种类多，还有Raid情况，需要根据实际情况具体解决。
        这里只以简单的SATA硬盘为例子。可能有多块硬盘。
        :param asset:
        :return:
        """
        disk_list = self.data.get('physical_disk_driver')
        if not disk_list:  # 一条硬盘数据都没有
            return
        for disk_dict in disk_list:
            if not disk_dict.get('sn'):
                raise ValueError("未知sn的硬盘！")  # 根据sn确定具体某块硬盘。
            disk = models.Disk()
            disk.asset = asset
            disk.sn = disk_dict.get('sn')
            disk.model = disk_dict.get('model')
            disk.manufacturer = disk_dict.get('manufacturer'),
            disk.slot = disk_dict.get('slot')
            disk.capacity = disk_dict.get('capacity', 0)
            iface = disk_dict.get('interface_type')
            if iface in ['SATA', 'SAS', 'SCSI', 'SSD', 'unknown']:
                disk.interface_type = iface

            disk.save()

    def _create_nic(self, asset):
        """
        创建网卡。可能有多个网卡，甚至虚拟网卡。
        :param asset:
        :return:
        """
        nic_list = self.data.get("nic")
        if not nic_list:
            return

        for nic_dict in nic_list:
            if not nic_dict.get('mac'):
                raise ValueError("网卡缺少mac地址！")
            if not nic_dict.get('model'):
                raise ValueError("网卡型号未知！")

            nic = models.NIC()
            nic.asset = asset
            nic.name = nic_dict.get('name')
            nic.model = nic_dict.get('model')
            nic.mac = nic_dict.get('mac')
            nic.ip_address = nic_dict.get('ip_address')
            if nic_dict.get('net_mask'):
                if len(nic_dict.get('net_mask')) > 0:
                    nic.net_mask = nic_dict.get('net_mask')[0]
            nic.save()

    def _delete_original_asset(self):
        """
        这里的逻辑是已经审批上线的资产，就从待审批区删除。
        也可以设置为修改成已审批状态但不删除，只是在管理界面特别处理，不让再次审批，灰色显示。
        不过这样可能导致待审批区越来越大。
        :return:
        """
        self.new_asset.delete()
```

核心就是增加了一个记录日志的log()函数以及审批资产的ApproveAsset类。

log()函数很简单，根据日志类型的不同，保存日志需要的各种信息，比如日志名称、关联的资产对象、日志详细内容和审批人员等等。所有的日志都被保存在数据库中，可以在admin中查看。

对于关键的ApproveAsset类，说明如下：

- 初始化方法接收reqeust和待审批资产的id；
- 分别提前获取资产对象和所有数据data；
- `asset_upline()`是入口方法，通过反射，获取一个类似`_server_upline`的方法。之所以这么做，是为后面的网络设别、安全设备、存储设备等更多类型资产的审批留下扩展接口。本教程里只实现了服务器类型资产的审批方法，更多的请自行完善，过程基本类似。

`_server_upline()`是服务器类型资产上线的核心方法：

- 它首先新建了一个Asset资产对象（注意要和待审批区的资产区分开）；
- 然后利用该对象，分别创建了对应的厂商、服务器、CPU、内存、硬盘和网卡，并删除待审批区的对应资产；
- 在实际的生产环境中，上面的操作应该是原子性的整体事务，任何一步出现异常，所有操作都要回滚；
- 如果任何一步出现错误，上面的操作全部撤销，也就是`asset.delete()`。记录错误日志，返回False；
- 如果没问题，那么记录正确日志，返回True。

对于`_create_asset(self)`方法，利用`request.user`自动获取当前管理人员的信息，作为审批人添加到资产数据中。

对于`_create_manufacturer(self, asset)`方法，先判断厂商数据是否存在，再决定是获取还是创建。

对于`_create_CPU(self, asset)`等方法，教程这里对数据采取了最大限度的容忍，实际情况下你可能还要对数据的完整性、合法性、数据类型进行检测，根据不同的检测情况，是被动接收，还是打回去要求重新收集，请自行决定。这里的业务逻辑非常复杂，不可能面面俱到。后面的内存、硬盘和网卡也是一样的。

对于`_delete_original_asset(self)`方法，这里的逻辑是已经审批上线的资产，就从待审批区删除。也可以设置为修改成已审批状态但不删除，只是在管理界面特别处理，不让再次审批，灰色显示，不过这样可能导致待审批区越来越大。

## 四、测试资产上线功能

重新启动服务器，在admin的新资产待审批区选择刚才的四条资产，然后选择上线action并点击‘执行’按钮，稍等片刻，显示`成功批准 4 条新资产上线！`的绿色提示信息，同时新资产也从待审批区被删除了，如下图所示：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/123-4.png)

然后，进入admin中的资产总表，可以看到有四条资产了。在其它相应的表内，也可以看到很多数据信息了。

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/123-5.png)

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/123-6.png)

往后，如果我们再次发送这四个服务器资产的信息，那就不是在待审批区了，而是已上线资产了。

最后，还可以看一下我们的日志记录：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/123-7.png)

# 8.已上线资产更新

前面，我们已经实现了资产进入待审批区、更新待审批区的资产信息以及审批资产上线三个主要功能，还剩下一个最主要的实时更新已上线资产信息的功能。

在`assets/views.py`中的report视图，目前是把已上线资产的数据更新流程‘pass’了，现在将其替换成下面的语句：

```
update_asset = asset_handler.UpdateAsset(request, asset_obj[0], data)
```

report视图变成了下面的样子：

```
@csrf_exempt
def report(request):
    """
    通过csrf_exempt装饰器，跳过Django的csrf安全机制，让post的数据能被接收，但这又会带来新的安全问题。
    可以在客户端，使用自定义的认证token，进行身份验证。这部分工作，请根据实际情况，自己进行。
    :param request:
    :return:
    """
    if request.method == "POST":
        asset_data = request.POST.get('asset_data')
        data = json.loads(asset_data)
        # 各种数据检查，请自行添加和完善！
        if not data:
            return HttpResponse("没有数据！")
        if not issubclass(dict, type(data)):
            return HttpResponse("数据必须为字典格式！")
        # 是否携带了关键的sn号
        sn = data.get('sn', None)
        if sn:
            # 进入审批流程
            # 首先判断是否在上线资产中存在该sn
            asset_obj = models.Asset.objects.filter(sn=sn)
            if asset_obj:
                # 进入已上线资产的数据更新流程
                update_asset = asset_handler.UpdateAsset(request, asset_obj[0], data)
                return HttpResponse("资产数据已经更新！")
            else:   # 如果已上线资产中没有，那么说明是未批准资产，进入新资产待审批区，更新或者创建资产。
                obj = asset_handler.NewAsset(request, data)
                response = obj.add_to_new_assets_zone()
                return HttpResponse(response)
        else:
            return HttpResponse("没有资产sn序列号，请检查数据！")
    return HttpResponse('200 ok')
```

然后，进入`assets/asset_handler.py`模块，修改`log()`方法，并且增加`UpdateAsset`类：

```
def log(log_type, msg=None, asset=None, new_asset=None, request=None):
    """
    记录日志
    """
    event = models.EventLog()
    if log_type == "upline":
        event.name = "%s <%s> ：  上线" % (asset.name, asset.sn)
        event.asset = asset
        event.detail = "资产成功上线！"
        event.user = request.user
    elif log_type == "approve_failed":
        event.name = "%s <%s> ：  审批失败" % (new_asset.asset_type, new_asset.sn)
        event.new_asset = new_asset
        event.detail = "审批失败！\n%s" % msg
        event.user = request.user
    elif log_type == "update":
        event.name = "%s <%s> ：  数据更新！" % (asset.asset_type, asset.sn)
        event.asset = asset
        event.detail = "更新成功！"
    elif log_type == "update_failed":
        event.name = "%s <%s> ：  更新失败" % (asset.asset_type, asset.sn)
        event.asset = asset
        event.detail = "更新失败！\n%s" % msg
    # 更多日志类型.....
    event.save()


class UpdateAsset:
    """
    自动更新已上线的资产。
    如果想让记录的日志更详细，可以逐条对比数据项，将更新过的项目记录到log信息中。
    """

    def __init__(self, request, asset, report_data):
        self.request = request
        self.asset = asset
        self.report_data = report_data            # 此处的数据是由客户端发送过来的整个数据字符串
        self.asset_update()

    def asset_update(self):
        # 为以后的其它类型资产扩展留下接口
        func = getattr(self, "_%s_update" % self.report_data['asset_type'])
        ret = func()
        return ret

    def _server_update(self):
        try:
            self._update_manufacturer()   # 更新厂商
            self._update_server()         # 更新服务器
            self._update_CPU()            # 更新CPU
            self._update_RAM()            # 更新内存
            self._update_disk()           # 更新硬盘
            self._update_nic()            # 更新网卡
            self.asset.save()
        except Exception as e:
            log('update_failed', msg=e, asset=self.asset, request=self.request)
            print(e)
            return False
        else:
            # 添加日志
            log("update", asset=self.asset)
            print("资产数据被更新!")
            return True

    def _update_manufacturer(self):
        """
        更新厂商
        """
        m = self.report_data.get('manufacturer')
        if m:
            manufacturer_obj, _ = models.Manufacturer.objects.get_or_create(name=m)
            self.asset.manufacturer = manufacturer_obj
        else:
            self.asset.manufacturer = None
        self.asset.manufacturer.save()

    def _update_server(self):
        """
        更新服务器
        """
        self.asset.server.model = self.report_data.get('model')
        self.asset.server.os_type = self.report_data.get('os_type')
        self.asset.server.os_distribution = self.report_data.get('os_distribution')
        self.asset.server.os_release = self.report_data.get('os_release')
        self.asset.server.save()

    def _update_CPU(self):
        """
        更新CPU信息
        :return:
        """
        self.asset.cpu.cpu_model = self.report_data.get('cpu_model')
        self.asset.cpu.cpu_count = self.report_data.get('cpu_count')
        self.asset.cpu.cpu_core_count = self.report_data.get('cpu_core_count')
        self.asset.cpu.save()

    def _update_RAM(self):
        """
        更新内存信息。
        使用集合数据类型中差的概念，处理不同的情况。
        如果新数据有，但原数据没有，则新增；
        如果新数据没有，但原数据有，则删除原来多余的部分；
        如果新的和原数据都有，则更新。
        在原则上，下面的代码应该写成一个复用的函数，
        但是由于内存、硬盘、网卡在某些方面的差别，导致很难提取出重用的代码。
        :return:
        """
        # 获取已有内存信息，并转成字典格式
        old_rams = models.RAM.objects.filter(asset=self.asset)
        old_rams_dict = dict()
        if old_rams:
            for ram in old_rams:
                old_rams_dict[ram.slot] = ram
        # 获取新数据中的内存信息，并转成字典格式
        new_rams_list = self.report_data['ram']
        new_rams_dict = dict()
        if new_rams_list:
            for item in new_rams_list:
                new_rams_dict[item['slot']] = item

        # 利用set类型的差集功能，获得需要删除的内存数据对象
        need_deleted_keys = set(old_rams_dict.keys()) - set(new_rams_dict.keys())
        if need_deleted_keys:
            for key in need_deleted_keys:
                old_rams_dict[key].delete()

        # 需要新增或更新的
        if new_rams_dict:
            for key in new_rams_dict:
                defaults = {
                            'sn': new_rams_dict[key].get('sn'),
                            'model': new_rams_dict[key].get('model'),
                            'manufacturer': new_rams_dict[key].get('manufacturer'),
                            'capacity': new_rams_dict[key].get('capacity', 0),
                            }
                models.RAM.objects.update_or_create(asset=self.asset, slot=key, defaults=defaults)

    def _update_disk(self):
        """
        更新硬盘信息。类似更新内存。
        """
        old_disks = models.Disk.objects.filter(asset=self.asset)
        old_disks_dict = dict()
        if old_disks:
            for disk in old_disks:
                old_disks_dict[disk.sn] = disk

        new_disks_list = self.report_data['physical_disk_driver']
        new_disks_dict = dict()
        if new_disks_list:
            for item in new_disks_list:
                new_disks_dict[item['sn']] = item

        # 需要删除的
        need_deleted_keys = set(old_disks_dict.keys()) - set(new_disks_dict.keys())
        if need_deleted_keys:
            for key in need_deleted_keys:
                old_disks_dict[key].delete()

        # 需要新增或更新的
        if new_disks_dict:
            for key in new_disks_dict:
                interface_type = new_disks_dict[key].get('interface_type', 'unknown')
                if interface_type not in ['SATA', 'SAS', 'SCSI', 'SSD', 'unknown']:
                    interface_type = 'unknown'
                defaults = {
                    'slot': new_disks_dict[key].get('slot'),
                    'model': new_disks_dict[key].get('model'),
                    'manufacturer': new_disks_dict[key].get('manufacturer'),
                    'capacity': new_disks_dict[key].get('capacity', 0),
                    'interface_type': interface_type,
                }
                models.Disk.objects.update_or_create(asset=self.asset, sn=key, defaults=defaults)

    def _update_nic(self):
        """
        更新网卡信息。类似更新内存。
        """
        old_nics = models.NIC.objects.filter(asset=self.asset)
        old_nics_dict = dict()
        if old_nics:
            for nic in old_nics:
                old_nics_dict[nic.model+nic.mac] = nic

        new_nics_list = self.report_data['nic']
        new_nics_dict = dict()
        if new_nics_list:
            for item in new_nics_list:
                new_nics_dict[item['model']+item['mac']] = item

        # 需要删除的
        need_deleted_keys = set(old_nics_dict.keys()) - set(new_nics_dict.keys())
        if need_deleted_keys:
            for key in need_deleted_keys:
                old_nics_dict[key].delete()

        # 需要新增或更新的
        if new_nics_dict:
            for key in new_nics_dict:
                if new_nics_dict[key].get('net_mask') and len(new_nics_dict[key].get('net_mask')) > 0:
                    net_mask = new_nics_dict[key].get('net_mask')[0]
                else:
                    net_mask = ""
                defaults = {
                    'name': new_nics_dict[key].get('name'),
                    'ip_address': new_nics_dict[key].get('ip_address'),
                    'net_mask': net_mask,
                }
                models.NIC.objects.update_or_create(asset=self.asset, model=new_nics_dict[key]['model'],
                                                    mac=new_nics_dict[key]['mac'], defaults=defaults)

        print('更新成功！')
```

对于log()函数，只是增加了两种数据更新的日志类型，分别记录不同的日志情况，没什么特别的。

对于UpdateAsset类，类似前面的ApproveAsset类：

- 首先初始化动作，自动执行asset_update()方法；
- 依然是通过反射，决定要调用的更新方法；
- 教程实现了主要的服务器类型资产的更新，对于网络设备、安全设备等请自行完善，基本类似；
- `_server_update(self)`方法中，分别更新厂商、服务器本身、CPU、内存、网卡、硬盘等信息。然后保存数据，这些事务应该是原子性的，所以要抓取异常；
- 不管成功还是失败，都要记录日志。

最主要的，对于`_update_CPU(self)`等方法，以内存为例，由于内存可能有多条，新的数据中可能出现三种情况，拔除、新增、信息变更，因此要分别对待和处理。

- 首先，获取已有内存信息，并转成字典格式；
- 其次，获取新数据中的内存信息，并转成字典格式；
- 利用set类型的差集功能，获得需要删除的内存数据对象
- 对要删除的对象，执行delete()方法；
- 对于需要新增或更新的内存对象，首先生成defaults数据字典；
- 然后，使用`update_or_create(asset=self.asset, slot=key, defaults=defaults)`方法，一次性完成新增或者更新数据的操作，不用写两个方法的代码；
- 硬盘和网卡的操作类同内存的操作。

数据更新完毕后，需要保存asset对象，也就是`self.asset.save()`，否则前面的工作无法关联保存下来。

**最终的`asset_handler.py`如下**：

```
import json
from assets import models


class NewAsset(object):
    def __init__(self, request, data):
        self.request = request
        self.data = data

    def add_to_new_assets_zone(self):
        defaults = {
            'data': json.dumps(self.data),
            'asset_type': self.data.get('asset_type'),
            'manufacturer': self.data.get('manufacturer'),
            'model': self.data.get('model'),
            'ram_size': self.data.get('ram_size'),
            'cpu_model': self.data.get('cpu_model'),
            'cpu_count': self.data.get('cpu_count'),
            'cpu_core_count': self.data.get('cpu_core_count'),
            'os_distribution': self.data.get('os_distribution'),
            'os_release': self.data.get('os_release'),
            'os_type': self.data.get('os_type'),

        }
        models.NewAssetApprovalZone.objects.update_or_create(sn=self.data['sn'], defaults=defaults)

        return '资产已经加入或更新待审批区！'


def log(log_type, msg=None, asset=None, new_asset=None, request=None):
    """
    记录日志
    """
    event = models.EventLog()
    if log_type == "upline":
        event.name = "%s <%s> ：  上线" % (asset.name, asset.sn)
        event.asset = asset
        event.detail = "资产成功上线！"
        event.user = request.user
    elif log_type == "approve_failed":
        event.name = "%s <%s> ：  审批失败" % (new_asset.asset_type, new_asset.sn)
        event.new_asset = new_asset
        event.detail = "审批失败！\n%s" % msg
        event.user = request.user
    elif log_type == "update":
        event.name = "%s <%s> ：  数据更新！" % (asset.asset_type, asset.sn)
        event.asset = asset
        event.detail = "更新成功！"
    elif log_type == "update_failed":
        event.name = "%s <%s> ：  更新失败" % (asset.asset_type, asset.sn)
        event.asset = asset
        event.detail = "更新失败！\n%s" % msg
    # 更多日志类型.....
    event.save()


class ApproveAsset:
    """
    审批资产并上线。
    """
    def __init__(self, request, asset_id):
        self.request = request
        self.new_asset = models.NewAssetApprovalZone.objects.get(id=asset_id)
        self.data = json.loads(self.new_asset.data)

    def asset_upline(self):
        # 为以后的其它类型资产扩展留下接口
        func = getattr(self, "_%s_upline" % self.new_asset.asset_type)
        ret = func()
        return ret

    def _server_upline(self):
        # 在实际的生产环境中，下面的操作应该是原子性的整体事务，任何一步出现异常，所有操作都要回滚。
        asset = self._create_asset()  # 创建一条资产并返回资产对象。注意要和待审批区的资产区分开。
        try:
            self._create_manufacturer(asset) # 创建厂商
            self._create_server(asset)       # 创建服务器
            self._create_CPU(asset)          # 创建CPU
            self._create_RAM(asset)          # 创建内存
            self._create_disk(asset)         # 创建硬盘
            self._create_nic(asset)          # 创建网卡
            self._delete_original_asset()    # 从待审批资产区删除已审批上线的资产
        except Exception as e:
            asset.delete()
            log('approve_failed', msg=e, new_asset=self.new_asset, request=self.request)
            print(e)
            return False
        else:
            # 添加日志
            log("upline", asset=asset, request=self.request)
            print("新服务器上线!")
            return True

    def _create_asset(self):
        """
        创建资产并上线
        :return:
        """
        # 利用request.user自动获取当前管理人员的信息，作为审批人添加到资产数据中。
        asset = models.Asset.objects.create(asset_type=self.new_asset.asset_type,
                                            name="%s: %s" % (self.new_asset.asset_type, self.new_asset.sn),
                                            sn=self.new_asset.sn,
                                            approved_by=self.request.user,
                                            )
        return asset

    def _create_manufacturer(self, asset):
        """
        创建厂商
        :param asset:
        :return:
        """
        # 判断厂商数据是否存在。如果存在，看看数据库里是否已经有该厂商，再决定是获取还是创建。
        m = self.new_asset.manufacturer
        if m:
            manufacturer_obj, _ = models.Manufacturer.objects.get_or_create(name=m)
            asset.manufacturer = manufacturer_obj
            asset.save()

    def _create_server(self, asset):
        """
        创建服务器
        :param asset:
        :return:
        """
        models.Server.objects.create(asset=asset,
                                     model=self.new_asset.model,
                                     os_type=self.new_asset.os_type,
                                     os_distribution=self.new_asset.os_distribution,
                                     os_release=self.new_asset.os_release,
                                     )

    def _create_CPU(self, asset):
        """
        创建CPU.
        教程这里对发送过来的数据采取了最大限度的容忍，
        实际情况下你可能还要对数据的完整性、合法性、数据类型进行检测，
        根据不同的检测情况，是被动接收，还是打回去要求重新收集，请自行决定。
        这里的业务逻辑非常复杂，不可能面面俱到。
        :param asset:
        :return:
        """
        cpu = models.CPU.objects.create(asset=asset)
        cpu.cpu_model = self.new_asset.cpu_model
        cpu.cpu_count = self.new_asset.cpu_count
        cpu.cpu_core_count = self.new_asset.cpu_core_count
        cpu.save()

    def _create_RAM(self, asset):
        """
        创建内存。通常有多条内存
        :param asset:
        :return:
        """
        ram_list = self.data.get('ram')
        if not ram_list:    # 万一一条内存数据都没有
            return
        for ram_dict in ram_list:
            if not ram_dict.get('slot'):
                raise ValueError("未知的内存插槽！")  # 使用虚拟机的时候，可能无法获取内存插槽，需要你修改此处的逻辑。
            ram = models.RAM()
            ram.asset = asset
            ram.slot = ram_dict.get('slot')
            ram.sn = ram_dict.get('sn')
            ram.model = ram_dict.get('model')
            ram.manufacturer = ram_dict.get('manufacturer')
            ram.capacity = ram_dict.get('capacity', 0)
            ram.save()

    def _create_disk(self, asset):
        """
        存储设备种类多，还有Raid情况，需要根据实际情况具体解决。
        这里只以简单的SATA硬盘为例子。可能有多块硬盘。
        :param asset:
        :return:
        """
        disk_list = self.data.get('physical_disk_driver')
        if not disk_list:  # 一条硬盘数据都没有
            return
        for disk_dict in disk_list:
            if not disk_dict.get('sn'):
                raise ValueError("未知sn的硬盘！")  # 根据sn确定具体某块硬盘。
            disk = models.Disk()
            disk.asset = asset
            disk.sn = disk_dict.get('sn')
            disk.model = disk_dict.get('model')
            disk.manufacturer = disk_dict.get('manufacturer'),
            disk.slot = disk_dict.get('slot')
            disk.capacity = disk_dict.get('capacity', 0)
            iface = disk_dict.get('interface_type')
            if iface in ['SATA', 'SAS', 'SCSI', 'SSD', 'unknown']:
                disk.interface_type = iface

            disk.save()

    def _create_nic(self, asset):
        """
        创建网卡。可能有多个网卡，甚至虚拟网卡。
        :param asset:
        :return:
        """
        nic_list = self.data.get("nic")
        if not nic_list:
            return

        for nic_dict in nic_list:
            if not nic_dict.get('mac'):
                raise ValueError("网卡缺少mac地址！")
            if not nic_dict.get('model'):
                raise ValueError("网卡型号未知！")

            nic = models.NIC()
            nic.asset = asset
            nic.name = nic_dict.get('name')
            nic.model = nic_dict.get('model')
            nic.mac = nic_dict.get('mac')
            nic.ip_address = nic_dict.get('ip_address')
            if nic_dict.get('net_mask'):
                if len(nic_dict.get('net_mask')) > 0:
                    nic.net_mask = nic_dict.get('net_mask')[0]
            nic.save()

    def _delete_original_asset(self):
        """
        这里的逻辑是已经审批上线的资产，就从待审批区删除。
        也可以设置为修改成已审批状态但不删除，只是在管理界面特别处理，不让再次审批，灰色显示。
        不过这样可能导致待审批区越来越大。
        :return:
        """
        self.new_asset.delete()


class UpdateAsset:
    """
    自动更新已上线的资产。
    如果想让记录的日志更详细，可以逐条对比数据项，将更新过的项目记录到log信息中。
    """

    def __init__(self, request, asset, report_data):
        self.request = request
        self.asset = asset
        self.report_data = report_data            # 此处的数据是由客户端发送过来的整个数据字符串
        self.asset_update()

    def asset_update(self):
        # 为以后的其它类型资产扩展留下接口
        func = getattr(self, "_%s_update" % self.report_data['asset_type'])
        ret = func()
        return ret

    def _server_update(self):
        try:
            self._update_manufacturer()   # 更新厂商
            self._update_server()         # 更新服务器
            self._update_CPU()            # 更新CPU
            self._update_RAM()            # 更新内存
            self._update_disk()           # 更新硬盘
            self._update_nic()            # 更新网卡
            self.asset.save()
        except Exception as e:
            log('update_failed', msg=e, asset=self.asset, request=self.request)
            print(e)
            return False
        else:
            # 添加日志
            log("update", asset=self.asset)
            print("资产数据被更新!")
            return True

    def _update_manufacturer(self):
        """
        更新厂商
        """
        m = self.report_data.get('manufacturer')
        if m:
            manufacturer_obj, _ = models.Manufacturer.objects.get_or_create(name=m)
            self.asset.manufacturer = manufacturer_obj
        else:
            self.asset.manufacturer = None
        self.asset.manufacturer.save()

    def _update_server(self):
        """
        更新服务器
        """
        self.asset.server.model = self.report_data.get('model')
        self.asset.server.os_type = self.report_data.get('os_type')
        self.asset.server.os_distribution = self.report_data.get('os_distribution')
        self.asset.server.os_release = self.report_data.get('os_release')
        self.asset.server.save()

    def _update_CPU(self):
        """
        更新CPU信息
        :return:
        """
        self.asset.cpu.cpu_model = self.report_data.get('cpu_model')
        self.asset.cpu.cpu_count = self.report_data.get('cpu_count')
        self.asset.cpu.cpu_core_count = self.report_data.get('cpu_core_count')
        self.asset.cpu.save()

    def _update_RAM(self):
        """
        更新内存信息。
        使用集合数据类型中差的概念，处理不同的情况。
        如果新数据有，但原数据没有，则新增；
        如果新数据没有，但原数据有，则删除原来多余的部分；
        如果新的和原数据都有，则更新。
        在原则上，下面的代码应该写成一个复用的函数，
        但是由于内存、硬盘、网卡在某些方面的差别，导致很难提取出重用的代码。
        :return:
        """
        # 获取已有内存信息，并转成字典格式
        old_rams = models.RAM.objects.filter(asset=self.asset)
        old_rams_dict = dict()
        if old_rams:
            for ram in old_rams:
                old_rams_dict[ram.slot] = ram
        # 获取新数据中的内存信息，并转成字典格式
        new_rams_list = self.report_data['ram']
        new_rams_dict = dict()
        if new_rams_list:
            for item in new_rams_list:
                new_rams_dict[item['slot']] = item

        # 利用set类型的差集功能，获得需要删除的内存数据对象
        need_deleted_keys = set(old_rams_dict.keys()) - set(new_rams_dict.keys())
        if need_deleted_keys:
            for key in need_deleted_keys:
                old_rams_dict[key].delete()

        # 需要新增或更新的
        if new_rams_dict:
            for key in new_rams_dict:
                defaults = {
                            'sn': new_rams_dict[key].get('sn'),
                            'model': new_rams_dict[key].get('model'),
                            'manufacturer': new_rams_dict[key].get('manufacturer'),
                            'capacity': new_rams_dict[key].get('capacity', 0),
                            }
                models.RAM.objects.update_or_create(asset=self.asset, slot=key, defaults=defaults)

    def _update_disk(self):
        """
        更新硬盘信息。类似更新内存。
        """
        old_disks = models.Disk.objects.filter(asset=self.asset)
        old_disks_dict = dict()
        if old_disks:
            for disk in old_disks:
                old_disks_dict[disk.sn] = disk

        new_disks_list = self.report_data['physical_disk_driver']
        new_disks_dict = dict()
        if new_disks_list:
            for item in new_disks_list:
                new_disks_dict[item['sn']] = item

        # 需要删除的
        need_deleted_keys = set(old_disks_dict.keys()) - set(new_disks_dict.keys())
        if need_deleted_keys:
            for key in need_deleted_keys:
                old_disks_dict[key].delete()

        # 需要新增或更新的
        if new_disks_dict:
            for key in new_disks_dict:
                interface_type = new_disks_dict[key].get('interface_type', 'unknown')
                if interface_type not in ['SATA', 'SAS', 'SCSI', 'SSD', 'unknown']:
                    interface_type = 'unknown'
                defaults = {
                    'slot': new_disks_dict[key].get('slot'),
                    'model': new_disks_dict[key].get('model'),
                    'manufacturer': new_disks_dict[key].get('manufacturer'),
                    'capacity': new_disks_dict[key].get('capacity', 0),
                    'interface_type': interface_type,
                }
                models.Disk.objects.update_or_create(asset=self.asset, sn=key, defaults=defaults)

    def _update_nic(self):
        """
        更新网卡信息。类似更新内存。
        """
        old_nics = models.NIC.objects.filter(asset=self.asset)
        old_nics_dict = dict()
        if old_nics:
            for nic in old_nics:
                old_nics_dict[nic.model+nic.mac] = nic

        new_nics_list = self.report_data['nic']
        new_nics_dict = dict()
        if new_nics_list:
            for item in new_nics_list:
                new_nics_dict[item['model']+item['mac']] = item

        # 需要删除的
        need_deleted_keys = set(old_nics_dict.keys()) - set(new_nics_dict.keys())
        if need_deleted_keys:
            for key in need_deleted_keys:
                old_nics_dict[key].delete()

        # 需要新增或更新的
        if new_nics_dict:
            for key in new_nics_dict:
                if new_nics_dict[key].get('net_mask') and len(new_nics_dict[key].get('net_mask')) > 0:
                    net_mask = new_nics_dict[key].get('net_mask')[0]
                else:
                    net_mask = ""
                defaults = {
                    'name': new_nics_dict[key].get('name'),
                    'ip_address': new_nics_dict[key].get('ip_address'),
                    'net_mask': net_mask,
                }
                models.NIC.objects.update_or_create(asset=self.asset, model=new_nics_dict[key]['model'],
                                                    mac=new_nics_dict[key]['mac'], defaults=defaults)

        print('更新成功！')
```

现在，可以测试一下资产数据的更新了。重启CMDB，然后转到Client/report_assetss.py脚本，修改其中的一些数据，删除或增加一些内存、硬盘、网卡的条目。**注意数据格式必须正确，sn必须不能变。**

再次运行脚本，报告数据。进入admin中查看相关内容，可以看到数据已经得到更新了。

至此，CMDB自动资产管理系统的后台部分已经完成了。

# 9.前端框架AdminLTE

作为CMDB资产管理项目，必须有一个丰富、直观、酷炫的前端页面。

适合运维平台的前端框架有很多，开源的也不少，这里选用的是AdminLTE。

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/125-1.png)

AdminLTE托管在GitHub上，可以通过下面的地址下载：

https://github.com/ColorlibHQ/AdminLTE/releases

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/125-2.png)

这里我们下载的是2.4.10版本，其官方文档地址：https://adminlte.io/docs/2.4/installation

AdminLTE自带JQuery和Bootstrap3框架插件，无需另外下载。

AdminLTE自带多种配色皮肤，可根据需要实时调整。

AdminLTE是移动端自适应的，无需单独考虑。

AdminLTE自带大量插件，比如表格、Charts等等，可根据需要载入。

## 一、创建base.html

AdminLTE源文件根目录下有个`starter.html`页面文件，可以利用它修改出我们CMDB项目需要的基本框架。

在项目的根目录cmdb下新建static目录，在settings文件中添加下面的配置：

```
STATICFILES_DIRS = [
    os.path.join(BASE_DIR, "static"),
]
```

为了以后扩展的方便，在`CMDB/static/`目录下再创建一级目录`adminlet-2.4.10`，将 AdminLTE源文件包里的`bower_components`、`dist`和`plugins`三个文件夹，全部拷贝到`adminlet-2.4.10`目录中，这样做的话文件会比较大，比较多，但可以防止出现引用文件找不到、插件缺失等情况的发生，等以后对AdminLTE非常熟悉了，可以对其中无用的文件进行删减。

在cmdb根目录下的templates目录中，新建`base.html`文件，将AdminLTE源文件包中的`starter.html`中的内容拷贝过去。然后，根据我们项目的具体情况修改文件引用、页面框架、title、CSS、主体和script块。这一部分工作量还是蛮大的，很繁琐，下面给出成品：

```
{% load static %}
<!DOCTYPE html>
<!--
This is a starter template page. Use this page to start your new project from
scratch. This page gets rid of all links and provides the needed markup only.
-->
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>{% block title %}base{% endblock %}</title>
  <!-- Tell the browser to be responsive to screen width -->
  <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
  <link rel="stylesheet" href="{% static 'adminlet-2.4.10/bower_components/bootstrap/dist/css/bootstrap.min.css' %}">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="{% static 'adminlet-2.4.10/bower_components/font-awesome/css/font-awesome.min.css' %}">
  <!-- Ionicons -->
  <link rel="stylesheet" href="{% static 'adminlet-2.4.10/bower_components/Ionicons/css/ionicons.min.css' %}">
  <!-- Theme style -->
  <link rel="stylesheet" href="{% static 'adminlet-2.4.10/dist/css/AdminLTE.min.css' %}">
  <!-- AdminLTE Skins. We have chosen the skin-blue for this starter
        page. However, you can choose any other skin. Make sure you
        apply the skin class to the body tag so the changes take effect. -->
  <link rel="stylesheet" href="{% static 'adminlet-2.4.10/dist/css/skins/skin-blue.min.css' %}">

    {% block css %}{% endblock %}

</head>
<!--
BODY TAG OPTIONS:
=================
Apply one or more of the following classes to get the
desired effect
|---------------------------------------------------------|
| SKINS         | skin-blue                               |
|               | skin-black                              |
|               | skin-purple                             |
|               | skin-yellow                             |
|               | skin-red                                |
|               | skin-green                              |
|---------------------------------------------------------|
|LAYOUT OPTIONS | fixed                                   |
|               | layout-boxed                            |
|               | layout-top-nav                          |
|               | sidebar-collapse                        |
|               | sidebar-mini                            |
|---------------------------------------------------------|
-->
<body class="hold-transition skin-blue sidebar-mini">
<div class="wrapper">

  <!-- Main Header -->
  <header class="main-header">

    <!-- Logo -->
    <a href="#" class="logo">
      <!-- mini logo for sidebar mini 50x50 pixels -->
      <span class="logo-mini"><b>CMDB</b></span>
      <!-- logo for regular state and mobile devices -->
      <span class="logo-lg"><b>CMDB</b></span>
    </a>

    <!-- Header Navbar -->
    <nav class="navbar navbar-static-top" role="navigation">
      <!-- Sidebar toggle button-->
      <a href="#" class="sidebar-toggle" data-toggle="push-menu" role="button">
        <span class="sr-only">Toggle navigation</span>
      </a>
      <!-- Navbar Right Menu -->
      <div class="navbar-custom-menu">
        <ul class="nav navbar-nav">
          <!-- Messages: style can be found in dropdown.less-->
          <li class="dropdown messages-menu">
            <!-- Menu toggle button -->
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
              <i class="fa fa-envelope-o"></i>
              <span class="label label-success">4</span>
            </a>
            <ul class="dropdown-menu">
              <li class="header">You have 4 messages</li>
              <li>
                <!-- inner menu: contains the messages -->
                <ul class="menu">
                  <li><!-- start message -->
                    <a href="#">
                      <div class="pull-left">
                        <!-- User Image -->
                        <img src="{% static 'adminlet-2.4.10/dist/img/user2-160x160.jpg' %}" class="img-circle" alt="User Image">
                      </div>
                      <!-- Message title and timestamp -->
                      <h4>
                        Support Team
                        <small><i class="fa fa-clock-o"></i> 5 mins</small>
                      </h4>
                      <!-- The message -->
                      <p>Why not buy a new awesome theme?</p>
                    </a>
                  </li>
                  <!-- end message -->
                </ul>
                <!-- /.menu -->
              </li>
              <li class="footer"><a href="#">See All Messages</a></li>
            </ul>
          </li>
          <!-- /.messages-menu -->

          <!-- Notifications Menu -->
          <li class="dropdown notifications-menu">
            <!-- Menu toggle button -->
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
              <i class="fa fa-bell-o"></i>
              <span class="label label-warning">10</span>
            </a>
            <ul class="dropdown-menu">
              <li class="header">You have 10 notifications</li>
              <li>
                <!-- Inner Menu: contains the notifications -->
                <ul class="menu">
                  <li><!-- start notification -->
                    <a href="#">
                      <i class="fa fa-users text-aqua"></i> 5 new members joined today
                    </a>
                  </li>
                  <!-- end notification -->
                </ul>
              </li>
              <li class="footer"><a href="#">View all</a></li>
            </ul>
          </li>
          <!-- Tasks Menu -->
          <li class="dropdown tasks-menu">
            <!-- Menu Toggle Button -->
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
              <i class="fa fa-flag-o"></i>
              <span class="label label-danger">9</span>
            </a>
            <ul class="dropdown-menu">
              <li class="header">You have 9 tasks</li>
              <li>
                <!-- Inner menu: contains the tasks -->
                <ul class="menu">
                  <li><!-- Task item -->
                    <a href="#">
                      <!-- Task title and progress text -->
                      <h3>
                        Design some buttons
                        <small class="pull-right">20%</small>
                      </h3>
                      <!-- The progress bar -->
                      <div class="progress xs">
                        <!-- Change the css width attribute to simulate progress -->
                        <div class="progress-bar progress-bar-aqua" style="width: 20%" role="progressbar"
                             aria-valuenow="20" aria-valuemin="0" aria-valuemax="100">
                          <span class="sr-only">20% Complete</span>
                        </div>
                      </div>
                    </a>
                  </li>
                  <!-- end task item -->
                </ul>
              </li>
              <li class="footer">
                <a href="#">View all tasks</a>
              </li>
            </ul>
          </li>
          <!-- User Account Menu -->
          <li class="dropdown user user-menu">
            <!-- Menu Toggle Button -->
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
              <!-- The user image in the navbar-->
              <img src="{% static 'adminlet-2.4.10/dist/img/user2-160x160.jpg' %}" class="user-image" alt="User Image">
              <!-- hidden-xs hides the username on small devices so only the image appears. -->
              <span class="hidden-xs">系统管理员</span>
            </a>
            <ul class="dropdown-menu">
              <!-- The user image in the menu -->
              <li class="user-header">
                <img src="{% static 'adminlet-2.4.10/dist/img/user2-160x160.jpg' %}" class="img-circle" alt="User Image">

                <p>
                  系统管理员
                  <small>2019-4-12</small>
                </p>
              </li>
              <!-- Menu Body -->
              <li class="user-body">
                <div class="row">
                  <div class="col-xs-4 text-center">
                    <a href="#">Followers</a>
                  </div>
                  <div class="col-xs-4 text-center">
                    <a href="#">Sales</a>
                  </div>
                  <div class="col-xs-4 text-center">
                    <a href="#">Friends</a>
                  </div>
                </div>
                <!-- /.row -->
              </li>
              <!-- Menu Footer-->
              <li class="user-footer">
                <div class="pull-left">
                  <a href="#" class="btn btn-default btn-flat">Profile</a>
                </div>
                <div class="pull-right">
                  <a href="#" class="btn btn-default btn-flat">Sign out</a>
                </div>
              </li>
            </ul>
          </li>
        </ul>
      </div>
    </nav>
  </header>

  <!-- Left side column. contains the logo and sidebar -->
  <aside class="main-sidebar">

    <!-- sidebar: style can be found in sidebar.less -->
    <section class="sidebar">

      <!-- Sidebar user panel (optional) -->
      <div class="user-panel">
        <div class="pull-left image">
          <img src="{% static 'adminlet-2.4.10/dist/img/user2-160x160.jpg' %}" class="img-circle" alt="User Image">
        </div>
        <div class="pull-left info">
          <p>Admin</p>
          <!-- Status -->
          <a href="#"><i class="fa fa-circle text-success"></i>在线</a>
        </div>
      </div>

      <!-- search form (Optional) -->
      <form action="#" method="get" class="sidebar-form">
        <div class="input-group">
          <input type="text" name="q" class="form-control" placeholder="Search...">
          <span class="input-group-btn">
              <button type="submit" name="search" id="search-btn" class="btn btn-flat"><i class="fa fa-search"></i>
              </button>
            </span>
        </div>
      </form>
      <!-- /.search form -->

      <!-- Sidebar Menu -->
      <ul class="sidebar-menu" data-widget="tree">
        <li class="header">导航栏</li>
        <!-- Optionally, you can add icons to the links -->
        <li><a href="{% url 'assets:dashboard' %}"><i class="fa fa-dashboard"></i> <span>仪表盘</span></a></li>
        <li><a href="{% url 'assets:index' %}"><i class="fa fa-table"></i> <span>资产总表</span></a></li>
      </ul>
      <!-- /.sidebar-menu -->
    </section>
    <!-- /.sidebar -->
  </aside>

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">

    {% block breadcrumb %}{% endblock %}

    <!-- Main content -->
    <section class="content container-fluid">
        {#        主体内容全放到这里！#}
        {% block content %}{% endblock %}
    </section>
    <!-- /.content -->

  </div>
  <!-- /.content-wrapper -->


  <!-- Main Footer -->
  <footer class="main-footer">
    <!-- To the right -->
    <div class="pull-right hidden-xs">
      http://www.liujiangblog.com
    </div>
    <!-- Default to the left -->
    <strong>Copyright &copy; 2019 <a href="http://www.liujiangblog.com" target="_blank">刘江的Django教程</a>.</strong> All rights reserved.
  </footer>


</div>
<!-- ./wrapper -->

<!-- REQUIRED JS SCRIPTS -->

<!-- jQuery 3 -->
<script src="{% static 'adminlet-2.4.10/bower_components/jquery/dist/jquery.min.js' %}"></script>
<!-- Bootstrap 3.3.7 -->
<script src="{% static 'adminlet-2.4.10/bower_components/bootstrap/dist/js/bootstrap.min.js' %}"></script>
<!-- AdminLTE App -->
<script src="{% static 'adminlet-2.4.10/dist/js/adminlte.min.js' %}"></script>

{% block script %}{% endblock %}

<script>
    $('ul.sidebar-menu li').each(function(i){
        if($(this).children().first().attr('href')==='{{ request.path }}'){
            $(this).addClass('active');
        }else{
        }
    });
</script>
</body>
</html>
```

其中，在代码的底部，为了让侧边栏根据当前url的不同，实现不同的激活active状态，编写了一段简单的js代码：

```
<script>
    $('ul.sidebar-menu li').each(function(i){
        if($(this).children().first().attr('href')==='{{ request.path }}'){
            $(this).addClass('active');
        }else{
        }
 });
</script>
```

## 二、创建路由、视图

这里设计了三个视图和页面，分别是：

- dashboard：仪表盘，图形化的数据展示
- index：资产总表，表格的形式展示资产信息
- detail：单个资产的详细信息页面

将`assets/urls.py`修改成下面的样子：

```
from django.urls import path
from assets import views

app_name = 'assets'

urlpatterns = [
    path('report/', views.report, name='report'),
    path('dashboard/', views.dashboard, name='dashboard'),
    path('index/', views.index, name='index'),
    path('detail/<int:asset_id>/', views.detail, name="detail"),
    path('', views.dashboard),   
]
```

在`assets/views.py`中，增加下面三个视图：

```
from django.shortcuts import get_object_or_404

def index(request):

    assets = models.Asset.objects.all()
    return render(request, 'assets/index.html', locals())


def dashboard(request):
    pass
    return render(request, 'assets/dashboard.html', locals())


def detail(request, asset_id):
    """
    以显示服务器类型资产详细为例，安全设备、存储设备、网络设备等参照此例。
    :param request:
    :param asset_id:
    :return:
    """
    asset = get_object_or_404(models.Asset, id=asset_id)
    return render(request, 'assets/detail.html', locals())
```

注意需要提前`from django.shortcuts import get_object_or_404`导入`get_object_or_404()`方法，这是一个常用的内置方法。

## 三、创建模版

### 1.dashboard.html

在assets目录下创建`templates/assets/dashboard.html`文件，写入下面的代码：

```
{% extends 'base.html' %}
{% load static %}
{% block title %}仪表盘{% endblock %}
{% block css %}{% endblock %}

{% block breadcrumb %}
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        仪表盘
        <small>dashboard</small>
      </h1>
      <ol class="breadcrumb">
        <li><a href="#"><i class="fa fa-dashboard"></i> 主页</a></li>
        <li class="active">仪表盘</li>
      </ol>
    </section>
{% endblock %}

{% block content %}

{% endblock %}

{% block script %}

{% endblock %}
```

### 2.index.html

在assets目录下创建`templates/assets/index.html`文件，写入下面的代码：

```
{% extends 'base.html' %}
{% load static %}
{% block title %}资产总表{% endblock %}

{% block css %}{% endblock %}

{% block breadcrumb %}
<!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        资产总表
        <small>assets list</small>
      </h1>
      <ol class="breadcrumb">
        <li><a href="#"><i class="fa fa-dashboard"></i> 主页</a></li>
        <li class="active">资产总表</li>
      </ol>
    </section>
{% endblock %}

{% block content %}
{% endblock %}


{% block script %}
{% endblock %}
```

### 3.detail.html

在assets目录下创建`templates/assets/detail.html`文件，写入下面的代码：

```
{% extends 'base.html' %}
{% load static %}
{% block title %}资产详细{% endblock %}

{% block css %}

{% endblock %}

{% block breadcrumb %}
<!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        资产详细
        <small>asset info</small>
      </h1>
      <ol class="breadcrumb">
        <li><a href="#"><i class="fa fa-dashboard"></i> 主页</a></li>
        <li>资产总表</li>
        <li class="active">资产详细</li>
      </ol>
    </section>
{% endblock %}

{% block content %}

{% endblock %}

{% block script %}

{% endblock %}
```

以上三个模板都很简单，就是下面的流程：

- extends继承‘base.html’；
- `{% load static %}`载入静态文件；
- `{% block title %}资产详细{% endblock %}`，定制title;
- `{% block css %}`，载入当前页面的专用CSS文件；
- `{% block breadcrumb%}`定制顶部面包屑导航;
- `{% block script %}`，载入当前页面的专用js文件；
- 最后在`{% block content %}`中， 填充页面的主体内容

## 四、访问页面

重启CMDB服务器，访问`http://192.168.0.100:8000/assets/dashboard/`，可以看到下面的页面。

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/125-3.png)

访问`http://192.168.0.100:8000/assets/index/`，可以看到下面的页面：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/125-4.png)

访问`http://192.168.0.100:8000/assets/detail/1/`，可以看到下面的页面(需要已经有了资产对象)：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/125-5.png)

如果你的配色和我的不一样，没关系，都可以调整的，在base.html中有说明注释。

# 10.资产总表

当前，我们的资产总表如下图所示，还没有任何数据：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/126-1.png)

这需要我们从数据库中查询数据，然后渲染到前端页面中。

数据的获取很简单，一句`assets = models.Asset.objects.all()`就搞定。当然，你也可以设置过滤条件，添加分页等等。

而在前端，我们往往需要以表格的形式，规整、美观、可排序的展示出来。这里推荐一个前端插件datatables，是一个非常好的表格插件，功能强大、配置简单。

其官网为：https://datatables.net/ 中文网站：http://datatables.club/

在AdminLTE中，集成了datatables插件，无需额外下载和安装，直接引入使用就可以。

下面给出一个完整的index.html模板代码：

```
{% extends 'base.html' %}
{% load static %}
{% block title %}资产总表{% endblock %}

{% block css %}
 <link rel="stylesheet" href="{% static 'adminlet-2.4.10/bower_components/datatables.net-bs/css/dataTables.bootstrap.min.css' %}">
{% endblock %}

{% block breadcrumb %}
<!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        资产总表
        <small>assets list</small>
      </h1>
      <ol class="breadcrumb">
        <li><a href="#"><i class="fa fa-dashboard"></i> 主页</a></li>
        <li class="active">资产总表</li>
      </ol>
    </section>
{% endblock %}

{% block content %}


    <!-- Main content -->
    <section class="content">
      <div class="row">
        <div class="col-xs-12">

        <div class="box">
        <div class="box-header">
          <h3 class="box-title">资产总表<small>(不含软件)</small></h3>
        </div>
        <!-- /.box-header -->
        <div class="box-body">
          <table id="assets_table" class="table table-bordered table-striped">
            <thead>
            <tr>
              <th>序号</th>
              <th>资产类型</th>
              <th>子类型</th>
              <th>资产名称</th>
              <th>SN</th>
              <th>业务线</th>
              <th>状态</th>
              <th>机房</th>
              <th>更新日期</th>
              <th>标签</th>
            </tr>
            </thead>
            <tbody>

                {% for asset in assets %}
                <tr>
                  <td>{{ forloop.counter }}</td>
                  {% if asset.asset_type == 'server' %}
                      <td class="text-green text-bold">{{ asset.get_asset_type_display }}</td>
                      <td>{{ asset.server.get_sub_asset_type_display }}</td>
                  {% elif asset.asset_type == "networkdevice" %}
                      <td class="text-yellow text-bold">{{ asset.get_asset_type_display }}</td>
                      <td>{{ asset.networkdevice.get_sub_asset_type_display }}</td>
                  {% elif asset.asset_type == "storagedevice" %}
                      <td class="text-blue text-bold">{{ asset.get_asset_type_display }}</td>
                      <td>{{ asset.storagedevice.get_sub_asset_type_display }}</td>
                  {% elif asset.asset_type == "securitydevice" %}
                      <td class="text-red text-bold">{{ asset.get_asset_type_display }}</td>
                      <td>{{ asset.securitydevice.get_sub_asset_type_display }}</td>
                  {% endif %}
                    {% if asset.asset_type == 'server' %}
                        <td><a href="{% url 'assets:detail' asset.id %}">{{ asset.name }}</a></td>
                    {% else %}
                        <td>{{ asset.name }}</td>
                    {% endif %}
                  <td>{{ asset.sn }}</td>
                  <td>{{ asset.business_unit|default_if_none:"-" }}</td>
                    {% if asset.status == 0 %}
                      <td><label class="label label-success">{{ asset.get_status_display }}</label></td>
                    {% elif asset.status == 1 %}
                      <td><label class="label label-warning">{{ asset.get_status_display }}</label></td>
                    {% elif asset.status == 2 %}
                      <td><label class="label label-default">{{ asset.get_status_display }}</label></td>
                    {% elif asset.status == 3 %}
                      <td><label class="label label-danger">{{ asset.get_status_display }}</label></td>
                    {% elif asset.status == 4 %}
                      <td><label class="label label-info">{{ asset.get_status_display }}</label></td>
                    {% endif %}
                  <td>{{ asset.idc|default:"-" }}</td>
                  <td>{{ asset.m_time|date:"Y/m/d [H:m:s]" }}</td>
                  <td>
                      {% for tag in asset.tags.all %}
                        <label class="label label-primary">{{ tag.name }}</label>
                      {% empty %}
                          -
                      {% endfor %}
                  </td>
                </tr>
                {% empty %}
                  <tr>没有数据！</tr>
                {% endfor %}

            </tbody>
            <tfoot>
            <tr>
              <th>序号</th>
              <th>资产类型</th>
              <th>子类型</th>
              <th>资产名称</th>
              <th>SN</th>
              <th>业务线</th>
              <th>状态</th>
              <th>机房</th>
              <th>更新日期</th>
              <th>标签</th>
            </tr>
            </tfoot>
          </table>
        </div>
        <!-- /.box-body -->
      </div>
      <!-- /.box -->
        </div>
    <!-- /.col -->
      </div>
    <!-- /.row -->
    </section>


{% endblock %}


{% block script %}

<script src="{% static 'adminlet-2.4.10/bower_components/datatables.net/js/jquery.dataTables.min.js' %}"></script>
<script src="{% static 'adminlet-2.4.10/bower_components/datatables.net-bs/js/dataTables.bootstrap.min.js' %}"></script>

<script>
$(function () {
        $('#assets_table').DataTable({
          "paging": true,       <!-- 允许分页 -->
          "lengthChange": true, <!-- 允许改变每页显示的行数 -->
          "searching": true,    <!-- 允许内容搜索 -->
          "ordering": true,     <!-- 允许排序 -->
          "info": true,         <!-- 显示信息 -->
          "autoWidth": false    <!-- 固定宽度 -->
        });
      });
</script>


{% endblock %}
```

**首先我们导入了datatables需要的CSS和JS文件。**

主要是新增了表格相关的html代码和初始化表格的js代码。

<table id="assets_table" class="table table-bordered table-striped">中的id属性非常重要，用于关联相应的初始化js代码。

表格中，循环每一个资产：

- 首先生成一个排序的列；
- 再根据资产类型的不同，用不同的颜色生成不同的资产类型名和子类型名；
- 通过`{{ asset.get_asset_type_display }}`的模板语法，拿到资产类型的直观名称，比如‘服务器’，而不是显示呆板的‘server’；
- 通过`{{ asset.server.get_sub_asset_type_display }}`，获取资产对应类型的子类型。这是Django特有的模板语法，非常类似其ORM的语法；
- 在资产名的栏目，增加了超级链接，用于显示资产的详细内容。这里只实现了服务器类型资产的详细页面，其它类型请自行完善。注意其中使用`url`模板标签，实现自动的详细页面url地址生成；
- 根据资产状态的不同，用不同的颜色显示；
- 利用`{{ asset.m_time|date:"Y/m/d [H:m:s]" }}`调整时间的显示格式；
- 由于资产和tas标签属于多对多的关系，所以需要一个循环，遍历每个tas并打印其名称；
- 通过`asset.tags.all`可以获取一个资产对应的多对多字段的全部对象，很类似ORM的做法。

表格的初始化JS代码如下：

```
    <script>
      $(function () {
        $('#assets_table').DataTable({
          "paging": true,       <!-- 允许分页 -->
          "lengthChange": true, <!-- 允许改变每页显示的行数 -->
          "searching": true,    <!-- 允许内容搜索 -->
          "ordering": true,     <!-- 允许排序 -->
          "info": true,         <!-- 显示信息 -->
          "autoWidth": false    <!-- 固定宽度 -->
        });
      });
    </script>
```

其中可定义是否允许分页、改变显示的行数、搜索、排序、显示信息、固定宽度等等，通过表格的id进行关联。

下面，我们通过后台admin界面，多增加几个服务器实例，并修改其子类型、业务线、状态、机房、标签，再刷新资产总表，可以看到效果如下：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/126-2.png)

试着使用一下排序和搜索功能吧！datatables还是相当强大的！

现在点击资产名称，可以链接到资产详细页面，但没有任何数据显示，在下一节中，我们来实现它。

# 11.资产详细页面

在资产的详细页面，我们将尽可能地将所有的信息都显示出来，并保持美观、整齐。

教程中实现了主要的服务器资产页面，对于其它类型的资产详细页面，可参照完成，并不复杂。

完整的detail.html页面代码如下：

```
{% extends 'base.html' %}
{% load static %}
{% block title %}资产详细{% endblock %}

{% block css %}

{% endblock %}

{% block breadcrumb %}
<!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        资产详细
        <small>asset info</small>
      </h1>
      <ol class="breadcrumb">
        <li><a href="#"><i class="fa fa-dashboard"></i> 主页</a></li>
        <li>资产总表</li>
        <li class="active">资产详细</li>
      </ol>
    </section>
{% endblock %}

{% block content %}

    <!-- Main content -->
    <section class="content">

      <!-- Default box -->
      <div class="box">

          <div class="box-header with-border">
          <h3 class="box-title"><strong class="btn btn-block btn-primary btn-lg">资产：{{ asset.name }}</strong></h3>

          <div class="box-tools pull-right">
            <button type="button" class="btn btn-box-tool" data-widget="collapse" data-toggle="tooltip" title="Collapse">
              <i class="fa fa-minus"></i></button>
            <button type="button" class="btn btn-box-tool" data-widget="remove" data-toggle="tooltip" title="Remove">
              <i class="fa fa-times"></i></button>
          </div>
        </div>

          <div class="box-body">
          <h4><b>概览:</b></h4>
            <table border="1" class="table  table-responsive" style="border-left:3px solid deepskyblue;border-bottom:1px solid deepskyblue" >
                <thead>
                    <tr>
                        <th>类型</th>
                        <th>SN</th>
                        <th>业务线</th>
                        <th>制造商</th>
                        <th>管理IP</th>
                        <th>机房</th>
                        <th>标签</th>
                        <th>更新日期</th>
                    </tr>
                </thead>
                <tbody>
                <tr>
                    <td>{{ asset.get_asset_type_display }}</td>
                    <td>{{ asset.sn }}</td>
                    <td>{{ asset.business_unit|default:'N/A' }}</td>
                    <td>{{ asset.manufacturer|default:'N/A' }}</td>
                    <td>{{ asset.manage_ip|default:'N/A' }}</td>
                    <td>{{ asset.idc|default:'N/A' }}</td>
                    <td>
                        {% for tag in asset.tags.all %}
                        <label class="label label-primary">{{ tag.name }}</label>
                        {% empty %}
                            -
                        {% endfor %}
                    </td>
                    <td>{{ asset.m_time }}</td>
                </tr>
                </tbody>
            </table>
            <br />
            <table border="1" class="table  table-responsive" style="border-left:3px solid deepskyblue;border-bottom:1px solid deepskyblue">
                <thead>
                    <tr>
                        <th>合同</th>
                        <th>价格</th>
                        <th>购买日期</th>
                        <th>过保日期</th>
                        <th>管理员</th>
                        <th>批准人</th>
                        <th>备注</th>
                        <th>批准日期</th>
                    </tr>
                </thead>
                <tbody>
                <tr>
                    <td>{{ asset.contract.name|default:'N/A' }}</td>
                    <td>{{ asset.price|default:'N/A' }}</td>
                    <td>{{ asset.purchase_day|default:'N/A' }}</td>
                    <td>{{ asset.expire_day|default:'N/A' }}</td>
                    <td>{{ asset.admin|default:'N/A' }}</td>
                    <td>{{ asset.approved_by|default:'N/A' }}</td>
                    <td>{{ asset.memo|default:'N/A' }}</td>
                    <td>{{ asset.m_time }}</td>
                </tr>
                </tbody>
            </table>
          <h4><b>服务器:</b></h4>
            <table border="1" class="table  table-responsive" style="border-left:3px solid green;border-bottom:1px solid green">
                <thead>
                    <tr>
                        <th>服务器类型</th>
                        <th>型号</th>
                        <th>宿主机</th>
                        <th>Raid类型</th>
                        <th>OS类型</th>
                        <th>OS发行版本</th>
                        <th>OS版本</th>
                        <th>添加方式</th>
                    </tr>
                </thead>
                <tbody>
                <tr>
                    <td>{{ asset.server.get_sub_asset_type_display }}</td>
                    <td>{{ asset.server.model|default:'N/A' }}</td>
                    <td>{{ asset.server.hosted_on.id|default:'N/A' }}</td>
                    <td>{{ asset.server.raid_type|default:'N/A' }}</td>
                    <td>{{ asset.server.os_type|default:'N/A' }}</td>
                    <td>{{ asset.server.os_distribution|default:'N/A' }}</td>
                    <td>{{ asset.server.os_release|default:'N/A' }}</td>
                    <td>{{ asset.server.get_created_by_display }}</td>
                </tr>
                </tbody>
            </table>
        <h4><b>CPU:</b></h4>
            <table border="1" class="table  table-responsive" style="border-left:3px solid purple;border-bottom:1px solid purple">
                <thead>
                    <tr>
                        <th  style="width: 45%">CPU型号</th>
                        <th  style="width: 15%">物理CPU个数</th>
                        <th>CPU核数</th>
                    </tr>
                </thead>
                <tbody>
                <tr>
                    <td>{{ asset.cpu.cpu_model|default:'N/A' }}</td>
                    <td>{{ asset.cpu.cpu_count|default:'1' }}</td>
                    <td>{{ asset.cpu.cpu_core_count|default:'1' }}</td>
                </tr>
                </tbody>
            </table>
        <h4><b>内存:</b></h4>
        <table border="1" class="table  table-responsive" style="border-left:3px solid orangered;border-bottom:1px solid orangered">
                <thead>
                    <tr>
                        <th style="width:5%;">序号</th>
                        <th>型号</th>
                        <th>容量</th>
                        <th>插槽</th>
                        <th>制造商</th>
                        <th>SN</th>
                    </tr>
                </thead>
                <tbody>
                {% for ram in asset.ram_set.all %}
                    <tr>
                        <td>{{ forloop.counter }}</td>
                        <td>{{ ram.model|default:'N/A' }}</td>
                        <td>{{ ram.capacity|default:'N/A' }}</td>
                        <td>{{ ram.slot }}</td>
                        <td>{{ ram.manufacturer|default:'N/A' }}</td>
                        <td>{{ ram.sn|default:'N/A' }}</td>
                    </tr>
                {% empty %}
                    <tr>
                        <td></td><td></td><td></td><td></td><td></td><td></td>
                    </tr>
                {% endfor %}
                </tbody>
            </table>
        <h4><b>硬盘:</b></h4>
        <table border="1" class="table  table-responsive" style="border-left:3px solid brown;border-bottom:1px solid brown">
                <thead>
                    <tr>
                        <th style="width:5%;">序号</th>
                        <th>型号</th>
                        <th>容量</th>
                        <th>插槽</th>
                        <th>接口类型</th>
                        <th>制造商</th>
                        <th>SN</th>
                    </tr>
                </thead>
                <tbody>
                {% for disk in asset.disk_set.all %}
                    <tr>
                        <td>{{ forloop.counter }}</td>
                        <td>{{ disk.model|default:'N/A' }}</td>
                        <td>{{ disk.capacity|default:'N/A' }}</td>
                        <td>{{ disk.slot|default:'N/A'  }}</td>
                        <td>{{ disk.get_interface_type_display }}</td>
                        <td>{{ disk.manufacturer|default:'N/A' }}</td>
                        <td>{{ disk.sn}}</td>
                    </tr>
                {% empty %}
                    <tr>
                        <td></td><td></td><td></td><td></td><td></td><td></td><td></td>
                    </tr>
                {% endfor %}
                </tbody>
            </table>
        <h4><b>网卡:</b></h4>
        <table border="1" class="table  table-responsive" style="border-left:3px solid #a59b1a;border-bottom:1px solid #a59b1a">
                <thead>
                    <tr>
                        <th style="width:5%;">序号</th>
                        <th>名称</th>
                        <th>型号</th>
                        <th>MAC</th>
                        <th>IP</th>
                        <th>掩码</th>
                        <th>绑定地址</th>
                    </tr>
                </thead>
                <tbody>
                {% for nic in asset.nic_set.all %}
                    <tr>
                        <td>{{ forloop.counter }}</td>
                        <td>{{ nic.name|default:'N/A' }}</td>
                        <td>{{ nic.model }}</td>
                        <td>{{ nic.mac  }}</td>
                        <td>{{ nic.ip_address|default:'N/A' }}</td>
                        <td>{{ nic.net_mask|default:'N/A' }}</td>
                        <td>{{ nic.bonding|default:'N/A' }}</td>
                    </tr>
                {% empty %}
                    <tr>
                        <td></td><td></td><td></td><td></td><td></td><td></td><td></td>
                    </tr>
                {% endfor %}
                </tbody>
            </table>

        </div>
        <!-- /.box-body -->
        <div class="box-footer">
          <i class="fa fa-angle-double-left"></i>&nbsp;&nbsp;<a href="{% url 'assets:index' %}"><strong>返回资产列表页</strong></a>
        </div>
        <!-- /.box-footer-->
      </div>
      <!-- /.box -->

    </section>
    <!-- /.content -->

{% endblock %}

{% block script %}

{% endblock %}
```

主要代码全部集中在``里，分别用几个表格将概览、服务器、CPU、内存、硬盘和网卡的信息展示出来了。并且，AdminLTE为我们提供了一个折叠的功能，也是非常酷的。

这个HTML文件没有太多需要额外解释的内容，都是一些很基础的模板语言，构造``，然后插入数据。如果没有数据，就以‘N/A’代替。最后在底部添加一个返回资产总表的链接。

下面是展示图：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/127-1.png)

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/127-2.png)

# 12.dashboard仪表盘

对于运维管理平台，一个总览的dashboard仪表盘界面是必须有的，不但提升整体格调，也有利于向老板‘邀功请赏’。

dashboard页面必须酷炫吊炸天，所以界面元素应当美观、丰富、富有冲击力。

完整的dashboard.html文件代码如下：

```
{% extends 'base.html' %}
{% load static %}
{% block title %}仪表盘{% endblock %}
{% block css %}{% endblock %}

{% block breadcrumb %}
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        仪表盘
        <small>dashboard</small>
      </h1>
      <ol class="breadcrumb">
        <li><a href="#"><i class="fa fa-dashboard"></i> 主页</a></li>
        <li class="active">仪表盘</li>
      </ol>
    </section>
{% endblock %}

{% block content %}

      <!-- Main content -->
    <section class="content">
    <div class="row">
        <!-- row -->
        <div class="col-md-12">
          <!-- jQuery Knob -->
          <div class="box box-solid">
            <div class="box-header">
              <i class="fa fa-bar-chart-o"></i>

              <h3 class="box-title">设备状态<small>(%)</small></h3>

              <div class="box-tools pull-right">
                <button type="button" class="btn btn-default btn-sm" data-widget="collapse"><i class="fa fa-minus"></i>
                </button>
                <button type="button" class="btn btn-default btn-sm" data-widget="remove"><i class="fa fa-times"></i>
                </button>
              </div>
            </div>
            <!-- /.box-header -->
            <div class="box-body">
              <div class="row">
                <div class="col-xs-6 col-md-2 col-md-offset-1 text-center">
                  <input type="text" class="knob" value="{{ up_rate }}" data-width="90" data-height="90" data-fgColor="#00a65a" data-readonly="true">

                  <div class="knob-label">在线</div>
                </div>
                <!-- ./col -->
                <div class="col-xs-6 col-md-2 text-center">
                  <input type="text" class="knob" value="{{ o_rate }}" data-width="90" data-height="90" data-fgColor="#f56954" data-readonly="true">

                  <div class="knob-label">下线</div>
                </div>
                <!-- ./col -->


                <div class="col-xs-6 col-md-2 text-center">
                  <input type="text" class="knob" value="{{ bd_rate }}" data-width="90" data-height="90" data-fgColor="#932ab6" data-readonly="true">

                  <div class="knob-label">故障</div>
                </div>
                <!-- ./col -->
                <div class="col-xs-6 col-md-2 text-center">
                  <input type="text" class="knob" value="{{ bu_rate }}" data-width="90" data-height="90" data-fgColor="#3c8dbc" data-readonly="true">

                  <div class="knob-label">备用</div>
                </div>
                  <!-- ./col -->
                <div class="col-xs-6 col-md-2 text-center">
                  <input type="text" class="knob" value="{{ un_rate }}" data-width="90" data-height="90" data-fgColor="#cccccc" data-readonly="true">

                  <div class="knob-label">未知</div>
                </div>
                <!-- ./col -->
              </div>
              <!-- /.row -->
            </div>
            <!-- /.box-body -->
          </div>
          <!-- /.box -->
        </div>
        <!-- /.col -->


        <div class="col-md-6">
            <!-- BAR CHART -->
          <div class="box box-success">

            <div class="box-header with-border">
              <h3 class="box-title">各状态资产数量统计：</h3>

              <div class="box-tools pull-right">
                <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>
                </button>
                <button type="button" class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button>
              </div>
            </div>
            <div class="box-body">
                {# 百度Echarts实现柱状图#}
                <div id="barChart" style="width: 600px;height:400px;"></div>
            </div>
            <!-- /.box-body -->
          </div>
        </div>



        <div class="col-md-6">
          <!-- DONUT CHART -->
          <div class="box box-danger">
            <div class="box-header with-border">
              <h3 class="box-title">各类型资产数量统计：</h3>

              <div class="box-tools pull-right">
                <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>
                </button>
                <button type="button" class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button>
              </div>
            </div>
            <div class="box-body">
                {# 百度Echarts实现饼状图#}
              <div id="donutChart" style="width: 600px;height:400px;"></div>
            </div>
            <!-- /.box-body -->
          </div>
          <!-- /.box -->
        </div>
        <!-- /.col (RIGHT) -->
      </div>
      <!-- /.row -->

    </section>
    <!-- /.content -->

{% endblock %}

{% block script %}

    <script src="https://cdn.bootcss.com/echarts/4.2.1/echarts.min.js"></script>
    <!-- AdminLTE App -->
    <script src="{% static 'adminlet-2.4.10/bower_components/jquery-knob/js/jquery.knob.js' %}"></script>
    <!-- page script -->

    <script type="text/javascript">

    // 顶部服务器状态百分率圆图
    $(function () {
        /* jQueryKnob */

        $(".knob").knob({
             /*change : function (value) {
       //console.log("change : " + value);
       },
       release : function (value) {
       console.log("release : " + value);
       },
       cancel : function () {
       console.log("cancel : " + this.value);
       },*/
      draw: function () {
             // "tron" case
        if (this.$.data('skin') == 'tron'
                ) {

          var a = this.angle(this.

                    cv)  // Angle
              , sa = this.
                            startAngle          // Previous start angle
              , sat = this.startAngle         // Start angle
              , ea                            // Previous end angle
              , eat = sat + a                 // End angle
              , r = true;

          this.g.lineWidth = this.lineWidth;

          this.o.cursor
          && (sat = eat - 0.3)
          && (eat = eat + 0.3);

          if (this.o.displayPrevious) {
            ea = this.startAngle + this.angle(this.value);
            this.o.cursor
            && (sa = ea - 0.3)
            && (ea = ea + 0.3);
            this.g.beginPath();
            this.g.strokeStyle = this.previousColor;
            this.g.arc(this.xy, this.xy, this.radius - this.lineWidth, sa, ea, false);
            this.g.stroke();
          }

          this.g.beginPath();
          this.g.strokeStyle = r ? this.o.fgColor : this.fgColor;
          this.g.arc(this.xy, this.xy, this.radius - this.lineWidth, sat, eat, false);
          this.g.stroke();

          this.g.lineWidth = 2;
          this.g.beginPath();
          this.g.strokeStyle = this.o.fgColor;
          this.g.arc(this.xy, this.xy, this.radius - this.lineWidth + 1 + this.lineWidth * 2 / 3, 0, 2 * Math.PI, false);
          this.g.stroke();

          return false;
        }
      }
    });
    /* END JQUERY KNOB */
    });

    //不同状态资产数量统计 柱状图
    $(function () {
        // 基于准备好的dom，初始化echarts实例
        var myChart = echarts.init(document.getElementById('barChart'));

        // 指定图表的配置项和数据
        var option = {
            color: ['#3398DB'],
            title: {
                text: '数量'
            },
            tooltip: {},
            legend: { data:['']
            },
            xAxis: {
                data: ["在线", "下线","故障","备用","未知"] },
            yAxis: {
            },
            series:
                [{
                name: '数量',
                type: 'bar',
                barWidth: '50%',
                data: [{{ upline }}, {{ offline }}, {{ breakdown }}, {{ backup }}, {{ unknown }}]
            }]
        };
            // 使用刚指定的配置项和数据显示图表。
            myChart.setOption(option);
    });

    //资产类型数量统计 饼图
    $(function () {
        // 基于准备好的dom，初始化echarts实例
        var myChart = echarts.init(document.getElementById('donutChart'));

        // 指定图表的配置项和数据
        option = {
            title : {
                x:'center'
            },
            tooltip : {
                trigger: 'item',
                formatter: "{a} <br/>{b} : {c} ({d}%)"
            },
            legend: {
                orient: 'vertical',
                left: 'left',
                data: ['服务器','网络设备','存储设备','安全设备','软件资产']
            },
            series : [
                {
                    name: '资产类型',
                    type: 'pie',
                    radius : '55%',
                    center: ['50%', '60%'],
                    data:[
                        {value:{{ server_number }}, name:'服务器'},
                        {value:{{ networkdevice_number }}, name:'网络设备'},
                        {value:{{ storagedevice_number }}, name:'存储设备'},
                        {value:{{ securitydevice_number }}, name:'安全设备'},
                        {value:{{ software_number }}, name:'软件资产'}
                    ],
                    itemStyle: {
                        emphasis: {
                            shadowBlur: 10,
                            shadowOffsetX: 0,
                            shadowColor: 'rgba(0, 0, 0, 0.5)'
                        }
                    }
                }
            ]
        };
            // 使用刚指定的配置项和数据显示图表。
            myChart.setOption(option);
    });

    </script>

{% endblock %}
```

## 一、资产状态占比图

首先，制作一个资产状态百分比表盘，用于显示上线、下线、未知、故障和备用五种资产在总资产中的占比。**注意是占比，不是数量！**

按照AdminLTE中提供的示例，在HTML中添加相应的标签，在script中添加相应的JS代码（jQueryKnob）。JS代码基本照抄，不需要改动。对于显示的圆圈，可以修改其颜色、大小、形态、是否只读等属性，可以参照AdminLTE中的范例。

最重要的是，需要从数据库中获取相应的数据，修改`assets/views.py`中的dashboard视图，最终如下：

```
def dashboard(request):
    total = models.Asset.objects.count()
    upline = models.Asset.objects.filter(status=0).count()
    offline = models.Asset.objects.filter(status=1).count()
    unknown = models.Asset.objects.filter(status=2).count()
    breakdown = models.Asset.objects.filter(status=3).count()
    backup = models.Asset.objects.filter(status=4).count()
    up_rate = round(upline/total*100)
    o_rate = round(offline/total*100)
    un_rate = round(unknown/total*100)
    bd_rate = round(breakdown/total*100)
    bu_rate = round(backup/total*100)
    server_number = models.Server.objects.count()
    networkdevice_number = models.NetworkDevice.objects.count()
    storagedevice_number = models.StorageDevice.objects.count()
    securitydevice_number = models.SecurityDevice.objects.count()
    software_number = models.Software.objects.count()

    return render(request, 'assets/dashboard.html', locals())
```

代码很简单，分别获取资产总数量，上线、下线、未知、故障和备用资产的数量，然后计算出各自的占比，例如上线率`up_rate`。同时获取服务器、网络设备、安全设备和软件设备的数量，后面需要使用。

在dashboard.html中修改各input框的value属性为`value="{{ up_rate }}"`（以上线率为例），这是最关键的步骤，前端会根据这个值的大小，决定圆圈的幅度。

完成后的页面如下图所示：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/128-1.png)

## 二、不同状态资产数量统计柱状图

要绘制柱状图，不可能我们自己一步步从无到有写起，建议使用第三方插件。AdminLTE中内置的是Chartjs插件，但更建议大家使用百度开源的Echarts插件，功能更强大，更容易学习。

百度Echarts的网址是：http://echarts.baidu.com/，提供插件下载、说明文档和在线帮助。

这里，我们使用CDN的方式，直接引用Echarts：

```
<script src="https://cdn.bootcss.com/echarts/4.2.1/echarts.min.js"></script>
```

使用Echarts的柱状图很简单，首先生成一个用于放置图形的容器：

```
<div class="col-md-6">
    <!-- BAR CHART -->
  <div class="box box-success">

    <div class="box-header with-border">
      <h3 class="box-title">各状态资产数量统计：</h3>

      <div class="box-tools pull-right">
        <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>
        </button>
        <button type="button" class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button>
      </div>
    </div>
    <div class="box-body">
        <div id="barChart" style="width: 600px;height:400px;"></div>
    </div>
    <!-- /.box-body -->
  </div>
</div>
```

上面的核心是``这句，它指明了图表的id和容器大小。其它的都是AdminLTE框架需要的元素，用于生成表头和折叠、关闭动作按钮。我们的容器是可以折叠和删除的，也是移动端自适应的。

构造了容器后，在``中，添加初始化的js代码：

```
$(function () {
        // 基于准备好的dom，初始化echarts实例
        var myChart = echarts.init(document.getElementById('barChart'));

        // 指定图表的配置项和数据
        var option = {
            color: ['#3398DB'],
            title: {
                text: '数量'
            },
            tooltip: {},
            legend: { data:['']
            },
            xAxis: {
                data: ["在线", "下线","故障","备用","未知"] },
            yAxis: {},
            series:
                [{
                name: '数量',
                type: 'bar',
                barWidth: '50%',
                data: [{{ upline }}, {{ offline }}, {{ breakdown }}, {{ backup }}, {{ unknown }}]
            }]
        };
            // 使用刚指定的配置项和数据显示图表。
            myChart.setOption(option);
    });
```

上面的js代码中，中文文字部分很容易理解，就是x轴的说明文字。还可以设置柱状图的颜色、宽度等特性。关键是series列表，其中的type指定该图表是什么类型，bar表示柱状图，而data就是至关重要的具体数据了，利用模板语言，将从数据库中获取的具体数值传入进来，Echarts插件会根据数值进行动态调整。

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/128-2.png)

## 三、各类型资产数量统计饼图

类似上面的柱状图，在HTML中需要先添加一个容器。不同之处在于初始化的JS代码：

```
//资产类型数量统计 饼图
    $(function () {
        // 基于准备好的dom，初始化echarts实例
        var myChart = echarts.init(document.getElementById('donutChart'));

        // 指定图表的配置项和数据
        option = {
            title : {
                x:'center'
            },
            tooltip : {
                trigger: 'item',
                formatter: "{a} <br/>{b} : {c} ({d}%)"
            },
            legend: {
                orient: 'vertical',
                left: 'left',
                data: ['服务器','网络设备','存储设备','安全设备','软件资产']
            },
            series : [
                {
                    name: '资产类型',
                    type: 'pie',
                    radius : '55%',
                    center: ['50%', '60%'],
                    data:[
                        {value:{{ server_number }}, name:'服务器'},
                        {value:{{ networkdevice_number }}, name:'网络设备'},
                        {value:{{ storagedevice_number }}, name:'存储设备'},
                        {value:{{ securitydevice_number }}, name:'安全设备'},
                        {value:{{ software_number }}, name:'软件资产'}
                    ],
                    itemStyle: {
                        emphasis: {
                            shadowBlur: 10,
                            shadowOffsetX: 0,
                            shadowColor: 'rgba(0, 0, 0, 0.5)'
                        }
                    }
                }
            ]
        };
            // 使用刚指定的配置项和数据显示图表。
            myChart.setOption(option);
    });
```

series中的type指定为pie，表示饼图，data列表动态传入各种资产类型的数量。其它的设置可参考官方文档。

为了展示的方便，我们在admin中新建一些网络设备、安全设备、软件资产等其它类型的资产，然后查看资产总表和饼图。

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/128-3.png)

查看dashboard如下图所示：

![image](%E5%AE%9E%E6%88%98%E4%BA%8C%EF%BC%9ADjango2.2%E4%B9%8BCMDB%E8%B5%84%E4%BA%A7%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F.assets/128-4.png)

## 四、项目总结

至此，CMDB项目就基本讲解完毕。

还是要强调的是，这是一个教学版，很多内容和细节没有实现，必然存在bug和不足。但不管怎么样，它至少包含CMDB资产管理的主体内容，如果你能从中有点收获，那么教程的目的就达到了。

项目的整体代码托管在GitHub上，地址如下：

https://github.com/feixuelove1009/CMDB