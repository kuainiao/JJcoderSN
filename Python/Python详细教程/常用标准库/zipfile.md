# zipfile

ZIP是通用的归档和压缩格式。zipfile模块提供了通用的创建、读取、写入、附加和显示压缩文件的方法，你可以简单地把它理解为Python中的zip解压缩软件。该模块可以解密带有密码的压缩文件，但不提供附加密码的压缩功能。

## 定义的类和异常

**class zipfile.ZipFile**

模块最重要的类。用于读写ZIP文件。

**class zipfile.PyZipFile**

创建包含Python库的ZIP归档文件的类

**class zipfile.ZipInfo(filename='NoName', date_time=(1980, 1, 1, 0, 0, 0))**

用于显示ZIP文件信息的类。ZIP对象的getinfo()或infolist()方法会返回一个该类的实例。`filename`是ZIP文件的完整名称。`date_time`是一个包含6个元素的元组，描述文件最近修改时间。

**zipfile.is_zipfile(filename)**

如果文件是个ZIP文件则返回True，否则False。

**zipfile.ZIP_STORED**

未压缩的归档文件的数字常数。

**zipfile.ZIP_DEFLATED**

常用的ZIP压缩方法。

**zipfile.ZIP_BZIP2**

BZIP2压缩方法的数字常量。

**zipfile.ZIP_LZMA**

LZMA压缩方法的数字常量。

**exception zipfile.BadZipFile**

ZIP文件被损坏异常。3.2版本新增。

**exception zipfile.LargeZipFile**

当需要ZIP64功能，但未开启该功能时弹出异常。

## ZipFile对象

**class zipfile.ZipFile(file, mode='r', compression=ZIP_STORED, allowZip64=True)**

打开一个ZIP文件。返回的也是一个类似文件的ZipFile对象，可以读写。

file可以是一个文件地址字符串、文件类对象或地址类对象。mode参数为r时，表示读取一个已经存在的文件；为w的时候表示覆盖或写入一个新文件；为a时表示在已有文件后追加；为x时表示新建文件并写入。x模式下，如果文件名已经存在，则抛出`FileExistsError`异常。这些特点和open()方法打开文件一样样的。

`compression`指明压缩格式，支持`ZIP_STORED`, `ZIP_DEFLATED`, `ZIP_BZIP2`和`ZIP_LZMA`。使用不支持的格式会抛出`NotImplementedError`异常。默认是`ZIP_STORED`格式。如果指定为`ZIP_DEFLATED`, `ZIP_BZIP2`或者`ZIP_LZMA`格式，但对应的支持模块`zlib`, `bz2`或者`lzma`不可用，则抛出`RuntimeError`异常。

当文件大小超过4GB时，将使用`ZIP64`扩展（默认启用）。

在`w/x/a`模式下，如果没有写入任何数据就`close`了，则会生成空的ZIP文件。

ZipFile也是一种上下文管理器（3.2版本新特性），同样支持with语句，如下例子所示：

```
with ZipFile('spam.zip', 'w') as myzip:
    myzip.write('eggs.txt')
```

**ZipFile.write(filename, arcname=None, compress_type=None)**

往ZIP文件里添加新文件，单个文件可以重复添加，但是会弹出警告。如果指定`arcname`参数，则在ZIP文件内部将原来的filename改成arcname。例如`z.write("test/111.txt", "test22/111.txt")`

```
import zipfile
import os

z = zipfile.ZipFile("test.zip", "w")

z.write(r"d:\test\1.txt")   # 注意路径的写法
z.write(r"d:\test\2.txt")
z.write(r"d:\\test\test.txt")
z.write(r"d:\\test\test.py")

z.close()
print(os.getcwd())
```

**ZipFile.close()**

确保压缩文件被正确关闭。

**ZipFile.getinfo(name)**

返回一个被压缩成员的ZipInfo对象。如果ZIP文件中没有该名字，将抛出异常。

**ZipFile.infolist()**

返回一个包含ZIP文件内所有成员信息的ZipInfo对象。

**ZipFile.namelist()**

返回ZIP文件内所有成员名字列表。

**ZipFile.open(name, mode='r', pwd=None, \*, force_zip64=False)**

