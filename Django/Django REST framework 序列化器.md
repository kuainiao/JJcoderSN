# Django REST framework 序列化器

------

源代码：serializers.py

DRF的序列化器类的继承关系如下图所示：

![1557298830443](Untitled.assets/1557298830443.png)

# 一、Serializer

> 对于Serializer类，是比较底层和基础，可定制程度最高的类，需要编写代码量最大的继承方式，当你需要高度定制DRF的序列化器的时候选择它，否则请选择后面的类！

序列化器一边把像查询集queryset和模型实例instance这样复杂的基于Django自定义的数据类型转换为可以轻松渲染成`JSON`，`XML`或其他内容类型的互联网通用的交换语言，让不知道后端到底是什么的前端能够轻松的解析数据内容，而不至于摸瞎。另一边，序列化器还提供反序列化功能，在验证前端传入过来的数据之后，将它们转换成Django使用的模型实例等复杂数据类型，从而使用ORM与数据库进行交互，也就是CRUD。

序列化器存在的核心原因是`前后端分离`，前端不知道后端，后端又无法定义前端。为了数据交换，只好都说json话，都将自己的内容翻译成json格式。然而对于前端，json属于自带，对于后端，则需要使用序列化器将Django自定义的数据类型转换成json格式。（当然，也可以是别的格式。）

事实上Django本身也自带序列化功能的，参考http://www.liujiangblog.com/course/django/171，只不过这里的序列化器不是专门为了前后端分离和API开发的，功能较弱。

REST framework中的serializers与Django的`Form`和`ModelForm`类非常像。DRF提供了一个最底层最基础的`Serializer`类，它类似Django的Form类，为我们提供了强大的通用方法来控制响应的输出。以及一个`ModelSerializer`类，类似Django的`ModelForm`类，为创建用于处理模型实例和查询集的序列化程序提供了快捷实现方式，但可自定义程度较低。

## 声明序列化器

让我们从创建一个简单的对象开始，我们可以使用下面的例子：

注意，下面是一个原生的Python类，而不是Django的model类，这里介绍的是序列化器的初步原理，不是最终做法：

```
from datetime import datetime

class Comment(object):
    def __init__(self, email, content, created=None):
        self.email = email
        self.content = content
        self.created = created or datetime.now()

comment = Comment(email='leila@example.com', content='foo bar')
```

下面声明一个序列化器，可以使用它来序列化和反序列化`Comment`对象。

声明一个序列化器在代码结构上看起来非常像声明一个Django的Form类：

```
from rest_framework import serializers

class CommentSerializer(serializers.Serializer):
    email = serializers.EmailField()
    content = serializers.CharField(max_length=200)
    created = serializers.DateTimeField()
```

## 序列化对象

现在，我们可以用`CommentSerializer`类去序列化一个comment对象或多个comment的列表。同样，使用`Serializer`类看起来很像使用`Form`类。

```
serializer = CommentSerializer(comment)
serializer.data
# {'email': 'leila@example.com', 'content': 'foo bar', 'created': '2016-01-27T15:17:10.375877'}
```

这样，我们就将一个comment实例转换为了Python原生的数据类型，看起来似乎是个字典类型，但type一下却不是。为了完成整个序列化过程，我们还需要使用渲染器将数据转化为成品`json`格式。

```
from rest_framework.renderers import JSONRenderer

json = JSONRenderer().render(serializer.data)
json
# b'{"email":"leila@example.com","content":"foo bar","created":"2016-01-27T15:17:10.375877"}'
```

注意结果里的`b`，在Python里，这表示Bytes类型，是Python3以后的数据传输格式。

## 反序列化对象

反序列化的过程大体类似，但差别还是不小。首先，为了举例方便我们将一个流解析为Python原生的数据类型，实际过程中不会有这种多此一举的做法：

```
import io
from rest_framework.parsers import JSONParser

stream = io.BytesIO(json)
data = JSONParser().parse(stream)
```

...然后我们将这些原生数据类型恢复到已验证数据的字典中。

```
serializer = CommentSerializer(data=data)
serializer.is_valid()
# True
serializer.validated_data
# {'content': 'foo bar', 'email': 'leila@example.com', 'created': datetime.datetime(2012, 08, 22, 16, 20, 09, 822243)}
```

注意：依然是调用CommentSerializer类的构造函数，但是给data参数传递数据，而不是第一位置参数，这表示反序列化过程。其次，数据有一个验证过程`is_valid()`。

这个步骤做完，只是从json变成了原生的Python数据类型，还不是前面自定义的Comment类的对象。

## 保存实例

如果我们想要返回基于验证数据的完整对象实例，我们需要实现`.create()`或者`update()`方法。例如：

```
class CommentSerializer(serializers.Serializer):
    email = serializers.EmailField()
    content = serializers.CharField(max_length=200)
    created = serializers.DateTimeField()

    def create(self, validated_data):
        return Comment(**validated_data)

    def update(self, instance, validated_data):
        instance.email = validated_data.get('email', instance.email)
        instance.content = validated_data.get('content', instance.content)
        instance.created = validated_data.get('created', instance.created)
        return instance
```

上面的两个方法在其继承关系中的父类里定义了具体的参数形式，`instance`和`validated_data`都是由继承体系里定义了的，分别表示要返回的Comment对象和经过验证的数据。

如果你的对象实例，比如这里的Comment对象，假设它对应了某个Django的模型，你还需要将这些对象通过Django的ORM保存到数据库中。具体的方法如下所示：

```
    def create(self, validated_data):
        return Comment.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance.email = validated_data.get('email', instance.email)
        instance.content = validated_data.get('content', instance.content)
        instance.created = validated_data.get('created', instance.created)
        instance.save()
        return instance
```

相比普通的Python的Comment类，对Django模型的保存多了一些ORM操作，比如save()方法。

