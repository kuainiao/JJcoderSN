# Vagrant的配置文件Vagrantfile详解

## 一、简介

在我们的工作目录下有一个Vagrantfile文件，里面包含有大量的配置信息，通过它可以定义虚拟机的各种配置，如网络、内存、主机名等，主要包括三个方面的配置，虚拟机的配置、SSH配置、Vagrant的一些基础配置。Vagrant是使用Ruby开发的，所以它的配置语法也是Ruby的，每个项目都需要有一个Vagrantfile，在执行vagrant init的目录下可以找到该文件

## 二、Vagrantfile文件

```ruby
# -*- mode: ruby -*-

# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure

# configures the configuration version (we support older styles for

# backwards compatibility). Please don't change it unless you know what

# you're doing.

Vagrant.configure("2") do |config|

  # The most common configuration options are documented and commented below.

  # For a complete reference, please see the online documentation at

  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for

  # boxes at https://atlas.hashicorp.com/search.

  config.vm.box = "centos7"

  # Disable automatic box update checking. If you disable this, then

  # boxes will only be checked for updates when the user runs

  # `vagrant box outdated`. This is not recommended.

  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port

  # within the machine from a port on the host machine. In the example below,

  # accessing "localhost:8080" will access port 80 on the guest machine.

  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine

  # using a specific IP.

  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.

  # Bridged networks make the machine appear as another physical device on

  # your network.

  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is

  # the path on the host to the actual folder. The second argument is

  # the path on the guest to mount the folder. And the optional third

  # argument is a set of non-required options.

  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various

  # backing providers for Vagrant. These expose provider-specific options.

  # Example for VirtualBox:

  #

  # config.vm.provider "virtualbox" do |vb|

  #   # Display the VirtualBox GUI when booting the machine

  #   vb.gui = true

  #

  #   # Customize the amount of memory on the VM:

  #   vb.memory = "1024"

  # end

  #

  # View the documentation for the provider you are using for more

  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies

  # such as FTP and Heroku are also available. See the documentation at

  # https://docs.vagrantup.com/v2/push/atlas.html for more information.

  # config.push.define "atlas" do |push|

  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"

  # end

  # Enable provisioning with a shell script. Additional provisioners such as

  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the

  # documentation for more information about their specific syntax and use.

  # config.vm.provision "shell", inline: <<-SHELL

  #   apt-get update

  #   apt-get install -y apache2

  # SHELL

end
```


可发现其中就两行配置:

```
Vagrant.configure("2") do |config|
config.vm.box = "centos7"
```


这两行就是我们在vagrant init中后面所指定的参数。由此可以看出，vagrant init只是帮我们生成了配置文件而已，换句话说，如果我们写好了Vagrantfile，就不需要vagrant init，只需将准备好的配置文件放入到所需目录中，然后直接执行vagrant up即可。

还有很多注释掉的配置，那些都是一些常用的配置，包括网卡设置、IP地址、绑定目录，甚至可以指定内存大小、CPU个数、是否启动界面等等。如果需要，可以根据注释文本进行配置。

## 三、 配置详解

下面是一些常用的配置：

> `config.vm.hostname`：配置虚拟机主机名
> `config.vm.network`：这是配置虚拟机网络，由于比较复杂，我们其后单独讨论
> `config.vm.synced_folder`：除了默认的目录绑定外，还可以手动指定绑定
> `config.ssh.username`：默认的用户是vagrant，从官方下载的box往往使用的是这个用户名。如果是自定制的box，所使用的用户名可能会有所不同，通过这个配置设定所用的用户名。
> `config.vm.provision`：我们可以通过这个配置在虚拟机第一次启动的时候进行一些安装配置

需要注意的是，Vagrantfile文件只会在第一次执行vagrant up时调用执行，其后如果不明确使用vagrant reload进行重新加载，否则不会被强制重新加载。

### 3.1、box设置

```
config.vm.box = "centos7"
```


该名称是再使用 vagrant init 中后面跟的名字。

### 3.2、hostname设置

```
config.vm.hostname = "node1"
```


设置hostname非常重要，因为当我们有很多台虚拟服务器的时候，都是依靠hostname來做识别的。比如，我安装了centos1,centos2 两台虚拟机，再启动时，我可以通过vagrant up centos1来指定只启动哪一台。

