# Django架构流程分析

# 中间件

中间件是一个钩子框架，它们可以介入`Django`的请求和响应处理过程。它是一个轻量级、底层的“插件”系统，用于在全局修改`Django`的输入和输出。
每个中间件组件负责完成某个特定的功能。例如，`Django`包含的一个中间件组件`AuthenticationMiddleware`，它使用会话将用户和请求关联起来。

### 编写自己的中间件

中间件工厂是可调用的，它接收一个可调用的`get_response`作为参数，返回一个中间件。一个中间件是可调用的，它接收`request`，返回`response`，就像`view`。
一个中间件可以是一个函数，像下面这样：

```python
  def simple_middleware(get_response):
      #One-time configuration and initialization.
      def middleware(request):
          #Code to be executed for each request before the view(and later middleware) are called.
          response = get_response(request)
          #Code to be executed for each request/response after the view is called.
          return response
      return middlware
```

或者可以写一个类，它的实例是可调用的，就像：

```ruby
  class SimpleMiddleware(object):
        def __init__(self, get_response):
            self.get_response = get_response
            #One-time configuration and initialization.
        def __call__(self, request):
            #Code to be executed for each request before the view(and later middleware) are called.
            response = self.get_response(request)
            #Code to be executed for each request/response after the view is called.
            return response
```

这个调用的`get_response`是由`Django`提供的，可能是真正的视图(如果是最后一个中间件)或者是下一个中间件提供的。当前中间件无需关注它是什么只需要知道它代表了下一步将要发生什么。

中间件可以存在于你`Python`路径的任何地方。
__init__(get_response)
中间件工厂必须接收一个`get_response`参数。你可以初始化中间件的一些全局状态。时刻谨记一些警告：

1. `Django`通过唯一的`get_response`参数，初始化你的中间件，因此，你不能定义`__init__()`一些其他的参数；
2. 不像`__call__()`方法会在每次请求的时候调用一次。`__init__()`方法只在服务器启动的时候调用一次。

### 标记中间件不被使用

有时候在运行时决定一个中间件是否使用是很有用的。在这种情况下，你的中间件中的`__init__`方法可以抛出一个`django.core.exceptions.MiddlewareNotUsed`异常。Django会从中间件处理过程中移除这个中间件，并且当`DEBUG`为`True`的时候在`django.request`记录器中记录调试信息。

### 激活中间件

要激活一个中间件组件，需要把它添加到`Django`配置文件中的`MIDDLEWARE_CLASSES`列表。
在`MIDDLEWARE_CLASSES`中，每一个中间件组件用字符串的方式描述：一个完整的中间件工厂类或者函数所在的`Python`路径。例如，使用`django-amdin startproject`创建工程的时候生成的默认值：

```bash
  MIDDLEWARE = [
  'django.middleware.security.SecurityMiddleware',
  'django.contrib.sessions.middleware.SessionMiddleware',
  'django.middleware.common.CommonMiddleware',
  'django.middleware.csrf.CsrfViewMiddleware',
  'django.contrib.auth.middleware.AuthenticationMiddleware',
  'django.contrib.messages.middleware.MessageMiddleware',
  'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
```

Django的程序中，中间件不是必需的---只要你喜欢， MIDDLWWARE_CLASSES可以为空---但是强烈推荐你至少使用CommonMiddleware。MIDDLEWARE_CLASSES中的顺序非常重要，因为一个中间件可能依赖于另外一个。例如，AuthenticationMiddleware在会话(session)中储存已认证的用户。所以它必须在SessionMiddleware之后运行。

### 中间件的顺序和层次

在请求阶段，调用视图之前，`Django`会按照`MIDDLEWARE_CLASSES`中定义的顺序自顶向下应用中间件。会用到两个钩子：

- process_request();
- process_view();

在响应阶段，调用视图之后，中间件会按照相反的顺序应用，自底向上。会用到三个钩子：

- process_exception();
- process_template_response();
- process_response()



