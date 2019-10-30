"""
提供一个APIView类，该类是REST框架中所有视图的基础。
"""
from django.conf import settings
from django.core.exceptions import PermissionDenied
from django.db import connection, models, transaction
from django.http import Http404
from django.http.response import HttpResponseBase
from django.utils.cache import cc_delim_re, patch_vary_headers
from django.utils.encoding import smart_text
from django.views.decorators.csrf import csrf_exempt
from django.views.generic import View

from rest_framework import exceptions, status
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.schemas import DefaultSchema
from rest_framework.settings import api_settings
from rest_framework.utils import formatting


def get_view_name(view):
    """
    给定一个视图实例，返回一个文本名称来表示该视图。此名称用于可浏览的API和OPTIONS响应中。此功能是VIEW_NAME_FUNCTION设置的默认设置。
    """
    # 名称可能由某些视图（例如ViewSet）设置。
    name = getattr(view, 'name', None)
    if name is not None:
        return name

    name = view.__class__.__name__
    name = formatting.remove_trailing_string(name, 'View')
    name = formatting.remove_trailing_string(name, 'ViewSet')
    name = formatting.camelcase_to_spaces(name)

    # 后缀可以由某些视图设置，例如ViewSet。
    suffix = getattr(view, 'suffix', None)
    if suffix:
        name += ' ' + suffix

    return name


def get_view_description(view, html=False):
    """
    给定视图实例，返回文本描述以表示视图。此名称用于可浏览的API和OPTIONS响应中。
    此功能是VIEW_DESCRIPTION_FUNCTION设置的默认设置。
    """
    # 描述可能由某些视图（例如ViewSet）设置。
    description = getattr(view, 'description', None)
    if description is None:
        description = view.__class__.__doc__ or ''

    description = formatting.dedent(smart_text(description))
    if html:
        return formatting.markup_description(description)
    return description


def set_rollback():
    atomic_requests = connection.settings_dict.get('ATOMIC_REQUESTS', False)
    if atomic_requests and connection.in_atomic_block:
        transaction.set_rollback(True)


def exception_handler(exc, context):
    """
    返回应用于任何给定异常的响应。默认情况下，我们处理REST框架APIException，以及Django内置的Http404和PermissionDenied异常。
    任何未处理的异常都可能返回“ None”，这将引发500错误。
    """
    if isinstance(exc, Http404):
        exc = exceptions.NotFound()
    elif isinstance(exc, PermissionDenied):
        exc = exceptions.PermissionDenied()

    if isinstance(exc, exceptions.APIException):
        headers = {}
        if getattr(exc, 'auth_header', None):
            headers['WWW-Authenticate'] = exc.auth_header
        if getattr(exc, 'wait', None):
            headers['Retry-After'] = '%d' % exc.wait

        if isinstance(exc.detail, (list, dict)):
            data = exc.detail
        else:
            data = {'detail': exc.detail}

        set_rollback() # 调用上面的rollback
        return Response(data, status=exc.status_code, headers=headers)

    return None


