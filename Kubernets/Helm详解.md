# HELM

# 基本概念

helm 类似于Linux系统下的包管理器，如yum/apt等，可以方便快捷的将之前打包好的yaml文件快速部署进kubernetes内，方便管理维护。

- helm：一个命令行下客户端工具，主要用于kubernetes应用chart的创建/打包/发布已经创建和管理和远程Chart仓库。
- Tiller：helm的服务端，部署于kubernetes内，Tiller接受helm的请求，并根据chart生成kubernetes部署文件（helm称为release），然后提交给 Kubernetes 创建应用。Tiller 还提供了 Release 的升级、删除、回滚等一系列功能。
- Chart： helm的软件包，采用tar格式，其中包含运行一个应用所需的`所有镜像/依赖/资源定义`等，还可能包含kubernetes集群中服务定义
- Release：在kubernetes中集群中运行的一个Chart实例，在同一个集群上，一个Chart可以安装多次，每次安装均会生成一个新的release。
- Repository：用于发布和存储Chart的仓库

简单来说：

- helm的作用：像centos7中的yum命令一样，管理软件包，只不过helm这儿管理的是在k8s上安装的各种容器。
- tiller的作用：像centos7的软件仓库一样，简单说类似于/etc/yum.repos.d目录下的xxx.repo。

# 组件架构



![img](Helm%E8%AF%A6%E8%A7%A3.assets/16cada288ee25884)



# 工作原理

## Chart install

- helm从制定目录或tar文件解析chart结构信息
- helm将制定的chart结构和value信息通过gRPC协议传递给tiller
- tiller根据chart和values生成一个release
- tiller通过json将release发送给kubernetes，生成release

## Chart update

- helm从制定的目录或tar文件解析chart结构信息
- helm将制定的chart结构和value信息通过gRPC协议传给tiller
- tiller生成release并更新制定名称的release的history
- tiller将release信息发送给kubernetes用于更新release

## Chart Rollback

- helm将会滚的release名称传递给tiller
- tiller根据release名称查找history
- tiller从history中获取到上一个release
- tiller将上一个release发送给kubernetes用于替换当前release

## Chart处理依赖

Tiller 在处理 Chart 时，直接将 Chart 以及其依赖的所有 Charts 合并为一个 Release，同时传递给 Kubernetes。因此 Tiller 并不负责管理依赖之间的启动顺序。Chart 中的应用需要能够自行处理依赖关系。

# 安装部署

## v2版本安装

### 安装helm

```
# 在helm客户端主机上，一般为master主机
wget https://get.helm.sh/helm-v2.14.2-linux-amd64.tar.gz
tar xf helm-v2.14.2-linux-amd64.tar.gz
mv helm /usr/local/bin/
helm version
```

### 初始化tiller

- 初始化tiller会自动读取`~/.kube`目录，所以需要确保config文件存在并认证成功
- tiller配置rbac，新建rabc-config.yaml并应用

```
# 在：https://github.com/helm/helm/blob/master/docs/rbac.md 可以找到rbac-config.yaml

cat > rbac-config.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF

kubectl apply -f rbac-config.yaml
```

- 制定镜像

```
docker pull jessestuart/tiller:v2.14.2

yum install socat

# yum install socat

docker tag jessestuart/tiller:v2.14.2 gcr.io/kubernetes-helm/tiller:v2.14.2

helm init -i gcr.io/kubernetes-helm/tiller:v2.9.0

# 需要注意点参数
–client-only：也就是不安装服务端应用，这在 CI&CD 中可能需要，因为通常你已经在 k8s 集群中安装好应用了，这时只需初始化 helm 客户端即可；
–history-max：最大历史，当你用 helm 安装应用的时候，helm 会在所在的 namespace 中创建一份安装记录，随着更新次数增加，这份记录会越来越多；
–tiller-namespace：默认是 kube-system，你也可以设置为其它 namespace；
```

- 修改镜像

```
# 由于gfw原因，可以利用此镜像https://hub.docker.com/r/jessestuart/tiller/tags
kubectl edit deployment -n kube-system tiller-deploy

image: jessestuart/tiller:v2.14.0
```

- 异常处理

```
Error: Looks like "https://kubernetes-charts.storage.googleapis.com" is not a valid chart repository or cannot be reached: Get https://kubernetes-charts.storage.googleapis.com/index.yaml: read tcp 10.2.8.44:49020->216.58.220.208:443: read: connection reset by peer

解决方案：更换源：helm repo add stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

然后在helm init


注意：tiller可能运行在node节点，将tiller镜像下载到node节点并修改tag
```

- 查看版本

```
[root@master ~]# helm version
Client: &version.Version{SemVer:"v2.14.2", GitCommit:"a8b13cc5ab6a7dbef0a58f5061bcc7c0c61598e7", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.14.2+unreleased", GitCommit:"d953c6875cfd4b351a1e8205081ea8aabad7e7d4", GitTreeState:"dirty"}
复制代码
```

## helm3 安装部署

