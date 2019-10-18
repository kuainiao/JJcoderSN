# HttpRequest对象

阅读: 16686     [评论](http://www.liujiangblog.com/course/django/138#comments)：4

每当一个用户请求发送过来，Django将HTTP数据包中的相关内容，打包成为一个HttpRequest对象，并传递给每个视图函数作为第一位置参数，也就是request，供我们调用。

HttpRequest对象中包含了非常多的重要的信息和数据，应该熟练掌握它。

类定义：class HttpRequest[source]

## 一、属性

HttpRequest对象的大部分属性是只读的，除非特别注明。

### 1. HttpRequest.scheme

字符串类型，表示请求的协议种类，'http'或'https'。

### 2. HttpRequest.body

bytes类型，表示原始HTTP请求的正文。它对于处理非HTML形式的数据非常有用：二进制图像、XML等。如果要处理常规的表单数据，应该使用HttpRequest.POST。

还可以使用类似读写文件的方式从HttpRequest中读取数据，参见HttpRequest.read()。

### 3. HttpRequest.path

字符串类型，表示当前请求页面的完整路径，但是不包括协议名和域名。例如："/music/bands/the_beatles/"。这个属性，常被用于我们进行某项操作时，如果不通过，返回用户先前浏览的页面。非常有用！

### 4. HttpRequest.path_info

在某些Web服务器配置下，主机名后的URL部分被分成脚本前缀部分和路径信息部分。`path_info` 属性将始终包含路径信息部分，不论使用的Web服务器是什么。使用它代替path可以让代码在测试和开发环境中更容易地切换。

例如，如果应用的WSGIScriptAlias设置为`/minfo`，那么`HttpRequest.path`等于`/music/bands/the_beatles/` ，而`HttpRequest.path_info`为`/minfo/music/bands/the_beatles/`。

### 5. HttpRequest.method

字符串类型，表示请求使用的HTTP方法。默认为大写。 像这样：

```
if request.method == 'GET':
    do_something()
elif request.method == 'POST':
    do_something_else()
```

通过这个属性来判断请求的方法，然后根据请求的方法不同，在视图中执行不同的代码。

### 6. HttpRequest.encoding

字符串类型，表示提交的数据的编码方式（如果为None 则表示使用`DEFAULT_CHARSET`设置）。 这个属性是可写的，可以通过修改它来改变表单数据的编码。任何随后的属性访问（例如GET或POST）将使用新的编码方式。

### 7. HttpRequest.content_type

Django1.10中新增。表示从`CONTENT_TYPE`头解析的请求的MIME类型。

### 8. HttpRequest.content_params

Django 1.10中新增。包含在`CONTENT_TYPE`标题中的键/值参数字典。

### 9 HttpRequest.GET

一个类似于字典的对象，包含GET请求中的所有参数。 详情参考QueryDict文档。

### 10. HttpRequest.POST

一个包含所有POST请求的参数，以及包含表单数据的字典。 详情请参考QueryDict文档。 如果需要访问请求中的原始或非表单数据，可以使用`HttpRequest.body`属性。

注意：请使用`if request.method == "POST"`来判断一个请求是否POST类型，而不要使用`if request.POST`。

POST中不包含上传文件的数据。

### 11. HttpRequest.COOKIES

包含所有Cookie信息的字典。 键和值都为字符串。可以类似字典类型的方式，在cookie中读写数据，但是注意cookie是不安全的，因此，不要写敏感重要的信息。

### 12. HttpRequest.FILES

一个类似于字典的对象，包含所有上传的文件数据。 FILES中的每个键为`<input type="file" name="" />`中的name属性值。 FILES中的每个值是一个`UploadedFile`。

要在Django中实现文件上传，就要靠这个属性！

如果请求方法是POST且请求的`<form>`中带有`enctype="multipart/form-data"`属性，那么FILES将包含上传的文件的数据。 否则，FILES将为一个空的类似于字典的对象，属于被忽略、无用的情形。

### 13. HttpRequest.META

包含所有HTTP头部信息的字典。 可用的头部信息取决于客户端和服务器，下面是一些示例：

- CONTENT_LENGTH —— 请求正文的长度（以字符串计）。
- CONTENT_TYPE —— 请求正文的MIME类型。
- HTTP_ACCEPT —— 可接收的响应`Content-Type`。
- HTTP_ACCEPT_ENCODING —— 可接收的响应编码类型。
- HTTP_ACCEPT_LANGUAGE —— 可接收的响应语言种类。
- HTTP_HOST —— 客服端发送的Host头部。
- HTTP_REFERER —— Referring页面。
- HTTP_USER_AGENT —— 客户端的`user-agent`字符串。
- QUERY_STRING —— 查询字符串。
- REMOTE_ADDR —— 客户端的IP地址。想要获取客户端的ip信息，就在这里！
- REMOTE_HOST —— 客户端的主机名。
- REMOTE_USER —— 服务器认证后的用户，如果可用。
- REQUEST_METHOD —— 表示请求方法的字符串，例如"GET" 或"POST"。
- SERVER_NAME —— 服务器的主机名。
- SERVER_PORT —— 服务器的端口（字符串）。

以上只是比较重要和常用的，还有很多未列出。

从上面可以看到，除`CONTENT_LENGTH`和`CONTENT_TYPE`之外，请求中的任何HTTP头部键转换为META键时，都会将所有字母大写并将连接符替换为下划线最后加上`HTTP_`前缀。所以，一个叫做`X-Bender`的头部将转换成META中的`HTTP_X_BENDER`键。

### 13. HttpRequest.resolver_match

代表一个已解析的URL的ResolverMatch实例。

## 二、可自定义的属性

Django不会自动设置下面这些属性，而是由你自己在应用程序中设置并使用它们。

### 1. HttpRequest.current_app

表示当前app的名字。url模板标签将使用其值作为`reverse()`方法的`current_app`参数。

### 2. HttpRequest.urlconf

设置当前请求的根`URLconf`，用于指定不同的url路由进入口，这将覆盖settings中的`ROOT_URLCONF`设置。

将它的值修改为None，可以恢复使用`ROOT_URLCONF`设置。

## 三、由中间件设置的属性

Django的contrib应用中包含的一些中间件会在请求上设置属性。

### 1. HttpRequest.session

SessionMiddleware中间件：一个可读写的，类似字典的对象，表示当前会话。我们要保存用户状态，回话过程等等，靠的就是这个中间件和这个属性。

### 2. HttpRequest.site

CurrentSiteMiddleware中间件：`get_current_site()`方法返回的Site或RequestSite的实例，代表当前站点是哪个。

Django是支持多站点的，如果你同时上线了几个站点，就需要为每个站点设置一个站点id。

### 3. HttpRequest.user

AuthenticationMiddleware中间件：表示当前登录的用户的`AUTH_USER_MODEL`的实例，这个模型是Django内置的Auth模块下的User模型。如果用户当前未登录，则user将被设置为`AnonymousUser`的实例。

可以使用`is_authenticated`方法判断当前用户是否合法用户，如下所示：

```
if request.user.is_authenticated:
    ... # Do something for logged-in users.
else:
    ... # Do something for anonymous users.
```

## 四、方法

### 1. HttpRequest.get_host()[source]

根据`HTTP_X_FORWARDED_HOST`和`HTTP_HOST`头部信息获取请求的原始主机。 如果这两个头部没有提供相应的值，则使用`SERVER_NAME`和`SERVER_PORT`。

例如："127.0.0.1:8000"

注：当主机位于多个代理的后面，`get_host()`方法将会失败。解决办法之一是使用中间件重写代理的头部，如下面的例子：

```
from django.utils.deprecation import MiddlewareMixin

class MultipleProxyMiddleware(MiddlewareMixin):
    FORWARDED_FOR_FIELDS = [
        'HTTP_X_FORWARDED_FOR',
        'HTTP_X_FORWARDED_HOST',
        'HTTP_X_FORWARDED_SERVER',
    ]

    def process_request(self, request):
        """
        Rewrites the proxy headers so that only the most
        recent proxy is used.
        """
        for field in self.FORWARDED_FOR_FIELDS:
            if field in request.META:
                if ',' in request.META[field]:
                    parts = request.META[field].split(',')
                    request.META[field] = parts[-1].strip()
```

### 2. HttpRequest.get_port()[source]

使用META中`HTTP_X_FORWARDED_PORT`和`SERVER_PORT`的信息返回请求的始发端口。

### 3. HttpRequest.get_full_path()[source]

返回包含完整参数列表的path。例如：`/music/bands/the_beatles/?print=true`

### 4. HttpRequest.build_absolute_uri(location)[source]

返回location的绝对URI形式。 如果location没有提供，则使用`request.get_full_path()`的值。

例如："https://example.com/music/bands/the_beatles/?print=true"

注：不鼓励在同一站点混合部署HTTP和HTTPS，如果需要将用户重定向到HTTPS，最好使用Web服务器将所有HTTP流量重定向到HTTPS。

### 5. HttpRequest.get_signed_cookie(key, default=RAISE_ERROR, salt='', max_age=None)[source]

从已签名的Cookie中获取值，如果签名不合法则返回django.core.signing.BadSignature。

可选参数salt用来为密码加盐，提高安全系数。 `max_age`参数用于检查Cookie对应的时间戳是否超时。

范例：

```
>>> request.get_signed_cookie('name')
'Tony'
>>> request.get_signed_cookie('name', salt='name-salt')
'Tony' # assuming cookie was set using the same salt
>>> request.get_signed_cookie('non-existing-cookie')
...
KeyError: 'non-existing-cookie'
>>> request.get_signed_cookie('non-existing-cookie', False)
False
>>> request.get_signed_cookie('cookie-that-was-tampered-with')
...
BadSignature: ...
>>> request.get_signed_cookie('name', max_age=60)
...
SignatureExpired: Signature age 1677.3839159 > 60 seconds
>>> request.get_signed_cookie('name', False, max_age=60)
False
```

### 6. HttpRequest.is_secure()[source]

如果使用的是Https，则返回True，表示连接是安全的。

### 7. HttpRequest.is_ajax()[source]

如果请求是通过XMLHttpRequest生成的，则返回True。

这个方法的作用就是判断，当前请求是否通过ajax机制发送过来的。

### 8. HttpRequest.read(size=None)[source]

### 9. HttpRequest.readline()[source]

### 10. HttpRequest.readlines()[source]

### 11. HttpRequest.xreadlines()[source]

### 12. HttpRequest.**iter**()

上面的几个方法都是从HttpRequest实例读取文件数据的方法。

可以将HttpRequest实例直接传递到XML解析器，例如ElementTree：

```
import xml.etree.ElementTree as ET
for element in ET.iterparse(request):
    process(element)
```