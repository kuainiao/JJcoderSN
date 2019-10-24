# QueryDict对象

类的原型：class QueryDict[source]

在HttpRequest对象中，GET和POST属性都是一个`django.http.QueryDict`的实例。也就是说你可以按本文下面提供的方法操作request.POST和request.GET。

request.POST或request.GET的QueryDict都是不可变，只读的。如果要修改它，需要使用QueryDict.copy()方法，获取它的一个拷贝，然后在这个拷贝上进行修改操作。

## 一、方法

QueryDict 实现了Python字典数据类型的所有标准方法，因为它是字典的子类。

不同之处在于下面：

### 1. QueryDict.**init**(query_string=None, mutable=False, encoding=None)[source]

QueryDict实例化方法。**注意：QueryDict的键值是可以重复的！**

```
>>> QueryDict('a=1&a=2&c=3')
<QueryDict: {'a': ['1', '2'], 'c': ['3']}>
```

如果需要实例化可以修改的对象，添加参数mutable=True。

### 2. classmethod QueryDict.fromkeys(iterable, value='', mutable=False, encoding=None)[source]

Django1.11中的新功能。

循环可迭代对象中的每个元素作为键值，并赋予同样的值（来至value参数）。

```
>>> QueryDict.fromkeys(['a', 'a', 'b'], value='val')
<QueryDict: {'a': ['val', 'val'], 'b': ['val']}>
```

### 3. QueryDict.update(other_dict)

用新的QueryDict或字典更新当前QueryDict。类似`dict.update()`，但是追加内容，而不是更新并替换它们。 像这样：

```
>>> q = QueryDict('a=1', mutable=True)
>>> q.update({'a': '2'})
>>> q.getlist('a')
['1', '2']
>>> q['a'] # returns the last
'2'
```

### 4. QueryDict.items()

类似`dict.items()`，如果有重复项目，返回最近的一个，而不是都返回：

```
>>> q = QueryDict('a=1&a=2&a=3')
>>> q.items()
[('a', '3')]
```

### 5. QueryDict.values()

类似`dict.values()`，但是只返回最近的值。 像这样：

```
>>> q = QueryDict('a=1&a=2&a=3')
>>> q.values()
['3']
```

### 6. QueryDict.copy()[source]

使用copy.deepcopy()返回QueryDict对象的副本。 此副本是可变的！

### 7. QueryDict.getlist(key, default=None)

返回键对应的值列表。 如果该键不存在并且未提供默认值，则返回一个空列表。

### 8. QueryDict.setlist(key, list_)[source]

为`list_`设置给定的键。

### 9. QueryDict.appendlist(key, item)[source]

将键追加到内部与键相关联的列表中。

### 10. QueryDict.setdefault(key, default=None)[source]

类似dict.setdefault()，为某个键设置默认值。

### 11. QueryDict.setlistdefault(key, default_list=None)[source]

类似setdefault()，除了它需要的是一个值的列表而不是单个值。

### 12. QueryDict.lists()

类似items()，只是它将其中的每个键的值作为列表放在一起。 像这样：

```
>>> q = QueryDict('a=1&a=2&a=3')
>>> q.lists()
[('a', ['1', '2', '3'])]
```

### 13. QueryDict.pop(key)[source]

返回给定键的值的列表，并从QueryDict中移除该键。 如果键不存在，将引发KeyError。 像这样：

```
>>> q = QueryDict('a=1&a=2&a=3', mutable=True)
>>> q.pop('a')
['1', '2', '3']
```

### 14. QueryDict.popitem()[source]

删除QueryDict任意一个键，并返回二值元组，包含键和键的所有值的列表。在一个空的字典上调用时将引发KeyError。 像这样：

```
>>> q = QueryDict('a=1&a=2&a=3', mutable=True)
>>> q.popitem()
('a', ['1', '2', '3'])
```

### 15. QueryDict.dict()

将QueryDict转换为Python的字典数据类型，并返回该字典。

如果出现重复的键，则将所有的值打包成一个列表，最为新字典中键的值。

```
>>> q = QueryDict('a=1&a=3&a=5')
>>> q.dict()
{'a': '5'}
```

### 16. QueryDict.urlencode(safe=None)[source]

已url的编码格式返回数据字符串。 像这样：

```
>>> q = QueryDict('a=2&b=3&b=5')
>>> q.urlencode()
'a=2&b=3&b=5'
```

使用safe参数传递不需要编码的字符。 像这样：

```
>>> q = QueryDict(mutable=True)
>>> q['next'] = '/a&b/'
>>> q.urlencode(safe='/')
'next=/a%26b/'
```