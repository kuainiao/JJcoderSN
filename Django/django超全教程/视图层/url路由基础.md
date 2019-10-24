# URL路由基础

### 路由的编写方式是Django2.0和1.11最大的区别所在。Django官方迫于压力和同行的影响，不得不将原来的正则匹配表达式，改为更加简单的path表达式，但依然通过re_path()方法保持对1.x版本的兼容。

------

URL是Web服务的入口，用户通过浏览器发送过来的任何请求，都是发送到一个指定的URL地址，然后被响应。

在Django项目中编写路由，就是向外暴露我们接收哪些URL的请求，除此之外的任何URL都不被处理，也没有返回。通俗地理解，不恰当的形容，URL路由是你的Web服务对外暴露的API。

Django奉行DRY主义，提倡使用简洁、优雅的URL，没有`.php`或`.cgi`这种后缀，更不会单独使用0、2097、1-1-1928、00这样无意义的东西，让你随心所欲设计你的URL，不受框架束缚。

## 一、概述

URL路由在Django项目中的体现就是`urls.py`文件，这个文件可以有很多个，但绝对不会在同一目录下。实际上Django提倡项目有个根`urls.py`，各app下分别有自己的一个`urls.py`，既集中又分治，是一种解耦的模式。

随便新建一个Django项目，默认会自动为我们创建一个`/project_name/urls.py`文件，并且自动包含下面的内容，这就是项目的根URL：

```
"""dj_test URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path

urlpatterns = [
    path('admin/', admin.site.urls),
]
```

前面一堆帮助性的文字，我们不用管，关键是默认导入了path方法和admin模块，然后有一条指向admin后台的url路径。

我们自己要编写的url路由，基本也是这个套路。

## 二、Django如何处理请求

当用户请求一个页面时，Django根据下面的逻辑执行操作：

1. **决定要使用的根URLconf模块。**通常，这是`ROOT_URLCONF`设置的值，但是如果传入的HttpRequest对象具有urlconf属性（由中间件设置），则其值将被用于代替`ROOT_URLCONF`设置。通俗的讲，就是你可以自定义项目入口url是哪个文件！
2. **加载该模块并寻找可用的urlpatterns。** 它是`django.urls.path()`或者`django.urls.re_path()`实例的一个列表。
3. **依次匹配每个URL模式，在与请求的URL相匹配的第一个模式停下来**。也就是说，url匹配是从上往下的短路操作，所以url在列表中的位置非常关键。
4. 导入并调用匹配行中给定的视图，该视图是一个简单的Python函数（被称为视图函数）,或基于类的视图。 视图将获得如下参数:
    1. 一个HttpRequest 实例。
    2. 如果匹配的表达式返回了未命名的组，那么匹配的内容将作为位置参数提供给视图。
    3. 关键字参数由表达式匹配的命名组组成，但是可以被`django.urls.path()`的可选参数kwargs覆盖。
5. 如果没有匹配到任何表达式，或者过程中抛出异常，将调用一个适当的错误处理视图。

## 三、简单示例

先看一个例子：

```
from django.urls import path

from . import views

urlpatterns = [
    path('articles/2003/', views.special_case_2003),
    path('articles/<int:year>/', views.year_archive),
    path('articles/<int:year>/<int:month>/', views.month_archive),
    path('articles/<int:year>/<int:month>/<slug:slug>/', views.article_detail),
]
```

注意：

1. 要捕获一段url中的值，需要使用尖括号，而不是之前的圆括号；
2. 可以转换捕获到的值为指定类型，比如例子中的int。默认情况下，捕获到的结果保存为字符串类型，不包含`/`这个特殊字符；
3. 匹配模式的最开头不需要添加`/`，因为默认情况下，每个url都带一个最前面的`/`，既然大家都有的部分，就不用浪费时间特别写一个了。

匹配例子：

