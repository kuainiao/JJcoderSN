#!/bin/bash
########################  install nginx   ########################
systemctl status nginx
if [[ $? == 4 ]];then  # 表示没有安装nginx
    yum install -y nginx
    if [[ $? == 0 ]];then
        #echo 'Yes!'
        systemctl start nginx
        if [[ $? == 0 ]];then
            echo "Congratulations!! Nginx start OK!!"
        else
            echo "Sorry is Fail!!!"    
        fi
    else
        echo "sorry install is Fail!!!"
    fi
elif [[ $? == 3 ]];then  # 表示已经安装但未启动
    systemctl start nginx
    if [[ $? == 0 ]];then
        echo "Congratulations!! Nginx start OK!!!"
    else
        echo "sorry!!"
    fi
elif [[ $? == 0 ]];then
    echo "OKOKOK!!!"
else 
    echo "I am so sorry"    
fi
echo "config writing...."
######################### config nginx upstream ################################
grep 'upstream' /etc/nginx/nginx.conf
if [[ $? != 0 ]];then
    sed -ri '/^http/a upstream Yanlong {' /etc/nginx/nginx.conf
    sed -ri '/^upst/a server yanlongweb1 weight=3\;' /etc/nginx/nginx.conf
    sed -ri '/^server yanlongweb1/a server yanlongweb2\;' /etc/nginx/nginx.conf
    sed -ri '/^server yanlongweb2/a \}' /etc/nginx/nginx.conf
    sed -ri '/^(\ +)(location)(\ )(\/)/a proxy_pass http:\/\/Yanlong\;' /etc/nginx/nginx.conf
fi
echo "config write is OK!"
systemctl reload nginx  # 重新加载配置文件
if [[ $?==0 ]];then
    echo "HTTP load balancer is OK!"
else
    echo "Sorry!!"
fi
###################### install nfs #################################
systemctl status nfs
if [[ $?==4 ]];then
    yum install rpcbind nfs-utils -y
    if [[ $?==0 ]];then
        #echo 'Yes!'
        systemctl start nfs
        if [[ $?==0 ]];then
            echo "Congratulations!! nfs start OK!!"
        else
            echo "Sorry is Fail!!!"    
        fi
    else
        echo"sorry install is Fail!!!"
        
    fi 
elif [[ $?==3 ]];then
    systemctl start nfs
    if [[ $?==0 ]];then
        echo "Congratulations!! nfs start OK!!!"
    else
        echo "sorry!!"
    fi
elif [[ $?==0 ]];then
    echo "OKOKOK!!!"
else 
    echo "I am so sorry"    
fi
echo "config writing...."
echo "/webindex 192.168.16.0/24(rw,sync,fsid=0)" > /etc/exports
echo "config write is OK!"
systemctl reload nfs
if [[ $?==0 ]];then
    echo "NFS service is OK!"
else
    echo "Sorry!!"
fi



