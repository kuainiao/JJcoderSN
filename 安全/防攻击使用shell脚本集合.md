# 防攻击使用shell脚本集合

------



检查iptables CC IP 访问排名

```bash
      #!/bin/bash
      num=100   //设置最高连接的值
      IP=`netstat -an |grep ^tcp.*:80|egrep -v 'LISTEN|127.0.0.1'|awk -F"[ ]+|[:]" '{print $6}'|sort|uniq -c|sort -rn|awk '{if ($1>$num){print $2}}'`
      for i in $IP
      do
            echo $i
      done
```

检查 SYN 访问链接

```bash
 #!/bin/bash
 conn=`netstat -an | grep SYN | awk '{print $5}' | awk -F: '{print $1}' | sort | uniq -c | sort -nr |head -n20`
 for i in $conn
 do
 echo $i
 done
```