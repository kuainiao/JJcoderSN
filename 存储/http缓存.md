#  http 缓存

- **在地址栏输入 url 回车，强缓存什么时候失效，什么时候有效**，你知道吗？
- disk cache 和 memory cache 是什么？在哪里出现？
- 火狐、IE 的缓存处理策略和 Chrome 一样吗？
- `cache-control` 的 `public`、`private` 你知道什么时候使用吗？
- 你知道 `ETag` 可能也有不适用的时候吗？
- 你知道 http 头中 `Vary` 和缓存有怎样的关系吗？

**如果上面的问题你都懂了，那关掉这个页面吧；如果你喜欢本文，点一个赞吧~**

先小小的回顾下

|             http header              |                             描述                             | 强缓存 | 协商缓存 |
| :----------------------------------: | :----------------------------------------------------------: | :----: | :------: |
|               `Pragma`               |            老版本的本地缓存机制，http 1.0 及以下             |        |          |
|              `Expires`               |    在此时候之后，响应过期，时间是绝对时间，受本地时间影响    |   *    |          |
|           `Cache-Control`            | 强缓存策略 `Cache-Control: public, max-age=31536000, must-revalidate` `max-age`是相对时间 |   *    |          |
| `Last-Modified`、`If-Modified-Since` |                资源最后被更改的时间，精确到秒                |        |    *     |
|       `ETag`、`If-None-Match`        |             资源的标识值，用来唯一的标识一个资源             |        |    *     |

处理优先级

在本地 `Cache-Control` > `Expires`，`Pragma` 在不支持 `Cache-Control` 时生效。

如果本地缓存过期，则要依靠协商缓存

```
ETag` > `Last-Modified
```

强缓存的 http 状态码是 200 OK

协商缓存的 http 状态码是 304 Not Modified

## Cache-Control

- `public` 表明响应可以被任何对象（包括：发送请求的客户端，代理服务器，等等）缓存。
- `private` 表明响应只能被单个用户缓存，不能作为共享缓存（即代理服务器不能缓存它）。私有缓存可以缓存响应内容。
- `no-cache` 即使有缓存也会向服务器发请求。
- `no-store` 让客户端不要把资源存在缓存。
- `max-age=` 设置缓存存储的最大周期，超过这个时间缓存被认为过期(单位秒)。与 `Expires` 相反，时间是相对于请求的时间。
- `s-maxage=` 覆盖 `max-age` 或者 `Expires` 头，但是**仅适用于共享缓存(比如各个代理)**，私有缓存会忽略

**问题** 关于 `public` 和 `private` 的区别

![image](http%E7%BC%93%E5%AD%98.assets/16dd7efa2fca4d10)



翻译成中文：`private` 不允许代理缓存。举个例子，ISP 服务商可以在你的客户端和互联网之间加上不可见的代理，这个代理会缓存网页来降低带宽，客户端设置 `cache-control: private` 之后，可以指定 ISP 代理不允许缓存网页，但是允许最后的接受者缓存。而使用 `cache-control: public` 的意思是说，谁都可以缓存哈，所以中间代理会缓存一份以减少带宽降低费用。

如果是谁都可以访问的内容，比如网站 logo，那就用 `public` 好了，反正也不会有关键数据泄露风险，尽量中间代理都给缓存上，减少带宽。而如果是一个含有用户信息的页面，比如页面含有我的用户名，那这个页面当然不是对谁都有用，因为不同的人要返回不同的用户名嘛，这个时候 `private` 会适合一些，如果代理缓存了我的这个页面，别的用户访问又会缓存别人的，这显然不合理，而且你的个人私密数据也尽量不要被保存在不受信任的地方。

当然，所有不被表示为 `public` 的数据都应该被标识为 `private`，要不然数据会存储在中间服务器上，别人就有可能会访问到这个数据。

禁止缓存

```
Cache-Control: no-cache, no-store, must-revalidate
```

缓存静态资源

```
Cache-Control:public, max-age=86400
```

## ETag、If-Match

`ETag` 和 `If-None-Match` 常被用来处理协商缓存。而 `ETag` 和 `If-Match` 可以 **避免“空中碰撞”**。

`ETag` HTTP响应头是资源的特定版本的标识符。这可以让缓存更高效，并节省带宽，因为如果内容没有改变，Web服务器不需要发送完整的响应。而如果内容发生了变化，使用 `ETag` 有助于防止资源的同时更新相互覆盖（“空中碰撞”）。

当编辑 MDN 时，当前的 Wiki 内容被散列，并在响应中放入`Etag`：

```
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4
复制代码
```

将更改保存到 Wiki 页面（发布数据）时，POST 请求将包含有 `ETag` 值的 `If-Match` 头来检查是否为最新版本。

```
If-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"
复制代码
```

