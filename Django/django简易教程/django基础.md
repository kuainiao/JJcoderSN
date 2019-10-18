# Django教程（一）- Django视图与网址

# 1.简介

### MVC

- 大部分开发语言中都有MVC框架
- MVC框架的核心思想是：解耦
- 降低各功能模块之间的耦合性，方便变更，更容易重构代码，最大程度上实现代码的重用
- m表示model，主要用于对数据库层的封装
- v表示view，用于向用户展示结果
- c表示controller，是核心，用于处理请求、获取数据、返回结果

### MVT

- Django是一款python的web开发框架
- 与MVC有所不同，属于MVT框架
- m表示model，负责与数据库交互
- v表示view，是核心，负责接收请求、获取数据、返回结果
- t表示template，负责呈现内容到浏览器

[Django](https://link.jianshu.com/?t=https%3A%2F%2Fwww.djangoproject.com%2F) 是用Python开发的一个免费开源的Web框架，可以用于快速搭建高性能，优雅的网站！

[Django官方网站](https://link.jianshu.com/?t=https%3A%2F%2Fwww.djangoproject.com%2F)
[Django官方文档](https://link.jianshu.com/?t=https%3A%2F%2Fdocs.djangoproject.com%2Fen%2Fdev%2F)
[安装Django官方文档介绍](https://link.jianshu.com/?t=https%3A%2F%2Fdocs.djangoproject.com%2Fen%2Fdev%2Fintro%2Finstall%2F)

Django是一个基于[MVC](https://link.jianshu.com/?t=https%3A%2F%2Fbaike.baidu.com%2Fitem%2FMVC)构造的框架。但是在Django中，控制器接受用户输入的部分由框架自行处理，所以 Django 里更关注的是模型（Model）、模板(Template)和视图（Views），称为 MTV模式。

BSD:BSD许可证是随着加州大学伯克利分校发布BSD UNIX发展起来的，修改版本被Apple、Apache所采用。BSD协议是“宽容自由软件许可证”中的一员，在软件复用上给予了最小限度的限制。

BSD协议允许作者使用该协议下的资源，将其并入私人版本的软件，该软件可使用闭源软件协议发布。

# 2.环境搭建

1. 下载Ubuntu 镜像文件
    [地址一](https://link.jianshu.com/?t=http%3A%2F%2Fwww.oschina.net%2Fp%2Fubuntu%3Ffromerr%3DmPMmNr7h)
    [地址二](https://link.jianshu.com/?t=http%3A%2F%2Freleases.ubuntu.com%2F)
    [地址三](https://link.jianshu.com/?t=http%3A%2F%2Fmirrors.163.com%2Fubuntu-releases%2F14.04%2F)
2. 安装[ubuntu](https://link.jianshu.com/?t=http%3A%2F%2Fblog.csdn.net%2Fu013142781%2Farticle%2Fdetails%2F50529030)
3. 安装pip,使用以下合适的代码安装

```csharp
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install python-pip
```

对于Python开发用户来讲，PIP安装软件包是家常便饭。但国外的源下载速度实在太慢，浪费时间，而且好多软件总是被墙，所以把PIP安装源替换成国内镜像，可以大幅提升下载速度，还可以解决被墙导致的装不上库的烦恼，提高安装成功率。网上有很多可用的源，这里推荐的是[清华大学的pip源](https://link.jianshu.com/?t=https%3A%2F%2Fpypi.tuna.tsinghua.edu.cn%2Fsimple)，它是官网pypi的镜像，每隔5分钟同步一次。

[Linux](https://link.jianshu.com/?t=https%3A%2F%2Fwww.linux.org%2F)下，修改 ~/.pip/pip.conf (没有就创建一个)，按下Ctrl + H 可以看到隐藏文件,修改 index-url至tuna，内容如下：

```csharp
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
```

4.利用pip安装 Django(推荐使用1.11版本)

```undefined
(sudo)pip install Django
或者 (sudo) pip install Django==1.8.16 
或者 pip install Django==1.11
```

检查是否安装成功

```ruby
>>> import django
>>> django.VERSION
(1, 11, 'final', 0)
>>> 
>>> django.get_version()
'1.11'
```

5.安装Rest FrameWork

- 安装

```undefined
pip install djangorestframework 
```

- 配置

```bash
INSTALLED_APPS = [
  ...
 'rest_framework', #配置 rest_framework app
  ...
]
```

# 3.安装pycharm

1. 下载[JDK](https://link.jianshu.com/?t=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fcn%2Fjava%2Fjavase%2Fdownloads%2Findex.html)

    

    ![img](https://upload-images.jianshu.io/upload_images/6078268-3a19de20a3249632.png?imageMogr2/auto-orient/strip|imageView2/2/w/143/format/webp)

    

2. 解压
    输入命令：`tar zvxf jdk-8u131-linux-x64.tar.gz`

3. 创建jvm文件
    输入命令：`sudo mkdir /usr/lib/jvm`

4. 移动到/usr/lib/jvm下
    输入命令：`sudo mv jdk1.8.0_131/ /usr/lib/jvm/`
    **注意：**如果没有jvm文件，执行该语句虽然会自动创建jvm文件，但只会把jdk1.8.0_25里面的文件都放到jvm中，而不是把jdk1.8.0_25及其里面的文件放到jvm文件中，两者是有区别的

5. 设置JDK环境变量
    （也有在/.bashrc修改的，区别是：/etc/profile的设置方法对所有登陆用户都有效/.bashrc只对当前用户有效）
    输入命令：`sudo vim ~/.profile`
    编辑：

```bash
export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_131
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
```

1. 使修改立刻生效`source ~/.profile`

2. 验证JDK

    输入命令：

    ```
    java -version
    ```

    

    ![img](https://upload-images.jianshu.io/upload_images/6078268-853f3a18fb86ab1f.png?imageMogr2/auto-orient/strip|imageView2/2/w/592/format/webp)

# 4.Ubuntu下 正确安装VMware Tools

为了实现可以从windows拖拽文件到ubuntu，可以[安装VMware Tools](https://link.jianshu.com/?t=http%3A%2F%2Fjingyan.baidu.com%2Falbum%2F93f9803f0d9d9be0e46f55ce.html%3Fpicindex%3D6)。

# 5.Django主要模块

- **urls.py**
    网址入口，关联到对应的views.py中的一个函数（或者generic类），访问网址就对应一个函数。
- **views.py**
    处理用户发出的请求，从urls.py中对应过来, 通过渲染templates中的网页可以将显示内容，比如登陆后的用户名，用户请求的数据，输出到网页。
- **models.py**
    与数据库操作相关，存入或读取数据时用到这个，当然用不到数据库的时候 你可以不使用。
- **forms.py**
    表单，用户在浏览器上输入数据提交，对数据的验证工作以及输入框的生成等工作，当然你也可以不使用。

- **templates 文件夹**
    views.py 中的函数渲染templates中的Html模板，得到动态内容的网页，当然可以用缓存来提高速度。
- **admin.py**
    后台，可以用很少量的代码就拥有一个强大的后台。
- **settings.py**
    Django 的设置，配置文件，比如 DEBUG 的开关，静态文件的位置等。

# 6.Django基本命令

- 新建一个 django project

```css
django-admin.py startproject project_name
特别是在 windows 上，如果报错，尝试用 django-admin 代替 django-admin.py 试试
```

注意 project_name 是自己的项目名称，需要为合法的 Python 包名，如不能为 1a 或 a-b。

- 新建 app
    要先进入项目目录下，cd project_name 然后执行下面的命令（下同，已经在项目目录下则不需要 cd project_name）

```css
python manage.py startapp app_name
或 django-admin.py startapp app_name
```

一般一个项目有多个app, 当然通用的app也可以在多个项目中使用。
与项目名类似 app name 也需要为合法的 Python 包名，如 blog，news, aboutus 等都是合法的 app 名称。

- 创建数据库表 或 更改数据库表或字段

```css
Django 1.7.1及以上 用以下命令
# 1. 创建更改的文件
python manage.py makemigrations
# 2. 将生成的py文件应用到数据库
python manage.py migrate
 
 
旧版本的Django 1.6及以下用
python manage.py syncdb
```

这种方法可以在SQL等数据库中创建与models.py代码对应的表，不需要自己手动执行SQL。
备注：对已有的 models 进行修改，Django 1.7之前的版本的Django都是无法自动更改表结构的，不过有第三方工具 south

- 使用开发服务器
    开发服务器，即开发时使用，一般修改代码后会自动重启，方便调试和开发，但是由于性能问题，建议只用来测试，不要用在生产环境。

```bash
python manage.py runserver
 
# 当提示端口被占用的时候，可以用其它端口：
python manage.py runserver 8001
python manage.py runserver 9999
（当然也可以kill掉占用端口的进程）
 
# 监听机器所有可用 ip （电脑可能有多个内网ip或多个外网ip）
python manage.py runserver 0.0.0.0:8000
# 如果是外网或者局域网电脑上可以用其它电脑查看开发服务器
# 访问对应的 ip加端口，比如 http://172.16.20.2:8000
```

- 清空数据库

```css
python manage.py flush
```

此命令会询问是 yes 还是 no, 选择 yes 会把数据全部清空掉，只留下空表。

- 创建超级管理员

```bash
python manage.py createsuperuser
 
# 按照提示输入用户名和对应的密码就好了邮箱可以留空，用户名和密码必填
 
# 修改 用户密码可以用：
python manage.py changepassword username
```

- Django 项目环境终端

```css
python manage.py shell
```

# 7. Django视图与网址

### 1.Django中网址是写在 urls.py 文件中，用正则表达式对应 views.py 中的一个函数(或者generic类)。

1. 新建一个项目(project), 名称为 zebk

```undefined
django-admin startproject zebk
```

备注： 如果 django-admin 不行，请用 django-admin.py

1. 新建一个应用(app), 名称叫 zhong

```bash
python manage.py startapp zhong  # zhong 是一个app的名称
```

1. 注：Django 1.8.x 以上的，还有一个 migrations 文件夹。Django 1.9.x 还会在 Django 1.8 的基础上多出一个 apps.py 文件。

把我们新定义的app加到settings.py中的INSTALL_APPS中
修改 mysite/mysite/settings.py

```bash
INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
 
    'zhong',
)
```

作用：新建的 app 如果不加到 INSTALL_APPS 中的话, django 就不能自动找到app中的模板文件(app-name/templates/下的文件)和静态文件(app-name/static/中的文件)

### 2.定义视图函数(即访问页面时显示的内容)

打开/zebk下的views.py文件 增加以下内容

```python
# -*- coding: utf-8 -*- 
from django.http import HttpResponse
 
def index(request):
    return HttpResponse(u"hellow 中二病控丶!")
```

1. 第一行是声明编码为`utf-8`, 因为我们在代码中用到了中文,如果不声明就报错.
2. 第二行引入HttpResponse，它是用来向网页返回内容的，就像Python中的 `print` 一样，只不过 `HttpResponse` 是把内容显示到网页上。
3. 我们定义了一个`index()`函数，第一个参数必须是 request，与网页发来的请求有关，request 变量里面包含get或post的内容，用户浏览器，系统等信息在里面（后面会讲，先了解一下就可以）。
4. 函数返回了一个 `HttpResponse` 对象，可以经过一些处理，最终显示几个字到网页上。

### 3. 定义视图函数函数相关的URL

1. 定义视图函数相关的URL(网址) （即规定 访问什么网址对应什么内容）
    打开 mysite/mysite/urls.py 这个文件, 修改其中的代码:
    在mysite/urls.py，导入django.conf.urls.include模块，并且添加到urlpatterns列表，所以mysite/urls.py如下：

```python
# mysite/urls.py
from django.conf.urls import include, url
from django.contrib import admin

urlpatterns = [
    url(r'^zhong/', include('zhong.urls')),
    url(r'^admin/', admin.site.urls),
]
```

2.在zhong中创建urls.py,编写如下：

```python
from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
]
```

然后在终端上运行 python manage.py runserver 我们会看到类似下面的信息:

```csharp
 python manage.py runserver
 
Performing system checks...
 
System check identified no issues (0 silenced).
 
You have unapplied migrations; your app may not work properly until they are applied.
Run 'python manage.py migrate' to apply them.
 
December 22, 2015 - 11:57:33
Django version 1.9, using settings 'mysite.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```

**打开网页，输入127.0.0.1:8000/zhong/**



![img](https://upload-images.jianshu.io/upload_images/6078268-0a6eb481be9d07e7.png?imageMogr2/auto-orient/strip|imageView2/2/w/653/format/webp)

# 8.管理操作

- 站点分为“内容发布”和“公共访问”两部分
- “内容发布”的部分负责添加、修改、删除内容，开发这些重复的功能是一件单调乏味、缺乏创造力的工作。为此，Django会根据定义的模型类完全自动地生成管理模块

### 使用django的管理

创建一个管理员用户

```css
python manage.py createsuperuser，按提示输入用户名、邮箱、密码
```

- 启动服务器，通过“127.0.0.1:8000/admin”访问，输入上面创建的用户名、密码完成登录
- 进入管理站点，默认可以对groups、users进行管理

### 管理界面本地化

- 编辑settings.py文件，设置编码、时区

```bash
LANGUAGE_CODE = 'zh-Hans'
TIME_ZONE = 'Asia/Shanghai'
```

### 向admin注册booktest的模型

- 打开booktest/admin.py文件，注册模型

```jsx
from django.contrib import admin
from models import BookInfo
admin.site.register(BookInfo)
```

- 刷新管理页面，可以对BookInfo的数据进行增删改查操作
- 问题：如果在str方法中返回中文，在修改和添加时会报ascii的错误
- 解决：在str()方法中，将字符串末尾添加“.encode('utf-8')”

### 自定义管理页面

- Django提供了admin.ModelAdmin类
- 通过定义ModelAdmin的子类，来定义模型在Admin界面的显示方式

```css
class QuestionAdmin(admin.ModelAdmin):
    ...
admin.site.register(Question, QuestionAdmin)
```

##### 列表页属性

- list_display：显示字段，可以点击列头进行排序

```bash
list_display = ['pk', 'btitle', 'bpub_date']
```

- list_filter：过滤字段，过滤框会出现在右侧

```bash
list_filter = ['btitle']
```

- search_fields：搜索字段，搜索框会出现在上侧

```bash
search_fields = ['btitle']
```

- list_per_page：分页，分页框会出现在下侧

```undefined
list_per_page = 10
```

##### 添加、修改页属性

- fields：属性的先后顺序

```bash
fields = ['bpub_date', 'btitle']
```

- fieldsets：属性分组

```bash
fieldsets = [
    ('basic',{'fields': ['btitle']}),
    ('more', {'fields': ['bpub_date']}),
]
```

##### 关联对象

- 对于HeroInfo模型类，有两种注册方式
    - 方式一：与BookInfo模型类相同
    - 方式二：关联注册
- 按照BookInfor的注册方式完成HeroInfo的注册
- 接下来实现关联注册

```python
from django.contrib import admin
from models import BookInfo,HeroInfo

class HeroInfoInline(admin.StackedInline):
    model = HeroInfo
    extra = 2

class BookInfoAdmin(admin.ModelAdmin):
    inlines = [HeroInfoInline]

admin.site.register(BookInfo, BookInfoAdmin)
```

- 可以将内嵌的方式改为表格

```ruby
class HeroInfoInline(admin.TabularInline)
```

##### 布尔值的显示

- 发布性别的显示不是一个直观的结果，可以使用方法进行封装

```python
def gender(self):
    if self.hgender:
        return '男'
    else:
        return '女'
gender.short_description = '性别'
在admin注册中使用gender代替hgender
class HeroInfoAdmin(admin.ModelAdmin):
    list_display = ['id', 'hname', 'gender', 'hcontent']
```

## 2018.5.15 更新

了解了下Django的社交用户系统的包 [django-allauth](https://link.jianshu.com/?t=http%3A%2F%2Fdjango-allauth.readthedocs.io%2Fen%2Flatest%2F)，django-allauth是集成了local用户系统和social用户系统，其social用户系统可以挂载多个账户。也是一个流行度非常高的Django user系统。

- 安装

```undefined
pip install django-allauth
```

- 配置

```bash
TEMPLATE_CONTEXT_PROCESSORS = (
"django.contrib.auth.context_processors.auth",
"django.core.context_processors.debug",
"django.core.context_processors.i18n",
"django.core.context_processors.media",
"django.core.context_processors.static",
"django.core.context_processors.tz",
#"django.contrib.messages.context_processors.messages"
# Required by allauth template tags
"django.core.context_processors.request",
# allauth specific context processors
"allauth.account.context_processors.account",
"allauth.socialaccount.context_processors.socialaccount",
)

AUTHENTICATION_BACKENDS = (
# Needed to login by username in Django admin, regardless of `allauth`
"django.contrib.auth.backends.ModelBackend",

# `allauth` specific authentication methods, such as login by e-mail
"allauth.account.auth_backends.AuthenticationBackend",
)

INSTALLED_APPS = (
...
# The Django sites framework is required
'django.contrib.sites',

'allauth',
'allauth.account',
'allauth.socialaccount',
# ... include the providers you want to enable:
'allauth.socialaccount.providers.amazon',
'allauth.socialaccount.providers.angellist',
'allauth.socialaccount.providers.bitbucket',
'allauth.socialaccount.providers.bitly',
'allauth.socialaccount.providers.coinbase',
'allauth.socialaccount.providers.dropbox',
'allauth.socialaccount.providers.facebook',
'allauth.socialaccount.providers.flickr',
'allauth.socialaccount.providers.feedly',
'allauth.socialaccount.providers.github',
'allauth.socialaccount.providers.google',
'allauth.socialaccount.providers.hubic',
'allauth.socialaccount.providers.instagram',
'allauth.socialaccount.providers.linkedin',
'allauth.socialaccount.providers.linkedin_oauth2',
'allauth.socialaccount.providers.openid',
'allauth.socialaccount.providers.persona',
'allauth.socialaccount.providers.soundcloud',
'allauth.socialaccount.providers.stackexchange',
'allauth.socialaccount.providers.tumblr',
'allauth.socialaccount.providers.twitch',
'allauth.socialaccount.providers.twitter',
'allauth.socialaccount.providers.vimeo',
'allauth.socialaccount.providers.vk',
'allauth.socialaccount.providers.weibo',
'allauth.socialaccount.providers.xing',
...
)
```

- urls.py

```python
urlpatterns = patterns('',
...
(r'^accounts/', include('allauth.urls')),
...
)
```

# Django教程（二）- Django视图与网址进阶

0.0962017.07.12 08:45:40字数 1410阅读 1290

### 目录：

> - **Django教程（一）- Django视图与网址**
> - **Django教程（二）- Django视图与网址进阶**
> - **Django教程（三）- Django表单Form**
> - **Django教程（四）- Django模板及进阶**
> - **Django模型(数据库)及Django Query常用方法**
> - **Django教程（五）- 上传及显示**
> - **Django实战（一）- 搭建简单的博客系统**
> - **Django实战（二）- 创建一个课程选择系统**

# 1. HTML表单

HTML 表单用于搜集不同类型的用户输入。
表单是一个包含表单元素的区域。
表单元素是允许用户在表单中输入内容,比如：文本域(textarea)、下拉列表、单选框(radio-buttons)、复选框(checkboxes)等等。
表单使用表单标签 <form> 来设置:

```xml
<form>
input elements
</form>
```

HTML 表单 - 输入元素
多数情况下被用到的表单标签是输入标签（`<input>`）。
输入类型是由类型属性（type）定义的。大多数经常被用到的输入类型如下：

- 文本域（Text Fields）
    文本域通过`<input type="text">` 标签来设定，当用户要在表单中键入字母、数字等内容时，就会用到文本域。

```xml
<form>
First name: <input type="text" name="firstname"><br>
Last name: <input type="text" name="lastname">
</form> 
```

注意:表单本身并不可见。同时，在大多数浏览器中，文本域的缺省宽度是20个字符。

- 密码字段
    密码字段通过标签`<input type="password">` 来定义:

```xml
<form>
Password: <input type="password" name="pwd">
</form> 
```

注意:密码字段字符不会明文显示，而是以星号或圆点替代。

- 单选按钮（Radio Buttons）
    `<input type="radio">` 标签定义了表单单选框选项

```xml
<form>
<input type="radio" name="gender" value="male">Male<br>
<input type="radio" name="gender" value="female">Female
</form> 
```

- 复选框（Checkboxes）
    `<input type="checkbox">` 定义了复选框. 用户需要从若干给定的选择中选取一个或若干选项。

```xml
<form>
<input type="checkbox" name="vehicle" value="Bike">I have a bike<br>
<input type="checkbox" name="vehicle" value="Car">I have a car
</form> 
```

- 提交按钮(Submit Button)
    `<input type="submit">` 定义了提交按钮.
    当用户单击确认按钮时，表单的内容会被传送到另一个文件。表单的动作属性定义了目的文件的文件名。由动作属性定义的这个文件通常会对接收到的输入数据进行相关的处理。:

```xml
<form name="input" action="html_form_action.php" method="get">
Username: <input type="text" name="user">
<input type="submit" value="Submit">
</form
```

# 2.CSRF

[CSRF](https://link.jianshu.com/?t=http://baike.baidu.com/link?url=5ROmJssyDO91x0uGDWXwBJLIroOwtl-92SAWUXvqQPAU5CX0w7aqMrPgLwAN51oGvS8b6BSVttE9XcOSCF0F6q)（Cross-site request forgery）通常缩写为CSRF或者XSRF:跨站请求伪造

CSRF攻击可以理解为：攻击者盗用了你的身份，以你的名义发送恶意请求。
举例来讲，某个恶意的网站上有一个指向你的网站的链接，如果
某个用户已经登录到你的网站上了，那么当这个用户点击这个恶意网站上的那个链接时，就会向你的网站发来一个请求，
你的网站会以为这个请求是用户自己发来的，其实呢，这个请求是那个恶意网站伪造的。

CSRF能够做的事情包括：以你名义发送邮件，发消息，盗取你的账号，甚至于购买商品，虚拟货币转账......造成的问题包括：个人隐私泄露以及财产安全。

**Django 提供的 CSRF 防护机制**
django 第一次响应来自某个客户端的请求时，会在服务器端随机生成一个 token，把这个 token 放在 cookie 里。然后每次 POST 请求都会带上这个 token，
这样就能避免被 CSRF 攻击。

1. 在返回的 HTTP 响应的 cookie 里，django 会为你添加一个 csrftoken 字段，其值为一个自动生成的 token
2. 在所有的 POST 表单时，必须包含一个 csrfmiddlewaretoken 字段 （只需要在模板里加一个 tag， django 就会自动帮你生成，见下面）
3. 在处理 POST 请求之前，django 会验证这个请求的 cookie 里的 csrftoken 字段的值和提交的表单里的 csrfmiddlewaretoken 字段的值是否一样。如果一样，则表明这是一个合法的请求，否则，这个请求可能是来自于别人的 csrf 攻击，返回 403 Forbidden.
4. 在所有 ajax POST 请求里，添加一个 X-CSRFTOKEN header，其值为 cookie 里的 csrftoken 的值

**Django 里如何使用 CSRF 防护：**

1. 首先，最基本的原则是：GET 请求不要用有副作用。也就是说任何处理 GET 请求的代码对资源的访问都一定要是“只读“的。
2. 要启用 django.middleware.csrf.CsrfViewMiddleware 这个中间件
3. 再次，在所有的 POST 表单元素时，需要加上一个 {% csrf_token %} tag
4. 在渲染模块时，使用 RequestContext。RequestContext 会处理 csrf_token 这个 tag, 从而自动为表单添加一个名为 csrfmiddlewaretoken 的 input

# 3.代码操作

**需求：**模拟登录功能，如果用户的名字是你的名字全拼且密码是12345,则显示登录成功，否则登录失败
1.创建app：`python manage.py startapp login`
2.在app中创建`templates`文件夹，并简单写三个网页，分别是登陆页面，登陆成功页面，登陆失败页面。



![img](https://upload-images.jianshu.io/upload_images/6078268-6d3d862b397ebc42.png?imageMogr2/auto-orient/strip|imageView2/2/w/896/format/webp)

login.html

3.建立项目视图的练习，详情请见[Django教程（一）- Django视图与网址](https://www.jianshu.com/p/04207f3f2129)



![img](https://upload-images.jianshu.io/upload_images/6078268-001315d6ab9ca1e4.png?imageMogr2/auto-orient/strip|imageView2/2/w/924/format/webp)

逻辑示意图.png

- 定义视图函数



![img](https://upload-images.jianshu.io/upload_images/6078268-c139265e3e36c5d8.png?imageMogr2/auto-orient/strip|imageView2/2/w/920/format/webp)

定义视图函数views.py

- 在app中创建urls.py,定义视图函数相关的url



![img](https://upload-images.jianshu.io/upload_images/6078268-c852cb7438e7e5b2.png?imageMogr2/auto-orient/strip|imageView2/2/w/885/format/webp)

创建urls.py

- 在项目的urls.py中，导入django.conf.urls.include模块，并且添加到urlpatterns列表



![img](https://upload-images.jianshu.io/upload_images/6078268-17886ae72ba35feb.png?imageMogr2/auto-orient/strip|imageView2/2/w/886/format/webp)

修改项目中的urls.py

- 把新定义的app加到settings.py中的INSTALL_APPS中
    **测试：**



![img](https://upload-images.jianshu.io/upload_images/6078268-de2a846ae3e8079e.png?imageMogr2/auto-orient/strip|imageView2/2/w/945/format/webp)

输入正确的用户名和密码：



![img](https://upload-images.jianshu.io/upload_images/6078268-9d065aa937cc8197.png?imageMogr2/auto-orient/strip|imageView2/2/w/813/format/webp)

反之：



![img](https://upload-images.jianshu.io/upload_images/6078268-aaafce3b4c50e326.png?imageMogr2/auto-orient/strip|imageView2/2/w/807/format/webp)

~~这里只是为了完成需求，不考虑网页的显示的效果！233~~

**注意：**测试之前需在终端打开服务器`python manage.py runserver 8001`(端口号默认是8000，也可以选择不设置！)

# Django教程（三） Django表单Form

#1.Form 基本使用 **django中的Form组件有以下几个功能：**

> 1. 生成HTML标签

1. 验证用户数据（显示错误信息）
2. HTML Form提交保留上次提交数据
3. 初始化页面显示内容

\#2.Form中字段及插件 创建Form类时，主要涉及到 【字段】 和 【插件】，字段用于对用户请求数据的验证，插件用于自动生成HTML;

\#### 1.Django内置字段如下：

- **Field:**

```
required=True,               是否允许为空
widget=None,                 HTML插件
label=None,                  用于生成Label标签或显示内容
initial=None,                初始值
help_text='',                帮助信息(在标签旁边显示)
error_messages=None,         错误信息 {'required': '不能为空', 'invalid': '格式错误'}
show_hidden_initial=False,   是否在当前插件后面再加一个隐藏的且具有默认值的插件（可用于检验两次输入是否一致）
validators=[],            自定义验证规则(from django.core import validators)
localize=False,              是否支持本地化（根据不同语言地区访问用户显示不同语言）
disabled=False,              是否可以编辑
label_suffix=None            Label内容后缀
```

- **CharField(Field)**

```
max_length=None,             最大长度
min_length=None,             最小长度
strip=True                   是否移除用户输入空白
```

- **IntegerField(Field), FloatField(IntegerField)** 他们之间的继承关系

```
max_value=None,              最大值
min_value=None,              最小值
```

- **DecimalField(IntegerField) 小数，举例，涉及金钱计算保留小数点后两位**

```
max_value=None,              最大值
min_value=None,              最小值
max_digits=None,             总长度
decimal_places=None,         小数位长度
```

- **BaseTemporalField(Field)**

```
input_formats=None          时间格式化

DateField(BaseTemporalField)    格式：2015-09-01
TimeField(BaseTemporalField)    格式：11:12
DateTimeField(BaseTemporalField)格式：2015-09-01 11:12
DurationField(Field)            时间间隔：%d %H:%M:%S.%f
```

- **RegexField(CharField)**

```
regex,                      自定制正则表达式
max_length=None,            最大长度
min_length=None,            最小长度
error_message=None,         忽略，错误信息使用 error_messages={'invalid': '...'}
```

**EmailField(CharField) ...**

- **FileField(Field)**

```
allow_empty_file=False     是否允许空文件
```

- **ImageField(FileField)**

```
...
注：需要PIL模块，pip install Pillow
以上两个字典使用时，需要注意两点：
- form表单中 enctype="multipart/form-data"
- view函数中 obj = MyForm(request.POST, request.FILES)
```

**URLField(Field)... BooleanField(Field)... NullBooleanField(BooleanField)...**

- **ChoiceField(Field)**

```
choices=(),                选项，如：choices = ((0,'上海'),(1,'北京'),)
required=True,             是否必填
widget=None,               插件，默认select插件
label=None,                Label内容
initial=None,              初始值
help_text='',              帮助提示
```

- **TypedChoiceField(ChoiceField)**

```
coerce = lambda val: val   对选中的值进行一次转换，通过lambda函数实现
empty_value= ''            空值的默认值
```

- **MultipleChoiceField(ChoiceField)多选框...**
- **TypedMultipleChoiceField(MultipleChoiceField)**

```
coerce = lambda val: val   对选中的每一个值进行一次转换
empty_value= ''            空值的默认值
```

- **ComboField(Field)**

```
fields=()                  使用多个验证，如下：即验证最大长度20，又验证邮箱格式
fields.ComboField(fields=[fields.CharField(max_length=20), fields.EmailField(),])
```

- **MultiValueField(Field)：** 抽象类，子类中可以实现聚合多个字典去匹配一个值，要配合MultiWidget使用，提供接口，需要自己实现
- **SplitDateTimeField(MultiValueField)**

```
input_date_formats=None,   格式列表：['%Y--%m--%d', '%m%d/%Y', '%m/%d/%y']
input_time_formats=None    格式列表：['%H:%M:%S', '%H:%M:%S.%f', '%H:%M']
```

- **FilePathField(ChoiceField)** 文件选项，目录下文件显示在页面中

```
path,                      文件夹路径
match=None,                正则匹配
recursive=False,           递归下面的文件夹
allow_files=True,          允许文件
allow_folders=False,       允许文件夹
required=True,
widget=None,
label=None,
initial=None,
help_text=''
```

- **GenericIPAddressField**

```
protocol='both',           both,ipv4,ipv6支持的IP格式
unpack_ipv4=False          解析ipv4地址，如果是::ffff:192.0.2.1时候，可解析为192.0.2.1， PS：protocol必须为both才能启用
```

- **SlugField(CharField) ：**数字，字母，下划线，减号（连字符）
- **UUIDField(CharField) ：**uuid类型

```python
import uuid

# make a UUID based on the host ID and current time
>>> uuid.uuid1()    # doctest: +SKIP
UUID('a8098c1a-f86e-11da-bd1a-00112444be1e')

# make a UUID using an MD5 hash of a namespace UUID and a name
>>> uuid.uuid3(uuid.NAMESPACE_DNS, 'python.org')
UUID('6fa459ea-ee8a-3ca4-894e-db77e160355e')

# make a random UUID
>>> uuid.uuid4()    # doctest: +SKIP
UUID('16fd2706-8baf-433b-82eb-8c7fada847da')

# make a UUID using a SHA-1 hash of a namespace UUID and a name
>>> uuid.uuid5(uuid.NAMESPACE_DNS, 'python.org')
UUID('886313e1-3b8a-5372-9b90-0c9aee199e5d')

# make a UUID from a string of hex digits (braces and hyphens ignored)
>>> x = uuid.UUID('{00010203-0405-0607-0809-0a0b0c0d0e0f}')

# convert a UUID to a string of hex digits in standard form
>>> str(x)
'00010203-0405-0607-0809-0a0b0c0d0e0f'

# get the raw 16 bytes of the UUID
>>> x.bytes
b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\t\n\x0b\x0c\r\x0e\x0f'

# make a UUID from a 16-byte string
>>> uuid.UUID(bytes=x.bytes)
UUID('00010203-0405-0607-0809-0a0b0c0d0e0f')
复制代码
```

- **Django内置插件：**

```
TextInput(Input)  #input type="text"
NumberInput(TextInput)  # 数字输入框
EmailInput(TextInput)  # 邮箱输入框
URLInput(TextInput)  # url输入框
PasswordInput(TextInput)  # 密码输入框
HiddenInput(TextInput)  # 隐藏输入框
Textarea(Widget)  # textarea文本区
DateInput(DateTimeBaseInput)  # 日期输入框
DateTimeInput(DateTimeBaseInput)  # 日期时间输入框
TimeInput(DateTimeBaseInput)  # 时间输入框
CheckboxInput  # 多选框
Select  # 下拉框
NullBooleanSelect  # 非空布尔值下拉框
SelectMultiple  # 多选下拉框
RadioSelect  # 单选框
CheckboxSelectMultiple  # 多选checkbox ？？？
FileInput  # 文件上传
ClearableFileInput
MultipleHiddenInput  # 多隐藏输入框
SplitDateTimeWidget  # 时间分割框（两个input框）
SplitHiddenDateTimeWidget
SelectDateWidget
```

- **常用的选择插件**

```python
# 单radio，值为字符串
# user = fields.CharField(
#     initial=2,
#     widget=widgets.RadioSelect(choices=((1,'上海'),(2,'北京'),))
# )

# 单radio，值为字符串
# user = fields.ChoiceField(
#     choices=((1, '上海'), (2, '北京'),),
#     initial=2,
#     widget=widgets.RadioSelect
# )

# 单select，值为字符串
# user = fields.CharField(
#     initial=2,
#     widget=widgets.Select(choices=((1,'上海'),(2,'北京'),))
# )

# 单select，值为字符串
# user = fields.ChoiceField(
#     choices=((1, '上海'), (2, '北京'),),
#     initial=2,
#     widget=widgets.Select
# )

# 多选select，值为列表
# user = fields.MultipleChoiceField(
#     choices=((1,'上海'),(2,'北京'),),
#     initial=[1,],
#     widget=widgets.SelectMultiple
# )



# 单checkbox
# user = fields.CharField(
#     widget=widgets.CheckboxInput()
# )


# 多选checkbox,值为列表
# user = fields.MultipleChoiceField(
#     initial=[2, ],
#     choices=((1, '上海'), (2, '北京'),),
#     widget=widgets.CheckboxSelectMultiple
# )
```

**Django模版加减乘除：**

```python
Django模版加法：
{{ value|add:10}}
value=5，则返回15 Django模版减法：
{{value|add:-10}}
value=5，则返回-5，这个比较好理解，减法就是加一个负数 Django模版乘法：
{%  widthratio 5 1 100 %}
上面的代码表示：5/1 *100，返回500，widthratio需要三个参数，它会使用 参数1/参数2*参数3，所以要进行乘法的话，就将参数2=1即可 Django模版除法
view sourceprint?
{%  widthratio 5 100 1 %}
上面的代码表示：5/100*1，返回0.05，只需要将第三个参数设置为1即可 
```

------

\#3.通过Django表单Form来完成需求 ###1.根据用户填写表单的不同跳往不同的页面 1.先创建app项目名:djangoform

![树形图](https://user-gold-cdn.xitu.io/2018/1/18/16107e57805ff4fe?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



2.app下创建文件夹djangoform,并建立表单`form1.py`

```python
# -*- coding:utf8 -*-
from django.forms import Form
from django.forms import widgets  # 插件
from django.forms import fields # 字段

class webpage(Form):
    page = fields.CharField()
```

3.app下创建templates文件夹，并创建不同的html网页

- index.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>首页</title>
</head>
<body>

    <form action="" method="post">
        {% csrf_token %}

        请选择要进入的页面：{{ web.page }}
        <input type="submit" value="提交">

    </form>

</body>
</html>
```

- page1.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>page1</title>
</head>
<body>


        Page1:一颦一笑一伤悲,一生痴迷一世醉.


</body>
</html>
```

- page2.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>page2</title>
</head>
<body>

        Page2:一嗟一叹一轮回,一寸相思一寸灰.


</body>
</html>
```

其他几个网页类似 4.建立视图views.py

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render,redirect
from django.http import HttpResponse
from django.forms import form1

# Create your views here.


def indexPage(request):
    if request.method == "GET":
        webPage=form1.webpage()
        return render(request,'index.html',{'web':webPage})

    elif request.method == "POST":
        webPage = form1.webpage(request.POST,request.FILES)
        if webPage.is_valid():
            values = webPage.clean()
            print(values)
            if values['page'] == '1':
                return render(request, 'page1.html', {'web': webPage})
            elif values['page']== '2':
                return render(request, 'page2.html', {'web': webPage})
            elif values['page']== '3':
                return render(request, 'page3.html', {'web': webPage})
        else:
            errors = webPage.errors
            print(errors)
        return render(request, 'index.html', {'web': webPage})
    else:
        return redirect('http://www.baidu.com')




def index(request):
    if request.method == "GET":
        obj = forms.MyForm()  # 没有值，在页面上渲染form中的标签
        return render(request, 'index.html', {'form': obj})

    elif request.method == "POST":
        obj = forms.MyForm(request.POST, request.FILES)  # 将post提交过来的数据作为参数传递给自定义的Form类
        if obj.is_valid():  # obj.is_valid()返回一个bool值，如果检查通过返回True，否则返回False
            values = obj.clean()  # 拿到处理后的所有数据，键值对的形式
            print(values)
        else:
            errors = obj.errors  # 拿到未通过的错误信息，里面封装的都是对象
            print(errors)
        return render(request, 'index.html', {'form': obj})
    else:
        return redirect('http://www.baidu.com')
```

5.定义视图函数相关的·urls.py·

```python
from django.conf.urls import include, url
from django.contrib import admin
from . import views

urlpatterns = [
    url(r'^page/',views.indexPage),
]
```

6.把我们新定义的app加到settings.py中的INSTALL_APPS中和urls中，详情见[Django教程（一）- Django视图与网址](https://link.juejin.im/?target=http%3A%2F%2Fwww.jianshu.com%2Fp%2F04207f3f2129)

\##2.在网页上打印9*9乘法表

- home.html

```python
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>九九乘法表</title>
</head>
<body>
    {% for i in list %}
        {% for j in list %}
            {% if j <= i %}
                {{i}}*{{j}}={% widthratio j 1 i %}
            {% endif %}
        {% endfor %}<br>
    {% endfor %}



</body>
</html>
```

- views.py

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render

# Create your views here.

def home(request):
    list= [1,2,3,4,5,6,7,8,9,]
    return render(request,'home.html',{'list':list})
```

- urls.py

```python
from django.conf.urls import url
from . import views

urlpatterns=[
    url(r'^home/$',views.home,name='home',)
]
```

效果展示：



![九九乘法表](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="820" height="406"></svg>)



\##3.在网页上打印1-100之间的偶数 **先了解下python中map函数**

```
>>> map(str, range(5))           #对range(5)各项进行str操作
['0', '1', '2', '3', '4']        #返回列表
>>> def add(n):return n+n
... 
>>> map(add, range(5))           #对range(5)各项进行add操作
[0, 2, 4, 6, 8]
>>> map(lambda x:x+x,range(5))   #lambda 函数，各项+本身
[0, 2, 4, 6, 8]
>>> map(lambda x:x+1,range(10))  #lambda 函数，各项+1
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
>>> map(add,'zhoujy')            
['zz', 'hh', 'oo', 'uu', 'jj', 'yy']

#想要输入多个序列，需要支持多个参数的函数，注意的是各序列的长度必须一样，否则报错：
>>> def add(x,y):return x+y
... 
>>> map(add,'zhoujy','Python')
['zP', 'hy', 'ot', 'uh', 'jo', 'yn']
>>> def add(x,y,z):return x+y+z
... 
>>> map(add,'zhoujy','Python','test')     #'test'的长度比其他2个小
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: add() takes exactly 2 arguments (3 given)

>>> map(add,'zhoujy','Python','testop')
['zPt', 'hye', 'ots', 'uht', 'joo', 'ynp']
复制代码
```

- views.py

```
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render

# Create your views here.

def even(request):
    list = map(str,range(100))  #对range(100)各项进行str操作
    return render(request,'even.html',{'list':list})
复制代码
```

- urls.py

```
from django.conf.urls import url
from . import views

urlpatterns=[
    url(r'^even/$',views.even,name='even',)
]

复制代码
```

- even.html

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>1-100之间的偶数</title>
</head>
<body>
    {% for item in list %}
    {% if forloop.counter|divisibleby:2 %}{{forloop.counter}} {% if not forloop.last %},{% endif %} {% endif %}
    {% endfor %}



</body>
</html>
复制代码
```

**效果如下：**



![在网页上打印1-100之间的偶数](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1240" height="440"></svg>)



\#4.自定义验证验证规则

- **方式1：在字段中自定义validators设计正则匹配**

```
from django.forms import Form
from django.forms import widgets
from django.forms import fields
from django.core.validators import RegexValidator

class MyForm(Form):
    user = fields.CharField(
        validators=[RegexValidator(r'^[0-9]+$', '请输入数字'), RegexValidator(r'^159[0-9]+$', '数字必须以159开头')],
    )
复制代码
```

- **方式2：自定义规则函数处理数据**

```
import re
from django.forms import Form
from django.forms import widgets
from django.forms import fields
from django.core.exceptions import ValidationError


# 自定义验证规则
def mobile_validate(value):
    mobile_re = re.compile(r'^(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$')
    if not mobile_re.match(value):
        raise ValidationError('手机号码格式错误')


class PublishForm(Form):


    title = fields.CharField(max_length=20,
                            min_length=5,
                            error_messages={'required': '标题不能为空',
                                            'min_length': '标题最少为5个字符',
                                            'max_length': '标题最多为20个字符'},
                            widget=widgets.TextInput(attrs={'class': "form-control",
                                                          'placeholder': '标题5-20个字符'}))


    # 使用自定义验证规则
    phone = fields.CharField(validators=[mobile_validate, ],
                            error_messages={'required': '手机不能为空'},
                            widget=widgets.TextInput(attrs={'class': "form-control",
                                                          'placeholder': u'手机号码'}))

    email = fields.EmailField(required=False,
                            error_messages={'required': u'邮箱不能为空','invalid': u'邮箱格式错误'},
                            widget=widgets.TextInput(attrs={'class': "form-control", 'placeholder': u'邮箱'}))
```

# Django教程（四）- Django模板及进阶
代码操作：

- **home.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>模板实例</title>
</head>
<body>
    <!--1.显示一个基本的字符串在网页上-->
    <!--{{ string }}-->

    <!--2.基本的 for 循环 和 List内容的显示-->
    <!--{% for i in list %}-->
    <!--{{ i }}-->
    <!--{% endfor %}-->

    <!--3.显示字典中内容-->
    <!--{% for key,value in dict.items %}-->
    <!--{{ key }}:{{ value }}-->
    <!--{% endfor %}-->

    <!--4.在模板进行 条件判断和 for 循环的详细操作：-->
    <!--{% for i in list %}-->
    <!--{{ i }}{% if not forloop.last %},{% endif %}-->
    <!--{% endfor %}-->

    <!--#5.模板上得到视图对应的网址：-->
    <!--<a href="{% url 'h' 4 5 %}" >友情链接</a>-->

    <!--6.模板中的逻辑操作：-->
    <!--{% if var >= 90 %}-->
    <!--成绩优秀-->
    <!--{% elif var >= 80 %}-->
    <!--成绩良好-->
    <!--{% elif var >= 70 %}-->
    <!--成绩一般-->
    <!--{% elif var >= 60 %}-->
    <!--需要努力-->
    <!--{% else %}-->
    <!--不及格-->
    <!--{% endif %}-->

    <!--7.模板中 获取当前网址，当前用户等：-->
    <!--{{ request.user }}-->

    <!--8.过滤器-->
    {{ var|lower }}



</body>
</html>
```

- **views.py**

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render,redirect
from temforms import temform
from django.http import HttpResponse

# Create your views here.
# 简单的模板
# def test(request):
#     return render(request,'new.html',)

# 1.显示一个基本的字符串在网页上
# def home(request):
#     string =u'遇见你真是三生有幸❤'
#     return render(request,'home.html',{'string':string})

# 2.基本的 for 循环 和 List内容的显示
# def home(request):
#     list =['L','o','v','e','x','l']
#     return render(request,'home.html',{'list':list})

# 3.显示字典中内容
# def home(request):
#     dict={'name':'中二病控','age':'22','interset':'write'}
#     return render(request,'home.html',{'dict':dict})

# 4.在模板进行 条件判断和 for 循环的详细操作：
# def home(request):
#     list = map(str,range(20))# 一个长度为10的 List，对range(20)各项进行str操作
#     return render(request,'home.html',{'list':list})

#5.模板上得到视图对应的网址：
def add(request,a,b):
    c= int(a)+int(b)
    return HttpResponse(str(c))


#6.模板中的逻辑操作：
# def home(request):
#     return render(request, 'home.html', {'var': 20})

# 7.模板中 获取当前网址，当前用户等：
def home(request):
     return render(request, 'home.html', )
# 8.过滤器
def home(request):
     return render(request, 'home.html', {'var': 'LOVER'})
```

- **urls.py**

```python
from django.conf.urls import include, url
from django.contrib import admin
from . import views

urlpatterns = [
     # url(r'^test/',views.test,),
    url(r'^home/',views.home,),
    url(r'^add/(\d+)/(\d+)/$',views.add,name='h')

]
```

需求：编写注册提交，“密码”与“确认密码”不一致，显示密码不一样。成功后在另一个页面显示
代码操作：



![img](https://upload-images.jianshu.io/upload_images/6078268-5f2a19069dc97580.png?imageMogr2/auto-orient/strip|imageView2/2/w/628/format/webp)

文件树形图显示

- **ofForm.py**

```python
# -*- coding:utf-8 -*-
from django.forms import Form,widgets,fields
from django import forms

class ofForm(Form):
    userName = fields.CharField(max_length=10)
    password = fields.CharField(max_length=10,widget=widgets.PasswordInput)
    repassword = fields.CharField(max_length=10,widget=widgets.PasswordInput)

    def clean(self):
        password = self.cleaned_data['password']
        repassword = self.cleaned_data['repassword']
        if not password == repassword:
            print 'error'
            myerror = 'password is different from repassword,please write again!'
            raise forms.ValidationError(myerror)

        return self.cleaned_data
```

- **index.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>首页</title>
</head>
<body>
<form action="" method="post">
    {% csrf_token %}
    用户名：{{ form.userName }}<br>
    密码：{{ form.password }}<br>
    确认密码：{{ form.repassword }}{{form.non_field_errors}}<br>

    <input type="submit" value="注册">


</form>

</body>
</html>
```

- **urls.py**

```python
from django.conf.urls import url
from django.contrib import admin
from . import views

urlpatterns = [
    url(r'^reg/$',views.register)

]
```

- **views.py**

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.http import HttpResponse
from ofForms import ofForm
from models import UserModel


# Create your views here.
def register(request):
    if request.method == 'GET':
        form =ofForm.ofForm()
        return render(request,'index.html',{'form':form})
    elif request.method == 'POST':
        form = ofForm.ofForm(request.POST)
        if form.is_valid():
            userModel = UserModel()
            userModel.userName = form.cleaned_data['userName']
            userModel.password = form.cleaned_data['password']
            userModel.save()

            return HttpResponse('数据提交成功！')
        else:
            return render(request,'index.html',{'form':form})
```

- **models.py**

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models

# Create your models here.
class UserModel(models.Model):
    userName = models.CharField(max_length=10)
    password = models.CharField(max_length=10)
```

效果展示：



![img](https://upload-images.jianshu.io/upload_images/6078268-5c7c35627fc11fab.png?imageMogr2/auto-orient/strip|imageView2/2/w/813/format/webp)

首页



![img](https://upload-images.jianshu.io/upload_images/6078268-f9142d0186e5860a.png?imageMogr2/auto-orient/strip|imageView2/2/w/817/format/webp)

两次密码一致



![img](https://upload-images.jianshu.io/upload_images/6078268-163b7e43d58ee3a5.png?imageMogr2/auto-orient/strip|imageView2/2/w/820/format/webp)

两次密码不一致

# Django教程（五）- 上传及显示

## 上传及显示

##### model.py

```python
from django.db import models

# Create your models here.

class Profile(models.Model):
   name = models.CharField(max_length = 50)
   picture = models.ImageField(upload_to = 'pictures/')
```

##### views.py

```python
from django.shortcuts import render
from django import forms
from .models import Profile
# Create your views here.

class ProfileForm(forms.Form):
   name = forms.CharField(max_length = 100)
   picture = forms.ImageField()


def saveProfile(request):


    if request.method == "POST":
        # Get the posted form
        MyProfileForm = ProfileForm(request.POST, request.FILES)

        if MyProfileForm.is_valid():
            profile = Profile()
            profile.name = MyProfileForm.cleaned_data["name"]
            profile.picture = MyProfileForm.cleaned_data["picture"]
            profile.save()

    else:
        MyProfileForm = ProfileForm()

    return render(request, 'saved.html', {"form":MyProfileForm})

def showImages(request):
    objs = Profile.objects.all()
    print objs
    return  render(request,"list.html",{"pics":objs})
```

##### 工程目录的urls

```python
from django.conf.urls import include, url
from django.contrib import admin
from django.conf.urls.static import static
from django.conf import settings


urlpatterns = [
    url(r'imgapp/',include("imgapp.urls")),
    url(r'^admin/', include(admin.site.urls)),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

##### 工程目录settings增加下列代码

```csharp
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR,'media')

INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    'imgapp'
)
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR,'media')
```

##### App目录下的urls

```python
from django.conf.urls import url

from . import views
urlpatterns = [


    url(r'^upload/$',views.saveProfile,name="upload"),
    url(r'^showlist/$',views.showImages,name="showlist"),

]
```

##### 创建templates文件夹，分别创建saved.html，list.html

saved.html上传图片

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
    <form action="{{ request.path }}"  method="POST" enctype="multipart/form-data">
        {% csrf_token %}
        {{form.name}}<br/>
        {{form.picture}}

        <input type="submit" value="upload">
    </form>

</body>
</html>
```

##### list.html显示上传的图片

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
    {% for pic in pics %}

    ![]({{ pic.picture.url }})
    <br/>

    {%endfor%}

</body>
</html>
```

实例代码操作：
显示之前先安装`pip install pillow`



![img](https://upload-images.jianshu.io/upload_images/6078268-d407f3e7cfaef527.png?imageMogr2/auto-orient/strip|imageView2/2/w/650/format/webp)

上传树形图

- **views.py**

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from . import models
from django.forms import fields,Form,widgets
from django.http import HttpResponse
# Create your views here.



class uploadForm(Form):
    introduce = fields.CharField(max_length=50)
    picPath = fields.ImageField()



def load(request):
    if request.method == 'GET':
        uploadform = uploadForm()
        return render(request,'upload.html',{'form':uploadform})
    elif request.method == 'POST':
        uploadform = uploadForm(request.POST,request.FILES)
        if uploadform.is_valid():
            Load = models.loadmodel()
            Load.introduce = uploadform.cleaned_data['introduce']
            Load.picPath = uploadform.cleaned_data['picPath']
            Load.save()
            pics = models.loadmodel.objects.all()
            return render(request,'pics.html',{'pics':pics})

    else:
        return render(request,'upload.html')


def showAll(request):
    pics = models.loadmodel.objects.all()
    return render(request,'pics.html',{'pics':pics})
```

- **urls.py**

```python
from django.conf.urls import url
from . import views

urlpatterns = [
    url(r'upload/$',views.load,name='upload'),
    url(r'showAll/$',views.showAll,name='showAll'),
]
```

- **models.py**

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models


    # Create your models here.
class loadmodel(models.Model):
    introduce = models.CharField(max_length=50)
    picPath = models.ImageField(upload_to='pictures/',)
```

- **pics.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>图片显示</title>
</head>
<body>

        <h1>图片显示</h1>
        {% for pic in pics %}
        ![]({{ pic.picPath.url }})
        <br>

        {% endfor %}


</body>
</html>
```

- **upload.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>上传</title>
</head>
<body>
    <form action="" method="POST" enctype="multipart/form-data">
        {% csrf_token %}
        描述：{{form.introduce}}<br>
        {{form.picPath}}<br>

        <input type="submit" value="确定上传">

    </form>

</body>
</html>
```



![img](https://upload-images.jianshu.io/upload_images/6078268-c73153f82b3874a3.gif?imageMogr2/auto-orient/strip|imageView2/2/w/650/format/webp)

上传

# Django实战（一）- 搭建简单的博客系统

## 1.要求

> 1、用户可以注册、登录
> 2、登陆后，用户可以发表博客、查看博客列表、修改博客、删除博客；博客包含标题、内容、照片
> 3、如果用户没有登录就尝试发表博客、修改博客、删除博客，提示用户去登录
> 4、每个用户只能看见自己发表的博客
> 5、提供标题关键词查找功能，查找后列出所有标题包含关键字的博客

## 2.代码操作



![img](https://upload-images.jianshu.io/upload_images/6078268-872bbc55766e9764.png?imageMogr2/auto-orient/strip|imageView2/2/w/945/format/webp)

blogapp文件树形图

- **blogForm.py**

```python
# -*- coding:utf-8 -*-
from django.forms import Form,widgets,fields,ValidationError




class register(Form):
    userName = fields.CharField(max_length=10)
    password = fields.CharField(max_length=10,widget=widgets.PasswordInput)
    repassword = fields.CharField(max_length=10,widget=widgets.PasswordInput)

    def  clean(self):

        password = self.cleaned_data['password']
        repassword = self.cleaned_data['repassword']
        if not password == repassword:
            myerror = '两次密码不一致,请重新输入'
            raise ValidationError(myerror)

        return self.cleaned_data


class login(Form):
    userName = fields.CharField(max_length=10)
    password = fields.CharField(max_length=10,widget=widgets.PasswordInput)

class BlogForm(Form):
    title = fields.CharField(max_length=20)
    content = fields.CharField(max_length=200)
    pic = fields.ImageField()
```

- **html**
- **addblog.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>添加博客</title>
</head>
<body>
        <form action="{{request.path}}" enctype="multipart/form-data" method="POST">
            {% csrf_token %}
            标题：{{blogform.title}}<br>
            内容：{{blogform.content}}<br>
            配图：{{blogform.pic}}<br>
            <input type="submit" value="发表">

        </form>
         <a href="{% url 'blogapp:bloglist' %}">返回文章列表</a>


</body>
</html>
```

- **html**
- **bloglist.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>显示博客列表</title>
</head>
<body>
        <form action="{% url 'blogapp:search' %}" method="get">
            <input type="text" name="keyword" value="{{ keyword }}">
            <input type="submit" value="查询">

        </form>
        <a href="{% url 'blogapp:addblog' %}">写博客</a>


    <h1>文章列表：</h1><br>
    {% for blog in blogs %}
        <a href="{% url 'blogapp:detailblog' %}?blogid={{blog.id}}">{{blog.title}}</a>
        <a href="{% url 'blogapp:editblog' %}?blogid={{blog.id}}">修改</a>|
        <a href="{% url 'blogapp:delblog' %}?blogid={{blog.id}}">删除</a><br>
    {% endfor %}
    <!--这里'blogapp:detailblog'是因为setting中给blogapp加了命名空间，为了区别不同的代码功能，也看不加-->

        <a href="{% url 'blogapp:bloglist' %}">返回文章列表</a>

        <a href="{% url 'blogapp:logout' %}">用户注销</a>

</body>
</html>
```

- **html**
- **detailblog.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>显示每篇博客的内容</title>
</head>
<body>


    文章标题：{{blog.title}}<br>
    内   容：{{blog.content}}<br>
    配   图：![]({{blog.pic.url}})


</body>
</html>
```

- **html**
- **editblog.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>添加博客</title>
</head>
<body>
        <form action="{{request.path}}" enctype="multipart/form-data" method="post">
            {% csrf_token %}
            <input type="hidden" value="{{ id }}">
            标题：{{blogform.title}}<br>
            内容：{{blogform.content}}<br>
            配图：{{blogform.pic}}<br>
            <input type="submit" value="修改">

        </form>
         <a href="{% url 'blogapp:bloglist' %}">返回文章列表</a>



</body>
</html>
```

- **html**
- **login.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>登录</title>
</head>
<body>
    <form action="{{request.path}}" method="POST">
        {% csrf_token %}

        <a href="{% url 'register' %}">没有账号？去注册</a><br>


        用户名：{{loginform.userName}}<br>
        密   码：{{loginform.password}}<br>{{error}}<br>

        <input type="submit" value="登录">
         <a href="{% url 'blogapp:bloglist' %}">博客列表</a>



    </form>


</body>
</html>
```

- **html**
- **register.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>注册页面</title>
</head>
<body>
    <form action="" method="post">
        {% csrf_token %}
        用户名：{{form.userName}}{{error}}<br>
        密  码：{{form.password}}<br>
        确认密码：{{form.repassword}}<br>{{form.non_field_errors}}<br>

    <input type="submit" value="注册">
    <a href="{% url 'bloglogin' %}">已有账号,去登录</a>


        </form>
</body>
</html>
```

- **html**
- **loginsuc.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>登录成功</title>
</head>
<body>
    登陆成功了，开不开心，意不意外。怎么还有一个网页？哈哈哈哈哈哈～

    <a href="{% url 'blogapp:bloglist' %}">博客列表</a>

</body>
</html>
```

- **html**
- **search.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>显示博客列表</title>
</head>
<body>

    文章列表：<br>
    {% for blog in blogs %}
        <a href="{% url 'blogapp:detailblog' %}?blogid={{blog.id}}">{{blog.title}}</a>
        <a href="{% url 'blogapp:editblog' %}?blogid={{blog.id}}">修改</a>|
        <a href="{% url 'blogapp:delblog' %}?blogid={{blog.id}}">删除</a><br>
    {% endfor %}
    <!--这里'blogapp:detailblog'是因为setting中给blogapp加了命名空间，为了区别不同的代码功能，也看不加-->



</body>
</html>
```

- **views**
- **user_views.py**

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render,redirect
from blogapp.models import User
from django.http import HttpResponse
from blogapp import models

from blogapp.blogForms import blogForm

# Create your views here.
#注册功能
def register(request):
    if request.method == 'GET':
        form = blogForm.register()
        return render(request,'blogapp/register.html',{'form':form})
    elif request.method == 'POST':
        form = blogForm.register(request.POST)
        if form.is_valid():
            temp = models.User.objects.filter(userName=form.cleaned_data['userName']).exists()

            if temp == False:
                userModel = User()
                userModel.userName = form.cleaned_data['userName']
                userModel.password = form.cleaned_data['password']

                userModel.save()
                return HttpResponse('数据提交成功!快去登录吧.')
            else:
                error = '用户名已经存在，请换一个用户名试试!'
                return render(request,'blogapp/register.html',{'form':form,'error':error})

        else:
            return render(request,'blogapp/register.html',{'form':form})

#登录功能
def login(request):
    if request.method == 'GET':
        loginform = blogForm.login()
        return render(request,'blogapp/login.html',{'loginform':loginform})
    elif request.method == 'POST':
        loginform = blogForm.login(request.POST,)
        if loginform.is_valid():
            userName = loginform.cleaned_data['userName']
            password = loginform.cleaned_data['password']

            user = models.User.objects.filter(userName=userName).filter(password=password)
            if user.exists():
                request.session['user_id'] = user[0].id

                return render(request,'blogapp/loginsuc.html')
            else:
                error = '用户名或者密码输入有误，请重试'
                return render(request,'blogapp/login.html',{'loginform':loginform,'error':error})
        else:
            return render(request,'blogapp/login.html',{'loginform':loginform})
    else:
        return redirect('https://www.zhihu.com/')

#注销功能
def logout(request):
    userId = request.session.get('user_id',None)
    if not userId == None:
        del request.session['user_id']
        return HttpResponse('注销成功')
    else:
        return HttpResponse('你的操作不合法')
```

- **views**
- **blog_views.py**

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals


from django.shortcuts import render,redirect
from blogapp.models import User
from django.http import HttpResponse
from blogapp import models

from blogapp.blogForms import blogForm

from django.core.urlresolvers import reverse #引入重定向的包


#验证用户是否登录
def checkLogin(session):
    #session 键user_id如果不存在对应的值
    id = session.get('user_id',None)
    if id==None:
        #转到登录页面
        return False,redirect(reverse('blogapp:bloglogin'))
    else:
        return True,id

#增加博客内容
def addBlog(request):
    #强制登录验证
    isPassed,next=checkLogin(request.session)
    if not isPassed:
        return next
    if request.method == 'GET':
       blogform = blogForm.BlogForm()
       return render(request,'blogapp/addblog.html',{'blogform':blogform})
    elif request.method == 'POST':
        submitForm = blogForm.BlogForm(request.POST,request.FILES)
        if submitForm.is_valid():
            newBlog = models.Blog()
            newBlog.pic = submitForm.cleaned_data['pic']
            newBlog.title = submitForm.cleaned_data['title']
            newBlog.content = submitForm.cleaned_data['content']
            newBlog.authorId = request.session['user_id']

            newBlog.save()

            return HttpResponse('发表成功QAQ.')
        else:
            return render(request,'blogapp/addblog.html',{'blogform':submitForm})

#显示首页
def index(request):
    return render(request,'blogapp/index.html')



#显示博客列表
def list(request):
    isPassed,next=checkLogin(request.session)
    if not isPassed:
        return next
    userId = request.session.get('user_id')
    #查找authorId和session中和user_id一致的博客
    list = models.Blog.objects.filter(authorId=userId).filter(isDelete=1)
    return render(request,'blogapp/bloglist.html',{'blogs':list})

#显示博客文章内容
def detailBlog(request):
    isPassed,next=checkLogin(request.session)
    if not isPassed:
        return next
    #从选择器中提取博客ID
    blogId = request.GET.get('blogid',0) #默认为0
    blog = models.Blog.objects.get(pk=blogId)
    return render(request,'blogapp/detailblog.html',{'blog':blog})

#修改博客内容
def editBlog(request):
    isPassed,next=checkLogin(request.session)
    if not isPassed:
        return next
    if request.method == 'GET':
        #从选择器中提取博客ID
        blogId = request.GET.get('blogid',0)
        blog = models.Blog.objects.get(pk=blogId)
        blogform = blogForm.BlogForm(initial={
                'title':blog.title,
                'content':blog.content,
                'pic':blog.pic
        })
        return render(request,'blogapp/editblog.html',{'blogform':blogform,'id':blogId})
    elif request.method == 'POST':
        submitForm = blogForm.BlogForm(request.POST,request.FILES)
        id = request.POST.get('id',0)
        if submitForm.is_valid():
            user_id = request.session['user_id']
            #查找当前用户发表的博客
            newBlog = models.Blog.objects.filter(authorId=user_id)[0]
            newBlog.pic = submitForm.cleaned_data['pic']
            newBlog.title = submitForm.cleaned_data['title']
            newBlog.content = submitForm.cleaned_data['content']

            newBlog.save()
            return redirect(reverse('blogapp:bloglist')) #重定向到博客首页

        else:
            return render(request,'blogapp/editblog.html',{'blogform':submitForm,'id':id})

#删除博客内容
def delBlog(request):
    isPassed,next=checkLogin(request.session)
    if not isPassed:
        return next
    if request.method == 'GET':
        blogId = request.GET.get('blogid',0)
        blog = models.Blog.objects.get(pk=blogId)
        if blog.authorId == request.session['user_id']:
            blog.isDelete=0
            blog.save()
            blog = models.Blog.objects.all().filter(isDelete=1)
            return redirect(reverse('blogapp:bloglist')) #重定向到博客首页
        else:
            return HttpResponse('抱歉，您无权进行此操作！！！')


#查找博客内容
def search(request):
    isPassed,next=checkLogin(request.session)
    if not isPassed:
        return next
    userId = request.session.get('user_id')
    #得到关键词
    keyword = request.GET.get('keyword',None)
    # 查找authorId和session中和user_id一致的博客
    list = models.Blog.objects.filter(authorId=userId).filter(isDelete=1).filter(title__contains=keyword)
    #注意这里的title__contains是双划线
    return render(request, 'blogapp/bloglist.html', {'blogs': list})
```

- **APP下的urls.py**

```python
from django.conf.urls import url
from views import user_views,blog_views


urlpatterns=[
    url(r'^register/$',user_views.register,name='blogregister'),
    url(r'^login/$',user_views.login,name='bloglogin'),
    url(r'^addblog/$',blog_views.addBlog,name='addblog'),
    url(r'^bloglist/$',blog_views.list,name='bloglist'),
    url(r'^detailblog/$',blog_views.detailBlog,name='detailblog'),
    url(r'^editblog/$', blog_views.editBlog, name='editblog'),
    url(r'^delblog/$', blog_views.delBlog, name='delblog'),
    url(r'^search/$',blog_views.search,name='search'),
    url(r'^logout/$',user_views.logout,name='logout'),
    

]
```

- **models.py**

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models

# Create your models here.
class User(models.Model):
    userName = models.CharField(max_length=10)
    password = models.CharField(max_length=10)

class Blog(models.Model):
    title = models.CharField(max_length=20)
    content = models.CharField(max_length=200)
    pic = models.ImageField(upload_to='mypics/')
    authorId = models.IntegerField()
    isDelete = models.BooleanField(default=1)
```

- **项目下的urls.py**

```python
from django.conf.urls import url,include
from django.contrib import admin
from django.conf.urls.static import static
from django.conf import settings

urlpatterns = [
    url(r'^blogapp/',include('blogapp.urls',namespace='blogapp')),
    url(r'^admin/', admin.site.urls),

]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

- **settings.py文件中加入以下内容**

```csharp
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR,'media')

#INSTALLED_APPS中加入app名
INSTALLED_APPS = [

    'blogapp',
]

SESSION_SERIALIZER='django.contrib.sessions.serializers.PickleSerializer'
```

**效果展示：**



![img](https://upload-images.jianshu.io/upload_images/6078268-dc7c8773a712a9bc.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/595/format/webp)

# Django实战（二）- 创建一个课程选择系统

# 1.需求

> 1.登录注册

- 编写用户注册功能（用户名、密码、确认密码）
- 提供登录功能
- 登陆后可以填写个人信息（昵称、年龄、头像）

> 2.功能

- 第一个注册用户为管理员，管理员还可以创建、修改、删除课程分类信息，比如（计算机、文学、化学）
- 管理员可以创建课程（每一门课程只能属于一个课程分类）、修改课程、删除课程、查看选择某一门学科的所有学生列表、查看某一分类的所有学科。
- 所有用户都可以查看课程列表，并将课程加到自己的已选课程列表中；所有用户可以查看自己选择的课程列表、查看课程详细介绍、从自己的课程列表中删除某一门课程

# 2.代码操作

(~~前端小白，所以没有加入样式QAQ~~)



![img](https://upload-images.jianshu.io/upload_images/6078268-5d5c2785fc78ec2b.png?imageMogr2/auto-orient/strip|imageView2/2/w/840/format/webp)

lesson树形图

- **lessonform.py**

```python
#-*- coding:utf-8 -*-
from django.forms import Form,fields,widgets,ValidationError
from lesson import models

class register(Form):
    userName = fields.CharField(max_length=10)
    password = fields.CharField(max_length=10,widget=widgets.PasswordInput)
    repassword = fields.CharField(max_length=10,widget=widgets.PasswordInput)

    def  clean(self):

        password = self.cleaned_data['password']
        repassword = self.cleaned_data['repassword']
        if not password == repassword:
            myerror = '两次密码不一致,请重新输入'
            raise ValidationError(myerror)

        return self.cleaned_data


class login(Form):
    userName = fields.CharField(max_length=10)
    password = fields.CharField(max_length=10,widget=widgets.PasswordInput)




class UserInfoForm(Form):
    age = fields.IntegerField()
    email = fields.EmailField(max_length=20)

class TypeForm(Form):
    typeName = fields.CharField(max_length=20)

class LessonForm(Form):
    lessonName = fields.CharField(max_length=20)
    typeName = fields.ChoiceField()

    def __init__(self,*args,**kwargs):
        super(LessonForm, self).__init__(*args,**kwargs)
        items = models.LessonType.objects.values_list('id','typeName')
        self.fields['typeName'].choices=(x for x in items )
```

- **models.py**

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models

# Create your models here.
class User(models.Model):
    userName = models.CharField(max_length=10)
    password = models.CharField(max_length=10)



class UserInfo(models.Model):
    user = models.OneToOneField('User')
    age = models.IntegerField()
    email = models.EmailField()




class LessonType(models.Model):
    typeName = models.CharField(max_length=20)


class Lesson(models.Model):
    lessonName = models.CharField(max_length=20)
    type = models.ForeignKey('LessonType')
    selectedUser = models.ManyToManyField('User')
```

- **html**
- **login.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>登录</title>
</head>
<body>
    <form action="{{request.path}}" method="POST">
        {% csrf_token %}

        <a href="{% url 'lessonregister' %}">没有账号？去注册</a><br>


        用户名：{{loginform.userName}}<br>
        密   码：{{loginform.password}}<br>{{error}}<br>

        <input type="submit" value="登录">

    
    </form>
    <a href="{% url 'lessonlogout' %}">注销</a>
    <a href="{% url 'addtype' %}">增加课程分类</a>


</body>
</html>
```

- **html**
- **register.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>注册页面</title>
</head>
<body>
    <form action="" method="post">
        {% csrf_token %}
        用户名：{{form.userName}}{{error}}<br>
        密  码：{{form.password}}<br>
        确认密码：{{form.repassword}}<br>{{form.non_field_errors}}<br>

    <input type="submit" value="注册">
    <a href="{% url 'lessonlogin' %}">已有账号,去登录</a>


        </form>
</body>
</html>
```

- **html**
- **registersuc.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>登录成功</title>
</head>
<body>
        登录成功
        <a href="{% url 'complete' %}">完善信息</a>
        <a href="{% url 'addtype' %}">添加课程类型</a>
        <a href="{% url 'addlesson' %}">添加课程</a>

        <a href="{% url 'showseleteles' %}">显示已选课程</a>
        <a href="{% url 'cancelseleteles' %}">取消所选课程</a>



</body>
</html>
```

- **html**
- **addtype.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>添加课程分类</title>
</head>
<body>

    <form action="" method="POST">
        {% csrf_token %}
        课程类型名称：{{ form.typeName }}<br>

        <input type="submit" value="添加">

    </form>

</body>
</html>
```

- html
    - **addlesson.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>添加课程</title>
</head>
<body>
    <form action="" method="POST">
        {% csrf_token %}
        课程名字：{{ form.lessonName }}<br>
        课程分组：{{ form.typeName }}<br>


        <input type="submit" value="确认添加">
    </form>


</body>
</html>
```

- html
    - **complete.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>完善个人信息</title>
</head>
<body>
    <form action="" method="POST">
        {% csrf_token %}
        年龄：{{ form.age }}<br>
        邮箱：{{ form.email }}<br>

        <input type="submit" value="提交">

    </form>


</body>
</html>
```

- html
    - **mylesson.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>显示课程列表</title>
</head>
<body>

    {% for item in list %}
    {{ item.lessonName}}<a href="{% url 'cancelseleteles' %}?lessonid={{item.id}}">取消选修</a><br>

        {% endfor %}

</body>
</html>
```

- html
    - **show_lesson.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>显示课程列表</title>
</head>
<body>

    {% for item in list %}
    <a href="{% url 'showstudents' %}?lessonid={{item.id}}">{{ item.lessonName}}</a>     <a href="{% url 'selectlesson' %}?lessonid={{item.id}}">选修此课程</a><br>

        {% endfor %}

</body>
</html>
```

- **html**
- **nav.html**(导航栏)

```jsx
<nav class="navbar navbar-default">
      <div class="container-fluid">
        <!-- Brand and toggle get grouped for better mobile display -->
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">选课系统</a>
        </div>

        <!-- Collect the nav links, forms, and other content for toggling -->
        <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
          <ul class="nav navbar-nav">
            <li class="active"><a href="{% url 'index' %}">首页 <span class="sr-only">(current)</span></a></li>
            <li><a href="{% url 'showlessontype' %}">选课</a></li>
              <li><a href="{% url 'showseleteles' %}">我的课程</a></li>
          </ul>
          <form class="navbar-form navbar-left">
            <div class="form-group">
              <input type="text" class="form-control" placeholder="请输入关键词">
            </div>
            <button type="submit" class="btn btn-default">搜搜</button>
          </form>
            {% if not request.session.userid %}
          <ul class="nav navbar-nav navbar-right">
            <li><a class="btn btn-link" data-toggle="modal" href="{% url 'lessonlogin' %}">登录</a></li>
            <li><a class="btn btn-link" data-toggle="modal" href="{% url 'lessonregister'%}">注册 </a> </li>

              <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">管理 <span class="caret"></span></a>
              <ul class="dropdown-menu" >
                <li><a href="{% url 'addtype' %}">课程分类管理</a></li>
                <li><a href="{% url 'addlesson' %}">课程管理</a></li>
              </ul>
            </li>
          </ul>
            {% endif %}
            {% if request.session.userid %}
            <ul class="nav navbar-nav navbar-right">

            <li><a class="btn btn-link" data-toggle="modal" href="{% url 'lessonlogout' %}">注销 </a> </li>
            <li><a class="btn" data-toggle="modal" href="{% url 'complete' %}">我的资料</a> </li>
                <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">管理 <span class="caret"></span></a>
              <ul class="dropdown-menu" >
                <li><a href="{% url 'addtype' %}">课程分类管理</a></li>
                <li><a href="{% url 'addlesson' %}">课程管理</a></li>
                <li><a class="btn btn-link" data-toggle="modal" href="{% url 'lessonlogin' %}">登录</a></li>
                <li><a class="btn btn-link" data-toggle="modal" href="{% url 'lessonregister'%}">注册 </a> </li>
              </ul>
            </li>

          </ul>
            {% endif %}
        </div><!-- /.navbar-collapse -->
      </div><!-- /.container-fluid -->
    </nav>
```

- html
    - **showstudents.html**

```xml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>显示课程的学生</title>
</head>
<body>
    {% for item in list %}
        {{ item.userName }}
    <br>
    {% endfor %}

</body>
</html>
```

- 项目下的`url.py`

```python
# -*- coding:utf-8 -*-
from django.conf.urls import url
from . import views


urlpatterns=[
    url(r'^register/$',views.register,name='lessonregister'),
    url(r'^login/$',views.login,name='lessonlogin'),
    url(r'^logout/$',views.logout,name='lessonlogout'),
    url(r'^addtype/$',views.addLessonType,name='addtype'),  #增加课程类型
    url(r'^complete/$',views.completeInfo,name='complete'), #完善信息
    url(r'^addlesson/$',views.addLesson,name='addlesson'),  #增加课程
    url(r'^listlesson/(\d+)/$',views.listlesson,name='listlesson'), #显示每个课程类型下的学科
    url(r'^selectlesson/$',views.selectLesson,name='selectlesson'), #选课
    url(r'^showseleteles/$', views.showSelectedLessons, name='showseleteles'),  #显示用户已经选的课程
    url(r'^cancelseleteles/$',views.cancelSelectedLessons,name='cancelseleteles'), #取消所选课程
    url(r'^showstudents/$',views.showStudents,name='showstudents'), #显示每一门学科的学生

]
```

- **views.py**

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render,redirect
from lesson.forms import lessonform
from lesson import models
from django.http import HttpResponse

from django.core.urlresolvers import reverse

# Create your views here.

def register(request):
    if request.method == 'GET':
        form = lessonform.register()
        return render(request,'lesson/register.html',{'form':form})
    elif request.method == 'POST':
        form = lessonform.register(request.POST)
        if form.is_valid():
            temp = models.User.objects.filter(userName=form.cleaned_data['userName']).exists()

            if temp == False:
                user = models.User.objects.create(userName=form.cleaned_data['userName'],password=form.cleaned_data['password'])
                request.session['userid']=str(user.id)
                return HttpResponse('恭喜你注册成功,用户ID:' + request.session['userid'])
            else:
                error = '用户名已经存在，请换一个用户名试试!'
                return render(request,'lesson/register.html',{'form':form,'error':error})

        else:
            return render(request,'lesson/register.html',{'form':form})

#登录功能
def login(request):
    if request.method == 'GET':
        loginform = lessonform.login()
        return render(request,'lesson/login.html',{'loginform':loginform})
    elif request.method == 'POST':
        loginform = lessonform.login(request.POST,)
        if loginform.is_valid():
            userName = loginform.cleaned_data['userName']
            password = loginform.cleaned_data['password']

            user = models.User.objects.filter(userName=userName).filter(password=password)
            if user.exists():
                request.session['userid'] = user[0].id
                print request.session['userid']
                return render(request,'lesson/loginsuc.html',{'loginform':loginform})
            else:
                error = '用户名或者密码输入有误，请重试'
                return render(request,'lesson/login.html',{'loginform':loginform,'error':error})
        else:
            return render(request,'lesson/login.html',{'loginform':loginform})
    else:
        return render(request, 'lesson/login.html')


#验证用户是否登录
def checkLogin(session):
    #session 键userid如果不存在对应的值
    id = session.get('userid',None)
    if id==None:
        #转到登录页面
        return False,redirect(reverse('lessonlogin'))
    else:
        return True,id


#注销功能
def logout(request):
    userId = request.session.get('userid',None)
    if not userId == None:
        del request.session['userid']
        return HttpResponse('注销成功')
    else:
        return HttpResponse('您还没有登录')



#添加课程类型
def addLessonType(request):
    #先判断是否登录
    isLogin,next = checkLogin(request.session)
    #登录后session中userid
    if not isLogin:
        return next
    else:
        #判断是否为第一个用户(默认第一个用户为超级管理员)
        if next==1:
            if request.method == 'GET':
                #生成表单
                form = lessonform.TypeForm()
                return render(request,'lesson/addtype.html',{'form':form})
            elif request.method == 'POST':
                form = lessonform.TypeForm(request.POST)
                if form.is_valid():
                    #处理表单信息
                    type = models.LessonType()

                    type.typeName = form.cleaned_data['typeName']

                    if not models.LessonType.objects.filter(typeName=type.typeName):
                        type.save()
                        return HttpResponse('添加成功')
                    else:
                        error='此类型已存在'
                        return render(request,'lesson/addtype.html',{'form':form,'error':error})
                else:
                    return render(request,'lesson/addtype.html',{'form':form})

        else:
            return HttpResponse('抱歉，你没有此类权限！')

#完善信息
def completeInfo(request):
    #先判断是否登录
    isLogin,next = checkLogin(request.session)
    # 登录后session中userid
    if not isLogin:
        return next
    else:
        if request.method == 'GET':
            infoForm = lessonform.UserInfoForm()
            return render(request,'lesson/complete.html',{'form':infoForm})
        elif request.method == 'POST':
            infoForm = lessonform.UserInfoForm(request.POST)
            if infoForm.is_valid():
                user = models.User.objects.get(id=request.session['userid'])
                email = infoForm.cleaned_data['email']
                age = infoForm.cleaned_data['age']

                models.UserInfo.objects.create(user=user,age=age,email=email)
                return HttpResponse('信息已经完善，你可以进行下一步操作了')

            else:
                return render(request,'lesson/complete.html',{'form':infoForm})




#添加课程
def addLesson(request):
    #验证是否登录
    isLogin,next = checkLogin(request.session)
    if not isLogin:
        return next
    else:
        #判断是否为超级管理员
        if next==1:
            if request.method == 'GET':
                #生成表单
                form = lessonform.LessonForm()
                #初始化选项列表，从数据库中查找
                items = models.LessonType.objects.values_list('id','typeName')
                form.fields['typeName'].choices = (x for x in items)
                return render(request,'lesson/addlesson.html',{'form':form})
            elif request.method == 'POST':
                form = lessonform.LessonForm(request.POST)
                if form.is_valid():
                    #处理表单信息
                    lessonName = form.cleaned_data['lessonName']
                    id = form.cleaned_data['typeName']
                    #查找母表中的数据
                    lesson_type = models.LessonType.objects.get(id=id)
                    lesson = models.Lesson()
                    lesson.lessonName = lessonName
                    lesson.type = lesson_type
                    if not models.Lesson.objects.filter(lessonName=lessonName):
                        lesson.save()
                        return HttpResponse('添加成功')
                    else:
                        error = '课程已存在'
                        return render(request,'lesson/addlesson.html',{'form':form,'error':error})
                else:
                    items = models.LessonType.objects.values_list('id','typeName')
                    form.fields['typeName'].choices=(x for x in items)
                    return render(request,'lesson/addlesson.html',{'form':form})

        else:
            return HttpResponse('你没有操作的权限！')


# 修改课程所属分类
def editlessontype(request):
    #验证是否登录
    isLogin,next = checkLogin(request.session)
    if not isLogin:
        #转到登录页面
        return next
    else:
        if next == 1:
            if request.method == 'GET':
                id = request.GET['id']
                obj = models.LessonType.objects.get(id=id)
                form = lessonform.TypeForm(initial={
                    'type': obj.lessiontype
                })
                return render(request, 'eeditTyp.html', {'form': form, 'id': id})
            elif request.method == 'POST':
                form = lessonform.TypeForm(request.POST)
                if form.is_valid():
                    data = form.cleaned_data
                    id = request.GET['id']
                    type = models.LessonType.objects.get(id=id)
                    type.lessiontype = data['type']
                    if not models.LessonType.objects.filter(lessiontype=type.lessiontype):
                        type.save()
                        return redirect(reverse('addType'))
                    else:
                        error = '课程类型已存在'
                        return render(request, 'edittype.html', {'form': form, 'error': error})

                else:
                    return render(request, 'edittype.html', {'form': form})
        else:
            return HttpResponse('你没有此权限')



#显示课程列表
def listlesson(request):
    typeId=request.GET.get('lessontypeid',0)
    #lessons = models.LessonType.objects.get(id=typeId).lesson_set.all().values_list('lessonName',flat=True)
    lessons = models.LessonType.objects.get(id=typeId).lesson_set.all()
    return render(request,'lesson/show_lesson.html',{'list':lessons,})


#显示课程分类
def showLessonType(request):
    items = models.LessonType.objects.values_list('id','typeName')
    print items[0][0]
    return render(request,'lesson/showlessontype.html',{'items':items})


#选课
def selectLesson(request):
    lessonid = request.GET.get('lessonid',0)
    lesson = models.Lesson.objects.get(id=lessonid)

    user = models.User.objects.get(id=request.session['userid'])
    lesson.selectedUser.add(user)
    return HttpResponse('恭喜你选课成功')

#显示用户所选课程
def showSelectedLessons(request):
    user = models.User.objects.get(id=request.session['userid'])
    list = user.lesson_set.all()
    return render(request,'lesson/mylessons.html',{'list':list})


#取消所选课程
def cancelSelectedLessons(request):
    lessonid = request.GET.get('lessonid',0)
    lesson = models.Lesson.objects.get(id=lessonid)

    user = models.User.objects.get(id=request.session['userid'])
    lesson.selectedUser.remove(user)
    return HttpResponse('取消成功')

#显示一门课程的学生
def showStudents(request):
    lessonid = request.GET.get('lessonid',0)
    lesson = models.Lesson.objects.get(id=lessonid)
    list = lesson.selectedUser.all()
    return render(request,'lesson/showstudents.html',{'list':list})

# 首页
def index(request):
    return render(request,'lesson/index.html')
```



![img](https://upload-images.jianshu.io/upload_images/6078268-79a8b851e56e84f6.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)