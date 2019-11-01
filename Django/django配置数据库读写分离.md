# Django配置数据库读写分离

对网站的数据库作读写分离（Read/Write Splitting）可以提高性能，在Django中对此提供了支持，下面我们来简单看一下。注意，还需要运维人员作数据库的读写分离和数据同步。

### 配置数据库

我们知道在Django项目的settings中，可以配置数据库，除了默认的数据库，我在下面又加了一个`db2`。因为是演示，我这里用的是默认的SQLite，如果希望用MySQL，看[这里](http://blog.csdn.net/ayhan_huang/article/details/77575186#t4) 。

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    },
    'db2': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db2.sqlite3'),
    },
}12345678910
```

### 创建models并执行数据库迁移

这里我简单创建一张产品表

```python
from django.db import models


class Products(models.Model):
    """产品表"""
    prod_name = models.CharField(max_length=30)
    prod_price = models.DecimalField(max_digits=6, decimal_places=2)1234567
```

创建完成后，执行数据库迁移操作：

```shell
python manage.py makemigrations  # 在migrations文件夹下生成记录，迁移前检查
python manage.py migrate  # 创建表12
```

在migrations文件夹下生成记录，并在迁移前检查是否有问题，默认值检查`defualt`数据库，但是可以在后面的数据库路由类(Router)中通过`allow_migrate()`方法来指定是否检查其它的数据库。

其实第二步迁移默认有参数`python manage.py migrate --database default` ，在默认数据库上创建表。因此完成以上迁移后，执行`python manage.py --database db2`，再迁移一次，就可以在db2上创建相同的表。这样在项目根目录下，就有了两个表结构一样的数据库，分别是db.sqlite3和db2.sqlite3。

### 读写分离

#### 手动读写分离

在使用数据库时，通过`.using(db_name)`来手动指定要使用的数据库

```python
from django.shortcuts import HttpResponse
from . import models


def write(request):
    models.Products.objects.using('default').create(prod_name='熊猫公仔', prod_price=12.99)
    return HttpResponse('写入成功')


def read(request):
    obj = models.Products.objects.filter(id=1).using('db2').first()
    return HttpResponse(obj.prod_name)123456789101112
```

#### 自动读写分离

通过配置数据库路由，来自动实现，这样就不需要每次读写都手动指定数据库了。数据库路由中提供了四个方法。这里这里主要用其中的两个：`def db_for_read()`决定读操作的数据库，`def db_for_write()`决定写操作的数据库。

##### 定义Router类

新建`myrouter.py`脚本，定义Router类：

```python
class Router:
    def db_for_read(self, model, **hints):
        return 'db2'

    def db_for_write(self, model, **hints):
        return 'default'123456
```

##### 配置Router

```
settings.py`中指定`DATABASE_ROUTERS
DATABASE_ROUTERS = ['myrouter.Router',]  1
```

可以指定多个数据库路由，比如对于读操作，Django将会循环所有路由中的`db_for_read()`方法，直到其中一个有返回值，然后使用这个数据库进行当前操作。

##### 一主多从方案

网站的读的性能通常更重要，因此，可以多配置几个数据库，并在读取时，随机选取，比如：

```python
class Router:
    def db_for_read(self, model, **hints):
        """
        读取时随机选择一个数据库
        """
        import random
        return random.choice(['db2', 'db3', 'db4'])

    def db_for_write(self, model, **hints):
        """
        写入时选择主库
        """
        return 'default'12345678910111213
```

### 分库分表

在大型web项目中，常常会创建多个app来处理不同的业务，如果希望实现app之间的数据库分离，比如app01走数据库db1，app02走数据库

```python
class Router:
    def db_for_read(self, model, **hints):
        if model._meta.app_label == 'app01':
            return 'db1'
        if model._meta.app_label == 'app02':
            return 'db2'

    def db_for_write(self, model, **hints):
       if model._meta.app_label == 'app01':
            return 'db1'
       if model._meta.app_label == 'app02':
            return 'db2'
```

# Django（四）数据库

# 一、数据库框架

数据库框架是数据库的抽象层，也称为对象关系映射（Object-Relational Mapper, ORM），它将高层的面向对象操作转换成低层的数据库指令，比起直接操作数据库引擎，ORM极大的提高了易用性。这种转换会带来一定的性能损耗，但ORM对生产效率的提升远远超过这一丁点儿性能降低。
Django中内置的SQLAlchemy ORM就是一个很好的数据库框架，它为多种关系型数据库引擎提供抽象层，比如MySQL, Postgres，SQLite，并且使用相同的面向对象接口。因此，使用SQLAlchemy ORM，不仅能极大的提高生产力，而且可以方便的在多种数据库之间迁移。

# 二、配置数据库

我们可以在项目文件夹的settins.py中配置数据库引擎。
Django默认使用sqlite：

```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',  # sqlite引擎
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}123456
```

如果要要使用mysql, 需要进行如下配置：
1 编辑项目文件夹下的`settings.py` :

```
DATABASES = {

    'default': {

        'ENGINE': 'django.db.backends.mysql',  # mysql引擎
        'NAME': 'BookManagement',    
        # 数据库名称, 需要通过命令‘CREATE DATABASE BookManagement’在mysql命令窗口中提前创建
        'USER': 'root',   #你的数据库用户名
        'PASSWORD': '***', #你的数据库密码
        'HOST': '', #你的数据库主机，留空默认为localhost
        'PORT': '3306', #你的数据库端口
    }
}12345678910111213
```

2 编辑项目文件夹下的`__init__.py` :
由于mysql在Django中默认驱动是MySQLdb, 而该驱动不适用于python3， 因此，我们需要更改驱动为PyMySQL

```
import pymysql

