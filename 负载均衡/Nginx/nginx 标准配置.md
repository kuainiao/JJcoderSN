# nginx 标准配置

------

# nginx 版本

## nginx 官方版本

### 安装与配置

#### 源码包安装

- 下载nginx对应版本源码包
- 安装编译参数

```
./configure --user=www --group=www --prefix=/app/nginx --with-http_stub_status_module --with-http_ssl_module
```

#### yum 安装

```
yum install nginx
```

## 使用方向

### tengine 做前端负载及缓存

```yml
        http {
        include       mime.types;
        default_type  application/octet-stream;
        autoindex     off;

        ##linux 2.4+   network optimize
        sendfile        on;
        tcp_nopush     on;
        tcp_nodelay    on;

        ## tengine
        server_info     off;
        server_tag    off;
        server_tokens off;
        access_log    off;

        keepalive_timeout  60;
        ### 限制header clien_body 大小等参数
        server_names_hash_bucket_size 128;
        client_header_buffer_size 32k;
        large_client_header_buffers 4 32k;
        client_max_body_size 10m;
        client_body_buffer_size 256k;


        ##cache_buff_tmp

          #  fastcgi_intercept_errors on;
          #  fastcgi_hide_header X-Powered-By;
          #  fastcgi_connect_timeout 180;
          #  fastcgi_send_timeout 180;
          #  fastcgi_read_timeout 180;
          #  fastcgi_buffer_size 128k;
          #  fastcgi_buffers 4 128K;
          #  fastcgi_busy_buffers_size 128k;
          #  fastcgi_temp_file_write_size 128k;
          #  fastcgi_temp_path /home/cache_php;


        #gzip  on;
        gzip on;
        gzip_min_length 1k;
        gzip_buffers 4 16k;
        gzip_http_version 1.0;
        gzip_comp_level 4;
        gzip_disable "MSIE [1-6].";
        gzip_types text/plain application/x-javascript text/css  text/javascript application/json application/x-httpd-php application/xml;
        gzip_vary on;


        ### lua  moty   add
        lua_package_path "/opt/nginx/conf/waf/?.lua";
        lua_shared_dict limit 10m;
        init_by_lua_file  /opt/nginx/conf/waf/init.lua;
        access_by_lua_file /opt/nginx/conf/waf/waf.lua;


        ###  upstream     
        include vhost/upstream.conf ;

        log_format access '$remote_addr - $remote_user [$time_local] "$request"'
            '$status $body_bytes_sent "$http_referer"'
            '"$http_user_agent" $http_x_forwarded_for';

        ### whiteIPlist
        geo $whiteiplist  {
            default 1;
            192.168.6.0/24 0;
        }
            map $whiteiplist  $limit {
            1 $binary_remote_addr;
            0 "";
        }


        ### limite  session

        limit_req_zone $cookie_token zone=session_limit:20m rate=10r/s;
        limit_req_zone $binary_remote_addr $uri zone=auth_limit:20m rate=10r/m;

        ###  proxy_buffer   
        proxy_connect_timeout 600;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
        proxy_buffer_size 128k;
        proxy_buffers 4 128k;
        proxy_busy_buffers_size 256k;
        proxy_temp_file_write_size 256k;
        proxy_headers_hash_max_size 1024;
        proxy_headers_hash_bucket_size 128;

        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_temp_path /home/data/nginx/nginx_temp;
        proxy_cache_path /home/data/nginx/nginx_cache levels=1:2 keys_zone=cache_one:2048m inactive=30m max_size=60g;


           # proxy_temp_path   /home/cache/nginx/proxy_temp;
           # proxy_cache_path  /home/cache/nginx/proxy_cache_www levels=1:2   keys_zone=cache_www:3000m inactive=1d max_size=20g;

            include  vhost/ap18game.com.conf;
        }


        ## 创建 负载均衡配置文件
        upstream webserver {
        consistent_hash $request_uri;
        server web1:80 weight=1;
        server web2:80 weight=1;
        session_sticky;


        check interval=3000 rise=2 fall=5 timeout=1000 type=http;
        check_http_send "GET / HTTP/1.0\r\n\r\n";
        check_http_expect_alive http_2xx http_3xx;
        }



        server {
        listen       80;
        server_name  webserver;
        root         /home/data/nginx/nginx_cache;
        index        index.php index.html index.htm;
        #charset koi8-r;

        ##access_log
        access_log  /home/data/nginx/logs/webserver.access.log  access;

        #trim on;
        #trim_jscss on;
        #location / {
        #    root   html;
        #    index  index.html index.htm;
        #}

        location / {
        proxy_next_upstream http_500 http_502 http_503 http_504 error timeout invalid_header;

        #if (-d $request_filename) {
        #    rewrite ^/(.*)$ http://$host/index.html break;
        #}

            ##  defend   CC    lua简单防CC
            limit_req zone=session_limit burst=5;
             rewrite_by_lua '
             local random = ngx.var.cookie_random
             if (random == nil) then
                return ngx.redirect("/auth?url=" .. ngx.var.request_uri)
             end
            local token = ngx.md5("opencdn" .. ngx.var.remote_addr .. random)
            if (ngx.var.cookie_token ~= token) then
                  return ngx.redirect("/auth?url=".. ngx.var.request_uri)
            end
        ';
            ### 负载均衡
            proxy_redirect         off;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://webserver;
       }

        ###  defend  CC
        location /auth {
        limit_req zone=auth_limit burst=1;
        if ($arg_url = "") {
            return 403;
        }
        access_by_lua '
            local random = math.random(9999)
            local token = ngx.md5("opencdn" .. ngx.var.remote_addr .. random)
            if (ngx.var.cookie_token ~= token) then
                ngx.header["Set-Cookie"] = {"token=" .. token, "random=" .. random}
                return ngx.redirect(ngx.var.arg_url)
            end
        ';
        }

        #location ~ .*\. (php)?$ {
        #       proxy_next_upstream http_500 http_502 http_503 http_504 error timeout invalid_header;
        #       proxy_pass http://webserver;
        #}

        ###  前端缓存
        location ~ .*\.(htm|html|js|css|gif|jpg|jpeg|png|bmp|ico|swf|flv|otf)$ {
                proxy_next_upstream http_500 http_502 http_503 http_504 error timeout invalid_header;
                proxy_cache cache_one;
                proxy_cache_valid 200 304 15m;
                proxy_cache_valid 301 302 10m;
                proxy_cache_valid any 1m;
                proxy_cache_key $host$uri$is_args$args;
                add_header Ten-webcache '$upstream_cache_status from $host';
                proxy_pass http://webserver;
                expires 30m;
        }



        ##  test lua
        location /lua {
                default_type 'text/plain';
                content_by_lua 'ngx.say("hello, lua")';
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
        location /nstatus {
                check_status;
                access_log off;
                allow 182.52.236.240;
                deny all;
        }
    }
```



