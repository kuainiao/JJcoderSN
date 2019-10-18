## 视图
视图一般都写在app下的views.py中.并且视图中的第一个参数永远都是`request`(一个HttpRequest)
对象.这个对象存储请求过来的所有信息,包括请求过来的参数和一些头部信息.在视图中，一般是完成逻辑相关
的操作。比如这个请求是添加一篇博客，那么可以通过request来接收到这些数据，然后存储到数据库中，
最后再把执行的结果返回给浏览器。视图函数的返回结果必须是`HttpResponseBase`对象或者子类的对象。  
示例代码如下：

```python
from django.http import HttpResponse

def book(request):
    return HttpResponse("书籍页")

def book_detail(request, book_id):
    text = "请输入书籍的id: %s" % id
    return HttpRsponse(text)   
```

## URL映射
视图写完后,要与URL进行映射,也即用户在浏览器中输入什么url的时候可以请求到这个视图函数,在用户输入
了某个url，请求到我们的网站的时候，django会从项目的urls.py文件中寻找对应的视图。在urls.py文件
中有一个`urlpatterns`变量，以后django就会从这个变量中读取所有的匹配规则。匹配规则需要使用
`django.urls.path`函数进行包裹，这个函数会根据传入的参数返回`URLPattern`或者是`URLResolver`的对象。  
示例代码如下：
```djangotemplate
from django.url import path
from book import views
urlpattern = [
    path('book/', views.book, name="book")
]
```

## URL中添加参数
有时候，url中包含了一些参数需要动态调整。比如简书某篇文章的详情页的url，
是https://www.jianshu.com/p/a5aab9c4978e后面的a5aab9c4978e就是这篇文章的id，
那么简书的文章详情页面的url就可以写成https://www.jianshu.com/p/<id>，其中id就是文章的id。
那么如何在django中实现这种需求呢。这时候我们可以在path函数中，使用尖括号的形式来定义一个参数。
比如我现在想要获取一本书籍的详细信息，那么应该在url中指定这个参数。  
示例代码如下：  
```djangourlpath
from django.url import path
from book import views
urlpattern = [
    path('book/<book_id>', views.book_detail, name="book_detail")
]
```
也可以通过查询字符串的方式传递一个参数过去.
```djangourlpath
from django.url import path
form book import views
urlpattern = [
    path("book/book_detail", views.book_detail, name="detail")
]
```

`views.py`中的代码:
```djangourlpath
from django.http import HttpResponse
def book_detail(request):
    book_id = request.GET.get("id")
    text = "请输入书籍的id: %s" % book_id
    return HttpResponse(text)
```
以后在访问的时候就是通过/book/detail/?id=1即可将参数传递过去。

## URL中包含另外一个urls模块(urls分层模块化)：
在我们的项目中，不可能只有一个app，如果把所有的app的views中的视图都放在urls.py中进行映射，
肯定会让代码显得非常乱。因此django给我们提供了一个方法，可以在app内部包含自己的url匹配规则，
而在项目的urls.py中再统一包含这个app的urls。使用这个技术需要借助`include`函数。  
示例代码如下：  
first_project/urls.py文件：

```djangourlpath
from django.contrib import admin
from django.urls import path,include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('book/',include("book.urls"))
]
```

在urls.py文件中把所有的和book这个app相关的url都移动到app/urls.py中了，
然后在first_project/urls.py中，通过include函数包含book.urls，
以后在请求book相关的url的时候都需要加一个book的前缀。
book/urls.py文件：

```djangourlpath
from django.urls import path
from . import views

urlpatterns = [
    path('list/',views.book_list),
    path('detail/<book_id>/',views.book_detail)
]
```
以后访问书的列表的url的时候，就通过/book/list/来访问，访问书籍详情页面的url的时候
就通过book/detail/<id>来访问。

