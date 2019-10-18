# Django Rest Framework 教程及API向导

##  一、请求（Request）

REST_FRAMEWORK 中的 `Request`扩展了标准的HttpRequest,为 REST_FRAMEWORK增加了灵活的request解析和request认证。

- 请求

`.data`: 获取请求的主体，相当于request.POST和request.FILES

`.query_params`: request.GET的重命名

`.parsers:` APIView类或@api_view装饰将确保这个属性将自动设置为一个解析器实例列表

- 内容协商 .accepted_render: 接受渲染一个对象内容协商 .accepted_media_type: 接受的媒体类型
- 身份验证 .user: 通常返回django.contrib.auth.models.user的对象。虽然行为取决于所使用的身份验证策略。 如果请求用户没有被认证，request.user是一个django.contrib.auth.models.Anoymoser对象。 .auth: 被认证的后才会被使用，返回任何额外身份的环境。 .authenticators: APIView类或@api_view装饰将确保这个属性将自动设置为一个认证实例列表
- 浏览器增强方法

> django rest framework提供一些附加的表单提交方法:PUT,PATCH,DELETE

`.method`: 返回一个大写的HTTP请求方法字符串，包含了PUT,PATCH,DELETE等。

`.content_type`: 返回一个字符串对象代表HTTP请求的媒体类型的身体,或如果没有媒体类型提供一个空字符串。 同样可以使用：request.META.get(‘HTTP_CONTENT_TYPE’)

`.stream`: 返回一个请求主体类容的流。

- 支持其他标准的HttpResquest属性 .META/.session/等等

## 二、Response（响应）

> 你需要使用一个APIView类或@api_view函数返回response对象的views

- 创建Response `from rest_framework.response import Response` 例: `Response(data, status=None, template_name=None, headers=None, content_type=None)`
- `data`: 响应serialized(序列化)后的数据
- `status`: 定义响应状态码，默认200
- `template_name`: 如果HTMLRender被选择，返回一个模板
- `headers`: 是关于HTTP请求头的一个字典
- `content_type`: 响应内容类型，一般会根据内容自动协商。
- 其他标准的HttpResponse属性

```python
response = Response()
response[‘Cache-Control’] = ‘no-cache’
.render(): 响应序列化的数据。
```

## 三、基本视图类 (APIView/@api_view)

1. 类基础视图（APIView）

DRF不同于django常规的view类，他有如下几点优点：

- 提供了更好用的`request`对象，不同于普通的django HttpRequest更好用。
- 封装了`Response`对象，代替了原有的django HttpResponse，视图将管理内容协商并设置正确的渲染器的响应。
- 任何`APIException`异常将会被捕捉，并做适当的响应。
- 传入的请求将身份验证和适当的权限和节流检查将之前运行调度请求处理程序的方法。 一个小例子：

```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import authenication, permissions

class ListUser(APIView):
```

**展示系统中所有的用户**

- 需要令牌认证。
- 只有admin用户能够访问这一个视图

```python
authentication_classes = (authentication.TokenAuthentication,)  # 认证策略属性
permission_classes = (permissions.IsAdminUser,) # 权限策略属性

def get(self, requeset, format=None):
"""
返回一个用户列表
"""
usernames = [user.username for user in  User.objects.all()]
return Response(usernames)
```

1. API策略属性 以下的API策略属性应用于APIView，控制视图的策略：

`renderer_classes`： 渲染器类

`parser_classes`： 解释器类

`authentication_classes`： 权限类

`throttle_classes`：节流类

`permission_classes`： 权限类

`content_negotiation_class`： 内容协商类

1. API 策略方法 以下的策略方法用在API的策略，通常不用重写它：

`get_renderers(self)`: 获取渲染器方法 `get_parsers(self)`: 获取解释器方法 `get_authenticators(self)`: 或缺认证方法 `get_throttles(self)`: 获取节流方法 `get_permissions(self)`: 获取权限方法 `get_content_negotiator(self)`: 获取内容协商方法

