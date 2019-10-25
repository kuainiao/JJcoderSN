"""
提供各种身份验证策略。
"""
import base64
import binascii

from django.contrib.auth import authenticate, get_user_model
from django.middleware.csrf import CsrfViewMiddleware
from django.utils.translation import gettext_lazy as _

from rest_framework import HTTP_HEADER_ENCODING, exceptions


def get_authorization_header(request):
    """
   以字节串形式返回请求的“ Authorization：”标头。隐藏标头可以是unicode的一些测试客户端异常。
    """
    auth = request.META.get('HTTP_AUTHORIZATION', b'')
    if isinstance(auth, str):
        # 解决Django测试客户端奇怪的问题
        auth = auth.encode(HTTP_HEADER_ENCODING)
    return auth


class CSRFCheck(CsrfViewMiddleware):
    def _reject(self, request, reason):
        # 返回失败原因而不是HttpResponse
        return reason


class BaseAuthentication:
    """
    所有身份验证类都应扩展BaseAuthentication。
    """

    def authenticate(self, request):
        """
        验证请求并返回（user，token）的二元组。
        """
        raise NotImplementedError(".authenticate() must be overridden.")

    def authenticate_header(self, request):
        """
        返回一个字符串，用作“ 401 Unauthenticated”响应中的“ WWW-Authenticate”标头的值，
        如果身份验证方案应返回“ 403 Permission Denied”响应，则返回“ None”。
        """
        pass


class BasicAuthentication(BaseAuthentication):
    """
    针对用户名/密码的HTTP基本身份验证。
    """
    www_authenticate_realm = 'api'

    def authenticate(self, request):
        """
       如果使用HTTP Basic身份验证提供了正确的用户名和密码，则返回“user”。否则返回“None”。
        """
        auth = get_authorization_header(request).split()

        if not auth or auth[0].lower() != b'basic':
            return None

        if len(auth) == 1:
            msg = _('Invalid basic header. No credentials provided.')
            raise exceptions.AuthenticationFailed(msg)
        elif len(auth) > 2:
            msg = _('Invalid basic header. Credentials string should not contain spaces.')
            raise exceptions.AuthenticationFailed(msg)

        try:
            auth_parts = base64.b64decode(auth[1]).decode(HTTP_HEADER_ENCODING).partition(':')
        except (TypeError, UnicodeDecodeError, binascii.Error):
            msg = _('Invalid basic header. Credentials not correctly base64 encoded.')
            raise exceptions.AuthenticationFailed(msg)

        userid, password = auth_parts[0], auth_parts[2]
        return self.authenticate_credentials(userid, password, request)

    def authenticate_credentials(self, userid, password, request=None):
        """
       针对用户名和密码对用户标识和密码进行身份验证，并提供可选的上下文请求。
        """
        credentials = {
            get_user_model().USERNAME_FIELD: userid,
            'password': password
        }
        user = authenticate(request=request, **credentials)

        if user is None:
            raise exceptions.AuthenticationFailed(_('Invalid username/password.'))

        if not user.is_active:
            raise exceptions.AuthenticationFailed(_('User inactive or deleted.'))

        return (user, None)

    def authenticate_header(self, request):
        return 'Basic realm="%s"' % self.www_authenticate_realm


class SessionAuthentication(BaseAuthentication):
    """
    使用Django的会话框架进行身份验证。
    """

    def authenticate(self, request):
        """
        如果请求会话当前有一个登录用户，则返回一个“user”。否则返回“None”。
        """

        # 从基础HttpRequest对象获取基于会话的用户
        user = getattr(request._request, 'user', None)

        # 未经身份验证，不需要CSRF验证
        if not user or not user.is_active:
            return None

        self.enforce_csrf(request)

        # CSRF已通过身份验证的用户
        return (user, None)

    def enforce_csrf(self, request):
        """
        对基于会话的身份验证强制执行CSRF验证。
        """
        check = CSRFCheck()
        # 填充request.META ['CSRF_COOKIE']，在process_view（）中使用
        check.process_request(request)
        reason = check.process_view(request, None, (), {})
        if reason:
            # CSRF失败，以明确的错误消息保释
            raise exceptions.PermissionDenied('CSRF Failed: %s' % reason)


class TokenAuthentication(BaseAuthentication):
    """
    基于简单令牌的身份验证。
    客户端应通过在“ Authorization” HTTP头中传递令牌密钥进行身份验证，该令牌头带有字符串“ Token”。例如：
    Authorization: Token 401f7ac837da42b97f613d789819ff93537bee6a
    """

    keyword = 'Token'
    model = None

    def get_model(self):
        if self.model is not None:
            return self.model
        from rest_framework.authtoken.models import Token
        return Token

    """
    可以使用自定义令牌模型，但必须具有以下属性。

    * key -- 标识令牌的字符串
    * user -- 令牌所属的用户
    """

    def authenticate(self, request):
        auth = get_authorization_header(request).split()

        if not auth or auth[0].lower() != self.keyword.lower().encode():
            return None

        if len(auth) == 1:
            msg = _('Invalid token header. No credentials provided.')
            raise exceptions.AuthenticationFailed(msg)
        elif len(auth) > 2:
            msg = _('Invalid token header. Token string should not contain spaces.')
            raise exceptions.AuthenticationFailed(msg)

        try:
            token = auth[1].decode()
        except UnicodeError:
            msg = _('Invalid token header. Token string should not contain invalid characters.')
            raise exceptions.AuthenticationFailed(msg)

        return self.authenticate_credentials(token)

    def authenticate_credentials(self, key):
        model = self.get_model()
        try:
            token = model.objects.select_related('user').get(key=key)
        except model.DoesNotExist:
            raise exceptions.AuthenticationFailed(_('Invalid token.'))

        if not token.user.is_active:
            raise exceptions.AuthenticationFailed(_('User inactive or deleted.'))

        return (token.user, token)

    def authenticate_header(self, request):
        return self.keyword


class RemoteUserAuthentication(BaseAuthentication):
    """
    REMOTE_USER身份验证。要使用此功能，请设置您的Web服务器以执行身份验证，这将设置REMOTE_USER环境变量。
    您的AUTHENTICATION_BACKENDS设置中需要有'django.contrib.auth.backends.RemoteUserBackend
    """

    # 从中获取用户名的请求标头的名称。这将是request.META词典中使用的的关键，即将标头标准化为所有大写字母，并加上“ HTTP_”前缀。
    header = "REMOTE_USER"

    def authenticate(self, request):
        user = authenticate(remote_user=request.META.get(self.header))
        if user and user.is_active:
            return (user, None)