### [#](http://www.liuwq.com/views/网站架构/nginx/nginx标准配置.html#nginx-做网站防火墙)nginx 做网站防火墙

**主要使用使用lua waf模块.**

```bash
git clone http://luajit.org/git/luajit-2.0.git
wget http://tengine.taobao.org/download/tengine-2.1.0.tar.gz
git clone https://github.com/loveshell/ngx_lua_waf
cd luajit-2.0 && git checkout v2.1
make
make install PREFIX=/usr/local/luajit
解压安装tengine
 ./configure --prefix=/opt/nginx --with-http_lua_module --with-luajit-lib=/usr/local/luajit/lib/ --with-luajit-inc=/usr/local/luajit/include/luajit-2.1/ --with-ld-opt=-Wl,-rpath,/usr/local/luajit/lib

make && make install
```



#### [#](http://www.liuwq.com/views/网站架构/nginx/nginx标准配置.html#测试)测试

在nginx.conf中添加一个location

```lua
location /lua {
     default_type 'text/plain';
    content_by_lua 'ngx.say("hello, lua")';
}
```



#### [#](http://www.liuwq.com/views/网站架构/nginx/nginx标准配置.html#配置ngx-lua-waf)配置ngx_lua_waf

nginx下常见的**开源waf**有mod_security、naxsi、ngx_lua_waf这三个，mod_security是最老牌的，功能最强规则细定制性又强，但是配置最复杂高并发时性能差。naxsi是原生nginx下的waf，性能不错但是基于白名单，配置也很麻烦。ngx_lua_waf功能和规则虽然没有这两个强大，但赢在性能高和易用性强，基本上零配置，而且常见的攻击类型都能防御，是比较省心的选择。安装好ngx_lua后，把下载好的ngx_lua_waf复制到conf目录下,重命名为waf，在nginx.conf的http段添加：

```lua
lua_package_path "/opt/nginx/conf/waf/?.lua";
lua_shared_dict limit 10m;
init_by_lua_file  /opt/nginxconf/waf/init.lua;
access_by_lua_file /opt/nginx/conf/waf/waf.lua;
```

修改/opt/nginx/conf/waf/config.lua文件，该文件为waf的配置文件，将RulePath和logdir改为实际的目录：

```lua
RulePath = "/opt/nginx/conf/waf/wafconf/"
logdir = "/opt/nginx/logs/waf"   //确保此文件夹nginx有写入权限
```

其它的安全配置，按照实际需要开启。设置好和启动nginx

### [#](http://www.liuwq.com/views/网站架构/nginx/nginx标准配置.html#nginx-做后端代理)nginx 做后端代理

#### [#](http://www.liuwq.com/views/网站架构/nginx/nginx标准配置.html#nginx-做后端处理配置)nginx 做后端处理配置

```yml
user  www www;
worker_processes  8;
worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;

error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

pid        logs/nginx.pid;
worker_rlimit_nofile  65535;


events {
    use epoll;
    worker_connections  65535;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #log_format short '[$time_local] | $status | $host | $request | $remote_addr | $http_user_agent | $http_referer | $http_cookie';
    log_format  short '$remote_addr - $remote_user [$time_local] "$request" ' '$status $body_bytes_sent "$http_referer" ' '"$http_user_agent" "$http_x_forwarded_for" $request_body $host "$http_cookie" ' '$upstream_response_time $request_time ';
    #access_log  logs/access.log  short;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server_tokens off;

    charset     UTF-8;
    server_names_hash_bucket_size       128;
    client_header_buffer_size           4k;
    large_client_header_buffers  4      32k;
    client_max_body_size 30m;
    client_body_buffer_size 128k;
    fastcgi_connect_timeout 300;
    fastcgi_read_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_buffer_size 64k;
    fastcgi_buffers   4 32k;
    fastcgi_busy_buffers_size 64k;
    fastcgi_temp_file_write_size 64k;
    ####open_file_cache
    open_file_cache max=65536  inactive=60s;
    open_file_cache_valid      80s;
    open_file_cache_min_uses   1;

    include ./vhost/*.conf;
}
```