1. API策略实施方法

下列方法之前被称为调度处理程序方法：

`check_permissions(self, request)`: 检查权限

`check_throttles(self, request)`: 检查节流

`check_content_negotiation(self, request, force=False)`: 检查内容协商

1. 调度方法

这些执行任何操作,需要发生之前或之后调用处理程序方法等. `initial(self, request, *args, **kwargs)`: 执行任何操作,需要发生在处理程序方法之前被调用。这个方法是用来执行权限和节流,并执行内容协商。

`handle_exception(self, exc)`：抛出的任何异常处理程序方法将被传递给这个方法,而返回响应实例,或者re-raises异常。 `initialize_request(self, request, *args, **kwargs)`：确保请求对象传递给处理程序方法是request的一个实例，而不是django的HttpRequest

`finalize_response(self, request, response, *args, **kwargs)`：确保任何响应处理程序方法返回的对象将被呈现到正确的内容类型

1. 函数基础视图（@api_view()） DRF同样提供了另外一种函数基础视图来装饰django的普通视图，我们同样可以使用request来接受请求和response响应。 一个小例子：

```python
from rest_framework.decorators import api_view

@api_view
def hello_world(request):
return Response({“message”:”Hello world!”})
```

1. api_view()使用方法

> 这个视图将使用默认渲染器、解析器、身份验证设置中指定的类等。通常默认只有GET方法，其他请求方法会报405错误，我们可以手动添加方法为这 装饰器指定request方法。

像这样：

```python
@api_view([‘GET’, ‘POST’])
def hello_world(request):
if request.method  == ‘POST’:
return Response({“message”:”Got some data”, “data”: request.data})
return Response({“messsage”:”Hello world!”})
```

1. API策略装饰器 DRF提供了很多附加的装饰器，我们可以添加到@api_view()后面，例如要加入一个节流的装饰器来确保特定用户每天只能一次通过这个视图，我 我们就要用到@throttle_classes装饰器：

```python
from rest_framework.decorators import api_view, throttle_classes
from rest_framework.throttling import UserRateThrottle

class OncePerDayUserThrottle(UserRateThrottle):
rate = “1/day”

@api_view([‘GET’])
@throttle_classes([OncePerDayUserThrottle])
def view(request):
return Response({“message”:”Hello for to day! see you tomorrow!”})
```



```text
其他可用API的装饰器：
@renderer_classes(…)
@parser_classes(…)
@authentication_classes(…)
@throttle_classes(…)
@permission_classes(…)
```

## 四、 通用视图（Generic views）

> 基于类视图的主要好处之一是他们允许您编写可重用的行为. REST框架提供的通用视图允许您快速构建API观点紧密地映射到您的数据库模型. 如果通用视图不适合你的需要API,您可以使用常规APIView类,或重用mixin和基类使用的通用视图来组成自己的组可重用通用视图。

### 通用视图

同样我们可以设置一些类属性在通用视图内，也可以根据特殊要写重写它的内部视图方法。一个小例子：

```python
from django.contrib.auth.models import User
from myapp.serializers import UserSerializer
from rest_framework import generics
from rest_framework.permissions import IsAdminUser

class UserList(generics.ListCreateAPIView):
queryset = User.objects.all()
serializer_class = UserSerializer
permission_classes = (IsAdminUser,)

def list(self, request):
# Note the use of get_queryset() instead of self.queryset
queryset = self.get_queryset()
serializer = UserSerializer(queryset, many=True)
return Response(serializer.data)
```



在urls配置中，**我们可以使用.as_views()来转换成视图函数**，当然也可以配置一些属性

```python
url(r’^/users/’, ListCreateAPIView.as_view(queryset=User.objects.all(), serializer_class=UserSerializer), name=’user-list’)
```

### GenericAPIView通用视图API参考：

