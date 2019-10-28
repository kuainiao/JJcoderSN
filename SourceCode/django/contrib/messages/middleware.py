from django.conf import settings
from django.contrib.messages.storage import default_storage
from django.utils.deprecation import MiddlewareMixin


class MessageMiddleware(MiddlewareMixin):
    """
    处理临时消息的中间件。
    """

    def process_request(self, request):
        request._messages = default_storage(request)

    def process_response(self, request, response):
        """
        更新存储后端（即，保存消息）。

        如果不是所有消息都可以存储并且DEBUG为True，则引发ValueError。
        """
        # 较高的中间件层可能会返回不包含条消息存储的请求，因此请不要假设该请求将存在。
        if hasattr(request, '_messages'):
            unstored_messages = request._messages.update(response)
            if unstored_messages and settings.DEBUG:
                raise ValueError('Not all temporary messages could be stored.')
        return response
