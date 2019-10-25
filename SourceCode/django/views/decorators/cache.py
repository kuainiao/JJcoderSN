from functools import wraps

from django.middleware.cache import CacheMiddleware
from django.utils.cache import add_never_cache_headers, patch_cache_control
from django.utils.decorators import decorator_from_middleware_with_args


def cache_page(timeout, *, cache=None, key_prefix=None):
    """
    视图的装饰器，用于尝试从缓存中获取页面并在该页面不在缓存中时填充缓存。

    URL和标头中的一些数据为缓存设置了密钥。此外，还有一个键前缀，用于区分多站点设置中的不同缓存区域。
    例如，您可以使用get_current_site（）。domain，因为这在Django项目中是唯一的。

    此外，缓存时会考虑到响应的Vary标头中的所有标头，就像中间件一样。
    """
    return decorator_from_middleware_with_args(CacheMiddleware)(
        cache_timeout=timeout, cache_alias=cache, key_prefix=key_prefix
    )


def cache_control(**kwargs):
    def _cache_controller(viewfunc):
        @wraps(viewfunc)
        def _cache_controlled(request, *args, **kw):
            response = viewfunc(request, *args, **kw)
            patch_cache_control(response, **kwargs)
            return response
        return _cache_controlled
    return _cache_controller


def never_cache(view_func):
    """
    装饰器，将响应头添加到响应中，以便永远不会将其缓存。
    """
    @wraps(view_func)
    def _wrapped_view_func(request, *args, **kwargs):
        response = view_func(request, *args, **kwargs)
        add_never_cache_headers(response)
        return response
    return _wrapped_view_func