### 3.3、虚拟机网络设置

```
config.vm.network "private_network", ip: "192.168.10.11"
//Host-only模式

config.vm.network "public_network", ip: "10.1.2.61"
//Bridge模式
```


Vagrant的网络连接方式有三种：

`NAT` : 缺省创建，用于让vm可以通过host转发访问局域网甚至互联网。

`host-only` : 只有主机可以访问vm，其他机器无法访问它。

`bridge` : 此模式下vm就像局域网中的一台独立的机器，可以被其他机器访问。

```shell
config.vm.network :private_network, ip: "192.168.33.10"
#配置当前vm的host-only网络的IP地址为192.168.33.10
```


host-only 模式的IP可以不指定，而是采用dhcp自动生成的方式，如 :

```shell
config.vm.network "private_network", type: "dhcp”
#config.vm.network "public_network", ip: "192.168.0.17"
#创建一个bridge桥接网络，指定IP
#config.vm.network "public_network", bridge: "en1: Wi-Fi (AirPort)"
#创建一个bridge桥接网络，指定桥接适配器
config.vm.network "public_network"
#创建一个bridge桥接网络，不指定桥接适配器
```

### 3.4、同步目录设置

```
config.vm.synced_folder "D:/xxx/code", "/home/www/" 
```


前面的路径(D:/xxx/code)是本机代码的地址，后面的地址就是虚拟机的目录。虚拟机的/vagrant目录默认挂载宿主机的开发目录(可以在进入虚拟机机后，使用df -h 查看)，这是在虚拟机启动时自动挂载的。我们还可以设置额外的共享目录，上面这个设定，第一个参数是宿主机的目录，第二个参数是虚拟机挂载的目录。

### 3.5、端口转发设置

```
config.vm.network :forwarded_port, guest: 80, host: 8080
```


上面的配置把宿主机上的8080端口映射到客户虚拟机的80端口，例如你在虚拟机上使用nginx跑了一个Go应用，那么你在host上的浏览器中打开http://localhost:8080时，Vagrant就会把这个请求转发到虚拟机里跑在80端口的nginx服务上。不建议使用该方法，因为涉及端口占用问题，常常导致应用之间不能正常通信，建议使用Host-only和Bridge方式进行设置。

guest和host是必须的，还有几个可选属性：

`guest_ip`：字符串，vm指定绑定的Ip，缺省为0.0.0.0
`host_ip`：字符串，host指定绑定的Ip，缺省为0.0.0.0
`protocol`：字符串，可选TCP或UDP，缺省为TCP

### 3.6、定义vm的configure配置节点(一个节点就是一个虚拟机)

```
config.vm.define :mysql do |mysql_config|

# ...

end
```


表示在config配置中，定义一个名为mysql的vm配置，该节点下的配置信息命名为mysql_config； 如果该Vagrantfile配置文件只定义了一个vm，这个配置节点层次可忽略。

还可以在一个Vagrantfile文件里建立多个虚拟机，一般情况下，你可以用多主机功能完成以下任务：

▲ 分布式的服务，例如网站服务器和数据库服务器
▲ 分发系统
▲ 测试接口
▲ 灾难测试 

```shell
Vagrant.configure("2") do |config|

  config.vm.define "web" do |web|
    web.vm.box = "apache"
  end

  config.vm.define "db" do |db|
    db.vm.box = "mysql"
  end
end
```

当定义了多主机之后，在使用vagrant命令的时候，就需要加上主机名，例如vagrant ssh web；也有一些命令，如果你不指定特定的主机，那么将会对所有的主机起作用，比如vagrant up；你也可以使用表达式指定特定的主机名，例如

vagrant up /follower[0-9]/。

### 3.7、通用数据 设置一些基础数据，供配置信息中调用。

```shell
app_servers = {
    :service1 => '192.168.33.20',
    :service2 => '192.168.33.21'
}
```


这里是定义一个hashmap，以key-value方式来存储vm主机名和ip地址。

### 3.8、配置信息

```shell
ENV["LC_ALL"] = "en_US.UTF-8"
#指定vm的语言环境，缺省地，会继承host的locale配置
Vagrant.configure("2") do |config|
    # ...
end
```


