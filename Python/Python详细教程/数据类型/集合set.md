# 集合set

阅读: 8103   [评论](http://www.liujiangblog.com/course/python/24#comments)：5

set集合是一个无序不重复元素的集，基本功能包括关系测试和消除重复元素。集合使用大括号({})框定元素，并以逗号进行分隔。但是注意：如果要创建一个空集合，必须用 set() 而不是 {} ，因为后者创建的是一个空字典。集合除了在形式上最外层用的也是花括号外，其它的和字典没有一毛钱关系。

集合数据类型的核心在于**自动去重**。很多时候，这能给你省不少事。

```
>>> s = set([1,1,2,3,3,4])
>>> s
{1, 2, 3, 4}        # 自动去重
>>> set("it is a nice day")     # 对于字符串，集合会把它一个一个拆开，然后去重
{'s', 'e', 'y', 't', 'c', 'n', ' ', 'd', 'i', 'a'}
```

通过add(key)方法可以添加元素到set中，可以重复添加，但不会有效果：

```
>>> s = {1, 2, 3, 4}
>>> s
{1, 2, 3, 4}
>>> s.add(5)
>>> s
{1, 2, 3, 4, 5}
>>> s.add(5)
>>> s
{1, 2, 3, 4, 5}
```

可以通过update()方法，将另一个对象更新到已有的集合中，这一过程同样会进行去重。

```
>>> s
{1, 2, 3, 4, 5}
>>> s.update("hello")
>>> s
{1, 2, 3, 4, 5, 'e', 'o', 'l', 'h'}
```

通过remove(key)方法删除指定元素，或者使用pop()方法。注意，集合的pop方法无法设置参数，删除指定的元素：

```
>>> s
{1, 2, 3, 4, 5, 'e', 'o', 'l', 'h'}
>>> s.remove("l")
>>> s
{1, 2, 3, 4, 5, 'e', 'o', 'h'}
>>> s.pop()
1
>>> s
{2, 3, 4, 5, 'e', 'o', 'h'}
>>> s.pop(3)
Traceback (most recent call last):
  File "<pyshell#22>", line 1, in <module>
    s.pop(3)
TypeError: pop() takes no arguments (1 given)
```

说了这么多，有没有同学注意到，我没有从集合取某个元素。为什么呢？因为集合既不支持下标索引也不支持字典那样的通过键获取值。

那么集合支持哪些操作呢？全在这里：

```
>>> dir(set)
['__and__', '__class__', '__contains__', '__delattr__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', '__getattribute__', '__gt__', '__hash__', '__iand__', '__init__', '__init_subclass__', '__ior__', '__isub__', '__iter__', '__ixor__', '__le__', '__len__', '__lt__', '__ne__', '__new__', '__or__', '__rand__', '__reduce__', '__reduce_ex__', '__repr__', '__ror__', '__rsub__', '__rxor__', '__setattr__', '__sizeof__', '__str__', '__sub__', '__subclasshook__', '__xor__', 'add', 'clear', 'copy', 'difference', 'difference_update', 'discard', 'intersection', 'intersection_update', 'isdisjoint', 'issubset', 'issuperset', 'pop', 'remove', 'symmetric_difference', 'symmetric_difference_update', 'union', 'update']
```

除了add、clear、copy、pop、remove、update等集合常规操作，剩下的全是数学意义上的集合操作，交并差等等。

对集合进行交并差等，既可以使用union一类的英文方法名，也可以更方便的使用减号表示差集，“&”表示交集，“|”表示并集。看看下面的例子：

```
>>> basket = {'apple', 'orange', 'apple', 'pear', 'orange', 'banana'}
>>> print(basket)                      # 删除重复的
{'orange', 'banana', 'pear', 'apple'}
>>> 'orange' in basket                 # 检测成员
True
>>> 'crabgrass' in basket
False
>>> # 以下演示了两个集合的交、并、差操作
>>> a = set('abracadabra')
>>> b = set('alacazam')
>>> a                                  # a 中唯一的字母
{'a', 'r', 'b', 'c', 'd'}
>>> a - b                              # 在 a 中的字母，但不在 b 中
{'r', 'd', 'b'}
>>> a | b                              # 在 a 或 b 中的字母
{'a', 'c', 'r', 'd', 'b', 'm', 'z', 'l'}
>>> a & b                              # 在 a 和 b 中都有的字母
{'a', 'c'}
>>> a ^ b                              # 在 a 或 b 中的字母，但不同时在 a 和 b 中
{'r', 'd', 'b', 'm', 'z', 'l'}
```

集合数据类型属于Python内置的数据类型，但不被重视，在很多书籍中甚至都看不到一点介绍。其实，集合是一种非常有用的数据结构，它的去重和集合运算是其它内置类型都不具备的功能，在很多场合有着非常重要的作用，比如网络爬虫。

我们都知道爬虫需要发散链接，一个页面连着另一个页面，不断爬取所有的超级链接，才能把整个站点爬取下来。然而在成千上万个页面链接中，有很大一部分可能是重复的链接或者循环互链，如果不对链接进行去重处理，那么爬虫要么陷入死循环内，要么就是出现错误。这个时候可以用集合的去重功能，保留一个曾经爬过页面的不重复的元素集合，每爬一个新链接，看看集合里是否曾经爬过，没有就开始爬，并将链接加入集合，爬过就忽略当前链接。在这里，用集合远比用列表或者字典要来得高效、节省得多。