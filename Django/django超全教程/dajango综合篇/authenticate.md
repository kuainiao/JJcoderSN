# Authentication

阅读: 14570     [评论](http://www.liujiangblog.com/course/django/178#comments)：2

Django自带一个用户认证系统，用于处理用户账户、群组、许可和基于cookie的用户会话。

Django的认证系统包含了身份验证和权限管理两部分。简单地说，身份验证用于核实某个用户是否合法，权限管理则是决定一个合法用户具有哪些权限。往后，‘认证’这个词同时代指上面两部分的含义。

Django的认证系统主要包括下面几个部分：

- 用户
- 许可
- 组
- 可配置的密码哈希系统
- 用于用户登录或者限制访问的表单和视图工具
- 可插拔的后台系统

类似下面的问题，不是Django认证系统的业务范围，请使用第三方工具：

- 密码强度检查
- 登录请求限制
- 第三方认证

默认情况下，使用`django-admin startproject`命令后，认证相关的模块已经自动添加到settings文件内了，如果没有的话，请手动添加。

在`INSTALLED_APPS`配置项中添加：

1. 'django.contrib.auth'： 包含认证框架的核心以及默认模型
2. 'django.contrib.contenttypes'：内容类型系统，用于给模型关联许可

在MIDDLEWARE配置项中添加：

1. SessionMiddleware：通过请求管理会话
2. AuthenticationMiddleware：将会话和用户关联

当配置正确后，运行`manage.py migrate`命令，创建用户认证系统相关的数据库表以及分配预定义的权限。

## 一、用户对象

用户对象是Django认证系统的核心！在Django的认证框架中只有一个用户模型也就是User模型，它位于`django.contrib.auth.models`。

**本节内容叙述的所有功能，都是基于这个User模型的，和这个User模型没有任何关系的自定义用户模型是无法使用Django认证系统的功能的！**

用户模型主要有下面几个字段：

- username
- password
- email
- first_name
- last_name

### 1. 创建用户

要创建一个新用户，最直接的办法是使用`create_user()`方法：

```
>>> from django.contrib.auth.models import User
>>> user = User.objects.create_user('john', 'lennon@thebeatles.com', 'johnpassword')
# 这时，user是一个User类的实例，已经保存在了数据库内，你可以随时修改它的属性，例如：
>>> user.last_name = 'Lennon'
>>> user.save()
```

如果你已经启用了Django的admin站点，你也可以在后台创建用户。

### 2. 创建超级用户

使用createsuperuser命令，创建超级用户：

```
$ python manage.py createsuperuser
或者
$ python manage.py createsuperuser --username=joe --email=joe@example.com
```

根据提示输入名字、密码和邮箱地址。密码要有一定强度

### 3. 修改密码

Django默认会对密码进行加密，因此，不要企图对密码进行直接操作。

要修改密码，有两个办法：

- 使用命令行： `python manage.py changepassword username`。如果不提供用户名，则会尝试修改当前系统用户的密码。
- 使用`set_password()`方法：

```
from django.contrib.auth.models import User
u = User.objects.get(username='john')
u.set_password('new password')
u.save()
```

同样可以在admin中修改密码。Django提供了views和forms，方便用户自己修改密码。 修改密码后，用户的所有当前会话将被注销。

### 4. 用户验证

利用authenticate()方法，对用户进行验证。该方法通常接收username与password作为参数。要注意的是，认证的后端可能有好几个，有一项认证通过则返回一个User类对象，一项都没通过或者抛出了PermissionDenied异常，则返回一个None。例如：

```
from django.contrib.auth import authenticate
user = authenticate(username='john', password='secret')
if user is not None:
    # A backend authenticated the credentials
else:
    # No backend authenticated the credentials
```

## 二、 权限与授权

Django提供了一个简单的权限系统，并且已经用于它的admin站点，当然你也可以在你的代码中使用。

User模型的对象有两个多对多的字段：groups和`user_permissions`，可以像下面这样访问他们：

```
myuser.groups.set([group_list])
myuser.groups.add(group, group, ...)
myuser.groups.remove(group, group, ...)
myuser.groups.clear()
myuser.user_permissions.set([permission_list])
myuser.user_permissions.add(permission, permission, ...)
myuser.user_permissions.remove(permission, permission, ...)
myuser.user_permissions.clear()
```

### 1. 默认权限

默认情况下，使用`manage.py migrate`命令时，Django会给每个已经存在的model添加默认的权限。 假设你现在有个app叫做foo，有个model叫做bar，使用下面的方式可以测试默认权限：

```
add: user.has_perm('foo.add_bar')
change: user.has_perm('foo.change_bar')
delete: user.has_perm('foo.delete_bar')
```

### 2. 用户组

Django提供了一个`django.contrib.auth.models.Group`模型，该model可用于给用户分组，实现批量管理。用户和组属于多对多的关系。用户自动具有所属组的所有权限。

### 3. 在代码中创建权限

例如，为myapp中的BlogPost模型添加一个`can_publish`权限。

```
from myapp.models import BlogPost
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType

content_type = ContentType.objects.get_for_model(BlogPost)
permission = Permission.objects.create(
    codename='can_publish',
    name='Can Publish Posts',
    content_type=content_type,
)
```

然后，你可以通过User模型的`user_permissions`属性或者Group模型的permissions属性为用户添加该权限。

### 4. 权限缓存

权限检查后，会被缓存在用户对象中。参考下面的例子：

```
from django.contrib.auth.models import Permission, User
from django.shortcuts import get_object_or_404

def user_gains_perms(request, user_id):
    user = get_object_or_404(User, pk=user_id)
    # any permission check will cache the current set of permissions
    user.has_perm('myapp.change_bar')

    permission = Permission.objects.get(codename='change_bar')
    user.user_permissions.add(permission)

    # Checking the cached permission set
    user.has_perm('myapp.change_bar')  # False

    # Request new instance of User
    # Be aware that user.refresh_from_db() won't clear the cache.
    user = get_object_or_404(User, pk=user_id)

    # Permission cache is repopulated from the database
    user.has_perm('myapp.change_bar')  # True

    ...
```

## 三、 在视图中认证用户

Django使用session和中间件关联请求对象中和认证系统。

每一次请求中都包含一个request.user属性，表示当前用户。如果该用户未登陆，该属性的值是一个AnonymousUser实例（匿名用户），如果已经登录，该属性就是一个User模型的实例。

可以使用`is_authenticated`方法进行判断，如下：

```
if request.user.is_authenticated:
# Do something for authenticated users.
...
else:
    # Do something for anonymous users.
    ...
```

### 1. 如何登录用户

在视图中，使用认证系统的login()方法登录用户。它接收一个HttpRequest参数和一个User对象参数。该方法会把用户的ID保存在Django的session中。下面是一个认证和登陆的例子：

```
from django.contrib.auth import authenticate, login

def my_view(request):
    username = request.POST['username']
    password = request.POST['password']
    user = authenticate(username=username, password=password)
    if user is not None:
        login(request, user)
        # 跳转到成功页面
        ...
    else:
        # 返回一个非法登录的错误页面
        ...
```

### 2. 如何注销用户

logout(request)[source]：

```
from django.contrib.auth import logout

def logout_view(request):
    logout(request)
    # Redirect to a success page.
```

注意，被logout的用户如何没登录，不会抛出错误。 一旦logout，当前请求中的session数据都会被清空。

### 3. 限制用户的访问权限

很多时候，我们要区分已登录用户和未登录用户，只对登录的用户开放一些页面或功能，限制未登录用户的行为。办法有很多，下面是主要几种：

#### **1.原始的办法**：

如果用户未登录，重定向到登录页面，如下所示：

```
from django.conf import settings
from django.shortcuts import redirect

def my_view(request):
    if not request.user.is_authenticated:
        return redirect('%s?next=%s' % (settings.LOGIN_URL, request.path))
    # ...
```

或者显示一个错误信息：

```
from django.shortcuts import render

def my_view(request):
    if not request.user.is_authenticated:
        return render(request, 'myapp/login_error.html')
    # ...
```

#### **2. 使用装饰器**

原型：login_required(redirect_field_name='next', login_url=None)[source]

被该装饰器装饰的视图，强制要求用户必须登录后才可以访问。

```
from django.contrib.auth.decorators import login_required

@login_required
def my_view(request):
    ...
```

该装饰器工作机制：

- 如果用户未登陆，重定向到`settings.LOGIN_URL`，传递当前绝对路径作为url字符串的参数，例如：`/accounts/login/?next=/polls/3/`
- 如果用户已经登录，执行正常的视图

此时，默认的url中使用的参数是“next”，如果你想使用自定义的参数，请修改`login_required()`的`redirect_field_name`参数，如下所示：

```
from django.contrib.auth.decorators import login_required

@login_required(redirect_field_name='my_redirect_field')
def my_view(request):
    ...
```

如果你这么做了，你还需要重新定制登录模板，因为它引用了`redirect_field_name`变量。

`login_required()`装饰器还有一个可选的`longin_url`参数。例如：

```
from django.contrib.auth.decorators import login_required

@login_required(login_url='/accounts/login/')
def my_view(request):
    ...
```

注意：如果不指定`login_url`参数，请确保你的`settings.LOGIN_URL`和登陆视图保持正确的关联。例如：

```
from django.contrib.auth import views as auth_views
url(r'^accounts/login/$', auth_views.login),
```

#### **3. 使用LoginRequired mixin**

通过继承LoginRequiredMixin类的方式限制用户。在多继承时，该类必须是最左边的父类。

```
from django.contrib.auth.mixins import LoginRequiredMixin

class MyView(LoginRequiredMixin, View):
    login_url = '/login/'
    redirect_field_name = 'redirect_to'
```

#### **4. 进行测试，根据结果决定动作**

也可以直接在视图中进行过滤：

```
from django.shortcuts import redirect

def my_view(request):
    if not request.user.email.endswith('@example.com'):
        return redirect('/login/?next=%s' % request.path)
    # ...
```

上面根据用户的邮箱地址，判断用户的权限。

#### **5. 使用权限需求装饰器**

Django内置了一个`permission_required()`装饰器，用户根据用户权限，决定视图的访问权限，如下所示：

```
from django.contrib.auth.decorators import permission_required

@permission_required('polls.can_vote')
def my_view(request):
    ...
```

权限的格式是`<app label>.<permission codename>`。

该装饰器还有一个可选的`longin_url`参数：

```
from django.contrib.auth.decorators import permission_required

@permission_required('polls.can_vote', login_url='/loginpage/')
def my_view(request):
    ...
```

### 4. 认证视图

Django为我们提供了一系列认证相关的视图，可以直接拿来用，这样你就不需要自己写登录、注销、注册等视图。但是，但是，Django没有为认证视图提供默认的模板，你需要自己写......。

所以，除非懒癌发作，还是老老实实自己写认证相关的视图、路由和模板吧。个人认为类似跟实际生产环境结合非常紧密的视图，根本不需要这种鸡肋的内置视图，到最后，你发现还是要自己写才能满足需求。

所以，后面的部分就不赘述了！