# zabbix 集成 LDAP

------



# [#](http://www.liuwq.com/views/监控/zabbix-ldap.html#zabbix-配置)zabbix 配置

![zabbix](http://img.liuwenqi.com/blog/2019-07-24-013445.jpg) ![zabbix ldap](http://img.liuwenqi.com/blog/2019-07-24-013515.jpg)

```shell
LDAP host：访问DC的地址。格式：ldap://ip地址
Port：默认389
Base DN: dc=tencent,dc=com,也就是域名(tencent.com)
Search attribute: uid，属性值，网上有填sAMAccountName。
Bind DN： cn=Admin, ou=People, dc=tencent, dc=com。 cn就是在DC中创建的LDAPuser用户， ou就是LDAPuser属于哪个ou，dc=tencent和dc=com不在解释。
Bind password：xxxx ，改密码为LDAPuser用户的密码
Login：Admin
User password：在DC中创建Admin用户的密码
>  这里的Login 是当前用户，如果是admin  需要在AD域控中增减用户名
点击"Test"。如果没有报什么错误，就可以点击"Save"。现在ZABBIX的LDAP认证方式就已经配置完成了。
```

> 虽然 zabbix 的ldap 认证成功了，但是不能自动创建用户，需要根据在zabbix 数据库中创建对应的用户

- 插入用户的SQL如下：

```
insert into users(userid,name,alias) values ('%s','%s','%s');" % (n,$name,$name)
```

- 需要用到组管理的话，可以组的映射信息

插入关联用户组的SQL：

```shell
"insert into users_groups (id,usrgrpid,userid) values ('%s','%s','%s');" % (n,grouplist[group_name],userlist[name])
users           用户表
users_groups    用户组的表
usrgrp          用户-组，映射关系表
```

- ldap查询命令，获取用户的用户名，和组名

> 先从ldap服务器把用户数据导入文件

```shell
ldapsearch -x -LLL   -D "CN=张三,OU=运维技术部,OU=信息技术中心,OU=神秘公司,DC=corp,DC=shenmi,DC=com,DC=cn"   -b "OU=运维技术部,OU=信息技术中心,OU=神秘公司,DC=corp,DC=shenmi,DC=com,DC=cn"   givenName  -H ldap://10.12.3.30:389 -w asdfasdfa sAMAccountName | egrep -v '^$|givenName'
```

## [#](http://www.liuwq.com/views/监控/zabbix-ldap.html#python导入ldap用户)python导入ldap用户

环境python 2.6 脚本如下：

```python
 cat insert_sql.py

#!/usr/bin/env python
# -*- coding:utf-8 -*-

import pymysql
import commands
import re
import base64
import sys

# 避免中文乱码
reload(sys)
sys.setdefaultencoding('utf-8')

ldap_list='/usr/local/zabbix/sh/ldap.list'

# 先从ldap服务器把用户数据导入文件
ldap_users=commands.getoutput("ldapsearch -x -LLL -H ldap://1.1.1.1 -b dc=weimob,dc=com givenName|sed '1,12'd|sed '/^$/d'|egrep -v 'ou=Group|ou=machines'> %s" % ldap_list)

# 因为zabbix的表没有自增id，所以每次操作都会记录下id，并递增
idfile = '/usr/local/zabbix/sh/userid'

# 处理元数据，把文件里的每行数据转化成方便使用的格式
def get_item(fobj):
    item = ['', '', '']
    for no,line in enumerate(fobj):
        #print no,line
        slot = no % 2
        item[slot] = line.rstrip()
        if slot == 1:
            yield item

def insert_user():
    conn = pymysql.connect(host='2.2.2.2', port=3306, user='zabbix', passwd='zabbix', db='zabbix', charset='utf8')
    cur = conn.cursor()
    fs = open(idfile,'r')
    n = int(fs.read())
    fs.close()
    with open(ldap_list) as fobj:
        for item in get_item(fobj):
            n += 1
            try:
                s='{0}{1}{2}'.format(*item)
                l = re.search('cn=(.*),ou.*:: (.*)',s)
                name = base64.b64decode(l.group(2))
                alias = l.group(1)
                search = cur.execute("""select * from users where alias = %s""", (alias, ))
                if not search:
                    sql = "insert into users(userid,name,alias) values ('%s','%s','%s');" % (n,name,alias)
                    insert = cur.execute(sql)
                    if sql:
                        print "User %s Add Succed!" % alias
                        print sql
            except AttributeError as e:
                print e
    conn.commit() #这步很必要，不然插入的数据不生效
    cur.close()
    conn.close()
    fe = open(idfile,'w')
    fe.write(str(n))
    fe.close()

if __name__ == '__main__':
    insert_user(
```

