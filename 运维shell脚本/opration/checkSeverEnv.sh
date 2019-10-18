#!/bin/bash

phpIniPath=`php -i | grep "Loaded Configuration File" | awk '{print $5}'`
echo `cat $phpIniPath | grep "^memory_limit" | awk -F "\r" '{print $1}' | awk -F "=" '{print $2}' | awk -F "M" '{print \$1}'`
let phpMemLimit=`cat $phpIniPath | grep "^memory_limit" | awk -F "\r" '{print $1}' | awk -F "=" '{print $2}' | awk -F "M" '{print \$1}'`
## | awk -F "=" '{print $2}'` | '

echo $phpMemLimit

if [ $phpMemLimit -lt 1204 ]; then
    echo "xxxxx"
fi