由于国外很多镜像网站国内无法访问，例如[gcr.io ](http://gcr.io/)，建议使用阿里源，[developer.aliyun.com/hub。](https://developer.aliyun.com/hub。)

AppHub 是一个托管在国内公有云上、全公益性的 Helm Hub “中国站”，它的后端由阿里云容器平台团队的三位工程师利用 20% 时间开发完成。

而这个站点的一个重要职责，就是把所有 Helm 官方 Hub 托管的应用自动同步到国内；同时，自动将 Charts 文件中的 [gcr.io ](http://gcr.io/)等所有有网络访问问题的 URL 替换成为稳定的国内镜像 URL。

目前helm3已经不依赖于tiller，Release 名称可在不同 ns 间重用。

### 安装helm

Helm3 不需要安装tiller，下载到 Helm 二进制文件直接解压到 $PATH 下就可以使用了。

```
cd /opt && wget https://cloudnativeapphub.oss-cn-hangzhou.aliyuncs.com/helm-v3.0.0-alpha.1-linux-amd64.tar.gz

tar -xvf helm-v3.0.0-alpha.1-linux-amd64.tar.gz

mv linux-amd64 helm3

mv helm3/helm helm3/helm3

chown root.root helm3 -R

cat > /etc/profile.d/helm3.sh << EOF
export PATH=$PATH:/opt/helm3
EOF

source /etc/profile.d/helm3.sh


[root@master helm3]# helm3 version
version.BuildInfo{Version:"v3.0.0-alpha.1", GitCommit:"b9a54967f838723fe241172a6b94d18caf8bcdca", GitTreeState:"clean"}
```

### 使用helm3安装应用

```
helm3 init
helm3 repo add apphub https://apphub.aliyuncs.com
helm3 search guestbook
helm3 install guestbook apphub/guestbook
```

# 使用

## 基础命令

```shell
http://hub.kubeapps.com/

completion 	# 为指定的shell生成自动完成脚本（bash或zsh）
create     	# 创建一个具有给定名称的新 chart
delete     	# 从 Kubernetes 删除指定名称的 release
dependency 	# 管理 chart 的依赖关系
fetch      	# 从存储库下载 chart 并（可选）将其解压缩到本地目录中
get        	# 下载一个命名 release
help       	# 列出所有帮助信息
history    	# 获取 release 历史
home       	# 显示 HELM_HOME 的位置
init       	# 在客户端和服务器上初始化Helm
inspect    	# 检查 chart 详细信息
install    	# 安装 chart 存档
lint       	# 对 chart 进行语法检查
list       	# releases 列表
package    	# 将 chart 目录打包成 chart 档案
plugin     	# 添加列表或删除 helm 插件
repo       	# 添加列表删除更新和索引 chart 存储库
reset      	# 从集群中卸载 Tiller
rollback   	# 将版本回滚到以前的版本
search     	# 在 chart 存储库中搜索关键字
serve      	# 启动本地http网络服务器
status     	# 显示指定 release 的状态
template   	# 本地渲染模板
test       	# 测试一个 release
upgrade    	# 升级一个 release
verify     	# 验证给定路径上的 chart 是否已签名且有效
version    	# 打印客户端/服务器版本信息
dep         # 分析 Chart 并下载依赖
```

- 指定value.yaml部署一个chart

```
helm install --name els1 -f values.yaml stable/elasticsearch
```

- 升级一个chart

```
helm upgrade --set mysqlRootPassword=passwd db-mysql stable/mysql

helm upgrade go2cloud-api-doc go2cloud-api-doc/ 
```

- 回滚一个 chart

```
helm rollback db-mysql 1
```

- 删除一个 release

```
helm delete --purge db-mysql
```

- 只对模板进行渲染然后输出，不进行安装

```
helm install/upgrade xxx --dry-run --debug
```

## Chart文件组织

```shell
myapp/                               # Chart 目录
├── charts                           # 这个 charts 依赖的其他 charts，始终被安装
├── Chart.yaml                       # 描述这个 Chart 的相关信息、包括名字、描述信息、版本等
├── templates                        # 模板目录
│   ├── deployment.yaml              # deployment 控制器的 Go 模板文件
│   ├── _helpers.tpl                 # 以 _ 开头的文件不会部署到 k8s 上，可用于定制通用信息
│   ├── ingress.yaml                 # ingress 的模板文件
│   ├── NOTES.txt                    # Chart 部署到集群后的一些信息，例如：如何使用、列出缺省值
│   ├── service.yaml                 # service 的 Go 模板文件
│   └── tests
│       └── test-connection.yaml
└── values.yaml                      # 模板的值文件，这些值会在安装时应用到 GO 模板生成部署文件
```

## 新建自己的Chart

- 创建自己的mychart

```
[root@master mychart]# helm create mychart
Creating mychart
[root@master mychart]# ls
mychart
[root@master mychart]# tree mychart/
mychart/
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml						# 部署相关资源
│   ├── _helpers.tpl							# 模版助手
│   ├── ingress.yaml							# ingress资源
│   ├── NOTES.txt									# chart的帮助文本，运行helm install展示给用户
│   ├── service.yaml							# service端点
│   └── tests
│       └── test-connection.yaml
└── values.yaml

3 directories, 8 files
```

- 删除template下的所有文件，并创建configmap

```
rm -rf mychart/templates/*
# 我们首先创建一个名为 mychart/templates/configmap.yaml：

apiVersion: v1
kind: ConfigMap
metadata:
  name: mychart-configmap
data:
  myvalue: "Hello World"
```

- 安装测试

由于创建的yaml文件在template下，tiller读取此文件，会将其发送给kubernetes。

```
[root@centos708 mychart]# helm install ./mychart/ --generate-name
NAME: mychart-1576220703
LAST DEPLOYED: 2019-12-13 02:05:03.59526337 -0500 EST m=+0.246081546
NAMESPACE: default
STATUS: deployed

[root@centos708 mychart]# kubectl get cm mychart-configmap
NAME                DATA   AGE
mychart-configmap   1      103s

[root@centos708 mychart]# kubectl describe cm mychart-configmap
Name:         mychart-configmap
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
myvalue:
----
hello world
Events:  <none>

[root@master mychart]# helm get manifest enervated-dolphin

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mychart-configmap
data:
  myvalue: "this is my chart configmap"
```

该 `helm get manifest` 命令获取 release 名称（enervated-dolphin）并打印出上传到服务器的所有 Kubernetes 资源。每个文件都以 `---` 开始作为 YAML 文档的开始，然后是一个自动生成的注释行，告诉我们该模板文件生成的这个 YAML 文档。

从那里开始，我们可以看到 YAML 数据正是我们在我们的 `configmap.yaml` 文件中所设计的 。

现在我们可以删除我们的 release：`helm delete enervated-dolphin`。

```
[root@master mychart]# helm delete enervated-dolphin
release "enervated-dolphin" deleted
```

## 添加模版调用

硬编码 `name:` 成资源通常被认为是不好的做法。名称应该是唯一的一个版本。所以我们可能希望通过插入 release 名称来生成一个名称字段。

**提示：** name: 由于 DNS 系统的限制，该字段限制为 63 个字符。因此，release 名称限制为 53 个字符。Kubernetes 1.3 及更早版本仅限于 24 个字符（即 14 个字符名称）。

修改下之前的configmap为如下内容

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
```

`name:` 现在这个值发生了变化成了 `{{.Release.Name}}-configmap`。

模板指令包含在 `{{` 和 `}}` 块中。

模板指令 `{{.Release.Name}}` 将 release 名称注入模板。传递给模板的值可以认为是 namespace 对象，其中 dot（.）分隔每个 namespace 元素。

Release 前面的前一个小圆点表示我们从这个范围的最上面的 namespace 开始（我们将稍微谈一下 scope）。所以我们可以这样理解 `.Release.Name：`"从顶层命名空间开始，找到 Release 对象，然后在里面查找名为 `Name` 的对象"。

该 Release 对象是 Helm 的内置对象之一，稍后我们将更深入地介绍它。但就目前而言，这足以说明这会显示 Tiller 分配给我们发布的 release 名称。

现在，当我们安装我们的资源时，我们会立即看到使用这个模板指令的结果：

```
[root@master mychart]# helm install ./mychart/
NAME:   famous-peahen
LAST DEPLOYED: Sun Jul 21 09:42:05 2019
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                    DATA  AGE
famous-peahen-confgmap  1     0s


[root@master mychart]# helm get manifest famous-peahen

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: famous-peahen-confgmap
data:
  myvalue: "this is my chart configmap"
```

我们看过了基础的模板：YAML 文件嵌入了模板指令，通过 。在下一部分中，我们将深入研究模板。但在继续之前，有一个快速技巧可以使构建模板更快：当您想测试模板渲染，但实际上没有安装任何东西时，可以使用 `helm install --debug --dry-run ./mychart`。这会将 chart 发送到 Tiller 服务器，它将渲染模板。但不是安装 chart，它会将渲染模板返回，以便可以看到输出：

## 内置对象

[helm内部变量](https://helm.sh/docs/chart_template_guide/#built-in-objects)

对象从模板引擎传递到模板中。你的代码可以传递对象（我们将在说明 `with` 和 `range` 语句时看到示例）。甚至有几种方法在模板中创建新对象，就像我们稍后会看的 `tuple` 函数一样。

对象可以很简单，只有一个值。或者他们可以包含其他对象或函数。例如，`Release` 对象包含多个对象（如 `Release.Name`）并且 `Files` 对象具有一些函数。

在上一节中，我们使用 `{{.Release.Name}}` 将 release 的名称插入到模板中。`Release` 是可以在模板中访问的顶级对象之一。

- `Release`：这个对象描述了 release 本身。它里面有几个对象：
- `Release.Name`：release 名称
- `Release.Time`：release 的时间
- `Release.Namespace`：release 的 namespace（如果清单未覆盖）
- `Release.Service`：release 服务的名称（始终是 `Tiller`）。
- `Release.Revision`：此 release 的修订版本号。它从 1 开始，每 `helm upgrade` 一次增加一个。
- `Release.IsUpgrade`：如果当前操作是升级或回滚，则将其设置为 `true`。
- `Release.IsInstall`：如果当前操作是安装，则设置为 `true`。
- `Values`：从 `values.yaml` 文件和用户提供的文件传入模板的值。默认情况下，Values 是空的。
- `Chart`：`Chart.yaml` 文件的内容。任何数据 Chart.yaml 将在这里访问。例如 {{.Chart.Name}}-{{.Chart.Version}} 将打印出来 mychart-0.1.0。chart 指南中 [Charts Guide](https://github.com/kubernetes/helm/blob/master/docs/charts.md#the-chartyaml-file) 列出了可用字段
- `Files`：这提供对 chart 中所有非特殊文件的访问。虽然无法使用它来访问模板，但可以使用它来访问 chart 中的其他文件。请参阅 "访问文件" 部分。
- `Files.Get` 是一个按名称获取文件的函数（`.Files.Get config.ini`）
- `Files.GetBytes` 是将文件内容作为字节数组而不是字符串获取的函数。这对于像图片这样的东西很有用。
- `Capabilities`：这提供了关于 Kubernetes 集群支持的功能的信息。
- `Capabilities.APIVersions` 是一组版本信息。
- `Capabilities.APIVersions.Has $version` 指示是否在群集上启用版本（`batch/v1`）。
- `Capabilities.KubeVersion` 提供了查找 Kubernetes 版本的方法。它具有以下值：Major，Minor，GitVersion，GitCommit，GitTreeState，BuildDate，GoVersion，Compiler，和 Platform。
- `Capabilities.TillerVersion` 提供了查找 Tiller 版本的方法。它具有以下值：SemVer，GitCommit，和 GitTreeState。
- `Template`：包含有关正在执行的当前模板的信息
- `Name`：到当前模板的 namespace 文件路径（例如 `mychart/templates/mytemplate.yaml`）
- `BasePath`：当前 chart 模板目录的 namespace 路径（例如 mychart/templates）。

这些值可用于任何顶级模板。我们稍后会看到，这并不意味着它们将在任何地方都要有。

内置值始终以大写字母开头。这符合Go的命名约定。当你创建自己的名字时，你可以自由地使用适合你的团队的惯例。一些团队，如Kubernetes chart团队，选择仅使用首字母小写字母来区分本地名称与内置名称。在本指南中，我们遵循该约定。

## values文件

在上一节中，我们看了 Helm 模板提供的内置对象。四个内置对象之一是 Values。该对象提供对传入 chart 的值的访问。其内容来自四个来源：

- chart 中的 `values.yaml` 文件
- 如果这是一个子 chart，来自父 chart 的 `values.yaml` 文件
- value 文件通过 helm install 或 helm upgrade 的 - f 标志传入文件（`helm install -f myvals.yaml ./mychart`）
- 通过 `--set`（例如 `helm install --set foo=bar ./mychart`）

上面的列表按照特定的顺序排列：values.yaml 在默认情况下，父级 chart 的可以覆盖该默认级别，而该 chart values.yaml 又可以被用户提供的 values 文件覆盖，而该文件又可以被 --set 参数覆盖。

值文件是纯 YAML 文件。我们编辑 `mychart/values.yaml`，然后来编辑我们的 `ConfigMap` 模板。

删除默认带的 values.yaml，我们只设置一个参数：

```
# 编辑values.yaml
domain: anchnet.com

# 在模版中引用
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  domain: {{.Values.domain}}
```

注意我们在最后一行 {{ .Values.domain}} 获取 domain` 的值。

```
[root@master mychart]# helm install --dry-run --debug ./mychart
'''
---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: exciting-manta-confgmap
data:
  myvalue: "this is my chart configmap"
  domain: anchnet.com
```

- 手动利用--set指定

由于 `domain` 在默认 `values.yaml` 文件中设置为 `anchnet.com`，这就是模板中显示的值。我们可以轻松地在我们的 helm install 命令中通过加一个 `--set` 添标志来覆盖：

```
helm install --dry-run --debug --set domain=51idc.com ./mychart 
'''
---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: foppish-mule-confgmap
data:
  myvalue: "this is my chart configmap"
  domain: 51idc.com
```

由于 `--set` 比默认 `values.yaml` 文件具有更高的优先级

- 删除默认 key

如果您需要从默认值中删除一个键，可以覆盖该键的值为 null，在这种情况下，Helm 将从覆盖值合并中删除该键。

```
helm install stable/drupal --set image=my-registry/drupal:0.1.0 --set livenessProbe.exec.command=[cat,docroot/CHANGELOG.txt] --set livenessProbe.httpGet=null
```

## 模版函数和管道

- 模版函数

目前为止，我们已经知道如何将信息放入模板中。但是这些信息未经修改就被放入模板中。有时我们想要转换这些数据，使得他们对我们来说更有用。

让我们从一个最佳实践开始：当从. Values 对象注入字符串到模板中时，我们引用这些字符串。我们可以通过调用 quote 模板指令中的函数来实现：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  drink: {{quote .Values.favorite.drink}}
  food: {{quote .Values.favorite.food}}
```

模板函数遵循语法 `functionName arg1 arg2...`。在上面的代码片段中，`quote .Values.favorite.drink` 调用 quote 函数并将一个参数传递给它。

Helm 拥有超过 60 种可用函数。其中一些是由 Go 模板语言 [Go template language](https://godoc.org/text/template) 本身定义的。其他大多数都是 Sprig 模板库 [Sprig template library](https://godoc.org/github.com/Masterminds/sprig) 的一部分。在我们讲解例子进行的过程中，我们会看到很多。

> 虽然我们将 Helm 模板语言视为 Helm 特有的，但它实际上是 Go 模板语言，一些额外函数和各种包装器的组合，以将某些对象暴露给模板。Go 模板上的许多资源在了解模板时可能会有所帮助。

- 管道

模板语言的强大功能之一是其管道概念。利用 UNIX 的一个概念，管道是一个链接在一起的一系列模板命令的工具，以紧凑地表达一系列转换。换句话说，管道是按顺序完成几件事情的有效方式。我们用管道重写上面的例子。

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  drink: {{.Values.favorite.drink | quote}}
  food: {{.Values.favorite.food | quote}}
```

在这个例子中，没有调用 `quote ARGUMENT`，我们调换了顺序。我们使用管道（|）将 “参数” 发送给函数：`.Values.favorite.drink | quote`。使用管道，我们可以将几个功能链接在一起：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  drink: {{.Values.favorite.drink | quote}}
  food: {{.Values.favorite.food | upper | quote}}
```

> 反转顺序是模板中的常见做法。你会看到.`val | quote` 比 `quote .val` 更常见。练习也是。

当评估时，该模板将产生如下结果：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: trendsetting-p-configmap
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "PIZZA"
```

请注意，我们的原来 `pizza` 现在已经转换为 `"PIZZA"`。

当有像这样管道参数时，第一个评估（`.Values.favorite.drink`）的结果将作为函数的最后一个参数发送。我们可以修改上面的饮料示例来说明一个带有两个参数的函数 `repeat COUNT STRING`：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  drink: {{.Values.favorite.drink | repeat 5 | quote}}
  food: {{.Values.favorite.food | upper | quote}}
```

该 repeat 函数将回送给定的字符串和给定的次数，所以我们将得到这个输出：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: melting-porcup-configmap
data:
  myvalue: "Hello World"
  drink: "coffeecoffeecoffeecoffeecoffee"
  food: "PIZZA"
```

- 使用 default 函数

经常使用的一个函数是 `default`：`default DEFAULT_VALUE GIVEN_VALUE`。该功能允许在模板内部指定默认值，以防该值被省略。让我们用它来修改上面的饮料示例：

```
drink: {{.Values.favorite.drink | default "tea" | quote}}
```

如果我们像往常一样运行，我们会得到我们的 coffee：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: virtuous-mink-configmap
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "PIZZA"
```

现在，我们将从以下位置删除喜欢的饮料设置 values.yaml：

```
favorite:
  #drink: coffee
  food: pizza
```

现在重新运行 `helm install --dry-run --debug ./mychart` 会产生这个 YAML：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fair-worm-configmap
data:
  myvalue: "Hello World"
  drink: "tea"
  food: "PIZZA"
```

在实际的 chart 中，所有静态默认值应该存在于 values.yaml 中，不应该使用该 default 命令重复（否则它们将是重复多余的）。但是，default 命令对于计算的值是合适的，因为计算值不能在 values.yaml 中声明。例如：

```
drink: {{.Values.favorite.drink | default (printf "%s-tea" (include "fullname" .)) }}
```

在一些地方，一个 `if` 条件可能比这 `default` 更适合。我们将在下一节中看到这些。

模板函数和管道是转换信息并将其插入到 YAML 中的强大方法。但有时候需要添加一些比插入字符串更复杂一些的模板逻辑。在下一节中，我们将看看模板语言提供的控制结构。

- 运算符函数

对于模板，运算符（eq，ne，lt，gt，and，or 等等）都是已实现的功能。在管道中，运算符可以用圆括号（`(` 和 `)`）分组。

将运算符放到声明的前面，后面跟着它的参数，就像使用函数一样。要多个运算符一起使用，将每个函数通过圆括号分隔。

```
{{/* include the body of this if statement when the variable .Values.fooString xists and is set to "foo" */}}
{{if and .Values.fooString (eq .Values.fooString "foo") }}
    {{...}}
{{end}}


{{/* do not include the body of this if statement because unset variables evaluate o false and .Values.setVariable was negated with the not function. */}}
{{if or .Values.anUnsetVariable (not .Values.aSetVariable) }}
   {{...}}
{{end}}
```

现在我们可以从函数和管道转向流控制,条件，循环和范围修饰符。

## 流程控制

### 流程控制

控制结构（模板说法中称为 “动作”）为模板作者提供了控制模板生成流程的能力。Helm 的模板语言提供了以下控制结构：

- `if/else` 用于创建条件块
- `with` 指定范围
- `range`，它提供了一个 “for each” 风格的循环

除此之外，它还提供了一些声明和使用命名模板段的操作：

- `define` 在模板中声明一个新的命名模板
- `template` 导入一个命名模板
- `block` 声明了一种特殊的可填写模板区域

在本节中，我们将谈论 `if`，`with` 和 `range`。其他内容在本指南后面的 “命名模板” 一节中介绍。

### if/else

我们要看的第一个控制结构是用于在模板中有条件地包含文本块。这就是 if/else 块。

条件的基本结构如下所示：

```
{{if PIPELINE}}
  # Do something
{{else if OTHER PIPELINE}}
  # Do something else
{{else}}
  # Default case
{{end}}
```

注意，我们现在讨论的是管道而不是值。其原因是要明确控制结构可以执行整个管道，而不仅仅是评估一个值。

如果值为如下情况，则管道评估为 false。

- 一个布尔型的假
- 一个数字零
- 一个空的字符串
- 一个 `nil`（空或 null）
- 一个空的集合（`map`，`slice`，`tuple`，`dict`，`array`）

在其他情况下, 条件值为 *true* 此管道被执行。

我们为 ConfigMap 添加一个简单的条件。如果饮料被设置为咖啡，我们将添加另一个设置：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  drink: {{.Values.favorite.drink | default "tea" | quote}}
  food: {{.Values.favorite.food | upper | quote}}
  {{if and .Values.favorite.drink (eq .Values.favorite.drink "coffee") }}mug: true{{ end }}
```

注意 `.Values.favorite.drink` 必须已定义，否则在将它与 “coffee” 进行比较时会抛出错误。由于我们在上一个例子中注释掉了 `drink：coffee`，因此输出不应该包含 `mug：true` 标志。但是如果我们将该行添加回 `values.yaml` 文件中，输出应该如下所示:

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: eyewitness-elk-configmap
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "PIZZA"
  mug: true
```

###  控制空格

在查看条件时，我们应该快速查看模板中的空格控制方式。让我们看一下前面的例子，并将其格式化为更容易阅读的格式：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  drink: {{.Values.favorite.drink | default "tea" | quote}}
  food: {{.Values.favorite.food | upper | quote}}
  {{if eq .Values.favorite.drink "coffee"}}
    mug: true
  {{end}}
```

最初，这看起来不错。但是如果我们通过模板引擎运行它，我们会得到一个错误的结果：

```
$ helm install --dry-run --debug ./mychart
SERVER: "localhost:44134"
CHART PATH: /Users/mattbutcher/Code/Go/src/k8s.io/helm/_scratch/mychart
Error: YAML parse error on mychart/templates/configmap.yaml: error converting YAML to JSON: yaml: line 9: did not find expected key
```

发生了什么？由于上面的空格，我们生成了不正确的 YAML。

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: eyewitness-elk-configmap
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "PIZZA"
    mug: true
```

mug 不正确地缩进。让我们简单地缩进那行，然后重新运行：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  drink: {{.Values.favorite.drink | default "tea" | quote}}
  food: {{.Values.favorite.food | upper | quote}}
  {{if eq .Values.favorite.drink "coffee"}}
  mug: true
  {{end}}
```

当我们发送该信息时，我们会得到有效的 YAML，但仍然看起来有点意思：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: telling-chimp-configmap
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "PIZZA"

  mug: true
```

请注意，我们在 YAML 中收到了一些空行。为什么？当模板引擎运行时，它将删除 `{{` 和 `}}` 中的空白内容，但是按原样保留剩余的空白。

YAML 中的缩进空格是严格的，因此管理空格变得非常重要。幸运的是，Helm 模板有几个工具可以帮助我们。

首先，可以使用特殊字符修改模板声明的大括号语法，以告诉模板引擎填充空白。`{{-`（添加了破折号和空格）表示应该将格左移，而 `-}}` 意味着应该删除右空格。注意！换行符也是空格！

> 确保 `-` 和其他指令之间有空格。`-3` 意思是 “删除左空格并打印 3”，而 `-3` 意思是 “打印 -3”。

使用这个语法，我们可以修改我们的模板来摆脱这些新行：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  drink: {{.Values.favorite.drink | default "tea" | quote}}
  food: {{.Values.favorite.food | upper | quote}}
  {{- if eq .Values.favorite.drink "coffee"}}
  mug: true
  {{- end}}
```

为了清楚说明这一点，让我们调整上面的内容，将空格替换为 `*`, 按照此规则将每个空格将被删除。一个在该行的末尾的 `*` 指示换行符将被移除

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  drink: {{.Values.favorite.drink | default "tea" | quote}}
  food: {{.Values.favorite.food | upper | quote}}*
**{{- if eq .Values.favorite.drink "coffee"}}
  mug: true*
**{{- end}}
```

牢记这一点，我们可以通过 Helm 运行我们的模板并查看结果：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: clunky-cat-configmap
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "PIZZA"
  mug: true
```

小心使用 chomping 修饰符。这样很容易引起意外：

```
  food: {{.Values.favorite.food | upper | quote}}
  {{- if eq .Values.favorite.drink "coffee" -}}
  mug: true
  {{- end -}}
```

这将会产生 food: "PIZZA"mug:true，因为删除了双方的换行符。

> 有关模板中空格控制的详细信息，请参阅官方 Go 模板文档 [Official Go template documentation](https://godoc.org/text/template)

最后，有时候告诉模板系统如何缩进更容易，而不是试图掌握模板指令的间距。因此，有时可能会发现使用 `indent` 函数（`{{indent 2 "mug:true"}}`）会很有用。

###  使用 with 修改范围

下一个要看的控制结构是 `with`。它控制着变量作用域。回想一下，`.` 是对当前范围的引用。因此，`.Values` 告诉模板在当前范围中查找 `Values` 对象。

其语法 with 类似于一个简单的 if 语句：

```
{{with PIPELINE}}
  # restricted scope
{{end}}
```

范围可以改变。with 可以允许将当前范围（`.`）设置为特定的对象。例如，我们一直在使用的 `.Values.favorites`。让我们重写我们的 ConfigMap 来改变 `.` 范围来指向 `.Values.favorites`：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  {{- with .Values.favorite}}
  drink: {{.drink | default "tea" | quote}}
  food: {{.food | upper | quote}}
  {{- end}}
```

注意，现在我们可以引用 `.drink` 和 `.food` 无需对其进行限定。这是因为该 `with` 声明设置 `.` 为指向 `.Values.favorite`。在 `{{end}}` 后 `.` 复位其先前的范围。

但是请注意！在受限范围内，此时将无法从父范围访问其他对象。例如，下面会报错：

```
  {{- with .Values.favorite}}
  drink: {{.drink | default "tea" | quote}}
  food: {{.food | upper | quote}}
  release: {{.Release.Name}}
  {{- end}}
```

它会产生一个错误，因为 Release.Name 它不在 `.` 限制范围内。但是，如果我们交换最后两行，所有将按预期工作，因为范围在 之后被重置。

```
  {{- with .Values.favorite}}
  drink: {{.drink | default "tea" | quote}}
  food: {{.food | upper | quote}}
  {{- end}}
  release: {{.Release.Name}}
```

看下 `range`，我们看看模板变量，它提供了一个解决上述范围问题的方法。

### 循环 `range` 动作

许多编程语言都支持使用 `for` 循环，`foreach` 循环或类似的功能机制进行循环。在 Helm 的模板语言中，遍历集合的方式是使用 `range` 操作子。

首先，让我们在我们的 `values.yaml` 文件中添加一份披萨配料列表：

```
favorite:
  drink: coffee
  food: pizza
pizzaToppings:
  - mushrooms
  - cheese
  - peppers
  - onions
```

现在我们有一个列表（模板中称为 slice）pizzaToppings。我们可以修改我们的模板，将这个列表打印到我们的 ConfigMap 中：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  {{- with .Values.favorite}}
  drink: {{.drink | default "tea" | quote}}
  food: {{.food | upper | quote}}
  {{- end}}
  toppings: |-
    {{- range .Values.pizzaToppings}}
    - {{. | title | quote}}
    {{- end}}
```

让我们仔细看看 `toppings`:list。该 range 函数将遍历 pizzaToppings 列表。但现在发生了一些有趣的事. 就像 `with`sets 的范围 `.`，`range` 操作子也是一样。每次通过循环时，`.` 都设置为当前比萨饼顶部。也就是第一次 `.` 设定 mushrooms。第二个迭代它设置为 `cheese`，依此类推。

我们可以直接向管道发送 `.` 的值，所以当我们这样做时 `{{. | title | quote}}`，它会发送 `.` 到 title（标题 case 函数），然后发送到 `quote`。如果我们运行这个模板，输出将是：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: edgy-dragonfly-configmap
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "PIZZA"
  toppings: |-
    - "Mushrooms"
    - "Cheese"
    - "Peppers"
    - "Onions"
```

现在，在这个例子中，我们碰到了一些棘手的事情。该 `toppings: |-` 行声明了一个多行字符串。所以我们的 toppings list 实际上不是 YAML 清单。这是一个很大的字符串。我们为什么要这样做？因为 ConfigMaps 中的数据 `data` 由键 / 值对组成，其中键和值都是简单的字符串。要理解这种情况，请查看 [Kubernetes ConfigMap 文档](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/).。但对我们来说，这个细节并不重要。

> YAML 中的 `|-` 标记表示一个多行字符串。这可以是一种有用的技术，用于在清单中嵌入大块数据，如此处所示。

有时能快速在模板中创建一个列表，然后遍历该列表是很有用的。Helm 模板有一个功能可以使这个变得简单：`tuple`。在计算机科学中，元组是类固定大小的列表类集合，但是具有任意数据类型。这粗略地表达了 tuple 的使用方式。

```
  sizes: |-
    {{- range tuple "small" "medium" "large"}}
    - {{.}}
    {{- end}}
  sizes: |-
    - small
    - medium
    - large
```

除了list和tuple之外，`range`还可以用于遍历具有键和值的集合（如`map` 或 `dict`）。当在下一节我们介绍模板变量时，将看到如何做到这一点。

## 变量

我们已经了解了函数，管道，对象和控制结构，我们可以在许多编程语言中找到更基本的用法之一：变量。在模板中，它们使用的频率较低。我们将看到如何使用它们来简化代码，并更好地使用 `with` 和 `range`。

在前面的例子中，我们看到这段代码会失败：

```
  {{- with .Values.favorite}}
  drink: {{.drink | default "tea" | quote}}
  food: {{.food | upper | quote}}
  release: {{.Release.Name}}
  {{- end}}
```

`Release.Name` 不在该 `with` 块中限制的范围内。解决范围问题的一种方法是将对象分配给可以在不考虑当前范围的情况下访问的变量。

在 Helm 模板中，变量是对另一个对象的命名引用。它遵循这个形式 `$name`。变量被赋予一个特殊的赋值操作符：`:=`。我们可以使用变量重写上面的 Release.Name。

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  {{- $relname := .Release.Name -}}
  {{- with .Values.favorite}}
  drink: {{.drink | default "tea" | quote}}
  food: {{.food | upper | quote}}
  release: {{$relname}}
  {{- end}}
```

注意，在我们开始 `with` 块之前，我们赋值 `$relname :=`.Release.Name。现在在 `with` 块内部，`$relname` 变量仍然指向发布名称。

会产生这样的结果：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: viable-badger-configmap
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "PIZZA"
  release: viable-badger
```

变量在 `range` 循环中特别有用。它们可以用于类似列表的对象以同时捕获索引和值：

```
toppings: |-
    {{- range $index, $topping := .Values.pizzaToppings}}
      {{$index}}: {{ $topping }}
    {{- end}}
```

注意，`range` 首先是变量，然后是赋值运算符，然后是列表。这将分配整数索引（从零开始）给 `$index`，值给 `$topping`。运行它将产生：

```
  toppings: |-
      0: mushrooms
      1: cheese
      2: peppers
      3: onions
```

对于同时具有键和值的数据结构，我们可以使用 `range` 来获得两者。例如，我们可以对 `.Values.favorite` 像这样循环：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-configmap
data:
  myvalue: "Hello World"
  {{- range $key, $val := .Values.favorite}}
  {{$key}}: {{ $val | quote }}
  {{- end}}
```

现在在第一次迭代中，`$key` 是 `drink`，`$val` 是 `coffee`，第二次，`$key` 是 food，`$val` 会 pizza。运行上面的代码会生成下面这个：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: eager-rabbit-configmap
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "pizza"
```

变量通常不是 “全局” 的。它们的范围是它们所在的块。之前，我们在模板的顶层赋值 `$relname`。该变量将在整个模板的范围内起作用。但在我们的最后一个例子中，`$key` 和 `$val` 只会在该 `{{range...}}{{end}}` 块的范围内起作用。

然而，总有一个变量是全局 `$` 变量 - 这个变量总是指向根上下文。当你在需要知道 chart 发行名称的范围内循环时，这非常有用。

举例说明：

```
{{- range .Values.tlsSecrets}}
apiVersion: v1
kind: Secret
metadata:
  name: {{.name}}
  labels:
    # Many helm templates would use `.` below, but that will not work,
    # however `$` will work here
    app.kubernetes.io/name: {{template "fullname" $}}
    # I cannot reference .Chart.Name, but I can do $.Chart.Name
    helm.sh/chart: "{{$.Chart.Name}}-{{ $.Chart.Version }}"
    app.kubernetes.io/instance: "{{$.Release.Name}}"
    app.kubernetes.io/managed-by: "{{$.Release.Service}}"
type: kubernetes.io/tls
data:
  tls.crt: {{.certificate}}
  tls.key: {{.key}}
---
{{- end}}
```

到目前为止，我们只查看了一个文件中声明的一个模板。但是Helm模板语言的强大功能之一是它能够声明多个模板并将它们一起使用。我们将在下一节中讨论。

## 命名模版

现在是开始创建超过一个模板的时候了。在本节中，我们将看到如何在一个文件中定义命名模板，然后在别处使用它们。命名模板（有时称为部分或子模板）是限定在一个文件内部的模板，并起一个名称。我们有两种创建方法，以及几种不同的使用方法。

在 “流量控制” 部分中，我们介绍了声明和管理模板三个动作：`define`，`template`，和 `block`。在本节中，我们将介绍这三个动作，并介绍一个 `include` 函数，与 `template` 类似功能。

在命名模板时要注意一个重要的细节：模板名称是全局的。如果声明两个具有相同名称的模板，则最后加载一个模板是起作用的模板。由于子 chart 中的模板与顶级模板一起编译，因此注意小心地使用特定 chart 的名称来命名模板。

通用的命名约定是为每个定义的模板添加 chart 名称：`{{define "mychart.labels"}}`。通过使用特定 chart 名称作为前缀，我们可以避免由于同名模板的两个不同 chart 而可能出现的任何冲突。

### partials 和 `_` 文件

到目前为止，我们已经使用了一个文件，一个文件包含一个模板。但 Helm 的模板语言允许创建指定的嵌入模板，可以通过名称访问。

在我们开始编写这些模板之前，有一些文件命名约定值得一提：

- 大多数文件 `templates/` 被视为包含 Kubernetes manifests
- `NOTES.txt` 是一个例外
- 名称以下划线（`_`）开头的文件被假定为没有内部 manifest。这些文件不会渲染 Kubernetes 对象定义，而是在其他 chart 模板中随处可用以供调用。

这些文件用于存储 partials 和辅助程序。事实上，当我们第一次创建时 mychart，我们看到一个叫做文件 `_helpers.tpl`。该文件是模板 partials 的默认位置。

### 用 `define` 和 `template` 声明和使用模板

# 实战

## 制作charts

- 将用slate做好的go2cloud-api-doc 利用helm做成charts，方便后续部署

```
helm create go2cloud-api-doc

[root@master go2cloud-api-doc]# tree 
.
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── NOTES.txt
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml

3 directories, 8 files


# 配置 deployment
[root@master go2cloud_api_doc_charts]# egrep "^$|^#" -v go2cloud-api-doc/templates/deployment.yaml  
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "go2cloud-api-doc.fullname" . }}
  labels:
{{ include "go2cloud-api-doc.labels" . | indent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "go2cloud-api-doc.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "go2cloud-api-doc.name" . }}
        app.kubernetes.io/instance: {{ .Release.Name }}
    spec:
      imagePullSecrets: 
        - name: {{ .Values.imagePullSecrets }}
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.port }}
              protocol: TCP
          livenessProbe:
            {{- toYaml .Values.livenessProbe | nindent 12  }}
          readinessProbe:
            {{- toYaml .Values.readinessProbe | nindent 12  }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
    {{- end }}
    {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
    {{- end }}


# 配置service
[root@master go2cloud_api_doc_charts]# egrep "^$|^#" -v go2cloud-api-doc/templates/service.yaml 
apiVersion: v1
kind: Service
metadata:
  name: {{ include "go2cloud-api-doc.fullname" . }}
  labels:
{{ include "go2cloud-api-doc.labels" . | indent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.port }}
      protocol: TCP
      name: http
      nodePort: {{ .Values.service.nodePort }}      
  selector:
    app.kubernetes.io/name: {{ include "go2cloud-api-doc.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}


# 配置values
[root@master go2cloud_api_doc_charts]# egrep "^$|^#|^[[:space:]]+#" -v go2cloud-api-doc/values.yaml
replicaCount: 1
image:
  repository: 10.234.2.218/go2cloud/go2cloud-api-doc
  tag: latest
  pullPolicy: Always
imagePullSecrets: registry-secret
nameOverride: ""
fullnameOverride: ""
service:
  type: NodePort
  port: 4567
  nodePort: 30567
ingress:
  enabled: false
  annotations: {}
  hosts:
    - host: chart-example.local
      paths: []
  tls: []
resources: 
  requests:
    cpu: 1000m
    memory: 1280Mi
  limits:
    cpu: 1000m
    memory: 1280Mi
livenessProbe:
  tcpSocket:
    port: 4567
  initialDelaySeconds: 10
  failureThreshold: 2 
  timeoutSeconds: 10
readinessProbe:
  httpGet:
    path: /#introduction
    port: http
  initialDelaySeconds: 5
  failureThreshold: 2 
  timeoutSeconds: 30
nodeSelector: {}
tolerations: []
affinity: {}

[root@master go2cloud_api_doc_charts]# egrep "^$|^#|^[[:space:]]+#" -v go2cloud-api-doc/Chart.yaml 
apiVersion: v1
appVersion: "1.0"
description: A Helm chart for Kubernetes
name: go2cloud-api-doc
version: 0.1.0


# 部署
[root@master go2cloud_api_doc_charts]# helm install -n go2cloud-api-doc -f go2cloud-api-doc/values.yaml go2cloud-api-doc/                  
NAME:   go2cloud-api-doc
LAST DEPLOYED: Wed Jul 31 14:34:21 2019
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME              READY  UP-TO-DATE  AVAILABLE  AGE
go2cloud-api-doc  0/1    1           0          0s

==> v1/Pod(related)
NAME                               READY  STATUS             RESTARTS  AGE
go2cloud-api-doc-7cfb7bb795-clrz8  0/1    ContainerCreating  0         0s

==> v1/Service
NAME              TYPE      CLUSTER-IP     EXTERNAL-IP  PORT(S)         AGE
go2cloud-api-doc  NodePort  10.96.228.251  <none>       4567:30567/TCP  0s


NOTES:
1. Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services go2cloud-api-doc)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT

[root@master go2cloud_api_doc_charts]# helm ls go2cloud-api-doc
NAME                    REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
go2cloud-api-doc        1               Wed Jul 31 14:34:21 2019        DEPLOYED        go2cloud-api-doc-0.1.0  1.0             default  

[root@master go2cloud_api_doc_charts]# kubectl get deployment go2cloud-api-doc
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
go2cloud-api-doc   0/1     1            0           10m

[root@master go2cloud_api_doc_charts]# kubectl get pods |grep go2cloud-api-doc
go2cloud-api-doc-7cfb7bb795-clrz8                         0/1     CrashLoopBackOff   7          10m

[root@master go2cloud_api_doc_charts]# kubectl get svc go2cloud-api-doc
NAME               TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
go2cloud-api-doc   NodePort   10.96.228.251   <none>        4567:30567/TCP   10m



# 打包
[root@master go2cloud_api_doc_charts]# helm package ./go2cloud-api-doc/
Successfully packaged chart and saved it to: /data/go2cloud_api_doc_charts/go2cloud-api-doc-0.1.0.tgz
[root@master go2cloud_api_doc_charts]# tree 
.
├── go2cloud-api-doc
│   ├── charts
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   ├── _helpers.tpl
│   │   ├── NOTES.txt
│   │   ├── service.yaml
│   │   └── tests
│   │       └── test-connection.yaml
│   └── values.yaml
└── go2cloud-api-doc-0.1.0.tgz

4 directories, 8 files


# 升级副本数量
helm upgrade go2cloud-api-doc --set replicaCount=2 go2cloud-api-doc/
```



![img](Helm%E8%AF%A6%E8%A7%A3.assets/16cada4194d6cc6d)



## 配置minior

将制作好的charts存放到minio上,在k8s内部署minior

- 创建本地chart目录

```
mkdir minio-chart
```

- 将修改好的chart文件打包

```
helm package redis
```

- 将包拷贝至创建的本地chart目录中

```
cp redis-8.0.5.tgz /root/minio-chart/
```

- 更新/root/minio-chart/目录下的index索引

```
helm repo index minio-chart/ --url http://10.234.2.204:31311/minio/common-helm-repo/
```



![img](Helm%E8%AF%A6%E8%A7%A3.assets/16cada47d2a140ed)



- 将index.yaml 和chart包上传至minio

```
mc cp index.yaml minio/common-helm-repo/
mc cp redis-8.0.5.tgz minio/common-helm-repo/
```

- 将制作好的charts上传至minio

```
helm repo add monocular https://helm.github.io/monocular
helm install -n monocular monocular/monocular

mc cp go2cloud-api-doc-0.1.0.tgz minio/common-helm-repo
```



![img](Helm%E8%AF%A6%E8%A7%A3.assets/16cada4e0185ac6e)



可以在`${HOME}/.mc/config.json`中查看ak密钥信息。

- 验证



![img](Helm%E8%AF%A6%E8%A7%A3.assets/16cada533f734c04)



## 上传至公共的helm仓库

将制作好的charts包可以上传至helm仓库，可以放在自己的自建私有仓库，流入：kubeapps/Monocular/minior等，可以利用helm命令一键安装。

上传至公有云公共仓库，例如国内的阿里目前创建的Apphub等，在现今的云原生生态当中，已经有很多成熟的开源软件被制作成了 Helm Charts，使得用户可以非常方便地下载和使用，比如 Nginx，Apache、Elasticsearch、Redis 等等。不过，在开放云原生应用中心 App hub（Helm Charts 中国站) 发布之前，国内用户一直都很难直接下载使用这些 Charts。而现在，AppHub 不仅为国内用户实时同步了官方 Helm Hub 里的所有应用，还自动替换了这些 Charts 里所有不可访问的镜像 URL（比如 gcr.io, quay.io 等），终于使得国内开发者通过 helm install “一键安装”应用成为了可能。

具体提交自己的charts可以参考：[github.com/cloudnative…](https://github.com/cloudnativeapp/charts/pulls?spm=a2c6h.13155457.1383030.1.3347b579urlAo7)

此为我上传的slate chart，[Slate](https://spectrum.chat/slate) helps you create beautiful, intelligent, responsive API documentation.

[developer.aliyun.com/hub/detail?…](https://developer.aliyun.com/hub/detail?spm=a2c6h.12873679.0.0.61731107C921or&name=slate&version=v2.3.1#/?_k=ayosl1)



![img](Helm%E8%AF%A6%E8%A7%A3.assets/16cada57adc18391)



# 七 相关链接

- [helm githab地址](https://github.com/helm/helm)
- [helm 手册](https://whmzsu.github.io/helm-doc-zh-cn/)
- [whmzsu.github.io/helm-doc-zh…](https://whmzsu.github.io/helm-doc-zh-cn/chart_template_guide/control_structures-zh_cn.html)
- [github.com/helm/monocu…](https://github.com/helm/monocular)
- [Helm3](https://www.infoq.cn/article/HRMBW_jsMFqXVEx7vj7Z)