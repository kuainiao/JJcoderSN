# Django与缓存

阅读: 8347     [评论](http://www.liujiangblog.com/course/django/177#comments)：2

我们都知道Django建立的是动态网站，正常情况下，每次请求过来都经历了这样一个过程：

```
接收请求 -> url路由 -> 视图处理 -> 数据库读写 -> 视图处理 -> 模版渲染 -> 返回请求
```

设想这么个场景，一个用户或者大量用户都对某个页面非常感兴趣，出现了大量实质相同的请求，如果每次请求都采取上面的流程，将出现大量的重复工作，尤其是大量无谓的数据库读写。

要解决这个问题，有很多办法，其中一个就是使用缓存。

缓存的思路是，既然已经处理过一次，得到了结果，就把当前结果缓存下来。下次再请求时，把缓存的处理结果直接返回。这样，可以极大地减少重复工作，降低数据库负载。

下面是缓存思路的伪代码：

```
给定一个URL， 试图在缓存中查询对应的页面

如果缓存中有该页面：
    返回这个缓存的页面
否则：
    生成页面
    将生成的页面保存到缓存中（用作以后）
    返回这个生成的页面
```

以Django一站式服务的尿性，像缓存这么重要的功能，怎么可能不具备？当然是必带的了！

Django提供不同粒度不同层级的缓存：你可以缓存指定的页面、难以生成的部分或者整个站点。

Django也能很好的配合那些“下游”缓存, 比如Squid和基于浏览器的缓存。

## 一、设置缓存

Django支持基于数据库的、文件的和内存的缓存。通常我们首先要对其进行设置。Django关于缓存的设置都位于settings.py中的CACHES配置项中。

Django支持下面几种缓存系统：

### 1. Memcached

Memcached是Django原生支持的缓存系统，速度快，效率高。Memcached是一种基于内存的缓存服务，起初是为了解决LiveJournal.com的负载问题而开发的，后来由Danga开源。 它被类似Facebook和维基百科这种大型网站使用，用来减少数据库访问次数，显著地提高了网站的性能。

Memcached会启动一个守护进程，并分配单独的内存块。其主要工作就是为缓存提供一个快速的添加，检索，删除的接口。所有的数据直接存储在内存中，所以它不能取代数据库或者文件系统的功能。如果你对缓存很熟悉，这些内容都很好理解。

如果你是新手，那么要清楚：

- Memcached不是Django自带的软件，而是一个独立的软件，需要你自己安装、配置和启动服务；
- Memcached安装好了后，还要安装Python操作Memcached的依赖库，最常用的是python-memcached和pylibmc；
- 上面两个条件都满足了后，还要在Django中进行配置。

**配置方法：**

- 根据你安装的Python依赖库不同，将CACHES的BACKEND设置为django.core.cache.backends.memcached.MemcachedCache或者django.core.cache.backends.memcached.PyLibMCCache
- 设置LOCATION为你的Memecached守护进程所在的主机IP和进程端口，格式为ip:port的字符串。或者unix:path的形式，在Unix操作系统中。

下面是一个参考例子，Memcached运行在`localhost (127.0.0.1) port 11211`，使用了`python-memcached`库：

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
    }
}
```

下面的Memcached运行在本地的Unix socket上：`/tmp/memcached.sock`，依赖`python-memcached`：

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': 'unix:/tmp/memcached.sock',
    }
}
```

下面的Memcached运行在`/tmp/memcached.sock`，不带`unix:/`前缀，依赖pylibmc库：

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.PyLibMCCache',
        'LOCATION': '/tmp/memcached.sock',
    }
}
```

Memcached支持分布式服务，可能同时在几台机器上运行，将它们的IP地址都加入到LOCATION中，如下所示：

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': [
            '172.19.26.240:11211',
            '172.19.26.242:21423',
            '172.19.26.244:11213',
        ]
    }
}
```

基于内存的缓存系统有个明显的缺点就是断电数据丢失，尤其是Memcached这种不支持序列化的缓存，所以请大家务必要注意数据的安全性。

其实对于当下，redis如日中天的时代，还是选择redis作为缓存吧，还支持序列化。

### 2. 数据库缓存

我们使用缓存的很大原因就是要减少数据库的操作，如果将缓存又存到数据库，岂不是脱....

所以，尽量不要使用基于数据库的缓存，这里也不做具体介绍，给个简单的配置范例吧：

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.db.DatabaseCache',
        'LOCATION': 'my_cache_table',
    }
}
```

但是在某些情况下，还是有一些用途的，比如你有一个高速、高效索引的数据库。

### 3. 文件系统缓存

连数据库我们都觉得慢，那么基于文件系统的呢？更慢！不过在你手里没有Redis、Memcached和数据库的时候，也可以勉为其难的用一下。下面给出两个配置案例：

基于Unix系统：

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
        'LOCATION': '/var/tmp/django_cache',
    }
}
```

基于Windows操作系统，需要带盘符路径：

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
        'LOCATION': 'c:/foo/bar',
    }
}
```

### 4. 基于本地内存的缓存

如果你的本地主机内存够大够快，也可以直接使用它作为缓存。配置如下：

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake',
    }
}
```

### 5. 开发用的缓存

Django很贴心的为我们设计了一个开发用的缓存。当你的生产环境是个大型的缓存系统，而你在开发的时候又没有相应的缓存系统支持，或者不想用那种笨重的大家伙进行开发。但实际开发过程中，你又不得不接入缓存系统，使用缓存的api，这种情况下，开发用的缓存就很顺手了。

