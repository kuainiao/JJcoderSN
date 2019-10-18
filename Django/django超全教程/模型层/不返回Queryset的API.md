# 不返回QuerySets的API

阅读: 16495     [评论](http://www.liujiangblog.com/course/django/131#comments)：7

以下的方法不会返回QuerySets，但是作用非常强大，尤其是粗体显示的方法，需要背下来。

| 方法名                 | 解释                             |
| ---------------------- | -------------------------------- |
| **get()**              | 获取单个对象                     |
| **create()**           | 创建对象，无需save()             |
| **get_or_create()**    | 查询对象，如果没有找到就新建对象 |
| **update_or_create()** | 更新对象，如果没有找到就创建对象 |
| `bulk_create()`        | 批量创建对象                     |
| **count()**            | 统计对象的个数                   |
| `in_bulk()`            | 根据主键值的列表，批量返回对象   |
| `iterator()`           | 获取包含对象的迭代器             |
| **latest()**           | 获取最近的对象                   |
| **earliest()**         | 获取最早的对象                   |
| **first()**            | 获取第一个对象                   |
| **last()**             | 获取最后一个对象                 |
| **aggregate()**        | 聚合操作                         |
| **exists()**           | 判断queryset中是否有对象         |
| **update()**           | 批量更新对象                     |
| **delete()**           | 批量删除对象                     |
| as_manager()           | 获取管理器                       |

## 1. get()

get(**kwargs)

返回按照查询参数匹配到的单个对象，参数的格式应该符合Field lookups的要求。

如果匹配到的对象个数不只一个的话，触发MultipleObjectsReturned异常

如果根据给出的参数匹配不到对象的话，触发DoesNotExist异常。例如：

```
Entry.objects.get(id='foo') # raises Entry.DoesNotExist
```

DoesNotExist异常从`django.core.exceptions.ObjectDoesNotExist`继承，可以定位多个DoesNotExist异常。 例如：

```
from django.core.exceptions import ObjectDoesNotExist
try:
    e = Entry.objects.get(id=3)
    b = Blog.objects.get(id=1)
except ObjectDoesNotExist:
    print("Either the entry or blog doesn't exist.")
```

如果希望查询器只返回一行，则可以使用get()而不使用任何参数来返回该行的对象：

```
entry = Entry.objects.filter(...).exclude(...).get()
```

## 2. create()

create(**kwargs)

在一步操作中同时创建并且保存对象的便捷方法.

```
p = Person.objects.create(first_name="Bruce", last_name="Springsteen")
```

等于:

```
p = Person(first_name="Bruce", last_name="Springsteen")
p.save(force_insert=True)
```

参数`force_insert`表示强制创建对象。如果model中有一个你手动设置的主键，并且这个值已经存在于数据库中, 调用create()将会失败并且触发IntegrityError因为主键必须是唯一的。如果你手动设置了主键，做好异常处理的准备。

## 3. get_or_create()

get_or_create(defaults=None, **kwargs)

**通过kwargs来查询对象的便捷方法（如果模型中的所有字段都有默认值，可以为空），如果该对象不存在则创建一个新对象**。

该方法**返回一个由(object, created)组成的元组**，元组中的object 是一个查询到的或者是被创建的对象， created是一个表示是否创建了新的对象的布尔值。

对于下面的代码：

```
try:
    obj = Person.objects.get(first_name='John', last_name='Lennon')
except Person.DoesNotExist:
    obj = Person(first_name='John', last_name='Lennon', birthday=date(1940, 10, 9))
    obj.save()
```

如果模型的字段数量较大的话，这种模式就变的非常不易用了。 上面的示例可以用`get_or_create()`重写 :

```
obj, created = Person.objects.get_or_create(
    first_name='John',
    last_name='Lennon',
    defaults={'birthday': date(1940, 10, 9)},
)
```

任何传递给`get_or_create()`的关键字参数，除了一个可选的defaults，都将传递给get()调用。 如果查找到一个对象，返回一个包含匹配到的对象以及False 组成的元组。 如果查找到的对象超过一个以上，将引发MultipleObjectsReturned。如果查找不到对象，`get_or_create()`将会实例化并保存一个新的对象，返回一个由新的对象以及True组成的元组。新的对象将会按照以下的逻辑创建:

```
params = {k: v for k, v in kwargs.items() if '__' not in k}
params.update({k: v() if callable(v) else v for k, v in defaults.items()})
obj = self.model(**params)
obj.save()
```

它表示从非'defaults' 且不包含双下划线的关键字参数开始。然后将defaults的内容添加进来，覆盖必要的键，并使用结果作为关键字参数传递给模型类。

如果有一个名为`defaults__exact`的字段，并且想在`get_or_create()`时用它作为精确查询，只需要使用defaults，像这样：

```
Foo.objects.get_or_create(defaults__exact='bar', defaults={'defaults': 'baz'})
```

当你使用手动指定的主键时，`get_or_create()`方法与`create()`方法有相似的错误行为 。 如果需要创建一个对象而该对象的主键早已存在于数据库中，IntegrityError异常将会被触发。

这个方法假设进行的是原子操作，并且正确地配置了数据库和正确的底层数据库行为。如果数据库级别没有对`get_or_create`中用到的kwargs强制要求唯一性（unique和unique_together），方法容易导致竞态条件，可能会有相同参数的多行同时插入。（简单理解，kwargs必须指定的是主键或者unique属性的字段才安全。）

最后建议只在Django视图的POST请求中使用get_or_create()，因为这是一个具有修改性质的动作，不应该使用在GET请求中，那样不安全。

可以通过ManyToManyField属性和反向关联使用`get_or_create()`。在这种情况下，应该限制查询在关联的上下文内部。 否则，可能导致完整性问题。

例如下面的模型：

```
class Chapter(models.Model):
    title = models.CharField(max_length=255, unique=True)

class Book(models.Model):
    title = models.CharField(max_length=256)
    chapters = models.ManyToManyField(Chapter)
```

可以通过Book的chapters字段使用`get_or_create()`，但是它只会获取该Book内部的上下文：

```
>>> book = Book.objects.create(title="Ulysses")
>>> book.chapters.get_or_create(title="Telemachus")
(<Chapter: Telemachus>, True)
>>> book.chapters.get_or_create(title="Telemachus")
(<Chapter: Telemachus>, False)
>>> Chapter.objects.create(title="Chapter 1")
<Chapter: Chapter 1>
>>> book.chapters.get_or_create(title="Chapter 1")
# Raises IntegrityError
```

发生这个错误是因为尝试通过Book “Ulysses”获取或者创建“Chapter 1”，但是它不能，因为它与这个book不关联，但因为title 字段是唯一的它仍然不能创建。

在Django1.11在defaults中增加了对可调用值的支持。

## 4. update_or_create()

update_or_create(defaults=None, **kwargs)

类似前面的`get_or_create()`。

**通过给出的kwargs来更新对象的便捷方法， 如果没找到对象，则创建一个新的对象**。defaults是一个由 (field, value)对组成的字典，用于更新对象。defaults中的值可以是可调用对象（也就是说函数等）。

该方法返回一个由(object, created)组成的元组,元组中的object是一个创建的或者是被更新的对象， created是一个标示是否创建了新的对象的布尔值。

`update_or_create`方法尝试通过给出的kwargs 去从数据库中获取匹配的对象。 如果找到匹配的对象，它将会依据defaults 字典给出的值更新字段。

像下面的代码：

```
defaults = {'first_name': 'Bob'}
try:
    obj = Person.objects.get(first_name='John', last_name='Lennon')
    for key, value in defaults.items():
        setattr(obj, key, value)
    obj.save()
except Person.DoesNotExist:
    new_values = {'first_name': 'John', 'last_name': 'Lennon'}
    new_values.update(defaults)
    obj = Person(**new_values)
    obj.save()
```

如果模型的字段数量较大的话，这种模式就变的非常不易用了。 上面的示例可以用`update_or_create()` 重写:

```
obj, created = Person.objects.update_or_create(
    first_name='John', last_name='Lennon',
    defaults={'first_name': 'Bob'},
)
```

kwargs中的名称如何解析的详细描述可以参见`get_or_create()`。

和`get_or_create()`一样，这个方法也容易导致竞态条件，如果数据库层级没有前置唯一性会让多行同时插入。

在Django1.11在defaults中增加了对可调用值的支持。

## 5. bulk_create()

bulk_create(objs, batch_size=None)

以高效的方式（通常只有1个查询，无论有多少对象）将提供的对象列表插入到数据库中：

```
>>> Entry.objects.bulk_create([
...     Entry(headline='This is a test'),
...     Entry(headline='This is only a test'),
... ])
```

注意事项：

- 不会调用模型的save()方法，并且不会发送`pre_save`和`post_save`信号。
- 不适用于多表继承场景中的子模型。
- 如果模型的主键是AutoField，则不会像save()那样检索并设置主键属性，除非数据库后端支持。
- 不适用于多对多关系。

`batch_size`参数控制在单个查询中创建的对象数。

## 6. count()

count()

返回在数据库中对应的QuerySet对象的个数。count()永远不会引发异常。

例如：

```
# 返回总个数.
Entry.objects.count()
# 返回包含有'Lennon'的对象的总数
Entry.objects.filter(headline__contains='Lennon').count()
```

## 7. in_bulk()

in_bulk(id_list=None)

获取主键值的列表，并返回将每个主键值映射到具有给定ID的对象的实例的字典。 如果未提供列表，则会返回查询集中的所有对象。

例如：

```
>>> Blog.objects.in_bulk([1])
{1: <Blog: Beatles Blog>}
>>> Blog.objects.in_bulk([1, 2])
{1: <Blog: Beatles Blog>, 2: <Blog: Cheddar Talk>}
>>> Blog.objects.in_bulk([])
{}
>>> Blog.objects.in_bulk()
{1: <Blog: Beatles Blog>, 2: <Blog: Cheddar Talk>, 3: <Blog: Django Weblog>}
```

如果向`in_bulk()`传递一个空列表，会得到一个空的字典。

在旧版本中，`id_list`是必需的参数，现在是一个可选参数。

## 8. iterator()

iterator()

提交数据库操作，获取QuerySet，并返回一个迭代器。

QuerySet通常会在内部缓存其结果，以便在重复计算时不会导致额外的查询。而iterator()将直接读取结果，不在QuerySet级别执行任何缓存。对于返回大量只需要访问一次的对象的QuerySet，这可以带来更好的性能，显著减少内存使用。

请注意，在已经提交了的iterator()上使用QuerySet会强制它再次提交数据库操作，进行重复查询。此外，使用iterator()会导致先前的`prefetch_related()`调用被忽略，因为这两个一起优化没有意义。

## 9. latest()

latest(field_name=None)

使用日期字段field_name，按日期返回最新对象。

下例根据Entry的'pub_date'字段返回最新发布的entry：

```
Entry.objects.latest('pub_date')
```

如果模型的Meta指定了`get_latest_by`，则可以将latest()参数留给earliest()或者`field_name`。 默认情况下，Django将使用`get_latest_by`中指定的字段。

earliest()和latest()可能会返回空日期的实例,可能需要过滤掉空值：

```
Entry.objects.filter(pub_date__isnull=False).latest('pub_date')
```

## 10. earliest()

earliest(field_name=None)

类同latest()。

## 11. first()

first()

返回结果集的第一个对象, 当没有找到时返回None。如果QuerySet没有设置排序,则将会自动按主键进行排序。例如：

```
p = Article.objects.order_by('title', 'pub_date').first()
```

first()是一个简便方法，下面的例子和上面的代码效果是一样：

```
try:
    p = Article.objects.order_by('title', 'pub_date')[0]
except IndexError:
    p = None
```

## 12. last()

last()

工作方式类似first()，只是返回的是查询集中最后一个对象。

## 13. aggregate()

aggregate(*args,* *kwargs)

返回汇总值的字典（平均值，总和等）,通过QuerySet进行计算。每个参数指定返回的字典中将要包含的值。

使用关键字参数指定的聚合将使用关键字参数的名称作为Annotation 的名称。 匿名参数的名称将基于聚合函数的名称和模型字段生成。 复杂的聚合不可以使用匿名参数，必须指定一个关键字参数作为别名。

例如，想知道Blog Entry 的数目：

```
>>> from django.db.models import Count
>>> q = Blog.objects.aggregate(Count('entry'))
{'entry__count': 16}
```

通过使用关键字参数来指定聚合函数，可以控制返回的聚合的值的名称：

```
>>> q = Blog.objects.aggregate(number_of_entries=Count('entry'))
{'number_of_entries': 16}
```

## 14. exists()

exists()

如果QuerySet包含任何结果，则返回True，否则返回False。

查找具有唯一性字段（例如primary_key）的模型是否在一个QuerySet中的最高效的方法是：

```
entry = Entry.objects.get(pk=123)
if some_queryset.filter(pk=entry.pk).exists():
    print("Entry contained in queryset")
```

它将比下面的方法快很多，这个方法要求对QuerySet求值并迭代整个QuerySet：

```
if entry in some_queryset:
   print("Entry contained in QuerySet")
```

若要查找一个QuerySet是否包含任何元素：

```
if some_queryset.exists():
    print("There is at least one object in some_queryset")
```

将快于：

```
if some_queryset:
    print("There is at least one object in some_queryset")
```

## 15. update()

update(**kwargs)

**对指定的字段执行批量更新操作，并返回匹配的行数**（如果某些行已具有新值，则可能不等于已更新的行数）。

例如，要对2010年发布的所有博客条目启用评论，可以执行以下操作：

```
>>> Entry.objects.filter(pub_date__year=2010).update(comments_on=False)
```

可以同时更新多个字段 （没有多少字段的限制）。 例如同时更新comments_on和headline字段：

```
>>> Entry.objects.filter(pub_date__year=2010).update(comments_on=False, headline='This is old')
```

update()方法无需save操作。唯一限制是它只能更新模型主表中的列，而不是关联的模型，例如不能这样做：

```
>>> Entry.objects.update(blog__name='foo') # Won't work!
```

仍然可以根据相关字段进行过滤：

```
>>> Entry.objects.filter(blog__id=1).update(comments_on=True)
```

update()方法返回受影响的行数：

```
>>> Entry.objects.filter(id=64).update(comments_on=True)
1
>>> Entry.objects.filter(slug='nonexistent-slug').update(comments_on=True)
0
>>> Entry.objects.filter(pub_date__year=2010).update(comments_on=False)
132
```

如果你只是更新一下对象，不需要为对象做别的事情，最有效的方法是调用update()，而不是将模型对象加载到内存中。 例如，不要这样做：

```
e = Entry.objects.get(id=10)
e.comments_on = False
e.save()
```

建议如下操作：

```
Entry.objects.filter(id=10).update(comments_on=False)
```

用update()还可以防止在加载对象和调用save()之间的短时间内数据库中某些内容可能发生更改的竞争条件。

如果想更新一个具有自定义save()方法的模型的记录，请循环遍历它们并调用save()，如下所示：

```
for e in Entry.objects.filter(pub_date__year=2010):
    e.comments_on = False
    e.save()
```

## 16. delete()

delete()

批量删除QuerySet中的所有对象，并返回删除的对象个数和每个对象类型的删除次数的字典。

delete()动作是立即执行的。

不能在QuerySet上调用delete()。

例如，要删除特定博客中的所有条目：

```
>>> b = Blog.objects.get(pk=1)
# Delete all the entries belonging to this Blog.
>>> Entry.objects.filter(blog=b).delete()
(4, {'weblog.Entry': 2, 'weblog.Entry_authors': 2})
```

默认情况下，Django的ForeignKey使用SQL约束ON DELETE CASCADE，任何具有指向要删除的对象的外键的对象将与它们一起被删除。 像这样：

```
>>> blogs = Blog.objects.all()
# This will delete all Blogs and all of their Entry objects.
>>> blogs.delete()
(5, {'weblog.Blog': 1, 'weblog.Entry': 2, 'weblog.Entry_authors': 2})
```

这种级联的行为可以通过的ForeignKey的on_delete参数自定义。（什么时候要改变这种行为呢？比如日志数据，就不能和它关联的主体一并被删除！）

delete()会为所有已删除的对象（包括级联删除）发出`pre_delete`和`post_delete`信号。

## 17. as_manager()

classmethod as_manager()

一个类方法，返回Manager的实例与QuerySet的方法的副本。