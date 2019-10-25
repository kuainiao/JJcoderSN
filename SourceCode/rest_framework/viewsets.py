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
            # We also store the mapping of request methods to actions,
            # so that we can later set the action attribute.
            # eg. `self.action = 'list'` on an incoming GET request.
            self.action_map = actions

            # Bind methods to actions
            # This is the bit that's different to a standard view
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

        # take name and docstring from class
        update_wrapper(view, cls, updated=())

        # and possible attributes set by decorators
        # like csrf_exempt from dispatch
        update_wrapper(view, cls.dispatch, assigned=())

        # We need to set these on the view function, so that breadcrumb
        # generation can pick out these bits of information from a
        # resolved URL.
        view.cls = cls
        view.initkwargs = initkwargs
        view.actions = actions
        return csrf_exempt(view)

    def initialize_request(self, request, *args, **kwargs):
        """
        Set the `.action` attribute on the view, depending on the request method.
        """
        request = super().initialize_request(request, *args, **kwargs)
        method = request.method.lower()
        if method == 'options':
            # This is a special case as we always provide handling for the
            # options method in the base `View` class.
            # Unlike the other explicitly defined actions, 'metadata' is implicit.
            self.action = 'metadata'
        else:
            self.action = self.action_map.get(method)
        return request

    def reverse_action(self, url_name, *args, **kwargs):
        """
        Reverse the action for the given `url_name`.
        """
        url_name = '%s-%s' % (self.basename, url_name)
        kwargs.setdefault('request', self.request)

        return reverse(url_name, *args, **kwargs)

    @classmethod
    def get_extra_actions(cls):
        """
        Get the methods that are marked as an extra ViewSet `@action`.
        """
        return [method for _, method in getmembers(cls, _is_extra_action)]

    def get_extra_action_url_map(self):
        """
        Build a map of {names: urls} for the extra actions.

        This method will noop if `detail` was not provided as a view initkwarg.
        """
        action_urls = OrderedDict()

        # exit early if `detail` has not been provided
        if self.detail is None:
            return action_urls

        # filter for the relevant extra actions
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
                pass  # URL requires additional arguments, ignore

        return action_urls


class ViewSet(ViewSetMixin, views.APIView):
    """
    The base ViewSet class does not provide any actions by default.
    """
    pass


class GenericViewSet(ViewSetMixin, generics.GenericAPIView):
    """
    The GenericViewSet class does not provide any actions by default,
    but does include the base set of generic view behavior, such as
    the `get_object` and `get_queryset` methods.
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
