# REST framework 源码分析-认证 鉴权 限流

## rest framework 重写dispatch()方法源码分析

1. 根据CBV的源码运行流程，还是执行dispatch()方法，只是rest framework插件 **重写** 了 **dispatch()** 方法

> - rest_framework/views.py/APIView.dispatch()
> - 对传入的request参数进行扩展

```
def dispatch(self, request, *args, **kwargs):
    """
    `.dispatch()` is pretty much the same as Django's regular dispatch,
    but with extra hooks for startup, finalize, and exception handling.
    """
    """
    扩展了django原生的dispatch()方法
    """
    self.args = args
    self.kwargs = kwargs
    # 扩展reqeust
    request = self.initialize_request(request, *args, **kwargs)
    self.request = request
    self.headers = self.default_response_headers  # deprecate?
    
    # 这里和原生的dispatch()基本一样
    # 重写了initial()方法
    try:
        self.initial(request, *args, **kwargs)

        # Get the appropriate handler method
        if request.method.lower() in self.http_method_names:
            handler = getattr(self, request.method.lower(),
                              self.http_method_not_allowed)
        else:
            handler = self.http_method_not_allowed

        response = handler(request, *args, **kwargs)

    except Exception as exc:
        response = self.handle_exception(exc)
        
    self.response = self.finalize_response(request, response, *args, **kwargs)
    return self.response
复制代码
```

1. 通过initialize_request()方法扩展request，**重新新封装**了原生request、**authenticators(认证对象列表)** 等成员

```
def initialize_request(self, request, *args, **kwargs):
    """
    Returns the initial request object.
    """
    parser_context = self.get_parser_context(request)
    
    # 增加了authenticators等成员
    return Request(
        request,
        parsers=self.get_parsers(),
        authenticators=self.get_authenticators(),
        negotiator=self.get_content_negotiator(),
        parser_context=parser_context
    )
复制代码
```

1. get_authenticators()方法找到setting中指定的**认证类**，或者在View中重写的**认证类**

```
def get_authenticators(self):
    """
    Instantiates and returns the list of authenticators that this view can use.
    """
    # 列表生成式，生成了相应的类的对象的列表：[对象，对象，...]
    return [auth() for auth in self.authentication_classes]
        
class APIView(View):

    # The following policies may be set at either globally, or per-view.
    # 下面的策略 可能在setting中设置，或者重写在每个View中
    ...
    authentication_classes = api_settings.DEFAULT_AUTHENTICATION_CLASSES
    throttle_classes = api_settings.DEFAULT_THROTTLE_CLASSES
    permission_classes = api_settings.DEFAULT_PERMISSION_CLASSES
    ...
复制代码
```

1. 回到dispatch()方法，在重新扩展封装了新的request之后，使用了 **initial()** 方法，初始化。在初始化的方法中，执行了认证、鉴权、限流这三个方法。

```
    def initial(self, request, *args, **kwargs):
        """
        Runs anything that needs to occur prior to calling the method handler.
        """
        ...

        # Ensure that the incoming request is permitted
        # 执行了认证、鉴权、限流这三个方法
        self.perform_authentication(request)
        self.check_permissions(request)
        self.check_throttles(request)
```

------

## rest framework 认证 源码分析

### 源码分析

> 接上回，restframework重写的dispatch()方法中，执行了inital()函数。其中**perform_authentication(request)** 方法实现了请求的认证功能。

1. perform_authentication()函数中执行了Request类（rest_framework.reqeust.py中定义的类）的对象request（新封装的request）的**user**方法

```
def perform_authentication(self, request):
    """
    Perform authentication on the incoming request.

    Note that if you override this and simply 'pass', then authentication
    will instead be performed lazily, the first time either
    `request.user` or `request.auth` is accessed.
    """
    # 执行新封装的request对象的的user方法（是个property所以不用user() ）
    request.user
复制代码
```

1. 经过一些判断之后，跳转到 **_authenticate()** 方法

```
@property
def user(self):
    """
    Returns the user associated with the current request, as authenticated
    by the authentication classes provided to the request.
    """
    if not hasattr(self, '_user'):
        with wrap_attributeerrors():
            # 经过一些判断之后，跳转到_authenticate()方法
            self._authenticate()
    return self._user
```

