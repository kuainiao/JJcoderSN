# mongodb 数据导出

------



> mongdb 数据导出脚本

```shell
  #!/bin/bash
  mysql_user_pwd="--login-path=zabbix"
  mysql_db=XXXXX
  input_file_dir=/tmp/count
  select_into="/root/scripts/select_mysql.sql"
  if [ ! -d "$input_file_dir" ];then
      mkdir $input_file_dir;
  fi
  ### output mysqldb to text!
  select_all_tmp_mongo="select mytitle AS \"类别指标\", (case  git  when '3' then '铁血屠龙' when  '2' then '像素骑士团'  when '1' then '封神伏魔' END ) AS \"游戏名称\", cnt AS \"数量\" ,data_time AS \"记录时间\"  INTO OUTFILE '$input_file_dir/$(date +%Y%m%d).text' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n' FROM tmp_mongo where data_time like '%$(date +%Y-%m-%d)%';"

  ####input mysql db start
  mysql  $mysql_user_pwd $mysql_db <$select_into
  ####input mongo db
  ssh localhost /root/scripts/day_select_mongo.sh >$input_file_dir/tmp_mongo.txt
  while read line
  do
          a=`echo $line | awk '{print $1}'`
          b=`echo $line | awk '{print $2}'`
          c=`echo $line | awk '{print $3}'`
          mysql $mysql_user_pwd  $mysql_db -e "insert into tmp_mongo  values ('$a','$b','$c',now());"
  done <$input_file_dir/tmp_mongo.txt
  #### Mysql db output to csv
  #
  #echo " into CSV  at time  $(date +%Y%m%d%H%M%S)"
  #
  # mysql $mysql_user_pwd $mysql_db --default-character-set=utf8 -e "$select_all_tmp_mongo"  | awk '{print $1,$2,$3,$4}' >$input_file_dir/tmp_all.html
  #
  # mysql $mysql_user_pwd $mysql_db  --default-character-set=utf8 -e "$select_all_tmp_mongo" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' >$input_file_dir/tmp_all.csv
  #if [ $? -eq 0 ];then
  #    	echo "Mysql output to CSV  finshed_time is  $(date +%Y%m%d%H%M%S)"
  #
  #	iconv -f utf-8 -t gb2312 $input_file_dir/tmp_all.csv >$input_file_dir/Count_$(date +%Y%m%d%H%M%S).csv
  #
  #	if [ $? -eq 0 ];then
  #    		echo "Csv iconv to gb2312  finshed_time is  $(date +%Y%m%d%H%M%S)"
  #    	exit 0
  #	else
  #    		echo "Csv iconv to gb2312 is fail! at $(date +%Y%m%d%H%M)"
  #    	exit 1
  #	fi
  #    exit 0
  #else
  #    echo "Mysql output to CSV is fail! at $(date +%Y%m%d%H%M)"
  #    exit 1
  #fi
  chown  -R mysql.mysql  $input_file_dir
  mysql $mysql_user_pwd $mysql_db -e "$select_all_tmp_mongo"
  if [ $? -eq 0 ];then
  	echo "Mysqldb output to $input_file_dir/$(date +%Y%m%d%).text is successful finshed_time is  $(date +%Y%m%d%H%M%S)"
  	cat $input_file_dir/$(date +%Y%m%d).text  | sed -e '1 i\"指标名称","游戏类别","数据值","记录时间\"' | sed -e 's/^"/\<tr bgcolor="#cccccc">\<td>/' | sed -e 's/","/\<\/td><td>/g' | sed -e 's/"$/\<\/td>\<\/tr>/' | sed -e '1 i\<table border=2 width=750 align=center>' | sed -e '$ a\<\/table>' | sed -e '1 a\<h2 align=center>AP-GAME-各项指标\</h2>' >$input_file_dir/$(date +%Y%m%d).html

  	if [ $? -eq 0 ];then
  		echo "$input_file_dir/$(date +%Y%m%d).text to $input_file_dir/$(date +%Y%m%d%).html is successful!!"
  		iconv -f utf-8 -t gb2312 $input_file_dir/$(date +%Y%m%d).html >$input_file_dir/game$(date +%Y%m%d).html

          	if [ $? -eq 0 ];then
                  	echo "Html iconv to gb2312  finshed_time is  $(date +%Y%m%d%H%M%S)"
          	exit 0
          	else
                  	echo "Html iconv to gb2312 is fail! at $(date +%Y%m%d%H%M)"
         		exit 1
          	fi
  	exit 0
  	else
  		echo "$input_file_dir/$(date +%Y%m%d%).text to $input_file_dir/$(date +%Y%m%d%).html is fail!!"
  	exit 1
  	fi
  else
  	echo "Mysqldb output to $input_file_dir/$(date +%Y%m%d%).text is failed time is  $(date +%Y%m%d%H%M%S)"
  	exit 1
  fi
  #scp $input_file_dir/$(date +%Y%m%d%).html apbackup:/data/www/zabbix/apgame/
```