GenericAPIView继承了DRF的APIView类，为list和detail视图增加了一些一般需求行为方法（提供queryset）。

#### 属性

**基本属性**：

`queryset`: 用于返回query对象集合，也可以使用get_queryset()方法。

`serializer_class`: 序列化器类,应该用于输入进行验证和反序列化,并用于序列化输出。通常情况下,你必须设置这个属性,或重写get_serializer_class()方法。

`lookup_field`: 模型的字段应该用于执行对象查找个别的模型实例

`ookup_url_kwarg`:URL应该用于对象查找关键字参数

**分页属性**： `pagination_class`: 用于返回一个分页列表视图的分页类，默认与settings中设置的`DEFAULT_PAGINATION_CLASS` 值相同， 可以通过`’rest_framework.pagination.PageNumberPagination’`设置分页数

**过滤器属性**：

`filter_backends`: 过滤queryset的类列表，和在settings中设置DEFAULT_FILTER_BACKENDS 一样

#### 方法

***基本方法***：

`get_queryset()`: 返回queryset。（详情见官网http://www.django-rest-framework.org/api-guide/generic-views/）

`get_object()`:获取某一个具体的model实例对象。

***保存与删除挂钩方法：***

> 以下方法是mixins类提供，提供简单的对象保存和删除的行为重写：

`perform_create(self, serializer)`: `CreateModelMixin` 当要保存对象时候会被调用

`perform_update(self, serializer)`:`UpdateModelMixin` 当要更新对象时候会被调用

`perform_destroy(self, instance)`: `DestoryModelMixin` 当药删除对象时候会被调用

### Mixins

> mixin类提供用于提供基础视图的操作行为。注意,mixin类提供操作方法而不是定义处理程序方法,比如. get()和. post(),直接。这允许更灵活的组合的行为。

通过rest_framework.mixins引用:

`ListModelMixin`：提供`list方法`，列出queryset

`CreateModelMixin`： 提供`create方法`，创建和保存一个Model对象

`RetrieveModelMixin`：提供`retrieve方法`，检索一个存在的model对象

`UpdateModelMixin`： 提供`Update方法`，更改一个模型对象

`DestroyModelMixin`：提供`destroy方法`，删除一个模型对象

### Generic

Generic通用视图类提供具体操作的通用视图类，可以理解为Generic.GenericAPIView和mixin类的合体.

通过rest_framework.generic.调用 .CreateAPIView:

#### 创建一个模型实例

**提供post方法的处理器** 继承于：`GenericAPIView，CreateModelMixin .ListAPIView`: 模型实例的集合

**提供get方法处理器** 继承于：`GenericAPIView，ListModelMixin .RetrieveAPIView`: 一个模型实例

**提供get方法处理器** 继承于：`GenericAPIView，RetrieveModelMixin .DestoryAPIView`:

#### 删除一个模型实例

提供delete方法处理器 继承于：`GenericAPIView，DestroyModelMixin .UpdateAPIView`:

#### 修改模型实例，

提供put和patch方法处理器 继承于：GenericAPIView，UpdateModelMixin .ListCreateAPIView:

#### 创建和展示一个模型实例集合

提供get和post处理器 继承于：`GenericAPIView，ListModelMixin，CreateModelMixin .RetrieveUpdateAPIView`:

#### 读和改一个模型实例

提供get,put,patch处理器 继承于：`GenericAPIView，RetrieveModelMixin，UpdateModelMixin .RetrieveDestoryAPIView`:

#### 读和删除一个模型实例

提供get和delete处理器 继承于：`GenericAPIView，RetrieveModelMixin，DestroyModelMixin .RetrieveUpdateDestroyAPIView`：

#### 读、改和删一个模型实例

get, put, patch,delete处理器 继承于：`GenericAPIView，RetrieveModelMixin，UpdateModelMixin，DestroyModelMixin`

## 五、视图集合ViewSets

