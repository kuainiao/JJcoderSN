# SSL 证书数据传输

------

*kame* *11/8/2016*  11  *nginx openssl SSL证书*

**使用openssl制作证书**

## [#](http://www.liuwq.com/views/网站架构/SSL数据传输nginx.html#_1、服务器单向验证)1、服务器单向验证

创建并进入sslkey存放目录

```shell
mkdir /opt/nginx/sslkey
cd /opt/nginx/sslkey
```

1
2

### [#](http://www.liuwq.com/views/网站架构/SSL数据传输nginx.html#生成rsa密钥)生成RSA密钥

```
openssl genrsa -out key.pem 2048
```

### [#](http://www.liuwq.com/views/网站架构/SSL数据传输nginx.html#生成一个证书请求)生成一个证书请求

```shell
openssl req -new -key key.pem -out cert.csr`

#//会提示输入省份、城市、域名信息等，重要的是，email 一定要是你的域名后缀的你可以拿着这个文件去数字证书颁发机构（即CA）申请一个数字证书。
CA会给你一个新的文件cacert.pem，那才是你的数字证书。
```

1
2
3
4

**如果是自己做测试，就可以用下面这个命令来生成证书：**

```
openssl req -new -x509 -nodes -out server.crt -keyout server.key
```

### [#](http://www.liuwq.com/views/网站架构/SSL数据传输nginx.html#修改-nginx-配置)修改 nginx 配置

```yml
# HTTPS server  
server {  
  listen 443;  
  server_name localhost;  
  ##开启ssl   
  ssl on;  
  ##服务器证书
  ssl_certificate /opt/nginx/sslkey/server.crt;
  ##服务器证书公钥  
  ssl_certificate_key /opt/nginx/sslkey/server.key;  
  ##链接超时设置
  ssl_session_timeout 5m;  
  ##传输信息通道
  ssl_protocols SSLv2 SSLv3 TLSv1;
  ##传输加密方式  
  ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
  ##  
  ssl_prefer_server_ciphers on;  

  location / {      
          root /home/workspace/;      
          index index.asp index.aspx;        
      }  
  }
```

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24

配置好后，重启nginx，采用 `https`打开网站，浏览器会提示证书错误，点击继续浏览即可。

## [#](http://www.liuwq.com/views/网站架构/SSL数据传输nginx.html#_2、服务器-客户端双向验证)2、服务器-客户端双向验证

在nginx 目录下建立ca文件夹，进入ca。

```shell
# mkdir newcerts private conf server。
```

1

其中`newcerts`子目录将存放CA签署（颁发）过的数字证书（证书备份目录）。而`private`目录用于存放CA的私钥。目录conf只是用于存放一些简化参数

用的配置文件，server存放服务器证书文件。

### [#](http://www.liuwq.com/views/网站架构/SSL数据传输nginx.html#在conf目录创建文件openssl-conf配置文件，内容如下：)在conf目录创建文件openssl.conf配置文件，内容如下：

```yml
[ ca ]  
default_ca      = foo                  # The default ca section  

[ foo ]  
dir            = /opt/nginx/ca        # top dir  
database      = /opt/nginx/ca/index.txt          # index file.  
new_certs_dir  = /opt/nginx/ca/newcerts          # new certs dir  

certificate    = /opt/nginx/ca/private/ca.crt        # The CA cert  
serial        = /opt/nginx/ca/serial            # serial no file  
private_key    = /opt/nginx/ca/private/ca.key  # CA private key  
RANDFILE      =/opt/nginx/ca/private/.rand      # random number file  

default_days  = 365                    # how long to certify for  
default_crl_days= 30                    # how long before next CRL  
default_md    = md5                    # message digest method to use  
unique_subject = no                      # Set to 'no' to allow creation of  
                                        # several ctificates with same subject.  
policy        = policy_any              # default policy  

