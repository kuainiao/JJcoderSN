# sys

阅读: 6867   [评论](http://www.liujiangblog.com/course/python/54#comments)：2

sys模块主要是针对与Python解释器相关的变量和方法，不是主机操作系统。

导入方式：import sys

| 属性及方法                       | 使用说明                                                     |
| -------------------------------- | ------------------------------------------------------------ |
| sys.argv                         | 获取命令行参数列表，第一个元素是程序本身                     |
| sys.exit(n)                      | 退出Python程序，exit(0)表示正常退出。当参数非0时，会引发一个`SystemExit`异常，可以在程序中捕获该异常 |
| sys.version                      | 获取Python解释程器的版本信息                                 |
| sys.maxsize                      | 最大的Int值，64位平台是`2**63 - 1`                           |
| sys.path                         | 返回模块的搜索路径，初始化时使用PYTHONPATH环境变量的值       |
| sys.platform                     | 返回操作系统平台名称                                         |
| sys.stdin                        | 输入相关                                                     |
| sys.stdout                       | 输出相关                                                     |
| sys.stderr                       | 错误相关                                                     |
| sys.exc_info()                   | 返回异常信息三元元组                                         |
| sys.getdefaultencoding()         | 获取系统当前编码，默认为utf-8                                |
| sys.setdefaultencoding()         | 设置系统的默认编码                                           |
| sys.getfilesystemencoding()      | 获取文件系统使用编码方式，默认是utf-8                        |
| sys.modules                      | 以字典的形式返回所有当前Python环境中已经导入的模块           |
| sys.builtin_module_names         | 返回一个列表，包含所有已经编译到Python解释器里的模块的名字   |
| sys.copyright                    | 当前Python的版权信息                                         |
| sys.flags                        | 命令行标识状态信息列表。只读。                               |
| sys.getrefcount(object)          | 返回对象的引用数量                                           |
| sys.getrecursionlimit()          | 返回Python最大递归深度，默认1000                             |
| sys.getsizeof(object[, default]) | 返回对象的大小                                               |
| sys.getswitchinterval()          | 返回线程切换时间间隔，默认0.005秒                            |
| sys.setswitchinterval(interval)  | 设置线程切换的时间间隔，单位秒                               |
| sys.getwindowsversion()          | 返回当前windwos系统的版本信息                                |
| sys.hash_info                    | 返回Python默认的哈希方法的参数                               |
| sys.implementation               | 当前正在运行的Python解释器的具体实现，比如CPython            |
| sys.thread_info                  | 当前线程信息                                                 |

### sys.argv

sys.argv是一个脚本执行参数列表，列表的第一个元素是脚本名称，从第二个元素开始才是真正的参数。

```
# test.py

import sys

for index, arg in enumerate(sys.argv):
    print("第%d个参数是： %s" % (index, arg))
```

运行`python test.py 1 2 3 4`，结果：

```
第0个参数是： test.py
第1个参数是： 1
第2个参数是： 2
第3个参数是： 3
第4个参数是： 4 
```

### sys.getrefcount(object)

我们都知道Python有自动的垃圾回收机制，让我们不用费力去进行内存管理。那么Python怎么知道一个对象可以被当做垃圾回收呢？Python使用‘引用计数’的方式，追踪每个对象 的引用次数，每对这个对象的一次引用，这个计数就加一，每删除一个该对象的引用，这个计数就减一。当引用为0的时候，就表示没有任何变量指向这个对象，那么就可以回收这个对象，腾出它所占用的内存空间。

`sys.getrefcount(object)`这个方法可以返回一个对象被引用的次数。注意，这个次数默认从1开始，因为你在使用`sys.getrefcount(object)`方法的时候就已经引用了它一次（该引用是临时性的，调用结束后，自动解除引用。）。如果不好理解，可以简单地认为它自带被动光环：引用+1。

```
>>> a = "I like Python!"
>>> sys.getrefcount(a)
2
>>> b = a
>>> sys.getrefcount(a)
3
>>> c = a
>>> sys.getrefcount(a)
4
>>> del c
>>> sys.getrefcount(a)
3
>>> del b
>>> sys.getrefcount(a)
2
>>> sys.getrefcount(1)
902
>>> sys.getrefcount("a")
36
>>> sys.getrefcount(True)
581
>>> sys.getrefcount(None)
6918
```

注意实例中的`1、"a"、True、None`，Python内部环境运行过程中已经引用了它们很多次，None甚至被使用了6918次。

### sys.modules

`sys.modules`保存有当前Python环境中已经导入的模块记录，这是一个全局字典，当Python启动后就加载在内存中。每当导入新的模块，`sys.modules`将自动记录该模块，当第二次试图再次导入该模块时，Python会先到这个字典中查找是否曾经导入过该模块。是则忽略，否则导入，从而加快了程序运行的速度。同时，它拥有字典的基本方法。例如`sys.modules.keys()`查看字典的所有键，`sys.modules.values()`查看字典的所有值，`sys.modules['sys']`查看sys键对应的值。

```
>>> import sys
>>> sys.modules
{'builtins': <module 'builtins' (built-in)>, 'sys': <module 'sys' (built-in)>, '_frozen_importlib': <module 'importlib._bootstrap' (frozen)>, '_imp': <module '_imp' (built-in)>, '_warnings': <module '_warnings' (built-in)>, '_thread': 
.......截取部分
>>> sys.modules.keys()
dict_keys(['builtins', 'sys', '_frozen_importlib', '_imp', '_warnings', '_thread', '_weakref', '_frozen_importlib_external', '_io', 'marshal', 'nt', 'winreg', 'zipimport', 'encodings', 'codecs', '_codecs', 'encodings.aliases', 
...截取部分
>>> sys.modules.values()
dict_values([<module 'builtins' (built-in)>, <module 'sys' (built-in)>, <module 'importlib._bootstrap' (frozen)>, <module '_imp' (built-in)>, <module '_warnings' (built-in)>, <module '_thread' (built-in)>, <module '_weakref' module 'urllib.parse' from 'C:\\Python36\\lib\\urllib\\parse.py'>])
.......截取部分
>>> sys.modules['sys']
<module 'sys' (built-in)>
```

### sys.builtin_module_names

`sys.builtin_module_names`是一个字符串元组，包含了所有已经编译在Python解释器内的模块名称。

```
import sys

def find_module(module):
    if module in sys.builtin_module_names:
        print(module, " 内置于=> ", "__builtin__")
    else:
        print(module, "模块位于=> ", __import__(module).__file__)


find_module('os')
find_module('sys')
find_module('time')
find_module('zlib')
find_module('string')

#----------
运行结果：
os 模块位于=>  C:\Python36\lib\os.py
sys  内置于=>  __builtin__
time  内置于=>  __builtin__
zlib  内置于=>  __builtin__
string 模块位于=>  C:\Python36\lib\string.py
```

### sys.path

path是一个目录列表，供Python从中查找模块。在Python启动时，sys.path根据内建规则和`PYTHONPATH`变量进行初始化。`sys.path`的第一个元素通常是个空字符串，表示当前目录。

```
>>> sys.path
['', 'C:\\Python36\\Lib\\idlelib', 'C:\\Python36\\python36.zip', 'C:\\Python36\\DLLs', 'C:\\Python36\\lib', 'C:\\Python36', 'C:\\Python36\\lib\\site-packages']
```

`sys.path`本质上是一个列表，可以进行append、insert、pop、remove等各种列表相关的操作，但通常都进行append操作，添加自己想要的查找路径。在做修改、删除类型的操作之前，请务必确认你的行为！

### sys.platform

获取当前执行环境的平台名称，不同的平台返回值如下表所示：

| 操作系统       | 返回值   |
| -------------- | -------- |
| Linux          | 'linux'  |
| Windows        | 'win32'  |
| Windows/Cygwin | 'cygwin' |
| Mac OS X       | 'darwin' |

### sys.stdin、sys.stdout、sys.stderr

`stdin`用于所有的交互式输入（包括input()函数）。

`stdout`用于print()的打印输出或者input()函数的提示符。

`stderr`用于解释器自己的提示信息和错误信息。

简而言之，这三个属性就是操作系统的标准输入、输出和错误流，它们返回的都是一个“文件类型”对象，支持read()、write()和flush()等操作，就像用open()方法打开的文件对象那样！

```
>>> import sys
>>> s = sys.stdin.read()        # 使用ctrl+d结束输入
i like python
end



>>> s
'i like python\nend\n\n\n\n'
>>> sys.stdout.write(s)
i like python
end



21
```

**`sys.stdout` 与 `print()`**

当我们`print(obj)`的时候，事实上是调用了`sys.stdout.write(obj+'\n')`，将内容打印到控制台（默认是显示器），然后追加一个换行符。以下两行等价：

```
sys.stdout.write('hello'+'\n') 
print('hello')
```

**`sys.stdin` 与 `input()`**

当我们用`input('Please input something！')`时，事实上是先输出提示信息，然后捕获输入。 以下两组等价：

```
s = input('Please input something！')


print('Please input something！',)  # 逗号表示不换行
s = sys.stdin.readline()[:-1]  # -1 可以抛弃输入流中的'\n' 换行符，自己琢磨一下为什么。
```

### 从控制台重定向到文件

默认情况下`sys.stdout`指向控制台。如果把文件对象赋值给`sys.stdout`，那么`print ()`调用的就是文件对象的`write()`方法。

```
f_handler = open('out.log', 'w') 
sys.stdout = f_handler 
print('hello')
# 你无法在屏幕上看到“hello”
# 因为它被写到out.log文件里了
```

如果你还想同时在控制台打印的话，最好先将原始的控制台对象引用保存下来，向文件中打印之后再恢复 sys.stdout

```
__console__ = sys.stdout    # 保存控制台
# redirection start #       # 去干点别的，比如写到文件里
... 
# redirection end           # 干完别的了，恢复原来的控制台
sys.stdout = __console__
```

### 实例：带百分比的进度条

利用`sys.stdout`的功能，可以实现一个简易的进度条。

```
import sys
import time


def bar(num, total):
    rate = num / total
    rate_num = int(rate * 100)
    r = '\r[%s%s]%d%%' % ("="*num, " "*(100-num), rate_num, )
    sys.stdout.write(r)
    sys.stdout.flush()


if __name__ == '__main__':
    for i in range(0, 101):
        time.sleep(0.1)
        bar(i, 100)
```