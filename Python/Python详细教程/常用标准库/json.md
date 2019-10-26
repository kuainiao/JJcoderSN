# json

阅读: 7679   [评论](http://www.liujiangblog.com/course/python/65#comments)：2

**Json是一种轻量级的数据交换格式**。Json源自JavaScript语言，易于人类的阅读和编写，同时也易于机器解析和生成，是目前应用最广泛的数据交换格式。

数据交换格式是不同平台、语言中进行数据传递的通用格式。比如Python和Java之间要对话，你直接传递给Java一个dict或list吗？Java会问，这是什么鬼？虽然它也有字典和列表数据类型，但两种字典不是一个“物种”，根本无法相互理解。这个时候就需要用Json这种交换格式了，Python和Java都能理解Json。那么别的语言为什么能理解Json呢？因为这些语言都内置或提供了Json处理模块，比如Python的json模块。（额外强调一点，在Python中json是全部小写的，包括模块和方法名。）

**Json是跨语言，跨平台的，但只能对Python的基本数据类型做操作，对Python的类就无能为力**。JSON格式和Python中的字典非常像。但是，**json的数据要求用双引号将字符串引起来，并且不能有多余的逗号**。这是因为在别的语言中，双引号引起来的才是字符串，单引号引起来的是字符；Python程序员习惯性的在列表、元组或字典的最后一个元素的后面加个逗号，这在json中是不允许的，需要特别注意。

在Python中，很多场合是需要使用json的。比如socket通信中，你能直接发送一个列表给对方吗？显然是不行的，因为socket是基于bytes类型进行字节发送的。这时候就可以通过json将列表转换成字符串，再encode()成bytes类型，然后发送过去。

关于Json本身，我不打算做过多介绍和赘述，网上的介绍一大把，感兴趣的同学可以自行查阅。需要说明的是Json和xml之间的关系。xml是更早期的数据交换格式，但是现在逐渐被json取代，因为json的语法更简单，数据更小。不过由于银行、学校等庞然大物在早期使用的xml格式的数据量太大，根本没有那个时间和金钱去迁移到Json上来，所以xml在很长一段时间内依然是常用的数据交换格式之一。

## 类型转换

将数据从Python转换到json格式，在数据类型上会有变化，如下表所示：

| Python                                 | JSON   |
| -------------------------------------- | ------ |
| dict                                   | object |
| list, tuple                            | array  |
| str                                    | string |
| int, float, int- & float-derived Enums | number |
| True                                   | true   |
| False                                  | false  |
| None                                   | null   |

反过来，从json格式转化为Python内置类型，见下表：

| JSON          | Python |
| ------------- | ------ |
| object        | dict   |
| array         | list   |
| string        | str    |
| number (int)  | int    |
| number (real) | float  |
| true          | True   |
| false         | False  |
| null          | None   |

------

## 使用方法

json模块的使用其实很简单，对于绝大多数场合下，我们只需要使用下面四个方法就可以了：

| 方法                   | 功能                                             |
| ---------------------- | ------------------------------------------------ |
| **json.dump(obj, fp)** | 将python数据类型转换并保存到json格式的文件内。   |
| **json.dumps(obj)**    | 将python数据类型转换为json格式的字符串。         |
| **json.load(fp)**      | 从json格式的文件中读取数据并转换为python的类型。 |
| **json.loads(s)**      | 将json格式的字符串转换为python的类型。           |

下面是范例：

```
>>> import json
>>> json.dumps(['foo', {'bar': ('baz', None, 1.0, 2)}])
'["foo", {"bar": ["baz", null, 1.0, 2]}]'
>>> print(json.dumps("\"foo\bar"))
"\"foo\bar"
>>> print(json.dumps('\u1234'))
"\u1234"
>>> print(json.dumps('\\'))
"\\"
>>> print(json.dumps({"c": 0, "b": 0, "a": 0}, sort_keys=True))
{"a": 0, "b": 0, "c": 0}
>>> from io import StringIO
>>> io = StringIO()
>>> json.dump(['streaming API'], io)
>>> io.getvalue()
'["streaming API"]'
>>> json.dumps([1, 2, 3, {'4': 5, '6': 7}], separators=(',', ':'))
'[1,2,3,{"4":5,"6":7}]'
>>> print(json.dumps({'4': 5, '6': 7}, sort_keys=True, indent=4))
{
    "4": 5,
    "6": 7
}
>>> json.loads('["foo", {"bar":["baz", null, 1.0, 2]}]')
['foo', {'bar': ['baz', None, 1.0, 2]}]
>>> json.loads('"\\"foo\\bar"')         ### 注意斜杠的转义
'"foo\x08ar'
>>> from io import StringIO
>>> io = StringIO('["streaming API"]')
>>> json.load(io)
['streaming API']
```

仔细观察四个方法的名称，很好记忆的，要转化成json就‘dump’，要从json转化成Python就‘load’；要根据字符串转化就加‘s’，要从文件进行转化就不加‘s’。

**需要注意的是json模块不支持bytes类型，要先将bytes转换为str格式。**

```
>>> import json
>>> s = "haha"
>>> j = json.dumps(s)
>>> j
'"haha"'
>>> b = b'xixi'
>>> k = json.dumps(b)
Traceback (most recent call last):
  File "<pyshell#5>", line 1, in <module>
    k = json.dumps(b)
  File "C:\Python36\lib\json\__init__.py", line 231, in dumps
    return _default_encoder.encode(obj)
  File "C:\Python36\lib\json\encoder.py", line 199, in encode
    chunks = self.iterencode(o, _one_shot=True)
  File "C:\Python36\lib\json\encoder.py", line 257, in iterencode
    return _iterencode(o, 0)
  File "C:\Python36\lib\json\encoder.py", line 180, in default
    o.__class__.__name__)
TypeError: Object of type 'bytes' is not JSON serializable
>>> k = json.dumps(b.decode())
>>> k
'"xixi"'
>>> type(k)
<class 'str'>
>>> a = json.loads(k)
>>> a
'xixi'
```

对文件的读写：

```
>>>import json
>>> dic = {"k1":"v1","k2":123}
>>> f = json.dump(dic, open("d:\\3","w"))
>>> f       ## 没有返回值
>>> import os
>>> os.chdir("d:\\")
>>> os.listdir()        # 验证json文件3的存在
['$360Section', '$RECYCLE.BIN', '1.txt', '2.txt', '3', 'MobileFile', 'pymysql_test.py', 'System Volume Information', 'test', '用户目录']
>>> obj = json.load(open("d:\\3")) # 重新load回来
>>> obj
{'k1': 'v1', 'k2': 123}
>>> type(obj)
<class 'dict'>
```

可以在操作系统中，使用文本处理软件打开json文件，你会发现一切都是可读的。但是要当心，由于文本处理软件本身的问题，使用它们直接编辑json文件可能会在格式上出现问题。

还可以在命令行下，通过‘json.tool’使用json功能：

```
$ echo '{"json":"obj"}' | python -m json.tool
{
    "json": "obj"
}
$ echo '{1.2:3.4}' | python -m json.tool # 期望在花括号内使用双引号封装属性名称
Expecting property name enclosed in double quotes: line 1 column 2 (char 1)
```

------

## 在线工具

有时候，我们自己编写的，或者他人提供的json数据，格式、排版等等会非常混乱，比如下面的数据：

```
{
            "user" : "ZhangSan",           "type" : "work",            "team" : [{
                "city" : "BeiJing",
                "num" : 3           }, {                "city" : "GuangZhou",
                "num" : 3
            }, {                "city" : "ShangHai",
                "num" : 3
            }]
        }
```

这显然非常不利于阅读，无法区分层次关系，也不够优雅。

互联网上提供了很多JSON在线解析和校验工具，搜索关键字“json解析”，随便选一个，将你的数据粘贴进去，然后它就能帮你整理成下面的样子了。**注意：切勿泄露敏感信息！**

```
{
    "user": "ZhangSan",
    "type": "work",
    "team": [
        {
            "city": "BeiJing",
            "num": 3
        },
        {
            "city": "GuangZhou",
            "num": 3
        },
        {
            "city": "ShangHai",
            "num": 3
        }
    ]
}
```