Django REST框架允许您将一组相关的逻辑视图在一个类，ViewSet类是一个简单类型的基于类的观点,没有提供任何方法处理程序如.get()或. post(), 而代替提供方法比如.list()和create()。 一个小例子：

```python
from django.contrib.auth.models import User
from django.shortcuts import get_object_or_404
from myapps.serializers import UserSerializer
from rest_framework import viewsets
from rest_framework.response import Response

class UserViewSet(viewsets.ViewSet):
“””
A simple ViewSet for listing or retrieving users.
“””
def list(self, request):
queryset = User.objects.all()
serializer = UserSerializer(queryset, many=True)
return Response(serializer.data)

def retrieve(self, request, pk=None):
queryset = User.objects.all()
user = get_object_or_404(queryset, pk=pk)
serializer = UserSerializer(user)
return Response(serializer.data)
```

### 关于ViewSets

如果我们需要，我们需要为两个GET请求分开绑定视图：

```
user_list = UserViewSet.as_view({“GET”:’list’}) user_detail = UserViewSet.as_view({‘GET’:’retrieve’})
```

但是通常我们不会这样做，而是通过注册路由来配置url：

```python
from myapp.views import UserViewSet
from rest_framework.routers import DefaultRouter
router = DefaultRouter()
router.register(r’users’, UserViewSet)
urlpatterns = router.urls
```

或许你会经常用到自己模型数据，而不是手动写视图集合，这样就要用到模型视图集合ModelViewSet:

```
class UserViewSet(viewsets.ModelViewSet): “”” A viewset for viewing and editing user instance “”” serializer_class = UserSerializer queryset = User.objects.all()
```

**其他路由函数方法：**

```python
class UserViewSet(viewsets.ViewSet):
“””
Example empty viewset demonstrating the standard
actions that will be handled by a router class.

If you’re using format suffixes, make sure to also include
the format=None keyword argument for each action.
“””

def list(self, request):
pass

def create(self, request):
pass

def retrieve(self, request, pk=None):
pass

def update(self, request, pk=None):
pass

def partial_update(self, request, pk=None):
pass

def destroy(self, request, pk=None):
pass
```



如果你有特别的需要被路由到的方法,可以将它们标记为需要路由使用@detail_route或@list_route修饰符。

```
@detail_route(methods=[‘post’], permission_classes=[IsAdminOrIsSelf]) def set_password(self, request, pk=None): …
```

可以通过访问`^users/{pk}/set_password/$`来访问改视图

### ViewSets的API参考

`.ViewSet`： 继承了APIView，你可以使用一些标准的属性例如`permission_class,authentication_classes`去对视图做一些策略。ViewSet同样不提供具体 行为方法的实现，你可以重写和定义一些请求处理方法。而代替了原来APIVIew的POST，GET等方法，取而代之的是list，create等方法。

`.GenericViewSet`: 继承了`GenericAPIView`，提供了默认的`get_queryset()`和`get_object()`等方法来获取model数据，但不提供任何请求处理方法。 `.ModelViewSet`: 继承了GenericAPIView，增加了一些请求处理方法，如`list(), retrieve(),create()`等。

***例子：***

```python
class AccountViewSet(viewsets.ModelViewSet):
“””
A simple ViewSet for viewing and editing accounts
“””
queryset = Account.objects.all()
serializer_class = AccountSerializer
permissions_classes = [IsAccountAdminOrReadOnly]
```

`.ReadOnlyModelViewSet`: 继承了GenericAPIView，只增加了只读的请求处理方法list()和retrieve()

自定义View类： 只需要继承GenericAPIView, 增加mixins的相关处理方法。如：

```python
class CreatListRetrieveViewSet(mixins.CreateModelMixin,
mixins.ListModelMixin,
mixins.RetrieveModelMixin,
View.GenericViewSet):
pass
```

## 六、路由(routers)

### REST框架还支持自动Django URL路由,并为您提供了一个简单的、快速的和一致的方式连接视图逻辑的URL。

