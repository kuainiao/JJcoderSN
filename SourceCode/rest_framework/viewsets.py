"""
ViewSet本质上只是基于类的视图的一种，它不提供任何方法处理程序，例如`get（）`，`post（）`等，但是具有操作，
例如`list（）`，`retrieve（）`，`create（）`等。

A功能仅在实例化视图时绑定到方法。

    user_list = UserViewSet.as_view({'get': 'list'})
    user_detail = UserViewSet.as_view({'get': 'retrieve'})

通常，您将直接从视图集中实例化视图，而不是向路由器注册视图集，然后确定URL conf自动。
    router = DefaultRouter()
    router.register(r'users', UserViewSet, 'user')
    urlpatterns = router.urls
"""
from collections import OrderedDict
from functools import update_wrapper
from inspect import getmembers

from django.urls import NoReverseMatch
from django.utils.decorators import classonlymethod
from django.views.decorators.csrf import csrf_exempt

from rest_framework import generics, mixins, views
from rest_framework.reverse import reverse


def _is_extra_action(attr):
    return hasattr(attr, 'mapping')


class ViewSetMixin:
    """
    这就是魔术。覆盖.as_view（），以便它采用一个actions关键字，该关键字将HTTP方法绑定到Resource上的操作。
    例如，要创建将“ GET”和“ POST”方法绑定到“ list”和“ create”操作的具体视图...

    view = MyViewSet.as_view({'get': 'list', 'post': 'create'})
    """

    @classonlymethod
    def as_view(cls, actions=None, **initkwargs):
        """
        由于基于类的视图围绕实例化视图创建闭包的方式，我们需要完全重新实现`.as_view`，并略微修改所创建和返回的视图函数。
        """
        # 名称和说明initkwargs对于某些路由配置可以被显式覆盖。例如，额外动作的名称。
        cls.name = None
        cls.description = None

        # 后缀initkwarg保留用于显示视图集类型。 如果提供了名称，此initkwarg应该无效。 例如“列表”或“实例”。
        cls.suffix = None

        # 详细信息initkwarg保留用于自检视图集类型。
        cls.detail = None

        # 设置基本名称允许视图反转其操作URL。该值由路由器通过initkwargs提供。
        cls.basename = None

        # actions must not be empty
        if not actions:
            raise TypeError("The `actions` argument must be provided when "
                            "calling `.as_view()` on a ViewSet. For example "
                            "`.as_view({'get': 'list'})`")

        # sanitize keyword arguments
        for key in initkwargs:
            if key in cls.http_method_names:
                raise TypeError("You tried to pass in the %s method name as a "
                                "keyword argument to %s(). Don't do that."
                                % (key, cls.__name__))
            if not hasattr(cls, key):
                raise TypeError("%s() received an invalid keyword %r" % (
                    cls.__name__, key))

        # name and suffix are mutually exclusive
        if 'name' in initkwargs and 'suffix' in initkwargs:
            raise TypeError("%s() received both `name` and `suffix`, which are "
                            "mutually exclusive arguments." % (cls.__name__))

        def view(request, *args, **kwargs):
            self = cls(**initkwargs)
            # 我们还存储了请求方法到动作的映射，以便以后可以设置动作属性。 例如传入的GET请求上的`self.action ='list'`。
            self.action_map = actions

            # 将方法绑定到操作＃这与标准视图不同
            for method, action in actions.items():
                handler = getattr(self, action)
                setattr(self, method, handler)

            if hasattr(self, 'get') and not hasattr(self, 'head'):
                self.head = self.get

            self.request = request
            self.args = args
            self.kwargs = kwargs

            # And continue as usual
            return self.dispatch(request, *args, **kwargs)

        # 从类中获取名称和文档字符串
        update_wrapper(view, cls, updated=())

        # 以及由装饰器＃设置的可能属性，例如csrf_exempt from dispatch
        update_wrapper(view, cls.dispatch, assigned=())

        # 我们需要在视图函数上进行设置，以便面包屑生成可以从解析的URL中挑选出这些信息。
        view.cls = cls
        view.initkwargs = initkwargs
        view.actions = actions
        return csrf_exempt(view)

    def initialize_request(self, request, *args, **kwargs):
        """
        根据请求方法，在视图上设置`.action`属性。
        """
        request = super().initialize_request(request, *args, **kwargs)
        method = request.method.lower()
        if method == 'options':
            # 这是一种特殊情况，因为我们始终在基类View中为options方法提供处理。 与其他显式定义的操作不同，“元数据”是隐式的。
            self.action = 'metadata'
        else:
            self.action = self.action_map.get(method)
        return request

    def reverse_action(self, url_name, *args, **kwargs):
        """
        对给定的“ url_name”执行相反的操作。
        """
        url_name = '%s-%s' % (self.basename, url_name)
        kwargs.setdefault('request', self.request)

        return reverse(url_name, *args, **kwargs)

    @classmethod
    def get_extra_actions(cls):
        """
        获取标记为额外的ViewSet`@ action`的方法。
        """
        return [method for _, method in getmembers(cls, _is_extra_action)]

    def get_extra_action_url_map(self):
        """
        构建{names：urls}的映射以进行其他操作。如果未提供`detail`作为视图initkwarg，则此方法将不执行任何操作。
        """
        action_urls = OrderedDict()

        # 如果未提供“详细信息”，请提早退出
        if self.detail is None:
            return action_urls

        # 过滤相关的额外操作
        actions = [
            action for action in self.get_extra_actions()
            if action.detail == self.detail
        ]

        for action in actions:
            try:
                url_name = '%s-%s' % (self.basename, action.url_name)
                url = reverse(url_name, self.args, self.kwargs, request=self.request)
                view = self.__class__(**action.kwargs)
                action_urls[view.get_view_name()] = url
            except NoReverseMatch:
                pass  # URL需要其他参数，请忽略

        return action_urls


class ViewSet(ViewSetMixin, views.APIView):
    """
    默认情况下，基ViewSet类不提供任何操作。
    """
    pass


class GenericViewSet(ViewSetMixin, generics.GenericAPIView):
    """
    默认情况下，GenericViewSet类不提供任何操作，但包含通用视图行为的基本集合，例如get_object和get_queryset方法。
    """
    pass


class ReadOnlyModelViewSet(mixins.RetrieveModelMixin,
                           mixins.ListModelMixin,
                           GenericViewSet):
    """
    提供默认`list（）`和`retrieve（）`操作的视图集。
    """
    pass


class ModelViewSet(mixins.CreateModelMixin,
                   mixins.RetrieveModelMixin,
                   mixins.UpdateModelMixin,
                   mixins.DestroyModelMixin,
                   mixins.ListModelMixin,
                   GenericViewSet):
    """
    一个视图集，提供默认的create（），retrieve（），update（），partial_update（），destroy（）和list（）操作。
    """
    pass
