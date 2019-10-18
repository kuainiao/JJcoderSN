# htpasswd 密码认证工具

------

# [#](http://www.liuwq.com/views/linux基础/htpassword.html#htpasswd命令网络服务器)htpasswd命令网络服务器

> htpasswd命令是Apache的Web服务器内置工具，用于创建和更新储存用户名、域和用户基本认证的密码文件。

语法 `htpasswd(选项)(参数)` 选项

```yml
-c：创建一个加密文件；
-n：不更新加密文件，只将加密后的用户名密码显示在屏幕上；
-m：默认采用MD5算法对密码进行加密；
-d：采用CRYPT算法对密码进行加密；
-p：不对密码进行进行加密，即明文密码；
-s：采用SHA算法对密码进行加密；
-b：在命令行中一并输入用户名和密码而不是根据提示输入密码；
-D：删除指定的用户。
```

## [#](http://www.liuwq.com/views/linux基础/htpassword.html#实例)实例

### [#](http://www.liuwq.com/views/linux基础/htpassword.html#利用htpasswd命令添加用户)利用htpasswd命令添加用户

```
 htpasswd -bc .passwd www.linuxde.net php
在bin目录下生成一个.passwd文件，用户名www.linuxde.net，密码：php，默认采用MD5加密方式。
```

### [#](http://www.liuwq.com/views/linux基础/htpassword.html#在原有密码文件中增加下一个用户)在原有密码文件中增加下一个用户

```
htpasswd -b .passwd Jack 123456
去掉-c选项，即可在第一个用户之后添加第二个用户，依此类推。
```

### [#](http://www.liuwq.com/views/linux基础/htpassword.html#不更新密码文件，只显示加密后的用户名和密码)不更新密码文件，只显示加密后的用户名和密码

```
htpasswd -nb Jack 123456
不更新.passwd文件，只在屏幕上输出用户名和经过加密后的密码。
```

### [#](http://www.liuwq.com/views/linux基础/htpassword.html#利用htpasswd命令删除用户名和密码)利用htpasswd命令删除用户名和密码

```
 htpasswd -D .passwd Jack
```

### [#](http://www.liuwq.com/views/linux基础/htpassword.html#利用htpasswd命令修改密码)利用htpasswd命令修改密码

```
htpasswd -D .passwd Jack htpasswd -b .passwd Jack 123456
```

## [#](http://www.liuwq.com/views/linux基础/htpassword.html#nginx-server中添加配置)nginx server中添加配置

```
     auth_basic "Restricted Content";
     auth_basic_user_file /etc/nginx/.htpasswd;
```