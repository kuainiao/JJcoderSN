#!/bin/bash

#dns server
dns_server='10.80.3.25'

#yum server
yum_server='yum.server.local'

#ntp server
ntp_server='ntp.server.local'

system_info=`head -n 1 /etc/issue`
case "${system_info}" in
        'CentOS release 5'*)
                system='centos5'
                yum_source_name='centos5-lan'
                ;;
        'Red Hat Enterprise Linux Server release 5'*)
                system='rhel5'
                yum_source_name='RHEL5-lan'
                ;;
        'Red Hat Enterprise Linux Server release 6'*)
                system='rhel6'
                yum_source_name='RHEL6-lan'
                ;;
        *)
                system='unknown'
                echo "This script not support ${system_info}" 1>&2
                exit 1
                ;;
esac

mark_file="/etc/init_${system}.info"

[ -f "${mark_file}" ] && exit 1

yum='yum --skip-broken --nogpgcheck'

$yum install -y wget rsync lftp vim >/dev/null 2>&1 || eval "echo YUM Failed!;exit 1"

#set time
mydate=`date -d now +"%Y%m%d%H%M%S"`

add_dns() {
test -f /etc/resolv.conf && echo "nameserver ${dns_server}" > /etc/resolv.conf
}

set_ntp() {
$yum -y install ntp >/dev/null 2>&1 || install_ntp='fail'
if [ "${install_ntp}" = "fail" ];then
        echo "yum fail! ntp install fail!" 1>&2
        exit 1
else
        grep 'ntpdate' /etc/crontab >/dev/null 2>&1 || ntp_set='no'
        if [ "${ntp_set}" = "no" ];then
                echo "*/15 * * * * root ntpdate ${ntp_server} > /dev/null 2>&1" >> /etc/crontab
                service crond restart
        fi
fi
}

set_ulimit() {
grep -E '^ulimit.*' /etc/rc.local >/dev/null 2>&1 || echo "ulimit -SHn 4096" >> /etc/rc.local
limit_conf='/etc/security/limits.conf'
grep -E '^#-=SET Ulimit=-' ${limit_conf} >/dev/null 2>&1 ||set_limit="no"
if [ "${set_limit}" = 'no' ];then
test -f ${limit_conf} && echo '
#-=SET Ulimit=-
* soft nofile 4096
* hard nofile 65536
' >> ${limit_conf}
fi
nproc_conf='/etc/security/limits.d/90-nproc.conf'
grep -Eq '^#-=SET Nproc=-' ${nproc_conf} ||set_nproc="no"
if [ "${set_nproc}" = 'no' ];then
test -f ${nproc_conf} && echo '
app          soft    nproc     40960
' >> ${nproc_conf}
fi
}

disable_ipv6() {
keys=('alias net-pf-10 off' 'alias ipv6 off' 'options ipv6 disable=1')
conf='/etc/modprobe.d/disable_ipv6.conf'
for key in "${keys[@]}"
do
   echo "${key}" >> ${conf}
done

/sbin/chkconfig --list|grep 'ip6tables' >/dev/null 2>&1 && /sbin/chkconfig ip6tables off
echo "ipv6 is disabled!"
}

disable_selinux() {
if [ -f "/etc/selinux/config" ];then
        cp /etc/selinux/config /etc/selinux/config.${mydate}
        sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
        echo "selinux is disabled,you must reboot!" 1>&2
fi
}

set_vim() {
sed -i "8 s/^/alias vi='vim'/" /root/.bashrc
echo "alias vi='vim'"  >> /etc/profile.d/vim_alias.sh
grep -E '^set ts=4' /etc/vimrc >/dev/null 2>&1 ||\
echo "set nocompatible
set ts=4
set backspace=indent,eol,start
syntax on" >> /etc/vimrc
}

init_ssh() {
ssh_cf="/etc/ssh/sshd_config"
if [ -f "${ssh_cf}" ];then
        sed -i "s/#UseDNS yes/UseDNS no/;s/^GSSAPIAuthentication.*$/GSSAPIAuthentication no/" $ssh_cf
        service sshd restart
echo "init sshd ok."
else
        echo "${ssh_cf} not find!"
        exit 1
fi
}

turnoff_services() {
chkconfig --list|awk '/:on/{print $1}'|\
grep -E 'NetworkManager|rpcbind|portreserve|autofs|auditd|cpuspeed|postfix|ip6tables|mdmonitor|pcscd|iptables|bluetooth|nfslock|portmap|ntpd|cups|avahi-daemon|yum-updatesd|sendmail'|\
while read line
do
        chkconfig "${line}" off
        service "${line}" stop >/dev/null 2>&1
        echo "service ${line} stop"
done
echo "init service ok."
}

rm_cron_job() {
for cron_file in /etc/cron.daily/makewhatis.cron /etc/cron.weekly/makewhatis.cron /etc/cron.daily/mlocate.cron
do
        test -e ${cron_file} && chmod -x ${cron_file}
done
}

#close ctrl+alt+del
close_del() {
test -e /etc/inittab &&\
sed -i "s/ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/#ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/" /etc/inittab

echo "init ${system} ok" > ${mark_file}
}

set_timeout() {
profile_config='/etc/profile'
test -f ${profile_config} || exit 1
grep -q "TMOUT" ${profile_config} || \
echo "export TMOUT=300" >> ${profile_config}
}

user_add() {
awk -F: '{print $1}' /etc/passwd | grep -Eq '^sysyunwei$'
if [ $? -ne 0 ];then
        useradd -s /bin/bash -G wheel -m sysyunwei
        echo 'xdjk2016'| passwd --stdin sysyunwei > /dev/null
fi
}

disable_su() {
su_config='/etc/pam.d/su'

test -f ${su_config} || exit 1
grep -Eq '^auth.*required.*pam_wheel.so' ${su_config} 
if [ $? -ne 0 ];then
        sed -i 's/^#auth\(.*required.*pam_wheel.so.*\)/auth\1/'  ${su_config}
fi
}

disable_root_ssh() {
sshd_config='/etc/ssh/sshd_config'

test -f ${sshd_config} || exit 1
grep -Eq '^PermitRootLogin' ${sshd_config}
if [ $? -ne 0 ];then
        echo "PermitRootLogin no" >> ${sshd_config}
else
        sed 's/^\(PermitRootLogin\).*/\1 no/' ${sshd_config}
fi
}

passwd_min_len() {
pass_file='/etc/login.defs'

test -f ${pass_file} || exit 1
sed -i 's/\(^PASS_MIN_LEN\).*/\1    12/' ${pass_file}

grep -Eq '^SU_WHEEL_ONLY' ${pass_file} || \
echo "SU_WHEEL_ONLY yes" >> ${pass_file}
}

main() {
add_dns
set_ntp
set_ulimit
disable_ipv6
disable_selinux
set_vim
init_ssh
turnoff_services
rm_cron_job
close_del
set_timeout
user_add
passwd_min_len
#disable_su
#disable_root_ssh
}

main
