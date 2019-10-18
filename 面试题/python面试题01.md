# Python 面试题01

------



# [#](http://www.liuwq.com/views/面试题/python_01.html#python基础)Python基础

## [#](http://www.liuwq.com/views/面试题/python_01.html#文件操作)文件操作

### [#](http://www.liuwq.com/views/面试题/python_01.html#_1-有一个jsonline格式的文件file-txt大小约为10k)1.有一个jsonline格式的文件file.txt大小约为10K

```python
def get_lines():
    with open('file.txt','rb') as f:
        return f.readlines()

if __name__ == '__main__':
    for e in get_lines():
        process(e) # 处理每一行数据
```

现在要处理一个大小为10G的文件，但是内存只有4G，如果在只修改get_lines 函数而其他代码保持不变的情况下，应该如何实现？需要考虑的问题都有那些？

```python
def get_lines():
    with open('file.txt','rb') as f:
        for i in f:
            yield i
```

Pandaaaa906提供的方法

```python
from mmap import mmap


def get_lines(fp):
    with open(fp,"r+") as f:
        m = mmap(f.fileno(), 0)
        tmp = 0
        for i, char in enumerate(m):
            if char==b"\n":
                yield m[tmp:i+1].decode()
                tmp = i+1

if __name__=="__main__":
    for i in get_lines("fp_some_huge_file"):
        print(i
```

要考虑的问题有：内存只有4G无法一次性读入10G文件，需要分批读入分批读入数据要记录每次读入数据的位置。分批每次读取数据的大小，太小会在读取操作花费过多时间。 https://stackoverflow.com/questions/30294146/python-fastest-way-to-process-large-file

### [#](http://www.liuwq.com/views/面试题/python_01.html#_2-补充缺失的代码)2.补充缺失的代码

```python
def print_directory_contents(sPath):
"""
这个函数接收文件夹的名称作为输入参数
返回该文件夹中文件的路径
以及其包含文件夹中文件的路径
"""
import os
for s_child in os.listdir(s_path):
    s_child_path = os.path.join(s_path, s_child)
    if os.path.isdir(s_child_path):
        print_directory_contents(s_child_path)
    else:
        print(s_child_path)
```

## [#](http://www.liuwq.com/views/面试题/python_01.html#模块与包)模块与包

### [#](http://www.liuwq.com/views/面试题/python_01.html#_3-输入日期，-判断这一天是这一年的第几天？)3.输入日期， 判断这一天是这一年的第几天？

```python
import datetime
def dayofyear():
    year = input("请输入年份: ")
    month = input("请输入月份: ")
    day = input("请输入天: ")
    date1 = datetime.date(year=int(year),month=int(month),day=int(day))
    date2 = datetime.date(year=int(year),month=1,day=1)
    return (date1-date2).days+1
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_4-打乱一个排好序的list对象alist？)4.打乱一个排好序的list对象alist？

```python
import random
alist = [1,2,3,4,5]
random.shuffle(alist)
print(alist)
```

## [#](http://www.liuwq.com/views/面试题/python_01.html#数据类型)数据类型

### [#](http://www.liuwq.com/views/面试题/python_01.html#_5-现有字典-d-a-24-g-52-i-12-k-33-请按value值进行排序)5.现有字典 d= {'a':24,'g':52,'i':12,'k':33}请按value值进行排序?

```python
sorted(d.items(),key=lambda x:x[1])
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_6-字典推导式)6.字典推导式

```python
d = {key:value for (key,value) in iterable}
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_7-请反转字符串-astr)7.请反转字符串 "aStr"?

```python
print("aStr"[::-1])
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_8-将字符串-k-1-k1-2-k2-3-k3-4-，处理成字典-k-1-k1-2)8.将字符串 "k:1 |k1:2|k2:3|k3:4"，处理成字典 {k:1,k1:2,...}

```python
str1 = "k:1|k1:2|k2:3|k3:4"
def str2dict(str1):
    dict1 = {}
    for iterms in str1.split('|'):
        key,value = iterms.split(':')
        dict1[key] = value
    return dict1
#字典推导式
d = {k:int(v) for t in str1.split("|") for k, v in (t.split(":"), )}
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_9-请按alist中元素的age由大到小排序)9.请按alist中元素的age由大到小排序

```python
alist = [{'name':'a','age':20},{'name':'b','age':30},{'name':'c','age':25}]
def sort_by_age(list1):
    return sorted(alist,key=lambda x:x['age'],reverse=True)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_10-下面代码的输出结果将是什么？)10.下面代码的输出结果将是什么？

```python
list = ['a','b','c','d','e']
print(list[10:])
```

代码将输出[],不会产生IndexError错误，就像所期望的那样，尝试用超出成员的个数的index来获取某个列表的成员。例如，尝试获取list[10]和之后的成员，会导致IndexError。然而，尝试获取列表的切片，开始的index超过了成员个数不会产生IndexError，而是仅仅返回一个空列表。这成为特别让人恶心的疑难杂症，因为运行的时候没有错误产生，导致Bug很难被追踪到。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_11-写一个列表生成式，产生一个公差为11的等差数列)11.写一个列表生成式，产生一个公差为11的等差数列

```python
print([x*11 for x in range(10)])
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_12-给定两个列表，怎么找出他们相同的元素和不同的元素？)12.给定两个列表，怎么找出他们相同的元素和不同的元素？

```python
list1 = [1,2,3]
list2 = [3,4,5]
set1 = set(list1)
set2 = set(list2)
print(set1 & set2)
print(set1 ^ set2)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_13-请写出一段python代码实现删除list里面的重复元素？)13.请写出一段python代码实现删除list里面的重复元素？

```python
l1 = ['b','c','d','c','a','a']
l2 = list(set(l1))
print(l2)
```

用list类的sort方法:

```python
l1 = ['b','c','d','c','a','a']
l2 = list(set(l1))
l2.sort(key=l1.index)
print(l2)
```

也可以这样写:

```python
l1 = ['b','c','d','c','a','a']
l2 = sorted(set(l1),key=l1.index)
print(l2)
```

也可以用遍历：

```python
l1 = ['b','c','d','c','a','a']
l2 = []
for i in l1:
    if not i in l2:
        l2.append(i)
print(l2)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_14-给定两个list-a，b-请用找出a，b中相同与不同的元素)14.给定两个list A，B ,请用找出A，B中相同与不同的元素

```python
A,B 中相同元素： print(set(A)&set(B))
A,B 中不同元素:  print(set(A)^set(B))
```

## [#](http://www.liuwq.com/views/面试题/python_01.html#企业面试题)企业面试题

### [#](http://www.liuwq.com/views/面试题/python_01.html#_15-python新式类和经典类的区别？)15.python新式类和经典类的区别？

a. 在python里凡是继承了object的类，都是新式类

b. Python3里只有新式类

c. Python2里面继承object的是新式类，没有写父类的是经典类

d. 经典类目前在Python里基本没有应用

### [#](http://www.liuwq.com/views/面试题/python_01.html#_16-python中内置的数据结构有几种？)16.python中内置的数据结构有几种？

a. 整型 int、 长整型 long、浮点型 float、 复数 complex

b. 字符串 str、 列表 list、 元祖 tuple

c. 字典 dict 、 集合 set

d. Python3 中没有 long，只有无限精度的 int

### [#](http://www.liuwq.com/views/面试题/python_01.html#_17-python如何实现单例模式-请写出两种实现方式)17.python如何实现单例模式?请写出两种实现方式?

第一种方法:使用装饰器

```python
def singleton(cls):
    instances = {}
    def wrapper(*args, **kwargs):
        if cls not in instances:
            instances[cls] = cls(*args, **kwargs)
        return instances[cls]
    return wrapper
    
    
@singleton
class Foo(object):
    pass
foo1 = Foo()
foo2 = Foo()
print(foo1 is foo2)  # True
```

第二种方法：使用基类 New 是真正创建实例对象的方法，所以重写基类的new 方法，以此保证创建对象的时候只生成一个实例

```python
class Singleton(object):
    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, '_instance'):
            cls._instance = super(Singleton, cls).__new__(cls, *args, **kwargs)
        return cls._instance
    
    
class Foo(Singleton):
    pass

foo1 = Foo()
foo2 = Foo()

print(foo1 is foo2)  # True
```

第三种方法：元类，元类是用于创建类对象的类，类对象创建实例对象时一定要调用call方法，因此在调用call时候保证始终只创建一个实例即可，type是python的元类

```python
class Singleton(type):
    def __call__(cls, *args, **kwargs):
        if not hasattr(cls, '_instance'):
            cls._instance = super(Singleton, cls).__call__(*args, **kwargs)
        return cls._instance


# Python2
class Foo(object):
    __metaclass__ = Singleton

# Python3
class Foo(metaclass=Singleton):
    pass

foo1 = Foo()
foo2 = Foo()
print(foo1 is foo2)  # True
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_18-反转一个整数，例如-123-321)18.反转一个整数，例如-123 --> -321

```python
class Solution(object):
    def reverse(self,x):
        if -10<x<10:
            return x
        str_x = str(x)
        if str_x[0] !="-":
            str_x = str_x[::-1]
            x = int(str_x)
        else:
            str_x = str_x[1:][::-1]
            x = int(str_x)
            x = -x
        return x if -2147483648<x<2147483647 else 0
if __name__ == '__main__':
    s = Solution()
    reverse_int = s.reverse(-120)
    print(reverse_int)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_19-设计实现遍历目录与子目录，抓取-pyc文件)19.设计实现遍历目录与子目录，抓取.pyc文件

第一种方法：

```python
import os

def get_files(dir,suffix):
    res = []
    for root,dirs,files in os.walk(dir):
        for filename in files:
            name,suf = os.path.splitext(filename)
            if suf == suffix:
                res.append(os.path.join(root,filename))

    print(res)

get_files("./",'.pyc')
```

第二种方法：

```python
import os

def pick(obj):
    if ob.endswith(".pyc"):
        print(obj)
    
def scan_path(ph):
    file_list = os.listdir(ph)
    for obj in file_list:
        if os.path.isfile(obj):
    pick(obj)
        elif os.path.isdir(obj):
            scan_path(obj)
    
if __name__=='__main__':
    path = input('输入目录')
    scan_path(path)
```

第三种方法

```python
from glob import iglob


def func(fp, postfix):
    for i in iglob(f"{fp}/**/*{postfix}", recursive=True):
        print(i)

if __name__ == "__main__":
    postfix = ".pyc"
    func("K:\Python_script", postfix)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_20-一行代码实现1-100之和)20.一行代码实现1-100之和

```python
count = sum(range(0,101))
print(count)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_21-python-遍历列表时删除元素的正确做法)21.Python-遍历列表时删除元素的正确做法

遍历在新在列表操作，删除时在原来的列表操作

```python
a = [1,2,3,4,5,6,7,8]
print(id(a))
print(id(a[:]))
for i in a[:]:
    if i>5:
        pass
    else:
        a.remove(i)
    print(a)
print('-----------')
print(id(a))
```

```python
#filter
a=[1,2,3,4,5,6,7,8]
b = filter(lambda x: x>5,a)
print(list(b))
```

列表解析

```python
a=[1,2,3,4,5,6,7,8]
b = [i for i in a if i>5]
print(b)
```

倒序删除 因为列表总是‘向前移’，所以可以倒序遍历，即使后面的元素被修改了，还没有被遍历的元素和其坐标还是保持不变的

```python
a=[1,2,3,4,5,6,7,8]
print(id(a))
for i in range(len(a)-1,-1,-1):
    if a[i]>5:
        pass
    else:
        a.remove(a[i])
print(id(a))
print('-----------')
print(a)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_22-字符串的操作题目)22.字符串的操作题目

全字母短句 PANGRAM 是包含所有英文字母的句子，比如：A QUICK BROWN FOX JUMPS OVER THE LAZY DOG. 定义并实现一个方法 get_missing_letter, 传入一个字符串采纳数，返回参数字符串变成一个 PANGRAM 中所缺失的字符。应该忽略传入字符串参数中的大小写，返回应该都是小写字符并按字母顺序排序（请忽略所有非 ACSII 字符）

**下面示例是用来解释，双引号不需要考虑:**

(0)输入: "A quick brown for jumps over the lazy dog"

返回： ""

(1)输入: "A slow yellow fox crawls under the proactive dog"

返回: "bjkmqz"

(2)输入: "Lions, and tigers, and bears, oh my!"

返回: "cfjkpquvwxz"

(3)输入: ""

返回："abcdefghijklmnopqrstuvwxyz"

```python
def get_missing_letter(a):
    s1 = set("abcdefghijklmnopqrstuvwxyz")
    s2 = set(a.lower())
    ret = "".join(sorted(s1-s2))
    return ret
    
print(get_missing_letter("python"))

# other ways to generate letters
# range("a", "z")
# 方法一:
import string
letters = string.ascii_lowercase
# 方法二:
letters = "".join(map(chr, range(ord('a'), ord('z') + 1)))
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_23-可变类型和不可变类型)23.可变类型和不可变类型

1,可变类型有list,dict.不可变类型有string，number,tuple.

2,当进行修改操作时，可变类型传递的是内存中的地址，也就是说，直接修改内存中的值，并没有开辟新的内存。

3,不可变类型被改变时，并没有改变原内存地址中的值，而是开辟一块新的内存，将原地址中的值复制过去，对这块新开辟的内存中的值进行操作。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_24-is和-有什么区别？)24.is和==有什么区别？

is：比较的是两个对象的id值是否相等，也就是比较俩对象是否为同一个实例对象。是否指向同一个内存地址

== ： 比较的两个对象的内容/值是否相等，默认会调用对象的eq()方法

### [#](http://www.liuwq.com/views/面试题/python_01.html#_25-求出列表所有奇数并构造新列表)25.求出列表所有奇数并构造新列表

```python
a = [1,2,3,4,5,6,7,8,9,10]
res = [ i for i in a if i%2==1]
print(res)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_26-用一行python代码写出1-2-3-10248)26.用一行python代码写出1+2+3+10248

```python
from functools import reduce
#1.使用sum内置求和函数
num = sum([1,2,3,10248])
print(num)
#2.reduce 函数
num1 = reduce(lambda x,y :x+y,[1,2,3,10248])
print(num1)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_27-python中变量的作用域？（变量查找顺序)27.Python中变量的作用域？（变量查找顺序)

函数作用域的LEGB顺序

1.什么是LEGB?

L： local 函数内部作用域

E: enclosing 函数内部与内嵌函数之间

G: global 全局作用域

B： build-in 内置作用

python在函数里面的查找分为4种，称之为LEGB，也正是按照这是顺序来查找的

### [#](http://www.liuwq.com/views/面试题/python_01.html#_28-字符串-123-转换成-123，不使用内置api，例如-int)28.字符串 `"123"` 转换成 `123`，不使用内置api，例如 `int()`

方法一： 利用 `str` 函数

```python
def atoi(s):
    num = 0
    for v in s:
        for j in range(10):
            if v == str(j):
                num = num * 10 + j
    return num
```

方法二： 利用 `ord` 函数

```python
def atoi(s):
    num = 0
    for v in s:
        num = num * 10 + ord(v) - ord('0')
    return num
```

方法三: 利用 `eval` 函数

```python
def atoi(s):
    num = 0
    for v in s:
        t = "%s * 1" % v
        n = eval(t)
        num = num * 10 + n
    return num
```

方法四: 结合方法二，使用 `reduce`，一行解决

```python
from functools import reduce
def atoi(s):
    return reduce(lambda num, v: num * 10 + ord(v) - ord('0'), s, 0)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_29-given-an-array-of-integers)29.Given an array of integers

给定一个整数数组和一个目标值，找出数组中和为目标值的两个数。你可以假设每个输入只对应一种答案，且同样的元素不能被重复利用。示例:给定nums = [2,7,11,15],target=9 因为 nums[0]+nums[1] = 2+7 =9,所以返回[0,1]

```python
class Solution:
    def twoSum(self,nums,target):
        """
        :type nums: List[int]
        :type target: int
        :rtype: List[int]
        """
        d = {}
        size = 0
        while size < len(nums):
            if target-nums[size] in d:
                if d[target-nums[size]] <size:
                    return [d[target-nums[size]],size]
                else:
                    d[nums[size]] = size
                size = size +1
solution = Solution()
list = [2,7,11,15]
target = 9
nums = solution.twoSum(list,target)
print(nums)
```

给列表中的字典排序：假设有如下list对象，alist=[{"name":"a","age":20},{"name":"b","age":30},{"name":"c","age":25}],将alist中的元素按照age从大到小排序 alist=[{"name":"a","age":20},{"name":"b","age":30},{"name":"c","age":25}]

```python
alist_sort = sorted(alist,key=lambda e: e.__getitem__('age'),reverse=True)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_30-python代码实现删除一个list里面的重复元素)30.python代码实现删除一个list里面的重复元素

```python
def distFunc1(a):
    """使用集合去重"""
    a = list(set(a))
    print(a)

def distFunc2(a):
    """将一个列表的数据取出放到另一个列表中，中间作判断"""
    list = []
    for i in a:
        if i not in list:
            list.append(i)
    #如果需要排序的话用sort
    list.sort()
    print(list)

def distFunc3(a):
    """使用字典"""
    b = {}
    b = b.fromkeys(a)
    c = list(b.keys())
    print(c)

if __name__ == "__main__":
    a = [1,2,4,2,4,5,7,10,5,5,7,8,9,0,3]
    distFunc1(a)
    distFunc2(a)
    distFunc3(a)
  
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_31-统计一个文本中单词频次最高的10个单词？)31.统计一个文本中单词频次最高的10个单词？

```python
import re

# 方法一
def test(filepath):
    
    distone = {}

    with open(filepath) as f:
        for line in f:
            line = re.sub("\W+", " ", line)
            lineone = line.split()
            for keyone in lineone:
                if not distone.get(keyone):
                    distone[keyone] = 1
                else:
                    distone[keyone] += 1
    num_ten = sorted(distone.items(), key=lambda x:x[1], reverse=True)[:10]
    num_ten =[x[0] for x in num_ten]
    return num_ten
    
 
# 方法二 
# 使用 built-in 的 Counter 里面的 most_common
import re
from collections import Counter


def test2(filepath):
    with open(filepath) as f:
        return list(map(lambda c: c[0], Counter(re.sub("\W+", " ", f.read()).split()).most_common(10)))
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_32-请写出一个函数满足以下条件)32.请写出一个函数满足以下条件

该函数的输入是一个仅包含数字的list,输出一个新的list，其中每一个元素要满足以下条件：

1、该元素是偶数

2、该元素在原list中是在偶数的位置(index是偶数)

```python
def num_list(num):
    return [i for i in num if i %2 ==0 and num.index(i)%2==0]

num = [0,1,2,3,4,5,6,7,8,9,10]
result = num_list(num)
print(result)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_33-使用单一的列表生成式来产生一个新的列表)33.使用单一的列表生成式来产生一个新的列表

该列表只包含满足以下条件的值，元素为原始列表中偶数切片

```python
list_data = [1,2,5,8,10,3,18,6,20]
res = [x for x in list_data[::2] if x %2 ==0]
print(res)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_34-用一行代码生成-1-4-9-16-25-36-49-64-81-100)34.用一行代码生成[1,4,9,16,25,36,49,64,81,100]

```python
[x * x for x in range(1,11)]
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_35-输入某年某月某日，判断这一天是这一年的第几天？)35.输入某年某月某日，判断这一天是这一年的第几天？

```python
import datetime

y = int(input("请输入4位数字的年份:"))
m = int(input("请输入月份:"))
d = int(input("请输入是哪一天"))

targetDay = datetime.date(y,m,d)
dayCount = targetDay - datetime.date(targetDay.year -1,12,31)
print("%s是 %s年的第%s天。"%(targetDay,y,dayCount.days))
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_36-两个有序列表，l1-l2，对这两个列表进行合并不可使用extend)36.两个有序列表，l1,l2，对这两个列表进行合并不可使用extend

```python
def loop_merge_sort(l1,l2):
    tmp = []
    while len(l1)>0 and len(l2)>0:
        if l1[0] <l2[0]:
            tmp.append(l1[0])
            del l1[0]
        else:
            tmp.append(l2[0])
            del l2[0]
    while len(l1)>0:
        tmp.append(l1[0])
        del l1[0]
    while len(l2)>0:
        tmp.append(l2[0])
        del l2[0]
    return tmp
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_37-给定一个任意长度数组，实现一个函数)37.给定一个任意长度数组，实现一个函数

让所有奇数都在偶数前面，而且奇数升序排列，偶数降序排序，如字符串'1982376455',变成'1355798642'

```python
# 方法一
def func1(l):
    if isinstance(l, str):
        l = [int(i) for i in l]
    l.sort(reverse=True)
    for i in range(len(l)):
        if l[i] % 2 > 0:
            l.insert(0, l.pop(i))
    print(''.join(str(e) for e in l))

# 方法二
def func2(l):
    print("".join(sorted(l, key=lambda x: int(x) % 2 == 0 and 20 - int(x) or int(x))))
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_38-写一个函数找出一个整数数组中，第二大的数)38.写一个函数找出一个整数数组中，第二大的数

```python
def find_second_large_num(num_list):
    """
    找出数组第2大的数字
    """
    # 方法一
    # 直接排序，输出倒数第二个数即可
    tmp_list = sorted(num_list)
    print("方法一\nSecond_large_num is :", tmp_list[-2])
    
    # 方法二
    # 设置两个标志位一个存储最大数一个存储次大数
    # two 存储次大值，one 存储最大值，遍历一次数组即可，先判断是否大于 one，若大于将 one 的值给 two，将 num_list[i] 的值给 one，否则比较是否大于two，若大于直接将 num_list[i] 的值给two，否则pass
    one = num_list[0]
    two = num_list[0]
    for i in range(1, len(num_list)):
        if num_list[i] > one:
            two = one
            one = num_list[i]
        elif num_list[i] > two:
            two = num_list[i]
    print("方法二\nSecond_large_num is :", two)
    
    # 方法三
    # 用 reduce 与逻辑符号 (and, or)
    # 基本思路与方法二一样，但是不需要用 if 进行判断。
    from functools import reduce
    num = reduce(lambda ot, x: ot[1] < x and (ot[1], x) or ot[0] < x and (x, ot[1]) or ot, num_list, (0, 0))[0]
    print("方法三\nSecond_large_num is :", num)
    
    
