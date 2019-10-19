# Python 面试题01

------



### 

# [#](http://www.liuwq.com/views/面试题/python_01.html#web)Web

## [#](http://www.liuwq.com/views/面试题/python_01.html#flask)Flask

### [#](http://www.liuwq.com/views/面试题/python_01.html#_140-对flask蓝图-blueprint-的理解？)140.对Flask蓝图(Blueprint)的理解？

蓝图的定义

蓝图 /Blueprint 是Flask应用程序组件化的方法，可以在一个应用内或跨越多个项目共用蓝图。使用蓝图可以极大简化大型应用的开发难度，也为Flask扩展提供了一种在应用中注册服务的集中式机制。

蓝图的应用场景：

把一个应用分解为一个蓝图的集合。这对大型应用是理想的。一个项目可以实例化一个应用对象，初始化几个扩展，并注册一集合的蓝图。

以URL前缀和/或子域名，在应用上注册一个蓝图。URL前缀/子域名中的参数即成为这个蓝图下的所有视图函数的共同的视图参数（默认情况下） 在一个应用中用不同的URL规则多次注册一个蓝图。

通过蓝图提供模板过滤器、静态文件、模板和其他功能。一个蓝图不一定要实现应用或视图函数。

初始化一个Flask扩展时，在这些情况中注册一个蓝图。

蓝图的缺点：

不能在应用创建后撤销注册一个蓝图而不销毁整个应用对象。

使用蓝图的三个步骤

1.创建一个蓝图对象

```python
blue = Blueprint("blue",__name__)
```

2.在这个蓝图对象上进行操作，例如注册路由、指定静态文件夹、注册模板过滤器...

```python
@blue.route('/')
def blue_index():
    return "Welcome to my blueprint"
```

3.在应用对象上注册这个蓝图对象

