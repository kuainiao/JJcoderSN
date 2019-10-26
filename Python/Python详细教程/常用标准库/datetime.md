# datetime

与time模块相比，datetime模块提供的接口更直观、易用，功能也更加强大。

导入方式： `import datetime`

datetime模块定义了以下几个类（**注意：这些类的对象都是不可变的！**）。

| 类名                   | 描述                                                         |
| ---------------------- | ------------------------------------------------------------ |
| **datetime.date**      | 日期类                                                       |
| **datetime.time**      | 时间类                                                       |
| **datetime.datetime**  | 日期与时间类                                                 |
| **datetime.timedelta** | 表示两个date、time、datetime实例之间的时间差                 |
| **datetime.tzinfo**    | 时区相关信息对象的抽象基类。                                 |
| **datetime.timezone**  | Python3.2中新增的功能，实现tzinfo抽象基类的类，表示与UTC的固定偏移量 |

使用datetime模块主要就是对其前四个类的操作。另外，datetime模块中还定义了两个常量：

**datetime.MINYEAR：**

datetime.date或datetime.datetime对象所允许的年份的最小值，该值为1。

**datetime.MAXYEAR：**

datetime.date或datetime.datetime对象所允许的年份的最大值，该值为9999。

## 一、datetime.date类

定义：`class datetime.date(year, month, day)`

datetime模块下的日期类，只能处理年月日这种日期时间，不能处理时分秒。

在构造datetime.date对象的时候需要传递下面的参数：

| 参数名称 | 取值范围                    |
| -------- | --------------------------- |
| year     | [MINYEAR, MAXYEAR]          |
| month    | [1, 12]                     |
| day      | [1, 指定年份的月份中的天数] |

主要属性和方法：

| 类方法/属性名称                 | 描述                                                         |
| ------------------------------- | ------------------------------------------------------------ |
| date.max                        | date对象所能表示的最大日期：9999-12-31                       |
| date.min                        | date对象所能表示的最小日期：00001-01-01                      |
| date.resoluation                | date对象表示的日期的最小单位：天                             |
| date.today()                    | 返回一个表示当前本地日期的date对象                           |
| date.fromtimestamp(timestamp)   | 根据给定的时间戳，返回一个date对象                           |
| d.year                          | 年                                                           |
| d.month                         | 月                                                           |
| d.day                           | 日                                                           |
| d.replace(year[, month[, day]]) | 生成并返回一个新的日期对象，原日期对象不变                   |
| d.timetuple()                   | 返回日期对应的time.struct_time对象                           |
| d.toordinal()                   | 返回日期是是自 0001-01-01 开始的第多少天                     |
| d.weekday()                     | 返回日期是星期几，[0, 6]，0表示星期一                        |
| d.isoweekday()                  | 返回日期是星期几，[1, 7], 1表示星期一                        |
| d.isocalendar()                 | 返回一个元组，格式为：(year, weekday, isoweekday)            |
| d.isoformat()                   | 返回‘YYYY-MM-DD’格式的日期字符串                             |
| d.strftime(format)              | 返回指定格式的日期字符串，与time模块的strftime(format, struct_time)功能相同 |

使用范例：

```
>>> import time
>>> from datetime import date
>>>
>>> date.max
>>> date.min
>>> date.resolution
>>> date.today()
>>> date.fromtimestamp(time.time())
>>> d = date.today()
>>> d.year
>>> d.month
>>> d.day
>>> d.replace(2018)
>>> d.replace(2018, 5)
>>> d.replace(2018, 5, 2)
>>> d.timetuple()
>>> d.toordinal()
>>> d.weekday()
>>> d.isoweekday()
>>> d.isocalendar()
>> d.isoformat()
>>> d.ctime()
>>> d.strftime('%Y/%m/%d')
```

## 二、 datetime.time类

定义：`class datetime.time(hour, [minute[, second, [microsecond[, tzinfo]]]])`

datetime模块下的时间类，只能处理时分秒。

在构造datetime.time对象的时候需要传递下面的参数：

