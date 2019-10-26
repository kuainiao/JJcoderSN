# bisect

**bisect模块实现了二分查找和插入算法**

这个模块短小精干，简单易用，并且可以用C重写。

我们可以看一下bisect模块的源码。

```
"""Bisection algorithms."""

def insort_right(a, x, lo=0, hi=None):

    if lo < 0:
        raise ValueError('lo must be non-negative')
    if hi is None:
        hi = len(a)
    while lo < hi:
        mid = (lo+hi)//2
        if x < a[mid]: hi = mid
        else: lo = mid+1
    a.insert(lo, x)

insort = insort_right   # backward compatibility

def bisect_right(a, x, lo=0, hi=None):

    if lo < 0:
        raise ValueError('lo must be non-negative')
    if hi is None:
        hi = len(a)
    while lo < hi:
        mid = (lo+hi)//2
        if x < a[mid]: hi = mid
        else: lo = mid+1
    return lo

bisect = bisect_right   # backward compatibility

def insort_left(a, x, lo=0, hi=None):

    if lo < 0:
        raise ValueError('lo must be non-negative')
    if hi is None:
        hi = len(a)
    while lo < hi:
        mid = (lo+hi)//2
        if a[mid] < x: lo = mid+1
        else: hi = mid
    a.insert(lo, x)


def bisect_left(a, x, lo=0, hi=None):

    if lo < 0:
        raise ValueError('lo must be non-negative')
    if hi is None:
        hi = len(a)
    while lo < hi:
        mid = (lo+hi)//2
        if a[mid] < x: lo = mid+1
        else: hi = mid
    return lo

# Overwrite above definitions with a fast C implementation
try:
    from _bisect import *
except ImportError:
    pass
```

这可能是Python初学者少有的能快速看懂的标准库源代码。整个模块去掉注释语句，就这么多行代码。

`bisect = bisect_right`这一行其实就是个alias，用于向后兼容。

最后的try、except语句为我们提供了用C语言重写算法的钩子。

### 方法介绍

bisect模块采用经典的二分算法查找元素。模块提供下面几个方法：

**bisect.bisect_left(a, x, lo=0, hi=len(a))**

定位x在序列a中的插入点，并保持原来的有序状态不变。参数lo和hi用于指定查找区间。如果x已经存在于a中，那么插入点在已存在元素的左边。函数的返回值是列表的整数下标。

**bisect.bisect_right(a, x, lo=0, hi=len(a))**

和上面的区别是插入点在右边。函数的返回值依然是一个列表下标整数。

**bisect.bisect(a, x, lo=0, hi=len(a))**

等同于bisect_right()。

注意，前面这三个方法都是获取插入位置，也就是列表的某个下标的，并不实际插入。但下面三个方法实际插入元素，没有返回值。

**bisect.insort_left(a, x, lo=0, hi=len(a))**

将x插入有序序列a内，并保持有序状态。相当于`a.insert(bisect.bisect_left(a, x, lo, hi), x)`。碰到相同的元素则插入到元素的左边。这个操作通常是 O(log n) 的时间复杂度。

**bisect.insort_right(a, x, lo=0, hi=len(a))**

同上，只不过碰到相同的元素则插入到元素的右边。

**bisect.insort(a, x, lo=0, hi=len(a))**

等同于insort_right()。

实例展示：

```
import bisect

x = 200
list1 = [1, 3, 6, 24, 55, 78, 454, 555, 1234, 6900]
ret = bisect.bisect(list1, x)
print("返回值： ", ret)
print("list1 = ", list1)

#------------------------------
运行结果：
返回值：  6
list1 =  [1, 3, 6, 24, 55, 78, 454, 555, 1234, 6900]

##########################################################
import bisect

x = 200
list1 = [1, 3, 6, 24, 55, 78, 454, 555, 1234, 6900]
ret = bisect.insort(list1, x)
print("返回值： ", ret)
print("list1 = ", list1)

#------------------------------------------
运行结果：
返回值：  None
list1 =  [1, 3, 6, 24, 55, 78, 200, 454, 555, 1234, 6900]
```

下面是一个bisect和random配合的例子：

```
import bisect
import random

random.seed(1)

print('New  Pos Contents')
print('---  --- --------')

l = []
for i in range(1, 15):
    r = random.randint(1, 100)
    position = bisect.bisect(l, r)
    bisect.insort(l, r)
    print('%3d  %3d' % (r, position), l)

#------------------------------------------
打印结果：
New  Pos Contents
---  --- --------
 18    0 [18]
 73    1 [18, 73]
 98    2 [18, 73, 98]
  9    0 [9, 18, 73, 98]
 33    2 [9, 18, 33, 73, 98]
 16    1 [9, 16, 18, 33, 73, 98]
 64    4 [9, 16, 18, 33, 64, 73, 98]
 98    7 [9, 16, 18, 33, 64, 73, 98, 98]
 58    4 [9, 16, 18, 33, 58, 64, 73, 98, 98]
 61    5 [9, 16, 18, 33, 58, 61, 64, 73, 98, 98]
 84    8 [9, 16, 18, 33, 58, 61, 64, 73, 84, 98, 98]
 49    4 [9, 16, 18, 33, 49, 58, 61, 64, 73, 84, 98, 98]
 27    3 [9, 16, 18, 27, 33, 49, 58, 61, 64, 73, 84, 98, 98]
 13    1 [9, 13, 16, 18, 27, 33, 49, 58, 61, 64, 73, 84, 98, 98]
```

下面的5个例子是利用bisect模块实现通用的列表元素查询方法：

```
def index(a, x):
    '定位最左边的值等于x的元素的下标'
    i = bisect_left(a, x)
    if i != len(a) and a[i] == x:
        return i
    raise ValueError

def find_lt(a, x):
    '获取最靠右的值小于x的元素'
    i = bisect_left(a, x)
    if i:
        return a[i-1]
    raise ValueError

def find_le(a, x):
    '获取最靠右的值小于等于x的元素'
    i = bisect_right(a, x)
    if i:
        return a[i-1]
    raise ValueError

def find_gt(a, x):
    '获取最靠左边的值大于x的元素'
    i = bisect_right(a, x)
    if i != len(a):
        return a[i]
    raise ValueError

def find_ge(a, x):
    '获取最靠左边的值大于或等于x的元素'
    i = bisect_left(a, x)
    if i != len(a):
        return a[i]
    raise ValueError
```

下面是一个利用bisect自动由百分制成绩转换为ABCD等级的方法：90 以上是‘A’, 80 -89 是‘B’,

```
>>> def grade(score, breakpoints=[60, 70, 80, 90], grades='FDCBA'):
...     i = bisect(breakpoints, score)
...     return grades[i]
...
>>> [grade(score) for score in [33, 99, 77, 70, 89, 90, 100]]
['F', 'A', 'C', 'C', 'B', 'A', 'A']
```

另外一个例子

```
>>> data = [('red', 5), ('blue', 1), ('yellow', 8), ('black', 0)]
>>> data.sort(key=lambda r: r[1])
>>> keys = [r[1] for r in data]         # precomputed list of keys
>>> data[bisect_left(keys, 0)]
('black', 0)
>>> data[bisect_left(keys, 1)]
('blue', 1)
>>> data[bisect_left(keys, 5)]
('red', 5)
>>> data[bisect_left(keys, 8)]
('yellow', 8)
```