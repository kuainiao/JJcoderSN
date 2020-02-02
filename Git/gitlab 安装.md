# gitlab 安装

------



## Gitlab 安装配置

### gitlab 安装脚本

```bash
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
```

由于资源在国外，国内下载很慢，推荐使用清华大华gitlab源

```bash
vim /etc/yum.repos.d/gitlab-ce.repo
添加如下内容


[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el$releasever/
gpgcheck=0
enabled=1
```

添加完成后，执行如下代码：

```bash
sudo yum makecache  
sudo yum install gitlab-ce  
sudo gitlab-ctl reconfigure  
```