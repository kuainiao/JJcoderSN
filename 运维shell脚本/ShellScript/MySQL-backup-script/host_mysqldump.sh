#!bin/bash
ipadd=10.8.183.154
user='root'
passwd='Gaoji_dba.com'  
backup_base='/data/backup/mysql'
backuplog='mysqlbackup.log'
backup_server='10.8.6.19'
remote_user='sauser'
remote_pass='Gaoji_001#'
remote_backup_dir='/backup_idc/mysql'
remote_backuplog_dir='/backup_idc/mysql/backuplog'
romote_backup_base='/backup/mysql'
romote_backuplog_base='/backup/mysql/backuplog'
backup_date=$(date +%F)

source /etc/profile
find $backup_base -type f -mtime +2 -exec rm {} \;

which mysql >/dev/null 2>&1
if [ $? -ne 0 ]; then
  sudo ln -s /usr/local/3306/mysql-5.7.21/bin/mysql /bin/mysql
fi

if [ ! -d "$backup_base" ]; then
  sudo mkdir -p $backup_base
fi

sudo chown -R $remote_user:$remote_user $backup_base/

if [ ! -f "/home/$remote_user/.ssh/id_rsa" ]; then
  ssh-keygen -t rsa -f ~/.ssh/id_rsa -N "" -q
fi

rpm -q expect &> /dev/null
if [ $? -ne 0 ]; then
  sudo yum -y install expect
fi

ssh -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no $backup_server "date" >/dev/null 2>&1
if [ $? -ne 0 ]; then
/usr/bin/expect <<-EOF
set timeout 5
spawn ssh-copy-id $backup_server
expect {
        "yes/no" {send "yes\r"; exp_continue}
        "password:" {send "$remote_pass\r"}
       }
expect eof
EOF
fi

cat >$backup_base/$backuplog<<-EOF
##########################################################################################################################
Backup host ip address: $ipadd
Backup server address: $backup_server
Backup start time：$(date +%F-%H:%M:%S)
Local backup path: $backup_base
Remote backup path: $backup_server: $remote_backup_dir/$ipadd/
Remote backup base path: $backup_server: $romote_backup_base/$ipadd/
Backup details are as follows:
EOF

cd $backup_base
mysql -u$user -p$passwd -e "show databases;" >/dev/null 2>&1
if [ $? -eq 0 ]; then
   mysql -u$user -p$passwd -e "show databases;" | grep -Ev "information_schema|Database|performance_schema|mysql|sys" | xargs mysqldump -u$user -p$passwd --master-data=2 --single-transaction --set-gtid-purged=OFF --quick --routines --triggers --databases | gzip  > $backup_base/$(date +%F-%H:%M:%S).sql.gz
   if [ $? -eq 0 ]; then
   	echo "$ipadd successful database backup !!!" >> $backup_base/$backuplog
   	echo "Backup dir file size : $(du -h $backup_base/$backup_date*.sql.gz)" >> $backup_base/$backuplog
   	echo "Backup successful time: $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
   	echo "Remote copy backup file start time ($ipadd-$backup_server): $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
   	scp $backup_base/$backup_date*.sql.gz $remote_user@$backup_server:$remote_backup_dir/$ipadd/
   	if [ $? -eq 0 ];then
      		echo "Remote copy backup file successful !!! ($ipadd-$backup_server): $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
   	else
      		echo "Remote copy backup file failed !!! ($ipadd-$backup_server): $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
   	fi
   	echo "Local copy backup file start time ($remote_backup_dir/$ipadd-$romote_backup_base/$ipadd): $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
   	ssh $remote_user@$backup_server "sudo cp $remote_backup_dir/$ipadd/$backup_date*.sql.gz $romote_backup_base/$ipadd/"
   	if [ $? -eq 0 ]; then
      		echo "Local copy backup file successful !!! ($remote_backup_dir/$ipadd-$romote_backup_base/$ipadd): $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
   	else
      		echo "Local copy backup file failed !!! ($remote_backup_dir/$ipadd-$romote_backup_base/$ipadd): $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
   	fi
        echo "Backup complete time: $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
   else
        echo "$ipadd database backup failed !!!" >> $backup_base/$backuplog
   	echo "Backup failed time: $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
   fi
else
   echo "$ipadd failure to log in to database !!!" >> $backup_base/$backuplog
   echo "Backup failed time: $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
fi
scp $backup_base/$backuplog $remote_user@$backup_server:$remote_backup_dir/$ipadd/
ssh $remote_user@$backup_server "echo \"cat $remote_backup_dir/$ipadd/$backuplog >> $remote_backuplog_dir/$backup_date.log\" | sudo sh && sudo rm -f $remote_backup_dir/$ipadd/$backuplog"
ssh $remote_user@$backup_server "sudo cp $remote_backuplog_dir/$backup_date.log $romote_backuplog_base/"
rm -f /home/$remote_user/host_mysqldump.sh
