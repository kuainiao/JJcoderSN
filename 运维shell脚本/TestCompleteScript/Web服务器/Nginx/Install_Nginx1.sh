#!/bin/bash
#
#tddh 2017-6-6  ********@163.com   rhel6u4 x86_64
#
#nginx install
#
##########################################################################################

#定义参数
cur_dir=`pwd`  #packages……
nginx_user=nginx

zlib=zlib-1.2.11.tar.gz
zlib_version=zlib-1.2.11

openssl=openssl-1.1.0f.tar.gz
openssl_version=openssl-1.1.0f

pcre=pcre-8.10.tar.gz
pcre_version=pcre-8.10

nginx=nginx-1.13.1.tar.gz
nginx_version=nginx-1.13.1

module1=nginx-goodies-nginx-sticky-module-ng-c78b7dd79d0d.zip
module1_version=nginx-goodies-nginx-sticky-module-ng-c78b7dd79d0d
 
module2=nginx_upstream_check_module-master.zip
module2_version=nginx_upstream_check_module-master

#cdrom="/app/system/rhel6.SIO"   #光盘位置，全路径


#依赖包,#yum安装源配置

#安装nginx

#系统变量


cp /etc/sysctl.conf  /etc/sysctl.conf_swyang.conf

cat <<EOF > /etc/sysctl.conf
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_syncookies = 1  
fs.file-max = 999999  
net.ipv4.tcp_tw_reuse = 1  
net.ipv4.tcp_keepalive_time = 600  
net.ipv4.tcp_fin_timeout = 30  
net.ipv4.tcp_max_tw_buckets = 5000  
net.ipv4.ip_local_port_range = 1024 61000  
net.ipv4.tcp_rmem = 10240 87380 12582912  
net.ipv4.tcp_wmem = 10240 87380 12582912  
net.core.netdev_max_backlog = 8096  
net.core.rmem_default = 6291456  
net.core.wmem_default = 6291456  
net.core.rmem_max = 12582912  
net.core.wmem_max = 12582912  
net.ipv4.tcp_max_syn_backlog = 8192
EOF

if [ $? -ne 0 ]
    then
        echo "sysctl.conf   install error"
        exit 1
    else
        echo "11 sysctl.conf    success" >> ${cur_dir}/tddh_install.log 
fi

sysctl -p


echo  "    ${nginx_user}          soft        nproc               20480" >> /etc/security/limits.conf 
echo  "    ${nginx_user}          hard        nproc               26384" >> /etc/security/limits.conf 
echo  "    ${nginx_user}          soft        nofile              10240" >> /etc/security/limits.conf 
echo  "    ${nginx_user}          hard        nofile              65536" >> /etc/security/limits.conf 
echo  "    ${nginx_user}          soft        stack               10240" >> /etc/security/limits.conf 

echo "session    required     pam_limits.so"  >> /etc/pam.d/login
if [ $? -ne 0 ]
    then
        echo "limits.conf  install error"
        exit 1
    else
        echo "12 limits.conf   success" >> ${cur_dir}/tddh_install.log 
fi

echo "UseDNS no"  >> /etc/ssh/sshd_config
echo "UseLogin yes"  >> /etc/ssh/sshd_config
/etc/init.d/sshd restart
if [ $? -ne 0 ]
    then
        echo "sshd  install error"
        exit 1
    else
        echo "13 sshd   success" >> ${cur_dir}/tddh_install.log 
fi
 
#install nginx
cd ${cur_dir}/packages/
tar -zxvf ${zlib}
tar -zxvf ${openssl}
tar -zxvf ${pcre}
tar -zxvf ${nginx}
unzip ${module1}
unzip ${module2}

if [ $? -ne 0 ]
    then
        echo "tar nginx   install error"
        exit 1
    else
        echo "14 tar nginx   success" >> ${cur_dir}/tddh_install.log 
fi

cd ${nginx_version}/
./configure --user=${nginx_user} --group=${nginx_user} --prefix=${cur_dir}/${nginx_version} --with-http_stub_status_module --with-http_ssl_module --add-module=${cur_dir}/packages/${module1_version} --add-module=${cur_dir}/packages/${module2_version} --with-http_realip_module --with-pcre=${cur_dir}/packages/${pcre_version}  --with-zlib=${cur_dir}/packages/${zlib_version}  --with-openssl=${cur_dir}/packages/${openssl_version}/ --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module

if [ $? -ne 0 ]
    then
        echo "nginx configure  install error"
        exit 1
    else
        echo "15 nginx configure  success" >> ${cur_dir}/tddh_install.log 
fi

make 
if [ $? -ne 0 ]
    then
        echo "nginx make  install error"
        exit 1
    else
        echo "16 nginx make  success" >> ${cur_dir}/tddh_install.log 
fi

make install
if [ $? -ne 0 ]
    then
        echo "nginx make install install error"
        exit 1
    else
        echo "17 nginx make install success" >> ${cur_dir}/tddh_install.log 