[ policy_any ]  
countryName = match  
stateOrProvinceName = match  
organizationName = match  
organizationalUnitName = match  
localityName            = optional  
commonName              = supplied  
emailAddress            = optional
```

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28

### [#](http://www.liuwq.com/views/网站架构/SSL数据传输nginx.html#使用脚本创建证书)使用脚本创建证书

下面的几个脚本都放在`/nginx/ca/`目录下。

#### [#](http://www.liuwq.com/views/网站架构/SSL数据传输nginx.html#创建一个新的ca根证书)创建一个新的CA根证书

```
vim new_ca.sh
#!/bin/sh  
# Generate the key.  
openssl genrsa -out private/ca.key  
# Generate a certificate request.  
openssl req -new -key private/ca.key -out private/ca.csr  
# Self signing key is bad... this could work with a third party signed key... registeryfly has them on for $16 but I'm too cheap lazy to get one on a lark.  
# I'm also not 100% sure if any old certificate will work or if you have to buy a special one that you can sign with. I could investigate further but since this  
# service will never see the light of an unencrypted Internet see the cheap and lazy remark.  
# So self sign our root key.  
openssl x509 -req -days 365 -in private/ca.csr -signkey private/ca.key -out private/ca.crt  
# Setup the first serial number for our keys... can be any 4 digit hex string... not sure if there are broader bounds but everything I've seen uses 4 digits.  
echo FACE > serial  
# Create the CA's key database.  
touch index.txt  
# Create a Certificate Revocation list for removing 'user certificates.'  
openssl ca -gencrl -out /opt/nginx/ca/private/ca.crl -crldays 7 -config "/opt/nginx/ca/conf/openssl.conf"
```

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17

执行 `sh new_ca.sh`生成新的CA证书。

#### [#](http://www.liuwq.com/views/网站架构/SSL数据传输nginx.html#生成服务器证书的脚本)生成服务器证书的脚本

```
new_server.sh
# Create us a key. Don't bother putting a password on it since you will need it to start apache. If you have a better work around I'd love to hear it.  
openssl genrsa -out server/server.key  
# Take our key and create a Certificate Signing Request for it.  
openssl req -new -key server/server.key -out server/server.csr  
# Sign this bastard key with our bastard CA key.  
openssl ca -in server/server.csr -cert private/ca.crt -keyfile private/ca.key -out server/server.crt -config "/opt/nginx/ca/conf/openssl.conf"
```

1
2
3
4
5
6

执行 `sh new_server.sh`生成新服务器的证书

#### [#](http://www.liuwq.com/views/网站架构/SSL数据传输nginx.html#配置-nginx的ssl支持)配置 nginx的ssl支持

```yml
#user  www-nginx;  
worker_processes  1;  

#error_log  logs/error.log;  
#error_log  logs/error.log  notice;  
#error_log  logs/error.log  info;  

#pid        logs/nginx.pid;  


events {  
    worker_connections  1024;  
}  
http {  
    include      mime.types;  
    default_type  application/octet-stream;  
    sendfile        on;  
    keepalive_timeout  65;  
    #gzip  on;  

    # HTTPS server  
    #  
    server {  
        listen      443;  
        server_name  localhost;  
        ssi on;  
        ssi_silent_errors on;  
        ssi_types text/shtml;  

        ssl                  on;  
        ssl_certificate      /opt/nginx/ca/server/server.crt;  
        ssl_certificate_key  /opt/nginx/ca/server/server.key;  
        ssl_client_certificate /opt/nginx/ca/private/ca.crt;  

        ssl_session_timeout  5m;  
        ssl_verify_client on;  #开户客户端证书验证  

        ssl_protocols  SSLv2 SSLv3 TLSv1;  
        ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;  
        ssl_prefer_server_ciphers  on;  

        location / {      
        root /home/workspace/;      
        index index.asp index.aspx;        
    }  
    }  
}
```

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47

启动`nginx`,等待客户连接，如果此时连接服务器，将提示`400 Bad request certification`的错误，故还需要生成客户端证书。

#### [#](http://www.liuwq.com/views/网站架构/SSL数据传输nginx.html#生成客户端证书)生成客户端证书

```
vim new_user.sh
#!/bin/sh  
# The base of where our SSL stuff lives.  
base="/opt/nginx/ca"  
# Were we would like to store keys... in this case we take the username given to us and store everything there.  
mkdir -p $base/users/  

# Let's create us a key for this user... yeah not sure why people want to use DES3 but at least let's make us a nice big key.  
openssl genrsa -des3 -out $base/users/client.key 1024  
# Create a Certificate Signing Request for said key.  
openssl req -new -key $base/users/client.key -out $base/users/client.csr  
# Sign the key with our CA's key and cert and create the user's certificate out of it.  
openssl ca -in $base/users/client.csr -cert $base/private/ca.crt -keyfile $base/private/ca.key -out $base/users/client.crt -config "/opt/nginx/ca/conf/openssl.conf"  

