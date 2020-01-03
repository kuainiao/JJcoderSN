# xtraback备份脚本

------



```shell
# xtraback 备份脚本
# author: kame
# mail:liuwenqi7011@.163.com
#!/bin/sh
#percona-xtrabackup全量和增量备份脚本

#usage: 1. full backup  : ./backup.sh full
#       2. incremental backup : ./backup.sh inc


Innobackupex_Path=/usr/bin/innobackupex
Mysql_Client=/usr/bin/mysql
Bak_Time=`date +%Y%m%d_%H%M%S`

#请勿在Incrbackup_Path及下属文件夹创建或写入内容，否则可能导致增量备份不成功
Backup_Dir=/opt/backup   #备份主目录
#Backup_Dir=/opt/backup/data/`data -I`   #按日期生成备份主目录
Fullbackup_Path=$Backup_Dir/full # 全库备份的目录  
Incrbackup_Path=$Backup_Dir/incr # 增量备份的目录  
Log_Path=$Backup_Dir/logs   #日志文件目录
Keep_Fullbackup=5    #保留的全备份数量,此处要加1; 如要保留2个，此处要写3
Mysql_Conf=/etc/my.cnf #mysql配置文件
Mysql_Opts='--socket=/opt/mysql/mysql.sock  --host=localhost --user=root --password=9hb1a$OCinbl'  #mysql的连接配置，按需修改

Error()  
  {  
    echo -e "\e[1;31m$1\e[0m" 1>&2
    exit 1  
  }  
Backup()
  {
    #两个参数为全量备份,第一个参数为备份目录，第二个参数为日志全路径
    if [ $# = 2 ] ; then
        $Innobackupex_Path --defaults-file=$Mysql_Conf $Mysql_Opts  --no-timestamp  $1/full_$Bak_Time>$2 2>&1
    #三个参数为增量备份，第一个为增量备份目录，第二个为上个增量备份目录,第三个为日志全路径
    elif [ $# = 3 ];then
        $Innobackupex_Path --defaults-file=$Mysql_Conf $Mysql_Opts  --no-timestamp --incremental  $1/incr_$Bak_Time  --incremental-basedir $2 >$3 2>&1
    else
    Error "Backup(): 参数不正确"
     fi
  }

#获得某个目录下，最近修改的目录
Lastest_Dir()
  {
    if [ -d $1 ]; then
        path=`ls -t $1 |head -n 1`
        if [  $path ]; then
            echo $path
        else
            Error "Lastest_Diri(): 目录为空,没有最新目录"
        fi
    else
        Error "Latest_Dir(): 目录不存在或者不是目录"
    fi
  }

#进行增量备份
Do_Inc()
  {
    if [ "$(ls -A $Incrbackup_Path)" ] ; then
        #不是第一次增量备份，以最新的增量备份目录为base_dir
        Backup $Incrbackup_Path $Incrbackup_Path/`Lastest_Dir $Incrbackup_Path`  $Log_Path/incr_$Bak_Time.log
      else
        #第一次增量备份要先全量备份
        Backup $Incrbackup_Path  $Log_Path/incr_full_$Bak_Time.log
    fi
  }

#进行全量备份
Do_Full()
  {
    Backup  $Fullbackup_Path $Log_Path/full_$Bak_Time.log
    cd $Fullbackup_Path
    ls -t |tail -n +$Keep_Fullbackup |xargs  rm -rf
  }

#环境和配置检查
Check()
  {
    #检查目录和创建目录
    if [ ! -d $Fullbackup_Path ];then
        mkdir -p $Fullbackup_Path
    fi
    if [ ! -d $Incrbackup_Path ];then
        mkdir -p $Incrbackup_Path
    fi
    if [ ! -d $Log_Path ];then
        mkdir -p $Log_Path
    fi
    #检测所需的软件
    if [ ! -f $Innobackupex_Path ];then
        Error "未安装xtradbbackup或xtradbbackup路径不正确"
    fi
    if [ ! -f $Mysql_Client ];then
        Error "未安装mysql客户端"
    fi
    if [ ! -f $Mysql_Conf ];then
        Error "mysql配置文件路径不正确"
    fi
    #检查mysql的运行状态
    if [ `netstat -tlnp |grep mysqld |wc -l` = 0 ];then
        Error "MySQL没有运行"
    fi
    #验证mysql的用户和密码是否正确
    if  ! `echo 'exit' | $Mysql_Client -s  $Mysql_Opts >/dev/null 2>&1` ; then
        Error "提供的数据库连接配置不正确!"  
    fi
  }
case $1 in
       full)
          Check
          Do_Full
          ;;
        inc)
          Check
          Do_Inc
          ;;
         *)
          echo "full 全量备份"
      echo "inc  增量备份"
      ;;
esac  
```