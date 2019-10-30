"""
Form classes
"""

import copy
from collections import OrderedDict

from django.core.exceptions import NON_FIELD_ERRORS, ValidationError
# BoundField is imported for backwards compatibility in Django 1.9
from django.forms.boundfield import BoundField  # NOQA
from django.forms.fields import Field, FileField
# pretty_name is imported for backwards compatibility in Django 1.9
from django.forms.utils import ErrorDict, ErrorList, pretty_name  # NOQA
from django.forms.widgets import Media, MediaDefiningClass
from django.utils.functional import cached_property
from django.utils.html import conditional_escape, html_safe
from django.utils.safestring import mark_safe
from django.utils.translation import gettext as _

from .renderers import get_default_renderer

__all__ = ('BaseForm', 'Form')


class DeclarativeFieldsMetaclass(MediaDefiningClass):
    """收集在基类上声明的字段。"""

    def __new__(mcs, name, bases, attrs):
        # 从当前类中收集字段。
        current_fields = []
        for key, value in list(attrs.items()):
            if isinstance(value, Field):
                current_fields.append((key, value))
                attrs.pop(key)
        attrs['declared_fields'] = OrderedDict(current_fields)

        new_class = super(DeclarativeFieldsMetaclass, mcs).__new__(mcs, name, bases, attrs)

        # 遍历MRO。
        declared_fields = OrderedDict()
        for base in reversed(new_class.__mro__):
            # 从基类收集字段。
            if hasattr(base, 'declared_fields'):
                declared_fields.update(base.declared_fields)

            # Field shadowing.
            for attr, value in base.__dict__.items():
                if value is None and attr in declared_fields:
                    declared_fields.pop(attr)

        new_class.base_fields = declared_fields
        new_class.declared_fields = declared_fields

        return new_class

    @classmethod
    def __prepare__(metacls, name, bases, **kwds):
        # 记住定义表单字段的顺序。
        return OrderedDict()


