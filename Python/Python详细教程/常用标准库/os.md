# os

阅读: 12888   [评论](http://www.liujiangblog.com/course/python/53#comments)：3

模块导入方式： `import os`

os模块是Python标准库中的一个用于访问操作系统相关功能的模块，os模块提供了一种可移植的使用操作系统功能的方法。使用os模块中提供的接口，可以实现跨平台访问。但是，并不是所有的os模块中的接口在全平台都通用，有些接口的实现是一来特定平台的，比如linux相关的文件权限管理和进程管理。

os模块的主要功能：**系统相关、目录及文件操作、执行命令和管理进程**

*Ps:其中的进程管理功能主要是Linux相关的，本节不做讨论。*

在使用os模块的时候，如果出现了问题，会抛出`OSError`异常，表明无效的路径名或文件名，或者路径名(文件名)无法访问，或者当前操作系统不支持该操作。

```
>>> import os
>>> os.chdir("d:\11")
Traceback (most recent call last):
  File "<pyshell#2>", line 1, in <module>
    os.chdir("d:\11")
OSError: [WinError 123] 文件名、目录名或卷标语法不正确。: 'd:\t'
```

## 1. 系统相关

os模块提供了一些操作系统相关的变量，可以在跨平台的时候提供支持，便于编写移植性高，可用性好的代码。所以在涉及操作系统相关的操作时，请尽量使用本模块提供的方法，而不要使用当前平台特定的用法或格式，否则一旦移植到其他平台，可能会造成难以解决的困扰。

下面以表格的形式，列举os模块中常用的方法和变量，及其用途解释。个别比较重要的内容会单独举例说明，以后类同。

| 方法和变量 | 用途                                                         |
| ---------- | ------------------------------------------------------------ |
| os.name    | 查看当前操作系统的名称。windows平台下返回‘nt’，Linux则返回‘posix’。 |
| os.environ | 获取系统环境变量                                             |
| os.sep     | 当前平台的路径分隔符。在windows下，为‘\’，在POSIX系统中，为‘/’。 |
| os.altsep  | 可替代的路径分隔符，在Windows中为‘/’。                       |
| os.extsep  | 文件名和文件扩展名之间分隔的符号，在Windows下为‘.’。         |
| os.pathsep | PATH环境变量中的分隔符，在POSIX系统中为‘:’，在Windows中为‘;’。 |
| os.linesep | 行结束符。在不同的系统中行尾的结束符是不同的，例如在Windows下为‘\r\n’。 |
| os.devnull | 在不同的系统上null设备的路径，在Windows下为‘nul’，在POSIX下为‘/dev/null’。 |
| os.defpath | 当使用exec函数族的时候，如果没有指定PATH环境变量，则默认会查找os.defpath中的值作为子进程PATH的值。 |

使用范例：

```
>>> import os
>>> os.name
'nt'
>>> os.environ
environ({'ALLUSERSPROFILE': 'C:\\ProgramData', 'APPDATA': 'C:\\Users\\Administrator\\AppData\\Roaming', 'ASL.LOG': 'Destination=file', ......
>>> os.sep
'\\'
>>> os.altsep
'/'
>>> os.extsep
'.'
>>> os.pathsep
';'
>>> os.linesep
'\r\n'
>>> os.devnull
'nul'
>>> os.defpath
'.;C:\\bin'
```

## 2. 文件和目录操作

os模块中包含了一系列文件操作相关的函数，其中有一部分是Linux平台专用方法。Linux是用C写的，底层的`libc`库和系统调用的接口都是`C API`，Python的os模块中包括了对这些接口的Python实现，通过Python的os模块，可以调用Linux系统的一些底层功能，进行系统编程。关于Linux的相关方法，内容较为复杂，可根据需要自行查阅官方文档，这里只介绍一些常用的，各平台通用的方法。

| 方法和变量                          | 用途                                                         |
| ----------------------------------- | ------------------------------------------------------------ |
| os.getcwd()                         | 获取当前工作目录，即当前python脚本工作的目录路径             |
| os.chdir("dirname")                 | 改变当前脚本工作目录；相当于shell下cd                        |
| os.curdir                           | 返回当前目录: ('.')                                          |
| os.pardir                           | 获取当前目录的父目录字符串名：('..')                         |
| os.makedirs('dir1/dir2')            | 可生成多层递归目录                                           |
| os.removedirs(‘dirname1’)           | 递归删除空目录（要小心）                                     |
| os.mkdir('dirname')                 | 生成单级目录                                                 |
| os.rmdir('dirname')                 | 删除单级空目录，若目录不为空则无法删除并报错                 |
| os.listdir('dirname')               | 列出指定目录下的所有文件和子目录，包括隐藏文件               |
| os.remove('filename')               | 删除一个文件                                                 |
| os.rename("oldname","new")          | 重命名文件/目录                                              |
| os.stat('path/filename')            | 获取文件/目录信息                                            |
| os.path.abspath(path)               | 返回path规范化的绝对路径                                     |
| os.path.split(path)                 | 将path分割成目录和文件名二元组返回                           |
| os.path.dirname(path)               | 返回path的目录。其实就是`os.path.split(path)`的第一个元素    |
| os.path.basename(path)              | 返回path最后的文件名。如果path以`／`或`\`结尾，那么就会返回空值。 |
| os.path.exists(path或者file)        | 如果path存在，返回True；如果path不存在，返回False            |
| os.path.isabs(path)                 | 如果path是绝对路径，返回True                                 |
| os.path.isfile(path)                | 如果path是一个存在的文件，返回True。否则返回False            |
| os.path.isdir(path)                 | 如果path是一个存在的目录，则返回True。否则返回False          |
| os.path.join(path1[, path2[, ...]]) | 将多个路径组合后返回，第一个绝对路径之前的参数将被忽略       |
| os.path.getatime(path)              | 返回path所指向的文件或者目录的最后存取时间                   |
| os.path.getmtime(path)              | 返回path所指向的文件或者目录的最后修改时间                   |
| os.path.getsize(filename)           | 返回文件包含的字符数量                                       |

在Python中，使用windows的文件路径时一定要小心，比如你要引用d盘下的1.txt文件，那么路径要以字符串的形式写成`'d:\\1.txt'`或者`r'd:\1.txt`。前面的方式是使用windwos的双斜杠作为路径分隔符，后者是使用`原生字符串`的形式，以r开始的字符串都被认为是原始字符串，表示字符串里所有的特殊符号都以本色出演，不进行转义，此时可以使用普通windows下的路径表示方式。这两种方法使用哪种都可以，但不可混用。

下面是一些使用的例子，建议大家都跟着做一遍(其中有一些是错误示范，让你更清楚它的用法)。

```
>>> os.getcwd()
'C:\\Python36'
>>> os.chdir("d:")
>>> os.getcwd()
'D:\\'
>>> os.curdir
'.'
>>> os.pardir
'..'
>>> os.makedirs("1\\2")
>>> os.removedirs("1\\2")
>>> os.listdir()
['$360Section', '$RECYCLE.BIN', '1.txt', 'MobileFile', 'pymysql_test.py', 'System Volume Information', '用户目录']
>>> os.mkdir("1")
>>> os.listdir()
['$360Section', '$RECYCLE.BIN', '1', '1.txt', 'MobileFile', 'pymysql_test.py', 'System Volume Information', '用户目录']
>>> os.rmdir("1")
>>> os.rename('1.txt','2.txt')
>>> os.listdir()
['$360Section', '$RECYCLE.BIN', '2.txt', 'MobileFile', 'pymysql_test.py', 'System Volume Information', '用户目录']
>>> os.remove('1.txt')
Traceback (most recent call last):
  File "<pyshell#22>", line 1, in <module>
    os.remove('1.txt')
FileNotFoundError: [WinError 2] 系统找不到指定的文件。: '1.txt'
>>> os.remove('2.txt')
>>> os.stat()
Traceback (most recent call last):
  File "<pyshell#24>", line 1, in <module>
    os.stat()
TypeError: Required argument 'path' (pos 1) not found
>>> os.stat(os.getcwd())
os.stat_result(st_mode=16895, st_ino=1407374883553285, st_dev=2431137650, st_nlink=1, st_uid=0, st_gid=0, st_size=32768, st_atime=1505824872, st_mtime=1505824872, st_ctime=1445187376)
```

更多的操作：

```
>>> import os
>>> os.chdir("d:")
>>> os.getcwd()
'D:\\'
>>> os.mkdir('test')
>>> os.listdir()
['$360Section', '$RECYCLE.BIN', 'MobileFile', 'pymysql_test.py', 'System Volume Information', 'test', '用户目录']
>>> os.chdir('test')
>>> os.getcwd()
'D:\\test'
>>> os.path.abspath(os.getcwd())
'D:\\test'
>>> os.path.split(os.getcwd())
('D:\\', 'test')
>>> cp = os.getcwd()
>>> os.path.dirname(cp)
'D:\\'
>>> os.path.basename(cp)
'test'
>>> os.path.exists(cp)
True
>>> os.path.exists("d:\\123\123")
False
>>> os.path.isabs(cp)
True
>>> os.path.isabs("11\\1.py")
False
>>> os.path.isfile(cp)
False
>>> os.path.isfile("d:\\1.txt")
False
>>> os.path.isdir(cp)
True
>>> os.path.join(cp, "test.py")
'D:\\test\\test.py'
>>> os.path.getatime(cp)
1505825113.4970243
>>> os.path.getmtime(cp)
1505825113.4970243
>>> os.path.getsize(cp)
0
```

**os.walk(top, topdown=True, onerror=None, followlinks=False)**

walk方法是os模块中非常重要和强大的一个方法。可以帮助我们非常便捷地以递归方式自顶向下或者自底向上的方式遍历目录树，对每一个目录都返回一个三元元组(dirpath, dirnames, filenames)。

三元元组(dirpath，dirnames，filenames)：

dirpath - 遍历所在目录树的位置，是一个字符串对象

dirnames - 目录树中的子目录组成的列表，不包括("."和"..")

filenames - 目录树中的文件组成的列表

如果可选参数`topdown = True`或者没有指定，则采用自顶向下的方式进行目录遍历，也就是从父目录向子目录逐步深入遍历，如果`topdown = False`，则采用自底向上的方式遍历目录，也就是先打印子目录再打印父目录的方式。

如果可选参数`onerror`被指定，则`onerror`必须是一个函数，该函数有一个`OSError`实例的参数，这样可以允许在运行的时候即使出现错误的时候不会打断`os.walk()`的执行，或者抛出一个异常并终止`os.walk()`的运行。通俗的讲，就是定义这个参数用于指定当发生了错误时的处理方法。

默认情况下，os.walk()遍历的时候不会进入符号链接，如果设置了可选参数`followlinks = True`，则会进入符号链接。注意，这可能会出现遍历死循环，因为符号链接可能会出现自己链接自己的情况，而`os.walk()`没有那么高的智商，无法发现这一点。

下面的例子会将`c:\python36`目录中的所有文件和子目录打印出来。

```
import os

try:
    for root, dirs, files in os.walk(r"c:\python36"):
        print("\033[1;31m-"*8, "directory", "<%s>\033[0m" % root, "-"*10)
        for directory in dirs:
            print("\033[1;34m<DIR>    %s\033[0m" % directory)
        for file in files:
            print("\t\t%s" % file)
except OSError as ex:
    print(ex)
```

运行结果：

```
-------- directory <c:\python36> ----------
<DIR>    DLLs
<DIR>    Doc
<DIR>    include
<DIR>    Lib
<DIR>    libs
<DIR>    Scripts
<DIR>    share
<DIR>    tcl
<DIR>    Tools
        LICENSE.txt
        NEWS.txt
        python.exe
        python3.dll
        python36.dll
        pythonw.exe
        vcruntime140.dll
-------- directory <c:\python36\DLLs> ----------
        py.ico
        pyc.ico
......太长了，截取部分
```

下面的例子会统计`c:/python36/Lib/email`目录下所有子目录的大小，但是CVS目录除外。

```
import os
from os.path import join, getsize
for root, dirs, files in os.walk('c:/python36/Lib/email'):
    print(root, "consumes", end=" ")
    print(sum(getsize(join(root, name)) for name in files), end=" ")
    print("bytes in", len(files), "non-directory files")
    if 'CVS' in dirs:
        dirs.remove('CVS')  # 不遍历CVS目录
```

运行结果：

```
C:\Python36\python.exe F:/Python/pycharm/201705/1.py -
c:/python36/Lib/email consumes 377849 bytes in 21 non-directory files
c:/python36/Lib/email\mime consumes 12205 bytes in 9 non-directory files
c:/python36/Lib/email\mime\__pycache__ consumes 30289 bytes in 27 non-directory files
c:/python36/Lib/email\__pycache__ consumes 741924 bytes in 60 non-directory files
```

下面的例子会递归删除目录的所有内容，危险，请勿随意尝试！

```
import os
for root, dirs, files in os.walk(top, topdown=False):
    for name in files:
        os.remove(os.path.join(root, name))
    for name in dirs:
        os.rmdir(os.path.join(root, name))
```

## 3. 执行命令

在早期的Python版本中，通常使用os模块的system或者popen等方法执行操作系统的命令。但是，最近Python官方逐渐弃用了这些命令，而是改用内置的subprocess模块执行操作系统相关命令。由于目前还有很多人仍然在使用os的system和popen方法，在此简要介绍一下。

**os.system(command)**

运行操作系统命令，直接显示结果。但返回值是0或-1，不能获得显示在屏幕上的数据。 command是要执行的命令字符串。

我们尝试在linux下使用ipython交互式界面运行一下：

```
In [1]: import os

In [2]: ret = os.system("ifconfig")
eth0      Link encap:Ethernet  HWaddr 02:16:3e:31:ff:3b  
          inet addr:176.17.230.109  Bcast:176.17.230.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:274674 errors:0 dropped:0 overruns:0 frame:0
          TX packets:260923 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:62664341 (62.6 MB)  TX bytes:83842737 (83.8 MB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:244020 errors:0 dropped:0 overruns:0 frame:0
          TX packets:244020 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1 
          RX bytes:376137873 (376.1 MB)  TX bytes:376137873 (376.1 MB)
In [3]: ret
Out[3]: 0
```

可以看到运行的返回值是0，而不是我们期望的输出信息。

如果我们是在windows环境下使用IDLE运行`os.system('ipconfig /all')`，你会发现命令终端界面一闪而过，根本啥都来不及看。这时候，你最好进入cmd环境使用`python`命令进入交互式界面才可以看到屏幕上的信息。

另外，请尝试在不同环境下执行`os.system('python3')`。

**os.popen(command, [mode, [bufsize]])**

开启一个子进程执行command参数指定的命令，在父进程和子进程之间建立一个管道pipe，用于在父子进程间通信。该方法返回一个文件对象，可以对这个文件对象进行读或写，取决于参数mode，如果mode指定了只读，那么只能对文件对象进行读，如果mode参数指定了只写，那么只能对文件对象进行写操作。

简而言之，`popen`也可以运行操作系统命令，并通过read()方法将命令的结果返回，不像`system`只能看不能存，这个能存！

```
>>> os.popen('ipconfig')
<os._wrap_close object at 0x0000000002BB8EF0>
>>> ret = os.popen('ipconfig')
>>> ret.read()
'\nWindows IP 配置\n\n\n以太网适配器 Bluetooth 网络连接 2:\n\n   媒体状态  . . . . . . . . . . . . : 媒体已断开\n   连接特定的 DNS 后缀 . . . . . . . : \n\n无线局域网适配器 无线网络连接 2:\n\n   媒体状态  . . . . . . . . . . . . : 媒体已断开\n   连接特定的 DNS 后缀 . . . . . . . : \n\n无线局域网适配器 无线网络连接:\n\n   连接特定的 DNS 后缀......
```

试试运行类似`python3`这种会进入交互式界面的命令看看，结果不是很理想，无法进入想要的交互式界面：

```
>>> ret = os.popen('python3')
>>> ret
<os._wrap_close object at 0x0000000002BB8E80>
>>> ret.read()
''
```