#!/bin/bash
vdisk=$(lsblk -l | grep ^vdb | cut -d' ' -f1)
sdisk=$(lsblk -l | grep ^sdb | cut -d' ' -f1)
path=$(pwd)
if [ "$sdisk" == 'sdb' ]; then
        pvcreate /dev/$sdisk
        if [ ! -d /dev/vg_data ];then
                vgcreate vg_data /dev/$sdisk
                lvcreate -l 100%free -n lv_data vg_data
                mkfs.xfs /dev/vg_data/lv_data
                mkdir -p /data
                echo "/dev/vg_data/lv_data      /data           xfs             defaults                0 0" >> /etc/fstab
                mount -a
       fi
fi
if [ "$vdisk" == 'vdb' ]; then
        pvcreate /dev/$vdisk
        if [ ! -d /dev/vg_data ];then
                vgcreate vg_data /dev/$vdisk
                lvcreate -l 100%free -n lv_data vg_data
                mkfs.xfs /dev/vg_data/lv_data
                mkdir -p /data
                echo "/dev/vg_data/lv_data      /data           xfs             defaults                0 0" >> /etc/fstab
                mount -a
        fi
fi
rm -f $path/mount_disk.sh