如果哈希值不匹配，则意味着文档已经被编辑，抛出 412 ( Precondition Failed) 前提条件失败错误。

`If-None-Match` 是客户端发送给服务器时的请求头，其值是服务器返回给客户端的 `ETag`，当 `If-None-Match` 和服务器资源最新的 `Etag` 不同时，返回最新的资源及其 `Etag`。

## Last-Modified、If-Modified-Since

`Last-Modified`、`If-Modified-Since` 是资源最后更改的时间。

```
Last-Modified: <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT

Last-Modified: Wed, 21 Oct 2015 07:28:00 GMT 
复制代码
```

这两个的区别是： `Last-Modified` 是服务器发送给客户端的，`If-Modified-Since` 是客户端发送给服务器的。

**问题** `Last-Modified` 机制和 `ETag` 机制的区别和优先级是怎样的？

`Last-Modified` 只能精确到秒，所以在秒级以下的更改无法检测到。而 `ETag` 可以表征文件的任何更改，只要文件变化 `ETag` 就会变化。所以 `Last-Modified` 是一个备用机制，优先级不如 `Etag`。

客户端请求带有 `If-None-Match` 在服务端校验匹配则返回 304，校验不匹配则返回 200，同时返回最新的资源和 `Etag`。

## Age

`Age` 消息头里包含消息对象在缓存代理中存贮的时长，以秒为单位。

`Age` 消息头的值通常接近于0。表示此消息对象刚刚从原始服务器获取不久；其他的值则是表示代理服务器当前的系统时间与此应答消息中的通用消息头 Date 的值之差。

```
Age: <delta-seconds>
复制代码
```

如

```
age: 1135860
复制代码
```

## Date

`Date` 是一个通用首部，其中包含了报文创建的日期和时间。

指的是响应生成的时间. 请求经过代理服务器时, 返回的 `Date` 未必是最新的, 通常这个时候, 代理服务器将增加一个 `Age` 字段告知该资源已缓存了多久.

```
Date: Wed, 21 Oct 2015 07:28:00 GMT 
复制代码
```

## Vary

`Vary` 是一个HTTP响应头部信息，它决定了对于未来的一个请求头，应该用一个缓存的回复(response)还是向源服务器请求一个新的回复。它被服务器用来表明在 content negotiation algorithm（内容协商算法）中选择一个资源代表的时候应该使用哪些头部信息（headers）。

对于服务器而言, 资源文件可能不止一个版本, 比如说压缩和未压缩, 针对不同的客户端, 通常需要返回不同的资源版本。 比如说老式的浏览器可能不支持解压缩, 这个时候, 就需要返回一个未压缩的版本; 对于新的浏览器, 支持压缩, 返回一个压缩的版本, 有利于节省带宽, 提升体验. 那么怎么区分这个版本呢, 这个时候就需要 `Vary` 了。

服务器通过指定 `Vary: Accept-Encoding`, 告知代理服务器, 对于这个资源, 需要缓存两个版本: 压缩和未压缩. 这样老式浏览器和新的浏览器, 通过代理, 就分别拿到了未压缩和压缩版本的资源, 避免了都拿同一个资源的尴尬。

```
Vary: Accept-Encoding,User-Agent
复制代码
```

如上设置, 代理服务器将针对是否压缩和浏览器类型两个维度去缓存资源. 如此一来, 同一个url, 就能针对 PC 和 Mobile 返回不同的缓存内容。

## 怎么让浏览器不缓存静态资源

可以设置 `Cache-Control`

```
Cache-Control: no-cache, no-store, must-revalidate
复制代码
```

**也可以给资源增加版本号，这样可以很方便地控制什么时候加载最新资源**，这也是目前做版本更新比较常用的手段，即使老资源还在有效期内，加上了 query、hash。

```
<link rel="stylesheet" type="text/css" href="../css/style.css?version=1.8.9"/>
复制代码
```

## 用户行为与缓存

用户按 f5(ctrl+r)、ctrl+f5、点击前进后退 都会触发缓存机制

经过本地测试发现和网上传的有些出入，记录如下（强缓存有效代表直接使用本地的缓存文件，Chrome 状态码为 200，协商缓存有效代表向服务器发起请求，服务器可能返回 304 无内容或者 200 有内容）。

|        操作        |         强缓存         | 协商缓存 |
| :----------------: | :--------------------: | :------: |
|    页面链接跳转    |          有效          |   有效   |
|      新开窗口      |          有效          |   有效   |
|      前进后退      |          有效          |   有效   |
|     地址栏回车     | **失效** 或者 **有效** |   有效   |
| `ctrl+r`或者 `f5`  |          失效          |   有效   |
| `ctrl+f5` 强制刷新 |          失效          |   失效   |



![image](http%E7%BC%93%E5%AD%98.assets/16dd7efa386e0c16)



