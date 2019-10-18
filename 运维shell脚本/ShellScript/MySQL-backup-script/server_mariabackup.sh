#!bin/bash
remote_user='sauser'
remote_pass='Gaoji_001#'
backup_dir='/backup_idc/mysql'
backuplog_dir='/backup_idc/mysql/backuplog'    
backup_base='/backup/mysql'
backuplog_base='/backup/mysql/backuplog'
backup_script='host_mariabackup.sh'
backup_date=$(date +%F)
viplist=$1

if [ ! -d "$backup_dir" ]; then
   sudo mkdir -p "$backup_dir"
fi
sudo chown -R sauser:sauser $backup_dir/

if [ ! -d "$backuplog_dir" ]; then
   sudo mkdir -p "$backuplog_dir"
fi

if [ ! -d "$backup_base" ]; then
   sudo mkdir -p "$backup_base"
fi
sudo chown -R sauser:sauser $backup_base

if [ ! -d "$backuplog_base" ]; then
   sudo mkdir -p "$backuplog_base"
fi

if [ ! -f "/home/$remote_user/.ssh/id_rsa" ]; then
  ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' -q
fi

rpm -q expect &> /dev/null
if [ $? -ne 0 ]; then
  sudo yum -y install expect
fi

for vip in $(cat $viplist);
do
if [ ! -d "$backup_dir/$vip" ]; then
  mkdir -p "$backup_dir/$vip"
fi
if [ ! -d "$backup_base/$vip" ]; then
  mkdir -p "$backup_base/$vip"
fi

find $backup_dir/$vip -type f -mtime +3 -exec rm {} \;
find $backup_base/$vip  -type f -mtime +7 -exec rm {} \;

sed -i '/^ipadd=.*$/d' $backup_script
sed -i '2i\ipadd='"$vip"'' $backup_script

/usr/bin/expect <<-EOF
set timeout 5
spawn scp $backup_script $remote_user@$vip:/home/$remote_user/
expect {
        "yes/no" {send "yes\r"; exp_continue}
        "password:" {send "$remote_pass\r"}
       }
expect eof
EOF
done
	
for vip1 in $(cat $viplist);
do
/usr/bin/expect <<-EOF
set timeout 5
spawn ssh $remote_user@$vip1 "bash /home/$remote_user/$backup_script > /dev/null 2>&1 &"
expect {
        "yes/no" {send "yes\r"; exp_continue}
        "password:" {send "$remote_pass\r"}
       }
expect eof
EOF
done
