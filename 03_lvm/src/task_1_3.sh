
#!/bin/sh
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

echo "Убираем ненужные lv и vg"
lvremove -y /dev/vg_temproot/lv_temproot
vgremove -y /dev/vg_temproot

echo "Task 1 complete"