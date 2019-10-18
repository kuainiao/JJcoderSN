## 一、为什么需要url命名？
因为url是经常变化的。如果在代码中写死可能会经常改代码。给url取个名字，以后使用url的时候就使用他的名字进行反转就可以了，就不需要写死url了。

>需求：访问app主页，如果没登录则自动跳转至登录页面，已经登录则留在app主页。

### 项目下创建两个app：
```
django-admin startapp app01
django-admin startapp app02
```
### 项目的settings.py中添加这两个应用：
```
INSTALLED_APPS = [
	...
    'apps.app01',
    'apps.app02'
]
```

### 项目的urls.py中添加URL映射：
```
from django.urls import path, include

urlpatterns = [
    ...
    path('app01/', include('apps.app01.urls')),
    path('app02/', include('apps.app02.urls')),
]
```

### app01和app02分别新建urls.py并配置：
```
from django.urls import path
from . import views

urlpatterns = [
    path('', views.index),
    path('signin/', views.login),
]
```
app01和app02的views.py中：

### 以下是app01/views.py
```
from django.http import HttpResponse
from django.shortcuts import redirect


def index(request):
    username = request.GET.get('username')
    if username:
        return HttpResponse('app01首页')
    else:
        return redirect('./login/')
    

def login(request):
    return HttpResponse('app01登录页面')
```
### 以下是app02/views.py
```
from django.http import HttpResponse
from django.shortcuts import redirect


def index(request):
    username = request.GET.get('username')
    if username:
        return HttpResponse('app02首页')
    else:
        return redirect('./login/')
    

def login(request):
    return HttpResponse('app02登录页面')
```

### 启动服务：
```
python manage.py runserver

访问 http://127.0.0.1:8000/app01?username='onefine'


访问 http://127.0.0.1:8000/app02?username='onefine'


访问 http://127.0.0.1:8000/app01/


访问 http://127.0.0.1:8000/app02/


一切正常！
```
现在有了新的需求：登录时的url由login变为signin。在目前的项目中，更改需要涉及四个文件…额…

现在采用url命名来防止这种需求。

## 二、如何给一个url指定名称？
在path函数中，传递一个name参数就可以指定。
```
path('', views.index, name='index')
```

### app01和app02下的urls.py配置：
```
urlpatterns = [
    path('', views.index, name="index"),
    path('signin/', views.login, name="login"),
]
```

app01和app02的views.py中：

### 以下是app01/views.py
```
from django.http import HttpResponse
from django.shortcuts import redirect, reverse


def index(request):
    username = request.GET.get('username')
    if username:
        return HttpResponse('app01首页')
    else:
    	# url反转，url重定向
        return redirect(reverse('login'))


def login(request):
    return HttpResponse('app01登录页面')
```

### 以下是app02/views.py
```
from django.http import HttpResponse
from django.shortcuts import redirect, reverse


def index(request):
    username = request.GET.get('username')
    if username:
        return HttpResponse('app02首页')
    else:
        return redirect(reverse('login'))


def login(request):
    return HttpResponse('app02登录页面')
```

### 重新启动服务器，输入 http://127.0.0.1:8000/app02 输入 http://127.0.0.1:8000/app01


你没看错，它确实跳转的是app2下面的signin，这是怎么回事呢？

## 三、应用(app)命名空间：
在多个app之间，有可能产生同名的url。这时候为了避免反转url的时候产生混淆，可以使用应用命名空间，来做区分。定义应用命名空间非常简单，只要在app的urls.py中定义一个叫做app_name的变量，来指定这个应用的命名空间即可。

### app01下的urls.py配置，app02类似：
```
from django.urls import path
from . import views

# 应用命名空间
app_name = 'app01'

urlpatterns = [
    path('', views.index, name="index"),
    path('signin/', views.login, name="login"),
]
```

以后在做反转的时候就可以使用应用命名空间:url名称的方式进行反转。

### app01的views.py中，app02类似：
```
from django.http import HttpResponse
from django.shortcuts import redirect, reverse


def index(request):
    username = request.GET.get('username')
    if username:
        return HttpResponse('app01首页')
    else:
        return redirect(reverse('app01:login'))


def login(request):
    return HttpResponse('app01登录页面')
```

## 四、实例命名空间：
一个app可以创建多个实例。可以使用多个url映射到同一个app。这就会产生一个问题：以后在做反转的时候，如果使用应用命名空间，那么就会发生混淆。

### 项目下urls.py文件：
```
urlpatterns = [
    path('app01/', include('apps.app01.urls')),
    path('app02/', include('apps.app02.urls')),
	
	# 新添加的
    path('app03/', include('apps.app01.urls')),
]
```
### 重启服务访问 http://127.0.0.1:8000/app03


为了避免这个问题。我们可以使用实例命名空间。实例命名空间只要在include函数中传递一个namespace变量即可。

### 项目下urls.py文件：
```
urlpatterns = [
    url(r'^admin/', admin.site.urls),
    # re_path(r'^$', views.index),
	path('app01/', include('apps.app01.urls', namespace='app01')),
    path('app02/', include('apps.app02.urls', namespace='app02')),
	
	# 同一个app下的第二个实例，实例命名空间
    path('app03/', include('apps.app01.urls'), namespace='app03'),
]
```
以后在做反转的时候，就可以根据实例命名空间来指定具体的url。

### app01下的views.py,app02类似:
```
from django.http import HttpResponse
from django.shortcuts import redirect, reverse


def index(request):
    username = request.GET.get('username')
    if username:
        return HttpResponse('app01首页')
    else:
    	# 获取当前实例的命名空间
        current_namespace = request.resolver_match.namespace
        return redirect(reverse('%s:login' % current_namespace))


def login(request):
    return HttpResponse('app01登录页面')
```

输入http://127.0.0.1:8000/app03/


输入 http://127.0.0.1:8000/app03?username='onefine'
