"""
我们在序列化程序类上显式执行唯一性检查，而不是使用Django的`.full_clean（）`。

这使我们可以更好地分离关注点，允许我们使用单步执行对象创建，并可以在使用隐式方法之间进行切换ModelSerializer类和等效的显式Serializer类。
"""
from django.db import DataError
from django.utils.translation import gettext_lazy as _

from rest_framework.exceptions import ValidationError
from rest_framework.utils.representation import smart_repr


# 健壮的过滤器并存在。确保queryset.exists（）用于无效的值返回False，而不是引发错误。
# Refs https://github.com/encode/django-rest-framework/issues/3381
def qs_exists(queryset):
    try:
        return queryset.exists()
    except (TypeError, ValueError, DataError):
        return False


def qs_filter(queryset, **kwargs):
    try:
        return queryset.filter(**kwargs)
    except (TypeError, ValueError, DataError):
        return queryset.none()


class UniqueValidator:
    """
   在模型字段上对应于“ unique = True”的验证器。应该应用于序列化器上的单个字段。
   queryset 必须 - 这是验证唯一性的查询集。
   message - 验证失败时使用的错误消息。
   lookup - 用于查找已验证值的现有实例。默认为 `'exact'`。
    """

    message = _('This field must be unique.')

    def __init__(self, queryset, message=None, lookup='exact'):
        self.queryset = queryset
        self.serializer_field = None
        self.message = message or self.message
        self.lookup = lookup

    def set_context(self, serializer_field):
        """
        在进行验证调用之前，该挂钩由序列化程序实例调用。
        """
        # 确定基础模型字段名称。如果设置了“ source = <>”，则此名称可能与序列化器字段名称不同。
        self.field_name = serializer_field.source_attrs[-1]
        # 如果这是更新操作，请确定现有实例。
        self.instance = getattr(serializer_field.parent, 'instance', None)

    def filter_queryset(self, value, queryset):
        """
        将查询集过滤到与给定属性匹配的所有实例。
        """
        filter_kwargs = {'%s__%s' % (self.field_name, self.lookup): value}
        return qs_filter(queryset, **filter_kwargs)

    def exclude_current_instance(self, queryset):
        """
        如果实例正在更新，则不要将该实例本身包括为唯一性冲突。
        """
        if self.instance is not None:
            return queryset.exclude(pk=self.instance.pk)
        return queryset

    def __call__(self, value):
        queryset = self.queryset
        queryset = self.filter_queryset(value, queryset)
        queryset = self.exclude_current_instance(queryset)
        if qs_exists(queryset):
            raise ValidationError(self.message, code='unique')

    def __repr__(self):
        return '<%s(queryset=%s)>' % (
            self.__class__.__name__,
            smart_repr(self.queryset)
        )


class UniqueTogetherValidator:
    """
    验证器，它对应于模型类上的`unique_together =（...）`。应该应用于序列化程序类，而不是单个字段。
    * `queryset` *必须* - 这是验证唯一性的查询集。
    * `fields` *必须* - 一个存放字段名称的列表或者元组，这个集合必须是唯一的（意思是集合中的字段代表的一组值不能同时出现在两条数据中）。这些字段必须都是序列化类中的字段。
    * `message` - 验证失败时使用的错误消息。
    """
    message = _('The fields {field_names} must make a unique set.')
    missing_message = _('This field is required.')

    def __init__(self, queryset, fields, message=None):
        self.queryset = queryset
        self.fields = fields
        self.serializer_field = None
        self.message = message or self.message

    def set_context(self, serializer):
        """
        在进行验证调用之前，该挂钩由序列化程序实例调用。
        """
        # 如果这是更新操作，请确定现有实例。
        self.instance = getattr(serializer, 'instance', None)

    def enforce_required_fields(self, attrs):
        """
        “ UniqueTogetherValidator”始终在其适用的字段上强制使用隐含的“required”状态。
        """
        if self.instance is not None:
            return

        missing_items = {
            field_name: self.missing_message
            for field_name in self.fields
            if field_name not in attrs
        }
        if missing_items:
            raise ValidationError(missing_items, code='required')

    def filter_queryset(self, attrs, queryset):
        """
        将查询集过滤到与给定属性匹配的所有实例。
        """
        # 如果这是更新，则任何未提供的字段都应根据现有的instance属性设置其值。
        if self.instance is not None:
            for field_name in self.fields:
                if field_name not in attrs:
                    attrs[field_name] = getattr(self.instance, field_name)

        # 确定过滤器关键字参数并过滤查询集。
        filter_kwargs = {
            field_name: attrs[field_name]
            for field_name in self.fields
        }
        return qs_filter(queryset, **filter_kwargs)

    def exclude_current_instance(self, attrs, queryset):
        """
        如果实例正在更新，则不要将该实例本身包括为唯一性冲突。
        """
        if self.instance is not None:
            return queryset.exclude(pk=self.instance.pk)
        return queryset

    def __call__(self, attrs):
        self.enforce_required_fields(attrs)
        queryset = self.queryset
        queryset = self.filter_queryset(attrs, queryset)
        queryset = self.exclude_current_instance(attrs, queryset)

        # 如果任何字段为None，则忽略验证
        checked_values = [
            value for field, value in attrs.items() if field in self.fields
        ]
        if None not in checked_values and qs_exists(queryset):
            field_names = ', '.join(self.fields)
            message = self.message.format(field_names=field_names)
            raise ValidationError(message, code='unique')

    def __repr__(self):
        return '<%s(queryset=%s, fields=%s)>' % (
            self.__class__.__name__,
            smart_repr(self.queryset),
            smart_repr(self.fields)
        )


