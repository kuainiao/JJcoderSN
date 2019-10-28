from django.core.exceptions import ImproperlyConfigured
from django.db import models
from django.http import Http404
from django.utils.translation import gettext as _
from django.views.generic.base import ContextMixin, TemplateResponseMixin, View


class SingleObjectMixin(ContextMixin):
    """
    提供检索单个对象以进行进一步操作的能力。
    """
    model = None
    queryset = None
    slug_field = 'slug'
    context_object_name = None
    slug_url_kwarg = 'slug'
    pk_url_kwarg = 'pk'
    query_pk_and_slug = False

    def get_object(self, queryset=None):
        """
        返回视图显示的对象。在URLconf中需要`self.queryset`和一个`pk`或`slug`参数。子类可以重写此方法以返回任何对象。
        """
        # 如果提供的话，请使用自定义查询集；这对于子类是必需的，例如DateDetailView
        if queryset is None:
            queryset = self.get_queryset()

        # 接下来，尝试按主键查找。
        pk = self.kwargs.get(self.pk_url_kwarg)
        slug = self.kwargs.get(self.slug_url_kwarg)
        if pk is not None:
            queryset = queryset.filter(pk=pk)

        # Next, try looking up by slug.
        if slug is not None and (pk is None or self.query_pk_and_slug):
            slug_field = self.get_slug_field()
            queryset = queryset.filter(**{slug_field: slug})

        # If none of those are defined, it's an error.
        if pk is None and slug is None:
            raise AttributeError(
                "Generic detail view %s must be called with either an object "
                "pk or a slug in the URLconf." % self.__class__.__name__
            )

        try:
            # Get the single item from the filtered queryset
            obj = queryset.get()
        except queryset.model.DoesNotExist:
            raise Http404(_("No %(verbose_name)s found matching the query") %
                          {'verbose_name': queryset.model._meta.verbose_name})
        return obj

    def get_queryset(self):
        """
        返回将用于查找对象的“ QuerySet”。此方法由get_object（）的默认实现调用，并且如果get_object（）被覆盖，则可能不会调用此方法。
        """
        if self.queryset is None:
            if self.model:
                return self.model._default_manager.all()
            else:
                raise ImproperlyConfigured(
                    "%(cls)s is missing a QuerySet. Define "
                    "%(cls)s.model, %(cls)s.queryset, or override "
                    "%(cls)s.get_queryset()." % {
                        'cls': self.__class__.__name__
                    }
                )
        return self.queryset.all()

    def get_slug_field(self):
        """获取将由Slug查找的Slug字段的名称。"""
        return self.slug_field

    def get_context_object_name(self, obj):
        """获取用于对象的名称。"""
        if self.context_object_name:
            return self.context_object_name
        elif isinstance(obj, models.Model):
            return obj._meta.model_name
        else:
            return None

    def get_context_data(self, **kwargs):
        """将单个对象插入上下文字典中。"""
        context = {}
        if self.object:
            context['object'] = self.object
            context_object_name = self.get_context_object_name(self.object)
            if context_object_name:
                context[context_object_name] = self.object
        context.update(kwargs)
        return super().get_context_data(**context)


class BaseDetailView(SingleObjectMixin, View):
    """用于显示单个对象的基本视图。"""
    def get(self, request, *args, **kwargs):
        self.object = self.get_object()
        context = self.get_context_data(object=self.object)
        return self.render_to_response(context)


class SingleObjectTemplateResponseMixin(TemplateResponseMixin):
    template_name_field = None
    template_name_suffix = '_detail'

    def get_template_names(self):
        """
        返回用于请求的模板名称列表。如果render_to_response（）被覆盖，则可能不会被调用。返回以下列表：

        * the value of ``template_name`` on the view (if provided)
        * the contents of the ``template_name_field`` field on the
          object instance that the view is operating upon (if available)
        * ``<app_label>/<model_name><template_name_suffix>.html``
        """
        try:
            names = super().get_template_names()
        except ImproperlyConfigured:
            # 如果未指定template_name，则没有问题-我们从一个空列表开始。
            names = []

            # 如果设置了self.template_name_field，则从对象中获取该名称的字段的值；如果指定的话，这是最具体的模板名称。
            if self.object and self.template_name_field:
                name = getattr(self.object, self.template_name_field, None)
                if name:
                    names.insert(0, name)

            # 最不明确的选项是默认的<app> / <model> _detail.html; 仅在相关对象是模型时才使用此功能。
            if isinstance(self.object, models.Model):
                object_meta = self.object._meta
                names.append("%s/%s%s.html" % (
                    object_meta.app_label,
                    object_meta.model_name,
                    self.template_name_suffix
                ))
            elif getattr(self, 'model', None) is not None and issubclass(self.model, models.Model):
                names.append("%s/%s%s.html" % (
                    self.model._meta.app_label,
                    self.model._meta.model_name,
                    self.template_name_suffix
                ))

            # 如果仍然无法找到任何模板名称，则应重新引发ImproperlyConfigured来警告用户。
            if not names:
                raise

        return names


class DetailView(SingleObjectTemplateResponseMixin, BaseDetailView):
    """
    渲染对象的“详细”视图。默认情况下，这是一个从self.queryset查找的模型实例，但是视图将通过覆盖self.get_object（）来支持* any *对象的显示。
    """
