# REST接口设计规范总结
### 简介
Representational State Transfer 简称 REST 描述了一个架构样式的网络系统。REST 指的是一组架构约束条件和原则。满足这些约束条件和原则的应用程序或设计就是 RESTful。

### 概念:

资源（Resources） REST是”表现层状态转化”，其实它省略了主语。”表现层”其实指的是”资源”的”表现层”。那么什么是资源呢？就是我们平常上网访问的一张图片、一个文档、一个视频等。这些资源我们通过URI来定位，也就是一个URI表示一个资源。

### 表现层（Representation）
资源是做一个具体的实体信息，他可以有多种的展现方式。而把实体展现出来就是表现层，例如一个txt文本信息，他可以输出成html、json、xml等格式，一个图片他可以jpg、png等方式展现，这个就是表现层的意思。
URI确定一个资源，但是如何确定它的具体表现形式呢？应该在HTTP请求的头信息中用Accept和Content-Type字段指定，这两个字段才是对”表现层”的描述。

**状态转化（State Transfer**）访问一个网站，就代表了客户端和服务器的一个互动过程。在这个过程中，肯定涉及到数据和状态的变化。而HTTP协议是无状态的，那么这些状态肯定保存在服务器端，所以如果客户端想要通知服务器端改变数据和状态的变化，肯定要通过某种方式来通知它。

### URI格式规范
URI中尽量使用连字符”-“代替下划线”_”的使用
URI中统一使用小写字母
URI中不要包含文件(脚本)的扩展名
## 资源的原型
### 文档(Document)
文档是资源的单一表现形式，可以理解为一个对象，或者数据库中的一条记录。在请求文档时，
要么返回文档对应的数据，要么会返回一个指向另外一个资源(文档)的链接。
以下是几个基于文档定义的URI例子：
https://api.example.com/users/will
https://api.example.com/posts/1
https://api.example.com/posts/1/comments/1
### 集合(Collection)
集合可以理解为是资源的一个容器(目录)，我们可以向里面添加资源(文档)。例如：
https://api.example.com/users
https://api.example.com/posts
https://api.example.com/posts/1/comments
### 仓库(Store)
仓库是客户端来管理的一个资源库，客户端可以向仓库中新增资源或者删除资源。
客户端也可以批量获取到某个仓库下的所有资源。仓库中的资源对外的访问不会提供单独URI的，
客户端在创建资源时候的URI除外。例如：
PUT /users/1234/favorites/posts/1
上面的例子我们可以理解为，我们向一个id是1234的用户的仓库(收藏夹)中，
添加了一个id为1的post资源。通俗点儿说：就是用户收藏了一个自己喜爱的id为1的文章。
### 控制器(Controller)
控制器资源模型，可以执行一个方法，支持参数输入，结果返回。 是为了除了标准操作:
增删改查(CRUD)以外的一些逻辑操作。控制器(方法)一般定义子URI中末尾，
并且不会有子资源(控制器)。例如：
向用户重发ID为245743的消息
POST /alerts/245743/resend

发布ID为1的文章
POST /posts/1/publish

### 把动作转换成资源

把动作转换成可以执行 CRUD 操作的资源， github 就是用了这种方法。

比如“喜欢”一个 gist，就增加一个 /gists/:id/star 子资源，
然后对其进行操作：“喜欢”使用 PUT /gists/:id/star，
“取消喜欢”使用 DELETE /gists/:id/star
或者使用 POST /gists/:id/unstar

另外一个例子是 Fork，这也是一个动作，但是在 gist 下面增加 forks资源，
就能把动作变成 CRUD 兼容的：POST /gists/:id/forks 可以执行用户 fork 的动作。
## URI命名规范
**文档(Document)类型**的资源用名词(短语)单数命名
**集合(Collection)类型**的资源用名词(短语)复数命名
**仓库(Store)类型**的资源用名词(短语)复数命名
**控制器(Controller)类型**的资源用动词(短语)命名
URI中有些字段可以是变量，在实际使用中可以按需替换
例如一个资源URI可以这样定义：
https://api.example.com/posts/{postId}/comments/{commentId}
postId,commentId 是变量(数字，字符串都类型都可以)。

### CRUD

CRUD的操作不要体现在URI中，HTTP协议中的操作符已经对CRUD做了映射。
CRUD是创建，读取，更新，删除这四个经典操作的简称
例如删除的操作用REST规范执行的话，应该是这个样子：
DELETE /users/1234

