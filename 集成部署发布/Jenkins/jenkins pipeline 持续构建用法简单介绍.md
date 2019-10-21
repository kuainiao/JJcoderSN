# jenkins pipeline 持续构建用法简单介绍

------

# Jenkins pipeline

## 背景

前段时间一直在想，怎么做CI方面的东西，后来通过整理nginx、rabbitmq、bind等等一下软件的配置，虽然都有相关的备份。但是并没有统一管理，无法做相关治理的目的。

有这么**两种做法进行管理**：

- 通过ansible 进行管理及相关备份
    - 优点: 编辑简单、方便更改等等
    - 比较难做到很好版本管理
- 通过jenkins pipeline + gitlab 方式进行 配置文件治理。
    - 版本管理方便、回退方便、完全可以自动化发布
    - 需要 知晓整个构建原理、以及根据实际业务需要编写 相关脚本、需要知识相对负载。

我选择**第二种方案**进行治理，也就是本文主要讲解内容。背景介绍完成，进入正题。

### [#](http://www.liuwq.com/views/自动化工具/jenkins_type.html#架构思路)架构思路

![img](jenkins%20pipeline%20%E6%8C%81%E7%BB%AD%E6%9E%84%E5%BB%BA%E7%94%A8%E6%B3%95%E7%AE%80%E5%8D%95%E4%BB%8B%E7%BB%8D.assets/2019-07-23-125238.jpg)

git push 到gitlab >> 触发jenkins webhooks API >> 执行ansible

### [#](http://www.liuwq.com/views/自动化工具/jenkins_type.html#jenkins-所需插件)jenkins 所需插件

在插件里面搜索pipeline ，凡是有pipeline的都安装，完成后，重启jenkins

### [#](http://www.liuwq.com/views/自动化工具/jenkins_type.html#gitlab-与-jenkins-绑定)gitlab 与 jenkins 绑定

- jenkins

![img](jenkins%20pipeline%20%E6%8C%81%E7%BB%AD%E6%9E%84%E5%BB%BA%E7%94%A8%E6%B3%95%E7%AE%80%E5%8D%95%E4%BB%8B%E7%BB%8D.assets/2019-07-03-022623.jpg)

![img](http://img.liuwenqi.com/blog/2019-07-03-022717.jpg)

- Gitlab

![img](jenkins%20pipeline%20%E6%8C%81%E7%BB%AD%E6%9E%84%E5%BB%BA%E7%94%A8%E6%B3%95%E7%AE%80%E5%8D%95%E4%BB%8B%E7%BB%8D.assets/2019-07-03-022744.jpg)

URL 添写上面 jenkins api ,如：**http://IP:8080/job/pip_base_conf/build?token=123654**

![img](http://img.liuwenqi.com/blog/2019-07-03-022840.jpg)

![img](jenkins%20pipeline%20%E6%8C%81%E7%BB%AD%E6%9E%84%E5%BB%BA%E7%94%A8%E6%B3%95%E7%AE%80%E5%8D%95%E4%BB%8B%E7%BB%8D.assets/2019-07-03-022903.jpg)

### [#](http://www.liuwq.com/views/自动化工具/jenkins_type.html#jenkins-pipeline-2)jenkins pipeline

![img](jenkins%20pipeline%20%E6%8C%81%E7%BB%AD%E6%9E%84%E5%BB%BA%E7%94%A8%E6%B3%95%E7%AE%80%E5%8D%95%E4%BB%8B%E7%BB%8D.assets/2019-07-03-023019.jpg)

```yml
pipeline {
    agent any
    environment {
        def GIT_NAME = "base_conf"
        def CODE_DIR = "/cron"
        def GIT_ADDR = "git@10.18.12.172:OPS"
        def ANSIBLE_HOST_DIR = "/cron/base_conf/ansible_conf/ansible/base"
        def ANSIBLE_HOST_NAME = "nginx-all"
    }
    stages {
        stage('Git') {
            steps {
                sh '/root/scripts/jenkins_pip_git_pull.sh $CODE_DIR $GIT_NAME $GIT_ADDR'
            }
        }
        stage('Ansible Git pull') {
            steps {
                sh 'ansible -i $ANSIBLE_HOST_DIR $ANSIBLE_HOST_NAME  -m shell -a "cd $CODE_DIR/$GIT_NAME;git pull"'
            }
        }
    }
}
```

在你的ansible服务器上创建 jenkins_pip_git_pull.sh脚本，内容如下：

```bash
#!/bin/bash
## Version:1.0

GIT_DIR=$1
GIT_NAME=$2
GIT_ADDR=$3
#echo $GIT_DIR $GIT_NAME $GIT_ADDR
if [ -d ${GIT_DIR}/${GIT_NAME} ];then
        cd ${GIT_DIR}/${GIT_NAME}
        git pull
else
        cd ${GIT_DIR}
        git clone ${GIT_ADDR}/${GIT_NAME}.git
fi
```