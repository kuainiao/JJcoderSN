# django-admin和manage.py

阅读: 9995     [评论](http://www.liujiangblog.com/course/django/166#comments)：3

------

### 目录

一、Django内置命令选项

1. check
2. dbshell
3. diffsettings
4. flush
5. makemigrations
6. migrate
7. runserver
8. shell
9. startapp
10. startproject
11. test

二、app提供的命令

1. changepassword
2. createsuperuser
3. clearsessions
4. collectstatic

三、 共有参数

1. --pythonpath PYTHONPATH
2. --settings SETTINGS
3. --traceback
4. --verbosity {0,1,2,3}, -v {0,1,2,3}
5. --no-color

四、颜色控制

五、在代码中调用管理命令

------

django-admin是用于管理Django的命令行工具集，当我们成功安装Django后，在操作系统中就会有这个命令，但是根据安装方式或者系统环境的不同，你可能需要配置一下调用路径。在Linux下，该命令一般位于`site-packages/django/bin`，最好做一个链接到`/usr/local/bin`，方便调用。Windows下可以配置系统环境变量，参考教程开始部分。

manage.py则是每个Django项目中自动生成的一个用于管理项目的脚本文件，需要通过python命令执行。

**有三种方式，可以执行Django提供的内置命令：**

```
$ django-admin <command> [options]
$ manage.py <command> [options]
$ python -m django <command> [options]
```

其中的command是Django内置的或者你自定义的命令。

**有三种获取帮助信息的办法：**

`django-admin help`：显示使用信息和命令列表。

`django-admin help --commands`：所有可用命令的列表。

`django-admin help <command>`：命令的介绍及其可用的参数列表。

**django-admin version：获取当前使用的Django版本。**

使用`--verbosity`参数指定`django-admin`将通知和调试信息打印到控制台。

## 一、Django内置命令选项

Django为我们提供了一系列命令选项，有一些天天都用，有一些很重要，有一些基本用不到。下面列出了一些重要的：

调用方式：`django-admin 命令选项 额外参数`

### 1. check

检查整个Django项目是否存在常见问题。

默认情况下，所有应用都将被选中。可以通过提供app的名字检查指定的应用：

```
django-admin check auth admin myapp
```

如果你没有指定任何一个应用，那么将对全部的应用进行检查。

### 2. dbshell

运行ENGINE设置中指定的数据库引擎的命令行客户端，其中USER，PASSWORD等指定连接参数。

--database DATABASE

指定打开某个数据库的shell。 默认为default。

### 3. diffsettings

django-admin diffsettings

显示当前设置文件与Django的默认设置之间的差异。

### 4. flush

django-admin flush

从数据库中删除所有数据。已应用的迁移不会被清除。**只删除具体数据，不删除数据表！**

如果您希望从空数据库启动并重新运行所有迁移，则应该删除并重新创建数据库，然后再运行migrate，这样会连原来的数据表都删了。

### 5. makemigrations

django-admin makemigrations [app_label [app_label ...]]

根据检测到的模型创建新的迁移。迁移的作用，更多的是将数据库的操作，以文件的形式记录下来，方便以后检查、调用、重做等等。尤其是对于Git版本管理，它无法获知数据库是如何变化的，只能通过迁移文件中的记录来追溯和保存。

### 6. migrate

django-admin migrate [app_label] [migration_name]

使数据库状态与当前模型集和迁移集同步。说白了，就是将对数据库的更改，主要是数据表设计的更改，在数据库中真实执行。例如，新建、修改、删除数据表，新增、修改、删除某数据表内的字段等等。

### 7. runserver

django-admin runserver [addrport]

启用Django为我们提供的轻量级的开发用的Web服务器。默认情况下，服务器运行在IP地址127.0.0.1的8000端口上。如果要自定义服务器端口和地址，可以显式地传递一个IP地址和端口号给它。

在Linux中，如果你以一个普通用户的身份来运行脚本,你可能没有权限在低位端口上运行。低端口数(即1024以下)是预留出来给超级用户（root）的。

这个服务器使用的WSGI application对象是在`WSGI_APPLICATION`中设置的。

**不要在生产环境中使用这个服务器。**

通常，每当我们写的代码有变化时，这个服务器会自动重启，但这不是绝对的，所以，为了不出意外，每次测试时，还是手动重启一下吧。

当你启动服务器之后，在服务器运行过程中每当你的Python代码有变更时，系统的检测框架将会检查整个项目中是否存在一些直观的错误，如果检测到了错误，这些错误信息将会输出至标准输出。

可以同时启动多个服务器，只要它们在不同的端口上，多次执行`django-admin runserver ...`即可。

注意：默认的IP为127.0.0.1，它是不可被网络中的其它主机所访问的，只能本机。要使网络上的其他计算机可以访问你的开发服务器，请使用自己的IP地址（例如192.168.2.1）或0.0.0.0或 :: （启用IPv6）。也可以使用只包含ASCII码的主机名.

Django开发服务器，默认支持多线程，可以通过`--nothreading`参数关闭。

下面是使用不同端口和地址的示例：

端口8000在IP地址127.0.0.1：

```
django-admin runserver
```

端口8000在IP地址1.2.3.4：

```
django-admin runserver 1.2.3.4:8000
```

端口7000在IP地址127.0.0.1：

```
django-admin runserver 7000
```

端口7000在IP地址1.2.3.4：

```
django-admin runserver 1.2.3.4:7000
```

端口8000在IPv6地址::1：

```
django-admin runserver -6
```

端口7000在IPv6地址::1：

```
django-admin runserver -6 7000
```

端口7000在IPv6地址2001:0db8:1234:5678::9：

```
django-admin runserver [2001:0db8:1234:5678::9]:7000
```

端口8000在主机的IPv4地址localhost：

```
django-admin runserver localhost:8000
```

端口8000在主机的IPv6地址localhost：

```
django-admin runserver -6 localhost:8000
```

### 8. shell

django-admin shell

启动带有Django环境的Python交互式解释器，也就是命令行环境。默认使用基本的python交互式解释器。这个命令非常常用，是我们测试和开发过程中不可或缺的部分！

```
--interface {ipython,bpython,python}, -i {ipython,bpython,python}
```

指定要使用的shell。 默认情况下，Django将使用IPython或bpython。如果同时安装了两个，请指定您想要的那个，如下所示：

使用IPython：

```
django-admin shell -i ipython
```

使用bpython：

```
django-admin shell -i bpython
```

### 9. startapp

django-admin startapp name [directory]

创建新的app。

默认情况下，会在这个新的app目录下创建一系列文件模版，比如models.py、views.py、admin.py等等。

### 10. startproject

django-admin startproject name [directory]

新建工程。默认情况下，新目录包含manage.py脚本和项目包（包含settings.py和其他文件）。

### 11. test

django-admin test [test_label [test_label ...]]

运行所有已安装的app的测试代码。

## 二、app提供的命令

前面是Django核心提供的命令项，下面则是一些内置app，比如auth等提供的命令项。它们只在对应的app启用的时候才可用。

下面是最重要的几个：

### 1. changepassword

此命令仅在安装了Django的authentication system（django.contrib.auth）时可用。

该命令用于更改用户的密码。它会提示为给定用户输入两次新密码。如果两次输入相同，则立即成为新密码。 如果不提供用户名，该命令将尝试更改与当前用户匹配的用户名的密码。

用法示例：

```
django-admin changepassword tom
```

### 2. createsuperuser

此命令仅在安装了Django的authentication system（django.contrib.auth）时可用。

创建超级用户帐户（具有所有权限的用户）。如果你需要创建初始超级用户帐户，或者需要以编程方式为你的网站生成超级用户帐户，这将非常有用。

以交互方式运行时，此命令将提示输入新超级用户的密码。

当以非交互方式运行时，将不会设置密码，并且超级用户帐户将无法登录，直到为其手动设置密码。

可以使用命令行上的`--username`和`--email`参数提供新帐户的用户名和电子邮件地址。如果未提供其中任何一个，则createsuperuser将在以交互方式运行时提示输入。

### 3. clearsessions

清除过期的会话。可以作为cron定期作业或直接运行。

### 4. collectstatic

仅当安装了static files application（django.contrib.staticfiles）时，此命令才可用。

用于在线上环境，当DEBUG设置为False时，将静态文件等统一集中到一个目录下，为Web服务器提供静态文件支持。

**这是一个不起眼，但非常重要的命令！**

## 三、 共有参数

每种命令都有自己特定的参数选项，但下面几个是所有命令都可以使用的参数：

### 1. --pythonpath PYTHONPATH

将给定的文件系统路径添加到Python的模块导入搜索路径（import search path）。

如果未提供，django-admin将使用PYTHONPATH环境变量的值。

用法示例：

```
django-admin migrate --pythonpath='/home/djangoprojects/myproject'
```

### 2. --settings SETTINGS

指定要使用的配置文件。例如mysite.settings。如果未提供，django-admin将使用`DJANGO_SETTINGS_MODULE`环境变量的值。

用法示例：

```
django-admin migrate --settings=mysite.settings
```

### 3. --traceback

当引发CommandError时，显示完整的错误栈信息。默认情况下，django-admin将显示一个简单的错误消息。

用法示例：

```
django-admin migrate --traceback
```

### 4. --verbosity {0,1,2,3}, -v

指定向控制台打印消息的方式。

- 0表示无输出。
- 1表示正常输出（默认）。
- 2表示详细输出。
- 3表示非常详细输出。

用法示例：

```
django-admin migrate --verbosity 2
```

### 5. --no-color

禁用彩色的输出信息。 一些命令会给它输出的内容添加色彩。例如，错误将以红色打印到控制台，SQL语句将突出显示语法。

用法示例：

```
django-admin runserver --no-color
```

## 四、颜色控制

如果你的终端支持ANSI颜色输出，则`django-admin`或者manage.py命令将使用漂亮的颜色输出。如果你将命令的输出传递到另一个程序，它不会使用颜色代码。

在Windows下，本机控制台不支持ANSI转义序列，因此默认情况下没有颜色输出。但是，可以安装ANSICON第三方工具，Django命令将检测其存在，并使用带颜色的输出，就像在基于Unix的平台上。

用于语法高亮的颜色可以自定义。Django自带三个调色板：

- dark，适用于在黑色背景上显示白色文字的终端。 这是默认调色板。
- light，适用于在白色背景上显示黑色文本的终端。
- nocolor，禁用语法高亮显示。

可以通过设置DJANGO_COLORS环境变量来指定要使用的调色板。 例如，要在Unix或OS/X BASH shell下指定light调色板，可以运行以下命令：

```
export DJANGO_COLORS="light"
```

还可以自定义要使用的颜色，以下是基本规则：

```
error - 主要错误。
notice - 一个小错误。
success - 成功。
warning - 警告。
sql_field - SQL中模型字段的名称。
sql_coltype - SQL中的模型字段的类型。
sql_keyword - 一个SQL关键字。
sql_table - SQL中模型的名称。
http_info - 1XX HTTP信息服务器响应。
http_success - 2XX HTTP成功服务器响应。
http_not_modified - 304 HTTP未修改服务器响应。
http_redirect - 除304之外的3XX HTTP重定向服务器响应。
http_not_found - 404 HTTP未找到服务器响应。
http_bad_request - 除404之外的4XX HTTP错误请求服务器响应。
http_server_error - 5XX HTTP Server错误响应。
migrate_heading - 迁移管理命令中的标题。
migrate_label - 迁移名称。
```

可以从以下列表中分配特定的前景和背景颜色：

```
black
red
green
yellow
blue
magenta
cyan
white
```

可以使用以下显示选项修改每种颜色：

```
bold
underscore
blink
reverse
conceal
```

颜色的配置规范遵循以下模式之一：

```
role=fg
role=fg/bg
role=fg,option,option
role=fg/bg,option,option
```

其中role是有效颜色配置的名称，fg是前景颜色，bg是背景颜色，每个option是一个颜色修改选项（用分号分隔）。 像这样：

```
export DJANGO_COLORS="error=yellow/blue,blink;notice=magenta"
```

或者：

```
export DJANGO_COLORS="light;error=yellow/blue,blink;notice=magenta"
```

## 五、在代码中调用管理命令

django.core.management.call_command(name, *args,* *options)

要在代码中调用管理命令，需要使用call_command方法，它接受下面的参数：

`name`：

要调用的命令的名称或命令对象。

`*args`:

该命令接受的参数列表。 例如，`call_command（'flush'， ' - verbosity = 0'）`。

`**options`:

传递给命名的选项。 例如，`call_command（'flush'， verbosity = 0）`。

例子：

```
from django.core import management
from django.core.management.commands import loaddata

management.call_command('flush', verbosity=0, interactive=False)
management.call_command('loaddata', 'test_data', verbosity=0)
management.call_command(loaddata.Command(), 'test_data', verbosity=0)
```

命名参数可以通过使用以下语法之一传递：

```
# Similar to the command line
management.call_command('dumpdata', '--natural-foreign')

# Named argument similar to the command line minus the initial dashes and
# with internal dashes replaced by underscores
management.call_command('dumpdata', natural_foreign=True)

# `use_natural_foreign_keys` is the option destination variable
management.call_command('dumpdata', use_natural_foreign_keys=True)
```

有多个参数时，传递列表：

```
management.call_command('dumpdata', exclude=['contenttypes', 'auth'])
```

可以重定向标准输出和错误流，因为所有命令都支持stdout和stderr选项。 例如：

```
with open('/path/to/command_output') as f:
    management.call_command('dumpdata', stdout=f)
```