以下是几个错误的示例：
GET /deleteUser?id=1234
GET /deleteUser/1234
DELETE /deleteUser/1234
POST /users/1234/delete
## URI的query字段
在REST中,query字段一般作为查询的参数补充，也可以帮助标示一个唯一的资源。但需要注意的是，
作为一个提供查询功能的URI，无论是否有query条件，我们都应该保证结果的唯一性，
一个URI对应的返回数据是不应该被改变的(在资源没有修改的情况下)。
HTTP中的缓存也可能缓存查询结果。

Query参数可以作为Collection或Store类型资源的过滤条件来使用 例如：
GET /users //返回所有用户列表
GET /users?role=admin //返回权限为admin的用户列表
GET /search/users?q={query}{&page,per_page,sort,order} //根据多条件查询用户
Query参数可以作为Collection或Store资源列表分页标示使用
如果是一个简单的列表操作，可以这样设计：
GET /users?pageSize=25&pageStartIndex=50
如果是一个复杂的列表或查询操作的话，我们可以为资源设计一个Collection，
因为复杂查询可能会涉及比较多的参数，建议使用Post的方式传入，例如这样：
POST /users/search

相关的分页信息还可以存放到 Link 头部，这样客户端可以直接得到诸如下一页、最后一页、上一页
等内容的 url 地址
Status: 200 OK
Link: <https://api.github.com/resource?page=2>; rel="previous",
      <https://api.github.com/resource?page=2>; rel="next",
      <https://api.github.com/resource?page=5>; rel="last"
X-RateLimit-Limit: 20
X-RateLimit-Remaining: 19
## HTTP请求方法的使用
GET方法用来获取资源
PUT方法可用来新增/更新Store类型的资源
PUT方法可用来更新一个资源的全部属性，使用时传递所有属性的值，即使有的值没有改变
PATCH方法更新资源的部分属性。因为 PATCH 比较新，而且规范比较复杂，所以真正实现的比较少，
一般都是用 POST 替代
POST方法可用来创建一个资源
POST方法可用来触发执行一个Controller类型资源
DELETE方法用于删除资源
## HTTP响应状态码的使用
200 (“OK”) 用于一般性的成功返回
200 (“OK”) 不可用于请求错误返回
201 (“Created”) 资源被创建
202 (“Accepted”) 用于Controller控制类资源异步处理的返回，仅表示请求已经收到。
对于耗时比较久的处理，一般用异步处理来完成
204 (“No Content”) 此状态可能会出现在PUT、POST、DELETE的请求中，一般表示资源存在，
但消息体中不会返回任何资源相关的状态或信息。
301 (“Moved Permanently”) 资源的URI被转移，需要使用新的URI访问
302 (“Found”) 不推荐使用，此代码在HTTP1.1协议中被303/307替代。
我们目前对302的使用和最初HTTP1.0定义的语意是有出入的，应该只有在GET/HEAD方法下，
客户端才能根据Location执行自动跳转，而我们目前的客户端基本上是不会判断原请求方法的，
无条件的执行临时重定向
303 (“See Other”) 返回一个资源地址URI的引用，但不强制要求客户端获取该地址的状态(访问该地址)
304 (“Not Modified”) 有一些类似于204状态，服务器端的资源与客户端最近访问的资源版本一致，
并无修改，不返回资源消息体。可以用来降低服务端的压力
307 (“Temporary Redirect”) 目前URI不能提供当前请求的服务，临时性重定向到另外一个URI。
在HTTP1.1中307是用来替代早期HTTP1.0中使用不当的302
400 (“Bad Request”) 用于客户端一般性错误返回, 在其它4xx错误以外的错误，也可以使用400，
具体错误信息可以放在body中
401 (“Unauthorized”) 在访问一个需要验证的资源时，验证错误
403 (“Forbidden”) 一般用于非验证性资源访问被禁止，例如对于某些客户端只开放部分API的访问权限，
而另外一些API可能无法访问时，可以给予403状态
404 (“Not Found”) 找不到URI对应的资源
405 (“Method Not Allowed”) HTTP的方法不支持，例如某些只读资源，可能不支持POST/DELETE。
但405的响应header中必须声明该URI所支持的方法
406 (“Not Acceptable”) 客户端所请求的资源数据格式类型不被支持，
例如客户端请求数据格式为application/xml，但服务器端只支持application/json
409 (“Conflict”) 资源状态冲突，例如客户端尝试删除一个非空的Store资源
412 (“Precondition Failed”) 用于有条件的操作不被满足时
415 (“Unsupported Media Type”) 客户所支持的数据类型，服务端无法满足
429 (“Too Many Requests”) 客户端在规定的时间里发送了太多请求，在进行限流的时候会用到
500 (“Internal Server Error”) 服务器端的接口错误，此错误于客户端无关
## HTTP Headers
Content-Type 标示body的数据格式
Content-Length body 数据体的大小，客户端可以根据此标示检验读取到的数据是否完整，
也可以通过Header判断是否需要下载可能较大的数据体
Last-Modified 用于服务器端的响应，是一个资源最后被修改的时间戳，客户端(缓存)可以根据
此信息判断是否需要重新获取该资源
ETag 服务器端资源版本的标示，客户端(缓存)可以根据此信息判断是否需要重新获取该资源，
需要注意的是，ETag如果通过服务器随机生成，可能会存在多个主机对同一个资源产生不同ETag的问题
Store类型的资源要支持有条件的PUT请求
假设有两个客户端client#1/#2都向一个Store资源提交PUT请求，服务端是无法清楚的判断是要
insert还是要update的，所以我们要在header中加入条件标示if-Match，If-Unmodified-Since
来明确是本次调用API的意图。例如：