参数2，表示的是当前配置文件使用的vagrant configure版本号为Vagrant 1.1+,如果取值为1，表示为Vagrant 1.0.x Vagrantfiles，旧版本暂不考虑，记住就写2即可。

do … end 为配置的开始结束符，所有配置信息都写在这两段代码之间。 config是为当前配置命名，你可以指定任意名称，如myvmconfig，在后面引用的时候，改为自己的名字即可。

### 3.9、vm提供者配置

```
config.vm.provider :virtualbox do |vb|
     # ...
end
```


▲vm provider通用配置

虚机容器提供者配置，对于不同的provider，特有的一些配置，此处配置信息是针对virtualbox定义一个提供者，命名为vb，跟前面一样，这个名字随意取，只要节点内部调用一致即可。

配置信息又分为通用配置和个性化配置，通用配置对于不同provider是通用的，常用的通用配置如下：

```shell
vb.name = "centos7"
#指定vm-name，也就是virtualbox管理控制台中的虚机名称。如果不指定该选项会生成一个随机的名字，不容易区分。
vb.gui = true

# vagrant up启动时，是否自动打开virtual box的窗口，缺省为false

vb.memory = "1024"
#指定vm内存，单位为MB
vb.cpus = 2
#设置CPU个数
```

▲vm provider个性化配置(virtualbox)

▲vm provider个性化配置(virtualbox)

上面的provider配置是通用的配置，针对不同的虚拟机，还有一些的个性的配置，通过vb.customize配置来定制。

对virtual box的个性化配置，可以参考：VBoxManage modifyvm 命令的使用方法。详细的功能接口和使用说明，可以参考virtualbox官方文档。

```shell
#修改vb.name的值
v.customize ["modifyvm", :id, "--name", "mfsmaster2"]

#如修改显存，缺省为8M，如果启动桌面，至少需要10M，如下修改为16M：
vb.customize ["modifyvm", :id, "--vram", "16"]

#调整虚拟机的内存
 vb.customize ["modifyvm", :id, "--memory", "1024"]

#指定虚拟CPU个数
 vb.customize ["modifyvm", :id, "--cpus", "2"]

#增加光驱：
vb.customize ["storageattach",:id,"--storagectl", "IDE Controller","--port","0","--device","0","--type","dvddrive","--medium","/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"]
#注：meduim参数不可以为空，如果只挂载驱动器不挂在iso，指定为“emptydrive”。如果要卸载光驱，medium传入none即可。
#从这个指令可以看出，customize方法传入一个json数组，按照顺序传入参数即可。

#json数组传入多个参数
v.customize ["modifyvm", :id, "--name", “mfsserver3", "--memory", “2048"]
```

### 4.0、一组相同配置的vm

前面配置了一组vm的hash map，定义一组vm时，使用如下节点遍历。

```shell
#遍历app_servers map，将key和value分别赋值给app_server_name和app_server_ip
app_servers.each do |app_server_name, app_server_ip|
     #针对每一个app_server_name，来配置config.vm.define配置节点，命名为app_config
     config.vm.define app_server_name do |app_config|
          # 此处配置，参考config.vm.define
     end
end
```

如果不想定义app_servers，下面也是一种方案:

```shell
(1..3).each do |i|
        config.vm.define "app-#{i}" do |node|
        app_config.vm.hostname = "app-#{i}.vagrant.internal"
        app_config.vm.provider "virtualbox" do |vb|
            vb.name = app-#{i}
        end
  end
end
```

### 4.1、provision任务

你可以编写一些命令，让vagrant在启动虚拟机的时候自动执行，这样你就可以省去手动配置环境的时间了。

▲ 脚本何时会被执行

● 第一次执行vagrant up命令
● 执行vagrant provision命令
● 执行vagrant reload --provision或者vagrant up --provision命令
● 你也可以在启动虚拟机的时候添加--no-provision参数以阻止脚本被执行
▲ provision任务是什么？

provision任务是预先设置的一些操作指令，格式：

```
config.vm.provision 命令字 json格式参数

config.vm.provion 命令字 do |s|
    s.参数名 = 参数值
end
```


每一个 config.vm.provision 命令字 代码段，我们称之为一个provisioner。
根据任务操作的对象，provisioner可以分为：

● Shell
● File
● Ansible
● CFEngine
● Chef
● Docker
● Puppet

● Salt

