# django.objects 使用介绍

------

# Django objects.all()、objects.get()与objects.filter()之间的区别介绍

> 本文主要介绍的是关于Django objects.all()、objects.get()与objects.filter()直接区别的相关内容，文中介绍的非常详细，需要的朋友们下面来一起看看详细的介绍： 示例代码

```python
ret=UserInfo.objects.all()
```

**all返回的是QuerySet对象，程序并没有真的在数据库中执行SQL语句查询数据，但支持迭代，使用for循环可以获取数据.**

```python
ret=UserInfo.objects.get(id='1')
```

**get返回的是Model对象，类型为列表，说明使用get方法会直接执行sql语句获取数据.**

```python
ret=UserInfo.objects.filter()
```

**filter和get类似，但支持更强大的查询功能.**

## [#](http://www.liuwq.com/views/Django/django.objects.html#补充：)补充：

> 条件选取querySet的时候，filter表示=，exclude表示!=。

```python
querySet.distinct() 去重复  
__exact 精确等于 like ‘aaa’
__iexact 精确等于 忽略大小写 ilike ‘aaa’
__contains 包含 like ‘%aaa%’
__icontains 包含 忽略大小写 ilike ‘%aaa%’，但是对于sqlite来说，contains的作用效果等同于icontains。
__gt 大于
__gte 大于等于
__lt 小于
__lte 小于等于
__in 存在于一个list范围内
__startswith 以…开头
__istartswith 以…开头 忽略大小写
__endswith 以…结尾
__iendswith 以…结尾，忽略大小写
__range 在…范围内
__year 日期字段的年份
__month 日期字段的月份
__day 日期字段的日
__isnull=True/False
```