## path函数：
path函数的定义为：`path(route,view,name=None,kwargs=None)`。以下对这几个参数进行讲解。  
>这里想要理解内置URL转换器是怎么运行的要看源码:
```
from django.urls import converters
```
```python
import uuid
from functools import lru_cache


class IntConverter:
    regex = '[0-9]+'  # 0-9数字中的一个或者多个

    def to_python(self, value):   # 实现to_python(self,value)方法，这个方法是将url中的值转换一下，然后传给视图函数的。

        return int(value)

    def to_url(self, value):   # 实现to_url(self,value)方法，这个方法是在做url反转的时候，将传进来的参数转换后拼接成一个正确的url。
        return str(value)


class StringConverter:
    regex = '[^/]+'    # 这里的^是一个托字符, 指不是/的任意字符,一次或者多次

    def to_python(self, value):
        return value

    def to_url(self, value):
        return value


class UUIDConverter:
    regex = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' # 这是uuid的匹配规则

    def to_python(self, value):
        return uuid.UUID(value)

    def to_url(self, value):
        return str(value)


class SlugConverter(StringConverter):
    regex = '[-a-zA-Z0-9_]+'     # 英文的-,数字,字母,或者下划线,一个或者多个


class PathConverter(StringConverter):  
    regex = '.+'  # .出现一次或者多次


DEFAULT_CONVERTERS = {
    'int': IntConverter(),
    'path': PathConverter(),
    'slug': SlugConverter(),
    'str': StringConverter(),
    'uuid': UUIDConverter(),
}


REGISTERED_CONVERTERS = {}


def register_converter(converter, type_name):
    REGISTERED_CONVERTERS[type_name] = converter()  # 添加到注册表中
    get_converters.cache_clear() # 清理缓存文件


@lru_cache(maxsize=None)
def get_converters():
    return {**DEFAULT_CONVERTERS, **REGISTERED_CONVERTERS}


def get_converter(raw_converter):
    return get_converters()[raw_converter]
```
>**route参数**：url的匹配规则。这个参数中可以指定url中需要传递的参数，比如在访问文章详情页的时候，
可以传递一个id。传递参数是通过`<>`尖括号来进行指定的。并且在传递参数的时候，
可以指定这个参数的数据类型，比如文章的id都是int类型，那么可以这样写<int:id>，
以后匹配的时候，就只会匹配到id为int类型的url，而不会匹配其他的url，
并且在视图函数中获取这个参数的时候，就已经被转换成一个int类型了。  
##### 其中还有几种常用的类型(内置url转换器)：  
>**str**：非空的字符串类型。默认的转换器。但是`不能包含斜杠.`
>**int**：匹配任意的零或者正数的整形。到视图函数中就是一个int类型。  
>**slug**：由英文中的横杠-，或者下划线_连接英文字符或者数字而成的字符串。  
>**uuid**：匹配uuid字符串。  
>**path**：匹配非空的英文字符串，`可以包含斜杠`.这是与str的区别.(有时我们需要斜杠,这是有用的)

>**view参数**：可以为一个视图函数或者是类视图`.as_view()`或者是`django.urls.include()`函数的返回值。  
>**name参数**：这个参数是给这个url取个名字的，这在项目比较大，url比较多的时候用处很大。  
>**kwargs参数**：有时候想给视图函数传递一些额外的参数，就可以通过kwargs参数进行传递。这个参数接收一个字典。传到视图函数中的时候，会作为一个关键字参数传过去. 

#### UUID的获取方式:
```python
import uuid
print(uuid.uuid4())
```

比如以下的url规则：
```
 from django.urls import path
 from . import views

 urlpatterns = [
     path('blog/<int:year>/', views.year_archive, {'foo': 'bar'}),
 ]
```
那么以后在访问blog/1991/这个url的时候，会将foo=bar作为关键字参数传给year_archive函数。  

## re_path函数：
有时候我们在写url匹配的时候，想要写使用正则表达式来实现一些复杂的需求，那么这时候我们可以使用re_path来实现。re_path的参数和path参数一模一样，只不过第一个参数也就是route参数可以为一个正则表达式。
一些使用re_path的示例代码如下：
```
from django.urls import path, re_path

from . import views

urlpatterns = [
    path('articles/2003/', views.special_case_2003),
    re_path(r'articles/(?P<year>[0-9]{4})/', views.year_archive),
    re_path(r'articles/(?P<year>[0-9]{4})/(?P<month>[0-9]{2})/', views.month_archive),
    re_path(r'articles/(?P<year>[0-9]{4})/(?P<month>[0-9]{2})/(?P<slug>[\w-_]+)/', views.article_detail),
]
```
以上例子中我们可以看到，所有的route字符串前面都加了一个r，表示这个字符串是一个`原生字符串`。在写正则表达式中是推荐使用原生字符串的，这样可以避免在python这一层面进行转义。而且，使用正则表达式捕获参数的时候，是用一个圆括号进行包裹，然后这个参数的名字是通过尖括号<year>进行包裹，之后才是写正则表达式的语法。`如果能用path解决的,就避免使用re_path,因为正则表达式是晦涩的`

## include函数：
在项目变大以后，经常不会把所有的url匹配规则都放在项目的urls.py文件中，而是每个app都有自己的urls.py文件，在这个文件中存储的都是当前这个app的所有url匹配规则。然后再统一注册到项目的urls.py文件中。include函数有多种用法，这里讲下两种常用的用法。

`include(pattern,namespace=None)`：直接把其他app的urls包含进来。示例代码如下：
```
 from django.contrib import admin
 from django.urls import path,include

 urlpatterns = [
     path('admin/', admin.site.urls),
     path('book/',include("book.urls"))
 ]
```
当然也可以传递namespace参数来指定一个`实例命名空间`，但是在使用实例命名空间之前，必须先指定一个`应用命名空间`。
示例代码如下：

