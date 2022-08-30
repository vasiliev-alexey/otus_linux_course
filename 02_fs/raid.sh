#!/bin/bash
mdadm --zero-superblock --force /dev/sd{b,c} -y
mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b,c} -y
mkfs.xfs /dev/md0 -f 
echo $(blkid|grep md0|awk '{print $2 " /mnt xfs defaults 0 0" }') >> /etc/fstab 
mount -a 
mkdir /etc/mdadm  && mdadm  --detail --scan >> /etc/mdadm/mdadm.conf