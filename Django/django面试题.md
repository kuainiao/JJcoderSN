#### jango、flask、tornado框架的比较？

django：
优点：最全能的web开发框架，各种功能完备，可维护性高，开发速度快
缺点：django orm 跟数据库的交互，django同步特性导致吞吐量小的问题可以通过celery解决

tornado：
优点：天生异步，性能强悍
缺点：框架提供的功能比较少，需要自己实现，这样导致了开发速度偏慢

flask：
优点：自由、灵活，扩展性强，第三方库的选择面广
缺点：但是对程序员要求更高

------

#### 什么是wsgi？

https://www.jianshu.com/p/679dee0a4193

WSGI，描述web server如何与web application通信的一种规范

WSGI协议主要包括server和application两部分：

WSGI server负责从客户端接收请求，将request转发给application，将application返回的response返回给客户端；
WSGI application接收由server转发的request，处理请求，并将处理结果返回给server。

application中可以包括多个栈式的中间件(middlewares)，这些中间件需要同时实现server与application，因此可以在WSGI服务器与WSGI应用之间起调节作用：对服务器来说，中间件扮演应用程序，对应用程序来说，中间件扮演服务器。

------

#### django请求的生命周期？

Django的请求生命周期是指当用户在浏览器上输入url到用户看到网页的这个时间段内,Django后台所发生的事情

而Django的生命周期内到底发生了什么呢??

1. 当用户在浏览器中输入url时,浏览器会生成请求头和请求体发给服务端
    请求头和请求体中会包含浏览器的动作(action),这个动作通常为get或者post,体现在url之中.
2. url经过Django中的wsgi,再经过Django的中间件,最后url到过路由映射表,在路由中一条一条进行匹配,
    一旦其中一条匹配成功就执行对应的视图函数,后面的路由就不再继续匹配了.
3. 视图函数根据客户端的请求查询相应的数据.返回给Django,然后Django把客户端想要的数据做为一个字符串返回给客户端.
4. 客户端浏览器接收到返回的数据,经过渲染后显示给用户.

------

#### 列举django的内置组件

认证组件

缓存

日志

邮件

分页

静态文件管理

资讯聚合

消息框架

数据验证

------

#### 列举django中间件的5个方法？以及django中间件的应用场景？

在django中，中间件其实就是一个类，在请求到来和结束后，django会根据自己的规则在合适的时机执行中间件中相应的方法

在django项目的settings模块中，有一个 MIDDLEWARE_CLASSES 变量，其中每一个元素就是一个中间件

默认的中间件有哪些

中间件中可以定义五个方法，分别是：

```
# 方法在请求到来的时候调用
process_request(self,request)
# 在本次将要执行的View函数被调用前调用本函数
process_view(self, request, callback, callback_args, callback_kwargs)
# 需使用render()方法才会执行process_template_response
process_template_response(self,request,response)
# View函数在抛出异常时该函数被调用，得到的exception参数是实际上抛出的异常实例。通过此方法可以进行很好的错误控制，提供友好的用户界面。
process_exception(self, request, exception)
# 在执行完View函数准备将响应发到客户端前被执行
process_response(self, request, response)
```

django中间件的使用场景

如果你想修改请求，例如被传送到view中的HttpRequest对象

或者你想修改view返回的HttpResponse对象，这些都可以通过中间件来实现

可能你还想在view执行之前做一些操作，这种情况也可以用 middleware来实现。
比如我们写一个判断浏览器来源，是pc还是手机，这里手机我们采用iphone，因为暂时没有其他设备。我们有不想把这个逻辑加到视图函数里，想作为一个通用服务，作为一个可插拔的组件被使用，最好的方法就是实现为中间件

或者说做一个拦截器，发现一定的时间内某个ip对网页的访问次数过多，则将其加入黑名单

------

#### 简述什么是FBV和CBV？

FBV（function base views） 基于函数的视图
CBV（class base views） 基于类的视图

使用fbv的模式,在url匹配成功之后,会直接执行对应的视图函数

使用cbv模式,在url匹配成功之后,会找到视图函数中对应的类,然后这个类回到请求头中找到对应的Request Method

用户发送url请求,Django会依次遍历路由映射表中的所有记录,一旦路由映射表其中的一条匹配成功了,就执行视图函数中对应的函数名,这是fbv的执行流程

当服务端使用cbv模式的时候,用户发给服务端的请求包含url和method,这两个信息都是字符串类型
服务端通过路由映射表匹配成功后会自动去找dispatch方法,然后Django会通过dispatch反射的方式找到类中对应的方法并执行
类中的方法执行完毕之后,会把客户端想要的数据返回给dispatch方法,由dispatch方法把数据返回经客户端

------

#### django的request对象是在什么时候创建的？

当请求一个页面时,Django创建一个 HttpRequest 对象.该对象包含 request 的元数据. 然后 Django 调用相应的 view 函数(HttpRequest 对象自动传递给该view函数<作为第一个参数>), 每一个 view 负责返回一个 HttpResponse 对象.

requests的元数据包括path，get，put等方法，cookies，user等等

------

#### 如何给CBV的程序添加装饰器？

CBV添加装饰器有两种方法

1. 在指定方法上添加装饰器
2. 在类上添加，但是要用name来指定方法

```
## CBV中添加装饰器
def wrapper(func):
    def inner(*args,**kwargs):
        return func(*args,**kwargs)
    return inner
    
# 1. 指定方法上添加装饰器
class Foo(View):

    @method_decorator(wrapper)
    def get(self,request):
        pass
    def post(self,request):
        pass

2. 在类上添加

@method_decorator(wrapper,name='dispatch')
class Foo(View):
    def get(self,request):
        pass
def post(self,request):
        pass
```

总结

1. 添加装饰器前必须导入from django.utils.decorators import method_decorator
2. 添加装饰器的格式必须为@method_decorator()，括号里面为装饰器的函数名
3. 给类添加是必须声明name
4. 注意csrf-token装饰器的特殊性，它只能加在dispatch上面

------

#### 列举django orm 中所有的方法（QuerySet对象的所有方法）

从数据库中查询出来的结果一般是一个集合，这个集合叫做 QuerySet

- filter 过滤
- exclude 排除
- annotate 聚合
- order_by 排序
- reverse 反向排序
- distinct 去除查询结果中重复的行
- values 迭代时返回字典而不是模型实例对象
- values_list 迭代时返回元组而不是字典
- dates 表示特定种类的所有可用日期
- datetimes 表示特定种类的所有可用日期
- none 不返回任何对象
- all 返回所有结果
- select_related 外键查询
- prefetch_related 在单个批处理中自动检索每个指定查找的相关对象
- defer 告诉django不要查询某些字段
- using 多个数据库时控制QuerySet在哪个数据库上求值

------

#### only和defer的区别？

在复杂的情况下，表中可能有些字段内容非常多，取出来转化成 Python 对象会占用大量的资源。
这时候可以用 defer 来排除这些字段，比如我们在文章列表页，只需要文章的标题和作者，没有必要把文章的内容也获取出来（因为会转换成python对象，浪费内存）

和 defer 相反，only 用于取出需要的字段，假如我们只需要查出 作者的名称

------

#### `select_related`和`prefetch_related`的区别？

https://hk.saowen.com/a/bb124ab70580b722d7840c7c0377a326ac4ce022dc653f4cbc7e0ae7fc245232

------

#### filter和exclude的区别？

filter 设置要查询的字段
exclude 设置不要查询的字段

------

#### 列举django orm中三种能写sql语句的方法

1. 使用extra：查询人民邮电出版社出版并且价格大于50元的书籍

```
Book.objects.filter(publisher__name='人民邮电出版社').extra(where=['price>50']) 
```

1. 使用raw

```
books=Book.objects.raw('select * from hello_book')  
for book in books:  
   print book  
```

1. 自定义sql

```
from django.db import connection  
  
cursor = connection.cursor()  
cursor.execute("insert into hello_author(name) VALUES ('郭敬明')")  
cursor.execute("update hello_author set name='韩寒' WHERE name='郭敬明'")  
cursor.execute("delete from hello_author where name='韩寒'")  
cursor.execute("select * from hello_author")  
cursor.fetchone()  
cursor.fetchall() 
```

------

#### django orm 中如何设置读写分离？