if __name__ == '__main___':
    num_list = [34, 11, 23, 56, 78, 0, 9, 12, 3, 7, 5]
    find_second_large_num(num_list)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_39-阅读一下代码他们的输出结果是什么？)39.阅读一下代码他们的输出结果是什么？

```python
def multi():
    return [lambda x : i*x for i in range(4)]
print([m(3) for m in multi()])
```

正确答案是[9,9,9,9]，而不是[0,3,6,9]产生的原因是Python的闭包的后期绑定导致的，这意味着在闭包中的变量是在内部函数被调用的时候被查找的，因为，最后函数被调用的时候，for循环已经完成, i 的值最后是3,因此每一个返回值的i都是3,所以最后的结果是[9,9,9,9]

### [#](http://www.liuwq.com/views/面试题/python_01.html#_40-统计一段字符串中字符出现的次数)40.统计一段字符串中字符出现的次数

```python
# 方法一
def count_str(str_data):
    """定义一个字符出现次数的函数"""
    dict_str = {} 
    for i in str_data:
        dict_str[i] = dict_str.get(i, 0) + 1
    return dict_str
dict_str = count_str("AAABBCCAC")
str_count_data = ""
for k, v in dict_str.items():
    str_count_data += k + str(v)
print(str_count_data)

# 方法二
from collections import Counter

print("".join(map(lambda x: x[0] + str(x[1]), Counter("AAABBCCAC").most_common())))
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_41-super函数的具体用法和场景)41.super函数的具体用法和场景

https://python3-cookbook.readthedocs.io/zh_CN/latest/c08/p07_calling_method_on_parent_class.html

# [#](http://www.liuwq.com/views/面试题/python_01.html#python高级)Python高级

## [#](http://www.liuwq.com/views/面试题/python_01.html#元类)元类

### [#](http://www.liuwq.com/views/面试题/python_01.html#_42-python中类方法、类实例方法、静态方法有何区别？)42.Python中类方法、类实例方法、静态方法有何区别？

类方法: 是类对象的方法，在定义时需要在上方使用 @classmethod 进行装饰,形参为cls，表示类对象，类对象和实例对象都可调用

类实例方法: 是类实例化对象的方法,只有实例对象可以调用，形参为self,指代对象本身;

静态方法: 是一个任意函数，在其上方使用 @staticmethod 进行装饰，可以用对象直接调用，静态方法实际上跟该类没有太大关系

### [#](http://www.liuwq.com/views/面试题/python_01.html#_43-遍历一个object的所有属性，并print每一个属性名？)43.遍历一个object的所有属性，并print每一个属性名？

```python
class Car:
    def __init__(self,name,loss): # loss [价格，油耗，公里数]
        self.name = name
        self.loss = loss
    
    def getName(self):
        return self.name
    
    def getPrice(self):
        # 获取汽车价格
        return self.loss[0]
    
    def getLoss(self):
        # 获取汽车损耗值
        return self.loss[1] * self.loss[2]

Bmw = Car("宝马",[60,9,500]) # 实例化一个宝马车对象
print(getattr(Bmw,"name")) # 使用getattr()传入对象名字,属性值。
print(dir(Bmw)) # 获Bmw所有的属性和方法
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_44-写一个类，并让它尽可能多的支持操作符)44.写一个类，并让它尽可能多的支持操作符?

```python
class Array:
    __list = []
    
    def __init__(self):
        print "constructor"
    
    def __del__(self):
        print "destruct"
    
    def __str__(self):
        return "this self-defined array class"

    def __getitem__(self,key):
        return self.__list[key]
    
    def __len__(self):
        return len(self.__list)

    def Add(self,value):
        self.__list.append(value)
    
    def Remove(self,index):
        del self.__list[index]
    
    def DisplayItems(self):
        print "show all items---"
        for item in self.__list:
            print item
    
        
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_45-介绍cython，pypy-cpython-numba各有什么缺点)45.介绍Cython，Pypy Cpython Numba各有什么缺点

Cython

### [#](http://www.liuwq.com/views/面试题/python_01.html#_46-请描述抽象类和接口类的区别和联系)46.请描述抽象类和接口类的区别和联系

1.抽象类： 规定了一系列的方法，并规定了必须由继承类实现的方法。由于有抽象方法的存在，所以抽象类不能实例化。可以将抽象类理解为毛坯房，门窗，墙面的样式由你自己来定，所以抽象类与作为基类的普通类的区别在于约束性更强

2.接口类：与抽象类很相似，表现在接口中定义的方法，必须由引用类实现，但他与抽象类的根本区别在于用途：与不同个体间沟通的规则，你要进宿舍需要有钥匙，这个钥匙就是你与宿舍的接口，你的舍友也有这个接口，所以他也能进入宿舍，你用手机通话，那么手机就是你与他人交流的接口

3.区别和关联：

1.接口是抽象类的变体，接口中所有的方法都是抽象的，而抽象类中可以有非抽象方法，抽象类是声明方法的存在而不去实现它的类

2.接口可以继承，抽象类不行

3.接口定义方法，没有实现的代码，而抽象类可以实现部分方法

4.接口中基本数据类型为static而抽象类不是

### [#](http://www.liuwq.com/views/面试题/python_01.html#_47-python中如何动态获取和设置对象的属性？)47.Python中如何动态获取和设置对象的属性？

```python
if hasattr(Parent, 'x'):
    print(getattr(Parent, 'x'))
    setattr(Parent, 'x',3)
print(getattr(Parent,'x'))
```

## [#](http://www.liuwq.com/views/面试题/python_01.html#内存管理与垃圾回收机制)内存管理与垃圾回收机制

### [#](http://www.liuwq.com/views/面试题/python_01.html#_48-哪些操作会导致python内存溢出，怎么处理？)48.哪些操作会导致Python内存溢出，怎么处理？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_49-关于python内存管理-下列说法错误的是-b)49.关于Python内存管理,下列说法错误的是 B

A,变量不必事先声明 B,变量无须先创建和赋值而直接使用

C,变量无须指定类型 D,可以使用del释放资源

### [#](http://www.liuwq.com/views/面试题/python_01.html#_50-python的内存管理机制及调优手段？)50.Python的内存管理机制及调优手段？

内存管理机制: 引用计数、垃圾回收、内存池

引用计数：引用计数是一种非常高效的内存管理手段，当一个Python对象被引用时其引用计数增加1,

当其不再被一个变量引用时则计数减1,当引用计数等于0时对象被删除。弱引用不会增加引用计数

垃圾回收：

1.引用计数

引用计数也是一种垃圾收集机制，而且也是一种最直观、最简单的垃圾收集技术。当Python的某个对象的引用计数降为0时，说明没有任何引用指向该对象，该对象就成为要被回收的垃圾了。比如某个新建对象，它被分配给某个引用，对象的引用计数变为1，如果引用被删除，对象的引用计数为0,那么该对象就可以被垃圾回收。不过如果出现循环引用的话，引用计数机制就不再起有效的作用了。

2.标记清除

https://foofish.net/python-gc.html

调优手段

1.手动垃圾回收

2.调高垃圾回收阈值

3.避免循环引用

### [#](http://www.liuwq.com/views/面试题/python_01.html#_51-内存泄露是什么？如何避免？)51.内存泄露是什么？如何避免？

**内存泄漏**指由于疏忽或错误造成程序未能释放已经不再使用的内存。内存泄漏并非指内存在物理上的消失，而是应用程序分配某段内存后，由于设计错误，导致在释放该段内存之前就失去了对该段内存的控制，从而造成了内存的浪费。

有`__del__()`函数的对象间的循环引用是导致内存泄露的主凶。不使用一个对象时使用: del object 来删除一个对象的引用计数就可以有效防止内存泄露问题。

通过Python扩展模块gc 来查看不能回收的对象的详细信息。

可以通过 sys.getrefcount(obj) 来获取对象的引用计数，并根据返回值是否为0来判断是否内存泄露

## [#](http://www.liuwq.com/views/面试题/python_01.html#函数)函数

### [#](http://www.liuwq.com/views/面试题/python_01.html#_52-python常见的列表推导式？)52.python常见的列表推导式？

[表达式 for 变量 in 列表] 或者 [表达式 for 变量 in 列表 if 条件]

### [#](http://www.liuwq.com/views/面试题/python_01.html#_53-简述read、readline、readlines的区别？)53.简述read、readline、readlines的区别？

read 读取整个文件

readline 读取下一行

readlines 读取整个文件到一个迭代器以供我们遍历

### [#](http://www.liuwq.com/views/面试题/python_01.html#_54-什么是hash（散列函数）？)54.什么是Hash（散列函数）？

**散列函数**（英语：Hash function）又称**散列算法**、**哈希函数**，是一种从任何一种数据中创建小的数字“指纹”的方法。散列函数把消息或数据压缩成摘要，使得数据量变小，将数据的格式固定下来。该函数将数据打乱混合，重新创建一个叫做**散列值**（hash values，hash codes，hash sums，或hashes）的指纹。散列值通常用一个短的随机字母和数字组成的字符串来代表

### [#](http://www.liuwq.com/views/面试题/python_01.html#_55-python函数重载机制？)55.python函数重载机制？

函数重载主要是为了解决两个问题。 1。可变参数类型。 2。可变参数个数。

另外，一个基本的设计原则是，仅仅当两个函数除了参数类型和参数个数不同以外，其功能是完全相同的，此时才使用函数重载，如果两个函数的功能其实不同，那么不应当使用重载，而应当使用一个名字不同的函数。

好吧，那么对于情况 1 ，函数功能相同，但是参数类型不同，python 如何处理？答案是根本不需要处理，因为 python 可以接受任何类型的参数，如果函数的功能相同，那么不同的参数类型在 python 中很可能是相同的代码，没有必要做成两个不同函数。

那么对于情况 2 ，函数功能相同，但参数个数不同，python 如何处理？大家知道，答案就是缺省参数。对那些缺少的参数设定为缺省参数即可解决问题。因为你假设函数功能相同，那么那些缺少的参数终归是需要用的。

好了，鉴于情况 1 跟 情况 2 都有了解决方案，python 自然就不需要函数重载了。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_56-写一个函数找出一个整数数组中，第二大的数)56.写一个函数找出一个整数数组中，第二大的数

### [#](http://www.liuwq.com/views/面试题/python_01.html#_57-手写一个判断时间的装饰器)57.手写一个判断时间的装饰器

```python
import datetime


class TimeException(Exception):
    def __init__(self, exception_info):
        super().__init__()
        self.info = exception_info

    def __str__(self):
        return self.info


def timecheck(func):
    def wrapper(*args, **kwargs):
        if datetime.datetime.now().year == 2019:
            func(*args, **kwargs)
        else:
            raise TimeException("函数已过时")

    return wrapper


@timecheck
def test(name):
    print("Hello {}, 2019 Happy".format(name))


if __name__ == "__main__":
    test("backbp")
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_58-使用python内置的filter-方法来过滤？)58.使用Python内置的filter()方法来过滤？

```python
list(filter(lambda x: x % 2 == 0, range(10)))
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_59-编写函数的4个原则)59.编写函数的4个原则

1.函数设计要尽量短小

2.函数声明要做到合理、简单、易于使用

3.函数参数设计应该考虑向下兼容

4.一个函数只做一件事情，尽量保证函数语句粒度的一致性

### [#](http://www.liuwq.com/views/面试题/python_01.html#_60-函数调用参数的传递方式是值传递还是引用传递？)60.函数调用参数的传递方式是值传递还是引用传递？

Python的参数传递有：位置参数、默认参数、可变参数、关键字参数。

函数的传值到底是值传递还是引用传递、要分情况：

不可变参数用值传递：像整数和字符串这样的不可变对象，是通过拷贝进行传递的，因为你无论如何都不可能在原处改变不可变对象。

可变参数是引用传递：比如像列表，字典这样的对象是通过引用传递、和C语言里面的用指针传递数组很相似，可变对象能在函数内部改变。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_61-如何在function里面设置一个全局变量)61.如何在function里面设置一个全局变量

```python
globals() # 返回包含当前作用余全局变量的字典。
global 变量 设置使用全局变量
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_62-对缺省参数的理解-？)62.对缺省参数的理解 ？

缺省参数指在调用函数的时候没有传入参数的情况下，调用默认的参数，在调用函数的同时赋值时，所传入的参数会替代默认参数。

*args是不定长参数，它可以表示输入参数是不确定的，可以是任意多个。

**kwargs是关键字参数，赋值的时候是以键值对的方式，参数可以是任意多对在定义函数的时候

不确定会有多少参数会传入时，就可以使用两个参数

### [#](http://www.liuwq.com/views/面试题/python_01.html#_63-mysql怎么限制ip访问？)63.Mysql怎么限制IP访问？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_64-带参数的装饰器)64.带参数的装饰器?

带定长参数的装饰器

```python
def new_func(func):
    def wrappedfun(username, passwd):
        if username == 'root' and passwd == '123456789':
            print('通过认证')
            print('开始执行附加功能')
            return func()
       	else:
            print('用户名或密码错误')
            return
    return wrappedfun

@new_func
def origin():
    print('开始执行函数')
origin('root','123456789')
```

带不定长参数的装饰器

```python
def new_func(func):
    def wrappedfun(*parts):
        if parts:
            counts = len(parts)
            print('本系统包含 ', end='')
            for part in parts:
                print(part, ' ',end='')
            print('等', counts, '部分')
            return func()
        else:
            print('用户名或密码错误')
            return func()
   return wrappedfun
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_65-为什么函数名字可以当做参数用)65.为什么函数名字可以当做参数用?

Python中一切皆对象，函数名是函数在内存中的空间，也是一个对象

### [#](http://www.liuwq.com/views/面试题/python_01.html#_66-python中pass语句的作用是什么？)66.Python中pass语句的作用是什么？

在编写代码时只写框架思路，具体实现还未编写就可以用pass进行占位，是程序不报错，不会进行任何操作。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_67-有这样一段代码，print-c会输出什么，为什么？)67.有这样一段代码，print c会输出什么，为什么？

```python
a = 10
b = 20
c = [a]
a = 15
```

答：10对于字符串，数字，传递是相应的值

### [#](http://www.liuwq.com/views/面试题/python_01.html#_68-交换两个变量的值？)68.交换两个变量的值？

```python
a, b = b, a
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_69-map函数和reduce函数？)69.map函数和reduce函数？

```python
map(lambda x: x * x, [1, 2, 3, 4])   # 使用 lambda
# [1, 4, 9, 16]
reduce(lambda x, y: x * y, [1, 2, 3, 4])  # 相当于 ((1 * 2) * 3) * 4
# 24
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_70-回调函数，如何通信的)70.回调函数，如何通信的?

回调函数是把函数的指针(地址)作为参数传递给另一个函数，将整个函数当作一个对象，赋值给调用的函数。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_71-python主要的内置数据类型都有哪些？-print-dir-‘a-’-的输出？)71.Python主要的内置数据类型都有哪些？ print dir( ‘a ’) 的输出？

内建类型：布尔类型，数字，字符串，列表，元组，字典，集合

输出字符串'a'的内建方法

### [#](http://www.liuwq.com/views/面试题/python_01.html#_72-map-lambda-x-xx，-y-for-y-in-range-3-的输出？)72.map(lambda x:xx，[y for y in range(3)])的输出？

```text
[0, 1, 4]
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_73-hasattr-getattr-setattr-函数使用详解？)73.hasattr() getattr() setattr() 函数使用详解？

hasattr(object,name)函数:

判断一个对象里面是否有name属性或者name方法，返回bool值，有name属性（方法）返回True，否则返回False。

```python
class function_demo(object):
    name = 'demo'
    def run(self):
        return "hello function"
functiondemo = function_demo()
res = hasattr(functiondemo, "name") # 判断对象是否有name属性，True
res = hasattr(functiondemo, "run") # 判断对象是否有run方法，True
res = hasattr(functiondemo, "age") # 判断对象是否有age属性，False
print(res)
```

getattr(object, name[,default])函数：

获取对象object的属性或者方法，如果存在则打印出来，如果不存在，打印默认值，默认值可选。注意：如果返回的是对象的方法，则打印结果是：方法的内存地址，如果需要运行这个方法，可以在后面添加括号().

```python
functiondemo = function_demo()
getattr(functiondemo, "name")# 获取name属性，存在就打印出来 --- demo
getattr(functiondemo, "run") # 获取run 方法，存在打印出方法的内存地址
getattr(functiondemo, "age") # 获取不存在的属性，报错
getattr(functiondemo, "age", 18)# 获取不存在的属性，返回一个默认值
```

setattr(object, name, values)函数：

给对象的属性赋值，若属性不存在，先创建再赋值

```python
class function_demo(object):
    name = "demo"
    def run(self):
        return "hello function"
functiondemo = function_demo()
res = hasattr(functiondemo, "age") # 判断age属性是否存在，False
print(res)
setattr(functiondemo, "age", 18) # 对age属性进行赋值，无返回值
res1 = hasattr(functiondemo, "age") # 再次判断属性是否存在，True
```

综合使用

```python
class function_demo(object):
    name = "demo"
    def run(self):
        return "hello function"
functiondemo = function_demo()
res = hasattr(functiondemo, "addr") # 先判断是否存在
if res:
    addr = getattr(functiondemo, "addr")
    print(addr)
else:
    addr = getattr(functiondemo, "addr", setattr(functiondemo, "addr", "北京首都"))
    print(addr)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_74-一句话解决阶乘函数？)74.一句话解决阶乘函数？

```text
reduce(lambda x,y : x*y,range(1,n+1))
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_75-什么是lambda函数？-有什么好处？)75.什么是lambda函数？ 有什么好处？

lambda 函数是一个可以接收任意多个参数(包括可选参数)并且返回单个表达式值的函数

1.lambda函数比较轻便，即用即仍，很适合需要完成一项功能，但是此功能只在此一处使用，连名字都很随意的情况下

2.匿名函数，一般用来给filter，map这样的函数式编程服务

3.作为回调函数，传递给某些应用，比如消息处理

### [#](http://www.liuwq.com/views/面试题/python_01.html#_76-递归函数停止的条件？)76.递归函数停止的条件？

递归的终止条件一般定义在递归函数内部，在递归调用前要做一个条件判断，根据判断的结果选择是继续调用自身，还是return，，返回终止递归。

终止的条件：判断递归的次数是否达到某一限定值

2.判断运算的结果是否达到某个范围等，根据设计的目的来选择

### [#](http://www.liuwq.com/views/面试题/python_01.html#_77-下面这段代码的输出结果将是什么？请解释。)77.下面这段代码的输出结果将是什么？请解释。

```python
def multipliers():
    return [lambda x: i *x for i in range(4)]
	print([m(2) for m in multipliers()])
```

上面代码的输出结果是[6,6,6,6]，不是我们想的[0,2,4,6]

你如何修改上面的multipliers的定义产生想要的结果？

上述问题产生的原因是python闭包的延迟绑定。这意味着内部函数被调用时，参数的值在闭包内进行查找。因此，当任何由multipliers()返回的函数被调用时,i的值将在附近的范围进行查找。那时，不管返回的函数是否被调用，for循环已经完成，i被赋予了最终的值3.

```python
def multipliers():
    for i in range(4):
        yield lambda x: i *x
```

```python
def multipliers():
    return [lambda x,i = i: i*x for i in range(4)]
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_78-什么是lambda函数？它有什么好处？写一个匿名函数求两个数的和)78.什么是lambda函数？它有什么好处？写一个匿名函数求两个数的和

lambda函数是匿名函数，使用lambda函数能创建小型匿名函数，这种函数得名于省略了用def声明函数的标准步骤

## [#](http://www.liuwq.com/views/面试题/python_01.html#设计模式)设计模式

### [#](http://www.liuwq.com/views/面试题/python_01.html#_79-对设计模式的理解，简述你了解的设计模式？)79.对设计模式的理解，简述你了解的设计模式？

设计模式是经过总结，优化的，对我们经常会碰到的一些编程问题的可重用解决方案。一个设计模式并不像一个类或一个库那样能够直接作用于我们的代码，反之，设计模式更为高级，它是一种必须在特定情形下实现的一种方法模板。 常见的是工厂模式和单例模式

### [#](http://www.liuwq.com/views/面试题/python_01.html#_80-请手写一个单例)80.请手写一个单例

```python
#python2
class A(object):
    __instance = None
    def __new__(cls,*args,**kwargs):
        if cls.__instance is None:
            cls.__instance = objecet.__new__(cls)
            return cls.__instance
        else:
            return cls.__instance
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_81-单例模式的应用场景有那些？)81.单例模式的应用场景有那些？

单例模式应用的场景一般发现在以下条件下： 资源共享的情况下，避免由于资源操作时导致的性能或损耗等，如日志文件，应用配置。 控制资源的情况下，方便资源之间的互相通信。如线程池等，1,网站的计数器 2,应用配置 3.多线程池 4数据库配置 数据库连接池 5.应用程序的日志应用...

### [#](http://www.liuwq.com/views/面试题/python_01.html#_82-用一行代码生成-1-4-9-16-25-36-49-64-81-100)82.用一行代码生成[1,4,9,16,25,36,49,64,81,100]