```python
app.register_blueprint(blue,url_prefix="/blue")
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_141-flask-和-django-路由映射的区别？)141.Flask 和 Django 路由映射的区别？

在django中，路由是浏览器访问服务器时，先访问的项目中的url，再由项目中的url找到应用中url，这些url是放在一个列表里，遵从从前往后匹配的规则。在flask中，路由是通过装饰器给每个视图函数提供的，而且根据请求方式的不同可以一个url用于不同的作用。

## [#](http://www.liuwq.com/views/面试题/python_01.html#django)Django

### [#](http://www.liuwq.com/views/面试题/python_01.html#_142-什么是wsgi-uwsgi-uwsgi)142.什么是wsgi,uwsgi,uWSGI?

WSGI:

web服务器网关接口，是一套协议。用于接收用户请求并将请求进行初次封装，然后将请求交给web框架。

实现wsgi协议的模块：wsgiref,本质上就是编写一socket服务端，用于接收用户请求（django)

werkzeug,本质上就是编写一个socket服务端，用于接收用户请求(flask)

uwsgi:

与WSGI一样是一种通信协议，它是uWSGI服务器的独占协议，用于定义传输信息的类型。 uWSGI:

是一个web服务器，实现了WSGI的协议，uWSGI协议，http协议

### [#](http://www.liuwq.com/views/面试题/python_01.html#_143-django、flask、tornado的对比？)143.Django、Flask、Tornado的对比？

1、 Django走的大而全的方向，开发效率高。它的MTV框架，自带的ORM,admin后台管理,自带的sqlite数据库和开发测试用的服务器，给开发者提高了超高的开发效率。 重量级web框架，功能齐全，提供一站式解决的思路，能让开发者不用在选择上花费大量时间。

自带ORM和模板引擎，支持jinja等非官方模板引擎。

自带ORM使Django和关系型数据库耦合度高，如果要使用非关系型数据库，需要使用第三方库

自带数据库管理app

成熟，稳定，开发效率高，相对于Flask，Django的整体封闭性比较好，适合做企业级网站的开发。python web框架的先驱，第三方库丰富

2、 Flask 是轻量级的框架，自由，灵活，可扩展性强，核心基于Werkzeug WSGI工具 和jinja2 模板引擎

适用于做小网站以及web服务的API,开发大型网站无压力，但架构需要自己设计

与关系型数据库的结合不弱于Django，而与非关系型数据库的结合远远优于Django

3、 Tornado走的是少而精的方向，性能优越，它最出名的异步非阻塞的设计方式

Tornado的两大核心模块：

iostraem:对非阻塞的socket进行简单的封装

ioloop: 对I/O 多路复用的封装,它实现一个单例

### [#](http://www.liuwq.com/views/面试题/python_01.html#_144-cors-和-csrf的区别？)144.CORS 和 CSRF的区别？

什么是CORS？

CORS是一个W3C标准,全称是“跨域资源共享"(Cross-origin resoure sharing). 它允许浏览器向跨源服务器，发出XMLHttpRequest请求，从而客服了AJAX只能同源使用的限制。

什么是CSRF？

CSRF主流防御方式是在后端生成表单的时候生成一串随机token,内置到表单里成为一个字段，同时，将此串token置入session中。每次表单提交到后端时都会检查这两个值是否一致，以此来判断此次表单提交是否是可信的，提交过一次之后，如果这个页面没有生成CSRF token,那么token将会被清空,如果有新的需求，那么token会被更新。 攻击者可以伪造POST表单提交，但是他没有后端生成的内置于表单的token，session中没有token都无济于事。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_145-session-cookie-jwt的理解)145.Session,Cookie,JWT的理解

#### 为什么要使用会话管理

众所周知，HTTP协议是一个无状态的协议，也就是说每个请求都是一个独立的请求，请求与请求之间并无关系。但在实际的应用场景，这种方式并不能满足我们的需求。举个大家都喜欢用的例子，把商品加入购物车，单独考虑这个请求，服务端并不知道这个商品是谁的，应该加入谁的购物车？因此这个请求的上下文环境实际上应该包含用户的相关信息，在每次用户发出请求时把这一小部分额外信息，也做为请求的一部分，这样服务端就可以根据上下文中的信息，针对具体的用户进行操作。所以这几种技术的出现都是对HTTP协议的一个补充，使得我们可以用HTTP协议+状态管理构建一个的面向用户的WEB应用。

#### Session 和Cookie的区别

这里我想先谈谈session与cookies,因为这两个技术是做为开发最为常见的。那么session与cookies的区别是什么？个人认为session与cookies最核心区别在于额外信息由谁来维护。利用cookies来实现会话管理时，用户的相关信息或者其他我们想要保持在每个请求中的信息，都是放在cookies中,而cookies是由客户端来保存，每当客户端发出新请求时，就会稍带上cookies,服务端会根据其中的信息进行操作。 当利用session来进行会话管理时，客户端实际上只存了一个由服务端发送的session_id,而由这个session_id,可以在服务端还原出所需要的所有状态信息，从这里可以看出这部分信息是由服务端来维护的。

##### 除此以外，session与cookies都有一些自己的缺点：

cookies的安全性不好，攻击者可以通过获取本地cookies进行欺骗或者利用cookies进行CSRF攻击。使用cookies时,在多个域名下，会存在跨域问题。 session 在一定的时间里，需要存放在服务端，因此当拥有大量用户时，也会大幅度降低服务端的性能，当有多台机器时，如何共享session也会是一个问题.(redis集群)也就是说，用户第一个访问的时候是服务器A，而第二个请求被转发给了服务器B，那服务器B如何得知其状态。实际上，session与cookies是有联系的，比如我们可以把session_id存放在cookies中的。

##### JWT是如何工作的

首先用户发出登录请求，服务端根据用户的登录请求进行匹配，如果匹配成功，将相关的信息放入payload中，利用算法，加上服务端的密钥生成token，这里需要注意的是secret_key很重要，如果这个泄露的话，客户端就可以随机篡改发送的额外信息，它是信息完整性的保证。生成token后服务端将其返回给客户端，客户端可以在下次请求时，将token一起交给服务端，一般是说我们可以将其放在Authorization首部中，这样也就可以避免跨域问题。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_146-简述django请求生命周期)146.简述Django请求生命周期

一般是用户通过浏览器向我们的服务器发起一个请求(request),这个请求会去访问视图函数，如果不涉及到数据调用，那么这个时候视图函数返回一个模板也就是一个网页给用户） 视图函数调用模型毛模型去数据库查找数据，然后逐级返回，视图函数把返回的数据填充到模板中空格中，最后返回网页给用户。

1.wsgi ,请求封装后交给web框架（Flask，Django)

2.中间件，对请求进行校验或在请求对象中添加其他相关数据，例如：csrf,request.session

3.路由匹配 根据浏览器发送的不同url去匹配不同的视图函数

4.视图函数，在视图函数中进行业务逻辑的处理，可能涉及到：orm，templates

5.中间件，对响应的数据进行处理

6.wsgi，将响应的内容发送给浏览器

### [#](http://www.liuwq.com/views/面试题/python_01.html#_147-用的restframework完成api发送时间时区)147.用的restframework完成api发送时间时区

当前的问题是用django的rest framework模块做一个get请求的发送时间以及时区信息的api

```python
class getCurrenttime(APIView):
    def get(self,request):
        local_time = time.localtime()
        time_zone =settings.TIME_ZONE
        temp = {'localtime':local_time,'timezone':time_zone}
        return Response(temp)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_148-nginx-tomcat-apach到都是什么？)148.nginx,tomcat,apach到都是什么？