等等，前面所作的改进只是在serializer层面的代码逻辑实现，在对应的视图操作中，我们还需要调用save()方法：

```
serializer = CommentSerializer(data=data)
serializer.is_valid()
# True
serializer.validated_data
# {'content': 'foo bar', 'email': 'leila@example.com', 'created': datetime.datetime(2012, 08, 22, 16, 20, 09, 822243)}
comment = serializer.save()  # if serializer.is_valid()
```

调用`.save()`方法将创建新实例或者更新现有实例，具体取决于实例化序列化器类的时候是否传递了一个现有实例：

```
# 这样的情况下.save() 将创建一个新实例
serializer = CommentSerializer(data=data)

# 这样将更新已有的comment实例
serializer = CommentSerializer(comment, data=data)
```

原则上`.create()`和`.update()`方法都是可选的。你可以根据你的序列化器类的用例不实现、实现它们之一或都实现，随你。但是新手，请千万不要随意。

#### 传递附加属性到`.save()`

有时你会希望你的视图代码能够在保存实例时注入额外的数据。此额外数据可能是当前用户，当前时间或不是请求数据一部分的其他信息。

你可以通过在调用`.save()`时添加其他关键字参数来执行此操作。例如：

```
serializer.save(owner=request.user)
```

在`.create()`或`.update()`被调用时，所有其他的关键字参数将被包含在`validated_data`参数中。

#### 重写`.save()`方法

在某些情况下`.create()`和`.update()`方法可能无意义。例如在联系人名单中，我们可能不会创建新的实例，而是发送电子邮件或其他消息。

在这些情况下，你可以选择直接重写`.save()`方法，也许更可读和有意义。

例如：

```
class ContactForm(serializers.Serializer):
    email = serializers.EmailField()
    message = serializers.CharField()

    def save(self):
        email = self.validated_data['email']
        message = self.validated_data['message']
        send_email(from=email, message=message)
```

请注意在上述情况下，我们需要直接访问serializer的`.validated_data`属性，因为没有写create或者update方法，没人给你传递`validated_data`参数，只能从self里面自己取。

重写save方法的例子给我们自定义保存数据做了个很好的演示，活学活用，会有很大的惊喜。

## 验证

反序列化数据的时候，你需要先调用`is_valid()`方法，然后再尝试去访问经过验证的数据或保存对象实例。如果发生任何验证错误，`.errors`属性将包含错误消息，以字典的格式。例如：

```
serializer = CommentSerializer(data={'email': 'foobar', 'content': 'baz'})
serializer.is_valid()
# False
serializer.errors
# {'email': ['Enter a valid e-mail address.'], 'created': ['This field is required.']}
```

字典里的每一个键都是字段名称，值是与该字段对应的错误消息的字符串列表。`non_field_errors`键可能存在，它将列出任何一般验证错误信息。`non_field_errors`的名称可以通过REST framework设置中的`NON_FIELD_ERRORS_KEY`来自定义。 当对对象列表进行序列化时，返回的错误是每个反序列化项的字典列表。

#### 内置无效数据的异常

`.is_valid()`方法具有`raise_exception`异常标志，如果存在验证错误将会抛出一个`serializers.ValidationError`异常。

这些异常由REST framework提供的默认异常处理程序自动处理，默认情况下将返回`HTTP 400 Bad Request`响应。

```
# Return a 400 response if the data was invalid.
serializer.is_valid(raise_exception=True)
```

#### 字段级别的验证

你可以通过向你的`Serializer`子类中添加`.validate_`方法来指定自定义字段级别的验证。类似于Django表单中的`.clean_`方法。

这些方法采用单个参数，即需要验证的字段值。

`validate_`方法应该返回一个验证过的数据或者抛出一个`serializers.ValidationError`异常。例如：

```
from rest_framework import serializers

class BlogPostSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=100)
    content = serializers.CharField()

    def validate_title(self, value):
        """
        这个例子检查博客是否和django有关。
        """
        if 'django' not in value.lower():
            raise serializers.ValidationError("Blog post is not about Django")
        return value
```

------

**注意：** 如果你在序列化器中声明``的时候带有`required=False`参数，并且未给该字段提供参数，那么这个验证步骤不会执行。

------

#### 对象级别的验证

要执行需要访问多个字段的任何其他验证，请添加一个`.validate()`方法到你的`Serializer`子类中。这个方法使用包含各个字段值的字典作为单个参数，错误情况下应该抛出一个 `ValidationError`异常，正常情况下应该返回经过验证的值。例如：

```
from rest_framework import serializers

class EventSerializer(serializers.Serializer):
    description = serializers.CharField(max_length=100)
    start = serializers.DateTimeField()
    finish = serializers.DateTimeField()

    def validate(self, data):
        """
        检查开始时间是在结束时间之前。
        """
        if data['start'] > data['finish']:
            raise serializers.ValidationError("finish must occur after start")
        return data
```

#### 验证器参数

还可以通过在字段上声明验证器参数的方式为字段设置指定的验证器，例如：

```
def multiple_of_ten(value):
    if value % 10 != 0:
        raise serializers.ValidationError('Not a multiple of ten')

class GameRecord(serializers.Serializer):
    score = IntegerField(validators=[multiple_of_ten])
    ...
```

注意上面给参数提供了一个列表值，这说明可以同时使用多个验证器。

序列化器类还可以设置应用于一组字段的可重用的验证器。这些验证器要在内部的`Meta`类中声明，如下所示：

```
class EventSerializer(serializers.Serializer):
    name = serializers.CharField()
    room_number = serializers.IntegerField(choices=[101, 102, 103, 201])
    date = serializers.DateField()

    class Meta:
        # Each room only has one event per day.
        validators = UniqueTogetherValidator(
            queryset=Event.objects.all(),
            fields=['room_number', 'date']
        )
```

