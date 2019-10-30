***\*django shortcuts渲染模板\****

***\*
\****

这里没有单独的使用介绍，只有这个模块下包含的这些函数的介绍，自己记录也欢迎大家浏览

```python
from django.shortcuts import render_to_responsedef render_to_response(template_name, context=None,                       context_instance=_context_instance_undefined,                       content_type=None, status=None, dirs=_dirs_undefined,                       dictionary=_dictionary_undefined, using=None):        """	返回其内容被调用结果填充的HttpResponse	django.template.loader.render_to_string()与传递的参数。        """
from django.shortcuts import renderdef render(request, template_name, context=None,           context_instance=_context_instance_undefined,           content_type=None, status=None, current_app=_current_app_undefined,           dirs=_dirs_undefined, dictionary=_dictionary_undefined,           using=None):	"""	返回其内容被调用结果填充的HttpResponse	django.template.loader.render_to_string()与传递的参数。	默认情况下使用请求上下文。	"""
from django.shortcuts import redirectdef redirect(to, *args, **kwargs):	"""	返回一个HttpResponseRedirect通过参数到相应URL	参数可以是:	* 模型:模型的get_absolute_url()函数将被调用。	* 视图名称，可能带有参数:urlresolvers.reverse()将用于反向解析名称。	* 一个URL，它将被用于重定向位置。	* 默认情况下，临时重定向; permanent=True 来发布永久重定向	"""
from django.shortcuts import _get_querysetdef _get_queryset(klass):	"""	从模型、管理器或QuerySet中返回一个QuerySet。为了使get_object_or_404和get_list_or_404更加DRY(代码不重复)。	如果klass不是Modle、Manager或QuerySet，那么就会产生一个ValueError。
      """
from django.shortcuts import get_object_or_404def get_object_or_404(klass, *args, **kwargs):	"""	使用get()返回一个对象如果对象不存在返回Http404异常。	klass可能是一个Model、Manager或QuerySet对象; get()查询中使用了参数和关键字参数。	注意: 就像get()一样，如果有多个返回对象，则返回多个对象。	"""
from django.shortcuts import get_list_or_404def get_list_or_404(klass, *args, **kwargs):	"""	使用filter()返回一个对象列表,如果列表为空则返回一个Http404异常	klass可能是一个Model、Manager或QuerySet对象。	filter()查询中使用了参数和关键字参数。	"""
from django.shortcuts import resolve_urldef resolve_url(to, *args, **kwargs):	"""	返回一个与所传递参数相对应的URL。	参数可以是:	*模型:模型的get_absolute_url()函数将被调用。	*视图名称，可能带有参数:' urlresolvers.reverse()将用于反向解析名称。
```