![img](https://upload-images.jianshu.io/upload_images/2153494-f3adf56de6558fd4.png?imageMogr2/auto-orient/strip|imageView2/2/w/641/format/webp)

image.png

你可以把它想象成一颗洋葱：每个中间件都是包裹视图的一层“皮”，而视图就是洋葱心。如果`request`通过洋葱的各层(每层通过调用`get_response`传递`request`到下一层)，传向中心的视图，`response`会原路返回穿过各层。
如果某一次决定短路直接返回`response`(不再调用`get_response`)，余下的各层和视图将不会见到任何`request和response`。

# Django的运行方式

运行`Django`项目的方法很多，一种是在开发和调试中经常用到的`runserver`方法，使用`Django`自己的`Web Server`。另外一种就是使用`fastcgi, uWSGI`等协议运行`Django`项目，这里以`uWSGI`为例。

##### 1.runserver方法

`runserver`方法是调用`Django`时经常用到的运行方式，主要用在测试和开发中使用，使用方法如下：

```css
    Usage: manage.py runserver [options: port number or ipaddr]
    #python manage.py runserver #default port is 8000
    #python manage.py runserver 8080
    #python manage.py runserver 127.0.0.1:9000
```

看一下`manage.py`的源代码，你会发现上面的命令其实是通过`Django`的`execute_from_command_line`方法执行了内部实现的`runserver`命令，那么现在看一下`runserver`具体做了什么。
`runserver`命令主要做了两件事情：

1. 解析参数，并通过`django.core.servers.basehttp.get_internal_wsgi_application`方法获取`wsgi handler`；

2. 根据`ip address`和`port`生成一个`WSGIServer`对象，接受用户请求，`get_internal_wsgi_application`的源码如下：

    ```python
     def get_internal_wsgi_application():
       """
       Loads and returns the WSGI application as configured by the
       user in ``settings.WSGI_APPLICATION``. With the default   
       ``startproject`` layout, this will be the ``application`` object in 
       ``projectname/wsgi.py``.
       This function, and the ``WSGI_APPLICATION`` setting itself, are     
       only useful for Django's internal servers (runserver, runfcgi); 
       external WSGI servers should just be configured to point to the 
       correct application object directly.
       If settings.WSGI_APPLICATION is not set (is ``None``), we just   
       return whatever ``django.core.wsgi.get_wsgi_application`` returns.
       """
       from django.conf import settings
       app_path = getattr(settings, 'WSGI_APPLICATION')
       if app_path is None:
             return get_wsgi_application()
       return import_by_path(
             app_path,
             error_prefix="WSGI application '%s' could not be loaded; " % app_path
       )
    ```

通过上面的代码我们可以知道，`Django`会先根据`settings`中的`WSGI_APPLICATION`来获取`handler`；在创建`project`的时候，`Django`会默认创建一个`wsgi.py`文件，而`settings`中的`WSGI_APPLICATION`配置也会默认指向这个文件。看一下这个`wsgi.py`文件，其实它也和上面的逻辑一样，最终调用````get_wsgi_application```实现。

##### 2.uWSGI方法

`uWSGI+Nginx`的方法是现在最常见的在生产环境中运行`Django`的方法，要了解这种方法，首先要了解一下`WSGI`和`uWSGI`协议。

- `WSGI`:全称`Web Server Gateway Interface`，或者`Python Web Server Gateway Interface`，是为`Python`语言定义的`Web`服务器和`Web`应用程序或框架之间的一种简单而通用的接口，基于现存的`CGI`标准而设计的。`WSGI`其实就是一个网关(`Gateway`)，其作用就是在协议之间进行转换。
- `uWSGI`:是一个`Web`服务器，它实现了`WSGI协议、uwsgi、http`等协议。注意`uWSGI`是一种通信协议，而`uWSGI`是实现`uwsgi协议和WSGI协议`的`Web`服务器。`uWSGI`具有超快的性能、低内存占用和多`app`管理等优点。

# HTTP请求处理流程

`Django`和其他`Web`框架一样，`HTTP`的处理流程基本类似：接收`request`，返回`response`内容。`Django`的具体处理流程大致如下图所示：

1. 加载`project settings`
    在通过`django-admin.py`创建`project`的时候，`Django`会自动生成默认的`settings`文件和`manage.py`等文件，在创建`WSGIServer`之前会执行下面的引用：
    from django.conf import settings
    上面引用在执行时，会读取`os.environ`中的`DJANGO_SETTINGS_MODULE`配置，加载项目配置文件，生成`settings`对象。所以，在`manage.py`文件中你可以看到，在获取`WSGIServer`之前，会先将`project`的`settings`路径加到`os`路径中。
    
2. 创建`WSGIServer`
    不管是使用`runserver`还是`uWSGI`运行`Django`项目，在启动时都会调用`django.core.servers.basehttp`中的`run()`方法，创建一个`django.core.servers.basehttp.WSGIServer`类的实例，之后调用其`serve_forever()`方法启动`HTTP`服务。`run`方法的源码如下：
    
    ```python
    def run(addr, port, wsgi_handler, ipv6=False, threading=False):
    	server_address = (addr, port)
    	if threading:
    		httpd_cls = type(str('WSGIServer'), (socketserver.ThreadingMixIn, WSGIServer), {})
    	else:
    		httpd_cls = WSGIServer
    	httpd = httpd_cls(server_address, WSGIRequestHandler, ipv6=ipv6)
    # Sets the callable application as the WSGI application that will receive requests
    httpd.set_app(wsgi_handler)
    httpd.serve_forever()
    ```
    
    如上，我们可以看到：在创建`WSGIServer`实例的时候会指定`HTTP`请求的`Handler`，上述代码使用`WSGIRequestHandler`。当用户的`HTTP`请求到达服务器时，`WSGIServer`会创建`WSGIRequestHandler`实例，使用其`handler`方法来处理`HTTP`请求(其实最终是调用`wsgiref.handlers.BaseHandler`中的`run`方法处理)。`WSGIServer`通过`set_app`方法设置一个可调用`(callable)`的对象作为`application`，上面提到的`handler`方法最终会调用设置的application处理`request`，并返回`response`。
    其中，`WSGIServer`继承自`wsgiref.simple_server.WSGIServer`，而`WSGIRequestHandler`继承自`wsgiref.simple_server.WSGIRequestHandler`，`wsgiref`是`Python`标准库给出的`WSGI`的参考实现。
    
    如上，我们可以看到：在创建`WSGIServer`实例的时候会指定`HTTP`请求的`Handler`，上述代码使用`WSGIRequestHandler`。当用户的`HTTP`请求到达服务器时，`WSGIServer`会创建`WSGIRequestHandler`实例，使用其`handler`方法来处理`HTTP`请求(其实最终是调用`wsgiref.handlers.BaseHandler`中的`run`方法处理)。`WSGIServer`通过`set_app`方法设置一个可调用`(callable)`的对象作为`application`，上面提到的`handler`方法最终会调用设置的application处理`request`，并返回`response`。
    其中，`WSGIServer`继承自`wsgiref.simple_server.WSGIServer`，而`WSGIRequestHandler`继承自`wsgiref.simple_server.WSGIRequestHandler`，`wsgiref`是`Python`标准库给出的`WSGI`的参考实现。
    
3. 处理`Request`
    第二步中说到的`application`，在`Django`中一般是`django.core.handlers.wsgi.WSGIHandler`对象，`WSGIHandler`继承自`django.core.handlers.base.BaseHandler`，这个是`Django`处理`request`的核心逻辑，它会创建一个`WSGIRequest`实例，而`WSGIRequest`是从`http.HttpRequest`继承而来。
    
4. 返回`Response`
    上面提到的`BaseHandler`中有个`get_response`方法，该方法会先加载`Django`项目的`ROOT_URLCONF`，然后根据`url`规则找到对应的`view`方法(类)，`view`逻辑会根据`request`实例生成并返回具体的`response`。

在`Django`返回结果之后，第二步中提到`wsgiref.handlers.BaseHandler.run`方法会调用`finish_response`结束请求，并将内容返回给用户。



![img](https://upload-images.jianshu.io/upload_images/2153494-a665dd800e29d8cd.png?imageMogr2/auto-orient/strip|imageView2/2/w/467/format/webp)

Paste_Image.png





![img](https://upload-images.jianshu.io/upload_images/2153494-6db494d8322f1910.png?imageMogr2/auto-orient/strip|imageView2/2/w/531/format/webp)

Paste_Image.png



上面的两张流程图可以大致描述Django处理request的流程，按照流程图2的标注，可以分为以下几个步骤：

1.用户通过浏览器请求一个页面
2.请求到达Request Middlewares，中间件对request做一些预处理或者直接response请求
3.URLConf通过urls.py文件和请求的URL找到相应的View
4.View Middlewares被访问，它同样可以对request做一些处理或者直接返回response
5.调用View中的函数
6.View中的方法可以选择性的通过Models访问底层的数据
7.所有的Model-to-DB的交互都是通过manager完成的
8.如果需要，Views可以使用一个特殊的Context
9.Context被传给Template用来生成页面
a.Template使用Filters和Tags去渲染输出
b.输出被返回到View
c.HTTPResponse被发送到Response Middlewares
d.任何Response Middlewares都可以丰富response或者返回一个完全不同的response
e.Response返回到浏览器，呈现给用户

上述流程中最主要的几个部分分别是：Middleware(中间件，包括request, view, exception, response)，URLConf(url映射关系)，Template(模板系统)，下面一一介绍一下。

##### Middleware(中间件)

Middleware并不是Django所独有的东西，在其他的Web框架中也有这种概念。在Django中，Middleware可以渗入处理流程的四个阶段：request，view，response和exception，相应的，在每个Middleware类中都有process_request，process_view， process_response 和 process_exception这四个方法。你可以定义其中任意一个或多个方法，这取决于你希望该Middleware作用于哪个处理阶段。每个方法都可以直接返回response对象。

Middleware是在Django BaseHandler的load_middleware方法执行时加载的，加载之后会建立四个列表作为处理器的实例变量：
_request_middleware：process_request方法的列表
_view_middleware：process_view方法的列表
_response_middleware：process_response方法的列表
_exception_middleware：process_exception方法的列表
Django项目的安装并不强制要求任何中间件，如果你愿意，MIDDLEWARE_CLASSES可以为空。中间件出现的顺序非常重要：在request和view的处理阶段，Django按照MIDDLEWARE_CLASSES中出现的顺序来应用中间件，而在response和exception异常处理阶段，Django则按逆序来调用它们。也就是说，Django将MIDDLEWARE_CLASSES视为view函数外层的顺序包装子：在request阶段按顺序从上到下穿过，而在response则反过来。以下两张图可以更好地帮助你理解：





![img](https://upload-images.jianshu.io/upload_images/2153494-50a02beab48c1d58.png?imageMogr2/auto-orient/strip|imageView2/2/w/502/format/webp)

Paste_Image.png





![img](https://upload-images.jianshu.io/upload_images/2153494-90b2d9ef8e04e437.png?imageMogr2/auto-orient/strip|imageView2/2/w/899/format/webp)

Paste_Image.png

##### URLConf(URL映射)

如果处理request的中间件都没有直接返回response，那么Django会去解析用户请求的URL。URLconf就是Django所支撑网站的目录。它的本质是URL模式以及要为该URL模式调用的视图函数之间的映射表。通过这种方式可以告诉Django，对于这个URL调用这段代码，对于那个URL调用那段代码。具体的，在Django项目的配置文件中有ROOT_URLCONF常量，这个常量加上根目录”/”，作为参数来创建django.core.urlresolvers.RegexURLResolver的实例，然后通过它的resolve方法解析用户请求的URL，找到第一个匹配的view。

##### Template(模板)

大部分web框架都有自己的Template(模板)系统，Django也是。但是，Django模板不同于Mako模板和jinja2模板，在Django模板不能直接写Python代码，只能通过额外的定义filter和template tag实现。

# Django处理Request的详细流程

上述的第三步和第四步逻辑只是大致说了一下处理过程，Django在处理request的时候其实做了很多事情，下面我们详细的过一下。首先给大家分享两个网上看到的Django流程图：

# Django框架总览

如下图所示Django的架构总览图，整体上把握Django的组成。





![img](https://upload-images.jianshu.io/upload_images/2153494-c41d4c7324338600.png?imageMogr2/auto-orient/strip|imageView2/2/w/495/format/webp)

image.png



核心在于middleware(中间件)，Django所有的请求/返回都由中间件来完成。
中间件，就是处理HTTP的request和reponse的，类似插件，比如有request中间件、View中间件、response中间件、exception中间件等，Middleware都需要在"project/settings.py"中MIDDLEWARE_CLASS的定义。大致的程序流程图如下所示：



![img](https://upload-images.jianshu.io/upload_images/2153494-08122546813bc245.png?imageMogr2/auto-orient/strip|imageView2/2/w/687/format/webp)

image.png



首先，Middleware都需要在"project/settings.py"中的MIDDLEWARE_CLASSES定义，一个HTTP请求，将被这里指定的中间件从头到尾处理一遍，暂且称这些需要挨个处理的中间件为处理链，如果链中某个处理器处理后没有返回response，就把请求传递给下一个处理器；如果链中某个处理器返回了response，直接跳出处理链由response中间件处理后返回给客户端，可以称之为**短路处理**。

# 了解Django Middleware的几个关键方法

Django处理一个Request的过程是首先通过中间件，然后再通过默认的URL方式进行的。我们可以在Middleware这个地方把所有Request拦截住，用我们自己的方式完成处理以后直接返回Response。因此了解中间件的构成是非常必要的。

##### Initializer: __init__(self)

出于性能的考虑，每个已启用的中间件在每个服务器进程中只初始化一次。也就是说`__init__()`仅在服务进程启动的时候调用，而在针对单个request处理时并不执行。
对一个middleware而言，定义`__init__()`方法通常是为了检查自身的必要性。如果`__init__()`抛出异常`django.core.exception.MiddlewareNotUsed`，则Django将从middleware栈中移出该middleware。
在中间件中定义`__init__()`方法时，除了标准的self参数之外，不应该定义任何其它参数。

##### Request预处理函数:process_request(self, request)

这个方法的调用时机在Django接收到request之后，但仍未解析URL以确定应当运行的view之前。Django向它传入相应的HttpRequest对象，以便在方法中修改。
process_request()应当返回None或HttpResponse对象。
如果返回None，Django将继续处理这个request，执行后续的中间件，然后调用相应的view。
如果返回HttpResponse对象，Django将不再执行任何其它的中间件(无视其种类)以及相应的view。Django将立即返回该HttpResponse。

##### View预处理函数：process_view(self,request,callback,callback_args,callback_kwargs)

这个方法的调用时机在Django执行完request预处理函数并确定待执行的view之后，但在view函数实际执行之前。

- request：HttpRequest对象。
- callback：Django将调用的处理request的python函数。这是实际的函数对象本身，而不是字符串表述的函数名。
- args：将传入view的位置参数列表，但不包括request参数(它通常是传入view的第一个参数)。
- kwargs：将传入view的关键字参数字典。
    如同process_request()，process_view()应当返回None或者HttpResponse对象。如果返回None，Django将继续处理这个request，执行后续的中间件，然后调用相应的view。
    如果返回HttpResponse对象，Django将不再执行任何其它的中间件(不论种类)以及相应的view，Django将立即返回。

##### Response后处理函数:process_response(self, request, response)

这个方法的调用时机在Django执行view函数并生成response之后。
该处理器能修改response的内容：一个常见的用途是内容压缩，如gzip所请求的HTML页面。
这个方法的参数相当直观: request是request对象，而response则是从view中返回的response对象。
process_response()必须返回HttpResponse对象。这个response对象可以是传入函数的那个原始对象(通常已被修改)，也可以是全新生成的。

##### Exception后处理函数：process_exception(self, request, exception)

这个方法只有在request处理过程中出了问题并且view函数抛出了一个未捕获的异常时才会被调用。这个钩子可以用来发送错误通知，将现成相关信息输出到日志文件，或者甚至尝试从错误中自动恢复。
这个函数的参数除了一贯的request对象之外，还包括view函数抛出的实际的异常对象exception。
process_exception()应当返回None或者HttpResponse对象。
如果返回None，Django将用框架内置的异常处理机制继续处理相应request。
如果返回HttpResponse对象，Django将使用该response对象，而短路框架内置的异常处理机制。

# Django HTTP请求的处理流程

Django处理一个Request的过程是首先通过中间件，然后再通过默认的URL方式进行的。我们可以在Middleware这个地方把所有Request拦截住，用我们自己的方式完成处理以后直接返回Response。

1. 加载配置
    Django的配置都在"Project/settings.py"中定义，可以是Django的配置，也可以是自定义的配置，并且都通过django.conf.settings访问，非常方便。

2. 启动
    最核心的动作是通过`django.core.management.commands.runfcgi`的`Command`来启动，它运行`django.core.servers.fastcgi`中的runfastcgi，runfastcgi使用了flup的WSGIServer来启动fastcgi。而WSGIServer中携带了`django.core.servers.fastcgi`的WSGIHandler类的一个实例，通过WSGIHandler来处理由Web服务器(比如Apache, Lighttpd等)传过来的请求，此时才是真正进入Django的世界。

3. 处理Request
    当有HTTP请求来时，WSGIHandler就开始工作了，它从BaseHandler继承而来。WSGIHandler为每个请求创建一个WSGIRequest实例，而WSGIRequest是从http.HttpRequest继承而来。接下来就开始创建Response了。

4. 创建Response
    BaseHandler的get_response方法就是根据request创建response，而具体生成response的动作就是执行urls.py中对应的view函数了，这也是Django可以处理“友好URL”的关键步骤，每个这样的函数都要返回一个Response实例。此时一般的做法是通过loader加载template并生成页面内容，其中重要的就是通过ORM技术从数据库中取出数据，并渲染到template中，从而生成具体的页面了。

5. 处理Response
    Django返回Response给flup，flup就取出Response的内容返回给Web服务器，由后者返回给浏览器。
    总之，Django在fastcgit中主要做了两件事：处理Request和创建Response，而它们对应的核心就是"urls分析"，“模板技术”和“ORM技术”。

    

    ![img](https://upload-images.jianshu.io/upload_images/2153494-6cbf4593fb91cae1.png?imageMogr2/auto-orient/strip|imageView2/2/w/467/format/webp)

    image.png

    如图所示，一个HTTP请求，首先被转化成一个HttpRequest对象，然后该对象被传递给Request中间件处理，如果该中间件返回了Response，则直接传递给Response中间件做收尾处理。否则的话Request中间将访问URL配置，确定哪个view来处理，在确定了哪个view要执行，但是还没有执行该view的时候，系统会把request传递给View中间件处理器进行处理，如果该中间件返回了Response，那么该Response直接被传递给Response中间件进行后续处理，否则将执行确定的View函数处理并返回Response，在这个过程中如果引发了异常并抛出，会被Exception中间件处理器进行处理。

# 请求处理机制其一:进入Django前的准备

##### 一个Request到达了！

首先发生的是一些和`Django`有关(前期准备)的其他事情，分别是：

- 如果是`Apache/mod_python`提供服务，`request`由`mod_python`创建的`django.core.handlers.modpython.ModPythonHander`实例传递给`Django`。
- 如果是其它服务器，则必须兼容`WSGI`，这样，服务器将创建一个`django.core.handlers.wsgi.WsgiHander`实例。
    这两个类都继承自`django.core.handlers.base.BaseHandler`，它包含对任何类型的`request`来说都需要的公共代码。

##### 快准备处理器(Handler)

当上面其中一个处理器实例化后，紧接着发生了一系列的事情;

1. 这个处理器(`handler`)导入你的`Django`配置文件；
2. 这个处理器导入`Django`的自定义异常类；
3. 这个处理器调用它自己的`load_middleware`方法，加载所有列在`MIDDLEWARE_CLASSES`中的`middleware`类并且内省它们。

最后一条有点复杂，我们仔细瞧瞧。
一个`middlware`类可以渗入处理过程中的四个阶段:`request, view, response和exception`。要做到这一点，只需要定义指定的、恰当的方法：`process_request，process_view，process_response和process_exceptions`。`middleware`可以定义其中任何一个或所有的这些方法，这取决于你想要它提供什么样的功能。

当处理器内省`middleware`时，它查找上述名字的方法，并建立四个列表作为处理器的实例变量：

- `_request_middleware`是一个保存`process_request`方法的列表(在每一种情况下，它们是真正的方法，可以直接调用)，这些方法来自于任一个定义了它们的`middleware`类。
- `_view_middlware`是一个保存`process_view`方法的列表，这些方法来自于任一个定义了它们的`middleware`类。
- `_response_middleware`是一个保存`process_response`方法的列表，这些方法来自于任一个定义了它们的`middleware`类。
- `_exception_middlware`是一个保存`process_exception`方法的列表，这些方法来自于任一个定义了它们的`middleware`类。

##### HttpRequest准备好了就可以进入Django

现在处理器已经准备好真正开始处理了，因此它给调度程序发送一个信号`request_started`(`Django`内部的调度程序允许各种不同的组件声明它们正在干什么，并可以写一些代码监听特定的事件。关于这一点目前还没有官方的文档，但在wiki上有一些注释)，接下来它实例化一个`django.http.HttpRequest`的子类。
根据不同的处理器，可能是`django.core.handlers.modpython.ModPythonRequest`的一个实例，也可能是`django.core.handlers.wsgi.WSGIRequest`的一个实例。需要两个不同的类是因为`mod_python`和`WSGI APIs`以不同的格式传入`request`信息，这个信息需要解析为`Django`能够处理的一个单独的标准格式。
一旦一个`HttpRequest`或者类似的东西存在了，处理器就调用它自己的`get_response`方法，传入这个`HttpRequest`作为唯一的参数。这里就是几乎所有真正的活动发生的地方。

# 请求处理机制其二:Django中间件的解析

##### Middleware开始工作了！

`get_response`做的第一件事就是遍历处理器的`_request_middleware`实例变量并调用其中的每一个方法，传入`HttpRequest`的实例作为参数。

```objectivec
  for middleware_method in self._request_middleware:
      response = middleware_method(request)
      if response:
         break
```

这些方法可以选择短路剩下的处理并立即让`get_response`返回，通过返回自身的一个值(如果他们这样做，返回值必须是`django.http.HttpResponse`的一个实例)。如果其中之一这样做了，我们会立即回到主处理器代码，`get_response`不会等着看其它`middleware`类想要做什么，它直接返回，然后处理器进入`response`阶段。
然而，更一般的情况是，这里应用的`middleware`方法简单地做一些处理并决定是否增加，删除或补充`request`的属性。

##### URL resolver的解析

假设没有一个作用于`request`的`middleware`直接返回`response`，处理器下一步会尝试解析请求的`URL`。它在配置文件中寻找一个叫做`ROOT_URLCONF`的配置，用这个配置加上根`/`，作为参数来创建`django.core.urlresolvers.RegexURLResolver`的一个实例，然后调用它的`resolve`方法来解析请求的`URL`路径。
`URL resolver`遵循一个相当简单的模式。对于在`URL`配置文件中根据`ROOT_URLCONF`的配置产生的每一个在`urlpatterns`列表中的条目，它会检查请求的`URL`路径是否与这个条目的正则表达式相匹配，如果是的话，有两种选择：
1.如果这个条目有一个可以调用的`include`，resolver截取匹配的`URL`，转到`include`指定的`URL`配置文件并开始遍历其中`urlpatterns`列表中的每一个条目。根据你`URL`的深度和模块性，这可能重复好几次。
2.否则，`resolver`返回三个条目：

- 匹配的条目指定的`view function`；

- 一个从`URL`得到的未命名匹配组(被用来作为`view`的位置参数);

- 一个关键字参数字典，它由从`URL`得到的任意命名匹配组和从`URLConf`中得到的任意其它关键字参数组合而成。
    注意这一过程会在匹配到第一个指定了`view`的条目时停止，因此最好让你的`URL`配置从复杂的正则过渡到简单的正则，这样能确保`resolver`不会首先匹配到简单的那一个而返回错误的`view function`。
    如果没有找到匹配的条目，`resolvers`会产生`django.core.urlresolvers.Resolver404`异常，它是`django.http.Http404`的子类。后面我们会知道它是如何处理的。

    ```objectivec
    #Apply view middleware
    for middleware_method in self._view_middleware:
        response = middleware_method(request, callback, callback_args, callback_kwargs)
        if response:
          break
    ```

一旦知道了所需的 `view function`和相关的参数，处理器就会查看它的`_view_middleware`列表，并调用其中的方法，传入 `HttpRequst，view function`，针对这个`view`的位置参数列表和关键字参数字典。
还有，`Middleware`有可能介入这一阶段并强迫处理器立即返回。

# 请求处理机制其三：view层与模板解析

##### 进入View了！

如果处理过程这时候还在继续的话，处理器会调用`view function`。`Django`中的`Views`不很严格因为它只需要满足几个条件：

- 必须可以调用；
- 必须接受`django.http.HttpRequest`的实例作为第一位置参数；
- 必须能产生一个异常或返回`django.http.HttpResponse`的一个实例；
    一般来说，`views`会使用`Django`的`database API`来创建、检索、更新和删除数据库的某些东西，还会加载并渲染一个模板来呈现一些东西给最终用户。

##### 模板

`Django`的模板系统有两个部分：一部分是给设计师使用的混入少量其它东西的`HTML`，另一部分是给程序员使用纯```Python``。
从一个HTML作者的角度，Django的模板系统非常简单，需要知道的仅有三个结构：

- 变量引用。在模板中是这样：{{foo}}。
- 模板过滤。在上面的例子中使用过滤竖线，类似{{foo|bar}}。通常这用来格式化输出(比如：运行Textile，格式化日期等等)。
- 模板标签。类似{%bar%}。这是模板的“逻辑”实现的地方，你可以{%if foo%},{%for bar in foo%},等等，if和for都是模板标签。
    变量引用以一种非常简单的方式工作。如果你只是要打印变量，只要{{foo}}，模板系统就会输出它。这里唯一的复杂情况是{{foo.bar}}，这时模板系统按顺序尝试几件事：

1. 首先它尝试一个字典的方式的查找，看看foo['bar']是否存在。如果存在，则它的值被输出，这个过程也随之结束。
2. 如果字典查找失败，模板系统尝试属性查找，看看foo.bar是否存在。同时它还检查这个属性是否可以被调用，如果可以，调用之。
3. 如果属性查找失败，模板系统尝试把它作为列表索引进行查找。
    如果所有这些都失败了，模板系统输出配置TEMPLATE_STRING_IF_INVALID的值，默认是空字符串。
    模板过滤就是简单的Python functions， 它接受一个值和一个参数，返回一个新的值。比如，date过滤用一个Python datetime对象作为它的值，一个标准的strftime格式化字符串作为它的参数，返回对datetime对象应用了格式化字符串之后的结果。
    模板标签用在事情有一点点复杂的地方，它是你了解 Django 的模板系统是如何真正工作的地方。

##### Django模板的结构

在内部，一个Django模板体现为一个'nodes'集合，它们都是从基本的django.template.Node类继承而来。Nodes可以做各种处理，但有一个共同点：每一个Node必须有一个叫做render的方法，它接受的第二个参数(第一个参数，是Node实例)是django.template.Context的一个实例，这是一个类似于字典的对象，包含所有模板可以获得的变量。Node 的 render 方法必须返回 一个字符串，但如果 Node 的工作不是输出（比如，它是要通过增加，删除或修 改传入的 Context 实例变量中的变量来修改模板上下文），可以返回空字符串。
Django 包含许多 Node 的子类来提供有用的功能。比如，每个内置的模板标签都 被一个 Node 的子类处理（比如，IfNode 实现了 if 标签，ForNode 实现了 for 标签，等等）。所有内置标签可以在 django.template.defaulttags 找到。



![img](https://upload-images.jianshu.io/upload_images/2153494-1b76130c57c8468c.png?imageMogr2/auto-orient/strip|imageView2/2/w/287/format/webp)

image.png



实际上，上面介绍的所有模板结构都是某种形式的Nodes。变量查找由VariableNode处理，出于自然，过滤也应用在VariableNode上，标签是各种类型的Nodes，纯文本是一个TextNode。
一般来说，一个view渲染一个模板要经过下面的步骤，依次是：

1. 加载需要渲染的模板。这是由django.template.loader.get_template完成的，它能利用这许多方法中的任意一个来定位需要的模板文件。get_template函数返回一个django.template.Template实例，其中包含经过解析的模板和用到的方法。
2. 实例化一个Context用来渲染模板。如果用的是Context的子类django.template.RequestContext，那么附带的上下文处理函数就会自动添加在view中没有定义的变量。Context的构建器方法用一个键/值对的字典作为它唯一的参数，RequestContext则用HttpRequest的一个实例和一个字典。
3. 调用Template实例的render方法，Context对象作为第一个位置参数。
    Template的render方法的返回值是一个字符串，它由Template中所有Nodes的render方法返回的值连接而成，调用顺序为它们出现在Template中的顺序。

##### 关于Response，一点点！

一旦一个模板完成渲染，或者产生了其它某些合适的输出，view就会负责产生一个django.http.HttpResponse实例，它的构建器接受两个可选的参数：

- 一个作为response主体的字符串(它应该是第一位置参数，或者是关键字参数content)。大部分时间，这将作为渲染一个模板的输出，但不是必须这样，在这里你可以传入任何有效的Python字符串。
- 作为reponse的Content-Type header的值(它应该是第二位置参数，或者是关键字参数mime_type)。如果没有提供这个参数，Django将会使用配置中`DEFAULT_MIME_TYPE`的值和`DEFAULT_CHARSET`的值，如果你没有在`Django`的全局配置文件中更改它们的话，分别是`'text/html'和‘utf-8’`。

##### 异常

如果`view`函数，后者其中的什么东西，发生了异常，那么`get_response`将遍历它的`_exception_middleware`实例变量并调用那里的每个方法，传入`HttpResponse`和这个`exception`作为参数。如果顺利，这些方法中的一个会实例化一个`HttpResponse`并返回它。
这时候有可能还是没有得到一个`HttpResponse`，这可能有几个原因：

- `view`可能没有返回值；
- `view`可能产生了异常但是没有一个`middleware`能够处理它；
- 一个`middleware`方法视图处理一个异常时自己又产生了一个新的异常。

这时候，`get_response`会回到自己的异常处理机制中，它们有几个层次：

1. 如果`exception`是`Http404`并且`DEBUG`设置为`True`，`get_response`将执行`view django.views.debug.technical_404_response`，传入`HttpRequest`和`exception`作为参数。这个`view`会展示`URL resolver`试图匹配的模式信息。
2. 如果`DEBUG`是`False`并且异常是`Http404`，`get_response`会调用`URL resolver`的`resolve_404`方法。这个方法查看`URL`配置以判断哪一个`view`被指定用来处理`404`错误。默认是`django.views.defaults.page_not_found`，但可以在`URL`配置中给`handler404`变量赋值来更改。
3. 对于任何其它类型的异常，如果`DEBUG`设置为`True`，`get_response`将执行`view.django.views.debug.technical_500_response`，传入`HttpRequest`和`exception`作为参数。这个`view`提供了关于异常的详细信息，包括`traceback`，每一个层次`stack`中的本地变量，`HttpRequest`对象的详细描述和所有无效配置的列表。
4. 如果 `DEBUG`是 `False`，`get_response`会调用 `URL resolver`的 `resolve_500`方法，它和`resolve_404`方法非常相似，这时默认的`view` 是 `django.views.defaults.server_error`，但可以在 `URL` 配置中给 `handler500` 变量赋值来更改。

此外，对于除了`django.http.Http404`或 `Python`内置的 `SystemExit`之外的任 何异常，处理器会给调度者发送信号`got_request_exception`，在返回之前，构建一个关于异常的描述，把它发送给列在 `Django` 配置文件的`ADMINS` 配置中的每一个人。
现在，无论 `get_response` 在哪一个层次上发生错误，它都会返回一个 `HttpResponse` 实例，因此我们回到处理器的主要部分。一旦它获得一个 `HttpResponse`它做的第一件事就是遍历它的````_response_middleware `实例变量并 应用那里的方法，传入`HttpRequest `和`HttpResponse``` 作为参数。

```php
    finally:
    # Reset URLconf for this thread on the way out for complete
    # isolation of request.urlconf
    urlresolvers.set_urlconf(None)

    try:
    # Apply response middleware, regardless of the response
    for middleware_method in self._response_middleware:
      response = middleware_method(request, response)
      response = self.apply_response_fixes(request, response)
```

一旦 `middleware` 完成了最后环节，处理器将给调度者发送 信号 `request_finished`，对与想在当前的 `request`中执行的任何东西来说，这是最后的调用。监听这个信号的处理者会清空并释放任何使用中的资源。比如，`Django` 的 `request_finished`监听者会关闭所有数据库连接。

这件事发生以后，处理器会构建一个合适的返回值送返给实例化它的任何东西 （现在，是一个恰当的 `mod_python response` 或者一个 `WSGI`兼容的 `response`，这取决于处理器）并返回。

这就是 `Django` 如何处理一个 `request`。

# Django中的request与resposne对象

##### 关于request与response

前面几个Sections介绍了关于Django请求(Request)处理的流程分析，我们也了解到，Django是围绕着Request与Response进行处理，也就是无外乎‘求’与‘应’。
当请求一个页面时，Django把请求的metadata数据包装成一个HttpRequest对象，然后Django加载合适的view方法，把这个HttpRequest对象，作为第一个参数传给view方法。任何view方法都应该返回一个HttpResponse对象。





![img](https://upload-images.jianshu.io/upload_images/2153494-95d70b2492e3e0ac.png?imageMogr2/auto-orient/strip|imageView2/2/w/373/format/webp)

Paste_Image.png

##### HttpRequest

HttpRequest对象表示来自某客户端的一个单独的HTTP请求。HttpRequest对象是Django自动创建的。
它的属性有很多，可以参考DjangoBook，比较常用的有以下几个：

1. method请求方法，如：

    ```bash
     if request.method == 'POST':
     ...
     elif request.method == 'GET':
      ...
    ```

2. 类字典对象GET、POST

3. COOKIES(字典形式)

4. user:
    一个django.contrib.auth.models.User对象表示当前登录用户，若当前用户尚未登录，user会设为django.contrib.auth.models.AnonymousUser的一个实例。
    可以将它们用is_authenticated()区分开:

    ```bash
     if request.user.is_authenticated():
      ...
     else:
      ...
    ```

5. session(字典形式)

6. request.META
    具体可以参考[《request.META里包含了哪些数据？》](https://link.jianshu.com/?t=http%3A%2F%2Fwww.nowamagic.net%2Facademy%2Fdetail%2F1318909)。
    request.META是一个Python字典，包含了所有本次HTTP请求的Header信息，比如用户IP地址和用户Agent(通常是浏览器的名称和版本号)。注意，Header信息的完整列表取决于用户所发送的Header信息和服务器端设置的Header信息。这个字典中几个常见的键值有：

- HTTP_REFERRER: 进站前链接网页，如果有的话；

- HTTP_USER_AGENT：用户浏览器的user-agent字符串，如果有的话，例如：Mozilla/5.0 (X11; U; Linux i686; fr-FR; rv:1.8.1.17) Gecko/20080829 Firefox/2.0.0.17" .

- REMOTE_ADDR:客户端IP，如"12.345.67.89"。(如果申请是经过代理服务器的话，那么它可能是以逗号分割的多个IP地址，如："12.345.67.89,23.456.78.90" 。)

    ```python
    def request_test(request):
    context={}
    try:
      http_referer=request.META['HTTP_REFERRER']
      http_user_agent=request.META['HTTP_USER_AGENT']
      remote_addr=request.META['REMOTE_ADDR']
      return HttpResponse('[http_user_agent]:%s,[remote_addr]=%s' %(http_user_agent,remote_addr))
    except Exception,e:
      return HttpResponse("Error:%s" %e)
    ```

注意：GET、POST属性都是django.http.QueryDict的实例，在DjangoBook可具体了解。

##### HttpResponse

Request和Response对象起到了服务器与客户端之间的信息传递作用。Request对象用于接收客户端浏览器提交的数据，而Response对象的功能则是将服务器端的数据发送到客户端浏览器。
比如在view层，一般都是以以下代码结束一个def:

```ruby
  return HttpResponse(html)
  return render_to_response('template.html',{'data':data})
```

对于HttpRequest对象来说，是由Django自动创建，但是，HttpResponse对象就必须我们自己创建。每个View方法必须返回一个HttpResponse对象。HttpResponse类在django.http.HttpResponse。

1. 构造HttpResponse
    HttpResponse类存在于django.http.HttpResponse，以字符串的形式传递给页面。一般地，你可以通过给HttpResponse的构造函数传递字符串表示的页面内容来构造HttpResponse对象：

    ```ruby
     >>> response = HttpResponse("Welcome to nowamagic.net.")
     >>> response = HttpResponse("Text only, please.", mimetype="text/plain")
    ```

但是如果想要增量添加内容，你可以把response当做filelike对象使用：

```ruby
    >>> response = HttpResponse()
    >>> response.write("<p>Welcome to nowamagic.net.</p>")
    >>> response.write("<p>Here's another paragraph.</p>")
```

也可以给HttpResponse传递一个iterator作为参数，而不用传递硬编码字符串。如果你使用这种技术，下面是需要注意的一些事项:

- iterator应该返回字符串；
- 如果HttpResponse使用iterator进行初始化，就不能把HttpResponse实例座位filelike对象使用。这样做将会抛出异常。
    最后，再说明一下，HttpResponse实现了write()方法，可以在任何需要filelike对象的地方使用HttpResponse对象。

1. 设置Headers
    你可以使用字典语法添加，删除 headers：

    ```ruby
     >>> response = HttpResponse() 
     >>> response['X-DJANGO'] = "It's the best."
     >>> del response['X-PHP']
     >>> response['X-DJANGO']
     "It's the best."
    ```

2. HttpResponse子类



![img](https://upload-images.jianshu.io/upload_images/2153494-1b2fe0dae32834fe.png?imageMogr2/auto-orient/strip|imageView2/2/w/547/format/webp)

Paste_Image.png



当然，你也可以自己定义不包含在上表中的HttpResponse子类。

# 参考

1. [http://www.nowamagic.net/academy/detail/13281808](https://link.jianshu.com/?t=http%3A%2F%2Fwww.nowamagic.net%2Facademy%2Fdetail%2F13281808)
2. [http://python.jobbole.com/80836/](https://link.jianshu.com/?t=http%3A%2F%2Fpython.jobbole.com%2F80836%2F)
3. [http://python.usyiyi.cn/translate/django_182/topics/http/middleware.html](https://link.jianshu.com/?t=http%3A%2F%2Fpython.usyiyi.cn%2Ftranslate%2Fdjango_182%2Ftopics%2Fhttp%2Fmiddleware.html)
4. [https://my.oschina.net/tenking/blog/29439](https://link.jianshu.com/?t=https%3A%2F%2Fmy.oschina.net%2Ftenking%2Fblog%2F29439)


