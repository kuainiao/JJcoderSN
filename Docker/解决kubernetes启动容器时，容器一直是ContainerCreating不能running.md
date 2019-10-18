# 解决kubernetes启动容器时，容器一直是ContainerCreating不能running

------



# 解决kubernetes启动容器时，容器一直是ContainerCreating不能running

## 现象

```shell
kubectl get pod redis
NAME READY STATUS RESTARTS AGE
kubetest-8s1rt1 0/1 ContainerCreating 0 12s
```

## 分心

### 首先执行kubectl describe pod

> describe 输出指定的一个/多个资源的详细信息。 详细可以参考：https://www.kubernetes.org.cn/doc-61

- 查看最后报错信息

```text
Error syncing pod, skipping: failed to "StartContainer" for "POD" with ErrImagePull: "image pull failed for registry.access.redhat.com/rhel7/pod-infrastructure:latest, this may be because there are no credentials on this request. details: (open /etc/docker/certs.d/registry.access.redhat.com/redhat-ca.crt: no such file or directory)"
```

- 查看/etc/docker/certs.d/registry.access.redhat.com/redhat-ca.crt 是一个软链接，但是链接过去后并没有真实的/etc/rhsm

```shell
yum install *rhsm*
```

- **安装完成后，如果还没有真实文件**

执行如下：

```shell
cd  /etc/rhsm/ca/
## 下载真实 ca文件
wget https://raw.githubusercontent.com/candlepin/subscription-manager/master/etc-conf/redhat-uep.pem
```

- 最后需要手动 docker pull 源

```shell
docker pull registry.access.redhat.com/rhel7/pod-infrastructure:latest
```