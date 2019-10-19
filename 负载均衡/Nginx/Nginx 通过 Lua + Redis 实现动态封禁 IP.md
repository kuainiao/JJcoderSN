# Nginx 通过 Lua + Redis 实现动态封禁 IP

### 一、背景

为了封禁某些爬虫或者恶意用户对服务器的请求，我们需要建立一个动态的 IP 黑名单。对于黑名单之内的 IP ，拒绝提供服务。

### 二、架构

实现 IP 黑名单的功能有很多途径：

1、在操作系统层面，配置 iptables，拒绝指定 IP 的网络请求；

2、在 Web Server 层面，通过 Nginx 自身的 deny 选项 或者 lua 插件 配置 IP 黑名单；

3、在应用层面，在请求服务之前检查一遍客户端 IP 是否在黑名单。

为了方便管理和共享，我们通过 Nginx+Lua+Redis 的架构实现 IP 黑名单的功能，架构图如下：

![img](Nginx%20%E9%80%9A%E8%BF%87%20Lua%20+%20Redis%20%E5%AE%9E%E7%8E%B0%E5%8A%A8%E6%80%81%E5%B0%81%E7%A6%81%20IP.assets/19687-0cce75bc979158d9.webp)

架构图

### 三、实现

1、安装 Nginx+Lua模块，推荐使用 OpenResty，这是一个集成了各种 Lua 模块的 Nginx 服务器：

![img](Nginx%20%E9%80%9A%E8%BF%87%20Lua%20+%20Redis%20%E5%AE%9E%E7%8E%B0%E5%8A%A8%E6%80%81%E5%B0%81%E7%A6%81%20IP.assets/19687-c6eff90c6cd05e5e.webp)

OpenResty

2、安装并启动 Redis 服务器；

3、配置 Nginx 示例：

![img](Nginx%20%E9%80%9A%E8%BF%87%20Lua%20+%20Redis%20%E5%AE%9E%E7%8E%B0%E5%8A%A8%E6%80%81%E5%B0%81%E7%A6%81%20IP.assets/19687-6356315a3039c0e5.webp)

Nginx 配置

其中

> lua_shared_dict ip_blacklist 1m;

由 Nginx 进程分配一块 1M 大小的共享内存空间，用来缓存 IP 黑名单，参见：

[https://github.com/openresty/lua-nginx-module#lua_shared_dict](https://link.jianshu.com/?t=https://github.com/openresty/lua-nginx-module#lua_shared_dict)

> access_by_lua_file lua/ip_blacklist.lua;

指定 lua 脚本位置

4、配置 lua 脚本，定期从 Redis 获取最新的 IP 黑名单，文件内容参见：

[https://gist.github.com/Ceelog/39862d297d9c85e743b3b5111b7d44cb](https://link.jianshu.com/?t=https://gist.github.com/Ceelog/39862d297d9c85e743b3b5111b7d44cb)

![img](Nginx%20%E9%80%9A%E8%BF%87%20Lua%20+%20Redis%20%E5%AE%9E%E7%8E%B0%E5%8A%A8%E6%80%81%E5%B0%81%E7%A6%81%20IP.assets/19687-7f522eb72e23b2fd.webp)

lua 脚本内容

5、在 Redis 服务器上新建 Set 类型的数据 ip_blacklist，并加入最新的 IP 黑名单。

完成以上步骤后，重新加载 nginx，配置便开始生效了

这时访问服务器，如果你的 IP 地址在黑名单内的话，将出现拒绝访问：

![img](Nginx%20%E9%80%9A%E8%BF%87%20Lua%20+%20Redis%20%E5%AE%9E%E7%8E%B0%E5%8A%A8%E6%80%81%E5%B0%81%E7%A6%81%20IP.assets/19687-2ffed3cd588614c5.webp)

拒绝访问

### 四、总结

以上，便是 Nginx+Lua+Redis 实现的 IP 黑名单功能，具有如下优点：

1、配置简单、轻量，几乎对服务器性能不产生影响；

2、多台服务器可以通过Redis实例共享黑名单；

3、动态配置，可以手工或者通过某种自动化的方式设置 Redis 中的黑名单。