from django.conf import settings
from django.contrib.messages import constants


def get_level_tags():
    """
    返回消息级别标签。
    """
    return {
        **constants.DEFAULT_TAGS,
        **getattr(settings, 'MESSAGE_TAGS', {}),
    }