class APIView(View):
    # T可以在全局或按观看次数设置以下策略。
    renderer_classes = api_settings.DEFAULT_RENDERER_CLASSES
    parser_classes = api_settings.DEFAULT_PARSER_CLASSES
    authentication_classes = api_settings.DEFAULT_AUTHENTICATION_CLASSES
    throttle_classes = api_settings.DEFAULT_THROTTLE_CLASSES
    permission_classes = api_settings.DEFAULT_PERMISSION_CLASSES
    content_negotiation_class = api_settings.DEFAULT_CONTENT_NEGOTIATION_CLASS
    metadata_class = api_settings.DEFAULT_METADATA_CLASS
    versioning_class = api_settings.DEFAULT_VERSIONING_CLASS

    # 允许其他设置的依赖项注入使测试更加容易。
    settings = api_settings

    schema = DefaultSchema()

    @classmethod
    def as_view(cls, **initkwargs):
        """
        将原始类存储在视图函数中。这使我们能够在进行URL反向查找时发现有关视图的信息。用于生成面包屑。
        """
        if isinstance(getattr(cls, 'queryset', None), models.query.QuerySet):
            def force_evaluation():
                raise RuntimeError(
                    'Do not evaluate the `.queryset` attribute directly, '
                    'as the result will be cached and reused between requests. '
                    'Use `.all()` or call `.get_queryset()` instead.'
                )

            cls.queryset._fetch_all = force_evaluation

        view = super().as_view(**initkwargs) # 调用父类的as_view
        view.cls = cls
        view.initkwargs = initkwargs

        # 注意：基于会话的身份验证已通过CSRF明​​确验证，所有其他身份验证均不受CSRF的限制。
        return csrf_exempt(view)

    @property
    def allowed_methods(self):
        """
        将Django的私有_allowed_methods接口包装在公共属性中。
        """
        return self._allowed_methods()

    @property
    def default_response_headers(self): # 获取响应头的信息
        headers = {
            'Allow': ', '.join(self.allowed_methods),
        }
        if len(self.renderer_classes) > 1:
            headers['Vary'] = 'Accept'
        return headers

    def http_method_not_allowed(self, request, *args, **kwargs):
        """
       如果`request.method`与处理程序方法不对应，请确定引发哪种异常。
        """
        raise exceptions.MethodNotAllowed(request.method)

    def permission_denied(self, request, message=None):
        """
        如果不允许请求，请确定要提出哪种异常。
        """
        if request.authenticators and not request.successful_authenticator:
            raise exceptions.NotAuthenticated()
        raise exceptions.PermissionDenied(detail=message)

    def throttled(self, request, wait):
        """
       如果请求受到限制，请确定引发哪种异常。
        """
        raise exceptions.Throttled(wait)

    def get_authenticate_header(self, request):
        """
        如果请求未经身份验证，请确定用于401响应的WWW-Authenticate标头（如果有）。
        """
        authenticators = self.get_authenticators()
        if authenticators:
            return authenticators[0].authenticate_header(request)

    def get_parser_context(self, http_request):
        """
        返回传递给Parser.parse（）的字典，作为parser_context关键字参数。
        """
        # 注意：另外，request对象还将把`request`和`encoding`添加到上下文中。
        return {
            'view': self,
            'args': getattr(self, 'args', ()),
            'kwargs': getattr(self, 'kwargs', {})
        }

    def get_renderer_context(self):
        """
        返回传递给Renderer.render（）的字典，作为`renderer_context`关键字参数。
        """
        # 注意：另外，“响应”也将通过“响应”对象添加到上下文中。
        return {
            'view': self,
            'args': getattr(self, 'args', ()),
            'kwargs': getattr(self, 'kwargs', {}),
            'request': getattr(self, 'request', None)
        }

    def get_exception_handler_context(self):
        """
        返回传递给EXCEPTION_HANDLER的字典，作为context参数。
        """
        return {
            'view': self,
            'args': getattr(self, 'args', ()),
            'kwargs': getattr(self, 'kwargs', {}),
            'request': getattr(self, 'request', None)
        }

    def get_view_name(self):
        """
        返回在OPTIONS响应和可浏览API中使用的视图名称。
        """
        func = self.settings.VIEW_NAME_FUNCTION
        return func(self)

    def get_view_description(self, html=False):
        """
        返回视图的一些描述性文本，如OPTIONS响应和可浏览API中所使用。
        """
        func = self.settings.VIEW_DESCRIPTION_FUNCTION
        return func(self, html)

    # API策略实例化方法
    def get_format_suffix(self, **kwargs):
        """
        确定请求是否包含'.json'样式格式后缀
        """
        if self.settings.FORMAT_SUFFIX_KWARG:
            return kwargs.get(self.settings.FORMAT_SUFFIX_KWARG)

    def get_renderers(self):
        """
        实例化并返回此视图可以使用的渲染器列表。
        """
        return [renderer() for renderer in self.renderer_classes]

    def get_parsers(self):
        """
        实例化并返回此视图可以使用的解析器列表。
        """
        return [parser() for parser in self.parser_classes]

    def get_authenticators(self):
        """
        实例化并返回此视图可以使用的身份验证器列表。
        """
        return [auth() for auth in self.authentication_classes]

    def get_permissions(self):
        """
        实例化并返回此视图所需的权限列表。
        """
        return [permission() for permission in self.permission_classes]

    def get_throttles(self):
        """
        实例化并返回此视图使用的油门列表。
        """
        return [throttle() for throttle in self.throttle_classes]

    def get_content_negotiator(self):
        """
        实例化并返回要使用的内容协商类。
        """
        if not getattr(self, '_negotiator', None):
            self._negotiator = self.content_negotiation_class()
        return self._negotiator

    def get_exception_handler(self):
        """
        返回此视图使用的异常处理程序。
        """
        return self.settings.EXCEPTION_HANDLER

    # API政策实施方法

    def perform_content_negotiation(self, request, force=False):
        """
        确定要使用哪种渲染器和媒体类型来渲染响应。
        """
        renderers = self.get_renderers()
        conneg = self.get_content_negotiator()

        try:
            return conneg.select_renderer(request, renderers, self.format_kwarg)
        except Exception:
            if force:
                return (renderers[0], renderers[0].media_type)
            raise

    def perform_authentication(self, request):
        """
       对传入的请求执行身份验证。

       请注意，如果您覆盖此设置并只是简单地“通过”，则将在第一次访问`request.user`或`request.auth`时懒惰地执行身份验证。
        """
        request.user

    def check_permissions(self, request):
        """
        检查是否应允许该请求。如果不允许该请求，则引发适当的异常。
        """
        for permission in self.get_permissions():
            if not permission.has_permission(request, self):
                self.permission_denied(
                    request, message=getattr(permission, 'message', None)
                )

    def check_object_permissions(self, request, obj):
        """
        检查是否应允许给定对象的请求。如果不允许该请求，则引发适当的异常。
        """
        for permission in self.get_permissions():
            if not permission.has_object_permission(request, self, obj):
                self.permission_denied(
                    request, message=getattr(permission, 'message', None)
                )

    def check_throttles(self, request):
        """
        检查是否应限制请求。如果请求被限制，则引发适当的异常。
        """
        throttle_durations = []
        for throttle in self.get_throttles():
            if not throttle.allow_request(request, self):
                throttle_durations.append(throttle.wait())

        if throttle_durations:
            # 滤除“None”值，这些值可能在配置/速率更改的情况下发生，请参阅＃1438
            durations = [
                duration for duration in throttle_durations
                if duration is not None
            ]

            duration = max(durations, default=None)
            self.throttled(request, duration)

    def determine_version(self, request, *args, **kwargs):
        """
        如果使用版本控制，则为传入请求确定任何API版本。返回（version，versioning_scheme）的二元组
        """
        if self.versioning_class is None:
            return (None, None)
        scheme = self.versioning_class()
        return (scheme.determine_version(request, *args, **kwargs), scheme)

    # Dispatch methods

    def initialize_request(self, request, *args, **kwargs):
        """
        返回初始请求对象。
        """
        parser_context = self.get_parser_context(request)

        return Request(
            request,
            parsers=self.get_parsers(),
            authenticators=self.get_authenticators(),
            negotiator=self.get_content_negotiator(),
            parser_context=parser_context
        )

    def initial(self, request, *args, **kwargs):
        """
        运行在调用方法处理程序之前需要发生的任何事情。
        """
        self.format_kwarg = self.get_format_suffix(**kwargs)

        # 执行内容协商并在请求上存储接受的信息
        neg = self.perform_content_negotiation(request)
        request.accepted_renderer, request.accepted_media_type = neg

        # 确定API版本（如果正在使用版本控制）。
        version, scheme = self.determine_version(request, *args, **kwargs)
        request.version, request.versioning_scheme = version, scheme

        # 确保允许传入请求
        self.perform_authentication(request)
        self.check_permissions(request)
        self.check_throttles(request)

    def finalize_response(self, request, response, *args, **kwargs):
        """
        返回最终响应对象。
        """
        # 如果未返回正确的响应，则使错误显而易见
        assert isinstance(response, HttpResponseBase), (
                'Expected a `Response`, `HttpResponse` or `HttpStreamingResponse` '
                'to be returned from the view, but received a `%s`'
                % type(response)
        )

        if isinstance(response, Response):
            if not getattr(request, 'accepted_renderer', None):
                neg = self.perform_content_negotiation(request, force=True)
                request.accepted_renderer, request.accepted_media_type = neg

            response.accepted_renderer = request.accepted_renderer
            response.accepted_media_type = request.accepted_media_type
            response.renderer_context = self.get_renderer_context()

        # 向响应中添加新的variable标头，而不是覆盖。
        vary_headers = self.headers.pop('Vary', None)
        if vary_headers is not None:
            patch_vary_headers(response, cc_delim_re.split(vary_headers))

        for key, value in self.headers.items():
            response[key] = value

        return response

    def handle_exception(self, exc):
        """
        通过返回适当的响应或重新引发错误来处理发生的任何异常。
        """
        if isinstance(exc, (exceptions.NotAuthenticated,
                            exceptions.AuthenticationFailed)):
            # 用于401响应的WWW-Authenticate标头，否则强制为403
            auth_header = self.get_authenticate_header(self.request)

            if auth_header:
                exc.auth_header = auth_header
            else:
                exc.status_code = status.HTTP_403_FORBIDDEN

        exception_handler = self.get_exception_handler()

        context = self.get_exception_handler_context()
        response = exception_handler(exc, context)

        if response is None:
            self.raise_uncaught_exception(exc)

        response.exception = True
        return response

    def raise_uncaught_exception(self, exc):
        if settings.DEBUG:
            request = self.request
            renderer_format = getattr(request.accepted_renderer, 'format')
            use_plaintext_traceback = renderer_format not in ('html', 'api', 'admin')
            request.force_plaintext_errors(use_plaintext_traceback)
        raise exc

    # 注意：在`as_view`中将视图设为CSRF免除项，以防止Dispatch`需要被覆盖时意外删除此免除项。
    def dispatch(self, request, *args, **kwargs):
        """
        `.dispatch（）`与Django的常规调度几乎相同，但具有用于启动，完成和异常处理的额外钩子。
        """
        self.args = args
        self.kwargs = kwargs
        request = self.initialize_request(request, *args, **kwargs)
        self.request = request
        self.headers = self.default_response_headers  # deprecate?

        try:
            self.initial(request, *args, **kwargs)

            # 获取适当的处理程序方法
            if request.method.lower() in self.http_method_names:
                handler = getattr(self, request.method.lower(),
                                  self.http_method_not_allowed)
            else:
                handler = self.http_method_not_allowed

            response = handler(request, *args, **kwargs)

        except Exception as exc:
            response = self.handle_exception(exc)

        self.response = self.finalize_response(request, response, *args, **kwargs)
        return self.response

    def options(self, request, *args, **kwargs):
        """
       HTTP“ OPTIONS”请求的处理程序方法。
        """
        if self.metadata_class is None:
            return self.http_method_not_allowed(request, *args, **kwargs)
        data = self.metadata_class().determine_metadata(request, self)
        return Response(data, status=status.HTTP_200_OK)
