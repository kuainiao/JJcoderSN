#!/bin/bash
pvcreate  /dev/vdb
vgcreate vg1 /dev/vdb
lvcreate -L 1000G -n lv1 vg1
mkfs.xfs /dev/vg1/lv1
echo "/dev/vg1/lv1      /data           xfs             defaults                0 0" >> /etc/fstab
mount -a