```python
print([x*x for x in range(1, 11)])
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_83-对装饰器的理解，并写出一个计时器记录方法执行性能的装饰器？)83.对装饰器的理解，并写出一个计时器记录方法执行性能的装饰器？

装饰器本质上是一个callable object ，它可以让其他函数在不需要做任何代码变动的前提下增加额外功能，装饰器的返回值也是一个函数对象。

```python
import time
from functools import wraps

def timeit(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.clock()
        ret = func(*args, **kwargs)
        end = time.clock()
        print('used:',end-start)
        return ret
    
    return wrapper
@timeit
def foo():
    print('in foo()'foo())
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_84-解释以下什么是闭包？)84.解释以下什么是闭包？

在函数内部再定义一个函数，并且这个函数用到了外边函数的变量，那么将这个函数以及用到的一些变量称之为闭包。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_85-函数装饰器有什么作用？)85.函数装饰器有什么作用？

装饰器本质上是一个callable object，它可以在让其他函数在不需要做任何代码的变动的前提下增加额外的功能。装饰器的返回值也是一个函数的对象，它经常用于有切面需求的场景。比如：插入日志，性能测试，事务处理，缓存。权限的校验等场景，有了装饰器就可以抽离出大量的与函数功能本身无关的雷同代码并发并继续使用。 详细参考：https://manjusaka.itscoder.com/2018/02/23/something-about-decorator/

### [#](http://www.liuwq.com/views/面试题/python_01.html#_86-生成器，迭代器的区别？)86.生成器，迭代器的区别？

迭代器是遵循迭代协议的对象。用户可以使用 iter() 以从任何序列得到迭代器（如 list, tuple, dictionary, set 等）。另一个方法则是创建一个另一种形式的迭代器 —— generator 。要获取下一个元素，则使用成员函数 next()（Python 2）或函数 next() function （Python 3） 。当没有元素时，则引发 StopIteration 此例外。若要实现自己的迭代器，则只要实现 next()（Python 2）或 `__next__`()（ Python 3）

生成器（Generator），只是在需要返回数据的时候使用yield语句。每次next()被调用时，生成器会返回它脱离的位置（它记忆语句最后一次执行的位置和所有的数据值）

区别： 生成器能做到迭代器能做的所有事，而且因为自动创建iter()和next()方法，生成器显得特别简洁，而且生成器也是高效的，使用生成器表达式取代列表解析可以同时节省内存。除了创建和保存程序状态的自动方法，当发生器终结时，还会自动抛出StopIteration异常。

官方介绍：https://docs.python.org/3/tutorial/classes.html#iterators

### [#](http://www.liuwq.com/views/面试题/python_01.html#_87-x是什么类型)87.X是什么类型?

```
X= (i for i in range(10))
X是 generator类型
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_88-请用一行代码-实现将1-n-的整数列表以3为单位分组)88.请用一行代码 实现将1-N 的整数列表以3为单位分组

```python
N =100
print ([[x for x in range(1,100)] [i:i+3] for i in range(0,100,3)])
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_89-python中yield的用法)89.Python中yield的用法?

yield就是保存当前程序执行状态。你用for循环的时候，每次取一个元素的时候就会计算一次。用yield的函数叫generator,和iterator一样，它的好处是不用一次计算所有元素，而是用一次算一次，可以节省很多空间，generator每次计算需要上一次计算结果，所以用yield,否则一return，上次计算结果就没了

## [#](http://www.liuwq.com/views/面试题/python_01.html#面向对象)面向对象

### [#](http://www.liuwq.com/views/面试题/python_01.html#_90-python中的可变对象和不可变对象？)90.Python中的可变对象和不可变对象？

不可变对象，该对象所指向的内存中的值不能被改变。当改变某个变量时候，由于其所指的值不能被改变，相当于把原来的值复制一份后再改变，这会开辟一个新的地址，变量再指向这个新的地址。

可变对象，该对象所指向的内存中的值可以被改变。变量（准确的说是引用）改变后，实际上其所指的值直接发生改变，并没有发生复制行为，也没有开辟出新的地址，通俗点说就是原地改变。

Pyhton中，数值类型(int 和float)，字符串str、元祖tuple都是不可变类型。而列表list、字典dict、集合set是可变类型

### [#](http://www.liuwq.com/views/面试题/python_01.html#_91-python的魔法方法)91.Python的魔法方法

魔法方法就是可以给你的类增加魔力的特殊方法，如果你的对象实现（重载）了这些方法中的某一个，那么这个方法就会在特殊的情况下被Python所调用，你可以定义自己想要的行为，而这一切都是自动发生的，它们经常是两个下划线包围来命名的（比如`__init___`,`__len__`),Python的魔法方法是非常强大的所以了解其使用方法也变得尤为重要!

`__init__`构造器，当一个实例被创建的时候初始化的方法，但是它并不是实例化调用的第一个方法。

`__new__`才是实例化对象调用的第一个方法，它只取下cls参数，并把其他参数传给`__init___`.

`___new__`很少使用，但是也有它适合的场景，尤其是当类继承自一个像元祖或者字符串这样不经常改变的类型的时候。

`__call__`让一个类的实例像函数一样被调用

`__getitem__`定义获取容器中指定元素的行为，相当于self[key]

`__getattr__`定义当用户试图访问一个不存在属性的时候的行为。

`__setattr__`定义当一个属性被设置的时候的行为

`__getattribute___`定义当一个属性被访问的时候的行为

### [#](http://www.liuwq.com/views/面试题/python_01.html#_92-面向对象中怎么实现只读属性)92.面向对象中怎么实现只读属性?

将对象私有化，通过共有方法提供一个读取数据的接口

```python
class person:
    def __init__(self, x):
        self.__age = 10
    def age(self):
        return self.__age
t = person(22)
# t.__age =100
print(t.age())
```

最好的方法

```python
class MyCls(object):
    __weight = 50
    
    @property
    def weight(self):
        return self.__weight
   
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_93-谈谈你对面向对象的理解？)93.谈谈你对面向对象的理解？

面向对象是相当于面向过程而言的，面向过程语言是一种基于功能分析的，以算法为中心的程序设计方法，而面向对象是一种基于结构分析的，以数据为中心的程序设计思想。在面向对象语言中有一个很重要的东西，叫做类。面向对象有三大特性：封装、继承、多态。

## [#](http://www.liuwq.com/views/面试题/python_01.html#正则表达式)正则表达式

### [#](http://www.liuwq.com/views/面试题/python_01.html#_94-请写出一段代码用正则匹配出ip？)94.请写出一段代码用正则匹配出ip？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_95-a-“abbbccc”，用正则匹配为abccc-不管有多少b，就出现一次？)95.a = “abbbccc”，用正则匹配为abccc,不管有多少b，就出现一次？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_96-python字符串查找和替换？)96.Python字符串查找和替换？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_97-用python匹配html-g-tag的时候，-和-有什么区别)97.用Python匹配HTML g tag的时候，<.> 和 <.*?> 有什么区别

### [#](http://www.liuwq.com/views/面试题/python_01.html#_98-正则表达式贪婪与非贪婪模式的区别？)98.正则表达式贪婪与非贪婪模式的区别？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_99-写出开头匹配字母和下划线，末尾是数字的正则表达式？)99.写出开头匹配字母和下划线，末尾是数字的正则表达式？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_100-正则表达式操作)100.正则表达式操作

### [#](http://www.liuwq.com/views/面试题/python_01.html#_101-请匹配出变量a-中的json字符串。)101.请匹配出变量A 中的json字符串。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_102-怎么过滤评论中的表情？)102.怎么过滤评论中的表情？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_103-简述python里面search和match的区别)103.简述Python里面search和match的区别

### [#](http://www.liuwq.com/views/面试题/python_01.html#_104-请写出匹配ip的python正则表达式)104.请写出匹配ip的Python正则表达式

### [#](http://www.liuwq.com/views/面试题/python_01.html#_105-python里match与search的区别？)105.Python里match与search的区别？

## [#](http://www.liuwq.com/views/面试题/python_01.html#系统编程)系统编程

### [#](http://www.liuwq.com/views/面试题/python_01.html#_106-进程总结)106.进程总结

进程：程序运行在操作系统上的一个实例，就称之为进程。进程需要相应的系统资源：内存、时间片、pid。 创建进程： 首先要导入multiprocessing中的Process： 创建一个Process对象; 创建Process对象时，可以传递参数;

```python
p = Process(target=XXX,args=(tuple,),kwargs={key:value})
target = XXX 指定的任务函数，不用加(),
args=(tuple,)kwargs={key:value}给任务函数传递的参数
```

使用start()启动进程 结束进程 给子进程指定函数传递参数Demo

```python
import os
from mulitprocessing import Process
import time

def pro_func(name,age,**kwargs):
    for i in range(5):
        print("子进程正在运行中，name=%s,age=%d,pid=%d"%(name,age,os.getpid()))
        print(kwargs)
        time.sleep(0.2)
if __name__ =="__main__":
    #创建Process对象
    p = Process(target=pro_func,args=('小明',18),kwargs={'m':20})
    #启动进程
    p.start()
    time.sleep(1)
    #1秒钟之后，立刻结束子进程
    p.terminate()
    p.join()
```

注意：进程间不共享全局变量

进程之间的通信-Queue

在初始化Queue()对象时（例如q=Queue(),若在括号中没有指定最大可接受的消息数量，获数量为负值时，那么就代表可接受的消息数量没有上限一直到内存尽头）

Queue.qsize():返回当前队列包含的消息数量

Queue.empty():如果队列为空，返回True，反之False

Queue.full():如果队列满了，返回True,反之False

Queue.get([block[,timeout]]):获取队列中的一条消息，然后将其从队列中移除，

block默认值为True。

如果block使用默认值，且没有设置timeout（单位秒),消息队列如果为空，此时程序将被阻塞（停在读中状态），直到消息队列读到消息为止，如果设置了timeout，则会等待timeout秒，若还没读取到任何消息，则抛出“Queue.Empty"异常：

Queue.get_nowait()相当于Queue.get(False)

Queue.put(item,[block[,timeout]]):将item消息写入队列，block默认值为True; 如果block使用默认值，且没有设置timeout（单位秒），消息队列如果已经没有空间可写入，此时程序将被阻塞（停在写入状态），直到从消息队列腾出空间为止，如果设置了timeout，则会等待timeout秒，若还没空间，则抛出”Queue.Full"异常 如果block值为False，消息队列如果没有空间可写入，则会立刻抛出"Queue.Full"异常; Queue.put_nowait(item):相当Queue.put(item,False)

进程间通信Demo:

```python
from multiprocessing import Process.Queue
import os,time,random
#写数据进程执行的代码：
def write(q):
    for value in ['A','B','C']:
        print("Put %s to queue...",%value)
        q.put(value)
        time.sleep(random.random())
#读数据进程执行的代码
def read(q):
    while True:
        if not q.empty():
            value = q.get(True)
            print("Get %s from queue.",%value)
            time.sleep(random.random())
        else:
            break
if __name__=='__main__':
    #父进程创建Queue，并传给各个子进程
    q = Queue()
    pw = Process(target=write,args=(q,))
    pr = Process(target=read,args=(q,))
    #启动子进程pw ，写入：
    pw.start()
    #等待pw结束
    pw.join()
    #启动子进程pr，读取：
    pr.start()
    pr.join()
    #pr 进程里是死循环，无法等待其结束，只能强行终止:
    print('')
    print('所有数据都写入并且读完')
```



```python
进程池Pool
#coding:utf-8
from multiprocessing import Pool
import os,time,random

def worker(msg):
    t_start = time.time()
    print("%s 开始执行，进程号为%d"%(msg,os.getpid()))
    # random.random()随机生成0-1之间的浮点数
    time.sleep(random.random()*2)
    t_stop = time.time()
    print(msg,"执行完毕，耗时%0.2f”%（t_stop-t_start))

po = Pool(3)#定义一个进程池，最大进程数3
for i in range(0,10):
    po.apply_async(worker,(i,))
print("---start----")
po.close()
po.join()
print("----end----")
```

进程池中使用Queue

如果要使用Pool创建进程，就需要使用multiprocessing.Manager()中的Queue(),而不是multiprocessing.Queue(),否则会得到如下的错误信息：

RuntimeError： Queue objects should only be shared between processs through inheritance

```python
from multiprocessing import Manager,Pool
import os,time,random
def reader(q):
    print("reader 启动(%s),父进程为（%s)"%(os.getpid(),os.getpid()))
    for i in range(q.qsize()):
        print("reader 从Queue获取到消息:%s"%q.get(True))

def writer(q):
    print("writer 启动（%s),父进程为(%s)"%(os.getpid(),os.getpid()))
    for i ini "itcast":
        q.put(i)
if __name__ == "__main__":
    print("(%s)start"%os.getpid())
    q = Manager().Queue()#使用Manager中的Queue
    po = Pool()
    po.apply_async(wrtier,(q,))
    time.sleep(1)
    po.apply_async(reader,(q,))
    po.close()
    po.join()
    print("(%s)End"%os.getpid())
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_107-谈谈你对多进程，多线程，以及协程的理解，项目是否用？)107.谈谈你对多进程，多线程，以及协程的理解，项目是否用？

这个问题被问的概念相当之大， 进程：一个运行的程序（代码）就是一个进程，没有运行的代码叫程序，进程是系统资源分配的最小单位，进程拥有自己独立的内存空间，所有进程间数据不共享，开销大。

线程: cpu调度执行的最小单位，也叫执行路径，不能独立存在，依赖进程存在，一个进程至少有一个线程，叫主线程，而多个线程共享内存（数据共享，共享全局变量),从而极大地提高了程序的运行效率。

协程: 是一种用户态的轻量级线程，协程的调度完全由用户控制。协程拥有自己的寄存器上下文和栈。协程调度时，将寄存器上下文和栈保存到其他地方，在切回来的时候，恢复先前保存的寄存器上下文和栈，直接操中栈则基本没有内核切换的开销，可以不加锁的访问全局变量，所以上下文的切换非常快。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_108-python异常使用场景有那些？)108.Python异常使用场景有那些？

异步的使用场景:

1、 不涉及共享资源，获对共享资源只读，即非互斥操作

2、 没有时序上的严格关系

3、 不需要原子操作，或可以通过其他方式控制原子性

4、 常用于IO操作等耗时操作，因为比较影响客户体验和使用性能

5、 不影响主线程逻辑

### [#](http://www.liuwq.com/views/面试题/python_01.html#_109-多线程共同操作同一个数据互斥锁同步？)109.多线程共同操作同一个数据互斥锁同步？

```python
import threading
import time
class MyThread(threading.Thread):
    def run(self):
        global num
        time.sleep(1)
    
        if mutex.acquire(1):
            num +=1
            msg = self.name + 'set num to ' +str(num)
            print msg
            mutex.release()
num = 0
mutex = threading.Lock()
def test():
    for i in range(5):
        t = MyThread()
        t.start()
if __name__=="__main__":
    test()
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_110-什么是多线程竞争？)110.什么是多线程竞争？

线程是非独立的，同一个进程里线程是数据共享的，当各个线程访问数据资源时会出现竞争状态即：数据几乎同步会被多个线程占用，造成数据混乱，即所谓的线程不安全

那么怎么解决多线程竞争问题？---锁

锁的好处： 确保了某段关键代码（共享数据资源）只能由一个线程从头到尾完整地执行能解决多线程资源竞争下的原子操作问题。

锁的坏处： 阻止了多线程并发执行，包含锁的某段代码实际上只能以单线程模式执行，效率就大大地下降了

锁的致命问题: 死锁

### [#](http://www.liuwq.com/views/面试题/python_01.html#_111-请介绍一下python的线程同步？)111.请介绍一下Python的线程同步？

一、 setDaemon(False) 当一个进程启动之后，会默认产生一个主线程，因为线程是程序执行的最小单位，当设置多线程时，主线程会创建多个子线程，在Python中，默认情况下就是setDaemon(False),主线程执行完自己的任务以后，就退出了，此时子线程会继续执行自己的任务，直到自己的任务结束。

例子

```python
import threading 
import time

def thread():
    time.sleep(2)
    print('---子线程结束---')

def main():
    t1 = threading.Thread(target=thread)
    t1.start()
    print('---主线程--结束')

if __name__ =='__main__':
    main()
#执行结果
---主线程--结束
---子线程结束---
```

二、 setDaemon（True) 当我们使用setDaemon(True)时，这是子线程为守护线程，主线程一旦执行结束，则全部子线程被强制终止

例子

```python
import threading
import time
def thread():
    time.sleep(2)
    print(’---子线程结束---')
def main():
    t1 = threading.Thread(target=thread)
    t1.setDaemon(True)#设置子线程守护主线程
    t1.start()
    print('---主线程结束---')

if __name__ =='__main__':
    main()
#执行结果
---主线程结束--- #只有主线程结束，子线程来不及执行就被强制结束
```

三、 join（线程同步) join 所完成的工作就是线程同步，即主线程任务结束以后，进入堵塞状态，一直等待所有的子线程结束以后，主线程再终止。

当设置守护线程时，含义是主线程对于子线程等待timeout的时间将会杀死该子线程，最后退出程序，所以说，如果有10个子线程，全部的等待时间就是每个timeout的累加和，简单的来说，就是给每个子线程一个timeou的时间，让他去执行，时间一到，不管任务有没有完成，直接杀死。

没有设置守护线程时，主线程将会等待timeout的累加和这样的一段时间，时间一到，主线程结束，但是并没有杀死子线程，子线程依然可以继续执行，直到子线程全部结束，程序退出。

例子

```python
import threading
import time

def thread():
    time.sleep(2)
    print('---子线程结束---')

def main():
    t1 = threading.Thread(target=thread)
    t1.setDaemon(True)
    t1.start()
    t1.join(timeout=1)#1 线程同步，主线程堵塞1s 然后主线程结束，子线程继续执行
                        #2 如果不设置timeout参数就等子线程结束主线程再结束
                        #3 如果设置了setDaemon=True和timeout=1主线程等待1s后会强制杀死子线程，然后主线程结束
    print('---主线程结束---')

if __name__=='__main___':
    main()
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_112-解释以下什么是锁，有哪几种锁？)112.解释以下什么是锁，有哪几种锁？

锁(Lock)是python提供的对线程控制的对象。有互斥锁，可重入锁，死锁。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_113-什么是死锁？)113.什么是死锁？

若干子线程在系统资源竞争时，都在等待对方对某部分资源解除占用状态，结果是谁也不愿先解锁，互相干等着，程序无法执行下去，这就是死锁。

GIL锁 全局解释器锁

作用： 限制多线程同时执行，保证同一时间只有一个线程执行，所以cython里的多线程其实是伪多线程！

所以python里常常使用协程技术来代替多线程，协程是一种更轻量级的线程。

进程和线程的切换时由系统决定，而协程由我们程序员自己决定，而模块gevent下切换是遇到了耗时操作时才会切换

三者的关系：进程里有线程，线程里有协程。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_114-多线程交互访问数据，如果访问到了就不访问了？)114.多线程交互访问数据，如果访问到了就不访问了？

怎么避免重读？

创建一个已访问数据列表，用于存储已经访问过的数据，并加上互斥锁，在多线程访问数据的时候先查看数据是否在已访问的列表中，若已存在就直接跳过。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_115-什么是线程安全，什么是互斥锁？)115.什么是线程安全，什么是互斥锁？

每个对象都对应于一个可称为’互斥锁‘的标记，这个标记用来保证在任一时刻，只能有一个线程访问该对象。

同一进程中的多线程之间是共享系统资源的，多个线程同时对一个对象进行操作，一个线程操作尚未结束，另一线程已经对其进行操作，导致最终结果出现错误，此时需要对被操作对象添加互斥锁，保证每个线程对该对象的操作都得到正确的结果。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_116-说说下面几个概念：同步，异步，阻塞，非阻塞？)116.说说下面几个概念：同步，异步，阻塞，非阻塞？

同步： 多个任务之间有先后顺序执行，一个执行完下个才能执行。

异步： 多个任务之间没有先后顺序，可以同时执行，有时候一个任务可能要在必要的时候获取另一个同时执行的任务的结果，这个就叫回调！

阻塞： 如果卡住了调用者，调用者不能继续往下执行，就是说调用者阻塞了。

非阻塞： 如果不会卡住，可以继续执行，就是说非阻塞的。

同步异步相对于多任务而言，阻塞非阻塞相对于代码执行而言。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_117-什么是僵尸进程和孤儿进程？怎么避免僵尸进程？)117.什么是僵尸进程和孤儿进程？怎么避免僵尸进程？

孤儿进程： 父进程退出，子进程还在运行的这些子进程都是孤儿进程，孤儿进程将被init 进程（进程号为1）所收养，并由init 进程对他们完成状态收集工作。

僵尸进程： 进程使用fork 创建子进程，如果子进程退出，而父进程并没有调用wait 获waitpid 获取子进程的状态信息，那么子进程的进程描述符仍然保存在系统中的这些进程是僵尸进程。

避免僵尸进程的方法：

1.fork 两次用孙子进程去完成子进程的任务

2.用wait()函数使父进程阻塞

3.使用信号量，在signal handler 中调用waitpid,这样父进程不用阻塞

### [#](http://www.liuwq.com/views/面试题/python_01.html#_118-python中进程与线程的使用场景？)118.python中进程与线程的使用场景？

多进程适合在CPU密集操作（cpu操作指令比较多，如位多的的浮点运算）。

多线程适合在IO密性型操作（读写数据操作比多的的，比如爬虫）

### [#](http://www.liuwq.com/views/面试题/python_01.html#_119-线程是并发还是并行，进程是并发还是并行？)119.线程是并发还是并行，进程是并发还是并行？

线程是并发，进程是并行;

进程之间互相独立，是系统分配资源的最小单位，同一个线程中的所有线程共享资源。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_120-并行-parallel-和并发（concurrency)120.并行(parallel)和并发（concurrency)?

