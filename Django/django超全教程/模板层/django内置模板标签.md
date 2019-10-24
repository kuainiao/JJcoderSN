# Django内置模板标签

## Django内置标签总览

可以查询下表来总览Django的内置标签：

| 标签        | 说明                      |
| ----------- | ------------------------- |
| autoescape  | 自动转义开关              |
| block       | 块引用                    |
| comment     | 注释                      |
| csrf_token  | CSRF令牌                  |
| cycle       | 循环对象的值              |
| debug       | 调试模式                  |
| extends     | 继承模版                  |
| filter      | 过滤功能                  |
| firstof     | 输出第一个不为False的参数 |
| for         | 循环对象                  |
| for … empty | 带empty说明的循环         |
| if          | 条件判断                  |
| ifequal     | 如果等于                  |
| ifnotequal  | 如果不等于                |
| ifchanged   | 如果有变化，则..          |
| include     | 导入子模版的内容          |
| load        | 加载标签和过滤器          |
| lorem       | 生成无用的废话            |
| now         | 当前时间                  |
| regroup     | 根据对象重组集合          |
| resetcycle  | 重置循环                  |
| spaceless   | 去除空白                  |
| templatetag | 转义模版标签符号          |
| url         | 获取url字符串             |
| verbatim    | 禁用模版引擎              |
| widthratio  | 宽度比例                  |
| with        | 上下文变量管理器          |

### 1. autoescape

控制自动转义是否可用。参数是on或off。 该标签会以一个endautoescape作为结束标签.

例如：

```
{% autoescape on %}
    {{ body }}
{% endautoescape %}
```

### 2. block

block标签可以被子模板覆盖。

### 3. comment

在`{% comment %}`和`{% endcomment %}`之间的内容会被忽略，作为注释。

比如，当要注释掉一些代码时，可以用此来记录代码被注释掉的原因。

例如：

```
<p>Rendered text with {{ pub_date|date:"c" }}</p>
{% comment "Optional note" %}
    <p>Commented out text with {{ create_date|date:"c" }}</p>
{% endcomment %}
```

comment标签不能嵌套使用。

### 4. csrf_token

这个标签用于跨站请求伪造保护。常用于为form表单提供csrf令牌。

### 5. cycle

每当这个标签被访问,返回它的下一个元素。第一次访问返回第一个元素,第二次访问返回第二个参数,以此类推. 一旦所有的变量都被访问过了，就会回到最开始的地方，重复下去。这个标签在循环中特别有用:

```
{% for o in some_list %}
    <tr class="{% cycle 'row1' 'row2'%}">
        ...
    </tr>
{% endfor %}
```

第一次迭代产生的HTML引用了row1类，第二次则是row2类，第三次又是row1 类，如此类推。

cycle的本质是根据某个规律，提供某种特性，比如想循环给表格的行添加底色等等。

也可以使用变量， 例如，如果你有两个模版变量：rowvalue1和rowvalue2, 可以让他们的值像这样替换:

```
{% for o in some_list %}
    <tr class="{% cycle rowvalue1 rowvalue2 %}">
        ...
    </tr>
{% endfor %}
```

被包含在cycle中的变量将会被转义。 可以禁止自动转义:

```
{% for o in some_list %}
    <tr class="{% autoescape off %}{% cycle rowvalue1 rowvalue2 %}{% endautoescape %}">
        ...
    </tr>
{% endfor %}
```

可以混合使用变量和字符串：

```
{% for o in some_list %}
    <tr class="{% cycle 'row1' rowvalue2 'row3' %}">
        ...
    </tr>
{% endfor %}
```

在某些情况下，可能需要连续引用一个当前循环的值，而不前进到下一个循环值。要达到这个目的，只需使用`as`来给`{％ cycle ％}`取一个别名，就像这样：

```
{% cycle 'row1' 'row2' as rowcolors %}
```

从那时起（设置别名后），你可以将别名当作一个模板变量进行引用，从而随意在模板中插入当前循环的值。 如果要将循环值移动到原始cycle标记的下一个值，可以使用另一个cycle标记并指定变量的名称。看下面的例子：