https://blog.csdn.net/Ayhan_huang/article/details/78784486

https://my.oschina.net/candiesyangyang/blog/203425

------

#### F和Q的作用?

F作用：操作数据表中的某列值，F()允许Django在未实际链接数据的情况下具有对数据库字段的值的引用，不用获取对象放在内存中再对字段进行操作，直接执行原生产sql语句操作

使用场景：对数据库中的所有的商品，在原价格的基础上涨价10元

```
from django.db.models import F
from app01.models import Book
Book.objects.update(price=F("price")+20)  # 对于book表中每本书的价格都在原价格的基础上增加20元
```

Q作用：对对象进行复杂查询，并支持&（and）,|（or），~（not）操作符

使用场景：filter查询条件只有一个，而使用Q可以设置多个查询条件

```
from django.db.models import Q
search_obj=Asset.objects.filter(Q(hostname__icontains=keyword)|Q(ip=keyword))
```

当同时使用filter的关键字查询和Q查询时，一定要把Q对象放在前面

```
Asset.objects.get(
Q(pub_date=date(2005, 5, 2)) | Q(pub_date=date(2005, 5, 6)),question__startswith='Who')
```

#### values和values_list的区别

values 返回字典而不是模型查询对象

values-list 跟values一样，但是返回的是元组

https://blog.csdn.net/weixin_40475396/article/details/79529256

#### 如何使用django orm批量创建数据？

如果使用django save()创建数据，则每次save的时候都会访问一次数据库

```
for i in resultlist:
    p = Account(name=i)
    p.save()
```

django1.4之后加入新特性可以批量创建对象，减少SQL查询次数

```
querysetlist=[]
for i in resultlist:
    querysetlist.append(Account(name=i))
Account.objects.bulk_create(querysetlist)
```

#### django的Form和ModeForm的作用？

http://www.cnblogs.com/caochao-/articles/8412830.html

表单的作用是收集元素中的内容

Form 需要自己定义表单的字段

ModelForm 根据model来生成表单的字段

#### django的Form组件中，如果字段中包含choices参数，请使用两种方式实现数据源实时更新

此问题只适用于From组件，ModelFrom组件不用考虑(自身已经解决)

示例：例如choice类型字段，添加了新的数据，而在页面中不能显示出来，只有再次刷新页面才能获取最新的数据，因为程序运行时静态字段只加载一次, choice的数据如果从数据库获取可能会造成数据无法实时更新

```
# models.py
from django.db import models

class UserType(models.Model):
    title = models.CharField(max_length=32)
　　　
　　def __str__(self):
　　　　return self.title


class UserInfo(models.Model):
    name = models.CharField(max_length=32)
    email = models.CharField(max_length=32)
    ut = models.ForeignKey(to='UserType')
```

方法一：重写构造方法：

```
# views.py      

from django.forms import Form
from django.forms import fields

class UserForm(Form):
    name = fields.CharField(label='用户名',max_length=32)
    email = fields.EmailField(label='邮箱')
    ut_id = fields.ChoiceField(
        # choices=[(1,'二笔用户'),(2,'闷骚')]
        choices=[]
    )

    def __init__(self,*args,**kwargs):
        super(UserForm,self).__init__(*args,**kwargs)
        
        # 每次实例化，重新去数据库获取数据并更新
        self.fields['ut_id'].choices = models.UserType.objects.all().values_list('id','title')

def user(request):
    if request.method == "GET":
        form = UserForm()
        return render(request,'user.html',{'form':form})
```

方法二：使用ModelChoiceField字段

```
# views.py

from django.forms import Form
from django.forms import fields
from django.forms.models import ModelChoiceField
class UserForm(Form):
    name = fields.CharField(label='用户名',max_length=32)
    email = fields.EmailField(label='邮箱')
    ut_id = ModelChoiceField(queryset=models.UserType.objects.all())    
```

#### django的Model中的ForeignKey字段中的on_delete参数有什么作用？

当一个被ForeignKey引用的对象删除后，django将会通过指定on_delete参数来仿真sql约束的行为

例如，如果你有一个可以为空的ForeignKey，在其引用的对象被删除的时你想把这个ForeignKey 设置为空：

```
user = models.ForeignKey(User, blank=True, null=True, on_delete=models.SET_NULL)
```

`on_delete`有`CASCADE`、`PROTECT`、`SET_NULL`、`SET_DEFAULT`、`SET()`五个可选择的值

