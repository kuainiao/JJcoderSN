# grafana ldap 集成域控登录

------



## [#](http://www.liuwq.com/views/监控/grafana-ldap.html#grafana授权公司内部邮箱登录-ldap配置)grafana授权公司内部邮箱登录 ldap配置

### [#](http://www.liuwq.com/views/监控/grafana-ldap.html#修改配置)修改配置

```shell
vim /etc/grafana/grafana.ini    （默认配置是这个）

修改ldap相关配置如下
[auth.ldap]
enabled = true   ## 开启LDAP认证
config_file = /etc/grafana/ldap.toml   ## 加载LDAP 配置文件    
allow_sign_up = true            ## 开启用户登录后，创建到内置用户
```

```yml
vim  /etc/grafana/ldap.toml
 ## 如下是 相关配置修改 ，请对应默认配置进行修改
verbose_logging = true       ## 这个默认配置里面没有请自行添加
[[servers]]
host = XXXX   //公司内部ldaphost
port = XXXX       //公司内部ldapport
use_ssl = false
ssl_skip_verify = false

bind_dn = "CN=XXXX,OU=XXXX,OU=XXXX,DC=XXXX,DC=com"   ## 这个需要咨询域控管理员，填写具体的账号密码
bind_password = XXXX
search_filter = "(sAMAccountName=%s)"
search_base_dns = ["OU=XXXX,OU=XXXX,DC=XXXX,DC=XXXX"]
[servers.attributes]
name = "givenName"
surname = "sn"
username = "sAMAccountName"
member_of = "memberOf"
email =  "mail"

[[servers.group_mappings]]
group_dn = "CN=XXXX,OU=User Group,OU=XXXX,DC=XXXX,DC=com"
org_role = "Admin"

[[servers.group_mappings]]
group_dn = "*"
org_role = "Viewer"
```

### [#](http://www.liuwq.com/views/监控/grafana-ldap.html#重启服务)重启服务

```
sudo service grafana-server restart
```