```
<tr>
    <td class="{% cycle 'row1' 'row2' as rowcolors %}">...</td>
    <td class="{{ rowcolors }}">...</td>
</tr>
<tr>
    <td class="{% cycle rowcolors %}">...</td>
    <td class="{{ rowcolors }}">...</td>
</tr>
```

将输出：

```
<tr>
    <td class="row1">...</td>
    <td class="row1">...</td>
</tr>
<tr>
    <td class="row2">...</td>
    <td class="row2">...</td>
</tr>
```

cycle 标签中，通过空格分割，可以使用任意数量的值。被包含在单引号(')或者双引号(")中的值被认为是可迭代字符串，相反，没有被引号包围的值被当作模版变量。

### 6. debug

输出整个调试信息，包括当前上下文和导入的模块。

### 7. extends

表示当前模板继承自一个父模板。

这个标签可以有两种用法:

- {% extends "base.html" %}：继承名为"base.html"的父模板
- {％ extends variable ％}:使用variable变量表示的模版

Django1.10中添加了使用相对路径的能力。通常模板名称是相对于模板加载器的根目录。字符串参数也可以是以`./`或`../`开头的相对路径。 例如，假设有以下目录结构：

```
dir1/
    template.html
    base2.html
    my/
        base3.html
base1.html
```

在template.html中，以下路径将有效：

```
{% extends "./base2.html" %}
{% extends "../base1.html" %}
{% extends "./my/base3.html" %}
```

### 8. filter

通过一个或多个过滤器对内容过滤。需要结束标签endfilter。

例如：

```
{% filter force_escape|lower %}
    This text will be HTML-escaped, and will appear in all lowercase.
{% endfilter %}
```

### 9. firstof

输出第一个不为False参数。 如果传入的所有变量都为False，就什么也不输出。

例如：

```
{% firstof var1 var2 var3 %}
```

它等价于：

```
{% if var1 %}
    {{ var1 }}
{% elif var2 %}
    {{ var2 }}
{% elif var3 %}
    {{ var3 }}
{% endif %}
```

当然也可以用一个默认字符串作为输出以防止传入的所有变量都是False：

```
{% firstof var1 var2 var3 "fallback value" %}
```

### 10. for

循环对象中的每一个元素

```
<ul>
{% for athlete in athlete_list %}
    <li>{{ athlete.name }}</li>
{% endfor %}
</ul>
```

可以使用`{% for obj in list reversed %}`进行反向循环。

如果循环对象points的每个元素都是(x,y)这样的二元元组，可以像以下面一样输出：

```
{% for x, y in points %}
    There is a point at {{ x }},{{ y }}
{% endfor %}
```

如果你想访问一个字典中的键值，这个方法同样有用：

```
{% for key, value in data.items %}
    {{ key }}: {{ value }}
{% endfor %}
```

请记住，对于点运算符，字典键查找优先于方法查找。

下面是Django为for标签内置的一些属性，可以当作变量一样使用`{{ }}`在模版中使用。

- forloop.counter：循环的当前索引值，从1开始计数；常用于生成一个表格或者列表的序号！
- forloop.counter0：循环的当前索引值，从0开始计数；
- forloop.revcounter： 循环结束的次数（从1开始）
- forloop.revcounter0 循环结束的次数（从0开始）
- forloop.first：判断当前是否循环的第一次，是的话，该变量的值为True。我们经常要为第一行加点特殊的对待，就用得上这个判断了，结合if。
- forloop.last：如果这是最后一次循环，则为真
- forloop.parentloop：对于嵌套循环，返回父循环所在的循环次数。某些场景下，这是个大杀器，能解决你很多头疼的问题。

### 11. for ... empty

for标签带有一个可选的`{% empty %}`从句，以便在循环对象是空的或者没有被找到时，可以有所操作和提示。

```
<ul>
{% for athlete in athlete_list %}
    <li>{{ athlete.name }}</li>
{% empty %}
    <li>Sorry, no athletes in this list.</li>
{% endfor %}
</ul>
```

它和下面的例子作用相等，但是更简洁、更清晰甚至可能运行起来更快：

```
<ul>
  {% if athlete_list %}
    {% for athlete in athlete_list %}
      <li>{{ athlete.name }}</li>
    {% endfor %}
  {% else %}
    <li>Sorry, no athletes in this list.</li>
  {% endif %}
</ul>
```

### 12. if

`{% if %}`会对一个变量求值，如果它的值是“True”（存在、不为空、且不是boolean类型的False值），这个内容块就会输出：

```
{% if athlete_list %}
    Number of athletes: {{ athlete_list|length }}
{% elif athlete_in_locker_room_list %}
    Athletes should be out of the locker room soon!
{% else %}
    No athletes.
{% endif %}
```

上述例子中，如果`athlete_list`不为空，就会通过使用`{{ athlete_list|length }}`过滤器展示出athletes的数量。

if标签之后可以带有一个或者多个`{% elif %}`从句，也可以带有一个`{% else %}`从句以便在之前的所有条件不成立的情况下完成执行。这些从句都是可选的。

**布尔运算符**:

if标签可以使用not，and或or来测试布尔值：

```
{% if athlete_list and coach_list %}
    Both athletes and coaches are available.
{% endif %}

{% if not athlete_list %}
    There are no athletes.
{% endif %}

{% if athlete_list or coach_list %}
    There are some athletes or some coaches.
{% endif %}

{% if not athlete_list or coach_list %}
    There are no athletes or there are some coaches.
{% endif %}

{% if athlete_list and not coach_list %}
    There are some athletes and absolutely no coaches.
{% endif %}
```

允许同时使用and和or子句，and的优先级高于or ：

```
{% if athlete_list and coach_list or cheerleader_list %}
```

将解释如下：

```
if (athlete_list and coach_list) or cheerleader_list
```

**在if标签中使用实际括号是错误的语法，这点不同于Python。**如果需要为它们指示优先级，应使用嵌套的if标签。

if标签允许使用这些操作符：`==`, `!=`, `<`, `>`, `<=`, `>=`, `in`, `not in`, `is`, `is not`,如下面的列子所示：

```
{% if somevar == "x" %}
  This appears if variable somevar equals the string "x"
{% endif %}

{% if somevar != "x" %}
  This appears if variable somevar does not equal the string "x",
  or if somevar is not found in the context
{% endif %}

{% if somevar < 100 %}
  This appears if variable somevar is less than 100.
{% endif %}

{% if somevar > 0 %}
  This appears if variable somevar is greater than 0.
{% endif %}

{% if somevar <= 100 %}
  This appears if variable somevar is less than 100 or equal to 100.
{% endif %}

{% if somevar >= 1 %}
  This appears if variable somevar is greater than 1 or equal to 1.
{% endif %}

{% if "bc" in "abcdef" %}
  This appears since "bc" is a substring of "abcdef"
{% endif %}

{% if "hello" in greetings %}
  If greetings is a list or set, one element of which is the string
  "hello", this will appear.
{% endif %}

{% if user not in users %}
  If users is a QuerySet, this will appear if user is not an
  instance that belongs to the QuerySet.
{% endif %}

{% if somevar is True %}
  This appears if and only if somevar is True.
{% endif %}

{% if somevar is None %}
  This appears if somevar is None, or if somevar is not found in the context.
{% endif %}

{% if somevar is not True %}
  This appears if somevar is not True, or if somevar is not found in the
  context.
{% endif %}

{% if somevar is not None %}
  This appears if and only if somevar is not None.
{% endif %}
```

也可以在if表达式中使用过滤器。 像这样：

```
{% if messages|length >= 100 %}
   You have lots of messages today!
{% endif %}
```

所有上述操作符都可以组合以形成复杂表达式。对于这样的表达式，重要的是优先级规则。操作符的优先级从低至高如下：

```
or
and
not
in
==，!=，<，>，<= ，>=
```

与Python的规则是一样的。 所以，对于下面的复杂if标签：

```
{% if a == b or c == d and e %}
```

将被解释为：

```
(a == b) or ((c == d) and e)
```

如果想要不同的优先级，那么你需要使用嵌套的if标签，而不能使用圆括号。

**比较运算符不能像Python或数学符号中那样“链接”。** 例如，不能使用：

```
{% if a > b > c %}  (错误的用法)
```

应该使用：

```
{% if a > b and b > c %}
```

### 13. ifequal和ifnotequal

`{％ ifequal a b ％} ... {％ endifequal ％}`是一种过时的写法，等同于`{％ if a == b ％} ... {％ endif ％}`。 同样， `{％ ifnotequal a b ％} ... {％ endifnotequal ％}`等同于`{％ if a ！= b ％} ... {％ endif ％}`。这两个标签将在以后的版本中弃用。

### 14. ifchanged

检查一个值是否在上一次的迭代中被改变了。

`{% ifchanged %}`标签通常用在循环里。它有两个用处：

检查已经渲染过的内容的当前状态。并且只会显示发生改变的内容。例如，以下的代码是输出days的列表项，不过它只会输出被修改过月份的项:

```
<h1>Archive for {{ year }}</h1>

{% for date in days %}
    {% ifchanged %}<h3>{{ date|date:"F" }}</h3>{% endifchanged %}
    <a href="{{ date|date:"M/d"|lower }}/">{{ date|date:"j" }}</a>
{% endfor %}
```

如果标签内有多个值时,则会比较每一个值是否与上一次不同。例如，以下显示每次更改时的日期，如果小时或日期已更改，则显示小时：

```
{% for date in days %}
    {% ifchanged date.date %} {{ date.date }} {% endifchanged %}
    {% ifchanged date.hour date.date %}
        {{ date.hour }}
    {% endifchanged %}
{% endfor %}
```

ifchanged标记也可以采用可选的`{％ else ％}`将显示值没有改变的情况：

```
{% for match in matches %}
    <div style="background-color:
        {% ifchanged match.ballot_id %}
            {% cycle "red" "blue" %}
        {% else ％}
            gray
        {% endifchanged ％}
    ">{{ match }}</div>
{% endfor %}
```

### 15. include

加载指定的模板并以标签内的参数渲染。这是一种引入别的模板的方法，一定要将include和extend区分开！include类似Python的import。

```
{% include "foo/bar.html" %}
```

也可以使用变量名`template_name`：

```
{% include template_name %}
```

下面这个示例生成输出“Hello, John!”：

context：变量greeting="Hello"，变量person="John"。

模板：

```
{% include "name_snippet.html" %}
```

name_snippet.html模板：

```
{{ greeting }}, {{ person|default:"friend" }}!
```

可以使用关键字参数将额外的上下文传递到模板：

```
{% include "name_snippet.html" with person="Jane" greeting="Hello" %}
```

如果仅使用提供的变量来渲染上下文，添加only选项。

```
{% include "name_snippet.html" with greeting="Hi" only %}
```

include标签应该被理解为是一种"将子模版渲染并嵌入当前HTML中"的变种方法,而不应该看作是"解析子模版并在被父模版包含的情况下展现其被父模版定义的内容"。这意味着在不同的被包含的子模版之间并不共享父模版的状态,每一个子包含都是完全独立的渲染过程。

### 16. load

加载自定义模板标签。

下面的模板将会从somelibrary和package包中的otherlibrary中载入所有已经注册的标签和过滤器:

```
{% load somelibrary package.otherlibrary %}
```

还可以使用from参数从库中选择性加载单个过滤器或标记。

```
{% load foo bar from somelibrary %}
```

### 17. lorem

这个标签是用来在模版中提供文字样本以供测试用的。使用场景是什么？

比如你要写个demo，里面要有一大段的文字和篇章，你不可能真的去写一篇文章吧？如果懒得去网上COPY，又不愿意使用一堆毫无意义杂乱的乱码，那么使用这个方法，可以帮你自动填充一些可以阅读的内容。

PS：Django考虑得真细.....

用法：

```
{% lorem [count] [method] [random] %}
```

可以使用零个，一个，两个或三个参数。 这些参数是：

- count ：一个数字（或变量），其中包含要生成的段落或字数（默认值为1）。
- method：HTML中使用p标签、还是w标签、还是b标签，决定文本格式。默认是“b”。
- random：如果给出的话，random这个词在生成文本时不会使用公共段落。 例子：

```
{％ lorem ％}将输出常见的“lorem ipsum”段落。
{％ lorem 3 p ％}输出常用的“lorem ipsum”段落和两个随机段落，每段包裹在HTML`<p>`标签中。
{% lorem 2 w random %}将输出两个随机拉丁字。
```

### 18. now

显示当前的日期或时间。可以指定显示的格式。 例如：

```
It is {% now "jS F Y H:i" %}
```

下面的例子中，“o”和“f”都被反斜杠转义：

```
It is the {% now "jS \o\f F" %}
```

这将显示为“It is the 4th of September”。

还可以使用语法`{％ now “Y” as current_year ％}`将输出存储在变量中。

```
{% now "Y" as current_year %}
{% blocktrans %}Copyright {{ current_year }}{% endblocktrans %}
```

### 19. regroup

用对象间共有的属性重组列表。

对于下面的数据：

```
cities = [
    {'name': 'Mumbai', 'population': '19,000,000', 'country': 'India'},
    {'name': 'Calcutta', 'population': '15,000,000', 'country': 'India'},
    {'name': 'New York', 'population': '20,000,000', 'country': 'USA'},
    {'name': 'Chicago', 'population': '7,000,000', 'country': 'USA'},
    {'name': 'Tokyo', 'population': '33,000,000', 'country': 'Japan'},
]
```

如果你想显示按国家/地区排序的分层列表，如下所示：

```
India
    Mumbai: 19,000,000
    Calcutta: 15,000,000
USA
    New York: 20,000,000
    Chicago: 7,000,000
Japan
    Tokyo: 33,000,000
```

可以使用`{% regroup %}`标签来给每个国家的城市分组：

```
{% regroup cities by country as country_list %}

<ul>
{% for country in country_list %}
    <li>{{ country.grouper }}
    <ul>
        {% for city in country.list %}
          <li>{{ city.name }}: {{ city.population }}</li>
        {% endfor %}
    </ul>
    </li>
{% endfor %}
</ul>
```

让我们来看看这个例子。`{% regroup %}`有三个参数： 要重组的列表、用来分组的属性、结果列表的名字。在这里，我们通过`country`属性重新分组cities列表，并将结果保存在`country_list`中。

`country_list`的每个元素是具有两个字段的`namedtuple()`的实例：

- grouper - 分组的项目（例如，字符串“India”或“Japan”）。
- list - 此群组中所有项目的列表（例如，所有城市的列表，其中country ='India'）。

### 20. resetcycle

Django1.11中的新功能。

重置先前的循环，以便在下一次循环时从其第一个项目重新启动。如果没有参数，`{％ resetcycle ％}`将重置最后一个`{% cycle %}`。

用法示例：

```
{% for coach in coach_list %}
    <h1>{{ coach.name }}</h1>
    {% for athlete in coach.athlete_set.all %}
        <p class="{% cycle 'odd' 'even' %}">{{ athlete.name }}</p>
    {% endfor %}
    {% resetcycle %}
{% endfor %}
```

这个示例将返回下面的HTML：

```
<h1>José Mourinho</h1>
<p class="odd">Thibaut Courtois</p>
<p class="even">John Terry</p>
<p class="odd">Eden Hazard</p>

<h1>Carlo Ancelotti</h1>
<p class="odd">Manuel Neuer</p>
<p class="even">Thomas Müller</p>
```

注意第一个块以class="odd"结束，新的以class="odd"开头。没有`{％ resetcycle ％}`标签，第二个块将以class="even"开始。

还可以重置循环标签：

```
{% for item in list %}
    <p class="{% cycle 'odd' 'even' as stripe %} {% cycle 'major' 'minor' 'minor' 'minor' 'minor' as tick %}">
        {{ item.data }}
    </p>
    {% ifchanged item.category %}
        <h1>{{ item.category }}</h1>
        {% if not forloop.first %}{% resetcycle tick %}{% endif %}
    {% endifchanged %}
{% endfor %}
```

在这个例子中，我们有交替的奇数/偶数行和每五行出现一次的‘major’行。当类别更改时，只有五行周期被重置。

### 21. spaceless

删除HTML标签之间的空白，包括制表符和换行。

用法示例：

```
{% spaceless %}
    <p>
        <a href="foo/">Foo</a>
    </p>
{% endspaceless %}
```

这个示例将返回下面的HTML：

```
<p><a href="foo/">Foo</a></p>
```

仅会删除tags之间的空格，不会删除标签和文本之间的。下面的例子中，Hello周围的空格不会被删除：

```
{% spaceless %}
    <strong>
        Hello
    </strong>
{% endspaceless %}
```

### 22. templatetag

输出用于构成模板标签的语法字符。

由于模板系统没有“转义”的概念，无法在HTML中使用‘\’转义出类似`{%`的字符。为了显示模板标签本身，必须使用`{％ templatetag ％}`标签，并添加相应的参数：

- openblock：`{％`
- closeblock： `％}`
- openvariable： `{{`
- closevariable： `}}`
- openbrace ：`{`
- closebrace： `}`
- opencomment： `{＃`
- closecomment： `＃}`

例如：

```
{% templatetag openblock %} url 'entry_list' {% templatetag closeblock %}
```

### 23. url

返回与给定视图和可选参数匹配的绝对路径引用（不带域名的URL）。在解析后返回的结果路径字符串中，每个特殊字符将使用`iri_to_uri()`编码。这可以避免在模板中硬编码超级链接路径。

```
{% url 'some-url-name' v1 v2 %}
```

第一个参数是`url()`的名字。 它可以是一个被引号引起来的字符串或者其他的上下文变量。其他参数是可选的并且以空格隔开，这些值会在URL中以参数的形式传递。上面的例子展示了如何传递位置参数，当然也可以使用关键字参数。

```
{% url 'some-url-name' arg1=v1 arg2=v2 %}
```

不要把位置参数和关键字参数混在一起使用。URLconf所需的所有参数都应该提供。

例如，假设有一个视图`app_views.client`，其URLconf接受客户端ID，并如下所示：

```
('^client/([0-9]+)/$', app_views.client, name='app-views-client')
```

如果你的应用中的URLconf已经被包含到项目URLconf中，比如下面这样

```
('^clients/', include('project_name.app_name.urls'))
```

然后，在模板中，你可以创建一个此视图的链接，如下所示：

```
{% url 'app-views-client' client.id %}
```

模板标签会输出字符串:`/clients/client/123/`

如果希望在不显示网址的情况下检索网址，可以使用略有不同的调用：

```
{% url 'some-url-name' arg arg2 as the_url %}
<a href="{{ the_url }}">I'm linking to {{ the_url }}</a>
```

如果视图不存在，`{％ url ... as var ％}`语法不会导致错误。

```
{% url 'some-url-name' as the_url %}
{% if the_url %}
  <a href="{{ the_url }}">Link to optional stuff</a>
{% endif %}
```

如果使用urlconf的名称空间网址，通过**冒号**指定完全名称，如下所示：

```
{% url 'myapp:view-name' %}
```

**再次强调，是冒号，不是圆点不是斜杠！**

### 24. verbatim

禁止模版引擎在该标签中进行渲染工作。

常见的用法是允许与Django语法冲突的JavaScript模板图层工作。 像这样：

```
{% verbatim %}
    {{if dying}}Still alive.{{/if}}
{% endverbatim %}
```

### 25. widthratio

为了创建柱状形图，此标签计算给定值与最大值的比率，然后将该比率应用于常量。

像这样：

```
<img src="bar.png" alt="Bar"
     height="10" width="{% widthratio this_value max_value max_width %}" />
```

如果`this_value`是175，`max_value`是200，并且`max_width`是100，则上述示例中的图像将是88像素宽（因为175 / 200 = .875； .875 * 100 = 87.5，四舍五入入为88）。

### 26. with

使用一个简单地名字缓存一个复杂的变量，当你需要使用一个代价较大的方法（比如访问数据库）很多次的时候这是非常有用的。

像这样：

```
{% with total=business.employees.count %}
    {{ total }} employee{{ total|pluralize }}
{% endwith %}
```

total只在with标签内部有效。

可以分配多个变量：

```
{% with alpha=1 beta=2 %}
    ...
{% endwith %}
```