访问档案中的指定文件。`pwd`是解压密码。该方法也是个上下文管理器，支持with语法。

```
with ZipFile('spam.zip') as myzip:
    with myzip.open('eggs.txt') as myfile:
        print(myfile.read())
```

r模式为只读模式，提供`read()`, `readline()`, `readlines()`, `__iter__()`, `__next__()`等方法.

w模式为写入模式，支持`write()`方法。此时对ZIP文件内其它成员的读写将抛出`ValueError`异常。

```
>>> import zipfile
>>> z = zipfile.ZipFile(r"d:\test.zip")
>>> z.namelist()
['test/1.txt', 'test/2.txt', 'test/test.txt', 'test/test.py']
>>> z.infolist()
[<ZipInfo filename='test/1.txt' filemode='-rw-rw-rw-' file_size=9>, <ZipInfo filename='test/2.txt' filemode='-rw-rw-rw-' file_size=9>, <ZipInfo filename='test/test.txt' filemode='-rw-rw-rw-' file_size=25>, <ZipInfo filename='test/test.py' filemode='-rw-rw-rw-' file_size=96>]
>>> z.getinfo("test/1.txt")
<ZipInfo filename='test/1.txt' filemode='-rw-rw-rw-' file_size=9>
>>> t = z.open("test/1.txt")
>>> ret = t.read()
>>> ret
b'asdasdasd'
```

**ZipFile.extract(member, path=None, pwd=None)**

解压单个文件。核心方法之一。将ZIP文件中的某个成员解压到当前目录。member必须是完整名，path是指定的解压目录。解压的过程不会破坏原压缩文件。

**ZipFile.extractall(path=None, members=None, pwd=None)**

批量解压文件。默认是全部解压。核心方法之一。

```
>>> z.extract("test/1.txt")
'C:\\Python36\\test\\1.txt'
>>> z.namelist()
['test/1.txt', 'test/2.txt', 'test/test.txt', 'test/test.py']
>>> z.extractall()
>>> z.namelist()
['test/1.txt', 'test/2.txt', 'test/test.txt', 'test/test.py']
>>> z.wirte(r"d:\3.txt")
Traceback (most recent call last):
  File "<pyshell#15>", line 1, in <module>
    z.wirte(r"d:\3.txt")
AttributeError: 'ZipFile' object has no attribute 'wirte'
>>> z.close()
>>> z = zipfile.ZipFile(r"d:\test.zip", "w")
>>> z.namelist()
[]
>>> z.write(r"d:\3.txt")
>>> z.close()
>>> z = zipfile.ZipFile(r"d:\test.zip", "a")
>>> z.write(r"d:\3.txt")
Warning (from warnings module):
  File "C:\Python36\lib\zipfile.py", line 1349
    return self._open_to_write(zinfo, force_zip64=force_zip64)
UserWarning: Duplicate name: '3.txt'
>>> z.write(r"d:\4.txt")
>>> z.namelist()
['3.txt', '3.txt', '4.txt']
>>> z.close()
```

**ZipFile.printdir()**

在stdout上打印ZIP文件的目录表。

**ZipFile.setpassword(pwd)**

设置通用的解压密码，用于解压加密压缩文件。

**ZipFile.read(name, pwd=None)**

从已打开的ZIP文件成员中读取数据。

**ZipFile.testzip()**

校验ZIP文件完整性。

**ZipFile.writestr(zinfo_or_arcname, data[, compress_type])**

往ZIP文件里添加字符串类型数据

**ZipFile.filename**

ZIP文件的名字

**ZipFile.debug**

调试输出的级别。从0到3。

**ZipFile.comment**

ZIP文件的注释内容。

## 总结

zipfile模块其实很简单，记住下面几个重要的方法就可以了。

| 方法                  | 用途                        |
| --------------------- | --------------------------- |
| z = zipfile.ZipFile() | 打开或者新建一个zip文件对象 |
| z.write()             | 添加文件到压缩包内          |
| z.infolist()          | 查看压缩包内的文件信息      |
| z.extract()           | 解压单个文件                |
| z.extractall()        | 解压所有文件                |
| z.close()             | 关闭压缩文件                |