并行： 同一时刻多个任务同时在运行

不会在同一时刻同时运行，存在交替执行的情况。

实现并行的库有： multiprocessing

实现并发的库有: threading

程序需要执行较多的读写、请求和回复任务的需要大量的IO操作，IO密集型操作使用并发更好。

CPU运算量大的程序，使用并行会更好

### [#](http://www.liuwq.com/views/面试题/python_01.html#_121-io密集型和cpu密集型区别？)121.IO密集型和CPU密集型区别？

IO密集型： 系统运行，大部分的状况是CPU在等 I/O（硬盘/内存）的读/写

CPU密集型： 大部分时间用来做计算，逻辑判断等CPU动作的程序称之CPU密集型。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_122-python-asyncio的原理？)122.python asyncio的原理？

asyncio这个库就是使用python的yield这个可以打断保存当前函数的上下文的机制， 封装好了selector 摆脱掉了复杂的回调关系

## [#](http://www.liuwq.com/views/面试题/python_01.html#网络编程)网络编程

### [#](http://www.liuwq.com/views/面试题/python_01.html#_123-怎么实现强行关闭客户端和服务器之间的连接)123.怎么实现强行关闭客户端和服务器之间的连接?

### [#](http://www.liuwq.com/views/面试题/python_01.html#_124-简述tcp和udp的区别以及优缺点)124.简述TCP和UDP的区别以及优缺点?

### [#](http://www.liuwq.com/views/面试题/python_01.html#_125-简述浏览器通过wsgi请求动态资源的过程)125.简述浏览器通过WSGI请求动态资源的过程?

浏览器发送的请求被Nginx监听到，Nginx根据请求的URL的PATH或者后缀把请求静态资源的分发到静态资源的目录，别的请求根据配置好的转发到相应端口。 实现了WSGI的程序会监听某个端口，监听到Nginx转发过来的请求接收后(一般用socket的recv来接收HTTP的报文)以后把请求的报文封装成`environ`的字典对象，然后再提供一个`start_response`的方法。把这两个对象当成参数传入某个方法比如`wsgi_app(environ, start_response)`或者实现了`__call__(self, environ, start_response)`方法的某个实例。这个实例再调用`start_response`返回给实现了WSGI的中间件，再由中间件返回给Nginx。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_126-描述用浏览器访问www-baidu-com的过程)126.描述用浏览器访问www.baidu.com的过程

### [#](http://www.liuwq.com/views/面试题/python_01.html#_127-post和get请求的区别)127.Post和Get请求的区别?

### [#](http://www.liuwq.com/views/面试题/python_01.html#_128-cookie-和session-的区别？)128.cookie 和session 的区别？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_129-列出你知道的http协议的状态码，说出表示什么意思？)129.列出你知道的HTTP协议的状态码，说出表示什么意思？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_130-请简单说一下三次握手和四次挥手？)130.请简单说一下三次握手和四次挥手？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_131-说一下什么是tcp的2msl？)131.说一下什么是tcp的2MSL？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_132-为什么客户端在time-wait状态必须等待2msl的时间？)132.为什么客户端在TIME-WAIT状态必须等待2MSL的时间？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_133-说说http和https区别？)133.说说HTTP和HTTPS区别？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_134-谈一下http协议以及协议头部中表示数据类型的字段？)134.谈一下HTTP协议以及协议头部中表示数据类型的字段？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_135-http请求方法都有什么？)135.HTTP请求方法都有什么？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_136-使用socket套接字需要传入哪些参数-？)136.使用Socket套接字需要传入哪些参数 ？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_137-http常见请求头？)137.HTTP常见请求头？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_138-七层模型？)138.七层模型？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_139-url的形式？)139.url的形式？

# [#](http://www.liuwq.com/views/面试题/python_01.html#web)Web

## [#](http://www.liuwq.com/views/面试题/python_01.html#flask)Flask

### [#](http://www.liuwq.com/views/面试题/python_01.html#_140-对flask蓝图-blueprint-的理解？)140.对Flask蓝图(Blueprint)的理解？

蓝图的定义

蓝图 /Blueprint 是Flask应用程序组件化的方法，可以在一个应用内或跨越多个项目共用蓝图。使用蓝图可以极大简化大型应用的开发难度，也为Flask扩展提供了一种在应用中注册服务的集中式机制。

蓝图的应用场景：

把一个应用分解为一个蓝图的集合。这对大型应用是理想的。一个项目可以实例化一个应用对象，初始化几个扩展，并注册一集合的蓝图。

以URL前缀和/或子域名，在应用上注册一个蓝图。URL前缀/子域名中的参数即成为这个蓝图下的所有视图函数的共同的视图参数（默认情况下） 在一个应用中用不同的URL规则多次注册一个蓝图。

通过蓝图提供模板过滤器、静态文件、模板和其他功能。一个蓝图不一定要实现应用或视图函数。

初始化一个Flask扩展时，在这些情况中注册一个蓝图。

蓝图的缺点：

不能在应用创建后撤销注册一个蓝图而不销毁整个应用对象。

使用蓝图的三个步骤

1.创建一个蓝图对象

```python
blue = Blueprint("blue",__name__)
```

2.在这个蓝图对象上进行操作，例如注册路由、指定静态文件夹、注册模板过滤器...

```python
@blue.route('/')
def blue_index():
    return "Welcome to my blueprint"
```

3.在应用对象上注册这个蓝图对象

```python
app.register_blueprint(blue,url_prefix="/blue")
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_141-flask-和-django-路由映射的区别？)141.Flask 和 Django 路由映射的区别？

在django中，路由是浏览器访问服务器时，先访问的项目中的url，再由项目中的url找到应用中url，这些url是放在一个列表里，遵从从前往后匹配的规则。在flask中，路由是通过装饰器给每个视图函数提供的，而且根据请求方式的不同可以一个url用于不同的作用。

## [#](http://www.liuwq.com/views/面试题/python_01.html#django)Django

### [#](http://www.liuwq.com/views/面试题/python_01.html#_142-什么是wsgi-uwsgi-uwsgi)142.什么是wsgi,uwsgi,uWSGI?

WSGI:

web服务器网关接口，是一套协议。用于接收用户请求并将请求进行初次封装，然后将请求交给web框架。

实现wsgi协议的模块：wsgiref,本质上就是编写一socket服务端，用于接收用户请求（django)

werkzeug,本质上就是编写一个socket服务端，用于接收用户请求(flask)

uwsgi:

与WSGI一样是一种通信协议，它是uWSGI服务器的独占协议，用于定义传输信息的类型。 uWSGI:

是一个web服务器，实现了WSGI的协议，uWSGI协议，http协议

### [#](http://www.liuwq.com/views/面试题/python_01.html#_143-django、flask、tornado的对比？)143.Django、Flask、Tornado的对比？

1、 Django走的大而全的方向，开发效率高。它的MTV框架，自带的ORM,admin后台管理,自带的sqlite数据库和开发测试用的服务器，给开发者提高了超高的开发效率。 重量级web框架，功能齐全，提供一站式解决的思路，能让开发者不用在选择上花费大量时间。

自带ORM和模板引擎，支持jinja等非官方模板引擎。

自带ORM使Django和关系型数据库耦合度高，如果要使用非关系型数据库，需要使用第三方库

自带数据库管理app

成熟，稳定，开发效率高，相对于Flask，Django的整体封闭性比较好，适合做企业级网站的开发。python web框架的先驱，第三方库丰富

2、 Flask 是轻量级的框架，自由，灵活，可扩展性强，核心基于Werkzeug WSGI工具 和jinja2 模板引擎

适用于做小网站以及web服务的API,开发大型网站无压力，但架构需要自己设计

与关系型数据库的结合不弱于Django，而与非关系型数据库的结合远远优于Django

3、 Tornado走的是少而精的方向，性能优越，它最出名的异步非阻塞的设计方式

Tornado的两大核心模块：

iostraem:对非阻塞的socket进行简单的封装

ioloop: 对I/O 多路复用的封装,它实现一个单例

### [#](http://www.liuwq.com/views/面试题/python_01.html#_144-cors-和-csrf的区别？)144.CORS 和 CSRF的区别？

什么是CORS？

CORS是一个W3C标准,全称是“跨域资源共享"(Cross-origin resoure sharing). 它允许浏览器向跨源服务器，发出XMLHttpRequest请求，从而客服了AJAX只能同源使用的限制。

什么是CSRF？

CSRF主流防御方式是在后端生成表单的时候生成一串随机token,内置到表单里成为一个字段，同时，将此串token置入session中。每次表单提交到后端时都会检查这两个值是否一致，以此来判断此次表单提交是否是可信的，提交过一次之后，如果这个页面没有生成CSRF token,那么token将会被清空,如果有新的需求，那么token会被更新。 攻击者可以伪造POST表单提交，但是他没有后端生成的内置于表单的token，session中没有token都无济于事。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_145-session-cookie-jwt的理解)145.Session,Cookie,JWT的理解

#### 为什么要使用会话管理

众所周知，HTTP协议是一个无状态的协议，也就是说每个请求都是一个独立的请求，请求与请求之间并无关系。但在实际的应用场景，这种方式并不能满足我们的需求。举个大家都喜欢用的例子，把商品加入购物车，单独考虑这个请求，服务端并不知道这个商品是谁的，应该加入谁的购物车？因此这个请求的上下文环境实际上应该包含用户的相关信息，在每次用户发出请求时把这一小部分额外信息，也做为请求的一部分，这样服务端就可以根据上下文中的信息，针对具体的用户进行操作。所以这几种技术的出现都是对HTTP协议的一个补充，使得我们可以用HTTP协议+状态管理构建一个的面向用户的WEB应用。

#### Session 和Cookie的区别

这里我想先谈谈session与cookies,因为这两个技术是做为开发最为常见的。那么session与cookies的区别是什么？个人认为session与cookies最核心区别在于额外信息由谁来维护。利用cookies来实现会话管理时，用户的相关信息或者其他我们想要保持在每个请求中的信息，都是放在cookies中,而cookies是由客户端来保存，每当客户端发出新请求时，就会稍带上cookies,服务端会根据其中的信息进行操作。 当利用session来进行会话管理时，客户端实际上只存了一个由服务端发送的session_id,而由这个session_id,可以在服务端还原出所需要的所有状态信息，从这里可以看出这部分信息是由服务端来维护的。

##### 除此以外，session与cookies都有一些自己的缺点：

cookies的安全性不好，攻击者可以通过获取本地cookies进行欺骗或者利用cookies进行CSRF攻击。使用cookies时,在多个域名下，会存在跨域问题。 session 在一定的时间里，需要存放在服务端，因此当拥有大量用户时，也会大幅度降低服务端的性能，当有多台机器时，如何共享session也会是一个问题.(redis集群)也就是说，用户第一个访问的时候是服务器A，而第二个请求被转发给了服务器B，那服务器B如何得知其状态。实际上，session与cookies是有联系的，比如我们可以把session_id存放在cookies中的。

##### JWT是如何工作的

首先用户发出登录请求，服务端根据用户的登录请求进行匹配，如果匹配成功，将相关的信息放入payload中，利用算法，加上服务端的密钥生成token，这里需要注意的是secret_key很重要，如果这个泄露的话，客户端就可以随机篡改发送的额外信息，它是信息完整性的保证。生成token后服务端将其返回给客户端，客户端可以在下次请求时，将token一起交给服务端，一般是说我们可以将其放在Authorization首部中，这样也就可以避免跨域问题。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_146-简述django请求生命周期)146.简述Django请求生命周期

一般是用户通过浏览器向我们的服务器发起一个请求(request),这个请求会去访问视图函数，如果不涉及到数据调用，那么这个时候视图函数返回一个模板也就是一个网页给用户） 视图函数调用模型毛模型去数据库查找数据，然后逐级返回，视图函数把返回的数据填充到模板中空格中，最后返回网页给用户。

1.wsgi ,请求封装后交给web框架（Flask，Django)

2.中间件，对请求进行校验或在请求对象中添加其他相关数据，例如：csrf,request.session

3.路由匹配 根据浏览器发送的不同url去匹配不同的视图函数

4.视图函数，在视图函数中进行业务逻辑的处理，可能涉及到：orm，templates

5.中间件，对响应的数据进行处理

6.wsgi，将响应的内容发送给浏览器

### [#](http://www.liuwq.com/views/面试题/python_01.html#_147-用的restframework完成api发送时间时区)147.用的restframework完成api发送时间时区

当前的问题是用django的rest framework模块做一个get请求的发送时间以及时区信息的api

```python
class getCurrenttime(APIView):
    def get(self,request):
        local_time = time.localtime()
        time_zone =settings.TIME_ZONE
        temp = {'localtime':local_time,'timezone':time_zone}
        return Response(temp)
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_148-nginx-tomcat-apach到都是什么？)148.nginx,tomcat,apach到都是什么？

Nginx（engine x)是一个高性能的HTTP和反向代理服务器，也是 一个IMAP/POP3/SMTP服务器，工作在OSI七层，负载的实现方式：轮询，IP_HASH,fair,session_sticky. Apache HTTP Server是一个模块化的服务器，源于NCSAhttpd服务器 Tomcat 服务器是一个免费的开放源代码的Web应用服务器，属于轻量级应用服务器，是开发和调试JSP程序的首选。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_149-请给出你熟悉关系数据库范式有哪些，有什么作用？)149.请给出你熟悉关系数据库范式有哪些，有什么作用？

在进行数据库的设计时，所遵循的一些规范，只要按照设计规范进行设计，就能设计出没有数据冗余和数据维护异常的数据库结构。

数据库的设计的规范有很多，通常来说我们在设是数据库时只要达到其中一些规范就可以了，这些规范又称之为数据库的三范式，一共有三条，也存在着其他范式，我们只要做到满足前三个范式的要求，就能设陈出符合我们的数据库了，我们也不能全部来按照范式的要求来做，还要考虑实际的业务使用情况，所以有时候也需要做一些违反范式的要求。 1.数据库设计的第一范式(最基本)，基本上所有数据库的范式都是符合第一范式的，符合第一范式的表具有以下几个特点：

数据库表中的所有字段都只具有单一属性，单一属性的列是由基本的数据类型（整型，浮点型，字符型等）所构成的设计出来的表都是简单的二比表

2.数据库设计的第二范式(是在第一范式的基础上设计的)，要求一个表中只具有一个业务主键，也就是说符合第二范式的表中不能存在非主键列对只对部分主键的依赖关系

3.数据库设计的第三范式，指每一个非主属性既不部分依赖与也不传递依赖于业务主键，也就是第二范式的基础上消除了非主属性对主键的传递依赖

### [#](http://www.liuwq.com/views/面试题/python_01.html#_150-简述qq登陆过程)150.简述QQ登陆过程

qq登录，在我们的项目中分为了三个接口，

第一个接口是请求qq服务器返回一个qq登录的界面;

第二个接口是通过扫码或账号登陆进行验证，qq服务器返回给浏览器一个code和state,利用这个code通过本地服务器去向qq服务器获取access_token覆返回给本地服务器，凭借access_token再向qq服务器获取用户的openid(openid用户的唯一标识)

第三个接口是判断用户是否是第一次qq登录，如果不是的话直接登录返回的jwt-token给用户，对没有绑定过本网站的用户，对openid进行加密生成token进行绑定

### [#](http://www.liuwq.com/views/面试题/python_01.html#_151-post-和-get的区别)151.post 和 get的区别?

1.GET是从服务器上获取数据，POST是向服务器传送数据

2.在客户端，GET方式在通过URL提交数据，数据在URL中可以看到，POST方式，数据放置在HTML——HEADER内提交

3.对于GET方式，服务器端用Request.QueryString获取变量的值，对于POST方式，服务器端用Request.Form获取提交的数据

### [#](http://www.liuwq.com/views/面试题/python_01.html#_152-项目中日志的作用)152.项目中日志的作用

一、日志相关概念

1.日志是一种可以追踪某些软件运行时所发生事件的方法

2.软件开发人员可以向他们的代码中调用日志记录相关的方法来表明发生了某些事情

3.一个事件可以用一个包含可选变量数据的消息来描述

4.此外，事件也有重要性的概念，这个重要性也可以被成为严重性级别(level)

二、日志的作用

1.通过log的分析，可以方便用户了解系统或软件、应用的运行情况;

2.如果你的应用log足够丰富，可以分析以往用户的操作行为、类型喜好，地域分布或其他更多信息;

3.如果一个应用的log同时也分了多个级别，那么可以很轻易地分析得到该应用的健康状况，及时发现问题并快速定位、解决问题，补救损失。

4.简单来讲就是我们通过记录和分析日志可以了解一个系统或软件程序运行情况是否正常，也可以在应用程序出现故障时快速定位问题。不仅在开发中，在运维中日志也很重要，日志的作用也可以简单。总结为以下几点：

1.程序调试

2.了解软件程序运行情况，是否正常

3,软件程序运行故障分析与问题定位

4,如果应用的日志信息足够详细和丰富，还可以用来做用户行为分析

### [#](http://www.liuwq.com/views/面试题/python_01.html#_153-django中间件的使用？)153.django中间件的使用？

Django在中间件中预置了六个方法，这六个方法的区别在于不同的阶段执行，对输入或输出进行干预，方法如下：

1.初始化：无需任何参数，服务器响应第一个请求的时候调用一次，用于确定是否启用当前中间件

```python
def __init__():
    pass
```

2.处理请求前：在每个请求上调用，返回None或HttpResponse对象。

```python
def process_request(request):
    pass
```

3.处理视图前:在每个请求上调用，返回None或HttpResponse对象。

```python
def process_view(request,view_func,view_args,view_kwargs):
    pass
```

4.处理模板响应前：在每个请求上调用，返回实现了render方法的响应对象。

```python
def process_template_response(request,response):
    pass
```

5.处理响应后：所有响应返回浏览器之前被调用，在每个请求上调用，返回HttpResponse对象。

```python
def process_response(request,response):
    pass
```

6.异常处理：当视图抛出异常时调用，在每个请求上调用，返回一个HttpResponse对象。

