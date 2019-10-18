import uuid
from functools import lru_cache


class IntConverter:
    regex = '[0-9]+'  # 0-9数字中的一个或者多个

    def to_python(self, value):   # 实现to_python(self,value)方法，这个方法是将url中的值转换一下，然后传给视图函数的。

        return int(value)

    def to_url(self, value):   # 实现to_url(self,value)方法，这个方法是在做url反转的时候，将传进来的参数转换后拼接成一个正确的url。
        return str(value)


class StringConverter:
    regex = '[^/]+'    # 这里的^是一个托字符, 指不是/的任意字符,一次或者多次

    def to_python(self, value):
        return value

    def to_url(self, value):
        return value


class UUIDConverter:
    regex = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' # 这是uuid的匹配规则

    def to_python(self, value):
        return uuid.UUID(value)

    def to_url(self, value):
        return str(value)


class SlugConverter(StringConverter):
    regex = '[-a-zA-Z0-9_]+'     # 英文的-,数字,字母,或者下划线,一个或者多个


class PathConverter(StringConverter):
    regex = '.+'  # .出现一次或者多次


DEFAULT_CONVERTERS = {
    'int': IntConverter(),
    'path': PathConverter(),
    'slug': SlugConverter(),
    'str': StringConverter(),
    'uuid': UUIDConverter(),
}


REGISTERED_CONVERTERS = {}


def register_converter(converter, type_name):
    REGISTERED_CONVERTERS[type_name] = converter()  # 添加到注册表中
    get_converters.cache_clear() # 清理缓存文件


@lru_cache(maxsize=None)
def get_converters():
    return {**DEFAULT_CONVERTERS, **REGISTERED_CONVERTERS}


def get_converter(raw_converter):
    return get_converters()[raw_converter]