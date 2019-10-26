# timeit

阅读: 4087   [评论](http://www.liujiangblog.com/course/python/70#comments)：0

前面我们介绍过，`time.time()`和`time.clock()`方法可以用来计算程序执行时间及cpu时间。但是，很多时候我们只想对某些代码片段或者算法进行执行时间的统计，这时候，使用timeit模块就比较方便。timeit模块是Python内置的用于统计小段代码执行时间的模块，它同时提供命令行调用接口。

## 实例

下面是三个命令行下的执行例子：

```
$ python3 -m timeit '"-".join(str(n) for n in range(100))'
10000 loops, best of 3: 30.2 usec per loop
$ python3 -m timeit '"-".join([str(n) for n in range(100)])'
10000 loops, best of 3: 27.5 usec per loop
$ python3 -m timeit '"-".join(map(str, range(100)))'
10000 loops, best of 3: 23.2 usec per loop
```

**注意:在windows命令行中执行时，最外围要用双引号**

上面的例子在IDLE环境下，是这么样的：

```
>>> import timeit
>>> timeit.timeit('"-".join(str(n) for n in range(100))', number=10000)
0.3018611848820001
>>> timeit.timeit('"-".join([str(n) for n in range(100)])', number=10000)
0.2727368790656328
>>> timeit.timeit('"-".join(map(str, range(100)))', number=10000)
0.23702679807320237
```

## Python接口

**timeit.timeit(stmt='pass', setup='pass', timer=, number=1000000, globals=None)**

创建一个Timer实例，并运行代码进行计时，默认将代码执行一百万次。

`stmt`是要执行的代码，字符串形式，多行就多个字符串。`setup`是执行前的环境配置，比如import语句。`timer`是使用的计时器。`number`是执行的次数。`globals`是执行的命名空间。

**timeit.repeat(stmt='pass', setup='pass', timer=, repeat=3, number=1000000, globals=None)**

指定重复次数的执行timeit方法，返回一个结果列表。

**timeit.default_timer()**

默认的计时器，也就是`time.perf_counter()`

**class timeit.Timer(stmt='pass', setup='pass', timer=, globals=None)**

用于进行代码执行速度测试的计时类。该类有四个方法：

- timeit(number=1000000)
- autorange(callback=None)
- repeat(repeat=3, number=1000000)
- print_exc(file=None)

## 命令行界面

命令格式： `python -m timeit [-n N] [-r N] [-u U] [-s S] [-t] [-c] [-h] [语句 ...]`

参数：

```
-n：执行次数
-r：计时器重复次数
-s：执行环境配置（通常该语句只被执行一次）
-p：处理器时间
-v：打印原始时间
-h：帮助
```

## 更多的例子

**1. 设置setup参数**

```
$ python -m timeit -s 'text = "sample string"; char = "g"'  'char in text'
10000000 loops, best of 3: 0.0877 usec per loop
$ python -m timeit -s 'text = "sample string"; char = "g"'  'text.find(char)'
1000000 loops, best of 3: 0.342 usec per loop
>>> import timeit
>>> timeit.timeit('char in text', setup='text = "sample string"; char = "g"')
0.41440500499993504
>>> timeit.timeit('text.find(char)', setup='text = "sample string"; char = "g"')
1.7246671520006203
```

也可以这么调用：

```
>>> import timeit
>>> t = timeit.Timer('char in text', setup='text = "sample string"; char = "g"')
>>> t.timeit()
0.3955516149999312
>>> t.repeat()
[0.40193588800002544, 0.3960157959998014, 0.39594301399984033]
```

**2. 测试多行语句执行时间**

测试的对象是str和int两种数据类型，一个有`__bool__`属性，一个没有。调用语句一个用try语法，一个用hasattr语法。最终显示不同情况下的执行效率。

```
$ python -m timeit 'try:' '  str.__bool__' 'except AttributeError:' '  pass'
100000 loops, best of 3: 15.7 usec per loop
$ python -m timeit 'if hasattr(str, "__bool__"): pass'
100000 loops, best of 3: 4.26 usec per loop

$ python -m timeit 'try:' '  int.__bool__' 'except AttributeError:' '  pass'
1000000 loops, best of 3: 1.43 usec per loop
$ python -m timeit 'if hasattr(int, "__bool__"): pass'
100000 loops, best of 3: 2.23 usec per loop
>>> import timeit
>>> # attribute is missing
>>> s = """\
... try:
...     str.__bool__
... except AttributeError:
...     pass
... """
>>> timeit.timeit(stmt=s, number=100000)
0.9138244460009446
>>> s = "if hasattr(str, '__bool__'): pass"
>>> timeit.timeit(stmt=s, number=100000)
0.5829014980008651
>>>
>>> # attribute is present
>>> s = """\
... try:
...     int.__bool__
... except AttributeError:
...     pass
... """
>>> timeit.timeit(stmt=s, number=100000)
0.04215312199994514
>>> s = "if hasattr(int, '__bool__'): pass"
>>> timeit.timeit(stmt=s, number=100000)
0.08588060699912603
```

**3. 在方法内通过setup参数指定调用对象**

```
def test():
    """Stupid test function"""
    L = [i for i in range(100)]

if __name__ == '__main__':
    import timeit
    print(timeit.timeit("test()", setup="from __main__ import test"))
```

**4. 通过globals参数指定运行空间**

```
def f(x):
    return x**2
def g(x):
    return x**4
def h(x):
    return x**8

import timeit
print(timeit.timeit('[func(42) for func in (f,g,h)]', globals=globals()))
```