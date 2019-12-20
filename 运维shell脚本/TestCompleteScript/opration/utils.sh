#!/bin/bash

personal=""

readLine()
{
    case "$#" in
        1)
            head $1 -n 1 | tail -n 1 | awk 'BEGIN{ORS=""} {print $1}';;
        2)
            if [[ `cat $1 | wc -l`+1 -lt $2 ]]; then
                echo "";
            else
                head $1 -n $2 | tail -n 1 | awk 'BEGIN{ORS=""} {print $1}';
            fi
            ;;
        3)
            head $1 -n $2+$3-1 | tail -n $3  | awk 'BEGIN{ORS=""} {print $1}';;
        *)
            echo "accept params (file [start=1] [linecount=1])";;
    esac
}

getPersonal()
{
    personal=`pwd | awk -F"/" '{print $4}'\n`
}

loopUntil()
{
    checkOver="$1"

    maxLoop=`echo $2 60|awk 'BEGIN{ORS=""} {print $1}'`
    delay=`echo $3 0.01|awk 'BEGIN{ORS=""} {print $1}'`

    for i in `seq ${maxLoop}`
    do
        sleep ${delay}
        if ( ${checkOver} ); then
            return 0
        fi
    done

    return 1
}