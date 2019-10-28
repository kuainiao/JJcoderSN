from django.contrib.messages import constants
from django.contrib.messages.storage import default_storage

__all__ = (
    'add_message', 'get_messages',
    'get_level', 'set_level',
    'debug', 'info', 'success', 'warning', 'error',
    'MessageFailure',
)


class MessageFailure(Exception):
    pass


def add_message(request, level, message, extra_tags='', fail_silently=False):
    """
    尝试使用“消息”应用向请求添加消息。
    """
    try:
        messages = request._messages
    except AttributeError:
        if not hasattr(request, 'META'):
            raise TypeError(
                "add_message() argument must be an HttpRequest object, not "
                "'%s'." % request.__class__.__name__
            )
        if not fail_silently:
            raise MessageFailure(
                'You cannot add messages without installing '
                'django.contrib.messages.middleware.MessageMiddleware'
            )
    else:
        return messages.add(level, message, extra_tags)


def get_messages(request):
    """
   返回请求中的消息存储（如果存在），否则返回一个空列表。
    """
    return getattr(request, '_messages', [])


def get_level(request):
    """
   返回要记录的消息的最低级别。

   默认级别是“ MESSAGE_LEVEL”设置。如果未找到，则使用“ INFO”级别。
    """
    storage = getattr(request, '_messages', default_storage(request))
    return storage.level


def set_level(request, level):
    """
    设置要记录的消息的最低级别，如果该级别被成功记录，则返回“ True”。

    如果设置为“None”，则使用默认级别（请参见get_level（）函数）。
    """
    if not hasattr(request, '_messages'):
        return False
    request._messages.level = level
    return True


def debug(request, message, extra_tags='', fail_silently=False):
    """添加一个具有DEBUG级别的消息。"""
    add_message(request, constants.DEBUG, message, extra_tags=extra_tags,
                fail_silently=fail_silently)


def info(request, message, extra_tags='', fail_silently=False):
    """添加具有``INFO''级的消息。"""
    add_message(request, constants.INFO, message, extra_tags=extra_tags,
                fail_silently=fail_silently)


def success(request, message, extra_tags='', fail_silently=False):
    """添加一条具有``SUCCESS''级别的消息。"""
    add_message(request, constants.SUCCESS, message, extra_tags=extra_tags,
                fail_silently=fail_silently)


def warning(request, message, extra_tags='', fail_silently=False):
    """添加一条带有``WARNING''级别的消息。"""
    add_message(request, constants.WARNING, message, extra_tags=extra_tags,
                fail_silently=fail_silently)


def error(request, message, extra_tags='', fail_silently=False):
    """添加一条消息为``ERROR''级别。"""
    add_message(request, constants.ERROR, message, extra_tags=extra_tags,
                fail_silently=fail_silently)
