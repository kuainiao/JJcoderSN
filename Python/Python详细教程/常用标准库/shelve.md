# shelve

阅读: 3311   [评论](http://www.liujiangblog.com/course/python/67#comments)：1

前面我们介绍了json和pickle，这里再介绍一个简单好用的shelve持久化模块。

shelve模块以类似字典的方式将Python对象持久化，它依赖于pickle模块，但比pickle用起来简单。当我们写程序的时候如果不想用关系数据库那么重量级的程序去存储数据，可以简单地使用shelve。shelve使用起来和字典类似，也是用key来访问的，键为普通字符串，值则可以是任何Python数据类型，并且支持所有字典类型的操作。

shelve模块最主要的两个方法：

**shelve.open(filename, flag='c', protocol=None, writeback=False)**

创建或打开一个shelve对象。

**shelve.close()**

同步并关闭shelve对象。

每次使用完毕，都必须确保shelve对象被安全关闭。同样可以使用with语句。

```
with shelve.open('spam') as db:
    db['eggs'] = 'eggs'
```

通过shelve.open()方法打开一个shelve对象后，就可以使用类似字典的方式操作这个对象，如下面的例子所示：

```
import shelve

d = shelve.open(filename)       # 打开一个shelve文件

d[key] = data                       # 存入数据
data = d[key]                       # 获取数据
del d[key]                          # 删除某个键值对
flag = key in d                     # 判断某个键是否在字典内
klist = list(d.keys())              # 列出所有的键

d.close()                  # 关闭shelve文件
```

注意，这里不用提供读写模式！shelve默认打开方式就支持同时读写操作。

### writeback参数

默认情况下，`writeback=False`，这时:

```
>>> import shelve
>>> d = shelve.open("d:\\1")
>>> d['list'] = [0, 1,  2]      # 正常工作
>>> d['list']
[0, 1, 2]
>>> d['list'].append(3)     # 给它添加个3
>>> d['list']               # 无效！d['list']还是[0, 1, 2]!
[0, 1, 2]
```

怎么办呢？使用中间变量！

```
temp = d['list']             
temp.append(3)                          # 修改数据
d['list'] = temp                        # 再存回去
```

或者使用`d=shelve.open(filename,writeback=True)`的方式可以让你正常进行`d['list'].append(3)`的操作。 但是这会消耗大量的内存，同时让`d.close()`操作变得缓慢。

shelve在默认情况下是不会记录对持久化对象的任何后续修改的！

如果我们想让shelve去自动捕获对象的变化，应该在打开shelve文件的时候将`writeback`参数设置为True。此时，shelve会将所有数据放到缓存中，并接收后续对数据的修改操作。最后，当我们`close()`的时候，缓存中所有的对象一次性写回磁盘内。

`writeback=True`有优点也有缺点。优点是可以动态修改数据，并减少出错的概率，让对象的持久化对用户更加的透明。但也有很大的缺点，在`open()`的时候会增加额外的内存消耗，并且当`close()`对象的时候会将缓存中的每一个细节都写回到文件系统，这也会带来额外的等待时间和计算消耗，因为shelve没有办法知道缓存中哪些对象修改了，哪些对象没有修改，所有的对象都必须被写入。