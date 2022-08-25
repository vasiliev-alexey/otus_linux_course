#!/bin/sh
echo "go home )"
cd ~
echo "Создадим начальные данные"

touch test_data{1..2}
echo 'random data' > test_data1

echo "Создаем снапшот"
sudo lvcreate -L 1G -s -n Home_snapshot /dev/VolGroup00/LogVol02Home

echo "Мутирруем данные в разделе"
touch test_data3
echo 'test2' > test_data1
echo 'test3' > test_data3
rm -f test_data2
echo "Откат на созаднный ранее снапшот"
cd /
sudo umount /home
sudo lvconvert --merge /dev/VolGroup00/Home_snapshot
sudo  mount -a

echo "Верификация данных"
ls -l /home/vagrant
cat /home/vagrant/test_data1

echo "Удаляем тестовый данные"
rm -f /home/vagrant/test_data{1..3}
 
echo  "Task 4 and 6  complete" 