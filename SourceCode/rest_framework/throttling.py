"""
提供各种限制策略。
"""
import time

from django.core.cache import cache as default_cache
from django.core.exceptions import ImproperlyConfigured

from rest_framework.settings import api_settings


class BaseThrottle:
    """
    对请求进行节流。
    """

    def allow_request(self, request, view):
        """
       如果应允许该请求，则返回True，否则返回False。
        """
        raise NotImplementedError('.allow_request() must be overridden')

    def get_ident(self, request):
        """
        通过解析HTTP_X_FORWARDED_FOR（如果存在且代理数> 0）来识别发出请求的计算机。
        如果不可用，则使用所有HTTP_X_FORWARDED_FOR（如果可用），否则不使用REMOTE_ADDR。
        """
        xff = request.META.get('HTTP_X_FORWARDED_FOR')  # 客户端真实ip,不是代理ip
        remote_addr = request.META.get('REMOTE_ADDR')  # 远程主机ip
        num_proxies = api_settings.NUM_PROXIES  # API 运行的应用代理的数量

        if num_proxies is not None:
            if num_proxies == 0 or xff is None:
                return remote_addr
            addrs = xff.split(',')
            client_addr = addrs[-min(num_proxies, len(addrs))]
            return client_addr.strip()

        return ''.join(xff.split()) if xff else remote_addr

    def wait(self):
        """
        （可选）返回建议的秒数，以等待下一个请求。
        """
        return None


class SimpleRateThrottle(BaseThrottle):
    """
    一个简单的缓存实现，只需要覆盖.get_cache_key（）即可。

    速率（请求/秒）由View类的“ rate”属性设置。该属性是形式为'number_of_requests / period'的字符串。
    期间应为以下之一：（“ s”，“ sec”，“ m”，“ min”，“ h”，“ hour”，“ d”，“ day”）,用于节流的先前请求信息存储在缓存中。
    """
    cache = default_cache
    timer = time.time
    cache_format = 'throttle_%(scope)s_%(ident)s'
    scope = None
    THROTTLE_RATES = api_settings.DEFAULT_THROTTLE_RATES

    def __init__(self):
        if not getattr(self, 'rate', None):
            self.rate = self.get_rate()
        self.num_requests, self.duration = self.parse_rate(self.rate)

    def get_cache_key(self, request, view):
        """
        应该返回一个唯一的可用于节流的缓存键。必须重写。如果不应该限制请求，则可能会返回“None”。
        """
        raise NotImplementedError('.get_cache_key() must be overridden')

    def get_rate(self):
        """
        确定允许的请求速率的字符串表示形式。
        """
        if not getattr(self, 'scope', None):
            msg = ("You must set either `.scope` or `.rate` for '%s' throttle" %
                   self.__class__.__name__)
            raise ImproperlyConfigured(msg)

        try:
            return self.THROTTLE_RATES[self.scope]
        except KeyError:
            msg = "No default throttle rate set for '%s' scope" % self.scope
            raise ImproperlyConfigured(msg)

    def parse_rate(self, rate):
        """
        给定请求率字符串，返回两个元组：<允许的请求数>，<以秒为单位的时间段>
        """
        if rate is None:
            return (None, None)
        num, period = rate.split('/')
        num_requests = int(num)
        duration = {'s': 1, 'm': 60, 'h': 3600, 'd': 86400}[period[0]]
        return (num_requests, duration)  # 返回的是一个二元组

    def allow_request(self, request, view):
        """
        实施检查以查看是否应限制请求。成功时调用`throttle_success`。失败时调用`throttle_failure`。
        """
        if self.rate is None:
            return True

        self.key = self.get_cache_key(request, view)
        if self.key is None:
            return True

        self.history = self.cache.get(self.key, [])
        self.now = self.timer()

        # 删除历史记录中已超过节气门持续时间的所有请求
        while self.history and self.history[-1] <= self.now - self.duration:
            self.history.pop()
        if len(self.history) >= self.num_requests:
            return self.throttle_failure()
        return self.throttle_success()

    def throttle_success(self):
        """
        将当前请求的时间戳和密钥一起插入高速缓存。
        """
        self.history.insert(0, self.now)
        self.cache.set(self.key, self.history, self.duration)
        return True

    def throttle_failure(self):
        """
        当由于限制而对API的请求失败时调用。
        """
        return False

    def wait(self):
        """
        返回建议的下一个请求时间（以秒为单位）。
        """
        if self.history:
            remaining_duration = self.duration - (self.now - self.history[-1])
        else:
            remaining_duration = self.duration

        available_requests = self.num_requests - len(self.history) + 1
        if available_requests <= 0:
            return None

        return remaining_duration / float(available_requests)


class AnonRateThrottle(SimpleRateThrottle):
    """
    限制匿名用户可能进行的API调用的速率。请求的IP地址将用作唯一的缓存密钥。
    """
    scope = 'anon'

    def get_cache_key(self, request, view):
        if request.user.is_authenticated:
            return None  # 仅限制未经身份验证的请求。

        return self.cache_format % {
            'scope': self.scope,
            'ident': self.get_ident(request)
        }


class UserRateThrottle(SimpleRateThrottle):
    """
    限制给定用户可能进行的API调用的速率。如果用户通过身份验证，则该用户ID将用作唯一的缓存密钥。对于匿名请求，将使用请求的IP地址。
    """
    scope = 'user'

    def get_cache_key(self, request, view):
        if request.user.is_authenticated:
            ident = request.user.pk
        else:
            ident = self.get_ident(request)

        return self.cache_format % {
            'scope': self.scope,
            'ident': ident
        }


class ScopedRateThrottle(SimpleRateThrottle):
    """
    针对API的各个部分，以不同的数量限制API调用的速率。任何设置了“ throttle_scope”属性的视图都会被限制。
    通过将请求的用户ID和正在访问的视图的范围串联起来，将生成唯一的缓存键。
    """
    scope_attr = 'throttle_scope'

    def __init__(self):
        # 覆盖通常的SimpleRateThrottle，因为在视图调用之前我们无法确定速率。
        pass

    def allow_request(self, request, view):
        # 一旦被视图调用，我们就只能确定范围。
        self.scope = getattr(view, self.scope_attr, None)

        # 如果视图没有`throttle_scope`，则始终允许该请求
        if not self.scope:
            return True

        # 像通常在__ init__`调用期间那样确定允许的请求速率。
        self.rate = self.get_rate()
        self.num_requests, self.duration = self.parse_rate(self.rate)

        # 现在，我们可以正常进行了。
        return super().allow_request(request, view)

    def get_cache_key(self, request, view):
        """
        如果未设置“ view.throttle_scope”，请不要应用此限制。否则，通过将用户ID与视图的'.throttle_scope`属性并置来生成唯一的缓存键。
        """
        if request.user.is_authenticated:
            ident = request.user.pk
        else:
            ident = self.get_ident(request)

        return self.cache_format % {
            'scope': self.scope,
            'ident': ident
        }
