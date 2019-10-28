from django.contrib.messages.api import get_messages
from django.contrib.messages.constants import DEFAULT_LEVELS


def messages(request):
    """
    返回一个懒惰的“ messages”上下文变量以及“ DEFAULT_MESSAGE_LEVELS”。
    """
    return {
        'messages': get_messages(request),
        'DEFAULT_MESSAGE_LEVELS': DEFAULT_LEVELS,
    }
