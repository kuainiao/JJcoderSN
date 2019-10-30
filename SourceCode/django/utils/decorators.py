"用于动态创建视图装饰器的功能。"

# 为了在Django 2.0中向后兼容。
# 从contextlib导入ContextDecorator＃noqa
from functools import WRAPPER_ASSIGNMENTS, partial, update_wrapper, wraps


class classonlymethod(classmethod):
    def __get__(self, instance, cls=None):
        if instance is not None:
            raise AttributeError("This method is available only on the class, not on instances.")
        return super().__get__(instance, cls)


def _update_method_wrapper(_wrapper, decorator):
    # _multi_decorate（）的bound_method在此范围内不可用。通过在虚函数上使用作弊。
    @decorator
    def dummy(*args, **kwargs):
        pass

    update_wrapper(_wrapper, dummy)


def _multi_decorate(decorators, method):
    """
    用一个或多个函数装饰器装饰“方法”。装饰器可以是单个装饰器，也可以是可迭代的装饰器。
    """
    if hasattr(decorators, '__iter__'):
        # 如果装饰器为一个，则应用装饰器的列表/元组。应用装饰器函数，以便调用顺序与它们在可迭代程序中出现的顺序相同。
        decorators = decorators[::-1]
    else:
        decorators = [decorators]

    def _wrapper(self, *args, **kwargs):
        # bound_method具有'decorator'期望的签名，即没有'self'参数，但这是对self的闭包，因此可以调用'func'。
        # 另外，将method .__ get __（）包装在函数中，因为不能在绑定的方法对象上设置新的属性，而只能在函数上设置。
        bound_method = partial(method.__get__(self, type(self)))
        for dec in decorators:
            bound_method = dec(bound_method)
        return bound_method(*args, **kwargs)

    # 将装饰器添加的所有属性复制到其装饰的函数中。
    for dec in decorators:
        _update_method_wrapper(_wrapper, dec)
    # 保留“方法”的任何现有属性，包括名称。
    update_wrapper(_wrapper, method)
    return _wrapper


def method_decorator(decorator, name=''):
    """
    将函数修饰器转换为方法修饰器
    """

    # 'obj'可以是类或函数。如果将'obj'在传递给_dec时是一个函数，则它将最终成为定义在其上的类的方法。
    # 如果'obj'是一个类，则'name'必须是将要修饰的方法的名称。
    def _dec(obj):
        if not isinstance(obj, type):
            return _multi_decorate(decorator, obj)
        if not (name and hasattr(obj, name)):
            raise ValueError(
                "The keyword argument `name` must be the name of a method "
                "of the decorated class: %s. Got '%s' instead." % (obj, name)
            )
        method = getattr(obj, name)
        if not callable(method):
            raise TypeError(
                "Cannot decorate '%s' as it isn't a callable attribute of "
                "%s (%s)." % (name, obj, method)
            )
        _wrapper = _multi_decorate(decorator, method)
        setattr(obj, name, _wrapper)
        return obj

    # 不必担心_dec看起来与列表/元组类似，因为它毫无意义
    if not hasattr(decorator, '__iter__'):
        update_wrapper(_dec, decorator)
    # 更改名称以帮助调试。
    obj = decorator if hasattr(decorator, '__name__') else decorator.__class__
    _dec.__name__ = 'method_decorator(%s)' % obj.__name__
    return _dec


def decorator_from_middleware_with_args(middleware_class):
    """
    Like decorator_from_middleware, but return a function
    that accepts the arguments to be passed to the middleware_class.
    Use like::

         cache_page = decorator_from_middleware_with_args(CacheMiddleware)
         # ...

         @cache_page(3600)
         def my_view(request):
             # ...
    """
    return make_middleware_decorator(middleware_class)


def decorator_from_middleware(middleware_class):
    """
    Given a middleware class (not an instance), return a view decorator. This
    lets you use middleware functionality on a per-view basis. The middleware
    is created with no params passed.
    """
    return make_middleware_decorator(middleware_class)()


# Unused, for backwards compatibility in Django 2.0.
def available_attrs(fn):
    """
    Return the list of functools-wrappable attributes on a callable.
    This was required as a workaround for https://bugs.python.org/issue3445
    under Python 2.
    """
    return WRAPPER_ASSIGNMENTS


def make_middleware_decorator(middleware_class):
    def _make_decorator(*m_args, **m_kwargs):
        middleware = middleware_class(*m_args, **m_kwargs)

        def _decorator(view_func):
            @wraps(view_func)
            def _wrapped_view(request, *args, **kwargs):
                if hasattr(middleware, 'process_request'):
                    result = middleware.process_request(request)
                    if result is not None:
                        return result
                if hasattr(middleware, 'process_view'):
                    result = middleware.process_view(request, view_func, args, kwargs)
                    if result is not None:
                        return result
                try:
                    response = view_func(request, *args, **kwargs)
                except Exception as e:
                    if hasattr(middleware, 'process_exception'):
                        result = middleware.process_exception(request, e)
                        if result is not None:
                            return result
                    raise
                if hasattr(response, 'render') and callable(response.render):
                    if hasattr(middleware, 'process_template_response'):
                        response = middleware.process_template_response(request, response)
                    # Defer running of process_response until after the template
                    # has been rendered:
                    if hasattr(middleware, 'process_response'):
                        def callback(response):
                            return middleware.process_response(request, response)

                        response.add_post_render_callback(callback)
                else:
                    if hasattr(middleware, 'process_response'):
                        return middleware.process_response(request, response)
                return response

            return _wrapped_view

        return _decorator

    return _make_decorator


class classproperty:
    def __init__(self, method=None):
        self.fget = method

    def __get__(self, instance, cls=None):
        return self.fget(cls)

    def getter(self, method):
        self.fget = method
        return self
