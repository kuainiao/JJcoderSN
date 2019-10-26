import django
from django.core.handlers.wsgi import WSGIHandler


def get_wsgi_application():
    """
    Django WSGI支持的公共接口。返回可调用的WSGI

    避免将django.core.handlers.WSGIHandler设为公共API，以防内部WSGI实现在将来发生更改或移动。
    """
    django.setup(set_prefix=False)
    return WSGIHandler()
