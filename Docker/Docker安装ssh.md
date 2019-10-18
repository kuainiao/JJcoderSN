```
docker run -it --name ansible --privileged centos /usr/sbin/init
yum -y install openssh*

mkdir -p /var/run/sshd    #创建一个空目录 等会用于ssh启动

ssh-keygen -t rsa   #创建一个秘钥

vim /etc/ssh/sshd_config   修该
#UsePAM yes 改为 UsePAM no 
#UsePrivilegeSeparation sandbox 改为 UsePrivilegeSeparation no

systemctl start sshd
```