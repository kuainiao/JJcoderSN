# 自定义django-admin命令

阅读: 7102     [评论](http://www.liujiangblog.com/course/django/167#comments)：0

我们可以通过manage.py编写和注册自定义的命令。

自定义的管理命令对于独立脚本非常有用，特别是那些使用Linux的crontab服务，或者Windows的调度任务执行的脚本。比如，你有个需求，需要定时清空某篇文章下面的评论，一种解决方案就是写一个django-admin命令，再写一个运行该命令的独立脚本，最后通过crontab服务，定时执行该脚本。

下面，我们将为教程最开始的第一个Django应用中的polls应用编写一个自定义的`closepoll`命令。

## 一、创建management/commands目录

首先，需向该应用添加一个`management/commands`目录。

Django将为该目录中名字没有以下划线开始的每个Python模块注册一个manage.py命令。也就是说，你每自定义一个命令，就要在目录下创建一个新的模块。

像这样：

```
polls/
    __init__.py
    models.py
    management/
        __init__.py
        commands/
            __init__.py
            _private.py
            closepoll.py
    tests.py
    views.py
```

在Python 2上，请确保`management`和`management/commands`两个目录都包含`__init__.py`文件，否则将检测不到你的命令。

在这个例子中，`closepoll`命令对任何项目都可用，只要它们的`INSTALLED_APPS`里包含polls应用。

`_private.py`因为以下划线开头，将不可以作为一个管理命令使用。

在`closepoll.py`模块中只有一个要求:必须定义一个`Command`类并继承`BaseCommand`类或其子类。

## 二、编写命令的具体代码

要实现这个命令，在`polls/management/commands/closepoll.py`中添加代码如下：

```
from django.core.management.base import BaseCommand, CommandError
from polls.models import Question as Poll

class Command(BaseCommand):
    help = '关闭指定问卷的投票功能'

    def add_arguments(self, parser):
        parser.add_argument('poll_id', nargs='+', type=int)

    def handle(self, *args, **options):
        for poll_id in options['poll_id']:
            try:
                poll = Poll.objects.get(pk=poll_id)
            except Poll.DoesNotExist:
                raise CommandError('Poll "%s" does not exist' % poll_id)

            poll.opened = False
            poll.save()

            self.stdout.write(self.style.SUCCESS('Successfully closed poll "%s"' % poll_id))
```

每一个自定义的命令，都要自己实现handle()方法，这个方法是命令的核心业务处理代码，你的命令功能要通过它来实现。而add_arguments()则用于帮助处理命令行的参数，如果没有参数，可以不写这个方法。

**注意**：当你使用管理命令并希望提供控制台输出时，你应该写到`self.stdout`和`self.stderr`，而不能直接打印到stdout和stderr。另外，你不需要在消息的末尾加上换行符，它将被自动添加，除非你指定ending参数：`self.stdout.write("Unterminated line", ending='')`

## 三、执行命令的方式

调用格式：`python manage.py 自定义命令名 <参数列表>`

可以使用`python manage.py closepoll <poll_id>`调用上面的自定义命令。

### 四、可选参数

通过接收额外的命令行选项，可以简单地修改closepoll来删除一个给定的poll而不是关闭它。这些自定义的选项可以像下面这样添加到`add_arguments()`方法中：

```
class Command(BaseCommand):
    def add_arguments(self, parser):
        # Positional arguments
        parser.add_argument('poll_id', nargs='+', type=int)

        # Named (optional) arguments
        parser.add_argument(
            '--delete',
            action='store_true',
            dest='delete',
            default=False,
            help='Delete poll instead of closing it',
        )

    def handle(self, *args, **options):
        # ...
        if options['delete']:
            poll.delete()
        # ...
```