配置如下：

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.dummy.DummyCache',
    }
}
```

### 6. 自定义缓存后端

最高境界当然是使用自己开发的缓存系统了，Django是支持的，但前提是你要有那能力！配置很简单：

```
CACHES = {
    'default': {
        'BACKEND': 'path.to.backend',
    }
}
```

### 7. 缓存参数

上述每一个缓存后端都可以设置一些额外的参数来控制缓存行为，可以设置的参数如下：

- TIMEOUT

缓存的默认过期时间，以秒为单位，默认是300秒None表示永远不会过期。设置成0将造成缓存立即失效(缓存就没有意义了)。

- OPTIONS

可选参数，根据缓存后端的不同而不同。

- KEY_PREFIX

Django服务器使用的所有缓存键的字符串。

- VERSION

由Django服务器生成的默认版本号。

- KEY_FUNCTION

一个字符串，其中包含一个函数的点路径，该函数定义了如何将前缀，版本和密钥组合成最终缓存密钥。

下面例子中配置了一个基于文件系统的缓存后端，缓存过期时间被设置为60秒，最大条目为1000.

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
        'LOCATION': '/var/tmp/django_cache',
        'TIMEOUT': 60,
        'OPTIONS': {
            'MAX_ENTRIES': 1000
        }
    }
}
```

以下示例配置了一个基于python-memcached库的后端，其对象大小限制为2MB：

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
        'OPTIONS': {
            'server_max_value_length': 1024 * 1024 * 2,
        }
    }
}
```

以下是基于pylibmc库的后端配置，该后端启用二进制协议、SASL认证和ketama行为模式：

```
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.PyLibMCCache',
        'LOCATION': '127.0.0.1:11211',
        'OPTIONS': {
            'binary': True,
            'username': 'user',
            'password': 'pass',
            'behaviors': {
                'ketama': True,
            }
        }
    }
}
```

## 二、缓存全站

缓存系统最简单的使用方法是缓存整个网站。

这需要额外将'django.middleware.cache.UpdateCacheMiddleware'和'django.middleware.cache.FetchFromCacheMiddleware'添加到MIDDLEWARE设置中，如下所示：

```
MIDDLEWARE = [
    'django.middleware.cache.UpdateCacheMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.cache.FetchFromCacheMiddleware',
]
```

注意： `update`中间件必须放在列表的开始位置，而`fectch`中间件，必须放在最后。 这是Django使用中间件的规则，它们是有顺序关系的。

然后，添加下面这些需要的参数到settings文件里:

```
CACHE_MIDDLEWARE_ALIAS : 用于存储的缓存的别名
CACHE_MIDDLEWARE_SECONDS : 每个page需要被缓存多少秒.
CACHE_MIDDLEWARE_KEY_PREFIX : 密钥前缀
```

## 三、缓存视图

另一个使用缓存框架的方法是对视图的输出进行缓存。在django.views.decorators.cache定义了一个自动缓存视图响应结果的装饰器`cache_page`，使用非常简单:

```
from django.views.decorators.cache import cache_page

@cache_page(60 * 15)
def my_view(request):
    ...
```

`cache_page`接受一个参数：timeout，秒为单位。在上例中，`my_view()`视图的结果将被缓存15分钟(为了提高可读性写成了60 * 15)

和站点缓存一样，视图缓存与URL无关。如果多个URL指向同一视图，每个URL将会分别缓存。 继续my_view的例子，如果URLconf如下所示：

```
urlpatterns = [
    url(r'^foo/([0-9]{1,2})/$', my_view),
]
```

那么发送到`/foo/23/`和`/foo/1/`的请求会被分别缓存。但是一旦一个明确的URL(例如`/foo/23/`) 已经被请求过了， 之后再度发出的指向该URL的请求将使用缓存的内容。

`cache_page`装his起也可以使用一些额外的参数，比如cache，这个参数指示具体使用的缓存后端。

```
@cache_page(60 * 15, cache="special_cache")
def my_view(request):
    ...
```

还可以采用可选的关键字参数`key_prefix`在每个视图中指定具体的缓存前缀，如下所示：

```
@cache_page(60 * 15, key_prefix="site1")
def my_view(request):
    ...
```

## 四、缓存模板片段

我们还可以使用`cache`模板标签来缓存模板的一个片段。要使用这个标签，首先要在模版的顶部位置添加`{% load cache %}`。

模板标签`{% cache %}`将在设定的时间内，缓存标签块中包含的内容。它最少需要两个参数：缓存时间（以秒为单位）以及给缓存片段起的名称。像这样：

```
{% load cache %}
{% cache 500 sidebar %}
    .. sidebar ..
{% endcache %}
```

还可以依据片段内的动态内容缓存多个版本。如上个例子中，可以给站点的每个用户生成不同版本的sidebar缓存。 只需要给`{% cache %}`标签再传递一个参数来标识区分这个缓存片段，如下所示：

```
{% load cache %}
{% cache 500 sidebar request.user.username %}
    .. sidebar for logged in user ..
{% endcache %}
```

缓存超时参数可以是个模板变量，只要模板变量可以解析为整数值即可。例如，如果模板变量my_timeout设置为值600，则以下两个示例是等效的：

```
{% cache 600 sidebar %} ... {% endcache %}
{% cache my_timeout sidebar %} ... {% endcache %}
```