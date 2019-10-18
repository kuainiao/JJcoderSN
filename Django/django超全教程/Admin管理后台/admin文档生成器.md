

# Admin文档生成器

阅读: 8992     [评论](http://www.liujiangblog.com/course/django/160#comments)：0

Django的admindocs应用可以从模型、视图、模板标签等地方获得文档内容。

## 一、概览

要激活admindocs，请按下面的步骤操作：

- 在`INSTALLED_APPS`内添加`django.contrib.admindocs`
- 在`urlpatterns`内添加`url(r'^admin/doc/',include('django.contrib.admindocs.urls'))`。确保它处于`r'^admin/'`条目之前，原因你懂的。
- 安装Python的docutils模块(http://docutils.sf.net/)(pip3 install docutils)
- 可选：想使用admindocs的书签小工具，需要安装django.contrib.admindocs.middleware.XViewMiddleware。

如果上述步骤顺利完成，那么你可以从admin界面访问doc界面，也可以直接访问`/admin/doc`，如下图：

![22.png-12.2kB](http://static.zybuluo.com/feixuelove1009/vczgdhubo4rqbh5wndc85kw2/22.png)

它看起来是下面的样子：

![23.png-109.9kB](http://static.zybuluo.com/feixuelove1009/5elmdqpzsajnu9lklcg2sdck/23.png)

下面的这些特殊标记，可帮助你在文档字符串中，快速创建指向其它组件的链接：

![2.jpg-27.2kB](http://static.zybuluo.com/feixuelove1009/95gi5xwftlmomj6yziu2lv6r/2.jpg)

## 二、模型

在doc页面的模型部分，列出了所有的模型，点击可以查看具体的字段等细节信息。信息主要来自字段的`help_txt`部分和模型方法的`docstring`部分。如下面图中展示：

有用的帮助信息看起来是这个样子的：

```
class BlogEntry(models.Model):
    """
    Stores a single blog entry, related to :model:`blog.Blog` and
    :model:`auth.User`.
    """
    slug = models.SlugField(help_text="A short label, generally used in URLs.")
    author = models.ForeignKey(
        User,
        models.SET_NULL,
        blank=True, null=True,
    )
    blog = models.ForeignKey(Blog, models.CASCADE)
    ...

    def publish(self):
        """Makes the blog entry live on the site."""
        ...
```

![24.png-104.9kB](http://static.zybuluo.com/feixuelove1009/ajygzgpvd8ytwtp4wz2vlsqa/24.png)

![25.png-117.8kB](http://static.zybuluo.com/feixuelove1009/lf8m9raw5hmunkh9akf2qldc/25.png)

## 三、视图

站点内的每个URL都会在doc内享有一个页面，点击某个URL将会展示对应的视图信息。主要包括下面这些信息，请尽量丰富它们：

- 视图功能的简单描述
- 上下文环境，或者视图模块里的变量列表
- 视图内使用的模板

例如：

```
from django.shortcuts import render

from myapp.models import MyModel

def my_view(request, slug):
    """
    Display an individual :model:`myapp.MyModel`.

    **Context**

    ``mymodel``
        An instance of :model:`myapp.MyModel`.

    **Template:**

    :template:`myapp/my_template.html`
    """
    context = {'mymodel': MyModel.objects.get(slug=slug)}
    return render(request, 'myapp/my_template.html', context)
```

![26.png-132.3kB](http://static.zybuluo.com/feixuelove1009/hecy9ddfg73lkrty76sjp93g/26.png)

## 四、模板标签和过滤器

所有Django内置的或者你自定义的或者第三方app提供的标签和过滤器都将在页面内展示：

![27.png-133.1kB](http://static.zybuluo.com/feixuelove1009/4s0gcqgkm5lq3xa8ce00u4fm/27.png)

![28.png-140.4kB](http://static.zybuluo.com/feixuelove1009/yblibbj3wrxekjumd7sbd2lq/28.png)