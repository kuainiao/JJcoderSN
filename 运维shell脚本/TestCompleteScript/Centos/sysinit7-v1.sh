#!/bin/bash

####################################################################
########################               ############################# 
######################## modify record #############################
########################               #############################
########################  by sa        #############################
########################               #############################
########################  2015-06-12   #############################
########################               #############################
####################################################################



######################### configuration DNS ########################



echo   "nameserver 10.58.24.120"   > /etc/resolv.conf
echo   "nameserver 10.58.48.120"     >> /etc/resolv.conf





#####################  configuration local yum #####################

if [ ! -d /etc/yum.repos.d/bak ];then
mkdir -p /etc/yum.repos.d/bak
fi
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/
wget -N -q -O /etc/yum.repos.d/centos7.repo	http://10.58.60.21/os/repo/centos7.repo


################### configuration runlevel ########################## 

rm -rf /etc/systemd/system/default.target
ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

 
################## configuration zonetime ###########################
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
 
################## configuration ntp ###############################
    

wget http://file.idc.pub/pub_file/script/sysadmin_ntp_reset

bash sysadmin_ntp_reset >> /dev/null  2>&1
 
################  configuration service ### close the unnecessary services ####################

systemctl  disable  NetworkManager.service  	>> /dev/null 2>&1
systemctl  stop     NetworkManager.service  	>> /dev/null 2>&1	 
systemctl  disable  firewalld.service	    	>> /dev/null 2>&1
systemctl  stop     firewalld.service	    	>> /dev/null 2>&1
systemctl  disable  postfix.service	    	>> /dev/null 2>&1
systemctl  stop     postfix.service		>> /dev/null 2>&1
systemctl  disable  chronyd			>> /dev/null 2>&1
systemctl  stop	    chronyd			>> /dev/null 2>&1


##################### forbidden contrl+alt+delete #####################

rm  -rf /etc/systemd/system/ctrl-alt-del.target

######################### close CoreDump ####################

grep  -v  "^#" /etc/security/limits.conf | grep core  >> /dev/null  2>&1
 
if [ $? -eq  0 ] 
  then
      echo  -e "Close CoreDump           \e[32m done\e[0m"
  else 
      echo "*	soft	core	0"  >> /etc/security/limits.conf
      echo "*	hard	core	0"  >> /etc/security/limits.conf  
      echo  -e "Close CoreDump	         \e[32m done\e[0m"
 fi
 
######################  configuration open the largest number of files ###############################

 grep  -v "^#" /etc/security/limits.conf | grep nofile  >> /dev/null 2>&1
 
 if [ $? -eq 0 ]
          then 
              echo  -e "ulimited config         \e[32m done\e[0m"
	  else
	      echo "*	soft	nofile		655360" >> /etc/security/limits.conf
	      echo "*	hard	nofile		655360" >> /etc/security/limits.conf

 fi

####################### close SELINUX ##############################
  
sed -i               's/SELINUX=enforcing/SELINUX=disabled/g'  /etc/sysconfig/selinux 
sed -i               's/SELINUX=permissive/SELINUX=disabled/g'  /etc/sysconfig/selinux 
sed -i 		     's/SELINUX=enforcing/SELINUX=disabled/g'  /etc/selinux/config
sed -i 		     's/SELINUX=permissive/SELINUX=disabled/g'  /etc/selinux/config

setenforce 0  >> /dev/null
echo  -e  "Close selinux              \e[32m done\e[0m"  

###################### close firewall ##############################

> /etc/sysconfig/iptables
iptables -F  

######################### configuration history record ########################

