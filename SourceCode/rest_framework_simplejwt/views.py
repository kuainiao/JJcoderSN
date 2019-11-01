from rest_framework import generics, status
from rest_framework.response import Response

from . import serializers
from .authentication import AUTH_HEADER_TYPES
from .exceptions import InvalidToken, TokenError


class TokenViewBase(generics.GenericAPIView):
    permission_classes = ()
    authentication_classes = ()

    serializer_class = None

    www_authenticate_realm = 'api'

    def get_authenticate_header(self, request):
        return '{0} realm="{1}"'.format(
            AUTH_HEADER_TYPES[0],
            self.www_authenticate_realm,
        )

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)

        try:
            serializer.is_valid(raise_exception=True)
        except TokenError as e:
            raise InvalidToken(e.args[0])

        return Response(serializer.validated_data, status=status.HTTP_200_OK)


class TokenObtainPairView(TokenViewBase):
    """
    获取一组用户凭据，并返回访问和刷新JSON Web令牌对，以证明这些凭据的身份验证。
    """
    serializer_class = serializers.TokenObtainPairSerializer


token_obtain_pair = TokenObtainPairView.as_view()


class TokenRefreshView(TokenViewBase):
    """
    获取刷新类型JSON Web令牌，如果刷新令牌有效，则返回访问类型JSON Web令牌。
    """
    serializer_class = serializers.TokenRefreshSerializer


token_refresh = TokenRefreshView.as_view()


class TokenObtainSlidingView(TokenViewBase):
    """
    获取一组用户凭证，并返回一个滑动JSON Web令牌以证明这些凭证的身份验证。
    """
    serializer_class = serializers.TokenObtainSlidingSerializer


token_obtain_sliding = TokenObtainSlidingView.as_view()


class TokenRefreshSlidingView(TokenViewBase):
    """
    获取滑动的JSON Web令牌，如果令牌的刷新期限尚未到期，则返回新的刷新版本。
    """
    serializer_class = serializers.TokenRefreshSlidingSerializer


token_refresh_sliding = TokenRefreshSlidingView.as_view()


class TokenVerifyView(TokenViewBase):
    """
    获取令牌并指示其是否有效。该视图未提供有关令牌对特定用途的适用性的信息。
    """
    serializer_class = serializers.TokenVerifySerializer


token_verify = TokenVerifyView.as_view()
