#!/bin/bash

lastTime=`date "+%s"`
det=0
showLog()
{
    nowTime=`date "+%s"`
    let det=nowTime-lastTime
    let lastTime=nowTime

    printf "[%s*%4ds] $1\n" "`date "+%Y-%m-%d %H:%M:%S"`" ${det}
}

showLog "start"

# ENV
cd `dirname $0`;
toolPath=`pwd`\/../tools\

declare -A gameLogPathList
declare -A logPathList

pyPath=${toolPath}/fileCopyer/fileCopyer.py
if [ ! -f ${pyPath} ]; then
    toolPath=`pwd`/../../tools
    pyPath=${toolPath}"/fileCopyer/fileCopyer.py"
    if [ ! -f ${pyPath} ]; then
        showLog "get no file fileCopyer/fileCopyer.py"
        exit 1
    fi
fi

gameLogPathList=(
[ywl]=/data/personal/ywl/share/server/php/FOprator
)
gameLogConfPath=`pwd`/copyerBackupGameLog.cnf
if [ ! -f ${gameLogConfPath} ]; then
    showLog "get no file copyerBackupGameLog.cnf"
    exit 1
fi

logPathList=(
[log]=/data/log
)
logConfPath=`pwd`/copyerBackupLog.cnf
if [ ! -f ${logConfPath} ]; then
    showLog "get no file copyerBackupLog.cnf"
    exit 1
fi

for key in ${!gameLogPathList[*]}; do
    if [ ! -d ${gameLogPathList[key]} ]; then
        showLog "skip dir, not exists : ${gameLogPathList[${key}]}"
        continue
    fi

    targetPath=/data/backup/gameLog/${key}/
    if [ ! -d ${targetPath} ]; then
        mkdir -p ${targetPath}
    fi

    showLog "start backup gameLog ${targetPath}"
    python ${pyPath} -w ${gameLogPathList[${key}]} -c ${gameLogConfPath} -t ${targetPath} 1>/dev/null
done

for key in ${!logPathList[*]}; do
    if [ ! -d ${logPathList[key]} ]; then
        showLog "skip dir, not exists : ${logPathList[${key}]}"
        continue
    fi

    targetPath=/data/backup/${key}/
    if [ ! -d ${targetPath} ]; then
        mkdir -p ${targetPath}
    fi

    showLog "start backup log ${targetPath}"
    python ${pyPath} -w ${logPathList[${key}]} -c ${logConfPath} -t ${targetPath} 1>/dev/null
done

showLog "done"
