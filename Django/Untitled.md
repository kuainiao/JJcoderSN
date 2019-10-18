# python提供的内置装饰器——staticmethod、classmethod和property 使用介绍

------

# [#](http://www.liuwq.com/views/Django/django_propety.html#装饰器)装饰器

## [#](http://www.liuwq.com/views/Django/django_propety.html#property-装饰器)property 装饰器

@property 可以将python定义的函数“当做”属性访问，从而提供更加友好访问方式，和java中的setter和getter类似。

**models.py中如下:**

```python
from django.db import models

class Person(models.Model):
    G=(('chen','jian'),('hong','yi'),('rt','ju'))
    gender=models.CharField(max_length=20,choices=G)

    # 定义装饰器
    @property
    def Gender(self):
        return self.gender
    # 装饰器 setter value update
    @Gender.setter
    def Gender(self,new_value):
        self.gender=new_value
```

**在views.py中使用:**

```python
from django.http import HttpResponse
from mytest.models import *
def index(request):
    print Person.objects.all()[0].Gender #当成属性使用
    b=Person.objects.all()[0]
    b.Gender='adfasfasd' #使用setter value update
    print b.Gender
    b.save()
    return HttpResponse(Person.objects.all()[0].Gender)
```

> @property提供的是一个只读的属性，如果需要对属性进行修改，那么就需要定义它的setter。

## [#](http://www.liuwq.com/views/Django/django_propety.html#staticmethod和-classmethod的作用与区别)@staticmethod和@classmethod的作用与区别

> 一般来说，要使用某个类的方法，需要先实例化一个对象再调用方法。 而使用@staticmethod或@classmethod，就可以不需要实例化，直接类名.方法名()来调用。 这有利于组织代码，把某些应该属于某个类的函数给放到那个类里去，同时有利于命名空间的整洁。

### [#](http://www.liuwq.com/views/Django/django_propety.html#区别)区别

- @staticmethod 不需要表示自身对象的self和自身类的cls参数，就跟使用函数一样。
- @classmethod 也不需要self参数，但第一个参数需要是表示自身类的cls参数。

如果在@staticmethod中要调用到这个类的一些属性方法，只能直接类名.属性名或类名.方法名。 而@classmethod因为持有cls参数，可以来调用类的属性，类的方法，实例化对象等，避免硬编码。

```python
class A(object):
    bar = 1
    def foo(self):
        print 'foo'

    @staticmethod
    def static_foo():
        print 'static_foo'
        print A.bar

    @classmethod
    def class_foo(cls):
        print 'class_foo'
        print cls.bar
        cls().foo()

A.static_foo()
A.class_foo()
```

**输出**

```text
static_foo
1
class_foo
1
foo
```