from django.urls import get_script_prefix, resolve


def get_breadcrumbs(url, request=None):
    """
   给定url，返回面包屑列表，每个面包屑都是（name，url）的元组。
    """
    from rest_framework.reverse import preserve_builtin_query_params
    from rest_framework.views import APIView

    def breadcrumbs_recursive(url, breadcrumbs_list, prefix, seen):
        """
        将（name，url）的元组添加到面包屑列表中，逐步删除部分url。
        """
        try:
            (view, unused_args, unused_kwargs) = resolve(url)
        except Exception:
            pass
        else:
            # 检查这是否是REST框架视图，如果是，则将其添加到面包屑中
            cls = getattr(view, 'cls', None)
            initkwargs = getattr(view, 'initkwargs', {})
            if cls is not None and issubclass(cls, APIView):
                # 不要连续两次列出同一视图。 可能是可选的斜杠。
                if not seen or seen[-1] != view:
                    c = cls(**initkwargs)
                    name = c.get_view_name()
                    insert_url = preserve_builtin_query_params(prefix + url, request)
                    breadcrumbs_list.insert(0, (name, insert_url))
                    seen.append(view)

        if url == '':
            # All done
            return breadcrumbs_list

        elif url.endswith('/'):
            # 末尾添加斜杠，并继续尝试解决更多的面包屑
            url = url.rstrip('/')
            return breadcrumbs_recursive(url, breadcrumbs_list, prefix, seen)

        # 将结尾的非斜杠删除掉，并继续尝试解决更多的面包屑
        url = url[:url.rfind('/') + 1]
        return breadcrumbs_recursive(url, breadcrumbs_list, prefix, seen)

    prefix = get_script_prefix().rstrip('/')
    url = url[len(prefix):]
    return breadcrumbs_recursive(url, [], prefix, [])
