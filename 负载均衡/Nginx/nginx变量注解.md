# nginx变量注解

------

# nginx变量注解

> nginx_version 变量解释

| 参数名称            | 注释                                                         |
| ------------------- | ------------------------------------------------------------ |
| $arg_PARAMETER      | HTTP 请求中某个参数的值,如/index.php?site=www.ttlsa.com,可以用$arg_site 取得 www.ttlsa.com 这个值. |
| $args HTTP          | 请求中的完整参数。例如,在请求/index.php?width=400&height=200 中,$args 表示 字符串 width=400&height=200. |
| $binary_remote_addr | 二进制格式的客户端地址。例如:\x0A\xE0B\x0E                   |
| $body_bytes_sent    | 表示在向客户端发送的 http 响应中,包体部分的字节数            |
| $content_length     | 表示客户端请求头部中的 Content-Length 字段                   |
| $content_type       | 表示客户端请求头部中的 Content-Type 字段                     |
| $cookie_COOKIE      | 表示在客户端请求头部中的 cookie 字段                         |
| $document_root      | 表示当前请求所使用的 root 配置项的值                         |
| $uri                | 表示当前请求的 URI,不带任何参数                              |
| $document_uri       | 与$uri 含义相同                                              |
| $request_uri        | 表示客户端发来的原始请求 URI,带完整的参数。$uri 和$document_uri 未必是用户的原始请求,在内部重定向后可能是重定向后的 URI,而$request_uri 永远不会改变,始终是客户端的原始 URI. |
| $host               | 表示客户端请求头部中的 Host 字段。如果 Host 字段不存在,则以实际处理的 server(虚拟主机)名称代替。如果 Host 字段中带有端口,如 IP:PORT,那么$host 是去掉端口的,它的值为 IP。$host是全小写的。这些特性与 http_HEADER 中的 http_host 不同,http_host 只取出 Host 头部对应的值。 |
| $hostname           | 表示 Nginx 所在机器的名称,与 gethostbyname 调用返回的值相同  |
| $http_HEADER        | 表示当前 HTTP 请求中相应头部的值。HEADER 名称全小写。例如,示请求中 Host 头部对应的值 用 $http_host 表 |
| $sent_http_HEADER   | 表示返回客户端的 HTTP 响应中相应头部的值。HEADER 名称全小写。例如,用 $sent_http_content_type 表示响应中 Content-Type 头部对应的值 |
| $is_args            | 表示请求中的 URI 是否带参数,如果带参数,$is_args 值为 ?,如果不带参数,则是空字符串 |
| $limit_rate         | 表示当前连接的限速是多少,0 表示无限速                        |
| $nginx_version      | 表示当前 Nginx 的版本号                                      |
| $query_string       | 请求 URI 中的参数,与 $args 相同,然而 $query_string 是只读的不会改变 |
| $remote_addr        | 表示客户端的地址                                             |
| $remote_port        | 表示客户端连接使用的端口                                     |
| $remote_user        | 表示使用 Auth Basic Module 时定义的用户名                    |
| $request_filename   | 表示用户请求中的 URI 经过 root 或 alias 转换后的文件路径     |
| $request_body       | 表示 HTTP 请求中的包体,该参数只在 proxy_pass 或 fastcgi_pass 中有意义 |
| $request_body_file  | 表示 HTTP 请求中的包体存储的临时文件名                       |
| $request_completion | 当请求已经全部完成时,其值为 “ok”。若没有完成,就要返回客户端,则其值为空字符串;或者在断点续传等情况下使用 HTTP range 访问的并不是文件的最后一块,那么其值也是空字符串。 |
| $request_method     | 表示 HTTP 请求的方法名,如 GET、PUT、POST 等                  |
| $scheme             | 表示 HTTP scheme,如在请求 https://nginx.com/中表示 https     |
| $server_addr        | 表示服务器地址                                               |
| $server_name        | 表示服务器名称                                               |
| $server_port        | 表示服务器端口                                               |
| $server_protocol    | 表示服务器向客户端发送响应的协议,如 HTTP/1.1 或 HTTP/1.0     |

