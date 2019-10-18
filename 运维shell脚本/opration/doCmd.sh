#!/bin/bash

g_serverName=""
g_serverPort=""
g_exInfo=""
g_php_c=""
g_target=""

runPhp()
{
    php_c=""
    if [ "${g_php_c}" != "" ]; then
        php_conf="-c "${g_php_c}
    fi

    /usr/local/bin/php ${php_conf} $1 $2 $3 $4 $5 $6 $7
}

_show()
{
    ps aux | grep -E "${1}[:_].+\[[0-9]+\]" | grep -v 'grep'
}
_showWithTitle()
{
    ps aux | grep -E "(${1}[:_].+\[[0-9]+\]|VSZ +RSS +TTY +STAT +START +TIME +COMMAND)" | grep -v 'grep'
}
_count()
{
    _show $1 | wc -l
}
_start()
{
#    _clearLog
    if [[ `_count $4` -gt 0 ]]; then
        echo "Please stop before start!\n"
        return
    fi

    if [ "${g_target}" = "" ]; then
        g_target=$1
    fi


#    echo "/usr/local/bin/php `pwd`/../script/IServer/${g_target}/main.php $2 $3 $4 $5 $6 >> /data/log/err.log"
    runPhp ../script/IServer/${g_target}/main.php $2 $3 $4 $5 $6 >> /data/log/err.log
}
_stop()
{
    if [[ `_count $1` -lt 1 ]]; then
        echo "Please start before stop!\n"
        return
    fi

    pid=`ps -fe |grep -E "${1}[:_]master\[[0-9]+\]" | grep -v 'grep' |  awk '{print \$2}'`
    echo kill -15 ${pid}
    kill -15 ${pid}
}
_kill()
{
    for i in `_show $1 |grep -v 'grep'|awk '{print pid=$2}'`
    do
        echo "kill "${i}
        kill -9 ${i}
    done
}
_restart()
{
    _stop $4
    for i in `seq 20`
    do
        sleep 0.1
        if [[ `_count $4` -lt 1 ]]; then
            echo "[restart] doStart : "`date`
            _start $1 $2 $3 $4 $5 $6

            return
        fi
        if [[ $i%50 -eq 0 ]]; then
            echo "[restart] waiting stop: "`date`
        fi
    done
    echo "something wrong !! stop failed !! "
}
_getPort()
{
    echo $1
}
_clearLog()
{
    for i in `ls -1 /data/log/*.log`
    do
        echo "" > ${i}
    done
}
_clearGameLog()
{
    if [ ! -d "./emptyForRmoveDir" ]; then
        echo "no empty dir ./emptyForRmoveDir"
        return
    fi

    if [ ! -d "../FOprator" ]; then
        echo "no file dir ../FOprator"
        return
    fi

    if ! `hash rsync>/dev/null`; then
        echo "get no commond rsync"
        return
    fi

    rsync -av --delete --exclude .svn/ ./emptyForRmoveDir/ ../FOprator/
    chmod 777 ../FOprator/
}

_backupLog()
{
    currentTime=`date "+%y%m%d%H%M"`
    abandonTime=`date "+%y%m%d%H%M" --date="-15 days"`
    targetDir=/data/log/backup/

    if [ ! -d ${targetDir} ]; then
        mkdir ${targetDir}
    fi

    if [ ! -d ${targetDir}${currentTime} ]; then
        mkdir ${targetDir}${currentTime}
    fi

    cp /data/log/*.log ${targetDir}${currentTime}

    _clearLog

	dirNames=`ls ${targetDir} -l | grep "^d" | awk '{print $9}' | grep -v "[^0-9]"`

	for dirName in ${dirNames}
	do
        echo ${dirName}
        if [ ${dirName} -lt ${abandonTime} ]; then
            rm ${targetDir}${dirName} -rf
	    fi
	done
}

_showConf()
{
    ls -l ../config/ * | grep "^d" | awk '{print pid=$9}'
}

_checkParam()
{
    if [ "$1" =  "" ]; then
        echo "\$1 get empty"
        exit
    fi
}

doCmd()
{
    inchargeList=$3
    debugMode=$4
    g_serverName=$5
    g_serverPort=$6
    g_exInfo=$7

    case "$1" in
        start)
            _checkParam ${debugMode}
            _checkParam ${g_serverName}
            _checkParam ${g_serverPort}

            _start $2 ${inchargeList} ${debugMode} ${g_serverName} ${g_serverPort} ${g_exInfo};;
        show)
            _showWithTitle ${g_serverName};;
        stop)
            _checkParam ${g_serverName}

            _stop ${g_serverName};;
        kill)
            _checkParam ${g_serverName}

            _kill ${g_serverName};;
        getPort)
            _checkParam ${g_serverName}

            _getPort ${g_serverPort};;
        restart)
            _checkParam ${debugMode}
            _checkParam ${g_serverName}
            _checkParam ${g_serverPort}

            _restart $2 ${inchargeList} ${debugMode} ${g_serverName} ${g_serverPort} ${g_exInfo};;
        clearLog)
            _clearLog;;
        clearGameLog)
            _clearGameLog;;
        backupLog)
            _backupLog;;
        showConf)
            _showConf;;
        *)
            echo "only accept (start|show|stop|kill|restart|getPort|clearLog|clearGameLog|backupLog|showConf)";;
    esac
}
