# tarfile

阅读: 7895   [评论](http://www.liujiangblog.com/course/python/63#comments)：0

既然有压缩模块zipfile，那有一个归档模块tarfile也是很自然的。tarfile模块用于解包和打包文件，包括被`gzip`，`bz2`或`lzma`压缩后的打包文件。如果是`.zip`类型的文件，建议使用zipfile模块，更高级的功能请使用shutil模块。

## 定义的类和异常

**tarfile.open(name=None, mode='r', fileobj=None, bufsize=10240, `\**kwargs`)**

返回一个TarFile类型的对象。本质上就是打开一个文件对象。Python随处可见这种文件对象类型的设计，你很容易就明白，不是吗？

`name`是文件名或路径。

`bufsize`用于指定数据块的大小，默认为20*512字节。

`mode`是打开模式，一个类似`filemode[:compression]`格式的字符串，可以有下表所示的组合，默认为“r”。

| 模式       | 说明                                                       |
| ---------- | ---------------------------------------------------------- |
| 'r'or'r:*' | 自动解压并打开文件（推荐模式）                             |
| 'r:'       | 只打开文件不解压                                           |
| 'r:gz'     | 采用gzip格式解压并打开文件                                 |
| 'r:bz2'    | 采用bz2格式解压并打开文件                                  |
| 'r:xz'     | 采用lzma格式解压并打开文件                                 |
| 'x'or'x:'  | 仅创建打包文件，不压缩                                     |
| 'x:gz'     | 采用gzip方式压缩并打包文件                                 |
| 'x:bz2'    | 采用bzip2方式压缩并打包文件                                |
| 'x:xz'     | 采用lzma方式压缩并打包文件                                 |
| 'a'or'a:'  | 打开文件，并以不压缩的方式追加内容。如果文件不存在，则新建 |
| 'w'or'w:'  | 以不压缩的方式写入                                         |
| 'w:gz'     | 以gzip的方式压缩并写入                                     |
| 'w:bz2'    | 以bzip2的方式压缩并写入                                    |
| 'w:xz'     | 以lzma的方式压缩并写入                                     |
| `注意`     | 不支持'a:gz', 'a:bz2'和'a:xz'的模式                        |

如果当前模式不能正常打开文件用于读取，将抛出`ReadError`异常，这种情况下，请使用“r”模式。如果指定的压缩方式不支持，将抛出`CompressionError`异常。

在`w:gz`,`r:gz`,`w:bz2`,`r:bz2`,`x:gz`,`x:bz2`模式下，`tarfile.open()`方法额外接受一个压缩等级参数`compresslevel`，默认值为9。

**class tarfile.TarFile**

用于读写`tarfile`文件的类。不要直接使用这个类，请使用`tarfile.open()`方法。

**tarfile.is_tarfile(name)**

判断一个文件是否打包文件类型。

**exception tarfile.TarError**

tarfile模块所有异常类的基类

**exception tarfile.ReadError**

读异常

**exception tarfile.CompressionError**

压缩异常

**exception tarfile.StreamError**

流异常

**exception tarfile.ExtractError**

解压异常

**exception tarfile.HeaderError**

头部异常

**tarfile.ENCODING**

tarfile的编码方式。在windows系统中，字符编码为utf-8。在其它系统中为`sys.getfilesystemencoding()`方法的返回值。

## TarFile对象

该对象提供了访问打包文件的接口。打包文件本质上是数据块的序列。包中的每个文件成员都是由头部块和数据块组成的。在包中，文件有可能重复。**包里的每个文件都是一个TarInfo对象。所以遍历一个TarFile对象，就是遍历一个TarInfo对象的集合**，这一点要搞清楚。

TarFile对象同样可以使用with语句进行上下文管理。

**class tarfile.TarFile(name=None, mode='r', fileobj=None, format=DEFAULT_FORMAT, tarinfo=TarInfo, dereference=False, ignore_zeros=False, encoding=ENCODING, errors='surrogateescape', pax_headers=None, debug=0, errorlevel=0)**

TarFile类

**TarFile.getmember(name)**

获取某个成员的信息

**TarFile.getmembers()**

获取包内所有成员的信息

**TarFile.getnames()**

获取包内所有成员的名字

**TarFile.list(verbose=True, \*, members=None)**

列表显示包内成员信息

**TarFile.next()**

显示下一个文件的信息

**TarFile.extractall(path=".", members=None, \*, numeric_owner=False)**

解包所有文件到当前目录，或path指定的目录。警告：解包文件之前一定要确保安全，防止覆盖本地或上级目录等恶意行为。

**TarFile.extract(member, path="", set_attrs=True, \*, numeric_owner=False)**

解包指定文件

**TarFile.extractfile(member)**

同上

**TarFile.add(name, arcname=None, recursive=True, exclude=None, \*, filter=None)**

将指定文件加入包内。`arcname`参数用于变换路径和文件名。默认情况下，文件夹会被递归的加入包内，除非`recursive`参数设为`False`。`filter`参数指向一个方法，该方法用来过滤哪些文件不会被打入包内，不被打包的就返回个None，会的就返回`tarinfo`本身，该方法为3.2版本新增，同时废弃原有的exclude方法。

**TarFile.addfile(tarinfo, fileobj=None)**

将一个tarinfo对象关联的文件加入包内。

**TarFile.close()**

关闭TarFile文件。在“w”模式下，会在文件末尾添加量个zero块。

使用范例：

```
>>> import os
>>> os.getcwd()
'C:\\Python36'
>>> os.chdir("d:\\test")
>>> os.getcwd()
'd:\\test'
>>> os.listdir()
['1.txt', '2.txt', 'test.py', 'test.txt']
>>> import tarfile
>>> tar = tarfile.open("test.tar.gz", "w:gz")
>>> tar.add("1.txt")
>>> tar.add("2.txt")
>>> tar.add("test.txt")
>>> tar.add("test.py")
>>> tar.close()
>>> os.listdir()
['1.txt', '2.txt', 'test.py', 'test.tar.gz', 'test.txt']
>>> tar = tarfile.open("test.tar.gz",)
>>> tar.getmembers()
[<TarInfo '1.txt' at 0x2a7ae58>, <TarInfo '2.txt' at 0x2df6368>, <TarInfo 'test.txt' at 0x2df6430>, <TarInfo 'test.py' at 0x2df64f8>]
>>> tar.getnames()
['1.txt', '2.txt', 'test.txt', 'test.py']
>>> tar.list()
?rw-rw-rw- 0/0          9 2017-05-17 22:05:31 1.txt 
?rw-rw-rw- 0/0          9 2017-05-17 22:05:31 2.txt 
?rw-rw-rw- 0/0         25 2017-05-16 11:54:45 test.txt 
?rw-rw-rw- 0/0         96 2017-05-18 08:50:59 test.py 
>>> tar.getmember("1.txt")
<TarInfo '1.txt' at 0x2a7ae58>
```

## TarInfo对象

一个TarInfo对象代表TarFile里的一个成员。除了保存所有文件必需的属性（例如文件类型、大小、时间、权限、拥有者等等），它还提供了很多有用的方法，用来判断它的类型。但是它不包含文件的具体数据内容。

TarFile对象的`getmember()`,`getmembers()`和`gettarinfo()`会返回TarInfo对象。

| 名称                           | 解释               |
| ------------------------------ | ------------------ |
| class tarfile.TarInfo(name="") | TarInfo类          |
| TarInfo.name                   | 名字               |
| TarInfo.size                   | 大小               |
| TarInfo.mtime                  | 最近的修改时间     |
| TarInfo.mode                   | 权限               |
| TarInfo.type                   | 文件类型           |
| TarInfo.linkname               | 连接目标的名字     |
| TarInfo.uid                    | 用户id             |
| TarInfo.gid                    | 组id               |
| TarInfo.uname                  | 用户名             |
| TarInfo.gname                  | 组名               |
| TarInfo.isfile()               | 判断是否文件       |
| TarInfo.isdir()                | 判断是否目录       |
| TarInfo.issym()                | 判断是否符号链接   |
| TarInfo.islnk()                | 判断是否硬链接     |
| TarInfo.ischr()                | 判断是否字符设备   |
| TarInfo.isblk()                | 判断是否块设备     |
| TarInfo.isfifo()               | 判断是否FIFO设备   |
| TarInfo.isdev()                | 判断是否是设备文件 |

## 命令行界面

tarfile模块还提供一种命令行界面下的交互模式。该功能属于Python3.4版本新增。

如果你想创建一个包，在-c参数后指定包名称，然后列出打包的文件，如下所示（-m参数是指定使用的模块）：

```
$ python -m tarfile -c monty.tar  spam.txt eggs.txt
```

也可以指定一个文件夹：

```
$ python -m tarfile -c monty.tar life-of-brian_1979/
```

如果想要解包到当前目录，请使用-e参数：

```
$ python -m tarfile -e monty.tar
```

当然，也可以解包到指定目录：

```
$ python -m tarfile -e monty.tar  other-dir/
```

想查看包内文件列表，使用-l参数：

```
$ python -m tarfile -l monty.tar
```

## 一些例子

1.解包到当前目录

```
import tarfile
tar = tarfile.open("sample.tar.gz")
tar.extractall()
tar.close()
```

2.指定包内某一类型文件被解包

```
import os
import tarfile

def py_files(members):
    for tarinfo in members:
        if os.path.splitext(tarinfo.name)[1] == ".py":
            yield tarinfo

tar = tarfile.open("sample.tar.gz")
tar.extractall(members=py_files(tar))
tar.close()
```

3.根据文件名列表，创建不压缩的包

```
import tarfile
tar = tarfile.open("sample.tar", "w")
for name in ["foo", "bar", "quux"]:
    tar.add(name)
tar.close()
```

使用with语句的写法：

```
import tarfile
with tarfile.open("sample.tar", "w") as tar:
    for name in ["foo", "bar", "quux"]:
        tar.add(name)
```

4.解包使用gzip压缩的包文件，并显示部分信息。

```
import tarfile
tar = tarfile.open("sample.tar.gz", "r:gz")
for tarinfo in tar:
    print(tarinfo.name, "is", tarinfo.size, "bytes in size and is", end="")
    if tarinfo.isreg():
        print("a regular file.")
    elif tarinfo.isdir():
        print("a directory.")
    else:
        print("something else.")
tar.close()
```

5.往包内添加文件，并使用filter参数修改文件信息。

```
import tarfile
def reset(tarinfo):
    tarinfo.uid = tarinfo.gid = 0
    tarinfo.uname = tarinfo.gname = "root"
    return tarinfo
tar = tarfile.open("sample.tar.gz", "w:gz")
tar.add("foo", filter=reset)
tar.close()
```

6.压缩并打包文件夹下的所有文件及目录

```
import os  
import tarfile  

tar = tarfile.open('test.tar','w:gz')  
for root ,dir,files in os.walk(os.getcwd()):  
    for file in files:  
        fullpath = os.path.join(root,file)  
        tar.add(fullpath) 
```

## 总结

tarfile模块看似复杂，其实也很简单，只需要掌握下面几个重点方法就可以了：

| 方法               | 说明                                               |
| ------------------ | -------------------------------------------------- |
| t = tarfile.open() | 打开或新建一个归档文件，返回一个TarFile类型的对象t |
| t.getmembers()     | 获取包内所有成员的信息                             |
| t.add()            | 将指定文件加入包内                                 |
| t.extract()        | 解包指定文件                                       |
| t.extractall()     | 解包所有文件                                       |
| TarFile.close()    | 关闭TarFile文件                                    |

感觉和zipfile模块的使用是不是很像？需要注意的是两者在打开文件、获取文件信息和添加文件的命令名称不一样。