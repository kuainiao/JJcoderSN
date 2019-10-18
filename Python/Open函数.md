# Python open() 函数 文件处理

### 函数：open()

**作用**：打开一个文件

#### 语法：

```python
open(file[, mode[, buffering[, encoding[, errors[, newline[, closefd=True]]]]]])
```

#### 参数说明：
**file：**              要打开的文件名，需加路径(除非是在当前目录)。唯一强制参数
**mode：**         文件打开的模式
**buffering：**    设置buffer（取值为0,1,>1）
**encoding：**   返回数据的编码（一般为UTF8或GBK）
**errors：**         报错级别（一般为strict，ignore）
**newline：**      用于区分换行符(只对文本模式有效，可以取的值有None,'\n','\r','','\r\n')
**closefd：**       传入的file参数类型（缺省为True）

常用的是file，mode和encoding这三个参数

#### 参数详细说明：
**mode**：文件打开的模式。有如下几种模式
'r'： 以只读模式打开（缺省模式）（必须保证文件存在）
'w'：以只写模式打开。若文件存在，则会自动清空文件，然后重新创建；若文件不存在，则新建文件。使用这个模式必须要保证文件所在目录存在，文件可以不存在。该模式下不能使用read*()方法下面四个模式要和上面的模式组合使用
'b'：以二进制模式打开
't'： 以文本模式打开（缺省模式）
'+'：以读写模式打开
'U'：以通用换行符模式打开

#### 常见的mode组合
'r'或'rt'：     默认模式，文本读模式
'w'或'wt'：  以文本写模式打开（打开前文件会被清空）
'rb'：          以二进制读模式打开
'ab'：         以二进制追加模式打开
'wb'：        以二进制写模式打开（打开前文件会被清空）
'r+'：         以文本读写模式打开，可以写到文件任何位置；默认写的指针开始指在文件开头, 因此会覆写文件
'w+'：        以文本读写模式打开（打开前文件会被清空）。可以使用read*()
'a+'：        以文本读写模式打开（写只能写在文件末尾）。可以使用read*()
'rb+'：       以二进制读写模式打开
'wb+'：     以二进制读写模式打开（打开前文件会被清空）



**buffering**：设置buffer
0：    代表buffer关闭（只适用于二进制模式）
1：    代表line buffer（只适用于文本模式）
\>1：  表示初始化的buffer大小

**errors**：报错级别
strict：    字符编码出现问题时会报错
ignore：  字符编码出现问题时程序会忽略而过，继续执行下面的程序

**closefd**：
True：   传入的file参数为文件的文件名
False：  传入的file参数只能是文件描述符
Ps：      文件描述符，就是一个非负整数，在Unix内核的系统中，打开一个文件，便会返回一个文件描述符。

注意：使用open打开文件后一定要记得关闭文件对象
判断文件是否被关闭

```
>>> try:
		all_the_text = f.read()
	finally:	
		f.close() 
>>> f.read()
Traceback (most recent call last):  File "<pyshell#60>", line 1, in <module>    f.read()ValueError: I/O operation on closed file
```

注：不能把open语句放在try块里，因为当打开文件出现异常时，文件对象file_object无法执行close()方法。

6：其他：
file()与open()
相同点： 两者都能够打开文件，对文件进行操作，用法和参数也相似

不同点：
file 打开文件，相当于这是在构造文件类

open 打开文件，是用python的内建函数来操作



```python
# 打开文件，用写的方式

# r表示后面字符串内容不需要转义

# f称之为文件句柄

f = open(r"test01.txt",'w')

#文件打开后必须关闭
f.close()
# 此案例说明，以写方式打开文件，默认是如果没有文件，则创建
```


### with语句
with语句使用得技术是一种成为上下文管理协议得技术（ContextMangagementProtoal）,由系统负责关闭文件。
自动判断文件的作用域，自动关闭不在使用的打开的文件句柄
对文件的使用一般要求使用with打开文件

```python
with open(r"test01.txt",'r') as f:
    pass

# 下面语句块开始对文件f进行操作

# 在本模块中不需要在使用close关闭文件f
```


### readline
一行一行读取文件

```python
# with 案例

with open(r"file01.txt",'r') as f:
    # 按行读取内容
    strline = f.readline()
    # 此结构保证能够完整读取文件直到结束
    while strline:
        print(strline)
        strline = f.readline()
```


### list
整个文件读取，把文件内每一行作为一个元素，进行遍历

```
# 按行读取内容

strline = f.readline()
# 此结构保证能够完整读取文件直到结束
while strline:
    print(strline)
    strline = f.readline()
```

list
整个文件读取，把文件内每一行作为一个元素，进行遍历

```python
# list 能用打开的文件作为参数，把文件内每一行内容作为一个元素

with open(r"file01.txt", 'r') as f:
    l = list(f)
    for line in l:
        print(line)
```


### read
是按照字符读取文件内容
允许输入参数决定读取几个字符，如果没有制定，从当前位置读取到结尾
否则，从当前位置（文字指针位置）读取指定个数字符
```python
with open(r'file01.txt', 'r' ) as f:
    strChar = f.read()
    print(len(strChar))
    print(strChar)
```

