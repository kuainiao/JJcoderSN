### 简介

　　HTTP 应用的信息是通过 **请求报文** 和 **响应报文** 传递的，关于更多的相关知识，可以阅读《HTTP权威指南》获得。

　　其中 请求报文 由客户端发送，其中包含和许多的信息，而 django 将这些信息封装成了 HttpRequest 对象，该对象由 HttpRequest 类创建。每一个请求都会生成一个 HttpRequest 对象，django会将这个对象自动传递给响应的视图函数，一般视图函数约定俗成地使用 request 参数承接这个对象。

例如：

　　

```
def index(request):
    ...
    return render(...)
```

当然你也可以使用其他参数来承接这个对象，并没有硬性规定一定要使用什么名称。

简单点说就是request也可以叫别的名字。

### 属性

django将请求报文中的请求行、首部信息、内容主体封装成 HttpRequest 类中的属性。除了特殊说明的之外，其他均为只读的。

**1.`HttpRequest.scheme`**

```
　　一个字符串，代表请求的方案，一般为 ‘http’ 或 ‘https’。
```

 

**2.`HttpRequest.body`**

```
　　一个字符串，代表请求报文的主体。在处理非 HTTP 形式的报文时非常有用，例如：二进制图片、XML等。

　　但是，如果要处理表单数据的时候，推荐还是使用 HttpRequest.POST 。

　　另外，我们还可以用 python 的类文件方法去操作它，详情参考 HttpRequest.read() 。
```

 

**`3.HttpRequest.path`**

```
　　一个字符串，表示请求的路径组件（不含域名）。

　　例如："/music/bands/the_beatles/"
```

 

**4.`HttpRequest.path_info`**

```
　　一个字符串，在某些 Web 服务器配置下，主机名后的 URL 部分被分成脚本前缀部分和路径信息部分。path_info 属性将始终包含路径信息部分，不论使用的Web 服务器是什么。
使用它代替 path 可以让代码在测试和开发环境中更容易地切换。

　　例如，如果应用的WSGIScriptAlias 设置为"/minfo"，那么当 path 是"/minfo/music/bands/the_beatles/" 时path_info 将是"/music/bands/the_beatles/"。
```

 

**5.`HttpRequest.method`**

```
　　一个字符串，表示请求使用的HTTP 方法。必须使用大写。

　　例如："GET"、"POST"
```

 

**6.`HttpRequest.encoding`**

```
　　一个字符串，表示提交的数据的编码方式（如果为 None 则表示使用 DEFAULT_CHARSET 的设置，默认为 'utf-8'）。
这个属性是可写的，你可以修改它来修改访问表单数据使用的编码。接下来对属性的任何访问（例如从 GET 或 POST 中读取数据）将使用新的 encoding 值。
如果你知道表单数据的编码不是 DEFAULT_CHARSET ，则使用它。
```

 

**7.`HttpRequest.GET`**

```
　　一个类似于字典的对象，包含 HTTP GET 的所有参数。详情请参考 QueryDict 对象
```

 

**8.`HttpRequest.POST`**

```
　　一个类似于字典的对象，如果请求中包含表单数据，则将这些数据封装成 QueryDict 对象。

　　POST 请求可以带有空的 POST 字典 —— 如果通过 HTTP POST 方法发送一个表单，但是表单中没有任何的数据，QueryDict 对象依然会被创建。
因此，不应该使用 if request.POST  来检查使用的是否是POST 方法；
应该使用 if request.method == "POST" 

　　另外：如果使用 POST 上传文件的话，文件信息将包含在 FILES 属性中。
```

 

 **9.`HttpRequest.REQUEST`**

```
　　一个类似于字典的对象，它首先搜索POST，然后搜索GET，主要是为了方便。灵感来自于PHP 的 $_REQUEST。

　　例如，如果 GET = {"name": "john"}  而 POST = {"age": '34'} ， REQUEST["name"]  将等于"john"， REQUEST["age"]  将等于"34"。

　　强烈建议使用 GET 和 POST 而不要用REQUEST，因为它们更加明确。
```

 

**10.`HttpRequest.COOKIES`**