Nginx（engine x)是一个高性能的HTTP和反向代理服务器，也是 一个IMAP/POP3/SMTP服务器，工作在OSI七层，负载的实现方式：轮询，IP_HASH,fair,session_sticky. Apache HTTP Server是一个模块化的服务器，源于NCSAhttpd服务器 Tomcat 服务器是一个免费的开放源代码的Web应用服务器，属于轻量级应用服务器，是开发和调试JSP程序的首选。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_149-请给出你熟悉关系数据库范式有哪些，有什么作用？)149.请给出你熟悉关系数据库范式有哪些，有什么作用？

在进行数据库的设计时，所遵循的一些规范，只要按照设计规范进行设计，就能设计出没有数据冗余和数据维护异常的数据库结构。

数据库的设计的规范有很多，通常来说我们在设是数据库时只要达到其中一些规范就可以了，这些规范又称之为数据库的三范式，一共有三条，也存在着其他范式，我们只要做到满足前三个范式的要求，就能设陈出符合我们的数据库了，我们也不能全部来按照范式的要求来做，还要考虑实际的业务使用情况，所以有时候也需要做一些违反范式的要求。 1.数据库设计的第一范式(最基本)，基本上所有数据库的范式都是符合第一范式的，符合第一范式的表具有以下几个特点：

数据库表中的所有字段都只具有单一属性，单一属性的列是由基本的数据类型（整型，浮点型，字符型等）所构成的设计出来的表都是简单的二比表

2.数据库设计的第二范式(是在第一范式的基础上设计的)，要求一个表中只具有一个业务主键，也就是说符合第二范式的表中不能存在非主键列对只对部分主键的依赖关系

3.数据库设计的第三范式，指每一个非主属性既不部分依赖与也不传递依赖于业务主键，也就是第二范式的基础上消除了非主属性对主键的传递依赖

### [#](http://www.liuwq.com/views/面试题/python_01.html#_150-简述qq登陆过程)150.简述QQ登陆过程

qq登录，在我们的项目中分为了三个接口，

第一个接口是请求qq服务器返回一个qq登录的界面;

第二个接口是通过扫码或账号登陆进行验证，qq服务器返回给浏览器一个code和state,利用这个code通过本地服务器去向qq服务器获取access_token覆返回给本地服务器，凭借access_token再向qq服务器获取用户的openid(openid用户的唯一标识)

