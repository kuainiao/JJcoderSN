"""Base Cache class."""
import time
import warnings

from django.core.exceptions import ImproperlyConfigured
from django.utils.module_loading import import_string


class InvalidCacheBackendError(ImproperlyConfigured):
    pass


class CacheKeyWarning(RuntimeWarning):
    pass


# 存根类以确保不传递`timeout`参数导致默认超时
DEFAULT_TIMEOUT = object()

# Memcached接受密钥的时间不能超过此时间。
MEMCACHE_MAX_KEY_LENGTH = 250


def default_key_func(key, key_prefix, version):
    """
    默认功能生成密钥。

    构造所有其他方法使用的密钥。默认情况下，在'key_prefix'之前添加。 KEY_FUNCTION可用于指定具有自定义按键行为的备用功能。
    """
    return '%s:%s:%s' % (key_prefix, version, key)


def get_key_func(key_func):
    """
    决定使用哪个关键功能的功能。

    Default to ``default_key_func``.
    """
    if key_func is not None:
        if callable(key_func):
            return key_func
        else:
            return import_string(key_func)
    return default_key_func


class BaseCache:
    def __init__(self, params):
        timeout = params.get('timeout', params.get('TIMEOUT', 300))
        if timeout is not None:
            try:
                timeout = int(timeout)
            except (ValueError, TypeError):
                timeout = 300  # 默认超时时间是300秒
        self.default_timeout = timeout

        options = params.get('OPTIONS', {})
        max_entries = params.get('max_entries', options.get('MAX_ENTRIES', 300))
        try:
            self._max_entries = int(max_entries)
        except (ValueError, TypeError):
            self._max_entries = 300

        cull_frequency = params.get('cull_frequency', options.get('CULL_FREQUENCY', 3))
        try:
            self._cull_frequency = int(cull_frequency)
        except (ValueError, TypeError):
            self._cull_frequency = 3

        self.key_prefix = params.get('KEY_PREFIX', '')
        self.version = params.get('VERSION', 1)
        self.key_func = get_key_func(params.get('KEY_FUNCTION'))

    def get_backend_timeout(self, timeout=DEFAULT_TIMEOUT):
        """
        根据提供的超时值，返回该后端可用的超时值。
        """
        if timeout == DEFAULT_TIMEOUT:
            timeout = self.default_timeout
        elif timeout == 0:
            # ticket 21147 - avoid time.time() related precision issues
            timeout = -1
        return None if timeout is None else time.time() + timeout

    def make_key(self, key, version=None):
        """
        构造所有其他方法使用的密钥。默认情况下，使用key_func生成一个密钥（默认情况下会在密钥前加上“ key_prefix”和“ version”）。
        在构造高速缓存时，可以提供不同的键功能。或者，您可以子类化缓存后端以提供自定义密钥生成行为。
        """
        if version is None:
            version = self.version

        new_key = self.key_func(key, self.key_prefix, version)
        return new_key

    def add(self, key, value, timeout=DEFAULT_TIMEOUT, version=None):
        """
        如果密钥尚不存在，请在缓存中设置一个值。如果给出了超时，则使用该超时作为密钥；否则，请使用默认的缓存超时。

        如果存储了值，则返回True，否则返回False。
        """
        raise NotImplementedError('subclasses of BaseCache must provide an add() method')

    def get(self, key, default=None, version=None):
        """
        从缓存中获取给定密钥。如果密钥不存在，则返回默认值，该默认值本身默认为“None”。
        """
        raise NotImplementedError('subclasses of BaseCache must provide a get() method')

    def set(self, key, value, timeout=DEFAULT_TIMEOUT, version=None):
        """
        在缓存中设置一个值。如果给出了超时，则使用该超时作为密钥；否则，请使用默认的缓存超时。
        """
        raise NotImplementedError('subclasses of BaseCache must provide a set() method')

    def touch(self, key, timeout=DEFAULT_TIMEOUT, version=None):
        """
       使用超时更新密钥的到期时间。如果成功，则返回True；如果密钥不存在，则返回False。
        """
        raise NotImplementedError('subclasses of BaseCache must provide a touch() method')

    def delete(self, key, version=None):
        """
        从缓存中删除密钥，无提示地失败。
        """
        raise NotImplementedError('subclasses of BaseCache must provide a delete() method')

    def get_many(self, keys, version=None):
        """
        从缓存中获取一堆密钥。对于某些后端（memcached，pgsql），在获取多个值时可以*快得多*。

        返回一个字典，将键中的每个键映射到其值。如果缺少给定密钥，则响应字典将丢失该密钥。
        """
        d = {}
        for k in keys:
            val = self.get(k, version=version)
            if val is not None:
                d[k] = val
        return d

    def get_or_set(self, key, default, timeout=DEFAULT_TIMEOUT, version=None):
        """
        从缓存中获取给定密钥。如果密钥不存在，请添加密钥并将其设置为默认值。默认值也可以是任何可调用的。
        如果给出了超时，则使用该超时作为密钥；否则，请使用默认的缓存超时。

        返回存储或检索到的密钥的值。
        """
        val = self.get(key, version=version)
        if val is None:
            if callable(default):
                default = default()
            if default is not None:
                self.add(key, default, timeout=timeout, version=version)
                # 如果另一个调用者在上面的第一个get（）和add（）之间添加了一个值，请再次获取该值以避免出现竞争情况。
                return self.get(key, default, version=version)
        return val

    def has_key(self, key, version=None):
        """
       如果密钥在缓存中并且尚未过期，则返回True。
        """
        return self.get(key, version=version) is not None

    def incr(self, key, delta=1, version=None):
        """
       将增量添加到缓存中的值。如果键不存在，则引发ValueError异常。
        """
        value = self.get(key, version=version)
        if value is None:
            raise ValueError("Key '%s' not found" % key)
        new_value = value + delta
        self.set(key, new_value, version=version)
        return new_value

    def decr(self, key, delta=1, version=None):
        """
        从缓存中的值中减去增量。如果键不存在，则引发ValueError异常。
        """
        return self.incr(key, -delta, version=version)

    def __contains__(self, key):
        """
        如果密钥在缓存中并且尚未过期，则返回True。
        """
        # 这是一个单独的方法，而不仅仅是has_key（）的副本，因此始终具有与has_key（）相同的功能，即使被子类覆盖。
        return self.has_key(key)

    def set_many(self, data, timeout=DEFAULT_TIMEOUT, version=None):
        """
        从键/值对的字典中一次设置一堆值在缓存中。对于某些后端（memcached），这比多次调用set（）更有效。

        如果给出了超时，则使用该超时作为密钥；否则，请使用默认的缓存超时。
        在支持它的后端上，返回插入失败的密钥列表，或者如果成功插入所有密钥，则返回空列表。
        """
        for key, value in data.items():
            self.set(key, value, timeout=timeout, version=version)
        return []

    def delete_many(self, keys, version=None):
        """
        一次删除缓存中的一堆值。对于某些后端（memcached），这比多次调用delete（）更有效。
        """
        for key in keys:
            self.delete(key, version=version)

    def clear(self):
        """Remove *all* values from the cache at once."""
        raise NotImplementedError('subclasses of BaseCache must provide a clear() method')

    def validate_key(self, key):
        """
        Warn about keys that would not be portable to the memcached
        backend. This encourages (but does not force) writing backend-portable
        cache code.
        """
        if len(key) > MEMCACHE_MAX_KEY_LENGTH:
            warnings.warn(
                'Cache key will cause errors if used with memcached: %r '
                '(longer than %s)' % (key, MEMCACHE_MAX_KEY_LENGTH), CacheKeyWarning
            )
        for char in key:
            if ord(char) < 33 or ord(char) == 127:
                warnings.warn(
                    'Cache key contains characters that will cause errors if '
                    'used with memcached: %r' % key, CacheKeyWarning
                )
                break

    def incr_version(self, key, delta=1, version=None):
        """
        Add delta to the cache version for the supplied key. Return the new
        version.
        """
        if version is None:
            version = self.version

        value = self.get(key, version=version)
        if value is None:
            raise ValueError("Key '%s' not found" % key)

        self.set(key, value, version=version + delta)
        self.delete(key, version=version)
        return version + delta

    def decr_version(self, key, delta=1, version=None):
        """
        Subtract delta from the cache version for the supplied key. Return the
        new version.
        """
        return self.incr_version(key, -delta, version)

    def close(self, **kwargs):
        """Close the cache connection"""
        pass
