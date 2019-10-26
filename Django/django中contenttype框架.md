# Django之contenttypes框架

**博主**   2019年05月21日  **分类：** [Django](http://www.liujiangblog.com/blog/tag/2/)  **阅读：**1382   [**评论**](http://www.liujiangblog.com/blog/44/#comments)：9

------

# contenttypes框架

Django除了我们常见的admin、auth、session等contrib框架，还包含一个`contenttypes`框架，它可以跟踪Django项目中安装的所有模型（model），为我们提供更高级的模型接口。默认情况下，它已经在settings中了，如果没有，请手动添加：

```
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',  # 看这里！！！！！！！！！！！
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]
```

平时还是尽量启用contenttypes框架，因为Django的一些其它框架依赖它：

- Django的admin框架用它来记录添加或更改对象的历史记录。
- Django的auth认证框架用它将用户权限绑定到指定的模型。

contenttypes不是中间件，不是视图，也不是模板，而是一些"额外的数据表"!所以，在使用它们之前，你需要执行makemigrations和migrate操作，为contenttypes框架创建它需要的数据表，用于保存特定的数据。这张表通常叫做`django_content_type`，让我们看看它在数据库中的存在方式：

![1558359639770](django%E4%B8%ADcontenttype%E6%A1%86%E6%9E%B6.assets/1558359639770.png)

而表的结构形式则如下图所示：

![1558359709577](django%E4%B8%ADcontenttype%E6%A1%86%E6%9E%B6.assets/1558359709577.png)

一共三个字段：

- id:表的主键，没什么好说的
- app_label：模型所属的app的名字
- model：具体对应的模型的名字。

表中的每一条记录，其实就是Django项目中某个app下面的某个model模型。

## 概述

contenttypes框架的核心是`ContentType` 模型，它位于`django.contrib.contenttypes.models.ContentType`。`ContentType`实例表示和存储Django项目中安装的所有模型的信息。每当你的Django项目中创建了新的模型，会在`ContentType`表中自动添加一条新的对应的记录。

`ContentType`模型的实例具有一系列方法，用于返回它们所记录的模型类以及从这些模型查询对象。`ContentType` 还有一个自定义的管理器，用于进行`ContentType`实例相关的ORM操作。

## `ContentType`模型

每个`ContentType` 实例都有两个字段（除了隐含的主键id）。

- `app_label`: 模型所属app的名称。通过模型的`app_label`属性自动获取，仅包括Python导入路径的**最后**部分。例如对于`django.contrib.contenttypes`模型，自动获取的`app_label`就是最后的`contenttypes`字符串部分。
- `model`：模型类的名称。（小写）

此外，ContentType实例还有一个`name`属性，保存了ContentType的人类可读名称。由模型的`verbose_name` 属性值自动获取。

例如，对于`django.contrib.sites.models.Site`这个模型：

- `app_label` 将被设置为`'sites'`（`django.contrib.sites`的最后一部分）。
- `model` 将被设置为`'site'`（小写）。

## `ContentType`的实例方法

每个`ContentType`实例都有一些方法，允许你从`ContentType`实例获取它所对应的模型，或者从该模型中检索对象：

- `ContentType.get_object_for_this_type(**kwargs)`

提供一系列合法的参数，在对应的模型中，执行一个get()查询操作，并返回相应的结果。

- `ContentType.model_class（）`

返回当前`ContentType`实例表示的模型类 。

例如，我们可以在 `ContentType`表中查询auth的 `User`模型对应的那条ContentType记录：

```
>>> from django.contrib.contenttypes.models import ContentType
>>> user_type = ContentType.objects.get(app_label='auth', model='user') # 获取到一条记录
>>> user_type # 注意，这是contenttype的实例对象，不是User表的
<ContentType: user>
```

然后，就可以使用它来查询特定的 `User`，或者访问`User`模型类：

```
>>> user_type.model_class()  # 获取User类
<class 'django.contrib.auth.models.User'>
>>> user_type.get_object_for_this_type(username='Guido') # 获取某个User表的实例
<User: Guido>
```

一起使用 `get_object_for_this_type()` 和`model_class()`方法可以实现两个特别重要的功能：

1. 使用这些方法，你可以编写对模型执行查询操作的高级通用代码 。不需要导入和使用某个特定模型类，只需要在运行时将`app_label`和 `model`参数传入 `ContentType`的ORM方法，然后使用`model_class()`方法就可以调用对应模型的ORM操作了。
2. 还可以将另一个模型与ContentType关联起来，作为将它的实例与特定模型类绑定的方法，并使用这些方法来访问这些模型类。

不好理解，没关系，往后接着看。

------

`ContentType`还有一个自定义管理器，也就是`ContentTypeManager`。它有下面的方法：

- `clear_cache（）`:用于清除内部缓存 。一般不需要手动调用它，Django会在需要时自动调用它。
- `get_for_id（id）`：通过id值查询一个`ContentType`实例。比`ContentType.objects.get(pk=id)`的方式更优。
- `get_for_model（model，for_concrete_model = True）`：获取模型类或模型的实例，并返回表示该模型的`ContentType` 实例。设置参数`for_concrete_model=False`允许获取代理模型的`ContentType`。
- `get_for_models（*model，for_concrete_model = True）`: 获取可变数量的模型类，并返回模型类映射`ContentType`实例的字典。
- `get_by_natural_key(app_label, model)`:给定app标签和模型名称，返回唯一匹配的`ContentType`实例。

当你只想使用 `ContentType`，但不想去获取模型的元数据以执行手动查找时，`get_for_model()`方法特别有用 ：

```
>>> from django.contrib.auth.models import User
>>> ContentType.objects.get_for_model(User) # 提供model的名字，查询出对应的contenttype实例。
<ContentType: user>
```

## 通用关系GenericForeignKey字段

`ContentTypes`框架最核心的功能是**连表**，也就是将两个模型或者说两张数据表通过外键联系起来。比如：

- 有A、B、C三个不同的模型
- 有一个特别的x模型，它需要外键关联到A、B、C模型之一
- 不可以同时关联到A\B\C中的两个以上，只能关联一个

那么，使用我们传统的Django模型思维，你可能写出下面的模型设计：

```
class A(models.Model):
    name = models.CharField(max_length=32)


class B(models.Model):
    name = models.CharField(max_length=32)


class C(models.Model):
    name = models.CharField(max_length=32)


class X(models.Model):
    name = models.CharField(max_length=32)
    a = models.ForeignKey(A, blank=True,null=True, on_delete=models.DO_NOTHING)
    b = models.ForeignKey(B, blank=True,null=True, on_delete=models.DO_NOTHING)
    c = models.ForeignKey(C, blank=True,null=True, on_delete=models.DO_NOTHING)
```

注意，X中的a、b、c三个外键字段，它们必须允许为空。然后在你的实际ORM操作中，你还必须注意，不能同时对a、b、c字段赋值，最多只能赋值一个。

这种方式不但要写重复的代码，而且效率低，安全差，也不利于后期维护。

解决办法是使用ContentTypes框架，如下所示：

```
from django.contrib.contenttypes.models import ContentType
from django.contrib.contenttypes.fields import GenericForeignKey

class A(models.Model):
    name = models.CharField(max_length=32)


class B(models.Model):
    name = models.CharField(max_length=32)


class C(models.Model):
    name = models.CharField(max_length=32)


class X(models.Model):
    name = models.CharField(max_length=32)
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE)
    object_id = models.PositiveIntegerField()
    content_object = GenericForeignKey('content_type', 'object_id')
```

- 首先，我们导入了两个类，ContentType和GenericForeignKey，一个是模型类，一个是字段类
- 其次，我们删除了先前的三个外键
- 最后，我们添加了三个字段

需要说明的是，我们添加这三个字段的套路，可以适用在大多数的场景，无需修改。也就是说，这三行代码你直接拷贝使用就可以了。

上面三个字段：

- `content_type`字典是一个指向`ContentType`模型的外键，一般我们就取这个名字，别换。
- object_id是一个主键id字段，存储A、B、C模型中某个实例的主键，也就是说，最终是A、B、C模型中的哪个实例关联到当前的这个X模型的实例。（注意，虽然可以使用除数字类型主键外的，比如字符串或者文本类型作为关联的字段，但是建议大家还是使用pk。）
- `content_object`这个字段比较特殊，它的字段类型来自ContentTypes框架，不是Django原生的。这个字段不会创建任何的数据库实际的列，不影响任何的数据过程，只是为了方便ORM操作。它需要两个参数，就是前面两个字段的名字，一般情况下都保持默认的就好。

------

让我们看个具体的例子，一个简单的标签系统，如下所示：

```
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.db import models

class TaggedItem(models.Model):
    tag = models.SlugField()
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE)
    object_id = models.PositiveIntegerField()
    content_object = GenericForeignKey('content_type', 'object_id')

    def __str__(self):
        return self.tag
```

普通的`ForeignKey`字段只能指向另外唯一一个模型，这意味着如果`TaggedItem`模型使用了`ForeignKey`，则必须选择一个且只有一个模型来存储标签。contenttypes框架提供了一个特殊的字段类型（`GenericForeignKey`），它可以解决这个问题，并允许关联任何模型：

然后我们就可以进行下面的操作了：

```
>>> from django.contrib.auth.models import User
>>> guido = User.objects.get(username='Guido')  #创建一个auth的user对象
>>> t = TaggedItem(content_object=guido, tag='bdfl') 创建一个标签，关联到guido用户
>>> t.save() # 执行数据库写入操作
>>> t.content_object  # 查看一下
<User: Guido>
```

**重点说明**：对于`t = TaggedItem(content_object=guido, tag='bdfl')`这行代码，应该是Django原生ORM中创建一个模型实例的方法，可是你看它提供的参数：

- 没有提供`content_type`字段关联的`ContentType`的id，没有提供t实例关联的User表的Guido用户的id！
- 提供的是一个`content_object`的对象`guido`

**这就是在前面我们说的`content_object = GenericForeignKey('content_type', 'object_id')`，这个字段的作用！它不参与字段的具体内容生成和保存，只是为了方便ORM操作！它免去了我们通过Guido用户取查找自己的id，以及查找`ContentType`表中对应模型的id的过程！**

其实，看到这里，已经**说明了`ContentType`模型就是一张中间表！**

接下来，如果删除了相关对象，比如删除Guido用户，`content_type`和`object_id`字段仍将设置为其原始值，而`GenericForeignKey`字段将返回 `None`：

```
>>> guido.delete()
>>> t.content_object  # returns None
```

但是，也由于`GenericForeignKey`字段类型的特殊性，你不能直接使用它进行过滤器操作，比如`filter()` 和`exclude()`，看下面的例子：

```
# 失败的操作
>>> TaggedItem.objects.filter(content_object=guido)
# 失败的操作
>>> TaggedItem.objects.get(content_object=guido)
```

同样，在`ModelForms`中，`GenericForeignKey`也是不会出现的，仅用于ORM操作。

## 反向通用关系`GenericRelation`字段

既然前面使用GenericForeignKey字段可以帮我们正向查询关联的对象，那么就必然有一个对应的反向关联类型，也就是`GenericRelation`字段类型。

使用它可以帮助我们从关联的对象反向查询对象本身，也就是ORM中的反向关联。

同样的，这个字段也不会对数据表产生任何影响，仅仅用于ORM操作！

比如下面的例子，我要从书签去反向查询它所对应的标签：

```
from django.contrib.contenttypes.fields import GenericRelation # 导入
from django.db import models

class Bookmark(models.Model):
    url = models.URLField()
    tags = GenericRelation(TaggedItem) # 看这里！！！！！！！！！！！！！
```

每个`Bookmark`实例都有一个`tags`字段，可以用来检索它关联的`TaggedItems`对象：

```
>>> b = Bookmark(url='https://www.djangoproject.com/')
>>> b.save()
>>> t1 = TaggedItem(content_object=b, tag='django')
>>> t1.save()
>>> t2 = TaggedItem(content_object=b, tag='python')
>>> t2.save()
>>> b.tags.all()  # 看这句！！！！！！！！！！！！
<QuerySet [<TaggedItem: django>, <TaggedItem: python>]>
```

上面的操作涉及到一个ORM新手非常容易犯的错误，那就是外键这种一对多的关系，究竟要怎么写：

- 首先，要想明白是一个标签可以对应多个书签，还是一个书签可以对应多个标签？
- 这里定义的是一个书签bookmark可以对应多个标签tag，书签是‘一’方，标签是‘多’方。
- 所以，ForeignKey字段要写在多的一方，也就是`TaggedItem`模型中。
- 那么对于Bookmark模型对象，去查询关联的tag对象，就是属于从一到多的反向查询。
- 这也就是上面我们最后为什么是使用`b.tags.all()`这种查询方法，而不是直接`b.tags`!

这里请你自己做一件事，它有助于你理解为什么在`ContentType`框架中建议使用`GenericForeignKey`和`GenericRelation`这种关联字段：

**请用Django原生的ORM方法，执行上面的正向查询和反向查询操作！并与例子中的操作进行对比！**

------

如果为`GenericRelation`字段提供一个 `related_query_name`参数值，比如下面的例子：

```
tags = GenericRelation(TaggedItem, related_query_name='bookmark')
```

那么将可以从TaggedItem对象过滤查询关联的BookMark对象，如下所示：

```
>>> # 查找所有属于特定书签模型的标签，这些书签必须包含`django`字符串。
>>> TaggedItem.objects.filter(bookmark__url__contains='django')
<QuerySet [<TaggedItem: django>, <TaggedItem: python>]>
```

当然，如果你不添加`related_query_name`参数，也可以手动执行相同类型的查找：

```
>>> bookmarks = Bookmark.objects.filter(url__contains='django')
>>> bookmark_type = ContentType.objects.get_for_model(Bookmark)
>>> TaggedItem.objects.filter(content_type__pk=bookmark_type.id, object_id__in=bookmarks)
<QuerySet [<TaggedItem: django>, <TaggedItem: python>]>
```

比较一下，三行代码和一行代码的区别！

**注意**：`GenericForeignKey` 和`GenericRelation`字段是匹配的， 如果你在定义`GenericForeignKey`的时候使用了另外的`content-type`和`object-id`名字，那么在`GenericRelation`定义中，你必须做同样的变化。

例如，如果`TaggedItem`模型使用`content_type_fk`和 `object_primary_key`创建`content_object`字段，像下面这样：

```
...
class TaggedItem(models.Model):
    tag = models.SlugField()
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE)
    object_id = models.PositiveIntegerField()
    content_object = GenericForeignKey('content_type_fk', 'object_primary_key') #看这里
    ...
```

那么在`GenericRelation`中，你需要像这样定义：

```
tags = GenericRelation(
    TaggedItem,
    content_type_field='content_type_fk',
    object_id_field='object_primary_key',
)
```

**另外还要注意**：如果你删除了一个具有`GenericRelation`字段的对象，则任何具有`GenericForeignKey`字段指向该对象的关联对象也将被删除。在上面的示例中，这意味着如果删除了某个`Bookmark`对象，则会同时删除指向该对象的任何`TaggedItem`对象。

不同于普通的`ForeignKey`字段， `GenericForeignKey`字段不接受`on_delete`参数。如果需要，可以重写 `pre_delete`方法，不细说。

## 其它

Django的数据库聚合API可用于 `GenericRelation`。例如，你可以找出所有书签的标签数量：

```
>>> Bookmark.objects.aggregate(Count('tags'))
{'tags__count': 3}
```

------

除以上内容外，contenttypes框架还提供了`django.contrib.contenttypes.forms`模块用于处理表单相关内容，`django.contrib.contenttypes.admin`模块用于处理管理后台相关内容，感兴趣的可以自行查阅相关资料。