地址栏回车和网络上不一样，打个比方，如果当前已经在 `http://localhost:3333/`，然后在地址栏选中后回车，你会发现没有缓存。



![image](http%E7%BC%93%E5%AD%98.assets/16dd7efa5047144f)



**但是**如果当前不在 `http://localhost:3333/` ，比如 `http://localhost:3333/index.css` 或者**空白页**，然后输入 `http://localhost:3333/` 回车，这时候就会直接从本地缓存中读取。



![image](http%E7%BC%93%E5%AD%98.assets/16dd7efa3d782ac2)



**惊喜不，意外不**



![image](http%E7%BC%93%E5%AD%98.assets/16dd7efa2822b479)



## 关于 memory cache 和 disk cache

这两种缓存类型存在于 Chrome 中。

上个小标题 **用户行为与缓存**，我们看到浏览器从本地读缓存的时候有一个 disk cache，与之对应的还有一个 memory cache。看名字也能大概才出来，disk cache 是从硬盘中读取的文件缓存，memory cache 是从内存中直接读取的内容，速度上当然也是后者更快。

那为什么要有这两种缓存的形式呢？

disk cache 存在硬盘，可以存很多，容量上限比内容缓存高很多，而 memory cache 从内存直接读取，速度上占优势，这两个各有各的好处！

**问题** 浏览器如何决策使用哪种缓存呢？



![image](http%E7%BC%93%E5%AD%98.assets/16dd7ef8d854fd55)



来自知乎 [浏览器是根据什么决定「from disk cache」与「from memory cache」？](https://www.zhihu.com/question/64201378)

## 划重点！！关于 Chrome、FF、IE 的缓存区别

这个内容网络上很少有文章介绍，经过我测试之后发现区别挺大的。**Chome 的缓存处理和另外两个存在明显的不同！**

**上面讲的强缓存、memory cache、disk cache 在 FF、IE 中都没有明显的区分，或许这就是 Chrome 速度快的原因？**

我们举个例子，多次重复请求 `https://www.baidu.com/`，查看三个浏览器的区别。

Chrome



![image](http%E7%BC%93%E5%AD%98.assets/16dda81e120e945f)



FF



![image](http%E7%BC%93%E5%AD%98.assets/16dda81dbc68993c)



IE



![image](http%E7%BC%93%E5%AD%98.assets/16dda81def103ef7)



Chrome 中有强缓存、协商缓存，强缓存分为 memory cache、disk cache，这种处理机制可以最大化的利用缓存，减少发起的请求，从而优化页面加载速度！！**Chrome 资源状态码都是 200，没有 304，另外两家都存在大量304，在 FF、IE 中，即使服务器明确表示资源需要进行强缓存，比如 `Cache-Control: max-age=86400`，他们仍然不会应用所谓的强缓存策略，仍然会向服务器发送请求，服务器返回 304 ，告诉浏览器用你本地的资源就好了！！！**

怎么知道这个请求确实是发送到了代理或者真实服务器呢？我们上面有说 `Age` 和 `Date`，Age 表示当前请求在返回时，在代理那里的时间减去 `Date` 的时间，所以每次只要请求发出去了，`Age` 都会相比上一次增加！！！

我们以掘金的 `https://b-gold-cdn.xitu.io/v3/static/js/0.81b469df7a0dd87832a4.js` 文件为例。在 FF 上，前一次的结果是



![image](http%E7%BC%93%E5%AD%98.assets/16dda81dbf524204)



刷一下



![image](http%E7%BC%93%E5%AD%98.assets/16dda81ddfa582c1)



`Date` 没有变，表示都是使用的同一个真实服务器的响应资源，`Age` 后一次比前一次变大了，但是状态码都是 304，而缓存规则是 `cache-control: s-maxage=2592199, max-age=2592199`！！！

所以想要做好缓存，需要考虑浏览器兼容的问题，综合使用 http headers。

## 既然 Etag 可以校验资源是否更改，那为什么还要 Last-Modified 作为备用策略

这个问题大多数讲缓存的文章也没有提及。

`Etag` 是通过资源内容生成的，所以会有一个计算成本存在，本如大图片的更改，它的最后更改时间可以很容易获得，但是计算 `Etag` 成本就会高很多了。

------

参考

- [浏览器缓存机制：强缓存、协商缓存](https://github.com/amandakelake/blog/issues/41)
- [深入理解浏览器的缓存机制](https://www.jianshu.com/p/54cc04190252)
- [HTTP缓存机制](https://www.cnblogs.com/ranyonsue/p/8918908.html)
- [浏览器是根据什么决定「from disk cache」与「from memory cache」？](https://www.zhihu.com/question/64201378)
- [浏览器缓存机制剖析](https://juejin.im/post/58eacff90ce4630058668257)
- [浅谈浏览器http的缓存机制](https://www.cnblogs.com/vajoy/p/5341664.html)