如果设置basename将自动生成基于queryset viewset的属性,如果它有一个。注意,如果viewset不包括queryset属性然后注册时必须设置base_name viewset。

```python
from rest_framework import routers
router = routers.SimpleRouter()
router.register(r’users’, UserViewSet, ‘users’)
router.register(r’accounts’, AccountViewSet)
urlpatterns = router.urls
```

**注意：router.register有三个参数属性**：

`prefix`：这是url匹配正则表达式。

`viewset`: 指定视图集合

`base_name`: 基于基础的url名字设置。这个特别要注意，如果不加这个参数，那么视图集合必须要包含queryset这个属性。

### 使用路由routers

```python
router = routers.SimpleRouter()
router.register(r’users’, UserViewSet)
urlpatterns = [
url(r’^api/’, include(router.urls, namespace=’api’)),
]
```



或者：urlpatterns +=router.urls

### @detail_route / @list_route指定路由

```
@detail_route(methods=[‘post’], permission_classes=[IsAdminOrIsSelf]) ->指定post方法，权限为IsAdminOrIsSelf
```

## 七、解释器(parse)

### 设置解释器

设置成全局：

```python
REST_FRAMEWORK ={
‘DEFAULT_PARSER_CLASSES’: (‘rest_framework.parsers.JSONParser’,）
}
```



也可以在视图APIView中设置：

```python
from rest_framework.parsers import JSONParser
parser_class = (JSONParser,)
如果是@api_view装饰的视图：
@api_view([‘POST’])
@parser_classes((JSONParser,))
```



### API 参考

`JSONParse`: application/json

`FormParse`: application/x-www-form-urlencoded

`MultiPartParser`: multipart/form-data

