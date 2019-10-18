# Django时区详解

## 引言

相信使用Django的各位开发者在存储时间的时候经常会遇到这样子的错误:

```text
RuntimeWarning: DateTimeField received a naive datetime while time zone support is active. 
```

这个错误到底是什么意思呢？什么是naive datetime object？什么又是aware datetime object？

在Django配置中如果将settings.TIME_ZONE设置为中国时区（Asia/Shanghai），为什么以下时间函数会得到时间相差较大的结果？

```pytb
# settings.py

TIME_ZONE = 'Asia/Shanghai'



# python manage.py shell

>>> from datetime import datetime

>>> datetime.now()

datetime.datetime(2016, 12, 7, 12, 41, 22, 729326)

>>> from django.utils import timezone

>>> timezone.now()

datetime.datetime(2016, 12, 7, 4, 41, 36, 685921, tzinfo=<UTC>)
```

接下来笔者将详细揭秘在Django中关于时区的种种内幕，如有不对，敬请指教。



## 准备

**UTC与DST**

UTC可以视为一个世界统一的时间，以原子时为基础，其他时区的时间都是在这个基础上增加或减少的，比如中国的时区就为UTC＋8。

DST（夏时制）则是为了充分利用夏天日照长的特点，充分利用光照节约能源而人为调整时间的一种机制。通过在夏天将时间向前加一小时，使人们早睡早起节约能源。虽然很多西方国家都采用了DST，但是中国不采用DST。（资料来源：[DST（夏时制）_百度百科](https://link.zhihu.com/?target=http%3A//baike.baidu.com/item/DST/1203186)）

**naive datetime object vs aware datetime object**

当使用datetime.now()得到一个datetime对象的时候，此时该datetime对象没有任何关于时区的信息，即datetime对象的tzinfo属性为None(tzinfo属性被用于存储datetime object关于时区的信息)，该datetime对象就被称为naive datetime object。



```python
>>> import datetime

>>> naive = datetime.datetime.now()

>>> naive.tzinfo
```

既然naive datetime object没有关于时区的信息存储，相对的aware datetime object就是指存储了时区信息的datetime object。

在使用now函数的时候，可以指定时区，但该时区参数必须是datetime.tzinfo的子类。(tzinfo是一个抽象类，必须有一个具体的子类才能使用，笔者在这里使用了pytz.utc，在Django中的timezone源码中也实现了一个UTC类以防没有pytz库的时候timezone功能能正常使用)

```text
>>> import datetime

>>> import pytz

>>> aware = datetime.datetime.now(pytz.utc)

>>> aware

datetime.datetime(2016, 12, 7, 8, 32, 7, 864077, tzinfo=<UTC>)

>>> aware.tzinfo

<UTC>
```

在Django中提供了几个简单的函数如is_aware, is_naive, make_aware和make_naive用于辨别和转换naive datetime object和aware datetime object。

**datetime.now简析**

在调用datetime.now()的时候时间是如何返回的呢？在官方文档([8.1. datetime - Basic date and time types - Python 3.5.2 documentation](https://link.zhihu.com/?target=https%3A//docs.python.org/3/library/datetime.html))里只是简单地说明了now函数返回当前的具体时间，以及可以指定时区参数，并没有具体的说明now函数的实现。

> classmethod datetime.now(tz=None)
>
> Return the current local date and time. If optional argument tz is None or not specified, this is like today(), but, if possible, supplies more precision than can be gotten from going through a time.time() timestamp (for example, this may be possible on platforms supplying the C gettimeofday() function).
>
> If tz is not None, it must be an instance of a tzinfo subclass, and the current date and time are converted to tz’s time zone. In this case the result is equivalent to tz.fromutc(datetime.utcnow().replace(tzinfo=tz)). See also today(), utcnow().



OK，那么接下来直接从datetime.now()的源码入手吧。

```text
@classmethod

    def now(cls, tz=None):

        "Construct a datetime from time.time() and optional time zone info."

        t = _time.time()

        return cls.fromtimestamp(t, tz)
```

大家可以看到datetime.now函数通过time.time()返回了一个时间戳，然后调用了datetime.fromtimestamp()将一个时间戳转化成一个datetime对象。

那么，不同时区的时间戳会不会不一样呢？不，时间戳不会随着时区的改变而改变，时间戳是唯一的，被定义为格林威治时间1970年01月01日00时00分00秒(北京时间1970年01月01日08时00分00秒)起至现在的总秒数。关于时间戳与时间的关系可以参考这一则漫画：([程序员的日常：时间戳和时区的故事| 编程派 | Coding Python](https://link.zhihu.com/?target=http%3A//codingpy.com/article/programmer-daily-story-about-timestamp-and-timezone/))。

**datetime.fromtimestamp**

既然时间戳不会随时区改变，那么在fromtimestamp中应该对时间戳的转换做了时区的处理。

直接上源码：

```python
    @classmethod

    def _fromtimestamp(cls, t, utc, tz):

        """Construct a datetime from a POSIX timestamp (like time.time()).



        A timezone info object may be passed in as well.

        """

        frac, t = _math.modf(t)

        us = round(frac * 1e6)

        if us >= 1000000:

            t += 1

            us -= 1000000

        elif us < 0:

            t -= 1

            us += 1000000



        converter = _time.gmtime if utc else _time.localtime

        y, m, d, hh, mm, ss, weekday, jday, dst = converter(t)

        ss = min(ss, 59)    # clamp out leap seconds if the platform has them

        return cls(y, m, d, hh, mm, ss, us, tz)



    @classmethod

    def fromtimestamp(cls, t, tz=None):

        """Construct a datetime from a POSIX timestamp (like time.time()).



        A timezone info object may be passed in as well.

        """

        _check_tzinfo_arg(tz)



        result = cls._fromtimestamp(t, tz is not None, tz)

        if tz is not None:

            result = tz.fromutc(result)

        return result
```

当直接调用datetime.now()的时候，并没有传进tz的参数，因此_fromtimestamp中的utc参数为False，所以converter被赋值为time.localtime函数。



**time.localtime**

localtime函数的使用只需要知道它返回一个九元组表示当前的时区的具体时间即可：

```python
def localtime(seconds=None): # real signature unknown; restored from __doc__

    """

    localtime([seconds]) -> (tm_year,tm_mon,tm_mday,tm_hour,tm_min,

                              tm_sec,tm_wday,tm_yday,tm_isdst)

    

    Convert seconds since the Epoch to a time tuple expressing local time.

    When 'seconds' is not passed in, convert the current time instead.

    """

    pass
```

笔者觉得更需要注意的是什么因素影响了time.localtime返回的时区时间，那么，就需要谈及time.tzset函数了。

在Python官方文档中关于time.tzset函数解释如下：

> time.tzset()
>
> Resets the time conversion rules used by the library routines. The environment variable TZ specifies how this is done.
>
> Availability: Unix.
>
> Note Although in many cases, changing the TZ environment variable may affect the output of functions like localtime() without calling tzset(), this behavior should not be relied on.
>
> The TZ environment variable should contain no whitespace.



可以看到，一个名为TZ的环境变量的设置会影响localtime的时区时间的返回。（有兴趣的同学可以去在Unix下执行man tzset，就知道TZ变量是如何影响localtime了）

最后，笔者给出一些测试的例子，由于获取的时间戳不随时间改变，因此直接调用fromtimestamp即可：

```python
>>> from datetime import datetime

>>> from time import time, tzset

>>> china = datetime.fromtimestamp(time())

>>> import os

>>> os.environ['TZ'] = 'UTC'

>>> tzset()

>>> utc = datetime.fromtimestamp(time())

>>> china

datetime.datetime(2016, 12, 7, 16, 3, 34, 453664)

>>> utc

datetime.datetime(2016, 12, 7, 8, 4, 30, 108349)
```

以及直接调用localtime的例子：

```python
>>> from time import time, localtime, tzset

>>> import os

>>> china = localtime()

>>> china

time.struct_time(tm_year=2016, tm_mon=12, tm_mday=7, tm_hour=16, tm_min=7, tm_sec=5, tm_wday=2, tm_yday=342, tm_isdst=0)

>>> os.environ['TZ'] = 'UTC'

>>> tzset()

>>> utc = localtime()

>>> utc

time.struct_time(tm_year=2016, tm_mon=12, tm_mday=7, tm_hour=8, tm_min=7, tm_sec=34, tm_wday=2, tm_yday=342, tm_isdst=0)
```

（提前剧透：TZ这一个环境变量在Django的时区中发挥了重大的作用）



## Django TimeZone

**timezone.now() vs datetime.now()**

笔者在前面花费了大量的篇幅来讲datetime.now函数的原理，并且提及了TZ这一个环境变量，这是因为在Django导入settings的时候也设置了TZ环境变量。



当执行以下语句的时候：

```python
from django.conf import settings
```



毫无疑问，首先会访问django.conf.\__init__.py文件。

在这里settings是一个lazy object，但是这不是本章的重点，只需要知道当访问settings的时候，真正实例化的是以下这一个Settings类。

```python
class Settings(BaseSettings):

    def __init__(self, settings_module):

        # update this dict from global settings (but only for ALL_CAPS settings)

        for setting in dir(global_settings):

            if setting.isupper():

                setattr(self, setting, getattr(global_settings, setting))



        # store the settings module in case someone later cares

        self.SETTINGS_MODULE = settings_module



        mod = importlib.import_module(self.SETTINGS_MODULE)



        tuple_settings = (

            "INSTALLED_APPS",

            "TEMPLATE_DIRS",

            "LOCALE_PATHS",

        )

        self._explicit_settings = set()

        for setting in dir(mod):

            if setting.isupper():

                setting_value = getattr(mod, setting)



                if (setting in tuple_settings and

                        not isinstance(setting_value, (list, tuple))):

                    raise ImproperlyConfigured("The %s setting must be a list or a tuple. " % setting)

                setattr(self, setting, setting_value)

                self._explicit_settings.add(setting)



        if not self.SECRET_KEY:

            raise ImproperlyConfigured("The SECRET_KEY setting must not be empty.")



        if hasattr(time, 'tzset') and self.TIME_ZONE:

            # When we can, attempt to validate the timezone. If we can't find

            # this file, no check happens and it's harmless.

            zoneinfo_root = '/usr/share/zoneinfo'

            if (os.path.exists(zoneinfo_root) and not

                    os.path.exists(os.path.join(zoneinfo_root, *(self.TIME_ZONE.split('/'))))):

                raise ValueError("Incorrect timezone setting: %s" % self.TIME_ZONE)

            # Move the time zone info into os.environ. See ticket #2315 for why

            # we don't do this unconditionally (breaks Windows).

            os.environ['TZ'] = self.TIME_ZONE

            time.tzset()



    def is_overridden(self, setting):

        return setting in self._explicit_settings



    def __repr__(self):

        return '<%(cls)s "%(settings_module)s">' % {

            'cls': self.__class__.__name__,

            'settings_module': self.SETTINGS_MODULE,

        }
```



在该类的初始化函数的最后，可以看到当USE_TZ=True的时候（即开启Django的时区功能），设置了TZ变量为settings.TIME_ZONE。

OK，知道了TZ变量被设置为TIME_ZONE之后，就能解释一些很奇怪的事情了。

比如，新建一个Django项目，保留默认的时区设置，并启动django shell：

```python
# settings.py

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True



# python3 manage.py shell

>>> import datetime

>>> datetime.datetime.now()

datetime.datetime(2016, 12, 7, 9, 19, 34, 741124)

>>> datetime.datetime.utcnow()

datetime.datetime(2016, 12, 7, 9, 19, 45, 753843)
```

默认的Python Shell通过datetime.now返回的应该是当地时间，在这里即中国时区，但是当settings.TIME_ZONE设置为UTC的时候，通过datetime.now返回的就是UTC时间。



可以试试将TIME_ZONE设置成中国时区：

```python
# settings.py

TIME_ZONE = 'Asia/Shanghai'



# python3 manage.py shell

>>> import datetime

>>> datetime.datetime.now()

datetime.datetime(2016, 12, 7, 17, 22, 21, 172761)

>>> datetime.datetime.utcnow()

datetime.datetime(2016, 12, 7, 9, 22, 26, 373080)
```

此时datetime.now返回的就是中国时区了。



当使用timezone.now函数的时候，情况则不一样，在支持时区功能的时候，该函数返回的是一个带有UTC时区信息的aware datetime obeject，即它不受TIME_ZONE变量的影响。

直接看它的源码实现：

```python
def now():

    """

    Returns an aware or naive datetime.datetime, depending on settings.USE_TZ.

    """

    if settings.USE_TZ:

        # timeit shows that datetime.now(tz=utc) is 24% slower

        return datetime.utcnow().replace(tzinfo=utc)

    else:

        return datetime.now()
```

不支持时区功能，就返回一个受TIME_ZONE影响的naive datetime object。



**实践场景**

假设现在有这样一个场景，前端通过固定格式提交一个时间字符串供后端的form验证，后端解析得到datetime object之后再通过django orm存储到DatetimeField里面。

**Form.DateTimeField**

在django关于timezone的官方文档中，已经说明了经过form.DatetimeField返回的在cleaned_data中的时间都是**当前时区**的**aware datetime object**。

> Time zone aware input in forms
>
> When you enable time zone support, Django interprets datetimes entered in forms in the current time zone and returns aware datetime objects in cleaned_data.
>
> If the current time zone raises an exception for datetimes that don’t exist or are ambiguous because they fall in a DST transition (the timezones provided by pytz do this), such datetimes will be reported as invalid values.

**Models.DatetimeField**

在存储时间到MySQL的时候，首先需要知道在Models里面的DatetimeField通过ORM映射到MySQL的时候是什么类型。

笔者首先建立了一个Model作为测试：

```text
# models.py

class Time(models.Model):



    now = models.DateTimeField()

    

# MySQL Tables Schema

+-------+-------------+------+-----+---------+----------------+

| Field | Type        | Null | Key | Default | Extra          |

+-------+-------------+------+-----+---------+----------------+

| id    | int(11)     | NO   | PRI | NULL    | auto_increment |

| now   | datetime(6) | NO   |     | NULL    |                |

+-------+-------------+------+-----+---------+----------------+
```

可以看到，在MySQL中是通过datetime类型存储Django ORM中的DateTimeField类型，其中datetime类型是不受MySQL的时区设置影响，与timestamp类型不同。

关于datetime和timestamp类型可以参考这篇文章([关于“时间”的一次探索 - 前端涨姿势 - SegmentFault](https://link.zhihu.com/?target=https%3A//segmentfault.com/a/1190000004292140))。

因此，如果笔者关闭了时区功能，却向MySQL中存储了一个aware datetime object，就会得到以下报错：

```python
ValueError: MySQL backend does not support timezone-aware datetimes.
```



## 关于对时区在业务开发中的一些看法

后端应该在数据库统一存储UTC时间并返回UTC时间给前端，前端在发送时间和接收时间的时候要把时间分别从当前时区转换成UTC发送给后端，以及接收后端的UTC时间转换成当地时区。