1. 在Request类的_authenticate()方法中，执行 **authenticators（认证对象列表）** 中的每一个认证对象的 **authenticate()** 方法。

```
def _authenticate(self):
    """
    Attempt to authenticate the request using each authentication instance
    in turn.
    """
    """
    尝试去执行每一个认证对象实例中的authenticate()方法，返回认证结果
    """
    # 获取每一个认证对象实例
    for authenticator in self.authenticators:
        try:
            # 使用认证对象的authenticate()方法
            user_auth_tuple = authenticator.authenticate(self)
        except exceptions.APIException:
            # 如果认证对象没有写authenticate()方法，抛出异常_not_authenticated()
            self._not_authenticated()
            raise
        
        # 如果写了authenticate()方法，并且执行后返回的不是None
        # 则给request对象实例生成3个成员 self._authenticator, self.user, self.auth
        if user_auth_tuple is not None:
            self._authenticator = authenticator
            self.user, self.auth = user_auth_tuple
            return
        
        # 如果执行authenticate()方法之后返回的是None
        # 则继续循环，执行对象列表中下一个 认证对象的方法，直到最后一个对象

    self._not_authenticated()
复制代码
```

- authenticate()的返回值应该是（should be）一个元祖，元祖的值 **(self.force_user, self.force_token)**
- 返回的值是最终通过认证的用户和token，这些会作为成员变量赋值给request，可以在view中调用self.user, self.auth

```
def authenticate(self, request):
    return (self.force_user, self.force_token)
复制代码
```

### 使用示例

1. 自定义一个认证类，继承BaseAuthentication类
    - 如果这是认证类列表调用的最后一个类，则认证成功：返回 (user,token)
    - 如果认证列表后续还有别的认证类需要叠加认证，则认证成功：返回None,交由下一个类处理
    - 认证失败，抛出异常

- 自定义**认证类**

```
from rest_framework.authentication import BaseAuthentication,exceptions

class MyAuthentication(BaseAuthentication):
    
    # 必须要重写authenticate()、authenticate_header()方法
    def authenticate(self, request):
        # 从新的request中如果找不到成员，会继续从原生_request中查找
        token = request.GET.get('token')
        # 检查token，实际应该与数据库中token比对，这里简写
        if token and token=='123456abc':
            # 返回元祖（user, token）
            return ('clay', token)
        else:
            # 如果没有token或者token错误，抛出认证失败的异常
            raise exceptions.AuthenticationFailed('用户认证失败')
            
    def authenticate_header(self, request):
        pass
复制代码
```

- 在View中重写authentication_classes列表，调用认证类

```
class AssetsView(APIView):
    # 重点看这一行，重写authentication_classes列表，调用认证类
    # 自定义的类MyAuthentication此时是最后一个认证类，所以必须返回（user, token）
    authentication_classes = [MyAuthentication, ]

    def get(self,request,*args,**kwargs):
        """
        返回带code、msg的assets json数据
        :param requset:
        :param args:
        :param kwargs:
        :return:
        """

        # 提取数据库中assets信息, 整合成字典(先使用土法1)
        asset_list = []

        for asset in models.Assets.objects.all():
            asset_dict = {
                'id': asset.id,
                'name': asset.name,
            }
            asset_list.append(asset_dict)

        ret = [
                  {
                      'code': 1000,
                      'msg': 'SUCCESS: get assets info summary',
                      # 调用认证成功返回的元祖
                      'user': request.user,
                      'token':  request.auth,
                  }
              ] + asset_list
        # 返回数据库中全部assets概览
        # 返回带状态码，成功响应默认就是200，可以修改
        return HttpResponse(json.dumps(ret), status=200)
复制代码
```

- 想要调用认证类，也可以再全局的setting.py文件中设置认证类的路径
- 建议创建一个专门的文件夹来存放这些类

```
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": ['restframework_class.auth.MyAuthentication', 'restframework_class.auth.MyAuthentication2'] 
}
复制代码
```

------

## rest framework 鉴权 源码分析

### 源码分析

> restframework重写的dispatch()方法中，执行了inital()函数。inital()中**check_permissions(request)** 方法实现了请求的鉴权、权限控制功能。

