#!bin/bash
ipadd=10.8.183.116
user='dba'
passwd='Gaoji_dba.com'  
backup_base='/data/backup/mysql'
backuplog='mysqlbackup.log'
backup_server='10.8.6.19'
remote_user='sauser'
remote_pass='Gaoji_001#'
remote_backup_base='/backup/mysql'
remote_backuplog_base='/backup/mysql/backuplog'
download_url='http://172.17.0.30/CentOS-YUM/Pub/YumRepoFile/CentOS7/Mariadb.repo'
package_name='MariaDB-backup'
mysqlbackup_file='/opt/mysql/meb-4.1/bin/mysqlbackup'
databases_name='zabbix'
backup_date=$(date +%F)

source /etc/profile

which marabackup > /dev/null 2>&1
if [ $? -ne 0 ];then
	curl -o /etc/yum.repos.d/mariadb.repo  $download_url
	sudo yum -y install $package_name
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
Remote backup base path: $backup_server: $romote_backup_base/$ipadd/
Backup details are as follows:
EOF

cd $backup_base 
mysql -u$user -p$passwd -h$ipadd -e "show databases;" >/dev/null 2>&1
if [ $? -eq 0 ];then
   sudo /usr/bin/mariabackup --backup --target-dir $backup_base/$(date +%F)_fullbackup --binlog-info=OFF  --user $user --password $passwd --host $ipadd --databases="$databases_name" --compress --compress-threads=12 --compress-chunk-size=5M
   if [ $? -eq 0 ];then
	find $backup_base -type f -mtime +2 -exec rm {} \;
    	sudo chown -R $remote_user:$remote_user $backup_base/
	echo "$ipadd successful database backup !!!" >> $backup_base/$backuplog
	echo "Backup dir file size : $(du -sh $backup_base/$backup_date_fullbackup)" >> $backup_base/$backuplog
	echo "Backup successful time: $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
	echo "Remote copy backup file start time ($ipadd-$backup_server): $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
	scp -r $backup_date_fullbackup $remote_user@$backup_server:$remote_backup_base/$ipadd/
	if [ $? -eq 0 ];then
		echo "Remote copy backup file successful !!! ($ipadd-$backup_server): $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
	else
		echo "Remote copy backup file failed !!! ($ipadd-$backup_server): $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
	fi
	echo "Backup complete time: $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
   else
        sudo chown -R $remote_user:$remote_user $backup_base/
	echo "$ipadd database backup failed !!!" >> $backup_base/$backuplog
	echo "Backup failed time: $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
   fi
else
   sudo chown -R $remote_user:$remote_user $backup_base/
   echo "$ipadd failure to log in to database !!!" >> $backup_base/$backuplog
   echo "Backup failed time: $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
fi
scp $backup_base/$backuplog $remote_user@$backup_server:$remote_backup_base/$ipadd/
ssh $remote_user@$backup_server "cat $remote_backup_base/$ipadd/$backuplog >> $remote_backuplog_base/$backup_date.log && rm -rf $remote_backup_base/$ipadd/$backuplog"
#find $backup_base -type f -mtime +2 -exec rm {} \;
rm -f /home/$remote_user/host_mysqlbackup.sh
