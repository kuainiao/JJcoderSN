# ansible 优化配置

------

# ansible 优化

## ControlPersist

高版本的 ssh 具有 ControlPersist 特性，即 持久化 socket ,一次验证多次通信.并且只需要修改 ssh client 就行了，也就是 ansible 控制机即可

## 添加 ControlMaster 的配置

cat ~/.ssh/config

Host * Compression yes ServerAliveInterval 60 ServerAliveCountMax 5 ControlMaster auto ControlPath ~/.ssh/sockets/%r@%h-%p ControlPersist 4h

## pipelining

> 打开此选项可以减少 ansible 执行没有文件传输时 ssh 在远端机器上执行任务的连接数，不过如果使用 sudo ，必须关闭 requiretty 选项，选项默认关闭

```
   pipelining=True
```

看官方文档说关闭这个是为了兼容不同的 sudo 配置，如果不使用 sudo，还是推荐开启的，这边本地通过管理十台云主机的批量执行命令，已经可以直观感受到执行速度的差异了