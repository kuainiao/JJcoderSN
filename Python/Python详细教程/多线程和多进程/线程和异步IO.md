# 协程与异步IO

阅读: 9972   [评论](http://www.liujiangblog.com/course/python/83#comments)：10

通常在Python中我们进行并发编程一般都是使用多线程或者多进程来实现的，对于CPU计算密集型任务由于GIL的存在通常使用多进程来实现，而对于IO密集型任务可以通过线程调度来让线程在执行IO任务时让出GIL，从而实现表面上的并发。

其实对于IO密集型任务我们还有一种选择就是协程。**协程，又称微线程，英文名`Coroutine`**，是运行在单线程中的“并发”，协程相比多线程的一大优势就是省去了多线程之间的切换开销，获得了更高的运行效率。Python中的异步IO模块asyncio就是基本的协程模块。

Python中的协程经历了很长的一段发展历程。最初的生成器`yield`和`send()`语法，然后在Python3.4中加入了`asyncio`模块，引入`@asyncio.coroutine`装饰器和`yield from`语法，在Python3.5上又提供了`async/await`语法，目前正式发布的Python3.6中`asynico`也由临时版改为了稳定版。

## 1. 协程：

协程的切换不同于线程切换，是由程序自身控制的，没有切换的开销。协程不需要多线程的锁机制，因为都是在同一个线程中运行，所以没有同时访问数据的问题，执行效率比多线程高很多。

因为协程是单线程执行，那怎么利用多核CPU呢？最简单的方法是多进程+协程，既充分利用多核，又充分发挥协程的高效率，可获得极高的性能。

如果你还无法理解协程的概念，那么可以这么简单的理解：

**进程/线程：操作系统提供的一种并发处理任务的能力。**

**协程：程序员通过高超的代码能力，在代码执行流程中人为的实现多任务并发，是单个线程内的任务调度技巧。**

多进程和多线程体现的是操作系统的能力，而协程体现的是程序员的流程控制能力。看下面的例子，甲，乙两个工人模拟两个工作任务交替进行，在单线程内实现了类似多线程的功能。

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-

import time

def task1():
    while True:
        yield "<甲>也累了，让<乙>工作一会儿"
        time.sleep(1)
        print("<甲>工作了一段时间.....")


def task2(t):
    next(t)
    while True:
        print("-----------------------------------")
        print("<乙>工作了一段时间.....")
        time.sleep(2)
        print("<乙>累了，让<甲>工作一会儿....")
        ret = t.send(None)
        print(ret)
    t.close()

if __name__ == '__main__':
    t = task1()
    task2(t)
```

运行结果：

```
<乙>工作了一段时间.....
<乙>累了，让<甲>工作一会儿....
<甲>工作了一段时间.....
<甲>也累了，让<乙>工作一会儿
-----------------------------------
<乙>工作了一段时间.....
<乙>累了，让<甲>工作一会儿....
<甲>工作了一段时间.....
<甲>也累了，让<乙>工作一会儿
-----------------------------------
<乙>工作了一段时间.....
<乙>累了，让<甲>工作一会儿....
<甲>工作了一段时间.....
<甲>也累了，让<乙>工作一会儿
-----------------------------------
<乙>工作了一段时间.....
```

## 2. yield

最早的时候，Python提供了yield关键字，用于制造生成器。也就是说，包含有yield的函数，都是一个生成器！

**yield的语法规则是：在yield这里暂停函数的执行，并返回yield后面表达式的值（默认为None），直到被next()方法再次调用时，从上次暂停的yield代码处继续往下执行。**当没有可以继续next()的时候，抛出异常，该异常可被for循环处理。

```
>>> def fib(n):
    a, b = 0, 1
    i = 0
    while i < n:
        yield b
        a, b = b, a+b
        i += 1
>>> f = fib(5)
>>> next(f)
1
>>> next(f)
1
>>> next(f)
2
>>> next(f)
3
>>> next(f)
5
>>> next(f)
Traceback (most recent call last):
  File "<pyshell#9>", line 1, in <module>
    next(f)
StopIteration
```

下面是通过for循环不断地使fib生成下一个数，实际上就是不断地调用next()方法。

```
def fib(n):
    a, b = 0, 1
    i = 0
    while i < n:
        yield b
        a, b = b, a+b
        i += 1

if __name__ == '__main__':
    f = fib(10)
    for item in f:
        print(item)
```

## 3. send()

最初的yield只能返回并暂停函数，并不能实现协程的功能。后来，Python为它定义了新的功能——接收外部发来的值，这样一个生成器就变成了协程。

**每个生成器都可以执行send()方法，为生成器内部的yield语句发送数据**。此时yield语句不再只是`yield xxxx`的形式，还可以是`var = yield xxxx`的赋值形式。**它同时具备两个功能，一是暂停并返回函数，二是接收外部send()方法发送过来的值，重新激活函数，并将这个值赋值给var变量！**

```
def simple_coroutine():
    print('-> 启动协程')
    y = 10
    x = yield y
    print('-> 协程接收到了x的值:', x)

my_coro = simple_coroutine()
ret = next(my_coro)
print(ret)
my_coro.send(10)
```

协程可以处于下面四个状态中的一个。当前状态可以导入inspect模块，使用inspect.getgeneratorstate(...) 方法查看，该方法会返回下述字符串中的一个。

- 'GEN_CREATED'　　等待开始执行。
- 'GEN_RUNNING'　　协程正在执行。
- 'GEN_SUSPENDED' 在yield表达式处暂停。
- 'GEN_CLOSED' 　　执行结束。

因为send()方法的参数会成为暂停的yield表达式的值，所以，仅当协程处于暂停状态时才能调用 send()方法，例如`my_coro.send(10)`。不过，如果协程还没激活（状态是`'GEN_CREATED'`），就立即把None之外的值发给它，会出现TypeError。因此，始终要先调用`next(my_coro)`激活协程（也可以调用`my_coro.send(None)`），这一过程被称作预激活。

除了send()方法，其实还有throw()和close()方法：

- generator.throw(exc_type[, exc_value[, traceback]])

使生成器在暂停的yield表达式处抛出指定的异常。如果生成器处理了抛出的异常，代码会向前执行到下一个yield表达式，而产出的值会成为调用`generator.throw()`方法得到的返回值。如果生成器没有处理抛出的异常，异常会向上冒泡，传到调用方的上下文中。

- generator.close()

使生成器在暂停的yield表达式处抛出`GeneratorExit`异常。如果生成器没有处理这个异常，或者抛出了`StopIteration`异常（通常是指运行到结尾），调用方不会报错。如果收到`GeneratorExit`异常，生成器一定不能产出值，否则解释器会抛出`RuntimeError`异常。生成器抛出的其他异常会向上冒泡，传给调用方。

## 4. @asyncio.coroutine与yield from

**@asyncio.coroutine：asyncio模块中的装饰器，用于将一个生成器声明为协程。**

**yield from 其实就是等待另外一个协程的返回。**

```
def func():
    for i in range(10):
        yield i

print(list(func()))
```

可以写成：

```
def func():
    yield from range(10)

print(list(func()))
```

从Python3.4开始asyncio模块加入到了标准库，通过asyncio我们可以轻松实现协程来完成异步IO操作。asyncio是一个基于事件循环的异步IO模块,通过`yield from`，我们可以将协程`asyncio.sleep()`的控制权交给事件循环，然后挂起当前协程；之后，由事件循环决定何时唤醒`asyncio.sleep`,接着向后执行代码。

下面这段代码，我们创造了一个协程display_date(num, loop)，然后它使用关键字yield from来等待协程`asyncio.sleep(2)()`的返回结果。而在这等待的2s之间它会让出CPU的执行权，直到`asyncio.sleep(2)`返回结果。`asyncio.sleep(2)`模拟的其实就是一个耗时2秒的IO读写操作。

```
import asyncio
import datetime

@asyncio.coroutine  # 声明一个协程
def display_date(num, loop):
    end_time = loop.time() + 10.0
    while True:
        print("Loop: {} Time: {}".format(num, datetime.datetime.now()))
        if (loop.time() + 1.0) >= end_time:
            break
        yield from asyncio.sleep(2)  # 阻塞直到协程sleep(2)返回结果
loop = asyncio.get_event_loop()  # 获取一个event_loop
tasks = [display_date(1, loop), display_date(2, loop)]
loop.run_until_complete(asyncio.gather(*tasks))  # "阻塞"直到所有的tasks完成
loop.close()
```

运行结果：

```
Loop: 2 Time: 2017-10-17 21:19:45.438511
Loop: 1 Time: 2017-10-17 21:19:45.438511
Loop: 2 Time: 2017-10-17 21:19:47.438626
Loop: 1 Time: 2017-10-17 21:19:47.438626
Loop: 2 Time: 2017-10-17 21:19:49.438740
Loop: 1 Time: 2017-10-17 21:19:49.438740
Loop: 2 Time: 2017-10-17 21:19:51.438855
Loop: 1 Time: 2017-10-17 21:19:51.438855
Loop: 2 Time: 2017-10-17 21:19:53.438969
Loop: 1 Time: 2017-10-17 21:19:53.438969
Loop: 2 Time: 2017-10-17 21:19:55.439083
Loop: 1 Time: 2017-10-17 21:19:55.439083
```

## 5. async和await

Python3.5中对协程提供了更直接的支持，引入了`async/await`关键字。上面的代码可以这样改写：使用`async`代替`@asyncio.coroutine`，使用`await`代替`yield from`，代码变得更加简洁可读。从Python设计的角度来说，`async/await`让协程独立于生成器而存在，不再使用yield语法。

```
import asyncio
import datetime

async def display_date(num, loop):      # 注意这一行的写法
    end_time = loop.time() + 10.0
    while True:
        print("Loop: {} Time: {}".format(num, datetime.datetime.now()))
        if (loop.time() + 1.0) >= end_time:
            break
        await asyncio.sleep(2)  # 阻塞直到协程sleep(2)返回结果

loop = asyncio.get_event_loop()  # 获取一个event_loop
tasks = [display_date(1, loop), display_date(2, loop)]
loop.run_until_complete(asyncio.gather(*tasks))  # "阻塞"直到所有的tasks完成
loop.close()
```

## 6. asyncio模块

asyncio的使用可分三步走：

1. 创建事件循环
2. 指定循环模式并运行
3. 关闭循环

通常我们使用`asyncio.get_event_loop()`方法创建一个循环。

运行循环有两种方法：一是调用`run_until_complete()`方法，二是调用`run_forever()`方法。`run_until_complete()`内置`add_done_callback`回调函数，`run_forever()`则可以自定义`add_done_callback()`，具体差异请看下面两个例子。

使用`run_until_complete()`方法：

```
import asyncio

async def func(future):
    await asyncio.sleep(1)
    future.set_result('Future is done!')

if __name__ == '__main__':

    loop = asyncio.get_event_loop()
    future = asyncio.Future()
    asyncio.ensure_future(func(future))
    print(loop.is_running())   # 查看当前状态时循环是否已经启动
    loop.run_until_complete(future)
    print(future.result())
    loop.close()
```

使用`run_forever()`方法：

```
import asyncio

async def func(future):
    await asyncio.sleep(1)
    future.set_result('Future is done!')

def call_result(future):
    print(future.result())
    loop.stop()

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    future = asyncio.Future()
    asyncio.ensure_future(func(future))
    future.add_done_callback(call_result)        # 注意这行
    try:
        loop.run_forever()
    finally:
        loop.close()
```