fi



#配置

[ -d ${cur_dir}/${nginx_version}/lock ] || mkdir ${cur_dir}/${nginx_version}/lock
[ -d ${cur_dir}/${nginx_version}/run ] || mkdir ${cur_dir}/${nginx_version}/run
[ -d ${cur_dir}/${nginx_version}/script ] || mkdir ${cur_dir}/${nginx_version}/script

#nginx configure

cat <<EOF > ${cur_dir}/${nginx_version}/conf/proxy.conf
fs.file-max = 999999
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.ip_local_port_range = 1024 61000
net.ipv4.tcp_rmem = 4096 32768 262142
net.ipv4.tcp_wmem = 4096 32768 262142
net.ipv4.tcp_syncookies = 1
net.core.netdev_max_backlog = 8096
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.core.rmem_max = 2097152
net.core.wmem_max = 2097152
net.ipv4.tcp_max_syn.backlog = 1024
EOF

if [ $? -ne 0 ]
    then
        echo "nginx proxy.conf install error"
        exit 1
    else
        echo "18 nginx proxy.conf success" >> ${cur_dir}/tddh_install.log 
fi



cpu_number=`cat /proc/cpuinfo | grep process | awk '{print $3}' | wc -l`


cat <<EOF > ${cur_dir}/${nginx_version}/conf/nginx.conf
user  ${nginx_user};
worker_processes  ${cpu_number};

error_log  logs/error.log;
error_log  logs/error.log  notice;
error_log  logs/error.log  info;

pid        run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

}
EOF

if [ $? -ne 0 ]
    then
        echo "nginx nginx.conf install error"
        exit 1
    else
        echo "19 nginx nginx.conf success" >> ${cur_dir}/tddh_install.log 
fi


cat <<EOF > ${cur_dir}/${nginx_version}/script/nginx.sh
#!/bin/bash  
# nginx Startup script for the Nginx HTTP Server  
# description: Nginx is a high-performance web and proxy server.  
#              It has a lot of features, but it's not for everyone.  
# processname: nginx  
# pidfile: /var/run/nginx.pid  
# config: /usr/local/nginx/conf/nginx.conf

#nginx启动文件  
nginxd=${cur_dir}/${nginx_version}/sbin/nginx 

#nginx配置文件
nginx_config=${cur_dir}/${nginx_version}/conf/nginx.conf  

#nginx的pid文件
nginx_pid=${cur_dir}/${nginx_version}/sbin/nginx.pid  
RETVAL=0  
prog="nginx"  
# Source function library.  
. /etc/rc.d/init.d/functions  
# Source networking configuration.  
. /etc/sysconfig/network  
# Check that networking is up.  
[ \${NETWORKING} = "no" ] && exit 0  
[ -x \$nginxd ] || exit 0  
# Start nginx daemons functions.  
start() {  
if [ -e \$nginx_pid ];then  
   echo "nginx already running...."  
   exit 1  
fi  
   echo -n \$"Starting \$prog: "  
   daemon \$nginxd -c \${nginx_config}  
   RETVAL=\$?  
   echo  
   [ \$RETVAL = 0 ] && touch ${cur_dir}/${nginx_version}/lock/nginx  
   return $RETVAL  
}  
# Stop nginx daemons functions.  
stop() {  
    echo -n \$"Stopping \$prog: "  
    killproc \$nginxd  
    RETVAL=\$?  
    echo  
    [ \$RETVAL = 0 ] && rm -f ${cur_dir}/${nginx_version}/lock/nginx ${cur_dir}/${nginx_version}/run/nginx.pid  
}  
# reload nginx service functions.  
reload() {  
    echo -n \$"Reloading \$prog: "  
    #kill -HUP \`cat \${nginx_pid}\`  
    killproc \$nginxd -HUP  
    RETVAL=\$?  
    echo  
}  
# See how we were called.  
case "\$1" in  
start)  
    start  
    ;;  
stop)  
    stop  
    ;;  
reload)  
    reload  
    ;;  
restart)  
    stop  
    start  
    ;;  
status)  
    status \$prog  
    RETVAL=\$?  
    ;;  
*)  
    echo \$"Usage: \$prog {start|stop|restart|reload|status|help}"  
    exit 1  
esac  
exit \$RETVAL 
EOF


if [ $? -ne 0 ]
    then
        echo "nginx nginx.sh install error"
        exit 1
    else
        echo "20 nginx nginx.sh success" >> ${cur_dir}/tddh_install.log 
fi

chmod +x ${cur_dir}${nginx_version}/script/nginx.sh 
chown ${nginx_user}.${nginx_user} -R ${cur_dir}/nginx

if [ $? -ne 0 ]
    then
        echo "nginx ${nginx_user} install error"
        exit 1
    else
        echo "21 nginx ${nginx_user} success" >> ${cur_dir}/tddh_install.log 
        echo #########################End##############################
        exit 1
fi