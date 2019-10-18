SQL注入
所谓SQL注入，就是通过把SQL命令插入到表单中或页面请求的查询字符串中，最终达到欺骗服务器执行恶意的SQL命令。具体来说，它是利用现有应用程序，将（恶意的）SQL命令注入到后台数据库引擎执行的能力，它可以通过在Web表单中输入（恶意）SQL语句得到一个存在安全漏洞的网站上的数据库，而不是按照设计者意图去执行SQL语句。 比如先前的很多影视网站泄露VIP会员密码大多就是通过WEB表单递交查询字符暴出的。

场景：
比如现在数据库中有一个front_user表，表结构如下：

class User(models.Model):
    telephone = models.CharField(max_length=11)
    username = models.CharField(max_length=100)
    password = models.CharField(max_length=100)
然后我们使用原生sql语句实现以下需求：

实现一个根据用户id获取用户详情的视图。示例代码如下：

     def index(request):
         user_id = request.GET.get('user_id')
         cursor = connection.cursor()
         cursor.execute("select id,username from front_user where id=%s" % user_id)
         rows = cursor.fetchall()
         for row in rows:
             print(row)
         return HttpResponse('success')
这样表面上看起来没有问题。但是如果用户传的user_id是等于1 or 1=1，那么以上拼接后的sql语句为：

 select id,username from front_user where id=1 or 1=1
以上sql语句的条件是id=1 or 1=1，只要id=1或者是1=1两个有一个成立，那么整个条件就成立。毫无疑问1=1是肯定成立的。因此执行完以上sql语句后，会将front_user表中所有的数据都提取出来。

实现一个根据用户的username提取用户的视图。示例代码如下：

 def index(request):
     username = request.GET.get('username')
     cursor = connection.cursor()
     cursor.execute("select id,username from front_user where username='%s'" % username)
     rows = cursor.fetchall()
     for row in rows:
         print(row)
     return HttpResponse('success')
这样表面上看起来也没有问题。但是如果用户传的username是zhiliao' or '1=1，那么以上拼接后的sql语句为：

 select id,username from front_user where username='zhiliao' or '1=1'
以上sql语句的条件是username='zhiliao'或者是一个字符串，毫无疑问，字符串的判断是肯定成立的。因此会将front_user表中所有的数据都提取出来。

sql注入防御：
以上便是sql注入的原理。他通过传递一些恶意的参数来破坏原有的sql语句以便达到自己的目的。当然sql注入远远没有这么简单，我们现在讲到的只是冰山一角。那么如何防御sql注入呢？归类起来主要有以下几点：

永远不要信任用户的输入。对用户的输入进行校验，可以通过正则表达式，或限制长度；对单引号和 双"-"进行转换等。
永远不要使用动态拼装sql，可以使用参数化的sql或者直接使用存储过程进行数据查询存取。比如：
 def index(request):
     user_id = "1 or 1=1"
     cursor = connection.cursor()
     cursor.execute("select id,username from front_user where id=%s",(user_id,))
     rows = cursor.fetchall()
     for row in rows:
         print(row)
     return HttpResponse('success')
永远不要使用管理员权限的数据库连接，为每个应用使用单独的权限有限的数据库连接。
不要把机密信息直接存放，加密或者hash掉密码和敏感的信息。
应用的异常信息应该给出尽可能少的提示，最好使用自定义的错误信息对原始错误信息进行包装。
在Django中如何防御sql注入：
使用ORM来做数据的增删改查。因为ORM使用的是参数化的形式执行sql语句的。
如果万一要执行原生sql语句，那么建议不要拼接sql，而是使用参数化的形式。