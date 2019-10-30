"""
路由器提供一种方便且一致的自动方式确定您的API的URL conf。只需实例化Router类，然后注册即可使用它们
该路由器的所有必需ViewSet。例如，您可能有一个类似以下内容的“ urls.py”：

    router = routers.DefaultRouter()
    router.register('users', UserViewSet, 'user')
    router.register('accounts', AccountViewSet, 'account')

    urlpatterns = router.urls
"""
import itertools
import warnings
from collections import OrderedDict, namedtuple

from django.conf.urls import url
from django.core.exceptions import ImproperlyConfigured
from django.urls import NoReverseMatch
from django.utils.deprecation import RenameMethodsBase

from rest_framework import RemovedInDRF311Warning, views
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework.schemas import SchemaGenerator
from rest_framework.schemas.views import SchemaView
from rest_framework.settings import api_settings
from rest_framework.urlpatterns import format_suffix_patterns

Route = namedtuple('Route', ['url', 'mapping', 'name', 'detail', 'initkwargs'])
DynamicRoute = namedtuple('DynamicRoute', ['url', 'name', 'detail', 'initkwargs'])


def escape_curly_brackets(url_path):
    """
    url_path的正则表达式中的双括号，用于转义字符串格式
    """
    if ('{' and '}') in url_path:
        url_path = url_path.replace('{', '{{').replace('}', '}}')
    return url_path


def flatten(list_of_lists):
    """
    接受一个iterable的iterable，返回包含所有项目的单个iterable
    """
    return itertools.chain(*list_of_lists)


class RenameRouterMethods(RenameMethodsBase):
    renamed_methods = (
        ('get_default_base_name', 'get_default_basename', RemovedInDRF311Warning),
    )


class BaseRouter(metaclass=RenameRouterMethods):  # 这是一个元类
    def __init__(self):
        self.registry = []

    """
    register()` 方法有两个必须参数：  

    `prefix` - 设置这组路由的前缀。
    `viewset` - 设置对应的视图集类。
    """

    def register(self, prefix, viewset, basename=None, base_name=None):
        if base_name is not None:
            msg = "The `base_name` argument is pending deprecation in favor of `basename`."
            warnings.warn(msg, RemovedInDRF311Warning, 2)

        assert not (basename and base_name), (
            "Do not provide both the `basename` and `base_name` arguments.")

        if basename is None:
            basename = base_name

        if basename is None:
            basename = self.get_default_basename(viewset)
        self.registry.append((prefix, viewset, basename))

        # 使网址缓存无效
        if hasattr(self, '_urls'):
            del self._urls

    def get_default_basename(self, viewset):
        """
        如果未指定`basename`，请尝试根据视图集自动确定它。
        """
        raise NotImplementedError('get_default_basename must be overridden')

    def get_urls(self):
        """
        给定已注册的视图集，返回URL模式列表。
        """
        raise NotImplementedError('get_urls must be overridden')

    @property
    def urls(self):
        if not hasattr(self, '_urls'):
            self._urls = self.get_urls()
        return self._urls