pymysql.install_as_MySQLdb()123
```

3 显示SQL语句
前面我们说了ORM将高层的面向对象的操作，转换为低层的SQL语句，如果想在终端打印对应的SQL语句，可以在`setting.py`中加上日志记录：

```
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console':{
            'level':'DEBUG',
            'class':'logging.StreamHandler',
        },
    },
    'loggers': {
        'django.db.backends': {
            'handlers': ['console'],
            'propagate': True,
            'level':'DEBUG',
        },
    }
}1234567891011121314151617
```

# 三、模型

在ORM中，用模型(Model)表示数据库中一张表。模型的具体实现是一个Python类，类中的属性对应数据库表中的字段，这个类的实例化对象，对应表中的一条记录。
总结：类 –> 表； 类属性 –> 表字段； 类实例 –> 表记录

## 定义模型

定义模型就是定义一个python类，以创建一个图书管理系统为例，基本形式如下：

```
from django.db import models

class Publish(models.Model):
    name = models.CharField(max_length=60)
    addr = models.CharField(max_length=60)

    def __str__(self):
        return self.name


class Author(models.Model):
    name = models.CharField(max_length=30)

    def __str__(self):
        return self.name


class Book(models.Model):
    name = models.CharField(max_length=60)
    price = models.DecimalField(max_digits=6, decimal_places=2)
    publish = models.ForeignKey(Publish)
    # 定义书与出版社的多对一关系
    # 默认绑定到Publish表中的主键字段
    authors = models.ManyToManyField(Author)
    # 定义书与作者的多对多关系，ORM将自动创建多对多关系的第三张表12345678910111213141516171819202122232425
```

说明：
\1. 定义完模型后，或者修改了模型后，要执行数据库迁移操作：
`python manage.py makemigrations`
`python manage.py migrate`
执行完命令后，查看数据库的表目录，可以看到上述表格成功创建：
![这里写图片描述](django%E9%85%8D%E7%BD%AE%E6%95%B0%E6%8D%AE%E5%BA%93%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.assets/20170827171125549.png)
\2. 上述模型中都没有设置主键，在完成上迁移操作后，orm会自动创建主键。
\3. orm会自动将Book表中的关联字段`publish`, 在数据库中存为`publish_id`, 所以不要画蛇添足自己命名为publish_id，否则你在数据库中看到的是publish_id_id
\4. 外键引用的主表要么在子表前创建，要么使用字符串形式指定，否则子表找不到主表。
\5. 如果我们实例化一个Book对象，book_obj, 那么通过book_obj.publish得到的是publish_id对应的那个Publish对象。这是ORM作的设定，原因很简单，如果通过book_obj.publish得到只是一个publish_id，对我们并没有多大用。
\6. 虽然不是强制的，但是建议在每个类中定义`__str__`方法（或`__repr__`方法），这样当我们打印对象时，可以显示具有可读性的字符串信息，方便调试。
\7. 只要在一张表中定义了多对多关系，orm会自动创建实现多对多关系的第三张表。当然，你也可以手动创建，如下：

```
class BookToAuthor(models.Model):
    # 手动创建书与作者的多对多关系的第三张表
    book = models.ForeignKey(Book)
    author = models.ForeignKey(Author)1234