| 参数名称    | 取值范围                             |
| ----------- | ------------------------------------ |
| hour        | [0, 23]                              |
| minute      | [0, 59]                              |
| second      | [0, 59]                              |
| microsecond | [0, 1000000]                         |
| tzinfo      | tzinfo的子类对象，如timezone类的实例 |

主要属性和方法：

| 类方法/属性名称                                              | 描述                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| time.max                                                     | time类所能表示的最大时间：time(23, 59, 59, 999999)           |
| time.min                                                     | time类所能表示的最小时间：time(0, 0, 0, 0)                   |
| time.resolution                                              | 时间的最小单位，即两个不同时间的最小差值：1微秒              |
| t.hour                                                       | 时                                                           |
| t.minute                                                     | 分                                                           |
| t.second                                                     | 秒                                                           |
| t.microsecond                                                | 微秒                                                         |
| t.tzinfo                                                     | 返回传递给time构造方法的tzinfo对象，如果该参数未给出，则返回None |
| t.replace(hour[, minute[, second[, microsecond[, tzinfo]]]]) | 生成并返回一个新的时间对象，原时间对象不变                   |
| t.isoformat()                                                | 返回一个‘HH:MM:SS.%f’格式的时间字符串                        |
| t.strftime()                                                 | 返回指定格式的时间字符串，与time模块的strftime(format, struct_time)功能相同 |

使用范例：

```
>>> from datetime import time
>>>
>>> time.max
datetime.time(23, 59, 59, 999999)
>>> time.min
datetime.time(0, 0)
>>> time.resolution
datetime.timedelta(0, 0, 1)
>>>
>>> t = time(12, 15, 40, 6666)
>>> t.hour
20
>>> t.minute
5
>>> t.second
40
>>> t.microsecond
8888
>>> t.replace(21)
>>> t.isoformat()
>>> t.strftime('%H%M%S')
>>> t.strftime('%H%M%S.%f')
```

## 三、 datetime.datetime类

定义：`class datetime.datetime(year, month, day, hour=0, minute=0, second=0, microsecond=0, tzinfo=None)`

一定要注意这是datetime模块下的datetime类，千万不要搞混了！

datetime模块下的日期时间类，你可以理解为datetime.time和datetime.date的组合类。

在构造datetime.datetime对象的时候需要传递下面的参数：

| 参数名称    | 取值范围                             |
| ----------- | ------------------------------------ |
| year        | [MINYEAR, MAXYEAR]                   |
| month       | [1, 12]                              |
| day         | [1, 指定年份的月份中的天数]          |
| hour        | [0, 23]                              |
| minute      | [0, 59]                              |
| second      | [0, 59]                              |
| microsecond | [0, 1000000]                         |
| tzinfo      | tzinfo的子类对象，如timezone类的实例 |

主要属性和方法：

| 类方法/属性名称                         | 描述                                                         |
| --------------------------------------- | ------------------------------------------------------------ |
| datetime.today()                        | 返回一个表示当前本期日期时间的datetime对象                   |
| datetime.now([tz])                      | 返回指定时区日期时间的datetime对象，如果不指定tz参数则结果同上 |
| datetime.utcnow()                       | 返回当前utc日期时间的datetime对象                            |
| datetime.fromtimestamp(timestamp[, tz]) | 根据指定的时间戳创建一个datetime对象                         |
| datetime.utcfromtimestamp(timestamp)    | 根据指定的时间戳创建一个datetime对象                         |
| datetime.combine(date, time)            | 把指定的date和time对象整合成一个datetime对象                 |
| datetime.strptime(date_str, format)     | 将时间字符串转换为datetime对象                               |
| dt.year, dt.month, dt.day               | 年、月、日                                                   |
| dt.hour, dt.minute, dt.second           | 时、分、秒                                                   |
| dt.microsecond, dt.tzinfo               | 微秒、时区信息                                               |
| dt.date()                               | 获取datetime对象对应的date对象                               |
| dt.time()                               | 获取datetime对象对应的time对象， tzinfo 为None               |
| dt.timetz()                             | 获取datetime对象对应的time对象，tzinfo与datetime对象的tzinfo相同 |
| dt.replace()                            | 生成并返回一个新的datetime对象，如果所有参数都没有指定，则返回一个与原datetime对象相同的对象 |
| dt.timetuple()                          | 返回datetime对象对应的tuple（不包括tzinfo）                  |
| dt.utctimetuple()                       | 返回datetime对象对应的utc时间的tuple（不包括tzinfo）         |
| dt.timestamp()                          | 返回datetime对象对应的时间戳，Python 3.3才新增的             |
| dt.toordinal()                          | 同date对象                                                   |
| dt.weekday()                            | 同date对象                                                   |
| dt.isocalendar()                        | 同date对象                                                   |
| dt.isoformat([sep])                     | 返回一个‘%Y-%m-%d’字符串                                     |
| dt.ctime()                              | 等价于time模块的time.ctime(time.mktime(d.timetuple()))       |
| dt.strftime(format)                     | 返回指定格式的时间字符串                                     |