```python
def process_exception(request,exception):
    pass
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_154-谈一下你对uwsgi和nginx的理解？)154.谈一下你对uWSGI和nginx的理解？

1.uWSGI是一个Web服务器，它实现了WSGI协议、uwsgi、http等协议。Nginx中HttpUwsgiModule的作用是与uWSGI服务器进行交换。WSGI是一种Web服务器网关接口。它是一个Web服务器（如nginx，uWSGI等服务器）与web应用（如用Flask框架写的程序）通信的一种规范。

要注意WSGI/uwsgi/uWSGI这三个概念的区分。

WSGI是一种通信协议。

uwsgi是一种线路协议而不是通信协议，在此常用于在uWSGI服务器与其他网络服务器的数据通信。

uWSGI是实现了uwsgi和WSGI两种协议的Web服务器。

nginx 是一个开源的高性能的HTTP服务器和反向代理：

1.作为web服务器，它处理静态文件和索引文件效果非常高

2.它的设计非常注重效率，最大支持5万个并发连接，但只占用很少的内存空间

3.稳定性高，配置简洁。

4.强大的反向代理和负载均衡功能，平衡集群中各个服务器的负载压力应用

### [#](http://www.liuwq.com/views/面试题/python_01.html#_155-python中三大框架各自的应用场景？)155.Python中三大框架各自的应用场景？

django:主要是用来搞快速开发的，他的亮点就是快速开发，节约成本，,如果要实现高并发的话，就要对django进行二次开发，比如把整个笨重的框架给拆掉自己写socket实现http的通信,底层用纯c,c++写提升效率，ORM框架给干掉，自己编写封装与数据库交互的框架,ORM虽然面向对象来操作数据库，但是它的效率很低，使用外键来联系表与表之间的查询; flask: 轻量级，主要是用来写接口的一个框架，实现前后端分离，提考开发效率，Flask本身相当于一个内核，其他几乎所有的功能都要用到扩展(邮件扩展Flask-Mail，用户认证Flask-Login),都需要用第三方的扩展来实现。比如可以用Flask-extension加入ORM、文件上传、身份验证等。Flask没有默认使用的数据库，你可以选择MySQL，也可以用NoSQL。

其WSGI工具箱用Werkzeug(路由模块)，模板引擎则使用Jinja2,这两个也是Flask框架的核心。

Tornado： Tornado是一种Web服务器软件的开源版本。Tornado和现在的主流Web服务器框架（包括大多数Python的框架）有着明显的区别：它是非阻塞式服务器，而且速度相当快。得利于其非阻塞的方式和对epoll的运用，Tornado每秒可以处理数以千计的连接因此Tornado是实时Web服务的一个理想框架

### [#](http://www.liuwq.com/views/面试题/python_01.html#_156-django中哪里用到了线程？哪里用到了协程？哪里用到了进程？)156.Django中哪里用到了线程？哪里用到了协程？哪里用到了进程？

1.Django中耗时的任务用一个进程或者线程来执行，比如发邮件，使用celery.

2.部署django项目是时候，配置文件中设置了进程和协程的相关配置。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_157-有用过django-rest-framework吗？)157.有用过Django REST framework吗？

Django REST framework是一个强大而灵活的Web API工具。使用RESTframework的理由有：

Web browsable API对开发者有极大的好处

包括OAuth1a和OAuth2的认证策略

支持ORM和非ORM数据资源的序列化

全程自定义开发--如果不想使用更加强大的功能，可仅仅使用常规的function-based views额外的文档和强大的社区支持

### [#](http://www.liuwq.com/views/面试题/python_01.html#_158-对cookies与session的了解？他们能单独用吗？)158.对cookies与session的了解？他们能单独用吗？

Session采用的是在服务器端保持状态的方案，而Cookie采用的是在客户端保持状态的方案。但是禁用Cookie就不能得到Session。因为Session是用Session ID来确定当前对话所对应的服务器Session，而Session ID是通过Cookie来传递的，禁用Cookie相当于SessionID,也就得不到Session。

## [#](http://www.liuwq.com/views/面试题/python_01.html#爬虫)爬虫

### [#](http://www.liuwq.com/views/面试题/python_01.html#_159-试列出至少三种目前流行的大型数据库)159.试列出至少三种目前流行的大型数据库

### [#](http://www.liuwq.com/views/面试题/python_01.html#_160-列举您使用过的python网络爬虫所用到的网络数据包)160.列举您使用过的Python网络爬虫所用到的网络数据包?

requests, urllib,urllib2, httplib2

### [#](http://www.liuwq.com/views/面试题/python_01.html#_161-爬取数据后使用哪个数据库存储数据的，为什么？)161.爬取数据后使用哪个数据库存储数据的，为什么？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_162-你用过的爬虫框架或者模块有哪些？优缺点？)162.你用过的爬虫框架或者模块有哪些？优缺点？

Python自带：urllib,urllib2

第三方：requests

框架： Scrapy

urllib 和urllib2模块都做与请求URL相关的操作，但他们提供不同的功能。

urllib2: urllib2.urlopen可以接受一个Request对象或者url,(在接受Request对象时，并以此可以来设置一个URL的headers),urllib.urlopen只接收一个url。

urllib 有urlencode,urllib2没有，因此总是urllib, urllib2常会一起使用的原因

scrapy是封装起来的框架，他包含了下载器，解析器，日志及异常处理，基于多线程，twisted的方式处理，对于固定单个网站的爬取开发，有优势，但是对于多网站爬取100个网站，并发及分布式处理不够灵活，不便调整与扩展

requests是一个HTTP库，它只是用来请求，它是一个强大的库，下载，解析全部自己处理，灵活性高

Scrapy优点：异步，xpath，强大的统计和log系统，支持不同url。shell方便独立调试。写middleware方便过滤。通过管道存入数据库

### [#](http://www.liuwq.com/views/面试题/python_01.html#_163-写爬虫是用多进程好？还是多线程好？)163.写爬虫是用多进程好？还是多线程好？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_164-常见的反爬虫和应对方法？)164.常见的反爬虫和应对方法？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_165-解析网页的解析器使用最多的是哪几个)165.解析网页的解析器使用最多的是哪几个?

### [#](http://www.liuwq.com/views/面试题/python_01.html#_166-需要登录的网页，如何解决同时限制ip，cookie-session)166.需要登录的网页，如何解决同时限制ip，cookie,session

### [#](http://www.liuwq.com/views/面试题/python_01.html#_167-验证码的解决)167.验证码的解决?

### [#](http://www.liuwq.com/views/面试题/python_01.html#_168-使用最多的数据库，对他们的理解？)168.使用最多的数据库，对他们的理解？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_169-编写过哪些爬虫中间件？)169.编写过哪些爬虫中间件？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_170-“极验”滑动验证码如何破解？)170.“极验”滑动验证码如何破解？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_171-爬虫多久爬一次，爬下来的数据是怎么存储？)171.爬虫多久爬一次，爬下来的数据是怎么存储？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_172-cookie过期的处理问题？)172.cookie过期的处理问题？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_173-动态加载又对及时性要求很高怎么处理？)173.动态加载又对及时性要求很高怎么处理？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_174-https有什么优点和缺点？)174.HTTPS有什么优点和缺点？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_175-https是如何实现安全传输数据的？)175.HTTPS是如何实现安全传输数据的？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_176-ttl，msl，rtt各是什么？)176.TTL，MSL，RTT各是什么？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_177-谈一谈你对selenium和phantomjs了解)177.谈一谈你对Selenium和PhantomJS了解

### [#](http://www.liuwq.com/views/面试题/python_01.html#_178-平常怎么使用代理的-？)178.平常怎么使用代理的 ？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_179-存放在数据库-redis、mysql等-。)179.存放在数据库(redis、mysql等)。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_180-怎么监控爬虫的状态)180.怎么监控爬虫的状态?

### [#](http://www.liuwq.com/views/面试题/python_01.html#_181-描述下scrapy框架运行的机制？)181.描述下scrapy框架运行的机制？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_182-谈谈你对scrapy的理解？)182.谈谈你对Scrapy的理解？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_183-怎么样让-scrapy-框架发送一个-post-请求（具体写出来）)183.怎么样让 scrapy 框架发送一个 post 请求（具体写出来）

### [#](http://www.liuwq.com/views/面试题/python_01.html#_184-怎么监控爬虫的状态-？)184.怎么监控爬虫的状态 ？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_185-怎么判断网站是否更新？)185.怎么判断网站是否更新？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_186-图片、视频爬取怎么绕过防盗连接)186.图片、视频爬取怎么绕过防盗连接

### [#](http://www.liuwq.com/views/面试题/python_01.html#_187-你爬出来的数据量大概有多大？大概多长时间爬一次？)187.你爬出来的数据量大概有多大？大概多长时间爬一次？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_188-用什么数据库存爬下来的数据？部署是你做的吗？怎么部署？)188.用什么数据库存爬下来的数据？部署是你做的吗？怎么部署？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_189-增量爬取)189.增量爬取

### [#](http://www.liuwq.com/views/面试题/python_01.html#_190-爬取下来的数据如何去重，说一下scrapy的具体的算法依据。)190.爬取下来的数据如何去重，说一下scrapy的具体的算法依据。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_191-scrapy的优缺点)191.Scrapy的优缺点?

### [#](http://www.liuwq.com/views/面试题/python_01.html#_192-怎么设置爬取深度？)192.怎么设置爬取深度？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_193-scrapy和scrapy-redis有什么区别？为什么选择redis数据库？)193.scrapy和scrapy-redis有什么区别？为什么选择redis数据库？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_194-分布式爬虫主要解决什么问题？)194.分布式爬虫主要解决什么问题？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_195-什么是分布式存储？)195.什么是分布式存储？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_196-你所知道的分布式爬虫方案有哪些？)196.你所知道的分布式爬虫方案有哪些？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_197-scrapy-redis，有做过其他的分布式爬虫吗？)197.scrapy-redis，有做过其他的分布式爬虫吗？

# [#](http://www.liuwq.com/views/面试题/python_01.html#数据库)数据库

## [#](http://www.liuwq.com/views/面试题/python_01.html#mysql)MySQL

### [#](http://www.liuwq.com/views/面试题/python_01.html#_198-主键-超键-候选键-外键)198.主键 超键 候选键 外键

主键：数据库表中对存储数据对象予以唯一和完整标识的数据列或属性的组合。一个数据列只能有一个主键，且主键的取值不能缺失，即不能为空值(Null).

超键：在关系中能唯一标识元组的属性集称为关系模式的超键。一个属性可以作为一个超键，多个属性组合在一起也可以作为一个超键。超键包含候选键和主键。

候选键：是最小超键，即没有冗余元素的超键。

外键：在一个表中存在的另一个表的主键称此表的外键。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_199-视图的作用，视图可以更改么？)199.视图的作用，视图可以更改么？

视图是虚拟的表，与包含数据的表不一样，视图只包含使用时动态检索数据的查询;不包含任何列或数据。使用视图可以简化复杂的sql操作，隐藏具体的细节，保护数据;视图创建后，可以使用与表相同的方式利用它们。

视图不能被索引，也不能有关联的触发器或默认值，如果视图本身内有order by则对视图再次order by将被覆盖。

创建视图： create view xxx as xxxxxx

对于某些视图比如未使用联结子查询分组聚集函数Distinct Union等，是可以对其更新的，对视图的更新将对基表进行更新;但是视图主要用于简化检索，保护数据，并不用于更新，而且大部分视图都不可以更新。

### [#](http://www.liuwq.com/views/面试题/python_01.html#_200-drop-delete与truncate的区别)200.drop,delete与truncate的区别

drop直接删掉表，truncate删除表中数据，再插入时自增长id又从1开始，delete删除表中数据，可以加where字句。

1.delete 语句执行删除的过程是每次从表中删除一行，并且同时将该行的删除操作作为事务记录在日志中保存以便进行回滚操作。truncate table则一次性地从表中删除所有的数据并不把单独的删除操作记录记入日志保存，删除行是不能恢复的。并且在删除的过程中不会激活与表有关的删除触发器，执行速度快。

2.表和索引所占空间。当表被truncate后，这个表和索引所占用的空间会恢复到初始大小，而delete操作不会减少表或索引所占用的空间。drop语句将表所占用的空间全释放掉。

3.一般而言，drop>truncate>delete

4.应用范围。truncate只能对table，delete可以是table和view

5.truncate和delete只删除数据，而drop则删除整个表（结构和数据)

6.truncate与不带where的delete:只删除数据，而不删除表的结构（定义）drop语句将删除表的结构被依赖的约束(constrain),触发器（trigger)索引(index);依赖于该表的存储过程/函数将被保留，但其状态会变为:invalid.

### [#](http://www.liuwq.com/views/面试题/python_01.html#_201-索引的工作原理及其种类)201.索引的工作原理及其种类

数据库索引，是数据库管理系统中一个排序的数据结构，以协助快速查询，更新数据库表中数据。索引的实现通常使用B树以其变种B+树。

在数据之外，数据库系统还维护着满足特定查找算法的数据结构，这些数据结构以某种方式引用（指向）数据，这样就可以在这些数据结构上实现高级查找算法。这种数据结构，就是索引。

为表设置索引要付出代价的：一是增加了数据库的存储空间，二是在插入和修改数据时要花费较多的时间（因为索引也要随之变动）

### [#](http://www.liuwq.com/views/面试题/python_01.html#_202-连接的种类)202.连接的种类

### [#](http://www.liuwq.com/views/面试题/python_01.html#_203-数据库优化的思路)203.数据库优化的思路

### [#](http://www.liuwq.com/views/面试题/python_01.html#_204-存储过程与触发器的区别)204.存储过程与触发器的区别

### [#](http://www.liuwq.com/views/面试题/python_01.html#_205-悲观锁和乐观锁是什么？)205.悲观锁和乐观锁是什么？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_206-你常用的mysql引擎有哪些-各引擎间有什么区别)206.你常用的mysql引擎有哪些?各引擎间有什么区别?

## [#](http://www.liuwq.com/views/面试题/python_01.html#redis)Redis

### [#](http://www.liuwq.com/views/面试题/python_01.html#_207-redis宕机怎么解决)207.Redis宕机怎么解决?

宕机:服务器停止服务‘

如果只有一台redis，肯定 会造成数据丢失，无法挽救

多台redis或者是redis集群，宕机则需要分为在主从模式下区分来看：

slave从redis宕机，配置主从复制的时候才配置从的redis，从的会从主的redis中读取主的redis的操作日志1，在redis中从库重新启动后会自动加入到主从架构中，自动完成同步数据;

2, 如果从数据库实现了持久化，此时千万不要立马重启服务，否则可能会造成数据丢失，正确的操作如下：在slave数据上执行SLAVEOF ON ONE,来断开主从关系并把slave升级为主库，此时重新启动主数据库，执行SLAVEOF，把它设置为从库，连接到主的redis上面做主从复制，自动备份数据。

以上过程很容易配置错误，可以使用redis提供的哨兵机制来简化上面的操作。简单的方法:redis的哨兵(sentinel)的功能

### [#](http://www.liuwq.com/views/面试题/python_01.html#_208-redis和mecached的区别，以及使用场景)208.redis和mecached的区别，以及使用场景

区别

1、redis和Memcache都是将数据存放在内存中，都是内存数据库。不过memcache还可以用于缓存其他东西，例如图片，视频等等

2、Redis不仅仅支持简单的k/v类型的数据，同时还提供list,set,hash等数据结构的存储

3、虚拟内存-redis当物流内存用完时，可以将一些很久没用的value交换到磁盘

4、过期策略-memcache在set时就指定，例如set key1 0 0 8，即永不过期。Redis可以通过例如expire设定，例如expire name 10

5、分布式-设定memcache集群，利用magent做一主多从，redis可以做一主多从。都可以一主一丛

6、存储数据安全-memcache挂掉后，数据没了，redis可以定期保存到磁盘(持久化)

7、灾难恢复-memcache挂掉后，数据不可恢复，redis数据丢失后可以通过aof恢复

8、Redis支持数据的备份，即master-slave模式的数据备份

9、应用场景不一样，redis除了作为NoSQL数据库使用外，还能用做消息队列，数据堆栈和数据缓存等;Memcache适合于缓存SQL语句，数据集，用户临时性数据，延迟查询数据和session等

使用场景

1,如果有持久方面的需求或对数据类型和处理有要求的应该选择redis

2,如果简单的key/value存储应该选择memcached.

### [#](http://www.liuwq.com/views/面试题/python_01.html#_209-redis集群方案该怎么做-都有哪些方案)209.Redis集群方案该怎么做?都有哪些方案?

1,codis

目前用的最多的集群方案，基本和twemproxy一致的效果，但它支持在节点数量改变情况下，旧节点数据客恢复到新hash节点

2redis cluster3.0自带的集群，特点在于他的分布式算法不是一致性hash，而是hash槽的概念，以及自身支持节点设置从节点。具体看官方介绍

3.在业务代码层实现，起几个毫无关联的redis实例，在代码层，对key进行hash计算，然后去对应的redis实例操作数据。这种方式对hash层代码要求比较高，考虑部分包括，节点失效后的替代算法方案，数据震荡后的字典脚本恢复，实例的监控，等等

### [#](http://www.liuwq.com/views/面试题/python_01.html#_210-redis回收进程是如何工作的)210.Redis回收进程是如何工作的

一个客户端运行了新的命令，添加了新的数据。

redis检查内存使用情况，如果大于maxmemory的限制，则根据设定好的策略进行回收。

一个新的命令被执行等等，所以我们不断地穿越内存限制的边界，通过不断达到边界然后不断回收回到边界以下。

如果一个命令的结果导致大量内存被使用(例如很大的集合的交集保存到一个新的键)，不用多久内存限制就会被这个内存使用量超越。

## [#](http://www.liuwq.com/views/面试题/python_01.html#mongodb)MongoDB

### [#](http://www.liuwq.com/views/面试题/python_01.html#_211-mongodb中对多条记录做更新操作命令是什么？)211.MongoDB中对多条记录做更新操作命令是什么？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_212-mongodb如何才会拓展到多个shard里？)212.MongoDB如何才会拓展到多个shard里？

## [#](http://www.liuwq.com/views/面试题/python_01.html#测试)测试

### [#](http://www.liuwq.com/views/面试题/python_01.html#_213-编写测试计划的目的是)213.编写测试计划的目的是

### [#](http://www.liuwq.com/views/面试题/python_01.html#_214-对关键词触发模块进行测试)214.对关键词触发模块进行测试

### [#](http://www.liuwq.com/views/面试题/python_01.html#_215-其他常用笔试题目网址汇总)215.其他常用笔试题目网址汇总

### [#](http://www.liuwq.com/views/面试题/python_01.html#_216-测试人员在软件开发过程中的任务是什么)216.测试人员在软件开发过程中的任务是什么

### [#](http://www.liuwq.com/views/面试题/python_01.html#_217-一条软件bug记录都包含了哪些内容？)217.一条软件Bug记录都包含了哪些内容？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_218-简述黑盒测试和白盒测试的优缺点)218.简述黑盒测试和白盒测试的优缺点

### [#](http://www.liuwq.com/views/面试题/python_01.html#_219-请列出你所知道的软件测试种类，至少5项)219.请列出你所知道的软件测试种类，至少5项

### [#](http://www.liuwq.com/views/面试题/python_01.html#_220-alpha测试与beta测试的区别是什么？)220.Alpha测试与Beta测试的区别是什么？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_221-举例说明什么是bug？一个bug-report应包含什么关键字？)221.举例说明什么是Bug？一个bug report应包含什么关键字？

## [#](http://www.liuwq.com/views/面试题/python_01.html#数据结构)数据结构

### [#](http://www.liuwq.com/views/面试题/python_01.html#_222-数组中出现次数超过一半的数字-python版)222.数组中出现次数超过一半的数字-Python版

### [#](http://www.liuwq.com/views/面试题/python_01.html#_223-求100以内的质数)223.求100以内的质数

### [#](http://www.liuwq.com/views/面试题/python_01.html#_224-无重复字符的最长子串-python实现)224.无重复字符的最长子串-Python实现

### [#](http://www.liuwq.com/views/面试题/python_01.html#_225-通过2个5-6升得水壶从池塘得到3升水)225.通过2个5/6升得水壶从池塘得到3升水

### [#](http://www.liuwq.com/views/面试题/python_01.html#_226-什么是md5加密，有什么特点？)226.什么是MD5加密，有什么特点？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_227-什么是对称加密和非对称加密)227.什么是对称加密和非对称加密

### [#](http://www.liuwq.com/views/面试题/python_01.html#_228-冒泡排序的思想？)228.冒泡排序的思想？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_229-快速排序的思想？)229.快速排序的思想？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_230-如何判断单向链表中是否有环？)230.如何判断单向链表中是否有环？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_231-你知道哪些排序算法（一般是通过问题考算法）)231.你知道哪些排序算法（一般是通过问题考算法）

### [#](http://www.liuwq.com/views/面试题/python_01.html#_232-斐波那契数列)232.斐波那契数列

**数列定义: **

f 0 = f 1 = 1 f n = f (n-1) + f (n-2)

#### [#](http://www.liuwq.com/views/面试题/python_01.html#根据定义)根据定义

速度很慢，另外(暴栈注意！⚠️️） `O(fibonacci n)`

```python
def fibonacci(n):
    if n == 0 or n == 1:
        return 1
    return fibonacci(n - 1) + fibonacci(n - 2)
```

#### [#](http://www.liuwq.com/views/面试题/python_01.html#线性时间的)线性时间的

**状态/循环**

```python
def fibonacci(n):
   a, b = 1, 1
   for _ in range(n):
       a, b = b, a + b
   return a
```

**递归**

```python
def fibonacci(n):
    def fib(n_, s):
        if n_ == 0:
            return s[0]
        a, b = s
        return fib(n_ - 1, (b, a + b))
    return fib(n, (1, 1))
```

**map(zipwith)**

```python
def fibs():
    yield 1
    fibs_ = fibs()
    yield next(fibs_)
    fibs__ = fibs()
    for fib in map(lambad a, b: a + b, fibs_, fibs__):
        yield fib
        
        
def fibonacci(n):
    fibs_ = fibs()
    for _ in range(n):
        next(fibs_)
    return next(fibs)
```

#### [#](http://www.liuwq.com/views/面试题/python_01.html#logarithmic)Logarithmic

**矩阵**

```python
import numpy as np
def fibonacci(n):
    return (np.matrix([[0, 1], [1, 1]]) ** n)[1, 1]
```

**不是矩阵**

```python
def fibonacci(n):
    def fib(n):
        if n == 0:
            return (1, 1)
        elif n == 1:
            return (1, 2)
        a, b = fib(n // 2 - 1)
        c = a + b
        if n % 2 == 0:
            return (a * a + b * b, c * c - a * a)
        return (c * c - a * a, b * b + c * c)
    return fib(n)[0]
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_233-如何翻转一个单链表？)233.如何翻转一个单链表？

```python
class Node:
    def __init__(self,data=None,next=None):
        self.data = data
        self.next = next
        
def rev(link):
    pre = link
    cur = link.next
    pre.next = None
    while cur:
        temp  = cur.next
        cur.next = pre
        pre = cur
        cur = tmp
    return pre

if __name__ == '__main__':
    link = Node(1,Node(2,Node(3,Node(4,Node(5,Node(6,Node7,Node(8.Node(9))))))))
    root = rev(link)
    while root:
        print(roo.data)
        root = root.next
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_234-青蛙跳台阶问题)234.青蛙跳台阶问题

一只青蛙要跳上n层高的台阶，一次能跳一级，也可以跳两级，请问这只青蛙有多少种跳上这个n层台阶的方法？

方法1：递归

设青蛙跳上n级台阶有f(n)种方法，把这n种方法分为两大类，第一种最后一次跳了一级台阶，这类共有f(n-1)种，第二种最后一次跳了两级台阶，这种方法共有f(n-2)种，则得出递推公式f(n)=f(n-1) + f(n-2),显然f(1)=1,f(2)=2，这种方法虽然代码简单，但效率低，会超出时间上限

```python
class Solution:
    def climbStairs(self,n):
        if n ==1:
            return 1
        elif n==2:
            return 2
        else:
            return self.climbStairs(n-1) + self.climbStairs(n-2)
```

方法2：用循环来代替递归

```python
class Solution:
    def climbStairs(self,n):
        if n==1 or n==2:
            return n
        a,b,c = 1,2,3
        for i in range(3,n+1):
            c = a+b
            a = b
            b = c
        return c
