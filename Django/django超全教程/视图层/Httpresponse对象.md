# HttpResponse对象

阅读: 18321     [评论](http://www.liujiangblog.com/course/django/140#comments)：2

类定义：class HttpResponse[source]

HttpResponse类定义在django.http模块中。

HttpRequest对象由Django自动创建，而HttpResponse对象则由程序员手动创建.

我们编写的每个视图都要实例化、填充和返回一个HttpResponse对象。也就是函数的return值。

## 一、使用方法

### 1. 传递一个字符串

最简单的方式是传递一个字符串作为页面的内容到HttpResponse构造函数，并返回给用户:

```
>>> from django.http import HttpResponse
>>> response = HttpResponse("Here's the text of the Web page.")
>>> response = HttpResponse("Text only, please.", content_type="text/plain")
```

可以将response看做一个类文件对象，使用wirte()方法不断地往里面增加内容。

```
>>> response = HttpResponse()
>>> response.write("<p>Here's the text of the Web page.</p>")
>>> response.write("<p>Here's another paragraph.</p>")
```

### 2. 传递可迭代对象

HttpResponse会立即处理这个迭代器，并把它的内容存成字符串，最后废弃这个迭代器。比如文件在读取后，会立刻调用close()方法，关闭文件。

### 3. 设置头部字段

可以把HttpResponse对象当作一个字典一样，在其中增加和删除头部字段。

```
>>> response = HttpResponse()
>>> response['Age'] = 120
>>> del response['Age']
```

注意！与字典不同的是，如果要删除的头部字段如果不存在，del不会抛出KeyError异常。

HTTP的头部字段中不能包含换行。所以如果我们提供的头部字段值包含换行符（CR或者LF），将会抛出BadHeaderError异常。

### 4. 告诉浏览器将响应视为文件附件

让浏览器以文件附件的形式处理响应, 需要声明`content_type`类型和设置`Content-Disposition`头信息。 例如，给浏览器返回一个微软电子表格：

```
>>> response = HttpResponse(my_data, content_type='application/vnd.ms-excel')
>>> response['Content-Disposition'] = 'attachment; filename="foo.xls"'
```

## 二、属性

### 1. HttpResponse.content

响应的内容。bytes类型。

### 2. HttpResponse.charset

编码的字符集。 如果没指定，将会从`content_type`中解析出来。

### 3. HttpResponse.status_code

响应的状态码，比如200。

### 4. HttpResponse.reason_phrase

响应的HTTP原因短语。 使用标准原因短语。

除非明确设置，否则`reason_phrase`由`status_code`的值决定。

### 5. HttpResponse.streaming

这个属性的值总是False。由于这个属性的存在，使得中间件能够区别对待流式响应和常规响应。

### 6. HttpResponse.closed

如果响应已关闭，那么这个属性的值为True。

## 三、 方法

### 1. HttpResponse.**init**(content='', content_type=None, status=200, reason=None, charset=None)[source]

响应的实例化方法。使用content参数和`content-type`实例化一个HttpResponse对象。

content应该是一个迭代器或者字符串。如果是迭代器，这个迭代期返回的应是一串字符串，并且这些字符串连接起来形成response的内容。 如果不是迭代器或者字符串，那么在其被接收的时候将转换成字符串。

`content_type`是可选地，用于填充HTTP的`Content-Type`头部。如果未指定，默认情况下由`DEFAULT_CONTENT_TYPE`和`DEFAULT_CHARSET`设置组成：`text/html; charset=utf-8`。

status是响应的状态码。reason是HTTP响应短语。charset是编码方式。

### 2. HttpResponse.has_header(header)

检查头部中是否有给定的名称（不区分大小写），返回True或 False。

### 3. HttpResponse.setdefault(header, value)

设置一个头部，除非该头部已经设置过了。

### 4. HttpResponse.set_cookie(key, value='', max_age=None, expires=None, path='/', domain=None, secure=None, httponly=False)

设置一个Cookie。 参数与Python标准库中的Morsel.Cookie对象相同。

max_age: 生存周期，以秒为单位。

expires：到期时间。

domain: 用于设置跨域的Cookie。例如`domain=".lawrence.com"`将设置一个`www.lawrence.com`、`blogs.lawrence.com`和`calendars.lawrence.com`都可读的Cookie。 否则，Cookie将只能被设置它的域读取。

如果你想阻止客服端的JavaScript访问Cookie，可以设置httponly=True。

### 5. HttpResponse.set_signed_cookie(key, value, salt='', max_age=None, expires=None, path='/', domain=None, secure=None, httponly=True)

与`set_cookie()`类似，但是在设置之前将对cookie进行加密签名。通常与`HttpRequest.get_signed_cookie()`一起使用。

### 6. HttpResponse.delete_cookie(key, path='/', domain=None)

删除Cookie中指定的key。

由于Cookie的工作方式，path和domain应该与`set_cookie()`中使用的值相同，否则Cookie不会删掉。

### 7. HttpResponse.write(content)[source]

将HttpResponse实例看作类似文件的对象，往里面添加内容。

### 8. HttpResponse.flush()

清空HttpResponse实例的内容。

### 9. HttpResponse.tell()[source]

将HttpResponse实例看作类似文件的对象，移动位置指针。

### 10. HttpResponse.getvalue()[source]

返回HttpResponse.content的值。 此方法将HttpResponse实例看作是一个类似流的对象。

### 11. HttpResponse.readable()

Django1.10中的新功能，值始终为False。

### 12. HttpResponse.seekable()

Django1.10中的新功能，值始终为False。

### 13. HttpResponse.writable()[source]

Django1.10中的新功能，值始终为True。

### 14. HttpResponse.writelines(lines)[source]

将一个包含行的列表写入响应对象中。 不添加分行符。

## 四、HttpResponse的子类

Django包含了一系列的HttpResponse衍生类（子类），用来处理不同类型的HTTP响应。与HttpResponse相同, 这些衍生类存在于django.http之中。

- class HttpResponseRedirect[source]：重定向，返回302状态码。已经被redirect()替代。
- class HttpResponsePermanentRedirect[source]:永久重定向，返回301状态码。
- class HttpResponseNotModified[source]：未修改页面，返回304状态码。
- class HttpResponseBadRequest[source]：错误的请求，返回400状态码。
- class HttpResponseNotFound[source]：页面不存在，返回404状态码。
- class HttpResponseForbidden[source]：禁止访问，返回403状态码。
- class HttpResponseNotAllowed[source]：禁止访问，返回405状态码。
- class HttpResponseGone[source]：过期，返回405状态码。
- class HttpResponseServerError[source]：服务器错误，返回500状态码。

## 五、JsonResponse类

class JsonResponse（data，encoder = DjangoJSONEncoder，safe = True，json_dumps_params = None ，** kwargs）[source]

JsonResponse是HttpResponse的一个子类，是Django提供的用于创建JSON编码类型响应的快捷类。

它从父类继承大部分行为，并具有以下不同点：

它的默认Content-Type头部设置为application/json。

它的第一个参数data，通常应该为一个字典数据类型。 如果safe参数设置为False，则可以是任何可JSON 序列化的对象。

encoder默认为`django.core.serializers.json.DjangoJSONEncoder`，用于序列化数据。

布尔类型参数safe默认为True。 如果设置为False，可以传递任何对象进行序列化（否则，只允许dict 实例）。

典型的用法如下：

```
>>> from django.http import JsonResponse
>>> response = JsonResponse({'foo': 'bar'})
>>> response.content
b'{"foo": "bar"}'
```

若要序列化非dict对象，必须设置safe参数为False：

```
>>> response = JsonResponse([1, 2, 3], safe=False)
```

如果不传递safe=False，将抛出一个TypeError。

如果你需要使用不同的JSON 编码器类，可以传递encoder参数给构造函数：

```
>>> response = JsonResponse(data, encoder=MyJSONEncoder)
```

## 六、StreamingHttpResponse类

StreamingHttpResponse类被用来从Django响应一个流式对象到浏览器。如果生成的响应太长或者是占用的内存较大，这么做可能更有效率。 例如，它对于生成大型的CSV文件非常有用。

StreamingHttpResponse不是HttpResponse的衍生类（子类），因为它实现了完全不同的应用程序接口。但是，除了几个明显不同的地方，两者几乎完全相同。

## 七、FileResponse

文件类型响应。通常用于给浏览器返回一个文件附件。

FileResponse是StreamingHttpResponse的衍生类，为二进制文件专门做了优化。

FileResponse需要通过二进制模式打开文件，如下:

```
>>> from django.http import FileResponse
>>> response = FileResponse(open('myfile.png', 'rb'))
```