根据vagrantfile的层次，分为：

configure级：它定义在 Vagrant.configure("2") 的下一层次，形如： config.vm.provision ...

vm级：它定义在 config.vm.define "web" do |web| 的下一层次，web.vm.provision ...

执行的顺序是先执行configure级任务，再执行vm级任务，即便configure级任务在vm定义的下面才定义。例如：

```
Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: "echo 1"

  config.vm.define "web" do |web|
    web.vm.provision "shell", inline: "echo 2"
  end

  config.vm.provision "shell", inline: "echo 3"
end
```


输出结果：

```
==> default: "1"
==> default: "2"
==> default: "3"
```


▲ 如何使用
● 单行脚本


helloword只是一个开始，对于inline模式，命令只能在写在一行中。

单行脚本使用的基本格式：

```
config.vm.provision "shell", inline: "echo fendo"
```


shell命令的参数还可以写入do ... end代码块中，如下：

```
config.vm.provision "shell" do |s|
  s.inline = "echo hello provision."
end
```

● 内联脚本


如果要执行脚本较多，可以在Vagrantfile中指定内联脚本，在Vagrant.configure节点外面，写入命名内联脚本：

```
$script = <<SCRIPT
echo I am provisioning...
echo hello provision.
SCRIPT
```


然后，inline调用如下：

```
config.vm.provision "shell", inline: $script
```

● 外部脚本


也可以把代码写入代码文件，并保存在一个shell里，进行调用：

```
config.vm.provision "shell", path: "script.sh"
```


script.sh的内容：

```
echo hello provision.
```


注意:

如果使用provision来安装程序，如yum install lrzsz会出现如下错误:

```shell
E:\OS_WORK\Node2>vagrant reload --provision
==> test: Attempting graceful shutdown of VM...
==> test: Clearing any previously set forwarded ports...
==> test: Clearing any previously set network interfaces...
==> test: Preparing network interfaces based on configuration...
    test: Adapter 1: nat
    test: Adapter 2: hostonly
==> test: Forwarding ports...
    test: 22 (guest) => 2222 (host) (adapter 1)
==> test: Running 'pre-boot' VM customizations...
==> test: Booting VM...
==> test: Waiting for machine to boot. This may take a few minutes...
    test: SSH address: 127.0.0.1:2222
    test: SSH username: vagrant
    test: SSH auth method: private key
==> test: Machine booted and ready!
[test] GuestAdditions 5.1.24 running --- OK.
==> test: Checking for guest additions in VM...
==> test: Setting hostname...
==> test: Configuring and enabling network interfaces...
==> test: Mounting shared folders...
    test: /vagrant => E:/OS_WORK/Node2
==> test: Running provisioner: shell...
    test: Running: inline script
==> test: Loaded plugins: fastestmirror
==> test: Loading mirror speeds from cached hostfile
==> test:  * base: mirrors.shu.edu.cn
==> test:  * extras: mirrors.shu.edu.cn
==> test:  * updates: mirrors.shu.edu.cn
==> test: No package y available.
==> test: Resolving Dependencies
==> test: --> Running transaction check
==> test: ---> Package lrzsz.x86_64 0:0.12.20-36.el7 will be installed
==> test: --> Finished Dependency Resolution
==> test:
==> test: Dependencies Resolved
==> test:
==> test: ================================================================================
==> test:  Package         Arch             Version                  Repository      Size
==> test: ================================================================================
==> test: Installing:
==> test:  lrzsz           x86_64           0.12.20-36.el7           base            78 k
==> test:
==> test: Transaction Summary
==> test: ================================================================================
==> test: Install  1 Package
==> test:
==> test: Total download size: 78 k
==> test: Installed size: 181 k
==> test: Is this ok [y/d/N]: Is this ok [y/d/N]: Exiting on user command
==> test: Your transaction was saved, rerun it with:
==> test:  yum load-transaction /tmp/yum_save_tx.2018-05-13.04-28.1BMR07.yumtx
The SSH command responded with a non-zero exit status. Vagrant
assumes that this means the command failed. The output for this command
should be in the log above. Please read the output to determine what
went wrong. 
```


使用yum install -y就行了。
修改完Vagrantfile的配置后，记得要重启虚拟机，才能使用虚拟机更新后的配置。

```
vagrant reload

```

