"""
内容协商涉及在给定的情况下选择合适的渲染器传入请求。通常，这将基于请求的Accept标头。
"""
from django.http import Http404

from rest_framework import HTTP_HEADER_ENCODING, exceptions
from rest_framework.settings import api_settings
from rest_framework.utils.mediatypes import (
    _MediaType, media_type_matches, order_by_precedence
)


class BaseContentNegotiation:
    def select_parser(self, request, parsers):
        raise NotImplementedError('.select_parser() must be implemented')

    def select_renderer(self, request, renderers, format_suffix=None):
        raise NotImplementedError('.select_renderer() must be implemented')


class DefaultContentNegotiation(BaseContentNegotiation):
    settings = api_settings

    def select_parser(self, request, parsers):
        """
        给定解析器列表和媒体类型，请返回适当的解析器以处理传入的请求。
        """
        for parser in parsers:
            if media_type_matches(parser.media_type, request.content_type):
                return parser
        return None

    def select_renderer(self, request, renderers, format_suffix=None):
        """
       给定一个请求和一个渲染器列表，返回一个二元组的：（渲染器，媒体类型）。
        """
        # 允许覆盖URL样式格式。例如。 “？format = json
        format_query_param = self.settings.URL_FORMAT_OVERRIDE
        format = format_suffix or request.query_params.get(format_query_param)

        if format:
            renderers = self.filter_renderers(renderers, format)

        accepts = self.get_accept_list(request)

        # Check the acceptable media types against each renderer,
        # attempting more specific media types first
        # NB. The inner loop here isn't as bad as it first looks :)
        #     Worst case is we're looping over len(accept_list) * len(self.renderers)
        for media_type_set in order_by_precedence(accepts):
            for renderer in renderers:
                for media_type in media_type_set:
                    if media_type_matches(renderer.media_type, media_type):
                        # Return the most specific media type as accepted.
                        media_type_wrapper = _MediaType(media_type)
                        if (
                            _MediaType(renderer.media_type).precedence >
                            media_type_wrapper.precedence
                        ):
                            # Eg client requests '*/*'
                            # Accepted media type is 'application/json'
                            full_media_type = ';'.join(
                                (renderer.media_type,) +
                                tuple('{}={}'.format(
                                    key, value.decode(HTTP_HEADER_ENCODING))
                                    for key, value in media_type_wrapper.params.items()))
                            return renderer, full_media_type
                        else:
                            # Eg client requests 'application/json; indent=8'
                            # Accepted media type is 'application/json; indent=8'
                            return renderer, media_type

        raise exceptions.NotAcceptable(available_renderers=renderers)

    def filter_renderers(self, renderers, format):
        """
        If there is a '.json' style format suffix, filter the renderers
        so that we only negotiation against those that accept that format.
        """
        renderers = [renderer for renderer in renderers
                     if renderer.format == format]
        if not renderers:
            raise Http404
        return renderers

    def get_accept_list(self, request):
        """
        Given the incoming request, return a tokenized list of media
        type strings.
        """
        header = request.META.get('HTTP_ACCEPT', '*/*')
        return [token.strip() for token in header.split(',')]
