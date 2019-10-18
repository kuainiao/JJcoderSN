# 网站地图sitemap

阅读: 9962     [评论](http://www.liujiangblog.com/course/django/169#comments)：6

网站地图是根据网站的结构、框架、内容，生成的导航网页，是一个网站所有链接的容器。很多网站的连接层次比较深，蜘蛛很难抓取到，网站地图可以方便搜索引擎或者网络蜘蛛抓取网站页面，了解网站的架构，为网络蜘蛛指路，增加网站内容页面的收录概率。网站地图一般存放在域名根目录下并命名为sitemap，比如`http://www.liujiangblog.com/sitemap.xml`。

一个典型的sitemap，其内容片段如下：

```
This XML file does not appear to have any style information associated with it. The document tree is shown below.
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
<url>
<loc>http://www.liujiangblog.com/blog/9/</loc>
<lastmod>2017-12-08</lastmod>
<priority>0.4</priority>
</url>
<url>
<loc>http://www.liujiangblog.com/blog/8/</loc>
<lastmod>2017-12-05</lastmod>
<priority>0.4</priority>
</url>
<url>
<loc>http://www.liujiangblog.com/blog/7/</loc>
<lastmod>2017-11-19</lastmod>
<priority>0.4</priority>
</url>
# 更多内容未列出
```

Django自带了一个高级的生成网站地图的框架，我们可以很容易地创建出XML格式的网站地图。创建网站地图，只需编写一个Sitemap类，并在URLconf中编写对应的访问路由。

## 一、安装

安装sitemap框架的步骤如下：

1. 在INSTALLED_APPS设置中添加'django.contrib.sitemaps' .
2. 确认settings.py中的`TEMPLATES`设置包含`DjangoTemplates`后端，并将`APP_DIRS`选项设置为True。其实，默认配置就是这样的，只有当你曾经修改过这些设置，才需要调整过来。
3. 确认你已经安装sites框架. (注意: 网站地图APP并不需要在数据库中建立任何数据库表。修改`INSTALLED_APPS`的唯一原因是，以便`Loader()`模板加载器可以找到默认模板。）

## 二、初始化

为了在网站上激活站点地图生成功能，请把以下代码添加到URLconf中:

```
from django.contrib.sitemaps.views import sitemap

url(r'^sitemap\.xml$', sitemap, {'sitemaps': sitemaps},
    name='django.contrib.sitemaps.views.sitemap')
```

当用户访问`/sitemap.xml`时，Django将生成并返回一个网站地图。

网站地图的文件名并不重要，重要的是文件的位置。搜索引擎只会索引网站的当前URL层级及下属层级。例如，如果`sitemap.xml`位于根目录中，它会引用网站中的任何URL。 但是如果站点地图位于`/content/sitemap.xml`，则它只能引用以`/content/`开头的网址。

sitemap视图需要一个额外的必需参数： `{'sitemaps': sitemaps}`。`sitemaps`应是一个字典，将部门的标签（例如news或blog）映射到其 Sitemap类（例如，NewsSitemap或BlogSitemap）。也可以映射到Sitemap类的实例（例如，BlogSitemap(some_var)）。

## 三、范例

假设你有一个博客系统，拥有Entry模型，并且你希望站点地图包含指向每篇博客文章的所有链接。 以下是Sitemap类的写法：

```
from django.contrib.sitemaps import Sitemap
from blog.models import Entry

class BlogSitemap(Sitemap):
    changefreq = "never"
    priority = 0.5

    def items(self):
        return Entry.objects.filter(is_draft=False)

    def lastmod(self, obj):
        return obj.pub_date
```

注意：

- changefreq和priority分别对应于HTML页面中的`<changefreq>`和`<priority>`标签。
- items()只是一个返回对象列表的方法。
- lastmod方法应该返回一个datetime时间对象。
- 在此示例中没有编写location方法，但你可以自己增加此方法来指定对象的URL。默认情况下，location()在每个对象上调用`get_absolute_url()`并将返回结果作为对象的url。也就是说，使用站点地图的模型，比如Entry，需要在模型内部实现`get_absolute_url()`方法。

## 四、Sitemap类详解

class Sitemap[source]

Sitemap类可以定义以下方法/属性：

### 1. items[source]

必须定义。返回对象列表的方法。

框架不关心对象的类型，重要的是这些对象将被传递给location()，lastmod()，changefreq()和priority()方法。

### 2. location[source]

可选。 其值可以是一个方法或属性。

如果是一个方法, 它应该为items()返回的对象的绝对路径.

如果它是一个属性，它的值应该是一个字符串，表示items()返回的每个对象的绝对路径。

上面所说的“绝对路径”表示不包含协议和域名的URL。 例子：

```
正确：'/foo/bar/'
错误：'example.com/foo/bar/'
错误：'https://example.com/foo/bar/'
```

如果未提供location，框架将调用items()返回的每个对象上的`get_absolute_url()`方法。

该属性最终反映到HTML页面上的`<loc></loc>`标签。

### 3. lastmod

可选。 一个方法或属性。表示当前条目最后的修改时间。

### 4. changefreq

可选。 一个方法或属性。表示当前条目修改的频率。

changefreq的允许值为：

```
'always'
'hourly'
'daily'
'weekly'
'monthly'
'yearly'
'never'
```

### 5. priority

可选。表示当前条目在网站中的权重系数，优先级。

示例值：0.4，1.0。 页面的默认优先级为0.5，最高为1.0。

### 6. protocol

可选的。定义网站地图中的网址的协议（'http'或'https'）。

### 7. limit

可选的。定义网站地图的每个网页上包含的最大超级链接数。

### 8. i18n

可选的。一个boolean属性，定义是否应使用所有语言生成此网站地图。默认值为False。

## 五、快捷方式

sitemap框架提供了一个快捷类，帮助我们迅速生成网站地图：

```
class GenericSitemap[source]
```

通过它，我们无需为sitemap编写单独的视图模块，直接在URLCONF中，获取对象，获取参数，传递参数，设置url，如下所示，一条龙服务：

```
from django.conf.urls import url
from django.contrib.sitemaps import GenericSitemap
from django.contrib.sitemaps.views import sitemap
from blog.models import Entry

info_dict = {
    'queryset': Entry.objects.all(),
    'date_field': 'pub_date',
}

urlpatterns = [
    # some generic view using info_dict
    # ...

    # the sitemap
    url(r'^sitemap\.xml$', sitemap,
        {'sitemaps': {'blog': GenericSitemap(info_dict, priority=0.6)}},
        name='django.contrib.sitemaps.views.sitemap'),
]
```

## 六、静态视图的Sitemap

有时候，我们不希望在站点地图中出现一些静态页面，比如商品的详细信息页面。要怎么做呢？解决方案是在items中显式列出这些页面的网址名称，并在网站地图的location方法中调用reverse()。 像下面这样：

```
# sitemaps.py
from django.contrib import sitemaps
from django.urls import reverse

class StaticViewSitemap(sitemaps.Sitemap):
    priority = 0.5
    changefreq = 'daily'

    def items(self):
        return ['main', 'about', 'license']

    def location(self, item):
        return reverse(item)

# urls.py
from django.conf.urls import url
from django.contrib.sitemaps.views import sitemap

from .sitemaps import StaticViewSitemap
from . import views

sitemaps = {
    'static': StaticViewSitemap,
}

urlpatterns = [
    url(r'^$', views.main, name='main'),
    url(r'^about/$', views.about, name='about'),
    url(r'^license/$', views.license, name='license'),
    # ...
    url(r'^sitemap\.xml$', sitemap, {'sitemaps': sitemaps},
        name='django.contrib.sitemaps.views.sitemap')
]
```

上面做法的本质，是我先找出不想展示的页面，然后反向选择一下，获取想生成站点条目的对象，最后展示到站点地图中。你可以简单的理解为‘反选’。