```

还是不建议手动创建，一是麻烦，而是后面我在执行删除记录的操作时，提示找不到第三关联表，可能是我表名命名问题，猜测应该将第三张表命名为`Book_authors`的格式，这样才能和orm自动创建的第三张表同名，未验证。。。

## 字段类型

| 类型名                                            | Python类型        | 说明                                                    |
| ------------------------------------------------- | ----------------- | ------------------------------------------------------- |
| IntegerField                                      | int               | 普通整数,通常是32位,-2147483648 to 2147483647           |
| SmallIntegerField                                 | int               | 小整数，一般是16位，-32768 to 32767                     |
| BigIntegerField                                   | int/long          | 64位的整数，-9223372036854775808 to 9223372036854775807 |
| FloatField                                        | float             | 浮点数                                                  |
| DecimalField(max_digits=None, decimal_places=None | decimal.Decimal   | 定点数,精度更高；要求指定位数和小数点精度。             |
| CharField(max_length=None)                        | str               | 字符串；要求指定最大长度                                |
| TextField                                         | str               | 变长字符串                                              |
| BooleanField                                      | bool              | 布尔值                                                  |
| DateField                                         | datetime.date     | 日期，比如：2017-08-25                                  |
| DateTimeField                                     | datetime.datetime | 日期和时间                                              |
| BinaryField                                       | str               | 二进制                                                  |

更多类型请参考[官网 field types](https://docs.djangoproject.com/en/1.11/ref/models/fields/#field-types)

## 关系字段

| 字段                        | 说明                       |
| --------------------------- | -------------------------- |
| ForeignKey(othermodel)      | 多对一关系,需要指定关系表  |
| ManyToManyField(othermodel) | 多对多关系，需要指定关系表 |
| OneToOneField(othermodel)   | 一对一关系，需要指定关系表 |

## 字段选项

| 选项         | 说明                                                         |
| ------------ | ------------------------------------------------------------ |
| primary_key  | 如果设置primary_key=True, 这列就是表的主键；如果不指定，Django会自动添加一个AutoField字段来盛放主键，所以我们一般无需设定主键。 |
| unique       | 如果设置unique=True, 这列不允许出现重复的值                  |
| db_index     | 如果设置db_index=True, 为这列创建索引，提升查询效率          |
| null         | 如果设置null=True, 这列允许使用空值；如果新增了字段，建议设置该选项，因为新增字段之前的记录没有该字段 |
| default      | 为这列定义默认值；如果新增了字段，建议设置该选项，因为新增字段之前的记录没有该字段 |
| related_name | 在一对多关系多所在的表中定义反向引用；这样在一所在的表中反向查询多所在的表时，直接用这个字段就行了，可以替代下面要讲到的`_set`反向查询 |

更多选项请参考[官网 filed options](https://docs.djangoproject.com/en/1.11/ref/models/fields/#field-options)

# 四、数据库的操作

下面通过python shell来演示数据库的操作。在终端切换到项目根目录下，输入命令`python manage.py shell`进入shell操作环境：

## 增删改查

#### 1 创建记录

方式一：实例化

```
>>> from app.models import Author #导入模型
>>> a = Author(name="张三")  # 实例化
>>> a.save()  # 插入记录
>>> print(a)
张三
123456
```

方式二：`create()`工厂函数

```
>>> Author.objects.create(name='李四')
<Author: 李四>
123
```

通过`get_or_create()`创建记录，这种方法可以防止重复（速度稍慢，因为会先查询数据库），它返回一个元组，第一个是实例对象（记录），创建成功返回True，已存在则返回False，不执行创建。

```
>>> Author.objects.get_or_create(name='李四')
(<Author: 李四>, False)12
```

#### 2 查询记录

1 `Author.objects.all()`查询所有

```
>>> Author.objects.all()
<QuerySet [<Author: 张三>, <Author: 李四>]>
123
```

我们也可以对查询结果进行切片索引操作：`Author.objects.all()[start:end:step]`，注意，不支持负索引：

```
>>> Author.objects.all()[-1]
AssertionError: Negative indexing is not supported.
123
```

2 `Author.objects.filter(name='李四')` 过滤查询

3 万能的双下划线查询`__`，对应SQL的where语句
__contains, __regex, __gt, __th， 多个条件之间以逗号分隔

```
>>> Author.objects.filter(name__contains='李')  # 查询姓名中包含‘李’的记录；如果是__icontains则不区分大小写
<QuerySet [<Author: 李四>, <Author: 李白>]>

>>> Author.objects.filter(name__regex=r'^李') #正则查询，以‘李’开头的记录；如果是__iregex则不区分大小写
<QuerySet [<Author: 李四>, <Author: 李白>]>

>>> Author.objects.filter(id__gt=3)  # 查询id大于3的记录
<QuerySet [<Author: 李白>, <Author: 光绪>, <Author: Martin>]>