@html_safe
class BaseForm:
    """
    所有Form逻辑的主要实现。请注意，此类不同于Form。有关更多信息，请参见Form类的注释。对表单API的任何改进都应针对此类，而不是对Form类。
    """
    default_renderer = None
    field_order = None
    prefix = None
    use_required_attribute = True

    def __init__(self, data=None, files=None, auto_id='id_%s', prefix=None,
                 initial=None, error_class=ErrorList, label_suffix=None,
                 empty_permitted=False, field_order=None, use_required_attribute=None, renderer=None):
        self.is_bound = data is not None or files is not None
        self.data = {} if data is None else data
        self.files = {} if files is None else files
        self.auto_id = auto_id
        if prefix is not None:
            self.prefix = prefix
        self.initial = initial or {}
        self.error_class = error_class
        # 译者：这是添加到表单字段标签的默认后缀
        self.label_suffix = label_suffix if label_suffix is not None else _(':')
        self.empty_permitted = empty_permitted
        self._errors = None  # 在调用clean（）之后存储错误。

        # Tbase_fields类属性是个字段的“全类”定义。因为类的特定* instance *可能希望alter self.fields，
        # 所以我们在这里通过复制base_fields创建self.fields。 实例应始终修改self.fields;他们不应该修改self.base_fields。
        self.fields = copy.deepcopy(self.base_fields)
        self._bound_fields_cache = {}
        self.order_fields(self.field_order if field_order is None else field_order)

        if use_required_attribute is not None:
            self.use_required_attribute = use_required_attribute

        if self.empty_permitted and self.use_required_attribute:
            raise ValueError(
                'The empty_permitted and use_required_attribute arguments may '
                'not both be True.'
            )

        # 初始化表单渲染器。如果未指定＃，请使用全局默认值作为参数或self.default_renderer。
        if renderer is None:
            if self.default_renderer is None:
                renderer = get_default_renderer()
            else:
                renderer = self.default_renderer
                if isinstance(self.default_renderer, type):
                    renderer = renderer()
        self.renderer = renderer

    def order_fields(self, field_order):
        """
        根据field_order重新排列字段。

        field_order是指定顺序的字段名称的列表。以默认顺序追加未包含在列表中的字段，以便与不覆盖field_order的子类向后兼容。
        如果field_order为None，则使所有字段保持类中定义的顺序。忽略field_order中的未知字段，以允许在表单子类中禁用字段而无需重新定义顺序。
        """
        if field_order is None:
            return
        fields = OrderedDict()
        for key in field_order:
            try:
                fields[key] = self.fields.pop(key)
            except KeyError:  # ignore unknown fields
                pass
        fields.update(self.fields)  # add remaining fields in original order
        self.fields = fields

    def __str__(self):
        return self.as_table()

    def __repr__(self):
        if self._errors is None:
            is_valid = "Unknown"
        else:
            is_valid = self.is_bound and not self._errors
        return '<%(cls)s bound=%(bound)s, valid=%(valid)s, fields=(%(fields)s)>' % {
            'cls': self.__class__.__name__,
            'bound': self.is_bound,
            'valid': is_valid,
            'fields': ';'.join(self.fields),
        }

    def __iter__(self):
        for name in self.fields:
            yield self[name]

    def __getitem__(self, name):
        """Return a BoundField with the given name."""
        try:
            field = self.fields[name]
        except KeyError:
            raise KeyError(
                "Key '%s' not found in '%s'. Choices are: %s." % (
                    name,
                    self.__class__.__name__,
                    ', '.join(sorted(f for f in self.fields)),
                )
            )
        if name not in self._bound_fields_cache:
            self._bound_fields_cache[name] = field.get_bound_field(self, name)
        return self._bound_fields_cache[name]

    @property
    def errors(self):
        """返回为表单提供的数据的ErrorDict。"""
        if self._errors is None:
            self.full_clean()
        return self._errors

    def is_valid(self):
        """如果表单没有错误，则返回True，否则返回False。"""
        return self.is_bound and not self.errors

    def add_prefix(self, field_name):
        """
        如果此表单设置了前缀，则返回带有前缀的字段名称。子类可能希望覆盖。
        """
        return '%s-%s' % (self.prefix, field_name) if self.prefix else field_name

    def add_initial_prefix(self, field_name):
        """添加“ initial”前缀以检查动态初始值。"""
        return 'initial-%s' % self.add_prefix(field_name)

    def _html_output(self, normal_row, error_row, row_ender, help_text_html, errors_on_separate_row):
        "输出HTML。由as_table（），as_ul（），as_p（）使用。"
        top_errors = self.non_field_errors()  # 应该在所有字段上方显示的错误。
        output, hidden_fields = [], []

        for name, field in self.fields.items():
            html_class_attr = ''
            bf = self[name]
            bf_errors = self.error_class(bf.errors)
            if bf.is_hidden:
                if bf_errors:
                    top_errors.extend(
                        [_('(Hidden field %(name)s) %(error)s') % {'name': name, 'error': str(e)}
                         for e in bf_errors])
                hidden_fields.append(str(bf))
            else:
                # 如果该行应应用任何CSS类，则创建一个'class =“ ...”'属性。
                css_classes = bf.css_classes()
                if css_classes:
                    html_class_attr = ' class="%s"' % css_classes

                if errors_on_separate_row and bf_errors:
                    output.append(error_row % str(bf_errors))

                if bf.label:
                    label = conditional_escape(bf.label)
                    label = bf.label_tag(label) or ''
                else:
                    label = ''

                if field.help_text:
                    help_text = help_text_html % field.help_text
                else:
                    help_text = ''

                output.append(normal_row % {
                    'errors': bf_errors,
                    'label': label,
                    'field': bf,
                    'help_text': help_text,
                    'html_class_attr': html_class_attr,
                    'css_classes': css_classes,
                    'field_name': bf.html_name,
                })

        if top_errors:
            output.insert(0, error_row % top_errors)

        if hidden_fields:  # 在最后一行中插入所有隐藏的字段。
            str_hidden = ''.join(hidden_fields)
            if output:
                last_row = output[-1]
                # 截去尾随的row_ender（例如'</ td> </ tr>'），然后插入隐藏的字段。
                if not last_row.endswith(row_ender):
                    # 这可能发生在as_p（）情况下（可能还有其他个用户编写的情况）：如果只有最主要的错误，
                    # 我们可能无法出于我们的目的而应征入最后一行，因此请插入一个新的空行。
                    last_row = (normal_row % {
                        'errors': '',
                        'label': '',
                        'field': '',
                        'help_text': '',
                        'html_class_attr': html_class_attr,
                        'css_classes': '',
                        'field_name': '',
                    })
                    output.append(last_row)
                output[-1] = last_row[:-len(row_ender)] + str_hidden + row_ender
            else:
                # 如果输出中没有任何行，只需附加隐藏字段。
                output.append(str_hidden)
        return mark_safe('\n'.join(output))

    def as_table(self):
        "返回呈现为HTML <tr> s的此表单-不包括<table> </ table>。"
        return self._html_output(
            normal_row='<tr%(html_class_attr)s><th>%(label)s</th><td>%(errors)s%(field)s%(help_text)s</td></tr>',
            error_row='<tr><td colspan="2">%s</td></tr>',
            row_ender='</td></tr>',
            help_text_html='<br><span class="helptext">%s</span>',
            errors_on_separate_row=False,
        )

    def as_ul(self):
        "返回以HTML <li>形式呈现的此表单-不包括<ul> </ ul>。"
        return self._html_output(
            normal_row='<li%(html_class_attr)s>%(errors)s%(label)s %(field)s%(help_text)s</li>',
            error_row='<li>%s</li>',
            row_ender='</li>',
            help_text_html=' <span class="helptext">%s</span>',
            errors_on_separate_row=False,
        )

    def as_p(self):
        "返回以HTML <p> s形式呈现的表单。"
        return self._html_output(
            normal_row='<p%(html_class_attr)s>%(label)s %(field)s%(help_text)s</p>',
            error_row='%s',
            row_ender='</p>',
            help_text_html=' <span class="helptext">%s</span>',
            errors_on_separate_row=True,
        )

    def non_field_errors(self):
        """
        返回与特定字段无关的错误的ErrorList-即从Form.clean（）中返回。如果没有，则返回一个空的ErrorList。
        """
        return self.errors.get(NON_FIELD_ERRORS, self.error_class(error_class='nonfield'))

    def add_error(self, field, error):
        """
        更新“ self._errors”的内容。

        “ field”参数是应在其中添加错误的字段的名称。如果为None，则将错误视为NON_FIELD_ERRORS。

        错误参数可以是单个错误，错误列表或将字段名称映射到错误列表的字典。
        “错误”可以是简单的字符串，也可以是设置了消息属性的ValidationError实例，“列表或字典”可以是实际的“ list”或“ dict”，
        也可以是带有“ error_list”或“`”的ValidationError实例。 error_dict`属性集。

        如果`error`是字典，则`field`参数*必须*为None，并且错误将添加到与字典键对应的字段中。
        """
        if not isinstance(error, ValidationError):
            # 标准化到ValidationError，并让其构造函数进行使输入有意义的艰苦工作。
            error = ValidationError(error)

        if hasattr(error, 'error_dict'):
            if field is not None:
                raise TypeError(
                    "The argument `field` must be `None` when the `error` "
                    "argument contains errors for multiple fields."
                )
            else:
                error = error.error_dict
        else:
            error = {field or NON_FIELD_ERRORS: error.error_list}

        for field, error_list in error.items():
            if field not in self.errors:
                if field != NON_FIELD_ERRORS and field not in self.fields:
                    raise ValueError(
                        "'%s' has no field named '%s'." % (self.__class__.__name__, field))
                if field == NON_FIELD_ERRORS:
                    self._errors[field] = self.error_class(error_class='nonfield')
                else:
                    self._errors[field] = self.error_class()
            self._errors[field].extend(error_list)
            if field in self.cleaned_data:
                del self.cleaned_data[field]

    def has_error(self, field, code=None):
        return field in self.errors and (
                code is None or
                any(error.code == code for error in self.errors.as_data()[field])
        )

    def full_clean(self):
        """
        清除所有self.data并填充self._errors和self.cleaned_data。
        """
        self._errors = ErrorDict()
        if not self.is_bound:  # Stop further processing.
            return
        self.cleaned_data = {}
        # 如果允许表单为空，并且表单数据中的任何一个都没有更改初始数据，则短路任何验证。
        if self.empty_permitted and not self.has_changed():
            return

        self._clean_fields()
        self._clean_form()
        self._post_clean()

    def _clean_fields(self):
        for name, field in self.fields.items():
            # value_from_datadict（）从数据字典获取数据。 每个小部件类型都知道如何检索自己的数据，因为某些小部件将数据拆分为多个HTML字段。
            if field.disabled:
                value = self.get_initial_for_field(field, name)
            else:
                value = field.widget.value_from_datadict(self.data, self.files, self.add_prefix(name))
            try:
                if isinstance(field, FileField):
                    initial = self.get_initial_for_field(field, name)
                    value = field.clean(value, initial)
                else:
                    value = field.clean(value)
                self.cleaned_data[name] = value
                if hasattr(self, 'clean_%s' % name):
                    value = getattr(self, 'clean_%s' % name)()
                    self.cleaned_data[name] = value
            except ValidationError as e:
                self.add_error(name, e)

    def _clean_form(self):
        try:
            cleaned_data = self.clean()
        except ValidationError as e:
            self.add_error(None, e)
        else:
            if cleaned_data is not None:
                self.cleaned_data = cleaned_data

    def _post_clean(self):
        """
        内部挂钩，用于在完成表格清洁后执行其他清洁。用于模型形式的模型验证。
        """
        pass

    def clean(self):
        """
        在每个字段上都调用Field.clean（）之后，可以进行任何额外的表单范围内的清理工作。
        此方法引发的任何ValidationError都不会与特定字段关联；它将与名为“ __all__”的字段具有特殊情况的关联。
        """
        return self.cleaned_data

    def has_changed(self):
        """如果数据与初始值不同，则返回True。"""
        return bool(self.changed_data)

    @cached_property
    def changed_data(self):
        data = []
        for name, field in self.fields.items():
            prefixed_name = self.add_prefix(name)
            data_value = field.widget.value_from_datadict(self.data, self.files, prefixed_name)
            if not field.show_hidden_initial:
                # 使用BoundField的首字母，因为这是传递给小部件的值
                initial_value = self[name].initial
            else:
                initial_prefixed_name = self.add_initial_prefix(name)
                hidden_widget = field.hidden_widget()
                try:
                    initial_value = field.to_python(hidden_widget.value_from_datadict(
                        self.data, self.files, initial_prefixed_name))
                except ValidationError:
                    # 如果验证失败，请始终假定数据已更改。
                    data.append(name)
                    continue
            if field.has_changed(initial_value, data_value):
                data.append(name)
        return data

    @property
    def media(self):
        """返回在此表单上呈现小部件所需的所有媒体。"""
        media = Media()
        for field in self.fields.values():
            media = media + field.widget.media
        return media

    def is_multipart(self):
        """
        如果表单需要进行多部分编码，则返回True，即它具有FileInput，否则返回False。
        """
        return any(field.widget.needs_multipart_form for field in self.fields.values())

    def hidden_fields(self):
        """
        返回所有作为隐藏字段的BoundField对象的列表。对于模板中的手动表单布局很有用。
        """
        return [field for field in self if field.is_hidden]

    def visible_fields(self):
        """
        返回不是隐藏字段的BoundField对象的列表。与hidden_​​fields（）方法相反。
        """
        return [field for field in self if not field.is_hidden]

    def get_initial_for_field(self, field, field_name):
        """
        返回初始数据字段上的形式。按顺序使用表单或字段中的初始数据。评估可调用值。
        """
        value = self.initial.get(field_name, field.initial)
        if callable(value):
            value = value()
        return value


class Form(BaseForm, metaclass=DeclarativeFieldsMetaclass):
    "字段及其相关数据的集合。"
    # 这是与BaseForm分离的类，以便抽象指定self.fields的方式。
    # 此类（Form）是纯粹为语义糖做花式元类内容的类-它允许使用声明性语法定义一种形式。 BaseForm本身无法指定self.fields。