class SimpleRouter(BaseRouter):
    routes = [
        # List route.
        Route(
            url=r'^{prefix}{trailing_slash}$',
            mapping={
                'get': 'list',
                'post': 'create'
            },
            name='{basename}-list',
            # `base_name` - 用于创建的 URL 名称的基础。如果未设置，将根据视图集的 `queryset` 属性自动生成。
            # 请注意，如果视图集不包含 `queryset` 属性，则在注册视图集时必须设置 `base_name`。
            detail=False,
            initkwargs={'suffix': 'List'}
        ),
        # 动态生成的列表路由。使用@action（detail = False）装饰器在视图集的方法上生成。
        DynamicRoute(
            url=r'^{prefix}/{url_path}{trailing_slash}$',
            name='{basename}-{url_name}',
            detail=False,
            initkwargs={}
        ),
        # Detail route.
        Route(
            url=r'^{prefix}/{lookup}{trailing_slash}$',
            mapping={
                'get': 'retrieve',
                'put': 'update',
                'patch': 'partial_update',
                'delete': 'destroy'
            },
            name='{basename}-detail',
            detail=True,
            initkwargs={'suffix': 'Instance'}
        ),
        # 动态生成的详细路线。使用@action（detail = True）装饰器在视图集的方法上生成。
        DynamicRoute(
            url=r'^{prefix}/{lookup}/{url_path}{trailing_slash}$',
            name='{basename}-{url_name}',
            detail=True,
            initkwargs={}
        ),
    ]

    def __init__(self, trailing_slash=True):
        self.trailing_slash = '/' if trailing_slash else ''
        super().__init__()

    def get_default_basename(self, viewset):
        """
        如果未指定`basename`，请尝试根据视图集自动确定它。
        """
        queryset = getattr(viewset, 'queryset', None)

        assert queryset is not None, '`basename` argument not specified, and could ' \
                                     'not automatically determine the name from the viewset, as ' \
                                     'it does not have a `.queryset` attribute.'

        return queryset.model._meta.object_name.lower()

    def get_routes(self, viewset):
        """
        使用任何动态生成的路由来增强`self.routes`。

       返回Route namedtuple的列表。
        """
        # 转换为列表是可迭代的，因为它一次通过就很好了，需要为个不同的功能一次又一次地检查已知的主机。
        known_actions = list(flatten([route.mapping.values() for route in self.routes if isinstance(route, Route)]))
        extra_actions = viewset.get_extra_actions()

        # 根据已知动作列表检查动作名称
        not_allowed = [
            action.__name__ for action in extra_actions
            if action.__name__ in known_actions
        ]
        if not_allowed:
            msg = ('Cannot use the @action decorator on the following '
                   'methods, as they are existing routes: %s')
            raise ImproperlyConfigured(msg % ', '.join(not_allowed))

        # 分区详细信息和列表操作
        detail_actions = [action for action in extra_actions if action.detail]
        list_actions = [action for action in extra_actions if not action.detail]

        routes = []
        for route in self.routes:
            if isinstance(route, DynamicRoute) and route.detail:
                routes += [self._get_dynamic_route(route, action) for action in detail_actions]
            elif isinstance(route, DynamicRoute) and not route.detail:
                routes += [self._get_dynamic_route(route, action) for action in list_actions]
            else:
                routes.append(route)

        return routes

    def _get_dynamic_route(self, route, action):
        initkwargs = route.initkwargs.copy()
        initkwargs.update(action.kwargs)

        url_path = escape_curly_brackets(action.url_path)

        return Route(
            url=route.url.replace('{url_path}', url_path),
            mapping=action.mapping,
            name=route.name.replace('{url_name}', action.url_name),
            detail=route.detail,
            initkwargs=initkwargs,
        )

    def get_method_map(self, viewset, method_map):
        """
        给定一个视图集，以及http方法到操作的映射，返回一个新映射，该映射仅包含该视图集实际实现的任何映射。
        """
        bound_methods = {}
        for method, action in method_map.items():
            if hasattr(viewset, action):
                bound_methods[method] = action
        return bound_methods

    def get_lookup_regex(self, viewset, lookup_prefix=''):
        """
        给定一个视图集，返回URL正则表达式中用于与单个实例匹配的部分。

        请注意，lookup_prefix并非直接在REST rest_framework本身内部使用，而是为了很好地支持嵌套路由器实现（例如drf-nested-routers）而必需的。
        https://github.com/alanjds/drf-nested-routers
        """
        base_regex = '(?P<{lookup_prefix}{lookup_url_kwarg}>{lookup_value})'
        # Use `pk` as default field, unset set.  Default regex should not
        # consume `.json` style suffixes and should break at '/' boundaries.
        lookup_field = getattr(viewset, 'lookup_field', 'pk')
        lookup_url_kwarg = getattr(viewset, 'lookup_url_kwarg', None) or lookup_field
        lookup_value = getattr(viewset, 'lookup_value_regex', '[^/.]+')
        return base_regex.format(
            lookup_prefix=lookup_prefix,
            lookup_url_kwarg=lookup_url_kwarg,
            lookup_value=lookup_value
        )

    def get_urls(self):
        """
        使用注册的视图集生成URL模式列表。
        """
        ret = []

        for prefix, viewset, basename in self.registry:
            lookup = self.get_lookup_regex(viewset)
            routes = self.get_routes(viewset)

            for route in routes:

                # 仅绑定实际存在于视图集上的动作
                mapping = self.get_method_map(viewset, route.mapping)
                if not mapping:
                    continue

                # 建立网址格式
                regex = route.url.format(
                    prefix=prefix,
                    lookup=lookup,
                    trailing_slash=self.trailing_slash
                )

                # 如果没有前缀，则URL的第一部分可能是由项目的urls.py控制的，而路由器位于应用程序中，
                # 因此开头的斜线将（A）导致Django发出＃警告，并且（B）生成需要使用“ //”的URL。
                if not prefix and regex[:2] == '^/':
                    regex = '^' + regex[2:]

                initkwargs = route.initkwargs.copy()
                initkwargs.update({
                    'basename': basename,
                    'detail': route.detail,
                })

                view = viewset.as_view(mapping, **initkwargs)
                name = route.name.format(basename=basename)
                ret.append(url(regex, view, name=name))

        return ret


