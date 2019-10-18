#!/bin/bash
cd `dirname $0`;

if [ "$1" =  "" ]; then
    echo "serverName get empty"
    exit
fi
if [ "$2" =  "" ]; then
    echo "clock N get empty"
    exit
fi
if [ "$3" =  "" ]; then
    echo "gameId get empty"
    exit
fi

/usr/local/bin/php ./../script/iserver/$1/operation/schdule.php $2 $3 >> /data/log/schdule.log