# This is the tricky bit... convert the certificate into a form that most browsers will understand PKCS12 to be specific.  
# The export password is the password used for the browser to extract the bits it needs and insert the key into the user's keychain.  
# Take the same precaution with the export password that would take with any other password based authentication scheme.  
openssl pkcs12 -export -clcerts -in $base/users/client.crt -inkey $base/users/client.key -out $base/users/client.p12
```

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17

执行 `sh new_user.sh`生成一个 `client`证书。

按照提示一步一步来，这里要注意的是客户证书的几个项目要和根证书匹配。

也就是前面配置的:

```yml
countryName = match
stateOrProvinceName = match
organizationName = match
organizationalUnitName = match
```

1
2
3
4

不一致的话无法生成最后的客户证书，证书生成后，客户端导入证书浏览器，即可打开网站。

**注意事项：**

1. 制作证书时会提示输入密码，服务器证书和客户端证书密码可以不相同。
2. 服务器证书和客户端证书制作时提示输入省份、城市、域名信息等，需保持一致。
3. `Nginx`默认未开启SSI，上面配置已开启。
4. `Nginx`不能自启动，需要如下配置：

```shell
cd /etc/init.d
sudo touch nginx
sudo chmod +x nginx
```

1
2
3

nginx内容：

```shell
#! /bin/sh  
#  
### BEGIN INIT INFO  
# Provides:          nginx  
# Required-Start:    $syslog $local_fs $remote_fs  
# Required-Stop:    $syslog $local_fs $remote_fs  
# Should-Start:      dbus avahi  
# Should-Stop:      dbus avahi  
# Default-Start:    2 3 4 5  
# Default-Stop:      1  
# Short-Description: Nginx Server  
# Description:      Nginx  
### END INIT INFO  

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/nginx/sbin  
DAEMON=/opt/nginx/sbin/nginx  
NAME=nginx  
DESC="Nginx Server"  
PID_FILE=/opt/nginx/logs/nginx.pid  

test -x $DAEMON || exit 0  

RUN=yes  
#RUN_AS_USER=root  

#DAEMON_OPTS="-a $RUN_AS_USER"  

set -e  

case "$1" in  
  start)  
    echo -n "Starting $DESC: "  
    start-stop-daemon --start --quiet --pidfile $PID_FILE \  
        --exec $DAEMON  
    echo "$NAME."  
    ;;  
  stop)  
    echo -n "Stopping $DESC: "  
    start-stop-daemon --stop --oknodo --quiet --pidfile $PID_FILE \  
        --exec $DAEMON  
    echo "$NAME."  
    ;;  
  force-reload)  
    # check whether $DAEMON is running. If so, restart  
    start-stop-daemon --stop --test --quiet --pidfile \  
        $PID_FILE --exec $DAEMON \  
    && $0 restart \  
    || exit 0  
    ;;  
  restart)  
    echo -n "Restarting $DESC: "  
    start-stop-daemon --stop --oknodo --quiet --pidfile \  
        $PID_FILE --exec $DAEMON  
    sleep 1  
    start-stop-daemon --start --quiet --pidfile \  
        $PID_FILE --exec $DAEMON  
    echo "$NAME."  
    ;;  
  status)  
    if [ -s $PID_FILE ]; then  
            RUNNING=$(cat $PID_FILE)  
            if [ -d /proc/$RUNNING ]; then  
                if [ $(readlink /proc/$RUNNING/exe) = $DAEMON ]; then  
                    echo "$NAME is running."  
                    exit 0  
                fi  
            fi  

            # No such PID, or executables don't match  
            echo "$NAME is not running, but pidfile existed."  
            rm $PID_FILE  
            exit 1  
        else  
            rm -f $PID_FILE  
            echo "$NAME not running."  
            exit 1  
        fi  
    ;;  
  *)  
    N=/etc/init.d/$NAME  
    echo "Usage: $N {start|stop|restart|force-reload}" >&2  
    exit 1  
    ;;  
esac  

exit 0
```

设置自启动：

```shell
sudo chkconfig --list nginx
sudo chkconfig nginx on
```