```
　　一个标准的Python 字典，包含所有的cookie。键和值都为字符串。
```

 

 **11.`HttpRequest.FILES`**

```
　　一个类似于字典的对象，包含所有的上传文件信息。FILES 中的每个键为<input type="file" name="" /> 中的name，值则为对应的数据。

　　注意，FILES 只有在请求的方法为POST 且提交的<form> 带有enctype="multipart/form-data" 的情况下才会包含数据。　　否则，FILES 将为一个空的类似于字典的对象。
```

 

 **12.`HttpRequest.META`**

**一个标准的Python 字典，包含所有的HTTP 首部。具体的头部信息取决于客户端和服务器，下面是一些示例：**

![img](views%E4%B8%ADrequest%E5%AF%B9%E8%B1%A1%E8%AF%A6%E8%A7%A3.assets/ExpandedBlockStart.gif)

```
CONTENT_LENGTH —— 请求的正文的长度（是一个字符串）。
CONTENT_TYPE —— 请求的正文的MIME 类型。
HTTP_ACCEPT —— 响应可接收的Content-Type。
HTTP_ACCEPT_ENCODING —— 响应可接收的编码。
HTTP_ACCEPT_LANGUAGE —— 响应可接收的语言。
HTTP_HOST —— 客服端发送的HTTP Host 头部。
HTTP_REFERER —— Referring 页面。
HTTP_USER_AGENT —— 客户端的user-agent 字符串。
QUERY_STRING —— 单个字符串形式的查询字符串（未解析过的形式）。
REMOTE_ADDR —— 客户端的IP 地址。
REMOTE_HOST —— 客户端的主机名。
REMOTE_USER —— 服务器认证后的用户。
REQUEST_METHOD —— 一个字符串，例如"GET" 或"POST"。
SERVER_NAME —— 服务器的主机名。
SERVER_PORT —— 服务器的端口（是一个字符串）。
```

 　从上面可以看到，除 `CONTENT_LENGTH` 和 `CONTENT_TYPE` 之外，请求中的任何 HTTP 首部转换为 `META` 的键时，都会将所有字母大写并将连接符替换为下划线最后加上 `HTTP_` 前缀。所以，一个叫做 `X-Bender` 的头部将转换成 `META` 中的 `HTTP_X_BENDER` 键

 

**13.`HttpRequest.user`**

　　一个 `AUTH_USER_MODEL` 类型的对象，表示当前登录的用户。如果用户当前没有登录，`user` 将设置为 `django.contrib.auth.models.AnonymousUser` 的一个实例。你可以通过 `is_authenticated()` 区分它们。

例如：

```
`if` `request.user.is_authenticated():``  ``# Do something for logged-in users.``else``:``  ``# Do something for anonymous users.`
```

 　　`user` 只有当Django 启用 `AuthenticationMiddleware` 中间件时才可用。

#### 匿名用户

class `models.AnonymousUser`

`　　django.contrib.auth.models.AnonymousUser` 类实现了`django.contrib.auth.models.User` 接口，但具有下面几个不同点：

```
`id 永远为None。``username 永远为空字符串。``get_username() 永远返回空字符串。``is_staff 和 is_superuser 永远为False。``is_active 永远为 False。``groups 和 user_permissions 永远为空。``is_anonymous() 返回True 而不是False。``is_authenticated() 返回False 而不是True。``set_password()、check_password()、save() 和``delete``() 引发 NotImplementedError。`
```

 　New in Django 1.8:

　　新增 `AnonymousUser.get_username()` 以更好地模拟 `django.contrib.auth.models.User`。

 

**14.`HttpRequest.session`**

```
 　　一个既可读又可写的类似于字典的对象，表示当前的会话。只有当Django 启用会话的支持时才可用。完整的细节参见会话的文档。
