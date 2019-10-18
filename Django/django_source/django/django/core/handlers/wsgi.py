import re
from io import BytesIO

from django.conf import settings
from django.core import signals
from django.core.handlers import base
from django.http import HttpRequest, QueryDict, parse_cookie
from django.urls import set_script_prefix
from django.utils.encoding import repercent_broken_unicode
from django.utils.functional import cached_property

_slashes_re = re.compile(br'/+')


class LimitedStream:
    """Wrap another stream to disallow reading it past a number of bytes.
        包装另一个流，使其不允许读取超过若干字节的数据。
    """
    def __init__(self, stream, limit, buf_size=64 * 1024 * 1024):
        self.stream = stream
        self.remaining = limit
        self.buffer = b''
        self.buf_size = buf_size

    def _read_limited(self, size=None):
        if size is None or size > self.remaining:
            size = self.remaining
        if size == 0:
            return b''
        result = self.stream.read(size)
        self.remaining -= len(result)
        return result

    def read(self, size=None):
        if size is None:
            result = self.buffer + self._read_limited()
            self.buffer = b''
        elif size < len(self.buffer):
            result = self.buffer[:size]
            self.buffer = self.buffer[size:]
        else:  # size >= len(self.buffer)
            result = self.buffer + self._read_limited(size - len(self.buffer))
            self.buffer = b''
        return result

    def readline(self, size=None):
        while b'\n' not in self.buffer and \
              (size is None or len(self.buffer) < size):
            if size:
                # since size is not None here, len(self.buffer) < size
                chunk = self._read_limited(size - len(self.buffer))
            else:
                chunk = self._read_limited()
            if not chunk:
                break
            self.buffer += chunk
        sio = BytesIO(self.buffer)
        if size:
            line = sio.readline(size)
        else:
            line = sio.readline()
        self.buffer = sio.read()
        return line

# 这里注意，首先django在接受到http请求后，会根据http请求携带的参数以及报文信息创建一个WSGIRequest对象，并且作为视图函数第一个参数传给视图函数。也就是我们经常看到的request参数
class WSGIRequest(HttpRequest): # 这里继承了HttpRequest基础的http request
    def __init__(self, environ):
        script_name = get_script_name(environ)
        # If PATH_INFO is empty (e.g. accessing the SCRIPT_NAME URL without a
        # trailing slash), operate as if '/' was requested.
        path_info = get_path_info(environ) or '/'
        self.environ = environ
        self.path_info = path_info
        # be careful to only replace the first slash in the path because of
        # http://test/something and http://test//something being different as
        # stated in https://www.ietf.org/rfc/rfc2396.txt
        self.path = '%s/%s' % (script_name.rstrip('/'),
                               path_info.replace('/', '', 1)) # path: 请求服务器的完整路径，但是不包含域名和参数
        self.META = environ  # META：存储客户端发送上来的所有头部信息
        self.META['PATH_INFO'] = path_info
        self.META['SCRIPT_NAME'] = script_name
        self.method = environ['REQUEST_METHOD'].upper() # method: 当前请求的http方法,这里将method转成了大写
        # Set content_type, content_params, and encoding.
        self._set_content_type_params(environ)
        try:
            content_length = int(environ.get('CONTENT_LENGTH')) # CONTENT_LENGTH:请求的正文长度（是一个字符串）
        except (ValueError, TypeError):
            content_length = 0
        self._stream = LimitedStream(self.environ['wsgi.input'], content_length)
        self._read_started = False
        self.resolver_match = None

    def _get_scheme(self):
        return self.environ.get('wsgi.url_scheme')

    @cached_property
    def GET(self):  # GET请求，一个django.http.request.QueryDict对象
        # The WSGI spec says 'QUERY_STRING' may be absent.
        raw_query_string = get_bytes_from_wsgi(self.environ, 'QUERY_STRING', '')
        return QueryDict(raw_query_string, encoding=self._encoding)

    def _get_post(self):
        if not hasattr(self, '_post'):
            self._load_post_and_files()
        return self._post

    def _set_post(self, post):
        self._post = post

    @cached_property
    def COOKIES(self): # COOKIES信息，标准的python字典，键值对都是字符串类型
        raw_cookie = get_str_from_wsgi(self.environ, 'HTTP_COOKIE', '')
        return parse_cookie(raw_cookie)

    @property
    def FILES(self): # 所有上传的文件，一个django.http.request.QueryDict对象
        if not hasattr(self, '_files'):
            self._load_post_and_files()
        return self._files

    POST = property(_get_post, _set_post) # POST请求，一个django.http.request.QueryDict对象


