"""
REST框架中的Response类与HTTPResponse类似，除了
它使用未渲染的数据（而不是预先渲染的字符串）初始化。在Django的模板响应渲染期间会调用适当的渲染器。
"""
from http.client import responses

from django.template.response import SimpleTemplateResponse

from rest_framework.serializers import Serializer


class Response(SimpleTemplateResponse):
    """
    HttpResponse，允许其数据呈现​​为任意媒体类型。
    """

    def __init__(self, data=None, status=None,
                 template_name=None, headers=None,
                 exception=False, content_type=None):
        """
        稍微更改init参数。例如，删除“ template_name”，而使用“ data”。
        设置“ renderer”和“ media_type”通常会被推迟，例如由“ APIView”自动设置。
        """
        super().__init__(None, status=status)

        if isinstance(data, Serializer):
            msg = (
                'You passed a Serializer instance as data, but '
                'probably meant to pass serialized `.data` or '
                '`.error`. representation.'
            )
            raise AssertionError(msg)

        self.data = data
        self.template_name = template_name
        self.exception = exception
        self.content_type = content_type

        if headers:
            for name, value in headers.items():
                self[name] = value

    @property
    def rendered_content(self):
        renderer = getattr(self, 'accepted_renderer', None)
        accepted_media_type = getattr(self, 'accepted_media_type', None)
        context = getattr(self, 'renderer_context', None)

        assert renderer, ".accepted_renderer not set on Response"
        assert accepted_media_type, ".accepted_media_type not set on Response"
        assert context is not None, ".renderer_context not set on Response"
        context['response'] = self

        media_type = renderer.media_type
        charset = renderer.charset
        content_type = self.content_type

        if content_type is None and charset is not None:
            content_type = "{}; charset={}".format(media_type, charset)
        elif content_type is None:
            content_type = media_type
        self['Content-Type'] = content_type

        ret = renderer.render(self.data, accepted_media_type, context)
        if isinstance(ret, str):
            assert charset, (
                'renderer returned unicode, and did not specify '
                'a charset value.'
            )
            return ret.encode(charset)

        if not ret:
            del self['Content-Type']

        return ret

    @property
    def status_text(self):
        """
        返回与我们的HTTP响应状态代码相对应的原因文本。提供方便。
        """
        return responses.get(self.status_code, '')

    def __getstate__(self):
        """
        从响应中删除不应缓存的属性。
        """
        state = super().__getstate__()
        for key in (
            'accepted_renderer', 'renderer_context', 'resolver_match',
            'client', 'request', 'json', 'wsgi_request'
        ):
            if key in state:
                del state[key]
        state['_closable_objects'] = []
        return state
