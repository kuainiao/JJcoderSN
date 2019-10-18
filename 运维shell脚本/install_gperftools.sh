#!/bin/bash
package_name='gperftools-libs-2.6.1-1.el7.x86_64.rpm'

if [ ! -f "libtcmalloc_minimal.so.4.4.5" ]; then
        curl -O http://172.17.0.30/CentOS-YUM/Pub/Package/$package_name
        yum -y install lsof libunwind $package_name
fi

if [ -f "/usr/local/3306/mysql-5.7.21/bin/mysqld_safe" ]; then
        sed -i '13i\export LD_PRELOAD=/usr/lib64/libtcmalloc_minimal.so.4' /usr/local/3306/mysql-5.7.21/bin/mysqld_safe
        systemctl restart mysql3306.service
        lsof | grep -i libtcmalloc
else
        cp /usr/lib/systemd/system/mysqld.service{,.bak}
        sed -i '40i\Environment="LD_PRELOAD=/usr/lib64/libtcmalloc_minimal.so.4"' /usr/lib/systemd/system/mysqld.service
        sed -i '40i\#malloc-lib' /usr/lib/systemd/system/mysqld.service
		systemctl daemon-reload
        systemctl restart mysqld.service
        lsof | grep -i libtcmalloc
fi