1. CASCADE: 级联删除；默认值
2. PROTECT: 抛出ProtectedError 以阻止被引用对象的删除，它是django.db.IntegrityError 的一个子类
3. SET_NULL: 把ForeignKey 设置为null； null 参数为True 时才可以这样做
4. SET_DEFAULT: ForeignKey 值设置成它的默认值；此时必须设置ForeignKey 的default 参数
5. SET: 设置ForeignKey 为传递给SET() 的值，如果传递的是一个可调用对象，则为调用后的结果。在大部分情形下，[传递一个可调用对象用于避免models.py](http://xn--models-9m7igl44aw5bf6lb5io91a1s4fba7274gzkb249ap2b.py/) 在导入时执行查询

#### django中csrf的实现机制？

https://blog.csdn.net/u011715678/article/details/48752873

https://www.jianshu.com/p/991df812e2a5?utm_campaign=maleskine&utm_content=note&utm_medium=seo_notes&utm_source=recommendation

#### django如何实现websocket？

http://www.ruanyifeng.com/blog/2017/05/websocket.html

HTTP 协议有一个缺陷：通信只能由客户端发起

WebSocket 协议它的最大特点就是，服务器可以主动向客户端推送信息，客户端也可以主动向服务器发送信息，是真正的双向平等对话，属于服务器推送技术的一种

django实现websocket有多种方式：

1. 使用Channels实现websocket

https://www.jianshu.com/p/3de90e457bb4

1. 使用dwebsocket实现Websocket

https://www.cnblogs.com/huguodong/p/6611602.html

http://gtcsq.readthedocs.io/en/latest/others/websocket.html

#### 基于django使用ajax发送post请求时，都可以使用哪种方法携带csrf token？

1、写在Ajax beforeSend

```
ajax（｛
　　xxx:xxx,
　　beforeSend:function(xhr, settings){
　　　　xhr.setRequestHeader("x-CSRFToken", "{{ csrf_token }}");
　　},
｝）
```

2、写到Ajax Data

```
ajax（｛
　　xxx:xxx,
　　data: $("#form").serialize(),
｝）
```

3、写到ajaxSetup

```
$("#add-business-form").submit(function () {
            $.ajaxSetup({
            data: {csrfmiddlewaretoken: '{{ csrf_token }}'}
            });
            $.ajax({
               xxx:xxxx,
            });
            return false;
        });
```

4、KindEditor携带CSRF

```
<script>
    var csrfitems = document.getElementsByName("csrfmiddlewaretoken");
    var csrftoken = "";
    if(csrfitems.length > 0)
    {
        csrftoken = csrfitems[0].value;
    }
    $(function () {
            initKindEditor();
        });
    function initKindEditor() {
        $.ajaxSetup({
        data: {csrfmiddlewaretoken: '{{ csrf_token }}'}
        });
        var kind = KindEditor.create('#content', {
            width: '100%',       // 文本框宽度(可以百分比或像素)
            height: '300px',     // 文本框高度(只能像素)
            minWidth: 200,       // 最小宽度（数字）
            minHeight: 400,      // 最小高度（数字）
            uploadJson: '{% url "upload_image" %}',
            extraFileUploadParams : {
                csrfmiddlewaretoken:csrftoken
            }
        });
    }
</script>
```

#### django中如何实现orm表中添加数据时创建一条日志记录

1. 使用信号记录
2. 使用logger

https://blog.csdn.net/apple9005/article/details/73608994

#### django缓存如何设置？

https://www.cnblogs.com/linxiyue/p/7494540.html

#### django的缓存能使用redis吗？如果可以的话，如何配置？

https://www.jianshu.com/p/04ef84c3fe3b

#### django路由系统中name的作用？

https://www.cnblogs.com/no13bus/p/3767521.html

https://code.ziqiangxuetang.com/django/django-url-name.html

#### django的模板中filter和simple_tag的区别？

https://blog.csdn.net/huanhuanq1209/article/details/77756446

#### django-debug-toolbar的作用？

https://www.cnblogs.com/Lands-ljk/p/5506766.html

#### django中如何实现单元测试？

https://www.jianshu.com/p/15af33d2c2c4

#### 解释orm中 db first 和 code first的含义

db first：现有数据库，[然后从数据库反向生成models.py](http://xn--models-ht8i645axqa6a510yi0i5neuviwr3c2cn.py/)

code first: [现有models.py](http://xn--models-283m094f.py/) 再进行数据库操作

#### django中如何根据数据库表生成model中的类

https://www.jianshu.com/p/037bd7e20a7a

#### 使用orm和原生sql的优缺点？

使用 ORM 最大的优点就是快速开发，让我们将更多的精力放在业务上而不是数据库上，下面是 ORM 的几个优点

1. 隐藏了数据访问细节，使通用数据库交互变得简单易行。同时 ORM 避免了不规范、冗余、风格不统一的 SQL 语句，可以避免很多人为的 bug，方便编码风格的统一和后期维护。
2. 将数据库表和对象模型关联，我们只需针对相关的对象模型进行编码，无须考虑对象模型和数据库表之间的转化，大大提高了程序的开发效率。
3. 方便数据库的迁移。当需要迁移到新的数据库时，不需要修改对象模型，只需要修改数据库的配置。

ORM 的最令人诟病的地方就是性能问题，不过现在已经提高了很多，下面是 ORM 的几个缺点

1. 性能问题
    1. 自动化进行数据库关系的映射需要消耗系统资源
    2. 程序员编码
    3. 在处理多表联查、where 条件复杂的查询时，ORM 可能会生成的效率低下的 SQL
    4. 通过 Lazy load 和 Cache 很大程度上改善了性能问题
2. SQL 调优，SQL 语句是由 ORM 框架自动生成，虽然减少了 SQL 语句错误的发生，但是也给 SQL 调优带来了困难。
3. 越是功能强大的 ORM 越消耗内存，因为一个 ORM Object 会带有很多成员变量和成员函数。
4. 对象和关系之间并不是完美映射
    一般来说 ORM 足以满足我们的需求，如果对性能要求特别高或者查询十分复杂，可以考虑使用原生 SQL 和 ORM 共用的方式

使用原生sql优点：

1. 进行复杂的查询时更加灵活
2. 可以根据需要编写特殊的sql语句

使用原生sql缺点：

1. 需要对输入进行严格的检测
2. 自己写的sql语句，很多时候使用的是字符串拼接，可能会有sql注入的漏洞
3. 不能使用django orm相关的一些特性

#### 简述MVC和MTV

http://www.dongwm.com/archives/浅谈MVC、MTV和MVVM/

#### django的contenttype组件的作用？

https://blog.csdn.net/Ayhan_huang/article/details/78626957

https://juejin.im/entry/581da04f128fe1005afdf618

#### 谈谈你对restfull 规范的认识？

http://www.ruanyifeng.com/blog/2014/05/restful_api.html

#### 接口的幂等性是什么意思？

https://www.jianshu.com/p/b09a2e9bcd29

#### 什么是RPC？

https://www.jianshu.com/p/2accc2840a1b

#### Http和Https的区别？

https://juejin.im/entry/58d7635e5c497d0057fae036

#### 为什么要使用django rest framework框架？

为什么要使用REST framework？

- 在线可视的API，对于赢得你的开发者们十分有用

验证策略涵盖了OAuth1a和OAuth2

同时支持ORM和非ORM数据源的序列化

可以配置各个环节，若无需更多强大的特性，使用一般基于方法（function-based）的视图（views）即可

大量的文档，强力的社区支持

大公司如同Mozilla和Eventbrite，也是忠实的使用者

#### django rest framework框架中都有那些组件？

#### django models中null和blank得区别

`null` 是针对数据库而言，如果 `null=True`, 表示数据库的该字段可以为空

`blank` 是针对表单的，如果 `blank=True`，表示你的表单填写该字段的时候可以不填，比如 `admin` 界面下增加 `model` 一条记录的时候。直观的看到就是该字段不是粗体

[Django面试题（附带答案）](https://www.cnblogs.com/zxmt/p/10808692.html)

总结的一些Django中会问的问题，希望对你们有用。

1、 Django的生命周期

当用户在浏览器输入url时，浏览器会生成请求头和请求体发送给服务端，url经过Django中的wsgi时请求对象创建完成，经过django的中间件，然后到路由系统匹配路由，匹配成功后走到相对应的views函数，视图函数执行相关的逻辑代码返回执行结果，Django把客户端想要的数据作为一个字符串返回给客户端，客户端接收数据，渲染到页面展现给用户

2、 内置组件

Admin、from、modelfrom、model

3、 缓存方案

设置缓存到内存

缓存到redis，配置redis

CACHES = {

  "default": {

​    "BACKEND": "django_redis.cache.RedisCache",

​    "LOCATION": "redis://39.96.61.39:6379",

​    'PASSWORD':'19990104.Yu',

​    "OPTIONS": {

​      "CLIENT_CLASS": "django_redis.client.DefaultClient",

​    }

  }

}

  单个view缓存

​    视图导入from django.views.decorators.cache import cache_page

​    在需要进行缓存的视图函数上添加如下装饰器即可：

@cache_page(60 * 2)#20分钟

  底层缓存API

​    视图导入 from django.core.cache import cache

  模板片段缓存

​    使用cache标签进行缓存

在HTML文件中添加：

{%load cache%}

{%cache 60 缓存名字 %}

4、 FBV和CBV

FBV:基于函数的视图函数

CBV:基于类的视图函数

5、 session和cookie

区别：

  cookie数据存放在客户的浏览器上，session数据放在服务器上

cookie不是很安全，别人可以分析存放在本地的COOKIE并进行COOKIE欺骗

  考虑到安全应当使用session。

session会在一定时间内保存在服务器上。当访问增多，会比较占用你服务器的性能考虑到减轻服务器性能方面，应当使用COOKIE

单个cookie保存的数据不能超过4K，很多浏览器都限制一个站点最多保存20个cookie

建议：将登陆信息等重要信息存放为SESSION，其他信息如果需要保留，可以放在COOKIE中

Cookie代码

HttpCookie cookie = new HttpCookie("MyCook");//初使化并设置Cookie的名称

DateTime dt = DateTime.Now;

TimeSpan ts = new TimeSpan(0, 0, 1, 0, 0);//过期时间为1分钟

cookie.Expires = dt.Add(ts);//设置过期时间

cookie.Values.Add("userid", "value");

cookie.Values.Add("userid2", "value2");

Response.AppendCookie(cookie);

6、 HTTP请求常见的方式

1、opions  返回服务器针对特定资源所支持的HTML请求方法  或web服务器发送测试服务器功能（允许客户端查看服务器性能）

2、Get  向特定资源发出请求（请求指定页面信息，并返回实体主体）

3、Post  向指定资源提交数据进行处理请求（提交表单、上传文件），又可能导致新的资源的建立或原有资源的修改

4、Put  向指定资源位置上上传其最新内容（从客户端向服务器传送的数据取代指定文档的内容）

5、Head 与服务器索与get请求一致的相应，响应体不会返回，获取包含在小消息头中的原信息（与get请求类似，返回的响应中没有具体内容，用于获取报头）

6、Delete  请求服务器删除request-URL所标示的资源（请求服务器删除页面）

7、Trace  回显服务器收到的请求，用于测试和诊断

8、Connect  HTTP/1.1协议中能够将连接改为管道方式的代理服务器

 

7、 MVC和MTV模式

MTV：Model(模型)：负责业务对象与数据库的对象(ORM)

   Template(模版)：负责如何把页面展示给用户

​     View(视图)：负责业务逻辑，并在适当的时候调用Model和Template

 

MVC: 所谓MVC就是把web应用分为模型(M),控制器(C),视图(V)三层；他们之间以一种插件似的，松耦合的方式连接在一起。模型负责业务对象与数据库的对象(ORM),视图负责与用户的交互(页面)，控制器(C)接受用户的输入调用模型和视图完成用户的请求。

8、 ORM

对象关系映射

优点：

1、ORM使得我们的通用数据库交互变得简单易行，并且完全不用考虑开始的SQL语句。快速开发，由此而来。

2、可以避免一些新手程序猿写sql语句带来的性能效率和安全问题。

缺点：

1、性能有所牺牲，不过现在的各种ORM框架都在尝试使用各种方法来减少这个问题（LazyLoad，Cache），效果还是很显著的。

2、对于个别的负责查询，ORM仍然力不从心。为了解决这个问题，ORm框架一般也提供了直接写原生sql的方式。

 

9、 中间件的作用

中间件是介于request与response处理之间的一道处理过程，能在全局上改变django的输入与输出

 

10、   中间件的4种方法及应用场景（自定义中间件必须继承MiddlewareMixin）

导包、from django.utils.deprecation import MiddlewareMixin

4种方法：

process_request

process_view

process_exception views中出现错误执行该方法

process_response

 

process_template_responseprocess 当函数中有render方法会执行该方法

11、什么是wsgi,uwsgi,uWSGI？

  WSGI:

web服务器网关接口,是一套协议。用于接收用户请求并将请求进行初次封装，然后将请求交给web框架

实现wsgi协议的模块：

​    1.wsgiref,本质上就是编写一个socket服务端，用于接收用户请求(django)

​    2.werkzeug,本质上就是编写一个socket服务端，用于接收用户请求(flask)

uwsgi:

与WSGI一样是一种通信协议，它是uWSGI服务器的独占协议,用于定义传输信息的类型

uWSGI:

​    是一个web服务器,实现了WSGI协议,uWSGI协议,http协议

12、ORM中的方法

  \1. models.Book.objects.all() # 获取到所有的书籍对象,结果是对象列表

   \2. models.Book.objects.get(条件) # 获取符合条件的对象

   \3. models.Book.objects.filter(条件) # 筛选所有符合条件的,结果是对象列表

\4. models.Book.objects.exclude(条件) # 筛选出所有不符合条件的,结果是对象列表

   \5. models.Book.objects.all().values( ) # 字典列表,[ {id:1,name:20} , {id:2,name:18} ]

​    values(‘id’)括号内不指定时显示全部,如指定则只显示指定的,[ {id:1} , {id:2,} ]

   \6. models.Book.objects.all().values_list( ) # 元组列表,[ (1,20) , (2,18) ]同上,指定时显示指定内容

   \7. models.Book.objects.all().order_by(‘id’) # 按照id升序就行排列

   models.Book.objects.all().order_by(‘-id’) # 按照id降序就行排列

   models.Book.objects.all().order_by(‘age’ , ‘-id’) # 先按age升序,age相同的按id进行降序排列

   \8. models.Book.objects.all().order_by(‘id’).reverse() # 对结果反转; 注意reverse前必须排序,

​    否则reverse无效; 或在model.py文件中Book类中的Meta中指定ordering=(‘id’ , )注意逗号必须有

   \9. distinct(): # 去重,当获取到的结果Queryset列表中同一对象出现多次时去重,只留一个

   \10. models.Book.objects.all().count() # 计数,可统计结果个数,如对Queryset内元素数进行统计.

   \11. models.Book.objects.all().first() # 获取结果中的第一条,即使前面结果列表为空,也不会报错

   \12. models.Book.objects.filter().last() # 获取结果中的最后一条

   13.models.Book.objects.filter().exists() # 判断Queryset列表是否有东西,结果为True或False;

 返回对象列表(Queryset)的方法有:

  all()  filter()  ordey_by()  exclude()  values()  values_list()  reverse()  distinct()

 返回单个对象的方法有:

  first()  last()  get()  create()创建一个对象,且返回刚创建的对象

 判断布尔值的有:

  exists()

 返回数字的有:

  count()

13、filter和exclude的区别

  filter返回满足条件的数据

  exclude返回不满足条件的数据

14、ORM中三种能写sql语句的方法

  1、execute 直接访问数据库，避开模型层

  2、extra

  3、raw  for p in Person.objects.raw('SELECT * FROM myapp_person'):

print(p)

15、ORM批量处理数据

插入数据：创建一个对象列表，然后调用bulk_create方法，一次将列表中的数据插入到数据库中。

  product_list_to_insert = list()

for x in range(10):

product_list_to_insert.append(Product(name='product name ' + str(x), price=x))

Product.objects.bulk_create(product_list_to_insert)

  更新数据：先进行数据过滤，然后再调用update方法进行一次性地更新

  Product.objects.filter(name__contains='name').update(name='new name')

  删除数据：先是进行数据过滤，然后再调用delete方法进行一次性删除

  Product.objects.filter(name__contains='name query').delete()

16、CSRF实现机制

  1）启用中间件

2）post请求

3）验证码

4）表单中添加{% csrf_token%}标签

17、Django中提供了runserver为什么不能用来部署项目(runserver与uWSGI的区别)

  1.runserver方法是调试 Django 时经常用到的运行方式，它使用Django自带的

WSGI Server 运行，主要在测试和开发中使用，并且 runserver 开启的方式也是单进程 。

2.uWSGI是一个Web服务器，它实现了WSGI协议、uwsgi、http 等协议。注意uwsgi是一种通信协议，而uWSGI是实现uwsgi协议和WSGI协议的 Web 服务器。

uWSGI具有超快的性能、低内存占用和多app管理等优点，并且搭配着Nginx就是一个生产环境了，能够将用户访问请求与应用 app 隔离开，实现真正的署 。

相比来讲，支持的并发量更高，方便管理多进程，发挥多核的优势，提升性能。

18、Django中如何实现websocket

1、简述：django实现websocket，之前django-websocket退出到3.0之后，被废弃。官方推荐大家使用channels。

2、配置

  1、需要在seting.py里配置，将我们的channels加入INSTALLED_APP里。

19、Django的跨域问题

  1、为什么有跨域？

1、浏览器的同源策略 （从一个域上加载的脚本不允许访问另外一个域的文档属性。）

  2、解决跨域问题

​    1、前端设置代理进行访问

​    2、settings中配置django-cors-headers==2.0.1

​      INSTALLED_APPS中添加 ‘corsheaders’

​      'corsheaders.middleware.CorsMiddleware',#放在session中间件下面

​    添加代码

​      CORS_ALLOW_CREDENTIALS = True

CORS_ORIGIN_ALLOW_ALL = True

\#允许所有的请求头

CORS_ALLOW_HEADERS = ('*')

20、model继承有几种方式，分别是什么？

  抽象基类(Abstract base classes)

  多表继承（Multi-table inheritance）

Meta inheritance 当一个子类没有声明自己的Meta类时，它会继承基类的 Meta 类，如果子类想扩展基类的 Meta 类 ，它可以继承基类的Meta类，然后再进行扩展。

21、values和values_list()的区别

  values : 取字典的queryset

values_list : 取元组的queryset

 

22、class Meta中的原信息字段有哪些？

1、app_label 应用场景：模型类不在默认的应用程序包下的models.py文件中，这时候你需要指定你这个模型类是那个应用程序的。

2、db_table  应用场景：用于指定自定义数据库表名的

3、db_tablespace 应用场景：通过db_tablespace来指定这个模型对应的数据库表放在哪个数据库表空间。

4、verbose_name  应用场景：给你的模型类起一个更可读的名字：

5、verbose_name_plural 应用场景： 模型的复数形式是什么

6、ordering 应用场景：象返回的记录结果集是按照哪个字段排序的

23、视图函数中，常用的验证装饰器有哪些？

 

 

24、web框架的本质

  socket服务端

  自定制web框架

​    from wsgiref.simple_server import make_server

def index():

  return b'index'

def login():

  return b'login'

def routers():

  urlpatterns = (

​    ('/index/', index),

​    ('/login/', login),

  )

  return urlpatterns

def RunServer(environ, start_response):

  start_response('200 OK', [('Content-Type', 'text/html')])

  url = environ['PATH_INFO']

  urlpatterns = routers()

  func = None

  for item in urlpatterns:

​    if item[0] == url:

​      func = item[1]

​      break

  if func:

​    return [func()]

  else:

​    return [b'404 not found']

if __name__ == '__main__':

  httpd = make_server('127.0.0.1',8080,RunServer)

  print("Serving HTTP on port 8080...")

httpd.serve_forever()

25、queryset的get和filter方法的区别

  输入参数：

get的参数只能是model中定义的那些字段，只支持严格匹配

filter的参数可以是字段，也可以是扩展的where查询关键字，如in，like等

返回值：

get返回值是一个定义的model对象

filter返回值是一个新的QuerySet对象，然后可以对QuerySet在进行查询返回新的QuerySet对象，支持链式操作。QuerySet一个集合对象，可使用迭代或者遍历，切片等，但是不等于list类型

异常：

get只有一条记录返回的时候才正常，也就说明get的查询字段必须是主键或者唯一约束的字段。当返回多条记录或者是没有找到记录的时候都会抛出异常。

filter有没有匹配记录都可以。

26、http请求的执行流程

​    1、域名解析

​    2、建立连接

​    3、接收请求  接收客户端访问某一资源的请求

​      单进程I/O

​      多进程I/O

​      复用I/O

​    4、处理请求

​    5、访问资源

​    6、构建响应报文

​    7、发送响应报文

​    8、记录日志

27、如何加载初始化数据

  Body中写onload方法

  Js代码写onload函数执行的过程

28、对Django的认知

\#1.Django是走大而全的方向，它最出名的是其全自动化的管理后台：只需要使用起ORM，做简单的对象定义，它就能自动生成数据库结构、以及全功能的管理后台。

\#2.Django内置的ORM跟框架内的其他模块耦合程度高。

\#应用程序必须使用Django内置的ORM，否则就不能享受到框架内提供的种种基于其ORM的便利；

\#理论上可以切换掉其ORM模块，但这就相当于要把装修完毕的房子拆除重新装修，倒不如一开始就去毛胚房做全新的装修。

\#3.Django的卖点是超高的开发效率，其性能扩展有限；采用Django的项目，在流量达到一定规模后，都需要对其进行重构，才能满足性能的要求。

\#4.Django适用的是中小型的网站，或者是作为大型网站快速实现产品雏形的工具。

\#5.Django模板的设计哲学是彻底的将代码、样式分离； Django从根本上杜绝在模板中进行编码、处理数据的可能。

  \2. Django 、Flask、Tornado的对比

\#1.Django走的是大而全的方向,开发效率高。它的MTV框架,自带的ORM,admin后台管理,自带的sqlite数据库和开发测试用的服务器

\#给开发者提高了超高的开发效率

\#2.Flask是轻量级的框架,自由,灵活,可扩展性很强,核心基于Werkzeug WSGI工具和jinja2模板引擎

\#3.Tornado走的是少而精的方向,性能优越。它最出名的是异步非阻塞的设计方式

\#Tornado的两大核心模块：

\#1.iostraem：对非阻塞式的socket进行简单的封装

\#2.ioloop：对I/O多路复用的封装，它实现了一个单例

29、重定向的实现，用的状态码

​    1.使用HttpResponseRedirect

​      from django.http import HttpResponseRedirect

2.使用redirect和reverse

​      状态码：301和302 #301和302的区别：

相同点：都表示重定向，浏览器在拿到服务器返回的这个状态码后会自动跳转到一个新的URL地址

​      不同点： 301比较常用的场景是使用域名跳转。

30、nginx的正向代理与反向代理

​    正向代理：多台客户端访问远程资源的时候通过的是代理服务器，例如（翻墙）

反向代理：多台客户端访问服务器上的资源的时候，如果用户数量超过了服务器的最大承受限度，通过反向代理分流，把多台客户访问的请求分发到不同的服务器上解决服务器压力的问题

31、路由系统中name的作用

用于反向解析路由,相当于给url取个别名，只要这个名字不变,即使对应的url改变 通过该名字也能找到该条url

32、select_related和prefetch_related的区别？

有外键存在时，可以很好的减少数据库请求的次数,提高性能

\#select_related通过多表join关联查询,一次性获得所有数据,只执行一次SQL查询

\#prefetch_related分别查询每个表,然后根据它们之间的关系进行处理,执行两次查询

33、django orm 中如何设置读写分离？

​    1.手动读写分离:通过.using(db_name)来指定要使用的数据库

​    2.自动读写分离:

​      1.定义类：如Router #

​      2.配置Router settings.py中指定DATABASE_ROUTERS

​      DATABASE_ROUTERS = ['myrouter.Router',]

34、django中如何根据数据库表生成model中的类？

​    1.在settings中设置要连接的数据库

2.生成model模型文件

python manage.py inspectdb

3.模型文件导入到models中

​    python manage.py inspectdb > app/models.py

 

35、什么是RPC

远程过程调用 (RPC) 是一种协议，程序可使用这种协议向网络中的另一台计算机上的程序请求服务

1.RPC采用客户机/服务器模式。请求程序就是一个客户机，而服务提供程序就是一个服务器。

2.首先，客户机调用进程发送一个有进程参数的调用信息到服务进程，然后等待应答信息。 2.在服务器端，进程保持睡眠状态直到调用信息到达为止。当一个调用信息到达，服务器获得进程参数，计算结果，发送答复信息，然后等待下一个调用信息，

3.最后，客户端调用进程接收答复信息，获得进程结果，然后调用执行继续进行。

36、如何实现用户的登录认证

​    1.cookie session

2.token 登陆成功后生成加密字符串

3.JWT：json wed token缩写 它将用户信息加密到token中,服务器不保存任何用户信息 #服务器通过使用保存的密钥来验证token的正确性

37、抽象继承

​    

38、is_valid()的用法

​    检查对象变量是否已经实例化即实例变量的值是否是个有效的对象句柄

39、取消级联删除

40、pv和uv

​    1.pv:页面访问量,没打开一次页面PV计算+1,页面刷新也是

\#2.UV：独立访问数,一台电脑终端为一个访客

41、django rest framework框架中都有那些组件？

​    1.序列化组件:serializers 对queryset序列化以及对请求数据格式校验

2.认证组件 写一个类并注册到认证类(authentication_classes)，在类的的authticate方法中编写认证逻

3.权限组件 写一个类并注册到权限类(permission_classes)，在类的的has_permission方法中编写认证逻辑

4.频率限制 写一个类并注册到频率类(throttle_classes)，在类的的allow_request/wait 方法中编写认证逻辑

​    5.渲染器 定义数据如何渲染到到页面上,在渲染器类中注册(renderer_classes)

​    6.分页 对获取到的数据进行分页处理, pagination_class

42、使用orm和原生sql的优缺点？

1.orm的开发速度快,操作简单。使开发更加对象化 #执行速度慢。处理多表联查等复杂操作时,ORM的语法会变得复杂

2.sql开发速度慢,执行速度快。性能强

43、F和Q的作用?

​    F:对数据本身的不同字段进行操作 如:比较和更新

Q：用于构造复杂的查询条件 如：& |操作

































# Django 的认识，面试题

 

1. 对Django的认识？

```
#1.Django是走大而全的方向，它最出名的是其全自动化的管理后台：只需要使用起ORM，做简单的对象定义，它就能自动生成数据库结构、以及全功能的管理后台。
#2.Django内置的ORM跟框架内的其他模块耦合程度高。
#应用程序必须使用Django内置的ORM，否则就不能享受到框架内提供的种种基于其ORM的便利；
#理论上可以切换掉其ORM模块，但这就相当于要把装修完毕的房子拆除重新装修，倒不如一开始就去毛胚房做全新的装修。
#3.Django的卖点是超高的开发效率，其性能扩展有限；采用Django的项目，在流量达到一定规模后，都需要对其进行重构，才能满足性能的要求。
#4.Django适用的是中小型的网站，或者是作为大型网站快速实现产品雏形的工具。
#5.Django模板的设计哲学是彻底的将代码、样式分离； Django从根本上杜绝在模板中进行编码、处理数据的可能。 
```

2. Django 、Flask、Tornado的对比

```
#1.Django走的是大而全的方向,开发效率高。它的MTV框架,自带的ORM,admin后台管理,自带的sqlite数据库和开发测试用的服务器
#给开发者提高了超高的开发效率
#2.Flask是轻量级的框架,自由,灵活,可扩展性很强,核心基于Werkzeug WSGI工具和jinja2模板引擎
#3.Tornado走的是少而精的方向,性能优越。它最出名的是异步非阻塞的设计方式
#Tornado的两大核心模块：
#    1.iostraem：对非阻塞式的socket进行简单的封装
#    2.ioloop：对I/O多路复用的封装，它实现了一个单例
```

 

3. 什么是wsgi,uwsgi,uWSGI？

```
#WSGI:
#    web服务器网关接口,是一套协议。用于接收用户请求并将请求进行初次封装，然后将请求交给web框架
#    实现wsgi协议的模块：
#        1.wsgiref,本质上就是编写一个socket服务端，用于接收用户请求(django)
#        2.werkzeug,本质上就是编写一个socket服务端，用于接收用户请求(flask)
#uwsgi:
#    与WSGI一样是一种通信协议，它是uWSGI服务器的独占协议,用于定义传输信息的类型
#uWSGI:
#    是一个web服务器,实现了WSGI协议,uWSGI协议,http协议,
```

4. django请求的生命周期？

```
#1.wsgi,请求封装后交给web框架 （Flask、Django）     
#2.中间件，对请求进行校验或在请求对象中添加其他相关数据，例如：csrf、request.session     - 
#3.路由匹配 根据浏览器发送的不同url去匹配不同的视图函数    
#4.视图函数，在视图函数中进行业务逻辑的处理，可能涉及到：orm、templates => 渲染     - 
#5.中间件，对响应的数据进行处理。 
#6.wsgi,将响应的内容发送给浏览器。
```

 

5. 简述什么是FBV和CBV？

```
#FBV和CBV本质是一样的
#基于函数的视图叫做FBV，基于类的视图叫做CBV
#在python中使用CBV的优点：
#1.提高了代码的复用性，可以使用面向对象的技术，比如Mixin（多继承）
#2.可以用不同的函数针对不同的HTTP方法处理，而不是通过很多if判断，提高代码可读性
```

6. 如何给CBV的程序添加装饰器？

```
#引入method_decorator模块
#1.直接在类上加装饰器
#@method_decorator(test,name='dispatch')
#class Loginview(View):
#    pass
#2.直接在处理的函数前加装饰器
#@method_decorator(test)
#    def post(self,request,*args,**kwargs):pass
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

7. 简述MVC和MTV

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#MVC软件系统分为三个基本部分：模型(Model)、视图(View)和控制器(Controller)
#Model：负责业务对象与数据库的映射(ORM)
#View：负责与用户的交互
#Control：接受用户的输入调用模型和视图完成用户的请求
#Django框架的MTV设计模式借鉴了MVC框架的思想,三部分为：Model、Template和View
#Model(模型)：负责业务对象与数据库的对象(ORM)
#Template(模版)：负责如何把页面展示给用户
#View(视图)：负责业务逻辑，并在适当的时候调用Model和Template
#此外,Django还有一个urls分发器,
#它将一个个URL的页面请求分发给不同的view处理,view再调用相应的Model和Template
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

8. django路由系统中name的作用？

```
#用于反向解析路由,相当于给url取个别名，只要这个名字不变,即使对应的url改变
#通过该名字也能找到该条url
```

 

9. 列举django的内置组件？

```
#1.Admin是对model中对应的数据表进行增删改查提供的组件
#2.model组件：负责操作数据库
#3.form组件：1.生成HTML代码2.数据有效性校验3校验信息返回并展示
#4.ModelForm组件即用于数据库操作,也可用于用户请求的验证
```

 

10. 说一下Django，MIDDLEWARES中间件的作用和应用场景？

```
#中间件是介于request与response处理之间的一道处理过程,用于在全局范围内改变Django的输入和输出。
#简单的来说中间件是帮助我们在视图函数执行之前和执行之后都可以做一些额外的操作
#例如：
#1.Django项目中默认启用了csrf保护,每次请求时通过CSRF中间件检查请求中是否有正确#token值
#2.当用户在页面上发送请求时，通过自定义的认证中间件，判断用户是否已经登陆，未登陆就去登陆。
#3.当有用户请求过来时，判断用户是否在白名单或者在黑名单里
```

 

11. 列举django中间件的5个方法？

```
#1.process_request : 请求进来时,权限认证
#2.process_view : 路由匹配之后,能够得到视图函数
#3.process_exception : 异常时执行
#4.process_template_responseprocess : 模板渲染时执行
#5.process_response : 请求有响应时执行
```

 

12. django的request对象是在什么时候创建的？

```
#class WSGIHandler(base.BaseHandler):
#    request = self.request_class(environ)
#请求走到WSGIHandler类的时候，执行__cell__方法，将environ封装成了request
```

 

13. Django重定向是如何实现的？用的什么状态码？

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#1.使用HttpResponseRedirect
#from django.http import HttpResponseRedirect  
#2.使用redirect和reverse
#状态码：301和302
#301和302的区别：
#相同点：都表示重定向，浏览器在拿到服务器返回的这个状态码后会自动跳转到一个新的URL地址
#不同点：
#301比较常用的场景是使用域名跳转。比如，我们访问 http://www.baidu.com 会跳转到 https://www.baidu.com
#表示旧地址A的资源已经被永久地移除了
#302用来做临时跳转，比如未登陆的用户访问用户中心重定向到登录页面。表示旧地址A的资源还在（仍然可以访问），这个重定向只是临时地从旧地址A跳转到地址B
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

14. xxss攻击

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#-- XSS攻击是向网页中注入恶意脚本，用在用户浏览网页时，在用户浏览器中执行恶意脚本的攻击。
#    -- XSS分类，反射型xss ，存储型xss
#    -- 反射型xss又称为非持久型xss，攻击者通过电子邮件等方式将包含注入脚本的链接发送给受害者，
#        受害者通过点击链接，执行注入脚本，达到攻击目的。
#    -- 持久型xss跟反射型的最大不同是攻击脚本将被永久的存放在目标服务器的数据库和文件中，多见于论坛
#        攻击脚本连同正常信息一同注入到帖子内容当中，当浏览这个被注入恶意脚本的帖子的时候，恶意脚本会被执行
#    -- 防范措施 1 输入过滤  2 输出编码  3 cookie防盗
#        1，输入过滤 用户输入进行检测 不允许带有js代码
#        2，输出编码 就是把我们的脚本代码变成字符串形式输出出来
#        3，cookie加密
        
        
        
#向页面注入恶意的代码,这些代码被浏览器执行
#XSS攻击能做些什么：
#    1.窃取cookies
#    2.读取用户未公开的资料，如果：邮件列表或者内容、系统的客户资料，联系人列表
#解决方法:
#    1.客户度端：表单提交之前或者url传递之前,对需要的参数进行过滤
#    2.服务器端：检查用户输入的内容是否有非法内容
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

15. django中csrf的实现机制

```
#第一步：django第一次响应来自某个客户端的请求时,后端随机产生一个token值，把这个token保存在SESSION状态中;同时,后端把这个token放到cookie中交给前端页面；
#第二步：下次前端需要发起请求（比如发帖）的时候把这个token值加入到请求数据或者头信息中,一起传给后端；Cookies:{csrftoken:xxxxx}
#第三步：后端校验前端请求带过来的token和SESSION里的token是否一致；
```

 

16. 基于django使用ajax发送post请求时，都可以使用哪种方法携带csrf token？

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#1.后端将csrftoken传到前端，发送post请求时携带这个值发送
data: {
             csrfmiddlewaretoken: '{{ csrf_token }}'
        },
#2.获取form中隐藏标签的csrftoken值，加入到请求数据中传给后端
 data: {
         csrfmiddlewaretoken:$('[name="csrfmiddlewaretoken"]').val()
         },
#3.cookie中存在csrftoken,将csrftoken值放到请求头中
headers:{ "X-CSRFtoken":$.cookie("csrftoken")}，
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

17. Django本身提供了runserver，为什么不能用来部署？(runserver与uWSGI的区别)

```
#1.runserver方法是调试 Django 时经常用到的运行方式，它使用Django自带的
#WSGI Server 运行，主要在测试和开发中使用，并且 runserver 开启的方式也是单进程 。
#2.uWSGI是一个Web服务器，它实现了WSGI协议、uwsgi、http 等协议。注意uwsgi是一种通信协议，而uWSGI是实现uwsgi协议和WSGI协议的 Web 服务器。
#uWSGI具有超快的性能、低内存占用和多app管理等优点，并且搭配着Nginx就是一个生产环境了，能够将用户访问请求与应用 app 隔离开，实现真正的部署 。
#相比来讲，支持的并发量更高，方便管理多进程，发挥多核的优势，提升性能。
```

 

 

18. cookie和session的区别： 

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#1.cookie:
#    cookie是保存在浏览器端的键值对,可以用来做用户认证
#2.session：
#   将用户的会话信息保存在服务端,key值是随机产生的自符串,value值时session的内容
#    依赖于cookie将每个用户的随机字符串保存到用户浏览器上
#Django中session默认保存在数据库中：django_session表
#flask,session默认将加密的数据写在用户的cookie中
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

19. 列举django orm 中所有的方法（QuerySet对象的所有方法）

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#<1> all():                  查询所有结果 
#<2> filter(**kwargs):       它包含了与所给筛选条件相匹配的对象。获取不到返回None
#<3> get(**kwargs):          返回与所给筛选条件相匹配的对象，返回结果有且只有一个。获取不到会抱胸
#如果符合筛选条件的对象超过一个或者没有都会抛出错误。
#<4> exclude(**kwargs):      它包含了与所给筛选条件不匹配的对象
#<5> order_by(*field):       对查询结果排序
#<6> reverse():              对查询结果反向排序 
#<8> count():                返回数据库中匹配查询(QuerySet)的对象数量。 
#<9> first():                返回第一条记录 
#<10> last():                返回最后一条记录 
#<11> exists():              如果QuerySet包含数据，就返回True，否则返回False
#<12> values(*field):        返回一个ValueQuerySet——一个特殊的QuerySet，运行后得到的并不是一系 model的实例化对象，而是一个可迭代的字典序列
#<13> values_list(*field):   它与values()非常相似，它返回的是一个元组序列，values返回的是一个字典序列
#<14> distinct():            从返回结果中剔除重复纪录
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

20. only和defer的区别？

```
#only:从数据库中只取指定字段的内容
#defer：指定字段的内容不被检索
```

 

21. select_related和prefetch_related的区别？

```
#有外键存在时，可以很好的减少数据库请求的次数,提高性能
#select_related通过多表join关联查询,一次性获得所有数据,只执行一次SQL查询
#prefetch_related分别查询每个表,然后根据它们之间的关系进行处理,执行两次查询
```

 

22. filter和exclude的区别？

```
#取到的值都是QuerySet对象,filter选择满足条件的,exclude:排除满足条件的.
```

 

23. F和Q的作用?

```
#F:对数据本身的不同字段进行操作 如:比较和更新
#Q：用于构造复杂的查询条件 如：& |操作
```

 

24. values和values_list的区别？

```
#values : 取字典的queryset
#values_list : 取元组的queryset
```

 

25. 如何使用django orm批量创建数据？

```
#bulk_create()
#objs=[models.Book(title="图书{}".format(i+15)) for i in range(100)]
#models.Book.objects.bulk_create(objs)
```

 

26. django的Form和ModeForm的作用？

```
#Form作用：

#    1.在前端生成HTML代码
#    2.对数据作有效性校验
#    3.返回校验信息并展示
#ModeForm：根据模型类生成From组件,并且可以操作数据库
```

 

27. django的Form组件中,如果字段中包含choices参数，请使用两种方式实现数据源实时更新。

```
#1.重写构造函数
def def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["city"].widget.choices = models.City.objects.all().values_list("id", "name")
#2.利用ModelChoiceField字段,参数为queryset对象
```

 

28. django的Model中的ForeignKey字段中的on_delete参数有什么作用？

```
#删除关联表中的数据时,当前表与其关联的field的操作
#django2.0之后，表与表之间关联的时候,必须要写on_delete参数,否则会报异常
```

 

29. django如何实现websocket？

\# 列举django orm中三种能写sql语句的方法。

```
#1.使用execute执行自定义的SQL
#2.使用extra方法 
#3.使用raw方法
#    1.执行原始sql并返回模型
#    2.依赖model多用于查询
```

 

30. django orm 中如何设置读写分离？

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#1.手动读写分离:通过.using(db_name)来指定要使用的数据库
#2.自动读写分离:
#    1.定义类：如Router
#    2.配置Router
#        settings.py中指定DATABASE_ROUTERS
#        DATABASE_ROUTERS = ['myrouter.Router',] 
#提高读的性能：多配置几个数据库,并在读取时,随机选取。写的时候写到主库
#实现app之间的数据库分离：分库分表
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

31. django中如何实现orm表中添加数据时创建一条日志记录。

32. django内置的缓存机制？

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
# 全站缓存
MIDDLEWARE_CLASSES = (
    ‘django.middleware.cache.UpdateCacheMiddleware’, #第一
    'django.middleware.common.CommonMiddleware',
    ‘django.middleware.cache.FetchFromCacheMiddleware’, #最后
)
 
# 视图缓存
from django.views.decorators.cache import cache_page
import time
  
@cache_page(15)          #超时时间为15秒
def index(request):
 t=time.time()      #获取当前时间
 return render(request,"index.html",locals())
 
# 模板缓存
{% load cache %}
 <h3 style="color: green">不缓存:-----{{ t }}</h3>
  
{% cache 2 'name' %} # 存的key
 <h3>缓存:-----:{{ t }}</h3>
{% endcache %}
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

 

33. django的缓存能使用redis吗？如果可以的话，如何配置？

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#1.安装 pip install django-redis
#2.在stting中配置CACHES,可以设置多个缓存,根据名字使用
        CACHES = {
            "default": {
                "BACKEND": "django_redis.cache.RedisCache",
                "LOCATION": "redis://127.0.0.1:6379",
                "OPTIONS": {
                    "CLIENT_CLASS": "django_redis.client.DefaultClient",
                    "CONNECTION_POOL_KWARGS": {"max_connections": 100}
                    # "PASSWORD": "密码",
                }
            }
        },
        #另添加缓存
        "JERD": { }
#3.根据名字去连接池中获取连接
        from django_redis import get_redis_connection
        conn = get_redis_connection("default")
```



 

 

34. django的模板中filter和simple_tag的区别？

```
# 自定义filter：{{ 参数1|filter函数名:参数2 }}
#    1.可以与if标签来连用
#    2.自定义时需要写两个形参
# simple_tag:{% simple_tag函数名 参数1 参数2 %}
#    1.可以传多个参数,没有限制
#    2.不能与if标签来连用
```

 

35. django-debug-toolbar的作用？

```
#1.是django的第三方工具包,给django扩展了调试功能
#包括查看sql语句,db查询次数,request,headers等
```

 

36. django中如何实现单元测试？

37. 解释orm中 db first 和 code first的含义？

```
#数据持久化的方式：
#db first基于已存在的数据库,生成模型
#code first基于已存在的模型,生成数据库库
```

 

38. django中如何根据数据库表生成model中的类？

```
#1.在settings中设置要连接的数据库
#2.生成model模型文件
#python manage.py inspectdb
#3.模型文件导入到models中
#    python manage.py inspectdb > app/models.py
```

 

39. 使用orm和原生sql的优缺点？

```
#1.orm的开发速度快,操作简单。使开发更加对象化
#执行速度慢。处理多表联查等复杂操作时,ORM的语法会变得复杂
#2.sql开发速度慢,执行速度快。性能强
```

 

40. django的contenttype组件的作用？

```
#这个组件保存了项目中所有app和model的对应关系,每当我们创建了新的model并执行数据库迁移后，ContentType表中就会自动新增一条记录
#当一张表和多个表FK关联,并且多个FK中只能选择其中一个或其中n个时,可以利用contenttypes
```

 

41. 谈谈你对restful规范的认识？

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#首先restful是一种软件架构风格或者说是一种设计风格，并不是标准，它只是提供了一组设计#原则和约束条件，主要用于客户端和服务器交互类的软件。     
#就像设计模式一样，并不是一定要遵循这些原则，而是基于这个风格设计的软件可以更简洁，更#有层次，我们可以根据开发的实际情况，做相应的改变。
#它里面提到了一些规范，例如：
#1.restful 提倡面向资源编程,在url接口中尽量要使用名词，不要使用动词             
#2、在url接口中推荐使用Https协议，让网络接口更加安全
#https://www.bootcss.com/v1/mycss？page=3
#（Https是Http的安全版，即HTTP下加入SSL层，HTTPS的安全基础是SSL，
#因此加密的详细内容就需要SSL（安全套接层协议））                          
#3、在url中可以体现版本号
#https://v1.bootcss.com/mycss
#不同的版本可以有不同的接口，使其更加简洁，清晰             
#4、url中可以体现是否是API接口 
#https://www.bootcss.com/api/mycss            
#5、url中可以添加条件去筛选匹配
#https://www.bootcss.com/v1/mycss？page=3             
#6、可以根据Http不同的method，进行不同的资源操作
#（5种方法：GET / POST / PUT / DELETE / PATCH）             
#7、响应式应该设置状态码
#8、有返回值，而且格式为统一的json格式             
#9、返回错误信息
#返回值携带错误信息             
#10、返回结果中要提供帮助链接，即API最好做到Hypermedia
#如果遇到需要跳转的情况 携带调转接口的URL
    　　ret = {
            code: 1000,
            data:{
            id:1,
            name:'小强',
            depart_id:http://www.luffycity.com/api/v1/depart/8/
            }
    }
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

42. 接口的幂等性是什么意思？

```
#1.是系统的接口对外一种承诺(而不是实现)
#2.承诺只要调用接口成功,外部多次调用对系统的影响都是一致的,不会对资源重复操作
```

 

43. 什么是RPC？

```
#远程过程调用 (RPC) 是一种协议，程序可使用这种协议向网络中的另一台计算机上的程序请求服务
#1.RPC采用客户机/服务器模式。请求程序就是一个客户机，而服务提供程序就是一个服务器。
#2.首先，客户机调用进程发送一个有进程参数的调用信息到服务进程，然后等待应答信息。
#2.在服务器端，进程保持睡眠状态直到调用信息到达为止。当一个调用信息到达，服务器获得进程参数，计算结果，发送答复信息，然后等待下一个调用信息，
#3.最后，客户端调用进程接收答复信息，获得进程结果，然后调用执行继续进行。
```

 

44. 为什么要使用API

```
#系统之间为了调用数据。
#数据传输格式:
#    1.json
#     2.xml 
```

 

45. 为什么要使用django rest framework框架？

```
#能自动生成符合 RESTful 规范的 API
#1.在开发REST API的视图中，虽然每个视图具体操作的数据不同，
#但增、删、改、查的实现流程基本一样,这部分的代码可以简写
#2.在序列化与反序列化时，虽然操作的数据不同，但是执行的过程却相似,这部分的代码也可以简写
#REST framework可以帮助简化上述两部分的代码编写，大大提高REST API的开发速度
```

 

46. django rest framework框架中都有那些组件？

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#1.序列化组件:serializers  对queryset序列化以及对请求数据格式校验
#2.路由组件routers 进行路由分发
#3.视图组件ModelViewSet  帮助开发者提供了一些类，并在类中提供了多个方法
#4.认证组件 写一个类并注册到认证类(authentication_classes)，在类的的authticate方法中编写认证逻
#5.权限组件 写一个类并注册到权限类(permission_classes)，在类的的has_permission方法中编写认证逻辑。 
#6.频率限制 写一个类并注册到频率类(throttle_classes)，在类的的allow_request/wait 方法中编写认证逻辑
#7.解析器  选择对数据解析的类，在解析器类中注册(parser_classes)
#8.渲染器 定义数据如何渲染到到页面上,在渲染器类中注册(renderer_classes)
#9.分页  对获取到的数据进行分页处理, pagination_class
#10.版本  版本控制用来在不同的客户端使用不同的行为
#在url中设置version参数，用户请求时候传入参数。在request.version中获取版本，根据版本不同 做不同处理 
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

47. django rest framework框架中的视图都可以继承哪些类？

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#class View(object):
#class APIView(View): 封装了view,并且重新封装了request,初始化了各种组件
#class GenericAPIView(views.APIView):
#1.增加了一些属性和方法,如get_queryset,get_serializer
#class GenericViewSet(ViewSetMixin, generics.GenericAPIView)
#父类ViewSetMixin 重写了as_view,返回return csrf_exempt(view)
#并重新设置请求方式与执行函数的关系
#class ModelViewSet(mixins.CreateModelMixin,
#                   mixins.RetrieveModelMixin,
#                   mixins.UpdateModelMixin,
#                   mixins.DestroyModelMixin,
#                   mixins.ListModelMixin,
#                   GenericViewSet):pass
#继承了mixins下的一些类,封装了list,create,update等方法
#和GenericViewSet
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

48. 简述 django rest framework框架的认证流程

```
#1.用户请求走进来后,走APIView,初始化了默认的认证方法
#2.走到APIView的dispatch方法,initial方法调用了request.user
#3.如果我们配置了认证类,走我们自己认证类中的authentication方法
```

 

49. django rest framework如何实现的用户访问频率控制

```
#使用IP/用户账号作为键，每次的访问时间戳作为值，构造一个字典形式的数据，存起来，每次访问时对时间戳列表的元素进行判断，
#把超时的删掉，再计算列表剩余的元素数就能做到频率限制了 
#匿名用户：使用IP控制，但是无法完全控制，因为用户可以换代理IP登录用户：使用账号控制，但是如果有很多账号，也无法限制
```

 

50. rest_framework序列化组件的作用,以及一些外键关系的钩子方法

```
#作用：帮助我们序列化数据
#1.choices  get_字段名_display
#2.ForeignKey source=orm 操作
#3.ManyToManyFiled  SerializerMethodField()
#                    def get_字段名():
#                    return 自定义
```

 

51. 给用户提供一个接口之前需要提前做什么

```
#1.跟前端进行和交互,确定前端要什么
#2.把需求写个文档保存
```

 

52. PV和UV

```
#1.pv:页面访问量,没打开一次页面PV计算+1,页面刷新也是
#2.UV：独立访问数,一台电脑终端为一个访客
```

 

53. 什么是跨域以及解决方法:

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
#跨域：
# 浏览器从一个域名的网页去请求另一个域名的资源时,浏览器处于安全的考虑,不允许不同源的请求
#同源策略：
#  协议相同
#  域名相同
#  端口相同
#处理方法：
# 1.通过JSONP跨域
# JSON是一种数据交换格式
# JSONP是一种非官方的跨域数据交互协议
# jsonp是包含在函数调用中的json
# script标签不受同源策略的影响，手动创建一个script标签,传递URL,同时传入一个回调函数的名字
# 服务器得到名字后,返回数据时会用这个函数名来包裹住数据,客户端获取到数据之后，立即把script标签删掉
# 2.cors：跨域资源共享
# 使用自定义的HTTP头部允许浏览器和服务器相互通信
# 1.如果是简单请求,直接设置允许访问的域名：
#   允许你的域名来获取我的数据                         
#   response['Access-Control-Allow-Origin'] = "*"
# 2.如果是复杂请求,首先会发送options请求做预检,然后再发送真正的PUT/POST....请求
#   因此如果复杂请求是PUT等请求,则服务端需要设置允许某请求
#   如果复杂请求设置了请求头，则服务端需要设置允许某请求头
#简单请求：
#    一次请求 
#非简单请求：
#    两次请求，在发送数据之前会先发一次请求用于做“预检”，
#    只有“预检”通过后才再发送一次请求用于数据传输。

#只要同时满足以下两大条件，就属于简单请求。                             
# (1) 请求方法是以下三种方法之一：HEAD  GET POST
# (2)HTTP的头信息不超出以下几种字段：                                     
#   Accept                                     
#   Accept-Language                                     
#   Content-Language
#   Last-Event-ID
#  Content-Type：只限于三个值application/x-www-form-urlencoded、multipart/form-data、 text/plain 
#JSONP和CORS：
#   1.JSONP只能实现GET请求，而CORS支持所有类型的HTTP请求
#   2.jsonp需要client和server端的相互配合
#   3.cors在client端无需设置，server端需要针对不同的请求，来做head头的处理
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

54. 如何实现用户的登陆认证

```
#1.cookie session
#2.token 登陆成功后生成加密字符串
#3.JWT：json wed token缩写 它将用户信息加密到token中,服务器不保存任何用户信息
#服务器通过使用保存的密钥来验证token的正确性
```

 

 

55. 如何将dict转换成url的格式：

```
#使用urlencode
#from urllib.parse import urlencode
#post_data={"k1"："v1","k2":"v2"}
#ret=urlencode(post_data)
#print(ret,type(ret))  #k1=v1&k2=v2 <class 'str'>
```

 