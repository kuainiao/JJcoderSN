"""
可浏览API的登录和注销视图。

如果您使用的是可浏览的API，请将这些添加到您的根URLconf中，您的API需要身份验证：

    urlpatterns = [
        ...
        url(r'^auth/', include('rest_framework.urls'))
    ]

您应确保身份验证设置包括“ SessionAuthentication”。
"""
from django.conf.urls import url
from django.contrib.auth import views

app_name = 'rest_framework'
urlpatterns = [
    url(r'^login/$', views.LoginView.as_view(template_name='rest_framework/login.html'), name='login'),
    url(r'^logout/$', views.LogoutView.as_view(), name='logout'),
]
