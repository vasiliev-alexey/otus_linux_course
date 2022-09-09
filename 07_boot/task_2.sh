#!/bin/bash
echo "check"
vgs
echo "rename VG"
vgrename VolGroup00 OtusVg

echo "replace VG"
sed -i 's/VolGroup00/OtusVg/g' /etc/default/grub && sed -i 's/VolGroup00/OtusVg/g' /boot/grub2/grub.cfg && sed -i 's/VolGroup00/OtusVg/g' /etc/fstab

echo "regenerate initramfs"
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
echo "reboot"

#reboot