memcached
什么是memcached：
memcached之前是danga的一个项目，最早是为LiveJournal服务的，当初设计师为了加速LiveJournal访问速度而开发的，后来被很多大型项目采用。官网是www.danga.com或者是memcached.org。
Memcached是一个高性能的分布式的内存对象缓存系统，全世界有不少公司采用这个缓存项目来构建大负载的网站，来分担数据库的压力。Memcached是通过在内存里维护一个统一的巨大的hash表，memcached能存储各种各样的数据，包括图像、视频、文件、以及数据库检索的结果等。简单的说就是将数据调用到内存中，然后从内存中读取，从而大大提高读取速度。
哪些情况下适合使用Memcached：存储验证码（图形验证码、短信验证码）、登录session等所有不是至关重要的数据。
安装和启动memcached：
windows：
安装：memcached.exe -d install。
启动：memcached.exe -d start。
linux（ubuntu）：

安装：sudo apt install memcached

启动：

cd /usr/local/memcached/bin
./memcached -d start
可能出现的问题：

提示你没有权限：在打开cmd的时候，右键使用管理员身份运行。
提示缺少pthreadGC2.dll文件：将pthreadGC2.dll文件拷贝到windows/System32.
不要放在含有中文的路径下面。
启动memcached：

-d：这个参数是让memcached在后台运行。
-m：指定占用多少内存。以M为单位，默认为64M。
-p：指定占用的端口。默认端口是11211。
-l：别的机器可以通过哪个ip地址连接到我这台服务器。如果是通过service memcached start的方式，那么只能通过本机连接。如果想要让别的机器连接，就必须设置-l 0.0.0.0。
如果想要使用以上参数来指定一些配置信息，那么不能使用service memcached start，而应该使用/usr/bin/memcached的方式来运行。比如/usr/bin/memcached -u memcache -m 1024 -p 11222 start。

telnet操作memcached：
telnet ip地址 [11211]

添加数据：

set：
语法：
  set key flas(是否压缩) timeout value_length
  value
示例：
  set username 0 60 7
  zhiliao
add：

语法：
  add key flas(0) timeout value_length
  value
示例：

  add username 0 60 7
  xiaotuo
set和add的区别：add是只负责添加数据，不会去修改数据。如果添加的数据的key已经存在了，则添加失败，如果添加的key不存在，则添加成功。而set不同，如果memcached中不存在相同的key，则进行添加，如果存在，则替换。

获取数据：

语法：
  get key
示例：
  get username
删除数据：

语法：
  delete key
示例：
  delete username
flush_all：删除memcached中的所有数据。
查看memcached的当前状态：

语法：stats。
通过python操作memcached：
安装：python-memcached：pip install python-memcached。
建立连接：

 import memcache
 mc = memcache.Client(['127.0.0.1:11211','192.168.174.130:11211'],debug=True)
设置数据：

 mc.set('username','hello world',time=60*5)
 mc.set_multi({'email':'xxx@qq.com','telphone':'111111'},time=60*5)
获取数据：

 mc.get('telphone')
删除数据：

 mc.delete('email')
自增长：

 mc.incr('read_count')
自减少：

 mc.decr('read_count')
memcached的安全性：
memcached的操作不需要任何用户名和密码，只需要知道memcached服务器的ip地址和端口号即可。因此memcached使用的时候尤其要注意他的安全性。这里提供两种安全的解决方案。分别来进行讲解：

使用-l参数设置为只有本地可以连接：这种方式，就只能通过本机才能连接，别的机器都不能访问，可以达到最好的安全性。
使用防火墙，关闭11211端口，外面也不能访问。
  ufw enable # 开启防火墙
  ufw disable # 关闭防火墙
  ufw default deny # 防火墙以禁止的方式打开，默认是关闭那些没有开启的端口
  ufw deny 端口号 # 关闭某个端口
  ufw allow 端口号 # 开启某个端口
在Django中使用memcached：
首先需要在settings.py中配置好缓存：

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
    }
}
如果想要使用多台机器，那么可以在LOCATION指定多个连接，示例代码如下：

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': [
            '172.19.26.240:11211',
            '172.19.26.242:11211',
        ]
    }
}
配置好memcached的缓存后，以后在代码中就可以使用以下代码来操作memcached了：

from django.core.cache import cache

def index(request):
    cache.set('abc','zhiliao',60)
    print(cache.get('abc'))
    response = HttpResponse('index')
    return response
需要注意的是，django在存储数据到memcached中的时候，不会将指定的key存储进去，而是会对key进行一些处理。比如会加一个前缀，会加一个版本号。如果想要自己加前缀，那么可以在settings.CACHES中添加KEY_FUNCTION参数：

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
        'KEY_FUNCTION': lambda key,prefix_key,version:"django:%s"%key
    }
}