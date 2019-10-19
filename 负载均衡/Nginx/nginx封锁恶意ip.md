# Nginx 封锁恶意 IP，并且定时取消的两种脚本

在这篇文章中：

- 一、使用nginx封锁
    - [1、封锁ip](javascript:;)
    - [2、解锁ip](javascript:;)
- 二、使用iptables封锁
    - [1、封锁IP脚本](javascript:;)

## 一、使用nginx封锁



脚本逻辑：两个脚本，一个脚本检索出访问量大于固定值的IP，并把这个IP加入到[nginx](https://www.qcloud.com/document/product/457/7851?fromSource=gwzcw.59303.59303.59303)的封锁配置文件中，使用at任务，定时（如一个小时）启用另一个脚本，实现对封锁IP的解锁。

步骤如下： 

1、打开[nginx](https://www.qcloud.com/document/product/457/7851?fromSource=gwzcw.59303.59303.59303)配置文件： vim /usr/local/nginx/conf/nginx.conf #这个配置文件根据自己的路径进行配置 

2、在server段加入如下语句： include blockip.conf;



### 1、封锁ip



```js
#!/bin/bash
max=500    #我们设定的最大值，当访问量大于这个值得时候，封锁
confdir=/usr/local/data/nginx/conf/blockip.conf #nginx封锁配置文件路径
logdir=/usr/local/data/nginx/logs/access_huke88.log  #nginx访问日志文件路径
#检测文件
test -e ${confdir} || touch ${confdir}
drop_ip=""
#循环遍历日志文件取出访问量大于500的ip
for drop_ip  in $(cat $logdir | awk '{print $1}' | sort | uniq -c | sort -rn  | awk '{if ($1>500) print $2}')
do
  grep  -q  "${drop_Ip}" ${confdir} && eg=1 || eg=0;
  if (( ${eg}==0 ));then
     echo "deny ${drop_Ip};">>$confdir  #把“deny IP；”语句写入封锁配置文件中
     echo ">>>>> `date '+%Y-%m-%d %H%M%S'` - 发现攻击源地址 ->  ${drop_Ip} " >> /usr/local/data/nginx/logs/nginx_deny.log  #记录log
  fi
done
service nginx reload
```



### 2、解锁ip



```js
#！/bin/bash
sed -i 's/^/#&/g' /usr/local/nginx/conf/
blockip.conf  #把nginx封锁配置文件中的内容注释掉
service nginx reload   #重置nginx服务，这样就做到了解锁IP
```



## 二、使用iptables封锁



封锁逻辑：两个脚本，一个检索出访问量大于我们设定值得IP，并把这个IP添加到防火墙规则中，实现IP封锁，定时（如一小时）后，使用at服务调用另一个脚本，这个脚本把iptables规则清楚，实现对封锁IP的解锁，脚本如下：



### 1、封锁IP脚本



```js
#!/bin/bash
max=500    #我们设定的最大值，当访问量大于这个值得时候，封锁
logdir=/usr/local/data/nginx/logs/access_huke88.log  #nginx访问日志文件路径
port=80
drop_ip=""
#循环遍历日志文件取出访问量大于500的ip
for drop_ip  in $(cat $logdir | awk '{print $1}' | sort | uniq -c | sort -rn  | awk '{if ($1>500) print $2}')
do
  grep  -q  "${drop_Ip}" ${confdir} && eg=1 || eg=0;
  if (( ${eg}==0 ));then
     iptables -I INPUT -p tcp --dport ${port} -s ${drop_Ip} -j DROP
     echo ">>>>> `date '+%Y-%m-%d %H%M%S'` - 发现攻击源地址 ->  ${drop_Ip} " >> /usr/local/data/nginx/logs/nginx_deny.log  #记录log
  fi
done
```



加入计划任务每五分钟执行一次



```js
chmod +x /home/scripts/deny_ip.sh
#####nginx封ip######
*/5 * * * * /bin/sh /home/scripts/deny_ip.sh >/dev/null 2>&1
```