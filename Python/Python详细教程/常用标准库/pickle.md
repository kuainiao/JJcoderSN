# pickle

阅读: 3937   [评论](http://www.liujiangblog.com/course/python/66#comments)：1

前面json章节中我们介绍过，json作为一种通用的数据交换格式和Python的持久化方式之一，只能对基本的一些内置数据类型（并且不是所有的）进行持久化。

而pickle模块则是Python专用的持久化模块，可以持久化包括自定义类在内的各种数据，比较适合Python本身复杂数据的存贮。pickle与json的操作基本一样，但是不同的是,它持久化后的字串是不可认读的，不如json的来得直观，并且只能用于Python环境，不能用作与其它语言进行数据交换，不通用。

## 主要方法

与json模块一模一样的方法名。但是**在pickle中dumps()和loads()操作的是bytes类型，而不是json中的str类型；在使用dump()和load()读写文件时，要使用`rb`或`wb`模式，也就是只接收bytes类型的数据**。

| 方法                       | 功能                                             |
| -------------------------- | ------------------------------------------------ |
| pickle.dump(obj, file)     | 将Python数据转换并保存到pickle格式的文件内       |
| pickle.dumps(obj)          | 将Python数据转换为pickle格式的bytes字串          |
| pickle.load(file)          | 从pickle格式的文件中读取数据并转换为python的类型 |
| pickle.loads(bytes_object) | 将pickle格式的bytes字串转换为python的类型        |

## 一些例子

```
>>> import pickle
>>> dic = {"k1":"v1","k2":123}
>>> s = pickle.dumps(dic)
>>> type(s)
<class 'bytes'>
>>> s
b'\x80\x03}q\x00(X\x02\x00\x00\x00k1q\x01X\x02\x00\x00\x00v1q\x02X\x02\x00\x00\x00k2q\x03K{u.'
>>> dic2 = pickle.loads(s)
>>> dic2
{'k1': 'v1', 'k2': 123}
>>> type(dic2)
<class 'dict'>
import pickle

data = {
    'a': [1, 2.0, 3, 4+6],
    'b': ("character string", b"byte string"),
    'c': {None, True, False}
}

with open('data.pickle', 'wb') as f:
    pickle.dump(data, f)
```

可以尝试用文本编辑器打开上面保存的data文件，会发现其中全是不可认读的编码。

```
import pickle

with open('data.pickle', 'rb') as f:
    data = pickle.load(f)
```

`dump()`方法能一个接着一个地将几个对象转储到同一个文件。随后调用`load()`可以同样的顺序一个一个检索出这些对象。

```
>>> a1 = 'apple'  
>>> b1 = {1: 'One', 2: 'Two', 3: 'Three'}  
>>> c1 = ['fee', 'fie', 'foe', 'fum']  
>>> f1 = open('temp.pkl', 'wb')  
>>> pickle.dump(a1, f1)  
>>> pickle.dump(b1, f1)  
>>> pickle.dump(c1, f1)  
>>> f1.close()  
>>> f2 = open('temp.pkl', 'rb')  
>>> a2 = pickle.load(f2)  
>>> a2  
'apple'  
>>> b2 = pickle.load(f2)  
>>> b2  
{1: 'One', 2: 'Two', 3: 'Three'}  
>>> c2 = pickle.load(f2)  
>>> c2  
['fee', 'fie', 'foe', 'fum']  
>>> f2.close() 
```

**Pickle可以持久化Python的自定义数据类型，但是在反持久化的时候，必须能够读取到类的定义**。

```
import pickle

class Person:
    def __init__(self, n, a):
        self.name = n
        self.age = a

    def show(self):
        print(self.name+"_"+str(self.age))

aa = Person("张三", 20)
aa.show()
f = open('d:\\1.txt', 'wb')
pickle.dump(aa, f)
f.close()
# del Person        # 注意这行被注释了
f = open('d:\\1.txt', 'rb')
bb = pickle.load(f)
f.close()
bb.show()
```

如果取消对`del Person`这一行的注释，在代码中删除了Person类的定义，那么后面的`load()`方法将会出现错误。这一点很好理解，因为如果连数据的内部结构都不知道，pickle怎么能将数据正确的解析出来呢？