有专门的验证器章节，详细介绍这一部分内容。

## 访问初始数据和实例

将初始化对象或者查询集传递给序列化实例时，可以通过`.instance`访问原始对象。如果没有传递初始化对象，那么`.instance`属性值将是`None`。（正向，即序列化方向）

将数据传递给序列化器实例时，未修改的数据可以通过`.initial_data`获取。如果没有传递data关键字参数，那么`.initial_data`属性不存在。（反向，即反序列化方向）

## 部分更新

默认情况下，序列化器必须传递所有必填字段的值，否则就会引发验证错误。但是我们可以将 `partial`参数指定为True，来允许部分更新，而不至于产生错误，这很重要。

```
# 使用部分数据更新`comment` 
serializer = CommentSerializer(comment, data={'content': 'foo bar'}, partial=True)
```

## 处理关系对象

前面的实例适用于处理只有简单数据类型的对象，但是有时候我们也需要表示更复杂的对象，其中对象的某些属性可能不是字符串、日期、整数这样简单的数据类型。

`Serializer`类本身也是一种`Field`，并且可以用来表示一个对象嵌套在另一个对象中的关系。也就是处理Django模型中的关系类型，一对一、多对一、多对多的字段。

```
class UserSerializer(serializers.Serializer):
    email = serializers.EmailField()
    username = serializers.CharField(max_length=100)

class CommentSerializer(serializers.Serializer):
    user = UserSerializer()
    content = serializers.CharField(max_length=200)
    created = serializers.DateTimeField()
```

如果嵌套字段可以接收 `None`值，也就是关联的对象可以为空，应该将 `required=False`标志传递给嵌套的序列化器。

```
class CommentSerializer(serializers.Serializer):
    user = UserSerializer(required=False)  # 有可能未登录
    content = serializers.CharField(max_length=200)
    created = serializers.DateTimeField()
```

类似的，如果嵌套的关联字段可以接收一个列表，那么应该将`many=True`标志传递给嵌套的序列化器。也就是多对一外键和多对多关系的处理方式。

```
class CommentSerializer(serializers.Serializer):
    user = UserSerializer(required=False)
    edits = EditItemSerializer(many=True)  # edit'项的嵌套列表
    content = serializers.CharField(max_length=200)
    created = serializers.DateTimeField()
```

## 关系字段数据的验证

当我们在处理包含关系字段的序列化过程中，如果关联字段的值不合法，同样会被检测出来，并且将错误信息保存在相应的位置，如下例，CommentSerializer中的user字段关联到auth的User表，但是提供了一个不合法的邮箱地址，sorry，你不能成功反序列化，DRF给出了明确的错误信息。类似的，`.validated_data` 属性也将包括关系字段的数据结构。

```
serializer = CommentSerializer(data={'user': {'email': 'foobar', 'username': 'doe'}, 'content': 'baz'})
serializer.is_valid()
# False
serializer.errors
# {'user': {'email': ['Enter a valid e-mail address.']}, 'created': ['This field is required.']}
```

#### 为关系字段编写`.create()`方法

如果你对Django的ORM系统理解比较深刻，那么本章节的很多内容都能轻松理解。这些方法其实都是在打通序列化器和Django的ORM系统之间的通道。

对于关系型字段，我们需要编写`.create()`或`.update()`处理保存多个对象的方法。

下面的示例演示如何处理创建一个具有关联的概要信息对象的用户。

```
class UserSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()

    class Meta:
        model = User
        fields = ('username', 'email', 'profile')

    def create(self, validated_data):
        profile_data = validated_data.pop('profile')
        user = User.objects.create(**validated_data)
        Profile.objects.create(user=user, **profile_data)
        return user
```

官网的这个例子不太恰当，因为这里还没有讲解ModelSerializer，我们暂且放过它。重点是UserSerializer类内部的create方法。其代码的核心是，我们需要为关联的profile字段编写如何保存Profile对象的ORM语句！

#### 为关系字段定义`.update()`方法

对于更新，你需要仔细考虑如何处理关联字段的更新。 例如，如果关联字段的值是`None`，或者没有提供，那么会发生下面哪种情况？

- 在数据库中将关联字段设置成`NULL`。
- 删除关联的实例。
- 忽略数据并保留这个实例。
- 抛出验证错误。

下面是我们之前`UserSerializer`类中`update()`方法的一个例子。

```
    def update(self, instance, validated_data):
        profile_data = validated_data.pop('profile')
        # Unless the application properly enforces that this field is
        # always set, the follow could raise a `DoesNotExist`, which
        # would need to be handled.
        profile = instance.profile

        instance.username = validated_data.get('username', instance.username)
        instance.email = validated_data.get('email', instance.email)
        instance.save()

        profile.is_premium_member = profile_data.get(
            'is_premium_member',
            profile.is_premium_member
        )
        profile.has_support_contract = profile_data.get(
            'has_support_contract',
            profile.has_support_contract
         )
        profile.save()

        return instance
```

时刻记住，update里的代码如何写，要根据你的业务逻辑来编写，不要忘了调用save方法，或者弹出异常。

因为关系字段的创建和更新行为可能不明确，并且可能需要关联模型间的复杂依赖关系，DRF从3.x版本后要求你始终明确的定义这些方法。并且，默认的`ModelSerializer` 类的`.create()`和`.update()`方法不包括对关联字段的支持，需要你自己实现，或者需求第三方模块的支持。

#### 使用模型管理类保存关联对象

在序列化器中保存多个相关实例的另一种方法是编写处理创建正确实例的自定义模型管理器类，也就是Django原生的`models.Manager`。

例如，假设我们想确保`User`实例和`Profile`实例总是作为一对一起创建。我们可能会写一个类似这样的自定义管理器类：