>>> Author.objects.filter(id__lt=3) # 查询id小于3的记录
<QuerySet [<Author: 张三>]>1234567891011
```

`__in`判断字段在列表内。另外通常用`pk`指主键，不限于`id`，适用性更好。

```
models.Server.objects.filter(pk__in=id_list).delete()1
```

其它还有: `__startswith(), __istartswith(), __endswith(), __iendswith()`
4 `Author.objects.get()` 只能得到一个对象，多了少了都报错

```
>>> Author.objects.get(name='李四')
<Author: 李四>
123
```

5 `first(), last()`获取查询结果中的单个对象

```
>>> Author.objects.filter(id__gt=2).first()  # 获取第一个
<Author: 李四>
>>> Author.objects.filter(id__gt=2).last()  # 获取最后一个
<Author: Martin>1234
```

6 `values(*field)` 用字典形式，返回指定字段的查询结果；多个字段间以逗号分隔

```
>>> Author.objects.values('name')
<QuerySet [{'name': '李白'}, {'name': '光绪'}]>
# values()方法前可以加过滤条件，如果不加，相当于Author.objects.all().values()123
```

7 `values_list(*field)`，同上，用元组形式

```
<QuerySet [('李白',), ('光绪',)]>
12
```

8 `exclude(**kwargs)`反向过滤

```
>>> Author.objects.exclude(name__contains='鲁迅') # 过滤所有姓名不包含‘鲁迅的’
<QuerySet [<Author: 李白>, <Author: 光绪>, <Author: Martin>]>
123
```

9 `order_by(*field)` 根据字段排序
10 `reverse()` 反向排序，用在·`order_by`后面
11 `distinct()` 剔除重复
12 `count()` 统计数量
13 `exists()` QuerySet包含数据返回True, 否则返回False

#### 3 修改记录

方式一：QuerySet.update(field=var)
修改的前提是先查找，然后调用`update(field=val)`方法，只有QuerySet集合对象才能调用该方法，也就是说通过`get(), first(), last()`获取的对象没有该方法。

```
>>> Author.objects.filter(name='李白').update(name='李小白')
1 # 更新了一条记录
# 对应的SQL语句
UPDATE `app_author` SET `name` = '李小白' WHERE `app_author`.`name` = '李白'; args=('李小白', '李白')1234
```

方式二：对象赋值，不推荐，效率低

```
>>> obj = Author.objects.filter(name='李小白').first()
>>> obj.name='李白'
>>> obj.save()
# SQL语句：
UPDATE `app_author` SET `name` = '李白' WHERE `app_author`.`id` = 3; args=('李白', 3)
从SQL语句可以看出，通过对象赋值的方式，会将该对象的所有字段重新赋值，故而效率低。123456
```

#### 4 删除记录

删除的前提是先查找，然后调用`delete()`方法；不同于`update()`方法，`delete()`支持QuerySet集合对象的删除，也支持单个对象的删除。
`delete()`默认就是级联删除：删除一条记录后，在多对多关系的关联表中与该记录有关的记录也会删除。

```
>>> Author.objects.filter(id=1).delete()
(1, {'app.Book_authors': 0, 'app.Author': 1})   # 该记录在本表和关联表中的删除情况
123
```

## QuerySet

从数据库从数据库查询出来的结果一般是一个集合，哪怕只有一个对象，这个集合叫QuerySet。
**QuerySet特性：**
1 支持切片操作
2 可迭代：for循环
3 惰性机制：只有使用QuerySet时，才会走数据库，比如执行`res = Author.objects.all()`时，并不会真正执行数据库查询，只是翻译为SQL语句。而当我们执行`if res`, `print res`, `for obj in res`这些操作时，才会执行SQL语句，进行数据库查询。这一点可以通过在`setting.py`中加上日志记录显示SQL语句得到证实。
4 缓存机制：每次执行了数据库查询后，会将结果放在QuerySet的缓存中，下次再使用QuerySet时，不走数据库，直接从缓存中拿数据。缓存机制减少了对数据库的访问，有利于提高性能。但是一旦数据库数据更新，除非重新访问数据库，否则缓存也不会更新，下面我们来证实这一点：

```
>>> res = Author.objects.all()
>>> for item in res:
...     print(item.name)
...
李白
光绪
鲁迅
Martin
>>> Author.objects.create(name="Susan")
<Author: Susan>
# 往数据库插入一条记录
>>> for item in res:
...     print(item.name)
...
李白
光绪
鲁迅
Martin
# 以上结果可以验证QuerySet对象的缓存机制，尽管新插入了一条记录，但打印结果没变，说明，它不会重新走数据库，而是从缓存中拿。

# 下面我们重新访问数据库, 缓存更新，打印出了我们刚刚插入的那条记录：
>>> res = Author.objects.all()
>>> for item in res:
...     print(item.name)
...
李白
光绪
鲁迅
Martin
Susan

1234567891011121314151617181920212223242526272829303132
```

## 提高数据库性能

### iterator()迭代器

如果我们查询出的数据很大，QeurySet的缓存肯定会崩。解决方案：对QeurySet应用`.iterator()`方法，将查询结果转化为迭代器。

```
>>> g = Author.objects.all().iterator()
>>> for item in g:
...     print(item.name)
...
李白
光绪
鲁迅
Martin
Susan
>>> for item in g:
...     print(item.name)
...
>>>
# 第一次for循环迭代器迭代完了，所以第二次不会打印出来1234567891011121314
```

尽管转化为迭代器会节省内存，但是这也意味着，会造成额外的数据库查询。

### exists()

比如我们拿到一个QuerySet对象，`res = Book.objects.all()`，想确定记录是否存在，如果用`if res`，将会查询数据库中的所有记录，这会极大的影响性能，解决方案：`if res.exists()` 这样会限定只查询一条记录（低层转化为SQL语句中的limit 1)

### select_related主动连表查询

提高数据库性能的关键一点是减少对数据库的查询，我们来看一个栗子：

\1. 创建一张Role角色表，和UserInfo表，建立一对多关系：

```
from django.db import models


