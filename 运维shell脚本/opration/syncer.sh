#!/bin/bash
cd `dirname $0`;

if [ "$1" = "" ]; then
    echo "serverName get empty"
    exit
fi

if [ "$2" = "" ]; then
    cmd=""
else
    cmd=$2
fi


/usr/local/bin/php ./../script/iserver/${1}/syncer/main.php ${cmd} >> /data/log/syncer.log

