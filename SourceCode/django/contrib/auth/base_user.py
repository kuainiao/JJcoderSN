"""
This module allows importing AbstractBaseUser even when django.contrib.auth is
not in INSTALLED_APPS.
"""
import unicodedata

from django.contrib.auth import password_validation
from django.contrib.auth.hashers import (
    check_password, is_password_usable, make_password,
)
from django.db import models
from django.utils.crypto import get_random_string, salted_hmac
from django.utils.translation import gettext_lazy as _


class BaseUserManager(models.Manager):

    @classmethod
    def normalize_email(cls, email):
        """
        通过小写其域部分来规范化电子邮件地址。
        """
        email = email or ''
        try:
            email_name, domain_part = email.strip().rsplit('@', 1)
        except ValueError:
            pass
        else:
            email = email_name + '@' + domain_part.lower()
        return email

    def make_random_password(self, length=10,
                             allowed_chars='abcdefghjkmnpqrstuvwxyz'
                                           'ABCDEFGHJKLMNPQRSTUVWXYZ'
                                           '23456789'):
        """
        生成具有给定长度和给定allowed_chars的随机密码。默认的allowed_chars值没有“ I”或“ O”或看起来相似的字母和数字，只是为了避免混淆。
        """
        return get_random_string(length, allowed_chars)

    def get_by_natural_key(self, username):
        return self.get(**{self.model.USERNAME_FIELD: username})


class AbstractBaseUser(models.Model):
    password = models.CharField(_('password'), max_length=128)
    last_login = models.DateTimeField(_('last login'), blank=True, null=True)

    is_active = True

    REQUIRED_FIELDS = []  # 这个列表是用来填写需要验证的字段， REQUIRED_FIELEDS = ['username', 'telephone']

    # 如果调用了set_password（），则存储原始密码，以便可以在保存模型后将其传递给password_changed（）。
    _password = None

    class Meta:
        abstract = True

    def __str__(self):
        return self.get_username()

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        if self._password is not None:
            password_validation.password_changed(self._password, self)
            self._password = None

    def get_username(self):
        """返回该用户的用户名。"""
        return getattr(self, self.USERNAME_FIELD)

    def clean(self):
        setattr(self, self.USERNAME_FIELD, self.normalize_username(self.get_username()))

    def natural_key(self):
        return (self.get_username(),)

    @property
    def is_anonymous(self):
        """
        始终返回False。这是将用户对象与匿名用户进行比较的一种方式。
        """
        return False

    @property
    def is_authenticated(self):
        """
        始终返回True。这是一种告诉用户是否已在模板中进行身份验证的方法。
        """
        return True

    def set_password(self, raw_password):
        self.password = make_password(raw_password)
        self._password = raw_password

    def check_password(self, raw_password):
        """
       返回有关raw_password是否正确的布尔值。在后台处理哈希格式。
        """

        def setter(raw_password):
            self.set_password(raw_password)
            # 密码哈希升级不应视为密码更改。
            self._password = None
            self.save(update_fields=["password"])

        return check_password(raw_password, self.password, setter)

    def set_unusable_password(self):
        # 设置一个永远不会是有效哈希的值
        self.password = make_password(None)

    def has_usable_password(self):
        """
        如果已为此用户调用set_unusable_password（），则返回False。
        """
        return is_password_usable(self.password)

    def get_session_auth_hash(self):
        """
        返回密码字段的HMAC。
        """
        key_salt = "django.contrib.auth.models.AbstractBaseUser.get_session_auth_hash"
        return salted_hmac(key_salt, self.password).hexdigest()

    @classmethod
    def get_email_field_name(cls):
        try:
            return cls.EMAIL_FIELD
        except AttributeError:
            return 'email'

    @classmethod
    def normalize_username(cls, username):
        return unicodedata.normalize('NFKC', username) if isinstance(username, str) else username