class Role(models.Model):
    title = models.CharField(max_length=32)


class UserInfo(models.Model):
    name = models.CharField(max_length=32)
    role = models.ForeignKey("Role", null=True)12345678910
```


2.往UserInfo表中插入3个用户，并指定角色：略

3.在视图中通过如下方式查询用户名和用户的角色名：

```
def index(request):
    user_list = UserInfo.objects.all()
    for user in user_list:
        print(user.name, user.role.title)
    return HttpResponse('ok')12345
```

4.在settings.py中配置打印SQL命令；通过浏览器访问`http://127.0.0.1:8000/index.html/`执行index视图函数，查看SQL命令的执行结果：

```
(0.000) SELECT "app01_userinfo"."id", "app01_userinfo"."name", "app01_userinfo"."pwd", "app01_userinfo"."role_id" FROM "app01_userinfo"; args=()
(0.000) SELECT "app01_role"."id", "app01_role"."title" FROM "app01_role" WHERE "app01_role"."id" = 1; args=(1,)
(0.000) SELECT "app01_role"."id", "app01_role"."title" FROM "app01_role" WHERE "app01_role"."id" = 2; args=(2,)
(0.000) SELECT "app01_role"."id", "app01_role"."title" FROM "app01_role" WHERE "app01_role"."id" = 3; args=(3,)1234
```

SQL语句显示一共执行了4次数据库查询，第一次对应`user_list = UserInfo.objects.all()`，剩余三次是`for user in user_list: print(user.name, user.role.title)` 循环时，针对三个用户，查询了三次角色表。如果用户数量很多，这样一次次的查询数据库，将极大影响数据库性能。

下面我们通过`select_related`执行查询：

```
def index(request):
    user_list = UserInfo.objects.all().select_related("role")
    for user in user_list:
        print(user.name, user.role.title)
    return HttpResponse('ok')12345
```


查看这次的SQL语句：只执行了一次数据库查询

```
(0.001) SELECT "app01_userinfo"."id", "app01_userinfo"."name", "app01_userinfo"."role_id", "app01_role"."id", "app01_role"."title" FROM "app01_userinfo" LEFT OUTER JOIN "app01_role" ON ("app01_userinfo"."role_id" = "app01_role"."id"); args=()1
select_related('FK')`取当前表数据和表外键关联字段，因此，在一次查询中获得了所有需要的信息。
如果要连多个表，通过双下划线连接更多外键字段即可：
`select_related('FK1__FK2')
```

### prefetch_related

我们将上面的栗子中的`select_related`改为`prefetch_related`

```
def index(request):
    user_list = UserInfo.objects.all().prefetch_related("role")
    for user in user_list:
        print(user.name, user.role.title)
    return HttpResponse('ok')12345
```

查看SQL语句：

```
(0.000) SELECT "app01_userinfo"."id", "app01_userinfo"."name", "app01_userinfo"."role_id" FROM "app01_userinfo"; args=()
(0.001) SELECT "app01_role"."id", "app01_role"."title" FROM "app01_role" WHERE "app01_role"."id" IN (1, 2, 3); args=(1, 2, 3)12
```

执行了两次查询，第二次查询是通过判断用户角色是否在角色表，并将关联的角色取出来。因为通常用户数量很多，但是角色相对会少很多，因此，这种方式也减少了对数据库的访问。

### only

```
UserInfo.objects.all().only("name")1
```

`only()`方法只取某个字段，因此，如果需要只是需要用到指定的字段，通过这种方式可以提供性能。区别于`values()`，`only()`的查询结果还是对象，而`values()`的查询结果是字典。

### defer

与`only()`相反，排除某个字段。

## 关联关系的处理

在视图函数中操作数据库的语法与在python shell中是一样的

### 添加一对多关系

```
from django.shortcuts import render, HttpResponse
from  .models import *

def add(request):

    # 方式一,通过真实字段赋值
    Book.objects.get_or_create(
        title = 'chinese',
        price = 10.00,
        publish_id = 1, # Book的publish字段在数据库中真实表示是publish_id
    )

    # 方式二， 通过对象赋值
    publish_obj = Publish.objects.get(id=2)
    Book.objects.create(
        title ='English',
        price = 18.88,
        publish = publish_obj, #通过对象赋值
    )

    return HttpResponse('OK')123456789101112131415161718192021
```

### 添加/解除多对多关系