第三个接口是判断用户是否是第一次qq登录，如果不是的话直接登录返回的jwt-token给用户，对没有绑定过本网站的用户，对openid进行加密生成token进行绑定

### [#](http://www.liuwq.com/views/面试题/python_01.html#_151-post-和-get的区别)151.post 和 get的区别?

1.GET是从服务器上获取数据，POST是向服务器传送数据

2.在客户端，GET方式在通过URL提交数据，数据在URL中可以看到，POST方式，数据放置在HTML——HEADER内提交

3.对于GET方式，服务器端用Request.QueryString获取变量的值，对于POST方式，服务器端用Request.Form获取提交的数据

### [#](http://www.liuwq.com/views/面试题/python_01.html#_152-项目中日志的作用)152.项目中日志的作用

一、日志相关概念

1.日志是一种可以追踪某些软件运行时所发生事件的方法

2.软件开发人员可以向他们的代码中调用日志记录相关的方法来表明发生了某些事情

3.一个事件可以用一个包含可选变量数据的消息来描述

4.此外，事件也有重要性的概念，这个重要性也可以被成为严重性级别(level)

二、日志的作用

1.通过log的分析，可以方便用户了解系统或软件、应用的运行情况;

2.如果你的应用log足够丰富，可以分析以往用户的操作行为、类型喜好，地域分布或其他更多信息;

3.如果一个应用的log同时也分了多个级别，那么可以很轻易地分析得到该应用的健康状况，及时发现问题并快速定位、解决问题，补救损失。

4.简单来讲就是我们通过记录和分析日志可以了解一个系统或软件程序运行情况是否正常，也可以在应用程序出现故障时快速定位问题。不仅在开发中，在运维中日志也很重要，日志的作用也可以简单。总结为以下几点：

1.程序调试

2.了解软件程序运行情况，是否正常

3,软件程序运行故障分析与问题定位

4,如果应用的日志信息足够详细和丰富，还可以用来做用户行为分析

### [#](http://www.liuwq.com/views/面试题/python_01.html#_153-django中间件的使用？)153.django中间件的使用？

Django在中间件中预置了六个方法，这六个方法的区别在于不同的阶段执行，对输入或输出进行干预，方法如下：

1.初始化：无需任何参数，服务器响应第一个请求的时候调用一次，用于确定是否启用当前中间件

```python
def __init__():
    pass
```

2.处理请求前：在每个请求上调用，返回None或HttpResponse对象。

```python
def process_request(request):
    pass
```

3.处理视图前:在每个请求上调用，返回None或HttpResponse对象。

```python
def process_view(request,view_func,view_args,view_kwargs):
    pass
```

4.处理模板响应前：在每个请求上调用，返回实现了render方法的响应对象。

```python
def process_template_response(request,response):
    pass
```

5.处理响应后：所有响应返回浏览器之前被调用，在每个请求上调用，返回HttpResponse对象。

```python
def process_response(request,response):
    pass
```

6.异常处理：当视图抛出异常时调用，在每个请求上调用，返回一个HttpResponse对象。