```

### [#](http://www.liuwq.com/views/面试题/python_01.html#_235-两数之和-two-sum)235.两数之和 Two Sum

### [#](http://www.liuwq.com/views/面试题/python_01.html#_236-搜索旋转排序数组-search-in-rotated-sorted-array)236.搜索旋转排序数组 Search in Rotated Sorted Array

### [#](http://www.liuwq.com/views/面试题/python_01.html#_237-python实现一个stack的数据结构)237.Python实现一个Stack的数据结构

### [#](http://www.liuwq.com/views/面试题/python_01.html#_238-写一个二分查找)238.写一个二分查找

### [#](http://www.liuwq.com/views/面试题/python_01.html#_239-set-用-in-时间复杂度是多少，为什么？)239.set 用 in 时间复杂度是多少，为什么？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_240-列表中有n个正整数范围在-0，1000-，进行排序；)240.列表中有n个正整数范围在[0，1000]，进行排序；

### [#](http://www.liuwq.com/views/面试题/python_01.html#_241-面向对象编程中有组合和继承的方法实现新的类)241.面向对象编程中有组合和继承的方法实现新的类

## [#](http://www.liuwq.com/views/面试题/python_01.html#大数据)大数据

### [#](http://www.liuwq.com/views/面试题/python_01.html#_242-找出1g的文件中高频词)242.找出1G的文件中高频词

### [#](http://www.liuwq.com/views/面试题/python_01.html#_243-一个大约有一万行的文本文件统计高频词)243.一个大约有一万行的文本文件统计高频词

### [#](http://www.liuwq.com/views/面试题/python_01.html#_244-怎么在海量数据中找出重复次数最多的一个？)244.怎么在海量数据中找出重复次数最多的一个？

### [#](http://www.liuwq.com/views/面试题/python_01.html#_245-判断数据是否在大量数据中)245.判断数据是否在大量数据中

## [#](http://www.liuwq.com/views/面试题/python_01.html#架构)架构

### [#](http://www.liuwq.com/views/面试题/python_01.html#python后端架构演进)[Python后端架构演进](https://zhu327.github.io/2018/07/19/python后端架构演进/)

这篇文章几乎涵盖了python会用的架构，在面试可以手画架构图，根据自己的项目谈下技术选型和优劣，遇到的坑等。绝对加分



# Python语言特性

## 1 Python的函数参数传递

看两个例子:

```
a = 1
def fun(a):
    a = 2
fun(a)
print a  # 1
a = []
def fun(a):
    a.append(1)
fun(a)
print a  # [1]
```

所有的变量都可以理解是内存中一个对象的“引用”，或者，也可以看似c中void*的感觉。

通过`id`来看引用`a`的内存地址可以比较理解：

```
a = 1
def fun(a):
    print "func_in",id(a)   # func_in 41322472
    a = 2
    print "re-point",id(a), id(2)   # re-point 41322448 41322448
print "func_out",id(a), id(1)  # func_out 41322472 41322472
fun(a)
print a  # 1
```

注：具体的值在不同电脑上运行时可能不同。

可以看到，在执行完`a = 2`之后，`a`引用中保存的值，即内存地址发生变化，由原来`1`对象的所在的地址变成了`2`这个实体对象的内存地址。

而第2个例子`a`引用保存的内存值就不会发生变化：

```
a = []
def fun(a):
    print "func_in",id(a)  # func_in 53629256
    a.append(1)
print "func_out",id(a)     # func_out 53629256
fun(a)
print a  # [1]
```

这里记住的是类型是属于对象的，而不是变量。而对象有两种,“可更改”（mutable）与“不可更改”（immutable）对象。在python中，strings, tuples, 和numbers是不可更改的对象，而 list, dict, set 等则是可以修改的对象。(这就是这个问题的重点)

当一个引用传递给函数的时候,函数自动复制一份引用,这个函数里的引用和外边的引用没有半毛关系了.所以第一个例子里函数把引用指向了一个不可变对象,当函数返回的时候,外面的引用没半毛感觉.而第二个例子就不一样了,函数内的引用指向的是可变对象,对它的操作就和定位了指针地址一样,在内存里进行修改.

如果还不明白的话,这里有更好的解释: http://stackoverflow.com/questions/986006/how-do-i-pass-a-variable-by-reference

## 2 Python中的元类(metaclass)

这个非常的不常用,但是像ORM这种复杂的结构还是会需要的,详情请看:http://stackoverflow.com/questions/100003/what-is-a-metaclass-in-python

## 3 @staticmethod和@classmethod

Python其实有3个方法,即静态方法(staticmethod),类方法(classmethod)和实例方法,如下:

```
def foo(x):
    print "executing foo(%s)"%(x)

class A(object):
    def foo(self,x):
        print "executing foo(%s,%s)"%(self,x)

    @classmethod
    def class_foo(cls,x):
        print "executing class_foo(%s,%s)"%(cls,x)

    @staticmethod
    def static_foo(x):
        print "executing static_foo(%s)"%x

a=A()
```

这里先理解下函数参数里面的self和cls.这个self和cls是对类或者实例的绑定,对于一般的函数来说我们可以这么调用`foo(x)`,这个函数就是最常用的,它的工作跟任何东西(类,实例)无关.对于实例方法,我们知道在类里每次定义方法的时候都需要绑定这个实例,就是`foo(self, x)`,为什么要这么做呢?因为实例方法的调用离不开实例,我们需要把实例自己传给函数,调用的时候是这样的`a.foo(x)`(其实是`foo(a, x)`).类方法一样,只不过它传递的是类而不是实例,`A.class_foo(x)`.注意这里的self和cls可以替换别的参数,但是python的约定是这俩,还是不要改的好.

对于静态方法其实和普通的方法一样,不需要对谁进行绑定,唯一的区别是调用的时候需要使用`a.static_foo(x)`或者`A.static_foo(x)`来调用.

| \       | 实例方法 | 类方法         | 静态方法        |
| :------ | :------- | :------------- | :-------------- |
| a = A() | a.foo(x) | a.class_foo(x) | a.static_foo(x) |
| A       | 不可用   | A.class_foo(x) | A.static_foo(x) |

更多关于这个问题:

1. http://stackoverflow.com/questions/136097/what-is-the-difference-between-staticmethod-and-classmethod-in-python
2. https://realpython.com/blog/python/instance-class-and-static-methods-demystified/

## 4 类变量和实例变量

**类变量：**

>  是可在类的所有实例之间共享的值（也就是说，它们不是单独分配给每个实例的）。例如下例中，num_of_instance 就是类变量，用于跟踪存在着多少个Test 的实例。

**实例变量：**

> 实例化之后，每个实例单独拥有的变量。

```
class Test(object):  
    num_of_instance = 0  
    def __init__(self, name):  
        self.name = name  
        Test.num_of_instance += 1  
  
if __name__ == '__main__':  
    print Test.num_of_instance   # 0
    t1 = Test('jack')  
    print Test.num_of_instance   # 1
    t2 = Test('lucy')  
    print t1.name , t1.num_of_instance  # jack 2
    print t2.name , t2.num_of_instance  # lucy 2
```

> 补充的例子

```
class Person:
    name="aaa"

p1=Person()
p2=Person()
p1.name="bbb"
print p1.name  # bbb
print p2.name  # aaa
print Person.name  # aaa
```

这里`p1.name="bbb"`是实例调用了类变量,这其实和上面第一个问题一样,就是函数传参的问题,`p1.name`一开始是指向的类变量`name="aaa"`,但是在实例的作用域里把类变量的引用改变了,就变成了一个实例变量,self.name不再引用Person的类变量name了.

可以看看下面的例子:

```
class Person:
    name=[]

