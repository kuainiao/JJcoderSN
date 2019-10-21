# jenkins install

------

# Jenkins Install

> Centos7 +

- Install

    ```shell
    ## install centos repo
    sudo yum install -y epel-release
    sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
    sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
    sudo yum install jenkins
    ```

- install base java

```shell
  sudo yum install -y java
```

- command AND status

```shell
systemctl start jenkins
systemctl enable jenkins
```