```python
def process_exception(request,exception):
    pass
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_154-谈一下你对uwsgi和nginx的理解？)154.谈一下你对uWSGI和nginx的理解？

1.uWSGI是一个Web服务器，它实现了WSGI协议、uwsgi、http等协议。Nginx中HttpUwsgiModule的作用是与uWSGI服务器进行交换。WSGI是一种Web服务器网关接口。它是一个Web服务器（如nginx，uWSGI等服务器）与web应用（如用Flask框架写的程序）通信的一种规范。

要注意WSGI/uwsgi/uWSGI这三个概念的区分。

WSGI是一种通信协议。

uwsgi是一种线路协议而不是通信协议，在此常用于在uWSGI服务器与其他网络服务器的数据通信。

uWSGI是实现了uwsgi和WSGI两种协议的Web服务器。

nginx 是一个开源的高性能的HTTP服务器和反向代理：

1.作为web服务器，它处理静态文件和索引文件效果非常高

2.它的设计非常注重效率，最大支持5万个并发连接，但只占用很少的内存空间

3.稳定性高，配置简洁。

4.强大的反向代理和负载均衡功能，平衡集群中各个服务器的负载压力应用

### [#](http://www.liuwq.com/views/面试题/python_01.html#_155-python中三大框架各自的应用场景？)155.Python中三大框架各自的应用场景？

django:主要是用来搞快速开发的，他的亮点就是快速开发，节约成本，,如果要实现高并发的话，就要对django进行二次开发，比如把整个笨重的框架给拆掉自己写socket实现http的通信,底层用纯c,c++写提升效率，ORM框架给干掉，自己编写封装与数据库交互的框架,ORM虽然面向对象来操作数据库，但是它的效率很低，使用外键来联系表与表之间的查询; flask: 轻量级，主要是用来写接口的一个框架，实现前后端分离，提考开发效率，Flask本身相当于一个内核，其他几乎所有的功能都要用到扩展(邮件扩展Flask-Mail，用户认证Flask-Login),都需要用第三方的扩展来实现。比如可以用Flask-extension加入ORM、文件上传、身份验证等。Flask没有默认使用的数据库，你可以选择MySQL，也可以用NoSQL。

其WSGI工具箱用Werkzeug(路由模块)，模板引擎则使用Jinja2,这两个也是Flask框架的核心。

Tornado： Tornado是一种Web服务器软件的开源版本。Tornado和现在的主流Web服务器框架（包括大多数Python的框架）有着明显的区别：它是非阻塞式服务器，而且速度相当快。得利于其非阻塞的方式和对epoll的运用，Tornado每秒可以处理数以千计的连接因此Tornado是实时Web服务的一个理想框架

### [#](http://www.liuwq.com/views/面试题/python_01.html#_156-django中哪里用到了线程？哪里用到了协程？哪里用到了进程？)156.Django中哪里用到了线程？哪里用到了协程？哪里用到了进程？

1.Django中耗时的任务用一个进程或者线程来执行，比如发邮件，使用celery.

2.部署django项目是时候，配置文件中设置了进程和协程的相关配置。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_157-有用过django-rest-framework吗？)157.有用过Django REST framework吗？

Django REST framework是一个强大而灵活的Web API工具。使用RESTframework的理由有：

Web browsable API对开发者有极大的好处

包括OAuth1a和OAuth2的认证策略

支持ORM和非ORM数据资源的序列化

全程自定义开发--如果不想使用更加强大的功能，可仅仅使用常规的function-based views额外的文档和强大的社区支持

### [#](http://www.liuwq.com/views/面试题/python_01.html#_158-对cookies与session的了解？他们能单独用吗？)158.对cookies与session的了解？他们能单独用吗？

Session采用的是在服务器端保持状态的方案，而Cookie采用的是在客户端保持状态的方案。但是禁用Cookie就不能得到Session。因为Session是用Session ID来确定当前对话所对应的服务器Session，而Session ID是通过Cookie来传递的，禁用Cookie相当于SessionID,也就得不到Session。

## [#](http://www.liuwq.com/views/面试题/python_01.html#爬虫)爬虫

### [#](http://www.liuwq.com/views/面试题/python_01.html#_159-试列出至少三种目前流行的大型数据库)159.试列出至少三种目前流行的大型数据库

### [#](http://www.liuwq.com/views/面试题/python_01.html#_160-列举您使用过的python网络爬虫所用到的网络数据包)160.列举您使用过的Python网络爬虫所用到的网络数据包?

requests, urllib,urllib2, httplib2

### [#](http://www.liuwq.com/views/面试题/python_01.html#_161-爬取数据后使用哪个数据库存储数据的，为什么？)161.爬取数据后使用哪个数据库存储数据的，为什么？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_162-你用过的爬虫框架或者模块有哪些？优缺点？)162.你用过的爬虫框架或者模块有哪些？优缺点？

Python自带：urllib,urllib2

第三方：requests

框架： Scrapy

urllib 和urllib2模块都做与请求URL相关的操作，但他们提供不同的功能。

urllib2: urllib2.urlopen可以接受一个Request对象或者url,(在接受Request对象时，并以此可以来设置一个URL的headers),urllib.urlopen只接收一个url。

urllib 有urlencode,urllib2没有，因此总是urllib, urllib2常会一起使用的原因

scrapy是封装起来的框架，他包含了下载器，解析器，日志及异常处理，基于多线程，twisted的方式处理，对于固定单个网站的爬取开发，有优势，但是对于多网站爬取100个网站，并发及分布式处理不够灵活，不便调整与扩展

requests是一个HTTP库，它只是用来请求，它是一个强大的库，下载，解析全部自己处理，灵活性高

Scrapy优点：异步，xpath，强大的统计和log系统，支持不同url。shell方便独立调试。写middleware方便过滤。通过管道存入数据库

### [#](http://www.liuwq.com/views/面试题/python_01.html#_163-写爬虫是用多进程好？还是多线程好？)163.写爬虫是用多进程好？还是多线程好？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_164-常见的反爬虫和应对方法？)164.常见的反爬虫和应对方法？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_165-解析网页的解析器使用最多的是哪几个)165.解析网页的解析器使用最多的是哪几个?

### [#](http://www.liuwq.com/views/面试题/python_01.html#_166-需要登录的网页，如何解决同时限制ip，cookie-session)166.需要登录的网页，如何解决同时限制ip，cookie,session

### [#](http://www.liuwq.com/views/面试题/python_01.html#_167-验证码的解决)167.验证码的解决?

### [#](http://www.liuwq.com/views/面试题/python_01.html#_168-使用最多的数据库，对他们的理解？)168.使用最多的数据库，对他们的理解？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_169-编写过哪些爬虫中间件？)169.编写过哪些爬虫中间件？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_170-“极验”滑动验证码如何破解？)170.“极验”滑动验证码如何破解？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_171-爬虫多久爬一次，爬下来的数据是怎么存储？)171.爬虫多久爬一次，爬下来的数据是怎么存储？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_172-cookie过期的处理问题？)172.cookie过期的处理问题？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_173-动态加载又对及时性要求很高怎么处理？)173.动态加载又对及时性要求很高怎么处理？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_174-https有什么优点和缺点？)174.HTTPS有什么优点和缺点？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_175-https是如何实现安全传输数据的？)175.HTTPS是如何实现安全传输数据的？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_176-ttl，msl，rtt各是什么？)176.TTL，MSL，RTT各是什么？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_177-谈一谈你对selenium和phantomjs了解)177.谈一谈你对Selenium和PhantomJS了解

### [#](http://www.liuwq.com/views/面试题/python_01.html#_178-平常怎么使用代理的-？)178.平常怎么使用代理的 ？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_179-存放在数据库-redis、mysql等-。)179.存放在数据库(redis、mysql等)。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_180-怎么监控爬虫的状态)180.怎么监控爬虫的状态?

### [#](http://www.liuwq.com/views/面试题/python_01.html#_181-描述下scrapy框架运行的机制？)181.描述下scrapy框架运行的机制？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_182-谈谈你对scrapy的理解？)182.谈谈你对Scrapy的理解？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_183-怎么样让-scrapy-框架发送一个-post-请求（具体写出来）)183.怎么样让 scrapy 框架发送一个 post 请求（具体写出来）

### [#](http://www.liuwq.com/views/面试题/python_01.html#_184-怎么监控爬虫的状态-？)184.怎么监控爬虫的状态 ？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_185-怎么判断网站是否更新？)185.怎么判断网站是否更新？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_186-图片、视频爬取怎么绕过防盗连接)186.图片、视频爬取怎么绕过防盗连接

### [#](http://www.liuwq.com/views/面试题/python_01.html#_187-你爬出来的数据量大概有多大？大概多长时间爬一次？)187.你爬出来的数据量大概有多大？大概多长时间爬一次？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_188-用什么数据库存爬下来的数据？部署是你做的吗？怎么部署？)188.用什么数据库存爬下来的数据？部署是你做的吗？怎么部署？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_189-增量爬取)189.增量爬取

### [#](http://www.liuwq.com/views/面试题/python_01.html#_190-爬取下来的数据如何去重，说一下scrapy的具体的算法依据。)190.爬取下来的数据如何去重，说一下scrapy的具体的算法依据。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_191-scrapy的优缺点)191.Scrapy的优缺点?

### [#](http://www.liuwq.com/views/面试题/python_01.html#_192-怎么设置爬取深度？)192.怎么设置爬取深度？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_193-scrapy和scrapy-redis有什么区别？为什么选择redis数据库？)193.scrapy和scrapy-redis有什么区别？为什么选择redis数据库？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_194-分布式爬虫主要解决什么问题？)194.分布式爬虫主要解决什么问题？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_195-什么是分布式存储？)195.什么是分布式存储？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_196-你所知道的分布式爬虫方案有哪些？)196.你所知道的分布式爬虫方案有哪些？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_197-scrapy-redis，有做过其他的分布式爬虫吗？)197.scrapy-redis，有做过其他的分布式爬虫吗？

### 

## [#](http://www.liuwq.com/views/面试题/python_01.html#测试)测试

### [#](http://www.liuwq.com/views/面试题/python_01.html#_213-编写测试计划的目的是)213.编写测试计划的目的是

### [#](http://www.liuwq.com/views/面试题/python_01.html#_214-对关键词触发模块进行测试)214.对关键词触发模块进行测试

### [#](http://www.liuwq.com/views/面试题/python_01.html#_215-其他常用笔试题目网址汇总)215.其他常用笔试题目网址汇总

### [#](http://www.liuwq.com/views/面试题/python_01.html#_216-测试人员在软件开发过程中的任务是什么)216.测试人员在软件开发过程中的任务是什么

### [#](http://www.liuwq.com/views/面试题/python_01.html#_217-一条软件bug记录都包含了哪些内容？)217.一条软件Bug记录都包含了哪些内容？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_218-简述黑盒测试和白盒测试的优缺点)218.简述黑盒测试和白盒测试的优缺点

### [#](http://www.liuwq.com/views/面试题/python_01.html#_219-请列出你所知道的软件测试种类，至少5项)219.请列出你所知道的软件测试种类，至少5项

### [#](http://www.liuwq.com/views/面试题/python_01.html#_220-alpha测试与beta测试的区别是什么？)220.Alpha测试与Beta测试的区别是什么？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_221-举例说明什么是bug？一个bug-report应包含什么关键字？)221.举例说明什么是Bug？一个bug report应包含什么关键字？

### 

## [#](http://www.liuwq.com/views/面试题/python_01.html#大数据)大数据

### [#](http://www.liuwq.com/views/面试题/python_01.html#_242-找出1g的文件中高频词)242.找出1G的文件中高频词

### [#](http://www.liuwq.com/views/面试题/python_01.html#_243-一个大约有一万行的文本文件统计高频词)243.一个大约有一万行的文本文件统计高频词

### [#](http://www.liuwq.com/views/面试题/python_01.html#_244-怎么在海量数据中找出重复次数最多的一个？)244.怎么在海量数据中找出重复次数最多的一个？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_245-判断数据是否在大量数据中)245.判断数据是否在大量数据中

## [#](http://www.liuwq.com/views/面试题/python_01.html#架构)架构

### [#](http://www.liuwq.com/views/面试题/python_01.html#python后端架构演进)[Python后端架构演进](https://zhu327.github.io/2018/07/19/python后端架构演进/)

这篇文章几乎涵盖了python会用的架构，在面试可以手画架构图，根据自己的项目谈下技术选型和优劣，遇到的坑等。绝对加分







