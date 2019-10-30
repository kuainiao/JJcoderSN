"""
解析器用于解析传入的HTTP请求的内容。它们为我们提供了一种处理各种媒体类型的通用方法
根据请求，例如表单内容或json编码的数据。
"""
import codecs
from urllib import parse

from django.conf import settings
from django.core.files.uploadhandler import StopFutureHandlers
from django.http import QueryDict
from django.http.multipartparser import ChunkIter
from django.http.multipartparser import \
    MultiPartParser as DjangoMultiPartParser
from django.http.multipartparser import MultiPartParserError, parse_header
from django.utils.encoding import force_str

from rest_framework import renderers
from rest_framework.exceptions import ParseError
from rest_framework.settings import api_settings
from rest_framework.utils import json


class DataAndFiles:
    def __init__(self, data, files):
        self.data = data
        self.files = files


class BaseParser:
    """
    所有解析器都应该扩展BaseParser，指定一个media_type属性，并覆盖.parse（）方法。
    """
    media_type = None

    def parse(self, stream, media_type=None, parser_context=None):
        """
        给定要读取的流，返回解析的表示形式。应该返回解析后的数据，或者返回一个包含解析后的数据和文件的DataAndFiles对象。
        """
        raise NotImplementedError(".parse() must be overridden.")


class JSONParser(BaseParser):
    """
    Parses JSON-serialized data.
    """
    media_type = 'application/json'
    renderer_class = renderers.JSONRenderer
    strict = api_settings.STRICT_JSON

    def parse(self, stream, media_type=None, parser_context=None):
        """
        将传入的字节流解析为JSON并返回结果数据。
        """
        parser_context = parser_context or {}
        encoding = parser_context.get('encoding', settings.DEFAULT_CHARSET)

        try:
            decoded_stream = codecs.getreader(encoding)(stream)
            parse_constant = json.strict_constant if self.strict else None
            return json.load(decoded_stream, parse_constant=parse_constant)
        except ValueError as exc:
            raise ParseError('JSON parse error - %s' % str(exc))


class FormParser(BaseParser):
    """
    表单数据解析器。
    """
    media_type = 'application/x-www-form-urlencoded'

    def parse(self, stream, media_type=None, parser_context=None):
        """
        将传入的字节流解析为URL编码形式，并返回结果QueryDict。
        """
        parser_context = parser_context or {}
        encoding = parser_context.get('encoding', settings.DEFAULT_CHARSET)
        return QueryDict(stream.read(), encoding=encoding)


class MultiPartParser(BaseParser):
    """
    多部分表单数据的解析器，其中可能包括文件数据。
    """
    media_type = 'multipart/form-data'

    def parse(self, stream, media_type=None, parser_context=None):
        """
        将传入的字节流解析为多部分编码形式，并返回DataAndFiles对象

        .data将是包含所有表单参数的QueryDict。
        .files将是一个包含所有表单文件的QueryDict。
        """
        parser_context = parser_context or {}
        request = parser_context['request']
        encoding = parser_context.get('encoding', settings.DEFAULT_CHARSET)
        meta = request.META.copy()
        meta['CONTENT_TYPE'] = media_type
        upload_handlers = request.upload_handlers

        try:
            parser = DjangoMultiPartParser(meta, stream, upload_handlers, encoding)
            data, files = parser.parse()
            return DataAndFiles(data, files)
        except MultiPartParserError as exc:
            raise ParseError('Multipart form parse error - %s' % str(exc))


class FileUploadParser(BaseParser):
    """
    用于文件上传数据的解析器。
    """
    media_type = '*/*'
    errors = {
        'unhandled': 'FileUpload parse error - none of upload handlers can handle the stream',
        'no_filename': 'Missing filename. Request should include a Content-Disposition header with a filename parameter.',
    }

    def parse(self, stream, media_type=None, parser_context=None):
        """
        将传入的字节流视为原始文件上传，并返回`DataAndFiles`对象。

        .data将为None（我们希望请求正文为文件内容）。
        .files将是一个包含一个file元素的QueryDict。
        """
        parser_context = parser_context or {}
        request = parser_context['request']
        encoding = parser_context.get('encoding', settings.DEFAULT_CHARSET)
        meta = request.META
        upload_handlers = request.upload_handlers
        filename = self.get_filename(stream, media_type, parser_context)

        if not filename:
            raise ParseError(self.errors['no_filename'])

        # 请注意，此代码是从Django在MultiPartParser中对＃文件上传的处理中提取的。
        content_type = meta.get('HTTP_CONTENT_TYPE',
                                meta.get('CONTENT_TYPE', ''))
        try:
            content_length = int(meta.get('HTTP_CONTENT_LENGTH',
                                          meta.get('CONTENT_LENGTH', 0)))
        except (ValueError, TypeError):
            content_length = None

        # See if the handler will want to take care of the parsing.
        for handler in upload_handlers:
            result = handler.handle_raw_input(stream,
                                              meta,
                                              content_length,
                                              None,
                                              encoding)
            if result is not None:
                return DataAndFiles({}, {'file': result[1]})

        # This is the standard case.
        possible_sizes = [x.chunk_size for x in upload_handlers if x.chunk_size]
        chunk_size = min([2 ** 31 - 4] + possible_sizes)
        chunks = ChunkIter(stream, chunk_size)
        counters = [0] * len(upload_handlers)

        for index, handler in enumerate(upload_handlers):
            try:
                handler.new_file(None, filename, content_type,
                                 content_length, encoding)
            except StopFutureHandlers:
                upload_handlers = upload_handlers[:index + 1]
                break

        for chunk in chunks:
            for index, handler in enumerate(upload_handlers):
                chunk_length = len(chunk)
                chunk = handler.receive_data_chunk(chunk, counters[index])
                counters[index] += chunk_length
                if chunk is None:
                    break

        for index, handler in enumerate(upload_handlers):
            file_obj = handler.file_complete(counters[index])
            if file_obj is not None:
                return DataAndFiles({}, {'file': file_obj})

        raise ParseError(self.errors['unhandled'])

    def get_filename(self, stream, media_type, parser_context):
        """
        检测上传的文件名。首先搜索“文件名”网址kwarg。然后尝试解析Content-Disposition标头。
        """
        try:
            return parser_context['kwargs']['filename']
        except KeyError:
            pass

        try:
            meta = parser_context['request'].META
            disposition = parse_header(meta['HTTP_CONTENT_DISPOSITION'].encode())
            filename_parm = disposition[1]
            if 'filename*' in filename_parm:
                return self.get_encoded_filename(filename_parm)
            return force_str(filename_parm['filename'])
        except (AttributeError, KeyError, ValueError):
            pass

    def get_encoded_filename(self, filename_parm):
        """
        Handle encoded filenames per RFC6266. See also:
        https://tools.ietf.org/html/rfc2231#section-4
        """
        encoded_filename = force_str(filename_parm['filename*'])
        try:
            charset, lang, filename = encoded_filename.split('\'', 2)
            filename = parse.unquote(filename)
        except (ValueError, LookupError):
            filename = force_str(filename_parm['filename'])
        return filename
