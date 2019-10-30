"""
此模块收集“跨越”多个级别的辅助函数和类MVC。换句话说，这些功能/类引入了受控耦合
为了方便起见。 因为有些模块的目录级别太深，这里可以简化导入模块的过程
"""
import warnings

from django.http import (
    Http404, HttpResponse, HttpResponsePermanentRedirect, HttpResponseRedirect,
)
from django.template import loader
from django.urls import NoReverseMatch, reverse
from django.utils.deprecation import RemovedInDjango30Warning
from django.utils.functional import Promise


def render_to_response(template_name, context=None, content_type=None, status=None, using=None):
    """
    返回一个HttpResponse，其内容充满了使用传递的参数调用django.template.loader.render_to_string（）的结果。
    """
    warnings.warn(
        'render_to_response() is deprecated in favor of render(). It has the '  # 这里建议使用render而不是render_to_response
        'same signature except that it also requires a request.',
        RemovedInDjango30Warning, stacklevel=2,
    )
    content = loader.render_to_string(template_name, context, using=using)
    return HttpResponse(content, content_type, status)


"""
参数讲解:
request: 是一个固定参数, 没什么好讲的。

template_name: templates 中定义的文件, 要注意路径名. 比如'templates/polls/index.html', 参数就要写‘polls/index.html’

context: 要传入文件中用于渲染呈现的数据, 默认是字典格式

content_type: 生成的文档要使用的MIME 类型。默认为DEFAULT_CONTENT_TYPE 设置的值。

status: http的响应代码,默认是200.

using: 用于加载模板使用的模板引擎的名称。
"""


def render(request, template_name, context=None, content_type=None, status=None, using=None):
    """
    返回一个HttpResponse，其内容充满了使用传递的参数调用django.template.loader.render_to_string（）的结果。
    """
    content = loader.render_to_string(template_name, context, request, using=using)
    return HttpResponse(content, content_type, status)


def redirect(to, *args, permanent=False, **kwargs):
    """
    将HttpResponseRedirect返回到所传递参数的相应URL。

    The arguments could be:

        * A model: the model's `get_absolute_url()` function will be called.

        * A view name, possibly with arguments: `urls.reverse()` will be used
          to reverse-resolve the name.

        * A URL, which will be used as-is for the redirect location.

    Issues a temporary redirect by default; pass permanent=True to issue a
    permanent redirect.
    """
    redirect_class = HttpResponsePermanentRedirect if permanent else HttpResponseRedirect
    return redirect_class(resolve_url(to, *args, **kwargs))


def _get_queryset(klass):
    """
    返回查询集或管理器。
    鸭子输入动作：任何具有get（）方法（对于get_object_or_404）或filter（）方法（对于get_list_or_404）的类都可以完成这项工作。
    """
    # 如果是模型类或其他带有._default_manager的对象
    if hasattr(klass, '_default_manager'):
        return klass._default_manager.all()
    return klass


def get_object_or_404(klass, *args, **kwargs):
    """
    使用get（）返回一个对象，如果该对象不存在，则引发Http404异常。

    klass可以是Model，Manager或QuerySet对象。在get（）查询中使用所有其他传递的参数和关键字参数。

   与QuerySet.get（）一样，如果找到多个对象，则会引发MultipleObjectsReturned。
    """
    queryset = _get_queryset(klass)
    if not hasattr(queryset, 'get'):
        klass__name = klass.__name__ if isinstance(klass, type) else klass.__class__.__name__
        raise ValueError(
            "First argument to get_object_or_404() must be a Model, Manager, "
            "or QuerySet, not '%s'." % klass__name  # get_object_or_404的第一个参数必须是Model，Manager，QuerySet
        )
    try:
        return queryset.get(*args, **kwargs)
    except queryset.model.DoesNotExist:
        raise Http404('No %s matches the given query.' % queryset.model._meta.object_name)


def get_list_or_404(klass, *args, **kwargs):
    """
    使用filter（）返回对象列表，如果列表为空，则引发Http404异常。

    klass可以是Model，Manager或QuerySet对象。在filter（）查询中使用所有其他传递的参数和关键字参数。
    """
    queryset = _get_queryset(klass)
    if not hasattr(queryset, 'filter'):
        klass__name = klass.__name__ if isinstance(klass, type) else klass.__class__.__name__
        raise ValueError(
            "First argument to get_list_or_404() must be a Model, Manager, or "
            "QuerySet, not '%s'." % klass__name  # get_list_or_404的第一个参数必须是Model，Manager，QuerySet
        )
    obj_list = list(queryset.filter(*args, **kwargs))
    if not obj_list:
        raise Http404('No %s matches the given query.' % queryset.model._meta.object_name)
    return obj_list


def resolve_url(to, *args, **kwargs):
    """
    返回适合于所传递参数的URL。

    The arguments could be:

        * A model: the model's `get_absolute_url()` function will be called.

        * A view name, possibly with arguments: `urls.reverse()` will be used
          to reverse-resolve the name.

        * A URL, which will be returned as-is.
    """
    # 如果是模型，请使用get_absolute_url（）
    if hasattr(to, 'get_absolute_url'):
        return to.get_absolute_url()

    if isinstance(to, Promise):
        # 扩展惰性实例，因为将其进一步传递给某些Python函数（例如urlparse）时，可能会导致问题。
        to = str(to)

    if isinstance(to, str):
        # 处理相对URL
        if to.startswith(('./', '../')):
            return to

    # 接下来，尝试反向URL解析。
    try:
        return reverse(to, args=args, kwargs=kwargs)
    except NoReverseMatch:
        # 如果这是可以召集的，请重新加注。
        if callable(to):
            raise
        # 如果这不像URL“感觉”，请重新引发。
        if '/' not in to and '.' not in to:
            raise

    # 最后，回退并假设它是一个URL
    return to


"""
用特定查询条件获取某个对象，成功则返回该对象，否则引发一个 Http404。

get_object_or_404(klass, *args, **kwargs)

参数：
klass
接受一个 Model 类，Manager 或 QuerySet 实例，表示你要对该对象进行查询。

**kwargs
查询条件，格式需要被 get() 和 filter() 接受。

例子：

from django.shortcuts import render
from django.shortcuts import get_object_or_404
from myApp.models import Book 

def my_view(request):
    context = {}
    # 查询主键为1的书，找不到返回http404
    books = get_object_or_404(Book, pk=1)
    context['books'] = books
    return render(request, 'my_view.html', context)
除了传递一个 Model，还可以传递一个 QuerySet 实例：
queryset = Book.objects.filter(title__startswith='红')
books = get_object_or_404(queryset, pk=1)
以上写法等价于：
get_object_or_404(Book, title__startswith='红', pk=1)
"""