```
from django.shortcuts import render, HttpResponse
from  .models import *

def add(request):

    # 添加多对多关系的前提是记录已经创建好，无法在创建记录的同时添加多对多关系
    # 逐个添加 add(obj)
    author_obj1 = Author.objects.get(id=1)
    author_obj2 = Author.objects.get(id=2)
    book_obj = Book.objects.get(id='8')
    book_obj.authors.add(author_obj2, author_obj1)

    # 批量添加 add(queryset)
    author_list = Author.objects.all()
    book_obj = Book.objects.get(id='1')
    book_obj.authors.add(*author_list)
    # * + 列表，将列表传给函数
    # * + 字典，将字典传给函数

    # 打印authors --> 对象集合
    book_obj = Book.objects.get(id='8')
    print(book_obj.authors.all())
    # 打印结果：<QuerySet [<Author: Egon>, <Author: Alex>, <Author: 鲁迅>, <Author: 光绪>]>

    # 解除部分绑定 remove(obj)
    book_obj = Book.objects.get(id='8')
    author = Author.objects.get(id=2)
    book_obj.authors.remove(author)
    # 如果要解除多个：
    # * + 列表，将列表传给函数
    # * + 字典，将字典传给函数

    # 解除所有绑定 clear()
    book_obj = Book.objects.get(id='8')
    book_obj.authors.clear()


    return HttpResponse('OK')
123456789101112131415161718192021222324252627282930313233343536373839
```

## 多表查询

### 正向查询：通过当前表中存在的字段查询

例1：一对多：查询一本书出版社的名字

```
>>> b = Book.objects.filter(name__contains='现代').first() 
>>> b.publish.name  # b.publish 是一个对象，对应主表Publish中的一条记录
'复旦出版'
# 通过publish拿到对应主表中的对象，访问其属性1234
```

例2：多对多：查询一本书的作者

```
>>> b = Book.objects.get(name='linux')
>>> author_list = b.authors.all()  # 拿到某本书的所有author对象
>>> print(author_list)
<QuerySet [<Author: 李白>, <Author: 光绪>]>1234
```

以上两例是基于对象属性的正向查询。
例3：查询某出版社出版了哪些书：

```
>>> pid = Publish.objects.get(name='人民邮电').id
>>> book_list = Book.objects.filter(publish_id=pid)
# 正向查询，先拿到出版社id, 然后根据id查询123
```

### 反向查询

Publish表中没有book相关的字段，但是可以通过反向查询来做：`book_set`(用关联的表名小写，下划线加set)来找到与出版社关联的书籍的对象的集合
还是例3，如果用反向查询：

```
>>> pub = Publish.objects.get(name='人民邮电')
>>> book_list = pub.book_set.all()
>>> print(book_list)
<QuerySet [<Book: linux>, <Book: python>]>1234
```

book_set : 关联表名，set集合；all()取出所有数据。
注意，如果是一对一关联，那么就不用加`_set`。
基于反向查询的语法，我们也可以执行反向绑定关系：
伪代码形式：

```
a = Author.object.get(..) 拿到作者对象
book_list = ... # 拿到书籍对象的集合
a.book_set.add(*book_list.all()) # 通过反向查询来增加
1234
```

### 基于values(), filter(), 双下划线的多表查询

以上几种多表查询方式都略显麻烦，现在我们通过values(), filter(), 双下划线，来简化一下：
例1：查询一本书出版社的名字（正向思路）：

```
>>> Book.objects.filter(name='水浒传').values('publish__name')
<QuerySet [{'publish__name': '机械工业'}]>
# publish（子表中的关联字段） + __（双下划线） + name（Publish表中的字段）
# 对应的SQL语句：valuse("publish__name")应用了表联结：
SELECT `app_publish`.`name` FROM `app_book` INNER JOIN `app_publish` ON (`app_book`.`publi
sh_id` = `app_publish`.`id`) WHERE `app_book`.`name` = '水浒传' LIMIT 21; args=('水浒传',)
1234567
```

例2： 查询出版了某本书的的出版社名字（反向思路）：

```
>>> Publish.objects.filter(book__name='linux').values('name')
<QuerySet [{'name': '人民邮电'}]>
# book（子表名） + __（双下划线） + name（子表中的字段）
# 对应的低层SQL语句：filter(book__title="linux")应用了表联结 
 SELECT `app_publish`.`name` FROM `app_publish` INNER JOIN `app_book` ON (`app_publish`.`id
` = `app_book`.`publish_id`) WHERE `app_book`.`name` = 'linux' LIMIT 21; args=('linux',)
1234567
```

例3：查询价格大于10的书籍的作者姓名：

```
正向：
Book.objects.filter(price__gt=10).values("authors__name")
# authors（子表与主表关联字段） + __（双下划线） + name（主表目标字段）
反向：
Author.objects.filter(book__price__gt=10).values("name")
# book（子表名） + __（双下划线） + price__gt=10（子表字段，条件）123456
```

## 聚合&分组查询

SQL语言中有聚合函数：Avg, Min, Max, Sum, Count，可以方便进行数据统计；在ORM中，QuerySet的**`aggregate()`**方法对此提供了支持，它返回一个统计结果的键值对。下面我们看看如何使用，
基本格式：`QuerySet.aggregate(func(field))`
例1 查询某作家出版书籍的价格总和

