# 模型表单ModelForm

阅读: 15638     [评论](http://www.liujiangblog.com/course/django/156#comments)：8

如果你正在构建一个数据库驱动的应用，那么你可能会有与Django的模型紧密映射的表单。比如，你有个BlogComment模型，并且你还想创建一个表单让大家提交评论到这个模型中。在这种情况下，写一个forms.Form类，然后在表单类中定义字段，这种一般创建表单的做法是冗余的，因为你已经在ORM模型model中定义了字段的属性和功能，完全没必要重新写一遍字段。

## 一、核心用法

基于这个原因，Django提供一个辅助类帮助我们利用Django的ORM模型model创建Form。

像下面这样：

```
>>> from django.forms import ModelForm
>>> from myapp.models import Article

# 创建表单类
>>> class ArticleForm(ModelForm):
...     class Meta:
...         model = Article
...         fields = ['pub_date', 'headline', 'content', 'reporter']

# 创建一个表单，用于添加文章
>>> form = ArticleForm()

# 创建表单修改已有的文章
>>> article = Article.objects.get(pk=1)
>>> form = ArticleForm(instance=article)
```

用法的核心是：

1. 首先从django.forms导入ModelForm；
2. 编写一个自己的类，继承ModelForm；
3. 在新类里，设置元类Meta；
4. 在Meta中，设置model属性为你要关联的ORM模型，这里是Article；
5. 在Meta中，设置fields属性为你要在表单中使用的字段列表；
6. 列表里的值，应该是ORM模型model中的字段名。

上面的例子中，因为model和form比较简单，字段数量少，看不出这么做的威力和效率。但如果是那种大型项目，每个模型的字段数量几十上百，这么做的收益将非常巨大，而且后面还有一招提高效率的大杀器，也就是一步保存数据的操作。

## 二、 字段类型

生成的Form类中将具有和指定的模型字段对应的表单字段，顺序为fields属性列表中指定的顺序。

每个模型字段有一个对应的默认表单字段。比如，模型中的CharField表现成表单中的CharField。模型中的ManyToManyField字段会表现成MultipleChoiceField字段。下面是完整的映射列表：

| 模型字段                   | 表单字段                                                     |
| -------------------------- | ------------------------------------------------------------ |
| AutoField                  | 在Form类中无法使用                                           |
| BigAutoField               | 在Form类中无法使用                                           |
| BigIntegerField            | IntegerField，最小-9223372036854775808，最大9223372036854775807. |
| BooleanField               | BooleanField                                                 |
| CharField                  | CharField，同样的最大长度限制。如果model设置了null=True，Form将使用empty_value |
| CommaSeparatedIntegerField | CharField                                                    |
| DateField                  | DateField                                                    |
| DateTimeField              | DateTimeField                                                |
| DecimalField               | DecimalField                                                 |
| EmailField                 | EmailField                                                   |
| FileField                  | FileField                                                    |
| FilePathField              | FilePathField                                                |
| FloatField                 | FloatField                                                   |
| **ForeignKey**             | **ModelChoiceField**                                         |
| ImageField                 | ImageField                                                   |
| IntegerField               | IntegerField                                                 |
| IPAddressField             | IPAddressField                                               |
| GenericIPAddressField      | GenericIPAddressField                                        |
| **ManyToManyField**        | **ModelMultipleChoiceField**                                 |
| NullBooleanField           | NullBooleanField                                             |
| PositiveIntegerField       | IntegerField                                                 |
| PositiveSmallIntegerField  | IntegerField                                                 |
| SlugField                  | SlugField                                                    |
| SmallIntegerField          | IntegerField                                                 |
| TextField                  | CharField，并带有widget=forms.Textarea参数                   |
| TimeField                  | TimeField                                                    |
| URLField                   | URLField                                                     |

可以看出，Django在设计model字段和表单字段时存在大量的相似和重复之处。

ManyToManyField和 ForeignKey字段类型属于特殊情况：

- ForeignKey被映射成为表单类的django.forms.ModelChoiceField，它的选项是一个模型的QuerySet，也就是可以选择的对象的列表，但是只能选择一个。
- ManyToManyField被映射成为表单类的django.forms.ModelMultipleChoiceField，它的选项也是一个模型的QuerySet，也就是可以选择的对象的列表，但是可以同时选择多个，多对多嘛。

同时，在表单属性设置上，还有下面的映射关系：

- 如果模型字段设置blank=True，那么表单字段的required设置为False。 否则，required=True。
- 表单字段的label属性根据模型字段的verbose_name属性设置，并将第一个字母大写。
- 如果模型的某个字段设置了editable=False属性，那么它表单类中将不会出现该字段。道理很简单，都不能编辑了，还放在表单里提交什么？
- 表单字段的`help_text`设置为模型字段的`help_text`。
- 如果模型字段设置了choices参数，那么表单字段的widget属性将设置成Select框，其选项来自模型字段的choices。选单中通常会包含一个空选项，并且作为默认选择。如果该字段是必选的，它会强制用户选择一个选项。 如果模型字段具有default参数，则不会添加空选项到选单中。

## 三、完整示例

模型：

```
from django.db import models
from django.forms import ModelForm

TITLE_CHOICES = (
    ('MR', 'Mr.'),
    ('MRS', 'Mrs.'),
    ('MS', 'Ms.'),
)

class Author(models.Model):
    name = models.CharField(max_length=100)
    title = models.CharField(max_length=3, choices=TITLE_CHOICES)
    birth_date = models.DateField(blank=True, null=True)

    def __str__(self):              # __unicode__ on Python 2
        return self.name

class Book(models.Model):
    name = models.CharField(max_length=100)
    authors = models.ManyToManyField(Author)

class AuthorForm(ModelForm):
    class Meta:
        model = Author
        fields = ['name', 'title', 'birth_date']

class BookForm(ModelForm):
    class Meta:
        model = Book
        fields = ['name', 'authors']
```

上面的ModelForm子类基本等同于下面的定义方式（唯一的区别是save()方法）：

```
from django import forms

class AuthorForm(forms.Form):
    name = forms.CharField(max_length=100)
    title = forms.CharField(
        max_length=3,
        widget=forms.Select(choices=TITLE_CHOICES),
    )
    birth_date = forms.DateField(required=False)

class BookForm(forms.Form):
    name = forms.CharField(max_length=100)
    authors = forms.ModelMultipleChoiceField(queryset=Author.objects.all())
```

## 四、ModelForm的验证

验证ModelForm主要分两步：

- 验证表单
- 验证模型实例

与普通的表单验证类似，模型表单的验证也是调用`is_valid()`方法或访问errors属性。模型的验证（Model.full_clean()）紧跟在表单的clean()方法调用之后。通常情况下，我们使用Django内置的验证器就好了。如果需要，可以重写模型表单的clean()来提供额外的验证，方法和普通的表单一样。

## 五、ModelForm的字段选择

强烈建议使用ModelForm的fields属性，在赋值的列表内，一个一个将要使用的字段添加进去。这样做的好处是，安全可靠。

然而，有时候，字段太多，或者我们想偷懒，不愿意一个一个输入，也有简单的方法：

**__all__**:

将fields属性的值设为`__all__`，表示将映射的模型中的全部字段都添加到表单类中来。

```
from django.forms import ModelForm

class AuthorForm(ModelForm):
    class Meta:
        model = Author
        fields = '__all__'
```

**exclude属性**:

表示将model中，除了exclude属性中列出的字段之外的所有字段，添加到表单类中作为表单字段。

```
class PartialAuthorForm(ModelForm):
    class Meta:
        model = Author
        exclude = ['title']
```

因为Author模型有3个字段name、`birth_date`和title，上面的例子会让`birth_date`和name出现在表单中。

## 六、自定义ModelForm字段

在前面，我们有个表格，展示了从模型到模型表单在字段上的映射关系。通常，这是没有什么问题，直接使用，按默认的来就行了。但是，有时候可能这种默认映射关系不是我们想要的，或者想进行一些更加灵活的定制，那怎么办呢？

**使用Meta类内部的widgets属性！**

widgets属性接收一个数据字典。其中每个元素的键必须是模型中的字段名之一，键值就是我们要自定义的内容了，具体格式和写法，参考下面的例子。

例如，如果你想要让Author模型中的name字段的类型从CharField更改为`<textarea>`，而不是默认的`<input type="text">`，可以如下重写字段的Widget：

```
from django.forms import ModelForm, Textarea
from myapp.models import Author

class AuthorForm(ModelForm):
    class Meta:
        model = Author
        fields = ('name', 'title', 'birth_date')
        widgets = {
            'name': Textarea(attrs={'cols': 80, 'rows': 20}), # 关键是这一行
        }
```

上面还展示了添加样式参数的格式。

如果你希望进一步自定义字段，还可以指定Meta类内部的`error_messages`、`help_texts`和`labels`属性，比如：

```
from django.utils.translation import ugettext_lazy as _

class AuthorForm(ModelForm):
    class Meta:
        model = Author
        fields = ('name', 'title', 'birth_date')
        labels = {
            'name': _('Writer'),
        }
        help_texts = {
            'name': _('Some useful help text.'),
        }
        error_messages = {
            'name': {
                'max_length': _("This writer's name is too long."),
            },
        }
```

还可以指定`field_classes`属性将字段类型设置为你自己写的表单字段类型。

例如，如果你想为slug字段使用MySlugFormField，可以像下面这样：

```
from django.forms import ModelForm
from myapp.models import Article

class ArticleForm(ModelForm):
    class Meta:
        model = Article
        fields = ['pub_date', 'headline', 'content', 'reporter', 'slug']
        field_classes = {
            'slug': MySlugFormField,
        }
```

最后，如果你想完全控制一个字段,包括它的类型，验证器，是否必填等等。可以显式地声明或指定这些性质，就像在普通表单中一样。比如，如果想要指定某个字段的验证器，可以显式定义字段并设置它的validators参数：

```
from django.forms import ModelForm, CharField
from myapp.models import Article

class ArticleForm(ModelForm):
    slug = CharField(validators=[validate_slug])

    class Meta:
        model = Article
        fields = ['pub_date', 'headline', 'content', 'reporter', 'slug']
```

## 七、启用字段本地化

默认情况下，ModelForm中的字段不会本地化它们的数据。可以使用Meta类的`localized_fields`属性来启用字段的本地化功能。

```
>>> from django.forms import ModelForm
>>> from myapp.models import Author
>>> class AuthorForm(ModelForm):
...     class Meta:
...         model = Author
...         localized_fields = ('birth_date',)
```

如果`localized_fields`设置为`__all__`这个特殊的值，所有的字段都将本地化。

## 八、表单的继承

ModelForms是可以被继承的。子模型表单可以添加额外的方法和属性，比如下面的例子：

```
>>> class EnhancedArticleForm(ArticleForm):
...     def clean_pub_date(self):
...         ...
```

以上创建了一个ArticleForm的子类EnhancedArticleForm，并增加了一个`clean_pub_date`方法。

还可以修改`Meta.fields`或`Meta.exclude`列表，只要继承父类的Meta类，如下所示：

```
>>> class RestrictedArticleForm(EnhancedArticleForm):
...     class Meta(ArticleForm.Meta):
...         exclude = ('body',)
```

## 九、提供初始值

可以在实例化一个表单时通过指定initial参数来提供表单中数据的初始值。

```
>>> article = Article.objects.get(pk=1)
>>> article.headline
'My headline'
>>> form = ArticleForm(initial={'headline': 'Initial headline'}, instance=article)
>>> form['headline'].value()
'Initial headline'
```