使用范例：

```
>>> from datetime import datetime, timezone
>>> datetime.today()
>>> datetime.now()
>>> datetime.now(timezone.utc)
>>> datetime.utcnow()
>>> import time
>>> datetime.fromtimestamp(time.time())
>>> datetime.utcfromtimestamp(time.time())
>>> datetime.combine(date(2017, 5, 4), t)
>>> datetime.strptime('2017/05/04 10:23', '%Y/%m/%d %H:%M')
>>> dt = datetime.now()
>>> dt
>>> dt.year
>>> dt.month
>>> dt.day
>>> dt.hour
>>> dt.minute
>>> dt.second
>>> dt.timestamp()
>>> dt.date()
>>> dt.time()
>>> dt.timetz()
>>> dt.replace(2018)
>>> dt.timetuple()
>>> dt.utctimetuple()
>>> dt.toordinal()
>>> dt.weekday()
>>> dt.isocalendar()
>>> dt.isoformat()
>>> dt.isoformat(sep='/')
>>> dt.isoformat(sep=' ')
>>> dt.ctime()
>>> dt.strftime('%Y%m%d %H:%M:%S.%f')
```

## 四、 datetime.timedelta类

定义：`class datetime.timedelta(days=0, seconds=0, microseconds=0, milliseconds=0, hours=0, weeks=0)`

`timedelta`对象表示两个不同时间之间的差值。可以对`datetime.date`, `datetime.time`和`datetime.datetime`对象做算术运算。

主要属性和方法：

| 类方法/属性名称      | 描述                                                         |
| -------------------- | ------------------------------------------------------------ |
| timedelta.min        | timedelta(-999999999)                                        |
| timedelta.max        | timedelta(days=999999999, hours=23, minutes=59, seconds=59, microseconds=999999) |
| timedelta.resolution | timedelta(microseconds=1)                                    |
| td.days              | 天 [-999999999, 999999999]                                   |
| td.seconds           | 秒 [0, 86399]                                                |
| td.microseconds      | 微秒 [0, 999999]                                             |
| td.total_seconds()   | 时间差中包含的总秒数，等价于: td / timedelta(seconds=1)      |

使用范例：

```
>>> import datetime
>>>
>>> datetime.timedelta(365).total_seconds()     # 一年包含的总秒数
31536000.0
>>> dt = datetime.datetime.now()
>>> dt + datetime.timedelta(3)              # 3天后
datetime.datetime(2017, 5, 29, 11, 17, 18, 339791) 
>>> dt + datetime.timedelta(-3)             # 3天前
datetime.datetime(2017, 5, 23, 11, 17, 18, 339791) 
>>> dt + datetime.timedelta(hours=3)        # 3小时后
datetime.datetime(2017, 5, 26, 14, 17, 18, 339791) 
>>> dt + datetime.timedelta(hours=-3)       # 3小时前
datetime.datetime(2017, 5, 26, 8, 17, 18, 339791) 
>>> dt + datetime.timedelta(hours=3, seconds=30)   # 3小时30秒后  
datetime.datetime(2017, 5, 26, 14, 17, 48, 339791)
>>> dt2 = dt + datetime.timedelta(hours=10)
>>> dt2 -dt
datetime.timedelta(0, 36000)
>>> td = dt2 - dt
>>> td.seconds
36000
```