p1=Person()
p2=Person()
p1.name.append(1)
print p1.name  # [1]
print p2.name  # [1]
print Person.name  # [1]
```

参考:http://stackoverflow.com/questions/6470428/catch-multiple-exceptions-in-one-line-except-block

## 5 Python自省

这个也是python彪悍的特性.

自省就是面向对象的语言所写的程序在运行时,所能知道对象的类型.简单一句就是运行时能够获得对象的类型.比如type(),dir(),getattr(),hasattr(),isinstance().

```
a = [1,2,3]
b = {'a':1,'b':2,'c':3}
c = True
print type(a),type(b),type(c) # <type 'list'> <type 'dict'> <type 'bool'>
print isinstance(a,list)  # True
```

## 6 字典推导式

可能你见过列表推导时,却没有见过字典推导式,在2.7中才加入的:

```
d = {key: value for (key, value) in iterable}
```

## 7 Python中单下划线和双下划线

```
>>> class MyClass():
...     def __init__(self):
...             self.__superprivate = "Hello"
...             self._semiprivate = ", world!"
...
>>> mc = MyClass()
>>> print mc.__superprivate
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: myClass instance has no attribute '__superprivate'
>>> print mc._semiprivate
, world!
>>> print mc.__dict__
{'_MyClass__superprivate': 'Hello', '_semiprivate': ', world!'}
```

`__foo__`:一种约定,Python内部的名字,用来区别其他用户自定义的命名,以防冲突，就是例如`__init__()`,`__del__()`,`__call__()`这些特殊方法

`_foo`:一种约定,用来指定变量私有.程序员用来指定私有变量的一种方式.不能用from module import * 导入，其他方面和公有一样访问；

`__foo`:这个有真正的意义:解析器用`_classname__foo`来代替这个名字,以区别和其他类相同的命名,它无法直接像公有成员一样随便访问,通过对象名._类名__xxx这样的方式可以访问.

详情见:http://stackoverflow.com/questions/1301346/the-meaning-of-a-single-and-a-double-underscore-before-an-object-name-in-python

或者: http://www.zhihu.com/question/19754941

## 8 字符串格式化:%和.format

.format在许多方面看起来更便利.对于`%`最烦人的是它无法同时传递一个变量和元组.你可能会想下面的代码不会有什么问题:

```
"hi there %s" % name
```

但是,如果name恰好是(1,2,3),它将会抛出一个TypeError异常.为了保证它总是正确的,你必须这样做:

```
"hi there %s" % (name,)   # 提供一个单元素的数组而不是一个参数
```

但是有点丑..format就没有这些问题.你给的第二个问题也是这样,.format好看多了.

你为什么不用它?

- 不知道它(在读这个之前)
- 为了和Python2.5兼容(譬如logging库建议使用`%`([issue #4](https://github.com/taizilongxu/interview_python/issues/4)))

http://stackoverflow.com/questions/5082452/python-string-formatting-vs-format

## 9 迭代器和生成器

这个是stackoverflow里python排名第一的问题,值得一看: http://stackoverflow.com/questions/231767/what-does-the-yield-keyword-do-in-python

这是中文版: http://taizilongxu.gitbooks.io/stackoverflow-about-python/content/1/README.html

这里有个关于生成器的创建问题面试官有考：
问： 将列表生成式中[]改成() 之后数据结构是否改变？
答案：是，从列表变为生成器

```
>>> L = [x*x for x in range(10)]
>>> L
[0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
>>> g = (x*x for x in range(10))
>>> g
<generator object <genexpr> at 0x0000028F8B774200>
```

通过列表生成式，可以直接创建一个列表。但是，受到内存限制，列表容量肯定是有限的。而且，创建一个包含百万元素的列表，不仅是占用很大的内存空间，如：我们只需要访问前面的几个元素，后面大部分元素所占的空间都是浪费的。因此，没有必要创建完整的列表（节省大量内存空间）。在Python中，我们可以采用生成器：边循环，边计算的机制—>generator

## 10 `*args` and `**kwargs`

用`*args`和`**kwargs`只是为了方便并没有强制使用它们.

当你不确定你的函数里将要传递多少参数时你可以用`*args`.例如,它可以传递任意数量的参数:

```
>>> def print_everything(*args):
        for count, thing in enumerate(args):
...         print '{0}. {1}'.format(count, thing)
...
>>> print_everything('apple', 'banana', 'cabbage')
0. apple
1. banana
2. cabbage
```

相似的,`**kwargs`允许你使用没有事先定义的参数名:

```
>>> def table_things(**kwargs):
...     for name, value in kwargs.items():
...         print '{0} = {1}'.format(name, value)
...
>>> table_things(apple = 'fruit', cabbage = 'vegetable')
cabbage = vegetable
apple = fruit
```

你也可以混着用.命名参数首先获得参数值然后所有的其他参数都传递给`*args`和`**kwargs`.命名参数在列表的最前端.例如:

```
def table_things(titlestring, **kwargs)
```

`*args`和`**kwargs`可以同时在函数的定义中,但是`*args`必须在`**kwargs`前面.

当调用函数时你也可以用`*`和`**`语法.例如:

```
>>> def print_three_things(a, b, c):
...     print 'a = {0}, b = {1}, c = {2}'.format(a,b,c)
...
>>> mylist = ['aardvark', 'baboon', 'cat']
>>> print_three_things(*mylist)

a = aardvark, b = baboon, c = cat
```

就像你看到的一样,它可以传递列表(或者元组)的每一项并把它们解包.注意必须与它们在函数里的参数相吻合.当然,你也可以在函数定义或者函数调用时用*.

http://stackoverflow.com/questions/3394835/args-and-kwargs

## 11 面向切面编程AOP和装饰器

这个AOP一听起来有点懵,同学面阿里的时候就被问懵了...

装饰器是一个很著名的设计模式，经常被用于有切面需求的场景，较为经典的有插入日志、性能测试、事务处理等。装饰器是解决这类问题的绝佳设计，有了装饰器，我们就可以抽离出大量函数中与函数功能本身无关的雷同代码并继续重用。概括的讲，**装饰器的作用就是为已经存在的对象添加额外的功能。**

这个问题比较大,推荐: http://stackoverflow.com/questions/739654/how-can-i-make-a-chain-of-function-decorators-in-python

中文: http://taizilongxu.gitbooks.io/stackoverflow-about-python/content/3/README.html

## 12 鸭子类型

“当看到一只鸟走起来像鸭子、游泳起来像鸭子、叫起来也像鸭子，那么这只鸟就可以被称为鸭子。”

我们并不关心对象是什么类型，到底是不是鸭子，只关心行为。

比如在python中，有很多file-like的东西，比如StringIO,GzipFile,socket。它们有很多相同的方法，我们把它们当作文件使用。

又比如list.extend()方法中,我们并不关心它的参数是不是list,只要它是可迭代的,所以它的参数可以是list/tuple/dict/字符串/生成器等.

鸭子类型在动态语言中经常使用，非常灵活，使得python不想java那样专门去弄一大堆的设计模式。

## 13 Python中重载

引自知乎:http://www.zhihu.com/question/20053359

函数重载主要是为了解决两个问题。

1. 可变参数类型。
2. 可变参数个数。

另外，一个基本的设计原则是，仅仅当两个函数除了参数类型和参数个数不同以外，其功能是完全相同的，此时才使用函数重载，如果两个函数的功能其实不同，那么不应当使用重载，而应当使用一个名字不同的函数。

好吧，那么对于情况 1 ，函数功能相同，但是参数类型不同，python 如何处理？答案是根本不需要处理，因为 python 可以接受任何类型的参数，如果函数的功能相同，那么不同的参数类型在 python 中很可能是相同的代码，没有必要做成两个不同函数。

那么对于情况 2 ，函数功能相同，但参数个数不同，python 如何处理？大家知道，答案就是缺省参数。对那些缺少的参数设定为缺省参数即可解决问题。因为你假设函数功能相同，那么那些缺少的参数终归是需要用的。

好了，鉴于情况 1 跟 情况 2 都有了解决方案，python 自然就不需要函数重载了。

## 14 新式类和旧式类

这个面试官问了,我说了老半天,不知道他问的真正意图是什么.

[stackoverflow](http://stackoverflow.com/questions/54867/what-is-the-difference-between-old-style-and-new-style-classes-in-python)

这篇文章很好的介绍了新式类的特性: http://www.cnblogs.com/btchenguang/archive/2012/09/17/2689146.html

新式类很早在2.2就出现了,所以旧式类完全是兼容的问题,Python3里的类全部都是新式类.这里有一个MRO问题可以了解下(新式类继承是根据C3算法,旧式类是深度优先),<Python核心编程>里讲的也很多.

> 一个旧式类的深度优先的例子

```
class A():
    def foo1(self):
        print "A"
class B(A):
    def foo2(self):
        pass
class C(A):
    def foo1(self):
        print "C"
class D(B, C):
    pass

d = D()
d.foo1()

# A
```

**按照经典类的查找顺序从左到右深度优先的规则，在访问d.foo1()的时候,D这个类是没有的..那么往上查找,先找到B,里面没有,深度优先,访问A,找到了foo1(),所以这时候调用的是A的foo1()，从而导致C重写的foo1()被绕过**

## 15 `__new__`和`__init__`的区别

这个`__new__`确实很少见到,先做了解吧.

1. `__new__`是一个静态方法,而`__init__`是一个实例方法.
2. `__new__`方法会返回一个创建的实例,而`__init__`什么都不返回.
3. 只有在`__new__`返回一个cls的实例时后面的`__init__`才能被调用.
4. 当创建一个新实例时调用`__new__`,初始化一个实例时用`__init__`.

[stackoverflow](http://stackoverflow.com/questions/674304/pythons-use-of-new-and-init)

ps: `__metaclass__`是创建类时起作用.所以我们可以分别使用`__metaclass__`,`__new__`和`__init__`来分别在类创建,实例创建和实例初始化的时候做一些小手脚.

## 16 单例模式

>  单例模式是一种常用的软件设计模式。在它的核心结构中只包含一个被称为单例类的特殊类。通过单例模式可以保证系统中一个类只有一个实例而且该实例易于外界访问，从而方便对实例个数的控制并节约系统资源。如果希望在系统中某个类的对象只能存在一个，单例模式是最好的解决方案。
>
> `__new__()`在`__init__()`之前被调用，用于生成实例对象。利用这个方法和类的属性的特点可以实现设计模式的单例模式。单例模式是指创建唯一对象，单例模式设计的类只能实例
> **这个绝对常考啊.绝对要记住1~2个方法,当时面试官是让手写的.**

### 1 使用`__new__`方法

```
class Singleton(object):
    def __new__(cls, *args, **kw):
        if not hasattr(cls, '_instance'):
            orig = super(Singleton, cls)
            cls._instance = orig.__new__(cls, *args, **kw)
        return cls._instance

class MyClass(Singleton):
    a = 1
```

### 2 共享属性

创建实例时把所有实例的`__dict__`指向同一个字典,这样它们具有相同的属性和方法.

```
class Borg(object):
    _state = {}
    def __new__(cls, *args, **kw):
        ob = super(Borg, cls).__new__(cls, *args, **kw)
        ob.__dict__ = cls._state
        return ob

class MyClass2(Borg):
    a = 1
```

### 3 装饰器版本

```
def singleton(cls):
    instances = {}
    def getinstance(*args, **kw):
        if cls not in instances:
            instances[cls] = cls(*args, **kw)
        return instances[cls]
    return getinstance

@singleton
class MyClass:
  ...
```

### 4 import方法

作为python的模块是天然的单例模式

```
# mysingleton.py
class My_Singleton(object):
    def foo(self):
        pass

my_singleton = My_Singleton()

# to use
from mysingleton import my_singleton

my_singleton.foo()
```

**单例模式伯乐在线详细解释**

## 17 Python中的作用域

Python 中，一个变量的作用域总是由在代码中被赋值的地方所决定的。

当 Python 遇到一个变量的话他会按照这样的顺序进行搜索：

本地作用域（Local）→当前作用域被嵌入的本地作用域（Enclosing locals）→全局/模块作用域（Global）→内置作用域（Built-in）

## 18 GIL线程全局锁

线程全局锁(Global Interpreter Lock),即Python为了保证线程安全而采取的独立线程运行的限制,说白了就是一个核只能在同一时间运行一个线程.**对于io密集型任务，python的多线程起到作用，但对于cpu密集型任务，python的多线程几乎占不到任何优势，还有可能因为争夺资源而变慢。**

见[Python 最难的问题](http://www.oschina.net/translate/pythons-hardest-problem)

解决办法就是多进程和下面的协程(协程也只是单CPU,但是能减小切换代价提升性能).

## 19 协程

知乎被问到了,呵呵哒,跪了

简单点说协程是进程和线程的升级版,进程和线程都面临着内核态和用户态的切换问题而耗费许多切换时间,而协程就是用户自己控制切换的时机,不再需要陷入系统的内核态.

Python里最常见的yield就是协程的思想!可以查看第九个问题.

## 20 闭包

闭包(closure)是函数式编程的重要的语法结构。闭包也是一种组织代码的结构，它同样提高了代码的可重复使用性。

当一个内嵌函数引用其外部作作用域的变量,我们就会得到一个闭包. 总结一下,创建一个闭包必须满足以下几点:

1. 必须有一个内嵌函数
2. 内嵌函数必须引用外部函数中的变量
3. 外部函数的返回值必须是内嵌函数

感觉闭包还是有难度的,几句话是说不明白的,还是查查相关资料.

重点是函数运行后并不会被撤销,就像16题的instance字典一样,当函数运行完后,instance并不被销毁,而是继续留在内存空间里.这个功能类似类里的类变量,只不过迁移到了函数上.

闭包就像个空心球一样,你知道外面和里面,但你不知道中间是什么样.

## 21 lambda函数

其实就是一个匿名函数,为什么叫lambda?因为和后面的函数式编程有关.

推荐: [知乎](http://www.zhihu.com/question/20125256)

## 22 Python函数式编程

这个需要适当的了解一下吧,毕竟函数式编程在Python中也做了引用.

推荐: [酷壳](http://coolshell.cn/articles/10822.html)

python中函数式编程支持:

filter 函数的功能相当于过滤器。调用一个布尔函数`bool_func`来迭代遍历每个seq中的元素；返回一个使`bool_seq`返回值为true的元素的序列。

```
>>>a = [1,2,3,4,5,6,7]
>>>b = filter(lambda x: x > 5, a)
>>>print b
>>>[6,7]
```

map函数是对一个序列的每个项依次执行函数，下面是对一个序列每个项都乘以2：

```
>>> a = map(lambda x:x*2,[1,2,3])
>>> list(a)
[2, 4, 6]
```

reduce函数是对一个序列的每个项迭代调用函数，下面是求3的阶乘：

```
>>> reduce(lambda x,y:x*y,range(1,4))
6
```

## 23 Python里的拷贝

引用和copy(),deepcopy()的区别

```
import copy
a = [1, 2, 3, 4, ['a', 'b']]  #原始对象

b = a  #赋值，传对象的引用
c = copy.copy(a)  #对象拷贝，浅拷贝
d = copy.deepcopy(a)  #对象拷贝，深拷贝

a.append(5)  #修改对象a
a[4].append('c')  #修改对象a中的['a', 'b']数组对象

print 'a = ', a
print 'b = ', b
print 'c = ', c
print 'd = ', d

输出结果：
a =  [1, 2, 3, 4, ['a', 'b', 'c'], 5]
b =  [1, 2, 3, 4, ['a', 'b', 'c'], 5]
c =  [1, 2, 3, 4, ['a', 'b', 'c']]
d =  [1, 2, 3, 4, ['a', 'b']]
```

## 24 Python垃圾回收机制

Python GC主要使用引用计数（reference counting）来跟踪和回收垃圾。在引用计数的基础上，通过“标记-清除”（mark and sweep）解决容器对象可能产生的循环引用问题，通过“分代回收”（generation collection）以空间换时间的方法提高垃圾回收效率。

### 1 引用计数

PyObject是每个对象必有的内容，其中`ob_refcnt`就是做为引用计数。当一个对象有新的引用时，它的`ob_refcnt`就会增加，当引用它的对象被删除，它的`ob_refcnt`就会减少.引用计数为0时，该对象生命就结束了。

优点:

1. 简单
2. 实时性

缺点:

1. 维护引用计数消耗资源
2. 循环引用

### 2 标记-清除机制

基本思路是先按需分配，等到没有空闲内存的时候从寄存器和程序栈上的引用出发，遍历以对象为节点、以引用为边构成的图，把所有可以访问到的对象打上标记，然后清扫一遍内存空间，把所有没标记的对象释放。

### 3 分代技术

分代回收的整体思想是：将系统中的所有内存块根据其存活时间划分为不同的集合，每个集合就成为一个“代”，垃圾收集频率随着“代”的存活时间的增大而减小，存活时间通常利用经过几次垃圾回收来度量。

Python默认定义了三代对象集合，索引数越大，对象存活时间越长。

举例：
当某些内存块M经过了3次垃圾收集的清洗之后还存活时，我们就将内存块M划到一个集合A中去，而新分配的内存都划分到集合B中去。当垃圾收集开始工作时，大多数情况都只对集合B进行垃圾回收，而对集合A进行垃圾回收要隔相当长一段时间后才进行，这就使得垃圾收集机制需要处理的内存少了，效率自然就提高了。在这个过程中，集合B中的某些内存块由于存活时间长而会被转移到集合A中，当然，集合A中实际上也存在一些垃圾，这些垃圾的回收会因为这种分代的机制而被延迟。

## 25 Python的List

推荐: http://www.jianshu.com/p/J4U6rR

## 26 Python的is

is是对比地址,==是对比值

## 27 read,readline和readlines

- read 读取整个文件
- readline 读取下一行,使用生成器方法
- readlines 读取整个文件到一个迭代器以供我们遍历

## 28 Python2和3的区别

推荐：[Python 2.7.x 与 Python 3.x 的主要差异](http://chenqx.github.io/2014/11/10/Key-differences-between-Python-2-7-x-and-Python-3-x/)

## 29 super init

super() lets you avoid referring to the base class explicitly, which can be nice. But the main advantage comes with multiple inheritance, where all sorts of fun stuff can happen. See the standard docs on super if you haven't already.

Note that the syntax changed in Python 3.0: you can just say super().`__init__`() instead of super(ChildB, self).`__init__`() which IMO is quite a bit nicer.

http://stackoverflow.com/questions/576169/understanding-python-super-with-init-methods

[Python2.7中的super方法浅见](http://blog.csdn.net/mrlevo520/article/details/51712440)

## 30 range and xrange

都在循环时使用，xrange内存性能更好。
for i in range(0, 20):
for i in xrange(0, 20):
What is the difference between range and xrange functions in Python 2.X?
range creates a list, so if you do range(1, 10000000) it creates a list in memory with 9999999 elements.
xrange is a sequence object that evaluates lazily.

http://stackoverflow.com/questions/94935/what-is-the-difference-between-range-and-xrange-functions-in-python-2-x

# 操作系统

## 1 select,poll和epoll

其实所有的I/O都是轮询的方法,只不过实现的层面不同罢了.

这个问题可能有点深入了,但相信能回答出这个问题是对I/O多路复用有很好的了解了.其中tornado使用的就是epoll的.

[selec,poll和epoll区别总结](http://www.cnblogs.com/Anker/p/3265058.html)



基本上select有3个缺点:

1. 连接数受限
2. 查找配对速度慢
3. 数据由内核拷贝到用户态

poll改善了第一个缺点

epoll改了三个缺点.

关于epoll的: http://www.cnblogs.com/my_life/articles/3968782.html

## 2 调度算法

1. 先来先服务(FCFS, First Come First Serve)
2. 短作业优先(SJF, Shortest Job First)
3. 最高优先权调度(Priority Scheduling)
4. 时间片轮转(RR, Round Robin)
5. 多级反馈队列调度(multilevel feedback queue scheduling)

常见的调度算法总结:http://www.jianshu.com/p/6edf8174c1eb

实时调度算法:

1. 最早截至时间优先 EDF
2. 最低松弛度优先 LLF

## 3 死锁

原因:

1. 竞争资源
2. 程序推进顺序不当

必要条件:

1. 互斥条件
2. 请求和保持条件
3. 不剥夺条件
4. 环路等待条件

处理死锁基本方法:

1. 预防死锁(摒弃除1以外的条件)
2. 避免死锁(银行家算法)
3. 检测死锁(资源分配图)
4. 解除死锁
    1. 剥夺资源
    2. 撤销进程

死锁概念处理策略详细介绍:https://wizardforcel.gitbooks.io/wangdaokaoyan-os/content/10.html

## 4 程序编译与链接

推荐: http://www.ruanyifeng.com/blog/2014/11/compiler.html

Bulid过程可以分解为4个步骤:预处理(Prepressing), 编译(Compilation)、汇编(Assembly)、链接(Linking)

以c语言为例:

### 1 预处理

预编译过程主要处理那些源文件中的以“#”开始的预编译指令，主要处理规则有：

1. 将所有的“#define”删除，并展开所用的宏定义
2. 处理所有条件预编译指令，比如“#if”、“#ifdef”、 “#elif”、“#endif”
3. 处理“#include”预编译指令，将被包含的文件插入到该编译指令的位置，注：此过程是递归进行的
4. 删除所有注释
5. 添加行号和文件名标识，以便于编译时编译器产生调试用的行号信息以及用于编译时产生编译错误或警告时可显示行号
6. 保留所有的#pragma编译器指令。

### 2 编译

编译过程就是把预处理完的文件进行一系列的词法分析、语法分析、语义分析及优化后生成相应的汇编代码文件。这个过程是整个程序构建的核心部分。

### 3 汇编

汇编器是将汇编代码转化成机器可以执行的指令，每一条汇编语句几乎都是一条机器指令。经过编译、链接、汇编输出的文件成为目标文件(Object File)

### 4 链接

链接的主要内容就是把各个模块之间相互引用的部分处理好，使各个模块可以正确的拼接。
链接的主要过程包块 地址和空间的分配（Address and Storage Allocation）、符号决议(Symbol Resolution)和重定位(Relocation)等步骤。

## 5 静态链接和动态链接

静态链接方法：静态链接的时候，载入代码就会把程序会用到的动态代码或动态代码的地址确定下来
静态库的链接可以使用静态链接，动态链接库也可以使用这种方法链接导入库

动态链接方法：使用这种方式的程序并不在一开始就完成动态链接，而是直到真正调用动态库代码时，载入程序才计算(被调用的那部分)动态代码的逻辑地址，然后等到某个时候，程序又需要调用另外某块动态代码时，载入程序又去计算这部分代码的逻辑地址，所以，这种方式使程序初始化时间较短，但运行期间的性能比不上静态链接的程序

## 6 虚拟内存技术

虚拟存储器是指具有请求调入功能和置换功能,能从逻辑上对内存容量加以扩充的一种存储系统.

## 7 分页和分段

分页: 用户程序的地址空间被划分成若干固定大小的区域，称为“页”，相应地，内存空间分成若干个物理块，页和块的大小相等。可将用户程序的任一页放在内存的任一块中，实现了离散分配。

分段: 将用户程序地址空间分成若干个大小不等的段，每段可以定义一组相对完整的逻辑信息。存储分配时，以段为单位，段与段在内存中可以不相邻接，也实现了离散分配。

### 分页与分段的主要区别

1. 页是信息的物理单位,分页是为了实现非连续分配,以便解决内存碎片问题,或者说分页是由于系统管理的需要.段是信息的逻辑单位,它含有一组意义相对完整的信息,分段的目的是为了更好地实现共享,满足用户的需要.
2. 页的大小固定,由系统确定,将逻辑地址划分为页号和页内地址是由机器硬件实现的.而段的长度却不固定,决定于用户所编写的程序,通常由编译程序在对源程序进行编译时根据信息的性质来划分.
3. 分页的作业地址空间是一维的.分段的地址空间是二维的.

## 8 页面置换算法

1. 最佳置换算法OPT:不可能实现
2. 先进先出FIFO
3. 最近最久未使用算法LRU:最近一段时间里最久没有使用过的页面予以置换.
4. clock算法

## 9 边沿触发和水平触发

边缘触发是指每当状态变化时发生一个 io 事件，条件触发是只要满足条件就发生一个 io 事件

# 数据库

## 1 事务

数据库事务(Database Transaction) ，是指作为单个逻辑工作单元执行的一系列操作，要么完全地执行，要么完全地不执行。
彻底理解数据库事务: http://www.hollischuang.com/archives/898

## 2 数据库索引

推荐: http://tech.meituan.com/mysql-index.html

[MySQL索引背后的数据结构及算法原理](http://blog.codinglabs.org/articles/theory-of-mysql-index.html)

聚集索引,非聚集索引,B-Tree,B+Tree,最左前缀原理

## 3 Redis原理

### Redis是什么？

1. 是一个完全开源免费的key-value内存数据库
2. 通常被认为是一个数据结构服务器，主要是因为其有着丰富的数据结构 strings、map、 list、sets、 sorted sets

### Redis数据库

>  通常局限点来说，Redis也以消息队列的形式存在，作为内嵌的List存在，满足实时的高并发需求。在使用缓存的时候，redis比memcached具有更多的优势，并且支持更多的数据类型，把redis当作一个中间存储系统，用来处理高并发的数据库操作

- 速度快：使用标准C写，所有数据都在内存中完成，读写速度分别达到10万/20万
- 持久化：对数据的更新采用Copy-on-write技术，可以异步地保存到磁盘上，主要有两种策略，一是根据时间，更新次数的快照（save 300 10 ）二是基于语句追加方式(Append-only file，aof)
- 自动操作：对不同数据类型的操作都是自动的，很安全
- 快速的主--从复制，官方提供了一个数据，Slave在21秒即完成了对Amazon网站10G key set的复制。
- Sharding技术： 很容易将数据分布到多个Redis实例中，数据库的扩展是个永恒的话题，在关系型数据库中，主要是以添加硬件、以分区为主要技术形式的纵向扩展解决了很多的应用场景，但随着web2.0、移动互联网、云计算等应用的兴起，这种扩展模式已经不太适合了，所以近年来，像采用主从配置、数据库复制形式的，Sharding这种技术把负载分布到多个特理节点上去的横向扩展方式用处越来越多。

### Redis缺点

- 是数据库容量受到物理内存的限制,不能用作海量数据的高性能读写,因此Redis适合的场景主要局限在较小数据量的高性能操作和运算上。
- Redis较难支持在线扩容，在集群容量达到上限时在线扩容会变得很复杂。为避免这一问题，运维人员在系统上线时必须确保有足够的空间，这对资源造成了很大的浪费。

## 4 乐观锁和悲观锁

悲观锁：假定会发生并发冲突，屏蔽一切可能违反数据完整性的操作

乐观锁：假设不会发生并发冲突，只在提交操作时检查是否违反数据完整性。

乐观锁与悲观锁的具体区别: http://www.cnblogs.com/Bob-FD/p/3352216.html

## 5 MVCC

>  全称是Multi-Version Concurrent Control，即多版本并发控制，在MVCC协议下，每个读操作会看到一个一致性的snapshot，并且可以实现非阻塞的读。MVCC允许数据具有多个版本，这个版本可以是时间戳或者是全局递增的事务ID，在同一个时间点，不同的事务看到的数据是不同的。

### [MySQL](http://lib.csdn.net/base/mysql)的innodb引擎是如何实现MVCC的

innodb会为每一行添加两个字段，分别表示该行**创建的版本**和**删除的版本**，填入的是事务的版本号，这个版本号随着事务的创建不断递增。在repeated read的隔离级别（[事务的隔离级别请看这篇文章](http://blog.csdn.net/chosen0ne/article/details/10036775)）下，具体各种数据库操作的实现：

- select：满足以下两个条件innodb会返回该行数据：
    - 该行的创建版本号小于等于当前版本号，用于保证在select操作之前所有的操作已经执行落地。
    - 该行的删除版本号大于当前版本或者为空。删除版本号大于当前版本意味着有一个并发事务将该行删除了。
- insert：将新插入的行的创建版本号设置为当前系统的版本号。
- delete：将要删除的行的删除版本号设置为当前系统的版本号。
- update：不执行原地update，而是转换成insert + delete。将旧行的删除版本号设置为当前版本号，并将新行insert同时设置创建版本号为当前版本号。

其中，写操作（insert、delete和update）执行时，需要将系统版本号递增。

 由于旧数据并不真正的删除，所以必须对这些数据进行清理，innodb会开启一个后台线程执行清理工作，具体的规则是将删除版本号小于当前系统版本的行删除，这个过程叫做purge。

通过MVCC很好的实现了事务的隔离性，可以达到repeated read级别，要实现serializable还必须加锁。

> 参考：[MVCC浅析](http://blog.csdn.net/chosen0ne/article/details/18093187)

## 6 MyISAM和InnoDB

MyISAM 适合于一些需要大量查询的应用，但其对于有大量写操作并不是很好。甚至你只是需要update一个字段，整个表都会被锁起来，而别的进程，就算是读进程都无法操作直到读操作完成。另外，MyISAM 对于 SELECT COUNT(*) 这类的计算是超快无比的。

InnoDB 的趋势会是一个非常复杂的存储引擎，对于一些小的应用，它会比 MyISAM 还慢。他是它支持“行锁” ，于是在写操作比较多的时候，会更优秀。并且，他还支持更多的高级应用，比如：事务。

mysql 数据库引擎: http://www.cnblogs.com/0201zcr/p/5296843.html
MySQL存储引擎－－MyISAM与InnoDB区别: https://segmentfault.com/a/1190000008227211

# 网络

## 1 三次握手

1. 客户端通过向服务器端发送一个SYN来创建一个主动打开，作为三次握手的一部分。客户端把这段连接的序号设定为随机数 A。
2. 服务器端应当为一个合法的SYN回送一个SYN/ACK。ACK 的确认码应为 A+1，SYN/ACK 包本身又有一个随机序号 B。
3. 最后，客户端再发送一个ACK。当服务端受到这个ACK的时候，就完成了三路握手，并进入了连接创建状态。此时包序号被设定为收到的确认号 A+1，而响应则为 B+1。

## 2 四次挥手

*注意: 中断连接端可以是客户端，也可以是服务器端. 下面仅以客户端断开连接举例, 反之亦然.*

1. 客户端发送一个数据分段, 其中的 FIN 标记设置为1. 客户端进入 FIN-WAIT 状态. 该状态下客户端只接收数据, 不再发送数据.
2. 服务器接收到带有 FIN = 1 的数据分段, 发送带有 ACK = 1 的剩余数据分段, 确认收到客户端发来的 FIN 信息.
3. 服务器等到所有数据传输结束, 向客户端发送一个带有 FIN = 1 的数据分段, 并进入 CLOSE-WAIT 状态, 等待客户端发来带有 ACK = 1 的确认报文.
4. 客户端收到服务器发来带有 FIN = 1 的报文, 返回 ACK = 1 的报文确认, 为了防止服务器端未收到需要重发, 进入 TIME-WAIT 状态. 服务器接收到报文后关闭连接. 客户端等待 2MSL 后未收到回复, 则认为服务器成功关闭, 客户端关闭连接.

图解: http://blog.csdn.net/whuslei/article/details/6667471

## 3 ARP协议

地址解析协议(Address Resolution Protocol)，其基本功能为透过目标设备的IP地址，查询目标的MAC地址，以保证通信的顺利进行。它是IPv4网络层必不可少的协议，不过在IPv6中已不再适用，并被邻居发现协议（NDP）所替代。

## 4 urllib和urllib2的区别

这个面试官确实问过,当时答的urllib2可以Post而urllib不可以.

1. urllib提供urlencode方法用来GET查询字符串的产生，而urllib2没有。这是为何urllib常和urllib2一起使用的原因。
2. urllib2可以接受一个Request类的实例来设置URL请求的headers，urllib仅可以接受URL。这意味着，你不可以伪装你的User Agent字符串等。

## 5 Post和Get

[GET和POST有什么区别？及为什么网上的多数答案都是错的](http://www.cnblogs.com/nankezhishi/archive/2012/06/09/getandpost.html)

[知乎回答](https://www.zhihu.com/question/31640769?rf=37401322)

get: [RFC 2616 - Hypertext Transfer Protocol -- HTTP/1.1](http://tools.ietf.org/html/rfc2616#section-9.3)
post: [RFC 2616 - Hypertext Transfer Protocol -- HTTP/1.1](http://tools.ietf.org/html/rfc2616#section-9.5)

## 6 Cookie和Session

|          | Cookie                                               | Session  |
| :------- | :--------------------------------------------------- | :------- |
| 储存位置 | 客户端                                               | 服务器端 |
| 目的     | 跟踪会话，也可以保存用户偏好设置或者保存用户名密码等 | 跟踪会话 |
| 安全性   | 不安全                                               | 安全     |

session技术是要使用到cookie的，之所以出现session技术，主要是为了安全。

## 7 apache和nginx的区别

nginx 相对 apache 的优点：

- 轻量级，同样起web 服务，比apache 占用更少的内存及资源
- 抗并发，nginx 处理请求是异步非阻塞的，支持更多的并发连接，而apache 则是阻塞型的，在高并发下nginx 能保持低资源低消耗高性能
- 配置简洁
- 高度模块化的设计，编写模块相对简单
- 社区活跃

apache 相对nginx 的优点：

- rewrite ，比nginx 的rewrite 强大
- 模块超多，基本想到的都可以找到
- 少bug ，nginx 的bug 相对较多
- 超稳定

## 8 网站用户密码保存

1. 明文保存
2. 明文hash后保存,如md5
3. MD5+Salt方式,这个salt可以随机
4. 知乎使用了Bcrypy(好像)加密

## 9 HTTP和HTTPS

| 状态码         | 定义                            |
| :------------- | :------------------------------ |
| 1xx 报告       | 接收到请求，继续进程            |
| 2xx 成功       | 步骤成功接收，被理解，并被接受  |
| 3xx 重定向     | 为了完成请求,必须采取进一步措施 |
| 4xx 客户端出错 | 请求包括错的顺序或不能完成      |
| 5xx 服务器出错 | 服务器无法完成显然有效的请求    |

403: Forbidden
404: Not Found

HTTPS握手,对称加密,非对称加密,TLS/SSL,RSA

## 10 XSRF和XSS

- CSRF(Cross-site request forgery)跨站请求伪造
- XSS(Cross Site Scripting)跨站脚本攻击

CSRF重点在请求,XSS重点在脚本

## 11 幂等 Idempotence

HTTP方法的幂等性是指一次和多次请求某一个资源应该具有同样的**副作用**。(注意是副作用)

`GET http://www.bank.com/account/123456`，不会改变资源的状态，不论调用一次还是N次都没有副作用。请注意，这里强调的是一次和N次具有相同的副作用，而不是每次GET的结果相同。`GET http://www.news.com/latest-news`这个HTTP请求可能会每次得到不同的结果，但它本身并没有产生任何副作用，因而是满足幂等性的。

DELETE方法用于删除资源，有副作用，但它应该满足幂等性。比如：`DELETE http://www.forum.com/article/4231`，调用一次和N次对系统产生的副作用是相同的，即删掉id为4231的帖子；因此，调用者可以多次调用或刷新页面而不必担心引起错误。

POST所对应的URI并非创建的资源本身，而是资源的接收者。比如：`POST http://www.forum.com/articles`的语义是在`http://www.forum.com/articles`下创建一篇帖子，HTTP响应中应包含帖子的创建状态以及帖子的URI。两次相同的POST请求会在服务器端创建两份资源，它们具有不同的URI；所以，POST方法不具备幂等性。

PUT所对应的URI是要创建或更新的资源本身。比如：`PUT http://www.forum/articles/4231`的语义是创建或更新ID为4231的帖子。对同一URI进行多次PUT的副作用和一次PUT是相同的；因此，PUT方法具有幂等性。

## 12 RESTful架构(SOAP,RPC)

推荐: http://www.ruanyifeng.com/blog/2011/09/restful.html

## 13 SOAP

SOAP（原为Simple Object Access Protocol的首字母缩写，即简单对象访问协议）是交换数据的一种协议规范，使用在计算机网络Web服务（web service）中，交换带结构信息。SOAP为了简化网页服务器（Web Server）从XML数据库中提取数据时，节省去格式化页面时间，以及不同应用程序之间按照HTTP通信协议，遵从XML格式执行资料互换，使其抽象于语言实现、平台和硬件。

## 14 RPC

RPC（Remote Procedure Call Protocol）——远程过程调用协议，它是一种通过网络从远程计算机程序上请求服务，而不需要了解底层网络技术的协议。RPC协议假定某些传输协议的存在，如TCP或UDP，为通信程序之间携带信息数据。在OSI网络通信模型中，RPC跨越了传输层和应用层。RPC使得开发包括网络分布式多程序在内的应用程序更加容易。

总结:服务提供的两大流派.传统意义以方法调用为导向通称RPC。为了企业SOA,若干厂商联合推出webservice,制定了wsdl接口定义,传输soap.当互联网时代,臃肿SOA被简化为http+xml/json.但是简化出现各种混乱。以资源为导向,任何操作无非是对资源的增删改查，于是统一的REST出现了.

进化的顺序: RPC -> SOAP -> RESTful

## 15 CGI和WSGI

CGI是通用网关接口，是连接web服务器和应用程序的接口，用户通过CGI来获取动态数据或文件等。
CGI程序是一个独立的程序，它可以用几乎所有语言来写，包括perl，c，lua，python等等。

WSGI, Web Server Gateway Interface，是Python应用程序或框架和Web服务器之间的一种接口，WSGI的其中一个目的就是让用户可以用统一的语言(Python)编写前后端。

官方说明：[PEP-3333](https://www.python.org/dev/peps/pep-3333/)

## 16 中间人攻击

在GFW里屡见不鲜的,呵呵.

中间人攻击（Man-in-the-middle attack，通常缩写为MITM）是指攻击者与通讯的两端分别创建独立的联系，并交换其所收到的数据，使通讯的两端认为他们正在通过一个私密的连接与对方直接对话，但事实上整个会话都被攻击者完全控制。

## 17 c10k问题

所谓c10k问题，指的是服务器同时支持成千上万个客户端的问题，也就是concurrent 10 000 connection（这也是c10k这个名字的由来）。
推荐: https://my.oschina.net/xianggao/blog/664275

## 18 socket

推荐: http://www.360doc.com/content/11/0609/15/5482098_122692444.shtml

Socket=Ip address+ TCP/UDP + port

## 19 浏览器缓存

推荐: http://www.cnblogs.com/skynet/archive/2012/11/28/2792503.html

304 Not Modified

## 20 HTTP1.0和HTTP1.1

推荐: http://blog.csdn.net/elifefly/article/details/3964766

1. 请求头Host字段,一个服务器多个网站
2. 长链接
3. 文件断点续传
4. 身份认证,状态管理,Cache缓存

HTTP请求8种方法介绍
HTTP/1.1协议中共定义了8种HTTP请求方法，HTTP请求方法也被叫做“请求动作”，不同的方法规定了不同的操作指定的资源方式。服务端也会根据不同的请求方法做不同的响应。

GET

GET请求会显示请求指定的资源。一般来说GET方法应该只用于数据的读取，而不应当用于会产生副作用的非幂等的操作中。

GET会方法请求指定的页面信息，并返回响应主体，GET被认为是不安全的方法，因为GET方法会被网络蜘蛛等任意的访问。

HEAD

HEAD方法与GET方法一样，都是向服务器发出指定资源的请求。但是，服务器在响应HEAD请求时不会回传资源的内容部分，即：响应主体。这样，我们可以不传输全部内容的情况下，就可以获取服务器的响应头信息。HEAD方法常被用于客户端查看服务器的性能。

POST

POST请求会 向指定资源提交数据，请求服务器进行处理，如：表单数据提交、文件上传等，请求数据会被包含在请求体中。POST方法是非幂等的方法，因为这个请求可能会创建新的资源或/和修改现有资源。

PUT

PUT请求会身向指定资源位置上传其最新内容，PUT方法是幂等的方法。通过该方法客户端可以将指定资源的最新数据传送给服务器取代指定的资源的内容。

DELETE

DELETE请求用于请求服务器删除所请求URI（统一资源标识符，Uniform Resource Identifier）所标识的资源。DELETE请求后指定资源会被删除，DELETE方法也是幂等的。

CONNECT

CONNECT方法是HTTP/1.1协议预留的，能够将连接改为管道方式的代理服务器。通常用于SSL加密服务器的链接与非加密的HTTP代理服务器的通信。

OPTIONS

OPTIONS请求与HEAD类似，一般也是用于客户端查看服务器的性能。 这个方法会请求服务器返回该资源所支持的所有HTTP请求方法，该方法会用’*’来代替资源名称，向服务器发送OPTIONS请求，可以测试服务器功能是否正常。JavaScript的XMLHttpRequest对象进行CORS跨域资源共享时，就是使用OPTIONS方法发送嗅探请求，以判断是否有对指定资源的访问权限。 允许

TRACE

TRACE请求服务器回显其收到的请求信息，该方法主要用于HTTP请求的测试或诊断。

HTTP/1.1之后增加的方法

在HTTP/1.1标准制定之后，又陆续扩展了一些方法。其中使用中较多的是 PATCH 方法：

PATCH

PATCH方法出现的较晚，它在2010年的RFC 5789标准中被定义。PATCH请求与PUT请求类似，同样用于资源的更新。二者有以下两点不同：

但PATCH一般用于资源的部分更新，而PUT一般用于资源的整体更新。
当资源不存在时，PATCH会创建一个新的资源，而PUT只会对已在资源进行更新。

## 21 Ajax

AJAX,Asynchronous JavaScript and XML（异步的 JavaScript 和 XML）, 是与在不重新加载整个页面的情况下，与服务器交换数据并更新部分网页的技术。

# UNIX

## unix进程间通信方式(IPC)

1. 管道（Pipe）：管道可用于具有亲缘关系进程间的通信，允许一个进程和另一个与它有共同祖先的进程之间进行通信。
2. 命名管道（named pipe）：命名管道克服了管道没有名字的限制，因此，除具有管道所具有的功能外，它还允许无亲缘关系进程间的通信。命名管道在文件系统中有对应的文件名。命名管道通过命令mkfifo或系统调用mkfifo来创建。
3. 信号（Signal）：信号是比较复杂的通信方式，用于通知接受进程有某种事件发生，除了用于进程间通信外，进程还可以发送信号给进程本身；linux除了支持Unix早期信号语义函数sigal外，还支持语义符合Posix.1标准的信号函数sigaction（实际上，该函数是基于BSD的，BSD为了实现可靠信号机制，又能够统一对外接口，用sigaction函数重新实现了signal函数）。
4. 消息（Message）队列：消息队列是消息的链接表，包括Posix消息队列system V消息队列。有足够权限的进程可以向队列中添加消息，被赋予读权限的进程则可以读走队列中的消息。消息队列克服了信号承载信息量少，管道只能承载无格式字节流以及缓冲区大小受限等缺
5. 共享内存：使得多个进程可以访问同一块内存空间，是最快的可用IPC形式。是针对其他通信机制运行效率较低而设计的。往往与其它通信机制，如信号量结合使用，来达到进程间的同步及互斥。
6. 内存映射（mapped memory）：内存映射允许任何多个进程间通信，每一个使用该机制的进程通过把一个共享的文件映射到自己的进程地址空间来实现它。
7. 信号量（semaphore）：主要作为进程间以及同一进程不同线程之间的同步手段。
8. 套接口（Socket）：更为一般的进程间通信机制，可用于不同机器之间的进程间通信。起初是由Unix系统的BSD分支开发出来的，但现在一般可以移植到其它类Unix系统上：Linux和System V的变种都支持套接字。

# 数据结构

## 1 红黑树

红黑树与AVL的比较：

AVL是严格平衡树，因此在增加或者删除节点的时候，根据不同情况，旋转的次数比红黑树要多；

红黑是用非严格的平衡来换取增删节点时候旋转次数的降低；

所以简单说，如果你的应用中，搜索的次数远远大于插入和删除，那么选择AVL，如果搜索，插入删除次数几乎差不多，应该选择RB。

红黑树详解: https://xieguanglei.github.io/blog/post/red-black-tree.html

教你透彻了解红黑树: https://github.com/julycoding/The-Art-Of-Programming-By-July/blob/master/ebook/zh/03.01.md

# 编程题

## 1 台阶问题/斐波那契

一只青蛙一次可以跳上1级台阶，也可以跳上2级。求该青蛙跳上一个n级的台阶总共有多少种跳法。

```
fib = lambda n: n if n <= 2 else fib(n - 1) + fib(n - 2)
```

第二种记忆方法

```
def memo(func):
    cache = {}
    def wrap(*args):
        if args not in cache:
            cache[args] = func(*args)
        return cache[args]
    return wrap


@memo
def fib(i):
    if i < 2:
        return 1
    return fib(i-1) + fib(i-2)
```

第三种方法

```
def fib(n):
    a, b = 0, 1
    for _ in xrange(n):
        a, b = b, a + b
    return b
```

## 2 变态台阶问题

一只青蛙一次可以跳上1级台阶，也可以跳上2级……它也可以跳上n级。求该青蛙跳上一个n级的台阶总共有多少种跳法。

```
fib = lambda n: n if n < 2 else 2 * fib(n - 1)
```

## 3 矩形覆盖

我们可以用`2*1`的小矩形横着或者竖着去覆盖更大的矩形。请问用n个`2*1`的小矩形无重叠地覆盖一个`2*n`的大矩形，总共有多少种方法？

> 第`2*n`个矩形的覆盖方法等于第`2*(n-1)`加上第`2*(n-2)`的方法。

```
f = lambda n: 1 if n < 2 else f(n - 1) + f(n - 2)
```

## 4 杨氏矩阵查找

在一个m行n列二维数组中，每一行都按照从左到右递增的顺序排序，每一列都按照从上到下递增的顺序排序。请完成一个函数，输入这样的一个二维数组和一个整数，判断数组中是否含有该整数。

使用Step-wise线性搜索。

```
def get_value(l, r, c):
    return l[r][c]

def find(l, x):
    m = len(l) - 1
    n = len(l[0]) - 1
    r = 0
    c = n
    while c >= 0 and r <= m:
        value = get_value(l, r, c)
        if value == x:
            return True
        elif value > x:
            c = c - 1
        elif value < x:
            r = r + 1
    return False
```

## 5 去除列表中的重复元素

用集合

```
list(set(l))
```

用字典

```
l1 = ['b','c','d','b','c','a','a']
l2 = {}.fromkeys(l1).keys()
print l2
```

用字典并保持顺序

```
l1 = ['b','c','d','b','c','a','a']
l2 = list(set(l1))
l2.sort(key=l1.index)
print l2
```

列表推导式

```
l1 = ['b','c','d','b','c','a','a']
l2 = []
[l2.append(i) for i in l1 if not i in l2]
```

sorted排序并且用列表推导式.

l = ['b','c','d','b','c','a','a']

[single.append(i) for i in sorted(l) if i not in single]
print single

## 6 链表成对调换

`1->2->3->4`转换成`2->1->4->3`.

```
class ListNode:
    def __init__(self, x):
        self.val = x
        self.next = None

class Solution:
    # @param a ListNode
    # @return a ListNode
    def swapPairs(self, head):
        if head != None and head.next != None:
            next = head.next
            head.next = self.swapPairs(next.next)
            next.next = head
            return next
        return head
```

## 7 创建字典的方法

### 1 直接创建

```
dict = {'name':'earth', 'port':'80'}
```

### 2 工厂方法

```
items=[('name','earth'),('port','80')]
dict2=dict(items)
dict1=dict((['name','earth'],['port','80']))
```

### 3 fromkeys()方法

```
dict1={}.fromkeys(('x','y'),-1)
dict={'x':-1,'y':-1}
dict2={}.fromkeys(('x','y'))
dict2={'x':None, 'y':None}
```

## 8 合并两个有序列表

知乎远程面试要求编程

> 尾递归

```
def _recursion_merge_sort2(l1, l2, tmp):
    if len(l1) == 0 or len(l2) == 0:
        tmp.extend(l1)
        tmp.extend(l2)
        return tmp
    else:
        if l1[0] < l2[0]:
            tmp.append(l1[0])
            del l1[0]
        else:
            tmp.append(l2[0])
            del l2[0]
        return _recursion_merge_sort2(l1, l2, tmp)

def recursion_merge_sort2(l1, l2):
    return _recursion_merge_sort2(l1, l2, [])
```

> 循环算法

思路：

定义一个新的空列表

比较两个列表的首个元素

小的就插入到新列表里

把已经插入新列表的元素从旧列表删除

直到两个旧列表有一个为空

再把旧列表加到新列表后面

```
def loop_merge_sort(l1, l2):
    tmp = []
    while len(l1) > 0 and len(l2) > 0:
        if l1[0] < l2[0]:
            tmp.append(l1[0])
            del l1[0]
        else:
            tmp.append(l2[0])
            del l2[0]
    tmp.extend(l1)
    tmp.extend(l2)
    return tmp
```

> pop弹出

```
a = [1,2,3,7]
b = [3,4,5]

def merge_sortedlist(a,b):
    c = []
    while a and b:
        if a[0] >= b[0]:
            c.append(b.pop(0))
        else:
            c.append(a.pop(0))
    while a:
        c.append(a.pop(0))
    while b:
        c.append(b.pop(0))
    return c
print merge_sortedlist(a,b)
    
```

## 9 交叉链表求交点

> 其实思想可以按照从尾开始比较两个链表，如果相交，则从尾开始必然一致，只要从尾开始比较，直至不一致的地方即为交叉点，如图所示

![img](http://hi.csdn.net/attachment/201106/28/0_1309244136MWLP.gif)

```
# 使用a,b两个list来模拟链表，可以看出交叉点是 7这个节点
a = [1,2,3,7,9,1,5]
b = [4,5,7,9,1,5]

for i in range(1,min(len(a),len(b))):
    if i==1 and (a[-1] != b[-1]):
        print "No"
        break
    else:
        if a[-i] != b[-i]:
            print "交叉节点：",a[-i+1]
            break
        else:
            pass
```

> 另外一种比较正规的方法，构造链表类

```
class ListNode:
    def __init__(self, x):
        self.val = x
        self.next = None
def node(l1, l2):
    length1, lenth2 = 0, 0
    # 求两个链表长度
    while l1.next:
        l1 = l1.next
        length1 += 1
    while l2.next:
        l2 = l2.next
        length2 += 1
    # 长的链表先走
    if length1 > lenth2:
        for _ in range(length1 - length2):
            l1 = l1.next
    else:
        for _ in range(length2 - length1):
            l2 = l2.next
    while l1 and l2:
        if l1.next == l2.next:
            return l1.next
        else:
            l1 = l1.next
            l2 = l2.next
```

修改了一下:

```
#coding:utf-8
class ListNode:
    def __init__(self, x):
        self.val = x
        self.next = None

def node(l1, l2):
    length1, length2 = 0, 0
    # 求两个链表长度
    while l1.next:
        l1 = l1.next#尾节点
        length1 += 1
    while l2.next:
        l2 = l2.next#尾节点
        length2 += 1

    #如果相交
    if l1.next == l2.next:
        # 长的链表先走
        if length1 > length2:
            for _ in range(length1 - length2):
                l1 = l1.next
            return l1#返回交点
        else:
            for _ in range(length2 - length1):
                l2 = l2.next
            return l2#返回交点
    # 如果不相交
    else:
        return
```

思路: http://humaoli.blog.163.com/blog/static/13346651820141125102125995/

## 10 二分查找

```
#coding:utf-8
def binary_search(list, item):
    low = 0
    high = len(list) - 1
    while low <= high:
        mid = (high - low) / 2 + low    # 避免(high + low) / 2溢出
        guess = list[mid]
        if guess > item:
            high = mid - 1
        elif guess < item:
            low = mid + 1
        else:
            return mid
    return None
mylist = [1,3,5,7,9]
print binary_search(mylist, 3)
```

参考: http://blog.csdn.net/u013205877/article/details/76411718

## 11 快排

```
#coding:utf-8
def quicksort(list):
    if len(list)<2:
        return list
    else:
        midpivot = list[0]
        lessbeforemidpivot = [i for i in list[1:] if i<=midpivot]
        biggerafterpivot = [i for i in list[1:] if i > midpivot]
        finallylist = quicksort(lessbeforemidpivot)+[midpivot]+quicksort(biggerafterpivot)
        return finallylist

print quicksort([2,4,6,7,1,2,5])
```

> 更多排序问题可见：[数据结构与算法-排序篇-Python描述](http://blog.csdn.net/mrlevo520/article/details/77829204)

## 12 找零问题

```
#coding:utf-8
#values是硬币的面值values = [ 25, 21, 10, 5, 1]
#valuesCounts   钱币对应的种类数
#money  找出来的总钱数
#coinsUsed   对应于目前钱币总数i所使用的硬币数目

def coinChange(values,valuesCounts,money,coinsUsed):
    #遍历出从1到money所有的钱数可能
    for cents in range(1,money+1):
        minCoins = cents
        #把所有的硬币面值遍历出来和钱数做对比
        for kind in range(0,valuesCounts):
            if (values[kind] <= cents):
                temp = coinsUsed[cents - values[kind]] +1
                if (temp < minCoins):
                    minCoins = temp
        coinsUsed[cents] = minCoins
        print ('面值:{0}的最少硬币使用数为:{1}'.format(cents, coinsUsed[cents]))
```

思路: http://blog.csdn.net/wdxin1322/article/details/9501163

方法: http://www.cnblogs.com/ChenxofHit/archive/2011/03/18/1988431.html

## 13 广度遍历和深度遍历二叉树

给定一个数组，构建二叉树，并且按层次打印这个二叉树

## 14 二叉树节点

```
class Node(object):
    def __init__(self, data, left=None, right=None):
        self.data = data
        self.left = left
        self.right = right

tree = Node(1, Node(3, Node(7, Node(0)), Node(6)), Node(2, Node(5), Node(4)))
```

## 15 层次遍历

```
def lookup(root):
    row = [root]
    while row:
        print(row)
        row = [kid for item in row for kid in (item.left, item.right) if kid]
```

## 16 深度遍历

```
def deep(root):
    if not root:
        return
    print root.data
    deep(root.left)
    deep(root.right)

if __name__ == '__main__':
    lookup(tree)
    deep(tree)
```

## 17 前中后序遍历

深度遍历改变顺序就OK了

```
#coding:utf-8
#二叉树的遍历
#简单的二叉树节点类
class Node(object):
    def __init__(self,value,left,right):
        self.value = value
        self.left = left
        self.right = right

#中序遍历:遍历左子树,访问当前节点,遍历右子树

def mid_travelsal(root):
    if root.left is not None:
        mid_travelsal(root.left)
    #访问当前节点
    print(root.value)
    if root.right is not None:
        mid_travelsal(root.right)

#前序遍历:访问当前节点,遍历左子树,遍历右子树

def pre_travelsal(root):
    print (root.value)
    if root.left is not None:
        pre_travelsal(root.left)
    if root.right is not None:
        pre_travelsal(root.right)

#后续遍历:遍历左子树,遍历右子树,访问当前节点

def post_trvelsal(root):
    if root.left is not None:
        post_trvelsal(root.left)
    if root.right is not None:
        post_trvelsal(root.right)
    print (root.value)
```

## 18 求最大树深

```
def maxDepth(root):
        if not root:
            return 0
        return max(maxDepth(root.left), maxDepth(root.right)) + 1
```

## 19 求两棵树是否相同

```
def isSameTree(p, q):
    if p == None and q == None:
        return True
    elif p and q :
        return p.val == q.val and isSameTree(p.left,q.left) and isSameTree(p.right,q.right)
    else :
        return False
```

## 20 前序中序求后序

推荐: http://blog.csdn.net/hinyunsin/article/details/6315502

```
def rebuild(pre, center):
    if not pre:
        return
    cur = Node(pre[0])
    index = center.index(pre[0])
    cur.left = rebuild(pre[1:index + 1], center[:index])
    cur.right = rebuild(pre[index + 1:], center[index + 1:])
    return cur

def deep(root):
    if not root:
        return
    deep(root.left)
    deep(root.right)
    print root.data
```

## 21 单链表逆置

```
class Node(object):
    def __init__(self, data=None, next=None):
        self.data = data
        self.next = next

link = Node(1, Node(2, Node(3, Node(4, Node(5, Node(6, Node(7, Node(8, Node(9)))))))))

def rev(link):
    pre = link
    cur = link.next
    pre.next = None
    while cur:
        tmp = cur.next
        cur.next = pre
        pre = cur
        cur = tmp
    return pre

root = rev(link)
while root:
    print root.data
    root = root.next
```

思路: http://blog.csdn.net/feliciafay/article/details/6841115

方法: http://www.xuebuyuan.com/2066385.html?mobile=1

## 22 两个字符串是否是变位词

```
class Anagram:
    """
    @:param s1: The first string
    @:param s2: The second string
    @:return true or false
    """
    def Solution1(s1,s2):
        alist = list(s2)

        pos1 = 0
        stillOK = True

        while pos1 < len(s1) and stillOK:
            pos2 = 0
            found = False
            while pos2 < len(alist) and not found:
                if s1[pos1] == alist[pos2]:
                    found = True
                else:
                    pos2 = pos2 + 1

            if found:
                alist[pos2] = None
            else:
                stillOK = False

            pos1 = pos1 + 1

        return stillOK

    print(Solution1('abcd','dcba'))

    def Solution2(s1,s2):
        alist1 = list(s1)
        alist2 = list(s2)

        alist1.sort()
        alist2.sort()


        pos = 0
        matches = True

        while pos < len(s1) and matches:
            if alist1[pos] == alist2[pos]:
                pos = pos + 1
            else:
                matches = False

        return matches

    print(Solution2('abcde','edcbg'))

    def Solution3(s1,s2):
        c1 = [0]*26
        c2 = [0]*26

        for i in range(len(s1)):
            pos = ord(s1[i])-ord('a')
            c1[pos] = c1[pos] + 1

        for i in range(len(s2)):
            pos = ord(s2[i])-ord('a')
            c2[pos] = c2[pos] + 1

        j = 0
        stillOK = True
        while j<26 and stillOK:
            if c1[j] == c2[j]:
                j = j + 1
            else:
                stillOK = False

        return stillOK

    print(Solution3('apple','pleap'))
```

## 23 动态规划问题

> 可参考：[动态规划(DP)的整理-Python描述](http://blog.csdn.net/mrlevo520/article/details/75676160)