- /articles/2005/03/ 将匹配第三条，并调用views.month_archive(request, year=2005, month=3)；
- /articles/2003/匹配第一条，并调用views.special_case_2003(request)；
- /articles/2003将一条都匹配不上，因为它最后少了一个斜杠，而列表中的所有模式中都以斜杠结尾；
- /articles/2003/03/building-a-django-site/ 将匹配最后一个，并调用views.article_detail(request, year=2003, month=3, slug="building-a-django-site"

每当urls.py文件被第一次加载的时候，urlpatterns里的表达式们都将被预先编译，这会大大提高系统处理路由的速度。

## 四、path转换器

默认情况下，Django内置下面的路径转换器：

- `str`：匹配任何非空字符串，但不含斜杠`/`，如果你没有专门指定转换器，那么这个是默认使用的；
- `int`：匹配0和正整数，返回一个int类型
- `slug`：可理解为注释、后缀、附属等概念，是url拖在最后的一部分解释性字符。该转换器匹配任何ASCII字符以及连接符和下划线，比如`building-your-1st-django-site`；
- `uuid`：匹配一个uuid格式的对象。为了防止冲突，规定必须使用破折号，所有字母必须小写，例如`075194d3-6885-417e-a8a8-6c931e272f00`。返回一个UUID对象；
- `path`：匹配任何非空字符串，重点是可以包含路径分隔符’/‘。这个转换器可以帮助你匹配整个url而不是一段一段的url字符串。**要区分path转换器和path()方法**。

## 五、自定义path转换器

其实就是写一个类，并包含下面的成员和属性：

- 类属性regex：一个字符串形式的正则表达式属性；
- to_python(self, value) 方法：一个用来将匹配到的字符串转换为你想要的那个数据类型，并传递给视图函数。如果转换失败，它必须弹出ValueError异常；
- to_url(self, value)方法：将Python数据类型转换为一段url的方法，上面方法的反向操作。

例如，新建一个converters.py文件，与urlconf同目录，写个下面的类：

```
class FourDigitYearConverter:
    regex = '[0-9]{4}'

    def to_python(self, value):
        return int(value)

    def to_url(self, value):
        return '%04d' % value
```

写完类后，在URLconf 中注册，并使用它，如下所示，注册了一个yyyy：

```
from django.urls import register_converter, path

from . import converters, views

register_converter(converters.FourDigitYearConverter, 'yyyy')

urlpatterns = [
    path('articles/2003/', views.special_case_2003),
    path('articles/<yyyy:year>/', views.year_archive),
    ...
]
```

## 六、使用正则表达式

Django2.0的url虽然改‘配置’了，但它依然向老版本兼容。而这个兼容的办法，就是用`re_path()`方法代替`path()`方法。`re_path()`方法在骨子里，根本就是以前的`url()`方法，只不过导入的位置变了。下面是一个例子，对比一下Django1.11时代的语法，有什么太大的差别？

```
from django.urls import path, re_path

from . import views

urlpatterns = [
    path('articles/2003/', views.special_case_2003),
    re_path(r'^articles/(?P<year>[0-9]{4})/$', views.year_archive),
    re_path(r'^articles/(?P<year>[0-9]{4})/(?P<month>[0-9]{2})/$', views.month_archive),
    re_path(r'^articles/(?P<year>[0-9]{4})/(?P<month>[0-9]{2})/(?P<slug>[\w-]+)/$', views.article_detail),
]
```

与`path()`方法不同的在于两点：

- year中匹配不到10000等非四位数字，这是正则表达式决定的
- 传递给视图的所有参数都是字符串类型。而不像`path()`方法中可以指定转换成某种类型。在视图中接收参数时一定要小心。

## 七、URLconf匹配URL中的哪些部分

请求的URL被看做是一个普通的Python字符串，URLconf在其上查找并匹配。**进行匹配时将不包括GET或POST请求方式的参数以及域名。**

例如，在`https://www.example.com/myapp/`的请求中，URLconf将查找`myapp/`。

在`https://www.example.com/myapp/?page=3`的请求中，URLconf也将查找`myapp/`。

URLconf不检查使用何种HTTP请求方法，所有请求方法POST、GET、HEAD等都将路由到同一个URL的同一个视图。在视图中，才根据具体请求方法的不同，进行不同的处理。

## 八、指定视图参数的默认值

有一个小技巧，我们可以指定视图参数的默认值。 下面是一个URLconf和视图的示例：

```
# URLconf
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

在上面的例子中，两个URL模式指向同一个视图`views.page`。但是第一个模式不会从URL中捕获任何值。 如果第一个模式匹配，page()函数将使用num参数的默认值"1"。 如果第二个模式匹配，page()将使用捕获的num值。

## 九、自定义错误页面

当Django找不到与请求匹配的URL时，或者当抛出一个异常时，将调用一个错误处理视图。Django默认的自带的错误视图包括400、403、404和500，分别表示请求错误、拒绝服务、页面不存在和服务器错误。它们分别位于：

- handler400 —— django.conf.urls.handler400。
- handler403 —— django.conf.urls.handler403。
- handler404 —— django.conf.urls.handler404。
- handler500 —— django.conf.urls.handler500。

这些值可以在根URLconf中设置。在其它app中的二级URLconf中设置这些变量无效。

Django有内置的HTML模版，用于返回错误页面给用户，但是这些403，404页面实在丑陋，通常我们都自定义错误页面。

首先，在根URLconf中额外增加下面的条目，并导入views模块：

```
from django.contrib import admin
from django.urls import path
from app import views

urlpatterns = [
    path('admin/', admin.site.urls),
]

# 增加的条目
handler400 = views.bad_request
handler403 = views.permission_denied
handler404 = views.page_not_found
handler500 = views.error
```

然后在，app/views.py文件中增加四个处理视图：

```
def bad_request(request):
    return render(request, '400.html')


def permission_denied(request):
    return render(request, '403.html')


def page_not_found(request):
    return render(request, '404.html')


def error(request):
    return render(request, '500.html')
```

再根据自己的需求，创建对应的400、403、404、500.html四个页面文件，就可以了（要注意好模板文件的引用方式，视图的放置位置等等）。