#!/bin/bash

# 由于需要和flannel配合使用，所以我们这里对docker.service文件做了修改，而且我们采取非二进制程序部署方式

DOCKER_VERSION=18.06.3-ce

read -p "开始部署docker服务,默认使用${DOCKER_VERSION}版本输入y继续 [y/n] " isContinue
if [[ ${isContinue} == "n" ]]; then
  echo "程序退出。"
  exit 0
fi
source ./environment.sh

cd ${TEMP_WORK_DIR}
pwd
echo -e "\033[32m[Task]\033[0m 检查当前目录是否有docker-${DOCKER_VERSION}.tgz二进制包。"
if [[ -e docker-${DOCKER_VERSION}.tgz ]]; then
  echo "  >>> 当前目录存在docker-${DOCKER_VERSION}.tgz" 
else
  echo "  >>> 当前目录没有docker-${DOCKER_VERSION}.tgz即将下载"
  wget https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz
fi
tar -xzf docker-${DOCKER_VERSION}.tgz


echo -e "\033[32m[Task]\033[0m 生成docker环境变量文件。"
# 这个环境变量是为了方便的使用docker命令
cat > dockercmdenv.sh << EOF
export DOCKER_HOME=${DOCKER_HOME}
export PATH=\${DOCKER_HOME}/bin:\$PATH
EOF

echo -e "\033[32m[Task]\033[0m 生成dockerd daemon.json文件。"
cat > docker-daemon.json <<EOF
{
  "hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"],
  "selinux-enabled": false,
  "registry-mirrors": ["https://5l96ckrn.mirror.aliyuncs.com", "https://docker.mirrors.ustc.edu.cn"],
  "max-concurrent-downloads": 20
}
EOF

echo -e "\033[32m[Task]\033[0m 生成dockerd服务启动文件。"
# $DOCKER_NETWORK_OPTIONS这个变量对应的内容是在docker_opts.env文件里，而这个文件是flannel的一个脚本生成的用于修改docker0的bip信息也就是docker0网段。
# Environment= dockerd 运行时会调用其它 docker 命令，如 docker-proxy，所以需要将 docker 命令所在的目录加到 PATH 环境变量中
# EnvironmentFile=这里这个文件前加了一个"-"表示抑制错误，也就是/run/docker_opts.env文件不存在也不会报错
cat > docker.service << EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
Environment="PATH=${DOCKER_HOME}/bin:/bin:/sbin:/usr/bin:/usr/sbin"
EnvironmentFile=-/run/docker_opts.env
ExecStart=${DOCKER_HOME}/bin/dockerd --config-file=${DOCKER_HOME}/cfg/docker-daemon.json \$DOCKER_NETWORK_OPTIONS
ExecReload=/bin/kill -s HUP \$MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

# 虽然环境变量文件里有一个全部主机的集合ALL_K8S_CLUSTER_NODES，而且docker在所有主机安装，但是我这里还是选择分开写。
echo -e "\033[32m[Task]\033[0m 拷贝docker程序、服务文件及配置文件到master节点并设置开机启动。"
for master_ip in ${MASTER_IPS[@]}; do
  echo "  >>> docker程序、服务文件及配置文件到 ${master_ip} master节点."
  if [[ ${master_ip} == ${EXEC_SCRIPT_HOST_IP} ]]; then
    cp ${TEMP_WORK_DIR}/docker/* ${DOCKER_HOME}/bin
    cp ${TEMP_WORK_DIR}/dockercmdenv.sh /etc/profile.d/dockercmdenv.sh
    cp ${TEMP_WORK_DIR}/docker-daemon.json ${DOCKER_HOME}/cfg
    cp ${TEMP_WORK_DIR}/docker.service /usr/lib/systemd/system/docker.service
    systemctl daemon-reload && systemctl enable docker
    continue
  fi
  echo "  >>> docker程序、服务文件及配置文件到 ${master_ip} master节点."
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/docker/* root@${master_ip}:${DOCKER_HOME}/bin
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/dockercmdenv.sh root@${master_ip}:/etc/profile.d/dockercmdenv.sh
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/docker-daemon.json root@${master_ip}:${DOCKER_HOME}/cfg
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/docker.service root@${master_ip}:/usr/lib/systemd/system/docker.service
  echo "  >>> 启用docker服务为开机启动."
  ssh -o StrictHostKeyChecking=no root@${master_ip} "systemctl daemon-reload && systemctl enable docker"
done

echo -e "\033[32m[Task]\033[0m 拷贝docker程序、服务文件及配置文件到node节点并设置开机启动。"
for node_ip in ${NODE_IPS[@]}; do
  echo "  >>> docker程序、服务文件及配置文件到 ${node_ip} node节点."
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/docker/* root@${node_ip}:${DOCKER_HOME}/bin
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/dockercmdenv.sh root@${node_ip}:/etc/profile.d/dockercmdenv.sh
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/docker-daemon.json root@${node_ip}:${DOCKER_HOME}/cfg
  scp -o StrictHostKeyChecking=no ${TEMP_WORK_DIR}/docker.service root@${node_ip}:/usr/lib/systemd/system/docker.service
  echo "  >>> 启用docker服务为开机启动."
  ssh -o StrictHostKeyChecking=no root@${node_ip} "systemctl daemon-reload && systemctl enable docker"
done

cp ${TEMP_WORK_DIR}/dockercmdenv.sh ${JOIN_CLUSTER_DIR}
cp ${TEMP_WORK_DIR}/docker-daemon.json ${JOIN_CLUSTER_DIR}
cp ${TEMP_WORK_DIR}/docker.service ${JOIN_CLUSTER_DIR}


