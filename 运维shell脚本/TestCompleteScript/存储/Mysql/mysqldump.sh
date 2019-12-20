#!/bin/bash
cd `dirname $0`;
cd ../backup

currentTime=`date "+%Y-%m-%d-%H-%M-%S"`
dbName="mj_dev"

mysqldump --login-path=local $dbName --ignore-table=$dbName.game_record_detail --ignore-table=$dbName.player_online --ignore-table=$dbName.game_crash_report > ${dbName}_$currentTime.sql