```

 

 **15.`HttpRequest.urlconf`**

```
　　不是由Django 自身定义的，但是如果其它代码（例如，自定义的中间件类）设置了它，Django 就会读取它。
如果存在，它将用来作为当前的请求的Root URLconf，并覆盖 ROOT_URLCONF 设置。
```

 

 **16.`HttpRequest.resolver_match`**

```
一个 ResolverMatch 的实例，表示解析后的URL。这个属性只有在 URL 解析方法之后才设置，这意味着它在所有的视图中可以访问，但是在 URL 解析发生之前执行的中间件方法中不可以访问（比如process_request，但你可以使用 process_view 代替）。
```

###  方法

**1.`HttpRequest.get_host`()**

```
`根据从HTTP_X_FORWARDED_HOST（如果打开 USE_X_FORWARDED_HOST，默认为False）和 HTTP_HOST 头部信息返回请求的原始主机。 如果这两个头部没有提供相应的值，则使用SERVER_NAME 和SERVER_PORT，在PEP 3333 中有详细描述。` `USE_X_FORWARDED_HOST：一个布尔值，用于指定是否优先使用 X-Forwarded-Host 首部，仅在代理设置了该首部的情况下，才可以被使用。` `例如：``"127.0.0.1:8000"` `注意：当主机位于多个代理后面时，get_host() 方法将会失败。除非使用中间件重写代理的首部。`
```

 **2.`HttpRequest.get_full_path`()**

```
`返回 path，如果可以将加上查询字符串。` `例如：``"/music/bands/the_beatles/?print=true"`
```

 **3.`HttpRequest.build_absolute_uri`(location)**

```
`返回location 的绝对URI。如果location 没有提供，则使用request.get_full_path()的返回值。` `如果URI 已经是一个绝对的URI，将不会修改。否则，使用请求中的服务器相关的变量构建绝对URI。` `例如：``"http://example.com/music/bands/the_beatles/?print=true"`
```


**4.`HttpRequest.get_signed_cookie`(key, default=RAISE_ERROR, salt='', max_age=None)**

　　返回签名过的Cookie 对应的值，如果签名不再合法则返回`django.core.signing.BadSignature`。

　　如果提供 `default` 参数，将不会引发异常并返回 default 的值。

　　可选参数`salt` 可以用来对安全密钥强力攻击提供额外的保护。`max_age` 参数用于检查Cookie 对应的时间戳以确保Cookie 的时间不会超过`max_age` 秒。

```
`>>> request.get_signed_cookie(``'name'``)``'Tony'``>>> request.get_signed_cookie(``'name'``, salt=``'name-salt'``)``'Tony'` `# 假设在设置cookie的时候使用的是相同的salt``>>> request.get_signed_cookie(``'non-existing-cookie'``)``...``KeyError: ``'non-existing-cookie'`  `# 没有相应的键时触发异常``>>> request.get_signed_cookie(``'non-existing-cookie'``, False)``False``>>> request.get_signed_cookie(``'cookie-that-was-tampered-with'``)``...``BadSignature: ...  ``>>> request.get_signed_cookie(``'name'``, max_age=60)``...``SignatureExpired: Signature age 1677.3839159 > 60 seconds``>>> request.get_signed_cookie(``'name'``, False, max_age=60)``False`
```

 **5.`HttpRequest.is_secure`()**

```
`如果请求时是安全的，则返回True；即请求通是过 HTTPS 发起的。`
```

 **6.`HttpRequest.is_ajax`()**

```
`如果请求是通过XMLHttpRequest 发起的，则返回True，方法是检查 HTTP_X_REQUESTED_WITH 相应的首部是否是字符串``'XMLHttpRequest'``。` `大部分现代的 JavaScript 库都会发送这个头部。如果你编写自己的 XMLHttpRequest 调用（在浏览器端），你必须手工设置这个值来让 is_ajax() 可以工作。` `如果一个响应需要根据请求是否是通过AJAX 发起的，并且你正在使用某种形式的缓存例如Django 的 cache middleware， 你应该使用 vary_on_headers(``'HTTP_X_REQUESTED_WITH'``) 装饰 你的视图以让响应能够正确地缓存。`
```

 **7.`HttpRequest.read`(size=None)**

```
`像文件一样读取请求报文的内容主体，同样的，还有以下方法可用。` `HttpRequest.readline()` `HttpRequest.readlines()` `HttpRequest.xreadlines()` `其行为和文件操作中的一样。` `HttpRequest.__iter__()：说明可以使用 ``for` `的方式迭代文件的每一行。`
```