`FileUploadParser`: */* –>file_obj = request.data[‘file’]

## 八、渲染器(renders)

### 设置渲染器

设置成全局：

```text
REST_FRAMEWORK ={
‘rest_framework.renderers.JSONRenderer’,
‘rest_framework.renderers.BrowsableAPIRenderer’,
}
```

也可以在视图APIView中设置： `from rest_framework.renderers import JSONRenderer renderer_classes = (JSONRenderer, )` 如果是@api_view装饰的视图： `@api_view([‘GET’]) @renderer_classes((JSONRenderer,))`

## 九、序列化器serializers

> 序列化器可以将python的复杂数据格式渲染成json，xml等格式，同时也提供了反序列化器，可以将渲染成的数据解释成python的数据模型对象。它和django中 的from表单用法很相似。

### 渲染序列化对象：

可以将对象序列化成json,xml格式等

```python
serializer = CommentSerializer(comment)
serializer.data
# {’email’: ‘leila@example.com’, ‘content’: ‘foo bar’, ‘created’: ‘2016-01-27T15:17:10.375877′}


json = JSONRenderer().render(serializer.data)  # 渲染成json格式
# b'{“email”:”leila@example.com”,”content”:”foo bar”,”created”:”2016-01-27T15:17:10.375877″}’
```



### 反序列化

```text
from django.utils.six import BytesIO
from rest_framework.parsers import JSONParser

stream = BytesIO(json)
data = JSONParser().parse(stream)   # 解析json格式

serializer.is_valid()
# True
serializer.validated_data
```



### 保存实例

可以利用.create()和.update()方法 调用.save()方法会执行上面两个方法，自动保存或者更新实例对象 有时候，需要保存其他的信息，可以在参数中添加，如： `serializer.save(owner=request.user)`

### 验证validation

当需要保存反序列化的数据时，我们往往需要在之前用`is_valid()`验证数据的合法性，如果不合法可以用 `serializer.errors`得到该错误信息。这个错误信息可以根据error_message来进行自定义

### 模型序列化ModelSerializer

> 模型序列化与字段序列化用法类似，只需在类的属性Meta中指定相应的模型，就会根据模型自动生成相应的字段

```python
class AccountSerializer(serializers.ModelSerializer):
class Meta:
model = Account
fields = (‘id’, ‘account_name’, ‘users’, ‘created’)
```

### 超链接模型序列化HyperlinkedModelSerializer

与模型序列化类似，只不过过了一个可链接的形式。

## 十、序列化字段serializer fields

### 核心参数

`read_only`: 只读形式，只能序列化到api输出，不能被反序列化数据更新修改操作。默认False

`wirte_only`: 只写形式，只能被反序列化数据更新和创建，不能序列化表示。默认False

`required`: 必须字段，通常出现在反序列化的过程中，该字段必须有值。默认True

`allow_null`：是否允许为空，默认False

`default`: 默认值，

`source`：字段来源，为字段指定一个字段来源，如(source=’user.email’).

`validators`: 合法性函数列表，支持django的ValidationError包。

`error_message`: 一个错误信息的字典，包含null, blank, invalid, invalid_choice, unique等键值。

`label`:一篇简短的文本字符串,可以用作在HTML表单字段的名称或其他描述性的元素

`help_text`: 一个文本字符串,可以用作描述字段的HTML表单字段或其他描述性的元素。

`initial`: 用于预先填充HTML表单字段的值。

`style`: 字典的键-值对,可以用来控制渲染器应该如何呈现。

### 字段类型

`布尔字段BooleanField`: BoolenField(defalut=True)

`字符字段StringField`: CharField(max_length=None, min_length=None, allow_blank=False, trim_whitespace=True)

`邮箱字段EmailField`: EmailField(max_length=None, min_length=None, allow_blank=False)

`正则字段RegexField`: RegexField(regex, max_length=None, min_length=None, allow_blank=False)

`新闻标题字段SlugField：SlugField`(max_length=50, min_length=None, allow_blank=False)

`URL地址字段` `UrlField`: URLField(max_length=200, min_length=None, allow_blank=False)

`UUID字段 UUIDField`: UUIDField(format=’hex_verbose’) “de305d54-75b4-431b-adb2-eb6b9e546013″

`文件路径字段FilePathField`：FilePathField(path, match=None, recursive=False, allow_files=True, allow_folders=False, required=None, **kwargs)

`IP地址字段IPAddressField`：IPAddressField(protocol=’both’, unpack_ipv4=False, **options) *数字型字段：IntegerField、FloatField、DecimalField

`时间和日期字段：DateTimeField`：DateTimeField(format=None, input_formats=None)

DateField： TimeField： DurationField： `选择字段`：ChoiceField `文件字段`：FileField：FileField(max_length=None, allow_empty_file=False, use_url=UPLOADED_FILES_USE_URL)

`ImageField`：ImageField(max_length=None, allow_empty_file=False, use_url=UPLOADED_FILES_USE_URL) `模型字段`：`ModelField`：ModelField(model_field Django ModelField instance)

`只读字段`：ReadOnlyField：

## 十一、字段关系serializer relations

**多对一**：`ForeignKey`

**多对多**: `ManyToManyField`

**一对一**：`OneToOneField`

### api参考

`tracks = serializers.StringRelatedField(many=True)` # 字符串形式关系字段

`tracks = serializers.PrimaryKeyRelatedField(many=True, read_only=True)`# 主键形式关系字段

`tracks = serializers.HyperlinkedRelatedField(many=True, read_only=True, view_name=’track-detail’)` # 超链接形式关系字段

`tracks = serializers.SlugRelatedField(many=True, read_only=True, slug_field=’title’)` # 以小标题形式关系

`track_listing = serializers.HyperlinkedIdentityField(view_name=’track-list’)` # 超链接身份关系

### 嵌套关系

序列化类中可以直接引用其他序列化化类 十二、合法性验证(Validation) 1、数据的唯一性UniqueValidator 在模型中，只需设置字段的unique=True就会在该字段自动生成改唯一性判断 例:slug = SlugField(max_length=100, validators=[UniqueValidator(queryset=BlogPost.objects.all(), messsage=”)]) *queryset：模型数据对象集合

*message: 异常提示信息

2、数据字段的不重复性UniqueTogetherValidator

```python
class Meta:
validators = [
UniqueTogetherValidator(
queryset=ToDoItem.objects.all(),
fields=(‘list’, ‘position’)
)
]
```



`queryset`：模型数据对象集合

`fields`: 字段的集合元祖

`message`: 异常提示信息

## 十三、认证Authentication

### 设置认证方案

**可以在settings文件中配置**`DEFAULT_AUTHENTICATION_CLASSES：`

```text
REST_FRAMEWORK = {
‘DEFAULT_AUTHENTICATION_CLASSES’: (
‘rest_framework.authentication.BasicAuthentication’,
‘rest_framework.authentication.SessionAuthentication’,
)
}
```



**也可以在视图中设置**

(APIView)：

```text
authentication_classes = (SessionAuthentication, BasicAuthentication)
permission_classes = (IsAuthenticated,)
(@api_view)
@authentication_classes((SessionAuthentication, BasicAuthentication))
@permission_classes((IsAuthenticated,))
```



## 十四、权限

### 设置权限方案

**可以在settings文件中配置**`DEFAULT_PERMISSION_CLASSES`

`REST_FRAMEWORK = { ‘DEFAULT_PERMISSION_CLASSES’: ( ‘rest_framework.permissions.IsAuthenticated’,

# [#](http://www.liuwq.com/views/Django/django.restFramework.html#'rest-framework-permissions-allowany')‘rest_framework.permissions.AllowAny’,

) }` *视图中设置： （APIView）

```
permission_classes = (IsAuthenticated,) （@api_view） @permission_classes((IsAuthenticated, ))
```

### API引用

```text
*AllowAny：允许任何
*IsAuthenticated：是否被认证
*IsAdminUser：是管理用户
*IsAuthenticatedOrReadOnly：是被认证或者只读
*DjangoModelPermissions：标准的django模型设置权限
*DjangoModelPermissionsOrAnonReadOnly：标准的django模型处理或者只读权限
*DjangoObjectPermissions：相比模型权限，只提供queryset和get_queryset方法。
*自定义权限：
继承BasePermission;
重写：.has_permission(self, request, view)
.has_object_permission(self, request, view, obj)
```



## 十五、节流Trottling

> 限制请求量

1、设置节流方案

*可以在settings文件中配置DEFAULT_THROTTLE_CLASSES 和 DEFAULT_THROTTLE_RATES

```
‘DEFAULT_THROTTLE_CLASSES’: ( ‘rest_framework.throttling.AnonRateThrottle’, ‘rest_framework.throttling.UserRateThrottle’ ), ‘DEFAULT_THROTTLE_RATES’: { ‘anon’: ‘100/day’, ‘user’: ‘1000/day’ }
```

*可以在视图中设置： （APIView）

```
throttle_classes = (UserRateThrottle,) （@api_view） @throttle_classes([UserRateThrottle])
```

## 十六、过滤器Filtering

通常drf的默认的通用list视图类要处理的是全部模型的查询集合集，如果我们要指定结果集， 这就必须用到过滤器了。通常的方法是重写get_queryset(self)方法。 例如：

```text
# 根据用户过滤

class PurchaseList(generics.ListAPIView):
serializer_class = PurchaseSerializer

def get_queryset(self):
user = self.request.user
return Purchase.objects.filter(purchase = user)
# 根据url请求过滤
def get_queryset(self):
username = self.kwargs[‘username’]
return Purchase.objects.filter(purchaser__username=username)
# 根据请求参数过滤同上
def get_queryset(self):
queryset = Purchase.objects.all()
username = self.request.query_params.get(‘username’, None)
if username is not None:
queryset = queryset.filter(purchaser__username=username)
return queryset
```



1、generic filter过滤 *通过settings文件中配置过滤

```text
REST_FRAMEWORK = {
‘DEFAULT_FILTER_BACKENDS’: (‘rest_framework.filters.DjangoFilterBackend’,)
}
*也可通过视图中过滤
filter_backends = (filters.DjangoFilterBackend,)
```

2、API向导 *pip install django-filter filter.DjangoFilterBackend

*filter_fields过滤字段

```python
class ProductList(generics.ListAPIView):
query = Product.object.all()
serializer_class = ProductSerializer
filter_backends = (filter.DjangoFilterBackend,)
filter_fields = (‘category’, ‘in_stock’)
http://example.com/api/products?category=clothing&in_stock=True
*filter_class指定一个过滤集合类
import django_filters
from myapp.models import Product
from myapp.serializers impoert ProductSerializer
from rest_framework import filters
from rest_framework import generics

class ProductFilter(filters.FilterSet):
min_price = django_filters.NumberFilter(name=’price’, lookup_type=”gte”)
max_price = django_filters.NumberFilter(name=’price’, lookup_type=”lte”)

class Meta:
model = Product
fields = [‘category’, ‘in_stock’, ‘min_price’, ‘max_price’]

class ProductList(generics.ListAPIView):
queryset = Product.object.all()
serializer_class = ProductSerializer
filter_backends = (filter.DjangoFilterBackend,)
filter_class = ProductFilter
http://example.com/api/products?category=clothing&max_price=10.00
```



同理双下划线强调名字：

```text
class ProductFilter(filters.FilterSet):
class Meta:
model = Product
fields = [‘category’, ‘in_stock’, ‘manufacturer__name’]
http://example.com/api/products?manufacturer__name=foo
上面例子等同于：
class ProductFilter(filter.FilterSet):
manufacturer = django_filters.CharFilter(name=”manufacter__name”)

class Meta:
model = Product
fields = [‘category’, ‘in_stock’, ‘manufacturer’]
http://example.com/api/products?manufacturer=foo
*search_fields 搜索字段
class UserListView(generics.ListAPIView):
queryset = User.object.all()
serializer = UserSerializer
filter_backends = (filter.SearchFilter,)
filter_fields = (“suername”, ’email’)
http://example.com/api/users?search=russell

*ordring_fields排序字段
class UserList(generics.ListAPIView):
queryset = User.object.all()
serializer_class = UserSerializer
filter_backends = (filter.OrderingFilter,)
filter_fields = ‘__all__’
ordering = (‘username’,)  # 默认排序字段
*DjangoOjectPermissionFilter 对象权限的过滤器
filter_backends = (filter.DjangoObjectPermissionFilter,)
permission_classes = (myapp.permissions.CustomObjectPermissions,)  # 自定义的权限类
```



十七、分页Pagination

1、设置分页 *可以在settings中设置分页样式

```text
REST_FRAMEWORK = {
‘DEFAULT_PAGINATION_CLASS’: ‘rest_framework.pagination.LimitOffsetPagination’
}
```



*修改分页样式

```text
class LargeResultsSetPagination(PageNumberPagination):
page_size = 1000
page_size_query_param = ‘page_size’
max_page_size = 10000

class StandardResultsSetPagination(PageNumberPagination):
page_size = 100
page_size_query_param = ‘page_size’
max_page_size = 1000
```

*应用到视图中

```text
class BillingRecordsView(generics.ListAPIView):
queryset = Billing.objects.all()
serializer = BillingRecordsSerializer
pagination_class = LargeResultsSetPagination
```

1. API引用 **PageNumberPagination** 设置全局的分页大小：

```python
REST_FRAMEWORK = {
‘DEFAULT_PAGINATION_CLASS’: ‘rest_framework.pagination.PageNumberPagination’,
‘PAGE_SIZE’: 100
}
```

