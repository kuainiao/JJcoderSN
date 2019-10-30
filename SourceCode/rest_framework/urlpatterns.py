from django.conf.urls import include, url

from rest_framework.compat import (
    URLResolver, get_regex_pattern, is_route_pattern, path, register_converter
)
from rest_framework.settings import api_settings


def _get_format_path_converter(suffix_kwarg, allowed):
    if allowed:
        if len(allowed) == 1:
            allowed_pattern = allowed[0]
        else:
            allowed_pattern = '(?:%s)' % '|'.join(allowed)
        suffix_pattern = r"\.%s/?" % allowed_pattern
    else:
        suffix_pattern = r"\.[a-z0-9]+/?"

    class FormatSuffixConverter:
        regex = suffix_pattern

        def to_python(self, value):
            return value.strip('./')

        def to_url(self, value):
            return '.' + value + '/'

    converter_name = 'drf_format_suffix'
    if allowed:
        converter_name += '_' + '_'.join(allowed)

    return converter_name, FormatSuffixConverter


def apply_suffix_patterns(urlpatterns, suffix_pattern, suffix_required, suffix_route=None):
    ret = []
    for urlpattern in urlpatterns:
        if isinstance(urlpattern, URLResolver):
            # 一组包含的网址格式
            regex = get_regex_pattern(urlpattern)
            namespace = urlpattern.namespace
            app_name = urlpattern.app_name
            kwargs = urlpattern.default_kwargs
            # 应用后缀后，添加包含的模式
            patterns = apply_suffix_patterns(urlpattern.url_patterns,
                                             suffix_pattern,
                                             suffix_required,
                                             suffix_route)

            # 如果原始模式是RoutePattern，我们需要保留它
            if is_route_pattern(urlpattern):
                assert path is not None
                route = str(urlpattern.pattern)
                new_pattern = path(route, include((patterns, app_name), namespace), kwargs)
            else:
                new_pattern = url(regex, include((patterns, app_name), namespace), kwargs)

            ret.append(new_pattern)
        else:
            # 常规网址格式
            regex = get_regex_pattern(urlpattern).rstrip('$').rstrip('/') + suffix_pattern
            view = urlpattern.callback
            kwargs = urlpattern.default_args
            name = urlpattern.name
            # 添加现有和新的urlpattern
            if not suffix_required:
                ret.append(urlpattern)

            # 如果原始模式是RoutePattern，我们需要保留它
            if is_route_pattern(urlpattern):
                assert path is not None
                assert suffix_route is not None
                route = str(urlpattern.pattern).rstrip('$').rstrip('/') + suffix_route
                new_pattern = path(route, view, kwargs, name)
            else:
                new_pattern = url(regex, view, kwargs, name)

            ret.append(new_pattern)

    return ret


def format_suffix_patterns(urlpatterns, suffix_required=False, allowed=None):
    """
    用相应的模式补充现有的urlpattern，这些模式还包括一个'.format'后缀。保留urlpattern的顺序。

    urlpatterns：URL模式列表。
    suffix_required：如果为True，则只会生成带后缀的URL，而不会使用非带后缀的URL。默认为False。
    allowed：可选的元组/允许的后缀列表。例如['json'，'api']默认为`None`，允许任何后缀。
    """
    suffix_kwarg = api_settings.FORMAT_SUFFIX_KWARG
    if allowed:
        if len(allowed) == 1:
            allowed_pattern = allowed[0]
        else:
            allowed_pattern = '(%s)' % '|'.join(allowed)
        suffix_pattern = r'\.(?P<%s>%s)/?$' % (suffix_kwarg, allowed_pattern)
    else:
        suffix_pattern = r'\.(?P<%s>[a-z0-9]+)/?$' % suffix_kwarg

    if path and register_converter:
        converter_name, suffix_converter = _get_format_path_converter(suffix_kwarg, allowed)
        register_converter(suffix_converter, converter_name)

        suffix_route = '<%s:%s>' % (converter_name, suffix_kwarg)
    else:
        suffix_route = None

    return apply_suffix_patterns(urlpatterns, suffix_pattern, suffix_required, suffix_route)
