# VDDOS 防CC工具

------



## Vddos

## 什么是Vddos保护?

> vDDoS Protection是提供反向代理服务器HTTP（S）协议的免费软件。它充当第7层防火墙过滤器并缓解DOS，DDOS，SYN洪水或HTTP洪水攻击，以保护您的网站

### 特点

- Reverse Proxy(反向代理)
- DDoS Protection (DDoS保护)
- Robot Mitigator(机器人攻击缓解器)
- HTTP challenge/response (HTTP类型攻击防御)
- reCaptcha Robot challenge （reCaptcha 机器人攻击）
- HTTP Denial of Service tools （HTTP请求拦截工具）
- Cookie challenge/response （Cookie 类型防御）
- Block/Allow Country Code You Want (Status 403) （准许哪些国家可以访问，返回状态码403）
- Limit the request connection coming from a single IP address (Status 503) （限制IP访问时间）
- CDN Support (CloudFlare, Incapsula...) CDN支持（CloudFlare，Incapsula ......）
- Whitelist for Botsearch (SEO Support, Allow Botsearch: Google, Alexa, Bing, Yahoo, Yandex, Facebook...) （SEO 搜索引擎白名单）

## 工作原理

> vDDoS Protection is Nginx bundled with module HTTP/2; GeoIP; Limit Req, Testcookie; reCaptcha processor... Working like CloudFlare, but vDDoS is software help you build your own System Firewall.

### [#](http://www.liuwq.com/views/安全/vddos.html#if-your-site-does-not-use-protection-service-accept-all-queries)If your site does not use protection service: (accept all queries)