grep  logger  /etc/bashrc

          if [ $? -ne 0 ]
               then 
                  echo "logger -p local3.info  \"\`who am i\` =======================================  is login \""  >> /etc/bashrc
                  echo  "export PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; }); logger -p local3.info  \[ \$(who am i)\]\# \""\${msg}"\"; }'"  >> /etc/bashrc
                  source /etc/bashrc
                  if  [ -f  /etc/rsyslog.conf ]
                           then
                                echo  "local3.info                        /var/log/history.log"  >> /etc/rsyslog.conf  
                                /etc/init.d/rsyslog restart   
                           else 
                                echo  "local3.info                        /var/log/history.log"  >> /etc/syslog.conf
                                /etc/init.d/syslog restart
                  fi        

           fi


###################### install raid LSI-Tool ######################################                    

if dmidecode -t system |grep Manufacturer |grep HP >> /dev/null  2>&1
then
   if lspci |grep -i raid|grep Gen8 >> /dev/null  2>&1
   then 
      rpm -ivh http://file.idc.pub/software/HPRaid/ssacli-2.60-19.0.x86_64.rpm
   else 
      rpm -ivh http://file.idc.pub/software/HPRaid/hpacucli-9.0-24.0.noarch.rpm
   fi   
else
   rpm -ivh http://file.idc.pub/software/LSI-ToolsMegacli/Lib_Utils-1.00-09.noarch.rpm
   rpm -ivh http://file.idc.pub/software/LSI-ToolsMegacli/MegaCli-8.00.48-1.i386.rpm
fi

modprobe sg
echo sg > /etc/modules-load.d/sg.conf

######################### configuration hostname ########################

cat << EOF > /etc/sysconfig/network
NETWORKING=yes
EOF

echo '' > /etc/hostname

echo "====================================================================================="
echo "============================ Welcome to config hostname ============================="
echo "===================== /etc/hosts and /etc/sysconfig/network ========================="
echo "====================================================================================="
IPADDR=`ip addr|grep global |awk '{print $2}' |cut -d '/' -f1`
ip1=`ip addr |grep global |awk '{print $2}' |cut -d '/' -f1|cut -d '.' -f1`
ip2=`ip addr |grep global |awk '{print $2}' |cut -d '/' -f1|cut -d '.' -f2`
ip3=`ip addr |grep global |awk '{print $2}' |cut -d '/' -f1|cut -d '.' -f3`
ip4=`ip addr |grep global |awk '{print $2}' |cut -d '/' -f1|cut -d '.' -f4`
function SPA_hostname(){
	HOSTNAME=SPA-$ip4-$ip3-$ip2
	echo "HOSTNAME=$HOSTNAME" >> /etc/sysconfig/network
	echo "$IPADDR $HOSTNAME" >> /etc/hostname
	/bin/hostnamectl set-hostname $HOSTNAME
}
function VM_hostname(){
	HOSTNAME=VM-$ip1-$ip2-$ip3-$ip4
	echo "HOSTNAME=$HOSTNAME" >> /etc/sysconfig/network
	echo "$IPADDR $HOSTNAME" >> /etc/hostname
	/bin/hostnamectl set-hostname $HOSTNAME
}
if dmidecode -t system |grep Manufacturer|awk -F":" '{print $2}'|grep -i vmware;then
	VM_hostname
else
	SPA_hostname
fi


####################### install zabbix_agent ################################

 if  [ ! -d  /etc/zabbix ]
         then  
		  yum -y install  net-tools >> /dev/null
		  yum -y install vim* >> /dev/null
		  yum -y install wget >> /dev/null
	      echo  -e  "starting install zabbix          \e[32m done \e[0m"
	      wget   10.69.213.97:8080/zabbix/gome/zabbix_install.sh
	      sh  zabbix_install.sh >> /dev/null	
	      echo  -e  "install zabbix successfully      \e[32m done \e[0m"
        else
              echo -e  "zabbix is already installed"
 fi




#########################openssl version update#############################
yum install -y openssl openssl-devel

#cd /tmp
#wget http://file.idc.pub/pub_file/script/openssl_update.sh
#bash openssl_update.sh

########### CSuser add ################################################
wget http://10.58.60.21/pub_file/script/useradd.sh
bash useradd.sh >> /dev/null

exit 0
echo "\\r"
