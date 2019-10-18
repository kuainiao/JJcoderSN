# [CGI与FastCGI是什么](http://imhuchao.com/517.html)

## 当我们在谈到cgi的时候，我们在讨论什么

 最早的Web服务器简单地响应浏览器发来的HTTP请求，并将存储在服务器上的HTML文件返回给浏览器，也就是静态html。事物总是不 断发展，网站也越来越复杂，所以出现动态技术。但是服务器并不能直接运行 php，asp这样的文件，自己不能做，外包给别人吧，但是要与第三做个约定，我给你什么，然后你给我什么，就是握把请求参数发送给你，然后我接收你的处 理结果给客户端。那这个约定就是 common gateway interface，简称cgi。这个协议可以用vb，c，php，python 来实现。cgi只是接口协议，根本不是什么语言。下面图可以看到流程

[![222132422994681](http://imhuchao.com/wp-content/uploads/2015/12/222132422994681-300x194.gif)](http://imhuchao.com/wp-content/uploads/2015/12/222132422994681.gif)

## WEB服务器与cgi程序交互

WEB服务器将根据CGI程序的类型决定数据向CGI程序的传送方式，一般来讲是通过标准输入/输出流和环境变量来与CGI程序间传递数据。 如下图所示：

[![222140260037310](http://imhuchao.com/wp-content/uploads/2015/12/222140260037310-300x171.gif)](http://imhuchao.com/wp-content/uploads/2015/12/222140260037310.gif)

CGI程序通过标准输入（STDIN）和标准输出（STDOUT）来进行输入输出。此外CGI程序还通过环境变量来得到输入，操作系统提供了许 多环境变量，它们定义了程序的执行环境，应用程序可以存取它们。Web服务器和CGI接口又另外设置了一些环境变量，用来向CGI程序传递一些重要的参 数。CGI的GET方法还通过环境变量QUERY-STRING向CGI程序传递Form中的数据。 下面是一些常用的CGI环境变量：

| 变量名          | 描述                                                         |
| :-------------- | :----------------------------------------------------------- |
| CONTENT_TYPE    | 这个环境变量的值指示所传递来的信息的MIME类型。目前，环境变量CONTENT_TYPE一般都是：application/x-www-form-urlencoded,他表示数据来自于HTML表单。 |
| CONTENT_LENGTH  | 如果服务器与CGI程序信息的传递方式是POST，这个环境变量即使从标准输入STDIN中可以读到的有效数据的字节数。这个环境变量在读取所输入的数据时必须使用。 |
| HTTP_COOKIE     | 客户机内的 COOKIE 内容。                                     |
| HTTP_USER_AGENT | 提供包含了版本数或其他专有数据的客户浏览器信息。             |
| PATH_INFO       | 这个环境变量的值表示紧接在CGI程序名之后的其他路径信息。它常常作为CGI程序的参数出现。 |
| QUERY_STRING    | 如果服务器与CGI程序信息的传递方式是GET，这个环境变量的值即使所传递的信息。这个信息经跟在CGI程序名的后面，两者中间用一个问号’?’分隔。 |
| REMOTE_ADDR     | 这个环境变量的值是发送请求的客户机的IP地址，例如上面的192.168.1.67。这个值总是存在的。而且它是Web客户机需要提供给Web服务器的唯一标识，可以在CGI程序中用它来区分不同的Web客户机。 |
| REMOTE_HOST     | 这个环境变量的值包含发送CGI请求的客户机的主机名。如果不支持你想查询，则无需定义此环境变量。 |
| REQUEST_METHOD  | 提供脚本被调用的方法。对于使用 HTTP/1.0 协议的脚本，仅 GET 和 POST 有意义。 |
| SCRIPT_FILENAME | CGI脚本的完整路径                                            |
| SCRIPT_NAME     | CGI脚本的的名称                                              |
| SERVER_NAME     | 这是你的 WEB 服务器的主机名、别名或IP地址。                  |
| SERVER_SOFTWARE | 这个环境变量的值包含了调用CGI程序的HTTP服务器的名称和版本号。例如，上面的值为Apache/2.2.14(Unix) |

## 一个例子

说了这么多，你也许感觉烦了，写个小程序可能会更好的理解。 lighttpd + CGI，用c语言写cgi程序 。

lighttpd 配置 cgi， 打开cgi.conf， cgi.assign = (“.cgi” => “”) 设置 cgi 模块的扩展名和解释器。就本语句而言，表示cgi模块的扩展名是“.cgi”且该 cgi 模块不需要特别的解释器来执行。因为用c来写的是可执行文件。

下面是 test.c 代码：

```
#include "stdio.h"
#include "stdlib.h"
#include <string.h>

int mian()
{
     char *data;
     data = getenv("QUERY_STRING");
     puts(data);
     printf("Hello cgi!");

     return 0;
}
```

生成可执行文件放到你的服务器配置程序的目录下

```
gcc test.c -o test.cgi
```

访问：http://localhost/test.cgi?a=b&c=d 结果为：

```
a=b&c=d
Hello cgi!
```

通过环境变量”QUERY_STRING” 获取get 方式提交的内容，如果想获取post 提交的内容可以通过getenv(“CONTENT-LENGTH”)，Web服务器在调用使用POST方法的CGI程序时设置此环境变量，它的文本值表示Web服务器传送给CGI程序的输入中的字符数目。上面例子展示了cgi 程序与web服务器的交互。

## cgi 与 fastcgi

CGI工作原理：每当客户请求CGI的时候，WEB服务器就请求操作系统生成一个新的CGI解释器进程(如php-cgi.exe)，CGI 的一个进程则处理完一个请求后退出，下一个请求来时再创建新进程。当然，这样在访问量很少没有并发的情况也行。可是当访问量增大，并发存在，这种方式就不 适合了。于是就有了fastcgi。

FastCGI像是一个常驻(long-live)型的CGI，它可以一直执行着，只要激活后，不会每次都要花费时间去fork一次（这是CGI最为人诟病的fork-and-execute 模式）。

一般情况下，FastCGI的整个工作流程是这样的：

1. Web Server启动时载入FastCGI进程管理器（IIS ISAPI或Apache Module)
2. FastCGI进程管理器自身初始化，启动多个CGI解释器进程(可见多个php-cgi)并等待来自Web Server的连接。
3. 当客户端请求到达Web Server时，FastCGI进程管理器选择并连接到一个CGI解释器。 Web server将CGI环境变量和标准输入发送到FastCGI子进程php-cgi。
4.  FastCGI 子进程完成处理后将标准输出和错误信息从同一连接返回Web Server。当FastCGI子进程关闭连接时， 请求便告处理完成。FastCGI子进程接着等待并处理来自FastCGI进程管理器(运行在Web Server中)的下一个连接。 在CGI模式中，php-cgi在此便退出了。

**PHP-FPM与Spawn-FCGI**

Spawn-FCGI是一个通用的FastCGI管理服务器，它是lighttpd中的一部份，很多人都用Lighttpd的Spawn-FCGI进行FastCGI模式下的管理工作。 但是有缺点，于是PHP-fpm就是针对于PHP的，Fastcgi的一种实现，他负责管理一个进程池，来处理来自Web服务器的请求。目前，PHP-fpm是内置于PHP的。

## apache 模块方式

记得曾在xp 配置 apache + php ，会在apache 配置下面一段：

```
LoadModule php5_module C:/php/php5apache2_2.dll
```

当PHP需要在Apache服务器下运行时，一般来说，它可以模块的形式集成， 此时模块的作用是接收Apache传递过来的PHP文件请求，并处理这些请求， 然后将处理后的结果返回给Apache。如果我们在Apache启动前在其配置文件中配置好了PHP模块， PHP模块通过注册apache2的ap_hook_post_config挂钩，在Apache启动的时候启动此模块以接受PHP文件的请求。

Apache 的Hook机制是指：Apache 允许模块(包括内部模块和外部模块，例如mod_php5.so，mod_perl.so等)将自定义的函数注入到请求处理循环中。 换句话说，模块可以在Apache的任何一个处理阶段中挂接(Hook)上自己的处理函数，从而参与Apache的请求处理过程。 mod_php5.so/ php5apache2.dll就是将所包含的自定义函数，通过Hook机制注入到Apache中，在Apache处理流程的各个阶段负责处理php请 求。

有人测试nginx+PHP-FPM在高并发情况下可能会达到Apache+mod_php5的5~10倍，现在nginx+PHP-FPM使用的人越来越多。