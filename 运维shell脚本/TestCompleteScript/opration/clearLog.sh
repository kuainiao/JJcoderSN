#!/bin/bash

for i in `ls -1 /data/log/*.log`
do
    echo "" > $i
done