主urls.py文件：
```
from django.urls import path,include
urlpatterns = [
    path('movie/',include('movie.urls',namespace='movie'))
]
```
然后在movie/urls.py中指定应用命名空间。实例代码如下：
```
from django.urls import path
from . import views

# 应用命名空间
app_name = 'movie'

urlpatterns = [
    path('',views.movie,name='index'),
    path('list/',views.movie_list,name='list'),
]
```
**`include(pattern_list)`**：可以包含一个列表或者一个元组，这个元组或者列表中又包含的是`path`或者是`re_path`函数。这种写法用的比较少.

**`include((pattern,app_namespace),namespace=None)`**：在包含某个app的urls的时候，可以指定命名空间，这样做的目的是为了防止不同的app下出现相同的url，这时候就可以通过命名空间进行区分。

示例代码如下：
```
 from django.contrib import admin
 from django.urls import path,include

 urlpatterns = [
     path('admin/', admin.site.urls),
     path('book/',include(("book.urls",'book')),namespace='book') # 这里是一个元组(子urls模块, 应用命名空间)
 ]
```
但是这样做的前提是已经包含了应用命名空间。即在myapp.urls.py中添加一个和urlpatterns同级别的变量app_name。

**指定默认的参数**：
使用path或者是re_path的后，在route中都可以包含参数，而有时候想指定默认的参数，这时候可以通过以下方式来完成。示例代码如下：
```
from django.urls import path

from . import views

urlpatterns = [
    path('blog/', views.page),
    path('blog/page<int:num>/', views.page),
]

# View (in blog/views.py)
def page(request, num=1):
    # Output the appropriate page of blog entries, according to num.
    ...
```
当在访问blog/的时候，因为没有传递num参数，所以会匹配到第一个url，这时候就执行view.page这个视图函数，而在page函数中，又有num=1这个默认参数。因此这时候就可以不用传递参数。而如果访问blog/1的时候，因为在传递参数的时候传递了num，因此会匹配到第二个url，这时候也会执行views.page，然后把传递进来的参数传给page函数中的num。

## url反转：
之前我们都是通过url来访问视图函数。有时候我们知道这个视图函数，但是想反转回他的url。这时候就可以通过reverse来实现。
示例代码如下：
```
reverse("list")
/book/list/
```
如果有应用命名空间或者有实例命名空间，那么**应该在反转的时候加上命名空间**。(这里很重要, 踩过的坑)
示例代码如下：
```
reverse('book:list')
/book/list/
```
如果这个url中需要传递参数，那么可以通过kwargs来传递参数。

示例代码如下：
```
reverse("book:detail",kwargs={"book_id":1})
 /book/detail/1
```
因为django中的reverse反转url的时候不区分GET请求和POST请求，因此不能在反转的时候添加查询字符串的参数。如果想要添加查询字符串的参数，只能手动的添加。

示例代码如下：
```
login_url = reverse('login') + "?next=/"
```
## 自定义URL转换器：
之前已经学到过一些django内置的url转换器，包括有int、uuid等。有时候这些内置的url转换器并不能满足
我们的需求，因此django给我们提供了一个接口可以让我们自己定义自己的url转换器。
#### 自定义url转换器按照以下五个步骤来走就可以了：
1.定义一个类。  
2.在类中定义一个属性regex，这个属性是用来保存url转换器规则的正则表达式。  
3.实现to_python(self,value)方法，这个方法是将url中的值转换一下，然后传给视图函数的。  
4.实现to_url(self,value)方法，这个方法是在做url反转的时候，将传进来的参数转换后拼接成一个
正确的url。  
5.将定义好的转换器，注册到django中。比如写一个匹配四个数字年份的url转换器。  
示例代码如下：  

```
# 1. 定义一个类
class FourDigitYearConverter:
    # 2. 定义一个正则表达式
    regex = '[0-9]{4}'

    # 3. 定义to_python方法
    def to_python(self, value):
        return int(value)

    # 4. 定义to_url方法
    def to_url(self, value):
        return '%04d' % value     

# 5. 注册到django中
from django.urls import register_converter
register_converter(converters.FourDigitYearConverter, 'yyyy')
urlpatterns = [
    path('articles/2003/', views.special_case_2003),
    # 使用注册的转换器
    path('articles/<yyyy:year>/', views.year_archive),
    ...
]
```
为了使得url转换器好管理,需要在app下面,建立一个reversers.py文件,同时这样虽然已经写好了,但是这个代码却没有得到执行,所以需要把这个模块导入到此app下面的__init__.py文件中.(因为只要导入包就会去执行一下__init__.py的文件)
`from . import reversers`