### seek(offset,from)
移动文件的读取位置，也叫读取指针
from的取值范围：
0： 从文件头开始偏移
1： 从文件当前位置开启偏移
2： 从文件末尾开始偏移
移动的单位是字节（byte）一个字节不等于一个汉字
一个汉字由若干个字节构成，根据编码不同一个汉字的字节数也不同
返回文件只针对当前位置

```python
# seek案例

# 打开文件后，从第6个字节开始读取

# 打开后默认文件指针字0处，即文件的开头

with open(r'file01.txt', 'r' ) as f:

# seek移动单位是字节
	f.seek(6,0)
	strChar = f.read()
	print(strChar)
```


tell函数：用来显示文件读写指针的当前位置
```python
with open(r'file01.txt', 'r' ) as f:
    strChar = f.read(3)
    pos = f.tell()

    while strChar:
        print(pos)
        print(strChar)
    
        strChar = f.read(3)
        pos = f.tell()
```

### 文件的写操作-write
write(str): 把字符串写入文件
writelines(str): 把字符串按行写入文件,可以写入很多行，参数可以是list格式
区别：
write 函数参数只能是字符串
writelines 参数可以是字符串，也可以是字符序列
```
# write 案例
# 向文件追加诗的名称

# a 代表追加方式打开

with open(r'file01.txt','a') as f:
    f.write("李白-- \n 静夜思")
    f.writelines("鹅 鹅 鹅")
```
```
l = ["I","love","dsjka"]
with open(r'file01.txt','w') as f:
    f.writelines(l)
```
文件复制，删除，移动由os模块负责
持久化 - pickle
序列化 （持久化，落地）：把程序运行中的信息保存在磁盘上
反序列化： 序列化的逆过程
pickle : python提供的序列化模块
pickle.dump: 序列化
pickle.load: 反序列化
```
# 序列化案例
import pickle

age = 19

with open(r'file02.txt','wb') as f:
    # 将 age 以二进制方式序列化到file02.txt中
    pickle.dump(age,f)
```
```
# 反序列化案例

import pickle

with open(r'file02.txt','rb') as f:
    age = pickle.load(f)
    print(age)
```
```
# 序列化案例2

people = [23,'whj','beijing',[175,120]]

with open(r'file02.txt', 'wb') as f:
    pickle.dump(people,f)
````
```
with open(r'file02.txt', 'rb') as f:
    people =  pickle.load(f)
    print(people)
```
```
[23, 'whj', 'beijing', [175, 120]]
```
持久化 - shelve
持久化工具
类似字典，用kv对保存数据，存储方式跟字典也类似
open,close.有打开必须有关闭
```
# 使用shelve创建文件并使用
import shelve

# 打开文件
# shv相当于一个字典
shv = shelve.open(r'shv.db')
shv['one'] = 1
shv['two'] = 2
shv['three'] = 3

shv.close()

# 通过以上案例发现，shelve自动创建的不仅仅是一个shv.db文件，还包括其他的文件
```
```
# shelve 读取案例
import shelve
shv = shelve.open(r'shv.db')
try:
    print(shv['one'])
    print(shv['two'])
except Exception as e:
    print("32")
finally:
    shv.close()
```
shelve 特性
不支持多个应用并行写入
为了解决这个问题，open的时候可以使用flag=r
写回问题
shelv 一般情况下不会等待持久化对象进行任何修改
解决方案：强制回写：writeback = true
```
# shelve 以只读打开
import shelve

shv = shelve.open(r'shv.db',flag='r')

try:
    k1 = shv['one']
    print(k1)
finally:
    shv.close()
```
```
{'eins': 1, 'zwei': 2, 'drei': 3}
```
```
import shelve


shv = shelve.open(r'shv.db')
try:
    shv['one'] = {"eins":1,"zwei":2,"drei":3}
finally:
    shv.close()

shv = shelve.open(r'shv.db')
try:
    one = shv['one']
    print(one)
finally:
    shv.close()
```
```
{'eins': 1, 'zwei': 2, 'drei': 3}
```
```
# shelve 使用强制写回

import shelve

shv = shelve.open(r'shv.db',flag='r')

try:
    k1 = shv['one']
    print(k1)
    # 此时，一旦shelve关闭，则内容还在内存中，没有回写数据库
    k1["eins"] = 100
finally:
    shv.close()

shv = shelve.open(r'shv.db')
try:
    one = shv['one']
    print(one)
finally:
    shv.close()
```
```
{'eins': 1, 'zwei': 2, 'drei': 3}
{'eins': 1, 'zwei': 2, 'drei': 3}
```
```
# shelve 使用强制写回

import shelve

shv = shelve.open(r'shv.db',writeback=True)
try:
    k1 = shv['one']
    print(k1)
    # 通过writeback 强制回写
    k1["eins"] = 100
finally:
    shv.close()

shv = shelve.open(r'shv.db')
try:
    one = shv['one']
    print(one)
finally:
    shv.close()
```
```
{'eins': 1, 'zwei': 2, 'drei': 3}
{'eins': 100, 'zwei': 2, 'drei': 3}
```
```
# shelve 使用with管理上下文环境

with shelve.open(r'shv.db',writeback=True) as shv:
    k1 = shv['one']
    print(k1)
    # 通过writeback 强制回写
​    k1["eins"] = 10000
with shelve.open(r'shv.db') as shv:
​    print(shv['one'])
```
```
{'eins': 1000, 'zwei': 2, 'drei': 3}
{'eins': 10000, 'zwei': 2, 'drei': 3}
```