```
>>> from django.db.models import Avg, Sum, Min, Max, Count # 导入聚合函数
>>> Book.objects.filter(authors__name='鲁迅').aggregate(Sum('price'))
{'price__sum': Decimal('39.90')}
# orm会根据字段和和聚合函数自动拼接键，值是聚合值；
# 也可以自定义key, 通过如下方式：
QuerySet.aggregate('your key' = Sum(field))123456
```

如果要统计多个作者，那就要用到**分组查询**，QuerySet的**`anotate()`**方法对此提供了支持。
例2 每个作者出版过的书的平均价格

```
>>> from django.db.models import Avg, Sum, Min, Max, Count # 导入聚合函数
>>> Book.objects.values('authors__name').annotate(Avg('price'))
# values()根据作者名字进行分组，annotate()显示分组后的统计结果123
```

## F&Q查询

很多时候单一的关键字查询无法满足查询要求，可以使用F&和Q查询，使用前请先导入：
`from django.db.models import F, Q`

### F对字段取值

F用于取字段取值，我们来看一个例子：
对数据库中每本书的价格加10元：
`Book.objects.all.update(price=price+10)`
直接报错 NameError: name ‘price’ is not defined，提示price+10中的price未定义，取不到值。下面我们通过F对price字段取值：

```
>>> Book.objects.all().update(price=F('price')+10)
# 对应的SQL语句：
UPDATE `app_book` SET `price` = (`app_book`.`price` + 10); args=(10,)123
```

### Q组合多个查询条件

假设我们要查询某个作家，价格大于10元的书，那么`filter()`函数中通过逗号，放两个过滤条件可以实现：

```
>>> Book.objects.filter(authors__name='光绪', price__gt=10)
<QuerySet [<Book: linux>, <Book: 现代编程方法>]>
123
```

上面这个情况，逗号就是处理逻辑与。那如果要处理逻辑非，逻辑或，这些过滤条件呢？这时Q查询就可以很灵活处理：
1 将查询条件用Q包起来
2 通过：**`, & | ~`** 且，或，非，运算符来连接多个过滤条件
下面我们看栗子：
例1 查询某个作家的，或者价格大于10的书

```
>>> Book.objects.filter(Q(authors__name='光绪') | Q(price__gt=10))
<QuerySet [<Book: python>, <Book: linux>, <Book: 现代编程方法>, <Book: linux>, <Book: 苏菲的世界>, <Book: 水浒传>]>
# 光绪写的，或者价格大于10的书123
```

例2 查询非莫个作家写的，并且是某个出版社的书

```
>>> Book.objects.filter(~Q(authors__name='李白') & Q(publish__name='机械工业'))
<QuerySet [<Book: 苏菲的世界>, <Book: 水浒传>]>
# 不是李白写的，并且是由机械工业出版社出版的书123
```



### Q查询的面向对象方式

如果查询条件是一个如下的字典形式：

```
search_condictions = {'ID': [1, 2], 'hostname': ['c1.com', 'c2.com']} 1
```

分析查询逻辑：

字典中每一个元素下键对应的列表中的元素：OR

```python
Q('ID'=1) | Q('ID'=2)
Q('hostname'='c1.com') | Q('hostname'='c2.com')12
```

字典中ID与hostname – AND, 最终组合查询条件如下：

```
Q((Q('ID'=1) | Q('ID'=2)) & (Q('hostname'='c1.com') | Q('hostname'='c2.com')))1
```



下面我们用Q查询的面向对象方式：

```python
from django.db.models import Q

query = Q()

temp1 = Q()
temp1.connector = 'OR'
temp1.children.append(('ID', 1))
temp1.children.append(('ID', 2))
# 相当于：
# Q('ID'=1) | Q('ID'=2)

temp2 = Q()
temp2.connector = 'OR'
temp2.children.append(('hostname', 'c1.com'))
temp2.children.append(('hostname', 'c2.com'))
# 相当于：
# Q('hostname'='c1.com') | Q('hostname'='c2.com')

query.add(temp1, 'AND')
query.add(temp2, 'ADN')
# 相当于：
# Q((Q('ID'=1) | Q('ID'=2)) & (Q('hostname'='c1.com') | Q('hostname'='c2.com')))12345678910111213141516171819202122
```



当查询条件长度不确定时，显然我们无法通过简单的对Q进行组合来查询，那么Q查询的面向对象方式就可以发挥用处：

```python
from django.db.models import Q

query = Q()

for k, v in search_condictions.items():
    # k: AND;  for i in v: OR
    temp = Q()
    temp.connector = 'OR'
    for i in v:
        temp.children.append((k, i))
    query.add(temp, 'AND')

res = models.Server.objects.filter(query).all()12345678910111213
```

# 多表查询和表创建总结

## 多表查询：正向查询用字段，反向查询用表名（小写）