## nginx日志变量注解

### log_format 指令

- 语法: log_format name string ...;
- 默认值: log_format combined “...”;
- 配置段: http
- name 表示格式名称,string 表示等义的格式。

log_format 有一个默认的无需设置的 combined 日志格式,相当于apache 的 combined 日志格式,如下所示:

```
  log_format combined
  '$remote_addr - $remote_user [$time_local] '
  ' "$request" $status $body_bytes_sent '
  ' "$http_referer" "$http_user_agent" ';
```

如果 nginx 位于负载均衡器,squid,nginx 反向代理之后,web 服务器无法直接获取到客户端真实的 IP 地址了。

$remote_addr 获取反向代理的 IP 地址。反向代理服务器在转发请求的 http 头信息中,可以增加 X-Forwarded-For 信息,用来记录 客户端 IP 地址和客户端请求的服务器地址。PS: 获取用户真实 IP 参见 http://www.ttlsa.com/html/2235.html 如下所示:

```
    log_format porxy
    '$http_x_forwarded_for - $remote_user [$time_local] '
    ' "$request" $status $body_bytes_sent '
    ' "$http_referer" "$http_user_agent" ';
```

> 日志格式允许包含的变量注释如下:

| 参数                                | 注解                                                         |
| ----------------------------------- | ------------------------------------------------------------ |
| $remote_addr, $http_x_forwarded_for | 记录客户端 IP 地址                                           |
| $remote_user                        | 记录客户端用户名称                                           |
| $request                            | 记录请求的 URL 和 HTTP 协议                                  |
| $status                             | 记录请求状态                                                 |
| $body_bytes_sent                    | 发送给客户端的字节数,不包括响应头的大小; 该变量与 Apache 模块 |
| $bytes_sent                         | 发送给客户端的总字节数。                                     |
| $connection                         | 连接的序列号。                                               |
| $connection_requests                | 当前通过一个连接获得的请求数量。                             |
| $msec                               | 日志写入时间。单位为秒,精度是毫秒。                          |
| $pipe                               | 如果请求是通过 HTTP 流水线(pipelined)发送,pipe 值为“p”,否则为“.”。 |
| $http_referer                       | 记录从哪个页面链接访问过来的                                 |
| $http_user_agent                    | 记录客户端浏览器相关信息                                     |
| $request_length                     | 请求的长度(包括请求行,请求头和请求正文)。                    |
| $request_time                       | 请求处理时间,单位为秒,精度毫秒; 从读入客户端的第一个字节开始,直到把最后一个字符发送给客户端后进行日志写入为止。 |
| $time_iso8601 ISO8601               | 标准格式下的本地时间。                                       |
| $time_local                         | 通用日志格式下的本地时间。                                   |
| [warning]                           | 发送给客户端的响应头拥有“sent_http_”前缀。 如$sent_http_content_range。[/warning] |

> 实例如下:

```yml
    http {
      log_format main '$remote_addr - $remote_user [$time_local] "$request" '
      '"$status" $body_bytes_sent "$http_referer" '
      '"$http_user_agent" "$http_x_forwarded_for" '
      '"$gzip_ratio" $request_time $bytes_sent $request_length';
      log_format srcache_log '$remote_addr - $remote_user [$time_local] "$request" '
      '"$status"
      $body_bytes_sent
      $request_time
      $bytes_sent
      $request_length '
      '[$upstream_response_time]
      [$srcache_fetch_status]
      [$srcache_store_status] [$srcache_expire]';
      open_log_file_cache max=1000 inactive=60s;
    server {
      server_name ~^(www\.)?(.+)$;
      access_log logs/$2-access.log main;
      error_log logs/$2-error.log;
      location /srcache {
        access_log logs/access-srcache.log srcache_log;
      }
    }
  }
```