#!/bin/bash

#$1 projectName
#$2 cmd (only accept start|show|stop|kill|restart|getPort|clearLog)

cd `dirname $0`;

source "./utils.sh"
source "./doCmd.sh"


_checkPhpC()
{
    if [ ! -f `pwd`"/php_ini/$1php.ini" ]; then
        return
    fi
    g_php_c=`pwd`"/php_ini/$1php.ini";
}

loadEnv()
{
    Environment=`runPhp ../config/Environment.php $1 shell`
    n=0
    for param in $Environment;
    do
        case $n in
        0) configPath=$param
        ;;
        1) inchargeList=$param
        ;;
        2) debugMode=$param
        ;;
        3) g_serverName=$param
        ;;
        4) g_serverPort=$param
        ;;
        5) personal=$param
        ;;
        6) g_target=$param
        ;;
        7) g_exInfo=$param
        ;;
        *)
        echo "unused param$n:$personal"
        ;;
        esac
      n=$(($n+1))
    done
}

loadEnvFromFile()
{
    inchargeList=`readLine $1 1`
    debugMode=`readLine $1 2`
    g_serverName=`readLine $1 3`
    g_serverPort=`readLine $1 4`
    g_exInfo=`readLine $1 5`
    g_target=`readLine $1 6`
}

initEnv()
{

    if [ ! -f "../config/Environment.php" ]; then
        echo "lost Environment.php";
        return
    fi

    getPersonal
    _checkPhpC ${personal}

    loadEnv $1

    if [ "$configPath" ==  '' ]; then
        echo "bad game:$1";
        return
    fi

    if [ -f "$configPath" ]; then
        loadEnvFromFile "$configPath"
    fi

    if [ "$personal" ==  'none' ]; then
        getPersonal
    fi

    g_serverName="${personal}${g_serverName}"

    if [ "$debugMode" ==  '' ]; then
        echo "lost config file:$configPath";
        return
    fi

    echo "configPath:$configPath"
    echo "inchargeList:$inchargeList"
    echo "debugMode:$debugMode"
    echo "personal:$personal"
    echo "serverName:$g_serverName"
    echo "serverPort:$g_serverPort"
    echo "target:$g_target"
    echo "extra:$g_exInfo"

    case "$debugMode" in
        debug)
            ;;
        testServer)
            return
            ;;
        release)
            return
            ;;
        *)
            ;;
    esac
}

cmds=(restart show clearLog stop start kill getPort restart clearGameLog backupLog showConf)
for cmd in  ${cmds[@]}
do
if [ "$1" == "$cmd" ]; then
    command=$1
    target=$2
    break
fi
if [ "$2" == "$cmd" ]; then
    command=$2
    target=$1
    break
fi
done

if [ "$command" ==  '' ]; then
    echo "only accept (start|show|stop|kill|restart|getPort|clearLog|clearGameLog|backupLog|showConf)"
    exit
fi

if [ "$target" ==  '' ]; then
    doCmd $command
    exit
fi

cd `dirname $0`;
initEnv $target
if [ "$debugMode" !=  '' ]; then
    doCmd $command $target ${inchargeList} ${debugMode} ${g_serverName} ${g_serverPort} ${g_exInfo}
fi




