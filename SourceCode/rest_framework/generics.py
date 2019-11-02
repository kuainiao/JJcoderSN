"""
提供通常需要的行为的通用视图。
"""
from django.core.exceptions import ValidationError
from django.db.models.query import QuerySet
from django.http import Http404
from django.shortcuts import get_object_or_404 as _get_object_or_404

from rest_framework import mixins, views
from rest_framework.settings import api_settings


def get_object_or_404(queryset, *filter_args, **filter_kwargs):
    """
    与Django的标准快捷方式相同，但如果filter_kwargs与所需的类型不匹配，请确保也抛出404。
    """
    try:
        return _get_object_or_404(queryset, *filter_args, **filter_kwargs)
    except (TypeError, ValueError, ValidationError):
        raise Http404


class GenericAPIView(views.APIView):
    """
    所有其他通用视图的基类。
    """
    # 您需要设置这些属性，或覆盖`get_queryset（）`/`get_serializer_class（）`。
    # 如果要覆盖视图方法，则必须调用`get_queryset（）`而不是直接访问`queryset`属性，这一点很重要，
    # 因为`queryset`只会被评估一次，并且所有结果都将被缓存后续请求。
    queryset = None
    serializer_class = None

    # 如果要使用除pk以外的对象查找，请设置'lookup_field'。 对于更复杂的查找要求，请覆盖`get_object（）`。
    lookup_field = 'pk'
    lookup_url_kwarg = None

    # 用于查询集过滤的过​​滤器后端类
    filter_backends = api_settings.DEFAULT_FILTER_BACKENDS

    # 用于查询集分页的样式。
    pagination_class = api_settings.DEFAULT_PAGINATION_CLASS

    def get_queryset(self):
        """
       获取此视图的项目列表。这必须是可迭代的，并且可以是查询集。默认使用`self.queryset`。

        应始终使用此方法，而不是直接访问“ self.queryset”，因为“ self.queryset”仅被评估一次，并且那些结果将为所有后续请求缓存。
        如果您需要根据传入请求提供不同的查询集，则可能要覆盖此设置。(例如，返回特定于用户的商品列表）
        """
        assert self.queryset is not None, (
                "'%s' should either include a `queryset` attribute, "
                "or override the `get_queryset()` method."
                % self.__class__.__name__
        )

        queryset = self.queryset
        if isinstance(queryset, QuerySet):
            # 确保对每个请求重新评估查询集。
            queryset = queryset.all()
        return queryset

    def get_object(self):
        """
        返回视图显示的对象。

        如果需要提供非标准的查询集查找，则可能要覆盖此方法。例如，是否使用url conf中的多个关键字参数引用了对象。
        """
        queryset = self.filter_queryset(self.get_queryset())

        # 执行查找过滤。
        lookup_url_kwarg = self.lookup_url_kwarg or self.lookup_field

        assert lookup_url_kwarg in self.kwargs, (
                'Expected view %s to be called with a URL keyword argument '
                'named "%s". Fix your URL conf, or set the `.lookup_field` '
                'attribute on the view correctly.' %
                (self.__class__.__name__, lookup_url_kwarg)
        )

        filter_kwargs = {self.lookup_field: self.kwargs[lookup_url_kwarg]}
        obj = get_object_or_404(queryset, **filter_kwargs)

        # 可能会提出拒绝的许可
        self.check_object_permissions(self.request, obj)

        return obj

    def get_serializer(self, *args, **kwargs):
        """
        返回应用于验证和反序列化输入以及序列化输出的序列化器实例。
        """
        serializer_class = self.get_serializer_class()
        kwargs['context'] = self.get_serializer_context()
        return serializer_class(*args, **kwargs)

    def get_serializer_class(self):
        """
        返回用于序列化器的类。默认使用`self.serializer_class`。

        如果您需要根据传入请求提供不同的序列化，则可能需要覆盖此方法。（例如，管理员获得完整的序列化，其他获得基本的序列化）
        """
        assert self.serializer_class is not None, (
                "'%s' should either include a `serializer_class` attribute, "
                "or override the `get_serializer_class()` method."
                % self.__class__.__name__
        )

        return self.serializer_class

    def get_serializer_context(self):
        """
        提供给序列化程序类的额外上下文。
        """
        return {
            'request': self.request,
            'format': self.format_kwarg,
            'view': self
        }

    def filter_queryset(self, queryset):
        """
        给定一个查询集，请使用哪个过滤器后端对其进行过滤。
尽管您可能需要从列表视图或自定义“ get_object”方法调用它（如果要将配置的过滤后端应用于默认查询集），但您不太可能希望覆盖此方法。
        """
        for backend in list(self.filter_backends):
            queryset = backend().filter_queryset(self.request, queryset, self)
        return queryset

    @property
    def paginator(self):
        """
        与视图关联的分页器实例，或“None”。
        """
        if not hasattr(self, '_paginator'):
            if self.pagination_class is None:
                self._paginator = None
            else:
                self._paginator = self.pagination_class()
        return self._paginator

    def paginate_queryset(self, queryset):
        """
        返回单页结果；如果禁用了分页，则返回“None”。
        """
        if self.paginator is None:
            return None
        return self.paginator.paginate_queryset(queryset, self.request, view=self)

    def get_paginated_response(self, data):
        """
        返回给定输出数据的分页样式`Response`对象。
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data)


# 提供方法处理程序的具体视图类 通过将mixin类与基本视图组成。

class CreateAPIView(mixins.CreateModelMixin,
                    GenericAPIView):
    """
    用于创建模型实例的具体视图。
    """

    def post(self, request, *args, **kwargs):
        return self.create(request, *args, **kwargs)


class ListAPIView(mixins.ListModelMixin,
                  GenericAPIView):
    """
    列出查询集的具体视图。
    """

    def get(self, request, *args, **kwargs):
        return self.list(request, *args, **kwargs)


class RetrieveAPIView(mixins.RetrieveModelMixin,
                      GenericAPIView):
    """
    用于检索模型实例的具体视图。
    """

    def get(self, request, *args, **kwargs):
        return self.retrieve(request, *args, **kwargs)


class DestroyAPIView(mixins.DestroyModelMixin,
                     GenericAPIView):
    """
    用于删除模型实例的具体视图。
    """

    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)


class UpdateAPIView(mixins.UpdateModelMixin,
                    GenericAPIView):
    """
    用于更新模型实例的具体视图。
    """

    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    def patch(self, request, *args, **kwargs):
        return self.partial_update(request, *args, **kwargs)


class ListCreateAPIView(mixins.ListModelMixin,
                        mixins.CreateModelMixin,
                        GenericAPIView):
    """
   列出查询集或创建模型实例的具体视图。
    """

    def get(self, request, *args, **kwargs):
        return self.list(request, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        return self.create(request, *args, **kwargs)


class RetrieveUpdateAPIView(mixins.RetrieveModelMixin,
                            mixins.UpdateModelMixin,
                            GenericAPIView):
    """
    用于检索，更新模型实例的具体视图。
    """

    def get(self, request, *args, **kwargs):
        return self.retrieve(request, *args, **kwargs)

    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    def patch(self, request, *args, **kwargs):
        return self.partial_update(request, *args, **kwargs)


class RetrieveDestroyAPIView(mixins.RetrieveModelMixin,
                             mixins.DestroyModelMixin,
                             GenericAPIView):
    """
    用于检索或删除模型实例的具体视图。
    """

    def get(self, request, *args, **kwargs):
        return self.retrieve(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)


class RetrieveUpdateDestroyAPIView(mixins.RetrieveModelMixin,
                                   mixins.UpdateModelMixin,
                                   mixins.DestroyModelMixin,
                                   GenericAPIView):
    """
    用于检索，更新或删除模型实例的具体视图。
    """

    def get(self, request, *args, **kwargs):
        return self.retrieve(request, *args, **kwargs)

    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    def patch(self, request, *args, **kwargs):
        return self.partial_update(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)
