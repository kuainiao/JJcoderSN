# 动态生成CSV文件

阅读: 11100     [评论](http://www.liujiangblog.com/course/django/142#comments)：0

CSV (Comma Separated Values)，以纯文本形式存储数字和文本数据的存储方式。纯文本意味着该文件是一个字符序列，不含必须像二进制数字那样的数据。CSV文件由任意数目的记录组成，记录间以某种换行符分隔；每条记录由字段组成，字段间的分隔符是其它字符或字符串，最常见的是逗号或制表符。通常，所有记录都有完全相同的字段序列。

要在Django的视图中生成CSV文件，可以使用Python的CSV库或者Django的模板系统来实现。

## 一、使用Python的CSV库

Python自带处理CSV文件的标准库csv。csv模块的CSV文件创建功能作用于类似于文件对象创建，并且Django的HttpResponse对象也是类似于文件的对象。

下面是个例子：

```
import csv
from django.http import HttpResponse

def some_view(request):
    # Create the HttpResponse object with the appropriate CSV header.
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="somefilename.csv"'

    writer = csv.writer(response)
    writer.writerow(['First row', 'Foo', 'Bar', 'Baz'])
    writer.writerow(['Second row', 'A', 'B', 'C', '"Testing"', "Here's a quote"])

    return response
```

相关说明：

- 响应对象的MIME类型设置为`text/csv`，告诉浏览器，返回的是一个CSV文件而不是HTML文件。
- 响应对象设置了附加的`Content-Disposition`协议头，含有CSV文件的名称。文件名随便取，浏览器会在“另存为...”对话框等环境中使用它。
- 要在生成CSV的API中使用钩子非常简单：只需要把response作为第一个参数传递给`csv.writer`。`csv.writer`方法接受一个类似于文件的对象，而HttpResponse对象正好就是这么个东西。
- 对于CSV文件的每一行，调用`writer.writerow`，向它传递一个可迭代的对象比如列表或者元组。
- CSV模板会为你处理各种引用，不用担心没有转义字符串中的引号或者逗号。只需要向writerow()传递你的原始字符串，它就会执行正确的操作。

当处理大尺寸文件时，可以使用Django的StreamingHttpResponse类，通过流式传输，避免负载均衡器在服务器生成响应的时候断掉连接，提高传输可靠性。

在下面的例子中，利用Python的生成器来有效处理大尺寸CSV文件的拼接和传输：

```
import csv

from django.http import StreamingHttpResponse

class Echo(object):
    """An object that implements just the write method of the file-like
    interface.
    """
    def write(self, value):
        """Write the value by returning it, instead of storing in a buffer."""
        return value

def some_streaming_csv_view(request):
    """A view that streams a large CSV file."""
    # Generate a sequence of rows. The range is based on the maximum number of
    # rows that can be handled by a single sheet in most spreadsheet
    # applications.
    rows = (["Row {}".format(idx), str(idx)] for idx in range(65536))
    pseudo_buffer = Echo()
    writer = csv.writer(pseudo_buffer)
    response = StreamingHttpResponse((writer.writerow(row) for row in rows),
                                     content_type="text/csv")
    response['Content-Disposition'] = 'attachment; filename="somefilename.csv"'
    return response
```

## 二、使用Django的模板系统

也可以使用Django的模板系统来生成CSV。比起便捷的Python-csv库，这样做比较低级，不建议这么做，这里只是展示一下有这种方式而已。

思路是，传递一个项目的列表给你的模板，并且让模板在for循环中输出逗号。下面是一个例子，它像上面一样生成相同的CSV文件：

```
from django.http import HttpResponse
from django.template import loader, Context

def some_view(request):
    # Create the HttpResponse object with the appropriate CSV header.
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="somefilename.csv"'

    # The data is hard-coded here, but you could load it from a database or
    # some other source.
    csv_data = (
        ('First row', 'Foo', 'Bar', 'Baz'),
        ('Second row', 'A', 'B', 'C', '"Testing"', "Here's a quote"),
    )

    t = loader.get_template('my_template_name.txt')
    c = Context({
        'data': csv_data,
    })
    response.write(t.render(c))
    return response
```

然后，创建模板`my_template_name.txt`，带有以下模板代码：

```
{% for row in data %}"{{ row.0|addslashes }}", "{{ row.1|addslashes }}", "{{ row.2|addslashes }}", "{{ row.3|addslashes }}", "{{ row.4|addslashes }}"
{% endfor %}
```