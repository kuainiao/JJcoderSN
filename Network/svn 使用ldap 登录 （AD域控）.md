# svn 使用ldap 登录 （AD域控）

------

# [#](http://www.liuwq.com/views/自动化工具/svn-ldap.html#svn-使用ldap)SVN 使用LDAP

## [#](http://www.liuwq.com/views/自动化工具/svn-ldap.html#介绍sasl)介绍SASL

> 简单认证与安全层是卡内基梅隆大学出品的一个开源软件（准确的说，是John Gardiner Myers写的），它将通用的身份验证和加密功能添加到任何网络协议，从1.5版本以后，Subversion（这是SVN的全称……）服务端和客户端都知道如何使用这个库。以下情况将决定SASL是否可用：如果你打算自行编译SVN并使SASL可用，那么必须安装2.1或者更高的SASL版本，并且保证在编译期间，你安装的SASL能被编译进程检测到。如果你使用预先编译好的二进制包，你需要联系维护者确定SASL特性支持已经被编译进去了。SASL使用各种模块来对应不同的身份验证系统：Kerberos (GSSAPI), NTLM, One-Time-Passwords (OTP), DIGEST-MD5, LDAP, Secure-Remote-Password (SRP)等，某种验证机制是否可用，取决于你是否拥有这种机制对应的模块。

**SVN 从LDAP 获取用户名和密码主要是用通过SASL服务器**

## [#](http://www.liuwq.com/views/自动化工具/svn-ldap.html#安装与配置)安装与配置

环境要求： Centos7 及以上

### [#](http://www.liuwq.com/views/自动化工具/svn-ldap.html#安装相关组件)安装相关组件

```shell
yum install -y subversion cyrus-sasl cyrus-sasl-lib cyrus-sasl-plain
```

### [#](http://www.liuwq.com/views/自动化工具/svn-ldap.html#查看sasl版本和提供的验证模块)查看SASL版本和提供的验证模块

```shell
[root@localhost ~]# saslauthd -v
saslauthd 2.1.26
authentication mechanisms: getpwent kerberos5 pam rimap shadow ldap httpform #此处提供了对LDAP的支持。
```

### [#](http://www.liuwq.com/views/自动化工具/svn-ldap.html#修改sasl的用户验证方式为ldap)修改sasl的用户验证方式为ldap

```shell
cp /etc/sysconfig/saslauthd /etc/sysconfig/saslauthd.save
sed -i 's/MECH=pam/MECH=ldap/' /etc/sysconfig/saslauthd
```

### [#](http://www.liuwq.com/views/自动化工具/svn-ldap.html#修改sasl配置文件-etc-saslauthd-conf)修改sasl配置文件/etc/saslauthd.conf

```shell
ldap_servers: ldap://ldapserver   #填写你的服务器，域名或者IP均可，前提是你的DNS能正常工作  
ldap_default_domain:domain.com    #默认域名
ldap_search_base:DC=domain,dc=com #具体 OU信息
ldap_bind_dn:domain\user ## 域控可以访问的用户名
ldap_password:password
ldap_deref: never
ldap_restart: yes
ldap_scope: sub
ldap_use_sasl: no
ldap_start_tls: no
ldap_version: 3
ldap_auth_method: bind
ldap_mech: DIGEST-MD5
ldap_filter:sAMAccountName=%u  ## 获取英文名
ldap_password_attr:userPassword
ldap_timeout: 10
ldap_cache_ttl: 30
ldap_cache_mem: 32786
此处是填写的LDAP协议的各个要素。
```

### [#](http://www.liuwq.com/views/自动化工具/svn-ldap.html#重启sasl服务以应用配置文件并测试是否通过)重启sasl服务以应用配置文件并测试是否通过

```shell
systemctl restart saslauthd.service
testsaslauthd -u user -p 'password' #添加测试的用户名和密码
```

### [#](http://www.liuwq.com/views/自动化工具/svn-ldap.html#修改svn的sasl配置文件-etc-sasl-svn-conf)修改SVN的sasl配置文件/etc/sasl/svn.conf

```shell
vi /etc/sasl2/svn.conf
   pwcheck_method:saslauthd #用户验证方法
   mech_list: plain login  #用户验证信息怎么传输
```

### [#](http://www.liuwq.com/views/自动化工具/svn-ldap.html#修改版本库的配置)修改版本库的配置

```shell
 vim /yourrepository/conf/svnserve.conf  ## SVN 具体库地址 配置信息修改
 [general]
 anon-access = none
 auth-access = write
 #password-db = passwd #关闭passwd
 authz-db = authz #如果要对版本库进行权限控制，开启authz
 [sasl]
 use-sasl = true #开启sasl用户验证
```

### [#](http://www.liuwq.com/views/自动化工具/svn-ldap.html#重启svn-测试一下即可)重启SVN,测试一下即可

```shell
svnserve -d -r  /data/svn  # 具体仓库地址

[/path]
username = r
username = rw #没写就是没权限……用@符号表示用户组，用户组的创建就是
groupname = user1,user2,
```

> 测试通过 搞定收工 注意点： LDAP确认网络可以使用； 确认登录的LDAP用户可以获取正常的OU信息