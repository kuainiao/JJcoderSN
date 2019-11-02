from django.core.exceptions import ImproperlyConfigured
from django.views.generic import View
from django.views.generic.list import (
    MultipleObjectMixin,
    MultipleObjectTemplateResponseMixin
)

from .constants import ALL_FIELDS
from .filterset import filterset_factory
from .utils import MigrationNotice, RenameAttributesBase


# TODO: remove metaclass in 2.1
class FilterMixinRenames(RenameAttributesBase):
    renamed_attributes = (
        ('filter_fields', 'filterset_fields', MigrationNotice),
    )


class FilterMixin(metaclass=FilterMixinRenames):
    """
    一个mixin，提供一种显示和处理请求中的FilterSet的方法。
    """
    filterset_class = None
    filterset_fields = ALL_FIELDS
    strict = True

    def get_filterset_class(self):
        """
        返回要在此视图中使用的filterset类
        """
        if self.filterset_class:
            return self.filterset_class
        elif self.model:
            return filterset_factory(model=self.model, fields=self.filterset_fields)
        else:
            msg = "'%s' must define 'filterset_class' or 'model'"
            raise ImproperlyConfigured(msg % self.__class__.__name__)

    def get_filterset(self, filterset_class):
        """
        返回要在此视图中使用的过滤器集的实例。
        """
        kwargs = self.get_filterset_kwargs(filterset_class)
        return filterset_class(**kwargs)

    def get_filterset_kwargs(self, filterset_class):
        """
        返回用于实例化过滤器集的关键字参数。
        """
        kwargs = {
            'data': self.request.GET or None,
            'request': self.request,
        }
        try:
            kwargs.update({
                'queryset': self.get_queryset(),
            })
        except ImproperlyConfigured:
            # 如果过滤器集具有定义的模型以从中获取查询集，请忽略此处的错误
            if filterset_class._meta.model is None:
                msg = ("'%s' does not define a 'model' and the view '%s' does "
                       "not return a valid queryset from 'get_queryset'.  You "
                       "must fix one of them.")
                args = (filterset_class.__name__, self.__class__.__name__)
                raise ImproperlyConfigured(msg % args)
        return kwargs

    def get_strict(self):
        return self.strict


class BaseFilterView(FilterMixin, MultipleObjectMixin, View):

    def get(self, request, *args, **kwargs):
        filterset_class = self.get_filterset_class()
        self.filterset = self.get_filterset(filterset_class)

        if not self.filterset.is_bound or self.filterset.is_valid() or not self.get_strict():
            self.object_list = self.filterset.qs
        else:
            self.object_list = self.filterset.queryset.none()

        context = self.get_context_data(filter=self.filterset,
                                        object_list=self.object_list)
        return self.render_to_response(context)


class FilterView(MultipleObjectTemplateResponseMixin, BaseFilterView):
    """
    渲染一些带有过滤器的对象列表，由“ self.model”或“ self.queryset”设置。
    实际上，`self.queryset`可以是任何可迭代的项目，而不仅仅是查询集。
    """
    template_name_suffix = '_filter'


def object_filter(request, model=None, queryset=None, template_name=None,
                  extra_context=None, context_processors=None,
                  filter_class=None):
    class ECFilterView(FilterView):
        """从功能object_filter视图处理extra_context"""
        def get_context_data(self, **kwargs):
            context = super().get_context_data(**kwargs)
            extra_context = self.kwargs.get('extra_context') or {}
            for k, v in extra_context.items():
                if callable(v):
                    v = v()
                context[k] = v
            return context

    kwargs = dict(model=model, queryset=queryset, template_name=template_name,
                  filterset_class=filter_class)
    view = ECFilterView.as_view(**kwargs)
    return view(request, extra_context=extra_context)
