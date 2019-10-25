"""
此模块收集“跨越”多个级别的辅助函数和类MVC。换句话说，这些功能/类引入了受控耦合
为了方便起见。
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
        'render_to_response() is deprecated in favor of render(). It has the '
        'same signature except that it also requires a request.',
        RemovedInDjango30Warning, stacklevel=2,
    )
    content = loader.render_to_string(template_name, context, using=using)
    return HttpResponse(content, content_type, status)


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
    # If it is a model class or anything else with ._default_manager
    if hasattr(klass, '_default_manager'):
        return klass._default_manager.all()
    return klass


def get_object_or_404(klass, *args, **kwargs):
    """
    Use get() to return an object, or raise a Http404 exception if the object
    does not exist.

    klass may be a Model, Manager, or QuerySet object. All other passed
    arguments and keyword arguments are used in the get() query.

    Like with QuerySet.get(), MultipleObjectsReturned is raised if more than
    one object is found.
    """
    queryset = _get_queryset(klass)
    if not hasattr(queryset, 'get'):
        klass__name = klass.__name__ if isinstance(klass, type) else klass.__class__.__name__
        raise ValueError(
            "First argument to get_object_or_404() must be a Model, Manager, "
            "or QuerySet, not '%s'." % klass__name
        )
    try:
        return queryset.get(*args, **kwargs)
    except queryset.model.DoesNotExist:
        raise Http404('No %s matches the given query.' % queryset.model._meta.object_name)


def get_list_or_404(klass, *args, **kwargs):
    """
    Use filter() to return a list of objects, or raise a Http404 exception if
    the list is empty.

    klass may be a Model, Manager, or QuerySet object. All other passed
    arguments and keyword arguments are used in the filter() query.
    """
    queryset = _get_queryset(klass)
    if not hasattr(queryset, 'filter'):
        klass__name = klass.__name__ if isinstance(klass, type) else klass.__class__.__name__
        raise ValueError(
            "First argument to get_list_or_404() must be a Model, Manager, or "
            "QuerySet, not '%s'." % klass__name
        )
    obj_list = list(queryset.filter(*args, **kwargs))
    if not obj_list:
        raise Http404('No %s matches the given query.' % queryset.model._meta.object_name)
    return obj_list


def resolve_url(to, *args, **kwargs):
    """
    Return a URL appropriate for the arguments passed.

    The arguments could be:

        * A model: the model's `get_absolute_url()` function will be called.

        * A view name, possibly with arguments: `urls.reverse()` will be used
          to reverse-resolve the name.

        * A URL, which will be returned as-is.
    """
    # If it's a model, use get_absolute_url()
    if hasattr(to, 'get_absolute_url'):
        return to.get_absolute_url()

    if isinstance(to, Promise):
        # Expand the lazy instance, as it can cause issues when it is passed
        # further to some Python functions like urlparse.
        to = str(to)

    if isinstance(to, str):
        # Handle relative URLs
        if to.startswith(('./', '../')):
            return to

    # Next try a reverse URL resolution.
    try:
        return reverse(to, args=args, kwargs=kwargs)
    except NoReverseMatch:
        # If this is a callable, re-raise.
        if callable(to):
            raise
        # If this doesn't "feel" like a URL, re-raise.
        if '/' not in to and '.' not in to:
            raise

    # Finally, fall back and assume it's a URL
    return to
