# queue

阅读: 6047   [评论](http://www.liujiangblog.com/course/python/59#comments)：0

当今市面上有很多主流的消息中间件，如老牌的ActiveMQ、RabbitMQ、ZeroMQ，炙手可热的Kafka，还有阿里巴巴自主开发的Notify、MetaQ、RocketMQ等。这些都是大型的重量级消息队列，通常应用于商业生产环境。但是，如果只是小型服务或者任务量不大，再或者学习、实验、测试等情况下，你有必要去搭建或者购买一个本身就已经很庞大的消息服务么？杀鸡焉用牛刀，当然不需要！

Python为我们内置了一个微型轻量级的消息队列模块，queue！queue模块主要用于多生产者和消费者模式下的队列实现，特别适合多线程时的消息交换。它实现了常见的锁语法，临时阻塞线程，防止竞争，这有赖于Python对线程的支持。

![image.png-80.9kB](queue.assets/image.png)

### queue模块实现了三种队列：

**FIFO**：先进先出队列，类似管道。元素只能从队头方向一个一个的弹出，只能从队尾一个一个的放入。

![image.png-101.2kB](queue.assets/image.png)

**LIFO**：后进先出队列，也就是栈。元素永远只能在栈顶出入。

![image.png-61.8kB](queue.assets/image.png)

**priority queue**：优先级队列，每个元素都带有一个优先值，值越小的越早出去。值相同的，先进入队列的先出去。

![image.png-278.6kB](queue.assets/image-1572068641331.png)

### queue模块定义了下面几个类和异常（一定要注意大小写！） ：

**class queue.Queue(maxsize=0)：**

FIFO队列构造器。`maxsize`是队列里最多能同时存在的元素个数。如果队列满了，则会暂时阻塞队列，直到有消费者取走元素。maxsize的值如果小于或等于零，表示队列元素个数不设上限，理论上可无穷个，但要小心，内存不是无限大的，这样可能会让你的内存溢出。

**class queue.LifoQueue(maxsize=0)**

LIFO队列构造器。maxsize是队列里最多能同时放置的元素个数。如果队列满了，则会暂时阻塞队列，直到有消费者取走元素。maxsize的值如果小于或等于零，表示队列元素个数不设上限，可无穷个。

**class queue.PriorityQueue(maxsize=0)**

优先级队列构造器。maxsize是队列里最多能同时放置的元素个数。如果队列满了，则会暂时阻塞队列，直到有消费者取走元素。maxsize的值如果小于或等于零，表示队列元素个数不设上限，可无穷个。通常在这类队列中，元素的优先顺序是按sorted(list(entries))[0]的结果来定义的，而元素的结构形式通常是(priority_number, data)类型的元组。

**exception queue.Empty**

从空的队列里请求元素的时候，弹出该异常。

**exception queue.Full**

往满的队列里放入元素的时候，弹出该异常。

## Queue对象

三种队列类的对象都提供了以下通用的方法：

**Queue.qsize()**

返回当前队列内的元素的个数。注意，`qsize()`大于零不等于下一个`get()`方法一定不会被阻塞，`qsize()`小于`maxsize`也不表示下一个`put()`方法一定不会被阻塞。

**Queue.empty()**

队列为空则返回True，否则返回False。同样地，返回True不表示下一个`put()`方法一定不会被阻塞。返回False不表示下一个`get()`一定不会被阻塞。

**Queue.full()**

与empty()方法正好相反。同样不保证下一步的操作不被阻塞。

**Queue.put(item, block=True, timeout=None)**

item参数表示具体要放入队列的元素。block和timeout两个参数配合使用。其中，如果`block=True，timeout=None`，队列阻塞，直到有空槽出现；当`block=True，timeout=正整数N`，如果在等待了N秒后，队列还没有空槽，则弹出Full异常；如果`block=False`，则timeout参数被忽略，队列有空槽则立即放入，如果没空槽，则弹出Full异常。

**Queue.put_nowait(item)**

等同于`put(item, False)`

**Queue.get(block=True, timeout=None)**

从队列内删除并返回一个元素。如果`block=True, timeout=None`，队列会阻塞，直到有可供弹出的元素。如果timeout指定为一个正整数N，则在N秒内如果队列内没有可供弹出的元素，则抛出Empty异常。如果`block=False`，timeout参数会被忽略，此时队列内如果有元素则直接弹出，无元素可弹，则抛出Empty异常。

```
Queue.get_nowait()
```

等同于get(False).

下面的两个方法用于跟踪排队的任务是否被消费者守护线程完全处理。

**Queue.task_done()**

表明先前的队列任务已完成。由消费者线程使用。

**Queue.join()**

阻塞队列，直到队列内的所有元素被获取和处理。

当有元素进入队列时未完成任务的计数将增加。每当有消费者线程调用task_done()方法表示一个任务被完成时，未完成任务的计数将减少。当该计数变成0的时候，join()方法将不再阻塞。

### 实例展示

看一些使用的例子：

```
>>> import queue
>>> q = queue.Queue(5)
>>> q.put(1)
>>> q.put(2)
>>> q.put(3)
>>> q.get()
1
>>> q.get()
2
>>> q.get()
3
>>> q.get()  # 阻塞了
-------------------------------------
>>> q = queue.Queue(5)
>>> q.maxsize
5
>>> q.qsize()
0
>>> q.empty()
True
>>> q.full()
False
>>> q.put(123)
>>> q.put("abc")
>>> q.put(["1","2"])
>>> q.put({"name":"tom"})
>>> q.put(None)
>>> q.put("6")   # 阻塞了
-----------------------------------
>>> q = queue.LifoQueue()
>>> q.put(1)
>>> q.put(2)
>>> q.put(3)
>>> q.get()
3
>>> q.get()
2
>>> q.get()
1
-------------------------------------
>>> q = queue.PriorityQueue()
>>> q.put((3,"haha"))
>>> q.put((2,"heihei"))
>>> q.put((1,"hehe"))
>>> q.get()
(1, 'hehe')
>>> q.get()
(2, 'heihei')
>>> q
<queue.PriorityQueue object at 0x0000016825583470>
>>> q.put((4, "xixi"))
>>> q.get()
(3, 'haha')
```

下面是一个等待排队任务如何完成的例子：

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-
import time
import queue
import threading


def worker(i):
    while True:
        item = q.get()
        if item is None:
            print("线程%s发现了一个None,可以休息了^-^" % i)
            break
        # do_work(item)做具体的工作
        time.sleep(0.5)
        print("线程%s将任务<%s>完成了！" % (i, item))
        # 做完后发出任务完成信号，然后继续下一个任务
        q.task_done()


if __name__ == '__main__':
    num_of_threads = 5

    source = [i for i in range(1, 21)]  # 模拟20个任务

    # 创建一个FIFO队列对象，不设置上限
    q = queue.Queue()
    # 创建一个线程池
    threads = []
    # 创建指定个数的工作线程，并讲他们放到线程池threads中
    for i in range(1, num_of_threads+1):
        t = threading.Thread(target=worker, args=(i,))
        threads.append(t)
        t.start()

    # 将任务源里的任务逐个放入队列
    for item in source:
        time.sleep(0.5)     # 每隔0.5秒发布一个新任务
        q.put(item)

    # 阻塞队列直到队列里的任务都完成了
    q.join()
    print("-----工作都完成了-----")
    # 停止工作线程
    for i in range(num_of_threads):
        q.put(None)
    for t in threads:
        t.join()
    print(threads)
```

注意，每次运行的结果可能都不一样：

```
线程1将任务<1>完成了！
线程3将任务<2>完成了！
线程3将任务<3>完成了！
线程5将任务<4>完成了！
线程5将任务<5>完成了！
线程4将任务<6>完成了！
线程3将任务<7>完成了！
线程3将任务<8>完成了！
线程5将任务<9>完成了！
线程1将任务<10>完成了！
线程1将任务<11>完成了！
线程1将任务<12>完成了！
线程3将任务<13>完成了！
线程5将任务<14>完成了！
线程1将任务<15>完成了！
线程1将任务<16>完成了！
线程1将任务<17>完成了！
线程3将任务<18>完成了！
线程5将任务<19>完成了！
线程5将任务<20>完成了！
-----工作都完成了-----
线程2发现了一个None,可以休息了^-^
线程1发现了一个None,可以休息了^-^
线程3发现了一个None,可以休息了^-^
线程5发现了一个None,可以休息了^-^
线程4发现了一个None,可以休息了^-^
[<Thread(Thread-1, stopped 7028)>, <Thread(Thread-2, stopped 6800)>, <Thread(Thread-3, stopped 5620)>, <Thread(Thread-4, stopped 6508)>, <Thread(Thread-5, stopped 4344)>]
```

PS：

Python提供了很多关于队列的类，其中：

`Class multiprocessing.Queue`是用于多进程的队列类（不要和多线程搞混了）

`collections.deque`则是一种可选择的队列替代方案，它提供了快速的原子级别的`append()`和`popleft()`方法，但是不提供锁的能力。