1. 一对一关系：

    ```python
    # 正向：
    
    b_obj = a_obj.field
    
    # 反向：因为是一对一，所有查询出来只有一个，不需要_set
    
    a_obj = b_obj.model12345678
    ```

2. 一对多关系：

    ```python
    # 正向：
    
    b_obj = a_obj.field
    
    # 反向：_set取到集合
    
    QuerySet_obj = b_obj.model_set.all()12345678
    ```

3. 多对多关系：

    ```python
    # 正向：
    
    QuerySet_obj = a_obj.field.all()
    
    # 反向：
    
    QuerySet_obj = b_obj.model_set.all()12345678
    ```

## 创建表：

## 多表关系的创建

```python
class Article(models.Model):
    # 自定义主键；一般不需要定义，默认会自己创建。
    nid = models.BigAutoField(primary_key=True)

    title = models.CharField(max_length=50, verbose_name='文章标题')

    # 一对一关系；to_field属性一般不用定义，orm会自动找到关联表的主键字段
    body = models.OneToOneField(verbose_name='文章内容', to='ArticleDetail', to_field='nid')

    # 一对多关系
    blog = models.ForeignKey(verbose_name='所属博客', to='Blog', to_field='nid')

    # 多对多关系；默认自动创建第三张表，通过定义through和through_fields属性，来手动定义多对多关系。如果需要操作第三张表，选择手动定义。
    tags = models.ManyToManyField(
        to="Tag",
        through='Article2Tag',
        through_fields=('article', 'tag'),
    )

    # 静态字段
    type_choices = [
        (1, "Python"),
        (2, "Linux"),
        (3, "OpenStack"),
        (4, "GoLang"),
    ]

    article_type_id = models.IntegerField(choices=type_choices, default=None)

# 手动创建多对多关联表
class Article2Tag(models.Model):
    nid = models.AutoField(primary_key=True)
    article = models.ForeignKey(verbose_name='文章', to="Article", to_field='nid')
    tag = models.ForeignKey(verbose_name='标签', to="Tag", to_field='nid')

    class Meta:
        unique_together = [
            ('article', 'tag'),
        ]123456789101112131415161718192021222324252627282930313233343536373839
```

说明：表中出现静态字段作为choices源的字段，存的值是Integer，如果想获取对应的文本，使用:

`obj.get_field_display()`即可显示，省去自己写循环判断的麻烦。对于这里来说，field是article_type_id

## 本表和本表的关系

### 自引用一对多

```python
class Menu(models.Model):
    """
    菜单
    """
    title = models.CharField(verbose_name='菜单名称', max_length=32, unique=True)
    parent = models.ForeignKey(verbose_name='父级菜单', to="Menu", null=True, blank=True)
    # 定义本表的自引用一对多关系
    # blank=True 意味着在后台管理中填写可以为空，根菜单没有父级菜单
123456789
class Customer(models.Model):
    """
    客户表
    """
    name = models.CharField(verbose_name='姓名', max_length=16)
    gender_choices = ((1, '男'), (2, '女'))
    gender = models.SmallIntegerField(verbose_name='性别', choices=gender_choices)

    referral_from = models.ForeignKey(
        'self',  # 与本表的自引用一对多
        blank=True,
        null=True,
        verbose_name="转介绍自客户",
        help_text="若此客户是转介绍自内部会员,请在此处选择会员姓名",
        related_name="internal_referral"
    )
    # related_name定义反向引用关系，通过该字段直接查找，而不用反向查找。1234567891011121314151617
```

### 自引用多对多，比如用户互相关注

```python
class UserInfo(AbstractUser):
    """
    用户信息
    """
    nid = models.BigAutoField(primary_key=True)
    nickname = models.CharField(verbose_name='昵称', max_length=32)

    fans = models.ManyToManyField(verbose_name='粉丝们',
                                  to='UserInfo',
                                  through='UserFans',
                                  through_fields=('user', 'follower'))


class UserFans(models.Model):
    """
    互粉关系表
    """
    nid = models.AutoField(primary_key=True)
    user = models.ForeignKey(verbose_name='用户', to='UserInfo', to_field='nid', related_name='users')
    follower = models.ForeignKey(verbose_name='粉丝', to='UserInfo', to_field='nid', related_name='followers')

    class Meta:
        unique_together = [
            ('user', 'follower'),
        ]12345678910111213141516171819202122232425
```

## 继承自带用户表

Django自带一张用户表，其中提供了很多字段，包括密文密码。而用户自定义的用户表密码是明文的，如果需要使用Django自带用户表的特性。可以继承自带的用户表。

1. 配置settings.py

    ```python
    AUTH_USER_MODEL='app.UserInfo' # app名 加 表名1
    ```

2. 继承AbstractUser表后，自带用户表中的所有字段可用，并且可以定义其它字段。

    ```python
    from django.contrib.auth.models import AbstractUser
    
    class UserInfo(AbstractUser):
        """
        用户信息
        """
        pass
    ```