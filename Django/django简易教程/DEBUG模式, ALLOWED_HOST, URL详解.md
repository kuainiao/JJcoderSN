## DEBUG模式
1.如果开启了Debug模式,那么下次在修改代码之后,按下`ctrl+s`,django会给我们自动重启项目.  
2.如果开启debug模式,以后项目中出现bug,那么在终端和浏览器上都会有代码的错误提示.  
3.如果debug设置为False,那么必须要设置ALLOWED_HOSTS.如果不设置会报如下错误
```djangotemplate
(python_django) ➜  myweb python3 manage.py runserver
CommandError: You must set settings.ALLOWED_HOSTS if DEBUG is False.

```

## ALLOWED_HOST
这个变量是用来设置以后别人只能通过这个变量中的ip或者域名来访问.

## URL组成部分详解：
URL是Uniform Resource Locator的简写，统一资源定位符。

一个URL由以下几部分组成：
```djangotemplate
scheme://host:port/path/?query-string=xxx#anchor
```
**`scheme`**：代表的是访问的协议，一般为http或者https以及ftp等。  
**`host`**：主机名，域名，比如www.baidu.com。  
**`port`**：端口号。当你访问一个网站的时候，浏览器默认使用80端口。  
**`path`**：查找路径。比如：www.jianshu.com/trending/now，后面的trending/now就是path。  
**`query-string`**：查询字符串，比如：www.baidu.com/s?wd=python，后面的wd=python就是查询字符串。  
**`ancho`r**：锚点，后台一般不用管，前端用来做页面定位的。  
注意：URL中的所有字符都是ASCII字符集，如果出现非ASCII字符，比如中文，浏览器会进行编码再进行传输。  