client#1第一次向服务端发起一个请求 PUT /objects/2113 此时2113资源还不存在，那服务端会
认为本次请求是一个insert操作，完成后，会返回 201 (“Created”)

client#2再一次向服务端发起同一个请求 PUT /objects/2113 时，因2113资源已存在，服务端会
返回 409 (“Conflict”)

为了能让client#2的请求成功，或者说我们要清楚的表明本次操作是一次update操作，我们必须在
header中加入一些条件标示，例如 if-Match。我们需要给出资源的ETag(if-Match:Etag)，来表
明我们希望更新资源的版本，如果服务端版本一致，会返回200 (“OK”) 或者 204 (“No Content”)。
如果服务端发现指定的版本与当前资源版本不一致，会返回 412 (“Precondition Failed”)
Location 在响应header中使用，一般为客户端感兴趣的资源URI,例如在成功创建一个资源后，我们
可以把新的资源URI放在Location中，如果是一个异步创建资源的请求，接口在响应202 (“Accepted”)
的同时可以给予客户端一个异步状态查询的地址
Cache-Control, Expires, Date 通过缓存机制提升接口响应性能,同时根据实际需要也可以禁止
客户端对接口请求做缓存。对于REST接口来说，如果某些接口实时性要求不高的情况下，我们可以使
用max-age来指定一个小的缓存时间，这样对客户端和服务器端双方都是有利的。一般来说只对GET
方法且返回200的情况下使用缓存，在某些情况下我们也可以对返回3xx或者4xx的情况下做缓存，可
以防范错误访问带来的负载。
我们可以自定义一些头信息，作为客户端和服务器间的通信使用，但不能改变HTTP方法的性质。自
定义头尽量简单明了，不要用body中的信息对其作补充说明。
## API 地址和版本
在 url 中指定 API 的版本是个很好地做法。如果 API 变化比较大，可以把 API 设计为子域名，
比如 api.github.com/v3；也可以简单地把版… example.com/api/v1。
另一种做法是，将版本号放在HTTP头信息中。

## 限流 rate limit
如果对访问的次数不加控制，很可能会造成 API 被滥用，甚至被 DDos 攻击。根据使用者不同的身份对其进行限流，可以防止这些情况，减少服务器的压力。

对用户的请求限流之后，要有方法告诉用户它的请求使用情况，Github API 使用的三个相关的头部：

X-RateLimit-Limit: 用户每个小时允许发送请求的最大值
X-RateLimit-Remaining：当前时间窗口剩下的可用请求数目
X-RateLimit-Rest: 时间窗口重置的时候，到这个时间点可用的请求数量就会变成 X-RateLimit-Limit 的值
对于超过流量的请求，可以返回 429 Too many requests 状态码，并附带错误信息。

参考文档
cizixs.com/2016/12/12/…
wangwei.info/about-rest-…
www.ruanyifeng.com/blog/2011/0…
www.ruanyifeng.com/blog/2014/0…
zh.wikipedia.org/wiki/REST
developer.github.com/v3
novoland.github.io/%E8%AE%BE%E…
API