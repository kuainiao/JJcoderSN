#!/bin/bash -
#===============================================================================
#
#          FILE: initialize.sh
#
#         USAGE: ./initialize.sh
#
#   DESCRIPTION: mysql 初始化脚本
#
#===============================================================================


export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }' # 第四级提示符变量$PS4, 增强”-x”选项的输出信息

set -o nounset                              # Treat unset variables as an error
set -e

PASSWORD=$1

echo "password is ${PASSWORD}"
mysql -u root -p${PASSWORD} --connect-expired-password  <<EOF

SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root');
grant all privileges  on *.* to root@'%' identified by '520Myself.';
flush privileges;

EOF