```
class UserManager(models.Manager):
    ...

    def create(self, username, email, is_premium_member=False, has_support_contract=False):
        user = User(username=username, email=email)
        user.save()
        profile = Profile(
            user=user,
            is_premium_member=is_premium_member,
            has_support_contract=has_support_contract
        )
        profile.save()
        return user
```

这个管理器类现使得用户实例和用户信息实例总是在同一时间创建。我们在序列化器类上的`.create()`方法现在可以用新的管理器方法重写一下。

```
def create(self, validated_data):
    return User.objects.create(
        username=validated_data['username'],
        email=validated_data['email']
        is_premium_member=validated_data['profile']['is_premium_member']
        has_support_contract=validated_data['profile']['has_support_contract']
    )
```

有关此方法的更多详细信息，请参阅Django文档中的 [模型管理器](https://docs.djangoproject.com/en/stable/topics/db/managers/)

## 处理多个对象

`Serializer`类还可以序列化或反序列化对象的列表。

#### 同时序列化多个对象

为了能够序列化一个查询集或者一个对象列表而不是一个单独的对象，需要在实例化序列化器类的时候传一个`many=True`参数。这样就能序列化一个查询集或一个对象列表。

```
queryset = Book.objects.all()
serializer = BookSerializer(queryset, many=True)
serializer.data
# [
#     {'id': 0, 'title': 'The electric kool-aid acid test', 'author': 'Tom Wolfe'},
#     {'id': 1, 'title': 'If this is a man', 'author': 'Primo Levi'},
#     {'id': 2, 'title': 'The wind-up bird chronicle', 'author': 'Haruki Murakami'}
# ]
```

**反序列化过程中默认支持多个对象的创建，但是不支持多个对象的同时更新。**

有关如何支持或自定义这些情况的更多信息，请查阅ListSerializer类。

## 附加额外的上下文

在某些情况下，除了要序列化的对象之外，还需要为序列化程序提供额外的上下文。一个常见的情况是，如果你使用包含超链接关系的序列化程序，这需要序列化器能够访问当前的请求以便正确生成完全限定的URL。

可以在实例化序列化器的时候传递一个`context`参数来传递任意的附加上下文。例如：

```
serializer = AccountSerializer(account, context={'request': request})
serializer.data
# {'id': 6, 'owner': 'denvercoder9', 'created': datetime.datetime(2013, 2, 12, 09, 44, 56, 678870), 'details': 'http://example.com/accounts/6/details'}
```

这个上下文字典可以在任何序列化器字段的中使用，例如`.to_representation()`方法中可以通过访问`self.context`属性获取上下文字典。

------

# 二、 ModelSerializer

> 注：更高一级的封装，更少的代码，但也更低的可定制性

类似Django原生的ModelForm对model的引用。

`ModelSerializer`类能够让你自动创建一个具有模型中相应字段的`Serializer`类。

**`ModelSerializer`类直接继承了`Serializer`类，不同的是**：

- 它根据model模型的定义，自动生成默认字段。
- 它自动生成序列化器的验证器，比如unique_together验证器。
- 它实现了简单的`.create()`方法和`.update()`方法。

声明一个`ModelSerializer`类的方法如下：

```
class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ('id', 'account_name', 'users', 'created')
```

默认情况下，所有的Django模型的字段都将映射到序列化器上相应的字段。（请抛弃本章节一开始对普通Python类的序列化概念，以下都是针对Django的模型相关。）

**模型中所有的关系字段比如外键都将映射成`PrimaryKeyRelatedField`字段。**

默认情况下不包括反向关联，除非像serializer relations文档中规定的那样显式包含。

如果你想确定ModelSerializer自动创建了哪些字段和验证器，可以打开Django shell。

执行 `python manage.py shell`，导入序列化器类，实例化它，并打印对象的表示：

```
>>> from myapp.serializers import AccountSerializer
>>> serializer = AccountSerializer()
>>> print(repr(serializer))
AccountSerializer():
    id = IntegerField(label='ID', read_only=True)
    name = CharField(allow_blank=True, max_length=100, required=False)
    owner = PrimaryKeyRelatedField(queryset=User.objects.all())
```

核心是这个`repr(serializer)`，在ModelSerializer中有专门的实现代码。事实上，你直接print也行，这些都是Python的特性。

## 指定要包括的字段

如果你希望在模型序列化器中只使用默认字段的一部分，你可以使用`fields`或`exclude`选项来执行此操作，就像使用`ModelForm`一样。强烈建议你使用`fields`属性显式的设置要序列化的字段。这样就不太可能因为你修改了模型而无意中暴露了数据。

例如：

```
class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ('id', 'account_name', 'users', 'created')
```

你还可以将`fields`属性设置成`'__all__'`来表明使用模型中的所有字段。

例如：

```
class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = '__all__'
```

你可以将`exclude`属性设置成一个从序列化器中排除的字段列表。

例如：

```
class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        exclude = ('users',)
```

在上面的例子中，如果`Account`模型有三个字段`account_name`，`users`和`created`，那么只有 `account_name`和`created`会被序列化。

在`fields`和`exclude`属性中的名称，通常会映射到模型类中的模型字段。

`fields`选项中的名称也可以映射到模型类中不存在任何参数的属性或方法。

最后，思考一个问题，如果序列化器没有映射Django模型中的必填字段，会发生什么？废话，肯定是出错呀，缺少了必填的字段的内容，Django的ORM怎么操作数据库的读写？所以，这里的fields和exclude要慎用，过度的浪就会浪出坑。

## 关系字段的序列化深度

`ModelSerializer`默认使用主键进行对象关联，但是你也可以使用`depth`选项轻松生成嵌套关联：

```
class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ('id', 'account_name', 'users', 'created')
        depth = 1
```

`depth`选项应该设置一个整数值，表明应该遍历的关联深度。

如果要自定义序列化的方式你需要自定义该字段。

## 明确指定字段

觉得全自动的字段不满足需求，也可以轻度定制，这就向基础的Serializer类靠拢了一点。

可以通过在`ModelSerializer`类上显式声明字段来增加额外的字段或者重写默认的字段，就和在`Serializer`类一样的。

```
class AccountSerializer(serializers.ModelSerializer):
    url = serializers.CharField(source='get_absolute_url', read_only=True)
    groups = serializers.PrimaryKeyRelatedField(many=True)

    class Meta:
        model = Account
```

额外的字段可以对应模型上任何属性或可调用的方法。

## 指定只读字段

你可能希望将某些字段指定为只读，而不是显式的逐一为每个字段添加`read_only=True`属性，这种情况你可以使用Meta的`read_only_fields`选项。

该选项应该是字段名称的列表或元组，并像下面这样声明：

```
class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ('id', 'account_name', 'users', 'created')
        read_only_fields = ('account_name',)
```

模型中设置`editable=False`的字段和`AutoField`字段默认被设置为只读属性，不需要额外添加到`read_only_fields`选项中。

------

**注意**: 有一种特殊情况，其中一个只读字段是模型级别`unique_together`约束的一部分。在这种情况下，序列化器需要该字段的值才能验证约束，但也是不能由用户编辑的。

处理此问题的正确方法是在序列化器上显式指定该字段，同时提供`read_only=True`和`default=…`关键字参数。

这种情况的一个例子就是对于一个和其他标识符`unique_together`的当前认证的`User`是只读的。 在这种情况下你可以像下面这样声明user字段：

```
user = serializers.PrimaryKeyRelatedField(read_only=True, default=serializers.CurrentUserDefault())
```

------

## 附加关键字参数

还可以通过使用`extra_kwargs`选项快捷地在字段上指定任意附加的关键字参数。这个选项是一个将具体字段名称当作键值的字典。例如：

```
class CreateUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('email', 'username', 'password')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User(
            email=validated_data['email'],
            username=validated_data['username']
        )
        user.set_password(validated_data['password'])
        user.save()
        return user
```

## 关系字段

在序列化模型实例的时候，你可以选择多种不同的方式来表示关联关系。对于`ModelSerializer`默认是使用相关实例的主键，也就是PrimaryKeyRelatedField。

替代的其他方法包括使用超链接序列化、序列化完整的嵌套表示或者使用自定义表示的序列化。

更多详细信息请查阅serializer relations章节

## 自定义字段映射

ModelSerializer类还暴露了一个可以覆盖的API，以便在实例化序列化器时改变序列化器字段的自动确定方式。

通常情况下，如果`ModelSerializer`没有生成默认情况下你需要的字段，那么你应该将它们显式地添加到类中，或者直接使用常规的`Serializer`类。但是在某些情况下，你可能需要创建一个新的基类，定义任意模型创建序列化字段的方式。

- `.serializer_field_mapping`

将Django model的字段类型映射到REST framework serializer的字段类型。你可以覆写这个映射。

- `.serializer_related_field`

用于关联对象的字段类型。

对于`ModelSerializer`此属性默认是`PrimaryKeyRelatedField`。

对于`HyperlinkedModelSerializer`此属性默认是`serializers.HyperlinkedRelatedField`。

- `serializer_url_field`

```
url`类型的字段类。默认是 `serializers.HyperlinkedIdentityField
```

- `serializer_choice_field`

选择类型的字段类。默认是`serializers.ChoiceField`

### The field_class和field_kwargs API

调用下面的方法来确定应该自动包含在序列化器类中每个字段的类和关键字参数。这些方法都应该返回 `(field_class, field_kwargs)`元组。

- `.build_standard_field(self, field_name, model_field)`

调用后生成对应标准模型字段的序列化器字段。

默认实现是根据`serializer_field_mapping`属性返回一个序列化器类。

- `.build_relational_field(self, field_name, relation_info)`

调用后生成对应关联模型字段的序列化器字段。

默认实现是根据`serializer_relational_field`属性返回一个序列化器类。

这里的`relation_info`参数是一个命名元组，包含`model_field`，`related_model`，`to_many`和`has_through_model`属性。

- `.build_nested_field(self, field_name, relation_info, nested_depth)`

当`depth`选项被设置时，被调用后生成一个对应到关联模型字段的序列化器字段。

默认实现是动态的创建一个基于`ModelSerializer`或`HyperlinkedModelSerializer`的嵌套的序列化器类。

`nested_depth`的值是`depth`的值减1。

`relation_info`参数是一个命名元组，包含 `model_field`，`related_model`，`to_many`和`has_through_model`属性。

- `.build_property_field(self, field_name, model_class)`

被调用后生成一个对应到模型类中属性或无参数方法的序列化器字段。

默认实现是返回一个`ReadOnlyField`类。

- `.build_url_field(self, field_name, model_class)`

被调用后为序列化器自己的`url`字段生成一个序列化器字段。默认实现是返回一个`HyperlinkedIdentityField`类。

- `.build_unknown_field(self, field_name, model_class)`

当字段名称没有对应到任何模型字段或者模型属性时调用。 默认实现会抛出一个错误，尽管子类可能会自定义该行为。

------

# 三、 HyperlinkedModelSerializer

> 进一步封装了ModelSerializer类，并且自动多出了一个`url`字段

`HyperlinkedModelSerializer`类直接继承`ModelSerializer`类，不同之处在于它使用超链接来表示关联关系而不是主键。

默认情况下，HyperlinkedModelSerializer序列化器将包含一个`url`字段而不是主键字段。

url字段将使用`HyperlinkedIdentityField`字段来表示，模型的任何关联都将使用`HyperlinkedRelatedField`字段来表示。

你可以通过将主键添加到`fields`选项中来显式的包含主键字段，例如下面的`id`：

```
class AccountSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Account
        fields = ('url', 'id', 'account_name', 'users', 'created')
```

这个类的源代码非常简单：

```
class HyperlinkedModelSerializer(ModelSerializer):
    # 下面这句是核心
    serializer_related_field = HyperlinkedRelatedField

    def get_default_field_names(self, declared_fields, model_info):
        # 覆写了ModelSerializer中的方法，在第一个变量处发生了变化，使用了url名字。
        return (
            [self.url_field_name] +
            list(declared_fields) +
            list(model_info.fields) +
            list(model_info.forward_relations)
        )

    def build_nested_field(self, field_name, relation_info, nested_depth):
        # 覆写了ModelSerializer中的方法，嵌套的子类依然继承的是HyperlinkedModelSerializer
        class NestedSerializer(HyperlinkedModelSerializer):
            class Meta:
                model = relation_info.related_model
                depth = nested_depth - 1
                fields = '__all__'

        field_class = NestedSerializer
        field_kwargs = get_nested_relation_kwargs(relation_info)

        return field_class, field_kwargs
```

## 绝对和相对URL

当实例化一个`HyperlinkedModelSerializer`时，你必须在序列化器的上下文中包含当前的`request`值，例如：

```
serializer = AccountSerializer(queryset, context={'request': request})
```

因为我们需要生成url字段的内容，需要request里关于请求的url路径信息，这样做将确保超链接可以包含恰当的主机名，生成完整的url路径，如下面的：

```
http://api.example.com/accounts/1/
```

而不是相对的URL，例如：

```
/accounts/1/
```

如果你真的要使用相对URL，你应该明确的在序列化器上下文中传递一个`{'request': None}`参数，而不是忽略不写。

## 如何确定超链接视图

我们为什么要使用超链接的序列化器？因为默认的主键字段只是冰冷的数字id，也就是1，2，3等等，在前端你无法知道它具体的含义。使用超链接则返回的是对应对象的url访问地址，是可以点击跳转直达的，更加形象。

既然是点击跳转可以直达，那么就需要确定哪些视图能应用超链接到模型实例的方法，否则没有对应的视图来处理这些链接的请求，就会404了。

默认情况下，超链接期望对应到一个样式能匹配`'{model_name}-detail'`的视图，并通过`pk`关键字参数查找实例。

但是如果你想自己玩点花样，那么可以通过在`extra_kwargs`中设置`view_name`和`lookup_field`中的一个或两个来重写URL字段视图名称和查询字段。如下所示：

```
class AccountSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Account
        fields = ('account_url', 'account_name', 'users', 'created')
        extra_kwargs = {
            'url': {'view_name': 'accounts', 'lookup_field': 'account_name'},
            'users': {'lookup_field': 'username'}
        }
```

或者你可以显式的设置序列化器上的字段。例如：

```
class AccountSerializer(serializers.HyperlinkedModelSerializer):
    url = serializers.HyperlinkedIdentityField(
        view_name='accounts',
        lookup_field='slug'
    )
    users = serializers.HyperlinkedRelatedField(
        view_name='user-detail',
        lookup_field='username',
        many=True,
        read_only=True
    )

    class Meta:
        model = Account
        fields = ('url', 'account_name', 'users', 'created')
```

------

**提示**：正确匹配超链接表示和你的URL配置有时可能会有点困难。打印一个`HyperlinkedModelSerializer`实例的`repr`是一个特别有用的方式来检查关联关系映射的那些视图名称和查询字段。

------

## 更改URL字段名称

URL字段的名称默认为`'url'`。你可以在settings.py中修改`URL_FIELD_NAME`配置项进行全局性修改。

------

# 四、 ListSerializer

> 与前三者不同，ListSerializer继承的是BaseSerializer，属于Serializer的兄弟

`ListSerializer`类能够一次性序列化和验证多个对象。我们通常不要直接使用`ListSerializer`，而是应该在实例化一个序列化器时简单地传递一个`many=True`参数。

当一个序列化器在带有`many=True`选项被序列化时，实际将创建一个`ListSerializer`类的实例。该序列化器类将成为`ListSerializer`类的子类。

可以传递一个`allow_empty`参数给`ListSerializer`序列化器。这个参数的默认值是`True`，但是如果你不想把空列表当作有效输入的话可以把它设置成`False`。

### 自定义`ListSerializer`行为

碰到下面的情况，你可能需要自定制`ListSerializer`的一些行为：

- 希望提供列表的特定验证，例如检查一个元素是否与列表中的另外一个元素冲突。
- 想自定义多个对象的创建或更新行为。

对于这些情况，当你可以通过使用序列化器类的`Meta`类下面的`list_serializer_class`选项来修改当`many=True`时正在使用的类。

也就是说这个时候你必须写一个继承了serializers.ListSerializer类的子类，然后在需要用它的序列化器类的Meta中添加`list_serializer_class`条目。

例如：

```
class CustomListSerializer(serializers.ListSerializer):
    ...

class CustomSerializer(serializers.Serializer):
    ...
    class Meta:
        list_serializer_class = CustomListSerializer
```

#### 自定义多个对象的创建

默认情况下，多个对象的创建是简单的对列表中每个对象调用`.create()`方法。如果要自定义实现，那么你需要自定义当被传递`many=True`参数时使用的`ListSerializer`类中的`.create()`方法。

例如：

```
class BookListSerializer(serializers.ListSerializer):
    def create(self, validated_data):
        books = [Book(**item) for item in validated_data]
        return Book.objects.bulk_create(books)

class BookSerializer(serializers.Serializer):
    ...
    class Meta:
        list_serializer_class = BookListSerializer
```

#### 自定义多对象的更新

默认情况下，`ListSerializer`类不支持多对象的更新。这是因为插入和删除的预期行为是不明确的，每个人的业务逻辑都可能不同。

要支持多对象同时更新的话你需要自己明确地实现相关的代码。编写多时要注意以下几点：

- 如何确定数据列表中的每个元素应该对应更新哪个实例？
- 如何处理插入？它们是无效的？还是创建新对象？
- 移除应该如何处理？它们是要删除对象还是删除关联关系？它们应该被忽略还是提示无效操作？
- 排序如何处理？改变两个元素的位置是否意味着任何状态改变或者应该被忽视？

你需要向实例序列化器中显式添加一个`id`字段。默认隐式生成的`id`字段是`read_only`。这就导致它在更新时被删除。一旦你明确地声明它，它将在列表序列化器的`update`方法中可用。

下面是一个多对象更新的示例：

```
class BookListSerializer(serializers.ListSerializer):
    def update(self, instance, validated_data):
        # Maps for id->instance and id->data item.
        book_mapping = {book.id: book for book in instance}
        data_mapping = {item['id']: item for item in validated_data}

        # Perform creations and updates.
        ret = []
        for book_id, data in data_mapping.items():
            book = book_mapping.get(book_id, None)
            if book is None:
                ret.append(self.child.create(data))
            else:
                ret.append(self.child.update(book, data))

        # Perform deletions.
        for book_id, book in book_mapping.items():
            if book_id not in data_mapping:
                book.delete()

        return ret

class BookSerializer(serializers.Serializer):
    # We need to identify elements in the list using their primary key,
    # so use a writable field here, rather than the default which would be read-only.
    id = serializers.IntegerField()
    ...

    class Meta:
        list_serializer_class = BookListSerializer
```

#### 自定义ListSerializer初始化

当带有`many=True`参数的序列化器被实例化时，我们需要确定哪些参数和关键字参数应该被传递给子`Serializer`类和父类`ListSerializer`的`.__init__()`方法。

默认实现是将所有参数都传递给两个类，除了`validators`和自定义的关键字参数，这些参数都假定用于子序列化器类。

有时候，你可能需要明确指定当被传递`many=True`参数时，子类和父类应该如何实例化。你可以使用`many_init`类方法来执行此操作。

```
  @classmethod
    def many_init(cls, *args, **kwargs):
        # Instantiate the child serializer.
        kwargs['child'] = cls()
        # Instantiate the parent list serializer.
        return CustomListSerializer(*args, **kwargs)
```

------

# 五、 BaseSerializer

> 这是DRF中其它序列化器的基类，一般我们不直接使用它。所以，下面的内容看看就好，非深度用户无需了解。

`BaseSerializer` 可以简单的用来替代序列化和反序列化的样式。

`Serializer`类直接继承了BaseSerializer类，所以两者具有基本相同的API：

- `.data` - 返回传出的原始数据。
- `.is_valid()` - 反序列化并验证传入的数据。
- `.validated_data` - 返回经过验证后的传入数据。
- `.errors` - 返回验证期间的错误。
- `.save()` - 将验证的数据保留到对象实例中。

它还有可以覆写的四种方法，具体取决于你想要序列化类支持的功能：

- `.to_representation()` - 重写此方法来改变读取操作的序列化结果。
- `.to_internal_value()` - 重写此方法来改变写入操作的序列化结果。
- `.create()` 和 `.update()` - 重写其中一个或两个来改变保存实例时的动作。

因为此类提供与`Serializer`类相同的接口，所以你可以将它与现有的基于类的通用视图一起使用，就像使用常规`Serializer`或`ModelSerializer`一样。

你需要注意到的唯一区别是`BaseSerializer`类并不会在可浏览的API页面中生成HTML表单。

- 只读的 `BaseSerializer` 类

要使用`BaseSerializer`类实现只读的序列化器，我们只需要覆写`.to_representation()`方法。让我们看一个简单的Django模型的示例：

```
class HighScore(models.Model):
    created = models.DateTimeField(auto_now_add=True)
    player_name = models.CharField(max_length=10)
    score = models.IntegerField()
```

创建一个只读的序列化程序来将`HighScore`实例转换为原始数据类型非常简单。

```
class HighScoreSerializer(serializers.BaseSerializer):
    def to_representation(self, obj):
        return {
            'score': obj.score,
            'player_name': obj.player_name
        }
```

我们现在可以使用这个类来序列化单个`HighScore`实例：

```
@api_view(['GET'])
def high_score(request, pk):
    instance = HighScore.objects.get(pk=pk)
    serializer = HighScoreSerializer(instance)
    return Response(serializer.data)
```

或者使用它来序列化多个实例：

```
@api_view(['GET'])
def all_high_scores(request):
    queryset = HighScore.objects.order_by('-score')
    serializer = HighScoreSerializer(queryset, many=True)
    return Response(serializer.data)
```

- 可读写的`BaseSerializer`类

要创建一个读写都支持的序列化器，我们首先需要实现`.to_internal_value()`方法。这个方法返回用来构造对象实例的经过验证的值，如果提供的数据格式不正确，则可能引发`ValidationError`。

一旦你实现了`.to_internal_value()`方法，那些基础的验证API都会在序列化对象上可用了，你就可以使用`.is_valid()`, `.validated_data` 和 `.errors` 方法。

如果你还想支持`.save()`，你还需要实现`.create()`和`.update()`方法中的一个或两个。

下面是支持读、写操作的 `HighScoreSerializer` 完整示例:

```
class HighScoreSerializer(serializers.BaseSerializer):
    def to_internal_value(self, data):
        score = data.get('score')
        player_name = data.get('player_name')

        # Perform the data validation.
        if not score:
            raise serializers.ValidationError({
                'score': 'This field is required.'
            })
        if not player_name:
            raise serializers.ValidationError({
                'player_name': 'This field is required.'
            })
        if len(player_name) > 10:
            raise serializers.ValidationError({
                'player_name': 'May not be more than 10 characters.'
            })

        # Return the validated values. This will be available as
        # the `.validated_data` property.
        return {
            'score': int(score),
            'player_name': player_name
        }

    def to_representation(self, obj):
        return {
            'score': obj.score,
            'player_name': obj.player_name
        }

    def create(self, validated_data):
        return HighScore.objects.create(**validated_data)
```

- 创建一个新的基类

`BaseSerializer`类还可以用来创建新的通用序列化基类来处理特定的序列化样式或者用来整合备用存储后端。

下面这个类是一个可以将任意对象强制转换为基本表示的通用序列化类的示例。

```
class ObjectSerializer(serializers.BaseSerializer):
    """
    A read-only serializer that coerces arbitrary complex objects
    into primitive representations.
    """
    def to_representation(self, obj):
        for attribute_name in dir(obj):
            attribute = getattr(obj, attribute_name)
            if attribute_name('_'):
                # Ignore private attributes.
                pass
            elif hasattr(attribute, '__call__'):
                # Ignore methods and other callables.
                pass
            elif isinstance(attribute, (str, int, bool, float, type(None))):
                # Primitive types can be passed through unmodified.
                output[attribute_name] = attribute
            elif isinstance(attribute, list):
                # Recursively deal with items in lists.
                output[attribute_name] = [
                    self.to_representation(item) for item in attribute
                ]
            elif isinstance(attribute, dict):
                # Recursively deal with items in dictionaries.
                output[attribute_name] = {
                    str(key): self.to_representation(value)
                    for key, value in attribute.items()
                }
            else:
                # Force anything else to its string representation.
                output[attribute_name] = str(attribute)
```

------

# 六、 serializer高级用法

## 重写序列化和反序列化行为

如果你需要自定义序列化类的序列化、反序列化或验证过程的行为，可以通过重写`.to_representation()`或`.to_internal_value()`方法来完成。

这么做的一些原因包括......

- 为新的序列化基类添加新行为。
- 对现有的类稍作修改。
- 提高频繁访问返回大量数据的API端点的序列化性能。

这些方法的签名如下：

- `.to_representation(self, obj)`

接收一个需要被序列化的对象实例并且返回一个序列化之后的表示。通常，这意味着返回内置Python数据类型的结构。可以处理的确切类型取决于你为API配置的渲染类。这是正向过程，由后端往前端。

- `.to_internal_value(self, data)`

将未经验证的传入数据作为输入，返回可以通过`serializer.validated_data`来访问的已验证的数据。如果在序列化类上调用`.save()`，则该返回值也将传递给`.create()`或`.update()`方法。这是反向的过程，由前端数据往后端保存。

如果任何验证条件失败，那么该方法会引发一个`serializers.ValidationError(errors)`。通常，此处的`errors`参数将是错误消息字典的一个映射字段，或者是`settings.NON_FIELD_ERRORS_KEY`设置的值。

传递给此方法的`data`参数通常是`request.data`的值，因此它提供的数据类型将取决于你为API配置的解析器类。

## Serializer的继承

与Django表单类似，你可以通过继承扩展和重用序列化类。这允许你在父类上声明一组公共字段或方法，然后可以在许多序列化器中使用它们。举个例子，

```
class MyBaseSerializer(Serializer):
    my_field = serializers.CharField()

    def validate_my_field(self, value):
        ...

class MySerializer(MyBaseSerializer):
    ...
```

像Django的`Model`和`ModelForm`类一样，序列化器内部`Meta`类不会隐式地继承它的父元素内部的`Meta`类。如果你希望从父类继承`Meta`类，则必须明确地这样做。比如：

```
class AccountSerializer(MyBaseSerializer):
    class Meta(MyBaseSerializer.Meta):
        model = Account
```

但是，我们建议*不要*在内部Meta类上使用继承，而是明确声明所有选项。

此外，以下警告适用于序列化类的继承过程：

- 使用正常的Python名称解析规则。如果你有多个声明了`Meta`类的基类，则只使用第一个类。这意味要么是孩子的`Meta`（如果存在），否则就是第一个父类的`Meta`等。
- 通过在子类上将名称设置为`None`，可以声明性地删除从父类继承的`Field`。

\``` class MyBaseSerializer(ModelSerializer): my_field = serializers.CharField()

class MySerializer(MyBaseSerializer): my_field = None ```

但是，你只能使用此黑科技去掉父类显式声明定义的字段；它不会阻止`ModelSerializer`生成的默认字段。

## 动态修改字段

访问或修改序列化器的fileds属性可以动态地修改字段。这可以实现一些有趣的操作，比如在运行过程中修改某些字段的参数。

比如下面的例子：

```
class DynamicFieldsModelSerializer(serializers.ModelSerializer):
    """
    A ModelSerializer that takes an additional `fields` argument that
    controls which fields should be displayed.
    """

    def __init__(self, *args, **kwargs):
        # Don't pass the 'fields' arg up to the superclass
        fields = kwargs.pop('fields', None)

        # Instantiate the superclass normally
        super(DynamicFieldsModelSerializer, self).__init__(*args, **kwargs)

        if fields is not None:
            # Drop any fields that are not specified in the `fields` argument.
            allowed = set(fields)
            existing = set(self.fields)
            for field_name in existing - allowed:
                self.fields.pop(field_name)
```

然后你就可以进行下面的操作了：

```
>>> class UserSerializer(DynamicFieldsModelSerializer):
>>>     class Meta:
>>>         model = User
>>>         fields = ('id', 'username', 'email')
>>>
>>> print(UserSerializer(user))
{'id': 2, 'username': 'jonwatts', 'email': 'jon@example.com'}
>>>
>>> print(UserSerializer(user, fields=('id', 'email')))
{'id': 2, 'email': 'jon@example.com'}
```