1. check_permissions(request)函数中，循环了权限类的对象列表，依次执行权限对象的

     

    has_permission()

     

    方法

    - 如果有权限，则继续循环使用下一个权限对象再来检查request
    - 如果没有权限，执行permission_denied()函数，抛出异常（通过权限对象的message变量来自定义异常信息）

```
def check_permissions(self, request):
    """
    Check if the request should be permitted.
    Raises an appropriate exception if the request is not permitted.
    
    检查请求是否被权限限制。
    如果请求没有权限，抛出对应的异常
    """
    for permission in self.get_permissions():
        if not permission.has_permission(request, self):
            self.permission_denied(
                request, message=getattr(permission, 'message', None)
            )
复制代码
```

- permission_classes可以在全局的setting中设置，也可以再每个类中重写

```
def get_permissions(self):
    """
    Instantiates and returns the list of permissions that this view requires.
    
    列表生产式，来生成权限类的列表
    """
    return [permission() for permission in self.permission_classes]
复制代码
```

- 如果没有权限，执行permission_denied()函数，抛出异常，通过权限对象的message变量来自定义异常信息，message是权限对象中的变量。

```
def permission_denied(self, request, message=None):
    """
    If request is not permitted, determine what kind of exception to raise.
    """
    if request.authenticators and not request.successful_authenticator:
        raise exceptions.NotAuthenticated()
    # 抛出PermissionDenied(detail=message)异常，出入权限对象的message变量
    raise exceptions.PermissionDenied(detail=message)
复制代码
```

### 使用示例

1. 自定义的权限类继 承

    BasePermission

     

    类

    - 在重写 **has_permission()** 方法时，需要引入 *request, view* 参数，可以根据 ***request, view*** 来做权限控制
    - 在重写 **has_object_permission()** 方法时, 需要引入 *request, view, obj* 参数，可以根据 ***request, view, obj*** 来做权限控制

```
class BasePermission(object):
    """
    A base class from which all permission classes should inherit.
    """

    def has_permission(self, request, view):
        """
        Return `True` if permission is granted, `False` otherwise.
        """
        return True

    def has_object_permission(self, request, view, obj):
        """
        Return `True` if permission is granted, `False` otherwise.
        """
        return True
复制代码
```

- 自定义权限类，示例：

```
from rest_framework.permissions import BasePermission

class NetPermission(BasePermission):
    message = "必须是网络工程是才能访问！"
    def has_permission(self, request, view):
        if request.user.role != 0:
            return False
        return True
复制代码
```

1. 在View中重写permission_classes权限类列表，列表中几个权限类表示要经过几层权限检查（从左至右依次检查）

```
class AssetsView(APIView):
    authentication_classes = [MyAuthentication, ]
    # 关注这一行
    # 在View中重写permission_classes权限类列表，几个类表示要经过几层权限检查
    permission_classes = [NetPermission, ]

    def get(self,request,*args,**kwargs):
        ...
        return HttpResponse(json.dumps(ret), status=200)
复制代码
```

- 或者在全局setting.py中指定权限类的路径，对全站的View进行默认的权限检查

```
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": ['plugin.restframework.authentication.MyAuthentication', 'plugin.restframework.authentication.MyAuthentication2'] ,
    "DEFAULT_PERMISSION_CLASSES": ['restframework.permissions.MyPermission', ] 
}
复制代码
```

### 细化的权限控制（针对view ，针对obj）

## rest framework 限流 源码分析

### 源码分析

