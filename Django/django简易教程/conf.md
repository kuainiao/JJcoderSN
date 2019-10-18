```python
from django.urls import conf
```
```python
"""Functions for use in URLsconfs."""
from functools import partial
"""
functools.partial(func, *args, **keywords)
用于创建一个偏函数，它用一些默认参数包装一个可调用对象，返回结果是可调用对象，并且可以像原始对象一样对待，这样可以简化函数调用。实际上 partial 相当于一个高阶函数，其大致的实现如下（实际在标准库中它是用 C 实现的）：
def partial(func, *args, **keywords):
    def newfunc(*fargs, **fkeywords):
        newkeywords = keywords.copy()
        newkeywords.update(fkeywords)
        return func(*args, *fargs, **newkeywords)
    newfunc.func = func
    newfunc.args = args
    newfunc.keywords = keywords
    return newfunc
简单例子：
from functools import partial

def add(x, y):
    return x + y

add_y = partial(add, 3)  # add_y 是一个新的函数
add_y(4)
实用例子：
def json_serial_fallback(obj):
    #JSON serializer for objects not serializable by default json code
    if isinstance(obj, (datetime.datetime, datetime.date)):
        return str(obj)
    if isinstance(obj, bytes):
        return obj.decode("utf-8")
    raise TypeError ("%s is not JSON serializable" % obj)

json_dumps = partial(json.dumps, default=json_serial_fallback)
可以在 json_serial_fallback 函数中添加类型判断来指定如何 json 序列化一个 Python 对象
"""

from importlib import import_module
"""
importlib.import_module(name, package=None) 返回的是指定的包或者模块
导入一个模块。参数 name 指定了以绝对或相对导入方式导入什么模块 (比如要么像这样 pkg.mod 或者这样 ..mod)。如果参数 name 使用相对导入的方式来指定，那么那个参数 packages 必须设置为那个包名，这个包名作为解析这个包名的锚点 (比如 import_module('..mod', 'pkg.subpkg') 将会导入 pkg.mod)。

import_module() 函数是一个对 importlib.__import__() 进行简化的包装器。 这意味着该函数的所有主义都来自于 importlib.__import__()。 这两个函数之间最重要的不同点在于 import_module() 返回指定的包或模块 (例如 pkg.mod)，而 __import__() 返回最高层级的包或模块 (例如 pkg)。

如果动态导入一个自从解释器开始执行以来被创建的模块（即创建了一个 Python 源代码文件），为了让导入系统知道这个新模块，可能需要调用 invalidate_caches()。
"""

from django.core.exceptions import ImproperlyConfigured

from .resolvers import (
    LocalePrefixPattern, RegexPattern, RoutePattern, URLPattern, URLResolver,
)


def include(arg, namespace=None):   # include(arg, namespace)函数，有两个参数, 这个arg类型是Any（函数标注：指无法表达所有类型）
    app_name = None
    if isinstance(arg, tuple): # arg只是一个元祖（include((pattern,app_namespace),namespace=None)）
        # Callable returning a namespace hint. 调用返回一个命名空间提示
        try:
            urlconf_module, app_name = arg # 在序列解包的时候，第一个参数是urlconf_module(子urls)，第二个参数是应用命名空间
        except ValueError:
            if namespace: # 这里不太懂什么意思
                raise ImproperlyConfigured(
                    'Cannot override the namespace for a dynamic module that '
                    'provides a namespace.'
                )
            raise ImproperlyConfigured(
                'Passing a %d-tuple to include() is not supported. Pass a '
                '2-tuple containing the list of patterns and app_name, and '
                'provide the namespace argument to include() instead.' % len(arg)
            )
    else:
        # No namespace hint - use manually(手动) provided namespace.
        urlconf_module = arg # 如果他不是一个元祖，那么arg就是urlconf_module（include(urlconf_module, namespace=None)）
# 上面整体是对arg进行判断和解参（arg），以供下面调用使用(urlconf_module)

    if isinstance(urlconf_module, str): # 因为urlconf_module必须是一个字符串
        urlconf_module = import_module(urlconf_module) # 反射，相当于from app名字 import urls，这里的urlconf_module是urls
    patterns = getattr(urlconf_module, 'urlpatterns', urlconf_module)
    app_name = getattr(urlconf_module, 'app_name', app_name)
    if namespace and not app_name: # 如果有实例命名空间，而没有应用命名空间，是不可以的，所以会报错
        raise ImproperlyConfigured(
            'Specifying a namespace in include() without providing an app_name '
            'is not supported. Set the app_name attribute in the included '
            'module, or pass a 2-tuple containing the list of patterns and '
            'app_name instead.',
        )
    namespace = namespace or app_name
    # Make sure the patterns can be iterated through (without this, some (确保可以遍历模式(如果没有这个，一些testcase将会崩溃)
    # testcases will break).
    if isinstance(patterns, (list, tuple)): #include(pattern_list or pattern_tuple)里面包含的是path或者re_path(这种用法不常见)
        for url_pattern in patterns:
            pattern = getattr(url_pattern, 'pattern', None)
            if isinstance(pattern, LocalePrefixPattern):
                raise ImproperlyConfigured(
                    'Using i18n_patterns in an included URLconf is not allowed.'
                )
    return (urlconf_module, app_name, namespace)


def _path(route, view, kwargs=None, name=None, Pattern=None): # 这个是path和re_path的原型
    if isinstance(view, (list, tuple)):
        # For include(...) processing.
        pattern = Pattern(route, is_endpoint=False)
        urlconf_module, app_name, namespace = view # 因为这是原生的path，而生成的偏函数path或者re_path中还会对view处理
        return URLResolver(
            pattern,
            urlconf_module,
            kwargs,
            app_name=app_name,
            namespace=namespace,
        )
    elif callable(view):
        pattern = Pattern(route, name=name, is_endpoint=True)
        return URLPattern(pattern, view, kwargs, name)
    else:
        raise TypeError('view must be a callable or a list/tuple in the case of include().')


path = partial(_path, Pattern=RoutePattern)
re_path = partial(_path, Pattern=RegexPattern)  #　这两个是偏函数，也即是传入pattern参数在原来的函数上面生成一个新的函数


"""
getattr(object, name[, default])
返回对象命名属性的值。name 必须是字符串。如果该字符串是对象的属性之一，则返回该属性的值。例如， getattr(x, 'foobar') 等同于 x.foobar。如果指定的属性不存在，且提供了 default 值，则返回它，否则触发 AttributeError。
"""
```