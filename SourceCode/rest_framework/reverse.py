"""
提供urlresolver函数，这些函数返回完全限定的URL或视图名称
"""
from django.urls import NoReverseMatch
from django.urls import reverse as django_reverse
from django.utils.functional import lazy

from rest_framework.settings import api_settings
from rest_framework.utils.urls import replace_query_param


def preserve_builtin_query_params(url, request=None):
    """
    给定传入请求和传出URL表示形式，请附加任何内置查询参数的值。
    """
    if request is None:
        return url

    overrides = [
        api_settings.URL_FORMAT_OVERRIDE,
    ]

    for param in overrides:
        if param and (param in request.GET):
            value = request.GET[param]
            url = replace_query_param(url, param, value)

    return url


def reverse(viewname, args=None, kwargs=None, request=None, format=None, **extra):
    """
    如果正在使用版本控制，那么我们会将所有“反向”调用传递给版本控制方案实例，以便可以根据需要修改生成的URL。
    """
    scheme = getattr(request, 'versioning_scheme', None)
    if scheme is not None:
        try:
            url = scheme.reverse(viewname, args, kwargs, request, format, **extra)
        except NoReverseMatch:
            # 如果版本控制方案失败，请回退到默认的实现
            url = _reverse(viewname, args, kwargs, request, format, **extra)
    else:
        url = _reverse(viewname, args, kwargs, request, format, **extra)

    return preserve_builtin_query_params(url, request)


def _reverse(viewname, args=None, kwargs=None, request=None, format=None, **extra):
    """
    与django.urls.reverse相同，但可以选择接受一个请求并返回完全限定的URL，并使用该请求获取基本URL。
    """
    if format is not None:
        kwargs = kwargs or {}
        kwargs['format'] = format
    url = django_reverse(viewname, args=args, kwargs=kwargs, **extra)
    if request:
        return request.build_absolute_uri(url)
    return url


reverse_lazy = lazy(reverse, str)
