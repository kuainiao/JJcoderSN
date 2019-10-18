# GitLab ldap集成 配置

------

# Gitlab 集成ldap （AD域控）

> 配置方法如下：

## 第一步：修改配置文件

```yml
vim  /etc/gitlab/gitlab.rb  ##位置根据实际情况而定

gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
   main: # 'main' is the GitLab 'provider ID' of this LDAP server
     label: 'LDAP'
     host: '10.182.1.10'  #域账号管理服务器IP
     port: 389
     uid: 'sAMAccountName'
     bind_dn: 'cn=admin,ou=应用帐号,dc=ad,dc=mycompany,dc=com,dc=cn' #域账号管理员DN
     password: '123456'#域账号管理员密码
    encryption: 'plain' # "start_tls" or "simple_tls" or "plain"
     verify_certificates: true
     ca_file: ''
     ssl_version: ''
     active_directory: true
     allow_username_or_email_login: true
     block_auto_created_users: false
     base: 'dc=ad,dc=mycompany,dc=com,dc=cn'
     user_filter: ''
     attributes:
       username: ['uid', 'userid', 'sAMAccountName']
       email:    ['mail', 'email', 'userPrincipalName']
       name:       'cn'
       first_name: 'givenName'
       last_name:  'sn'
#     ## EE only
#     group_base: ''
#     admin_group: ''
#     sync_ssh_keys: false
#
#   secondary: # 'secondary' is the GitLab 'provider ID' of second LDAP server
#     label: 'LDAP'
#     host: '_your_ldap_server'
#     port: 389
#     uid: 'sAMAccountName'
#     bind_dn: '_the_full_dn_of_the_user_you_will_bind_with'
#     password: '_the_password_of_the_bind_user'
#     encryption: 'plain' # "start_tls" or "simple_tls" or "plain"
#     verify_certificates: true
#     ca_file: ''
#     ssl_version: ''
#     active_directory: true
#     allow_username_or_email_login: false
#     block_auto_created_users: false
#     base: ''
#     user_filter: ''
#     attributes:
#       username: ['uid', 'userid', 'sAMAccountName']
#       email:    ['mail', 'email', 'userPrincipalName']
#       name:       'cn'
#       first_name: 'givenName'
#       last_name:  'sn'
#     ## EE only
#     group_base: ''
#     admin_group: ''
#     sync_ssh_keys: false
 EOS   ## 注意别忘了写这个
```



## 第二步: 执行`sudo gitlab-ctl reconfigure`命令重新加载GitLab配置。

## 第三步：重启`sudo gitlab-ctl restart`