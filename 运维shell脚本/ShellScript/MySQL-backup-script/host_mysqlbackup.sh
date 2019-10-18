#!bin/bash
ipadd=10.8.16.103
user='root'
passwd='Gaoji_dba.com'  
backup_base='/data/backup/mysql'
backup_tmp='mysqlbackup_log'
backuplog='mysqlbackup.log'
backup_server='10.8.6.19'
remote_user='sauser'
remote_pass='Gaoji_001#'
remote_backup_base='/backup/mysql'
remote_backuplog_base='/backup/mysql/backuplog'
download_url='http://172.17.0.30/CentOS-YUM/Pub/Package'
package_name='MySQL_Enterprise_Backup_4.1.2.rpm'
mysqlbackup_file='/opt/mysql/meb-4.1/bin/mysqlbackup'
backup_date=$(date +%F)
mysql_socket=$(cat /etc/my.cnf | grep socket | head -1 | cut -d'=' -f2 | sed 's/^[ \t]*//g')

source /etc/profile
sudo find $backup_base -type f -mtime +1 -exec rm {} \;

which mysql >/dev/null 2>&1
if [ $? -ne 0 ]; then
  sudo ln -s /usr/local/3306/mysql-5.7.21/bin/mysql /bin/mysql
fi

if [ ! -f "$mysqlbackup_file" ];then
	curl -O $download_url/$package_name
	sudo yum -y install $package_name
	rm -f /home/$remote_user/$package_name
fi

if [ ! -d "$backup_base" ]; then
  sudo mkdir -p $backup_base
fi

if [ ! -d "/tmp/$backuplog" ]; then
  sudo mkdir -p /tmp/$backuplog
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
mysql -u$user -p$passwd --socket=$mysql_socket -e "show databases;" >/dev/null 2>&1
if [ $? -eq 0 ];then
   sudo rm -rf /tmp/$backup_tmp/*
   sudo /opt/mysql/meb-4.1/bin/mysqlbackup --backup-image=$backup_base/$(date +%F-%H:%M:%S).mbi --backup-dir=/tmp/$backup_tmp --user=$user --socket=$mysql_socket -p$passwd --read-threads=6 --process-threads=12 --write-threads=6 --limit-memory=300 --skip-binlog --compress --compress-level=5 backup-to-image

   if [ $? -eq 0 ];then
    	sudo chown -R $remote_user:$remote_user $backup_base/
        sudo chown -R $remote_user:$remote_user /tmp/$backup_tmp/
	echo "$ipadd successful database backup !!!" >> $backup_base/$backuplog
	echo "Backup dir file size : $(du -h $backup_base/$backup_date*.mbi)" >> $backup_base/$backuplog
	echo "Backup successful time: $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
	echo "Remote copy backup file start time ($ipadd-$backup_server): $(date +%F-%H:%M:%S)" >>$backup_base/$backuplog
	scp $backup_base/$backup_date*.mbi $remote_user@$backup_server:$remote_backup_base/$ipadd/
        scp -r /tmp/$backup_tmp $remote_user@$backup_server:$remote_backup_base/$ipadd/
        ssh $remote_user@$backup_server "mv $remote_backup_base/$ipadd/$backup_tmp $remote_backup_base/$ipadd/$backup_date-$backup_tmp"
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
scp -r $backup_base/$backuplog $remote_user@$backup_server:$remote_backup_base/$ipadd/
ssh $remote_user@$backup_server "cat $remote_backup_base/$ipadd/$backuplog >> $remote_backuplog_base/$backup_date.log && rm -rf $remote_backup_base/$ipadd/$backuplog"
rm -f /home/$remote_user/host_mysqlbackup.sh