class WSGIHandler(base.BaseHandler):
    request_class = WSGIRequest

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.load_middleware()

    def __call__(self, environ, start_response):
        set_script_prefix(get_script_name(environ))
        signals.request_started.send(sender=self.__class__, environ=environ)
        request = self.request_class(environ)
        response = self.get_response(request)

        response._handler_class = self.__class__

        status = '%d %s' % (response.status_code, response.reason_phrase)
        response_headers = [
            *response.items(),
            *(('Set-Cookie', c.output(header='')) for c in response.cookies.values()),
        ]
        start_response(status, response_headers)
        if getattr(response, 'file_to_stream', None) is not None and environ.get('wsgi.file_wrapper'):
            response = environ['wsgi.file_wrapper'](response.file_to_stream, response.block_size)
        return response


def get_path_info(environ):
    """Return the HTTP request's PATH_INFO as a string."""
    path_info = get_bytes_from_wsgi(environ, 'PATH_INFO', '/')

    return repercent_broken_unicode(path_info).decode()


def get_script_name(environ):
    """
    Return the equivalent of the HTTP request's SCRIPT_NAME environment
    variable. If Apache mod_rewrite is used, return what would have been
    the script name prior to any rewriting (so it's the script name as seen
    from the client's perspective), unless the FORCE_SCRIPT_NAME setting is
    set (to anything).
    返回HTTP请求的脚本名环境变量的等效值。如果使用Apache mod重写，则返回任何重写之前的脚本名称(因此从客户机的角度来看，它是脚本名称)，除非强制脚本名称设置(设置为任何值)。
    """
    if settings.FORCE_SCRIPT_NAME is not None:
        return settings.FORCE_SCRIPT_NAME

    # If Apache's mod_rewrite had a whack at the URL, Apache set either
    # SCRIPT_URL or REDIRECT_URL to the full resource URL before applying any
    # rewrites. Unfortunately not every Web server (lighttpd!) passes this
    # information through all the time, so FORCE_SCRIPT_NAME, above, is still
    # needed.
    # 如果Apache的mod重写对URL有影响，Apache在应用任何重写之前，要么设置SCRIPT URL，要么将URL重定向到完整的资源URL。不幸的是，并不是每个Web服务器(lighttpd!)都一直传递这个信息，所以上面的FORCE脚本名仍然是必需的。
    script_url = get_bytes_from_wsgi(environ, 'SCRIPT_URL', '') or get_bytes_from_wsgi(environ, 'REDIRECT_URL', '')

    if script_url:
        if b'//' in script_url:
            # mod_wsgi squashes multiple successive slashes in PATH_INFO,
            # do the same with script_url before manipulating paths (#17133).
            script_url = _slashes_re.sub(b'/', script_url)
        path_info = get_bytes_from_wsgi(environ, 'PATH_INFO', '')
        script_name = script_url[:-len(path_info)] if path_info else script_url
    else:
        script_name = get_bytes_from_wsgi(environ, 'SCRIPT_NAME', '')

    return script_name.decode()


def get_bytes_from_wsgi(environ, key, default):
    """
    Get a value from the WSGI environ dictionary as bytes.

    key and default should be strings.
    以字节的形式从WSGI环境字典中获取值。键和默认值应该是字符串
    """
    value = environ.get(key, default)
    # Non-ASCII values in the WSGI environ are arbitrarily decoded with
    # ISO-8859-1. This is wrong for Django websites where UTF-8 is the default.
    # Re-encode to recover the original bytestring.
    return value.encode('iso-8859-1')


def get_str_from_wsgi(environ, key, default):
    """
    Get a value from the WSGI environ dictionary as str.

    key and default should be str objects.
    以字符串的形式从WSGI环境字典中获取值。键和默认值应该是字符串。
    """
    value = get_bytes_from_wsgi(environ, key, default)
    return value.decode(errors='replace')
    # 对error="replace"解释： 实现 'replace' 错误处理方案 (仅用于 文本编码)：编码错误替换为 '?' (并由编解码器编码)，解码错误替换为 '\ufffd' (Unicode 替换字符)。

"""
str.encode(encoding="utf-8", errors="strict")¶
返回原字符串编码为字节串对象的版本。 默认编码为 'utf-8'。 可以给出 errors 来设置不同的错误处理方案。 errors 的默认值为 'strict'，表示编码错误会引发 UnicodeError。 其他可用的值为 'ignore', 'replace', 'xmlcharrefreplace', 'backslashreplace' 以及任何其他通过 codecs.register_error() 注册的值，请参阅 错误处理方案 小节。 要查看可用的编码列表，请参阅 标准编码 小节。

bytearray.decode(encoding="utf-8", errors="strict")
返回从给定 bytes 解码出来的字符串。 默认编码为 'utf-8'。 可以给出 errors 来设置不同的错误处理方案。 errors 的默认值为 'strict'，表示编码错误会引发 UnicodeError。 其他可用的值为 'ignore', 'replace' 以及任何其他通过 codecs.register_error() 注册的名称，请参阅 错误处理方案 小节。 要查看可用的编码列表，请参阅 标准编码 小节。
"""