> restframework重写的dispatch()方法中，执行了inital()函数。inital()中**check_throttles((request)** 方法实现了请求的**访问频率控制**功能。

1. check_throttles(request)函数中，循环了限流类的对象列表，依次执行限流对象的 **allow_request()** 方法

```
def check_throttles(self, request):
    """
    Check if request should be throttled.
    Raises an appropriate exception if the request is throttled.
    
    检查请求是否应该被节流。
    如果被节流，则抛出相应异常。
    """
    # 遍历 限流对象列表，如果返回Fasle,则被限流，抛出异常（可传参数throttle.wait()的返回值）
    for throttle in self.get_throttles():
        # 如果被节流，返回False，则抛出相应异常
        if not throttle.allow_request(request, self):
            self.throttled(request, throttle.wait())
复制代码
```

- 限流对象列表生成式

```
def get_throttles(self):
    """
    Instantiates and returns the list of throttles that this view uses.
    """
    # 可以在view中重写throttle_classes，指定限流对象列表
    # 也可以在setting.py中定义
    return [throttle() for throttle in self.throttle_classes]
复制代码
```

- 如果被节流，则通过throttled()方法，抛出相应异常，可传入wait作为等待时间的参数

```
def throttled(self, request, wait):
    """
    If request is throttled, determine what kind of exception to raise.
    """
    # wait参数，出入的值是 节流类的wait()方法的返回值（单位：秒）
    raise exceptions.Throttled(wait)
复制代码
```

### 使用示例

1. 自定义限流类，继承BaseThrottle类，重写 **allow_request()** 和 **wait()** 这两个方法

```
from rest_framework.throttling import BaseThrottle

import time

# 访问记录,key是IP，value是访问时间的列表。应该记录在redis缓存中，这里简单写在内存里。
REQ_RECORD = {}

class MyThrottle(BaseThrottle):
    """
    自定义限流类：10秒内只能访问3次，超过就限流
    
    返回True，允许请求访问
    返回False，禁止请求访问
    """
    
    
    # 通过 self.history这个对象的成员变量，
    # 在allow_request()和 wait()这两个成员方法之间传递history的值
    def __init__(self):
        self.history = None

    def allow_request(self, request, view):
        remote_addr = request.META.get('REMOTE_ADDR')
        timer = time.time()
        if remote_addr not in REQ_RECORD:
            REQ_RECORD[remote_addr]=[timer]
            return True

        history = REQ_RECORD[remote_addr]
        self.history = history
        # 如果历史访问时间列表的最老的访问时间 在10秒之前，
        # 将最老的访问时间 从历史访问时间列表 中移除
        while history and history[-1] < timer - 10:
            history.pop()

        # 10秒内的访问记录，是否超过3次
        # 如果没有超过，则记录这次访问，并返回True,允许访问
        # 如果超过，则返回False,禁止访问
        if len(history) < 3:
            history.insert(0, timer)
            return True
        return False

    def wait(self):
        timer = time.time()
        return 10 - (timer - self.history[-1])
    
复制代码
```

1. 在View中调用限流类

```
class AssetsView(APIView):
    authentication_classes = [MyAuthentication, ]
    permission_classes = [NetPermission, ]
    # 关注这一行
    # 在View中重写throttle_classes限流类列表，一般只写一个限流，
    # 或者不限流，使列表为空，throttle_classes = []
    throttle_classes = [MyThrottle, ]

    def get(self,request,*args,**kwargs):
        ...
        return HttpResponse(json.dumps(ret), status=200)
复制代码
```

- 或者在setting.py中指定全站默认使用的限流类的路径

```
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": ['plugin.restframework.authentication.MyAuthentication', 'plugin.restframework.authentication.MyAuthentication2'],
    "DEFAULT_PERMISSION_CLASSES": ['restframework.permissions.MyPermission', ],
    "DEFAULT_THROTTLE_CLASSES": ['plugin.restframework.throttling.MyThrottle']
}
复制代码
```

### 内置的限流类

> 与认证类、鉴权类通常继承BaseXXX类，高度自定义不同，限流类我个人觉得继承restframework提供的其他内置的类更方便

> - 例如继承 **SimpleRateThrottle** 类

```
class ZklTrottle(SimpleRateThrottle):
    # 设定规定时间内能访问的次数，例如 3/m, 1/s, 1000/h, 9999/day
    # 通常设定在setting.py中
    THROTTLE_RATES = {
        "Zkl": '5/m'
    }
    # 指定scope值为 查找THROTTLE_RATES的key
    scope = "Zkl"
    # 定义标识一个用户的参数 
    # get_ident(request)是BaseThrottle类中的方法，返回remote_addr,
    # 即使用访问源IP作为一个用户的标识
    def get_cache_key(self, request, view):
        return self.get_ident(request)
        
        # return request.user.pk   # 通常也使用requser.user作为标识一个用户的ID
```