![img](https://ws2.sinaimg.cn/large/006tNbRwly1fxgnacznz1j30zk0k0gop.jpg)

### [#](http://www.liuwq.com/views/安全/vddos.html#if-your-site-uses-protection-service-challenge-all-queries)If your site uses protection service: (challenge all queries)

- Human queries:

![img](https://ws3.sinaimg.cn/large/006tNbRwly1fxgnbv9yjyj30zk0k0dhv.jpg)

![img](https://ws1.sinaimg.cn/large/006tNbRwly1fxgnch541yj30zk0k0wgi.jpg)

- Bad Bots queries:

![img](https://ws3.sinaimg.cn/large/006tNbRwly1fxgne4lyhvj30zk0k0mz4.jpg)

![img](https://ws4.sinaimg.cn/large/006tNbRwly1fxgnf75ggnj30zk0k0q4w.jpg)

## [#](http://www.liuwq.com/views/安全/vddos.html#vddos-安装)vDDos 安装

- vDDoS Protection only support CentOS Server 5/6/7 x86_64 ([http://centos.org](https://centos.org/)) & CloudLinux Server 5/6/7 x86_64 ([http://cloudlinux.com](https://cloudlinux.com/))
- Please go to Homepage and download vDDoS Protection version working on your system (https://github.com/duy13/vDDoS-Protection)
- vDDoS Protection should be installed before installing other things (cPanel, VestaCP, LAMP, LEMP...)

```shell
yum -y install epel-release 
yum -y install curl wget gc gcc gcc-c++ pcre-devel zlib-devel make wget openssl-devel libxml2-devel libxslt-devel gd-devel perl-ExtUtils-Embed GeoIP-devel gperftools gperftools-devel libatomic_ops-devel perl-ExtUtils-Embed gcc automake autoconf apr-util-devel gc gcc gcc-c++ pcre-devel zlib-devel make wget openssl-devel libxml2-devel libxslt-devel gd-devel perl-ExtUtils-Embed GeoIP-devel gperftools gperftools-devel libatomic_ops-devel perl-ExtUtils-Embed 
```

1
2

Example: my system is CentOS 7 x86_64 install vDDoS 1.10.1 Version (only need wget a file vddos-1.10.1-centos7):

```bash
curl -L https://github.com/duy13/vDDoS-Protection/raw/master/vddos-1.10.1-centos7 -o /usr/bin/vddos
chmod 700 /usr/bin/vddos
/usr/bin/vddos help

/usr/bin/vddos setup
```

1
2
3
4
5

(This installation takes about 15 minutes or more)

### [#](http://www.liuwq.com/views/安全/vddos.html#vddos-使用介绍)**vDDoS 使用介绍**

```bash
   Welcome to vDDoS, a HTTP(S) DDoS Protection Reverse Proxy. Thank you for using!

   Command Line Usage:
   vddos setup             :installing vDDoS service for the first time into /vddos
   vddos start             :start vDDoS service
   vddos stop              :stop vDDoS service
   vddos restart           :restart vDDoS service
   vddos autostart         :auto-start vDDoS services on boot
   vddos attack            :create a DDoS attacks to HTTP target (in 30 min)
   vddos stopattack        :stop "vddos attack" command
   vddos help              :display this help

    Please sure download vDDoS source from: vddos.voduy.com
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

#### [#](http://www.liuwq.com/views/安全/vddos.html#如何加入自己的站点使用vddos)**如何加入自己的站点使用Vddos**

Please edit your website.conf file in /vddos/conf.d

Example Edit my website.conf:

```shell
# vim /vddos/conf.d/website.conf

# Website       Listen               Backend                  Cache Security SSL-Prikey   SSL-CRTkey
default         http://0.0.0.0:80    http://127.0.0.1:8080    no    200      no           no
your-domain.com http://0.0.0.0:80    http://127.0.0.1:8080    no    200      no           no
default         https://0.0.0.0:443  https://127.0.0.1:8443   no    307      /vddos/ssl/your-domain.com.pri /vddos/ssl/your-domain.com.crt
your-domain.com https://0.0.0.0:443  https://127.0.0.1:8443   no    307      /vddos/ssl/your-domain.com.pri /vddos/ssl/your-domain.com.crt
your-domain.com https://0.0.0.0:4343 https://103.28.249.200:443 yes click    /vddos/ssl/your-domain.com.pri /vddos/ssl/your-domain.com.crt


"your-domain.com" is my site on my Apache backend http://127.0.0.1:8080 want to be Protection by vDDoS
"default" is option for All remaining sites
/vddos/ssl/your-domain.com.pri is SSL Private key my website
/vddos/ssl/your-domain.com.crt is SSL Public key my website

Cache:
variable: no, yes (Sets proxy cache website on vDDoS)
Security:
variable: no, 307, 200, click, 5s, high, captcha (Sets a valid for Security Level Protection)
Note Security Level: no < 307 < 200 < click < 5s < high < captcha
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

Restart vDDoS after saving:

```text
# vddos restart
```

1

**Set Real IP traffic from Proxy or CDN:**

Please edit file cdn-ip.conf

```bash
# nano /vddos/conf.d/cdn-ip.conf

# Cloudflare
set_real_ip_from 103.21.244.0/22;
...
```

1
2
3
4
5

**Deny Country or IP:**

Please edit file blacklist-countrycode.conf

```bash
#nano /vddos/conf.d/blacklist-countrycode.conf

geoip_country /usr/share/GeoIP/GeoIP.dat;
map $geoip_country_code $allowed_country {
    default yes;
    US yes;
    CN no;

}
deny 1.1.1.1;
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

**Allow your IP Address do not need protection & challenge:**

Please edit file whitelist-botsearch.conf

```bash
# nano /vddos/conf.d/whitelist-botsearch.conf

#Alexa Bot IP Addresses
204.236.235.245; 75.101.186.145;
...
```

1
2
3
4
5

**Use Mode reCaptcha:**

Please edit file recaptcha-secretkey.conf & recaptcha-sitekey.conf

```bash
# nano /vddos/conf.d/recaptcha-sitekey.conf
# Website       reCaptcha-sitekey (View KEY in https://www.google.com/recaptcha/admin#list)
your-domain.com     6Lcr6QkUAAAAAxxxxxxxxxxxxxxxxxxxxxxxxxxx

...

# nano /vddos/conf.d/recaptcha-secretkey.conf
DEBUG=False
RE_SECRETS = { 'your-domain.com': '6Lcr6QkUAAAAxxxxxxxxxxxxxxxxxxxxxxxxxxx',
               'your-domain.org': '6LcKngoUAAAAxxxxxxxxxxxxxxxxxxxxxxxxxxx' }
```

(Go to https://www.google.com/recaptcha/admin#list and get your key for vDDoS)

**Recommend?**

-Recommend You use vDDoS with CloudFlare Free/Pro (hide your website real IP Address)

(CloudFlare is Mitigate Firewall Layer 3-4)

(vDDoS Protection is Mitigate Firewall Layer 7)

-Download vDDoS Protection packages from vDDoS HomePages

-Use this soft only for testing or demo attack!

**vDDoS Protection is Simple like that!**