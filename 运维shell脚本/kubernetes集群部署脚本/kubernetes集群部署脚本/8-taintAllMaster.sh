#!/bin/bash
# 为所有api-server角色也就是master主机打污点，因为我们把所有角色都安装到了Master主机上，Node主机只安装了Node应该具有的服务。
# 所以Master主机也可以当做Node主机使用来运行POD，除非特殊需要为了避免把POD调度到Master主机上运行所以我们为其打污点。
# NoSchedule: 一定不能被调度  PreferNoSchedule: 尽量不要调度  NoExecute: 不仅不会调度, 还会驱逐Node上已有的Pod

source ./environment.sh

read -p "请确保所有Master主机都已加入集群，如不确定请使用 kubectl get nodes 命令查看，输入y继续本脚本操作 [y/n] " isContinue
if [[ ${isContinue} == "n" ]]; then
  echo "程序退出。"
  exit 0
fi


echo -e "\033[32m[Task]\033[0m 为所有Master主机打污点。"
for master_name in ${MASTER_NAMES[@]}; do
  echo "为 ${master_name} 打污点，Key为dedicate Value为master 策略为 NoSchedule"
  ${KUBERNETES_SERVER_HOME}/bin/kubectl taint nodes ${master_name} node-role.kubernetes.io/master=:NoSchedule
  ${KUBERNETES_SERVER_HOME}/bin/kubectl describe node ${master_name} | grep "Taints"
done


echo "如果要删除污点可以运行命令 taint nodes ${master_name} node-role.kubernetes.io/master=:NoSchedule-"


