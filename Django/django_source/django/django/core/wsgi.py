import django
from django.core.handlers.wsgi import WSGIHandler


def get_wsgi_application():
    """
    The public interface to Django's WSGI support. Return a WSGI callable.

    Avoids making django.core.handlers.WSGIHandler a public API, in case the
    internal WSGI implementation changes or moves in the future.
    Django的WSGI支持的公共接口。返回一个可调用的WSGI。避免使django.core.handlers
    WSGIHandler是一个公共API，以防将来内部WSGI实现发生变化或移动。
    """
    django.setup(set_prefix=False)
    return WSGIHandler()
