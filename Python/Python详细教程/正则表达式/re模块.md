# re模块

阅读: 7044   [评论](http://www.liujiangblog.com/course/python/74#comments)：1

上文介绍的是正则表达式本身的语法知识，并未涉及实际使用的方法。本文将介绍在Python语言中如何使用正则表达式。

在Python中，通过内置的re模块提供对正则表达式的支持。正则表达式会被编译成一系列的字节码，然后由通过C编写的正则表达式引擎进行执行。该引擎自从Python1.6被内置以来，近20年时间未有发生过变化，实乃我辈楷模。

re模块支持下面的正则语法：

```
"."      
"^"      
"$" 
"*"     
"+"      
"?"      
*?,+?,?? 
{m,n}    
{m,n}?   
"\\"     
[]      
"|"      
(...)    
(?aiLmsux)
(?:...)  
(?P<name>...) 
(?P=name)     
(?#...)  
(?=...) 
(?!...) 
(?<=...) 
(?<!...) 
(?(id/name)yes|no)
```

支持下面的字符集或转义：

```
\number  
\A
\Z 
\b
\B
\d
\D       
\s
\S 
\w
\W     
\\
```

提供了下面的方法进行字符串的查找、替换和分割等各种处理操作。

| 方法                                       | 描述                                   | 返回值                           |
| ------------------------------------------ | -------------------------------------- | -------------------------------- |
| compile(pattern[, flags])                  | 根据包含正则表达式的字符串创建模式对象 | re对象                           |
| search(pattern, string[, flags])           | 在字符串中查找                         | 第一个匹配到的对象或者None       |
| match(pattern, string[, flags])            | 在字符串的开始处匹配模式               | 在字符串开头匹配到的对象或者None |
| split(pattern, string[, maxsplit=0,flags]) | 根据模式的匹配项来分割字符串           | 分割后的字符串列表               |
| findall(pattern, string,flags)             | 列出字符串中模式的所有匹配项           | 所有匹配到的字符串列表           |
| sub(pat,repl, string[,count=0,flags])      | 将字符串中所有的pat的匹配项用repl替换  | 完成替换后的新字符串             |
| finditer(pattern, string,flags)            | 将所有匹配到的项生成一个迭代器         | 所有匹配到的字符串组合成的迭代器 |
| subn(pat,repl, string[,count=0,flags])     | 在替换字符串后，同时报告替换的次数     | 完成替换后的新字符串及替换次数   |
| escape（string）                           | 将字符串中所有特殊正则表达式字符串转义 | 转义后的字符串                   |
| purge(pattern)                             | 清空正则表达式                         |                                  |
| template(pattern[,flags])                  | 编译一个匹配模板                       | 模式对象                         |
| fullmatch(pattern, string[, flags])        | match方法的全字符串匹配版本            | 类似match的返回值                |

同时还定义了下面几种匹配模式，单个大写字母是缩写，单词是完整模式名称，引用方法为`re.A`或者`re.ASCII`，两者都可以，注意全部是大写：

```
A  ：ASCII       
I  ：IGNORECASE  
L  ：LOCALE      
M  ：MULTILINE  
S  ：DOTALL      
X  ：VERBOSE    
U  ：UNICODE
```

**反斜杠的困扰：`\`**

与大多数编程语言相同，正则表达式里使用`\`作为转义字符，这可能造成反斜杠困扰。假如需要匹配文本中的字符`\`，那么使用编程语言表示的正则表达式里将需要4个反斜杠`\\\\`。前两个和后两个分别用于在编程语言里转义成反斜杠，转换成两个反斜杠后再在正则表达式里转义成一个反斜杠。为了方便我们使用个，Python提供了原生字符串的功能，很好地解决了这个问题，这个例子中的正则表达式可以使用`r"\\"`表示。同样，匹配一个数字的`"\\d"`可以直接写成`r"\d"`。有了原生字符串，你再也不用担心是不是漏写了反斜杠，写出来的表达式也更直观。

## 一、compile(pattern, flags=0)

这个方法是re模块的工厂方法，用于将字符串形式的正则表达式编译为Pattern模式对象，可以实现更高效率的匹配。第二个参数flag是匹配模式。

使用`compile()`完成一次转换后，再次使用该匹配模式的时候就不用进行转换了。经过`compile()`转换的正则表达式对象也能使用普通的re方法。其用法如下：

```
>>> import re
>>> pat = re.compile(r"abc")
>>> pat.match("abc123")
<_sre.SRE_Match object; span=(0, 3), match='abc'>
>>> pat.match("abc123").group
<built-in method group of _sre.SRE_Match object at 0x00000000035104A8>
>>> pat.match("abc123").group()
'abc'
```

经过compile()方法编译过后的返回值是个re对象，它可以调用match()、search()、findall()等其他方法,但其他方法不能调用compile()方法。实际上，match()和search()等方法在使用前，Python内部帮你进行了compile的步骤。

```
>>> re.match(r"abc","abc123").compile()
Traceback (most recent call last):
  File "<pyshell#7>", line 1, in <module>
    re.match(r"abc","abc123").compile()
AttributeError: '_sre.SRE_Match' object has no attribute 'compile'
```

那么是使用compile()还是直接使用`re.match()`呢？看场景！如果你只是简单的匹配一下后就不用了，那么`re.match()`这种简便的调用方式无疑来得更简单快捷。如果你有个模式需要进行大量次数的匹配，那么先compile编译一下再匹配的方式，效率会高很多。

以下的内容，都采用直接通过re模块调用方法的形式。

## 二、match(pattern, string, flags=0)

match()方法会在给定字符串的开头进行匹配，如果匹配不成功则返回None，匹配成功返回一个匹配对象，这个对象有个group()方法，可以将匹配到的字符串给出。

```
>>> ret = re.match(r"abc","ab1c123")
>>> print(ret)
None
>>> re.match(r"abc","abc123")
<_sre.SRE_Match object; span=(0, 3), match='abc'>
>>> obj = re.match(r"abc","abc123")
>>> obj.group()
'abc'
```

对于一个`<_sre.SRE_Match object; span=(0, 3), match='abc'>`对象，span指的是匹配到的字符在字符串中的位置下标，分别对应start和end。需要注意的是不包括end位置的下标，它是右开口的。具体如下：

```
>>> obj = re.match(r"abc","abc123")
>>> obj.start()
0
>>> obj.end()
3
>>> obj.span()
(0, 3)
>>> obj.group()
'abc'
```

## 三、search(pattern, string, flags=0)

在文本内查找，返回第一个匹配到的字符串。它的返回值类型和使用方法与match()是一样的，唯一的区别就是查找的位置不用固定在文本的开头。

```
>>> obj = re.search(r"abc","123abc456abc789")
>>> obj
<_sre.SRE_Match object; span=(3, 6), match='abc'>
>>> obj.group()
'abc'
>>> obj.start()
3
>>> obj.end()
6
>>> obj.span()
(3, 6)
```

## 四、findall(pattern, string, flags=0)

作为re模块的三大搜索函数之一，findall()和match()、search()的不同之处在于，前两者都是单值匹配，找到一个就忽略后面，直接返回不再查找了。而findall是全文查找，它的返回值是一个匹配到的字符串的列表。这个列表没有group()方法，没有start、end、span，更不是一个匹配对象，仅仅是个列表！如果一项都没有匹配到那么返回一个空列表。

```
>>> obj = re.findall(r"abc","123abc456abc789")
>>> obj
['abc', 'abc']
>>> obj.group()
Traceback (most recent call last):
  File "<pyshell#37>", line 1, in <module>
    obj.group()
AttributeError: 'list' object has no attribute 'group'
>>> obj = re.findall(r"ABC","123abc456abc789")
>>> print(obj)
[]
```

## 五、split(pattern, string, maxsplit=0, flags=0)

re模块的split()方法和字符串的split()方法很相似，都是利用特定的字符去分割字符串。但是re模块的split()可以使用正则表达式，因此更灵活，更强大，而且还有“杀手锏”。看下面这个例子，匹配模式是加减乘除四个运算符中的任何一种，通过split()将字符串分割成一个一个的数字：

```
>>> s = "8+7*5+6/3"
>>> import re
>>> a_list = re.split(r"[\+\-\*\/]",s)
>>> a_list
['8', '7', '5', '6', '3']
```

split有个参数`maxsplit`，用于指定分割的次数：

```
>>> a_list = re.split(r"[\+\-\*\/]",s,maxsplit= 2)
>>> a_list
['8', '7', '5+6/3']
```

利用分组的概念，`re.split()`方法还可以保存被匹配到的分隔符，这个功能非常重要！为什么呢？比如，你要计算8+7，是不是要同时获得`8，+，7`三个字符？就如同下面的例子，字符串`s = "8+7*5+6/3"`，想要计算字符串内的表达式的值，你必须获得其中加减乘除的符号。

```
>>> a_list = re.split(r“([\+\-\*\/])”,s)    # 注意这里添加了括号！
>>> a_list
['8', '+', '7', '*', '5', '+', '6', '/', '3']
```

## 六、sub(pattern, repl, string, count=0, flags=0)

sub()方法类似字符串的replace()方法，用指定的内容替换匹配到的字符，可以指定替换次数。

```
>>> s = "i am jack! i am nine years old ! i like swiming!"
>>> import re
>>> s = re.sub(r"i","I",s)
>>> s
'I am jack! I am nIne years old ! I lIke swImIng!'
```

sub()方法有一个高级功能——“分组引用”，这是一个非常强大的功能，运用好了能发挥巨大的作用！举例如下：

```
import re

origin = "Hello,world!"
r = re.sub(r“(world)”, r“<em>\1<em>”, origin)   # 注意括号和\1的作用！
print(r)
```

运行结果：

```
Hello,<em>world<em>!
```

其实现机制是首先在正则表达式里用括号建立了一个分组，然后在要替换进去的字符串里用“\1”引用了这个分组匹配到的内容。PS：还记得正则语法里反向引用的知识点吗？

## 七、flag匹配模式

Python的re模块提供了一些可选的标志修饰符来控制匹配的模式。可以同时指定多种模式，通过与符号`|`来设置多种模式共存。如`re.I | re.M`被设置成`I`和`M`模式。

| 匹配模式 | 描述                                                         |
| -------- | ------------------------------------------------------------ |
| re.A     | ASCII字符模式                                                |
| re.I     | 使匹配对大小写不敏感，也就是不区分大小写的模式               |
| re.L     | 做本地化识别（locale-aware）匹配                             |
| re.M     | 多行匹配，影响 `^` 和 `$`                                    |
| re.S     | 使 `.` 这个通配符能够匹配包括换行在内的所有字符，针对多行匹配 |
| re.U     | 根据Unicode字符集解析字符。这个标志影响 \w, \W, \b, \B       |
| re.X     | 该标志通过给予你更灵活的格式以便你将正则表达式写得更易于理解 |

**`re.I`模式：**

正则表达式是区分字母大小写的，但在`re.I`模式下，则忽略大小写。

split()方法用flag时的问题，尝试运行代码`re.split('a','1A1a2A3',re.I)`，但是输出结果并不是我们预想的不区分大小写的a，将字符串分割。这是因为`re.split(pattern，string，maxsplit,flags)`方法的定义体中默认是四个参数，当我们传入三个参数的时候，`re.I`实际是被当做第三个参数传递进去了，所以没起到该有的作用。如果想让这里的`re.I`起作用，应当写成`flags=re.I`，也就是`re.split('a','1A1a2A3',flags=re.I)`。

**`re.M`模式：**

多行匹配模式。默认，元字符`^`会匹配字符串的开始处，元字符`$`会匹配字符串的结束位置和字符串后面紧跟的换行符之前（如果存在这个换行符）。如果指定了这个选项，则`^`将会匹配字符串的开头和每一行的开始处，紧跟在每一个换行符后面的位置。类似的，`$`会匹配字符串的最后和每一行的最后，在接下来的换行符的前面的位置。

```
>>> import re
>>> s = "\nabc\n"
>>> re.search(r"^abc$",s)
>>>
>>> re.search(r"abc$",s)
<_sre.SRE_Match object; span=(1, 4), match='abc'>
>>> re.search(r"^abc",s)
>>>
>>> re.search(r"abc",s)
<_sre.SRE_Match object; span=(1, 4), match='abc'>
>>>
>>> re.search(r"^abc$",s,re.M)
<_sre.SRE_Match object; span=(1, 4), match='abc'>
>>>
>>> re.search(r"^abc",s,re.M)
<_sre.SRE_Match object; span=(1, 4), match='abc'>
>>>
>>> re.search(r"abc$",s,re.M)
<_sre.SRE_Match object; span=(1, 4), match='abc'>
```

**re.X模式：**

Python的re模块还有一个很有趣的X模式，也就是VERBOSE。该标志通过给予你更灵活的格式以便你将正则表达式写得更易于理解。当该标志被指定时，在正则表达式字符串中的空白、tab、换行符将被忽略，除非该空白符在字符类中或在反斜杠之后；这可以让你更清晰地组织和缩进表达式。它也允许你将注释写入表达式，这些注释会被引擎忽略；注释用 "#"号来标识，不过该符号不能在字符串或反斜杠之后。巴拉巴拉一堆，你只需要记住它的两个作用：一是让冗长难懂的表达式更易读；二是给表达式加注释。

```
>>> pat = re.compile(r'''
                                \*           # 转义一个星号
                                (            #左括号代表一个 组的开始
                                [^\*]+       #捕获任何非星号的字符
                                )            #右括号代表组的结束
                                \*           #转义一个星号
                                ''',re.VERBOSE)

>>> obj = pat.search("hi ,this is a  *something* !")
>>> obj
<_sre.SRE_Match object; span=(15, 26), match='*something*'>
>>> obj.group()
'*something*'
```

**re.U模式：**

re.UNICODE是种兼容模式。在字符串模式下被忽略（默认模式），在字节类型模式下被禁止。我们知道，在Python3之后，string和bytes被独立成了两种不同的数据类型。在re模块中，不能用bytes去匹配string或者用string去匹配bytes，只能用string匹配string，bytes匹配bytes。下面是一个bytes匹配bytes的例子：

```
import re

s = "hello"
b = bytes(s, encoding="utf-8")
pat = bytes('he', encoding="utf-8")
print("字符串s：%s" % s)
print("字节类型b：%s" % b)
print("字节类型正则表达式pat：%s" % pat)
obj_s = re.search(pat, b)
print("匹配结果： %s" % obj_s.group())
```

运行结果：

```
字符串s：hello
字节类型b：b'hello'
字节类型正则表达式pat：b'he'
匹配结果： b'he'
```

当使用UNICODE模式时，将强制禁止使用bytes类型，一但使用将报错。在string类型中，UNICODE是默认设置。

```
obj_s = re.search(pat, b, re.U)   #只贴出了修改了的部分
```

运行结果：

```
Traceback (most recent call last):
  File "F:/Python/pycharm/201705/test.py", line 10, in <module>
    obj_s = re.search(pat, b, re.U)
  File "C:\Python36\lib\re.py", line 182, in search
    return _compile(pattern, flags).search(string)
  File "C:\Python36\lib\re.py", line 301, in _compile
    p = sre_compile.compile(pattern, flags)
  File "C:\Python36\lib\sre_compile.py", line 562, in compile
    p = sre_parse.parse(p, flags)
  File "C:\Python36\lib\sre_parse.py", line 866, in parse
    p.pattern.flags = fix_flags(str, p.pattern.flags)
  File "C:\Python36\lib\sre_parse.py", line 840, in fix_flags
    raise ValueError("cannot use UNICODE flag with a bytes pattern")
ValueError: cannot use UNICODE flag with a bytes pattern
字符串s：hello
字节类型b：b'hello'
字节e类型正则表达式pat：b'he'
```

**re.S模式：**

让圆点`.`这个通配符能够从默认的不支持换行符，变得可以匹配换行符。这在我们使用网络爬虫，爬取HTML文本的时候，非常重要。我们都知道，比如技术文章，网络小说中，文本通常都是大段大段的，并且包含很多换行符，为了将整个文本爬取下来，我们常常使用`(.+)`匹配核心文本内容，看下面的例子：

```
import re

s = """
<p>水调歌头·明月几时有\n
宋代：苏轼\n
\n
丙辰中秋，欢饮达旦，大醉，作此篇，兼怀子由。\n
\n
明月几时有？把酒问青天。\n
不知天上宫阙，今夕是何年。\n
我欲乘风归去，又恐琼楼玉宇，高处不胜寒。\n
起舞弄清影，何似在人间？\n
转朱阁，低绮户，照无眠。\n
不应有恨，何事长向别时圆？\n
人有悲欢离合，月有阴晴圆缺，此事古难全。\n
但愿人长久，千里共婵娟。\n</p>
"""

ret = re.search(r'<p>(.+)</p>', s)
print(ret)
print(ret.group(1))
```

代码运行的结果不是我们想象的那样，根本就没匹配到任何东西。原因就是圆点默认不匹配换行符，导致整个匹配的失败。

解决方法就是使用`re.S`模式！如下所示替换代码中国的语句，运行后就能看到想要的结果。

```
ret = re.search(r'(.+)', s, re.S)
```

## 八、分组功能

Python的re模块有一个分组功能。所谓的分组就是去已经匹配到的内容里面再筛选出需要的内容，相当于二次过滤。实现分组靠圆括号`()`，而获取分组的内容靠的是group()、groups()和groupdict()方法，其实前面我们已经展示过。re模块里的几个重要方法在分组上，有不同的表现形式，需要区别对待。

**例一**：match()方法，不分组时的情况：

```
import re

origin = "hasdfi123123safd"
# 不分组时的情况
r = re.match("h\w+", origin)
print(r.group())         # 获取匹配到的整体结果
print(r.groups())        # 获取模型中匹配到的分组结果元组
print(r.groupdict())     # 获取模型中匹配到的分组中所有key的字典

结果：
hasdfi123123safd
()
{}
```

**例二**：match()方法，有分组的情况（注意圆括号！）

```
import re

origin = "hasdfi123123safd123"
# 有分组
r = re.match("h(\w+).*(?P<name>\d)$", origin)
print(r.group())  # 获取匹配到的整体结果
print(r.group(1))  # 获取匹配到的分组1的结果
print(r.group(2))  # 获取匹配到的分组2的结果
print(r.groups())  # 获取模型中匹配到的分组结果元组
print(r.groupdict())  # 获取模型中匹配到的分组中所有key的字典

执行结果：
hasdfi123123safd123
asdfi123123safd12
3
('asdfi123123safd12', '3')
{'name': '3'}
```

分析一下上面的代码，正则表达式`h(\w+).*(?P\d)$`中有2个小括号，表示它分了2个小组，在匹配的时候是拿整体的表达式去匹配的，而不是拿小组去匹配的。`(\w+)`表示这个小组内是1到多个字母数字字符，`(?P\d)`中`?P`是个正则表达式的特殊语法，表示给这个小组取了个叫`“name”`的名字，`?P`是固定写法。在获取分组值的时候，`group()`和`group(0)`是对等的，都表示整个匹配到的字符串，从`group(1)`开始，分别是从左往右的小组序号，按位置顺序来。

有时候括号会存在嵌套情况，那怎么确定组的顺序1，2，3？要么用取名字的方法，要么就数左括号，第几个左括号就是第几个分组，例如`（1（2，（3）），（4））`，0表示表达式本身，不参加数左括号的动作。

**例三**，search()方法，有分组的情况：

```
import re

origin = "sdfi1ha23123safd123"      # 注意这里对匹配对象做了下调整
# 有分组
r = re.search("h(\w+).*(?P<name>\d)$", origin)
print(r.group())  
print(r.group(0))  
print(r.group(1))  
print(r.group(2))
print(r.groups())  
print(r.groupdict()) 

执行结果：
ha23123safd123
ha23123safd123
a23123safd12
3
('a23123safd12', '3')
{'name': '3'}
```

表现得和match()方法基本一样。

**例四**，findall()方法，没有分组的情况：

```
import re

origin = "has something have do"
# 无分组
r = re.findall("h\w+", origin)
print(r)

执行结果：
['has', 'hing', 'have']
# 一切看起来没什么不一样
```

注意到了没有？我根本没有调用group相关的方法，因为findall()的返回值是个列表，根本就没有group()、groups()、groupdict()的概念！

**例五**，findall()方法，有一个分组的情况：

```
import re

origin = "has something have do"
# 一个分组
r = re.findall("h(\w+)", origin)
print(r)

执行结果：
['as', 'ing', 'ave']
```

相比较前面未分组的例子，有没有发现什么？对了！没有圈在分组内的内容被抛弃了，比如这里的字符'h'。

**例六**，findall()方法，有两个以上分组的情况：

```
import re

origin = "hasabcd something haveabcd do"    # 字符串调整了一下
# 两个分组
r = re.findall("h(\w+)a(bc)d", origin)
print(r)

运行结果：
[('as', 'bc'), ('ave', 'bc')]
```

注意到了返回值是什么了吗？元组组成的列表！

**例七**，sub()方法，有分组的情况：

```
import re

origin = "hasabcd something haveabcd do"
# 有分组
r = re.sub("h(\w+)", "haha",origin)
print(r)

运行结果：

haha somethaha haha do
```

看到没有？sub()没有分组的概念！这是因为sub()方法是用正则表达式整体去匹配，然后又整体的去替换，分不分组对它没有意义。这里一定要注意了！

例八，split()方法，有一个分组的情况：

```
import re

origin = "has abcd something abcd do"
# 有一个分组
r = re.split("(abcd)", origin)
print(r)

运行结果：
['has ', 'abcd', ' something ', 'abcd', ' do']
```

事实上，在前面我们已经展示过这个例子，通过分组，我们可以拿到split匹配到的分隔符。

**例九**，split()方法，有两个分组，并且嵌套：

```
import re

origin = "has abcd something abcd do"
# 有一个分组
r = re.split("(a(bc)d)", origin)
print(r)

运行结果：
['has ', 'abcd', 'bc', ' something ', 'abcd', 'bc', ' do']
```

**例十**，split()方法，有多个分组，并且嵌套：

```
import re

origin = "has abcd something abcd do"
# 有一个分组
r = re.split("(a(b)c(d))", origin)
print(r)

运行结果：
['has ', 'abcd', 'b', 'd', ' something ', 'abcd', 'b', 'd', ' do']
```