class APIRootView(views.APIView):
    """
    DefaultRouter的默认基本根视图
    """
    _ignore_model_permissions = True
    schema = None  # exclude from schema
    api_root_dict = None

    def get(self, request, *args, **kwargs):
        # 返回一个简单的{“ name”：“ hyperlink”}响应。
        ret = OrderedDict()
        namespace = request.resolver_match.namespace
        for key, url_name in self.api_root_dict.items():
            if namespace:
                url_name = namespace + ':' + url_name
            try:
                ret[key] = reverse(
                    url_name,
                    args=args,
                    kwargs=kwargs,
                    request=request,
                    format=kwargs.get('format', None)
                )
            except NoReverseMatch:
                # 例如，不要纾困。没有列表路由，只有明细路由。
                continue

        return Response(ret)


class DefaultRouter(SimpleRouter):
    """
    默认路由器扩展了SimpleRouter，但还添加了默认API根视图，并向URL添加了格式后缀模式。
    """
    include_root_view = True
    include_format_suffixes = True
    root_view_name = 'api-root'
    default_schema_renderers = None
    APIRootView = APIRootView
    APISchemaView = SchemaView
    SchemaGenerator = SchemaGenerator

    def __init__(self, *args, **kwargs):
        if 'root_renderers' in kwargs:
            self.root_renderers = kwargs.pop('root_renderers')
        else:
            self.root_renderers = list(api_settings.DEFAULT_RENDERER_CLASSES)
        super().__init__(*args, **kwargs)

    def get_api_root_view(self, api_urls=None):
        """
        返回基本的根视图。
        """
        api_root_dict = OrderedDict()
        list_name = self.routes[0].name
        for prefix, viewset, basename in self.registry:
            api_root_dict[prefix] = list_name.format(basename=basename)

        return self.APIRootView.as_view(api_root_dict=api_root_dict)

    def get_urls(self):
        """
        生成URL模式列表，包括API的默认根视图，并附加`.json`样式格式后缀。
        """
        urls = super().get_urls()

        if self.include_root_view:
            view = self.get_api_root_view(api_urls=urls)
            root_url = url(r'^$', view, name=self.root_view_name)
            urls.append(root_url)

        if self.include_format_suffixes:
            urls = format_suffix_patterns(urls)

        return urls