class BaseUniqueForValidator:
    message = None
    missing_message = _('This field is required.')

    def __init__(self, queryset, field, date_field, message=None):
        self.queryset = queryset
        self.field = field
        self.date_field = date_field
        self.message = message or self.message

    def set_context(self, serializer):
        """
        在进行验证调用之前，该挂钩由序列化程序实例调用。
        """
        # 确定基础模型字段名称。如果设置了`source = <>`，则这些名称可能与序列化器字段名称不同。
        self.field_name = serializer.fields[self.field].source_attrs[-1]
        self.date_field_name = serializer.fields[self.date_field].source_attrs[-1]
        # Determine the existing instance, if this is an update operation.
        self.instance = getattr(serializer, 'instance', None)

    def enforce_required_fields(self, attrs):
        """
        “ UniqueFor <Range> Validator”类始终在它们应用于的字段上强制隐含“required”状态。
        """
        missing_items = {
            field_name: self.missing_message
            for field_name in [self.field, self.date_field]
            if field_name not in attrs
        }
        if missing_items:
            raise ValidationError(missing_items, code='required')

    def filter_queryset(self, attrs, queryset):
        raise NotImplementedError('`filter_queryset` must be implemented.')

    def exclude_current_instance(self, attrs, queryset):
        """
        如果实例正在更新，则不要将该实例本身包括为唯一性冲突。
        """
        if self.instance is not None:
            return queryset.exclude(pk=self.instance.pk)
        return queryset

    def __call__(self, attrs):
        self.enforce_required_fields(attrs)
        queryset = self.queryset
        queryset = self.filter_queryset(attrs, queryset)
        queryset = self.exclude_current_instance(attrs, queryset)
        if qs_exists(queryset):
            message = self.message.format(date_field=self.date_field)
            raise ValidationError({
                self.field: message
            }, code='unique')

    def __repr__(self):
        return '<%s(queryset=%s, field=%s, date_field=%s)>' % (
            self.__class__.__name__,
            smart_repr(self.queryset),
            smart_repr(self.field),
            smart_repr(self.date_field)
        )


"""
下面三个关于时间的Validator
* `queryset` *必须* - 这是验证唯一性的查询集。
* `field` *必须* - 在给定日期范围内需要被验证唯一性的字段的名称。该字段必须是序列化类中的字段。
* `date_field` *必须* - 将用于确定唯一性约束的日期范围的字段名称。该字段必须是序列化类中的字段。
* `message` - 验证失败时使用的错误消息。
"""


class UniqueForDateValidator(BaseUniqueForValidator):
    message = _('This field must be unique for the "{date_field}" date.')

    def filter_queryset(self, attrs, queryset):
        value = attrs[self.field]
        date = attrs[self.date_field]

        filter_kwargs = {}
        filter_kwargs[self.field_name] = value
        filter_kwargs['%s__day' % self.date_field_name] = date.day
        filter_kwargs['%s__month' % self.date_field_name] = date.month
        filter_kwargs['%s__year' % self.date_field_name] = date.year
        return qs_filter(queryset, **filter_kwargs)


class UniqueForMonthValidator(BaseUniqueForValidator):
    message = _('This field must be unique for the "{date_field}" month.')

    def filter_queryset(self, attrs, queryset):
        value = attrs[self.field]
        date = attrs[self.date_field]

        filter_kwargs = {}
        filter_kwargs[self.field_name] = value
        filter_kwargs['%s__month' % self.date_field_name] = date.month
        return qs_filter(queryset, **filter_kwargs)


class UniqueForYearValidator(BaseUniqueForValidator):
    message = _('This field must be unique for the "{date_field}" year.')

    def filter_queryset(self, attrs, queryset):
        value = attrs[self.field]
        date = attrs[self.date_field]

        filter_kwargs = {}
        filter_kwargs[self.field_name] = value
        filter_kwargs['%s__year' % self.date_field_name] = date.year
        return qs_filter(queryset, **filter_kwargs)
